"""Write recipes/palette_g07.json = palette_h0_mood.json (V1) + g07 materials.

    py -3 -B make_palette_g07.py            # writes ../recipes/palette_g07.json

Everything from V1 is kept unchanged (ink, shadows, grime, damp, rust, styles).
Only new colour names and new materials are added, all at V1 brightness
(dark, worn, dull).  Lit lamps / phosphor screens are the only bright values and
they are always drawn with ``emit`` so the game can light them on its own.
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
SRC = JOB / "recipes" / "palette_h0_mood.json"
OUT = JOB / "recipes" / "palette_g07.json"

RUST = {"stamps": ["metaballs", "sponge"], "size": 16, "soft": 1.5, "density": 0.35, "strength": 0.4, "color": "rust"}
GRIME = {"stamps": ["metaballs", "cloud"], "size": 18, "soft": 2, "density": 0.3, "strength": 0.3, "color": "grime"}
SIDE_RUST = {"stamps": ["droplet", "metaballs"], "size": 16, "aspect": 1.7, "soft": 1.5, "density": 0.45,
             "strength": 0.45, "color": "rust", "foot": 0.6, "foot_curve": 1.6}

COLORS = {
    "enamel": "#8f8672",
    "dial_mark": "#211a1f",
    "zone_red": "#6e2c34",
    "glare": "#cfc6b4",
    "glow_red": "#ff6a55",
    "glow_green": "#8ff0a0",
    "glow_amber": "#ffc36a",
    "glow_white": "#fff1d6",
    "glow_phosphor": "#86e8a8",
    "glow_blue": "#8fc8ff",
    "ink_red": "#6e2a2e",
    "ink_violet": "#4e3a66",
}


def lamp(off_base, off_shadow, off_light, on_base, on_shadow, on_light, line):
    return (
        {"base": off_base, "shadow": off_shadow, "light": off_light, "line": line,
         "shade": {"highlight": 0.86, "highlight_amount": 0.45}},
        {"base": on_base, "shadow": on_shadow, "light": on_light, "line": line,
         "shade": {"threshold": 0.34, "highlight": 0.8, "highlight_amount": 0.75}},
    )


MATERIALS = {
    "enamel": {"base": "#8f8672", "shadow": "#6f6756", "light": "#a79d86", "line": "#2d2720",
               "shade": {"bump": 0.35, "highlight_amount": 0.25},
               "texture": {"stamp": "leaf", "pre_rot": 45, "length": 10, "width": 3, "angle": 0, "jitter": 10,
                           "density": 0.7, "strength": 0.04},
               "grime": {"stamps": ["sponge", "metaballs"], "size": 14, "soft": 1.5, "density": 0.3,
                         "strength": 0.3, "color": "foxing"}},
    "dial_mark": {"base": "#211a1f"},
    "zone_red": {"base": "#6e2c34"},
    "glare": {"base": "#cfc6b4"},
    "steel": {"base": "#4a4d57", "shadow": "#2f3138", "light": "#6d717d", "side": "#373a42", "side_shadow": "#23252b",
              "line": "#0b0b0e", "shade": {"highlight": 0.86, "highlight_amount": 0.55}, "grime": RUST,
              "side_grime": SIDE_RUST},
    "steel_dark": {"base": "#34363e", "shadow": "#212228", "light": "#4e515b", "side": "#2a2c32", "side_shadow": "#18191d",
                   "line": "#08080a", "shade": {"highlight": 0.88, "highlight_amount": 0.45}, "grime": RUST,
                   "side_grime": SIDE_RUST},
    "paint_teal": {"base": "#3b5250", "shadow": "#273735", "light": "#4f6b68", "side": "#2d3f3d", "side_shadow": "#1c2827",
                   "line": "#0a100f", "grime": RUST, "side_grime": SIDE_RUST},
    "paint_olive": {"base": "#4a4936", "shadow": "#313023", "light": "#626149", "side": "#393828", "side_shadow": "#24241a",
                    "line": "#0f0f09", "grime": RUST, "side_grime": SIDE_RUST},
    "paint_red": {"base": "#7a2d30", "shadow": "#4f1b1f", "light": "#98474a", "side": "#5a2124", "side_shadow": "#3a1417",
                  "line": "#22090b", "grime": GRIME},
    "paint_ochre": {"base": "#7d6532", "shadow": "#544320", "light": "#9a7f45", "side": "#5e4b25", "side_shadow": "#3e3118",
                    "line": "#1f170a", "grime": RUST, "side_grime": SIDE_RUST},
    "paint_violet": {"base": "#4f4160", "shadow": "#332a40", "light": "#675679", "side": "#3b3048", "side_shadow": "#261f2f",
                     "line": "#110c16", "grime": GRIME},
    "plastic_beige": {"base": "#857d6b", "shadow": "#645d4f", "light": "#9f9682", "side": "#6a6354", "side_shadow": "#4b463b",
                      "line": "#231f19", "shade": {"bump": 0.6},
                      "grime": {"stamps": ["cloud", "metaballs"], "size": 16, "soft": 2, "density": 0.3, "strength": 0.3,
                                "color": "grime"}},
    "plastic_dark": {"base": "#2f2c33", "shadow": "#1e1c21", "light": "#46424b", "side": "#262429", "side_shadow": "#18161a",
                     "line": "#070608", "shade": {"highlight": 0.88, "highlight_amount": 0.4}},
    "rubber": {"base": "#221f25", "shadow": "#141216", "light": "#36313b", "side": "#1b181d", "side_shadow": "#100e11",
               "line": "#050406"},
    "cable": {"base": "#2c2830", "shadow": "#1a171d", "light": "#433d49", "line": "#070608",
              "texture": {"stamp": "feather", "pre_rot": -45, "length": 8, "width": 2.2, "angle": 60, "jitter": 8,
                          "density": 1.0, "strength": 0.12}},
    "screen": {"base": "#0f1917", "shadow": "#08100e", "light": "#1c2b27", "line": "#030605"},
    "screen_glass": {"base": "#1a2624", "shadow": "#0e1614", "light": "#2f423e", "line": "#050807",
                     "shade": {"highlight": 0.8, "highlight_amount": 0.8}},
    "phosphor": {"base": "#4f9a6c", "shadow": "#357050", "light": "#86e8a8", "line": "#0c2416"},
    "phosphor_dim": {"base": "#2c5a40"},
    "amber_screen": {"base": "#a0702e", "shadow": "#76501e", "light": "#f0c070", "line": "#2a1a08"},
    "glass_pane": {"base": "#4c5a60", "shadow": "#343f44", "light": "#6f8088", "line": "#10161a",
                   "shade": {"highlight": 0.84, "highlight_amount": 0.8}},
    "felt": {"base": "#2d4538", "shadow": "#1d2e25", "light": "#3d5a4a", "line": "#0a120e",
             "texture": {"stamp": "leaf", "pre_rot": 45, "length": 9, "width": 3, "angle": 30, "jitter": 40, "density": 0.9,
                         "strength": 0.06}},
    "cork": {"base": "#6b5237", "shadow": "#4b3925", "light": "#836546", "side": "#4f3c28", "side_shadow": "#34271a",
             "line": "#1f160d",
             "grime": {"stamps": ["sponge", "metaballs"], "size": 10, "soft": 0.8, "density": 0.55, "strength": 0.35,
                       "color": "soot"}},
    "water": {"base": "#1d2b31", "shadow": "#121c20", "light": "#2c3f46", "line": "#060a0c"},
    "rust_metal": {"base": "#5e3e2c", "shadow": "#3e281c", "light": "#7a5238", "side": "#472f21", "side_shadow": "#2e1e15",
                   "line": "#150c07", "grime": GRIME, "side_grime": SIDE_RUST},
    "wax": {"base": "#a89a7c", "shadow": "#7e7360", "light": "#c0b394", "line": "#3a3226"},
    "salt": {"base": "#8f8a80", "shadow": "#6e6a62", "light": "#a39e94", "line": "#2e2b27"},
    "crystal": {"base": "#4f6a7a", "shadow": "#344856", "light": "#8fb8c8", "line": "#0e1a22",
                "shade": {"threshold": 0.4, "highlight_amount": 0.8}},
    "ink_red": {"base": "#6e2a2e"},
    "ink_violet": {"base": "#4e3a66"},
    "bone": {"base": "#9c9178", "shadow": "#766d59", "light": "#b3a88e", "side": "#7a705c", "side_shadow": "#5a5244",
             "line": "#2e281e"},
}

LAMPS = {
    "red": ("#4a1d21", "#2e1114", "#6a2b30", "#c0443c", "#8a2a26", "#ff8a70", "#150608"),
    "green": ("#1f3a28", "#13251a", "#2c5038", "#4fa060", "#357a44", "#a0f0b0", "#06110a"),
    "amber": ("#4a3518", "#2e210f", "#634822", "#d09030", "#a06a20", "#ffd890", "#140d04"),
    "white": ("#3a3638", "#262325", "#4c474a", "#d8cfb8", "#a89f8a", "#fff6e0", "#0e0c0d"),
    "blue": ("#1e2a3a", "#121a25", "#2c3c52", "#5a8ac8", "#3f6698", "#b0d8ff", "#060a10"),
}


def main() -> int:
    pal = json.loads(SRC.read_text(encoding="utf-8"))
    pal["id"] = "palette_g07"
    pal["source"] = ("g07 (future-kit niche assets). palette_h0_mood.json (V1) unchanged, plus instrument / screen / "
                     "device materials at V1 brightness. Lit lamps and phosphor are the only bright values and are "
                     "always drawn as emit layers. See docs JOB.md.")
    pal["colors"].update(COLORS)
    pal["materials"].update(MATERIALS)
    for name, (ob, os_, ol, nb, ns, nl, line) in LAMPS.items():
        off, on = lamp(ob, os_, ol, nb, ns, nl, line)
        pal["materials"][f"lamp_{name}_off"] = off
        pal["materials"][f"lamp_{name}_on"] = on
    OUT.write_text(json.dumps(pal, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(OUT, len(pal["materials"]), "materials")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
