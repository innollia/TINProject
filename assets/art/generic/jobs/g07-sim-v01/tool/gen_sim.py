"""g07-sim-v01 recipes: simulation / logistics / incremental objects (60 deg top-down).

    py -3 -B gen_sim.py [A|B|C ...]      # writes ../recipes/obj_*.json

Same scale as g04 and g07-devices (180 / 156 / 105 px per metre).  Tile
pieces (192 cells) are seamless: nothing but the belt / rail crosses the cell
edge and the silhouette pass is switched off so no outline forms at the seam.
"""

from __future__ import annotations

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import (box, disc, floor_ellipse_shadow, form, frame, piece, recipe, rrect,  # noqa: E402
                    variant, write)

NOTE = "g07 future-kit sim object (60 deg top-down). at-icons collage, candidate."
FLOOR = "front-bottom centre on the floor"
SEAMLESS = {"silhouette": False}


# ------------------------------------------------------------------ conveyor tile
def conveyor():
    f = [
        # x-running belt: top face 20..145, front face 145..192
        variant(form("x_shadow", -10, [rrect([100, 150], [260, 96], corner=10)], kind="shadow", color="shadow_contact",
                     opacity=0.3, blur=6), "x"),
        variant(box("x_frame", 0, 96, 192, 240, 125, 47, "steel"), "x"),
        variant(form("x_belt", 1, [rrect([96, 82], [240, 100], corner=2)], "rubber", shade={"bump": 0.35}), "x"),
        variant(form("x_rails", 2, [rrect([96, 27], [240, 10], corner=2), rrect([96, 138], [240, 10], corner=2)], "steel",
                     shade={"bump": 0.9}), "x"),
        variant(form("x_roller_caps", 2.5, [piece("circle", [0, 0], [13, 13], repeat={"line": [[-16, 166], [208, 166]],
                                                                                      "count": 8})],
                     "steel_dark", line={"width": 0.5, "heavy": 0.4}), "x"),
        variant(form("x_hazard", 2.4, [piece("square", [0, 0], [10, 30], rot=35,
                                             repeat={"line": [[-24, 182], [216, 182]], "count": 16})],
                     "paint_ochre", kind="flat", opacity=0.55, clip_to="x_frame"), "x"),
        # y-running belt: full-height strip
        variant(form("y_shadow", -10, [rrect([110, 96], [150, 240], corner=10)], kind="shadow", color="shadow_contact",
                     opacity=0.3, blur=6), "y"),
        variant(form("y_frame", 0, [rrect([96, 96], [164, 240], corner=2)], "steel", shade={"bump": 0.5}), "y"),
        variant(form("y_belt", 1, [rrect([96, 96], [130, 240], corner=2)], "rubber", shade={"bump": 0.35}), "y"),
        variant(form("y_rails", 2, [rrect([22, 96], [10, 240], corner=2), rrect([170, 96], [10, 240], corner=2)], "steel",
                     shade={"bump": 0.9}), "y"),
    ]
    for k, off in enumerate((0.0, 32 / 3.0, 64 / 3.0)):
        f.append(variant(form(f"x_cleats_{k}", 1.5, [piece("square", [0, 0], [6, 94], slice={"border": 3, "corner": 2},
                                                           repeat={"line": [[-32 + off, 82], [224 + off, 82]],
                                                                   "count": 9})],
                              "steel_dark", shade={"bump": 0.8}, clip_to="x_belt"), f"x{k}"))
        f.append(variant(form(f"y_cleats_{k}", 1.5, [piece("square", [0, 0], [122, 6], slice={"border": 3, "corner": 2},
                                                           repeat={"line": [[96, -32 + off], [96, 224 + off]],
                                                                   "count": 9})],
                              "steel_dark", shade={"bump": 0.8}, clip_to="y_belt"), f"y{k}"))
    frames = [frame(f"x_{k}", show=["x", f"x{k}"]) for k in range(3)] + [frame(f"y_{k}", show=["y", f"y{k}"])
                                                                           for k in range(3)]
    return recipe("obj_conveyor", [192, 192], f, pivot=[96, 192], seed=201, style="prop", style_override=SEAMLESS,
                  frames=frames, pivot_meaning="cell bottom centre (grid cell of 192 x 192)",
                  note=NOTE + " Seamless conveyor cell: x_0..2 runs left-right (front face visible), y_0..2 runs "
                              "up-down; frames 0-1-2 move the cleats 1/3 of their 32 px spacing (play 0-1-2 for "
                              "+x / +y travel).")


# ------------------------------------------------------------------ ore rock
def jag_line(x, y, angle, n, seg, width, seed, wiggle=38, taper=0.6):
    """A crack / vein: short rounded bars joined end to end along a jittered direction."""
    rng = random.Random(seed)
    pcs = []
    for i in range(n):
        a = angle + rng.uniform(-wiggle, wiggle)
        dx, dy = seg * math.cos(math.radians(a)), seg * math.sin(math.radians(a))
        w = max(1.2, width * (1.0 - taper * i / max(1, n - 1)))
        pcs.append(rrect([x + dx / 2, y + dy / 2], [w, seg + w], corner=w / 2, rot=a - 90))
        x, y = x + dx, y + dy
    return pcs


def ore_rock():
    cx, base = 128, 222
    rock = [piece("rocks", [128, 150], [206, 150]), piece("hexagon", [92, 170], [96, 84], rot=14),
            piece("hexagon", [166, 176], [92, 72], rot=-8), piece("rocks", [140, 124], [120, 90], flip="x")]
    rng = random.Random(5)
    rubble = [piece("rocks", [120, 196], [150, 70]), piece("hexagon", [84, 204], [62, 40], rot=24),
              piece("hexagon", [170, 202], [58, 38], rot=-18)]
    for _ in range(8):
        x, y = rng.uniform(56, 204), rng.uniform(186, 222)
        rubble.append(piece(rng.choice(["rocks", "hexagon", "diamond_shape"]), [x, y], [rng.uniform(22, 40),
                                                                                         rng.uniform(16, 28)],
                            rot=rng.uniform(-40, 40)))
    f = [
        floor_ellipse_shadow(cx, base, 112, 40),
        variant(form("body", 1, rock, "stone_dark", shade={"bump": 1.3}), "whole"),
        variant(form("veins", 2, jag_line(78, 136, 20, 7, 14, 6, 11) + jag_line(150, 112, 70, 6, 13, 5, 12),
                     "paint_ochre", kind="flat", opacity=0.7, clip_to="body"), "whole"),
        variant(form("shards", 2.5, [piece("gem", [120, 128], [22, 20], rot=-10), piece("gem", [168, 168], [18, 16], rot=20),
                                     piece("gem", [86, 176], [16, 14])], "crystal", emit=0.3,
                     glow={"radius": 4, "opacity": 0.4, "color": "glow_blue"}), "whole"),
        variant(form("cracks_1", 3, jag_line(146, 84, 100, 7, 12, 4.5, 21), "dial_mark", kind="flat", opacity=0.9,
                     clip_to="body"), "crack1", "crack2"),
        variant(form("cracks_2", 3, jag_line(146, 150, 160, 6, 13, 4, 22) + jag_line(150, 152, 20, 5, 13, 4, 23),
                     "dial_mark", kind="flat", opacity=0.9, clip_to="body"), "crack2"),
        variant(form("chips", 1.5, [piece("hexagon", [70, 212], [18, 14], rot=20), piece("rocks", [196, 208], [22, 16]),
                                    piece("diamond_shape", [150, 216], [12, 10])], "stone_dark"), "crack2"),
        variant(form("rubble", 1, rubble, "stone_dark", shade={"bump": 1.2}), "broken"),
        variant(form("loose_ore", 2, [piece("gem", [110, 180], [30, 28], rot=-15), piece("gem", [150, 188], [26, 24], rot=18),
                                      piece("gem", [132, 168], [20, 18])], "crystal", emit=0.45,
                     glow={"radius": 6, "opacity": 0.5, "color": "glow_blue"}), "broken"),
    ]
    frames = [frame("whole", show=["whole"]), frame("crack1", show=["whole", "crack1"]),
              frame("crack2", show=["whole", "crack2"]), frame("broken", show=["broken"])]
    return recipe("obj_ore_rock", [256, 256], f, pivot=[cx, base], seed=202, style="prop", frames=frames,
                  pivot_meaning=FLOOR,
                  note=NOTE + " Mining rock with ore veins and crystal shards: whole, cracked 1, cracked 2, broken "
                              "(rubble + loose ore).")


def stage_a():
    return [conveyor(), ore_rock()]


STAGES = {"A": stage_a}


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
