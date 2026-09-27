"""Batch 4: brewing materials.  nether wart, the three powders, resin-like clots and the crystals
reuse the frozen forms from gen_1 / gen_2 so each class keeps one form."""

from common import MB_BIG, MB_MID, MB_SML, base, form, write_all
from gen_1 import clot, powder_heap

R = []

# --------------------------------------------------------- it_glass_bottle
r = base("it_glass_bottle", 120, "Brewing glass bottle: a dusty green glass flask with a cork and a "
                                "neck band.")
r["forms"] = [
    form("body", "glass_bottle", 0,
         [{"icon": "potion", "crop": [2, 3, 14, 16], "at": [64, 74], "size": [88, 88]}]),
    form("liquid", "slime", 1,
         [{"icon": "circle", "at": [64, 84], "size": [52, 52]}],
         kind="flat", opacity=0.55),
    form("band", "glass_bottle", 2,
         [{"icon": "square", "crop": [4, 2, 12, 4], "at": [64, 44], "size": [30, 10]}],
         color="#6b7566"),
    form("cork", "wood", 3,
         [{"icon": "cylinder", "crop": [4, 0, 12, 3], "at": [64, 24], "size": [26, 18]}]),
    form("glint", "glass_bottle", 4,
         [{"icon": "square", "crop": [4, 8, 6, 11], "at": [44, 76], "size": [10, 22], "rot": -14}],
         kind="flat", color="#cfdcc0", opacity=0.5),
]
R.append(r)

# ---------------------------------------------------------- it_nether_wart
r = base("it_nether_wart", 121, "Brewing nether wart: a knobbly dark red root nodule with raised "
                                "warts and a short root tail.")
r["forms"] = [
    form("root", "nether_wart", 0,
         [{"icon": "droplet", "at": [64, 104], "size": [26, 26], "rot": 180}],
         color="#3c1917"),
    form("nodule", "nether_wart", 1,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [62, 76], "size": [76, 68]}]),
    form("upper", "nether_wart", 2,
         [{"icon": "metaballs", "crop": MB_MID, "at": [50, 44], "size": [40, 40]}]),
    form("lobe", "nether_wart", 2,
         [{"icon": "metaballs", "crop": MB_SML, "at": [26, 58], "size": [24, 24]}]),
    form("top", "nether_wart", 3,
         [{"icon": "metaballs", "crop": MB_SML, "at": [78, 26], "size": [22, 22]}]),
    form("wart1", "nether_wart", 4,
         [{"icon": "circle", "at": [48, 62], "size": [18, 18]}],
         color="#7d3f36"),
    form("wart2", "nether_wart", 4,
         [{"icon": "circle", "at": [84, 58], "size": [14, 14]}],
         color="#7d3f36"),
    form("wart3", "nether_wart", 4,
         [{"icon": "circle", "at": [66, 98], "size": [12, 12]}],
         color="#6a3229"),
]
R.append(r)

# ------------------------------- the three powders, on the frozen powder heap (same geometry)
r = base("it_redstone_dust", 122,
         "Brewing redstone dust: the frozen powder heap, deep red grains.")
r["forms"] = powder_heap("redstone")
R.append(r)

r = base("it_glowstone_dust", 123,
         "Brewing glowstone dust: the frozen powder heap, dull warm yellow grains.")
r["forms"] = powder_heap("glowstone")
R.append(r)

r = base("it_gunpowder", 124,
         "Brewing gunpowder: the frozen powder heap, dark grey grains.")
r["forms"] = powder_heap("gunpowder")
R.append(r)

# -------------------------------------------------------- it_dragon_breath
r = base("it_dragon_breath", 125, "Brewing dragon's breath: a warm grey plume that thins into drifting "
                                 "wisp dashes.")
r["forms"] = [
    form("tail", "dragon_breath", 0,
         [{"icon": "fog", "crop": [0, 9, 16, 16], "at": [62, 88], "size": [96, 50]}]),
    form("plume", "dragon_breath", 1,
         [{"icon": "cloud", "at": [58, 52], "size": [90, 72]}]),
    form("wisp1", "dragon_breath", 2,
         [{"icon": "cloud", "crop": [3, 4, 11, 10], "at": [24, 40], "size": [30, 30]}],
         kind="flat", opacity=0.5),
    form("wisp2", "dragon_breath", 2,
         [{"icon": "cloud", "crop": [4, 4, 11, 9], "at": [100, 28], "size": [24, 24]}],
         kind="flat", opacity=0.4),
]
R.append(r)

# ----------------------------------------------------------- it_spider_eye
r = base("it_spider_eye", 126, "Brewing spider eye: a dark red almond eyeball with a black pupil and "
                              "a wet highlight.")
r["forms"] = [
    form("eye", "spider_eye", 0,
         [{"icon": "eye", "at": [64, 64], "size": [100, 62]}]),
    form("pupil", "void", 1,
         [{"icon": "circle", "at": [64, 64], "size": [26, 26]}]),
    form("glint", "ghast_tear", 2,
         [{"icon": "circle", "at": [50, 54], "size": [11, 11]}],
         kind="flat", opacity=0.7),
]
R.append(r)

# ---------------------------------------------------------------- it_sugar
r = base("it_sugar", 127, "Brewing sugar: a heap of pale sugar crystals, same pyramid facet split as "
                         "the other crystals.")
r["forms"] = [
    form("heap", "sugar", 0,
         [{"icon": "cloud", "crop": [2, 4, 14, 13], "at": [64, 88], "size": [92, 54]}]),
    form("crystal_l", "sugar", 1,
         [{"icon": "pyramid", "at": [44, 68], "size": [34, 46], "rot": -12}]),
    form("crystal_m", "sugar", 1,
         [{"icon": "pyramid", "at": [70, 60], "size": [38, 52], "rot": 6}]),
    form("crystal_r", "sugar", 1,
         [{"icon": "pyramid", "at": [92, 80], "size": [26, 34], "rot": 18}]),
    form("grain", "sugar", 2,
         [{"icon": "metaballs", "crop": [10, 10, 16, 16], "at": [30, 40], "size": [14, 14]}]),
]
R.append(r)

# ------------------------------------------------------------ it_rabbit_foot
r = base("it_rabbit_foot", 128, "Brewing rabbit's foot: a pale furry foot - a straight ankle stub, "
                                "four toes and a pad stacked so the pad reads first.")
r["forms"] = [
    form("ankle", "bone", 0,
         [{"icon": "square", "crop": [6, 9, 10, 16], "at": [64, 30], "size": [26, 38]},
          {"icon": "square", "crop": [4, 9, 12, 16], "at": [64, 20], "size": [34, 24]}],
         color="#a8987c"),
    form("toes", "bone", 1,
         [{"icon": "paw_print", "crop": [1, 0, 15, 7], "at": [64, 58], "size": [58, 30]}]),
    form("pad", "bone", 2,
         [{"icon": "paw_print", "crop": [3, 9, 16, 16], "at": [64, 88], "size": [66, 50]}]),
    form("heel", "bone", 3,
         [{"icon": "circle", "at": [48, 96], "size": [15, 15]}],
         color="#a8987c", opacity=0.5),
]
R.append(r)

# --------------------------------------------------------- it_glimmer_melon
r = base("it_glimmer_melon", 129, "Brewing glimmer melon: a melon wedge with a dark rind, seeds and a "
                                  "glimmer sparkle.")
r["forms"] = [
    form("rind", "slime", 0,
         [{"icon": "pyramid", "at": [62, 64], "size": [98, 88], "rot": 0}],
         color="#2f4a33"),
    form("flesh", "melon_flesh", 1,
         [{"icon": "triangle", "at": [64, 80], "size": [72, 56], "rot": 0}]),
    form("seed", "", 2,
         [{"icon": "circle", "at": [50, 88], "size": [9, 9]},
          {"icon": "circle", "at": [66, 94], "size": [9, 9]},
          {"icon": "circle", "at": [78, 82], "size": [8, 8]}],
         kind="flat", color="#1a1a10", opacity=0.85),
    form("glimmer", "sugar", 3,
         [{"icon": "stars", "crop": [9, 0, 16, 8], "at": [100, 26], "size": [26, 26]}],
         kind="flat", opacity=0.7),
]
R.append(r)

# ---------------------------------------------------------- it_magma_cream
r = base("it_magma_cream", 130, "Brewing magma cream: the frozen clot form in hot orange with a pale "
                                "cooled crust.")
r["forms"] = clot("magma_cream", crust_color="#c98a52")
R.append(r)

# ------------------------------------------------------------ it_ghast_tear
r = base("it_ghast_tear", 131, "Brewing ghast tear: a pale cold teardrop, rounded foot and a bright "
                              "wet highlight.")
r["forms"] = [
    form("tear", "ghast_tear", 0,
         [{"icon": "droplet", "at": [64, 66], "size": [76, 90]}]),
    form("glint", "ghast_tear", 1,
         [{"icon": "circle", "at": [50, 82], "size": [14, 14]}],
         kind="flat", color="#e2eaec", opacity=0.7),
]
R.append(r)

# ------------------------------------------------------ it_phantom_membrane
r = base("it_phantom_membrane", 132, "Brewing phantom membrane: a thin torn pale sheet, ragged on two "
                                     "edges, with one soft fold.")
r["forms"] = [
    form("sheet", "membrane", 0,
         [{"icon": "file", "crop": [1, 1, 15, 15], "at": [62, 64], "size": [92, 92], "rot": 8},
          {"icon": "triangle", "at": [104, 34], "size": [26, 26], "rot": 90, "op": "sub"},
          {"icon": "triangle", "at": [30, 96], "size": [22, 22], "rot": 270, "op": "sub"}],
         rough={"amp": 0.55, "soft": 2.0, "cell": 11}),
    form("fold", "membrane", 1,
         [{"icon": "file", "crop": [2, 2, 8, 15], "at": [54, 64], "size": [40, 88], "rot": 8}],
         color="#75756e", opacity=0.45),
    form("sheen", "membrane", 2,
         [{"icon": "cloud", "crop": [4, 5, 11, 10], "at": [70, 50], "size": [40, 30]}],
         kind="flat", color="#c4c4ba", opacity=0.35),
]
R.append(r)

write_all(R)
