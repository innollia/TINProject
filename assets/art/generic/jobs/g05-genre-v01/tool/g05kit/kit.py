"""g05kit: helpers that write iconkit recipes for front-view battle creatures.

A creature is written as a Python function that builds a :class:`Creature`
(forms made of cut icon pieces) and its frames.  ``make_recipes.py`` turns the
result into ``recipes/<asset>.json``; ``build.py`` renders those unchanged, so
the JSON next to the output is always the exact source of every PNG.

Conventions (all in final output px, y down):
  * canvas height 384 = human-size battler; pivot = ground point under the body.
  * every form carries the tag "all" so a frame can lean / lunge the whole body;
    per-part tags (arm_r, head, jaw, ...) move first, "all" last.
  * forms tagged "eyes" / "mouth" are the idle face; "eyes_hit" / "mouth_open"
    are hidden alternatives that attack / hit frames switch on.
"""

from __future__ import annotations

import copy
import math

ALL = "all"


def r1(v: float) -> float:
    return round(float(v), 1)


# --------------------------------------------------------------------------- pieces
def P(icon: str, x: float, y: float, w, h=None, rot: float = 0.0, **kw) -> dict:
    """One icon piece centred at (x, y); size [w, h] (h None keeps aspect when w is a number)."""
    if h is None and not isinstance(w, (list, tuple)):
        size = r1(w)
    elif isinstance(w, (list, tuple)):
        size = [None if v is None else r1(v) for v in w]
    else:
        size = [None if w is None else r1(w), None if h is None else r1(h)]
    d = {"icon": icon, "at": [r1(x), r1(y)], "size": size}
    if rot:
        d["rot"] = r1(rot)
    d.update(kw)
    return d


def E(x, y, w, h=None, rot=0.0, **kw) -> dict:
    """Ellipse (circle icon)."""
    return P("circle", x, y, w, w if h is None else h, rot, **kw)


def angle_of(dx: float, dy: float) -> float:
    """Rotation that turns an icon's vertical (down) axis toward (dx, dy)."""
    return math.degrees(math.atan2(-dx, dy))


def seg(x0, y0, x1, y1, w, icon="circle", ext=0.35, **kw) -> dict:
    """Elongated piece from (x0, y0) to (x1, y1), width ``w`` (a limb bone)."""
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy)
    return P(icon, (x0 + x1) / 2, (y0 + y1) / 2, w, length + w * ext, angle_of(dx, dy), **kw)


def bezier(ctrl, n: int):
    """Sample a quadratic / cubic Bezier (or a polyline of more points, piecewise) -> [(x, y, dx, dy)]."""
    ctrl = [tuple(map(float, c)) for c in ctrl]
    out = []
    for i in range(n):
        t = i / (n - 1) if n > 1 else 0.5
        if len(ctrl) == 2:
            (x0, y0), (x1, y1) = ctrl
            x, y, dx, dy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, x1 - x0, y1 - y0
        elif len(ctrl) == 3:
            (x0, y0), (x1, y1), (x2, y2) = ctrl
            u = 1 - t
            x = u * u * x0 + 2 * u * t * x1 + t * t * x2
            y = u * u * y0 + 2 * u * t * y1 + t * t * y2
            dx = 2 * u * (x1 - x0) + 2 * t * (x2 - x1)
            dy = 2 * u * (y1 - y0) + 2 * t * (y2 - y1)
        else:
            (x0, y0), (x1, y1), (x2, y2), (x3, y3) = ctrl[:4]
            u = 1 - t
            x = u ** 3 * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t ** 3 * x3
            y = u ** 3 * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t ** 3 * y3
            dx = 3 * u * u * (x1 - x0) + 6 * u * t * (x2 - x1) + 3 * t * t * (x3 - x2)
            dy = 3 * u * u * (y1 - y0) + 6 * u * t * (y2 - y1) + 3 * t * t * (y3 - y2)
        out.append((x, y, dx, dy))
    return out


def tube(ctrl, w0, w1, n=10, icon="circle", stretch=1.9, curve=1.0, cap=False, **kw) -> list:
    """Tapered tube along a Bezier: overlapping ellipses, width w0 -> w1 (tails, necks, tentacles).
    cap=True keeps the two end pieces inside the end points (round caps, no overshoot)."""
    pts = bezier(ctrl, n)
    total = sum(math.hypot(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1]) for i in range(n - 1))
    step = total / max(1, n - 1)
    pieces = []
    for i, (x, y, dx, dy) in enumerate(pts):
        f = (i / (n - 1)) ** curve if n > 1 else 0.0
        w = w0 + (w1 - w0) * f
        length = max(w, step * stretch)
        if cap and (i == 0 or i == n - 1) and (dx or dy):
            nrm = math.hypot(dx, dy)
            ux, uy = dx / nrm, dy / nrm
            length = max(w, step * stretch * 0.6)
            sgn = 1.0 if i == 0 else -1.0
            x, y = x + sgn * ux * (length - w) / 2, y + sgn * uy * (length - w) / 2
        pieces.append(P(icon, x, y, w, length, angle_of(dx, dy) if (dx or dy) else 0.0, **kw))
    return pieces


def along(ctrl, n, make, t0=0.0, t1=1.0):
    """Call make(x, y, angle_deg_of_tangent, i, t) at n points of a Bezier between t0..t1."""
    pts = bezier(ctrl, 64)
    out = []
    for i in range(n):
        t = t0 + (t1 - t0) * (i / (n - 1) if n > 1 else 0.5)
        k = min(63, int(round(t * 63)))
        x, y, dx, dy = pts[k]
        res = make(x, y, math.degrees(math.atan2(dy, dx)), i, t)
        out.extend(res if isinstance(res, list) else [res])
    return out


def mirror_piece(p: dict, cx: float) -> dict:
    q = copy.deepcopy(p)
    q["at"] = [r1(2 * cx - p["at"][0]), p["at"][1]]
    flip = q.get("flip", "") or ""
    q["flip"] = flip.replace("x", "") if "x" in flip else flip + "x"
    if not q["flip"]:
        del q["flip"]
    if q.get("rot"):
        q["rot"] = r1(-q["rot"])
    if q.get("skew"):
        q["skew"] = [-q["skew"][0], -q["skew"][1]]
    return q


def mirror(pieces: list, cx: float) -> list:
    return [mirror_piece(p, cx) for p in pieces]


def sym(pieces: list, cx: float) -> list:
    """Pieces plus their mirror image about x = cx."""
    return list(pieces) + mirror(pieces, cx)


def row(n, x0, x1, y, make):
    """make(x, y, i) for n evenly spaced x between x0..x1."""
    out = []
    for i in range(n):
        x = x0 + (x1 - x0) * (i / (n - 1) if n > 1 else 0.5)
        res = make(x, y, i)
        out.extend(res if isinstance(res, list) else [res])
    return out


def fangs(x0, x1, y, n, h, w=None, down=True, icon="triangle", jitter=0.0) -> list:
    """A row of triangle teeth between x0..x1 at y (pointing down, or up)."""
    w = w or (abs(x1 - x0) / max(1, n)) * 0.9
    out = []
    for i in range(n):
        x = x0 + (x1 - x0) * ((i + 0.5) / n)
        hh = h * (1.0 - jitter * ((i * 37) % 5) / 5.0)
        out.append(P(icon, x, y + (hh / 2 if down else -hh / 2), w, hh, 0, **({"flip": "y"} if down else {})))
    return out


def held(icon, hand, size, phi, grip=0.42, flip=False, **kw) -> dict:
    """A diagonal tool icon (handle lower-left, tip upper-right: axe, dagger, sword, bat, hammer)
    gripped at ``hand`` and pointing its tip toward screen angle ``phi`` (deg, 0 = right, -90 = up).
    ``flip`` mirrors the icon (blade on the other side)."""
    t = math.radians(phi)
    cxp, cyp = hand[0] + math.cos(t) * grip * size, hand[1] + math.sin(t) * grip * size
    if flip:
        return P(icon, cxp, cyp, size, size, phi + 135.0, flip="x", **kw)
    return P(icon, cxp, cyp, size, size, phi + 45.0, **kw)


def poly(points, **kw) -> dict:
    """Any polygon in canvas px, cut out of the (rounded) square icon with a ``poly`` cut.
    The polygon is mapped into icon units 1.5..14.5 (inside the square's rounded corners)."""
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    w, h = max(x1 - x0, 1.0), max(y1 - y0, 1.0)
    units = [[round(1.5 + (x - x0) / w * 13.0, 3), round(1.5 + (y - y0) / h * 13.0, 3)] for x, y in points]
    return P("square", (x0 + x1) / 2, (y0 + y1) / 2, w, h, poly=units, fit=[1.5, 1.5, 14.5, 14.5], **kw)


def membrane(root, wrist, tips, inner, scallop=0.22):
    """Bat / dragon wing membrane: polygon root -> wrist -> tips... -> inner (back at the body),
    with the trailing edge between consecutive tips scooped out by ellipses (op sub).
    Returns (membrane_pieces, bone_pieces)."""
    pts = [root, wrist] + list(tips) + [inner]
    pieces = [poly(pts)]
    edge = list(tips) + [inner]
    for a, b in zip(edge[:-1], edge[1:]):
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        L = math.hypot(b[0] - a[0], b[1] - a[1])
        # push the scoop centre outward (away from the wrist) so it bites the edge
        vx, vy = mx - wrist[0], my - wrist[1]
        n = math.hypot(vx, vy) or 1.0
        cxp, cyp = mx + vx / n * L * scallop * 0.9, my + vy / n * L * scallop * 0.9
        pieces.append(P("circle", cxp, cyp, L * 0.92, L * scallop * 2.4, math.degrees(math.atan2(b[1] - a[1], b[0] - a[0])),
                        op="sub"))
    return pieces


# --------------------------------------------------------------------------- faces
def smile(cx, y, w, h, depth=0.42, frown=False) -> list:
    """Symmetric crescent mouth: an ellipse minus a shifted ellipse (op sub)."""
    k = 1 if frown else -1
    return [E(cx, y, w, h), E(cx, y + k * h * depth, w * 1.2, h * 1.05, op="sub")]


def brows(cx, y, dx, length, width, tilt=14.0) -> list:
    """Angry brows: inner ends low (tilt > 0) or worried (tilt < 0)."""
    import math as _m
    t = _m.radians(tilt)
    ox, oy = length / 2 * _m.cos(t), length / 2 * _m.sin(t)
    left = seg(cx - dx - ox, y - oy, cx - dx + ox, y + oy, width)
    return [left, mirror_piece(left, cx)]


def dot_eyes(c, cx, y, dx, w, h, mat="eye", z=6, glint=True, tags=("eyes",), name="eyes", rot=0.0):
    pieces = [E(cx - dx, y, w, h, rot), E(cx + dx, y, w, h, -rot)]
    c.flat(name, mat, z, pieces, tags=tags)
    if glint:
        c.flat(name + "_glint", "eye_white", z + 0.1,
               [E(cx - dx - w * 0.22, y - h * 0.22, w * 0.3, h * 0.26), E(cx + dx - w * 0.22, y - h * 0.22, w * 0.3, h * 0.26)],
               tags=tags, line=False)


def x_eyes(c, cx, y, dx, s, mat="eye", z=6, width=6.0, tags=()):
    """Squeezed ">  <" eyes for the hit frame (hidden until shown)."""
    L = [seg(cx - dx - s, y - s * 0.7, cx - dx + s * 0.6, y, width), seg(cx - dx + s * 0.6, y, cx - dx - s, y + s * 0.7, width)]
    c.flat("eyes_hit", mat, z, L + mirror(L, cx), tags=("eyes_hit", *tags), hidden=True)


# --------------------------------------------------------------------------- creature
class Creature:
    def __init__(self, asset: str, canvas, pivot, seed: int = 1, note: str = "",
                 palette: str = "palette_g05.json", style: str = "sprite"):
        self.asset = asset
        self.canvas = list(canvas)
        self.pivot = list(pivot)
        self.seed = seed
        self.note = note
        self.palette = palette
        self.style = style
        self.forms: list = []
        self.frames: list = []
        self.meta: dict = {}

    # forms ------------------------------------------------------------------
    def add(self, name, mat, z, pieces, tags=(), kind=None, **kw) -> dict:
        form = {"name": name, "tags": [ALL, *tags], "z": z}
        if kind:
            form["kind"] = kind
        if mat:
            form["material"] = mat
        form.update(kw)
        form["pieces"] = pieces
        self.forms.append(form)
        return form

    def flat(self, name, mat, z, pieces, tags=(), **kw) -> dict:
        return self.add(name, mat, z, pieces, tags, kind="flat", **kw)

    def shadow(self, x, y, w, h, opacity=0.42, blur=4, name="shadow", tags=("shadow",)) -> dict:
        # keep the blurred ellipse inside the canvas (a clipped shadow shows a flat bottom edge)
        limit = self.canvas[1] - 5 - h / 2 - blur * 1.6
        y = min(y, limit)
        form = {"name": name, "tags": list(tags), "kind": "shadow", "color": "shadow_contact",
                "opacity": opacity, "blur": blur, "pieces": [E(x, y, w, h)]}
        self.forms.append(form)
        return form

    def glow(self, name, mat, z, pieces, tags=(), color="glow_red_c", strength=1.0, radius=2.5, opacity=0.6,
             hidden=False, **kw) -> dict:
        extra = {"emit": strength, "glow": {"radius": radius, "opacity": opacity, "color": color}}
        if hidden:
            extra["hidden"] = True
        extra.update(kw)
        return self.flat(name, mat, z, pieces, tags, **extra)

    # frames -----------------------------------------------------------------
    def frame(self, name, move=None, show=(), hide=(), **kw) -> dict:
        fr = {"name": name}
        if move:
            fr["move"] = move
        if show:
            fr["show"] = list(show)
        if hide:
            fr["hide"] = list(hide)
        fr.update(kw)
        self.frames.append(fr)
        return fr

    def whole(self, rot=0.0, dx=0.0, dy=0.0, s=1.0, sx=None, sy=None, pivot=None) -> dict:
        """Move for the tag "all" (lean / lunge around the ground pivot)."""
        mv = {"pivot": list(pivot or self.pivot)}
        if rot:
            mv["rot"] = rot
        if dx:
            mv["dx"] = dx
        if dy:
            mv["dy"] = dy
        sx = s if sx is None else sx
        sy = s if sy is None else sy
        if sx != 1.0:
            mv["sx"] = sx
        if sy != 1.0:
            mv["sy"] = sy
        return mv

    # output -----------------------------------------------------------------
    def recipe(self) -> dict:
        frames = self.frames or [{"name": "idle"}]
        return {
            "asset": self.asset,
            "status": "candidate",
            "note": self.note,
            "palette": self.palette,
            "style": self.style,
            "canvas": self.canvas,
            "pivot": self.pivot,
            "pivot_meaning": "ground point under the body centre (front-view battler; place this pixel on the battle floor)",
            "seed": self.seed,
            "g05": dict(self.meta, generator="tool/make_recipes.py"),
            "forms": self.forms,
            "frames": frames,
        }


# --------------------------------------------------------------------------- common frame recipes
def std_frames(c: Creature, attack_move=None, hit_move=None, attack_show=("mouth_open",), attack_hide=("mouth",),
               hit_show=("eyes_hit", "mouth_open"), hit_hide=("eyes", "mouth"), shadow_hit_dx=0.0,
               shadow_attack=None, a_state=True):
    """idle / attack / hit with the usual face swaps.  a_state=False -> idle only (B, C items)."""
    c.frame("idle")
    if not a_state:
        return
    am = dict(attack_move or {})
    if shadow_attack:
        am = {"shadow": shadow_attack, **am}
    c.frame("attack", move=am, show=[t for t in attack_show if has_tag(c, t)], hide=[t for t in attack_hide if has_tag(c, t)])
    hm = dict(hit_move or {})
    if shadow_hit_dx:
        hm = {"shadow": {"dx": shadow_hit_dx}, **hm}
    c.frame("hit", move=hm, show=[t for t in hit_show if has_tag(c, t)], hide=[t for t in hit_hide if has_tag(c, t)])


def has_tag(c: Creature, tag: str) -> bool:
    return any(tag in f.get("tags", []) or f.get("name") == tag for f in c.forms)


# registry ---------------------------------------------------------------------
REGISTRY: dict = {}


def creature(asset: str, priority: str = "A"):
    def deco(fn):
        REGISTRY[asset] = (fn, priority)
        return fn
    return deco
