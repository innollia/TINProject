"""Body, face, expressions and hair (battler space, see core.py)."""

from __future__ import annotations

from .core import FACE, HAND, F, P, mirror, pair

UP = ["upper"]
HEADT = ["upper", "head"]
FEAT = ["upper", "head", "feature"]


def shadow():
    return [F("shadow", -5, [P("circle", 160, 371, 136, 22)], kind="shadow", color="shadow_contact",
              opacity=0.42, blur=4, tags=["no_portrait"])]


def legs(mat, boots="boot", boot_mat="leather", width=1.0, hide_legs=False):
    out = []
    for side, x in (("r", 146.0), ("l", 174.0)):
        tag = ["legs", f"leg_{side}", "no_portrait"]
        if not hide_legs:
            out.append(F(f"leg_{side}", 1, [P("square", x, 297, 32 * width, 64), P("square", x + (-1 if side == "r" else 1), 334, 27 * width, 62)],
                         mat, tag))
        bx = x + (-1.5 if side == "r" else 1.5)
        if boots == "boot":
            pcs = [P("square", bx, 346, 30, 36), P("circle", bx + (-1 if side == "r" else 1), 364, 36, 20)]
        elif boots == "tall":
            pcs = [P("square", bx, 334, 32, 60), P("circle", bx, 364, 37, 20), P("square", bx, 306, 36, 10)]
        elif boots == "shoe":
            pcs = [P("square", bx, 358, 26, 14), P("circle", bx, 366, 34, 16)]
        elif boots == "sandal":
            out.append(F(f"foot_{side}", 1.9, [P("circle", bx, 364, 30, 18)], "skin", tag))
            pcs = [P("circle", bx, 370, 36, 8), P("square", bx, 360, 28, 4)]
        elif boots == "sabaton":
            pcs = [P("square", bx, 342, 32, 44), P("circle", bx, 364, 38, 22), P("circle", bx, 322, 34, 16)]
        elif boots == "bare":
            pcs = [P("circle", bx, 364, 30, 18)]
            boot_mat = "skin"
        else:
            continue
        out.append(F(f"boot_{side}", 2, pcs, boot_mat, tag))
    return out


def arms(mat, hand_mat="skin", width=1.0, cuff=None, bare=False):
    out = []
    for side in ("r", "l"):
        tag = ["upper", f"arm_{side}"]
        sleeve = P("shield", 105.5, 233, 27 * width, 88, half="left", rot=6)
        hand = P("droplet", HAND["r"][0], HAND["r"][1], 19, 23, flip="y", rot=6)
        cf = P("circle", 104.5, 268, 24 * width, 10, rot=6)
        if side == "l":
            sleeve, hand, cf = mirror(sleeve), mirror(hand), mirror(cf)
        out.append(F(f"sleeve_{side}", 5, [sleeve], "skin" if bare else mat, tag))
        if cuff:
            out.append(F(f"cuff_{side}", 5.3, [cf], cuff, tag))
        out.append(F(f"hand_{side}", 6, [hand], hand_mat, tag))
    return out


def neck(mat="skin"):
    return [F("neck", 2.9, [P("square", 160, 172, 24, 20)], mat, UP)]


# ------------------------------------------------------------------ face
def face(spec):
    fs = spec.get("face", {})
    skin = spec.get("skin", "skin")
    shape = fs.get("shape", "round")
    cx, cy = FACE
    pcs = [P("circle", cx, cy, 72, 66)]
    if shape == "square":
        pcs.append(P("square", cx, cy + 16, 60, 34))
    elif shape == "long":
        pcs = [P("circle", cx, cy + 2, 66, 72)]
    elif shape == "soft":
        pcs = [P("circle", cx, cy + 1, 74, 64)]
    out = [F("face", 9, pcs, skin, HEADT, shade={"highlight_amount": 0.28})]
    if fs.get("ears"):
        out.append(F("ears", 8.9, pair(P("circle", 124, 143, 12, 18)), skin, HEADT))
    return out


def expressions(spec):
    fs = spec.get("face", {})
    eye_mat = fs.get("eye", "eye")
    brow_mat = fs.get("brow_mat", spec.get("hair", {}).get("mat", "hair"))
    ew, eh = {"normal": (8.5, 11), "narrow": (10, 6.5), "wide": (10, 12.5), "small": (6.5, 8)}[fs.get("eyes", "normal")]
    ey = 143 + fs.get("eye_dy", 0)
    out = []
    for nm, x, extra in (("eye_near", 146, []), ("eye_far", 174, ["far"])):
        out.append(F(nm, 11, [P("circle", x, ey, ew, eh)], eye_mat, FEAT + ["eyes_open"] + extra, kind="flat"))
        if eh >= 8:
            out.append(F(nm + "_glint", 11.05, [P("circle", x - ew * 0.2, ey - eh * 0.22, ew * 0.34, ew * 0.34)], None,
                         FEAT + ["eyes_open"] + extra, kind="flat", color="white_ink", opacity=0.75))
        rot = 16 if x < 160 else -16
        out.append(F(nm + "_hit", 11, [P("circle", x, ey, 12, 3.2, rot=rot)], "eye",
                     FEAT + ["eyes_hit"] + extra, kind="flat", hidden=True))
    bw, bh = {"thick": (15, 4.6), "normal": (13, 3.4), "thin": (12, 2.4)}[fs.get("brows", "normal")]
    by = 129 + fs.get("brow_dy", 0)
    for tag, dy, rot, hidden in (("brow_calm", 0, 4, False), ("brow_angry", 3, 20, True), ("brow_hurt", -1, -17, True)):
        for x, extra in ((146, []), (174, ["far"])):
            r = -rot if x < 160 else rot
            if tag != "brow_calm":
                r = rot if x < 160 else -rot
            out.append(F(f"{tag}_{x}", 11.2, [P("circle", x, by + dy, bw, bh, rot=r)], brow_mat,
                         FEAT + [tag] + extra, kind="flat", hidden=hidden))
    out.append(F("nose", 11, [P("moon", 160, 153, 6, 4, rot=200)], None, ["upper", "head", "nose"], kind="flat", color="skin_shadow"))
    mouth = fs.get("mouth", "line")
    if mouth == "smile":
        mp = P("moon", 160, 161, 13, 6, rot=-90)
    elif mouth == "frown":
        mp = P("moon", 160, 163, 12, 5, rot=90)
    elif mouth == "grim":
        mp = P("circle", 160, 162, 17, 2.8)
    elif mouth == "lips":
        mp = P("circle", 160, 162, 11, 4)
    else:
        mp = P("circle", 160, 162, 12, 2.6)
    out.append(F("mouth", 11.1, [mp], "lip" if mouth == "lips" else "mouth", FEAT + ["mouth_idle"], kind="flat"))
    out.append(F("mouth_shout", 11.1, [P("circle", 160, 163, 12, 9)], "mouth", FEAT + ["mouth_shout"], kind="flat", hidden=True))
    out.append(F("mouth_hurt", 11.1, [P("circle", 160, 163, 13, 5.5, rot=-8)], "mouth", FEAT + ["mouth_hurt"], kind="flat", hidden=True))
    if fs.get("blush"):
        out.append(F("blush", 10.9, pair(P("circle", 139, 156, 11, 5)), "blush", FEAT, kind="flat", opacity=0.4, clip_to="face"))
    if fs.get("wrinkles"):
        out.append(F("wrinkles", 11.05, pair(P("circle", 133, 150, 7, 1.6, rot=25)) + [P("circle", 160, 121, 16, 1.6)],
                     None, FEAT, kind="flat", color="skin_shadow", opacity=0.8))
    if fs.get("scar"):
        out.append(F("scar", 11.4, [P("circle", 177, 142, 2.6, 20, rot=18)], "lip", FEAT, kind="flat", opacity=0.9))
    beard = fs.get("beard")
    bmat = fs.get("beard_mat", spec.get("hair", {}).get("mat", "hair"))
    if beard in ("full", "long"):
        h = 50 if beard == "full" else 74
        out.append(F("beard", 10.8, [P("droplet", 160, 162 + h * 0.2, 64, h, flip="y"), P("circle", 160, 156, 70, 26)],
                     bmat, HEADT + ["hair"], cut_by=[]))
    if beard in ("full", "long", "mustache", "curl"):
        m = [P("droplet", 151, 158, 8, 17, rot=-96), P("droplet", 169, 158, 8, 17, rot=96)]
        if beard == "curl":
            m += [P("moon", 139, 154, 8, 9, rot=-30), P("moon", 181, 154, 8, 9, rot=210)]
        out.append(F("mustache", 11.3, m, bmat, FEAT))
    if beard == "goatee":
        out.append(F("goatee", 11.3, [P("droplet", 160, 173, 15, 18, flip="y")], bmat, FEAT))
    if beard == "stubble":
        out.append(F("stubble", 10.95, [P("circle", 160, 162, 60, 26)], bmat, FEAT, kind="flat", opacity=0.22, clip_to="face"))
    return out


# ------------------------------------------------------------------ hair
def hair(spec):
    hs = spec.get("hair", {})
    style = hs.get("style", "short")
    mat = hs.get("mat", "hair")
    out = []
    back, front = [], []
    if style in ("none", "hidden"):
        return out
    if style == "bald":
        return [F("skull", 8.95, [P("circle", 160, 126, 78, 80)], spec.get("skin", "skin"), HEADT)]
    if style == "buzz":
        return [F("hair_back", 8.95, [P("circle", 160, 124, 80, 78)], mat, HEADT + ["hair"], texture={"strength": 0.04})]
    if style == "mohawk":
        return [F("skull", 8.95, [P("circle", 160, 124, 78, 80)], spec.get("skin", "skin"), HEADT),
                F("hair_front", 10, [P("mountains", 160, 80, 40, 60, rot=-90, crop=[0, 3, 16, 14]), P("square", 160, 98, 22, 34)],
                  mat, HEADT + ["hair"])]
    back.append(P("circle", 160, 118, 100, 92))
    if style in ("short", "bob", "long", "ponytail", "braids", "wild"):
        front += [P("cloud", 160, 95, 106, 52),
                  P("droplet", 144, 113, 19, 23, flip="y", rot=14), P("droplet", 160, 115, 16, 22, flip="y"),
                  P("droplet", 176, 113, 19, 23, flip="y", rot=-14)]
        front += pair(P("droplet", 127, 131, 15, 32, flip="y", rot=5))
    if style == "bob":
        front += pair(P("droplet", 125, 150, 17, 40, flip="y", rot=3))
    if style == "long":
        out.append(F("hair_long", 0.5, [P("bell", 160, 176, 124, 128, crop=[1.6, 3.4, 14.4, 12])], mat, HEADT + ["hair"]))
        front += pair(P("droplet", 127, 170, 18, 70, flip="y", rot=3))
    if style == "wild":
        out.append(F("hair_long", 0.5, [P("bell", 160, 180, 132, 136, crop=[1.6, 3.4, 14.4, 12]),
                                        P("leaf", 108, 222, 26, 44, rot=30), P("leaf", 212, 222, 26, 44, rot=-30, flip="x")],
                     mat, HEADT + ["hair"]))
        front += pair(P("leaf", 126, 168, 20, 58, rot=8))
    if style == "ponytail":
        out.append(F("hair_tail", 0.4, [P("droplet", 207, 158, 22, 70, flip="y", rot=-14)], mat, HEADT + ["hair"]))
    if style == "braids":
        for x0, x1 in ((129, 122), (191, 198)):
            out.append(F(f"braid_{x0}", 10.2, [P("circle", x0, 150, 15, 15, repeat={"line": [[x0, 150], [x1, 226]], "count": 7})],
                         mat, HEADT + ["hair"]))
    if style in ("slick", "topknot", "bun", "cap"):
        front += [P("umbrella", 160, 102, 102, 44, crop=[0.6, 2.3, 15.4, 8.7])]
        front += pair(P("droplet", 126, 124, 12, 24, flip="y", rot=4))
    if style == "topknot":
        out.append(F("topknot", 9.6, [P("cylinder", 160, 74, 20, 24), P("circle", 160, 86, 30, 10)], mat, HEADT + ["hair"]))
    if style == "bun":
        out.append(F("bun", 9.6, [P("circle", 160, 78, 38, 34)], mat, HEADT + ["hair"]))
    if style == "spiky":
        front += [P("cloud", 160, 98, 104, 46), P("mountains", 160, 84, 112, 40),
                  P("mountains", 138, 104, 40, 24, rot=-20), P("mountains", 182, 104, 40, 24, rot=20)]
        front += pair(P("droplet", 128, 129, 13, 28, flip="y", rot=8))
    if style == "curly":
        front += [P("cloud", 160, 94, 110, 54), P("cloud", 132, 112, 44, 34, rot=-30), P("cloud", 188, 112, 44, 34, rot=30)]
        back = [P("cloud", 160, 128, 128, 104)]
    if style == "receding":
        back = [P("circle", 160, 132, 94, 74)]
        front = pair(P("droplet", 125, 134, 13, 30, flip="y", rot=6)) + pair(P("cloud", 130, 120, 22, 16, rot=-40))
        out.append(F("skull", 8.95, [P("circle", 160, 122, 76, 78)], spec.get("skin", "skin"), HEADT))
    out.append(F("hair_back", 0.6, back, mat, HEADT + ["hair"]))
    if front:
        out.append(F("hair_front", 10, front, mat, HEADT + ["hair"], shade={"highlight_amount": 0.7, "highlight": 0.9}))
    return out
