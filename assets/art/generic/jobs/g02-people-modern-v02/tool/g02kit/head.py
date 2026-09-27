"""Headwear, masks and face gear (battler space)."""

from __future__ import annotations

from .core import F, P, pair

HT = ["upper", "head", "hair"]      # moves with the head, small 3/4 turn in portraits
FT = ["upper", "head", "feature"]   # sits on the face, full 3/4 turn


def shield_whole(cx, cy, w, h):
    """The shield icon without its centre gap: two left halves, mirrored, overlapping."""
    half = P("shield", cx - w / 4.0 + 0.8, cy, w / 2.0 + 1.6, h, half="left", crop=[1, 0.8, 8, 15.2])
    return [half, dict(half, at=[round(2 * cx - half["at"][0], 2), half["at"][1]], flip="x")]


def headwear(spec):
    h = spec.get("head") or {}
    t = h.get("type")
    m = h.get("mat", "cloth_black")
    m2 = h.get("mat2", "leather_dark")
    acc = h.get("accent", "bronze")
    out = []
    if not t:
        return out
    if t == "hood":
        out.append(F("hood_back", 0.7, [P("droplet", 160, 118, 132, 140)], m, HT))
        out.append(F("hood_rim", 10.5, [P("circle", 160, 131, 112, 108), P("circle", 160, 146, 80, 80, op="sub"),
                                        P("square", 160, 196, 120, 40, op="sub")], m, HT))
        if h.get("deep"):
            out.append(F("hood_shade", 10.4, [P("circle", 160, 146, 82, 82)], None, HT, kind="flat",
                         color="shade_face", opacity=0.55, clip_to="face"))
    elif t in ("wide_hat", "cowboy", "witch", "captain", "hunter"):
        brim_w = {"cowboy": 164, "witch": 170, "captain": 176, "hunter": 172}.get(t, 166)
        brim = [P("circle", 160, 104, brim_w, 30)]
        if t == "cowboy":
            brim += [P("droplet", 88, 96, 20, 30, rot=-62), P("droplet", 232, 96, 20, 30, rot=62)]
        out.append(F("hat_brim", 12, brim, m, HT))
        if t == "witch":
            crown = [P("triangle", 160, 52, 76, 100, rot=-4), P("droplet", 196, 14, 18, 40, rot=62)]
        elif t == "captain":
            crown = [P("umbrella", 160, 84, 104, 48, crop=[0.6, 2.3, 15.4, 8.7])]
        elif t == "cowboy":
            crown = [P("bell", 160, 80, 74, 50, crop=[3.5, 3.4, 12.5, 10.4]), P("circle", 160, 55, 22, 9, op="sub")]
        else:
            crown = [P("bell", 160, 78, 76, 54, crop=[3.5, 3.4, 12.5, 10.4])]
        out.append(F("hat_crown", 12.1, crown, m, HT))
        out.append(F("hat_band", 12.2, [P("square", 160, 98, 74 if t != "captain" else 100, 8)], m2, HT))
        if h.get("feather"):
            out.append(F("hat_feather", 12.3, [P("feather", 206, 72, 34, 70, rot=18)], h.get("feather"), HT))
        if h.get("buckle"):
            out.append(F("hat_buckle", 12.3, [P("square", 160, 98, 12, 10)], acc, HT, line={"width": 0.6, "heavy": 0.4}))
    elif t == "top_hat":
        out.append(F("hat_brim", 12, [P("circle", 160, 100, 104, 18)], m, HT))
        out.append(F("hat_crown", 12.1, [P("cylinder", 160, 66, 60, 70)], m, HT))
        out.append(F("hat_band", 12.2, [P("square", 160, 90, 60, 9)], m2, HT))
    elif t == "wizard":
        out.append(F("hat_brim", 12, [P("circle", 160, 102, 156, 28)], m, HT))
        out.append(F("hat_crown", 12.1, [P("triangle", 160, 52, 84, 104, rot=-7), P("droplet", 138, 8, 16, 34, rot=-50)], m, HT))
        out.append(F("hat_band", 12.2, [P("square", 160, 94, 80, 8)], m2, HT))
        if h.get("stars"):
            out.append(F("hat_mark", 12.3, [P("moon", 150, 64, 14, 16, rot=-20)], acc, HT, kind="flat", emit=0.4))
    elif t == "helm_great":
        out.append(F("helm", 12, shield_whole(160, 128, 92, 104), m, HT))
        out.append(F("helm_ridge", 12.1, [P("square", 160, 124, 3, 92)], None, HT, kind="flat", color="coat_seam", opacity=0.6))
        out.append(F("helm_slit", 12.2, [P("square", 160, 134, 64, 7)] + ([P("square", 160, 150, 7, 30)] if h.get("cross") else []),
                     "void", HT, kind="flat"))
        out.append(F("helm_holes", 12.2, [P("circle", 172, 158, 4, 4, repeat={"grid": [3, 2], "step": [8, 8]})], "void", HT, kind="flat"))
        if h.get("plume"):
            out.append(F("helm_plume", 11.9, [P("feather", 176, 64, 34, 66, rot=24)], h.get("plume"), HT))
    elif t == "helm_open":
        out.append(F("helm", 12, [P("umbrella", 160, 96, 104, 48, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("helm_rim", 12.1, [P("circle", 160, 114, 120 if h.get("kettle") else 104, 14)], m, HT))
        if h.get("nasal"):
            out.append(F("helm_nasal", 12.2, [P("square", 160, 130, 8, 30)], m, HT))
        if h.get("crest"):
            out.append(F("helm_crest", 11.9, [P("cloud", 160, 66, 70, 30)], h.get("crest"), HT))
    elif t == "helm_black":
        out.append(F("helm", 12, shield_whole(160, 128, 96, 108) + [P("triangle", 118, 84, 22, 34, rot=-24),
                                  P("triangle", 202, 84, 22, 34, rot=24)], m, HT))
        out.append(F("helm_slit", 12.2, [P("moon", 146, 138, 24, 10, rot=-80), P("moon", 174, 138, 24, 10, rot=80)],
                     h.get("eye", "ember_red"), HT, kind="flat", emit=0.8, glow={"radius": 2.5, "opacity": 0.5, "color": "ember_glow"}))
    elif t == "cap":
        out.append(F("cap_crown", 12, [P("umbrella", 160, 94, 102, 42, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("cap_band", 12.1, [P("square", 160, 106, 98, 10)], m2, HT))
        out.append(F("cap_visor", 12.2, [P("moon", 160, 114, 26, 74, rot=-90)], "leather_dark", HT))
        if h.get("badge"):
            out.append(F("cap_badge", 12.3, [P("badge", 160, 96, 16, 16)], acc, HT))
    elif t == "beret":
        out.append(F("beret", 12, [P("circle", 154, 96, 104, 34, rot=-8), P("circle", 176, 86, 10, 8)], m, HT))
    elif t in ("crown", "tiara"):
        w, hh = (70, 44) if t == "crown" else (46, 26)
        out.append(F("crown", 12, [P("chess_queen", 160, 88 if t == "crown" else 100, w, hh, crop=[0, 0, 16, 10.5])], acc, HT,
                     shade={"highlight_amount": 0.8}))
        if h.get("gem"):
            out.append(F("crown_gem", 12.2, [P("circle", 160, 96 if t == "crown" else 104, 9, 9)], h.get("gem"), HT, kind="flat"))
    elif t == "veil":
        out.append(F("veil_back", 0.7, [P("bell", 160, 176, 138, 160, crop=[1.6, 1.5, 14.4, 12])], m, HT))
        out.append(F("coif", 10.4, [P("circle", 160, 136, 98, 98), P("circle", 160, 145, 70, 70, op="sub"),
                                    P("square", 160, 196, 110, 36, op="sub")], m2, HT))
        out.append(F("veil_top", 10.5, [P("umbrella", 160, 96, 108, 40, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
    elif t == "nurse_cap":
        out.append(F("nurse_cap", 12, [P("square", 160, 88, 54, 24), P("triangle", 160, 80, 40, 12, flip="y", op="sub")], m, HT))
        out.append(F("nurse_line", 12.1, [P("square", 160, 92, 40, 3)], m2, HT, kind="flat"))
    elif t == "kasa":
        out.append(F("kasa", 12, [P("triangle", 160, 86, 176, 52)], m, HT, texture={"stamp": "pill", "pre_rot": -45, "length": 18,
                                                                                      "width": 1.6, "angle": 70, "jitter": 30,
                                                                                      "density": 0.9, "strength": 0.14}))
        out.append(F("kasa_cord", 11.6, pair(P("square", 130, 150, 3, 46, rot=-12)), m2, HT))
    elif t == "kabuto":
        out.append(F("kabuto_guard", 0.8, [P("bell", 160, 150, 150, 90, crop=[1.6, 3.4, 14.4, 12])], m, HT))
        out.append(F("kabuto", 12, [P("umbrella", 160, 94, 110, 50, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("kabuto_flaps", 12.1, pair(P("moon", 108, 110, 22, 34, rot=150)), m, HT))
        out.append(F("kabuto_crest", 12.3, [P("moon", 160, 64, 30, 60, rot=-90)], acc, HT, shade={"highlight_amount": 0.8}))
    elif t == "santa":
        out.append(F("santa_hat", 12, [P("triangle", 172, 72, 90, 76, rot=38)], m, HT))
        out.append(F("santa_trim", 12.1, [P("cloud", 160, 102, 112, 28), P("circle", 218, 84, 22, 22)], m2, HT))
    elif t == "bubble":
        out.append(F("helmet_ring", 12.4, [P("circle", 160, 190, 124, 30)], m2, HT))
        out.append(F("helmet_glass", 12.5, [P("circle", 160, 128, 152, 150)], m, HT, opacity=0.3,
                     line={"width": 1.2, "heavy": 1.2}))
        out.append(F("helmet_glint", 12.6, [P("moon", 126, 104, 26, 50, rot=-30)], None, HT, kind="flat",
                     color="white_ink", opacity=0.45))
    elif t == "gat":
        out.append(F("gat_brim", 12, [P("circle", 160, 104, 150, 22)], m, HT, opacity=0.8))
        out.append(F("gat_crown", 12.1, [P("cylinder", 160, 80, 46, 44)], m, HT, opacity=0.9))
        out.append(F("gat_beads", 11.7, [P("circle", 128, 124, 5, 5, repeat={"line": [[128, 124], [150, 196]], "count": 8}),
                                         P("circle", 192, 124, 5, 5, repeat={"line": [[192, 124], [170, 196]], "count": 8})], acc, HT))
    elif t == "bandana":
        out.append(F("bandana", 10.6, [P("umbrella", 160, 100, 106, 42, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("bandana_knot", 10.55, [P("droplet", 206, 128, 14, 30, rot=-150), P("droplet", 214, 124, 12, 26, rot=-120)], m, HT))
    elif t == "headband":
        out.append(F("headband", 10.6, [P("square", 160, 112, 84, 9)], m, HT))
        out.append(F("headband_tail", 10.55, [P("bookmark", 206, 132, 10, 34, rot=-24), P("bookmark", 214, 128, 9, 30, rot=-50)], m, HT))
    elif t == "goggles":
        out.append(F("goggle_strap", 10.6, [P("square", 160, 104, 98, 10)], m2, HT))
        out.append(F("goggle_rim", 10.7, pair(P("circle", 145, 102, 28, 26)), acc, HT))
        out.append(F("goggle_lens", 10.8, pair(P("circle", 145, 102, 19, 17)), m, HT, shade={"highlight_amount": 0.8}))
    elif t == "ninja":
        out.append(F("ninja_hood", 10.5, [P("circle", 160, 126, 104, 102), P("square", 160, 143, 70, 17, op="sub")], m, HT))
        out.append(F("ninja_tail", 0.7, [P("bookmark", 206, 150, 12, 40, rot=-30)], m, HT))
    elif t == "fedora":
        out.append(F("hat_brim", 12, [P("circle", 160, 102, 130, 20)], m, HT))
        out.append(F("hat_crown", 12.1, [P("bell", 160, 80, 70, 44, crop=[3.5, 3.4, 12.5, 10.4]), P("triangle", 160, 60, 20, 10, flip="y", op="sub")], m, HT))
        out.append(F("hat_band", 12.2, [P("square", 160, 96, 70, 7)], m2, HT))
    elif t == "scrub_cap":
        out.append(F("hat", 12, [P("umbrella", 160, 98, 96, 38, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
    elif t == "sailor_cap":
        out.append(F("hat", 12, [P("circle", 160, 88, 84, 28), P("square", 160, 98, 66, 14)], m, HT))
        out.append(F("hat_band", 12.1, [P("square", 160, 102, 68, 6)], m2, HT))
    elif t == "bicorne":
        out.append(F("bicorne", 12, [P("umbrella", 160, 90, 166, 50, crop=[0.6, 2.3, 15.4, 8.7]), P("triangle", 160, 70, 60, 26)], m, HT))
        out.append(F("bicorne_trim", 12.1, [P("circle", 160, 102, 120, 6)], acc, HT))
        out.append(F("bicorne_badge", 12.2, [P("circle", 160, 90, 14, 14)], h.get("badge", "cloth_white"), HT))
    elif t == "deerstalker":
        out.append(F("hat_crown", 12, [P("umbrella", 160, 96, 104, 46, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("hat_visor", 12.1, [P("moon", 160, 112, 22, 60, rot=-90)], m, HT))
        out.append(F("hat_flaps", 11.9, pair(P("droplet", 112, 118, 20, 34, flip="y", rot=10)), m, HT))
        out.append(F("hat_bow", 12.2, [P("square", 160, 76, 16, 6)], m2, HT))
    elif t == "chef":
        out.append(F("chef_puff", 12, [P("cloud", 160, 64, 98, 70), P("square", 160, 84, 78, 30)], m, HT))
        out.append(F("chef_band", 12.1, [P("square", 160, 102, 84, 16)], m, HT))
    elif t == "jeonrip":
        out.append(F("hat_brim", 12, [P("circle", 160, 104, 154, 26)], m, HT))
        out.append(F("hat_crown", 12.1, [P("umbrella", 160, 84, 70, 38, crop=[0.6, 2.3, 15.4, 8.7])], m, HT))
        out.append(F("hat_tassel", 12.2, [P("cloud", 160, 64, 26, 14), P("droplet", 176, 78, 10, 22, rot=30)], acc, HT))
    elif t == "taoist":
        out.append(F("hat", 12, [P("square", 160, 92, 60, 26), P("triangle", 160, 76, 60, 18)], m, HT))
        out.append(F("hat_pin", 12.1, [P("square", 160, 90, 80, 4)], acc, HT))
    elif t == "chef_cap":
        out.append(F("hat", 12, [P("cylinder", 160, 86, 62, 36)], m, HT))
    elif t == "hairpin":
        out.append(F("hairpin", 12, [P("square", 160, 80, 96, 5, rot=-8), P("circle", 206, 74, 12, 12)], acc, HT))
        if h.get("flower"):
            out.append(F("hair_flower", 12.1, [P("flower", 128, 90, 26, 26)], h["flower"], HT))
    elif t == "ribbon":
        out.append(F("ribbon", 12, [P("triangle", 150, 78, 22, 18, rot=-90), P("triangle", 170, 78, 22, 18, rot=90),
                                    P("circle", 160, 78, 8, 8)], m, HT))
    elif t == "maid_cap":
        out.append(F("maid_cap", 12, [P("cloud", 160, 88, 80, 22)], m, HT))
    elif t == "hood_mask":
        out.append(F("hood_back", 0.7, [P("droplet", 160, 116, 128, 138)], m, HT))
        out.append(F("hood_face", 10.5, [P("circle", 160, 128, 106, 104), P("circle", 146, 143, 16, 12, op="sub"),
                                         P("circle", 174, 143, 16, 12, op="sub"), P("square", 160, 196, 120, 36, op="sub")], m, HT))
    else:
        raise KeyError(f"unknown headwear {t!r}")
    return out


def facegear(spec):
    g = (spec.get("face") or {}).get("gear")
    out = []
    if not g:
        return out
    if g == "glasses":
        out.append(F("glasses", 11.6, [P("glasses", 160, 143, 62, 20, crop=[0.8, 8.4, 15.2, 14.6])], "iron_dark", FT,
                     shade={"bump": 0.3}))
    elif g == "shades":
        out.append(F("shades", 11.6, [P("glasses", 160, 143, 64, 21, crop=[0.8, 8.4, 15.2, 14.6])], "iron_dark", FT, shade={"bump": 0.3}))
        out.append(F("shades_lens", 11.65, [P("circle", 146, 144, 22, 15), P("circle", 174, 144, 22, 15)], "cloth_black", FT, kind="flat"))
    elif g == "monocle":
        out.append(F("monocle", 11.6, [P("circle", 174, 143, 17, 17), P("circle", 174, 143, 12, 12, op="sub")], "gold", FT))
    elif g == "eyepatch":
        out.append(F("eyepatch", 11.6, [P("circle", 174, 143, 17, 15), P("square", 160, 126, 80, 3, rot=-22)], "leather_dark", FT))
    elif g == "gas_mask":
        out.append(F("mask", 11.6, [P("circle", 160, 150, 74, 60)], "rubber", FT))
        out.append(F("mask_lens", 11.7, [P("circle", 145, 142, 21, 19), P("circle", 175, 142, 21, 19)], "lens", FT))
        out.append(F("mask_filter", 11.8, [P("cylinder", 160, 172, 28, 24)], "iron", FT))
    elif g == "plague":
        out.append(F("beak", 11.8, [P("droplet", 160, 172, 34, 70, flip="y")], "leather_tan", FT))
        out.append(F("beak_lens", 11.7, [P("circle", 144, 139, 20, 20), P("circle", 176, 139, 20, 20)], "lens", FT,
                     shade={"highlight_amount": 0.9}))
    elif g == "surgical":
        out.append(F("surgical_mask", 11.6, [P("square", 160, 160, 62, 28)], "cloth_ice", FT))
    elif g == "cloth_mask":
        out.append(F("cloth_mask", 11.6, [P("square", 160, 162, 76, 34)], (spec.get("face") or {}).get("gear_mat", "cloth_black"), FT))
    elif g == "visor":
        out.append(F("visor_frame", 11.6, [P("square", 160, 143, 84, 18)], "iron_dark", FT))
        out.append(F("visor_glow", 11.7, [P("square", 160, 143, 76, 10)], "neon_cyan", FT, kind="flat", emit=0.9,
                     glow={"radius": 3, "opacity": 0.5, "color": "neon_glow_c"}))
    elif g == "clown":
        out.append(F("clown_nose", 11.8, [P("circle", 160, 153, 14, 13)], "cloth_red", FT))
        out.append(F("clown_marks", 11.5, [P("diamond", 146, 132, 8, 20), P("diamond", 174, 132, 8, 20)], "cloth_navy", FT, kind="flat"))
    elif g == "skull_paint":
        out.append(F("face_paint", 11.5, [P("circle", 146, 143, 17, 16), P("circle", 174, 143, 17, 16)], "shade_face", FT, kind="flat",
                     opacity=0.8))
    else:
        raise KeyError(f"unknown face gear {g!r}")
    return out
