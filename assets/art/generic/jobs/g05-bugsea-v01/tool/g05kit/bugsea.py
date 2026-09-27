"""g05-bugsea-v01: bugs, arachnids and sea creatures (front-view battlers)."""

from __future__ import annotations

import math

from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, spikes_on, wing_at


def arch_leg(c, name, root, knee, foot, w0, w1, mat, z, tags, pivot=None, hidden=False, tip_mat=None):
    """Arthropod leg: root -> high knee -> foot on the ground, tapering, with a dark tip."""
    pieces = tube([root, ((root[0] + knee[0]) / 2, knee[1] - 6), knee], w0, (w0 + w1) / 2, n=6, cap=True)
    pieces += tube([knee, ((knee[0] + foot[0]) / 2 + (knee[0] - foot[0]) * 0.1, (knee[1] + foot[1]) / 2), foot], (w0 + w1) / 2, w1, n=6, cap=True)
    extra = {"hidden": True} if hidden else {}
    c.add(name, mat, z, pieces, tags=tags, pivot=list(pivot or root), **extra)
    if tip_mat:
        c.add(name + "_tip", tip_mat, z + 0.01, [E(foot[0], foot[1], w1 * 1.4, w1 * 1.6)], tags=tags, pivot=list(pivot or root),
              line=False, **extra)


def pincer(x, y, size, ang, open_=0.35):
    """Crab / scorpion claw: a palm with two curved fingers opening toward angle ``ang`` (deg)."""
    t = math.radians(ang)
    ux, uy = math.cos(t), math.sin(t)
    px, py = x - ux * size * 0.1, y - uy * size * 0.1
    out = [E(px, py, size * 0.72, size * 0.52, ang)]
    tipx, tipy = x + ux * size * 0.55, y + uy * size * 0.55
    for d in (-1, 1):
        a = t + d * open_
        fx, fy = x + math.cos(a) * size * 0.62, y + math.sin(a) * size * 0.62
        out += tube([(x + ux * size * 0.15, y + uy * size * 0.15), ((x + fx) / 2 - uy * d * size * 0.12, (y + fy) / 2 + ux * d * size * 0.12),
                     (fx, fy)], size * 0.26, size * 0.06, n=6)
    return out


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
