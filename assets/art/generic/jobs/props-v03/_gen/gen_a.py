"""Recipes: 3. fruit and berries (5 assets).

Run from the job folder:  py -3 -B _gen\\gen_a.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import (APPLE_BODY, APPLE_STEM, DISC, DROP_SEED, LEAF, SPROUT_TOP,  # noqa: E402
                    STEM_TAPER, piece, rec, write)

# 90-degree circular sector with the apex at the bottom centre of the icon box
# (keep is a flat [ax, ay, bx, by] half-plane per line, intersected)
SECTOR = [[8.0, 16.0, 16.0, 7.5], [0.0, 7.5, 8.0, 16.0]]

RECIPES = [
    # ------------------------------------------------------------------ it_apple
    rec("it_apple", "apple, three-quarter from slightly above: two-lobed body, sunken stem "
        "well, short woody stem, one leaf. No text.", 3101, [
        {"name": "leaf", "z": 0, "material": "carrot_top",
         "pieces": [piece("leaf", [38, 34], [48, 30], crop=LEAF, rot=-42)]},
        {"name": "stem", "z": 1, "material": "wood",
         "pieces": [piece("apple", [67, 33], [18, 32], crop=APPLE_STEM, rot=8)]},
        {"name": "body", "z": 2, "material": "apple",
         "shade": {"bump": 1.15, "highlight_amount": 0.45},
         "pieces": [piece("apple", [64, 72], [98, 90], crop=APPLE_BODY)]},
        {"name": "well", "z": 3, "kind": "flat", "material": "apple_blush", "opacity": 0.5,
         "clip_to": "body",
         "pieces": [piece("circle", [64, 46], [20, 13], crop=DISC)]},
        {"name": "blush", "z": 4, "kind": "flat", "material": "apple_blush", "opacity": 0.34,
         "clip_to": "body",
         "pieces": [piece("circle", [86, 86], [36, 32], crop=DISC)]},
        {"name": "gleam", "z": 5, "kind": "flat", "material": "melon_pale", "opacity": 0.42,
         "clip_to": "body",
         "pieces": [piece("circle", [45, 58], [24, 14], crop=DISC, rot=-32)]},
    ]),
    # ------------------------------------------------------------ it_melon_slice
    rec("it_melon_slice", "watermelon wedge seen from the front: dark green rind, pale "
        "rind ring, muted red flesh, five dark seeds. No text.", 3102, [
        {"name": "rind", "z": 0, "material": "melon_rind",
         "shade": {"bump": 1.1, "highlight_amount": 0.4},
         "pieces": [piece("circle", [64, 66], [104, 100], keep=SECTOR)]},
        {"name": "ring", "z": 1, "material": "melon_pale",
         "pieces": [piece("circle", [64, 66], [88, 84], keep=SECTOR)]},
        {"name": "flesh", "z": 2, "material": "melon_flesh", "clip_to": "ring",
         "shade": {"bump": 0.9, "highlight_amount": 0.35},
         "pieces": [piece("circle", [64, 66], [74, 70], keep=SECTOR)]},
        {"name": "fibres", "z": 3, "kind": "flat", "material": "melon_pale", "opacity": 0.4,
         "clip_to": "flesh",
         "pieces": [piece("droplet", [46, 62], [8, 28], crop=STEM_TAPER, rot=20),
                    piece("droplet", [82, 64], [8, 26], crop=STEM_TAPER, rot=-14)]},
        {"name": "seeds", "z": 4, "material": "melon_seed", "clip_to": "flesh",
         "pieces": [piece("droplet", [50, 42], [10, 12], crop=DROP_SEED, rot=168),
                    piece("droplet", [64, 36], [10, 12], crop=DROP_SEED, rot=180),
                    piece("droplet", [78, 43], [10, 12], crop=DROP_SEED, rot=192),
                    piece("droplet", [57, 57], [10, 12], crop=DROP_SEED, rot=172),
                    piece("droplet", [71, 58], [10, 12], crop=DROP_SEED, rot=188)]},
    ]),
    # ---------------------------------------------------------- it_sweet_berry
    rec("it_sweet_berry", "three small dark berries clustered on one short stem, the front "
        "one paler, with a single leaf. No text.", 3103, [
        {"name": "leaf", "z": 0, "material": "carrot_top",
         "pieces": [piece("leaf", [86, 40], [42, 26], crop=LEAF, rot=-18)]},
        {"name": "stem", "z": 1, "material": "wood",
         "pieces": [piece("apple", [61, 36], [14, 28], crop=APPLE_STEM, rot=-12)]},
        {"name": "b1", "z": 2, "material": "berry",
         "shade": {"bump": 1.1, "highlight_amount": 0.45},
         "pieces": [piece("circle", [47, 83], [58, 56], crop=DISC)]},
        {"name": "b2", "z": 3, "material": "berry",
         "pieces": [piece("circle", [88, 87], [46, 44], crop=DISC)]},
        {"name": "b3", "z": 4, "material": "berry_pale",
         "shade": {"bump": 1.0, "highlight_amount": 0.5},
         "pieces": [piece("circle", [69, 60], [40, 38], crop=DISC)]},
        {"name": "gleam", "z": 5, "kind": "flat", "material": "melon_pale", "opacity": 0.5,
         "clip_to": "b3",
         "pieces": [piece("circle", [60, 51], [18, 10], crop=DISC, rot=-30)]},
        {"name": "gleam2", "z": 6, "kind": "flat", "material": "berry_pale", "opacity": 0.5,
         "clip_to": "b1",
         "pieces": [piece("circle", [37, 70], [17, 10], crop=DISC, rot=-30)]},
    ]),
    # ----------------------------------------------------------- it_glow_berry
    rec("it_glow_berry", "one round berry with a faint cold sheen: emissive body, soft pale "
        "halo, dull green sepal, thin stem, three drifting motes. No text.", 3104, [
        {"name": "motes", "z": 0, "material": "glow_berry", "opacity": 0.55,
         "pieces": [piece("circle", [22, 48], [8, 8], crop=DISC),
                    piece("circle", [106, 38], [7, 7], crop=DISC),
                    piece("circle", [111, 68], [6, 6], crop=DISC)]},
        {"name": "sepal", "z": 1, "material": "kelp_pale",
         "pieces": [piece("sprout", [64, 40], [50, 24], crop=SPROUT_TOP)]},
        {"name": "stem", "z": 2, "material": "wood",
         "pieces": [piece("droplet", [64, 27], [14, 32], crop=STEM_TAPER, rot=8)]},
        {"name": "body", "z": 3, "material": "glow_berry", "emit": 0.4,
         "glow": {"radius": 10, "opacity": 0.16, "color": "glow_soft"},
         "shade": {"bump": 1.0, "highlight_amount": 0.5},
         "grad": {"to": "soot", "y0": 58, "y1": 116, "amount": 0.45},
         "pieces": [piece("circle", [64, 76], [86, 82], crop=DISC)]},
        {"name": "core", "z": 4, "kind": "flat", "material": "chorus_pale", "opacity": 0.3,
         "clip_to": "body",
         "pieces": [piece("circle", [54, 66], [38, 36], crop=DISC)]},
        {"name": "gleam", "z": 5, "kind": "flat", "material": "glow_soft", "opacity": 0.5,
         "clip_to": "body",
         "pieces": [piece("circle", [46, 56], [24, 13], crop=DISC, rot=-30)]},
    ]),
    # ---------------------------------------------------------- it_chorus_fruit
    rec("it_chorus_fruit", "knobbly three-lobed pale fruit, each lobe dimpled, on a short "
        "stem with a leaf. No text.", 3105, [
        {"name": "leaf", "z": 0, "material": "carrot_top",
         "pieces": [piece("leaf", [90, 32], [44, 28], crop=LEAF, rot=16)]},
        {"name": "stem", "z": 1, "material": "wood",
         "pieces": [piece("apple", [58, 30], [15, 30], crop=APPLE_STEM, rot=16)]},
        {"name": "lobe_l", "z": 2, "material": "chorus",
         "shade": {"bump": 1.1, "highlight_amount": 0.45},
         "pieces": [piece("circle", [40, 62], [44, 42], crop=DISC)]},
        {"name": "lobe_r", "z": 3, "material": "chorus",
         "pieces": [piece("circle", [92, 60], [38, 36], crop=DISC)]},
        {"name": "front", "z": 4, "material": "chorus",
         "shade": {"bump": 1.05, "highlight_amount": 0.4},
         "grad": {"to": "soot", "y0": 76, "y1": 118, "amount": 0.35},
         "pieces": [piece("circle", [64, 86], [70, 62], crop=DISC)]},
        {"name": "dimple", "z": 5, "kind": "flat", "material": "chorus_pale", "opacity": 0.6,
         "clip_to": "front",
         "pieces": [piece("circle", [52, 68], [14, 12], crop=DISC),
                    piece("circle", [78, 72], [12, 11], crop=DISC)]},
        {"name": "gleam", "z": 6, "kind": "flat", "material": "chorus_pale", "opacity": 0.34,
         "clip_to": "front",
         "pieces": [piece("circle", [52, 60], [30, 15], crop=DISC, rot=-26)]},
    ]),
]

if __name__ == "__main__":
    raise SystemExit(write(RECIPES))
