"""Scene lighting layer for composited previews (v02, h0-icon-mood-v02).

The painted assets keep their own diffuse top light.  This module adds an
optional *scene* light on top, the way a 2D game does it at runtime:

    lit = painted * light_map  +  emission  +  halos/haze

``light_map`` = ambient (colour x level) + ground light pools + beam pools,
optionally darkened by a corner vignette, then raised back to a minimum level
on the readability guards (passages, interactive objects).  All positions are
source pixels of the 2560x1440 background.  Nothing here draws shapes: pools
are computed falloffs, only the look of the painted assets is icon-made.

Spec (scene JSON ``"lighting"``)::

    {"ambient": {"color": "#6c7394", "level": 0.30},
     "lights": [{"at": [x, y], "radius": 360, "color": "#ffc27a", "intensity": 0.9,
                 "shape": "linear" | "smooth", "core": 0.0, "power": 1.0,
                 "halo": {"at": [x, y], "radius": 70, "opacity": 0.35}}],
     "follow": [{"item": "player", "offset": [0, -30], "radius": 520, ...}],
     "beams":  [{"floor": [x, y], "radius": [rx, ry], "color": "#cfdde2", "intensity": 0.5,
                 "poly": [[x, y], ...], "haze": 0.08, "haze_blur": 90}],
     "vignette": {"strength": 0.3, "inner": 0.85, "outer": 1.45},
     "guard": {"level": 0.42, "color": "#d8d0c8",
               "areas": [{"poly": [[x, y], ...], "blur": 80, "level": 0.42}],
               "items": {"level": 0.62, "pad": 36, "soft": 0.35}},
     "max": 1.3, "emissive_gain": 1.0, "step": 4}

``radius`` of a ground pool is the horizontal radius; the vertical one is
foreshortened by the 60 deg camera (x0.866) unless ``squash`` is given.
"""

from __future__ import annotations

import math

import numpy as np
from PIL import Image, ImageDraw

from . import paint as P

GROUND = math.sin(math.radians(60.0))


def tint(value) -> np.ndarray:
    """Colour normalised to unit luma, so ``level`` alone sets brightness."""
    c = P.hex_rgb(value)
    lum = 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
    return (c / max(float(lum), 1e-4)).astype(np.float32)


def falloff(t: np.ndarray, shape: str = "linear", core: float = 0.0, power: float = 1.0) -> np.ndarray:
    u = np.clip((t - core) / max(1e-6, 1.0 - core), 0.0, 1.0)
    f = 1.0 - u * u * (3.0 - 2.0 * u) if shape == "smooth" else 1.0 - u
    return np.clip(f, 0.0, 1.0) ** power


class LightGrid:
    def __init__(self, W: int, H: int, step: int):
        self.W, self.H, self.step = W, H, step
        self.w, self.h = int(math.ceil(W / step)), int(math.ceil(H / step))
        ys, xs = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        self.xs, self.ys = (xs + 0.5) * step, (ys + 0.5) * step

    def dist(self, at, radius, squash: float = GROUND) -> np.ndarray:
        if isinstance(radius, (int, float)):
            rx, ry = float(radius), float(radius) * squash
        else:
            rx, ry = float(radius[0]), float(radius[1])
        return np.sqrt(((self.xs - at[0]) / rx) ** 2 + ((self.ys - at[1]) / ry) ** 2)

    def polygon(self, pts, blur_px: float = 0.0) -> np.ndarray:
        im = Image.new("L", (self.w, self.h), 0)
        ImageDraw.Draw(im).polygon([(x / self.step, y / self.step) for x, y in pts], fill=255)
        m = np.asarray(im, dtype=np.float32) / 255.0
        return P.blur(m, blur_px / self.step) if blur_px else m

    def upsample(self, arr: np.ndarray) -> np.ndarray:
        chans = [np.asarray(Image.fromarray(np.ascontiguousarray(arr[..., i])).resize((self.W, self.H),
                                                                                      Image.Resampling.BICUBIC))
                 for i in range(arr.shape[2])]
        return np.dstack(chans).astype(np.float32)


def _pool(grid: LightGrid, spec: dict, at) -> np.ndarray:
    t = grid.dist(at, spec["radius"], spec.get("squash", GROUND))
    f = falloff(t, spec.get("shape", "linear"), spec.get("core", 0.0), spec.get("power", 1.0))
    return f[..., None] * tint(spec.get("color", "#ffffff")) * float(spec.get("intensity", 1.0))


def _halo(grid: LightGrid, halo: dict, at, color) -> np.ndarray:
    t = grid.dist(halo.get("at", at), halo["radius"], 1.0)
    f = falloff(t, "smooth", 0.0, halo.get("power", 2.0))
    return f[..., None] * tint(halo.get("color", color)) * float(halo.get("opacity", 0.3))


def build(spec: dict, W: int, H: int, items: dict | None = None) -> dict:
    """Return full-size float maps: ``light`` (multiplier) and ``add`` (additive light)."""
    items = items or {}
    grid = LightGrid(W, H, int(spec.get("step", 4)))
    amb = spec.get("ambient", {"color": "#ffffff", "level": 1.0})
    L = np.broadcast_to(tint(amb.get("color", "#ffffff")) * float(amb.get("level", 1.0)),
                        (grid.h, grid.w, 3)).astype(np.float32).copy()
    A = np.zeros_like(L)
    for light in spec.get("lights", []):
        L += _pool(grid, light, light["at"])
        if light.get("halo"):
            A += _halo(grid, light["halo"], light["at"], light.get("color", "#ffffff"))
    for follow in spec.get("follow", []):
        item = items.get(follow["item"])
        if item is None:
            continue
        off = follow.get("offset", [0, 0])
        at = [item["at"][0] + off[0], item["at"][1] + off[1]]
        L += _pool(grid, follow, at)
        if follow.get("halo"):
            A += _halo(grid, follow["halo"], at, follow.get("color", "#ffffff"))
    for beam in spec.get("beams", []):
        L += _pool(grid, dict(beam, shape=beam.get("shape", "smooth"), core=beam.get("core", 0.15)), beam["floor"])
        if beam.get("haze", 0) > 0 and beam.get("poly"):
            m = grid.polygon(beam["poly"], beam.get("haze_blur", 80))
            A += m[..., None] * tint(beam.get("color", "#ffffff")) * float(beam["haze"])
    vig = spec.get("vignette")
    if vig:
        r = np.sqrt(((grid.xs - W / 2) / (W / 2)) ** 2 + ((grid.ys - H / 2) / (H / 2)) ** 2)
        L *= (1.0 - vig.get("strength", 0.3) * P.smoothstep(vig.get("inner", 0.85), vig.get("outer", 1.45), r))[..., None]
    guard = spec.get("guard")
    if guard:
        g = np.zeros((grid.h, grid.w), dtype=np.float32)
        for area in guard.get("areas", []):
            g = np.maximum(g, grid.polygon(area["poly"], area.get("blur", 60)) * area.get("level", guard.get("level", 0.4)))
        gi = guard.get("items")
        if gi:
            for item in items.values():
                if not item.get("interactive") or not item.get("bbox"):
                    continue
                x0, y0, x1, y1 = item["bbox"]
                pad = gi.get("pad", 30)
                rx, ry = (x1 - x0) / 2 + pad, (y1 - y0) / 2 + pad
                t = grid.dist(((x0 + x1) / 2, (y0 + y1) / 2), (rx, ry))
                g = np.maximum(g, (1.0 - P.smoothstep(1.0 - gi.get("soft", 0.35), 1.0, t)) * gi.get("level", 0.6))
        L = np.maximum(L, g[..., None] * tint(guard.get("color", "#ffffff")))
    L = np.minimum(L, float(spec.get("max", 1.3)))
    return {"light": grid.upsample(L), "add": grid.upsample(A)}


def apply(rgb: np.ndarray, emit: np.ndarray | None, maps: dict, spec: dict, seed: int = 5) -> np.ndarray:
    """``rgb`` straight 0..1 (H, W, 3); ``emit`` premultiplied additive light or None."""
    out = rgb * maps["light"] + maps["add"]
    if emit is not None:
        out = out + emit * float(spec.get("emissive_gain", 1.0))
    # tiny dither so the deep gradients do not band in 8-bit
    out += (np.random.default_rng(seed).random(out.shape[:2], dtype=np.float32)[..., None] - 0.5) / 255.0
    return np.clip(out, 0.0, 1.0)
