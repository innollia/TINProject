"""Rain World grammar for a static, layered background.

    python -m procbake.backdrop specs/backdrops/01_rain_industrial.json -o out/backdrops
    python -m procbake.backdrop specs/backdrops/*.json -o out/backdrops --sheet backdrops
    python -m procbake.backdrop specs/backdrops/03_ice_cavern.json -o out/backdrops --check

One spec in, a 1280x720 composite plus one PNG per depth layer plus a report JSON
out.  No Godot, no scene tree.  The same reason bake.py exists: a background can
be iterated on in a second and looked at.

THE GRAMMAR, which is the whole point of the module
---------------------------------------------------
A Rain World background is three readings stacked: a far colour plane, a middle
structure, a near silhouette.  The layer names are the ones the engine already
knows - `ProceduralBackdropDynamics.Layer` is SKY, FAR, MID, NEAR, FOREGROUND, and
`parallax` is what that class multiplies the camera offset by, so the vocabulary
here is the runtime's, not a second one.

    sky           a flat colour plane with a gradient.  No ink, no structure.
    far           big soft masses, low contrast, pushed toward the fog colour.
    mid           the architecture.  Mid value, inked, shaded.
    near          a few large dark shapes that frame the action.
    foreground    near black, bottom or top of frame, occasionally occluding.

And the rule the whole file is built around: THE CENTRE STAYS OPEN.  A dark
creature has to read against whatever is behind it, and the player has to be able
to act, so detail concentrates at the left and right thirds and along the top and
bottom edges.  A background that competes with the creature is a failed
background, and that is measured, not asserted - see `gate`.

SILHOUETTE FIRST
----------------
Every element is a closed loop resolved to a distance field, then the same cel
stack creatures use: an outline band, a fill, a crescent on the side away from
the light, a lit edge.  Elements come from three places:

  * the `shapes/` body part library, where the vocabulary fits - a tentacle is a
    root, a `tail_seg` is a pipe run, a `limb_hoof` is a rubble block
  * inline `shapes` in the spec, a list of closed point loops
  * the generators below - ribbon, disc, drip, arch, slab, tree - which is how a
    spec stays readable while still drawing twenty things

Antialiasing is everywhere by construction: nothing is ever filled with
`draw_polygon` or `draw_line`, because those have hard edges and a hard edge on a
900px pipe run is a stair-step.  Every visible surface goes through
`coverage(field)`.  The one exception is `kind: "glow"`, the light source itself,
which is a smooth falloff and has no edge to antialias.

DETERMINISM
-----------
`numpy.random.default_rng(seed * 10007 + element_index)` per element.  The same
spec always gives the same PNG, in any order, on any machine.  Python's `random`
is never used.

SCROLLING
---------
Each layer is written twice.  `<name>_layer_<layer>.png` is the 1280x720 design
window, which matches the composite pixel for pixel and is what you look at.
`<name>_tile_<layer>.png` is the same layer with `overhang` px of bleed on each
side, wrapped: any element that pokes past a design edge is repeated on the far
side, so the bleed strip is the picture continued rather than a smear.  The tile
is what a Kit scrolls at `parallax`; the overhang is sized from the parallax so
the layer cannot run out of picture.

ONE DEVIATION FROM canvas.py, AND WHY
-------------------------------------
`Canvas.paint_ink` is documented as "a stroke of the outline, laid down first so
the fill covers its inner half - the result is a line that sits OUTSIDE the
silhouette".  It does not do that.  `sdf` is negative inside, and the band it
builds is `|d + w/2| - w/2 < 0`, i.e. `-w <= d <= 0` - entirely INSIDE.
`paint_field` then covers it at coverage 1.0, so the only thing left on screen is
the fill's own antialiased edge darkening over a half-strength ink: about a 1px
line.  On a 40px creature that is enough.  On a 1280x720 backdrop where one pipe
crosses 900px there is no contour at all, and the picture falls apart.

So `_ink_field` here builds the band the docstring describes - `0 <= d <= w` - and
it is the documented intent with the sign the sdf module actually uses.  Fill,
shade and lit edge are the shared stack; only the ink sign is local.  If
canvas.py is ever fixed, this one function goes away.
"""

from __future__ import annotations

import argparse
import glob as globmod
import json
import math
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

from . import palette as pal_mod
from . import sheet as sheet_mod
from .canvas import Canvas
from .sdf import coverage, poly_sdf_points, shifted, smooth_min
from .shapes import ShapeLibrary

ROOT = Path(__file__).resolve().parent.parent

# The engine's vocabulary.  ProceduralBackdropDynamics.Layer, in draw order.
LAYERS = ("sky", "far", "mid", "near", "foreground")

# Default atmospheric perspective per layer: how much of the fog colour stands
# between the camera and this depth.  This, not the palette, is what makes depth.
# A far shape painted in the same ink as a near one reads as the same distance
# away, whatever its colour.
LAYER_FOG = {"sky": 0.00, "far": 0.62, "mid": 0.30, "near": 0.08, "foreground": 0.00}
# Default parallax.  The sky barely moves; the things you can walk behind move.
LAYER_PARALLAX = {"sky": 0.05, "far": 0.18, "mid": 0.42, "near": 0.72, "foreground": 1.00}
# Default silhouette role per layer.  The value ladder: the further forward a
# layer sits, the darker it is drawn.  `foreground` is `ink`, which the palette
# forces near black - "nearly black" is a requirement here, not a mood.
LAYER_ROLE = {"far": "ground", "mid": "body_dark", "near": "shade", "foreground": "ink"}
# Outline width per layer: thin far away, thick in front, because a contour has
# to survive being scaled up together with its layer.
LAYER_INK = {"far": 1.0, "mid": 1.8, "near": 2.8, "foreground": 3.6}
LAYER_TONE = {"far": 1.0, "mid": 0.92, "near": 0.72, "foreground": 0.55}
LAYER_SHADE = {"far": 7.0, "mid": 11.0, "near": 15.0, "foreground": 18.0}

MIN_ELEMENTS = 8
MAX_ELEMENTS = 20
MIN_LAYERS = 3
MAX_LAYERS = 5
MAX_OVERHANG_FRAC = 0.40     # per side, as a share of width.  Wider than this is
                             # a tiling asset, not a backdrop.
_FAR = np.float32(1.0e6)
# What the field carries where no shape is near enough to paint.  Only has to
# exceed a cel band's reach; 1e3 is comfortably past the deepest shade depth.
_OUTSIDE = np.float32(1.0e3)

# The open centre.  A creature is 40-90px tall in a 720px frame and stands in the
# middle band, so this is the rectangle that has to stay quiet.  The reference
# regions are the left and right thirds of the frame, as specified - but with the
# centre rectangle subtracted from them, because comparing a region against one
# that contains it lets the answer cancel itself out.
CENTRE = (0.25, 0.30, 0.75, 0.70)
THIRD_L = (0.00, 0.00, 1.0 / 3.0, 1.00)
THIRD_R = (2.0 / 3.0, 0.00, 1.00, 1.00)

LUMA = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)


# --------------------------------------------------------------------- colour
def _luma(colour) -> float:
    """Rec.709 luminance of one colour, 0..1."""
    return float(np.dot(np.asarray(colour[:3], dtype=np.float32), LUMA))


def _mean_luma(rgb: np.ndarray) -> float:
    """Mean luminance of an (h, w, 3) block - the value one layer sits at."""
    if rgb.size == 0:
        return 0.0
    return float((rgb.astype(np.float32) * LUMA[None, None, :]).sum(axis=2).mean())


def _value_scale(colour, k: float) -> tuple:
    """The same role at a different exposure.  Not a new colour and not a literal
    RGB: it is the honest way to put two layers of one material at two depths."""
    r, g, b, a = (float(c) for c in colour)
    return (min(max(r * k, 0.0), 1.0), min(max(g * k, 0.0), 1.0),
            min(max(b * k, 0.0), 1.0), a)


def _mix(a, b, t: float) -> tuple:
    t = min(max(t, 0.0), 1.0)
    return tuple(float(a[i]) + (float(b[i]) - float(a[i])) * t for i in range(4))


def _role(pal, name: str, fallback: str) -> tuple:
    return pal.get(name) if pal.has(name) else pal.get(fallback)


# ------------------------------------------------------------------- geometry
def _closed(loop) -> np.ndarray:
    return np.asarray(loop, dtype=np.float64).reshape(-1, 2)


def _polyline(points) -> np.ndarray:
    return np.asarray(points, dtype=np.float64).reshape(-1, 2)


def _superellipse(w: float, h: float, n: float = 4.0, steps: int = 64,
                  taper: float = 1.0, bulge: float = 0.0,
                  lean: float = 0.0) -> np.ndarray:
    """Rounded rectangle, ellipse or tapered slab, as one smooth closed loop.

    `n` is the superellipse exponent: 2 is an ellipse, 8 is a panel with soft
    corners, 3.2 is a tombstone.  Nothing on this path can produce a right
    angle, which is how architecture in a backdrop spec can be rectangular in
    intent and still survive the no-corners rule.

    `taper` narrows the top, `bulge` swells the middle, `lean` pushes the top
    sideways - the three moves that turn an ellipse into a monolith, a boulder,
    a leaning stele or a gourd.
    """
    t = np.linspace(0.0, 2.0 * math.pi, steps, endpoint=False)
    ct, st = np.cos(t), np.sin(t)
    x = np.sign(ct) * np.abs(ct) ** (2.0 / n) * (w * 0.5)
    y = np.sign(st) * np.abs(st) ** (2.0 / n) * (h * 0.5)
    v = y / max(h * 0.5, 1e-6) * 0.5 + 0.5            # 0 at the base, 1 at the top
    if taper != 1.0:
        x *= taper + (1.0 - taper) * v
    if bulge:
        x *= 1.0 + bulge * np.sin(math.pi * v)
    if lean:
        x += lean * v * v
    return np.stack([x, y], axis=1)


def _resample(points: np.ndarray, count: int) -> np.ndarray:
    """Even arc-length resample of a polyline, by linear interpolation."""
    seg = np.linalg.norm(np.diff(points, axis=0), axis=1)
    total = float(seg.sum())
    if total <= 1e-9 or len(points) < 2:
        return points
    at = np.concatenate([[0.0], np.cumsum(seg)])
    want = np.linspace(0.0, total, count)
    return np.stack([np.interp(want, at, points[:, 0]),
                     np.interp(want, at, points[:, 1])], axis=1)


def _unit(v) -> np.ndarray:
    a = np.asarray(v, dtype=np.float64)
    n = float(np.linalg.norm(a))
    return a / n if n > 1e-9 else np.array([1.0, 0.0])


def _normals(points: np.ndarray) -> np.ndarray:
    """Unit normal, left of travel, at every point of a polyline."""
    d = np.gradient(points, axis=0)
    n = np.stack([-d[:, 1], d[:, 0]], axis=1)
    return n / np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-9)


def _wiggle(points: np.ndarray, amount: float, rng) -> np.ndarray:
    """Low-frequency lateral displacement, so an authored run is not a ruler.

    Three octaves of sine with rng phases, far enough apart in frequency that one
    spine never visibly repeats itself.
    """
    if amount <= 0.0:
        return points
    out = points.astype(np.float64).copy()
    u = np.linspace(0.0, 1.0, len(points))
    for k, freq in enumerate((1.3, 2.9, 6.1)):
        ph = float(rng.uniform(0.0, 2.0 * math.pi)) * (k + 1)
        out[:, 0] += np.sin(u * freq * 2.0 * math.pi + ph) * amount * (0.60 - 0.18 * k)
        out[:, 1] += np.cos(u * freq * 2.0 * math.pi + ph * 1.7) * amount * (0.50 - 0.15 * k)
    return out


def _cap(at, normal, half: float, steps: int = 7, squash: float = 1.0, forward=None) -> np.ndarray:
    """Round cap from +normal round to -normal, through the direction of travel.

    `squash` shortens the dome along the axis of travel.  A full semicircle is
    the right end for a bone and the wrong end for a pipe: at squash 1 the cap
    curves back far enough that the lit edge runs along its inside, and every
    organ pipe, stalactite and hanging cable grew a visible cup.
    """
    if half <= 1e-6:
        return np.zeros((0, 2), dtype=np.float64)
    fwd = np.asarray(forward, dtype=np.float64) if forward is not None \
        else np.array([-normal[1], normal[0]], dtype=np.float64)
    fwd = _unit(fwd)
    base = math.atan2(fwd[1], fwd[0]) + math.pi * 0.5
    t = np.linspace(base, base - math.pi, steps, endpoint=False)
    return np.stack([at[0] + np.cos(t) * half,
                     at[1] + np.sin(t) * half * squash], axis=1)


def _ribbon_loop(spine, widths, round_caps: bool = True, steps: int = 0,
                 cap_squash: float = 1.0) -> np.ndarray:
    """Closed outline of a band following `spine` with per-point half-widths.

    One loop, so it resolves to a single field: offset left going forward, round
    cap, offset right coming back, round cap.  Round caps because a flat cap is a
    hard edge and the spec bans hard edges; `cap_squash` decides how domed they
    are.
    """
    pts = _polyline(spine)
    if steps:
        pts = _resample(pts, steps)
    if isinstance(widths, (int, float)):
        w = np.full(len(pts), float(widths) * 0.5)
    else:
        seq = np.asarray(widths, dtype=np.float64)
        w = np.interp(np.linspace(0.0, 1.0, len(pts)),
                      np.linspace(0.0, 1.0, len(seq)), seq) * 0.5
    n = _normals(pts)
    # The cap has to bulge ALONG TRAVEL.  Deriving its direction from the normal
    # instead - fwd = (-n.y, n.x) - points backwards for every ribbon, so the
    # cap curves back over the band's own body; where the width is still growing
    # at the end the cap is wider than the body there, it leaves it, and the
    # even-odd fill cancels the overlap into a visible hole punched through the
    # shape.  Take the direction from the polyline itself.
    head = _unit(pts[1] - pts[0]) if len(pts) > 1 else np.array([1.0, 0.0])
    tail = _unit(pts[-1] - pts[-2]) if len(pts) > 1 else np.array([1.0, 0.0])
    parts = [pts + n * w[:, None]]
    if round_caps:
        parts.append(_cap(pts[-1], n[-1], w[-1], forward=tail, squash=cap_squash))
    parts.append((pts - n * w[:, None])[::-1])
    if round_caps:
        parts.append(_cap(pts[0], n[0], w[0], forward=-head, squash=cap_squash))
    return np.concatenate([np.asarray(p, dtype=np.float64) for p in parts], axis=0)


def _smoothstep(x: np.ndarray) -> np.ndarray:
    t = np.clip(x, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def _toothed_disc(radius: float, teeth: int, depth: float, phase: float = 0.0,
                  top: float = 0.44, flank: float = 0.12, steps: int = 0) -> np.ndarray:
    """A gear: flat-topped teeth with near-vertical flanks, shoulders rounded.

    The obvious version - radius modulated by `cos(teeth * theta)` - gives a
    scalloped flower, not a gear: the teeth have no flat and no flank, so at
    any readable size the eye reads lobes.  A gear is a trapezoid, so that is
    what this builds, and only the two shoulders are eased.
    """
    n = max(int(teeth), 3)
    steps = steps or max(n * 11, 96)
    t = np.linspace(0.0, 2.0 * math.pi, steps, endpoint=False)
    u = ((t - phase) * n / (2.0 * math.pi)) % 1.0
    f = max(flank * 0.5, 1e-3)
    a, b = top * 0.5, 1.0 - top * 0.5
    w = np.minimum(_smoothstep((u - (a - f)) / f),
                   1.0 - _smoothstep((u - (b - f)) / f))
    r = radius + depth * w
    return np.stack([np.cos(t) * r, np.sin(t) * r], axis=1)


def _arch_spine(span: float, rise: float, leg: float, steps: int = 40) -> np.ndarray:
    """Centreline of a freestanding arch: two legs and a half-ellipse over them."""
    half = max(span * 0.5, 1.0)
    leg = min(leg, rise * 0.82)
    pts = [np.array([-half, 0.0]), np.array([-half, leg * 0.5]), np.array([-half, leg])]
    cap = max(rise - leg, 1.0)
    a = np.linspace(math.pi, 0.0, steps)
    pts.extend(np.stack([-half * np.cos(a), leg + cap * np.sin(a)], axis=1))
    pts.extend([np.array([half, leg * 0.5]), np.array([half, 0.0])])
    return np.asarray(pts, dtype=np.float64)


# ------------------------------------------------------------ element records
@dataclass
class Element:
    """One drawable thing.  Geometry is built in LOCAL space; `raw` carries the
    placement, and `transformed()` moves it into design space (0..W, 0..H)."""

    id: str
    kind: str
    raw: dict
    parts: list = field(default_factory=list)   # [[contour, ...], ...] -> smooth union
    bbox: tuple = (0.0, 0.0, 0.0, 0.0)

    def transformed(self) -> list:
        at = np.asarray(self.raw.get("at", (0.0, 0.0)), dtype=np.float64)
        rot = math.radians(float(self.raw.get("rotation", 0.0)))
        sc = self.raw.get("scale", 1.0)
        if isinstance(sc, (list, tuple)):
            sx, sy = float(sc[0]), float(sc[1])
        else:
            sx = sy = float(sc)
        flip = str(self.raw.get("flip", "")).lower()
        c, s = math.cos(rot), math.sin(rot)
        basis = np.array([[c, s], [-s, c]], dtype=np.float64)
        out = []
        for group in self.parts:
            moved = []
            for contour in group:
                p = np.asarray(contour, dtype=np.float64).copy()
                if "y" in flip:
                    p[:, 1] *= -1.0
                if "x" in flip:
                    p[:, 0] *= -1.0
                p[:, 0] *= sx
                p[:, 1] *= sy
                p = p @ basis
                p += at
                moved.append(p)
            out.append(moved)
        return out


def _element_bounds(groups) -> tuple:
    pts = np.concatenate([np.concatenate(g, axis=0) for g in groups], axis=0)
    return (float(pts[:, 0].min()), float(pts[:, 1].min()),
            float(pts[:, 0].max()), float(pts[:, 1].max()))


# ------------------------------------------------------------------ generators
def _g_poly(spec, rng, lib) -> list:
    loops = spec.get("shapes")
    if loops is None and spec.get("loop"):
        loops = [spec["loop"]]
    if not loops:
        raise ValueError("poly element needs 'shapes': a list of closed point loops")
    if loops and not isinstance(loops[0][0], (list, tuple)):
        loops = [loops]                          # a single bare loop
    return [[_closed(loop) for loop in loops]]


def _g_shape(spec, rng, lib) -> list:
    shape = lib.get(str(spec.get("part") or spec.get("shape")))
    return [[c.copy() for c in shape.contours]]


def _g_ribbon(spec, rng, lib) -> list:
    spine = _polyline(spec["spine"])
    if spec.get("bow"):
        t = np.linspace(0.0, 1.0, len(spine))
        bow = float(spec["bow"])
        spine = spine + np.stack([t * t * bow, -t * (1.0 - t) * bow], axis=1)
    if spec.get("wiggle"):
        spine = _wiggle(spine, float(spec["wiggle"]), rng)
    widths = spec.get("widths", spec.get("width", 6.0))
    return [[_ribbon_loop(spine, widths, bool(spec.get("round_caps", True)),
                          int(spec.get("steps", 0)),
                          float(spec.get("cap_squash", 1.0)))]]


def _g_disc(spec, rng, lib) -> list:
    r = float(spec.get("r", 30.0))
    teeth = int(spec.get("teeth", 0))
    if teeth > 0:
        loop = _toothed_disc(r, teeth, float(spec.get("tooth_depth", r * 0.20)),
                             float(spec.get("tooth_phase", 0.0)),
                             top=float(spec.get("tooth_top", 0.44)),
                             flank=float(spec.get("tooth_flank", 0.12)))
    else:
        t = np.linspace(0.0, 2.0 * math.pi, int(spec.get("steps", 72)), endpoint=False)
        loop = np.stack([np.cos(t) * r, np.sin(t) * r], axis=1)
    group = [loop]
    bore = float(spec.get("bore", 0.0))
    if bore > 0.0:
        # A second loop inside the first: even-odd makes it a hole, so a gear
        # reads as a ring with a bore rather than a disc with a dot on it.
        t = np.linspace(0.0, 2.0 * math.pi, 48, endpoint=False)
        wobble = 1.0 + 0.10 * np.cos(5.0 * t + float(rng.uniform(0.0, 6.28)))
        group.append(np.stack([np.cos(t) * bore * wobble, np.sin(t) * bore * wobble], axis=1))
    groups = [group]
    spokes = int(spec.get("spokes", 0))
    hub = float(spec.get("hub", 0.0))
    if spokes >= 2 and hub > 0.0:
        # A ring plus spokes is a hand wheel or a rose window rather than a
        # flower.  Spokes are separate parts, so they smooth-union with the rim
        # instead of filling the bore in.  Their width is its own field because
        # tying it to the bore - the first thing this did - made a 14px rim with
        # 85px spokes, which fills solid and leaves a ragged edge.
        ph = float(spec.get("spoke_phase", rng.uniform(0.0, 6.28)))
        w = float(spec.get("spoke_width", max(bore * 0.17, 1.2)))
        for k in range(spokes):
            a = ph + k * 2.0 * math.pi / spokes
            groups.append([_ribbon_loop(
                np.stack([[math.cos(a) * hub * 0.4, math.sin(a) * hub * 0.4],
                          [math.cos(a) * r * 1.02, math.sin(a) * r * 1.02]], axis=0),
                [w, w], True, steps=8)])
        groups.append([_ribbon_loop(np.array([[0.0, 0.0], [0.5, 0.0]]),
                                    [hub, hub * 0.94], True, steps=6)])
    return groups


def _g_drip(spec, rng, lib) -> list:
    """A hanging drop: a tapering run with a bead at the end, unioned."""
    length = float(spec.get("length", 90.0))
    w0 = float(spec.get("width", 5.0))
    tip = float(spec.get("tip", 0.22))
    spine = np.stack([np.zeros(4), np.linspace(0.0, length, 4)], axis=1)
    spine[:, 0] += np.array([0.0, 0.5, -0.4, 0.0]) * (length * 0.02)
    group = [_ribbon_loop(spine, [w0, w0 * 0.62, w0 * (0.62 + tip) * 0.5, w0 * tip],
                          True, steps=24)]
    bulb = float(spec.get("bulb", w0 * 1.15))
    if bulb > 0.0:
        t = np.linspace(0.0, 2.0 * math.pi, 28, endpoint=False)
        y = length * float(spec.get("bulb_at", 0.86))
        group.append(np.stack([np.cos(t) * bulb * 0.86 + spine[-1, 0],
                               np.sin(t) * bulb + y], axis=1))
    return [group]


def _g_arch(spec, rng, lib) -> list:
    spine = _arch_spine(float(spec.get("span", 300.0)), float(spec.get("rise", 380.0)),
                        float(spec.get("leg", 180.0)))
    w = spec.get("widths", spec.get("width", 26.0))
    widths = [w, w, w * 0.86, w * 0.86] if isinstance(w, (int, float)) else list(w)
    return [[_ribbon_loop(spine, widths, True, steps=110)]]


def _g_slab(spec, rng, lib) -> list:
    n = float(spec.get("n", 4.0))
    if n <= 2.05 and not (spec.get("taper") or spec.get("bulge") or spec.get("lean")):
        n = 2.0
    return [[_superellipse(float(spec.get("w", 120.0)), float(spec.get("h", 200.0)),
                           n=n, steps=int(spec.get("steps", 64)),
                           taper=float(spec.get("taper", 1.0)),
                           bulge=float(spec.get("bulge", 0.0)),
                           lean=float(spec.get("lean", 0.0)))]]


def _g_glow(spec, rng, lib) -> list:
    return []                        # a glow is a falloff, not a loop


def _g_tree(spec, rng, lib) -> list:
    """Recursive fork, built as ribbons and smooth-min'd into one mass.

    A tree is not a stack of ellipses: it is a taper that splits, and the split
    is what makes the silhouette read at a distance.  So this recurses.
    """
    depth = int(spec.get("depth", 3))
    groups: list = []

    def branch(at, ang, length, w0, w1, level):
        a = math.radians(ang)
        tip = np.array([at[0] + math.cos(a) * length, at[1] + math.sin(a) * length])
        mid = (at + tip) * 0.5 + rng.uniform(-1.0, 1.0, 2) * length * 0.05
        spine = _wiggle(np.stack([at, mid, tip]), length * 0.025, rng) if level else \
            np.stack([at, mid, tip])
        groups.append([_ribbon_loop(spine, [w0, (w0 + w1) * 0.5, max(w1, 0.8)],
                                    True, steps=18)])
        if level <= 1 or w1 < 2.4:
            return
        kids = 2 if level < depth else int(spec.get("fan", rng.integers(2, 4)))
        spread = float(spec.get("spread", 34.0))
        for k in range(kids):
            off = (k - (kids - 1) * 0.5) * spread + float(rng.uniform(-9.0, 9.0))
            branch(tip, ang + off, length * float(rng.uniform(0.58, 0.76)), w1,
                   w1 * float(spec.get("taper", 0.62)), level - 1)

    w = float(spec.get("width", 26.0))
    branch(np.array([0.0, 0.0]), float(spec.get("angle", -90.0)),
           float(spec.get("length", 220.0)), w, w * 0.66, depth)
    # One group per branch, not one group holding all of them: even-odd would
    # cancel overlapping branches instead of fusing them, and the tree would come
    # out as a ring of holes.
    return groups


GENERATORS = {
    "poly": _g_poly, "shape": _g_shape, "ribbon": _g_ribbon, "disc": _g_disc,
    "drip": _g_drip, "arch": _g_arch, "slab": _g_slab, "glow": _g_glow,
    "tree": _g_tree,
}


# ------------------------------------------------------------------- clusters
def _sub_stalactite(rng) -> dict:
    return {"kind": "ribbon", "spine": [[0, 0], [0, 60], [0, 130], [0, 190]],
            "widths": [46, 34, 16, 5], "resample": 26,
            "rotation": float(rng.uniform(-7, 7))}


def _sub_icicle(rng) -> dict:
    return {"kind": "ribbon", "spine": [[0, 0], [0, 70], [0, 160], [0, 250]],
            "widths": [24, 14, 5, 1.0], "resample": 24,
            "rotation": float(rng.uniform(-9, 9))}


def _sub_tombstone(rng) -> dict:
    """A stele on a plinth.  n has to be high: at n=2.6 the rounded-rectangle
    exponent has not flattened the sides yet and a tombstone renders as an egg,
    which is the single most legible way to fail this element."""
    w = float(rng.uniform(32, 58))
    h = float(rng.uniform(160, 320))
    return {"kind": "cluster2", "parts": [
        {"kind": "slab", "w": w * 1.5, "h": h * 0.10, "n": 5.0, "at": [0.0, h * 0.45]},
        {"kind": "slab", "w": w, "h": h, "n": float(rng.uniform(3.6, 4.8)),
         "taper": float(rng.uniform(0.78, 0.98)),
         "lean": float(rng.uniform(-7, 7))},
    ], "rotation": float(rng.uniform(-7, 7))}


def _sub_shroom(rng) -> dict:
    """A mushroom: domed cap, a collar under it, and a stalk - unioned, so it
    is one silhouette.  A flat disc on a stick reads as a table, not a cap, so
    the cap is a tapered dome and the collar is what makes the underside read."""
    h = float(rng.uniform(58, 132))
    cap_w = float(rng.uniform(40, 96))
    return {"kind": "cluster2", "parts": [
        {"kind": "ribbon", "spine": [[0, 0], [0, h * 0.45], [0, h * 0.9]],
         "widths": [15, 11, 9], "resample": 16},
        # A cap thinner than about half its width reads as a plate on a stick.
        {"kind": "slab", "w": cap_w, "h": cap_w * 0.66, "n": 2.1, "taper": 0.40,
         "bulge": 0.20, "at": [0.0, -h * 0.16]},
        {"kind": "slab", "w": cap_w * 0.88, "h": cap_w * 0.16, "n": 2.6,
         "at": [0.0, -h * 0.16 + cap_w * 0.30]},
    ]}


def _sub_boulder(rng) -> dict:
    w = float(rng.uniform(70, 200))
    return {"kind": "slab", "w": w, "h": w * float(rng.uniform(0.42, 0.78)),
            "n": float(rng.uniform(2.0, 2.6)), "rotation": float(rng.uniform(-16, 16))}


def _sub_stump(rng) -> dict:
    h = float(rng.uniform(70, 200))
    w = float(rng.uniform(38, 86))
    return {"kind": "ribbon", "spine": [[0, 0], [0, h * 0.4], [0, h * 0.78], [0, h]],
            "widths": [w * 1.5, w * 1.1, w * 0.92, w * 0.5], "resample": 24,
            "rotation": float(rng.uniform(-6, 6))}


def _sub_frond(rng) -> dict:
    return {"kind": "shape", "part": "limb_tentacle",
            "rotation": float(rng.uniform(-118, -62)),
            "scale": float(rng.uniform(1.1, 2.4))}


def _sub_post(rng, up: bool = False) -> dict:
    h = float(rng.uniform(160, 400))
    w = float(rng.uniform(16, 48))
    # A post that keeps its width all the way up reads as an open cup, because
    # the round cap is then as wide as the shaft.  A pipe tapers, and its cap is
    # a shallow dome rather than a hemisphere.
    return {"kind": "ribbon", "spine": [[0, 0], [0, -h if up else h]],
            "widths": [w, w * 0.66], "resample": 14, "cap_squash": 0.42,
            "rotation": float(rng.uniform(-5, 5))}


def _sub_debris(rng) -> dict:
    w = float(rng.uniform(26, 96))
    return {"kind": "slab", "w": w, "h": w * float(rng.uniform(0.3, 0.7)),
            "n": float(rng.uniform(2.6, 4.2)), "rotation": float(rng.uniform(0, 360))}


def _sub_root(rng) -> dict:
    return {"kind": "ribbon", "spine": [[0, 0], [10, 46], [4, 96], [16, 150]],
            "widths": [17, 13, 8, 2.5], "resample": 26,
            "wiggle": 7.0, "rotation": float(rng.uniform(-16, 16))}


def _sub_pipe(rng) -> dict:
    length = float(rng.uniform(180, 460))
    w = float(rng.uniform(16, 42))
    return {"kind": "ribbon", "spine": [[0, 0], [length, 0]], "widths": [w, w],
            "resample": 14, "cap_squash": 0.5, "rotation": float(rng.uniform(-30, 30))}


def _sub_gear(rng) -> dict:
    r = float(rng.uniform(24, 74))
    return {"kind": "disc", "r": r, "teeth": int(rng.integers(9, 17)),
            "tooth_depth": r * 0.24, "bore": r * 0.26,
            "tooth_phase": float(rng.uniform(0, 6.28)),
            "rotation": float(rng.uniform(0, 360))}


def _sub_wheel(rng) -> dict:
    r = float(rng.uniform(30, 86))
    spokes = int(rng.integers(4, 8))
    return {"kind": "disc", "r": r, "bore": r * 0.58, "spokes": spokes, "hub": r * 0.26,
            "spoke_phase": float(rng.uniform(0, 6.28)),
            "rotation": float(rng.uniform(0, 360))}


def _sub_drip(rng) -> dict:
    return {"kind": "drip", "length": float(rng.uniform(60, 210)),
            "width": float(rng.uniform(3.5, 9.0)),
            "bulb": float(rng.uniform(5.0, 13.0)),
            "bulb_at": float(rng.uniform(0.78, 0.94))}


def _sub_hypha(rng) -> dict:
    """A short crossing filament, always sagging - a catenary reads as tension.

    Length matters more than it looks.  A filament scaled up to cross a 1280px
    frame stops being a thread in a weave and becomes a cable across the picture,
    and a room full of those has no open middle left for anything to stand in.
    """
    length = float(rng.uniform(180, 400))
    sag = length * float(rng.uniform(0.14, 0.34))
    t = np.linspace(0.0, 1.0, 18)
    return {"kind": "ribbon",
            "spine": np.stack([t * length, sag * np.sin(math.pi * t)], axis=1).tolist(),
            "widths": float(rng.uniform(1.6, 4.0)), "resample": 22,
            "rotation": float(rng.uniform(-10, 10))}


SUBS = {
    "stalactite": _sub_stalactite, "icicle": _sub_icicle, "tombstone": _sub_tombstone,
    "shroom": _sub_shroom, "boulder": _sub_boulder, "stump": _sub_stump,
    "frond": _sub_frond, "post": _sub_post, "debris": _sub_debris,
    "root": _sub_root, "pipe": _sub_pipe, "gear": _sub_gear, "hypha": _sub_hypha,
    "drip": _sub_drip, "wheel": _sub_wheel,
}


def _rng_for(seed: int, index: int) -> np.random.Generator:
    """One generator per element, keyed off the spec seed and the element's own
    index.  Deterministic, and independent of evaluation order, so inserting an
    element never reshuffles the ones after it."""
    return np.random.default_rng(int(seed) * 10007 + int(index))


def _check_parts(el: Element) -> None:
    """A part is a list of contours for even-odd; a group of parts is a list of
    groups.  Nesting one level wrong is invisible until the SDF silently gets a
    3-D array, so it is caught here with a message that names the element."""
    for group in el.parts:
        if not isinstance(group, (list, tuple)) or not group:
            raise ValueError(f"element {el.id!r} ({el.kind}) has a part that is not a "
                             f"list of contours")
        for contour in group:
            arr = np.asarray(contour)
            if arr.ndim != 2 or arr.shape[0] < 3 or arr.shape[1] != 2:
                raise ValueError(f"element {el.id!r} ({el.kind}) has a contour of shape "
                                 f"{arr.shape}; a closed loop is (N, 2) with N >= 3")


def _expand(raw: dict, rng, lib, prefix: str = "") -> list:
    """One spec entry -> the list of Elements it really draws.

    A `cluster` is a convenience, not a hidden element: it produces N children,
    each with its own id, and the report counts both.  Every child varies -
    scale, tilt, flip, wiggle - because N copies of one stamp is exactly the
    failure the contact sheet exists to catch.
    """
    kind = str(raw.get("kind", "poly"))
    if kind == "cluster":
        sub = str(raw.get("sub", "debris"))
        if sub not in SUBS:
            raise ValueError(f"unknown cluster sub {sub!r}; have {sorted(SUBS)}")
        count = int(raw.get("count", 6))
        spread = np.asarray(raw.get("spread", (200, 60)), dtype=np.float64)
        at = np.asarray(raw.get("at", (0.0, 0.0)), dtype=np.float64)
        # `band` pulls the children into a strip instead of a box, which is what
        # makes a row of stelae or a fringe of stalactites read as placed objects
        # rather than as a rectangle of objects
        band = str(raw.get("band", "y"))
        smin = np.asarray(raw.get("scale", (0.7, 1.35)), dtype=np.float64)
        rmin = float(raw.get("rotation", 0.0))
        extra_wiggle = float(raw.get("wiggle", 0.0))
        out = []
        for i in range(count):
            u = (i + 0.5) / max(count, 1)
            if band == "x":
                off = np.array([(u * 2.0 - 1.0) * spread[0], 0.0])
            elif band == "y":
                off = np.array([0.0, (u * 2.0 - 1.0) * spread[1]])
            else:
                off = np.array([rng.uniform(-spread[0], spread[0]),
                                rng.uniform(-spread[1], spread[1])])
            child = dict(SUBS[sub](rng, up=True) if bool(raw.get("up")) else SUBS[sub](rng))
            child["at"] = [float(at[0] + off[0]), float(at[1] + off[1])]
            child["scale"] = float(child.get("scale", 1.0)) * float(rng.uniform(smin[0], smin[1]))
            child["rotation"] = float(child.get("rotation", 0.0)) + float(rng.uniform(-rmin, rmin))
            if bool(raw.get("flip", True)) and rng.random() < 0.5:
                child["flip"] = "x"
            if extra_wiggle and "spine" in child:
                child["wiggle"] = float(child.get("wiggle", 0.0) or 0.0) + float(rng.uniform(0, extra_wiggle))
            out.extend(_expand(child, rng, lib, prefix=f"{prefix}{sub}{i}_"))
        return out
    if kind == "cluster2":
        # an explicitly authored multi-part object (a mushroom, a valve stack)
        groups: list = []
        for part_raw in raw["parts"]:
            groups.extend(_build_groups(dict(part_raw), rng, lib))
        el = Element(id=prefix + str(raw.get("id", "group")), kind="composite",
                     raw=raw, parts=groups)
        _check_parts(el)
        el.bbox = _element_bounds(el.transformed())
        return [el]
    groups = _build_groups(raw, rng, lib)
    el = Element(id=prefix + str(raw.get("id", kind)), kind=kind, raw=raw, parts=groups)
    _check_parts(el)
    el.bbox = _element_bounds(el.transformed()) if groups else (0.0, 0.0, 0.0, 0.0)
    return [el]


def _build_groups(raw: dict, rng, lib) -> list:
    gen = GENERATORS.get(str(raw.get("kind", "poly")))
    if gen is None:
        raise ValueError(f"unknown element kind {raw.get('kind')!r}; "
                         f"have {sorted(GENERATORS)} and cluster sub {sorted(SUBS)}")
    return gen(raw, rng, lib)


# ------------------------------------------------------------------- backdrop
@dataclass
class LayerSpec:
    name: str
    parallax: float
    fog: float
    role: str
    ink: float
    tone: float
    shade_depth: float
    backlit: bool
    plane: dict | None
    overhang: int
    entries: list
    elements: list = field(default_factory=list)


class Backdrop:
    def __init__(self, spec: dict, library: ShapeLibrary, index: int = 0):
        self.spec = spec
        self.library = library
        self.index = index
        self.name = str(spec.get("name") or "backdrop")
        size = spec.get("size", [1280, 720])
        self.width, self.height = int(size[0]), int(size[1])
        self.seed = int(spec.get("seed", 0))
        # `variant` is 0, not the CLI position in the batch.  Every spec in
        # specs/backdrops carries its own palette block, but a spec without one
        # would otherwise derive a different palette depending on how many files
        # happened to sort before it - which is exactly the kind of order
        # dependence a deterministic bake is supposed to not have.
        self.palette = pal_mod.from_spec(spec.get("palette") or {}, self.seed, 0)

        light = spec.get("light") or {}
        rad = math.radians(float(light.get("angle", -135.0)))
        self.light = np.array([math.cos(rad), math.sin(rad)], dtype=np.float64)
        self.backlit = bool(light.get("backlit", False))
        self.fog_colour = _role(self.palette,
                                str((spec.get("atmosphere") or {}).get("role", "fog")), "fog")
        self._warn: list = []
        # Per-pixel silhouette coverage, the max over every element in every
        # layer.  This is what the antialiasing gate is measured on - see
        # `_unantialiased_edges` for why a value-jump test cannot answer it.
        self._cov: np.ndarray | None = None
        self.layers = self._build_layers(spec)

    # ------------------------------------------------------------------ build
    def _build_layers(self, spec: dict) -> list:
        raw_layers = spec.get("layers") or []
        if not raw_layers:
            raise ValueError("a backdrop spec needs a 'layers' list")
        if not (MIN_LAYERS <= len(raw_layers) <= MAX_LAYERS):
            self._warn.append(f"{len(raw_layers)} layers, spec says {MIN_LAYERS}-{MAX_LAYERS}")
        names = [str(r.get("name", LAYERS[min(i, len(LAYERS) - 1)]))
                 for i, r in enumerate(raw_layers)]
        unknown = [n for n in names if n not in LAYERS]
        if unknown:
            raise ValueError(f"layer name(s) {unknown} are not in ProceduralBackdropDynamics."
                             f"Layer; use {list(LAYERS)}")
        if names != sorted(names, key=LAYERS.index):
            raise ValueError(f"layers must be listed back to front, got {names}")
        out = []
        for li, raw in enumerate(raw_layers):
            name = names[li]
            parallax = float(raw.get("parallax", LAYER_PARALLAX.get(name, 0.4)))
            overhang = raw.get("overhang")
            if overhang is None:
                # The layer must be able to slide by its own parallax share of a
                # camera move, or it runs out of picture at the edge.
                overhang = int(round(self.width * abs(parallax) * 0.5))
            overhang = int(min(max(overhang, 0), int(self.width * MAX_OVERHANG_FRAC)))
            layer = LayerSpec(
                name=name,
                parallax=parallax,
                fog=float(raw.get("fog", LAYER_FOG.get(name, 0.25))),
                role=str(raw.get("role", LAYER_ROLE.get(name, "body_dark"))),
                ink=float(raw.get("ink", LAYER_INK.get(name, 2.0))),
                tone=float(raw.get("tone", LAYER_TONE.get(name, 1.0))),
                shade_depth=float(raw.get("shade_depth", LAYER_SHADE.get(name, 10.0))),
                backlit=bool(raw.get("backlit", self.backlit)),
                plane=raw.get("plane"),
                overhang=overhang,
                entries=list(raw.get("elements") or []),
            )
            for ei, entry in enumerate(layer.entries):
                layer.elements.extend(
                    _expand(entry, _rng_for(self.seed * 31 + li, ei), self.library,
                            prefix=f"{name}{ei}_"))
            out.append(layer)
        return out

    # ----------------------------------------------------------------- render
    def new_layer_canvas(self, layer: LayerSpec) -> Canvas:
        canvas = Canvas(self.width + layer.overhang * 2, self.height)
        geo = Canvas(self.width + layer.overhang * 2, self.height)
        if layer.plane:
            self._paint_plane(canvas, layer)
            geo.px[:, :, :] = canvas.px
        if self._cov is None or self._cov.shape != (self.height, self.width):
            self._cov = np.zeros((self.height, self.width), dtype=np.float32)
        # The plane is the BACKGROUND here, not a covered pixel.  Marking it
        # covered would make every pixel solid and hide every edge in the frame.
        return canvas, geo

    def render_layer(self, canvas: Canvas, layer: LayerSpec, geo: Canvas) -> None:
        for el in layer.elements:
            if el.kind == "glow":
                self._paint_glow(canvas, el, layer)
                continue
            groups = el.transformed()
            bbox = el.bbox
            copies = [(0.0, 0.0)]
            # A layer is a tiling asset: anything poking past a design edge is
            # repeated on the far side, so the bleed strip is the picture
            # continued rather than a smear.
            if bbox[0] < 0.0:
                copies.append((float(self.width), 0.0))
            if bbox[2] > float(self.width):
                copies.append((-float(self.width), 0.0))
            for dx, _ in copies:
                self._paint_element(canvas, el, groups, layer.overhang + dx, layer, geo)

    def _depth_for(self, el: Element, layer: LayerSpec) -> float:
        """Shade depth for one element, in px.

        A layer's default depth is a good number for a mass, and a terrible
        number for a pipe.  An 18px crescent on a 40px-wide pipe covers half its
        width and the round cap turns into the inside of a cup - the "bowls on
        sticks" that organ pipes and stalactites both became.  Scaling the
        crescent to the element's own short side keeps the shading in the same
        proportion on a 900px floor and on a 20px drip, and a spec can still
        override it per element.
        """
        if "shade_depth" in el.raw:
            return float(el.raw["shade_depth"])
        if not bool(el.raw.get("shade", True)):
            return 0.0
        short = min(el.bbox[2] - el.bbox[0], el.bbox[3] - el.bbox[1])
        return float(min(layer.shade_depth, max(2.0, short * 0.26)))

    def _paint_element(self, canvas: Canvas, el: Element, groups, ox: float,
                       layer: LayerSpec, geo: Canvas) -> None:
        raw = el.raw
        ink_w = float(raw.get("ink", layer.ink))
        depth = self._depth_for(el, layer)
        moved = [[c + np.array([ox, 0.0], dtype=np.float64) for c in g] for g in groups]
        pts = np.concatenate([np.concatenate(g, axis=0) for g in moved], axis=0)
        # Everything the cel stack can paint lives within `margin` of the
        # silhouette: the fill is inside, the ink band is `ink_w` outside it, and
        # a crescent is at most `shade_depth` deep.  Beyond that every coverage
        # term is identically zero, so those pixels do not need a distance
        # evaluation - which for a 1300px pipe run is most of the frame.
        margin = ink_w + depth + 4.0
        x0 = max(0, int(math.floor(pts[:, 0].min() - margin)))
        y0 = max(0, int(math.floor(pts[:, 1].min() - margin)))
        x1 = min(canvas.width, int(math.ceil(pts[:, 0].max() + margin)) + 1)
        y1 = min(canvas.height, int(math.ceil(pts[:, 1].max() + margin)) + 1)
        if x1 <= x0 or y1 <= y0:
            return
        ww, hh = x1 - x0, y1 - y0
        gx = x0 + np.arange(ww, dtype=np.float64) + 0.5
        gy = y0 + np.arange(hh, dtype=np.float64) + 0.5
        sample = np.stack(np.meshgrid(gx, gy), axis=-1)          # (h, w, 2)
        field = self._fuse(moved, sample, ww, hh, float(raw.get("fuse", 2.4)), margin,
                           x0, y0)
        self._paint_cel(canvas, el, layer, field, (x0, y0), geo)

    def _fuse(self, groups, sample, w: int, h: int, blend: float,
              margin: float, ox: int = 0, oy: int = 0) -> np.ndarray:
        """Even-odd inside each part, polynomial smooth minimum between parts.

        The same construction as `Creature._fuse`: a mushroom is a stalk and a
        cap that have to read as one silhouette, not as two objects sitting next
        to each other.  Each part is evaluated only inside its own bounds plus
        `margin`; everywhere else the field carries a large positive constant,
        which is indistinguishable from a real distance once it is further than
        `margin` from the shape.  `ox`/`oy` are the window's own origin, because
        the contours are in canvas coordinates and `sample` is not.

        `sample` is the (h, w, 2) pixel-centre grid.  A sub-window of that is
        only addressable as a slice of the 3D array - a flat index range picks up
        the tail of the first row and the head of the last, which is a reshape
        error and not a slow path.
        """
        out = np.full((h, w), _OUTSIDE, dtype=np.float32)
        for group in groups:
            pts = np.concatenate(group, axis=0)
            x0 = max(0, int(math.floor(pts[:, 0].min() - margin)) - ox)
            y0 = max(0, int(math.floor(pts[:, 1].min() - margin)) - oy)
            x1 = min(w, int(math.ceil(pts[:, 0].max() + margin)) - ox + 1)
            y1 = min(h, int(math.ceil(pts[:, 1].max() + margin)) - oy + 1)
            if x1 <= x0 or y1 <= y0:
                continue
            sub = sample[y0:y1, x0:x1].reshape(-1, 2)
            piece = poly_sdf_points(group, sub)[0].reshape(y1 - y0, x1 - x0)
            target = out[y0:y1, x0:x1]
            target[...] = smooth_min(target, piece, blend) if blend > 0.0 else \
                np.minimum(target, piece)
        return out

    def _paint_cel(self, canvas: Canvas, el: Element, layer: LayerSpec, field, window,
                   geo: Canvas) -> None:
        """The creature cel stack: outline, fill, shade away from the light, lit edge.

        Ink goes down first and is biased OUTWARD (module docstring), so the fill
        cannot cover it and the contour survives at any size.

        `geo` is a parallel canvas that receives the flat fill and nothing else -
        no ink, no crescent, no lit edge.  It exists so the gate can ask whether
        the SILHOUETTE edges are antialiased, which it cannot tell from the
        finished picture: a 1px rim line is a hard value jump and a stair-step is
        a hard value jump, and only one of them is a defect.
        """
        raw = el.raw
        x0, y0 = window
        pal = self.palette
        depth = self._depth_for(el, layer)
        role = str(raw.get("role", layer.role))
        tone = float(raw.get("tone", layer.tone))
        colour = _value_scale(_role(pal, role, layer.role), tone)
        alpha = float(raw.get("alpha", 1.0))
        if alpha < 1.0:
            colour = (colour[0], colour[1], colour[2], colour[3] * alpha)

        ink_w = float(raw.get("ink", layer.ink))
        if ink_w > 0.0 and pal.has("ink"):
            canvas.blend_mask(_value_scale(pal.get("ink"), float(raw.get("ink_tone", 1.0))),
                              _ink_field(field, ink_w), x0, y0)
        canvas.paint_field(field, colour, x0=x0, y0=y0)
        geo.blend_mask(colour, coverage(field), x0, y0)
        if self._cov is not None:
            view = self._cov[y0:y0 + field.shape[0], x0:x0 + field.shape[1]]
            if view.shape == field.shape:
                np.maximum(view, coverage(field), out=view)
        if depth <= 0.0:
            return
        if pal.has("shade"):
            canvas.blend_mask(_mix(colour, pal.get("shade"), 0.70),
                              _rim_field(field, depth, self.light, lit=False), x0, y0)
        if float(raw.get("key", 1.0)) > 0.0 and pal.has("rim"):
            band = _mix(colour, pal.get("rim"), 0.80 if layer.backlit else 0.52)
            canvas.blend_mask(band, _rim_field(field, max(1.0, depth * 0.22),
                                                self.light, lit=True), x0, y0)
            if layer.backlit:
                # A backlit silhouette gets a second, tighter hot line: that hard
                # bright edge against a bright plane is the entire reason a dark
                # creature reads as a silhouette in front of it.
                canvas.blend_mask(pal.get("rim"),
                                  _rim_field(field, 1.6, self.light, lit=True), x0, y0)

    def _paint_glow(self, canvas: Canvas, el: Element, layer: LayerSpec) -> None:
        """A soft radial falloff: the light source itself.

        No contours and no ink, because a light has no edge to antialias.
        """
        raw = el.raw
        at = np.asarray(raw.get("at", (0.0, 0.0)), dtype=np.float64)
        r = max(float(raw.get("r", 300.0)), 1.0)
        colour = _role(self.palette, str(raw.get("role", "fog")), "fog")
        strength = float(raw.get("alpha", 0.55))
        yy, xx = np.mgrid[0:canvas.height, 0:canvas.width]
        dx = (xx + 0.5 - (at[0] + layer.overhang)) / r
        dy = (yy + 0.5 - at[1]) / (r * float(raw.get("squash", 1.0)))
        falloff = np.clip(1.0 - np.sqrt(dx * dx + dy * dy), 0.0, 1.0) ** float(
            raw.get("power", 2.2))
        canvas.blend_mask((colour[0], colour[1], colour[2], colour[3] * strength),
                          falloff.astype(np.float32))

    def _apply_fog(self, canvas: Canvas, fog: float) -> None:
        """Atmospheric perspective: a uniform veil of the fog colour over a layer.

        Applied after the whole layer, not per element, because the veil is the
        air between the camera and that depth - it flattens the layer's internal
        contrast too, and that half of the effect is not reachable by changing
        an element's colour.
        """
        if fog <= 0.0:
            return
        a = canvas.px[:, :, 3:4]
        w = (fog * a).astype(np.float32)
        canvas.px[:, :, :3] = np.clip(
            canvas.px[:, :, :3] * (1.0 - w)
            + np.asarray(self.fog_colour[:3], dtype=np.float32) * w, 0.0, 1.0)

    def _paint_plane(self, canvas: Canvas, layer: LayerSpec) -> None:
        """The far colour plane: a flat value with a vertical gradient.

        A gradient, never a texture.  Texture in the plane is what puts noise in
        the middle of the frame, which is the one thing a backdrop may not do.
        """
        plane = layer.plane
        top = _role(self.palette, str(plane.get("role", "sky_far")), "sky_far")
        to = _role(self.palette, str(plane.get("to_role", "sky_near")), "sky_near")
        bias = float(plane.get("bias", 0.5))
        t = np.arange(canvas.height, dtype=np.float32) / max(canvas.height - 1, 1)
        ramp = np.clip((t - bias) * float(plane.get("spread", 1.6)) + bias, 0.0, 1.0)
        a = np.asarray(top[:3], dtype=np.float32)
        b = np.asarray(to[:3], dtype=np.float32)
        row = a[None, :] * (1.0 - ramp[:, None]) + b[None, :] * ramp[:, None]
        canvas.px[:, :, :3] = np.clip(row[:, None, :], 0.0, 1.0)
        canvas.px[:, :, 3] = 1.0
        if plane.get("strength") is not None:
            self._apply_fog(canvas, 1.0 - float(plane["strength"]))

    # ------------------------------------------------------------------- bake
    def bake(self) -> dict:
        started = time.perf_counter()
        tiles, crops, geo_crops = [], [], []
        for layer in self.layers:
            canvas, geo = self.new_layer_canvas(layer)
            self.render_layer(canvas, layer, geo)
            self._apply_fog(canvas, layer.fog)
            self._apply_fog(geo, layer.fog)
            crop = Canvas(self.width, self.height)
            gcrop = Canvas(self.width, self.height)
            ox = layer.overhang
            crop.px[:, :, :] = canvas.px[:, ox:ox + self.width, :]
            gcrop.px[:, :, :] = geo.px[:, ox:ox + self.width, :]
            tiles.append(canvas)
            crops.append(crop)
            geo_crops.append(gcrop)
        composite = self._composite(crops)
        geometry = self._composite(geo_crops)

        report = {
            "name": self.name,
            "seed": self.seed,
            "canvas": [self.width, self.height],
            "elements": sum(len(l.entries) for l in self.layers),
            "drawn_shapes": sum(len(l.elements) for l in self.layers),
            "layers": len(self.layers),
            "light": {"angle": round(math.degrees(math.atan2(self.light[1], self.light[0])), 1),
                      "backlit": self.backlit},
            "palette": self.palette.to_dict(),
            "role_values": {r: round(_luma(c), 4) for r, c in self.palette.roles.items()},
            "layer_report": [],
            "warnings": list(self._warn),
        }
        for layer, crop in zip(self.layers, crops):
            alpha = crop.px[:, :, 3]
            solid = alpha > 0.5
            report["layer_report"].append({
                "name": layer.name,
                "parallax": round(layer.parallax, 3),
                "fog": round(layer.fog, 3),
                "role": layer.role,
                "ink": layer.ink,
                "elements": len(layer.entries),
                "drawn_shapes": len(layer.elements),
                "tile_width": self.width + layer.overhang * 2,
                "overhang": layer.overhang,
                "coverage": round(float(solid.mean()), 4),
                "mean_value_solid": (round(_mean_luma(crop.px[:, :, :3][solid]), 4)
                                     if bool(solid.any()) else None),
            })
        report["gate"] = gate(self, crops, composite, geometry)
        report["warnings"].extend(report["gate"]["warnings"])
        report["seconds"] = round(time.perf_counter() - started, 3)
        return {"composite": composite, "crops": crops, "tiles": tiles, "report": report}

    def _composite(self, crops) -> Canvas:
        out = Canvas(self.width, self.height)
        for crop in crops:
            src = crop.px
            a_src = src[:, :, 3:4]
            a_dst = out.px[:, :, 3:4]
            out_a = a_src + a_dst * (1.0 - a_src)
            safe = np.where(out_a > 1e-6, out_a, 1.0)
            carry = a_dst * (1.0 - a_src)
            out.px[:, :, :3] = np.clip(
                (src[:, :, :3] * a_src + out.px[:, :, :3] * carry) / safe, 0.0, 1.0)
            out.px[:, :, 3] = np.clip(out_a[:, :, 0], 0.0, 1.0)
        if not bool((out.px[:, :, 3] > 0.999).all()):
            # A spec with no full-frame plane would otherwise leave the composite
            # transparent; the fog colour is the honest backdrop for that.
            base = np.asarray(self.fog_colour[:3], dtype=np.float32)
            a = out.px[:, :, 3:4]
            out.px[:, :, :3] = np.clip(
                out.px[:, :, :3] * a + base[None, None, :] * (1.0 - a), 0.0, 1.0)
            out.px[:, :, 3] = 1.0
            self._warn.append("no layer covered the whole frame - the composite was "
                              "flattened onto the fog colour")
        return out


# --------------------------------------------------------------- cel banding
def _ink_field(field: np.ndarray, width: float) -> np.ndarray:
    """The outline band, OUTSIDE the silhouette: 0 <= d <= width.

    `Canvas.paint_ink` builds `|d + w/2| - w/2`, which with this sdf's sign
    convention is -w <= d <= 0 - the inside.  The fill covers it.  This is the
    band the docstring describes, and at 1280x720 the difference is a contour
    line or no contour line.
    """
    if width <= 0.0:
        return np.zeros_like(field)
    half = width * 0.5
    return coverage(np.abs(field - half) - half, 1.0)


def _rim_field(field: np.ndarray, depth: float, light, lit: bool) -> np.ndarray:
    """A cel crescent on one side of a silhouette.

    Identical maths to `Canvas._rim_band`, with the light direction as a
    parameter instead of a module constant, so a spec can be lit from behind.
    """
    if depth <= 0.0:
        return np.zeros_like(field)
    step = -light if lit else light
    probe = shifted(field, step[0] * depth, step[1] * depth)
    band = coverage(np.maximum(field, -probe), 1.0)
    band = np.where(field < 0.0, band, 0.0)
    inner = coverage(np.minimum(field + depth, 1e6), 1.0)
    return band * (1.0 - inner)


# ---------------------------------------------------------------------- gate
# THRESHOLDS.  Every one of these was set by rendering the twelve, reading the
# numbers, looking at the pictures, and moving the line to where the failures
# actually start.  None of them is a round number picked in advance.
CENTRE_BUSY_RATIO_GATE = 1.00    # centre busier than the sides: failed by definition
CENTRE_BUSY_WARN = 0.70          # measured ratio across the twelve: 0.09 - 0.55
CENTRE_FILL_GATE = 0.30          # share of the centre covered by a foreground layer
DEPTH_GAP_GATE = 0.020           # min adjacent layer value gap, absolute, 0..1
DEPTH_SPREAD_GATE = 0.075        # front-to-back value travel
EDGE_SOFT = 0.06                 # coverage this far from 0 or 1 is a blended pixel
MIN_AA_COVERAGE = 0.30           # calibrated: 0.86-0.91 measured, 0.00 for a hard fill


def _luma_image(rgba: np.ndarray) -> np.ndarray:
    return (rgba[:, :, :3].astype(np.float32) * LUMA[None, None, :]).sum(axis=2)


def _crop(luma: np.ndarray, box) -> np.ndarray:
    h, w = luma.shape
    x0, y0, x1, y1 = box
    return luma[int(y0 * h):max(int(y1 * h), int(y0 * h) + 1),
                int(x0 * w):max(int(x1 * w), int(x0 * w) + 1)]


def _region_mask(shape, boxes, minus=None) -> np.ndarray:
    h, w = shape
    m = np.zeros((h, w), dtype=bool)
    for x0, y0, x1, y1 in boxes:
        m[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)] = True
    if minus is not None:
        m &= ~_region_mask(shape, [minus])
    return m


def _busyness(luma: np.ndarray) -> float:
    """Mean absolute luminance gradient over a region: how much is going on here.

    A first difference, not a Laplacian.  A second difference triples the noise
    sensitivity, and a backdrop is mostly smooth, so the first difference is the
    honest version of the question.
    """
    if luma.shape[0] < 3 or luma.shape[1] < 3:
        return 0.0
    gx = np.abs(np.diff(luma, axis=1)).mean()
    gy = np.abs(np.diff(luma, axis=0)).mean()
    return float((gx + gy) * 0.5)


def _grad_map(luma: np.ndarray) -> np.ndarray:
    """Per-pixel gradient magnitude, so an arbitrary region mask can be measured.

    The centre rectangle and the two side thirds are different shapes, and the
    side reference has a notch cut out of it where the centre overlaps.  A
    rectangular crop cannot express that, and reshaping a masked array into a
    rectangle would glue the two sides together across a gap.  So the gradient
    is computed once over the frame and averaged inside each mask.
    """
    g = np.zeros(luma.shape, dtype=np.float32)
    if luma.shape[0] > 1 and luma.shape[1] > 1:
        g[:, :-1] = np.abs(np.diff(luma, axis=1))
        g[:-1, :] += np.abs(np.diff(luma, axis=0))
    return g * 0.5


def _aa_coverage(cov: np.ndarray) -> float:
    """Antialiased boundary pixels as a share of all boundary pixels.

    Measured on the accumulated coverage, not on the picture, and that is the
    whole point.  `coverage(field, feather=1)` saturates: on a vertical edge that
    lands exactly between two pixel centres, the inside sample reads 1.0 and the
    outside sample reads 0.0, so the finished image shows a full-contrast step
    between neighbours - byte for byte what `draw_polygon` produces.  No
    threshold on pixel values can separate those, because they are the same
    numbers.  What differs is whether a partial-coverage pixel exists, and only
    the coverage field knows that.

    So the test is: does the render contain blended silhouette pixels at all, and
    in what proportion?  A hard-filled shape has none anywhere and scores 0.  A
    coverage-filled shape has one on every edge that is not perfectly axis
    aligned, and never fewer than about a third.

    The absolute number is a property of the GEOMETRY, not a defect rate: a
    scene of axis-aligned rectangles scores lower than a scene of diagonals and
    both are fully antialiased.  It is a floor test, and the gate sits far enough
    below the coverage path to be unambiguous.  Positive control: the same
    silhouette through `Canvas.draw_polygon` scores 0.000, through
    `Canvas.paint_field` it scores 0.35.
    """
    if cov is None or not cov.any():
        return 1.0
    solid = cov > 0.5
    edge = (solid != np.roll(solid, 1, axis=1)) | (solid != np.roll(solid, 1, axis=0))
    total = int(edge.sum())
    if total == 0:
        return 1.0
    soft = (cov > EDGE_SOFT) & (cov < 1.0 - EDGE_SOFT)
    near = (soft
            | np.roll(soft, 1, axis=1) | np.roll(soft, -1, axis=1)
            | np.roll(soft, 1, axis=0) | np.roll(soft, -1, axis=0))
    return float((edge & near).sum()) / float(total)


def gate(backdrop: "Backdrop", crops, composite, geometry) -> dict:
    """The machine checks a backdrop has to survive.

    Centre openness is measured three ways because one number lies.  Mean
    luminance: is the middle the quietest VALUE?  Gradient density: is the middle
    the quietest TEXTURE?  Drawn coverage from the per-layer alphas: is anything
    actually standing in the middle?  A background can be bright and flat and
    still have a pipe through the middle, and it can be dark and smooth and
    still be a legible mid-value wall.
    """
    rgba = composite.px
    luma = _luma_image(rgba)
    shape = luma.shape
    grad = _grad_map(luma)
    centre_mask = _region_mask(shape, [CENTRE])
    sides_mask = _region_mask(shape, [THIRD_L, THIRD_R], minus=CENTRE)
    centre = luma[centre_mask]
    sides = luma[sides_mask]

    busy_c = float(grad[centre_mask].mean())
    busy_s = float(grad[sides_mask].mean())
    ratio = busy_c / busy_s if busy_s > 1e-6 else 0.0

    occ = np.zeros(shape, dtype=bool)
    front = np.zeros(shape, dtype=bool)
    for layer, crop in zip(backdrop.layers, crops):
        if layer.name == "sky":
            continue                       # the plane is a value, not an object
        solid = crop.px[:, :, 3] > 0.5
        occ |= solid
        if layer.name in ("mid", "near", "foreground"):
            front |= solid
    centre_fill = float(occ[centre_mask].mean()) if occ.any() else 0.0
    centre_fill_front = float(front[centre_mask].mean()) if front.any() else 0.0

    values = []
    for layer, crop in zip(backdrop.layers, crops):
        solid = crop.px[:, :, 3] > 0.5
        values.append(_mean_luma(crop.px[:, :, :3][solid]) if bool(solid.any()) else None)
    gaps = [None if (a is None or b is None) else abs(a - b)
            for a, b in zip(values, values[1:])]
    real = [g for g in gaps if g is not None]
    present = [v for v in values if v is not None]
    spread = float(max(present) - min(present)) if len(present) >= 2 else None
    hard = _aa_coverage(backdrop._cov)
    n = sum(len(l.entries) for l in backdrop.layers)

    errors: list = []
    warnings: list = []
    if ratio > CENTRE_BUSY_RATIO_GATE:
        errors.append(f"G-B1 the centre is busier than the sides "
                      f"(ratio {ratio:.2f} > {CENTRE_BUSY_RATIO_GATE}) - the middle "
                      f"band has to stay open for the creature")
    elif ratio > CENTRE_BUSY_WARN:
        warnings.append(f"G-B1 centre/side busyness {ratio:.2f} is close to the "
                        f"{CENTRE_BUSY_RATIO_GATE} limit")
    if centre_fill_front > CENTRE_FILL_GATE:
        errors.append(f"G-B2 {centre_fill_front:.0%} of the centre is covered by a "
                      f"foreground layer (gate {CENTRE_FILL_GATE:.0%}) - a pale far "
                      f"layer behind the creature is fine, a dark near one is not")
    if real and min(real) < DEPTH_GAP_GATE:
        errors.append(f"G-B3 two adjacent layers sit {min(real):.3f} apart in value "
                      f"(gate {DEPTH_GAP_GATE}) - they will merge into one plane")
    if spread is not None and spread < DEPTH_SPREAD_GATE:
        errors.append(f"G-B3 front-to-back value travel is only {spread:.3f} "
                      f"(gate {DEPTH_SPREAD_GATE}) - the depth does not read")
    if hard < MIN_AA_COVERAGE:
        errors.append(f"G-B5 only {hard:.0%} of silhouette boundary pixels have an "
                      f"antialiased pixel beside them (floor {MIN_AA_COVERAGE:.0%}) - "
                      f"something is being filled without coverage")
    if not (MIN_ELEMENTS <= n <= MAX_ELEMENTS):
        errors.append(f"G-B4 {n} elements, the spec says {MIN_ELEMENTS}-{MAX_ELEMENTS}")
    if not (MIN_LAYERS <= len(backdrop.layers) <= MAX_LAYERS):
        errors.append(f"G-B6 {len(backdrop.layers)} layers, the spec says "
                      f"{MIN_LAYERS}-{MAX_LAYERS}")

    return {
        "centre_luma": round(float(centre.mean()), 4) if centre.size else 0.0,
        "sides_luma": round(float(sides.mean()), 4) if sides.size else 0.0,
        "centre_busy": round(busy_c, 4),
        "sides_busy": round(busy_s, 4),
        "busyness_ratio": round(ratio, 3),
        "centre_contrast": round(float(centre.std()) if centre.size else 0.0, 4),
        "sides_contrast": round(float(sides.std()) if sides.size else 0.0, 4),
        "centre_fill": round(centre_fill, 4),
        "centre_fill_front": round(centre_fill_front, 4),
        "layer_values": [None if v is None else round(v, 4) for v in values],
        "adjacent_gaps": [None if g is None else round(g, 4) for g in gaps],
        "min_adjacent_gap": round(min(real), 4) if real else None,
        "depth_spread": None if spread is None else round(spread, 4),
        "aa_coverage": round(hard, 4),
        "elements": n,
        "ok": not errors,
        "errors": errors,
        "warnings": warnings,
    }


# ------------------------------------------------------------------------ CLI
def load_library(extra: list[str] | None = None) -> ShapeLibrary:
    lib = ShapeLibrary([ROOT / "shapes"])
    for path in extra or []:
        lib.add(Path(path))
    return lib


def expand_specs(paths) -> list:
    """argv paths may be globs the shell did not expand, or not."""
    out: list = []
    for raw in paths:
        p = Path(raw)
        if p.is_file():
            out.append(p)
        elif p.is_dir():
            out.extend(sorted(p.glob("*.json")))
        else:
            out.extend(Path(m) for m in sorted(globmod.glob(str(raw), recursive=True))
                       if Path(m).is_file())
    seen, uniq = set(), []
    for p in out:
        key = str(p.resolve()).lower()
        if key not in seen:
            seen.add(key)
            uniq.append(p)
    return uniq


def bake_one(spec_path: Path, out_dir: Path, library: ShapeLibrary, index: int,
             write: bool = True) -> dict:
    spec = json.loads(Path(spec_path).read_text(encoding="utf-8"))
    spec.setdefault("name", Path(spec_path).stem)
    backdrop = Backdrop(spec, library, index)
    result = backdrop.bake()
    name = backdrop.name
    report = result["report"]
    report["spec"] = str(spec_path)
    written = []
    out_dir.mkdir(parents=True, exist_ok=True)
    for layer, crop, tile in zip(backdrop.layers, result["crops"], result["tiles"]):
        crop.save(out_dir / f"{name}_layer_{layer.name}.png")
        written.append(f"{name}_layer_{layer.name}.png")
        if layer.overhang:
            tile.save(out_dir / f"{name}_tile_{layer.name}.png")
            written.append(f"{name}_tile_{layer.name}.png")
    result["composite"].save(out_dir / f"{name}.png")
    written.append(f"{name}.png")
    written.append(f"{name}.json")
    report["files"] = written
    if write:
        (out_dir / f"{name}.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


def print_report(report: dict) -> None:
    if report.get("error"):
        return
    g = report.get("gate", {})
    print(f"{'ok  ' if g.get('ok') else 'FAIL'} {report.get('name', '?'):24s} "
          f"{report.get('canvas', [0, 0])[0]}x{report.get('canvas', [0, 0])[1]} "
          f"L={report.get('layers', 0)} el={report.get('elements', 0):2d} "
          f"draw={report.get('drawn_shapes', 0):3d} "
          f"busy={g.get('busyness_ratio', 0):.2f} "
          f"fill={g.get('centre_fill_front', 0):.2f} "
          f"depth={g.get('depth_spread') or 0:.3f} "
          f"aa={g.get('aa_coverage', 0):.2f} "
          f"{report.get('seconds', 0)}s")
    for msg in g.get("errors", []):
        print(f"     FAIL {msg}", file=sys.stderr)
    for msg in g.get("warnings", []) + report.get("warnings", []):
        if msg not in g.get("errors", []):
            print(f"     warn {msg}", file=sys.stderr)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        prog="procbake.backdrop", description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("specs", nargs="*", type=str, help="backdrop spec JSON files")
    parser.add_argument("-o", "--out", type=Path, default=ROOT / "out" / "backdrops")
    parser.add_argument("--shapes", nargs="*", default=[], help="extra shape directories")
    parser.add_argument("--pad", type=int, default=10, help="contact sheet padding")
    parser.add_argument("--sheet", default="", help="also write a contact sheet under this name")
    parser.add_argument("--check", action="store_true", help="gate only, write no PNG")
    args = parser.parse_args(argv)

    paths = expand_specs(args.specs)
    if not paths:
        parser.error("no specs given (pass a file, a directory or a glob)")
    library = load_library(args.shapes)

    reports, images, labels = [], [], []
    for i, path in enumerate(paths):
        try:
            report = bake_one(path, args.out, library, i, write=not args.check)
        except Exception as exc:
            reports.append({"name": Path(path).stem, "spec": str(path),
                            "error": f"{type(exc).__name__}: {exc}"})
            print_report(reports[-1])
            continue
        reports.append(report)
        if args.sheet and not args.check:
            from PIL import Image
            images.append(Image.open(args.out / f"{report['name']}.png"))
            labels.append(report["name"])
        print_report(report)

    for report in reports:
        if report.get("error"):
            print(f"FAIL {report['spec']}: {report['error']}", file=sys.stderr)
    if args.sheet and images:
        from PIL import Image
        cols = int(math.ceil(math.sqrt(len(images)))) or 1
        sheet_mod.compose(images, columns=cols, pad=args.pad,
                          background=(20, 20, 23, 255), labels=labels).save(
            args.out / f"{args.sheet}.png")
        print(f"contact sheet -> {args.out / f'{args.sheet}.png'}")

    bad = [r for r in reports if r.get("error") or not r.get("gate", {}).get("ok", False)]
    print(f"\n{len(reports) - len(bad)}/{len(reports)} pass the gate")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
