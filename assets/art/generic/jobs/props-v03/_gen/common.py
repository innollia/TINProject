"""Shared recipe helpers for props-v03 food recipes.

Crop boxes were read off preview/g1.png and preview/g2.png (0..16 icon grid) and
verified with recipes/_scratch.json.  Rule of thumb: a circle crop clips its own
corners into a rounded square, so discs use the near-full 0.4..15.6 box.
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
OUT = JOB / "recipes"

BASE = {
    "palette": "palette_props.json",
    "style": "prop",
    "style_override": {"cast": False},
    "canvas": [128, 128],
    "pivot": [64, 64],
    "pivot_meaning": "centre of the 128px inventory cell",
}

# --- cut boxes -----------------------------------------------------------------
DISC = [0.4, 0.4, 15.6, 15.6]        # clean circle
LEAF = [2.2, 4.4, 13.8, 11.6]        # wide leaf lens with vein
LEAF_FULL = [1.0, 1.0, 15.0, 15.0]   # full almond leaf
LEAF_TIP = [3.0, 6.0, 13.0, 10.5]    # narrow leaf tip
APPLE_BODY = [1.6, 4.2, 14.4, 16.0]
APPLE_STEM = [7.2, 0.2, 10.8, 5.4]
SPROUT_TOP = [2.0, 0.4, 14.0, 8.0]
STEM_TAPER = [5.6, 1.0, 10.4, 16.0]
CLOUD = [1.4, 2.6, 14.6, 13.4]
PRISM = [1.0, 0.8, 13.0, 15.4]
DROPLET = [3.4, 0.8, 12.6, 15.2]
DROP_SEED = [3.0, 4.0, 13.0, 15.2]   # droplet with the pointed tip removed
CONE = [3.0, 0.6, 13.0, 15.2]
GRASS = [2.6, 3.0, 14.0, 15.6]
CYL_BODY = [1.2, 5.0, 14.8, 15.6]    # cylinder without the lid rim
SPHERE_NOTCH = [0.4, 0.4, 15.6, 15.6]
FISH_BODY = [2.4, 3.2, 14.8, 11.8]
FISH_TAIL = [0.0, 3.4, 3.6, 11.6]
MEAT_ROUND = [3.4, 0.2, 14.6, 8.4]   # drumstick head
MEAT_BONE = [0.0, 6.6, 7.0, 15.4]   # drumstick handle end
BONE_H = [0.4, 4.0, 15.6, 12.0]
BONE_DIAG = [3.0, 3.0, 13.0, 13.0]
CAULDRON_POT = [1.8, 6.0, 14.2, 15.8]
CAULDRON_LID = [1.4, 4.2, 14.6, 6.4]
CUP_BODY = [1.4, 1.2, 12.4, 11.8]
POULTRY_ROUND = [3.2, 0.4, 13.4, 9.4]
BONE_DIAG = [2.5, 0.5, 13.5, 15.5]
CYL_LID = [1.0, 0.2, 15.0, 7.0]


def piece(icon, at, size, **kw) -> dict:
    out = {"icon": icon, "at": list(at), "size": list(size)}
    out.update({k: v for k, v in kw.items() if v is not None})
    return out


def rec(asset: str, note: str, seed: int, forms: list) -> dict:
    out = dict(BASE)
    out.update({"asset": asset, "note": note, "seed": seed, "forms": forms})
    return out


def write(recipes) -> int:
    for r in recipes:
        path = OUT / f"{r['asset']}.json"
        path.write_text(json.dumps(r, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print("wrote", path.name)
    return 0
