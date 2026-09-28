"""Does an IK solution survive the trip back into a spec?

Autopose solves a pose, writes `angle` back into the JSON, and rebuilds.  If the
rebuilt rest pose is not the pose that was solved, autopose is lying: it reports
a solvable leg and the bake then draws something else.  This checks that
round trip directly, on a two link chain, with no creatures involved.
"""
from __future__ import annotations

import math
import sys

import numpy as np

from .creature import Creature
from .rig import Rig, chain_bone_lengths
from .shapes import ShapeLibrary

ROOT = __import__("pathlib").Path(__file__).resolve().parent.parent

SPEC = {
    "name": "probe",
    "size": [400, 300],
    "palette": {"body": "#557755", "shade": "#223318", "ink": "#0a0f08"},
    "parts": [
        {"id": "torso", "shape": "torso_lizard"},
        {"id": "up", "shape": "limb_femur", "parent": "torso", "at": 0.3,
         "angle": 90, "scale": 0.8, "follow": "rigid"},
        {"id": "lo", "shape": "limb_shin", "parent": "up", "at": 1.0,
         "angle": 20, "scale": 0.8, "follow": "rigid"},
        {"id": "ft", "shape": "foot_claw", "parent": "lo", "at": 1.0,
         "angle": -90, "scale": 0.7, "follow": "rigid"},
    ],
    "legs": [{"chain": ["up", "lo", "ft"], "bend": 1.0}],
}


def main() -> int:
    lib = ShapeLibrary([ROOT / "shapes"])
    spec = SPEC
    creature = Creature.from_spec(spec, lib)
    placement = creature.rest_placement()
    rig = Rig(creature, placement, None)
    chain = spec["legs"][0]["chain"]

    parent = rig.joints[chain[0]].parent
    c, s = math.cos(rig.joints[parent].rot), math.sin(rig.joints[parent].rot)
    hip = rig.joints[chain[0]].rest_offset
    hip_world = rig.joints[parent].pos + np.array([c * hip[0] - s * hip[1],
                                                   s * hip[0] + c * hip[1]])
    target = np.array([hip_world[0] + 18.0, hip_world[1] + 95.0])
    rig.apply_ik(chain, target, bend=1.0)
    want = {pid: rig.joints[pid].rot for pid in chain[:2]}
    want_foot = rig.joints[chain[-1]].pos.copy()
    print("solved  up/lo world rot:", {k: round(math.degrees(v), 2) for k, v in want.items()})
    print("solved  foot at", np.round(want_foot, 2).tolist())

    by_id = {p["id"]: p for p in spec["parts"]}
    for slot in (0, 1):
        pid = chain[slot]
        parent_id = rig.joints[pid].parent
        # the CHILD's `at` selects the point on the parent's spine - the same
        # point rest_placement() samples.  The parent's own `at` is a different
        # place and quietly rotates the leg.
        child = creature._by_id[pid]
        shape = creature.shape_of(creature._by_id[parent_id])
        bone = shape.spine_dir_at(child.at)
        bone_rad = math.atan2(float(bone[1]), float(bone[0]))
        # the parent's CURRENT rest rotation, not the one from before this pass:
        # writing link 0's angle changed it, and using the stale value leaves
        # link 1 pointing at the old place.
        parent_rest = rig.joints[parent_id].rot
        by_id[pid]["angle"] = round(
            math.degrees(rig.joints[pid].rot - parent_rest - bone_rad), 2)
    print("written angles:", {p: by_id[p]["angle"] for p in chain[:2]})

    again = Creature.from_spec(spec, lib)
    got = again.rest_placement()
    print("rebuilt up/lo world rot:",
          {k: round(math.degrees(got[k].rotation), 2) for k in chain[:2]})
    drift = max(abs(math.degrees(got[k].rotation - want[k])) for k in chain[:2])
    foot_drift = float(np.linalg.norm(got[chain[-1]].position - want_foot))
    print(f"rotation drift {drift:.3f} deg, foot drift {foot_drift:.3f} px")
    if drift < 0.5 and foot_drift < 1.0:
        print("ROUND TRIP OK")
        return 0
    print("ROUND TRIP BROKEN - written angles do not reproduce the solved pose")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
