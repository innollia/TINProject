"""mp02-npc-a-v01: NPC palette + dialogue portrait recipe generator.

    py -3 -B mp02_make_recipes.py              # write palette + every portrait recipe
    py -3 -B mp02_make_recipes.py npc_01       # only recipes whose asset id starts with npc_01

Writes ``../recipes/palette_mp02_npc.json`` (palette_h0_mood.json unchanged + the NPC
materials listed in NPC_MATERIALS) and ``../recipes/<npc_id>_portrait.json``.
Build the images with ``build.py`` as usual.

Portrait frame (author design, recorded in the docs JOB.md):
  * 320x320 transparent, 3/4 bust turned toward screen right (toward the dialogue text),
  * face anchor = point between the eyes = (168, 128) in every portrait (recorded as the
    manifest pivot), eye line y = 128, chin near y = 190, chest cut by the canvas bottom,
  * eye-level view: the 60 degree field camera is not applied to portraits.

Shapes are cuts of at-icons masks.  Faces, collars and small facial strokes are polygon
cuts of the ``square`` icon (``poly`` cut, raster.py) so their outlines can follow the
face; hair, cloth folds and props use the icons' own shapes (cloud, droplet, leaf, ...).
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
RECIPES = JOB / "recipes"
BASE_PALETTE = "palette_h0_mood.json"
PALETTE = "palette_mp02_npc.json"
CANVAS = [320, 320]
ANCHOR = [168, 128]
SQ_LO, SQ_HI = 3.0, 13.0      # the square icon is solid from 1.0 to 15.0 units
BOTTOM = 344                  # shapes that touch the chest cut run past the canvas


# ============================================================== palette
def _skin(base, shadow, light, line):
    return {"base": base, "shadow": shadow, "light": light, "line": line,
            "shade": {"threshold": 0.5, "highlight_amount": 0.35}}


def _hair(base, shadow, light, line, angle=70):
    return {"base": base, "shadow": shadow, "light": light, "line": line,
            "texture": {"stamp": "feather", "pre_rot": -45, "length": 9, "width": 2.2, "angle": angle,
                        "jitter": 25, "density": 0.9, "strength": 0.10}}


def _cloth(base, shadow, light, line, angle=88, grime=0.22, stamp="feather"):
    return {"base": base, "shadow": shadow, "light": light, "line": line,
            "texture": {"stamp": stamp, "pre_rot": -45, "length": 11, "width": 2.5, "angle": angle,
                        "jitter": 12, "density": 0.8, "strength": 0.08},
            "grime": {"stamps": ["cloud", "metaballs"], "size": 12, "soft": 1.5, "density": 0.25,
                      "strength": grime, "color": "grime"}}


NPC_COLORS = {
    "sclera": "#a89e94",
    "catchlight": "#e8dcc8",
}

NPC_MATERIALS = {
    # skin: V1 "skin" is the lightest tone; three more for variety
    "skin_warm": _skin("#c39a80", "#93705d", "#d8b59b", "#4e3129"),
    "skin_tan": _skin("#ad8261", "#7d5a42", "#c49c7a", "#3f2717"),
    "skin_deep": _skin("#7a5443", "#553a2e", "#946b5a", "#24140e"),
    # hair
    "hair_blueblack": _hair("#23263a", "#13151f", "#414862", "#06070b"),
    "hair_grey": _hair("#6c6770", "#4a4650", "#8d8891", "#1c1a1f"),
    "hair_ash": _hair("#8f8474", "#655c50", "#ada18e", "#2a241c"),
    "hair_copper": _hair("#7a3f26", "#52291a", "#9c5a38", "#220f08"),
    "hair_auburn": _hair("#4e2621", "#331614", "#6d3a31", "#170808"),
    "hair_chestnut": _hair("#4a3526", "#2f2118", "#684b36", "#140c07"),
    "hair_darkbrown": _hair("#2e2a26", "#1c1917", "#4a443e", "#0b0a09"),
    "hair_black": _hair("#25232a", "#151419", "#45424c", "#08070a"),
    "hair_white": _hair("#b3ada7", "#86807b", "#cdc8c2", "#3a3533"),
    "hair_honey": _hair("#8a6436", "#5f4323", "#aa8250", "#28190b"),
    # cloth: one identity colour per NPC (JOB.md table), V1 brightness
    "cloth_slate": _cloth("#3e4a5c", "#283242", "#56657a", "#0c1017"),
    "cloth_slate_dark": _cloth("#323d4d", "#212a37", "#475567", "#0a0d13", angle=20),
    "cloth_ash": _cloth("#4f4c4e", "#343234", "#6a6668", "#111011"),
    "cloth_ember": _cloth("#8a4a24", "#5e3016", "#b0663a", "#221006", angle=10),
    "cloth_ink": _cloth("#1f1d24", "#121116", "#35323d", "#050407"),
    "cloth_steel": _cloth("#5b5f66", "#3c3f45", "#787d85", "#141518", angle=10, grime=0.15),
    "cloth_teal": _cloth("#2f5552", "#1d3836", "#437470", "#081312"),
    "cloth_rose": _cloth("#7a5058", "#54343b", "#976a72", "#1e0e11", angle=30, stamp="leaf"),
    "cloth_brown_dark": _cloth("#3b2a24", "#261a16", "#54403a", "#0c0706"),
    "cloth_brick": _cloth("#6e3b2c", "#4a261c", "#8c5240", "#1c0c07"),
    "cloth_cream": _cloth("#9d917a", "#756b58", "#b7ab93", "#2c261d", angle=10, stamp="leaf"),
    "cloth_olive": _cloth("#4d4d2e", "#33331d", "#676741", "#111107"),
    "cloth_indigo": _cloth("#2c3558", "#1b213c", "#414c78", "#080a16"),
    "cloth_sand": _cloth("#8a7a5c", "#62563f", "#a6967a", "#231d12", angle=10),
    "cloth_oat": _cloth("#8d8270", "#655c4e", "#aa9f8c", "#25201a", stamp="leaf"),
    "cloth_sage": _cloth("#56644f", "#3a4535", "#6f7f67", "#10150e", angle=15),
    "cloth_mustard": _cloth("#8a6a28", "#5f4819", "#aa8638", "#221806"),
    "lens_glass": {"base": "#5d6b73", "shadow": "#3e4a51", "light": "#9fb0b8", "line": "#11181c",
                   "shade": {"threshold": 0.4, "highlight_amount": 0.7}},
    "water_glass": {"base": "#4f6f86", "shadow": "#324b5e", "light": "#8fb2c8", "line": "#0c161e",
                    "shade": {"threshold": 0.4, "highlight_amount": 0.75}},
}


def make_palette() -> dict:
    base = json.loads((RECIPES / BASE_PALETTE).read_text(encoding="utf-8"))
    pal = json.loads(json.dumps(base))
    pal["id"] = "palette_mp02_npc"
    pal["source"] = ("mp02-npc-a-v01: palette_h0_mood.json (V1, h0-icon-mood-v02) copied unchanged; "
                     "added NPC skin, hair, cloth and glass materials and two eye colours. "
                     "Ink, shadow, common colours and all three styles are V1 values.")
    for k, v in NPC_COLORS.items():
        assert k not in pal["colors"], k
        pal["colors"][k] = v
    for k, v in NPC_MATERIALS.items():
        assert k not in pal["materials"], k
        pal["materials"][k] = v
    return pal


# ============================================================== geometry helpers
def r2(v):
    return round(float(v), 2)


def catmull(ctrl, n=8, closed=True):
    """Catmull-Rom curve through the control points."""
    pts, m = [], len(ctrl)
    segs = range(m) if closed else range(m - 1)
    for i in segs:
        p0 = ctrl[(i - 1) % m] if closed else ctrl[max(i - 1, 0)]
        p1 = ctrl[i]
        p2 = ctrl[(i + 1) % m] if closed else ctrl[i + 1]
        p3 = ctrl[(i + 2) % m] if closed else ctrl[min(i + 2, m - 1)]
        for k in range(n):
            t = k / n
            t2, t3 = t * t, t * t * t
            pts.append(tuple(
                0.5 * (2 * p1[j] + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t2
                       + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t3) for j in (0, 1)))
    if not closed:
        pts.append(tuple(ctrl[-1]))
    return pts


def bezier(p0, p1, p2, n=14):
    out = []
    for i in range(n):
        t = i / (n - 1)
        out.append(((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
                    (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]))
    return out


def profile(n, w0, w1, w2):
    """Width along a stroke: w0 at the start, w1 in the middle, w2 at the end."""
    out = []
    for i in range(n):
        t = i / (n - 1)
        out.append(w0 * (1 - t) + w2 * t + (w1 - (w0 + w2) / 2.0) * math.sin(math.pi * t))
    return out


def stroke_outline(pts, widths):
    left, right = [], []
    for i, (x, y) in enumerate(pts):
        xa, ya = pts[max(0, i - 1)]
        xb, yb = pts[min(len(pts) - 1, i + 1)]
        dx, dy = xb - xa, yb - ya
        length = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / length, dx / length
        w = max(widths[i], 0.05) / 2.0
        left.append((x + nx * w, y + ny * w))
        right.append((x - nx * w, y - ny * w))
    return left + right[::-1]


def P(points, **kw):
    """Polygon cut of the square icon, placed in canvas px."""
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 0.5), max(y1 - y0, 0.5)
    span = SQ_HI - SQ_LO
    poly = [[round(SQ_LO + span * (x - x0) / w, 4), round(SQ_LO + span * (y - y0) / h, 4)] for x, y in points]
    piece = {"icon": "square", "poly": poly, "fit": [SQ_LO, SQ_LO, SQ_HI, SQ_HI],
             "at": [r2((x0 + x1) / 2), r2((y0 + y1) / 2)], "size": [r2(w), r2(h)]}
    piece.update(kw)
    return piece


def smooth(ctrl, n=8, **kw):
    return P(catmull(ctrl, n), **kw)


def stroke(p0, p1, p2, w0, w1, w2, n=14, **kw):
    pts = bezier(p0, p1, p2, n)
    return P(stroke_outline(pts, profile(n, w0, w1, w2)), **kw)


def I(icon, at, size, **kw):
    piece = {"icon": icon, "at": [r2(at[0]), r2(at[1])],
             "size": size if isinstance(size, (int, float)) else [r2(size[0]), r2(size[1])]}
    piece.update(kw)
    return piece


def C(at, size, **kw):
    return I("circle", at, size, **kw)


def form(name, z, pieces, kind="mass", material=None, **kw):
    f = {"name": name, "z": z, "kind": kind, "pieces": pieces}
    if material:
        f["material"] = material
    f.update(kw)
    return f


def lock(points, w0, w1, w2, n=6, **kw):
    """Tapered band along a Catmull-Rom curve (hair locks, folds, straps)."""
    pts = catmull(points, n, closed=False)
    return P(stroke_outline(pts, profile(len(pts), w0, w1, w2)), **kw)


def ring(at, outer, inner, rot=0.0):
    return [C(at, outer, rot=rot), C(at, inner, rot=rot, op="sub")]


def along(p0, p1, p2, count, size, **kw):
    return [C(pt, size, **kw) for pt in bezier(p0, p1, p2, count)]


def marks(name, z, strokes, color, opacity):
    """Thin flat strokes: wrinkles, seams, strands.  ``strokes`` = [(p0, p1, p2, w0, w1, w2), ...]."""
    return form(name, z, [stroke(*s) for s in strokes], kind="flat", color=color, opacity=opacity)


def wash(name, z, pieces, color, opacity, clip_to=None, blur=2.0):
    f = form(name, z, pieces, kind="wash", color=color, blend="multiply", opacity=opacity, blur=blur)
    if clip_to:
        f["clip_to"] = clip_to
    return f


def dashes(center, rx, ry, count, length, width, seed, flow=(0.0, -1.0), spread=25.0):
    """Short strokes scattered in an ellipse, pointing away from ``center`` + ``flow``
    (cropped hair, bristles).  Deterministic for a given seed."""
    import random
    rnd = random.Random(seed)
    out = []
    cx, cy = center
    for _ in range(count):
        a = rnd.uniform(0, 2 * math.pi)
        r = math.sqrt(rnd.uniform(0.0, 1.0))
        x, y = cx + math.cos(a) * rx * r, cy + math.sin(a) * ry * r
        dx, dy = (x - cx) / max(rx, 1) + flow[0], (y - cy) / max(ry, 1) + flow[1]
        ang = math.atan2(dy, dx) + math.radians(rnd.uniform(-spread, spread))
        ln = length * rnd.uniform(0.7, 1.3)
        p0 = (x - math.cos(ang) * ln / 2, y - math.sin(ang) * ln / 2)
        p2 = (x + math.cos(ang) * ln / 2, y + math.sin(ang) * ln / 2)
        out.append(stroke(p0, (x, y), p2, 0.3, width, 0.3, n=6))
    return out


def shift(points, dx, dy):
    return [(x + dx, y + dy) for x, y in points]


def rot_about(c, dx, dy, deg):
    t = math.radians(deg)
    return (c[0] + dx * math.cos(t) - dy * math.sin(t), c[1] + dx * math.sin(t) + dy * math.cos(t))


# ============================================================== face kit
def skin_colors(pal, skin):
    m = pal["materials"][skin]
    return m["base"], m["shadow"], m["light"], m["line"]


def head_base(pal, skin, outline, neck, ear, plane, z=7.0):
    """Face mass, near ear, neck and the big light/shadow planes.

    ``outline`` runs well up under the hair so no skin-on-skin contour shows.
    ``plane`` = (ridge, outer): the far (shadow) side polygon.  ``ridge`` runs brow ->
    nose -> mouth -> chin and is smoothed (the face's central structure line,
    PERSONAL_STYLE_CORE 1); ``outer`` closes the polygon with straight lines outside
    the face (so the smoothing cannot overshoot into the lit side).
    The face mass itself is shaded almost flat (low bump and threshold) so the plane,
    not dome noise, splits light and shadow.
    """
    base, shadow, light, line = skin_colors(pal, skin)
    face_pts = catmull(outline, 8)
    ex, ey, ew, eh, er = ear
    ridge, outer = plane
    plane_pts = catmull(ridge, 6, closed=False) + list(outer)
    return [
        form("neck", 2.0, [P(neck)], material=skin),
        form("neck_shadow", 2.5, [P(shift(face_pts, 3, 15))], kind="wash", color=shadow, blend="multiply",
             opacity=0.75, clip_to="neck", blur=2.0),
        form("ear", z - 0.2, [C((ex, ey), (ew, eh), rot=er)], material=skin),
        form("ear_inner", z - 0.15, [C((ex + 1.5, ey + 1), (ew * 0.45, eh * 0.55), rot=er)], kind="wash",
             color=shadow, blend="multiply", opacity=0.7, clip_to="ear", blur=1.0),
        form("face", z, [P(face_pts)], material=skin,
             shade={"bump": 0.55, "threshold": 0.22, "ragged": 0.05, "highlight_amount": 0.2}),
        form("face_plane", z + 0.2, [P(plane_pts)], kind="wash", color=shadow, blend="multiply",
             opacity=0.5, clip_to="face", blur=2.2),
        form("cheek_light", z + 0.3, [C((138, 150), (30, 18), rot=-12)], kind="flat", color=light,
             opacity=0.28, clip_to="face", blur=4.0),
    ]


PORTRAIT_GRIME = {"size": 26, "soft": 3.0, "density": 0.08, "strength": 0.1}


def cloth(name, z, pieces, material, **kw):
    """Portrait cloth: fewer, larger and weaker stains than the sprite-size material default,
    and a calmer light/shadow edge (``ragged`` 0.2 -> 0.07) so big folds do not read as camouflage."""
    kw.setdefault("grime", dict(PORTRAIT_GRIME))
    shade = {"ragged": 0.07}
    shade.update(kw.pop("shade", {}))
    kw["shade"] = shade
    return form(name, z, pieces, material=material, **kw)


def eye(tag, c, w, h, tilt, lid, iris, outer, skin_line, z=10.0, look=0.1):
    """One eye: almond white, iris, pupil, catchlight, lid lines.

    ``outer`` = -1 when the outer corner is on the left (near eye), +1 on the right.
    ``lid`` 0..0.5 lowers the upper lid (heavy-lidded / tired / calm look).
    ``look`` shifts the iris toward screen right (the dialogue side) by look * w.
    """
    R = ((w / 2.0) ** 2 + (h / 2.0) ** 2) / h
    a = R - h / 2.0
    cut = lid * h
    low = rot_about(c, 0.0, a + cut, tilt)      # circle whose top arc is the upper lid
    high = rot_about(c, 0.0, -a, tilt)          # circle whose bottom arc is the lower lid
    D = 2.0 * R
    d = 2.0 * a + cut
    half = math.sqrt(max(R * R - (d / 2.0) ** 2, 1.0))

    def top(x):
        return a + cut - math.sqrt(max(R * R - x * x, 0.0))

    def bot(x):
        return -a + math.sqrt(max(R * R - x * x, 0.0))

    def pt(x, y):
        return rot_about(c, x, y, tilt)

    ic = pt(w * look, h * 0.08 + cut * 0.35)
    idia = min(h * 1.08, w * 0.56)
    forms = [
        form(f"{tag}_white", z, [C(low, (D, D)), C(high, (D, D), op="clip")], kind="flat", color="sclera"),
        form(f"{tag}_iris", z + 0.1, [C(ic, (idia, idia))], kind="flat", color=iris, clip_to=f"{tag}_white"),
        form(f"{tag}_pupil", z + 0.15, [C(ic, (idia * 0.46, idia * 0.46))], kind="flat", color="eye",
             clip_to=f"{tag}_white"),
        form(f"{tag}_lidshade", z + 0.2, [C(low, (D, D)), C(pt(0, a + cut + h * 0.42), (D, D), op="sub")],
             kind="wash", color="#2a1c24", blend="multiply", opacity=0.55, clip_to=f"{tag}_white"),
        form(f"{tag}_catch", z + 0.25, [C((ic[0] - idia * 0.26, ic[1] - idia * 0.22), (idia * 0.26, idia * 0.26))],
             kind="flat", color="catchlight", opacity=0.9, clip_to=f"{tag}_white"),
    ]
    # upper lid line: inner corner thin -> outer corner thick -> short upward wing
    n = 12
    xs = [(-outer) * half + (outer * half - (-outer) * half) * i / (n - 1) for i in range(n)]
    pts = [pt(x, top(x)) for x in xs]
    wing = pt(outer * (half + w * 0.16), top(outer * half) - h * 0.2)
    pts.append(wing)
    lw = max(2.0, 0.24 * h)
    widths = profile(n, 0.8, lw, lw * 1.25) + [0.5]
    forms.append(form(f"{tag}_lid", z + 0.4, [P(stroke_outline(pts, widths))], kind="flat", color="ink"))
    # lower lid: outer two thirds, thin
    xs = [outer * half * 0.95 - outer * half * 1.25 * i / 9 for i in range(10)]
    pts = [pt(x, bot(x) + 0.6) for x in xs]
    forms.append(form(f"{tag}_lower", z + 0.35, [P(stroke_outline(pts, profile(10, 1.3, 1.0, 0.3)))],
                      kind="flat", color=skin_line, opacity=0.5))
    # crease above the lid
    xs = [-half * 0.85 + 1.7 * half * i / 9 for i in range(10)]
    pts = [pt(x, top(x) - h * 0.42 - cut * 0.5) for x in xs]
    forms.append(form(f"{tag}_crease", z + 0.3, [P(stroke_outline(pts, profile(10, 0.3, 1.0, 0.4)))],
                      kind="flat", color=skin_line, opacity=0.35))
    return forms


def socket_shadows(shadow, near, far, z=7.3):
    return [form("eye_sockets", z, [C((near[0] + 2, near[1] - 3), (34, 20)), C((far[0] - 1, far[1] - 3), (26, 18))],
                 kind="wash", color=shadow, blend="multiply", opacity=0.4, clip_to="face", blur=5.0)]


def brows(near, far, color, width=(3.2, 2.4, 0.6), z=11.0):
    """``near`` / ``far`` = (inner end, control, outer end)."""
    return [form("brow_near", z, [stroke(*near, *width)], kind="flat", color=color),
            form("brow_far", z, [stroke(*far, width[0] * 0.85, width[1] * 0.85, width[2])], kind="flat", color=color)]


def nose(bridge, tip, skin_line, light, z=9.0):
    bx, by = bridge
    tx, ty = tip
    return [
        form("nose_ridge", z, [stroke(bridge, ((bx + tx) / 2 + 1, (by + ty) / 2), tip, 0.6, 1.6, 1.1)],
             kind="flat", color=skin_line, opacity=0.55),
        form("nose_base", z + 0.1, [stroke((tx - 13, ty + 3), (tx - 5, ty + 8), (tx + 3, ty + 5), 0.6, 1.8, 0.6)],
             kind="flat", color=skin_line, opacity=0.6),
        form("nostril", z + 0.15, [C((tx - 6, ty + 5), (6, 3.2), rot=-8)], kind="flat", color=skin_line, opacity=0.8),
        form("nose_tip_light", z + 0.2, [C((tx - 5, ty - 3), (7, 4.5), rot=-20)], kind="flat", color=light,
             opacity=0.45, blur=1.0),
    ]


def mouth(left, mid, right, skin_line, light, shadow, z=9.5, open_mouth=None):
    lx, ly = left
    rx, ry = right
    mx, my = mid
    w = rx - lx
    forms = []
    if open_mouth:
        forms.append(form("mouth_open", z, [smooth(open_mouth, 6)], kind="flat", color="#2a1418"))
    forms += [
        form("mouth_line", z + 0.1, [stroke(left, mid, right, 0.8, 2.2, 0.9)], kind="flat", color=skin_line,
             opacity=0.85),
        form("lip_light", z + 0.05, [C((mx - 1, my + 5.5), (w * 0.45, 4.0))], kind="flat", color=light,
             opacity=0.35, blur=1.0, clip_to="face"),
        form("under_lip", z + 0.02, [C((mx + 2, my + 10), (w * 0.5, 5.0))], kind="wash", color=shadow,
             blend="multiply", opacity=0.35, blur=1.5, clip_to="face"),
    ]
    return forms


# ============================================================== NPC portraits
def recipe(asset, frame, seed, note, forms):
    return {
        "asset": asset,
        "status": "candidate",
        "note": note,
        "palette": PALETTE,
        "style": "sprite",
        "style_override": {"silhouette": {"edge_extend": True}},
        "canvas": CANVAS,
        "pivot": ANCHOR,
        "pivot_meaning": "face anchor: the point between the eyes, identical in every mp02 portrait",
        "seed": seed,
        "forms": forms,
        "frames": [{"name": frame}],
    }


def ilyra(pal):
    skin = "skin"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_blueblack"
    hair_line = pal["materials"][hair]["shadow"]
    outline = [(160, 58), (196, 64), (210, 96), (212, 124), (207, 151), (197, 175), (183, 193), (163, 190),
               (140, 177), (124, 153), (116, 124), (116, 88), (132, 66)]
    plane = ([(176, 98), (173, 121), (187, 151), (179, 160), (186, 172), (190, 197)],
             [(240, 205), (245, 70), (182, 70)])
    forms = []
    # --- hair behind the head: skull, bun, stylus
    forms += [
        form("hair_skull", 0.0, [C((148, 98), (136, 116))], material=hair),
        form("bun", 0.4, [C((132, 46), (60, 52), rot=-12), C((118, 58), (30, 26))], material=hair,
             shade={"highlight_amount": 0.5}),
        form("bun_lock", 0.5, [stroke((108, 60), (128, 32), (158, 40), 3.0, 7.0, 2.0)], material=hair),
        form("bun_wrap", 0.6, [stroke((110, 66), (126, 76), (152, 70), 3.0, 6.0, 3.0)], material="leather"),
        form("stylus", 0.8, [C((134, 40), (5.5, 92), rot=62)], material="bronze"),
        form("stylus_cap", 0.85, [C((95, 60), (9, 9))], material="bronze"),
    ]
    # --- robe with a high standing collar
    forms += [
        cloth("collar_back", 1.5, [smooth([(132, 196), (170, 190), (208, 198), (214, 238), (170, 244), (128, 236)])],
              "cloth_slate_dark"),
        cloth("robe", 4.0, [smooth([(134, 226), (176, 232), (212, 230), (252, 244), (288, 264), (304, BOTTOM),
                                    (18, BOTTOM), (30, 276), (76, 246)], 6)], "cloth_slate"),
        form("robe_front_seam", 4.3, [stroke((180, 244), (186, 290), (196, 330), 1.2, 2.0, 2.0)], kind="flat",
             color="coat_seam", opacity=0.8),
        form("robe_fold", 4.3, [stroke((72, 262), (86, 296), (80, 330), 0.6, 2.4, 1.0),
                                stroke((246, 262), (256, 296), (268, 330), 0.6, 2.2, 0.8)], kind="flat",
             color="coat_seam", opacity=0.55),
        cloth("collar_near", 5.0, [smooth([(128, 208), (156, 213), (178, 222), (180, 250), (150, 248), (124, 240)])],
              "cloth_slate"),
        cloth("collar_far", 5.1, [smooth([(180, 222), (198, 213), (214, 209), (218, 242), (196, 250), (182, 250)])],
              "cloth_slate_dark"),
        form("collar_edge", 5.2, [stroke((128, 208), (156, 209), (179, 223), 2.0, 3.2, 2.0),
                                  stroke((181, 223), (198, 212), (214, 209), 2.0, 3.0, 1.8)], kind="flat",
             material="paper"),
        cloth("pocket", 5.4, [smooth([(72, 294), (112, 290), (116, 330), (74, 334)])], "cloth_slate_dark"),
        form("index_cards", 5.3, [I("square", (82, 288), (15, 20), rot=-8), I("square", (95, 285), (15, 22), rot=3),
                                  I("square", (107, 289), (13, 18), rot=10)], material="paper"),
        form("card_tabs", 5.35, [I("square", (81, 278), (6, 4), rot=-8), I("square", (100, 274), (6, 4), rot=3)],
             kind="flat", color="#6b3a2e"),
        form("filing_pin", 5.6, [I("tag", (132, 262), (14, 18), rot=-30)], material="bronze"),
    ]
    # --- head
    forms += head_base(pal, skin, outline, [(148, 166), (192, 172), (194, 238), (146, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 117), (186, 151), line, light)
    forms += mouth((169, 172), (179, 174), (190, 171), line, light, shadow)
    forms += eye("eye_n", (146, 129), 24, 11, -3, 0.32, "#4a5a6a", -1, line)
    forms += eye("eye_f", (194, 127), 17, 10, 4, 0.32, "#4a5a6a", 1, line)
    forms += brows([(160, 111), (146, 104), (131, 110)], [(182, 110), (193, 105), (204, 111)], hair_line,
                   width=(2.6, 2.2, 0.5))
    # --- hair over the head: pulled back in a few big locks, hairline high on the forehead
    hair_light = pal["materials"][hair]["light"]
    forms += [
        form("hair_top", 13.0, [smooth([(213, 100), (207, 76), (190, 58), (163, 50), (134, 54), (110, 68), (94, 92),
                                        (89, 120), (97, 137), (106, 128), (112, 108), (124, 92), (146, 82),
                                        (172, 80), (193, 85), (206, 95)], 6)], material=hair,
             shade={"highlight_amount": 0.35}),
        form("hair_lock_1", 13.1, [stroke((204, 94), (176, 66), (136, 62), 5.0, 13.0, 5.0)], material=hair,
             shade={"highlight_amount": 0.55}),
        form("hair_lock_2", 13.2, [stroke((182, 84), (148, 70), (114, 80), 5.0, 12.0, 4.0)], material=hair,
             shade={"highlight_amount": 0.5}),
        form("hair_lock_3", 13.3, [stroke((152, 84), (122, 86), (102, 106), 4.0, 10.0, 3.0)], material=hair,
             shade={"highlight_amount": 0.45}),
        form("hair_strands", 13.5, [stroke((196, 86), (168, 66), (130, 66), 0.3, 1.3, 0.3),
                                    stroke((170, 80), (140, 72), (112, 86), 0.3, 1.2, 0.3)], kind="flat",
             color=hair_light, opacity=0.5),
        form("temple_strand", 13.4, [stroke((124, 100), (118, 124), (126, 150), 2.5, 3.5, 0.6)], material=hair),
    ]
    note = ("Ilyra Senn (npc_01), archive inquiry and record correction. Author design: slate-blue high-collared "
            "robe, blue-black hair pulled into a high bun pinned with a bronze stylus, blank index cards in the "
            "breast pocket, calm lowered eyes. 3/4 bust facing screen right.")
    return recipe("npc_01_ilyra_senn", "portrait_ilyra_senn", 101, note, forms)


def orrin(pal):
    skin = "skin_deep"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_grey"
    hm = pal["materials"][hair]
    outline = [(160, 58), (200, 62), (216, 94), (218, 124), (215, 152), (208, 178), (190, 198), (164, 200),
               (138, 190), (122, 168), (112, 128), (114, 88), (130, 64)]
    plane = ([(177, 98), (174, 121), (189, 153), (181, 162), (188, 176), (194, 203)],
             [(250, 212), (250, 70), (182, 70)])
    forms = [
        form("hair_skull", 0.0, [C((146, 100), (136, 110))], material=hair),
        # heavy intake smock, stand collar, the quarantine mask pulled down round the neck
        cloth("collar_back", 1.5, [smooth([(128, 200), (172, 194), (214, 202), (220, 240), (172, 246), (124, 240)])],
              "cloth_ash"),
        cloth("smock", 4.0, [smooth([(128, 228), (176, 234), (214, 232), (258, 246), (296, 268), (312, BOTTOM),
                                     (8, BOTTOM), (22, 280), (70, 248)], 6)], "cloth_ash"),
        marks("smock_seams", 4.3, [((178, 248), (184, 290), (190, 332), 1.4, 2.2, 2.2),
                                   ((66, 262), (80, 300), (76, 332), 0.6, 2.4, 1.0),
                                   ((250, 262), (262, 298), (272, 332), 0.6, 2.2, 0.8)], "coat_seam", 0.7),
        form("smock_buttons", 4.5, [C((170, 270), (7, 7)), C((174, 300), (7, 7))], material="iron"),
        cloth("collar_front", 5.0, [smooth([(126, 214), (172, 224), (214, 214), (222, 246), (174, 256), (120, 246)])],
              "cloth_ash"),
        cloth("mask", 5.5, [smooth([(136, 206), (170, 216), (208, 208), (214, 226), (174, 236), (132, 224)])],
              "cloth_cream"),
        marks("mask_folds", 5.6, [((142, 214), (172, 222), (206, 214), 0.6, 1.6, 0.6),
                                  ((140, 220), (172, 230), (208, 222), 0.4, 1.2, 0.4)], "#5a5044", 0.6),
        marks("mask_strings", 5.4, [((136, 210), (126, 190), (118, 160), 1.6, 1.6, 1.2)], "#8a7f6a", 0.9),
        cloth("armband", 5.2, [smooth([(268, 282), (300, 276), (316, 310), (284, 318)])], "cloth_ember"),
    ]
    forms += head_base(pal, skin, outline, [(140, 170), (206, 176), (212, 240), (134, 242)], (114, 142, 17, 30, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((174, 117), (189, 154), line, light)
    forms += mouth((168, 178), (180, 178), (193, 177), line, light, shadow)
    forms += eye("eye_n", (146, 129), 23, 9, 2, 0.25, "#3a2a20", -1, line)
    forms += eye("eye_f", (194, 127), 17, 8.5, -2, 0.25, "#3a2a20", 1, line)
    forms += brows([(160, 113), (146, 109), (130, 113)], [(183, 112), (194, 109), (206, 113)], "#35313a",
                   width=(4.4, 3.6, 1.2))
    forms += [
        wash("stubble", 11.5, [smooth([(124, 160), (150, 170), (168, 164), (198, 166), (214, 158), (208, 182),
                                       (190, 202), (162, 204), (134, 192)])], "#3a3033", 0.35, clip_to="face", blur=2.5),
        marks("age_lines", 11.6, [((150, 139), (144, 143), (136, 141), 0.3, 1.2, 0.3),
                                  ((190, 137), (196, 140), (202, 138), 0.3, 1.0, 0.3),
                                  ((176, 158), (168, 170), (166, 182), 0.4, 1.4, 0.4),
                                  ((150, 98), (170, 95), (192, 99), 0.3, 1.0, 0.3)], line, 0.45),
        form("hair_top", 13.0, [smooth([(216, 98), (210, 74), (192, 56), (162, 48), (132, 52), (108, 68), (96, 92),
                                        (94, 118), (102, 132), (110, 124), (114, 104), (126, 90), (146, 86),
                                        (162, 88), (178, 84), (198, 86), (211, 94)], 6)], material=hair,
             shade={"highlight_amount": 0.18}, rough={"amp": 0.5, "soft": 1.0, "cell": 4},
             line={"width": 0.7, "heavy": 0.5, "breaks": 0.55}),
        form("hairline_fuzz", 13.05, dashes((162, 90), 46, 5, 22, 6, 1.3, 23, flow=(0.0, -1.5), spread=15),
             kind="flat", color=hm["base"], opacity=0.8),
        form("hair_crop_dark", 13.2, dashes((156, 70), 50, 22, 26, 7, 1.4, 21), kind="flat", color=hm["shadow"],
             opacity=0.7, clip_to="hair_top"),
        form("hair_crop_light", 13.3, dashes((150, 64), 42, 16, 18, 6, 1.2, 22), kind="flat", color=hm["light"],
             opacity=0.6, clip_to="hair_top"),
        form("sideburn", 13.1, [lock([(114, 100), (113, 116), (117, 130)], 5, 6, 2)], material=hair,
             rough={"amp": 0.4, "soft": 1.0, "cell": 4}),
    ]
    note = ("Orrin Kest (npc_02), recovery intake examiner. Author design: broad square face, cropped grey hair, "
            "stubble, heavy brows and tired lids, ash-grey intake smock, linen quarantine mask pulled down round "
            "the neck, ember-orange quarantine band on the far arm. 3/4 bust facing screen right.")
    return recipe("npc_02_orrin_kest", "portrait_orrin_kest", 102, note, forms)


def veya(pal):
    skin = "skin"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_ash"
    hm = pal["materials"][hair]
    outline = [(160, 58), (196, 62), (211, 94), (214, 120), (209, 146), (198, 172), (184, 194), (166, 190),
               (142, 176), (124, 152), (116, 122), (116, 86), (132, 64)]
    plane = ([(176, 98), (173, 121), (187, 152), (179, 161), (186, 173), (188, 197)],
             [(240, 205), (245, 70), (182, 70)])
    forms = [
        form("hair_back", 0.0, [C((150, 104), (140, 124))], material=hair),
        form("hair_far_side", 0.5, [smooth([(206, 86), (219, 100), (221, 130), (214, 142), (209, 118)])],
             material=hair),
        # ink-black coat, sharp shoulder mantle, tall collar lined in steel grey, steel throat plate
        cloth("collar_back", 1.5, [P([(126, 180), (170, 170), (214, 180), (222, 238), (124, 238)])], "cloth_ink"),
        form("collar_back_lining", 1.6, [stroke((128, 182), (170, 168), (212, 182), 3.0, 4.0, 3.0)], kind="flat",
             material="cloth_steel"),
        cloth("coat", 4.0, [smooth([(130, 230), (176, 236), (214, 234), (260, 248), (300, 262), (314, BOTTOM),
                                    (6, BOTTOM), (18, 272), (66, 248)], 6)], "cloth_ink"),
        cloth("mantle", 4.5, [P([(126, 222), (84, 234), (40, 252), (8, 268), (40, 282), (90, 292), (140, 300),
                                 (178, 304), (216, 298), (264, 288), (306, 278), (314, 262), (278, 244), (222, 228)])],
              "cloth_ink"),
        marks("mantle_edge", 4.6, [((14, 270), (90, 292), (178, 303), 1.0, 2.0, 1.4),
                                   ((180, 303), (250, 292), (310, 266), 1.4, 2.0, 1.0)], "#5b5f66", 0.9),
        cloth("collar_near", 5.0, [P([(126, 196), (160, 206), (178, 216), (178, 250), (128, 246)])], "cloth_ink"),
        cloth("collar_far", 5.1, [P([(180, 216), (200, 204), (218, 196), (222, 246), (182, 250)])], "cloth_ink"),
        marks("collar_lining", 5.2, [((126, 196), (156, 204), (177, 216), 2.4, 3.0, 2.0),
                                     ((181, 216), (200, 204), (218, 196), 2.0, 2.8, 2.2)], "#5b5f66", 1.0),
        form("throat_plate", 5.05, [I("shield", (179, 216), (14, 18))], material="iron"),
    ]
    forms += head_base(pal, skin, outline, [(148, 166), (190, 172), (194, 236), (146, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += [wash("cheek_hollow", 7.35, [C((138, 166), (24, 12), rot=-20)], shadow, 0.3, clip_to="face", blur=4.0)]
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 116), (188, 153), line, light)
    forms += mouth((168, 175), (179, 174), (191, 174), line, light, shadow)
    forms += eye("eye_n", (146, 129), 25, 9, -6, 0.1, "#6a6e72", -1, line)
    forms += eye("eye_f", (194, 127), 18, 8, 6, 0.1, "#6a6e72", 1, line)
    forms += brows([(160, 114), (146, 109), (130, 108)], [(182, 113), (193, 108), (205, 107)], hm["line"],
                   width=(3.0, 2.6, 0.8))
    forms += [
        # asymmetric bob: long on her right (the near side, covering the ear), short on the far side.
        # Built from a crown, a near-side curtain with a crisp angled hem, locks and a swept fringe.
        form("bob_crown", 13.0, [smooth([(214, 100), (208, 76), (190, 58), (162, 50), (132, 54), (110, 68),
                                         (96, 94), (94, 118), (104, 110), (120, 96), (142, 88), (170, 84),
                                         (192, 88), (206, 98)], 6)], material=hair, shade={"highlight_amount": 0.25}),
        form("bob_curtain", 13.1, [P(catmull([(88, 150), (90, 112), (100, 90), (116, 84), (130, 96)], 6, closed=False)
                                     + [(134, 124), (137, 152), (140, 180), (92, 188)])], material=hair,
             shade={"highlight_amount": 0.2}),
        form("bob_lock_1", 13.2, [lock([(120, 90), (114, 132), (118, 182)], 6, 10, 5)], material=hair,
             shade={"highlight_amount": 0.55}),
        form("bob_lock_2", 13.25, [lock([(104, 96), (97, 138), (100, 186)], 5, 9, 5)], material=hair,
             shade={"highlight_amount": 0.45}),
        form("bob_lock_3", 13.3, [lock([(130, 100), (131, 140), (136, 180)], 4, 8, 4)], material=hair,
             shade={"highlight_amount": 0.4}),
        form("fringe", 13.4, [P(catmull([(206, 98), (196, 84), (170, 79), (146, 85), (128, 98), (119, 118)], 6,
                                        closed=False) + [(133, 108), (152, 98), (174, 93), (193, 96)])],
             material=hair, shade={"highlight_amount": 0.6}),
        form("bob_strands", 13.5, [stroke((114, 96), (106, 136), (110, 180), 0.3, 1.2, 0.3),
                                   stroke((126, 100), (124, 140), (128, 178), 0.3, 1.0, 0.3),
                                   stroke((198, 90), (166, 84), (136, 100), 0.3, 1.2, 0.3),
                                   stroke((186, 94), (160, 92), (140, 104), 0.3, 1.0, 0.3)], kind="flat",
             color=hm["light"], opacity=0.55),
        marks("bob_shadow_lines", 13.45, [((110, 94), (100, 136), (104, 184), 0.3, 1.4, 0.3),
                                          ((132, 104), (132, 142), (137, 178), 0.3, 1.2, 0.3)], hm["line"], 0.6),
    ]
    note = ("Veya Morcant (npc_03), audit officer. Author design: angular face, sharp narrow eyes and stern "
            "straight brows, ash-blonde asymmetric bob (longer on her right), ink-black coat with a sharp shoulder "
            "mantle, tall collar lined in steel grey, small steel throat plate (first hint of the voice implant). "
            "3/4 bust facing screen right.")
    return recipe("npc_03_veya_morcant", "portrait_veya_morcant", 103, note, forms)


def sable(pal):
    skin = "skin_tan"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_copper"
    hm = pal["materials"][hair]
    outline = [(160, 58), (198, 62), (212, 94), (214, 122), (210, 150), (200, 174), (184, 192), (164, 190),
               (142, 180), (124, 158), (116, 126), (116, 88), (132, 64)]
    plane = ([(176, 98), (173, 121), (186, 150), (179, 158), (186, 170), (190, 195)],
             [(240, 205), (245, 70), (182, 70)])
    forms = [
        form("hair_skull", 0.0, [C((148, 98), (136, 114))], material=hair),
        # high ponytail gathered at the crown, falling behind the near shoulder
        form("ponytail", 0.3, [lock([(126, 50), (96, 60), (80, 100), (82, 150), (70, 196)], 16, 26, 6)],
             material=hair, shade={"highlight_amount": 0.6}),
        form("ponytail_lock", 0.35, [lock([(118, 56), (100, 84), (98, 130), (90, 176)], 6, 10, 3)],
             material=hair, shade={"highlight_amount": 0.7}),
        form("hair_tie", 0.4, [C((124, 52), (18, 16), rot=-30)], material="leather"),
        # teal work jacket, rolled collar, dark undershirt, leather braces, a wrench in the chest pocket
        cloth("jacket", 4.0, [smooth([(130, 228), (176, 234), (214, 230), (256, 244), (294, 264), (310, BOTTOM),
                                      (10, BOTTOM), (22, 276), (70, 246)], 6)], "cloth_teal"),
        cloth("undershirt", 4.2, [smooth([(150, 224), (180, 232), (204, 226), (198, 262), (179, 282), (160, 262)])],
              "cloth_brown_dark"),
        cloth("collar_roll", 4.6, [lock([(128, 222), (150, 234), (170, 250), (178, 270)], 12, 14, 6),
                                   lock([(216, 222), (206, 240), (192, 256), (182, 272)], 10, 12, 5)], "cloth_teal",
              shade={"highlight_amount": 0.6}),
        form("brace_near", 5.5, [lock([(96, 242), (100, 290), (104, BOTTOM)], 11, 11, 11)], material="leather"),
        form("brace_far", 5.5, [lock([(240, 244), (244, 290), (250, BOTTOM)], 9, 9, 9)], material="leather"),
        form("brace_buckles", 5.6, [I("square", (100, 286), (12, 10)), I("square", (244, 288), (10, 9))],
             material="bronze"),
        cloth("chest_pocket", 5.3, [smooth([(212, 292), (254, 290), (258, 334), (214, 336)])], "cloth_teal"),
        form("pocket_wrench", 5.2, [I("wrench", (232, 282), (14, 34), rot=12)], material="iron"),
    ]
    forms += head_base(pal, skin, outline, [(148, 166), (192, 172), (196, 236), (144, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += [wash("grease_smudge", 7.4, [smooth([(126, 156), (140, 150), (150, 156), (138, 162)])], "#3a2a22", 0.4,
                   clip_to="face", blur=1.5)]
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 117), (185, 149), line, light)
    forms += mouth((168, 171), (179, 174), (191, 168), line, light, shadow)
    forms += eye("eye_n", (146, 129), 23, 12, -2, 0.05, "#6a4a26", -1, line)
    forms += eye("eye_f", (194, 127), 17, 11, 3, 0.05, "#6a4a26", 1, line)
    forms += brows([(160, 110), (146, 103), (131, 108)], [(182, 108), (193, 103), (204, 108)], hm["shadow"],
                   width=(2.8, 2.4, 0.6))
    forms += [
        form("hair_top", 13.0, [smooth([(214, 100), (208, 76), (190, 58), (162, 50), (132, 54), (110, 68), (96, 92),
                                        (92, 118), (100, 132), (110, 122), (116, 102), (130, 90), (150, 86),
                                        (172, 84), (192, 88), (206, 98)], 6)], material=hair,
             shade={"highlight_amount": 0.4}),
        form("hair_pulled", 13.1, [lock([(200, 90), (170, 66), (130, 58)], 4, 10, 4),
                                   lock([(160, 86), (134, 72), (116, 66)], 3, 8, 3)], material=hair,
             shade={"highlight_amount": 0.6}),
        form("bangs", 13.3, [I("droplet", (150, 94), (13, 26), flip="y", rot=12),
                             I("droplet", (168, 92), (12, 24), flip="y", rot=4),
                             I("droplet", (188, 96), (10, 20), flip="y", rot=-12),
                             I("droplet", (122, 104), (10, 24), flip="y", rot=18)], material=hair,
             shade={"highlight_amount": 0.5}),
        # goggles pushed up onto the hair: strap, two frames, glass
        form("goggle_strap", 13.6, [lock([(94, 100), (120, 74), (160, 66), (200, 70), (214, 88)], 5, 7, 5)],
             material="leather"),
        form("goggle_frame", 13.7, ring((148, 76), (30, 24), (22, 17)) + ring((190, 76), (24, 23), (17, 16)) +
             [stroke((163, 76), (169, 73), (178, 76), 3.0, 3.0, 3.0)], material="iron"),
        form("goggle_glass", 13.65, [C((148, 76), (23, 18)), C((190, 76), (18, 17))], material="lens_glass"),
    ]
    note = ("Sable Halm (npc_04), transformation support operator. Author design: copper-red hair in a high "
            "ponytail, work goggles pushed up on the hair, grease smudge on the cheek, confident half smile, teal "
            "work jacket with rolled collar and leather braces, a wrench in the chest pocket. 3/4 bust facing "
            "screen right.")
    return recipe("npc_04_sable_halm", "portrait_sable_halm", 104, note, forms)


def nera(pal):
    skin = "skin_warm"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_auburn"
    hm = pal["materials"][hair]
    outline = [(160, 58), (198, 62), (213, 94), (216, 122), (213, 150), (204, 176), (186, 195), (164, 194),
               (140, 182), (122, 160), (114, 126), (116, 88), (132, 64)]
    plane = ([(176, 98), (173, 121), (186, 151), (179, 160), (187, 172), (192, 198)],
             [(242, 208), (245, 70), (182, 70)])
    forms = [
        form("hair_back", 0.0, [smooth([(98, 84), (128, 50), (178, 44), (214, 64), (230, 106), (234, 160),
                                        (228, 214), (206, 222), (204, 170), (200, 120), (150, 96), (108, 120)])],
             material=hair),
        form("hair_far_fall", 0.5, [lock([(208, 92), (227, 132), (213, 178), (233, 224)], 14, 22, 3),
                                    lock([(214, 100), (232, 140), (226, 190), (238, 214)], 8, 12, 2)],
             material=hair, shade={"highlight_amount": 0.5}),
        # dark brown dress, dusty rose shawl draped over both shoulders, bronze ledger chain
        cloth("dress", 4.0, [smooth([(130, 228), (176, 234), (214, 232), (258, 246), (298, 266), (312, BOTTOM),
                                     (8, BOTTOM), (20, 276), (68, 246)], 6)], "cloth_brown_dark"),
        cloth("shawl", 4.6, [smooth([(118, 226), (150, 244), (172, 256), (196, 250), (220, 232), (262, 240),
                                     (306, 264), (318, BOTTOM), (2, BOTTOM), (10, 272), (58, 240)], 6)], "cloth_rose"),
        cloth("shawl_wrap", 4.8, [lock([(222, 236), (204, 262), (184, 300), (174, BOTTOM)], 14, 26, 30)],
              "cloth_rose", shade={"highlight_amount": 0.55}),
        marks("shawl_folds", 4.9, [((60, 254), (78, 292), (72, 334), 0.6, 2.4, 1.0),
                                   ((262, 252), (270, 290), (284, 334), 0.6, 2.2, 0.8),
                                   ((186, 262), (178, 296), (170, 334), 0.6, 2.0, 0.8)], "#3a2226", 0.6),
        form("ledger_chain", 5.4, along((204, 268), (230, 300), (262, 336), 13, (6, 4.5), rot=40),
             material="bronze"),
        form("brooch", 5.5, [C((150, 250), (14, 14)), C((150, 250), (7, 7), op="sub")], material="bronze"),
    ]
    forms += head_base(pal, skin, outline, [(146, 166), (194, 172), (198, 236), (142, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 117), (186, 151), line, light)
    forms += mouth((167, 172), (179, 176), (192, 170), line, light, shadow)
    forms += [form("lip_full", 9.52, [C((179, 179), (18, 5))], kind="flat", color="#9a6a62", opacity=0.45,
                   blur=1.0, clip_to="face")]
    forms += eye("eye_n", (146, 129), 24, 11, -2, 0.35, "#3e4030", -1, line)
    forms += eye("eye_f", (194, 127), 17, 10, 3, 0.35, "#3e4030", 1, line)
    forms += brows([(160, 110), (146, 104), (131, 109)], [(182, 109), (193, 104), (204, 109)], hm["shadow"],
                   width=(2.6, 2.2, 0.5))
    forms += [
        form("hair_top", 13.0, [smooth([(214, 100), (208, 76), (190, 58), (162, 50), (134, 54), (110, 68), (96, 92),
                                        (92, 120), (100, 138), (112, 128), (118, 106), (132, 94), (150, 90),
                                        (166, 84), (188, 90), (206, 100)], 6)], material=hair,
             shade={"highlight_amount": 0.35}),
        form("hair_part_locks", 13.1, [lock([(166, 84), (140, 74), (112, 90)], 4, 12, 5),
                                       lock([(168, 84), (192, 76), (210, 96)], 4, 10, 4)], material=hair,
             shade={"highlight_amount": 0.6}),
        # long wavy hair falling over her right (near) shoulder, in front of the shawl
        form("hair_near_under", 13.35, [lock([(104, 104), (86, 150), (102, 200), (84, 248), (94, 290)], 10, 17, 2)],
             material=hair, shade={"highlight_amount": 0.35}),
        form("hair_near_fall", 13.4, [lock([(112, 96), (95, 140), (114, 186), (93, 236), (112, 296)], 18, 30, 3)],
             material=hair, shade={"highlight_amount": 0.45}),
        form("hair_near_wave", 13.5, [lock([(124, 108), (113, 152), (132, 198), (113, 246), (136, 292)], 10, 18, 2)],
             material=hair, shade={"highlight_amount": 0.6}),
        form("hair_strands", 13.6, [stroke((110, 110), (96, 170), (110, 230), 0.3, 1.3, 0.3),
                                    stroke((122, 120), (120, 190), (126, 260), 0.3, 1.2, 0.3)], kind="flat",
             color=hm["light"], opacity=0.5),
    ]
    note = ("Nera Voss (npc_05), organ custody broker and keeper of the kiln ledger. Author design: soft full "
            "face, heavy-lidded calm eyes, half smile, long wavy auburn hair over her right shoulder, dusty rose "
            "shawl over a dark brown dress, bronze brooch and the ledger chain. 3/4 bust facing screen right.")
    return recipe("npc_05_nera_voss", "portrait_nera_voss", 105, note, forms)


def tamas(pal):
    skin = "skin_tan"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_chestnut"
    hm = pal["materials"][hair]
    outline = [(160, 58), (196, 62), (210, 94), (212, 122), (207, 150), (197, 176), (183, 196), (163, 193),
               (140, 180), (124, 156), (116, 124), (116, 88), (132, 64)]
    plane = ([(176, 98), (173, 120), (187, 152), (179, 161), (186, 173), (190, 198)],
             [(240, 206), (245, 70), (182, 70)])
    forms = [
        form("hair_skull", 0.0, [C((148, 98), (136, 114))], material=hair),
        # brick coat with lapels, cream cravat, leather strap of the scroll case across the chest
        cloth("coat", 4.0, [smooth([(130, 228), (176, 234), (214, 230), (256, 244), (294, 264), (310, BOTTOM),
                                    (10, BOTTOM), (22, 276), (70, 246)], 6)], "cloth_brick"),
        cloth("lapel_near", 5.0, [P([(132, 224), (170, 244), (162, 302), (122, 256)])], "cloth_brick",
              shade={"highlight_amount": 0.6}),
        cloth("lapel_far", 5.0, [P([(210, 226), (190, 246), (206, 300), (232, 256)])], "cloth_brick",
              shade={"threshold": 0.62}),
        cloth("cravat", 5.2, [smooth([(150, 220), (180, 230), (204, 222), (198, 252), (180, 270), (162, 252)])],
              "cloth_cream"),
        cloth("cravat_knot", 5.3, [C((179, 238), (18, 15))], "cloth_cream", shade={"highlight_amount": 0.6}),
        form("case_strap", 5.6, [lock([(246, 236), (212, 262), (170, 296), (116, BOTTOM)], 9, 9, 9)],
             material="leather"),
        form("strap_buckle", 5.7, [I("square", (190, 280), (12, 10), rot=-38)], material="bronze"),
    ]
    forms += head_base(pal, skin, outline, [(148, 166), (192, 172), (196, 236), (144, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 116), (187, 152), line, light)
    forms += mouth((169, 174), (179, 174), (190, 172), line, light, shadow)
    forms += eye("eye_n", (146, 129), 22, 10.5, 3, 0.15, "#5a4a2e", -1, line)
    forms += eye("eye_f", (194, 127), 16, 10, -3, 0.15, "#5a4a2e", 1, line)
    # worried brows: inner ends raised
    forms += brows([(159, 106), (146, 106), (132, 112)], [(183, 105), (193, 106), (204, 111)], hm["shadow"],
                   width=(2.8, 2.2, 0.6))
    forms += [
        form("hair_top", 13.0, [smooth([(214, 100), (208, 74), (190, 56), (162, 48), (132, 52), (108, 66), (94, 90),
                                        (90, 118), (98, 136), (110, 126), (116, 104), (130, 92), (150, 88),
                                        (170, 86), (192, 90), (208, 100)], 6)], material=hair,
             shade={"highlight_amount": 0.35}),
        form("fringe_locks", 13.2, [lock([(170, 62), (160, 84), (151, 106)], 6, 12, 2),
                                    lock([(191, 68), (187, 88), (181, 105)], 5, 10, 2),
                                    lock([(150, 62), (135, 84), (126, 106)], 5, 11, 2),
                                    lock([(207, 80), (207, 95), (201, 107)], 4, 8, 1.5)], material=hair,
             shade={"highlight_amount": 0.55}),
        form("tufts", 13.1, [lock([(118, 72), (150, 52), (192, 58)], 6, 10, 3),
                             lock([(160, 54), (176, 45), (192, 48)], 3, 6, 1.5)], material=hair,
             shade={"highlight_amount": 0.6}),
        # bronze translation earpiece on the near (right) ear with a wire into the hair
        form("earpiece", 13.8, [C((118, 146), (11, 13)), I("square", (118, 156), (5, 8))], material="bronze"),
        marks("earpiece_wire", 13.75, [((118, 140), (122, 118), (130, 104), 1.4, 1.4, 1.0)], "#74603f", 1.0),
        # quill tucked behind the ear
        form("quill", 13.6, [I("feather", (104, 112), (18, 54), rot=-24)], material="paper"),
        # round spectacles
        form("glass_tint", 14.0, [C((146, 129), (30, 26)), C((194, 127), (21, 24))], kind="flat",
             material="lens_glass", opacity=0.18),
        form("glass_frames", 14.1, ring((146, 129), (34, 30), (29, 25)) + ring((194, 127), (25, 28), (20, 23)) +
             [stroke((163, 126), (171, 122), (181, 125), 1.8, 1.8, 1.8),
              stroke((129, 128), (122, 130), (115, 135), 1.8, 1.6, 1.2)], kind="flat", color="#2a2228"),
        form("glass_glint", 14.2, [stroke((136, 121), (140, 118), (146, 117), 0.4, 1.6, 0.4),
                                   stroke((188, 119), (191, 117), (195, 117), 0.4, 1.2, 0.4)], kind="flat",
             color="catchlight", opacity=0.7),
    ]
    note = ("Tamas Quill (npc_06), translation officer. Author design: slim face, gentle worried brows, round "
            "spectacles, tousled chestnut hair, quill tucked behind the ear, small bronze translation earpiece on "
            "the right ear (first hint of the neural translation implant), brick coat with a cream cravat and the "
            "scroll-case strap. 3/4 bust facing screen right.")
    return recipe("npc_06_tamas_quill", "portrait_tamas_quill", 106, note, forms)


def bryn(pal):
    skin = "skin_tan"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_darkbrown"
    hm = pal["materials"][hair]
    grey = pal["materials"]["hair_grey"]["light"]
    outline = [(160, 58), (200, 62), (214, 94), (216, 122), (212, 150), (204, 176), (188, 198), (164, 198),
               (138, 186), (122, 162), (114, 126), (116, 88), (132, 64)]
    plane = ([(177, 98), (174, 120), (190, 155), (181, 163), (188, 176), (194, 202)],
             [(248, 212), (248, 70), (182, 70)])
    forms = [
        # olive hood: back mass behind the head, cowl round the neck, front rim framing the face
        cloth("hood_back", 0.0, [smooth([(80, 112), (94, 58), (138, 26), (196, 26), (236, 58), (250, 118),
                                         (246, 190), (232, 236), (94, 236), (78, 182)])], "cloth_olive"),
        cloth("cloak", 4.0, [smooth([(126, 226), (176, 236), (218, 230), (262, 244), (300, 266), (314, BOTTOM),
                                     (6, BOTTOM), (18, 276), (66, 246)], 6)], "cloth_olive"),
        cloth("cowl", 4.6, [smooth([(108, 196), (150, 224), (198, 230), (230, 204), (240, 240), (198, 264),
                                    (148, 264), (100, 242)])], "cloth_olive", shade={"highlight_amount": 0.55}),
        form("pack_strap_near", 5.5, [lock([(80, 250), (92, 292), (98, BOTTOM)], 12, 13, 13)], material="leather"),
        form("pack_strap_far", 5.5, [lock([(250, 248), (262, 292), (266, BOTTOM)], 10, 11, 11)], material="leather"),
        form("rope_coil", 5.7, ring((272, 262), (58, 34), (40, 20), rot=-12) + ring((262, 270), (50, 30), (34, 17),
                                                                                    rot=-8),
             material="cloth_sand", shade={"highlight_amount": 0.5}),
        marks("rope_twist", 5.8, [((250, 252), (272, 246), (296, 256), 0.4, 1.4, 0.4),
                                  ((244, 262), (262, 258), (284, 268), 0.4, 1.2, 0.4)], "#4a4030", 0.7),
    ]
    forms += head_base(pal, skin, outline, [(140, 170), (206, 176), (212, 240), (134, 242)], (116, 142, 16, 30, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((174, 116), (190, 155), line, light)
    forms += eye("eye_n", (146, 129), 22, 9, 0, 0.2, "#505458", -1, line)
    forms += eye("eye_f", (194, 127), 16, 8.5, 0, 0.2, "#505458", 1, line)
    forms += brows([(160, 113), (146, 108), (130, 111)], [(183, 112), (194, 108), (206, 111)], hm["base"],
                   width=(4.0, 3.4, 1.0))
    forms += [
        marks("weather_lines", 11.6, [((132, 131), (126, 128), (121, 124), 0.3, 1.1, 0.3),
                                      ((133, 136), (127, 136), (122, 134), 0.3, 1.0, 0.3),
                                      ((150, 140), (144, 144), (136, 142), 0.3, 1.1, 0.3),
                                      ((178, 158), (170, 168), (168, 176), 0.4, 1.4, 0.4)], line, 0.45),
        # full beard with grey streaks, moustache over the mouth
        form("beard", 12.0, [smooth([(122, 158), (136, 170), (152, 174), (168, 168), (184, 168), (200, 170),
                                     (212, 156), (214, 174), (206, 196), (190, 214), (166, 218), (142, 208),
                                     (126, 186)])], material=hair, rough={"amp": 0.35, "soft": 1.0, "cell": 5},
             shade={"highlight_amount": 0.4}),
        form("moustache", 12.2, [lock([(160, 172), (170, 166), (182, 165), (194, 168), (202, 176)], 3, 8, 2)],
             material=hair, shade={"highlight_amount": 0.5}),
        form("mouth_gap", 12.25, [stroke((170, 180), (181, 181), (193, 179), 0.8, 2.2, 0.8)], kind="flat",
             color="#241810", opacity=0.9),
        form("beard_grey", 12.3, dashes((170, 196), 34, 14, 16, 8, 1.3, 71, flow=(0.0, 1.0)), kind="flat",
             color=grey, opacity=0.6, clip_to="beard"),
        form("beard_dark", 12.35, dashes((168, 192), 38, 16, 18, 8, 1.4, 72, flow=(0.0, 1.0)), kind="flat",
             color=hm["shadow"], opacity=0.7, clip_to="beard"),
        # lens device over his left (far) eye
        form("lens_strap", 13.9, [lock([(207, 124), (214, 120), (222, 118)], 2.6, 2.6, 2.2)], material="leather"),
        form("lens_glass", 14.0, [C((194, 127), (20, 18))], material="lens_glass", opacity=0.72),
        form("lens_ring", 14.1, ring((194, 127), (27, 25), (20, 18)), material="iron"),
        # hood rim framing the face (drawn over hair and ear)
        cloth("hood_rim", 13.0, [smooth([(100, 196), (92, 130), (102, 76), (134, 42), (180, 36), (218, 54),
                                         (236, 96), (240, 152), (232, 200), (216, 204), (218, 160), (214, 110),
                                         (202, 82), (178, 68), (150, 68), (126, 80), (114, 106), (110, 150),
                                         (114, 196)], 6)], "cloth_olive", shade={"highlight_amount": 0.5}),
        wash("hood_shadow", 13.05, [smooth([(118, 104), (132, 80), (160, 70), (196, 76), (214, 96), (212, 112),
                                            (190, 94), (160, 88), (132, 98), (122, 120)])], "#1a1c10", 0.55,
             clip_to="face", blur=4.0),
    ]
    note = ("Bryn Oskel (npc_07), frontier guide. Author design: weathered face under an olive hood, full dark beard "
            "with grey streaks, heavy brows, a small iron-rimmed lens over his left eye (first hint of the sensory "
            "change), pack straps and a rope coil on the far shoulder. 3/4 bust facing screen right.")
    return recipe("npc_07_bryn_oskel", "portrait_bryn_oskel", 107, note, forms)


def meral(pal):
    skin = "skin_deep"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_black"
    hm = pal["materials"][hair]
    grey = pal["materials"]["hair_grey"]["light"]
    outline = [(160, 58), (198, 62), (213, 94), (216, 122), (213, 150), (206, 176), (190, 196), (166, 198),
               (140, 186), (122, 162), (114, 126), (116, 88), (132, 64)]
    plane = ([(177, 98), (174, 121), (188, 153), (180, 162), (188, 175), (193, 201)],
             [(248, 210), (248, 70), (182, 70)])
    forms = [
        # headwrap knot and tails behind the head
        cloth("wrap_knot", 0.5, [C((108, 54), (40, 32), rot=-20), C((92, 66), (24, 20))], "cloth_indigo",
              shade={"highlight_amount": 0.55}),
        cloth("wrap_tails", 0.4, [lock([(100, 66), (84, 96), (80, 140)], 12, 14, 5),
                                  lock([(92, 70), (70, 100), (62, 128)], 9, 11, 4)], "cloth_indigo"),
        form("hair_back", 0.2, [C((146, 104), (130, 110))], material=hair),
        # indigo dress, sand shawl, cord with a water-glass drop
        cloth("dress", 4.0, [smooth([(128, 228), (176, 234), (214, 232), (258, 246), (298, 266), (312, BOTTOM),
                                     (8, BOTTOM), (20, 278), (68, 248)], 6)], "cloth_indigo"),
        cloth("shawl", 4.6, [smooth([(112, 234), (150, 256), (174, 290), (196, 258), (222, 238), (266, 248),
                                     (304, 272), (316, BOTTOM), (4, BOTTOM), (14, 282), (56, 250)], 6)], "cloth_sand"),
        marks("shawl_folds", 4.8, [((58, 262), (72, 298), (66, 334), 0.6, 2.4, 1.0),
                                   ((264, 262), (274, 296), (286, 334), 0.6, 2.2, 0.8),
                                   ((132, 262), (150, 286), (160, 320), 0.5, 1.8, 0.8)], "#3e3526", 0.55),
        marks("pendant_cord", 5.4, [((150, 226), (160, 250), (174, 268), 1.3, 1.3, 1.3),
                                    ((204, 228), (192, 250), (178, 268), 1.3, 1.3, 1.3)], "#4f3b2f", 1.0),
        form("pendant", 5.5, [I("droplet", (176, 280), (15, 22))], material="water_glass"),
    ]
    forms += head_base(pal, skin, outline, [(140, 170), (206, 176), (212, 240), (134, 242)], (115, 142, 16, 29, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((174, 117), (188, 153), line, light)
    forms += [form("nose_wing", 9.05, [C((170, 156), (10, 8)), C((192, 154), (8, 7))], kind="flat", color=shadow,
                   opacity=0.35, blur=1.0, clip_to="face")]
    forms += mouth((167, 176), (180, 177), (193, 176), line, light, shadow)
    forms += eye("eye_n", (146, 129), 23, 10, 0, 0.12, "#2e1f18", -1, line)
    forms += eye("eye_f", (194, 127), 17, 9.5, 0, 0.12, "#2e1f18", 1, line)
    forms += brows([(160, 112), (146, 110), (130, 111)], [(182, 111), (194, 109), (206, 111)], hm["base"],
                   width=(3.4, 3.0, 0.8))
    forms += [
        marks("age_lines", 11.6, [((177, 158), (169, 170), (167, 182), 0.4, 1.4, 0.4),
                                  ((150, 140), (144, 143), (137, 141), 0.3, 1.1, 0.3),
                                  ((190, 138), (196, 141), (202, 139), 0.3, 1.0, 0.3)], line, 0.4),
        # grey-streaked strands escaping the wrap at the near temple
        form("temple_hair", 12.8, [lock([(118, 94), (111, 114), (116, 136)], 5, 7, 1.5)], material=hair),
        marks("temple_grey", 12.9, [((120, 96), (113, 114), (117, 132), 0.3, 1.2, 0.3)], grey, 0.8),
        # indigo headwrap covering the hair, folds running round the head
        cloth("headwrap", 13.0, [smooth([(216, 104), (212, 78), (196, 58), (166, 46), (134, 48), (108, 62), (92, 86),
                                         (88, 116), (98, 136), (108, 126), (112, 106), (124, 92), (146, 86),
                                         (172, 83), (196, 88), (210, 100)], 6)], "cloth_indigo",
              shade={"highlight_amount": 0.45}),
        cloth("wrap_band", 13.2, [lock([(212, 96), (184, 80), (150, 78), (118, 90), (100, 112)], 6, 14, 8)],
              "cloth_indigo", shade={"highlight_amount": 0.6}),
        marks("wrap_folds", 13.3, [((200, 66), (168, 56), (130, 62), 0.4, 1.8, 0.4),
                                   ((206, 82), (166, 68), (116, 76), 0.4, 1.6, 0.4),
                                   ((150, 50), (128, 60), (104, 80), 0.4, 1.4, 0.4)], "#0e1224", 0.65),
    ]
    note = ("Meral Dune (npc_08), water and seed broker. Author design: strong jaw, straight brows and a firm "
            "mouth, indigo headwrap with a knot at the back and grey-streaked hair escaping at the temple, sand "
            "shawl over an indigo dress, a water-glass drop on a cord. 3/4 bust facing screen right.")
    return recipe("npc_08_meral_dune", "portrait_meral_dune", 108, note, forms)


def perrin(pal):
    skin = "skin_warm"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_white"
    hm = pal["materials"][hair]
    # balding: the face outline includes the bare crown
    outline = [(162, 44), (198, 50), (214, 86), (217, 122), (214, 152), (206, 178), (188, 196), (164, 196),
               (140, 186), (122, 164), (114, 128), (112, 84), (128, 54)]
    plane = ([(206, 54), (192, 80), (177, 100), (174, 121), (189, 156), (181, 165), (187, 175), (193, 200)],
             [(250, 210), (250, 36), (214, 36)])
    forms = [
        form("hair_back", 0.0, [smooth([(96, 96), (108, 72), (124, 68), (130, 100), (128, 142), (118, 162),
                                        (100, 152), (92, 124)])], material=hair, shade={"highlight_amount": 0.45}),
        # oat cardigan, sage scarf, bronze bell on a cord, wooden name tags
        cloth("cardigan", 4.0, [smooth([(128, 222), (176, 230), (214, 226), (256, 240), (296, 262), (312, BOTTOM),
                                        (8, BOTTOM), (20, 272), (66, 240)], 6)], "cloth_oat"),
        marks("cardigan_edges", 4.3, [((160, 244), (164, 290), (160, 334), 1.2, 2.2, 2.2),
                                      ((210, 240), (214, 290), (222, 334), 1.0, 2.0, 2.0)], "coat_seam", 0.7),
        form("cardigan_buttons", 4.5, [C((166, 282), (8, 8)), C((166, 310), (8, 8))], material="wood"),
        cloth("scarf", 5.0, [smooth([(128, 206), (170, 220), (212, 210), (222, 234), (172, 250), (120, 234)])],
              "cloth_sage", shade={"highlight_amount": 0.5}),
        cloth("scarf_tail", 5.1, [lock([(198, 232), (206, 272), (200, 312), (206, BOTTOM)], 16, 16, 12)],
              "cloth_sage"),
        marks("bell_cord", 5.4, [((150, 232), (158, 262), (166, 282), 1.4, 1.4, 1.4)], "#4f3b2f", 1.0),
        form("bell", 5.5, [I("bell", (166, 294), (20, 22))], material="bronze"),
        form("name_tags", 5.45, [I("tag", (244, 290), (16, 22), rot=-20), I("tag", (258, 300), (14, 20), rot=10)],
             material="wood"),
        marks("tag_strings", 5.4, [((236, 270), (240, 280), (242, 286), 1.0, 1.0, 1.0),
                                   ((236, 270), (250, 284), (256, 294), 1.0, 1.0, 1.0)], "#4f3b2f", 0.9),
    ]
    forms += head_base(pal, skin, outline, [(144, 170), (200, 176), (206, 232), (140, 234)], (114, 142, 18, 32, 6),
                       plane)
    forms += [form("crown_light", 7.35, [C((150, 70), (40, 20), rot=-15)], kind="flat", color=light, opacity=0.35,
                   blur=4.0, clip_to="face")]
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((174, 118), (188, 156), line, light)
    forms += [form("nose_round", 9.02, [C((184, 152), (16, 12))], kind="flat", color=light, opacity=0.25, blur=2.0,
                   clip_to="face")]
    forms += mouth((167, 174), (179, 178), (192, 172), line, light, shadow)
    forms += eye("eye_n", (146, 129), 21, 9, 5, 0.3, "#52606a", -1, line)
    forms += eye("eye_f", (194, 127), 15, 8.5, -5, 0.3, "#52606a", 1, line)
    forms += brows([(159, 110), (146, 106), (130, 112)], [(183, 109), (193, 106), (205, 112)], hm["shadow"],
                   width=(3.6, 3.0, 1.0))
    forms += [
        marks("wrinkles", 11.6, [((140, 92), (164, 88), (190, 92), 0.3, 1.2, 0.3),
                                 ((146, 100), (166, 97), (186, 100), 0.3, 1.0, 0.3),
                                 ((132, 132), (126, 129), (121, 125), 0.3, 1.1, 0.3),
                                 ((133, 137), (127, 137), (122, 135), 0.3, 1.0, 0.3),
                                 ((151, 139), (145, 145), (136, 143), 0.4, 1.3, 0.4),
                                 ((190, 137), (196, 142), (203, 140), 0.3, 1.1, 0.3),
                                 ((176, 160), (166, 172), (164, 184), 0.4, 1.5, 0.4),
                                 ((196, 160), (200, 170), (198, 180), 0.3, 1.1, 0.3)], line, 0.45),
        # wispy white hair round the sides, above the ear
        form("hair_wisps", 13.0, [lock([(126, 72), (112, 86), (106, 110), (110, 130)], 4, 10, 2),
                                  lock([(120, 80), (100, 96), (96, 120)], 3, 8, 1.5),
                                  lock([(208, 72), (218, 90), (220, 112)], 3, 7, 1.5)], material=hair,
             shade={"highlight_amount": 0.5}),
        marks("wisp_strands", 13.1, [((114, 80), (104, 96), (100, 116), 0.3, 1.0, 0.3),
                                     ((130, 64), (120, 70), (112, 80), 0.3, 0.9, 0.3)], hm["light"], 0.7),
    ]
    note = ("Perrin Lask (npc_09), continuation registrar. Author design (the documents give no gender): an older "
            "man, balding with wispy white hair at the sides, droopy kind eyes, soft round nose, wrinkles and a "
            "gentle smile, oat cardigan with a sage scarf, a small bronze bell on a cord and wooden name tags. "
            "3/4 bust facing screen right.")
    return recipe("npc_09_perrin_lask", "portrait_perrin_lask", 109, note, forms)


def juno(pal):
    skin = "skin_warm"
    base, shadow, light, line = skin_colors(pal, skin)
    hair = "hair_honey"
    hm = pal["materials"][hair]
    outline = [(160, 58), (196, 62), (211, 94), (213, 122), (209, 148), (199, 172), (184, 190), (164, 188),
               (142, 178), (124, 156), (116, 124), (116, 88), (132, 64)]
    plane = ([(176, 100), (173, 121), (184, 148), (178, 156), (186, 168), (190, 193)],
             [(240, 204), (245, 70), (182, 70)])
    curls_back = [C((100, 118), (18, 18)), C((94, 136), (16, 16)), C((98, 154), (16, 16)), C((108, 168), (14, 14)),
                  C((110, 100), (16, 14))]
    curls_near = [C((112, 104), (14, 14)), C((104, 118), (14, 14)), C((110, 132), (13, 13)), C((104, 146), (13, 13)),
                  C((114, 156), (12, 12)), C((122, 98), (13, 12)), C((124, 146), (10, 10))]
    curls_far = [C((213, 104), (13, 13)), C((218, 118), (12, 12)), C((215, 131), (10, 10))]
    forms = [
        form("hair_back_mass", 0.15, [smooth([(96, 100), (114, 90), (122, 120), (118, 170), (100, 178), (88, 152),
                                              (88, 120)])], material=hair, shade={"highlight_amount": 0.3}),
        form("curls_back", 0.2, curls_back, material=hair, shade={"highlight_amount": 0.3}),
        form("curls_far", 0.5, curls_far, material=hair, shade={"highlight_amount": 0.3}),
        # mustard coat with a short cape collar, black stand collar, a blank notice pinned on the chest
        cloth("coat", 4.0, [smooth([(128, 226), (176, 232), (214, 228), (256, 242), (296, 262), (312, BOTTOM),
                                    (8, BOTTOM), (20, 274), (66, 244)], 6)], "cloth_mustard"),
        cloth("cape_collar", 4.8, [smooth([(122, 214), (172, 228), (216, 216), (262, 236), (292, 262), (254, 278),
                                           (204, 264), (172, 268), (140, 264), (88, 278), (50, 262), (80, 234)], 6)],
              "cloth_mustard", shade={"highlight_amount": 0.55}),
        marks("cape_hem", 4.9, [((52, 262), (96, 280), (140, 264), 1.0, 2.2, 1.0),
                                ((204, 264), (250, 280), (290, 262), 1.0, 2.2, 1.0)], "#3a2c10", 0.7),
        cloth("stand_collar", 5.0, [smooth([(132, 204), (172, 216), (210, 206), (214, 230), (172, 240), (128, 228)])],
              "cloth_ink"),
        form("coat_buttons", 5.1, [C((176, 286), (8, 8)), C((178, 312), (8, 8))], material="bronze"),
        form("notice", 5.3, [I("square", (96, 296), (24, 30), rot=-6)], material="paper"),
        form("notice_lines", 5.35, [stroke((88, 290), (96, 289), (104, 288), 0.8, 0.8, 0.8),
                                    stroke((88, 297), (96, 296), (105, 295), 0.8, 0.8, 0.8),
                                    stroke((89, 304), (95, 303), (101, 302), 0.8, 0.8, 0.8)], kind="flat",
             material="paper_mark"),
        form("notice_pin", 5.4, [C((96, 283), (7, 7))], material="bronze"),
    ]
    forms += head_base(pal, skin, outline, [(148, 166), (190, 172), (194, 236), (146, 238)], (120, 141, 15, 27, 6),
                       plane)
    forms += socket_shadows(shadow, (146, 129), (194, 127))
    forms += nose((173, 118), (184, 148), line, light)
    forms += mouth((167, 168), (178, 170), (191, 166), line, light, shadow,
                   open_mouth=[(167, 168), (178, 167), (191, 166), (187, 177), (178, 181), (170, 176)])
    forms += [
        form("mouth_teeth", 9.52, [C((179, 165), (22, 6))], kind="flat", color="#b3a696", opacity=0.9,
             clip_to="mouth_open"),
        form("mouth_tongue", 9.52, [C((180, 181), (16, 9))], kind="flat", color="#6a3035", opacity=0.9,
             clip_to="mouth_open"),
    ]
    forms += eye("eye_n", (146, 129), 22, 13, -2, 0.0, "#5a3a22", -1, line)
    forms += eye("eye_f", (194, 127), 16, 12, 3, 0.0, "#5a3a22", 1, line)
    forms += brows([(160, 108), (146, 101), (131, 106)], [(182, 106), (193, 101), (204, 106)], hm["shadow"],
                   width=(2.6, 2.2, 0.5))
    forms += [
        form("hair_near_mass", 12.7, [smooth([(112, 96), (128, 92), (132, 110), (127, 140), (121, 160), (106, 160),
                                              (98, 134), (102, 108)])], material=hair, shade={"highlight_amount": 0.3}),
        form("curls_near", 12.8, curls_near, material=hair, shade={"highlight_amount": 0.3}),
        form("fringe_curls", 12.9, [C((140, 100), (13, 10)), C((151, 99), (12, 10)), C((162, 98), (11, 9)),
                                    C((196, 101), (11, 9)), C((205, 103), (10, 8))],
             material=hair, shade={"highlight_amount": 0.3}),
        # wide-brimmed black hat, tilted, with a mustard band; the brim shades the brow
        wash("brim_shadow", 12.95, [smooth([(114, 96), (160, 104), (212, 104), (214, 116), (160, 116),
                                            (116, 110)])], "#20161a", 0.4, clip_to="face", blur=4.0),
        cloth("hat_brim", 13.5, [C((162, 80), (236, 50), rot=-7)], "cloth_ink", shade={"highlight_amount": 0.4}),
        cloth("hat_crown", 13.6, [smooth([(108, 70), (114, 34), (140, 16), (184, 12), (212, 26), (220, 60),
                                          (190, 72), (150, 76)])], "cloth_ink", shade={"highlight_amount": 0.45}),
        cloth("hat_band", 13.7, [lock([(110, 64), (150, 72), (190, 68), (220, 56)], 7, 9, 7)], "cloth_mustard"),
    ]
    note = ("Juno Caster (npc_10), public crier. Author design: young round face caught mid-sentence, honey short "
            "curls under a wide-brimmed black hat with a mustard band, mustard coat with a short cape collar and "
            "black stand collar, a blank notice pinned on the chest. 3/4 bust facing screen right.")
    return recipe("npc_10_juno_caster", "portrait_juno_caster", 110, note, forms)


PORTRAITS = [ilyra, orrin, veya, sable, nera, tamas, bryn, meral, perrin, juno]


def main() -> int:
    only = sys.argv[1] if len(sys.argv) > 1 else ""
    pal = make_palette()
    (RECIPES / PALETTE).write_text(json.dumps(pal, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("wrote", PALETTE)
    for make in PORTRAITS:
        rec = make(pal)
        if only and not rec["asset"].startswith(only):
            continue
        path = RECIPES / f"{rec['asset']}_portrait.json"
        path.write_text(json.dumps(rec, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
        print("wrote", path.name, len(rec["forms"]), "forms")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
