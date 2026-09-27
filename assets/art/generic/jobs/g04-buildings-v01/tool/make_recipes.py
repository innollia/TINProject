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


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
