"""Stage 02 (모렌 저택) settings: palette (13C mansion: red-brown / ink-green /
wine / brass / grey grave clay) and the registry."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g06kit.palettes import GRIME_WOOD, TEX_WOOD, cloth, solid  # noqa: E402
from g06kit.stage import Stage, desat_palette  # noqa: E402

JOB = Path(__file__).resolve().parents[1]
PPM = 320.0

COLORS = {"clay_grey": "#7a766c", "soup": "#8a6a3e", "soup_skin": "#9c8058", "wine": "#4a1420", "rain": "#6d7a82",
          "night_sky": "#1c2129", "stain_disinfect": "#8a6a3a", "under_eye": "#6d7682", "powder": "#c9c3b4",
          "magnet_yellow": "#8e7a36"}
MATS = {
    "wall_green": solid("#3d4838", "#2d3529", "#4c5946", "#0e120c",
                        tex={"stamp": "leaf", "pre_rot": 45, "length": 40, "width": 8, "angle": 90, "jitter": 8,
                             "density": 0.8, "strength": 0.05}),
    "wall_green_dark": solid("#323b2e", "#242b21", "#404b3b", "#0b0e09"),
    "wainscot": solid("#4e3326", "#35221a", "#654335", "#120a06", side="#3e281e", side_shadow="#281a13",
                      tex=TEX_WOOD, grime=GRIME_WOOD),
    "wood_red": solid("#5c3a2c", "#3e2619", "#744a38", "#170c07", side="#4a2e23", side_shadow="#321e17",
                      tex=TEX_WOOD, grime=GRIME_WOOD),
    "wood_dark": solid("#4a3a28", "#30251a", "#614c35", "#110b06", side="#3a2d1f", side_shadow="#261d14",
                       tex=TEX_WOOD, grime=GRIME_WOOD),
    "wood_ochre": solid("#6a5334", "#473720", "#86693f", "#1a1109", side="#53412a", side_shadow="#372a1b",
                        tex=TEX_WOOD, grime=GRIME_WOOD),
    "parquet": solid("#4b3526", "#38281c", "#5d4432", "#120b06",
                     tex={"stamp": "pill", "pre_rot": -45, "length": 30, "width": 3, "angle": 0, "jitter": 4,
                          "density": 1.0, "strength": 0.12},
                     grime={"stamps": ["cloud", "sponge"], "size": 120, "soft": 14, "density": 0.08, "strength": 0.25,
                            "color": "grime", "lo": 0.2}),
    "marble_dark": solid("#4c4a4e", "#3a383c", "#5f5c62", "#121114",
                         tex={"stamp": "leaf", "pre_rot": 45, "length": 60, "width": 3, "angle": 30, "jitter": 40,
                              "density": 0.6, "strength": 0.1}),
    "marble_light": solid("#77736c", "#5d5a54", "#8c8880", "#1e1d1a",
                          tex={"stamp": "leaf", "pre_rot": 45, "length": 60, "width": 3, "angle": 30, "jitter": 40,
                               "density": 0.6, "strength": 0.1}),
    "cloth_wine": cloth("#5a2b33", "#3a1a21", "#744049", "#1a080c", angle=90, strength=0.08, grime=0.2, stamp="leaf"),
    "curtain_green": cloth("#445240", "#2e382b", "#586a53", "#0e120c", angle=90, strength=0.08, grime=0.2, stamp="leaf"),
    "tablecloth": solid("#a8a292", "#838071", "#bdb7a6", "#3a362d",
                        tex={"stamp": "leaf", "pre_rot": 45, "length": 18, "width": 3, "angle": 0, "jitter": 10,
                             "density": 0.6, "strength": 0.05}),
    "clay_grey": solid("#7a766c", "#5c5951", "#8e8a80", "#1e1c18",
                       tex={"stamp": "metaballs", "pre_rot": 0, "length": 8, "width": 8, "angle": 0, "jitter": 40,
                            "density": 0.8, "strength": 0.15}),
    "mud": solid("#3e362c", "#2c261f", "#4e453a", "#0e0b08"),
    "grass_dark": solid("#323a2c", "#232a1f", "#414b39", "#0b0e09",
                        tex={"stamp": "leaf", "pre_rot": 45, "length": 14, "width": 3, "angle": 90, "jitter": 30,
                             "density": 1.2, "strength": 0.14}),
    "stone_wall": solid("#56525a", "#3f3c44", "#6a656e", "#121014", side="#3d3a41", side_shadow="#28262b",
                        tex={"stamp": "leaf", "pre_rot": 45, "length": 14, "width": 3.5, "angle": 0, "jitter": 14,
                             "density": 0.9, "strength": 0.09},
                        grime={"stamps": ["cloud", "droplet"], "size": 60, "soft": 6, "density": 0.1, "strength": 0.35,
                               "color": "damp", "lo": 0.25}),
    "glass_booth": solid("#46545e", "#34404a", "#6a7a84", "#10161a", shade={"threshold": 0.4, "highlight_amount": 0.6}),
    "glass_rain": solid("#3a4650", "#2b353d", "#56646e", "#0c1115", shade={"threshold": 0.4, "highlight_amount": 0.6}),
    # people (13A-1 Stage 2, darkened to V1 values; mourning clothes for the funeral evening)
    "mourning_black": cloth("#2b2729", "#1b181a", "#3d383b", "#070506", angle=90, strength=0.06, grime=0.1),
    "suit_brown": cloth("#3e3029", "#2a201b", "#52413a", "#0c0907", angle=90, strength=0.06, grime=0.12),
    "suit_greybrown": cloth("#443a34", "#2d2622", "#584c45", "#0e0c0a", angle=90, strength=0.06, grime=0.12),
    "dress_navy": cloth("#323e4c", "#222a35", "#44536a", "#0a0d12", angle=90, strength=0.06, grime=0.12),
    "cardigan_greybrown": cloth("#6d655c", "#4f4943", "#837a70", "#1e1b18", angle=0, strength=0.12, grime=0.12, stamp="leaf"),
    "jacket_plum": cloth("#473b45", "#30272f", "#5c4d59", "#0e0b0d", angle=90, strength=0.07, grime=0.12),
    "blouse_cream": cloth("#b1a88f", "#877f69", "#c6bda3", "#3e372b", angle=85, strength=0.05, grime=0.1),
    "shirt_white": cloth("#a7a396", "#7b776c", "#bdb8a9", "#37332c", angle=85, strength=0.05, grime=0.18),
    "vest_darkbrown": cloth("#3f352e", "#2a231e", "#534740", "#0c0a08", angle=0, strength=0.1, grime=0.12, stamp="leaf"),
    "apron_black": cloth("#232022", "#161415", "#343033", "#060506", angle=90, strength=0.06, grime=0.1),
    "suit_threepiece": cloth("#3a322d", "#27211d", "#4d433d", "#0b0908", angle=90, strength=0.06, grime=0.1),
    "skirt_dark": cloth("#3a3036", "#262024", "#4d4249", "#0c0a0b", angle=90, strength=0.06, grime=0.1),
    "tie_green": solid("#2f4034", "#1f2b23", "#3d5444", "#0a100c"),
    "stocking_dark": solid("#2a2527", "#1a1718", "#3a3437", "#070606"),
    "glove_grey": solid("#6c6966", "#4f4d4a", "#817e7a", "#1b1a19"),
    "hair_auburn_grey": solid("#5e4238", "#3f2c25", "#7a5a4e", "#140d0a"),
    "hair_chestnut": solid("#4a2e22", "#311e16", "#633f2f", "#100906"),
    "hair_greyish_brown": solid("#6b6159", "#4c453f", "#82766d", "#171412"),
    "hair_silver": solid("#a6a39c", "#7b7872", "#c0bdb5", "#2e2c29"),
}

S = Stage(JOB, 2, "palette_s02_morren",
          "Stage 02 Morren mansion: ink-green wallpaper, red-brown wood, wine and moss cloth, brass, grey grave clay "
          "(13C); mourning clothes and identity colours of the Morrens, Silla Beck, Yona Pale, Peter Rohn (13A-1).",
          COLORS, MATS)
S.extra_palettes.append(("palette_s02_sepia.json", lambda p: desat_palette(
    p, "palette_s02_sepia", "Sepia variant for the old family photographs (A2).", tint=(0.74, 0.64, 0.5), amount=0.9)))
asset = S.asset
PAL = S.pal
PAL_SEPIA = "palette_s02_sepia.json"
