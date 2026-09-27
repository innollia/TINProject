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
                     timber="wood_dark"):
    """Gable facing the viewer.  wall_top = screen y of the front wall's top edge (centre x = 0)."""
    half = W / 2 + ov_s
    drop = ov_s * rise / (W / 2)
    apex = wall_top - rise
    fe_y = wall_top + drop + ov_f           # front eave corners
    fa_y = apex + ov_f                      # front apex
    back = D + 2 * ov_f
    a.add(f"{name}_gable", [poly_abs([(-W / 2, wall_top), (0, apex), (W / 2, wall_top)])], "mass", gable,
          shade={"bump": 0.2, "highlight_amount": 0.1})
    a.flat(f"{name}_gable_timber", [LINE(-W / 2 + 10, wall_top - 6, 0, apex + 10, 12),
                                   LINE(W / 2 - 10, wall_top - 6, 0, apex + 10, 12),
                                   R(0, (wall_top + apex) / 2 + 20, 14, rise - 30, 2),
                                   R(0, wall_top - 8, W, 14, 2)], timber, line=THIN, clip_to=f"{name}_gable")
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


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
