"""Stylised adult figures for the 03 kit, assembled from icon cuts.

A figure = joints (``pose_*``) + an outfit spec.  Joints are in canvas px.
Views: ``front`` and ``3q`` (three-quarter, facing screen-right; mirror the
frame for facing left).  Head is ~1/5.3 of the standing height (13 bible 1.2:
"head slightly larger than reality").

Draw order (z): far leg 1, far arm 2, torso/legs 3-4, coat 5, near leg 5.5,
near arm 6-7, neck 7.5, head 8, hair 9, face 10, accessories 11+.
"""

from __future__ import annotations

import math

from . import F, ell, icon, lerp, limb, quad, rect, shadow

# ------------------------------------------------------------------ poses
# Each pose returns a dict of joints (canvas px) given ground point g and height H.
#  keys: head (centre), neck, sh_n/sh_f (near/far shoulder), el_n/el_f, wr_n/wr_f,
#        hip_n/hip_f, kn_n/kn_f, an_n/an_f (ankles), pelvis, chest


HEAD_RATIO = 4.8   # standing height / head height (stylised: 13 bible 1.2)
HIP = 0.465        # hip joint height / H
KNEE = 0.245


def _base(g, H, view):
    gx, gy = g
    hh = H / HEAD_RATIO
    s = 0.8 if view == "3q" else 1.0          # shoulder width squeeze in 3/4
    sw = H * 0.25 * s
    hw = H * 0.17 * s
    j = {
        "hh": hh,
        "head": [gx + (H * 0.012 if view == "3q" else 0), gy - H + hh * 0.5],
        "neck": [gx, gy - H + hh * 0.98],
        # 3/4 facing screen-right: the NEAR (camera-side) shoulder is on screen-left
        "sh_n": [gx - sw / 2, gy - H + hh * 1.14],
        "sh_f": [gx + sw / 2, gy - H + hh * 1.14 - (H * 0.006 if view == "3q" else 0)],
        "hip_n": [gx - hw * 0.32, gy - H * HIP],
        "hip_f": [gx + hw * 0.32, gy - H * HIP],
    }
    j["pelvis"] = lerp(j["hip_n"], j["hip_f"], 0.5)
    j["chest"] = lerp(j["neck"], j["pelvis"], 0.33)
    return j


def pose_stand(g, H, view="3q", arms="down", lean=0.0):
    j = _base(g, H, view)
    gx, gy = g
    if lean:
        for k in ("head", "neck", "sh_n", "sh_f", "chest"):
            j[k][0] += lean * (gy - j[k][1]) / H
    j["kn_n"] = [gx - H * 0.035, gy - H * KNEE]
    j["kn_f"] = [gx + H * 0.035, gy - H * (KNEE + 0.002)]
    j["an_n"] = [gx - H * 0.045, gy - H * 0.035]
    j["an_f"] = [gx + H * 0.045, gy - H * 0.04]
    if arms == "down":
        j["el_n"] = [j["sh_n"][0] - H * 0.02, j["sh_n"][1] + H * 0.17]
        j["wr_n"] = [j["el_n"][0] - H * 0.004, j["el_n"][1] + H * 0.15]
        j["el_f"] = [j["sh_f"][0] + H * 0.02, j["sh_f"][1] + H * 0.17]
        j["wr_f"] = [j["el_f"][0] + H * 0.008, j["el_f"][1] + H * 0.15]
    return j


def set_arm(j, side, elbow, wrist):
    j["el_" + side] = list(elbow)
    j["wr_" + side] = list(wrist)
    return j


def pose_sit_floor(g, H, view="3q", lean_back=12.0):
    """Seated on the floor facing screen-right, knees up, torso leaning back to the
    left (against a bench).  Near (camera-side) limbs are on screen-left.
    Near hand rests on the near knee, far hand on the floor beside the hip."""
    gx, gy = g
    hh = H / HEAD_RATIO
    sw = H * 0.25 * (0.8 if view == "3q" else 1.0)
    pel = [gx, gy - H * 0.045]
    torso = H * 0.30
    a = math.radians(lean_back)
    neck = [pel[0] - math.sin(a) * torso, pel[1] - math.cos(a) * torso]
    j = {"hh": hh, "pelvis": pel, "neck": neck,
         "head": [neck[0] + H * 0.018, neck[1] - hh * 0.48],
         "sh_n": [neck[0] - sw / 2, neck[1] + hh * 0.17],
         "sh_f": [neck[0] + sw / 2, neck[1] + hh * 0.13],
         "hip_n": [pel[0] - H * 0.03, pel[1] + H * 0.004],
         "hip_f": [pel[0] + H * 0.03, pel[1] - H * 0.006],
         "kn_n": [pel[0] + H * 0.16, pel[1] - H * 0.15],
         "kn_f": [pel[0] + H * 0.21, pel[1] - H * 0.165],
         "an_n": [pel[0] + H * 0.29, pel[1] + H * 0.03],
         "an_f": [pel[0] + H * 0.34, pel[1] + H * 0.015]}
    j["chest"] = lerp(j["neck"], j["pelvis"], 0.33)
    j["el_n"] = [j["sh_n"][0] + H * 0.05, j["sh_n"][1] + H * 0.14]
    j["wr_n"] = [j["kn_n"][0] - H * 0.035, j["kn_n"][1] + H * 0.005]
    j["el_f"] = [j["sh_f"][0] + H * 0.03, j["sh_f"][1] + H * 0.13]
    j["wr_f"] = [pel[0] + H * 0.07, pel[1] - H * 0.005]
    return j


def pose_kneel(g, H, view="3q"):
    """Facing screen-right: far knee on the floor, near foot planted in front,
    torso upright, both hands forward and low (working on the floor)."""
    gx, gy = g
    j = _base([gx, gy + H * 0.2], H, view)   # the whole upper body drops by the kneel
    j["hip_n"] = [gx - H * 0.03, gy - H * 0.265]
    j["hip_f"] = [gx + H * 0.03, gy - H * 0.27]
    j["pelvis"] = lerp(j["hip_n"], j["hip_f"], 0.5)
    j["kn_n"] = [gx + H * 0.14, gy - H * 0.2]      # near leg: foot planted, knee up
    j["an_n"] = [gx + H * 0.13, gy - H * 0.03]
    j["kn_f"] = [gx + H * 0.02, gy - H * 0.03]     # far leg: knee on the floor, shin back
    j["an_f"] = [gx - H * 0.2, gy - H * 0.035]
    j["chest"] = lerp(j["neck"], j["pelvis"], 0.33)
    j["el_n"] = [j["sh_n"][0] + H * 0.07, j["sh_n"][1] + H * 0.14]
    j["wr_n"] = [j["el_n"][0] + H * 0.13, j["el_n"][1] + H * 0.06]
    j["el_f"] = [j["sh_f"][0] + H * 0.05, j["sh_f"][1] + H * 0.14]
    j["wr_f"] = [j["el_f"][0] + H * 0.13, j["el_f"][1] + H * 0.08]
    return j


# ------------------------------------------------------------------ parts
def _lr(j, key):
    """(screen-left, screen-right) points of a near/far joint pair."""
    a, b = j[key + "_n"], j[key + "_f"]
    return (a, b) if a[0] <= b[0] else (b, a)


def _torso_poly(j, H, top_w_scale=1.0, waist=0.34, hem=None, hem_w=None):
    sl, sr = _lr(j, "sh")
    pel = j["pelvis"]
    hem = hem if hem is not None else pel[1] + H * 0.02
    hw = hem_w if hem_w is not None else H * 0.18
    cx_top = (sl[0] + sr[0]) / 2
    half = abs(sr[0] - sl[0]) / 2 * top_w_scale
    wy = lerp(j["neck"], pel, 0.62)[1]
    wx = cx_top + (pel[0] - cx_top) * 0.62
    ww = H * waist * 0.5
    return [(cx_top - half, sl[1] - H * 0.004), (cx_top + half, sr[1] - H * 0.004),
            (wx + ww * 0.62, wy), (pel[0] + hw / 2, hem), (pel[0] - hw / 2, hem), (wx - ww * 0.62, wy)]


def legs(j, H, mat, shoe, z_far=1.0, z_near=5.5, width=0.062, shoe_len=0.085, trouser=True, far_mat=None,
         facing=1):
    out = []
    for side, z in (("f", z_far), ("n", z_near)):
        w = H * width
        pieces = limb(j["hip_" + side], j["kn_" + side], w * 1.15, w * 0.95) + \
            limb(j["kn_" + side], j["an_" + side], w * 0.95, w * 0.72)
        out.append(F(f"leg_{side}", pieces, far_mat if (side == "f" and far_mat) else mat, z,
                     tags=["legs", "leg_" + side]))
        a = j["an_" + side]
        sl = H * shoe_len
        if facing == 0:   # front view: toes toward the camera, a short wide oval
            sp = ell(a[0], a[1] + H * 0.02, sl * 0.7, H * 0.05)
        else:
            sp = ell(a[0] + facing * sl * 0.3, a[1] + H * 0.018, sl, H * 0.042)
        out.append(F(f"shoe_{side}", [sp], shoe, z + 0.1, tags=["legs", "leg_" + side]))
    return out


def arm(j, H, side, sleeve, skin, z, width=0.052, hand=0.05, cuff=None, hand_icon=None, hand_rot=None):
    w = H * width
    sh, el, wr = j["sh_" + side], j["el_" + side], j["wr_" + side]
    forms = [F(f"arm_{side}", limb(sh, el, w * 1.1, w * 0.92) + limb(el, wr, w * 0.92, w * 0.78),
               sleeve, z, tags=["arms", "arm_" + side])]
    if cuff:
        c = lerp(el, wr, 0.9)
        forms.append(F(f"cuff_{side}", limb(lerp(el, wr, 0.8), c, w * 0.86, w * 0.84, caps=False), cuff, z + 0.05))
    hs = H * hand
    dx, dy = wr[0] - el[0], wr[1] - el[1]
    L = math.hypot(dx, dy) or 1.0
    hc = [wr[0] + dx / L * hs * 0.42, wr[1] + dy / L * hs * 0.42]
    if hand_icon:
        rot = hand_rot if hand_rot is not None else math.degrees(math.atan2(-dx, dy)) + 180
        forms.append(F(f"hand_{side}", [icon(hand_icon, hc[0], hc[1], hs * 1.25, rot=rot)], skin, z + 0.1,
                       tags=["arms", "hand_" + side]))
    else:
        forms.append(F(f"hand_{side}", [ell(hc[0], hc[1], hs * 0.82, hs * 1.0,
                                            rot=math.degrees(math.atan2(-dx, dy)))], skin, z + 0.1,
                       tags=["arms", "hand_" + side]))
    j["hand_" + side] = hc
    return forms


def neck(j, H, skin, z=7.5, w=0.055):
    return [F("neck", limb(j["neck"], lerp(j["neck"], j["head"], 0.55), H * w, H * w * 0.95, caps=False), skin, z)]


def head(j, H, skin, view="3q", z=8.0, jaw=0.9, width=0.72):
    hh = j["hh"]
    cx, cy = j["head"]
    w = hh * width
    pieces = [ell(cx, cy - hh * 0.05, w, hh * 0.86)]
    # jaw: a slightly narrower lower ellipse for a longer face
    pieces.append(ell(cx + (hh * 0.03 if view == "3q" else 0), cy + hh * 0.13, w * jaw * 0.86, hh * 0.62))
    if view == "3q":  # the far cheek is hidden, the near one rounds out
        pieces.append(ell(cx + w * 0.12, cy + hh * 0.05, w * 0.6, hh * 0.6))
    j["face_w"] = w
    return [F("head", pieces, skin, z)]


def ear(j, H, skin, view="3q", z=7.9):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    if view == "3q":
        return [F("ear", [ell(cx - w * 0.43, cy + hh * 0.02, hh * 0.13, hh * 0.22)], skin, z)]
    return [F("ear", [ell(cx - w * 0.5, cy + hh * 0.02, hh * 0.12, hh * 0.2),
                      ell(cx + w * 0.5, cy + hh * 0.02, hh * 0.12, hh * 0.2)], skin, z)]


def face(j, H, view="3q", z=10.0, eyes="open", brow_tilt=0.0, mouth="flat", eye_mat="eye",
         brow_mat="hair", nose_mat="skin_shadow", eye_size=1.0, lid=None, age_lines=0):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    off = w * 0.1 if view == "3q" else 0.0
    ex = [cx + off - w * 0.2, cx + off + w * 0.22]
    ey = cy + hh * 0.02
    out = []
    es = hh * 0.07 * eye_size
    fs = 0.78 if view == "3q" else 1.0          # far eye narrower in 3/4
    look = es * (0.25 if view == "3q" else 0.0)  # irises turn toward the facing side
    if eyes == "open":
        out.append(F("eye_white", [ell(ex[0], ey, es * 1.7 * fs, es * 1.25), ell(ex[1], ey, es * 1.75, es * 1.25)],
                     "@eye_white", z, kind="flat"))
        out.append(F("eyes", [ell(ex[0] + look * 0.6, ey + es * 0.05, es * 0.95 * fs, es * 1.15),
                              ell(ex[1] + look, ey + es * 0.05, es * 0.95, es * 1.15)], eye_mat, z + 0.02, kind="flat"))
        out.append(F("lid_line", [rect(ex[0] - es * 0.95 * fs, ey - es * 0.78, ex[0] + es * 0.9 * fs, ey - es * 0.5,
                                       rot=-4),
                                  rect(ex[1] - es * 0.95, ey - es * 0.8, ex[1] + es * 0.98, ey - es * 0.5, rot=4)],
                     "@lid_line", z + 0.04, kind="flat"))
        if lid:
            out.append(F("lids", [ell(ex[0], ey + es * 0.95, es * 1.4 * fs, es * 0.28),
                                  ell(ex[1], ey + es * 0.95, es * 1.45, es * 0.28)],
                         lid, z - 0.02, kind="flat", opacity=0.55))
    elif eyes == "closed":
        out.append(F("eyes", [rect(ex[0] - es * fs, ey - es * 0.15, ex[0] + es * 0.9 * fs, ey + es * 0.15, rot=4),
                              rect(ex[1] - es, ey - es * 0.15, ex[1] + es, ey + es * 0.15, rot=-4)], eye_mat, z,
                     kind="flat"))
    elif eyes == "unfocused":  # open but looking past the object (Mira at 01:34)
        out.append(F("eye_white", [ell(ex[0], ey, es * 1.7 * fs, es * 1.25), ell(ex[1], ey, es * 1.75, es * 1.25)],
                     "@eye_white", z, kind="flat"))
        out.append(F("eyes", [ell(ex[0] - es * 0.35, ey + es * 0.18, es * 0.9 * fs, es * 1.05),
                              ell(ex[1] - es * 0.25, ey + es * 0.2, es * 0.9, es * 1.05)], eye_mat, z + 0.02,
                     kind="flat"))
        out.append(F("lid_line", [rect(ex[0] - es * 0.95 * fs, ey - es * 0.78, ex[0] + es * 0.9 * fs, ey - es * 0.5,
                                       rot=-4),
                                  rect(ex[1] - es * 0.95, ey - es * 0.8, ex[1] + es * 0.98, ey - es * 0.5, rot=4)],
                     "@lid_line", z + 0.04, kind="flat"))
    by = ey - hh * 0.13
    bw = hh * 0.16
    out.append(F("brows", [rect(ex[0] - bw / 2, by - hh * 0.018, ex[0] + bw / 2, by + hh * 0.018,
                                rot=-6 + brow_tilt) if eyes != "none" else None,
                           rect(ex[1] - bw / 2, by - hh * 0.022, ex[1] + bw / 2, by + hh * 0.014,
                                rot=6 - brow_tilt) if eyes != "none" else None],
                 brow_mat, z + 0.1, kind="flat"))
    nx = cx + off + (w * 0.1 if view == "3q" else 0.0)
    out.append(F("nose", [icon("moon", nx, cy + hh * 0.13, hh * 0.1, hh * 0.08, rot=200 if view != "3q" else 230)],
                 nose_mat, z, kind="flat"))
    my = cy + hh * 0.27
    mw = hh * 0.16
    if mouth == "flat":
        mp = [rect(cx + off - mw / 2 + w * 0.03, my - hh * 0.012, cx + off + mw / 2 + w * 0.03, my + hh * 0.012)]
    elif mouth == "open":
        mp = [ell(cx + off + w * 0.03, my, mw * 0.55, hh * 0.07)]
    else:  # tense: down-turned
        mp = [icon("moon", cx + off + w * 0.03, my + hh * 0.01, mw, hh * 0.05, rot=90)]
    out.append(F("mouth", mp, "@mouth", z, kind="flat", opacity=0.9))
    if age_lines:
        lines = [rect(cx + off - w * 0.05 - hh * 0.1, my - hh * 0.1, cx + off - w * 0.05 - hh * 0.09, my + hh * 0.02,
                      rot=20),
                 rect(cx + off + w * 0.2, my - hh * 0.1, cx + off + w * 0.21, my + hh * 0.02, rot=-20)]
        if age_lines > 1:
            lines += [rect(ex[0] - es * 1.6, ey + es * 1.2, ex[0] - es * 0.4, ey + es * 1.35, rot=-15),
                      rect(ex[1] + es * 0.4, ey + es * 1.2, ex[1] + es * 1.6, ey + es * 1.35, rot=15)]
        out.append(F("age_lines", lines, nose_mat, z - 0.05, kind="flat", opacity=0.55))
    j["eye_pts"] = [[ex[0], ey], [ex[1], ey]]
    return out


# ------------------------------------------------------------------ hair styles
def hair_bob(j, mat, view="3q", z_back=7.6, z_front=9.0, length=0.62):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    back = [ell(cx - w * 0.06, cy - hh * 0.1, w * 1.22, hh * 1.0),
            quad([(cx - w * 0.62, cy - hh * 0.1), (cx + w * 0.5, cy - hh * 0.1),
                  (cx + w * 0.48, cy + hh * length * 0.55), (cx - w * 0.66, cy + hh * length * 0.6)])]
    front = [icon("cloud", cx + w * 0.02, cy - hh * 0.33, w * 1.2, hh * 0.52),
             icon("droplet", cx + w * 0.3, cy - hh * 0.12, w * 0.28, hh * 0.36, flip="y", rot=-20),
             icon("droplet", cx - w * 0.36, cy + hh * 0.05, w * 0.32, hh * 0.62, flip="y", rot=8)]
    return [F("hair_back", back, mat, z_back), F("hair_front", front, mat, z_front,
                                                 shade={"highlight_amount": 0.6, "highlight": 0.9})]


def hair_short_back(j, mat, grey=None, view="3q", z=9.0, recede=0.0):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    top = [ell(cx - w * 0.06, cy - hh * 0.31, w * 1.06, hh * 0.46),
           ell(cx - w * 0.38, cy - hh * 0.1, w * 0.36, hh * 0.44)]
    if view != "3q":
        top.append(ell(cx + w * 0.38, cy - hh * 0.1, w * 0.36, hh * 0.44))
    if recede:  # M-shaped hairline: two small bites at the temples
        top.append(ell(cx + w * 0.22, cy - hh * 0.36, w * 0.22 * recede, hh * 0.12, op="sub"))
        top.append(ell(cx - w * 0.12, cy - hh * 0.37, w * 0.18 * recede, hh * 0.1, op="sub"))
    out = [F("hair", top, mat, z, shade={"highlight_amount": 0.5})]
    if grey:
        gp = [ell(cx - w * 0.4, cy - hh * 0.02, w * 0.14, hh * 0.2)]
        if view != "3q":
            gp.append(ell(cx + w * 0.4, cy - hh * 0.02, w * 0.14, hh * 0.2))
        out.append(F("hair_grey", gp, grey, z + 0.05, kind="flat", opacity=0.85, clip_to="hair"))
    return out


def hair_bald_sides(j, mat, view="3q", z=9.0):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    if view == "3q":
        pcs = [ell(cx - w * 0.36, cy - hh * 0.04, w * 0.34, hh * 0.3), ell(cx - w * 0.2, cy + hh * 0.06, w * 0.24, hh * 0.2)]
    else:
        pcs = [ell(cx - w * 0.44, cy - hh * 0.06, w * 0.2, hh * 0.3), ell(cx + w * 0.44, cy - hh * 0.06, w * 0.2, hh * 0.3)]
    return [F("hair", pcs, mat, z, shade={"highlight_amount": 0.4})]


def hair_ponytail(j, mat, view="3q", z_back=7.6, z_front=9.0):
    hh = j["hh"]
    cx, cy = j["head"]
    w = j.get("face_w", hh * 0.72)
    return [F("hair_tail", [icon("droplet", cx - w * 0.72, cy + hh * 0.1, w * 0.36, hh * 0.9, flip="y", rot=24)],
              mat, z_back - 0.1),
            F("hair_back", [ell(cx - w * 0.04, cy - hh * 0.12, w * 1.12, hh * 0.9)], mat, z_back),
            F("hair_front", [icon("cloud", cx + w * 0.02, cy - hh * 0.36, w * 1.12, hh * 0.44),
                             icon("droplet", cx + w * 0.26, cy - hh * 0.18, w * 0.2, hh * 0.28, flip="y", rot=-24)],
              mat, z_front, shade={"highlight_amount": 0.6})]


def coat_panels(j, H, mat, z=5.0, hem_y=None, gap=0.045, flare=0.2, split=0.56):
    """Open long coat: a screen-left and a screen-right panel hanging from the
    shoulders; the clothes under it show through the front gap.  ``split`` =
    where the gap sits from the left (0) to the right (1) shoulder; a 3/4 view
    facing right puts it right of centre."""
    sl, sr = _lr(j, "sh")
    pel = j["pelvis"]
    hem_y = pel[1] + H * 0.2 if hem_y is None else hem_y
    gx_top = sl[0] + (sr[0] - sl[0]) * split
    gx_hem = pel[0] + (split - 0.5) * H * 0.2
    g = H * gap
    ny = j["neck"][1] + H * 0.012
    left = quad([(sl[0] - H * 0.012, sl[1] - H * 0.008), (gx_top - g * 0.2, ny),
                 (gx_hem - g * 0.5, hem_y), (pel[0] - H * flare * 0.6, hem_y + H * 0.004),
                 (sl[0] - H * 0.035, (sl[1] + hem_y) / 2)])
    right = quad([(gx_top + g * 0.2, ny), (sr[0] + H * 0.012, sr[1] - H * 0.008),
                  (sr[0] + H * 0.035, (sr[1] + hem_y) / 2), (pel[0] + H * flare * 0.6, hem_y + H * 0.004),
                  (gx_hem + g * 0.5, hem_y)])
    return [F("coat_left", [left], mat, z, tags=["body"]), F("coat_right", [right], mat, z + 0.01, tags=["body"])]
