"""Recipes: 5. meat (6 assets). Diagonal cut face, top-left light.

Run from the job folder:  py -3 -B _gen\\gen_c.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import (BONE_DIAG, BONE_H, CLOUD, DISC, DROPLET, MEAT_ROUND,  # noqa: E402
                    POULTRY_ROUND, STEM_TAPER, piece, rec, write)

# a cut-face band drawn across a diagonal piece: flat, clipped to the mass
CUT_BAND = STEM_TAPER


def slab(mass: str, fat: str, marble_mat: str, marble_op=0.34) -> list:
    """Fat cap behind, meat mass, a diagonal cut face band, marbling, a gleam."""
    at, cap, size, rot = (58, 66), (64, 74), (82, 66), -15
    return [
        {"name": "cap", "z": 0, "material": fat, "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("cloud", cap, [size[0] + 2, size[1] + 2], crop=CLOUD, rot=rot)]},
        {"name": "meat", "z": 1, "material": mass, "rough": {"amp": 0.35, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.1, "highlight_amount": 0.45},
         "grad": {"to": "soot", "y0": 74, "y1": 118, "amount": 0.3},
         "pieces": [piece("cloud", at, list(size), crop=CLOUD, rot=rot)]},
        {"name": "cut", "z": 2, "kind": "flat", "material": marble_mat, "opacity": 0.55,
         "clip_to": "meat",
         "pieces": [piece("droplet", [at[0] - 2, at[1] - 12], [size[0] * 0.95, 34],
                          crop=CUT_BAND, rot=rot + 74)]},
        {"name": "mottle", "z": 3, "kind": "flat", "material": marble_mat, "opacity": marble_op,
         "clip_to": "meat",
         "pieces": [piece("sponge", [at[0] + 8, at[1] + 8], [size[0] * 0.5, size[1] * 0.42],
                          rot=rot - 12)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": fat, "opacity": 0.28,
         "clip_to": "meat",
         "pieces": [piece("circle", [at[0] - 16, at[1] - 20], [32, 13], crop=DISC, rot=rot)]},
    ]


RECIPES = [
    # ----------------------------------------------------------------- it_beef
    rec("it_beef", "beef steak seen from the front at a diagonal: dark red mass, a pale fat "
        "cap along the lower edge, a lighter cut face across the middle. No text.", 3301,
        slab("beef", "beef_fat", "beef_marble")),
    # ------------------------------------------------------------- it_porkchop
    rec("it_porkchop", "pork chop at a diagonal: pale pink-grey meat, fat edge, one pale bone "
        "sticking out at the upper right. No text.", 3302,
        slab("pork", "pork", "beef_marble", marble_op=0.3) + [
            {"name": "bone", "z": 5, "material": "bone_white",
             "shade": {"bump": 0.9, "highlight_amount": 0.4},
             "pieces": [piece("bone_horizontal", [92, 40], [50, 24], crop=BONE_H, rot=-14)]},
            {"name": "bone2", "z": 6, "material": "bone_white",
             "pieces": [piece("bone", [30, 88], [30, 30], crop=BONE_DIAG, rot=200)]},
        ]),
    # ---------------------------------------------------------------- it_mutton
    rec("it_mutton", "mutton chop at a diagonal: deep red-brown meat, a diagonal pale bone "
        "across the top right, dull fat edge. No text.", 3303,
        slab("mutton", "beef_fat", "beef_marble", marble_op=0.32) + [
            {"name": "bone", "z": 5, "material": "bone_white",
             "shade": {"bump": 0.9, "highlight_amount": 0.4},
             "pieces": [piece("bone", [90, 42], [46, 46], crop=BONE_DIAG, rot=-24)]},
        ]),
    # --------------------------------------------------------------- it_chicken
    rec("it_chicken", "chicken leg at a diagonal: pale cream-pink drumstick, bone handle "
        "pointing down right, dull fat rim on the meat. No text.", 3304, [
        {"name": "rim", "z": 0, "material": "chicken", "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("poultry", [61, 59], [86, 78], crop=POULTRY_ROUND, rot=-20)]},
        {"name": "meat", "z": 1, "material": "chicken", "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "pastry_dark", "y0": 56, "y1": 100, "amount": 0.3},
         "pieces": [piece("poultry", [58, 56], [84, 74], crop=POULTRY_ROUND, rot=-20)]},
        {"name": "cut", "z": 2, "kind": "flat", "material": "crumb", "opacity": 0.4,
         "clip_to": "meat",
         "pieces": [piece("droplet", [54, 44], [64, 28], crop=CUT_BAND, rot=-20 + 74)]},
        {"name": "bone", "z": 3, "material": "bone_white",
         "shade": {"bump": 0.9, "highlight_amount": 0.4},
         "pieces": [piece("meat", [82, 96], [30, 40], crop=[0.0, 6.6, 7.0, 15.4], rot=-20)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": "bone_white", "opacity": 0.32,
         "clip_to": "meat",
         "pieces": [piece("circle", [48, 38], [30, 14], crop=DISC, rot=-20)]},
    ]),
    # ---------------------------------------------------------------- it_rabbit
    rec("it_rabbit", "rabbit haunch at a diagonal: very pale cream drumstick, long bone "
        "handle pointing down right, small dull fat rim. No text.", 3305, [
        {"name": "rim", "z": 0, "material": "rabbit", "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("meat", [61, 59], [88, 78], crop=MEAT_ROUND, rot=-22)]},
        {"name": "meat", "z": 1, "material": "rabbit", "rough": {"amp": 0.35, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "grad": {"to": "pastry_dark", "y0": 56, "y1": 100, "amount": 0.26},
         "pieces": [piece("meat", [58, 56], [86, 76], crop=MEAT_ROUND, rot=-22)]},
        {"name": "cut", "z": 2, "kind": "flat", "material": "bone_white", "opacity": 0.38,
         "clip_to": "meat",
         "pieces": [piece("droplet", [54, 42], [64, 26], crop=CUT_BAND, rot=-22 + 74)]},
        {"name": "bone", "z": 3, "material": "bone_white",
         "shade": {"bump": 0.9, "highlight_amount": 0.4},
         "pieces": [piece("meat", [84, 100], [28, 44], crop=[0.0, 6.6, 7.0, 15.4], rot=-22)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": "bone_white", "opacity": 0.32,
         "clip_to": "meat",
         "pieces": [piece("circle", [48, 36], [30, 14], crop=DISC, rot=-22)]},
        {"name": "socket", "z": 5, "kind": "flat", "material": "rabbit", "opacity": 0.95,
         "clip_to": "meat",
         "pieces": [piece("circle", [69, 43], [36, 27], crop=DISC, rot=-22)]},
    ]),
    # ---------------------------------------------------------- it_rotten_flesh
    rec("it_rotten_flesh", "rotten flesh: a wet, dark, sagging lump with green mould patches, "
        "darker drips and a pale scrap of bone. Filthy, no text.", 3306, [
        {"name": "mass", "z": 0, "material": "rotten", "rough": {"amp": 0.6, "soft": 1.4, "cell": 7},
         "shade": {"bump": 1.0, "highlight_amount": 0.5},
         "grad": {"to": "soot", "y0": 58, "y1": 118, "amount": 0.5},
         "pieces": [piece("cloud", [64, 68], [96, 78], crop=CLOUD, rot=8)]},
        {"name": "mould", "z": 1, "kind": "flat", "material": "moldy", "opacity": 0.6,
         "clip_to": "mass",
         "pieces": [piece("sponge", [50, 54], [48, 34], rot=20),
                    piece("sponge", [84, 84], [40, 30], rot=-16)]},
        {"name": "drips", "z": 2, "kind": "flat", "material": "wet_dark", "opacity": 0.55,
         "clip_to": "mass",
         "pieces": [piece("droplet", [44, 78], [16, 40], crop=DROPLET, rot=8),
                    piece("droplet", [72, 88], [14, 34], crop=DROPLET, rot=-10),
                    piece("droplet", [92, 62], [12, 30], crop=DROPLET, rot=14)]},
        {"name": "wet", "z": 3, "kind": "flat", "material": "bubble", "opacity": 0.22,
         "clip_to": "mass",
         "pieces": [piece("circle", [46, 56], [30, 16], crop=DISC, rot=-12),
                    piece("circle", [82, 70], [22, 12], crop=DISC, rot=10)]},
        {"name": "scrap", "z": 4, "material": "bone_white", "opacity": 0.9,
         "pieces": [piece("bone", [92, 42], [34, 34], crop=BONE_DIAG, rot=-18)]},
    ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
