"""g04-genre-v01 recipes: objects of the non-fantasy genres (modern / city, horror, SF, cyberpunk,
steampunk, post-apocalypse, pirate / sea, western) and of the eastern-fantasy genre.

    python -B make_recipes.py                     # write every recipe into ../recipes
    python -B make_recipes.py obj_vending_machine # only these

Screens, signal lamps and neon are the objects' own lit parts: they go to ``_emit.png`` in the
"on" frame, with a game light in the frame manifest.  No text or logos anywhere.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g04kit import (E, I, LINE, MD, MH, MW, POLY, R, SQ, Asset, band_on_cyl, ellipse_shadow,  # noqa: E402,F401
                    planks_front, planks_top, rect_shadow, rivets)

JOB = Path(__file__).resolve().parents[1]
ASSETS = {}
THIN = {"width": 0.9, "heavy": 0.9, "breaks": 0.3}
FINE = {"width": 0.7, "heavy": 0.6, "breaks": 0.3}
WALLFRONT = "front-bottom centre on the floor; the back face stands on the wall line"
SCREEN = "#7ed0c8"


def asset(fn):
    ASSETS[fn.__name__] = fn
    return fn


def lamps(a, name, xys, size, on_mat, off_mat="signal_off", glow=4):
    """Small indicator lamps: off pieces always, on pieces (emit) in the 'on' frame."""
    pieces = [E(x, y, size, size * 0.9) for x, y in xys]
    a.flat(f"{name}_off", pieces, off_mat, line=FINE, tags=["off"])
    a.flat(f"{name}_on", pieces, on_mat, line=FINE, tags=["on"], hidden=True, emit=1.0,
           glow={"radius": glow, "opacity": 0.6, "color": f"{on_mat}_glow" if on_mat.startswith("signal") else "screen_glow"})


def on_off(a, light=None, anchors=None):
    a.frame("off", state="off", anchors=anchors)
    a.frame("on", state="on", show=["on"], hide=["off"], light=light, anchors=anchors)


# ============================================================================ A
@asset
def obj_vending_machine():
    a = Asset("obj_vending_machine", "Drink vending machine 0.9 m wide, 1.85 m high (modern / city): red body, product "
              "window with three rows of cans and bottles, button column, coin slot, pickup hatch, no text or logo. "
              "Frames: off, on (lit window and buttons, emit).", seed=901, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -52, 180, 124, 14)], opacity=0.36, blur=9)
    b = a.box("body", 0, 0, 162, 117, 194, "paint_red", corner=6)
    a.flat("top_vents", [R(0, b.top_cy + k * 12 - 24, 120, 3, 1) for k in range(5)], "soot", opacity=0.5)
    a.flat("header", [R(0, -178, 150, 20, 3)], "plastic", line=THIN)
    a.add("window_off", [R(-18, -112, 104, 120, 4)], "mass", "glass_dark", tags=["off"], shade={"bump": 0.4})
    a.flat("window_on", [R(-18, -112, 104, 120, 4)], "screen_on", tags=["on"], hidden=True, emit=0.75,
           glow={"radius": 8, "opacity": 0.4, "color": "screen_glow"})
    rows = []
    mats = ["paint_red", "paint_teal", "hazard", "plastic", "cloth_blue"]
    by_mat = {m: [] for m in mats}
    for r_i, y in enumerate((-148, -110, -72)):
        a.flat(f"rack{r_i}", [R(-18, y + 16, 98, 4, 1)], "chrome", line=FINE)
        for c_i in range(5):
            x = -56 + c_i * 19
            m = mats[(c_i + r_i * 2) % len(mats)]
            if (c_i + r_i) % 2:
                by_mat[m] += [R(x, y + 2, 11, 26, 3)]
            else:
                by_mat[m] += [R(x, y + 6, 12, 18, 3), R(x, y - 6, 12, 5, 2)]
    for m, pieces in by_mat.items():
        a.flat(f"cans_{m}", pieces, m, line=FINE)
    a.flat("glass_sheen", [LINE(-60, -60, -10, -168, 6)], "chrome", opacity=0.25)
    a.flat("panel", [R(56, -118, 30, 96, 4)], "plastic", line=THIN)
    lamps(a, "buttons", [(56, -156 + k * 13) for k in range(6)], 9, "signal_amber")
    a.flat("coin_slot", [R(56, -74, 12, 4, 1), R(56, -62, 18, 8, 2)], "hole")
    a.flat("hatch", [R(-12, -30, 112, 26, 4)], "hole", line=THIN)
    a.flat("hatch_flap", [R(-12, -36, 108, 10, 3)], "plastic", line=FINE)
    on_off(a, light={"color": SCREEN, "radius": 280, "at": [-18, -112]})
    a.footprint = (-81, -117, 81, 0)
    return a


@asset
def obj_car():
    a = Asset("obj_car", "Compact hatchback facing east (modern / city), 3.8 x 1.7 m: teal body, dark glass cabin with "
              "pillars, windscreen and rear window seen from above, near-side wheels, door seams, lamps, chrome "
              "bumpers.", seed=902, pivot_meaning="centre of the car's near-side ground line")
    a.shadow([R(24, -128, 720, 270, 60)], opacity=0.4, blur=14)
    body = a.box("body", 0, -6, 684, 250, 58, "paint_teal", lift=22, corner=46)
    a.flat("arches", [E(-226, -44, 126, 84), E(214, -44, 126, 84)], "hole")
    a.flat("door_seams", [R(-62, body.front_cy, 3, 50, 1), R(96, body.front_cy, 3, 50, 1)], "soot", opacity=0.7)
    a.flat("handles", [R(-32, body.front_cy - 12, 22, 5, 2), R(124, body.front_cy - 12, 22, 5, 2)], "chrome",
           line=FINE)
    a.flat("sill", [R(0, body.bottom - 6, 520, 7, 3)], "rubber")
    g = a.box("glasshouse", -26, -40, 392, 186, 58, "glass_dark", lift=80, corner=34)
    a.flat("pillars", [R(-222, g.front_cy, 18, 58, 3), R(-28, g.front_cy, 14, 58, 2), R(160, g.front_cy, 16, 58, 3)],
           "paint_teal", line=FINE)
    roof = a.box("roof", -40, -48, 330, 164, 9, "paint_teal", lift=138, corner=30)
    a.add("windscreen", [R(150, roof.top_cy + 4, 44, 158, 12)], "mass", "glass_dark", shade={"bump": 0.4})
    a.add("rear_glass", [R(-222, roof.top_cy + 4, 30, 150, 10)], "mass", "glass_dark", shade={"bump": 0.4})
    a.flat("mirror", [E(140, g.bottom - 8, 26, 16)], "paint_teal", line=FINE)
    for i, x in enumerate((-226, 214)):
        a.add(f"wheel{i}", [E(x, -30, 104, 64)], "mass", "rubber")
        a.flat(f"hub{i}", [E(x, -30, 44, 28)], "chrome", line=FINE)
        a.flat(f"hub_bolts{i}", rivets([(x - 10, -32), (x + 10, -32), (x, -24), (x, -38)], 4), "steel")
    a.flat("headlamps", [E(322, body.top_cy - 88, 26, 20), E(322, body.top_cy + 86, 26, 20)], "glass", line=FINE)
    a.flat("taillamps", [R(-334, body.top_cy - 84, 12, 30, 3), R(-334, body.top_cy + 82, 12, 30, 3)], "signal_red",
           line=FINE)
    a.flat("bumpers", [R(326, body.front_cy + 10, 30, 12, 4), R(-326, body.front_cy + 10, 30, 12, 4)], "chrome",
           line=FINE)
    a.footprint = (-342, -256, 342, -6)
    return a


@asset
def obj_sf_console():
    a = Asset("obj_sf_console", "Sci-fi control console 1.4 m wide: steel cabinet, sloped control deck with key grid, "
              "sliders and indicator lamps, upright screen panel. Frames: off, on (screen and lamps lit, emit).",
              seed=903)
    a.shadow([R(8, -48, 270, 110, 14)], opacity=0.36, blur=9)
    back = a.box("screen_panel", 0, -92, 236, 14, 96, "steel", lift=62, corner=5)
    a.flat("screen_off", [R(0, back.front_cy, 204, 74, 5)], "screen_off", tags=["off"], line=THIN)
    a.flat("screen_on", [R(0, back.front_cy, 204, 74, 5)], "screen_on", tags=["on"], hidden=True, emit=0.85,
           glow={"radius": 8, "opacity": 0.45, "color": "screen_glow"}, line=THIN)
    a.flat("screen_graph", [I("line_graph", -40, back.front_cy + 4, 90, 50), I("bar_graph", 60, back.front_cy + 6, 60, 44),
                            R(0, back.front_cy - 30, 190, 3, 1)], "neon_cyan", tags=["on"], hidden=True, emit=1.0,
           opacity=0.8)
    cab = a.box("cabinet", 0, 0, 252, 94, 76, "steel", corner=6)
    a.flat("cabinet_panels", [R(-62, cab.front_cy, 110, 56, 4), R(62, cab.front_cy, 110, 56, 4)], "steel_light",
           line=THIN)
    a.flat("vents", [R(-62, cab.front_cy + 4 + k * 8 - 12, 80, 3, 1) for k in range(4)], "soot", opacity=0.6)
    deck = a.box("deck", 0, -6, 244, 84, 10, "steel_light", lift=76, corner=6)
    a.flat("keys", [I("grid_fine", -52, deck.top_cy + 6, 96, 44, crop=[1, 1, 15, 15], ground=True)], "steel",
           line=FINE)
    a.flat("sliders", [R(40 + k * 16, deck.top_cy + 4, 4, 40, 1) for k in range(4)], "soot")
    a.flat("slider_knobs", [R(40 + k * 16, deck.top_cy + [-8, 6, -2, 10][k], 10, 6, 2) for k in range(4)], "chrome",
           line=FINE)
    lamps(a, "lamps_g", [(104, deck.top_cy - 16), (104, deck.top_cy), (104, deck.top_cy + 16)], 9, "signal_green")
    lamps(a, "lamps_r", [(-106, deck.top_cy - 10), (-106, deck.top_cy + 8)], 9, "signal_red")
    on_off(a, light={"color": SCREEN, "radius": 300, "at": [0, back.front_cy]})
    a.footprint = (-126, -106, 126, 0)
    return a


@asset
def obj_sf_capsule():
    a = Asset("obj_sf_capsule", "Upright cryo capsule against a wall (SF): pale steel shell, rounded glass door, frost "
              "and cold light inside, side conduits, status lamp, plinth. Frames: closed (door shut, active), "
              "open (door slid aside, empty padded cradle).", seed=904, pivot_meaning=WALLFRONT)
    a.shadow([R(6, -40, 170, 100, 16)], opacity=0.36, blur=9)
    for i, x in enumerate((-70, 70)):
        c = a.cyl(f"conduit{i}", x, -60, 18, 200, "steel", lift=14)
        a.flat(f"conduit{i}_rings", band_on_cyl(x, -60 - 14 - 8 - 40, 18, 4) + band_on_cyl(x, -60 - 14 - 8 - 140, 18, 4),
               "soot", clip_to=f"conduit{i}")
    a.box("plinth", 0, 0, 158, 96, 16, "steel", corner=6)
    a.add("shell", [R(0, -134, 126, 240, 58)], "mass", "steel_light", shade={"bump": 0.9})
    a.flat("seams", [R(0, -254, 70, 3, 1), R(-50, -134, 3, 190, 1), R(50, -134, 3, 190, 1)], "soot", opacity=0.5,
           clip_to="shell")
    a.flat("cavity", [R(0, -130, 82, 184, 38)], "hole", grad={"to": "well_inner", "y0": -222, "y1": -38})
    a.wash("cold_light", [R(0, -130, 70, 170, 32)], "neon_cyan", opacity=0.5, blend="normal", blur=10,
           clip_to="cavity", tags=["closed"], emit=0.6)
    a.add("cradle", [R(0, -126, 54, 150, 24)], "mass", "cloth_blue", tags=["open"], hidden=True, clip_to="cavity",
          shade={"bump": 1.0})
    a.flat("cradle_straps", [R(0, -170, 56, 6, 2), R(0, -100, 56, 6, 2)], "soot", tags=["open"], hidden=True,
           clip_to="cradle")
    a.add("glass", [R(0, -130, 84, 186, 40)], "mass", "glass_dark", tags=["closed"], opacity=0.55,
          shade={"bump": 0.4, "highlight_amount": 0.8})
    a.wash("frost", [I("cloud", -10, -60, 80, 40), I("cloud", 14, -196, 60, 30, flip="x")], "snow", opacity=0.45,
           blend="normal", clip_to="glass", tags=["closed"], blur=3)
    a.add("door_aside", [R(72, -132, 30, 186, 14)], "mass", "glass_dark", tags=["open"], hidden=True, opacity=0.7,
          shade={"bump": 0.4, "highlight_amount": 0.8})
    a.add("cap", [E(0, -252, 96, 30)], "mass", "steel")
    lamps(a, "status", [(0, -252)], 12, "signal_green", glow=6)
    light = {"color": "#7ef0f4", "radius": 240, "at": [0, -130]}
    a.frame("closed", state="closed", show=["on"], hide=["off"], light=light)
    a.frame("open", state="open", show=["open", "on"], hide=["closed", "off"], light=light)
    a.footprint = (-79, -96, 79, 0)
    return a


@asset
def obj_steam_boiler():
    a = Asset("obj_steam_boiler", "Steampunk boiler: riveted copper drum on brick saddles, iron firebox with vented door, "
              "smoke stack, pressure gauge, valve wheel and pipe run. Frames: off, on (firebox glow and gauge lamp, "
              "emit).", seed=905)
    a.shadow([R(20, -70, 440, 150, 30)], opacity=0.38, blur=12)
    for i, x in enumerate((-40, 150)):
        a.box(f"saddle{i}", x, -6, 60, 110, 52, "brick", corner=4)
    fb = a.box("firebox", -170, 0, 110, 120, 110, "iron", corner=6)
    a.flat("fire_door", [R(-170, fb.front_cy + 4, 64, 54, 5)], "iron", line=THIN)
    vents = [R(-170 + dx, fb.front_cy + 4, 7, 32, 3) for dx in (-18, -6, 6, 18)]
    a.flat("vents_off", vents, "hole", tags=["off"])
    a.flat("vents_on", vents, "ember", tags=["on"], hidden=True, emit=0.9,
           glow={"radius": 6, "opacity": 0.6, "color": "ember_glow"})
    stack = a.cyl("stack", -170, -58, 44, 230, "iron", lift=110)
    a.flat("stack_rings", band_on_cyl(-170, -58 - 110 - 19 - 60, 44, 6) + band_on_cyl(-170, -58 - 110 - 19 - 170, 44, 6),
           "soot", clip_to="stack")
    a.add("drum", [R(50, -118, 344, 128, 62)], "mass", "copper", shade={"bump": 1.2})
    a.flat("drum_bands", [R(x, -118, 12, 128, 3) for x in (-40, 55, 150)], "iron", line=FINE, clip_to="drum")
    a.flat("drum_rivets", rivets([(x + dx, y) for x in (-40, 55, 150) for dx in (-10, 10) for y in (-160, -136, -112, -88)],
                                 4), "bronze", clip_to="drum")
    a.add("dome", [E(100, -188, 60, 34), R(100, -172, 46, 20, 6)], "mass", "copper")
    a.add("pipe", [LINE(218, -120, 256, -120, 16), LINE(256, -128, 256, -10, 16)], "mass", "copper")
    a.add("valve_stem", [R(256, -150, 8, 30, 2)], "mass", "iron")
    a.flat("valve_wheel", [I("wheel", 256, -166, 38, 24)], "iron", line=FINE)
    a.add("gauge", [E(4, -142, 40, 40)], "mass", "chrome")
    a.flat("gauge_face", [E(4, -142, 30, 30)], "paper", line=FINE)
    a.flat("gauge_needle", [LINE(4, -142, 14, -152, 3)], "soot")
    lamps(a, "gauge_lamp", [(34, -156)], 9, "signal_amber")
    on_off(a, light={"color": "#ff9a4a", "radius": 260, "at": [-170, -56]})
    a.footprint = (-225, -120, 265, 0)
    return a


# ============================================================================ B
WALL = "centre of the back plate = attach point on the wall face"


@asset
def obj_traffic_light():
    a = Asset("obj_traffic_light", "Traffic light 3.2 m (modern / city): steel pole on a base, dark signal head with "
              "three hooded lamps. Frames: red, green, off.", seed=911)
    ellipse_shadow(a, 6, -8, 60, 24, opacity=0.34, blur=6)
    a.box("base", 0, 0, 34, 30, 16, "steel", corner=4)
    a.cyl("pole", 0, -10, 14, 250, "steel", lift=16)
    head = a.box("head", 0, -6, 52, 40, 138, "plastic", lift=250, corner=6)
    a.flat("head_edge", [R(0, head.front_cy, 44, 130, 4)], "rubber", opacity=0.6)
    ys = [head.front_cy - 42, head.front_cy, head.front_cy + 42]
    lamps = {"red": ("signal_red", ys[0]), "amber": ("signal_amber", ys[1]), "green": ("signal_green", ys[2])}
    a.flat("lamps_off", [E(0, y, 30, 30) for _, y in lamps.values()], "signal_off", line=FINE)
    for key, (mat, y) in lamps.items():
        a.flat(f"lamp_{key}", [E(0, y, 30, 30)], mat, tags=[key], hidden=True, emit=1.0,
               glow={"radius": 8, "opacity": 0.6, "color": f"{mat}_glow"}, line=FINE)
    a.flat("visors", [POLY([(0, 1), (0.1, 0), (0.9, 0), (1, 1), (0.85, 0.6), (0.15, 0.6)], 0, y - 18, 40, 14)
                      for y in ys], "rubber", line=FINE)
    a.frame("red", state="red", show=["red"], light={"color": "#ff6a58", "radius": 200, "at": [0, ys[0]]})
    a.frame("green", state="green", show=["green"], light={"color": "#7af0a8", "radius": 200, "at": [0, ys[2]]})
    a.frame("off", state="off")
    return a


@asset
def obj_neon_sign():
    a = Asset("obj_neon_sign", "Cyberpunk neon sign on a wall bracket, no text: dark backing plate with a pink ring, "
              "cyan zigzag and bar tubes, cable and mounting bolts. Frames: off, on (tubes lit, emit).", seed=912,
              pivot_meaning=WALL, layer_hint="wall")
    a.shadow([R(8, 8, 190, 110, 10)], opacity=0.26, blur=8)
    a.add("plate", [R(0, 0, 184, 104, 10)], "mass", "steel", shade={"bump": 0.4})
    a.flat("plate_inner", [R(0, 0, 170, 90, 8)], "screen_off", opacity=0.9)
    a.flat("bolts", rivets([(-84, -44), (84, -44), (-84, 44), (84, 44)], 6), "chrome")
    tubes = {"pink": ("neon_pink", [E(-44, 0, 64, 64), E(-44, 0, 50, 50, op="sub")], "neon_pink_glow"),
             "cyan": ("neon_cyan", [I("arrow_zigzag", 30, -8, 60, 40, rot=0), R(40, 26, 80, 7, 3), R(40, -34, 50, 6, 3)],
                      "neon_cyan_glow")}
    for key, (mat, pieces, glow) in tubes.items():
        a.flat(f"tube_{key}_off", pieces, "glass_dark", tags=["off"], line=FINE)
        a.flat(f"tube_{key}_on", pieces, mat, tags=["on"], hidden=True, emit=1.0,
               glow={"radius": 9, "opacity": 0.7, "color": glow}, line=FINE)
    a.flat("cable", [LINE(88, 30, 104, 60, 3), LINE(104, 60, 100, 90, 3)], "rubber")
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"],
            light=[{"color": "#ff7aa8", "radius": 260, "at": [-44, 0]}, {"color": "#7ef0f4", "radius": 240, "at": [34, 0]}])
    return a


@asset
def obj_oil_drum():
    a = Asset("obj_oil_drum", "Steel oil drum 0.58 m (post-apocalypse): faded yellow paint, two rolling hoops, bung "
              "caps, rust. Frames: normal, dented (caved side, peeled paint, rust streaks).", seed=913)
    dia, h = 104, 92
    dd = dia * SQ
    ellipse_shadow(a, 8, -dd / 2 + 4, dia + 20, dd + 10, opacity=0.38, blur=7)
    b = a.cyl("body", 0, 0, dia, h, "hazard")
    hoops = band_on_cyl(0, -dd / 2 - 30, dia, 6) + band_on_cyl(0, -dd / 2 - 62, dia, 6)
    a.flat("hoops", hoops, "steel", clip_to="body", line=FINE)
    a.flat("lid_rim", [E(0, b.top_cy, dia - 2, dd - 2), E(0, b.top_cy, dia - 12, dd - 12, op="sub")], "steel",
           line=FINE)
    a.flat("bungs", [E(-24, b.top_cy - 8, 14, 10), E(22, b.top_cy + 10, 10, 8)], "steel", line=FINE)
    a.wash("rust", [I("droplet", x, -60, 12, 40, flip="y") for x in (-30, 6, 34)], "rust", opacity=0.5,
           clip_to="body")
    a.wash("dent", [POLY([(0.1, 0.2), (0.5, 0.0), (0.95, 0.3), (0.8, 0.8), (0.35, 1.0), (0.0, 0.7)], -16, -50, 60, 46)],
           "soot", opacity=0.5, blur=3, clip_to="body", tags=["dented"], hidden=True)
    a.flat("dent_creases", [LINE(-40, -60, -4, -44, 2.5), LINE(-30, -30, 8, -58, 2.2), LINE(-20, -70, -10, -26, 2)],
           "hazard", opacity=0.9, clip_to="body", tags=["dented"], hidden=True)
    a.wash("peeled", [I("sponge", 24, -30, 40, 30), I("metaballs", -30, -80, 36, 24)], "rust", opacity=0.75,
           clip_to="body", tags=["dented"], hidden=True)
    a.frame("normal", state="normal")
    a.frame("dented", state="dented", show=["dented"])
    return a


@asset
def obj_barricade():
    a = Asset("obj_barricade", "Post-apocalypse barricade 2.4 m: sandbag row, crossed planks, a leaning corrugated metal "
              "sheet, an old tyre and barbed wire.", seed=914, pivot_meaning="centre of the barricade's ground line")
    a.shadow([R(10, -24, 450, 70, 16)], opacity=0.36, blur=10)
    a.add("sheet", [POLY([(0.05, 0), (1, 0.08), (0.95, 1), (0, 0.92)], 90, -110, 190, 170)], "mass", "steel",
          shade={"bump": 0.5})
    a.flat("sheet_ribs", [R(x, -110, 5, 170, 2, rot=4) for x in range(10, 180, 18)], "steel_light", opacity=0.5,
           clip_to="sheet")
    a.wash("sheet_rust", [I("metaballs", 110, -80, 120, 90), I("cloud", 60, -150, 80, 40)], "rust", opacity=0.5,
           blur=6, clip_to="sheet")
    a.add("planks", [LINE(-190, -10, -40, -150, 20), LINE(-190, -150, -40, -10, 20), LINE(-210, -120, -20, -130, 18)],
          "mass", "wood_pale", texture={"angle": 45})
    a.flat("plank_nails", rivets([(-115, -80), (-190, -122), (-40, -126)], 5), "iron")
    bags = []
    for row, (y, n, w) in enumerate(((-18, 6, 74), (-52, 5, 72))):
        x0 = -(n - 1) * (w - 6) / 2 + (row * 20)
        for k in range(n):
            bags.append(R(x0 + k * (w - 6), y, w, 36, 16))
    a.add("sandbags", bags, "mass", "cloth_ochre", line=THIN, shade={"bump": 1.1})
    a.flat("bag_ties", [R(b["at"][0] + 22, b["at"][1], 3, 26, 1) for b in bags], "rope", opacity=0.7)
    a.add("tyre", [E(170, -26, 90, 52), E(170, -26, 44, 24, op="sub")], "mass", "rubber", shade={"bump": 1.2})
    coils = []
    for k in range(14):
        x = -200 + k * 22
        coils += [E(x, -170, 26, 20), E(x, -170, 20, 14, op="sub")]
    a.flat("wire", coils + [R(-57, -170, 290, 2, 1)], "iron", opacity=0.9)
    barbs = [LINE(-200 + k * 22 - 4, -182, -200 + k * 22 + 4, -174, 2) for k in range(14)]
    a.flat("barbs", barbs, "iron", opacity=0.9)
    a.footprint = (-230, -60, 230, 0)
    return a


@asset
def obj_stone_lantern():
    a = Asset("obj_stone_lantern", "Eastern stone lantern 1.6 m: square base, round pillar, platform, fire box with "
              "open windows, curved roof cap with a jewel finial. Frames: off, on (fire box glowing, emit).", seed=915)
    ellipse_shadow(a, 8, -10, 110, 40, opacity=0.36, blur=7)
    a.box("base", 0, 0, 96, 70, 22, "rock", corner=6)
    a.cyl("pillar", 0, -22, 36, 70, "rock", lift=22)
    a.box("platform", 0, -8, 96, 70, 16, "rock", lift=92, corner=6)
    fb = a.box("firebox", 0, -20, 66, 52, 50, "rock", lift=108, corner=4)
    a.flat("window_off", [R(0, fb.front_cy, 32, 30, 3)], "hole", tags=["off"])
    a.flat("window_on", [R(0, fb.front_cy, 32, 30, 3)], "window_lit", tags=["on"], hidden=True, emit=1.0,
           glow={"radius": 8, "opacity": 0.6, "color": "window_glow"})
    a.add("cap", [POLY([(0.0, 1.0), (0.12, 0.55), (0.5, 0.0), (0.88, 0.55), (1.0, 1.0), (0.5, 0.86)], 0, fb.top1 - 34,
                       140, 76)], "mass", "rock", shade={"bump": 0.7})
    a.add("jewel", [E(0, fb.top1 - 80, 22, 22), I("triangle", 0, fb.top1 - 94, 12, 12)], "mass", "rock", line=FINE)
    a.wash("moss", [I("cloud", -20, fb.top1 - 30, 70, 20)], "moss", opacity=0.5, clip_to="cap")
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": "#f0c27a", "radius": 240,
                                                             "at": [0, fb.front_cy]})
    return a


# ============================================================================ C
@asset
def obj_phone_booth():
    a = Asset("obj_phone_booth", "Public phone booth 2.4 m (modern / city): red painted frame, grid of small glass "
              "panes, domed roof with a blank light strip, phone box inside. Frames: off, on (strip and interior "
              "light, emit).", seed=921)
    a.shadow([R(8, -40, 130, 100, 12)], opacity=0.36, blur=8)
    b = a.box("body", 0, 0, 108, 92, 230, "paint_red", corner=6)
    a.flat("inside", [R(0, b.front_cy + 6, 84, 190, 3)], "glass_dark", tags=["off"])
    a.flat("inside_lit", [R(0, b.front_cy + 6, 84, 190, 3)], "window_lit", tags=["on"], hidden=True, emit=0.6,
           glow={"radius": 8, "opacity": 0.4, "color": "window_glow"})
    a.flat("phone", [R(-18, b.front_cy - 20, 26, 34, 3), R(-18, b.front_cy - 40, 30, 7, 3)], "soot", line=FINE)
    a.flat("glazing", [R(0, b.front_cy + 6, 3, 190, 1)] + [R(0, b.front_cy + 6 + dy, 84, 3, 1)
                                                          for dy in (-72, -36, 0, 36, 72)], "paint_red")
    a.add("roof", [E(0, b.top_cy - 4, 116, 60), R(0, b.top1 - 6, 112, 16, 6)], "mass", "paint_red")
    a.flat("strip_off", [R(0, b.top1 + 12, 80, 14, 3)], "signal_off", tags=["off"], line=FINE)
    a.flat("strip_on", [R(0, b.top1 + 12, 80, 14, 3)], "paper", tags=["on"], hidden=True, emit=1.0,
           glow={"radius": 6, "opacity": 0.5, "color": "lamp_glow"}, line=FINE)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light={"color": "#ffc987", "radius": 240,
                                                             "at": [0, b.front_cy]})
    a.footprint = (-54, -92, 54, 0)
    return a


@asset
def obj_trash_can():
    a = Asset("obj_trash_can", "Metal street trash can 0.95 m (modern / city): ribbed steel body, domed lid slightly "
              "ajar with a paper bag poking out, dents and grime.", seed=922)
    dia = 90
    dd = dia * SQ
    ellipse_shadow(a, 6, -dd / 2 + 4, dia + 20, dd + 8, opacity=0.36, blur=6)
    b = a.cyl("body", 0, 0, dia, 92, "steel")
    a.flat("ribs", [R(x, -46 - dd / 2 + 6, 3, 90, 1) for x in (-32, -16, 0, 16, 32)], "steel_light", opacity=0.4,
           clip_to="body")
    a.flat("bands", band_on_cyl(0, -dd / 2 - 20, dia, 6) + band_on_cyl(0, -dd / 2 - 76, dia, 6), "steel_light",
           clip_to="body", line=FINE)
    a.add("paper", [I("cloud", 14, b.top_cy - 10, 40, 26)], "mass", "paper", rough={"amp": 0.5, "soft": 1, "cell": 4},
          line=FINE)
    a.add("lid", [E(-6, b.top_cy - 8, dia + 8, dd * 0.9, rot=-8), E(-6, b.top_cy - 14, 22, 12)], "mass", "steel",
          shade={"bump": 1.0})
    a.wash("grime", [I("metaballs", 0, -30, 70, 40)], "grime", opacity=0.4, clip_to="body")
    return a


@asset
def obj_hitching_post():
    a = Asset("obj_hitching_post", "Western hitching rail 2 m: two weathered posts, a horizontal rail, rope knot and a "
              "small water trough.", seed=923, pivot_meaning="centre of the rail's ground line")
    a.shadow([R(8, -4, 390, 30, 8)], opacity=0.32, blur=6)
    for i, x in enumerate((-160, 160)):
        a.box(f"post{i}", x, 0, 20, 18, 108, "wood_pale", corner=3)
    a.box("rail", 0, -2, 360, 14, 16, "wood_pale", lift=92, corner=3)
    a.add("knot", [E(40, -104, 18, 22), LINE(40, -96, 34, -70, 4)], "mass", "rope", line=FINE)
    t = a.box("trough", 30, 70, 180, 60, 40, "wood_dark", corner=3)
    a.flat("trough_water", [R(30, t.top_cy, 160, 44, 3)], "water", line=FINE)
    a.footprint = (-170, -18, 170, 70)
    return a


@asset
def obj_water_tower():
    a = Asset("obj_water_tower", "Western water tower 6 m: wooden tank with iron hoops on four braced legs, conical "
              "roof, spout pipe with a rope pull.", seed=924, pivot_meaning="centre of the front legs' ground line")
    a.shadow([R(30, -110, 330, 250, 30)], opacity=0.34, blur=14)
    legs = [(-110, -200), (110, -200), (-120, 0), (120, 0)]
    for i, (x, y) in enumerate(legs[:2]):
        a.box(f"leg_back{i}", x, y, 20, 18, 330, "wood_dark", corner=3)
    a.add("braces_back", [LINE(-110, -230, 110, -430, 8), LINE(110, -230, -110, -430, 8)], "mass", "wood_dark")
    for i, (x, y) in enumerate(legs[2:]):
        a.box(f"leg_front{i}", x, y, 22, 20, 330, "wood_dark", corner=3)
    a.add("braces_front", [LINE(-120, -40, 120, -250, 9), LINE(120, -40, -120, -250, 9), R(0, -145, 240, 10, 3)],
          "mass", "wood_dark")
    tank = a.cyl("tank", 0, -10, 290, 190, "wood", lift=330)
    a.flat("staves", [R(x, tank.front_cy + 40, 2.4, 180, 1) for x in range(-130, 140, 26)], "wood_dark", opacity=0.5,
           clip_to="tank")
    hoops = []
    for t in (30, 100, 170):
        hoops += band_on_cyl(0, -10 - 330 - 290 * SQ / 2 - t, 290, 8)
    a.flat("hoops", hoops, "iron", clip_to="tank", line=FINE)
    a.add("roof", [POLY([(0.5, 0), (1, 0.85), (0.5, 1), (0, 0.85)], 0, tank.top_cy - 60, 320, 200)], "mass", "wood_dark",
          shade={"bump": 0.7})
    a.add("spout", [LINE(120, -400, 190, -440, 14), LINE(190, -440, 200, -380, 12)], "mass", "iron")
    a.flat("pull_rope", [R(200, -330, 3, 90, 1)], "rope")
    return a


@asset
def obj_torii():
    a = Asset("obj_torii", "Torii shrine gate 3.2 m (eastern): two red lacquer pillars on stone bases, lower tie beam, "
              "curved black-capped top beam with upturned ends, small blank plaque.", seed=925,
              pivot_meaning="centre between the pillars on the ground")
    a.shadow([R(10, -4, 460, 30, 10)], opacity=0.32, blur=7)
    for i, x in enumerate((-160, 160)):
        a.cyl(f"base{i}", x, 0, 50, 16, "rock")
        a.cyl(f"pillar{i}", x, -4, 34, 300, "lacquer_red", lift=16)
    a.box("nuki", 0, -4, 420, 18, 22, "lacquer_red", lift=250, corner=3)
    a.add("kasagi", [POLY([(0, 0.0), (0.08, 0.35), (0.5, 0.45), (0.92, 0.35), (1, 0.0), (1, 0.4), (0.92, 1),
                           (0.5, 1.0), (0.08, 1), (0, 0.4)], 0, -350, 480, 50)], "mass", "soot", shade={"bump": 0.5})
    a.add("kasagi_red", [R(0, -318, 420, 20, 3)], "mass", "lacquer_red")
    a.add("plaque", [R(0, -286, 50, 50, 3)], "mass", "lacquer_red", line=THIN)
    a.flat("plaque_face", [R(0, -286, 36, 36, 2)], "soot")
    return a


@asset
def obj_anchor_large():
    a = Asset("obj_anchor_large", "Large ship anchor (pirate / sea) leaning on its fluke, 1.8 m, rusted iron with a "
              "coil of chain.", seed=926, pivot_meaning="fluke tip contact on the ground")
    a.shadow([E(40, -10, 260, 70)], opacity=0.34, blur=9)
    a.add("anchor", [I("anchor", 20, -110, 200, 220, rot=18)], "mass", "iron", shade={"bump": 1.1},
          grime={"stamps": ["metaballs", "sponge"], "size": 16, "soft": 1.5, "density": 0.45, "strength": 0.45,
                 "color": "rust"})
    chain = []
    for k in range(14):
        t = 2 * math.pi * k / 14
        chain.append(I("link", 90 + 44 * math.cos(t), -8 + 20 * math.sin(t), 20, rot=math.degrees(t) + 45))
    a.flat("chain", chain, "iron", line=FINE)
    return a


@asset
def obj_car_burnt():
    a = Asset("obj_car_burnt", "Burnt-out car wreck (post-apocalypse): charred and rusted hatchback body sitting on "
              "its rims, empty window holes, crumpled bonnet, soot.", seed=927,
              pivot_meaning="centre of the car's near-side ground line")
    a.shadow([R(24, -118, 700, 250, 60)], opacity=0.4, blur=14)
    body = a.box("body", 0, -6, 684, 250, 58, "iron", lift=10, corner=46)
    a.wash("char", [I("metaballs", -100, body.top_cy, 400, 200), I("cloud", 200, body.front_cy, 300, 60)], "soot",
           opacity=0.6, clip_to="body")
    a.wash("rust", [I("sponge", 100, body.top_cy, 300, 180), I("metaballs", -220, body.front_cy, 200, 50)], "rust",
           opacity=0.65, clip_to="body")
    a.flat("arches", [E(-226, -34, 126, 84), E(214, -34, 126, 84)], "hole")
    g = a.box("glasshouse", -26, -40, 392, 186, 58, "iron", lift=68, corner=34)
    a.flat("window_holes", [R(-140, g.front_cy, 150, 44, 8), R(60, g.front_cy, 150, 44, 8)], "hole")
    roof = a.box("roof", -40, -48, 330, 164, 9, "iron", lift=126, corner=30)
    a.wash("roof_rust", [I("sponge", -40, roof.top_cy, 260, 140)], "rust", opacity=0.6, clip_to="roof")
    a.flat("windscreen_hole", [R(150, roof.top_cy + 4, 40, 150, 10)], "hole")
    for i, x in enumerate((-226, 214)):
        a.add(f"rim{i}", [E(x, -24, 90, 56), E(x, -24, 60, 36, op="sub")], "mass", "iron", line=THIN)
    a.add("bonnet", [POLY([(0, 0.2), (0.4, 0), (1, 0.3), (0.9, 1), (0.1, 0.8)], 262, body.top_cy - 10, 120, 170)],
          "mass", "iron", shade={"bump": 1.2})
    a.footprint = (-342, -256, 342, -6)
    return a


@asset
def obj_street_terminal():
    a = Asset("obj_street_terminal", "Cyberpunk street terminal 1.9 m: slim dark pillar with a hood, wide screen, "
              "keypad, card slot and cable bundle. Frames: off, on (screen and trim lit, emit).", seed=928)
    a.shadow([R(8, -30, 110, 70, 10)], opacity=0.36, blur=7)
    b = a.box("pillar", 0, 0, 90, 60, 190, "steel", corner=8)
    a.add("hood", [R(0, b.top1 + 8, 110, 24, 8)], "mass", "plastic")
    a.flat("screen_off", [R(0, -140, 72, 56, 4)], "screen_off", tags=["off"], line=THIN)
    a.flat("screen_on", [R(0, -140, 72, 56, 4)], "screen_on", tags=["on"], hidden=True, emit=0.9,
           glow={"radius": 8, "opacity": 0.5, "color": "screen_glow"}, line=THIN)
    a.flat("ui_bars", [R(-12, -154 + k * 12, 40 - k * 6, 5, 2) for k in range(3)] + [E(22, -140, 16, 16)], "neon_cyan",
           tags=["on"], hidden=True, emit=1.0, opacity=0.8)
    a.flat("keypad", [I("grid_fine", 0, -86, 46, 34, crop=[1, 1, 15, 15])], "chrome", line=FINE)
    a.flat("slot", [R(0, -58, 30, 5, 2)], "hole")
    a.flat("trim_off", [R(-40, -100, 4, 150, 2), R(40, -100, 4, 150, 2)], "signal_off", tags=["off"])
    a.flat("trim_on", [R(-40, -100, 4, 150, 2), R(40, -100, 4, 150, 2)], "neon_pink", tags=["on"], hidden=True,
           emit=1.0, glow={"radius": 5, "opacity": 0.6, "color": "neon_pink_glow"})
    a.add("cables", [LINE(40, -30, 70, 6, 6), LINE(30, -20, 54, 10, 5)], "mass", "rubber", line=FINE)
    a.frame("off", state="off")
    a.frame("on", state="on", show=["on"], hide=["off"], light=[{"color": "#7ed0c8", "radius": 220, "at": [0, -140]},
                                                                {"color": "#ff7aa8", "radius": 160, "at": [0, -100]}])
    return a


@asset
def obj_rail_signal():
    a = Asset("obj_rail_signal", "Steampunk railway semaphore 4 m: lattice iron mast, ladder, red arm with a bone "
              "stripe, lamp with red / green spectacle glass. Frames: red (arm level, stop), green (arm raised).",
              seed=929)
    a.shadow([R(10, -10, 90, 40, 8)], opacity=0.34, blur=6)
    a.box("base", 0, 0, 60, 50, 20, "stone_dark", corner=4)
    a.add("mast", [R(-10, -220, 6, 400, 2), R(10, -220, 6, 400, 2)], "mass", "iron")
    a.flat("lattice", [LINE(-10, -40 - k * 40, 10, -80 - k * 40, 3) for k in range(9)] +
           [LINE(10, -40 - k * 40, -10, -80 - k * 40, 3) for k in range(9)], "iron")
    a.flat("ladder", [R(-30, -200, 3, 340, 1)] + [R(-24, -40 - k * 26, 14, 3, 1) for k in range(13)], "iron")
    a.add("finial", [I("triangle", 0, -430, 20, 16), E(0, -418, 22, 10)], "mass", "iron")
    arm = [(0, 0.15), (1, 0.0), (1, 1.0), (0, 0.85)]
    a.add("arm_stop", [POLY(arm, 70, -380, 130, 26)], "mass", "paint_red", tags=["red"])
    a.flat("stripe_stop", [R(100, -380, 12, 26, 2)], "paper", tags=["red"])
    a.add("arm_go", [POLY(arm, 56, -420, 130, 26, rot=-45)], "mass", "paint_red", tags=["green"], hidden=True)
    a.flat("stripe_go", [R(78, -442, 12, 26, 2, rot=-45)], "paper", tags=["green"], hidden=True)
    a.add("lamp", [R(-32, -370, 26, 30, 5)], "mass", "iron")
    a.flat("lens_red", [E(-32, -370, 14, 14)], "signal_red", tags=["red"], emit=1.0,
           glow={"radius": 6, "opacity": 0.6, "color": "signal_red_glow"})
    a.flat("lens_green", [E(-32, -370, 14, 14)], "signal_green", tags=["green"], hidden=True, emit=1.0,
           glow={"radius": 6, "opacity": 0.6, "color": "signal_green_glow"})
    a.frame("red", state="red (stop)", hide=["green"], light={"color": "#ff6a58", "radius": 200, "at": [-32, -370]})
    a.frame("green", state="green (go)", show=["green"], hide=["red"],
            light={"color": "#7af0a8", "radius": 200, "at": [-32, -370]})
    return a


@asset
def obj_steam_chimney():
    a = Asset("obj_steam_chimney", "Industrial brick chimney stack 6 m (steampunk): square plinth, tapering round brick "
              "stack with iron bands, flared iron crown, soot.", seed=930)
    a.shadow([E(30, -40, 200, 90)], opacity=0.36, blur=10)
    a.box("plinth", 0, 0, 150, 130, 70, "stone", corner=5)
    stack = [(0.2, 0), (0.8, 0), (1, 1), (0, 1)]
    a.add("stack", [POLY(stack, 0, -380, 120, 600)], "mass", "brick", shade={"bump": 0.7})
    a.flat("courses", [R(0, y, 130, 2, 1) for y in range(-100, -680, -20)], "floor_joint", opacity=0.35, clip_to="stack")
    a.flat("bands", [R(0, y, 130, 8, 2) for y in (-220, -420, -600)], "iron", clip_to="stack", line=FINE)
    a.wash("soot", [R(0, -640, 90, 120, 20)], "soot", opacity=0.6, blur=10, clip_to="stack")
    a.add("crown", [POLY([(0, 0), (1, 0), (0.85, 1), (0.15, 1)], 0, -690, 110, 34), E(0, -706, 110, 26)], "mass",
          "iron")
    a.flat("mouth", [E(0, -706, 80, 16)], "hole")
    return a


@asset
def obj_cage_lift():
    a = Asset("obj_cage_lift", "Steampunk cage lift: iron lattice shaft 4 m with a pulley wheel and cables, barred cage "
              "car with a lamp. Frames: down (car at floor level), up (car raised to the top).", seed=931)
    a.shadow([R(10, -60, 230, 140, 14)], opacity=0.34, blur=9)
    for i, x in enumerate((-100, 100)):
        a.box(f"post_back{i}", x, -118, 14, 12, 420, "iron", corner=2)
    for i, x in enumerate((-104, 104)):
        a.box(f"post_front{i}", x, 0, 16, 14, 420, "iron", corner=2)
    a.flat("braces", [LINE(-104, -60 - 100 * k, 104, -160 - 100 * k, 4) for k in range(4)], "iron", opacity=0.8)
    a.box("top", 0, 0, 230, 130, 14, "iron", lift=420, corner=3)
    a.add("pulley", [E(0, -560, 70, 70), E(0, -560, 50, 50, op="sub")], "mass", "copper")
    a.flat("pulley_spokes", [I("wheel", 0, -560, 52)], "copper", opacity=0.8)
    for key, lift in (("down", 0), ("up", 290)):
        hid = key == "up"
        a.flat(f"cables_{key}", [R(-20, -300 - lift / 2, 3, 520 - lift - 180, 1), R(20, -300 - lift / 2, 3,
                                                                                  520 - lift - 180, 1)], "iron",
               tags=[key], hidden=hid)
        car = a.box(f"car_{key}", 0, -10, 180, 104, 10, "wood_dark", lift=lift, corner=3, tags=[key], hidden=hid)
        a.flat(f"car_bars_{key}", [R(x, -10 - lift - 70, 4, 124, 1) for x in range(-84, 90, 21)] +
               [R(0, -10 - lift - 132, 180, 6, 2), R(0, -10 - lift - 70, 180, 4, 1)], "iron", tags=[key], hidden=hid)
        a.box(f"car_roof_{key}", 0, -10, 186, 108, 8, "iron", lift=lift + 132, corner=3, tags=[key], hidden=hid)
        a.flat(f"car_lamp_{key}", [E(60, -10 - lift - 120, 12, 14)], "glass", tags=[key], hidden=hid, emit=0.9,
               glow={"radius": 5, "opacity": 0.5, "color": "lamp_glow"})
    a.frame("down", state="down", hide=["up"])
    a.frame("up", state="up", show=["up"], hide=["down"])
    a.footprint = (-115, -130, 115, 0)
    return a


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
