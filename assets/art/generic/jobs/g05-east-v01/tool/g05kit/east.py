"""g05-east-v01: East-Asian (Korea / China / Japan) yokai and spirits (front-view battlers).

Each function returns a kit.Creature.  Coordinates are final px.  A items get
idle / attack / hit, B and C items idle only.
"""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, spikes_on, wing_at


def bushy_tail(c, name, base, ang, length, width, mat, tip_mat, z, tags, bend=18.0, hidden=False):
    """Fox tail: thin at the base, full in the middle, pointed tip, light tip colour."""
    a = math.radians(ang)
    b2 = math.radians(ang + bend)
    mid = (base[0] + math.cos(a) * length * 0.5, base[1] + math.sin(a) * length * 0.5)
    tip = (mid[0] + math.cos(b2) * length * 0.5, mid[1] + math.sin(b2) * length * 0.5)
    q1 = (base[0] + math.cos(a) * length * 0.25, base[1] + math.sin(a) * length * 0.25)
    q3 = (mid[0] + math.cos(b2) * length * 0.25, mid[1] + math.sin(b2) * length * 0.25)
    pieces = tube([base, q1, mid], width * 0.35, width, n=8) + tube([mid, q3, tip], width, width * 0.2, n=8)
    extra = {"hidden": True} if hidden else {}
    c.add(name, mat, z, pieces, tags=tags, **extra)
    tip_pieces = tube([q3, tip], width * 0.9, width * 0.2, n=6)
    c.add(name + "_tip", tip_mat, z + 0.01, tip_pieces, tags=tags, clip_to=name, line=False, **extra)


# ---------------------------------------------------------------- A: gumiho
@creature("gumiho", "A")
def gumiho():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("gumiho", (W, H), (cx, gy), seed=701,
                 note="Gumiho (nine-tailed fox), front view. Dull-orange fox standing square to the viewer, pale chest "
                      "ruff and cheeks, tall ears, narrow snout, glowing violet eyes, nine bushy pale-tipped tails fanned "
                      "behind like a halo, three cold blue fox-fires floating around it. attack = tails flared wide, fox-fires "
                      "surging, jaws open; hit = tails collapse, head turned away with eyes shut.")
    c.shadow(cx, gy - 2, 300, 34)
    base = (cx, 400)
    for i in range(9):
        ang = -150 + i * 15
        bushy_tail(c, f"tail_{i}", base, ang, 318 - abs(i - 4) * 26, 64, "fur_fox", "fur_white", 0.5 + (4 - abs(i - 4)) * 0.01,
                   ("tails",), bend=10 if ang > -90 else -10)
    fires = [(cx - 200, 330), (cx + 204, 300), (cx + 150, 120)]
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"haunch_{s}", "fur_fox", 1.5, [E(cx + k * 84, 430, 96, 110)], tags=("legs",))
        c.add(f"hindpaw_{s}", "fur_fox", 1.6, [E(cx + k * 100, 482, 64, 26)], tags=("legs",))
    c.add("body", "fur_fox", 2, [E(cx, 380, 170, 170)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "fur_fox", 3, [seg(cx + k * 40, 380, cx + k * 44, 470, 44)], tags=("legs",))
        c.add(f"paw_{s}", "fur_white", 3.1, [E(cx + k * 44, 480, 50, 26)], tags=("legs",))
    c.add("ruff", "fur_white", 3.5, [P("cloud", cx, 330, 150, 80, flip="y"), P("droplet", cx, 380, 80, 110, flip="y")], tags=("body",))
    c.add("ears", "fur_fox", 4.8, [P("triangle", cx - 46, 192, 50, 86, rot=-16), P("triangle", cx + 46, 192, 50, 86, rot=16)], tags=("head",))
    c.add("ears_in", "soot", 4.85, [P("triangle", cx - 44, 204, 24, 50, rot=-16), P("triangle", cx + 44, 204, 24, 50, rot=16)], tags=("head",),
          line=False, opacity=0.8)
    c.add("head", "fur_fox", 5, [E(cx, 250, 120, 100)], tags=("head",))
    c.add("cheeks", "fur_white", 5.1, [P("cloud", cx, 272, 126, 50, flip="y")], tags=("head",))
    c.add("snout", "fur_fox", 5.2, [P("droplet", cx, 270, 50, 70, flip="y")], tags=("head",))
    c.add("muzzle", "fur_white", 5.25, [P("droplet", cx, 284, 34, 40, flip="y")], tags=("head",), clip_to="snout")
    c.add("nose", "eye", 5.3, [E(cx, 300, 16, 11)], tags=("head",))
    c.flat("marks", "cloth_wine", 5.15, [P("droplet", cx, 222, 10, 24, flip="y")], tags=("head",), opacity=0.8)
    c.glow("eyes", "glow_violet", 5.3, [E(cx - 28, 246, 20, 10, rot=18), E(cx + 28, 246, 20, 10, rot=-18)], tags=("head", "eyes"),
           color="glow_violet_c", strength=0.8, opacity=0.5)
    c.flat("pupils", "eye", 5.35, [E(cx - 28, 246, 4, 9), E(cx + 28, 246, 4, 9)], tags=("head", "eyes"))
    x_eyes(c, cx, 246, 28, 8, z=5.35, width=4.5, tags=("head",))
    c.flat("mouth", "mouth", 5.3, smile(cx, 312, 24, 7), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 5.3, [E(cx, 318, 30, 22)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 5.35, fangs(cx - 12, cx + 12, 308, 4, 7), tags=("head", "mouth_open"), hidden=True,
           line={"width": 0.5, "heavy": 0.4})
    for i, (x, y) in enumerate(fires):
        c.add(f"foxfire_{i}", "ghost_glow", 6, [P("fire", x, y, 40, 54)], tags=("fires",), emit=1.0, opacity=0.9,
              line={"width": 0.6, "heavy": 0.5}, glow={"radius": 4, "opacity": 0.5, "color": "ghost_glow_c"})
    std_frames(
        c,
        attack_move={"tails": {"sx": 1.03, "sy": 1.08, "pivot": [cx, 400]}, "fires": {"dy": -16},
                     "head": {"dy": 8, "sx": 1.06, "sy": 1.06, "pivot": [cx, 320]}, "all": c.whole(s=1.02)},
        hit_move={"tails": {"sx": 0.84, "sy": 0.74, "pivot": [cx, 400]}, "head": {"rot": 16, "dx": 8, "pivot": [cx, 320]},
                  "fires": {"dy": 30, "sx": 0.8, "sy": 0.8, "pivot": [cx, 300]}, "all": c.whole(rot=4, s=0.96)},
        shadow_hit_dx=0,
    )
    c.meta.update(name_ko="구미호", size="큼")
    return c


# ---------------------------------------------------------------- A: dokkaebi
@creature("dokkaebi", "A")
def dokkaebi():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("dokkaebi", (W, H), (cx, gy), seed=702,
                 note="Dokkaebi (Korean goblin), front view. Stocky indigo-skinned brute with a single horn, wild dark "
                      "hair, huge round eyes, a wide toothy grin and a striped tawny hide loincloth, gripping a studded "
                      "wooden club. attack = club swung up overhead, eyes blazing; hit = knocked back with eyes squeezed.")
    b = Biped(c, cx, gy, 300, build=1.25, leg=0.34, torso=0.3, head=0.26, shoulder=0.18, hip=0.11, arm_w=0.085,
              leg_w=0.1, arm_len=0.35, stance=1.3, hunch=0.02)
    c.shadow(cx, gy - 2, 210, 26)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("indigo", foot="claw", z=1, thigh=1.05, shin=0.95, foot_w=1.5)
    c.add("torso", "indigo", 3, [E(cx, ys + 34, 150, 80), E(cx, yh - 26, 124, 90)], tags=("torso",))
    c.add("loin", "fur_tawny", 3.3, [E(cx, yh + 8, 130, 40), P("bookmark", cx - 22, yh + 36, 46, 44), P("bookmark", cx + 24, yh + 34, 44, 40)],
          tags=("torso",))
    c.flat("stripes", "fur_dark", 3.4, [seg(cx - 50 + i * 22, yh - 6, cx - 44 + i * 22, yh + 30, 5) for i in range(5)], tags=("torso",),
           clip_to="loin", opacity=0.85)
    c.add("sash", "cloth_blue", 3.5, [E(cx, yh - 6, 128, 14)], tags=("torso",))
    b.arm_to("l", (cx - 20, ys + 82), elbow=(b.sh["l"][0] - 20, ys + 60))
    b.arm_to("r", (cx + 34, ys + 90), elbow=(b.sh["r"][0] + 20, ys + 70))
    b.arm("l", "indigo", z=4.5, upper=1.0, fore=0.95, hand=1.3)
    b.arm("r", "indigo", z=4.5, upper=1.0, fore=0.95, hand=1.3)

    def club(hand, phi, size, z, tags, hidden=False):
        extra = {"hidden": True} if hidden else {}
        body = held("baseball_bat", hand, size, phi, grip=0.42)
        c.add("club" + ("_atk" if hidden else ""), "wood", z, [body], tags=tags, **extra)
        t = math.radians(phi)
        studs = []
        for f in (0.55, 0.72, 0.9, 1.05):
            px, py = hand[0] + math.cos(t) * size * f, hand[1] + math.sin(t) * size * f
            for d in (-1, 1):
                nx, ny = -math.sin(t) * d * size * 0.09, math.cos(t) * d * size * 0.09
                studs.append(P("triangle", px + nx, py + ny, 9, 14, rot=math.degrees(math.atan2(ny, nx)) + 90))
        c.add("studs" + ("_atk" if hidden else ""), "iron", z - 0.01, studs, tags=tags, **extra)

    club(b.hand["r"], -42, 170, 4.4, ("arm_r",))
    b.arm_to("r", (b.sh["r"][0] + 10, ys - 60), elbow=(b.sh["r"][0] + 42, ys - 6))
    b.arm("r", "indigo", z=4.5, upper=1.0, fore=0.95, hand=1.3, suffix="_atk", hidden=True, tags=("atk",))
    club(b.hand["r"], -158, 150, 4.4, ("atk",), hidden=True)
    c.add("hair", "hair", 6.4, [P("cloud", cx, hy0 - 26, 110, 60), P("droplet", cx - 56, hy0 - 4, 26, 48, rot=-40),
                                P("droplet", cx + 56, hy0 - 4, 26, 48, rot=40)], tags=("head",))
    c.add("horn", "horn", 6.3, [P("cone", cx, hy0 - 60, 24, 42)], tags=("head",))
    c.add("ears", "indigo", 6.5, sym([P("droplet", cx - 44, hy0 + 4, 18, 32, rot=-80)], cx), tags=("head",))
    c.add("head", "indigo", 7, [E(cx, hy0, 86, 76), E(cx, hy0 + 20, 90, 50)], tags=("head",))
    c.add("brow", "hair", 7.1, [E(cx - 20, hy0 - 16, 34, 10, rot=14), E(cx + 20, hy0 - 16, 34, 10, rot=-14)], tags=("head",))
    c.flat("eye_whites", "eye_white", 7.2, [E(cx - 20, hy0 - 2, 26, 26), E(cx + 20, hy0 - 2, 26, 26)], tags=("head", "eyes"))
    c.glow("eyes", "glow_yellow", 7.3, [E(cx - 18, hy0, 12, 12), E(cx + 18, hy0, 12, 12)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 7.35, [E(cx - 18, hy0, 6, 6), E(cx + 18, hy0, 6, 6)], tags=("head", "eyes"))
    x_eyes(c, cx, hy0 - 2, 20, 8, z=7.35, width=5, tags=("head",))
    c.add("nose", "indigo", 7.4, [E(cx, hy0 + 16, 26, 18)], tags=("head",))
    c.flat("mouth", "mouth", 7.45, smile(cx, hy0 + 34, 58, 18), tags=("head", "mouth"))
    c.flat("teeth", "tooth", 7.5, fangs(cx - 24, cx + 24, hy0 + 31, 6, 7), tags=("head", "mouth"), line={"width": 0.4, "heavy": 0.3})
    c.flat("mouth_open", "mouth", 7.45, [E(cx, hy0 + 38, 50, 30)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.5, fangs(cx - 22, cx + 22, hy0 + 26, 6, 9) + fangs(cx - 14, cx + 14, hy0 + 52, 4, 7, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"arm_l": {"rot": 50, "pivot": sl}, "head": {"rot": -4, "pivot": [cx, ys]}, "all": c.whole(s=1.04, dy=4)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_r"),
        hit_move={"arm_l": {"rot": 44, "pivot": sl}, "arm_r": {"rot": -20, "pivot": sr}, "head": {"rot": 12, "pivot": [cx, ys]},
                  "all": c.whole(rot=6, dx=2, dy=-4, s=0.96)},
        shadow_hit_dx=2,
    )
    c.meta.update(name_ko="도깨비", size="사람")
    return c


# ---------------------------------------------------------------- A: jiangshi
@creature("jiangshi", "A")
def jiangshi():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("jiangshi", (W, H), (cx, gy), seed=703,
                 note="Jiangshi (hopping corpse), front view. Stiff grey-green undead in a dark teal official robe and "
                      "round brimmed hat, a blank paper talisman with a red seal stuck on its forehead, both arms held "
                      "straight out toward the viewer with long nails. attack = hops high, mouth open with fangs; hit = "
                      "knocked askew, talisman flapping, eyes squeezed.")
    c.shadow(cx, gy - 2, 140, 20)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"shoe_{s}", "robe_black", 1, [E(cx + k * 18, gy - 8, 32, 16)], tags=("legs",))
    c.add("robe", "robe_teal", 2, [P("bell", cx, 268, 128, 200, crop=[1.6, 1.4, 14.4, 11.6]), E(cx, 184, 116, 44)], tags=("body",))
    c.add("robe_hem", "cloth_blue", 2.1, [P("square", cx, 352, 120, 16)], tags=("body",), clip_to="robe")
    c.add("badge", "robe_black", 2.2, [P("square", cx, 244, 54, 50)], tags=("body",))
    c.add("badge_in", "gold", 2.3, [P("square", cx, 244, 42, 38)], tags=("body",))
    c.flat("badge_mark", "cloth_wine", 2.4, [P("cloud", cx, 244, 30, 20)], tags=("body",))
    c.add("belt", "robe_black", 2.5, [E(cx, 290, 100, 12)], tags=("body",))
    # arms held straight out toward the viewer: wide sleeves coming forward and down, hands hanging limp
    for s, k in (("l", -1), ("r", 1)):
        piv = [cx + k * 50, 184]
        c.add(f"sleeve_{s}", "robe_teal", 3, [seg(cx + k * 52, 186, cx + k * 44, 222, 40), E(cx + k * 44, 226, 46, 30)],
              tags=(f"arm_{s}", "arms"), pivot=piv)
        c.flat(f"cuff_{s}", "robe_black", 3.1, [E(cx + k * 44, 228, 34, 20)], tags=(f"arm_{s}", "arms"), pivot=piv)
        c.add(f"hand_{s}", "corpse_grey", 3.2, [E(cx + k * 44, 238, 22, 18)] + [seg(cx + k * 44 + d * 6, 242, cx + k * 44 + d * 7, 262, 4, ext=0.1)
                                                                             for d in (-1.2, 0, 1.2)], tags=(f"arm_{s}", "arms"), pivot=piv)
        c.add(f"nails_{s}", "claw", 3.3, [P("triangle", cx + k * 44 + d * 7, 267, 4, 8, rot=180) for d in (-1.2, 0, 1.2)],
              tags=(f"arm_{s}", "arms"), pivot=piv)
    c.add("collar", "robe_black", 4, [E(cx, 166, 60, 20)], tags=("head",))
    c.add("head", "corpse_grey", 5, [E(cx, 130, 58, 64)], tags=("head",))
    c.add("hat", "robe_black", 6, [E(cx, 104, 88, 22), P("circle", cx, 96, 60, 40, half="top")], tags=("head",))
    c.add("hat_band", "cloth_wine", 6.1, [P("square", cx, 100, 58, 7)], tags=("head",), clip_to="hat")
    c.add("hat_knob", "gold", 6.2, [E(cx, 74, 12, 12)], tags=("head",))
    c.glow("eyes", "glow_green", 5.3, [E(cx - 12, 132, 9, 5), E(cx + 12, 132, 9, 5)], tags=("head", "eyes"), color="glow_green_c",
           strength=0.6, opacity=0.4)
    c.flat("sockets", "soot", 5.2, [E(cx - 12, 132, 16, 10), E(cx + 12, 132, 16, 10)], tags=("head",))
    x_eyes(c, cx, 132, 12, 5, mat="soot", z=5.35, width=3.5, tags=("head",))
    c.flat("mouth", "mouth", 5.3, [seg(cx - 8, 152, cx + 8, 152, 2.5)], tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 5.3, [E(cx, 153, 16, 11)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 5.35, [P("triangle", cx - 4, 150, 3, 6, flip="y"), P("triangle", cx + 4, 150, 3, 6, flip="y")],
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    c.add("talisman", "paper_talisman", 6.5, [P("square", cx + 2, 128, 22, 56, rot=4)], tags=("head", "talisman"), pivot=[cx, 104])
    c.flat("seal", "seal_red", 6.6, [P("square", cx + 3, 146, 12, 12, rot=4), seg(cx + 1, 112, cx + 3, 136, 2.5)], tags=("head", "talisman"),
           pivot=[cx, 104])
    std_frames(
        c,
        attack_move={"arms": {"dy": -8}, "talisman": {"rot": -14, "pivot": [cx, 104]}, "all": c.whole(dy=-32, s=1.03)},
        shadow_attack={"sx": 0.78, "sy": 0.78, "pivot": [cx, gy - 2]},
        hit_move={"talisman": {"rot": 28, "pivot": [cx, 104]}, "arm_l": {"dx": -6, "dy": -10}, "arm_r": {"dx": 8, "dy": 6},
                  "head": {"rot": -10, "pivot": [cx, 166]}, "all": c.whole(rot=-8, dy=-4, s=0.96)},
        shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="강시", size="사람")
    return c
