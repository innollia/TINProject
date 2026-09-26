"""Write g02 genre item icon recipes (128x128, flat view) into ../recipes/.

    py -3 -B make_icons.py [--only id,id] [--tier A] [--build]

Icons are authored level (weapons pointing right) and then turned as a whole
by ``rot`` around the centre, so every part stays registered.
"""

from __future__ import annotations

import argparse
import copy
import json
import math
import subprocess
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
ICONS = {}


def P(icon, x, y, w, h=None, **kw):
    p = {"icon": icon, "at": [float(x), float(y)], "size": [w, h] if h is not None else w}
    p.update(kw)
    return p


def F(name, z, pieces, mat=None, **kw):
    f = {"name": name, "z": z, "pieces": pieces}
    if mat:
        f["material"] = mat
    f.update(kw)
    return f


def icon(iid, tier, name, genre, rot=0.0, seed=1):
    def deco(fn):
        ICONS[iid] = {"tier": tier, "name": name, "genre": genre, "rot": rot, "seed": seed, "fn": fn}
        return fn
    return deco


def rot_all(forms, deg, c=(64.0, 64.0)):
    r = math.radians(deg)
    cs, sn = math.cos(r), math.sin(r)

    def pt(p):
        x, y = p[0] - c[0], p[1] - c[1]
        return [round(c[0] + x * cs - y * sn, 2), round(c[1] + x * sn + y * cs, 2)]

    out = copy.deepcopy(forms)
    for f in out:
        for p in f["pieces"]:
            p["at"] = pt(p["at"])
            p["rot"] = round(p.get("rot", 0.0) + deg, 2)
            rep = p.get("repeat")
            if rep and "step" in rep:
                sx, sy = rep["step"]
                rep["step"] = [round(sx * cs - sy * sn, 3), round(sx * sn + sy * cs, 3)]
            if rep and "ellipse" in rep:
                rep["ellipse"][:2] = pt(rep["ellipse"][:2])
    return out


SEAM = {"kind": "flat", "color": "coat_seam"}
GLOW = {"radius": 3, "opacity": 0.55}


def glint(x, y, w, h, clip, rot=-30, op=0.35):
    return F(f"glint_{clip}", 20, [P("moon", x, y, w, h, rot=rot)], None, kind="flat", color="white_ink", opacity=op, clip_to=clip)


# ------------------------------------------------------------------ A
@icon("icon_mo_pistol", "A", "권총", "현대·도시", rot=-22, seed=301)
def _():
    return [F("grip", 0, [P("square", 40, 84, 24, 42, rot=12)], "rubber"),
            F("frame", 1, [P("square", 60, 64, 66, 13)], "iron_dark"),
            F("guard", 1.5, [P("circle", 62, 75, 24, 19), P("circle", 62, 75, 15, 11, op="sub")], "iron_dark"),
            F("trigger", 1.6, [P("square", 60, 73, 3, 9, rot=10)], "iron_dark"),
            F("slide", 2, [P("square", 68, 50, 86, 21)], "steel"),
            F("port", 2.5, [P("square", 76, 46, 14, 5)], None, **SEAM),
            F("serration", 2.5, [P("square", 33, 50, 2.2, 15, repeat={"grid": [4, 1], "step": [5, 0]})], None, **SEAM),
            F("sight", 2.2, [P("square", 105, 38, 5, 5), P("square", 32, 38, 7, 5)], "iron_dark")]


@icon("icon_mo_smartphone", "A", "스마트폰", "현대·도시", rot=12, seed=302)
def _():
    return [F("body", 0, [P("square", 64, 64, 56, 100)], "iron_dark"),
            F("button", -0.5, [P("square", 94, 42, 5, 14)], "iron"),
            F("screen", 1, [P("square", 64, 62, 46, 82)], "visor", shade={"bump": 0.2}),
            F("screen_glow", 1.2, [P("square", 64, 70, 40, 50)], "neon_cyan", kind="flat", opacity=0.22, emit=0.5, clip_to="screen"),
            F("crack", 1.4, [P("lightning_bolt", 78, 84, 16, 36, rot=24), P("lightning_bolt", 70, 98, 10, 20, rot=-40)], None,
              kind="flat", color="white_ink", opacity=0.5, clip_to="screen"),
            glint(50, 40, 20, 42, "screen"),
            F("camera", 1.5, [P("circle", 64, 20, 6, 6)], "void", kind="flat")]


@icon("icon_ho_planchette", "A", "위자 플랑셰트", "호러·오컬트", rot=-12, seed=303)
def _():
    return [F("board", 0, [P("heart", 64, 60, 92, 88, flip="y")], "wood"),
            F("inlay", 0.5, [P("heart", 64, 62, 72, 68, flip="y"), P("heart", 64, 62, 64, 60, flip="y", op="sub")], "bone",
              kind="flat", opacity=0.55, clip_to="board"),
            F("marks", 0.6, [P("moon", 40, 72, 10, 10), P("star", 88, 72, 10, 10)], "bone", kind="flat", opacity=0.6),
            F("rim", 1, [P("circle", 64, 52, 36, 36), P("circle", 64, 52, 26, 26, op="sub")], "brass"),
            F("lens", 0.8, [P("circle", 64, 52, 27, 27)], "lens", opacity=0.85),
            glint(58, 46, 10, 16, "lens")]


@icon("icon_sf_ray_gun", "A", "광선총", "SF·우주", rot=-18, seed=304)
def _():
    return [F("grip", 0, [P("square", 40, 86, 20, 38, rot=14)], "iron_dark"),
            F("fin", 0.5, [P("triangle", 42, 36, 24, 20, rot=-10)], "cloth_red"),
            F("body", 1, [P("circle", 48, 60, 52, 36)], "chrome"),
            F("barrel", 1.2, [P("square", 82, 58, 48, 13)], "chrome"),
            F("rings", 1.4, [P("square", 74, 58, 5, 21, repeat={"grid": [3, 1], "step": [11, 0]})], "iron_dark"),
            F("window", 1.5, [P("circle", 46, 60, 16, 14)], "neon_green", kind="flat", emit=0.8, glow=dict(GLOW, color="rad_glow")),
            F("emitter", 1.6, [P("circle", 110, 58, 18, 18)], "iron_dark"),
            F("core", 1.7, [P("circle", 111, 58, 10, 10)], "neon_cyan", kind="flat", emit=1.0, glow=dict(GLOW, color="neon_glow_c"))]


@icon("icon_cp_cyberdeck", "A", "사이버덱", "사이버펑크", rot=-6, seed=305)
def _():
    return [F("cable", -1, [P("square", 108, 36, 4, 44, rot=-34), P("square", 118, 18, 9, 12, rot=-34)], "rubber"),
            F("base", 0, [P("square", 64, 76, 104, 44)], "iron_dark", kind="block", extrude=7),
            F("keys", 1, [P("square", 22, 68, 7, 5, repeat={"grid": [9, 3], "step": [10.4, 8]})], "chrome", kind="flat", opacity=0.9),
            F("strip", 1.2, [P("square", 64, 94, 92, 3)], "neon_magenta", kind="flat", emit=1.0, glow=dict(GLOW, color="neon_glow_m")),
            F("screen", 2, [P("square", 64, 34, 76, 34)], "iron_dark"),
            F("display", 2.2, [P("square", 64, 34, 66, 24)], "neon_cyan", kind="flat", emit=0.7, opacity=0.8),
            F("scan", 2.4, [P("square", 64, 26, 64, 2, repeat={"grid": [1, 4], "step": [0, 5]})], "iron_dark", kind="flat", opacity=0.5,
              clip_to="display")]


@icon("icon_sp_pocket_watch", "A", "톱니 회중시계", "스팀펑크", rot=8, seed=306)
def _():
    return [F("loop", 0, [P("circle", 64, 16, 22, 18), P("circle", 64, 16, 13, 9, op="sub")], "brass"),
            F("crown", 0.5, [P("square", 64, 29, 12, 12)], "brass"),
            F("case", 1, [P("circle", 64, 72, 92, 92)], "brass", shade={"highlight_amount": 0.8}),
            F("dial", 2, [P("circle", 64, 72, 74, 74)], "paper"),
            F("gear_a", 2.5, [P("cog", 50, 82, 36, 36)], "bronze", clip_to="dial"),
            F("gear_b", 2.6, [P("cog", 80, 62, 26, 26)], "brass", clip_to="dial"),
            F("ticks", 3, [P("square", 64, 40, 2.4, 6, repeat={"ellipse": [64, 72, 32, 32], "count": 12, "orient": True, "phase": -90})],
              "iron_dark", kind="flat"),
            F("hands", 3.2, [P("square", 64, 60, 3, 26), P("square", 72, 70, 3, 18, rot=62), P("circle", 64, 72, 7, 7)], "iron_dark"),
            glint(48, 54, 18, 36, "dial", op=0.3)]


@icon("icon_pa_gas_mask", "A", "방독면", "포스트아포칼립스", rot=0, seed=307)
def _():
    return [F("strap", -1, [P("square", 16, 46, 22, 7, rot=-24), P("square", 112, 46, 22, 7, rot=24)], "rubber"),
            F("mask", 0, [P("circle", 64, 56, 86, 78), P("square", 64, 84, 52, 42)], "rubber"),
            F("rims", 1, [P("circle", 44, 52, 32, 30), P("circle", 84, 52, 32, 30)], "iron"),
            F("lens_l", 1.2, [P("circle", 44, 52, 22, 20)], "lens"),
            F("lens_r", 1.2, [P("circle", 84, 52, 22, 20)], "lens"),
            glint(40, 48, 8, 14, "lens_l"), glint(80, 48, 8, 14, "lens_r"),
            F("filter", 2, [P("cylinder", 64, 102, 36, 30)], "iron"),
            F("ribs", 2.2, [P("square", 64, 98, 30, 2.4, repeat={"grid": [1, 3], "step": [0, 6]})], None, **SEAM)]


@icon("icon_pi_flintlock", "A", "부싯돌 권총", "해적·바다", rot=-20, seed=308)
def _():
    return [F("stock", 0, [P("flintlock", 58, 66, 104, 104, crop=[0.5, 5.5, 10.5, 15.8], fit="box"), P("square", 70, 58, 50, 12)], "wood"),
            F("barrel", 1, [P("square", 88, 50, 58, 11), P("square", 117, 50, 7, 16)], "iron"),
            F("bands", 1.2, [P("square", 76, 52, 4, 16), P("square", 98, 52, 4, 16)], "brass"),
            F("lock", 1.4, [P("square", 50, 56, 22, 11)], "brass"),
            F("hammer", 1.6, [P("moon", 42, 44, 13, 15, rot=200)], "iron_dark"),
            F("guard", 1.5, [P("circle", 52, 72, 18, 14), P("circle", 52, 72, 11, 8, op="sub")], "brass"),
            F("cap", 1.6, [P("circle", 20, 97, 17, 15)], "brass")]


@icon("icon_we_revolver", "A", "리볼버", "서부", rot=-20, seed=309)
def _():
    return [F("grip", 0, [P("square", 36, 82, 20, 40, rot=22)], "wood"),
            F("frame", 1, [P("square", 56, 58, 42, 16)], "iron"),
            F("guard", 1.2, [P("circle", 58, 70, 20, 16), P("circle", 58, 70, 12, 9, op="sub")], "iron"),
            F("barrel", 1.5, [P("square", 88, 48, 58, 10)], "steel"),
            F("rod", 1.4, [P("square", 86, 56, 44, 4)], "steel"),
            F("cylinder", 2, [P("square", 56, 52, 28, 24)], "steel"),
            F("flutes", 2.2, [P("square", 50, 52, 3, 20), P("square", 62, 52, 3, 20)], None, **SEAM),
            F("hammer", 1.8, [P("triangle", 38, 42, 12, 14, rot=-30)], "iron_dark"),
            F("screw", 2.4, [P("circle", 36, 80, 5, 5)], "brass", kind="flat"),
            F("sight", 1.6, [P("square", 114, 42, 4, 5)], "steel")]


@icon("icon_we_sheriff_star", "A", "보안관 별 배지", "서부", rot=0, seed=310)
def _():
    return [F("star", 0, [P("star", 64, 68, 104, 100)], "gold", shade={"highlight_amount": 0.8}),
            F("tips", 0.5, [P("circle", 64, 18, 12, 12, repeat={"ellipse": [64, 70, 50, 49], "count": 5, "phase": -90})], "gold"),
            F("inner", 1, [P("star", 64, 69, 62, 60)], "bronze", kind="flat", opacity=0.55),
            F("disc", 1.5, [P("circle", 64, 70, 30, 30)], "gold"),
            F("ring", 1.7, [P("circle", 64, 70, 24, 24), P("circle", 64, 70, 19, 19, op="sub")], "bronze", kind="flat")]



# ------------------------------------------------------------------ output
def recipe(iid, meta):
    forms = meta["fn"]()
    if meta["rot"]:
        forms = rot_all(forms, meta["rot"])
    return {"asset": iid, "status": "candidate",
            "note": f"{meta['name']} ({meta['genre']}, tier {meta['tier']}). Handheld item icon, flat view, no text.",
            "palette": "palette_g02.json", "style": "prop", "canvas": [128, 128], "pivot": [64, 64],
            "pivot_meaning": "icon centre", "seed": meta["seed"], "forms": forms}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", default="")
    ap.add_argument("--tier", default="")
    ap.add_argument("--build", action="store_true")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    written = []
    for iid, meta in ICONS.items():
        if (only and iid not in only) or (args.tier and meta["tier"] not in args.tier):
            continue
        path = JOB / "recipes" / f"{iid}.json"
        path.write_text(json.dumps(recipe(iid, meta), ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        written.append(path)
    print(f"wrote {len(written)} icon recipes")
    if args.build and written:
        return subprocess.call([sys.executable, "-B", str(Path(__file__).with_name("build.py")), *map(str, written)])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
