"""Write palette_g04.json into every g04 job: palette_h0_mood.json (V1) + object materials.

V1 ink / shadow / common colours and every V1 material are kept unchanged; only new
materials and colours are added.  Values stay in the V1 range (dark, desaturated,
bone paper = brightest surface).  Usage: python make_palette_g04.py <job_dir> [...]
"""
import copy
import json
import sys
from pathlib import Path

LEAF = {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 4, "angle": 60, "jitter": 40, "density": 1.0, "strength": 0.13}
GRAIN = {"stamp": "pill", "pre_rot": -45, "length": 20, "width": 2.2, "angle": 0, "jitter": 4, "density": 0.9, "strength": 0.12}
BARK = {"stamp": "pill", "pre_rot": -45, "length": 18, "width": 2.2, "angle": 90, "jitter": 6, "density": 1.0, "strength": 0.15}
STONE_TEX = {"stamp": "leaf", "pre_rot": 45, "length": 14, "width": 3.5, "angle": 0, "jitter": 14, "density": 0.9, "strength": 0.09}
CLOTH = {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 3, "angle": 90, "jitter": 10, "density": 0.8, "strength": 0.07}


def g(stamps, size, density, strength, color, soft=2.0, **kw):
    out = {"stamps": stamps, "size": size, "soft": soft, "density": density, "strength": strength, "color": color}
    out.update(kw)
    return out


def foot(color, size=24, strength=0.45):
    return g(["droplet", "metaballs"], size, 0.4, strength, color, soft=2.5, aspect=1.6, foot=0.6, foot_curve=1.6)


NEW_COLORS = {
    "moss": "#4a5238", "verdigris": "#4a6658", "sand": "#7a6a4e",
    "window_glow": "#f0c27a", "screen_glow": "#7ed0c8", "neon_pink_glow": "#ff7aa8",
    "neon_cyan_glow": "#7ef0f4", "crystal_glow": "#8a9ad8", "signal_red_glow": "#ff6a58",
    "signal_green_glow": "#7af0a8", "signal_amber_glow": "#ffc060", "water_light": "#5a7078",
    "hole": "#07050a",
}

NEW_MATERIALS = {
    # --- plants
    "foliage": {"base": "#3d4633", "shadow": "#272e22", "light": "#556043", "line": "#0c100a", "texture": LEAF,
                "grime": g(["cloud", "metaballs"], 30, 0.3, 0.25, "damp", soft=3)},
    "foliage_dark": {"base": "#323a2e", "shadow": "#1f251d", "light": "#465040", "line": "#0a0d09",
                     "texture": dict(LEAF, angle=80), "grime": g(["cloud", "metaballs"], 30, 0.3, 0.2, "damp", soft=3)},
    "foliage_dry": {"base": "#4e4432", "shadow": "#332c20", "light": "#665a42", "line": "#120e08", "texture": LEAF,
                    "grime": g(["cloud", "metaballs"], 26, 0.3, 0.25, "grime", soft=3)},
    "foliage_bloom": {"base": "#6e4a58", "shadow": "#4a3040", "light": "#8a6272", "line": "#1a0c14", "texture": LEAF,
                      "grime": g(["cloud", "metaballs"], 26, 0.25, 0.2, "grime", soft=3)},
    "foliage_sick": {"base": "#3e3a3a", "shadow": "#282424", "light": "#524c4a", "line": "#0c0a0a", "texture": LEAF,
                     "grime": g(["cloud", "metaballs"], 26, 0.35, 0.3, "damp", soft=3)},
    "grass": {"base": "#46503a", "shadow": "#2e3526", "light": "#5c6848", "line": "#0e110b",
              "texture": dict(LEAF, angle=90, length=10, width=3), "grime": False},
    "bark": {"base": "#40342c", "shadow": "#2a211b", "light": "#58483c", "side": "#352a22", "side_shadow": "#221a14",
             "line": "#100b08", "texture": BARK, "grime": g(["cloud", "metaballs"], 18, 0.35, 0.3, "moss", soft=2)},
    "bark_pale": {"base": "#5a524c", "shadow": "#3e3834", "light": "#706862", "side": "#4a4440", "side_shadow": "#302c2a",
                  "line": "#120f0d", "texture": BARK, "grime": g(["cloud", "metaballs"], 18, 0.35, 0.3, "grime", soft=2)},
    "wood_cut": {"base": "#7a6448", "shadow": "#57452f", "light": "#907858", "line": "#1e150c",
                 "texture": {"stamp": "ring", "length": 10, "width": 10, "angle": 0, "jitter": 0, "density": 0.3, "strength": 0.08}},
    "petal_wine": {"base": "#7a3444", "shadow": "#52202c", "light": "#9a4c5a", "line": "#240b12"},
    "petal_ochre": {"base": "#9a7c46", "shadow": "#6a5230", "light": "#b89a5c", "line": "#2a1c0c"},
    "petal_pale": {"base": "#a09a90", "shadow": "#77716a", "light": "#bab4a8", "line": "#322c28"},
    "petal_violet": {"base": "#5e4a70", "shadow": "#3e304c", "light": "#78628a", "line": "#160f1c"},
    "fruit": {"base": "#7a3a30", "shadow": "#50241e", "light": "#9c5444", "line": "#200a07",
              "shade": {"highlight_amount": 0.7}},
    "mushroom_cap": {"base": "#6e3a30", "shadow": "#4a241e", "light": "#8c5244", "line": "#1e0c08",
                     "grime": g(["metaballs", "sponge"], 12, 0.3, 0.25, "grime", soft=1)},
    "mushroom_stem": {"base": "#a09482", "shadow": "#786e60", "light": "#b8ac98", "line": "#2e2820",
                      "grime": g(["cloud", "metaballs"], 10, 0.3, 0.25, "grime", soft=1)},
    "bamboo": {"base": "#5a6440", "shadow": "#3c4428", "light": "#727e52", "line": "#141a0c",
               "texture": dict(BARK, strength=0.08)},
    "cactus": {"base": "#4a5a42", "shadow": "#303c2c", "light": "#62745a", "line": "#0e140c",
               "texture": {"stamp": "pill", "pre_rot": -45, "length": 30, "width": 2, "angle": 90, "jitter": 2, "density": 0.6, "strength": 0.1}},
    "moss": {"base": "#4a5238", "shadow": "#323824", "light": "#5e6848", "line": "#10130b", "texture": LEAF},
    # --- mineral / water
    "rock": {"base": "#5c5658", "shadow": "#403b3e", "light": "#726b6d", "side": "#454043", "side_shadow": "#2c282a",
             "line": "#100d0f", "texture": STONE_TEX,
             "grime": g(["metaballs", "cloud", "droplet"], 30, 0.35, 0.35, "damp", soft=3),
             "side_grime": g(["droplet", "metaballs"], 24, 0.45, 0.45, "moss", soft=2.5, aspect=1.6, foot=0.6, foot_curve=1.6)},
    "rock_dark": {"base": "#474244", "shadow": "#302c2e", "light": "#5a5456", "side": "#383436", "side_shadow": "#232022",
                  "line": "#0c0a0b", "texture": STONE_TEX,
                  "grime": g(["metaballs", "cloud"], 28, 0.35, 0.35, "damp", soft=3)},
    "crystal": {"base": "#4e5a86", "shadow": "#343e60", "light": "#8a98c4", "line": "#0e1020",
                "shade": {"threshold": 0.45, "highlight": 0.85, "highlight_amount": 0.8}},
    "marble": {"base": "#6e6a72", "shadow": "#504c56", "light": "#86828a", "side": "#58545e", "side_shadow": "#3a3740",
               "line": "#141117", "texture": dict(STONE_TEX, strength=0.05),
               "grime": g(["metaballs", "cloud", "droplet"], 22, 0.35, 0.35, "damp", soft=2.5),
               "side_grime": foot("damp", 20, 0.5)},
    "water": {"base": "#2b3940", "shadow": "#1b252b", "light": "#4a6068", "line": "#0a1014",
              "texture": {"stamp": "pill", "pre_rot": -45, "length": 26, "width": 2.5, "angle": 0, "jitter": 6, "density": 0.7, "strength": 0.16},
              "shade": {"threshold": 0.4, "highlight": 0.9, "highlight_amount": 0.4}},
    "snow": {"base": "#a7a8b2", "shadow": "#7c7c8a", "light": "#bcbdc6", "line": "#2c2a34",
             "texture": dict(STONE_TEX, strength=0.04), "grime": g(["cloud", "metaballs"], 20, 0.25, 0.18, "damp", soft=3)},
    "earth": {"base": "#4a4036", "shadow": "#322a22", "light": "#5e5244", "line": "#110c08", "texture": STONE_TEX},
    "sand": {"base": "#7a6a4e", "shadow": "#5a4c36", "light": "#8e7e60", "line": "#1e170c"},
    # --- metal / fine materials
    "gold": {"base": "#86703e", "shadow": "#584824", "light": "#b89a58", "side": "#5e4e2a", "side_shadow": "#3e331a",
             "line": "#1c1408", "shade": {"highlight": 0.88, "highlight_amount": 0.7},
             "grime": g(["metaballs", "sponge"], 12, 0.3, 0.25, "rust", soft=1)},
    "copper": {"base": "#744c34", "shadow": "#4c3020", "light": "#9a6848", "side": "#5c3c28", "side_shadow": "#3c2618",
               "line": "#1a0e08", "shade": {"highlight": 0.88, "highlight_amount": 0.6},
               "grime": g(["metaballs", "sponge"], 16, 0.4, 0.45, "verdigris", soft=1.5)},
    "steel": {"base": "#4a4e58", "shadow": "#30333b", "light": "#626876", "side": "#3a3e48", "side_shadow": "#262930",
              "line": "#0c0d10", "shade": {"highlight": 0.86, "highlight_amount": 0.5},
              "grime": g(["metaballs", "sponge"], 18, 0.3, 0.3, "grime", soft=2)},
    "steel_light": {"base": "#666a74", "shadow": "#4a4e56", "light": "#7e828e", "side": "#52565e", "side_shadow": "#383b42",
                    "line": "#101115", "shade": {"highlight": 0.86, "highlight_amount": 0.5},
                    "grime": g(["metaballs", "sponge"], 18, 0.3, 0.3, "grime", soft=2)},
    "chrome": {"base": "#6c6e76", "shadow": "#44464e", "light": "#9a9ca6", "line": "#141518",
               "shade": {"highlight": 0.85, "highlight_amount": 0.8}},
    "rubber": {"base": "#1f1c22", "shadow": "#141216", "light": "#302c34", "line": "#060507"},
    "plastic": {"base": "#56525c", "shadow": "#3a3740", "light": "#6e6a76", "side": "#46424c", "side_shadow": "#2e2b33",
                "line": "#0e0c10", "grime": g(["metaballs", "sponge"], 18, 0.3, 0.3, "grime", soft=2)},
    "paint_red": {"base": "#6a2c2c", "shadow": "#461c1c", "light": "#8a4040", "side": "#552222", "side_shadow": "#381616",
                  "line": "#1a0808", "shade": {"highlight": 0.88, "highlight_amount": 0.6},
                  "grime": g(["metaballs", "sponge"], 18, 0.3, 0.3, "rust", soft=2)},
    "paint_teal": {"base": "#2e4a4c", "shadow": "#1e3234", "light": "#3e6064", "side": "#263e40", "side_shadow": "#18282a",
                   "line": "#08100f", "shade": {"highlight": 0.88, "highlight_amount": 0.6},
                   "grime": g(["metaballs", "sponge"], 18, 0.3, 0.3, "rust", soft=2)},
    "hazard": {"base": "#8a7430", "shadow": "#5c4c1e", "light": "#a88e40", "side": "#6e5c26", "side_shadow": "#4a3e18",
               "line": "#1c1606", "grime": g(["metaballs", "sponge"], 16, 0.35, 0.35, "grime", soft=2)},
    "glass_dark": {"base": "#1e2230", "shadow": "#141620", "light": "#40465c", "line": "#08090e",
                   "shade": {"threshold": 0.4, "highlight": 0.86, "highlight_amount": 0.55}},
    "window_lit": {"base": "#c9954f", "shadow": "#a87a3c", "light": "#f0c27a", "line": "#2a1a0c"},
    "screen_off": {"base": "#161b20", "shadow": "#0e1115", "light": "#262e36", "line": "#07080a"},
    "screen_on": {"base": "#3f8a86", "shadow": "#2c6462", "light": "#7ed0c8", "line": "#0c1e1e"},
    "neon_pink": {"base": "#c2446e", "shadow": "#8e2e50", "light": "#ff8ab0", "line": "#2a0a16"},
    "neon_cyan": {"base": "#3aa8b0", "shadow": "#28787e", "light": "#8ef0f4", "line": "#0a2426"},
    "signal_red": {"base": "#b8433a", "light": "#ff8070", "line": "#2a0a08"},
    "signal_green": {"base": "#3aa06a", "light": "#8af0b0", "line": "#08200f"},
    "signal_amber": {"base": "#c08a36", "light": "#ffc870", "line": "#2a1a06"},
    "signal_off": {"base": "#2a2226", "shadow": "#1c171a", "light": "#3a3036", "line": "#0a0809"},
    "ceramic": {"base": "#5e5a6e", "shadow": "#403c4e", "light": "#78748a", "line": "#141220",
                "shade": {"highlight_amount": 0.6}, "grime": g(["metaballs", "sponge"], 14, 0.3, 0.28, "grime", soft=1.5)},
    "clay": {"base": "#6e4436", "shadow": "#4a2c22", "light": "#8a5a48", "line": "#1c0e0a",
             "grime": g(["metaballs", "sponge"], 14, 0.3, 0.28, "grime", soft=1.5)},
    # --- cloth / soft
    "cloth_blue": {"base": "#343c52", "shadow": "#222838", "light": "#48526a", "line": "#0a0c14", "texture": CLOTH,
                   "grime": g(["cloud", "metaballs"], 22, 0.3, 0.25, "grime", soft=3)},
    "cloth_green": {"base": "#394536", "shadow": "#252d23", "light": "#4d5a49", "line": "#0b0e0a", "texture": CLOTH,
                    "grime": g(["cloud", "metaballs"], 22, 0.3, 0.25, "grime", soft=3)},
    "cloth_ochre": {"base": "#6e5a3a", "shadow": "#4a3c26", "light": "#88714c", "line": "#1c140a", "texture": CLOTH,
                    "grime": g(["cloud", "metaballs"], 22, 0.3, 0.25, "grime", soft=3)},
    "cloth_pale": {"base": "#8a8276", "shadow": "#666056", "light": "#a29a8c", "line": "#2a2622", "texture": CLOTH,
                   "grime": g(["cloud", "metaballs"], 20, 0.3, 0.25, "foxing", soft=3)},
    "rope": {"base": "#6a5a3e", "shadow": "#4a3e2a", "light": "#84724e", "line": "#1a140a"},
    "thatch": {"base": "#6a5a3a", "shadow": "#4a3e28", "light": "#82704a", "side": "#584a30", "side_shadow": "#3a3020",
               "line": "#1a140a", "texture": {"stamp": "feather", "pre_rot": -45, "length": 14, "width": 2.5, "angle": 90, "jitter": 12, "density": 1.0, "strength": 0.14},
               "grime": g(["cloud", "metaballs"], 26, 0.35, 0.3, "damp", soft=3)},
    # --- building
    "plaster": {"base": "#6a625e", "shadow": "#4e4744", "light": "#7e7572", "side": "#5a5350", "side_shadow": "#3e3836",
                "line": "#15110f", "texture": dict(STONE_TEX, strength=0.05),
                "grime": g(["metaballs", "cloud", "droplet"], 26, 0.35, 0.3, "grime", soft=3), "side_grime": foot("grime", 26, 0.5)},
    "plaster_pale": {"base": "#807874", "shadow": "#605a56", "light": "#948c88", "side": "#6e6864", "side_shadow": "#504a47",
                     "line": "#18130f", "texture": dict(STONE_TEX, strength=0.05),
                     "grime": g(["metaballs", "cloud", "droplet"], 26, 0.35, 0.3, "grime", soft=3), "side_grime": foot("grime", 26, 0.5)},
    "roof_tile": {"base": "#4a2e34", "shadow": "#301c22", "light": "#643e46", "side": "#3a2228", "side_shadow": "#26141a",
                  "line": "#12070a", "grime": g(["cloud", "metaballs"], 26, 0.35, 0.3, "grime", soft=3)},
    "roof_slate": {"base": "#3a3846", "shadow": "#26242f", "light": "#4c4a5a", "side": "#2e2c38", "side_shadow": "#1e1c26",
                   "line": "#0a090e", "grime": g(["cloud", "metaballs"], 26, 0.35, 0.3, "damp", soft=3)},
    "brick": {"base": "#5a3c38", "shadow": "#3c2624", "light": "#72504a", "side": "#4a302c", "side_shadow": "#301e1c",
              "line": "#140a09", "grime": g(["metaballs", "cloud"], 24, 0.35, 0.3, "grime", soft=2.5), "side_grime": foot("grime", 24, 0.5)},
    "wood_dark": {"base": "#3a2c22", "shadow": "#261c15", "light": "#4e3c2e", "side": "#2e231a", "side_shadow": "#1d1610",
                  "line": "#0e0906", "texture": GRAIN, "grime": g(["metaballs", "cloud"], 18, 0.3, 0.3, "grime", soft=2)},
    "wood_pale": {"base": "#6a5a44", "shadow": "#4a3e2e", "light": "#84725a", "side": "#5a4c3a", "side_shadow": "#3c3226",
                  "line": "#18120b", "texture": GRAIN, "grime": g(["metaballs", "cloud"], 18, 0.3, 0.3, "grime", soft=2)},
    "lacquer_red": {"base": "#6a2a28", "shadow": "#461a18", "light": "#843a36", "side": "#541f1d", "side_shadow": "#381312",
                    "line": "#1a0707", "shade": {"highlight_amount": 0.55},
                    "grime": g(["metaballs", "cloud"], 18, 0.3, 0.3, "grime", soft=2)},
    "hole": {"base": "#07050a"},
}


def main() -> int:
    for job in map(Path, sys.argv[1:]):
        src = json.loads((job / "recipes" / "palette_h0_mood.json").read_text(encoding="utf-8"))
        pal = copy.deepcopy(src)
        pal["id"] = "palette_g04"
        pal["source"] = ("g04 (generic objects). Copy of h0-icon-mood-v02 palette_h0_mood.json (V1): every V1 colour, "
                         "material and style unchanged; added plant, mineral, water, building, cloth and genre "
                         "(modern / SF / cyberpunk / steampunk) materials in the same dark, desaturated value range.")
        for k, v in NEW_COLORS.items():
            assert k not in pal["colors"], k
            pal["colors"][k] = v
        for k, v in NEW_MATERIALS.items():
            assert k not in pal["materials"], k
            pal["materials"][k] = v
        (job / "recipes" / "palette_g04.json").write_text(json.dumps(pal, indent=1, ensure_ascii=False) + "\n",
                                                          encoding="utf-8")
        print("wrote", job / "recipes" / "palette_g04.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
