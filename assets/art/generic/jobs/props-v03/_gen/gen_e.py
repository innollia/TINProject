"""Recipes: 7. baking (4 assets).

Run from the job folder:  py -3 -B _gen\\gen_e.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import CLOUD, CYL_BODY, CYL_LID, DISC, STEM_TAPER, piece, rec, write  # noqa: E402

# 72-degree circular sector, apex at the bottom centre of the icon box
CAKE_SECTOR = [[8.0, 16.0, 16.0, 5.0], [0.0, 5.0, 8.0, 16.0]]

RECIPES = [
    # ----------------------------------------------------------------- it_bread
    rec("it_bread", "round country loaf seen from the front: browned domed top, squared "
        "base, three diagonal score marks, darker crust along the bottom. No text.", 3501, [
        {"name": "base", "z": 0, "material": "bread", "shade": {"bump": 1.0, "highlight_amount": 0.35},
         "grad": {"to": "pastry_dark", "y0": 78, "y1": 112, "amount": 0.45},
         "pieces": [piece("cylinder", [64, 90], [90, 34], crop=CYL_BODY)]},
        {"name": "dome", "z": 1, "material": "bread", "rough": {"amp": 0.3, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "pieces": [piece("cloud", [64, 64], [100, 76], crop=CLOUD)]},
        {"name": "scores", "z": 2, "kind": "flat", "material": "bread_score", "opacity": 0.8,
         "clip_to": "dome",
         "pieces": [piece("droplet", [44, 54], [34, 13], crop=STEM_TAPER, rot=-38),
                    piece("droplet", [64, 44], [34, 13], crop=STEM_TAPER, rot=-38),
                    piece("droplet", [84, 54], [34, 13], crop=STEM_TAPER, rot=-38)]},
        {"name": "crust", "z": 3, "kind": "flat", "material": "pastry_dark", "opacity": 0.4,
         "clip_to": "dome",
         "pieces": [piece("circle", [64, 100], [92, 26], crop=DISC)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": "crumb", "opacity": 0.3,
         "clip_to": "dome",
         "pieces": [piece("circle", [46, 44], [40, 16], crop=DISC, rot=-18)]},
    ]),
    # ---------------------------------------------------------------- it_cookie
    rec("it_cookie", "round cookie seen at a slight angle: browned top, a darker edge "
        "showing its thickness, dark chips and a few pale grains. No text.", 3502, [
        {"name": "edge", "z": 0, "material": "pastry_dark", "rough": {"amp": 0.35, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "pieces": [piece("circle", [64, 74], [92, 72], crop=DISC)]},
        {"name": "top", "z": 1, "material": "cookie", "rough": {"amp": 0.35, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "pieces": [piece("circle", [64, 62], [92, 70], crop=DISC)]},
        {"name": "chips", "z": 2, "kind": "flat", "material": "cookie_chip", "opacity": 0.9,
         "clip_to": "top",
         "pieces": [piece("circle", [42, 54], [17, 14], crop=DISC),
                    piece("circle", [66, 44], [15, 12], crop=DISC),
                    piece("circle", [86, 58], [18, 15], crop=DISC),
                    piece("circle", [56, 72], [16, 13], crop=DISC),
                    piece("circle", [78, 78], [14, 12], crop=DISC),
                    piece("circle", [34, 76], [13, 11], crop=DISC)]},
        {"name": "grains", "z": 3, "kind": "flat", "material": "crumb", "opacity": 0.6,
         "clip_to": "top",
         "pieces": [piece("circle", [50, 48], [7, 5], crop=DISC),
                    piece("circle", [74, 52], [6, 5], crop=DISC),
                    piece("circle", [62, 84], [7, 5], crop=DISC)]},
        {"name": "gleam", "z": 4, "kind": "flat", "material": "crumb", "opacity": 0.3,
         "clip_to": "top",
         "pieces": [piece("circle", [46, 46], [34, 14], crop=DISC, rot=-16)]},
    ]),
    # ------------------------------------------------------------------- it_cake
    rec("it_cake", "wedge of cake seen from the front: pale sponge wedge, two darker sponge "
        "bands, cream filling, a thick frosting top and one dark berry. No text.", 3503, [
        {"name": "wedge", "z": 0, "material": "cake_crumb", "shade": {"bump": 1.0, "highlight_amount": 0.45},
         "pieces": [piece("circle", [64, 66], [94, 96], keep=CAKE_SECTOR)]},
        {"name": "sponge1", "z": 1, "kind": "flat", "material": "cake_sponge", "opacity": 0.75,
         "clip_to": "wedge",
         "pieces": [piece("droplet", [64, 48], [88, 22], crop=STEM_TAPER)]},
        {"name": "cream1", "z": 2, "kind": "flat", "material": "cake_top", "opacity": 0.85,
         "clip_to": "wedge",
         "pieces": [piece("droplet", [64, 70], [82, 16], crop=STEM_TAPER)]},
        {"name": "sponge2", "z": 3, "kind": "flat", "material": "cake_sponge", "opacity": 0.6,
         "clip_to": "wedge",
         "pieces": [piece("droplet", [64, 90], [64, 16], crop=STEM_TAPER)]},
        {"name": "frosting", "z": 4, "kind": "flat", "material": "cake_top",
         "clip_to": "wedge",
         "pieces": [piece("circle", [64, 34], [88, 30], crop=DISC)]},
        {"name": "frost_edge", "z": 5, "kind": "flat", "material": "crumb", "opacity": 0.4,
         "clip_to": "wedge",
         "pieces": [piece("circle", [64, 26], [80, 12], crop=DISC)]},
        {"name": "berry", "z": 6, "material": "berry", "shade": {"bump": 1.0, "highlight_amount": 0.5},
         "pieces": [piece("circle", [64, 20], [20, 18], crop=DISC)]},
    ]),
    # ----------------------------------------------------------- it_pumpkin_pie
    rec("it_pumpkin_pie", "round pumpkin pie in a dark tin seen from the front: dull golden "
        "crust rim, dark orange filling, four pale lattice strips. No text.", 3504, [
        {"name": "tin", "z": 0, "material": "pastry_dark", "shade": {"bump": 1.0, "highlight_amount": 0.4},
         "grad": {"to": "soot", "y0": 92, "y1": 118, "amount": 0.4},
         "pieces": [piece("cylinder", [64, 92], [96, 46], crop=CYL_BODY)]},
        {"name": "crust", "z": 1, "material": "pie_crust", "rough": {"amp": 0.35, "soft": 1.0, "cell": 7},
         "shade": {"bump": 1.05, "highlight_amount": 0.45},
         "pieces": [piece("circle", [64, 64], [104, 58], crop=DISC)]},
        {"name": "fill", "z": 2, "material": "pie_fill", "clip_to": "crust",
         "shade": {"bump": 0.9, "highlight_amount": 0.35},
         "pieces": [piece("circle", [64, 62], [80, 40], crop=DISC)]},
        {"name": "lattice", "z": 3, "kind": "flat", "material": "pie_crust", "clip_to": "crust",
         "pieces": [piece("droplet", [46, 62], [72, 9], crop=STEM_TAPER, rot=-24),
                    piece("droplet", [46, 62], [72, 9], crop=STEM_TAPER, rot=24),
                    piece("droplet", [46, 62], [72, 8], crop=STEM_TAPER, rot=0)]},
        {"name": "rim_gleam", "z": 4, "kind": "flat", "material": "pie_crust", "opacity": 0.5,
         "clip_to": "crust",
         "pieces": [piece("circle", [64, 40], [96, 12], crop=DISC)]},
        {"name": "gleam", "z": 5, "kind": "flat", "material": "crumb", "opacity": 0.3,
         "clip_to": "crust",
         "pieces": [piece("circle", [42, 40], [36, 12], crop=DISC, rot=-14)]},
    ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
