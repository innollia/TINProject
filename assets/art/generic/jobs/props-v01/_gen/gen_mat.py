"""Generate recipes/it_*.json for the general material block of the job list.

Form grammar per group (one rule set inside each group):
  * rod      it_stick, it_flint         one long prism, lit on the upper left
  * cluster  it_wheat, it_snowball, it_clay_lump, it_honeycomb
  * shell    it_egg, it_armadillo_scute
  * vessel   it_bowl, it_brick, it_paper
  * wrapped  it_firework_charge
All objects share canvas 128 / pivot 64,64 / style prop and one light direction.
Cluster items all use the same three-piece mass (rocks + metaballs + paw_print)
so lumps read the same way across the whole sheet.

    py -3 -B _gen/gen_mat.py
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
REC = JOB / "recipes"

COMMON = {
    "palette": "palette_props.json",
    "style": "prop",
    "canvas": [128, 128],
    "pivot": [64, 64],
    "pivot_meaning": "canvas centre; inventory icon, no ground contact",
}

ROCKS_CROP = [1, 0.5, 13.5, 10.5]
LEAF_CROP = [2.2, 1.2, 14.2, 14.6]


def piece(icon, at, size, crop=None, **extra):
    p = {"icon": icon}
    if crop:
        p["crop"] = [round(v, 2) for v in crop]
    p["at"] = [round(at[0], 2), round(at[1], 2)]
    p["size"] = [round(size[0], 2), round(size[1], 2)]
    p.update(extra)
    return p


def grad(y0, y1, to, amount=0.55):
    return {"to": to, "y0": y0, "y1": y1, "amount": amount}


def out(asset, note, seed, forms):
    return {**COMMON, "asset": asset, "status": "candidate", "note": note, "seed": seed,
            "forms": forms}


def lump_forms(mat, note_at, seed, note, lit_at, lit_size, seat_at, seat_size, op=0.9):
    """The shared cluster mass: two big lumps, a toe, a lit cheek, a dark seat."""
    return out(note[0], note[1], seed, [
        {"name": "body", "material": mat, "grad": grad(76, 116, "well_void", 0.42),
         "pieces": [piece("rocks", [64, 60], [98, 72], crop=ROCKS_CROP),
                    piece("metaballs", [34, 90], [46, 40], crop=[0, 7.5, 6.5, 15.5]),
                    piece("paw_print", [92, 86], [34, 32], crop=[8, 7.5, 15, 14.5])]},
        {"name": "lit", "kind": "flat", "material": mat, "clip_to": "body", "opacity": op,
         "grad": grad(28, 62, "floor_light", 0.5),
         "pieces": [piece("diamond_shape", lit_at, lit_size, crop=[3, 3, 10, 8])]},
        {"name": "seat", "kind": "flat", "material": mat, "clip_to": "body", "opacity": 0.7,
         "grad": grad(70, 106, "well_void", 0.65),
         "pieces": [piece("gem", seat_at, seat_size, crop=[2, 6, 9, 13])]},
    ])


recipes = {}

# --- it_stick ------------------------------------------------------------------
SHAFT_CROP = [4.5, 6.5, 12.5, 9.7]
recipes["it_stick"] = out(
    "it_stick", "it_stick: one trimmed branch lying horizontally, a short side twig "
                "at the upper right, two cut facets, warm dark wood, no text.", 310, [
        {"name": "body", "material": "stick_wood", "grad": grad(48, 84, "well_void", 0.35),
         "pieces": [piece("bone_horizontal", [64, 64], [104, 34], crop=SHAFT_CROP),
                    piece("bone_horizontal", [90, 40], [32, 12], crop=[5, 6.5, 12, 9.7], rot=40)]},
        {"name": "cut_a", "kind": "flat", "material": "stick_wood", "clip_to": "body",
         "opacity": 0.8, "grad": grad(48, 68, "floor_light", 0.5),
         "pieces": [piece("diamond_shape", [40, 62], [34, 14], crop=[3, 4, 10, 8])]},
        {"name": "cut_b", "kind": "flat", "material": "stick_wood", "clip_to": "body",
         "opacity": 0.75, "grad": grad(48, 68, "floor_light", 0.45),
         "pieces": [piece("diamond_shape", [94, 64], [26, 12], crop=[4, 4, 9, 8])]},
        {"name": "seat", "kind": "flat", "material": "stick_wood", "clip_to": "body",
         "opacity": 0.55, "grad": grad(68, 86, "well_void", 0.5),
         "pieces": [piece("gem", [58, 80], [44, 14], crop=[2, 6, 9, 13])]},
    ])

# --- it_flint ------------------------------------------------------------------
recipes["it_flint"] = out(
    "it_flint", "it_flint: one sharp flint shard with a broken spur at the top right "
                "and a dull rind along the lower edge, no text.", 311, [
        {"name": "body", "material": "flint", "grad": grad(74, 112, "well_void", 0.4),
         "pieces": [piece("cutlass", [58, 66], [98, 86], crop=[5.2, 1.4, 14.6, 9.0], rot=-14),
                    piece("screw", [98, 38], [34, 44], crop=[4, 6, 12, 15], rot=26)]},
        {"name": "lit", "kind": "flat", "material": "flint", "clip_to": "body", "opacity": 0.9,
         "grad": grad(30, 66, "floor_light", 0.6),
         "pieces": [piece("diamond_shape", [50, 50], [44, 28], crop=[3, 3, 10, 8], rot=-14)]},
        {"name": "rind", "kind": "flat", "material": "flint", "clip_to": "body", "opacity": 0.85,
         "grad": grad(66, 108, "well_void", 0.7),
         "pieces": [piece("gem", [76, 92], [46, 32], crop=[2, 6, 9, 13], rot=-14)]},
    ])

# --- it_wheat ------------------------------------------------------------------
def ear(cx, top, n, w, h, rot):
    return {"name": f"ear_{cx}", "material": "wheat_straw",
            "pieces": [piece("leaf", [cx, top + i * (h * 0.72)], [w, h], crop=LEAF_CROP, rot=rot)
                      for i in range(n)]}


recipes["it_wheat"] = out(
    "it_wheat", "it_wheat: three ripe ears, the centre one tallest, the side ears "
                "lower and splayed outwards, one stalk, no text.", 312, [
        {"name": "stalk", "material": "wheat_straw", "grad": grad(70, 112, "well_void", 0.3),
         "pieces": [piece("bone_horizontal", [64, 88], [64, 24], crop=SHAFT_CROP, rot=90),
                    piece("droplet", [64, 76], [20, 18], crop=[4, 3, 12, 12])]},
        ear(64, 26, 3, 26, 32, -3),
        ear(30, 52, 2, 22, 27, 26),
        ear(98, 52, 2, 22, 27, -26),
        {"name": "lit", "kind": "flat", "material": "wheat_straw", "clip_to": "ear_64",
         "opacity": 0.85, "grad": grad(10, 50, "floor_light", 0.45),
         "pieces": [piece("leaf", [58, 30], [11, 26], crop=[2.6, 1.6, 6.0, 11.0], rot=-3)]},
    ])

# --- it_snowball ---------------------------------------------------------------
recipes["it_snowball"] = lump_forms(
    "snow", None, 313, ("it_snowball", "it_snowball: one packed snowball, three solid "
                         "lumps and a lit crown, no text."),
    [50, 44], [44, 30], [84, 92], [46, 32])

# --- it_clay_lump --------------------------------------------------------------
recipes["it_clay_lump"] = lump_forms(
    "clay", None, 316, ("it_clay_lump", "it_clay_lump: one soft grey clay lump, three "
                         "solid bulges and a lit left cheek, no text."),
    [50, 46], [44, 28], [84, 94], [46, 30])

# --- it_egg --------------------------------------------------------------------
EGG_CROP = [3.0, 1.0, 13.0, 14.8]
recipes["it_egg"] = out(
    "it_egg", "it_egg: one egg standing on its wide end, a thin rim pass for the "
              "shell edge, faint speckles and a lit left flank, no text.", 314, [
        {"name": "rim", "material": "egg_shell",
         "pieces": [piece("droplet", [64, 64], [94, 122], crop=EGG_CROP)]},
        {"name": "shell", "material": "egg_shell", "grad": grad(30, 104, "worn", 0.34),
         "pieces": [piece("droplet", [64, 64], [86, 112], crop=EGG_CROP)]},
        {"name": "lit", "kind": "flat", "material": "egg_shell", "clip_to": "shell",
         "opacity": 0.5, "grad": grad(20, 60, "floor_light", 0.55),
         "pieces": [piece("circle", [48, 50], [32, 32], crop=[1.4, 1.4, 14.6, 14.6])]},
        {"name": "foot", "kind": "flat", "material": "egg_shell", "clip_to": "shell",
         "opacity": 0.5, "grad": grad(86, 112, "worn", 0.6),
         "pieces": [piece("circle", [64, 104], [58, 20], crop=[1.4, 9.4, 14.6, 14.6])]},
    ])

# --- it_honeycomb --------------------------------------------------------------
HEX = [1.6, 2.4, 14.4, 13.6]
HEX_IN = [4.2, 5.2, 11.8, 10.8]
recipes["it_honeycomb"] = out(
    "it_honeycomb", "it_honeycomb: a broken comb, three hexagonal chunks in the same "
                    "tilt, one open cell per chunk, honey running from the middle, no text.", 315, [
        {"name": "wax", "material": "wax", "grad": grad(38, 110, "well_void", 0.4),
         "pieces": [piece("hexagon", [64, 48], [64, 52], crop=HEX, rot=-4),
                    piece("hexagon", [28, 80], [46, 38], crop=HEX, rot=-4),
                    piece("hexagon", [100, 76], [44, 36], crop=HEX, rot=-4)]},
        {"name": "honey", "material": "honey", "clip_to": "wax", "opacity": 0.9,
         "pieces": [piece("droplet", [44, 72], [22, 28], crop=[4, 3, 12, 14.5])]},
        {"name": "cells", "kind": "flat", "material": "clay_dark", "clip_to": "wax", "opacity": 0.8,
         "pieces": [piece("hexagon", [64, 46], [30, 25], crop=HEX_IN, rot=-4),
                    piece("hexagon", [28, 79], [21, 17], crop=HEX_IN, rot=-4),
                    piece("hexagon", [100, 75], [20, 16], crop=HEX_IN, rot=-4)]},
        {"name": "lit", "kind": "flat", "material": "wax", "clip_to": "wax", "opacity": 0.8,
         "grad": grad(18, 50, "floor_light", 0.45),
         "pieces": [piece("diamond_shape", [46, 32], [40, 20], crop=[3, 3, 10, 8], rot=-4)]},
    ])

# --- it_bowl -------------------------------------------------------------------
BOWL_OUT = [1.2, 7.4, 14.8, 15.2]
BOWL_IN = [3.0, 7.8, 13.0, 15.0]
recipes["it_bowl"] = out(
    "it_bowl", "it_bowl: one empty clay bowl from slightly above, lit outer wall, "
               "dark inner basin, no text.", 317, [
        {"name": "rim", "material": "clay",
         "pieces": [piece("circle", [64, 76], [106, 60], crop=BOWL_OUT)]},
        {"name": "body", "kind": "block", "material": "clay", "extrude": 3, "ao": False,
         "grad": grad(58, 108, "well_void", 0.3),
         "pieces": [piece("circle", [64, 78], [100, 56], crop=BOWL_OUT)]},
        {"name": "basin", "kind": "flat", "material": "clay_dark", "clip_to": "body",
         "opacity": 0.9, "grad": grad(50, 74, "worn", 0.5),
         "pieces": [piece("circle", [64, 72], [86, 40], crop=BOWL_IN)]},
        {"name": "lit", "kind": "flat", "material": "clay", "clip_to": "body", "opacity": 0.7,
         "grad": grad(56, 92, "floor_light", 0.4),
         "pieces": [piece("diamond_shape", [42, 84], [28, 28], crop=[3.4, 3.4, 8.0, 8.0])]},
    ])

# --- it_brick ------------------------------------------------------------------
BRICK_CROP = [6.0, 5.8, 8.8, 9.0]
recipes["it_brick"] = out(
    "it_brick", "it_brick: one fired brick lying flat, long face lit, front face "
                "dark, one pitted patch, no text.", 318, [
        {"name": "body", "kind": "block", "material": "brick_clay", "extrude": 7, "ao": False,
         "grad": grad(40, 70, "floor_light", 0.4),
         "pieces": [piece("brick_wall", [64, 56], [104, 84], crop=BRICK_CROP, squash=0.5)]},
        {"name": "lit", "kind": "flat", "material": "brick_clay", "clip_to": "body",
         "opacity": 0.65, "grad": grad(32, 60, "floor_light", 0.4),
         "pieces": [piece("diamond_shape", [56, 46], [50, 18], crop=[3, 3, 10, 8])]},
        {"name": "pitted", "kind": "flat", "material": "brick_clay", "clip_to": "body",
         "opacity": 0.6, "grad": grad(48, 74, "well_void", 0.55),
         "pieces": [piece("sponge", [92, 58], [30, 18], crop=[6, 1, 12, 7])]},
    ])

# --- it_paper ------------------------------------------------------------------
FILE_CROP = [2.6, 1.0, 12.8, 15.0]
recipes["it_paper"] = out(
    "it_paper", "it_paper: one blank sheet lying flat with the top margin rolled over, "
                "a shadow band under the roll and a soft crease near the foot, no text.", 319, [
        {"name": "sheet", "material": "paper", "grad": grad(40, 116, "foxing", 0.4),
         "pieces": [piece("file", [64, 68], [86, 104], crop=FILE_CROP, rot=-7)]},
        {"name": "roll", "material": "paper", "grad": grad(16, 52, "floor_light", 0.35),
         "pieces": [piece("sticker", [64, 26], [46, 30], crop=[3.0, 1.2, 15.0, 7.4], rot=-7)]},
        {"name": "roll_shadow", "kind": "flat", "material": "paper_mark", "clip_to": "sheet",
         "opacity": 0.7, "grad": grad(34, 60, "foxing", 0.6),
         "pieces": [piece("sticker", [64, 40], [52, 16], crop=[3.0, 1.2, 15.0, 7.4], rot=-7)]},
        {"name": "crease", "kind": "flat", "material": "paper_mark", "clip_to": "sheet",
         "opacity": 0.45, "grad": grad(60, 88, "foxing", 0.5),
         "pieces": [piece("diamond_shape", [60, 90], [56, 18], crop=[3, 4, 10, 7.6], rot=-7)]},
    ])

# --- it_firework_charge --------------------------------------------------------
MSL_A_CROP = [1.4, 4.6, 14.6, 15.0]
recipes["it_firework_charge"] = out(
    "it_firework_charge", "it_firework_charge: one small firework, a paper tube lying "
                          "diagonal, a dark cone at the nose, a knotted tail at the "
                          "lower left, no text.", 320, [
        {"name": "tube", "kind": "block", "material": "firework_paper", "extrude": 4, "ao": False,
         "grad": grad(48, 88, "well_void", 0.35),
         "pieces": [piece("droplet", [56, 62], [84, 22], crop=[1.4, 4.6, 14.6, 15.0], rot=18),
                    piece("droplet", [56, 62], [76, 14], crop=[3, 5, 13, 12.6], rot=18)]},
        {"name": "nose", "material": "iron_bar",
         "pieces": [piece("droplet", [94, 52], [26, 30], crop=[4, 1.4, 12, 9.6], rot=18)]},
        {"name": "tail", "material": "firework_paper",
         "pieces": [piece("droplet", [18, 78], [24, 18], crop=[4, 2, 12, 12], rot=-40),
                    piece("bone_horizontal", [20, 90], [28, 10], crop=SHAFT_CROP, rot=-16)]},
        {"name": "lit", "kind": "flat", "material": "firework_paper", "clip_to": "tube",
         "opacity": 0.8, "grad": grad(40, 70, "floor_light", 0.45),
         "pieces": [piece("diamond_shape", [50, 52], [40, 14], crop=[3, 3, 10, 8], rot=18)]},
    ])

# --- it_armadillo_scute --------------------------------------------------------
SCUTE_BACK = [4.0, 5.4, 12.0, 14.9]
SCUTE_CROP = [4.6, 6.0, 11.4, 14.5]
recipes["it_armadillo_scute"] = out(
    "it_armadillo_scute", "it_armadillo_scute: one armadillo scute, a flat horn scale "
                          "tapering to a blunt point, a lit top surface and a dark "
                          "growth ridge along the lower edge, no text.", 321, [
        {"name": "back", "material": "scute",
         "pieces": [piece("droplet", [64, 62], [108, 80], crop=SCUTE_BACK)]},
        {"name": "scale", "material": "scute", "grad": grad(30, 100, "well_void", 0.38),
         "pieces": [piece("droplet", [64, 62], [98, 72], crop=SCUTE_CROP)]},
        {"name": "sheen", "kind": "flat", "material": "scute", "clip_to": "scale",
         "opacity": 0.4, "grad": grad(34, 60, "floor_light", 0.5),
         "pieces": [piece("circle", [46, 50], [36, 36], crop=[1.4, 1.4, 14.6, 14.6])]},
    ])


def main() -> int:
    for asset, data in recipes.items():
        path = REC / f"{asset}.json"
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(path.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

