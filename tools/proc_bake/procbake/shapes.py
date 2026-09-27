"""The body part shape library.

A part is a hand-authored SVG.  Two things live in the file:

  * the silhouette   - a <path>, viewBox units, +X is the growth direction,
                       y grows downward (screen convention, same as the engine)
  * the spine        - data-joints="x0,y0 x1,y1 x2,y2", the centreline a child
                       part attaches to.  First point is the part's own origin.

    <svg viewBox="0 0 96 40" data-name="limb_femur"
         data-joints="0,20 32,17 64,12 96,8">
      <path d="..."/>
    </svg>

Optional data-* keys:
    data-flip     "y" mirrors the silhouette across the spine (a left leg)
    data-detail   "1" paints the part on top of the fused body instead of
                  fusing into it (an eye, a mouth, a belly patch)

Nothing here is procedural.  A shape is a drawing.  The creature spec decides
where it goes and how it moves.
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np

from . import svgpath


class Shape:
    __slots__ = ("name", "contours", "spine", "length", "flip", "detail", "bounds", "meta")

    def __init__(self, name: str, contours, spine: np.ndarray, meta: dict):
        self.name = name
        self.contours = [np.asarray(c, dtype=np.float64) for c in contours]
        # Spine in part-local coordinates: the SVG origin (joints[0]) is (0, 0).
        self.spine = spine - spine[0]
        self.length = float(_polyline_length(self.spine))
        self.flip = str(meta.get("flip", "")).lower()
        self.detail = str(meta.get("detail", "")).strip() not in ("", "0", "false")
        self.meta = meta
        pts = np.concatenate(self.contours, axis=0)
        self.bounds = (float(pts[:, 0].min()), float(pts[:, 1].min()),
                       float(pts[:, 0].max()), float(pts[:, 1].max()))

    def spine_at(self, t: float) -> np.ndarray:
        """Point at normalised arc length t along the spine, part-local."""
        t = min(max(t, 0.0), 1.0)
        if len(self.spine) == 1:
            return self.spine[0]
        lengths = np.linalg.norm(np.diff(self.spine, axis=0), axis=1)
        total = float(lengths.sum())
        if total <= 1e-9:
            return self.spine[0]
        want = t * total
        acc = 0.0
        for i, seg in enumerate(lengths):
            if acc + seg >= want or i == len(lengths) - 1:
                local = (want - acc) / max(seg, 1e-9)
                return self.spine[i] + (self.spine[i + 1] - self.spine[i]) * local
            acc += seg
        return self.spine[-1]

    def spine_dir_at(self, t: float) -> np.ndarray:
        a = self.spine_at(max(t - 0.06, 0.0))
        b = self.spine_at(min(t + 0.06, 1.0))
        d = b - a
        n = float(np.linalg.norm(d))
        return d / n if n > 1e-9 else np.array([1.0, 0.0])

    def transformed(self, position, rotation: float, scale: float, squash=None) -> list:
        """Contours placed into world space.

        `squash` is (along, across, axis_rad) for a limb that compressed along
        its own bone; the area-preserving 1/across rule is the engine's.
        """
        pts = []
        for contour in self.contours:
            p = (contour - self.spine[0]) * (1.0 if "y" not in self.flip else -1.0)
            p = p.copy()
            if "y" in self.flip:
                p[:, 1] *= -1.0
            if "x" in self.flip:
                p[:, 0] *= -1.0
            p *= scale
            if squash is not None:
                along, across, axis = squash
                if along != 1.0 or across != 1.0:
                    base = np.array([[along, 0.0], [0.0, across]], dtype=np.float64)
                    rot = np.array([[math.cos(axis), -math.sin(axis)],
                                    [math.sin(axis), math.cos(axis)]], dtype=np.float64)
                    p = (rot @ base @ rot.T) @ p.T
                    p = p.T
            c, s = math.cos(rotation), math.sin(rotation)
            p = p @ np.array([[c, s], [-s, c]], dtype=np.float64)
            p += np.asarray(position, dtype=np.float64)
            pts.append(p)
        return pts

    def world_bbox(self, position, rotation: float, scale: float, squash=None, pad: float = 0.0):
        pts = np.concatenate(self.transformed(position, rotation, scale, squash), axis=0)
        return (float(pts[:, 0].min()) - pad, float(pts[:, 1].min()) - pad,
                float(pts[:, 0].max()) + pad, float(pts[:, 1].max()) + pad)


class ShapeLibrary:
    def __init__(self, directories):
        self.shapes: dict[str, Shape] = {}
        self.sources: dict[str, str] = {}
        for directory in directories:
            directory = Path(directory)
            if not directory.is_dir():
                continue
            for path in sorted(directory.glob("*.svg")):
                self.add(path)

    def add(self, path) -> Shape:
        data = svgpath.read_svg(path)
        meta = dict(data["meta"])
        name = str(meta.get("name") or Path(path).stem)
        shape = Shape(name, data["contours"], svgpath.parse_joints(meta), meta)
        self.shapes[name] = shape
        self.sources[name] = str(path)
        return shape

    def get(self, name: str) -> Shape:
        if name not in self.shapes:
            near = [n for n in sorted(self.shapes) if name in n]
            hint = f"; did you mean {near[:5]}?" if near else f"; library has {sorted(self.shapes)}"
            raise KeyError(f"unknown shape {name!r}{hint}")
        return self.shapes[name]

    def names(self) -> list:
        return sorted(self.shapes)


def _polyline_length(points: np.ndarray) -> float:
    if len(points) < 2:
        return 0.0
    return float(np.linalg.norm(np.diff(points, axis=0), axis=1).sum())
