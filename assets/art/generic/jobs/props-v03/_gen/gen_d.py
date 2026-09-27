"""Recipes: 6. fish (4 assets).

Run from the job folder:  py -3 -B _gen\\gen_d.py
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DISC, DROP_SEED, FISH_BODY, FISH_TAIL, PRISM, STEM_TAPER, piece, rec, write  # noqa: E402

# where the eye hole sits inside the cropped fish body, in piece-box fractions
EYE = (0.815, 0.5)


def place(fx, fy, at, size, rot):
    """Where a feature at fraction (fx, fy) of a placed piece ends up."""
    ox, oy = (fx - 0.5) * size[0], (fy - 0.5) * size[1]
    r = math.radians(rot)
    return [at[0] + ox * math.cos(r) - oy * math.sin(r),
            at[1] + ox * math.sin(r) + oy * math.cos(r)]


def whole_fish(skin, back, belly, note, seed, at=(70, 62), size=(80, 68), rot=-14,
               fin=True, tint=None) -> list:
    tail_at = (at[0] - 44, at[1] + 4)
    eye = place(EYE[0], EYE[1], at, size, rot)
    forms = [
        {"name": "tail", "z": 0, "material": back, "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("fish", tail_at, [28, 60], crop=FISH_TAIL, rot=rot)]},
        {"name": "body", "z": 1, "material": skin, "rough": {"amp": 0.25, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "soot", "y0": 56, "y1": 104, "amount": 0.28},
         "pieces": [piece("fish", at, list(size), crop=FISH_BODY, rot=rot)]},
    ]
    if fin:
        forms.append(
            {"name": "dorsal", "z": 2, "material": back, "shade": {"bump": 1.0, "highlight_amount": 0.4},
             "pieces": [piece("prism", [at[0] - 4, at[1] - 32], [30, 24], crop=[3.4, 2.0, 9.6, 8.0],
                              rot=rot + 180)]})
    forms += [
        {"name": "belly", "z": 3, "kind": "flat", "material": belly, "opacity": 0.45,
         "clip_to": "body",
         "pieces": [piece("circle", [at[0] - 2, at[1] + 24], [70, 22], crop=DISC, rot=rot)]},
        {"name": "back", "z": 4, "kind": "flat", "material": back, "opacity": 0.5, "clip_to": "body",
         "pieces": [piece("droplet", [at[0] - 4, at[1] - 22], [70, 16], crop=STEM_TAPER, rot=rot)]},
        {"name": "scales", "z": 5, "kind": "flat", "material": tint or back, "opacity": 0.22,
         "clip_to": "body",
         "pieces": [piece("sponge", [at[0] + 2, at[1] + 4], [50, 34], rot=rot - 10)]},
        {"name": "gill", "z": 6, "kind": "flat", "material": "soot", "opacity": 0.5, "clip_to": "body",
         "pieces": [piece("droplet", [at[0] - 26, at[1] + 2], [7, 40], crop=STEM_TAPER, rot=rot + 20)]},
        {"name": "eye", "z": 7, "material": "ink",
         "pieces": [piece("circle", eye, [10, 9], crop=DISC)]},
        {"name": "gleam", "z": 8, "kind": "flat", "material": belly, "opacity": 0.3,
         "clip_to": "body",
         "pieces": [piece("circle", [at[0] - 22, at[1] - 16], [26, 10], crop=DISC, rot=rot)]},
    ]
    return forms


RECIPES = [
    # ------------------------------------------------------------------- it_cod
    rec("it_cod", "whole cod lying at a slight diagonal: pale grey body, lighter belly, "
        "darker back, dorsal fin, dark eye. No text.", 3401,
        whole_fish("cod", "fish", "fish_belly",
                   "whole cod lying at a slight diagonal", 3401)),
    # ---------------------------------------------------------------- it_salmon
    rec("it_salmon", "whole salmon lying at a diagonal: dull red-brown body, paler belly, "
        "dark back, dorsal fin, dark eye. No text.", 3402,
        whole_fish("salmon", "fish", "crumb", "", 3402)),
    # ---------------------------------------------------------- it_tropical_fish
    rec("it_tropical_fish", "tropical fish gone yellow-brown and battered: faded gold body, "
        "ragged fins, a dull green back stripe, dark eye. No text.", 3403, [
        {"name": "tailfin", "z": 0, "material": "tropical",
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("droplet", [22, 58], [30, 46], crop=DROP_SEED, rot=-24),
                    piece("droplet", [30, 80], [24, 26], crop=DROP_SEED, rot=14)]},
        {"name": "body", "z": 1, "material": "tropical", "rough": {"amp": 0.45, "soft": 1.1, "cell": 6},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "mold", "y0": 58, "y1": 104, "amount": 0.3},
         "pieces": [piece("fish", [70, 64], [82, 70], crop=FISH_BODY, rot=-14)]},
        {"name": "dorsal", "z": 2, "material": "pastry_dark",
         "pieces": [piece("prism", [64, 28], [34, 26], crop=[3.4, 2.0, 9.6, 8.0], rot=166),
                    piece("prism", [84, 30], [22, 18], crop=[3.4, 2.0, 9.6, 8.0], rot=196)]},
        {"name": "ventral", "z": 3, "material": "pastry_dark",
         "pieces": [piece("prism", [72, 102], [26, 18], crop=[3.4, 2.0, 9.6, 8.0], rot=10)]},
        {"name": "belly", "z": 4, "kind": "flat", "material": "crumb", "opacity": 0.4,
         "clip_to": "body",
         "pieces": [piece("circle", [68, 88], [70, 22], crop=DISC, rot=-14)]},
        {"name": "stripe", "z": 5, "kind": "flat", "material": "leaf_dark", "opacity": 0.55,
         "clip_to": "body",
         "pieces": [piece("droplet", [66, 42], [66, 15], crop=STEM_TAPER, rot=-14)]},
        {"name": "batter", "z": 6, "kind": "flat", "material": "moldy", "opacity": 0.45,
         "clip_to": "body",
         "pieces": [piece("sponge", [60, 74], [52, 34], rot=-24),
                    piece("sponge", [86, 56], [30, 22], rot=12)]},
        {"name": "eye", "z": 7, "material": "ink",
         "pieces": [piece("circle", place(EYE[0], EYE[1], [70, 64], [82, 70], -14), [10, 9], crop=DISC)]},
        {"name": "gleam", "z": 8, "kind": "flat", "material": "crumb", "opacity": 0.3,
         "clip_to": "body",
         "pieces": [piece("circle", [48, 48], [26, 10], crop=DISC, rot=-14)]},
    ]),
    # -------------------------------------------------------------- it_pufferfish
    rec("it_pufferfish", "puffed pufferfish seen from the side: round spiky body, pale "
        "belly, small tail fin, dark eye with a pale ring. No text.", 3404, [
        {"name": "tail", "z": 0, "material": "puffer",
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("droplet", [104, 66], [24, 36], crop=DROP_SEED, rot=96)]},
        {"name": "spikes", "z": 1, "material": "puffer",
         "shade": {"bump": 1.0, "highlight_amount": 0.45},
         "pieces": [piece("prism", [60, 64], [16, 22], crop=[3.4, 3.0, 9.6, 13.0],
                          repeat={"ellipse": [60, 64, 40, 39], "count": 16, "orient": True,
                                  "jitter": {"at": 2.0, "rot": 9, "size": 0.16}})]},
        {"name": "body", "z": 2, "material": "puffer", "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "mold", "y0": 62, "y1": 104, "amount": 0.3},
         "pieces": [piece("circle", [60, 64], [80, 78], crop=DISC)]},
        {"name": "belly", "z": 3, "kind": "flat", "material": "crumb", "opacity": 0.42,
         "clip_to": "body",
         "pieces": [piece("circle", [60, 88], [64, 26], crop=DISC)]},
        {"name": "freckles", "z": 4, "kind": "flat", "material": "soil", "opacity": 0.5,
         "clip_to": "body",
         "pieces": [piece("circle", [44, 58], [9, 7], crop=DISC),
                    piece("circle", [62, 48], [8, 6], crop=DISC),
                    piece("circle", [76, 62], [9, 7], crop=DISC),
                    piece("circle", [52, 78], [8, 6], crop=DISC),
                    piece("circle", [70, 84], [7, 6], crop=DISC)]},
        {"name": "eye_ring", "z": 5, "kind": "flat", "material": "bone_white", "opacity": 0.85,
         "clip_to": "body",
         "pieces": [piece("circle", [42, 52], [16, 15], crop=DISC)]},
        {"name": "eye", "z": 6, "material": "ink",
         "pieces": [piece("circle", [42, 52], [9, 8], crop=DISC)]},
        {"name": "gleam", "z": 7, "kind": "flat", "material": "bone_white", "opacity": 0.3,
         "clip_to": "body",
         "pieces": [piece("circle", [42, 36], [30, 13], crop=DISC, rot=-20)]},
    ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
