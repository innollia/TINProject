"""Recipes: 8. stews and soups (4 assets). Deep dish seen from three-quarter above.

Run from the job folder:  py -3 -B _gen\\gen_f.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import (BONE_DIAG, CAULDRON_LID, CAULDRON_POT, CUP_BODY, DISC,  # noqa: E402
                    DROP_SEED, STEM_TAPER, piece, rec, write)

# cauldron, seen from above-front: pot at [64, 76] size [92, 84]
POT = {"pot_at": [64, 76], "pot_size": [92, 84], "rim_y": 44}
# bowl, seen from above-front: cup body at [64, 74] size [90, 82]
BOWL = {"pot_at": [64, 74], "pot_size": [90, 82], "rim_y": 42}


def pot_forms(geom, body, liquid, bits, note, seed, lid=None, bone=None,
              scum=None, bubbles=False) -> list:
    at, size, rim = geom["pot_at"], geom["pot_size"], geom["rim_y"]
    forms = []
    z = 0
    if lid:
        forms.append({"name": "lid", "z": z, "material": "ceramic",
                      "shade": {"bump": 1.0, "highlight_amount": 0.45},
                      "pieces": [piece("cauldron", [at[0] - 8, rim - 14], [88, 20],
                                       crop=CAULDRON_LID, rot=-14)]})
        z += 1
    if bone:
        forms.append({"name": "bone", "z": z, "material": "bone_white",
                      "shade": {"bump": 0.9, "highlight_amount": 0.4},
                      "pieces": [piece("bone", bone[0], bone[1], crop=BONE_DIAG, rot=bone[2])]})
        z += 1
    forms += [
        {"name": "pot", "z": z, "material": body, "rough": {"amp": 0.25, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "soot", "y0": 84, "y1": 118, "amount": 0.35},
         "pieces": [piece("cauldron" if geom is POT else "cup", at, list(size),
                          crop=CAULDRON_POT if geom is POT else CUP_BODY)]},
        {"name": "surface", "z": z + 1, "kind": "flat", "material": liquid, "clip_to": "pot",
         "pieces": [piece("circle", [at[0], rim + 4], [size[0] * 0.82, 30], crop=DISC)]},
        {"name": "rim_light", "z": z + 2, "kind": "flat", "material": "ceramic", "opacity": 0.5,
         "clip_to": "pot",
         "pieces": [piece("circle", [at[0], rim - 2], [size[0] * 0.9, 8], crop=DISC)]},
        {"name": "bits", "z": z + 3, "clip_to": "surface", "pieces": bits},
    ]
    if scum:
        forms.append({"name": "scum", "z": z + 4, "kind": "flat", "material": scum, "opacity": 0.5,
                      "clip_to": "surface",
                      "pieces": [piece("circle", [at[0], rim + 12], [size[0] * 0.8, 20], crop=DISC)]})
    if bubbles:
        forms.append({"name": "bubbles", "z": z + 5, "kind": "flat", "material": "bubble",
                      "opacity": 0.55, "clip_to": "surface",
                      "pieces": [piece("circle", [at[0] - 18, rim - 1], [12, 8], crop=DISC),
                                 piece("circle", [at[0] + 16, rim + 6], [10, 7], crop=DISC),
                                 piece("circle", [at[0] - 2, rim + 11], [9, 6], crop=DISC)]})
    forms.append({"name": "gleam", "z": z + 6, "kind": "flat", "material": "ceramic", "opacity": 0.28,
                  "clip_to": "pot",
                  "pieces": [piece("circle", [at[0] - 26, 66], [22, 40], crop=DISC, rot=-12)]})
    return forms


RECIPES = [
    # ------------------------------------------------------- it_mushroom_stew
    rec("it_mushroom_stew", "cauldron of mushroom stew seen from above-front: dark pot, a "
        "lid tilted on top, brown broth with pale mushroom caps floating. No text.", 3601,
        pot_forms(POT, "ceramic_dark", "stew_brown", [
            piece("cloud", [50, 42], [26, 14], crop=[2.0, 3.0, 14.0, 13.0], rot=12),
            piece("cloud", [76, 47], [22, 12], crop=[2.0, 3.0, 14.0, 13.0], rot=-16),
            piece("circle", [64, 50], [18, 9], crop=DISC, rot=0),
        ], "", 3601, lid=True)),
    # ---------------------------------------------------------- it_rabbit_stew
    rec("it_rabbit_stew", "cauldron of rabbit stew seen from above-front: dark pot, brown "
        "broth with pale chunks, one bone sticking out, small bubbles. No text.", 3602,
        pot_forms(POT, "ceramic_dark", "stew_brown", [
            piece("circle", [48, 45], [22, 13], crop=DISC, rot=14),
            piece("circle", [74, 42], [18, 11], crop=DISC, rot=-12),
            piece("cloud", [60, 53], [26, 13], crop=[2.0, 3.0, 14.0, 13.0], rot=-8),
        ], "", 3602, bone=([96, 40], [44, 44], -26), bubbles=True)),
    # --------------------------------------------------------- it_beetroot_soup
    rec("it_beetroot_soup", "bowl of beetroot soup seen from above-front: grey bowl, dark red "
        "broth, two pale croutons, a beet slice leaning on the rim. No text.", 3603,
        pot_forms(BOWL, "ceramic", "stew_red", [
            piece("circle", [50, 40], [22, 12], crop=DISC, rot=10),
            piece("circle", [72, 45], [18, 10], crop=DISC, rot=-14),
        ], "", 3603, scum="moldy") + [
            {"name": "beet_slice", "z": 8, "material": "beet",
             "shade": {"bump": 1.0, "highlight_amount": 0.45},
             "pieces": [piece("circle", [90, 44], [30, 26], crop=DISC, rot=16)]},
            {"name": "beet_ring", "z": 9, "kind": "flat", "material": "beet_pale", "opacity": 0.85,
             "clip_to": "beet_slice",
             "pieces": [piece("circle", [90, 44], [20, 17], crop=DISC)]},
            {"name": "beet_core", "z": 10, "kind": "flat", "material": "beet", "opacity": 0.9,
             "clip_to": "beet_slice",
             "pieces": [piece("circle", [90, 44], [9, 8], crop=DISC)]},
        ]),
    # -------------------------------------------------------- it_suspicious_stew
    rec("it_suspicious_stew", "bowl of something unnameable seen from above-front: grey bowl, "
        "sickly green-brown liquid, pale lumps and bone fragments, foam bubbles. No text.", 3604,
        pot_forms(BOWL, "ceramic", "stew_green", [
            piece("cloud", [48, 43], [26, 14], crop=[2.0, 3.0, 14.0, 13.0], rot=16),
            piece("circle", [76, 48], [20, 12], crop=DISC, rot=-10),
            piece("bone", [64, 36], [30, 30], crop=BONE_DIAG, rot=200),
        ], "", 3604, scum="moldy", bubbles=True) + [
            {"name": "scrap", "z": 8, "material": "bone_white", "opacity": 0.95,
             "pieces": [piece("bone", [98, 30], [34, 34], crop=BONE_DIAG, rot=-30)]},
            {"name": "eye", "z": 9, "kind": "flat", "material": "bubble", "opacity": 0.4,
             "clip_to": "surface",
             "pieces": [piece("circle", [64, 44], [16, 10], crop=DISC)]},
        ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
