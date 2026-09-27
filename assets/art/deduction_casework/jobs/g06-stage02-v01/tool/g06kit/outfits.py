"""Outfit-driven figure builder shared by all stages.

    figure(j, H, view, spec) -> forms
spec keys (all optional except skin):
    skin, hair=(style, mat, kw), eyes, eye_size, brows, mouth, age, jaw, face_w,
    trousers, skirt=(mat, hem_ratio), dress=mat, top=mat, top_waist, sleeves=mat,
    coat=(mat, hem_ratio, open), jacket=(mat, hem_ratio), vest=mat, apron=mat,
    shoes, tie=mat, scarf=mat, collar=mat, glasses='round'|'square'|'thin',
    mustache=mat, hat=('net'|'cap'|'bowler'|'band', mat), hand=size, extras=[callable(j, H) -> forms]
"""

from __future__ import annotations

import math

from . import F, box, ell, icon, lerp, limb, quad, rect
from . import person as P


def pose_sit_chair(g, H, view="3q", seat=0.46, lean=0.0, slump=0.0, knee_fwd=0.2):
    """Seated on a chair/sofa facing screen-right; g = floor point under the knees'
    front edge is NOT used: g = floor point under the hip (seat front)."""
    gx, gy = g
    ppm = H / 1.7
    hh = H / P.HEAD_RATIO
    sw = H * 0.25 * (0.8 if view == "3q" else 1.0)
    pel = [gx, gy - seat * ppm]
    torso = H * 0.3 * (1 - slump * 0.15)
    a = math.radians(lean + slump * 35)
    neck = [pel[0] - math.sin(a) * torso, pel[1] - math.cos(a) * torso]
    j = {"hh": hh, "pelvis": pel, "neck": neck,
         "head": [neck[0] + H * 0.018 - slump * H * 0.05, neck[1] - hh * 0.48 + slump * hh * 0.25],
         "sh_n": [neck[0] - sw / 2, neck[1] + hh * 0.15], "sh_f": [neck[0] + sw / 2, neck[1] + hh * 0.12],
         "hip_n": [pel[0] - H * 0.02, pel[1] + H * 0.004], "hip_f": [pel[0] + H * 0.03, pel[1] - H * 0.004]}
    kx = pel[0] + H * knee_fwd
    j["kn_n"] = [kx - H * 0.01, pel[1] + H * 0.01]
    j["kn_f"] = [kx + H * 0.03, pel[1] - H * 0.006]
    j["an_n"] = [kx - H * 0.02, gy - H * 0.035]
    j["an_f"] = [kx + H * 0.03, gy - H * 0.04]
    j["chest"] = lerp(neck, pel, 0.33)
    if slump:
        j["el_n"] = [j["sh_n"][0] + H * 0.02, j["sh_n"][1] + H * 0.16]
        j["wr_n"] = [j["el_n"][0] + H * 0.05, j["el_n"][1] + H * 0.13]
        j["el_f"] = [j["sh_f"][0] + H * 0.05, j["sh_f"][1] + H * 0.14]
        j["wr_f"] = [j["el_f"][0] + H * 0.1, j["el_f"][1] + H * 0.08]
    else:
        j["el_n"] = [j["sh_n"][0] + H * 0.03, j["sh_n"][1] + H * 0.16]
        j["wr_n"] = [j["el_n"][0] + H * 0.12, j["el_n"][1] + H * 0.02]
        j["el_f"] = [j["sh_f"][0] + H * 0.03, j["sh_f"][1] + H * 0.15]
        j["wr_f"] = [j["el_f"][0] + H * 0.12, j["el_f"][1] + H * 0.03]
    return j


def _hat(j, kind, mat):
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    if kind == "net":   # small black mourning hat with a net veil
        return [F("hat", [ell(cx - w * 0.05, cy - hh * 0.4, w * 0.9, hh * 0.24), ell(cx - w * 0.05, cy - hh * 0.46, w * 0.55,
                                                                                    hh * 0.2)], mat, 11.0),
                F("veil", [quad([(cx - w * 0.5, cy - hh * 0.36), (cx + w * 0.5, cy - hh * 0.36), (cx + w * 0.55, cy - hh * 0.02),
                                 (cx - w * 0.52, cy + hh * 0.02)])], mat, 11.1, kind="flat", opacity=0.35),
                F("veil_mesh", [icon("grid_fine", cx, cy - hh * 0.2, w * 1.0, hh * 0.34)], mat, 11.2, kind="flat",
                  opacity=0.45, clip_to="veil")]
    if kind == "cap":
        return [F("cap", [ell(cx - w * 0.04, cy - hh * 0.36, w * 1.08, hh * 0.4),
                          quad([(cx + w * 0.2, cy - hh * 0.26), (cx + w * 0.78, cy - hh * 0.2), (cx + w * 0.7, cy - hh * 0.14),
                                (cx + w * 0.2, cy - hh * 0.16)])], mat, 11.0)]
    if kind == "bowler":
        return [F("hat", [ell(cx, cy - hh * 0.42, w * 0.9, hh * 0.45), ell(cx, cy - hh * 0.25, w * 1.3, hh * 0.12)], mat, 11.0)]
    if kind == "band":
        return [F("band", [ell(cx - w * 0.02, cy - hh * 0.3, w * 1.06, hh * 0.14)], mat, 10.9)]
    if kind == "goggles":
        return [F("goggles", [ell(cx + w * 0.02, cy - hh * 0.3, w * 0.95, hh * 0.2)], mat, 11.0, line={"width": 0.8, "heavy": 0.8}),
                F("goggle_strap", [ell(cx - w * 0.1, cy - hh * 0.3, w * 1.1, hh * 0.08)], "rubber", 10.95)]
    return []


def _glasses(j, kind):
    ex = j["eye_pts"]
    r = j["hh"] * 0.11
    if kind == "square":
        pcs = [rect(ex[0][0] - r * 0.9, ex[0][1] - r * 0.75, ex[0][0] + r * 0.9, ex[0][1] + r * 0.75),
               rect(ex[1][0] - r, ex[1][1] - r * 0.75, ex[1][0] + r, ex[1][1] + r * 0.75)]
        inner = [rect(ex[0][0] - r * 0.7, ex[0][1] - r * 0.55, ex[0][0] + r * 0.7, ex[0][1] + r * 0.55),
                 rect(ex[1][0] - r * 0.8, ex[1][1] - r * 0.55, ex[1][0] + r * 0.8, ex[1][1] + r * 0.55)]
        return [F("glasses", pcs + [rect(ex[0][0] + r * 0.9, ex[0][1] - r * 0.2, ex[1][0] - r, ex[0][1] + r * 0.05)],
                  "plastic_black", 10.6, kind="flat"),
                F("glasses_lens", inner, "glass_clear", 10.61, kind="flat", opacity=0.55)]
    mat = "brass" if kind == "gold" else "steel"
    sc = 0.8 if kind in ("thin", "gold") else 1.0
    return [F("glasses", [icon("ring", ex[0][0], ex[0][1], r * 2.3 * sc, r * 2.0 * sc),
                          icon("ring", ex[1][0], ex[1][1], r * 2.3 * sc, r * 2.0 * sc),
                          rect(ex[0][0] + r * 0.9, ex[0][1] - r * 0.2, ex[1][0] - r * 1.1, ex[0][1] + r * 0.05)],
              mat, 10.6, kind="flat", line={"width": 0.4, "heavy": 0.4})]


def figure(j, H, view, spec) -> list:
    s = spec
    skin = s["skin"]
    f = []
    facing = 0 if view == "front" else 1
    legmat = s.get("trousers") or s.get("legs") or skin
    f += P.legs(j, H, legmat, s.get("shoes", "shoe_black"), width=s.get("leg_w", 0.064), shoe_len=0.095, facing=facing)
    top = s.get("top") or s.get("dress")
    pel = j["pelvis"]
    if s.get("dress"):
        skirt_hem = pel[1] + H * s.get("dress_hem", 0.33)
        sl, sr = P._lr(j, "sh")
        f.append(F("dress_skirt", [quad([(pel[0] - H * 0.09, pel[1] - H * 0.04), (pel[0] + H * 0.09, pel[1] - H * 0.04),
                                         (pel[0] + H * 0.14, skirt_hem), (pel[0] - H * 0.15, skirt_hem)])],
                   s["dress"], 3.9, tags=["body"]))
    if s.get("skirt"):
        mat, hem = s["skirt"]
        if s.get("seated"):   # skirt follows the thighs to just past the knees
            k = lerp(j["kn_n"], j["kn_f"], 0.5)
            f.append(F("skirt", [quad([(pel[0] - H * 0.08, pel[1] - H * 0.045), (k[0] + H * 0.035, k[1] - H * 0.04),
                                       (k[0] + H * 0.035, k[1] + H * 0.05), (pel[0] - H * 0.08, pel[1] + H * 0.05)])],
                       mat, 5.8, tags=["body"]))
        else:
            f.append(F("skirt", [quad([(pel[0] - H * 0.085, pel[1] - H * 0.035), (pel[0] + H * 0.085, pel[1] - H * 0.035),
                                       (pel[0] + H * 0.12, pel[1] + H * hem), (pel[0] - H * 0.13, pel[1] + H * hem)])],
                       mat, 3.95, tags=["body"]))
    f.append(F("top", [quad(P._torso_poly(j, H, waist=s.get("top_waist", 0.3), hem=pel[1] + H * 0.03,
                                          hem_w=H * s.get("hem_w", 0.16)))], top, 4.0, tags=["body"]))
    if s.get("collar"):
        n = j["neck"]
        f.append(F("collar", [quad([(n[0] - H * 0.045, n[1] + H * 0.005), (n[0] + H * 0.05, n[1] + H * 0.005),
                                    (n[0] + H * 0.012, n[1] + H * 0.05)])], s["collar"], 4.3))
    if s.get("tie"):
        n = j["neck"]
        f.append(F("tie", [quad([(n[0] - H * 0.012, n[1] + H * 0.02), (n[0] + H * 0.018, n[1] + H * 0.02),
                                 (n[0] + H * 0.024, j["chest"][1] + H * 0.08), (n[0] + H * 0.003, j["chest"][1] + H * 0.1),
                                 (n[0] - H * 0.014, j["chest"][1] + H * 0.08)])], s["tie"], 4.4))
    if s.get("vest"):
        sl, sr = P._lr(j, "sh")
        n = j["neck"]
        f.append(F("vest", [quad([(sl[0] + H * 0.012, sl[1] + H * 0.01), (n[0] - H * 0.01, n[1] + H * 0.035),
                                  (n[0] + H * 0.018, j["chest"][1] + H * 0.06), (n[0] + H * 0.045, n[1] + H * 0.035),
                                  (sr[0] - H * 0.01, sr[1] + H * 0.01), (pel[0] + H * 0.075, pel[1] + H * 0.01),
                                  (pel[0] - H * 0.075, pel[1] + H * 0.012)])], s["vest"], 4.5, tags=["body"]))
    if s.get("apron"):
        f.append(F("apron", [quad([(pel[0] - H * 0.08, j["chest"][1] + H * 0.05), (pel[0] + H * 0.09, j["chest"][1] + H * 0.05),
                                   (pel[0] + H * 0.12, pel[1] + H * 0.28), (pel[0] - H * 0.12, pel[1] + H * 0.28)])],
                   s["apron"], 4.7, tags=["body"]))
    if s.get("jacket"):
        mat, hem = s["jacket"]
        f += P.coat_panels(j, H, mat, z=5.0, hem_y=pel[1] + H * hem, gap=s.get("jacket_gap", 0.035), flare=0.12)
    if s.get("coat"):
        mat, hem, _open = s["coat"]
        f += P.coat_panels(j, H, mat, z=5.0, hem_y=pel[1] + H * hem, gap=0.05 if _open else 0.012, flare=0.2)
    sleeve = s.get("sleeves") or (s["coat"][0] if s.get("coat") else (s["jacket"][0] if s.get("jacket") else top))
    hand = s.get("hand", 0.05)
    hands = s.get("hands", skin)
    f += P.arm(j, H, "f", sleeve, hands, 2.0, width=s.get("arm_w", 0.05), hand=hand)
    f += P.arm(j, H, "n", sleeve, hands, 6.0, width=s.get("arm_w", 0.05), hand=hand)
    f += P.neck(j, H, skin, z=4.2, w=s.get("neck_w", 0.052))
    f += P.head(j, H, skin, view, jaw=s.get("jaw", 0.88), width=s.get("face_w", 0.7))
    f += P.ear(j, H, skin, view)
    f += P.face(j, H, view, eyes=s.get("eyes", "open"), brow_tilt=s.get("brow_tilt", 0), eye_size=s.get("eye_size", 0.9),
                brow_mat=s.get("brows", "hair_brown"), mouth=s.get("mouth", "flat"), age_lines=s.get("age", 0),
                lid=s.get("lid"))
    hair = s.get("hair")
    if hair:
        style, mat, kw = (hair + ({},))[:3] if len(hair) == 2 else hair
        fn = {"bob": P.hair_bob, "short": P.hair_short_back, "bald": P.hair_bald_sides, "ponytail": P.hair_ponytail,
              "bun": hair_bun, "wave": hair_wave, "crop": hair_crop}[style]
        f += fn(j, mat, view=view, **kw)
    if s.get("mustache"):
        hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
        off = w * 0.1 if view == "3q" else 0
        f.append(F("mustache", [icon("moon", cx + off + w * 0.03, cy + hh * 0.22, hh * 0.3, hh * 0.1, rot=90)],
                   s["mustache"], 10.4))
    if s.get("glasses"):
        f += _glasses(j, s["glasses"])
    if s.get("hat"):
        f += _hat(j, *s["hat"])
    for ex in s.get("extras", []):
        f += ex(j, H)
    return f


# ------------------------------------------------------------------ more hair styles
def hair_bun(j, mat, view="3q", z_back=7.6, z_front=9.0, low=True):
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    by = cy + hh * (0.12 if low else -0.3)
    return [F("bun", [ell(cx - w * 0.58, by, w * 0.42, hh * 0.36)], mat, z_back - 0.1),
            F("hair_back", [ell(cx - w * 0.05, cy - hh * 0.14, w * 1.1, hh * 0.84)], mat, z_back),
            F("hair_front", [icon("cloud", cx + w * 0.02, cy - hh * 0.36, w * 1.1, hh * 0.42)], mat, z_front,
              shade={"highlight_amount": 0.55})]


def hair_wave(j, mat, view="3q", z_back=7.6, z_front=9.0):
    """Short wave tucked behind the ears."""
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    return [F("hair_back", [ell(cx - w * 0.08, cy - hh * 0.1, w * 1.16, hh * 0.9)], mat, z_back),
            F("hair_front", [icon("cloud", cx + w * 0.0, cy - hh * 0.35, w * 1.18, hh * 0.46),
                             icon("cloud", cx - w * 0.4, cy - hh * 0.05, w * 0.4, hh * 0.4)], mat, z_front,
              shade={"highlight_amount": 0.55})]


def hair_crop(j, mat, view="3q", z=9.0):
    """Short cropped hair (bleached / buzz)."""
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    return [F("hair", [ell(cx - w * 0.04, cy - hh * 0.3, w * 1.04, hh * 0.44), ell(cx - w * 0.36, cy - hh * 0.12, w * 0.32,
                                                                                   hh * 0.36)], mat, z,
              shade={"highlight_amount": 0.5})]
