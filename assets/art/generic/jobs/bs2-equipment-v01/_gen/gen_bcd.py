"""Groups B (armour 37-52), C (shields 53-58), D (jewellery 59-72)."""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from kit import (damp_stains, etch, iron_tarnish, p, patina, soot, stain,  # noqa: E402
                 wash, write_all)

ITEMS = []


def cord_loop(at, size=170, material="leather", z=2):
    """Top arc of a ring: the thread a charm is hung on.

    ``size`` is the width of the arc.  A cropped piece's ``size`` is the size of
    the cropped region, not of the whole icon, so the height has to be derived
    from the crop aspect or the loop comes out stretched.
    """
    crop = [2.0, 3.0, 14.0, 8.6]
    w, h = size, size * (crop[3] - crop[1]) / (crop[2] - crop[0])
    return {"name": "cord", "z": z, "kind": "flat", "material": material,
            "line": False, "pieces": [p("ring", at, [w, h], crop=crop)]}


def halo(name, pieces, pad=13, z=-1):
    """Near-black copy of a silhouette, drawn behind it.

    Without this, two garments at 512 px on a dark floor merge into one mass and
    the whole thing reads as a blob.  pad is the outline thickness in px.
    """
    out = []
    for pc in pieces:
        q = dict(pc)
        s = q.get("size")
        if isinstance(s, (int, float)):
            q["size"] = s + 2 * pad
        elif isinstance(s, list):
            q["size"] = [v + 2 * pad for v in s]
        out.append(q)
    return {"name": name, "z": z, "material": "stone_cap", "line": False,
            "pieces": [q for q in out if q.get("op", "add") == "add"]}


def torso(name, material, w=290, y=300, h=320, neck_w=250, neck_y=146, z=0, pad=13):
    """Block torso with a neck hole: the base every garment here is built on."""
    body = [p("square", [256, y], [w, h], slice={"border": 3, "corner": 3}),
            p("circle", [256, neck_y], [neck_w, 132], op="sub")]
    return [halo(name + "_edge", body, pad, z - 0.5),
            {"name": name, "z": z, "material": material, "pieces": body}]


def skirt(name, material, w=410, y=420, h=250, rot=180, z=1, tears=(), pad=13):
    pieces = [p("triangle", [256, y], [w, h], rot=rot)]
    for tx, ty, ts, _tw in tears:
        pieces.append(p("circle", [tx, ty], [ts, ts], op="sub"))
    return [halo(name + "_edge", pieces, pad, z - 0.5),
            {"name": name, "z": z, "material": material, "pieces": pieces}]


def sleeves(name, material, x=80, w=180, h=240, y=262, z=1, pad=13):
    pieces = [p("circle", [x, y], [w, h]), p("circle", [512 - x, y], [w, h])]
    return [halo(name + "_edge", pieces, pad, z - 0.5),
            {"name": name, "z": z, "material": material, "pieces": pieces}]


def flat(name, material, pieces, z=2, opacity=1.0, clip=None):
    form = {"name": name, "z": z, "kind": "flat", "material": material,
            "opacity": opacity, "line": False, "pieces": pieces}
    if clip:
        form["clip_to"] = clip
    return form


# ---------------------------------------------------------------- B. armour
# slice border/corner are in the 0..8 icon-grid band, not pixels - large values
# produce an empty body.  Cloth uses coat_top/worn so the silhouette survives a
# dark background.
# 37 rusted helm
# Built on the tragedy_mask silhouette: it already reads as a head, so the helm
# gets a dome, a nose bar and a flared neck instead of fighting the shape.
ITEMS.append(("eq_a01_rusted_helm", [
    halo("skull_edge", [p("tragedy_mask", [256, 236], [340, 360])], 14, -1),
    {"name": "skull", "z": 0, "material": "iron",
     "pieces": [p("tragedy_mask", [256, 236], [340, 360])]},
    {"name": "dome", "z": 1, "material": "iron",
     "pieces": [p("circle", [256, 116], [330, 190])]},
    {"name": "neck", "z": 1, "material": "iron",
     "pieces": [p("triangle", [256, 400], [420, 190], rot=180)]},
    {"name": "nose", "z": 2, "kind": "flat", "material": "worn", "opacity": 0.7,
     "line": False, "clip_to": "skull",
     "pieces": [p("square", [256, 250], [24, 190])]},
    {"name": "eye_slots", "z": 2, "kind": "flat", "material": "void",
     "line": False, "clip_to": "skull",
     "pieces": [p("circle", [200, 214], [70, 58]), p("circle", [312, 214], [70, 58])]},
    {"name": "mouth", "z": 2, "kind": "flat", "material": "void",
     "line": False, "clip_to": "skull", "pieces": [p("square", [256, 322], [96, 16])]},
    {"name": "rivets", "z": 2.5, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [256, 400], [16, 16],
                  repeat={"line": [[70, 372], [442, 372]], "count": 9})]},
    iron_tarnish("skull", ((200, 190, 200, 150), (330, 300, 180, 150))),
    iron_tarnish("dome", ((256, 116, 280, 160),)),
    stain([p("droplet", [196, 250], [26, 40])], "rust", 0.5, clip="skull", z=9.1),
], "37 rusted helm. An open-faced iron skull, now one flat orange-brown patch. Rivets are the only thing still bright."))

# 38 knight helm
ITEMS.append(("eq_a02_knight_helm", [
    halo("skull_edge", [p("tragedy_mask", [256, 226], [340, 370])], 14, -1),
    {"name": "skull", "z": 0, "material": "iron",
     "pieces": [p("tragedy_mask", [256, 226], [340, 370])]},
    {"name": "dome", "z": 1, "material": "iron",
     "pieces": [p("circle", [256, 104], [336, 200])]},
    {"name": "neck", "z": 1, "material": "iron",
     "pieces": [p("triangle", [256, 396], [430, 200], rot=180)]},
    {"name": "visor", "z": 2, "kind": "flat", "material": "stone_cap", "opacity": 0.85,
     "line": False, "clip_to": "skull",
     "pieces": [p("square", [256, 212], [300, 26]),
                p("square", [256, 262], [26, 150])]},
    {"name": "eye_slots", "z": 2, "kind": "flat", "material": "void",
     "line": False, "clip_to": "skull",
     "pieces": [p("square", [200, 186], [104, 20]),
                p("square", [312, 186], [104, 20])]},
    {"name": "breath", "z": 2, "kind": "flat", "material": "void",
     "line": False, "clip_to": "skull",
     "pieces": [p("circle", [206, 322], [40, 40]), p("circle", [256, 322], [40, 40]),
                p("circle", [306, 322], [40, 40])]},
    {"name": "band", "z": 2.5, "material": "bronze",
     "pieces": [p("square", [256, 156], [310, 24])]},
    iron_tarnish("skull", ((196, 200, 150, 130), (330, 300, 150, 130))),
    iron_tarnish("dome", ((256, 104, 290, 170),)),
], "38 knight helm. A great helm with a cross visor, two eye slits and three breath holes. Kept because it fits."))

# 39 leather hood
ITEMS.append(("eq_a39_leather_hood", [
    halo("cap_edge", [p("tragedy_mask", [256, 216], [330, 350]),
                      p("triangle", [256, 396], [430, 200], rot=180)], 13, -1),
    {"name": "cap", "z": 0, "material": "leather",
     "pieces": [p("tragedy_mask", [256, 216], [330, 350])]},
    skirt("cape", "leather", 430, 396, 200, 180, 0.5),
    {"name": "rim", "z": 2, "kind": "flat", "material": "worn", "opacity": 0.6,
     "line": False, "clip_to": "cap",
     "pieces": [p("circle", [256, 262], [210, 230])]},
    {"name": "stitch", "z": 3, "kind": "flat", "material": "stone_cap",
     "opacity": 0.5, "line": False, "clip_to": "cape",
     "pieces": [p("circle", [256, 484], [20, 20],
                  repeat={"line": [[110, 470], [402, 470]], "count": 9})]},
    damp_stains("cape", ((256, 410, 360, 180),)),
], "39 leather hood. A boiled-leather cap with the face cut out and a shoulder cape laced along the hem. Stiff, sour, mould at the seams."))

# 40 iron mask
ITEMS.append(("eq_a40_iron_mask", [
    {"name": "plate", "z": 0, "material": "iron",
     "pieces": [p("tragedy_mask", [256, 262], [390, 390])]},
    {"name": "eye_slots", "z": 1, "kind": "flat", "material": "void",
     "line": False, "clip_to": "plate",
     "pieces": [p("circle", [198, 222], [76, 62]),
                p("circle", [314, 222], [76, 62])]},
    {"name": "mouth", "z": 1, "kind": "flat", "material": "void",
     "line": False, "clip_to": "plate",
     "pieces": [p("square", [256, 348], [112, 18], rot=-4)]},
    {"name": "straps", "z": 2, "material": "leather",
     "pieces": [p("square", [46, 190], [120, 26], rot=-18),
                p("square", [46, 340], [120, 26], rot=18)]},
    {"name": "rivets", "z": 2, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [256, 262], [14, 14],
                  repeat={"ellipse": [256, 262, 168, 176], "count": 10,
                          "arc": [20, 340], "skip": [4, 5, 6]})]},
    iron_tarnish("plate", ((200, 210, 140, 120), (330, 330, 130, 110))),
], "40 iron mask. A pressed theatre face in sheet iron, eye holes cut to slits. Somebody kept the expression and lost the face."))

# 41 jester mask
ITEMS.append(("eq_a41_jester_mask", [
    {"name": "mask", "z": 0, "material": "paper",
     "pieces": [p("carnival_mask", [256, 280], [350, 350])]},
    {"name": "cracks", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.4, "line": False, "clip_to": "mask",
     "pieces": [p("square", [180, 210], [110, 12], rot=28),
                p("square", [340, 330], [120, 12], rot=-34)]},
    {"name": "cap", "z": 2, "material": "cloth_wine",
     "pieces": [p("triangle", [256, 130], [390, 130], rot=180)]},
    {"name": "ears", "z": 2, "material": "cloth_wine",
     "pieces": [p("circle", [72, 130], [130, 130]),
                p("circle", [440, 130], [130, 130])]},
    {"name": "bells", "z": 3, "material": "bronze",
     "pieces": [p("bell", [72, 252], [86, 86]),
                p("bell", [440, 252], [86, 86])]},
    {"name": "eye_slots", "z": 3, "kind": "flat", "material": "void",
     "line": False, "clip_to": "mask",
     "pieces": [p("circle", [198, 258], [66, 46]), p("circle", [314, 258], [66, 46])]},
    damp_stains("mask", ((256, 290, 300, 220),)),
], "41 jester mask. Card, split at the cheek, still wearing its two bells. The grin is painted on; the eyes are not painted on."))

# 42 chainmail
ITEMS.append(("eq_a42_chainmail", [
    torso("mail", "iron", 300, 300, 300, 260, 152),
    sleeves("shoulders", "iron", 74, 170, 140, 232, 0.5),
    skirt("skirt", "iron", 400, 412, 210),
    {"name": "links", "z": 1.5, "kind": "flat", "material": "worn", "opacity": 0.55,
     "line": False, "clip_to": "mail",
     "pieces": [p("circle", [150, 210], [26, 26],
                  repeat={"grid": [6, 4], "step": [44, 46], "at": [150, 210],
                          "stagger": 22, "skip": [[0, 0], [5, 3]]})]},
    {"name": "collar", "z": 2, "material": "cloth_wine",
     "pieces": [p("ring", [256, 160], [250, 84], crop=[1.0, 6.0, 15.0, 11.0])]},
    iron_tarnish("mail", ((200, 300, 210, 200), (350, 400, 180, 150))),
], "42 chainmail. A short shirt of iron links over a skirt, collar still lined with cloth. Rusted through in a band where a body leaned on it."))

# 43 plate mail
ITEMS.append(("eq_a43_plate_mail", [
    torso("cuirass", "iron", 320, 300, 300, 250, 150),
    sleeves("pauldrons", "iron", 76, 200, 170, 226, 0.5),
    skirt("fauld", "iron", 380, 414, 200),
    {"name": "gorget", "z": 2, "material": "bronze",
     "pieces": [p("ring", [256, 156], [256, 92], crop=[1.0, 5.5, 15.0, 11.0])]},
    {"name": "seam", "z": 3, "kind": "flat", "material": "stone_cap",
     "opacity": 0.55, "line": False, "clip_to": "cuirass",
     "pieces": [p("square", [256, 330], [14, 270]),
                p("square", [256, 262], [244, 12])]},
    {"name": "buckles", "z": 3, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [256, 266], [38, 38]), p("circle", [256, 344], [38, 38])]},
    iron_tarnish("cuirass", ((200, 330, 210, 200), (350, 420, 170, 140))),
], "43 plate mail. A breastplate with pauldrons and a fauld, centre seam, two buckles and nothing else. It is armour for a person who only ever stood still."))

# 44 leather mail
ITEMS.append(("eq_a44_leather_mail", [
    torso("jerkin", "worn", 320, 300, 300, 260, 150),
    sleeves("sleeves", "leather", 70, 180, 230, 250, 0.5),
    skirt("skirt", "leather", 420, 414, 220),
    {"name": "straps", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.55, "line": False, "clip_to": "jerkin",
     "pieces": [p("square", [256, 254], [310, 20], rot=-9),
                p("square", [256, 330], [310, 20], rot=7)]},
    {"name": "buckles", "z": 3, "material": "bronze",
     "pieces": [p("square", [182, 258], [42, 28], rot=-9),
                p("square", [334, 336], [42, 28], rot=7)]},
    {"name": "stitch", "z": 3, "kind": "flat", "material": "stone_cap",
     "opacity": 0.45, "line": False, "clip_to": "skirt",
     "pieces": [p("circle", [256, 500], [18, 18],
                  repeat={"line": [[96, 486], [416, 486]], "count": 9})]},
    damp_stains("skirt", ((256, 430, 340, 150),)),
], "44 leather mail. A boiled jerkin with a skirt of strips and two brass buckles. The shoulder seams have been restitched four times."))

# 45 ragged robe
ITEMS.append(("eq_a45_ragged_robe", [
    torso("body", "coat_top", 300, 296, 300, 250, 148),
    sleeves("sleeves", "coat_top", 76, 180, 250, 252),
    skirt("skirt", "coat_top", 420, 412, 250, 180, 1,
          tears=((132, 476, 96, 96), (300, 492, 86, 86), (400, 468, 74, 74))),
    {"name": "cord", "z": 2, "material": "leather",
     "pieces": [p("square", [256, 300], [310, 26])]},
    {"name": "fold", "z": 2, "kind": "flat", "material": "coat_dark", "opacity": 0.7,
     "line": False, "clip_to": "skirt",
     "pieces": [p("square", [190, 430], [14, 200]), p("square", [330, 430], [14, 200])]},
    damp_stains("skirt", ((256, 400, 350, 200),)),
    soot("body", ((256, 250, 300, 260),)),
], "45 ragged robe. A grey coat worn out at the hem, belted with a bootlace. Nobody mended it and nobody threw it away."))

# 46 cult robe
ITEMS.append(("eq_a46_cult_robe", [
    torso("body", "cloth_wine", 300, 296, 300, 250, 148),
    sleeves("sleeves", "cloth_wine", 72, 185, 255, 252),
    skirt("skirt", "cloth_wine", 420, 414, 250),
    {"name": "hood", "z": 2, "material": "coat",
     "pieces": [p("circle", [256, 182], [330, 250]),
                p("circle", [256, 218], [176, 176], op="sub")]},
    {"name": "mark", "z": 3, "kind": "flat", "material": "paper",
     "opacity": 0.75, "line": False, "clip_to": "body",
     "pieces": [p("square", [256, 290], [86, 20]), p("square", [256, 290], [20, 86])]},
    damp_stains("skirt", ((256, 400, 340, 200),)),
], "46 cult robe. Wine-red wool, hood up and empty, a chalk cross on the chest that has been scrubbed and re-drawn many times."))

# 47 cape
ITEMS.append(("eq_a47_cape", [
    {"name": "cloth", "z": 0, "material": "cloth_wine",
     "pieces": [p("circle", [256, 200], [440, 300]),
                p("triangle", [256, 400], [430, 300], rot=180),
                p("circle", [256, 156], [230, 130], op="sub"),
                p("circle", [120, 480], [96, 96], op="sub"),
                p("circle", [396, 470], [86, 86], op="sub")]},
    {"name": "folds", "z": 1, "kind": "flat", "material": "coat_seam",
     "opacity": 0.45, "line": False, "clip_to": "cloth",
     "pieces": [p("square", [186, 340], [16, 300]), p("square", [326, 340], [16, 300]),
                p("square", [256, 350], [14, 280])]},
    {"name": "clasp", "z": 2, "material": "bronze",
     "pieces": [p("circle", [256, 152], [76, 76]), p("square", [256, 152], [34, 34], rot=45)]},
    damp_stains("cloth", ((256, 360, 360, 260),)),
], "47 cape. A wine-red cloak on a bronze ring clasp, worn through at both lower corners."))

# 48 leather glove
ITEMS.append(("eq_a48_leather_glove", [
    {"name": "hand", "z": 0, "material": "leather",
     "pieces": [p("hand", [252, 240], [380, 380], crop=[1.0, 0.5, 15.0, 13.0])]},
    {"name": "cuff", "z": 1, "material": "worn",
     "pieces": [p("square", [256, 378], [340, 104], slice={"border": 2, "corner": 2})]},
    {"name": "fingers", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.4, "line": False, "clip_to": "hand",
     "pieces": [p("square", [256, 240], [310, 12]),
                p("square", [196, 254], [12, 170]), p("square", [316, 254], [12, 170])]},
    {"name": "lacing", "z": 3, "kind": "flat", "material": "stone_cap",
     "opacity": 0.55, "line": False, "clip_to": "cuff",
     "pieces": [p("circle", [256, 378], [22, 22],
                  repeat={"line": [[116, 378], [396, 378]], "count": 7})]},
    damp_stains("hand", ((256, 270, 300, 220),)),
], "48 leather glove. A soft glove with a gauntlet cuff, lacing snapped in two places. The index finger is stiff."))

# 49 iron glove
ITEMS.append(("eq_a49_iron_glove", [
    {"name": "hand", "z": 0, "material": "iron",
     "pieces": [p("hand", [252, 240], [380, 380], crop=[1.0, 0.5, 15.0, 13.0])]},
    {"name": "knuckles", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.55, "line": False, "clip_to": "hand",
     "pieces": [p("circle", [252, 240], [300, 130])]},
    {"name": "studs", "z": 2, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [252, 240], [24, 24],
                  repeat={"line": [[110, 202], [394, 202]], "count": 6})]},
    {"name": "cuff", "z": 2, "material": "worn",
     "pieces": [p("square", [256, 378], [340, 108], slice={"border": 2, "corner": 2})]},
    iron_tarnish("hand", ((230, 200, 220, 160), (300, 310, 160, 130))),
], "49 iron glove. Plate over the knuckles, studs along the seam, a closed cuff. Heavy as the rest of the set."))

# 50 leather boot
ITEMS.append(("eq_a50_leather_boot", [
    {"name": "sole", "z": 0, "material": "leather",
     "pieces": [p("square", [250, 440], [420, 76], slice={"border": 2, "corner": 2})]},
    {"name": "upper", "z": 1, "material": "worn",
     "pieces": [p("square", [300, 336], [230, 190], slice={"border": 2, "corner": 2}),
                p("circle", [86, 440], [150, 150])]},
    {"name": "shaft", "z": 1, "material": "worn",
     "pieces": [p("square", [292, 200], [200, 240], slice={"border": 2, "corner": 2})]},
    {"name": "cuff", "z": 2, "material": "leather",
     "pieces": [p("square", [292, 96], [240, 60], slice={"border": 2, "corner": 2})]},
    {"name": "buckle", "z": 3, "material": "bronze",
     "pieces": [p("square", [292, 130], [70, 30])]},
    {"name": "seam", "z": 3, "kind": "flat", "material": "stone_cap",
     "opacity": 0.5, "line": False, "clip_to": "upper",
     "pieces": [p("square", [300, 336], [12, 180])]},
    damp_stains("shaft", ((292, 200, 190, 220),)),
], "50 leather boot. A low-cuffed work boot with the toe gone soft. Sole worn through at the ball of the foot."))

# 51 iron boot
ITEMS.append(("eq_a51_iron_boot", [
    {"name": "greave", "z": 0, "material": "iron",
     "pieces": [p("square", [292, 300], [250, 270], slice={"border": 2, "corner": 2})]},
    {"name": "foot", "z": 0, "material": "iron",
     "pieces": [p("square", [256, 430], [420, 92], slice={"border": 2, "corner": 2}),
                p("circle", [72, 430], [160, 160])]},
    {"name": "bands", "z": 2, "material": "bronze",
     "pieces": [p("square", [292, 236], [258, 22]), p("square", [292, 350], [254, 22])]},
    {"name": "hinge", "z": 3, "material": "iron",
     "pieces": [p("circle", [396, 300], [46, 46]), p("circle", [396, 386], [46, 46])]},
    iron_tarnish("greave", ((260, 300, 210, 230),)),
    iron_tarnish("foot", ((250, 430, 320, 120),)),
], "51 iron boot. A sabaton with a rounded toe and two hinge pins at the ankle. Heavier than the leg it was made for."))

# 52 bracer
ITEMS.append(("eq_a52_bracer", [
    {"name": "band", "z": 0, "material": "iron",
     "pieces": [p("cylinder", [256, 290], [320, 340]),
                p("square", [256, 290], [312, 190], op="sub"),
                p("circle", [256, 160], [300, 140]),
                p("circle", [256, 420], [300, 140])]},
    {"name": "plates", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.5, "line": False, "clip_to": "band",
     "pieces": [p("square", [256, 290], [14, 190]),
                p("square", [256, 290], [300, 14])]},
    {"name": "straps", "z": 2, "material": "leather",
     "pieces": [p("square", [256, 198], [318, 36], rot=-6),
                p("square", [256, 382], [318, 36], rot=6)]},
    {"name": "buckles", "z": 3, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [256, 198], [40, 40]), p("circle", [256, 382], [40, 40])]},
    iron_tarnish("band", ((256, 290, 280, 220),)),
], "52 bracer. A forearm shell with two leather straps and bronze buckles. The inside is polished by one arm only."))

# ---------------------------------------------------------------- C. shields
# The `shield` icon already reads as a shield, so the shaped boards build on it
# and the round one uses circle + halo.
ITEMS.append(("eq_s01_round_wood_shield", [
    halo("board_edge", [p("circle", [256, 256], [400, 400])], 15, -1),
    {"name": "board", "z": 0, "material": "wood",
     "pieces": [p("circle", [256, 256], [400, 400])]},
    {"name": "planks", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.5, "line": False, "clip_to": "board",
     "pieces": [p("square", [176, 256], [12, 400]), p("square", [256, 256], [12, 400]),
                p("square", [336, 256], [12, 400])]},
    {"name": "rim", "z": 2, "kind": "flat", "material": "iron",
     "pieces": [p("circle", [256, 256], [400, 400]),
                p("circle", [256, 256], [340, 340], op="sub")]},
    {"name": "boss", "z": 3, "material": "iron",
     "pieces": [p("circle", [256, 256], [150, 150]),
                p("circle", [256, 256], [90, 90])]},
    {"name": "rivets", "z": 3, "kind": "flat", "material": "bronze",
     "pieces": [p("circle", [256, 256], [20, 20],
                  repeat={"ellipse": [256, 256, 176, 176], "count": 12})]},
    damp_stains("board", ((200, 200, 200, 200), (340, 340, 180, 180))),
], "53 round wood shield. Plank board, iron rim, iron boss, twelve rivets. The rim is bent in on the right from something that hit it."))

ITEMS.append(("eq_s02_kite_shield", [
    halo("board_edge", [p("shield", [256, 210], [380, 330]),
                        p("square", [256, 118], [230, 80], slice={"border": 2, "corner": 2}),
                        p("triangle", [256, 380], [330, 300], rot=180)], 14, -1),
    {"name": "board", "z": 0, "material": "wood",
     "pieces": [p("shield", [256, 210], [380, 330]),
                p("square", [256, 118], [230, 80], slice={"border": 2, "corner": 2}),
                p("triangle", [256, 380], [330, 300], rot=180)]},
    {"name": "bands", "z": 1, "kind": "flat", "material": "iron", "opacity": 0.9,
     "pieces": [p("square", [256, 250], [300, 18]), p("square", [256, 330], [250, 16])]},
    {"name": "boss", "z": 2, "material": "iron",
     "pieces": [p("circle", [256, 200], [120, 120]), p("circle", [256, 200], [70, 70])]},
    {"name": "edge", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.4, "line": False, "clip_to": "board",
     "pieces": [p("square", [256, 400], [300, 16], rot=4)]},
    damp_stains("board", ((256, 240, 300, 260),)),
], "54 kite shield. A tall board drawn to a point at the bottom, two iron bands, one boss. Made to hide a man and not to be carried."))

ITEMS.append(("eq_s03_tower_shield", [
    halo("board_edge", [p("shield", [256, 230], [330, 400]),
                        p("square", [256, 300], [300, 200], slice={"border": 2, "corner": 2})],
         14, -1),
    {"name": "board", "z": 0, "material": "wood",
     "pieces": [p("shield", [256, 230], [330, 400]),
                p("square", [256, 300], [300, 200], slice={"border": 2, "corner": 2})]},
    {"name": "bands", "z": 1, "kind": "flat", "material": "iron", "opacity": 0.9,
     "pieces": [p("square", [256, 160], [290, 18]), p("square", [256, 300], [290, 18]),
                p("square", [256, 420], [290, 18])]},
    {"name": "boss", "z": 2, "material": "iron",
     "pieces": [p("circle", [256, 200], [130, 130]), p("circle", [256, 200], [76, 76])]},
    {"name": "grain", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.35, "line": False, "clip_to": "board",
     "pieces": [p("square", [206, 260], [10, 400]), p("square", [306, 260], [10, 400])]},
    damp_stains("board", ((256, 300, 260, 340),)),
], "55 tower shield. A door on a hinge: full height, three bands, one boss. It does not leave the wall."))

ITEMS.append(("eq_s04_rusted_buckler", [
    halo("disc_edge", [p("circle", [256, 256], [380, 380])], 15, -1),
    {"name": "disc", "z": 0, "material": "iron",
     "pieces": [p("circle", [256, 256], [380, 380])]},
    {"name": "dents", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.4, "line": False, "clip_to": "disc",
     "pieces": [p("circle", [180, 200], [110, 110]), p("circle", [350, 330], [90, 90])]},
    {"name": "rim", "z": 2, "kind": "flat", "material": "iron",
     "pieces": [p("circle", [256, 256], [380, 380]),
                p("circle", [256, 256], [326, 326], op="sub")]},
    {"name": "boss", "z": 3, "material": "iron",
     "pieces": [p("circle", [256, 256], [150, 150]), p("square", [256, 256], [70, 70], rot=45)]},
    {"name": "strap", "z": 3, "material": "leather",
     "pieces": [p("square", [256, 366], [320, 40], rot=-8)]},
    iron_tarnish("disc", ((200, 200, 190, 180), (330, 320, 190, 180))),
], "56 rusted buckler. A palm-sized dish dented in two places and orange with rust. The handle strap is the only leather left on it."))

ITEMS.append(("eq_s05_heraldic_shield", [
    halo("board_edge", [p("shield", [256, 250], [380, 420])], 15, -1),
    {"name": "board", "z": 0, "material": "cloth_wine",
     "pieces": [p("shield", [256, 250], [380, 420])]},
    {"name": "border", "z": 1, "kind": "flat", "material": "bronze", "opacity": 0.9,
     "line": False, "clip_to": "board",
     # crop [2,1,14,3.4] is 12 x 2.4 icon units of a 380x420 shield: size must be
     # the size of THAT region (285 x 63) placed at its own centre, not 380x420.
     "pieces": [p("shield", [256, 98], [285, 63], crop=[2.0, 1.0, 14.0, 3.4])]},
    {"name": "device", "z": 2, "kind": "flat", "material": "paper",
     "opacity": 0.85, "line": False, "clip_to": "board",
     "pieces": [p("square", [256, 240], [140, 30]), p("square", [256, 240], [30, 140])]},
    {"name": "boss", "z": 3, "material": "iron",
     "pieces": [p("circle", [256, 250], [96, 96]), p("circle", [256, 250], [54, 54])]},
    damp_stains("board", ((256, 250, 320, 360),)),
], "57 heraldic shield. Wine field, bronze border, a chalk cross on the front. The device has been scrubbed off and re-chalked twice."))

ITEMS.append(("eq_s06_spiked_shield", [
    halo("board_edge", [p("shield", [256, 258], [320, 380])], 14, -1),
    {"name": "board", "z": 0, "material": "wood",
     "pieces": [p("shield", [256, 258], [320, 380])]},
    {"name": "spikes", "z": 1, "material": "iron",
     "pieces": [p("triangle", [256, 250], [70, 96],
                  repeat={"ellipse": [256, 250, 180, 200], "count": 9, "orient": True,
                          "jitter": {"at": 4.0, "rot": 6.0}})]},
    {"name": "bands", "z": 2, "kind": "flat", "material": "iron", "opacity": 0.9,
     "pieces": [p("square", [256, 210], [280, 18]), p("square", [256, 310], [240, 16])]},
    {"name": "boss", "z": 3, "material": "iron",
     "pieces": [p("circle", [256, 210], [120, 120]), p("circle", [256, 210], [68, 68])]},
    iron_tarnish("spikes", ((256, 250, 380, 380),)),
    damp_stains("board", ((256, 280, 280, 300),)),
], "58 spiked shield. A board with nails through the edge, all of them pointing out. Meant to be held, not to be carried."))

# ---------------------------------------------------------------- D. jewellery
ITEMS.append(("eq_j01_rusted_ring", [
    {"name": "band", "z": 0, "material": "iron",
     "pieces": [p("ring", [256, 250], [380, 340])]},
    {"name": "wear", "z": 1, "kind": "flat", "material": "worn", "opacity": 0.5,
     "line": False, "clip_to": "band",
     "pieces": [p("square", [256, 250], [380, 16])]},
    iron_tarnish("band", ((200, 200, 200, 180), (330, 300, 200, 170))),
], "59 rusted ring. A plain iron band, gone orange, thin on the inside from being worn. It is not jewellery any more."))

ITEMS.append(("eq_j02_gem_ring", [
    {"name": "band", "z": 0, "material": "bronze",
     "pieces": [p("ring", [256, 268], [360, 320])]},
    {"name": "seat", "z": 1, "material": "bronze",
     "pieces": [p("square", [256, 118], [110, 46], slice={"border": 6, "corner": 10})]},
    {"name": "gem", "z": 2, "material": "glass", "emit": 0.25,
     "glow": {"radius": 6, "opacity": 0.4, "color": "flame_glow"},
     "pieces": [p("gem", [256, 88], [200, 180])]},
    patina([p("cloud", [256, 268], [240, 200])], "rust", 0.4, clip="band", z=9.1),
], "60 gem ring. A bronze band with a green glass stone in a four-prong seat. The stone is warm and the band is not."))

ITEMS.append(("eq_j03_skull_ring", [
    {"name": "band", "z": 0, "material": "bronze",
     "pieces": [p("ring", [256, 292], [340, 280])]},
    {"name": "skull", "z": 1, "material": "bone",
     "pieces": [p("skull", [256, 148], [220, 220])]},
    {"name": "eye_slots", "z": 2, "kind": "flat", "material": "void", "line": False,
     "clip_to": "skull",
     "pieces": [p("circle", [222, 132], [34, 36]), p("circle", [290, 132], [34, 36]),
                p("triangle", [256, 176], [22, 26], rot=180)]},
    patina([p("cloud", [256, 292], [230, 190])], "rust", 0.35, clip="band", z=9.1),
], "61 skull ring. A bronze band with a child's skull set on top, filed smooth where a thumb rubs it."))

ITEMS.append(("eq_j04_snake_ring", [
    halo("coil_edge", [p("ring", [256, 300], [340, 300])], 12, -1),
    {"name": "coil", "z": 0, "material": "iron",
     "pieces": [p("ring", [256, 300], [340, 300])]},
    halo("coil2_edge", [p("ring", [256, 246], [270, 240])], 12, 0.4),
    {"name": "coil2", "z": 0.5, "material": "iron",
     "pieces": [p("ring", [256, 246], [270, 240])]},
    {"name": "head", "z": 1, "material": "iron",
     "pieces": [p("droplet", [256, 132], [130, 160])]},
    {"name": "eye", "z": 2, "kind": "flat", "material": "ember", "opacity": 0.9,
     "line": False, "clip_to": "head",
     "pieces": [p("circle", [228, 116], [30, 30])]},
    {"name": "scales", "z": 2, "kind": "flat", "material": "worn", "opacity": 0.45,
     "line": False, "clip_to": "coil",
     "pieces": [p("circle", [256, 300], [22, 22],
                  repeat={"ellipse": [256, 300, 148, 128], "count": 14, "arc": [200, 340]})]},
    iron_tarnish("coil", ((200, 290, 200, 180), (320, 330, 180, 160))),
], "62 snake ring. A band with two coils and a head with one lit eye. The scales are worn flat where it has been turned."))

ITEMS.append(("eq_j05_pendant_necklace", [
    {"name": "cord", "z": 0, "kind": "flat", "material": "bronze",
     "pieces": [p("link", [256, 168], [46, 46], rot=45,
                  repeat={"ellipse": [256, 300, 190, 190], "count": 16, "arc": [190, 350]})]},
    {"name": "bail", "z": 1, "material": "bronze",
     "pieces": [p("ring", [256, 306], [80, 80], crop=[3.0, 1.0, 13.0, 9.0])]},
    {"name": "pendant", "z": 2, "material": "glass", "emit": 0.25,
     "glow": {"radius": 6, "opacity": 0.4, "color": "flame_glow"},
     "pieces": [p("diamond", [256, 386], [180, 220])]},
    {"name": "frame", "z": 2.5, "kind": "flat", "material": "bronze", "opacity": 0.8,
     "line": False, "clip_to": "pendant",
     "pieces": [p("diamond", [256, 386], [150, 186])]},
    patina([p("cloud", [256, 380], [220, 260])], "rust", 0.3, z=9.1),
], "63 pendant necklace. A bronze link chain with a glass stone in a bronze frame. It hangs straight and level, which is unusual."))

ITEMS.append(("eq_j06_rocket_charm", [
    {"name": "cord", "z": 0, "kind": "flat", "material": "leather",
     "pieces": [p("ring", [256, 120], [300, 240], crop=[2.0, 3.0, 14.0, 7.4])]},
    {"name": "body", "z": 1, "material": "iron",
     "pieces": [p("square", [256, 250], [110, 200], slice={"border": 6, "corner": 50})]},
    {"name": "nose", "z": 1, "material": "iron",
     "pieces": [p("triangle", [256, 128], [110, 90], rot=180)]},
    {"name": "fins", "z": 1, "material": "iron",
     "pieces": [p("triangle", [176, 316], [90, 110], rot=90),
                p("triangle", [336, 316], [90, 110], rot=-90)]},
    {"name": "flame", "z": 1.5, "material": "ember", "emit": 0.45,
     "glow": {"radius": 7, "opacity": 0.45, "color": "flame_glow"},
     "pieces": [p("triangle", [256, 400], [80, 110], rot=180)]},
    iron_tarnish("body", ((256, 260, 130, 220),)),
], "64 rocket charm. An iron rocket on a leather loop, and something in it still burning. The list named a heart icon; a heart does not read as a rocket, so this is built from cone/square/triangle instead."))

ITEMS.append(("eq_j07_charm_tag", [
    {"name": "plate", "z": 0, "material": "wood",
     "pieces": [p("diamond_shape", [256, 300], [300, 320], rot=90)]},
    {"name": "grain", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.3, "line": False, "clip_to": "plate",
     "pieces": [p("square", [256, 300], [10, 300])]},
    {"name": "carving", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.7, "line": False, "clip_to": "plate",
     "pieces": [p("circle", [256, 280], [90, 90]),
                p("square", [256, 340], [110, 14]),
                p("square", [256, 372], [80, 12])]},
    {"name": "hole", "z": 2.5, "kind": "flat", "material": "void", "line": False,
     "clip_to": "plate", "pieces": [p("circle", [256, 156], [40, 40])]},
    cord_loop([256, 152], 210),
    damp_stains("plate", ((256, 310, 260, 260),)),
], "65 charm tag. A wooden amulet on a thread, with a circle and two bars cut into it. The carving is not a letter. That is deliberate."))

ITEMS.append(("eq_j08_prayer_beads", [
    {"name": "loop", "z": 0, "kind": "flat", "material": "leather",
     "pieces": [p("link", [256, 240], [44, 44], rot=45,
                  repeat={"ellipse": [256, 250, 180, 190], "count": 18, "arc": [0, 360]})]},
    {"name": "beads", "z": 1, "material": "wood",
     "pieces": [p("circle", [256, 250], [64, 64],
                  repeat={"ellipse": [256, 250, 180, 190], "count": 18,
                          "skip": [0, 9]})]},
    {"name": "marker", "z": 2, "material": "bronze",
     "pieces": [p("circle", [256, 66], [64, 64]), p("circle", [256, 434], [64, 64])]},
    {"name": "cross", "z": 2, "material": "bronze",
     "pieces": [p("square", [256, 150], [24, 130]), p("square", [256, 128], [96, 22])]},
    damp_stains("beads", None) if False else stain(
        [p("cloud", [256, 250], [200, 200])], "grime", 0.25, z=9.1),
], "66 prayer beads. Eighteen dark wooden beads on a loop with two bronze markers and a cross. The beads are worn to different colours."))

ITEMS.append(("eq_j09_bone_charm", [
    {"name": "bone", "z": 0, "material": "bone",
     "pieces": [p("bone", [256, 262], [400, 400])]},
    {"name": "crack", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.45, "line": False, "clip_to": "bone",
     "pieces": [p("square", [256, 262], [300, 12], rot=42)]},
    {"name": "hole", "z": 2, "kind": "flat", "material": "void", "line": False,
     "clip_to": "bone", "pieces": [p("circle", [140, 380], [46, 46])]},
    cord_loop([150, 400], 210),
    stain([p("droplet", [300, 180], [34, 52])], "grime", 0.35, clip="bone", z=9.1),
], "67 bone charm. A cracked long bone on a thread, grey where it has been handled. One end is drilled for the string and the other end is not."))

ITEMS.append(("eq_j10_feather_charm", [
    {"name": "quill", "z": 0, "material": "bone",
     "pieces": [p("feather", [256, 262], [380, 380])]},
    {"name": "barbs", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.35, "line": False, "clip_to": "quill",
     "pieces": [p("square", [256, 262], [12, 340], rot=42)]},
    {"name": "hole", "z": 2, "kind": "flat", "material": "void", "line": False,
     "clip_to": "quill", "pieces": [p("circle", [146, 372], [42, 42])]},
    cord_loop([152, 392], 200),
    stain([p("cloud", [256, 262], [200, 200])], "grime", 0.3, clip="quill", z=9.1),
], "68 feather charm. A grey quill on a thread, barbs worn away on one side. The vane is symmetrical except where a thumb held it."))

ITEMS.append(("eq_j11_eye_charm", [
    {"name": "eye", "z": 0, "material": "bronze",
     "pieces": [p("eye", [256, 260], [400, 300])]},
    {"name": "pupil", "z": 1, "kind": "flat", "material": "void", "opacity": 0.9,
     "line": False, "clip_to": "eye", "pieces": [p("circle", [256, 260], [130, 130])]},
    {"name": "shine", "z": 2, "kind": "flat", "material": "glass", "opacity": 0.6,
     "line": False, "clip_to": "pupil", "pieces": [p("circle", [222, 228], [40, 40])]},
    {"name": "hole", "z": 3, "kind": "flat", "material": "void", "line": False,
     "clip_to": "eye", "pieces": [p("circle", [256, 104], [40, 40])]},
    cord_loop([256, 104], 210),
    patina([p("cloud", [256, 260], [280, 220])], "rust", 0.4, z=9.1),
], "69 eye charm. A cast bronze eye on a thread, pupil a hole straight through. The shine is polished brass, not light."))

ITEMS.append(("eq_j12_cursed_gem", [
    {"name": "stone", "z": 0, "material": "glass", "emit": 0.2,
     "glow": {"radius": 7, "opacity": 0.4, "color": "flame_glow"},
     "pieces": [p("gem", [256, 256], [400, 400])]},
    {"name": "core", "z": 1, "kind": "flat", "material": "void", "opacity": 0.85,
     "line": False, "clip_to": "stone", "pieces": [p("circle", [256, 280], [150, 150])]},
    {"name": "cracks", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.6, "line": False, "clip_to": "stone",
     "pieces": [p("square", [256, 256], [330, 12], rot=28),
                p("square", [256, 256], [330, 12], rot=-38),
                p("square", [256, 256], [300, 10], rot=88)]},
    patina([p("cloud", [256, 256], [300, 300])], "soot", 0.35, clip="stone", z=9.3),
], "70 cursed gem. A green glass stone with a black core and three cracks. Held to the light it is warmer on one side."))

ITEMS.append(("eq_j13_key_necklace", [
    {"name": "key", "z": 0, "material": "iron",
     "pieces": [p("key", [256, 250], [380, 380])]},
    {"name": "teeth", "z": 1, "kind": "flat", "material": "stone_cap",
     "opacity": 0.4, "line": False, "clip_to": "key",
     "pieces": [p("square", [140, 400], [110, 14], rot=40),
                p("square", [172, 424], [90, 12], rot=40)]},
    {"name": "hole", "z": 2, "kind": "flat", "material": "void", "line": False,
     "clip_to": "key", "pieces": [p("circle", [386, 128], [70, 70])]},
    cord_loop([386, 122], 220),
    iron_tarnish("key", ((220, 220, 200, 180), (320, 320, 180, 160))),
], "71 key necklace. An iron key worn on a loop around the neck. It is not for any door that still exists."))

ITEMS.append(("eq_j14_moon_charm", [
    {"name": "crescent", "z": 0, "material": "bronze",
     "pieces": [p("moon", [256, 268], [400, 400])]},
    {"name": "face", "z": 1, "kind": "flat", "material": "bronze_block",
     "opacity": 0.7, "line": False, "clip_to": "crescent",
     "pieces": [p("circle", [300, 220], [90, 90]), p("circle", [276, 300], [70, 70])]},
    {"name": "eye", "z": 2, "kind": "flat", "material": "void",
     "line": False, "clip_to": "crescent", "pieces": [p("circle", [280, 214], [30, 34])]},
    {"name": "hole", "z": 3, "kind": "flat", "material": "void", "line": False,
     "clip_to": "crescent", "pieces": [p("circle", [372, 116], [44, 44])]},
    cord_loop([372, 112], 210),
    patina([p("cloud", [256, 268], [280, 280])], "rust", 0.45, z=9.1),
], "72 moon charm. A bronze crescent with one eye and a worn face, on a thread. The hole is at the tip of the waxing moon, which is the wrong way up for a charm."))

if __name__ == "__main__":
    write_all(ITEMS)
