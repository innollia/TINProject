"""proc_bake - bake a procedural creature spec straight to a PNG.

    python -m procbake.bake spec.json
    python -m procbake.bake specs/*.json -o out/ --strip 8 --motion walk
    python -m procbake.bake spec.json --preview-shape limb_femur

One spec in, one set of PNGs out.  No Godot, no scene tree, no lock file - the
whole point is that an agent can iterate on a silhouette in under a second and
look at the result.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
import time
from pathlib import Path

import numpy as np

from . import sheet as sheet_mod
from .canvas import Canvas
from .check import SILHOUETTE_DEV, SILHOUETTE_FILL, silhouette_report
from .creature import Creature
from .rig import Rig, chain_bone_lengths, gait_targets, motion_targets
from .shapes import ShapeLibrary

ROOT = Path(__file__).resolve().parent.parent
KNEE_GATE_DEG = 45.0     # below this a leg folds into a ring instead of a limb
FOOT_SPLAY = 0.42         # how far sideways of its own hip a foot may land, in leg spans
WORLD_SCALE_FLOOR = 0.22  # below this a part is too small to read as anything


def _bone_parts(rig, chain: list) -> list:
    """Which entries of a chain are bones, and so may be rescaled.

    A chain is [upper, lower, end].  The upper and lower are bones; the end is
    a foot, a flipper or a claw.  On a two part chain there is no lower, so
    slicing [:2] grabs the foot - which is how a whole batch of creatures ended
    up rendering with no legs.
    """
    return chain[:2] if len(chain) >= 3 else chain[:1]
DEFAULT_SHAPE_DIRS = [
    ROOT / "shapes",
    ROOT.parent.parent / "core" / "procedural-icon-dlc" / "shapes",
]


def load_library(extra: list[str] | None = None) -> ShapeLibrary:
    dirs = list(DEFAULT_SHAPE_DIRS) + [Path(p) for p in (extra or [])]
    return ShapeLibrary(dirs)


def load_spec(path: Path) -> dict:
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def build(spec: dict, library: ShapeLibrary) -> Creature:
    return Creature.from_spec(spec, library)


def render_rest(creature: Creature) -> Canvas:
    return creature.render(creature.rest_placement())


def render_strip(creature: Creature, spec: dict, frames: int, motion: str,
                 settle: float = 1.2, fps: float = 30.0) -> list:
    """Run the rig, then sample `frames` poses evenly over one gait cycle.

    A spec with "legs" uses planted inverse kinematics: the feet are targets on
    a ground line and the body rides over them.  A spec without one falls back to
    per-joint target offsets, which is right for a tail or a breathing torso but
    makes a walk float.
    """
    placement = creature.rest_placement()
    rig = Rig(creature, placement, spec.get("physics"))
    block = spec.get("motion", {})
    amount = block.get(motion) or block.get("idle") or {}
    cycle = float(block.get("cycle", 1.0))
    legs = spec.get("legs")
    # default ground: wherever the feet already rest, so the authored pose stands
    ground = float(spec.get("ground", max(p.position[1] for p in placement.values())))
    stride = float(spec.get("stride", 16.0))
    lift = float(spec.get("lift", 10.0))
    duty = float(spec.get("duty", 0.62))
    for _ in range(int(settle * 60.0)):
        rig.step(1.0 / 60.0, motion_targets(rig, motion, rig.time, amount))
        if legs:
            gait_targets(rig, legs, rig.time, ground, stride, lift, duty, cycle)
    out = []
    for _ in range(frames):
        rig.step(cycle / max(frames, 1), motion_targets(rig, motion, rig.time, amount))
        if legs:
            gait_targets(rig, legs, rig.time, ground, stride, lift, duty, cycle)
        out.append(creature.render(rig.placement()))
    return out


def preview_shape(library: ShapeLibrary, name: str) -> Canvas:
    from . import palette as pal_mod
    shape = library.get(name)
    w = int(shape.bounds[2] - shape.bounds[0]) + 8
    h = int(shape.bounds[3] - shape.bounds[1]) + 8
    canvas = Canvas(w, h)
    pal = pal_mod.derive("analogous", 0.55, 0.5, 1.0)
    contours = shape.transformed((-shape.bounds[0] + 4.0, -shape.bounds[1] + 4.0), 0.0, 1.0)
    from .sdf import poly_sdf_points
    import numpy as np
    pts = np.stack(np.meshgrid(np.arange(w) + 0.5, np.arange(h) + 0.5), axis=-1).reshape(-1, 2)
    field = poly_sdf_points(contours, pts)[0].reshape(h, w)
    canvas.paint_ink(field, pal.get(pal_mod.ROLE_INK), 2.0)
    canvas.paint_field(field, pal.get(pal_mod.ROLE_BODY))
    canvas.paint_shade(field, pal.mix(pal_mod.ROLE_BODY, pal_mod.ROLE_SHADE, 0.55), 4.0)
    canvas.paint_key(field, pal.mix(pal_mod.ROLE_BODY, pal_mod.ROLE_KEY_LIGHT, 0.45), 1.0)
    # the spine, so a wrong data-joints is visible at a glance
    joints = shape.spine + np.array([-shape.bounds[0] + 4.0, -shape.bounds[1] + 4.0])
    for i in range(len(joints) - 1):
        canvas.draw_line(joints[i], joints[i + 1], (1.0, 0.25, 0.35, 1.0), 1.0)
    for j in joints:
        canvas.draw_circle(j, 2.0, (1.0, 0.9, 0.2, 1.0))
    return canvas


def leg_report(creature: Creature, spec: dict) -> list:
    """Reachability of every IK leg chain.

    A chain is only solvable if the rest pose it was AUTHORED at is inside the
    annulus the two bones can span.  Fold the knee too far and the rest foot
    sits past the leg's maximum reach; the IK then saturates, the knee flips
    between frames, and the leg renders as a scribble.  Nothing catches that
    by eye at a glance, so the tool refuses the spec instead.
    """
    out = []
    placement = creature.rest_placement()
    ground = float(spec.get("ground", max(p.position[1] for p in placement.values())))
    rig = Rig(creature, placement, spec.get("physics"))
    for entry in spec.get("legs") or []:
        chain = entry["chain"]
        if len(chain) < 2:
            out.append({"chain": chain, "ok": False, "why": "chain needs 2+ parts"})
            continue
        upper, lower = rig.joints[chain[0]], rig.joints[chain[1]]
        l1, l2 = chain_bone_lengths(rig, chain)
        lo, hi = abs(l1 - l2), l1 + l2
        hip = upper.rest_offset
        parent = rig.joints[upper.parent]
        c, s = math.cos(parent.rot), math.sin(parent.rot)
        hip_world = parent.pos + np.array([c * hip[0] - s * hip[1], s * hip[0] + c * hip[1]])
        rest_foot = placement[chain[-1]].position
        reach = float(np.linalg.norm(rest_foot - hip_world))
        margin = hi - reach
        knee = placement[chain[1]].position
        # interior angle at the knee.  Below ~45 degrees the leg doubles back on
        # itself and reads as a closed ring hanging off the hip, not a limb.
        knee_deg = None
        a = rest_foot - knee
        b = hip_world - knee
        na, nb = float(np.linalg.norm(a)), float(np.linalg.norm(b))
        if na > 1e-6 and nb > 1e-6:
            cosang = float(np.clip(np.dot(a, b) / (na * nb), -1.0, 1.0))
            knee_deg = round(math.degrees(math.acos(cosang)), 1)
        row = {"chain": chain, "l1": round(l1, 1), "l2": round(l2, 1),
               "reach": round(reach, 1), "max": round(hi, 1), "min": round(lo, 1),
               "margin": round(margin, 1), "knee_deg": knee_deg,
               "bend": entry.get("bend", 1.0)}
        row["ok"] = bool(margin > 0.04 * hi and reach > lo + 0.04 * hi)
        if not row["ok"]:
            row["why"] = (f"rest reach {reach:.1f} outside [{lo:.1f}, {hi:.1f}] "
                          f"({margin:+.1f} slack) - IK will saturate and the knee flips")
        elif knee_deg is not None and knee_deg < KNEE_GATE_DEG:
            row["ok"] = False
            row["why"] = (f"knee angle {knee_deg}deg < {KNEE_GATE_DEG}deg - the leg folds back "
                          "on itself and reads as a ring, not a limb (flip `bend` or shorten the lift)")
        out.append(row)
    return out


def autopose(spec: dict, library: ShapeLibrary, stance: float = 0.78) -> dict:
    """Rewrite every leg chain so it STANDS: reachable, the right length, feet
    on one line.

    Three things go wrong in a hand-authored leg and none of them is obvious at a
    glance.  Reach: fold the knee too far and the rest foot lands outside the
    annulus the two bones span; the IK saturates, the knee snaps between frames
    and the leg renders as a scribble (11 of 20 first-batch creatures did this).
    Length: a leg too short to hold the body at its authored hip height has to
    lock straight, so the creature ends up lying in its own belly with two
    sticks poking sideways.  Line: legs authored independently land on different
    heights, so the walk floats.

    So, once, deterministically: take the lowest authored foot as the ground,
    scale every leg so hip-to-ground is `stance` of full extension, then solve
    each rest pose onto that ground and write the angles back.  No iteration -
    an earlier version that re-scaled until it converged ran away, because each
    pass moved the ground it was measuring against.
    """
    spec = json.loads(json.dumps(spec))
    by_id = {p["id"]: p for p in spec["parts"]}
    chains = [e for e in (spec.get("legs") or []) if len(e["chain"]) >= 2]
    if not chains:
        return spec

    def hips_of(current: dict):
        creature = Creature.from_spec(current, library)
        placement = creature.rest_placement()
        rig = Rig(creature, placement, current.get("physics"))
        out = {}
        for entry in chains:
            upper = rig.joints[entry["chain"][0]]
            parent = rig.joints[upper.parent]
            c, s = math.cos(parent.rot), math.sin(parent.rot)
            hip = upper.rest_offset
            out[entry["chain"][0]] = parent.pos + np.array(
                [c * hip[0] - s * hip[1], s * hip[0] + c * hip[1]])
        return placement, rig, out, creature

    placement, rig, hips, _creature = hips_of(spec)
    ground = max(placement[entry["chain"][-1]].position[1] for entry in chains)

    # length: every leg holds the body at the same fraction of its own span
    for entry in chains:
        chain = entry["chain"]
        drop = max(ground - float(hips[chain[0]][1]), 1.0)
        have = sum(chain_bone_lengths(rig, chain))
        factor = min(max((drop / stance) / have, 0.7), 1.9)
        if abs(factor - 1.0) > 0.01:
            # Only the parts that ARE bones may be rescaled.  On a two part
            # chain the second entry is a foot, not a shin, and stretching it
            # drove every paw to a few pixels - the creature rendered with no
            # legs at all and nothing in the output said why.
            for pid in _bone_parts(rig, chain):
                part = by_id[pid]
                part["scale"] = round(float(part.get("scale", 1.0)) * factor, 3)

    placement, rig, hips, creature = hips_of(spec)
    for entry in chains:
        chain = entry["chain"]
        upper, lower = rig.joints[chain[0]], rig.joints[chain[1]]
        parent = rig.joints[upper.parent]
        l1, l2 = chain_bone_lengths(rig, chain)
        lo, hi = abs(l1 - l2), l1 + l2
        hip_world = hips[chain[0]]
        # A foot belongs under its own hip.  Left free, an authored foot that
        # sits far to one side makes the solver lay the shin out almost
        # sideways, and the leg plus the belly then close into a ring - which
        # reads as a hole in the animal rather than a limb.  Clamp the target to
        # the splay a real stance allows.
        span = sum(chain_bone_lengths(rig, chain))
        hip_x = float(hip_world[0])
        want_x = float(placement[chain[-1]].position[0])
        want_x = min(max(want_x, hip_x - span * FOOT_SPLAY), hip_x + span * FOOT_SPLAY)
        target = np.array([want_x, ground], dtype=np.float64)
        delta = target - hip_world
        reach = float(np.linalg.norm(delta))
        clamped = min(max(reach, lo * 1.02), hi * 0.97)
        target = hip_world + (delta / reach if reach > 1e-6 else np.array([1.0, 0.0])) * clamped
        rig.apply_ik(chain, target, bend=float(entry.get("bend", 1.0)))
        # A part's `angle` is measured from its parent's BONE heading, not from
        # the parent's rotation and not from the previous joint's world angle.
        # Getting this wrong on link 0 tilts it by however far the parent part
        # is rotated; getting it wrong on link 1 forgets the bone heading of the
        # upper link entirely.  Both produce a rest pose the IK never solved.
        for slot in (0, 1):
            joint_id = chain[slot]
            child = creature._by_id[joint_id]
            parent_id = rig.joints[joint_id].parent
            parent_shape = creature.shape_of(creature._by_id[parent_id])
            # the CHILD's `at` picks the point on the parent's spine, which is
            # the same point rest_placement() samples.  Using the parent's own
            # `at` here samples a different place and quietly rotates every leg.
            bone = parent_shape.spine_dir_at(child.at)
            bone_rad = math.atan2(float(bone[1]), float(bone[0]))
            # the parent's CURRENT rotation, not the pre-pass one: writing link
            # 0's angle changed it, and a stale value leaves link 1 aimed at the
            # old place.  probe.py exists to keep this round trip honest.
            parent_rest = rig.joints[parent_id].rot
            by_id[joint_id]["angle"] = round(
                math.degrees(rig.joints[joint_id].rot - parent_rest - bone_rad), 2)
    return spec


def bake_one(spec_path: Path, out_dir: Path, library: ShapeLibrary, args) -> dict:
    spec = load_spec(spec_path)
    name = spec.get("name") or spec_path.stem
    started = time.perf_counter()
    creature = build(spec, library)
    out_dir.mkdir(parents=True, exist_ok=True)

    rest = render_rest(creature)
    rest_path = out_dir / f"{name}.png"
    rest.save(rest_path)

    written = [rest_path]
    strip_frames = []
    if args.strip and args.strip > 0:
        strip_frames = render_strip(creature, spec, args.strip, args.motion)
        strip_img = sheet_mod.compose(strip_frames, columns=args.strip, pad=args.pad,
                                      background=None)
        strip_path = out_dir / f"{name}_{args.motion}_strip.png"
        strip_img.save(strip_path)
        written.append(strip_path)

    report = {
        "name": name,
        "spec": str(spec_path),
        "canvas": [rest.width, rest.height],
        "used_rect": list(rest.used_rect()),
        "parts": len(creature.parts),
        "shapes": sorted({p.shape for p in creature.parts}),
        "palette": creature.palette.to_dict(),
        "silhouette": silhouette_report(rest),
        "seconds": round(time.perf_counter() - started, 3),
        "files": [str(p) for p in written],
    }
    sil = report["silhouette"]
    if sil.get("dev_small", 0.0) < SILHOUETTE_DEV:
        report["errors"] = [f"G1 dev_small={sil.get('dev_small')} < {SILHOUETTE_DEV} "
                            "(silhouette is a smooth blob at 40px)"]
    if sil.get("fill_ratio", 1.0) < SILHOUETTE_FILL:
        report.setdefault("errors", []).append(
            f"fill_ratio={sil.get('fill_ratio')} < {SILHOUETTE_FILL} (sprite is mostly empty)")
    legs = leg_report(creature, spec)
    report["legs"] = legs
    for row in legs:
        if not row.get("ok"):
            report.setdefault("errors", []).append(f"G3 leg {'>'.join(row['chain'])}: {row.get('why')}")
    # `scale` is relative to the parent, so it compounds down a chain and three
    # parts at 0.4 land at 0.4 / 0.16 / 0.064.  Nothing in a spec makes that
    # visible, and it has silently produced whole batches of creatures a few
    # pixels tall, so the composed result is stated rather than assumed.  A spec
    # may carry "g4_exempt" with its reason when the small parts are limb tips
    # on a tapering body and carry no chain - that is a judgement made once, in
    # the file, and visible in the diff.
    tiny = creature.tiny_parts()
    if tiny and not spec.get("g4_exempt"):
        report.setdefault("errors", []).append(
            f"G4 world scale under {WORLD_SCALE_FLOOR}: {', '.join(tiny)} - "
            "`scale` is relative to the parent and compounds down a chain")
    used = rest.used_rect()
    span = max(used[2] - used[0], used[3] - used[1])
    if span < 40:
        report.setdefault("errors", []).append(
            f"G4 creature is only {span}px across - check the same compounding scale")
    if span > 900:
        report.setdefault("errors", []).append(
            f"G4 creature is {span}px across - a scale has run away, check the chain")
    (out_dir / f"{name}_bake.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


def bake_many(paths, out_dir: Path, library: ShapeLibrary, args) -> list:
    reports = []
    for path in paths:
        try:
            reports.append(bake_one(Path(path), out_dir, library, args))
        except Exception as exc:                      # keep going: a batch is a batch
            reports.append({"spec": str(path), "error": f"{type(exc).__name__}: {exc}"})
    if len(reports) > 1 and args.sheet:
        frames, labels = [], []
        for report in reports:
            if "error" in report:
                continue
            img = Image.open(report["files"][0])
            frames.append(img)
            labels.append(report["name"])
        if frames:
            target = max(f.height for f in frames)
            norm = [sheet_mod.scale_image(f, sheet_mod.scale_factor(f, target)) for f in frames]
            cols = int(math.ceil(math.sqrt(len(norm)))) or 1
            sheet_mod.compose(norm, columns=cols, pad=args.pad, background=(24, 24, 27, 255),
                              labels=labels).save(out_dir / f"{args.sheet}.png")
    return reports


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="proc_bake", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("specs", nargs="*", type=Path, help="creature spec JSON files")
    parser.add_argument("-o", "--out", type=Path, default=ROOT / "out", help="output directory")
    parser.add_argument("--shapes", nargs="*", default=[], help="extra shape directories")
    parser.add_argument("--strip", type=int, default=8, help="frames in the motion strip (0 = off)")
    parser.add_argument("--motion", default="walk", help="idle | walk | land | alert")
    parser.add_argument("--pad", type=int, default=8, help="sheet padding")
    parser.add_argument("--sheet", default="", help="also write a contact sheet under this name")
    parser.add_argument("--list-shapes", action="store_true")
    parser.add_argument("--autopose", type=Path, default=None,
                        help="rewrite this spec's leg angles to a solvable IK pose, in place")
    parser.add_argument("--preview-shape", default="", help="render one part and its spine")
    args = parser.parse_args(argv)

    if args.autopose:
        library = load_library(args.shapes)
        spec = load_spec(args.autopose)
        fixed = autopose(spec, library)
        args.autopose.write_text(json.dumps(fixed, indent=2), encoding="utf-8")
        rows = leg_report(Creature.from_spec(fixed, library), fixed)
        bad = [r for r in rows if not r.get("ok")]
        print(f"autopose {args.autopose.name}: {len(rows) - len(bad)}/{len(rows)} chains solvable")
        for r in bad:
            print(f"  still broken: {'>'.join(r['chain'])} {r.get('why','')}", file=sys.stderr)
        return 1 if bad else 0

    library = load_library(args.shapes)
    if args.list_shapes:
        for shape_name in library.names():
            shape = library.shapes[shape_name]
            print(f"{shape_name:28s} spine={len(shape.spine):2d} len={shape.length:6.1f} "
                  f"detail={int(shape.detail)}")
        return 0
    if args.preview_shape:
        out = preview_shape(library, args.preview_shape)
        args.out.mkdir(parents=True, exist_ok=True)
        path = args.out / f"shape_{args.preview_shape}.png"
        out.save(path)
        print(path)
        return 0
    if not args.specs:
        parser.error("no specs given (or use --list-shapes / --preview-shape)")

    reports = bake_many(args.specs, args.out, library, args)
    failed = 0
    for report in reports:
        if "error" in report:
            failed += 1
            print(f"FAIL {report['spec']}: {report['error']}", file=sys.stderr)
        elif report.get("errors"):
            print(f"WARN {report['name']:24s} {' + '.join(report['errors'])}", file=sys.stderr)
        else:
            print(f"ok   {report['name']:24s} {report['canvas'][0]}x{report['canvas'][1]:<4d} "
                  f"parts={report['parts']:<3d} {report['seconds']}s")
    return 1 if failed else 0


from PIL import Image  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
