"""SVG path -> flat polygons.

Only the commands a hand-authored body part needs: M L H V C S Q T Z (and the
lowercase relative forms).  Arcs and implicit oddities are not supported on
purpose - raise instead of guessing a shape.

`parse_path` returns a list of contours, each an (N, 2) float64 array of viewBox
coordinates, in order, with the closing point NOT repeated.  Subpaths are kept
separate so the SDF can apply an even-odd fill rule (holes work).
"""

from __future__ import annotations

import math
import re
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np

_TOKEN = re.compile(r"[MmLlHhVvCcSsQqTtZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")

# Flatness: a curve is subdivided until it deviates less than this, in viewBox
# units.  Small enough that a 0.5px antialiased edge has no visible facets.
_TOLERANCE = 0.08
_MIN_STEPS = 2
_MAX_STEPS = 24


class SvgError(ValueError):
    pass


def parse_path(d: str) -> list[np.ndarray]:
    """Flatten one path `d` attribute into closed contours."""
    tokens = _TOKEN.findall(d)
    contours: list[np.ndarray] = []
    current: list[tuple[float, float]] = []
    cursor = (0.0, 0.0)
    start = (0.0, 0.0)
    # cubic control point memory, for S/T
    last_cubic: tuple[float, float] | None = None
    last_quad: tuple[float, float] | None = None
    command = ""
    index = 0

    def flush() -> None:
        nonlocal current
        if len(current) >= 3:
            contours.append(np.asarray(current, dtype=np.float64))
        current = []

    def take(n: int) -> list[float]:
        nonlocal index
        out: list[float] = []
        while len(out) < n:
            if index >= len(tokens):
                raise SvgError(f"path ended early, wanted {n} numbers after {command!r}")
            token = tokens[index]
            if token.isalpha():
                raise SvgError(f"path ended early, wanted {n} numbers after {command!r}")
            out.append(float(token))
            index += 1
        return out

    while index < len(tokens):
        token = tokens[index]
        if token.isalpha():
            command = token
            index += 1
            if command in "Zz":
                if current:
                    current.append(start)
                    flush()
                cursor = start
                last_cubic = last_quad = None
                continue
        elif not command:
            raise SvgError("path starts with a number")

        rel = command.islower()
        upper = command.upper()

        if upper == "M":
            x, y = take(2)
            cursor = (cursor[0] + x, cursor[1] + y) if rel else (x, y)
            flush()
            start = cursor
            current = [cursor]
            command = "l" if rel else "L"          # extra pairs are implicit lineto
            last_cubic = last_quad = None
        elif upper == "L":
            x, y = take(2)
            cursor = (cursor[0] + x, cursor[1] + y) if rel else (x, y)
            current.append(cursor)
            last_cubic = last_quad = None
        elif upper == "H":
            (x,) = take(1)
            cursor = (cursor[0] + x, cursor[1]) if rel else (x, cursor[1])
            current.append(cursor)
            last_cubic = last_quad = None
        elif upper == "V":
            (y,) = take(1)
            cursor = (cursor[0], cursor[1] + y) if rel else (cursor[0], y)
            current.append(cursor)
            last_cubic = last_quad = None
        elif upper in ("C", "S"):
            if upper == "C":
                x1, y1, x2, y2, x, y = take(6)
                if rel:
                    x1, y1, x2, y2, x, y = (cursor[0] + x1, cursor[1] + y1,
                                             cursor[0] + x2, cursor[1] + y2,
                                             cursor[0] + x, cursor[1] + y)
                c1, c2 = (x1, y1), (x2, y2)
            else:
                x2, y2, x, y = take(4)
                if rel:
                    x2, y2, x, y = (cursor[0] + x2, cursor[1] + y2,
                                    cursor[0] + x, cursor[1] + y)
                c1 = (2 * cursor[0] - last_cubic[0], 2 * cursor[1] - last_cubic[1]) \
                    if last_cubic else cursor
                c2 = (x2, y2)
            current.extend(_cubic(cursor, c1, c2, (x, y)))
            last_cubic, last_quad, cursor = c2, None, (x, y)
        elif upper in ("Q", "T"):
            if upper == "Q":
                x1, y1, x, y = take(4)
                if rel:
                    x1, y1, x, y = (cursor[0] + x1, cursor[1] + y1,
                                    cursor[0] + x, cursor[1] + y)
                c1 = (x1, y1)
            else:
                x, y = take(2)
                if rel:
                    x, y = cursor[0] + x, cursor[1] + y
                c1 = (2 * cursor[0] - last_quad[0], 2 * cursor[1] - last_quad[1]) \
                    if last_quad else cursor
            current.extend(_quad(cursor, c1, (x, y)))
            last_quad, last_cubic, cursor = c1, None, (x, y)
        else:
            raise SvgError(f"unsupported path command {command!r}")

    flush()
    return contours


def _cubic(p0, p1, p2, p3) -> list[tuple[float, float]]:
    out: list[tuple[float, float]] = []
    steps = _steps_for(_cubic_flatness(p0, p1, p2, p3))
    for i in range(1, steps + 1):
        t = i / steps
        out.append(_cubic_at(p0, p1, p2, p3, t))
    return out


def _quad(p0, p1, p2) -> list[tuple[float, float]]:
    out: list[tuple[float, float]] = []
    steps = _steps_for(_quad_flatness(p0, p1, p2))
    for i in range(1, steps + 1):
        t = i / steps
        u = 1.0 - t
        out.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return out


def _steps_for(flatness: float) -> int:
    if flatness <= _TOLERANCE:
        return _MIN_STEPS
    return int(min(_MAX_STEPS, max(_MIN_STEPS, math.ceil(math.sqrt(flatness / _TOLERANCE) * 2))))


def _cubic_flatness(p0, p1, p2, p3) -> float:
    """Rough upper bound on the chord deviation of a cubic."""
    d1 = math.dist(p0, p1)
    d2 = math.dist(p1, p2)
    d3 = math.dist(p2, p3)
    return 0.75 * max(d1, d2, d3)


def _quad_flatness(p0, p1, p2) -> float:
    return 0.5 * max(math.dist(p0, p1), math.dist(p1, p2))


def _cubic_at(p0, p1, p2, p3, t: float) -> tuple[float, float]:
    u = 1.0 - t
    a, b, c, d = u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t
    return (a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0],
            a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1])


# --------------------------------------------------------------------------- document
def _strip_ns(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def read_svg(path: str | Path) -> dict:
    """Read a body part SVG.

    Returns {"contours": [...], "meta": {...}}.  `meta` carries the `data-*`
    attributes on the root element, which is where a part declares its spine:

        <svg data-name="tail_fork" data-joints="0,0 10,-1 22,-4" ...>
        <svg data-name="head" data-joints="0,0 6,-3" data-origin="0,0">

    Unknown `data-*` keys are passed through untouched.
    """
    root = ET.parse(str(path)).getroot()
    if _strip_ns(root.tag) != "svg":
        raise SvgError(f"{path}: root element is <{_strip_ns(root.tag)}>, expected <svg>")
    contours: list[np.ndarray] = []
    for node in root.iter():
        if _strip_ns(node.tag) != "path":
            continue
        d = node.get("d")
        if not d:
            continue
        contours.extend(parse_path(d))
    if not contours:
        raise SvgError(f"{path}: no <path d=...> found")
    meta = {k[5:]: v for k, v in root.attrib.items() if k.startswith("data-")}
    view_box = root.get("viewBox")
    if view_box:
        parts = [float(v) for v in re.split(r"[\s,]+", view_box.strip()) if v]
        if len(parts) == 4:
            meta.setdefault("viewbox", view_box.strip())
    return {"contours": contours, "meta": meta}


def parse_joints(meta: dict) -> np.ndarray:
    """`data-joints` -> (N, 2).  A single joint is allowed (a blob)."""
    raw = meta.get("joints")
    if not raw:
        raise SvgError("part SVG has no data-joints")
    flat: list[float] = []
    for token in re.split(r"[\s,]+", str(raw).strip()):
        if token:
            flat.append(float(token))
    if len(flat) < 4 or len(flat) % 2:
        raise SvgError(f"data-joints needs 2*N numbers, got {len(flat)}: {raw!r}")
    return np.asarray(flat, dtype=np.float64).reshape(-1, 2)


def parse_point(meta: dict, key: str, default: tuple[float, float]) -> tuple[float, float]:
    raw = meta.get(key)
    if not raw:
        return default
    flat = [float(v) for v in re.split(r"[\s,]+", str(raw).strip()) if v]
    if len(flat) != 2:
        raise SvgError(f"data-{key} needs 2 numbers, got {raw!r}")
    return (flat[0], flat[1])
