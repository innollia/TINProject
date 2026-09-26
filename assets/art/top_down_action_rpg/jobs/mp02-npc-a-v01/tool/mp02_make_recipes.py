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


PORTRAIT_GRIME = {"size": 26, "soft": 3.0, "density": 0.1, "strength": 0.16}


def cloth(name, z, pieces, material, **kw):
    """Portrait cloth: fewer, larger and weaker stains than the sprite-size material default."""
    kw.setdefault("grime", dict(PORTRAIT_GRIME))
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


PORTRAITS = [ilyra]


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


PORTRAITS = [ilyra, orrin]


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


PORTRAITS = [ilyra, orrin, veya]


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


PORTRAITS = [ilyra, orrin, veya, sable]


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


PORTRAITS = [ilyra, orrin, veya, sable, nera]


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
