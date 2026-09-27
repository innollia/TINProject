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
    f = cloud_forms(1, dy=-8)
    f.append(drops(0, [[40, 96], [62, 100], [84, 96], [52, 116], [74, 118]]))
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


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
