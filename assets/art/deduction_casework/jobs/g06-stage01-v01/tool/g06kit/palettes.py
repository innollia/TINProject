"""Stage palettes for the 03 kit: palette_h0_mood.json (V1) + stage materials.

Ink, shadow, common colours and the three styles are copied unchanged from V1.
Stage colours come from the 13C relational palette and the 13A identity colours,
pushed down to V1 values (median luma ~70, dark violet joints, olive grime).
"""

from __future__ import annotations

import copy
import json
from pathlib import Path


def _tex(stamp="feather", angle=88.0, length=11, width=2.5, strength=0.08, density=0.8, pre_rot=-45, jitter=12):
    return {"stamp": stamp, "pre_rot": pre_rot, "length": length, "width": width, "angle": angle,
            "jitter": jitter, "density": density, "strength": strength}


def cloth(base, shadow, light, line, angle=88.0, strength=0.08, grime=0.2, stamp="feather"):
    m = {"base": base, "shadow": shadow, "light": light, "line": line,
         "texture": _tex(stamp=stamp, angle=angle, strength=strength)}
    if grime:
        m["grime"] = {"stamps": ["cloud", "metaballs"], "size": 12, "soft": 1.5, "density": 0.25,
                      "strength": grime, "color": "grime"}
    return m


def solid(base, shadow, light, line, side=None, side_shadow=None, tex=None, grime=None, shade=None):
    m = {"base": base, "shadow": shadow, "light": light, "line": line}
    if side:
        m["side"] = side
        m["side_shadow"] = side_shadow or side
    if tex:
        m["texture"] = tex
    if grime:
        m["grime"] = grime
    if shade:
        m["shade"] = shade
    return m


GRIME_WOOD = {"stamps": ["metaballs", "cloud"], "size": 18, "soft": 2, "density": 0.3, "strength": 0.3, "color": "grime"}
GRIME_METAL = {"stamps": ["metaballs", "sponge"], "size": 14, "soft": 1.5, "density": 0.35, "strength": 0.35,
               "color": "rust"}
GRIME_PAPER = {"stamps": ["sponge", "metaballs"], "size": 10, "soft": 1.0, "density": 0.25, "strength": 0.28,
               "color": "foxing"}
TEX_WOOD = _tex(stamp="pill", angle=0.0, length=22, width=2.2, strength=0.12, density=0.9, pre_rot=-45, jitter=4)
TEX_PAPER = _tex(stamp="leaf", angle=0.0, length=10, width=3, strength=0.05, density=0.8, pre_rot=45, jitter=10)

# Materials shared by every stage of the kit (people, paper, common metals).
COMMON = {
    "skin_light": solid("#cdb3a2", "#9e7c6e", "#e2cdbf", "#5a3a36", shade={"threshold": 0.5, "highlight_amount": 0.35}),
    "skin_mid": solid("#b89478", "#8a6552", "#cfae94", "#4e3024", shade={"threshold": 0.5, "highlight_amount": 0.3}),
    "skin_old": solid("#bf9f8e", "#8f6f62", "#d3b8a8", "#553733", shade={"threshold": 0.5, "highlight_amount": 0.3}),
    "skin_dark": solid("#7d5a45", "#583c2d", "#946f57", "#2a1a12", shade={"threshold": 0.5, "highlight_amount": 0.3}),
    "hair_brown": solid("#3a2a22", "#231913", "#56412f", "#0b0705",
                        tex=_tex(angle=70, length=9, width=2.2, strength=0.1, jitter=25, density=0.9)),
    "hair_black": solid("#221c20", "#141013", "#3a3137", "#070506",
                        tex=_tex(angle=70, length=9, width=2.2, strength=0.1, jitter=25, density=0.9)),
    "hair_greybrown": solid("#4a423c", "#302a26", "#655b53", "#100c0a",
                            tex=_tex(angle=70, length=9, width=2.2, strength=0.1, jitter=25, density=0.9)),
    "hair_grey": solid("#8d8a84", "#66635e", "#a8a59e", "#2a2826"),
    "hair_white": solid("#a9a59d", "#7d7a73", "#c3bfb6", "#33312d"),
    "shoe_black": solid("#221c1e", "#151113", "#3a3134", "#060405"),
    "shoe_brown": solid("#46342a", "#2d211a", "#5f4839", "#120c08"),
    "labcoat": dict(cloth("#a8a293", "#8a8577", "#c1bba9", "#3a352c", angle=90, strength=0.07, grime=0.12), shade={"threshold": 0.42}),
    "shirt_white": cloth("#a7a396", "#7b776c", "#bdb8a9", "#37332c", angle=85, strength=0.05, grime=0.18),
    "bandage": solid("#c2bba9", "#908a7b", "#d6cfbd", "#4a4438",
                     tex=_tex(stamp="leaf", angle=0, length=8, width=2.5, strength=0.12, pre_rot=45)),
    "gauze": solid("#bbb4a3", "#8a8476", "#d0c9b6", "#48423a"),
    "blood": solid("#5e1a1d", "#3e1013", "#7a2629", "#1a0507"),
    "blood_dry": solid("#4a1a18", "#301010", "#5e2622", "#140606"),
    "silver": solid("#9a9ca0", "#6c6e72", "#c4c6c9", "#26272a", shade={"highlight": 0.85, "highlight_amount": 0.7}),
    "glass_clear": solid("#8e9aa0", "#66737a", "#c9d3d6", "#2a3236", shade={"threshold": 0.4, "highlight_amount": 0.7}),
    "brass": solid("#8a7247", "#5c4b2e", "#b3995f", "#1f160b", shade={"highlight": 0.87, "highlight_amount": 0.7},
                   grime=GRIME_METAL),
    "paper_ivory": solid("#b6ab8f", "#8c8267", "#cdc3a6", "#4a4033", tex=TEX_PAPER, grime=GRIME_PAPER,
                         shade={"bump": 0.25, "highlight_amount": 0.25}),
    "paper_white": solid("#bcb6a6", "#918c7e", "#d2ccbb", "#4a463b", tex=TEX_PAPER, grime=GRIME_PAPER,
                         shade={"bump": 0.25, "highlight_amount": 0.25}),
    "paper_cream": solid("#b3a78c", "#8a8067", "#c9bea2", "#4a4033", tex=TEX_PAPER, grime=GRIME_PAPER,
                         shade={"bump": 0.25, "highlight_amount": 0.25}),
    "card_olive": solid("#6f7052", "#50513a", "#86876a", "#1e1f14", tex=TEX_PAPER),
    "ink_line": solid("#2b2530", "#1c1820", "#3d3544", "#0c0a0e"),
    "ink_blue": solid("#2f3a5a", "#1f273f", "#46557d", "#0c1020"),
    "ink_red": solid("#7a2a2a", "#561c1c", "#96403d", "#220808"),
    "pencil": solid("#4d4a50", "#35333a", "#66636a", "#141217"),
    "plastic_black": solid("#262427", "#171518", "#3e3b40", "#070607", side="#1c1a1d", side_shadow="#121113",
                           shade={"highlight": 0.86, "highlight_amount": 0.6}),
    "plastic_beige": solid("#8c8470", "#6a6352", "#a39a82", "#27231a", side="#746c5a", side_shadow="#58513f",
                           grime={"stamps": ["cloud", "metaballs"], "size": 16, "soft": 2, "density": 0.3,
                                  "strength": 0.3, "color": "grime"}),
    "screen_dark": solid("#1e2629", "#12181a", "#34403f", "#060909", shade={"threshold": 0.38, "highlight_amount": 0.55}),
    "screen_glow": solid("#5b6d5e", "#3e4d41", "#7c907d", "#141c16"),
    "metal_grey": solid("#585c62", "#3c3f45", "#7a7f86", "#111215", side="#45484e", side_shadow="#2e3035",
                        shade={"highlight": 0.86, "highlight_amount": 0.55}, grime=GRIME_METAL),
    "metal_dark": solid("#3f4247", "#2a2c30", "#5a5e64", "#0b0c0e", side="#303236", side_shadow="#1f2023",
                        shade={"highlight": 0.86, "highlight_amount": 0.5}, grime=GRIME_METAL),
    "steel": solid("#7a7e84", "#55585d", "#a3a8ae", "#1b1c1f", shade={"highlight": 0.84, "highlight_amount": 0.8}),
    "rubber": solid("#2c2a2b", "#1b1a1b", "#403d3f", "#080707"),
    "cork": solid("#6e5739", "#4d3c27", "#85694a", "#1c140a",
                  tex=_tex(stamp="metaballs", angle=0, length=6, width=6, strength=0.12, pre_rot=0, jitter=40)),
    "felt_green": solid("#3b4a3a", "#283327", "#4d5f4b", "#0e140e"),
    "leather_brown": solid("#4f3b2f", "#31241c", "#6d5343", "#150d09", grime=GRIME_WOOD),
    "leather_black": solid("#2a2426", "#1a1618", "#3f373a", "#080607"),
    "cloth_red": cloth("#7a3440", "#4f1f29", "#9a4c57", "#240b10", angle=10, strength=0.07, stamp="leaf"),
}


COMMON_COLORS = {"eye_white": "#b8b1a4", "lid_line": "#1c1216", "mouth": "#5a2c2c", "blood_mark": "#5e1a1d",
                 "joint_dark": "#1e1710", "reflect": "#9aa8b0", "corner": "#1a1712", "void_room": "#15120f"}


def build_palette(base_path: Path, stage_id: str, note: str, colors: dict, materials: dict) -> dict:
    base = json.loads(Path(base_path).read_text(encoding="utf-8"))
    pal = copy.deepcopy(base)
    pal["id"] = stage_id
    pal["status"] = "candidate"
    pal["source"] = ("g06 (03 Deduction Casework kit). Copy of palette_h0_mood.json (V1): ink, shadow, common "
                     "colours and styles unchanged. Added: " + note)
    pal["colors"].update(COMMON_COLORS)
    pal["colors"].update(colors)
    pal["materials"].update(copy.deepcopy(COMMON))
    pal["materials"].update(materials)
    return pal


def write_palette(path: Path, pal: dict) -> None:
    Path(path).write_text(json.dumps(pal, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
