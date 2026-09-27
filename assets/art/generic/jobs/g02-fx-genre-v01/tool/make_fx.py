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


# ------------------------------------------------------------------ B
@fx("fx_cp_glitch", "B", "해킹 글리치", "사이버펑크", origin=[96, 96], seed=505, note="centred on the hacked target")
def _():
    F = Frames()
    cx, cy = 96, 96
    plan = [4, 8, 12, 8, 4]
    for k, n in enumerate(plan):
        a = [0.8, 1.0, 1.0, 0.8, 0.5][k]
        bars_m, bars_c = [], []
        for i in range(n):
            s = math.sin(i * 7.31 + k * 3.7)
            c = math.cos(i * 4.17 + k * 1.9)
            w = 18 + abs(s) * (22 + 7 * k)
            h = 3 + abs(c) * (6 if k != 2 else 12)
            x = cx + s * (26 + 5 * k)
            y = cy + c * (36 + 5 * k)
            (bars_m if i % 2 else bars_c).append(P("square", x, y, w, h))
        F.add(k, "bars_m", 1, bars_m, "neon_magenta", opacity=a, emit=1.0, glow=dict(GLOW, color="neon_glow_m", radius=2.5))
        F.add(k, "bars_c", 1.1, bars_c, "neon_cyan", opacity=a, emit=1.0, glow=dict(GLOW, color="neon_glow_c", radius=2.5))
        if k in (1, 2, 3):
            F.add(k, "frame", 2, [P("square", cx + (k - 2) * 6, cy, 70 + 10 * k, 50 + 8 * k), P("square", cx + (k - 2) * 6, cy, 64 + 10 * k,
                                                                                               44 + 8 * k, op="sub")],
                  "neon_cyan", opacity=0.8 - 0.15 * abs(k - 2), emit=1.0)
            F.add(k, "pixels", 3, [P("square", cx - 50 + 25 * i, cy - 30 + ((i * 37 + k * 11) % 60), 6, 6) for i in range(5)],
                  None, color="#f4f0ff", opacity=0.9, emit=1.0)
    return F.forms


@fx("fx_pa_radiation", "B", "방사능 파동", "포스트아포칼립스", origin=[96, 96], seed=506, note="pulse from a contaminated source")
def _():
    F = Frames()
    cx, cy = 96, 96
    for k in range(N):
        for j, r in enumerate((24 + 30 * k, 4 + 30 * k)):
            if r < 10 or r > 176:
                continue
            a = max(0.15, 1.0 - r / 190.0) * (1.0 if j == 0 else 0.6)
            F.add(k, f"ring{j}", 1 + j * 0.1, [P("circle", cx, cy, r, r), P("circle", cx, cy, r - 7, r - 7, op="sub")], "rad_green",
                  opacity=a, emit=1.0, glow=dict(GLOW, color="rad_glow"))
        F.add(k, "core", 2, [P("circle", cx, cy, 30 - 4 * k, 30 - 4 * k)], "rad_green", opacity=0.9 - 0.15 * k, emit=1.0,
              glow=dict(GLOW, color="rad_glow", radius=6))
        pts = ring_pts(cx, cy, 30 + 14 * k, 6, a0=k * 23, jitter=14, seed=6)
        F.add(k, "motes", 3, [P("circle", x, y - 6 * k, 5, 5) for x, y, _ in pts], "neon_green", opacity=0.9 - 0.15 * k, emit=1.0)
    return F.forms


@fx("fx_pi_cannon_smoke", "B", "대포 연기", "해적·바다", origin=[20, 110], seed=507, note="cannon mouth at the left, blast toward +x")
def _():
    F = Frames()
    ox, oy = 20, 110
    for k in range(N):
        if k <= 1:
            F.add(k, "flash", 2, [P("star", ox + 24 + 10 * k, oy, 50 + 20 * k, 60 + 24 * k, rot=90)], "flame", opacity=1.0 - 0.3 * k, emit=1.0,
                  glow=dict(GLOW, color="flame_glow"))
            F.add(k, "core", 2.1, [P("circle", ox + 18 + 8 * k, oy, 26, 22)], None, color="#fff2c8", opacity=1.0 - 0.4 * k, emit=1.0)
        g = [0.3, 0.55, 0.8, 1.0, 1.1][k]
        a = [0.8, 0.9, 0.85, 0.7, 0.45][k]
        puffs = [P("cloud", ox + 40 + 60 * g, oy - 4 - 10 * g, 50 + 40 * g, 36 + 28 * g),
                 P("cloud", ox + 30 + 36 * g, oy + 16 * g, 40 + 30 * g, 30 + 22 * g),
                 P("cloud", ox + 50 + 70 * g, oy - 26 * g, 32 + 28 * g, 26 + 20 * g)]
        F.add(k, "smoke", 1, puffs, "ash", kind="mass", opacity=a, line={"width": 0.8, "heavy": 0.7})
        if k in (1, 2, 3):
            F.add(k, "embers", 3, [P("circle", ox + 60 + 30 * k, oy - 30 - 6 * k, 4, 4), P("circle", ox + 90 + 24 * k, oy + 20, 3, 3)],
                  "ember", opacity=1.0 - 0.25 * k, emit=1.0)
    return F.forms


@fx("fx_we_dust", "B", "흙먼지", "서부", origin=[96, 170], seed=508, note="kicked up at ground level")
def _():
    F = Frames()
    cx, base = 96, 170
    for k in range(N):
        g = [0.35, 0.65, 0.9, 1.0, 1.05][k]
        a = [0.85, 0.85, 0.75, 0.55, 0.3][k]
        puffs = [P("cloud", cx, base - 14 * g, 70 * g + 20, 36 * g + 14),
                 P("cloud", cx - 48 * g, base - 8 * g, 46 * g + 14, 26 * g + 10),
                 P("cloud", cx + 50 * g, base - 10 * g, 50 * g + 14, 28 * g + 10)]
        F.add(k, "dust", 1, puffs, "cloth_tan", kind="mass", opacity=a, line={"width": 0.8, "heavy": 0.6},
              shade={"threshold": 0.45, "highlight_amount": 0.4})
        if k <= 3:
            F.add(k, "pebbles", 2, [P("rocks", cx - 60 * g, base - 30 * g - 10, 9, 8), P("rocks", cx + 64 * g, base - 36 * g - 8, 8, 7),
                                    P("rocks", cx + 20, base - 50 * g - 6, 7, 6)], "stone", kind="mass", opacity=1.0 - 0.2 * k)
    return F.forms


# ------------------------------------------------------------------ C
@fx("fx_ho_wail", "C", "비명 파동", "호러·오컬트", origin=[96, 96], seed=509, note="distorted rings from the screamer's head")
def _():
    F = Frames()
    cx, cy = 96, 96
    for k in range(N):
        for j in range(3):
            r = 16 + 29 * k - 20 * j
            if r < 12 or r > 172:
                continue
            a = max(0.2, 0.95 - r / 200.0)
            F.add(k, f"ring{j}", 1 + 0.1 * j, [P("circle", cx, cy, r * 1.1, r * 0.82, rot=(k * 17 + j * 40) % 90),
                                                P("circle", cx, cy, r * 1.1 - 7, r * 0.82 - 6, rot=(k * 17 + j * 40) % 90, op="sub")],
                  None, color="#c9b6d6", opacity=a, emit=0.6, glow=dict(GLOW, color="#8f6aa8", radius=3))
        if k <= 2:
            F.add(k, "mouth", 2, [P("circle", cx, cy, 22 - 5 * k, 30 - 6 * k)], None, color="#1a1020", opacity=0.9 - 0.2 * k)
    return F.forms


@fx("fx_sf_plasma_burst", "C", "플라스마 폭발", "SF·우주", origin=[96, 96], seed=510, note="centred plasma detonation")
def _():
    F = Frames()
    cx, cy = 96, 96
    for k in range(N):
        s = [0.35, 0.8, 1.0, 0.9, 0.6][k]
        a = [1.0, 1.0, 0.85, 0.6, 0.3][k]
        F.add(k, "ball", 1, [P("circle", cx, cy, 120 * s, 120 * s)], "plasma", opacity=a * 0.8, emit=1.0,
              glow=dict(GLOW, color="plasma_glow", radius=6))
        F.add(k, "core", 2, [P("circle", cx, cy, 60 * s, 60 * s)], None, color="#eef7ff", opacity=a, emit=1.0)
        if k >= 1:
            F.add(k, "arcs", 3, [P("lightning_bolt", cx + 40 * s * math.cos(t), cy + 40 * s * math.sin(t), 16, 40 * s,
                                   rot=math.degrees(t) + 90) for t in (0.4 + k, 2.5 + k, 4.4 + k)],
                  "neon_cyan", opacity=a, emit=1.0)
        if k >= 2:
            F.add(k, "shell", 0.5, [P("circle", cx, cy, 150 * s + 20, 150 * s + 20), P("circle", cx, cy, 150 * s + 12, 150 * s + 12, op="sub")],
                  "plasma", opacity=a * 0.6, emit=1.0)
    return F.forms


@fx("fx_pa_shrapnel", "C", "고철 파편 튀김", "포스트아포칼립스", origin=[96, 96], seed=511, note="junk bomb burst, scrap flies outward")
def _():
    F = Frames()
    cx, cy = 96, 96
    shapes = ["nut_and_bolt", "screw", "cog", "triangle", "square", "hexagon"]
    for k in range(N):
        d = [8, 30, 52, 68, 78][k]
        a = [1.0, 1.0, 1.0, 0.8, 0.5][k]
        if k <= 1:
            F.add(k, "flash", 1, [P("star", cx, cy, 64 + 30 * k, 64 + 30 * k, rot=k * 20), P("star", cx, cy, 44 + 20 * k, 44 + 20 * k, rot=36 + k * 20)], "flame", opacity=1.0 - 0.3 * k, emit=1.0,
                  glow=dict(GLOW, color="flame_glow"))
        pts = ring_pts(cx, cy, d, 8, a0=12, jitter=14, seed=11)
        F.add(k, "scrap", 2, [P(shapes[i % len(shapes)], x, y + k * k * 1.5, 12, 12, rot=k * 50 + i * 33) for i, (x, y, _) in enumerate(pts)],
              "iron", kind="mass", opacity=a, line={"width": 0.8, "heavy": 0.6})
        if k >= 2:
            F.add(k, "smoke", 0, [P("cloud", cx, cy + 10, 60 + 20 * k, 40 + 12 * k)], "ash", kind="mass", opacity=0.7 - 0.12 * k)
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
