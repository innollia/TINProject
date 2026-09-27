"""g05-beasts-v01: animals — beasts, birds, reptiles, amphibians (front-view battlers).

Quadrupeds are drawn in a 3/4 front view (head toward the lower left, body going
back to the upper right) because a straight front view of a four-legged animal
reads as a small lump (COMMON.md weakness note on the test hound).  Bears stand up.
"""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, spikes_on, wing_at


def leg3(c, name, pts, w0, w1, mat, z, tags, paw=None, paw_mat=None, claws=0, hidden=False, pivot=None):
    """Three-point animal leg (hip, joint, foot) tapering w0 -> w1, with a paw ellipse and optional claws."""
    (x0, y0), (x1, y1), (x2, y2) = pts
    pieces = [seg(x0, y0, x1, y1, w0), seg(x1, y1, x2, y2, (w0 + w1) / 2)]
    if paw:
        pw, ph = paw
        pieces.append(E(x2 - pw * 0.1, y2 + ph * 0.1, pw, ph))
    extra = {"hidden": True} if hidden else {}
    if pivot:
        extra["pivot"] = list(pivot)
    c.add(name, mat, z, pieces, tags=tags, **extra)
    if claws and paw:
        pw, ph = paw
        cl = [P("triangle", x2 - pw * 0.35 + i * pw * 0.22, y2 + ph * 0.55, pw * 0.14, ph * 0.7, rot=180 + 10) for i in range(claws)]
        c.add(name + "_claws", paw_mat or "claw", z + 0.05, cl, tags=tags, **extra)


# ---------------------------------------------------------------- A: wolf
@creature("wolf", "A")
def wolf():
    W, H = 384, 384
    gy = 366
    c = Creature("wolf", (W, H), (200, gy), seed=801,
                 note="Wolf, 3/4 front view facing the lower left. Lean grey wolf with a pale throat ruff, pricked ears, "
                      "long snout, yellow eyes, bushy tail. attack = pounces forward with forelegs raised and jaws wide; "
                      "hit = thrown back, head flung up yelping, eyes shut.")
    c.shadow(206, gy - 4, 270, 30)
    leg3(c, "leg_hind_far", [(292, 238), (306, 300), (300, 346)], 24, 16, "fur_dark", 1, ("legs", "hind"), paw=(28, 12))
    leg3(c, "leg_front_far", [(170, 246), (176, 304), (172, 346)], 22, 16, "fur_dark", 1, ("legs", "front"), paw=(28, 12),
         pivot=(170, 246))
    c.add("tail", "fur_grey", 1.5, tube([(306, 196), (344, 196), (356, 238)], 30, 12, n=10), tags=("tail",))
    c.add("tail_tip", "fur_white", 1.55, tube([(348, 214), (356, 238)], 16, 8, n=5), tags=("tail",), clip_to="tail", line=False)
    c.add("body", "fur_grey", 2, [E(234, 222, 186, 100, rot=-6), E(160, 232, 96, 104)], tags=("body",))
    c.add("back", "fur_dark", 2.1, [E(246, 196, 150, 40, rot=-6)], tags=("body",), clip_to="body", line=False, opacity=0.7)
    c.add("belly", "fur_white", 2.2, [E(210, 262, 120, 24, rot=-4)], tags=("body",), clip_to="body", line=False, opacity=0.6)
    leg3(c, "leg_hind", [(290, 244), (310, 300), (300, 352)], 34, 22, "fur_grey", 3, ("legs", "hind"), paw=(36, 14), claws=3)
    c.add("thigh", "fur_grey", 3.05, [E(288, 248, 70, 92, rot=-10)], tags=("legs", "hind"))
    leg3(c, "leg_front", [(132, 246), (126, 304), (124, 350)], 32, 22, "fur_grey", 3.1, ("legs", "front"), paw=(38, 15), claws=3,
         pivot=(132, 246))
    c.add("ruff", "fur_white", 3.5, [P("cloud", 142, 222, 92, 70, rot=-10, flip="y")], tags=("head",))
    hp = [150, 214]
    c.add("ear_far", "fur_dark", 3.8, [P("triangle", 140, 126, 26, 44, rot=12)], tags=("head",), pivot=hp)
    c.add("head", "fur_grey", 4, [E(116, 174, 84, 72)], tags=("head",), pivot=hp)
    c.add("ear", "fur_grey", 4.1, [P("triangle", 100, 130, 30, 48, rot=-18)], tags=("head",), pivot=hp)
    c.add("ear_in", "hide_pink", 4.15, [P("triangle", 101, 136, 14, 28, rot=-18)], tags=("head",), line=False, opacity=0.6, pivot=hp)
    c.add("snout", "fur_grey", 4.3, [P("droplet", 86, 200, 40, 70, rot=-128)], tags=("head",), pivot=hp)
    c.add("cheek", "fur_white", 4.35, [P("cloud", 112, 196, 60, 30, rot=-20, flip="y")], tags=("head",), pivot=hp)
    c.add("nose", "eye", 4.5, [E(64, 222, 16, 12, rot=-30)], tags=("head",), pivot=hp)
    c.glow("eyes", "glow_yellow", 4.4, [E(98, 170, 14, 8, rot=20), E(130, 166, 11, 7, rot=10)], tags=("head", "eyes"), color="glow_yellow_c",
           strength=0.7, opacity=0.4, pivot=hp)
    c.flat("pupils", "eye", 4.45, [E(98, 170, 3, 7), E(130, 166, 3, 6)], tags=("head", "eyes"), pivot=hp)
    c.flat("brow", "fur_dark", 4.46, [seg(86, 158, 110, 164, 5), seg(122, 156, 140, 160, 4)], tags=("head",), pivot=hp)
    c.flat("eyes_hit", "eye", 4.45, [seg(88, 168, 108, 172, 3.5), seg(122, 164, 138, 166, 3)], tags=("head", "eyes_hit"), hidden=True, pivot=hp)
    c.flat("mouth", "mouth", 4.4, [seg(72, 224, 110, 214, 3.5)], tags=("head", "mouth"), pivot=hp)
    c.flat("mouth_open", "mouth", 4.25, [P("droplet", 90, 232, 34, 58, rot=-112)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.flat("fangs", "tooth", 4.28, [P("triangle", 80, 222, 6, 12, flip="y"), P("triangle", 96, 218, 6, 11, flip="y"),
                                    P("triangle", 86, 244, 5, 10)], tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    std_frames(
        c,
        attack_move={"front": {"rot": 26, "pivot": [132, 246]}, "head": {"sx": 1.08, "sy": 1.08, "dx": -6, "pivot": hp},
                     "tail": {"rot": -20, "pivot": [306, 196]}, "all": c.whole(rot=-5, dx=-4, dy=-6, pivot=[300, 350])},
        hit_move={"head": {"rot": 24, "pivot": hp}, "front": {"rot": -14, "pivot": [132, 246]}, "tail": {"rot": 24, "pivot": [306, 196]},
                  "all": c.whole(rot=5, dx=10, dy=-4, s=0.96)},
        shadow_hit_dx=6,
    )
    c.meta.update(name_ko="늑대", size="사람")
    return c


# ---------------------------------------------------------------- A: bear
@creature("bear", "A")
def bear():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("bear", (W, H), (cx, gy), seed=802,
                 note="Bear, front view, reared up on its hind legs. Heavy dark-brown bear with round ears, tan muzzle, "
                      "small dark eyes, big clawed paws held up. attack = paws raised high, jaws wide in a roar; hit = "
                      "rocks back, head turned, eyes squeezed.")
    b = Biped(c, cx, gy, 430, build=1.45, leg=0.3, torso=0.36, head=0.2, shoulder=0.16, hip=0.12, arm_w=0.08,
              leg_w=0.11, arm_len=0.34, stance=1.05, hunch=0.02)
    c.shadow(cx, gy - 2, 300, 34)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "fur_brown", 1, [E(cx + k * 70, yh + 40, 110, 130), E(cx + k * 84, gy - 20, 90, 44)], tags=("legs",))
        c.add(f"toes_{s}", "claw", 1.1, [P("triangle", cx + k * 84 + d * 16, gy - 2, 8, 14, rot=180) for d in (-1.5, -0.5, 0.5, 1.5)],
              tags=("legs",))
    c.add("torso", "fur_brown", 3, [E(cx, ys + 80, 250, 230), E(cx, yh + 6, 220, 110)], tags=("torso",))
    c.add("chest", "fur_dark", 3.1, [P("cloud", cx, ys + 60, 150, 70, flip="y")], tags=("torso",), clip_to="torso", opacity=0.7, line=False)
    b.arm_to("l", (cx - 96, ys + 66), elbow=(b.sh["l"][0] - 30, ys + 90))
    b.arm_to("r", (cx + 96, ys + 60), elbow=(b.sh["r"][0] + 30, ys + 86))
    b.arm("l", "fur_brown", z=4, upper=1.3, fore=1.2, hand=1.4, fist=False, claws=0.8)
    b.arm("r", "fur_brown", z=4, upper=1.3, fore=1.2, hand=1.4, fist=False, claws=0.8)
    b.arm_to("l", (b.sh["l"][0] - 60, ys - 80), elbow=(b.sh["l"][0] - 64, ys + 4))
    b.arm("l", "fur_brown", z=4, upper=1.3, fore=1.2, hand=1.5, fist=False, claws=1.0, suffix="_atk", hidden=True, tags=("atk",))
    b.arm_to("r", (b.sh["r"][0] + 60, ys - 76), elbow=(b.sh["r"][0] + 64, ys + 8))
    b.arm("r", "fur_brown", z=4, upper=1.3, fore=1.2, hand=1.5, fist=False, claws=1.0, suffix="_atk", hidden=True, tags=("atk",))
    c.add("ears", "fur_brown", 6.5, [E(cx - 50, hy0 - 38, 40, 38), E(cx + 50, hy0 - 38, 40, 38)], tags=("head",))
    c.add("ears_in", "fur_dark", 6.55, [E(cx - 50, hy0 - 36, 20, 20), E(cx + 50, hy0 - 36, 20, 20)], tags=("head",), line=False)
    c.add("head", "fur_brown", 7, [E(cx, hy0, 120, 104)], tags=("head",))
    c.add("muzzle", "fur_tawny", 7.2, [E(cx, hy0 + 26, 60, 46)], tags=("head",))
    c.add("nose", "eye", 7.4, [E(cx, hy0 + 14, 26, 16)], tags=("head",))
    dot_eyes(c, cx, hy0 - 8, 26, 12, 12, z=7.3, tags=("head", "eyes"))
    c.flat("brows", "fur_dark", 7.35, brows(cx, hy0 - 20, 26, 22, 5, tilt=16), tags=("head",))
    x_eyes(c, cx, hy0 - 8, 26, 7, z=7.35, width=4.5, tags=("head",))
    c.flat("mouth", "mouth", 7.45, smile(cx, hy0 + 38, 24, 7, frown=True), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.45, [E(cx, hy0 + 44, 44, 34)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.5, fangs(cx - 18, cx + 18, hy0 + 30, 4, 10) + fangs(cx - 12, cx + 12, hy0 + 60, 3, 8, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"head": {"rot": -4, "dy": -4, "pivot": [cx, ys]}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 40, "pivot": sl}, "arm_r": {"rot": -30, "pivot": sr}, "head": {"rot": 16, "pivot": [cx, ys]},
                  "all": c.whole(rot=5, dy=-4, s=0.95)},
        shadow_hit_dx=2,
    )
    c.meta.update(name_ko="곰", size="큼")
    return c


# ---------------------------------------------------------------- A: boar
@creature("boar", "A")
def boar():
    W, H = 384, 384
    gy = 366
    c = Creature("boar", (W, H), (200, gy), seed=803,
                 note="Boar, 3/4 front view facing the lower left. Massive bristly dark-brown boar with a spiky mane, "
                      "heavy wedge head, pink snout disc, curved ivory tusks, small red eyes, short legs with hooves. "
                      "attack = charging, head lowered and tusks thrust forward; hit = rears back squealing, eyes shut.")
    c.shadow(206, gy - 4, 280, 32)
    leg3(c, "leg_hind_far", [(296, 262), (304, 314), (300, 346)], 24, 18, "fur_dark", 1, ("legs",), paw=(22, 12))
    leg3(c, "leg_front_far", [(178, 270), (184, 318), (182, 348)], 24, 18, "fur_dark", 1, ("legs", "front"), paw=(22, 12))
    c.add("tail", "fur_brown", 1.5, tube([(320, 212), (340, 222), (344, 244)], 8, 4, n=6) + [P("droplet", 344, 252, 12, 18, flip="y")],
          tags=("tail",))
    c.add("body", "fur_brown", 2, [E(240, 234, 190, 128, rot=-8), E(170, 246, 120, 120)], tags=("body",))
    c.add("mane", "fur_dark", 2.2, spikes_on([(140, 176), (220, 164), (310, 188)], 9, 30, 20, 0.0, 1.0, side=-1), tags=("body",))
    c.add("back", "fur_dark", 2.1, [E(236, 196, 170, 46, rot=-8)], tags=("body",), clip_to="body", line=False, opacity=0.7)
    leg3(c, "leg_hind", [(294, 262), (310, 316), (304, 352)], 32, 22, "fur_brown", 3, ("legs",), paw=(28, 14))
    c.add("thigh", "fur_brown", 3.05, [E(290, 262, 74, 90, rot=-10)], tags=("legs",))
    leg3(c, "leg_front", [(146, 270), (140, 318), (138, 352)], 32, 22, "fur_brown", 3.1, ("legs", "front"), paw=(30, 14),
         pivot=(146, 270))
    c.add("hooves", "horn", 3.2, [P("cylinder", 302, 356, 24, 14), P("cylinder", 136, 356, 26, 14)], tags=("legs",))
    hp = [160, 230]
    c.add("ear_far", "fur_dark", 3.8, [P("triangle", 150, 150, 22, 36, rot=24)], tags=("head",), pivot=hp)
    c.add("head", "fur_brown", 4, [P("droplet", 110, 210, 110, 130, rot=-126), E(134, 196, 84, 78)], tags=("head",), pivot=hp)
    c.add("ear", "fur_brown", 4.1, [P("triangle", 112, 150, 26, 40, rot=-12)], tags=("head",), pivot=hp)
    c.add("snout", "hide_pink", 4.4, [E(62, 250, 36, 30, rot=-30)], tags=("head",), pivot=hp)
    c.flat("nostrils", "mouth", 4.45, [E(56, 250, 6, 8, rot=-30), E(68, 246, 6, 8, rot=-30)], tags=("head",), pivot=hp)
    c.add("tusks", "tooth", 4.5, [P("moon", 70, 262, 26, 26, rot=-160), P("moon", 96, 262, 22, 22, rot=-170)], tags=("head",), pivot=hp,
          line={"width": 0.6, "heavy": 0.5})
    c.glow("eyes", "glow_red", 4.4, [E(106, 196, 10, 7, rot=24), E(134, 188, 8, 6, rot=10)], tags=("head", "eyes"), color="glow_red_c",
           strength=0.7, opacity=0.4, pivot=hp)
    c.flat("brow", "fur_dark", 4.42, [seg(94, 184, 118, 192, 5), seg(128, 180, 142, 184, 4)], tags=("head",), pivot=hp)
    c.flat("eyes_hit", "eye", 4.45, [seg(98, 196, 116, 198, 3.5), seg(128, 190, 140, 190, 3)], tags=("head", "eyes_hit"), hidden=True, pivot=hp)
    c.flat("mouth", "mouth", 4.35, [seg(76, 270, 112, 262, 3)], tags=("head", "mouth"), pivot=hp)
    c.flat("mouth_open", "mouth", 4.3, [E(96, 276, 40, 22, rot=-20)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    std_frames(
        c,
        attack_move={"head": {"rot": -16, "dx": -8, "dy": 18, "pivot": hp}, "front": {"rot": 20, "pivot": [146, 270]},
                     "all": c.whole(rot=-4, dx=-6, dy=6, pivot=[300, 350])},
        hit_move={"head": {"rot": 22, "pivot": hp}, "front": {"rot": -18, "pivot": [146, 270]},
                  "all": c.whole(rot=6, dx=8, dy=-4, s=0.96)},
        shadow_hit_dx=6,
    )
    c.meta.update(name_ko="멧돼지", size="사람")
    return c


# ---------------------------------------------------------------- A: bat
@creature("bat", "A")
def bat():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("bat", (W, H), (cx, gy), seed=804,
                 note="Giant bat, front view, hovering. Dark violet furry body, huge ears, pig-like snout, red glowing "
                      "eyes, needle fangs, broad membrane wings with finger bones, clawed feet. attack = dives with wings "
                      "swept back, mouth wide, feet claws forward; hit = wings crumpled, knocked sideways.")
    c.shadow(cx, gy - 2, 110, 16, opacity=0.3, blur=6)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 20, 186), 118, 60, "membrane", "hide_bat", 1, (f"wing_{s}", "wings"))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "claw", 1.5, [seg(cx + k * 12, 236, cx + k * 16, 262, 5)] + [P("moon", cx + k * 16 + d * 5, 268, 8, 8, rot=-45 + d * 30)
                                                                                     for d in (-1, 1)], tags=("feet",))
    c.add("body", "hide_bat", 2, [E(cx, 208, 62, 76)], tags=("body",))
    c.add("chest", "fur_rat", 2.1, [E(cx, 214, 34, 48)], tags=("body",), clip_to="body", line=False, opacity=0.7)
    c.add("ears", "hide_bat", 2.8, [P("triangle", cx - 28, 124, 34, 60, rot=-18), P("triangle", cx + 28, 124, 34, 60, rot=18)], tags=("head",))
    c.add("ears_in", "hide_pink", 2.85, [P("triangle", cx - 27, 132, 16, 36, rot=-18), P("triangle", cx + 27, 132, 16, 36, rot=18)],
          tags=("head",), line=False, opacity=0.55)
    c.add("head", "hide_bat", 3, [E(cx, 164, 62, 54)], tags=("head",))
    c.add("snout", "snout", 3.2, [E(cx, 172, 22, 16)], tags=("head",))
    c.flat("nostrils", "mouth", 3.25, [E(cx - 4, 172, 4, 5), E(cx + 4, 172, 4, 5)], tags=("head",))
    c.glow("eyes", "glow_red", 3.3, [E(cx - 15, 158, 10, 8, rot=14), E(cx + 15, 158, 10, 8, rot=-14)], tags=("head", "eyes"),
           color="glow_red_c", strength=0.9, opacity=0.5)
    x_eyes(c, cx, 158, 15, 5, z=3.3, width=3.5, tags=("head",))
    c.flat("mouth", "mouth", 3.3, smile(cx, 184, 22, 7), tags=("head", "mouth"))
    c.flat("fang_idle", "tooth", 3.35, [P("triangle", cx - 5, 184, 3, 6, flip="y"), P("triangle", cx + 5, 184, 3, 6, flip="y")],
           tags=("head", "mouth"), line={"width": 0.4, "heavy": 0.3})
    c.flat("mouth_open", "mouth", 3.3, [E(cx, 188, 22, 18)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 3.35, [P("triangle", cx - 6, 183, 4, 8, flip="y"), P("triangle", cx + 6, 183, 4, 8, flip="y")],
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    wl, wr = [cx - 20, 186], [cx + 20, 186]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 30, "pivot": wl}, "wing_r": {"rot": -30, "pivot": wr}, "feet": {"dy": -10, "sy": 0.8, "pivot": [cx, 236]},
                     "all": c.whole(s=1.08, dy=26)},
        shadow_attack={"sx": 1.2, "sy": 1.2, "pivot": [cx, gy - 2]},
        hit_move={"wing_l": {"rot": -40, "pivot": wl}, "wing_r": {"rot": 16, "pivot": wr}, "head": {"rot": 14, "pivot": [cx, 190]},
                  "all": c.whole(rot=8, dx=0, dy=-10, s=0.9)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="박쥐", size="작음")
    return c


# ---------------------------------------------------------------- A: rat
@creature("rat", "A")
def rat():
    W, H = 320, 384
    gy = 366
    c = Creature("rat", (W, H), (164, gy), seed=805,
                 note="Giant rat, 3/4 front view facing the lower left. Plump grey-brown rat crouched to spring, pink "
                      "ears, paws and long scaly tail, beady red eyes, buck teeth, whiskers. attack = rears up lunging with "
                      "forepaws out and mouth open; hit = flinches back, ears flat, eyes squeezed.")
    c.shadow(170, gy - 4, 200, 24)
    c.add("tail", "hide_pink", 0.8, tube([(236, 330), (290, 352), (300, 300), (270, 262)], 16, 5, n=16), tags=("tail",))
    leg3(c, "leg_far", [(214, 300), (226, 336), (222, 356)], 18, 12, "fur_rat", 1, ("legs",), paw=(22, 10))
    c.add("body", "fur_rat", 2, [E(200, 292, 150, 120, rot=-12), E(146, 286, 90, 90)], tags=("body",))
    c.add("belly", "fur_white", 2.1, [E(160, 318, 90, 40, rot=-8)], tags=("body",), clip_to="body", line=False, opacity=0.55)
    c.add("haunch", "fur_rat", 2.5, [E(226, 316, 70, 80, rot=-10)], tags=("legs",))
    c.add("hindfoot", "hide_pink", 2.6, [E(228, 356, 44, 14)], tags=("legs",))
    for s, (x, y) in (("l", (118, 344)), ("r", (160, 350))):
        c.add(f"paw_{s}", "hide_pink", 3, [E(x, y, 22, 14)] + [seg(x - 6 + i * 6, y + 4, x - 8 + i * 6, y + 12, 2.5, ext=0.1) for i in range(3)],
              tags=("paws",))
        c.add(f"foreleg_{s}", "fur_rat", 2.9, [seg(x + 6, y - 40, x, y - 6, 16)], tags=("paws",))
    hp = [150, 280]
    c.add("ear_far", "hide_pink", 3.6, [E(158, 206, 34, 38)], tags=("head",), pivot=hp)
    c.add("head", "fur_rat", 4, [P("droplet", 112, 256, 76, 110, rot=-122), E(140, 240, 70, 64)], tags=("head",), pivot=hp)
    c.add("ear", "fur_rat", 4.1, [E(118, 204, 42, 46)], tags=("head",), pivot=hp)
    c.add("ear_in", "hide_pink", 4.15, [E(118, 206, 28, 32)], tags=("head",), line=False, pivot=hp)
    c.add("nose", "hide_pink", 4.3, [E(66, 290, 16, 12, rot=-30)], tags=("head",), pivot=hp)
    c.glow("eyes", "glow_red", 4.3, [E(110, 244, 9, 9), E(136, 236, 7, 7)], tags=("head", "eyes"), color="glow_red_c", strength=0.8,
           opacity=0.45, pivot=hp)
    c.flat("eyes_hit", "eye", 4.35, [seg(104, 244, 116, 246, 3), seg(132, 237, 140, 238, 2.5)], tags=("head", "eyes_hit"), hidden=True, pivot=hp)
    c.flat("whiskers", "eye", 4.35, [seg(84, 280, 44, 270, 1.4), seg(86, 284, 44, 290, 1.4), seg(92, 276, 60, 256, 1.4)],
           tags=("head",), pivot=hp, opacity=0.8)
    c.add("teeth", "tooth", 4.4, [P("square", 82, 304, 8, 12, rot=-20), P("square", 90, 302, 8, 12, rot=-20)], tags=("head", "mouth"),
          pivot=hp, line={"width": 0.5, "heavy": 0.4})
    c.flat("mouth_open", "mouth", 4.35, [E(92, 306, 26, 18, rot=-24)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.add("teeth_open", "tooth", 4.4, [P("square", 84, 298, 8, 12, rot=-20), P("square", 92, 296, 8, 12, rot=-20)], tags=("head", "mouth_open"),
          hidden=True, pivot=hp, line={"width": 0.5, "heavy": 0.4})
    std_frames(
        c,
        attack_move={"paws": {"rot": 50, "dy": -30, "pivot": [150, 300]}, "head": {"sx": 1.08, "sy": 1.08, "pivot": hp},
                     "all": c.whole(rot=-8, dx=-4, pivot=[240, 356])},
        hit_move={"head": {"rot": 20, "pivot": hp}, "tail": {"rot": 10, "pivot": [236, 330]}, "all": c.whole(rot=6, dx=10, dy=-4, s=0.95)},
        shadow_hit_dx=6,
    )
    c.meta.update(name_ko="쥐", size="작음")
    return c


# ---------------------------------------------------------------- A: snake
@creature("snake", "A")
def snake():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("snake", (W, H), (cx, gy), seed=806,
                 note="Snake, front view. Olive-scaled snake coiled on the ground, neck raised in an S with the head "
                      "facing the viewer, pale belly scales, yellow slit eyes, forked tongue. attack = head strikes forward "
                      "(bigger, lower) with jaws open and fangs out; hit = head snaps back and up, eyes shut.")
    c.shadow(cx, gy - 2, 220, 26)
    c.add("coil_3", "scale_olive", 1, [E(cx, 340, 220, 58)], tags=("coils",))
    c.add("coil_2", "scale_olive", 1.2, [E(cx + 8, 314, 180, 50)], tags=("coils",))
    c.add("coil_1", "scale_olive", 1.4, [E(cx - 4, 290, 140, 44)], tags=("coils",))
    c.add("coil_belly", "belly", 1.5, [E(cx, 356, 170, 20), E(cx + 8, 328, 140, 16)], tags=("coils",), clip_to="coil_3", line=False, opacity=0.6)
    c.add("tail", "scale_olive", 0.8, tube([(cx + 100, 348), (cx + 136, 340), (cx + 140, 316)], 20, 5, n=8), tags=("coils",))
    neck = [(cx + 10, 286), (cx + 44, 236), (cx - 14, 200), (cx, 158)]
    c.add("neck", "scale_olive", 2, tube(neck, 44, 36, n=14), tags=("neck", "head"))
    c.add("neck_belly", "belly", 2.1, tube(neck, 22, 18, n=14), tags=("neck", "head"), clip_to="neck", line=False)
    hp = [cx + 10, 286]
    c.add("head", "scale_olive", 3, [E(cx, 138, 70, 52), E(cx, 156, 50, 36)], tags=("head",), pivot=hp)
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 20, 132, 14, 11, rot=14), E(cx + 20, 132, 14, 11, rot=-14)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.6, opacity=0.35, pivot=hp)
    c.flat("pupils", "eye", 3.25, [E(cx - 20, 132, 3, 10), E(cx + 20, 132, 3, 10)], tags=("head", "eyes"), pivot=hp)
    c.flat("eyes_hit", "eye", 3.25, [seg(cx - 28, 132, cx - 12, 134, 3), seg(cx + 12, 134, cx + 28, 132, 3)], tags=("head", "eyes_hit"),
           hidden=True, pivot=hp)
    c.flat("nostrils", "eye", 3.2, [E(cx - 6, 154, 4, 3), E(cx + 6, 154, 4, 3)], tags=("head",), pivot=hp)
    c.flat("mouth", "mouth", 3.2, [seg(cx - 20, 166, cx + 20, 166, 2.5)], tags=("head", "mouth"), pivot=hp)
    c.add("tongue", "tongue", 3.3, [seg(cx, 166, cx, 188, 4), seg(cx, 186, cx - 7, 198, 3), seg(cx, 186, cx + 7, 198, 3)],
          tags=("head", "mouth"), pivot=hp)
    c.flat("mouth_open", "mouth", 3.2, [E(cx, 176, 48, 38)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.flat("fangs", "tooth", 3.3, [P("triangle", cx - 12, 166, 5, 14, flip="y"), P("triangle", cx + 12, 166, 5, 14, flip="y")],
           tags=("head", "mouth_open"), hidden=True, pivot=hp, line={"width": 0.4, "heavy": 0.3})
    c.add("tongue_open", "tongue", 3.35, [seg(cx, 184, cx, 206, 4), seg(cx, 204, cx - 7, 216, 3), seg(cx, 204, cx + 7, 216, 3)],
          tags=("head", "mouth_open"), hidden=True, pivot=hp)
    std_frames(
        c,
        attack_move={"head": {"sx": 1.18, "sy": 1.18, "dy": 36, "pivot": hp}, "all": c.whole(s=1.02)},
        hit_move={"head": {"rot": 16, "dx": 10, "dy": -12, "pivot": hp}, "all": c.whole(rot=4, s=0.97)},
        shadow_hit_dx=0,
    )
    c.meta.update(name_ko="뱀", size="작음")
    return c


# ---------------------------------------------------------------- A: crow
@creature("crow", "A")
def crow():
    W, H = 320, 384
    gy = 366
    c = Creature("crow", (W, H), (164, gy), seed=807,
                 note="Crow, 3/4 front view facing the lower left. Big black-violet crow standing on thin legs, sheen on "
                      "the feathers, heavy dark beak, bright bead eye, fanned tail. attack = wings flung open, beak gaping "
                      "and lunging to peck; hit = feathers ruffled, knocked back, eye shut.")
    c.shadow(170, gy - 4, 150, 20)
    c.add("tail", "feather_black", 1, [P("feather", 232, 300, 50, 90, rot=150), P("feather", 250, 290, 44, 84, rot=130),
                                       P("feather", 216, 306, 44, 80, rot=170)], tags=("tail",))
    for s, x in (("l", 150), ("r", 186)):
        c.add(f"leg_{s}", "claw", 1.5, [seg(x, 300, x - 4, 350, 6)] + [seg(x - 4, 350, x - 4 + d * 10, 360, 4, ext=0.1) for d in (-1.2, 0, 1)],
              tags=("legs",))
    for s, k in (("l", -1), ("r", 1)):
        root = (164 + k * 20, 214)
        c.add(f"wing_{s}_atk", "feather_black", 1.2, [wing_at(root, 150, 128, s, rot=k * -26)], tags=("atk",), hidden=True)
    c.add("body", "feather_black", 2, [E(172, 260, 110, 118, rot=-10), P("droplet", 196, 292, 60, 80, rot=150)], tags=("body",))
    c.add("wing_fold", "feather_black", 2.5, [P("wing", 206, 258, 96, 80, rot=70, fit="box")], tags=("wing",))
    c.add("sheen", "crystal", 2.6, [E(150, 236, 50, 26, rot=-20)], tags=("body",), clip_to="body", line=False, opacity=0.25)
    hp = [160, 240]
    c.add("head", "feather_black", 3, [E(142, 184, 70, 66)], tags=("head",), pivot=hp)
    c.add("beak", "claw", 3.2, [P("droplet", 104, 200, 26, 58, rot=-118), P("droplet", 110, 206, 18, 40, rot=-110)], tags=("head", "mouth"),
          pivot=hp)
    c.add("beak_up", "claw", 3.2, [P("droplet", 102, 190, 24, 56, rot=-128)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.add("beak_down", "claw", 3.1, [P("droplet", 112, 216, 16, 40, rot=-96)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.flat("gape", "mouth", 3.05, [E(116, 206, 22, 14, rot=-20)], tags=("head", "mouth_open"), hidden=True, pivot=hp)
    c.flat("eye_ring", "eye", 3.3, [E(136, 176, 16, 16)], tags=("head", "eyes"), pivot=hp)
    c.flat("eye_glint", "eye_white", 3.35, [E(133, 173, 5, 5)], tags=("head", "eyes"), pivot=hp)
    c.flat("eyes_hit", "eye", 3.3, [seg(128, 177, 144, 177, 3.5)], tags=("head", "eyes_hit"), hidden=True, pivot=hp)
    std_frames(
        c,
        attack_move={"head": {"rot": -18, "dx": -8, "dy": 10, "pivot": hp}, "all": c.whole(rot=-6, dx=-4, pivot=[190, 356])},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "wing"),
        hit_move={"head": {"rot": 20, "pivot": hp}, "tail": {"rot": 16, "pivot": [210, 290]}, "wing": {"rot": -24, "pivot": [196, 230]},
                  "all": c.whole(rot=8, dx=10, dy=-6, s=0.95)},
        shadow_hit_dx=6,
    )
    c.meta.update(name_ko="까마귀", size="작음")
    return c
