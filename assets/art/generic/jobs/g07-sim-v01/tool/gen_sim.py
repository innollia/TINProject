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
from g07kit import (bezier, box, cyl, disc, dots, floor_ellipse_shadow, floor_shadow, form, frame, piece,  # noqa: E402
                    recipe, rod, rrect, variant, write)

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


# ------------------------------------------------------------------ B
def container():
    cx, base = 320, 786
    W, D, H = 440, 468, 273
    top_c = base - H - D / 2.0
    front_top = base - H
    ribs_roof = [piece("square", [0, 0], [W - 24, 5], repeat={"line": [[cx, top_c - D / 2 + 20], [cx, top_c + D / 2 - 20]],
                                                               "count": 17})]
    f = [
        floor_shadow(cx, base, W, D, opacity=0.35, blur=10),
        box("body", 1, cx, base, W, D, H, "rust_metal", corner=4),
        form("roof_ribs", 1.5, ribs_roof, "dial_mark", kind="flat", opacity=0.35),
        form("corner_posts", 1.6, [rrect([cx - W / 2 + 10, front_top + H / 2], [20, H], corner=2),
                                   rrect([cx + W / 2 - 10, front_top + H / 2], [20, H], corner=2)], "steel_dark"),
        form("rails", 1.6, [rrect([cx, front_top + 9], [W, 18], corner=2), rrect([cx, base - 9], [W, 18], corner=2)],
             "steel_dark"),
        variant(form("doors", 2, [rrect([cx - 100, front_top + H / 2], [196, H - 36], corner=2),
                                  rrect([cx + 100, front_top + H / 2], [196, H - 36], corner=2)], "rust_metal",
                     shade={"bump": 0.4}), "closed"),
        variant(form("door_ribs", 2.1, [piece("square", [0, 0], [5, H - 50],
                                              repeat={"line": [[cx - 186, front_top + H / 2], [cx + 186, front_top + H / 2]],
                                                      "count": 16})], "dial_mark", kind="flat", opacity=0.3,
                     clip_to="doors"), "closed"),
        variant(form("lock_bars", 2.2, [rrect([x, front_top + H / 2], [8, H - 30], corner=3)
                                        for x in (cx - 150, cx - 50, cx + 50, cx + 150)], "steel"), "closed"),
        variant(form("handles", 2.3, [rrect([x + 14, front_top + H / 2 + 20], [30, 8], corner=3)
                                      for x in (cx - 150, cx - 50, cx + 50, cx + 150)], "steel_dark"), "closed"),
        variant(form("tag_plate", 2.4, [rrect([cx + 100, front_top + 60], [70, 34], corner=3)], "enamel", kind="flat",
                     opacity=0.85), "closed"),
        variant(form("inside", 2, [rrect([cx, front_top + H / 2], [W - 44, H - 36], corner=2)], "void", kind="flat",
                     grad={"to": "well_inner", "y0": front_top, "y1": base}), "open"),
        variant(box("crate_a", 2.5, cx - 90, base - 20, 120, 60, 90, "wood"), "open"),
        variant(box("crate_b", 2.6, cx + 70, base - 24, 100, 60, 70, "cork"), "open"),
        variant(box("crate_c", 2.4, cx - 70, base - 110, 90, 60, 60, "wood"), "open"),
        variant(form("door_open_l", 3, [piece("square", [cx - W / 2 - 40, front_top + H / 2 + 12], [80, H - 36],
                                              slice={"border": 3, "corner": 2}, skew=[0, 18])], "rust_metal",
                     shade={"bump": 0.4}), "open"),
        variant(form("door_open_r", 3, [piece("square", [cx + W / 2 + 40, front_top + H / 2 + 12], [80, H - 36],
                                              slice={"border": 3, "corner": 2}, skew=[0, -18])], "rust_metal",
                     shade={"bump": 0.4}), "open"),
    ]
    return recipe("obj_container", [640, 820], f, pivot=[cx, base], seed=203, style="prop",
                  frames=[frame("closed", show=["closed"]), frame("open", show=["open"])], pivot_meaning=FLOOR,
                  note=NOTE + " Rusty 10 ft cargo container (2.4 x 3.0 x 2.6 m), doors facing the viewer. closed / open "
                              "(doors swung out, crates inside). Blank plate, no markings.")


def shard_pile():
    rng = random.Random(33)
    sizes = {"small": (60, 30, 26, 22), "medium": (104, 50, 46, 48), "large": (150, 72, 70, 90)}
    cx, base = 160, 236
    f = []
    for tag, (rx, ry, h, n) in sizes.items():
        mound = []
        for i in range(max(8, n // 2)):
            r, t = math.sqrt(rng.random()) * 0.8, rng.uniform(0, 2 * math.pi)
            u, v = r * math.cos(t), r * math.sin(t)
            lift = h * 0.85 * (1 - r * r)
            s = rng.uniform(0.28, 0.42) * rx
            mound.append((base - ry + v * ry * 0.7 - lift, piece(rng.choice(["rocks", "hexagon"]),
                                                                 [cx + u * rx * 0.8, base - ry + v * ry * 0.7 - lift],
                                                                 [s, s * 0.75], rot=rng.uniform(-30, 30))))
        mound = [p for _, p in sorted(mound, key=lambda t: t[0])]
        stone, glass, metal = [], [], []
        pts = []
        for i in range(n):
            r, t = math.sqrt(rng.random()), rng.uniform(0, 2 * math.pi)
            u, v = r * math.cos(t), r * math.sin(t)
            lift = h * (1 - r * r) ** 0.9
            pts.append((base - ry + v * ry * 0.85 - lift, cx + u * rx * 0.88))
        for y, x in sorted(pts):
            s = rng.uniform(14, 26)
            p = piece(rng.choice(["diamond_shape", "triangle", "hexagon", "rocks"]), [x, y], [s, s * rng.uniform(0.6, 1.0)],
                      rot=rng.uniform(0, 360))
            q = rng.random()
            (glass if q < 0.14 else metal if q < 0.24 else stone).append(p)
        f.append(variant(floor_ellipse_shadow(cx, base, rx, ry, name=f"shadow_{tag}"), tag))
        f.append(variant(form(f"mound_{tag}", 0.5, mound, "rubble", shade={"bump": 1.3}), tag))
        f.append(variant(form(f"stone_{tag}", 1, stone, "stone", shade={"bump": 1.2}), tag))
        f.append(variant(form(f"metal_{tag}", 1.1, metal, "bronze", shade={"bump": 1.2}), tag))
        f.append(variant(form(f"glass_{tag}", 1.2, glass, "crystal", emit=0.25,
                              glow={"radius": 3, "opacity": 0.35, "color": "glow_blue"}), tag))
    return recipe("obj_shard_pile", [320, 256], f, pivot=[cx, base], seed=204, style="prop",
                  frames=[frame(k, show=[k]) for k in sizes], pivot_meaning=FLOOR,
                  note=NOTE + " Growing shard pile (stone, brass and crystal fragments): small / medium / large.")


def stage_b():
    return [container(), shard_pile()]


STAGES["B"] = stage_b


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
