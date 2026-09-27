"""Stage 01 close-ups (message detail / comparison images).  Face-on, transparent,
paper-shaped.  No legible text: the game writes the words; lines mark where text
sits.  Visual clues (task board, sketches, prints) are drawn exactly."""

from __future__ import annotations

import math

from g06kit import F, box, ell, icon, limb, quad, recipe, rect, shadow
from s01_board import cells as board_cells
from s01_common import PAL, asset

LT = {"width": 1.6, "heavy": 1.8, "breaks": 0.25}
LS = {"width": 1.1, "heavy": 1.2, "breaks": 0.2}
LX = {"width": 0.7, "heavy": 0.7, "breaks": 0.1}
PAPER_GRIME = {"stamps": ["sponge", "metaballs", "cloud"], "size": 34, "soft": 4, "density": 0.07, "strength": 0.2,
               "color": "foxing", "lo": 0.25}


def drop(pieces, opacity=0.35, blur=10):
    return shadow("shadow", pieces, opacity, blur)


def text_rows(x0, x1, y0, n, step, mat="ink_line", z=5.0, name="rows", ragged=True, thick=4, opacity=0.5):
    rows = []
    for i in range(n):
        w = (x1 - x0) * (1.0 if not ragged else (0.62 + 0.38 * ((i * 37) % 10) / 10))
        rows.append(rect(x0, y0 + i * step, x0 + w, y0 + i * step + thick))
    return F(name, rows, mat, z, kind="flat", opacity=opacity)


def scribble(x0, y, length, mat="pencil", z=5.2, name="scribble", h=10, seg=26, opacity=0.8, rot=0.0):
    """Handwriting stand-in: a run of small tilted strokes (no letters)."""
    pcs = []
    x = x0
    k = 0
    while x < x0 + length:
        w = seg * (0.5 + ((k * 7) % 5) / 8)
        pcs.append(box(x + w / 2, y + ((k * 3) % 3 - 1) * 1.5, w, h * 0.34, rot=rot + ((k * 13) % 9 - 4)))
        x += w + seg * 0.25
        k += 1
    return F(name, pcs, mat, z, kind="flat", opacity=opacity)


def sheet(W, H, x0, y0, x1, y1, mat="paper_ivory", name="sheet", fold=None, tilt=0.0, holes=False, z=1.0):
    pcs = [quad([(x0, y0), (x1, y0 + tilt), (x1, y1 + tilt), (x0, y1)])]
    f = [drop([quad([(x0 + 10, y0 + 12), (x1 + 10, y0 + tilt + 12), (x1 + 10, y1 + tilt + 12), (x0 + 10, y1 + 12)])]),
         F(name, pcs, mat, z, line=LS, shade={"bump": 0.2, "highlight_amount": 0.2}, grime=PAPER_GRIME)]
    if holes:
        hs = [ell(x0 + 22, y, 12, 12) for y in range(int(y0 + 30), int(y1 - 10), 44)] + \
             [ell(x1 - 22, y, 12, 12) for y in range(int(y0 + 30), int(y1 - 10), 44)]
        f.append(F(name + "_holes", hs, "@ink", z + 0.1, kind="flat", opacity=0.6))
        f.append(F(name + "_perf", [rect(x0 + 40, y0, x0 + 42, y1), rect(x1 - 42, y0, x1 - 40, y1)], "@joint_dark",
                   z + 0.11, kind="flat", opacity=0.25))
    return f


def band(x0, y0, x1, y1, color="#56573f", z=2.0, name="band"):
    return F(name, [rect(x0, y0, x1, y1)], "card_olive", z, kind="flat", color=color)


@asset("cu_s01_lens_case")
def cu_lens_case():
    W, H = 900, 600
    f = [drop([ell(450, 330, 700, 360)]),
         F("case", [ell(300, 300, 320, 320), ell(600, 300, 320, 320), rect(300, 220, 600, 380)], "glass_clear", 1.0,
           line=LT, opacity=0.95),
         F("lens_l", [ell(300, 300, 250, 250)], "glass_clear", 1.1, kind="flat", color="#b9c3c6", opacity=0.55, line=LS),
         F("lens_r", [ell(600, 300, 250, 250)], "glass_clear", 1.1, kind="flat", color="#b9c3c6", opacity=0.55, line=LS),
         F("marker_dots", [ell(300, 300, 16, 16), ell(600, 300, 16, 16)], "@ink", 1.2, kind="flat", opacity=0.7),
         F("crack", [icon("lightning_bolt", 610, 280, 40, 190, rot=24), icon("lightning_bolt", 640, 330, 26, 110, rot=-40),
                     icon("lightning_bolt", 570, 250, 20, 90, rot=70)], "@ink", 1.3, kind="flat", opacity=0.75),
         F("shards", [icon("triangle", 700, 420, 30, 24, rot=30), icon("triangle", 520, 430, 20, 16, rot=-20)],
           "glass_clear", 1.35, line=LS),
         F("hinge", [rect(430, 180, 470, 420)], "steel", 1.4, line=LS),
         F("plate", [rect(330, 470, 570, 540)], "steel", 1.5, line=LS),
         F("engraving", [rect(350, 488, 548, 494), rect(390, 512, 510, 518)], "@ink", 1.6, kind="flat", opacity=0.5)]
    return recipe("cu_s01_lens_case", f, (W, H), (450, 300), PAL, style="prop", seed=301,
                  note="A2 close-up: transparent twin lens case, both lenses carry a centre marker dot (eye-tracking "
                       "markers, power 0.00), the right one cracked with two loose shards; engraved steel plate "
                       "(EYE TRACK MARKER / 0.00 = game text on the plate lines).")


@asset("cu_s01_calib_printout")
def cu_calib():
    W, H = 760, 1000
    f = sheet(W, H, 60, 40, 700, 960, holes=True)
    f += [band(100, 70, 660, 110),
          text_rows(110, 420, 140, 3, 26),
          F("graph_box", [rect(110, 260, 650, 620)], "paper_ivory", 3.0, kind="flat", color="#c4b99b", line=LS),
          F("ref_band", [rect(112, 380, 648, 500)], "card_olive", 3.1, kind="flat", color="#9aa07a", opacity=0.45),
          F("ref_lines", [rect(112, 378, 648, 382), rect(112, 498, 648, 502)], "ink_blue", 3.2, kind="flat",
            opacity=0.7)]
    # square flash pulses: every peak inside the reference band
    pulses = []
    x = 130
    while x < 630:
        pulses += [rect(x, 470, x + 34, 474), rect(x + 32, 410, x + 36, 474), rect(x + 34, 410, x + 64, 414),
                   rect(x + 62, 410, x + 66, 474)]
        x += 70
    f.append(F("pulses", pulses, "ink_line", 3.3, kind="flat", opacity=0.85))
    f.append(text_rows(110, 650, 660, 8, 30))
    f.append(F("stamp", [ell(580, 880, 110, 110)], "ink_blue", 4.0, kind="flat", opacity=0.25, line=LS))
    return recipe("cu_s01_calib_printout", f, (W, H), (380, 500), PAL, style="prop", seed=302,
                  note="A3-1 calibration printout (continuous feed): university band, flash-input square pulses all "
                       "inside the shaded reference band (= input normal). Text rows blank for the game text.")


@asset("cu_s01_behavior_printout")
def cu_behavior():
    W, H = 760, 1000
    f = sheet(W, H, 60, 40, 700, 960, holes=True)
    f += [band(100, 70, 660, 110), text_rows(110, 420, 140, 3, 26)]
    cells, marks = [], []
    for r in range(3):
        for c in range(4):
            x0 = 130 + c * 128
            y0 = 260 + r * 128
            cells.append(rect(x0, y0, x0 + 104, y0 + 104))
            marks.append(rect(x0 + 30, y0 + 50, x0 + 74, y0 + 55))   # empty response dash in every cell
    f.append(F("trial_cells", cells, "paper_ivory", 3.0, kind="flat", color="#c4b99b", line=LS))
    f.append(F("no_response", marks, "ink_line", 3.1, kind="flat", opacity=0.7))
    f.append(F("total_box", [rect(470, 680, 650, 760)], "paper_ivory", 3.2, kind="flat", color="#c4b99b", line=LS))
    f.append(text_rows(110, 440, 700, 2, 30))
    f.append(text_rows(110, 650, 800, 5, 30))
    return recipe("cu_s01_behavior_printout", f, (W, H), (380, 500), PAL, style="prop", seed=303,
                  note="A3-2 behaviour-response printout: 12 trial cells (3x4) each with only an empty-response dash "
                       "(0/12 detected); a total box for the game text.")


@asset("cu_s01_task_board")
def cu_task_board():
    W, H = 1280, 820
    bx0, by0, bx1, by1 = 60, 60, 860, 760
    f = [drop([rect(bx0 + 14, by0 + 16, bx1 + 14, by1 + 16), rect(930, 120, 1240, 470)]),
         F("frame", [rect(bx0 - 22, by0 - 22, bx1 + 22, by1 + 22)], "wood_dark", 1.0, line=LT),
         F("panel", [rect(bx0, by0, bx1, by1)], "cork", 1.1, kind="flat", color="#6b6552", textured=True, line=LS)]
    cw, ch = (bx1 - bx0) / 4, (by1 - by0) / 4
    raised, rims, mags = [], [], {}
    for r, c, shape, key, mc in board_cells():
        cx = bx0 + cw * (c + 0.5)
        cy = by0 + ch * (r + 0.5)
        rims.append(icon(shape, cx + 5, cy + 6, cw * 0.66, ch * 0.66, fit="box"))
        raised.append(icon(shape, cx, cy, cw * 0.66, ch * 0.66, fit="box"))
        mags.setdefault(mc, []).append(icon(shape, cx - 2, cy - 3, cw * 0.5, ch * 0.5, fit="box"))
    f.append(F("outline_shadow", rims, "@joint_dark", 1.2, kind="flat", opacity=0.45))
    f.append(F("raised_outlines", raised, "cork", 1.3, kind="flat", color="#8a826a", line=LS))
    for i, (col, pcs) in enumerate(sorted(mags.items())):
        f.append(F("magnets_" + col, pcs, col, 1.4 + i * 0.01, line=LS))
    # the printed answer key, pinned beside the board
    kx0, ky0, kx1, ky1 = 930, 120, 1240, 470
    f.append(F("key_card", [rect(kx0, ky0, kx1, ky1)], "paper_ivory", 2.0, line=LS))
    f.append(F("key_band", [rect(kx0 + 16, ky0 + 14, kx1 - 16, ky0 + 40)], "card_olive", 2.1, kind="flat",
               color="#56573f"))
    kw, kh = (kx1 - kx0 - 40) / 4, (ky1 - ky0 - 80) / 4
    kgrid, kshapes = [], {}
    for r, c, shape, key, mc in board_cells():
        x = kx0 + 20 + kw * (c + 0.5)
        y = ky0 + 60 + kh * (r + 0.5)
        kgrid.append(rect(x - kw / 2 + 2, y - kh / 2 + 2, x + kw / 2 - 2, y + kh / 2 - 2))
        kshapes.setdefault(key, []).append(icon(shape, x, y, kw * 0.62, kh * 0.62, fit="box"))
    f.append(F("key_cells", kgrid, "paper_ivory", 2.2, kind="flat", color="#c2b797", line=LX))
    for i, (col, pcs) in enumerate(sorted(kshapes.items())):
        f.append(F("key_" + col, pcs, col, 2.3 + i * 0.01, kind="flat", line=LX))
    f.append(F("key_pin", [ell(1085, 118, 20, 20)], "ink_red", 2.5, line=LS))
    return recipe("cu_s01_task_board", f, (W, H), (640, 410), PAL, style="prop", seed=304,
                  note="VISUAL 2 close-up (no text): left = the 4x4 board, every cell with a raised tactile outline "
                       "and Mira's magnet sitting on the matching outline; right = the printed answer key. Shapes "
                       "match everywhere, colours are wrong in 15 of 16 cells (s01_board.py): visual behaviour "
                       "failed, touch discrimination kept. Same arrangement as obj_s01_task_board and the CCTV frame.")


@asset("cu_s01_eye_card")
def cu_eye_card():
    W, H = 920, 620
    f = sheet(W, H, 50, 50, 870, 570)
    f += [band(80, 76, 840, 120),
          F("pupil_ring", [ell(260, 300, 220, 150)], "paper_white", 3.0, kind="flat", line=LS),
          F("iris", [ell(260, 300, 110, 110)], "ink_blue", 3.1, kind="flat", color="#56607a", line=LS),
          F("pupil", [ell(260, 300, 44, 44)], "@ink", 3.2, kind="flat"),
          F("reflex_arrows", [icon("arrow_left", 170, 300, 40, 26), icon("arrow_right", 350, 300, 40, 26)], "ink_line",
            3.3, kind="flat", opacity=0.6),
          F("fundus", [ell(650, 300, 210, 210)], "cloth_red", 3.0, kind="flat", color="#7e5147", line=LS),
          F("disc", [ell(610, 290, 44, 44)], "paper_cream", 3.1, kind="flat", color="#c9ae82"),
          F("vessels", [icon("sprout", 650, 300, 170, 170, rot=90), icon("git_branch", 670, 320, 120, 120, rot=200)],
            "blood_dry", 3.2, kind="flat", opacity=0.7, clip_to="fundus"),
          text_rows(90, 500, 440, 3, 34), text_rows(560, 830, 440, 3, 34, name="rows_r"),
          F("check_boxes", [rect(90, 180, 118, 208), rect(560, 180, 588, 208)], "paper_ivory", 3.4, kind="flat",
            color="#c2b797", line=LX),
          F("ticks", [icon("checkmark", 104, 194, 26, 22), icon("checkmark", 574, 194, 26, 22)], "ink_blue", 3.5,
            kind="flat", opacity=0.85)]
    return recipe("cu_s01_eye_card", f, (W, H), (460, 310), PAL, style="prop", seed=305,
                  note="B1 eye exam card: pupil-reflex diagram and retina (fundus) diagram, both ticked normal; rows "
                       "for the time (50 min before) and values = game text. No behaviour results on this card.")


@asset("cu_s01_log_sheet")
def cu_log_sheet():
    W, H = 760, 1000
    f = sheet(W, H, 70, 40, 690, 960)
    f += [band(100, 70, 660, 108), text_rows(110, 400, 136, 2, 28)]
    f.append(F("col_line", [rect(230, 220, 233, 700)], "ink_line", 2.9, kind="flat", opacity=0.4))
    for i in range(3):
        y = 250 + i * 110
        f.append(scribble(110, y, 90, name=f"time{i}", mat="pencil"))
        f.append(scribble(260, y, 280 - i * 40, name=f"entry{i}", mat="pencil"))
    # bottom question in Mira's hand, the verb boxed (her habit, 13A-1)
    f.append(scribble(110, 800, 220, name="question_a"))
    f.append(scribble(360, 800, 120, name="question_verb"))
    f.append(F("verb_box", [rect(350, 780, 490, 784), rect(350, 816, 490, 820), rect(350, 780, 354, 820),
                            rect(486, 780, 490, 820)], "pencil", 5.3, kind="flat", opacity=0.8))
    f.append(scribble(510, 800, 120, name="question_b"))
    return recipe("cu_s01_log_sheet", f, (W, H), (380, 500), PAL, style="prop", seed=306,
                  note="B3 Mira's experiment log: three timed pencil entries and the handwritten question at the "
                       "bottom with the verb boxed (Mira's verb-boxing habit). Words = game text.")


@asset("cu_s01_pager")
def cu_pager():
    W, H = 920, 520
    f = [drop([rect(120, 110, 820, 440)]),
         F("body", [rect(100, 90, 800, 420)], "plastic_black", 1.0, line=LT, shade={"highlight_amount": 0.5}),
         F("clip", [rect(360, 50, 540, 100)], "plastic_black", 0.9, line=LS),
         F("display", [rect(150, 140, 640, 330)], "screen_glow", 1.1, kind="flat", line=LS, emit=0.4),
         F("display_rows", [rect(170, 170 + i * 50, 560 - (i % 2) * 90, 186 + i * 50) for i in range(3)], "@ink", 1.2,
           kind="flat", opacity=0.35),
         F("buttons", [ell(720, 180, 70, 70), ell(720, 290, 70, 70)], "steel", 1.3, line=LS),
         F("grip", [rect(150, 360, 640, 372), rect(150, 384, 640, 396)], "@joint_dark", 1.4, kind="flat", opacity=0.6)]
    return recipe("cu_s01_pager", f, (W, H), (450, 260), PAL, style="prop", seed=307,
                  note="B4 Grell's pager close-up: lit display with two message rows (01:50 to Lina, 02:08 guard call = "
                       "game text), two buttons. Display glow in _emit.png.")


@asset("cu_s01_labcoat_label")
def cu_labcoat_label():
    W, H = 900, 620
    f = [drop([quad([(60, 80), (840, 80), (760, 580), (140, 580)])]),
         F("collar", [quad([(60, 60), (840, 60), (760, 560), (140, 560)])], "labcoat", 1.0, line=LT),
         F("seam", [rect(90, 100, 810, 106)], "@joint_dark", 1.1, kind="flat", opacity=0.4),
         F("label", [rect(290, 200, 610, 360)], "paper_white", 1.2, line=LS),
         F("stitch_edge", [rect(300, 210, 600, 214), rect(300, 346, 600, 350), rect(300, 210, 304, 350),
                           rect(596, 210, 600, 350)], "ink_blue", 1.3, kind="flat", opacity=0.5)]
    # embroidered name: satin-stitch strokes, no letters
    st = []
    for i in range(4):
        x = 340 + i * 58
        st += [box(x, 280, 12, 70, rot=8 - i * 4), box(x + 22, 280, 12, 70, rot=-10 + i * 5)]
    f.append(F("embroidery", st, "ink_blue", 1.4, kind="flat", opacity=0.85))
    f.append(F("graphite", [icon("metaballs", 190, 470, 90, 50)], "pencil", 1.5, kind="flat", opacity=0.35,
               clip_to="collar"))
    return recipe("cu_s01_labcoat_label", f, (W, H), (450, 310), PAL, style="prop", seed=308,
                  note="C1-1 inner collar of Mira's spare lab coat with the embroidered name label (MIRA = game text "
                       "over the satin-stitch strokes).")


@asset("cu_s01_notebook")
def cu_notebook():
    W, H = 1100, 760
    f = [drop([rect(70, 80, 1060, 720)]),
         F("cover", [rect(40, 50, 1060, 710)], "leather_black", 0.9, line=LT),
         F("page_l", [quad([(70, 70), (548, 80), (548, 690), (70, 690)])], "paper_ivory", 1.0, line=LS),
         F("page_r", [quad([(552, 80), (1030, 70), (1030, 690), (552, 690)])], "paper_ivory", 1.1, line=LS),
         F("gutter", [rect(540, 78, 560, 692)], "@joint_dark", 1.2, kind="flat", opacity=0.3),
         F("ruling", [rect(100, 130 + i * 40, 520, 132 + i * 40) for i in range(13)] +
           [rect(580, 130 + i * 40, 1000, 132 + i * 40) for i in range(13)], "ink_blue", 1.3, kind="flat", opacity=0.18)]
    for i in range(10):
        f.append(scribble(110, 126 + i * 40, 380 - (i % 4) * 50, name=f"l{i}"))
    for i in range(6):
        f.append(scribble(590, 126 + i * 40, 360 - (i % 3) * 60, name=f"r{i}"))
    boxes = []
    for (x, y) in ((250, 166), (330, 326), (700, 206)):
        boxes += [rect(x, y - 16, x + 90, y - 13), rect(x, y + 13, x + 90, y + 16), rect(x, y - 16, x + 3, y + 16),
                  rect(x + 87, y - 16, x + 90, y + 16)]
    f.append(F("verb_boxes", boxes, "pencil", 5.4, kind="flat", opacity=0.8))
    f.append(F("elastic", [rect(960, 40, 980, 720)], "cloth_red", 6.0, line=LS))
    return recipe("cu_s01_notebook", f, (W, H), (550, 380), PAL, style="prop", seed=309,
                  note="C1-2 Mira's research notebook, open: pencil lines of the entry with several verbs boxed (her "
                       "habit). The entry text is game text.")


@asset("cu_s01_repair_card")
def cu_repair_card():
    W, H = 940, 640
    f = sheet(W, H, 50, 50, 890, 590)
    f += [band(80, 76, 860, 118),
          F("diagram", [rect(110, 180, 300, 300), rect(375, 180, 565, 300), rect(640, 180, 830, 300)], "paper_ivory",
            3.0, kind="flat", color="#c2b797", line=LS),
          F("arrows", [icon("arrow_right", 338, 240, 60, 36), icon("arrow_right", 603, 240, 60, 36)], "ink_line", 3.1,
            kind="flat", opacity=0.8),
          F("icons", [icon("plug", 205, 240, 60, 60), icon("cog", 470, 240, 60, 60), icon("lightbulb", 735, 240, 60, 60)],
            "ink_line", 3.2, kind="flat", opacity=0.55)]
    f.append(scribble(110, 380, 460, name="rule_line"))
    f.append(scribble(110, 440, 300, name="rule_line2"))
    f.append(F("oil_thumb", [icon("fingerprint", 660, 400, 110, 110, rot=12)], "@soot", 6.0, kind="flat", opacity=0.5))
    f.append(F("oil_smear", [icon("metaballs", 700, 450, 90, 40)], "@soot", 6.1, kind="flat", opacity=0.25))
    return recipe("cu_s01_repair_card", f, (W, H), (470, 320), PAL, style="prop", seed=310,
                  note="C2 / hinge C: equipment repair card in Mira's hand. INPUT -> PART -> OUTPUT box diagram "
                       "(plug, cog, bulb pictograms), the handwritten rule line, and an oily right-thumb smudge right "
                       "beside it (same hand as the tool print).")


@asset("cu_s01_name_cards")
def cu_name_cards():
    W, H = 1180, 520
    f = []
    xs = [150, 430, 710, 990]
    for i, x in enumerate(xs):
        f += [drop([rect(x - 118, 72, x + 132, 470)], 0.3, 8),
              F(f"card{i}", [rect(x - 125, 60, x + 125, 460)], "paper_ivory", 1.0 + i * 0.1, line=LS),
              F(f"frame{i}", [rect(x - 100, 90, x + 100, 330)], "paper_ivory", 1.05 + i * 0.1, kind="flat",
                color="#c4b99b", line=LX)]
    f.append(F("pic_eye", [icon("eye", xs[0], 210, 150, 100)], "ink_line", 2.0, kind="flat", opacity=0.85))
    f.append(F("pic_photo", [rect(xs[1] - 80, 150, xs[1] + 80, 270)], "paper_white", 2.0, kind="flat", line=LS))
    f.append(F("pic_photo_scene", [icon("mountains", xs[1], 222, 140, 80), icon("sun", xs[1] + 40, 175, 30, 30)], "ink_line",
               2.1, kind="flat", opacity=0.7))
    f.append(F("pic_red", [rect(xs[2] - 70, 140, xs[2] + 70, 280)], "ink_red", 2.0, kind="flat"))
    f.append(F("pic_look", [icon("person_body", xs[3] - 40, 220, 90, 140), icon("binoculars", xs[3] + 30, 170, 70, 50),
                            icon("eye", xs[3] + 60, 260, 50, 34)], "ink_line", 2.0, kind="flat", opacity=0.8))
    for i, x in enumerate(xs):
        f.append(text_rows(x - 90, x + 90, 360, 2, 30, name=f"cap{i}", ragged=False))
    f.append(F("marks_ok", [icon("checkmark", xs[i] + 80, 420, 50, 44) for i in range(3)], "pencil", 3.0, kind="flat",
               opacity=0.9))
    f.append(F("mark_fail", [icon("cross", xs[3] + 80, 420, 44, 44), icon("help", xs[3] - 60, 420, 40, 40)], "pencil", 3.0,
               kind="flat", opacity=0.9))
    return recipe("cu_s01_name_cards", f, (W, H), (590, 260), PAL, style="prop", seed=311,
                  note="C3 picture naming cards (4, v5.3): eye, photograph, red - each ticked (named correctly); the "
                       "'looking' action card is crossed with a question mark (explanation failed). Captions = game "
                       "text.")


@asset("cu_s01_roster")
def cu_roster():
    W, H = 760, 1000
    f = sheet(W, H, 70, 40, 690, 960)
    f += [band(100, 70, 660, 116), text_rows(110, 420, 146, 2, 28)]
    f.append(F("table", [rect(110, 230, 650, 560)], "paper_ivory", 3.0, kind="flat", color="#c4b99b", line=LS))
    f.append(F("table_rows", [rect(110, 230 + i * 110, 650, 233 + i * 110) for i in range(1, 3)] +
               [rect(380, 230, 383, 560)], "ink_line", 3.1, kind="flat", opacity=0.5))
    f.append(text_rows(130, 360, 270, 3, 110, name="names", ragged=False, thick=8, opacity=0.55))
    f.append(text_rows(400, 630, 270, 3, 110, name="roles", ragged=False, thick=8, opacity=0.55))
    f.append(F("pins", [ell(140, 50, 26, 26), ell(620, 50, 26, 26)], "ink_red", 4.0, line=LS))
    return recipe("cu_s01_roster", f, (W, H), (380, 500), PAL, style="prop", seed=312,
                  note="C4 department roster: three typed rows (Venn, Mira - Graduate Researcher / Orr, Lina - "
                       "Undergraduate Assistant / Grell, Thomas - Principal Investigator = game text).")


def _room_sketch(ox, oy, s, persp=True):
    """Pencil drawing of the lab (for the two sketchbook pages)."""
    if persp:
        # corner, receding walls, floor lines, bench box, window, board, CRT - real perspective
        lines = [((0, 0), (0, 300)), ((0, 300), (-340, 470)), ((0, 300), (360, 480)), ((0, 0), (-340, -110)),
                 ((0, 0), (360, -120)), ((-260, 60), (-100, 30)), ((-260, 60), (-260, 220)), ((-100, 30), (-100, 190)),
                 ((-260, 220), (-100, 190)), ((80, 40), (220, 70)), ((80, 40), (80, 150)), ((220, 70), (220, 180)),
                 ((80, 150), (220, 180)), ((-120, 380), (60, 330)), ((60, 330), (200, 400)), ((200, 400), (20, 460)),
                 ((20, 460), (-120, 380)), ((-120, 380), (-120, 440)), ((20, 460), (20, 520)), ((200, 400), (200, 460)),
                 ((-120, 440), (20, 520)), ((20, 520), (200, 460)), ((-300, 300), (-200, 280)), ((-300, 300), (-300, 360)),
                 ((-200, 280), (-200, 340))]
        for k in range(1, 6):
            lines.append(((-340 + k * 20, 470 - k * 34), (360 - k * 20, 480 - k * 36)))
        return [limb((ox + a[0] * s, oy + a[1] * s), (ox + b[0] * s, oy + b[1] * s), 3.2, 3.2, caps=False)
                for a, b in lines]
    # incident day: no depth - things become name tags and touched outlines scattered flat
    out = []
    for (x, y, w, h) in ((-250, 40, 120, 70), (90, 60, 110, 80), (-60, 300, 190, 90), (-280, 280, 80, 60),
                         (200, 330, 90, 60)):
        out.append(("outline", ell(ox + x * s, oy + y * s, w * s, h * s)))
        out.append(("tag", rect(ox + (x - 34) * s, oy + (y + h * 0.7) * s, ox + (x + 34) * s, oy + (y + h * 0.7 + 26) * s)))
    return out


@asset("cu_s01_sketch_prev")
def cu_sketch_prev():
    W, H = 1060, 780
    f = sheet(W, H, 40, 40, 1020, 740, mat="paper_white")
    f.append(F("spiral", [ell(90 + i * 60, 40, 14, 24) for i in range(15)], "steel", 2.0, kind="flat", line=LX))
    f.append(F("sketch", sum((pc for pc in _room_sketch(540, 200, 1.0, True)), []), "pencil", 3.0, kind="flat",
               opacity=0.8))
    hatch = [box(260 + i * 14, 470 + (i % 3) * 4, 3, 60, rot=30) for i in range(10)] + \
            [box(640 + i * 14, 560, 3, 50, rot=30) for i in range(8)]
    f.append(F("hatching", hatch, "pencil", 3.1, kind="flat", opacity=0.45))
    f.append(F("tone", [quad([(420, 580), (600, 530), (740, 600), (560, 660)])], "pencil", 2.9, kind="flat",
               opacity=0.12))
    f.append(scribble(80, 710, 140, name="date", opacity=0.6))
    return recipe("cu_s01_sketch_prev", f, (W, H), (530, 390), PAL, style="prop", seed=313,
                  note="VISUAL 3 (a): last month's sketchbook page - the lab drawn in correct perspective (corner, "
                       "receding walls, window, board, CRT, bench box, floor lines, shading). Compare with "
                       "cu_s01_sketch_day.")


@asset("cu_s01_sketch_day")
def cu_sketch_day():
    W, H = 1060, 780
    f = sheet(W, H, 40, 40, 1020, 740, mat="paper_white")
    f.append(F("spiral", [ell(90 + i * 60, 40, 14, 24) for i in range(15)], "steel", 2.0, kind="flat", line=LX))
    parts = _room_sketch(540, 260, 1.0, False)
    f.append(F("touch_outlines", [p for k, p in parts if k == "outline"], "paper_white", 3.0, kind="flat",
               color="#c8c2b2", line={"width": 2.2, "heavy": 2.6, "breaks": 0.5}, rough={"amp": 0.5, "soft": 2, "cell": 8}))
    f.append(F("name_tags", [p for k, p in parts if k == "tag"], "paper_white", 3.1, kind="flat", color="#d0cabc",
               line=LX))
    tags = [p for k, p in parts if k == "tag"]
    for i, t in enumerate(tags):
        x, y = t["at"]
        f.append(scribble(x - 26, y, 52, name=f"tag_word{i}", h=8, seg=14))
    f.append(scribble(80, 710, 140, name="date", opacity=0.6))
    return recipe("cu_s01_sketch_day", f, (W, H), (530, 390), PAL, style="prop", seed=314,
                  note="VISUAL 3 (b): the incident-day sheet of the same room - no perspective, no tone: only "
                       "wobbly touched outlines and little name tags with words (game text), scattered flat.")


@asset("cu_s01_tool_print")
def cu_tool_print():
    W, H = 1100, 520
    f = [drop([box(560, 280, 900, 150, rot=-6)]),
         F("handle", [box(470, 260, 620, 170, rot=-6)], "plastic_black", 1.0, line=LT, shade={"highlight_amount": 0.6}),
         F("grip_rings", [box(220 + i * 40, 290 - i * 4, 8, 150, rot=-6) for i in range(4)], "@joint_dark", 1.1,
           kind="flat", opacity=0.6),
         F("ferrule", [box(810, 225, 60, 110, rot=-6)], "steel", 1.2, line=LS),
         F("shaft", [box(950, 212, 240, 30, rot=-6)], "steel", 1.3, line=LS),
         F("thumb_print", [icon("fingerprint", 520, 250, 150, 150, rot=-6)], "blood", 1.5, kind="flat", opacity=0.92),
         F("smear", [icon("metaballs", 600, 300, 80, 36, rot=-6)], "blood_dry", 1.4, kind="flat", opacity=0.7)]
    return recipe("cu_s01_tool_print", f, (W, H), (550, 260), PAL, style="prop", seed=315,
                  note="D1 / hinge C: the instrument handle with a bloody RIGHT-thumb whorl print. The whorl is the "
                       "same shape as the inked print on cu_s01_access_card (IMAGE <-> IMAGE comparison).")


@asset("cu_s01_access_card")
def cu_access_card():
    W, H = 920, 620
    f = sheet(W, H, 50, 50, 870, 570, mat="paper_white")
    f += [band(80, 76, 840, 124, color="#3b4658"),
          F("photo_box", [rect(100, 170, 300, 420)], "paper_ivory", 3.0, kind="flat", color="#a9a08a", line=LS),
          F("photo_person", [icon("person_body", 200, 320, 150, 190)], "ink_line", 3.1, kind="flat", opacity=0.35),
          F("print_box", [rect(560, 170, 820, 450)], "paper_ivory", 3.0, kind="flat", color="#c4b99b", line=LS),
          F("thumb_print", [icon("fingerprint", 690, 310, 180, 180)], "@ink", 3.2, kind="flat", opacity=0.85),
          text_rows(330, 520, 190, 5, 44), text_rows(100, 520, 470, 2, 36, name="rows_b")]
    return recipe("cu_s01_access_card", f, (W, H), (460, 310), PAL, style="prop", seed=316,
                  note="D1 comparison: Mira's building access card with her inked right-thumb print (whorl identical "
                       "to the bloody print on cu_s01_tool_print). Name/number rows = game text.")


@asset("cu_s01_copier_log")
def cu_copier_log():
    W, H = 760, 1000
    f = sheet(W, H, 70, 40, 690, 960)
    f += [band(100, 70, 660, 110), text_rows(110, 420, 140, 2, 28)]
    grid = [rect(110, 220 + i * 60, 650, 222 + i * 60) for i in range(11)] + \
           [rect(250, 220, 252, 820), rect(460, 220, 462, 820), rect(560, 220, 562, 820)]
    f.append(F("grid", grid, "ink_line", 3.0, kind="flat", opacity=0.4))
    for i, row in enumerate((7, 8)):
        y = 220 + row * 60 + 30
        f.append(scribble(130, y, 100, name=f"t{i}"))
        f.append(scribble(270, y, 160, name=f"n{i}"))
        f.append(scribble(480, y, 60, name=f"c{i}"))
    f.append(F("highlight", [rect(112, 222 + 7 * 60, 648, 220 + 9 * 60)], "@magnet_yellow", 2.9, kind="flat",
               opacity=0.18))
    return recipe("cu_s01_copier_log", f, (W, H), (380, 500), PAL, style="prop", seed=317,
                  note="D2 copier usage log: two handwritten rows (01:52 L. Orr 14 sheets / 02:06 L. Orr 6 sheets = "
                       "game text) in the ruled table.")


@asset("cu_s01_guard_log")
def cu_guard_log():
    W, H = 780, 1020
    f = [drop([rect(90, 60, 700, 990)]),
         F("clipboard", [rect(70, 40, 710, 990)], "wood_ochre", 1.0, line=LT),
         F("paper", [rect(110, 110, 670, 950)], "paper_ivory", 1.1, line=LS),
         F("clip", [rect(290, 20, 490, 130)], "steel", 1.2, line=LS),
         band(140, 150, 640, 190)]
    f.append(F("grid", [rect(140, 250 + i * 64, 640, 252 + i * 64) for i in range(10)] + [rect(300, 250, 302, 890)],
               "ink_line", 2.0, kind="flat", opacity=0.4))
    for i in range(2):
        y = 250 + (5 + i) * 64 + 32
        f.append(scribble(160, y, 110, name=f"t{i}", mat="ink_blue"))
        f.append(scribble(320, y, 250 - i * 60, name=f"e{i}", mat="ink_blue"))
    return recipe("cu_s01_guard_log", f, (W, H), (390, 510), PAL, style="prop", seed=318,
                  note="D3 guard call/arrival clipboard: two blue-ink rows (02:08 call / 02:11 Ed Faro on floor 4 = "
                       "game text).")
