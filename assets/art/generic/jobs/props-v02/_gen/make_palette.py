"""Create recipes/palette_props.json = palette_h0_mood.json + the materials this job needs.

palette_h0_mood.json is never touched; this only writes the new file.
Run:  py -3 -B _gen\make_palette.py
"""

import json
import pathlib

JOB = pathlib.Path(__file__).resolve().parents[1]
SRC = JOB / "recipes" / "palette_h0_mood.json"
DST = JOB / "recipes" / "palette_props.json"

ADDED = {
    # --- bone / thread / leather family -----------------------------------
    "bone": {"base": "#c3b79a", "shadow": "#94886c", "light": "#ded3b4", "line": "#3a3226",
             "texture": {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 3, "angle": 20,
                         "jitter": 14, "density": 0.7, "strength": 0.05},
             "grime": {"stamps": ["sponge", "cloud"], "size": 15, "soft": 1.0, "density": 0.3,
                       "strength": 0.32, "color": "foxing"}},
    "thread": {"base": "#a2977c", "shadow": "#776e58", "light": "#c6bba0", "line": "#3b3428"},
    "ink_sac": {"base": "#0e0d16", "shadow": "#06060c", "light": "#2f2c40", "line": "#020105",
                "shade": {"threshold": 0.42, "highlight": 0.88, "highlight_amount": 0.7}},
    # --- nether / end family ----------------------------------------------
    "nether_star": {"base": "#b8a781", "shadow": "#8a7c58", "light": "#d4c69c", "line": "#463c26",
                    "shade": {"highlight": 0.9, "highlight_amount": 0.4}},
    "breeze_rod": {"base": "#9aa3a8", "shadow": "#6a7276", "light": "#c4cdd2", "line": "#2f3639",
                   "shade": {"highlight": 0.88, "highlight_amount": 0.6}},
    "crystal": {"base": "#b4a3b9", "shadow": "#85758b", "light": "#dbcfdf", "line": "#423a46",
                "shade": {"threshold": 0.4, "highlight_amount": 0.65, "highlight": 0.9}},
    "echo_stone": {"base": "#68727c", "shadow": "#47505a", "light": "#8b959e", "line": "#21262c",
                   "shade": {"highlight": 0.9, "highlight_amount": 0.5}},
    "scute": {"base": "#545838", "shadow": "#383b26", "light": "#6e7350", "line": "#191b0f",
              "texture": {"stamp": "hexagon", "pre_rot": 0, "length": 10, "width": 3, "angle": 0,
                          "jitter": 18, "density": 0.5, "strength": 0.12}},
    # --- powders (one shared mound, four colours) ---------------------------
    "redstone": {"base": "#7a2a26", "shadow": "#501a18", "light": "#9b4038", "line": "#1e0707"},
    "glowstone": {"base": "#b3964f", "shadow": "#826b36", "light": "#d6b76c", "line": "#382d13"},
    "gunpowder": {"base": "#3a3a41", "shadow": "#24242a", "light": "#57575f", "line": "#0b0b0f"},
    "blaze_powder": {"base": "#9e652c", "shadow": "#6d421b", "light": "#c2884a", "line": "#2f1a07"},
    # --- organic lumps / goo -------------------------------------------------
    "slime": {"base": "#3f5a44", "shadow": "#28392b", "light": "#5d8064", "line": "#111b14",
              "shade": {"threshold": 0.42, "highlight": 0.86, "highlight_amount": 0.6}},
    "resin": {"base": "#87672f", "shadow": "#5a4320", "light": "#ae8a4a", "line": "#281c0d",
              "shade": {"threshold": 0.42, "highlight": 0.88, "highlight_amount": 0.6}},
    "magma_cream": {"base": "#8a4723", "shadow": "#5b2d14", "light": "#b16635", "line": "#281205",
                    "shade": {"threshold": 0.42, "highlight": 0.88, "highlight_amount": 0.6}},
    "nether_wart": {"base": "#5e2a26", "shadow": "#3c1917", "light": "#7d3f36", "line": "#180807"},
    "spider_eye": {"base": "#6a3a30", "shadow": "#43231e", "light": "#8c5349", "line": "#1d0c0a"},
    "ghast_tear": {"base": "#a4b0b5", "shadow": "#758085", "light": "#ccd6d9", "line": "#363d41",
                   "shade": {"threshold": 0.4, "highlight": 0.86, "highlight_amount": 0.7}},
    "membrane": {"base": "#93938b", "shadow": "#6b6b64", "light": "#b7b7ae", "line": "#35352f"},
    "dragon_breath": {"base": "#a4928a", "shadow": "#756560", "light": "#c9bbb1", "line": "#372c28"},
    # --- made objects --------------------------------------------------------
    "coral": {"base": "#96685a", "shadow": "#67453a", "light": "#b98a76", "line": "#2f1e18"},
    "ceramic": {"base": "#a89a86", "shadow": "#7b7061", "light": "#c9bda8", "line": "#38312a"},
    "glass_bottle": {"base": "#8a9583", "shadow": "#5c6558", "light": "#c3d0b6", "line": "#252a22",
                     "shade": {"threshold": 0.35, "highlight": 0.88, "highlight_amount": 0.7}},
    "sugar": {"base": "#b8b3a4", "shadow": "#8b877a", "light": "#dbd7c8", "line": "#3e3b33",
              "shade": {"highlight": 0.9, "highlight_amount": 0.5}},
    "melon_flesh": {"base": "#8d9059", "shadow": "#676a3f", "light": "#adb089", "line": "#2b2c18"},
}


def main() -> int:
    data = json.loads(SRC.read_text(encoding="utf-8"))
    data["id"] = "palette_props"
    data["source"] = ("palette_h0_mood copied verbatim (colors + styles unchanged). materials extended "
                      "for the generic loot / dye / brewing prop job: all added materials are low-value, "
                      "low-saturation tones in the same family as the base palette (nether star #c9b78f, "
                      "slime #3f5a44, breeze rod #9aa3a8, ...).")
    for name, mat in ADDED.items():
        if name in data["materials"]:
            raise SystemExit(f"material already in base palette: {name}")
        data["materials"][name] = mat
    DST.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {DST.name}  materials={len(data['materials'])} (+{len(ADDED)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
