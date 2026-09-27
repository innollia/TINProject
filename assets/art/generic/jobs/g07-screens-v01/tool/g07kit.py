"""g07 recipe helpers: write iconkit recipes from short Python definitions.

Nothing here paints.  The helpers only build the same JSON recipe dicts that
build.py already reads (see iconkit/render.py for the recipe grammar), so every
result is still an at-icons collage rendered by the unchanged V1 renderer.

Units are final output px.  Object scale (same as g04, 60 deg top-down):
width 180 px/m, ground depth 156 px/m (x0.866), height 105 px/m.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

PX_W, PX_D, PX_H = 180.0, 156.0, 105.0
GROUND = math.sin(math.radians(60.0))


def _r(v):
    return None if v is None else round(float(v), 2)


# ------------------------------------------------------------------ pieces
def piece(icon, at, size=None, **kw):
    d = {"icon": icon, "at": [_r(at[0]), _r(at[1])]}
    if size is not None:
        d["size"] = _r(size) if isinstance(size, (int, float)) else [_r(v) for v in size]
    d.update(kw)
    return d


def rrect(at, size, corner=6, border=4, **kw):
    """Rounded rectangle whose corner radius stays ``corner`` px at any size (9-slice of 'square')."""
    return piece("square", at, size, slice={"border": border, "corner": corner}, **kw)


def disc(at, d, **kw):
    size = [d, d] if isinstance(d, (int, float)) else d
    return piece("circle", at, size, **kw)


def wedge_poly(a0, a1, steps=None, r=7.6):
    """Polygon (icon units) of a pie slice of the 'circle' icon, angles in screen degrees (0 = right, 90 = down)."""
    steps = steps or max(4, int(abs(a1 - a0) / 6) + 1)
    pts = [[8.0, 8.0]]
    for k in range(steps + 1):
        t = math.radians(a0 + (a1 - a0) * k / steps)
        pts.append([round(8 + r * math.cos(t), 3), round(8 + r * math.sin(t), 3)])
    return pts


def sector(at, radius, a0, a1, **kw):
    """Pie slice of radius ``radius`` centred on ``at`` (registered to the full circle)."""
    return piece("circle", at, [2 * radius, 2 * radius], poly=wedge_poly(a0, a1), fit=[1, 1, 15, 15], **kw)


# ------------------------------------------------------------------ forms
def form(name, z, pieces, material=None, kind=None, tags=None, **kw):
    d = {"name": name, "z": z}
    if kind:
        d["kind"] = kind
    if material:
        d["material"] = material
    if tags:
        d["tags"] = list(tags)
    d.update(kw)
    d["pieces"] = pieces if isinstance(pieces, list) else [pieces]
    return d


def variant(f, *tags):
    """Hide a form by default and give it tags, so a frame can ``show`` it."""
    f["hidden"] = True
    f["tags"] = list(f.get("tags", [])) + list(tags)
    return f


def annulus(name, z, c, r_out, r_in, material, kind="mass", **kw):
    return form(name, z, [disc(c, 2 * r_out), disc(c, 2 * r_in, op="sub")], material, kind=kind, **kw)


def arc_band(name, z, c, r_out, r_in, a0, a1, material, kind="flat", **kw):
    return form(name, z, [sector(c, r_out, a0, a1), disc(c, 2 * r_in, op="sub")], material, kind=kind, **kw)


def ticks(name, z, c, r, count, a0, a1, length, width, material, kind="flat", icon="square", **kw):
    """Radial marks on a circle of radius ``r`` (full circle when a1 - a0 == 360)."""
    p = piece(icon, [0, 0], [width, length],
              repeat={"ellipse": [_r(c[0]), _r(c[1]), _r(r), _r(r)], "count": count, "arc": [a0, a1], "orient": True})
    return form(name, z, [p], material, kind=kind, **kw)


def screws(name, z, pts, d=8.0, material="steel", slot_angle=35.0):
    """Screw heads with a slot.  Returns two forms (heads, slots)."""
    heads = form(name, z, [disc(p, d) for p in pts], material, line={"width": 0.5, "heavy": 0.5})
    slots = form(name + "_slot", z + 0.01, [piece("square", p, [d * 0.8, max(1.0, d * 0.16)], rot=slot_angle + 23 * i)
                                            for i, p in enumerate(pts)], "dial_mark", kind="flat", opacity=0.8)
    return [heads, slots]


def glare(name, z, c, d, clip, opacity=0.12, dx=-0.06, dy=-0.08):
    """Glass glare crescent at the upper left of a round face."""
    return form(name, z, [disc([c[0] + dx * d, c[1] + dy * d], d * 0.92),
                          disc([c[0] + 0.05 * d, c[1] + 0.07 * d], d * 1.02, op="sub")],
                "glare", kind="flat", opacity=opacity, clip_to=clip)


def bezier(p0, p1, p2, n):
    pts = []
    for k in range(n):
        t = k / (n - 1) if n > 1 else 0.0
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        pts.append([round(x, 2), round(y, 2)])
    return pts


def dots(name, z, pts, d, material, kind="mass", icon="circle", **kw):
    p = piece(icon, [0, 0], [d, d], repeat={"points": pts})
    return form(name, z, [p], material, kind=kind, **kw)


def rod(p0, p1, w, corner=None, **kw):
    """Rounded bar from p0 to p1 (a leg, strut, arm or wire) as one piece."""
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    length = math.hypot(dx, dy)
    ang = math.degrees(math.atan2(dy, dx)) - 90.0
    return rrect([(p0[0] + p1[0]) / 2.0, (p0[1] + p1[1]) / 2.0], [w, length + w], corner=corner or w / 2.0,
                 rot=ang, **kw)


# ------------------------------------------------------------------ objects (60 deg top-down)
def box(name, z, cx, base_y, w, d, h, material, corner=6, **kw):
    """Box standing on the floor: footprint w x d px ends at base_y, front face h px tall."""
    top_y = base_y - h - d / 2.0
    return form(name, z, [rrect([cx, top_y], [w, d], corner=corner)], material, kind="block", extrude=h, **kw)


def cyl(name, z, cx, base_y, r, h, material, **kw):
    """Upright cylinder of radius r px (footprint ellipse 2r x 2r*0.866) whose front foot is at base_y."""
    ry = r * GROUND
    top_y = base_y - ry - h
    return form(name, z, [disc([cx, top_y], [2 * r, 2 * ry])], material, kind="block", extrude=h, **kw)


def floor_shadow(cx, base_y, w, d, opacity=0.35, blur=8, name="shadow", dx=6):
    return form(name, -10, [rrect([cx + dx, base_y - d * 0.45], [w + 18, d * 0.9 + 10], corner=min(w, d) * 0.45)],
                kind="shadow", color="shadow_contact", opacity=opacity, blur=blur)


def floor_ellipse_shadow(cx, base_y, rx, ry, opacity=0.35, blur=8, name="shadow", dx=6):
    return form(name, -10, [disc([cx + dx, base_y - ry], [2 * rx + 14, 2 * ry + 10])],
                kind="shadow", color="shadow_contact", opacity=opacity, blur=blur)


# ------------------------------------------------------------------ recipe
def frame(name, **kw):
    d = {"name": name}
    d.update(kw)
    return d


def recipe(asset, canvas, forms, pivot=None, frames=None, style="sprite", seed=7, note="", pivot_meaning=None,
           palette="palette_g07.json", **kw):
    r = {"asset": asset, "status": "candidate", "note": note, "palette": palette, "style": style,
         "canvas": list(canvas)}
    if pivot is not None:
        r["pivot"] = [_r(pivot[0]), _r(pivot[1])]
    if pivot_meaning:
        r["pivot_meaning"] = pivot_meaning
    r["seed"] = seed
    r.update(kw)
    r["forms"] = forms
    if frames:
        r["frames"] = frames
    return r


def write(recipes, out_dir):
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    names = []
    for r in recipes:
        path = out_dir / f"{r['asset']}.json"
        path.write_text(json.dumps(r, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
        names.append(path.name)
    print("wrote", len(names), "recipes:", ", ".join(names))
    return names
