"""Batch 1: bone, string, feather, leather, ink sac, turtle scute, slime ball, blaze powder.

The "clot" form (slime ball / resin lump / magma cream) and the "powder heap" form are frozen
here and reused verbatim by gen_3 / gen_4 so every gooey lump and every powder reads the same.
"""

from common import MB_BIG, MB_MID, MB_SML, SEA_BAND, base, form, write_all


# ---------------------------------------------------------------- shared forms
def clot(mat: str, gloss_color=None, crust_color=None) -> list:
    """One frozen lumpy-clot silhouette: round body + two lobes + a run-off drip (+ a gloss)."""
    forms = [
        form("drip", mat, 0,
             [{"icon": "circle", "at": [72, 100], "size": [30, 26]}]),
        form("body", mat, 1,
             [{"icon": "metaballs", "crop": MB_BIG, "at": [64, 60], "size": [84, 76]}]),
        form("lobe_l", mat, 2,
             [{"icon": "metaballs", "crop": MB_MID, "at": [32, 86], "size": [46, 42]}]),
        form("lobe_r", mat, 2,
             [{"icon": "metaballs", "crop": MB_SML, "at": [96, 88], "size": [40, 36]}]),
    ]
    if gloss_color:
        forms.append(form("gloss", mat, 3,
                          [{"icon": "circle", "at": [46, 44], "size": [22, 20]}],
                          kind="flat", color=gloss_color, opacity=0.45))
    if crust_color:
        forms.append(form("crust", mat, 3,
                          [{"icon": "cloud", "crop": [3, 4, 10, 10], "at": [50, 44], "size": [50, 40]}],
                          kind="flat", color=crust_color, opacity=0.4))
    return forms


# A tight triangular lattice (15 px pitch) of 22 px round grains, so the heap has no holes.
POWDER_POINTS = [
    [34, 100], [49, 100], [64, 100], [79, 100], [94, 100],
    [26.5, 85], [41.5, 85], [56.5, 85], [71.5, 85], [86.5, 85], [101.5, 85],
    [34, 70], [49, 70], [64, 70], [79, 70], [94, 70],
    [41.5, 55], [56.5, 55], [71.5, 55], [86.5, 55],
    [49, 40], [64, 40], [79, 40],
]


def powder_heap(mat: str) -> list:
    """One frozen powder heap: a triangular lattice of round grains plus three loose specks."""
    return [
        form("heap", mat, 0,
             [{"icon": "circle", "size": 22, "at": [0, 0],
               "repeat": {"points": POWDER_POINTS,
                          "jitter": {"at": 2.0, "size": 0.12}}}]),
        form("speck", mat, 1,
             [{"icon": "metaballs", "crop": MB_SML, "at": [30, 20], "size": 12},
              {"icon": "metaballs", "crop": MB_MID, "at": [100, 22], "size": 11},
              {"icon": "metaballs", "crop": MB_SML, "at": [66, 16], "size": 8}]),
    ]


R = []

# ---------------------------------------------------------------- it_bone
r = base("it_bone", 101, "Loot bone: a long split bone plus two loose chips, pale bone material.")
r["forms"] = [
    form("bone", "bone", 0,
         [{"icon": "bone", "at": [62, 62], "size": [96, 96], "rot": 34}]),
    form("shard", "bone", 1,
         [{"icon": "bone_fracture", "crop": [10, 5, 16, 13], "at": [99, 88], "size": [26, 26], "rot": -22}]),
    form("chip", "bone", 2,
         [{"icon": "bone", "crop": [0, 4, 7, 13], "at": [26, 82], "size": [30, 30], "rot": 24}]),
]
R.append(r)

# ------------------------------------------------------------- it_string
r = base("it_string", 102, "Loot thread: a ball of wound thread - three wound strands across the "
                           "ball and one loose end running off it.")
r["forms"] = [
    form("ball", "thread", 0,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [62, 62], "size": [88, 80]}]),
    form("wind1", "thread", 1,
         [{"icon": "sea", "crop": SEA_BAND, "at": [64, 46], "size": [66, 15], "rot": -18}],
         color="#7a6f57"),
    form("wind2", "thread", 2,
         [{"icon": "sea", "crop": SEA_BAND, "at": [64, 66], "size": [68, 15], "rot": 14}],
         color="#7a6f57"),
    form("wind3", "thread", 3,
         [{"icon": "sea", "crop": SEA_BAND, "at": [64, 86], "size": [62, 15], "rot": -8}],
         color="#7a6f57"),
    form("tail", "thread", 4,
         [{"icon": "sea", "crop": SEA_BAND, "at": [90, 102], "size": [40, 12], "rot": 26}]),
]
R.append(r)

# ------------------------------------------------------------ it_feather
r = base("it_feather", 103, "Loot feather: quill feather, pale vane split into overlapping layers.")
r["forms"] = [
    form("vane", "bone", 0,
         [{"icon": "feather", "at": [64, 62], "size": [100, 100], "rot": 0}]),
    form("barb", "bone", 1,
         [{"icon": "feather", "crop": [1, 8, 8, 16], "at": [36, 92], "size": [40, 40], "rot": 0}]),
    form("vane_top", "bone", 2,
         [{"icon": "feather", "crop": [3, 0, 16, 8], "at": [82, 42], "size": [56, 56], "rot": 8}]),
]
R.append(r)

# ------------------------------------------------------------ it_leather
r = base("it_leather", 104, "Loot leather: a torn scrap of hide with a crease and a scuffed grain.")
r["forms"] = [
    form("scrap", "leather", 0,
         [{"icon": "square", "crop": [2, 3, 14, 13], "at": [64, 66], "size": [98, 88], "rot": 9},
          {"icon": "triangle", "at": [92, 34], "size": [30, 30], "rot": 180, "op": "sub"}],
         rough={"amp": 0.45, "soft": 2.5, "cell": 12}),
    form("grain", "leather", 1,
         [{"icon": "cloud", "crop": [3, 5, 13, 12], "at": [58, 70], "size": [70, 44], "rot": 9}],
         kind="wash", opacity=0.28, blend="multiply"),
    form("crease", "leather", 2,
         [{"icon": "square", "crop": [2, 7, 14, 10], "at": [64, 64], "size": [92, 20], "rot": 9}],
         color="#3a2a21", opacity=0.6),
]
R.append(r)

# ----------------------------------------------------------- it_ink_sac
r = base("it_ink_sac", 105, "Loot ink sac: a black drop-shaped sac with a tied thread loop at the "
                           "neck and a small drip at the foot.")
r["forms"] = [
    form("drip", "ink_sac", 0,
         [{"icon": "circle", "at": [32, 102], "size": [22, 19]}]),
    form("sac", "ink_sac", 1,
         [{"icon": "droplet", "at": [66, 72], "size": [78, 88]}]),
    form("tie", "thread", 2,
         [{"icon": "ring", "at": [60, 22], "size": [26, 16], "rot": -18}]),
    form("gloss", "ink_sac", 3,
         [{"icon": "circle", "at": [52, 56], "size": [11, 11]}],
         kind="flat", color="#7d7d9e", opacity=0.45),
]
R.append(r)

# --------------------------------------------------------- it_turtle_scute
r = base("it_turtle_scute", 106, "Loot turtle scute: one shell plate, three nested hexagon rings, chipped.")
r["forms"] = [
    form("plate", "scute", 0,
         [{"icon": "hexagon", "at": [62, 68], "size": [92, 92], "rot": 0}]),
    form("ring", "scute", 1,
         [{"icon": "hexagon", "at": [62, 68], "size": [58, 58], "rot": 0}],
         color="#5f6440"),
    form("core", "scute", 2,
         [{"icon": "hexagon", "at": [62, 68], "size": [28, 28], "rot": 0}],
         color="#43462c"),
    form("chip", "scute", 3,
         [{"icon": "hexagon", "crop": [0, 0, 7, 9], "at": [100, 36], "size": [24, 26], "rot": 40}]),
]
R.append(r)

# --------------------------------------------------------- it_slime_ball
r = base("it_slime_ball", 107, "Loot slime ball: the frozen clot form in slime green.")
r["forms"] = clot("slime", gloss_color="#a8c9a4")
R.append(r)

# ------------------------------------------------------- it_blaze_powder
r = base("it_blaze_powder", 108,
         "Loot blaze powder (chose the powder half of 'rod/powder'): the frozen powder heap, "
         "burnt-orange grains.")
r["forms"] = powder_heap("blaze_powder")
R.append(r)

write_all(R)
