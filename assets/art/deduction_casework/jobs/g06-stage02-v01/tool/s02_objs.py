"""Stage 02 world objects (A foyer + C study = quarter view; B dining, D service, E garden = front/side view)."""

from __future__ import annotations

import math

from g06kit import F, box, ell, icon, lerp, limb, quad, recipe, rect, shadow
from g06kit.front import (LS, LT, LX, ISO_SKEW_X, ISO_SKEW_Y, chair_front, fblock, floor_shadow, iso_frame, iso_shadow,
                          legs4, tones)
from g06kit.iso import Iso
from s02_common import PAL, PPM, asset

K = 250.0


def _r(asset_id, f, size, piv, note, seed, pm="ground contact point", frames=None):
    return recipe(asset_id, f, size, piv, PAL, style="prop", seed=seed, pivot_meaning=pm, note=note, frames=frames)


# ------------------------------------------------------------------ A foyer (iso)
@asset("obj_s02_coat_rack")
def coat_rack():
    io, size = iso_frame(0.5, 0.5, 1.95, pad=60)
    c = io.p(0.25, 0.25)
    f = [iso_shadow(io, 0.05, 0.05, 0.45, 0.45, grow=0.0, opacity=0.35, blur=6),
         F("pole", [rect(c[0] - 8, c[1] - 1.85 * PPM, c[0] + 8, c[1] - 10)], "wood_dark", 1.0, line=LT),
         F("feet", [icon("cross", c[0], c[1] - 6, 110, 30)], "wood_dark", 0.9, line=LS),
         F("hooks", [icon("hook", c[0] - 30, c[1] - 1.78 * PPM, 24, 30), icon("hook", c[0] + 30, c[1] - 1.8 * PPM, 24, 30,
                                                                                flip="x")], "brass", 1.1, line=LS)]
    for i, (dx, mat, col) in enumerate(((-34, "mourning_black", None), (30, "suit_greybrown", None), (4, "mourning_black",
                                                                                                         "#302a2c"))):
        top = c[1] - 1.76 * PPM
        coat = quad([(c[0] + dx - 30, top), (c[0] + dx + 30, top), (c[0] + dx + 52, top + 300), (c[0] + dx - 52, top + 300)])
        fm = F(f"coat{i}", [coat], mat, 2.0 + i * 0.1, line=LT)
        if col:
            fm["color"] = col
        f.append(fm)
    f.append(F("drips", [icon("droplet", c[0] - 40 + i * 30, c[1] - 1.76 * PPM + 318 + (i % 2) * 20, 10, 16) for i in range(4)],
               "@rain", 3.0, kind="flat", opacity=0.6))
    f.append(F("wet_sheen", [icon("droplet", c[0] - 30, c[1] - 360, 30, 80), icon("droplet", c[0] + 36, c[1] - 380, 26, 70)],
               "@rain", 2.9, kind="flat", opacity=0.25))
    return _r("obj_s02_coat_rack", f, size, c, "A: hall coat stand with wet mourning coats (0-click: 비 맞은 외투), drips.",
              401)


@asset("obj_s02_umbrella_stand")
def umbrella_stand():
    io, size = iso_frame(0.35, 0.35, 0.95, pad=40)
    c = io.p(0.17, 0.17)
    f = [iso_shadow(io, 0.02, 0.02, 0.33, 0.33, grow=0.0, opacity=0.35, blur=5),
         F("stand", [rect(c[0] - 44, c[1] - 170, c[0] + 44, c[1]), ell(c[0], c[1], 88, 30), ell(c[0], c[1] - 170, 88, 30)],
           "metal_dark", 1.0, line=LT),
         F("umb1", [quad([(c[0] - 30, c[1] - 170), (c[0] - 10, c[1] - 170), (c[0] - 40, c[1] - 290), (c[0] - 60, c[1] - 280)])],
           "mourning_black", 0.9, line=LS),
         F("umb2", [quad([(c[0] + 6, c[1] - 170), (c[0] + 28, c[1] - 170), (c[0] + 40, c[1] - 300), (c[0] + 18, c[1] - 305)])],
           "cloth_wine", 0.8, line=LS),
         F("handles", [icon("hook", c[0] - 52, c[1] - 296, 22, 26), icon("hook", c[0] + 30, c[1] - 314, 22, 26)], "wood_dark",
           1.1, line=LS),
         F("puddle", [ell(c[0] + 10, c[1] + 6, 120, 30)], "@rain", 0.5, kind="flat", opacity=0.3)]
    return _r("obj_s02_umbrella_stand", f, size, c, "A: brass umbrella stand with two wet umbrellas and a puddle.", 402)


@asset("obj_s02_lectern_book")
def lectern_book():
    io, size = iso_frame(0.5, 0.6, 1.25, pad=50)
    f = [iso_shadow(io, 0.1, 0.1, 0.4, 0.5, grow=0.0)]
    t, l, r = tones("wood_red")
    f += io.box("post", 0.18, 0.22, 0.0, 0.32, 0.38, 1.0, t, l, r, z=1.0, line=LS)
    f += io.box("base", 0.08, 0.1, 0.0, 0.42, 0.5, 0.06, t, l, r, z=0.9, line=LS)
    f.append(F("slope", [quad([io.p(0.02, 0.04, 1.02), io.p(0.02, 0.56, 1.02), io.p(0.48, 0.56, 1.14), io.p(0.48, 0.04, 1.14)])],
               "wood_red", 2.0, kind="flat", color="#5c3a2c", line=LT))
    f.append(F("book", [quad([io.p(0.08, 0.08, 1.13), io.p(0.08, 0.52, 1.13), io.p(0.44, 0.52, 1.23), io.p(0.44, 0.08, 1.23)])],
               "paper_ivory", 2.1, line=LS))
    f.append(F("gutter", [quad([io.p(0.08, 0.29, 1.13), io.p(0.08, 0.31, 1.13), io.p(0.44, 0.31, 1.24), io.p(0.44, 0.29, 1.24)])],
               "@joint_dark", 2.2, kind="flat", opacity=0.4))
    rows = [quad([io.p(0.14 + i * 0.05, 0.1, 1.155 + i * 0.013), io.p(0.14 + i * 0.05, 0.27, 1.155 + i * 0.013),
                  io.p(0.15 + i * 0.05, 0.27, 1.158 + i * 0.013), io.p(0.15 + i * 0.05, 0.1, 1.158 + i * 0.013)]) for i in range(5)]
    f.append(F("rows", rows, "ink_line", 2.3, kind="flat", opacity=0.5))
    f.append(F("pen", [limb(io.p(0.3, 0.4, 1.24), io.p(0.4, 0.5, 1.26), 5, 4)[0]], "plastic_black", 2.4))
    return _r("obj_s02_lectern_book", f, size, io.p(0.25, 0.3), "A1: red-brown lectern with the funeral attendance book "
              "open (rows only; page = cu_s02_attendance).", 403)


@asset("obj_s02_photo_table")
def photo_table():
    io, size = iso_frame(0.45, 1.0, 1.1, pad=50)
    f = [iso_shadow(io, 0, 0, 0.45, 1.0)]
    t, l, r = tones("wood_red")
    f += io.box("top", 0, 0, 0.72, 0.45, 1.0, 0.77, t, l, r, z=2.0, line=LT)
    for (x, y) in ((0.4, 0.04), (0.4, 0.94), (0.03, 0.94)):
        f += io.box(f"leg{x}{y}", x, y, 0, x + 0.04, y + 0.04, 0.72, t, l, r, z=1.0 + y, line=LS)
    f.append(F("runner", [io.floor(0.06, 0.05, 0.38, 0.95, Z=0.772)], "curtain_green", 2.5, kind="flat", opacity=0.9))
    for i, (y0, h, w, col) in enumerate(((0.12, 0.28, 0.2, "brass"), (0.42, 0.24, 0.22, "wood_dark"), (0.72, 0.3, 0.2, "brass"))):
        frame = io.wall_x(0.15, 0.15 + w, 0.78, 0.78 + h, Y=y0)
        f.append(F(f"frame{i}", [frame], col, 3.0 + i * 0.1, kind="flat", line=LS))
        f.append(F(f"photo{i}", [io.wall_x(0.17, 0.13 + w, 0.8, 0.76 + h, Y=y0 + 0.001)], "paper_cream", 3.05 + i * 0.1,
                   kind="flat", color="#8c7c62"))
        f.append(F(f"figs{i}", [ell(*io.p(0.2 + k * 0.05, y0, 0.86 + h * 0.4), 12, 18) for k in range(2 + i % 2)],
                   "@ink", 3.07 + i * 0.1, kind="flat", opacity=0.35))
    f.append(F("black_ribbon", [io.wall_x(0.3, 0.33, 0.78, 1.1, Y=0.12)], "mourning_black", 3.4, kind="flat"))
    return _r("obj_s02_photo_table", f, size, io.p(0.22, 0.5), "A2: side table with the three framed family photographs "
              "(one with a black mourning ribbon); prints = cu_s02_photo_young / _wedding / _family.", 404)


@asset("obj_s02_wreath")
def wreath():
    W, H = 300, 520
    cx = 150
    f = [floor_shadow(cx, 500, 180, 26),
         F("easel", [limb((cx - 60, 500), (cx - 10, 60), 10, 8)[0], limb((cx + 60, 500), (cx + 10, 60), 10, 8)[0],
                     limb((cx, 500), (cx, 120), 10, 8)[0]], "wood_dark", 0.8, line=LS),
         F("ring", [icon("ring", cx, 190, 240, 240)], "grass_dark", 1.0, color="#34422f", line=LT),
         F("leaves", [icon("leaf", cx + 100 * math.cos(a), 190 + 100 * math.sin(a), 40, 26, rot=a * 57.3)
                      for a in [i * 0.5236 for i in range(12)]], "grass_dark", 1.1, color="#3e4f38", line=LS),
         F("flowers", [icon("flower", cx - 70, 110, 44, 44), icon("flower", cx + 76, 130, 40, 40), icon("flower", cx - 90, 250, 42, 42),
                       icon("flower", cx + 60, 280, 44, 44)], "paper_white", 1.2, color="#b7b1a2", line=LS),
         F("sash", [quad([(cx - 20, 290), (cx + 20, 290), (cx + 50, 420), (cx + 22, 424)]),
                    quad([(cx - 20, 290), (cx + 4, 292), (cx - 28, 430), (cx - 56, 424)])], "mourning_black", 1.3, line=LS)]
    return _r("obj_s02_wreath", f, (W, H), (cx, 500), "A: funeral wreath on an easel (new flowers vs old furniture, "
              "13B-1).", 405)


@asset("obj_s02_yona_bag")
def yona_bag():
    W, H = 220, 170
    f = [floor_shadow(110, 156, 190, 18),
         fblock("bag", 30, 190, 70, 20, 64, "leather_black", z=1.0),
         F("flap", [quad([(30, 70), (190, 70), (180, 118), (40, 118)])], "leather_black", 1.1, color="#342d30", line=LS),
         F("handle", [icon("ring", 110, 58, 90, 50, crop=[0, 0, 16, 8])], "leather_black", 0.9, line=LS),
         F("clasp", [rect(100, 110, 120, 124)], "brass", 1.2, line=LS),
         F("wear", [icon("cloud", 60, 140, 50, 22), icon("cloud", 170, 132, 34, 16)], "@worn", 1.3, kind="flat", opacity=0.3)]
    return _r("obj_s02_yona_bag", f, (W, H), (110, 156), "A3: Yona's worn black condolence bag (fixed size, 13A-1); "
              "contents in cu_s02_yona_bag_open.", 406)


@asset("obj_s02_shoe_row")
def shoe_row():
    W, H = 760, 150
    f = [floor_shadow(380, 128, 700, 24, 0.3, 5)]
    shoes = [("shoe_black", 0), ("shoe_brown", 1), ("shoe_black", 0), ("leather_black", 2), ("shoe_black", 0), ("shoe_brown", 1)]
    for i, (mat, kind) in enumerate(shoes):
        x = 70 + i * 120
        for s in (0, 1):
            xx = x + s * 38
            f.append(F(f"shoe{i}{s}", [ell(xx, 110, 34, 72), rect(xx - 17, 70, xx + 17, 110)], mat, 1.0 + i * 0.01, line=LS))
        if i == 3:   # Yona's practical shoes: grey clay caked on the heels
            f.append(F("clay", [icon("metaballs", x + 18, 134, 90, 24)], "clay_grey", 1.2, kind="flat"))
    return _r("obj_s02_shoe_row", f, (W, H), (380, 128), "VISUAL 3: six pairs of shoes lined up by the door; the 4th pair "
              "(Yona's practical shoes) has grey clay at the heels (soles compared in cu_s02_shoe_soles).", 407)


@asset("obj_s02_bench_foyer")
def bench_foyer():
    io, size = iso_frame(0.45, 1.3, 0.55, pad=40)
    f = [iso_shadow(io, 0, 0, 0.45, 1.3)]
    t, l, r = tones("wood_red")
    f += io.box("seat", 0, 0, 0.4, 0.45, 1.3, 0.46, ("cloth_wine", "#5a2b33"), ("cloth_wine", "#4a232a"), ("cloth_wine", "#35191e"),
                z=2.0, line=LT)
    f += io.box("apron", 0.02, 0.02, 0.3, 0.43, 1.28, 0.4, t, l, r, z=1.5, line=LS)
    for (x, y) in ((0.38, 0.03), (0.38, 1.22), (0.02, 1.22)):
        f += io.box(f"leg{x}{y}", x, y, 0, x + 0.05, y + 0.05, 0.3, t, l, r, z=1.0 + y * 0.1, line=LS)
    return _r("obj_s02_bench_foyer", f, size, io.p(0.22, 0.65), "A: upholstered hall bench (Yona's bag sits on it).", 408)


# ------------------------------------------------------------------ B dining (front)
TABLE = {"x0": 520, "x1": 2040, "top": 880, "depth": 150, "height": 200}


@asset("obj_s02_dining_table")
def dining_table():
    W, H = 1640, 420
    x0, x1 = 60, 1580
    f = [floor_shadow(820, 400, 1500, 50),
         F("cloth_top", [rect(x0, 40, x1, 190)], "tablecloth", 2.0, line=LT, shade={"bump": 0.3}),
         F("cloth_drop", [rect(x0 - 10, 190, x1 + 10, 300)], "tablecloth", 2.1, color="#96907f", line=LT),
         F("cloth_folds", [rect(x0 + i * 120, 196, x0 + i * 120 + 4, 298) for i in range(1, 13)], "@joint_dark", 2.2,
           kind="flat", opacity=0.25),
         legs4(x0, x1, 300, 400, 40, mat="wood_red", z=1.0),
         F("runner", [rect(x0 + 200, 100, x1 - 200, 130)], "curtain_green", 2.3, kind="flat", opacity=0.9),
         F("candles", [rect(780 + i * 40, 50, 792 + i * 40, 110) for i in range(3)], "paper_white", 2.4, line=LS),
         F("candle_stand", [rect(760, 104, 880, 118), rect(812, 96, 828, 124)], "brass", 2.5, line=LS),
         F("wax_drips", [icon("droplet", 786 + i * 40, 86, 8, 16) for i in range(3)], "paper_white", 2.45, color="#cfc9b8")]
    # five used settings (plates with spoons, half-empty glasses, crumpled napkins); the guest setting is a separate object
    xs = [260, 820, 1380, 260, 820]
    ys = [80, 80, 80, 160, 160]
    for i, (x, y) in enumerate(zip(xs, ys)):
        f += [F(f"plate{i}", [ell(x, y, 110, 40)], "paper_white", 3.0 + i * 0.01, line=LS),
              F(f"bowl{i}", [ell(x, y - 4, 70, 26)], "paper_white", 3.02 + i * 0.01, color="#b4ae9f", line=LS),
              F(f"soup{i}", [ell(x, y - 5, 50, 16)], "@soup", 3.03 + i * 0.01, kind="flat", opacity=0.55 if i % 2 else 0.35),
              F(f"glass{i}", [rect(x + 70, y - 60, x + 88, y - 20), ell(x + 79, y - 16, 22, 8)], "glass_clear", 3.04 + i * 0.01,
                line=LS, opacity=0.8),
              F(f"wine{i}", [rect(x + 72, y - 40 + (i % 3) * 6, x + 86, y - 22)], "@wine", 3.05 + i * 0.01, kind="flat"),
              F(f"napkin{i}", [icon("cloud", x - 80, y + 4, 44, 22, rot=i * 17)], "paper_white", 3.06 + i * 0.01, line=LS)]
    return _r("obj_s02_dining_table", f, (W, H), (820, 400), "B: six-seat dining table (cloth, candles, runner) with the "
              "FIVE used settings - each used differently (spoon, level of soup and wine, crumpled napkin). The Guest "
              "setting is obj_s02_setting_guest; Silla's teacup obj_s02_teacup.", 410, pm="floor point under the front "
              "centre")


@asset("obj_s02_setting_guest")
def setting_guest():
    W, H = 220, 130
    x, y = 110, 70
    f = [F("plate", [ell(x, y, 110, 40)], "paper_white", 1.0, line=LS),
         F("bowl", [ell(x, y - 4, 70, 26)], "paper_white", 1.02, color="#b4ae9f", line=LS),
         F("soup_skin", [ell(x, y - 5, 54, 18)], "@soup_skin", 1.03, kind="flat"),
         F("skin_wrinkle", [icon("wave", x, y - 5, 40, 8)], "@soup", 1.04, kind="flat", opacity=0.6),
         F("glass_full", [rect(x + 70, y - 60, x + 88, y - 20), ell(x + 79, y - 16, 22, 8)], "glass_clear", 1.05, line=LS,
           opacity=0.8),
         F("wine_full", [rect(x + 72, y - 56, x + 86, y - 22)], "@wine", 1.06, kind="flat"),
         F("napkin_folded", [icon("triangle", x - 78, y, 40, 30)], "paper_white", 1.07, line=LS),
         F("spoon", [box(x + 50, y + 6, 6, 40, rot=80)], "silver", 1.08)]
    return _r("obj_s02_setting_guest", f, (W, H), (x, y), "B2 / hinge A: the Guest setting - soup with a skin on its "
              "surface, wine glass still full, napkin never unfolded, spoon unused.", 411, pm="plate centre on the "
              "table top (placed on obj_s02_dining_table)")


@asset("obj_s02_teacup")
def teacup():
    W, H = 120, 80
    f = [F("saucer", [ell(60, 56, 90, 24)], "paper_white", 1.0, line=LS),
         F("powder", [icon("sponge", 30, 58, 20, 8)], "@powder", 1.05, kind="flat"),
         F("cup", [rect(40, 26, 80, 54), ell(60, 54, 40, 12)], "paper_white", 1.1, line=LS),
         F("cup_top", [ell(60, 26, 40, 12)], "paper_white", 1.11, color="#c9c3b4", line=LS),
         F("tea", [ell(60, 27, 30, 8)], "@soup", 1.12, kind="flat"),
         F("handle", [icon("ring", 86, 40, 16, 20)], "paper_white", 1.05, line=LS)]
    return _r("obj_s02_teacup", f, (W, H), (60, 58), "B3 / hinge C: Silla's teacup with a white powder trace on the "
              "outside of the saucer (details in cu_s02_teacup).", 412, pm="saucer centre on the table top")


def _chair(asset_id, note, seed, crest=None, briefcase=False, apron_hook=False, coat=False, pulled=False, mat="wood_red"):
    W, H = 260, 520
    cx = 130
    f = [floor_shadow(cx, 500, 200, 26)] + chair_front(cx, 500, mat=mat, seat_y=360, back_h=300, w=170, crest=crest)
    if briefcase:
        f += [F("briefcase", [rect(cx - 70, 200, cx + 70, 300)], "leather_black", 2.0, line=LT),
              F("brief_handle", [icon("ring", cx, 196, 60, 30, crop=[0, 0, 16, 8])], "leather_black", 1.9, line=LS),
              F("brief_clasp", [rect(cx - 8, 240, cx + 8, 252)], "brass", 2.1)]
    if apron_hook:
        f.append(F("apron_hook", [icon("hook", cx + 50, 120, 30, 40)], "silver", 2.0, line=LS))
    if coat:
        f += [F("wet_coat", [quad([(cx - 80, 70), (cx + 80, 70), (cx + 96, 360), (cx - 96, 360)])], "mourning_black", 2.0,
                line=LT),
              F("coat_wet", [icon("droplet", cx - 40, 200, 30, 80), icon("droplet", cx + 30, 240, 26, 70)], "@rain", 2.1,
                kind="flat", opacity=0.3),
              F("drips", [icon("droplet", cx - 60 + i * 40, 380 + (i % 2) * 20, 10, 16) for i in range(4)], "@rain", 2.2,
                kind="flat", opacity=0.6)]
    frames = None
    rec = _r(asset_id, f, (W, H), (cx, 500), note, seed, frames=frames)
    if pulled:
        rec["note"] += " Pulled back toward the aisle and turned (place it rotated/offset per scene_s02_dining.json)."
    return rec


@asset("obj_s02_chair_family")
def chair_family():
    return _chair("obj_s02_chair_family", "VISUAL 1: family dining chair with the Morren crest embroidered on the "
                  "backrest (used three times: Helen, Luca, Eva).", 413, crest="shield")


@asset("obj_s02_chair_silla")
def chair_silla():
    return _chair("obj_s02_chair_silla", "VISUAL 1: Silla's chair - her black briefcase hangs on the backrest.", 414,
                  briefcase=True)


@asset("obj_s02_chair_peter")
def chair_peter():
    return _chair("obj_s02_chair_peter", "VISUAL 1: Peter's chair - the butler's apron hook on the backrest.", 415,
                  apron_hook=True)


@asset("obj_s02_chair_guest")
def chair_guest():
    return _chair("obj_s02_chair_guest", "VISUAL 1 / hinge A: the plain Guest chair, pushed back toward the aisle, a "
                  "rain-wet coat over its back, drips on the floor.", 416, coat=True, pulled=True, mat="wood_dark")


@asset("obj_s02_seat_plan")
def seat_plan():
    W, H = 150, 120
    f = [F("stand", [quad([(40, 108), (110, 108), (100, 116), (50, 116)])], "brass", 0.9, line=LS),
         F("card", [rect(20, 14, 130, 104)], "paper_ivory", 1.0, line=LS),
         F("table", [rect(46, 44, 104, 74)], "paper_ivory", 1.1, kind="flat", color="#c2b797", line=LX),
         F("seats", [ell(56 + i * 20, 36, 12, 12) for i in range(3)] + [ell(56 + i * 20, 82, 12, 12) for i in range(3)],
           "ink_line", 1.2, kind="flat", opacity=0.7),
         F("guest_mark", [ell(96, 82, 14, 14)], "ink_red", 1.3, kind="flat", opacity=0.5)]
    return _r("obj_s02_seat_plan", f, (W, H), (75, 112), "B1: seating card on a small brass stand (six seats; one marked "
              "'outside guest' = game text).", 417)


# ------------------------------------------------------------------ C study (iso)
@asset("obj_s02_sofa")
def sofa():
    io, size = iso_frame(0.9, 2.0, 0.95, pad=50)
    f = [iso_shadow(io, 0, 0, 0.9, 2.0)]
    ct, cl, cr = ("cloth_wine", "#5a2b33"), ("cloth_wine", "#4a232a"), ("cloth_wine", "#35191e")
    f += io.box("base", 0.05, 0.05, 0.08, 0.9, 1.95, 0.42, ct, cl, cr, z=1.0, line=LT)
    f += io.box("back", 0.0, 0.0, 0.42, 0.25, 2.0, 0.92, ct, cl, cr, z=0.8, line=LT)
    f += io.box("arm_l", 0.2, 0.0, 0.42, 0.9, 0.2, 0.66, ct, cl, cr, z=1.5, line=LT)
    f += io.box("arm_r", 0.2, 1.8, 0.42, 0.9, 2.0, 0.66, ct, cl, cr, z=1.6, line=LT)
    f += io.box("cushions", 0.25, 0.2, 0.42, 0.88, 1.8, 0.5, ("cloth_wine", "#633039"), ("cloth_wine", "#512730"),
                ("cloth_wine", "#3a1c22"), z=1.2, line=LS)
    t, l, r = tones("wood_dark")
    for (x, y) in ((0.82, 0.08), (0.82, 1.9)):
        f += io.box(f"foot{y}", x, y, 0, x + 0.06, y + 0.06, 0.08, t, l, r, z=0.9, line=LS)
    f.append(F("buttons", [ell(*io.p(0.05, 0.3 + i * 0.35, 0.75), 8, 8) for i in range(5)], "brass", 0.95, kind="flat"))
    return _r("obj_s02_sofa", f, size, io.p(0.45, 1.0), "C: wine velvet sofa in the study (Silla lies slumped on it).",
              420)


@asset("obj_s02_desk_will")
def desk_will():
    io, size = iso_frame(0.8, 1.5, 1.0, pad=50)
    f = [iso_shadow(io, 0, 0, 0.8, 1.5)]
    t, l, r = tones("wood_red")
    f += io.box("pedestal_a", 0.05, 0.05, 0, 0.75, 0.45, 0.72, t, l, r, z=1.0, line=LT)
    f += io.box("pedestal_b", 0.05, 1.05, 0, 0.75, 1.45, 0.72, t, l, r, z=1.1, line=LT)
    f += io.box("top", 0, 0, 0.72, 0.8, 1.5, 0.77, t, l, r, z=2.0, line=LT)
    f.append(F("leather", [io.floor(0.12, 0.25, 0.7, 1.25, Z=0.771)], "felt_green", 2.1, kind="flat", color="#2e3a2c"))
    f.append(F("drawers", [io.wall_y(0.1 + i * 0.12, 0.2 + i * 0.12, 0.1, 0.68, X=0.75) for i in range(0)] +
               [io.wall_y(0.08, 0.42, 0.1 + i * 0.2, 0.26 + i * 0.2, X=0.75) for i in range(3)] +
               [io.wall_y(1.08, 1.42, 0.1 + i * 0.2, 0.26 + i * 0.2, X=0.75) for i in range(3)], "wood_red", 1.5, kind="flat",
               color="#4a2e23", line=LS))
    f.append(F("will", [io.floor(0.25, 0.45, 0.62, 0.95, Z=0.775)], "paper_ivory", 2.2, line=LS))
    f.append(F("will_rows", [io.floor(0.3 + i * 0.05, 0.5, 0.31 + i * 0.05, 0.9, Z=0.777) for i in range(6)], "ink_line",
               2.3, kind="flat", opacity=0.45))
    f.append(F("inkwell", [ell(*io.p(0.2, 1.2, 0.8), 30, 16), rect(io.p(0.2, 1.2, 0.8)[0] - 12, io.p(0.2, 1.2, 0.8)[1] - 26,
                                                                     io.p(0.2, 1.2, 0.8)[0] + 12, io.p(0.2, 1.2, 0.8)[1])],
               "glass", 2.4, color="#2a2328", line=LS))
    f.append(F("pen", [limb(io.p(0.5, 1.1, 0.78), io.p(0.62, 1.3, 0.78), 5, 4)[0]], "plastic_black", 2.5))
    return _r("obj_s02_desk_will", f, size, io.p(0.4, 0.75), "C2: red-brown pedestal desk; the new will lies open on the "
              "green leather (unsigned; text in cu_s02_will).", 421)


@asset("obj_s02_wall_safe")
def wall_safe():
    """Right-wall safe door, open; inside: file folders, one gap with dust line (C3 / VISUAL 4)."""
    yl, zh = 0.75, 0.6
    pad = 40
    io = Iso((pad + 160, zh * PPM + pad + 30), K, PPM)
    W, H = int(yl * K + 2 * pad + 220), int(yl * K / 2 + zh * PPM + 2 * pad + 110)
    f = [F("inner", [io.wall_y(0, yl, 0, zh, X=0.0)], "metal_dark", 1.0, kind="flat", color="#1c1d20")]
    # file folders standing in the safe (seen through the opening), one slot empty
    folders = []
    y = 0.04
    for i in range(9):
        w = 0.05 if i != 5 else 0.0
        if i == 5:
            gap = (y, y + 0.07)
            y += 0.07
            continue
        folders.append(io.wall_y(y, y + w, 0.04, 0.5 - (i % 3) * 0.03, X=0.05))
        y += w + 0.012
    f.append(F("folders", folders, "paper_cream", 1.2, kind="flat", color="#8c7c5c", line=LX))
    f.append(F("dust_line", [io.wall_y(0.04, yl - 0.04, 0.5, 0.515, X=0.06)], "@worn", 1.3, kind="flat", opacity=0.6))
    f.append(F("gap_clean", [io.wall_y(gap[0], gap[1], 0.04, 0.515, X=0.055)], "@void_room", 1.25, kind="flat", opacity=0.8))
    f.append(F("string_marks", [io.wall_y(gap[0] - 0.005, gap[0] + 0.004, 0.2, 0.3, X=0.06),
                                io.wall_y(gap[1] - 0.004, gap[1] + 0.005, 0.2, 0.3, X=0.06)], "@ink", 1.35, kind="flat",
               opacity=0.7))
    # heavy door swung open toward the camera-left (edge-on parallelogram)
    door = quad([io.p(0.0, 0.0, zh), io.p(0.55, -0.02, zh + 0.02), io.p(0.55, -0.02, -0.02), io.p(0.0, 0.0, 0.0)])
    f.append(F("door", [door], "metal_grey", 2.0, kind="flat", color="#5b5f66", line=LT))
    dc = lerp(io.p(0.0, 0.0, zh / 2), io.p(0.55, -0.02, zh / 2), 0.5)
    f.append(F("dial", [ell(dc[0], dc[1], 40, 44)], "steel", 2.1, line=LS))
    f.append(F("handle", [box(dc[0] + 30, dc[1] + 30, 8, 40, rot=30)], "steel", 2.2, line=LS))
    piv = io.p(0.0, yl / 2, zh / 2)
    return _r("obj_s02_wall_safe", f, (W, H), piv, "C3 / VISUAL 4: wall safe in the study's right wall, heavy door swung "
              "open; inside, a row of file folders with ONE empty slot - the dust line breaks there and two pressed "
              "string marks flank it (width = cu_s02_preservation_cover). The will is not in the safe (it is on the "
              "desk).", 422, pm="safe opening centre on the right-wall plane (Y 3.0..3.75, Z 1.0..1.6 of bg_s02_study)")


@asset("obj_s02_window_soil")
def window_soil():
    W, H = 200, 70
    f = [F("soil", [icon("cloud", 100, 36, 150, 36), icon("metaballs", 70, 40, 60, 20)], "clay_grey", 1.0, line=LS),
         F("wet", [icon("droplet", 140, 38, 30, 14, rot=90)], "@rain", 1.1, kind="flat", opacity=0.3),
         F("v_groove", [icon("triangle", 104, 34, 30, 12, rot=180)],
           "mud", 1.2, kind="flat", opacity=0.9)]
    return _r("obj_s02_window_soil", f, (W, H), (100, 44), "C4: thin grey wet clay on the study window sill with one "
              "narrow V-groove print (compare cu_s02_shoe_soles / cu_s02_footprints).", 423, pm="sill contact line")


# ------------------------------------------------------------------ D service (front)
@asset("obj_s02_key_board")
def key_board():
    W, H = 360, 300
    f = [F("board", [rect(30, 30, 330, 270)], "wood_red", 1.0, line=LT),
         F("frame", [rect(20, 20, 340, 36), rect(20, 264, 340, 280)], "wood_dark", 1.1, kind="flat", line=LS)]
    hooks, keys, tags = [], [], []
    for r in range(3):
        for c in range(6):
            x, y = 70 + c * 46, 70 + r * 70
            hooks.append(ell(x, y, 8, 8))
            if (r, c) not in ((1, 4),):
                keys.append(icon("key", x, y + 26, 16, 38, rot=((r * 3 + c) % 5 - 2) * 6))
                tags.append(rect(x - 10, y + 44, x + 10, y + 56))
    f += [F("hooks", hooks, "brass", 1.2, kind="flat"), F("keys", keys, "brass", 1.3, line=LX),
          F("tags", tags, "paper_ivory", 1.4, kind="flat", opacity=0.9)]
    return _r("obj_s02_key_board", f, (W, H), (180, 24), "D: current key board in the butler's room (one hook empty is "
              "just a spare; the old staff-key rule is on the spec card, cu_s02_key_spec).", 430, pm="top centre hang point")


@asset("obj_s02_butler_desk")
def butler_desk():
    W, H = 640, 380
    f = [floor_shadow(320, 360, 580, 36),
         fblock("top", 40, 600, 80, 34, 26, "wood_dark", z=2.0),
         legs4(40, 600, 140, 360, 30, z=1.0),
         F("drawer_open", [rect(360, 150, 560, 200)], "wood_dark", 2.5, color="#3a2d1f", line=LT),
         F("drawer_inside", [rect(370, 150, 550, 170)], "@void_room", 2.6, kind="flat"),
         F("old_keys", [icon("key", 400 + i * 40, 158, 18, 40, rot=80) for i in range(3)], "brass", 2.7, line=LX),
         F("spec_chart", [quad([(420, 60), (560, 56), (566, 110), (424, 114)])], "paper_ivory", 3.0, line=LS),
         F("spec_lines", [rect(440, 72, 540, 75), rect(440, 90, 520, 93)], "ink_line", 3.1, kind="flat", opacity=0.5),
         F("silver_tray", [ell(160, 100, 160, 34)], "silver", 3.0, line=LS),
         F("wine_opener", [box(160, 96, 60, 8, rot=20)], "steel", 3.1, line=LX)]
    return _r("obj_s02_butler_desk", f, (W, H), (320, 360), "D2: butler's desk - drawer pulled out with old staff keys, "
              "the door/key spec chart on top, silver tray and wine opener (Peter's props).", 431)


@asset("obj_s02_payroll_ledger")
def payroll_ledger():
    W, H = 200, 110
    f = [floor_shadow(100, 96, 180, 14, 0.25, 3),
         F("cover", [quad([(14, 40), (186, 40), (194, 92), (6, 92)])], "leather_brown", 0.9, line=LS),
         F("pages", [quad([(22, 34), (98, 38), (98, 88), (14, 88)]), quad([(102, 38), (178, 34), (186, 88), (102, 88)])],
           "paper_cream", 1.0, line=LS),
         F("rows", [rect(30, 46 + i * 8, 90, 47 + i * 8) for i in range(5)] + [rect(110, 46 + i * 8, 172, 47 + i * 8)
                                                                             for i in range(5)], "ink_line", 1.1,
           kind="flat", opacity=0.5)]
    return _r("obj_s02_payroll_ledger", f, (W, H), (100, 94), "D3: old payroll ledger open on the butler's desk "
              "(Yona Pale's row: cu_s02_payroll).", 432, pm="bottom centre on the desk top")


# ------------------------------------------------------------------ E garden (side view)
@asset("obj_s02_gravestones")
def gravestones():
    W, H = 900, 380
    f = [floor_shadow(450, 360, 820, 30)]
    for i, (x, w, h, kind) in enumerate(((120, 120, 220, "round"), (380, 150, 260, "cross"), (660, 130, 200, "round"),
                                          (820, 90, 150, "round"))):
        top = 360 - h
        if kind == "cross":
            pcs = [rect(x - 18, top, x + 18, 360), rect(x - 60, top + 50, x + 60, top + 86)]
        else:
            pcs = [rect(x - w / 2, top + w / 2, x + w / 2, 360), ell(x, top + w / 2, w, w)]
        f.append(F(f"stone{i}", pcs, "stone_wall", 1.0 + i * 0.1, line=LT))
        f.append(F(f"moss{i}", [icon("cloud", x, 344, w * 0.9, 30)], "grass_dark", 1.05 + i * 0.1, kind="flat", opacity=0.7))
    return _r("obj_s02_gravestones", f, (W, H), (450, 360), "E: family headstones along the cemetery path (no "
              "inscriptions).", 440)


@asset("obj_s02_footprint_trail")
def footprint_trail():
    W, H = 1400, 140
    prints = []
    for i in range(9):
        x = 60 + i * 150
        y = 70 + (18 if i % 2 else -10)
        prints.append(ell(x, y, 60, 24, rot=4))
    f = [F("prints", prints, "mud", 1.0, kind="flat", opacity=0.9),
         F("grooves", [icon("triangle", 60 + i * 150, 70 + (18 if i % 2 else -10), 20, 10, rot=90) for i in range(9)], "@ink",
           1.1, kind="flat", opacity=0.5),
         F("clay", [icon("metaballs", 60 + i * 150, 72 + (18 if i % 2 else -10), 30, 12) for i in range(0, 9, 2)], "clay_grey",
           1.2, kind="flat", opacity=0.6)]
    return _r("obj_s02_footprint_trail", f, (W, H), (700, 70), "E1: one-direction trail of mud prints with a narrow "
              "V-groove each, from the cemetery side to under the study window (flat on the path).", 441,
              pm="trail centre on the ground")


@asset("obj_s02_case44_page")
def case44_page():
    W, H = 150, 90
    f = [F("page", [quad([(20, 30), (126, 20), (132, 70), (26, 80)])], "paper_cream", 1.0, line=LS),
         F("wet", [icon("cloud", 80, 56, 80, 30)], "@rain", 1.1, kind="flat", opacity=0.35),
         F("mud", [icon("metaballs", 40, 70, 40, 16)], "mud", 1.2, kind="flat", opacity=0.6),
         F("rows", [rect(36, 38 + i * 8, 110, 40 + i * 8) for i in range(4)], "ink_line", 1.3, kind="flat", opacity=0.4)]
    return _r("obj_s02_case44_page", f, (W, H), (76, 60), "E2: one fallen, rain-wet page of the Case 44 file on the path "
              "(text in cu_s02_case44).", 442)
