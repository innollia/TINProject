"""g07-icons-v01 recipes: 128x128 flat icons (forecast symbols, desktop icons, board-game pieces).

    py -3 -B gen_icons.py [A|B|C ...]      # writes ../recipes/icon_*.json

No letters or numbers: dice use pips, desktop icons use shapes only.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import annulus, disc, form, frame, piece, recipe, rrect, ticks, variant, write  # noqa: E402

C = (64, 64)
NOTE = "g07 future-kit icon (128, flat, no text). at-icons collage, candidate."


def icon(asset, forms, seed, what, frames=None):
    return recipe(asset, [128, 128], forms, pivot=C, seed=seed, frames=frames, pivot_meaning="icon centre",
                  note=NOTE + " " + what)


# ------------------------------------------------------------------ forecast
def cloud_forms(z, dx=0, dy=0, back="ash", front="salt", scale=1.0):
    s = scale
    return [
        form("cloud_back", z, [piece("cloud", [70 + dx, 46 + dy], [70 * s, 46 * s])], back, shade={"bump": 0.8}),
        form("cloud_front", z + 0.1, [piece("cloud", [54 + dx, 58 + dy], [88 * s, 58 * s], flip="x")], front,
             shade={"bump": 0.9}),
        form("cloud_base", z + 0.2, [rrect([58 + dx, 76 + dy], [76 * s, 14 * s], corner=7)], front, shade={"bump": 0.6}),
    ]


def fc_sun():
    f = [
        ticks("rays_long", 0, C, 45, 8, 0, 360, 22, 13, "paint_ochre", kind="mass", icon="triangle"),
        ticks("rays_short", 0, C, 42, 8, 22.5, 382.5, 12, 8, "bronze", kind="mass", icon="triangle"),
        form("disc", 1, [disc(C, 58)], "paint_ochre", shade={"bump": 1.1, "highlight_amount": 0.6}),
        form("core", 1.5, [disc([60, 60], 30)], "wax", kind="flat", opacity=0.22),
    ]
    return icon("icon_fc_sun", f, 51, "Forecast symbol: clear.")


def fc_cloud():
    return icon("icon_fc_cloud", cloud_forms(0, dy=4), 52, "Forecast symbol: cloudy.")


def drops(z, pts, up=False, name="drops"):
    ps = [piece("droplet", p, [13, 20], rot=12, **({"flip": "y"} if up else {})) for p in pts]
    return form(name, z, ps, "crystal", shade={"bump": 0.8})


def fc_rain():
    f = cloud_forms(1, dy=-14)
    f.append(drops(0, [[40, 88], [62, 92], [84, 88], [52, 108], [74, 110]]))
    return icon("icon_fc_rain", f, 53, "Forecast symbol: rain.")


def fc_rain_up():
    f = [
        form("puddle", 0, [disc([64, 108], [96, 24])], "water", shade={"bump": 0.5}),
        form("ripple", 0.5, [disc([62, 106], [60, 12]), disc([62, 106], [46, 7], op="sub")], "glare", kind="flat",
             opacity=0.25),
        form("streaks", 1, [rrect([44, 86], [3, 18], corner=1), rrect([66, 72], [3, 22], corner=1),
                            rrect([88, 82], [3, 18], corner=1), rrect([56, 46], [3, 16], corner=1),
                            rrect([80, 40], [3, 16], corner=1)], "crystal", kind="flat", opacity=0.55),
        drops(2, [[44, 72], [66, 56], [88, 68], [56, 30], [80, 24]], up=True),
    ]
    return icon("icon_fc_rain_up", f, 54, "Forecast symbol: rain falling upward out of a puddle.")


# ------------------------------------------------------------------ desktop
def os_folder():
    f = [
        form("back", 0, [rrect([64, 64], [104, 76], corner=8), rrect([40, 28], [40, 18], corner=5)], "paint_ochre",
             shade={"bump": 0.7}),
        form("sheet_a", 1, [rrect([58, 44], [66, 50], corner=3, rot=-7)], "paper", shade={"bump": 0.4}),
        form("sheet_b", 1.1, [rrect([72, 46], [62, 46], corner=3, rot=6)], "paper", shade={"bump": 0.4}),
        form("front", 2, [rrect([64, 78], [108, 58], corner=8, skew=[-10, 0])], "paint_ochre",
             shade={"bump": 0.8, "highlight_amount": 0.4}),
        form("front_edge", 2.5, [rrect([62, 54], [98, 4], corner=2)], "glare", kind="flat", opacity=0.14),
    ]
    return icon("icon_os_folder", f, 55, "Desktop icon: folder.")


def os_trash():
    f = [
        form("crumple", 0, [piece("metaballs", [48, 32], [32, 22], rot=20), piece("sponge", [76, 32], [22, 18])], "paper",
             shade={"bump": 0.6}),
        form("bin", 1, [piece("trash_can", [64, 74], [80, 90], crop=[1, 5.6, 15, 16])], "steel",
             shade={"bump": 0.9}),
        form("ribs", 1.5, [rrect([48, 78], [4, 48], corner=2), rrect([64, 80], [4, 50], corner=2),
                           rrect([80, 78], [4, 48], corner=2)], "dial_mark", kind="flat", opacity=0.45, clip_to="bin"),
        form("lid", 2, [rrect([62, 22], [92, 12], corner=4, rot=-8), rrect([60.7, 13.1], [28, 9], corner=3, rot=-8)],
             "steel", shade={"bump": 0.9}),
    ]
    return icon("icon_os_trash", f, 56, "Desktop icon: trash can with crumpled paper.")


def os_file():
    f = [
        form("sheet", 0, [piece("file", [64, 64], [82, 102])], "paper", shade={"bump": 0.45}),
        form("lines", 1, [rrect([56, 50], [42, 5], corner=2), rrect([60, 62], [50, 5], corner=2),
                          rrect([60, 74], [50, 5], corner=2), rrect([52, 86], [34, 5], corner=2)],
             "paper_mark", kind="flat", opacity=0.75, clip_to="sheet"),
        form("tab", 1.5, [rrect([44, 100], [22, 9], corner=3)], "cloth_wine", kind="flat", opacity=0.8, clip_to="sheet"),
    ]
    return icon("icon_os_file", f, 57, "Desktop icon: document file (empty lines, no text).")


def os_chat():
    f = [
        form("bubble_b", 0, [piece("speech_bubble", [84, 76], [66, 56], flip="x")], "cloth_wine", shade={"bump": 0.8}),
        form("bubble_a", 1, [piece("speech_bubble", [54, 54], [92, 76])], "paint_teal", shade={"bump": 0.8}),
        form("dots", 2, [disc([34, 50], 12), disc([54, 50], 12), disc([74, 50], 12)], "enamel", kind="flat",
             opacity=0.9),
    ]
    return icon("icon_os_chat", f, 58, "Desktop icon: messenger.")


# ------------------------------------------------------------------ board game
PAWN_COLOURS = {"wine": "cloth_wine", "teal": "paint_teal", "ochre": "paint_ochre", "violet": "paint_violet",
                "bone": "bone", "charcoal": "plastic_dark"}


def bg_pawn():
    sh = {"bump": 1.25, "highlight_amount": 0.55}
    f = [
        form("base", 0, [rrect([64, 106], [74, 18], corner=8)], "cloth_wine", tags=["pawn"], shade=sh),
        form("body", 1, [piece("triangle", [64, 76], [56, 62])], "cloth_wine", tags=["pawn"], shade=sh),
        form("collar", 2, [rrect([64, 52], [40, 10], corner=5)], "cloth_wine", tags=["pawn"], shade=sh),
        form("head", 3, [disc([64, 34], 36)], "cloth_wine", tags=["pawn"], shade=sh),
    ]
    frames = [frame(k, materials={"pawn": v}) for k, v in PAWN_COLOURS.items()]
    return icon("icon_bg_pawn", f, 59, "Board-game pawn, six colours.", frames=frames)


PIPS = {"tl": (40, 40), "tr": (88, 40), "ml": (40, 64), "mr": (88, 64), "bl": (40, 88), "br": (88, 88), "c": (64, 64)}
FACES = {1: ["one"], 2: ["tl", "br"], 3: ["tl", "c", "br"], 4: ["tl", "tr", "bl", "br"], 5: ["tl", "tr", "bl", "br", "c"],
         6: ["tl", "tr", "ml", "mr", "bl", "br"]}


def bg_die():
    f = [
        form("side", 0, [rrect([68, 69], [100, 100], corner=18)], "salt", shade={"bump": 0.4}),
        form("face", 1, [rrect([62, 62], [100, 100], corner=18)], "bone", shade={"bump": 0.55, "highlight_amount": 0.4}),
    ]
    for key, p in PIPS.items():
        f.append(variant(form(f"pip_{key}", 2, [disc([p[0] - 2, p[1] - 2], 17)], "dial_mark", kind="flat"), key))
    f.append(variant(form("pip_one", 2, [disc([62, 62], 22)], "zone_red", kind="flat"), "one"))
    frames = [frame(f"face_{n}", show=tags) for n, tags in FACES.items()]
    return icon("icon_bg_die", f, 60, "Six-sided die, faces 1-6 as pips.", frames=frames)


def stage_a():
    return [fc_sun(), fc_cloud(), fc_rain(), fc_rain_up(), os_folder(), os_trash(), os_file(), os_chat(), bg_pawn(),
            bg_die()]


STAGES = {"A": stage_a}


# ------------------------------------------------------------------ B
def flakes(z, pts, size=24, name="flakes", mat="bone"):
    return form(name, z, [piece("snowflake", p, [size, size], rot=15 * i) for i, p in enumerate(pts)], mat,
                shade={"bump": 0.4}, line=False)


def fc_snow():
    f = cloud_forms(1, dy=-14)
    f.append(flakes(0, [[38, 90], [66, 98], [94, 88], [52, 112], [82, 112]], size=22))
    return icon("icon_fc_snow", f, 61, "Forecast symbol: snow.")


def fc_storm():
    f = cloud_forms(1, dy=-10, back="stone_dark", front="ash")
    f += [form("bolt", 2, [piece("lightning_bolt", [66, 92], [34, 48], rot=8)], "paint_ochre", shade={"bump": 1.0}),
          drops(0, [[36, 94], [94, 96], [48, 110]])]
    return icon("icon_fc_storm", f, 62, "Forecast symbol: thunderstorm.")


def fc_fog():
    f = [form("cloud", 0, [piece("cloud", [66, 40], [90, 58])], "ash", shade={"bump": 0.7})]
    bars = [([58, 66], [96, 18]), ([72, 88], [88, 18]), ([56, 110], [80, 18])]
    f += [form(f"bank_{i}", 1 + i * 0.1, [rrect(p, s, corner=9)], "salt", opacity=0.9 - 0.12 * i, blur=0.8,
               shade={"bump": 0.4}) for i, (p, s) in enumerate(bars)]
    return icon("icon_fc_fog", f, 63, "Forecast symbol: fog.")


def fc_snow_indoor():
    f = [
        form("house", 0, [piece("house", [64, 66], [104, 96])], "steel_dark", shade={"bump": 0.6}),
        form("room", 1, [rrect([64, 84], [58, 48], corner=3)], "coat_dark", kind="flat"),
        flakes(2, [[52, 76], [76, 82], [62, 100]], size=18, name="flakes_in"),
        form("sill", 2.5, [rrect([64, 108], [60, 6], corner=2)], "salt", kind="flat", opacity=0.8),
    ]
    return icon("icon_fc_snow_indoor", f, 64, "Forecast symbol: snow indoors only (sun-dry outside).")


def os_mail():
    f = [
        form("envelope", 0, [rrect([62, 68], [100, 70], corner=6)], "paper", shade={"bump": 0.4}),
        form("flap", 1, [piece("triangle", [62, 52], [100, 44], rot=180)], "paper_mark", kind="flat", opacity=0.7,
             clip_to="envelope"),
        form("seal", 2, [disc([62, 72], 18)], "cloth_wine", shade={"bump": 1.1}),
        form("badge", 3, [disc([104, 30], 28)], "paint_red", shade={"bump": 1.1}),
        form("badge_dot", 3.5, [disc([104, 30], 8)], "bone", kind="flat"),
    ]
    return icon("icon_os_mail", f, 65, "Desktop icon: mail with an unread badge (no number).")


def os_web():
    f = [
        form("globe", 0, [disc([60, 60], 88)], "paint_teal", shade={"bump": 1.0}),
        form("lands", 1, [piece("globe", [60, 60], [88, 88])], "paint_olive", kind="flat", opacity=0.55, clip_to="globe"),
        form("orbit", 2, [disc([62, 62], [118, 40], rot=-20), disc([62, 60], [104, 28], rot=-20, op="sub")], "bronze",
             kind="flat", opacity=0.9),
        form("arrow", 3, [piece("cursor", [100, 100], [30, 40])], "bone", shade={"bump": 0.5}),
    ]
    return icon("icon_os_web", f, 66, "Desktop icon: web browser.")


def os_settings():
    f = [
        form("cog_big", 0, [piece("cog", [56, 58], [84, 84])], "steel", shade={"bump": 1.0}),
        form("cog_big_hole", 0.5, [disc([56, 58], 26)], "steel_dark", kind="flat"),
        form("cog_small", 1, [piece("cog", [94, 92], [48, 48], rot=20)], "bronze", shade={"bump": 1.0}),
        form("cog_small_hole", 1.5, [disc([94, 92], 14)], "steel_dark", kind="flat"),
    ]
    return icon("icon_os_settings", f, 67, "Desktop icon: settings (two gears).")


def os_terminal():
    f = [
        form("window", 0, [rrect([64, 64], [108, 92], corner=8)], "plastic_dark", shade={"bump": 0.5}),
        form("bar", 1, [rrect([64, 26], [102, 14], corner=4)], "steel", kind="flat"),
        form("screen", 1, [rrect([64, 72], [96, 66], corner=4)], "screen", kind="flat"),
        form("prompt", 2, [rrect([36, 62], [18, 6], corner=2, rot=35), rrect([36, 72], [18, 6], corner=2, rot=-35)],
             "phosphor", kind="flat", emit=0.6),
        form("block", 2, [rrect([60, 68], [16, 10], corner=1)], "phosphor", kind="flat", emit=0.6),
    ]
    return icon("icon_os_terminal", f, 68, "Desktop icon: command window (prompt chevron and cursor block).")


def os_webcam():
    f = [
        form("stand", 0, [rrect([64, 104], [54, 12], corner=5), rrect([64, 92], [10, 20], corner=3)], "steel_dark"),
        form("body", 1, [disc([64, 56], 76)], "plastic_dark", shade={"bump": 1.0}),
        form("lens_ring", 2, [disc([64, 56], 46)], "steel", shade={"bump": 1.1}),
        form("lens", 2.5, [disc([64, 56], 30)], "screen_glass", shade={"bump": 1.2}),
        form("lens_glint", 3, [disc([58, 50], 8)], "glare", kind="flat", opacity=0.5),
        form("tally", 3, [disc([92, 30], 12)], "lamp_red_on", emit=1.0, glow={"radius": 4, "opacity": 0.6,
                                                                               "color": "glow_red"}),
    ]
    return icon("icon_os_webcam", f, 69, "Desktop icon: streaming webcam with a lit tally lamp.")


def stage_b():
    return [fc_snow(), fc_storm(), fc_fog(), fc_snow_indoor(), os_mail(), os_web(), os_settings(), os_terminal(),
            os_webcam()]


STAGES["B"] = stage_b


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
