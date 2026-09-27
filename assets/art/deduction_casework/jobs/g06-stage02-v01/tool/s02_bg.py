"""Stage 02 backgrounds (base_clean only)."""

from __future__ import annotations

from g06kit import F, box, ell, icon, quad, rect
from g06kit.front import LINE_ENV, LINE_THIN, conduit_h, damp, front_door, front_window, wall_panels
from g06kit.rooms import FrontRoom, IsoRoom
from s02_common import PAL, PPM, asset

NOTE_BASE = " Base only (floor, walls, fixed structure, flat floor marks); no people, props, text or UI."
FOYER = {"origin": (1180, 560), "k": 250.0, "front_door": (2.3, 3.4), "dining_door": (3.4, 4.6)}
STUDY = {"origin": (1180, 560), "k": 250.0, "window": (1.3, 2.6, 0.85, 2.3), "side_door": (3.7, 4.5),
         "shelves": (0.25, 2.7), "safe": (3.0, 3.75, 1.0, 1.6), "main_door": (4.6, 5.5)}


def _picture_rail_iso(io, xmax, ymax, z=2.35):
    return F("picture_rail", [io.wall_x(0, xmax, z, z + 0.05), io.wall_y(0, ymax, z, z + 0.05)], "wood_dark", 3.6,
             kind="flat", line=LINE_THIN)


def _wallpaper_iso(io, xmax, ymax, z0=1.0, z1=5.0, name="damask"):
    pcs = []
    for i in range(int(xmax / 0.6)):
        for k in range(int((z1 - z0) / 0.7)):
            x, y = io.p(0.3 + i * 0.6, 0, z0 + 0.35 + k * 0.7 + (0.35 if i % 2 else 0))
            pcs.append(icon("flower", x, y, 42, 50, skew=[0, -26.565]))
    for i in range(int(ymax / 0.6)):
        for k in range(int((z1 - z0) / 0.7)):
            x, y = io.p(0, 0.3 + i * 0.6, z0 + 0.35 + k * 0.7 + (0.35 if i % 2 else 0))
            pcs.append(icon("flower", x, y, 42, 50, skew=[0, 26.565]))
    return F(name, pcs, "@joint_dark", 3.05, kind="flat", opacity=0.12)


# ------------------------------------------------------------------ A foyer (quarter view)
@asset("bg_s02_foyer")
def bg_foyer():
    room = IsoRoom(origin=FOYER["origin"], k=FOYER["k"], kz=PPM, xmax=6.0, ymax=7.0, zmax=5.2)
    io = room.iso
    f = room.floor_tiles("marble_dark", "marble_light", tile=0.6)
    f += room.floor_stains([(3.0, 2.2, 1.0, 0.8), (4.2, 3.6, 0.8, 1.0), (1.5, 4.4, 0.6, 1.0), (3.3, 1.2, 0.3, 1.2),
                            (2.1, 3.1, 0.35, 1.0)], opacity=0.3)
    # wet tracks from the front door (flat marks): rain water on the marble
    wet = [icon("droplet", *io.p(2.9 + t * 0.35, 0.6 + t * 0.55), 34, 22, rot=60) for t in range(6)]
    f.append(F("wet_tracks", wet, "damp", 2.2, kind="wash", blend="multiply", opacity=0.35, blur=4))
    f += room.walls("wall_green", "wall_green", left_color="#353f31", right_color="#414d3c")
    f.append(_wallpaper_iso(io, 6.0, 7.0))
    fd, dd = FOYER["front_door"], FOYER["dining_door"]
    f += room.wainscot("wainscot", top=1.0, gaps_left=[fd], gaps_right=[dd], left_color="#3c271d", right_color="#4a3023")
    f.append(_picture_rail_iso(io, 6.0, 7.0))
    f += room.door("front_door", "l", fd[0], fd[1], height=2.4, z=4.0, state="closed", window=True, leaf=("wood_red"))
    f += room.door("dining_door", "r", dd[0], dd[1], height=2.4, z=4.0, state="open", inside="@void_room",
                   inside_floor="parquet")
    f.append(F("transom", [io.wall_x(fd[0] + 0.1, fd[1] - 0.1, 2.5, 2.75)], "glass_rain", 4.1, kind="flat", line=LINE_THIN,
               color="#2b353d"))
    f.append(damp([icon("cloud", *io.p(4.8, 0, 2.8), 400, 260), icon("cloud", *io.p(0, 6.2, 3.0), 420, 300)]))
    f.append(F("doormat_mark", [io.floor(2.25, 0.05, 3.45, 0.7)], "grime", 2.3, kind="wash", blend="multiply",
               opacity=0.45, blur=6))
    return recipe_bg("bg_s02_foyer", f, 201, "Stage 02 region A, entrance hall / condolence room, quarter view (same "
                     "iso frame as Stage 01: far corner (1180,560), 250 px/m floor axes, 320 px/m vertical). Dark marble "
                     "checker floor with wet tracks from the front door (left wall), ink-green damask walls, red-brown "
                     "wainscot, open doorway to the dining room (right wall).")


def recipe_bg(asset_id, forms, seed, note):
    from g06kit import recipe
    return recipe(asset_id, forms, (2560, 1440), (0, 0), PAL, style="environment", seed=seed,
                  pivot_meaning="canvas origin = logical (0,0); 2 source px per logical px", note=note + NOTE_BASE)


# ------------------------------------------------------------------ B dining (wide view)
@asset("bg_s02_dining")
def bg_dining():
    W, H = 2560, 1440
    hz = 1000
    room = FrontRoom(W, H, horizon=hz, vanish=(1280, -1400))
    f = room.floor_boards("parquet", n=20, rows=4, spread=1.6)
    f += room.back_wall("wall_green", color="#3a4535")
    pcs = []
    for i in range(22):
        for k in range(8):
            pcs.append(icon("flower", 60 + i * 120 + (60 if k % 2 else 0), 60 + k * 100, 40, 48))
    f.append(F("damask", pcs, "@joint_dark", 3.05, kind="flat", opacity=0.12))
    f += wall_panels(760, hz, -40, W + 40, 10, color="#3c271d")
    f.append(F("picture_rail", [rect(-40, 150, W + 40, 164)], "wood_dark", 3.6, kind="flat", line=LINE_THIN))
    outside = [F("rain_streaks", [box(420 + i * 37, 450, 3, 600, rot=12) for i in range(10)], "@rain", 4.1, kind="flat",
                 opacity=0.2)]
    f += front_window("win_l", 400, 720, 230, 700, z=4.0, glass="glass_rain", mullions=1, transoms=2, outside=outside,
                      curtain="cloth_wine")
    outside2 = [F("rain_streaks2", [box(1860 + i * 37, 450, 3, 600, rot=12) for i in range(10)], "@rain", 4.1,
                  kind="flat", opacity=0.2)]
    f += front_window("win_r", 1840, 2160, 230, 700, z=4.0, glass="glass_rain", mullions=1, transoms=2, outside=outside2,
                      curtain="cloth_wine")
    # fireplace (fixed): mantel, surround, dark firebox (cold after the funeral)
    f.append(F("chimney_breast", [rect(1040, 160, 1520, hz)], "wall_green", 3.8, kind="flat", color="#344030",
               line=LINE_THIN))
    f.append(F("surround", [rect(1100, 560, 1460, hz)], "marble_dark", 3.9, kind="flat", textured=True, line=LINE_ENV))
    f.append(F("firebox", [rect(1180, 680, 1380, hz)], "@void_room", 3.95, kind="flat"))
    f.append(F("grate", [rect(1200, 900 + i * 18, 1360, 906 + i * 18) for i in range(4)], "metal_dark", 3.96,
               kind="flat"))
    f.append(F("mantel", [rect(1070, 540, 1490, 575)], "wood_red", 4.0, kind="flat", textured=True, line=LINE_THIN))
    f += front_door("door_foyer", 90, 330, 330, hz, state="open", inside="@void_room")
    f += front_door("door_study", 2250, 2490, 330, hz, state="closed", leaf="wood_red")
    f += front_door("door_service", 1600, 1760, 380, hz, state="closed", leaf="wall_green_dark", frame="wall_green_dark")
    f.append(damp([icon("cloud", 800, 120, 420, 220), icon("cloud", 2300, 150, 360, 220)]))
    return recipe_bg("bg_s02_dining", f, 202, "Stage 02 region B, dining room, wide front view (floor from y=1000): "
                     "ink-green damask wall, two rain windows with wine curtains, cold fireplace in the middle, open "
                     "door to the hall (left), closed door to the study corridor (right), service jib door "
                     "(x 1600..1760).")


# ------------------------------------------------------------------ C study (quarter view)
@asset("bg_s02_study")
def bg_study():
    room = IsoRoom(origin=STUDY["origin"], k=STUDY["k"], kz=PPM, xmax=6.0, ymax=7.0, zmax=5.2)
    io = room.iso
    f = room.floor_tiles("parquet", "parquet", tile=0.4, checker_opacity=0.0)
    f.append(F("rug", [io.floor(1.8, 1.4, 4.2, 4.2)], "cloth_wine", 1.5, kind="flat", textured=True,
               line={"width": 1.2, "heavy": 1.2}))
    f.append(F("rug_border", [io.floor(1.9, 1.5, 4.1, 1.62), io.floor(1.9, 3.98, 4.1, 4.1), io.floor(1.9, 1.5, 2.02, 4.1),
                              io.floor(3.98, 1.5, 4.1, 4.1)], "brass", 1.6, kind="flat", opacity=0.5))
    f += room.floor_stains([(3.0, 2.4, 0.9, 0.8), (1.2, 4.8, 0.6, 1.0)], opacity=0.25)
    f += room.walls("wall_green", "wall_green", left_color="#323b2e", right_color="#3e4a3a")
    f.append(_wallpaper_iso(io, 6.0, 7.0))
    wx0, wx1, wz0, wz1 = STUDY["window"]
    sd, md = STUDY["side_door"], STUDY["main_door"]
    s0, s1 = STUDY["shelves"]
    f += room.wainscot("wainscot", top=0.95, gaps_left=[sd], gaps_right=[(s0, s1), md], left_color="#3c271d",
                       right_color="#4a3023")
    # built-in bookshelves on the right wall (fixed): frame, shelves, rows of spines
    f.append(F("shelf_case", [io.wall_y(s0, s1, 0, 2.6)], "wood_red", 4.0, kind="flat", textured=True, line=LINE_THIN))
    books, cols = [], ["#4a2b24", "#2f3a2c", "#5a4a2e", "#2c2e3a", "#5b2d30", "#3d3a33"]
    rows = [(0.1, 0.5), (0.62, 1.02), (1.14, 1.54), (1.66, 2.06), (2.18, 2.5)]
    forms_b = {c: [] for c in cols}
    for r, (z0, z1) in enumerate(rows):
        y = s0 + 0.06
        k = r * 3
        while y < s1 - 0.1:
            w = 0.05 + ((k * 7) % 5) * 0.012
            hz_ = z1 - ((k * 11) % 4) * 0.03
            forms_b[cols[k % len(cols)]].append(io.wall_y(y, y + w, z0, hz_, X=0.02))
            y += w + 0.008
            k += 1
    for i, (c, pcs) in enumerate(forms_b.items()):
        f.append(F(f"books_{i}", pcs, "leather_brown", 4.1 + i * 0.001, kind="flat", color=c,
                   line={"width": 0.8, "heavy": 0.8}))
    f.append(F("shelf_boards", [io.wall_y(s0, s1, z1, z1 + 0.05, X=0.03) for _, z1 in [(0, 0.1)] + rows] +
               [io.wall_y(s0, s1, 2.5, 2.6, X=0.03)], "wood_red", 4.2, kind="flat", line=LINE_THIN))
    # wall safe recess (the door is obj_s02_wall_safe)
    y0, y1, z0, z1 = STUDY["safe"]
    f.append(F("safe_recess", [io.wall_y(y0 - 0.05, y1 + 0.05, z0 - 0.05, z1 + 0.05)], "metal_dark", 4.0, kind="flat",
               line=LINE_THIN))
    f.append(F("safe_void", [io.wall_y(y0, y1, z0, z1)], "@void_room", 4.01, kind="flat"))
    # half-open sash window (lower sash raised: a dark gap with rain outside)
    beyond = [F("win_outside", [io.wall_x(wx0, wx1, wz0, wz0 + 0.55)], "@night_sky", 4.02, kind="flat")]
    f += room.window("study_window", "l", wx0, wx1, wz0, wz1, z=4.0, mullions=1, beyond=beyond, glass="glass_rain")
    f.append(F("raised_sash", [io.wall_x(wx0, wx1, wz0 + 0.55, wz0 + 0.62), io.wall_x(wx0, wx1, wz0 + 1.25, wz0 + 1.3)],
               "wood_dark", 4.35, kind="flat", line=LINE_THIN))
    f += room.door("side_door", "l", sd[0], sd[1], height=2.1, z=4.0, state="closed", leaf="wood_dark")
    f += room.door("main_door", "r", md[0], md[1], height=2.35, z=4.0, state="closed", leaf="wood_red")
    f.append(_picture_rail_iso(io, 6.0, 7.0, z=2.7))
    f.append(damp([icon("droplet", *io.p(1.9, 0, 0.6), 60, 140)], opacity=0.4))
    return recipe_bg("bg_s02_study", f, 203, "Stage 02 region C, study, quarter view (same iso frame). Parquet with a "
                     "wine rug, built-in bookshelves and the wall safe recess on the right wall (safe door = object), "
                     "half-open sash window with rain outside and the servants' side door on the left wall, main door "
                     "(right wall).")


# ------------------------------------------------------------------ D servants' corridor + butler room (2x1)
@asset("bg_s02_service")
def bg_service():
    W, H = 2560, 1440
    hz = 1040
    room = FrontRoom(W, H, horizon=hz, vanish=(640, -1100))
    f = room.floor_boards("parquet", n=16, rows=4, spread=2.0)
    f += room.back_wall("wall_green", color="#2e3629")
    f.append(F("room_wall", [rect(1180, -40, W + 40, hz)], "wall_green", 3.1, kind="flat", color="#3e4938", textured=True,
               line=LINE_ENV))
    f.append(F("room_floor_tint", [rect(1180, hz, W + 40, H + 40)], "parquet", 1.2, kind="flat", color="#56402f",
               opacity=0.35))
    f += wall_panels(820, hz, -40, 1150, 3, color="#33221a")
    f += wall_panels(820, hz, 1210, W + 40, 5, color="#3c271d")
    # partition between the corridor and the butler's room: pillar + open doorframe
    f.append(F("partition", [rect(1150, -40, 1215, hz)], "wood_red", 4.5, kind="flat", textured=True, line=LINE_ENV))
    f.append(F("partition_base", [rect(1140, hz - 60, 1225, hz)], "wood_dark", 4.6, kind="flat", line=LINE_THIN))
    # corridor: the study's side door at the end, the door back to the dining room on the left edge
    f += front_door("door_to_study", 560, 820, 380, hz, state="closed", leaf="wood_dark")
    f += front_door("door_to_dining", 60, 300, 360, hz, state="closed", leaf="wall_green_dark", frame="wall_green_dark")
    f += conduit_h(110, -40, 1150)
    f.append(F("bell_board", [rect(1400, 160, 1760, 300)], "wood_dark", 4.1, kind="flat", line=LINE_THIN))
    f.append(F("bells", [icon("bell", 1440 + i * 56, 210, 36, 40) for i in range(6)], "brass", 4.2, line={"width": 0.8,
                                                                                                      "heavy": 0.8}))
    f.append(F("bell_labels", [rect(1424 + i * 56, 248, 1456 + i * 56, 262) for i in range(6)], "paper_ivory", 4.3,
               kind="flat", opacity=0.7))
    f.append(damp([icon("cloud", 300, 200, 420, 260), icon("cloud", 2200, 120, 380, 220)], opacity=0.35))
    return recipe_bg("bg_s02_service", f, 204, "Stage 02 region D, servants' corridor + butler's room side by side "
                     "(2x1, front view, floor from y=1040): dark narrow corridor on the left with the study side door "
                     "(x 560..820) and the dining-room door (x 60..300); a partition pillar; the butler's room wall on "
                     "the right with the old service bell board. Key board and desk are objects.")


# ------------------------------------------------------------------ E back garden, cemetery path (side view)
@asset("bg_s02_grave")
def bg_grave():
    W, H = 2560, 1440
    f = [F("sky", [rect(-40, -40, W + 40, 900)], "@night_sky", 0.5, kind="flat", grad={"to": "#2a313a", "y0": 0, "y1": 900})]
    f.append(F("far_trees", [icon("tree_evergreen", 120 + i * 260, 700 - (i % 3) * 40, 260, 460) for i in range(7)],
               "grass_dark", 0.6, kind="flat", color="#1f261e", opacity=0.9))
    f.append(F("ground", [rect(-40, 880, W + 40, H + 40)], "grass_dark", 1.0, kind="flat", textured=True, line=LINE_THIN))
    # the stone path from the far side of the garden toward the study window
    path = [quad([(-40, 1180), (900, 1150), (1720, 1230), (1760, 1330), (900, 1260), (-40, 1300)])]
    f.append(F("path", path, "mud", 1.2, kind="flat", textured=True, line=LINE_THIN))
    slabs = [box(120 + i * 150, 1235 - (i % 2) * 8, 110, 50, rot=-2 + (i % 3)) for i in range(11)]
    f.append(F("path_slabs", slabs, "stone_wall", 1.3, kind="flat", color="#4b474e", line=LINE_THIN))
    f.append(F("puddles", [ell(560, 1250, 160, 30), ell(1340, 1270, 200, 34)], "glass_rain", 1.4, kind="flat", opacity=0.55))
    # low stone wall with a gap (the cemetery side)
    f.append(F("low_wall", [rect(-40, 930, 780, 1060), rect(1000, 930, 1640, 1060)], "stone_wall", 2.0, kind="block",
               extrude=0, line=LINE_ENV))
    f.append(F("wall_cap", [rect(-40, 916, 780, 942), rect(1000, 916, 1640, 942)], "stone_wall", 2.1, kind="flat",
               color="#625d66", line=LINE_THIN))
    f.append(F("wall_joints", [rect(-40 + i * 90, 942, -36 + i * 90, 1060) for i in range(19)], "@joint_dark", 2.2,
               kind="flat", opacity=0.5))
    # house exterior with the study window and the servants' side door
    f.append(F("house_wall", [rect(1700, -40, W + 40, 1220)], "stone_wall", 3.0, kind="flat", textured=True, line=LINE_ENV,
               color="#3d3a42"))
    f.append(F("house_courses", [rect(1700, y, W + 40, y + 4) for y in range(60, 1200, 90)], "@joint_dark", 3.1,
               kind="flat", opacity=0.45))
    f += front_window("study_window_out", 1900, 2240, 360, 820, z=3.2, glass="glass_rain", mullions=1, transoms=1,
                      frame="wood_dark")
    f.append(F("sash_gap", [rect(1900, 700, 2240, 820)], "@void_room", 3.25, kind="flat", opacity=0.85))
    f += front_door("side_door_out", 2340, 2520, 560, 1220, state="closed", leaf="wood_dark")
    f.append(F("plinth", [rect(1700, 1180, W + 40, 1240)], "stone_wall", 3.3, kind="flat", color="#46424a", line=LINE_THIN))
    f.append(F("rain", [box(40 + i * 61, 420 + (i * 97) % 700, 3, 180, rot=12) for i in range(42)], "@rain", 9.0,
               kind="flat", opacity=0.18))
    return recipe_bg("bg_s02_grave", f, 205, "Stage 02 region E, back garden cemetery path + study outer wall, side "
                     "view, night rain: muddy path with stone slabs and puddles leading to the house, low stone wall "
                     "with a gap, the study window (lower sash raised) and the servants' side door on the house wall. "
                     "Headstones, footprints and the fallen page are objects.")
