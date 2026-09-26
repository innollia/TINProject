"""g01 effect recipes: battle and magic animations, 192 x 192 cells, 5 frames each.

    py -3 -B gen_fx.py [--stage A|B|C|all] [--only fx_a,fx_b]

Flat view, transparent background, no ink silhouette (light should not get an
outline).  Free-standing light is a blurred flat form (g01kit.halo).  Frames are
tagged f1..f5 (g01kit.animate); row_sheet.py joins them into one 960 x 192 row.
"""

from __future__ import annotations

import argparse
import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g01kit import (C, D, F, MOON, P, POLY, R, RR, SPARK, STAR, animate, around, halo, ngon, poly_abs,  # noqa: E402
                    polyline, ringp, rrect, save, scale, shift, spindle, star_pts, sub, turn, wedge)

RDIR = Path(__file__).resolve().parents[1] / "recipes"
FX: list = []
CX = CY = 96


def fx(stage, asset, note):
    def deco(fn):
        FX.append((stage, asset, note, fn))
        return fn
    return deco


def clip(piece):
    piece = dict(piece)
    piece["op"] = "clip"
    return piece


def sparks(rng, n, cx, cy, rx, ry, smin, smax):
    out = []
    for _ in range(n):
        a = rng.uniform(0, 2 * math.pi)
        r = math.sqrt(rng.uniform(0.15, 1.0))
        out.append(SPARK(cx + math.cos(a) * rx * r, cy + math.sin(a) * ry * r, rng.uniform(smin, smax)))
    return out


def light(name, mat, pieces, z, glow_color, blur, glow_op=0.55, opacity=1.0, **kw):
    """Core shape + its halo underneath."""
    return [halo(name + "_halo", None, pieces, z - 0.05, blur, glow_op, color=glow_color, **kw),
            F(name, mat, pieces, z, "flat", opacity=opacity, **kw)]


# ================================================================== A
@fx("A", "fx_slash", "Sword slash: a steel-white crescent sweeps from upper right to lower left, flashes, thins and fades with sparks.")
def slash():
    rng = random.Random(11)
    r = 150

    def arc(d, a0, a1, soft, op, core_op=0.9):
        crescent = [C(CX, CY, r, r), sub(C(CX + d, CY + d, r, r))]
        inner = [C(CX + d * 0.35, CY + d * 0.35, r - d * 0.6, r - d * 0.6),
                 sub(C(CX + d * 0.8, CY + d * 0.8, r - d * 0.6, r - d * 0.6))]
        out = [F("sweep", None, [wedge(CX + d / 2, CY + d / 2, r, a0, a1, steps=24)], 0, "flat", color="#ffffff",
                 opacity=0.0, blur=soft)]
        out += light("arc", "fx_steel", crescent, 1, "glow_steel", 7, glow_op=0.6 * op, opacity=op, clip_to="sweep")
        out.append(F("core", "fx_white", inner, 1.2, "flat", opacity=core_op * op, clip_to="sweep"))
        return out

    f1 = arc(8, 325, 255, 8, 0.85) + [F("tip", None, [SPARK(77, 25, 22)], 2, "flat", color="#ffffff")]
    f2 = arc(12, 330, 175, 7, 1.0) + [F("tip", None, [SPARK(23, 102, 20)], 2, "flat", color="#ffffff")]
    f3 = arc(13, 335, 125, 5, 1.0) + [F("sparks", None, sparks(rng, 6, 70, 70, 60, 60, 8, 16), 2, "flat",
                                        color="#ffffff", opacity=0.9)]
    f4 = arc(7, 335, 125, 5, 0.6, 0.6) + [F("sparks", None, sparks(rng, 5, 64, 64, 70, 70, 6, 11), 2, "flat",
                                            color="glow_steel", opacity=0.7)]
    f5 = arc(3.5, 335, 125, 5, 0.3, 0.4) + [F("sparks", None, sparks(rng, 3, 60, 60, 75, 75, 4, 7), 2, "flat",
                                              color="glow_steel", opacity=0.45)]
    return animate([f1, f2, f3, f4, f5], "fx_slash")


@fx("A", "fx_thrust", "Thrust: a narrow white streak drives from lower left to upper right, a four-point flash and ring burst at the tip.")
def thrust():
    rng = random.Random(23)
    tip = (140, 52)

    def speed_lines(n, spread, op):
        out = []
        for k in range(n):
            o = (k - (n - 1) / 2) * spread
            x0, y0 = 30 + o * 0.7, 150 + o * 0.7
            out.append(spindle(x0, y0, x0 + 60, y0 - 60, 3))
        return F("lines", None, out, 0.5, "flat", color="glow_steel", opacity=op)

    f1 = light("streak", "fx_white", [spindle(34, 158, 92, 100, 12)], 1, "glow_steel", 6) + [speed_lines(4, 16, 0.35)]
    f2 = light("streak", "fx_white", [spindle(36, 156, *tip, 16)], 1, "glow_steel", 7) + [speed_lines(5, 14, 0.4)]
    f3 = (light("streak", "fx_steel", [spindle(70, 122, *tip, 10)], 1, "glow_steel", 6, glow_op=0.4, opacity=0.7)
          + light("flash", "fx_white", [SPARK(*tip, 64)], 2, "glow_steel", 10, glow_op=0.7)
          + [F("ring", None, ringp(*tip, 40, 40, 4), 1.5, "flat", color="fx_white", opacity=0.9)])
    f4 = (light("flash", "fx_white", [SPARK(*tip, 44)], 2, "glow_steel", 12, glow_op=0.5, opacity=0.75)
          + [F("ring", None, ringp(*tip, 76, 76, 3), 1.5, "flat", color="glow_steel", opacity=0.7),
             F("bits", None, sparks(rng, 6, tip[0], tip[1], 42, 42, 5, 10), 2.2, "flat", color="#ffffff",
               opacity=0.85)])
    f5 = [F("ring", None, ringp(*tip, 88, 88, 2), 1.5, "flat", color="glow_steel", opacity=0.35),
          F("bits", None, sparks(rng, 4, tip[0], tip[1], 55, 55, 3, 6), 2.2, "flat", color="glow_steel", opacity=0.5)]
    return animate([f1, f2, f3, f4, f5], "fx_thrust")


@fx("A", "fx_blunt_hit", "Blunt impact: white-gold star burst, expanding shock ring, dust puffs and flying chips.")
def blunt_hit():
    rng = random.Random(37)
    c = (96, 96)
    burst = lambda s, rot=0: POLY(star_pts(8, 0.42), c[0], c[1], s, s, rot=rot)

    def dust(n, spread, size, op):
        pcs = []
        for k in range(n):
            a = math.radians(180 + (k + 0.5) * 180.0 / n)
            pcs.append(P("cloud", c[0] + math.cos(a) * spread * 1.1, c[1] + 34 + math.sin(a) * spread * 0.25,
                         size, size * 0.62))
        return F("dust", "fx_dust", pcs, 0.8, "flat", opacity=op, blur=2)

    f1 = light("core", "fx_white", [C(*c, 34, 34), burst(56)], 1, "glow_gold", 8)
    f2 = (light("burst", "fx_gold", [burst(130, 10)], 1, "glow_gold", 10, glow_op=0.6)
          + light("core", "fx_white", [burst(80, 10), C(*c, 40, 40)], 1.2, "glow_gold", 4))
    f3 = (light("burst", "fx_gold", [burst(96, 22)], 1, "glow_gold", 8, glow_op=0.5, opacity=0.85)
          + [F("ring", None, ringp(*c, 120, 120, 5), 0.9, "flat", color="fx_white", opacity=0.85),
             dust(4, 40, 40, 0.8)])
    f4 = [F("ring", None, ringp(*c, 164, 164, 3), 0.9, "flat", color="glow_gold", opacity=0.55),
          F("core", "fx_gold", [burst(46, 30)], 1, "flat", opacity=0.55),
          dust(5, 56, 50, 0.65),
          F("chips", "fx_dust", [R(c[0] + math.cos(a) * 60, c[1] + math.sin(a) * 50, 7, 5, rot=a * 50)
                                 for a in [rng.uniform(3.4, 6.0) for _ in range(6)]], 1.2, "flat", opacity=0.9)]
    f5 = [dust(5, 64, 56, 0.35),
          F("ring", None, ringp(*c, 184, 184, 2), 0.9, "flat", color="glow_gold", opacity=0.22)]
    return animate([f1, f2, f3, f4, f5], "fx_blunt_hit")


def flames(rng, n, base_y, height, width, spread):
    pcs = []
    for k in range(n):
        f = (k + 0.5) / n
        x = CX + (f - 0.5) * spread + rng.uniform(-4, 4)
        h = height * (1.0 - abs(f - 0.5) * 1.1) * rng.uniform(0.85, 1.1)
        w = width * rng.uniform(0.8, 1.15)
        pcs.append(D(x, base_y - h / 2.0, w, h, rot=(f - 0.5) * 24 + rng.uniform(-5, 5)))
    return pcs


@fx("A", "fx_fire_burst", "Fire burst: flames flare up from the ground, peak with a hot core and embers, break into tongues and dark smoke.")
def fire_burst():
    rng = random.Random(41)
    base = 160

    def blaze(n, h, w, spread, core_k, op=1.0):
        outer = flames(rng, n, base, h, w, spread)
        inner = flames(rng, max(2, n - 2), base + 4, h * core_k, w * 0.6, spread * 0.6)
        return (light("flame", "fx_fire", outer + [C(CX, base - 4, spread * 0.9, 26)], 1, "glow_fire", 10,
                      glow_op=0.55 * op, opacity=op)
                + [F("core", "fx_fire_core", inner, 1.3, "flat", opacity=op)])

    def embers(n, y0, y1, op):
        return F("embers", "fx_fire_core", [C(CX + rng.uniform(-60, 60), rng.uniform(y0, y1), rng.uniform(3, 6))
                                            for _ in range(n)], 2, "flat", opacity=op)

    def smoke(n, y, size, op):
        return F("smoke", "fx_smoke", [P("cloud", CX + rng.uniform(-40, 40), y + rng.uniform(-14, 14), size,
                                         size * 0.62) for _ in range(n)], 0.5, "flat", opacity=op, blur=3)

    f1 = blaze(3, 58, 28, 40, 0.55)
    f2 = blaze(5, 108, 32, 70, 0.6) + [embers(4, 70, 120, 0.9)]
    f3 = blaze(7, 150, 34, 104, 0.62) + [embers(8, 20, 110, 1.0),
                                         F("hot", None, [C(CX, base - 20, 44, 30)], 1.5, "flat", color="#fff4c0",
                                           blur=6, opacity=0.8)]
    f4 = [smoke(3, 50, 60, 0.6)] + blaze(6, 110, 26, 110, 0.5, op=0.85) + [embers(8, 10, 90, 0.9)]
    f5 = [smoke(4, 38, 72, 0.5)] + blaze(4, 50, 20, 90, 0.45, op=0.6) + [embers(5, 0, 60, 0.6)]
    return animate([f1, f2, f3, f4, f5], "fx_fire_burst")


def shard(x, y, w, h, rot):
    return POLY([(0.5, 0), (1, 0.22), (0.86, 1), (0.14, 1), (0, 0.22)], x, y, w, h, rot=rot)


@fx("A", "fx_ice_shards", "Ice shards: a frost ring spreads, crystals burst upward, glint, crack into flying fragments and mist.")
def ice_shards():
    rng = random.Random(53)
    base = 150
    spec = [(-54, 70, -34), (-30, 104, -18), (-8, 130, -4), (14, 118, 8), (36, 96, 22), (58, 64, 36), (0, 60, 0)]

    def crystals(k, count):
        pcs = []
        for dx, h, rot in spec[:count]:
            hh = h * k
            a = math.radians(rot)
            pcs.append(shard(CX + dx + math.sin(a) * hh / 2, base - math.cos(a) * hh / 2, max(8, hh * 0.24), hh, rot))
        return pcs

    def frost(w, op):
        return F("frost", None, ringp(CX, base, w, w * 0.34, 5), 0.4, "flat", color="fx_ice", blur=2, opacity=op)

    def mist(n, size, op):
        return F("mist", None, [P("cloud", CX + rng.uniform(-50, 50), base - rng.uniform(0, 40), size, size * 0.6)
                                for _ in range(n)], 3, "flat", color="#dcefff", blur=10, opacity=op * 0.55)

    f1 = [frost(70, 0.8), F("floor", None, [C(CX, base, 60, 20)], 0.3, "flat", color="glow_ice", blur=6,
                             opacity=0.5)] + [F("ice", "ice", crystals(0.35, 3), 1)]
    f2 = [frost(120, 0.7), halo("ice_halo", None, crystals(0.75, 6), 0.9, 6, 0.4, color="glow_ice"),
          F("ice", "ice", crystals(0.75, 6), 1)]
    f3 = [frost(160, 0.5), halo("ice_halo", None, crystals(1.0, 7), 0.9, 8, 0.5, color="glow_ice"),
          F("ice", "ice", crystals(1.0, 7), 1),
          F("glints", None, sparks(rng, 5, CX, base - 70, 60, 50, 9, 18), 2, "flat", color="#ffffff")]
    frags = [shard(CX + rng.uniform(-80, 80), base - rng.uniform(20, 130), rng.uniform(6, 12), rng.uniform(14, 26),
                   rng.uniform(-60, 60)) for _ in range(12)]
    f4 = [frost(170, 0.3), F("ice", "ice", crystals(0.6, 5), 1, opacity=0.75), F("frags", "ice", frags, 1.5),
          mist(4, 60, 0.35)]
    f5 = [F("frags", "ice", frags[::2], 1.5, opacity=0.5), mist(5, 72, 0.3)]
    return animate([f1, f2, f3, f4, f5], "fx_ice_shards")


def bolt_path(rng, x0, y0, x1, y1, n, jitter):
    pts = [(x0, y0)]
    for k in range(1, n):
        f = k / n
        pts.append((x0 + (x1 - x0) * f + rng.uniform(-jitter, jitter), y0 + (y1 - y0) * f))
    pts.append((x1, y1))
    return pts


@fx("A", "fx_lightning_strike", "Lightning strike: a jagged bolt drops from the top, flashes on the ground with branches and sparks, then leaves an afterglow.")
def lightning_strike():
    rng = random.Random(67)
    main = bolt_path(rng, 104, -4, 94, 156, 9, 18)
    br1 = bolt_path(rng, main[3][0], main[3][1], 40, 116, 5, 10)
    br2 = bolt_path(rng, main[5][0], main[5][1], 156, 142, 4, 9)
    ground = (94, 156)

    def bolt(points, width, op=1.0, glow=0.65):
        return (light("bolt", "fx_bolt", polyline(points, width), 1, "glow_bolt", 9, glow_op=glow * op, opacity=op)
                + [F("bolt_core", "fx_bolt_core", polyline(points, max(1.2, width * 0.4)), 1.2, "flat", opacity=op)])

    f1 = bolt(main[:5], 5, 0.85, 0.5)
    f2 = bolt(main, 8) + [halo("flash", None, [C(*ground, 110, 40)], 0.5, 8, 0.8, color="glow_bolt")]
    f3 = (bolt(main, 10) + [F("branches", "fx_bolt", polyline(br1, 4) + polyline(br2, 4), 1.1, "flat"),
                            halo("flash", None, [C(*ground, 170, 60)], 0.5, 12, 0.9, color="glow_bolt"),
                            F("sparks", None, sparks(rng, 7, ground[0], ground[1] - 20, 70, 30, 7, 14), 2, "flat",
                              color="#fffbe6")])
    f4 = (bolt(main, 5, 0.45, 0.4) + [halo("flash", None, [C(*ground, 150, 50)], 0.5, 14, 0.5, color="glow_bolt"),
                                      F("sparks", None, sparks(rng, 6, ground[0], ground[1] - 40, 80, 50, 5, 10), 2,
                                        "flat", color="glow_bolt", opacity=0.8)])
    f5 = [halo("flash", None, [C(*ground, 120, 40)], 0.5, 14, 0.3, color="glow_bolt"),
          F("sparks", None, sparks(rng, 4, ground[0], ground[1] - 50, 80, 50, 4, 7), 2, "flat", color="glow_bolt",
            opacity=0.5)]
    return animate([f1, f2, f3, f4, f5], "fx_lightning_strike")


def plus(x, y, s):
    return [RR(x, y, s * 0.34, s), RR(x, y, s, s * 0.34)]


@fx("A", "fx_heal_light", "Healing light: green-gold glow gathers on the ground, a soft column rises with floating crosses and sparkles, then drifts away.")
def heal_light():
    rng = random.Random(79)
    base = 158

    def column(h, op):
        return [halo("column", None, rrect(CX, base - h / 2, 60, h, 30), 0.5, 10, 0.5 * op, color="glow_heal"),
                F("column_core", None, rrect(CX, base - h / 2, 22, h, 11), 0.6, "flat", color="#e8ffe8", blur=6,
                  opacity=0.45 * op)]

    def crosses(n, y0, y1, smin, smax, op):
        pcs = []
        for _ in range(n):
            pcs += plus(CX + rng.uniform(-50, 50), rng.uniform(y0, y1), rng.uniform(smin, smax))
        return light("cross", "fx_heal", pcs, 1.5, "glow_heal", 4, glow_op=0.5 * op, opacity=op)

    ground = lambda w, op: halo("ground", None, [C(CX, base, w, w * 0.3)], 0.3, 8, op, color="glow_heal")
    f1 = [ground(90, 0.7), F("sparks", None, sparks(rng, 3, CX, base - 16, 40, 12, 6, 10), 2, "flat",
                               color="#effff0")]
    f2 = [ground(130, 0.8)] + column(90, 0.8) + crosses(3, 90, 140, 12, 18, 1.0)
    f3 = [ground(150, 0.8)] + column(160, 1.0) + crosses(5, 30, 130, 12, 22, 1.0) + [
        F("sparks", None, sparks(rng, 6, CX, 70, 60, 60, 6, 12), 2, "flat", color="#effff0")]
    f4 = [ground(130, 0.4)] + column(170, 0.5) + crosses(4, 10, 90, 10, 18, 0.75) + [
        F("sparks", None, sparks(rng, 5, CX, 50, 60, 50, 5, 10), 2, "flat", color="#effff0", opacity=0.8)]
    f5 = crosses(2, 0, 50, 8, 12, 0.4) + [F("sparks", None, sparks(rng, 4, CX, 30, 60, 30, 4, 8), 2, "flat",
                                           color="#effff0", opacity=0.5)]
    return animate([f1, f2, f3, f4, f5], "fx_heal_light")


# ================================================================== B
def arrow_pieces(tx, ty, length, rot, hide_tip=False):
    """Arrow pointing along +x (then turned by rot about the tip): shaft, head, fletching."""
    x0 = tx - length
    shaft = [R((x0 + tx - 12) / 2.0, ty, length - 12, 5.5)]
    head = [] if hide_tip else [POLY([(0, 0), (1, 0.5), (0, 1), (0.25, 0.5)], tx - 9, ty, 20, 16)]
    fletch = [D(x0 + 10, ty - 7, 10, 26, rot=-100), D(x0 + 10, ty + 7, 10, 26, rot=-80)]
    return [turn(shaft, rot, tx, ty), turn(head, rot, tx, ty), turn(fletch, rot, tx, ty)]


@fx("B", "fx_arrow_hit", "Arrow hit: an arrow streaks in from the left, strikes with a flash and ring, sticks and quivers as the flash fades.")
def arrow_hit():
    rng = random.Random(89)
    hit = (136, 100)

    def arrow(tx, ty, length, rot, hide_tip=False, op=1.0):
        shaft, head, fletch = arrow_pieces(tx, ty, length, rot, hide_tip)
        out = [halo("arrow_glow", None, shaft + head + fletch, 0.8, 4, 0.35 * op, color="glow_steel"),
               F("shaft", "cork", shaft, 1, opacity=op), F("fletch", "cloth_wine", fletch, 1.1, opacity=op)]
        if head:
            out.append(F("head", "steel", head, 1.2, opacity=op))
        return out

    streaks = lambda x0, x1, op: F("streaks", None, [spindle(x0, hit[1] + o, x1, hit[1] + o * 0.6, 3)
                                                      for o in (-12, 0, 12)], 0.5, "flat", color="glow_steel",
                                   opacity=op)
    f1 = arrow(84, 96, 88, 6) + [streaks(4, 70, 0.5)]
    f2 = arrow(hit[0], hit[1], 96, 6) + [streaks(20, 110, 0.45),
                                          F("spark", None, [SPARK(*hit, 24)], 2, "flat", color="#ffffff")]
    f3 = (arrow(hit[0] - 6, hit[1], 90, 6, hide_tip=True)
          + light("flash", "fx_white", [POLY(star_pts(8, 0.4), hit[0], hit[1], 66, 66, rot=8)], 2, "glow_steel", 8)
          + [F("ring", None, ringp(*hit, 60, 60, 3), 1.8, "flat", color="fx_white", opacity=0.8)])
    f4 = (arrow(hit[0] - 6, hit[1], 90, 10, hide_tip=True)
          + [F("ring", None, ringp(*hit, 88, 88, 2), 1.8, "flat", color="glow_steel", opacity=0.5),
             F("chips", "fx_dust", [R(hit[0] + rng.uniform(-10, 30), hit[1] + rng.uniform(-30, 30), 6, 5,
                                      rot=rng.uniform(0, 90)) for _ in range(6)], 2, "flat")])
    f5 = arrow(hit[0] - 6, hit[1], 90, 3, hide_tip=True) + [
        F("ring", None, ringp(*hit, 100, 100, 1.6), 1.8, "flat", color="glow_steel", opacity=0.25)]
    return animate([f1, f2, f3, f4, f5], "fx_arrow_hit")


@fx("B", "fx_summon_pillar", "Summon: an arcane ring lights on the ground, a pillar of light rises to full height with rising motes, then fades.")
def summon_pillar():
    rng = random.Random(97)
    base = 160

    def ground(op, w=150):
        marks = around(8, CX, base, w * 0.43, w * 0.43 * 0.3, lambda x, y, k, a: POLY([(0.5, 0), (1, 0.5), (0.5, 1), (0, 0.5)],
                                                                                  x, y, 8, 5))
        return [halo("ground_glow", None, [C(CX, base, w, w * 0.32)], 0.2, 8, 0.5 * op, color="glow_arcane"),
                F("ring", "fx_arcane", ringp(CX, base, w, w * 0.32, 3) + ringp(CX, base, w * 0.72, w * 0.23, 2), 0.4,
                  "flat", opacity=op),
                F("marks", None, marks, 0.5, "flat", color="#d8e0ff", opacity=op)]

    def pillar(top, width, op):
        h = base - top
        return [halo("pillar_glow", None, rrect(CX, top + h / 2, width, h, width / 2), 1, 10, 0.6 * op,
                     color="glow_arcane"),
                F("pillar", None, rrect(CX, top + h / 2, width * 0.55, h, width * 0.27), 1.2, "flat", color="#c8d2ff",
                  blur=4, opacity=0.8 * op),
                F("pillar_core", None, rrect(CX, top + h / 2, width * 0.18, h, width * 0.09), 1.4, "flat",
                  color="#ffffff", blur=2, opacity=op)]

    motes = lambda n, y0, y1, op: F("motes", None, [C(CX + rng.uniform(-40, 40), rng.uniform(y0, y1),
                                                      rng.uniform(3, 6)) for _ in range(n)], 2, "flat",
                                    color="#d8e0ff", opacity=op)
    f1 = ground(0.9)
    f2 = ground(1.0) + pillar(100, 40, 0.8)
    f3 = ground(1.0) + pillar(-4, 52, 1.0) + [motes(6, 40, 150, 0.9)]
    f4 = ground(0.7) + pillar(-4, 70, 0.55) + [motes(8, 10, 120, 0.8)]
    f5 = ground(0.35) + [motes(6, 0, 90, 0.5)]
    return animate([f1, f2, f3, f4, f5], "fx_summon_pillar")


@fx("B", "fx_magic_circle", "Magic circle, looping: double ring with tick marks turning one way and a hexagram with node circles turning the other.")
def magic_circle():
    frames = []
    for k in range(5):
        a_in, a_out = k * 12.0, -k * 6.0
        ticks = around(12, CX, CY, 80, 80, lambda x, y, i, a: R(x, y, 3, 9), a0=a_out, a1=a_out + 360, orient=True)
        dots = around(24, CX, CY, 69, 69, lambda x, y, i, a: C(x, y, 3.2 if i % 2 else 5.5), a0=a_in, a1=a_in + 360)
        tri_pts = lambda a0: [(CX + 58 * math.cos(math.radians(a0 + j * 120)), CY + 58 * math.sin(math.radians(a0 + j * 120)))
                              for j in range(4)]
        hexa = polyline(tri_pts(a_in - 90), 3) + polyline(tri_pts(a_in + 90), 3)
        hexa += [C(x, y, 8) for x, y in tri_pts(a_in - 90)[:3] + tri_pts(a_in + 90)[:3]]
        rings = (ringp(CX, CY, 176, 176, 3) + ringp(CX, CY, 124, 124, 2.4) + ringp(CX, CY, 58, 58, 2)
                 + ringp(CX, CY, 20, 20, 2))
        fl = [halo("glow", None, rings + hexa, 0.5, 6, 0.55, color="glow_arcane"),
              F("fill", None, [C(CX, CY, 124, 124)], 0.6, "flat", color="#6a7cf0", opacity=0.12),
              F("lines", "fx_arcane", rings + ticks + hexa, 1, "flat", opacity=0.95),
              F("dots", None, dots, 1.2, "flat", color="#d8e0ff", opacity=0.9),
              F("core", None, [C(CX, CY, 10, 10)], 1.3, "flat", color="#ffffff")]
        frames.append(fl)
    return animate(frames, "fx_magic_circle")


@fx("B", "fx_explosion", "Explosion: white flash, fireball bursting outward with a shock ring, then rolling dark smoke with embers.")
def explosion():
    rng = random.Random(113)

    def puffs(n, r, smin, smax, jitter=0.35):
        pcs = []
        for k in range(n):
            a = math.radians(k * 360.0 / n + rng.uniform(-20, 20))
            d = r * rng.uniform(1 - jitter, 1)
            s = rng.uniform(smin, smax)
            pcs.append(P("cloud", CX + math.cos(a) * d, CY + math.sin(a) * d * 0.85, s, s * 0.7,
                         rot=rng.uniform(-25, 25)))
        return pcs

    def smoke(n, r, size, op):
        return F("smoke", "fx_smoke", [P("cloud", CX + rng.uniform(-r, r), CY + rng.uniform(-r, r * 0.6), size,
                                         size * 0.62) for _ in range(n)], 0.5, "flat", blur=3, opacity=op)

    f1 = light("core", "fx_white", [C(CX, CY, 46, 46), POLY(star_pts(10, 0.5), CX, CY, 70, 70)], 1, "glow_fire", 8)
    f2 = (light("fire", "fx_fire", puffs(8, 30, 34, 52) + [C(CX, CY, 70, 64)], 1, "glow_fire", 10)
          + [F("core", "fx_fire_core", puffs(5, 14, 26, 38) + [C(CX, CY, 44, 40)], 1.2, "flat"),
             F("hot", None, [C(CX, CY, 30, 28)], 1.4, "flat", color="#fff6d0", blur=4)])
    f3 = (light("fire", "fx_fire", puffs(11, 50, 44, 66) + [C(CX, CY, 104, 96)], 1, "glow_fire", 12)
          + [F("deep", "fx_fire_deep", puffs(7, 58, 26, 40), 0.9, "flat", opacity=0.8),
             F("core", "fx_fire_core", puffs(6, 22, 34, 48) + [C(CX, CY, 60, 54)], 1.2, "flat", opacity=0.95),
             F("ring", None, ringp(CX, CY, 180, 170, 3), 0.8, "flat", color="#ffe0a0", opacity=0.55)])
    f4 = [smoke(7, 44, 78, 0.85),
          halo("underglow", None, puffs(5, 26, 30, 44), 0.7, 8, 0.7, color="glow_fire"),
          F("embers", "fx_fire_core", [C(CX + rng.uniform(-80, 80), CY + rng.uniform(-80, 70), rng.uniform(3, 6))
                                       for _ in range(10)], 2, "flat")]
    f5 = [smoke(7, 52, 82, 0.5),
          F("embers", "fx_fire_core", [C(CX + rng.uniform(-80, 80), CY + rng.uniform(-86, 50), rng.uniform(2, 4))
                                       for _ in range(7)], 2, "flat", opacity=0.6)]
    return animate([f1, f2, f3, f4, f5], "fx_explosion")


@fx("B", "fx_poison_cloud", "Poison cloud: green puffs swell from the ground with rising bubbles, peak, then drift up and thin out.")
def poison_cloud():
    rng = random.Random(127)
    base = 150

    def cloud(n, spread, y, size, op):
        pcs = [P("cloud", CX + rng.uniform(-spread, spread), y + rng.uniform(-spread * 0.4, spread * 0.3), size,
                 size * 0.62) for _ in range(n)]
        return [F("cloud_dark", "fx_poison_deep", pcs, 0.8, "flat", blur=3, opacity=op),
                F("cloud", "fx_poison", scale(pcs, 0.8, CX, y), 1, "flat", blur=4, opacity=op * 0.8)]

    def bubbles(n, y0, y1, op, rings=False):
        pcs = []
        for _ in range(n):
            x, y, s = CX + rng.uniform(-60, 60), rng.uniform(y0, y1), rng.uniform(6, 12)
            pcs += ringp(x, y, s, s, 1.6) if rings else [C(x, y, s)]
        return F("bubbles", None, pcs, 2, "flat", color="glow_poison", opacity=op)

    f1 = cloud(3, 24, base, 50, 0.8)
    f2 = cloud(5, 40, base - 16, 66, 0.85) + [bubbles(3, 90, 130, 0.9)]
    f3 = cloud(7, 56, base - 30, 80, 0.9) + [bubbles(5, 40, 110, 0.9), bubbles(3, 30, 90, 0.7, rings=True)]
    f4 = cloud(6, 48, base - 46, 78, 0.6) + [bubbles(4, 20, 80, 0.6, rings=True)]
    f5 = cloud(5, 46, base - 58, 80, 0.3)
    return animate([f1, f2, f3, f4, f5], "fx_poison_cloud")


@fx("B", "fx_dark_wave", "Dark wave: a void orb pulses, violet shock rings roll outward with shadow spikes and motes, then fade.")
def dark_wave():
    rng = random.Random(131)

    def spikes(n, r0, r1, w, op):
        pcs = []
        for k in range(n):
            a = math.radians(k * 360.0 / n + 15)
            pcs.append(spindle(CX + math.cos(a) * r0, CY + math.sin(a) * r0, CX + math.cos(a) * r1,
                               CY + math.sin(a) * r1, w))
        return F("spikes", "fx_shadow", pcs, 0.8, "flat", opacity=op)

    orb = lambda s, op: [halo("orb_glow", None, [C(CX, CY, s * 1.4, s * 1.4)], 1, 6, 0.6 * op, color="glow_shadow"),
                         F("orb", None, [C(CX, CY, s, s)], 1.2, "flat", color="#0c0612", opacity=op),
                         F("orb_rim", None, ringp(CX, CY, s, s, 2), 1.3, "flat", color="glow_shadow", opacity=op)]
    ring = lambda d, t, op: F("ring", None, ringp(CX, CY, d, d, t), 1.5, "flat", color="glow_shadow", opacity=op)
    motes = lambda n, r, op: F("motes", None, [C(CX + rng.uniform(-r, r), CY + rng.uniform(-r, r), rng.uniform(3, 5))
                                               for _ in range(n)], 2, "flat", color="#c8a0ff", opacity=op)
    f1 = orb(34, 1.0)
    f2 = orb(44, 1.0) + [ring(80, 6, 0.9), spikes(6, 24, 62, 8, 0.9)]
    f3 = orb(40, 0.9) + [ring(130, 6, 0.8), ring(84, 3, 0.6), spikes(8, 28, 86, 10, 0.85), motes(8, 80, 0.9)]
    f4 = orb(30, 0.7) + [ring(170, 4, 0.5), ring(124, 3, 0.4), spikes(8, 30, 60, 6, 0.5), motes(8, 88, 0.7)]
    f5 = orb(20, 0.4) + [ring(186, 2, 0.25), motes(5, 90, 0.45)]
    return animate([f1, f2, f3, f4, f5], "fx_dark_wave")


@fx("B", "fx_holy_light", "Holy light: a golden shaft falls from above, blooms into a four-point star with rays, then sparkles drift down.")
def holy_light():
    rng = random.Random(137)
    base = 150

    def shaft(width, op):
        return [halo("shaft", None, [POLY([(0.3, 0), (0.7, 0), (1, 1), (0, 1)], CX, (base - 10) / 2, width * 1.6,
                                          base + 10)], 0.5, 10, 0.5 * op, color="glow_holy"),
                F("shaft_core", None, [POLY([(0.35, 0), (0.65, 0), (0.8, 1), (0.2, 1)], CX, (base - 10) / 2,
                                            width * 0.7, base + 10)], 0.6, "flat", color="#fff6d8", blur=5,
                  opacity=0.6 * op)]

    def rays(n, r, w, op):
        pcs = [spindle(CX, CY + 10, CX + math.cos(math.radians(k * 360.0 / n)) * r,
                       CY + 10 + math.sin(math.radians(k * 360.0 / n)) * r, w) for k in range(n)]
        return F("rays", "fx_holy", pcs, 1.1, "flat", opacity=op)

    ground = lambda w, op: halo("ground", None, [C(CX, base, w, w * 0.3)], 0.3, 8, op, color="glow_holy")
    f1 = shaft(30, 0.6)
    f2 = shaft(46, 1.0) + [ground(110, 0.6)]
    f3 = shaft(50, 0.9) + [ground(140, 0.7), rays(12, 84, 7, 0.8)] + light(
        "star", "fx_holy", [SPARK(CX, CY + 10, 96)], 1.5, "glow_holy", 10)
    f4 = shaft(40, 0.5) + [ground(120, 0.4), rays(12, 70, 4, 0.45),
                           F("sparks", None, sparks(rng, 8, CX, 90, 70, 60, 6, 12), 2, "flat", color="#fff6d8")]
    f5 = [F("sparks", None, sparks(rng, 7, CX, 120, 70, 50, 4, 9), 2, "flat", color="#fff6d8", opacity=0.6)]
    return animate([f1, f2, f3, f4, f5], "fx_holy_light")


@fx("B", "fx_wind_blade", "Wind blades: pale green crescents fly from left to right with streaks, then leave curling wind lines.")
def wind_blade():
    def blade(x, y, s, op):
        return light("blade", "fx_wind", [C(x, y, s * 0.6, s), sub(C(x - s * 0.14, y, s * 0.6, s))], 1, "glow_wind", 5,
                     glow_op=0.5 * op, opacity=op)

    def streaks(x0, x1, op, ys=(70, 96, 122)):
        return F("streaks", None, [spindle(x0, y, x1, y + 2, 3) for y in ys], 0.5, "flat", color="glow_wind", opacity=op)

    def curls(op):
        pcs = []
        for (x, y, s, a) in ((120, 70, 30, 0), (150, 110, 24, 120), (100, 130, 20, 240)):
            pcs += ringp(x, y, s, s, 2) + [sub(wedge(x, y, s, a, a + 110, steps=8))]
        return F("curls", None, pcs, 0.6, "flat", color="glow_wind", opacity=op)

    f1 = blade(40, 96, 60, 0.9) + [streaks(4, 30, 0.5)]
    f2 = blade(80, 84, 76, 1.0) + blade(50, 112, 50, 0.8) + [streaks(10, 70, 0.5)]
    f3 = blade(128, 80, 84, 1.0) + blade(100, 114, 62, 0.9) + blade(64, 96, 44, 0.7) + [streaks(20, 110, 0.45)]
    f4 = blade(168, 84, 70, 0.6) + blade(146, 118, 52, 0.5) + [streaks(60, 150, 0.35), curls(0.6)]
    f5 = [streaks(110, 186, 0.25), curls(0.35)]
    return animate([f1, f2, f3, f4, f5], "fx_wind_blade")


@fx("B", "fx_line_slashes", "Line slashes: three straight cuts cross the target one after another, flash where they meet, then fade with sparks.")
def line_slashes():
    rng = random.Random(149)
    cuts = [(30, 40, 162, 152), (162, 44, 30, 148), (22, 100, 170, 92)]

    def cut(i, w, op):
        return light(f"cut{i}", "fx_white", [spindle(*cuts[i], w)], 1 + i * 0.1, "glow_steel", 5, glow_op=0.55 * op,
                     opacity=op)

    f1 = cut(0, 10, 1.0)
    f2 = cut(0, 6, 0.6) + cut(1, 10, 1.0)
    f3 = cut(0, 4, 0.45) + cut(1, 6, 0.7) + cut(2, 10, 1.0) + light(
        "flash", "fx_white", [SPARK(CX, CY, 56)], 2, "glow_steel", 8)
    f4 = cut(0, 3, 0.3) + cut(1, 3, 0.4) + cut(2, 5, 0.55) + [
        F("sparks", None, sparks(rng, 7, CX, CY, 70, 60, 6, 12), 2, "flat", color="#ffffff", opacity=0.9)]
    f5 = [F("sparks", None, sparks(rng, 5, CX, CY, 80, 70, 4, 8), 2, "flat", color="glow_steel", opacity=0.5)]
    return animate([f1, f2, f3, f4, f5], "fx_line_slashes")


# ------------------------------------------------------------------ main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--stage", default="all")
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    n = 0
    for stage, asset, note, fn in FX:
        if args.stage != "all" and stage != args.stage:
            continue
        if only and asset not in only:
            continue
        forms, frames = fn()
        save(RDIR, asset, forms, (192, 192), "fx", frames=frames, note=note,
             meta={"kind": "fx", "stage": stage, "frames": len(frames), "cell": [192, 192],
                   "sheet": f"{asset}_sheet.png (one row)", "blend": "normal (alpha); additive also works",
                   "list": "docs/art/projects/generic/catalog/g01_list.md"})
        n += 1
    print(f"wrote {n} fx recipes to {RDIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
