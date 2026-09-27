"""g04-exterior-v01 recipes: fences, wells, lamps, signs, carts, benches, graves, campfires, water and
street objects.

    python -B make_recipes.py              # write every recipe into ../recipes
    python -B make_recipes.py obj_well     # only these

Fire boundary: the campfire shows glowing logs / coals only; anchors.flame_anchor marks where the
game adds the flame effect (g01 / g02).  Lamps in glass show their own lit glass (emit).
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
WALL = "centre of the wall plate = attach point on the wall face"
LAMP = "#ffc987"
FLAME = "#ffb45c"


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


def tile_rows(y0, y1, x0, x1, row_h=22, dash=34):
    """Joint pieces for tiled / slated roof slopes (rows + staggered joints)."""
    pieces = []
    y = y0 + row_h
    k = 0
    while y < y1:
        pieces.append(R((x0 + x1) / 2, y, x1 - x0, 2.4, 1))
        off = (dash / 2) if k % 2 else 0
        x = x0 + off + dash
        while x < x1 - 4:
            pieces.append(R(x, y - row_h / 2, 2.2, row_h - 3, 1))
            x += dash
        y += row_h
        k += 1
    return pieces


# ============================================================================ A
def _fence_post(a, name, x, y, h=116, tags=None, hidden=False):
    b = a.box(name, x, y, 15, 13, h, "wood", corner=3, tags=tags, hidden=hidden)
    a.add(f"{name}_cap", [I("triangle", x, b.top_cy - 5, 17, 12)], "mass", "wood", line=FINE, tags=tags,
          hidden=hidden)
    return b


@asset
def obj_fence_wood():
    a = Asset("obj_fence_wood", "Rustic wooden fence segment 2 m long (east-west): three posts, two rails. Frames: "
              "normal, broken (top rail snapped and hanging, middle post leaning, a plank on the ground). Tile the "
              "segment every 352 px; the vertical run is obj_fence_wood_v.", seed=701,
              pivot_meaning="middle post base on the ground")
    a.shadow([R(6, -3, 372, 18, 8)], opacity=0.32, blur=6)
    a.box("rail_low", 0, -5, 352, 6, 12, "wood", lift=34, corner=3)
    a.box("rail_top", 0, -5, 352, 6, 12, "wood", lift=78, corner=3, tags=["whole"])
    a.box("rail_top_l", -88, -5, 176, 6, 12, "wood", lift=78, corner=3, tags=["broken"], hidden=True)
    a.add("rail_hang", [LINE(10, -86, 150, -30, 12)], "mass", "wood", tags=["broken"], hidden=True,
          texture={"angle": 22})
    a.add("plank_ground", [R(120, 14, 110, 12, 3, rot=-6, ground=True)], "block", "wood", extrude=4, line=THIN,
          tags=["broken"], hidden=True)
    for i, x in enumerate((-176, 176)):
        _fence_post(a, f"post{i}", x, 0)
    _fence_post(a, "post_mid", 0, 0, tags=["whole"])
    a.add("post_lean", [R(10, -56, 15, 116, 3, rot=12)], "mass", "wood", tags=["broken"], hidden=True,
          texture={"angle": 100})
    a.flat("nails", rivets([(x, y) for x in (-176, 176) for y in (-40, -84)], 4), "iron")
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    return a


@asset
def obj_fence_wood_v():
    a = Asset("obj_fence_wood_v", "The same rustic fence running north-south (2 m): posts at the ends and middle, rails "
              "seen from above as thin strips. Tile every 312 px along y.", seed=702,
              pivot_meaning="south (front) post base on the ground")
    a.shadow([R(6, -156, 22, 330, 8)], opacity=0.32, blur=6)
    for i, y in enumerate((-312, -156)):
        _fence_post(a, f"post{i}", 0, y)
    a.box("rail_low", 0, -6, 6, 300, 12, "wood", lift=34, corner=2)
    a.box("rail_top", 0, -6, 6, 300, 12, "wood", lift=78, corner=2)
    _fence_post(a, "post_front", 0, 0)
    return a


@asset
def obj_well():
    a = Asset("obj_well", "Village well: round stone curb 1.3 m wide with dark water, wooden posts, winch axle with "
              "crank, rope and bucket, small tiled gable roof.", seed=703)
    ellipse_shadow(a, 10, -96, 290, 220, opacity=0.36, blur=10)
    dd = 234 * SQ
    a.flat("void", [E(0, -79 - dd / 2 + 4, 196, 168)], "hole", grad={"to": "well_inner", "y0": -79 - dd, "y1": -79})
    a.add("water", [E(0, -79 - dd / 2 + 26, 150, 84)], "mass", "water", clip_to="void",
          shade={"bump": 0.3, "highlight_amount": 0.3}, line=FINE)
    rim = a.cyl("rim", 0, 0, 234, 79, "stone", hole=190)
    a.flat("masonry", [I("brick_wall", 0, -44, 250, 104, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                         fit=[1.2, 1.2, 14.8, 14.8])], "floor_joint", opacity=0.4, clip_to="rim")
    caps = []
    for k in range(12):
        t = 2 * math.pi * k / 12
        x0, y0 = 106 * math.cos(t), rim.top_cy + 91 * SQ * math.sin(t)
        x1, y1 = 118 * math.cos(t), rim.top_cy + 102 * SQ * math.sin(t)
        caps.append(LINE(x0, y0, x1, y1, 2.2))
    a.flat("cap_joints", caps, "floor_joint", opacity=0.6, clip_to="rim")
    for i, x in enumerate((-126, 126)):
        a.box(f"post{i}", x, -92, 15, 13, 226, "wood_dark", corner=3)
    a.box("axle", 0, -92, 262, 10, 12, "wood", lift=130, corner=3)
    a.add("crank", [LINE(131, -230, 152, -212, 6), LINE(152, -212, 152, -192, 6)], "mass", "iron")
    a.flat("rope", [R(0, -214, 3, 20, 1)], "rope")
    bk = a.cyl("bucket", 0, -110, 30, 26, "wood", lift=62)
    a.flat("bucket_hoop", band_on_cyl(0, bk.top_cy + 16, 30, 4), "iron", clip_to="bucket")
    front = a.box("roof", 0, -48, 296, 98, 10, "roof_slate", lift=222, corner=4)
    a.flat("roof_tiles", tile_rows(front.top0, front.top1, front.x0 + 4, front.x1 - 4, 14, 20), "floor_joint",
           opacity=0.5, clip_to="roof")
    a.wash("roof_shade", [R(0, front.top1 - 14, 296, 30, 4)], "shade_tint" if False else "soot", opacity=0.35,
           blur=6, clip_to="roof")
    a.box("ridge", 0, -112, 302, 10, 10, "wood_dark", lift=256, corner=3)
    return a


@asset
def obj_street_lamp():
    a = Asset("obj_street_lamp", "Cast-iron street lamp 2.9 m: stepped base, ringed post, glass lantern with an iron "
              "cage and cap. Frames: off, on (lit glass, emit).", seed=704)
    ellipse_shadow(a, 6, -12, 64, 30, opacity=0.36, blur=6)
    a.box("base", 0, 0, 38, 32, 22, "iron", corner=4)
    post = a.cyl("post", 0, -12, 15, 236, "iron", lift=22)
    a.flat("collars", band_on_cyl(0, -12 - 7 - 30, 17, 6) + band_on_cyl(0, -12 - 7 - 150, 17, 5), "iron",
           clip_to="post", line=FINE)
    a.box("lantern_floor", 0, -10, 44, 26, 6, "iron", lift=254, corner=3)
    a.add("glass_off", [R(0, -292, 34, 44, 3)], "mass", "glass_dark", tags=["off"])
    a.add("glass_on", [R(0, -292, 34, 44, 3)], "mass", "glass", tags=["on"], hidden=True, emit=0.9,
          glow={"radius": 12, "opacity": 0.55, "color": "lamp_glow"})
    a.flat("cage", [R(-17, -292, 3, 46, 1), R(17, -292, 3, 46, 1), R(0, -292, 3, 46, 1), R(0, -300, 36, 3, 1)], "iron")
    a.add("cap", [I("triangle", 0, -324, 50, 22), E(0, -338, 9, 9)], "mass", "iron")
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": LAMP, "radius": 420, "at": [0, -292]})
    return a


@asset
def obj_sign_hanging():
    a = Asset("obj_sign_hanging", "Hanging shop sign on an iron wall bracket, board parallel to the wall, no text. "
              "Frames: blank, inn (mug), smithy (hammer), potion (flask).", seed=705, pivot_meaning=WALL,
              layer_hint="wall")
    a.shadow([R(4, 62, 124, 84, 8)], opacity=0.25, blur=7)
    a.add("plate", [R(-74, 0, 12, 32, 3)], "mass", "iron")
    a.add("arm", [LINE(-74, -4, 66, -4, 6), LINE(-74, 20, -24, -4, 4), I("spiral", 70, -8, 14)], "mass", "iron")
    a.flat("chains", [LINE(-44, -2, -44, 22, 2.5), LINE(44, -2, 44, 22, 2.5)], "iron")
    a.add("board", [R(0, 62, 124, 80, 6)], "mass", "wood", shade={"bump": 0.35}, texture={"angle": 0})
    a.flat("border", [R(0, 62, 124, 80, 6), R(0, 62, 108, 64, 4, op="sub")], "wood_dark", line=FINE)
    a.flat("pic_inn", [I("cup", 0, 64, 44)], "bronze", line=THIN, tags=["inn"], hidden=True)
    a.flat("pic_smithy", [I("hammer", 0, 62, 48, rot=-10)], "iron", line=THIN, tags=["smithy"], hidden=True)
    a.flat("pic_potion", [I("potion", 0, 62, 44)], "cloth_wine", line=THIN, tags=["potion"], hidden=True)
    a.frame("blank", state="blank")
    a.frame("inn", state="inn", show=["inn"])
    a.frame("smithy", state="smithy", show=["smithy"])
    a.frame("potion", state="potion", show=["potion"])
    return a


@asset
def obj_handcart():
    a = Asset("obj_handcart", "Two-wheeled wooden handcart, bed 1.2 x 0.8 m, spoked wheel on the near side, two long "
              "handles to the east and a resting leg.", seed=706, pivot_meaning="centre of the wheel axle on the ground")
    a.shadow([R(40, -60, 330, 140, 16)], opacity=0.32, blur=10)
    a.add("wheel_far", [E(-10, -132, 104, 64)], "mass", "wood_dark")
    a.add("handle_far", [LINE(96, -110, 236, -82, 8)], "mass", "wood")
    bed = a.box("bed", -10, -10, 216, 118, 34, "wood", lift=50, corner=5)
    a.flat("bed_inside", [R(-10, bed.top_cy, 196, 98, 4)], "wood_dark", line=FINE)
    planks_top(a, "bed_planks", bed, 4, along_x=False)
    planks_front(a, "side_planks", bed, 2)
    a.box("leg", 156, -2, 9, 8, 50, "wood_dark", corner=2)
    a.add("handle_near", [LINE(96, -60, 250, -28, 8)], "mass", "wood")
    a.add("wheel", [E(-10, -36, 108, 68)], "mass", "wood_dark", shade={"bump": 0.8})
    a.flat("spokes", [I("wheel", -10, -36, 96, 60)], "wood", line=FINE, clip_to="wheel")
    a.flat("tyre", [E(-10, -36, 108, 68), E(-10, -36, 94, 56, op="sub")], "iron", line=FINE)
    a.flat("hub", [E(-10, -36, 16, 11)], "iron", line=FINE)
    return a


@asset
def obj_bench():
    a = Asset("obj_bench", "Wooden bench 1.6 m long facing down (south): three seat slats, backrest with two rails, "
              "four legs.", seed=707)
    a.shadow([R(8, -34, 300, 80, 12)], opacity=0.32, blur=8)
    for i, x in enumerate((-126, 126)):
        a.box(f"back_leg{i}", x, -64, 10, 8, 47, "wood_dark", corner=2)
        a.box(f"back_post{i}", x, -64, 11, 8, 44, "wood_dark", lift=47, corner=2)
    a.box("back_rail_top", 0, -64, 284, 7, 14, "wood", lift=78, corner=3)
    a.box("back_rail_low", 0, -64, 284, 7, 12, "wood", lift=56, corner=3)
    seat = a.box("seat", 0, 0, 288, 70, 7, "wood", lift=40, corner=4)
    planks_top(a, "seat_slats", seat, 3, opacity=0.6)
    for i, x in enumerate((-126, 126)):
        a.box(f"front_leg{i}", x, -3, 10, 8, 40, "wood_dark", corner=2)
    a.footprint = (-144, -70, 144, 0)
    return a


ARCH = [(0, 1), (0, 0.32), (0.08, 0.14), (0.25, 0.03), (0.5, 0), (0.75, 0.03), (0.92, 0.14), (1, 0.32), (1, 1)]


@asset
def obj_gravestone():
    a = Asset("obj_gravestone", "Weathered gravestone on a low plinth with a small grave mound. Frames: arch, cross, "
              "broken (top half fallen in front, cracks).", seed=708)
    a.shadow([R(8, -14, 150, 44, 10)], opacity=0.34, blur=7)
    a.add("mound", [E(0, 30, 150, 44)], "mass", "earth", shade={"bump": 0.6}, line=THIN)
    a.add("grass", [I("grass", -56, 30, 34, 18), I("grass", 60, 34, 30, 16, flip="x"), I("grass", 8, 48, 26, 12)],
          "mass", "grass", line=FINE)
    a.box("plinth", 0, 0, 132, 38, 14, "rock", corner=4)
    stone = POLY(ARCH, 0, -68, 108, 110)
    a.add("arch", [stone], "mass", "marble", tags=["arch"], shade={"bump": 0.6})
    a.flat("arch_border", [POLY(ARCH, 0, -66, 88, 92), POLY(ARCH, 0, -64, 78, 80, op="sub")], "floor_joint",
           opacity=0.45, tags=["arch"], clip_to="arch")
    a.flat("arch_mark", [R(0, -76, 6, 34, 2), R(0, -84, 22, 6, 2)], "floor_joint", opacity=0.5, tags=["arch"])
    a.add("cross", [R(0, -70, 24, 116, 4), R(0, -98, 84, 22, 4)], "mass", "marble", tags=["cross"], hidden=True,
          shade={"bump": 0.7})
    a.add("broken_stump", [POLY([(0, 1), (0, 0.18), (0.2, 0.0), (0.38, 0.32), (0.55, 0.08), (0.8, 0.4), (1, 0.12),
                                 (1, 1)], 0, -38, 108, 52)], "mass", "marble", tags=["broken"], hidden=True,
          shade={"bump": 0.6})
    a.add("broken_top", [POLY(ARCH, 64, 34, 96, 58, rot=-72, squash=0.9)], "mass", "marble", tags=["broken"],
          hidden=True, shade={"bump": 0.5})
    a.flat("cracks", [I("lightning_bolt", 16, -64, 7, 60, rot=-12)], "floor_joint", opacity=0.6, tags=["arch"])
    a.frame("arch", state="normal", hide=["cross", "broken"])
    a.frame("cross", state="normal", show=["cross"], hide=["arch", "broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["arch", "cross"])
    return a


@asset
def obj_campfire():
    a = Asset("obj_campfire", "Campfire: ring of stones, ash bed, four logs leaning together. Frames: off (cold logs, "
              "grey ash), on (glowing logs and coals, emit). Flame effect not drawn (anchors.flame_anchor).",
              seed=709, pivot_meaning="centre of the fire ring on the ground")
    ellipse_shadow(a, 6, 2, 190, 80, opacity=0.3, blur=8)
    stones = []
    for k in range(11):
        t = 2 * math.pi * k / 11 + 0.2
        x, y = 78 * math.cos(t), -8 + 44 * math.sin(t)
        w = 30 + 8 * math.sin(k * 1.7)
        stones.append(POLY([(0, 0.6), (0.2, 0.1), (0.7, 0), (1, 0.4), (0.8, 1), (0.2, 0.95)], x, y, w, w * 0.62))
    back = [p for p in stones if p["at"][1] < -8]
    front = [p for p in stones if p["at"][1] >= -8]
    a.add("stones_back", back, "mass", "rock", line=THIN)
    a.add("ash", [E(0, -8, 132, 68)], "mass", "ash", shade={"bump": 0.3}, line=FINE)
    a.flat("coals_off", [E(-12, -10, 20, 9), E(14, -4, 18, 8), E(2, -18, 16, 7)], "soot", tags=["off"])
    a.add("coals_on", [E(0, -8, 90, 40)], "mass", "ember", tags=["on"], hidden=True, emit=0.8,
          glow={"radius": 8, "opacity": 0.6, "color": "ember_glow"}, line=FINE)
    logs = [LINE(-58, -4, -4, -62, 15), LINE(56, -2, 6, -60, 15), LINE(-30, 20, 0, -58, 14), LINE(34, -30, 2, -64, 13)]
    a.add("logs_off", logs, "mass", "bark", tags=["off"], texture={"angle": 60})
    a.add("logs_on", logs, "mass", "soot", tags=["on"], hidden=True, texture={"angle": 60})
    a.flat("log_embers", [LINE(-50, -10, -12, -52, 5), LINE(48, -8, 12, -50, 5), LINE(-26, 12, -2, -48, 5)], "ember",
           tags=["on"], hidden=True, emit=0.9, glow={"radius": 4, "opacity": 0.6, "color": "ember_glow"})
    a.add("stones_front", front, "mass", "rock", line=THIN)
    anchors = {"flame_anchor": [0, -40]}
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=anchors,
            light={"color": FLAME, "radius": 420, "at": [0, -40]})
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
