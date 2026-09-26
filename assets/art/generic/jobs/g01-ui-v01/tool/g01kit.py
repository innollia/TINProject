"""g01kit - recipe authoring helpers for the g01 generic asset jobs (added in g01, 2026-09-27).

The iconkit renderer and build.py are the V1 tool; this module only WRITES recipes.
Every picture stays a composition of cut at-icons masks: circles, the filled
``square`` icon cut to exact polygons (``poly``) or sharp rectangles (``crop``),
droplets, crescents, sparkle crops of ``stars``, clouds and so on.  No other
drawing source exists.

    P(icon, x, y, w, h=None, **opts)        one piece (size [w, h], or longest side w)
    C R RR POLY D MOON SPARK STAR           common primitive pieces
    F(name, material, pieces, z, kind, **)   one form
    turn / scale / shift                     move a group of pieces rigidly
    around(n, cx, cy, rx, ry, fn)            pieces on an ellipse, explicit (turnable)
    animate([[forms of frame 1], ...], asset)  -> (forms, frames) with f1..fN tags
    write_palette(recipes_dir)               palette_g01.json = V1 mood palette + PALETTE_ADD
    save(recipes_dir, asset, forms, canvas, style, ...)
"""

from __future__ import annotations

import copy
import json
import math
from pathlib import Path

PALETTE = "palette_g01.json"


# ------------------------------------------------------------------ pieces
def _r(v):
    return round(float(v), 2)


def P(icon, x, y, w, h=None, **kw):
    piece = {"icon": icon, "at": [_r(x), _r(y)], "size": _r(w) if h is None else [_r(w), _r(h)]}
    for k, v in kw.items():
        if v is not None:
            piece[k] = v
    return piece


def C(x, y, w, h=None, **kw):
    """Ellipse (the at-icons circle)."""
    return P("circle", x, y, w, w if h is None else h, **kw)


def R(x, y, w, h, **kw):
    """Sharp rectangle: the inner, fully filled part of the square icon."""
    return P("square", x, y, w, h, crop=[3, 3, 13, 13], **kw)


def RR(x, y, w, h, **kw):
    """Rounded rectangle (the whole square icon)."""
    return P("square", x, y, w, h, **kw)


def POLY(pts, x, y, w, h, **kw):
    """Exact polygon: ``pts`` in 0..1 box units, mapped onto a w x h box centred on (x, y).
    The points should span 0..1 on both axes (the tight fit maps their bounds to the box)."""
    poly = [[round(2.0 + 12.0 * u, 4), round(2.0 + 12.0 * v, 4)] for u, v in pts]
    return P("square", x, y, w, h, poly=poly, **kw)


def D(x, y, w, h, **kw):
    """Droplet, point up (rot turns it)."""
    return P("droplet", x, y, w, h, **kw)


def MOON(x, y, w, h, **kw):
    """Crescent: horns top-right and bottom-left, convex side bottom-right (at rot 0)."""
    return P("moon", x, y, w, h, **kw)


def SPARK(x, y, s, **kw):
    """Four-point sparkle: the big star of the ``stars`` icon cut out on its own."""
    return P("stars", x, y, s, s, crop=[1.0, 4.6, 8.6, 14.0], **kw)


def STAR(x, y, s, **kw):
    return P("star", x, y, s, s, **kw)


def star_pts(n, inner=0.45, phase=-90.0):
    """Unit-box points of an n-point star (for POLY)."""
    pts = []
    for k in range(2 * n):
        r = 0.5 if k % 2 == 0 else 0.5 * inner
        a = math.radians(phase + k * 180.0 / n)
        pts.append((0.5 + r * math.cos(a), 0.5 + r * math.sin(a)))
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    return [((u - x0) / (x1 - x0), (v - y0) / (y1 - y0)) for u, v in pts]


def ngon(n, phase=-90.0):
    pts = [(0.5 + 0.5 * math.cos(math.radians(phase + k * 360.0 / n)),
            0.5 + 0.5 * math.sin(math.radians(phase + k * 360.0 / n))) for k in range(n)]
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    return [((u - x0) / (x1 - x0), (v - y0) / (y1 - y0)) for u, v in pts]


def sub(piece):
    piece = copy.deepcopy(piece)
    piece["op"] = "sub"
    return piece


def poly_abs(points, **kw):
    """Exact polygon from absolute canvas points (maps them onto their own bounding box)."""
    xs, ys = [p[0] for p in points], [p[1] for p in points]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 0.6), max(y1 - y0, 0.6)
    pts = [((px - x0) / w, (py - y0) / h) for px, py in points]
    return POLY(pts, (x0 + x1) / 2.0, (y0 + y1) / 2.0, w, h, **kw)


def wedge(cx, cy, r, a0, a1, steps=16, **kw):
    """Pie slice from angle a0 to a1 (degrees, clockwise on screen, 0 = +x)."""
    pts = [(cx, cy)]
    for k in range(steps + 1):
        a = math.radians(a0 + (a1 - a0) * k / steps)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return poly_abs(pts, **kw)


def spindle(x0, y0, x1, y1, w, **kw):
    """Long thin diamond from (x0, y0) to (x1, y1), widest (w) at 60 % of the way."""
    dx, dy = x1 - x0, y1 - y0
    n = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / n, dx / n
    mx, my = x0 + dx * 0.6, y0 + dy * 0.6
    return poly_abs([(x0, y0), (mx + nx * w / 2, my + ny * w / 2), (x1, y1), (mx - nx * w / 2, my - ny * w / 2)], **kw)


def polyline(points, width, **kw):
    """Thick polyline: one sharp rectangle per segment plus round joints."""
    ps = []
    for (ax, ay), (bx, by) in zip(points, points[1:]):
        length = math.hypot(bx - ax, by - ay)
        if length < 0.3:
            continue
        ang = math.degrees(math.atan2(by - ay, bx - ax))
        ps.append(R((ax + bx) / 2.0, (ay + by) / 2.0, length + 0.6, width, rot=round(ang, 2), **kw))
    for (x, y) in points[1:-1]:
        ps.append(C(x, y, width, width, **kw))
    return ps


def ringp(x, y, w, h, t, **kw):
    """Elliptic ring of thickness t: [outer add, inner sub]."""
    return [C(x, y, w, h, **kw), sub(C(x, y, max(1.0, w - 2 * t), max(1.0, h - 2 * t), **kw))]


def rrframe(x, y, w, h, t, **kw):
    """Rounded-rectangle frame band of thickness t."""
    return [RR(x, y, w, h, **kw), sub(RR(x, y, w - 2 * t, h - 2 * t, **kw))]


def rrect(x, y, w, h, r):
    """Rounded rectangle with a TRUE constant corner radius r (2 sharp rects + 4 circles),
    so a 9-slice edge stays straight and the corner fits its cell."""
    r = max(0.5, min(r, w / 2.0, h / 2.0))
    ps = []
    if w - 2 * r > 0.5:
        ps.append(R(x, y, w - 2 * r, h))
    if h - 2 * r > 0.5:
        ps.append(R(x, y, w, h - 2 * r))
    for sx in (-1, 1):
        for sy in (-1, 1):
            ps.append(C(x + sx * (w / 2.0 - r), y + sy * (h / 2.0 - r), 2 * r, 2 * r))
    return ps


def rframe(x, y, w, h, t, r):
    """Band of thickness t along a constant-radius rounded rectangle."""
    return rrect(x, y, w, h, r) + [sub(p) for p in rrect(x, y, w - 2 * t, h - 2 * t, max(0.5, r - t))]


# ------------------------------------------------------------------ groups
def turn(pieces, deg, cx, cy):
    r = math.radians(deg)
    c, s = math.cos(r), math.sin(r)
    out = []
    for p in pieces:
        q = copy.deepcopy(p)
        x, y = q["at"][0] - cx, q["at"][1] - cy
        q["at"] = [_r(cx + x * c - y * s), _r(cy + x * s + y * c)]
        q["rot"] = _r(q.get("rot", 0.0) + deg)
        out.append(q)
    return out


def scale(pieces, k, cx, cy, ky=None):
    ky = k if ky is None else ky
    out = []
    for p in pieces:
        q = copy.deepcopy(p)
        q["at"] = [_r(cx + (q["at"][0] - cx) * k), _r(cy + (q["at"][1] - cy) * ky)]
        size = q.get("size")
        if isinstance(size, (int, float)):
            q["size"] = _r(size * max(k, ky))
        elif size is not None:
            q["size"] = [None if size[0] is None else _r(size[0] * k), None if size[1] is None else _r(size[1] * ky)]
        out.append(q)
    return out


def shift(pieces, dx, dy):
    out = []
    for p in pieces:
        q = copy.deepcopy(p)
        q["at"] = [_r(q["at"][0] + dx), _r(q["at"][1] + dy)]
        out.append(q)
    return out


def around(n, cx, cy, rx, ry, fn, a0=0.0, a1=360.0, orient=False):
    """fn(x, y, k, angle_deg) -> piece; returns explicit pieces on an ellipse."""
    out = []
    full = abs((a1 - a0) - 360.0) < 1e-6
    for k in range(n):
        f = k / n if full else (k / (n - 1) if n > 1 else 0.5)
        a = a0 + (a1 - a0) * f
        t = math.radians(a)
        p = fn(cx + rx * math.cos(t), cy + ry * math.sin(t), k, a)
        if orient:
            p["rot"] = _r(p.get("rot", 0.0) + a + 90.0)
        out.append(p)
    return out


def xform_forms(forms, fn):
    """Apply a piece-group function (e.g. lambda ps: turn(ps, 30, 64, 64)) to every form."""
    out = []
    for f in forms:
        g = copy.deepcopy(f)
        g["pieces"] = fn(g.get("pieces", []))
        out.append(g)
    return out


# ------------------------------------------------------------------ forms
def F(name, material, pieces, z=0.0, kind=None, **kw):
    form = {"name": name, "z": z}
    if kind:
        form["kind"] = kind
    if material:
        form["material"] = material
    form["pieces"] = pieces
    for k, v in kw.items():
        if v is not None:
            form[k] = v
    return form


def halo(name, color_mat, pieces, z, blur, opacity, **kw):
    """Soft light around a shape on a transparent canvas (the renderer's ``glow`` only
    brightens pixels that are already painted, so free-standing light needs its own form)."""
    return F(name, color_mat, pieces, z, "flat", blur=blur, opacity=opacity, **kw)


def animate(frame_forms, asset, names=None):
    """[[forms shown in frame 1], [frame 2], ...] -> (forms, frames).

    Each frame's forms get a tag f<k>, start hidden and are shown only by their frame.
    clip_to / cut_by references are renamed inside the same frame.
    """
    forms, frames = [], []
    for k, fl in enumerate(frame_forms, start=1):
        tag = f"f{k}"
        for f in fl:
            g = copy.deepcopy(f)
            g["name"] = f"{tag}_{f['name']}"
            g["tags"] = [tag]
            g["hidden"] = True
            if g.get("clip_to"):
                g["clip_to"] = f"{tag}_{g['clip_to']}"
            if g.get("cut_by"):
                g["cut_by"] = [f"{tag}_{n}" for n in g["cut_by"]]
            forms.append(g)
        name = names[k - 1] if names else f"{asset}_{k}"
        frames.append({"name": name, "show": [tag]})
    return forms, frames


# ------------------------------------------------------------------ files
def save(rdir, asset, forms, canvas, style, frames=None, meta=None, note="", seed=None,
         pivot=None, pivot_meaning=None, style_override=None, **extra):
    rdir = Path(rdir)
    rdir.mkdir(parents=True, exist_ok=True)
    rec = {
        "asset": asset,
        "status": "candidate",
        "note": note,
        "palette": PALETTE,
        "style": style,
        "canvas": list(canvas),
        "pivot": pivot or [canvas[0] / 2.0, canvas[1] / 2.0],
        "pivot_meaning": pivot_meaning or "centre of the canvas (flat view: icon / UI / effect)",
        "seed": seed if seed is not None else (sum(ord(c) for c in asset) * 7919) % 100000,
    }
    if style_override:
        rec["style_override"] = style_override
    if meta:
        rec["meta"] = meta
    rec.update(extra)
    rec["forms"] = forms
    if frames:
        rec["frames"] = frames
    path = rdir / f"{asset}.json"
    path.write_text(json.dumps(rec, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return path


# ------------------------------------------------------------------ palette
PALETTE_ADD = {
    "colors": {
        "glint": "#e8e2ee", "void_violet": "#0b0710", "plate_low": "#120e16",
        "fx_white": "#f4f0e8", "fx_ice": "#8fd0f0", "fx_gold": "#f0c860", "fx_heal": "#9ce4a8",
        "glow_steel": "#c8d4ee", "glow_fire": "#ff8a3a", "glow_ice": "#9ad6ff", "glow_bolt": "#ffe57a",
        "glow_holy": "#ffe6a0", "glow_heal": "#9cf0b4", "glow_poison": "#a8dc58", "glow_shadow": "#a070e0",
        "glow_arcane": "#8ea4ff", "glow_gold": "#ffd070", "glow_water": "#8cc8f0", "glow_wind": "#c8f0e0",
        "glow_earth": "#d0a868", "glow_red": "#ff5a4a", "glow_blue": "#5a8cff",
        "ui_panel": "#17131c", "ui_panel_warm": "#1a1511",
        "fog": "#8c86a0", "fog_dark": "#4e4860", "dark_veil": "#07050a", "rain": "#a0aac4", "snow": "#e6e2ee",
        "tint_steel": "#3a3446", "tint_fire": "#4c2218", "tint_ice": "#1a3048", "tint_bolt": "#2c2a4a",
        "tint_heal": "#1c3a2a", "tint_poison": "#26401c", "tint_shadow": "#2c1c3c", "tint_holy": "#3e3420",
        "tint_earth": "#3a2e1e", "tint_wind": "#1e3a36", "tint_stun": "#3a3420", "tint_sleep": "#1c2040",
        "tint_curse": "#301a36", "tint_buff": "#3a2a18", "tint_water": "#182c44", "tint_silence": "#28283a"
    },
    "materials": {
        "steel": {"base": "#666a75", "shadow": "#3f424b", "light": "#a8adba", "line": "#101116",
                  "shade": {"highlight": 0.84, "highlight_amount": 0.75},
                  "grime": {"stamps": ["metaballs", "sponge"], "size": 9, "soft": 1.0, "density": 0.18, "strength": 0.22, "color": "rust"}},
        "steel_dark": {"base": "#4a4d57", "shadow": "#2e3037", "light": "#7b7f8c", "line": "#0b0b0e"},
        "steel_light": {"base": "#b4b9c6", "light": "#e2e6ef"},
        "iron_dark": {"base": "#2e3036", "shadow": "#1b1c20", "light": "#4a4c55", "line": "#08080a",
                      "grime": {"stamps": ["metaballs", "sponge"], "size": 12, "soft": 1.5, "density": 0.35, "strength": 0.4, "color": "rust"}},
        "gold": {"base": "#9c7b35", "shadow": "#604a1f", "light": "#dcc070", "line": "#1f1407",
                 "side": "#6e5424", "side_shadow": "#4a3816",
                 "shade": {"highlight": 0.84, "highlight_amount": 0.8}},
        "gold_dark": {"base": "#6e5424"},
        "silver": {"base": "#83858f", "shadow": "#55575f", "light": "#c4c6d0", "line": "#15151a",
                   "side": "#5c5e66", "side_shadow": "#3e4046", "shade": {"highlight": 0.84, "highlight_amount": 0.8}},
        "glass_dark": {"base": "#4e4a5c", "shadow": "#2e2b38", "light": "#9894aa", "line": "#0c0a10",
                       "shade": {"threshold": 0.45, "highlight_amount": 0.6}},
        "liquid_red": {"base": "#8c2632", "shadow": "#561420", "light": "#c4505a", "line": "#1e060a"},
        "liquid_red_light": {"base": "#c4505a"},
        "liquid_blue": {"base": "#2d4c84", "shadow": "#1a2c54", "light": "#5d86c4", "line": "#080e1e"},
        "liquid_blue_light": {"base": "#6a92d0"},
        "liquid_green": {"base": "#4a7a36", "shadow": "#2c4a20", "light": "#7eb058", "line": "#0c1608"},
        "liquid_green_light": {"base": "#8cbc62"},
        "liquid_gold": {"base": "#b0883a", "shadow": "#72561f", "light": "#e8c872", "line": "#1f1407"},
        "liquid_gold_light": {"base": "#ecd08a"},
        "liquid_violet": {"base": "#5e3a86", "shadow": "#3a2256", "light": "#9066c0", "line": "#12081e"},
        "cork": {"base": "#7a6044", "shadow": "#4e3c2a", "light": "#9e8260", "line": "#1a120a",
                 "texture": {"stamp": "sponge", "length": 5, "width": 5, "angle": 0, "jitter": 90, "density": 0.6, "strength": 0.08}},
        "wax_red": {"base": "#7e2430", "shadow": "#4e141c", "light": "#a84450", "line": "#1e0608"},
        "wax_dark": {"base": "#551820"},
        "bread": {"base": "#8e6436", "shadow": "#5c3e20", "light": "#bc8c52", "line": "#1e1208",
                  "texture": {"stamp": "sponge", "length": 6, "width": 6, "angle": 0, "jitter": 90, "density": 0.7, "strength": 0.08}},
        "bread_crumb": {"base": "#c49e66"},
        "meat": {"base": "#7c3a2e", "shadow": "#4c2019", "light": "#a8584a", "line": "#1a0806"},
        "bone": {"base": "#b5a88a", "shadow": "#82765e", "light": "#d6cbb0", "line": "#3a3226",
                 "grime": {"stamps": ["sponge", "metaballs"], "size": 8, "soft": 1.0, "density": 0.2, "strength": 0.25, "color": "grime"}},
        "herb": {"base": "#48683a", "shadow": "#2c4224", "light": "#6e9254", "line": "#0c1408"},
        "herb_dark": {"base": "#2e4626"},
        "cloth_blue": {"base": "#2f3a5c", "shadow": "#1c2238", "light": "#4a5a84", "line": "#080a14",
                       "texture": {"stamp": "leaf", "pre_rot": 45, "length": 10, "width": 2.5, "angle": 90, "jitter": 10, "density": 0.8, "strength": 0.07}},
        "cloth_green": {"base": "#34503a", "shadow": "#1f3224", "light": "#4e7254", "line": "#08100a"},
        "cloth_violet": {"base": "#4a3560", "shadow": "#2e203e", "light": "#6a5086", "line": "#0e0814",
                         "texture": {"stamp": "leaf", "pre_rot": 45, "length": 10, "width": 2.5, "angle": 90, "jitter": 10, "density": 0.8, "strength": 0.07}},
        "cloth_brown": {"base": "#5a4430", "shadow": "#3a2a1e", "light": "#7a6048", "line": "#140c08"},
        "leather_dark": {"base": "#33261e"},
        "wood_dark": {"base": "#2a2018"},
        "string": {"base": "#c8bca0"},
        "gem_red": {"base": "#a02838", "shadow": "#5e1220", "light": "#ff7880", "line": "#200408",
                    "shade": {"threshold": 0.42, "highlight": 0.84, "highlight_amount": 0.9}},
        "gem_blue": {"base": "#2a5aa8", "shadow": "#142e62", "light": "#80b4ff", "line": "#040a1c",
                     "shade": {"threshold": 0.42, "highlight": 0.84, "highlight_amount": 0.9}},
        "gem_green": {"base": "#2a8a5a", "shadow": "#144a30", "light": "#7ae0a8", "line": "#041c0e",
                      "shade": {"threshold": 0.42, "highlight": 0.84, "highlight_amount": 0.9}},
        "gem_violet": {"base": "#7440a8", "shadow": "#3e2064", "light": "#c090ff", "line": "#12061e",
                       "shade": {"threshold": 0.42, "highlight": 0.84, "highlight_amount": 0.9}},
        "plate": {"base": "#2c2634", "shadow": "#1a1620", "light": "#3e3648", "line": "#07050a",
                  "texture": {"stamp": "leaf", "pre_rot": 45, "length": 12, "width": 3, "angle": 0, "jitter": 14, "density": 0.9, "strength": 0.08},
                  "grime": {"stamps": ["metaballs", "cloud"], "size": 22, "soft": 2, "density": 0.3, "strength": 0.3, "color": "grime"}},
        "balloon": {"base": "#c9bfae", "shadow": "#958b7c", "light": "#e4dccd", "line": "#3a3226",
                    "shade": {"highlight_amount": 0.35, "bump": 0.8}},
        "ice": {"base": "#7fb2d4", "shadow": "#40688c", "light": "#dff2ff", "line": "#0c1a28",
                "shade": {"threshold": 0.45, "highlight": 0.82, "highlight_amount": 0.85}},
        "button": {"base": "#3a3246", "shadow": "#241f2c", "light": "#524862", "line": "#0a080e",
                   "texture": {"stamp": "leaf", "pre_rot": 45, "length": 14, "width": 3, "angle": 0, "jitter": 10, "density": 0.8, "strength": 0.06}},
        "button_hot": {"base": "#4a3f5a", "shadow": "#2e2738", "light": "#6a5c80", "line": "#0a080e"},
        "button_dark": {"base": "#28222f", "shadow": "#18141c", "light": "#383040", "line": "#07050a"},
        "button_off": {"base": "#34323a", "shadow": "#222127", "light": "#46444c", "line": "#0a0a0c"},
        "fx_white": {"base": "#f4f0e8", "light": "#ffffff"},
        "fx_steel": {"base": "#d4dcec", "light": "#ffffff"},
        "fx_fire": {"base": "#ff8a2a", "light": "#ffe080"},
        "fx_fire_core": {"base": "#ffd060", "light": "#fff6c8"},
        "fx_fire_deep": {"base": "#c8401e"},
        "fx_ice": {"base": "#8fd0f0", "light": "#e8f8ff"},
        "fx_ice_deep": {"base": "#3f78a8"},
        "fx_bolt": {"base": "#f6e27a", "light": "#fffbe0"},
        "fx_bolt_core": {"base": "#fffbe6"},
        "fx_holy": {"base": "#f4dc98", "light": "#fff8e0"},
        "fx_heal": {"base": "#9ce4a8", "light": "#effff0"},
        "fx_poison": {"base": "#8ab83e", "light": "#d4f080"},
        "fx_poison_deep": {"base": "#4a6a24"},
        "fx_shadow": {"base": "#6a44a0", "light": "#b088e0"},
        "fx_void": {"base": "#1a0e24"},
        "fx_arcane": {"base": "#7a8cff", "light": "#d8e0ff"},
        "fx_wind": {"base": "#b8d8c8", "light": "#f0fff8"},
        "fx_water": {"base": "#4a90c8", "light": "#b8e4ff"},
        "fx_earth": {"base": "#7a6444", "shadow": "#4e3e2a", "light": "#a08a64", "line": "#140e08"},
        "fx_smoke": {"base": "#3e3844", "light": "#5a5262"},
        "fx_dust": {"base": "#8a7e70"},
        "fx_gold": {"base": "#f0c860", "light": "#fff0c0"},
        "fx_red": {"base": "#e04a3a", "light": "#ffb0a0"},
        "fx_blue": {"base": "#4a78e8", "light": "#b8ccff"},
        "fog": {"base": "#8c86a0"},
        "fog_dark": {"base": "#4e4860"},
        "dark_veil": {"base": "#07050a"},
        "rain": {"base": "#a0aac4"},
        "snow": {"base": "#e6e2ee"},
        "ui_panel": {"base": "#17131c"},
        "ui_panel_warm": {"base": "#1a1511"}
    },
    "styles": {
        "icon": {
            "supersample": 3, "light": [-0.42, -0.62, 0.66], "noise_cell": 7, "edge_pad": 16,
            "shade": {"soft": 0.3, "bump": 1.1, "threshold": 0.5, "edge": 0.035, "ragged": 0.16, "highlight": 0.9, "highlight_amount": 0.6},
            "line": {"width": 0.9, "heavy": 1.0, "breaks": 0.3, "junction": 0.7},
            "silhouette": {"width": 1.5, "heavy": 1.1, "color": "ink"},
            "texture": {"strength": 0.06, "density": 0.8},
            "cast": {"dist": 2.2, "blur": 1.3, "opacity": 0.5, "color": "shade_tint"},
            "shadow_output": "separate"
        },
        "ui": {
            "supersample": 2, "light": [-0.42, -0.62, 0.66], "noise_cell": 9, "edge_pad": 24,
            "shade": {"soft": 0.25, "bump": 1.0, "threshold": 0.5, "edge": 0.035, "ragged": 0.14, "highlight": 0.9, "highlight_amount": 0.5},
            "line": {"width": 1.0, "heavy": 1.1, "breaks": 0.25, "junction": 0.8},
            "silhouette": {"width": 1.4, "heavy": 1.0, "color": "ink"},
            "texture": {"strength": 0.06, "density": 0.8},
            "cast": {"dist": 2.0, "blur": 1.5, "opacity": 0.5, "color": "shade_tint"},
            "shadow_output": "separate"
        },
        "fx": {
            "supersample": 2, "light": [-0.42, -0.62, 0.66], "noise_cell": 10, "edge_pad": 48,
            "shade": {"soft": 0.3, "bump": 0.9, "threshold": 0.5, "edge": 0.04, "ragged": 0.2, "highlight": 0.9, "highlight_amount": 0.5},
            "line": {"width": 0.8, "heavy": 0.6, "breaks": 0.4, "junction": 0.5},
            "silhouette": None,
            "shadow_output": "separate"
        },
        "overlay": {
            "supersample": 1, "light": [-0.42, -0.62, 0.66], "noise_cell": 60, "edge_pad": 640,
            "shade": {"soft": 0.2, "bump": 0.6, "threshold": 0.5, "edge": 0.05, "ragged": 0.2, "highlight": 0.9, "highlight_amount": 0.3},
            "line": None,
            "silhouette": None,
            "shadow_output": "separate"
        }
    }
}


def write_palette(recipes_dir):
    """palette_g01.json = V1 palette_h0_mood.json (unchanged entries) + PALETTE_ADD."""
    rdir = Path(recipes_dir)
    base = json.loads((rdir / "palette_h0_mood.json").read_text(encoding="utf-8"))
    out = copy.deepcopy(base)
    out["id"] = "palette_g01"
    out["status"] = "candidate"
    out["source"] = ("g01 generic assets. Every V1 entry of palette_h0_mood.json is kept unchanged; "
                     "added: metals that must read on dark UI (steel, gold, silver), potion liquids, gems, food, cloth, "
                     "skill/status plate tints, effect light colours and icon/ui/fx/overlay render styles. "
                     "Added colours keep the V1 value structure: dark bodies, bone/paper as the brightest surface; "
                     "only effect light and gem highlights go brighter, as emitted light.")
    for key in ("colors", "materials", "styles"):
        for name, value in PALETTE_ADD[key].items():
            if name in out[key]:
                continue  # never override a V1 entry
            out[key][name] = copy.deepcopy(value)
    path = rdir / PALETTE
    path.write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return path
