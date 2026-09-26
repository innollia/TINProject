"""g01 overlay recipes: fog, weather, light circles, darkness masks, screen patterns.

    py -3 -B gen_overlays.py [--stage A|B|C|all] [--only ov_a,ov_b]

Tileable overlays (meta.tileable = true) are 768 x 768 and wrap on every edge:
each scattered piece that crosses an edge is repeated one tile over (wrap()), so
the blurred result meets itself seamlessly.  Nothing here uses noise fields that
are not periodic (no mottle, no texture) for that reason.
"""

from __future__ import annotations

import argparse
import copy
import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g01kit import C, D, F, P, POLY, R, RR, SPARK, animate, halo, poly_abs, ringp, save, sub, turn  # noqa: E402

RDIR = Path(__file__).resolve().parents[1] / "recipes"
OV: list = []
T = 768   # tile size


def ov(stage, asset, note):
    def deco(fn):
        OV.append((stage, asset, note, fn))
        return fn
    return deco


def extent(piece):
    size = piece.get("size", 16)
    if isinstance(size, (int, float)):
        return size / 2.0
    return max(v for v in size if v is not None) / 2.0


def wrap(pieces, w=T, h=T, margin=0.0):
    """Repeat every piece that reaches within ``margin`` of an edge on the opposite side(s)."""
    out = []
    for p in pieces:
        e = extent(p) + margin
        x, y = p["at"]
        xs = [0] + ([w] if x - e < 0 else []) + ([-w] if x + e > w else [])
        ys = [0] + ([h] if y - e < 0 else []) + ([-h] if y + e > h else [])
        for dx in xs:
            for dy in ys:
                q = copy.deepcopy(p)
                q["at"] = [round(x + dx, 2), round(y + dy, 2)]
                out.append(q)
    return out


def tile_meta(extra=None):
    m = {"kind": "overlay", "tileable": True, "tile": [T, T], "blend": "normal over the scene (alpha)",
         "scroll_hint": "slow drift"}
    m.update(extra or {})
    return m


# ================================================================== A
@ov("A", "ov_fog_light", "Light fog: sparse soft wisps of pale violet-grey, low alpha, tiles seamlessly (768).")
def fog_light():
    rng = random.Random(101)
    big = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(220, 380), rng.uniform(120, 200)) for _ in range(16)]
    wisps = [P("cloud", rng.uniform(0, T), rng.uniform(0, T), rng.uniform(200, 320), rng.uniform(50, 80))
             for _ in range(22)]
    forms = [
        F("haze", None, wrap(big, margin=90), 0, "flat", color="fog", blur=60, opacity=0.2),
        F("wisps", None, wrap(wisps, margin=50), 1, "flat", color="#a8a2ba", blur=26, opacity=0.16),
    ]
    return {"forms": forms, "canvas": (T, T), "meta": tile_meta({"scroll_hint": "drift 8-20 px/s sideways"})}


def light_circle(asset, d, colors):
    c = d / 2.0
    frames_forms = []
    for _name, col in colors:
        frames_forms.append([
            F("outer", None, [C(c, c, d * 0.56)], 0, "flat", color=col, blur=d * 0.12, opacity=0.34),
            F("mid", None, [C(c, c, d * 0.36)], 1, "flat", color=col, blur=d * 0.08, opacity=0.5),
            F("core", None, [C(c, c, d * 0.16)], 2, "flat", color=col, blur=d * 0.05, opacity=0.8),
        ])
    forms, frames = animate(frames_forms, asset, names=[f"{asset}_{n}" for n, _ in colors])
    return {"forms": forms, "frames": frames, "canvas": (d, d),
            "meta": {"kind": "overlay_light", "tileable": False, "sizes_px": d,
                     "blend": "additive (or screen) over the scene", "colors": [n for n, _ in colors]}}


WHITE_YELLOW = [("white", "#fff6ec"), ("yellow", "#ffd27a")]


@ov("A", "ov_light_circle_s", "Light circle, small (192): white and yellow soft radial light, three stacked falloffs.")
def light_s():
    return light_circle("ov_light_circle_s", 192, WHITE_YELLOW)


@ov("A", "ov_light_circle_m", "Light circle, medium (384): white and yellow.")
def light_m():
    return light_circle("ov_light_circle_m", 384, WHITE_YELLOW)


@ov("A", "ov_light_circle_l", "Light circle, large (768): white and yellow.")
def light_l():
    return light_circle("ov_light_circle_l", 768, WHITE_YELLOW)


@ov("A", "ov_vision_dark", "Darkness outside the field of view: near-black veil over 2560x1440 with a soft clear hole (wide and narrow).")
def vision_dark():
    W, H = 2560, 1440
    frames_forms = []
    for hole, soft in ((1180, 150), (700, 110)):
        frames_forms.append([
            F("veil", None, [R(W / 2, H / 2, W + 900, H + 900), sub(C(W / 2, H / 2, hole, hole))], 0, "flat",
              color="dark_veil", blur=soft, opacity=0.96),
            F("edge", None, [C(W / 2, H / 2, hole * 1.25, hole * 1.25), sub(C(W / 2, H / 2, hole * 0.9, hole * 0.9))],
              0.5, "flat", color="#120c18", blur=soft * 1.2, opacity=0.35),
        ])
    forms, frames = animate(frames_forms, "ov_vision_dark", names=["ov_vision_dark_wide", "ov_vision_dark_narrow"])
    return {"forms": forms, "frames": frames, "canvas": (W, H),
            "meta": {"kind": "overlay_mask", "tileable": False, "blend": "normal (alpha) over everything",
                     "hole_centre": [W / 2, H / 2], "note": "move the whole image with the player"}}


# ================================================================== B
@ov("B", "ov_fog_thick", "Thick fog: dense layered banks of dark and pale violet-grey, higher alpha, tiles seamlessly (768).")
def fog_thick():
    rng = random.Random(211)
    banks = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(260, 420), rng.uniform(150, 240)) for _ in range(22)]
    body = [P("cloud", rng.uniform(0, T), rng.uniform(0, T), rng.uniform(220, 340), rng.uniform(90, 140))
            for _ in range(26)]
    wisps = [P("cloud", rng.uniform(0, T), rng.uniform(0, T), rng.uniform(160, 260), rng.uniform(40, 70))
             for _ in range(24)]
    forms = [
        F("base", None, [R(T / 2, T / 2, T + 400, T + 400)], -1, "flat", color="fog_dark", opacity=0.22),
        F("banks", None, wrap(banks, margin=110), 0, "flat", color="fog_dark", blur=70, opacity=0.35),
        F("body", None, wrap(body, margin=70), 1, "flat", color="fog", blur=40, opacity=0.3),
        F("wisps", None, wrap(wisps, margin=40), 2, "flat", color="#aaa4bc", blur=18, opacity=0.2),
    ]
    return {"forms": forms, "canvas": (T, T), "meta": tile_meta({"scroll_hint": "drift 4-12 px/s sideways"})}


@ov("B", "ov_rain", "Rain: thin slanted streaks in two depths (long faint far drops, shorter brighter near drops), tiles seamlessly (768).")
def rain():
    rng = random.Random(223)

    def drops(n, lmin, lmax, wmin, wmax):
        pcs = []
        for _ in range(n):
            x, y, ln, w = rng.uniform(0, T), rng.uniform(0, T), rng.uniform(lmin, lmax), rng.uniform(wmin, wmax)
            pcs.append(R(x, y, w, ln, rot=14))
        return pcs

    forms = [
        F("far", None, wrap(drops(170, 30, 52, 1.2, 1.8), margin=6), 0, "flat", color="rain", blur=0.6, opacity=0.28),
        F("near", None, wrap(drops(70, 44, 72, 2.0, 3.0), margin=6), 1, "flat", color="#c4cce0", blur=0.8, opacity=0.45),
    ]
    return {"forms": forms, "canvas": (T, T),
            "meta": tile_meta({"scroll_hint": "scroll down-left fast (about 900 px/s down, 220 px/s left); layer twice at two speeds"})}


@ov("B", "ov_snow", "Snow: soft flakes in two depths, small far dots and larger blurred near flakes with a few sparkles, tiles seamlessly (768).")
def snow():
    rng = random.Random(227)
    far = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(3, 5.5)) for _ in range(190)]
    near = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(7, 12)) for _ in range(46)]
    glints = [SPARK(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(9, 14)) for _ in range(10)]
    forms = [
        F("far", None, wrap(far, margin=4), 0, "flat", color="snow", blur=0.8, opacity=0.55),
        F("near", None, wrap(near, margin=8), 1, "flat", color="#f4f2f8", blur=2.4, opacity=0.7),
        F("glints", None, wrap(glints, margin=8), 2, "flat", color="#ffffff", opacity=0.8),
    ]
    return {"forms": forms, "canvas": (T, T),
            "meta": tile_meta({"scroll_hint": "scroll down slowly (40-80 px/s) with a small sideways sway"})}


@ov("B", "ov_leaves", "Falling leaves: sparse brown, rust and wine leaves at random angles with midribs, tiles seamlessly (768).")
def leaves():
    rng = random.Random(229)
    forms = []
    for i, col in enumerate(("#7a4a26", "#8e5a2c", "#6a2e24")):
        pcs, ribs = [], []
        for _ in range(9):
            x, y = rng.uniform(0, T), rng.uniform(0, T)
            s, rot = rng.uniform(30, 48), rng.uniform(0, 360)
            pcs.append(D(x, y, s * 0.55, s, rot=rot))
            ribs.append(R(x, y, 1.2, s * 0.8, rot=rot))
        forms.append(F(f"leaf{i}", None, wrap(pcs, margin=4), i, color=col, shade={"bump": 0.8, "highlight_amount": 0.3}))
        forms.append(F(f"rib{i}", None, wrap(ribs, margin=4), i + 0.5, "flat", color="#2a1a10", clip_to=f"leaf{i}",
                       opacity=0.6))
    return {"forms": forms, "canvas": (T, T),
            "meta": tile_meta({"scroll_hint": "scroll down-right slowly (30-60 px/s); rotate the layer a little for flutter"})}


# ================================================================== C
@ov("C", "ov_screen_noise", "Screen noise: fine grain in three greys plus faint scanlines, two frames to flicker, tiles seamlessly (768).")
def screen_noise():
    frames_forms = []
    for seed in (307, 311):
        rng = random.Random(seed)
        fl = [F("scan", None, [R(T / 2, y + 1, T + 8, 1.2) for y in range(0, T, 4)], 0, "flat", color="#000000",
                opacity=0.18)]
        for i, (col, op) in enumerate((("#000000", 0.5), ("#8a8494", 0.35), ("#e6e2ee", 0.3))):
            dots = [R(rng.uniform(0, T), rng.uniform(0, T), s, s) for s in
                    (rng.uniform(1.0, 2.4) for _ in range(700))]
            fl.append(F(f"grain{i}", None, wrap(dots, margin=2), 1 + i * 0.1, "flat", color=col, opacity=op))
        frames_forms.append(fl)
    forms, frames = animate(frames_forms, "ov_screen_noise", names=["ov_screen_noise_a", "ov_screen_noise_b"])
    return {"forms": forms, "frames": frames, "canvas": (T, T),
            "meta": tile_meta({"scroll_hint": "swap a/b every 2-3 frames and jump the offset randomly"})}


@ov("C", "ov_bubbles", "Bubbles: pale rings of mixed sizes with small highlights, rising, tiles seamlessly (768).")
def bubbles():
    rng = random.Random(313)
    rings, shines = [], []
    for _ in range(64):
        x, y, s = rng.uniform(0, T), rng.uniform(0, T), rng.uniform(8, 34)
        rings += ringp(x, y, s, s, max(1.2, s * 0.08))
        shines.append(C(x - s * 0.22, y - s * 0.22, s * 0.22, s * 0.16, rot=-40))
    forms = [
        F("fill", None, wrap([C(p["at"][0], p["at"][1], p["size"][0] * 0.9) for p in rings[::2]], margin=4), 0, "flat",
          color="#9ac8e8", opacity=0.08),
        F("rings", None, wrap(rings, margin=4), 1, "flat", color="#cfe6ff", opacity=0.5),
        F("shines", None, wrap(shines, margin=4), 2, "flat", color="#ffffff", opacity=0.7),
    ]
    return {"forms": forms, "canvas": (T, T), "meta": tile_meta({"scroll_hint": "scroll up 30-60 px/s with a slow sway"})}


@ov("C", "ov_sunbeams", "Sunbeams: soft warm shafts slanting down from the upper left, over 2560x1440, low alpha.")
def sunbeams():
    W, H = 2560, 1440
    rng = random.Random(317)
    beams, cores = [], []
    for k in range(7):
        x0 = 160 + k * 300 + rng.uniform(-60, 60)
        w0, w1 = rng.uniform(60, 120), rng.uniform(150, 240)
        dx = 900
        beams.append(poly_abs([(x0, -60), (x0 + w0, -60), (x0 + w0 + dx + w1 / 2, H + 60), (x0 + dx - w1 / 2, H + 60)]))
        if k % 2 == 0:
            m0, m1 = x0 + w0 / 2, x0 + w0 / 2 + dx + w0 / 2
            cores.append(poly_abs([(m0 - w0 * 0.2, -60), (m0 + w0 * 0.2, -60), (m1 + w1 * 0.15, H + 60),
                                   (m1 - w1 * 0.15, H + 60)]))
    forms = [
        F("beams", None, beams, 0, "flat", color="#ffe8b0", blur=40, opacity=0.2),
        F("cores", None, cores, 1, "flat", color="#fff4d8", blur=26, opacity=0.14),
    ]
    return {"forms": forms, "canvas": (W, H),
            "meta": {"kind": "overlay_light", "tileable": False, "blend": "additive or screen, 40-80 % strength"}}


BLUE_RED = [("blue", "#7ab0ff"), ("red", "#ff7a6a")]


@ov("C", "ov_light_circle_color_s", "Light circle, small (192): blue and red.")
def light_cs():
    return light_circle("ov_light_circle_color_s", 192, BLUE_RED)


@ov("C", "ov_light_circle_color_m", "Light circle, medium (384): blue and red.")
def light_cm():
    return light_circle("ov_light_circle_color_m", 384, BLUE_RED)


@ov("C", "ov_light_circle_color_l", "Light circle, large (768): blue and red.")
def light_cl():
    return light_circle("ov_light_circle_color_l", 768, BLUE_RED)


@ov("C", "ov_dust_motes", "Dust motes: small warm specks and a few larger soft blurred ones, drifting, tiles seamlessly (768).")
def dust_motes():
    rng = random.Random(331)
    small = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(2, 4)) for _ in range(120)]
    big = [C(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(8, 16)) for _ in range(18)]
    forms = [
        F("small", None, wrap(small, margin=3), 0, "flat", color="#e6d6b8", blur=0.6, opacity=0.55),
        F("big", None, wrap(big, margin=12), 1, "flat", color="#e6d6b8", blur=4, opacity=0.3),
    ]
    return {"forms": forms, "canvas": (T, T), "meta": tile_meta({"scroll_hint": "drift 5-15 px/s in any direction"})}


# ------------------------------------------------------------------ main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--stage", default="all")
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    n = 0
    for stage, asset, note, fn in OV:
        if args.stage != "all" and stage != args.stage:
            continue
        if only and asset not in only:
            continue
        spec = fn()
        meta = dict(spec.get("meta", {}), stage=stage, list="docs/art/projects/generic/catalog/g01_list.md")
        save(RDIR, asset, spec["forms"], spec["canvas"], "overlay", frames=spec.get("frames"), meta=meta, note=note,
             pivot_meaning="centre of the image")
        n += 1
    print(f"wrote {n} overlay recipes to {RDIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
