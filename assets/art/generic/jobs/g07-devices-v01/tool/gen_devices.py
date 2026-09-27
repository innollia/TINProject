"""g07-devices-v01 recipes: genre devices as 60 deg top-down objects.

    py -3 -B gen_devices.py [A|B|C ...]      # writes ../recipes/obj_*.json

Scale (same as g04): width 180 px/m, ground depth 156 px/m, height 105 px/m.
Transparent PNG, pivot = front-bottom centre on the floor unless noted, floor
shadow in _shadow.png, lit parts in _emit.png, states are frames.
"""

from __future__ import annotations

import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import (bezier, box, cyl, disc, dots, floor_ellipse_shadow, floor_shadow, form, frame,  # noqa: E402
                    piece, recipe, rod, rrect, ticks, variant, write)

NOTE = "g07 future-kit device (60 deg top-down object). at-icons collage, candidate."
FLOOR = "front-bottom centre on the floor"


def obj(asset, canvas, forms, pivot, seed, what, frames=None, meaning=FLOOR):
    return recipe(asset, canvas, forms, pivot=pivot, seed=seed, frames=frames, style="prop", pivot_meaning=meaning,
                  note=NOTE + " " + what)


def lamp_pair(name, z, at, d, colour, tag_off, tag_on, glow=5):
    return [variant(form(f"{name}_off", z, [disc(at, d)], f"lamp_{colour}_off", line={"width": 0.5, "heavy": 0.4}),
                    tag_off),
            variant(form(f"{name}_on", z, [disc(at, d)], f"lamp_{colour}_on", line={"width": 0.5, "heavy": 0.4},
                         emit=1.0, glow={"radius": glow, "opacity": 0.6, "color": f"glow_{colour}"}), tag_on)]


# ------------------------------------------------------------------ K1 switchboard
def switchboard():
    cx, base = 180, 404
    cols, rows = 12, 4
    x0, dx = 64.5, 21.0
    f = [
        floor_shadow(cx, base, 300, 110),
        box("panel", 0, cx, base - 94, 292, 20, 200, "wood"),
        form("jack_plate", 0.5, [rrect([cx, 170], [266, 112], corner=6)], "plastic_dark", kind="flat"),
        form("plate_rim", 0.6, [rrect([cx, 170], [272, 118], corner=7), rrect([cx, 170], [266, 112], corner=6, op="sub")],
             "bronze", kind="flat", opacity=0.9),
        form("jack_rims", 1, [piece("circle", [x0, 146], [11, 11], repeat={"grid": [cols, rows], "step": [dx, 22]})],
             "bronze", line={"width": 0.4, "heavy": 0.4}),
        form("jack_holes", 1.1, [piece("circle", [x0, 146], [5.5, 5.5], repeat={"grid": [cols, rows], "step": [dx, 22]})],
             "void", kind="flat"),
        form("lamp_row", 1, [piece("circle", [x0, 125], [8, 8], repeat={"line": [[x0, 125], [x0 + dx * 11, 125]],
                                                                         "count": cols})],
             "lamp_amber_off", line={"width": 0.4, "heavy": 0.3}),
        variant(form("lamps_lit", 1.2, [disc([x0 + dx * i, 125], 8) for i in (1, 4, 5, 9)], "lamp_amber_on",
                     line={"width": 0.4, "heavy": 0.3}, emit=1.0, glow={"radius": 5, "opacity": 0.7, "color": "glow_amber"}),
                "active"),
        box("desk", 2, cx, base, 300, 94, 84, "wood"),
        form("drawers", 2.5, [rrect([104, 362], [112, 54], corner=4), rrect([256, 362], [112, 54], corner=4)], "wood",
             kind="flat", line={"width": 1.0, "heavy": 1.0}),
        form("drawer_pulls", 2.6, [rrect([104, 352], [32, 6], corner=2), rrect([256, 352], [32, 6], corner=2)], "bronze"),
        form("keys", 3, [piece("square", [x0, 300], [6, 14], repeat={"line": [[x0, 300], [x0 + dx * 11, 300]],
                                                                     "count": cols})], "steel"),
        form("plug_stems", 3, [piece("square", [x0, 268], [6, 16], repeat={"line": [[x0, 268], [x0 + dx * 11, 268]],
                                                                           "count": cols})], "rubber"),
        form("plug_tips", 3.1, [piece("circle", [x0, 259], [8, 8], repeat={"line": [[x0, 259], [x0 + dx * 11, 259]],
                                                                            "count": cols})], "bronze"),
        form("headset", 3.2, [piece("headphones", [322, 244], [40, 34], rot=12)], "plastic_dark"),
    ]
    cords = [((x0 + dx * 2, 262), (x0 + dx * 4, 168)), ((x0 + dx * 6, 262), (x0 + dx * 9, 146)),
             ((x0 + dx * 8, 262), (x0 + dx * 5, 190))]
    for i, (a, b) in enumerate(cords):
        mid = ((a[0] + b[0]) / 2.0, max(a[1], b[1]) + 24)
        f.append(variant(dots(f"cord_{i}", 4, bezier(a, mid, b, 40), 4.5, "cloth_wine" if i != 1 else "cable",
                              line={"width": 0.4, "heavy": 0.3}), "active"))
        f.append(variant(form(f"cord_plug_{i}", 4.1, [disc(b, 9)], "bronze"), "active"))
    return obj("obj_switchboard", [360, 432], f, [cx, base], 101,
               "Telephone switchboard: jack field, call lamps, plugs and keys on the desk. idle / active (lamps lit, cords "
               "patched).", frames=[frame("idle"), frame("active", show=["active"])])


# ------------------------------------------------------------------ K1 radio desk
def radio_desk():
    cx, base = 160, 334
    f = [
        floor_shadow(cx, base, 234, 94),
        box("desk", 1, cx, base, 234, 94, 82, "wood"),
        form("modesty", 1.5, [rrect([cx, 296], [206, 64], corner=4)], "wood", kind="flat", line={"width": 1, "heavy": 1}),
        form("drawer_pull", 1.6, [rrect([cx, 276], [40, 6], corner=2)], "bronze"),
        box("radio", 2, 150, 219, 144, 55, 44, "paint_olive"),
        form("radio_vents", 2.5, [piece("square", [0, 0], [3, 20], repeat={"line": [[110, 146], [190, 146]], "count": 9})],
             "dial_mark", kind="flat", opacity=0.55),
        form("radio_handle", 2.6, [rrect([150, 128], [60, 7], corner=3)], "bronze"),
        form("dial_window", 3, [rrect([112, 194], [56, 24], corner=4)], "screen", kind="flat"),
        variant(form("dial_lit", 3.1, [rrect([112, 194], [52, 20], corner=3)], "amber_screen", kind="flat", emit=1.0,
                     glow={"radius": 4, "opacity": 0.5, "color": "glow_amber"}), "on"),
        form("dial_marks", 3.2, [piece("square", [0, 0], [1.4, 8], repeat={"line": [[90, 194], [134, 194]], "count": 12})],
             "dial_mark", kind="flat", opacity=0.8),
        form("dial_needle", 3.3, [rrect([120, 194], [2.4, 22], corner=1)], "paint_red", kind="flat"),
        form("meter", 3, [rrect([160, 188], [26, 16], corner=3)], "enamel", kind="flat", line={"width": 0.6, "heavy": 0.5}),
        form("meter_needle", 3.1, [rrect([163, 190], [1.6, 12], corner=1, rot=25)], "dial_mark", kind="flat"),
        form("grille", 3, [rrect([200, 196], [28, 34], corner=3)], "rubber", kind="flat"),
        form("grille_slots", 3.1, [piece("square", [0, 0], [22, 2], repeat={"line": [[200, 184], [200, 208]], "count": 7})],
             "plastic_dark", kind="flat", opacity=0.9),
        form("knobs", 3.2, [disc([146, 211], 12), disc([164, 211], 12), disc([182, 211], 12)], "plastic_dark"),
    ]
    f += lamp_pair("power", 3.3, [182, 186], 7, "green", "off", "on", glow=4)
    f += [
        form("mic_base", 3, [disc([238, 226], [30, 13])], "steel_dark"),
        form("mic_stem", 3.1, [rrect([238, 208], [4, 30], corner=2)], "steel"),
        form("mic", 3.2, [piece("microphone", [238, 186], [22, 30], crop=[3.5, 0, 12.5, 10.5])], "steel"),
        dots("mic_cable", 2.9, bezier((238, 228), (214, 240), (206, 214), 18), 3.5, "cable"),
        form("headphones", 3, [piece("headphones", [70, 224], [44, 34], rot=-16)], "plastic_dark"),
    ]
    return obj("obj_radio_desk", [320, 360], f, [cx, base], 102,
               "Radio transceiver on a desk with microphone and headphones. off / on (dial and lamp lit).",
               frames=[frame("off", show=["off"]), frame("on", show=["on"])])


# ------------------------------------------------------------------ K2 sorting rack
def sorting_rack():
    cx, base = 160, 316
    cols, rows = 7, 7
    x0, y0, sx, sy = 64, 138, 32, 25
    rng = random.Random(9)
    full = [(i, j) for j in range(rows) for i in range(cols) if rng.random() < 0.62]
    f = [
        floor_shadow(cx, base, 252, 62),
        box("body", 1, cx, base, 252, 62, 200, "wood"),
        form("holes", 2, [piece("square", [x0, y0], [27, 19], slice={"border": 3, "corner": 2},
                                repeat={"grid": [cols, rows], "step": [sx, sy]})], "void", kind="flat",
             grad={"to": "well_inner", "y0": 120, "y1": 300}),
        form("labels", 2.1, [piece("square", [x0, y0 + 12.5], [12, 3], repeat={"grid": [cols, rows], "step": [sx, sy]})],
             "bronze", kind="flat", opacity=0.9),
        variant(form("letters", 3, [rrect([x0 + i * sx + rng.uniform(-3, 3), y0 + j * sy - 2], [20, 10], corner=1,
                                          rot=rng.uniform(-8, 8)) for i, j in full], "paper",
                     line={"width": 0.5, "heavy": 0.4}), "full"),
        variant(form("parcels", 3.1, [rrect([x0 + 1 * sx, y0 + 5 * sy], [24, 16], corner=2),
                                      rrect([x0 + 5 * sx, y0 + 2 * sy], [24, 16], corner=2)], "cork"), "full"),
        variant(form("parcel_string", 3.2, [rrect([x0 + 1 * sx, y0 + 5 * sy], [2, 16], corner=1),
                                            rrect([x0 + 5 * sx, y0 + 2 * sy], [2, 16], corner=1)], "paper_mark",
                     kind="flat"), "full"),
        form("crown", 1.5, [rrect([cx, 118], [256, 6], corner=2)], "bronze", kind="flat", opacity=0.8),
    ]
    return obj("obj_sorting_rack", [320, 340], f, [cx, base], 103,
               "Mail sorting rack with 7x7 pigeonholes and blank label plates. empty / full (letters and parcels).",
               frames=[frame("empty"), frame("full", show=["full"])])


# ------------------------------------------------------------------ K2 x-ray scanner
def xray_scanner():
    cx, base_m, base_t = 170, 360, 454
    f = [
        floor_shadow(cx, base_m, 180, 172),
        floor_shadow(cx, base_t, 150, 94, name="shadow_table"),
        box("machine", 1, cx, base_m, 180, 172, 152, "plastic_beige"),
        form("mouth", 2, [rrect([cx, 258], [128, 60], corner=6)], "void", kind="flat",
             grad={"to": "well_inner", "y0": 228, "y1": 288}),
        form("curtain", 2.1, [piece("square", [0, 0], [11, 52], slice={"border": 3, "corner": 2},
                                    repeat={"line": [[114, 256], [226, 256]], "count": 9})], "rubber", opacity=0.9),
        form("mouth_frame", 2.2, [rrect([cx, 258], [136, 66], corner=7), rrect([cx, 258], [128, 60], corner=6, op="sub")],
             "steel_dark", kind="flat"),
        form("hazard_mark", 2.3, [piece("radioactive_symbol", [236, 318], [26, 26])], "paint_ochre", kind="flat",
             opacity=0.85),
        form("vents", 2.3, [piece("square", [0, 0], [26, 3], repeat={"line": [[108, 312], [108, 336]], "count": 5})],
             "dial_mark", kind="flat", opacity=0.5),
        form("top_panel", 2.4, [rrect([cx, 110], [120, 90], corner=8)], "plastic_beige", kind="flat",
             line={"width": 0.8, "heavy": 0.8}),
        cyl("beacon_base", 2.5, cx, 118, 12, 6, "steel_dark"),
    ]
    f += [variant(cyl("beacon_off", 2.6, cx, 110, 9, 14, "lamp_amber_off"), "off"),
          variant(cyl("beacon_on", 2.6, cx, 110, 9, 14, "lamp_amber_on", emit=1.0,
                      glow={"radius": 8, "opacity": 0.7, "color": "glow_amber"}), "on")]
    f += [
        box("table", 3, cx, base_t, 150, 94, 72, "steel"),
        form("belt", 3.5, [rrect([cx, 335], [116, 94], corner=3)], "rubber", kind="flat"),
        form("rollers", 3.6, [piece("square", [0, 0], [110, 3], repeat={"line": [[cx, 296], [cx, 376]], "count": 8})],
             "steel_dark", kind="flat", opacity=0.7),
        form("pole", 4, [rrect([306, 352], [8, 124], corner=3)], "steel"),
        form("foot", 3.9, [disc([306, 414], [42, 16])], "steel_dark"),
        form("monitor", 4.1, [rrect([306, 272], [76, 58], corner=6)], "plastic_dark"),
        form("screen", 4.2, [rrect([306, 270], [60, 42], corner=4)], "screen", kind="flat"),
    ]
    f += [variant(form("scan", 4.3, [rrect([306, 270], [56, 38], corner=3)], "phosphor_dim", kind="flat", emit=0.8), "on"),
          variant(form("scan_bags", 4.4, [rrect([296, 272], [22, 16], corner=4), rrect([316, 266], [14, 12], corner=3),
                                          piece("key", [300, 272], [10, 10], rot=40)], "phosphor", kind="flat",
                       opacity=0.8, emit=1.0, glow={"radius": 3, "opacity": 0.5, "color": "glow_phosphor"}), "on")]
    return obj("obj_xray_scanner", [360, 480], f, [cx, base_t], 104,
               "Baggage x-ray scanner: tunnel with rubber curtain, roller table toward the viewer, monitor on a pole, "
               "beacon. off / on (beacon and monitor lit).",
               frames=[frame("off", show=["off"]), frame("on", show=["on"])])


# ------------------------------------------------------------------ K2 turnstile
def turnstile():
    cx, base = 80, 270
    f = [
        floor_shadow(cx, base, 50, 140),
        floor_shadow(170, 236, 150, 30, name="shadow_arm", opacity=0.2, blur=6),
        box("cabinet", 1, cx, base, 50, 140, 105, "steel"),
        form("top_plate", 1.5, [rrect([cx, 96], [42, 132], corner=5)], "steel_dark", kind="flat"),
        form("reader", 2, [rrect([cx, 74], [34, 30], corner=4)], "plastic_dark"),
        form("reader_slot", 2.1, [rrect([cx, 70], [22, 3], corner=1)], "void", kind="flat"),
        form("hub", 3, [disc([108, 112], 22)], "steel"),
        form("hub_cap", 3.1, [disc([108, 112], 10)], "steel_dark"),
        variant(form("arm_locked", 2.9, [rrect([160, 112], [100, 9], corner=4), rrect([126, 144], [9, 64], corner=4,
                                                                                    rot=-30)],
                     "steel"), "locked"),
        variant(form("arm_open", 2.9, [rrect([110, 152], [9, 80], corner=4), rrect([132, 128], [9, 56], corner=4,
                                                                                 rot=-60)],
                     "steel"), "open"),
        form("front_grille", 1.6, [piece("square", [0, 0], [30, 3], repeat={"line": [[cx, 186], [cx, 252]], "count": 7})],
             "dial_mark", kind="flat", opacity=0.45),
    ]
    f += lamp_pair("lamp_red", 2.2, [cx, 104], 11, "red", "open", "locked", glow=6)
    f += lamp_pair("lamp_green", 2.2, [cx, 122], 11, "green", "locked", "open", glow=6)
    return obj("obj_turnstile", [260, 300], f, [cx, base], 105,
               "Tripod turnstile with card reader and red / green lamps. locked (arm across, red lit) / open (arm dropped, "
               "green lit).", frames=[frame("locked", show=["locked"]), frame("open", show=["open"])])


# ------------------------------------------------------------------ K4 lighthouse lens
def lighthouse_lens():
    cx = 120
    f = [
        floor_ellipse_shadow(cx, 376, 74, 60),
        cyl("plinth", 0.5, cx, 378, 74, 14, "iron"),
        cyl("pedestal", 1, cx, 372, 60, 63, "iron"),
        form("gearbox", 1.5, [rrect([cx, 340], [52, 30], corner=5)], "bronze"),
        form("gear", 1.6, [piece("cog", [cx, 340], [24, 24])], "steel_dark"),
        variant(form("lamp_off", 2, [disc([cx, 242], 26)], "lamp_amber_off"), "off"),
        variant(form("lamp_on", 2, [disc([cx, 242], 30)], "lamp_amber_on", emit=1.0,
                     glow={"radius": 18, "opacity": 0.8, "color": "glow_amber"}), "on"),
        cyl("lens", 3, cx, 305, 56, 116, "glass_pane", opacity=0.72),
    ]
    bands = []
    for yc in (148, 166, 184, 202, 220, 238):
        bands += [disc([cx, yc], [112, 97]), disc([cx, yc - 4], [112, 97], op="sub")]
    f += [
        form("bands", 3.5, bands, "bronze", kind="flat", opacity=0.95, clip_to="lens"),
        form("bullseye", 3.6, [disc([cx, 244], [46, 40]), disc([cx, 244], [34, 29], op="sub"),
                               disc([cx, 244], [22, 19]), disc([cx, 244], [12, 10], op="sub")], "glare", kind="flat",
             opacity=0.22, clip_to="lens"),
        variant(form("lens_glow", 3.7, [disc([cx, 240], [112, 170])], "lamp_amber_on", kind="flat", opacity=0.28,
                     emit=0.8, clip_to="lens"), "on"),
        variant(form("lamp_core", 3.8, [disc([cx, 242], 14)], "lamp_white_on", kind="flat", emit=1.0,
                     glow={"radius": 10, "opacity": 0.7, "color": "glow_white"}), "on"),
        cyl("roof_ring", 4, cx, 190, 60, 8, "bronze"),
        form("dome", 4.5, [disc([cx, 128], [96, 62])], "bronze", shade={"bump": 1.2}),
        form("vent_ball", 4.6, [disc([cx, 96], 18)], "bronze"),
    ]
    return obj("obj_lighthouse_lens", [240, 400], f, [cx, 378], 106,
               "Fresnel lighthouse lens on a clockwork pedestal (brass bands, glass). off / on (lamp and glass lit).",
               frames=[frame("off", show=["off"]), frame("on", show=["on"])])


# ------------------------------------------------------------------ K5 submarine hatch
def sub_hatch():
    cx, gy = 128, 202
    f = [
        floor_ellipse_shadow(cx, 290, 92, 80, opacity=0.3),
        cyl("rim", 1, cx, 288, 90, 8, "paint_teal"),
        variant(form("lid", 2, [disc([cx, 200], [150, 130])], "steel", shade={"bump": 0.6}), "closed"),
        variant(form("bolts", 2.5, [piece("circle", [0, 0], [7, 7], repeat={"ellipse": [cx, 200, 66, 57], "count": 12})],
                     "steel_dark"), "closed"),
        variant(form("wheel", 3, [piece("steering_wheel", [cx, 198], [96, 96], ground=True)], "paint_red",
                     shade={"bump": 1.1}), "closed"),
        form("hinge", 2.2, [rrect([cx, 134], [52, 16], corner=4)], "steel"),
        variant(form("hole", 2, [disc([cx, 202], [150, 130])], "void", kind="flat",
                     grad={"to": "well_inner", "y0": 150, "y1": 262}), "open"),
        variant(form("rungs", 2.1, [piece("square", [0, 0], [64, 6], slice={"border": 3, "corner": 2},
                                          repeat={"line": [[cx, 186], [cx, 246]], "count": 4})], "steel_dark",
                     clip_to="hole"), "open"),
        variant(form("lid_up", 3, [disc([cx, 82], [150, 105])], "steel", shade={"bump": 0.6}), "open"),
        variant(form("lid_up_wheel", 3.5, [piece("steering_wheel", [cx, 82], [84, 60])], "paint_red"), "open"),
    ]
    return obj("obj_sub_hatch", [256, 320], f, [cx, gy], 107,
               "Round submarine floor hatch with a hand wheel. closed / open (lid up, ladder rungs going down).",
               frames=[frame("closed", show=["closed"]), frame("open", show=["open"])],
               meaning="hatch centre on the floor")


# ------------------------------------------------------------------ K7 cash register
def cash_register():
    cx, base = 96, 190
    f = [
        floor_shadow(cx, base, 84, 70, opacity=0.3, blur=5),
        box("base", 1, cx, base, 84, 70, 26, "bronze_block"),
        form("keys", 2, [piece("circle", [70, 124], [9, 9], repeat={"grid": [5, 3], "step": [13, 11]})], "enamel",
             line={"width": 0.4, "heavy": 0.4}),
        box("tower", 2.5, cx, 118, 70, 20, 40, "bronze_block"),
        form("window", 3, [rrect([cx, 88], [46, 14], corner=3)], "screen", kind="flat"),
        form("tabs", 3.1, [piece("square", [0, 0], [6, 9], repeat={"line": [[80, 88], [112, 88]], "count": 5})],
             "enamel", kind="flat", opacity=0.9),
        form("crest", 3.2, [piece("bell", [cx, 63], [16, 14])], "bronze"),
        form("crank", 3, [rrect([144, 140], [6, 24], corner=2)], "steel"),
        form("crank_knob", 3.1, [disc([148, 152], 11)], "rubber"),
        variant(form("drawer_front", 2, [rrect([cx, 176], [76, 18], corner=3)], "wood", kind="flat",
                     line={"width": 0.8, "heavy": 0.8}), "closed"),
        variant(form("drawer_pull", 2.1, [rrect([cx, 176], [22, 5], corner=2)], "steel"), "closed"),
        variant(box("drawer", 3, cx, 224, 78, 36, 18, "wood"), "open"),
        variant(form("trays", 3.5, [rrect([66 + 20 * i, 188], [16, 26], corner=2) for i in range(4)], "void", kind="flat"),
                "open"),
        variant(form("coins", 3.6, [disc([66, 192], 9), disc([86, 190], 8), disc([106, 193], 9), disc([126, 191], 7)],
                     "bronze"), "open"),
    ]
    return obj("obj_cash_register", [192, 232], f, [cx, base], 108,
               "Old brass cash register (blank tabs, no numbers). closed / open (drawer out with coins). Meant to sit on a "
               "counter top.", frames=[frame("closed", show=["closed"]), frame("open", show=["open"])],
               meaning="front-bottom centre; set it on a counter top")


# ------------------------------------------------------------------ K9 evidence board
def evidence_board():
    cx, base = 160, 280
    photos = [((104, 124), -6), ((196, 116), 5), ((246, 166), -3)]
    notes = [((136, 170), 8), ((214, 162), -5), ((80, 168), 4)]
    pins = [(p[0], p[1] - 12) for p, _ in photos] + [(p[0], p[1] - 10) for p, _ in notes]
    links = [(0, 3), (3, 1), (1, 2), (2, 4), (4, 3), (0, 5)]
    f = [
        floor_shadow(cx, base, 240, 50, opacity=0.25),
        form("legs", 1, [rrect([62, 236], [10, 90], corner=3), rrect([258, 236], [10, 90], corner=3)], "wood"),
        form("braces", 0.9, [rrect([80, 244], [8, 76], corner=3, rot=-14), rrect([240, 244], [8, 76], corner=3, rot=14)],
             "wood"),
        box("board", 2, cx, 196, 252, 8, 105, "wood"),
        form("cork", 2.5, [rrect([cx, 144], [236, 94], corner=4)], "cork", shade={"bump": 0.3}),
        form("ledge", 2.6, [rrect([cx, 198], [250, 8], corner=3)], "wood"),
        variant(form("old_holes", 2.7, [disc([p[0] + 6, p[1] + 18], 2.5) for p in pins], "soot", kind="flat"), "empty"),
    ]
    ph = []
    for (p, r) in photos:
        ph.append(rrect(p, [36, 30], corner=2, rot=r))
    f.append(variant(form("photo_frames", 3, ph, "paper", line={"width": 0.5, "heavy": 0.4}), "pinned"))
    f.append(variant(form("photo_prints", 3.1, [rrect([p[0], p[1] - 1], [28, 20], corner=1, rot=r) for p, r in photos],
                          "steel_dark", kind="flat"), "pinned"))
    f.append(variant(form("notes", 3, [rrect(p, [26, 24], corner=1, rot=r) for p, r in notes], "paper",
                          line={"width": 0.5, "heavy": 0.4}), "pinned"))
    f.append(variant(form("note_lines", 3.1, [rrect([p[0], p[1] + dy], [16, 2], corner=1, rot=r)
                                              for p, r in notes for dy in (-2, 3, 8)], "paper_mark", kind="flat"),
                     "pinned"))
    strings = []
    for a, b in links:
        pa, pb = pins[a], pins[b]
        mid = ((pa[0] + pb[0]) / 2.0, (pa[1] + pb[1]) / 2.0 + 6)
        strings += bezier(pa, mid, pb, 26)
    f.append(variant(dots("strings", 3.5, strings, 2.2, "paint_red", kind="flat"), "pinned"))
    f.append(variant(form("pins", 4, [disc(p, 7) for p in pins], "paint_red", line={"width": 0.4, "heavy": 0.3}),
                     "pinned"))
    return obj("obj_evidence_board", [320, 300], f, [cx, base], 109,
               "Cork evidence board on legs. empty (old pin holes) / pinned (blank photos, blank notes, red strings).",
               frames=[frame("empty", show=["empty"]), frame("pinned", show=["pinned"])])


def stage_a():
    return [switchboard(), radio_desk(), sorting_rack(), xray_scanner(), turnstile(), lighthouse_lens(), sub_hatch(),
            cash_register(), evidence_board()]


STAGES = {"A": stage_a}


# ------------------------------------------------------------------ B
def stripes_along(p0, p1, w, n, mats):
    """Alternating coloured segments along a bar (barrier arms)."""
    segs = {m: [] for m in mats}
    for i in range(n):
        a = [p0[0] + (p1[0] - p0[0]) * i / n, p0[1] + (p1[1] - p0[1]) * i / n]
        b = [p0[0] + (p1[0] - p0[0]) * (i + 1) / n, p0[1] + (p1[1] - p0[1]) * (i + 1) / n]
        segs[mats[i % len(mats)]].append(rod(a, b, w, corner=2))
    return segs


def telegraph_desk():
    cx, base = 128, 254
    f = [
        floor_shadow(cx, base, 180, 86),
        box("desk", 1, cx, base, 180, 86, 82, "wood"),
        form("drawer", 1.5, [rrect([cx, 212], [120, 44], corner=4)], "wood", kind="flat", line={"width": 1, "heavy": 1}),
        form("pull", 1.6, [rrect([cx, 204], [30, 6], corner=2)], "bronze"),
        form("reel", 2, [disc([62, 124], [36, 30])], "paper", shade={"bump": 0.5}),
        form("reel_hub", 2.1, [disc([62, 124], [10, 8])], "bronze"),
        form("tape", 2, [rrect([92, 140], [60, 7], corner=2, rot=12)], "paper", shade={"bump": 0.3}),
        form("key_base", 2, [rrect([100, 150], [46, 18], corner=4)], "wood", shade={"bump": 0.9}),
        form("key_lever", 2.5, [rod([80, 148], [122, 136], 5)], "bronze"),
        form("key_knob", 2.6, [disc([124, 134], 13)], "rubber"),
        cyl("coil_a", 2, 150, 150, 7, 18, "rust_metal"),
        cyl("coil_b", 2, 166, 150, 7, 18, "rust_metal"),
        form("armature", 2.7, [rrect([158, 124], [34, 5], corner=2)], "steel"),
        form("sounder_base", 1.9, [rrect([158, 150], [44, 14], corner=3)], "wood"),
        form("wires", 2.8, [rod([166, 150], [196, 162], 2.5), rod([104, 158], [150, 158], 2.5)], "cable"),
        form("inkwell", 2, [disc([198, 124], [20, 16])], "glass_pane", opacity=0.85),
    ]
    return obj("obj_telegraph_desk", [256, 280], f, [cx, base], 111,
               "Telegraph desk: Morse key, sounder with two coils, paper-tape reel, inkwell.")


def antenna_mast():
    cx, base = 100, 340
    top = 64
    lattice = [rod([90, 318], [96, top + 10], 5), rod([110, 318], [104, top + 10], 5)]
    for k in range(7):
        y0 = 312 - k * 36
        y1 = y0 - 36
        lattice.append(rod([90 + k * 0.8, y0], [110 - (k + 1) * 0.8, y1], 3))
    f = [
        floor_shadow(cx, base, 60, 52),
        box("footing", 1, cx, base, 60, 52, 16, "stone"),
        form("lattice", 2, lattice, "steel"),
        form("guys", 1.5, [rod([100, 170], [30, 330], 2), rod([100, 170], [170, 330], 2)], "cable", opacity=0.75,
             line=False),
        form("dipoles", 2.5, [rod([60, 96], [140, 96], 4), rod([70, 118], [130, 118], 4), rod([78, 140], [122, 140], 4)],
             "steel"),
        form("cap", 3, [disc([100, top + 6], 14)], "steel_dark"),
    ]
    f += lamp_pair("beacon", 3.5, [100, top - 6], 14, "red", "off", "on", glow=9)
    return obj("obj_antenna_mast", [200, 360], f, [cx, base], 112,
               "Radio antenna mast (2.6 m) on a footing, dipole bars, guy wires, red beacon. off / on.",
               frames=[frame("off", show=["off"]), frame("on", show=["on"])])


def parcel_scale():
    cx, base = 100, 250
    c = (100, 78)
    f = [
        floor_shadow(cx, base, 110, 78),
        box("platform", 1, cx, base, 110, 78, 14, "iron"),
        form("tread", 1.5, [piece("square", [0, 0], [96, 3], repeat={"line": [[cx, 172], [cx, 222]], "count": 6})],
             "steel_dark", kind="flat", opacity=0.6),
        form("column", 2, [rod([100, 176], [100, 104], 12)], "steel_dark"),
        form("dial_back", 3, [disc(c, 64)], "bronze", shade={"bump": 1.2}),
        form("dial_face", 3.1, [disc(c, 50)], "enamel", shade={"bump": 0.3}),
        ticks("dial_ticks", 3.2, c, 20, 13, 150, 390, 5, 1.6, "dial_mark"),
        form("needle", 3.4, [rod([100, 78], [100, 58], 2.6)], "paint_red", kind="flat"),
        form("hub", 3.5, [disc(c, 6)], "steel_dark"),
        variant(box("parcel", 2.5, cx, 226, 64, 46, 40, "cork"), "loaded"),
        variant(form("string", 2.6, [rrect([cx, 186], [3, 46], corner=1), rrect([cx, 200], [3, 42], corner=1)],
                     "paper_mark", kind="flat"), "loaded"),
    ]
    return obj("obj_parcel_scale", [200, 270], f, [cx, base], 113,
               "Platform parcel scale with a round dial (no numbers). empty / loaded (needle swings).",
               frames=[frame("empty"),
                       frame("loaded", show=["loaded"], move={"needle": {"rot": 75, "pivot": [100, 78]}})])


def checkpoint_booth():
    cx, base = 130, 470
    f = [
        floor_shadow(cx, base, 198, 156),
        floor_shadow(390, 452, 250, 20, name="shadow_arm", opacity=0.18, blur=6),
        box("booth", 1, cx, base, 198, 156, 231, "paint_olive"),
        form("interior", 1.5, [rrect([cx, 302], [172, 84], corner=4)], "void", kind="flat",
             grad={"to": "well_inner", "y0": 260, "y1": 344}),
        form("glass", 1.6, [rrect([cx, 302], [172, 84], corner=4)], "glass_pane", opacity=0.45,
             shade={"bump": 0.4, "highlight_amount": 0.7}),
        form("mullion", 1.7, [rrect([cx, 302], [178, 90], corner=5), rrect([cx, 302], [172, 84], corner=4, op="sub"),
                              rrect([cx, 302], [4, 84], corner=1)], "steel_dark"),
        form("shelf", 1.8, [rrect([cx, 350], [184, 10], corner=3)], "wood"),
        box("roof", 2, cx, 246, 222, 176, 16, "steel_dark"),
        form("roof_seams", 2.2, [rrect([cx, 110], [206, 3], corner=1), rrect([cx, 150], [206, 3], corner=1),
                                 rrect([cx, 190], [206, 3], corner=1)], "dial_mark", kind="flat", opacity=0.45),
        form("roof_trim", 2.2, [rrect([cx, 227], [222, 5], corner=2)], "paint_ochre", kind="flat", opacity=0.7),
        box("roof_vent", 2.4, 76, 182, 46, 36, 18, "steel"),
        form("vent_slots", 2.5, [piece("square", [0, 0], [34, 2.5], repeat={"line": [[76, 150], [76, 160]], "count": 3})],
             "dial_mark", kind="flat", opacity=0.6),
        cyl("roof_light_base", 2.4, 176, 160, 12, 6, "steel"),
        form("stripe", 1.6, [rrect([cx, 438], [198, 14], corner=2)], "paint_ochre", kind="flat", opacity=0.8),
        form("post", 3, [rod([262, 462], [262, 362], 16)], "steel"),
        form("counterweight", 3.1, [rrect([262, 360], [34, 26], corner=4)], "iron"),
        form("sign", 3.2, [piece("octagon", [262, 410], [30, 30], rot=22.5)], "paint_red"),
        form("sign_bar", 3.3, [rrect([262, 410], [18, 5], corner=2)], "bone", kind="flat"),
    ]
    f += lamp_pair("window_lamp", 2.5, [cx, 244 + 12], 12, "amber", "never", "always", glow=7)
    f += [variant(cyl("roof_light_off", 2.6, 176, 152, 9, 12, "lamp_amber_off"), "down"),
          variant(cyl("roof_light_on", 2.6, 176, 152, 9, 12, "lamp_amber_on", emit=1.0,
                      glow={"radius": 7, "opacity": 0.7, "color": "glow_amber"}), "up")]
    for state, (p0, p1) in (("down", ((266, 358), (512, 358))), ("up", ((266, 358), (300, 110)))):
        segs = stripes_along(p0, p1, 10, 8, ["paint_red", "bone"])
        f.append(variant(form(f"arm_{state}_red", 3.4, segs["paint_red"], "paint_red"), state))
        f.append(variant(form(f"arm_{state}_bone", 3.4, segs["bone"], "bone"), state))
    return obj("obj_checkpoint_booth", [520, 490], f, [cx, base], 114,
               "Checkpoint booth (1.1 x 1.0 x 2.2 m) with window shelf and lamp, barrier post with red/white arm. down / "
               "up.", frames=[frame("down", show=["down", "always"]), frame("up", show=["up", "always"])])


def locker_bank():
    cx, base = 140, 286
    doors = [68, 140, 212]
    f = [
        floor_shadow(cx, base, 216, 70),
        box("body", 1, cx, base, 216, 70, 189, "steel"),
    ]
    for i, x in enumerate(doors):
        tag = "mid" if i == 1 else "side"
        door = [rrect([x, 196], [66, 176], corner=3)]
        vents = [piece("square", [0, 0], [40, 3], repeat={"line": [[x, 124], [x, 146]], "count": 5})]
        extra = {"tags": ["door_mid"]} if i == 1 else {}
        f.append(form(f"door_{i}", 2, door, "steel", shade={"bump": 0.5}, **extra))
        f.append(form(f"vents_{i}", 2.1, vents, "dial_mark", kind="flat", opacity=0.6, **extra))
        f.append(form(f"plate_{i}", 2.1, [rrect([x, 166], [22, 10], corner=2)], "bronze", **extra))
        f.append(form(f"handle_{i}", 2.2, [rrect([x + 22, 208], [6, 26], corner=2)], "steel_dark", **extra))
        if i == 1:
            for form_ in f[-4:]:
                form_["tags"] = ["door_mid"]
    f += [
        variant(form("mid_inside", 2.5, [rrect([140, 196], [66, 176], corner=3)], "void", kind="flat",
                     grad={"to": "well_inner", "y0": 110, "y1": 284}), "open"),
        variant(form("mid_shelf", 2.6, [rrect([140, 170], [62, 6], corner=2)], "steel_dark"), "open"),
        variant(form("cups", 2.7, [piece("cup", [128, 156], [18, 16]), piece("cup", [150, 156], [18, 16], flip="x")],
                     "enamel"), "open"),
        variant(form("note", 2.7, [rrect([140, 250], [24, 16], corner=1, rot=-8)], "paper"), "open"),
        variant(form("mid_door_open", 3, [piece("square", [190, 200], [28, 176], slice={"border": 3, "corner": 3},
                                                skew=[0, 20])], "steel", shade={"bump": 0.5}), "open"),
    ]
    return obj("obj_locker_bank", [280, 300], f, [cx, base], 115,
               "Bank of three steel lockers with vents and blank number plates. closed / open (middle door open: "
               "shelf, two cups, a folded note).",
               frames=[frame("closed"), frame("open", show=["open"], hide=["door_mid"])])


def weather_mast():
    cx, base = 100, 322
    hub = (100, 58)
    arms, cups = [], []
    for a in (0, 120, 240):
        r = math.radians(a + 20)
        end = [hub[0] + 44 * math.cos(r), hub[1] + 22 * math.sin(r)]
        arms.append(rod(hub, end, 3))
        cups.append(piece("circle", end, [16, 14], half="left" if math.cos(r) > 0 else "right"))
    f = [
        floor_shadow(cx, base, 52, 44),
        box("footing", 1, cx, base, 52, 44, 14, "stone"),
        form("pole", 2, [rod([100, 300], [100, 64], 8)], "steel"),
        form("arms", 3, arms, "steel"),
        form("cups", 3.1, cups, "steel_dark"),
        form("hub", 3.2, [disc(hub, 12)], "steel_dark"),
        form("vane_shaft", 3, [rod([66, 112], [134, 112], 5)], "iron"),
        form("vane_head", 3.1, [piece("triangle", [140, 112], [18, 16], rot=90)], "iron"),
        form("vane_tail", 3.1, [piece("flag_triangular", [62, 104], [26, 22], crop=[5, 1, 15, 10])], "paint_ochre"),
        form("vane_collar", 3.2, [disc([100, 112], 10)], "steel_dark"),
        form("logger", 3, [rrect([118, 244], [30, 40], corner=4)], "paint_olive", shade={"bump": 0.8}),
        form("logger_vents", 3.1, [piece("square", [0, 0], [18, 2], repeat={"line": [[118, 234], [118, 250]], "count": 4})],
             "dial_mark", kind="flat", opacity=0.6),
    ]
    f += lamp_pair("logger_lamp", 3.2, [118, 258], 7, "green", "never", "always", glow=4)
    return obj("obj_weather_mast", [200, 340], f, [cx, base], 116,
               "Weather mast (2.4 m): cup anemometer, wind vane, data logger box with a green lamp.",
               frames=[frame("default", show=["always"])])


def studio_camera():
    cx, base = 110, 300
    f = [
        floor_ellipse_shadow(cx, base - 6, 70, 30),
        form("legs", 1, [rod([110, 160], [52, 292], 6), rod([110, 160], [168, 292], 6), rod([110, 160], [116, 270], 6)],
             "steel_dark"),
        form("feet", 1.2, [disc([52, 292], [16, 9]), disc([168, 292], [16, 9]), disc([116, 270], [16, 9])], "rubber"),
        form("column", 1.5, [rod([110, 212], [110, 140], 10)], "steel"),
        form("head", 2, [rrect([110, 138], [42, 18], corner=5)], "steel_dark"),
        form("body", 3, [rrect([118, 110], [96, 52], corner=8)], "plastic_dark", shade={"bump": 0.7}),
        form("lens", 3.2, [rrect([56, 114], [44, 34], corner=6)], "steel"),
        form("lens_hood", 3.3, [rrect([34, 114], [10, 42], corner=3)], "rubber"),
        form("lens_glass", 3.4, [disc([30, 114], [8, 30])], "screen_glass"),
        form("viewfinder", 3.3, [rrect([160, 90], [30, 22], corner=4)], "rubber"),
        form("pan_bar", 2.5, [rod([134, 136], [196, 172], 6)], "steel"),
        form("grip", 2.6, [disc([198, 173], 14)], "rubber"),
        form("cable", 1.1, [piece("circle", [0, 0], [5, 5], repeat={"points": [[110 + 2 * t, 212 + 0.9 * t * t / 10]
                                                                                for t in range(0, 34)]})], "cable"),
    ]
    f += lamp_pair("tally", 4, [128, 80], 12, "red", "off", "on", glow=8)
    return obj("obj_studio_camera", [220, 320], f, [cx, base], 117,
               "Studio / weather-broadcast camera on a tripod, lens to the left, pan bar to the right. off / on (red "
               "tally lamp).", frames=[frame("off", show=["off"]), frame("on", show=["on"])])


def fog_horn():
    cx, base = 130, 262
    f = [
        floor_shadow(cx, base, 120, 86),
        box("pedestal", 1, cx, base, 120, 86, 56, "iron"),
        cyl("tank", 1.5, cx, 176, 32, 50, "paint_red"),
        form("tank_bands", 1.6, [rrect([cx, 132], [66, 4], corner=1), rrect([cx, 150], [66, 4], corner=1)], "iron",
             kind="flat", opacity=0.8),
        form("horn_l", 2, [piece("triangle", [70, 118], [60, 84], rot=90)], "bronze", shade={"bump": 1.2}),
        form("horn_r", 2, [piece("triangle", [190, 118], [60, 84], rot=-90)], "bronze", shade={"bump": 1.2}),
        form("mouth_rims", 2.1, [disc([30, 118], [22, 62]), disc([230, 118], [22, 62])], "bronze", shade={"bump": 1.0}),
        form("mouths", 2.2, [disc([30, 118], [14, 50]), disc([230, 118], [14, 50])], "void", kind="flat", opacity=0.95),
        form("valve", 2.5, [piece("steering_wheel", [cx, 206], [34, 34])], "steel"),
        form("pipe", 1.8, [rod([96, 150], [164, 150], 10)], "iron"),
    ]
    return obj("obj_fog_horn", [260, 280], f, [cx, base], 118,
               "Twin fog horn on an air tank and iron pedestal, with a valve wheel.")


def bell_buoy():
    cx, base = 100, 276
    cage = [rod([76, 198], [88, 112], 4), rod([124, 198], [112, 112], 4), rod([100, 204], [100, 112], 4),
            rod([82, 164], [118, 164], 3), rod([86, 134], [114, 134], 3)]
    f = [
        form("water", 0, [disc([100, 262], [180, 62])], "water", kind="flat", opacity=0.9),
        form("ripples", 0.5, [disc([100, 264], [150, 44]), disc([100, 260], [132, 34], op="sub")], "glare", kind="flat",
             opacity=0.12),
        cyl("float", 1, cx, 276, 52, 40, "paint_red"),
        form("float_band", 1.5, [rrect([cx, 256], [104, 8], corner=2)], "bone", kind="flat", opacity=0.8,
             clip_to="float"),
        form("water_front", 2, [disc([100, 266], [184, 64]), disc([100, 252], [128, 40], op="sub")], "water",
             kind="flat", opacity=0.8),
        form("deck", 2.5, [disc([100, 196], [70, 26])], "iron"),
        form("cage", 3, cage, "iron"),
        form("bell", 3.2, [piece("bell", [100, 162], [40, 44])], "bronze", shade={"bump": 1.2}),
        form("top_plate", 3.5, [disc([100, 112], [36, 14])], "iron"),
    ]
    f += lamp_pair("light", 3.6, [100, 100], 12, "green", "off", "on", glow=8)
    return obj("obj_bell_buoy", [200, 300], f, [cx, base], 119,
               "Bell buoy floating on dark water: red float, iron cage with a bell, top light. dark / lit.",
               frames=[frame("dark", show=["off"]), frame("lit", show=["on"])],
               meaning="waterline front centre (place on water)")


def valve_wheel():
    f = [
        form("wall_plate", 0, [rrect([100, 230], [60, 10], corner=3)], "steel_dark"),
        form("pipe", 1, [rod([100, 232], [100, 40], 26)], "paint_teal"),
        form("flange", 1.2, [rrect([100, 30], [44, 12], corner=3)], "iron"),
        form("brackets", 1.5, [rrect([100, 60], [44, 12], corner=3), rrect([100, 206], [44, 12], corner=3)], "iron"),
        form("body", 2, [piece("hexagon", [100, 132], [70, 70], rot=30)], "iron", shade={"bump": 1.0}),
        form("stem", 2.5, [disc([100, 128], 22)], "steel"),
        form("wheel", 3, [piece("steering_wheel", [100, 124], [104, 104])], "paint_red", shade={"bump": 1.1}),
        form("nut", 3.5, [piece("hexagon", [100, 124], [22, 22])], "steel_dark"),
    ]
    return obj("obj_valve_wheel", [200, 256], f, [100, 236], 120,
               "Wall pipe with a valve body and red hand wheel (facing the viewer).",
               meaning="wall base line under the pipe (place on a south-facing wall's bottom edge)")


def periscope():
    cx, base = 110, 330
    f = [
        floor_ellipse_shadow(cx, base, 60, 30),
        cyl("well", 1, cx, base, 60, 14, "steel_dark"),
        form("well_hole", 1.5, [disc([cx, 266], [84, 40])], "void", kind="flat"),
        variant(form("tube_up", 2, [rod([cx, 270], [cx, -8], 34)], "steel", shade={"bump": 1.0}), "up"),
        variant(form("tube_down", 2, [rod([cx, 270], [cx, -8], 34)], "steel_dark", shade={"bump": 0.8}), "down"),
        variant(form("eyebox_up", 3, [rrect([cx, 120], [56, 66], corner=10)], "paint_teal", shade={"bump": 0.8}), "up"),
        variant(form("eyepiece_up", 3.2, [rrect([cx, 118], [30, 16], corner=6)], "rubber"), "up"),
        variant(form("handles_up", 3.1, [rod([82, 136], [40, 136], 12), rod([138, 136], [180, 136], 12)], "paint_red"),
                "up"),
        variant(form("grips_up", 3.3, [disc([38, 136], 18), disc([182, 136], 18)], "rubber"), "up"),
        variant(form("eyebox_down", 3, [rrect([cx, 250], [56, 66], corner=10)], "paint_teal", shade={"bump": 0.8}),
                "down"),
        variant(form("handles_down", 3.1, [rod([90, 276], [90, 236], 10), rod([130, 276], [130, 236], 10)], "paint_red"),
                "down"),
        form("collar", 1.8, [disc([cx, 264], [52, 20])], "iron"),
    ]
    return obj("obj_periscope", [220, 350], f, [cx, base], 121,
               "Periscope column rising through a floor well into the ceiling (the tube leaves the top of the canvas on "
               "purpose). down (eyepiece low, handles folded) / up (eyepiece at eye level, handles out).",
               frames=[frame("down", show=["down"]), frame("up", show=["up"])])


def display_case():
    cx, base = 130, 260
    items = [piece("potion", [70, 176], [22, 26]), piece("gem", [104, 182], [20, 18]), piece("ring", [134, 184], [22, 12]),
             piece("potion", [168, 174], [18, 22], flip="x"), piece("hourglass", [196, 178], [16, 22]),
             piece("coin", [88, 196], [14, 14]), piece("coin", [150, 198], [14, 14])]
    f = [
        floor_shadow(cx, base, 216, 94),
        box("base", 1, cx, base, 216, 94, 38, "wood"),
        form("base_panel", 1.5, [rrect([cx, 240], [196, 26], corner=3)], "wood", kind="flat", line={"width": 1, "heavy": 1}),
        form("felt", 1.8, [rrect([cx, 175], [206, 84], corner=4)], "felt", kind="flat"),
        variant(form("wares", 2, items, "bronze", shade={"bump": 1.0}), "stocked"),
        variant(form("price_tags", 2.1, [rrect([70, 198], [12, 7], corner=1, rot=-10), rrect([168, 196], [12, 7], corner=1,
                                                                                            rot=8)],
                     "paper"), "stocked"),
        box("glass", 3, cx, base - 38, 216, 94, 70, "glass_pane", opacity=0.42),
        form("frame_posts", 3.5, [rrect([24, 187], [6, 70], corner=2), rrect([236, 187], [6, 70], corner=2),
                                  rrect([cx, 152], [218, 6], corner=2), rrect([cx, 222], [218, 6], corner=2),
                                  rrect([cx, 58], [218, 5], corner=2), rod([24, 152], [24, 58], 5),
                                  rod([236, 152], [236, 58], 5)], "bronze"),
    ]
    return obj("obj_display_case", [260, 280], f, [cx, base], 122,
               "Glass display counter with a wooden base and felt floor. empty / stocked (bottles, gem, ring, coins, "
               "blank price tags).", frames=[frame("empty"), frame("stocked", show=["stocked"])])


def seance_table():
    cx, base = 130, 330
    f = [
        floor_ellipse_shadow(cx, base - 8, 92, 40),
        cyl("cloth", 1, cx, 322, 84, 81, "cloth_wine"),
        form("hem", 1.5, [rrect([cx, 316], [168, 8], corner=3)], "bronze", kind="flat", opacity=0.6, clip_to="cloth"),
        form("board", 2, [rrect([cx, 176], [96, 50], corner=6)], "wood", shade={"bump": 0.6}),
        form("board_marks", 2.1, [piece("sun", [104, 170], [14, 14]), piece("moon", [156, 170], [12, 12]),
                                  rrect([cx, 190], [60, 3], corner=1)], "bone", kind="flat", opacity=0.55),
        form("planchette", 2.2, [piece("heart", [cx + 6, 180], [22, 20], rot=180)], "bone", shade={"bump": 0.8}),
        cyl("ball_stand", 2.3, 176, 160, 9, 8, "bronze"),
        form("ball", 2.4, [disc([176, 140], 30)], "crystal", shade={"bump": 1.3}),
    ]
    for i, (x, yb) in enumerate(((82, 196), (180, 200), (126, 140))):
        f.append(cyl(f"candle_{i}", 2.5, x, yb, 6, 22, "wax"))
        f.append(variant(form(f"wick_{i}", 2.6, [rrect([x, yb - 30], [2, 6], corner=1)], "dial_mark", kind="flat"), "off"))
        f.append(variant(form(f"flame_{i}", 2.6, [piece("fire", [x, yb - 36], [12, 16])], "flame", kind="flat",
                              emit=1.0, glow={"radius": 8, "opacity": 0.7, "color": "flame_glow"}), "on"))
    f.append(variant(form("ball_glow", 2.45, [disc([176, 140], 22)], "lamp_blue_on", kind="flat", opacity=0.35, emit=0.6,
                          clip_to="ball"), "on"))
    return obj("obj_seance_table", [260, 344], f, [cx, base], 123,
               "Round seance table with a floor-length wine cloth, spirit board, planchette, crystal ball and three "
               "candles. unlit / lit.", frames=[frame("unlit", show=["off"]), frame("lit", show=["on"])])


def bell_rack():
    cx, base = 130, 268
    bells = [(80, 34), (130, 44), (182, 54)]
    f = [
        floor_shadow(cx, base, 210, 40, opacity=0.25),
        box("foot_l", 1, 40, base, 34, 40, 12, "wood"),
        box("foot_r", 1, 220, base, 34, 40, 12, "wood"),
        form("posts", 2, [rod([40, 250], [40, 110], 12), rod([220, 250], [220, 110], 12)], "wood"),
        form("beam", 2.5, [rod([30, 112], [230, 112], 14)], "wood"),
        form("hangers", 2.6, [rod([x, 116], [x, 134 + s * 0.1], 3) for x, s in bells], "iron"),
        form("bells", 3, [piece("bell", [x, 138 + s * 0.55], [s, s * 1.1]) for x, s in bells], "bronze",
             shade={"bump": 1.2}),
        form("mallet_handle", 3.5, [rod([236, 262], [206, 186], 6)], "wood"),
        form("mallet_head", 3.6, [rrect([206, 180], [26, 16], corner=6, rot=-22)], "cloth_wine"),
    ]
    return obj("obj_bell_rack", [260, 284], f, [cx, base], 124,
               "Wooden rack with three tuned bells (low / middle / high) and a felt mallet.")


def stage_b():
    return [telegraph_desk(), antenna_mast(), parcel_scale(), checkpoint_booth(), locker_bank(), weather_mast(),
            studio_camera(), fog_horn(), bell_buoy(), valve_wheel(), periscope(), display_case(), seance_table(),
            bell_rack()]


STAGES["B"] = stage_b


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
