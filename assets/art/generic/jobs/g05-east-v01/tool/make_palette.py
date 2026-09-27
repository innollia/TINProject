"""Write recipes/palette_g05.json = V1 palette_h0_mood.json + creature materials.

    py -3 -B make_palette.py

Every V1 colour, material and style is copied unchanged (ink, shadow and the
sprite style are what keep g05 in the shared V1 look).  Only NEW keys are added:
creature skins, furs, scales, chitin, bone, ghost, plant, elemental, metal and
glowing-eye materials, all kept in the V1 value range (bases mostly luma 40-110,
bone and pale skin as the brightest accents like V1 paper/skin).
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
SRC = JOB / "recipes" / "palette_h0_mood.json"
OUT = JOB / "recipes" / "palette_g05.json"

FUR = {"stamp": "feather", "pre_rot": -45, "length": 10, "width": 2.4, "angle": 80, "jitter": 25, "density": 1.0, "strength": 0.12}
FUR_SOFT = dict(FUR, strength=0.08)
SCALES = {"stamp": "leaf", "pre_rot": 45, "length": 7, "width": 3.4, "angle": 0, "jitter": 35, "density": 1.1, "strength": 0.11}
FEATHER = {"stamp": "feather", "pre_rot": -45, "length": 12, "width": 3.0, "angle": 100, "jitter": 15, "density": 0.9, "strength": 0.12}
GRAIN = {"stamp": "pill", "pre_rot": -45, "length": 20, "width": 2.2, "angle": 90, "jitter": 6, "density": 0.9, "strength": 0.12}
CLOTH = {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 3, "angle": 90, "jitter": 10, "density": 0.8, "strength": 0.07}
LEAFY = {"stamp": "leaf", "pre_rot": 45, "length": 9, "width": 4, "angle": 30, "jitter": 60, "density": 1.1, "strength": 0.13}
STONE = {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 3.4, "angle": 0, "jitter": 20, "density": 0.9, "strength": 0.10}

GRIME_SKIN = {"stamps": ["cloud", "metaballs"], "size": 14, "soft": 1.5, "density": 0.25, "strength": 0.22, "color": "grime"}
GRIME_ROT = {"stamps": ["metaballs", "sponge", "cloud"], "size": 16, "soft": 1.5, "density": 0.35, "strength": 0.32, "color": "damp"}
GRIME_BONE = {"stamps": ["sponge", "metaballs"], "size": 10, "soft": 1.0, "density": 0.3, "strength": 0.3, "color": "grime"}
GRIME_RUST = {"stamps": ["metaballs", "sponge"], "size": 14, "soft": 1.0, "density": 0.4, "strength": 0.42, "color": "rust"}
GRIME_MOSS = {"stamps": ["metaballs", "cloud"], "size": 22, "soft": 2.0, "density": 0.35, "strength": 0.35, "color": "damp"}

WET = {"threshold": 0.46, "highlight": 0.84, "highlight_amount": 0.8}
GLOSS = {"highlight": 0.86, "highlight_amount": 0.65}
SKIN = {"threshold": 0.5, "highlight_amount": 0.35}
METAL = {"highlight": 0.85, "highlight_amount": 0.65}


def m(base, shadow, light, line, **kw):
    out = {"base": base, "shadow": shadow, "light": light, "line": line}
    out.update(kw)
    return out


NEW_COLORS = {
    "glow_red_c": "#ff6048",
    "glow_yellow_c": "#ffd468",
    "glow_green_c": "#a8f078",
    "glow_cyan_c": "#98e8f8",
    "glow_violet_c": "#cc98ff",
    "ghost_glow_c": "#b8eef4",
    "mouth_dark": "#240c12",
}

NEW_MATERIALS = {
    # --- skins
    "goblin": m("#5b6a3a", "#3c4726", "#76874d", "#121808", shade=SKIN, grime=GRIME_SKIN),
    "orc": m("#54604a", "#384131", "#6d7a61", "#10140c", shade=SKIN, grime=GRIME_SKIN),
    "troll": m("#4c5c57", "#333f3c", "#64766f", "#0d1312", shade=SKIN, grime=GRIME_MOSS),
    "zombie": m("#65705b", "#465040", "#7e8a73", "#141a10", shade=SKIN, grime=GRIME_ROT),
    "ghoul": m("#5a5663", "#3d3a45", "#736e7c", "#100e14", shade=SKIN, grime=GRIME_ROT),
    "pale": m("#a0949e", "#766a78", "#bbb0b8", "#3a2c38", shade=SKIN),
    "demon": m("#5a282c", "#3b161a", "#763a3e", "#180608", shade=SKIN, grime=GRIME_SKIN),
    "imp": m("#6b3a2a", "#47241a", "#87513c", "#1a0a05", shade=SKIN),
    "indigo": m("#4a4d68", "#30324a", "#636788", "#0c0d18", shade=SKIN, grime=GRIME_SKIN),
    "oni_red": m("#6a3230", "#46201e", "#864644", "#1c0908", shade=SKIN, grime=GRIME_SKIN),
    "corpse_grey": m("#8a9488", "#646d62", "#a3ad9f", "#262c24", shade=SKIN, grime=GRIME_ROT),
    "alien": m("#687276", "#485054", "#838d91", "#111618", shade=SKIN),
    "frog": m("#4d5a36", "#323c22", "#66744a", "#10150a", shade=WET),
    # --- fur / hide
    "fur_grey": m("#4a474d", "#2e2c31", "#635f67", "#0e0c10", texture=FUR),
    "fur_dark": m("#3a3336", "#231e21", "#514749", "#0b0809", texture=FUR),
    "fur_brown": m("#4b372a", "#2f221a", "#654b3a", "#120b07", texture=FUR),
    "fur_tawny": m("#6e5536", "#4a3822", "#8a6d48", "#1a1108", texture=FUR),
    "fur_fox": m("#7a4a2a", "#50301a", "#96603a", "#1c0e05", texture=FUR),
    "fur_white": m("#9a9486", "#706a60", "#b4ae9f", "#2c2822", texture=FUR_SOFT),
    "fur_rat": m("#56504b", "#393431", "#6e6862", "#110e0c", texture=FUR),
    "hide_bat": m("#3a3140", "#241e2a", "#52475a", "#0c090e", texture=FUR_SOFT),
    "hide_pink": m("#8a6a64", "#644a46", "#a4827a", "#281a17", shade=SKIN),
    "membrane": m("#4a3842", "#2f2229", "#614a55", "#0f080b", shade={"soft": 0.2, "bump": 0.7}),
    "membrane_red": m("#4f2a2e", "#331a1d", "#683a3e", "#120506", shade={"soft": 0.2, "bump": 0.7}),
    "membrane_green": m("#3a4236", "#252b22", "#4f5a49", "#090c08", shade={"soft": 0.2, "bump": 0.7}),
    "snout": m("#6a5550", "#4a3a36", "#82696a", "#1a1010", shade=SKIN),
    # --- feathers
    "feather_black": m("#2b2631", "#19151d", "#443c4c", "#08060a", texture=FEATHER),
    "feather_brown": m("#5a4838", "#3a2e23", "#75604c", "#140e08", texture=FEATHER),
    "feather_pale": m("#9a9286", "#6f685f", "#b3ab9e", "#2a2620", texture=FEATHER),
    # --- scales / chitin
    "scale_olive": m("#4c5233", "#31351f", "#666d46", "#0f1108", texture=SCALES),
    "scale_red": m("#5a2a2a", "#3a1818", "#774141", "#160606", texture=SCALES),
    "scale_green": m("#3e4a3a", "#283026", "#55634f", "#0b0f0a", texture=SCALES),
    "scale_teal": m("#344a4c", "#213133", "#4a6466", "#0a1011", texture=SCALES),
    "belly": m("#857a58", "#5e5540", "#a09470", "#2a2416", texture={"stamp": "pill", "pre_rot": -45, "length": 16, "width": 2.2, "angle": 0, "jitter": 3, "density": 0.8, "strength": 0.1}),
    "chitin_black": m("#2e2934", "#1b171f", "#4b4354", "#09070b", shade=GLOSS),
    "chitin_amber": m("#6a4f30", "#44321e", "#8b6b45", "#160e06", shade=GLOSS),
    "chitin_rust": m("#5c2d24", "#3a1b16", "#7a4335", "#140806", shade=GLOSS),
    # --- bone / undead / ghost
    "bone": m("#a39985", "#776e5e", "#bdb49f", "#352d25", grime=GRIME_BONE),
    "bone_old": m("#8c8270", "#655d50", "#a59b87", "#2c251d", grime=GRIME_BONE),
    "ghost": m("#76838e", "#525c67", "#9aa7b0", "#1a2028", shade={"soft": 0.35, "bump": 0.8}),
    "ghost_glow": m("#8fc4cc", "#6a9aa2", "#c8f2f6", "#1a2a2e"),
    # --- plants / fungus
    "moss": m("#4a5637", "#303a23", "#5f6e47", "#0e1208", texture=LEAFY),
    "bark": m("#4a3a2d", "#2e241b", "#604c3b", "#110b07", texture=GRAIN, grime=GRIME_MOSS),
    "leaf": m("#3c4a2e", "#26301d", "#53643f", "#0a0f06", texture=LEAFY),
    "leaf_dark": m("#2f3a26", "#1d2518", "#435236", "#070b05", texture=LEAFY),
    "mushroom_cap": m("#6c3830", "#48231f", "#884c43", "#1a0806"),
    "mushroom_stem": m("#9c907e", "#736958", "#b4a994", "#3a3128", shade=SKIN),
    "spot": m("#b0a58e", "#877e6a", "#c8bea8", "#3a3226"),
    "petal": m("#6e3246", "#4a1f2f", "#8a4a5e", "#1a0810"),
    # --- elements
    "fire_outer": m("#a8482a", "#7a2e18", "#d87038", "#2a0c04"),
    "fire_mid": m("#d06a30", "#a04a20", "#f09048", "#3a1606"),
    "fire_core": m("#ffc060", "#e89a40", "#fff0b8", "#5a3010"),
    "water": m("#3d6570", "#29454e", "#5e8992", "#0b171b", shade=WET),
    "wind": m("#7a8a82", "#56645d", "#9aaba2", "#1a2420"),
    "ice": m("#7a94a4", "#56707e", "#a4bccb", "#16242c", shade=GLOSS),
    "crystal": m("#6a5a8a", "#48395f", "#8c7cb0", "#140e22", shade=GLOSS),
    # --- metal / cloth / objects
    "armor": m("#4b4e58", "#2f3139", "#767a87", "#0c0d11", shade=METAL, grime=GRIME_RUST),
    "armor_dark": m("#34363e", "#212228", "#51545f", "#08090c", shade=METAL, grime=GRIME_RUST),
    "gold": m("#8a7038", "#5e4a22", "#b09250", "#1e1406", shade=METAL, grime=GRIME_RUST),
    "metal_robot": m("#50545e", "#34373f", "#787d8a", "#0c0d10", shade=METAL, grime=GRIME_RUST),
    "paint_yellow": m("#7a6a36", "#54491f", "#978648", "#1a1506", shade=METAL, grime=GRIME_RUST),
    "brass": m("#7c6434", "#54421f", "#a48a4c", "#1a1206", shade=METAL, grime=GRIME_RUST),
    "cloth_rag": m("#4d4538", "#332d24", "#655b4a", "#100c08", texture=CLOTH, grime=GRIME_SKIN),
    "robe_black": m("#29232e", "#18141c", "#3b3342", "#060408", texture=CLOTH),
    "robe_teal": m("#33424a", "#212c32", "#485a63", "#0a1014", texture=CLOTH, grime=GRIME_SKIN),
    "cloth_blue": m("#343c58", "#22283c", "#4a5474", "#0a0c16", texture=CLOTH),
    "horn": m("#675b4b", "#443a2e", "#857763", "#150f09"),
    "tooth": m("#b5aa92", "#877d6a", "#cfc4ac", "#3a3226"),
    "claw": m("#3a3330", "#221d1b", "#5a504b", "#0a0706"),
    "mouth": m("#2a0f15", "#1a080c", "#3c1820", "#0a0305"),
    "tongue": m("#6e3440", "#4a2029", "#88485a", "#1a080c", shade=WET),
    "gem": m("#5a2a4a", "#3a1830", "#8a4a70", "#12060e", shade=GLOSS),
    "eye_white": m("#c2b8a4", "#968c7a", "#dcd2be", "#3a3226", shade={"highlight": 0.88, "highlight_amount": 0.55}),
    "iris": m("#6a3a2a", "#44241a", "#8a5038", "#150805"),
    "tentacle": m("#4f3a50", "#33243a", "#6a4e6c", "#0f0911", shade=WET),
    "sucker": m("#8a6c72", "#644c52", "#a6868c", "#261a1c"),
    "paper_talisman": m("#a89a6e", "#7e7250", "#c0b288", "#3a3020"),
    "seal_red": {"base": "#8a2a26"},
    # --- glowing eyes / cores (use with "emit")
    "glow_red": {"base": "#b8342c", "light": "#ff6a50"},
    "glow_yellow": {"base": "#c8a030", "light": "#ffe07a"},
    "glow_green": {"base": "#78b048", "light": "#b8f080"},
    "glow_cyan": {"base": "#58aebe", "light": "#aef0ff"},
    "glow_violet": {"base": "#9a60c8", "light": "#d8a8ff"},
    "glow_white": {"base": "#d8d0c0", "light": "#fff8e8"},
    "slime": m("#56703f", "#394d29", "#7f9a5c", "#121a0b", shade=WET),
    "slime_dark": m("#3f5530", "#2a3a1f", "#56703f", "#0c1207", shade=WET),
}


def main() -> int:
    data = json.loads(SRC.read_text(encoding="utf-8"))
    for k, v in NEW_COLORS.items():
        assert k not in data["colors"], k
        data["colors"][k] = v
    for k, v in NEW_MATERIALS.items():
        assert k not in data["materials"], k
        data["materials"][k] = v
    data["id"] = "palette_g05"
    data["source"] = ("g05 creature palette = palette_h0_mood.json (V1, copied unchanged) + creature materials. "
                      "Written by tool/make_palette.py. " + data.get("source", ""))
    OUT.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(OUT, len(data["materials"]), "materials")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
