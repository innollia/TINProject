"""Write g02 genre effect recipes (192x192 cells, 5 frames) into ../recipes/.

    py -3 -B make_fx.py [--only id] [--tier A] [--build]

Each frame shows its own forms (tag f0..f4), so shapes can grow, split and fade
freely.  Bright parts carry ``emit`` and also land in <frame>_emit.png for an
additive game layer.  fx_sheet.py packs the frames into one 960x192 row.
"""

from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
FX = {}
N = 5


def P(icon, x, y, w, h=None, **kw):
    p = {"icon": icon, "at": [round(float(x), 2), round(float(y), 2)], "size": [w, h] if h is not None else w}
    p.update(kw)
    return p


def fx(fid, tier, name, genre, origin, seed=1, note=""):
    def deco(fn):
        FX[fid] = {"tier": tier, "name": name, "genre": genre, "origin": origin, "seed": seed, "fn": fn, "note": note}
        return fn
    return deco


class Frames:
    def __init__(self):
        self.forms = []

    def add(self, k, name, z, pieces, mat=None, **kw):
        f = {"name": f"{name}_f{k}", "z": z + k * 0.001, "tags": [f"f{k}"], "hidden": True, "pieces": pieces, "kind": kw.pop("kind", "flat")}
        if mat:
            f["material"] = mat
        f.update(kw)
        self.forms.append(f)


GLOW = {"radius": 4, "opacity": 0.6}


def ring_pts(cx, cy, r, n, a0=0.0, jitter=0.0, seed=1):
    out = []
    for i in range(n):
        a = math.radians(a0 + 360.0 * i / n + (math.sin(i * 12.9898 + seed) * jitter))
        out.append((cx + r * math.cos(a), cy + r * math.sin(a), math.degrees(a)))
    return out


# ------------------------------------------------------------------ A
@fx("fx_mo_muzzle_flash", "A", "총구 섬광", "현대·도시", origin=[34, 96], seed=501, note="muzzle at the left middle, shot toward +x")
def _():
    F = Frames()
    ox, oy = 34, 96
    flash = [(0.55, 1.0), (1.0, 1.0), (0.7, 0.75), (0.35, 0.45), (0.0, 0.0)]
    for k, (s, a) in enumerate(flash):
        if s > 0:
            F.add(k, "cone", 1, [P("droplet", ox + 46 * s, oy, 34 * s + 6, 96 * s + 8, rot=90)], "flame", opacity=a, emit=1.0,
                  glow=dict(GLOW, color="flame_glow"))
            F.add(k, "burst", 2, [P("star", ox + 20 * s, oy, 58 * s + 8, 46 * s + 6, rot=90)], "flame", opacity=a, emit=1.0)
            F.add(k, "core", 3, [P("circle", ox + 12 * s, oy, 26 * s + 4, 18 * s + 4)], None, color="#fff2c8", opacity=a, emit=1.0)
        if k >= 2:
            g = (k - 1) / 3.0
            F.add(k, "smoke", 0, [P("cloud", ox + 30 + 40 * g, oy - 6 - 20 * g, 40 + 40 * g, 28 + 26 * g),
                                   P("cloud", ox + 60 + 50 * g, oy - 14 - 28 * g, 30 + 30 * g, 22 + 20 * g)],
                  "ash", kind="mass", opacity=0.75 - 0.18 * k, line={"width": 0.8, "heavy": 0.6})
        if k in (1, 2, 3):
            pts = [(ox + 40 + 30 * k, oy - 26 - 8 * k), (ox + 52 + 26 * k, oy + 22 + 8 * k), (ox + 70 + 30 * k, oy - 4)]
            F.add(k, "spark", 4, [P("circle", x, y, 5 - k, 5 - k) for x, y in pts], "ember", opacity=1.0 - 0.2 * k, emit=1.0)
    return F.forms


@fx("fx_ho_possession", "A", "빙의 검은 연기", "호러·오컬트", origin=[96, 176], seed=502, note="rises from the target's feet")
def _():
    F = Frames()
    cx, base = 96, 176
    for k in range(N):
        h = [0.35, 0.65, 0.9, 1.0, 0.85][k]
        a = [0.7, 0.85, 0.9, 0.85, 0.45][k]
        wisps = []
        for i, dx in enumerate((-40, -14, 14, 40)):
            ww = 30 - abs(dx) * 0.25
            wisps.append(P("droplet", cx + dx * (0.7 + 0.3 * h), base - 40 * h - (i % 2) * 18 * h, ww, 70 * h + 20,
                           rot=(dx * 0.35) + (k - 2) * 6 * (1 if i % 2 else -1)))
        F.add(k, "wisps", 1, wisps, None, color="#1a1020", kind="mass", opacity=a, line={"width": 0.9, "heavy": 0.8},
              rough={"amp": 0.5, "soft": 2.0, "cell": 10})
        F.add(k, "pool", 0, [P("cloud", cx, base - 6, 120 * (0.6 + 0.4 * h), 30)], None, color="#221428", opacity=a * 0.8)
        if k >= 1:
            F.add(k, "swirl", 2, [P("spiral", cx + (k - 2) * 6, base - 70 * h - 10, 44 * h + 10, 44 * h + 10, rot=k * 40)],
                  None, color="#3a1f40", opacity=a * 0.8)
        if k in (2, 3, 4):
            pts = ring_pts(cx, base - 80 * h, 34 + 10 * k, 4, a0=k * 35, seed=k)
            F.add(k, "glints", 3, [P("diamond", x, y, 5, 9) for x, y, _ in pts], "ember_red", opacity=1.0 - 0.25 * (k - 2), emit=1.0,
                  glow=dict(GLOW, color="ember_red_glow", radius=3))
    return F.forms


@fx("fx_sf_laser_hit", "A", "레이저 적중", "SF·우주", origin=[96, 96], seed=503, note="impact at the centre, beam from the left")
def _():
    F = Frames()
    cx, cy = 96, 96
    for k in range(N):
        if k <= 1:
            F.add(k, "beam", 1, [P("square", cx / 2.0 - 2, cy, cx + 4, 7 - k * 2)], "neon_cyan", opacity=1.0, emit=1.0,
                  glow=dict(GLOW, color="neon_glow_c"))
            F.add(k, "beam_core", 1.1, [P("square", cx / 2.0 - 2, cy, cx + 4, 2.4)], None, color="#e8feff", emit=1.0)
        r = [16, 44, 70, 86, 94][k]
        a = [1.0, 1.0, 0.8, 0.5, 0.25][k]
        F.add(k, "ring", 2, [P("circle", cx, cy, r, r), P("circle", cx, cy, r - 6 - k * 2, r - 6 - k * 2, op="sub")],
              "neon_cyan", opacity=a, emit=1.0, glow=dict(GLOW, color="neon_glow_c"))
        if k <= 2:
            F.add(k, "flash", 3, [P("star", cx, cy, 40 - k * 8, 40 - k * 8, rot=k * 18)], None, color="#e8feff", opacity=1.0 - 0.25 * k,
                  emit=1.0)
        if k >= 1:
            pts = ring_pts(cx, cy, 20 + 16 * k, 7, a0=10 + k * 7, jitter=10, seed=3)
            F.add(k, "sparks", 4, [P("square", x, y, 3, 12 - k, rot=ang + 90) for x, y, ang in pts], "plasma", opacity=1.0 - 0.2 * k,
                  emit=1.0)
    return F.forms


@fx("fx_sp_steam_burst", "A", "증기 분출", "스팀펑크", origin=[26, 170], seed=504, note="vent at the lower left, jet toward the upper right")
def _():
    F = Frames()
    ox, oy = 26, 170
    for k in range(N):
        a = [0.85, 0.9, 0.85, 0.65, 0.35][k]
        puffs = []
        n = [2, 4, 5, 5, 4][k]
        for i in range(n):
            t = (i + 0.5) / 5.0 * [0.4, 0.8, 1.0, 1.1, 1.2][k]
            s = 16 + 44 * t + 8 * k
            puffs.append(P("cloud", ox + 96 * t, oy - 96 * t - (i % 2) * 8, s, s * 0.72, rot=(i % 3 - 1) * 12))
        F.add(k, "steam", 1, puffs, "fur_white", kind="mass", opacity=a, line={"width": 0.8, "heavy": 0.7},
              shade={"threshold": 0.4, "highlight_amount": 0.5})
        if k <= 2:
            F.add(k, "jet", 0.5, [P("droplet", ox + 18 + 10 * k, oy - 18 - 10 * k, 12 + 4 * k, 44 + 20 * k, rot=45)], "cloth_white",
                  kind="mass", opacity=0.9)
        if k in (2, 3):
            pts = [(ox + 50 + 16 * k, oy - 16), (ox + 20, oy - 60 - 8 * k), (ox + 92, oy - 52)]
            F.add(k, "drops", 2, [P("droplet", x, y, 5, 8) for x, y in pts], "lens", kind="mass", opacity=0.8)
    return F.forms


# ------------------------------------------------------------------ output
def recipe(fid, meta):
    return {"asset": fid, "status": "candidate",
            "note": f"{meta['name']} ({meta['genre']}, tier {meta['tier']}). 5-frame effect, 192x192 cells. {meta['note']}",
            "palette": "palette_g02.json", "style": "sprite",
            "style_override": {"silhouette": {"opacity": 0.0}, "cast": {"opacity": 0.0}},
            "canvas": [192, 192], "pivot": meta["origin"], "pivot_meaning": "effect origin",
            "seed": meta["seed"], "forms": meta["fn"](),
            "frames": [{"name": f"f{k}", "show": [f"f{k}"]} for k in range(N)]}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", default="")
    ap.add_argument("--tier", default="")
    ap.add_argument("--build", action="store_true")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    written = []
    for fid, meta in FX.items():
        if (only and fid not in only) or (args.tier and meta["tier"] not in args.tier):
            continue
        path = JOB / "recipes" / f"{fid}.json"
        path.write_text(json.dumps(recipe(fid, meta), ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        written.append(path)
    print(f"wrote {len(written)} fx recipes")
    if args.build and written:
        rc = subprocess.call([sys.executable, "-B", str(Path(__file__).with_name("build.py")), *map(str, written)])
        if rc:
            return rc
        return subprocess.call([sys.executable, "-B", str(Path(__file__).with_name("fx_sheet.py")), *[p.stem for p in written]])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
