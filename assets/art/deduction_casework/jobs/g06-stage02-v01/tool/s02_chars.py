"""Stage 02 characters (13A-1 Stage 2 identity points, mourning evening)."""

from __future__ import annotations

from g06kit import F, box, ell, icon, lerp, limb, quad, recipe, rect, shadow
from g06kit import person as P
from g06kit.outfits import figure, pose_sit_chair
from g06kit.portrait import portrait
from s02_common import PAL, PAL_SEPIA, PPM, asset

NOTE = " Transparent cut-out at the stage scale (320 px/m); contact shadow in _shadow.png."


# ------------------------------------------------------------------ accessories
def penlight(j, H):
    n = j["neck"]
    c = j["chest"]
    return [F("penlight_cord", limb((n[0] - H * 0.03, n[1] + H * 0.01), (c[0] + H * 0.005, c[1] + H * 0.04), 2.5, 2.5) +
              limb((n[0] + H * 0.035, n[1] + H * 0.01), (c[0] + H * 0.01, c[1] + H * 0.04), 2.5, 2.5), "@ink", 7.0,
              kind="flat"),
            F("penlight", [box(c[0] + H * 0.008, c[1] + H * 0.07, H * 0.012, H * 0.06, rot=6)], "silver", 7.1,
              line={"width": 0.5, "heavy": 0.5})]


def ledger_clip(j, H):
    p = j["pelvis"]
    return [F("ledger_clip", [box(p[0] + H * 0.05, p[1] - H * 0.03, H * 0.014, H * 0.05)], "silver", 7.2,
              line={"width": 0.5, "heavy": 0.5})]


def key_brooch(j, H):
    c = j["chest"]
    return [F("brooch", [icon("key", c[0] + H * 0.035, c[1] - H * 0.02, H * 0.018, H * 0.04, rot=30)], "silver", 7.2,
              line={"width": 0.4, "heavy": 0.4})]


def mole_under_eye(side=0):
    def ex(j, H):
        e = j["eye_pts"][side]
        return [F("mole", [ell(e[0], e[1] + j["hh"] * 0.1, j["hh"] * 0.022, j["hh"] * 0.022)], "@ink", 10.5, kind="flat")]
    return ex


def safe_key_necklace(j, H):
    n = j["neck"]
    c = j["chest"]
    return [F("key_chain", limb((n[0] - H * 0.03, n[1] + H * 0.01), (c[0], c[1] + H * 0.02), 2, 2) +
              limb((n[0] + H * 0.035, n[1] + H * 0.01), (c[0], c[1] + H * 0.02), 2, 2), "silver", 7.0, kind="flat"),
            F("safe_key", [icon("key", c[0], c[1] + H * 0.045, H * 0.02, H * 0.05)], "brass", 7.1,
              line={"width": 0.4, "heavy": 0.4})]


def pharmacy_bag(j, H):
    w = j["wr_n"]
    return [F("pharmacy_bag", [quad([(w[0] - H * 0.02, w[1] - H * 0.06), (w[0] + H * 0.015, w[1] - H * 0.065),
                                     (w[0] + H * 0.02, w[1] - H * 0.01), (w[0] - H * 0.018, w[1] - H * 0.005)])],
              "paper_cream", 6.02, line={"width": 0.6, "heavy": 0.6})]


def cufflink(j, H):
    w = j["wr_f"]
    return [F("cufflink", [ell(w[0], w[1] - H * 0.012, H * 0.012, H * 0.012)], "brass", 2.5,
              line={"width": 0.4, "heavy": 0.4})]


def jaw_scar(j, H):
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    return [F("scar", [box(cx - w * 0.28, cy + hh * 0.3, hh * 0.1, hh * 0.018, rot=-30)], "@eye_white", 10.5, kind="flat",
              opacity=0.8)]


def nose_spot(j, H):
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    return [F("age_spot", [ell(cx + w * 0.12, cy + hh * 0.06, hh * 0.03, hh * 0.025)], "@soot", 10.5, kind="flat",
              opacity=0.6)]


def apron_hook(j, H):
    p = j["pelvis"]
    return [F("apron_hook", [icon("ring", p[0] - H * 0.07, p[1] - H * 0.01, H * 0.035, H * 0.035)], "silver", 7.3,
              line={"width": 0.5, "heavy": 0.5})]


def droop_lid(j, H):
    e = j["eye_pts"][0]
    return [F("droop", [rect(e[0] - j["hh"] * 0.07, e[1] - j["hh"] * 0.06, e[0] + j["hh"] * 0.07, e[1] - j["hh"] * 0.01)],
              "skin_old", 10.3, kind="flat")]


def front_strand(j, H):
    hh, (cx, cy), w = j["hh"], j["head"], j["face_w"]
    return [F("strand", [icon("droplet", cx + w * 0.22, cy - hh * 0.12, hh * 0.08, hh * 0.3, flip="y", rot=-14)],
              "hair_chestnut", 9.3)]


# ------------------------------------------------------------------ specs
HELEN = {"skin": "skin_light", "dress": "mourning_black", "top": "mourning_black", "legs": "stocking_dark",
         "shoes": "shoe_black", "hair": ("bob", "hair_chestnut", {"length": 0.5}), "brows": "hair_chestnut",
         "brow_tilt": -4, "mouth": "flat", "jaw": 0.9, "face_w": 0.68, "extras": [penlight], "dress_hem": 0.36,
         "collar": "shirt_white"}
LUCA = {"skin": "skin_light", "trousers": "suit_brown", "top": "blouse_cream", "jacket": ("suit_brown", 0.1),
        "shoes": "shoe_brown", "hair": ("short", "hair_chestnut", {}), "brows": "hair_chestnut", "tie": "mourning_black",
        "mouth": "tense", "jaw": 0.92, "extras": [front_strand, pharmacy_bag, cufflink], "lid": "@under_eye"}
EVA = {"skin": "skin_light", "dress": "dress_navy", "top": "dress_navy", "legs": "stocking_dark", "shoes": "shoe_black",
       "jacket": ("cardigan_greybrown", 0.04), "hair": ("bun", "hair_chestnut", {}), "brows": "hair_chestnut",
       "eye_size": 0.8, "extras": [ledger_clip, key_brooch, mole_under_eye(0)], "dress_hem": 0.42}
SILLA = {"skin": "skin_mid", "trousers": "stocking_dark", "top": "blouse_cream", "jacket": ("jacket_plum", 0.06),
         "skirt": ("skirt_dark", 0.26), "shoes": "shoe_black", "hair": ("wave", "hair_auburn_grey", {}),
         "brows": "hair_auburn_grey", "glasses": "square", "jaw": 1.0, "face_w": 0.74, "extras": [safe_key_necklace],
         "leg_w": 0.07}
YONA = {"skin": "skin_old", "dress": "mourning_black", "top": "mourning_black", "legs": "stocking_dark",
        "shoes": "shoe_black", "coat": ("mourning_black", 0.3, False), "hair": ("bun", "hair_greyish_brown", {}),
        "brows": "hair_greyish_brown", "age": 2, "jaw": 0.85, "face_w": 0.64, "hat": ("net", "mourning_black"),
        "hands": "glove_grey", "extras": [nose_spot]}
PETER = {"skin": "skin_old", "trousers": "suit_brown", "top": "shirt_white", "vest": "vest_darkbrown",
         "apron": "apron_black", "shoes": "shoe_black", "hair": ("short", "hair_silver", {}), "brows": "hair_silver",
         "mustache": "hair_silver", "age": 2, "jaw": 1.0, "face_w": 0.64, "extras": [apron_hook, droop_lid]}
OSWALD = {"skin": "skin_old", "trousers": "suit_threepiece", "top": "shirt_white", "vest": "suit_threepiece",
          "jacket": ("suit_threepiece", 0.12), "tie": "tie_green", "shoes": "shoe_black",
          "hair": ("short", "hair_silver", {}), "brows": "hair_silver", "glasses": "gold", "age": 2, "face_w": 0.64,
          "jaw": 0.95, "extras": [jaw_scar]}


def _stand(asset_id, spec, h_m, note, mirror=False, view="3q", arms=None, seed=20, canvas=(380, 640)):
    H = h_m * PPM
    g = (canvas[0] / 2, canvas[1] - 28)
    j = P.pose_stand(g, H, view)
    if arms:
        arms(j, H)
    forms = [shadow("shadow", [ell(g[0], g[1] - 3, H * 0.34, H * 0.06)], 0.35, 4)] + figure(j, H, view, spec)
    frames = [{"name": asset_id, "mirror": True}] if mirror else None
    return recipe(asset_id, forms, canvas, g, PAL, style="sprite", seed=seed, frames=frames,
                  pivot_meaning="ground point between the feet", note=note + NOTE)


def _arms_hands_folded(j, H):
    c = j["pelvis"]
    P.set_arm(j, "n", [j["sh_n"][0] - H * 0.01, j["sh_n"][1] + H * 0.16], [c[0] - H * 0.02, c[1] - H * 0.03])
    P.set_arm(j, "f", [j["sh_f"][0] + H * 0.01, j["sh_f"][1] + H * 0.16], [c[0] + H * 0.02, c[1] - H * 0.035])


def _arms_behind(j, H):  # Peter: left hand hidden behind the back
    P.set_arm(j, "f", [j["sh_f"][0] + H * 0.015, j["sh_f"][1] + H * 0.15], [j["pelvis"][0] + H * 0.03, j["pelvis"][1] - H * 0.02])


@asset("chr_s02_helen_stand")
def helen():
    return _stand("chr_s02_helen_stand", HELEN, 1.70, "Helen Morren, dining room: black mourning dress, doctor's "
                  "penlight on a cord (13A-1 fixed), chin-length chestnut bob, straight brows, upright.", mirror=True,
                  arms=_arms_hands_folded, seed=21)


@asset("chr_s02_luca_stand")
def luca():
    return _stand("chr_s02_luca_stand", LUCA, 1.78, "Luca Morren, dining room: dark brown mourning suit, falling front "
                  "strand, one ornate cufflink, pharmacy paper bag in the right sleeve pocket (B4 hotspot).", seed=22)


@asset("chr_s02_eva_stand")
def eva():
    return _stand("chr_s02_eva_stand", EVA, 1.66, "Eva Morren, dining room: navy dress + grey-brown cardigan, low "
                  "chignon, mole under the left eye, silver ledger clip at the waist, key brooch (VISUAL 2).",
                  mirror=True, arms=_arms_hands_folded, seed=23)


@asset("chr_s02_peter_stand")
def peter():
    return _stand("chr_s02_peter_stand", PETER, 1.75, "Peter Rohn, butler's room: dark brown vest, white shirt, black "
                  "apron with the big apron hook on the left, drooping grey moustache, long nose, left hand behind the "
                  "back, upright.", arms=_arms_behind, seed=24)


@asset("chr_s02_silla_slumped")
def silla():
    H = 1.60 * PPM
    g = (200, 470)
    j = pose_sit_chair(g, H, "3q", seat=0.42, slump=1.0)
    forms = [shadow("shadow", [ell(g[0] + H * 0.1, g[1] - 4, H * 0.5, H * 0.07)], 0.3, 5)]
    spec = dict(SILLA, eyes="closed", mouth="open", seated=True)
    forms += figure(j, H, "3q", spec)
    return recipe("chr_s02_silla_slumped", forms, (460, 500), g, PAL, style="sprite", seed=25,
                  pivot_meaning="floor point under the seat front (on obj_s02_sofa)",
                  note="Silla Beck, study (C1): drugged, slumped sideways on the sofa, eyes closed, mouth open, arms "
                       "limp. Plum jacket, cream blouse, square glasses, short auburn-grey wave, safe-key necklace." + NOTE)


# ------------------------------------------------------------------ portraits
def _p(asset_id, spec, note, mirror=False, view="3q", palette=PAL):
    return portrait(asset_id, lambda j, H, v: figure(j, H, v, spec), note, palette, view=view, mirror=mirror)


@asset("por_s02_oswald")
def por_oswald():
    return _p("por_s02_oswald", OSWALD, "Oswald Morren (deceased; silver hair, small gold glasses, green tie, scar on the "
              "right jaw).")


@asset("por_s02_helen")
def por_helen():
    return _p("por_s02_helen", HELEN, "Helen Morren (bob, penlight).", mirror=True)


@asset("por_s02_luca")
def por_luca():
    return _p("por_s02_luca", LUCA, "Luca Morren (falling strand, brown suit).")


@asset("por_s02_eva")
def por_eva():
    return _p("por_s02_eva", EVA, "Eva Morren (chignon, mole, ledger clip).", mirror=True)


@asset("por_s02_silla")
def por_silla():
    return _p("por_s02_silla", SILLA, "Silla Beck (square glasses, plum jacket, safe-key necklace).")


@asset("por_s02_yona")
def por_yona():
    return _p("por_s02_yona", YONA, "Yona Pale (net mourning hat, age spot on the right side of the nose, old black "
              "mourning coat).", mirror=True)


@asset("por_s02_peter")
def por_peter():
    return _p("por_s02_peter", PETER, "Peter Rohn (grey moustache, long nose, dark brown vest, apron hook).")
