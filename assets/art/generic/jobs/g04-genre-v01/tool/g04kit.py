"""g04kit: write iconkit recipes (JSON) for generic map objects from short Python specs.

Added by session g04 (not part of the V1 tool).  Everything it writes is an ordinary
iconkit recipe: pieces are at-icons shapes (cut, stretched, overlapped), painted by the
unchanged V1 renderer (iconkit/render.py) through build.py.

Coordinates are LOCAL px with the origin at the object's pivot (ground contact point),
x to the right, y down.  ``Asset.save`` measures every piece, adds the 32 px safety
margin (+ glow / blur reach), and writes the canvas size and pivot into the recipe.

Scale (?묒꽦???ㅺ퀎, see JOB.md): 60 deg top-down camera, width 180 px per metre,
ground depth 156 px per metre (x0.866), height 105 px per metre (the player sprite is
~180 px tall for a ~1.7 m person, so objects keep real proportions next to it).
"""

from __future__ import annotations

import copy
import json
import math
import random
from dataclasses import dataclass
from pathlib import Path

MW = 180.0      # px per metre of width
MD = 156.0      # px per metre of ground depth
MH = 105.0      # px per metre of height
SQ = 0.866      # ground squash of a 60 deg camera
MARGIN = 32     # safety margin around every object (COMMON.md 09 짠12)


# ----------------------------------------------------------------------------- pieces
def R(x, y, w, h, corner=4, **kw):
    """Rectangle (sliced rounded square) centred at (x, y)."""
    p = {"icon": "square", "slice": {"border": 4, "corner": corner}, "at": [x, y], "size": [w, h]}
    p.update(kw)
    return p


def E(x, y, w, h, **kw):
    """Ellipse centred at (x, y)."""
    p = {"icon": "circle", "at": [x, y], "size": [w, h]}
    p.update(kw)
    return p


def I(icon, x, y, w, h=None, **kw):
    """Any at-icons shape; ``h=None`` keeps the icon aspect with ``w`` as the longest side."""
    p = {"icon": icon, "at": [x, y], "size": [w, h] if h is not None else w}
    p.update(kw)
    return p


def POLY(points, x, y, w, h, **kw):
    """Arbitrary polygon: ``points`` in a 0..1 box mapped onto a [w, h] box centred at (x, y)."""
    pts = [[round(2 + 12 * u, 4), round(2 + 12 * v, 4)] for u, v in points]
    p = {"icon": "square", "poly": pts, "fit": [2, 2, 14, 14], "at": [x, y], "size": [w, h]}
    p.update(kw)
    return p


def LINE(x0, y0, x1, y1, width, **kw):
    """A straight bar from (x0, y0) to (x1, y1)."""
    length = math.hypot(x1 - x0, y1 - y0)
    rot = math.degrees(math.atan2(y1 - y0, x1 - x0))
    return R((x0 + x1) / 2, (y0 + y1) / 2, max(length, 1.0), width, corner=min(3, width / 2), rot=rot, **kw)


def piece_box(p: dict):
    x, y = p["at"]
    size = p.get("size", 16)
    if isinstance(size, (int, float)):
        w = h = float(size)
    else:
        w = size[0] if size[0] is not None else size[1] * 2.0
        h = size[1] if size[1] is not None else size[0] * 2.0
    if p.get("squash"):
        h *= float(p["squash"])
    elif p.get("ground"):
        h *= SQ
    rot = float(p.get("rot", 0.0)) % 180.0
    if abs(rot) < 1e-6:
        hw, hh = w / 2, h / 2
    elif abs(rot - 90.0) < 1e-6:
        hw, hh = h / 2, w / 2
    else:
        r = math.radians(rot)
        hw = abs(w / 2 * math.cos(r)) + abs(h / 2 * math.sin(r))
        hh = abs(w / 2 * math.sin(r)) + abs(h / 2 * math.cos(r))
    sk = p.get("skew")
    if sk:
        hw += abs(math.tan(math.radians(sk[0]))) * hh
        hh += abs(math.tan(math.radians(sk[1]))) * hw
    return (x - hw, y - hh, x + hw, y + hh)


@dataclass
class Box:
    cx: float
    x0: float
    x1: float
    top0: float    # far edge of the top face
    top1: float    # near edge of the top face = top of the front face
    bottom: float  # bottom of the front face
    ground: float  # ground line under the front face
    w: float
    d: float
    h: float

    @property
    def top_cy(self):
        return (self.top0 + self.top1) / 2.0

    @property
    def front_cy(self):
        return (self.top1 + self.bottom) / 2.0


# ----------------------------------------------------------------------------- asset
class Asset:
    def __init__(self, asset: str, note: str, seed: int, *, pivot_meaning="front-bottom centre of the base on the floor",
                 layer_hint="world", palette="palette_g04.json", style="prop"):
        self.asset = asset
        self.meta = {"asset": asset, "status": "candidate", "note": note, "palette": palette, "style": style,
                     "seed": seed, "pivot_meaning": pivot_meaning, "layer_hint": layer_hint}
        self.forms: list[dict] = []
        self.frames: list[dict] = []
        self.footprint = None
        self._z = 0.0
        self.rng = random.Random(seed)

    # -- forms ---------------------------------------------------------------------
    def add(self, name, pieces, kind="mass", material=None, *, z=None, tags=None, hidden=False, **kw):
        if z is None:
            self._z += 1.0
            z = self._z
        else:
            self._z = max(self._z, z)
        f = {"name": name, "z": round(z, 3), "kind": kind}
        if material:
            f["material"] = material
        if tags:
            f["tags"] = list(tags)
        if hidden:
            f["hidden"] = True
        f.update(kw)
        f["pieces"] = [copy.deepcopy(p) for p in pieces]
        self.forms.append(f)
        return f

    def flat(self, name, pieces, material, **kw):
        return self.add(name, pieces, "flat", material, **kw)

    def wash(self, name, pieces, material="grime", opacity=0.4, **kw):
        kw.setdefault("blend", "multiply")
        return self.add(name, pieces, "wash", material, opacity=opacity, **kw)

    def shadow(self, pieces, opacity=0.35, blur=8, name="shadow", **kw):
        return self.add(name, pieces, "shadow", None, color="shadow_contact", opacity=opacity, blur=blur, **kw)

    def box(self, name, x, y, w, d, h, material, *, lift=0.0, corner=5, top=None, **kw) -> Box:
        """Axis-aligned box; (x, y) = centre of the front-bottom edge ON THE GROUND.
        w, d, h in px (d already foreshortened); ``lift`` = height of the box bottom above ground."""
        top1 = y - lift - h
        top0 = top1 - d
        cy = (top0 + top1) / 2.0
        piece = R(x, cy, w, d, corner) if top is None else top(x, cy, w, d)
        self.add(name, [piece] if isinstance(piece, dict) else piece, "block", material, extrude=h, **kw)
        return Box(x, x - w / 2, x + w / 2, top0, top1, y - lift, y, w, d, h)

    def cyl(self, name, x, y, dia, h, material, *, lift=0.0, hole=None, **kw) -> Box:
        """Upright cylinder; (x, y) = lowest point of its base ellipse on the ground."""
        dd = dia * SQ
        top1 = y - lift - h
        cy = top1 - dd / 2.0
        pieces = [E(x, cy, dia, dd)]
        if hole:
            pieces.append(E(x, cy, hole, hole * SQ, op="sub"))
        self.add(name, pieces, "block", material, extrude=h, **kw)
        return Box(x, x - dia / 2, x + dia / 2, top1 - dd, top1, y - lift, y, dia, dd, h)

    # -- frames --------------------------------------------------------------------
    def frame(self, name, *, state=None, hide=(), show=(), light=None, anchors=None, **kw):
        fr = {"name": name}
        if state:
            fr["state"] = state
        if hide:
            fr["hide"] = list(hide)
        if show:
            fr["show"] = list(show)
        if light:
            fr["game_light"] = copy.deepcopy(light)
        if anchors:
            fr["anchors"] = {k: list(v) for k, v in anchors.items()}
        fr.update(kw)
        self.frames.append(fr)
        return fr

    # -- output --------------------------------------------------------------------
    def _bounds(self):
        bx = [math.inf, math.inf, -math.inf, -math.inf]
        for f in self.forms:
            boxes = [piece_box(p) for p in f["pieces"] if p.get("op") not in ("sub", "clip")]
            if not boxes:
                continue
            x0 = min(b[0] for b in boxes)
            y0 = min(b[1] for b in boxes)
            x1 = max(b[2] for b in boxes)
            y1 = max(b[3] for b in boxes)
            if f.get("kind") == "block":
                y1 += float(f.get("extrude", 0.0))
            grow = 0.0
            if f.get("glow"):
                grow = max(grow, float(f["glow"].get("radius", 3)) * 3.0)
            if f.get("blur"):
                grow = max(grow, float(f["blur"]) * 3.0)
            if f.get("rough"):
                grow = max(grow, float(f["rough"].get("soft", 2.0)) * 2.0 + 3.0)
            if f.get("cast"):
                grow = max(grow, float(f["cast"].get("dist", 3)) + float(f["cast"].get("blur", 2)) * 3.0)
            bx = [min(bx[0], x0 - grow), min(bx[1], y0 - grow), max(bx[2], x1 + grow), max(bx[3], y1 + grow)]
        return bx

    def save(self, recipes_dir: Path) -> Path:
        x0, y0, x1, y1 = self._bounds()
        pad = MARGIN + 6
        left, top = math.floor(x0 - pad), math.floor(y0 - pad)
        W, H = math.ceil(x1 + pad) - left, math.ceil(y1 + pad) - top
        W += W % 2
        H += H % 2
        px, py = -left, -top

        def mv(pt):
            return [round(pt[0] + px, 2), round(pt[1] + py, 2)]

        forms = copy.deepcopy(self.forms)
        for f in forms:
            for p in f["pieces"]:
                p["at"] = mv(p["at"])
            if f.get("pivot"):
                f["pivot"] = mv(f["pivot"])
        frames = copy.deepcopy(self.frames)
        for fr in frames:
            gl = fr.get("game_light")
            for light in (gl if isinstance(gl, list) else [gl] if gl else []):
                if light.get("at"):
                    light["at"] = mv(light["at"])
            for k, v in (fr.get("anchors") or {}).items():
                fr["anchors"][k] = mv(v)
        recipe = dict(self.meta)
        recipe["canvas"] = [int(W), int(H)]
        recipe["pivot"] = [int(px), int(py)]
        if self.footprint:
            fx0, fy0, fx1, fy1 = self.footprint
            recipe["footprint"] = [round(fx0 + px), round(fy0 + py), round(fx1 + px), round(fy1 + py)]
        recipe["forms"] = forms
        if frames:
            recipe["frames"] = frames
        path = Path(recipes_dir) / f"{self.asset}.json"
        path.write_text(json.dumps(recipe, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
        return path


# ----------------------------------------------------------------------------- shared parts
def planks_front(a: Asset, name, b: Box, n, material="wood_dark", opacity=0.55, vertical=False, **kw):
    """Dark joint lines dividing a box front into n planks."""
    pieces = []
    for i in range(1, n):
        if vertical:
            x = b.x0 + b.w * i / n
            pieces.append(R(x, b.front_cy, 2.2, b.h - 4, 1))
        else:
            y = b.top1 + b.h * i / n
            pieces.append(R(b.cx, y, b.w - 6, 2.2, 1))
    if pieces:
        a.flat(name, pieces, material, opacity=opacity, **kw)


def planks_top(a: Asset, name, b: Box, n, material="wood_dark", opacity=0.45, along_x=True, **kw):
    pieces = []
    for i in range(1, n):
        if along_x:
            y = b.top0 + b.d * i / n
            pieces.append(R(b.cx, y, b.w - 8, 2.0, 1))
        else:
            x = b.x0 + b.w * i / n
            pieces.append(R(x, b.top_cy, 2.0, b.d - 6, 1))
    if pieces:
        a.flat(name, pieces, material, opacity=opacity, **kw)


def legs(a: Asset, name, b: Box, lift, size, material, inset=6, back=True, front=True, z_back=None, **kw):
    """Four square legs under a lifted slab ``b`` (its ground line b.ground)."""
    xs = [b.x0 + inset + size / 2, b.x1 - inset - size / 2]
    if back:
        yb = b.ground - b.d + inset
        for i, x in enumerate(xs):
            a.box(f"{name}_back{i}", x, yb, size, size * SQ, lift, material, corner=2, z=z_back, **kw)
    out = []
    if front:
        for i, x in enumerate(xs):
            out.append(a.box(f"{name}_front{i}", x, b.ground - inset, size, size * SQ, lift, material, corner=2, **kw))
    return out


def rivets(xys, size=5):
    return [E(x, y, size, size * 0.9) for x, y in xys]


def ellipse_shadow(a: Asset, x, y, w, h, opacity=0.35, blur=8, name="shadow"):
    return a.shadow([E(x, y, w, h)], opacity=opacity, blur=blur, name=name)


def rect_shadow(a: Asset, b: Box, grow=10, opacity=0.35, blur=9, dx=6, dy=4, name="shadow"):
    return a.shadow([R(b.cx + dx, b.ground - b.d / 2 + dy, b.w + grow, b.d + grow, 12)], opacity=opacity, blur=blur,
                    name=name)


def band_on_cyl(x, y_center, dia, width):
    """Pieces for a hoop band on the front of an upright cylinder (use clip_to the body)."""
    dd = dia * SQ
    return [E(x, y_center + width / 2, dia + 2, dd, half="bottom", fit=[1, 1, 15, 15]),
            E(x, y_center - width / 2, dia + 2, dd, op="sub")]
