"""Recipe writer for bs2-equipment-v01.  Emits the JSON files that tool/build.py eats.

Nothing here paints anything; every coordinate is hand-authored in the group files.
Only the boilerplate (palette/style/canvas/pivot/status) is factored out.
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(r"C:\projects\TINProject\assets\art\generic\jobs\bs2-equipment-v01")
RECIPES = JOB / "recipes"

SQUARE = [512, 512, [256, 256]]
DOC = [1024, 1024, [512, 512]]

_seed = {"n": 100}


def p(icon, at, size, **kw):
    piece = {"icon": icon, "at": list(at), "size": list(size)}
    piece.update(kw)
    return piece


def wash(name, pieces, material="rust", opacity=0.65, clip=None, z=9.0, rot_blend=None):
    form = {"name": name, "z": z, "kind": "wash", "material": material,
            "blend": rot_blend or "multiply", "opacity": opacity, "line": False,
            "pieces": pieces}
    if clip:
        form["clip_to"] = clip
    return form


def stain(pieces, material="grime", opacity=0.4, clip=None, z=9.2):
    """Soft dirt that is not coloured rust - damp, soot, handling marks."""
    return wash("dirt_" + material, pieces, material=material, opacity=opacity,
                clip=clip, z=z)


def etch(name, pieces, material="stone_cap", opacity=0.55, clip=None, z=8.5):
    """Flat dark inlay: engraved marks, lettering holes, empty photo fields."""
    form = {"name": name, "z": z, "kind": "flat", "material": material,
            "opacity": opacity, "line": False, "pieces": pieces}
    if clip:
        form["clip_to"] = clip
    return form


def patina(pieces, material="rust", opacity=0.6, clip=None, z=9.0):
    return wash("patina", pieces, material=material, opacity=opacity, clip=clip, z=z)


def write(asset, forms, note, geom=SQUARE, style="prop", seed=None):
    canvas, pivot, pv = geom
    if seed is None:
        _seed["n"] += 1
        seed = _seed["n"]
    data = {
        "asset": asset,
        "status": "candidate",
        "note": note,
        "palette": "palette_h0_mood.json",
        "style": style,
        "canvas": list(canvas),
        "pivot": list(pivot),
        "pivot_meaning": "centre",
        "seed": seed,
        "forms": forms,
    }
    RECIPES.mkdir(parents=True, exist_ok=True)
    (RECIPES / f"{asset}.json").write_text(
        json.dumps(data, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    return asset


def write_all(items):
    for asset, forms, note in items:
        write(asset, forms, note)
    print(f"wrote {len(items)} recipes -> {RECIPES}")


# ---------------------------------------------------------------- shared looks
def iron_tarnish(clip, spots=((300, 210, 150, 110), (360, 150, 90, 70), (200, 300, 130, 95))):
    """The house rust pass every iron thing in this job gets."""
    pieces = []
    for i, (x, y, w, h) in enumerate(spots):
        pieces.append(p(["cloud", "metaballs", "droplet", "sponge"][i % 4], [x, y], [w, h],
                        **({"flip": "x"} if i % 2 else {})))
    return patina(pieces, "rust", 0.62, clip=clip)


def damp_stains(clip, spots=((180, 330, 150, 90), (350, 180, 120, 80))):
    pieces = [p("cloud" if i % 2 == 0 else "metaballs", [x, y], [w, h]) for i, (x, y, w, h) in enumerate(spots)]
    return stain(pieces, "damp", 0.3, clip=clip)


def soot(clip, spots=((300, 250, 160, 120),)):
    return stain([p("cloud", [x, y], [w, h]) for x, y, w, h in spots], "soot", 0.45, clip=clip, z=9.3)
