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



# ================================================================ B (idle only)
@creature("tengu", "B")
def tengu():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("tengu", (W, H), (cx, gy), seed=721,
                 note="Tengu, front view. Red-faced mountain goblin with a very long nose, bristling pale brows and beard, "
                      "a small black cap, black feathered wings, dark blue mountain-ascetic robe with pom-pom sash, tall "
                      "one-toothed wooden sandals, feather fan in hand.")
    b = Biped(c, cx, gy - 20, 300, build=1.0, leg=0.42, torso=0.3, head=0.19, shoulder=0.15, hip=0.09, arm_w=0.065,
              leg_w=0.075, arm_len=0.36, stance=1.1)
    c.shadow(cx, gy - 2, 190, 22)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    for s, k in (("l", -1), ("r", 1)):
        root = (cx + k * 26, ys + 20)
        c.add(f"wing_{s}", "feather_black", 0.5, [wing_at(root, 170, 150, s, rot=k * -30)], tags=("wings",))
    b.legs("cloth_blue", foot_mat="wood", z=1, thigh=1.1, shin=1.0)
    for s in "lr":
        fx, fy = b.foot[s]
        c.add(f"geta_{s}", "wood", 1.3, [P("square", fx, fy + 12, 40, 10), P("square", fx, fy + 22, 10, 20)], tags=("legs",))
    c.add("robe", "cloth_blue", 3, [P("bell", cx, ys + 90, 150, 200, crop=[1.6, 1.4, 14.4, 11.6])], tags=("torso",))
    c.add("sash", "cloth_wine", 3.3, [E(cx, yh - 8, 110, 14)], tags=("torso",))
    c.add("pompoms", "fur_white", 3.4, [E(cx - 30 + i * 20, ys + 36, 16, 16) for i in range(4)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 10, ys + 100), bend=0.1)
    b.arm_to("r", (b.sh["r"][0] + 30, ys + 40), elbow=(b.sh["r"][0] + 26, ys + 80))
    b.arm("l", "cloth_blue", "oni_red", z=4, upper=1.4, fore=1.3, hand=1.1)
    b.arm("r", "cloth_blue", "oni_red", z=4, upper=1.4, fore=1.3, hand=1.1)
    hx, hy = b.hand["r"]
    c.add("fan", "feather_brown", 4.5, [P("feather", hx + d * 12, hy - 34, 18, 50, rot=d * 18) for d in (-2, -1, 0, 1, 2)], tags=("fan",))
    c.add("head", "oni_red", 7, [E(cx, hy0, 60, 64)], tags=("head",))
    c.add("beard", "fur_white", 7.1, [P("cloud", cx, hy0 + 30, 64, 40, flip="y")], tags=("head",))
    c.add("brows", "fur_white", 7.3, [E(cx - 16, hy0 - 12, 26, 12, rot=-14), E(cx + 16, hy0 - 12, 26, 12, rot=14)], tags=("head",))
    dot_eyes(c, cx, hy0 - 2, 14, 9, 10, z=7.25, tags=("head",))
    c.add("nose", "oni_red", 7.5, tube([(cx, hy0 + 2), (cx - 4, hy0 + 24), (cx - 30, hy0 + 44)], 18, 10, n=8, cap=True), tags=("head",))
    c.add("cap", "robe_black", 7.6, [P("hexagon", cx, hy0 - 32, 26, 20)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="텐구", size="사람")
    return c


@creature("kappa", "B")
def kappa():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("kappa", (W, H), (cx, gy), seed=722,
                 note="Kappa, front view. Small green river imp crouched on webbed feet: turtle shell on its back, a water "
                      "dish on the crown ringed with a fringe of dark hair, yellow beak, round eyes, webbed hands.")
    c.shadow(cx, gy - 2, 160, 20)
    c.add("shell", "horn", 1, [E(cx, 250, 150, 150)], tags=("body",))
    c.flat("shell_plates", "chitin_amber", 1.1, [P("hexagon", cx + dx, 250 + dy, 34, 30) for dx, dy in ((-40, -30), (0, -40), (40, -30), (-44, 16), (44, 16))],
           tags=("body",), clip_to="shell", opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "frog", 1.5, [E(cx + k * 44, 318, 50, 56, rot=k * -20), E(cx + k * 52, 352, 50, 18)], tags=("legs",))
        c.add(f"toes_{s}", "frog", 1.6, [P("triangle", cx + k * 52 + d * 12, 360, 10, 12, rot=180) for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "frog", 2, [E(cx, 272, 100, 100)], tags=("body",))
    c.add("belly", "belly", 2.1, [E(cx, 282, 60, 70)], tags=("body",), clip_to="body", opacity=0.7)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "frog", 2.5, [seg(cx + k * 40, 244, cx + k * 62, 290, 16), P("fan", cx + k * 66, 300, 24, 22, rot=180 + k * 20)],
              tags=("arms",))
    c.add("head", "frog", 3, [E(cx, 186, 96, 84)], tags=("head",))
    c.add("hair", "hair", 3.1, [P("mountains", cx, 150, 96, 22, flip="y"), E(cx, 146, 90, 20)], tags=("head",))
    c.add("dish", "water", 3.2, [E(cx, 142, 60, 16)], tags=("head",))
    dot_eyes(c, cx, 184, 22, 16, 18, z=3.3, tags=("head",))
    c.add("beak", "gold", 3.4, [P("droplet", cx, 214, 38, 30, flip="y"), E(cx, 208, 40, 16)], tags=("head",))
    c.flat("beak_line", "mouth", 3.45, [seg(cx - 18, 212, cx + 18, 212, 2.5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="갓파", size="작음")
    return c


@creature("oni", "B")
def oni():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("oni", (W, H), (cx, gy), seed=723,
                 note="Oni, front view. Huge dull-red ogre with two horns, wild black mane, glaring yellow eyes, tusked "
                      "scowl, striped tawny hide loincloth, a studded iron kanabo club held across its shoulders.")
    b = Biped(c, cx, gy, 420, build=1.3, leg=0.37, torso=0.32, head=0.2, shoulder=0.18, hip=0.105, arm_w=0.08,
              leg_w=0.095, arm_len=0.38, stance=1.3, hunch=0.03)
    c.shadow(cx, gy - 2, 290, 32)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("oni_red", foot="claw", z=1, thigh=1.1, shin=1.0, foot_w=1.6)
    c.add("torso", "oni_red", 3, [E(cx, ys + 44, 230, 110), E(cx, yh - 36, 170, 120)], tags=("torso",))
    c.add("loin", "fur_tawny", 3.3, [E(cx, yh + 10, 180, 50), P("bookmark", cx - 30, yh + 50, 60, 60), P("bookmark", cx + 32, yh + 46, 56, 56)],
          tags=("torso",))
    c.flat("stripes", "fur_dark", 3.4, [seg(cx - 70 + i * 28, yh - 8, cx - 62 + i * 28, yh + 44, 7) for i in range(6)], tags=("torso",),
           clip_to="loin", opacity=0.85)
    club_y = ys - 20
    c.add("kanabo", "iron", 3.8, [seg(cx - 200, club_y + 10, cx + 210, club_y - 10, 34), E(cx + 206, club_y - 10, 44, 44)], tags=("club",))
    c.add("studs", "armor", 3.85, [P("triangle", cx - 150 + i * 44, club_y + 4 - i * 2 - 22, 12, 16) for i in range(9)]
          + [P("triangle", cx - 150 + i * 44, club_y + 4 - i * 2 + 22, 12, 16, flip="y") for i in range(9)], tags=("club",))
    for s, k in (("l", -1), ("r", 1)):
        b.arm_to(s, (cx + k * 150, club_y + 4), elbow=(b.sh[s][0] + k * 40, ys + 50))
    b.arm("l", "oni_red", z=4, upper=1.1, fore=1.0, hand=1.3)
    b.arm("r", "oni_red", z=4, upper=1.1, fore=1.0, hand=1.3)
    c.add("mane", "hair", 6.4, [P("cloud", cx, hy0 - 20, 150, 80), P("droplet", cx - 66, hy0 + 20, 36, 70, flip="y", rot=20),
                                P("droplet", cx + 66, hy0 + 20, 36, 70, flip="y", rot=-20)], tags=("head",))
    c.add("horns", "horn", 6.3, [P("cone", cx - 30, hy0 - 60, 24, 50, rot=-16), P("cone", cx + 30, hy0 - 60, 24, 50, rot=16)], tags=("head",))
    c.add("head", "oni_red", 7, [E(cx, hy0, 90, 84), E(cx, hy0 + 24, 96, 52)], tags=("head",))
    c.add("brow", "hair", 7.2, [E(cx - 22, hy0 - 16, 36, 12, rot=18), E(cx + 22, hy0 - 16, 36, 12, rot=-18)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.25, [E(cx - 20, hy0 - 4, 18, 12, rot=14), E(cx + 20, hy0 - 4, 18, 12, rot=-14)], tags=("head",),
           color="glow_yellow_c", strength=0.6, opacity=0.35)
    c.flat("pupils", "eye", 7.3, [E(cx - 20, hy0 - 4, 6, 6), E(cx + 20, hy0 - 4, 6, 6)], tags=("head",))
    c.add("nose", "oni_red", 7.35, [E(cx, hy0 + 14, 28, 20)], tags=("head",))
    c.flat("mouth", "mouth", 7.4, smile(cx, hy0 + 38, 56, 14, frown=True), tags=("head",))
    c.add("tusks", "tooth", 7.5, [P("triangle", cx - 20, hy0 + 30, 9, 18), P("triangle", cx + 20, hy0 + 30, 9, 18)], tags=("head",),
          line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="오니", size="큼")
    return c


@creature("haetae", "B")
def haetae():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("haetae", (W, H), (cx, gy), seed=724,
                 note="Haetae, front view. Seated guardian lion-beast of weathered stone: curling spiral mane, a single "
                      "horn, bulging round eyes, wide fanged grin, scaled chest, bronze bell on a collar, heavy paws.")
    c.shadow(cx, gy - 2, 330, 36)
    c.add("haunches", "stone", 1, [E(cx - 110, 420, 130, 140), E(cx + 110, 420, 130, 140)], tags=("body",))
    c.add("tail", "stone_dark", 0.8, [P("spiral", cx + 170, 330, 80, 80), P("cloud", cx + 160, 290, 70, 40)], tags=("body",))
    c.add("chest", "stone", 2, [E(cx, 370, 200, 200)], tags=("body",))
    c.flat("scales", "stone_dark", 2.1, [P("moon", cx + dx, 340 + dy, 26, 26, rot=-45) for dx in (-40, 0, 40) for dy in (0, 34, 68)],
           tags=("body",), clip_to="chest", opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "stone", 3, [seg(cx + k * 60, 370, cx + k * 66, 460, 56), E(cx + k * 66, 472, 76, 40)], tags=("legs",))
        c.add(f"toes_{s}", "stone_dark", 3.1, [E(cx + k * 66 + d * 20, 486, 18, 12) for d in (-1, 0, 1)], tags=("legs",))
    c.add("collar", "bronze", 3.5, [E(cx, 290, 150, 26)], tags=("body",))
    c.add("bell", "gold", 3.6, [P("bell", cx, 314, 40, 40)], tags=("body",))
    c.add("mane", "stone_dark", 4, [P("spiral", cx + dx, 200 + dy, 50, 50, **({"flip": "x"} if dx < 0 else {})) for dx, dy in
                                    ((-110, 30), (-120, -30), (-80, -80), (-30, -110), (30, -110), (80, -80), (120, -30), (110, 30))]
          + [E(cx, 190, 210, 190)], tags=("head",))
    c.add("head", "stone", 5, [E(cx, 196, 150, 130)], tags=("head",))
    c.add("horn", "horn", 5.1, [P("cone", cx, 112, 26, 44)], tags=("head",))
    c.flat("eye_whites", "eye_white", 5.2, [E(cx - 34, 180, 36, 36), E(cx + 34, 180, 36, 36)], tags=("head",))
    c.flat("pupils", "eye", 5.3, [E(cx - 32, 182, 14, 14), E(cx + 32, 182, 14, 14)], tags=("head",))
    c.add("brows", "stone_dark", 5.35, [E(cx - 36, 158, 44, 14, rot=-12), E(cx + 36, 158, 44, 14, rot=12)], tags=("head",))
    c.add("nose", "stone", 5.4, [E(cx, 210, 50, 30)], tags=("head",))
    c.flat("nostrils", "void", 5.45, [E(cx - 10, 212, 10, 8), E(cx + 10, 212, 10, 8)], tags=("head",))
    c.flat("mouth", "void", 5.5, smile(cx, 244, 110, 30), tags=("head",))
    c.add("fangs", "bone_old", 5.6, fangs(cx - 44, cx + 44, 240, 6, 12), tags=("head",), line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="해태", size="큼")
    return c



# ================================================================ C (idle only)
@creature("imugi", "C")
def imugi():
    W, H = 640, 512
    cx, gy = 320, 494
    c = Creature("imugi", (W, H), (cx, gy), seed=731,
                 note="Imugi, front view. Great legless serpent-dragon of dark river-teal scales coiling up in an S, a "
                      "blunt dragon head with horn nubs, long drooping whiskers and a wispy beard, glowing yellow eyes, pale "
                      "belly plates, a luminous pearl floating near its jaws.")
    c.shadow(cx, gy - 2, 420, 44)
    body = [(cx + 220, 460), (cx - 200, 440), (cx - 120, 300), (cx + 120, 300), (cx + 10, 170)]
    c.add("body", "scale_teal", 1, tube(body, 40, 84, n=36, cap=True, stretch=2.3), tags=("body",))
    c.add("belly", "belly", 1.1, tube(body, 16, 36, n=36, cap=True, stretch=2.3), tags=("body",), clip_to="body", line=False, opacity=0.8)
    c.add("fins", "cloth_blue", 0.9, spikes_on(body, 9, 26, 16, 0.2, 0.9, side=-1), tags=("body",))
    hx, hy = body[-1][0], body[-1][1] - 40
    c.add("head", "scale_teal", 2, [E(hx, hy, 110, 84), E(hx, hy + 28, 84, 50)], tags=("head",))
    c.add("horns", "horn", 1.9, [P("cone", hx - 30, hy - 50, 16, 30, rot=-20), P("cone", hx + 30, hy - 50, 16, 30, rot=20)], tags=("head",))
    c.add("whiskers", "hair", 2.2, tube([(hx - 30, hy + 30), (hx - 70, hy + 34), (hx - 86, hy + 70)], 6, 2, n=8, cap=True)
          + tube([(hx + 30, hy + 30), (hx + 70, hy + 34), (hx + 86, hy + 70)], 6, 2, n=8, cap=True), tags=("head",))
    c.add("beard", "hair", 2.15, [P("droplet", hx, hy + 64, 30, 40, flip="y")], tags=("head",))
    c.glow("eyes", "glow_yellow", 2.3, [E(hx - 26, hy - 8, 18, 11, rot=16), E(hx + 26, hy - 8, 18, 11, rot=-16)], tags=("head",), color="glow_yellow_c",
           strength=0.8, opacity=0.45)
    c.flat("pupils", "eye", 2.35, [E(hx - 26, hy - 8, 4, 10), E(hx + 26, hy - 8, 4, 10)], tags=("head",))
    c.flat("nostrils", "mouth", 2.3, [E(hx - 10, hy + 24, 8, 6), E(hx + 10, hy + 24, 8, 6)], tags=("head",))
    c.flat("mouth", "mouth", 2.3, [seg(hx - 30, hy + 42, hx + 30, hy + 42, 3)], tags=("head",))
    c.glow("pearl", "glow_white", 3, [E(hx + 110, hy + 10, 40, 40)], tags=("fx",), color="lamp_glow", strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="이무기", size="큼")
    return c


@creature("lantern_ghost", "C")
def lantern_ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("lantern_ghost", (W, H), (cx, gy), seed=732,
                 note="Lantern ghost, front view, floating. An old ribbed paper lantern torn open into a grinning mouth "
                      "with a long lolling tongue, one huge glowing eye, lit warmly from inside, black lacquer caps and a "
                      "wire handle.")
    c.shadow(cx, gy - 2, 100, 14, opacity=0.25, blur=7)
    c.add("handle", "iron", 1, [smile(cx, 100, 50, 30, depth=0.8)[0], smile(cx, 100, 50, 30, depth=0.8)[1]], tags=("body",), kind="flat")
    c.add("paper", "paper", 2, [E(cx, 214, 140, 180)], tags=("body",), emit=0.35)
    c.flat("ribs", "foxing", 2.1, [smile(cx, 150 + i * 26, 130 - abs(i - 2.5) * 18, 10, depth=0.5)[0] for i in range(6)], tags=("body",),
           clip_to="paper", opacity=0.45)
    c.add("cap_top", "robe_black", 2.2, [E(cx, 126, 80, 22)], tags=("body",))
    c.add("cap_bot", "robe_black", 2.2, [E(cx, 302, 70, 20)], tags=("body",))
    c.flat("eye_white", "eye_white", 2.4, [E(cx, 180, 56, 44)], tags=("body",))
    c.glow("iris", "glow_red", 2.5, [E(cx, 182, 26, 26)], tags=("body",), color="glow_red_c", strength=1.0, opacity=0.5)
    c.flat("pupil", "eye", 2.55, [E(cx, 182, 8, 18)], tags=("body",))
    c.flat("mouth", "mouth", 2.4, smile(cx, 244, 110, 30, depth=0.35), tags=("body",))
    c.add("tongue", "tongue", 2.6, tube([(cx + 10, 252), (cx + 26, 290), (cx + 6, 330)], 26, 12, n=8, cap=True), tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="초롱 요괴", size="작음")
    return c


@creature("umbrella_ghost", "C")
def umbrella_ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("umbrella_ghost", (W, H), (cx, gy), seed=733,
                 note="Umbrella ghost, front view, hopping. A closed old oil-paper umbrella with ragged wine-red panels "
                      "and bamboo ribs, one big eye, a long tongue hanging out, and a single hairy leg ending in a wooden "
                      "geta sandal.")
    c.shadow(cx, gy - 2, 90, 14)
    c.add("leg", "hide_pink", 1, [seg(cx, 280, cx + 4, 336, 20)], tags=("body",))
    c.add("geta", "wood", 1.1, [P("square", cx + 4, 346, 50, 12), P("square", cx - 10, 358, 8, 14), P("square", cx + 18, 358, 8, 14)], tags=("body",))
    c.add("canopy", "cloth_wine", 2, [P("triangle", cx, 170, 150, 230), E(cx, 270, 110, 40)], tags=("body",))
    c.flat("panels", "bark", 2.1, [seg(cx, 60, cx + d * 60, 280, 3) for d in (-1, -0.5, 0.5, 1)], tags=("body",), clip_to="canopy", opacity=0.6)
    c.add("tears", "cloth_wine", 2.2, [P("mountains", cx, 286, 110, 20, flip="y")], tags=("body",))
    c.add("tip", "bark", 1.9, [seg(cx, 70, cx, 36, 8)], tags=("body",))
    c.flat("eye_white", "eye_white", 2.4, [E(cx, 190, 50, 40)], tags=("body",))
    c.add("iris", "iris", 2.5, [E(cx, 192, 22, 22)], tags=("body",))
    c.flat("pupil", "eye", 2.55, [E(cx, 192, 8, 8)], tags=("body",))
    c.flat("mouth", "mouth", 2.4, smile(cx, 234, 50, 16), tags=("body",))
    c.add("tongue", "tongue", 2.6, tube([(cx, 240), (cx - 18, 270), (cx - 4, 300)], 20, 10, n=8, cap=True), tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="우산 요괴", size="작음")
    return c


@creature("bulgasari", "C")
def bulgasari():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("bulgasari", (W, H), (cx, gy), seed=734,
                 note="Bulgasari (iron-eating beast), front view. Bulky beast of dark iron: bear-like body bristling with "
                      "needle spikes of metal, a short elephant trunk, small rust-red glowing eyes, curved tusks, thick "
                      "tiger-striped legs, a bent iron nail clutched in its trunk.")
    c.shadow(cx, gy - 2, 340, 36)
    c.add("spikes", "armor", 1, spikes_on([(cx - 180, 380), (cx - 150, 190), (cx, 140), (cx + 150, 190), (cx + 180, 380)], 14, 40, 20, 0.0, 1.0, side=-1),
          tags=("body",))
    c.add("body", "iron", 2, [E(cx, 330, 330, 260)], tags=("body",))
    c.flat("stripes", "armor_dark", 2.1, [seg(cx + d * 40, 220 + abs(d) * 10, cx + d * 46, 300, 10) for d in (-3, -2, -1, 1, 2, 3)], tags=("body",),
           clip_to="body", opacity=0.6)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "iron", 3, [seg(cx + k * 90, 400, cx + k * 100, 470, 70), E(cx + k * 100, 476, 90, 34)], tags=("legs",))
        c.add(f"claws_{s}", "armor", 3.1, [P("triangle", cx + k * 100 + d * 22, 492, 10, 16, rot=180) for d in (-1, 0, 1)], tags=("legs",))
    c.add("head", "iron", 4, [E(cx, 220, 150, 120)], tags=("head",))
    c.add("ears", "iron", 3.9, [E(cx - 76, 180, 40, 50), E(cx + 76, 180, 40, 50)], tags=("head",))
    c.glow("eyes", "glow_red", 4.1, [E(cx - 30, 206, 14, 10, rot=14), E(cx + 30, 206, 14, 10, rot=-14)], tags=("head",), color="glow_red_c", strength=0.8, opacity=0.5)
    c.add("tusks", "bone_old", 4.2, [P("moon", cx - 40, 262, 30, 30, rot=-150), P("moon", cx + 40, 262, 30, 30, rot=150, flip="x")], tags=("head",))
    c.add("trunk", "iron", 4.3, tube([(cx, 240), (cx + 6, 290), (cx - 20, 330), (cx - 10, 356)], 40, 22, n=12, cap=True), tags=("head",))
    c.add("nail", "rust", 4.4, [seg(cx - 30, 356, cx + 20, 370, 7), P("square", cx - 32, 356, 16, 6, rot=20)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="불가사리", size="큼")
    return c


@creature("virgin_ghost", "C")
def virgin_ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("virgin_ghost", (W, H), (cx, gy), seed=735,
                 note="Maiden ghost (cheonyeo gwishin), front view, floating. A pale spirit in a long plain white mourning "
                      "dress, long straight black hair hanging over half her face, one dark-ringed glowing eye visible, "
                      "grey hands hanging, the hem fading into mist.")
    c.shadow(cx, gy - 2, 100, 14, opacity=0.25, blur=7)
    c.add("dress", "paper", 2, [P("bell", cx, 244, 130, 230, crop=[1.6, 1.4, 14.4, 11.6]), P("mountains", cx, 356, 130, 30, op="sub")],
          tags=("body",), opacity=0.92)
    c.add("mist", "ghost", 1.9, [P("cloud", cx, 344, 130, 40)], tags=("body",), opacity=0.5, line=False)
    c.add("sleeves", "paper", 2.2, [seg(cx - 40, 150, cx - 56, 230, 30), seg(cx + 40, 150, cx + 56, 230, 30)], tags=("body",), opacity=0.95)
    c.add("hands", "corpse_grey", 2.3, [E(cx - 58, 246, 16, 22), E(cx + 58, 246, 16, 22)], tags=("body",))
    c.add("hair_back", "hair", 2.5, [P("square", cx, 176, 90, 180), E(cx, 104, 92, 60)], tags=("head",))
    c.add("face", "pale", 3, [E(cx, 118, 50, 60)], tags=("head",))
    c.flat("ring", "soot", 3.1, [E(cx + 12, 114, 18, 14)], tags=("head",))
    c.glow("eye", "glow_red", 3.2, [E(cx + 12, 114, 7, 6)], tags=("head",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.flat("mouth", "mouth", 3.1, [seg(cx + 2, 140, cx + 12, 142, 2)], tags=("head",))
    c.add("hair_front", "hair", 3.3, [P("square", cx - 20, 150, 26, 120), P("droplet", cx + 30, 196, 16, 150, flip="y"), E(cx - 8, 92, 60, 24)],
          tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="처녀귀신", size="사람")
    return c
