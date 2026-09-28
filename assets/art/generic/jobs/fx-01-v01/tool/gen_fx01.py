"""Write the fx-01 recipes as JSON (UTF-8, no BOM) into ../recipes.

    py -3 -B tool/gen_fx01.py            # write all 15 recipes
    py -3 -B tool/gen_fx01.py bubble     # only the named ones

Repeated geometry (bubble trains, rain fields, leaf clusters) is generated
here instead of being hand typed, so every effect gets its own layout.
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
REC = JOB / "recipes"
PAL = "palette_fx.json"

# ----------------------------------------------------------------- small helpers
def r2(v):
    return round(float(v) + 0.0, 2)


def pc(icon, at, size, **kw):
    """One piece.  ``size`` is a scalar (aspect kept) or [w, h]."""
    d = {"icon": icon, "at": [r2(at[0]), r2(at[1])]}
    if isinstance(size, (int, float)):
        d["size"] = r2(size)
    else:
        d["size"] = [r2(size[0]), r2(size[1])]
    d.update(kw)
    return d


def at_of(c, off, ang=0.0):
    """``off`` from centre ``c`` rotated by ``ang`` degrees (screen cw)."""
    if not ang:
        return [r2(c[0] + off[0]), r2(c[1] + off[1])]
    t = math.radians(ang)
    dx, dy = off
    return [r2(c[0] + dx * math.cos(t) - dy * math.sin(t)),
            r2(c[1] + dx * math.sin(t) + dy * math.cos(t))]


def fr(name, **kw):
    d = {"name": name}
    d.update(kw)
    return d


def bob(n, amp, phase=0.0, half=0.5):
    """Seamless n-frame oscillation: value[k] = amp*sin(2pi*k/n + phase), k=0..n-1."""
    out = []
    for k in range(n):
        t = 2.0 * math.pi * k / n + phase
        out.append(r2(amp * math.sin(t) * (2.0 if half == 0.5 else 1.0)))
    return out


def mvv(dx=0.0, dy=0.0, rot=0.0, sx=None, sy=None):
    m = {}
    if dx:
        m["dx"] = r2(dx)
    if dy:
        m["dy"] = r2(dy)
    if rot:
        m["rot"] = r2(rot)
    if sx is not None:
        m["sx"] = r2(sx)
    if sy is not None:
        m["sy"] = r2(sy)
    return m


def ring(cx, cy, r_out, thick, **kw):
    """A hollow disc: outer circle minus an inset circle."""
    return [pc("circle", [cx, cy], [r_out * 2, r_out * 2], **kw),
            pc("circle", [cx, cy], [(r_out - thick) * 2, (r_out - thick) * 2], op="sub")]


def recipe(asset, note, canvas, pivot, meaning, seed, forms, frames, style_over=None):
    r = {"asset": asset, "status": "candidate", "note": note, "palette": PAL,
         "style": "sprite", "canvas": canvas, "pivot": pivot,
         "pivot_meaning": meaning, "seed": seed, "forms": forms, "frames": frames}
    if style_over:
        r["style_override"] = style_over
    return r


FX_STYLE = {"cast": False, "silhouette": False}
# water is not a drawn object: no ink outline, no offset cast shadow
FX_WATER = {"cast": False, "silhouette": False, "line": False}


# ================================================================= 1. bubble
def fx_bubble():
    """A single big shell hovering in water: thick three-layer membrane, wide
    soft halo, two specular dots, three small bubbles rising through it."""
    cx, cy, R = 96.0, 100.0, 45.0
    forms = [
        {"name": "halo", "tags": ["b"], "z": 0, "kind": "mass", "material": "water_pale",
         "pivot": [cx, cy], "opacity": 0.3, "blur": 4.0, "line": False,
         "shade": {"soft": 0.8, "bump": 0.1, "threshold": 0.4, "highlight_amount": 0.0},
         "pieces": ring(cx, cy, R + 5, 15.0)},
        {"name": "shell", "tags": ["b"], "z": 1, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "opacity": 0.95,
         "shade": {"soft": 0.6, "bump": 0.3, "threshold": 0.36, "highlight_amount": 0.55},
         "glow": {"radius": 2.5, "opacity": 0.3, "color": "water_pale"},
         "pieces": ring(cx, cy, R, 6.5)},
        {"name": "film", "tags": ["b"], "z": 2, "kind": "mass", "material": "water_pale",
         "pivot": [cx, cy], "opacity": 0.14, "line": False,
         "shade": {"soft": 0.7, "bump": 0.2, "threshold": 0.4, "highlight_amount": 0.2},
         "pieces": [pc("circle", [cx, cy], [R * 2 - 13, R * 2 - 13], alpha=0.5)]},
        {"name": "rim_lo", "tags": ["b"], "z": 3, "kind": "flat", "material": "water_mid",
         "pivot": [cx, cy], "opacity": 0.95, "clip_to": "shell", "line": False,
         "pieces": [pc("circle", [cx, cy], [R * 2, R * 2]),
                    pc("circle", [cx - 7, cy - 8], [R * 2 - 3, R * 2 - 3], op="sub")]},
        {"name": "rim_hi", "tags": ["b"], "z": 4, "kind": "flat", "material": "foam",
         "pivot": [cx, cy], "clip_to": "shell", "line": False, "emit": 0.28,
         "glow": {"radius": 1.5, "opacity": 0.3, "color": "water_pale"},
         "pieces": [pc("circle", [cx, cy], [R * 2, R * 2]),
                    pc("circle", [cx + 8, cy + 9], [R * 2 - 1, R * 2 - 1], op="sub")]},
        {"name": "spec", "tags": ["b"], "z": 5, "kind": "flat", "material": "foam",
         "pivot": [cx, cy], "line": False, "emit": 0.5,
         "glow": {"radius": 3, "opacity": 0.6, "color": "foam"},
         "pieces": [pc("circle", at_of([cx, cy], (-16, -19), 0), [15, 10], rot=-32),
                    pc("circle", at_of([cx, cy], (-2, -30), 0), [8, 6], rot=-20)]},
    ]
    # three small bubbles rising through, staggered so they never jump together
    small = [(-30, 150, 12.0, "t0"), (26, 126, 9.5, "t1"), (-6, 100, 7.5, "t2")]
    for dx, y0, rad, tag in small:
        forms.append({"name": "rise_" + tag, "tags": [tag], "z": 2, "kind": "mass",
                      "material": "bubble_shell", "pivot": [cx + dx, y0], "opacity": 0.8,
                      "line": {"width": 0.7, "heavy": 0.5},
                      "glow": {"radius": 2.5, "opacity": 0.4, "color": "water_pale"},
                      "pieces": ring(cx + dx, y0, rad, rad * 0.32)})
    frames = []
    dy = bob(6, 9.0)
    sc = [r2(1.0 + 0.035 * (d / 9.0)) for d in dy]
    for k in range(6):
        mv = {"b": mvv(dx=bob(6, 3.0, math.pi / 2)[k], dy=dy[k], sx=sc[k], sy=sc[k])}
        for j, (_dx, _y0, _rad, tag) in enumerate(small):
            mv[tag] = mvv(dy=-21.0 * k, dx=round(2.5 * math.sin(1.7 * k + j), 2))
        frames.append(fr(f"f{k}", move=mv))
    return recipe("bubble",
                  "bubble (floating shell). One large three-layer membrane (halo, shell ring, "
                  "inner film) with a dark bottom rim and a bright top-left rim, two specular dots, "
                  "and three smaller bubbles rising through it and wrapping at the loop point. "
                  "Hover motion only: the shell bobs and swells, it does not travel.",
                  [192, 192], [cx, cy], "centre of the shell, mid water", 301, forms, frames, FX_WATER)


# ================================================================= 2. bubble_column_up
def fx_bubble_column_up():
    """A narrow vertical column of many bubbles in three sub-streams, rising.
    The pattern is tiled twice (0 and -384) so it wraps exactly once per loop."""
    W, H = 384, 384
    rng = random.Random(4402)
    streams = [(192.0, 14.0, 11.0, 50.0), (152.0, 11.0, 8.0, 58.0), (232.0, 10.0, 7.5, 62.0)]
    blobs = []
    for x, rmin, rmax, step in streams:
        y = 14.0
        while y < H + 80:
            rad = rng.uniform(rmin, rmax)
            blobs.append((x + rng.uniform(-13, 13), y + rng.uniform(-9, 9), rad, rng.random()))
            y += rng.uniform(step * 0.75, step * 1.5)
    for i in range(4):  # wide slugs that briefly block the column
        blobs.append((192 + rng.uniform(-24, 24), 30 + i * 118 + rng.uniform(-20, 20),
                      rng.uniform(28, 38), 1.0))
    blobs.sort(key=lambda b: b[1])

    def blob_pieces(b, dy):
        x, y, rad, roll = b
        y -= dy
        if roll < 0.24:
            return [pc("droplet", [x, y], [rad * 1.4, rad * 2.0], rot=180)]
        out = ring(x, y, rad, max(2.2, rad * 0.3))
        if roll > 0.74:
            out.append(pc("circle", [x - rad * 0.34, y - rad * 0.4], [rad * 0.3, rad * 0.22], rot=-30))
        return out

    forms = [
        {"name": "column_wash", "tags": ["col"], "z": 0, "kind": "mass", "material": "water_mid",
         "pivot": [192, 192], "opacity": 0.3, "blur": 14.0, "line": False,
         "shade": {"soft": 0.8, "bump": 0.1, "threshold": 0.4, "highlight_amount": 0.0},
         "pieces": [pc("circle", [192, 192 - d * H], [120, 500]) for d in (-1, 0, 1)]},
        {"name": "column_sheen", "tags": ["col"], "z": 0.5, "kind": "flat", "material": "water_pale",
         "pivot": [192, 192], "opacity": 0.22, "blur": 6.0, "clip_to": "column_wash", "line": False,
         "pieces": [pc("circle", [172, 192 - d * H], [40, 460]) for d in (-1, 0, 1)]},
    ]
    for idx, dy in enumerate((0, -H)):
        pieces = []
        for b in blobs:
            pieces.extend(blob_pieces(b, dy))
        forms.append({"name": f"column{idx}", "tags": ["col"], "z": 1 + idx * 0.01,
                      "kind": "mass", "material": "bubble_shell", "pivot": [192, 192],
                      "opacity": 0.85, "line": False,
                      "shade": {"soft": 0.55, "bump": 0.4, "threshold": 0.4, "highlight_amount": 0.5},
                      "glow": {"radius": 1.5, "opacity": 0.22, "color": "water_pale"},
                      "pieces": pieces})
    frames = [fr(f"f{k}", move={"col": mvv(dy=-64.0 * k)}) for k in range(6)]
    return recipe("bubble_column_up",
                  "bubble_column_up (rising bubble column). Three sub-streams of ring bubbles plus "
                  "wide slugs, inside a soft water column with a bright sheen on the left. The whole "
                  "pattern is tiled at y and y-384 and slides up 64 px per frame, so one loop is "
                  "exactly one tile height and the wrap is invisible.",
                  [W, H], [192, 192], "centre of the column in the water", 302, forms, frames, FX_WATER)


# ================================================================= 3. current_down
def fx_current_down():
    """A bounded downward channel: soft water body, a darker core, wide foam
    crests that travel down, vertical streaks, fast droplets, and slow eddies."""
    W, H = 384, 384
    rng = random.Random(4403)

    crests = []
    y = 4.0
    while y < H + 70:
        crests.append((192 + rng.uniform(-26, 26), y, rng.uniform(70, 130), rng.uniform(16, 26)))
        y += rng.uniform(40, 74)
    flecks = [(192 + rng.uniform(-74, 74), rng.uniform(0, H + 40),
               rng.uniform(70, 132), rng.uniform(13, 22)) for _ in range(16)]
    streaks = [(192 + rng.uniform(-82, 82), rng.uniform(6, H + 40),
                rng.uniform(2.2, 4.4), rng.uniform(30, 74)) for _ in range(30)]
    drops = [(192 + rng.uniform(-62, 62), rng.uniform(6, H + 40), rng.uniform(6, 10)) for _ in range(8)]

    def rows(width, step, h, sq, off):
        out = []
        for k in range(-1, int(H / step) + 2):
            out.append(pc("wave", [192 + rng.uniform(-8, 8), off + k * step], [width, h],
                          squash=sq, rot=rng.uniform(-4, 4)))
        return out

    def flow(off):
        p = []
        for x, cy, w, h in crests:
            p += arc("ring", [x, cy - off], [w, h], [1.5, 0, 15.5, 8.5],
                     rot=rng.uniform(-8, 8), thin=0.45)
        for x, y, w, h in flecks:
            p.append(pc("wave", [x, y - off], [w, h], squash=0.5, rot=rng.uniform(-5, 5)))
        for x, y, w, h in streaks:
            p.append(pc("circle", [x, y - off], [w, h]))
        for x, y, w in drops:
            p.append(pc("droplet", [x, y - off], [w, w * 3.4]))
        return p

    forms = [
        {"name": "body", "tags": ["flow"], "z": 0, "kind": "mass", "material": "water_mid",
         "pivot": [192, 192], "opacity": 0.34, "blur": 10.0, "line": False,
         "shade": {"soft": 0.8, "bump": 0.1, "threshold": 0.4, "highlight_amount": 0.0},
         "pieces": rows(200, 44, 74, 0.5, 0.0)},
        {"name": "flow_a", "tags": ["flow"], "z": 1, "kind": "mass", "material": "water_pale",
         "pivot": [192, 192], "opacity": 0.34, "line": False,
         "shade": {"soft": 0.5, "bump": 0.6, "threshold": 0.45, "highlight_amount": 0.3},
         "pieces": flow(0.0)},
        {"name": "flow_b", "tags": ["flow"], "z": 1.01, "kind": "mass", "material": "water_pale",
         "pivot": [192, 192], "opacity": 0.3, "line": False,
         "shade": {"soft": 0.5, "bump": 0.6, "threshold": 0.45, "highlight_amount": 0.3},
         "pieces": flow(-H)},
    ]
    # eddies: a 192 px tile so they can turn at half speed and still loop
    eddies = [(170, 46, 42, 36), (216, 122, 34, 30), (180, 194, 38, 32)]
    forms.append({"name": "eddies", "tags": ["eddy"], "z": 3, "kind": "mass", "material": "water_pale",
                  "pivot": [192, 192], "opacity": 0.3, "line": False,
                  "pieces": [pc("spiral", [x, y - d * 192], [w, h], rot=(-1) ** d * 20)
                             for x, y, w, h in eddies for d in (-1, 0, 1)]})
    frames = []
    for k in range(6):
        frames.append(fr(f"f{k}", move={"flow": mvv(dy=64.0 * k), "eddy": mvv(dy=32.0 * k)}))
    return recipe("current_down",
                  "current_down (downward channel). A bounded soft channel built from 10 overlapping "
                  "blurred wave rows plus a darker core, then thin curved crest lines cut from the ring "
                  "icon, thin vertical streaks and stretched droplets - all sliding DOWN 64 px per frame "
                  "out of a pattern tiled at y and y-384. Three lasso eddies sit on a 192 px tile and "
                  "turn at half speed, so the channel reads as moving water, not a barcode: unlike the "
                  "rain cell it has strong horizontal elements everywhere.",
                  [W, H], [192, 192], "centre of the channel", 303, forms, frames, FX_WATER)


# ================================================================= 4. dolphin
def arc(icon, at, size, crop, rot=0.0, thin=0.72, flip=""):
    """A thin band cut out of the ring icon: the arc minus a shrunken copy."""
    return [pc(icon, at, size, crop=crop, rot=rot, flip=flip),
            pc(icon, at, [size[0] * thin, size[1] * thin], crop=crop, rot=rot, flip=flip, op="sub")]


def fish(cx, cy, length, tilt=0.0, tags=(), z=2, mat="water_pale", squash=0.6,
         tail_tag=None, eye=True):
    """One side-view fish: cropped body + its own tail icon + dorsal + pectoral,
    and a dark belly drawn ON TOP as a second form (a sub piece would cut a hole)."""
    lb, lt = length * 0.74, length * 0.3
    bx = cx + length * 0.1
    joint = at_of([bx, cy], (-lb * 0.5, 0))
    body = {"name": f"b{abs(hash((cx, cy, length))) % 9999}", "tags": list(tags), "z": z + 0.02,
            "kind": "mass", "material": mat, "pivot": [cx, cy], "line": {"width": 0.8, "heavy": 0.7},
            "shade": {"soft": 0.34, "bump": 0.8, "threshold": 0.48, "highlight_amount": 0.45},
            "pieces": [
                pc("fish", [bx, cy], [lb, lb * 0.66], rot=tilt, squash=squash, crop=[3.4, 2.4, 15.6, 13.6]),
                pc("triangle", at_of([bx, cy], (-lb * 0.02, -lb * 0.30), tilt),
                   [lb * 0.3, lb * 0.26], rot=tilt + 4, squash=squash),
                pc("triangle", at_of([bx, cy], (-lb * 0.10, lb * 0.26), tilt),
                   [lb * 0.22, lb * 0.2], rot=tilt - 118, squash=squash),
            ]}
    belly = {"name": f"y{abs(hash((cx, cy, length))) % 9999}", "tags": list(tags), "z": z + 0.03,
             "kind": "flat", "material": "water_deep", "pivot": [cx, cy], "opacity": 0.7,
             "line": False,
             "pieces": [pc("fish", at_of([bx, cy], (0, lb * 0.13), tilt), [lb * 0.9, lb * 0.56],
                           rot=tilt, squash=squash, crop=[3.4, 9.8, 15.6, 13.6])]}
    tail = {"name": f"t{abs(hash((cx, cy, length))) % 9999}", "tags": list(tags) + ([tail_tag] if tail_tag else []),
            "z": z - 0.01, "kind": "mass", "material": mat, "pivot": joint,
            "line": {"width": 0.8, "heavy": 0.7},
            "shade": {"soft": 0.34, "bump": 0.8, "threshold": 0.48, "highlight_amount": 0.4},
            "pieces": [pc("fish", joint, [lt, lt * 1.3], rot=tilt, squash=squash,
                          crop=[0.1, 2.6, 4.4, 13.4])]}
    forms = [belly, body, tail]
    if eye:
        body["pieces"].append(pc("circle", at_of([bx, cy], (lb * 0.28, -lb * 0.05), tilt),
                                 [7, 6], rot=tilt, squash=squash))
    return forms, tail


def fx_dolphin():
    """A school of seven fish of graded size in a loose V, swimming on the spot:
    tails wag, bodies undulate, ripple bands scroll behind them."""
    W, H = 384, 384
    school = [(322, 200, 122, -2), (256, 150, 100, -7), (242, 258, 88, 8),
              (182, 112, 76, -12), (166, 286, 68, 13), (112, 176, 78, 6), (74, 254, 58, 15)]
    forms, tails = [], []
    for i, (x, y, L, tilt) in enumerate(school):
        mat = "water_pale" if i % 3 else "bubble_shell"
        parts, tail = fish(x, y, L, tilt, tags=["sw"], z=2 + i * 0.01, mat=mat,
                           squash=0.58, tail_tag=f"t{i}")
        forms.extend(parts)
        tails.append(f"t{i}")
    forms.append({"name": "ripples", "tags": ["rip"], "z": 1, "kind": "mass", "material": "foam",
                  "pivot": [192, 192], "opacity": 0.4, "line": False,
                  "shade": {"soft": 0.6, "bump": 0.4, "threshold": 0.44, "highlight_amount": 0.3},
                  "pieces": [pc("sea", [192, 202], [344, 42], squash=0.6),
                            pc("wave", [196, 116], [322, 28], squash=0.5),
                            pc("wave", [188, 288], [306, 26], squash=0.5),
                            pc("wave", [200, 148], [250, 22], squash=0.5),
                            pc("wave", [184, 258], [262, 22], squash=0.5)]})
    frames = []
    dx, dy = bob(6, 7.0), bob(6, 5.0, math.pi / 3)
    wag = [0, 15, 19, 0, -15, -19]
    for k in range(6):
        mv = {"sw": mvv(dx=dx[k], dy=dy[k]),
              "rip": mvv(dx=-64.0 * k, dy=bob(6, 4.0, 1.0)[k])}
        for i, t in enumerate(tails):
            mv[t] = mvv(rot=wag[k] * (1 if i % 2 == 0 else -1))
        frames.append(fr(f"f{k}", move=mv))
    return recipe("dolphin",
                  "dolphin (school of fish). Seven fish of graded size in a loose V, every one built "
                  "from the fish icon: cropped body, its own tail icon on a joint pivot, dorsal and "
                  "pectoral triangles, a dark belly bite and a small eye. The school holds position and "
                  "swims: tails wag out of phase, the whole group bobs, and three wide ripple bands "
                  "scroll left 64 px per frame out of a pattern tiled at x and x-384.",
                  [W, H], [192, 192], "centre of the school on the water", 304, forms, frames, FX_STYLE)


# ================================================================= 5. bubble_pop
def fx_bubble_pop():
    """A burst, not a shell: intact membrane, stretched film, broken arcs,
    flying shards, a central flash, and an expanding surface ring."""
    cx, cy = 96.0, 92.0
    forms = [
        {"name": "mem_o", "tags": ["mo"], "z": 2, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "line": {"width": 0.8, "heavy": 0.6, "breaks": 0.4},
         "glow": {"radius": 3, "opacity": 0.45, "color": "water_pale"},
         "pieces": ring(cx, cy, 33.0, 7.5)},
        {"name": "mem_i", "tags": ["mi"], "z": 2.1, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "opacity": 0.8,
         "shade": {"soft": 0.6, "bump": 0.3, "threshold": 0.36, "highlight_amount": 0.6},
         "pieces": ring(cx, cy, 30.0, 2.6)},
        {"name": "mem_glow", "tags": ["mg"], "z": 1, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "opacity": 0.28, "blur": 3.0, "line": False,
         "pieces": [pc("circle", [cx, cy], [86, 86]),
                    pc("circle", [cx, cy], [64, 64], op="sub")]},
        {"name": "arcs", "tags": ["ar"], "z": 3, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "line": False,
         "glow": {"radius": 2.5, "opacity": 0.4, "color": "foam"},
         "pieces": arc("ring", [cx, cy - 20], [70, 36], [1.5, 0, 15.5, 8.5], rot=-4) +
                   arc("ring", [cx, cy + 19], [66, 34], [1.5, 8, 15.5, 16], rot=3) +
                   arc("ring", [cx + 25, cy], [32, 58], [8, 1.5, 16, 14.5], rot=8) +
                   arc("ring", [cx - 28, cy + 2], [28, 46], [0, 2, 6, 14], rot=-10)},
        {"name": "shards", "tags": ["sh"], "z": 4, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, cy], "line": False,
         "pieces": [pc("triangle", at_of([cx, cy], (-50, -36), -18), [21, 15], rot=-40),
                    pc("droplet", at_of([cx, cy], (-14, -58), 0), [14, 21], rot=170),
                    pc("triangle", at_of([cx, cy], (46, -42), 22), [18, 14], rot=52),
                    pc("droplet", at_of([cx, cy], (60, -6), 0), [13, 19], rot=96),
                    pc("triangle", at_of([cx, cy], (38, 42), -30), [22, 16], rot=140),
                    pc("droplet", at_of([cx, cy], (-8, 60), 0), [14, 21], rot=6),
                    pc("triangle", at_of([cx, cy], (-58, 16), 12), [17, 13], rot=-128),
                    pc("droplet", at_of([cx, cy], (-32, 52), 0), [12, 17], rot=30),
                    pc("circle", at_of([cx, cy], (26, -66), 0), [9, 8]),
                    pc("circle", at_of([cx, cy], (-66, -14), 0), [8, 7])]},
        {"name": "flash", "tags": ["fl"], "z": 5, "kind": "flat", "material": "foam",
         "pivot": [cx, cy], "line": False, "emit": 1.0,
         "glow": {"radius": 7, "opacity": 0.75, "color": "water_pale"},
         "pieces": [pc("circle", [cx, cy], [17, 17])] +
                   [pc("droplet", at_of([cx, cy], (0, 26), a), [5, 22], rot=180)
                    for a in (0, 60, 120, 180, 240, 300)] +
                   [pc("circle", at_of([cx, cy], (0, 38), 0), [5, 5])]},
        {"name": "ripple", "tags": ["rp"], "z": 1.5, "kind": "mass", "material": "water_pale",
         "pivot": [cx, cy], "opacity": 0.55, "line": False,
         "pieces": ring(cx, cy, 44.0, 3.5)},
    ]
    frames = [
        fr("f0", show=["mem_o", "mem_i", "mem_glow"]),
        fr("f1", show=["mem_o", "mem_i", "mem_glow", "flash"],
           move={"mo": mvv(sx=1.95, sy=1.7), "mi": mvv(sx=1.25, sy=1.15),
                 "mg": mvv(sx=1.5, sy=1.35), "fl": mvv(sx=0.9, sy=0.9)}),
        fr("f2", show=["mem_i", "mem_glow", "arcs", "flash", "ripple"],
           move={"mi": mvv(sx=1.7, sy=1.5), "mg": mvv(sx=2.1, sy=1.9),
                 "fl": mvv(sx=0.62, sy=0.62), "rp": mvv(sx=1.35, sy=0.5)}),
        fr("f3", show=["arcs", "shards", "flash", "ripple"],
           move={"ar": mvv(sx=1.25, sy=1.2, rot=13), "sh": mvv(dx=12, dy=10),
                 "fl": mvv(sx=0.34, sy=0.34), "rp": mvv(sx=1.75, sy=0.45)}),
        fr("f4", show=["arcs", "shards", "ripple"],
           move={"ar": mvv(sx=1.5, sy=1.4, rot=26), "sh": mvv(dx=26, dy=22),
                 "rp": mvv(sx=2.05, sy=0.4)}),
    ]
    return recipe("bubble_pop",
                  "bubble_pop (burst). Five stages, none of them a hovering shell: an intact "
                  "three-part membrane, a membrane blown out to 1.9x, four thinned ring sectors left "
                  "as arcs, ten shards thrown out, a hot core with six radial rays in the middle and a "
                  "flattened surface ring expanding under it. The main image never shows the whole "
                  "bubble again after f1.",
                  [192, 192], [cx, cy], "point of the burst, mid water", 305, forms, frames, FX_WATER)


# ================================================================= 6. fishing
def fx_fishing():
    """A single hooked fish: line and hook from above, one big fish, a surface
    dimple that widens, and water flicked off the fish on two frames."""
    fx, fy = 98.0, 112.0
    parts, tail = fish(fx, fy, 116, -6, tags=["f"], z=3, mat="water_pale", squash=0.62, tail_tag="tl")
    parts[2]["pieces"].append(pc("circle", at_of([fx + 11.6, fy], (24.1, -4.3), -6), [10, 8],
                                 rot=-6, squash=0.62, op="sub"))
    forms = [
        {"name": "dimple", "tags": ["dm"], "z": 1, "kind": "mass", "material": "water_pale",
         "pivot": [96, 74], "opacity": 0.5, "line": False,
         "pieces": [pc("circle", [96, 74], [82, 28]),
                    pc("circle", [96, 74], [64, 22], op="sub"),
                    pc("circle", [96, 74], [82, 28], op="sub")]},
        {"name": "dimple_wide", "tags": ["dm"], "z": 1.1, "kind": "flat", "material": "water_mid",
         "pivot": [96, 74], "opacity": 0.55, "clip_to": "dimple", "line": False,
         "pieces": [pc("circle", [96, 70], [84, 32])]},
        {"name": "line", "tags": ["ln"], "z": 2, "kind": "flat", "material": "foam",
         "pivot": [96, 10], "opacity": 0.85, "line": False,
         "pieces": [pc("circle", [96, 44], [2.8, 74])]},
        {"name": "hook", "tags": ["hk"], "z": 4.5, "kind": "mass", "material": "bubble_shell",
         "pivot": [96, 84], "line": {"width": 0.8, "heavy": 0.6},
         "pieces": [pc("hook", [96, 84], [22, 26], rot=180)]},
    ]
    forms.extend(parts)
    forms.append(tail)
    forms.append({"name": "flick", "tags": ["fk"], "z": 5, "kind": "mass", "material": "foam",
                  "pivot": [fx, fy - 20], "line": {"width": 0.6, "heavy": 0.4},
                  "pieces": [pc("droplet", [fx - 44, fy - 46], [12, 18], rot=146),
                             pc("droplet", [fx - 8, fy - 62], [11, 17], rot=172),
                             pc("droplet", [fx + 40, fy - 40], [12, 18], rot=204),
                             pc("circle", [fx - 56, fy - 18], [7, 6])]})
    frames = []
    ry, rdx = bob(6, 13.0), bob(6, 5.0, math.pi / 2)
    wag = [0, 18, 22, 0, -18, -22]
    for k in range(6):
        mv = {"f": mvv(dy=ry[k], dx=rdx[k], rot=ry[k] * 0.7),
              "tl": mvv(dy=ry[k], dx=rdx[k], rot=wag[k]),
              "ln": mvv(rot=ry[k] * 0.32),
              "hk": mvv(rot=ry[k] * 0.32),
              "dm": mvv(sx=1.0 + 0.13 * k, sy=1.0 + 0.05 * k)}
        if k >= 2:
            mv["fk"] = mvv(dx=4.0 * (k - 2), dy=-9.0 * (k - 2), sx=1.0 + 0.22 * (k - 2),
                           sy=1.0 + 0.22 * (k - 2))
        frames.append(fr(f"f{k}", show=(["flick"] if k >= 2 else []), move=mv))
    return recipe("fishing",
                  "fishing (hooked fish). One large fish built from the fish icon, a thin line and hook "
                  "coming down from the top of the cell, and a flattened surface dimple that widens every "
                  "frame. The fish tugs on a 6-frame loop (body roll, tail wag, bending line) and water "
                  "is flicked off it on the last four frames.",
                  [192, 192], [96, 176], "the water surface the line comes from", 306, forms, frames, FX_WATER)


# ================================================================= 7. rain
def fx_rain():
    """Vertical falling rain in two depths: a far field of short thin streaks and
    a near field of long blurred ones, both tilted the same way, plus splash dots."""
    W, H = 384, 384
    rng = random.Random(4407)
    # even columns so no side of the cell is empty, jittered so it is not a grid
    cols, cstep, rstep = 7, 42.0, 70.0
    far = []
    for i in range(cols):
        for j in range(-1, 7):
            far.append((66 + i * cstep + (rstep * 0.5 if i % 2 else 0.0) + rng.uniform(-7, 7),
                        j * rstep + rng.uniform(-12, 12),
                        rng.uniform(3.0, 4.6), rng.uniform(30, 52)))
    near = []
    for i in range(0, cols, 3):
        for j in range(-1, 4):
            near.append((70 + i * cstep + rng.uniform(-14, 14), j * 150 + rng.uniform(-18, 18),
                         rng.uniform(5.0, 8.0), rng.uniform(84, 128)))
    dots = [(rng.uniform(50, W - 50), rng.uniform(30, H - 20)) for _ in range(4)]

    def streak(sy, skew):
        return [pc("droplet", [x, y - sy], [w, h], skew=[skew, 0.0]) for x, y, w, h in far]

    def streak_n(sy, skew):
        return [pc("droplet", [x, y - sy], [w, h], skew=[skew, 0.0]) for x, y, w, h in near]

    forms = [
        {"name": "rain_far", "tags": ["rf"], "z": 1, "kind": "mass", "material": "water_pale",
         "pivot": [192, 192], "opacity": 0.5, "line": False,
         "shade": {"soft": 0.5, "bump": 0.4, "threshold": 0.42, "highlight_amount": 0.35},
         "pieces": streak(0.0, 9.0) + streak(-H, 9.0)},
        {"name": "rain_near", "tags": ["rn"], "z": 2, "kind": "mass", "material": "foam",
         "pivot": [192, 192], "opacity": 0.42, "blur": 1.1, "line": False,
         "shade": {"soft": 0.6, "bump": 0.3, "threshold": 0.4, "highlight_amount": 0.3},
         "pieces": streak_n(0.0, 13.0) + streak_n(-H, 13.0)},
        {"name": "splashes", "tags": ["sp"], "z": 3, "kind": "mass", "material": "foam",
         "pivot": [192, 192], "opacity": 0.5, "line": {"width": 0.6, "heavy": 0.4},
         "pieces": [pc("circle", [x, y], [22, 7]) for x, y in dots[:2]]},
    ]
    frames = []
    for k in range(6):
        mv = {"rf": mvv(dy=64.0 * k), "rn": mvv(dy=64.0 * k)}
        if k in (1, 4):
            mv["sp"] = mvv(sx=1.0, sy=1.0)
        frames.append(fr(f"f{k}", show=(["splashes"] if k in (1, 4) else []), move=mv))
    return recipe("rain",
                  "rain (falling streaks). 72 tilted vertical streaks in two depths: a far field on a "
                  "staggered 40x70 grid of short thin ones and a near field of long blurred ones, all "
                  "leaning the same way, tiled at y and y-384 and sliding down 64 px per frame. "
                  "Flattened splash dots appear on two frames of the loop. No horizontal element "
                  "anywhere, so it cannot be confused with the current channel.",
                  [W, H], [192, 192], "centre of the rain cell", 307, forms, frames, FX_WATER)


# ================================================================= 8. splash
def fx_splash():
    """An upward crown: a low mound, a U bowl, two curved arms, a centre column
    and four droplets flung out, growing then breaking apart."""
    cx, base = 96.0, 170.0
    forms = [
        {"name": "ridge", "tags": ["rg"], "z": 1, "kind": "mass", "material": "water_pale",
         "pivot": [cx, base], "opacity": 0.85, "line": False,
         "shade": {"soft": 0.5, "bump": 0.6, "threshold": 0.44, "highlight_amount": 0.45},
         "pieces": [pc("wave", [cx, base], [118, 52], squash=0.55)]},
        {"name": "bowl", "tags": ["bw"], "z": 2, "kind": "mass", "material": "water_pale",
         "pivot": [cx, base - 20], "line": False, "opacity": 0.9,
         "shade": {"soft": 0.5, "bump": 0.6, "threshold": 0.44, "highlight_amount": 0.5},
         "pieces": [pc("ring", [cx, base - 16], [100, 54], crop=[2.4, 9.0, 13.6, 16])]},
        {"name": "rim", "tags": ["bw"], "z": 2.05, "kind": "flat", "material": "foam",
         "pivot": [cx, base - 20], "opacity": 0.6, "clip_to": "bowl", "line": False,
         "pieces": [pc("ring", [cx, base - 16], [100, 54], crop=[2.4, 9.0, 13.6, 16]),
                    pc("ring", [cx + 5, base - 21], [100, 54], crop=[2.4, 9.0, 13.6, 16], op="sub")]},
        {"name": "tongues", "tags": ["tg"], "z": 3, "kind": "mass", "material": "water_pale",
         "pivot": [cx, base - 40], "line": False,
         "shade": {"soft": 0.5, "bump": 0.55, "threshold": 0.42, "highlight_amount": 0.5},
         "glow": {"radius": 3, "opacity": 0.3, "color": "water_pale"},
         "pieces": [
             pc("droplet", [cx - 30, base - 58], [19, 70], rot=200),
             pc("droplet", [cx + 30, base - 58], [19, 70], rot=160),
             pc("droplet", [cx - 48, base - 38], [17, 52], rot=222),
             pc("droplet", [cx + 48, base - 38], [17, 52], rot=138),
             pc("droplet", [cx, base - 66], [18, 78], rot=180)]},
        {"name": "spikes", "tags": ["sp"], "z": 3.5, "kind": "mass", "material": "foam",
         "pivot": [cx, base - 40], "line": False,
         "shade": {"soft": 0.55, "bump": 0.5, "threshold": 0.42, "highlight_amount": 0.5},
         "pieces": [pc("droplet", [cx - 14, base - 70], [10, 44], rot=192),
                    pc("droplet", [cx + 15, base - 76], [9, 38], rot=168),
                    pc("droplet", [cx, base - 92], [8, 32], rot=180)]},
        {"name": "drops", "tags": ["dp"], "z": 4, "kind": "mass", "material": "bubble_shell",
         "pivot": [cx, base - 60], "line": False,
         "pieces": [pc("droplet", [cx - 62, base - 88], [13, 20], rot=150),
                    pc("droplet", [cx - 30, base - 116], [11, 18], rot=170),
                    pc("droplet", [cx + 32, base - 112], [12, 19], rot=190),
                    pc("droplet", [cx + 64, base - 84], [13, 20], rot=212),
                    pc("circle", [cx - 2, base - 136], [8, 7])]},
    ]
    frames = [
        fr("f0", show=["ridge"], move={"rg": mvv(sx=0.78, sy=0.7)}),
        fr("f1", show=["ridge", "bowl", "tongues"],
           move={"rg": mvv(sx=1.05, sy=0.95), "bw": mvv(sx=0.86, sy=0.5), "tg": mvv(sy=0.45)}),
        fr("f2", show=["bowl", "tongues", "spikes", "drops"],
           move={"bw": mvv(sx=1.0, sy=0.9), "tg": mvv(sy=0.9), "sp": mvv(sy=0.9),
                 "dp": mvv(sx=0.7, sy=0.7)}),
        fr("f3", show=["bowl", "tongues", "spikes", "drops"],
           move={"bw": mvv(sx=1.1, sy=1.1), "tg": mvv(sy=1.06, dx=-4),
                 "sp": mvv(sy=1.12), "dp": mvv(sx=1.0, sy=1.0, dx=5, dy=-7)}),
        fr("f4", show=["bowl", "tongues", "drops"],
           move={"bw": mvv(sx=1.18, sy=1.2), "tg": mvv(sy=1.16, dx=-8),
                 "dp": mvv(sx=1.25, sy=1.2, dx=10, dy=-14)}),
    ]
    return recipe("splash",
                  "splash (crown of water). A low wavy ridge at the surface, a shallow U cup cut from the "
                  "lower half of the ring icon with a lit inner rim, five narrow tapered droplet tongues "
                  "fanning outward, three thin foam spikes between them, and five thrown droplets. Five "
                  "frames: the cup rises and widens, the tongues swing out, the spikes drop out of the "
                  "last frame and the droplets carry on alone.",
                  [192, 192], [cx, base], "the water surface the splash leaves", 308, forms, frames, FX_WATER)


# ================================================================= 9-13. leaves
def leaf_forms(spec):
    """spec: list of dicts x, y, size, rot, tag, kind pieces."""
    forms = []
    for i, s in enumerate(spec):
        tag = s["tag"]
        forms.append({"name": f"leaf{i}", "tags": [tag], "z": 2 + i * 0.01, "kind": "mass",
                      "material": s["mat"], "pivot": [s["x"], s["y"]],
                      "shade": {"soft": 0.32, "bump": 0.85, "threshold": 0.5,
                                "highlight_amount": 0.4},
                      "pieces": s["pieces"]})
        for extra in s.get("extra", []):
            extra["tags"] = [tag]
            forms.append(extra)
    return forms


def leaf_frames(n, per_leaf):
    """per_leaf: list of (rot_step, dy_amp, dy_phase, dx_amp, dx_phase, sx_amp)."""
    frames = []
    for k in range(n):
        mv = {}
        for tag, (rs, dya, dyp, dxa, dxp, sxa) in per_leaf.items():
            mv[tag] = mvv(rot=rs * k, dy=dya * math.sin(2 * math.pi * k / n + dyp),
                          dx=dxa * math.sin(2 * math.pi * k / n + dxp),
                          sx=1.0 + sxa * math.sin(2 * math.pi * k / n + dyp),
                          sy=1.0 + sxa * math.sin(2 * math.pi * k / n + dyp))
        frames.append(fr(f"f{k}", move=mv))
    return frames


def stem(x, y, ln, w, deg):
    """A petiole leaving the leaf centre in direction ``deg`` degrees."""
    return pc("circle", at_of([x, y], (0, ln * 0.5), deg - 90), [ln, w], rot=deg)


def fx_pale_oak():
    """Ash-grey oak: broad lobed leaves, big, slow, spread wide, tumbling once
    per loop with a long lateral drift."""
    rng = random.Random(4409)
    spec = []
    spots = [(62, 56, 52, 226), (130, 48, 44, 250), (92, 96, 54, 40), (58, 136, 46, 205),
             (136, 126, 42, 268), (96, 150, 40, 218)]
    for i, (x, y, s, rot) in enumerate(spots):
        t = f"l{i}"
        # the leaf icon is a broad pointed oval with a hollow slot along the 45 deg axis:
        # a bar on that same axis fills the slot, so the blade reads solid
        p = [pc("leaf", [x, y], [s * 0.9, s], rot=rot),
             pc("circle", [x, y], [s * 0.9, s * 0.2], rot=rot + 45),
             stem(x, y, s * 0.66, s * 0.08, rot + 225)]
        vein = {"name": f"vein{i}", "z": 2.6 + i * 0.01, "kind": "flat", "material": "water_deep",
                "pivot": [x, y], "tags": [t], "opacity": 0.45, "line": False,
                "pieces": [pc("circle", [x, y], [s * 0.8, s * 0.05], rot=rot + 45)]}
        spec.append({"x": x, "y": y, "tag": t, "mat": "leaf_pale_oak", "pieces": p,
                     "extra": [vein]})
    per = {}
    for i in range(len(spots)):
        per[f"l{i}"] = (60.0 if i % 2 == 0 else -60.0, 7.0, 0.7 * i, 10.0, 0.4 * i + 1.0, 0.03)
    return recipe("pale_oak_leaves",
                  "pale_oak_leaves (ash-grey oak). Six leaves, each the leaf icon's broad pointed-oval "
                  "blade with its hollow midrib filled by a bar on the same axis and a darker vein "
                  "drawn on top, plus the longest petiole of the five. They tumble a full turn per "
                  "6-frame loop (60 deg/frame) and drift sideways on long sines, so the cluster "
                  "ripples sideways. Greyest and slowest.",
                  [192, 192], [96, 96], "centre of the drifting cluster", 309,
                  leaf_forms(spec), leaf_frames(6, per), FX_STYLE)


def fx_cherry():
    """Cherry petals: tiny notched teardrops, many of them, fluttering fast with
    a hard side-to-side wobble instead of a steady tumble."""
    rng = random.Random(4410)
    spec = []
    for i in range(9):
        x = 96 + rng.uniform(-64, 64)
        y = 34 + i * 15 + rng.uniform(-7, 7)
        s = rng.uniform(19, 26)
        rot = rng.uniform(0, 360)
        p = [pc("droplet", [x, y], [s * 0.86, s], rot=rot, flip="y", skew=[rng.uniform(-14, 14), 0],
                minus_icons=[{"icon": "circle", "box": [6.2, 0, 9.8, 3.0]}])]
        spec.append({"x": x, "y": y, "tag": f"p{i}", "mat": "leaf_cherry", "pieces": p})
    per = {}
    for i in range(9):
        ph = i * 0.62
        per[f"p{i}"] = (0.0, 7.0, ph, 14.0, ph + 0.5, 0.10)
    return recipe("cherry_leaves",
                  "cherry_leaves (blossom petals). Nine small petals, each an upside-down droplet with "
                  "a notch bitten out of the rounded tip and a random skew, so no two point the same "
                  "way. They do not tumble steadily: the rotation swings through zero and back "
                  "every frame while the petals jump 17 px sideways, a fast flutter. Smallest, "
                  "pinkest and the only one with no stem.",
                  [192, 192], [96, 96], "centre of the drifting cluster", 310,
                  leaf_forms(spec), leaf_frames(6, per), FX_STYLE)


def fx_yellow_poplar():
    """Yellow poplar: plain ovate-triangle leaves with a long stem, tilted to
    hang point-down, a medium steady tumble."""
    spec = []
    for i in range(6):
        x = 96 + [-48, 18, -28, 50, -6, 34][i]
        y = 42 + i * 19
        s = [36, 42, 34, 40, 35, 38][i]
        rot = [34, 196, 22, 210, 44, 200][i]
        t = f"y{i}"
        p = [pc("triangle", [x, y], [s * 0.9, s], rot=rot, crop=[2.2, 0, 13.8, 15]),
             stem(x, y, s * 0.66, s * 0.1, rot + 90)]
        spec.append({"x": x, "y": y, "tag": t, "mat": "leaf_yellow_poplar", "pieces": p})
    per = {}
    for i in range(6):
        per[f"y{i}"] = (60.0 if i % 2 == 0 else -60.0, 7.0, 0.9 * i, 6.0, 0.5 * i, 0.05)
    return recipe("yellow_poplar_leaves",
                  "yellow_poplar_leaves. Six leaves, each a plain isoceles triangle with its sides "
                  "trimmed and a long stem, so the outline is a simple pointed fan. Four of them are "
                  "rotated near 180 deg to hang point-down. Medium 60 deg/frame tumble and a short "
                  "sway; the stems are what tell them apart from the orange poplar.",
                  [192, 192], [96, 96], "centre of the drifting cluster", 311,
                  leaf_forms(spec), leaf_frames(6, per), FX_STYLE)


def fx_orange_poplar():
    """Orange poplar: the biggest leaves, cordate (a narrow heart on its side),
    with a midrib, in two tight clumps, tumbling twice per loop."""
    spec = []
    spots = [(64, 58, 60, 180), (104, 78, 52, 205), (134, 60, 58, 158),
             (74, 132, 54, 214), (116, 148, 58, 168), (142, 112, 48, 196)]
    for i, (x, y, s, rot) in enumerate(spots):
        t = f"o{i}"
        p = [pc("heart", [x, y], [s * 0.66, s], rot=rot),
             stem(x, y, s * 0.42, s * 0.1, rot - 90)]
        rib = {"name": f"rib{i}", "z": 2.6 + i * 0.01, "kind": "flat", "material": "flame_mid",
               "pivot": [x, y], "opacity": 0.5, "line": False,
               "pieces": [pc("circle", [x, y], [s * 0.05, s * 0.72], rot=rot)]}
        spec.append({"x": x, "y": y, "tag": t, "mat": "leaf_orange_poplar", "pieces": p,
                     "extra": [rib]})
    per = {}
    for i in range(6):
        per[f"o{i}"] = (120.0 if i % 2 == 0 else -120.0, 5.0, 0.8 * i, 8.0, 0.55 * i, 0.06)
    return recipe("orange_poplar_leaves",
                  "orange_poplar_leaves. Six of the biggest leaves here: a heart icon turned upside "
                  "down and squashed to 0.66, which gives a cordate leaf with a notched base, plus a "
                  "stem and a lit midrib. Grouped in two clumps instead of one drift, and they tumble "
                  "120 deg per frame - two full turns per loop, twice as fast as the yellow poplar.",
                  [192, 192], [96, 96], "centre of the drifting cluster", 312,
                  leaf_forms(spec), leaf_frames(6, per), FX_STYLE)


def fx_red_poplar():
    """Red poplar: narrow lance leaves in a vertical streamer, spinning 180 deg
    per frame so they read as a gust tearing them down a line."""
    spec = []
    for i in range(7):
        x = 96 + [14, -18, 6, -12, 20, -5, 10][i]
        y = 36 + i * 17
        s = [40, 34, 42, 36, 40, 33, 37][i]
        rot = [8, 168, 22, 190, 12, 176, 26][i]
        t = f"r{i}"
        p = [pc("diamond", [x, y], [s * 0.44, s], rot=rot, crop=[2.0, 0, 14.0, 16]),
             stem(x, y, s * 0.55, s * 0.07, rot + 90)]
        spec.append({"x": x, "y": y, "tag": t, "mat": "leaf_red_poplar", "pieces": p})
    per = {}
    for i in range(7):
        per[f"r{i}"] = (180.0 if i % 2 == 0 else -180.0, 8.0, 0.85 * i, 9.0, 0.7 * i, 0.05)
    return recipe("red_poplar_leaves",
                  "red_poplar_leaves. Seven narrow lance leaves (a diamond icon cropped to 0.44 wide) "
                  "strung out in a vertical line, not a cluster, with a thin stem on each. They spin "
                  "180 deg per frame - three turns per loop - and the phase runs down the line, so the "
                  "gust travels from the top of the cell to the bottom.",
                  [192, 192], [96, 96], "centre of the drifting streamer", 313,
                  leaf_forms(spec), leaf_frames(6, per), FX_STYLE)


# ================================================================= 14. flame
def fx_flame():
    """A tall fire: a ragged dark shell, an amber body, a bright core, two
    detached licks and eight rising sparks, on a warm base pool."""
    cx, base = 192.0, 352.0
    forms = [
        {"name": "pool", "tags": ["pl"], "z": 0, "kind": "mass", "material": "flame_mid",
         "pivot": [cx, base], "opacity": 0.5, "blur": 9.0, "line": False,
         "shade": {"soft": 0.8, "bump": 0.2, "threshold": 0.4, "highlight_amount": 0.3},
         "glow": {"radius": 6, "opacity": 0.4, "color": "flame_glow"},
         "pieces": [pc("circle", [cx, base - 6], [170, 50], squash=0.5)]},
        {"name": "shell", "tags": ["sh"], "z": 1, "kind": "mass", "material": "flame_shell",
         "pivot": [cx, base], "emit": 0.35,
         "rough": {"amp": 0.5, "soft": 3.0, "cell": 16},
         "shade": {"soft": 0.5, "bump": 0.7, "threshold": 0.45, "highlight_amount": 0.45},
         "glow": {"radius": 5, "opacity": 0.35, "color": "flame_mid"},
         "pieces": [pc("droplet", [cx, base - 148], [196, 300], rot=180),
                    pc("droplet", [cx - 62, base - 78], [86, 158], rot=176),
                    pc("droplet", [cx + 60, base - 92], [78, 172], rot=184)]},
        {"name": "body", "tags": ["bd"], "z": 2, "kind": "mass", "material": "flame_mid",
         "pivot": [cx, base], "emit": 0.7,
         "rough": {"amp": 0.45, "soft": 2.4, "cell": 13},
         "shade": {"soft": 0.5, "bump": 0.7, "threshold": 0.45, "highlight_amount": 0.55},
         "glow": {"radius": 6, "opacity": 0.45, "color": "flame_glow"},
         "pieces": [pc("droplet", [cx, base - 120], [126, 236], rot=180),
                    pc("droplet", [cx - 34, base - 56], [60, 118], rot=174)]},
        {"name": "core", "tags": ["cr"], "z": 3, "kind": "mass", "material": "flame_core",
         "pivot": [cx, base], "emit": 1.0,
         "rough": {"amp": 0.35, "soft": 2.0, "cell": 10},
         "shade": {"soft": 0.55, "bump": 0.5, "threshold": 0.4, "highlight_amount": 0.7},
         "glow": {"radius": 9, "opacity": 0.6, "color": "flame_glow"},
         "pieces": [pc("droplet", [cx, base - 78], [66, 152], rot=180)]},
        {"name": "licks", "tags": ["lk"], "z": 2.5, "kind": "mass", "material": "flame_mid",
         "pivot": [cx, base - 268], "emit": 0.85,
         "rough": {"amp": 0.4, "soft": 2.0, "cell": 9},
         "pieces": [pc("droplet", [cx - 14, base - 274], [34, 74], rot=180),
                    pc("droplet", [cx + 24, base - 290], [24, 56], rot=180)]},
        {"name": "sparks", "tags": ["sp"], "z": 4, "kind": "mass", "material": "spark",
         "pivot": [cx, base - 288], "emit": 1.0, "line": {"width": 0.6, "heavy": 0.4},
         "glow": {"radius": 4, "opacity": 0.7, "color": "flame_glow"},
         "pieces": [pc("circle", [cx - 58, base - 300], [9, 8]),
                    pc("circle", [cx - 22, base - 278], [7, 6]),
                    pc("circle", [cx + 16, base - 304], [8, 7]),
                    pc("circle", [cx + 52, base - 270], [6, 6]),
                    pc("circle", [cx - 40, base - 244], [5, 5]),
                    pc("circle", [cx + 34, base - 236], [6, 5]),
                    pc("circle", [cx + 2, base - 222], [5, 4]),
                    pc("circle", [cx - 70, base - 210], [4, 4])]},
    ]
    frames = []
    for k in range(8):
        ph = 2 * math.pi * k / 8
        mv = {"pl": mvv(sx=1.0 + 0.10 * math.sin(ph), sy=1.0 + 0.06 * math.sin(ph + 1)),
              "sh": mvv(sy=1.0 + 0.11 * math.sin(ph), sx=1.0 + 0.05 * math.cos(ph)),
              "bd": mvv(sy=1.0 + 0.15 * math.sin(ph + 0.7), sx=1.0 + 0.06 * math.sin(ph + 1.4)),
              "cr": mvv(sy=1.0 + 0.20 * math.sin(ph + 1.2), dx=4 * math.sin(ph)),
              "lk": mvv(dy=-5.5 * k, sx=1.0 - 0.08 * k, sy=1.0 - 0.06 * k),
              "sp": mvv(dy=-5.0 * k)}
        frames.append(fr(f"f{k}", move=mv))
    return recipe("flame",
                  "flame (tall fire). Five layers: a warm pool at the base, a ragged dark shell (three "
                  "droplets, roughened), an amber body, a bright core and two detached licks above the "
                  "tip, plus eight sparks. Height is animated three different ways at once - the shell "
                  "and body scale vertically, the core also slides sideways, the licks and sparks rise "
                  "and shrink on their own. 384 px, 8 frames, full emission layer.",
                  [384, 384], [cx, base], "the surface the fire stands on", 314, forms, frames, FX_STYLE)


# ================================================================= 15. small_flame
def fx_small_flame():
    """A squat little flame: two wide tongues and one small core and one tip
    spark. Nothing else - no pool, no sparks, 4 frames only."""
    cx, base = 96.0, 170.0
    forms = [
        {"name": "tongues", "tags": ["tg"], "z": 1, "kind": "mass", "material": "flame_shell",
         "pivot": [cx, base], "emit": 0.3,
         "rough": {"amp": 0.4, "soft": 2.0, "cell": 9},
         "shade": {"soft": 0.5, "bump": 0.7, "threshold": 0.45, "highlight_amount": 0.45},
         "glow": {"radius": 4, "opacity": 0.3, "color": "flame_mid"},
         "pieces": [pc("droplet", [cx - 20, base - 34], [58, 76], rot=196),
                    pc("droplet", [cx + 20, base - 34], [58, 76], rot=164),
                    pc("droplet", [cx, base - 40], [66, 88], rot=180)]},
        {"name": "inner", "tags": ["in"], "z": 2, "kind": "mass", "material": "flame_mid",
         "pivot": [cx, base], "emit": 0.75,
         "rough": {"amp": 0.3, "soft": 1.6, "cell": 7},
         "glow": {"radius": 5, "opacity": 0.45, "color": "flame_glow"},
         "pieces": [pc("droplet", [cx, base - 30], [40, 62], rot=180)]},
        {"name": "core", "tags": ["cr"], "z": 3, "kind": "mass", "material": "flame_core",
         "pivot": [cx, base], "emit": 1.0,
         "shade": {"soft": 0.55, "bump": 0.5, "threshold": 0.4, "highlight_amount": 0.7},
         "glow": {"radius": 7, "opacity": 0.6, "color": "flame_glow"},
         "pieces": [pc("circle", [cx, base - 22], [26, 34])]},
        {"name": "tip", "tags": ["tp"], "z": 3.5, "kind": "mass", "material": "spark",
         "pivot": [cx, base - 96], "emit": 1.0, "line": {"width": 0.5, "heavy": 0.3},
         "glow": {"radius": 3, "opacity": 0.6, "color": "flame_glow"},
         "pieces": [pc("droplet", [cx + 4, base - 100], [13, 20], rot=180)]},
    ]
    frames = []
    for k in range(4):
        ph = 2 * math.pi * k / 4
        mv = {"tg": mvv(sy=1.0 + 0.13 * math.sin(ph), sx=1.0 + 0.05 * math.cos(ph)),
              "in": mvv(sy=1.0 + 0.19 * math.sin(ph + 0.9)),
              "cr": mvv(sy=1.0 + 0.24 * math.sin(ph + 1.3), dx=3 * math.sin(ph))}
        if k in (1, 2):
            mv["tp"] = mvv(dy=-8.0 * (k - 1) if k == 2 else 0.0,
                           sx=1.0 - 0.1 * (k - 1), sy=1.0 - 0.1 * (k - 1))
        frames.append(fr(f"f{k}", show=(["tip"] if k in (1, 2) else []), move=mv))
    return recipe("small_flame",
                  "small_flame (torch-scale flame). A different shape from the big flame, not a smaller "
                  "one: three wide leaning tongues instead of one tall droplet, a squat inner body, a "
                  "round core and one tip spark that appears on two frames. No base pool, no spark "
                  "trail, 4 frames, emission layer only on the inner layers.",
                  [192, 192], [cx, base], "the surface the flame stands on", 315, forms, frames, FX_STYLE)


# ================================================================= driver
BUILDERS = {
    "bubble": fx_bubble,
    "bubble_column_up": fx_bubble_column_up,
    "current_down": fx_current_down,
    "dolphin": fx_dolphin,
    "bubble_pop": fx_bubble_pop,
    "fishing": fx_fishing,
    "rain": fx_rain,
    "splash": fx_splash,
    "pale_oak_leaves": fx_pale_oak,
    "cherry_leaves": fx_cherry,
    "yellow_poplar_leaves": fx_yellow_poplar,
    "orange_poplar_leaves": fx_orange_poplar,
    "red_poplar_leaves": fx_red_poplar,
    "flame": fx_flame,
    "small_flame": fx_small_flame,
}


def main(argv):
    names = argv or list(BUILDERS)
    REC.mkdir(parents=True, exist_ok=True)
    for name in names:
        rec = BUILDERS[name]()
        path = REC / f"{name}.json"
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(rec, fh, indent=1, ensure_ascii=False)
            fh.write("\n")
        print(f"wrote {path.name}  canvas={rec['canvas']}  frames={len(rec['frames'])}  "
              f"forms={len(rec['forms'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
