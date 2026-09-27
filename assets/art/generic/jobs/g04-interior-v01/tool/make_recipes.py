"""g04-interior-v01 recipes: furniture, indoor lights, indoor BS2 props.

    python -B make_recipes.py              # write every recipe into ../recipes
    python -B make_recipes.py obj_desk     # only these

Furniture that stands against a wall keeps the ordinary pivot (front-bottom centre on the floor);
its back face is the wall line.  Wall-hung things use the wall attach point (pivot_meaning).
Fire boundary: stoves / fireplaces show glowing coals and logs only; anchors.flame_anchor marks
where the game adds g01 / g02 flame effects.
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
WALLFRONT = "front-bottom centre on the floor; the back face stands on the wall line"
BOOKS = ["cloth_wine", "cloth_blue", "cloth_green", "cloth_ochre", "leather", "paper"]


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


def book_row(a, prefix, x0, x1, base_y, max_h, tags=None, hidden=False, gap_chance=0.12):
    """Books standing on a shelf line ``base_y`` between x0..x1 (front view)."""
    rng = a.rng
    by_mat = {m: [] for m in BOOKS}
    x = x0 + 2
    while x < x1 - 6:
        w = rng.uniform(7, 13)
        if rng.random() < gap_chance:
            x += rng.uniform(8, 16)
            continue
        h = rng.uniform(0.66, 1.0) * max_h
        mat = rng.choice(BOOKS)
        rot = 0.0
        if rng.random() < 0.1 and x + 14 < x1:
            rot = rng.choice([-14, 12])
        by_mat[mat].append(R(x + w / 2, base_y - h / 2, w, h, 1.5, rot=rot))
        x += w + rng.uniform(0.5, 2)
    for mat, pieces in by_mat.items():
        if pieces:
            a.flat(f"{prefix}_{mat}", pieces, mat, line=FINE, tags=tags, hidden=hidden)


# ============================================================================ A
@asset
def obj_desk():
    a = Asset("obj_desk", "Wooden writing desk 1.2 x 0.6 m, 0.76 m high: drawer pedestal on the right, two legs on "
              "the left, a few loose papers on top.", seed=601)
    a.shadow([R(8, -44, 236, 100, 14)], opacity=0.34, blur=9)
    a.box("leg_back", -98, -86, 9, 8, 74, "wood_dark", corner=2)
    p = a.box("pedestal", 64, -3, 76, 86, 74, "wood", corner=4)
    a.flat("drawers", [R(64, p.top1 + 13 + k * 24, 66, 20, 2) for k in range(3)], "wood_pale", line=THIN)
    a.flat("knobs", [E(64, p.top1 + 13 + k * 24, 7, 6) for k in range(3)], "bronze", line=FINE)
    top = a.box("top", 0, 0, 218, 96, 8, "wood", lift=74, corner=4)
    planks_top(a, "top_joints", top, 3)
    a.box("leg_front", -98, -4, 9, 8, 74, "wood_dark", corner=2)
    a.add("papers", [R(-40, top.top_cy + 4, 46, 58, 2, rot=78, ground=True), R(-4, top.top_cy - 6, 42, 54, 2, rot=96,
                                                                               ground=True)],
          "mass", "paper", shade={"bump": 0.25}, line=THIN, cast={"dist": 2, "blur": 1.5, "opacity": 0.4,
                                                                   "color": "shade_tint"})
    a.flat("paper_marks", [R(-40, top.top_cy + 4 + k * 8 - 8, 30, 2, 1, rot=-12) for k in range(3)], "paper_mark")
    a.footprint = (-109, -96, 109, 0)
    return a


@asset
def obj_chair():
    a = Asset("obj_chair", "Wooden chair facing down (south): seat at 0.45 m, slatted backrest to 0.95 m.", seed=602)
    a.shadow([R(6, -34, 94, 80, 12)], opacity=0.32, blur=7)
    for i, x in enumerate((-35, 35)):
        a.box(f"back_leg{i}", x, -66, 8, 7, 47, "wood_dark", corner=2)
    for i, x in enumerate((-35, 35)):
        a.box(f"back_post{i}", x, -66, 9, 7, 60, "wood_dark", lift=47, corner=2)
    a.box("back_rail", 0, -66, 84, 7, 13, "wood", lift=94, corner=3)
    a.box("back_rail_low", 0, -66, 70, 6, 8, "wood", lift=62, corner=2)
    for i, x in enumerate((-12, 12)):
        a.box(f"slat{i}", x, -66, 8, 5, 28, "wood", lift=68, corner=2)
    seat = a.box("seat", 0, 0, 84, 72, 6, "wood", lift=45, corner=4)
    planks_top(a, "seat_joints", seat, 3)
    for i, x in enumerate((-35, 35)):
        a.box(f"front_leg{i}", x, -3, 8, 7, 45, "wood_dark", corner=2)
    a.footprint = (-42, -72, 42, 0)
    return a


@asset
def obj_bed():
    a = Asset("obj_bed", "Single bed 1.0 x 2.0 m, head to the north: dark wood frame and headboard, linen mattress, "
              "pillow, wine blanket folded over the foot end.", seed=603)
    a.shadow([R(8, -150, 204, 330, 16)], opacity=0.34, blur=10)
    hb = a.box("headboard", 0, -306, 196, 14, 112, "wood_dark", corner=4)
    a.flat("headboard_panel", [R(0, hb.front_cy - 6, 160, 64, 4)], "wood", line=THIN)
    a.box("posts_back", 0, -306, 206, 14, 124, "wood_dark", corner=4, top=lambda x, cy, w, d: [R(x - 96, cy, 14, d, 3),
                                                                                                 R(x + 96, cy, 14, d, 3)])
    fr = a.box("frame", 0, 0, 184, 306, 38, "wood_dark", lift=6, corner=5)
    a.box("feet", 0, 0, 184, 12, 6, "wood_dark", corner=2, top=lambda x, cy, w, d: [R(x - 86, cy, 12, d, 2),
                                                                                     R(x + 86, cy, 12, d, 2)])
    m = a.box("mattress", 0, -6, 168, 292, 16, "cloth_pale", lift=44, corner=10)
    a.add("pillow", [R(0, m.top0 + 34, 124, 50, 18)], "mass", "cloth_pale", shade={"bump": 1.2})
    a.add("blanket", [R(0, m.top1 - 94, 178, 196, 14), R(0, m.top1 + 10, 178, 30, 8)], "mass", "cloth_wine",
          shade={"bump": 0.7})
    a.flat("blanket_fold", [R(0, m.top1 - 180, 176, 12, 5)], "cloth_pale", line=THIN)
    a.flat("blanket_creases", [LINE(-50, m.top1 - 150, -20, m.top1 - 60, 3), LINE(40, m.top1 - 130, 58, m.top1 - 40, 3)],
           "cloth_wine", opacity=0.9, line=FINE)
    a.footprint = (-92, -306, 92, 0)
    return a


@asset
def obj_bookshelf():
    a = Asset("obj_bookshelf", "Tall bookshelf 1.0 m wide, 1.9 m high, 0.35 m deep, against a wall: five shelves of "
              "books in muted bindings, a few gaps and leaning books.", seed=604, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -24, 196, 64, 10)], opacity=0.34, blur=8)
    c = a.box("case", 0, 0, 180, 55, 200, "wood_dark", corner=4)
    a.flat("recess", [R(0, -103, 160, 184, 2)], "void", opacity=0.55)
    shelves = [-196 + 38 * k for k in range(1, 5)]
    for k, y in enumerate([-196] + shelves):
        book_row(a, f"row{k}", -80, 80, y + 38 - 4, 30)
    a.flat("boards", [R(0, y, 164, 7, 2) for y in shelves] + [R(0, -8, 164, 9, 2)], "wood", line=THIN)
    a.box("cornice", 0, 3, 192, 62, 10, "wood", lift=200, corner=3)
    a.footprint = (-90, -55, 90, 0)
    return a


def _shelf_items(a, tag, y_top_face, x0, x1, hidden):
    """A few stored things on one shelf board (front of the board's top face at y_top_face)."""
    rng = a.rng
    base = y_top_face - 16
    jars, baskets, sacks, bottles, weaves = [], [], [], [], []
    x = x0 + 18
    while x < x1 - 18:
        kind = rng.choice(["jar", "jar", "basket", "sack", "bottle", "gap"])
        if kind == "jar":
            w = rng.uniform(22, 30)
            h = rng.uniform(26, 34)
            jars += [E(x, base - h / 2, w, h), E(x, base - h + 3, w * 0.6, 6)]
            x += w + 6
        elif kind == "basket":
            baskets += [R(x + 8, base - 11, 40, 22, 7), E(x + 8, base - 22, 40, 9)]
            weaves.append(R(x + 8, base - 11, 36, 2, 1))
            weaves.append(R(x + 8, base - 5, 34, 2, 1))
            x += 44
        elif kind == "sack":
            sacks.append(I("pouch", x + 4, base - 16, 32, 34))
            x += 34
        elif kind == "bottle":
            bottles += [R(x, base - 12, 10, 22, 4), R(x, base - 27, 4, 10, 2)]
            x += 16
        else:
            x += 18
    if jars:
        a.add(f"{tag}_jars", jars, "mass", "clay", line=THIN, tags=["full"], hidden=hidden)
    if baskets:
        a.add(f"{tag}_baskets", baskets, "mass", "thatch", line=THIN, tags=["full"], hidden=hidden)
        a.flat(f"{tag}_weave", weaves, "wood_dark", opacity=0.55, tags=["full"], hidden=hidden,
               clip_to=f"{tag}_baskets")
    if sacks:
        a.add(f"{tag}_sacks", sacks, "mass", "cloth_ochre", line=THIN, tags=["full"], hidden=hidden)
    if bottles:
        a.add(f"{tag}_bottles", bottles, "mass", "glass_dark", line=FINE, tags=["full"], hidden=hidden)


@asset
def obj_shelf():
    a = Asset("obj_shelf", "Open storage shelf 1.2 m wide, 1.6 m high, 0.4 m deep, against a wall; drawn like the "
              "bookshelf (compartments on the front face). Frames: full (jars, baskets, sacks, bottles), empty.",
              seed=605, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -28, 232, 70, 10)], opacity=0.34, blur=8)
    c = a.box("case", 0, 0, 216, 62, 168, "wood_dark", corner=4)
    a.flat("recess", [R(0, -86, 196, 156, 2)], "void", opacity=0.5)
    planks_front(a, "back_joints", c, 6, vertical=True, opacity=0.3)
    levels = [-10, -52, -94, -136]
    for k, y in enumerate(levels):
        _shelf_items(a, f"lvl{k}", y + 16, -96, 96, hidden=False)
    a.flat("boards", [R(0, y, 200, 7, 2) for y in levels[1:]] + [R(0, -8, 200, 9, 2)], "wood", line=THIN)
    a.box("top_board", 0, 3, 224, 66, 6, "wood", lift=168, corner=3)
    a.frame("full", state="full")
    a.frame("empty", state="empty", hide=["full"])
    a.footprint = (-108, -62, 108, 0)
    return a


@asset
def obj_wardrobe():
    a = Asset("obj_wardrobe", "Two-door wardrobe 1.1 m wide, 2.1 m high, against a wall: panelled doors, cornice, "
              "feet. Frames: closed, open (doors swung toward the viewer, hanging clothes inside).", seed=606,
              pivot_meaning=WALLFRONT)
    a.shadow([R(6, -40, 214, 96, 12)], opacity=0.35, blur=9, tags=["closed"])
    a.shadow([R(6, -20, 300, 150, 12)], opacity=0.3, blur=9, name="shadow_open", tags=["open"], hidden=True)
    a.box("feet", 0, -2, 190, 80, 10, "wood_dark", corner=2,
          top=lambda x, cy, w, d: [R(x - 88, cy, 14, d, 2), R(x + 88, cy, 14, d, 2)])
    b = a.box("body", 0, 0, 198, 86, 200, "wood", lift=10, corner=4)
    a.box("cornice", 0, 3, 212, 92, 12, "wood_dark", lift=210, corner=3)
    # closed doors
    for i, x in enumerate((-49, 49)):
        a.flat(f"door{i}", [R(x, b.front_cy, 92, 190, 3)], "wood", line=THIN, tags=["closed"])
        a.add(f"door{i}_panels", [R(x, b.front_cy - 46, 70, 78, 4), R(x, b.front_cy + 50, 70, 70, 4)], "mass", "wood",
              shade={"bump": 0.5}, line=THIN, tags=["closed"])
    a.flat("handles", [R(-8, b.front_cy, 5, 22, 2), R(8, b.front_cy, 5, 22, 2)], "bronze", line=FINE, tags=["closed"])
    # open
    a.flat("inside", [R(0, b.front_cy, 184, 190, 2)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": b.top1, "y1": b.bottom, "curve": 0.8})
    a.flat("rod", [R(0, b.top1 + 22, 176, 5, 2)], "iron", line=FINE, tags=["open"], hidden=True)
    rng = a.rng
    for k, (x, mat) in enumerate([(-66, "cloth_wine"), (-38, "cloth_blue"), (-8, "coat"), (24, "cloth_green"),
                                   (54, "cloth_ochre")]):
        ln = rng.uniform(96, 140)
        a.add(f"cloth{k}", [R(x, b.top1 + 30 + ln / 2, 30, ln, 6), I("triangle", x, b.top1 + 32, 32, 12)], "mass", mat,
              line=THIN, tags=["open"], hidden=True, shade={"bump": 0.7})
    a.flat("hooks", [I("clothes_hanger", x, b.top1 + 24, 26, 14, crop=[0.5, 4, 15.5, 13]) for x in (-66, -38, -8, 24, 54)],
           "iron", line=FINE, tags=["open"], hidden=True)
    h = 190
    for i, (x, flip) in enumerate(((b.x0 - 23, False), (b.x1 + 23, True))):
        pts = [(1, 0), (1, 0.73), (0, 1), (0, 0.27)] if not flip else [(0, 0), (0, 0.73), (1, 1), (1, 0.27)]
        a.add(f"door_open{i}", [POLY(pts, x, b.front_cy + 35, 46, h + 70)], "mass", "wood", tags=["open"], hidden=True,
              shade={"bump": 0.4}, texture={"angle": 90})
        a.flat(f"door_open{i}_panel", [POLY(pts, x, b.front_cy + 35, 30, h + 30)], "wood_pale", opacity=0.6,
               line=FINE, tags=["open"], hidden=True, clip_to=f"door_open{i}")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    a.footprint = (-99, -86, 99, 0)
    return a


@asset
def obj_dining_table():
    a = Asset("obj_dining_table", "Long dining table 2.0 x 0.9 m, six square legs, a wine runner along the top.",
              seed=607)
    a.shadow([R(8, -64, 380, 150, 16)], opacity=0.34, blur=10)
    for i, x in enumerate((-166, 0, 166)):
        a.box(f"leg_back{i}", x, -128, 12, 10, 72, "wood_dark", corner=2)
    t = a.box("top", 0, 0, 360, 140, 9, "wood", lift=72, corner=5)
    planks_top(a, "top_joints", t, 4)
    a.flat("runner", [R(0, t.top_cy, 300, 44, 3)], "cloth_wine", line=THIN)
    a.flat("runner_trim", [R(0, t.top_cy - 18, 300, 3, 1), R(0, t.top_cy + 18, 300, 3, 1)], "cloth_ochre", opacity=0.8)
    a.box("apron", 0, 0, 348, 4, 12, "wood_dark", lift=60, corner=2)
    for i, x in enumerate((-166, 0, 166)):
        a.box(f"leg_front{i}", x, -4, 12, 10, 72, "wood_dark", corner=2)
    a.footprint = (-180, -140, 180, 0)
    return a


@asset
def obj_stove_iron():
    a = Asset("obj_stove_iron", "Cast-iron stove on short legs with two cooking plates, a vented fire door, an ash "
              "drawer and a stovepipe. Frames: off, on (vents glow, emit).", seed=608, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -40, 144, 96, 12)], opacity=0.36, blur=8)
    a.box("legs", 0, -2, 118, 80, 14, "iron", corner=2,
          top=lambda x, cy, w, d: [R(x - 52, cy, 12, d, 3), R(x + 52, cy, 12, d, 3)])
    b = a.box("body", 0, 0, 126, 86, 74, "iron", lift=14, corner=6)
    a.flat("plates", [E(-30, b.top_cy + 8, 40, 30), E(8, b.top_cy + 12, 30, 22)], "soot", line=THIN)
    a.flat("plate_rings", [E(-30, b.top_cy + 8, 24, 16), E(8, b.top_cy + 12, 18, 12)], "iron", opacity=0.7, line=FINE)
    pipe = a.cyl("pipe", 40, -70, 28, 150, "iron", lift=88)
    a.flat("pipe_rings", band_on_cyl(40, -70 - 88 - 12 - 24, 28, 5) + band_on_cyl(40, -70 - 88 - 12 - 110, 28, 5),
           "iron", clip_to="pipe", line=FINE)
    a.flat("door", [R(-12, b.front_cy - 6, 70, 44, 4)], "iron", line=THIN)
    vents = [R(-12 + dx, b.front_cy - 6, 7, 26, 3) for dx in (-22, -11, 0, 11, 22)]
    a.flat("vents_off", vents, "hole", tags=["off"])
    a.flat("vents_on", vents, "ember", tags=["on"], hidden=True, emit=0.9,
           glow={"radius": 6, "opacity": 0.6, "color": "ember_glow"})
    a.flat("ash_drawer", [R(-12, b.bottom - 9, 60, 10, 3)], "soot", line=THIN)
    a.flat("handle", [R(34, b.front_cy - 6, 6, 16, 2)], "bronze", line=FINE)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": "#ff9a4a", "radius": 240, "at": [-12, -50]})
    a.footprint = (-63, -86, 63, 0)
    return a


@asset
def obj_fireplace():
    a = Asset("obj_fireplace", "Stone fireplace against a wall: 1.6 m surround with masonry joints, wooden mantel, "
              "chimney breast, arched firebox with brick back, iron grate and logs, hearth slab. Frames: off (ash, "
              "cold logs), on (glowing logs and coals, emit). Flame effect not drawn (anchors.flame_anchor).",
              seed=609, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -20, 330, 70, 12)], opacity=0.34, blur=9)
    a.box("hearth", 0, 50, 336, 60, 7, "stone_dark", corner=4)
    a.box("breast", 0, -30, 224, 44, 118, "stone", lift=153, corner=4)
    s = a.box("surround", 0, 0, 288, 78, 140, "stone", corner=5)
    a.flat("masonry", [I("brick_wall", 0, s.front_cy, 300, 156, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                         fit=[1.2, 1.2, 14.8, 14.8])], "floor_joint", opacity=0.42, clip_to="surround")
    a.flat("opening", [I("bullet", 0, -52, 104, 158, rot=-90)], "hole",
           grad={"to": "well_inner", "y0": -104, "y1": 0, "curve": 1.4})
    a.flat("firebrick", [I("brick_wall", 0, -58, 120, 70, invert=True, crop=[1.2, 1.2, 14.8, 14.8],
                           fit=[1.2, 1.2, 14.8, 14.8])], "brick", opacity=0.35, clip_to="opening")
    a.wash("inner_glow", [E(0, -40, 120, 80)], "ember", opacity=0.55, blend="normal", blur=10, clip_to="opening",
           tags=["on"], hidden=True, emit=0.6)
    a.add("grate", [R(0, -14, 112, 8, 3), R(-44, -22, 7, 22, 2), R(44, -22, 7, 22, 2)], "mass", "iron", line=THIN)
    a.add("logs_off", [R(-8, -30, 96, 22, 11, rot=-6), R(12, -42, 84, 20, 10, rot=8)], "mass", "bark",
          tags=["off"], texture={"angle": 0})
    a.add("ash", [E(0, -12, 110, 14)], "mass", "ash", tags=["off"], line=THIN)
    a.add("logs_on", [R(-8, -30, 96, 22, 11, rot=-6), R(12, -42, 84, 20, 10, rot=8)], "mass", "soot",
          tags=["on"], hidden=True, texture={"angle": 0})
    a.flat("log_embers", [R(-8, -26, 80, 6, 3, rot=-6), R(12, -38, 66, 5, 3, rot=8)], "ember", tags=["on"],
           hidden=True, emit=0.9, glow={"radius": 5, "opacity": 0.6, "color": "ember_glow"})
    a.add("coals", [E(0, -12, 110, 14)], "mass", "ember", tags=["on"], hidden=True, emit=0.8,
          glow={"radius": 7, "opacity": 0.6, "color": "ember_glow"}, line=THIN)
    a.box("mantel", 0, 6, 312, 47, 13, "wood_dark", lift=140, corner=4)
    anchors = {"flame_anchor": [0, -48]}
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=anchors,
            light={"color": "#ffb45c", "radius": 420, "at": [0, -48]})
    a.footprint = (-144, -78, 144, 0)
    return a


# ============================================================================ B
OVERHEAD = "floor point directly below the fixture (drawn at its hanging height above it)"
WALL = "centre of the wall plate = attach point on the wall face"
LAMP = "#ffc987"


@asset
def obj_chandelier():
    a = Asset("obj_chandelier", "Gothic chandelier hanging at 2.2 m: chain, gold stem and ring, six glass lamp globes. "
              "Frames: off, on (globes lit, emit). Hangs above characters (layer_hint overhead).", seed=611,
              pivot_meaning=OVERHEAD, layer_hint="overhead")
    ellipse_shadow(a, 0, 0, 170, 60, opacity=0.18, blur=12)
    y = -232
    a.flat("chain", [E(0, y - 110 + k * 12, 7, 11) for k in range(9)], "iron", line=FINE)
    a.add("stem", [R(0, y - 34, 12, 60, 4), E(0, y - 66, 20, 14), E(0, y + 4, 26, 16)], "mass", "gold")
    ring = [E(0, y, 176, 62), E(0, y, 156, 48, op="sub")]
    a.add("ring", ring, "mass", "gold", shade={"bump": 0.6})
    pts = [(88 * math.cos(t), y + 31 * math.sin(t)) for t in [math.radians(30 + 60 * k) for k in range(6)]]
    back = [p for p in pts if p[1] < y]
    front = [p for p in pts if p[1] >= y]
    for tag, sel in (("back", back), ("front", front)):
        a.add(f"cups_{tag}", [E(x, py + 4, 20, 9) for x, py in sel], "mass", "gold", line=FINE,
              z=None)
        a.add(f"globes_{tag}_off", [E(x, py - 10, 18, 22) for x, py in sel], "mass", "glass_dark", tags=["off"],
              line=FINE)
        a.add(f"globes_{tag}_on", [E(x, py - 10, 18, 22) for x, py in sel], "mass", "glass", tags=["on"], hidden=True,
              emit=0.95, glow={"radius": 7, "opacity": 0.55, "color": "lamp_glow"}, line=FINE)
    a.add("finial", [I("triangle", 0, y + 22, 16, 18, flip="y")], "mass", "gold", line=FINE)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": LAMP, "radius": 520, "at": [0, y]})
    return a


@asset
def obj_lamp_floor():
    a = Asset("obj_lamp_floor", "Gothic standing lamp 1.7 m: iron tripod foot, turned pole, fringed ochre fabric shade. "
              "Frames: off, on (shade glowing from inside, emit).", seed=612)
    ellipse_shadow(a, 6, -4, 76, 26, opacity=0.34, blur=6)
    a.add("foot", [LINE(0, -18, -30, 0, 7), LINE(0, -18, 30, 0, 7), LINE(0, -18, -2, 6, 6), E(0, -18, 18, 10)], "mass",
          "iron")
    a.add("pole", [R(0, -96, 8, 160, 3), E(0, -60, 14, 8), E(0, -120, 14, 8)], "mass", "iron")
    shade = [(0.22, 0), (0.78, 0), (1, 1), (0, 1)]
    a.add("shade_off", [POLY(shade, 0, -196, 84, 58)], "mass", "cloth_ochre", tags=["off"])
    a.add("shade_on", [POLY(shade, 0, -196, 84, 58)], "mass", "window_lit", tags=["on"], hidden=True, emit=0.85,
          glow={"radius": 9, "opacity": 0.5, "color": "lamp_glow"})
    a.flat("fringe", [R(x, -164, 3, 8, 1) for x in range(-38, 40, 8)], "cloth_wine", line=FINE)
    a.flat("shade_rim", [R(0, -168, 86, 4, 1), R(0, -224, 44, 4, 1)], "gold")
    a.add("finial", [E(0, -230, 10, 10)], "mass", "gold", line=FINE)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": LAMP, "radius": 360, "at": [0, -196]})
    return a


@asset
def obj_lantern_wall():
    a = Asset("obj_lantern_wall", "Wall lantern: iron plate and scrolled bracket, hanging glass lantern with cage and "
              "cap. Frames: off, on (lit glass, emit).", seed=613, pivot_meaning=WALL, layer_hint="wall")
    a.shadow([R(8, 30, 34, 60, 8)], opacity=0.25, blur=6)
    a.add("plate", [R(0, 0, 22, 36, 5)], "mass", "iron", shade={"bump": 0.5})
    a.add("arm", [LINE(0, -6, 0, 18, 6), LINE(0, 18, 6, 26, 5), I("spiral", -10, 10, 16, rot=90)], "mass", "iron")
    a.flat("hook", [R(6, 32, 3, 12, 1)], "iron")
    a.add("cap", [I("triangle", 6, 44, 34, 16), E(6, 36, 8, 8)], "mass", "iron")
    a.add("glass_off", [R(6, 66, 26, 34, 3)], "mass", "glass_dark", tags=["off"])
    a.add("glass_on", [R(6, 66, 26, 34, 3)], "mass", "glass", tags=["on"], hidden=True, emit=0.9,
          glow={"radius": 9, "opacity": 0.55, "color": "lamp_glow"})
    a.flat("cage", [R(-7, 66, 3, 36, 1), R(19, 66, 3, 36, 1), R(6, 66, 3, 36, 1)], "iron")
    a.box("base", 6, 88, 32, 16, 6, "iron", corner=2)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": LAMP, "radius": 320, "at": [6, 66]})
    return a


@asset
def obj_clock_grandfather():
    a = Asset("obj_clock_grandfather", "Grandfather clock 2.1 m against a wall: dark wood case, hood with a bone dial, "
              "hour marks and hands (no numerals), trunk window showing the brass pendulum.", seed=614,
              pivot_meaning=WALLFRONT)
    a.shadow([R(6, -22, 110, 56, 8)], opacity=0.34, blur=7)
    a.box("plinth", 0, 0, 96, 50, 34, "wood_dark", corner=3)
    trunk = a.box("trunk", 0, -4, 78, 44, 132, "wood_dark", lift=34, corner=3)
    a.flat("window", [R(0, trunk.front_cy + 6, 44, 96, 16)], "glass_dark", line=THIN)
    a.flat("pendulum", [R(0, trunk.front_cy - 10, 3, 60, 1), E(0, trunk.front_cy + 30, 22, 22)], "gold", line=FINE,
           clip_to="window")
    hood = a.box("hood", 0, 0, 96, 52, 58, "wood_dark", lift=166, corner=4)
    a.flat("dial", [E(0, hood.front_cy, 52, 52)], "paper", line=THIN)
    marks = []
    for k in range(12):
        t = math.radians(30 * k)
        marks.append(LINE(math.cos(t) * 19, hood.front_cy + math.sin(t) * 19, math.cos(t) * 23,
                          hood.front_cy + math.sin(t) * 23, 2))
    a.flat("marks", marks, "soot")
    a.flat("hands", [LINE(0, hood.front_cy, 0, hood.front_cy - 18, 3), LINE(0, hood.front_cy, 12, hood.front_cy + 4, 3)],
           "soot")
    a.add("crest", [POLY([(0, 1), (0.2, 0.3), (0.5, 0), (0.8, 0.3), (1, 1)], 0, hood.top1 - 60, 90, 22)], "mass",
          "wood_dark")
    a.flat("finials", [E(-40, hood.top1 - 64, 10, 12), E(40, hood.top1 - 64, 10, 12), E(0, hood.top1 - 76, 10, 12)],
           "gold", line=FINE)
    a.footprint = (-48, -50, 48, 0)
    return a


@asset
def obj_mirror_standing():
    a = Asset("obj_mirror_standing", "Cheval mirror 1.8 m: oval glass in a carved dark frame on two posts with feet. "
              "Frames: normal, broken (cracks, missing pieces, shards on the floor).", seed=615)
    a.shadow([R(6, -18, 120, 44, 8)], opacity=0.32, blur=7)
    for i, x in enumerate((-50, 50)):
        a.box(f"foot{i}", x, 0, 18, 46, 8, "wood_dark", corner=3)
        a.box(f"post{i}", x, -20, 10, 8, 160, "wood_dark", corner=2)
    a.add("frame", [E(0, -104, 92, 150)], "mass", "wood_dark")
    a.add("glass", [E(0, -104, 76, 134)], "mass", "glass_dark", shade={"bump": 0.3, "highlight_amount": 0.8})
    a.flat("sheen", [LINE(-20, -60, 10, -150, 6), LINE(-4, -52, 20, -120, 3)], "chrome", opacity=0.35, clip_to="glass",
           tags=["whole"])
    cx, cy = 10, -118
    cracks = []
    for ang, ln in ((-100, 50), (-40, 44), (10, 38), (70, 52), (130, 46), (190, 40), (240, 34)):
        r = math.radians(ang)
        mx, my = cx + math.cos(r) * ln * 0.55, cy + math.sin(r) * ln * 0.55
        cracks += [LINE(cx, cy, mx, my, 2.2), LINE(mx, my, cx + math.cos(r + 0.25) * ln, cy + math.sin(r + 0.25) * ln, 1.8)]
    a.flat("cracks", cracks, "chrome", opacity=0.75, clip_to="glass", tags=["broken"], hidden=True)
    a.flat("missing", [POLY([(0, 0.2), (0.6, 0), (1, 0.7), (0.3, 1)], 14, -70, 26, 30)], "hole", clip_to="glass",
           tags=["broken"], hidden=True)
    a.add("shards", [POLY([(0, 0.6), (0.4, 0), (1, 0.3), (0.7, 1)], x, y, w, w * 0.6, rot=r) for x, y, w, r in
                     ((-30, 14, 20, 20), (26, 18, 16, -40), (8, 26, 12, 60))], "mass", "glass_dark", tags=["broken"],
          hidden=True, line=FINE)
    a.flat("pins", [E(-46, -104, 8, 8), E(46, -104, 8, 8)], "gold", line=FINE)
    a.add("crest", [I("triangle", 0, -186, 30, 14)], "mass", "wood_dark", line=FINE)
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    return a


@asset
def obj_counter_shop():
    a = Asset("obj_counter_shop", "Shop counter 2.0 m wide, 1.05 m high (waist height of the player): panelled wooden "
              "front, thick top, lift-up flap section at the east end.", seed=616)
    a.shadow([R(8, -40, 380, 104, 14)], opacity=0.34, blur=9)
    b = a.box("body", 0, 0, 360, 94, 100, "wood", corner=5)
    a.flat("panels", [R(x, b.front_cy + 4, 88, 72, 4) for x in (-130, -36, 58)], "wood_dark", opacity=0.6, line=THIN)
    a.flat("flap_gap", [R(148, b.front_cy + 4, 3, 90, 1)], "soot", opacity=0.8)
    t = a.box("top", 0, 6, 376, 104, 11, "wood", lift=100, corner=5)
    a.flat("top_joints", [R(0, t.top0 + 26 * k, 366, 2, 1) for k in range(1, 4)], "wood_dark", opacity=0.45)
    a.flat("flap_hinge", [R(148, t.top_cy, 3, 96, 1)], "iron")
    a.footprint = (-180, -94, 180, 0)
    return a


@asset
def obj_sofa():
    a = Asset("obj_sofa", "Gothic sofa 2.0 m: wine velvet seat, tall rounded back with buttons, rolled arms, three "
              "cushions, dark wood feet.", seed=617)
    a.shadow([R(8, -50, 380, 120, 16)], opacity=0.34, blur=10)
    a.add("back", [R(0, -182, 332, 118, 40)], "mass", "cloth_wine", shade={"bump": 0.9})
    a.flat("buttons", [E(x, y, 6, 6) for x in (-110, -55, 0, 55, 110) for y in (-196, -164)], "soot", opacity=0.8)
    a.box("feet", 0, 0, 340, 100, 12, "wood_dark", corner=2,
          top=lambda x, cy, w, d: [R(x - 160, cy, 12, d, 2), R(x + 160, cy, 12, d, 2)])
    seat = a.box("seat", 0, -2, 330, 104, 34, "cloth_wine", lift=12, corner=16)
    for i, x in enumerate((-106, 0, 106)):
        a.add(f"cushion{i}", [R(x, seat.top_cy - 4, 100, 88, 24)], "mass", "cloth_wine", shade={"bump": 1.1}, line=THIN)
    for i, x in enumerate((-172, 172)):
        a.add(f"arm{i}", [R(x, -80, 44, 130, 20), E(x, -140, 50, 36)], "mass", "cloth_wine", shade={"bump": 1.0})
    a.flat("trim", [R(0, seat.bottom - 4, 330, 5, 2)], "gold", line=FINE)
    a.footprint = (-194, -110, 194, 0)
    return a


@asset
def obj_piano():
    a = Asset("obj_piano", "Upright piano 1.5 m wide, 1.3 m high against a wall: dark lacquered case, candle brackets "
              "(unlit), keyboard shelf, pedals. Frames: closed (fallboard down), open (keys visible).", seed=618,
              pivot_meaning=WALLFRONT)
    a.shadow([R(8, -44, 290, 110, 14)], opacity=0.34, blur=9)
    body = a.box("case", 0, -44, 270, 50, 136, "wood_dark", corner=4)
    a.flat("panel", [R(0, body.front_cy - 20, 220, 70, 4)], "wood", opacity=0.5, line=THIN)
    a.flat("brackets", [R(-110, body.front_cy - 20, 6, 20, 2), R(110, body.front_cy - 20, 6, 20, 2)], "gold",
           line=FINE)
    a.box("legs", 0, -2, 262, 40, 60, "wood_dark", corner=2,
          top=lambda x, cy, w, d: [R(x - 124, cy, 14, d, 3), R(x + 124, cy, 14, d, 3)])
    a.box("lower", 0, -40, 250, 8, 58, "wood_dark", corner=3)
    a.flat("pedals", [R(x, -12, 12, 6, 2) for x in (-16, 0, 16)], "gold", line=FINE)
    kb = a.box("keybed", 0, 0, 270, 48, 12, "wood_dark", lift=60, corner=3)
    a.flat("keys_white", [R(0, kb.top_cy + 2, 250, 34, 2)], "paper", tags=["open"], hidden=True, line=FINE)
    a.flat("keys_joints", [R(-122 + k * 10, kb.top_cy + 2, 1.2, 32, 0.6) for k in range(25)], "paper_mark",
           tags=["open"], hidden=True)
    a.flat("keys_black", [R(-117 + k * 10, kb.top_cy - 6, 6, 18, 1) for k in range(24) if k % 7 not in (2, 6)], "soot",
           tags=["open"], hidden=True)
    a.add("fallboard", [R(0, kb.top_cy, 262, 40, 6)], "mass", "wood_dark", tags=["closed"], shade={"bump": 0.6})
    a.footprint = (-135, -94, 135, 0)
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
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
