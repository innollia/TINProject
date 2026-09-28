"""Spring rig: the part tree that walks, breathes and lands.

Physics first, drawing second, always - same order core/procedural documents.
Each part is one joint.  A joint springs toward where its parent says it should
be, so a tail drags behind a turning torso for free.  Rotation and squash are
read off how far the bone actually moved, never kept as extra springs; that is
what keeps a limb from sliding off its own bone.

Fixed substep, so a strip is identical at 24, 60 or 240 fps.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np

SUBSTEP = 1.0 / 240.0
MAX_SUBSTEP = 1.0 / 30.0


@dataclass
class Joint:
    part_id: str
    parent: str | None
    rest_pos: np.ndarray            # world rest position
    rest_rot: float                 # world rest rotation, radians
    rest_offset: np.ndarray         # seat in the parent's local frame
    rest_rel_rot: float             # rest rotation relative to the parent bone
    stiffness: float = 140.0
    damping: float = 0.60
    follow: str = "soft"
    squash_limit: float = 0.35
    rest_scale: float = 1.0
    pos: np.ndarray = field(default=None, repr=False)
    vel: np.ndarray = field(default=None, repr=False)
    rot: float = 0.0
    rot_vel: float = 0.0
    squash: float = 0.0
    parent_bone_len: float = 1.0
    rest_bone_len: float = 1.0


def chain_bone_lengths(rig: "Rig", chain: list) -> tuple[float, float]:
    """Lengths of the two links a chain actually articulates.

    A joint's `rest_bone_len` is the bone leading INTO it, so for a leg
    [femur, shin, foot] the femur's own entry is the torso->hip distance and
    the femur's LENGTH is the bone into the shin.  Reading them the naive way
    gives the IK a leg far longer than the one being drawn, so the knee never
    bends properly and the reach comes out wrong.  Link 0 is therefore the bone
    into chain[1], and link 1 the bone into chain[2] - or, for a two part chain,
    the last part's own drawn length.
    """
    first = rig.joints[chain[1]].rest_bone_len
    if len(chain) >= 3:
        second = rig.joints[chain[2]].rest_bone_len
    else:
        part = rig.creature._by_id[chain[1]]
        second = rig.creature.shape_of(part).length * max(part.scale, 1e-4)
    return first, second


class Rig:
    def __init__(self, creature, placement: dict, spec: dict | None = None):
        self.creature = creature
        self.spec = spec or {}
        self.joints: dict[str, Joint] = {}
        self.order: list[str] = []
        for part in creature.parts:
            place = placement[part.id]
            parent_place = placement[part.parent] if part.parent else None
            if part.parent is None:
                rest_offset = np.zeros(2)
                rest_rel_rot = 0.0
                rest_scale = part.scale
            else:
                # The seat has to be stored in the PARENT's local frame.  Storing
                # the rest-world difference and rotating it by the parent's live
                # rotation double counts, which is what walks a foot off its shin.
                rest_offset = _rotate(place.position - parent_place.position,
                                      -parent_place.rotation)
                rest_rel_rot = place.rotation - parent_place.rotation
                rest_scale = place.scale
            joint = Joint(
                part_id=part.id,
                parent=part.parent,
                rest_pos=place.position.copy(),
                rest_rot=place.rotation,
                rest_offset=rest_offset,
                rest_rel_rot=rest_rel_rot,
                stiffness=max(part.stiffness, 1.0),
                damping=max(part.damping, 0.0),
                follow=part.follow if part.follow in ("soft", "rigid", "pinned") else "soft",
                squash_limit=float(self.spec.get("squash_limit", 0.35)),
                rest_scale=rest_scale,
            )
            joint.pos = joint.rest_pos.copy()
            joint.vel = np.zeros(2)
            joint.rot = joint.rest_rot
            if part.parent is not None:
                joint.rest_bone_len = float(np.linalg.norm(rest_offset)) or 1.0
                joint.parent_bone_len = joint.rest_bone_len
            self.joints[part.id] = joint
            self.order.append(part.id)
        self.time = 0.0
        self.gravity = float(self.spec.get("gravity", 0.0))
        self.wind = np.zeros(2)

    # ------------------------------------------------------------------ input
    def kick(self, part_id: str, impulse) -> None:
        joint = self.joints[part_id]
        joint.vel += np.asarray(impulse, dtype=np.float64)

    def spin(self, part_id: str, impulse: float) -> None:
        self.joints[part_id].rot_vel += impulse

    # ------------------------------------------------------------------ solve
    def step(self, delta: float, targets: dict | None = None) -> None:
        targets = targets or {}
        remaining = min(max(delta, 0.0), MAX_SUBSTEP)
        while remaining > 1e-9:
            h = min(SUBSTEP, remaining)
            self._integrate(h, targets)
            remaining -= h
            self.time += h

    def _integrate(self, h: float, targets: dict) -> None:
        for part_id in self.order:
            joint = self.joints[part_id]
            extra = targets.get(part_id)
            if joint.parent is None:
                want_pos = joint.rest_pos.copy()
                want_rot = joint.rest_rot
            else:
                parent = self.joints[joint.parent]
                want_pos_no_extra = parent.pos + _rotate(joint.rest_offset, parent.rot)
                want_pos = want_pos_no_extra
                want_rot = parent.rot + joint.rest_rel_rot
            if extra is not None:
                want_pos = want_pos + np.asarray(extra.get("pos", (0.0, 0.0)), dtype=np.float64)
                want_rot = want_rot + math.radians(float(extra.get("rot", 0.0)))
            if joint.follow == "pinned" and joint.parent is not None:
                joint.pos = joint.rest_pos.copy()
                joint.rot = joint.rest_rot
                joint.vel = np.zeros(2)
                joint.rot_vel = 0.0
                continue
            if joint.follow == "rigid":
                # welded to the parent: it may turn, it may never translate away
                joint.pos = want_pos_no_extra
                joint.rot = want_rot
                joint.vel = np.zeros(2)
                joint.rot_vel = 0.0
            else:
                k = joint.stiffness
                c = 2.0 * math.sqrt(k) * joint.damping
                acc = (want_pos - joint.pos) * k - joint.vel * c
                if self.gravity:
                    acc = acc + np.array([0.0, self.gravity])
                if joint.parent is None:
                    acc = acc + self.wind
                joint.vel = joint.vel + acc * h
                joint.pos = joint.pos + joint.vel * h
                rot_k = k * 1.6
                rot_c = 2.0 * math.sqrt(rot_k) * max(joint.damping, 0.05)
                joint.rot_vel += ((want_rot - joint.rot) * rot_k - joint.rot_vel * rot_c) * h
                joint.rot += joint.rot_vel * h
            self._read_bone(joint)

    def _read_bone(self, joint: Joint) -> None:
        """Squash comes from how short the bone actually got, clamped to the
        joint's limit and applied along the bone so area is preserved."""
        if joint.parent is None:
            joint.squash = 0.0
            return
        parent = self.joints[joint.parent]
        live = float(np.linalg.norm(joint.pos - parent.pos))
        rest = joint.rest_bone_len
        if rest < 1e-6:
            joint.squash = 0.0
            return
        amount = 1.0 - live / rest
        joint.squash = min(max(amount, -joint.squash_limit), joint.squash_limit)

    # ------------------------------------------------------------------ output
    def placement(self) -> dict:
        out = {}
        for part in self.creature.parts:
            joint = self.joints[part.id]
            squash = None
            if abs(joint.squash) > 1e-4:
                if joint.parent is None:
                    axis = 0.0
                else:
                    d = joint.pos - self.joints[joint.parent].pos
                    axis = math.atan2(float(d[1]), float(d[0])) if np.linalg.norm(d) > 1e-6 else 0.0
                along = 1.0 - joint.squash
                squash = (max(along, 0.15), 1.0 / max(along, 0.15), axis)
            out[part.id] = Placement(joint.pos, joint.rot, joint.rest_scale, squash)
        return out

    # ------------------------------------------------------------------ inverse kinematics
    def apply_ik(self, chain: list, target: np.ndarray, bend: float = 1.0) -> None:
        """Place `target` with a two bone chain and write the rotations back.

        `chain` is [upper, lower, ...]; only the first two links are solved, the
        rest rides along rigidly.  `bend` picks the elbow/knee direction: +1 puts
        the middle joint one way, -1 the other.

        This is what turns a scissor into a walk.  A leg whose foot is *pinned to
        a line* while the body bobs reads as weight-bearing; a leg that only
        rotates at the hip reads as a puppet.
        """
        if len(chain) < 2:
            raise ValueError(f"ik chain needs at least two parts, got {chain}")
        upper, lower = self.joints[chain[0]], self.joints[chain[1]]
        if upper.parent is None:
            raise ValueError(f"ik chain must start on a child joint, {chain[0]!r} is the root")
        l1, l2 = chain_bone_lengths(self, chain)
        hip = upper.rest_offset                     # the hip seat in its parent frame
        parent = self.joints[upper.parent]
        hip_world = parent.pos + _rotate(hip, parent.rot)
        target = np.asarray(target, dtype=np.float64)
        delta = target - hip_world
        reach = float(np.linalg.norm(delta))
        lo = abs(l1 - l2) + 1e-3
        hi = l1 + l2 - 1e-3
        clamped = min(max(reach, lo), hi)
        base = math.atan2(float(delta[1]), float(delta[0]))
        cos_a = (l1 * l1 + clamped * clamped - l2 * l2) / (2.0 * l1 * clamped)
        a = math.acos(min(max(cos_a, -1.0), 1.0))
        upper_rot = base - a * bend
        knee = hip_world + np.array([math.cos(upper_rot), math.sin(upper_rot)]) * l1
        lower_rot = math.atan2(float(target[1] - knee[1]), float(target[0] - knee[0]))
        upper.rot = upper_rot
        upper.vel = np.zeros(2)
        upper.rot_vel = 0.0
        lower.rot = lower_rot
        lower.vel = np.zeros(2)
        lower.rot_vel = 0.0
        # recompute the chain so the solved angles are what get drawn
        for link in chain:
            joint = self.joints[link]
            if joint.parent is not None:
                par = self.joints[joint.parent]
                joint.pos = par.pos + _rotate(joint.rest_offset, par.rot)
            self._read_bone(joint)


# --------------------------------------------------------------------- motion
def motion_targets(rig: Rig, kind: str, phase: float, amount: dict) -> dict:
    """Target offsets per part id.

    `kind` is idle | walk | land | alert.  Every entry is additive on top of the
    rig's own chain following, so a part with no entry simply rides its parent.
    """
    out: dict = {}
    t = phase
    for part_id, cfg in (amount or {}).items():
        joint = rig.joints.get(part_id)
        if joint is None:
            continue
        mode = str(cfg.get("mode", "sway"))
        amp = float(cfg.get("amp", 0.0))
        freq = float(cfg.get("freq", 1.0))
        phase_off = float(cfg.get("phase", 0.0))
        dx = dy = drot = 0.0
        w = t * freq + phase_off
        if mode == "sway":
            dx = math.sin(w) * amp
            dy = math.cos(w * 2.0) * amp * 0.25
            drot = math.sin(w) * float(cfg.get("rot", 0.0))
        elif mode == "swing":
            # rotation only: a limb turns about its seat instead of sliding off it
            drot = math.sin(w) * float(cfg.get("rot", 6.0))
            dy = -abs(math.sin(w)) * amp
        elif mode == "bob":
            dy = -abs(math.sin(w)) * amp
            drot = math.sin(w * 2.0) * float(cfg.get("rot", 0.0))
        elif mode == "step":
            # a scissor: the foot swings forward on one half cycle, back on the other
            s = math.sin(w)
            dx = s * amp
            dy = -max(0.0, -s) * amp * float(cfg.get("lift", 0.6))
            drot = s * float(cfg.get("rot", 0.0))
        elif mode == "pulse":
            pulse = 0.5 + 0.5 * math.sin(w)
            drot = pulse * float(cfg.get("rot", 0.0))
            dy = -pulse * amp
        if kind == "walk" and joint.follow == "soft":
            drot += math.sin(t * 6.0 + phase_off) * float(cfg.get("walk_rot", 0.0))
        out[part_id] = {"pos": (dx, dy), "rot": drot}
    return out


def gait_targets(rig: Rig, legs: list, t: float, ground: float, stride: float,
                 lift: float, duty: float = 0.62, cycle: float = 1.0) -> None:
    """Plant every leg on `ground` and stride it fore/aft in antiphase.

    A leg is in stance for `duty` of the cycle (foot sliding back along the
    ground) and lifts for the rest (foot swinging forward, off the line).  The
    vertical travel is a smooth arc on the lift half, which is what makes a
    footfall read as a footfall instead of a twitch.

    `cycle` is the walk period in SECONDS, the same number the strip advances
    by, so one strip of N frames covers exactly one gait.  Each leg gets
    `stride`/legs of ground distance and the phases are spread evenly, so a
    four-legged thing walks instead of hopping.
    """
    cycle = max(float(cycle), 1e-3)
    for index, leg in enumerate(legs):
        phase = 2.0 * math.pi * (t / cycle) + 2.0 * math.pi * index / max(len(legs), 1)
        s = (phase / (2.0 * math.pi)) % 1.0
        rest_x = rig.joints[leg["chain"][-1]].rest_pos[0]
        half = stride * 0.5
        if s < duty:
            k = s / duty
            x = rest_x + half - 2.0 * half * k
            y = ground
        else:
            k = (s - duty) / (1.0 - duty)
            x = rest_x - half + 2.0 * half * k
            y = ground - lift * math.sin(math.pi * k)
        rig.apply_ik(leg["chain"], np.array([x, y], dtype=np.float64),
                     bend=float(leg.get("bend", 1.0)))


def _rotate(v, angle: float) -> np.ndarray:
    c, s = math.cos(angle), math.sin(angle)
    return np.array([c * v[0] - s * v[1], s * v[0] + c * v[1]], dtype=np.float64)


from .creature import Placement  # noqa: E402
