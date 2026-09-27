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



# ------------------------------------------------------------------ B
def shield_whole(cx, cy, w, h):
    half = P("shield", cx - w / 4.0 + 0.8, cy, w / 2.0 + 1.6, h, half="left", crop=[1, 0.8, 8, 15.2])
    return [half, dict(half, at=[round(2 * cx - half["at"][0], 2), half["at"][1]], flip="x")]


@icon("icon_mo_police_badge", "B", "경찰 배지", "현대·도시", rot=-6, seed=311)
def _():
    return [F("wallet", -1, [P("square", 64, 70, 84, 100)], "leather_dark"),
            F("wallet_fold", -0.5, [P("square", 64, 22, 84, 4)], None, **SEAM),
            F("shield", 0, shield_whole(64, 68, 64, 76), "gold", shade={"highlight_amount": 0.8}),
            F("inner", 0.5, shield_whole(64, 66, 48, 58), "bronze", kind="flat", opacity=0.6),
            F("star", 1, [P("star", 64, 64, 28, 28)], "gold"),
            F("ribbon", 1.2, [P("square", 64, 92, 44, 9)], "cloth_navy")]


@icon("icon_ho_camcorder", "B", "심령 캠코더", "호러·오컬트", rot=-8, seed=312)
def _():
    return [F("strap", -1, [P("square", 60, 88, 60, 10)], "rubber"),
            F("body", 0, [P("square", 58, 64, 72, 44)], "iron_dark", kind="block", extrude=6),
            F("lens_tube", 1, [P("square", 104, 62, 24, 30)], "iron_dark"),
            F("lens", 1.2, [P("circle", 112, 62, 18, 26)], "lens"),
            glint(110, 56, 6, 12, "lens"),
            F("screen_arm", 1.5, [P("square", 24, 60, 18, 36)], "iron"),
            F("screen", 1.6, [P("square", 24, 60, 12, 28)], "rad_green", kind="flat", emit=0.5, opacity=0.75),
            F("rec", 2, [P("circle", 78, 50, 7, 7)], "ember_red", kind="flat", emit=1.0, glow=dict(GLOW, color="ember_red_glow"))]


@icon("icon_ho_emf", "B", "유령 탐지기(EMF)", "호러·오컬트", rot=10, seed=313)
def _():
    leds = ["rad_green", "rad_green", "neon_amber", "neon_amber", "ember_red"]
    return [F("antenna", -1, [P("square", 64, 18, 5, 26), P("circle", 64, 6, 8, 8)], "chrome"),
            F("body", 0, [P("square", 64, 70, 54, 92)], "cloth_black"),
            F("face", 1, [P("square", 64, 50, 42, 34)], "iron_dark"),
            *[F(f"led{i}", 2, [P("circle", 46 + i * 9, 50 - (2 - abs(i - 2)) * 3, 7, 7)], c, kind="flat", emit=1.0 if i < 3 else 0.3,
                opacity=1.0 if i < 3 else 0.5) for i, c in enumerate(leds)],
            F("grip", 1, [P("square", 64, 96, 40, 26)], "rubber"),
            F("ribs", 1.2, [P("square", 64, 92, 32, 2.4, repeat={"grid": [1, 3], "step": [0, 6]})], None, **SEAM)]


@icon("icon_sf_energy_cell", "B", "에너지 셀", "SF·우주", rot=-30, seed=314)
def _():
    return [F("cap_a", 0, [P("square", 64, 20, 40, 18)], "chrome"),
            F("cap_b", 0, [P("square", 64, 108, 40, 18)], "chrome"),
            F("glass", 1, [P("square", 64, 64, 34, 76)], "visor", opacity=0.85),
            F("core", 1.5, [P("square", 64, 64, 16, 62)], "plasma", kind="flat", emit=1.0, glow=dict(GLOW, color="plasma_glow")),
            F("bands", 2, [P("square", 64, 44, 38, 5), P("square", 64, 84, 38, 5)], "iron_dark"),
            F("pin", 0.5, [P("square", 64, 8, 12, 8)], "gold"),
            glint(54, 54, 8, 30, "glass", rot=0)]


@icon("icon_sf_scanner", "B", "휴대 스캐너", "SF·우주", rot=-12, seed=315)
def _():
    return [F("antenna", -1, [P("square", 88, 16, 4, 26), P("circle", 88, 5, 7, 7)], "chrome"),
            F("body", 0, [P("square", 64, 58, 70, 64)], "cloth_white", shade={"bump": 0.5}),
            F("screen", 1, [P("square", 64, 52, 54, 42)], "iron_dark"),
            F("radar", 1.5, [P("circle", 64, 52, 36, 36), P("circle", 64, 52, 32, 32, op="sub"), P("circle", 64, 52, 18, 18),
                             P("circle", 64, 52, 15, 15, op="sub")], "neon_cyan", kind="flat", emit=0.8, opacity=0.8, clip_to="screen"),
            F("blip", 1.7, [P("circle", 74, 44, 6, 6)], "neon_amber", kind="flat", emit=1.0),
            F("grip", 0.5, [P("square", 64, 104, 30, 42)], "rubber"),
            F("keys", 1.2, [P("circle", 50, 82, 7, 7), P("circle", 64, 82, 7, 7), P("circle", 78, 82, 7, 7)], "iron_dark")]


@icon("icon_cp_neural_chip", "B", "신경 칩", "사이버펑크", rot=20, seed=316)
def _():
    return [F("pins", -1, [P("square", 40, 38, 5, 16, repeat={"grid": [5, 1], "step": [12, 0]}),
                           P("square", 40, 90, 5, 16, repeat={"grid": [5, 1], "step": [12, 0]})], "gold"),
            F("chip", 0, [P("square", 64, 64, 70, 56)], "iron_dark", kind="block", extrude=5),
            F("die", 1, [P("square", 64, 62, 38, 30)], "chrome"),
            F("trace", 1.5, [P("square", 50, 62, 3, 22), P("square", 64, 56, 28, 3), P("square", 78, 66, 3, 18)],
              "neon_magenta", kind="flat", emit=1.0, glow=dict(GLOW, color="neon_glow_m")),
            F("dot", 1.6, [P("circle", 64, 70, 7, 7)], "neon_cyan", kind="flat", emit=1.0)]


@icon("icon_sp_goggles", "B", "황동 고글", "스팀펑크", rot=-8, seed=317)
def _():
    return [F("strap", -1, [P("square", 64, 70, 124, 16)], "leather_dark"),
            F("rims", 0, [P("circle", 38, 66, 46, 46), P("circle", 90, 66, 46, 46)], "brass", shade={"highlight_amount": 0.8}),
            F("bridge", 0.5, [P("square", 64, 62, 20, 8)], "bronze"),
            F("lens_l", 1, [P("circle", 38, 66, 32, 32)], "lens"),
            F("lens_r", 1, [P("circle", 90, 66, 32, 32)], "lens"),
            glint(32, 58, 10, 18, "lens_l"), glint(84, 58, 10, 18, "lens_r"),
            F("rivets", 1.5, [P("circle", 38, 44, 4, 4, repeat={"ellipse": [38, 66, 20, 20], "count": 6}),
                              P("circle", 90, 44, 4, 4, repeat={"ellipse": [90, 66, 20, 20], "count": 6})], "bronze", kind="flat")]


@icon("icon_sp_steam_pistol", "B", "증기 권총", "스팀펑크", rot=-18, seed=318)
def _():
    return [F("grip", 0, [P("square", 38, 84, 22, 40, rot=18)], "wood"),
            F("body", 1, [P("square", 58, 58, 46, 22)], "brass"),
            F("barrel", 1.2, [P("square", 92, 52, 50, 12)], "bronze"),
            F("muzzle", 1.3, [P("square", 118, 52, 8, 18)], "brass"),
            F("tank", 2, [P("cylinder", 60, 36, 30, 20)], "cloth_red", shade={"highlight_amount": 0.7}),
            F("pipe", 1.8, [P("square", 80, 40, 26, 4), P("square", 92, 45, 4, 10)], "bronze"),
            F("gauge", 2.2, [P("circle", 44, 58, 16, 16)], "paper"),
            F("needle", 2.3, [P("square", 46, 56, 2, 8, rot=40)], "iron_dark", kind="flat"),
            F("guard", 1.5, [P("circle", 56, 74, 18, 14), P("circle", 56, 74, 11, 8, op="sub")], "brass")]


@icon("icon_pa_canned_food", "B", "찌그러진 통조림", "포스트아포칼립스", rot=8, seed=319)
def _():
    return [F("can", 0, [P("cylinder", 64, 66, 70, 88)], "steel"),
            F("dent", 1.4, [P("moon", 88, 58, 14, 30, rot=10)], None, kind="flat", color="coat_seam", opacity=0.5, clip_to="can"),
            F("label", 1, [P("square", 60, 70, 70, 40)], "cloth_rust", clip_to="can"),
            F("label_tear", 1.2, [P("lightning_bolt", 82, 70, 14, 44)], "steel", clip_to="label"),
            F("label_band", 1.3, [P("square", 60, 70, 70, 6)], "paper", kind="flat", opacity=0.7, clip_to="label"),
            F("rust", 1.5, [P("metaballs", 44, 100, 22, 16)], "rust", kind="flat", opacity=0.7, clip_to="can"),
            F("lid_ring", 2, [P("circle", 64, 28, 58, 12), P("circle", 64, 28, 48, 7, op="sub")], "chrome", kind="flat", opacity=0.7)]


@icon("icon_pa_geiger", "B", "방사능 측정기", "포스트아포칼립스", rot=0, seed=320)
def _():
    return [F("cable", -1, [P("square", 106, 84, 4, 40, rot=20)], "rubber"),
            F("probe", -0.5, [P("square", 114, 50, 12, 44, rot=20)], "chrome"),
            F("body", 0, [P("square", 56, 70, 84, 64)], "cloth_mustard", kind="block", extrude=6),
            F("handle", -0.8, [P("square", 56, 32, 60, 10), P("square", 30, 40, 8, 20), P("square", 82, 40, 8, 20)], "iron_dark"),
            F("dial", 1, [P("circle", 46, 70, 38, 38)], "paper"),
            F("scale", 1.2, [P("circle", 46, 74, 30, 30), P("circle", 46, 74, 24, 24, op="sub"), P("square", 46, 84, 40, 12, op="sub")],
              "ember_red", kind="flat", opacity=0.8, clip_to="dial"),
            F("needle", 1.4, [P("square", 50, 64, 2.4, 18, rot=35)], "iron_dark", kind="flat"),
            F("trefoil", 1.3, [P("radioactive_symbol", 80, 80, 20, 20)], "iron_dark", kind="flat", opacity=0.85),
            F("lamp", 1.5, [P("circle", 82, 56, 8, 8)], "rad_green", kind="flat", emit=1.0, glow=dict(GLOW, color="rad_glow"))]


@icon("icon_pi_spyglass", "B", "망원경", "해적·바다", rot=-40, seed=321)
def _():
    return [F("tube_c", 0, [P("square", 104, 64, 26, 20)], "brass"),
            F("tube_b", 0.5, [P("square", 80, 64, 30, 24)], "brass"),
            F("tube_a", 1, [P("square", 46, 64, 44, 30)], "leather_dark"),
            F("rings", 1.5, [P("square", 66, 64, 5, 32), P("square", 94, 64, 5, 26), P("square", 26, 64, 6, 32)], "bronze"),
            F("lens", 2, [P("circle", 118, 64, 6, 18)], "lens")]


@icon("icon_pi_treasure_map", "B", "보물 지도", "해적·바다", rot=-6, seed=322)
def _():
    return [F("paper", 0, [P("square", 64, 64, 100, 84), P("lightning_bolt", 16, 40, 10, 22, op="sub"), P("triangle", 108, 104, 16, 12, op="sub")],
              "paper", shade={"bump": 0.3}),
            F("roll_top", 1, [P("square", 64, 22, 108, 14)], "paper", shade={"bump": 0.8}),
            F("roll_bottom", 1, [P("square", 64, 106, 104, 12)], "paper", shade={"bump": 0.8}),
            F("coast", 0.5, [P("cloud", 44, 70, 52, 36), P("cloud", 84, 52, 34, 24)], "paper_mark", kind="flat", opacity=0.55, clip_to="paper"),
            F("path", 0.8, [P("square", 30, 88, 6, 3, repeat={"line": [[30, 88], [86, 58]], "count": 7})], "cloth_crimson", kind="flat"),
            F("x", 1, [P("square", 92, 56, 5, 18, rot=45), P("square", 92, 56, 5, 18, rot=-45)], "cloth_crimson", kind="flat"),
            F("rose", 0.9, [P("star", 28, 44, 16, 16)], "paper_mark", kind="flat", opacity=0.8)]


@icon("icon_we_lasso", "B", "올가미 밧줄", "서부", rot=0, seed=323)
def _():
    rope = {"stamp": "pill", "pre_rot": -45, "length": 8, "width": 2, "angle": 60, "jitter": 6, "density": 1.0, "strength": 0.25}
    return [F("coil_back", 0, [P("circle", 56, 72, 80, 70), P("circle", 56, 72, 66, 56, op="sub")], "rope", texture=rope),
            F("coil_mid", 0.5, [P("circle", 62, 68, 76, 66), P("circle", 62, 68, 64, 54, op="sub")], "rope", texture=rope),
            F("loop", 1, [P("circle", 92, 34, 44, 34), P("circle", 92, 34, 34, 25, op="sub")], "rope", texture=rope),
            F("knot", 1.5, [P("circle", 76, 50, 14, 12)], "rope"),
            F("tail", 0.2, [P("square", 30, 108, 7, 28, rot=30)], "rope", texture=rope)]


# ------------------------------------------------------------------ C
@icon("icon_ho_cassette", "C", "카세트 녹음기", "호러·오컬트", rot=-8, seed=324)
def _():
    return [F("body", 0, [P("square", 64, 68, 96, 64)], "cloth_grey", kind="block", extrude=6),
            F("window", 1, [P("square", 60, 62, 60, 30)], "iron_dark"),
            F("reels", 1.5, [P("circle", 46, 62, 18, 18), P("circle", 74, 62, 18, 18)], "paper", kind="flat", opacity=0.9),
            F("hubs", 1.6, [P("cog", 46, 62, 10, 10), P("cog", 74, 62, 10, 10)], "iron_dark", kind="flat"),
            F("tape", 1.4, [P("square", 60, 70, 30, 6)], "leather_dark", kind="flat"),
            F("keys", 1.2, [P("square", 38, 94, 14, 8, repeat={"grid": [4, 1], "step": [16, 0]})], "iron_dark"),
            F("speaker", 1.3, [P("square", 104, 60, 14, 2.4, repeat={"grid": [1, 5], "step": [0, 6]})], None, **SEAM),
            F("rec", 2, [P("circle", 38, 94, 7, 5)], "ember_red", kind="flat", emit=0.8)]


@icon("icon_sf_oxygen_tank", "C", "산소통", "SF·우주", rot=-20, seed=325)
def _():
    return [F("tank", 0, [P("cylinder", 64, 72, 50, 90)], "cloth_white", shade={"highlight_amount": 0.7}),
            F("band", 1, [P("square", 64, 72, 50, 12)], "neon_amber", kind="flat", opacity=0.85),
            F("valve", 1.2, [P("square", 64, 22, 16, 16), P("square", 64, 12, 30, 7)], "chrome"),
            F("gauge", 1.4, [P("circle", 84, 22, 16, 16)], "paper"),
            F("needle", 1.5, [P("square", 86, 20, 2, 7, rot=40)], "iron_dark", kind="flat"),
            F("hose", 0.5, [P("square", 40, 30, 5, 30, rot=40)], "rubber")]


@icon("icon_cp_cred_chip", "C", "크레딧 칩", "사이버펑크", rot=-24, seed=326)
def _():
    return [F("card", 0, [P("square", 64, 64, 100, 62)], "iron_dark", kind="block", extrude=4),
            F("stripe", 1, [P("square", 64, 50, 96, 8)], "neon_magenta", kind="flat", emit=1.0, glow=dict(GLOW, color="neon_glow_m")),
            F("contact", 1.2, [P("square", 36, 72, 20, 16)], "gold"),
            F("contact_lines", 1.3, [P("square", 36, 72, 18, 2, repeat={"grid": [1, 3], "step": [0, 5]})], None, **SEAM),
            F("holo", 1.4, [P("circle", 88, 76, 18, 18)], "neon_cyan", kind="flat", emit=0.7, opacity=0.8)]


@icon("icon_cp_mono_blade", "C", "단분자 칼", "사이버펑크", rot=-45, seed=327)
def _():
    return [F("grip", 0, [P("square", 30, 64, 34, 14)], "rubber"),
            F("guard", 0.5, [P("square", 49, 64, 6, 26)], "chrome"),
            F("blade", 1, [P("square", 84, 62, 64, 10), P("triangle", 120, 62, 10, 12, rot=90)], "chrome", shade={"highlight_amount": 0.8}),
            F("edge", 1.2, [P("square", 86, 67, 66, 2.4)], "neon_cyan", kind="flat", emit=1.0, glow=dict(GLOW, color="neon_glow_c")),
            F("wrap", 0.6, [P("square", 30, 64, 2.4, 14, repeat={"grid": [4, 1], "step": [7, 0]})], "neon_magenta", kind="flat", emit=0.6)]


@icon("icon_sp_clockwork_key", "C", "태엽 열쇠", "스팀펑크", rot=-35, seed=328)
def _():
    return [F("wing_l", 0, [P("circle", 24, 64, 30, 40)], "brass"),
            F("wing_r", 0, [P("circle", 50, 64, 30, 40)], "brass"),
            F("holes", 0.5, [P("circle", 24, 64, 12, 18), P("circle", 50, 64, 12, 18)], "void", kind="flat"),
            F("shaft", 1, [P("square", 86, 64, 60, 10)], "bronze"),
            F("collar", 1.2, [P("square", 62, 64, 10, 18)], "brass"),
            F("bit", 1.3, [P("square", 116, 64, 8, 14)], "bronze")]


@icon("icon_pa_jerrycan", "C", "연료통", "포스트아포칼립스", rot=6, seed=329)
def _():
    return [F("can", 0, [P("square", 64, 70, 76, 92)], "cloth_rust", kind="block", extrude=6),
            F("x", 1, [P("square", 64, 76, 6, 70, rot=38), P("square", 64, 76, 6, 70, rot=-38)], None, kind="flat", color="coat_seam", opacity=0.6),
            F("handles", -0.5, [P("square", 50, 18, 12, 14), P("square", 64, 18, 12, 14), P("square", 78, 18, 12, 14),
                                P("square", 64, 12, 44, 7)], "iron_dark"),
            F("spout", 0.5, [P("cylinder", 92, 26, 16, 16)], "iron"),
            F("scrape", 1.2, [P("metaballs", 42, 104, 24, 14)], "iron", kind="flat", opacity=0.55, clip_to="can")]


@icon("icon_pi_rum", "C", "럼주 병", "해적·바다", rot=14, seed=330)
def _():
    return [F("bottle", 0, [P("potion", 64, 70, 76, 100)], "cloth_green", opacity=0.95, shade={"highlight_amount": 0.8}),
            F("liquid", 0.5, [P("circle", 64, 82, 56, 50)], "cloth_brown", kind="flat", opacity=0.6, clip_to="bottle"),
            F("label", 1, [P("square", 64, 84, 40, 22)], "paper", clip_to="bottle"),
            F("mark", 1.2, [P("square", 64, 84, 20, 3)], "cloth_crimson", kind="flat"),
            F("cork", 1.5, [P("cylinder", 64, 18, 16, 16)], "leather_tan"),
            glint(50, 64, 10, 30, "bottle", rot=0)]


@icon("icon_we_dynamite", "C", "다이너마이트", "서부", rot=-14, seed=331)
def _():
    return [F("sticks", 0, [P("square", x, 72, 26, 78) for x in (36, 64, 92)], "cloth_red", shade={"bump": 0.8}),
            F("ends", 0.5, [P("circle", x, 33, 26, 8) for x in (36, 64, 92)], "paper"),
            F("band", 1, [P("square", 64, 76, 90, 12)], "rope"),
            F("fuse", 1.2, [P("square", 70, 18, 3, 26, rot=24)], "rope"),
            F("spark", 2, [P("star", 76, 5, 14, 14)], "neon_amber", kind="flat", emit=1.0, glow=dict(GLOW, color="flame_glow"))]


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
