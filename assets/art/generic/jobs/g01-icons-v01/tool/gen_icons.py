"""g01 icon recipes: items, equipment, skills, status (fantasy families + genre-less).

    py -3 -B gen_icons.py [--stage A|B|C|all] [--only icon_a,icon_b]

Writes ../recipes/<asset>.json (128 x 128, flat view, style "icon" of palette_g01.json).
Every shape is a cut at-icons mask (see g01kit); no icon is used whole as the picture.
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g01kit import (C, D, F, MOON, P, POLY, R, RR, SPARK, STAR, around, halo, ngon, poly_abs, polyline,  # noqa: E402
                    ringp, rrframe, rrect, save, scale, shift, spindle, star_pts, sub, turn, wedge)

RDIR = Path(__file__).resolve().parents[1] / "recipes"
ICONS: list = []   # (stage, asset, note, fn) in list order


def icon(stage, asset, note):
    def deco(fn):
        ICONS.append((stage, asset, note, fn))
        return fn
    return deco


BOLT = [(0.55, 0.0), (0.95, 0.0), (0.62, 0.4), (0.86, 0.4), (0.2, 1.0), (0.4, 0.55), (0.1, 0.55)]
DIAMOND = [(0.5, 0.0), (1.0, 0.5), (0.5, 1.0), (0.0, 0.5)]
TRI_UP = [(0.5, 0.0), (1.0, 1.0), (0.0, 1.0)]


def g45(deg):
    return lambda ps: turn(ps, deg, 64, 64)


# ------------------------------------------------------------------ shared plates
def skill_plate(tint):
    """Square skill tile: dark plate, coloured gradient field, bronze rim, corner studs."""
    return [
        F("plate", "plate", [RR(64, 64, 112, 112)], 0),
        F("plate_tint", None, [RR(64, 64, 100, 100)], 0.5, "flat", color=tint, clip_to="plate", opacity=0.95,
          grad={"to": "plate_low", "y0": 18, "y1": 114}),
        F("plate_rim", "bronze", rrframe(64, 64, 115, 115, 6.5), 5),
        F("plate_studs", "bronze", [C(15, 15, 7), C(113, 15, 7), C(15, 113, 7), C(113, 113, 7)], 5.2),
    ]


def status_badge(tint):
    """Round status badge: dark disc, coloured field, silver rim."""
    return [
        F("badge", "plate", [C(64, 64, 106, 106)], 0),
        F("badge_tint", None, [C(64, 64, 96, 96)], 0.5, "flat", color=tint, clip_to="badge", opacity=0.95,
          grad={"to": "plate_low", "y0": 16, "y1": 112}),
        F("badge_rim", "silver", ringp(64, 64, 112, 112, 7), 5),
    ]


# ================================================================== A: items
@icon("A", "icon_potion_red", "Round red healing potion: dark glass flask, cork, bronze neck band, liquid level and glint.")
def potion_red():
    glass = [C(64, 82, 74, 70), RR(64, 42, 24, 30), C(64, 28, 32, 10)]
    return [
        F("glass", "glass_dark", glass, 0),
        F("liquid", "liquid_red", [C(64, 84, 68, 64), sub(R(64, 44, 90, 40))], 1, clip_to="glass"),
        F("surface", "liquid_red_light", [C(64, 64, 58, 8)], 2, "flat", clip_to="liquid", opacity=0.8),
        F("bubbles", "liquid_red_light", [C(76, 92, 7), C(82, 80, 4.5), C(68, 102, 3.5)], 2.2, "flat",
          clip_to="liquid", opacity=0.7),
        F("band", "bronze", [R(64, 50, 28, 6)], 3),
        F("cork", "cork", [RR(64, 20, 20, 18), C(64, 13, 22, 8)], 3),
        F("glint", None, [C(44, 84, 12, 42), sub(C(48, 82, 12, 42)), C(50, 60, 6, 7)], 4, "flat", color="glint",
          clip_to="glass", opacity=0.55),
    ]


@icon("A", "icon_potion_blue", "Blue mana potion in a teardrop flask with a silver band and sparkles in the liquid.")
def potion_blue():
    glass = [D(64, 80, 68, 80), RR(64, 38, 20, 22), C(64, 27, 28, 9)]
    return [
        F("glass", "glass_dark", glass, 0),
        F("liquid", "liquid_blue", [D(64, 84, 64, 74), sub(R(64, 48, 90, 40))], 1, clip_to="glass"),
        F("surface", "liquid_blue_light", [C(64, 68, 50, 7)], 2, "flat", clip_to="liquid", opacity=0.75),
        F("spark", None, [SPARK(74, 96, 20), SPARK(55, 86, 11), C(66, 106, 3.5)], 2.5, "flat", color="glow_arcane",
          clip_to="liquid", opacity=0.9),
        F("band", "silver", [R(64, 45, 24, 5)], 3),
        F("cork", "cork", [RR(64, 20, 18, 16), C(64, 13, 20, 7)], 3),
        F("glint", None, [C(47, 90, 10, 36), sub(C(51, 88, 10, 36))], 4, "flat", color="glint", clip_to="glass",
          opacity=0.5),
    ]


@icon("A", "icon_antidote", "Green antidote in a squat square bottle: paper label with two herb leaves, string at the neck.")
def antidote():
    glass = [RR(64, 86, 62, 58), C(64, 60, 62, 22), RR(64, 44, 22, 22), C(64, 33, 28, 9)]
    return [
        F("glass", "glass_dark", glass, 0),
        F("liquid", "liquid_green", [RR(64, 88, 58, 56), sub(R(64, 50, 90, 40))], 1, clip_to="glass"),
        F("surface", "liquid_green_light", [C(64, 70, 52, 6)], 2, "flat", clip_to="liquid", opacity=0.75),
        F("label", "paper", [RR(64, 92, 32, 28)], 2.5, clip_to="glass"),
        F("leaves", "herb", [D(59, 90, 11, 20, rot=-35), D(69, 90, 11, 20, rot=30), R(64, 99, 2, 9)], 3),
        F("string", "cloth_brown", [R(64, 48, 26, 4)], 3),
        F("cork", "cork", [RR(64, 25, 18, 14), C(64, 19, 20, 6)], 3),
        F("glint", None, [C(40, 86, 8, 40), sub(C(43, 84, 8, 40))], 4, "flat", color="glint", clip_to="glass",
          opacity=0.45),
    ]


@icon("A", "icon_key_iron", "Old rusted iron key, trefoil bow, two collars, notched bit; lies diagonally.")
def key_iron():
    ps = [
        C(26, 64, 38, 38), sub(C(26, 64, 18, 18)),
        C(8, 64, 12, 12), C(26, 46, 11, 11), C(26, 82, 11, 11),
        R(72, 64, 72, 11),
        RR(50, 64, 8, 23), RR(58, 64, 6, 19),
        R(99, 78, 16, 18), sub(R(99, 81, 6, 8)), R(88, 76, 6, 13),
    ]
    g = g45(-40)
    return [
        F("key", "steel", g(ps), 0, shade={"highlight_amount": 0.55}),
        F("rust", None, g(ps), 0.5, "flat", color="rust", clip_to="key", opacity=0.5,
          mottle={"cell": 16, "lo": 0.5, "hi": 0.8}),
        F("key_light", "steel_light", g([R(72, 60.5, 64, 2)]), 1, "flat", clip_to="key", opacity=0.4),
    ]


@icon("A", "icon_coins_gold", "Gold coins: two short stacks (coin edges from the block extrusion) and one standing coin with a star mark.")
def coins_gold():
    forms = [
        F("stand", "gold", [C(90, 60, 40, 42, rot=12)], 0),
        F("stand_ring", "gold_dark", ringp(90, 60, 30, 32, 2.4, rot=12), 0.2, "flat", clip_to="stand", opacity=0.7),
        F("stand_star", "gold_dark", [STAR(90, 60, 14, rot=12)], 0.3, "flat", clip_to="stand", opacity=0.75),
    ]
    z = 1.0
    stacks = [[(44, 104), (46, 96), (43, 88), (45, 80), (44, 72)], [(84, 108), (82, 100), (85, 92)]]
    for s, stack in enumerate(stacks):
        for i, (x, y) in enumerate(stack):
            name = f"coin{s}_{i}"
            forms.append(F(name, "gold", [C(x, y, 46, 17)], z, "block", extrude=6))
            forms.append(F(name + "_mark", "gold_dark", ringp(x, y, 32, 11, 2), z + 0.01, "flat", clip_to=name,
                           opacity=0.55))
            z += 0.1
    return forms


@icon("A", "icon_scroll_sealed", "Rolled parchment scroll with a wine ribbon and a red wax seal hanging below.")
def scroll_sealed():
    g = g45(-28)
    tail = [(0, 0), (1, 0), (0.85, 1), (0.5, 0.78), (0.15, 1)]
    return [
        F("roll", "paper", g([R(64, 64, 80, 32), C(24, 64, 12, 32)]), 0),
        F("end", "paper", g([C(104, 64, 13, 32)]), 1, shade={"bump": 0.4}),
        F("spiral", "paper_mark", g([P("spiral", 104, 64, 10, 26)]), 1.5, "flat", clip_to="end", opacity=0.8),
        F("ribbon", "cloth_wine", g([R(58, 64, 10, 36)]), 2.5),
        F("tails", "cloth_wine", [POLY(tail, 54, 94, 11, 24, rot=12), POLY(tail, 64, 93, 11, 22, rot=-16)], 2),
        F("seal", "wax_red", [C(59, 82, 24, 22), C(51, 88, 8), C(68, 89, 7)], 3),
        F("seal_mark", "wax_dark", [STAR(59, 82, 12)], 3.5, "flat", clip_to="seal", opacity=0.75),
    ]


@icon("A", "icon_bread", "Crusty bread loaf with three light score marks and a small roll in front.")
def bread():
    return [
        F("loaf", "bread", [C(60, 76, 100, 58), C(60, 66, 84, 50)], 1),
        F("scores", "bread_crumb", [RR(38, 66, 9, 30, rot=38), RR(58, 60, 9, 34, rot=38), RR(78, 60, 9, 32, rot=38)],
          2, "flat", clip_to="loaf", opacity=0.85),
        F("crust_hl", None, [C(52, 50, 44, 10, rot=-12)], 2.5, "flat", color="glint", clip_to="loaf", opacity=0.14),
        F("roll", "bread", [C(98, 100, 40, 28)], 3),
        F("roll_score", "bread_crumb", [RR(98, 96, 22, 5, rot=-15)], 3.5, "flat", clip_to="roll", opacity=0.8),
    ]


# ================================================================== A: equipment
@icon("A", "icon_longsword", "Longsword on the diagonal: pointed steel blade with fuller and edge light, bronze guard, wrapped grip, gem pommel.")
def longsword():
    g = g45(45)
    blade = [POLY([(0.5, 0), (1, 0.13), (1, 1), (0, 1), (0, 0.13)], 64, 44, 16, 76)]
    return [
        F("blade", "steel", g(blade), 0),
        F("fuller", "steel_dark", g([R(64, 50, 3.2, 54)]), 1, "flat", clip_to="blade", opacity=0.7),
        F("edge_hl", "steel_light", g([POLY([(0.5, 0), (1, 0.08), (1, 1), (0, 1), (0, 0.08)], 59.3, 45, 2.2, 70)]),
          1.2, "flat", clip_to="blade", opacity=0.55),
        F("grip", "leather", g([R(64, 101, 8, 22)]), 1.5),
        F("wrap", "leather_dark", g([R(64, 95, 10, 1.8, rot=-22), R(64, 101, 10, 1.8, rot=-22),
                                     R(64, 107, 10, 1.8, rot=-22)]), 1.7, "flat", clip_to="grip", opacity=0.9),
        F("guard", "bronze", g([R(64, 86, 44, 7), C(42, 86, 9), C(86, 86, 9), POLY(DIAMOND, 64, 86, 12, 16)]), 2),
        F("pommel", "bronze", g([C(64, 116, 13, 13)]), 2),
        F("pommel_gem", "gem_red", g([C(64, 116, 6, 6)]), 2.5),
    ]


@icon("A", "icon_dagger", "Leaf-bladed dagger on the diagonal: ridge line, short bronze guard, wrapped grip, diamond pommel.")
def dagger():
    g = g45(45)
    return [
        F("blade", "steel", g([D(64, 48, 17, 60)]), 0),
        F("ridge", "steel_dark", g([POLY(TRI_UP, 64, 52, 3, 44)]), 1, "flat", clip_to="blade", opacity=0.6),
        F("grip", "leather", g([RR(64, 92, 9, 18)]), 1.5),
        F("wrap", "leather_dark", g([R(64, 88, 10, 1.6, rot=-20), R(64, 94, 10, 1.6, rot=-20)]), 1.7, "flat",
          clip_to="grip", opacity=0.9),
        F("guard", "bronze", g([RR(64, 80, 38, 6), C(46, 78, 7), C(82, 78, 7)]), 2),
        F("pommel", "bronze", g([P("diamond_shape", 64, 105, 12, 14)]), 2),
    ]


@icon("A", "icon_battle_axe", "Bearded battle axe: crescent steel head with back spike, iron socket with rivets, leather-wrapped haft.")
def battle_axe():
    g = g45(38)
    head = [C(86, 38, 44, 60), sub(C(70, 38, 32, 54)), R(73, 38, 18, 20)]
    return [
        F("haft", "wood", g([R(64, 72, 9, 100)]), 0),
        F("head", "steel", g(head), 1),
        F("spike", "steel", g([POLY([(0, 0.5), (1, 0), (1, 1)], 49, 38, 18, 14)]), 1),
        F("socket", "iron", g([R(64, 38, 14, 28), POLY(TRI_UP, 64, 18, 10, 14)]), 2),
        F("rivets", "bronze", g([C(64, 31, 4.5), C(64, 45, 4.5)]), 3),
        F("wrap", "leather", g([R(64, 100, 12, 24)]), 2),
        F("wrap_lines", "leather_dark", g([R(64, 94, 13, 1.6, rot=-20), R(64, 100, 13, 1.6, rot=-20),
                                           R(64, 106, 13, 1.6, rot=-20)]), 2.2, "flat", clip_to="wrap", opacity=0.9),
        F("butt", "iron", g([RR(64, 121, 12, 8)]), 2),
    ]


@icon("A", "icon_longbow", "Longbow on the diagonal: crescent wooden limb, taut string, leather grip, bone tips.")
def longbow():
    cx, w, h, d = 50, 70, 112, 10
    hx = cx - d / 2.0
    hy = (h / 2.0) * math.sqrt(1 - (d / w) ** 2)
    g = g45(45)
    return [
        F("string", None, g([R(hx, 64, 1.6, 2 * hy - 4)]), 0, "flat", color="#c8bca0"),
        F("limb", "wood", g([C(cx, 64, w, h), sub(C(cx - d, 64, w, h))]), 1),
        F("grip", "leather", g([RR(cx + w / 2.0 - d / 2.0, 64, 12, 22)]), 2),
        F("tips", "bone", g([C(hx + 1, 64 - hy + 3, 6), C(hx + 1, 64 + hy - 3, 6)]), 2),
    ]


@icon("A", "icon_staff_orb", "Wooden mage staff: violet orb held by a bronze claw, arcane halo, cloth wrap, iron foot.")
def staff_orb():
    g = g45(40)
    return [
        F("orb_halo", None, g([C(64, 24, 40, 40)]), 0, "flat", color="glow_arcane", blur=4, opacity=0.35),
        F("shaft", "wood", g([POLY([(0.25, 0), (0.75, 0), (1, 1), (0, 1)], 64, 78, 10, 88)]), 1),
        F("knots", "wood", g([C(64, 62, 12, 6), C(64, 92, 13, 6)]), 1.5),
        F("butt", "iron", g([RR(64, 122, 9, 6)]), 1.2),
        F("wrap", "cloth_wine", g([R(64, 72, 11, 12)]), 2),
        F("orb", "gem_violet", g([C(64, 24, 24, 24)]), 2.5),
        F("cup", "bronze", g([C(64, 38, 22, 10), D(50, 27, 8, 24, rot=-22), D(78, 27, 8, 24, rot=22)]), 3),
        F("orb_spark", None, g([SPARK(58, 18, 11)]), 3.5, "flat", color="#ffffff", opacity=0.85),
    ]


@icon("A", "icon_shield_round", "Round wooden shield: plank seams, faded wine bend, iron rim with bronze rivets, steel boss.")
def shield_round():
    return [
        F("board", "wood", [C(64, 64, 104, 104)], 0),
        F("bend", "cloth_wine", [R(64, 64, 28, 130, rot=-38)], 0.5, "flat", clip_to="board", opacity=0.55),
        F("planks", "wood_dark", [R(44, 64, 2, 110), R(64, 64, 2, 110), R(84, 64, 2, 110)], 1, "flat",
          clip_to="board", opacity=0.75),
        F("rim", "iron", ringp(64, 64, 110, 110, 8), 2),
        F("rivets", "bronze", around(10, 64, 64, 51, 51, lambda x, y, k, a: C(x, y, 5.5)), 3),
        F("boss_ring", "bronze", ringp(64, 64, 40, 40, 5), 3),
        F("boss", "steel", [C(64, 64, 30, 30)], 4, shade={"highlight_amount": 0.8}),
    ]


@icon("A", "icon_helm_iron", "Closed iron helm: dome with steel crest, bronze brow band with rivets, eye slits and breathing holes.")
def helm_iron():
    helm = [C(64, 52, 80, 74), R(64, 78, 80, 44), POLY([(0, 0), (1, 0), (0.82, 1), (0.18, 1)], 64, 106, 80, 16)]
    return [
        F("helm", "iron", helm, 0, shade={"highlight_amount": 0.7}),
        F("spike", "bronze", [POLY(TRI_UP, 64, 11, 8, 12)], 0.5),
        F("crest", "steel", [RR(64, 42, 7, 56)], 1),
        F("brow", "bronze", [R(64, 58, 82, 7)], 2),
        F("slits", None, [R(47, 68, 24, 5), R(81, 68, 24, 5)], 3, "flat", color="void_violet"),
        F("holes", None, [C(x, y, 3.6) for x in (44, 50, 78, 84) for y in (86, 93, 100)], 3, "flat",
          color="void_violet"),
        F("rivets", "bronze", [C(x, 58, 3.5) for x in (30, 47, 64, 81, 98)], 4),
    ]


@icon("A", "icon_breastplate", "Steel breastplate: centre ridge, bronze neck trim, iron pauldrons, leather belt with bronze buckle.")
def breastplate():
    plate = [POLY([(0.12, 0), (0.88, 0), (1, 0.22), (0.93, 1), (0.07, 1), (0, 0.22)], 64, 72, 82, 82),
             sub(C(64, 29, 32, 24)), sub(C(21, 50, 20, 38)), sub(C(107, 50, 20, 38))]
    return [
        F("plate", "steel", plate, 1, shade={"highlight_amount": 0.3, "bump": 0.75}),
        F("ridge", "steel_light", [POLY(DIAMOND, 64, 70, 7, 70)], 2, "flat", clip_to="plate", opacity=0.4),
        F("trim", "bronze", ringp(64, 29, 42, 34, 5), 2.5, clip_to="plate"),
        F("pauldron_l", "iron", [C(30, 42, 34, 28, rot=-18), C(26, 54, 26, 18, rot=-18)], 3),
        F("pauldron_r", "iron", [C(98, 42, 34, 28, rot=18), C(102, 54, 26, 18, rot=18)], 3),
        F("belt", "leather", [R(64, 104, 80, 10)], 4),
        F("rivets", "bronze", [C(40, 38, 3.5), C(88, 38, 3.5), C(64, 44, 3.5)], 4),
        F("buckle", "bronze", [R(64, 104, 13, 13)], 5),
        F("buckle_hole", None, [R(64, 104, 6, 6)], 5.5, "flat", color="void_violet"),
    ]


# ================================================================== A: skills
@icon("A", "icon_skill_slash", "Skill tile: a bright steel crescent slash with two fainter trailing arcs and sparks.")
def skill_slash():
    main = [C(56, 72, 88, 88), sub(C(47, 81, 88, 88))]
    trail = [C(46, 82, 66, 66), sub(C(41, 87, 66, 66)), C(38, 90, 44, 44), sub(C(35, 93, 44, 44))]
    return skill_plate("tint_steel") + [
        halo("glow", None, main, 1, 4, 0.55, color="glow_steel", clip_to="plate"),
        F("trail", "fx_steel", trail, 1.8, "flat", clip_to="plate", opacity=0.5),
        F("arc", "fx_steel", main, 2, "flat", clip_to="plate"),
        F("sparks", None, [SPARK(94, 34, 15), SPARK(28, 98, 10)], 2.5, "flat", color="#ffffff", clip_to="plate",
          opacity=0.9),
    ]


@icon("A", "icon_skill_fireball", "Skill tile: fireball flying to the lower left, flame tongues trailing up-right, embers.")
def skill_fireball():
    outer = [D(76, 52, 30, 50, rot=45), D(88, 40, 18, 34, rot=40), D(68, 40, 14, 28, rot=30),
             D(90, 62, 14, 26, rot=62), C(52, 76, 40, 40)]
    inner = [D(66, 60, 16, 30, rot=45), C(54, 74, 26, 26)]
    return skill_plate("tint_fire") + [
        halo("glow", None, outer, 1, 6, 0.5, color="glow_fire", clip_to="plate"),
        F("flame", "fx_fire", outer, 2, "flat", clip_to="plate"),
        F("flame_core", "fx_fire_core", inner, 2.5, "flat", clip_to="plate"),
        F("hot", None, [C(50, 78, 12, 12)], 2.8, "flat", color="#fff6d0", clip_to="plate", opacity=0.9),
        F("embers", "fx_fire_core", [C(36, 44, 4), C(28, 58, 3), C(98, 92, 3.5)], 2.6, "flat", clip_to="plate"),
    ]


@icon("A", "icon_skill_lightning", "Skill tile: zigzag lightning bolt falling from a dark cloud, pale core, sparks.")
def skill_lightning():
    bolt = [POLY(BOLT, 62, 74, 50, 80)]
    return skill_plate("tint_bolt") + [
        F("cloud", "fx_smoke", [P("cloud", 64, 26, 88, 42)], 1, clip_to="plate"),
        halo("glow", None, bolt, 1.5, 5, 0.6, color="glow_bolt", clip_to="plate"),
        F("bolt", "fx_bolt", bolt, 2, "flat", clip_to="plate"),
        F("bolt_core", "fx_bolt_core", [POLY(BOLT, 62, 74, 30, 64)], 2.5, "flat", clip_to="bolt", opacity=0.8),
        F("sparks", None, [SPARK(96, 98, 12), SPARK(30, 92, 9)], 3, "flat", color="#fffbe6", clip_to="plate"),
    ]


@icon("A", "icon_skill_heal", "Skill tile: glowing green cross of light, two herb leaves, sparkles.")
def skill_heal():
    cross = [RR(64, 58, 20, 58), RR(64, 58, 58, 20)]
    return skill_plate("tint_heal") + [
        halo("glow", None, cross, 1, 6, 0.55, color="glow_heal", clip_to="plate"),
        F("cross", "fx_heal", cross, 2, "flat", clip_to="plate"),
        F("cross_core", None, [RR(64, 58, 8, 46), RR(64, 58, 46, 8)], 2.3, "flat", color="#effff0", clip_to="cross",
          opacity=0.7),
        F("leaves", "herb", [D(46, 98, 14, 28, rot=-55), D(82, 98, 14, 28, rot=55)], 2.5),
        F("sparks", None, [SPARK(96, 30, 13), SPARK(30, 32, 9), SPARK(100, 74, 8)], 3, "flat", color="#effff0",
          clip_to="plate"),
    ]


# ================================================================== A: status
@icon("A", "icon_status_poison", "Status badge: green poison drop with a small bone skull, rising bubbles.")
def status_poison():
    return status_badge("tint_poison") + [
        F("bubbles", "liquid_green_light", [C(88, 40, 9), C(97, 55, 6), C(38, 40, 5)], 1.5, "flat",
          clip_to="badge", opacity=0.85),
        F("drop", "liquid_green", [D(64, 62, 52, 70)], 1),
        F("skull", "bone", [C(64, 68, 26, 23), RR(64, 79, 15, 10)], 2),
        F("skull_holes", None, [C(58.5, 69, 7, 7.5), C(69.5, 69, 7, 7.5), POLY(TRI_UP, 64, 76, 4, 4),
                                R(61.5, 82, 1.5, 5), R(66.5, 82, 1.5, 5)], 2.5, "flat", color="void_violet"),
    ]


@icon("A", "icon_status_burn", "Status badge: three flame tongues with a hot core and embers.")
def status_burn():
    outer = [D(64, 60, 42, 66), D(45, 74, 24, 40, rot=-18), D(83, 74, 24, 40, rot=18)]
    inner = [D(64, 72, 22, 38), D(50, 82, 12, 20, rot=-15), D(78, 82, 12, 20, rot=15)]
    return status_badge("tint_fire") + [
        halo("glow", None, outer, 1, 5, 0.5, color="glow_fire", clip_to="badge"),
        F("flame", "fx_fire", outer, 2, "flat", clip_to="badge"),
        F("flame_core", "fx_fire_core", inner, 2.5, "flat", clip_to="badge"),
        F("embers", "fx_fire_core", [C(40, 40, 4), C(90, 36, 3.5), C(80, 26, 2.5)], 2.6, "flat", clip_to="badge"),
    ]


def snowflake_pieces(cx, cy, arm, width, tick):
    pieces = []
    for k in range(3):
        a = k * 60
        local = [RR(cx, cy, width, arm)]
        for e in (-1, 1):
            for s in (-1, 1):
                off = arm * 0.29
                local.append(RR(cx + s * tick * 0.26, cy + e * (off + tick * 0.26), width * 0.7, tick,
                                rot=s * (-e) * 45))
        pieces += turn(local, a, cx, cy)
    return pieces


@icon("A", "icon_status_freeze", "Status badge: ice crystal snowflake built from six ticked arms and a hexagon core.")
def status_freeze():
    arms = snowflake_pieces(64, 64, 80, 8, 18)
    return status_badge("tint_ice") + [
        halo("glow", None, arms, 1, 4, 0.45, color="glow_ice", clip_to="badge"),
        F("flake", "ice", arms + [POLY(ngon(6), 64, 64, 20, 20)], 2),
    ]


@icon("A", "icon_status_stun", "Status badge: three gold stars circling on a faint orbit, a small swirl below.")
def status_stun():
    stars = [STAR(33, 58, 27, rot=-12), STAR(80, 45, 21, rot=10), STAR(98, 66, 16, rot=20)]
    cores = [STAR(33, 58, 13, rot=-12), STAR(80, 45, 10, rot=10), STAR(98, 66, 8, rot=20)]
    return status_badge("tint_stun") + [
        F("orbit", None, ringp(64, 60, 80, 30, 2.6), 1, "flat", color="glow_gold", clip_to="badge", opacity=0.5),
        halo("glow", None, stars, 1.5, 4, 0.6, color="glow_gold", clip_to="badge"),
        F("stars", "gold", stars, 2, shade={"highlight_amount": 0.9}),
        F("star_cores", None, cores, 2.2, "flat", color="#ffe8a0", clip_to="stars", opacity=0.55),
        F("swirl", None, [P("spiral", 64, 92, 30, 18)], 2, "flat", color="glow_gold", clip_to="badge", opacity=0.55),
    ]


@icon("A", "icon_status_sleep", "Status badge: pale crescent moon with sparkles (no letters).")
def status_sleep():
    moon = [C(58, 66, 60, 60), sub(C(73, 55, 54, 54))]
    return status_badge("tint_sleep") + [
        halo("glow", None, moon, 1, 5, 0.4, color="glow_holy", clip_to="badge"),
        F("moon", "bone", moon, 2),
        F("stars", None, [SPARK(88, 36, 17), SPARK(99, 62, 10), C(82, 84, 4)], 2.5, "flat", color="glow_holy",
          clip_to="badge"),
    ]


# ================================================================== B: items
def bottle_glint(x, y, w, h):
    return [C(x, y, w, h), sub(C(x + w * 0.35, y - h * 0.05, w, h))]


@icon("B", "icon_elixir", "Golden elixir: round flask in a thin gold cage, glowing gold liquid with sparkles, crowned gold stopper with a garnet.")
def elixir():
    glass = [C(64, 82, 66, 64), RR(64, 44, 20, 26), C(64, 31, 28, 9)]
    return [
        halo("aura", None, [C(64, 80, 74, 72)], 0, 6, 0.35, color="glow_gold"),
        F("glass", "glass_dark", glass, 0.5),
        F("liquid", "liquid_gold", [C(64, 84, 60, 58), sub(R(64, 46, 90, 40))], 1, clip_to="glass"),
        F("surface", "liquid_gold_light", [C(64, 66, 50, 7)], 2, "flat", clip_to="liquid", opacity=0.8),
        F("spark", None, [SPARK(76, 92, 16), SPARK(54, 98, 10), SPARK(66, 78, 8)], 2.2, "flat", color="#fff4c8",
          clip_to="liquid", opacity=0.9),
        F("cage", "gold", ringp(64, 82, 34, 64, 2.4) + [R(64, 82, 66, 3)], 3, clip_to="glass"),
        F("stopper", "gold", [RR(64, 22, 16, 12),
                              POLY([(0, 1), (0, 0.3), (0.25, 0.62), (0.5, 0), (0.75, 0.62), (1, 0.3), (1, 1)],
                                   64, 12, 24, 13)], 3),
        F("stopper_gem", "gem_red", [C(64, 22, 6, 6)], 3.5),
        F("glint", None, bottle_glint(44, 84, 12, 40), 4, "flat", color="glint", clip_to="glass", opacity=0.5),
    ]


@icon("B", "icon_phoenix_feather", "Revival feather: long flame-coloured feather with notched vane, bone quill and a warm glow.")
def phoenix_feather():
    g = g45(38)
    vane = [D(64, 58, 36, 98), sub(POLY(TRI_UP, 44, 70, 10, 12, rot=-60)), sub(POLY(TRI_UP, 46, 88, 10, 12, rot=-60)),
            sub(POLY(TRI_UP, 84, 62, 10, 12, rot=60)), sub(POLY(TRI_UP, 82, 82, 10, 12, rot=60))]
    return [
        halo("glow", None, g([D(64, 58, 44, 106)]), 0, 6, 0.45, color="glow_fire"),
        F("vane", None, g(vane), 1, color="#b8502a", grad={"to": "#e0b050", "y0": 110, "y1": 20, "amount": 0.8}),
        F("vane_core", "fx_fire_core", g([D(64, 60, 12, 70)]), 1.5, "flat", clip_to="vane", opacity=0.55),
        F("quill", "bone", g([R(64, 80, 3.5, 80), RR(64, 116, 4.5, 14)]), 2),
    ]


@icon("B", "icon_herb_bundle", "Bundle of healing herbs: four leafy stems and a violet bud, tied with brown twine.")
def herb_bundle():
    stems = []
    leaves = []
    for k, (ang, ln) in enumerate([(-22, 84), (-8, 92), (8, 88), (22, 78)]):
        a = math.radians(ang)
        bx, by = 64, 112
        tx, ty = bx + math.sin(a) * ln, by - math.cos(a) * ln
        stems.append(R((bx + tx) / 2, (by + ty) / 2, 3, ln, rot=ang))
        for j, f in enumerate((0.45, 0.65, 0.85)):
            px, py = bx + math.sin(a) * ln * f, by - math.cos(a) * ln * f
            side = 1 if (j + k) % 2 else -1
            leaves.append(D(px + side * 8, py, 11, 22, rot=ang + side * 55))
        leaves.append(D(tx, ty - 6, 12, 22, rot=ang))
    return [
        F("stems", "herb_dark", stems, 0, "flat"),
        F("leaves", "herb", leaves, 1),
        F("bud", "cloth_violet", [C(46, 30, 12, 14), C(52, 26, 9, 10)], 1.5),
        F("twine", "cloth_brown", [R(64, 94, 26, 6, rot=-4), R(64, 101, 24, 5, rot=5), D(52, 108, 6, 14, rot=200)], 2),
    ]


@icon("B", "icon_meat_roast", "Roast drumstick: glazed browned meat with grill marks and a bone end.")
def meat_roast():
    meat = [C(54, 56, 68, 58, rot=-35), C(68, 70, 44, 40)]
    return [
        F("bone", "bone", [R(92, 92, 11, 34, rot=-45), C(104, 98, 13), C(98, 106, 13)], 0),
        F("meat", "meat", meat, 1),
        F("crust", None, [C(48, 48, 44, 26, rot=-35)], 1.5, "flat", color="#a86a40", clip_to="meat", opacity=0.55),
        F("marks", "leather_dark", [RR(46, 58, 30, 4, rot=-50), RR(58, 50, 30, 4, rot=-50), RR(62, 66, 24, 4, rot=-50)],
          2, "flat", clip_to="meat", opacity=0.6),
        F("glaze", None, [C(42, 42, 16, 8, rot=-35)], 2.5, "flat", color="glint", clip_to="meat", opacity=0.35),
    ]


@icon("B", "icon_spellbook", "Closed spellbook: violet cloth cover, gold corner guards, arcane ring emblem with glow, bronze clasp, page edges.")
def spellbook():
    corner = [(0, 0), (1, 0), (0, 1)]
    return [
        F("pages", "paper", [R(70, 66, 76, 92)], 0),
        F("cover", "cloth_violet", [RR(62, 64, 78, 98)], 1),
        F("spine", "leather", [R(26, 64, 10, 98)], 1.5),
        F("spine_bands", "gold", [R(26, 34, 12, 4), R(26, 94, 12, 4)], 1.7),
        F("corners", "gold", [POLY(corner, 30, 23, 14, 14), POLY(corner, 94, 23, 14, 14, flip="x"),
                              POLY(corner, 30, 105, 14, 14, flip="y"), POLY(corner, 94, 105, 14, 14, flip="xy")], 2),
        halo("emblem_glow", None, ringp(64, 62, 40, 40, 4), 2.2, 3, 0.6, color="glow_arcane"),
        F("emblem", "gold", ringp(64, 62, 40, 40, 3.2) + [POLY(DIAMOND, 64, 62, 14, 22)], 2.5),
        F("clasp", "bronze", [R(100, 64, 12, 16), C(104, 64, 6)], 3),
    ]


@icon("B", "icon_bomb", "Round black bomb: iron sphere with highlight, bronze cap, curled fuse with a burning spark.")
def bomb():
    fuse = [(84, 36), (90, 28), (98, 24), (104, 26)]
    return [
        F("fuse", "cloth_brown", polyline(fuse, 4), 0),
        halo("spark_glow", None, [C(106, 24, 22)], 0.5, 5, 0.7, color="glow_fire"),
        F("ball", "iron_dark", [C(58, 74, 72, 72)], 1, shade={"highlight_amount": 0.8}),
        F("cap", "bronze", [RR(80, 42, 20, 14, rot=40)], 2),
        F("spark", None, [SPARK(106, 24, 20)], 3, "flat", color="#fff0b0"),
        F("shine", None, [C(40, 54, 16, 10, rot=-35)], 2.5, "flat", color="glint", clip_to="ball", opacity=0.4),
    ]


@icon("B", "icon_gem_red", "Cut red gem: crown and pavilion facets in three tones, table highlight, sparkle.")
def gem_red():
    crown = POLY([(0.22, 0), (0.78, 0), (1, 1), (0, 1)], 64, 42, 88, 26)
    pav = POLY([(0, 0), (1, 0), (0.5, 1)], 64, 83, 88, 56)
    return [
        F("gem", "gem_red", [crown, pav], 0),
        F("table", None, [POLY([(0.1, 0), (0.9, 0), (1, 1), (0, 1)], 64, 38, 44, 12)], 1, "flat", color="#ff8a90",
          clip_to="gem", opacity=0.55),
        F("facet_l", None, [poly_abs([(20, 55), (64, 55), (64, 111)])], 1, "flat", color="#5e1220", clip_to="gem",
          opacity=0.45),
        F("facet_r", None, [poly_abs([(64, 55), (108, 55), (82, 83)])], 1, "flat", color="#ff7880", clip_to="gem",
          opacity=0.25),
        F("girdle", None, [R(64, 55, 90, 2)], 1.5, "flat", color="#2a0408", clip_to="gem", opacity=0.6),
        F("sparkle", None, [SPARK(46, 36, 16), SPARK(80, 66, 8)], 2, "flat", color="#ffffff"),
    ]


# ================================================================== B: equipment (listed before the g07 split)
@icon("B", "icon_spear", "Spear on the diagonal: leaf-shaped steel head, iron socket with a wine tassel, long wooden shaft.")
def spear():
    g = g45(45)
    return [
        F("shaft", "wood", g([R(64, 76, 7, 104)]), 0),
        F("tassel", "cloth_wine", g([D(58, 42, 8, 22, flip="y"), D(64, 44, 8, 24, flip="y"), D(70, 42, 8, 22, flip="y")]), 0.5),
        F("head", "steel", g([POLY([(0.5, 0), (1, 0.45), (0.62, 1), (0.38, 1), (0, 0.45)], 64, 18, 22, 34)]), 1),
        F("ridge", "steel_dark", g([R(64, 20, 2.2, 24)]), 1.2, "flat", clip_to="head", opacity=0.6),
        F("socket", "iron", g([RR(64, 38, 10, 12)]), 2),
        F("butt", "iron", g([RR(64, 126, 9, 6)]), 1),
    ]


@icon("B", "icon_warhammer", "War hammer: square iron head with a back spike, bronze bands, leather-wrapped haft.")
def warhammer():
    g = g45(40)
    return [
        F("haft", "wood", g([R(64, 74, 9, 96)]), 0),
        F("spike", "steel", g([POLY(TRI_UP, 64, 12, 10, 16)]), 0.5),
        F("head", "iron", g([RR(64, 32, 54, 26)]), 1, shade={"highlight_amount": 0.7}),
        F("faces", "steel", g([R(39, 32, 7, 30), R(89, 32, 7, 30)]), 1.5),
        F("bands", "bronze", g([R(64, 32, 13, 30), R(64, 50, 11, 5)]), 2),
        F("rivet", "gold", g([C(64, 32, 5)]), 2.5),
        F("wrap", "leather", g([R(64, 100, 12, 26)]), 2),
        F("wrap_lines", "leather_dark", g([R(64, 93, 13, 1.6, rot=-20), R(64, 100, 13, 1.6, rot=-20),
                                           R(64, 107, 13, 1.6, rot=-20)]), 2.2, "flat", clip_to="wrap", opacity=0.9),
    ]


@icon("B", "icon_crossbow", "Crossbow: wooden stock, curved steel prod with string, loaded bolt, iron trigger.")
def crossbow():
    g = g45(45)
    prod = [C(64, 40, 100, 44), sub(C(64, 50, 100, 44))]
    return [
        F("string", None, g(polyline([(15, 45), (64, 50), (113, 45)], 1.8)), 0, "flat", color="#c8bca0"),
        F("stock", "wood", g([POLY([(0.3, 0), (0.7, 0), (0.78, 0.7), (1, 1), (0, 1), (0.22, 0.7)], 64, 80, 28, 86)]), 1),
        F("bolt", "wood_dark", g([R(64, 52, 3.5, 60)]), 1.5, "flat"),
        F("bolt_tip", "steel", g([POLY(TRI_UP, 64, 18, 10, 13)]), 1.6),
        F("prod", "steel", g(prod), 2, shade={"highlight_amount": 0.8}),
        F("prod_caps", "iron", g([C(16, 45, 8), C(112, 45, 8)]), 2.2),
        F("lock", "iron", g([RR(64, 46, 18, 12), RR(64, 88, 9, 14)]), 2.5),
    ]


@icon("B", "icon_shield_kite", "Kite shield: dark blue field, gold cross, steel rim, a few rivets.")
def shield_kite():
    outer = [(0.08, 0), (0.92, 0), (1, 0.24), (0.5, 1), (0, 0.24)]
    return [
        F("rim", "steel", [POLY(outer, 64, 66, 94, 112)], 0),
        F("field", "cloth_blue", [POLY(outer, 64, 65, 83, 99)], 1),
        F("cross", "gold", [R(64, 60, 10, 80), R(64, 46, 64, 10)], 2, clip_to="field"),
        F("rivets", "steel", [C(32, 12.8, 5), C(64, 12.8, 5), C(96, 12.8, 5)], 3),
    ]


@icon("B", "icon_robe", "Mage robe: violet body flaring to the hem, wide sleeves, gold trim, wine sash with a gem clasp.")
def robe():
    body = POLY([(0.32, 0), (0.68, 0), (1, 1), (0, 1)], 64, 72, 72, 96)
    sleeves = [POLY([(0.7, 0), (1, 0.1), (0.5, 1), (0, 0.85)], 30, 58, 34, 52),
               POLY([(0.3, 0), (0, 0.1), (0.5, 1), (1, 0.85)], 98, 58, 34, 52)]
    return [
        F("sleeves", "cloth_violet", sleeves, 0),
        F("body", "cloth_violet", [body, C(64, 26, 34, 16)], 1),
        F("collar", "cloth_wine", ringp(64, 26, 36, 18, 5), 1.5, clip_to="body"),
        F("trim", "gold", [R(64, 76, 5, 94), R(64, 118, 70, 4)], 2, clip_to="body"),
        F("cuffs", "gold", [R(21, 80, 16, 4, rot=-28), R(107, 80, 16, 4, rot=28)], 2, clip_to="sleeves"),
        F("sash", "cloth_wine", [R(64, 60, 50, 8)], 2.5, clip_to="body"),
        F("clasp", "gem_blue", [C(64, 60, 9, 9)], 3),
    ]


@icon("B", "icon_boots", "Pair of leather boots: tall shafts with buckled straps, dark soles, one boot slightly behind.")
def boots():
    def boot(x, y):
        return [RR(x, y - 18, 26, 54), RR(x + 8, y + 16, 44, 22), C(x + 26, y + 18, 16, 18)]
    b1, b2 = boot(40, 66), boot(66, 72)
    return [
        F("boot_back", "leather", b1, 0, shade={"highlight_amount": 0.4}),
        F("sole_back", "leather_dark", [R(49, 93, 44, 5)], 0.5, "flat"),
        F("strap_back", "bronze", [R(40, 52, 28, 4)], 0.7, clip_to="boot_back"),
        F("boot_front", "leather", b2, 1, shade={"highlight_amount": 0.4}),
        F("sole_front", "leather_dark", [R(75, 99, 44, 5)], 1.5, "flat"),
        F("cuff", "cloth_brown", [RR(66, 30, 30, 10)], 1.6),
        F("strap_front", "bronze", [R(66, 58, 28, 4), R(66, 70, 28, 4)], 1.8, clip_to="boot_front"),
        F("buckles", "gold", [RR(76, 58, 6, 7), RR(76, 70, 6, 7)], 2),
    ]


@icon("B", "icon_gloves", "Leather glove, palm facing out: four fingers, thumb, flared cuff with a bronze stud, stitch lines.")
def gloves():
    fingers = [RR(44, 34, 13, 36, rot=-8), RR(58, 28, 13, 40, rot=-2), RR(72, 30, 13, 38, rot=4), RR(85, 38, 12, 30, rot=10)]
    return [
        F("glove", "leather", fingers + [RR(64, 64, 50, 44), RR(34, 66, 14, 34, rot=-40)], 0),
        F("stitches", "leather_dark", [R(51, 44, 1.4, 24, rot=-5), R(65, 42, 1.4, 26, rot=1), R(78, 45, 1.4, 22, rot=7)],
          0.5, "flat", clip_to="glove", opacity=0.8),
        F("cuff", "leather_dark", [POLY([(0.12, 0), (0.88, 0), (1, 1), (0, 1)], 66, 98, 62, 30)], 1),
        F("cuff_band", "cloth_brown", [R(66, 86, 54, 4)], 1.5),
        F("stud", "bronze", [C(66, 102, 9)], 2),
    ]


@icon("B", "icon_ring_gem", "Gold ring with a blue gem held by prongs, sparkle.")
def ring_gem():
    return [
        F("band", "gold", ringp(64, 80, 66, 56, 9), 0, shade={"highlight_amount": 0.8}),
        F("setting", "gold", [RR(64, 44, 34, 18), POLY(TRI_UP, 50, 34, 8, 12), POLY(TRI_UP, 78, 34, 8, 12)], 1),
        F("gem", "gem_blue", [POLY(ngon(8, phase=-67.5), 64, 36, 30, 26)], 2),
        F("gem_table", None, [POLY(ngon(8, phase=-67.5), 62, 33, 14, 10)], 2.5, "flat", color="#a8ccff",
          clip_to="gem", opacity=0.6),
        F("sparkle", None, [SPARK(78, 26, 14)], 3, "flat", color="#ffffff"),
    ]


@icon("B", "icon_amulet", "Dark iron amulet: teardrop pendant with a red stone and small spikes, on a silver chain.")
def amulet():
    chain = around(18, 64, 40, 42, 28, lambda x, y, k, a: C(x, y, 7, 5, rot=a + 90), a0=120, a1=420)
    return [
        F("chain", "silver", chain, 0),
        F("bail", "silver", ringp(64, 68, 12, 12, 3), 0.5),
        F("pendant", "iron_dark", [D(64, 91, 40, 50, flip="y"), POLY(TRI_UP, 42, 80, 8, 12, rot=-60),
                                   POLY(TRI_UP, 86, 80, 8, 12, rot=60), POLY(TRI_UP, 64, 117, 7, 8, flip="y")], 1,
          shade={"highlight_amount": 0.6}),
        F("stone", "gem_red", [D(64, 90, 22, 30, flip="y")], 2),
        F("stone_glint", None, [C(59, 84, 5, 7)], 2.5, "flat", color="#ffb0b0", clip_to="stone", opacity=0.7),
    ]


# ================================================================== B: skills
@icon("B", "icon_skill_ice", "Skill tile: an ice spear flying up to the right, frost shards and sparkles.")
def skill_ice():
    spear = [spindle(24, 104, 104, 24, 22)]
    shards = [POLY([(0.5, 0), (1, 0.4), (0.5, 1), (0, 0.4)], x, y, w, h, rot=r)
              for x, y, w, h, r in ((40, 46, 10, 20, -30), (92, 88, 9, 18, 40), (32, 76, 7, 14, 10))]
    return skill_plate("tint_ice") + [
        halo("glow", None, spear, 1, 5, 0.5, color="glow_ice", clip_to="plate"),
        F("spear", "ice", spear, 2),
        F("shards", "ice", shards, 2),
        F("core", None, [spindle(34, 94, 96, 32, 6)], 2.5, "flat", color="#ffffff", clip_to="spear", opacity=0.55),
        F("sparks", None, [SPARK(98, 30, 12), SPARK(30, 100, 9)], 3, "flat", color="#ffffff", clip_to="plate"),
    ]


@icon("B", "icon_skill_guard", "Skill tile: steel heater shield in front of a pale protective arc.")
def skill_guard():
    outer = [(0.06, 0), (0.94, 0), (1, 0.3), (0.5, 1), (0, 0.3)]
    return skill_plate("tint_steel") + [
        halo("aura", None, ringp(64, 62, 90, 90, 6), 1, 4, 0.55, color="glow_steel", clip_to="plate"),
        F("arc", "fx_steel", ringp(64, 62, 90, 90, 3), 1.2, "flat", clip_to="plate", opacity=0.7),
        F("shield", "steel", [POLY(outer, 64, 64, 58, 70)], 2),
        F("boss", "bronze", [R(64, 56, 6, 44), R(64, 46, 34, 6)], 2.5, clip_to="shield"),
        F("sparks", None, [SPARK(100, 30, 12), SPARK(28, 96, 9)], 3, "flat", color="#ffffff", clip_to="plate"),
    ]


@icon("B", "icon_skill_shadow", "Skill tile: void orb ringed by violet crescents and motes.")
def skill_shadow():
    swirl = [MOON(64, 64, 72, 72, rot=0), MOON(64, 64, 58, 58, rot=180)]
    return skill_plate("tint_shadow") + [
        halo("glow", None, [C(64, 64, 70, 70)], 1, 7, 0.6, color="glow_shadow", clip_to="plate"),
        F("swirl", "fx_shadow", swirl, 1.5, "flat", clip_to="plate", opacity=0.85),
        F("orb", None, [C(64, 64, 40, 40)], 2, "flat", color="#0c0612"),
        F("rim", None, ringp(64, 64, 42, 42, 2), 2.2, "flat", color="glow_shadow", opacity=0.9),
        F("motes", None, [C(30, 36, 4), C(98, 40, 5), C(94, 96, 3.5), C(34, 92, 3)], 2.5, "flat", color="glow_shadow"),
    ]


# ================================================================== B: status
@icon("B", "icon_status_curse", "Status badge: a pale cursed eye with a violet slit iris and dripping shadow.")
def status_curse():
    lens = [C(64, 92, 104, 104), dict(C(64, 36, 104, 104), op="clip")]
    return status_badge("tint_curse") + [
        F("drips", "fx_shadow", [D(50, 88, 8, 18, flip="y"), D(64, 94, 9, 22, flip="y"), D(78, 88, 8, 18, flip="y")],
          1, "flat", opacity=0.9),
        F("eye", "balloon", lens, 1.5),
        F("iris", None, [C(64, 64, 30, 30)], 2, "flat", color="#6a3aa0", clip_to="eye"),
        F("pupil", None, [POLY(DIAMOND, 64, 64, 7, 26)], 2.5, "flat", color="void_violet", clip_to="eye"),
        F("shine", None, [C(58, 58, 6, 6)], 3, "flat", color="#ffffff", opacity=0.85),
    ]


@icon("B", "icon_status_silence", "Status badge: speech bubble crossed by a red bar (no letters).")
def status_silence():
    bubble = [C(62, 58, 64, 50), POLY([(0, 0), (1, 0), (0.2, 1)], 52, 88, 16, 18)]
    return status_badge("tint_silence") + [
        F("bubble", "balloon", bubble, 1),
        F("dots", "iron_dark", [C(48, 58, 8), C(62, 58, 8), C(76, 58, 8)], 1.5, "flat", opacity=0.8),
        F("bar", "gem_red", [RR(64, 64, 11, 92, rot=45)], 2, clip_to="badge"),
    ]


def up_arrow(x, y, w, h):
    return POLY([(0.5, 0), (1, 0.55), (0.68, 0.55), (0.68, 1), (0.32, 1), (0.32, 0.55), (0, 0.55)], x, y, w, h)


@icon("B", "icon_status_atk_up", "Status badge: small sword with a glowing red-orange up arrow.")
def status_atk_up():
    sword = turn([POLY([(0.5, 0), (1, 0.12), (1, 1), (0, 1), (0, 0.12)], 50, 50, 10, 50),
                  R(50, 78, 26, 5), R(50, 88, 6, 14), C(50, 97, 8)], -20, 50, 64)
    arrow = [up_arrow(86, 64, 30, 46)]
    return status_badge("tint_buff") + [
        F("sword", "steel", sword, 1),
        halo("arrow_glow", None, arrow, 1.5, 4, 0.6, color="glow_fire", clip_to="badge"),
        F("arrow", "fx_fire", arrow, 2, "flat"),
        F("arrow_core", "fx_fire_core", [up_arrow(86, 66, 14, 30)], 2.2, "flat", clip_to="arrow", opacity=0.7),
    ]


@icon("B", "icon_status_def_up", "Status badge: small heater shield with a glowing blue up arrow.")
def status_def_up():
    shield = [POLY([(0.06, 0), (0.94, 0), (1, 0.3), (0.5, 1), (0, 0.3)], 48, 66, 40, 50)]
    arrow = [up_arrow(88, 62, 30, 46)]
    return status_badge("tint_water") + [
        F("shield", "steel", shield, 1),
        F("shield_mark", "bronze", [R(48, 60, 4, 30), R(48, 52, 22, 4)], 1.2, clip_to="shield"),
        halo("arrow_glow", None, arrow, 1.5, 4, 0.6, color="glow_blue", clip_to="badge"),
        F("arrow", "fx_blue", arrow, 2, "flat"),
        F("arrow_core", None, [up_arrow(88, 64, 14, 30)], 2.2, "flat", color="#b8ccff", clip_to="arrow", opacity=0.7),
    ]


# ================================================================== C: items
@icon("C", "icon_coin_pouch", "Leather coin pouch tied with a wine cord, frilled neck, silver coins spilling in front.")
def coin_pouch():
    coins = [(40, 108, 0), (62, 112, 0), (86, 106, 0)]
    forms = [
        F("pouch", "leather", [C(64, 78, 80, 66), POLY([(0.25, 0), (0.75, 0), (1, 1), (0, 1)], 64, 44, 44, 20)], 0,
          shade={"highlight_amount": 0.4}),
        F("frill", "leather", [D(52, 30, 12, 22, rot=-20), D(64, 27, 12, 24), D(76, 30, 12, 22, rot=20)], 0.5),
        F("folds", "leather_dark", [RR(50, 80, 4, 34, rot=10), RR(76, 80, 4, 34, rot=-10)], 0.7, "flat",
          clip_to="pouch", opacity=0.6),
        F("cord", "cloth_wine", [R(64, 43, 50, 6), D(80, 52, 6, 18, flip="y", rot=-10), D(86, 50, 6, 16, flip="y", rot=-25)], 1),
    ]
    z = 2.0
    for i, (x, y, r) in enumerate(coins):
        forms.append(F(f"coin{i}", "silver", [C(x, y, 30, 12)], z, "block", extrude=4))
        forms.append(F(f"coin{i}_mark", None, ringp(x, y, 20, 8, 1.6), z + 0.01, "flat", color="#55575f",
                       clip_to=f"coin{i}", opacity=0.6))
        z += 0.1
    return forms


@icon("C", "icon_treasure_map", "Treasure map: parchment sheet with rolled ends, coastline, little mountains, a dashed route and a red ring target (no letters).")
def treasure_map():
    g = g45(-8)
    route = [R(40 + k * 9, 70 - 6 * math.sin(k * 0.9), 5, 2, rot=-20 + k * 8) for k in range(6)]
    return [
        F("sheet", "paper", g([POLY([(0, 0.05), (1, 0), (1, 1), (0, 0.95)], 64, 64, 88, 72)]), 0,
          shade={"bump": 0.35, "highlight_amount": 0.2}),
        F("rolls", "paper", g([C(18, 64, 14, 76), C(110, 64, 14, 74)]), 1, shade={"bump": 0.9}),
        F("coast", None, g(polyline([(30, 44), (42, 48), (50, 42), (62, 50), (70, 46), (84, 54), (98, 50)], 2)), 1.2,
          "flat", color="#6e5c44", clip_to="sheet", opacity=0.8),
        F("sea", None, g([C(64, 34, 90, 26)]), 1.1, "flat", color="#5a6a78", clip_to="sheet", opacity=0.35),
        F("mountains", None, g([POLY(TRI_UP, 44, 84, 14, 10), POLY(TRI_UP, 56, 86, 12, 9), POLY(TRI_UP, 36, 88, 10, 8)]),
          1.3, "flat", color="#6e5c44", clip_to="sheet", opacity=0.75),
        F("route", "wax_red", g(route), 1.4, "flat", clip_to="sheet", opacity=0.85),
        F("target", "wax_red", g(ringp(92, 84, 14, 14, 2.4)), 1.5, "flat", clip_to="sheet"),
        F("compass", None, g([SPARK(96, 40, 12)]), 1.6, "flat", color="#6e5c44", clip_to="sheet", opacity=0.8),
    ]


@icon("C", "icon_empty_bottle", "Empty tall glass bottle with a long neck, dust at the bottom and a bright glint.")
def empty_bottle():
    glass = [RR(64, 90, 44, 60), C(64, 62, 44, 18), RR(64, 42, 14, 34), C(64, 25, 20, 7)]
    return [
        F("glass", "glass_dark", glass, 0, opacity=0.9, shade={"highlight_amount": 0.7}),
        F("inside", None, [RR(64, 92, 34, 50)], 0.5, "flat", color="#1c1824", clip_to="glass", opacity=0.45),
        F("dust", None, [C(64, 118, 36, 8)], 0.7, "flat", color="#6e6448", clip_to="glass", opacity=0.6),
        F("glint", None, [C(49, 88, 7, 44), sub(C(51, 87, 7, 44)), R(60, 40, 2, 26)], 1, "flat", color="glint",
          clip_to="glass", opacity=0.6),
    ]


@icon("C", "icon_crystal_ball", "Crystal ball: violet sphere with a pale inner swirl and glow, on a bronze stand with three claw feet.")
def crystal_ball():
    return [
        halo("aura", None, [C(64, 52, 88, 88)], 0, 6, 0.35, color="glow_arcane"),
        F("stand", "bronze", [C(64, 104, 62, 16), R(64, 96, 40, 12)], 1, "block", extrude=6),
        F("claws", "bronze", [D(38, 86, 10, 26, rot=-30), D(90, 86, 10, 26, rot=30), D(64, 90, 10, 22)], 1.5),
        F("ball", "gem_violet", [C(64, 54, 76, 76)], 2, shade={"highlight_amount": 0.7, "threshold": 0.45}),
        F("swirl", None, [MOON(60, 58, 40, 40, rot=30), MOON(70, 50, 26, 26, rot=210)], 2.5, "flat", color="#d8c0ff",
          clip_to="ball", opacity=0.5, blur=1),
        F("shine", None, [C(46, 34, 16, 10, rot=-35), C(84, 76, 5, 5)], 3, "flat", color="#ffffff", clip_to="ball",
          opacity=0.7),
    ]


def bone_piece(x0, y0, x1, y1, w):
    ang = math.degrees(math.atan2(y1 - y0, x1 - x0))
    length = math.hypot(x1 - x0, y1 - y0)
    nx, ny = -math.sin(math.radians(ang)), math.cos(math.radians(ang))
    out = [R((x0 + x1) / 2, (y0 + y1) / 2, length, w, rot=ang)]
    for (x, y) in ((x0, y0), (x1, y1)):
        out += [C(x + nx * w * 0.55, y + ny * w * 0.55, w * 1.35), C(x - nx * w * 0.55, y - ny * w * 0.55, w * 1.35)]
    return out


@icon("C", "icon_bone_material", "Two old crossed bones (crafting material), yellowed with grime.")
def bone_material():
    return [
        F("bone_back", "bone", bone_piece(28, 28, 100, 100, 12), 0),
        F("bone_front", "bone", bone_piece(100, 30, 28, 102, 12), 1),
    ]


@icon("C", "icon_hourglass", "Hourglass: wooden top and bottom plates with posts, two glass bulbs, sand falling into the lower bulb.")
def hourglass():
    upper = POLY([(0, 0), (1, 0), (0.56, 1), (0.44, 1)], 64, 42, 58, 40)
    lower = POLY([(0.44, 0), (0.56, 0), (1, 1), (0, 1)], 64, 84, 58, 40)
    return [
        F("glass", "glass_dark", [upper, lower, C(64, 40, 58, 30), C(64, 86, 58, 30)], 0, opacity=0.95),
        F("sand_top", None, [POLY([(0.1, 0), (0.9, 0), (0.55, 1), (0.45, 1)], 64, 50, 38, 20)], 0.5, "flat",
          color="#b09058", clip_to="glass"),
        F("sand_bottom", None, [C(64, 100, 50, 22)], 0.6, "flat", color="#b09058", clip_to="glass"),
        F("stream", None, [R(64, 78, 2.2, 26)], 0.7, "flat", color="#c8a868"),
        F("plates", "wood", [R(64, 18, 76, 10), R(64, 110, 76, 10)], 1, "block", extrude=4),
        F("posts", "wood", [R(30, 64, 6, 88), R(98, 64, 6, 88)], 1.5),
        F("glint", None, [C(46, 42, 6, 22, rot=20), C(48, 86, 6, 20, rot=-20)], 2, "flat", color="glint",
          clip_to="glass", opacity=0.45),
    ]


# ================================================================== C: equipment (listed before the g07 split)
@icon("C", "icon_scimitar", "Scimitar on the diagonal: broad curved steel blade, short bronze guard, wrapped grip, round pommel.")
def scimitar():
    g = g45(40)
    blade = [C(92, 58, 70, 110), sub(C(104, 58, 70, 110)), sub(R(64, 102, 90, 30))]
    return [
        F("blade", "steel", g(blade + [R(62, 82, 8, 12)]), 0),
        F("edge_hl", "steel_light", g([C(90, 58, 66, 106), sub(C(93, 58, 66, 106)), sub(R(64, 102, 90, 30))]), 0.5,
          "flat", clip_to="blade", opacity=0.45),
        F("guard", "bronze", g([RR(64, 90, 30, 7), C(50, 92, 7), C(78, 88, 7)]), 1),
        F("grip", "leather", g([RR(64, 104, 8, 20)]), 0.8),
        F("pommel", "bronze", g([C(64, 117, 11)]), 1),
    ]


@icon("C", "icon_scythe", "Great scythe: long dark wooden snath with bone grips and a huge blackened crescent blade.")
def scythe():
    g = g45(38)
    blade = [C(44, 34, 80, 50), sub(C(46, 41, 80, 50)), sub(R(96, 40, 30, 60))]
    return [
        F("snath", "wood_dark", g([R(84, 72, 8, 104)]), 0, color="#3a2c22"),
        F("grips", "bone", g([R(84, 74, 12, 7), R(84, 108, 11, 7)]), 0.5),
        F("blade", "iron_dark", g(blade), 1, shade={"highlight_amount": 0.7}),
        F("edge", "steel_light", g([C(44, 33, 80, 50), sub(C(44.5, 35.5, 80, 50)), sub(R(96, 40, 30, 60))]), 1.5,
          "flat", clip_to="blade", opacity=0.55),
        F("collar", "bronze", g([R(84, 30, 12, 14)]), 2),
    ]


@icon("C", "icon_katana", "Eastern single-edged sword: long gently curved blade with a pale temper line, round dark guard, diamond-wrapped hilt.")
def katana():
    g = g45(43)
    keep = dict(R(60, 48, 40, 80), op="clip")
    blade = [C(160, 40, 222, 222), sub(C(168, 40, 222, 222)), keep]
    hl = [C(160, 40, 222, 222), sub(C(162, 40, 222, 222)), keep]
    wraps = [POLY(DIAMOND, 64, 97 + k * 6.5, 6, 6) for k in range(4)]
    return [
        F("blade", "steel", g(blade + [POLY([(0, 1), (0.25, 0), (1, 1)], 57.7, 4.5, 8, 7)]), 0),
        F("temper", "steel_light", g(hl), 0.5, "flat", clip_to="blade", opacity=0.6),
        F("guard", "iron_dark", g([C(64, 90, 24, 9)]), 1),
        F("hilt", "cloth_blue", g([RR(64, 106, 9, 28)]), 0.8),
        F("wrap", "gold", g(wraps), 1.2, "flat", clip_to="hilt", opacity=0.9),
        F("cap", "iron_dark", g([RR(64, 121, 10, 5)]), 1.3),
    ]


@icon("C", "icon_war_fan", "Iron war fan, half open: wine-red silk between iron ribs, gold edge, pivot rivet with a tassel.")
def war_fan():
    cx, cy, r = 64, 100, 62
    sails = [wedge(cx, cy, r, 205, 335, steps=24), sub(wedge(cx, cy, 20, 200, 340, steps=12))]
    ribs = [spindle(cx, cy, cx + math.cos(math.radians(a)) * r * 0.98, cy + math.sin(math.radians(a)) * r * 0.98, 4)
            for a in range(210, 336, 18)]
    return [
        F("silk", "cloth_wine", sails, 0),
        F("edge", "gold", [wedge(cx, cy, r + 2, 205, 335, steps=24), sub(wedge(cx, cy, r - 4, 200, 340, steps=24))], 1),
        F("ribs", "iron", ribs, 1.5),
        F("pivot", "bronze", [C(cx, cy, 12)], 2),
        F("tassel", "cloth_wine", [R(cx, cy + 12, 3, 14), D(cx, cy + 22, 8, 16, flip="y")], 1.8),
    ]


@icon("C", "icon_jade_pendant", "Eastern jade ornament: pale green jade disc with a centre hole, tied wine knot above, long silk tassel below.")
def jade_pendant():
    return [
        F("cord", "cloth_wine", [R(64, 16, 3, 20)], 0),
        F("knot", "cloth_wine", [POLY(DIAMOND, 64, 32, 22, 22), C(52, 32, 9), C(76, 32, 9)], 1),
        F("disc", "gem_green", ringp(64, 66, 48, 48, 15), 2, color="#6a9a78", shade={"highlight_amount": 0.6}),
        F("disc_vein", None, [C(56, 58, 20, 8, rot=-30)], 2.5, "flat", color="#c8e8d0", clip_to="disc", opacity=0.35),
        F("bead", "gold", [C(64, 96, 10)], 3),
        F("tassel", "cloth_wine", [R(64 + dx, 112, 3, 24) for dx in (-6, -3, 0, 3, 6)], 2.8),
    ]


@icon("C", "icon_crown", "Gold crown: band with five points tipped with pearls, red and blue gems on the band.")
def crown():
    points = [POLY(TRI_UP, x, 50 - (8 if i == 2 else 0), 18, 34 + (8 if i == 2 else 0)) for i, x in enumerate((28, 46, 64, 82, 100))]
    return [
        F("crown", "gold", points + [R(64, 76, 88, 30)], 0, shade={"highlight_amount": 0.85}),
        F("rim", "gold_dark", [R(64, 64, 88, 3), R(64, 88, 88, 3)], 0.5, "flat", clip_to="crown", opacity=0.7),
        F("pearls", "bone", [C(28, 32, 8), C(46, 32, 8), C(64, 24, 9), C(82, 32, 8), C(100, 32, 8)], 1),
        F("gems_r", "gem_red", [C(64, 76, 14, 14)], 1),
        F("gems_b", "gem_blue", [C(38, 76, 10, 10), C(90, 76, 10, 10)], 1),
    ]


@icon("C", "icon_cloak", "Hooded travelling cloak: dark green wool with a deep hood, fold lines, bronze clasp.")
def cloak():
    body = POLY([(0.35, 0), (0.65, 0), (1, 1), (0.5, 0.94), (0, 1)], 64, 76, 90, 88)
    return [
        F("cloak", "cloth_green", [body, C(64, 36, 50, 44)], 0),
        F("hood_in", None, [C(64, 40, 32, 30)], 0.5, "flat", color="#0e120e", clip_to="cloak", opacity=0.9),
        F("folds", "herb_dark", [RR(48, 84, 4, 52, rot=12), RR(64, 88, 4, 56), RR(80, 84, 4, 52, rot=-12)], 0.7,
          "flat", clip_to="cloak", opacity=0.7),
        F("clasp", "bronze", [C(56, 62, 10), C(72, 62, 10), R(64, 62, 14, 3)], 1),
    ]


# ================================================================== C: skills
@icon("C", "icon_skill_earth", "Skill tile: ground splitting with jagged rock slabs thrown up and dust.")
def skill_earth():
    rocks = [POLY([(0.2, 1), (0, 0.4), (0.5, 0), (1, 0.3), (0.85, 1)], 40, 70, 30, 44, rot=-18),
             POLY([(0.1, 1), (0.3, 0.2), (0.7, 0), (1, 0.5), (0.9, 1)], 72, 56, 34, 60, rot=8),
             POLY([(0, 1), (0.2, 0.3), (0.6, 0), (1, 0.6), (0.8, 1)], 96, 76, 22, 34, rot=24)]
    return skill_plate("tint_earth") + [
        F("dust", "fx_dust", [P("cloud", 44, 94, 44, 22), P("cloud", 88, 96, 40, 20)], 1, "flat", clip_to="plate",
          opacity=0.6, blur=2),
        F("rocks", "fx_earth", rocks, 2, shade={"highlight_amount": 0.6}),
        F("crack", None, polyline([(20, 100), (40, 94), (56, 102), (74, 92), (92, 100), (110, 94)], 4), 2.5, "flat",
          color="void_violet", clip_to="plate"),
        F("chips", "fx_earth", [R(30, 44, 6, 5, rot=20), R(100, 40, 5, 5, rot=45), R(56, 30, 5, 4, rot=10)], 2.2),
    ]


@icon("C", "icon_skill_drain", "Skill tile: red life motes spiralling into a dark violet vortex.")
def skill_drain():
    motes = [C(64 + math.cos(math.radians(a)) * r, 64 + math.sin(math.radians(a)) * r, s)
             for a, r, s in ((20, 42, 9), (70, 34, 7), (130, 44, 8), (190, 30, 6), (250, 40, 9), (310, 32, 6))]
    trails = [spindle(64 + math.cos(math.radians(a)) * r, 64 + math.sin(math.radians(a)) * r,
                      64 + math.cos(math.radians(a + 40)) * r * 0.45, 64 + math.sin(math.radians(a + 40)) * r * 0.45, 4)
              for a, r, s in ((20, 42, 9), (130, 44, 8), (250, 40, 9))]
    return skill_plate("tint_curse") + [
        halo("glow", None, [C(64, 64, 56, 56)], 1, 6, 0.55, color="glow_shadow", clip_to="plate"),
        F("vortex", "fx_shadow", [MOON(64, 64, 58, 58, rot=20), MOON(64, 64, 42, 42, rot=200)], 1.5, "flat",
          clip_to="plate", opacity=0.9),
        F("core", None, [C(64, 64, 22, 22)], 2, "flat", color="#0c0612"),
        F("trails", "fx_red", trails, 2.2, "flat", clip_to="plate", opacity=0.6),
        F("motes", "gem_red", motes, 2.5),
    ]


@icon("C", "icon_skill_holy", "Skill tile: radiant golden eight-point star inside a halo ring with thin rays.")
def skill_holy():
    rays = [spindle(64, 64, 64 + math.cos(math.radians(a)) * 54, 64 + math.sin(math.radians(a)) * 54, 5)
            for a in range(0, 360, 30)]
    star = [POLY(star_pts(8, 0.42), 64, 64, 64, 64, rot=22.5)]
    return skill_plate("tint_holy") + [
        halo("glow", None, star + [C(64, 64, 70, 70)], 1, 7, 0.55, color="glow_holy", clip_to="plate"),
        F("rays", "fx_holy", rays, 1.5, "flat", clip_to="plate", opacity=0.7),
        F("ring", "fx_holy", ringp(64, 64, 86, 86, 3), 1.8, "flat", clip_to="plate", opacity=0.85),
        F("star", "gold", star, 2, shade={"highlight_amount": 0.9}),
        F("core", None, [C(64, 64, 14, 14)], 2.5, "flat", color="#fff8e0"),
    ]


# ================================================================== C: status
@icon("C", "icon_status_confuse", "Status badge: three nested pink-violet crescents turning in a swirl with small sparkles.")
def status_confuse():
    swirl = [MOON(64, 62, 74, 74, rot=0), MOON(64, 62, 52, 52, rot=120), MOON(64, 62, 30, 30, rot=240)]
    return status_badge("tint_curse") + [
        halo("glow", None, swirl, 1, 4, 0.5, color="glow_shadow", clip_to="badge"),
        F("swirl", None, swirl, 2, "flat", color="#d890d8"),
        F("sparks", None, [SPARK(96, 36, 13), SPARK(30, 92, 10)], 2.5, "flat", color="#ffe0ff", clip_to="badge"),
    ]


@icon("C", "icon_status_regen", "Status badge: two green leaves inside a looping arrow (healing over time).")
def status_regen():
    loop = ringp(64, 64, 76, 76, 7) + [sub(wedge(64, 64, 50, 300, 340, steps=6))]
    head = [POLY([(0, 0), (1, 0.5), (0, 1)], 86, 37, 20, 20, rot=30)]
    return status_badge("tint_heal") + [
        halo("glow", None, loop + head, 1, 4, 0.5, color="glow_heal", clip_to="badge"),
        F("loop", "fx_heal", loop + head, 2, "flat"),
        F("leaves", "herb", [D(56, 66, 18, 34, rot=-35), D(72, 66, 18, 34, rot=35)], 2.5),
        F("veins", "herb_dark", [R(56, 66, 1.5, 24, rot=-35), R(72, 66, 1.5, 24, rot=35)], 2.7, "flat",
          clip_to="leaves", opacity=0.7),
    ]


@icon("C", "icon_status_haste", "Status badge: double chevron pointing right with speed streaks (faster).")
def status_haste():
    chev = [(0, 0), (0.45, 0), (1, 0.5), (0.45, 1), (0, 1), (0.55, 0.5)]
    shapes = [POLY(chev, 58, 64, 34, 50), POLY(chev, 84, 64, 34, 50)]
    streaks = [spindle(16, y, 44, y, 4) for y in (50, 64, 78)]
    return status_badge("tint_wind") + [
        F("streaks", None, streaks, 1, "flat", color="glow_wind", clip_to="badge", opacity=0.7),
        halo("glow", None, shapes, 1.5, 4, 0.5, color="glow_wind", clip_to="badge"),
        F("chevrons", "fx_wind", shapes, 2, "flat"),
        F("chev_core", None, [POLY(chev, 58, 64, 20, 30), POLY(chev, 84, 64, 20, 30)], 2.2, "flat", color="#ffffff",
          clip_to="chevrons", opacity=0.4),
    ]


# ------------------------------------------------------------------ main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--stage", default="all")
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    n = 0
    for stage, asset, note, fn in ICONS:
        if args.stage != "all" and stage != args.stage:
            continue
        if only and asset not in only:
            continue
        save(RDIR, asset, fn(), (128, 128), "icon", note=note,
             meta={"kind": "icon", "stage": stage, "list": "docs/art/projects/generic/catalog/g01_list.md"})
        n += 1
    print(f"wrote {n} icon recipes to {RDIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
