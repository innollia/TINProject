"""fx-02 effect recipes: writes the 15 effect recipes into recipes/.

Repeated shapes (flame tongues, spiral chambers, tendril rings, lissajous paths,
orbiting pointers) are computed here instead of typed out, so a 6-frame loop is
one list of numbers rather than six copies of the form.

    py -3 -B tool\\gen_fx02.py
    py -3 -B tool\\build.py --all
"""
from __future__ import annotations

import json
import math
from pathlib import Path

REC = Path(__file__).resolve().parents[1] / "recipes"


# --------------------------------------------------------------------- helpers
def P(icon, at, size, **kw):
    d = {"icon": icon}
    d.update(kw)
    d["at"] = [round(float(at[0]), 2), round(float(at[1]), 2)]
    if isinstance(size, (int, float)):
        d["size"] = round(float(size), 2)
    else:
        d["size"] = [round(float(size[0]), 2), round(float(size[1]), 2)]
    return d


def F(name, pieces, z=0.0, material=None, kind="mass", tags=None, **kw):
    d = {"name": name, "z": z, "kind": kind, "pieces": pieces}
    if tags:
        d["tags"] = list(tags)
    if material:
        d["material"] = material
    d.update(kw)
    return d


def ring_spots(cx, cy, r, n, a0=-90.0, rot="radial", rj=0.0):
    """n spots on a circle.  rot: 'radial' (point outward), 'tangent', or None."""
    out = []
    for i in range(n):
        a = math.radians(a0 + 360.0 * i / n)
        rr = r * (1.0 + rj * (((i * 37) % 11) / 10.0 - 0.5))
        extra = 0.0
        if rot == "radial":
            extra = math.degrees(a) + 90.0
        elif rot == "tangent":
            extra = math.degrees(a)
        out.append([round(cx + rr * math.cos(a), 2), round(cy + rr * math.sin(a), 2),
                    round(extra, 2)])
    return out


def recipe(asset, canvas, pivot, seed, forms, frames, note, meaning, **kw):
    r = {"asset": asset, "status": "candidate", "note": note,
         "palette": "palette_fx.json", "style": "sprite",
         "canvas": list(canvas), "pivot": list(pivot), "pivot_meaning": meaning,
         "seed": seed, "forms": forms, "frames": frames}
    r.update(kw)
    return r


def write(name, data):
    (REC / name).write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("wrote recipes/" + name)


def frames(n, moves, hide_by_frame=None, show_by_frame=None):
    out = []
    for i in range(n):
        f = {"name": "f%d" % i}
        m = {k: v[i] for k, v in moves.items() if len(v) > i and v[i] is not None}
        if m:
            f["move"] = m
        if hide_by_frame and i in hide_by_frame:
            f["hide"] = list(hide_by_frame[i])
        if show_by_frame and i in show_by_frame:
            f["show"] = list(show_by_frame[i])
        out.append(f)
    return out


def swap_sets(forms_moves, fs, a_tag, b_tag, half):
    """Hide set A after the first `half` frames, show set B instead."""
    for i, f in enumerate(fs):
        if i < half:
            f.setdefault("hide", []).append(b_tag)
        else:
            f.setdefault("hide", []).append(a_tag)
            f.setdefault("show", []).append(b_tag)


# ================================================================= 1 soul fire
def soul_fire():
    """Blue soul fire: many thin tongues that taper as they rise, white core."""
    CX, BASE = 192, 300
    forms = [
        F("sf_haze", [P("droplet", [CX, 200], [250, 300]),
                      P("droplet", [126, 236], [128, 172]),
                      P("droplet", [262, 242], [116, 152])],
          z=0, material="flame_soul_deep", kind="flat", opacity=0.5, blur=7,
          grad={"to": "soul_blue_dark", "y0": 60, "y1": 300}),
        F("sf_base", [P("circle", [CX, 290], [238, 66])],
          z=0.5, material="flame_soul_inner", kind="flat", emit=0.4,
          glow={"radius": 11, "opacity": 0.45, "color": "soul_blue_pale"}),
        F("sf_ta", [P("droplet", [140, 202], [66, 196], rot=-7)], z=1, material="flame_soul",
          emit=0.75, glow={"radius": 4, "opacity": 0.4, "color": "soul_blue"}),
        F("sf_tb", [P("droplet", [248, 214], [58, 170], rot=8)], z=1, material="flame_soul",
          emit=0.75, glow={"radius": 4, "opacity": 0.4, "color": "soul_blue"}),
        F("sf_tc", [P("droplet", [192, 174], [74, 250], rot=-1)], z=1, material="flame_soul",
          emit=0.8, glow={"radius": 5, "opacity": 0.45, "color": "soul_blue"}),
        F("sf_td", [P("droplet", [168, 226], [48, 148], rot=-13)], z=1, material="flame_soul",
          emit=0.7, glow={"radius": 3, "opacity": 0.35, "color": "soul_blue"}),
        F("sf_te", [P("droplet", [220, 236], [44, 132], rot=12)], z=1, material="flame_soul",
          emit=0.7, glow={"radius": 3, "opacity": 0.35, "color": "soul_blue"}),
        F("sf_ia", [P("droplet", [172, 246], [40, 142], rot=-5)], z=2, material="flame_soul_inner",
          emit=0.9, glow={"radius": 3, "opacity": 0.5, "color": "soul_blue_pale"}),
        F("sf_ib", [P("droplet", [218, 254], [32, 112], rot=6)], z=2, material="flame_soul_inner",
          emit=0.9, glow={"radius": 3, "opacity": 0.5, "color": "soul_blue_pale"}),
        F("sf_ca", [P("droplet", [196, 270], [28, 96])], z=3, material="flame_soul_core",
          emit=1.0, glow={"radius": 3, "opacity": 0.7, "color": "soul_white"}),
        F("sf_cb", [P("droplet", [164, 280], [19, 60], rot=-9)], z=3, material="flame_soul_core",
          emit=1.0, glow={"radius": 2, "opacity": 0.6, "color": "soul_white"}),
    ]
    for tag, dy0, sizes in (("sf_mA", 0, (9, 7, 6)), ("sf_mB", 44, (7, 6, 5))):
        forms.append(F(tag, [P("circle", [128, 232 - dy0], [sizes[0]]),
                             P("circle", [206, 186 - dy0], [sizes[1]]),
                             P("circle", [252, 258 - dy0], [sizes[2]])],
                       z=4, material="flame_soul_inner", kind="flat", emit=0.95,
                       glow={"radius": 2, "opacity": 0.6, "color": "soul_white"}))
    mv = {
        "sf_base": [{"pivot": [CX, BASE], "dy": d, "sx": s, "sy": s}
                    for d, s in zip([0, -3, -6, -8, -6, -3], [1, 1.05, 1.1, 1.13, 1.1, 1.05])],
        "sf_ta": [{"pivot": [140, BASE], "dy": d, "sx": s, "rot": r}
                  for d, s, r in zip([0, -4, -9, -13, -9, -4], [1, .96, .9, .84, .9, .96],
                                     [0, -2, 2, 0, 2, -2])],
        "sf_tb": [{"pivot": [248, BASE], "dy": d, "sx": s, "rot": r}
                  for d, s, r in zip([0, -3, -7, -11, -7, -3], [1, .97, .92, .86, .92, .97],
                                     [0, 2, -2, 0, -2, 2])],
        "sf_tc": [{"pivot": [192, BASE], "dy": d, "sx": s}
                  for d, s in zip([0, -6, -13, -19, -13, -6], [1, .95, .88, .8, .88, .95])],
        "sf_td": [{"pivot": [168, BASE], "dy": d, "sx": s}
                  for d, s in zip([0, -3, -7, -10, -7, -3], [1, .96, .9, .85, .9, .96])],
        "sf_te": [{"pivot": [220, BASE], "dy": d, "sx": s}
                  for d, s in zip([0, -2, -6, -9, -6, -2], [1, .97, .92, .87, .92, .97])],
        "sf_ia": [{"pivot": [172, BASE], "dy": d, "sx": s}
                  for d, s in zip([0, -4, -9, -13, -9, -4], [1, .94, .86, .78, .86, .94])],
        "sf_ib": [{"pivot": [218, BASE], "dy": d, "sx": s}
                  for d, s in zip([0, -3, -7, -11, -7, -3], [1, .95, .88, .8, .88, .95])],
        "sf_ca": [{"pivot": [196, BASE], "dy": d, "sx": s, "sy": s}
                  for d, s in zip([0, -4, -8, -12, -8, -4], [1, .95, .88, .8, .88, .95])],
        "sf_cb": [{"pivot": [164, BASE], "dy": d} for d in [0, -3, -6, -9, -6, -3]],
    }
    for tag in ("sf_mA", "sf_mB"):
        mv[tag] = [{"pivot": [128, BASE], "dy": -8, "sx": s, "sy": s}
                   for s in [1, .92, .84, .76, .68, .6]]
    fs = frames(6, mv)
    swap_sets(mv, fs, "sf_mA", "sf_mB", 3)
    return recipe("soul_fire_flame", (384, 384), (CX, 316), 1201, forms, fs,
                  "soul_fire_flame (blue soul fire, idle burn). 6 frames, slow. Five thin "
                  "droplet tongues that narrow as they climb (0.80x at the tip, -19 px), a pale "
                  "inner tier, a white core, a wide low base glow, a dark blue haze, and two "
                  "ember sets that swap at frame 3 so the rise never pops.",
                  "floor point under the flame base")


# ================================================================ 2 copper fire
def copper_fire():
    """Green copper fire: fat plate lobes, an open hollow core, fast sputter."""
    CX, BASE = 192, 304
    forms = [
        F("cf_halo", [P("circle", [CX, 296], [268, 76])],
          z=0, kind="flat", material="flame_copper_deep", opacity=0.5, blur=9,
          grad={"to": "copper_green_dark", "y0": 240, "y1": 310}),
        F("cf_pool", [P("circle", [CX, 298], [214, 60], crop=[1.5, 6.5, 14.5, 16])],
          z=0.5, kind="flat", material="flame_copper_deep", emit=0.25, opacity=0.95),
        F("cf_plate", [
            P("droplet", [124, 240], [156, 196], rot=-92),
            P("droplet", [262, 244], [146, 180], rot=90),
            P("droplet", [192, 296], [124, 128], rot=180),
            P("circle", [192, 226], [86, 132], op="sub"),
        ], z=1, kind="flat", material="flame_copper", emit=0.7,
          glow={"radius": 6, "opacity": 0.45, "color": "copper_green"}),
        F("cf_gap", [P("circle", [192, 224], [78, 128])],
          z=1.2, kind="flat", material="flame_copper_deep", opacity=0.92),
        F("cf_gap_heat", [P("circle", [192, 246], [62, 92])],
          z=1.4, kind="flat", material="flame_copper_core", emit=0.55, opacity=0.5,
          glow={"radius": 6, "opacity": 0.4, "color": "copper_green_pale"}),
        F("cf_seams", [
            P("circle", [140, 218], [6, 150], rot=18),
            P("circle", [244, 222], [6, 140], rot=-20),
            P("circle", [192, 268], [112, 5], rot=4),
            P("circle", [176, 200], [5, 78], rot=8),
        ], z=2, kind="flat", material="rewind", opacity=0.75, line=False),
        F("cf_rims", [P("droplet", [104, 206], [64, 84], rot=-64),
                      P("droplet", [282, 214], [58, 76], rot=62)],
          z=2.2, kind="flat", material="flame_copper_core", emit=0.95,
          glow={"radius": 3, "opacity": 0.6, "color": "copper_green_pale"}),
        F("cf_lump", [P("circle", [148, 188], [58, 50])], z=2.3, kind="flat",
          material="flame_copper", emit=0.6,
          glow={"radius": 4, "opacity": 0.4, "color": "copper_green"}),
    ]
    for tag, dy0, sizes in (("cf_sA", 0, (11, 9, 13, 7)), ("cf_sB", 46, (9, 8, 11, 6))):
        forms.append(F(tag, [P("circle", [120, 168 - dy0], [sizes[0]]),
                             P("circle", [186, 132 - dy0], [sizes[1]]),
                             P("star", [246, 176 - dy0], [sizes[2]], rot=12),
                             P("circle", [160, 112 - dy0], [sizes[3]])],
                       z=3, kind="flat", material="copper_gold", emit=1.0,
                       glow={"radius": 2, "opacity": 0.65, "color": "copper_gold"}))
    mv = {
        "cf_pool": [{"pivot": [CX, BASE], "sx": s, "sy": s} for s in [1, 1.05, 1.1, 1.05, 1, .97]],
        "cf_plate": [{"pivot": [CX, BASE], "sx": s, "sy": s, "dy": d}
                     for s, d in zip([1, .97, .93, .97, 1, 1.02], [0, -3, -6, -3, 0, -2])],
        "cf_gap": [{"pivot": [CX, BASE], "sx": s, "sy": s} for s in [1, 1.12, 1.26, 1.12, 1, .96]],
        "cf_gap_heat": [{"pivot": [CX, BASE], "sy": s} for s in [1, 1.1, 1.2, 1.1, 1, .95]],
        "cf_seams": [{"dx": d} for d in [0, 2, 4, 2, 0, -2]],
        "cf_rims": [{"pivot": [CX, 290], "sx": s, "sy": s} for s in [1, 1.06, 1.12, 1.06, 1, .97]],
        "cf_lump": [{"pivot": [148, 214], "dy": d, "sx": s}
                    for d, s in zip([0, -4, -8, -12, -8, -4], [1, .96, .9, .84, .9, .96])],
    }
    for tag in ("cf_sA", "cf_sB"):
        mv[tag] = [{"pivot": [120, BASE], "dy": -14, "sx": s, "sy": s}
                   for s in [1, .88, .76, .64, .52, .4]]
    fs = frames(6, mv)
    swap_sets(mv, fs, "cf_sA", "cf_sB", 3)
    return recipe("copper_fire_flame", (384, 384), (CX, 320), 1202, forms, fs,
                  "copper_fire_flame (green copper/bug fire). 6 frames, fast. Deliberately not "
                  "the soul flame: three fat horizontal droplet plates, a dark hollow carved "
                  "down the middle by a subtraction, four bronze plate seams, a loose lump that "
                  "bobs, and a fast -14 px per frame sputter of gold sparks and stars.",
                  "floor point under the flame base")


# ======================================================================= 3 lava
def lava():
    """Molten pool lying on the ground: dark crust plates over hot veins."""
    CX, GY = 192, 300
    veins = [[118, 274, -14], [162, 292, 8], [206, 272, -6], [250, 296, 16],
             [140, 312, -22], [224, 318, 6], [190, 256, 4]]
    forms = [
        F("lv_shadow", [P("square", [CX + 6, GY + 4], [320, 108], slice={"border": 4, "corner": 40})],
          z=-2, kind="shadow", color="shadow_contact", opacity=0.4, blur=11),
        F("lv_halo", [P("circle", [CX, GY - 6], [300, 96], ground=True)],
          z=-1.5, kind="flat", material="lava_mid", opacity=0.45,
          glow={"radius": 16, "opacity": 0.4, "color": "lava_hot"}),
        F("lv_crust", [P("circle", [CX, GY - 8], [312, 112], ground=True),
                       P("circle", [96, GY - 14], [96, 56], ground=True),
                       P("circle", [286, GY - 10], [88, 52], ground=True),
                       P("circle", [CX, GY - 40], [120, 44], ground=True)],
          z=0, kind="flat", material="lava_crust",
          rough={"amp": 0.5, "soft": 3, "cell": 16},
          mottle={"cell": 46, "lo": 0.62, "hi": 0.9}),
        F("lv_melt", [P("circle", [CX, GY - 2], [246, 84], ground=True),
                      P("circle", [120, GY + 4], [70, 34], ground=True),
                      P("circle", [268, GY - 2], [66, 32], ground=True),
                      P("circle", [CX, GY - 16], [120, 40], ground=True),
                      P("circle", [88, GY - 6], [46, 26], ground=True, op="sub"),
                      P("circle", [300, GY - 8], [44, 24], ground=True, op="sub")],
          z=1, kind="flat", material="lava_molt", emit=0.3,
          rough={"amp": 0.55, "soft": 3, "cell": 14},
          glow={"radius": 7, "opacity": 0.4, "color": "lava_hot"}),
        F("lv_veins", [P("lightning_bolt", v[:2], [13, 30], rot=v[2]) for v in veins],
          z=2, kind="flat", material="lava_vein", emit=1.0, clip_to="lv_melt",
          glow={"radius": 4, "opacity": 0.6, "color": "lava_vein"}),
        F("lv_slabs", [
            P("square", [140, 268], [70, 20], ground=True, rot=6),
            P("square", [232, 284], [86, 22], ground=True, rot=-8),
            P("circle", [186, 300], [60, 24], ground=True),
            P("square", [272, 262], [44, 16], ground=True, rot=14),
        ], z=3, kind="flat", material="lava_crust",
          rough={"amp": 0.4, "soft": 2, "cell": 12}),
        F("lv_bubbles", [P("circle", [148, 262], [16, 9], ground=True),
                         P("circle", [232, 292], [13, 8], ground=True),
                         P("circle", [188, 274], [11, 7], ground=True)],
          z=4, kind="flat", material="lava_vein", emit=0.7,
          glow={"radius": 3, "opacity": 0.5, "color": "lava_vein"}),
    ]
    for tag, dy0, xs in (("lv_heatA", 0, (108, 168, 238, 288)), ("lv_heatB", 40, (108, 168, 238, 288))):
        forms.append(F(tag, [P("circle", [x, 232 - dy0], [11, 15]) for x in xs],
                       z=5, kind="flat", material="lava_vein", emit=0.9,
                       glow={"radius": 3, "opacity": 0.55, "color": "lava_vein"}))
    mv = {
        "lv_halo": [{"pivot": [CX, GY], "sy": s, "sx": s} for s in [1, 1.04, 1.08, 1.04, 1, .98]],
        "lv_crust": [{"pivot": [CX, GY], "sx": s, "sy": s} for s in [1, 1.01, 1.02, 1.01, 1, .99]],
        "lv_melt": [{"pivot": [CX, GY], "sx": s, "sy": s, "dy": d}
                    for s, d in zip([1, 1.03, 1.06, 1.03, 1, .98], [0, -2, -4, -2, 0, -1])],
        "lv_veins": [{"pivot": [CX, GY], "dx": d, "sx": s}
                     for d, s in zip([0, 3, 6, 3, 0, -3], [1, 1.02, 1.05, 1.02, 1, .99])],
        "lv_slabs": [{"pivot": [CX, GY], "sx": s, "rot": r}
                     for s, r in zip([1, 1.01, 1.02, 1.01, 1, .99], [0, .8, 1.4, .8, 0, -.6])],
        "lv_bubbles": [{"pivot": [CX, GY], "sy": s} for s in [1, 1.12, 1.24, 1.12, 1, .95]],
    }
    for tag in ("lv_heatA", "lv_heatB"):
        mv[tag] = [{"pivot": [108, GY], "dy": -9, "sx": s, "sy": s}
                   for s in [1, .9, .8, .7, .6, .5]]
    fs = frames(6, mv)
    swap_sets(mv, fs, "lv_heatA", "lv_heatB", 3)
    return recipe("lava", (384, 384), (CX, 306), 1203, forms, fs,
                  "lava (molten ground splash). 6 frames, ground-squashed. Ragged mottled dark "
                  "crust with holes, a breathing molten pool, seven lava veins clipped to it, "
                  "four dark slabs floating on the melt, three breathing bubbles, two rising "
                  "heat columns. Wide irregular pool silhouette, unique in this job.",
                  "ground contact point of the pool, centre")


# ============================================================ 4 damage indicator
def damage():
    """Impact: radiating blood shards, expanding ring, shrinking flash."""
    CX, CY = 96, 92
    shards = ring_spots(CX, CY, 48, 9, a0=-90, rot="radial")
    drops = ring_spots(CX, CY, 62, 11, a0=-70, rj=0.3)
    forms = [
        F("dm_halo", [P("circle", [CX, CY], [70, 70])], z=0, kind="flat",
          material="blood_wet", opacity=0.4, blur=8,
          glow={"radius": 10, "opacity": 0.35, "color": "blood_wet"}),
        F("dm_ring", [P("ring", [CX, CY], [104, 100], crop=[0.6, 4.4, 15.4, 11.6])],
          z=1, kind="flat", material="blood_wet", emit=0.4, line=False,
          glow={"radius": 3, "opacity": 0.4, "color": "blood_wet"}),
        F("dm_shards", [P("droplet", s[:2], [15, 34], rot=s[2]) for s in shards],
          z=2, kind="flat", material="blood", emit=0.45, line=False,
          glow={"radius": 2, "opacity": 0.35, "color": "blood_wet"}),
        F("dm_spit", [P("circle", d[:2], [10, 12]) for d in drops],
          z=2.2, kind="flat", material="blood", line=False),
        F("dm_core", [P("circle", [CX, CY], [34, 32]), P("circle", [CX, CY], [20, 18])],
          z=3, kind="flat", material="blood_flash", emit=1.0, line=False,
          glow={"radius": 6, "opacity": 0.75, "color": "blood_flash"}),
    ]
    pulse = [0.5, 0.86, 1.14, 0.86]
    mv = {
        "dm_halo": [{"pivot": [CX, CY], "sx": s, "sy": s} for s in pulse],
        "dm_ring": [{"pivot": [CX, CY], "sx": s, "sy": s} for s in pulse],
        "dm_shards": [{"pivot": [CX, CY], "sx": s, "sy": s} for s in pulse],
        "dm_spit": [{"pivot": [CX, CY], "sx": s, "sy": s} for s in [0.6, 1.0, 1.2, 1.0]],
        "dm_core": [{"pivot": [CX, CY], "sx": s, "sy": s} for s in [1.15, 0.72, 0.34, 0.72]],
    }
    return recipe("damage_indicator", (192, 192), (CX, 160), 1204, forms, frames(4, mv),
                  "damage_indicator (took a hit). 4 frames, symmetric pulse so the loop is "
                  "seamless. Nine tapered blood shards thrown outward on a 48 px ring, a thick "
                  "ring that expands, eleven spatter drops on a wider jittered ring, and a "
                  "bone-pale flash core that shrinks as the ring grows. Sharp radial "
                  "silhouette, not a recoloured disc.",
                  "point under the impact, low on the body")


# =============================================================== 5 angry villager
def angry_villager():
    """Villager bust leaning forward, squint eyes, bared teeth, red heat."""
    forms = [
        F("av_shadow", [P("circle", [100, 176], [128, 24])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.36, blur=5),
        F("av_hood", [P("droplet", [100, 100], [112, 126], rot=180)], z=1, material="coat_dark"),
        F("av_body", [P("mountains", [100, 152], [146, 68])], z=1.5, material="coat"),
        F("av_scarf", [P("mountains", [100, 132], [120, 30], crop=[1, 6, 15, 16])],
          z=2, material="scarf"),
        F("av_head", [P("circle", [100, 84], [92, 96])], z=3, material="skin",
          shade={"highlight_amount": 0.4}),
        F("av_brow", [P("circle", [78, 68], [30, 8], rot=-20),
                      P("circle", [122, 68], [30, 8], rot=20)],
          z=4, kind="flat", material="coat_seam", line=False),
        F("av_eyes", [P("circle", [80, 82], [24, 5], rot=-15),
                      P("circle", [120, 82], [24, 5], rot=15)],
          z=4.5, kind="flat", material="eye", line=False),
        F("av_nose", [P("circle", [100, 98], [10, 8])], z=4.5, kind="flat",
          material="skin_shadow", line=False),
        F("av_mouth", [P("circle", [100, 116], [60, 28]),
                       P("circle", [100, 104], [70, 24], op="sub")],
          z=4.6, kind="flat", material="coat_seam", line=False),
        F("av_teeth", [P("square", [88, 109], [13, 10], slice={"border": 2, "corner": 2}),
                       P("square", [112, 109], [13, 10], slice={"border": 2, "corner": 2})],
          z=4.7, kind="flat", material="paper", line=False),
        F("av_vein", [P("circle", [66, 100], [16, 4], rot=-26),
                      P("circle", [134, 100], [16, 4], rot=26),
                      P("circle", [88, 122], [12, 4], rot=16)],
          z=4.8, kind="flat", material="heat_red", emit=0.5, line=False,
          glow={"radius": 2, "opacity": 0.4, "color": "heat_red_light"}),
        F("av_heat", [P("lightning_bolt", [70, 44], [11, 28], rot=8),
                      P("lightning_bolt", [100, 30], [12, 32], rot=-6),
                      P("lightning_bolt", [130, 46], [10, 26], rot=12)],
          z=5, kind="flat", material="heat_red", emit=0.75, tags=["av_heat"], line=False,
          glow={"radius": 3, "opacity": 0.5, "color": "heat_red_light"}),
    ]
    for form in forms:
        if form["name"] != "av_heat":
            form["tags"] = list(form.get("tags", [])) + ["av_bust"]
    bust = [{"pivot": [100, 178], "dy": d, "dx": x, "sx": s, "sy": s2} for d, x, s, s2 in
            zip([0, 5, 3, 0], [0, 3, -1, 0], [1, 1.05, 1.02, 1], [1, 1.04, 1.01, 1])]
    mv = {"av_bust": bust,
          "av_heat": [{"pivot": [100, 60], "dy": d} for d in [0, -6, -12, -6]]}
    return recipe("angry_villager", (192, 192), (100, 180), 1205, forms, frames(4, mv),
                  "angry_villager (hostile villager state). 4 frames. Read from the face, not "
                  "from a symbol: hooded bust, brows slanted the wrong way, eyes squinted to "
                  "thin slanted slits, an open mouth with two bone teeth, cheek veins, and a red "
                  "heat plume that rises -12 px. The whole bust lunges forward (dy +5, 1.05x) "
                  "then settles. Opposite silhouette to happy_villager.",
                  "floor point under the bust")


# ============================================================== 6 happy villager
def happy_villager():
    """Villager bust bouncing: round staring eyes, wide open smile, warm halo."""
    forms = [
        F("hv_shadow", [P("circle", [96, 178], [124, 22])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.34, blur=5, tags=["hv_shadow"]),
        F("hv_hood", [P("droplet", [96, 106], [114, 132], rot=180)], z=1, material="coat_top",
          tags=["hv_all"]),
        F("hv_body", [P("mountains", [96, 154], [150, 70])], z=1.5, material="coat", tags=["hv_all"]),
        F("hv_scarf", [P("mountains", [96, 136], [122, 30], crop=[1, 6, 15, 16])],
          z=2, material="scarf", tags=["hv_all"]),
        F("hv_halo", [P("circle", [96, 78], [126, 126])], z=2.5, kind="flat",
          material="lamp_amber", opacity=0.22, blur=9, tags=["hv_all"],
          glow={"radius": 12, "opacity": 0.3, "color": "lamp_glow"}),
        F("hv_head", [P("circle", [96, 82], [94, 96])], z=3, material="skin", tags=["hv_all"],
          shade={"highlight_amount": 0.4}),
        F("hv_brow", [P("circle", [70, 58], [22, 6], rot=26),
                      P("circle", [122, 58], [22, 6], rot=-26)],
          z=4, kind="flat", material="coat_seam", tags=["hv_all"], line=False),
        F("hv_eye", [P("circle", [70, 80], [32, 34]), P("circle", [122, 80], [32, 34])],
          z=4.2, kind="flat", material="paper", tags=["hv_all"], line=False),
        F("hv_pupil", [P("circle", [70, 82], [14, 16]), P("circle", [122, 82], [14, 16])],
          z=4.4, kind="flat", material="eye", tags=["hv_all"], line=False),
        F("hv_blush", [P("circle", [58, 102], [24, 14]), P("circle", [134, 102], [24, 14])],
          z=4.3, kind="flat", material="heart_light", opacity=0.55, tags=["hv_all"], line=False),
        F("hv_mouth", [P("circle", [96, 114], [58, 44]),
                       P("circle", [96, 94], [68, 36], op="sub")],
          z=4.5, kind="flat", material="coat_seam", tags=["hv_all"], line=False),
        F("hv_tongue", [P("circle", [96, 130], [32, 12])],
          z=4.6, kind="flat", material="heart_light", tags=["hv_all"], line=False,
          clip_to="hv_mouth"),
        F("hv_spark", [P("ring", [58, 44], [26, 26], crop=[2, 2, 14, 14]),
                       P("ring", [96, 24], [30, 30], crop=[2, 2, 14, 14]),
                       P("ring", [136, 46], [24, 24], crop=[2, 2, 14, 14])],
          z=5, kind="flat", material="lamp_amber", emit=0.8, tags=["hv_spark"], line=False,
          glow={"radius": 3, "opacity": 0.55, "color": "lamp_glow"}),
    ]
    bounce_dy = [0, -10, -2, 0]
    stretch = [(1, 1), (0.93, 1.09), (1.07, 0.92), (1, 1)]
    mv = {
        "hv_all": [{"pivot": [96, 178], "dy": d, "sx": s, "sy": s2}
                   for d, (s, s2) in zip(bounce_dy, stretch)],
        "hv_shadow": [{"pivot": [96, 178], "sx": s, "sy": s2}
                      for (s, s2) in [(1, 1), (0.86, 0.6), (1.1, 1.14), (1, 1)]],
        "hv_spark": [{"pivot": [96, 70], "dy": d, "sx": s, "sy": s}
                     for d, s in zip([0, -5, -10, -5], [1, 1.12, 1.22, 1.12])],
    }
    return recipe("happy_villager", (192, 192), (96, 182), 1206, forms, frames(4, mv),
                  "happy_villager (pleased villager state). 4 frames. Same bust as "
                  "angry_villager with an opposite silhouette: eyes are big round discs with "
                  "pupils, the mouth is a wide toothless smile, the body squashes and stretches "
                  "and hops (dy -10, 0.93x / 1.09y), the shadow shrinks with the hop, and three "
                  "warm rings float up instead of red heat bolts.",
                  "floor point under the bust")


# =========================================================== 7 pause mob growth
def pause_growth():
    """Frozen growth bar: upright frosted column, chain, hanging pause plaque."""
    BX = 96
    forms = [
        F("pm_shadow", [P("circle", [BX, 186], [88, 11])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.34, blur=4),
        F("pm_track", [P("square", [BX, 80], [38, 118], slice={"border": 4, "corner": 9}),
                       P("square", [BX, 80], [25, 106], slice={"border": 3, "corner": 6}, op="sub")],
          z=1, material="iron"),
        F("pm_fill", [P("square", [BX, 120], [25, 46], slice={"border": 3, "corner": 6})],
          z=2, kind="flat", material="frost",
          grad={"to": "frost_white", "y0": 145, "y1": 95}),
        F("pm_crust", [P("mountains", [BX, 90], [38, 17]),
                       P("droplet", [BX - 8, 103], [7, 17], rot=180),
                       P("droplet", [BX + 7, 105], [6, 13], rot=180)],
          z=3, kind="flat", material="frost_ice", emit=0.22, tags=["pm_crust"], line=False,
          glow={"radius": 3, "opacity": 0.35, "color": "frost_white"}),
        F("pm_ice1", [P("snowflake", [BX, 58], [26, 26], rot=10)],
          z=3.2, kind="flat", material="frost_ice", emit=0.3, tags=["pm_ice1"], line=False,
          glow={"radius": 3, "opacity": 0.4, "color": "frost_white"}),
        F("pm_ice2", [P("snowflake", [BX + 8, 32], [17, 17], rot=-16)],
          z=3.2, kind="flat", material="frost_pale", emit=0.2, tags=["pm_ice2"], line=False),
        F("pm_chain", [P("link", [BX, 146], [9, 9], rot=45, crop=[4, 4, 12, 12]),
                       P("link", [BX, 155], [9, 9], rot=45, crop=[4, 4, 12, 12])],
          z=3.4, kind="flat", material="iron", line={"width": 0.5, "heavy": 0.3}),
        F("pm_sign_rim", [P("square", [BX, 170], [72, 40], slice={"border": 4, "corner": 9})],
          z=3.5, material="iron"),
        F("pm_sign_face", [P("square", [BX, 170], [64, 33], slice={"border": 4, "corner": 8})],
          z=3.6, kind="flat", material="frost", grad={"to": "frost_deep", "y0": 156, "y1": 185}),
        F("pm_bars", [P("square", [BX - 10, 170], [11, 24], slice={"border": 2, "corner": 3}),
                      P("square", [BX + 10, 170], [11, 24], slice={"border": 2, "corner": 3})],
          z=3.7, kind="flat", material="frost_ice", line=False,
          glow={"radius": 2, "opacity": 0.3, "color": "frost_white"}),
    ]
    mv = {
        "pm_crust": [{"pivot": [BX, 144], "sy": s} for s in [1, 1.1, 1.2, 1.1]],
        "pm_ice1": [{"pivot": [BX, 144], "dy": d, "sx": s, "sy": s}
                    for d, s in zip([0, 3, 6, 3], [1, 1.04, 1.08, 1.04])],
        "pm_ice2": [{"pivot": [BX, 144], "dy": d, "sx": s, "sy": s}
                    for d, s in zip([0, 1.5, 3, 1.5], [1, 1.05, 1.1, 1.05])],
    }
    return recipe("pause_mob_growth", (192, 192), (BX, 192), 1207, forms, frames(4, mv),
                  "pause_mob_growth (growth suspended). 4 frames. Upright and vertical on "
                  "purpose: an iron slot, a frosted column that stops part way with a jagged ice "
                  "crust and two hanging icicles, two snowflake frost marks creeping down the "
                  "empty slot, then a chain and a frozen plaque carrying two vertical bars. "
                  "Only the frost moves; the plaque never does.",
                  "floor point under the hanging plaque")


# ========================================================== 8 reset mob growth
def reset_growth():
    """Rewind: a pointer orbiting a bronze ring, a bar that shrinks, falling chips."""
    CXR, CYR, R, RT = 112, 76, 55, 70
    n = 8
    shrink = [1, .93, .86, .79, .72, .65, .58, .51]
    forms = [
        F("rm_shadow", [P("circle", [82, 178], [128, 18])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.34, blur=5),
        F("rm_bar", [P("square", [41, 138], [26, 78], slice={"border": 4, "corner": 6}),
                     P("mountains", [41, 108], [36, 20], op="sub")],
          z=1, material="stone_dark", pivot=[41, 176]),
        F("rm_bar_glass", [P("square", [41, 136], [19, 70], slice={"border": 3, "corner": 4})],
          z=1.5, kind="flat", material="frost_deep", opacity=0.9, tags=["rm_bar"]),
        F("rm_pile", [P("circle", [41, 174], [46, 20]), P("circle", [24, 178], [26, 12])],
          z=2, material="rubble"),
        F("rm_core", [P("circle", [CXR, CYR], [82, 82])],
          z=3, kind="flat", material="rewind_dark", line=False),
        F("rm_band", [P("ring", [CXR, CYR], [124, 124]),
                      P("circle", [CXR, CYR], [94, 94], op="sub")],
          z=3.5, material="rewind", shade={"highlight": 0.84, "highlight_amount": 0.7}),
        F("rm_head", [P("triangle", [CXR, CYR - R], [20, 20]),
                      P("square", [CXR - 26, CYR - R + 8], [14, 7], slice={"border": 2, "corner": 2}),
                      P("square", [CXR + 26, CYR - R + 8], [14, 7], slice={"border": 2, "corner": 2}),
                      P("square", [CXR, CYR - R + 24], [14, 7], slice={"border": 2, "corner": 2})],
          z=4, material="rewind", pivot=[CXR, CYR],
          glow={"radius": 3, "opacity": 0.3, "color": "rewind_bright"}),
        F("rm_tip", [P("circle", [CXR, CYR - RT], [16, 16])],
          z=5, kind="flat", material="lamp_amber", emit=0.85, line=False,
          glow={"radius": 3, "opacity": 0.55, "color": "lamp_glow"}),
    ]
    for i in range(n):
        forms.append(F("rm_chip%d" % i,
                       [P("square", [41, 104], [14, 12], slice={"border": 2, "corner": 2},
                          rot=18 - i * 5)],
                       z=6, material="rubble", tags=["chip%d" % i]))
    def orb(r, i):
        a = math.radians(-90 + 360.0 * i / n)
        return [round(r * math.cos(a), 2), round(r * math.sin(a), 2)]
    fs = []
    for i in range(n):
        f = {"name": "f%d" % i}
        m = {"rm_bar": {"pivot": [41, 176], "sy": shrink[i]},
             "rm_bar_glass": {"pivot": [41, 176], "sy": shrink[i]},
             "rm_head": {"pivot": [CXR, CYR], "rot": -360.0 * i / n}}
        if i == 0:
            m["rm_tip"] = {"pivot": [CXR, CYR], "dx": 0, "dy": 0}
        else:
            a, b = orb(RT, i), orb(RT, i - 1)
            m["rm_tip"] = {"pivot": [CXR, CYR], "dx": round(a[0] - b[0], 2), "dy": round(a[1] - b[1], 2)}
        m["chip%d" % i] = [0, 11 * i]
        f["move"] = m
        f["hide"] = ["chip%d" % k for k in range(n) if k != i]
        f["show"] = ["chip%d" % i]
        fs.append(f)
    return recipe("reset_mob_growth", (192, 192), (82, 182), 1208, forms, fs,
                  "reset_mob_growth (growth reset). 8 frames, circular and warm instead of the "
                  "frozen vertical bar. A bronze ring (ring icon minus an inner disc) carries a "
                  "pointer cluster that orbits a full 360 deg in 45 deg steps, so the loop is "
                  "seamless; a lit tip rides 15 px ahead of it; the spent bar on the left "
                  "shrinks to 0.51x about its base while eight chips fall one per frame into "
                  "the rubble pile.",
                  "floor point under the rubble pile")


# ======================================================================= 9 heart
def heart():
    """Wine-red heart, three-tone, four-frame beat."""
    forms = [
        F("ht_halo", [P("heart", [96, 98], [156, 152])], z=0, kind="flat",
          material="heart_dark", opacity=0.4, blur=3, emit=0.3, tags=["ht_halo"],
          glow={"radius": 15, "opacity": 0.32, "color": "heart_wine"}),
        F("ht_rim", [P("heart", [96, 98], [124, 120])], z=1, material="heart_dark", tags=["ht_body"]),
        F("ht_body", [P("heart", [96, 96], [112, 108])], z=2, material="heart_tissue"),
        F("ht_gloss", [P("circle", [76, 72], [34, 22], rot=-32)], z=3, kind="flat",
          material="heart_light", opacity=0.6, clip_to="ht_body", tags=["ht_body"], line=False),
        F("ht_gloss2", [P("circle", [86, 80], [18, 12], rot=-32)], z=3.2, kind="flat",
          material="paper", opacity=0.5, clip_to="ht_body", tags=["ht_body"], line=False),
    ]
    beat = [0.9, 1.11, 0.94, 1.06]
    mv = {
        "ht_body": [{"pivot": [96, 100], "sx": s, "sy": s, "dy": d}
                    for s, d in zip(beat, [0, -2, 1, -1])],
        "ht_halo": [{"pivot": [96, 100], "sx": s, "sy": s} for s in [1.0, 1.1, 1.0, 1.05]],
    }
    return recipe("heart", (192, 192), (96, 100), 1209, forms, frames(4, mv),
                  "heart (health / regard). 4 frames, lub-dub beat 0.90 / 1.11 / 0.94 / 1.06. "
                  "A dark rim under a wine-red body so all three tones read, two gloss "
                  "highlights clipped to the heart, and a soft wine halo that is its own "
                  "_emit layer. Muted red, no fluorescent pink.",
                  "centre of the heart (floats, no floor contact)")


# ============================================================== 10 elder guardian
def elder_guardian():
    """Upright sentinel: crested helm, glowing eye slit, long beard, stone footing."""
    forms = [
        F("eg_shadow", [P("circle", [96, 180], [118, 20])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.42, blur=6, tags=["eg_body"]),
        F("eg_feet", [P("droplet", [60, 172], [26, 16], rot=180),
                      P("droplet", [132, 172], [26, 16], rot=180)],
          z=1, material="stone_dark", tags=["eg_body"]),
        F("eg_base", [P("square", [96, 164], [104, 20], slice={"border": 4, "corner": 7})],
          z=1.5, kind="block", material="stone", extrude=8, tags=["eg_body"]),
        F("eg_tabard", [P("square", [96, 120], [72, 82], slice={"border": 4, "corner": 6}),
                        P("mountains", [96, 150], [74, 22])],
          z=2, material="coat", tags=["eg_body"]),
        F("eg_studs", [P("circle", [74, 126], [8, 8]), P("circle", [118, 126], [8, 8])],
          z=2.5, kind="flat", material="bronze", tags=["eg_body"], line=False),
        F("eg_hood", [P("droplet", [96, 90], [98, 104], rot=180)],
          z=3, material="coat_dark", tags=["eg_body"]),
        F("eg_beard", [P("droplet", [96, 102], [50, 58], rot=180),
                       P("droplet", [72, 112], [22, 42], rot=172),
                       P("droplet", [120, 112], [22, 42], rot=188)],
          z=4, material="paper", tags=["eg_body"], shade={"highlight_amount": 0.4}),
        F("eg_helm", [P("square", [96, 66], [70, 46], slice={"border": 4, "corner": 10}),
                      P("square", [96, 74], [8, 28], slice={"border": 2, "corner": 2})],
          z=5, material="iron", tags=["eg_body"],
          shade={"highlight": 0.84, "highlight_amount": 0.6}),
        F("eg_crest", [P("triangle", [96, 38], [26, 30])], z=5.5, material="bronze", tags=["eg_body"]),
        F("eg_crest2", [P("square", [96, 44], [40, 6], slice={"border": 2, "corner": 2})],
          z=5.6, kind="flat", material="iron", tags=["eg_body"], line=False),
        F("eg_eye", [P("square", [96, 64], [46, 9], slice={"border": 2, "corner": 2})],
          z=6, kind="flat", material="lamp_eye", emit=1.0, tags=["eg_eye"], line=False,
          glow={"radius": 6, "opacity": 0.65, "color": "lamp_glow"}),
        F("eg_breath", [P("cloud", [96, 122], [42, 18])], z=6.2, kind="flat", material="steam",
          opacity=0.22, tags=["eg_breath"], line=False),
        F("eg_dust", [P("circle", [64, 174], [26, 12]), P("circle", [130, 176], [22, 10])],
          z=6.5, kind="flat", material="rubble", opacity=0.55, tags=["eg_dust"], line=False),
    ]
    mv = {
        "eg_body": [{"pivot": [96, 180], "rot": r, "dy": d} for r, d in
                    zip([0, 2.2, 0, -2.2], [0, 1, 0, 1])],
        "eg_eye": [{"pivot": [96, 64], "sx": s} for s in [1, 0.66, 1, 1]],
        "eg_breath": [{"pivot": [96, 128], "dy": d, "sx": s} for d, s in
                      zip([0, -3, -6, -3], [1, 1.08, 1.16, 1.08])],
    }
    fs = frames(4, mv)
    for i, f in enumerate(fs):
        f["hide" if i < 2 else "show"] = ["eg_dust"]
    return recipe("elder_guardian", (192, 192), (96, 184), 1210, forms, fs,
                  "elder_guardian (elder sentinel state). 4 frames. A vertical standing "
                  "guardian, deliberately nothing like the nautilus spiral: crested iron helm, "
                  "one amber eye slit that narrows and reopens like a scan, a long bone beard, a "
                  "tabard on a stone footing with two root feet, dust kicked up on the return of "
                  "the sway. Whole figure rocks 2.2 deg about the floor point.",
                  "floor point between the feet")


# ==================================================================== 11 firefly
def firefly():
    """One firefly on a wandering path with a dotted wake."""
    PATH = [(96, 92), (130, 74), (141, 110), (112, 130), (66, 116), (58, 84)]
    n = len(PATH)
    x0, y0 = PATH[0]
    forms = [
        F("ff_glow", [P("circle", [x0, y0], [50, 50])], z=0, kind="flat", material="lamp_glow",
          opacity=0.5, blur=3, emit=0.7, glow={"radius": 13, "opacity": 0.55, "color": "lamp_glow"}),
        F("ff_body", [P("circle", [x0, y0], [21, 15])], z=2, material="ash"),
        F("ff_head", [P("circle", [x0 - 9, y0], [11, 10])], z=2.2, material="ash_far"),
        F("ff_wing", [P("droplet", [x0, y0 - 6], [22, 8], rot=-20),
                      P("droplet", [x0, y0 + 5], [22, 8], rot=200)],
          z=2.4, kind="flat", material="stone_cap", opacity=0.55, line=False),
        F("ff_core", [P("circle", [x0 - 8, y0], [14, 14])], z=3, kind="flat", material="flame",
          emit=1.0, line=False, glow={"radius": 4, "opacity": 0.8, "color": "flame_glow"}),
    ]
    TRAIL = 4
    for k in range(1, TRAIL + 1):
        bx, by = PATH[(-k) % n]
        s = round(11 - k * 1.8, 1)
        a = round(0.5 - k * 0.09, 2)
        forms.append(F("ff_t%d" % k, [P("circle", [bx, by], [s, s])], z=1, kind="flat",
                       material="lamp_amber", opacity=a, emit=a, tags=["tt%d" % k], line=False,
                       glow={"radius": 2, "opacity": 0.4, "color": "lamp_glow"}))

    def path_of(path):
        out = [None]
        for i in range(1, n):
            out.append([round(path[i][0] - path[i - 1][0], 2), round(path[i][1] - path[i - 1][1], 2)])
        return out

    mv = {}
    for tag in ("ff_glow", "ff_body", "ff_head", "ff_wing", "ff_core"):
        mv[tag] = path_of(PATH)
    for k in range(1, TRAIL + 1):
        mv["tt%d" % k] = path_of([PATH[(i - k) % n] for i in range(n)])
    # wings beat on the odd frames, and must still follow the body on the even ones
    flap = [1.0, 0.42, 1.0, 0.42, 1.0, 0.42]
    for i in range(n):
        if i == 0:
            mv["ff_wing"][i] = None
        elif i % 2 == 1:
            b = mv["ff_body"][i]
            mv["ff_wing"][i] = {"pivot": PATH[i - 1], "dx": b[0], "dy": b[1], "sy": flap[i]}
        else:
            mv["ff_wing"][i] = list(mv["ff_body"][i])
    pulse = [0.9, 1.14, 0.95, 1.1, 0.88, 1.12]
    for tag in ("ff_glow", "ff_core"):
        for i in range(n):
            d = {"sx": pulse[i], "sy": pulse[i]}
            if i > 0:
                d["dx"] = mv["ff_body"][i][0]
                d["dy"] = mv["ff_body"][i][1]
                d["pivot"] = PATH[i - 1]
            mv[tag][i] = d
    return recipe("firefly", (192, 192), (96, 116), 1211, forms, frames(n, mv),
                  "firefly (wisp insect). 6 frames. One insect on a 6-point wandering path; "
                  "body, head, wings, glow and abdomen core all ride the same path, and four "
                  "trail dots ride it one step apart so the flight leaves a dotted wake. Wings "
                  "beat on the odd frames (sy 0.42). Glow and core pulse out of phase, 0.88-1.14.",
                  "centre of the wander area (flies, no floor contact)")


# ==================================================================== 12 nautilus
def nautilus():
    """Chambered ammonite: logarithmic spiral, alternating chamber tones."""
    CX, CY, COIL = 96, 100, (94, 103)
    forms = [
        F("nn_shadow", [P("circle", [96, 96], [152, 148])], z=-1, kind="shadow",
          color="shadow_contact", opacity=0.3, blur=10, tags=["nn_all"]),
        F("nn_halo", [P("circle", [CX, 92], [176, 172])], z=0, kind="flat", material="nacre",
          opacity=0.18, blur=10, tags=["nn_halo"]),
        F("nn_band", [P("ring", [96, 88], [166, 158], crop=[0.3, 3.4, 15.7, 12.6])],
          z=1, material="shell", tags=["nn_all"]),
    ]
    for i in range(8):
        th = -1.45 + 0.58 * i
        r = 46.0 * math.exp(-0.285 * i)
        x = CX + r * math.cos(th)
        y = CY + r * math.sin(th)
        s = r * 1.86
        ux, uy = x - COIL[0], y - COIL[1]
        L = math.hypot(ux, uy) or 1.0
        sxc, syc = x - ux / L * s * 0.16, y - uy / L * s * 0.16
        forms.append(F("nn_c%d" % i, [
            P("circle", [round(x, 1), round(y, 1)], [round(s, 1)] * 2),
            P("circle", [round(sxc, 1), round(syc, 1)], [round(s * 0.84, 1)] * 2, op="sub"),
        ], z=2 + i, material="shell" if i % 2 == 0 else "shell_shadow", tags=["nn_ch"], line=False))
    forms += [
        F("nn_nacre", [P("circle", [110, 68], [56, 44], rot=-24)], z=11, kind="flat",
          material="nacre", opacity=0.42, tags=["nn_ch"], line=False, clip_to="nn_c0"),
        F("nn_septa", [P("spiral", [CX, 96], [148, 146])], z=12, kind="flat",
          material="shell_shadow", opacity=0.7, tags=["nn_ch"], line=False),
        F("nn_lip", [P("ring", [130, 84], [78, 138], crop=[8, 3, 16, 13])],
          z=13, material="shell", tags=["nn_all"]),
        F("nn_siphon", [P("circle", [136, 44], [20, 18])], z=14, material="shell", tags=["nn_all"]),
    ]
    n = 6
    mv = {
        "nn_all": [{"pivot": [CX, CY], "rot": r} for r in [0, 5, 10, 5, 0, -5]],
        "nn_ch": [{"pivot": [CX, CY], "rot": r, "sx": s, "sy": s}
                  for r, s in zip([0, 5, 10, 5, 0, -5], [1, 1.02, 1.05, 1.02, 1, .99])],
        "nn_halo": [{"pivot": [CX, CY], "rot": r, "sx": s}
                    for r, s in zip([0, 6, 12, 6, 0, -6], [1, 1.03, 1.06, 1.03, 1, .99])],
    }
    hl = []
    for i in range(n):
        a = math.radians(-90 + 60 * i)
        hl.append([round(64 * math.cos(a), 2), round(64 * math.sin(a) - 6, 2)])
    forms.append(F("nn_glint", [P("circle", [hl[0][0] + CX, hl[0][1] + CY], [26, 20], rot=-30)],
                   z=15, kind="flat", material="shell_pale", opacity=0.7, tags=["nn_glint"],
                   line=False, glow={"radius": 4, "opacity": 0.45, "color": "shell_pale"}))
    mv["nn_glint"] = [None] + [{"pivot": [CX, CY], "dx": d[0], "dy": d[1]} for d in hl[1:]]
    return recipe("nautilus", (192, 192), (96, 104), 1212, forms, frames(n, mv),
                  "nautilus (spiral shell sigil). 6 frames. Eight chambers placed on a "
                  "logarithmic spiral (r = 46 * e^-0.285i) with alternating shell / "
                  "shell_shadow tones, each with a subtracted inner disc that leaves a crescent "
                  "septal wall; an outer whorl band, a lip arc, a siphon knob and a spiral seam "
                  "line. A pale glint travels the whorl 60 deg per frame and the shell sways "
                  "10 deg. The only round asset in this job.",
                  "centre of the coil (floats)")


# ==================================================================== 13 infested
def infested():
    """Organic taint: creeping patch, dark veins, pods that pop, drifting spores."""
    CX, GY = 192, 250
    tendrils = []
    for i in range(11):
        a = -180 + i * 18.0
        rr = 150 + ((i * 53) % 7) * 9
        tendrils.append((round(CX + rr * math.cos(math.radians(a)), 1),
                         round(GY + rr * 0.34 * math.sin(math.radians(a)), 1),
                         round(90 + a * 0.35, 1)))
    pods = [[128, 236], [196, 258], [258, 240]]
    forms = [
        F("in_shadow", [P("square", [CX + 6, GY + 4], [346, 112], slice={"border": 4, "corner": 44})],
          z=-2, kind="shadow", color="shadow_contact", opacity=0.4, blur=13),
        F("in_halo", [P("circle", [CX, GY - 6], [330, 118], ground=True)], z=-1.5, kind="flat",
          material="rot_dark", opacity=0.5, blur=12, tags=["in_halo"]),
        F("in_patch", [P("circle", [CX, GY - 4], [306, 104], ground=True),
                       P("circle", [112, GY + 2], [112, 52], ground=True),
                       P("circle", [272, GY - 2], [104, 48], ground=True),
                       P("circle", [CX, GY - 26], [132, 46], ground=True)],
          z=0, kind="flat", material="rot", tags=["in_patch"],
          rough={"amp": 0.6, "soft": 3, "cell": 18},
          mottle={"cell": 40, "lo": 0.55, "hi": 0.86}),
        F("in_tendrils", [P("droplet", t[:2], [54, 24], rot=t[2], ground=True) for t in tendrils],
          z=0.5, kind="flat", material="rot", tags=["in_tend"],
          rough={"amp": 0.45, "soft": 2, "cell": 12}),
        F("in_veins", [P("lightning_bolt", [130, 232], [13, 30], ground=True, rot=-10),
                       P("lightning_bolt", [188, 258], [12, 26], ground=True, rot=8),
                       P("lightning_bolt", [246, 236], [14, 28], ground=True, rot=-6),
                       P("lightning_bolt", [210, 274], [11, 24], ground=True, rot=14),
                       P("lightning_bolt", [156, 274], [12, 24], ground=True, rot=-16)],
          z=1, kind="flat", material="rot_dark", tags=["in_veins"], line=False),
        F("in_leaves", [P("leaf", [120, 262], [34, 22], ground=True, rot=24),
                        P("leaf", [232, 264], [32, 20], ground=True, rot=-20),
                        P("leaf", [176, 226], [30, 20], ground=True, rot=8),
                        P("leaf", [266, 280], [28, 18], ground=True, rot=-34)],
          z=1.5, kind="flat", material="rot_dark", opacity=0.85, tags=["in_leaves"], line=False),
        F("in_bile", [P("circle", [148, 246], [26, 12], ground=True),
                      P("circle", [214, 262], [22, 10], ground=True),
                      P("circle", [252, 228], [18, 9], ground=True),
                      P("circle", [186, 286], [30, 12], ground=True)],
          z=2, kind="flat", material="bile", emit=0.18, tags=["in_bile"], line=False,
          glow={"radius": 3, "opacity": 0.3, "color": "bile"}),
    ]
    for i, (x, y) in enumerate(pods):
        forms.append(F("in_pod%d" % i, [P("bomb", [x, y], [34, 30], rot=-14 + i * 12)],
                       z=3, material="rot_dark", tags=["pod%d" % i], pivot=[x, y + 14]))
    for tag, dy0, xs in (("in_spA", 0, (128, 196, 258)), ("in_spB", 38, (128, 196, 258))):
        forms.append(F(tag, [P("circle", [x, 196 - dy0], [9, 9]) for x in xs],
                       z=4, kind="flat", material="bile", emit=0.4, tags=[tag], line=False,
                       glow={"radius": 2, "opacity": 0.4, "color": "bile"}))
    n = 6
    mv = {
        "in_patch": [{"pivot": [CX, GY], "sx": s, "sy": s} for s in [.94, .97, 1, 1.03, 1.05, 1.02]],
        "in_tend": [{"pivot": [CX, GY], "sx": s, "sy": s} for s in [.9, .94, .97, 1, 1.02, .96]],
        "in_veins": [{"pivot": [CX, GY], "dx": d} for d in [0, 2, 4, 2, 0, -2]],
        "in_leaves": [{"pivot": [CX, GY], "rot": r} for r in [0, 1.4, 2.4, 1.4, 0, -1.2]],
        "in_bile": [{"pivot": [CX, GY], "sx": s, "sy": s} for s in [1, 1.04, 1.08, 1.04, 1, .98]],
        "in_halo": [{"pivot": [CX, GY], "sx": s, "sy": s} for s in [.96, .99, 1.02, 1.05, 1.07, 1.04]],
    }
    for tag in ("in_spA", "in_spB"):
        mv[tag] = [{"pivot": [128, GY], "dy": -8, "sx": s, "sy": s}
                   for s in [1, .86, .72, .58, .44, .3]]
    for i, (x, y) in enumerate(pods):
        mv["pod%d" % i] = [{"pivot": [x, y + 14], "sx": s, "sy": s}
                           for s in [0.2, 0.55, 0.9, 1.0, 1.06, 1.0]]
    fs = frames(n, mv)
    swap_sets(mv, fs, "in_spA", "in_spB", 3)
    return recipe("infested", (384, 384), (CX, 262), 1213, forms, fs,
                  "infested (taint state on the ground). 6 frames, ground-squashed. A ragged "
                  "mottled olive patch breathing 0.94-1.05, eleven tapered tendrils creeping "
                  "out, five dark branching veins, four flat leaves, four dim bile spots, three "
                  "bomb-shaped pods that pop from 0.2 to 1.0 and two spore columns. Matte and "
                  "organic, so it cannot be confused with lava's hot veined crust.",
                  "ground contact point of the patch, centre")


# ==================================================================== 14 composter
def composter():
    """Slatted compost bin: crate, muck heap, ajar lid, steam, falling scraps."""
    forms = [
        F("cp_shadow", [P("square", [96, 178], [128, 26], slice={"border": 4, "corner": 12})],
          z=0, kind="shadow", color="shadow_contact", opacity=0.4, blur=5),
        F("cp_muck", [P("cloud", [96, 92], [98, 34]), P("circle", [78, 98], [46, 22])],
          z=1, kind="flat", material="soil", tags=["cp_muck"],
          rough={"amp": 0.4, "soft": 2, "cell": 12}),
        F("cp_worms", [P("hook", [82, 88], [26, 16], rot=24), P("hook", [116, 98], [22, 14], rot=-40)],
          z=1.5, kind="flat", material="worm", opacity=0.9, tags=["cp_muck"], line=False),
        F("cp_bin", [P("crate", [96, 134], [120, 88])], z=2, kind="block", material="wood",
          extrude=26, tags=["cp_bin"]),
        F("cp_slats", [P("square", [96, 112], [118, 8], slice={"border": 3, "corner": 3}),
                       P("square", [96, 134], [118, 8], slice={"border": 3, "corner": 3}),
                       P("square", [96, 156], [118, 8], slice={"border": 3, "corner": 3})],
          z=2.5, kind="flat", material="wood", opacity=0.75, clip_to="cp_bin", tags=["cp_bin"],
          line=False),
        F("cp_posts", [P("square", [40, 132], [12, 84], slice={"border": 3, "corner": 3}),
                       P("square", [152, 132], [12, 84], slice={"border": 3, "corner": 3})],
          z=2.8, kind="flat", material="wood", opacity=0.9, clip_to="cp_bin", tags=["cp_bin"],
          line=False),
        F("cp_lid", [P("square", [96, 72], [130, 18], slice={"border": 4, "corner": 6}),
                     P("circle", [96, 64], [24, 9])],
          z=3.5, kind="block", material="wood", extrude=10, pivot=[152, 76], tags=["cp_lid"]),
        F("cp_steam", [P("cloud", [74, 42], [44, 28]), P("cloud", [100, 30], [38, 24]),
                       P("cloud", [118, 44], [32, 22])],
          z=4, kind="flat", material="steam", opacity=0.36, blur=2, tags=["cp_steam"], line=False),
        F("cp_scrapA", [P("leaf", [72, 50], [14, 12], rot=30),
                        P("square", [126, 36], [11, 11], slice={"border": 2, "corner": 2}, rot=-24)],
          z=5, kind="flat", material="paper", opacity=0.85, tags=["scrapA"], line=False),
        F("cp_scrapB", [P("leaf", [72, 74], [14, 12], rot=34),
                        P("square", [126, 60], [11, 11], slice={"border": 2, "corner": 2}, rot=-18)],
          z=5, kind="flat", material="paper", opacity=0.85, tags=["scrapB"], line=False),
    ]
    mv = {
        "cp_lid": [{"pivot": [152, 76], "rot": r} for r in [-6, -3, -6, -9]],
        "cp_muck": [{"pivot": [96, 178], "sy": s} for s in [1, 1.05, 1.09, 1.05]],
        "cp_steam": [{"pivot": [96, 70], "dy": d, "sx": s, "sy": s}
                     for d, s in zip([0, -5, -10, -5], [1, 1.06, 1.12, 1.06])],
        "scrapA": [{"dy": 0}, {"dy": 9}, {"dy": 0}, {"dy": 9}],
        "scrapB": [{"dy": 0}, {"dy": 0}, {"dy": 9}, {"dy": 18}],
    }
    fs = frames(4, mv)
    for i, f in enumerate(fs):
        f["hide"] = ["scrapB"] if i < 2 else ["scrapA"]
    return recipe("composter", (192, 192), (96, 182), 1214, forms, fs,
                  "composter (decomposing / breaking down). 4 frames. The only box silhouette "
                  "in the job: a slatted crate bin with corner posts, a rough soil heap with two "
                  "pale worms, a plank lid on a hinge that creaks from -6 to -9 deg, three steam "
                  "wisps that breathe, and two paper scraps that fall 9 px per frame in two "
                  "alternating sets.",
                  "front-bottom centre of the bin on the floor")


# ==================================================================== 15 egg_crack
def egg_crack():
    """Egg split along a jagged seam; the cap lifts and tilts away."""
    EGG = P("droplet", [96, 100], [108, 132], crop=[0.4, 1.6, 15.6, 16])
    MTN = [96, 98, 160, 64]
    forms = [
        F("ec_shadow", [P("circle", [96, 178], [96, 20])],
          z=0, kind="shadow", color="shadow_contact", opacity=0.36, blur=5, tags=["ec_bottom"]),
        F("ec_void", [P("circle", [96, 102], [104, 128])], z=1, kind="flat", material="void",
          tags=["ec_bottom"]),
        F("ec_inside", [P("circle", [96, 104], [62, 66])], z=1.5, kind="flat", material="ember",
          opacity=0.4, emit=0.28, tags=["ec_bottom"],
          glow={"radius": 5, "opacity": 0.35, "color": "ember_glow"}),
        F("ec_gap", [P("mountains", MTN[:2], MTN[2:])], z=1.8, kind="flat", material="void",
          opacity=0.92, pivot=[96, 112], tags=["ec_gap"], line=False),
        F("ec_bottom", [dict(EGG),
                        P("square", [96, 62], [160, 72], op="sub"),
                        P("mountains", MTN[:2], MTN[2:])],
          z=2, kind="block", material="eggshell_mat", extrude=9, pivot=[96, 100],
          tags=["ec_bottom"]),
        F("ec_top", [dict(EGG),
                     P("square", [96, 140], [160, 84], op="sub"),
                     P("mountains", MTN[:2], MTN[2:], op="sub")],
          z=3, kind="block", material="eggshell_mat", extrude=8, pivot=[96, 100], tags=["ec_top"]),
        F("ec_seam", [P("lightning_bolt", [96, 98], [104, 24], rot=90)], z=4, kind="flat",
          material="soot", opacity=0.85, tags=["ec_seam"], line=False),
        F("ec_chipA", [P("square", [44, 126], [13, 12], slice={"border": 2, "corner": 2}, rot=30),
                       P("droplet", [148, 138], [11, 13], rot=120)],
          z=5, kind="flat", material="eggshell_mat", tags=["chipA"], line=False),
        F("ec_chipB", [P("square", [44, 150], [13, 12], slice={"border": 2, "corner": 2}, rot=22),
                       P("droplet", [148, 162], [11, 13], rot=108)],
          z=5, kind="flat", material="eggshell_mat", tags=["chipB"], line=False),
    ]
    mv = {
        "ec_top": [{"pivot": [96, 100], "dy": d, "rot": r}
                   for d, r in zip([0, -9, -18, -24], [0, -4, -7, -9])],
        "ec_gap": [{"pivot": [96, 112], "sy": s} for s in [1, 1.3, 1.6, 1.8]],
        "ec_inside": [{"pivot": [96, 112], "sx": s, "sy": s} for s in [1, 1.06, 1.12, 1.06]],
        "chipA": [{"dy": 0}, {"dy": 11}, {"dy": 22}, {"dy": 33}],
        "chipB": [{"dy": 0}, {"dy": 0}, {"dy": 11}, {"dy": 22}],
    }
    fs = frames(4, mv)
    for i, f in enumerate(fs):
        f["hide"] = (["chipB"] if i < 2 else ["chipA"]) + (["ec_seam"] if i >= 2 else [])
    return recipe("egg_crack", (192, 192), (96, 182), 1215, forms, fs,
                  "egg_crack (egg breaking). 4 frames. The egg is a cropped droplet (a solid "
                  "teardrop, unlike the egg icon which has a hole). The lower shell is the egg "
                  "minus everything above a jagged mountain seam with the mountains added back "
                  "as teeth; the cap is the exact complement, so the two interlock on frame 0. "
                  "The cap lifts -24 px and tilts -9 deg, a dark jagged gap opens under it, warm "
                  "light shows from inside, the seam line is only drawn on the first two "
                  "frames, and two shell chip pairs fall away.",
                  "floor point under the lower shell")


# ------------------------------------------------------------------------ main
def main():
    for b in (soul_fire, copper_fire, lava, damage, angry_villager, happy_villager,
              pause_growth, reset_growth, heart, elder_guardian, firefly, nautilus,
              infested, composter, egg_crack):
        r = b()
        write(r["asset"] + ".json", r)


if __name__ == "__main__":
    main()
