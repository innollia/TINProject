"""Cutting icon masks and placing them with affine transforms.

A *shape* is an icon mask after cuts.  Cuts are written in icon units
(0..16, the SVG viewBox) so recipes stay resolution independent:

    invert       true            -> 1 - icon (inside the 16x16 box)
    half         left|right|top|bottom
    crop         [x0, y0, x1, y1]           keep this rectangle
    keep         [[ax, ay, bx, by], ...]    keep the half-plane LEFT of a->b
    poly         [[x, y], ...]              keep inside this polygon
    minus_icons  [{"icon": name, "box": [x0, y0, x1, y1]}]  subtract icons
    fit          "tight" (default) | "box" | [x0, y0, x1, y1]

``fit`` decides which rectangle of the icon is mapped onto the recipe's
``size`` box: the tight bounds of what survived the cuts (default), the full
16x16 box, or an explicit rectangle (keeps cut pieces registered).

Placement: the fit rectangle is mapped to a [w, h] box centred on ``at``, then
flipped / skewed / rotated around ``at`` (see :func:`local_frame`).
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass

import numpy as np
from PIL import Image, ImageChops, ImageDraw

from .icons import ICON_UNITS, IconLibrary

CUT_KEYS = ("icon", "invert", "crop", "half", "keep", "poly", "minus_icons", "fit")


# --------------------------------------------------------------------------- affine
class Affine:
    """3x3 homogeneous 2D transform acting on column vectors (x, y, 1)."""

    __slots__ = ("m",)

    def __init__(self, m=None):
        self.m = np.array(m if m is not None else np.eye(3), dtype=np.float64)

    def __matmul__(self, other: "Affine") -> "Affine":
        return Affine(self.m @ other.m)

    @staticmethod
    def translate(tx: float, ty: float) -> "Affine":
        return Affine([[1, 0, tx], [0, 1, ty], [0, 0, 1]])

    @staticmethod
    def scale(sx: float, sy: float | None = None) -> "Affine":
        sy = sx if sy is None else sy
        return Affine([[sx, 0, 0], [0, sy, 0], [0, 0, 1]])

    @staticmethod
    def rotate(deg: float) -> "Affine":
        """Positive = clockwise on a y-down screen."""
        r = math.radians(deg)
        c, s = math.cos(r), math.sin(r)
        return Affine([[c, -s, 0], [s, c, 0], [0, 0, 1]])

    @staticmethod
    def skew(ax_deg: float, ay_deg: float) -> "Affine":
        return Affine([[1, math.tan(math.radians(ax_deg)), 0],
                       [math.tan(math.radians(ay_deg)), 1, 0], [0, 0, 1]])

    def inverse(self) -> "Affine":
        return Affine(np.linalg.inv(self.m))

    def apply(self, pts) -> np.ndarray:
        pts = np.asarray(pts, dtype=np.float64).reshape(-1, 2)
        homo = np.hstack([pts, np.ones((len(pts), 1))])
        return (self.m @ homo.T).T[:, :2]

    def linear_scale(self) -> float:
        return math.sqrt(abs(np.linalg.det(self.m[:2, :2])))


def local_frame(at, size, rot=0.0, flip="", skew=(0.0, 0.0)) -> Affine:
    """Map a unit box centred at the origin (-0.5..0.5) onto the placement box."""
    w, h = size
    fx = -1.0 if "x" in (flip or "") else 1.0
    fy = -1.0 if "y" in (flip or "") else 1.0
    return (Affine.translate(at[0], at[1]) @ Affine.rotate(rot or 0.0)
            @ Affine.skew(*(skew or (0.0, 0.0))) @ Affine.scale(w * fx, h * fy))


# --------------------------------------------------------------------------- shapes
@dataclass
class Shape:
    """A cut icon mask ready to be placed."""

    levels: list            # mip chain of 'L' images, levels[0] = full res
    bbox: tuple             # fit rectangle in level-0 px (x0, y0, x1, y1)
    res: int

    @property
    def aspect(self) -> float:
        x0, y0, x1, y1 = self.bbox
        return max(x1 - x0, 1e-6) / max(y1 - y0, 1e-6)


class ShapeFactory:
    """Builds and caches cut shapes from an :class:`IconLibrary`."""

    def __init__(self, lib: IconLibrary):
        self.lib = lib
        self._cache: dict[str, Shape] = {}

    def get(self, spec: dict) -> Shape:
        key = json.dumps({k: spec.get(k) for k in CUT_KEYS}, sort_keys=True)
        shape = self._cache.get(key)
        if shape is None:
            shape = self._build(spec)
            self._cache[key] = shape
        else:
            self.lib.used[spec["icon"]] = self.lib.sha256(spec["icon"])
        return shape

    def _build(self, spec: dict) -> Shape:
        lib = self.lib
        res = lib.res
        k = res / ICON_UNITS
        img = lib.image(spec["icon"]).copy()
        if spec.get("invert"):
            img = ImageChops.invert(img)

        def keep_poly(points_units):
            m = Image.new("L", (res, res), 0)
            ImageDraw.Draw(m).polygon([(x * k, y * k) for x, y in points_units], fill=255)
            return m

        half = spec.get("half")
        if half:
            x0, y0, x1, y1 = {"left": (0, 0, 8, 16), "right": (8, 0, 16, 16),
                              "top": (0, 0, 16, 8), "bottom": (0, 8, 16, 16)}[half]
            img = ImageChops.multiply(img, keep_poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)]))
        crop = spec.get("crop")
        if crop:
            x0, y0, x1, y1 = crop
            img = ImageChops.multiply(img, keep_poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)]))
        for line in spec.get("keep") or []:
            ax, ay, bx, by = line
            dx, dy = bx - ax, by - ay
            n = math.hypot(dx, dy) or 1.0
            dx, dy = dx / n, dy / n
            nx, ny = dy, -dx          # left normal on a y-down screen
            big = 64.0
            pts = [(ax - dx * big, ay - dy * big), (bx + dx * big, by + dy * big),
                   (bx + dx * big + nx * big, by + dy * big + ny * big),
                   (ax - dx * big + nx * big, ay - dy * big + ny * big)]
            img = ImageChops.multiply(img, keep_poly(pts))
        poly = spec.get("poly")
        if poly:
            img = ImageChops.multiply(img, keep_poly(poly))
        for other in spec.get("minus_icons") or []:
            o = lib.image(other["icon"])
            bx0, by0, bx1, by1 = other.get("box", (0, 0, 16, 16))
            w = max(1, int(round((bx1 - bx0) * k)))
            h = max(1, int(round((by1 - by0) * k)))
            placed = Image.new("L", (res, res), 0)
            placed.paste(o.resize((w, h), Image.Resampling.LANCZOS),
                         (int(round(bx0 * k)), int(round(by0 * k))))
            img = ImageChops.subtract(img, placed)

        fit = spec.get("fit", "tight")
        if fit == "box":
            bbox = (0.0, 0.0, float(res), float(res))
        elif isinstance(fit, (list, tuple)):
            bbox = tuple(float(v) * k for v in fit)
        else:
            box = img.point(lambda v: 255 if v > 6 else 0).getbbox()
            if box is None:
                raise ValueError(f"cuts removed the whole icon: {spec}")
            bbox = tuple(float(v) for v in box)
        levels = [img]
        while levels[-1].size[0] > 32:
            levels.append(levels[-1].reduce(2))
        return Shape(levels=levels, bbox=bbox, res=res)


def placement_size(shape: Shape, size) -> tuple[float, float]:
    """Resolve a recipe ``size``: [w, h] stretches, [w, null] / [null, h] keep aspect,
    a single number is the longest side (aspect kept)."""
    a = shape.aspect
    if size is None:
        size = 16.0
    if isinstance(size, (int, float)):
        s = float(size)
        return (s, s / a) if a >= 1.0 else (s * a, s)
    w, h = size
    if w is None and h is None:
        return (16.0 * a, 16.0)
    if w is None:
        return (float(h) * a, float(h))
    if h is None:
        return (float(w), float(w) / a)
    return (float(w), float(h))


def shape_to_canvas(shape: Shape, placement: Affine) -> Affine:
    """Forward transform from level-0 shape px to canvas px (placement maps the unit box)."""
    x0, y0, x1, y1 = shape.bbox
    w, h = max(x1 - x0, 1e-6), max(y1 - y0, 1e-6)
    to_unit = Affine.scale(1.0 / w, 1.0 / h) @ Affine.translate(-(x0 + x1) / 2.0, -(y0 + y1) / 2.0)
    return placement @ to_unit


def painted_box(shape: Shape) -> tuple[float, float, float, float]:
    """Level-0 px bounds of every painted pixel (can exceed an explicit fit box)."""
    if getattr(shape, "_painted", None) is None:
        small = shape.levels[-1]
        box = small.point(lambda v: 255 if v > 2 else 0).getbbox() or (0, 0, small.size[0], small.size[1])
        f = shape.res / small.size[0]
        shape._painted = ((box[0] - 1) * f, (box[1] - 1) * f, (box[2] + 1) * f, (box[3] + 1) * f)
    return shape._painted


def canvas_bounds(shape: Shape, forward: Affine) -> tuple[float, float, float, float]:
    """Canvas-space bounds of the painted part of a placed shape."""
    bx0, by0, bx1, by1 = painted_box(shape)
    c = forward.apply([(bx0, by0), (bx1, by0), (bx1, by1), (bx0, by1)])
    return (float(c[:, 0].min()), float(c[:, 1].min()), float(c[:, 0].max()), float(c[:, 1].max()))


def rasterize(shape: Shape, forward: Affine, window: tuple[int, int, int, int], margin: int = 2):
    """Coverage of the placed shape inside ``window`` = (x0, y0, x1, y1) canvas px.

    The window may extend beyond the real canvas.  Returns (float32 array, x, y)
    for the part that intersects the window, or None.
    """
    bx0, by0, bx1, by1 = canvas_bounds(shape, forward)
    wx0, wy0, wx1, wy1 = window
    cx0 = max(wx0, int(math.floor(bx0)) - margin)
    cy0 = max(wy0, int(math.floor(by0)) - margin)
    cx1 = min(wx1, int(math.ceil(bx1)) + margin)
    cy1 = min(wy1, int(math.ceil(by1)) + margin)
    if cx1 <= cx0 or cy1 <= cy0:
        return None
    # pick a mip level whose pixels are at most ~1 canvas px (limits aliasing)
    scale = forward.linear_scale()
    level = 0
    while level + 1 < len(shape.levels) and scale * (2 ** (level + 1)) <= 1.0:
        level += 1
    src = shape.levels[level]
    fwd_level = forward @ Affine.scale(2 ** level)          # level px -> canvas px
    inv = (fwd_level.inverse() @ Affine.translate(cx0, cy0)).m  # window px -> level px
    data = (inv[0, 0], inv[0, 1], inv[0, 2], inv[1, 0], inv[1, 1], inv[1, 2])
    out = src.transform((cx1 - cx0, cy1 - cy0), Image.Transform.AFFINE, data,
                        resample=Image.Resampling.BICUBIC, fillcolor=0)
    arr = np.asarray(out, dtype=np.float32) / 255.0
    return arr, cx0, cy0
