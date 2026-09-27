"""g06kit: small helpers that WRITE iconkit recipes (JSON) for the 03 Deduction
Casework kit.  Nothing here paints: every shape is still an at-icons cut
(``square`` / ``circle`` / named icons) that ``iconkit.render`` rasterises.

Coordinates are final output px of the recipe canvas.

    rect(x0, y0, x1, y1)        sharp rectangle (square icon, rounded corners cut off)
    box(cx, cy, w, h, rot)       rotated sharp rectangle
    quad([(x, y), ...])          any convex/concave polygon cut out of the square icon
    ell(cx, cy, w, h, rot)       ellipse (circle icon)
    limb(p0, p1, w0, w1)         tapered capsule between two points
    icon(name, cx, cy, w, h)     any at-icons glyph
    F(name, pieces, mat, z)      one form
"""

from __future__ import annotations

import json
import math
from pathlib import Path

SQ = [3.0, 3.0, 13.0, 13.0]  # inside the square icon's rounded corners


def _r(v) -> float:
    return round(float(v), 2)


def rect(x0, y0, x1, y1, **kw) -> dict:
    x0, x1 = sorted((x0, x1))
    y0, y1 = sorted((y0, y1))
    p = {"icon": "square", "crop": SQ, "at": [_r((x0 + x1) / 2), _r((y0 + y1) / 2)],
         "size": [_r(max(x1 - x0, 0.6)), _r(max(y1 - y0, 0.6))]}
    p.update(kw)
    return p


def box(cx, cy, w, h, rot=0.0, **kw) -> dict:
    p = {"icon": "square", "crop": SQ, "at": [_r(cx), _r(cy)], "size": [_r(max(w, 0.6)), _r(max(h, 0.6))]}
    if rot:
        p["rot"] = _r(rot)
    p.update(kw)
    return p


def quad(pts, **kw) -> dict:
    xs = [float(p[0]) for p in pts]
    ys = [float(p[1]) for p in pts]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 0.6), max(y1 - y0, 0.6)
    poly = [[_r(3 + 10 * (x - x0) / w), _r(3 + 10 * (y - y0) / h)] for x, y in zip(xs, ys)]
    p = {"icon": "square", "poly": poly, "fit": SQ, "at": [_r((x0 + x1) / 2), _r((y0 + y1) / 2)],
         "size": [_r(w), _r(h)]}
    p.update(kw)
    return p


def ell(cx, cy, w, h=None, rot=0.0, **kw) -> dict:
    p = {"icon": "circle", "at": [_r(cx), _r(cy)], "size": [_r(max(w, 0.6)), _r(max(h if h is not None else w, 0.6))]}
    if rot:
        p["rot"] = _r(rot)
    p.update(kw)
    return p


def icon(name, cx, cy, w, h=None, rot=0.0, **kw) -> dict:
    p = {"icon": name, "at": [_r(cx), _r(cy)], "size": _r(w) if h is None else [_r(w), _r(h)]}
    if rot:
        p["rot"] = _r(rot)
    p.update(kw)
    return p


def rot_to(p0, p1) -> float:
    """``rot`` that turns a piece's +y axis from p0 toward p1."""
    return math.degrees(math.atan2(-(p1[0] - p0[0]), p1[1] - p0[1]))


def limb(p0, p1, w0, w1=None, caps=True, cap1=None) -> list:
    """Tapered capsule: a trapezoid with round ends."""
    w1 = w0 if w1 is None else w1
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    L = math.hypot(dx, dy) or 1e-3
    nx, ny = -dy / L, dx / L
    pts = [(p0[0] + nx * w0 / 2, p0[1] + ny * w0 / 2), (p1[0] + nx * w1 / 2, p1[1] + ny * w1 / 2),
           (p1[0] - nx * w1 / 2, p1[1] - ny * w1 / 2), (p0[0] - nx * w0 / 2, p0[1] - ny * w0 / 2)]
    out = [quad(pts)]
    if caps:
        out.append(ell(p0[0], p0[1], w0))
        if cap1 is not False:
            out.append(ell(p1[0], p1[1], w1 if cap1 is None else cap1))
    return out


def lerp(a, b, t):
    return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t]


def F(name, pieces, mat=None, z=0.0, kind=None, **kw) -> dict:
    f = {"name": name, "z": z, "pieces": [p for p in pieces if p]}
    if kind:
        f["kind"] = kind
    if mat:
        if isinstance(mat, str) and mat.startswith("#"):
            f["color"] = mat
        elif isinstance(mat, str) and mat.startswith("@"):   # palette colour by name
            f["color"] = mat[1:]
        else:
            f["material"] = mat
    f.update(kw)
    return f


def shadow(name, pieces, opacity=0.35, blur=6.0) -> dict:
    return {"name": name, "kind": "shadow", "color": "shadow_contact", "opacity": opacity, "blur": blur,
            "pieces": pieces}


def recipe(asset, forms, canvas, pivot, palette, style="prop", note="", seed=1, pivot_meaning=None,
           frames=None, **kw) -> dict:
    r = {"asset": asset, "status": "candidate", "note": note, "palette": palette, "style": style,
         "canvas": [int(canvas[0]), int(canvas[1])], "pivot": [_r(pivot[0]), _r(pivot[1])],
         "pivot_meaning": pivot_meaning or "ground contact point", "seed": seed,
         "forms": [f for f in forms if f and f.get("pieces")]}
    if frames:
        r["frames"] = frames
    r.update(kw)
    return r


def write(recipes_dir, r) -> Path:
    path = Path(recipes_dir) / f"{r['asset']}.json"
    path.write_text(json.dumps(r, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return path


def clock_pieces(cx, cy, r, hour, minute, ticks=12, tick_len=0.18, hand_w=None):
    """Tick marks + hour/minute hands of an analogue clock face (pieces only).
    Angles are clockwise from 12 o'clock."""
    hw = hand_w or max(2.0, r * 0.07)
    tick = []
    for a in range(ticks):
        t = math.radians(a * 360.0 / ticks)
        rr = r * (1 - tick_len / 2)
        tick.append(box(cx + rr * math.sin(t), cy - rr * math.cos(t), hw * 0.7, r * tick_len, rot=a * 360.0 / ticks))
    hands = []
    for ang, L, w in ((((hour % 12) + minute / 60.0) * 30.0, r * 0.52, hw * 1.3), (minute * 6.0, r * 0.84, hw)):
        t = math.radians(ang)
        hands.append(box(cx + math.sin(t) * L / 2, cy - math.cos(t) * L / 2, w, L, rot=ang))
    return tick, hands

def clock_segments(hour, minute, ticks=12, tick_len=0.18):
    """Unit-radius clock as line segments [(p0, p1, width)] (clockwise from 12 o'clock),
    for faces that sit on a skewed plane: map the points, then draw each with limb()."""
    segs = []
    for a in range(ticks):
        t = math.radians(a * 360.0 / ticks)
        s, c = math.sin(t), -math.cos(t)
        segs.append(((s * (1 - tick_len), c * (1 - tick_len)), (s * 0.98, c * 0.98), 0.06))
    for ang, L, w in ((((hour % 12) + minute / 60.0) * 30.0, 0.52, 0.11), (minute * 6.0, 0.84, 0.075)):
        t = math.radians(ang)
        segs.append(((0.0, 0.0), (math.sin(t) * L, -math.cos(t) * L), w))
    return segs