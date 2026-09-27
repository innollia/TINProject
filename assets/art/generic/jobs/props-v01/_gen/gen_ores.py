"""Generate recipes/it_*.json for the ore / gem block of the job list.

Shared form grammar (one classification, one rule set):
  * cluster  (coal, redstone, nether_quartz)  angular rock mass + pointed shards
  * ingot    (iron, copper, gold)             one `layers` plate extruded down
  * stone    (lapis, netherite)               angular chunk + flat top face
  * cut gem  (emerald, diamond)               solid back plate + faceted front
  * shard    (amethyst)                       three tall prisms of one material
Light comes from the palette (top-left) in every recipe; no form carries a
grounding shadow.

    py -3 -B _gen/gen_ores.py
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


def sub(icon, crop, at, size, subcrop, dx=0.0, dy=0.0, **extra):
    """Place a sub-rectangle of `icon` inside an already placed piece."""
    cx0, cy0, cx1, cy1 = crop
    sx0, sy0, sx1, sy1 = subcrop
    px, py = size[0] / (cx1 - cx0), size[1] / (cy1 - cy0)
    at2 = [at[0] - size[0] / 2 + (sx0 + (sx1 - sx0) / 2 - cx0) * px + dx,
           at[1] - size[1] / 2 + (sy0 + (sy1 - sy0) / 2 - cy0) * py + dy]
    piece = {"icon": icon, "crop": [round(v, 2) for v in subcrop],
             "at": [round(at2[0], 2), round(at2[1], 2)],
             "size": [round((sx1 - sx0) * px, 2), round((sy1 - sy0) * py, 2)]}
    piece.update(extra)
    return piece


def piece(icon, at, size, crop=None, **extra):
    p = {"icon": icon}
    if crop:
        p["crop"] = crop
    p["at"] = [round(at[0], 2), round(at[1], 2)]
    p["size"] = [round(size[0], 2), round(size[1], 2)]
    p.update(extra)
    return p


LIGHT = {"to": "floor_light", "amount": 0.55}
DARK = {"to": "well_void", "amount": 0.6}


def grad(y0, y1, to, amount=0.55):
    return {"to": to, "y0": y0, "y1": y1, "amount": amount}


# --------------------------------------------------------------------------- cluster
def cluster(asset, note, seed, mat, base_size, base_at, shards, facets):
    return {
        **COMMON, "asset": asset, "status": "candidate", "note": note, "seed": seed,
        "forms": [
            {"name": "base", "kind": "block", "material": mat, "extrude": 4, "ao": False,
             "grad": grad(70, 118, "well_void", 0.5),
             "pieces": [piece("rocks", base_at, base_size, crop=[1, 0.5, 13.5, 10.5])]},
            *shards,
            *facets,
        ],
    }


# --------------------------------------------------------------------------- ingot
BAR_CROP = [1, 1, 15, 15]
BAR_AT, BAR_SIZE = [64, 54], [108, 56]


def ingot(asset, note, seed, mat, patina=False):
    forms = [
        {"name": "body", "kind": "block", "material": mat, "extrude": 8, "ao": False,
         "pieces": [piece("diamond_shape", BAR_AT, BAR_SIZE, crop=BAR_CROP)]},
        {"name": "sheen", "kind": "flat", "material": mat, "clip_to": "body", "opacity": 0.85,
         "grad": grad(30, 56, "floor_light", 0.55),
         "pieces": [sub("diamond_shape", BAR_CROP, BAR_AT, BAR_SIZE, [3.0, 2.4, 13.0, 7.2])]},
        {"name": "chamfer", "kind": "flat", "material": mat, "clip_to": "body", "opacity": 0.8,
         "grad": grad(58, 84, "well_void", 0.65),
         "pieces": [sub("diamond_shape", BAR_CROP, BAR_AT, BAR_SIZE, [2.6, 8.0, 13.4, 15.0])]},
    ]
    if patina:
        forms.append({"name": "verdigris", "kind": "flat", "material": "patina",
                      "clip_to": "body", "opacity": 0.6,
                      "pieces": [piece("droplet", [46, 62], [30, 22], crop=[4, 2, 12, 12])]})
    return {**COMMON, "asset": asset, "status": "candidate", "note": note, "seed": seed,
            "forms": forms}


# --------------------------------------------------------------------------- cut gem
def cut_gem(asset, note, seed, mat, at, size):
    crop = [1, 1, 15, 15]
    return {**COMMON, "asset": asset, "status": "candidate", "note": note, "seed": seed,
            "forms": [
                {"name": "body", "kind": "flat", "material": mat,
                 "pieces": [piece("diamond_shape", at, size, crop=crop)]},
                {"name": "facets", "material": mat, "clip_to": "body",
                 "shade": {"bump": 0.6, "threshold": 0.34, "highlight_amount": 0.7},
                 "pieces": [piece("gem", at, size, crop=crop)]},
                {"name": "table", "kind": "flat", "material": mat, "clip_to": "body", "opacity": 0.6,
                 "grad": grad(at[1] - size[1] * 0.3, at[1] + size[1] * 0.1, "floor_light", 0.7),
                 "pieces": [sub("gem", crop, at, size, [3.4, 3.0, 9.4, 6.4])]},
                {"name": "seat", "kind": "flat", "material": mat, "clip_to": "body", "opacity": 0.7,
                 "grad": grad(at[1] + size[1] * 0.1, at[1] + size[1] * 0.5, "well_void", 0.7),
                 "pieces": [sub("gem", crop, at, size, [3.0, 8.0, 13.0, 14.2])]},
            ]}


# --------------------------------------------------------------------------- recipes
ROCKS_CROP = [1, 0.5, 13.5, 10.5]
DROP_CROP = [4, 2, 12, 14.5]

recipes = {}

# --- it_coal -------------------------------------------------------------------
recipes["it_coal"] = {
    **COMMON, "asset": "it_coal", "status": "candidate", "seed": 201,
    "note": "it_coal: dull black lumpy coal chunk, two big lumps and a chipped toe, "
            "one lit facet on the top left, no text.",
    "forms": [
        {"name": "body", "material": "coal", "grad": grad(78, 116, "well_void", 0.45),
         "pieces": [piece("rocks", [66, 60], [100, 72], crop=ROCKS_CROP),
                    piece("metaballs", [32, 88], [48, 40], crop=[0, 7.5, 7, 15.5]),
                    piece("paw_print", [96, 84], [34, 32], crop=[8, 7.5, 15, 14.5])]},
        {"name": "lit", "kind": "flat", "material": "coal", "clip_to": "body", "opacity": 0.95,
         "grad": grad(28, 62, "floor_light", 0.75),
         "pieces": [piece("diamond_shape", [58, 44], [48, 30], crop=[3, 3, 10, 8])]},
        {"name": "fracture", "kind": "flat", "material": "coal", "clip_to": "body", "opacity": 0.75,
         "grad": grad(66, 108, "well_void", 0.7),
         "pieces": [piece("gem", [92, 86], [40, 34], crop=[2, 6, 8, 13])]},
    ],
}

# --- ingots --------------------------------------------------------------------
recipes["it_iron_ingot"] = ingot(
    "it_iron_ingot", "it_iron_ingot: one cold grey iron ingot seen from above, "
                     "trapezoid plate with a lit top band and a dark chamfer below.", 210, "iron_bar")
recipes["it_copper_ingot"] = ingot(
    "it_copper_ingot", "it_copper_ingot: same plate as the iron ingot, dull copper "
                       "with two verdigris blotches. Shape identical to it_iron_ingot.", 211,
    "copper_bar", patina=True)
recipes["it_gold_ingot"] = ingot(
    "it_gold_ingot", "it_gold_ingot: same plate again, worn dull gold, "
                     "dark chamfer. Shape identical to it_iron_ingot.", 212, "gold_bar")

# --- it_redstone ---------------------------------------------------------------
recipes["it_redstone"] = cluster(
    "it_redstone", "it_redstone: three blunt red crystals on a dark red rock base, "
                   "all points leaning the same way (10 deg), brightest crystal lit.", 220,
    "redstone", [96, 52], [64, 76],
    [{"name": "shard_a", "material": "redstone",
      "pieces": [piece("droplet", [42, 48], [36, 60], crop=[4, 2, 12, 14.5], rot=-8)]},
     {"name": "shard_b", "material": "redstone",
      "pieces": [piece("droplet", [80, 40], [34, 70], crop=[4, 2, 12, 14.5], rot=-8)]},
     {"name": "shard_c", "material": "redstone",
      "pieces": [piece("droplet", [62, 62], [28, 48], crop=[5, 4, 12, 14.5], rot=-8)]}],
    [{"name": "lit", "kind": "flat", "material": "redstone", "clip_to": "shard_b", "opacity": 0.7,
      "grad": grad(16, 48, "floor_light", 0.5),
      "pieces": [sub("droplet", [4, 2, 12, 14.5], [80, 40], [34, 70], [5.4, 2.4, 8.4, 9.0])]},
     {"name": "deep", "kind": "flat", "material": "redstone", "clip_to": "shard_a", "opacity": 0.7,
      "grad": grad(40, 74, "well_void", 0.65),
      "pieces": [sub("droplet", [4, 2, 12, 14.5], [42, 48], [36, 60], [7.6, 8.0, 12.0, 14.5])]}])

# --- cut gems ------------------------------------------------------------------
recipes["it_emerald"] = cut_gem(
    "it_emerald", "it_emerald: cut emerald, one flat back plate and the same plate "
                  "carrying the facet splits on top, dark green.", 230, "emerald",
    [64, 66], [94, 82])
recipes["it_diamond"] = cut_gem(
    "it_diamond", "it_diamond: cut diamond, identical facet split to it_emerald, "
                  "pale blue grey and brighter.", 231, "diamond", [64, 66], [94, 82])

# --- it_lapis ------------------------------------------------------------------
recipes["it_lapis"] = {
    **COMMON, "asset": "it_lapis", "status": "candidate", "seed": 240,
    "note": "it_lapis: angular lapis chunk, one flat cut top face over a broken mass, "
            "dull blue, no text.",
    "forms": [
        {"name": "body", "material": "lapis", "grad": grad(76, 116, "well_void", 0.45),
         "pieces": [piece("rocks", [64, 70], [94, 72], crop=ROCKS_CROP),
                    piece("diamond_shape", [70, 56], [72, 34], crop=[2, 2, 14, 8]),
                    piece("paw_print", [98, 96], [34, 30], crop=[8, 7.5, 15, 14.5])]},
        {"name": "face", "kind": "flat", "material": "lapis", "clip_to": "body", "opacity": 0.8,
         "grad": grad(38, 66, "floor_light", 0.55),
         "pieces": [piece("diamond_shape", [64, 48], [50, 22], crop=[3, 3, 11, 8])]},
        {"name": "chip", "kind": "flat", "material": "lapis", "clip_to": "body", "opacity": 0.7,
         "grad": grad(60, 100, "well_void", 0.7),
         "pieces": [piece("gem", [44, 92], [38, 30], crop=[2, 6, 8, 13])]},
    ],
}

# --- it_netherite_scrap --------------------------------------------------------
recipes["it_netherite_scrap"] = {
    **COMMON, "asset": "it_netherite_scrap", "status": "candidate", "seed": 250,
    "note": "it_netherite_scrap: broken dark metal plate, one blunt lit facet, "
            "near black brown, no text.",
    "forms": [
        {"name": "body", "material": "netherite", "grad": grad(74, 114, "well_void", 0.4),
         "pieces": [piece("sword", [58, 58], [100, 84], crop=[3.5, 1.5, 11.5, 11], rot=-16),
                    piece("pen_nib", [76, 92], [72, 50], crop=[2, 2, 14, 12], rot=8),
                    piece("screw", [98, 38], [34, 46], crop=[4, 6, 12, 15], rot=24)]},
        {"name": "lit", "kind": "flat", "material": "netherite", "clip_to": "body", "opacity": 0.8,
         "grad": grad(28, 62, "floor_light", 0.45),
         "pieces": [piece("diamond_shape", [52, 44], [44, 28], crop=[3, 3, 10, 8])]},
        {"name": "notch", "kind": "flat", "material": "netherite", "clip_to": "body", "opacity": 0.7,
         "grad": grad(66, 104, "well_void", 0.7),
         "pieces": [piece("gem", [70, 92], [46, 32], crop=[2, 6, 9, 13])]},
    ],
}

# --- it_nether_quartz ----------------------------------------------------------
recipes["it_nether_quartz"] = cluster(
    "it_nether_quartz", "it_nether_quartz: four blunt milky crystals on a pale rock "
                        "base, all leaning 8 deg, pale grey lilac.", 260,
    "nether_quartz", [86, 42], [64, 86],
    [{"name": "shard_a", "material": "nether_quartz",
      "pieces": [piece("droplet", [38, 50], [34, 64], crop=[4, 2, 12, 14.5], rot=-8)]},
     {"name": "shard_b", "material": "nether_quartz",
      "pieces": [piece("droplet", [62, 38], [32, 82], crop=[4, 2, 12, 14.5], rot=-8)]},
     {"name": "shard_c", "material": "nether_quartz",
      "pieces": [piece("droplet", [88, 54], [30, 60], crop=[4, 2, 12, 14.5], rot=-8)]},
     {"name": "shard_d", "material": "nether_quartz",
      "pieces": [piece("droplet", [52, 70], [24, 44], crop=[5, 4, 12, 14.5], rot=-8)]}],
    [{"name": "lit", "kind": "flat", "material": "nether_quartz", "clip_to": "shard_b",
      "opacity": 0.75, "grad": grad(12, 46, "floor_light", 0.55),
      "pieces": [sub("droplet", [4, 2, 12, 14.5], [62, 38], [32, 82], [5.4, 2.4, 8.4, 9.0])]},
     {"name": "deep", "kind": "flat", "material": "nether_quartz", "clip_to": "shard_c",
      "opacity": 0.7, "grad": grad(50, 84, "well_void", 0.6),
      "pieces": [sub("droplet", [4, 2, 12, 14.5], [88, 54], [30, 60], [7.6, 8.0, 12.0, 14.5])]}])

# --- it_amethyst_shard ---------------------------------------------------------
SHARD_A_CROP = [4.5, 1.5, 11.5, 14.5]
SHARD_A_AT, SHARD_A_SIZE = [56, 60], [56, 100]
recipes["it_amethyst_shard"] = {
    **COMMON, "asset": "it_amethyst_shard", "status": "candidate", "seed": 270,
    "note": "it_amethyst_shard: three violet crystal prisms of one height rule, "
            "big one leaning 10 deg, small ones 14 deg the other way, no text.",
    "forms": [
        {"name": "shard_a", "material": "amethyst", "grad": grad(60, 108, "well_void", 0.4),
         "pieces": [piece("droplet", SHARD_A_AT, SHARD_A_SIZE, crop=SHARD_A_CROP, rot=10)]},
        {"name": "shard_b", "material": "amethyst",
         "pieces": [piece("droplet", [96, 88], [42, 62], crop=[5, 3, 11.5, 14.5], rot=-14)]},
        {"name": "shard_c", "material": "amethyst",
         "pieces": [piece("droplet", [30, 96], [34, 46], crop=[6, 6, 11.5, 14.5], rot=18)]},
        {"name": "lit", "kind": "flat", "material": "amethyst", "clip_to": "shard_a",
         "opacity": 0.8, "grad": grad(16, 56, "floor_light", 0.5),
         "pieces": [sub("droplet", SHARD_A_CROP, SHARD_A_AT, SHARD_A_SIZE,
                        [5.2, 2.0, 8.0, 9.0], rot=10)]},
        {"name": "deep", "kind": "flat", "material": "amethyst", "clip_to": "shard_b",
         "opacity": 0.7, "grad": grad(70, 110, "well_void", 0.65),
         "pieces": [sub("droplet", [5, 3, 11.5, 14.5], [96, 88], [42, 62],
                        [8.2, 8.0, 11.5, 14.5], rot=-14)]},
    ],
}


def main() -> int:
    for asset, data in recipes.items():
        path = REC / f"{asset}.json"
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(path.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
