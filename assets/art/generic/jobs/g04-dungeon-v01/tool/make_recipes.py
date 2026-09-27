"""g04-dungeon-v01 recipes: crates, chests, barrels, torches, braziers, coffins, gates, levers, doors,
dark-fantasy props.

    python -B make_recipes.py              # write every recipe into ../recipes
    python -B make_recipes.py obj_crate    # only these

Fire boundary (GENERIC.md): torches and braziers are drawn as objects only.  Their "on" frame
shows glowing fuel / coals (``_emit.png``) and records ``anchors.flame_anchor`` where the game
puts the flame effect made by g01 / g02 (g10).  No flame shapes are painted here.
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


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
