"""Stage 01 characters (13A-1 identity points; one person, one state, one pose each)."""

from __future__ import annotations

from g06kit import F, box, ell, icon, lerp, limb, quad, recipe, rect, rot_to, shadow
from g06kit import person as P
from s01_common import PAL, PAL_CCTV, PPM, asset

SPRITE_NOTE = " Transparent cut-out at the stage scale (320 px/m); contact shadow in _shadow.png."


# ------------------------------------------------------------------ Mira Ben
def bandage_eyes(j, z=10.5):
    """Emergency bandage wound around the head at eye level (both eyes covered)."""
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    band = [quad([(cx - w * 0.56, cy - hh * 0.12), (cx + w * 0.58, cy - hh * 0.16),
                  (cx + w * 0.6, cy + hh * 0.1), (cx - w * 0.55, cy + hh * 0.13)])]
    wraps = [box(cx + w * 0.05, cy - hh * 0.02, w * 1.1, hh * 0.035, rot=-8),
             box(cx - w * 0.05, cy + hh * 0.06, w * 1.0, hh * 0.03, rot=6)]
    knot = [icon("droplet", cx - w * 0.62, cy + hh * 0.06, hh * 0.16, hh * 0.3, rot=-120),
            icon("droplet", cx - w * 0.6, cy + hh * 0.14, hh * 0.13, hh * 0.26, rot=-60)]
    return [F("bandage", band, "bandage", z), F("bandage_wraps", wraps, "gauze", z + 0.05, kind="flat", opacity=0.55),
            F("bandage_knot", knot, "bandage", z - 1.6)]


def mira_body(j, H, view="3q", bandaged=False, eyes="open", pins=True, sleeve_stain=False, seated=False,
              near_arm=True, far_arm=True):
    f = []
    f += P.legs(j, H, "trouser", "shoe_black", width=0.064, far_mat="trouser", shoe_len=0.095)
    f += [F("knit", [quad(P._torso_poly(j, H, top_w_scale=1.0, waist=0.3, hem=j["pelvis"][1] + H * 0.03,
                                        hem_w=H * 0.15))], "knit_green", 4.0, tags=["body"])]
    f += [F("collar", [quad([(j["neck"][0] - H * 0.045, j["neck"][1] + H * 0.005),
                             (j["neck"][0] + H * 0.05, j["neck"][1] + H * 0.005),
                             (j["neck"][0] + H * 0.012, j["neck"][1] + H * 0.05)])], "collar_cream", 4.3)]
    hem = j["pelvis"][1] + (H * 0.035 if seated else H * 0.19)
    f += P.coat_panels(j, H, "labcoat", z=5.0, hem_y=hem, gap=0.05, flare=0.12 if seated else 0.2)
    if far_arm:
        f += P.arm(j, H, "f", "labcoat", "skin_light", 2.0, width=0.05)
    if near_arm:
        f += P.arm(j, H, "n", "labcoat", "skin_light", 6.0, width=0.05)
    if sleeve_stain:  # disinfectant stain on the green knit cuff showing under the near coat sleeve
        c = lerp(j["el_n"], j["wr_n"], 0.86)
        f += [F("cuff_knit", [ell(c[0], c[1], H * 0.05, H * 0.03, rot=rot_to(j["el_n"], j["wr_n"]))],
                "knit_green", 6.05),
              F("sleeve_stain", [icon("metaballs", c[0], c[1] - H * 0.004, H * 0.05, H * 0.03)], "@stain_disinfect",
                6.08, kind="flat", opacity=0.7)]
    f += P.neck(j, H, "skin_light", z=4.2)
    f += P.head(j, H, "skin_light", view, jaw=0.82, width=0.7)
    f += P.ear(j, H, "skin_light", view)
    f += P.face(j, H, view, eyes="none" if bandaged else eyes, brow_tilt=2, lid="@under_eye", eye_size=0.95,
                brow_mat="hair_brown")
    f += P.hair_bob(j, "hair_brown", view)
    if bandaged:
        f += bandage_eyes(j)
    if pins:  # two parallel silver pins behind the (visible) ear: 13A-1 fixed element
        hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
        f += [F("pins", [box(cx - w * 0.42, cy - hh * 0.07, hh * 0.3, hh * 0.035, rot=-28),
                         box(cx - w * 0.4, cy + hh * 0.02, hh * 0.3, hh * 0.035, rot=-28)], "silver", 9.5,
                line={"width": 0.6, "heavy": 0.5})]
    return f


@asset("chr_s01_mira_seated_injured")
def mira_seated():
    H = 1.64 * PPM
    g = (150, 392)
    j = P.pose_sit_floor(g, H, "3q", lean_back=14)
    forms = [shadow("shadow", [ell(g[0] + H * 0.14, g[1] - 4, H * 0.62, H * 0.08)], 0.35, 5)]
    forms += mira_body(j, H, "3q", bandaged=True, pins=True, sleeve_stain=True, seated=True)
    return recipe("chr_s01_mira_seated_injured", forms, (420, 420), g, PAL, style="sprite", seed=12,
                  pivot_meaning="floor contact under the seat (source px of the mirrored frame)",
                  note="Mira Ben, Stage 1 region A after the injury: seated on the floor leaning back against the "
                       "bench, both eyes bandaged, disinfectant stain on the green knit cuff, left hand on the knee "
                       "(obj_s01_lens_case_broken goes in it), right hand down on the floor. Faces screen-left so the "
                       "two silver pins behind the LEFT ear show (13A-1 fixed element)." + SPRITE_NOTE,
                  frames=[{"name": "chr_s01_mira_seated_injured", "mirror": True}])



@asset("chr_s01_mira_cctv_0134")
def mira_cctv():
    """01:34 booth-camera pose: eyes open, looking past the board, far (left) hand
    feeling the magnets.  CCTV grey-green palette, at the frame's 350 px/m."""
    H = 1.64 * 350.0
    g = (170, 628)
    j = P.pose_stand(g, H, "3q")
    P.set_arm(j, "f", [j["sh_f"][0] + H * 0.09, j["sh_f"][1] + H * 0.06], [j["sh_f"][0] + H * 0.14, j["sh_f"][1] - H * 0.07])
    P.set_arm(j, "n", [j["sh_n"][0] - H * 0.01, j["sh_n"][1] + H * 0.17], [j["sh_n"][0] + H * 0.03, j["sh_n"][1] + H * 0.3])
    forms = [shadow("shadow", [ell(g[0], g[1] - 3, H * 0.34, H * 0.06)], 0.35, 4)]
    forms += mira_body(j, H, "3q", eyes="unfocused", pins=False)
    return recipe("chr_s01_mira_cctv_0134", forms, (400, 660), g, PAL_CCTV, style="sprite", seed=13,
                  pivot_meaning="ground point between the feet; scene_s01_cctv_frame.json puts it on cu_s01_cctv_view",
                  note="VISUAL 1 / hinge A: Mira at 01:34 in the booth-camera frame, both eyes open and whole, gaze "
                       "past the board, left hand raised feeling the magnets (tactile strategy). Faces screen-right "
                       "(the camera sees her right side, so the pins behind the left ear are hidden). CCTV grey-green "
                       "palette." + SPRITE_NOTE)


# ------------------------------------------------------------------ Thomas Grell
def grell_body(j, H, view="3q", bloody=True, kneel=False):
    f = []
    f += P.legs(j, H, "trouser_greybrown", "shoe_brown", width=0.06, shoe_len=0.1)
    f += [F("shirt", [quad(P._torso_poly(j, H, waist=0.28, hem=j["pelvis"][1] + H * 0.02, hem_w=H * 0.15))],
            "shirt_white", 4.0, tags=["body"])]
    sl, sr = P._lr(j, "sh")
    vest = quad([(sl[0] + H * 0.012, sl[1] + H * 0.01), (j["neck"][0] - H * 0.01, j["neck"][1] + H * 0.035),
                 (j["neck"][0] + H * 0.018, j["chest"][1] + H * 0.06), (j["neck"][0] + H * 0.045, j["neck"][1] + H * 0.035),
                 (sr[0] - H * 0.01, sr[1] + H * 0.01), (j["pelvis"][0] + H * 0.075, j["pelvis"][1] + H * 0.01),
                 (j["pelvis"][0] - H * 0.075, j["pelvis"][1] + H * 0.012)])
    f.append(F("vest", [vest], "vest_navy", 4.5, tags=["body"]))
    # three parallel pens in the shirt pocket above the vest edge (13A-1 fixed element)
    px, py = j["chest"][0] - H * 0.035, j["chest"][1] - H * 0.015
    pens = [rect(px + i * H * 0.013, py - H * 0.03, px + i * H * 0.013 + H * 0.008, py + H * 0.012) for i in range(3)]
    f.append(F("pens", pens, "plastic_black", 4.8, kind="flat", line={"width": 0.5, "heavy": 0.5}))
    f.append(F("pen_caps", [rect(px + i * H * 0.013, py - H * 0.036, px + i * H * 0.013 + H * 0.008, py - H * 0.026)
                            for i in range(3)], "brass", 4.81, kind="flat"))
    f.append(F("pen_cap_colors", [rect(px + H * 0.013, py - H * 0.036, px + H * 0.021, py - H * 0.026)], "ink_red",
               4.82, kind="flat"))
    f.append(F("pen_cap_blue", [rect(px + H * 0.026, py - H * 0.036, px + H * 0.034, py - H * 0.026)], "ink_blue", 4.83,
               kind="flat"))
    f += P.arm(j, H, "f", "shirt_white", "skin_mid", 2.0, width=0.05, hand=0.055)
    f += P.arm(j, H, "n", "shirt_white", "skin_mid", 6.0, width=0.05, hand=0.055)
    if bloody:
        for side, z in (("f", 2.2), ("n", 6.2)):
            hc = j["hand_" + side]
            f.append(F("blood_" + side, [icon("metaballs", hc[0], hc[1], H * 0.05, H * 0.045),
                                         icon("sponge", hc[0] + H * 0.005, hc[1] - H * 0.02, H * 0.03, H * 0.03)],
                       "blood", z, kind="flat", clip_to="hand_" + side, opacity=0.9))
    f += P.neck(j, H, "skin_mid", z=4.2, w=0.05)
    f += P.head(j, H, "skin_mid", view, jaw=0.95, width=0.62)
    f += P.ear(j, H, "skin_mid", view)
    f += P.face(j, H, view, eyes="open", brow_tilt=-3, eye_size=0.8, brow_mat="hair_greybrown", mouth="tense",
                age_lines=1)
    f += P.hair_short_back(j, "hair_greybrown", grey="hair_grey", view=view, recede=1.0)
    # thin metal glasses
    ex = j["eye_pts"]
    r = j["hh"] * 0.11
    f.append(F("glasses", [icon("ring", ex[0][0], ex[0][1], r * 2.3 * 0.8, r * 2.0), icon("ring", ex[1][0], ex[1][1],
                                                                                           r * 2.3, r * 2.0),
                           rect(ex[0][0] + r * 0.9, ex[0][1] - r * 0.2, ex[1][0] - r * 1.1, ex[0][1] + r * 0.05)],
               "steel", 10.6, kind="flat", line={"width": 0.4, "heavy": 0.4}))
    return f


@asset("chr_s01_grell_tending")
def grell_tending():
    H = 1.77 * PPM
    g = (230, 520)
    j = P.pose_kneel(g, H, "3q")
    forms = [shadow("shadow", [ell(g[0], g[1] - 4, H * 0.5, H * 0.07)], 0.35, 5)]
    forms += grell_body(j, H, "3q", bloody=True, kneel=True)
    return recipe("chr_s01_grell_tending", forms, (440, 560), g, PAL, style="sprite", seed=14,
                  pivot_meaning="floor point under the kneeling knee/foot pair (source px of the mirrored frame)",
                  note="Thomas Grell, region A: kneels on one knee sorting the first-aid box with blood on both hands "
                       "(A4). Long thin face, thin metal glasses, navy knit vest over a white shirt, three parallel "
                       "pens, grey temples, receding hairline (13A-1). Faces screen-left toward Mira." + SPRITE_NOTE,
                  frames=[{"name": "chr_s01_grell_tending", "mirror": True}])


# ------------------------------------------------------------------ Ed Faro
def ed_body(j, H, view="front"):
    f = []
    f += P.legs(j, H, "trouser_greyblue", "shoe_black", width=0.07, shoe_len=0.1, facing=0)
    f += [F("shirt", [quad(P._torso_poly(j, H, waist=0.4, hem=j["pelvis"][1] + H * 0.03, hem_w=H * 0.21))],
            "uniform_grey", 4.0, tags=["body"])]
    sl, sr = P._lr(j, "sh")
    f.append(F("pockets", [rect(j["chest"][0] - H * 0.07, j["chest"][1] - H * 0.01, j["chest"][0] - H * 0.025,
                                j["chest"][1] + H * 0.04),
                           rect(j["chest"][0] + H * 0.025, j["chest"][1] - H * 0.01, j["chest"][0] + H * 0.07,
                                j["chest"][1] + H * 0.04)], "uniform_grey", 4.1, kind="flat", color="#4c4d4a",
               line={"width": 0.7, "heavy": 0.7}))
    f.append(F("belt", [rect(j["pelvis"][0] - H * 0.11, j["pelvis"][1] - H * 0.035, j["pelvis"][0] + H * 0.11,
                             j["pelvis"][1] - H * 0.01)], "leather_black", 4.3, kind="flat", line={"width": 0.8, "heavy": 0.8}))
    f.append(F("buckle", [rect(j["pelvis"][0] - H * 0.015, j["pelvis"][1] - H * 0.037, j["pelvis"][0] + H * 0.015,
                               j["pelvis"][1] - H * 0.008)], "brass", 4.31, kind="flat"))
    # big key ring on the right hip (screen-left in front view): 13A-1 fixed element
    kx, ky = j["hip_n"][0] - H * 0.075, j["pelvis"][1] + H * 0.01
    f.append(F("keyring", [icon("ring", kx, ky, H * 0.06, H * 0.06)], "brass", 6.5, line={"width": 0.7, "heavy": 0.7}))
    keys = [icon("key", kx - H * 0.01 + i * H * 0.012, ky + H * 0.045, H * 0.02, H * 0.06, rot=-20 + i * 14)
            for i in range(4)]
    f.append(F("keys", keys, "brass", 6.6, line={"width": 0.6, "heavy": 0.6}))
    f += P.arm(j, H, "f", "uniform_grey", "skin_old", 2.0, width=0.058, hand=0.055)
    f += P.arm(j, H, "n", "uniform_grey", "skin_old", 6.0, width=0.058, hand=0.055)
    # small torch in the left hand (screen-right)
    hc = j["hand_f"]
    f.append(F("torch", [rect(hc[0] - H * 0.012, hc[1] - H * 0.01, hc[0] + H * 0.012, hc[1] + H * 0.07)], "metal_dark",
               2.3, line={"width": 0.7, "heavy": 0.7}))
    f.append(F("torch_lens", [ell(hc[0], hc[1] + H * 0.072, H * 0.03, H * 0.012)], "glass_clear", 2.31, kind="flat"))
    f += P.neck(j, H, "skin_old", z=4.2, w=0.07)
    f += P.head(j, H, "skin_old", view, jaw=1.08, width=0.74)
    f += P.ear(j, H, "skin_old", view)
    f += P.face(j, H, view, eyes="open", brow_tilt=-2, eye_size=0.65, brow_mat="hair_white", mouth="flat", age_lines=2)
    f += P.hair_bald_sides(j, "hair_white", view)
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    f.append(F("stubble", [ell(cx - w * 0.22, cy + hh * 0.24, w * 0.22, hh * 0.16)], "@joint_dark", 10.2, kind="flat",
               opacity=0.18))
    return f


@asset("chr_s01_ed_door")
def ed_door():
    H = 1.70 * PPM
    g = (190, 600)
    j = P.pose_stand(g, H, "front", lean=0.05)
    forms = [shadow("shadow", [ell(g[0], g[1] - 3, H * 0.36, H * 0.06)], 0.35, 4)]
    forms += ed_body(j, H, "front")
    return recipe("chr_s01_ed_door", forms, (380, 630), g, PAL, style="sprite", seed=15,
                  pivot_meaning="ground point between the feet",
                  note="Ed Faro, region A: stands at the corridor door facing into the room. Slight stoop, grey-white "
                       "side hair, square jaw, grey uniform shirt, grey-blue trousers, worn black belt, big key ring "
                       "on the right hip, small torch (13A-1)." + SPRITE_NOTE)


# ------------------------------------------------------------------ Lina Orr (portrait only in Stage 01)
def lina_body(j, H, view="3q"):
    f = []
    f += [F("blouse", [quad(P._torso_poly(j, H, waist=0.28, hem=j["pelvis"][1] + H * 0.02, hem_w=H * 0.15))],
            "shirt_white", 4.0)]
    f += P.coat_panels(j, H, "cardigan_beige", z=5.0, hem_y=j["pelvis"][1] + H * 0.06, gap=0.06, flare=0.14)
    f += P.arm(j, H, "f", "cardigan_beige", "skin_light", 2.0, width=0.046)
    f += P.arm(j, H, "n", "cardigan_beige", "skin_light", 6.0, width=0.046)
    f += P.neck(j, H, "skin_light", z=4.2, w=0.045)
    n = j["neck"]
    f.append(F("scarf", [ell(n[0], n[1] + H * 0.01, H * 0.12, H * 0.045),
                         icon("bookmark", n[0] + H * 0.03, n[1] + H * 0.07, H * 0.035, H * 0.1, rot=-8)], "cloth_red", 7.6))
    f += P.head(j, H, "skin_light", view, jaw=0.78, width=0.74)
    f += P.ear(j, H, "skin_light", view)
    f += P.face(j, H, view, eyes="open", brow_tilt=1, eye_size=1.2, brow_mat="hair_black", mouth="flat")
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    f.append(F("mole", [ell(cx + w * 0.16, cy + hh * 0.33, hh * 0.025, hh * 0.025)], "@ink", 10.3, kind="flat"))
    f += P.hair_ponytail(j, "hair_black", view)
    return f


# ------------------------------------------------------------------ portraits (320x320, face at a fixed spot)
PORTRAIT_HEAD = (160, 132)   # head centre in every portrait
PORTRAIT_HH = 150.0          # head height in px


def _portrait_joints(view="3q"):
    H = PORTRAIT_HH * P.HEAD_RATIO
    g0 = (160, 400)
    j = P.pose_stand(g0, H, view)
    dx, dy = PORTRAIT_HEAD[0] - j["head"][0], PORTRAIT_HEAD[1] - j["head"][1]
    g = (g0[0] + dx, g0[1] + dy)
    j = P.pose_stand(g, H, view)
    return j, H


def _portrait(asset_id, body_fn, note, view="3q", mirror=False, **kw):
    j, H = _portrait_joints(view)
    forms = body_fn(j, H, view, **kw)
    frames = [{"name": asset_id, "mirror": True}] if mirror else None
    return recipe(asset_id, forms, (320, 320), PORTRAIT_HEAD, PAL, style="sprite", seed=31, frames=frames,
                  pivot_meaning="head centre (same pixel in every portrait)",
                  note=note + " 3/4 bust, 320x320 transparent; head centre at (160,132), head height 150 px in every "
                              "g06 portrait.")


@asset("por_s01_mira")
def por_mira():
    return _portrait("por_s01_mira", mira_body, "Mira Ben before the incident (identity plate: short brown bob, two "
                     "silver pins behind the left ear, leaf-green knit, white lab coat).", mirror=True, pins=True)


@asset("por_s01_grell")
def por_grell():
    return _portrait("por_s01_grell", grell_body, "Thomas Grell (long face, thin metal glasses, navy vest, three pens).",
                     bloody=False)


@asset("por_s01_ed")
def por_ed():
    return _portrait("por_s01_ed", ed_body, "Ed Faro (grey-white side hair, square jaw, grey uniform).", view="front")


@asset("por_s01_lina")
def por_lina():
    return _portrait("por_s01_lina", lina_body, "Lina Orr (dull red scarf, black ponytail, mole below the right lip, "
                     "beige cardigan).", mirror=True)
