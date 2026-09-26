"""Painting primitives: layer buffers, noise, icon-stamp brush fields and the
light / line / extrusion effects that turn flat icon cut-outs into one style.

All arrays are float32.  Colour buffers are premultiplied sRGB in 0..1.
Directions follow the screen: +x right, +y down, +z toward the viewer.
``light2`` is a 2D unit vector pointing FROM the surface TOWARD the light
(e.g. (-0.5, -0.86) = light up and slightly left); ``light3`` adds z.
"""

from __future__ import annotations

import math

import numpy as np
from PIL import Image


# --------------------------------------------------------------------------- colour
def hex_rgb(value) -> np.ndarray:
    if isinstance(value, (list, tuple, np.ndarray)):
        return np.asarray(value, dtype=np.float32)
    value = value.lstrip("#")
    if len(value) == 3:
        value = "".join(c * 2 for c in value)
    return np.array([int(value[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], dtype=np.float32)


def lerp(a, b, t):
    """Blend colours/arrays; ``t`` may be a (h, w) map for (h, w, 3) images."""
    t = np.asarray(t, dtype=np.float32)
    if t.ndim == 2:
        t = t[..., None]
    return a + (b - a) * t


# --------------------------------------------------------------------------- buffers
class Buffer:
    """Premultiplied RGBA layer."""

    def __init__(self, width: int, height: int, fill=None):
        self.w, self.h = width, height
        self.rgb = np.zeros((height, width, 3), dtype=np.float32)
        self.a = np.zeros((height, width), dtype=np.float32)
        if fill is not None:
            self.rgb[:] = hex_rgb(fill)
            self.a[:] = 1.0

    def region(self, x0: int, y0: int, x1: int, y1: int):
        """Clip a window to the buffer: returns (bx0, by0, bx1, by1) or None."""
        bx0, by0 = max(0, x0), max(0, y0)
        bx1, by1 = min(self.w, x1), min(self.h, y1)
        if bx1 <= bx0 or by1 <= by0:
            return None
        return bx0, by0, bx1, by1

    def composite(self, rgb: np.ndarray, alpha: np.ndarray, x0: int, y0: int) -> None:
        """Straight colour ``rgb`` with coverage ``alpha`` (window at x0, y0) OVER the buffer."""
        h, w = alpha.shape
        r = self.region(x0, y0, x0 + w, y0 + h)
        if r is None:
            return
        bx0, by0, bx1, by1 = r
        sx0, sy0 = bx0 - x0, by0 - y0
        a = alpha[sy0:sy0 + by1 - by0, sx0:sx0 + bx1 - bx0]
        c = rgb[sy0:sy0 + by1 - by0, sx0:sx0 + bx1 - bx0] if rgb.ndim == 3 else rgb
        dst_rgb = self.rgb[by0:by1, bx0:bx1]
        dst_a = self.a[by0:by1, bx0:bx1]
        dst_rgb *= (1.0 - a)[..., None]
        dst_rgb += c * a[..., None]
        dst_a *= 1.0 - a
        dst_a += a

    def darken(self, amount: np.ndarray, tint, x0: int, y0: int) -> None:
        """Multiply existing content toward ``tint`` by ``amount`` (0..1); alpha kept."""
        h, w = amount.shape
        r = self.region(x0, y0, x0 + w, y0 + h)
        if r is None:
            return
        bx0, by0, bx1, by1 = r
        sx0, sy0 = bx0 - x0, by0 - y0
        m = amount[sy0:sy0 + by1 - by0, sx0:sx0 + bx1 - bx0][..., None]
        tint = hex_rgb(tint)
        self.rgb[by0:by1, bx0:bx1] *= 1.0 - m * (1.0 - tint)

    def lighten(self, amount: np.ndarray, color, x0: int, y0: int) -> None:
        """Screen-blend ``color`` onto existing content (glows); alpha kept."""
        h, w = amount.shape
        r = self.region(x0, y0, x0 + w, y0 + h)
        if r is None:
            return
        bx0, by0, bx1, by1 = r
        sx0, sy0 = bx0 - x0, by0 - y0
        m = amount[sy0:sy0 + by1 - by0, sx0:sx0 + bx1 - bx0][..., None]
        a = self.a[by0:by1, bx0:bx1][..., None]
        s = hex_rgb(color) * m
        cur = self.rgb[by0:by1, bx0:bx1]
        # screen blend in premultiplied form: out = rgb + s * (a - rgb)
        self.rgb[by0:by1, bx0:bx1] = cur + s * (a - cur)

    def to_image(self) -> Image.Image:
        a = np.clip(self.a, 0.0, 1.0)
        safe = np.where(a > 1e-5, a, 1.0)[..., None]
        rgb = np.clip(self.rgb / safe, 0.0, 1.0)
        out = np.dstack([rgb, a[..., None]])
        return Image.fromarray(np.ascontiguousarray((out * 255.0 + 0.5).astype(np.uint8)))


def downsample(img: Image.Image, factor: int) -> Image.Image:
    """Premultiplied Lanczos reduction so transparent edges do not darken."""
    if factor <= 1:
        return img
    size = (img.width // factor, img.height // factor)
    arr = np.asarray(img.convert("RGBA"), dtype=np.float32) / 255.0
    premul = arr.copy()
    premul[..., :3] *= premul[..., 3:4]
    chans = [Image.fromarray(np.ascontiguousarray(premul[..., i])).resize(size, Image.Resampling.LANCZOS)
             for i in range(4)]
    out = np.dstack([np.asarray(c) for c in chans])
    a = np.clip(out[..., 3], 0.0, 1.0)
    safe = np.where(a > 1e-5, a, 1.0)[..., None]
    rgb = np.clip(out[..., :3] / safe, 0.0, 1.0)
    rgba = np.dstack([rgb, a[..., None]])
    return Image.fromarray(np.ascontiguousarray((rgba * 255.0 + 0.5).astype(np.uint8)))


# --------------------------------------------------------------------------- morphology
def shift(a: np.ndarray, dx: float, dy: float) -> np.ndarray:
    dx, dy = int(round(dx)), int(round(dy))
    out = np.zeros_like(a)
    h, w = a.shape[:2]
    if abs(dx) >= w or abs(dy) >= h:
        return out
    src = a[max(0, -dy):h - max(0, dy), max(0, -dx):w - max(0, dx)]
    out[max(0, dy):max(0, dy) + src.shape[0], max(0, dx):max(0, dx) + src.shape[1]] = src
    return out


def _run(a: np.ndarray, r: int, fn) -> np.ndarray:
    out = a.copy()
    for d in range(1, r + 1):
        out = fn(out, shift(a, d, 0))
        out = fn(out, shift(a, -d, 0))
    row = out.copy()
    for d in range(1, r + 1):
        out = fn(out, shift(row, 0, d))
        out = fn(out, shift(row, 0, -d))
    return out


def dilate(a: np.ndarray, r: float) -> np.ndarray:
    r = int(round(r))
    return a if r <= 0 else _run(a, r, np.maximum)


def erode(a: np.ndarray, r: float) -> np.ndarray:
    r = int(round(r))
    if r <= 0:
        return a
    padded = np.pad(a, r, mode="edge")
    return _run(padded, r, np.minimum)[r:-r, r:-r]


def box_blur(a: np.ndarray, r: int) -> np.ndarray:
    if r <= 0:
        return a
    r = int(r)
    out = a.astype(np.float32)
    for axis in (0, 1):
        pad = [(0, 0)] * out.ndim
        pad[axis] = (r + 1, r)
        c = np.cumsum(np.pad(out, pad, mode="edge"), axis=axis, dtype=np.float64)
        n = c.shape[axis]
        hi = np.take(c, np.arange(2 * r + 1, n), axis=axis)
        lo = np.take(c, np.arange(0, n - 2 * r - 1), axis=axis)
        out = ((hi - lo) / (2 * r + 1)).astype(np.float32)
    return out


def blur(a: np.ndarray, radius: float) -> np.ndarray:
    """Approximate gaussian of ~``radius`` px: three box passes."""
    r = int(round(radius / 1.7))
    if r <= 0:
        return a.astype(np.float32)
    for _ in range(3):
        a = box_blur(a, r)
    return a


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / np.maximum(e1 - e0, 1e-6), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


# --------------------------------------------------------------------------- noise
def value_noise(h: int, w: int, cell: float, rng: np.random.Generator, octaves: int = 3) -> np.ndarray:
    """Smooth noise in 0..1 with feature size ~``cell`` px."""
    total = np.zeros((h, w), dtype=np.float32)
    amp, norm = 1.0, 0.0
    for o in range(octaves):
        c = max(2.0, cell / (2 ** o))
        gw, gh = max(2, int(w / c) + 3), max(2, int(h / c) + 3)
        grid = rng.random((gh, gw), dtype=np.float32)
        img = Image.fromarray(grid).resize((max(w + 2, int(gw * c)), max(h + 2, int(gh * c))),
                                           Image.Resampling.BICUBIC)
        arr = np.asarray(img)
        oy = int(rng.integers(0, max(1, arr.shape[0] - h)))
        ox = int(rng.integers(0, max(1, arr.shape[1] - w)))
        total += amp * arr[oy:oy + h, ox:ox + w]
        norm += amp
        amp *= 0.5
    t = total / norm
    lo, hi = np.percentile(t, 2), np.percentile(t, 98)
    return np.clip((t - lo) / max(hi - lo, 1e-6), 0.0, 1.0)


# --------------------------------------------------------------------------- brush field
def stroke_field(h: int, w: int, stamp: Image.Image, rng: np.random.Generator, angle: float = 0.0,
                 jitter: float = 12.0, density: float = 1.2, variants: int = 7,
                 mask: np.ndarray | None = None) -> np.ndarray:
    """Field in -1..1 built from rotated icon stamps (the 'brush marks').

    ``angle`` is the stroke direction in degrees (0 = horizontal, clockwise positive).
    Stamps are only placed where ``mask`` > 0.3 when a mask is given.
    """
    field = np.zeros((h, w), dtype=np.float32)
    stamps = []
    for i in range(variants):
        a = angle + (i / max(1, variants - 1) - 0.5) * 2.0 * jitter
        img = stamp.rotate(-a, resample=Image.Resampling.BICUBIC, expand=True)
        stamps.append(np.asarray(img, dtype=np.float32) / 255.0)
    area = float(np.mean([s.sum() for s in stamps])) or 1.0
    count = int(density * h * w / area)
    if count <= 0:
        return field
    xs = rng.integers(0, w, count)
    ys = rng.integers(0, h, count)
    if mask is not None:
        keep = mask[ys, xs] > 0.3
        xs, ys = xs[keep], ys[keep]
    vals = rng.uniform(-1.0, 1.0, len(xs)).astype(np.float32)
    picks = rng.integers(0, len(stamps), len(xs))
    for x, y, v, p in zip(xs, ys, vals, picks):
        s = stamps[p]
        sh, sw = s.shape
        x0, y0 = int(x) - sw // 2, int(y) - sh // 2
        ax0, ay0 = max(0, x0), max(0, y0)
        ax1, ay1 = min(w, x0 + sw), min(h, y0 + sh)
        if ax1 <= ax0 or ay1 <= ay0:
            continue
        field[ay0:ay1, ax0:ax1] += v * s[ay0 - y0:ay1 - y0, ax0 - x0:ax1 - x0]
    return np.tanh(field * 0.9)


# --------------------------------------------------------------------------- shading
def lambert(m: np.ndarray, radius: float, bump: float, light3) -> np.ndarray:
    """Pseudo-3D light term (-1..1) of a mask treated as a soft dome."""
    hgt = blur(m, radius)
    gy, gx = np.gradient(hgt)
    k = bump * radius * 2.2
    nx, ny = -gx * k, -gy * k
    norm = np.sqrt(nx * nx + ny * ny + 1.0)
    lx, ly, lz = light3
    return (nx * lx + ny * ly + lz) / norm


def crescent(a: np.ndarray, dx: float, dy: float) -> np.ndarray:
    """Part of ``a`` uncovered when ``a`` is moved by (dx, dy).

    With (dx, dy) toward the light this is the far (shadow-side) rim.
    """
    return np.clip(a - shift(a, dx, dy), 0.0, 1.0)


def extrude_down(a: np.ndarray, depth: float) -> tuple[np.ndarray, np.ndarray]:
    """Visible front faces of a prism whose top face is ``a``, dropped ``depth`` px.

    Returns (side_alpha, t) with t in 0..1 = how far down the side a pixel is.
    """
    depth = max(1, int(round(depth)))
    cover = a.copy()
    first = np.zeros_like(a)
    for t in range(1, depth + 1):
        moved = shift(a, 0, t)
        new = np.clip(moved - cover, 0.0, 1.0)
        first += new * (t / float(depth))
        cover = np.maximum(cover, moved)
    side = np.clip(cover - a, 0.0, 1.0)
    tt = np.where(side > 1e-4, first / np.maximum(side, 1e-4), 0.0)
    return side, np.clip(tt, 0.0, 1.0)


def edge_band(m: np.ndarray, width: float, heavy: float, light2, breaks: float = 0.0,
              noise: np.ndarray | None = None) -> np.ndarray:
    """Inner line band of ``m``: ``width`` all round plus ``heavy`` extra on the shadow side.

    ``breaks`` (0..1) removes parts of the thin line where ``noise`` is low, which
    reads as the line lifting off on the lit side.
    """
    thin = np.clip(m - erode(m, max(1.0, width)), 0.0, 1.0)
    if breaks > 0.0 and noise is not None:
        thin = thin * smoothstep(breaks - 0.1, breaks + 0.1, noise)
    if heavy <= 0.0:
        return thin
    lx, ly = light2
    heavy_band = crescent(m, lx * (width + heavy), ly * (width + heavy))
    return np.maximum(thin, heavy_band)


def roughen(m: np.ndarray, noise: np.ndarray, amp: float, soft: float) -> np.ndarray:
    """Irregular, brush-like silhouette: threshold a softened mask against noise."""
    if amp <= 0.0:
        return m
    s = blur(m, max(1.0, soft))
    thr = 0.5 + (noise - 0.5) * amp
    return smoothstep(thr - 0.08, thr + 0.08, s)
