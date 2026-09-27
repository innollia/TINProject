"""g04-nature-v01 recipes: trees, bushes, grass, flowers, mushrooms, rocks, logs.

    python -B make_recipes.py              # write every recipe into ../recipes
    python -B make_recipes.py obj_bush     # only these
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g04kit import (E, I, LINE, MD, MH, MW, POLY, R, Asset, ellipse_shadow)  # noqa: E402,F401

JOB = Path(__file__).resolve().parents[1]
ASSETS = {}

THIN = {"width": 0.9, "heavy": 0.9, "breaks": 0.3}
FINE_T = {"width": 0.8, "heavy": 0.9}

FOLIAGE_ROUGH = {"amp": 0.45, "soft": 2.0, "cell": 9}
NEEDLE_ROUGH = {"amp": 0.55, "soft": 1.6, "cell": 7}
TRUNK = "trunk base centre on the ground"


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


def canopy(a, name, blobs, material, rough=FOLIAGE_ROUGH, **kw):
    return a.add(name, blobs, "mass", material, rough=rough, **kw)


# ============================================================================ A
@asset
def obj_tree_oak():
    a = Asset("obj_tree_oak", "Broad-leaf tree (young oak), about 4.8 m tall with a 2.2 m crown. Dark back crown, "
              "trunk with root flare and branch stubs, lighter front clumps. No face (tree monsters are g05).",
              seed=401, pivot_meaning=TRUNK)
    ellipse_shadow(a, 18, -4, 300, 92, opacity=0.4, blur=12)
    canopy(a, "crown_back", [
        E(0, -300, 370, 280), I("cloud", -110, -345, 205, 140), I("cloud", 112, -335, 210, 150, flip="x"),
        E(-150, -255, 150, 125), E(152, -250, 150, 125), E(0, -420, 250, 170),
        I("leaf", -196, -292, 36, rot=-70), I("leaf", 198, -270, 34, rot=64),
        E(-176, -270, 64, 54), E(-120, -440, 70, 58), E(-40, -478, 76, 60), E(60, -470, 70, 56),
        E(146, -420, 66, 54), E(184, -300, 60, 52)],
        "foliage_dark")
    a.add("trunk", [R(0, -95, 48, 190, 16), E(0, -8, 98, 28), I("triangle", -30, -12, 44, 24, rot=-24),
                    I("triangle", 31, -11, 40, 22, rot=26)], "mass", "bark")
    a.add("branches", [LINE(-6, -150, -78, -236, 18), LINE(8, -160, 86, -246, 16), LINE(0, -170, 6, -262, 20)],
          "mass", "bark")
    a.flat("knot", [E(8, -110, 12, 18)], "hole", opacity=0.85)
    canopy(a, "crown_low", [E(-100, -232, 170, 124), E(98, -226, 176, 130), E(0, -212, 182, 110)], "foliage")
    canopy(a, "crown_top", [E(-62, -380, 200, 150), E(72, -392, 170, 128), E(-6, -300, 210, 146),
                            E(-146, -318, 110, 96), E(140, -312, 116, 100)], "foliage")
    a.wash("crown_damp", [E(40, -250, 260, 90)], "damp", opacity=0.25, blur=10, clip_to="crown_low")
    return a


@asset
def obj_tree_fir():
    a = Asset("obj_tree_fir", "Fir / conifer, about 4 m tall: five needle tiers with serrated lower edges, short trunk.",
              seed=402, pivot_meaning=TRUNK)
    ellipse_shadow(a, 14, -4, 210, 70, opacity=0.4, blur=10)
    a.add("trunk", [R(0, -42, 28, 88, 8), E(0, -6, 60, 18)], "mass", "bark")
    tiers = [(-118, 236, 150), (-196, 196, 138), (-270, 156, 124), (-338, 112, 108), (-396, 66, 80)]
    for i, (y, w, h) in enumerate(tiers):
        teeth = []
        n = max(3, int(w / 40))
        for k in range(n):
            x = -w / 2 + 16 + (w - 32) * k / max(1, n - 1)
            teeth.append(I("grass", x, y + h / 2 - 2, 44, 22, flip="y" if k % 2 else "xy"))
        a.add(f"tier{i}", [I("triangle", 0, y, w, h)] + teeth, "mass", "foliage_dark", rough=NEEDLE_ROUGH,
              texture={"angle": 80})
    return a


@asset
def obj_tree_dead():
    a = Asset("obj_tree_dead", "Dead tree (dark fantasy): pale bare trunk, crooked branches and twigs, knot hole.",
              seed=403, pivot_meaning=TRUNK)
    ellipse_shadow(a, 12, -4, 160, 48, opacity=0.4, blur=9)
    a.add("trunk", [R(0, -112, 40, 224, 14), I("triangle", 2, -236, 32, 86), E(0, -6, 86, 24),
                    I("triangle", -28, -10, 40, 22, rot=-26), I("triangle", 29, -9, 36, 20, rot=28)],
          "mass", "bark_pale")
    a.add("branches", [
        LINE(-4, -160, -92, -250, 14), LINE(-62, -222, -124, -238, 8), LINE(-86, -246, -102, -304, 8),
        LINE(6, -192, 96, -282, 13), LINE(70, -256, 124, -266, 7), LINE(92, -278, 100, -334, 7),
        LINE(0, -232, -22, -332, 10), LINE(-20, -312, -52, -352, 6), LINE(-16, -322, 10, -368, 6),
        LINE(-102, -300, -128, -330, 5), LINE(-104, -296, -96, -334, 4), LINE(-124, -238, -150, -222, 5),
        LINE(100, -330, 124, -356, 4), LINE(98, -328, 90, -362, 4), LINE(124, -266, 150, -252, 5),
        LINE(-50, -350, -70, -372, 4), LINE(10, -366, 26, -392, 4), LINE(8, -364, -2, -394, 3)], "mass", "bark_pale")
    a.flat("knot", [E(6, -128, 14, 22), E(-8, -70, 8, 12)], "hole", opacity=0.9)
    a.flat("cracks", [I("lightning_bolt", -8, -100, 6, 60, rot=4), I("lightning_bolt", 10, -180, 5, 44, rot=-8)],
           "floor_joint", opacity=0.6)
    return a


@asset
def obj_bush():
    a = Asset("obj_bush", "Round shrub about 1.1 m wide and 1 m tall, two leaf layers.", seed=404)
    ellipse_shadow(a, 10, -6, 214, 58, opacity=0.38, blur=9)
    canopy(a, "back", [E(0, -72, 212, 124), I("cloud", -56, -98, 122, 82), I("cloud", 60, -94, 122, 86, flip="x"),
                       I("leaf", -108, -70, 26, rot=-70), I("leaf", 110, -64, 24, rot=70)], "foliage_dark")
    canopy(a, "front", [E(-60, -50, 112, 80), E(56, -48, 116, 82), E(0, -40, 122, 70), E(-12, -106, 120, 80)],
           "foliage")
    return a


@asset
def obj_grass_tuft():
    a = Asset("obj_grass_tuft", "Low grass tuft about 0.35 m tall (no collision).", seed=405)
    ellipse_shadow(a, 4, -3, 96, 20, opacity=0.28, blur=5)
    a.add("back", [I("grass", -14, -30, 60, 58), I("grass", 20, -28, 54, 52, flip="x")], "mass", "foliage_dark",
          line={"width": 0.9, "heavy": 1.0})
    a.add("front", [I("grass", 0, -22, 62, 46), I("grass", -30, -14, 36, 30, rot=-18),
                    I("grass", 32, -15, 34, 32, rot=16, flip="x"), I("grass", 8, -30, 30, 54, rot=6)],
          "mass", "grass", line={"width": 0.9, "heavy": 1.0}, rough={"amp": 0.3, "soft": 1.0, "cell": 5})
    return a


@asset
def obj_flowers():
    a = Asset("obj_flowers", "Wild flower patch: leaves, thin stems and three muted petal colours.", seed=406)
    ellipse_shadow(a, 4, -3, 126, 24, opacity=0.28, blur=5)
    a.add("leaves", [I("grass", -20, -26, 58, 52), I("grass", 22, -24, 52, 48, flip="x"),
                     I("leaf", -44, -12, 28, rot=-56), I("leaf", 44, -10, 26, rot=44)], "mass", "grass",
          line={"width": 0.9, "heavy": 1.0})
    a.flat("stems", [LINE(-24, -30, -30, -62, 3), LINE(0, -30, 2, -76, 3), LINE(24, -28, 30, -60, 3),
                     LINE(-8, -26, -14, -50, 3), LINE(12, -24, 16, -46, 3)], "foliage_dark")
    crop = [1, 1, 15, 11.4]
    a.add("petals_wine", [I("flower", -30, -66, 28, crop=crop), I("flower", 31, -63, 26, crop=crop)], "mass",
          "petal_wine", line={"width": 0.9, "heavy": 1.0})
    a.add("petals_ochre", [I("flower", 2, -80, 30, crop=crop)], "mass", "petal_ochre", line={"width": 0.9, "heavy": 1.0})
    a.add("petals_pale", [I("flower", -14, -52, 22, crop=crop), I("flower", 17, -47, 20, crop=crop)], "mass",
          "petal_pale", line={"width": 0.9, "heavy": 1.0})
    a.flat("centres", [E(-30, -66, 7, 6), E(31, -63, 6, 5), E(2, -80, 8, 7), E(-14, -52, 5, 5), E(17, -47, 5, 4)],
           "gold")
    return a


@asset
def obj_mushrooms():
    a = Asset("obj_mushrooms", "Cluster of four forest mushrooms (the tallest 0.45 m), spotted caps.", seed=407)
    ellipse_shadow(a, 4, -3, 124, 26, opacity=0.3, blur=5)
    a.add("stems", [R(-22, -22, 14, 40, 6), R(9, -32, 19, 58, 8), R(36, -14, 12, 26, 5), R(-45, -10, 10, 18, 4)],
          "mass", "mushroom_stem")
    cap = [0.8, 0.8, 15.2, 8.9]
    a.add("caps", [I("umbrella", -22, -46, 54, 30, crop=cap), I("umbrella", 9, -66, 70, 38, crop=cap),
                   I("umbrella", 36, -28, 40, 22, crop=cap), I("umbrella", -45, -20, 30, 17, crop=cap)],
          "mass", "mushroom_cap")
    a.flat("spots", [E(-30, -52, 8, 6), E(-16, -50, 6, 5), E(0, -74, 10, 7), E(18, -72, 8, 6), E(8, -80, 6, 5),
                     E(32, -32, 6, 5), E(42, -31, 5, 4)], "mushroom_stem", opacity=0.9)
    a.add("grass", [I("grass", -8, -6, 50, 20), I("grass", 30, -4, 34, 14, flip="x")], "mass", "grass",
          line={"width": 0.8, "heavy": 0.9})
    return a


@asset
def obj_rock_large():
    a = Asset("obj_rock_large", "Large boulder about 1.4 m wide and 1 m tall, faceted, damp stains and moss, "
              "two small stones at its foot.", seed=408)
    ellipse_shadow(a, 14, -8, 270, 76, opacity=0.42, blur=10)
    body = [(0.06, 0.64), (0.16, 0.3), (0.4, 0.08), (0.7, 0.1), (0.9, 0.34), (0.97, 0.66), (0.86, 0.93),
            (0.5, 1.0), (0.14, 0.92)]
    a.add("body", [POLY(body, 0, -88, 256, 178)], "mass", "rock", shade={"bump": 1.25})
    a.add("facet", [POLY([(0.0, 0.7), (0.22, 0.12), (0.62, 0.0), (1.0, 0.3), (0.7, 0.72), (0.3, 1.0)],
                         -24, -128, 150, 86)], "mass", "rock", shade={"bump": 0.6, "highlight_amount": 0.7},
          clip_to="body", line={"width": 1.0, "heavy": 0.8, "breaks": 0.4})
    a.add("side_facet", [POLY([(0.35, 0.0), (1.0, 0.2), (1.0, 0.85), (0.6, 1.0), (0.0, 0.8), (0.2, 0.35)],
                              70, -58, 130, 116)], "mass", "rock_dark", clip_to="body",
          shade={"bump": 0.7}, line={"width": 1.0, "heavy": 0.8, "breaks": 0.4})
    a.flat("cracks", [I("lightning_bolt", 40, -80, 8, 70, rot=-18), I("lightning_bolt", -60, -60, 6, 44, rot=30)],
           "floor_joint", opacity=0.6, clip_to="body")
    a.add("moss", [I("cloud", -40, -156, 90, 34), I("cloud", 50, -150, 60, 24, flip="x")], "mass", "moss",
          clip_to="body", rough={"amp": 0.5, "soft": 1.5, "cell": 6}, opacity=0.9)
    a.add("pebbles", [POLY([(0, 0.6), (0.3, 0.05), (0.8, 0), (1, 0.55), (0.6, 1)], 118, -16, 46, 32),
                      POLY([(0, 0.5), (0.4, 0), (1, 0.3), (0.8, 1), (0.2, 0.9)], -120, -12, 34, 24)],
          "mass", "rock_dark")
    return a


@asset
def obj_log_fallen():
    a = Asset("obj_log_fallen", "Fallen log about 1.8 m long lying slightly diagonal, cut end with rings, moss "
              "and a broken branch stub.", seed=409, pivot_meaning="centre of the log's ground contact")
    ellipse_shadow(a, 12, -8, 330, 62, opacity=0.4, blur=9)
    a.add("body", [R(-8, -40, 300, 76, 34, rot=-8)], "mass", "bark", texture={"angle": -8})
    a.add("stub", [LINE(-40, -64, -60, -108, 16)], "mass", "bark", texture={"angle": 70})
    a.add("end", [E(138, -60, 52, 74, rot=-8)], "mass", "wood_cut", shade={"bump": 0.4, "highlight_amount": 0.3})
    a.flat("rings", [I("target", 138, -60, 38, 56, rot=-8)], "wood_dark", opacity=0.45, clip_to="end")
    a.add("moss", [I("cloud", -70, -70, 110, 30, rot=-8), I("cloud", 40, -82, 70, 22, rot=-8, flip="x")], "mass",
          "moss", clip_to="body", rough={"amp": 0.5, "soft": 1.5, "cell": 6})
    a.add("sprouts", [I("sprout", -120, -76, 26, 24, rot=-10), I("grass", 70, -18, 40, 18)], "mass", "grass",
          line={"width": 0.8, "heavy": 0.9})
    return a


# ============================================================================ B
@asset
def obj_stump():
    a = Asset("obj_stump", "Tree stump 0.55 m wide, cut top with growth rings and a radial crack, root flare, moss.",
              seed=411, pivot_meaning=TRUNK)
    ellipse_shadow(a, 10, -24, 150, 70, opacity=0.38, blur=8)
    a.add("roots", [I("triangle", -46, -10, 46, 24, rot=-28), I("triangle", 48, -8, 42, 22, rot=30),
                    I("triangle", -8, 2, 38, 18, rot=180, flip="y")], "mass", "bark")
    s = a.cyl("body", 0, 0, 100, 40, "bark", texture={"angle": 90})
    a.flat("cut", [E(0, s.top_cy, 92, 78)], "wood_cut", line=THIN)
    a.flat("rings", [I("target", 0, s.top_cy, 70, 58)], "wood_dark", opacity=0.4, clip_to="cut")
    a.flat("crack", [LINE(0, s.top_cy, 30, s.top_cy - 20, 3), LINE(0, s.top_cy, -6, s.top_cy + 30, 2)], "floor_joint",
           opacity=0.7, clip_to="cut")
    a.add("moss", [I("cloud", -30, -18, 50, 20)], "mass", "moss", clip_to="body", rough={"amp": 0.5, "soft": 1.2,
                                                                                       "cell": 5})
    return a


@asset
def obj_tree_fruit():
    a = Asset("obj_tree_fruit", "Fruit tree (apple-like), about 3.6 m: short forked trunk, round crown with red fruit, "
              "two fallen fruits.", seed=412, pivot_meaning=TRUNK)
    ellipse_shadow(a, 16, -4, 250, 80, opacity=0.4, blur=11)
    canopy(a, "crown_back", [E(0, -250, 300, 220), I("cloud", -86, -286, 170, 116), I("cloud", 90, -280, 170, 120, flip="x"),
                             E(-120, -214, 110, 96), E(120, -210, 116, 96), E(-60, -352, 90, 70), E(60, -356, 96, 72)],
           "foliage_dark")
    a.add("trunk", [R(0, -70, 40, 140, 14), E(0, -6, 80, 24), LINE(-4, -118, -58, -186, 15), LINE(6, -124, 60, -190, 14)],
          "mass", "bark")
    canopy(a, "crown_front", [E(-70, -196, 150, 110), E(74, -192, 150, 114), E(0, -276, 200, 140), E(-2, -186, 120, 80)],
           "foliage")
    fruit = [(-96, -210), (-40, -176), (30, -234), (86, -180), (-10, -300), (60, -290), (-78, -268), (110, -236),
             (0, -214), (-120, -236)]
    a.add("fruit", [E(x, y, 20, 19) for x, y in fruit], "mass", "fruit", line=FINE_T)
    a.add("fallen", [E(46, 10, 18, 14), E(-34, 16, 17, 13)], "mass", "fruit", line=FINE_T)
    return a


@asset
def obj_tree_cursed():
    a = Asset("obj_tree_cursed", "Cursed tree (dark fantasy, no face): black twisted trunk, curling branch tips, sparse "
              "sickly leaf clumps, hanging moss strands, exposed roots.", seed=413, pivot_meaning=TRUNK)
    ellipse_shadow(a, 12, -4, 200, 60, opacity=0.42, blur=10)
    a.add("roots", [LINE(-10, -12, -80, 8, 14), LINE(8, -10, 84, 4, 13), LINE(0, -6, -30, 20, 11), LINE(6, -8, 40, 22, 10),
                    E(0, -8, 70, 22)], "mass", "bark")
    a.add("trunk", [POLY([(0.3, 1), (0.0, 0.8), (0.28, 0.55), (0.1, 0.25), (0.42, 0.0), (0.62, 0.0), (0.5, 0.3),
                          (0.78, 0.52), (0.62, 0.78), (0.72, 1)], 0, -120, 80, 240)], "mass", "bark",
          texture={"angle": 80})
    a.add("branches", [LINE(-10, -200, -96, -268, 14), LINE(-90, -264, -130, -250, 9), LINE(10, -214, 104, -290, 13),
                       LINE(96, -284, 128, -318, 8), LINE(0, -236, -18, -330, 11),
                       LINE(-130, -250, -150, -262, 6), LINE(-150, -262, -154, -282, 5), LINE(-154, -282, -142, -292, 4),
                       LINE(128, -318, 146, -330, 6), LINE(146, -330, 148, -350, 5), LINE(148, -350, 136, -356, 4),
                       LINE(-18, -330, -34, -350, 6), LINE(-34, -350, -30, -368, 5), LINE(-30, -368, -18, -372, 4)],
          "mass", "bark")
    hang = []
    for x, y, w in ((-104, -262, 64), (100, -290, 60), (-14, -330, 54), (-60, -236, 44), (60, -252, 40)):
        hang += [I("cloud", x, y - 6, w, w * 0.45), I("grass", x - w * 0.18, y + w * 0.3, w * 0.5, w * 0.5, flip="y"),
                 I("grass", x + w * 0.2, y + w * 0.36, w * 0.44, w * 0.62, flip="xy")]
    canopy(a, "leaves", hang, "foliage_sick", rough={"amp": 0.6, "soft": 1.5, "cell": 6})
    a.flat("hollow", [E(10, -120, 20, 30)], "hole", opacity=0.9)
    return a


@asset
def obj_bamboo():
    a = Asset("obj_bamboo", "Bamboo clump (eastern), about 3 m: six culms with node rings, leaf sprays at the tops "
              "and along the stems.", seed=414, pivot_meaning="clump base centre on the ground")
    ellipse_shadow(a, 10, -4, 170, 44, opacity=0.36, blur=8)
    culms = [(-48, 262, -4), (-20, 318, 2), (8, 290, -2), (34, 336, 3), (58, 250, 5), (-66, 220, -6)]
    a.add("culms_back", [R(x + h * 0.03 * r, -h / 2, 13, h, 6, rot=r) for x, h, r in culms[::2]], "mass", "bamboo")
    a.add("culms_front", [R(x + h * 0.03 * r, -h / 2, 15, h, 7, rot=r) for x, h, r in culms[1::2]], "mass", "bamboo")
    nodes = []
    for x, h, r in culms:
        for k in range(1, int(h / 46)):
            nodes.append(R(x + (k * 46 - h / 2) * 0.0 + h * 0.03 * r, -k * 46, 17, 3, 1, rot=r))
    a.flat("nodes", nodes, "foliage_dark", opacity=0.8)
    sprays = []
    blade = [(0, 0.5), (0.25, 0.08), (1, 0.5), (0.25, 0.92)]
    for i, (x, h, r) in enumerate(culms):
        tx = x + h * 0.03 * r
        for dx, dy, ang, ln in ((-24, 6, 200, 52), (-18, 16, 160, 46), (22, 4, -20, 54), (20, 16, 24, 46), (0, -6, -80, 44),
                                (-20, h * 0.42, 190, 40), (20, h * 0.46, -10, 40)):
            rr = math.radians(ang)
            sprays.append(POLY(blade, tx + dx + math.cos(rr) * ln * 0.3, -h + dy + math.sin(rr) * ln * 0.3, ln, 11,
                               rot=ang))
    a.add("leaves", sprays, "mass", "foliage", line=FINE_T)
    return a


@asset
def obj_cactus():
    a = Asset("obj_cactus", "Saguaro-type cactus (western), about 2.1 m: ribbed column with two arms, pale flower, "
              "sand mound and pebbles.", seed=415, pivot_meaning=TRUNK)
    ellipse_shadow(a, 12, -2, 140, 36, opacity=0.38, blur=8)
    a.add("mound", [E(0, 0, 120, 34)], "mass", "sand", shade={"bump": 0.4}, line=FINE_T)
    a.add("column", [R(0, -104, 46, 212, 22)], "mass", "cactus")
    a.add("arms", [R(-36, -118, 52, 22, 11), E(-54, -118, 26, 26), R(-56, -148, 24, 70, 12),
                   R(36, -84, 50, 20, 10), E(52, -84, 24, 24), R(54, -112, 22, 62, 11)],
          "mass", "cactus")
    a.flat("ribs", [R(x, -104, 2, 196, 1) for x in (-12, 0, 12)] + [R(-56, -150, 2, 70, 1), R(54, -118, 2, 64, 1)],
           "foliage_dark", opacity=0.6)
    a.add("flower", [I("flower", 0, -212, 20, crop=[1, 1, 15, 11.4])], "mass", "petal_pale", line=FINE_T)
    a.add("pebbles", [E(-50, 6, 16, 10), E(46, 8, 14, 9), E(34, 14, 10, 7)], "mass", "rock", line=FINE_T)
    return a


@asset
def obj_palm():
    a = Asset("obj_palm", "Palm tree (pirate / sea), about 4.2 m: leaning ringed trunk, crown of long fronds, "
              "coconut cluster.", seed=416, pivot_meaning=TRUNK)
    ellipse_shadow(a, 40, -6, 220, 60, opacity=0.36, blur=10)
    pts = [(0, 0), (10, -80), (28, -160), (52, -236), (80, -300), (104, -350)]
    seg = [LINE(pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], 30 - i * 3) for i in range(len(pts) - 1)]
    a.add("trunk", seg + [E(0, -4, 60, 18)], "mass", "bark_pale", texture={"angle": 70})
    a.flat("rings", [R(pts[i][0] * 0.5 + pts[i + 1][0] * 0.5, pts[i][1] * 0.5 + pts[i + 1][1] * 0.5, 30 - i * 3, 3, 1,
                       rot=-15) for i in range(len(pts) - 1)] +
           [R(p[0], p[1], 26, 3, 1, rot=-18) for p in pts[1:-1]], "bark", opacity=0.7, clip_to="trunk")
    cx, cy = 106, -356
    fronds = []
    for ang, ln in ((-170, 150), (-140, 130), (-100, 110), (-60, 130), (-20, 150), (10, 140), (160, 140), (200, 120)):
        r = math.radians(ang)
        fronds.append(I("leaf", cx + math.cos(r) * ln / 2, cy + math.sin(r) * ln / 2 * 0.7, ln, ln * 0.3, rot=ang))
    a.add("fronds_back", fronds[:4], "mass", "foliage_dark", line=FINE_T)
    a.add("coconuts", [E(cx - 12, cy + 14, 22, 20), E(cx + 10, cy + 16, 22, 20), E(cx, cy + 26, 20, 18)], "mass",
          "wood", line=FINE_T)
    a.add("fronds_front", fronds[4:], "mass", "foliage", line=FINE_T)
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
