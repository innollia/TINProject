"""g07-controls-v01 recipes: instrument and control parts (flat front view UI).

    py -3 -B gen_controls.py            # writes ../recipes/ui_ctl_*.json

All parts face the viewer (no 60 deg squash).  Anything the game moves
(needles, knobs, handles, plugs) is its own recipe or frame, with ``pivot`` =
rotation centre / contact point.  Lit states put the lit part in ``_emit.png``.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import (annulus, arc_band, disc, form, frame, glare, piece, recipe, rrect, screws,  # noqa: E402
                    ticks, variant, write)

C = (96, 96)
NOTE = "g07 future-kit part (flat front view UI). at-icons collage, candidate."


def ring_pts(c, r, angles):
    return [[round(c[0] + r * math.cos(math.radians(a)), 2), round(c[1] + r * math.sin(math.radians(a)), 2)]
            for a in angles]


# ------------------------------------------------------------------ A
def gauge_round():
    f = [
        form("back", 0, [disc(C, 184)], "steel_dark", shade={"bump": 0.5}),
        form("face", 1, [disc(C, 146)], "enamel", shade={"bump": 0.25, "highlight_amount": 0.15}),
        arc_band("zone", 2, C, 67, 56, 0, 45, "zone_red", clip_to="face"),
        arc_band("scale_line", 2.1, C, 67.5, 66.2, 135, 405, "dial_mark", opacity=0.75, clip_to="face"),
        ticks("ticks_major", 3, C, 61, 9, 135, 405, 12, 3.2, "dial_mark", clip_to="face"),
        ticks("ticks_minor", 3, C, 63.5, 33, 135, 405, 6, 1.5, "dial_mark", opacity=0.8, clip_to="face"),
        form("plaque", 3.2, [rrect([96, 134], [34, 11], corner=3)], "bronze", line={"width": 0.5, "heavy": 0.4}),
        form("stains", 4, [piece("droplet", [66, 122], [18, 28], rot=12), piece("metaballs", [124, 76], [26, 20]),
                           piece("sponge", [80, 64], [20, 20], rot=30)],
             "grime", kind="wash", blend="multiply", opacity=0.32, clip_to="face"),
        form("hub_hole", 4.5, [disc(C, 12)], "dial_mark", kind="flat"),
        glare("glass_glare", 6, C, 146, "face", opacity=0.10),
        annulus("bezel", 7, C, 88, 72, "bronze", shade={"bump": 1.25}),
    ]
    f += screws("screws", 8, ring_pts(C, 80, [300, 60, 180]), d=7, material="steel")
    return recipe("ui_ctl_gauge_round", [192, 192], f, pivot=C, seed=11,
                  pivot_meaning="dial centre = needle rotation centre (use ui_ctl_needle)",
                  note=NOTE + " Round gauge face, 270 deg scale from 135 to 405 deg (screen angles), red zone at the top end, no numbers.")


def needle():
    f = [
        variant(form("slim_body", 1, [piece("triangle", [96, 64], [7, 66])], "paint_red"), "slim"),
        variant(form("slim_tail", 1, [rrect([96, 108], [5, 24], corner=2)], "paint_red"), "slim"),
        variant(form("slim_hub", 2, [disc(C, 18)], "steel"), "slim"),
        variant(form("slim_cap", 3, [disc(C, 6)], "bronze", line=False), "slim"),
        variant(form("arrow_shaft", 1, [rrect([96, 72], [5, 48], corner=2)], "steel_dark"), "arrow"),
        variant(form("arrow_head", 1, [piece("triangle", [96, 44], [17, 20])], "steel_dark"), "arrow"),
        variant(form("arrow_tail", 1, [rrect([96, 108], [10, 20], corner=3)], "steel_dark"), "arrow"),
        variant(form("arrow_hub", 2, [disc(C, 20)], "bronze"), "arrow"),
        variant(form("arrow_cap", 3, [disc(C, 7)], "steel_dark", line=False), "arrow"),
    ]
    return recipe("ui_ctl_needle", [192, 192], f, pivot=C, seed=12,
                  pivot_meaning="rotation centre; needle points straight up at 0 deg, rotate clockwise in game",
                  frames=[frame("slim", show=["slim"]), frame("arrow", show=["arrow"])],
                  note=NOTE + " Separate gauge needles for ui_ctl_gauge_round and other dials.")


def toggle():
    f = [
        form("plate", 0, [rrect(C, [112, 152], corner=18)], "steel", shade={"bump": 0.6}),
        form("plate_groove", 0.5, [rrect(C, [96, 136], corner=14), rrect(C, [92, 132], corner=12, op="sub")],
             "dial_mark", kind="flat", opacity=0.35),
        form("nut", 1, [piece("hexagon", C, [58, 58], rot=30)], "bronze"),
        form("hole", 1.5, [disc(C, 30)], "steel_dark", kind="flat"),
        variant(form("lever_up", 3, [rrect([96, 68], [16, 58], corner=7), disc([96, 38], 24)], "steel",
                     shade={"bump": 1.2}), "up"),
        variant(form("lever_down", 3, [rrect([96, 124], [16, 58], corner=7), disc([96, 154], 24)], "steel",
                     shade={"bump": 1.2}), "down"),
        form("lamp_rim", 1, [disc([96, 160], 18)], "steel_dark"),
        variant(form("lamp_off", 1.2, [disc([96, 160], 11)], "lamp_green_off"), "down"),
        variant(form("lamp_on", 1.2, [disc([96, 160], 11)], "lamp_green_on", emit=1.0,
                     glow={"radius": 6, "opacity": 0.5, "color": "glow_green"}), "up"),
    ]
    f += screws("screws", 2, [[96, 32]], d=9)
    return recipe("ui_ctl_toggle", [192, 192], f, pivot=C, seed=13,
                  frames=[frame("down", show=["down"]), frame("up", show=["up"])],
                  pivot_meaning="toggle centre", note=NOTE + " Toggle switch: down = off, up = on (lamp lit).")


COLORS3 = ("red", "green", "amber")


def button():
    f = [
        form("plate", 0, [rrect(C, [158, 158], corner=22)], "steel_dark", shade={"bump": 0.6}),
        annulus("ring", 1, C, 60, 45, "bronze", shade={"bump": 1.3}),
        annulus("ring_shadow", 1.2, C, 46, 43.5, "dial_mark", kind="flat", opacity=0.6),
        form("cap_mask", 1.9, [disc(C, 90)], "dial_mark", kind="flat", opacity=0.0),
    ]
    for col in COLORS3:
        f.append(variant(form(f"cap_{col}_off", 2, [disc(C, 90)], f"lamp_{col}_off", shade={"bump": 1.25}), f"{col}_off"))
        f.append(variant(form(f"cap_{col}_on", 2, [disc(C, 90)], f"lamp_{col}_on", shade={"bump": 1.1}, emit=1.0,
                              glow={"radius": 10, "opacity": 0.55, "color": f"glow_{col}"}), f"{col}_on"))
    f.append(glare("cap_glare", 3, C, 90, "cap_mask", opacity=0.22))
    f += screws("screws", 4, [[34, 34], [158, 34], [34, 158], [158, 158]], d=9)
    frames = [frame(f"{col}_{s}", show=[f"{col}_{s}"]) for col in COLORS3 for s in ("off", "on")]
    return recipe("ui_ctl_button", [192, 192], f, pivot=C, seed=14, frames=frames, pivot_meaning="button centre",
                  note=NOTE + " Round push button, three cap colours, unlit and lit.")


COLORS4 = ("red", "green", "amber", "white")


def lamp():
    f = [
        form("plate", 0, [piece("octagon", C, [164, 164], rot=22.5)], "steel_dark", shade={"bump": 0.6}),
        annulus("bezel", 1, C, 52, 37, "steel", shade={"bump": 1.3}),
        form("lens_mask", 1.9, [disc(C, 76)], "dial_mark", kind="flat", opacity=0.0),
    ]
    for col in COLORS4:
        f.append(variant(form(f"lens_{col}_off", 2, [disc(C, 76)], f"lamp_{col}_off", shade={"bump": 1.2}), f"{col}_off"))
        f.append(variant(form(f"lens_{col}_on", 2, [disc(C, 76)], f"lamp_{col}_on", emit=1.0,
                              glow={"radius": 14, "opacity": 0.6, "color": f"glow_{col}"}), f"{col}_on"))
    f += [
        annulus("fresnel_a", 2.5, C, 29, 27.6, "glare", kind="flat", opacity=0.14),
        annulus("fresnel_b", 2.5, C, 18, 16.6, "glare", kind="flat", opacity=0.14),
        glare("lens_glare", 3, C, 76, "lens_mask", opacity=0.2),
        form("cage_bars", 4, [rrect([80, 96], [5, 86], corner=2), rrect([112, 96], [5, 86], corner=2),
                              rrect([96, 96], [86, 5], corner=2)], "iron", line={"width": 0.6, "heavy": 0.6}),
        annulus("cage_ring", 4.1, C, 46, 41, "iron"),
    ]
    f += screws("screws", 5, ring_pts(C, 66, [45, 135, 225, 315]), d=9)
    frames = [frame(f"{col}_{s}", show=[f"{col}_{s}"]) for col in COLORS4 for s in ("off", "on")]
    return recipe("ui_ctl_lamp", [192, 192], f, pivot=C, seed=15, frames=frames, pivot_meaning="lamp centre",
                  note=NOTE + " Caged indicator lamp, four colours, unlit and lit.")


def knob():
    f = [
        variant(form("plate", 0, [disc(C, 178)], "steel_dark", shade={"bump": 0.55}), "base"),
        variant(ticks("scale_major", 1, C, 80, 11, 135, 405, 10, 3, "enamel"), "base"),
        variant(ticks("scale_minor", 1, C, 81.5, 21, 135, 405, 5, 1.5, "enamel", opacity=0.7), "base"),
        variant(arc_band("scale_zone", 1, C, 87, 84, 360, 405, "zone_red"), "base"),
        variant(form("seat", 1.5, [disc(C, 118)], "rubber", kind="flat", opacity=0.8), "base"),
        variant(form("knurl", 2, [piece("square", [0, 0], [5, 11], repeat={"ellipse": [96, 96, 54, 54], "count": 40,
                                                                          "orient": True})],
                     "rubber"), "knob"),
        variant(form("skirt", 2.1, [disc(C, 108)], "plastic_dark", shade={"bump": 1.1}), "knob"),
        variant(form("top", 3, [disc(C, 82)], "plastic_dark", shade={"bump": 0.7, "highlight_amount": 0.35}), "knob"),
        variant(form("pointer", 4, [rrect([96, 70], [7, 34], corner=3)], "enamel", kind="flat"), "knob"),
        variant(form("dimple", 4, [disc(C, 14)], "rubber", kind="flat", opacity=0.55), "knob"),
        variant(glare("top_glare", 5, C, 82, "top", opacity=0.12), "knob"),
    ]
    return recipe("ui_ctl_knob", [192, 192], f, pivot=C, seed=16,
                  frames=[frame("base", show=["base"]), frame("knob", show=["knob"])],
                  pivot_meaning="rotation centre; knob pointer points up at 0 deg",
                  note=NOTE + " Rotary knob: 'base' scale plate and 'knob' (rotate it in game) drawn separately.")


def throttle():
    track = [
        form("plate", 0, [rrect([96, 192], [150, 364], corner=20)], "steel_dark", shade={"bump": 0.5}),
        form("slot", 1, [rrect([96, 192], [30, 304], corner=14)], "void", kind="flat",
             grad={"to": "well_inner", "y0": 40, "y1": 344}),
        form("slot_lip", 1.1, [rrect([96, 192], [36, 310], corner=16), rrect([96, 192], [30, 304], corner=14, op="sub")],
             "steel", kind="flat", opacity=0.8),
        form("notches", 2, [piece("square", [0, 0], [22, 4], repeat={"line": [[56, 62], [56, 322]], "count": 9})],
             "steel", kind="flat", opacity=0.9),
        form("zone_top", 2, [rrect([136, 86], [9, 80], corner=3)], "zone_red", kind="flat"),
        form("zone_bottom", 2, [rrect([136, 298], [9, 80], corner=3)], "paint_teal", kind="flat"),
    ]
    track += screws("screws", 3, [[38, 36], [154, 36], [38, 348], [154, 348]], d=9)
    handle = [
        form("stem", 1, [rrect([96, 120], [22, 84], corner=6)], "steel", shade={"bump": 1.2}),
        form("collar", 2, [rrect([96, 164], [54, 18], corner=6)], "steel_dark"),
        form("grip", 3, [rrect([96, 62], [132, 42], corner=19)], "rubber", shade={"bump": 1.3}),
        form("grip_ridges", 3.5, [piece("square", [0, 0], [3, 30], repeat={"line": [[48, 62], [144, 62]], "count": 9})],
             "plastic_dark", kind="flat", opacity=0.55, clip_to="grip"),
    ]
    return [
        recipe("ui_ctl_throttle", [192, 384], track, pivot=[96, 192], seed=17, pivot_meaning="slot centre",
               note=NOTE + " Throttle track: the handle (ui_ctl_throttle_handle) slides along the slot, y 58..326."),
        recipe("ui_ctl_throttle_handle", [192, 192], handle, pivot=[96, 170], seed=18,
               pivot_meaning="slot contact point: place on the track slot centre line and move along y",
               note=NOTE + " Throttle handle for ui_ctl_throttle."),
    ]


def emergency():
    stripes = piece("square", [0, 0], [14, 300], rot=45,
                    repeat={"line": [[-120, 96], [312, 96]], "count": 19})
    f = [
        form("plate", 0, [rrect(C, [170, 170], corner=20)], "paint_ochre", shade={"bump": 0.5}),
        form("stripes", 0.5, [stripes], "dial_mark", kind="flat", opacity=0.85, clip_to="plate", cut_by=["inner"]),
        form("inner", 1, [rrect(C, [126, 126], corner=16)], "steel_dark", shade={"bump": 0.6}),
        annulus("base_ring", 2, C, 50, 40, "steel", shade={"bump": 1.2}),
        form("cap_mask", 2.9, [disc(C, 86)], "dial_mark", kind="flat", opacity=0.0),
        variant(form("cap_up", 3, [disc(C, 86)], "paint_red", shade={"bump": 1.35}), "cap_up"),
        variant(form("cap_down", 3, [disc([96, 98], 78)], "lamp_red_off", shade={"bump": 0.9}), "cap_down"),
        glare("cap_glare", 3.5, C, 86, "cap_mask", opacity=0.2),
        form("hinge", 5, [rrect([96, 24], [112, 14], corner=5), disc([44, 24], 16), disc([148, 24], 16)], "steel"),
        variant(form("cover", 4, [rrect(C, [134, 134], corner=26)], "glass_pane", opacity=0.42,
                     shade={"bump": 0.4, "highlight_amount": 0.7}), "guard"),
        variant(form("cover_frame", 4.2, [rrect(C, [134, 134], corner=26), rrect(C, [118, 118], corner=20, op="sub")],
                     "steel"), "guard"),
        variant(form("cover_open", 4, [rrect([96, 12], [134, 16], corner=6)], "glass_pane", opacity=0.7), "guard_open"),
        variant(form("cover_open_frame", 4.2, [rrect([96, 12], [134, 16], corner=6),
                                               rrect([96, 12], [118, 8], corner=3, op="sub")], "steel"), "guard_open"),
    ]
    return recipe("ui_ctl_emergency", [192, 192], f, pivot=C, seed=19, pivot_meaning="button centre",
                  frames=[frame("guarded", show=["guard", "cap_up"]), frame("open", show=["guard_open", "cap_up"]),
                          frame("pressed", show=["guard_open", "cap_down"])],
                  note=NOTE + " Emergency mushroom button behind a flip guard: guarded, guard open, pressed.")


def jack():
    f = [
        form("nut", 0, [piece("hexagon", C, [108, 108])], "steel", shade={"bump": 0.9}),
        form("washer", 1, [disc(C, 74)], "bronze", shade={"bump": 1.1}),
        form("hole", 2, [disc(C, 38)], "void", kind="flat"),
        annulus("hole_ring", 2.1, C, 21, 18.5, "dial_mark", kind="flat", opacity=0.8),
        variant(form("cord", 3, [rrect([96, 172], [18, 70], corner=8)], "cloth_wine"), "plugged"),
        variant(form("relief", 3.5, [rrect([96, 130], [32, 44], corner=11)], "rubber", shade={"bump": 1.2}), "plugged"),
        variant(form("plug_face", 4, [disc(C, 50)], "bronze", shade={"bump": 1.3}), "plugged"),
        variant(annulus("plug_ring", 4.2, C, 17, 13, "bronze_block", kind="flat", opacity=0.8), "plugged"),
    ]
    plug = [
        form("cord", 0, [rrect([96, 176], [18, 48], corner=8)], "cloth_wine"),
        form("grip", 1, [rrect([96, 130], [38, 54], corner=12)], "rubber", shade={"bump": 1.2}),
        form("grip_ridges", 1.5, [piece("square", [0, 0], [40, 3], repeat={"line": [[96, 112], [96, 148]], "count": 5})],
             "plastic_dark", kind="flat", opacity=0.6, clip_to="grip"),
        form("sleeve", 2, [rrect([96, 84], [28, 50], corner=7)], "bronze", shade={"bump": 1.2}),
        form("tip_ring", 3, [rrect([96, 56], [16, 6], corner=2)], "dial_mark", kind="flat"),
        form("tip", 2.5, [rrect([96, 38], [12, 32], corner=5)], "bronze", shade={"bump": 1.2}),
    ]
    return [
        recipe("ui_ctl_jack", [192, 192], f, pivot=C, seed=20, pivot_meaning="socket centre",
               frames=[frame("empty"), frame("plugged", show=["plugged"])],
               note=NOTE + " Switchboard jack socket, empty and with a plug in it (cord hangs down)."),
        recipe("ui_ctl_jack_plug", [192, 192], plug, pivot=[96, 22], seed=21,
               pivot_meaning="plug tip (the point that goes into ui_ctl_jack)",
               note=NOTE + " Loose patch plug for dragging; cord continues with ui_ctl_cable."),
    ]


def cable():
    f = [
        form("body", 0, [rrect([96, 24], [260, 22], corner=10)], "cloth_wine", tags=["cord"], shade={"bump": 1.2}),
        form("braid", 1, [piece("square", [0, 0], [8, 22], rot=30,
                                repeat={"line": [[-12, 24], [204, 24]], "count": 19})],
             "rubber", kind="flat", opacity=0.3, clip_to="body"),
        form("sheen", 2, [rrect([96, 18], [260, 4], corner=2)], "glare", kind="flat", opacity=0.1, clip_to="body"),
    ]
    return recipe("ui_ctl_cable", [192, 48], f, pivot=[0, 24], seed=22,
                  style_override={"silhouette": False},
                  pivot_meaning="left end, cord centre line (tile to the right every 192 px)",
                  frames=[frame("wine", materials={"cord": "cloth_wine"}), frame("black", materials={"cord": "cable"}),
                          frame("teal", materials={"cord": "paint_teal"})],
                  note=NOTE + " Seamless patch-cord strip (Line2D texture), three colours.")


def stage_a():
    out = [gauge_round(), needle(), toggle(), button(), lamp(), knob(), emergency(), cable()]
    out += throttle()
    out += jack()
    return out


STAGES = {"A": stage_a}


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
