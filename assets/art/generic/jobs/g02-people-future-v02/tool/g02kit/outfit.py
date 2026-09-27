"""Garments (torso, skirt, sleeves) and extras (belt, cape, tabard, collars...)."""

from __future__ import annotations

from . import body
from .core import F, P, pair

UP = ["upper"]
FRONT = ["upper", "front"]


def _flare(hem, width, top=236):
    h = hem - top
    return P("bell", 160, top + h / 2.0, width, h, crop=[1.6, 7, 14.4, 12])


def _chest(w=100, top=178, bottom=264):
    """Sloped-shoulder torso: two left halves of the shield icon, mirrored, overlapping 1.6 px
    (the icon's centre gap would otherwise show as a see-through line)."""
    h = bottom - top
    half = P("shield", 160 - w / 4.0 + 0.8, (top + bottom) / 2.0, w / 2.0 + 1.6, h, half="left", crop=[1, 0.8, 8, 10.4])
    return pair(half)


def garment(spec):
    """Torso garment + sleeves + legs.  Returns forms."""
    t = spec.get("top") or {}
    kind = t.get("type", "tunic")
    m = t.get("mat", "cloth_brown")
    m2 = t.get("mat2", m)
    trim = t.get("trim")
    lo = spec.get("lower") or {}
    out = []
    chest = _chest(t.get("chest", 100))
    hem = t.get("hem")
    if kind in ("tunic", "shirt", "jacket", "suit", "vest", "gown", "coat", "robe", "kimono", "lab"):
        hem = hem or {"tunic": 292, "shirt": 280, "jacket": 286, "suit": 286, "vest": 284, "gown": 322,
                      "coat": 334, "lab": 330, "robe": 368, "kimono": 300}[kind]
        width = t.get("width") or {"robe": 132, "coat": 116, "lab": 116, "gown": 104, "kimono": 110}.get(kind, 100)
        out.append(F("torso", 3, chest + [_flare(hem, width)], m, UP))
        if kind in ("coat", "lab", "jacket", "suit"):
            out.append(F("coat_seam", 3.5, [P("square", 160, (208 + hem) / 2, 3, hem - 212)], None, FRONT, kind="flat",
                         color="coat_seam", opacity=0.9))
        if kind in ("suit", "jacket", "lab", "vest"):
            out.append(F("shirt", 3.2, [P("triangle", 160, 205, 34, 44, flip="y")], t.get("shirt", "cloth_white"), FRONT))
            out.append(F("lapels", 3.4, [P("triangle", 148, 206, 18, 46, flip="y", rot=-14),
                                         P("triangle", 172, 206, 18, 46, flip="y", rot=14)], m2, FRONT))
        if kind == "kimono":
            out.append(F("collar_wrap", 3.4, [P("square", 170, 206, 12, 64, rot=34), P("square", 150, 202, 11, 48, rot=-34)],
                         t.get("collar", "cloth_white"), FRONT))
            out.append(F("obi", 3.6, [P("square", 160, 250, 98, 22)], t.get("obi", "cloth_red"), FRONT))
        if kind == "robe" and trim:
            out.append(F("robe_trim", 3.4, [P("square", 160, 290, 16, 154)], trim, FRONT))
    elif kind == "armor":
        out.append(F("torso", 3, chest + [_flare(t.get("hem", 292), 104)], t.get("under", "iron"), UP))
        out.append(F("breastplate", 3.3, [P("shield", 160, 219, 100, 100, crop=[0.5, 0, 15.5, 12.4])], m, FRONT))
        out.append(F("faulds", 3.4, [P("square", 160, 276, 86, 16), P("square", 160, 290, 78, 14)], m, UP))
        out.append(F("pauldrons", 7, pair(P("circle", 114, 194, 48, 38)) + pair(P("circle", 111, 208, 40, 26)), m, UP))
        if trim:
            out.append(F("plate_trim", 3.45, [P("circle", 160, 180, 56, 14)], trim, UP))
    elif kind == "dress":
        out.append(F("bodice", 3.2, _chest(86, 180, 258) + [P("shield", 160, 246, 60, 34, half=None, crop=[0, 6, 16, 15])], m, UP))
        out.append(F("skirt", 3, [P("bell", 160, 295, t.get("width", 178), 150, crop=[1.6, 3.4, 14.4, 12])], m2, ["legs", "no_portrait"]))
        if trim:
            out.append(F("skirt_trim", 3.1, [P("square", 160, 366, 150, 8)], trim, ["legs", "no_portrait"]))
    elif kind == "spacesuit":
        out.append(F("torso", 3, [P("circle", 160, 224, 122, 104), _flare(292, 110)], m, UP))
        out.append(F("chest_box", 3.5, [P("square", 160, 226, 42, 30)], m2, FRONT))
        out.append(F("chest_lights", 3.6, [P("circle", 150, 222, 6, 6), P("circle", 162, 222, 6, 6), P("square", 160, 234, 26, 4)],
                     t.get("light", "neon_cyan"), FRONT, kind="flat", emit=0.8))
    elif kind == "poncho":
        out.append(F("torso", 3, chest + [_flare(286, 100)], t.get("under", "cloth_white"), UP))
        out.append(F("poncho", 7.2, [P("triangle", 160, 238, 150, 110, flip="y"), P("square", 160, 196, 106, 30)], m, UP))
        out.append(F("poncho_stripes", 7.3, [P("square", 160, 214, 118, 6), P("square", 160, 232, 88, 6)], m2, UP, kind="flat",
                     clip_to="poncho"))
    else:
        raise KeyError(f"unknown top {kind!r}")

    sleeve = t.get("sleeve", m)
    style = t.get("sleeve_style", "fitted")
    if style == "wide":
        for side, sx in (("r", 100), ("l", 220)):
            pc = P("bell", sx, 238, 44, 96, crop=[1.6, 3.4, 14.4, 12], rot=6 if side == "r" else -6)
            out.append(F(f"sleeve_{side}", 5, [pc], sleeve, ["upper", f"arm_{side}"]))
            hand = P("droplet", 103 if side == "r" else 217, 282, 19, 23, flip="y")
            out.append(F(f"hand_{side}", 6, [hand], spec.get("hand_mat", spec.get("skin", "skin")), ["upper", f"arm_{side}"]))
    else:
        out += body.arms(sleeve, spec.get("hand_mat", spec.get("skin", "skin")), bare=(style == "bare"),
                         cuff=t.get("cuff"))
    if style == "puff":
        out.append(F("puff", 5.5, pair(P("circle", 110, 198, 40, 32)), sleeve, UP))

    ltype = lo.get("type", "trousers")
    lmat = lo.get("mat", "trouser")
    covered = kind in ("robe", "dress")
    if ltype == "hakama":
        out.append(F("hakama", 1.5, [P("bell", 160, 318, 128, 106, crop=[1.6, 5, 14.4, 12])], lmat, ["legs", "no_portrait"]))
    elif ltype == "skirt":
        out.append(F("skirt", 3.1, [P("bell", 160, 300, lo.get("width", 116), 64, crop=[1.6, 5, 14.4, 12])], lmat, ["legs", "no_portrait"]))
        if lo.get("pleats"):
            out.append(F("pleats", 3.15, [P("square", 132, 304, 2.4, 44, repeat={"grid": [8, 1], "step": [8, 0]})], None,
                         ["legs", "no_portrait"], kind="flat", color="coat_seam", opacity=0.55, clip_to="skirt"))
    elif ltype == "long_skirt":
        out.append(F("skirt", 3.1, [P("bell", 160, 312, lo.get("width", 150), 116, crop=[1.6, 3.4, 14.4, 12])], lmat,
                     ["legs", "no_portrait"]))
    out += body.legs(lo.get("leg_mat", lmat if ltype in ("trousers", "hakama") else "trouser"),
                     lo.get("boots", "boot"), lo.get("boot_mat", "leather"),
                     hide_legs=covered or ltype in ("long_skirt",))
    return out


def extras(spec):
    out = []
    for i, e in enumerate(spec.get("extras", [])):
        t = e["type"]
        m = e.get("mat", "leather")
        n = f"{t}_{i}"
        if t == "belt":
            y = e.get("y", 262)
            out.append(F(n, 4, [P("square", 160, y, e.get("w", 96), e.get("h", 11))], m, UP))
            if e.get("buckle", True):
                out.append(F(n + "_buckle", 4.1, [P("square", 160, y, 13, 13)], e.get("buckle_mat", "bronze"), UP,
                             line={"width": 0.6, "heavy": 0.5}))
        elif t == "sash":
            out.append(F(n, 4.2, [P("square", 160, 228, 13, 124, rot=-38)], m, FRONT))
        elif t == "bandolier":
            out.append(F(n, 4.2, [P("square", 160, 228, 12, 124, rot=38)], m, FRONT))
            out.append(F(n + "_shells", 4.3, [P("square", 128, 190, 5, 9, rot=38, repeat={"line": [[132, 192], [188, 264]], "count": 7})],
                         e.get("shell", "brass"), FRONT))
        elif t == "strap":
            out.append(F(n, 4.2, [P("square", 160, 226, 7, 122, rot=-40)], m, FRONT))
        elif t == "cape":
            out.append(F(n, 0.8, [P("bookmark", 160, e.get("y", 268), e.get("w", 128), e.get("h", 170))], m, UP))
            out.append(F(n + "_top", 7, [P("umbrella", 160, 194, 128, 46, crop=[0.6, 2.3, 15.4, 8.7])], e.get("top", m), UP))
            if e.get("clasp"):
                out.append(F(n + "_clasp", 7.5, [P("circle", 160, 196, 12, 12)], e["clasp"], UP, line={"width": 0.6, "heavy": 0.5}))
        elif t == "capelet":
            out.append(F(n, 7, [P("umbrella", 160, 198, 132, 56, crop=[0.6, 2.3, 15.4, 8.7])], m, UP))
        elif t == "tabard":
            out.append(F(n, 3.6, [P("square", 160, 262, 64, 136)], m, FRONT))
            mk = e.get("mark")
            if mk == "cross":
                out.append(F(n + "_mark", 3.7, [P("square", 160, 238, 9, 46), P("square", 160, 228, 30, 9)], e.get("mark_mat", "cloth_red"),
                             FRONT, kind="flat"))
        elif t == "apron":
            out.append(F(n, 3.7, [P("bell", 160, 280, e.get("w", 84), e.get("h", 118), crop=[2.5, 3.4, 13.5, 12])], m, FRONT))
            out.append(F(n + "_tie", 3.75, [P("square", 160, 250, 92, 6)], m, FRONT))
        elif t == "scarf":
            out.append(F(n, 8, [P("circle", 160, 182, 64, 22)], m, UP))
            out.append(F(n + "_tail", 8.2, [P("bookmark", 176, 206, 16, 38, rot=-8)], m, FRONT))
        elif t == "ruff":
            out.append(F(n, 8, [P("cloud", 160, 181, 84, 28)], m, UP))
        elif t == "collar":
            out.append(F(n, 8, [P("triangle", 148, 184, 26, 18, flip="y", rot=-20), P("triangle", 172, 184, 26, 18, flip="y", rot=20)], m, UP))
        elif t == "high_collar":
            out.append(F(n, 8, [P("umbrella", 160, 182, 90, 34, crop=[0.6, 2.3, 15.4, 8.7], flip="y")], m, UP))
        elif t == "tie":
            out.append(F(n, 3.5, [P("circle", 160, 188, 10, 8), P("diamond", 160, 212, 13, 46)], m, FRONT))
        elif t == "bowtie":
            out.append(F(n, 8.3, [P("triangle", 151, 186, 14, 12, rot=-90), P("triangle", 169, 186, 14, 12, rot=90), P("circle", 160, 186, 6, 6)],
                         m, FRONT))
        elif t == "necklace":
            out.append(F(n, 8.1, [P("circle", 138, 196, 5, 5, repeat={"ellipse": [160, 186, 26, 22], "count": 13, "arc": [20, 160]})], m, FRONT))
            if e.get("pendant") == "cross":
                out.append(F(n + "_p", 8.2, [P("square", 160, 218, 5, 20), P("square", 160, 213, 14, 5)], m, FRONT))
            elif e.get("pendant"):
                out.append(F(n + "_p", 8.2, [P(e["pendant"], 160, 216, 14, 14)], m, FRONT))
        elif t == "badge":
            out.append(F(n, 4.5, [P(e.get("icon", "star"), e.get("x", 182), e.get("y", 212), e.get("size", 18), e.get("size", 18))], m,
                         FRONT, line={"width": 0.6, "heavy": 0.5}))
        elif t == "buttons":
            out.append(F(n, 3.8, [P("circle", e.get("x", 166), 200, 5, 5, repeat={"line": [[e.get("x", 166), 200], [e.get("x", 166), 272]], "count": 5})],
                         m, FRONT, kind="flat"))
        elif t == "epaulettes":
            out.append(F(n, 7.5, pair(P("square", 118, 188, 30, 9)), m, UP))
            out.append(F(n + "_f", 7.4, pair(P("square", 118, 196, 3, 9, repeat={"grid": [5, 1], "step": [6, 0]})), m, UP, kind="flat"))
        elif t == "pouch":
            out.append(F(n, 4.4, [P("square", e.get("x", 190), 272, 20, 20)], m, UP))
        elif t == "holster":
            out.append(F(n, 4.4, [P("square", 196, 284, 16, 30)], m, UP))
            out.append(F(n + "_grip", 4.3, [P("square", 198, 266, 10, 14)], "iron_dark", UP))
        elif t == "backpack":
            out.append(F(n, 0.9, [P("square", 160, 214, 118, 84)], m, UP))
            out.append(F(n + "_straps", 7.1, pair(P("square", 132, 214, 9, 60)), e.get("strap", "leather_dark"), UP))
        elif t == "chest_rig":
            out.append(F(n, 3.8, [P("square", 160, 230, 82, 58)], m, FRONT))
            out.append(F(n + "_pockets", 3.9, [P("square", 142, 238, 20, 24), P("square", 178, 238, 20, 24)], e.get("mat2", m), FRONT))
        elif t == "belly":
            out.append(F(n, 3.35, [P("circle", 160, 250, 96, 70)], m, FRONT))
        elif t == "fur_collar":
            out.append(F(n, 8, [P("cloud", 160, 186, 112, 36)], m, UP))
        elif t == "sailor_collar":
            out.append(F(n, 7, pair(P("triangle", 136, 196, 46, 34, flip="y", rot=-28)) + [P("square", 160, 184, 70, 8)], m, UP))
            out.append(F(n + "_line", 7.1, pair(P("square", 132, 196, 3, 30, rot=62)), e.get("line", "cloth_white"), UP, kind="flat"))
            out.append(F(n + "_knot", 7.2, [P("triangle", 152, 214, 14, 20, flip="y", rot=-16), P("triangle", 168, 214, 14, 20, flip="y", rot=16),
                                            P("circle", 160, 206, 9, 8)], e.get("knot", "cloth_red"), FRONT))
        elif t == "spikes":
            out.append(F(n, 7.3, pair(P("circle", 116, 194, 44, 34)), m, UP))
            out.append(F(n + "_s", 7.4, pair(P("triangle", 104, 180, 9, 16, rot=-40)) + pair(P("triangle", 118, 176, 9, 16, rot=-10)),
                         e.get("spike", "steel"), UP))
        elif t == "stripes":
            out.append(F(n, 3.05, [P("square", 160, e.get("y", 196), 118, e.get("h", 5), repeat={"grid": [1, e.get("count", 7)], "step": [0, e.get("step", 13)]})],
                         m, UP, kind="flat", clip_to="torso", opacity=0.9))
        elif t == "sleeve_stripes":
            for side, x in (("r", 106), ("l", 214)):
                out.append(F(f"{n}_{side}", 5.1, [P("square", x, 212, 30, 4, repeat={"grid": [1, 4], "step": [0, 13]})], m,
                             ["upper", f"arm_{side}"], kind="flat", clip_to=f"sleeve_{side}", opacity=0.9))
        elif t == "gloves":
            continue
        elif t == "clerical":
            out.append(F(n, 8.2, [P("square", 160, 181, 20, 8)], m, UP))
        elif t == "quiver":
            out.append(F(n, 0.85, [P("square", 196, 190, 20, 64, rot=24)], m, UP))
            out.append(F(n + "_arrows", 0.8, [P("feather", 208 + i * 5, 156 - i * 3, 12, 22, rot=24) for i in range(3)], "cloth_white", UP))
        elif t == "sheath":
            out.append(F(n, 4.3, [P("square", 196, 262, 8, 86, rot=-62)], m, UP))
            out.append(F(n + "_hilt", 4.35, [P("square", 160, 243, 7, 24, rot=-62), P("circle", 172, 249, 12, 5, rot=-62)],
                         e.get("hilt", "iron_dark"), UP))
        elif t == "fur_trim":
            out.append(F(n, 3.9, [P("square", 160, 292, 18, 150)], m, FRONT))
        elif t == "trim_v":
            out.append(F(n, 3.9, [P("square", 160, e.get("y", 262), e.get("w", 14), e.get("h", 140))], m, FRONT))
        elif t == "patch":
            out.append(F(n, 3.95, [P("square", e.get("x", 140), e.get("y", 250), 16, 14, rot=12)], m, UP))
        elif t == "gorget":
            out.append(F(n, 8, [P("circle", 160, 182, 62, 20)], m, UP))
        elif t == "kesa":
            out.append(F(n, 4.2, [P("square", 160, 232, 26, 128, rot=-34)], m, FRONT))
            out.append(F(n + "_ring", 4.3, [P("circle", 138, 200, 10, 10)], e.get("ring", "gold"), FRONT))
        elif t == "wires":
            out.append(F(n, 8.4, [P("circle", 190, 178, 26, 26), P("circle", 190, 178, 20, 20, op="sub")], m, UP))
            out.append(F(n + "_port", 11.8, [P("circle", 190, 160, 7, 7)], e.get("glow", "neon_cyan"), ["upper", "head", "feature"],
                         kind="flat", emit=0.8))
        elif t == "shoulder_lamp":
            out.append(F(n, 7.6, [P("square", 206, 186, 16, 12)], "iron_dark", UP))
            out.append(F(n + "_l", 7.7, [P("circle", 206, 186, 8, 8)], e.get("glow", "neon_amber"), UP, kind="flat", emit=0.9))
        else:
            raise KeyError(f"unknown extra {t!r}")
    return out
