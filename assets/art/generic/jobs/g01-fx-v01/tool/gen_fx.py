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
