"""g04-genre-v01 recipes: objects of the non-fantasy genres (modern / city, horror, SF, cyberpunk,
steampunk, post-apocalypse, pirate / sea, western) and of the eastern-fantasy genre.

    python -B make_recipes.py                     # write every recipe into ../recipes
    python -B make_recipes.py obj_vending_machine # only these

Screens, signal lamps and neon are the objects' own lit parts: they go to ``_emit.png`` in the
"on" frame, with a game light in the frame manifest.  No text or logos anywhere.
"""

from __future__ import annotations

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


# ============================================================================ main
def main() -> int:
    names = sys.argv[1:] or list(ASSETS)
    out = JOB / "recipes"
    for n in names:
        print(ASSETS[n]().save(out).name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
