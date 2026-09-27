"""g07-screens-v01 recipes: special screen UI (scopes, retro OS, rhythm, stamps, overlays).

    py -3 -B gen_screens.py [A|B|C ...]      # writes ../recipes/*.json

Flat front view.  No text anywhere: title bars, counters and labels are empty
shapes the game fills.  Moving / lit parts are separate recipes or frames and
lit parts go to ``_emit.png``.
"""

from __future__ import annotations

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import (annulus, disc, dots, form, frame, glare, piece, recipe, rrect, screws, sector,  # noqa: E402
                    ticks, variant, write)

NOTE = "g07 future-kit screen UI (flat, no text). at-icons collage, candidate."
NO_SIL = {"silhouette": False}


def ring_pts(c, r, angles):
    return [[round(c[0] + r * math.cos(math.radians(a)), 2), round(c[1] + r * math.sin(math.radians(a)), 2)]
            for a in angles]


# ------------------------------------------------------------------ scopes
def sonar():
    c = (192, 192)
    f = [
        annulus("bezel", 0, c, 190, 156, "steel_dark", shade={"bump": 1.1}),
        annulus("lip", 1, c, 158, 150, "bronze", shade={"bump": 1.2}),
        form("screen", 2, [disc(c, 302)], "screen", shade={"bump": 0.35, "highlight_amount": 0.2}),
        form("inner_glow", 2.5, [disc(c, 230)], "phosphor_dim", kind="flat", opacity=0.10, blur=18, clip_to="screen"),
        annulus("ring_1", 3, c, 113.2, 111.6, "phosphor_dim", kind="flat", opacity=0.85, emit=0.35),
        annulus("ring_2", 3, c, 75.8, 74.2, "phosphor_dim", kind="flat", opacity=0.85, emit=0.35),
        annulus("ring_3", 3, c, 38.4, 36.8, "phosphor_dim", kind="flat", opacity=0.85, emit=0.35),
        form("cross", 3, [rrect(c, [2.2, 296], corner=1), rrect(c, [296, 2.2], corner=1)], "phosphor_dim", kind="flat",
             opacity=0.75, emit=0.35, clip_to="screen"),
        ticks("bearing_minor", 3.2, c, 144, 72, 0, 360, 6, 1.6, "phosphor_dim", opacity=0.85, emit=0.35),
        ticks("bearing_major", 3.3, c, 141, 12, 0, 360, 12, 2.8, "phosphor_dim", emit=0.4),
        glare("glass_glare", 4, c, 302, "screen", opacity=0.07),
    ]
    f += screws("screws", 5, ring_pts(c, 173, range(22, 360, 45)), d=10, material="steel")
    sweep = [
        form("trail_a", 1, [sector(c, 150, -150, -90)], "phosphor", kind="flat", opacity=0.08, emit=1.0),
        form("trail_b", 1.1, [sector(c, 150, -122, -90)], "phosphor", kind="flat", opacity=0.10, emit=1.0),
        form("trail_c", 1.2, [sector(c, 150, -106, -90)], "phosphor", kind="flat", opacity=0.14, emit=1.0),
        form("trail_d", 1.3, [sector(c, 150, -96, -90)], "phosphor", kind="flat", opacity=0.26, emit=1.0),
        form("edge", 2, [rrect([192, 117], [3, 150], corner=1)], "phosphor", kind="flat", opacity=0.9, emit=1.0,
             glow={"radius": 4, "opacity": 0.6, "color": "glow_phosphor"}),
    ]
    blip = [
        variant(form("blip_bright", 1, [disc([96, 96], 16)], "phosphor", kind="flat", emit=1.0,
                     glow={"radius": 10, "opacity": 0.8, "color": "glow_phosphor"}), "bright"),
        variant(form("blip_fade1", 1, [disc([96, 96], 14)], "phosphor", kind="flat", opacity=0.6, emit=0.6,
                     glow={"radius": 8, "opacity": 0.5, "color": "glow_phosphor"}), "fade1"),
        variant(form("blip_fade2", 1, [disc([96, 96], 12)], "phosphor", kind="flat", opacity=0.3, emit=0.3,
                     glow={"radius": 6, "opacity": 0.3, "color": "glow_phosphor"}), "fade2"),
    ]
    return [
        recipe("ui_scr_sonar", [384, 384], f, pivot=c, seed=31, pivot_meaning="screen centre",
               note=NOTE + " Round scope (sonar / radar) face: bezel, phosphor grid, bearing ticks."),
        recipe("ui_scr_sonar_sweep", [384, 384], sweep, pivot=c, seed=32, style_override=NO_SIL,
               pivot_meaning="rotation centre; leading edge points up at 0 deg, rotate clockwise",
               note=NOTE + " Sweep wedge for ui_scr_sonar (rotate in game)."),
        recipe("ui_scr_sonar_blip", [192, 192], blip, pivot=[96, 96], seed=33, style_override=NO_SIL,
               frames=[frame("bright", show=["bright"]), frame("fade1", show=["fade1"]), frame("fade2", show=["fade2"])],
               pivot_meaning="blip centre", note=NOTE + " Contact blip, bright then fading."),
    ]


def polyline_points(keys, spacing=2.0, lo=-9.0, hi=489.0):
    """Evenly spaced dots along a polyline (by length, so steep parts stay unbroken)."""
    pts = []
    for (x0, y0), (x1, y1) in zip(keys, keys[1:]):
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / spacing))
        for k in range(n):
            t = k / n
            x = x0 + (x1 - x0) * t
            if lo <= x <= hi:
                pts.append([round(x, 2), round(y0 + (y1 - y0) * t, 2)])
    return pts


def wave_points(kind, width=480, y=64):
    if kind == "sine":
        keys = [(i * 1.5, y + 36 * math.sin(2 * math.pi * (i * 1.5) / 120.0)) for i in range(-7, int(width / 1.5) + 8)]
        return polyline_points(keys, 1.5)
    if kind == "pulse":
        period = 160.0
        shape = [(0, 0), (52, 0), (60, -6), (68, 0), (78, 0), (84, -44), (90, 40), (96, -6), (104, 0), (160, 0)]
        keys = []
        for rep in range(-1, int(width / period) + 1):
            keys += [(rep * period + a, y + dy) for a, dy in shape[:-1]]
        keys.append((width + period, y))
        return polyline_points(keys, 2.0)
    rng = random.Random(71)  # noise: seeded jagged line with a period equal to the width
    ctrl = [rng.uniform(-30, 30) for _ in range(40)]
    step = width / 40.0
    keys = [(i * step, y + ctrl[i % 40]) for i in range(-1, 42)]
    return polyline_points(keys, 2.0)


def wave():
    c = (288, 176)
    f = [
        form("body", 0, [rrect([288, 192], [570, 378], corner=36)], "plastic_dark", shade={"bump": 0.5}),
        form("recess", 1, [rrect(c, [496, 316], corner=30)], "rubber", kind="flat"),
        form("screen", 2, [rrect(c, [478, 298], corner=26)], "screen", shade={"bump": 0.3, "highlight_amount": 0.2}),
        form("grid_v", 3, [piece("square", [0, 0], [1.6, 284], repeat={"line": [[68, 176], [508, 176]], "count": 11})],
             "phosphor_dim", kind="flat", opacity=0.6, emit=0.3, clip_to="screen"),
        form("grid_h", 3, [piece("square", [0, 0], [466, 1.6], repeat={"line": [[288, 44], [288, 308]], "count": 7})],
             "phosphor_dim", kind="flat", opacity=0.6, emit=0.3, clip_to="screen"),
        form("axes", 3.1, [rrect(c, [3, 290], corner=1), rrect(c, [470, 3], corner=1)], "phosphor_dim", kind="flat",
             opacity=0.85, emit=0.35, clip_to="screen"),
        form("axis_ticks", 3.2, [piece("square", [0, 0], [1.4, 8], repeat={"line": [[68, 176], [508, 176]], "count": 51})],
             "phosphor_dim", kind="flat", opacity=0.7, emit=0.3),
        form("knob_a", 5, [disc([436, 356], 26)], "plastic_dark", shade={"bump": 1.2}),
        form("knob_b", 5, [disc([492, 356], 26)], "plastic_dark", shade={"bump": 1.2}),
        form("knob_marks", 5.5, [rrect([436, 348], [3, 10], corner=1), rrect([496, 351], [3, 10], corner=1, rot=40)],
             "enamel", kind="flat"),
        form("lamp_rim", 5, [disc([96, 356], 18)], "steel"),
        form("lamp", 5.2, [disc([96, 356], 11)], "lamp_green_on", emit=1.0,
             glow={"radius": 6, "opacity": 0.5, "color": "glow_green"}),
    ]
    f += screws("screws", 6, [[34, 34], [542, 34], [34, 350], [542, 350]], d=10)
    strip = []
    for kind in ("sine", "pulse", "noise"):
        strip.append(variant(dots(f"trace_{kind}", 1, wave_points(kind), 5, "phosphor", kind="flat", emit=1.0,
                                  glow={"radius": 5, "opacity": 0.6, "color": "glow_phosphor"}), kind))
    return [
        recipe("ui_scr_wave", [576, 384], f, pivot=[288, 176], seed=34, pivot_meaning="screen centre",
               note=NOTE + " Oscilloscope with a 478x298 phosphor screen (centre 288,176); put ui_scr_wave_strip on it."),
        recipe("ui_scr_wave_strip", [480, 128], strip, pivot=[0, 64], seed=35, style_override=NO_SIL,
               frames=[frame("sine", show=["sine"]), frame("pulse", show=["pulse"]), frame("noise", show=["noise"])],
               pivot_meaning="left end on the centre line; seamless every 480 px, scroll in x",
               note=NOTE + " Seamless trace strips: sine (period 120), heartbeat pulse (160), noise (480)."),
    ]


# ------------------------------------------------------------------ retro OS
def os_window():
    c = (96, 96)
    f = [
        form("frame", 0, [rrect(c, [188, 188], corner=5)], "plastic_beige", shade={"bump": 0.3, "highlight_amount": 0.2}),
        form("bevel_light", 1, [rrect([96, 5.5], [180, 3], corner=1), rrect([5.5, 96], [3, 180], corner=1)],
             "glare", kind="flat", opacity=0.2),
        form("bevel_dark", 1, [rrect([96, 186.5], [184, 3], corner=1), rrect([186.5, 96], [3, 184], corner=1)],
             "dial_mark", kind="flat", opacity=0.55),
        form("title", 2, [rrect([96, 22], [176, 26], corner=3)], "paint_teal", tags=["title"],
             shade={"bump": 0.4, "highlight_amount": 0.25}),
        form("title_sheen", 2.5, [rrect([96, 14], [170, 5], corner=2)], "glare", kind="flat", opacity=0.08,
             clip_to="title"),
        form("menu_mark", 3, [piece("diamond", [22, 22], [13, 13])], "plastic_beige"),
        form("client", 2, [rrect([96, 113], [176, 138], corner=2)], "plastic_dark", kind="flat"),
        form("client_bevel_dark", 2.2, [rrect([96, 45], [176, 3], corner=1), rrect([9.5, 113], [3, 138], corner=1)],
             "dial_mark", kind="flat", opacity=0.7),
        form("client_bevel_light", 2.2, [rrect([96, 181], [176, 2.5], corner=1), rrect([182.5, 113], [2.5, 138], corner=1)],
             "glare", kind="flat", opacity=0.14),
    ]
    return recipe("ui_os_window", [192, 192], f, pivot=[96, 96], seed=36,
                  frames=[frame("active", materials={"title": "paint_teal"}),
                          frame("inactive", materials={"title": "steel_dark"})],
                  pivot_meaning="frame centre",
                  note=NOTE + " Retro OS window 9-slice (margin 48): title bar in the top band, empty client area.")


def os_titlebtn():
    c = (64, 64)
    body = rrect(c, [96, 88], corner=7)
    light_grime = {"strength": 0.12, "density": 0.2}
    f = [
        variant(form("body", 0, [body], "plastic_beige", shade={"bump": 0.35, "highlight_amount": 0.2},
                     grime=light_grime), "beige"),
        variant(form("body_close", 0, [body], "cloth_wine", shade={"bump": 0.35, "highlight_amount": 0.2},
                     grime=light_grime), "wine"),
        variant(form("pressed_shade", 0.5, [rrect([64, 64], [92, 84], corner=6)], "dial_mark", kind="flat", opacity=0.22),
                "down"),
        variant(form("bevel_up_l", 1, [rrect([64, 23], [88, 3], corner=1), rrect([19, 64], [3, 80], corner=1)], "glare",
                     kind="flat", opacity=0.22), "up"),
        variant(form("bevel_up_d", 1, [rrect([64, 106], [92, 3], corner=1), rrect([110, 64], [3, 84], corner=1)],
                     "dial_mark", kind="flat", opacity=0.6), "up"),
        variant(form("bevel_dn_d", 1, [rrect([64, 23], [88, 3], corner=1), rrect([19, 64], [3, 80], corner=1)],
                     "dial_mark", kind="flat", opacity=0.6), "down"),
        variant(form("bevel_dn_l", 1, [rrect([64, 106], [92, 3], corner=1), rrect([110, 64], [3, 84], corner=1)], "glare",
                     kind="flat", opacity=0.18), "down"),
        variant(form("glyph_min", 2, [rrect([64, 86], [38, 9], corner=2)], "dial_mark", kind="flat", tags=["glyph"]), "min"),
        variant(form("glyph_max", 2, [rrect([64, 62], [42, 36], corner=2), rrect([64, 66], [32, 22], corner=1, op="sub")],
                     "dial_mark", kind="flat", tags=["glyph"]), "max"),
        variant(form("glyph_close", 2, [rrect(c, [50, 10], corner=3, rot=45), rrect(c, [50, 10], corner=3, rot=-45)],
                     "dial_mark", kind="flat", tags=["glyph"]), "close"),
    ]
    frames = []
    for g, colour in (("min", "beige"), ("max", "beige"), ("close", "wine")):
        frames.append(frame(f"{g}_normal", show=[g, colour, "up"]))
        frames.append(frame(f"{g}_pressed", show=[g, colour, "down"], move={"glyph": [3, 3]}))
    return recipe("ui_os_titlebtn", [128, 128], f, pivot=c, seed=37, frames=frames, pivot_meaning="button centre",
                  note=NOTE + " Title-bar buttons (minimise / maximise / close), normal and pressed.")


def os_cursors():
    arrow = [
        form("arrow", 0, [piece("cursor", [58, 60], [72, 94])], "bone", shade={"bump": 0.5}),
        form("arrow_inner", 1, [piece("cursor", [56, 56], [48, 62])], "enamel", kind="flat", opacity=0.35),
    ]
    wait = [
        form("glass_top", 0, [piece("triangle", [64, 44], [58, 44], rot=180)], "glass_pane", opacity=0.75),
        form("glass_bottom", 0, [piece("triangle", [64, 84], [58, 44])], "glass_pane", opacity=0.75),
        form("sand_top", 1, [piece("triangle", [64, 50], [30, 20], rot=180)], "paint_ochre", kind="flat"),
        form("sand_bottom", 1, [piece("triangle", [64, 94], [42, 22])], "paint_ochre", kind="flat"),
        form("sand_stream", 1, [rrect([64, 72], [3, 22], corner=1)], "paint_ochre", kind="flat"),
        form("caps", 2, [rrect([64, 20], [68, 11], corner=3), rrect([64, 108], [68, 11], corner=3)], "wood"),
        form("posts", 1.5, [rrect([34, 64], [5, 86], corner=2), rrect([94, 64], [5, 86], corner=2)], "wood"),
    ]
    hand = [
        form("hand", 0, [piece("pointer", [66, 66], [80, 96])], "bone", shade={"bump": 0.6}),
        form("cuff", 1, [rrect([72, 112], [44, 14], corner=4)], "cloth_wine"),
    ]
    beam = [
        form("beam_stem", 0, [rrect([64, 64], [8, 82], corner=2)], "enamel", shade={"bump": 0.3}),
        form("beam_caps", 1, [rrect([64, 22], [34, 8], corner=2), rrect([64, 106], [34, 8], corner=2)], "enamel",
             shade={"bump": 0.3}),
    ]
    mk = lambda name, forms, pivot, what: recipe(name, [128, 128], forms, pivot=pivot, seed=38,
                                                 pivot_meaning="hotspot (" + what + ")",
                                                 note=NOTE + " Retro OS mouse cursor.")
    return [mk("ui_os_cursor_arrow", arrow, [25, 15], "arrow tip"), mk("ui_os_cursor_wait", wait, [64, 64], "centre"),
            mk("ui_os_cursor_hand", hand, [52, 20], "finger tip"), mk("ui_os_cursor_beam", beam, [64, 64], "centre")]


def os_progress():
    frame_forms = [
        form("track", 0, [rrect([96, 24], [188, 44], corner=5)], "plastic_beige", shade={"bump": 0.3}),
        form("well", 1, [rrect([96, 24], [176, 30], corner=2)], "plastic_dark", kind="flat"),
        form("well_shadow", 1.2, [rrect([96, 10.5], [176, 3], corner=1), rrect([9.5, 24], [3, 30], corner=1)],
             "dial_mark", kind="flat", opacity=0.7),
        form("well_light", 1.2, [rrect([96, 38], [176, 2.5], corner=1)], "glare", kind="flat", opacity=0.14),
    ]
    cell = [
        form("cell", 0, [rrect([24, 24], [34, 26], corner=3)], "paint_teal", tags=["fill"],
             shade={"bump": 0.8, "highlight_amount": 0.35}),
        form("cell_sheen", 1, [rrect([24, 15], [28, 4], corner=1)], "glare", kind="flat", opacity=0.14, clip_to="cell"),
    ]
    return [
        recipe("ui_os_progress_frame", [192, 48], frame_forms, pivot=[96, 24], seed=39, pivot_meaning="frame centre",
               note=NOTE + " Progress bar track, 9-slice margin 16 (cells go inside the dark well)."),
        recipe("ui_os_progress_cell", [48, 48], cell, pivot=[24, 24], seed=40, pivot_meaning="cell centre",
               frames=[frame("teal", materials={"fill": "paint_teal"}), frame("wine", materials={"fill": "cloth_wine"}),
                       frame("amber", materials={"fill": "paint_ochre"})],
               note=NOTE + " Progress fill block; place side by side every 38-40 px inside ui_os_progress_frame."),
    ]


# ------------------------------------------------------------------ stamps
def stamps():
    c = (96, 96)
    ink = {"rough": {"amp": 0.5, "soft": 1.4, "cell": 6}, "mottle": {"cell": 24, "lo": 0.2, "hi": 0.5},
           "opacity": 0.88}
    f = [
        variant(annulus("approve_outer", 1, c, 82, 72, "ink_red", kind="flat", tags=["ink"], **ink), "approve"),
        variant(annulus("approve_inner", 1, c, 64, 59, "ink_red", kind="flat", tags=["ink"], **ink), "approve"),
        variant(form("approve_star", 1, [piece("star", c, [74, 74])], "ink_red", kind="flat", tags=["ink"], **ink),
                "approve"),
        variant(annulus("deny_ring", 1, c, 82, 69, "ink_red", kind="flat", tags=["ink"], **ink), "deny"),
        variant(form("deny_cross", 1, [rrect(c, [112, 18], corner=4, rot=45), rrect(c, [112, 18], corner=4, rot=-45)],
                     "ink_red", kind="flat", tags=["ink"], **ink), "deny"),
        variant(annulus("hold_ring", 1, c, 82, 73, "ink_red", kind="flat", tags=["ink"], **ink), "hold"),
        variant(form("hold_triangle", 1, [piece("triangle", [96, 92], [90, 78]), piece("triangle", [96, 100], [58, 48],
                                                                                      op="sub")],
                     "ink_red", kind="flat", tags=["ink"], **ink), "hold"),
        variant(form("void_frame", 1, [rrect(c, [176, 112], corner=8), rrect(c, [156, 92], corner=4, op="sub")],
                     "ink_red", kind="flat", tags=["ink"], **ink), "void"),
        variant(form("void_bars", 1, [rrect([96, 82], [190, 12], corner=3, rot=-18), rrect([96, 110], [190, 12], corner=3,
                                                                                        rot=-18)],
                     "ink_red", kind="flat", tags=["ink"], clip_to="void_frame_box", **ink), "void"),
        variant(form("void_frame_box", 0.5, [rrect(c, [176, 112], corner=8)], "dial_mark", kind="flat", opacity=0.0),
                "void"),
    ]
    frames = []
    for mark in ("approve", "deny", "hold", "void"):
        for inkname in ("red", "violet"):
            frames.append(frame(f"{mark}_{inkname}", show=[mark], materials={"ink": f"ink_{inkname}"}))
    return recipe("ui_stamp_mark", [192, 192], f, pivot=list(c), seed=41, frames=frames, style_override=NO_SIL,
                  pivot_meaning="stamp centre",
                  note=NOTE + " Rubber-stamp imprints (approve / deny / hold / void) in red and violet ink, patchy edges.")


# ------------------------------------------------------------------ rhythm
def rhythm():
    c = (96, 96)
    lane = [
        form("lane", 0, [rrect(c, [152, 186], corner=26)], "plastic_dark", opacity=0.82, shade={"bump": 0.3}),
        form("rails", 1, [rrect([24, 96], [8, 170], corner=4), rrect([168, 96], [8, 170], corner=4)], "bronze"),
        form("guide", 1, [rrect(c, [2, 170], corner=1)], "phosphor_dim", kind="flat", opacity=0.45, emit=0.3),
    ]
    judge = [
        form("caps", 2, [disc([12, 24], 28), disc([180, 24], 28)], "bronze", shade={"bump": 1.2}),
        form("bar", 1, [rrect([96, 24], [176, 18], corner=8)], "amber_screen", kind="flat", emit=1.0,
             glow={"radius": 6, "opacity": 0.5, "color": "glow_amber"}),
        form("core", 1.5, [rrect([96, 24], [168, 5], corner=2)], "lamp_white_on", kind="flat", emit=1.0),
    ]
    cap = rrect(c, [150, 54], corner=25)
    note = [
        form("note_mask", 0.5, [cap], "dial_mark", kind="flat", opacity=0.0),
        variant(form("tap_amber", 1, [cap], "lamp_amber_on", emit=0.8, glow={"radius": 8, "opacity": 0.5,
                                                                             "color": "glow_amber"}), "tap_amber"),
        variant(form("tap_teal", 1, [cap], "phosphor", emit=0.8, glow={"radius": 8, "opacity": 0.5,
                                                                       "color": "glow_phosphor"}), "tap_teal"),
        variant(form("head", 1, [cap], "lamp_amber_on", emit=0.8, glow={"radius": 8, "opacity": 0.5,
                                                                        "color": "glow_amber"}), "head"),
        variant(form("head_mark", 2, [piece("triangle", [96, 92], [32, 20])], "dial_mark", kind="flat", opacity=0.5),
                "head"),
        variant(form("tail", 1, [rrect([96, 96], [96, 60], corner=28)], "amber_screen", opacity=0.8, emit=0.6), "tail"),
        variant(form("rim", 1.5, [cap, rrect(c, [134, 38], corner=17, op="sub")], "bronze", kind="flat", opacity=0.9),
                "tap_amber", "tap_teal", "head"),
        variant(form("sheen", 2, [rrect([96, 80], [118, 6], corner=3)], "glare", kind="flat", opacity=0.2,
                     clip_to="note_mask"), "tap_amber", "tap_teal", "head"),
    ]
    body = [
        form("body", 0, [rrect(c, [92, 220], corner=6)], "amber_screen", opacity=0.55, emit=0.6),
        form("edges", 1, [rrect([52, 96], [4, 220], corner=1), rrect([140, 96], [4, 220], corner=1)], "bronze",
             kind="flat", opacity=0.8),
    ]
    target = [
        annulus("ring", 1, c, 80, 67, "bronze", tags=["ring"], shade={"bump": 1.2}),
        annulus("inner_ring", 1.2, c, 56, 53, "phosphor_dim", kind="flat", opacity=0.8),
        ticks("notches", 2, c, 74, 4, 0, 360, 16, 6, "steel", kind="mass"),
        form("centre", 1.3, [disc(c, 10)], "dial_mark", kind="flat", opacity=0.8),
        variant(form("hit_fill", 0.5, [disc(c, 108)], "lamp_amber_on", kind="flat", opacity=0.5, emit=1.0,
                     glow={"radius": 16, "opacity": 0.6, "color": "glow_amber"}), "hit"),
        variant(form("miss_tint", 0.5, [disc(c, 108)], "zone_red", kind="flat", opacity=0.3), "miss"),
        variant(form("miss_crack", 3, [piece("arrow_zigzag", [58, 70], [30, 44], rot=-30),
                                       piece("arrow_zigzag", [132, 124], [26, 40], rot=150)],
                     "dial_mark", kind="flat", opacity=0.85, clip_to="ring"), "miss"),
    ]
    return [
        recipe("ui_rhythm_lane", [192, 192], lane, pivot=list(c), seed=42, pivot_meaning="lane centre",
               note=NOTE + " Vertical note lane, 9-slice margin 48 (stretch the middle band in y)."),
        recipe("ui_rhythm_judge", [192, 48], judge, pivot=[96, 24], seed=43, style_override=NO_SIL,
               pivot_meaning="judgement line centre",
               note=NOTE + " Glowing judgement line, 9-slice margin 28 in x."),
        recipe("ui_rhythm_note", [192, 192], note, pivot=list(c), seed=44, pivot_meaning="note centre",
               frames=[frame("tap_amber", show=["tap_amber"]), frame("tap_teal", show=["tap_teal"]),
                       frame("hold_head", show=["head"]), frame("hold_tail", show=["tail"])],
               note=NOTE + " Rhythm notes: two tap colours, hold head and hold tail."),
        recipe("ui_rhythm_note_body", [192, 192], body, pivot=list(c), seed=45, style_override=NO_SIL,
               pivot_meaning="body centre; seamless in y (tile or stretch between head and tail)",
               note=NOTE + " Hold-note body."),
        recipe("ui_rhythm_target", [192, 192], target, pivot=list(c), seed=46, pivot_meaning="target centre",
               frames=[frame("idle"), frame("hit", show=["hit"], materials={"ring": "lamp_amber_on"}),
                       frame("miss", show=["miss"], materials={"ring": "steel_dark"})],
               note=NOTE + " Hit target ring: idle, hit (lit), miss (dim, cracked)."),
    ]


# ------------------------------------------------------------------ overlay
def viewfinder():
    W, H = 2560, 1440
    pale = {"opacity": 0.85}
    corners = []
    inset_x, inset_y = 150, 130
    for sx in (-1, 1):
        for sy in (-1, 1):
            x = W / 2 + sx * (W / 2 - inset_x)
            y = H / 2 + sy * (H / 2 - inset_y)
            corners.append(rrect([x - sx * 100, y], [214, 14], corner=5))
            corners.append(rrect([x, y - sy * 72], [14, 158], corner=5))
    focus = []
    for sx in (-1, 1):
        for sy in (-1, 1):
            x, y = W / 2 + sx * 190, H / 2 + sy * 130
            focus.append(rrect([x - sx * 26, y], [58, 7], corner=3))
            focus.append(rrect([x, y - sy * 26], [7, 58], corner=3))
    cx, cy = W / 2, H / 2
    f = [
        form("brackets", 1, corners, "glare", kind="flat", **pale),
        form("focus", 1, focus, "glare", kind="flat", opacity=0.6),
        form("reticle", 1, [rrect([cx - 66, cy], [56, 6], corner=2), rrect([cx + 66, cy], [56, 6], corner=2),
                            rrect([cx, cy - 66], [6, 56], corner=2), rrect([cx, cy + 66], [6, 56], corner=2),
                            disc([cx, cy], 8)], "glare", kind="flat", opacity=0.7),
        form("level_line", 1, [rrect([cx, 1296], [620, 4], corner=2)], "glare", kind="flat", opacity=0.6),
        form("level_ticks", 1, [piece("square", [0, 0], [4, 18], repeat={"line": [[cx - 300, 1296], [cx + 300, 1296]],
                                                                          "count": 13})],
             "glare", kind="flat", opacity=0.6),
        form("level_mark", 1.1, [piece("triangle", [cx, 1274], [22, 16], rot=180)], "glare", kind="flat", opacity=0.85),
        form("battery", 1, [rrect([2310, 196], [150, 62], corner=8), rrect([2310, 196], [134, 46], corner=5, op="sub"),
                            rrect([2392, 196], [12, 26], corner=3)], "glare", kind="flat", **pale),
        form("battery_cells", 1, [rrect([2266, 196], [34, 34], corner=3), rrect([2306, 196], [34, 34], corner=3),
                                  rrect([2346, 196], [34, 34], corner=3)], "glare", kind="flat", opacity=0.7),
        form("rec_rim", 1, [disc([236, 196], 58)], "glare", kind="flat", opacity=0.5),
        variant(form("rec_on", 2, [disc([236, 196], 44)], "lamp_red_on", kind="flat", emit=1.0,
                     glow={"radius": 16, "opacity": 0.7, "color": "glow_red"}), "rec"),
        variant(form("rec_off", 2, [disc([236, 196], 44)], "lamp_red_off", kind="flat"), "standby"),
    ]
    return recipe("ui_scr_viewfinder", [W, H], f, style="prop", supersample=1, pivot=[cx, cy], seed=47,
                  style_override={"silhouette": {"width": 2.0, "heavy": 1.0}},
                  frames=[frame("rec", show=["rec"]), frame("standby", show=["standby"])],
                  pivot_meaning="screen centre",
                  note=NOTE + " Camcorder viewfinder overlay 2560x1440: corner brackets, focus box, reticle, level, "
                              "battery, record lamp. No numbers or letters.")


def stage_a():
    out = []
    out += sonar()
    out += wave()
    out += [os_window(), os_titlebtn()]
    out += os_cursors()
    out += os_progress()
    out += [stamps()]
    out += rhythm()
    out += [viewfinder()]
    return out


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
