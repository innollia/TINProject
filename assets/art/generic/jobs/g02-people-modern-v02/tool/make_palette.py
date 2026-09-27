"""Make palette_g02.json: palette_h0_mood.json (V1) + g02 people / genre materials.

    py -3 -B make_palette.py            # writes ../recipes/palette_g02.json

Ink, shadow, grime and the three styles are copied from V1 unchanged.  New
materials only add base colours; shadow / light / line are derived with the
same ratios V1 uses for coat and leather (shadow ~0.63x, light ~1.4x, line =
shadow pushed to ink), so the overall value stays at V1 level.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]

CLOTH_TEX = {"stamp": "feather", "pre_rot": -45, "length": 11, "width": 2.5, "angle": 88,
             "jitter": 10, "density": 0.8, "strength": 0.08}
CLOTH_GRIME = {"stamps": ["cloud", "metaballs"], "size": 12, "soft": 1.5, "density": 0.2,
               "strength": 0.13, "color": "grime"}
METAL_GRIME = {"stamps": ["metaballs", "sponge"], "size": 14, "soft": 1.2, "density": 0.3,
               "strength": 0.24, "color": "rust"}
HAIR_TEX = {"stamp": "feather", "pre_rot": -45, "length": 9, "width": 2.2, "angle": 70,
            "jitter": 25, "density": 0.9, "strength": 0.10}

# name: (base, kind)   kind: cloth | leather | metal | hair | skin | plain | glow | glass
TABLE = {
    "skin_pale": ("#d8c4b8", "skin"), "skin_tan": ("#b88e72", "skin"), "skin_dark": ("#7e5a47", "skin"),
    "skin_clown": ("#d9d2cc", "skin"),
    "hair_brown": ("#4e3a2e", "hair"), "hair_grey": ("#7d7880", "hair"), "hair_white": ("#b3adb2", "hair"),
    "hair_blond": ("#9a8354", "hair"), "hair_red": ("#6e3829", "hair"), "hair_black": ("#1f1a20", "hair"),
    "hair_magenta": ("#7a3a6e", "hair"), "hair_cyan": ("#3a6a70", "hair"),
    "cloth_black": ("#2a2530", "cloth"), "cloth_navy": ("#2b3247", "cloth"), "cloth_blue": ("#3a4862", "cloth"),
    "cloth_sky": ("#56687e", "cloth"), "cloth_red": ("#7a3440", "cloth"), "cloth_crimson": ("#6a2a2c", "cloth"),
    "cloth_brown": ("#5a4535", "cloth"), "cloth_tan": ("#86704f", "cloth"), "cloth_olive": ("#4d5037", "cloth"),
    "cloth_green": ("#3b4c3b", "cloth"), "cloth_teal": ("#34504e", "cloth"), "cloth_purple": ("#4a3857", "cloth"),
    "cloth_grey": ("#5c5761", "cloth"), "cloth_white": ("#a8a29a", "cloth"), "cloth_cream": ("#b0a283", "cloth"),
    "cloth_mustard": ("#86703d", "cloth"), "cloth_orange": ("#8a5230", "cloth"), "cloth_pink": ("#8a5b64", "cloth"),
    "cloth_khaki": ("#6e694e", "cloth"), "cloth_ice": ("#8c9aa6", "cloth"), "cloth_rust": ("#7a4630", "cloth"),
    "fur": ("#8e857c", "cloth"), "fur_white": ("#b9b2aa", "cloth"), "straw": ("#8a7a4c", "cloth"),
    "rope": ("#7a6848", "cloth"),
    "leather_dark": ("#2f2521", "leather"), "leather_red": ("#5a2e2a", "leather"), "leather_tan": ("#6e5236", "leather"),
    "rubber": ("#2c2e33", "leather"),
    "steel": ("#6a6e79", "metal"), "gold": ("#95773a", "metal"), "silver": ("#8c8c97", "metal"),
    "brass": ("#86672f", "metal"), "iron_dark": ("#2e3036", "metal"), "chrome": ("#7f8794", "metal"),
    "bone": ("#b5aa94", "plain"), "blood_dark": ("#3e1a1e", "plain"), "mouth": ("#4a2a2a", "plain"),
    "lip": ("#7a4448", "plain"), "blush": ("#b0786e", "plain"), "white_ink": ("#c9c1b4", "plain"),
    "shade_face": ("#1a141e", "plain"), "tooth": ("#c8bfae", "plain"),
    "neon_cyan": ("#46c9d2", "glow"), "neon_magenta": ("#c9469f", "glow"), "neon_green": ("#7ad24a", "glow"),
    "neon_amber": ("#e0a040", "glow"), "plasma": ("#8fc8ff", "glow"), "rad_green": ("#a8d84a", "glow"),
    "ember_red": ("#d8503a", "glow"),
    "visor": ("#3f5a66", "glass"), "visor_gold": ("#8a7340", "glass"), "lens": ("#5d6f73", "glass"),
}


def hex_rgb(h):
    h = h.lstrip("#")
    return [int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]


def rgb_hex(c):
    return "#" + "".join(f"{max(0, min(255, round(v * 255))):02x}" for v in c)


def lerp(a, b, t):
    return [x + (y - x) * t for x, y in zip(a, b)]


def derive(base_hex, kind):
    b = hex_rgb(base_hex)
    ink = hex_rgb("#0f0a11")
    plum = [0.10, 0.07, 0.12]
    shadow = lerp([v * 0.64 for v in b], plum, 0.12)
    light = [v * 1.36 + 0.01 if v * 1.36 < 0.92 else v + (1 - v) * 0.3 for v in b]
    mat = {"base": base_hex, "shadow": rgb_hex(shadow), "light": rgb_hex(light),
           "line": rgb_hex(lerp(shadow, ink, 0.7))}
    if kind == "cloth":
        mat["texture"] = dict(CLOTH_TEX)
        mat["grime"] = dict(CLOTH_GRIME)
    elif kind == "hair":
        mat["texture"] = dict(HAIR_TEX)
    elif kind == "skin":
        mat["shadow"] = rgb_hex([v * 0.78 for v in b])
        mat["light"] = rgb_hex([v + (1 - v) * 0.25 for v in b])
        mat["line"] = rgb_hex(lerp([v * 0.5 for v in b], ink, 0.35))
        mat["shade"] = {"threshold": 0.5, "highlight_amount": 0.3, "ragged": 0.05, "edge": 0.05}
    elif kind == "metal":
        mat["shade"] = {"highlight": 0.86, "highlight_amount": 0.6}
        mat["grime"] = dict(METAL_GRIME)
        mat["side"], mat["side_shadow"] = mat["shadow"], rgb_hex([v * 0.5 for v in b])
    elif kind == "leather":
        mat["grime"] = dict(CLOTH_GRIME, strength=0.18)
    elif kind == "glow":
        mat = {"base": base_hex, "light": rgb_hex([v + (1 - v) * 0.5 for v in b])}
    elif kind == "glass":
        mat["shade"] = {"threshold": 0.4, "highlight_amount": 0.7, "highlight": 0.88}
    elif kind == "plain":
        mat = {"base": base_hex, "line": rgb_hex(lerp(shadow, ink, 0.7))}
    return mat


def main() -> int:
    src = JOB / "recipes" / "palette_h0_mood.json"
    pal = json.loads(src.read_text(encoding="utf-8"))
    out = copy.deepcopy(pal)
    out["id"] = "palette_g02"
    out["source"] = ("g02 generic assets. palette_h0_mood (V1) unchanged + materials added by "
                     "tool/make_palette.py (same shadow/light/line ratios as V1 coat/leather).")
    for name, (base, kind) in TABLE.items():
        out["materials"][name] = derive(base, kind)
    # people read at 2x (portraits): calmer shading boundary on V1 skin, lighter grime on V1 cloth
    out["materials"]["skin"]["shade"] = {"threshold": 0.5, "highlight_amount": 0.3, "ragged": 0.05, "edge": 0.05}
    for name in ("coat", "cloth_wine"):
        out["materials"][name]["grime"] = dict(CLOTH_GRIME)
    out["materials"]["bronze"]["grime"] = dict(METAL_GRIME)
    out["materials"]["iron"]["grime"] = dict(METAL_GRIME)
    out["colors"].update({"grime_dark": "#4a4232", "neon_glow_c": "#7fe6ee", "neon_glow_m": "#ee7fcc",
                          "white_ink": "#c9c1b4", "shade_face": "#1a141e", "rad_glow": "#c8f07a",
                          "plasma_glow": "#b8dcff", "ember_red_glow": "#ff7a5c"})
    path = JOB / "recipes" / "palette_g02.json"
    path.write_text(json.dumps(out, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(path, len(out["materials"]), "materials")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
