"""g04-buildings-v01 recipes: one building per asset (houses, shops, towers, churches, barns, mills...).

    python -B make_recipes.py                    # write every recipe into ../recipes
    python -B make_recipes.py obj_house_medieval # only these

60 deg front view.  Two roof builders:
  * gable_front_roof: ridge runs north-south, the triangular gable faces the viewer, both slopes
    are seen from above (west slope lit, east slope in shade);
  * side_roof: ridge runs east-west, the front slope faces the viewer, the back slope is a thin
    strip above the ridge.
Pivot = front-bottom centre of the foundation (door threshold line).  Frames: day (windows
dark), night (lit windows, emit, one game light per window).
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g04kit import (E, I, LINE, MD, MH, MW, POLY, R, SQ, Asset, band_on_cyl, ellipse_shadow,  # noqa: E402,F401
                    planks_front, planks_top, rect_shadow, rivets)

JOB = Path(__file__).resolve().parents[1]
ASSETS = {}
THIN = {"width": 0.9, "heavy": 0.9, "breaks": 0.3}
FINE = {"width": 0.7, "heavy": 0.6, "breaks": 0.3}
BASE = "front-bottom centre of the foundation on the ground (door threshold line)"
WINDOW = "#f0c27a"


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


def poly_abs(points, **kw):
    """POLY from absolute local points (bounding box computed here)."""
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 1.0), max(y1 - y0, 1.0)
    return POLY([((x - x0) / w, (y - y0) / h) for x, y in points], (x0 + x1) / 2, (y0 + y1) / 2, w, h, **kw)


def courses(x0, x1, y0, y1, step, dash, vertical=False, down=1, dash_rot=0.0):
    """Tile courses: joint lines every ``step`` px, a shadow band on the downhill side of each joint,
    staggered joints between (rotated by ``dash_rot`` to follow the slope).  Returns (lines, shades)."""
    lines, shades = [], []
    k = 0
    if not vertical:
        y = y0 + step
        while y < y1:
            lines.append(R((x0 + x1) / 2, y, x1 - x0, 2.4, 1))
            shades.append(R((x0 + x1) / 2, y + 4 * down, x1 - x0, 7, 2))
            off = dash / 2 if k % 2 else 0
            x = x0 + off + dash
            while x < x1 - 4:
                lines.append(R(x, y - step / 2, 2.2, step - 4, 1))
                x += dash
            y += step
            k += 1
    else:
        x = x0 + step
        while x < x1:
            lines.append(R(x, (y0 + y1) / 2, 2.4, y1 - y0, 1))
            shades.append(R(x + 4 * down, (y0 + y1) / 2, 7, y1 - y0, 2))
            off = dash / 2 if k % 2 else 0
            y = y0 + off + dash
            while y < y1 - 4:
                lines.append(R(x - step / 2, y, step - 4, 2.2, 1, rot=dash_rot))
                y += dash
            x += step
            k += 1
    return lines, shades


def gable_front_roof(a, name, wall_top, W, D, rise, material, ov_s=30, ov_f=24, step=26, dash=40, gable="plaster",
                     timber="wood_dark", timbered=True, boards=False):
    """Gable facing the viewer.  wall_top = screen y of the front wall's top edge (centre x = 0)."""
    half = W / 2 + ov_s
    drop = ov_s * rise / (W / 2)
    apex = wall_top - rise
    fe_y = wall_top + drop + ov_f           # front eave corners
    fa_y = apex + ov_f                      # front apex
    back = D + 2 * ov_f
    a.add(f"{name}_gable", [poly_abs([(-W / 2, wall_top), (0, apex), (W / 2, wall_top)])], "mass", gable,
          shade={"bump": 0.2, "highlight_amount": 0.1})
    if timbered:
        a.flat(f"{name}_gable_timber", [LINE(-W / 2 + 10, wall_top - 6, 0, apex + 10, 12),
                                       LINE(W / 2 - 10, wall_top - 6, 0, apex + 10, 12),
                                       R(0, (wall_top + apex) / 2 + 20, 14, rise - 30, 2),
                                       R(0, wall_top - 8, W, 14, 2)], timber, line=THIN, clip_to=f"{name}_gable")
    if boards:
        a.flat(f"{name}_gable_boards", [R(x, (wall_top + apex) / 2, 2.4, rise, 1) for x in range(int(-W / 2) + 30,
                                                                                           int(W / 2), 30)],
               "wood_dark", opacity=0.55, clip_to=f"{name}_gable")
    west = [(-half, fe_y), (0, fa_y), (0, fa_y - back), (-half, fe_y - back)]
    east = [(half, fe_y), (0, fa_y), (0, fa_y - back), (half, fe_y - back)]
    a.add(f"{name}_west", [poly_abs(west)], "block", material, extrude=12)
    a.add(f"{name}_east", [poly_abs(east)], "block", material, extrude=12)
    import math as _m
    slant = _m.degrees(_m.atan2(fa_y - fe_y, half))
    for side, pts, down, rot in (("west", west, -1, slant), ("east", east, 1, -slant)):
        xs = [p[0] for p in pts]
        lines, shades = courses(min(xs), max(xs), fa_y - back - 40, fe_y + 10, step, dash, vertical=True, down=down,
                                dash_rot=rot)
        a.wash(f"{name}_{side}_shade", shades, "soot", opacity=0.28, clip_to=f"{name}_{side}")
        a.flat(f"{name}_{side}_joints", lines, "floor_joint", opacity=0.5, clip_to=f"{name}_{side}")
    a.wash(f"{name}_east_dark", [poly_abs(east)], "soot", opacity=0.3, clip_to=f"{name}_east")
    a.add(f"{name}_ridge", [R(0, fa_y - back / 2, 16, back + 6, 4)], "mass", timber, line=THIN)
    a.add(f"{name}_barge", [LINE(-half, fe_y, 0, fa_y, 11), LINE(half, fe_y, 0, fa_y, 11)], "mass", timber,
          line=THIN)
    return {"apex": apex, "fe_y": fe_y, "fa_y": fa_y, "back": back, "half": half}


def window(a, name, x, y, w, h, frame="wood_dark", shutters="wood", lit_tag="night", panes=(2, 2)):
    """Front-wall window centred at (x, y): frame, dark / lit glass, mullions, shutters, sill."""
    if shutters:
        a.flat(f"{name}_shutters", [R(x - w / 2 - w * 0.22, y, w * 0.42, h + 6, 3),
                                    R(x + w / 2 + w * 0.22, y, w * 0.42, h + 6, 3)], shutters, line=THIN)
        a.flat(f"{name}_shutter_slats", [R(x + s * (w / 2 + w * 0.22), y + (k - 2) * h / 5.5, w * 0.36, 2, 1)
                                         for s in (-1, 1) for k in range(5)], "wood_dark", opacity=0.6)
    a.flat(f"{name}_frame", [R(x, y, w + 12, h + 12, 3)], frame, line=THIN)
    a.add(f"{name}_glass", [R(x, y, w, h, 2)], "mass", "glass_dark", tags=["day"], shade={"bump": 0.4})
    a.flat(f"{name}_lit", [R(x, y, w, h, 2)], "window_lit", tags=[lit_tag], hidden=True, emit=0.9,
           glow={"radius": 10, "opacity": 0.45, "color": "window_glow"})
    bars = []
    for i in range(1, panes[0]):
        bars.append(R(x - w / 2 + w * i / panes[0], y, 4, h, 1))
    for j in range(1, panes[1]):
        bars.append(R(x, y - h / 2 + h * j / panes[1], w, 4, 1))
    if bars:
        a.flat(f"{name}_bars", bars, frame)
    a.box(f"{name}_sill", x, y + h / 2 + 14, w + 24, 12, 7, "wood_dark", corner=2)


def door(a, name, x, w, h, material="wood", frame="wood_dark", step=True):
    a.flat(f"{name}_frame", [R(x, -h / 2 - 4, w + 20, h + 10, 3)], frame, line=THIN)
    a.add(f"{name}_leaf", [R(x, -h / 2, w, h, 3)], "mass", material, shade={"bump": 0.35}, texture={"angle": 90})
    a.flat(f"{name}_joints", [R(x - w / 2 + w * k / 5, -h / 2, 2.2, h - 6, 1) for k in range(1, 5)], "wood_dark",
           opacity=0.55)
    a.flat(f"{name}_straps", [R(x - w * 0.18, -h * 0.78, w * 0.62, 10, 3), R(x - w * 0.18, -h * 0.24, w * 0.62, 10, 3)],
           "iron", line=THIN)
    a.flat(f"{name}_ring", [E(x + w * 0.3, -h * 0.48, 18, 18), E(x + w * 0.3, -h * 0.48, 11, 11, op="sub")], "iron",
           line=FINE)
    if step:
        a.box(f"{name}_step", x, 16, w + 36, 22, 8, "stone_dark", corner=3)


def night(a, lights):
    a.frame("day", state="day")
    a.frame("night", state="night", show=["night"], hide=["day"], light=lights)


# ============================================================================ A
@asset
def obj_house_medieval():
    a = Asset("obj_house_medieval", "Medieval cottage 3 x 2.8 m, gable facing south: stone footing, half-timbered "
              "plaster walls, plank door, two shuttered windows and a gable window, clay-tile roof (west slope lit, "
              "east slope in shade), stone chimney. Frames: day, night (lit windows, emit).", seed=801,
              pivot_meaning=BASE)
    W, D = 540, 440
    a.shadow([R(24, -230, W + 70, D + 40, 30)], opacity=0.38, blur=16)
    a.box("footing", 0, 6, W + 16, D + 12, 36, "rock", corner=6)
    wall = a.box("wall", 0, 0, W, D, 214, "plaster", lift=36, corner=4)
    top, bot = wall.top1, wall.bottom
    a.flat("timber", [R(x, wall.front_cy, 18, wall.h, 2) for x in (-262, -60, 262)] +
           [R(0, bot - 8, W, 14, 2), LINE(-250, bot - 14, -160, top + 12, 12), LINE(250, bot - 14, 160, top + 12, 12)],
           "wood_dark", line=THIN)
    door(a, "door", -150, 132, 196)
    window(a, "win0", 70, -150, 92, 80)
    window(a, "win1", 196, -150, 64, 80, shutters=None, panes=(2, 2))
    r = gable_front_roof(a, "roof", top, W, D, 190, "roof_tile")
    window(a, "win_gable", 0, top - 64, 54, 48, shutters=None, panes=(2, 1))
    x_ch, depth_ch = 150, 300
    z_ch = 190 + 214 + 36 - (190 + 21) * (x_ch / r["half"])
    ch = a.box("chimney", x_ch, -depth_ch, 72, 62, 190, "stone", lift=z_ch, corner=4)
    a.flat("chimney_masonry", [I("brick_wall", x_ch, ch.front_cy, 90, 190, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                               fit=[1.2, 1.2, 14.8, 14.8])], "floor_joint", opacity=0.45, clip_to="chimney")
    a.box("chimney_cap", x_ch, -depth_ch + 4, 86, 70, 12, "stone_dark", lift=z_ch + 190, corner=3)
    night(a, [{"color": WINDOW, "radius": 260, "at": [70, -150]}, {"color": WINDOW, "radius": 220, "at": [196, -150]},
              {"color": WINDOW, "radius": 200, "at": [0, top - 64]}])
    a.footprint = (-W / 2 - 8, -D - 6, W / 2 + 8, 6)
    return a


# ============================================================================ B
def side_roof(a, name, cx, front_y, D, wall_top, rise, width, material, ov=40, step=24, dash=36):
    """Ridge running east-west: front slope rectangle (seen from above), back strip, ridge beam.
    wall_top = screen y of the front wall's top edge."""
    eave = wall_top + ov
    ridge = wall_top - D / 2 - rise
    back = wall_top - D - ov
    a.add(f"{name}_back", [R(cx, (ridge + back) / 2, width - 8, max(ridge - back, 6), 3)], "block", material, extrude=5)
    if ridge - back > 30:
        bl, bs = courses(cx - width / 2 + 8, cx + width / 2 - 8, back, ridge, step, dash, down=-1)
        a.wash(f"{name}_back_shade", bs + [R(cx, (ridge + back) / 2, width, ridge - back, 3)], "soot", opacity=0.22,
               clip_to=f"{name}_back")
        a.flat(f"{name}_back_joints", bl, "floor_joint", opacity=0.45, clip_to=f"{name}_back")
    r = a.add(name, [R(cx, (eave + ridge) / 2, width, eave - ridge, 4)], "block", material, extrude=12)
    lines, shades = courses(cx - width / 2 + 4, cx + width / 2 - 4, ridge, eave, step, dash)
    a.wash(f"{name}_shade", shades, "soot", opacity=0.28, clip_to=name)
    a.flat(f"{name}_joints", lines, "floor_joint", opacity=0.5, clip_to=name)
    a.box(f"{name}_ridge", cx, ridge + 12, width + 8, 12, 12, "wood_dark", corner=3)
    return eave, ridge


@asset
def obj_shop_medieval():
    a = Asset("obj_shop_medieval", "Medieval shop 4 x 3 m, ridge east-west: stone ground floor with a wide shop window "
              "and counter hatch, wine awning, plank door, timbered plaster upper storey with two windows, slate "
              "roof, blank hanging board. Frames: day, night.", seed=811, pivot_meaning=BASE)
    W, D = 720, 468
    a.shadow([R(24, -220, W + 70, D + 30, 30)], opacity=0.38, blur=16)
    a.box("footing", 0, 6, W + 16, D + 12, 30, "rock", corner=6)
    low = a.box("ground_floor", 0, 0, W, D, 170, "stone", lift=30, corner=4)
    a.flat("masonry", [I("brick_wall", x, low.front_cy, 240, 180, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                         fit=[1.2, 1.2, 14.8, 14.8]) for x in (-240, 0, 240)], "floor_joint", opacity=0.35,
           clip_to="ground_floor")
    door(a, "door", -250, 124, 186)
    window(a, "shopwin", 60, -110, 250, 96, shutters=None, panes=(4, 2))
    a.box("counter", 60, 30, 290, 40, 22, "wood", lift=40, corner=3)
    a.add("awning", [POLY([(0, 0), (1, 0), (0.96, 1), (0.04, 1)], 60, -190, 330, 64)], "block", "cloth_wine", extrude=8)
    a.flat("awning_stripes", [R(-96 + 40 * k, -190, 18, 70, 2) for k in range(9)], "cloth_ochre", opacity=0.35,
           clip_to="awning")
    up = a.box("upper", 0, -16, W + 20, D, 150, "plaster", lift=200, corner=4)
    a.flat("upper_timber", [R(x, up.front_cy, 18, up.h, 2) for x in (-360, -120, 120, 360)] +
           [R(0, up.bottom - 8, W + 20, 14, 2), R(0, up.top1 + 8, W + 20, 12, 2)], "wood_dark", line=THIN)
    window(a, "upwin0", -240, up.front_cy, 84, 78)
    window(a, "upwin1", 240, up.front_cy, 84, 78)
    a.add("sign_arm", [LINE(250, up.front_cy + 30, 330, up.front_cy + 30, 6)], "mass", "iron")
    a.add("sign_board", [R(300, up.front_cy + 70, 70, 50, 5)], "mass", "wood", shade={"bump": 0.35})
    eave, ridge = side_roof(a, "roof", 0, 0, D, up.top1, 110, W + 90, "roof_slate")
    a.box("chimney", -230, -330, 70, 60, 170, "brick", lift=470, corner=4)
    a.box("chimney_cap", -230, -326, 84, 68, 10, "stone_dark", lift=640, corner=3)
    night(a, [{"color": WINDOW, "radius": 340, "at": [60, -110]},
              {"color": WINDOW, "radius": 220, "at": [-240, up.front_cy]},
              {"color": WINDOW, "radius": 220, "at": [240, up.front_cy]}])
    a.footprint = (-W / 2 - 8, -D - 6, W / 2 + 8, 6)
    return a


@asset
def obj_tower_mage():
    a = Asset("obj_tower_mage", "Mage tower about 12 m: round stone shaft on a plinth, arched door, slit and round "
              "windows, balcony ring, tall conical slate roof with a finial. Frames: day, night.", seed=812,
              pivot_meaning=BASE)
    dia = 300
    a.shadow([E(30, -140, 380, 300)], opacity=0.36, blur=16)
    a.cyl("plinth", 0, 0, dia + 40, 40, "rock")
    t = a.cyl("shaft", 0, -20, dia, 780, "stone", lift=40)
    a.flat("courses", [R(0, y, dia, 2.4, 1) for y in range(-100, -800, -36)], "floor_joint", opacity=0.35,
           clip_to="shaft")
    a.flat("shaft_shade", [R(110, -440, 90, 800, 20)], "soot", opacity=0.35, clip_to="shaft")
    a.flat("door_void", [I("bullet", 0, -110, 150, 100, rot=-90)], "hole")
    a.add("door_leaf", [I("bullet", 0, -104, 140, 90, rot=-90)], "mass", "wood", shade={"bump": 0.3},
          texture={"angle": 90})
    a.flat("door_bands", [R(0, y, 90, 8, 2) for y in (-150, -80)], "iron", line=FINE, clip_to="door_leaf")
    wins = [(-60, -340, 22, 60), (70, -470, 22, 60), (-20, -600, 22, 60)]
    lights = []
    for i, (x, y, w, h) in enumerate(wins):
        a.flat(f"slit{i}_frame", [I("bullet", x, y, h + 12, w + 12, rot=-90)], "stone_dark", line=THIN)
        a.add(f"slit{i}", [I("bullet", x, y, h, w, rot=-90)], "mass", "glass_dark", tags=["day"])
        a.flat(f"slit{i}_lit", [I("bullet", x, y, h, w, rot=-90)], "window_lit", tags=["night"], hidden=True, emit=0.9,
               glow={"radius": 8, "opacity": 0.45, "color": "window_glow"})
        lights.append({"color": WINDOW, "radius": 180, "at": [x, y]})
    a.cyl("balcony", 0, -40, dia + 60, 16, "stone_dark", lift=720)
    a.flat("rail", [R(x, -770, 6, 40, 2) for x in range(-160, 170, 32)], "iron")
    a.flat("rail_top", [R(0, -790, dia + 56, 5, 2)], "iron")
    a.flat("round_win_frame", [E(0, -700, 70, 70)], "stone_dark", line=THIN)
    a.add("round_win", [E(0, -700, 56, 56)], "mass", "glass_dark", tags=["day"])
    a.flat("round_win_lit", [E(0, -700, 56, 56)], "window_lit", tags=["night"], hidden=True, emit=0.9,
           glow={"radius": 10, "opacity": 0.5, "color": "window_glow"})
    lights.append({"color": WINDOW, "radius": 240, "at": [0, -700]})
    a.flat("round_win_bars", [R(0, -700, 4, 56, 1), R(0, -700, 56, 4, 1)], "stone_dark")
    cone = [(0.5, 0.0), (1.0, 0.92), (0.8, 1.0), (0.2, 1.0), (0.0, 0.92)]
    a.add("roof", [POLY(cone, 0, -1010, dia + 90, 420)], "mass", "roof_slate", shade={"bump": 0.8})
    lines = [LINE(0, -1220, x, -810, 2.4) for x in range(-150, 170, 38)]
    a.flat("roof_seams", lines, "floor_joint", opacity=0.45, clip_to="roof")
    a.flat("roof_rings", [R(0, y, 400, 2.2, 1) for y in range(-1180, -800, 44)], "floor_joint", opacity=0.3,
           clip_to="roof")
    a.add("finial", [R(0, -1236, 8, 40, 2), I("star", 0, -1262, 26)], "mass", "gold", line=FINE)
    night(a, lights)
    a.footprint = (-dia / 2 - 20, -(dia + 40) * SQ, dia / 2 + 20, 0)
    return a


@asset
def obj_church_gothic():
    a = Asset("obj_church_gothic", "Small gothic church: tall gable front facing south with a pointed arch door, rose "
              "window and lancet windows, buttresses, bell tower with a spire on the west side (no religious "
              "emblem). Frames: day, night.", seed=813, pivot_meaning=BASE)
    W, D = 600, 700
    a.shadow([R(40, -330, W + 360, D + 60, 40)], opacity=0.38, blur=18)
    # tower (west)
    tw = a.box("tower", -360, 10, 200, 200, 520, "stone", corner=4)
    a.flat("tower_courses", [R(-360, y, 200, 2.4, 1) for y in range(-60, -520, -40)], "floor_joint", opacity=0.35,
           clip_to="tower")
    a.flat("belfry_void", [I("bullet", -360, -440, 120, 80, rot=-90)], "hole")
    a.flat("bell", [I("bell", -360, -432, 50)], "bronze", line=FINE)
    spire = [(0.5, 0.0), (1.0, 1.0), (0.0, 1.0)]
    a.add("spire", [POLY(spire, -360, -870, 230, 460)], "mass", "roof_slate", shade={"bump": 0.7})
    a.flat("spire_seams", [LINE(-360, -1100, x, -640, 2.4) for x in range(-470, -240, 40)], "floor_joint", opacity=0.4,
           clip_to="spire")
    a.add("spire_tip", [R(-360, -1116, 8, 36, 2), E(-360, -1136, 16, 16)], "mass", "gold", line=FINE)
    # nave
    a.box("footing", 0, 6, W + 16, D + 12, 30, "rock", corner=6)
    wall = a.box("nave", 0, 0, W, D, 250, "stone", lift=30, corner=4)
    a.flat("nave_courses", [R(0, y, W, 2.4, 1) for y in range(-70, -280, -40)], "floor_joint", opacity=0.3,
           clip_to="nave")
    for i, x in enumerate((-W / 2 - 14, W / 2 + 14)):
        a.box(f"buttress{i}", x, 16, 40, 60, 200, "stone_dark", corner=3)
    r = gable_front_roof(a, "roof", wall.top1, W, D, 300, "roof_slate", gable="stone", timber="stone_dark",
                         timbered=False)
    a.flat("door_arch", [POLY([(0, 1), (0, 0.4), (0.5, 0), (1, 0.4), (1, 1)], 0, -118, 150, 236)], "stone_dark",
           line=THIN)
    a.add("door", [POLY([(0, 1), (0, 0.4), (0.5, 0), (1, 0.4), (1, 1)], 0, -110, 124, 216)], "mass", "wood",
          shade={"bump": 0.3}, texture={"angle": 90})
    a.flat("door_split", [R(0, -96, 3, 180, 1)], "wood_dark", clip_to="door")
    lights = []
    for i, x in enumerate((-190, 190)):
        a.flat(f"lancet{i}_frame", [POLY([(0, 1), (0, 0.35), (0.5, 0), (1, 0.35), (1, 1)], x, -150, 62, 150)],
               "stone_dark", line=THIN)
        a.add(f"lancet{i}", [POLY([(0, 1), (0, 0.35), (0.5, 0), (1, 0.35), (1, 1)], x, -148, 46, 134)], "mass",
              "glass_dark", tags=["day"])
        a.flat(f"lancet{i}_lit", [POLY([(0, 1), (0, 0.35), (0.5, 0), (1, 0.35), (1, 1)], x, -148, 46, 134)],
               "window_lit", tags=["night"], hidden=True, emit=0.9,
               glow={"radius": 9, "opacity": 0.45, "color": "window_glow"})
        lights.append({"color": WINDOW, "radius": 220, "at": [x, -148]})
    ry = wall.top1 - 110
    a.flat("rose_frame", [E(0, ry, 130, 130)], "stone_dark", line=THIN)
    a.add("rose", [E(0, ry, 110, 110)], "mass", "glass_dark", tags=["day"])
    a.flat("rose_lit", [E(0, ry, 110, 110)], "window_lit", tags=["night"], hidden=True, emit=0.9,
           glow={"radius": 12, "opacity": 0.5, "color": "window_glow"})
    a.flat("rose_tracery", [I("flower", 0, ry, 96, crop=[1, 1, 15, 11.4]), E(0, ry, 24, 24)], "stone_dark",
           opacity=0.8, line=FINE)
    lights.append({"color": WINDOW, "radius": 300, "at": [0, ry]})
    night(a, lights)
    a.footprint = (-470, -D - 6, W / 2 + 34, 16)
    return a


@asset
def obj_barn():
    a = Asset("obj_barn", "Timber barn / storehouse 5 x 4 m, gable facing south: vertical board walls, big double "
              "doors with cross braces, hay loft door, shingle roof. Frames: closed, open (doors swung out, hay "
              "inside).", seed=814, pivot_meaning=BASE)
    W, D = 720, 620
    a.shadow([R(30, -300, W + 80, D + 40, 30)], opacity=0.38, blur=16)
    a.box("footing", 0, 6, W + 16, D + 12, 24, "rock", corner=6)
    wall = a.box("wall", 0, 0, W, D, 250, "wood", lift=24, corner=4)
    a.flat("boards", [R(x, wall.front_cy, 2.4, wall.h, 1) for x in range(-340, 360, 30)], "wood_dark", opacity=0.55,
           clip_to="wall")
    a.flat("door_void", [R(0, -118, 300, 236, 3)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -236, "y1": 0})
    a.add("hay", [I("cloud", -60, -40, 150, 70), I("cloud", 60, -30, 130, 60, flip="x"), I("grass", 0, -80, 120, 60)],
          "mass", "thatch", tags=["open"], hidden=True, clip_to="door_void", rough={"amp": 0.5, "soft": 1.2, "cell": 5})
    for i, x in enumerate((-75, 75)):
        a.add(f"door{i}", [R(x, -118, 148, 232, 3)], "mass", "wood_pale", tags=["closed"], shade={"bump": 0.3},
              texture={"angle": 90})
        a.flat(f"door{i}_brace", [R(x, -118, 148, 232, 3), R(x, -118, 124, 208, 2, op="sub"),
                                  LINE(x - 60, -18, x + 60, -218, 12)], "wood_dark", tags=["closed"], line=FINE)
    for i, (x, pts) in enumerate(((-190, [(1, 0), (1, 0.76), (0, 1), (0, 0.24)]),
                                  (190, [(0, 0), (0, 0.76), (1, 1), (1, 0.24)]))):
        a.add(f"door_open{i}", [POLY(pts, x, -118 + 36, 80, 236 + 72)], "mass", "wood_pale", tags=["open"],
              hidden=True, shade={"bump": 0.3})
    r = gable_front_roof(a, "roof", wall.top1, W, D, 280, "wood_dark", gable="wood", timber="wood_dark", step=22,
                         dash=30, timbered=False, boards=True)
    a.flat("loft_frame", [R(0, wall.top1 - 90, 110, 110, 3)], "wood_dark", line=THIN)
    a.add("loft_door", [R(0, wall.top1 - 90, 90, 92, 3)], "mass", "wood_pale", shade={"bump": 0.3})
    a.flat("loft_brace", [LINE(-40, wall.top1 - 50, 40, wall.top1 - 130, 8)], "wood_dark")
    a.add("hoist", [LINE(0, wall.top1 - 170, 0, wall.top1 - 230, 10), LINE(-4, wall.top1 - 226, 40, wall.top1 - 226, 8)],
          "mass", "wood_dark")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    a.footprint = (-W / 2 - 8, -D - 6, W / 2 + 8, 6)
    return a


@asset
def obj_windmill():
    a = Asset("obj_windmill", "Tower windmill about 9 m: tapering whitewashed stone tower, small door and windows, "
              "conical thatched cap, four lattice sails facing south.", seed=815, pivot_meaning=BASE)
    a.shadow([E(30, -130, 420, 280)], opacity=0.36, blur=16)
    tower = [(0.18, 0.0), (0.82, 0.0), (1.0, 1.0), (0.0, 1.0)]
    a.add("tower", [POLY(tower, 0, -300, 340, 600)], "mass", "plaster_pale", shade={"bump": 0.6})
    a.flat("tower_courses", [R(0, y, 360, 2.4, 1) for y in range(-60, -600, -48)], "floor_joint", opacity=0.3,
           clip_to="tower")
    a.flat("tower_shade", [POLY([(0.55, 0), (0.82, 0), (1.0, 1.0), (0.66, 1.0)], 0, -300, 340, 600)], "soot",
           opacity=0.28, clip_to="tower")
    a.box("step", 0, 14, 150, 30, 10, "stone_dark", corner=3)
    a.flat("door_frame", [I("bullet", 0, -86, 180, 110, rot=-90)], "wood_dark", line=THIN)
    a.add("door", [I("bullet", 0, -82, 168, 96, rot=-90)], "mass", "wood", texture={"angle": 90})
    a.flat("windows", [R(-50, -330, 34, 46, 3), R(40, -450, 30, 40, 3)], "glass_dark", line=THIN)
    a.add("cap", [POLY([(0.5, 0), (1, 0.8), (0.9, 1), (0.1, 1), (0, 0.8)], 0, -680, 280, 170)], "mass", "thatch",
          shade={"bump": 0.8})
    hub = (0, -640)
    sails = []
    frames = []
    for ang in (45, 135, 225, 315):
        r = math.radians(ang)
        ex, ey = hub[0] + math.cos(r) * 330, hub[1] + math.sin(r) * 330 * 0.9
        frames.append(LINE(hub[0], hub[1], ex, ey, 10))
        mx, my = hub[0] + math.cos(r) * 200, hub[1] + math.sin(r) * 200 * 0.9
        sails.append(R(mx + math.cos(r + math.pi / 2) * 30, my + math.sin(r + math.pi / 2) * 30 * 0.9, 250, 56, 3,
                       rot=ang))
    a.add("sails", sails, "mass", "cloth_pale", shade={"bump": 0.4}, opacity=0.95)
    lattice = []
    for s in sails:
        for k in range(-2, 3):
            lattice.append(R(s["at"][0] + math.cos(math.radians(s["rot"])) * k * 50,
                             s["at"][1] + math.sin(math.radians(s["rot"])) * k * 50 * 0.9, 3, 56, 1, rot=s["rot"]))
    a.flat("sail_lattice", lattice, "wood_dark", opacity=0.6, clip_to="sails")
    a.add("stocks", frames, "mass", "wood_dark")
    a.add("hub", [E(hub[0], hub[1], 44, 44)], "mass", "wood_dark", line=THIN)
    a.footprint = (-170, -300, 170, 0)
    return a


@asset
def obj_house_east():
    a = Asset("obj_house_east", "Eastern tiled house (hanok / machiya style mix) 5 x 3.5 m, ridge east-west: stone base "
              "with steps, dark timber frame, lattice paper doors, curved dark-tile roof with upturned eaves. Frames: "
              "day, night (paper doors lit, emit).", seed=816, pivot_meaning=BASE)
    W, D = 820, 540
    a.shadow([R(24, -250, W + 90, D + 40, 30)], opacity=0.38, blur=16)
    a.box("base", 0, 20, W + 60, D + 60, 50, "rock", corner=6)
    a.box("steps", 0, 44, 220, 40, 24, "stone_dark", corner=3)
    wall = a.box("wall", 0, 0, W, D, 210, "plaster_pale", lift=50, corner=4)
    posts = [R(x, wall.front_cy, 22, wall.h, 2) for x in (-400, -200, 0, 200, 400)]
    a.flat("posts", posts + [R(0, wall.top1 + 10, W, 18, 2), R(0, wall.bottom - 8, W, 14, 2)], "wood_dark", line=THIN)
    lights = []
    for i, x in enumerate((-300, -100, 100, 300)):
        a.add(f"paper{i}", [R(x, wall.front_cy + 6, 170, 170, 2)], "mass", "cloth_pale", tags=["day"],
              shade={"bump": 0.2})
        a.flat(f"paper{i}_lit", [R(x, wall.front_cy + 6, 170, 170, 2)], "window_lit", tags=["night"], hidden=True,
               emit=0.8, glow={"radius": 10, "opacity": 0.4, "color": "window_glow"})
        a.flat(f"lattice{i}", [I("grid_fine", x, wall.front_cy + 6, 170, 170, crop=[1, 1, 15, 15])], "wood_dark",
               opacity=0.85)
        lights.append({"color": WINDOW, "radius": 220, "at": [x, wall.front_cy + 6]})
    eave = wall.top1 + 60
    ridge = wall.top1 - D / 2 - 180
    back = wall.top1 - D - 60
    a.add("roof_back", [R(0, (ridge + back) / 2, W + 150, max(ridge - back, 6), 3)], "block", "roof_slate", extrude=5)
    roof = [(0.0, 1.0), (0.04, 0.82), (0.1, 0.72), (0.9, 0.72), (0.96, 0.82), (1.0, 1.0), (0.92, 0.95), (0.5, 0.97),
            (0.08, 0.95)]
    a.add("roof", [R(0, (eave + ridge) / 2 - 16, W + 150, eave - ridge - 32, 6),
                   POLY(roof, 0, eave - 60, W + 190, 120)], "block", "roof_slate", extrude=12)
    ridges, shades = [], []
    for x in range(-(W + 150) // 2 + 20, (W + 150) // 2, 26):
        ridges.append(R(x, (eave + ridge) / 2, 9, eave - ridge, 4))
    a.add("roof_tiles", ridges, "mass", "roof_slate", clip_to="roof", line=FINE, shade={"bump": 0.9})
    a.box("roof_ridge", 0, ridge + 20, W + 170, 24, 26, "roof_slate", corner=6)
    a.add("ridge_ends", [I("wave", -(W + 170) / 2, ridge - 22, 50, 40), I("wave", (W + 170) / 2, ridge - 22, 50, 40,
                                                                          flip="x")], "mass", "roof_slate", line=FINE)
    night(a, lights)
    a.footprint = (-W / 2 - 30, -D - 40, W / 2 + 30, 20)
    return a


# ============================================================================ C
@asset
def obj_watermill():
    a = Asset("obj_watermill", "Watermill: small stone mill house with its gable facing south, big wooden water wheel "
              "on the east side turning in a stone channel of dark water.", seed=821, pivot_meaning=BASE)
    W, D = 480, 400
    a.shadow([R(80, -200, W + 260, D + 30, 30)], opacity=0.38, blur=16)
    a.box("channel", 320, 20, 120, 330, 30, "stone_dark", corner=4)
    a.flat("water", [R(320, -150, 90, 300, 4)], "water", line=FINE)
    a.flat("water_streaks", [R(320 + dx, -150, 3, 290, 1) for dx in (-30, -10, 10, 30)], "chrome", opacity=0.25,
           clip_to="water")
    a.box("footing", 0, 6, W + 16, D + 12, 30, "rock", corner=6)
    wall = a.box("wall", 0, 0, W, D, 220, "stone", lift=30, corner=4)
    a.flat("masonry", [I("brick_wall", x, wall.front_cy, 250, 230, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                         fit=[1.2, 1.2, 14.8, 14.8]) for x in (-120, 120)], "floor_joint", opacity=0.35,
           clip_to="wall")
    door(a, "door", -90, 120, 180)
    window(a, "win", 110, -150, 80, 70)
    gable_front_roof(a, "roof", wall.top1, W, D, 190, "thatch", gable="plaster", step=20, dash=28)
    cx, cy = 320, -170
    a.add("wheel_back", [E(cx, cy - 20, 250, 250), E(cx, cy - 20, 206, 206, op="sub")], "mass", "wood_dark")
    paddles = []
    for k in range(12):
        t = 2 * math.pi * k / 12
        paddles.append(R(cx + math.cos(t) * 116, cy + math.sin(t) * 116, 44, 16, 3, rot=math.degrees(t)))
    a.add("paddles", paddles, "mass", "wood")
    a.add("wheel", [E(cx, cy, 250, 250), E(cx, cy, 210, 210, op="sub")], "mass", "wood", shade={"bump": 0.7})
    a.flat("spokes", [LINE(cx - math.cos(math.radians(a_)) * 104, cy - math.sin(math.radians(a_)) * 104,
                           cx + math.cos(math.radians(a_)) * 104, cy + math.sin(math.radians(a_)) * 104, 9)
                      for a_ in (0, 45, 90, 135)], "wood_dark", line=FINE)
    a.add("hub", [E(cx, cy, 44, 44)], "mass", "iron", line=THIN)
    a.footprint = (-W / 2 - 8, -D - 6, 385, 20)
    return a


@asset
def obj_saloon():
    a = Asset("obj_saloon", "Western saloon 5 m wide: tall plank false front with a blank sign board, covered "
              "boardwalk porch on posts, swinging half doors, two windows, upper balcony door. Frames: day, night.",
              seed=822, pivot_meaning=BASE)
    W, D = 820, 520
    a.shadow([R(24, -240, W + 80, D + 40, 30)], opacity=0.38, blur=16)
    a.box("body_roof", 0, -40, W - 20, D - 40, 12, "wood_dark", lift=320, corner=4)
    wall = a.box("wall", 0, 0, W, D, 330, "wood", lift=20, corner=4)
    a.flat("boards", [R(0, y, W, 2.4, 1) for y in range(-40, -350, -24)], "wood_dark", opacity=0.5, clip_to="wall")
    front = [(0, 1), (0, 0.18), (0.1, 0.18), (0.1, 0.06), (0.3, 0.06), (0.3, 0.0), (0.7, 0.0), (0.7, 0.06), (0.9, 0.06),
             (0.9, 0.18), (1, 0.18), (1, 1)]
    a.add("false_front", [POLY(front, 0, -480, W + 20, 200)], "mass", "wood_pale", shade={"bump": 0.2},
          texture={"angle": 0})
    a.flat("false_front_boards", [R(0, y, W + 20, 2.4, 1) for y in range(-420, -560, -22)], "wood_dark", opacity=0.45,
           clip_to="false_front")
    a.flat("cornice", [R(0, -574, 0.4 * (W + 20), 10, 2), R(-0.3 * (W + 20), -562, 0.2 * (W + 20), 9, 2),
                       R(0.3 * (W + 20), -562, 0.2 * (W + 20), 9, 2), R(-0.45 * (W + 20), -538, 0.1 * (W + 20), 8, 2),
                       R(0.45 * (W + 20), -538, 0.1 * (W + 20), 8, 2)], "wood_dark", line=FINE)
    a.flat("sign", [R(0, -470, 380, 70, 4)], "cloth_ochre", line=THIN)
    a.flat("sign_frame", [R(0, -470, 380, 70, 4), R(0, -470, 360, 54, 3, op="sub")], "wood_dark")
    lights = []
    for i, x in enumerate((-260, 260)):
        window(a, f"win{i}", x, -130, 110, 100, shutters=None, panes=(2, 3))
        lights.append({"color": WINDOW, "radius": 260, "at": [x, -130]})
    a.flat("door_void", [R(0, -110, 150, 200, 3)], "hole")
    for i, x in enumerate((-37, 37)):
        a.add(f"batwing{i}", [R(x, -120, 70, 90, 6)], "mass", "wood_pale", shade={"bump": 0.4})
        a.flat(f"batwing{i}_slats", [R(x, -120 + k * 14 - 28, 60, 3, 1) for k in range(5)], "wood_dark", opacity=0.6)
    window(a, "balcony_door", 0, -290, 90, 110, shutters=None, panes=(2, 3))
    lights.append({"color": WINDOW, "radius": 220, "at": [0, -290]})
    a.box("balcony", 0, 40, W - 60, 60, 10, "wood_dark", lift=224, corner=3)
    a.flat("balcony_rail", [R(x, -262, 5, 36, 2) for x in range(-360, 380, 30)] + [R(0, -280, W - 60, 6, 2)],
           "wood_dark")
    a.box("porch_floor", 0, 60, W + 40, 100, 20, "wood_dark", corner=3)
    for i, x in enumerate((-390, -130, 130, 390)):
        a.box(f"porch_post{i}", x, 56, 16, 14, 204, "wood", lift=20, corner=2)
    a.box("porch_roof", 0, 70, W + 60, 110, 12, "wood_dark", lift=212, corner=3)
    night(a, lights)
    a.footprint = (-W / 2 - 20, -D - 6, W / 2 + 20, 60)
    return a


@asset
def obj_shack():
    a = Asset("obj_shack", "Post-apocalypse shack 3 x 2.5 m: patchwork of rusty corrugated sheets and planks, lean-to "
              "roof of metal sheets and a blue tarp, boarded window, crooked door, stove pipe, junk at the wall.",
              seed=823, pivot_meaning=BASE)
    W, D = 540, 390
    a.shadow([R(24, -190, W + 70, D + 30, 24)], opacity=0.38, blur=14)
    wall = a.box("wall", 0, 0, W, D, 230, "steel", corner=4)
    a.flat("ribs", [R(x, wall.front_cy, 5, 230, 2) for x in range(-250, 260, 18)], "steel_light", opacity=0.4,
           clip_to="wall")
    a.add("patch_planks", [R(-150, -140, 150, 150, 3)], "mass", "wood_pale", texture={"angle": 90})
    a.flat("patch_joints", [R(-150 + dx, -140, 2.2, 148, 1) for dx in (-50, -18, 14, 46)], "wood_dark", opacity=0.6)
    a.wash("rust", [I("metaballs", 140, -120, 220, 180), I("cloud", -40, -40, 200, 60)], "rust", opacity=0.55, blur=5,
           clip_to="wall")
    a.flat("window_boards", [R(-150, -150, 90, 70, 3)], "hole")
    a.add("boards_x", [LINE(-196, -186, -104, -114, 12), LINE(-196, -114, -104, -186, 12)], "mass", "wood")
    a.add("door", [POLY([(0.05, 0), (1, 0.04), (0.95, 1), (0, 0.98)], 110, -94, 110, 188)], "mass", "wood_dark",
          texture={"angle": 90})
    a.flat("door_handle", [R(146, -96, 6, 16, 2)], "iron")
    roof = [(0.0, 0.0), (1.0, 0.12), (1.0, 1.0), (0.0, 0.92)]
    a.add("roof", [POLY(roof, 0, -230 - D / 2 - 30, W + 80, D * 0.9)], "block", "steel", extrude=10)
    a.flat("roof_ribs", [R(x, -230 - D / 2 - 30, 5, D * 0.9, 2) for x in range(-300, 310, 22)], "steel_light",
           opacity=0.35, clip_to="roof")
    a.add("tarp", [POLY([(0, 0.1), (0.9, 0), (1, 0.8), (0.1, 1)], -120, -300, 260, 160)], "mass", "cloth_blue",
          shade={"bump": 0.6})
    a.wash("roof_rust", [I("sponge", 150, -340, 200, 120)], "rust", opacity=0.45, blur=4, clip_to="roof")
    a.box("pipe", 190, -250, 22, 18, 120, "iron", lift=230, corner=6)
    a.add("junk", [E(-250, -10, 70, 40), E(-250, -10, 34, 18, op="sub"), R(250, -24, 50, 48, 4)], "mass", "rubber",
          line=THIN)
    a.footprint = (-W / 2, -D, W / 2, 0)
    return a


@asset
def obj_sf_habitat():
    a = Asset("obj_sf_habitat", "SF habitat module 4 m: rounded pale steel capsule on landing struts, porthole band, "
              "airlock door with ramp, antenna dish and a solar panel. Frames: day, night (portholes and door strip "
              "lit, emit).", seed=824, pivot_meaning=BASE)
    a.shadow([E(30, -150, 820, 320)], opacity=0.36, blur=16)
    for x in (-270, -90, 90, 270):
        a.add(f"strut_{x}", [LINE(x, -10, x * 0.8, -100, 12)], "mass", "steel")
        a.add(f"foot_{x}", [E(x, -8, 36, 16)], "mass", "steel", line=FINE)
    a.add("hull", [R(0, -230, 660, 280, 130)], "mass", "steel_light", shade={"bump": 1.1})
    a.flat("seams", [R(x, -230, 3, 270, 1) for x in (-200, 0, 200)] + [R(0, -170, 640, 3, 1)], "soot", opacity=0.4,
           clip_to="hull")
    a.flat("band", [R(0, -236, 640, 40, 6)], "steel", opacity=0.9, clip_to="hull")
    lights = []
    for i, x in enumerate((-230, -140, 140, 230)):
        a.flat(f"port{i}_frame", [E(x, -236, 42, 32)], "steel", line=FINE)
        a.add(f"port{i}", [E(x, -236, 30, 22)], "mass", "glass_dark", tags=["day"])
        a.flat(f"port{i}_lit", [E(x, -236, 30, 22)], "screen_on", tags=["night"], hidden=True, emit=0.9,
               glow={"radius": 6, "opacity": 0.5, "color": "screen_glow"})
        lights.append({"color": "#7ed0c8", "radius": 180, "at": [x, -236]})
    a.flat("door_frame", [R(0, -150, 120, 170, 20)], "steel", line=THIN)
    a.add("door", [R(0, -150, 96, 150, 16)], "mass", "steel_light", shade={"bump": 0.4})
    a.flat("door_strip_off", [R(0, -236, 60, 6, 2)], "signal_off", tags=["day"])
    a.flat("door_strip_on", [R(0, -236, 60, 6, 2)], "signal_amber", tags=["night"], hidden=True, emit=1.0,
           glow={"radius": 5, "opacity": 0.6, "color": "signal_amber_glow"})
    a.add("ramp", [POLY([(0.1, 0), (0.9, 0), (1, 1), (0, 1)], 0, -40, 130, 80)], "block", "steel", extrude=6)
    a.add("dish", [LINE(220, -370, 240, -420, 6), E(250, -440, 80, 40, rot=-20)], "mass", "steel_light", line=THIN)
    a.add("panel", [R(-200, -400, 180, 70, 4, skew=[10, 0])], "mass", "cloth_blue", shade={"bump": 0.3})
    a.flat("panel_grid", [I("grid_fine", -200, -400, 170, 60, crop=[1, 1, 15, 15], skew=[10, 0])], "steel", opacity=0.7)
    a.flat("panel_mast", [R(-200, -358, 6, 30, 2)], "steel")
    night(a, lights)
    a.footprint = (-330, -300, 330, 0)
    return a


@asset
def obj_lighthouse():
    a = Asset("obj_lighthouse", "Lighthouse about 14 m (pirate / sea): rock base, tapering tower with wine and bone "
              "bands, small door and windows, gallery with railing, glazed lantern room, dark cap. Frames: off, on "
              "(lamp lit, emit).", seed=825, pivot_meaning=BASE)
    a.shadow([E(30, -120, 420, 260)], opacity=0.36, blur=16)
    a.add("rocks", [POLY([(0, 0.7), (0.15, 0.2), (0.45, 0.0), (0.8, 0.1), (1, 0.6), (0.85, 1), (0.1, 1)], 0, -40, 400,
                         110)], "mass", "rock_dark", shade={"bump": 1.0})
    tower = [(0.24, 0.0), (0.76, 0.0), (1.0, 1.0), (0.0, 1.0)]
    a.add("tower", [POLY(tower, 0, -520, 250, 920)], "mass", "plaster_pale", shade={"bump": 0.6})
    a.flat("bands", [R(0, y, 300, 110, 2) for y in (-260, -520, -780)], "cloth_wine", opacity=0.9, clip_to="tower")
    a.flat("tower_shade", [POLY([(0.55, 0.0), (0.76, 0.0), (1.0, 1.0), (0.66, 1.0)], 0, -520, 250, 920)], "soot",
           opacity=0.28, clip_to="tower")
    a.flat("door", [I("bullet", 0, -110, 110, 60, rot=-90)], "wood_dark", line=THIN)
    a.flat("windows", [R(20, -420, 24, 36, 3), R(-16, -660, 22, 32, 3)], "glass_dark", line=THIN)
    g = a.cyl("gallery", 0, -980 + 10, 190, 14, "iron", lift=0)
    a.flat("rail", [R(x, -1000, 4, 30, 1) for x in range(-90, 100, 18)] + [R(0, -1014, 190, 5, 2)], "iron")
    a.add("lantern_off", [R(0, -1040, 110, 80, 10)], "mass", "glass_dark", tags=["off"])
    a.add("lantern_on", [R(0, -1040, 110, 80, 10)], "mass", "glass", tags=["on"], hidden=True, emit=0.95,
          glow={"radius": 16, "opacity": 0.6, "color": "lamp_glow"})
    a.flat("mullions", [R(x, -1040, 5, 80, 1) for x in (-36, 0, 36)], "iron")
    a.add("cap", [POLY([(0.5, 0), (1, 1), (0, 1)], 0, -1110, 140, 70), E(0, -1150, 16, 16)], "mass", "iron")
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": "#ffc987", "radius": 900, "at": [0, -1040]})
    a.footprint = (-140, -60, 140, 0)
    return a


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
