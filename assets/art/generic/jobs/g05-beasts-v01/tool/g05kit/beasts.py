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
from .parts import bat_wing, bones_limb, claw_hand, leg3, spikes_on, wing_at


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


# ================================================================ B (idle only)
def quad_3q(c, mat, dark, light, body, head, legs, tail=None, ears=None, snout=None, eye_mat="glow_yellow", eye_c="glow_yellow_c",
            eye_glow=0.5, nose=True, extra_z=4.0):
    """Generic 3/4-front quadruped (facing lower left).  body=(x, y, w, h), head=(x, y, w, h),
    legs: list of (hip, knee, foot, width, z).  Returns the head pivot."""
    bx, by, bw, bh = body
    for i, (hip, knee, foot, w, z) in enumerate(legs):
        leg3(c, f"leg_{i}", [hip, knee, foot], w, w * 0.7, mat if z >= 2 else dark, z, ("legs",), paw=(w * 1.2, w * 0.5))
    if tail:
        c.add("tail", mat, 1.4, tube(tail, 20, 8, n=10, cap=True), tags=("tail",))
    c.add("body", mat, 2, [E(bx, by, bw, bh, -6), E(bx - bw * 0.36, by + bh * 0.08, bw * 0.5, bh * 1.02)], tags=("body",))
    if light:
        c.add("belly", light, 2.1, [E(bx - bw * 0.05, by + bh * 0.36, bw * 0.7, bh * 0.24, -4)], tags=("body",), clip_to="body",
              line=False, opacity=0.6)
    hx, hy, hw, hh = head
    hp = [hx + hw * 0.4, hy + hh * 0.6]
    if ears:
        for j, (ex, ey, ew, eh, rot) in enumerate(ears):
            c.add(f"ear_{j}", mat if j else dark, extra_z - 0.2 + j * 0.3, [P("triangle", ex, ey, ew, eh, rot=rot)], tags=("head",))
    c.add("head", mat, extra_z, [E(hx, hy, hw, hh)], tags=("head",))
    if snout:
        sx, sy, sw, sh, srot = snout
        c.add("snout", mat, extra_z + 0.2, [P("droplet", sx, sy, sw, sh, rot=srot)], tags=("head",))
    return hp


@creature("dog", "B")
def dog():
    W, H = 320, 384
    gy = 366
    c = Creature("dog", (W, H), (168, gy), seed=821,
                 note="Dog, 3/4 front view facing the lower left. Scruffy brown street dog with floppy ears, pale muzzle "
                      "and chest, worn leather collar with a tag, tail up, alert eyes.")
    c.shadow(172, gy - 4, 220, 26)
    quad_3q(c, "fur_brown", "fur_dark", "fur_white", (196, 268, 150, 86), (106, 214, 70, 64),
            [((244, 286), (256, 326), (250, 352), 20, 1), ((138, 290), (144, 328), (142, 352), 18, 1),
             ((246, 292), (262, 330), (256, 356), 26, 3), ((116, 292), (110, 330), (108, 356), 24, 3.1)],
            tail=[(262, 250), (292, 230), (298, 196)], extra_z=4)
    c.add("ears", "fur_dark", 4.3, [P("droplet", 82, 206, 22, 44, flip="y", rot=30), P("droplet", 132, 196, 20, 40, flip="y", rot=-10)], tags=("head",))
    c.add("muzzle", "fur_white", 4.25, [P("droplet", 80, 236, 34, 50, rot=-120)], tags=("head",))
    c.add("nose", "eye", 4.4, [E(62, 250, 14, 10)], tags=("head",))
    dot_eyes(c, 104, 206, 14, 9, 10, z=4.35, tags=("head",))
    c.add("collar", "leather", 3.5, [E(128, 250, 60, 14, rot=-30)], tags=("head",))
    c.add("tag", "gold", 3.6, [E(118, 262, 10, 12)], tags=("head",))
    c.add("chest", "fur_white", 3.4, [P("cloud", 120, 274, 50, 40, rot=-20, flip="y")], tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="개", size="작음")
    return c


@creature("cat", "B")
def cat():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("cat", (W, H), (cx, gy), seed=822,
                 note="Cat, front view, sitting. Sleek black-grey cat with a curled tail, tall pointed ears, glowing "
                      "yellow eyes with slit pupils, small pink nose, white whiskers, a wine ribbon with a tiny bell.")
    c.shadow(cx, gy - 2, 150, 20)
    c.add("tail", "fur_dark", 0.8, tube([(cx + 40, 346), (cx + 100, 340), (cx + 110, 280), (cx + 86, 250)], 22, 10, n=12, cap=True), tags=("tail",))
    c.add("body", "fur_dark", 1, [P("droplet", cx, 290, 120, 150), E(cx, 330, 130, 70)], tags=("body",))
    c.add("chest", "fur_grey", 1.1, [P("droplet", cx, 290, 50, 90, flip="y")], tags=("body",), clip_to="body", opacity=0.6, line=False)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "fur_dark", 1.5, [seg(cx + k * 20, 290, cx + k * 22, 352, 22), E(cx + k * 24, 356, 30, 16)], tags=("legs",))
    c.add("ribbon", "cloth_wine", 2, [E(cx, 236, 70, 12)], tags=("head",))
    c.add("bell", "gold", 2.1, [E(cx, 248, 14, 14)], tags=("head",))
    c.add("ears", "fur_dark", 2.8, [P("triangle", cx - 26, 164, 30, 44, rot=-14), P("triangle", cx + 26, 164, 30, 44, rot=14)], tags=("head",))
    c.add("ears_in", "hide_pink", 2.85, [P("triangle", cx - 25, 170, 14, 24, rot=-14), P("triangle", cx + 25, 170, 14, 24, rot=14)],
          tags=("head",), line=False, opacity=0.5)
    c.add("head", "fur_dark", 3, [E(cx, 200, 84, 70)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 17, 196, 18, 14, rot=10), E(cx + 17, 196, 18, 14, rot=-10)], tags=("head",), color="glow_yellow_c",
           strength=0.7, opacity=0.4)
    c.flat("pupils", "eye", 3.25, [E(cx - 17, 196, 4, 12), E(cx + 17, 196, 4, 12)], tags=("head",))
    c.add("nose", "hide_pink", 3.3, [P("triangle", cx, 212, 10, 7, flip="y")], tags=("head",))
    c.flat("mouth", "mouth", 3.3, [seg(cx, 216, cx - 6, 222, 1.8), seg(cx, 216, cx + 6, 222, 1.8)], tags=("head",))
    c.flat("whiskers", "fur_white", 3.4, [seg(cx - 12, 214, cx - 50, 206, 1.4), seg(cx - 12, 218, cx - 50, 222, 1.4),
                                          seg(cx + 12, 214, cx + 50, 206, 1.4), seg(cx + 12, 218, cx + 50, 222, 1.4)], tags=("head",), opacity=0.8)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="고양이", size="작음")
    return c


@creature("horse", "B")
def horse():
    W, H = 512, 512
    gy = 494
    c = Creature("horse", (W, H), (260, gy), seed=823,
                 note="Horse, 3/4 front view facing the lower left. Dark bay horse with black mane and tail, pale blaze on "
                      "the face, leather bridle and a worn western saddle with a blanket, hooves.")
    c.shadow(270, gy - 4, 360, 40)
    legs = [((356, 330), (368, 400), (362, 470), 30, 1), ((200, 330), (206, 400), (204, 470), 28, 1),
            ((354, 336), (378, 404), (370, 476), 38, 3), ((168, 336), (160, 404), (158, 476), 36, 3.1)]
    for i, (hip, knee, foot, w, z) in enumerate(legs):
        leg3(c, f"leg_{i}", [hip, knee, foot], w, w * 0.62, "fur_brown" if z >= 2 else "fur_dark", z, ("legs",))
        c.add(f"hoof_{i}", "horn", z + 0.05, [P("cylinder", foot[0], foot[1] + 8, w * 0.9, w * 0.6)], tags=("legs",))
    c.add("tail", "hair", 1.4, tube([(392, 262), (430, 290), (430, 380)], 36, 16, n=10, cap=True), tags=("tail",))
    c.add("body", "fur_brown", 2, [E(290, 290, 230, 120, -6), E(196, 300, 110, 120)], tags=("body",))
    c.add("blanket", "cloth_wine", 2.3, [P("square", 290, 280, 100, 80, rot=-6)], tags=("body",), clip_to="body")
    c.add("saddle", "leather", 2.5, [E(290, 256, 90, 40, -6), P("square", 292, 290, 20, 60)], tags=("body",))
    c.add("horn_s", "leather", 2.55, [E(258, 238, 16, 22)], tags=("body",))
    c.add("neck", "fur_brown", 3.5, tube([(190, 280), (160, 220), (136, 170)], 90, 60, n=8, cap=True), tags=("head",))
    c.add("mane", "hair", 3.6, tube([(212, 262), (184, 200), (160, 150)], 30, 20, n=8, cap=True), tags=("head",))
    c.add("head", "fur_brown", 4, [P("droplet", 110, 184, 70, 130, rot=-150), E(132, 150, 64, 56)], tags=("head",))
    c.add("ear", "fur_brown", 3.9, [P("triangle", 144, 108, 18, 34, rot=10), P("triangle", 126, 112, 16, 30, rot=-10)], tags=("head",))
    c.add("blaze", "fur_white", 4.1, [P("droplet", 106, 190, 18, 80, rot=-150)], tags=("head",), clip_to="head", opacity=0.8)
    c.add("bridle", "leather", 4.2, [seg(92, 212, 146, 180, 5), seg(120, 148, 146, 180, 5)], tags=("head",))
    dot_eyes(c, 128, 156, 12, 9, 11, z=4.3, tags=("head",))
    c.flat("nostril", "mouth", 4.3, [E(80, 232, 8, 6, rot=-30)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="말", size="큼")
    return c


@creature("giant_frog", "B")
def giant_frog():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("giant_frog", (W, H), (cx, gy), seed=824,
                 note="Giant frog, front view, squatting. Warty mottled green toad with bulging golden eyes on top, a huge "
                      "wide mouth, pale throat sac, splayed front feet and folded hind legs at the sides.")
    c.shadow(cx, gy - 2, 300, 34)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"hind_{s}", "frog", 1, [E(cx + k * 110, 316, 110, 90, rot=k * -20), E(cx + k * 130, 352, 90, 24)], tags=("legs",))
        c.add(f"hindtoes_{s}", "frog", 1.1, [E(cx + k * (130 + d * 20), 360, 16, 12) for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "frog", 2, [E(cx, 280, 250, 170)], tags=("body",))
    c.add("throat", "belly", 2.2, [E(cx, 318, 150, 70)], tags=("body",), clip_to="body")
    c.flat("warts", "leaf_dark", 2.3, [E(cx + dx, 250 + dy, 14, 11) for dx, dy in ((-90, 0), (-60, -30), (70, -24), (96, 10), (-100, 40), (104, 46))],
           tags=("body",), clip_to="body", opacity=0.6)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"front_{s}", "frog", 3, [seg(cx + k * 60, 320, cx + k * 70, 352, 26)] + [E(cx + k * 70 + d * 14, 360, 16, 12) for d in (-1, 0, 1)],
              tags=("legs",))
    c.flat("mouth", "mouth", 3.2, smile(cx, 290, 200, 24, depth=0.35), tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"eye_{s}", "frog", 3.4, [E(cx + k * 70, 196, 70, 66)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.5, [E(cx - 70, 196, 46, 42), E(cx + 70, 196, 46, 42)], tags=("head",), color="glow_yellow_c",
           strength=0.35, opacity=0.25)
    c.flat("pupils", "eye", 3.55, [E(cx - 70, 198, 30, 12), E(cx + 70, 198, 30, 12)], tags=("head",))
    c.flat("nostrils", "mouth", 3.3, [E(cx - 14, 244, 7, 5), E(cx + 14, 244, 7, 5)], tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 개구리", size="사람")
    return c


@creature("vulture", "B")
def vulture():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("vulture", (W, H), (cx, gy), seed=825,
                 note="Vulture, front view, hunched on the ground with wings half spread. Dusty dark-brown plumage, a pale "
                      "ruff around a bare wrinkled pink neck and head, heavy hooked beak, beady eyes, grey scaly legs.")
    c.shadow(cx, gy - 2, 240, 26)
    for s, k in (("l", -1), ("r", 1)):
        root = (cx + k * 30, 190)
        c.add(f"wing_{s}", "feather_brown", 1, [wing_at(root, 176, 150, s, rot=k * 30)], tags=("wings",))
        c.add(f"wing_{s}_tips", "feather_black", 1.1, [wing_at(root, 176, 150, s, rot=k * 30, tips=True)], tags=("wings",), clip_to=f"wing_{s}",
              line={"width": 0.7, "heavy": 0.5})
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "horn", 1.5, [seg(cx + k * 20, 300, cx + k * 24, 350, 12)] + [seg(cx + k * 24, 350, cx + k * 24 + d * 14, 362, 6, ext=0.1)
                                                                                    for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "feather_brown", 2, [P("droplet", cx, 250, 130, 150, flip="y"), E(cx, 226, 130, 90)], tags=("body",))
    c.add("ruff", "feather_pale", 3, [P("cloud", cx, 176, 110, 50), E(cx, 184, 100, 40)], tags=("head",))
    c.add("neck", "hide_pink", 3.2, [seg(cx, 176, cx - 4, 130, 26)], tags=("head",))
    c.add("head", "hide_pink", 3.4, [E(cx - 4, 118, 50, 44)], tags=("head",))
    dot_eyes(c, cx - 4, 112, 13, 7, 8, z=3.5, tags=("head",))
    c.add("beak", "horn", 3.6, [P("droplet", cx - 4, 140, 22, 40, flip="y"), P("moon", cx - 6, 150, 16, 16, rot=135)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="대머리수리", size="사람")
    return c


# ================================================================ C (idle only)
@creature("bat_swarm", "C")
def bat_swarm():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("bat_swarm", (W, H), (cx, gy), seed=831,
                 note="Bat swarm, front view. A cloud of seven small dark bats of different sizes flapping at different "
                      "angles, tiny red eyes, one bat in front larger than the rest.")
    c.shadow(cx, gy - 2, 200, 22, opacity=0.25, blur=8)
    bats = [(cx - 96, 120, 0.55, -14), (cx + 90, 104, 0.5, 12), (cx - 20, 90, 0.45, 4), (cx + 108, 220, 0.6, 18),
            (cx - 108, 240, 0.6, -20), (cx + 40, 270, 0.65, -8), (cx - 10, 190, 0.9, 0)]
    for i, (x, y, s, r) in enumerate(bats):
        z = 1 + i * 0.1
        for side, k in (("l", -1), ("r", 1)):
            bat_wing(c, f"b{i}_w{side}", side, (x + k * 10 * s, y), 90 * s, 40 * s, "membrane", "hide_bat", z, ("swarm",))
        c.add(f"b{i}_body", "hide_bat", z + 0.05, [E(x, y + 6 * s, 30 * s, 40 * s), E(x, y - 16 * s, 30 * s, 26 * s)]
              + [P("triangle", x + k * 9 * s, y - 32 * s, 10 * s, 18 * s, rot=k * 16) for k in (-1, 1)], tags=("swarm",))
        c.glow(f"b{i}_eyes", "glow_red", z + 0.06, [E(x - 5 * s, y - 16 * s, 5 * s, 4 * s), E(x + 5 * s, y - 16 * s, 5 * s, 4 * s)], tags=("swarm",),
               color="glow_red_c", strength=0.9, opacity=0.4)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="박쥐 떼", size="사람")
    return c


@creature("frog", "C")
def frog():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("frog", (W, H), (cx, gy), seed=832,
                 note="Frog, front view, sitting. Small dark olive frog with bulging copper eyes, a wide smiling mouth, "
                      "pale throat, spotted back and splayed webbed toes.")
    c.shadow(cx, gy - 2, 180, 22)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"hind_{s}", "frog", 1, [E(cx + k * 66, 330, 70, 52, rot=k * -20), E(cx + k * 80, 356, 56, 16)], tags=("legs",))
    c.add("body", "frog", 2, [E(cx, 306, 150, 110)], tags=("body",))
    c.add("throat", "belly", 2.1, [E(cx, 332, 90, 44)], tags=("body",), clip_to="body")
    c.flat("spots", "leaf_dark", 2.2, [E(cx + dx, 290 + dy, 12, 9) for dx, dy in ((-50, -4), (50, -8), (-60, 26), (64, 24))], tags=("body",), clip_to="body")
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"front_{s}", "frog", 3, [seg(cx + k * 36, 330, cx + k * 44, 354, 16)] + [E(cx + k * 44 + d * 9, 360, 10, 8) for d in (-1, 0, 1)], tags=("legs",))
        c.add(f"eye_{s}", "frog", 3.4, [E(cx + k * 42, 250, 44, 42)], tags=("head",))
    c.glow("eyes", "ember", 3.5, [E(cx - 42, 250, 30, 28), E(cx + 42, 250, 30, 28)], tags=("head",), color="ember_glow", strength=0.3, opacity=0.2)
    c.flat("pupils", "eye", 3.55, [E(cx - 42, 252, 20, 8), E(cx + 42, 252, 20, 8)], tags=("head",))
    c.flat("mouth", "mouth", 3.2, smile(cx, 312, 110, 14, depth=0.4), tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="개구리", size="작음")
    return c


@creature("crocodile", "C")
def crocodile():
    W, H = 640, 512
    gy = 494
    c = Creature("crocodile", (W, H), (330, gy), seed=833,
                 note="Crocodile, 3/4 front view facing the lower left. Long armoured olive-dark crocodile low to the "
                      "ground: ridged back scutes, a long toothy snout slightly open, yellow eyes on top of the head, "
                      "splayed clawed legs, thick tail sweeping back.")
    c.shadow(330, gy - 4, 520, 50)
    c.add("tail", "scale_olive", 1, tube([(440, 380), (540, 360), (600, 300)], 80, 16, n=12, cap=True), tags=("body",))
    leg3(c, "leg_far_h", [(420, 400), (450, 430), (440, 460)], 34, 22, "scale_green", 1.2, ("legs",), paw=(40, 14), claws=3)
    leg3(c, "leg_far_f", [(260, 410), (270, 440), (260, 466)], 32, 22, "scale_green", 1.2, ("legs",), paw=(40, 14), claws=3)
    c.add("body", "scale_olive", 2, [E(360, 400, 260, 110, rot=-10), E(250, 420, 150, 100)], tags=("body",))
    c.add("scutes", "scale_green", 2.1, spikes_on([(200, 370), (330, 340), (470, 350)], 10, 22, 18, 0.0, 1.0, side=-1), tags=("body",))
    leg3(c, "leg_h", [(420, 420), (460, 450), (450, 476)], 40, 26, "scale_olive", 3, ("legs",), paw=(48, 16), claws=3)
    leg3(c, "leg_f", [(220, 430), (200, 456), (196, 478)], 40, 26, "scale_olive", 3.1, ("legs",), paw=(50, 16), claws=3)
    c.add("jaw_low", "belly", 3.4, [P("droplet", 118, 452, 44, 170, rot=-112)], tags=("head",))
    c.flat("mouth", "mouth", 3.45, [P("droplet", 116, 438, 30, 150, rot=-112)], tags=("head",))
    c.add("teeth", "tooth", 3.5, [P("triangle", 60 + i * 16, 434 - i * 5, 7, 12, flip="y") for i in range(8)]
          + [P("triangle", 64 + i * 16, 448 - i * 5, 6, 10) for i in range(7)], tags=("head",), line={"width": 0.4, "heavy": 0.3})
    c.add("snout", "scale_olive", 3.6, [P("droplet", 124, 420, 56, 190, rot=-116), E(200, 404, 100, 70)], tags=("head",))
    c.add("eye_bumps", "scale_olive", 3.7, [E(186, 376, 30, 24), E(222, 372, 26, 22)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.8, [E(186, 374, 14, 9), E(222, 370, 12, 8)], tags=("head",), color="glow_yellow_c", strength=0.6, opacity=0.35)
    c.flat("pupils", "eye", 3.85, [E(186, 374, 3, 8), E(222, 370, 3, 7)], tags=("head",))
    c.flat("nostrils", "mouth", 3.8, [E(44, 452, 6, 4), E(54, 446, 6, 4)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="악어", size="큼")
    return c


@creature("coyote", "C")
def coyote():
    W, H = 384, 384
    gy = 366
    c = Creature("coyote", (W, H), (200, gy), seed=834,
                 note="Coyote, 3/4 front view facing the lower left. Lean scruffy tawny-grey coyote with oversized ears, a "
                      "narrow snout, pale throat, dark-tipped bushy tail held low, amber eyes.")
    c.shadow(206, gy - 4, 250, 28)
    hp = quad_3q(c, "fur_tawny", "fur_brown", "fur_white", (236, 236, 170, 84), (118, 176, 70, 60),
                 [((290, 250), (304, 306), (298, 350), 20, 1), ((168, 256), (174, 308), (170, 350), 18, 1),
                  ((288, 256), (308, 308), (300, 354), 28, 3), ((132, 256), (126, 308), (124, 354), 26, 3.1)],
                 tail=[(310, 230), (350, 270), (352, 320)], extra_z=4)
    c.add("tail_tip", "fur_dark", 1.45, tube([(350, 296), (352, 320)], 14, 8, n=4, cap=True), tags=("tail",))
    c.add("ears", "fur_tawny", 4.3, [P("triangle", 104, 122, 32, 60, rot=-16), P("triangle", 144, 118, 30, 56, rot=14)], tags=("head",))
    c.add("snout", "fur_tawny", 4.35, [P("droplet", 86, 200, 34, 66, rot=-128)], tags=("head",))
    c.add("throat", "fur_white", 4.2, [P("cloud", 136, 222, 60, 40, rot=-20, flip="y")], tags=("head",))
    c.add("nose", "eye", 4.5, [E(64, 222, 13, 9, rot=-30)], tags=("head",))
    c.glow("eyes", "ember", 4.4, [E(104, 170, 12, 7, rot=20), E(134, 166, 10, 6, rot=10)], tags=("head",), color="ember_glow", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 4.45, [E(104, 170, 3, 6), E(134, 166, 3, 5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="코요테", size="사람")
    return c


@creature("small_bird", "C")
def small_bird():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("small_bird", (W, H), (cx, gy), seed=835,
                 note="Pigeon, front view. Plump grey city pigeon with a faint violet-green sheen on the neck, darker wing "
                      "bars, orange eyes, a small dark beak with a pale cere, pinkish feet.")
    c.shadow(cx, gy - 2, 120, 16)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "hide_pink", 1, [seg(cx + k * 14, 320, cx + k * 16, 352, 6)] + [seg(cx + k * 16, 352, cx + k * 16 + d * 10, 360, 4, ext=0.1)
                                                                                     for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "fur_grey", 2, [E(cx, 280, 130, 120)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "stone_dark", 2.2, [P("droplet", cx + k * 54, 284, 44, 110, flip="y", rot=k * -10)], tags=("body",))
        c.flat(f"bars_{s}", "soot", 2.3, [seg(cx + k * 44, 296, cx + k * 64, 290, 5), seg(cx + k * 44, 312, cx + k * 62, 306, 5)], tags=("body",),
               clip_to=f"wing_{s}")
    c.add("neck", "fur_grey", 2.5, [E(cx, 222, 90, 70)], tags=("head",))
    c.add("sheen", "crystal", 2.6, [E(cx, 236, 80, 30)], tags=("head",), clip_to="neck", opacity=0.45, line=False)
    c.add("head", "fur_grey", 3, [E(cx, 186, 70, 62)], tags=("head",))
    c.glow("eyes", "ember", 3.1, [E(cx - 20, 182, 10, 10), E(cx + 20, 182, 10, 10)], tags=("head",), color="ember_glow", strength=0.4, opacity=0.25)
    c.flat("pupils", "eye", 3.15, [E(cx - 20, 182, 4, 4), E(cx + 20, 182, 4, 4)], tags=("head",))
    c.add("cere", "eye_white", 3.2, [E(cx, 194, 16, 8)], tags=("head",))
    c.add("beak", "claw", 3.25, [P("droplet", cx, 206, 12, 18, flip="y")], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="작은 새(비둘기)", size="작음")
    return c


@creature("pig", "C")
def pig():
    W, H = 384, 384
    gy = 366
    c = Creature("pig", (W, H), (196, gy), seed=836,
                 note="Pig, 3/4 front view facing the lower left. Stout dirty-pink farm pig with a round snout disc, "
                      "floppy ears, small dark eyes, mud smears, a curly tail and short trotters.")
    c.shadow(206, gy - 4, 270, 30)
    quad_3q(c, "hide_pink", "snout", None, (230, 260, 200, 120), (116, 224, 96, 88),
            [((290, 290), (296, 326), (292, 352), 26, 1), ((168, 296), (172, 330), (170, 352), 24, 1),
             ((286, 296), (298, 330), (294, 356), 32, 3), ((138, 296), (134, 330), (132, 356), 30, 3.1)], extra_z=4)
    c.add("curl", "hide_pink", 1.4, [P("spiral", 334, 226, 30, 30)], tags=("tail",))
    c.add("mud", "leather", 2.3, [E(250, 300, 90, 40), E(310, 250, 40, 30)], tags=("body",), clip_to="body", opacity=0.5, line=False)
    c.add("ears", "snout", 4.3, [P("droplet", 92, 186, 34, 44, flip="y", rot=40), P("droplet", 146, 176, 32, 42, flip="y", rot=-30)], tags=("head",))
    c.add("snout_disc", "hide_pink", 4.4, [E(72, 250, 44, 38, rot=-20)], tags=("head",))
    c.flat("nostrils", "mouth", 4.45, [E(64, 250, 7, 10), E(80, 246, 7, 10)], tags=("head",))
    dot_eyes(c, 116, 214, 14, 7, 8, z=4.45, tags=("head",))
    c.flat("hooves", "horn", 3.3, [E(292, 358, 24, 8), E(132, 358, 26, 8)], tags=("legs",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="돼지", size="사람")
    return c


@creature("goat", "C")
def goat():
    W, H = 384, 384
    gy = 366
    c = Creature("goat", (W, H), (200, gy), seed=837,
                 note="Black goat, 3/4 front view facing the lower left. Shaggy black-brown goat with ridged horns curving "
                      "back, a pale beard, unsettling amber eyes with bar pupils, drooping ears, a short tail and hooves.")
    c.shadow(206, gy - 4, 250, 28)
    quad_3q(c, "fur_dark", "soot", None, (232, 240, 170, 96), (120, 180, 70, 70),
            [((290, 260), (300, 310), (296, 352), 22, 1), ((170, 266), (176, 312), (174, 352), 20, 1),
             ((288, 266), (304, 314), (298, 356), 28, 3), ((136, 266), (130, 314), (128, 356), 26, 3.1)], extra_z=4)
    c.add("horns", "horn", 3.9, tube([(120, 150), (160, 110), (190, 130)], 18, 6, n=8, cap=True) + tube([(140, 152), (184, 124), (206, 150)], 16, 5, n=8, cap=True),
          tags=("head",))
    c.flat("horn_rings", "soot", 3.95, [seg(140 + i * 12, 128 - i * 3, 146 + i * 12, 140 - i * 3, 2.5) for i in range(4)], tags=("head",), clip_to="horns", opacity=0.6)
    c.add("snout", "fur_dark", 4.3, [P("droplet", 92, 206, 36, 64, rot=-140)], tags=("head",))
    c.add("ears", "fur_dark", 4.2, [P("droplet", 84, 176, 16, 34, rot=-60), P("droplet", 156, 178, 16, 32, rot=70)], tags=("head",))
    c.add("beard", "fur_white", 4.4, [P("droplet", 88, 244, 18, 40, flip="y")], tags=("head",))
    c.glow("eyes", "glow_yellow", 4.4, [E(108, 176, 13, 9, rot=20), E(138, 172, 11, 8, rot=10)], tags=("head",), color="glow_yellow_c", strength=0.6, opacity=0.35)
    c.flat("pupils", "eye", 4.45, [E(108, 176, 9, 3, rot=20), E(138, 172, 8, 3, rot=10)], tags=("head",))
    c.flat("hooves", "horn", 3.3, [E(298, 358, 22, 8), E(128, 358, 24, 8)], tags=("legs",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="염소", size="사람")
    return c


@creature("deer", "C")
def deer():
    W, H = 512, 512
    gy = 494
    c = Creature("deer", (W, H), (262, gy), seed=838,
                 note="Stag, 3/4 front view facing the lower left. Slender brown red-deer stag with tall branching "
                      "antlers, a pale throat patch and rump, large ears, dark gentle eyes and thin legs with small hooves.")
    c.shadow(270, gy - 4, 320, 34)
    legs = [((356, 330), (366, 400), (360, 474), 22, 1), ((214, 330), (220, 400), (218, 474), 20, 1),
            ((354, 336), (374, 404), (368, 478), 28, 3), ((184, 336), (178, 404), (176, 478), 26, 3.1)]
    for i, (hip, knee, foot, w, z) in enumerate(legs):
        leg3(c, f"leg_{i}", [hip, knee, foot], w, w * 0.6, "fur_brown" if z >= 2 else "fur_dark", z, ("legs",))
        c.add(f"hoof_{i}", "claw", z + 0.05, [P("triangle", foot[0], foot[1] + 8, w * 0.8, w * 0.7, flip="y")], tags=("legs",))
    c.add("body", "fur_brown", 2, [E(290, 300, 220, 110, -6), E(206, 306, 100, 110)], tags=("body",))
    c.add("rump", "fur_white", 2.1, [E(390, 290, 40, 50)], tags=("body",), clip_to="body", opacity=0.8)
    c.add("neck", "fur_brown", 3.5, tube([(206, 290), (184, 230), (170, 190)], 70, 50, n=8, cap=True), tags=("head",))
    c.add("throat", "fur_white", 3.6, [E(186, 250, 30, 50)], tags=("head",), clip_to="neck", opacity=0.7)
    c.add("head", "fur_brown", 4, [E(156, 176, 60, 54), P("droplet", 124, 208, 34, 70, rot=-140)], tags=("head",))
    c.add("ears", "fur_brown", 3.9, [P("droplet", 128, 150, 18, 40, rot=-70), P("droplet", 188, 150, 18, 38, rot=70)], tags=("head",))
    antler = lambda x0, y0, s: (tube([(x0, y0), (x0 + 10 * s, y0 - 60), (x0 + 30 * s, y0 - 130)], 9, 4, n=10, cap=True)
                                + tube([(x0 + 8 * s, y0 - 50), (x0 - 16 * s, y0 - 80)], 6, 3, n=5, cap=True)
                                + tube([(x0 + 18 * s, y0 - 90), (x0 + 50 * s, y0 - 110)], 6, 3, n=5, cap=True)
                                + tube([(x0 + 24 * s, y0 - 110), (x0 + 4 * s, y0 - 146)], 5, 2, n=5, cap=True))
    c.add("antlers", "horn", 4.1, antler(146, 150, -1) + antler(172, 150, 1), tags=("head",))
    dot_eyes(c, 150, 176, 12, 8, 9, z=4.2, tags=("head",))
    c.add("nose", "eye", 4.3, [E(102, 232, 12, 10, rot=-30)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="사슴", size="큼")
    return c


@creature("chicken", "C")
def chicken():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("chicken", (W, H), (cx, gy), seed=839,
                 note="Hen, front view. Plump speckled brown hen with a red-wine comb and wattles, a small yellow beak, "
                      "beady eyes, fluffed wings, a tail tuft and scaly yellow legs.")
    c.shadow(cx, gy - 2, 140, 18)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "gold", 1, [seg(cx + k * 16, 310, cx + k * 18, 350, 8)] + [seg(cx + k * 18, 350, cx + k * 18 + d * 12, 360, 5, ext=0.1)
                                                                                 for d in (-1, 0, 1)], tags=("legs",))
    c.add("tail", "feather_brown", 1.5, [P("feather", cx + 50, 214, 30, 60, rot=30), P("feather", cx - 50, 214, 30, 60, rot=-30, flip="x")], tags=("body",))
    c.add("body", "feather_brown", 2, [E(cx, 270, 140, 130)], tags=("body",))
    c.flat("speckle", "feather_pale", 2.1, [P("moon", cx + dx, 270 + dy, 10, 10, rot=-45) for dx, dy in ((-30, -10), (30, -10), (0, 14), (-36, 30), (36, 30))],
           tags=("body",), clip_to="body", opacity=0.6)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "feather_brown", 2.3, [P("droplet", cx + k * 60, 272, 40, 90, flip="y", rot=k * -14)], tags=("body",))
    c.add("head", "feather_brown", 3, [E(cx, 186, 70, 64)], tags=("head",))
    c.add("comb", "cloth_wine", 2.9, [P("cloud", cx, 152, 44, 26)], tags=("head",))
    c.add("wattle", "cloth_wine", 3.2, [P("droplet", cx, 222, 16, 24, flip="y")], tags=("head",))
    c.add("beak", "gold", 3.3, [P("triangle", cx, 206, 16, 16, flip="y")], tags=("head",))
    dot_eyes(c, cx, 186, 17, 8, 9, z=3.25, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="닭", size="작음")
    return c


@creature("duck", "C")
def duck():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("duck", (W, H), (cx, gy), seed=840,
                 note="Mallard duck, front view. Dark bottle-green head, a pale neck ring, chestnut breast, grey-brown "
                      "body, a broad dull-yellow bill, orange webbed feet.")
    c.shadow(cx, gy - 2, 140, 18)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "ember", 1, [seg(cx + k * 16, 318, cx + k * 18, 344, 8), P("fan", cx + k * 20, 354, 30, 18, rot=180)], tags=("legs",))
    c.add("body", "stone", 2, [E(cx, 280, 150, 120)], tags=("body",))
    c.add("breast", "fur_brown", 2.1, [E(cx, 260, 100, 70)], tags=("body",), clip_to="body")
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "fur_grey", 2.3, [P("droplet", cx + k * 60, 284, 44, 100, flip="y", rot=k * -10)], tags=("body",))
    c.add("neck", "scale_teal", 2.5, [seg(cx, 230, cx, 196, 36)], tags=("head",))
    c.add("ring", "feather_pale", 2.55, [E(cx, 228, 40, 10)], tags=("head",))
    c.add("head", "scale_teal", 3, [E(cx, 178, 70, 62)], tags=("head",))
    c.add("bill", "gold", 3.2, [E(cx, 206, 40, 22), E(cx, 198, 30, 14)], tags=("head",))
    dot_eyes(c, cx, 172, 18, 8, 8, z=3.25, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="오리", size="작음")
    return c


@creature("squirrel", "C")
def squirrel():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("squirrel", (W, H), (cx, gy), seed=841,
                 note="Squirrel, front view, sitting up. Rusty-brown squirrel with a huge bushy tail curled up behind "
                      "it, tufted ears, a pale belly, shiny dark eyes, holding an acorn in its paws.")
    c.shadow(cx, gy - 2, 140, 18)
    c.add("tail", "fur_fox", 1, tube([(cx + 20, 340), (cx + 110, 300), (cx + 100, 170), (cx + 40, 150)], 70, 44, n=16, cap=True), tags=("tail",))
    c.add("body", "fur_fox", 2, [P("droplet", cx - 6, 290, 100, 140), E(cx - 6, 320, 110, 80)], tags=("body",))
    c.add("belly", "fur_white", 2.1, [E(cx - 6, 300, 56, 80)], tags=("body",), clip_to="body", opacity=0.8)
    c.add("feet", "fur_fox", 2.2, [E(cx - 40, 356, 40, 16), E(cx + 26, 356, 40, 16)], tags=("body",))
    c.add("acorn", "wood", 2.4, [E(cx - 6, 270, 26, 30), P("circle", cx - 6, 258, 30, 16, half="top")], tags=("body",))
    c.add("paws", "fur_fox", 2.5, [E(cx - 22, 272, 18, 14), E(cx + 10, 272, 18, 14)], tags=("body",))
    c.add("ears", "fur_fox", 2.9, [P("triangle", cx - 30, 176, 20, 34, rot=-14), P("triangle", cx + 18, 176, 20, 34, rot=14)], tags=("head",))
    c.add("head", "fur_fox", 3, [E(cx - 6, 212, 70, 62)], tags=("head",))
    c.add("cheeks", "fur_white", 3.1, [P("cloud", cx - 6, 228, 50, 24, flip="y")], tags=("head",))
    dot_eyes(c, cx - 6, 206, 16, 10, 12, z=3.2, tags=("head",))
    c.add("nose", "eye", 3.3, [E(cx - 6, 224, 8, 6)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="다람쥐", size="작음")
    return c



@creature("raccoon", "C")
def raccoon():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("raccoon", (W, H), (cx, gy), seed=842,
                 note="Raccoon, front view, sitting up. Grey-brown raccoon with a black bandit mask, pale muzzle and brows, "
                      "rounded ears, dark handlike paws raised, a thick ringed tail curled at the side.")
    c.shadow(cx, gy - 2, 150, 18)
    c.add("tail", "fur_grey", 1, tube([(cx + 30, 340), (cx + 100, 320), (cx + 110, 250)], 40, 26, n=12, cap=True), tags=("tail",))
    c.flat("rings", "soot", 1.05, [E(cx + 60 + i * 14, 330 - i * 20, 34, 12, rot=-30 + i * 14) for i in range(4)], tags=("tail",), clip_to="tail")
    c.add("body", "fur_grey", 2, [P("droplet", cx - 6, 290, 110, 140), E(cx - 6, 322, 120, 80)], tags=("body",))
    c.add("belly", "fur_white", 2.1, [E(cx - 6, 304, 60, 70)], tags=("body",), clip_to="body", opacity=0.6)
    c.add("feet", "soot", 2.2, [E(cx - 40, 356, 36, 14), E(cx + 26, 356, 36, 14)], tags=("body",))
    c.add("paws", "soot", 2.4, [E(cx - 34, 256, 18, 16), E(cx + 22, 256, 18, 16)], tags=("body",))
    c.add("ears", "fur_grey", 2.9, [E(cx - 36, 170, 26, 30), E(cx + 24, 170, 26, 30)], tags=("head",))
    c.add("head", "fur_grey", 3, [E(cx - 6, 208, 84, 70)], tags=("head",))
    c.add("mask", "soot", 3.1, [E(cx - 24, 206, 34, 22, rot=10), E(cx + 12, 206, 34, 22, rot=-10)], tags=("head",))
    c.add("muzzle", "fur_white", 3.2, [P("droplet", cx - 6, 226, 30, 34, flip="y")], tags=("head",))
    c.add("brows", "fur_white", 3.15, [E(cx - 24, 190, 26, 8), E(cx + 12, 190, 26, 8)], tags=("head",))
    dot_eyes(c, cx - 6, 206, 18, 9, 10, z=3.3, tags=("head",))
    c.add("nose", "eye", 3.35, [E(cx - 6, 236, 10, 7)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="너구리", size="작음")
    return c


@creature("monkey", "C")
def monkey():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("monkey", (W, H), (cx, gy), seed=843,
                 note="Macaque, front view, crouching. Shaggy grey-brown monkey with a bare pinkish-red face, close-set "
                      "dark eyes, long arms with hands resting on the ground, a short curled tail.")
    c.shadow(cx, gy - 2, 170, 20)
    c.add("tail", "fur_brown", 0.8, [P("spiral", cx + 70, 316, 40, 40)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "fur_brown", 1, [E(cx + k * 44, 316, 60, 70, rot=k * -30), E(cx + k * 54, 354, 44, 16)], tags=("legs",))
    c.add("body", "fur_brown", 2, [E(cx, 280, 110, 120)], tags=("body",))
    c.add("belly", "hide_pink", 2.1, [E(cx, 294, 50, 60)], tags=("body",), clip_to="body", opacity=0.5, line=False)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "fur_brown", 2.5, [seg(cx + k * 44, 236, cx + k * 70, 300, 22), seg(cx + k * 70, 300, cx + k * 62, 350, 18),
                                            E(cx + k * 62, 356, 24, 14)], tags=("arms",))
    c.add("head", "fur_brown", 3, [E(cx, 196, 90, 80)], tags=("head",))
    c.add("ears", "hide_pink", 2.9, [E(cx - 46, 196, 20, 26), E(cx + 46, 196, 20, 26)], tags=("head",))
    c.add("face", "hide_pink", 3.1, [E(cx, 204, 60, 56)], tags=("head",))
    c.add("brow", "hide_pink", 3.15, [E(cx, 190, 50, 12)], tags=("head",))
    dot_eyes(c, cx, 198, 11, 8, 9, z=3.2, tags=("head",))
    c.flat("nostrils", "mouth", 3.25, [E(cx - 4, 214, 3, 3), E(cx + 4, 214, 3, 3)], tags=("head",))
    c.flat("mouth", "mouth", 3.25, [seg(cx - 10, 224, cx + 10, 224, 2)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="원숭이", size="작음")
    return c


@creature("elephant", "C")
def elephant():
    W, H = 640, 640
    cx, gy = 320, 620
    c = Creature("elephant", (W, H), (cx, gy), seed=844,
                 note="Elephant, front view. Huge wrinkled slate-grey elephant facing the viewer: great flapping ears, a "
                      "long trunk curling at the tip, two pale curved tusks, small eyes, pillar legs with toenails.")
    c.shadow(cx, gy - 4, 460, 50)
    c.add("ears", "stone", 1, [E(cx - 170, 250, 200, 250, rot=-10), E(cx + 170, 250, 200, 250, rot=10)], tags=("head",))
    c.add("ears_in", "hide_pink", 1.05, [E(cx - 160, 256, 150, 200, rot=-10), E(cx + 160, 256, 150, 200, rot=10)], tags=("head",), opacity=0.35, line=False)
    c.add("body", "stone", 1.5, [E(cx, 380, 380, 300)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "stone", 2, [P("cylinder", cx + k * 100, 530, 100, 170)], tags=("legs",))
        c.add(f"nails_{s}", "bone_old", 2.1, [E(cx + k * 100 + d * 26, 606, 22, 12) for d in (-1, 0, 1)], tags=("legs",))
    c.add("head", "stone", 3, [E(cx, 250, 220, 200)], tags=("head",))
    c.flat("wrinkles", "stone_dark", 3.1, [smile(cx, 200 + i * 16, 80, 8, depth=0.6)[0] for i in range(3)], tags=("head",), clip_to="head", opacity=0.4)
    c.add("tusks", "bone", 3.3, [P("moon", cx - 60, 380, 60, 70, rot=-160), P("moon", cx + 60, 380, 60, 70, rot=160, flip="x")], tags=("head",))
    c.add("trunk", "stone", 3.5, tube([(cx, 300), (cx - 6, 400), (cx + 20, 480), (cx + 60, 490)], 80, 30, n=16, cap=True), tags=("head",))
    c.flat("trunk_rings", "stone_dark", 3.55, [E(cx - 4 + i * 6, 340 + i * 30, 60 - i * 8, 8) for i in range(5)], tags=("head",), clip_to="trunk", opacity=0.4)
    dot_eyes(c, cx, 250, 60, 14, 14, z=3.4, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="코끼리", size="거대")
    return c


@creature("lizard", "C")
def lizard():
    W, H = 320, 384
    gy = 366
    c = Creature("lizard", (W, H), (164, gy), seed=845,
                 note="Desert lizard, 3/4 front view facing the lower left. Sandy spiny lizard low to the ground: horned "
                      "head with a frill of spikes, beady eyes, dark bands on its back, splayed clawed legs and a long "
                      "tapering tail curling back.")
    c.shadow(170, gy - 4, 230, 26)
    c.add("tail", "chitin_amber", 1, tube([(210, 330), (280, 330), (300, 270), (270, 240)], 30, 6, n=14, cap=True), tags=("tail",))
    leg3(c, "leg_far_h", [(210, 330), (236, 342), (236, 360)], 16, 10, "chitin_amber", 1.2, ("legs",), paw=(22, 8), claws=3)
    leg3(c, "leg_far_f", [(130, 330), (150, 340), (152, 360)], 16, 10, "chitin_amber", 1.2, ("legs",), paw=(22, 8), claws=3)
    c.add("body", "chitin_amber", 2, [E(170, 326, 150, 60, rot=-6)], tags=("body",))
    c.flat("bands", "chitin_rust", 2.1, [E(140 + i * 26, 318 - i * 2, 14, 40, rot=-6) for i in range(4)], tags=("body",), clip_to="body", opacity=0.6)
    c.add("spines", "chitin_rust", 2.2, spikes_on([(110, 304), (170, 296), (230, 306)], 7, 12, 8, 0.0, 1.0, side=-1), tags=("body",))
    leg3(c, "leg_h", [(214, 340), (240, 350), (244, 364)], 20, 12, "chitin_amber", 3, ("legs",), paw=(26, 9), claws=3)
    leg3(c, "leg_f", [(116, 340), (96, 352), (92, 364)], 20, 12, "chitin_amber", 3.1, ("legs",), paw=(26, 9), claws=3)
    c.add("head", "chitin_amber", 4, [E(96, 300, 70, 52), P("droplet", 66, 316, 30, 60, rot=-116)], tags=("head",))
    c.add("horns", "horn", 3.9, [P("triangle", 90 + d * 16, 270 - abs(d) * 4, 9, 22, rot=d * 20) for d in (-1, 0, 1, 2)], tags=("head",))
    dot_eyes(c, 96, 296, 14, 8, 8, z=4.2, tags=("head",))
    c.flat("mouth", "mouth", 4.2, [seg(50, 326, 96, 318, 2.5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="도마뱀", size="작음")
    return c


@creature("turtle", "C")
def turtle():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("turtle", (W, H), (cx, gy), seed=846,
                 note="Sea turtle, front view. Big turtle with a high domed barnacle-crusted olive shell of hexagon plates, "
                      "a beaked head poking forward under the rim with calm eyes, broad front flippers and small rear "
                      "flippers splayed, pale belly plate edge.")
    c.shadow(cx, gy - 2, 300, 34)
    for s_, k in (("l", -1), ("r", 1)):
        c.add(f"rear_{s_}", "scale_olive", 0.9, [E(cx + k * 100, 330, 60, 30, rot=k * 20)], tags=("legs",))
        c.add(f"flipper_{s_}", "scale_olive", 1, [P("leaf", cx + k * 118, 304, 84, 46, rot=k * 60 + 90, **({"flip": "x"} if k < 0 else {}))], tags=("legs",))
    c.add("shell", "horn", 2, [P("circle", cx, 262, 270, 190, half="top"), E(cx, 262, 270, 44)], tags=("body",))
    c.flat("plates", "chitin_amber", 2.1, [P("hexagon", cx + dx, 214 + dy, 50, 44) for dx, dy in ((-64, 10), (0, -12), (64, 10), (-100, 40), (100, 40), (-30, 42), (30, 42))],
           tags=("body",), clip_to="shell", opacity=0.55)
    c.add("barnacles", "bone_old", 2.2, [E(cx + dx, 204 + dy, 12, 10) for dx, dy in ((-80, 30), (60, -10), (100, 40), (-20, 10))], tags=("body",), clip_to="shell")
    c.add("rim", "belly", 2.3, [E(cx, 276, 262, 24)], tags=("body",))
    c.add("plastron", "belly", 1.8, [E(cx, 300, 200, 60)], tags=("body",))
    c.add("head", "scale_olive", 3, [E(cx, 316, 74, 62), E(cx, 290, 60, 40)], tags=("head",))
    c.add("beak", "claw", 3.1, [P("triangle", cx, 344, 24, 16, flip="y")], tags=("head",))
    dot_eyes(c, cx, 308, 20, 10, 11, z=3.2, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="??", size="??")
    return c


@creature("penguin", "C")
def penguin():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("penguin", (W, H), (cx, gy), seed=847,
                 note="Penguin, front view, standing. Black-backed penguin with a white belly, a dull-gold neck patch, "
                      "stubby flipper wings, a sharp beak, dark eyes and orange-grey feet.")
    c.shadow(cx, gy - 2, 130, 18)
    c.add("feet", "ember", 1, [E(cx - 22, 356, 34, 14), E(cx + 22, 356, 34, 14)], tags=("legs",))
    c.add("body", "robe_black", 2, [P("droplet", cx, 250, 130, 220), E(cx, 300, 130, 110)], tags=("body",))
    c.add("belly", "eye_white", 2.1, [P("droplet", cx, 266, 90, 180), E(cx, 300, 90, 90)], tags=("body",), clip_to="body")
    c.add("neck_patch", "gold", 2.15, [E(cx - 30, 196, 24, 30, rot=20), E(cx + 30, 196, 24, 30, rot=-20)], tags=("body",), clip_to="body", opacity=0.8)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"flipper_{s}", "robe_black", 2.3, [P("droplet", cx + k * 66, 262, 26, 100, flip="y", rot=k * -18)], tags=("body",))
    dot_eyes(c, cx, 176, 16, 9, 9, z=2.4, tags=("head",))
    c.add("beak", "claw", 2.5, [P("droplet", cx, 196, 16, 30, flip="y")], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="펭귄", size="작음")
    return c


@creature("walrus", "C")
def walrus():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("walrus", (W, H), (cx, gy), seed=848,
                 note="Walrus, front view. Massive wrinkled brown walrus propped on its front flippers: a bristly moustache "
                      "pad, two long ivory tusks, small eyes, heavy blubber folds, rear flippers spread behind.")
    c.shadow(cx, gy - 2, 360, 40)
    c.add("rear", "snout", 1, [E(cx - 150, 470, 110, 40, rot=-10), E(cx + 150, 470, 110, 40, rot=10)], tags=("body",))
    c.add("body", "snout", 2, [E(cx, 370, 330, 250)], tags=("body",))
    c.flat("folds", "leather", 2.1, [smile(cx, 330 + i * 30, 240 - i * 20, 12, depth=0.6)[0] for i in range(3)], tags=("body",), clip_to="body", opacity=0.4)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"flipper_{s}", "snout", 3, [P("leaf", cx + k * 110, 460, 110, 60, rot=k * -20, **({"flip": "x"} if k < 0 else {}))], tags=("legs",))
    c.add("head", "snout", 4, [E(cx, 250, 180, 140)], tags=("head",))
    c.add("muzzle", "hide_pink", 4.2, [E(cx - 36, 280, 76, 60), E(cx + 36, 280, 76, 60)], tags=("head",))
    c.flat("whiskers", "leather", 4.25, [E(cx + dx, 280 + dy, 5, 5) for dx in (-56, -40, -24, 24, 40, 56) for dy in (-10, 6)], tags=("head",))
    c.add("tusks", "bone", 4.3, [P("triangle", cx - 20, 360, 18, 110, flip="y", rot=4), P("triangle", cx + 20, 360, 18, 110, flip="y", rot=-4)], tags=("head",))
    dot_eyes(c, cx, 230, 44, 12, 12, z=4.35, tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="바다코끼리", size="큼")
    return c


@creature("flamingo", "C")
def flamingo():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("flamingo", (W, H), (cx, gy), seed=849,
                 note="Flamingo, front view. Dusty-pink flamingo standing on one long thin leg with the other folded, an "
                      "S-curved neck, a bent black-tipped bill, folded wings with dark edge feathers.")
    c.shadow(cx, gy - 2, 90, 14)
    c.add("leg", "hide_pink", 1, [seg(cx, 250, cx + 2, 350, 7), P("fan", cx + 2, 358, 30, 14, rot=180)], tags=("legs",))
    c.add("leg2", "hide_pink", 1.1, [seg(cx + 4, 250, cx + 40, 290, 7), seg(cx + 40, 290, cx + 8, 310, 6)], tags=("legs",))
    c.add("body", "hide_pink", 2, [E(cx, 220, 120, 80)], tags=("body",))
    c.add("wing", "hide_pink", 2.1, [P("droplet", cx + 20, 216, 70, 110, rot=100)], tags=("body",))
    c.add("wing_edge", "soot", 2.05, [P("droplet", cx + 60, 216, 30, 50, rot=100)], tags=("body",))
    c.add("neck", "hide_pink", 2.5, tube([(cx - 30, 200), (cx - 70, 150), (cx - 10, 110), (cx - 20, 80)], 18, 12, n=14, cap=True), tags=("head",))
    c.add("head", "hide_pink", 3, [E(cx - 20, 72, 34, 30)], tags=("head",))
    c.add("bill", "paper", 3.1, [P("moon", cx - 26, 96, 26, 30, rot=160)], tags=("head",))
    c.add("bill_tip", "soot", 3.15, [E(cx - 34, 106, 10, 10)], tags=("head",), clip_to="bill")
    c.flat("eye", "gold", 3.2, [E(cx - 22, 68, 6, 6)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="플라밍고", size="사람")
    return c


@creature("bison", "C")
def bison():
    W, H = 512, 512
    gy = 494
    c = Creature("bison", (W, H), (262, gy), seed=850,
                 note="Bison, 3/4 front view facing the lower left. Massive dark-brown bison with a towering shaggy hump, "
                      "a heavy woolly head held low, short curved horns, a thick beard, small dark eyes, lighter hindquarters.")
    c.shadow(270, gy - 4, 400, 44)
    legs = [((380, 360), (390, 420), (386, 476), 30, 1), ((200, 380), (206, 430), (204, 476), 32, 1),
            ((378, 366), (398, 426), (392, 480), 38, 3), ((168, 380), (160, 432), (158, 480), 40, 3.1)]
    for i, (hip, knee, foot, w, z) in enumerate(legs):
        leg3(c, f"leg_{i}", [hip, knee, foot], w, w * 0.7, "fur_brown" if z >= 2 else "fur_dark", z, ("legs",))
        c.add(f"hoof_{i}", "claw", z + 0.05, [P("cylinder", foot[0], foot[1] + 8, w * 0.9, w * 0.5)], tags=("legs",))
    c.add("tail", "fur_brown", 1.4, tube([(420, 300), (440, 330), (436, 380)], 12, 8, n=6, cap=True), tags=("tail",))
    c.add("body", "fur_brown", 2, [E(320, 320, 220, 140, -6)], tags=("body",))
    c.add("hump", "fur_dark", 2.5, [E(220, 290, 200, 220)], tags=("body",))
    c.add("head", "fur_dark", 4, [E(146, 336, 120, 110)], tags=("head",))
    c.add("beard", "fur_dark", 4.1, [P("droplet", 140, 410, 60, 70, flip="y")], tags=("head",))
    c.add("horns", "horn", 4.2, [P("moon", 110, 290, 30, 30, rot=-110), P("moon", 188, 284, 28, 28, rot=-60)], tags=("head",))
    c.add("face", "fur_brown", 4.15, [E(140, 350, 70, 60)], tags=("head",))
    dot_eyes(c, 140, 336, 20, 9, 9, z=4.3, tags=("head",))
    c.add("nose", "soot", 4.35, [E(132, 372, 30, 18)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="들소", size="큼")
    return c


@creature("parrot", "C")
def parrot():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("parrot", (W, H), (cx, gy), seed=851,
                 note="Parrot, front view, standing. Faded wine-red macaw with dusty blue-green wings folded, a long tail, "
                      "a heavy hooked bone-coloured beak, a pale face patch with a beady eye, grey zygodactyl feet.")
    c.shadow(cx, gy - 2, 110, 16)
    c.add("tail", "cloth_blue", 1, [P("feather", cx, 320, 30, 90, rot=180)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "horn", 1.5, [seg(cx + k * 16, 290, cx + k * 18, 316, 7)] + [seg(cx + k * 18, 316, cx + k * 18 + d * 10, 326, 4, ext=0.1)
                                                                                     for d in (-1, 1)], tags=("legs",))
    c.add("body", "cloth_wine", 2, [P("droplet", cx, 236, 100, 150, flip="y")], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "robe_teal", 2.2, [P("droplet", cx + k * 44, 240, 40, 110, flip="y", rot=k * -8)], tags=("body",))
    c.add("head", "cloth_wine", 3, [E(cx, 160, 70, 66)], tags=("head",))
    c.add("face", "eye_white", 3.1, [E(cx - 16, 160, 30, 36), E(cx + 16, 160, 30, 36)], tags=("head",), opacity=0.8)
    dot_eyes(c, cx, 156, 16, 8, 8, z=3.2, tags=("head",))
    c.add("beak", "bone", 3.3, [P("moon", cx, 186, 36, 40, rot=135), E(cx, 180, 26, 20)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="앵무새", size="작음")
    return c


@creature("rattlesnake", "C")
def rattlesnake():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("rattlesnake", (W, H), (cx, gy), seed=852,
                 note="Rattlesnake, front view. Sandy diamond-patterned rattlesnake coiled tight, head raised and drawn "
                      "back to strike, heat-pit face with yellow slit eyes, tongue flicking, its segmented rattle held up "
                      "behind.")
    c.shadow(cx, gy - 2, 200, 24)
    c.add("coil_2", "chitin_amber", 1, [E(cx, 336, 190, 50)], tags=("coils",))
    c.add("coil_1", "chitin_amber", 1.2, [E(cx - 6, 312, 150, 44)], tags=("coils",))
    c.flat("diamonds", "chitin_rust", 1.3, [P("diamond", cx - 70 + i * 28, 336, 18, 22) for i in range(6)], tags=("coils",), clip_to="coil_2", opacity=0.8)
    c.add("rattle_tail", "chitin_amber", 0.9, tube([(cx + 80, 330), (cx + 106, 290), (cx + 100, 250)], 16, 10, n=8, cap=True), tags=("coils",))
    c.add("rattle", "bone_old", 0.95, [E(cx + 100, 244 - i * 12, 16 - i, 12) for i in range(4)], tags=("coils",))
    neck = [(cx - 10, 306), (cx + 30, 260), (cx - 20, 220), (cx - 6, 180)]
    c.add("neck", "chitin_amber", 2, tube(neck, 36, 30, n=12, cap=True), tags=("head",))
    c.flat("neck_d", "chitin_rust", 2.05, [P("diamond", x, y, 14, 16) for x, y in ((cx + 18, 260), (cx - 8, 226))], tags=("head",), clip_to="neck")
    c.add("head", "chitin_amber", 3, [P("droplet", cx - 6, 156, 64, 60, flip="y"), E(cx - 6, 150, 60, 40)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 22, 148, 12, 9, rot=16), E(cx + 10, 148, 12, 9, rot=-16)], tags=("head",), color="glow_yellow_c",
           strength=0.6, opacity=0.35)
    c.flat("pupils", "eye", 3.25, [E(cx - 22, 148, 3, 8), E(cx + 10, 148, 3, 8)], tags=("head",))
    c.add("tongue", "tongue", 3.3, [seg(cx - 6, 180, cx - 6, 200, 3), seg(cx - 6, 198, cx - 12, 208, 2.5), seg(cx - 6, 198, cx, 208, 2.5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="방울뱀", size="작음")
    return c
