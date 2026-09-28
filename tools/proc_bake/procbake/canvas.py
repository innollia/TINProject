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

import math

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
        dst = self.px[y, x]
        if src_a >= 1.0:
            self.px[y, x] = (color[0], color[1], color[2], color[3])
            return
        out_a = src_a + float(dst[3]) * (1.0 - src_a)
        if out_a <= 0.0:
            self.px[y, x] = (0.0, 0.0, 0.0, 0.0)
            return
        carry = float(dst[3]) * (1.0 - src_a)
        self.px[y, x] = (
            (color[0] * src_a + float(dst[0]) * carry) / out_a,
            (color[1] * src_a + float(dst[1]) * carry) / out_a,
            (color[2] * src_a + float(dst[2]) * carry) / out_a,
            out_a,
        )

    def blend_mask(self, color, coverage: np.ndarray, x0: int = 0, y0: int = 0) -> None:
        """Composite a flat colour through a 0..1 coverage mask.

        The mask may cover only a window of this canvas; `x0`/`y0` say where.
        Everything outside the window is left alone, so a part can be rasterised
        into just its own bounding box instead of the whole frame.
        """
        if not coverage.any():
            return
        h, w = coverage.shape
        x1, y1 = min(self.width, x0 + w), min(self.height, y0 + h)
        cx0, cy0 = max(0, x0), max(0, y0)
        if x1 <= cx0 or y1 <= cy0:
            return
        cov = coverage[cy0 - y0:y1 - y0, cx0 - x0:x1 - x0, None] * float(color[3])
        dst_a = self.px[cy0:y1, cx0:x1, 3:4]
        out_a = cov + dst_a * (1.0 - cov)
        safe = np.where(out_a > 1e-6, out_a, 1.0)
        carry = dst_a * (1.0 - cov)
        rgb = (np.asarray(color[:3], dtype=np.float32) * cov + self.px[cy0:y1, cx0:x1, :3] * carry) / safe
        self.px[cy0:y1, cx0:x1, :3] = np.clip(rgb, 0.0, 1.0)
        self.px[cy0:y1, cx0:x1, 3] = np.where(out_a[:, :, 0] > 1e-6, out_a[:, :, 0], 0.0)

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
        steps = max(int(np.ceil(math.dist(a, b) * 2.0)), 1)
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
    def paint_field(self, field: np.ndarray, color, *, feather: float = 1.0,
                    x0: int = 0, y0: int = 0) -> None:
        from .sdf import coverage
        self.blend_mask(color, coverage(field, feather), x0, y0)

    def paint_ink(self, field: np.ndarray, color, width: float, *, feather: float = 1.0,
                  x0: int = 0, y0: int = 0) -> None:
        """A contour hugging d = 0, sitting OUTSIDE the silhouette.

        The band is `0 <= d <= width`, from `abs(d - width/2) - width/2`.  The
        sign matters and was wrong at first: `abs(d + width/2) - width/2` is the
        band `-width <= d <= 0`, which is entirely INSIDE.  The fill is opaque
        and goes on afterwards, so an inner band is painted and then completely
        covered - leaving nothing but the fill's own antialiased edge darkened
        by half-strength ink.  That reads as a contour at 40px, which is why it
        survived, and as no contour at all on a 1280x720 pipe crossing 900px.

        Outward-biased, the whole width shows and the line reads as drawn.
        """
        from .sdf import coverage
        if width <= 0.0:
            return
        half = width * 0.5
        self.blend_mask(color, coverage(np.abs(field - half) - half, feather), x0, y0)

    def _rim_band(self, field: np.ndarray, depth: float, feather: float, lit: bool) -> np.ndarray:
        """Cel band hugging one side of the silhouette, interior pixels only.

        Two things were wrong here and both showed up on every creature.  The
        band was never masked to the interior, so the "shade" also painted the
        whole region outside the shape: a dark grubby halo round every animal,
        and a band larger than the body it was shading.  And the two sides were
        swapped, so the shadow fell on the lit edge.

        The band is the set of pixels the shape would stop covering if it slid
        toward the light.  `lit` picks which side that leaves.

        Note the sign: `shifted(field, +d, +d)` samples UP-LEFT, and the band it
        produces is the up-left one - the band appears on the side that was
        sampled, not the side that would be exposed.  Both halves of this were
        backwards at once in the first version, which put the shadow on the lit
        edge.
        """
        from .sdf import coverage
        if depth <= 0.0:
            return np.zeros_like(field)
        step = -LIGHT if lit else LIGHT
        probe = shifted(field, step[0] * depth, step[1] * depth)
        band = coverage(np.maximum(field, -probe), feather)
        # inside only: a shade outside the silhouette is a halo, not a shadow
        band = np.where(field < 0.0, band, 0.0)
        # and only near the rim: a fused creature is full of interior valleys
        # where a limb meets the torso, and shading those reads as dirt
        inner = coverage(np.minimum(field + depth, 1e6), feather)
        return band * (1.0 - inner)

    def paint_shade(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0,
                    x0: int = 0, y0: int = 0) -> None:
        """Crescent on the side away from the light."""
        self.blend_mask(color, self._rim_band(field, depth, feather, lit=False), x0, y0)

    def paint_key(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0,
                  x0: int = 0, y0: int = 0) -> None:
        """Lit edge on the side facing the light."""
        self.blend_mask(color, self._rim_band(field, depth, feather, lit=True), x0, y0)

    def paint_rim(self, field: np.ndarray, color, depth: float, *, feather: float = 1.0,
                  x0: int = 0, y0: int = 0) -> None:
        self.blend_mask(color, self._rim_band(field, depth, feather, lit=True), x0, y0)

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


from .sdf import shifted  # noqa: E402  (import cycle: sdf does not import canvas)
