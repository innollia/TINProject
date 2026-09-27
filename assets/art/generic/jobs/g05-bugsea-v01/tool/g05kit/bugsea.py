"""g05-bugsea-v01: bugs, arachnids and sea creatures (front-view battlers)."""

from __future__ import annotations

import math

from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import arch_leg, bat_wing, bones_limb, claw_hand, pincer, spikes_on, wing_at


# ---------------------------------------------------------------- A: spider
@creature("spider", "A")
def spider():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("spider", (W, H), (cx, gy), seed=901,
                 note="Giant spider, front view. Glossy black-violet spider with a bulbous abdomen marked with a wine "
                      "hourglass, eight arched hairy legs, a cluster of red eyes and hooked fangs. attack = front legs "
                      "reared high, fangs spread, body lunging; hit = legs buckled, body tilted, eyes dimmed.")
    c.shadow(cx, gy - 2, 300, 36)
    c.add("abdomen", "chitin_black", 1, [E(cx, 214, 170, 150)], tags=("body",))
    c.add("mark", "cloth_wine", 1.1, [P("hourglass", cx, 204, 44, 60)], tags=("body",), clip_to="abdomen")
    c.add("hair", "fur_dark", 1.05, [E(cx, 170, 150, 60)], tags=("body",), clip_to="abdomen", line=False, opacity=0.5)
    legs = {"l": [], "r": []}
    for s, k in (("l", -1), ("r", 1)):
        knees = [(70, 196), (106, 170), (132, 182), (146, 210)]
        feet = [(62, gy - 4), (122, gy - 10), (152, gy - 18), (166, gy - 30)]
        for i in range(4):
            root = (cx + k * (38 + i * 6), 268 + i * 4)
            knee = (cx + k * knees[i][0], knees[i][1])
            foot = (cx + k * feet[i][0], feet[i][1])
            tags = ("legs", f"leg_{s}{i}") + (("front",) if i == 0 else ())
            arch_leg(c, f"leg_{s}{i}", root, knee, foot, 20 - i, 7, "chitin_black", 2 - i * 0.1, tags, tip_mat="claw")
            legs[s].append(root)
    for s, k in (("l", -1), ("r", 1)):
        arch_leg(c, f"leg_{s}_atk", (cx + k * 38, 268), (cx + k * 86, 160), (cx + k * 64, 104), 20, 8, "chitin_black", 3.5, ("atk",),
                 hidden=True, tip_mat="claw")
    c.add("thorax", "chitin_black", 3, [E(cx, 276, 110, 88)], tags=("body", "head"))
    c.glow("eyes", "glow_red", 3.3, [E(cx - 16, 262, 18, 18), E(cx + 16, 262, 18, 18), E(cx - 36, 250, 9, 9), E(cx + 36, 250, 9, 9),
                                     E(cx - 8, 244, 8, 8), E(cx + 8, 244, 8, 8), E(cx - 26, 278, 7, 7), E(cx + 26, 278, 7, 7)],
           tags=("head", "eyes"), color="glow_red_c", strength=0.9, opacity=0.5)
    c.flat("eyes_hit", "soot", 3.3, [E(cx - 16, 264, 16, 5), E(cx + 16, 264, 16, 5)], tags=("head", "eyes_hit"), hidden=True)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"fang_{s}", "chitin_black", 3.4, [E(cx + k * 16, 306, 22, 26)], tags=("head", "fangs", f"fang_{s}"), pivot=[cx + k * 14, 300])
        c.add(f"fang_{s}_tip", "claw", 3.5, [P("moon", cx + k * 12, 326, 18, 18, rot=135 if k < 0 else -135, **({"flip": "x"} if k > 0 else {}))],
              tags=("head", "fangs", f"fang_{s}"), pivot=[cx + k * 14, 300], line={"width": 0.6, "heavy": 0.5})
    std_frames(
        c,
        attack_move={"fang_l": {"rot": 16, "pivot": [cx - 14, 300]}, "fang_r": {"rot": -16, "pivot": [cx + 14, 300]},
                     "all": c.whole(s=1.04, dy=4)},
        attack_show=("atk",), attack_hide=("front",),
        hit_move={"legs": {"sy": 0.86, "pivot": [cx, gy]}, "all": c.whole(rot=6, dy=6, s=0.95)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="거대 거미", size="사람")
    return c


# ---------------------------------------------------------------- A: scorpion
@creature("scorpion", "A")
def scorpion():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("scorpion", (W, H), (cx, gy), seed=902,
                 note="Giant scorpion, front view. Amber-brown armoured scorpion: segmented tail arching high over its "
                      "back with a dark stinger aimed at the viewer, two heavy pincers forward, eight short legs, small "
                      "glowing eyes on the head plate. attack = stinger stabs down and forward, pincers open wide; hit = "
                      "tail and pincers recoil, body tilted.")
    c.shadow(cx, gy - 2, 300, 34)
    tail_c = [(cx, 290), (cx + 40, 170), (cx + 10, 70), (cx - 16, 112)]
    c.add("tail", "chitin_amber", 1, tube(tail_c, 46, 22, n=16), tags=("tail",))
    from .kit import along
    c.flat("tail_bands", "chitin_rust", 1.05, along(tail_c, 6, lambda x, y, ang, i, t: P("circle", x, y, 44 - 20 * t, 7, ang + 90), 0.1, 0.9),
           tags=("tail",), clip_to="tail", opacity=0.6)
    c.add("stinger", "claw", 1.2, [E(cx - 16, 112, 30, 30), P("droplet", cx - 18, 136, 16, 36, flip="y", rot=10)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        for i in range(4):
            root = (cx + k * (40 + i * 8), 300 + i * 6)
            knee = (cx + k * (84 + i * 16), 280 + i * 8)
            foot = (cx + k * (100 + i * 20), gy - 10)
            arch_leg(c, f"leg_{s}{i}", root, knee, foot, 14, 6, "chitin_amber", 1.5 - i * 0.05, ("legs",), tip_mat="claw")
    c.add("body", "chitin_amber", 2, [E(cx, 300, 150, 96)], tags=("body",))
    c.flat("plates", "chitin_rust", 2.1, [smile(cx, 290 + i * 18, 120 - i * 16, 8, depth=0.6)[0] for i in range(3)], tags=("body",),
           clip_to="body", opacity=0.5)
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 50, 296)
        arms[s] = list(sh)
        c.add(f"arm_{s}", "chitin_amber", 3, tube([sh, (cx + k * 100, 286), (cx + k * 100, 304)], 26, 20, n=6, cap=True), tags=(f"arm_{s}",), pivot=list(sh))
        c.add(f"claw_{s}", "chitin_amber", 3.2, pincer(cx + k * 96, 312, 88, 72 if k < 0 else 108, 0.3), tags=(f"arm_{s}", "claws"),
              pivot=list(sh))
        c.add(f"claw_{s}_atk", "chitin_amber", 3.2, pincer(cx + k * 104, 304, 92, 64 if k < 0 else 116, 0.62), tags=("atk",), hidden=True)
    c.add("head", "chitin_amber", 4, [E(cx, 306, 70, 44)], tags=("head",))
    c.glow("eyes", "glow_green", 4.2, [E(cx - 10, 296, 8, 7), E(cx + 10, 296, 8, 7)], tags=("head", "eyes"), color="glow_green_c",
           strength=0.8, opacity=0.4)
    c.flat("eyes_hit", "soot", 4.2, [E(cx - 10, 297, 9, 3), E(cx + 10, 297, 9, 3)], tags=("head", "eyes_hit"), hidden=True)
    c.add("mandibles", "claw", 4.3, [P("moon", cx - 8, 326, 12, 12, rot=135), P("moon", cx + 8, 326, 12, 12, rot=-135, flip="x")], tags=("head",))
    std_frames(
        c,
        attack_move={"tail": {"rot": -22, "sy": 0.86, "dy": 30, "pivot": [cx, 290]}, "all": c.whole(s=1.04, dy=4)},
        attack_show=("atk",), attack_hide=("claws",),
        hit_move={"tail": {"rot": 12, "pivot": [cx, 290]}, "arm_l": {"rot": 10, "pivot": arms["l"]}, "arm_r": {"rot": -10, "pivot": arms["r"]},
                  "all": c.whole(rot=-5, dy=-8, s=0.95)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="거대 전갈", size="사람")
    return c


# ---------------------------------------------------------------- A: centipede
@creature("centipede", "A")
def centipede():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("centipede", (W, H), (cx, gy), seed=903,
                 note="Giant centipede, front view. Rust-red segmented centipede rearing up from a coil on the ground, "
                      "dark band on every segment, rows of pale legs, long antennae, hooked venom fangs under a flat head "
                      "with small glowing eyes. attack = rears higher and strikes forward, fangs spread; hit = snaps back "
                      "into its coil, eyes dimmed.")
    c.shadow(cx, gy - 2, 300, 34)
    spine = [(cx + 60, 340), (cx - 70, 334), (cx - 100, 290), (cx - 10, 250), (cx + 30, 190), (cx, 140)]

    import math as _m
    lens = [0.0]
    for (x0, y0), (x1, y1) in zip(spine[:-1], spine[1:]):
        lens.append(lens[-1] + _m.hypot(x1 - x0, y1 - y0))

    def point(t):
        d = t * lens[-1]
        for i in range(len(spine) - 1):
            if d <= lens[i + 1] or i == len(spine) - 2:
                u = (d - lens[i]) / max(1e-6, lens[i + 1] - lens[i])
                (x0, y0), (x1, y1) = spine[i], spine[i + 1]
                return x0 + (x1 - x0) * u, y0 + (y1 - y0) * u

    nseg = 20
    body, bands, legs = [], [], []
    for i in range(nseg):
        t = i / (nseg - 1)
        x, y = point(t)
        w = 34 + 18 * t
        body.append(E(x, y, w * 1.3, w))
        bands.append(E(x, y + w * 0.12, w * 1.26, w * 0.34))
        xn, yn = point(min(1.0, t + 0.04))
        ang = math.degrees(math.atan2(yn - y, xn - x))
        for d in (-1, 1):
            a = math.radians(ang + 90 * d)
            lx, ly = x + math.cos(a) * w * 0.9, y + math.sin(a) * w * 0.9
            legs.append(seg(x, y, lx, min(ly + 10, gy - 6), 5, ext=0.1))
    c.add("legs", "bone_old", 1, legs, tags=("body",))
    c.add("body", "chitin_rust", 2, body, tags=("body",))
    c.flat("bands", "chitin_black", 2.1, bands, tags=("body",), clip_to="body", opacity=0.55)
    hx, hy = spine[-1]
    c.add("antennae", "chitin_black", 2.8, tube([(hx - 14, hy - 16), (hx - 40, hy - 60), (hx - 70, hy - 76)], 6, 2, n=8)
          + tube([(hx + 14, hy - 16), (hx + 40, hy - 60), (hx + 70, hy - 76)], 6, 2, n=8), tags=("head",), pivot=[hx, hy + 40])
    c.add("head", "chitin_rust", 3, [E(hx, hy, 74, 50)], tags=("head",), pivot=[hx, hy + 40])
    c.glow("eyes", "glow_yellow", 3.2, [E(hx - 16, hy - 6, 8, 6), E(hx + 16, hy - 6, 8, 6)], tags=("head", "eyes"), color="glow_yellow_c",
           strength=0.8, opacity=0.4, pivot=[hx, hy + 40])
    c.flat("eyes_hit", "soot", 3.2, [E(hx - 16, hy - 5, 10, 3), E(hx + 16, hy - 5, 10, 3)], tags=("head", "eyes_hit"), hidden=True,
           pivot=[hx, hy + 40])
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"fang_{s}", "claw", 3.3, [P("moon", hx + k * 14, hy + 28, 24, 24, rot=135 if k < 0 else -135, **({"flip": "x"} if k > 0 else {}))],
              tags=("head", f"fang_{s}"), pivot=[hx + k * 10, hy + 18], line={"width": 0.6, "heavy": 0.5})
    std_frames(
        c,
        attack_move={"fang_l": {"rot": 20, "pivot": [hx - 10, hy + 18]}, "fang_r": {"rot": -20, "pivot": [hx + 10, hy + 18]},
                     "head": {"sx": 1.12, "sy": 1.12, "dy": 16, "pivot": [hx, hy + 40]}, "all": c.whole(s=1.03)},
        hit_move={"head": {"rot": -16, "dy": 10, "pivot": [hx, hy + 40]}, "all": c.whole(rot=5, sy=0.94)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="거대 지네", size="사람")
    return c


# ================================================================ B (idle only)
@creature("caterpillar", "B")
def caterpillar():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("caterpillar", (W, H), (cx, gy), seed=921,
                 note="Giant caterpillar, front view. Fat segmented green grub rearing up from the ground in an S, pale "
                      "belly, dark spots with ochre rings along the back, stubby legs, round head with dark eyes, mandibles "
                      "and two short horns.")
    c.shadow(cx, gy - 2, 280, 30)
    spine = [(cx + 120, 340), (cx - 20, 348), (cx - 90, 300), (cx - 30, 240), (cx + 10, 190)]
    import math as _m
    lens = [0.0]
    for (x0, y0), (x1, y1) in zip(spine[:-1], spine[1:]):
        lens.append(lens[-1] + _m.hypot(x1 - x0, y1 - y0))

    def point(t):
        d = t * lens[-1]
        for i in range(len(spine) - 1):
            if d <= lens[i + 1] or i == len(spine) - 2:
                u = (d - lens[i]) / max(1e-6, lens[i + 1] - lens[i])
                (x0, y0), (x1, y1) = spine[i], spine[i + 1]
                return x0 + (x1 - x0) * u, y0 + (y1 - y0) * u

    body, spots, legs = [], [], []
    n = 11
    for i in range(n):
        t = i / (n - 1)
        x, y = point(t)
        w = 40 + 34 * t
        body.append(E(x, y, w * 1.2, w))
        if i % 2 == 0:
            spots.append(E(x, y - w * 0.18, w * 0.4, w * 0.3))
        legs.append(E(x - 6, y + w * 0.44, 10, 12))
        legs.append(E(x + 6, y + w * 0.44, 10, 12))
    c.add("legs", "leaf_dark", 1, legs, tags=("body",))
    c.add("body", "leaf", 2, body, tags=("body",))
    c.add("belly", "belly", 2.1, [E(point(t)[0], point(t)[1] + 16, 40, 18) for t in (0.2, 0.4, 0.6, 0.8)], tags=("body",), clip_to="body",
          line=False, opacity=0.5)
    c.flat("spots", "gold", 2.2, spots, tags=("body",), clip_to="body", opacity=0.8)
    c.flat("spot_core", "eye", 2.3, [E(p["at"][0], p["at"][1], p["size"][0] * 0.5, p["size"][1] * 0.5) for p in spots], tags=("body",),
           clip_to="body")
    hx, hy = spine[-1]
    c.add("head", "leaf", 3, [E(hx, hy - 30, 90, 80)], tags=("head",))
    c.add("horns", "horn", 2.9, [P("cone", hx - 22, hy - 80, 12, 26, rot=-16), P("cone", hx + 22, hy - 80, 12, 26, rot=16)], tags=("head",))
    dot_eyes(c, hx, hy - 36, 20, 18, 20, z=3.2, tags=("head",))
    c.add("mandibles", "claw", 3.3, [P("moon", hx - 10, hy - 4, 14, 14, rot=135), P("moon", hx + 10, hy - 4, 14, 14, rot=-135, flip="x")],
          tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 애벌레", size="사람")
    return c


@creature("kraken", "B")
def kraken():
    W, H = 768, 640
    cx, gy = 384, 620
    c = Creature("kraken", (W, H), (cx, gy), seed=922,
                 note="Kraken, front view. Colossal dark wine-red octopus rearing up: bulbous mantle with ridges, two huge "
                      "golden slit-pupil eyes, a beaked mouth, eight thick suckered arms spreading and curling in every "
                      "direction.")
    c.shadow(cx, gy - 4, 520, 50)
    arms = [(-1, [(cx - 90, 470), (cx - 250, 520), (cx - 330, 430), (cx - 290, 340)]),
            (-1, [(cx - 100, 420), (cx - 250, 360), (cx - 300, 230), (cx - 230, 170)]),
            (-1, [(cx - 60, 500), (cx - 170, 600), (cx - 300, 600), (cx - 350, 540)]),
            (-1, [(cx - 30, 520), (cx - 60, 600), (cx - 140, 610), (cx - 160, 570)]),
            (1, [(cx + 90, 470), (cx + 250, 520), (cx + 330, 430), (cx + 290, 340)]),
            (1, [(cx + 100, 420), (cx + 250, 360), (cx + 300, 230), (cx + 230, 170)]),
            (1, [(cx + 60, 500), (cx + 170, 600), (cx + 300, 600), (cx + 350, 540)]),
            (1, [(cx + 30, 520), (cx + 60, 600), (cx + 140, 610), (cx + 160, 570)])]
    from .kit import along
    for i, (k, ctrl) in enumerate(arms):
        z = 1 + (0.6 if i % 4 >= 2 else 0) + i * 0.01
        c.add(f"arm_{i}", "cloth_wine", z, tube(ctrl, 70, 14, n=18, cap=True), tags=("arms",))
        c.add(f"arm_{i}_s", "sucker", z + 0.005, along(ctrl, 8, lambda x, y, a, j, t: E(x + math.cos(math.radians(a + 90 * k)) * (70 - 56 * t) * 0.4,
                                                                                         y + math.sin(math.radians(a + 90 * k)) * (70 - 56 * t) * 0.4,
                                                                                         (70 - 56 * t) * 0.3, (70 - 56 * t) * 0.26), 0.15, 0.9),
              tags=("arms",), clip_to=f"arm_{i}", line=False)
    c.add("mantle", "cloth_wine", 2, [P("droplet", cx, 280, 300, 360), E(cx, 430, 260, 160)], tags=("body",))
    c.flat("ridges", "robe_black", 2.1, [seg(cx + d * 40, 130 + abs(d) * 20, cx + d * 60, 300, 6) for d in (-2, -1, 0, 1, 2)], tags=("body",),
           clip_to="mantle", opacity=0.35)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"eye_{s}", "cloth_wine", 2.3, [E(cx + k * 80, 400, 90, 80)], tags=("head",))
    c.glow("eyes", "glow_yellow", 2.4, [E(cx - 80, 402, 62, 54), E(cx + 80, 402, 62, 54)], tags=("head",), color="glow_yellow_c",
           strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 2.45, [E(cx - 80, 404, 44, 12), E(cx + 80, 404, 44, 12)], tags=("head",))
    c.add("beak", "claw", 2.5, [P("triangle", cx, 486, 40, 34, flip="y"), P("triangle", cx, 470, 34, 22)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="크라켄", size="거대")
    return c


@creature("giant_shark", "B")
def giant_shark():
    W, H = 640, 512
    cx, gy = 320, 494
    c = Creature("giant_shark", (W, H), (cx, gy), seed=923,
                 note="Giant shark, 3/4 front view lunging toward the lower left. Scarred slate-grey shark with a pale "
                      "belly, tall dorsal fin, pectoral fins spread, cold small eyes and a gaping jaw full of teeth.")
    c.shadow(cx, gy - 4, 420, 40, opacity=0.3, blur=6)
    c.add("tail", "shark", 1, [P("triangle", 540, 190, 90, 150, rot=40), P("triangle", 560, 330, 70, 120, rot=140)], tags=("body",))
    c.add("fin_far", "shark", 1.2, [P("triangle", 300, 390, 90, 60, rot=160)], tags=("body",))
    c.add("body", "shark", 2, [P("droplet", 330, 270, 200, 460, rot=-100), E(220, 290, 190, 170)], tags=("body",))
    c.add("belly", "eye_white", 2.1, [E(260, 340, 300, 90, rot=-8)], tags=("body",), clip_to="body", opacity=0.55, line=False)
    c.add("dorsal", "shark", 1.8, [P("triangle", 330, 150, 90, 120, rot=20)], tags=("body",))
    c.add("fin", "shark", 3, [P("triangle", 230, 390, 110, 70, rot=200)], tags=("body",))
    c.flat("gills", "robe_black", 2.2, [seg(300 + i * 16, 250, 296 + i * 16, 310, 4) for i in range(4)], tags=("body",), opacity=0.5)
    c.flat("mouth", "mouth", 3.2, [E(150, 300, 130, 110)], tags=("head",))
    c.add("teeth_up", "tooth", 3.3, fangs(96, 206, 254, 8, 16, jitter=0.2), tags=("head",), line={"width": 0.5, "heavy": 0.4})
    c.add("teeth_lo", "tooth", 3.3, fangs(104, 198, 346, 7, 14, down=False, jitter=0.2), tags=("head",), line={"width": 0.5, "heavy": 0.4})
    c.flat("scars", "eye_white", 2.3, [seg(260, 200, 300, 214, 3), seg(274, 190, 290, 226, 3)], tags=("body",), opacity=0.5)
    dot_eyes(c, 200, 214, 32, 11, 10, z=3.4, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="대왕 상어", size="큼")
    return c


@creature("crab", "B")
def crab():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("crab", (W, H), (cx, gy), seed=924,
                 note="Giant crab, front view. Wide rust-red knobbly carapace, eyes on stalks, one oversized pincer raised "
                      "and one smaller, four jointed legs per side braced on the ground, pale belly plates.")
    c.shadow(cx, gy - 2, 320, 34)
    for s, k in (("l", -1), ("r", 1)):
        for i in range(4):
            root = (cx + k * (70 + i * 8), 290 + i * 6)
            knee = (cx + k * (120 + i * 14), 266 + i * 10)
            foot = (cx + k * (140 + i * 10), gy - 10)
            arch_leg(c, f"leg_{s}{i}", root, knee, foot, 18, 7, "crab", 1 + i * 0.02, ("legs",), tip_mat="claw")
    c.add("body", "crab", 2, [E(cx, 280, 230, 130)], tags=("body",))
    c.add("belly", "belly", 2.1, [E(cx, 320, 150, 50)], tags=("body",), clip_to="body", opacity=0.6)
    c.flat("knobs", "chitin_rust", 2.2, [E(cx + dx, 250 + dy, 14, 10) for dx, dy in ((-60, 0), (-20, -20), (20, -20), (60, 0), (0, 10))],
           tags=("body",), clip_to="body", opacity=0.7)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"stalk_{s}", "crab", 2.5, [seg(cx + k * 22, 230, cx + k * 30, 196, 8)], tags=("head",))
        c.add(f"eyeball_{s}", "eye", 2.6, [E(cx + k * 30, 190, 16, 16)], tags=("head",))
        c.flat(f"glint_{s}", "eye_white", 2.65, [E(cx + k * 30 - 3, 187, 5, 5)], tags=("head",), line=False)
    c.add("arm_l", "crab", 3, tube([(cx - 96, 270), (cx - 136, 240), (cx - 134, 206)], 30, 22, n=6, cap=True), tags=("arms",))
    c.add("claw_l", "crab", 3.2, pincer(cx - 130, 176, 104, -92, 0.45), tags=("arms",))
    c.add("arm_r", "crab", 3, tube([(cx + 100, 274), (cx + 140, 260), (cx + 150, 240)], 24, 18, n=6, cap=True), tags=("arms",))
    c.add("claw_r", "crab", 3.2, pincer(cx + 154, 220, 72, -70, 0.3), tags=("arms",))
    c.flat("mouth", "mouth", 2.4, [E(cx, 300, 40, 10)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 게", size="사람")
    return c


@creature("jellyfish", "B")
def jellyfish():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("jellyfish", (W, H), (cx, gy), seed=925,
                 note="Jellyfish, front view, drifting. Translucent violet bell with a glowing inner frill, scalloped rim, "
                      "four frilly oral arms and many long thin trailing tentacles; faint bioluminescent spots.")
    c.shadow(cx, gy - 2, 90, 14, opacity=0.2, blur=7)
    for i in range(7):
        x = cx - 60 + i * 20
        c.add(f"tentacle_{i}", "jelly", 1, tube([(x, 170), (x + (i - 3) * 6, 240), (x - (i - 3) * 10, 320)], 5, 2, n=10, cap=True),
              tags=("body",), opacity=0.75, line={"width": 0.5, "heavy": 0.4})
    for i, x in enumerate((cx - 26, cx - 8, cx + 10, cx + 28)):
        c.add(f"oral_{i}", "jelly", 1.5, tube([(x, 170), (x + 8, 220), (x - 6, 270)], 16, 6, n=10, cap=True), tags=("body",), opacity=0.8)
    c.add("bell", "jelly", 2, [E(cx, 140, 190, 150), P("square", cx, 196, 200, 60, op="sub")] + [E(cx - 80 + i * 32, 164, 36, 22) for i in range(6)],
          tags=("body",), opacity=0.82)
    c.glow("frill", "glow_violet", 2.2, [E(cx, 140, 110, 50), E(cx, 130, 70, 30, op="sub")], tags=("body",), color="glow_violet_c",
           strength=0.7, opacity=0.4)
    c.glow("spots", "glow_cyan", 2.3, [E(cx - 50, 110, 8, 8), E(cx + 40, 96, 7, 7), E(cx + 60, 124, 6, 6), E(cx - 20, 90, 6, 6)], tags=("body",),
           color="ghost_glow_c", strength=0.9, opacity=0.5)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="해파리", size="작음")
    return c


# ================================================================ C (idle only)
@creature("giant_wasp", "C")
def giant_wasp():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("giant_wasp", (W, H), (cx, gy), seed=931,
                 note="Giant wasp, front view, hovering. Dull gold and black banded wasp with a curled-under abdomen ending "
                      "in a stinger, big dark compound eyes, hooked mandibles, short antennae, four smoky translucent "
                      "wings and dangling legs.")
    c.shadow(cx, gy - 2, 100, 14, opacity=0.25, blur=7)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "ghost", 1, [P("droplet", cx + k * 70, 140, 50, 130, rot=k * 64), P("droplet", cx + k * 60, 186, 36, 90, rot=k * 110)],
              tags=("wings",), opacity=0.55, line={"width": 0.6, "heavy": 0.5})
        for j in range(3):
            c.add(f"leg_{s}{j}", "robe_black", 1.5, tube([(cx + k * 24, 200 + j * 12), (cx + k * (56 + j * 8), 230 + j * 14), (cx + k * (46 + j * 10), 280 + j * 14)],
                                                         6, 3, n=6, cap=True), tags=("legs",))
    c.add("abdomen", "gold", 2, tube([(cx, 220), (cx + 6, 280), (cx - 4, 320)], 70, 30, n=10, cap=True), tags=("body",))
    c.flat("bands", "robe_black", 2.1, [E(cx + 2, 244 + i * 26, 76 - i * 12, 12) for i in range(3)], tags=("body",), clip_to="abdomen")
    c.add("stinger", "claw", 1.9, [P("triangle", cx - 4, 344, 10, 26, flip="y")], tags=("body",))
    c.add("thorax", "robe_black", 2.5, [E(cx, 196, 70, 56)], tags=("body",))
    c.add("head", "gold", 3, [E(cx, 150, 80, 60)], tags=("head",))
    c.add("eyes", "chitin_black", 3.1, [E(cx - 28, 146, 30, 42, rot=-10), E(cx + 28, 146, 30, 42, rot=10)], tags=("head",))
    c.add("mandibles", "claw", 3.2, [P("moon", cx - 10, 180, 16, 16, rot=135), P("moon", cx + 10, 180, 16, 16, rot=-135, flip="x")], tags=("head",))
    c.add("antennae", "robe_black", 3.3, tube([(cx - 8, 122), (cx - 26, 96), (cx - 40, 90)], 4, 2, n=6, cap=True)
          + tube([(cx + 8, 122), (cx + 26, 96), (cx + 40, 90)], 4, 2, n=6, cap=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 말벌", size="작음")
    return c


@creature("grasshopper", "C")
def grasshopper():
    W, H = 384, 384
    gy = 366
    c = Creature("grasshopper", (W, H), (196, gy), seed=932,
                 note="Giant grasshopper, 3/4 front view facing the lower left. Dusty olive locust with a long body and "
                      "folded wings, huge angled hind legs with spined shins, big shiny eyes, long antennae, chewing jaws.")
    c.shadow(206, gy - 4, 280, 28)
    c.add("hind_far", "leaf_dark", 1, [seg(250, 290, 300, 220, 30), seg(300, 220, 280, 350, 12)], tags=("legs",))
    c.add("body", "leaf", 2, [E(210, 290, 200, 70, rot=-12), E(128, 290, 80, 70)], tags=("body",))
    c.add("wings", "leaf_dark", 2.1, [P("droplet", 250, 272, 40, 170, rot=-100)], tags=("body",), opacity=0.9)
    c.flat("stripes", "belly", 2.2, [seg(170 + i * 24, 300, 176 + i * 24, 320, 3) for i in range(4)], tags=("body",), clip_to="body", opacity=0.5)
    for i, x in enumerate((140, 180)):
        c.add(f"front_{i}", "leaf_dark", 2.5, tube([(x, 310), (x - 16, 336), (x - 10, 358)], 7, 4, n=5, cap=True), tags=("legs",))
    c.add("hind", "leaf", 3, [seg(230, 300, 296, 230, 38), seg(296, 230, 272, 356, 14)], tags=("legs",))
    c.flat("spines", "claw", 3.1, [P("triangle", 290 - i * 5, 250 + i * 24, 5, 10, rot=-160) for i in range(4)], tags=("legs",))
    c.add("head", "leaf", 4, [P("droplet", 96, 290, 64, 90, rot=-150)], tags=("head",))
    c.add("eye", "chitin_black", 4.1, [E(108, 270, 26, 30)], tags=("head",))
    c.add("antennae", "leaf_dark", 4.2, tube([(96, 254), (80, 180), (110, 110)], 4, 2, n=10, cap=True) + tube([(110, 256), (120, 190), (160, 130)], 4, 2, n=10, cap=True),
          tags=("head",))
    c.add("jaws", "claw", 4.3, [E(70, 322, 18, 12)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 메뚜기", size="사람")
    return c


@creature("flea", "C")
def flea():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("flea", (W, H), (cx, gy), seed=933,
                 note="Giant flea, front view. Glossy rust-brown armoured flea with bristly spines, a small head with a "
                      "piercing beak and tiny glowing eyes, short front legs and huge coiled hind legs ready to spring.")
    c.shadow(cx, gy - 2, 200, 24)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"hind_{s}", "chitin_rust", 1, [seg(cx + k * 40, 290, cx + k * 110, 240, 36), seg(cx + k * 110, 240, cx + k * 96, 350, 18)], tags=("legs",))
        c.add(f"front_{s}", "chitin_rust", 2.5, tube([(cx + k * 30, 300), (cx + k * 50, 330), (cx + k * 44, 356)], 10, 6, n=5, cap=True), tags=("legs",))
    c.add("body", "chitin_rust", 2, [E(cx, 250, 150, 170)], tags=("body",))
    c.flat("segments", "chitin_black", 2.1, [smile(cx, 220 + i * 30, 140, 10, depth=0.6)[0] for i in range(4)], tags=("body",), clip_to="body", opacity=0.4)
    c.add("bristles", "claw", 2.2, spikes_on([(cx - 70, 300), (cx - 60, 180), (cx, 160), (cx + 60, 180), (cx + 70, 300)], 12, 16, 6, 0.0, 1.0, side=-1),
          tags=("body",))
    c.add("head", "chitin_rust", 3, [E(cx, 300, 60, 44)], tags=("head",))
    c.glow("eyes", "glow_red", 3.1, [E(cx - 14, 296, 6, 6), E(cx + 14, 296, 6, 6)], tags=("head",), color="glow_red_c", strength=0.8, opacity=0.4)
    c.add("beak", "claw", 3.2, [P("triangle", cx, 334, 10, 34, flip="y")], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 벼룩", size="작음")
    return c


@creature("slug", "C")
def slug():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("slug", (W, H), (cx, gy), seed=934,
                 note="Giant slug, front view. Glistening dark violet-brown slug rearing up from a trail of slime, a "
                      "mottled mantle hump, four eye-stalk tentacles (two long with glowing tips), a wet drooping mouth.")
    c.shadow(cx, gy - 2, 280, 30)
    c.add("slime", "slime", 0.8, [E(cx, 350, 280, 40)], tags=("body",), opacity=0.6, line=False)
    c.add("foot", "tentacle", 1, [E(cx, 330, 220, 70)], tags=("body",))
    c.add("body", "tentacle", 2, [P("droplet", cx, 240, 150, 220), E(cx, 300, 170, 100)], tags=("body",))
    c.add("mantle", "membrane", 2.1, [E(cx, 220, 120, 90)], tags=("body",), clip_to="body", opacity=0.7)
    c.flat("mottles", "robe_black", 2.2, [E(cx + dx, 230 + dy, 16, 12) for dx, dy in ((-30, -10), (20, -20), (34, 20), (-20, 30))], tags=("body",),
           clip_to="body", opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"stalk_{s}", "tentacle", 1.8, tube([(cx + k * 20, 140), (cx + k * 40, 90), (cx + k * 50, 60)], 12, 7, n=8, cap=True), tags=("head",))
        c.glow(f"tip_{s}", "glow_yellow", 1.9, [E(cx + k * 50, 56, 14, 14)], tags=("head",), color="glow_yellow_c", strength=0.7, opacity=0.4)
        c.add(f"feeler_{s}", "tentacle", 2.3, tube([(cx + k * 30, 170), (cx + k * 50, 160), (cx + k * 60, 170)], 8, 4, n=6, cap=True), tags=("head",))
    c.flat("mouth", "mouth", 2.4, smile(cx, 190, 50, 14, frown=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 민달팽이", size="사람")
    return c


@creature("bug_swarm", "C")
def bug_swarm():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("bug_swarm", (W, H), (cx, gy), seed=935,
                 note="Bug swarm, front view. A buzzing cloud of dozens of small dark beetles and flies of different sizes "
                      "and angles, a few with tiny green glowing eyes, denser in the middle.")
    c.shadow(cx, gy - 2, 220, 24, opacity=0.25, blur=8)
    import random
    rnd = random.Random(935)
    bugs = []
    for i in range(34):
        r = rnd.random() ** 0.7 * 150
        a = rnd.random() * math.tau
        x, y = cx + math.cos(a) * r, 200 + math.sin(a) * r * 0.7
        s = rnd.uniform(14, 30) * (1.2 - r / 300)
        bugs.append((x, y, s, rnd.uniform(-40, 40)))
    c.add("wings", "ghost", 1, [P("droplet", x + d * s * 0.4, y - s * 0.4, s * 0.5, s * 0.9, rot=r + d * 50) for x, y, s, r in bugs[::2] for d in (-1, 1)],
          tags=("swarm",), opacity=0.5, line=False)
    c.add("bugs", "chitin_black", 2, [P("bug", x, y, s, s, rot=r) for x, y, s, r in bugs], tags=("swarm",))
    c.glow("eyes", "glow_green", 2.1, [E(x, y - s * 0.25, s * 0.18, s * 0.18) for x, y, s, r in bugs[:8]], tags=("swarm",), color="glow_green_c",
           strength=0.8, opacity=0.35)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="벌레 떼", size="사람")
    return c


@creature("whale", "C")
def whale():
    W, H = 768, 512
    cx, gy = 384, 494
    c = Creature("whale", (W, H), (cx, gy), seed=936,
                 note="Whale, 3/4 front view facing the lower left. Enormous slate-grey sperm-like whale breaching: huge "
                      "blunt head with a long jaw line and a small dark eye, pale grooved throat, barnacle patches, a "
                      "pectoral fin, the tail fluke raised high behind.")
    c.shadow(cx, gy - 4, 560, 50, opacity=0.3, blur=6)
    c.add("fluke", "shark", 1, [P("heart", 640, 120, 170, 110, rot=160)], tags=("body",))
    c.add("tail", "shark", 1.1, tube([(560, 320), (620, 240), (640, 160)], 90, 40, n=10, cap=True), tags=("body",))
    c.add("body", "shark", 2, [E(420, 350, 400, 210, rot=-12), E(240, 360, 330, 230)], tags=("body",))
    c.add("throat", "eye_white", 2.1, [E(260, 430, 330, 80, rot=-6)], tags=("body",), clip_to="body", opacity=0.5)
    c.flat("grooves", "stone_dark", 2.2, [seg(120 + i * 30, 420 + i * 2, 190 + i * 30, 440 - i * 2, 3) for i in range(7)], tags=("body",), clip_to="throat", opacity=0.6)
    c.flat("jaw", "robe_black", 2.3, [seg(90, 400, 300, 380, 5)], tags=("body",))
    c.add("barnacles", "bone_old", 2.4, [E(200 + dx, 300 + dy, 16, 12) for dx, dy in ((0, 0), (30, 10), (60, -10), (90, 20), (340, -30), (380, -10))], tags=("body",),
          clip_to="body")
    c.add("fin", "shark", 3, [P("leaf", 330, 440, 140, 60, rot=160)], tags=("body",))
    dot_eyes(c, 250, 356, 0, 16, 12, z=2.5, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="고래", size="거대")
    return c


@creature("shrimp", "C")
def shrimp():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("shrimp", (W, H), (cx, gy), seed=937,
                 note="Giant shrimp, front view. Curled translucent-shelled rust-pink shrimp standing on its many legs: "
                      "segmented body arching up, a spiked head crest, black eyes on stalks, two long whip antennae and a "
                      "fanned tail.")
    c.shadow(cx, gy - 2, 260, 28)
    body = [(cx + 80, 330), (cx + 110, 240), (cx + 30, 160), (cx - 50, 170)]
    c.add("tail_fan", "crab", 1, [P("fan", cx + 90, 346, 90, 50, rot=180)], tags=("body",))
    for i in range(6):
        t = 0.2 + i * 0.12
        c.add(f"leg_{i}", "crab", 1.5, tube([(cx + 70 - i * 22, 250 + i * 6), (cx + 60 - i * 24, 310), (cx + 56 - i * 26, 356)], 8, 4, n=5, cap=True), tags=("legs",))
    c.add("body", "crab", 2, tube(body, 60, 80, n=16, cap=True), tags=("body",), opacity=0.95)
    from .kit import along
    c.flat("segs", "chitin_rust", 2.1, along(body, 6, lambda x, y, a, i, t: P("circle", x, y, 66 + 12 * t, 8, a + 90), 0.1, 0.8), tags=("body",),
           clip_to="body", opacity=0.5)
    c.add("crest", "crab", 1.9, spikes_on([(cx - 80, 150), (cx - 40, 130), (cx, 140)], 5, 22, 10, 0.0, 1.0, side=-1), tags=("head",))
    c.add("head", "crab", 3, [E(cx - 50, 176, 90, 70)], tags=("head",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"stalk_{s}", "crab", 3.1, [seg(cx - 50 + k * 20, 160, cx - 50 + k * 30, 136, 8)], tags=("head",))
        c.add(f"eye_{s}", "eye", 3.2, [E(cx - 50 + k * 30, 130, 16, 16)], tags=("head",))
    c.add("antennae", "chitin_rust", 3.3, tube([(cx - 60, 190), (cx - 140, 150), (cx - 170, 60)], 5, 2, n=12, cap=True)
          + tube([(cx - 40, 190), (cx - 100, 120), (cx - 60, 40)], 5, 2, n=12, cap=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 새우", size="사람")
    return c


@creature("oyster", "C")
def oyster():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("oyster", (W, H), (cx, gy), seed=938,
                 note="Pearl oyster monster, front view. A giant craggy grey oyster gaping open: jagged shell edges like "
                      "teeth, a lolling pale tongue of flesh, two eye stalks peeking over the rim and a glowing pearl "
                      "held inside.")
    c.shadow(cx, gy - 2, 220, 26)
    c.add("upper", "stone", 1, [P("circle", cx, 210, 230, 140, half="top"), E(cx, 212, 230, 30)], tags=("body",))
    c.flat("upper_ridges", "stone_dark", 1.1, [seg(cx, 150, cx + d * 60, 214, 4) for d in (-1.6, -0.8, 0, 0.8, 1.6)], tags=("body",), clip_to="upper", opacity=0.5)
    c.flat("inside", "mouth", 1.5, [E(cx, 250, 210, 90)], tags=("body",))
    c.add("nacre", "ghost", 1.6, [E(cx, 260, 180, 70)], tags=("body",), opacity=0.35, line=False)
    c.glow("pearl", "glow_white", 1.7, [E(cx, 244, 40, 40)], tags=("body",), color="lamp_glow", strength=1.0, opacity=0.6)
    c.add("tongue", "hide_pink", 1.8, tube([(cx - 20, 270), (cx - 40, 300), (cx - 20, 330)], 40, 20, n=8, cap=True), tags=("body",))
    c.add("teeth_up", "bone_old", 1.9, fangs(cx - 96, cx + 96, 222, 11, 16, jitter=0.4), tags=("body",), line={"width": 0.5, "heavy": 0.4})
    c.add("lower", "stone", 2, [P("circle", cx, 300, 236, 120, half="bottom"), E(cx, 298, 236, 26)], tags=("body",))
    c.add("teeth_lo", "bone_old", 2.1, fangs(cx - 90, cx + 90, 292, 10, 14, down=False, jitter=0.4), tags=("body",), line={"width": 0.5, "heavy": 0.4})
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"stalk_{s}", "hide_pink", 0.8, [seg(cx + k * 40, 160, cx + k * 60, 110, 10)], tags=("head",))
        c.add(f"eye_{s}", "eye_white", 0.9, [E(cx + k * 62, 104, 22, 22)], tags=("head",))
        c.flat(f"pupil_{s}", "eye", 0.95, [E(cx + k * 62, 106, 9, 9)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="진주 굴 괴물", size="작음")
    return c


@creature("piranha", "C")
def piranha():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("piranha", (W, H), (cx, gy), seed=939,
                 note="Piranha, 3/4 front view facing the lower left, hovering. Deep-bodied dusky grey fish with a rusty "
                      "red belly, a jutting underbite full of triangle teeth, a mean glowing eye, spiny fins and a forked tail.")
    c.shadow(cx, gy - 2, 140, 18, opacity=0.25, blur=7)
    c.add("tail", "shark", 1, [P("fan", 256, 190, 70, 80, rot=90)], tags=("body",))
    c.add("dorsal", "shark", 1.2, [P("triangle", 180, 120, 60, 60, rot=20)], tags=("body",))
    c.add("body", "shark", 2, [E(170, 200, 190, 150, rot=-10)], tags=("body",))
    c.add("belly", "crab", 2.1, [E(150, 250, 150, 60, rot=-10)], tags=("body",), clip_to="body", opacity=0.8)
    c.flat("scales", "stone_dark", 2.2, [P("moon", 170 + dx, 190 + dy, 16, 16, rot=-45) for dx in (-20, 10, 40) for dy in (-20, 10)], tags=("body",),
           clip_to="body", opacity=0.4)
    c.add("fin", "shark", 3, [P("triangle", 150, 272, 40, 40, rot=190)], tags=("body",))
    c.flat("mouth", "mouth", 3.1, [E(92, 234, 60, 36, rot=-20)], tags=("head",))
    c.add("teeth", "tooth", 3.2, [P("triangle", 72 + i * 11, 224 - i * 4, 8, 12, flip="y") for i in range(4)]
          + [P("triangle", 70 + i * 11, 246 - i * 4, 8, 12) for i in range(5)], tags=("head",), line={"width": 0.4, "heavy": 0.3})
    c.add("jaw", "shark", 3.05, [E(96, 258, 70, 24, rot=-20)], tags=("head",))
    c.glow("eye", "glow_red", 3.3, [E(122, 180, 16, 16)], tags=("head",), color="glow_red_c", strength=0.7, opacity=0.4)
    c.flat("pupil", "eye", 3.35, [E(122, 180, 6, 6)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="이빨 물고기", size="작음")
    return c
