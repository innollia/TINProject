"""Shared recipe builder for the props-v02 loot / dye / brewing job."""

import json
import pathlib

JOB = pathlib.Path(__file__).resolve().parents[1]
REC = JOB / "recipes"

# Frozen job rules (AGENTS/JOB brief): inventory icon, no contact-shadow form.
CANVAS = [128, 128]
PIVOT = [64, 64]
STYLE = "prop"
PALETTE = "palette_props.json"
PIVOT_MEANING = "centre of the item inside the inventory cell"

# Measured crops of the three lobes of the `metaballs` icon (see preview/g5.png):
#   big   x 4..11.5  y 0.5..8      -> a near-round 10x9 lobe
#   mid   x 0..6.5   y 8..16       -> a lower-left 7x9 lobe
#   small x 8.5..13  y 10.5..15.5  -> a 6x6 lobe
MB_BIG = [3, 0, 13, 9]
MB_MID = [0, 7, 7, 16]
MB_SML = [8, 10, 14, 16]
# One wavy stripe out of the `sea` icon (3 stacked waves, this is the top one).
SEA_BAND = [0, 0, 16, 6]


def base(asset: str, seed: int, note: str) -> dict:
    return {
        "asset": asset,
        "status": "candidate",
        "note": note,
        "palette": PALETTE,
        "style": STYLE,
        "canvas": list(CANVAS),
        "pivot": list(PIVOT),
        "pivot_meaning": PIVOT_MEANING,
        "seed": seed,
        "forms": [],
    }


def form(name: str, material: str, z: float, pieces: list, **kw) -> dict:
    f = {"name": name, "z": z, "material": material, "pieces": pieces}
    f.update(kw)
    return f


def write(recipe: dict) -> pathlib.Path:
    p = REC / f"{recipe['asset']}.json"
    p.write_text(json.dumps(recipe, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return p


def write_all(recipes: list) -> None:
    for r in recipes:
        print(write(r).name)
