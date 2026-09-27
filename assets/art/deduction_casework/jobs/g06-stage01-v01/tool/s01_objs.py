"""Stage 01 world objects.  Region A = quarter view (iso), B/C/D = front / side view.
All at the stage scale (320 px/m vertical, 250 px/m on the iso floor axes).
Contact shadows are separate (kind "shadow" -> _shadow.png)."""

from __future__ import annotations

import math

from g06kit import F, box, clock_pieces, clock_segments, ell, icon, lerp, limb, quad, recipe, rect, shadow
from g06kit.iso import Iso
from s01_board import cells as board_cells
from s01_common import PAL, PPM, asset

K = 250.0
LT = {"width": 1.2, "heavy": 1.4, "breaks": 0.25}
LS = {"width": 0.9, "heavy": 1.0, "breaks": 0.2}
ISO_SKEW_Y = [0.0, math.degrees(math.atan(0.5))]    # shapes lying on a right-wall plane (constant X)
ISO_SKEW_X = [0.0, -math.degrees(math.atan(0.5))]   # shapes on a left-wall plane (constant Y)


def iso_frame(xl, yl, zh, pad=40, k=K, kz=PPM):
    """Local iso frame for an object whose footprint is X 0..xl, Y 0..yl, height zh."""
    origin = (xl * k + pad, zh * kz + pad)
    W = int(math.ceil((xl + yl) * k + 2 * pad))
    H = int(math.ceil((xl + yl) * k / 2 + zh * kz + 2 * pad))
    return Iso(origin, k, kz), (W, H)


def iso_shadow(io, X0, Y0, X1, Y1, grow=0.06, opacity=0.4, blur=8):
    return shadow("shadow", [io.floor(X0 - grow, Y0 - grow, X1 + grow, Y1 + grow)], opacity, blur)


def wood3(mat="wood_ochre"):
    tones = {"wood_ochre": ("#6a5334", "#53412a", "#372a1b"), "wood_dark": ("#4a3a28", "#3a2d1f", "#261d14"),
             "metal_grey": ("#585c62", "#45484e", "#2e3035"), "metal_dark": ("#3f4247", "#303236", "#1f2023"),
             "plastic_beige": ("#8c8470", "#746c5a", "#58513f"), "plastic_black": ("#262427", "#1c1a1d", "#121113")}
    t, l, r = tones[mat]
    return (mat, t), (mat, l), (mat, r)


# ------------------------------------------------------------------ region A
@asset("obj_s01_lab_bench")
def lab_bench():
    xl, yl, zh = 0.9, 2.1, 0.9
    io, size = iso_frame(xl, yl, zh + 0.25)
    f = [iso_shadow(io, 0, 0, xl, yl)]
    top, left, right = wood3("wood_ochre")
    dt, dl, dr = wood3("wood_dark")
    # cabinet base (inset), slab top with overhang
    f += io.box("base", 0.05, 0.05, 0.0, xl - 0.05, yl - 0.05, zh - 0.05, dt, dl, dr, z=1.0, line=LT)
    f += io.box("slab", -0.02, -0.02, zh - 0.05, xl + 0.03, yl + 0.03, zh, top, left, right, z=2.0, line=LT,
                top_kw={"grime": {"stamps": ["cloud", "metaballs"], "size": 40, "soft": 4, "density": 0.18,
                                  "strength": 0.3, "color": "grime"}})
    # drawers on the left-front face (+X) and a knee opening
    drw = []
    for i in range(3):
        y0 = 0.15 + i * 0.42
        drw.append(io.wall_y(y0, y0 + 0.36, 0.5, 0.78, X=xl - 0.05))
    f.append(F("drawers", drw, "wood_ochre", 3.0, kind="flat", color="#4f3f2a", line=LS))
    f.append(F("knee_space", [io.wall_y(1.45, 1.95, 0.08, 0.78, X=xl - 0.05)], "@void_room", 3.01, kind="flat"))
    pulls = [ell(*io.p(xl - 0.05, 0.33 + i * 0.42, 0.64), 18, 10) for i in range(3)]
    f.append(F("pulls", pulls, "brass", 3.1, line=LS))
    # scratches on the slab (flat marks)
    sc = [box(*io.p(0.3, 0.6, zh), 60, 3, rot=26), box(*io.p(0.5, 1.3, zh), 80, 3, rot=24),
          box(*io.p(0.62, 0.9, zh), 40, 2, rot=-30)]
    f.append(F("scratches", sc, "@joint_dark", 3.2, kind="flat", opacity=0.5))
    # life objects on the bench: cold cup, pencil sharpener, worn books, lens cloth
    cx, cy = io.p(0.3, 0.35, zh)
    f.append(F("cup", [rect(cx - 18, cy - 44, cx + 18, cy), ell(cx, cy, 36, 16)], "paper_white", 4.0, line=LS))
    f.append(F("cup_top", [ell(cx, cy - 44, 36, 16)], "paper_white", 4.01, color="#cfc9b8", line=LS))
    f.append(F("cup_coffee", [ell(cx, cy - 43, 26, 10)], "leather_brown", 4.02, kind="flat", color="#2e2118"))
    f.append(F("cup_handle", [icon("ring", cx + 22, cy - 24, 16, 22)], "paper_white", 3.99, line=LS))
    f += io.box("book1", 0.25, 1.55, zh, 0.62, 1.85, zh + 0.05, ("leather_brown", "#5a3b2c"),
                ("leather_brown", "#4a3024"), ("leather_brown", "#352219"), z=4.1, line=LS)
    f += io.box("book2", 0.28, 1.58, zh + 0.05, 0.6, 1.82, zh + 0.09, ("cloth_red", "#5a2b33"),
                ("cloth_red", "#4a232a"), ("cloth_red", "#35191e"), z=4.2, line=LS)
    f += io.box("sharpener", 0.55, 0.62, zh, 0.66, 0.74, zh + 0.07, ("metal_grey", "#6d7178"),
                ("metal_grey", "#585c62"), ("metal_grey", "#3c3f45"), z=4.3, line=LS)
    f.append(F("lens_cloth", [io.floor(0.5, 1.05, 0.72, 1.3, Z=zh + 0.004)], "knit_green", 4.4, kind="flat",
               color="#5c6650", line=LS))
    piv = io.p(xl / 2, yl / 2)
    return recipe("obj_s01_lab_bench", f, size, piv, PAL, style="prop", seed=201,
                  pivot_meaning="footprint centre on the floor (iso)",
                  note="Central lab bench, region A (0.9 x 2.1 m, 0.9 m high): scratched ochre slab, dark cabinet "
                       "with three drawers on the camera-left face and a knee opening; cold cup, pencil sharpener, "
                       "two worn books and a lens cloth on top (13B-1 life objects).")


@asset("obj_s01_stim_desk")
def stim_desk():
    """Stimulus desk against the left wall with the CRT showing the frozen 12-cell task."""
    xl, yl, zh = 1.0, 0.7, 1.25
    io, size = iso_frame(xl, yl, zh)
    f = [iso_shadow(io, 0, 0, xl, yl)]
    dt, dl, dr = wood3("wood_dark")
    f += io.box("desk_top", 0, 0, 0.7, xl, yl, 0.75, dt, dl, dr, z=2.0, line=LT)
    f += io.box("leg_a", xl - 0.06, yl - 0.06, 0, xl, yl, 0.7, dt, dl, dr, z=1.0, line=LS)
    f += io.box("leg_b", xl - 0.06, 0.0, 0, xl, 0.06, 0.7, dt, dl, dr, z=0.9, line=LS)
    f += io.box("leg_c", 0.0, yl - 0.06, 0, 0.06, yl, 0.7, dt, dl, dr, z=0.95, line=LS)
    bt, bl, br = wood3("plastic_beige")
    # CRT: body, then the bezel + screen on the room-facing (+Y) face
    f += io.box("crt_back", 0.3, 0.05, 0.75, 0.7, 0.35, 1.1, bt, bl, br, z=3.0, line=LT)
    f += io.box("crt", 0.22, 0.25, 0.75, 0.78, 0.62, 1.22, bt, bl, br, z=3.1, line=LT)
    f.append(F("crt_screen", [io.wall_x(0.28, 0.72, 0.84, 1.16, Y=0.62)], "screen_dark", 3.2, kind="flat", line=LS))
    cells = []
    for r in range(3):
        for c in range(4):
            X0 = 0.32 + c * 0.1
            Z0 = 1.08 - r * 0.085
            cells.append(io.wall_x(X0, X0 + 0.07, Z0 - 0.055, Z0, Y=0.62))
    f.append(F("crt_cells", cells, "screen_glow", 3.3, kind="flat", opacity=0.9, emit=0.5))
    f.append(F("crt_button", [ell(*io.p(0.3, 0.62, 0.8), 10, 8)], "@lamp_glow", 3.4, kind="flat", emit=0.8))
    kt, kl, kr = wood3("plastic_beige")
    f += io.box("keyboard", 0.3, 0.64, 0.75, 0.75, 0.84, 0.78, kt, kl, kr, z=3.5, line=LS)
    keys = [io.floor(0.34 + i * 0.1, 0.67, 0.42 + i * 0.1, 0.8, Z=0.785) for i in range(4)]
    f.append(F("keys", keys, "@joint_dark", 3.6, kind="flat", opacity=0.35))
    f.append(F("cable", limb(io.p(0.8, 0.2, 0.8), io.p(0.95, 0.1, 0.1), 6, 6), "rubber", 0.8))
    piv = io.p(xl / 2, yl / 2)
    return recipe("obj_s01_stim_desk", f, size, piv, PAL, style="prop", seed=202,
                  pivot_meaning="footprint centre on the floor (iso); back edge (Y=0) touches the left wall",
                  note="A3 stimulus device: dark wood desk against the lab's left wall, beige CRT whose screen shows "
                       "the frozen 12-cell change-detection task (3x4 cells, glow in _emit.png), keyboard.")


@asset("obj_s01_printer_two_sheets")
def printer():
    xl, yl, zh = 0.55, 0.5, 0.95
    io, size = iso_frame(xl, yl, zh + 0.2)
    f = [iso_shadow(io, 0, 0, xl, yl)]
    mt, ml, mr = wood3("metal_dark")
    f += io.box("cart", 0.02, 0.02, 0.0, xl - 0.02, yl - 0.02, 0.6, mt, ml, mr, z=1.0, line=LT)
    f.append(F("cart_shelf", [io.wall_x(0.06, xl - 0.06, 0.1, 0.5, Y=yl - 0.02)], "@void_room", 1.1, kind="flat",
               opacity=0.7))
    bt, bl, br = wood3("plastic_beige")
    f += io.box("printer", 0.04, 0.05, 0.6, xl - 0.04, yl - 0.05, 0.78, bt, bl, br, z=2.0, line=LT)
    f.append(F("slot", [io.floor(0.1, 0.12, xl - 0.1, 0.18, Z=0.781)], "@ink", 2.1, kind="flat", opacity=0.7))
    # two continuous-feed sheets rising out of the slot and curling over the front
    s1 = quad([io.p(0.12, 0.14, 0.79), io.p(0.26, 0.14, 0.79), io.p(0.24, 0.1, 1.12), io.p(0.08, 0.08, 1.1)])
    s2 = quad([io.p(0.3, 0.15, 0.79), io.p(0.46, 0.15, 0.79), io.p(0.5, 0.2, 1.06), io.p(0.33, 0.2, 1.08)])
    f.append(F("sheet_calibration", [s1], "paper_ivory", 3.0, line=LS, tags=["sheet_a"]))
    f.append(F("sheet_behavior", [s2], "paper_ivory", 3.1, line=LS, tags=["sheet_b"]))
    holes = [ell(*io.p(0.1, 0.12, 0.84 + i * 0.05), 4, 4) for i in range(5)] + \
            [ell(*io.p(0.47, 0.17, 0.83 + i * 0.05), 4, 4) for i in range(5)]
    f.append(F("tractor_holes", holes, "@ink", 3.2, kind="flat", opacity=0.45))
    wave = [box(*io.p(0.18, 0.12, 0.9 + i * 0.045), 26, 2, rot=-20) for i in range(4)]
    f.append(F("sheet_marks", wave, "ink_line", 3.3, kind="flat", opacity=0.55))
    grid = [box(*io.p(0.4, 0.18, 0.88 + i * 0.05), 22, 2, rot=22) for i in range(3)]
    f.append(F("sheet_grid", grid, "ink_line", 3.35, kind="flat", opacity=0.45))
    piv = io.p(xl / 2, yl / 2)
    return recipe("obj_s01_printer_two_sheets", f, size, piv, PAL, style="prop", seed=203,
                  pivot_meaning="footprint centre on the floor (iso)",
                  note="A3-1/A3-2: beige dot-matrix printer on a metal cart; two continuous-feed printouts come out "
                       "of the slot: left = calibration (waveform marks), right = behaviour response (grid marks). "
                       "No legible text; the close-ups are cu_s01_calib_printout / cu_s01_behavior_printout.")


def _skewed_board(io, Y0, Y1, Z0, Z1, X=0.03, mira=True, color_mode="palette"):
    """4x4 task board drawn on the right-wall plane (constant X)."""
    f = []
    f.append(F("board_frame", [io.wall_y(Y0 - 0.05, Y1 + 0.05, Z0 - 0.05, Z1 + 0.05, X=X)], "wood_dark", 1.0,
               kind="flat", line=LT))
    f.append(F("board_panel", [io.wall_y(Y0, Y1, Z0, Z1, X=X)], "cork", 1.1, kind="flat", color="#6b6552", line=LS))
    cw = (Y1 - Y0 - 0.1) / 4
    chh = (Z1 - Z0 - 0.1) / 4
    raised, mags = {}, {}
    for r, c, shape, key, mc in board_cells():
        yc = Y0 + 0.05 + cw * (c + 0.5)
        zc = Z1 - 0.05 - chh * (r + 0.5)
        x, y = io.p(X, yc, zc)
        w = cw * 0.7 * io.k
        h = chh * 0.7 * io.kz
        raised.setdefault("r", []).append(icon(shape, x, y, w, h, skew=ISO_SKEW_Y, fit="box"))
        if mira:
            mags.setdefault(mc, []).append(icon(shape, x - 1, y - 2, w * 0.8, h * 0.8, skew=ISO_SKEW_Y, fit="box"))
    f.append(F("board_outlines", raised["r"], "cork", 1.2, kind="flat", color="#857d64", line=LS))
    for i, (col, pcs) in enumerate(sorted(mags.items())):
        f.append(F("magnets_" + col, pcs, col, 1.3 + i * 0.01, line=LS))
    return f


@asset("obj_s01_task_board")
def task_board():
    yl, zh = 1.2, 0.95
    pad = 30
    io = Iso((pad + 20, zh * PPM + pad + 20), K, PPM)
    W = int(yl * K + 2 * pad + 60)
    H = int(yl * K / 2 + zh * PPM + 2 * pad + 60)
    f = _skewed_board(io, 0.05, yl - 0.05, 0.03, zh - 0.03)
    piv = io.p(0.0, yl / 2, zh / 2)
    return recipe("obj_s01_task_board", f, (W, H), piv, PAL, style="prop", seed=204,
                  pivot_meaning="board centre on the right-wall plane (hang point); place on bg_s01_lab wall "
                                "(scene_s01_lab.json)",
                  note="VISUAL 2 task board on the lab's right wall (iso-skewed): 4x4 raised outlines with Mira's "
                       "magnets (shapes match every outline, colours swapped: s01_board.py). No text. The answer key "
                       "and the readable comparison are in cu_s01_task_board.")


@asset("obj_s01_wall_clock")
def wall_clock():
    pad = 24
    r = 0.16
    io = Iso((pad + 10, 0.5 * PPM + pad), K, PPM)
    W, H = int(2 * r * K + 2 * pad + 40), int(0.5 * PPM + r * K + 2 * pad + 40)
    x, y = io.p(0.0, r, 0.0)
    rw, rh = r * 2 * K, r * 2 * PPM * 0.82
    f = [F("rim", [icon("circle", x, y, rw * 1.08, rh * 1.08, skew=ISO_SKEW_Y)], "plastic_black", 1.0, line=LT),
         F("face", [icon("circle", x, y, rw * 0.92, rh * 0.92, skew=ISO_SKEW_Y)], "paper_ivory", 1.1, line=LS)]
    def face_pt(u, v):  # unit clock -> the face ellipse on the right-wall plane
        return (x + u * rw * 0.42, y + v * rh * 0.42 + u * rw * 0.42 * 0.5)

    for tag, (hh, mm) in (("t0213", (2, 13)), ("t0134", (1, 34))):
        pcs = []
        for p0, p1, w in clock_segments(hh, mm):
            pcs += limb(face_pt(*p0), face_pt(*p1), max(2.0, w * rw * 0.42), max(2.0, w * rw * 0.42), caps=False)
        f.append(F("marks_" + tag, pcs, "@ink", 1.2, kind="flat", tags=[tag], hidden=(tag != "t0213")))
    return recipe("obj_s01_wall_clock", f, (W, H), (x, y), PAL, style="prop", seed=205,
                  pivot_meaning="clock centre on the right-wall plane",
                  frames=[{"name": "t0213", "show": ["t0213"]},
                          {"name": "t0134", "show": ["t0134"], "hide": ["t0213"]}],
                  note="Wall clock on the lab's right wall. Frame t0213 = scene time 02:13; frame t0134 = 01:34 "
                       "(matches the CCTV frame; D2's 'CCTV 배경시계').")


@asset("obj_s01_bloody_gauze")
def bloody_gauze():
    io, size = iso_frame(0.45, 0.4, 0.08, pad=30)
    f = [iso_shadow(io, 0.05, 0.05, 0.4, 0.35, grow=0.0, opacity=0.3, blur=5)]
    pads = [icon("cloud", *io.p(0.15, 0.12, 0.02), 70, 40, rot=12), icon("cloud", *io.p(0.3, 0.26, 0.02), 64, 36, rot=-8),
            icon("metaballs", *io.p(0.22, 0.2, 0.04), 50, 30)]
    f.append(F("gauze", pads, "gauze", 1.0, line=LS))
    blood = [icon("metaballs", *io.p(0.16, 0.14, 0.03), 36, 20, rot=20), icon("droplet", *io.p(0.3, 0.25, 0.03), 22, 16, rot=70),
             icon("sponge", *io.p(0.24, 0.2, 0.05), 26, 16)]
    f.append(F("blood", blood, "blood", 1.1, kind="flat", clip_to="gauze", opacity=0.9))
    f.append(F("drops", [ell(*io.p(0.38, 0.1), 8, 5), ell(*io.p(0.42, 0.16), 6, 4)], "blood_dry", 1.2, kind="flat"))
    return recipe("obj_s01_bloody_gauze", f, size, io.p(0.22, 0.2), PAL, style="prop", seed=206,
                  note="A4 / 0-click: Grell's blood-soaked gauze pads, low on the floor below Mira's eye level.")


@asset("obj_s01_first_aid_open")
def first_aid():
    xl, yl, zh = 0.35, 0.5, 0.45
    io, size = iso_frame(xl, yl, zh)
    f = [iso_shadow(io, 0, 0, xl, yl)]
    mt, ml, mr = (("metal_grey", "#7c8088"), ("metal_grey", "#62666d"), ("metal_grey", "#44474d"))
    f += io.box("box", 0, 0, 0, xl, yl, 0.14, mt, ml, mr, z=1.0, line=LT)
    f.append(F("inside", [io.floor(0.02, 0.02, xl - 0.02, yl - 0.02, Z=0.14)], "@void_room", 1.1, kind="flat"))
    # lid open against the back
    f.append(F("lid", [io.wall_y(0.0, yl, 0.14, 0.44, X=0.0)], "metal_grey", 0.5, kind="flat", color="#6a6e75", line=LT))
    f.append(F("cross", [icon("plus", *io.p(0.0, yl / 2, 0.3), 70, 60, skew=ISO_SKEW_Y)], "ink_red", 0.6, kind="flat",
               opacity=0.9))
    rolls = [ell(*io.p(0.12, 0.12, 0.15), 34, 22), ell(*io.p(0.12, 0.28, 0.15), 34, 22), ell(*io.p(0.25, 0.4, 0.15), 30, 20)]
    f.append(F("rolls", rolls, "bandage", 1.2, line=LS))
    f.append(F("scissors", [icon("scissors", *io.p(0.26, 0.18, 0.16), 44, 30, rot=30)], "steel", 1.3, line=LS))
    f.append(F("smears", [icon("metaballs", *io.p(0.0, 0.1, 0.3), 30, 20), icon("droplet", *io.p(0.3, 0.02, 0.1), 14, 20)],
               "blood", 1.4, kind="flat", opacity=0.85))
    return recipe("obj_s01_first_aid_open", f, size, io.p(xl / 2, yl / 2), PAL, style="prop", seed=207,
                  note="A4: open metal first-aid box Grell is sorting: bandage rolls, scissors, blood smears on the "
                       "lid and rim.")


@asset("obj_s01_disinfect_floor")
def disinfect_floor():
    io, size = iso_frame(0.35, 0.35, 0.22, pad=30)
    f = [iso_shadow(io, 0.05, 0.05, 0.3, 0.3, grow=0.0, opacity=0.35, blur=5)]
    x, y = io.p(0.12, 0.12)
    f.append(F("bottle", [rect(x - 16, y - 60, x + 16, y), ell(x, y, 32, 14), rect(x - 8, y - 78, x + 8, y - 58)],
               "glass", 1.0, color="#5a3a22", line=LS))
    f.append(F("bottle_cap", [rect(x - 9, y - 90, x + 9, y - 76)], "plastic_black", 1.1, line=LS))
    f.append(F("label", [rect(x - 14, y - 44, x + 14, y - 20)], "paper_ivory", 1.2, kind="flat", line=LS))
    cot = [icon("cloud", *io.p(0.26, 0.2, 0.02), 34, 22), icon("cloud", *io.p(0.2, 0.3, 0.02), 28, 18)]
    f.append(F("cotton", cot, "gauze", 1.3, line=LS))
    f.append(F("iodine", [icon("metaballs", *io.p(0.25, 0.24, 0.03), 22, 12)], "@stain_disinfect", 1.4, kind="flat",
               clip_to="cotton"))
    return recipe("obj_s01_disinfect_floor", f, size, io.p(0.18, 0.18), PAL, style="prop", seed=208,
                  note="0-click: antiseptic bottle and stained cotton on the floor where Mira's right hand reaches "
                       "(13E).")


@asset("obj_s01_lens_case_broken")
def lens_case():
    W, H = 96, 72
    cx, cy = 48, 38
    f = [F("case", [ell(cx - 14, cy, 30, 30), ell(cx + 14, cy, 30, 30), rect(cx - 12, cy - 6, cx + 12, cy + 6)],
           "glass_clear", 1.0, line=LS, opacity=0.9),
         F("lens_l", [ell(cx - 14, cy, 22, 22)], "glass_clear", 1.1, kind="flat", color="#b7c1c4", opacity=0.6),
         F("lens_r", [ell(cx + 14, cy, 22, 22)], "glass_clear", 1.1, kind="flat", color="#b7c1c4", opacity=0.6),
         F("crack", [icon("lightning_bolt", cx + 14, cy, 6, 22, rot=20), icon("lightning_bolt", cx + 16, cy - 2, 4, 14,
                                                                           rot=-50)], "@ink", 1.2, kind="flat",
           opacity=0.8),
         F("hinge", [rect(cx - 3, cy - 16, cx + 3, cy + 16)], "steel", 1.3, kind="flat", line=LS)]
    return recipe("obj_s01_lens_case_broken", f, (W, H), (cx, cy), PAL, style="prop", seed=209,
                  pivot_meaning="case centre (goes in Mira's left hand, chr_s01_mira_seated_injured)",
                  note="A2: small transparent twin lens case, right lens cracked. The engraving is in the close-up "
                       "(cu_s01_lens_case) as a blank plate.")



# ------------------------------------------------------------------ front-view helpers
def fblock(name, x0, x1, y_top, depth, height, mat, z=1.0, line=None, color=None, **kw):
    """Face-on furniture block: ``depth`` px of visible top face, ``height`` px of front face."""
    f = F(name, [rect(x0, y_top, x1, y_top + depth)], mat, z, kind="block", extrude=height, line=line or LT, **kw)
    if color:
        f["color"] = color
    return f


def legs4(x0, x1, y0, y1, w, mat="wood_dark", z=0.5, inset=10):
    return F("legs", [rect(x0 + inset, y0, x0 + inset + w, y1), rect(x1 - inset - w, y0, x1 - inset, y1)], mat, z,
             line=LS)


def floor_shadow(cx, cy, w, h, opacity=0.35, blur=8):
    return shadow("shadow", [ell(cx, cy, w, h)], opacity, blur)


# ------------------------------------------------------------------ region B (side view)
@asset("obj_s01_booth_desk")
def booth_desk():
    W, H = 700, 300
    x0, x1, yt = 40, 660, 40
    f = [floor_shadow(350, 282, 660, 34),
         fblock("top", x0, x1, yt, 22, 20, "wood_dark", z=2.0),
         legs4(x0, x1, yt + 40, 280, 26, z=1.0),
         F("modesty", [rect(x0 + 40, yt + 42, x1 - 40, yt + 150)], "wood_dark", 1.2, kind="flat", color="#3a2d1f", line=LS),
         F("drawer", [rect(x1 - 200, yt + 44, x1 - 44, yt + 96)], "wood_dark", 1.3, kind="flat", color="#4a3a28", line=LS),
         F("drawer_pull", [rect(x1 - 140, yt + 66, x1 - 104, yt + 74)], "brass", 1.4, kind="flat")]
    return recipe("obj_s01_booth_desk", f, (W, H), (350, 280), PAL, style="prop", seed=210,
                  pivot_meaning="floor point between the front legs", note="Region B: small dark wood desk in front "
                  "of the observation window (the booth objects stand on its top, y=40..62 of this canvas).")


@asset("obj_s01_eye_card")
def eye_card():
    W, H = 110, 100
    f = [F("stand", [quad([(30, 88), (80, 88), (70, 94), (40, 94)])], "metal_dark", 0.5, line=LS),
         F("card", [quad([(24, 12), (86, 16), (82, 86), (28, 84)])], "paper_ivory", 1.0, line=LS),
         F("band", [quad([(24, 12), (86, 16), (85, 26), (25, 22)])], "card_olive", 1.1, kind="flat", color="#56573f"),
         F("pupil", [ell(42, 50, 22, 22)], "paper_white", 1.2, kind="flat", line=LS),
         F("pupil_dot", [ell(42, 50, 9, 9)], "@ink", 1.3, kind="flat"),
         F("retina", [ell(68, 52, 22, 22)], "cloth_red", 1.2, kind="flat", color="#7a5048", line=LS),
         F("vessels", [icon("sprout", 68, 52, 14, 14), icon("lightning_bolt", 66, 56, 4, 12, rot=40)], "blood_dry", 1.3,
           kind="flat", opacity=0.8),
         F("lines", [rect(32, 70, 78, 72), rect(32, 76, 70, 78)], "ink_line", 1.4, kind="flat", opacity=0.5)]
    return recipe("obj_s01_eye_card", f, (W, H), (55, 92), PAL, style="prop", seed=211,
                  note="B1 eye exam card in a desk stand: olive university band, pupil and retina diagrams, blank "
                       "lines (readable content in cu_s01_eye_card). Drawn 1.5x real size for legibility.")


@asset("obj_s01_recorder")
def recorder():
    W, H = 190, 110
    f = [floor_shadow(95, 96, 170, 16, 0.3, 4),
         fblock("body", 14, 176, 24, 14, 62, "plastic_black", z=1.0),
         F("grille", [icon("grid_fine", 52, 70, 64, 40)], "@ink", 1.2, kind="flat", opacity=0.6),
         F("deck", [rect(98, 46, 166, 86)], "screen_dark", 1.2, kind="flat", line=LS),
         F("reels", [ell(116, 66, 16, 16), ell(148, 66, 16, 16)], "steel", 1.3, kind="flat", line=LS),
         F("keys", [rect(20 + i * 22, 18, 38 + i * 22, 28) for i in range(4)], "steel", 1.4, line=LS),
         F("rec_key", [rect(108, 18, 126, 28)], "ink_red", 1.41, line=LS),
         F("handle", [icon("ring", 95, 14, 70, 22, crop=[0, 0, 16, 8])], "plastic_black", 0.9, line=LS)]
    return recipe("obj_s01_recorder", f, (W, H), (95, 96), PAL, style="prop", seed=212,
                  note="B2 portable cassette recorder (experiment tape): speaker grille, cassette window with two "
                       "reels, piano keys, red record key.")


@asset("obj_s01_log_sheet")
def log_sheet():
    W, H = 110, 130
    f = [F("board", [quad([(20, 14), (92, 18), (88, 122), (22, 118)])], "wood_dark", 1.0, color="#6a5334", line=LS),
         F("sheet", [quad([(26, 26), (86, 29), (83, 116), (28, 112)])], "paper_ivory", 1.1, line=LS),
         F("clip", [rect(44, 8, 70, 24)], "steel", 1.2, line=LS),
         F("rows", [rect(32, 40 + i * 12, 78 - (i % 3) * 8, 42 + i * 12) for i in range(6)], "ink_line", 1.3,
           kind="flat", opacity=0.5),
         F("note_line", [rect(32, 106, 72, 109)], "pencil", 1.35, kind="flat", opacity=0.7)]
    return recipe("obj_s01_log_sheet", f, (W, H), (55, 120), PAL, style="prop", seed=213,
                  note="B3 Mira's experiment log on a clipboard (times + a pencil line at the bottom; readable "
                       "version cu_s01_log_sheet).")


@asset("obj_s01_pager")
def pager():
    W, H = 80, 60
    f = [floor_shadow(40, 50, 60, 10, 0.3, 3),
         fblock("body", 14, 66, 16, 8, 26, "plastic_black", z=1.0),
         F("display", [rect(20, 26, 50, 38)], "screen_glow", 1.2, kind="flat", line=LS, emit=0.4),
         F("button", [ell(58, 32, 8, 8)], "steel", 1.3, kind="flat"),
         F("clip", [rect(30, 10, 50, 16)], "plastic_black", 0.9, line=LS)]
    return recipe("obj_s01_pager", f, (W, H), (40, 50), PAL, style="prop", seed=214,
                  note="B4 Grell's pager, 2x real size for legibility; lit display in _emit.png (messages are in "
                       "cu_s01_pager).")


@asset("obj_s01_eeg_printout")
def eeg_printout():
    W, H = 200, 170
    f = [F("stack", [rect(20, 40, 150, 70)], "paper_ivory", 1.0, line=LS),
         F("fold", [quad([(150, 40), (176, 44), (170, 160), (148, 150)]), quad([(150, 150), (170, 160), (150, 166), (132, 158)])],
           "paper_ivory", 1.1, line=LS),
         F("stack_edges", [rect(20, 48 + i * 6, 150, 49 + i * 6) for i in range(4)], "ink_line", 1.2, kind="flat",
           opacity=0.35),
         F("traces", [icon("signal_wave", 162, 70 + i * 22, 20, 12, rot=90) for i in range(4)], "ink_blue", 1.3,
           kind="flat", opacity=0.75, clip_to="fold")]
    return recipe("obj_s01_eeg_printout", f, (W, H), (85, 70), PAL, style="prop", seed=215,
                  pivot_meaning="bottom centre of the stack on the desk top",
                  note="Booth life object: fan-folded EEG printout stack with blue traces, one fold hanging over the "
                       "desk edge.")


@asset("obj_s01_cctv_monitor")
def cctv_monitor():
    W, H = 200, 190
    f = [floor_shadow(100, 170, 170, 18, 0.3, 4),
         fblock("case", 26, 174, 24, 18, 132, "plastic_beige", z=1.0),
         F("bezel", [rect(34, 48, 166, 150)], "plastic_black", 1.1, kind="flat", line=LS),
         F("screen", [rect(44, 56, 156, 140)], "screen_dark", 1.2, kind="flat", line=LS),
         F("screen_glow", [rect(48, 60, 152, 136)], "screen_glow", 1.3, kind="flat", opacity=0.25, emit=0.35),
         F("knobs", [ell(60, 160, 10, 10), ell(80, 160, 10, 10)], "plastic_black", 1.4, line=LS),
         F("led", [ell(150, 160, 6, 6)], "@lamp_glow", 1.45, kind="flat", emit=0.9)]
    return recipe("obj_s01_cctv_monitor", f, (W, H), (100, 170), PAL, style="prop", seed=216,
                  note="Booth CCTV monitor. Screen rectangle for the recorded frame = x 44..156, y 56..140 of this "
                       "canvas (4:3); the game draws cu_s01_cctv_view + chr_s01_mira_cctv_0134 into it (VISUAL 1). "
                       "Faint screen glow in _emit.png.")


# ------------------------------------------------------------------ region C (front view)
@asset("obj_s01_booth_chair")
def booth_chair():
    W, H = 260, 360
    cx = 130
    f = [floor_shadow(cx, 342, 200, 26),
         F("base", [icon("cross", cx, 330, 180, 30)], "metal_dark", 0.8, line=LS),
         F("column", [rect(cx - 10, 230, cx + 10, 322)], "steel", 0.9, line=LS),
         fblock("seat", cx - 90, cx + 90, 200, 30, 24, "leather_black", z=1.0),
         F("back", [rect(cx - 80, 40, cx + 80, 190)], "leather_black", 1.1, line=LT, shade={"highlight_amount": 0.4}),
         F("back_post", [rect(cx - 8, 186, cx + 8, 204)], "steel", 1.05),
         F("seams", [rect(cx - 70, 110, cx + 70, 114)], "@joint_dark", 1.2, kind="flat", opacity=0.5),
         F("wear", [icon("cloud", cx + 30, 80, 60, 40)], "@worn", 1.3, kind="flat", opacity=0.25, clip_to="back")]
    return recipe("obj_s01_booth_chair", f, (W, H), (cx, 342), PAL, style="prop", seed=217,
                  note="Region B life object: worn black office chair at the observation desk (back to the camera).")


@asset("obj_s01_eeg_rack")
def eeg_rack():
    W, H = 360, 600
    f = [floor_shadow(180, 580, 300, 30),
         fblock("rack", 50, 310, 50, 30, 490, "metal_dark", z=1.0),
         F("unit1", [rect(66, 100, 294, 190)], "plastic_beige", 1.1, kind="flat", line=LS),
         F("meters", [ell(110, 145, 50, 50), ell(170, 145, 50, 50)], "paper_ivory", 1.2, kind="flat", line=LS),
         F("needles", [box(112, 138, 3, 22, rot=30), box(168, 138, 3, 22, rot=-20)], "@ink", 1.3, kind="flat"),
         F("knobs", [ell(230 + (i % 3) * 22, 125 + (i // 3) * 36, 16, 16) for i in range(6)], "plastic_black", 1.3,
           line=LS),
         F("unit2", [rect(66, 210, 294, 300)], "plastic_beige", 1.1, kind="flat", color="#7a735f", line=LS),
         F("sockets", [ell(90 + i * 24, 256, 12, 12) for i in range(9)], "@ink", 1.2, kind="flat", opacity=0.7),
         F("leads", [icon("ring", 120, 372, 90, 90, crop=[0, 8, 16, 16]), icon("ring", 160, 390, 70, 110, crop=[0, 8, 16, 16])],
           "ink_red", 1.4, kind="flat", opacity=0.8),
         F("cap_hook", [rect(66, 320, 294, 330)], "steel", 1.3, kind="flat"),
         F("eeg_cap", [ell(210, 380, 90, 70)], "rubber", 1.5, line=LS),
         F("cap_holes", [ell(190 + (i % 3) * 20, 366 + (i // 3) * 18, 8, 8) for i in range(6)], "steel", 1.6, kind="flat"),
         F("lamp", [ell(270, 170, 10, 10)], "@lamp_glow", 1.7, kind="flat", emit=0.9)]
    return recipe("obj_s01_eeg_rack", f, (W, H), (180, 580), PAL, style="prop", seed=218,
                  note="Region B work object: EEG equipment rack (amplifier with meters and knobs, electrode "
                       "sockets, red leads, rubber electrode cap). Pilot lamp in _emit.png.")


# ------------------------------------------------------------------ region C (front view)
LOCKER_SLOT = (1200.0, 1406.67, 150, 1000)   # x0, x1, top, bottom of locker index 3 in bg_s01_locker


@asset("obj_s01_locker_mira")
def locker_mira():
    x0, x1, top, bot = LOCKER_SLOT
    w = x1 - x0
    pad = 40
    W, H = int(w + 2 * pad + 150), int(bot - top + 2 * pad)
    ox = 150 + pad - x0        # canvas x = bg x + ox (room for the door swung open to the left)
    oy = pad - top
    X = lambda v: v + ox  # noqa: E731
    Y = lambda v: v + oy  # noqa: E731
    d0, d1, dt, db = X(x0 + 8), X(x1 - 8), Y(top + 50), Y(bot - 44)
    f = []
    # closed door (same design as the bank, plus a blank name plate that reads 'M. VENN' in the close-up)
    f.append(F("door", [rect(d0, dt, d1, db)], "metal_grey", 1.0, kind="flat", color="#505b54", textured=True, line=LT,
               tags=["closed"]))
    f.append(F("vents", [rect(d0 + w * 0.3 - 8, dt + 40 + v * 26, d0 + w * 0.7 - 8, dt + 50 + v * 26) for v in range(4)],
               "@ink", 1.1, kind="flat", opacity=0.55, tags=["closed"]))
    f.append(F("plate", [rect(d0 + w * 0.34 - 8, dt + 170, d0 + w * 0.66 - 8, dt + 208)], "paper_ivory", 1.2,
               kind="flat", line=LS, tags=["closed"]))
    f.append(F("plate_letters", [rect(d0 + w * 0.38 - 8, dt + 184, d0 + w * 0.62 - 8, dt + 192)], "ink_line", 1.25,
               kind="flat", opacity=0.45, tags=["closed"]))
    f.append(F("handle", [rect(d1 - 38, dt + 370, d1 - 22, dt + 470)], "steel", 1.3, line=LS, tags=["closed"]))
    # open state: dark interior, shelf, rail; door leaf swung out to the left (seen edge-on)
    f.append(F("inside", [rect(d0, dt, d1, db)], "@void_room", 1.0, kind="flat", tags=["open"], hidden=True))
    f.append(F("inside_back", [rect(d0 + 12, dt + 12, d1 - 12, db - 12)], "metal_dark", 1.05, kind="flat",
               color="#2c302d", tags=["open"], hidden=True))
    f.append(F("shelf", [rect(d0 + 4, dt + 110, d1 - 4, dt + 126)], "metal_grey", 1.2, kind="flat", line=LS,
               tags=["open"], hidden=True))
    f.append(F("rail", [rect(d0 + 14, dt + 150, d1 - 14, dt + 158)], "steel", 1.25, kind="flat", tags=["open"],
               hidden=True))
    leaf = quad([(d0 - 4, dt - 6), (d0 - 120, dt + 24), (d0 - 120, db - 24), (d0 - 4, db + 6)])
    f.append(F("door_open", [leaf], "metal_grey", 2.0, kind="flat", color="#46504a", textured=True, line=LT,
               tags=["open"], hidden=True))
    f.append(F("door_open_plate", [quad([(d0 - 40, dt + 172), (d0 - 84, dt + 184), (d0 - 84, dt + 214), (d0 - 40, dt + 206)])],
               "paper_ivory", 2.1, kind="flat", tags=["open"], hidden=True))
    piv = (X((x0 + x1) / 2), Y(bot))
    return recipe("obj_s01_locker_mira", f, (W, H), piv, PAL, style="prop", seed=220,
                  pivot_meaning="bottom centre of locker index 3 = bg_s01_locker (1303.3, 1000)",
                  frames=[{"name": "closed"}, {"name": "open", "show": ["open"], "hide": ["closed"]}],
                  note="C1 Mira's locker door over slot 3 of the locker bank. Frames: closed (blank name plate; "
                       "'M. VENN' is in the close-up) / open (dark interior, shelf, coat rail, door swung left). "
                       "obj_s01_labcoat_hung and obj_s01_notebook_shelf go inside the open frame.")


@asset("obj_s01_labcoat_hung")
def labcoat_hung():
    W, H = 220, 360
    cx = 110
    f = [F("hanger", [icon("clothes_hanger", cx, 26, 120, 50)], "steel", 1.0, line=LS),
         F("coat", [quad([(cx - 52, 44), (cx + 52, 44), (cx + 78, 330), (cx - 78, 330)])], "labcoat", 2.0, line=LT),
         F("sleeves", [quad([(cx - 52, 46), (cx - 70, 60), (cx - 86, 250), (cx - 64, 252)]),
                       quad([(cx + 52, 46), (cx + 70, 60), (cx + 86, 250), (cx + 64, 252)])], "labcoat", 2.1, line=LT),
         F("opening", [quad([(cx - 6, 50), (cx + 6, 50), (cx + 10, 330), (cx - 10, 330)])], "@ink", 2.2, kind="flat",
           opacity=0.35),
         F("collar_in", [quad([(cx - 30, 44), (cx + 30, 44), (cx + 6, 96), (cx - 6, 96)])], "labcoat", 2.3,
           color="#8c8779", line=LS),
         F("label", [rect(cx - 16, 56, cx + 16, 70)], "paper_white", 2.4, kind="flat", line=LS),
         F("label_stitch", [rect(cx - 12, 61, cx + 12, 64)], "ink_blue", 2.45, kind="flat", opacity=0.6),
         F("pocket", [rect(cx - 64, 120, cx - 26, 160)], "labcoat", 2.5, kind="flat", color="#9c9687", line=LS),
         F("graphite", [icon("metaballs", cx - 74, 244, 20, 12), icon("sponge", cx + 76, 240, 18, 12)], "pencil", 2.6,
           kind="flat", opacity=0.55, clip_to="sleeves"),
         F("oil", [icon("droplet", cx + 70, 230, 10, 14)], "@soot", 2.61, kind="flat", opacity=0.6, clip_to="sleeves")]
    return recipe("obj_s01_labcoat_hung", f, (W, H), (cx, 20), PAL, style="prop", seed=221,
                  pivot_meaning="hanger hook (hangs on the locker rail)",
                  note="C1-1 spare white lab coat on a hanger inside Mira's locker: inner collar label (embroidered "
                       "'MIRA' readable in cu_s01_labcoat_label), graphite and machine-oil marks on the cuffs (13A-1).")


@asset("obj_s01_notebook_shelf")
def notebook_shelf():
    W, H = 150, 70
    f = [floor_shadow(75, 56, 120, 12, 0.3, 3),
         fblock("notebook", 20, 130, 26, 18, 14, "leather_black", z=1.0),
         F("pages", [rect(24, 44, 126, 50)], "paper_ivory", 1.1, kind="flat"),
         F("band", [rect(96, 24, 104, 58)], "cloth_red", 1.2, kind="flat")]
    return recipe("obj_s01_notebook_shelf", f, (W, H), (75, 58), PAL, style="prop", seed=222,
                  note="C1-2 Mira's personal research notebook lying on the locker shelf (black cover, red elastic "
                       "band); pages in cu_s01_notebook.")


@asset("obj_s01_prep_table")
def prep_table():
    W, H = 700, 340
    x0, x1 = 50, 650
    f = [floor_shadow(350, 318, 620, 40),
         fblock("top", x0, x1, 40, 80, 26, "wood_ochre", z=2.0),
         legs4(x0, x1, 140, 318, 30, mat="wood_dark", z=1.0),
         F("stretcher", [rect(x0 + 40, 250, x1 - 40, 266)], "wood_dark", 1.1, line=LS)]
    return recipe("obj_s01_prep_table", f, (W, H), (350, 318), PAL, style="prop", seed=223,
                  pivot_meaning="floor point between the front legs",
                  note="Region C prep table (1.9 m, 0.75 m high). Its top face is y=40..120 of this canvas; the "
                       "elephant model, name cards, lens storage, repair card and sketchbook stand on it.")


@asset("obj_s01_elephant_model")
def elephant():
    W, H = 170, 130
    f = [floor_shadow(80, 112, 130, 14, 0.3, 4),
         F("legs", [rect(40, 76, 56, 112), rect(64, 78, 78, 112), rect(94, 78, 108, 112), rect(114, 76, 130, 112)],
           "ash", 0.8, color="#6c686a", line=LS),
         F("body", [ell(86, 64, 110, 64)], "ash", 1.0, color="#77736f", line=LT),
         F("head", [ell(136, 50, 46, 44)], "ash", 1.1, color="#7d7975", line=LT),
         F("ear", [icon("leaf", 124, 52, 30, 40, rot=-20)], "ash", 1.2, color="#6a6663", line=LS),
         F("trunk", limb((150, 60), (158, 96), 14, 8) + limb((158, 96), (150, 110), 8, 6), "ash", 1.15, color="#7d7975"),
         F("tusk", [icon("moon", 150, 76, 10, 14, rot=40)], "paper_white", 1.3, kind="flat"),
         F("eye", [ell(140, 44, 4, 4)], "@ink", 1.4, kind="flat"),
         F("tail", limb((32, 58), (24, 80), 4, 3), "ash", 0.9, color="#6c686a"),
         F("texture_dots", [icon("sponge", 80, 60, 60, 30)], "@joint_dark", 1.05, kind="flat", opacity=0.15,
           clip_to="body")]
    return recipe("obj_s01_elephant_model", f, (W, H), (80, 112), PAL, style="prop", seed=224,
                  note="Region C life/work object: textured plastic elephant model used in the imagery tests "
                       "('코끼리를 생각하지 마세요', B2). Rough surface = something to touch.")


@asset("obj_s01_name_cards")
def name_cards():
    W, H = 170, 110
    cards = [(40, 60, -14), (68, 56, -5), (96, 56, 5), (124, 60, 14)]
    f = [floor_shadow(84, 96, 140, 12, 0.25, 3)]
    for i, (x, y, r) in enumerate(cards):
        f.append(F(f"card{i}", [box(x, y, 40, 56, rot=r)], "paper_ivory", 1.0 + i * 0.1, line=LS))
    f.append(F("pictures", [icon("eye", 40, 56, 20, 14, rot=-14), icon("photo_camera", 68, 52, 20, 16, rot=-5),
                            box(96, 52, 18, 18, rot=5), icon("binoculars", 124, 56, 20, 16, rot=14)], "ink_line", 1.5,
               kind="flat", opacity=0.8))
    f.append(F("red_patch", [box(96, 52, 16, 16, rot=5)], "ink_red", 1.6, kind="flat"))
    return recipe("obj_s01_name_cards", f, (W, H), (84, 96), PAL, style="prop", seed=225,
                  note="C3 four picture naming cards fanned on the table: eye, photo (camera), red swatch, and the "
                       "'looking' action card (binoculars). Marks in cu_s01_name_cards.")


@asset("obj_s01_lens_storage")
def lens_storage():
    W, H = 150, 110
    f = [floor_shadow(75, 94, 120, 14, 0.3, 3),
         fblock("case", 22, 128, 48, 26, 22, "plastic_black", z=1.0),
         F("lid", [quad([(22, 48), (128, 48), (124, 14), (26, 14)])], "plastic_black", 0.9, color="#343236", line=LS),
         F("slots", [ell(34 + i * 16, 60, 11, 8) for i in range(6)], "glass_clear", 1.2, kind="flat", line=LS),
         F("empty", [ell(34 + 3 * 16, 60, 11, 8)], "@ink", 1.3, kind="flat")]
    return recipe("obj_s01_lens_storage", f, (W, H), (75, 96), PAL, style="prop", seed=226,
                  note="Region C lens storage box: six marker-lens slots, one empty.")


@asset("obj_s01_repair_card")
def repair_card():
    W, H = 110, 100
    f = [F("card", [quad([(18, 20), (90, 14), (94, 80), (22, 86)])], "paper_ivory", 1.0, line=LS),
         F("diagram", [rect(28, 34, 44, 46), rect(50, 34, 66, 46), rect(72, 32, 86, 44)], "paper_ivory", 1.1, kind="flat",
           color="#c2b89c", line=LS),
         F("arrows", [rect(44, 39, 50, 41), rect(66, 38, 72, 40)], "ink_line", 1.2, kind="flat", opacity=0.6),
         F("text_rows", [rect(28, 56, 84, 58), rect(28, 64, 76, 66)], "pencil", 1.25, kind="flat", opacity=0.55),
         F("oil_thumb", [icon("fingerprint", 76, 66, 18, 18, rot=10)], "@soot", 1.3, kind="flat", opacity=0.55)]
    return recipe("obj_s01_repair_card", f, (W, H), (56, 84), PAL, style="prop", seed=227,
                  note="C2 equipment repair card in Mira's hand (INPUT -> PART -> OUTPUT boxes) with an oily thumb "
                       "smudge beside the 'isolate the input' line (hinge C). Detail: cu_s01_repair_card.")


@asset("obj_s01_sketchbook")
def sketchbook():
    W, H = 220, 110
    f = [floor_shadow(110, 90, 190, 14, 0.3, 3),
         F("cover", [quad([(14, 40), (206, 40), (214, 88), (6, 88)])], "leather_black", 0.9, line=LS),
         F("page_l", [quad([(22, 36), (108, 40), (108, 84), (14, 84)])], "paper_ivory", 1.0, line=LS),
         F("page_r", [quad([(112, 40), (198, 36), (206, 84), (112, 84)])], "paper_ivory", 1.1, line=LS),
         F("sketch_l", [quad([(30, 72), (60, 50), (98, 52), (98, 76)]), rect(40, 60, 70, 62)], "pencil", 1.2,
           kind="flat", opacity=0.35),
         F("sketch_r", [ell(140, 58, 26, 14), ell(176, 66, 20, 12), rect(132, 72, 150, 74)], "pencil", 1.2, kind="flat",
           opacity=0.3),
         F("spiral", [ell(110, 40 + i * 8, 8, 5) for i in range(6)], "steel", 1.3, kind="flat")]
    return recipe("obj_s01_sketchbook", f, (W, H), (110, 90), PAL, style="prop", seed=228,
                  note="VISUAL 3 hotspot: open spiral sketchbook on the prep table (left: last month's perspective "
                       "sketch, right: the incident-day outline sheet). Full pages: cu_s01_sketch_prev / "
                       "cu_s01_sketch_day.")


@asset("obj_s01_roster_sheet")
def roster_sheet():
    W, H = 150, 190
    f = [F("sheet", [quad([(22, 20), (130, 16), (128, 176), (24, 178)])], "paper_ivory", 1.0, line=LS),
         F("head", [rect(30, 28, 122, 40)], "card_olive", 1.1, kind="flat", color="#5c5d44"),
         F("rows", [rect(32, 54 + i * 16, 118 - (i % 2) * 20, 57 + i * 16) for i in range(7)], "ink_line", 1.2, kind="flat",
           opacity=0.5),
         F("pins", [ell(40, 22, 10, 10), ell(112, 18, 10, 10)], "ink_red", 1.3, line=LS)]
    return recipe("obj_s01_roster_sheet", f, (W, H), (76, 18), PAL, style="prop", seed=229,
                  pivot_meaning="pin line on the wall (hang point)",
                  note="C4 department roster pinned to the prep-room wall (names readable in cu_s01_roster).")


# ------------------------------------------------------------------ region D
@asset("obj_s01_sink")
def sink():
    W, H = 330, 420
    cx = 165
    f = [floor_shadow(cx, 402, 150, 18, 0.3, 6),
         F("pipe", [rect(cx - 12, 170, cx + 12, 400), rect(cx - 30, 390, cx + 30, 404)], "steel", 0.8, line=LS),
         F("trap", [icon("ring", cx, 206, 50, 40, crop=[0, 8, 16, 16])], "steel", 0.85, line=LS),
         fblock("basin", 40, 290, 110, 40, 60, "paper_white", z=1.0, color="#aaa69a"),
         F("bowl", [ell(cx, 128, 190, 30)], "@void_room", 1.1, kind="flat", opacity=0.55),
         F("tap_body", [rect(cx - 10, 62, cx + 10, 112), rect(cx - 10, 62, cx + 50, 76)], "steel", 1.2, line=LS),
         F("tap_heads", [ell(cx - 40, 96, 22, 14), ell(cx + 40, 96, 22, 14)], "steel", 1.3, line=LS),
         F("stains", [icon("droplet", cx + 20, 150, 10, 20), icon("metaballs", cx - 60, 124, 30, 12)], "@stain_disinfect",
           1.4, kind="flat", opacity=0.5)]
    return recipe("obj_s01_sink", f, (W, H), (cx, 402), PAL, style="prop", seed=230,
                  pivot_meaning="floor point under the drain pipe; the basin is fixed to the corridor wall",
                  note="Region D wall sink outside the lab: grey-white basin, two taps, drain pipe; antiseptic drips "
                       "on the rim. obj_s01_disinfect_tool sits on its left rim.")


@asset("obj_s01_disinfect_tool")
def disinfect_tool():
    W, H = 170, 80
    f = [floor_shadow(85, 62, 150, 12, 0.3, 3),
         fblock("tray", 16, 154, 40, 18, 10, "steel", z=1.0),
         F("tool_handle", [box(70, 44, 70, 10, rot=-8)], "plastic_black", 1.2, line=LS),
         F("tool_shaft", [box(122, 40, 44, 4, rot=-8)], "steel", 1.25, line=LS),
         F("thumb_print", [icon("fingerprint", 70, 43, 14, 9, rot=-8)], "blood", 1.3, kind="flat", opacity=0.9),
         F("cotton", [icon("cloud", 36, 46, 22, 14)], "gauze", 1.4, line=LS),
         F("gauze_blood", [icon("metaballs", 38, 46, 12, 8)], "blood", 1.45, kind="flat", clip_to="cotton")]
    return recipe("obj_s01_disinfect_tool", f, (W, H), (85, 62), PAL, style="prop", seed=231,
                  note="D1 instrument tray on the sink rim: black-handled steel instrument whose handle carries a "
                       "bloody right-thumb whorl print (compare cu_s01_tool_print with cu_s01_access_card), cotton.")


@asset("obj_s01_copier")
def copier():
    W, H = 380, 420
    f = [floor_shadow(190, 400, 330, 30, 0.35, 8),
         fblock("body", 40, 340, 60, 50, 290, "plastic_beige", z=1.0),
         F("lid", [rect(50, 40, 330, 64)], "plastic_beige", 1.1, color="#7a7362", line=LT),
         F("panel", [rect(250, 70, 330, 104)], "plastic_black", 1.2, kind="flat", line=LS),
         F("panel_keys", [rect(258 + i * 12, 80, 266 + i * 12, 88) for i in range(5)], "steel", 1.3, kind="flat"),
         F("counter", [rect(262, 92, 300, 100)], "screen_glow", 1.31, kind="flat", emit=0.5),
         F("trays", [rect(60, 200 + i * 60, 320, 240 + i * 60) for i in range(3)], "plastic_beige", 1.4, kind="flat",
           color="#6f6857", line=LS),
         F("tray_pulls", [rect(170, 214 + i * 60, 210, 222 + i * 60) for i in range(3)], "@ink", 1.5, kind="flat",
           opacity=0.5),
         F("log_sheet", [quad([(64, 120), (130, 118), (132, 176), (62, 178)])], "paper_ivory", 1.6, line=LS),
         F("log_rows", [rect(70, 130 + i * 10, 124, 132 + i * 10) for i in range(4)], "ink_line", 1.7, kind="flat",
           opacity=0.5)]
    return recipe("obj_s01_copier", f, (W, H), (190, 400), PAL, style="prop", seed=232,
                  pivot_meaning="floor point under the front centre",
                  note="D2 photocopier in the copy room under the stairs: usage log sheet taped to its front "
                       "(readable in cu_s01_copier_log), counter display in _emit.png.")


@asset("obj_s01_guard_board")
def guard_board():
    W, H = 200, 250
    f = [F("board", [rect(20, 20, 180, 230)], "cork", 1.0, line=LT),
         F("frame", [rect(12, 12, 188, 24), rect(12, 226, 188, 238), rect(12, 12, 24, 238), rect(176, 12, 188, 238)],
           "wood_dark", 1.1, kind="flat", line=LS),
         F("clipboard", [rect(50, 46, 150, 200)], "wood_dark", 1.2, color="#6a5334", line=LS),
         F("sheet", [rect(58, 60, 142, 194)], "paper_ivory", 1.3, line=LS),
         F("clip", [rect(80, 38, 120, 56)], "steel", 1.4, line=LS),
         F("rows", [rect(64, 76 + i * 14, 136, 78 + i * 14) for i in range(8)], "ink_line", 1.5, kind="flat", opacity=0.45),
         F("pen_string", limb((150, 60), (168, 150), 2, 2), "@ink", 1.6, kind="flat"),
         F("pen", [box(168, 160, 6, 36, rot=10)], "plastic_black", 1.7, line=LS)]
    return recipe("obj_s01_guard_board", f, (W, H), (100, 16), PAL, style="prop", seed=233,
                  pivot_meaning="top centre (hang point on the corridor wall)",
                  note="D3 guard call/arrival log board at the corridor end (clipboard sheet readable in "
                       "cu_s01_guard_log).")
