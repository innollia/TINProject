"""Recipes: 4. crops and gathered plants (5 assets).

Run from the job folder:  py -3 -B _gen\\gen_b.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import CLOUD, DISC, GRASS, LEAF, SPROUT_TOP, STEM_TAPER, piece, rec, write  # noqa: E402

FLOWER = [1.4, 0.8, 14.6, 10.8]

RECIPES = [
    # ----------------------------------------------------------------- it_carrot
    rec("it_carrot", "carrot lying on the ground with its tip to the lower left, cut end "
        "upper right, three dark ridges, a small tuft of greens. No text.", 3201, [
        {"name": "greens", "z": 0, "material": "carrot_top",
         "pieces": [piece("grass", [82, 26], [36, 28], crop=GRASS, rot=25),
                    piece("grass", [74, 32], [24, 19], crop=GRASS, rot=56, opacity=0.9)]},
        {"name": "body", "z": 1, "material": "carrot", "rough": {"amp": 0.3, "soft": 1.0, "cell": 6},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "pieces": [piece("droplet", [64, 70], [56, 92], rot=-205)]},
        {"name": "cut", "z": 2, "kind": "flat", "material": "carrot_ridge", "clip_to": "body",
         "pieces": [piece("circle", [79, 38], [24, 22], crop=DISC, rot=-25)]},
        {"name": "ridges", "z": 3, "kind": "flat", "material": "carrot_dark", "opacity": 0.5,
         "clip_to": "body",
         "pieces": [piece("droplet", [48, 88], [10, 40], rot=-205),
                    piece("droplet", [60, 68], [10, 40], rot=-205),
                    piece("droplet", [72, 48], [10, 38], rot=-205)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": "carrot_ridge", "opacity": 0.3,
         "clip_to": "body",
         "pieces": [piece("droplet", [52, 78], [9, 34], rot=-215)]},
    ]),
    # ---------------------------------------------------------------- it_potato
    rec("it_potato", "one dull brown potato lump, slightly irregular, with sunken eyes and a "
        "pale patch. Lying on the ground. No text.", 3202, [
        {"name": "body", "z": 0, "material": "potato",
         "rough": {"amp": 0.55, "soft": 1.2, "cell": 7},
         "shade": {"bump": 1.1, "highlight_amount": 0.4},
         "pieces": [piece("cloud", [64, 68], [90, 80], crop=CLOUD, rot=-12)]},
        {"name": "eyes", "z": 1, "kind": "flat", "material": "soil", "opacity": 0.9,
         "clip_to": "body",
         "pieces": [piece("circle", [40, 56], [14, 12], crop=DISC),
                    piece("circle", [58, 78], [12, 10], crop=DISC),
                    piece("circle", [78, 62], [15, 13], crop=DISC),
                    piece("circle", [92, 82], [11, 9], crop=DISC),
                    piece("circle", [66, 100], [10, 8], crop=DISC)]},
        {"name": "eye_rings", "z": 2, "kind": "flat", "material": "pastry_dark", "opacity": 0.5,
         "clip_to": "body",
         "pieces": [piece("circle", [40, 56], [22, 19], crop=DISC),
                    piece("circle", [78, 62], [23, 20], crop=DISC),
                    piece("circle", [58, 78], [19, 16], crop=DISC)]},
        {"name": "patch", "z": 2, "kind": "flat", "material": "crumb", "opacity": 0.35,
         "clip_to": "body",
         "pieces": [piece("circle", [44, 58], [34, 22], crop=DISC, rot=-18)]},
        {"name": "dirt", "z": 3, "kind": "flat", "material": "soil", "opacity": 0.4,
         "clip_to": "body",
         "pieces": [piece("sponge", [80, 92], [44, 30], opacity=0.7)]},
    ]),
    # -------------------------------------------------------------- it_beetroot
    rec("it_beetroot", "beetroot lying on the ground: round dark red bulb, one thin root "
        "trailing to the lower left, four dull green leaves on short stems. No text.", 3203, [
        {"name": "root", "z": 0, "material": "beet",
         "pieces": [piece("droplet", [38, 100], [13, 38], crop=STEM_TAPER, rot=205)]},
        {"name": "stems", "z": 1, "material": "leaf_dark",
         "pieces": [piece("droplet", [56, 40], [10, 26], crop=STEM_TAPER, rot=-14),
                    piece("droplet", [72, 40], [10, 26], crop=STEM_TAPER, rot=14)]},
        {"name": "leaves_b", "z": 2, "material": "leaf_dark",
         "pieces": [piece("sprout", [64, 28], [58, 26], crop=SPROUT_TOP, rot=180)]},
        {"name": "leaves_f", "z": 3, "material": "carrot_top",
         "pieces": [piece("sprout", [64, 26], [58, 26], crop=SPROUT_TOP)]},
        {"name": "bulb", "z": 4, "material": "beet", "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.1, "highlight_amount": 0.45},
         "grad": {"to": "soot", "y0": 74, "y1": 108, "amount": 0.35},
         "pieces": [piece("circle", [64, 70], [84, 74], crop=DISC)]},
        {"name": "gleam", "z": 5, "kind": "flat", "material": "beet_pale", "opacity": 0.4,
         "clip_to": "bulb",
         "pieces": [piece("circle", [46, 54], [30, 18], crop=DISC, rot=-24)]},
        {"name": "rings", "z": 6, "kind": "flat", "material": "beet_pale", "opacity": 0.22,
         "clip_to": "bulb",
         "pieces": [piece("droplet", [78, 86], [10, 26], crop=STEM_TAPER, rot=-30)]},
    ]),
    # ------------------------------------------------------------- it_dandelion
    rec("it_dandelion", "one yellow dandelion head seen from above on a short dark stem, "
        "five petals around a darker pollen centre. No text.", 3204, [
        {"name": "stem", "z": 0, "material": "leaf_dark",
         "pieces": [piece("droplet", [64, 100], [15, 46], crop=STEM_TAPER)]},
        {"name": "head", "z": 1, "material": "dandelion", "shade": {"bump": 1.0, "highlight_amount": 0.5},
         "pieces": [piece("flower", [64, 50], [84, 74], crop=FLOWER)]},
        {"name": "pollen", "z": 2, "kind": "flat", "material": "dandelion",
         "pieces": [piece("circle", [64, 50], [30, 26], crop=DISC)]},
        {"name": "pollen_mid", "z": 3, "kind": "flat", "material": "dandelion_mid", "opacity": 0.75,
         "clip_to": "pollen",
         "pieces": [piece("circle", [64, 50], [17, 15], crop=DISC)]},
        {"name": "pollen_gleam", "z": 4, "kind": "flat", "material": "dandelion", "opacity": 0.4,
         "clip_to": "pollen",
         "pieces": [piece("circle", [57, 44], [15, 8], crop=DISC, rot=-26)]},
    ]),
    # ------------------------------------------------------------ it_dried_kelp
    rec("it_dried_kelp", "bundle of dried kelp: four dark olive strips standing side by side "
        "with torn edges, paler crinkle veins and one frond. No text.", 3205, [
        {"name": "s1", "z": 0, "material": "kelp", "rough": {"amp": 0.5, "soft": 1.0, "cell": 6},
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("droplet", [38, 64], [20, 88], crop=STEM_TAPER, rot=-12)]},
        {"name": "s2", "z": 1, "material": "kelp", "rough": {"amp": 0.5, "soft": 1.0, "cell": 6},
         "pieces": [piece("droplet", [90, 64], [20, 88], crop=STEM_TAPER, rot=12)]},
        {"name": "s3", "z": 2, "material": "kelp", "rough": {"amp": 0.5, "soft": 1.0, "cell": 6},
         "pieces": [piece("droplet", [74, 66], [20, 88], crop=STEM_TAPER, rot=4)]},
        {"name": "s4", "z": 3, "material": "kelp", "rough": {"amp": 0.5, "soft": 1.0, "cell": 6},
         "pieces": [piece("droplet", [58, 62], [20, 88], crop=STEM_TAPER, rot=-4)]},
        {"name": "frond", "z": 4, "material": "kelp_pale",
         "pieces": [piece("leaf", [30, 30], [34, 16], crop=LEAF, rot=-34),
                    piece("leaf", [100, 96], [30, 14], crop=LEAF, rot=28)]},
        {"name": "veins", "z": 5, "kind": "flat", "material": "kelp_pale", "opacity": 0.4,
         "pieces": [piece("droplet", [38, 64], [6, 70], crop=STEM_TAPER, rot=-12),
                    piece("droplet", [58, 62], [6, 70], crop=STEM_TAPER, rot=-4),
                    piece("droplet", [74, 66], [6, 70], crop=STEM_TAPER, rot=4),
                    piece("droplet", [90, 64], [6, 70], crop=STEM_TAPER, rot=12)]},
        {"name": "crinkle", "z": 6, "kind": "flat", "material": "kelp_pale", "opacity": 0.22,
         "pieces": [piece("wave", [50, 46], [48, 16], rot=-8),
                    piece("wave", [80, 86], [44, 14], rot=6)]},
        {"name": "nubs", "z": 7, "kind": "flat", "material": "kelp_dark", "opacity": 0.6,
         "pieces": [piece("circle", [22, 40], [16, 11], crop=DISC, rot=-12),
                    piece("circle", [108, 46], [18, 12], crop=DISC, rot=12),
                    piece("circle", [26, 92], [14, 10], crop=DISC, rot=-4)]},
    ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
