import json
import math
import os
import sys

OUT = sys.argv[1] if len(sys.argv) > 1 else "."
HORIZON = 243.0


def r1(v):
    return round(v, 1)


def pts(seq):
    return [[r1(x), r1(y)] for x, y in seq]


def ogive(cx, base_y, a, spring_y, radius_k=1.35, steps=7):
    r = radius_k * a
    h = math.sqrt(max(0.0, 2.0 * a * r - a * a))
    left = [(cx - a, base_y), (cx - a, spring_y)]
    ccx = cx - a + r
    a_end = math.asin(h / r)
    for i in range(1, steps + 1):
        t = a_end * i / steps
        left.append((ccx - r * math.cos(t), spring_y - r * math.sin(t)))
    right = [(2 * cx - x, y) for x, y in reversed(left)]
    return left + right[1:]


def ellipse(cx, cy, rx, ry, n=24, a0=0.0, a1=math.tau):
    out = []
    for i in range(n):
        t = a0 + (a1 - a0) * i / n
        out.append((cx + rx * math.cos(t), cy + ry * math.sin(t)))
    return out


def flower(cx, cy, r_out, r_in, petals=8):
    out = []
    for i in range(petals * 2):
        t = math.tau * i / (petals * 2) - math.pi / 2
        rr = r_out if i % 2 == 0 else r_in
        out.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
    return out


def write(name, data):
    path = os.path.join(OUT, name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")


def dome():
    cam_z = -0.45
    eye = 0.035
    f = 430.0
    cx = 480.0

    def proj(theta_d, phi_d):
        t = math.radians(theta_d)
        p = math.radians(phi_d)
        x = math.cos(p) * math.sin(t)
        y = math.sin(p) - eye
        z = math.cos(p) * math.cos(t) - cam_z
        return (cx + f * x / z, HORIZON - f * y / z, z)

    thetas = [-84, -72, -60, -48, -36, -24, -12, 0, 12, 24, 36, 48, 60, 72, 84]
    phis = [0, 6, 15, 26, 39, 53]
    nodes = {}
    for i, p in enumerate(phis):
        for j, t in enumerate(thetas):
            nodes[(i, j)] = proj(t, p)

    def width(z, base):
        return base / z

    beams = []
    main = 7.2
    for j in range(len(thetas)):
        for i in range(len(phis) - 1):
            a = nodes[(i, j)]
            b = nodes[(i + 1, j)]
            beams.append([r1(a[0]), r1(a[1]), r1(b[0]), r1(b[1]), r1(width(a[2], main)), r1(width(b[2], main))])
    for i in range(1, len(phis)):
        for j in range(len(thetas) - 1):
            a = nodes[(i, j)]
            b = nodes[(i, j + 1)]
            beams.append([r1(a[0]), r1(a[1]), r1(b[0]), r1(b[1]), r1(width(a[2], main * 0.85)), r1(width(b[2], main * 0.85))])
    diag = []
    for i in range(1, len(phis) - 1):
        for j in range(len(thetas) - 1):
            if (i + j) % 2 == 0:
                a = nodes[(i, j)]
                b = nodes[(i + 1, j + 1)]
            else:
                a = nodes[(i, j + 1)]
                b = nodes[(i + 1, j)]
            diag.append([r1(a[0]), r1(a[1]), r1(b[0]), r1(b[1]), r1(width(a[2], main * 0.55)), r1(width(b[2], main * 0.55))])

    joints = []
    for i in range(1, len(phis)):
        for j in range(len(thetas)):
            n = nodes[(i, j)]
            joints.append([r1(n[0]), r1(n[1]), r1(width(n[2], main * 0.95))])

    panels = []
    pick = [(1, 3), (1, 10), (2, 5), (2, 8), (3, 2), (3, 7), (3, 11), (4, 5), (4, 9), (2, 12)]
    for i, j in pick:
        a = nodes[(i, j)]
        b = nodes[(i, j + 1)]
        c = nodes[(i + 1, j + 1)]
        d = nodes[(i + 1, j)]
        if (i + j) % 2 == 0:
            tri = [a, b, c]
        else:
            tri = [a, b, d]
        panels.append(pts([(q[0], q[1]) for q in tri]))

    base_top = []
    base_bot = []
    for k in range(-88, 89, 4):
        n = proj(k, 0)
        base_top.append((n[0], n[1] - 5.0 / n[2]))
        base_bot.append((n[0], n[1] + 9.0 / n[2]))
    base = pts(base_top + list(reversed(base_bot)))
    lip = []
    for k in range(-88, 89, 4):
        n = proj(k, 0)
        lip.append((n[0], n[1] - 5.0 / n[2]))
    lip_bot = [(x, y + 2.6) for x, y in reversed(lip)]

    layers = [
        {"role": "glass", "fill": p} for p in panels
    ]
    layers.append({"role": "rib_far", "beams": diag})
    layers.append({"role": "rib", "beams": beams})
    layers.append({"role": "rib_lit", "joints": joints})
    layers.append({"role": "wall_dark", "fill": base})
    layers.append({"role": "wall_lit", "fill": pts(lip + lip_bot)})
    return {"id": "str_dome_ribs", "kind": "dome", "breaks": "size", "layers": layers}


def cathedral():
    cx = 600.0
    base = 264.0
    layers = []
    nave = [(438, base), (438, 118), (cx, 30), (762, 118), (762, base)]
    layers.append({"role": "wall", "fill": pts(nave)})
    layers.append({"role": "wall_lit", "fill": pts([(438, 118), (cx, 30), (cx, 42), (452, 124)])})
    layers.append({"role": "wall_dark", "fill": pts([(cx, 30), (762, 118), (748, 124), (cx, 42)])})
    for side in (-1, 1):
        x0 = cx + side * 192.0
        xa = x0 - 30.0
        xb = x0 + 30.0
        tower = [(xa, base), (xa, 92), (x0, 12), (xb, 92), (xb, base)]
        layers.append({"role": "wall_lit" if side < 0 else "wall", "fill": pts(tower)})
        layers.append({"role": "wall_dark", "fill": pts([(xa, 92), (xb, 92), (xb, 100), (xa, 100)])})
        win = ogive(x0, 176.0, 11.0, 150.0, 1.4, 5)
        layers.append({"role": "opening", "fill": pts(win)})
        win2 = ogive(x0, 238.0, 13.0, 212.0, 1.4, 5)
        layers.append({"role": "opening", "fill": pts(win2)})
    roles = ["wall_dark", "wall_lit", "wall", "wall_lit", "opening"]
    a = 82.0
    spring = 168.0
    for k in range(5):
        layers.append({"role": roles[k], "fill": pts(ogive(cx, base, a, spring, 1.35, 8))})
        a -= 13.0
        spring += 13.0
    layers.append({"role": "trim", "fill": pts(flower(cx, 66.0, 17.0, 9.0, 8))})
    layers.append({"role": "opening", "fill": pts(ellipse(cx, 66.0, 5.5, 5.5, 12))})
    layers.append({"role": "wall_lit", "fill": pts([(500, base), (700, base), (708, base + 6), (492, base + 6)])})
    layers.append({"role": "wall_dark", "fill": pts([(492, base + 6), (708, base + 6), (716, base + 12), (484, base + 12)])})
    return {"id": "str_arch_cathedral", "kind": "arch", "breaks": "size", "layers": layers}


def canyon():
    layers = []
    left = [(-140, 350), (-140, -30), (150, -30), (138, 40), (176, 96), (150, 150), (196, 210), (182, 262), (230, 300), (210, 350)]
    right = [(1100, 350), (1100, -30), (812, -30), (826, 30), (786, 84), (812, 140), (770, 196), (790, 250), (744, 296), (760, 350)]
    layers.append({"role": "wall", "fill": pts(left)})
    layers.append({"role": "wall", "fill": pts(right)})
    layers.append({"role": "wall_lit", "fill": pts([(150, -30), (138, 40), (176, 96), (150, 150), (196, 210), (182, 262), (230, 300), (210, 350), (190, 350), (206, 302), (160, 262), (174, 210), (128, 150), (154, 96), (116, 40), (126, -30)])})
    layers.append({"role": "wall_dark", "fill": pts([(812, -30), (826, 30), (786, 84), (812, 140), (770, 196), (790, 250), (744, 296), (760, 350), (782, 350), (768, 298), (812, 250), (792, 196), (834, 140), (808, 84), (848, 30), (836, -30)])})
    grooves = []
    for x, y0, y1 in [(40, 20, 300), (78, 60, 320), (-20, 0, 280), (880, 30, 320), (920, 10, 300), (1000, 40, 330), (960, 70, 310)]:
        grooves.append([x, y0, x, y1, 7.0, 7.0])
    layers.append({"role": "wall_dark", "beams": grooves})
    arch = ogive(480.0, 252.0, 46.0, 214.0, 1.3, 7)
    inner = ogive(480.0, 252.0, 32.0, 222.0, 1.3, 7)
    layers.append({"role": "gold", "fill": pts(arch)})
    layers.append({"role": "sky_hole", "fill": pts(inner)})
    layers.append({"role": "sun_black", "fill": pts(ellipse(640.0, 96.0, 30.0, 30.0, 28))})
    rays = []
    for k in range(12):
        t = math.tau * k / 12 + 0.13
        x0 = 640 + 38 * math.cos(t)
        y0 = 96 + 38 * math.sin(t)
        x1 = 640 + 110 * math.cos(t)
        y1 = 96 + 110 * math.sin(t)
        rays.append([r1(x0), r1(y0), r1(x1), r1(y1), 7.0, 1.5])
    layers.append({"role": "sun_black", "beams": rays})
    return {"id": "str_canyon_walls", "kind": "canyon", "breaks": "size", "layers": layers}


def signpost():
    layers = []
    layers.append({"role": "ink", "fill": pts([(-5, 0), (-5, -150), (5, -150), (5, 0)])})
    layers.append({"role": "ink", "fill": pts([(-8, -150), (0, -160), (8, -150)])})
    left_board = [(-74, -118), (-54, -134), (40, -134), (40, -102), (-54, -102)]
    right_board = [(76, -80), (56, -96), (-40, -96), (-40, -64), (56, -64)]
    layers.append({"role": "trim", "fill": pts(left_board)})
    layers.append({"role": "trim", "fill": pts(right_board)})
    layers.append({"role": "trim_dark", "fill": pts([(-54, -108), (40, -108), (40, -102), (-54, -102)])})
    layers.append({"role": "trim_dark", "fill": pts([(-40, -70), (56, -70), (56, -64), (-40, -64)])})
    layers.append({"role": "ink", "joints": [[-44, -118, 2.6], [30, -118, 2.6], [-30, -80, 2.6], [46, -80, 2.6]]})
    return {"id": "prop_signpost", "kind": "scenery", "layers": layers}


def well():
    layers = []
    layers.append({"role": "stone", "fill": pts([(-36, -40), (-36, -4), (-24, 3), (0, 6), (24, 3), (36, -4), (36, -40)])})
    layers.append({"role": "stone_lit", "fill": pts([(-36, -40), (-36, -4), (-28, 1), (-26, -40)])})
    for yy in [-30, -18, -6]:
        layers.append({"role": "stone_dark", "beams": [[-36, yy, 36, yy + 1, 2.2, 2.2]]})
    layers.append({"role": "stone_lit", "fill": pts(ellipse(0, -41, 40, 10, 24))})
    layers.append({"role": "hole", "fill": pts(ellipse(0, -41, 29, 6, 20))})
    layers.append({"role": "wood", "fill": pts([(-33, -44), (-33, -104), (-26, -104), (-26, -44)])})
    layers.append({"role": "wood", "fill": pts([(26, -44), (26, -104), (33, -104), (33, -44)])})
    layers.append({"role": "trim", "fill": pts([(-50, -98), (0, -128), (50, -98), (44, -94), (0, -118), (-44, -94)])})
    layers.append({"role": "wood", "beams": [[-30, -100, 30, -100, 3.0, 3.0]]})
    layers.append({"role": "ink", "beams": [[0, -100, 0, -74, 1.4, 1.4]]})
    layers.append({"role": "wood", "fill": pts([(-8, -74), (8, -74), (6, -60), (-6, -60)])})
    return {"id": "prop_well", "kind": "mine", "yields": {"mat_ash": [2, 4]}, "ticks": 30, "layers": layers}


def vat():
    layers = []
    outline = []
    for i in range(0, 13):
        t = i / 12.0
        y = -t * 78.0
        bulge = 30.0 + 7.0 * math.sin(math.pi * t)
        outline.append((-bulge, y))
    right = [(-x, y) for x, y in reversed(outline)]
    layers.append({"role": "clay", "fill": pts(outline + right)})
    lit = []
    for i in range(1, 12):
        t = i / 12.0
        y = -t * 78.0
        bulge = 30.0 + 7.0 * math.sin(math.pi * t)
        lit.append((-bulge + 5.0, y))
    lit_in = [(x + 9.0, y) for x, y in reversed(lit)]
    layers.append({"role": "clay_lit", "fill": pts(lit + lit_in)})
    for t in (0.18, 0.5, 0.82):
        y = -t * 78.0
        bulge = 30.0 + 7.0 * math.sin(math.pi * t)
        layers.append({"role": "ink", "beams": [[r1(-bulge), r1(y), r1(bulge), r1(y), 3.2, 3.2]]})
    layers.append({"role": "clay_dark", "fill": pts(ellipse(0, -78, 30, 7, 20))})
    layers.append({"role": "ink", "fill": pts(ellipse(0, -79, 20, 4, 16))})
    return {"id": "prop_vat", "kind": "scenery", "layers": layers}


def deadtree():
    layers = []
    trunk = [(-5, 0), (-4, -34), (-16, -58), (-13, -60), (-2, -42), (-1, -70), (-10, -92), (-7, -94), (2, -76), (8, -96), (11, -94), (5, -70), (6, -46), (20, -64), (22, -61), (7, -36), (6, 0)]
    layers.append({"role": "ink", "fill": pts(trunk)})
    return {"id": "prop_deadtree", "kind": "scenery", "layers": layers}


def pillar():
    layers = []
    layers.append({"role": "stone", "fill": pts([(-17, -86), (-17, -2)] + [(-12, 3), (0, 5), (12, 3)] + [(17, -2), (17, -86)])})
    layers.append({"role": "stone_lit", "fill": pts([(-17, -86), (-17, -2), (-10, 2), (-10, -86)])})
    layers.append({"role": "stone_dark", "fill": pts([(10, -86), (10, 2), (17, -2), (17, -86)])})
    layers.append({"role": "stone_lit", "fill": pts(ellipse(0, -86, 17, 5, 20))})
    layers.append({"role": "hole", "fill": pts(ellipse(0, -86, 11, 3, 16))})
    layers.append({"role": "stone_dark", "beams": [[-6, -60, 2, -44, 2.0, 1.2], [2, -44, -3, -30, 1.2, 0.8]]})
    return {"id": "prop_pillar_hollow", "kind": "scenery", "layers": layers}


def rubble():
    layers = []
    layers.append({"role": "stone_dark", "fill": pts([(-34, 0), (-30, -16), (-14, -24), (0, -18), (4, 0)])})
    layers.append({"role": "stone", "fill": pts([(-8, 0), (-6, -22), (10, -34), (26, -26), (32, 0)])})
    layers.append({"role": "stone_lit", "fill": pts([(-6, -22), (10, -34), (14, -30), (0, -20)])})
    layers.append({"role": "stone_dark", "fill": pts([(20, 0), (24, -10), (36, -12), (40, 0)])})
    return {"id": "prop_rubble", "kind": "scenery", "layers": layers}


def train():
    layers = []
    layers.append({"role": "clay", "fill": pts([(-120, -18), (-120, -52), (-40, -52), (-40, -18)])})
    layers.append({"role": "clay", "fill": pts([(-32, -18), (-32, -52), (48, -52), (48, -18)])})
    layers.append({"role": "trim", "fill": pts([(56, -18), (56, -46), (96, -46), (112, -30), (112, -18)])})
    layers.append({"role": "trim", "fill": pts([(64, -46), (64, -66), (76, -66), (76, -46)])})
    for x0 in (-112, -84, -56, -24, 4, 32):
        layers.append({"role": "sky_hole", "fill": pts([(x0, -46), (x0, -32), (x0 + 16, -32), (x0 + 16, -46)])})
    wheels = []
    for x in (-104, -60, -16, 32, 72, 100):
        wheels.append([x, -14, 8.0])
    layers.append({"role": "ink", "joints": wheels})
    layers.append({"role": "ink", "beams": [[-40, -30, -32, -30, 3.0, 3.0], [48, -30, 56, -30, 3.0, 3.0]]})
    return {"id": "prop_train", "kind": "scenery", "layers": layers}


write("structure/str_dome_ribs.json", dome())
write("structure/str_arch_cathedral.json", cathedral())
write("structure/str_canyon_walls.json", canyon())
write("prop/prop_signpost.json", signpost())
write("prop/prop_well.json", well())
write("prop/prop_vat.json", vat())
write("prop/prop_deadtree.json", deadtree())
write("prop/prop_pillar_hollow.json", pillar())
write("prop/prop_rubble.json", rubble())
write("prop/prop_train.json", train())
print("ok")
