"""Batch 3: heavy core, resin lump, dye note."""

from common import base, form, write_all
from gen_1 import clot

R = []

# ---------------------------------------------------------- it_heavy_core
r = base("it_heavy_core", 117, "Loot heavy core: a heavy iron ball in a hexagonal housing, with a dark "
                              "core well and four rivets.")
r["forms"] = [
    form("ball", "iron", 0,
         [{"icon": "circle", "at": [64, 64], "size": [98, 98]}]),
    form("housing", "iron", 1,
         [{"icon": "hexagon", "at": [64, 64], "size": [70, 70], "rot": 0}],
         color="#2b2d34"),
    form("housing2", "iron", 1,
         [{"icon": "hexagon", "at": [64, 64], "size": [38, 38], "rot": 0}],
         color="#3a3d46"),
    form("well", "void", 2,
         [{"icon": "circle", "at": [64, 64], "size": [20, 20]}]),
    form("rivet", "bronze", 3,
         [{"icon": "circle", "at": [64, 30], "size": [10, 10]},
          {"icon": "circle", "at": [64, 98], "size": [10, 10]},
          {"icon": "circle", "at": [30, 64], "size": [10, 10]},
          {"icon": "circle", "at": [98, 64], "size": [10, 10]}],
         kind="flat", opacity=0.75),
    form("wear", "rust", 4,
         [{"icon": "cloud", "crop": [3, 6, 13, 12], "at": [60, 82], "size": [70, 40]}],
         kind="wash", opacity=0.3, blend="multiply"),
]
R.append(r)

# ---------------------------------------------------------- it_resin_lump
r = base("it_resin_lump", 118, "Loot resin lump: the frozen clot form in amber resin.")
r["forms"] = clot("resin", gloss_color="#cfa85e")
R.append(r)

# ------------------------------------------------------ it_dye_recipe_note
r = base("it_dye_recipe_note", 119,
         "Dye recipe note: a folded paper slip with a bronze clip bar and three dye colour chips. "
         "No letters, no numbers, no runes - only three colour swatches.")
r["forms"] = [
    form("sheet", "paper", 0,
         [{"icon": "file", "at": [62, 66], "size": [96, 100], "rot": -8}]),
    form("chip_wine", "paper", 1,
         [{"icon": "square", "crop": [4, 4, 12, 12], "at": [40, 52], "size": [26, 26], "rot": -8}],
         color="#6d2f38", texture=False, grime=False),
    form("chip_teal", "paper", 2,
         [{"icon": "square", "crop": [4, 4, 12, 12], "at": [70, 66], "size": [26, 26], "rot": -8}],
         color="#3d5a55", texture=False, grime=False),
    form("chip_ochre", "paper", 3,
         [{"icon": "square", "crop": [4, 4, 12, 12], "at": [46, 88], "size": [24, 24], "rot": -8}],
         color="#8a6a2c", texture=False, grime=False),
    form("clip", "bronze", 4,
         [{"icon": "square", "crop": [1, 7, 15, 9], "at": [66, 26], "size": [42, 13], "rot": -8}]),
    form("clip_pin", "bronze", 5,
         [{"icon": "circle", "at": [48, 29], "size": [9, 9]}],
         kind="flat", opacity=0.8),
]
R.append(r)

write_all(R)
