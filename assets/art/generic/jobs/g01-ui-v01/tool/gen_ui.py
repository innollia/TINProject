"""g01 UI recipes: window frames, buttons, gauges, cursors, selection corners, emotion balloons.

    py -3 -B gen_ui.py [--stage A|B|C|all] [--only ui_a,ui_b]

No letters anywhere: frames and bases only.  9-slice assets carry
``meta.nine_slice = [left, top, right, bottom]`` (px) in the recipe and the manifest;
edges between the corner cells are kept uniform so they stretch cleanly.
Balloon marks (! ? note ...) are built from shapes, not type.
"""

from __future__ import annotations

import argparse
import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g01kit import (C, D, F, MOON, P, POLY, R, RR, SPARK, STAR, animate, around, halo, ngon, rframe,  # noqa: E402
                    ringp, rrect, save, scale, shift, star_pts, sub, turn)

RDIR = Path(__file__).resolve().parents[1] / "recipes"
UI: list = []   # (stage, asset, note, fn) ; fn -> dict(forms, canvas, frames?, meta, pivot?)

DIAMOND = [(0.5, 0.0), (1.0, 0.5), (0.5, 1.0), (0.0, 0.5)]
L_SHAPE = [(0, 0), (1, 0), (1, 0.3), (0.3, 0.3), (0.3, 1), (0, 1)]


def ui(stage, asset, note):
    def deco(fn):
        UI.append((stage, asset, note, fn))
        return fn
    return deco


def corners(fn, w, h, inset):
    """fn(x, y, flip) for the four corners (flip '' / 'x' / 'y' / 'xy')."""
    return [fn(inset, inset, ""), fn(w - inset, inset, "x"), fn(inset, h - inset, "y"), fn(w - inset, h - inset, "xy")]


# ================================================================== A: frames
@ui("A", "ui_window_stone", "Basic window frame: dark bevelled stone band, bronze inner line, bronze corner diamonds with garnets, near-black panel.")
def window_stone():
    W = H = 192
    forms = [
        F("panel", None, [R(96, 96, 164, 164)], 0, "flat", color="ui_panel", opacity=0.93),
        F("band", "stone_dark", rframe(96, 96, 188, 188, 18, 12), 1, shade={"highlight_amount": 0.35}),
        F("inner_line", "bronze", rframe(96, 96, 150, 150, 2, 3), 2, "flat", opacity=0.85),
        F("outer_line", "bronze", rframe(96, 96, 182, 182, 1.5, 9), 2, "flat", opacity=0.45),
        F("corner_plates", "bronze", corners(lambda x, y, f: POLY(DIAMOND, x, y, 32, 32), W, H, 17), 3),
        F("corner_gems", "gem_red", corners(lambda x, y, f: C(x, y, 10, 10), W, H, 17), 4),
    ]
    return {"forms": forms, "canvas": (W, H), "meta": {"kind": "ui_9slice", "nine_slice": [64, 64, 64, 64],
            "content_inset": 24, "preview_size": [520, 220]}}


@ui("A", "ui_dialogue_wood", "Dialogue box frame: black-stained wood band, iron L brackets with nails at the corners, warm dark panel.")
def dialogue_wood():
    W = H = 192
    brackets = corners(lambda x, y, f: POLY(L_SHAPE, x, y, 42, 42, flip=f or None), W, H, 22)
    nails = []
    for (x, y, sx, sy) in [(6, 6, 1, 1), (186, 6, -1, 1), (6, 186, 1, -1), (186, 186, -1, -1)]:
        nails += [C(x + sx * 34, y + sy * 5, 5), C(x + sx * 5, y + sy * 34, 5), C(x + sx * 7, y + sy * 7, 6)]
    forms = [
        F("panel", None, [R(96, 96, 166, 166)], 0, "flat", color="ui_panel_warm", opacity=0.93),
        F("band", "wood", rframe(96, 96, 186, 186, 16, 6), 1, shade={"highlight_amount": 0.3}),
        F("band_line", "wood_dark", rframe(96, 96, 160, 160, 1.5, 2), 1.5, "flat", opacity=0.8),
        F("brackets", "iron", brackets, 3, shade={"highlight_amount": 0.6}),
        F("nails", "steel", nails, 4),
    ]
    return {"forms": forms, "canvas": (W, H), "meta": {"kind": "ui_9slice", "nine_slice": [64, 64, 64, 64],
            "content_inset": 22, "preview_size": [640, 200]}}


@ui("A", "ui_button", "Button base in four states (normal, hover, pressed, disabled): bevelled plate, bronze or gold rim, no label.")
def button():
    W, H = 192, 96
    body = rrect(96, 48, 186, 86, 16)
    rim = rframe(96, 48, 186, 86, 3.5, 16)
    sheen = rrect(96, 26, 168, 18, 9)
    smooth = {"ragged": 0.04, "threshold": 0.3, "soft": 0.1, "bump": 0.55, "highlight_amount": 0.25}
    normal = [
        F("body", "button", body, 0, shade=smooth),
        F("sheen", None, sheen, 1, "flat", color="glint", clip_to="body", opacity=0.08),
        F("rim", "bronze", rim, 2),
    ]
    hover = [
        F("body", "button_hot", body, 0, shade=smooth),
        F("sheen", None, sheen, 1, "flat", color="glint", clip_to="body", opacity=0.12),
        F("glow_in", None, rframe(96, 48, 172, 72, 5, 10), 1.5, "flat", color="glow_gold", blur=3, clip_to="body",
          opacity=0.4),
        F("rim", "gold", rim, 2),
    ]
    pressed = [
        F("body", "button_dark", shift(body, 0, 2), 0, shade=smooth),
        F("inset", None, rrect(96, 14, 186, 26, 12), 1, "flat", color="void_violet", blur=4, clip_to="body",
          opacity=0.55),
        F("rim", "bronze", shift(rim, 0, 2), 2, shade={"highlight_amount": 0.2}),
    ]
    disabled = [
        F("body", "button_off", body, 0, shade=smooth),
        F("rim", "iron", rim, 2, shade={"highlight_amount": 0.2}),
    ]
    forms, frames = animate([normal, hover, pressed, disabled], "ui_button",
                            names=["ui_button_normal", "ui_button_hover", "ui_button_pressed", "ui_button_disabled"])
    return {"forms": forms, "frames": frames, "canvas": (W, H),
            "meta": {"kind": "ui_9slice", "nine_slice": [32, 32, 32, 32], "states": [f["name"] for f in frames],
                     "preview_size": [360, 96]}}


@ui("A", "ui_gauge_frame", "Gauge base, frame part: iron tube with capsule ends, dark channel with inner shadow, bronze end studs.")
def gauge_frame():
    W, H = 192, 48
    forms = [
        F("channel", None, rrect(96, 24, 178, 30, 15), 0, "flat", color="void_violet", opacity=0.95),
        F("channel_shadow", None, rrect(96, 13, 178, 10, 5), 0.5, "flat", color="#000000", blur=2,
          clip_to="channel", opacity=0.55),
        F("tube", "iron", rframe(96, 24, 188, 42, 6, 21), 1, shade={"highlight_amount": 0.65}),
        F("studs", "bronze", [C(7, 24, 8), C(185, 24, 8)], 2),
    ]
    return {"forms": forms, "canvas": (W, H), "meta": {"kind": "ui_9slice", "nine_slice": [24, 16, 24, 16],
            "fill_area": [9, 9, 174, 30], "preview_size": [420, 48]}}


@ui("A", "ui_gauge_fill", "Gauge base, fill part in four colours (red life, blue mana, green stamina, gold experience): glossy capsule.")
def gauge_fill():
    W, H = 192, 24
    body = rrect(96, 12, 188, 20, 10)
    frames_forms = []
    for mat, light in (("liquid_red", "liquid_red_light"), ("liquid_blue", "liquid_blue_light"),
                       ("liquid_green", "liquid_green_light"), ("liquid_gold", "liquid_gold_light")):
        frames_forms.append([
            F("fill", mat, body, 0, shade={"highlight_amount": 0.5, "bump": 0.8}),
            F("gloss", light, rrect(96, 7.5, 172, 4, 2), 1, "flat", clip_to="fill", opacity=0.55),
        ])
    forms, frames = animate(frames_forms, "ui_gauge_fill",
                            names=["ui_gauge_fill_red", "ui_gauge_fill_blue", "ui_gauge_fill_green", "ui_gauge_fill_gold"])
    return {"forms": forms, "frames": frames, "canvas": (W, H),
            "meta": {"kind": "ui_9slice", "nine_slice": [12, 6, 12, 6], "states": [f["name"] for f in frames],
                     "preview_size": [300, 24]}}


# ================================================================== A: cursors
@ui("A", "ui_cursor_gauntlet", "Pointing cursor: steel gauntlet pointing right, curled armoured fingers, bronze cuff. Hotspot at the fingertip.")
def cursor_gauntlet():
    W = H = 128
    forms = [
        F("fingers", "steel", [RR(82, 70, 18, 14), RR(81, 83, 17, 13), RR(77, 95, 15, 12)], 0,
          shade={"highlight_amount": 0.4}),
        F("knuckle_lines", "steel_dark", [R(82, 76.5, 16, 1.6), R(80, 89.5, 15, 1.6)], 0.5, "flat",
          clip_to="fingers", opacity=0.9),
        F("hand", "steel", rrect(54, 72, 46, 46, 14), 1),
        F("finger", "steel", [RR(88, 56, 38, 17), C(106, 56, 17, 17)], 2),
        F("finger_lines", "steel_dark", [R(90, 56, 1.6, 14), R(101, 56, 1.6, 13)], 2.2, "flat", clip_to="finger",
          opacity=0.85),
        F("thumb", "steel", [RR(64, 48, 28, 13, rot=-18)], 2.5),
        F("plates", "steel_dark", [R(54, 64, 38, 1.6), R(54, 78, 38, 1.6)], 3, "flat", clip_to="hand", opacity=0.85),
        F("cuff", "bronze", rrect(25, 74, 18, 52, 4), 4),
        F("cuff_line", "gold_dark", [R(25, 74, 1.8, 48)], 4.5, "flat", clip_to="cuff", opacity=0.8),
    ]
    return {"forms": forms, "canvas": (W, H), "pivot": [115, 56],
            "meta": {"kind": "ui_cursor", "hotspot": [115, 56]}}


@ui("A", "ui_select_corners", "Selection frame: four gold L brackets with a soft glow and a faint edge line, empty centre.")
def select_corners():
    W = H = 128
    brackets = corners(lambda x, y, f: POLY(L_SHAPE, x, y, 34, 34, flip=f or None), W, H, 19)
    forms = [
        F("edge", "gold", rframe(64, 64, 120, 120, 1.6, 6), 0, "flat", opacity=0.45),
        halo("glow", None, brackets, 0.5, 3, 0.55, color="glow_gold"),
        F("brackets", "gold", brackets, 1, shade={"highlight_amount": 0.9}),
    ]
    return {"forms": forms, "canvas": (W, H), "meta": {"kind": "ui_9slice", "nine_slice": [40, 40, 40, 40],
            "preview_size": [300, 128]}}


# ================================================================== balloons
POP = [0.5, 1.08, 0.95, 1.0, 1.0]
BOUNCE = [0.0, -2.0, 1.0, -3.0, 0.0]
TAIL = [(0.2, 0.0), (1.0, 0.0), (0.0, 1.0)]
ANCHOR = (47, 116)   # tail tip: place this pixel just above the speaker's head


def balloon(asset, mark_forms, bubble_mat="balloon"):
    bubble = [C(64, 54, 100, 84), POLY(TAIL, 58, 103, 24, 26)]
    frames_forms = []
    for k in range(5):
        s = POP[k]
        fl = [F("bubble", bubble_mat, scale(bubble, s, *ANCHOR), 0,
                shade={"highlight_amount": 0.3, "ragged": 0.05, "threshold": 0.36, "bump": 0.7})]
        for mf in mark_forms:
            g = copy.deepcopy(mf)
            g["pieces"] = shift(scale(g["pieces"], s, *ANCHOR), 0, BOUNCE[k] * s)
            fl.append(g)
        frames_forms.append(fl)
    forms, frames = animate(frames_forms, asset)
    return {"forms": forms, "frames": frames, "canvas": (128, 128), "pivot": list(ANCHOR),
            "meta": {"kind": "ui_balloon", "anchor": list(ANCHOR), "frames": 5, "loop_from": 3,
                     "note": "frames 1-3 pop in, 4-5 idle bounce"}}


@ui("A", "ui_balloon_exclaim", "Emotion balloon: exclamation mark (bar + dot) on a bone-white bubble, 5-frame pop.")
def balloon_exclaim():
    return balloon("ui_balloon_exclaim", [F("mark", "gem_red", [RR(64, 42, 14, 38), C(64, 76, 14, 14)], 1)])


@ui("A", "ui_balloon_question", "Emotion balloon: question mark built from a ring arc, stem and dot, 5-frame pop.")
def balloon_question():
    hook = [C(64, 38, 38, 36), sub(C(64, 38, 17, 15)), sub(R(52, 50, 24, 24)), RR(67, 62, 11, 14)]
    return balloon("ui_balloon_question", [F("mark", "gem_blue", hook + [C(67, 79, 13, 13)], 1)])


# ================================================================== B
@ui("B", "ui_window_parchment", "Parchment window: pale paper panel with foxing, rolled top and bottom edges, burnt-brown border, wax dots in the corners.")
def window_parchment():
    W = H = 192
    rolls = []
    for y in (11, 181):
        rolls += [R(96, y, 180, 18), C(6, y, 9, 18), C(186, y, 9, 18)]
    forms = [
        F("panel", "paper", [R(96, 96, 172, 170)], 0, shade={"bump": 0.25, "highlight_amount": 0.15, "ragged": 0.08},
          grime={"density": 0.08, "strength": 0.14}, texture={"strength": 0.03}),
        F("burn", None, rframe(96, 96, 172, 170, 6, 2), 0.5, "flat", color="#6e5c44", blur=2, clip_to="panel",
          opacity=0.7),
        F("rolls", "paper", rolls, 1, shade={"bump": 0.9}),
        F("roll_lines", None, [R(96, 13, 180, 1.4), R(96, 183, 180, 1.4)], 1.5, "flat", color="#6e5c44",
          clip_to="rolls", opacity=0.8),
        F("wax", "wax_red", [C(26, 36, 10), C(166, 36, 10), C(26, 156, 10), C(166, 156, 10)], 2),
    ]
    return {"forms": forms, "canvas": (W, H), "meta": {"kind": "ui_9slice", "nine_slice": [64, 64, 64, 64],
            "content_inset": 26, "text_colour_hint": "dark ink on this light panel", "preview_size": [520, 240]}}


def heart_pieces(cx, cy, s):
    """Classic heart: a square turned 45 degrees plus two circles on its upper sides."""
    k = s / 2.0 * 0.7071
    return [R(cx, cy, s, s, rot=45), C(cx - k, cy - k, s, s), C(cx + k, cy - k, s, s)]


@ui("B", "ui_balloon_heart", "Emotion balloon: red heart (square + two circles), 5-frame pop.")
def balloon_heart():
    return balloon("ui_balloon_heart", [F("mark", "gem_red", heart_pieces(64, 58, 30), 1),
                                        F("shine", None, [C(52, 44, 8, 6, rot=-30)], 1.5, "flat", color="#ffc8c8",
                                          opacity=0.7)])


@ui("B", "ui_balloon_anger", "Emotion balloon: anger mark of four bent red strokes around a gap, 5-frame pop.")
def balloon_anger():
    strokes = []
    for k in range(4):
        strokes += turn([MOON(64 - 13, 54 - 13, 22, 22)], 90 * k, 64, 54)
    return balloon("ui_balloon_anger", [F("mark", "gem_red", strokes, 1)])


@ui("B", "ui_balloon_sweat", "Emotion balloon: two pale blue sweat drops with highlights, 5-frame pop.")
def balloon_sweat():
    return balloon("ui_balloon_sweat", [
        F("mark", "ice", [D(70, 52, 26, 38, rot=20), D(46, 66, 14, 20, rot=-15)], 1),
        F("shine", None, [C(66, 58, 5, 9, rot=20)], 1.5, "flat", color="#ffffff", opacity=0.8)])


@ui("B", "ui_balloon_silence", "Emotion balloon: three dots (silence), 5-frame pop.")
def balloon_silence():
    return balloon("ui_balloon_silence", [F("mark", "iron_dark", [C(40, 56, 14), C(64, 56, 14), C(88, 56, 14)], 1)])


@ui("B", "ui_balloon_note", "Emotion balloon: two beamed musical notes built from ellipses and bars, 5-frame pop.")
def balloon_note():
    notes = [C(48, 74, 18, 13, rot=-20), C(80, 68, 18, 13, rot=-20), R(56, 50, 4, 46), R(88, 44, 4, 46),
             R(72, 30, 36, 8, rot=-10)]
    return balloon("ui_balloon_note", [F("mark", "cloth_violet", notes, 1, shade={"highlight_amount": 0.7})])


@ui("B", "ui_balloon_idea", "Emotion balloon: bright gold four-point sparkle with two small ones (sudden idea), 5-frame pop.")
def balloon_idea():
    return balloon("ui_balloon_idea", [
        F("glow", None, [C(64, 54, 40, 40)], 0.8, "flat", color="glow_gold", blur=6, opacity=0.5),
        F("mark", "gold", [SPARK(64, 54, 50)], 1, shade={"highlight_amount": 0.9}),
        F("small", "gold", [SPARK(92, 32, 16), SPARK(36, 30, 12)], 1.2)])


# ------------------------------------------------------------------ main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--stage", default="all")
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    n = 0
    for stage, asset, note, fn in UI:
        if args.stage != "all" and stage != args.stage:
            continue
        if only and asset not in only:
            continue
        spec = fn()
        meta = dict(spec.get("meta", {}), stage=stage, list="docs/art/projects/generic/catalog/g01_list.md")
        save(RDIR, asset, spec["forms"], spec["canvas"], spec.get("style", "ui"), frames=spec.get("frames"),
             meta=meta, note=note, pivot=spec.get("pivot"),
             pivot_meaning=("cursor hotspot" if meta.get("kind") == "ui_cursor" else
                            "balloon anchor (tail tip)" if meta.get("kind") == "ui_balloon" else None))
        n += 1
    print(f"wrote {n} ui recipes to {RDIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
