"""Copy palette_h0_mood.json to palette_props.json and append food materials only.

Run from the job folder:  py -3 -B _gen\\make_palette.py
palette_h0_mood.json itself is never written.
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
SRC = JOB / "recipes" / "palette_h0_mood.json"
DST = JOB / "recipes" / "palette_props.json"

COLORS = {
    "glow_soft": "#93a89f",
    "wet_dark": "#2a2a22",
    "mold": "#4c4a2c",
    "seed_dark": "#241820",
    "pastry_dark": "#6a533a",
}

# name -> (base, shadow, light, line)
MATERIALS = {
    # fruit
    "apple":         ("#5c2a2c", "#401c20", "#7a3a38", "#1d0d10"),
    "apple_blush":   ("#7a4a3c", "#54322a", "#946050", "#241110"),
    "melon_rind":    ("#3f4a34", "#2a3223", "#55603f", "#12170e"),
    "melon_flesh":   ("#6e4446", "#4e2f31", "#8a5a58", "#221316"),
    "melon_pale":    ("#8a5c58", "#63403e", "#a5776f", "#2a1919"),
    "berry":         ("#46232e", "#2f161e", "#5e303c", "#160a0f"),
    "berry_pale":    ("#6a3a40", "#4a272c", "#875055", "#1e0f12"),
    "glow_berry":    ("#563a48", "#38242e", "#8a6c78", "#180f14"),
    "chorus":        ("#584a5c", "#3b3140", "#77687a", "#1a151d"),
    "chorus_pale":   ("#7a6a7e", "#564a59", "#9a8a9e", "#241d28"),
    # crops
    "carrot":        ("#6b4326", "#4a2d19", "#8a5c34", "#1e120a"),
    "carrot_top":    ("#455039", "#2f3728", "#5c6a4a", "#14180f"),
    "potato":        ("#6a5a44", "#4b3f2e", "#877357", "#241c13"),
    "beet":          ("#4a2733", "#331a23", "#653540", "#180b10"),
    "beet_pale":     ("#6b3a44", "#4a252d", "#8a525c", "#1e0f13"),
    "dandelion":     ("#8a7a3e", "#5f5430", "#a89a56", "#241f10"),
    "dandelion_mid": ("#6f6436", "#4d4526", "#8b7e47", "#1c180c"),
    "kelp":          ("#343a2b", "#23281b", "#454c39", "#0e100a"),
    "kelp_pale":     ("#525a44", "#383f2e", "#6b7458", "#171b10"),
    # meat
    "beef":          ("#5a3030", "#3e2020", "#774141", "#1c0f0f"),
    "beef_fat":      ("#8a8071", "#635a4e", "#a49a89", "#2a241d"),
    "beef_marble":   ("#8a5650", "#623c38", "#a4736a", "#2a1714"),
    "pork":          ("#7a5a58", "#553d3b", "#9a7773", "#241817"),
    "mutton":        ("#5c3634", "#3f2422", "#764845", "#1b100f"),
    "chicken":       ("#96806e", "#6c5a4b", "#b39c88", "#2a231b"),
    "rabbit":        ("#9a8878", "#6f6154", "#b6a492", "#2d251d"),
    "rotten":        ("#55503c", "#3a3728", "#6b6550", "#1a1810"),
    # fish
    "cod":           ("#7b8590", "#58616a", "#98a2ac", "#1b2025"),
    "fish":          ("#4a5660", "#333c44", "#66737d", "#151a1e"),
    "salmon":        ("#7a4436", "#543027", "#9a5c48", "#1f120e"),
    "tropical":      ("#8a7038", "#604e26", "#a88b4c", "#231a0c"),
    "puffer":        ("#6a6a4a", "#4a4a32", "#87875f", "#1c1c11"),
    "fish_belly":    ("#8a8378", "#655f56", "#a49c90", "#26221d"),
    # bakery
    "bread":         ("#7a6242", "#55422c", "#987c55", "#221a10"),
    "bread_score":   ("#4e3d28", "#33271a", "#674f34", "#160f08"),
    "crumb":         ("#8a7454", "#64543c", "#a68e6b", "#251d12"),
    "cookie":        ("#7a6246", "#54422e", "#977b58", "#221a10"),
    "cookie_chip":   ("#3a2b20", "#261c14", "#54402f", "#0d0906"),
    "cake_crumb":    ("#9a8a70", "#6f6350", "#b6a68a", "#282115"),
    "cake_sponge":   ("#6a4a34", "#48321f", "#87603f", "#1a0f08"),
    "cake_top":      ("#a89678", "#7a6c54", "#c0af90", "#2c2517"),
    "pie_crust":     ("#8a6c42", "#60492b", "#a58552", "#23180c"),
    "pie_fill":      ("#8a5c30", "#5f3e20", "#a67644", "#1e1208"),
    # stew
    "ceramic":       ("#6e6a62", "#4e4a44", "#8a857c", "#1c1a16"),
    "ceramic_dark":  ("#4a4740", "#32302b", "#646057", "#100f0d"),
    "stew_brown":    ("#4f4230", "#362d21", "#66573f", "#171208"),
    "stew_red":      ("#5a2a2a", "#3c1b1b", "#773c3c", "#180808"),
    "stew_green":    ("#474a30", "#2f3120", "#5e613f", "#121408"),
    "mushroom":      ("#6a5a48", "#4a3e30", "#86745e", "#1b1510"),
    "mushroom_gill": ("#8a7458", "#63533e", "#a58d6c", "#241a12"),
    "bone_white":    ("#9a917c", "#6f6757", "#b5ac95", "#2b261d"),
    # detail / small parts
    "melon_seed":    ("#241820", "#150e16", "#3a2a35", "#080509"),
    "carrot_dark":   ("#56351c", "#3a2412", "#6f4526", "#150d06"),
    "carrot_ridge":  ("#7d5130", "#573720", "#99683f", "#1d1208"),
    "soil":          ("#4a4032", "#332c22", "#5f5343", "#14110c"),
    "leaf_dark":     ("#38412c", "#252c1c", "#4b553a", "#10140b"),
    "kelp_dark":     ("#2b3024", "#1c2017", "#3a4130", "#0b0d07"),
    "fish_fin":      ("#3d4650", "#2b323a", "#525d68", "#12171b"),
    "stew_chunk":    ("#6a5340", "#483828", "#836a53", "#1a140e"),
    "bubble":        ("#7d8478", "#5b6157", "#9aa195", "#1e221c"),
    "moldy":         ("#565430", "#3b3a22", "#6e6c42", "#151507"),
    "pastry_dark":   ("#6a533a", "#493823", "#84684a", "#1b140d"),
}

TEXTURES = {
    "potato":   {"stamp": "sponge", "pre_rot": 0, "length": 7, "width": 3.5, "angle": 0,
                 "jitter": 30, "density": 0.9, "strength": 0.14},
    "bread":    {"stamp": "leaf", "pre_rot": 45, "length": 9, "width": 2.4, "angle": 20,
                 "jitter": 12, "density": 0.8, "strength": 0.1},
    "cookie":   {"stamp": "sponge", "pre_rot": 0, "length": 6, "width": 3, "angle": 0,
                 "jitter": 35, "density": 1.0, "strength": 0.16},
    "pie_crust": {"stamp": "leaf", "pre_rot": 45, "length": 11, "width": 2.6, "angle": 8,
                  "jitter": 18, "density": 0.9, "strength": 0.1},
    "kelp":     {"stamp": "leaf", "pre_rot": 45, "length": 13, "width": 2.2, "angle": 78,
                 "jitter": 20, "density": 0.9, "strength": 0.11},
    "rotten":   {"stamp": "metaballs", "pre_rot": 0, "length": 16, "width": 5, "angle": 0,
                 "jitter": 26, "density": 1.0, "strength": 0.2},
    "beef":     {"stamp": "feather", "pre_rot": -45, "length": 10, "width": 2.4, "angle": 30,
                 "jitter": 16, "density": 0.8, "strength": 0.09},
}

GRIME = {
    "rotten": {"stamps": ["metaballs", "sponge", "droplet"], "size": 18, "soft": 2,
               "density": 0.4, "strength": 0.5, "color": "mold"},
    "cod":    {"stamps": ["sponge", "metaballs"], "size": 14, "soft": 1.5,
               "density": 0.25, "strength": 0.22, "color": "damp"},
    "tropical": {"stamps": ["metaballs", "cloud"], "size": 16, "soft": 2,
                 "density": 0.35, "strength": 0.35, "color": "grime"},
    "pie_fill": {"stamps": ["metaballs", "sponge"], "size": 14, "soft": 1.5,
                 "density": 0.25, "strength": 0.2, "color": "foxing"},
    "beef_fat": {"stamps": ["sponge"], "size": 12, "soft": 1.0,
                 "density": 0.25, "strength": 0.25, "color": "rust"},
}


def main() -> int:
    pal = json.loads(SRC.read_text(encoding="utf-8"))
    pal["id"] = "palette_props"
    pal["status"] = "candidate"
    pal["source"] = (
        "palette_h0_mood.json copied verbatim, plus food/ingredient materials and a few food "
        "tint colours. Food tones are muted and faded on purpose: no fluorescent, no high-chroma. "
        "Bases sit darker than the rendered result because the prop shade pass lifts the lit side."
    )
    pal["colors"].update(COLORS)
    for name, (base, shadow, light, line) in MATERIALS.items():
        mat = {"base": base, "shadow": shadow, "light": light, "line": line}
        if name in TEXTURES:
            mat["texture"] = TEXTURES[name]
        if name in GRIME:
            mat["grime"] = GRIME[name]
        pal["materials"][name] = mat
    DST.write_text(json.dumps(pal, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {DST} materials={len(pal['materials'])} colors={len(pal['colors'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
