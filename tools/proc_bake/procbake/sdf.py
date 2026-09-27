"""Signed distance fields on a numpy grid.

Everything the renderer needs: distance to hand-authored polygons, smooth
union (so a stack of body parts reads as one animal instead of a pile of
shapes), antialiased coverage, and a shifted sample for the light/shade bands.

Sign convention matches core/procedural/raster/sdf.gd: negative inside, zero on
the boundary, positive outside.  The magnitude is the true Euclidean distance to
the nearest edge, so `smooth_min` on two real distance fields behaves the way
the Godot engine's does.
"""

from __future__ import annotations

import numpy as np

# Pixels evaluated per inner-loop chunk.  Each pair costs ~10 flops, so 4M pairs
# is a few tens of MB of temporaries - comfortably inside cache-friendly range.
_CHUNK_PAIRS = 4_000_000


def _edges(contours) -> tuple[np.ndarray, np.ndarray]:
    a_list, b_list = [], []
    for contour in contours:
        pts = np.asarray(contour, dtype=np.float64)
        if len(pts) < 3:
            continue
        a_list.append(pts)
        b_list.append(np.roll(pts, -1, axis=0))
    if not a_list:
        raise ValueError("no contour with 3+ points")
    return np.concatenate(a_list, axis=0), np.concatenate(b_list, axis=0)


def poly_sdf_points(contours, pts: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Signed distance of the even-odd fill at scattered `pts`.

    This is the workhorse: the renderer transforms canvas pixel centres into a
    part's local frame and asks here, so one code path serves an unrotated bake
    and a squashed, spun, scaled animation frame.

    Returns (distance, inside) as float32/float32 arrays of len(pts).
    """
    pts = np.asarray(pts, dtype=np.float64).reshape(-1, 2)
    a, b = _edges(contours)
    ab = b - a
    ab2 = np.maximum((ab * ab).sum(axis=1), 1e-12)
    count = len(ab)
    dist_out = np.empty(len(pts), dtype=np.float32)
    inside_out = np.zeros(len(pts), dtype=np.float32)
    step = max(1, int(_CHUNK_PAIRS // max(count, 1)))
    for i0 in range(0, len(pts), step):
        i1 = min(i0 + step, len(pts))
        p = pts[i0:i1]
        dx = p[:, 0][:, None] - a[None, :, 0]           # (n, E)
        dy = p[:, 1][:, None] - a[None, :, 1]
        t = np.clip((dx * ab[None, :, 0] + dy * ab[None, :, 1]) / ab2, 0.0, 1.0)
        ex = dx - t * ab[None, :, 0]
        ey = dy - t * ab[None, :, 1]
        dist = np.sqrt(ex * ex + ey * ey).min(axis=1)
        ay = a[None, :, 1]
        by = b[None, :, 1]
        straddles = (ay > p[:, 1][:, None]) != (by > p[:, 1][:, None])
        safe = np.where(straddles, by - ay, 1.0)
        xint = a[None, :, 0] + (p[:, 1][:, None] - ay) / safe * ab[None, :, 0]
        crossings = (straddles & (p[:, 0][:, None] < xint)).sum(axis=1)
        dist_out[i0:i1] = dist.astype(np.float32)
        inside_out[i0:i1] = (crossings % 2 == 1).astype(np.float32)
    signed = np.where(inside_out > 0.5, -dist_out, dist_out)
    return signed, inside_out


def poly_sdf(contours, x0: float, y0: float, w: int, h: int) -> np.ndarray:
    """Signed distance of the even-odd fill of `contours` over an (h, w) window.

    `x0`/`y0` are the window's top-left in the same units as the contours.  Pixel
    (col, row) samples at (x0 + col + 0.5, y0 + row + 0.5).
    """
    a, b = _edges(contours)
    ab = b - a                                   # (E, 2)
    ab2 = np.maximum((ab * ab).sum(axis=1), 1e-12)
    cols = x0 + np.arange(w, dtype=np.float64) + 0.5
    rows = y0 + np.arange(h, dtype=np.float64) + 0.5
    count = len(ab)
    out = np.empty((h, w), dtype=np.float32)
    step = max(1, int(_CHUNK_PAIRS // max(count, 1)))
    for y0i in range(0, h, step):
        y1i = min(y0i + step, h)
        py = rows[y0i:y1i][:, None]               # (c, 1)
        dx = cols[None, :, None] - a[None, None, :, 0]   # (c, w, E)
        dy = py - a[None, None, :, 1]
        t = np.clip((dx * ab[None, None, :, 0] + dy * ab[None, None, :, 1]) / ab2, 0.0, 1.0)
        ex = dx - t * ab[None, None, :, 0]
        ey = dy - t * ab[None, None, :, 1]
        dist = np.sqrt(ex * ex + ey * ey).min(axis=2)     # (c, w)
        # even-odd crossing test toward +x
        ay = a[None, None, :, 1]
        by = b[None, None, :, 1]
        straddles = (ay > py) != (by > py)
        safe = np.where(straddles, by - ay, 1.0)
        xint = a[None, None, :, 0] + (py - ay) / safe * ab[None, None, :, 0]
        crossings = (straddles & (cols[None, :, None] < xint)).sum(axis=2)
        inside = (crossings % 2) == 1
        out[y0i:y1i] = np.where(inside, -dist, dist).astype(np.float32)
    return out


def sdf_of(contours, w: int, h: int, pad: float = 2.0) -> tuple[np.ndarray, float, float]:
    """Whole-frame SDF plus the frame origin that was used."""
    all_pts = np.concatenate([np.asarray(c, dtype=np.float64) for c in contours], axis=0)
    ox = float(all_pts[:, 0].min()) - pad
    oy = float(all_pts[:, 1].min()) - pad
    return poly_sdf(contours, ox, oy, w, h), ox, oy


def smooth_min(a: np.ndarray, b: np.ndarray, blend: float) -> np.ndarray:
    """Polynomial smooth minimum - the soft join that makes limbs read as a body."""
    if blend <= 0.0:
        return np.minimum(a, b)
    h = np.clip(0.5 + 0.5 * (b - a) / blend, 0.0, 1.0)
    return b + (a - b) * h - blend * h * (1.0 - h)


def smooth_max(a: np.ndarray, b: np.ndarray, blend: float) -> np.ndarray:
    return -smooth_min(-a, -b, blend)


def coverage(distance: np.ndarray, feather: float = 1.0) -> np.ndarray:
    """Antialiased 0..1 coverage, `feather` pixels wide, matching sdf.gd."""
    return np.clip(0.5 - distance / max(feather, 1e-4), 0.0, 1.0)


def shifted(field: np.ndarray, dx: float, dy: float) -> np.ndarray:
    """field sampled at (x + dx, y + dy), clamped at the border.

    This is what makes a crescent: the part of the silhouette that survives when
    the whole shape is nudged toward the light is the lit edge, and the part that
    survives a nudge away from the light is the shade band.  Offsets round to whole
    pixels because a cel band that lands between pixels is just a blur.
    """
    sx, sy = int(round(dx)), int(round(dy))
    if sx == 0 and sy == 0:
        return field
    h, w = field.shape
    out = np.empty_like(field)
    # destination (x, y) reads source (x - sx, y - sy), clamped at the border
    src_x0, src_x1 = max(0, -sx), min(w, w - sx)
    dst_x0, dst_x1 = max(0, sx), min(w, w + sx)
    src_y0, src_y1 = max(0, -sy), min(h, h - sy)
    dst_y0, dst_y1 = max(0, sy), min(h, h + sy)
    if dst_x0 >= dst_x1 or dst_y0 >= dst_y1:
        return field
    out[dst_y0:dst_y1, dst_x0:dst_x1] = field[src_y0:src_y1, src_x0:src_x1]
    if sy > 0:
        out[:dst_y0] = field[0]
    elif sy < 0:
        out[dst_y1:] = field[h - 1]
    if sx > 0:
        out[:, :dst_x0] = out[:, dst_x0:dst_x0 + 1]
    elif sx < 0:
        out[:, dst_x1:] = out[:, dst_x1 - 1:dst_x1]
    return out
