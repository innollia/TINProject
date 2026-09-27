"""Straight-alpha RGBA float canvas, composited the way core/procedural does it.

Premultiplication is deliberately avoided: the engine's ProceduralCanvas stores
straight alpha and blends source-over, and a bake that previews a different
gamma looks like a different creature.  Bands are painted from a distance field
in the same layer order the engine uses:

    1. ink        a stroke of the outline, laid down *first* so the fill covers
                  its inner half - the result is a line that sits outside the
                  silhouette, which is what reads as Rain World
    2. fill       body_role
    3. shade      a crescent on the side away from the light
    4. key        a 1px lit edge, or a rim_role edge
"""

from __future__ import annotations

import numpy as np
from PIL import Image

# Light comes from the upper left, on a y-down screen.  Same constant as
# ProceduralBodyPart._LIGHT_DIRECTION.
LIGHT = np.array([-0.70710678, -0.70710678], dtype=np.float64)

LAYER_INK = 0
LAYER_FILL = 1
LAYER_SHADE = 2
LAYER_KEY = 3


class Canvas:
    def __init__(self, width: int, height: int):
        self.width = max(int(width), 1)
        self.height = max(int(height), 1)
        # straight alpha, float32, (h, w, 4)
        self.px = np.zeros((self.height, self.width, 4), dtype=np.float32)

    # ------------------------------------------------------------------ blending
    def blend(self, x: int, y: int, color, alpha: float) -> None:
        if not (0 <= x < self.width and 0 <= y < self.height):
            return
        src_a = float(color[3]) * float(alpha)
        if src_a <= 0.0:
            return
        i = x + y * self.width
        dst = self.px[i]
        if src_a >= 1.0:
            self.px[i] = (color[0], color[1], color[2], color[3])
            return
        out_a = src_a + float(dst[3]) * (1.0 - src_a)
        if out_a <= 0.0:
            self.px[i] = (0.0, 0.0, 0.0, 0.0)
            return
        carry = float(dst[3]) * (1.0 - src_a)
        self.px[i] = (
            (color[0] * src_a + float(dst[0]) * carry) / out_a,
            (color[1] * src_a + float(dst[1]) * carry) / out_a,
            (color[2] * src_a + float(dst[2]) * carry) / out_a,
            out_a,
        )

    def blend_mask(self, color, coverage: np.ndarray) -> None:
        """Composite a flat colour through a 0..1 coverage mask."""
        if not coverage.any():
            return
        src_a = float(color[3])
        if src_a <= 0.0:
            return
        cov = coverage[:, :, None] * src_a
        if src_a >= 1.0:
            out_a = cov[:, :, 0]
        else:
            out_a = cov[:, :, 0] + self.px[:, :, 3] * (1.0 - cov[:, :, 0])
        safe = np.where(out_a[:, :, None] > 1e-6, out_a[:, :, None], 1.0)
        carry = self.px[:, :, 3:4] * (1.0 - cov)
        rgb = (np.asarray(color[:3], dtype=np.float32)[None, None, :] * cov + self.px[:, :, :3] * carry) / safe
        self.px[:, :, :3] = np.clip(rgb, 0.0, 1.0)
        self.px[:, :, 3] = np.where(out_a > 1e-6, out_a, 0.0)

    def draw_polygon(self, points, color, alpha: float = 1.0) -> None:
        """Scanline fill of one closed contour."""
        import numpy as _np
        pts = _np.asarray(points, dtype=_np.float64).reshape(-1, 2)
        if len(pts) < 3:
            return
        y_lo = max(0, int(_np.floor(pts[:, 1].min())))
        y_hi = min(self.height, int(_np.ceil(pts[:, 1].max())) + 1)
        for y in range(y_lo, y_hi):
            scan = y + 0.5
            xs: list[float] = []
            for i in range(len(pts)):
                a, b = pts[i], pts[(i + 1) % len(pts)]
                if (a[1] <= scan < b[1]) or (b[1] <= scan < a[1]):
                    xs.append(a[0] + (scan - a[1]) / (b[1] - a[1]) * (b[0] - a[0]))
            if not xs:
                continue
            xs.sort()
            for k in range(0, len(xs) - 1, 2):
                x0 = max(0, int(_np.ceil(xs[k] - 0.5)))
                x1 = min(self.width, int(_np.floor(xs[k + 1] - 0.5)) + 1)
                for x in range(x0, x1):
                    self.blend(x, y, color, alpha)

    def draw_line(self, a, b, color, width: float = 1.0, alpha: float = 1.0) -> None:
        steps = max(int(np.ceil(np.dist(a, b) * 2.0)), 1)
        for i in range(steps + 1):
            t = i / steps
            self.draw_circle((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t),
                             max(width, 0.5) * 0.5, color, alpha)

    def draw_circle(self, center, radius: float, color, alpha: float = 1.0) -> None:
        r = max(float(radius), 0.0)
        if r <= 0.0:
            return
        x0 = max(0, int(np.floor(center[0] - r)))
        x1 = min(self.width, int(np.ceil(center[0] + r)) + 1)
        y0 = max(0, int(np.floor(center[1] - r)))
        y1 = min(self.height, int(np.ceil(center[1] + r)) + 1)
        for y in range(y0, y1):
            dy = y + 0.5 - center[1]
            if abs(dy) > r:
                continue
            span = float(np.sqrt(max(r * r - dy * dy, 0.0)))
            px0 = max(0, int(np.ceil(center[0] - span - 0.5)))
            px1 = min(self.width, int(np.floor(center[0] + span - 0.5)) + 1)
            for x in range(px0, px1):
                self.blend(x, y, color, alpha)

    # ------------------------------------------------------------------ field paint
    def paint_field(self, field: np.ndarray, color, *, feather: float = 1.0) -> None:
        from .sdf import coverage
        self.blend_mask(color, coverage(field, feather))

    def paint_ink(self, field: np.ndarray, color, width: float, *, feather: float = 1.0) -> None:
        """A closed stroke hugging d = 0.  Painted before the fill."""
        from .sdf import coverage
        if width <= 0.0:
            return
        self.blend_mask(color, coverage(np.abs(field) - width * 0.5, feather))

    def paint_shade(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0) -> None:
        """Crescent on the side away from the light, like _LAYER_CRESCENT."""
        from .sdf import coverage
        if depth <= 0.0:
            return
        dx = -LIGHT[0] * depth
        dy = -LIGHT[1] * depth
        away = _shift(field, dx, dy)
        self.blend_mask(color, coverage(np.maximum(field, -away), feather))

    def paint_key(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0) -> None:
        """1px lit edge on the side facing the light."""
        from .sdf import coverage
        dx = LIGHT[0] * depth
        dy = LIGHT[1] * depth
        toward = _shift(field, dx, dy)
        self.blend_mask(color, coverage(np.maximum(field, -toward), feather))

    def paint_rim(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0) -> None:
        from .sdf import coverage
        dx = LIGHT[0] * depth
        dy = LIGHT[1] * depth
        toward = _shift(field, dx, dy)
        self.blend_mask(color, coverage(np.maximum(field, -toward), feather))

    # ------------------------------------------------------------------ output
    def used_rect(self) -> tuple[int, int, int, int]:
        alpha = self.px[:, :, 3]
        rows = np.where(alpha.max(axis=1) > 0)[0]
        cols = np.where(alpha.max(axis=0) > 0)[0]
        if not len(rows) or not len(cols):
            return (0, 0, 0, 0)
        return (int(cols[0]), int(rows[0]), int(cols[-1]) + 1, int(rows[-1]) + 1)

    def to_rgba8(self) -> np.ndarray:
        out = np.clip(self.px, 0.0, 1.0) * 255.0
        return out.astype(np.uint8)

    def to_image(self) -> Image.Image:
        return Image.fromarray(self.to_rgba8(), mode="RGBA")

    def save(self, path) -> None:
        self.to_image().save(str(path))

    def copy(self) -> "Canvas":
        other = Canvas(self.width, self.height)
        other.px = self.px.copy()
        return other


def _shift(field: np.ndarray, dx: float, dy: float) -> np.ndarray:
    from .sdf import shifted
    return shifted(field, dx, dy)
