"""Stage 01 backgrounds (base_clean: floor, walls, fixed structure only)."""

from __future__ import annotations

from g06kit import F, box, clock_pieces, ell, icon, quad, recipe, rect
from g06kit.rooms import LINE_ENV, LINE_THIN, FrontRoom, IsoRoom, full
from s01_common import PAL, PPM, asset

# Region A layout (metres, iso world; see JOB.md "지역 A 배치")
LAB = {"origin": (1180, 560), "k": 250.0,
       "prep_door": (1.6, 2.5),       # right wall Y span, door to the prep room (region C)
       "board": (3.0, 4.2, 1.0, 1.9),  # right wall Y0, Y1, Z0, Z1: task board (object)
       "clock": (2.75, 2.15),          # right wall Y, Z (object)
       "main_door": (4.5, 5.4),        # right wall Y span, door to the corridor (region D)
       "window": (1.75, 3.6, 1.0, 2.1),  # left wall X0, X1, Z0, Z1: observation window (region B behind)
       "crt_desk": (0.45, 1.45)}       # left wall X span: stimulus desk (object)


@asset("bg_s01_lab")
def bg_lab():
    room = IsoRoom(origin=LAB["origin"], k=LAB["k"], kz=PPM, xmax=6.0, ymax=7.0, zmax=5.2)
    io = room.iso
    f = []
    f += room.floor_tiles("lino", checker_opacity=0.28)
    f += room.floor_stains([(2.6, 1.2, 0.9, 1.0), (4.4, 3.4, 1.2, 0.8), (1.2, 4.6, 0.8, 1.0),
                            (3.4, 2.4, 0.35, 1.0), (2.2, 3.9, 0.3, 1.2), (4.9, 1.6, 0.4, 1.0), (0.8, 3.2, 0.28, 1.0),
                            (3.7, 5.2, 0.5, 1.0)], opacity=0.38)
    # worn path: corridor door -> bench -> window
    wp = [icon("cloud", *io.p(1.2, 4.6), 520, 190, rot=26), icon("cloud", *io.p(2.3, 3.4), 560, 210, rot=26),
          icon("cloud", *io.p(3.4, 2.0), 480, 180, rot=-24)]
    f.append(F("worn_path", wp, "worn", 2.1, kind="wash", opacity=0.22, blur=34,
               rough={"amp": 0.6, "soft": 20, "cell": 60}))
    f += room.walls("wall_olive", "wall_olive", left_color="#4b4a35", right_color="#595840")
    prep, main = LAB["prep_door"], LAB["main_door"]
    f += room.wainscot("wainscot", gaps_left=[], gaps_right=[prep, main], left_color="#3d3022", right_color="#4a3a28")
    # plaster wear, a removed-notice ghost, cable conduit and sockets (fixed installation)
    f.append(F("plaster_damp", [icon("cloud", *io.p(0, 5.9, 2.9), 420, 300), icon("droplet", *io.p(0, 0.6, 2.2), 90, 220),
                                icon("cloud", *io.p(4.4, 0, 2.6), 380, 260)],
               "damp", 3.4, kind="wash", blend="multiply", opacity=0.35, blur=20, rough={"amp": 0.6, "soft": 12, "cell": 40}))
    f.append(F("notice_ghost", [io.wall_y(5.7, 6.4, 1.25, 1.85), io.wall_x(4.1, 4.6, 1.3, 1.7)], "@ink", 3.45,
               kind="flat", opacity=0.08))
    conduit = [io.wall_y(0.15, 6.9, 2.55, 2.6), io.wall_x(0.15, 5.9, 2.55, 2.6)]
    f.append(F("conduit", conduit, "metal_dark", 3.5, kind="flat", line=LINE_THIN))
    sockets = [io.wall_y(3.62, 3.74, 0.35, 0.47), io.wall_x(1.52, 1.64, 0.35, 0.47), io.wall_y(5.62, 5.72, 1.2, 1.34)]
    f.append(F("sockets", sockets, "plastic_beige", 3.52, kind="flat", line=LINE_THIN))
    # cracks in the plaster (flat marks)
    f.append(F("cracks", [icon("lightning_bolt", *io.p(0, 6.3, 1.4), 18, 110, rot=12),
                          icon("lightning_bolt", *io.p(3.9, 0, 2.3), 14, 80, rot=-30),
                          icon("lightning_bolt", *io.p(0, 0.9, 1.5), 12, 70, rot=20)], "floor_joint", 3.55,
               kind="flat", opacity=0.55))
    # doors and the observation window
    f += room.door("prep_door", "r", prep[0], prep[1], z=4.0, state="closed", window=True, leaf="wood_dark")
    f += room.door("main_door", "r", main[0], main[1], z=4.0, state="open", inside="@void_room",
                   inside_floor="lino")
    wx0, wx1, wz0, wz1 = LAB["window"]
    beyond = [F("booth_dim", [io.wall_x(wx0, wx1, wz0, wz0 + 0.42)], "@void_room", 4.05, kind="flat", opacity=0.55),
              F("booth_desk_dim", [io.wall_x(wx0 + 0.3, wx1 - 0.5, wz0, wz0 + 0.12)], "wood_dark", 4.06, kind="flat",
                opacity=0.5)]
    f += room.window("obs_window", "l", wx0, wx1, wz0, wz1, z=4.0, mullions=1, beyond=beyond)
    # floor drain + taped line in front of the stimulus desk (flat floor marks)
    f.append(F("tape_line", [io.floor(0.3, 0.9, 1.7, 0.96)], "@magnet_yellow", 2.3, kind="flat", opacity=0.45))
    dx, dy = io.p(3.3, 5.0)
    f.append(F("drain", [icon("grid_fine", dx, dy, 90, 45)], "metal_dark", 2.4, kind="flat",
               line={"width": 1.2, "heavy": 1.4}))
    return recipe("bg_s01_lab", f, (2560, 1440), (0, 0), PAL, style="environment", seed=101,
                  pivot_meaning="canvas origin = logical (0,0); 2 source px per logical px",
                  note="Stage 01 region A, main lab, quarter view (2:1 iso, far corner at (1180,560), 250 px/m on the "
                       "floor axes, 320 px/m vertical). Base only: lino floor, olive plaster walls, wood wainscot, "
                       "doors to the prep room (right wall) and corridor (right wall, open), observation window to "
                       "the booth (left wall). Empty wall space for the task board and clock (objects). No people, "
                       "props, text or UI.")


# ------------------------------------------------------------------ front-view helpers
def wall_panels(y_top, y_bot, x0, x1, n, mat="wainscot", color=None, z=3.2, skirt=36, rail=14):
    """Face-on wood wainscot band with ``n`` panels between x0 and x1."""
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
               handle_right=True):
    fw = 22
    f = [F(name + "_frame", [rect(x0 - fw, y_top - fw, x0, y_bot), rect(x1, y_top - fw, x1 + fw, y_bot),
                             rect(x0 - fw, y_top - fw, x1 + fw, y_top)], "wood_dark", z, kind="flat", line=LINE_THIN)]
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


def conduit_h(y, x0, x1, z=3.5, thick=12):
    return [F("conduit_" + str(int(y)), [rect(x0, y, x1, y + thick)], "metal_dark", z, kind="flat", line=LINE_THIN)]


# ------------------------------------------------------------------ region B
@asset("bg_s01_booth")
def bg_booth():
    """Side view (eye-level camera): the booth wall that faces the lab, with the thick
    observation window; through it the lab's right wall (task board, clock, doors) is
    a dim far view, painted without people or movable objects."""
    W, H = 2560, 1440
    hz = 1160
    room = FrontRoom(W, H, horizon=hz, vanish=(1280, -2600))
    f = []
    f += room.floor_boards("lino", n=16, rows=3, spread=1.5)
    f += room.back_wall("wall_olive", color="#4d4c36")
    f += wall_panels(880, hz, -40, W + 40, 8, color="#3d3022")
    # far lab view through the glass (window x 520..2060, y 170..760)
    gx0, gy0, gx1, gy1 = 520, 170, 2060, 770
    far = [rect(gx0, gy0, gx1, gy1)]
    f.append(F("win_far_wall", far, "wall_olive", 4.0, kind="flat", color="#3c3b2b"))
    f.append(F("win_far_wainscot", [rect(gx0, 560, gx1, gy1)], "wainscot", 4.01, kind="flat", color="#2f261b"))
    f.append(F("win_far_board", [rect(1080, 300, 1420, 520)], "cork", 4.02, kind="flat", color="#40372a",
               line={"width": 1.0, "heavy": 1.0}))
    f.append(F("win_far_doors", [rect(620, 250, 860, gy1), rect(1720, 250, 1960, gy1)], "wood_dark", 4.02, kind="flat",
               color="#2c2319"))
    f.append(F("win_far_clock", [ell(960, 280, 70, 70)], "plastic_beige", 4.03, kind="flat", color="#5d5a4c"))
    f.append(F("win_far_bench", [rect(gx0, 690, 1650, gy1), rect(gx0, 660, 1650, 700)], "wood_ochre", 4.04,
               kind="flat", color="#3a3021"))
    f.append(F("win_glass_tint", far, "glass_booth", 4.2, kind="flat", opacity=0.45))
    refl = [quad([(620, 180), (700, 180), (560, 760), (480, 760)]), quad([(760, 180), (800, 180), (660, 760), (620, 760)]),
            quad([(1500, 180), (1640, 180), (1500, 760), (1360, 760)])]
    f.append(F("win_reflect", refl, "@reflect", 4.25, kind="flat", opacity=0.1, clip_to="win_glass_tint"))
    # thick double frame
    fw = 46
    frame = [rect(gx0 - fw, gy0 - fw, gx1 + fw, gy0), rect(gx0 - fw, gy1, gx1 + fw, gy1 + fw),
             rect(gx0 - fw, gy0, gx0, gy1), rect(gx1, gy0, gx1 + fw, gy1), rect(1280 - 14, gy0, 1280 + 14, gy1)]
    f.append(F("win_frame", frame, "metal_dark", 4.3, kind="flat", line=LINE_ENV))
    f.append(F("win_gasket", [rect(gx0 - 8, gy0 - 8, gx1 + 8, gy0), rect(gx0 - 8, gy1, gx1 + 8, gy1 + 8)], "rubber",
               4.31, kind="flat"))
    f.append(F("win_sill", [rect(gx0 - 80, gy1 + fw, gx1 + 80, gy1 + fw + 26)], "wood_dark", 4.32, kind="flat",
               line=LINE_THIN))
    # booth door on the left (to the lab), cable tray and conduit
    f += front_door("booth_door", 110, 400, 330, hz - 4, state="closed", pane=True)
    f += conduit_h(96, -40, W + 40)
    f.append(F("cable_tray", [rect(2200, 120, 2480, 150), rect(2320, 150, 2340, 880)], "metal_dark", 3.6, kind="flat",
               line=LINE_THIN))
    f.append(F("plaster_damp", [icon("cloud", 2300, 600, 380, 260), icon("cloud", 250, 150, 360, 220)], "damp", 3.45,
               kind="wash", blend="multiply", opacity=0.3, blur=24, rough={"amp": 0.6, "soft": 12, "cell": 40}))
    return recipe("bg_s01_booth", f, (W, H), (0, 0), PAL, style="environment", seed=102,
                  pivot_meaning="canvas origin = logical (0,0); 2 source px per logical px",
                  note="Stage 01 region B, observation booth, side view (eye-level camera, floor band from y=1160). "
                       "Thick double-framed observation window (x 520..2060, y 170..770); behind the tinted glass a "
                       "dim face-on view of the lab's right wall (board, clock, prep door, corridor door) and the bench "
                       "top, without people or movable objects. Booth door to the lab on the left. No props, text, UI.")


# ------------------------------------------------------------------ region C
LOCKERS = {"x0": 580, "x1": 1820, "n": 6, "top": 150, "bottom": 1000, "mira": 3}  # locker index 3 = M. VENN


@asset("bg_s01_locker")
def bg_locker():
    """Front view: one wall of steel lockers; the stairwell door down to the copy room on the right."""
    W, H = 2560, 1440
    hz = 1020
    room = FrontRoom(W, H, horizon=hz, vanish=(1280, -900))
    f = []
    f += room.floor_boards("lino", n=14, rows=4, spread=2.2)
    f += room.back_wall("wall_olive", color="#56553d")
    f += wall_panels(800, hz, 1840, W + 40, 2, color="#3d3022")
    f += wall_panels(800, hz, -40, 560, 2, color="#3d3022")
    f += front_door("lab_door", 150, 440, 300, hz, state="closed", pane=True, handle_right=True)
    L = LOCKERS
    step = (L["x1"] - L["x0"]) / L["n"]
    bodies, doors, vents, plates, handles = [], [], [], [], []
    for i in range(L["n"]):
        x0 = L["x0"] + step * i
        doors.append(rect(x0 + 8, L["top"] + 50, x0 + step - 8, L["bottom"] - 44))
        for v in range(4):
            vents.append(rect(x0 + step * 0.3, L["top"] + 90 + v * 26, x0 + step * 0.7, L["top"] + 100 + v * 26))
        plates.append(rect(x0 + step * 0.34, L["top"] + 220, x0 + step * 0.66, L["top"] + 258))
        handles.append(rect(x0 + step - 46, L["top"] + 420, x0 + step - 30, L["top"] + 520))
    bodies.append(rect(L["x0"] - 16, L["top"], L["x1"] + 16, L["bottom"]))
    f.append(F("locker_bank", bodies, "metal_grey", 4.0, kind="flat", color="#46504a", line=LINE_ENV))
    f.append(F("locker_top", [rect(L["x0"] - 26, L["top"] - 20, L["x1"] + 26, L["top"] + 12)], "metal_dark", 4.01,
               kind="flat", line=LINE_THIN))
    f.append(F("locker_base", [rect(L["x0"] - 16, L["bottom"] - 44, L["x1"] + 16, L["bottom"])], "metal_dark", 4.02,
               kind="flat", line=LINE_THIN))
    f.append(F("locker_doors", doors, "metal_grey", 4.03, kind="flat", color="#505b54", textured=True, line=LINE_THIN,
               grime={"stamps": ["cloud", "droplet"], "size": 60, "soft": 6, "density": 0.07, "strength": 0.3,
                      "color": "rust", "lo": 0.25}))
    f.append(F("locker_vents", vents, "@ink", 4.04, kind="flat", opacity=0.55))
    f.append(F("locker_plates", plates, "paper_ivory", 4.05, kind="flat", color="#8d846e", line={"width": 0.8, "heavy": 0.8}))
    f.append(F("locker_handles", handles, "steel", 4.06, kind="flat", line={"width": 0.8, "heavy": 1.0}))
    # stairwell door (open) down to the copy room: dark void with the first steps going down
    dx0, dx1, dy0 = 1990, 2370, 250
    f += front_door("stair_door", dx0, dx1, dy0, hz, state="open", inside="@void_room")
    steps = []
    for s in range(5):
        y = hz - 30 - s * 48
        steps.append(rect(dx0 + 10, y, dx1 - 10, y + 16))
    f.append(F("stair_steps", steps, "metal_dark", 4.05, kind="flat", opacity=0.55, line={"width": 1.0, "heavy": 1.0}))
    f.append(F("stair_rail", [quad([(dx0 + 40, 520), (dx0 + 60, 520), (dx1 - 30, 900), (dx1 - 50, 900)])], "steel", 4.06,
               kind="flat", opacity=0.6))
    f += conduit_h(70, -40, W + 40)
    f.append(F("wall_marks", [rect(480, 380, 540, 520), rect(1880, 360, 1950, 470)], "@ink", 3.5, kind="flat",
               opacity=0.08))
    f.append(F("plaster_damp", [icon("cloud", 2450, 180, 360, 260), icon("cloud", 90, 700, 260, 300)], "damp", 3.45,
               kind="wash", blend="multiply", opacity=0.3, blur=24, rough={"amp": 0.6, "soft": 12, "cell": 40}))
    return recipe("bg_s01_locker", f, (W, H), (0, 0), PAL, style="environment", seed=103,
                  pivot_meaning="canvas origin = logical (0,0); 2 source px per logical px",
                  note="Stage 01 region C, prep room, front view (floor from y=1020). Fixed bank of six steel lockers "
                       "(x 580..1820, y 150..1000; locker index 3 = Mira's, overlaid by obj_s01_locker_mira), door back to "
                       "the lab (x 150..440), "
                       "open stairwell door down to the copy room (x 1990..2370). Name plates blank. No props, text, UI.")


# ------------------------------------------------------------------ region D
@asset("bg_s01_corridor")
def bg_corridor():
    """Connection screen: corridor outside the lab (lab door, sink wall) on the left;
    on the right the stairwell drops to the lower landing and the copy room door."""
    W, H = 2560, 1440
    hz = 1080
    room = FrontRoom(W, H, horizon=hz, vanish=(900, -900))
    f = []
    f += room.floor_boards("lino", n=12, rows=4, spread=2.0)
    f += room.back_wall("wall_olive", color="#53523a")
    f += wall_panels(860, hz, -40, 1560, 5, color="#3d3022")
    f += front_door("lab_door", 180, 500, 300, hz, state="closed", pane=True, handle_right=True)
    f += conduit_h(80, -40, W + 40)
    # stairwell: the upper floor ends at x=1560; stairs go down to the right to a lower landing
    sx0, sx1 = 1560, 2560
    f.append(F("well_void", [rect(sx0, 420, sx1 + 40, H + 40)], "@void_room", 4.0, kind="flat"))
    lower_wall = [rect(sx0 + 380, 420, sx1 + 40, 1260)]
    f.append(F("lower_wall", lower_wall, "wall_olive", 4.1, kind="flat", color="#3c3b2a", textured=True, line=LINE_ENV))
    f.append(F("lower_floor", [rect(sx0 + 380, 1260, sx1 + 40, H + 40)], "lino", 4.12, kind="flat", color="#3a3832",
               line=LINE_THIN))
    steps = []
    nsteps = 9
    for s in range(nsteps):
        x0 = sx0 + s * 44
        y0 = hz + s * 40
        steps.append(rect(x0, y0, sx0 + 380 + 40, y0 + 40))
    f.append(F("stairs", steps, "lino", 4.2, kind="flat", color="#46433b", line=LINE_THIN))
    noses = [rect(sx0 + s * 44, hz + s * 40, sx0 + 420, hz + s * 40 + 8) for s in range(nsteps)]
    f.append(F("stair_noses", noses, "metal_dark", 4.21, kind="flat", opacity=0.8))
    f.append(F("stair_rail", [quad([(sx0 + 10, hz - 110), (sx0 + 26, hz - 110), (sx0 + 430, hz + 250), (sx0 + 414, hz + 250)]),
                              rect(sx0 + 6, hz - 110, sx0 + 22, hz + 20)], "steel", 4.3, kind="flat", line=LINE_THIN))
    # copy room doorway on the lower landing (lit room inside -> flat lighter wall colour, no light effect)
    cx0, cx1 = 2080, 2440
    f.append(F("copy_room_inside", [rect(cx0, 700, cx1, 1260)], "wall_olive", 4.3, kind="flat", color="#5e5c45"))
    f.append(F("copy_room_floor", [rect(cx0, 1180, cx1, 1260)], "lino", 4.31, kind="flat", color="#56534a"))
    fw = 22
    f.append(F("copy_room_frame", [rect(cx0 - fw, 700 - fw, cx0, 1260), rect(cx1, 700 - fw, cx1 + fw, 1260),
                                   rect(cx0 - fw, 700 - fw, cx1 + fw, 700)], "wood_dark", 4.32, kind="flat", line=LINE_THIN))
    # under-stair void and the corridor end wall edge
    f.append(F("under_stair", [quad([(sx0, hz + 40), (sx0 + 380, hz + 380), (sx0 + 380, H + 40), (sx0, H + 40)])],
               "@ink", 4.25, kind="flat", opacity=0.55))
    f.append(F("wall_edge", [rect(sx0 - 14, 0, sx0 + 8, hz)], "wood_dark", 4.4, kind="flat", line=LINE_THIN))
    f.append(F("plaster_damp", [icon("cloud", 1300, 220, 420, 260), icon("droplet", 700, 760, 90, 200)], "damp", 3.45,
               kind="wash", blend="multiply", opacity=0.3, blur=24, rough={"amp": 0.6, "soft": 12, "cell": 40}))
    return recipe("bg_s01_corridor", f, (W, H), (0, 0), PAL, style="environment", seed=104,
                  pivot_meaning="canvas origin = logical (0,0); 2 source px per logical px",
                  note="Stage 01 region D, corridor connection screen (front view, floor from y=1080). Left: lab door "
                       "and the empty sink wall (sink = object). Right: stairwell going down to the lower landing and "
                       "the copy room doorway (x 2080..2440); copier and guard board are objects. No text, UI.")


# ------------------------------------------------------------------ VISUAL 1 frame
@asset("cu_s01_cctv_view")
def cctv_view():
    """Booth camera frame (4:3) of the lab's right wall at 01:34, CCTV grey-green.
    The task board and the clock (01:34) are part of the recorded picture; Mira is the
    separate sprite chr_s01_mira_cctv_0134 (placed by scene_s01_cctv_frame.json)."""
    from s01_common import PAL_CCTV
    W, H = 1280, 960
    f = [F("wall", [rect(-20, -20, W + 20, 720)], "wall_olive", 1.0, kind="flat", textured=True, line=LINE_THIN),
         F("wainscot", [rect(-20, 560, W + 20, 740)], "wainscot", 1.1, kind="flat", textured=True, line=LINE_THIN),
         F("rail", [rect(-20, 550, W + 20, 566)], "wood_dark", 1.2, kind="flat", line=LINE_THIN),
         F("floor", [rect(-20, 740, W + 20, H + 20)], "lino", 1.0, kind="flat", textured=True),
         F("floor_joints", [rect(-20, 800, W + 20, 806), rect(-20, 880, W + 20, 888), rect(300, 740, 306, H + 20),
                            rect(760, 740, 768, H + 20)], "floor_joint", 1.05, kind="flat", opacity=0.7),
         F("prep_door", [rect(-20, 120, 150, 740)], "wood_dark", 1.3, kind="flat", line=LINE_THIN)]
    # the task board (same arrangement as cu_s01_task_board, small)
    bx0, by0, bx1, by1 = 560, 190, 980, 500
    f.append(F("board", [rect(bx0, by0, bx1, by1)], "cork", 2.0, kind="flat", line=LINE_THIN))
    f.append(F("board_frame", [rect(bx0 - 14, by0 - 14, bx1 + 14, by0), rect(bx0 - 14, by1, bx1 + 14, by1 + 14),
                               rect(bx0 - 14, by0, bx0, by1), rect(bx1, by0, bx1 + 14, by1)], "wood_dark", 2.1,
               kind="flat", line=LINE_THIN))
    from s01_board import cells as board_cells
    cw, ch = (bx1 - bx0 - 40) / 4, (by1 - by0 - 40) / 4
    rims, mags = [], {}
    for r, c, shape, key, mc in board_cells():   # same arrangement as the board object and close-up
        x, y = bx0 + 20 + cw * (c + 0.5), by0 + 20 + ch * (r + 0.5)
        rims.append(icon(shape, x, y, cw * 0.66, ch * 0.66, fit="box"))
        mags.setdefault(mc, []).append(icon(shape, x - 1, y - 2, cw * 0.5, ch * 0.5, fit="box"))
    f.append(F("board_outlines", rims, "cork", 2.15, kind="flat", color="#857d64", line={"width": 0.8, "heavy": 0.8}))
    for i, (col, pcs) in enumerate(sorted(mags.items())):
        f.append(F("board_magnets_" + col, pcs, col, 2.2 + i * 0.01, line={"width": 0.8, "heavy": 0.8}))
    # wall clock at 01:34 (hour hand just past 1, minute hand at 34)
    cx, cy, r = 360, 150, 56
    f.append(F("clock_face", [ell(cx, cy, r * 2, r * 2)], "plastic_beige", 2.0, line=LINE_THIN))
    ticks, hands = clock_pieces(cx, cy, r * 0.9, 1, 34)
    f.append(F("clock_ticks", ticks, "@ink", 2.1, kind="flat"))
    f.append(F("clock_hands", hands, "@ink", 2.2, kind="flat"))
    f.append(F("bench_corner", [rect(-20, 800, 420, 850), rect(-20, 850, 380, H + 20)], "wood_ochre", 3.0, kind="flat",
               line=LINE_THIN))
    # recorded-image texture: scan lines + slight roll bar (part of the picture, not UI)
    lines = [rect(-20, y, W + 20, y + 2) for y in range(0, H, 6)]
    f.append(F("scanlines", lines, "@ink", 9.0, kind="flat", opacity=0.12))
    f.append(F("rollbar", [rect(-20, 610, W + 20, 660)], "screen_glow", 9.1, kind="flat", opacity=0.08))
    return recipe("cu_s01_cctv_view", f, (W, H), (0, 0), PAL_CCTV, style="environment", seed=105,
                  pivot_meaning="canvas origin",
                  note="VISUAL 1: the 01:34 booth-camera frame (4:3, CCTV grey-green palette). Lab right wall with "
                       "the 4x4 task board and the wall clock reading 01:34, bench corner at the bottom. Mira (eyes "
                       "open, hand on the board) is the separate sprite chr_s01_mira_cctv_0134; the frame has no "
                       "person, text or timestamp.")
