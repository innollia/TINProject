"""g07-devices-v01 recipes: genre devices as 60 deg top-down objects.

    py -3 -B gen_devices.py [A|B|C ...]      # writes ../recipes/obj_*.json

Scale (same as g04): width 180 px/m, ground depth 156 px/m, height 105 px/m.
Transparent PNG, pivot = front-bottom centre on the floor unless noted, floor
shadow in _shadow.png, lit parts in _emit.png, states are frames.
"""

from __future__ import annotations

import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g07kit import (bezier, box, cyl, disc, dots, floor_ellipse_shadow, floor_shadow, form, frame,  # noqa: E402
                    piece, recipe, rrect, variant, write)

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


def main() -> int:
    stages = sys.argv[1:] or list(STAGES)
    recipes = []
    for s in stages:
        recipes += STAGES[s]()
    write(recipes, Path(__file__).resolve().parents[1] / "recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
