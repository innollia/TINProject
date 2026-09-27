"""g04-dungeon-v01 recipes: crates, chests, barrels, torches, braziers, coffins, gates, levers, doors,
dark-fantasy props.

    python -B make_recipes.py              # write every recipe into ../recipes
    python -B make_recipes.py obj_crate    # only these

Fire boundary (GENERIC.md): torches and braziers are drawn as objects only.  Their "on" frame
shows glowing fuel / coals (``_emit.png``) and records ``anchors.flame_anchor`` where the game
puts the flame effect made by g01 / g02 (g10).  No flame shapes are painted here.
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
DOOR = "bottom centre of the opening on the wall-face floor line (threshold)"
WALL = "centre of the wall plate = attach point on the wall face"
FLAME = "#ffb45c"


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


# ============================================================================ A
@asset
def obj_crate():
    a = Asset("obj_crate", "Wooden crate 0.8 m cube: plank faces, frame boards, iron corner plates. "
              "Frames: normal, broken (low remains, standing shards, scattered planks, straw).", seed=501)
    a.shadow([R(8, -58, 160, 138, 14)], opacity=0.35, blur=9, tags=["whole"])
    b = a.box("body", 0, 0, 144, 125, 84, "wood", corner=6, tags=["whole"])
    planks_front(a, "front_joints", b, 3, tags=["whole"])
    planks_top(a, "top_joints", b, 4, tags=["whole"])
    a.flat("front_frame", [R(0, b.top1 + 5, 140, 9, 2), R(0, b.bottom - 5, 140, 9, 2), R(b.x0 + 6, b.front_cy, 11, 82, 2),
                           R(b.x1 - 6, b.front_cy, 11, 82, 2), LINE(b.x0 + 12, b.bottom - 9, b.x1 - 12, b.top1 + 9, 11)],
           "wood_pale", line=THIN, tags=["whole"])
    a.flat("top_frame", [R(0, b.top0 + 6, 138, 10, 2), R(0, b.top1 - 6, 138, 10, 2), R(b.x0 + 7, b.top_cy, 12, 112, 2),
                         R(b.x1 - 7, b.top_cy, 12, 112, 2)], "wood_pale", line=THIN, tags=["whole"])
    a.flat("corners", [R(b.x0 + 7, b.top1 + 7, 15, 15, 2), R(b.x1 - 7, b.top1 + 7, 15, 15, 2),
                       R(b.x0 + 7, b.bottom - 7, 15, 15, 2), R(b.x1 - 7, b.bottom - 7, 15, 15, 2)], "iron",
           line=THIN, tags=["whole"])
    a.flat("nails", rivets([(b.x0 + 7, b.top1 + 7), (b.x1 - 7, b.top1 + 7), (b.x0 + 7, b.bottom - 7),
                            (b.x1 - 7, b.bottom - 7), (0, b.front_cy)], 4), "bronze", tags=["whole"])
    # broken
    a.shadow([E(10, -40, 250, 110)], opacity=0.3, blur=9, name="shadow_broken", tags=["broken"], hidden=True)
    for i, (x, y, w, rot) in enumerate([(-96, -18, 92, 14), (84, -8, 100, -22), (-40, 22, 86, -6), (100, -70, 70, 64),
                                        (-110, -78, 64, -58)]):
        a.add(f"plank{i}", [R(x, y, w, 16, 3, rot=rot, ground=True)], "block", "wood", extrude=5,
              tags=["broken"], hidden=True, line=THIN)
    rb = a.box("remains", 0, 0, 144, 125, 26, "wood", corner=6, tags=["broken"], hidden=True)
    a.flat("remains_inside", [R(0, rb.top_cy, 124, 105, 4)], "hole", opacity=0.9, tags=["broken"], hidden=True,
           grad={"to": "well_inner", "y0": rb.top0, "y1": rb.top1})
    a.add("straw", [I("cloud", -10, rb.top_cy + 6, 100, 50), I("grass", 30, rb.top_cy - 4, 60, 34)], "mass", "thatch",
          rough={"amp": 0.5, "soft": 1.2, "cell": 5}, tags=["broken"], hidden=True, line=THIN)
    a.add("shards", [POLY([(0, 1), (0.1, 0.2), (0.35, 0.55), (0.55, 0), (0.8, 0.5), (1, 0.25), (1, 1)], -44, -70, 64, 64),
                     POLY([(0, 1), (0.2, 0.35), (0.5, 0.6), (0.7, 0.1), (1, 0.4), (1, 1)], 50, -52, 50, 44)],
          "mass", "wood", tags=["broken"], hidden=True, texture={"angle": 90})
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    a.footprint = (b.x0, -125, b.x1, 0)
    return a


@asset
def obj_chest():
    a = Asset("obj_chest", "Treasure chest 0.9 x 0.55 m, dark wood with dull gold straps, lock plate and keyhole. "
              "Frames: closed (rounded lid), open (lid raised at the back, coins and gems inside).", seed=502)
    a.shadow([R(8, -44, 176, 96, 14)], opacity=0.38, blur=9)
    a.add("lid_open", [R(0, -160, 166, 64, 18)], "mass", "wood_dark", tags=["open"], hidden=True,
          shade={"bump": 0.5}, texture={"angle": 90})
    a.flat("lid_open_straps", [R(-52, -160, 13, 64, 3), R(52, -160, 13, 64, 3), R(0, -191, 166, 8, 3)], "gold",
           line=THIN, tags=["open"], hidden=True, clip_to="lid_open")
    b = a.box("body", 0, 0, 162, 86, 47, "wood_dark", corner=6)
    planks_front(a, "front_joints", b, 2)
    a.flat("inside", [R(0, b.top_cy, 146, 70, 6)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": b.top0, "y1": b.top1})
    a.add("coins", [E(-34, b.top_cy + 2, 70, 40), E(20, b.top_cy - 4, 86, 44), E(52, b.top_cy + 8, 44, 26),
                    E(-6, b.top_cy - 16, 60, 26)], "mass", "gold", tags=["open"], hidden=True,
          rough={"amp": 0.35, "soft": 1.0, "cell": 4}, shade={"bump": 1.3, "highlight_amount": 0.8})
    a.flat("coin_marks", [E(-40, b.top_cy - 2, 12, 7), E(-20, b.top_cy + 8, 12, 7), E(10, b.top_cy - 10, 12, 7),
                          E(34, b.top_cy + 2, 12, 7), E(56, b.top_cy + 6, 10, 6)], "bronze", tags=["open"], hidden=True,
           line=THIN)
    a.add("gems", [I("diamond_shape", -8, b.top_cy - 8, 16, 14), I("diamond_shape", 38, b.top_cy - 14, 12, 11)],
          "mass", "crystal", tags=["open"], hidden=True, line=THIN)
    a.add("lid", [R(0, -100, 168, 96, 34)], "mass", "wood_dark", tags=["closed"], shade={"bump": 1.3},
          texture={"angle": 0})
    a.flat("lid_straps", [R(-52, -100, 14, 98, 3), R(52, -100, 14, 98, 3), R(0, -55, 168, 9, 3)], "gold",
           line=THIN, tags=["closed"], clip_to="lid")
    a.flat("straps", [R(-52, b.front_cy, 14, 45, 3), R(52, b.front_cy, 14, 45, 3), R(b.x0 + 5, b.bottom - 5, 12, 12, 2),
                      R(b.x1 - 5, b.bottom - 5, 12, 12, 2)], "gold", line=THIN)
    a.flat("lock", [R(0, -44, 26, 30, 4)], "gold", line=THIN)
    a.flat("keyhole", [I("keyhole", 0, -42, 8, 13)], "hole")
    a.flat("studs", rivets([(-52, -16), (52, -16), (-52, -36), (52, -36)], 4), "bronze")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    a.footprint = (b.x0, -86, b.x1, 0)
    return a


@asset
def obj_barrel():
    a = Asset("obj_barrel", "Upright wooden barrel 0.62 m wide, 0.9 m tall, four iron hoops. Frames: normal, "
              "broken (low remains, loose staves, a fallen hoop, a damp spill).", seed=503)
    dia, h = 112, 95
    dd = dia * SQ
    a.shadow([E(8, -dd / 2 + 4, dia + 20, dd + 10)], opacity=0.38, blur=8, tags=["whole"])
    b = a.cyl("body", 0, 0, dia, h, "wood", tags=["whole"])
    a.flat("staves", [R(x, -h / 2 - dd / 2 + 4, 2.4, h + dd - 10, 1) for x in (-40, -20, 0, 20, 40)], "wood_dark",
           opacity=0.65, clip_to="body", tags=["whole"])
    hoops = []
    for t in (12, 50, 84):
        hoops += band_on_cyl(0, -dd / 2 - t, dia, 7)
    a.flat("hoops", hoops, "iron", clip_to="body", line=THIN, tags=["whole"])
    a.flat("lid_rim", [E(0, b.top_cy, dia - 2, dd - 2), E(0, b.top_cy, dia - 16, dd - 14, op="sub")], "wood_dark",
           tags=["whole"])
    a.flat("lid_joints", [R(0, b.top_cy + k, dia - 22, 2, 1) for k in (-18, 0, 18)], "wood_dark", opacity=0.45,
           tags=["whole"])
    # broken
    a.wash("spill", [E(20, -8, 200, 70), E(-60, 10, 90, 36)], "damp", opacity=0.45, blur=6, tags=["broken"], hidden=True,
           rough={"amp": 0.6, "soft": 3, "cell": 14})
    a.shadow([E(8, -dd / 2 + 4, dia + 30, dd + 16)], opacity=0.32, blur=8, name="shadow_broken", tags=["broken"],
             hidden=True)
    a.add("hoop_fallen", [E(-80, 18, 106, 38, ground=True), E(-80, 17, 84, 24, ground=True, op="sub")], "mass", "iron",
          line=THIN, tags=["broken"], hidden=True, shade={"bump": 0.8})
    for i, (x, y, rot) in enumerate([(76, 10, -30), (96, -44, 70), (-96, -30, -64), (30, 30, 8)]):
        a.add(f"stave{i}", [R(x, y, 84, 15, 6, rot=rot, ground=True)], "block", "wood", extrude=5, line=THIN,
              tags=["broken"], hidden=True)
    rb = a.cyl("remains", 0, 0, dia, 40, "wood", hole=dia - 14, tags=["broken"], hidden=True)
    a.flat("remains_hoop", band_on_cyl(0, -dd / 2 - 12, dia, 8), "iron", clip_to="remains", line=THIN,
           tags=["broken"], hidden=True)
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    return a


def _torch_head(a, x, y, w, h):
    a.add("fuel_off", [E(x, y, w, h), I("cloud", x + 2, y - h * 0.3, w * 0.9, h * 0.6)], "mass", "soot",
          tags=["off"], line=THIN, rough={"amp": 0.35, "soft": 1.0, "cell": 4})
    a.add("fuel_on", [E(x, y, w, h), I("cloud", x + 2, y - h * 0.3, w * 0.9, h * 0.6)], "mass", "ember",
          tags=["on"], hidden=True, emit=0.8, glow={"radius": 6, "opacity": 0.6, "color": "ember_glow"},
          line=THIN, rough={"amp": 0.35, "soft": 1.0, "cell": 4})
    a.flat("fuel_wraps", [R(x, y - h * 0.18, w * 0.92, 3, 1, rot=-8), R(x, y + h * 0.18, w * 0.96, 3, 1, rot=6)],
           "soot", opacity=0.75, clip_to="fuel_on", tags=["on"], hidden=True)
    a.flat("fuel_wraps_off", [R(x, y - h * 0.18, w * 0.92, 3, 1, rot=-8), R(x, y + h * 0.18, w * 0.96, 3, 1, rot=6)],
           "ash", opacity=0.6, clip_to="fuel_off", tags=["off"])


@asset
def obj_torch_stand():
    a = Asset("obj_torch_stand", "Free-standing iron torch stand, 1.8 m: tripod foot, pole, cup with a pitch-soaked "
              "fuel bundle. Frames: off (charred fuel), on (glowing fuel + emit). Flame effect is not drawn: "
              "anchors.flame_anchor marks where the game adds it.", seed=504)
    ellipse_shadow(a, 8, -2, 90, 26, opacity=0.35, blur=6)
    a.add("feet", [LINE(0, -34, -38, -2, 9), LINE(0, -34, 38, -2, 9), LINE(0, -34, -4, 6, 8)], "mass", "iron")
    a.add("pole", [R(0, -100, 11, 150, 4), E(0, -34, 18, 12), E(0, -120, 16, 10)], "mass", "iron")
    a.add("cup", [I("cauldron", 0, -182, 50, 34, crop=[0.8, 5.6, 15.2, 16])], "mass", "iron")
    a.flat("cup_rim", [E(0, -196, 44, 13)], "soot")
    _torch_head(a, 0, -204, 30, 26)
    anchors = {"flame_anchor": [0, -214]}
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=anchors,
            light={"color": FLAME, "radius": 320, "at": [0, -214]})
    return a


@asset
def obj_torch_wall():
    a = Asset("obj_torch_wall", "Wall torch: riveted iron plate, arm and ring holding a wooden torch. Frames: off, on "
              "(glowing head + emit). Flame effect not drawn (anchors.flame_anchor).", seed=505,
              pivot_meaning=WALL, layer_hint="wall")
    a.shadow([R(7, 8, 30, 44, 6), R(9, 40, 18, 30, 4)], opacity=0.28, blur=6)
    a.add("plate", [R(0, 0, 26, 38, 5)], "mass", "iron", shade={"bump": 0.5})
    a.flat("plate_rivets", rivets([(0, -12), (0, 12)], 5), "bronze")
    a.add("arm", [LINE(0, 10, 0, 36, 7)], "mass", "iron")
    a.add("stick", [LINE(0, 52, 5, -16, 10)], "mass", "wood")
    a.flat("ring", [E(1, 36, 24, 11), E(1, 35, 14, 5, op="sub")], "iron", line=THIN)
    _torch_head(a, 6, -26, 22, 28)
    anchors = {"flame_anchor": [6, -40]}
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=anchors,
            light={"color": FLAME, "radius": 300, "at": [6, -40]})
    return a


@asset
def obj_brazier():
    a = Asset("obj_brazier", "Iron brazier on three legs, bowl 0.7 m wide. Frames: off (grey ash, charcoal), "
              "on (glowing coals + emit). Flame effect not drawn (anchors.flame_anchor).", seed=506)
    ellipse_shadow(a, 8, -4, 150, 44, opacity=0.4, blur=8)
    a.add("legs", [LINE(-42, -2, -30, -52, 9), LINE(42, -2, 30, -52, 9), LINE(0, 6, 0, -44, 9)], "mass", "iron")
    a.add("feet", [E(-42, -2, 16, 8), E(42, -2, 16, 8), E(0, 6, 16, 8)], "mass", "iron")
    a.add("bowl", [I("cauldron", 0, -70, 128, 72, crop=[0.8, 5.6, 15.2, 16])], "mass", "iron",
          shade={"bump": 1.1})
    a.flat("inside", [E(0, -104, 112, 24)], "soot")
    a.add("ash", [E(0, -102, 98, 18)], "mass", "ash", tags=["off"], line=THIN)
    a.add("charcoal", [E(-24, -104, 22, 10), E(8, -107, 20, 9), E(30, -101, 18, 8), E(-4, -99, 16, 7)], "mass",
          "soot", tags=["off"], line=THIN)
    a.add("coals", [E(0, -103, 100, 20)], "flat" if False else "mass", "ember", tags=["on"], hidden=True, emit=0.75,
          glow={"radius": 8, "opacity": 0.6, "color": "ember_glow"}, line=THIN)
    a.add("coal_lumps", [E(-26, -106, 22, 10), E(6, -109, 22, 10), E(30, -103, 18, 8), E(-6, -100, 18, 8)], "mass",
          "ember", tags=["on"], hidden=True, emit=0.9, line=THIN, shade={"highlight_amount": 0.9})
    a.flat("bowl_rim", [E(0, -106, 124, 30), E(0, -106, 112, 24, op="sub")], "iron", line=THIN)
    anchors = {"flame_anchor": [0, -112]}
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=anchors,
            light={"color": FLAME, "radius": 380, "at": [0, -120]})
    return a


COFFIN = [(0, 0.3), (0.22, 0), (1, 0.18), (1, 0.82), (0.22, 1), (0, 0.7)]


@asset
def obj_coffin():
    a = Asset("obj_coffin", "Gothic coffin 2.0 m long lying east-west (head to the west), dark wood, bronze cross inlay, "
              "iron handles. Frames: closed, open (lid on the floor in front, empty wine-cloth lining).", seed=507)
    a.shadow([POLY(COFFIN, 10, -48, 374, 116)], opacity=0.38, blur=9)
    b = a.box("body", 0, 0, 360, 103, 52, "wood_dark", top=lambda x, cy, w, d: POLY(COFFIN, x, cy, w, d))
    a.flat("handles", [E(x, -24, 24, 12) for x in (-60, 40, 130)] + [E(x, -26, 14, 6, op="sub") for x in (-60, 40, 130)],
           "iron", line=THIN)
    a.add("lid", [POLY(COFFIN, 0, -110, 350, 96)], "block", "wood_dark", extrude=8, tags=["closed"])
    a.flat("cross", [R(24, -112, 250, 9, 3), R(-70, -112, 9, 60, 3)], "bronze", line=THIN, tags=["closed"])
    a.flat("lid_studs", rivets([(-150, -112), (150, -140), (150, -84), (-80, -150), (-80, -74)], 5), "bronze",
           tags=["closed"])
    a.flat("inside", [POLY(COFFIN, 0, b.top_cy, 330, 82)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": b.top0, "y1": b.top1})
    a.add("lining", [POLY(COFFIN, 0, b.top_cy, 336, 88), POLY(COFFIN, 0, b.top_cy + 2, 300, 62, op="sub")], "mass",
          "cloth_wine", tags=["open"], hidden=True, line=THIN)
    a.add("pillow", [R(-132, b.top_cy, 44, 40, 14)], "mass", "cloth_wine", tags=["open"], hidden=True, line=THIN)
    a.shadow([POLY(COFFIN, 16, 74, 360, 100)], opacity=0.3, blur=8, name="shadow_lid", tags=["open"], hidden=True)
    a.add("lid_floor", [POLY(COFFIN, 10, 62, 350, 96, rot=4)], "block", "wood_dark", extrude=9, tags=["open"],
          hidden=True)
    a.flat("lid_floor_cross", [R(34, 60, 250, 9, 3, rot=4), R(-60, 54, 9, 60, 3, rot=4)], "bronze", line=THIN,
           tags=["open"], hidden=True)
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


def _bars(x0, x1, top, bottom, n):
    pieces, spikes = [], []
    for k in range(n):
        x = x0 + (x1 - x0) * k / (n - 1)
        pieces.append(R(x, (top + bottom) / 2, 9, bottom - top, 3))
        spikes.append(I("triangle", x, bottom + 5, 11, 12, flip="y"))
    return pieces, spikes


@asset
def obj_bar_door():
    a = Asset("obj_bar_door", "Iron-barred gate (portcullis) for a 1.2 m x 2.2 m dungeon opening: iron frame, "
              "8 bars with spiked feet, 3 crossbars, rivets. Frames: closed, open (grille raised into the lintel).",
              seed=508, pivot_meaning=DOOR)
    a.shadow([R(4, 2, 250, 14, 6)], opacity=0.3, blur=6, tags=["closed"])
    a.shadow([R(-120 + 6, 2, 30, 14, 4), R(120 + 6, 2, 30, 14, 4)], opacity=0.32, blur=5, name="shadow_posts")
    bars, spikes = _bars(-96, 96, -222, -8, 8)
    a.add("grille", bars, "mass", "iron", tags=["closed"], shade={"bump": 0.8})
    a.add("spikes", spikes, "mass", "iron", tags=["closed"], line=THIN)
    a.flat("crossbars", [R(0, y, 212, 10, 3) for y in (-196, -120, -44)], "iron", line=THIN, tags=["closed"])
    a.flat("bolts", rivets([(x, y) for y in (-196, -120, -44) for x in (-96, -41, 14, 69)], 5), "bronze",
           tags=["closed"])
    rb, rs = _bars(-96, 96, -234, -206, 8)
    a.add("grille_raised", rb, "mass", "iron", tags=["open"], hidden=True, shade={"bump": 0.8})
    a.add("spikes_raised", rs, "mass", "iron", tags=["open"], hidden=True, line=THIN)
    for i, x in enumerate((-120, 120)):
        a.box(f"post{i}", x, 0, 22, 20, 232, "iron", corner=3)
    a.box("lintel", 0, 0, 264, 20, 26, "iron", lift=232, corner=3)
    a.flat("lintel_rivets", rivets([(x, -245) for x in (-100, -50, 0, 50, 100)], 5), "bronze")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_lever():
    a = Asset("obj_lever", "Floor lever on a stone block: iron arm with a wooden knob. Frames: up, down.", seed=509)
    a.shadow([R(6, -18, 72, 50, 10)], opacity=0.35, blur=7)
    b = a.box("base", 0, 0, 64, 46, 18, "stone_dark", corner=5)
    a.flat("slot", [R(0, b.top_cy, 12, 30, 4)], "hole")
    a.add("arm_up", [LINE(0, b.top_cy, -24, -102, 8)], "mass", "iron", tags=["up"])
    a.add("knob_up", [E(-25, -104, 18, 16)], "mass", "wood_dark", tags=["up"])
    a.add("arm_down", [LINE(0, b.top_cy, 34, -52, 8)], "mass", "iron", tags=["down"], hidden=True)
    a.add("knob_down", [E(36, -52, 18, 16)], "mass", "wood_dark", tags=["down"], hidden=True)
    a.flat("hinge", [E(0, b.top_cy, 14, 11)], "iron", line=THIN)
    a.frame("up", state="up")
    a.frame("down", state="down", show=["down"], hide=["up"])
    return a


@asset
def obj_door_wood():
    a = Asset("obj_door_wood", "Wooden plank door 1.1 m x 2.1 m in a dark wood frame: iron straps, studs, ring "
              "handle. Frames: closed, open (dark doorway, leaf swung inward, seen through the opening).",
              seed=510, pivot_meaning=DOOR)
    a.shadow([R(4, 2, 250, 12, 5)], opacity=0.3, blur=6)
    a.flat("void", [R(0, -112, 198, 224, 2)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -224, "y1": 0, "curve": 0.7})
    a.add("leaf_open", [POLY([(0, 0.34), (1, 0.0), (1, 0.66), (0, 1.0)], -66, -120, 66, 250)], "mass", "wood",
          tags=["open"], hidden=True, clip_to="void", texture={"angle": 90}, shade={"bump": 0.5})
    a.add("leaf", [R(0, -112, 198, 224, 3)], "mass", "wood", tags=["closed"], shade={"bump": 0.35},
          texture={"angle": 90})
    a.flat("leaf_joints", [R(x, -112, 2.2, 218, 1) for x in (-66, -33, 0, 33, 66)], "wood_dark", opacity=0.55,
           tags=["closed"])
    a.flat("straps", [R(-34, -176, 128, 13, 3), R(-34, -52, 128, 13, 3)], "iron", line=THIN, tags=["closed"])
    a.flat("studs", rivets([(x, y) for y in (-176, -52) for x in (-86, -54, -22, 10)], 5), "bronze", tags=["closed"])
    a.flat("handle_plate", [R(62, -112, 18, 26, 4)], "iron", line=THIN, tags=["closed"])
    a.flat("handle_ring", [E(62, -98, 22, 22), E(62, -98, 14, 14, op="sub")], "iron", line=THIN, tags=["closed"])
    for i, x in enumerate((-108, 108)):
        a.box(f"jamb{i}", x, 0, 18, 18, 230, "wood_dark", corner=3)
    a.box("lintel", 0, 0, 236, 18, 20, "wood_dark", lift=226, corner=3)
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


# ============================================================================ B
@asset
def obj_wine_cask():
    a = Asset("obj_wine_cask", "Large wine cask 1.0 m across lying on a wooden cradle, round end facing south with "
              "hoops, stave joints and a bronze tap.", seed=511)
    a.shadow([R(8, -86, 230, 210, 30)], opacity=0.38, blur=10)
    for i, y in enumerate((-176, -20)):
        a.box(f"cradle{i}", 0, y, 214, 22, 44, "wood_dark", corner=3)
    a.add("body", [R(0, -168, 178, 236, 78)], "mass", "wood", texture={"angle": 90}, shade={"bump": 1.1})
    a.flat("body_hoops", [R(0, y, 180, 8, 3) for y in (-248, -206, -130, -92)], "iron", line=THIN, clip_to="body")
    a.flat("body_staves", [R(x, -168, 2.2, 230, 1) for x in (-60, -30, 0, 30, 60)], "wood_dark", opacity=0.5,
           clip_to="body")
    a.add("end", [E(0, -70, 184, 124)], "mass", "wood_dark", shade={"bump": 0.4})
    a.flat("end_staves", [R(x, -70, 2.2, 120, 1) for x in (-54, -18, 18, 54)], "wood", opacity=0.45, clip_to="end")
    a.flat("end_hoop", [E(0, -70, 184, 124), E(0, -70, 166, 108, op="sub")], "iron", line=THIN)
    a.add("tap", [R(0, -52, 14, 22, 4), LINE(0, -44, 0, -26, 7), E(0, -24, 12, 8)], "mass", "bronze", line=THIN)
    a.add("tap_handle", [R(0, -64, 26, 7, 3)], "mass", "bronze", line=THIN)
    return a


VASE = [(0.36, 0.0), (0.64, 0.0), (0.6, 0.1), (0.72, 0.22), (0.92, 0.46), (0.9, 0.7), (0.74, 0.9), (0.62, 1.0),
        (0.38, 1.0), (0.26, 0.9), (0.1, 0.7), (0.08, 0.46), (0.28, 0.22), (0.4, 0.1)]


@asset
def obj_vase():
    a = Asset("obj_vase", "Tall floor vase 0.8 m, blue-grey glaze with bronze and bone bands. Frames: normal, broken "
              "(low jagged remains and shards on the floor).", seed=512)
    ellipse_shadow(a, 8, -4, 100, 34, opacity=0.36, blur=7)
    a.add("body", [POLY(VASE, 0, -46, 92, 92)], "mass", "ceramic", tags=["whole"], shade={"bump": 1.2})
    a.flat("bands", [R(0, -68, 90, 6, 2), R(0, -30, 88, 10, 3), R(0, -12, 60, 4, 1)], "bronze", clip_to="body",
           tags=["whole"])
    a.flat("band_dots", [E(x, -30, 5, 5) for x in (-30, -15, 0, 15, 30)], "paper", clip_to="body", tags=["whole"])
    a.flat("mouth", [E(0, -90, 30, 10)], "hole", tags=["whole"])
    a.add("rim", [E(0, -90, 34, 12), E(0, -90, 26, 7, op="sub")], "mass", "ceramic", tags=["whole"], line=FINE)
    a.add("remains", [POLY([(0.1, 1), (0.02, 0.4), (0.2, 0.0), (0.35, 0.4), (0.5, 0.05), (0.66, 0.45), (0.82, 0.1),
                            (0.98, 0.45), (0.9, 1)], 0, -20, 88, 40)], "mass", "ceramic", tags=["broken"], hidden=True)
    a.flat("remains_inside", [E(0, -34, 60, 12)], "hole", tags=["broken"], hidden=True, clip_to="remains")
    shards = []
    for x, y, w, rot in ((-58, 8, 30, 20), (52, 12, 26, -30), (70, -8, 20, 50), (-36, 22, 22, -10), (18, 26, 18, 70)):
        shards.append(POLY([(0, 0.6), (0.4, 0), (1, 0.3), (0.7, 1)], x, y, w, w * 0.6, rot=rot))
    a.add("shards", shards, "mass", "ceramic", tags=["broken"], hidden=True, line=FINE)
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    return a


@asset
def obj_gift_box():
    a = Asset("obj_gift_box", "Big gift box 0.6 m cube in blue wrapping with a wine ribbon and bow. Frames: closed, open "
              "(lid on the floor beside it, crumpled paper inside).", seed=513)
    a.shadow([R(8, -44, 126, 104, 12)], opacity=0.34, blur=8)
    b = a.box("box", 0, 0, 108, 94, 62, "cloth_blue", corner=4)
    a.flat("ribbon_front", [R(0, b.front_cy, 14, 60, 2)], "cloth_wine", line=FINE)
    a.flat("inside", [R(0, b.top_cy, 96, 82, 3)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": b.top0, "y1": b.top1})
    a.add("paper", [I("cloud", -14, b.top_cy + 6, 56, 34), I("cloud", 20, b.top_cy - 4, 44, 28, flip="x")], "mass",
          "paper", tags=["open"], hidden=True, rough={"amp": 0.5, "soft": 1.0, "cell": 4}, line=FINE)
    a.shadow([R(98, 16, 110, 60, 10)], opacity=0.3, blur=6, name="shadow_lid", tags=["open"], hidden=True)
    lid_o = a.box("lid_floor", 92, 30, 116, 100, 14, "cloth_blue", corner=4, tags=["open"], hidden=True)
    a.flat("lid_floor_ribbon", [R(92, lid_o.top_cy, 116, 13, 2), R(92, lid_o.top_cy, 14, 100, 2)], "cloth_wine",
           tags=["open"], hidden=True, clip_to="lid_floor", line=FINE)
    lid = a.box("lid", 0, 4, 116, 100, 14, "cloth_blue", lift=56, corner=4, tags=["closed"])
    a.flat("lid_ribbon", [R(0, lid.top_cy, 116, 13, 2), R(0, lid.top_cy, 14, 100, 2), R(0, lid.front_cy, 14, 14, 2)],
           "cloth_wine", tags=["closed"], line=FINE)
    a.add("bow", [E(-18, lid.top_cy - 10, 34, 20, rot=-20), E(18, lid.top_cy - 10, 34, 20, rot=20),
                  I("triangle", -10, lid.top_cy + 8, 14, 20, rot=200), I("triangle", 12, lid.top_cy + 8, 14, 20, rot=160)],
          "mass", "cloth_wine", tags=["closed"], line=THIN)
    a.add("knot", [E(0, lid.top_cy - 8, 14, 12)], "mass", "cloth_wine", tags=["closed"], line=THIN)
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_altar():
    a = Asset("obj_altar", "Stone altar 1.6 m (dark fantasy, no religious emblem): carved block, wine cloth hanging "
              "over the front, bronze offering bowl, two iron candlesticks. Frames: off, on (candle wicks glow, emit; "
              "flames not drawn: anchors.flame_l / flame_r).", seed=514)
    a.shadow([R(8, -58, 310, 140, 14)], opacity=0.36, blur=10)
    a.box("step", 0, 14, 320, 150, 12, "stone_dark", corner=4)
    b = a.box("block", 0, 0, 288, 124, 100, "stone", corner=5)
    a.flat("carving", [R(-96, b.front_cy + 6, 60, 62, 4), R(96, b.front_cy + 6, 60, 62, 4)], "floor_joint", opacity=0.35,
           line=FINE)
    a.add("cloth", [R(0, b.top_cy, 110, 124, 3), R(0, b.top1 + 34, 110, 68, 3)], "mass", "cloth_wine",
          shade={"bump": 0.5})
    a.flat("cloth_hem", [R(0, b.top1 + 64, 110, 6, 2)], "gold", line=FINE)
    a.add("bowl", [I("cauldron", 0, b.top_cy - 4, 56, 32, crop=[0.8, 5.6, 15.2, 16])], "mass", "bronze")
    a.flat("bowl_inside", [E(0, b.top_cy - 16, 48, 12)], "soot")
    wicks = {}
    for side, x in (("l", -118), ("r", 118)):
        y = b.top_cy
        a.add(f"stick_{side}", [E(x, y + 6, 26, 12), R(x, y - 12, 7, 34, 2), E(x, y - 30, 20, 8)], "mass", "iron")
        a.add(f"candle_{side}", [R(x, y - 50, 14, 40, 4)], "mass", "paper", line=FINE)
        a.flat(f"wick_{side}_off", [R(x, y - 73, 3, 7, 1)], "soot", tags=["off"])
        a.flat(f"wick_{side}_on", [E(x, y - 74, 7, 9)], "flame", tags=["on"], hidden=True, emit=1.0,
               glow={"radius": 4, "opacity": 0.7, "color": "flame_glow"})
        wicks[f"flame_{side}"] = [x, y - 80]
    a.frame("off", state="off", anchors=wicks)
    a.frame("on", state="on", show=["on"], hide=["off"], anchors=wicks,
            light=[{"color": FLAME, "radius": 200, "at": wicks["flame_l"]},
                   {"color": FLAME, "radius": 200, "at": wicks["flame_r"]}])
    a.footprint = (-144, -124, 144, 0)
    return a


ROBE = [(0.3, 0.0), (0.7, 0.0), (0.78, 0.2), (0.86, 0.6), (1.0, 1.0), (0.0, 1.0), (0.14, 0.6), (0.22, 0.2)]


@asset
def obj_statue():
    a = Asset("obj_statue", "Gothic statue 2.2 m on a plinth: hooded robed figure with folded wings, weathered stone. "
              "Frames: normal, broken (upper body fallen in front, jagged break).", seed=515)
    a.shadow([R(8, -30, 150, 70, 12)], opacity=0.36, blur=8)
    a.box("plinth", 0, 0, 132, 66, 44, "stone_dark", corner=4)
    a.box("plinth_cap", 0, -4, 118, 58, 8, "stone", lift=44, corner=3)
    y0 = -52
    a.add("wings", [I("wing", -40, y0 - 120, 70, 130, rot=10, flip="x"), I("wing", 40, y0 - 120, 70, 130, rot=-10)],
          "mass", "marble", tags=["whole"], shade={"bump": 0.8})
    a.add("robe", [POLY(ROBE, 0, y0 - 76, 86, 152)], "mass", "marble", tags=["whole"])
    a.flat("folds", [LINE(-10, y0 - 20, -14, y0 - 110, 3), LINE(12, y0 - 20, 14, y0 - 104, 3)], "floor_joint",
           opacity=0.4, tags=["whole"], clip_to="robe")
    a.add("arms", [R(0, y0 - 104, 50, 22, 10)], "mass", "marble", tags=["whole"], line=THIN)
    a.add("hood", [E(0, y0 - 166, 44, 50), POLY([(0.5, 0), (1, 0.7), (0.5, 1), (0, 0.7)], 0, y0 - 186, 30, 24)], "mass",
          "marble", tags=["whole"])
    a.flat("face_shadow", [E(0, y0 - 160, 24, 28)], "hole", opacity=0.75, tags=["whole"])
    a.add("robe_stump", [POLY([(0.12, 1), (0.2, 0.2), (0.4, 0.45), (0.55, 0.0), (0.72, 0.4), (0.84, 0.15), (0.9, 1)],
                              0, y0 - 34, 86, 70)], "mass", "marble", tags=["broken"], hidden=True)
    a.add("fallen", [POLY(ROBE, 70, 34, 70, 120, rot=-78), E(126, 30, 40, 44)], "mass", "marble", tags=["broken"],
          hidden=True)
    a.add("fallen_wing", [I("wing", -80, 26, 60, 90, rot=70)], "mass", "marble", tags=["broken"], hidden=True)
    a.add("rubble", [POLY([(0, 0.6), (0.3, 0), (1, 0.3), (0.8, 1)], x, y, w, w * 0.6) for x, y, w in
                     ((-50, 14, 20), (20, 30, 16), (-20, 26, 14))], "mass", "marble", tags=["broken"], hidden=True,
          line=FINE)
    a.frame("normal", state="normal", hide=["broken"])
    a.frame("broken", state="broken", show=["broken"], hide=["whole"])
    return a


@asset
def obj_gate_castle():
    a = Asset("obj_gate_castle", "Castle gate for a 2.6 x 3.4 m arched opening: stone jambs and arch with voussoir "
              "joints, two heavy studded oak leaves with iron bands and ring handles. Frames: closed, open (leaves "
              "swung inward, seen through the dark opening).", seed=516, pivot_meaning=DOOR)
    W, H = 468, 357
    a.shadow([R(4, 4, W + 150, 18, 8)], opacity=0.32, blur=7)
    arch = [(0, 1), (0, 0.36), (0.06, 0.18), (0.2, 0.05), (0.5, 0.0), (0.8, 0.05), (0.94, 0.18), (1, 0.36), (1, 1)]
    a.flat("void", [POLY(arch, 0, -H / 2, W, H)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -H, "y1": 0, "curve": 0.7})
    for i, (x, pts) in enumerate(((-150, [(0, 0.3), (1, 0.0), (1, 0.7), (0, 1)]),
                                  (150, [(0, 0.0), (1, 0.3), (1, 1), (0, 0.7)]))):
        a.add(f"leaf_open{i}", [POLY(pts, x, -H / 2 + 10, 90, H + 60)], "mass", "wood", tags=["open"], hidden=True,
              clip_to="void", texture={"angle": 90}, shade={"bump": 0.5})
    a.add("leaves", [POLY(arch, 0, -H / 2, W, H)], "mass", "wood", tags=["closed"], shade={"bump": 0.3},
          texture={"angle": 90})
    a.flat("leaf_joints", [R(x, -H / 2 + 20, 2.4, H - 40, 1) for x in (-176, -118, -58, 58, 118, 176)] +
           [R(0, -H / 2, 5, H, 1)], "wood_dark", opacity=0.6, tags=["closed"], clip_to="leaves")
    a.flat("bands", [R(0, y, W, 16, 3) for y in (-300, -190, -70)], "iron", line=THIN, tags=["closed"], clip_to="leaves")
    a.flat("studs", rivets([(x, y) for y in (-300, -190, -70) for x in range(-210, 220, 40)], 6), "bronze",
           tags=["closed"], clip_to="leaves")
    a.flat("rings", [E(x, -150, 30, 30) for x in (-32, 32)] + [E(x, -150, 20, 20, op="sub") for x in (-32, 32)], "iron",
           line=THIN, tags=["closed"])
    jamb = []
    for side in (-1, 1):
        jamb.append(a.box(f"jamb{side + 1}", side * (W / 2 + 32), 0, 64, 40, 250, "stone", corner=4))
    a.add("arch_stones", [POLY(arch, 0, -H / 2 - 22, W + 128, H + 44), POLY(arch, 0, -H / 2 + 1, W - 2, H + 2, op="sub")],
          "mass", "stone", shade={"bump": 0.5})
    joints = []
    for k in range(9):
        t = math.pi * (k + 0.5) / 9
        cx, cy = 0, -H + H * 0.36
        r0x, r0y, r1x, r1y = W / 2, H * 0.64, W / 2 + 60, H * 0.64 + 40
        joints.append(LINE(cx - math.cos(t) * r0x, cy - math.sin(t) * r0y * 0.56, cx - math.cos(t) * r1x,
                           cy - math.sin(t) * r1y * 0.56, 3))
    a.flat("arch_joints", joints, "floor_joint", opacity=0.55, clip_to="arch_stones")
    a.flat("keystone", [POLY([(0.1, 0), (0.9, 0), (0.7, 1), (0.3, 1)], 0, -H - 6, 40, 44)], "stone_dark", line=THIN)
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


BOOKS = ["cloth_wine", "cloth_blue", "cloth_green", "cloth_ochre", "leather", "paper"]


def _book_rows(a, prefix, x0, x1, tops, max_h, tags, hidden=False):
    rng = a.rng
    by = {m: [] for m in BOOKS}
    for base in tops:
        x = x0 + 2
        while x < x1 - 6:
            w = rng.uniform(7, 13)
            if rng.random() < 0.1:
                x += rng.uniform(8, 14)
                continue
            h = rng.uniform(0.66, 1.0) * max_h
            by[rng.choice(BOOKS)].append(R(x + w / 2, base - h / 2, w, h, 1.5))
            x += w + rng.uniform(0.5, 2)
    for m, pieces in by.items():
        if pieces:
            a.flat(f"{prefix}_{m}", pieces, m, line=FINE, tags=tags, hidden=hidden)


@asset
def obj_door_secret():
    a = Asset("obj_door_secret", "Secret door disguised as a bookshelf (1.0 x 1.9 m). Frames: closed (looks like a plain "
              "bookshelf), open (the shelf swung out on its right hinge, dark passage and stone steps behind).",
              seed=517, pivot_meaning=DOOR)
    a.shadow([R(6, -24, 196, 64, 10)], opacity=0.34, blur=8, tags=["closed"])
    a.flat("passage", [R(0, -100, 176, 200, 3)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -200, "y1": 0, "curve": 0.6})
    a.flat("steps", [R(0, -30 - k * 26, 150 - k * 14, 6, 2) for k in range(5)], "stone", opacity=0.5,
           tags=["open"], hidden=True, clip_to="passage")
    a.box("frame_top", 0, 0, 196, 20, 14, "stone_dark", lift=200, corner=3, tags=["open"], hidden=True)
    for i, x in enumerate((-96, 96)):
        a.box(f"frame{i}", x, 0, 16, 20, 200, "stone_dark", corner=3, tags=["open"], hidden=True)
    a.shadow([R(150, 30, 60, 130, 10)], opacity=0.3, blur=8, name="shadow_open", tags=["open"], hidden=True)
    a.add("shelf_open", [POLY([(0, 0), (1, 0.28), (1, 1), (0, 0.72)], 128, -68, 64, 272)], "mass", "wood_dark",
          tags=["open"], hidden=True, texture={"angle": 90}, shade={"bump": 0.4})
    c = a.box("case", 0, 0, 180, 55, 200, "wood_dark", corner=4, tags=["closed"])
    a.flat("recess", [R(0, -103, 160, 184, 2)], "void", opacity=0.55, tags=["closed"])
    shelves = [-196 + 38 * k for k in range(1, 5)]
    _book_rows(a, "books", -80, 80, [y + 38 - 4 for y in [-196] + shelves], 30, tags=["closed"])
    a.flat("boards", [R(0, y, 164, 7, 2) for y in shelves] + [R(0, -8, 164, 9, 2)], "wood", line=THIN, tags=["closed"])
    a.box("cornice", 0, 3, 192, 62, 10, "wood", lift=200, corner=3, tags=["closed"])
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_trapdoor():
    a = Asset("obj_trapdoor", "Floor trapdoor 1.0 x 1.0 m (secret passage entrance): plank lid with iron hinges and "
              "ring. Frames: closed (flush with the floor), open (lid standing on its hinge, dark shaft with a ladder).",
              seed=518, pivot_meaning="front edge centre of the hatch on the floor", layer_hint="floor")
    fr = a.box("frame", 0, 0, 196, 170, 5, "wood_dark", corner=4)
    a.flat("shaft", [R(0, fr.top_cy, 170, 146, 3)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": fr.top0, "y1": fr.top1, "curve": 0.8})
    a.flat("ladder", [R(-40, fr.top_cy + 8, 8, 120, 2), R(40, fr.top_cy + 8, 8, 120, 2)] +
           [R(0, fr.top_cy - 40 + k * 26, 80, 6, 2) for k in range(5)], "wood", opacity=0.75, tags=["open"],
           hidden=True, clip_to="shaft", line=FINE)
    a.add("lid_up", [R(0, fr.top0 - 60, 176, 124, 4)], "mass", "wood", tags=["open"], hidden=True,
          texture={"angle": 90}, shade={"bump": 0.4})
    a.flat("lid_up_joints", [R(x, fr.top0 - 60, 2.2, 118, 1) for x in (-58, -18, 22, 62)], "wood_dark", opacity=0.55,
           tags=["open"], hidden=True, clip_to="lid_up")
    a.flat("lid_up_straps", [R(-40, fr.top0 - 30, 60, 10, 3), R(40, fr.top0 - 30, 60, 10, 3)], "iron", line=THIN,
           tags=["open"], hidden=True)
    lid = a.add("lid", [R(0, fr.top_cy, 176, 150, 4)], "mass", "wood", tags=["closed"], texture={"angle": 90},
                shade={"bump": 0.3})
    a.flat("lid_joints", [R(x, fr.top_cy, 2.2, 144, 1) for x in (-58, -18, 22, 62)], "wood_dark", opacity=0.55,
           tags=["closed"], clip_to="lid")
    a.flat("hinges", [R(-50, fr.top0 + 16, 60, 11, 3), R(50, fr.top0 + 16, 60, 11, 3)], "iron", line=THIN,
           tags=["closed"])
    a.flat("ring", [E(0, fr.top1 - 26, 28, 20), E(0, fr.top1 - 26, 18, 12, op="sub")], "iron", line=THIN,
           tags=["closed"])
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_door_balcony():
    a = Asset("obj_door_balcony", "Gothic balcony / French double door 1.4 x 2.4 m: dark frame, pointed transom, "
              "glazed leaves with mullions, bronze handles. Frames: closed, open (leaves swung toward the viewer, dark "
              "room behind).", seed=519, pivot_meaning=DOOR)
    W, H = 252, 252
    a.shadow([R(4, 2, W + 60, 14, 6)], opacity=0.3, blur=6, tags=["closed"])
    a.shadow([R(4, 30, W + 160, 90, 10)], opacity=0.28, blur=8, name="shadow_open", tags=["open"], hidden=True)
    a.flat("void", [R(0, -H / 2, W, H, 2)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -H, "y1": 0, "curve": 0.7})
    for i, x in enumerate((-W / 4, W / 4)):
        a.flat(f"leaf{i}", [R(x, -H / 2, W / 2 - 4, H - 4, 3)], "wood_dark", line=THIN, tags=["closed"])
        a.add(f"glass{i}", [R(x, -H / 2 - 12, W / 2 - 34, H - 58, 3)], "mass", "glass_dark", tags=["closed"],
              shade={"bump": 0.4, "highlight_amount": 0.7})
        a.flat(f"mullions{i}", [R(x, -H / 2 - 12, 4, H - 58, 1)] + [R(x, -H / 2 - 12 + dy, W / 2 - 34, 4, 1)
                                                                    for dy in (-60, 0, 60)], "wood_dark",
               tags=["closed"])
    a.flat("handles", [R(-10, -120, 5, 20, 2), R(10, -120, 5, 20, 2)], "bronze", line=FINE, tags=["closed"])
    for i, (x, pts) in enumerate(((-W / 2 - 34, [(1, 0), (1, 0.74), (0, 1), (0, 0.26)]),
                                  (W / 2 + 34, [(0, 0), (0, 0.74), (1, 1), (1, 0.26)]))):
        a.add(f"leaf_open{i}", [POLY(pts, x, -H / 2 + 44, 68, H + 88)], "mass", "wood_dark", tags=["open"], hidden=True,
              shade={"bump": 0.4})
        a.add(f"leaf_open_glass{i}", [POLY(pts, x, -H / 2 + 36, 44, H + 30)], "mass", "glass_dark", tags=["open"],
              hidden=True, clip_to=f"leaf_open{i}", shade={"bump": 0.3, "highlight_amount": 0.7})
    for i, x in enumerate((-W / 2 - 12, W / 2 + 12)):
        a.box(f"jamb{i}", x, 0, 24, 20, H + 4, "wood_dark", corner=3)
    tr = [(0, 1), (0, 0.5), (0.5, 0.0), (1, 0.5), (1, 1)]
    a.add("transom", [POLY(tr, 0, -H - 40, W + 48, 84)], "mass", "wood_dark", shade={"bump": 0.4})
    a.add("transom_glass", [POLY(tr, 0, -H - 36, W - 20, 60)], "mass", "glass_dark", clip_to="transom",
          shade={"bump": 0.3, "highlight_amount": 0.7})
    a.flat("transom_bars", [R(0, -H - 36, 4, 60, 1), LINE(-60, -H - 10, 0, -H - 60, 4), LINE(60, -H - 10, 0, -H - 60, 4)],
           "wood_dark", clip_to="transom")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


# ============================================================================ C
@asset
def obj_guillotine():
    a = Asset("obj_guillotine", "Guillotine 2.8 m (dark fantasy, empty device only): wooden platform, two grooved posts, "
              "crossbeam, raised slanted blade on its weight block, rope, lunette boards.", seed=521)
    a.shadow([R(10, -40, 260, 110, 12)], opacity=0.36, blur=9)
    base = a.box("platform", 0, 0, 240, 100, 30, "wood_dark", corner=4)
    planks_top(a, "platform_planks", base, 4, along_x=False)
    for i, x in enumerate((-58, 58)):
        a.box(f"post{i}", x, -40, 22, 20, 270, "wood", lift=30, corner=3)
        a.flat(f"groove{i}", [R(x + (8 if i == 0 else -8), -190, 4, 250, 1)], "wood_dark", opacity=0.7)
    a.box("beam", 0, -40, 160, 26, 22, "wood", lift=300, corner=3)
    a.add("weight", [R(0, -276, 94, 30, 4)], "mass", "wood_dark")
    a.add("blade", [POLY([(0, 0), (1, 0), (1, 0.45), (0, 1)], 0, -236, 94, 50)], "mass", "steel",
          shade={"highlight": 0.8, "highlight_amount": 0.8})
    a.flat("blade_edge", [LINE(-46, -212, 46, -236, 3)], "chrome", opacity=0.6)
    a.flat("rope", [R(64, -300, 3, 140, 1), LINE(64, -370, 30, -380, 3)], "rope")
    a.add("lunette", [R(0, -106, 110, 44, 6)], "mass", "wood", shade={"bump": 0.4})
    a.flat("lunette_hole", [E(0, -106, 32, 30)], "hole")
    a.flat("lunette_split", [R(0, -106, 110, 3, 1)], "wood_dark")
    return a


@asset
def obj_gallows():
    a = Asset("obj_gallows", "Gallows (dark fantasy, empty): raised plank platform on posts, side steps, upright with "
              "a braced crossbeam and an empty noose.", seed=522)
    a.shadow([R(20, -100, 380, 220, 20)], opacity=0.36, blur=12)
    for i, x in enumerate((-140, 140)):
        a.box(f"leg_back{i}", x, -186, 16, 14, 105, "wood_dark", corner=2)
    up = a.box("upright", 100, -150, 22, 20, 340, "wood", lift=105, corner=3)
    p = a.box("platform", 0, 0, 312, 200, 105, "wood", corner=4)
    planks_top(a, "planks", p, 6, along_x=False)
    a.flat("trapdoor", [R(-20, p.top_cy, 110, 90, 2)], "wood_dark", opacity=0.6, line=FINE)
    a.box("beam", 20, -150, 190, 18, 20, "wood", lift=425, corner=3)
    a.add("brace", [LINE(100, -600, 60, -640, 12)], "mass", "wood")
    a.flat("noose_rope", [R(-50, -590, 3, 70, 1)], "rope")
    a.add("noose", [E(-50, -538, 26, 36), E(-50, -538, 16, 26, op="sub"), R(-50, -560, 8, 14, 3)], "mass", "rope",
          line=FINE)
    steps = []
    for k in range(4):
        steps.append(a.box(f"step{k}", 196, -40 - k * 30, 70, 30, 25 * (k + 1), "wood", corner=3))
    a.footprint = (-156, -200, 231, 0)
    return a


MAIDEN = [(0.5, 0.0), (0.82, 0.08), (0.9, 0.3), (0.84, 1.0), (0.16, 1.0), (0.1, 0.3), (0.18, 0.08)]


@asset
def obj_iron_maiden():
    a = Asset("obj_iron_maiden", "Iron maiden (dark fantasy, empty): tall riveted iron cabinet on a plinth with a hooded "
              "helm top. Frames: closed, open (doors swung aside, spikes inside, dark empty interior).", seed=523)
    a.shadow([R(8, -30, 150, 70, 12)], opacity=0.36, blur=8, tags=["closed"])
    a.shadow([R(8, -10, 280, 110, 12)], opacity=0.3, blur=8, name="shadow_open", tags=["open"], hidden=True)
    a.box("plinth", 0, 0, 128, 64, 20, "stone_dark", corner=4)
    a.add("shell", [POLY(MAIDEN, 0, -120, 116, 200)], "mass", "iron")
    a.flat("inside", [POLY(MAIDEN, 0, -114, 92, 176)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -200, "y1": -26})
    spikes = [I("triangle", x, y, 10, 16, rot=90 if x < 0 else -90) for x in (-28, 28) for y in range(-170, -40, 26)]
    a.add("spikes", spikes, "mass", "steel", tags=["open"], hidden=True, line=FINE)
    a.add("doors", [POLY(MAIDEN, 0, -114, 100, 184)], "mass", "iron", tags=["closed"], shade={"bump": 0.5})
    a.flat("door_split", [R(0, -110, 3, 170, 1)], "soot", tags=["closed"])
    a.flat("bands", [R(0, y, 100, 8, 2) for y in (-170, -110, -50)], "iron", line=FINE, tags=["closed"],
           clip_to="doors")
    a.flat("rivets", rivets([(x, y) for y in (-170, -110, -50) for x in (-36, -18, 18, 36)], 5), "bronze",
           tags=["closed"])
    for i, (x, pts) in enumerate(((-86, [(1, 0), (1, 0.8), (0, 1), (0, 0.2)]), (86, [(0, 0), (0, 0.8), (1, 1),
                                                                                    (1, 0.2)]))):
        a.add(f"door_open{i}", [POLY(pts, x, -94, 64, 210)], "mass", "iron", tags=["open"], hidden=True,
              shade={"bump": 0.4})
        a.add(f"door_open{i}_spikes", [I("triangle", x + (10 if i == 0 else -10), y, 10, 14,
                                         rot=90 if i == 1 else -90) for y in range(-150, -40, 28)], "mass", "steel",
              tags=["open"], hidden=True, line=FINE)
    a.add("helm", [E(0, -214, 64, 44), POLY([(0.5, 0), (1, 1), (0, 1)], 0, -240, 30, 20)], "mass", "iron")
    a.flat("helm_slit", [R(0, -212, 34, 5, 2)], "hole")
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_saw_trap():
    a = Asset("obj_saw_trap", "Floor saw-blade trap: riveted iron floor plate with a long slot. Frames: hidden (slot "
              "only), out (toothed blade risen from the slot).", seed=524,
              pivot_meaning="front edge centre of the plate on the floor", layer_hint="floor")
    p = a.box("plate", 0, 0, 240, 110, 5, "iron", corner=5)
    a.flat("plate_rivets", rivets([(x, y) for x in (-108, 108) for y in (p.top0 + 12, p.top1 - 12)], 6), "bronze")
    a.flat("slot", [R(0, p.top_cy, 190, 10, 4)], "hole")
    a.add("blade", [I("cog", 0, p.top_cy - 24, 160, 104, crop=[0.3, 0.3, 15.7, 8.0])], "mass", "steel", tags=["out"],
          hidden=True, shade={"highlight": 0.8, "highlight_amount": 0.8})
    a.flat("blade_hub", [E(0, p.top_cy - 2, 30, 14, half="top", fit=[1, 1, 15, 15])], "iron", tags=["out"], hidden=True)
    a.flat("slot_front", [R(0, p.top_cy + 3, 190, 5, 2)], "hole", tags=["out"], hidden=True)
    a.wash("stain", [E(40, p.top_cy + 10, 120, 40)], "rust", opacity=0.35, blur=6)
    a.frame("hidden", state="hidden")
    a.frame("out", state="out", show=["out"])
    return a


CROOKED = [(0.06, 0.0), (0.94, 0.06), (1.0, 1.0), (0.0, 0.96)]


@asset
def obj_door_strange():
    a = Asset("obj_door_strange", "Strange door (dark fantasy): crooked frame, too-tall leaning leaf with mismatched "
              "panels, three locks and a faintly glowing keyhole. Frames: closed, open (violet-dark void, no effect).",
              seed=525, pivot_meaning=DOOR)
    a.shadow([R(4, 2, 200, 12, 5)], opacity=0.3, blur=6)
    a.add("frame", [POLY(CROOKED, 4, -140, 196, 284, rot=3)], "mass", "wood_dark", shade={"bump": 0.4})
    a.flat("void", [POLY(CROOKED, 4, -136, 160, 260, rot=3)], "hole", tags=["open"], hidden=True,
           grad={"to": "well_inner", "y0": -270, "y1": 0, "curve": 0.5})
    a.wash("void_tint", [E(4, -130, 120, 200)], "petal_violet", opacity=0.45, blend="normal", blur=16, clip_to="void",
           tags=["open"], hidden=True)
    a.add("leaf", [POLY(CROOKED, 4, -136, 160, 260, rot=3)], "mass", "wood", tags=["closed"], shade={"bump": 0.4},
          texture={"angle": 88})
    a.flat("panels", [POLY([(0, 0), (1, 0.1), (0.9, 1), (0.05, 0.9)], -24, -200, 56, 70, rot=6),
                      POLY([(0.1, 0), (1, 0), (1, 1), (0, 0.85)], 34, -150, 50, 90, rot=-4),
                      R(-10, -70, 90, 44, 4, rot=5)], "wood_pale", opacity=0.7, line=FINE, tags=["closed"],
           clip_to="leaf")
    a.flat("locks", [R(56, -196, 16, 18, 3, rot=4), R(58, -150, 18, 16, 3), R(60, -104, 14, 20, 3, rot=-6)], "iron",
           line=FINE, tags=["closed"])
    a.flat("keyhole", [I("keyhole", 60, -104, 7, 11)], "crystal", tags=["closed"], emit=0.8,
           glow={"radius": 4, "opacity": 0.6, "color": "crystal_glow"})
    a.flat("knob", [E(40, -128, 16, 16)], "gold", line=FINE, tags=["closed"])
    a.frame("closed", state="closed")
    a.frame("open", state="open", show=["open"], hide=["closed"])
    return a


@asset
def obj_wall_shackles():
    a = Asset("obj_wall_shackles", "Wall shackles (dark fantasy): riveted iron plate with two chains ending in open "
              "cuffs, rust.", seed=526, pivot_meaning=WALL, layer_hint="wall")
    a.shadow([R(8, 30, 110, 110, 12)], opacity=0.22, blur=8)
    a.add("plate", [R(0, 0, 96, 30, 5)], "mass", "iron", shade={"bump": 0.5})
    a.flat("plate_rivets", rivets([(-38, 0), (38, 0), (0, 0)], 6), "bronze")
    chains = []
    for x, n, dx in ((-30, 7, -2), (30, 6, 3)):
        for k in range(n):
            chains.append(I("link", x + dx * k, 20 + k * 13, 16, rot=45 if k % 2 else -45))
    a.flat("chains", chains, "iron", line=FINE)
    a.add("cuffs", [E(-44, 120, 34, 24), E(-44, 120, 22, 14, op="sub"), E(48, 108, 34, 24), E(48, 108, 22, 14, op="sub")],
          "mass", "iron", line=FINE, grime={"stamps": ["metaballs", "sponge"], "size": 10, "soft": 1, "density": 0.5,
                                           "strength": 0.4, "color": "rust"})
    return a


@asset
def obj_cage_large():
    a = Asset("obj_cage_large", "Large dome-topped iron cage 1.6 m (dark fantasy, empty): base ring, vertical bars "
              "curving to a crown ring and hook, bar door. Frames: closed, open (door swung aside).", seed=527)
    ellipse_shadow(a, 8, -60, 190, 120, opacity=0.34, blur=9)
    dia = 170
    base = a.cyl("base", 0, 0, dia, 14, "iron")
    a.flat("floor", [E(0, base.top_cy, dia - 16, (dia - 16) * SQ)], "wood_dark", line=FINE)
    back, front = [], []
    for k in range(16):
        t = 2 * math.pi * k / 16
        x = (dia / 2 - 4) * math.cos(t)
        yb = base.top_cy + (dia / 2 - 4) * SQ * math.sin(t)
        bar = [LINE(x, yb, x * 0.9, yb - 140, 5), LINE(x * 0.9, yb - 140, x * 0.2, -226 + (yb - base.top_cy) * 0.15, 5)]
        (back if math.sin(t) < 0 else front).append((k, bar))
    a.add("bars_back", [p for _, bar in back for p in bar], "mass", "iron", line=FINE)
    a.flat("rings", [E(0, base.top_cy - 70, dia - 18, (dia - 18) * SQ), E(0, base.top_cy - 70, dia - 26, (dia - 26) * SQ,
                                                                          op="sub")], "iron", line=FINE)
    door_keys = {4, 5}
    a.add("bars_front", [p for k, bar in front if k not in door_keys for p in bar], "mass", "iron", line=FINE)
    a.add("door_bars", [p for k, bar in front if k in door_keys for p in bar], "mass", "iron", line=FINE,
          tags=["closed"])
    a.add("door_open", [LINE(dia / 2 + 10 + 30 * j, base.top_cy + 40 - 8 * j, dia / 2 + 16 + 30 * j,
                             base.top_cy - 90 - 8 * j, 5) for j in range(2)] +
          [LINE(dia / 2 + 6, base.top_cy - 20, dia / 2 + 52, base.top_cy - 36, 4),
           LINE(dia / 2 + 8, base.top_cy - 80, dia / 2 + 54, base.top_cy - 96, 4)], "mass", "iron", line=FINE,
          tags=["open"], hidden=True)
    a.add("crown", [E(0, -226, 40, 18), R(0, -242, 6, 26, 2), E(0, -258, 20, 20), E(0, -258, 12, 12, op="sub")],
          "mass", "iron", line=FINE)
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
