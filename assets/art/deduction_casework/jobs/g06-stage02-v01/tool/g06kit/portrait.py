"""Portraits: 320x320 transparent 3/4 busts, head centre (160,132), head height
150 px in every g06 portrait (face position fixed across the whole kit)."""

from __future__ import annotations

from . import recipe
from . import person as P

PORTRAIT_HEAD = (160, 132)
PORTRAIT_HH = 150.0


def portrait_joints(view="3q"):
    H = PORTRAIT_HH * P.HEAD_RATIO
    g0 = (160, 400)
    j = P.pose_stand(g0, H, view)
    dx, dy = PORTRAIT_HEAD[0] - j["head"][0], PORTRAIT_HEAD[1] - j["head"][1]
    return P.pose_stand((g0[0] + dx, g0[1] + dy), H, view), H


def portrait(asset_id, body_fn, note, palette, view="3q", mirror=False, seed=31):
    j, H = portrait_joints(view)
    forms = body_fn(j, H, view)
    frames = [{"name": asset_id, "mirror": True}] if mirror else None
    return recipe(asset_id, forms, (320, 320), PORTRAIT_HEAD, palette, style="sprite", seed=seed, frames=frames,
                  pivot_meaning="head centre (same pixel in every portrait)",
                  note=note + " 3/4 bust, 320x320 transparent; head centre at (160,132), head height 150 px in every "
                              "g06 portrait.")
