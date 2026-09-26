"""Group A - weapons 1..36.  Coordinates are hand-placed against the 16x16 icon grid.

Icon grid notes used throughout (u,v in 0..16, y down):
  sword/dagger  blade runs (3.8,12.2) -> (13,2); guard ~(3.2,11.5); pommel (1,15)
  knife         handle (3.5,12.5); broad blade (8,6.5); tip (13,3)
  axe           head (10.5,5.5); haft butt (3,14)
  hammer        head (10,4.5); haft butt (2,14)
  sledgehammer  head block (10,5); haft butt (2,14)
  club          trefoil circles (7,4) (3,9) (11,9)
  pickaxe       head (10,5.5); haft butt (4,13)
  flintlock     barrel (10,6); grip (3.5,12)
  bow_and_arrow bow arc x 1..8 ; arrow head (13,3) ; fletch (5,11)
  arrow_projectile shaft (2,13) -> (12,4)
"""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from kit import (SQUARE, damp_stains, etch, iron_tarnish, p, patina, soot,  # noqa: E402
                 stain, wash, write_all)

# --- shared sub-assemblies ----------------------------------------------------


def grip_wrap(at, size, rot=45, material="leather", bands=3):
    """Leather cord wound round the grip: short bars across the haft, not a lump on it."""
    pieces = []
    dx, dy = (18.0, 18.0) if rot >= 0 else (-18.0, 18.0)
    for i in range(bands):
        o = (i - (bands - 1) / 2.0)
        pieces.append(p("square", [at[0] + dx * o, at[1] + dy * o],
                        [size, size * 0.3], rot=rot))
    return {"name": "grip", "z": 3, "material": material, "pieces": pieces}


def pommel(at, size, material="iron"):
    return {"name": "pommel", "z": 3, "material": material,
            "pieces": [p("circle", at, [size, size]),
                       p("square", at, [size * 0.45, size * 0.45], rot=45)]}


def edge_hilite(name, at, size, rot, clip, material="worn", opacity=0.7):
    return {"name": name, "z": 2, "kind": "flat", "material": material,
            "opacity": opacity, "line": False, "clip_to": clip,
            "pieces": [p("square", at, size, rot=rot)]}


ITEMS = []

# 1 rusted longsword
ITEMS.append(("eq_w01_rusted_longsword", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("sword", [256, 256], [400, 400])]},
    edge_hilite("edge", [268, 236], [26, 300], -45, "blade", "worn", 0.6),
    grip_wrap([114, 384], 66),
    pommel([88, 424], 40),
    iron_tarnish("blade"),
    stain([p("droplet", [210, 320], [40, 60]), p("cloud", [300, 200], [110, 70])],
          "rust", 0.5, clip="blade", z=9.1),
], "1 rusted longsword. Plain iron long sword, blade gone orange-brown, leather wrap gone hard and cracked. Blood is rust bloom, not red paint."))

# 2 chipped longsword
ITEMS.append(("eq_w02_chipped_longsword", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("sword", [256, 256], [400, 400],
                  op="add"),
                p("triangle", [404, 128], [86, 86], rot=225, op="sub")]},
    edge_hilite("edge", [262, 244], [24, 250], -45, "blade", "worn", 0.5),
    grip_wrap([114, 384], 66, material="leather"),
    pommel([88, 424], 40),
    iron_tarnish("blade", ((300, 200, 140, 100), (370, 260, 90, 80), (200, 300, 120, 90))),
    stain([p("droplet", [300, 300], [30, 44])], "rust", 0.7, clip="blade", z=9.1),
], "2 chipped longsword. A notch bitten out of the point; the tip is a stub now. Dull, pitted, kept because there is nothing better."))

# 3 crusader longsword
ITEMS.append(("eq_w03_crusader_longsword", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("sword", [256, 256], [400, 400])]},
    {"name": "inlay", "z": 1, "kind": "flat", "material": "bronze", "opacity": 0.9,
     "line": False, "clip_to": "blade",
     "pieces": [p("square", [268, 244], [96, 20], rot=-45),
                p("square", [268, 244], [20, 96], rot=-45),
                p("circle", [268, 244], [22, 22])]},
    edge_hilite("edge", [286, 226], [18, 260], -45, "blade", "worn", 0.55),
    grip_wrap([114, 384], 66, material="leather"),
    pommel([88, 424], 44, "bronze"),
    iron_tarnish("blade", ((330, 190, 120, 90), (200, 320, 120, 80))),
    damp_stains("blade"),
], "3 crusader longsword. Plain straight blade, a small cross stamped into the flat near the hilt, bronze pommel gone green-grey. The relic of somebody who never existed."))

# 4 executioner greatsword
ITEMS.append(("eq_w04_executioner_greatsword", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("sword", [256, 262], [400, 400]),
                p("square", [368, 152], [104, 132], rot=-45)]},
    edge_hilite("edge", [272, 246], [30, 250], -45, "blade", "worn", 0.45),
    {"name": "block_tip", "z": 1, "kind": "flat", "material": "stone_cap", "opacity": 0.4,
     "line": False, "clip_to": "blade",
     "pieces": [p("square", [368, 152], [86, 108], rot=-45)]},
    grip_wrap([136, 372], 86, material="leather"),
    pommel([92, 414], 48),
    iron_tarnish("blade", ((330, 180, 170, 120), (230, 320, 150, 100), (150, 250, 110, 90))),
    stain([p("cloud", [370, 150], [130, 90])], "rust", 0.6, clip="blade", z=9.1),
], "4 executioner greatsword. Long, heavy, and the point is a flat slab instead of a tip - it was never sharpened to kill, only to end. Wrapped grip dark with use."))

# 5 black greatsword
ITEMS.append(("eq_w05_black_greatsword", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("sword", [256, 256], [416, 416])]},
    {"name": "blackened", "z": 1, "kind": "flat", "material": "stone_cap", "opacity": 0.88,
     "line": False, "clip_to": "blade",
     "pieces": [p("sword", [256, 256], [416, 416])]},
    edge_hilite("edge", [272, 234], [16, 280], -45, "blade", "stone_dark", 0.9),
    grip_wrap([140, 368], 80, material="leather"),
    pommel([98, 408], 44, "stone_dark"),
    soot("blade", ((280, 240, 200, 150),)),
    stain([p("cloud", [330, 180], [90, 70])], "rust", 0.3, clip="blade", z=9.4),
], "5 black greatsword. Blade sooted to a flat black that eats the highlight. Only the faintest orange at the root where the hand never reaches."))

# 6 scimitar
ITEMS.append(("eq_w06_scimitar", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("cutlass", [256, 256], [416, 416])]},
    edge_hilite("edge", [300, 220], [22, 250], -22, "blade", "worn", 0.6),
    {"name": "knuckle", "z": 3, "material": "bronze",
     "pieces": [p("ring", [136, 372], [72, 56], rot=-30),
                p("square", [150, 350], [18, 60], rot=-30)]},
    pommel([104, 412], 40),
    iron_tarnish("blade", ((330, 210, 150, 110), (210, 300, 120, 90))),
], "6 scimitar. Curved single edge, knuckle bow at the hilt. Sellsword shape on a village - bent, not made, bent."))

# 7 dagger
ITEMS.append(("eq_w07_dagger", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("dagger", [268, 250], [352, 352])]},
    edge_hilite("edge", [286, 232], [18, 210], -45, "blade", "worn", 0.65),
    grip_wrap([168, 356], 62),
    pommel([140, 388], 34),
    iron_tarnish("blade", ((320, 200, 110, 80), (240, 300, 90, 70))),
], "7 plain dagger. Short, cheap, resharpened so often the edge is uneven. The tool everybody carries."))

# 8 rite dagger
ITEMS.append(("eq_w08_rite_dagger", [
    {"name": "blade", "z": 0, "material": "bronze",
     "pieces": [p("dagger", [268, 250], [352, 352])]},
    {"name": "inlay", "z": 1, "kind": "flat", "material": "glass", "opacity": 0.75,
     "line": False, "clip_to": "blade",
     "pieces": [p("cross", [282, 236], [72, 72], rot=-45),
                p("droplet", [300, 218], [34, 46])]},
    {"name": "guard", "z": 3, "material": "bronze",
     "pieces": [p("square", [176, 340], [86, 14], rot=-45),
                p("triangle", [148, 366], [34, 34], rot=45)]},
    grip_wrap([146, 372], 54, material="cloth_wine"),
    {"name": "pommel_gem", "z": 4, "material": "glass", "emit": 0.35,
     "glow": {"radius": 5, "opacity": 0.4, "color": "flame_glow"},
     "pieces": [p("diamond", [136, 392], [46, 52])]},
    patina([p("metaballs", [300, 200], [110, 80]), p("sponge", [230, 300], [90, 70])],
           "rust", 0.45, clip="blade"),
], "8 rite dagger. Bronze blade with a cross cut into the flat, wine-red cloth on the grip, a glass stone in the pommel that is not quite glass. Used for one purpose at a time."))

# 9 saw knife
ITEMS.append(("eq_w09_saw_knife", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("knife", [250, 258], [300, 300])]},
    {"name": "teeth", "z": 1, "material": "iron",
     "pieces": [p("triangle", [231, 262], [40, 40], rot=48,
                  repeat={"line": [[236, 266], [302, 310]], "count": 5, "jitter": {"at": 3.0}}),
                p("triangle", [381, 183], [40, 40], rot=118,
                  repeat={"line": [[375, 189], [310, 308]], "count": 6, "jitter": {"at": 3.0}})]},
    {"name": "handle", "z": 3, "material": "wood",
     "pieces": [p("square", [140, 350], [96, 34], rot=45),
                p("circle", [110, 380], [30, 30])]},
    {"name": "rivets", "z": 4, "kind": "flat", "material": "iron",
     "pieces": [p("circle", [150, 340], [11, 11]), p("circle", [128, 362], [11, 11])]},
    iron_tarnish("blade", ((300, 210, 130, 100), (200, 300, 110, 90))),
], "9 saw-tooth knife. Somebody filed teeth into a kitchen blade. The teeth are uneven and two are bent flat."))

# 10 butcher knife
ITEMS.append(("eq_w10_butcher_knife", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("knife", [268, 246], [372, 372])]},
    edge_hilite("edge", [318, 214], [22, 190], 118, "blade", "worn", 0.5),
    {"name": "handle", "z": 3, "material": "wood",
     "pieces": [p("square", [136, 372], [110, 36], rot=45),
                p("square", [112, 396], [26, 26], rot=45)]},
    {"name": "rivets", "z": 4, "kind": "flat", "material": "iron",
     "pieces": [p("circle", [150, 358], [12, 12]), p("circle", [128, 380], [12, 12])]},
    iron_tarnish("blade", ((320, 200, 140, 100), (230, 300, 120, 90))),
    damp_stains("blade", ((260, 250, 200, 150),)),
], "10 butcher knife. Wide, thin, cheap. The steel is soft and the edge rolls over. It has done one job for years."))

# 11 hand axe
ITEMS.append(("eq_w11_hand_axe", [
    {"name": "head", "z": 0, "material": "iron",
     "pieces": [p("axe", [262, 262], [372, 372])]},
    edge_hilite("bit", [368, 232], [22, 170], -12, "head", "worn", 0.6),
    {"name": "thong", "z": 3, "material": "leather",
     "pieces": [p("square", [176, 348], [58, 54], rot=45),
                p("square", [192, 332], [42, 40], rot=45)]},
    iron_tarnish("head", ((330, 220, 150, 130), (230, 320, 110, 90))),
    damp_stains("head", ((280, 240, 220, 180),)),
], "11 hand axe. Small head, split handle, one leather thong holding the head on. Chipped away on one side."))

# 12 battle axe
ITEMS.append(("eq_w12_battle_axe", [
    {"name": "head", "z": 0, "material": "iron",
     "pieces": [p("axe", [266, 250], [408, 408])]},
    edge_hilite("bit", [382, 216], [26, 200], -12, "head", "worn", 0.55),
    {"name": "bands", "z": 3, "material": "bronze",
     "pieces": [p("square", [190, 336], [64, 46], rot=45),
                p("square", [206, 320], [50, 38], rot=45)]},
    iron_tarnish("head", ((350, 210, 160, 130), (240, 320, 120, 100))),
], "12 battle axe. Long haft, two bronze bands, a bit re-edged so many times it is a shape rather than a blade."))

# 13 double axe
ITEMS.append(("eq_w13_double_axe", [
    {"name": "haft", "z": 0, "material": "wood",
     "pieces": [p("square", [256, 300], [48, 370]),
                p("square", [256, 462], [64, 26], rot=4)]},
    {"name": "bit_l", "z": 1, "material": "iron",
     "pieces": [p("triangle", [136, 168], [190, 210], rot=270)]},
    {"name": "bit_r", "z": 1, "material": "iron",
     "pieces": [p("triangle", [376, 168], [190, 210], rot=90)]},
    {"name": "eyes", "z": 2, "material": "iron",
     "pieces": [p("square", [216, 168], [70, 130]),
                p("square", [296, 168], [70, 130])]},
    {"name": "edges", "z": 2.5, "kind": "flat", "material": "worn", "opacity": 0.6,
     "line": False, "clip_to": "bit_l",
     "pieces": [p("square", [136, 168], [190, 16], rot=270)]},
    {"name": "edges_r", "z": 2.5, "kind": "flat", "material": "worn", "opacity": 0.6,
     "line": False, "clip_to": "bit_r",
     "pieces": [p("square", [376, 168], [190, 16], rot=90)]},
    {"name": "band", "z": 3, "material": "bronze",
     "pieces": [p("square", [256, 268], [110, 40]),
                p("square", [256, 232], [96, 30])]},
    iron_tarnish("bit_l", ((150, 170, 140, 150),)),
    iron_tarnish("bit_r", ((362, 170, 140, 150),)),
], "13 double axe. Two heads back to back on a straight haft. Balanced wrong; it wants to turn in the swing."))

# 14 iron club
ITEMS.append(("eq_w14_iron_club", [
    {"name": "core", "z": 0, "material": "iron",
     "pieces": [p("club", [256, 256], [340, 340])]},
    {"name": "studs", "z": 2, "kind": "flat", "material": "stone_cap",
     "line": False, "clip_to": "core",
     "pieces": [p("circle", [200, 200], [30, 30],
                  repeat={"ellipse": [256, 256, 108, 108], "count": 10, "orient": True})]},
    {"name": "stud_bumps", "z": 2.5, "kind": "flat", "material": "worn", "opacity": 0.6,
     "line": False, "clip_to": "core",
     "pieces": [p("circle", [196, 196], [18, 18],
                  repeat={"ellipse": [256, 256, 108, 108], "count": 10, "orient": True})]},
    {"name": "haft", "z": 3, "material": "wood",
     "pieces": [p("square", [256, 424], [56, 90], rot=8)]},
    iron_tarnish("core", ((300, 200, 150, 130), (200, 320, 130, 100))),
], "14 iron club. A knot of scrap bound around a length of wood, studs driven through. It is mostly dents."))

# 15 spiked club
ITEMS.append(("eq_w15_spiked_club", [
    {"name": "core", "z": 0, "material": "wood",
     "pieces": [p("club", [256, 264], [300, 300])]},
    {"name": "spikes", "z": 1, "material": "iron",
     "pieces": [p("triangle", [256, 150], [56, 80],
                  repeat={"ellipse": [256, 264, 128, 128], "count": 9, "orient": True,
                          "jitter": {"at": 6.0, "rot": 8.0}})]},
    {"name": "ferrule", "z": 2, "material": "iron",
     "pieces": [p("square", [256, 412], [60, 46])]},
    iron_tarnish("spikes", ((300, 200, 160, 120),)),
    stain([p("cloud", [256, 300], [200, 160])], "rust", 0.35, z=9.1),
], "15 spiked club. A studded length of wood with nails bent outward and left in. Two of the nails are teeth."))

# 16 war hammer
ITEMS.append(("eq_w16_war_hammer", [
    {"name": "head", "z": 0, "material": "iron",
     "pieces": [p("hammer", [300, 208], [336, 336])]},
    edge_hilite("edge", [356, 176], [22, 150], -20, "head", "worn", 0.6),
    {"name": "haft", "z": 3, "material": "wood",
     "pieces": [p("square", [172, 366], [290, 36], rot=-45)]},
    {"name": "collar", "z": 4, "material": "iron",
     "pieces": [p("square", [238, 300], [46, 60], rot=-45)]},
    iron_tarnish("head", ((360, 180, 140, 110), (250, 290, 100, 80))),
], "16 war hammer. Maul head with a short claw, long haft, iron collar where the wood keeps splitting."))

# 17 great sledgehammer
ITEMS.append(("eq_w17_great_sledgehammer", [
    {"name": "head", "z": 0, "material": "iron",
     "pieces": [p("sledgehammer", [330, 200], [360, 360])]},
    edge_hilite("edge", [390, 168], [26, 190], -16, "head", "worn", 0.5),
    {"name": "haft", "z": 3, "material": "wood",
     "pieces": [p("square", [170, 372], [300, 42], rot=-45)]},
    {"name": "grip", "z": 4, "material": "leather",
     "pieces": [p("square", [128, 414], [90, 52], rot=-45)]},
    iron_tarnish("head", ((380, 170, 170, 130), (200, 330, 150, 110))),
    stain([p("metaballs", [340, 190], [140, 110])], "rust", 0.5, clip="head", z=9.1),
], "17 great sledgehammer. Slab head, haft twice as thick as a normal hammer's. Built for a job that is not carpentry."))

# 18 pickaxe
ITEMS.append(("eq_w18_pickaxe", [
    {"name": "head", "z": 0, "material": "iron",
     "pieces": [p("pickaxe", [278, 220], [368, 368])]},
    edge_hilite("edge", [368, 176], [20, 170], -12, "head", "worn", 0.5),
    {"name": "haft", "z": 3, "material": "wood",
     "pieces": [p("square", [168, 360], [280, 34], rot=-45)]},
    {"name": "wrap", "z": 4, "material": "leather",
     "pieces": [p("square", [180, 348], [70, 48], rot=-45),
                p("square", [196, 332], [54, 40], rot=-45)]},
    iron_tarnish("head", ((360, 180, 150, 110), (230, 300, 110, 90))),
], "18 pickaxe. Long curved pick, one point ground down to a stub. The haft is grey with sweat and stone dust."))

# 19 spear
ITEMS.append(("eq_w19_spear", [
    {"name": "shaft", "z": 0, "material": "wood",
     "pieces": [p("square", [244, 292], [430, 24], rot=-45)]},
    {"name": "head", "z": 1, "material": "iron",
     "pieces": [p("dagger", [372, 166], [270, 270], crop=[3.5, 1.0, 14.5, 11.0])]},
    {"name": "socket", "z": 2, "material": "iron",
     "pieces": [p("square", [316, 224], [50, 60], rot=-45)]},
    {"name": "collar", "z": 2, "material": "bronze",
     "pieces": [p("square", [292, 248], [40, 48], rot=-45)]},
    {"name": "butt", "z": 1, "material": "iron",
     "pieces": [p("cone", [70, 464], [34, 48], rot=135)]},
    {"name": "wrap", "z": 3, "material": "leather",
     "pieces": [p("square", [250, 286], [66, 38], rot=-45),
                p("square", [264, 272], [50, 30], rot=-45)]},
    iron_tarnish("head", ((390, 140, 110, 100),)),
    stain([p("cloud", [200, 350], [140, 90])], "grime", 0.3, clip="shaft", z=9.1),
], "19 spear. Long ash shaft, socketed iron head, iron shoe on the butt so it can be planted. Straight and badly balanced."))

# 20 glaive
ITEMS.append(("eq_w20_glaive", [
    {"name": "shaft", "z": 0, "material": "wood",
     "pieces": [p("square", [268, 280], [440, 26], rot=-52)]},
    {"name": "hook", "z": 1, "material": "iron",
     "pieces": [p("hook", [382, 158], [150, 150], rot=-40)]},
    {"name": "blade", "z": 1, "material": "iron",
     "pieces": [p("axe", [366, 130], [230, 230], crop=[6.0, 1.0, 15.0, 9.0], rot=8)]},
    {"name": "socket", "z": 2, "material": "iron",
     "pieces": [p("square", [326, 200], [46, 56], rot=-52)]},
    {"name": "wrap", "z": 3, "material": "leather",
     "pieces": [p("square", [272, 274], [76, 40], rot=-52)]},
    iron_tarnish("blade", ((380, 120, 100, 80),)),
    iron_tarnish("hook", ((400, 180, 90, 80),)),
], "20 glaive. A curved knife blade and a back hook on one haft, both socketed. Meant to hook a man off his horse and open him."))

# 21 sickle
ITEMS.append(("eq_w21_sickle", [
    {"name": "blade", "z": 0, "material": "iron",
     "pieces": [p("hook", [230, 226], [330, 330], crop=[2.5, 5.0, 13.0, 15.0], rot=18)]},
    edge_hilite("edge", [222, 300], [20, 150], 108, "blade", "worn", 0.6),
    {"name": "haft", "z": 3, "material": "wood",
     "pieces": [p("square", [330, 372], [200, 30], rot=42),
                p("circle", [404, 416], [30, 30])]},
    {"name": "tang", "z": 2, "material": "iron",
     "pieces": [p("square", [286, 316], [70, 26], rot=42)]},
    {"name": "binding", "z": 4, "material": "bronze",
     "pieces": [p("square", [302, 350], [40, 44], rot=42)]},
    iron_tarnish("blade", ((230, 230, 170, 150),)),
], "21 sickle. A reaping hook with the handle split and bound. The inner curve is still bright from work."))

# 22 great scythe
ITEMS.append(("eq_w22_great_scythe", [
    {"name": "snath", "z": 0, "material": "wood",
     "pieces": [p("square", [352, 320], [340, 30], rot=52),
                p("square", [412, 262], [160, 26], rot=18)]},
    {"name": "blade", "z": 1, "material": "iron",
     "pieces": [p("hook", [210, 200], [400, 400], crop=[2.5, 5.0, 13.0, 15.0], rot=-16),
                p("triangle", [128, 306], [64, 84], rot=200)]},
    edge_hilite("edge", [176, 272], [22, 260], 122, "blade", "worn", 0.55),
    {"name": "brackets", "z": 2, "material": "iron",
     "pieces": [p("square", [270, 348], [72, 40], rot=52),
                p("square", [288, 326], [52, 30], rot=52)]},
    iron_tarnish("blade", ((200, 200, 200, 180),)),
    stain([p("cloud", [352, 320], [140, 70])], "grime", 0.35, clip="snath", z=9.1),
], "22 great scythe. A two-handed snath with a long curved blade set almost flat. The lower horn is bent inward where somebody tried to make it a spear."))

# 23 iron flail
ITEMS.append(("eq_w23_iron_flail", [
    {"name": "handle", "z": 0, "material": "wood",
     "pieces": [p("square", [146, 372], [150, 34], rot=-45)]},
    {"name": "chain", "z": 1, "kind": "flat", "material": "iron",
     "pieces": [p("link", [246, 276], [64, 64], rot=45,
                  repeat={"line": [[198, 324], [286, 240]], "count": 3})]},
    {"name": "ball", "z": 2, "material": "iron",
     "pieces": [p("circle", [318, 208], [150, 150]),
                p("square", [318, 208], [86, 86], rot=30)]},
    {"name": "spikes", "z": 2.5, "material": "iron",
     "pieces": [p("triangle", [318, 130], [40, 56],
                  repeat={"ellipse": [318, 208, 74, 74], "count": 7, "orient": True})]},
    iron_tarnish("ball", ((330, 200, 130, 120),)),
    iron_tarnish("chain", ((250, 200, 70, 140),)),
], "23 iron flail. Short handle, four links, a studded ball the size of a fist. The chain is bent closed on one link so it can be pocketed."))

# 24 short bow
ITEMS.append(("eq_w24_short_bow", [
    {"name": "limb", "z": 0, "material": "wood",
     "pieces": [p("bow_and_arrow", [248, 256], [380, 400], crop=[1.5, 0.5, 14.0, 15.5])]},
    {"name": "string", "z": 1, "kind": "flat", "material": "leather",
     "line": False, "clip_to": "limb",
     "pieces": [p("square", [134, 256], [7, 300])]},
    {"name": "grip", "z": 3, "material": "leather",
     "pieces": [p("square", [352, 232], [34, 92]),
                p("square", [352, 280], [24, 34])]},
    {"name": "arrow", "z": 2, "material": "wood",
     "pieces": [p("square", [248, 256], [330, 11], rot=-42)]},
    {"name": "arrowhead", "z": 2, "material": "iron",
     "pieces": [p("triangle", [378, 134], [58, 58], rot=135)]},
    {"name": "fletch", "z": 2, "kind": "flat", "material": "cloth_wine", "opacity": 0.85,
     "line": False,
     "pieces": [p("triangle", [126, 372], [50, 60], rot=45)]},
    stain([p("cloud", [300, 250], [90, 200])], "grime", 0.3, clip="limb", z=9.1),
], "24 short bow. Horn-and-yew recurved in miniature, string gone slack and re-waxed. Child's height, adult's draw weight."))

# 25 longbow
ITEMS.append(("eq_w25_longbow", [
    {"name": "limb", "z": 0, "material": "wood",
     "pieces": [p("bow_and_arrow", [236, 256], [400, 460], crop=[1.5, 0.5, 14.0, 15.5])]},
    {"name": "string", "z": 1, "kind": "flat", "material": "leather",
     "line": False, "clip_to": "limb",
     "pieces": [p("square", [110, 256], [7, 380])]},
    {"name": "grip", "z": 3, "material": "leather",
     "pieces": [p("square", [352, 226], [38, 140]),
                p("square", [352, 300], [26, 40])]},
    {"name": "arrow", "z": 2, "material": "wood",
     "pieces": [p("square", [236, 256], [360, 12], rot=-42)]},
    {"name": "arrowhead", "z": 2, "material": "iron",
     "pieces": [p("triangle", [382, 122], [62, 62], rot=135)]},
    {"name": "fletch", "z": 2, "kind": "flat", "material": "cloth_wine", "opacity": 0.85,
     "line": False,
     "pieces": [p("triangle", [102, 388], [54, 64], rot=45)]},
    stain([p("cloud", [300, 250], [80, 260])], "grime", 0.3, clip="limb", z=9.1),
], "25 longbow. Two metres of yew, wrapped grip, iron nocks. The belly has been scraped and re-oiled so often it is flat."))

# 26 crossbow
ITEMS.append(("eq_w26_crossbow", [
    {"name": "stock", "z": 0, "material": "wood",
     "pieces": [p("square", [250, 290], [380, 52], rot=8),
                p("square", [140, 314], [80, 92], rot=8)]},
    {"name": "prod", "z": 1, "material": "iron",
     "pieces": [p("bow_and_arrow", [232, 176], [360, 240], crop=[1.5, 0.5, 14.0, 15.5], rot=90)]},
    {"name": "string", "z": 2, "kind": "flat", "material": "leather", "line": False,
     "pieces": [p("square", [356, 176], [7, 210])]},
    {"name": "nut", "z": 3, "material": "iron",
     "pieces": [p("square", [378, 176], [26, 46]),
                p("circle", [366, 176], [20, 20])]},
    {"name": "trigger", "z": 3, "material": "iron",
     "pieces": [p("square", [286, 288], [26, 50], rot=22),
                p("circle", [282, 274], [24, 24])]},
    {"name": "grip", "z": 3, "material": "leather",
     "pieces": [p("square", [140, 314], [56, 96], rot=8)]},
    iron_tarnish("prod", ((240, 176, 200, 90),)),
], "26 crossbow. Boxy tiller, a prod bent slightly forward, string on a nut. Made to be carried loaded, which is why the string is not right."))

# 27 arrow bundle
ITEMS.append(("eq_w27_arrow_bundle", [
    {"name": "shafts", "z": 0, "material": "wood",
     "pieces": [p("arrow_projectile", [246, 268], [300, 300]),
                p("arrow_projectile", [280, 236], [290, 290], rot=-4),
                p("arrow_projectile", [216, 300], [290, 290], rot=5)]},
    {"name": "points", "z": 1, "material": "iron",
     "pieces": [p("arrow_projectile", [330, 168], [110, 110], crop=[8.0, 1.0, 15.0, 8.0]),
                p("arrow_projectile", [364, 136], [108, 108], crop=[8.0, 1.0, 15.0, 8.0], rot=-4),
                p("arrow_projectile", [300, 200], [108, 108], crop=[8.0, 1.0, 15.0, 8.0], rot=5)]},
    {"name": "fletch", "z": 1, "kind": "flat", "material": "cloth_wine", "opacity": 0.85,
     "line": False, "clip_to": "shafts",
     "pieces": [p("triangle", [150, 366], [56, 66], rot=45,
                  repeat={"points": [[150, 366, 0], [182, 336, -4], [120, 396, 5]]})]},
    {"name": "tie", "z": 2, "material": "leather",
     "pieces": [p("square", [200, 320], [40, 130], rot=38),
                p("square", [214, 306], [28, 100], rot=38)]},
    stain([p("cloud", [240, 280], [140, 100])], "grime", 0.3, clip="shafts", z=9.1),
], "27 arrow bundle. Eleven shafts tied in thirds, three of them with bodkins, one with a bone head somebody sharpened wrong."))

# 28 flintlock pistol
ITEMS.append(("eq_w28_flintlock_pistol", [
    {"name": "lock", "z": 0, "material": "iron",
     "pieces": [p("flintlock", [256, 262], [410, 410])]},
    {"name": "grip", "z": 1, "material": "wood",
     "pieces": [p("square", [148, 400], [76, 30], rot=22)]},
    {"name": "grip_cuts", "z": 2, "kind": "flat", "material": "stone_cap",
     "opacity": 0.45, "line": False, "clip_to": "grip",
     "pieces": [p("square", [148, 400], [64, 12], rot=22),
                p("square", [154, 392], [64, 12], rot=22)]},
    {"name": "guard", "z": 2, "kind": "flat", "material": "worn", "opacity": 0.5,
     "line": False,
     "pieces": [p("ring", [222, 386], [86, 62], rot=-14)]},
    iron_tarnish("lock", ((340, 220, 170, 120), (200, 320, 120, 100))),
    soot("lock", ((300, 270, 190, 140),)),
], "28 flintlock pistol. Small bore, worn frizzen, checkered grip rubbed smooth. It has misfired more than it has fired."))

# 29 flintlock rifle
ITEMS.append(("eq_w29_flintlock_rifle", [
    {"name": "lock", "z": 0, "material": "iron",
     "pieces": [p("flintlock", [196, 214], [290, 290])]},
    {"name": "barrel", "z": 1, "material": "iron",
     "pieces": [p("square", [336, 178], [300, 22], rot=-14)]},
    {"name": "muzzle", "z": 1, "material": "iron",
     "pieces": [p("square", [478, 144], [26, 34], rot=-14)]},
    {"name": "stock", "z": 2, "material": "wood",
     "pieces": [p("square", [268, 236], [420, 56], rot=-12),
                p("square", [136, 300], [120, 44], rot=32)]},
    {"name": "butt", "z": 2, "material": "iron",
     "pieces": [p("square", [70, 322], [26, 70], rot=32)]},
    iron_tarnish("lock", ((210, 190, 120, 100),)),
    iron_tarnish("barrel", ((350, 176, 220, 60),)),
    damp_stains("stock", ((300, 220, 260, 90),)),
], "29 flintlock rifle. Long barrel on a wrist stock, the butt plate dented. Shots it took are still in the wood."))

# 30 wooden staff
ITEMS.append(("eq_w30_wooden_staff", [
    {"name": "staff", "z": 0, "material": "wood",
     "pieces": [p("square", [256, 256], [440, 40], rot=8)]},
    {"name": "knots", "z": 1, "kind": "flat", "material": "wood", "opacity": 0.7,
     "line": {"width": 0.7}, "clip_to": "staff",
     "pieces": [p("circle", [200, 226], [34, 26], rot=8),
                p("circle", [330, 292], [28, 22], rot=8)]},
    {"name": "thong", "z": 2, "material": "leather",
     "pieces": [p("square", [256, 236], [54, 76], rot=8),
                p("square", [256, 300], [40, 40], rot=8)]},
    {"name": "caps", "z": 2, "material": "bronze",
     "pieces": [p("square", [42, 230], [26, 46], rot=8),
                p("square", [470, 282], [26, 46], rot=8)]},
    stain([p("cloud", [256, 256], [200, 70])], "grime", 0.35, clip="staff", z=9.1),
], "30 wooden staff. A straight hazel rod with bronze ferrules, a leather thong wound at the middle. Knobby, unremarkable, heavy."))

# 31 skull staff
ITEMS.append(("eq_w31_skull_staff", [
    {"name": "staff", "z": 0, "material": "wood",
     "pieces": [p("square", [230, 330], [400, 36], rot=-16)]},
    {"name": "socket", "z": 1, "material": "iron",
     "pieces": [p("square", [330, 240], [46, 60], rot=-16)]},
    {"name": "skull", "z": 2, "material": "bone",
     "pieces": [p("skull", [386, 164], [230, 230])]},
    {"name": "jaw", "z": 2.5, "material": "bone",
     "pieces": [p("square", [386, 258], [110, 30], rot=-6),
                p("square", [386, 252], [96, 10], rot=-6)]},
    {"name": "eye_sockets", "z": 3, "kind": "flat", "material": "void",
     "line": False, "clip_to": "skull",
     "pieces": [p("circle", [356, 148], [40, 44]),
                p("circle", [416, 148], [40, 44]),
                p("triangle", [386, 198], [26, 30], rot=180)]},
    stain([p("cloud", [230, 330], [180, 80])], "grime", 0.35, clip="staff", z=9.1),
    stain([p("droplet", [400, 130], [30, 44])], "grime", 0.4, clip="skull", z=9.1),
], "31 skull staff. A child's skull socketed on a rod. The jaw is wired shut. Something small and old was killed for this."))

# 32 gem staff
ITEMS.append(("eq_w32_gem_staff", [
    {"name": "wand", "z": 0, "material": "wood",
     "pieces": [p("magic_wand", [250, 258], [400, 400], crop=[1.0, 2.0, 12.0, 15.0])]},
    {"name": "gem", "z": 1, "material": "glass", "emit": 0.3,
     "glow": {"radius": 6, "opacity": 0.45, "color": "flame_glow"},
     "pieces": [p("gem", [336, 138], [130, 130])]},
    {"name": "wrap", "z": 2, "material": "leather",
     "pieces": [p("square", [190, 330], [60, 90], rot=-45),
                p("square", [212, 308], [44, 62], rot=-45)]},
    {"name": "claw", "z": 2, "material": "bronze",
     "pieces": [p("triangle", [300, 178], [40, 50], rot=-30),
                p("triangle", [336, 190], [34, 42], rot=-20)]},
    patina([p("metaballs", [300, 200], [110, 80]), p("sponge", [230, 300], [90, 70])],
           "rust", 0.55, clip="blade"),
], "32 gem staff. Split-ash wand with a bronze claw holding a green glass stone. The stone is warm and it is not supposed to be."))

# 33 spellbook
ITEMS.append(("eq_w33_spellbook", [
    {"name": "cover", "z": 0, "material": "leather",
     "pieces": [p("book", [264, 256], [356, 356])]},
    {"name": "spine", "z": 2, "material": "cloth_wine",
     "pieces": [p("square", [136, 256], [44, 300])]},
    {"name": "label", "z": 3, "kind": "flat", "material": "paper_mark", "opacity": 0.5,
     "line": False, "clip_to": "cover",
     "pieces": [p("square", [272, 152], [150, 34])]},
    {"name": "corners", "z": 3, "material": "bronze",
     "pieces": [p("square", [112, 112], [72, 62], rot=8), p("square", [112, 400], [72, 62], rot=-8),
                p("square", [416, 112], [72, 62], rot=-8), p("square", [416, 400], [72, 62], rot=8)]},
    {"name": "clasp", "z": 3, "material": "bronze",
     "pieces": [p("square", [186, 330], [72, 26]),
                p("circle", [200, 330], [30, 30])]},
    damp_stains("cover", ((310, 210, 200, 200),)),
], "33 spellbook. Faded leather cover, wine cloth spine, four bronze corners, a clasp that no longer catches. The label has been scraped off."))

# 34 cursed book
ITEMS.append(("eq_w34_cursed_book", [
    {"name": "cover", "z": 0, "material": "leather",
     "pieces": [p("book", [264, 256], [356, 356], rot=-6)]},
    {"name": "eye", "z": 1, "kind": "flat", "material": "void", "opacity": 0.92,
     "line": False, "clip_to": "cover",
     "pieces": [p("eye", [300, 258], [190, 150], rot=-6),
                p("circle", [300, 258], [64, 64])]},
    {"name": "iris", "z": 1.5, "kind": "flat", "material": "ember", "opacity": 0.8,
     "line": False, "clip_to": "cover",
     "pieces": [p("circle", [300, 258], [40, 40])]},
    {"name": "clasps", "z": 2, "material": "iron",
     "pieces": [p("square", [168, 336], [62, 22], rot=-6),
                p("square", [168, 196], [62, 22], rot=-6)]},
    {"name": "pages", "z": 2, "kind": "flat", "material": "paper", "opacity": 0.9,
     "line": False, "clip_to": "cover",
     "pieces": [p("square", [400, 256], [20, 250], rot=-6)]},
    soot("cover", ((310, 250, 240, 240),)),
    stain([p("droplet", [240, 330], [30, 46])], "soot", 0.5, clip="cover", z=9.4),
], "34 cursed book. An eye pressed into the cover, still faintly lit. Somebody read it in the dark and the dark read back."))

# 35 relic cross
ITEMS.append(("eq_w35_relic_cross", [
    {"name": "upright", "z": 0, "material": "bronze",
     "pieces": [p("square", [256, 250], [76, 400])]},
    {"name": "arms", "z": 0, "material": "bronze",
     "pieces": [p("square", [256, 178], [280, 70])]},
    {"name": "boss", "z": 1, "material": "iron",
     "pieces": [p("circle", [256, 178], [96, 96]),
                p("square", [256, 178], [48, 48], rot=45)]},
    {"name": "skull_relic", "z": 2, "material": "bone",
     "pieces": [p("skull", [256, 178], [82, 82])]},
    {"name": "eye_slots", "z": 3, "kind": "flat", "material": "void", "line": False,
     "clip_to": "skull_relic",
     "pieces": [p("circle", [244, 168], [16, 18]), p("circle", [268, 168], [16, 18])]},
    {"name": "feet", "z": 1, "material": "bronze",
     "pieces": [p("square", [256, 434], [110, 34], rot=2)]},
    patina([p("metaballs", [256, 250], [180, 260]), p("sponge", [230, 330], [120, 120])],
           "rust", 0.5),
    stain([p("droplet", [256, 300], [24, 40])], "grime", 0.35, z=9.1),
], "35 relic cross. Standing bronze cross with a small skull set in the crossing. The relic is a jaw, not a saint. Patina runs down from it in green-black streaks."))

# 36 swinging censer
ITEMS.append(("eq_w36_swinging_censer", [
    {"name": "chain", "z": 0, "kind": "flat", "material": "iron",
     "pieces": [p("link", [256, 96], [56, 56], rot=45,
                  repeat={"line": [[256, 56], [256, 200]], "count": 4})]},
    {"name": "bowl", "z": 1, "material": "bronze",
     "pieces": [p("circle", [256, 330], [320, 300]),
                p("square", [256, 452], [290, 30], rot=2)]},
    {"name": "lid", "z": 2, "material": "bronze",
     "pieces": [p("square", [256, 212], [230, 30], rot=2),
                p("triangle", [256, 172], [120, 56], rot=180)]},
    {"name": "vents", "z": 3, "kind": "flat", "material": "void", "line": False,
     "clip_to": "bowl",
     "pieces": [p("square", [256, 330], [13, 140], rot=24),
                p("square", [256, 330], [13, 140], rot=-24),
                p("square", [256, 330], [13, 140])]},
    {"name": "coals", "z": 2.5, "kind": "flat", "material": "ember", "emit": 0.5,
     "glow": {"radius": 8, "opacity": 0.5, "color": "flame_glow"},
     "line": False, "clip_to": "bowl",
     "pieces": [p("circle", [206, 322], [72, 44]), p("circle", [302, 336], [60, 38])]},
    patina([p("metaballs", [256, 350], [280, 200]), p("cloud", [256, 240], [220, 90])],
           "rust", 0.45),
], "36 swinging censer. A bronze pot on four links, lid vented, coals still warm inside. It swings when the room is empty and nobody is holding it."))

if __name__ == "__main__":
    write_all(ITEMS)
