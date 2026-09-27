"""Build recipes/palette_props.json = palette_h0_mood.json + prop materials.

Dark, worn value structure: base well under 0.5 luma, chroma kept low, every
material carries explicit side / side_shadow so `kind: block` extrusions read.

    py -3 -B _gen/mkpalette.py
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
REC = JOB / "recipes"

MINERAL_TEX = {"stamp": "leaf", "pre_rot": 45, "length": 14, "width": 3.5, "angle": 0,
               "jitter": 14, "density": 0.9, "strength": 0.09}
MINERAL_GRIME = {"stamps": ["metaballs", "cloud"], "size": 30, "soft": 3,
                 "density": 0.35, "strength": 0.35, "color": "grime"}
METAL_GRIME = {"stamps": ["metaballs", "sponge"], "size": 16, "soft": 1.5,
               "density": 0.4, "strength": 0.45, "color": "rust"}
WOOD_TEX = {"stamp": "pill", "pre_rot": -45, "length": 22, "width": 2.2, "angle": 0,
            "jitter": 4, "density": 0.9, "strength": 0.12}

#  name            base     shadow   light    side     side_shadow  line
MATERIALS: dict[str, dict] = {}


def mat(name, base, shadow, light, side, side_shadow, line, **extra):
    MATERIALS[name] = {"base": base, "shadow": shadow, "light": light,
                       "side": side, "side_shadow": side_shadow, "line": line, **extra}


# ---- ores and gems -----------------------------------------------------------
mat("coal", "#2a2730", "#191720", "#3c3846", "#1e1c25", "#131219", "#08070a",
    texture=MINERAL_TEX, grime={"stamps": ["cloud", "metaballs"], "size": 26, "soft": 3,
                                "density": 0.4, "strength": 0.5, "color": "soot"})
mat("iron_bar", "#3e4048", "#26272d", "#62656f", "#2c2d33", "#1b1c20", "#0b0b0e",
    shade={"highlight": 0.86, "highlight_amount": 0.55}, grime=METAL_GRIME)
mat("copper_bar", "#6d4b39", "#4a3227", "#8d6851", "#513728", "#34231a", "#180f0a",
    shade={"highlight": 0.86, "highlight_amount": 0.5}, grime=METAL_GRIME)
mat("gold_bar", "#8a7434", "#5e4e21", "#ad9450", "#6a5728", "#453a1a", "#181206",
    shade={"highlight": 0.88, "highlight_amount": 0.55}, grime=METAL_GRIME)
mat("redstone", "#7a2b30", "#4f1b1f", "#9a3d42", "#571f24", "#38151a", "#170709",
    texture=MINERAL_TEX, shade={"threshold": 0.42, "highlight_amount": 0.6},
    grime={"stamps": ["metaballs"], "size": 20, "soft": 2, "density": 0.3, "strength": 0.3, "color": "soot"})
mat("emerald", "#2f5a3c", "#1d3a27", "#42744f", "#25432e", "#182b1f", "#0a140e",
    shade={"threshold": 0.4, "highlight_amount": 0.65})
mat("lapis", "#2b3f6b", "#1b2a48", "#3d568c", "#22335a", "#152037", "#080d18",
    texture=MINERAL_TEX, grime=MINERAL_GRIME)
mat("diamond", "#7f93a0", "#5a6b76", "#a4b6c1", "#6b7d88", "#48565f", "#141a1e",
    shade={"threshold": 0.36, "highlight_amount": 0.7})
mat("netherite", "#332b31", "#1f1a1f", "#463c43", "#282228", "#171317", "#080608",
    texture=MINERAL_TEX, shade={"highlight": 0.8, "highlight_amount": 0.4},
    grime={"stamps": ["cloud"], "size": 24, "soft": 3, "density": 0.35, "strength": 0.3, "color": "soot"})
mat("nether_quartz", "#8e858a", "#6e666b", "#b0a8ac", "#7d757a", "#5a5357", "#1a1518",
    shade={"threshold": 0.38, "highlight_amount": 0.65})
mat("amethyst", "#5b4470", "#3c2c4c", "#7a5e92", "#4b3a5d", "#31253e", "#120c18",
    shade={"threshold": 0.38, "highlight_amount": 0.65})
mat("patina", "#3f5a4e", "#2a3f37", "#54756a", "#31473e", "#1f2e28", "#0a1210",
    grime={"stamps": ["sponge"], "size": 12, "soft": 1.5, "density": 0.4, "strength": 0.4, "color": "damp"})

# ---- general materials -------------------------------------------------------
mat("stick_wood", "#54432f", "#362a1e", "#6e5a3f", "#3f3123", "#2a2018", "#120c08",
    texture=WOOD_TEX, grime={"stamps": ["metaballs", "cloud"], "size": 18, "soft": 2,
                             "density": 0.3, "strength": 0.3, "color": "grime"})
mat("flint", "#4a4750", "#332f38", "#66626d", "#3a3740", "#26242b", "#0c0a0e",
    texture={"stamp": "leaf", "pre_rot": 45, "length": 8, "width": 3, "angle": 30,
             "jitter": 40, "density": 0.9, "strength": 0.1},
    grime={"stamps": ["metaballs", "cloud"], "size": 26, "soft": 2, "density": 0.3, "strength": 0.3, "color": "soot"})
mat("wheat_straw", "#8a7440", "#5f4f2b", "#a8914f", "#6d5c33", "#4a3d22", "#1c160a",
    texture={"stamp": "pill", "pre_rot": -45, "length": 16, "width": 2, "angle": 0,
             "jitter": 6, "density": 0.9, "strength": 0.1})
mat("snow", "#9ea2ae", "#767a86", "#c0c3cd", "#868a96", "#61646f", "#22242b",
    grime={"stamps": ["cloud"], "size": 20, "soft": 3, "density": 0.25, "strength": 0.18, "color": "floor_light"})
mat("egg_shell", "#b0a691", "#857c69", "#cbc2ad", "#948b78", "#6a6254", "#2c261d",
    grime={"stamps": ["sponge", "metaballs"], "size": 10, "soft": 1.0, "density": 0.25,
           "strength": 0.28, "color": "foxing"})
mat("wax", "#967a3c", "#6a5527", "#b39654", "#7d6630", "#564520", "#1f1708",
    texture={"stamp": "hexagon", "pre_rot": 0, "length": 6, "width": 2, "angle": 30,
             "jitter": 10, "density": 0.6, "strength": 0.12})
mat("honey", "#6a4a20", "#452f13", "#87642f", "#523a19", "#372511", "#0e0904",
    shade={"highlight": 0.9, "highlight_amount": 0.55})
mat("clay", "#6b5f66", "#4c434a", "#877a81", "#564d54", "#3a3339", "#120e12",
    grime={"stamps": ["metaballs", "sponge"], "size": 20, "soft": 2, "density": 0.3,
           "strength": 0.3, "color": "damp"})
mat("clay_dark", "#4a4046", "#332c31", "#5f535a", "#3c3439", "#282226", "#0d0a0d")
mat("brick_clay", "#6d4a3e", "#4a3129", "#876154", "#553830", "#3a2620", "#160e0b",
    texture={"stamp": "sponge", "pre_rot": 0, "length": 9, "width": 3, "angle": 0,
             "jitter": 20, "density": 0.7, "strength": 0.1},
    grime={"stamps": ["cloud"], "size": 18, "soft": 2, "density": 0.3, "strength": 0.28, "color": "grime"})
mat("firework_paper", "#71414a", "#4a2a31", "#8d5762", "#57313a", "#3a2028", "#140a0d",
    texture={"stamp": "pill", "pre_rot": -45, "length": 10, "width": 2, "angle": 0,
             "jitter": 8, "density": 0.7, "strength": 0.1})
mat("scute", "#5b5347", "#3f382f", "#7a7062", "#4a4238", "#312b23", "#100d0a",
    texture={"stamp": "leaf", "pre_rot": 45, "length": 9, "width": 3, "angle": 0,
             "jitter": 25, "density": 0.8, "strength": 0.1},
    grime={"stamps": ["cloud", "metaballs"], "size": 20, "soft": 2, "density": 0.3,
           "strength": 0.3, "color": "grime"})


def main() -> int:
    base = json.loads((REC / "palette_h0_mood.json").read_text(encoding="utf-8"))
    base["id"] = "palette_props"
    base["source"] = ("palette_h0_mood + prop materials for generic/jobs/props-v01. "
                      "Added materials keep the same dark worn value structure; nothing "
                      "was taken from a rendered reference.")
    base["materials"].update(MATERIALS)
    out = REC / "palette_props.json"
    out.write_text(json.dumps(base, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(out, len(base["materials"]), "materials")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

