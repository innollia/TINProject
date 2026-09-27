"""Shared front-view furniture / wall pieces, iso object frames and paper helpers
(moved out of the Stage 01 scripts so every later stage uses the same look)."""

from __future__ import annotations

import math

from . import F, box, ell, icon, limb, quad, rect, shadow
from .iso import Iso

LT = {"width": 1.2, "heavy": 1.4, "breaks": 0.25}
LS = {"width": 0.9, "heavy": 1.0, "breaks": 0.2}
LX = {"width": 0.7, "heavy": 0.7, "breaks": 0.1}
LC = {"width": 1.6, "heavy": 1.8, "breaks": 0.25}   # close-up outline
LCS = {"width": 1.1, "heavy": 1.2, "breaks": 0.2}
LINE_ENV = {"width": 2.0, "heavy": 2.2, "breaks": 0.3}
LINE_THIN = {"width": 1.4, "heavy": 1.6, "breaks": 0.3}
ISO_SKEW_Y = [0.0, math.degrees(math.atan(0.5))]    # shapes lying on a right-wall plane (constant X)
ISO_SKEW_X = [0.0, -math.degrees(math.atan(0.5))]   # shapes on a left-wall plane (constant Y)
PAPER_GRIME = {"stamps": ["sponge", "metaballs", "cloud"], "size": 34, "soft": 4, "density": 0.07, "strength": 0.2,
               "color": "foxing", "lo": 0.25}

TONES = {"wood_ochre": ("#6a5334", "#53412a", "#372a1b"), "wood_dark": ("#4a3a28", "#3a2d1f", "#261d14"),
         "wood_red": ("#5c3a2c", "#4a2e23", "#321e17"),
         "metal_grey": ("#585c62", "#45484e", "#2e3035"), "metal_dark": ("#3f4247", "#303236", "#1f2023"),
         "plastic_beige": ("#8c8470", "#746c5a", "#58513f"), "plastic_black": ("#262427", "#1c1a1d", "#121113"),
         "stone": ("#5a5260", "#3d3645", "#26212d"), "paper_ivory": ("#b6ab8f", "#9a9076", "#7a715b")}


def tones(mat):
    t, l, r = TONES[mat]
    return (mat, t), (mat, l), (mat, r)


# ------------------------------------------------------------------ iso objects
def iso_frame(xl, yl, zh, pad=40, k=250.0, kz=320.0):
    origin = (xl * k + pad, zh * kz + pad)
    W = int(math.ceil((xl + yl) * k + 2 * pad))
    H = int(math.ceil((xl + yl) * k / 2 + zh * kz + 2 * pad))
    return Iso(origin, k, kz), (W, H)


def iso_shadow(io, X0, Y0, X1, Y1, grow=0.06, opacity=0.4, blur=8):
    return shadow("shadow", [io.floor(X0 - grow, Y0 - grow, X1 + grow, Y1 + grow)], opacity, blur)


# ------------------------------------------------------------------ front-view furniture
def fblock(name, x0, x1, y_top, depth, height, mat, z=1.0, line=None, color=None, **kw):
    """Face-on block: ``depth`` px of visible top face, ``height`` px of front face."""
    f = F(name, [rect(x0, y_top, x1, y_top + depth)], mat, z, kind="block", extrude=height, line=line or LT, **kw)
    if color:
        f["color"] = color
    return f


def legs4(x0, x1, y0, y1, w, mat="wood_dark", z=0.5, inset=10, name="legs"):
    return F(name, [rect(x0 + inset, y0, x0 + inset + w, y1), rect(x1 - inset - w, y0, x1 - inset, y1)], mat, z,
             line=LS)


def floor_shadow(cx, cy, w, h, opacity=0.35, blur=8):
    return shadow("shadow", [ell(cx, cy, w, h)], opacity, blur)


def chair_front(cx, floor_y, mat="wood_dark", seat_y=None, back_h=260, w=150, z=1.0, crest=None, name="chair"):
    """Dining chair seen face-on (back toward the camera side not assumed)."""
    seat_y = seat_y or floor_y - 150
    f = [F(name + "_legs", [rect(cx - w / 2 + 8, seat_y + 10, cx - w / 2 + 24, floor_y),
                            rect(cx + w / 2 - 24, seat_y + 10, cx + w / 2 - 8, floor_y)], mat, z, line=LS),
         fblock(name + "_seat", cx - w / 2, cx + w / 2, seat_y - 14, 22, 16, mat, z=z + 0.1),
         F(name + "_back", [rect(cx - w / 2 + 6, seat_y - 14 - back_h, cx + w / 2 - 6, seat_y - 10)], mat, z + 0.05,
           line=LT),
         F(name + "_back_hole", [rect(cx - w / 2 + 26, seat_y - back_h + 20, cx + w / 2 - 26, seat_y - 60)], "@void_room",
           z + 0.06, kind="flat", opacity=0.55)]
    if crest:
        f.append(F(name + "_crest", [icon(crest, cx, seat_y - back_h + 30, 44, 44)], "brass", z + 0.07, line=LS))
    return f


# ------------------------------------------------------------------ face-on walls
def wall_panels(y_top, y_bot, x0, x1, n, mat="wainscot", color=None, z=3.2, skirt=36, rail=14):
    f = [F("wainscot", [rect(x0, y_top, x1, y_bot)], mat, z, kind="flat", textured=True, line=LINE_THIN)]
    if color:
        f[0]["color"] = color
    step = (x1 - x0) / n
    divs = [rect(x0 + step * i - 3, y_top + 14, x0 + step * i + 3, y_bot - skirt - 6) for i in range(1, n)]
    insets = [rect(x0 + step * i + 22, y_top + 26, x0 + step * (i + 1) - 22, y_bot - skirt - 22) for i in range(n)]
    f += [F("wainscot_divs", divs, "@joint_dark", z + 0.01, kind="flat", opacity=0.6),
          F("wainscot_insets", insets, "@ink", z + 0.015, kind="flat", opacity=0.12),
          F("rail", [rect(x0, y_top - rail, x1, y_top + 2)], "wood_dark", z + 0.02, kind="flat", line=LINE_THIN),
          F("skirting", [rect(x0, y_bot - skirt, x1, y_bot)], "wood_dark", z + 0.03, kind="flat", line=LINE_THIN)]
    return f


def front_door(name, x0, x1, y_top, y_bot, z=4.0, state="closed", leaf="wood_dark", pane=False, inside="@void_room",
               handle_right=True, frame="wood_dark"):
    fw = 22
    f = [F(name + "_frame", [rect(x0 - fw, y_top - fw, x0, y_bot), rect(x1, y_top - fw, x1 + fw, y_bot),
                             rect(x0 - fw, y_top - fw, x1 + fw, y_top)], frame, z, kind="flat", line=LINE_THIN)]
    if state == "open":
        f.append(F(name + "_void", [rect(x0, y_top, x1, y_bot)], inside, z + 0.01, kind="flat"))
    else:
        f.append(F(name + "_leaf", [rect(x0, y_top, x1, y_bot)], leaf, z + 0.01, kind="flat", textured=True,
                   line=LINE_THIN))
        ins = 34
        f.append(F(name + "_panels", [rect(x0 + ins, y_top + ins, x1 - ins, (y_top + y_bot) / 2 - 20),
                                      rect(x0 + ins, (y_top + y_bot) / 2 + 20, x1 - ins, y_bot - ins)], "@ink",
                   z + 0.02, kind="flat", opacity=0.16))
        if pane:
            f.append(F(name + "_pane", [rect(x0 + 50, y_top + 50, x1 - 50, y_top + (y_bot - y_top) * 0.36)],
                       "glass_booth", z + 0.03, kind="flat", line=LINE_THIN))
        hx = x1 - 34 if handle_right else x0 + 34
        f.append(F(name + "_handle", [ell(hx, (y_top + y_bot) / 2 + 10, 20, 18)], "brass", z + 0.04,
                   line={"width": 0.8, "heavy": 0.8}))
    return f


def front_window(name, x0, x1, y0, y1, z=4.0, frame="wood_dark", glass="glass_booth", mullions=1, transoms=1,
                 outside=None, curtain=None):
    fw = 20
    f = [F(name + "_glass", [rect(x0, y0, x1, y1)], glass, z, kind="flat")]
    if outside:
        f += outside
    refl = [quad([(x0 + (x1 - x0) * a, y0 + 6), (x0 + (x1 - x0) * b, y0 + 6), (x0 + (x1 - x0) * (b - 0.14), y1 - 6),
                  (x0 + (x1 - x0) * (a - 0.14), y1 - 6)]) for a, b in ((0.22, 0.3), (0.36, 0.4), (0.74, 0.84))]
    f.append(F(name + "_reflect", refl, "@reflect", z + 0.2, kind="flat", opacity=0.1, clip_to=name + "_glass"))
    frames = [rect(x0 - fw, y0 - fw, x1 + fw, y0), rect(x0 - fw, y1, x1 + fw, y1 + fw), rect(x0 - fw, y0, x0, y1),
              rect(x1, y0, x1 + fw, y1)]
    for m in range(1, mullions + 1):
        x = x0 + (x1 - x0) * m / (mullions + 1)
        frames.append(rect(x - 6, y0, x + 6, y1))
    for t in range(1, transoms + 1):
        y = y0 + (y1 - y0) * t / (transoms + 1)
        frames.append(rect(x0, y - 6, x1, y + 6))
    f.append(F(name + "_frame", frames, frame, z + 0.3, kind="flat", line=LINE_THIN))
    f.append(F(name + "_sill", [rect(x0 - 40, y1 + fw, x1 + 40, y1 + fw + 22)], frame, z + 0.31, kind="flat",
               line=LINE_THIN))
    if curtain:
        cw = (x1 - x0) * 0.22
        f.append(F(name + "_curtains", [quad([(x0 - 60, y0 - 70), (x0 + cw * 0.6, y0 - 70), (x0 + cw * 0.3, y1 + 60),
                                              (x0 - 70, y1 + 70)]),
                                        quad([(x1 - cw * 0.6, y0 - 70), (x1 + 60, y0 - 70), (x1 + 70, y1 + 70),
                                              (x1 - cw * 0.3, y1 + 60)])], curtain, z + 0.4, textured=True, line=LT))
        f.append(F(name + "_rod", [rect(x0 - 90, y0 - 84, x1 + 90, y0 - 70)], "brass", z + 0.41, kind="flat", line=LS))
    return f


def conduit_h(y, x0, x1, z=3.5, thick=12):
    return [F("conduit_" + str(int(y)), [rect(x0, y, x1, y + thick)], "metal_dark", z, kind="flat", line=LINE_THIN)]


def damp(pieces, z=3.45, opacity=0.3):
    return F("plaster_damp", pieces, "damp", z, kind="wash", blend="multiply", opacity=opacity, blur=24,
             rough={"amp": 0.6, "soft": 12, "cell": 40})


# ------------------------------------------------------------------ paper / close-ups
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


def sheet(x0, y0, x1, y1, mat="paper_ivory", name="sheet", tilt=0.0, holes=False, z=1.0, grime=None):
    pcs = [quad([(x0, y0), (x1, y0 + tilt), (x1, y1 + tilt), (x0, y1)])]
    f = [drop([quad([(x0 + 10, y0 + 12), (x1 + 10, y0 + tilt + 12), (x1 + 10, y1 + tilt + 12), (x0 + 10, y1 + 12)])]),
         F(name, pcs, mat, z, line=LCS, shade={"bump": 0.2, "highlight_amount": 0.2}, grime=grime or PAPER_GRIME)]
    if holes:
        hs = [ell(x0 + 22, y, 12, 12) for y in range(int(y0 + 30), int(y1 - 10), 44)] + \
             [ell(x1 - 22, y, 12, 12) for y in range(int(y0 + 30), int(y1 - 10), 44)]
        f.append(F(name + "_holes", hs, "@ink", z + 0.1, kind="flat", opacity=0.6))
    return f


def band(x0, y0, x1, y1, color="#56573f", z=2.0, name="band", mat="card_olive"):
    return F(name, [rect(x0, y0, x1, y1)], mat, z, kind="flat", color=color)


def frame_lines(x0, y0, x1, y1, t, mat="ink_line", z=2.5, name="frame_lines", opacity=0.8):
    return F(name, [rect(x0, y0, x1, y0 + t), rect(x0, y1 - t, x1, y1), rect(x0, y0, x0 + t, y1), rect(x1 - t, y0, x1, y1)],
             mat, z, kind="flat", opacity=opacity)
