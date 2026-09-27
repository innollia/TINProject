"""Shared settings for the Stage 01 recipe writers (palette, scale, registry)."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g06kit.palettes import GRIME_WOOD, TEX_WOOD, build_palette, cloth, solid, write_palette  # noqa: E402

JOB = Path(__file__).resolve().parents[1]
REC = JOB / "recipes"
PAL = "palette_s01_orin.json"
PAL_CCTV = "palette_s01_cctv.json"
PPM = 320.0  # source px per metre (vertical) in every Stage 01 asset

REGISTRY: dict = {}


def asset(name):
    def deco(fn):
        REGISTRY[name] = fn
        return fn
    return deco


S01_COLORS = {"wall_olive": "#55543c", "blood_mark": "#5e1a1d", "magnet_red": "#7c3434", "magnet_blue": "#34466a",
              "magnet_yellow": "#8e7a36", "magnet_green": "#3f6a47", "crt_line": "#6d8070",
              "stain_disinfect": "#8a6a3a", "under_eye": "#6d7682"}
S01_MATS = {
    "wall_olive": solid("#55543c", "#403f2c", "#66654b", "#141308",
                        tex={"stamp": "leaf", "pre_rot": 45, "length": 40, "width": 8, "angle": 90, "jitter": 8,
                             "density": 0.8, "strength": 0.05},
                        grime={"stamps": ["metaballs", "cloud", "droplet"], "size": 60, "soft": 5, "density": 0.25,
                               "strength": 0.3, "color": "grime"}),
    "wall_olive_dark": solid("#46452f", "#343322", "#56553c", "#100f06"),
    "wainscot": solid("#5b4830", "#3e3120", "#735e3f", "#140d06", side="#463824", side_shadow="#2d2416",
                      tex=TEX_WOOD, grime=GRIME_WOOD),
    "lino": solid("#4f4c43", "#3f3c35", "#615d53", "#16140f",
                  tex={"stamp": "leaf", "pre_rot": 45, "length": 34, "width": 7, "angle": 2, "jitter": 9,
                       "density": 1.2, "strength": 0.1},
                  grime={"stamps": ["cloud", "sponge"], "size": 120, "soft": 14, "density": 0.08,
                         "strength": 0.25, "color": "grime", "lo": 0.2}),
    "wood_ochre": solid("#6a5334", "#473720", "#86693f", "#1a1109", side="#53412a", side_shadow="#372a1b",
                        tex=TEX_WOOD, grime=GRIME_WOOD),
    "wood_dark": solid("#4a3a28", "#30251a", "#614c35", "#110b06", side="#3a2d1f", side_shadow="#261d14",
                       tex=TEX_WOOD, grime=GRIME_WOOD),
    "glass_booth": solid("#46545e", "#34404a", "#6a7a84", "#10161a", shade={"threshold": 0.4, "highlight_amount": 0.6}),
    "knit_green": cloth("#4f5a44", "#363f2f", "#66725a", "#11150d", angle=0, strength=0.12, grime=0.15, stamp="leaf"),
    "collar_cream": solid("#b3a88f", "#877e69", "#c9bfa5", "#3e372b"),
    "vest_navy": cloth("#2f3544", "#1e2230", "#454c5e", "#090b10", angle=0, strength=0.1, grime=0.15, stamp="leaf"),
    "trouser_greybrown": cloth("#57524c", "#3b3733", "#6d6760", "#121110", angle=90, strength=0.06, grime=0.15),
    "uniform_grey": cloth("#585956", "#3d3e3c", "#6f706c", "#121212", angle=88, strength=0.07, grime=0.25),
    "trouser_greyblue": cloth("#3c444d", "#282e35", "#505a64", "#0c0f12", angle=90, strength=0.06, grime=0.2),
    "cardigan_beige": cloth("#8e826c", "#665d4c", "#a69a82", "#27221a", angle=0, strength=0.12, grime=0.15,
                            stamp="leaf"),
    "magnet_red": solid("#7c3434", "#5c2626", "#9c4c4a", "#220a0a", shade={"highlight_amount": 0.6}),
    "magnet_blue": solid("#34466a", "#26334f", "#4c6290", "#0a0f1e", shade={"highlight_amount": 0.6}),
    "magnet_yellow": solid("#8e7a36", "#6a5a26", "#b09a4c", "#241e08", shade={"highlight_amount": 0.6}),
    "magnet_green": solid("#3f6a47", "#2e4f35", "#58885f", "#0c1a10", shade={"highlight_amount": 0.6}),
    "skirt_dark": cloth("#3b3534", "#272322", "#4f4847", "#0d0b0b", angle=90, strength=0.06, grime=0.1),
}


def _desat(hexv: str, amount=0.85, tint=(0.62, 0.7, 0.6), lift=0.0) -> str:
    """CCTV look: grey-green monochrome of the same value."""
    h = hexv.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    y = 0.299 * r + 0.587 * g + 0.114 * b
    y = min(1.0, y * 1.08 + lift)
    mix = [(1 - amount) * c + amount * y * t / 0.66 for c, t in zip((r, g, b), tint)]
    return "#" + "".join(f"{int(max(0, min(1, v)) * 255 + 0.5):02x}" for v in mix)


def _cctv_palette(pal: dict) -> dict:
    import copy
    out = copy.deepcopy(pal)
    out["id"] = "palette_s01_cctv"
    out["source"] += " CCTV variant: every colour turned into the same-value grey-green (booth camera frame, 13E)."
    for k, v in list(out["colors"].items()):
        if isinstance(v, str) and v.startswith("#"):
            out["colors"][k] = _desat(v)
    for m in out["materials"].values():
        for key in ("base", "shadow", "light", "line", "side", "side_shadow"):
            if isinstance(m.get(key), str) and m[key].startswith("#"):
                m[key] = _desat(m[key])
    for st in out["styles"].values():
        if isinstance(st.get("background"), str):
            st["background"] = _desat(st["background"])
    return out


def palettes():
    pal = build_palette(REC / "palette_h0_mood.json", "palette_s01_orin",
                        "Stage 01 university: olive plaster, ochre scratched wood, ivory paper, blue-grey glass, "
                        "silver pins (13C); identity colours of Mira, Grell, Ed, Lina (13A-1) darkened to V1 values.",
                        S01_COLORS, S01_MATS)
    write_palette(REC / PAL, pal)
    write_palette(REC / PAL_CCTV, _cctv_palette(pal))
