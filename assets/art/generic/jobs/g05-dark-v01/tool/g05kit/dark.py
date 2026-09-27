"""g05-dark-v01: dark-fantasy / gothic creatures (front-view battlers).

Each function returns a kit.Creature.  Coordinates are final px.  A items get
idle / attack / hit, B and C items idle only.
"""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, heater_shield, leg3, spikes_on, wing_at


# ---------------------------------------------------------------- A: skeleton
@creature("skeleton", "A")
def skeleton():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("skeleton", (W, H), (cx, gy), seed=601,
                 note="Skeleton soldier, front view. Yellowed bones with dark sockets and faint red eye lights, rib cage, "
                      "rusty sword and a cracked round shield. attack = sword raised overhead, jaw dropped; hit = skull "
                      "knocked askew, bones rattled sideways, eye lights gone.")
    c.shadow(cx, gy - 2, 150, 20)
    # legs
    for s, k in (("l", -1), ("r", 1)):
        bones_limb(c, f"leg_{s}", [(cx + k * 16, 252), (cx + k * 22, 306), (cx + k * 26, 352)], 11, "bone", 1, ("legs", f"leg_{s}"),
                   (cx + k * 16, 252))
        c.add(f"foot_{s}", "bone", 1.1, [E(cx + k * 32, 358, 30, 12)], tags=("legs", f"leg_{s}"))
    c.add("pelvis", "bone", 2, [E(cx, 246, 66, 30)], tags=("torso",))
    c.flat("pelvis_holes", "void", 2.1, [E(cx - 16, 248, 14, 12), E(cx + 16, 248, 14, 12)], tags=("torso",))
    c.add("spine", "bone", 2.2, [E(cx, 150 + i * 12, 13, 10) for i in range(9)], tags=("torso",))
    c.add("ribcage", "bone", 3, [E(cx, 182, 96, 78), E(cx, 150, 84, 22)], tags=("torso",))
    c.flat("rib_gaps", "void", 3.1, [p for i in range(4) for p in smile(cx, 172 + i * 15, 80 - i * 6, 8, depth=0.55)]
           + [P("square", cx, 186, 10, 70, op="sub")], tags=("torso",))
    c.add("collar", "bone", 3.2, [seg(cx - 44, 146, cx + 44, 146, 8)], tags=("torso",))
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 46, 148)
        arms[s] = list(sh)
        bones_limb(c, f"arm_{s}", [sh, (cx + k * 56, 200), (cx + k * 60, 246)], 9, "bone", 4, (f"arm_{s}",), sh)
        c.add(f"hand_{s}", "bone", 4.1, claw_hand(cx + k * 60, 252, 90 - k * 10, 16), tags=(f"arm_{s}",), pivot=list(sh))
    c.add("sword", "armor", 3.95, [held("sword", (cx + 60, 250), 120, -80, grip=0.5)], tags=("arm_r",), pivot=arms["r"])
    c.add("shield", "wood", 4.5, [E(cx - 66, 232, 78, 82)], tags=("arm_l", "shield"), pivot=arms["l"])
    c.add("shield_rim", "iron", 4.55, [E(cx - 66, 232, 80, 84), E(cx - 66, 232, 66, 70, op="sub")], tags=("arm_l", "shield"), pivot=arms["l"])
    c.flat("shield_crack", "void", 4.6, [P("lightning_bolt", cx - 58, 226, 14, 40, rot=12)], tags=("arm_l", "shield"), pivot=arms["l"])
    # attack arm: sword overhead
    bones_limb(c, "arm_r_atk", [arms["r"], (cx + 88, 126), (cx + 76, 98)], 9, "bone", 4, ("atk",), arms["r"], hidden=True)
    c.add("hand_r_atk", "bone", 4.1, claw_hand(cx + 74, 92, -100, 16), tags=("atk",), hidden=True)
    c.add("sword_atk", "armor", 3.95, [held("sword", (cx + 74, 96), 110, -160, grip=0.5)], tags=("atk",), hidden=True)
    # skull
    c.add("neck", "bone", 5, [E(cx, 136, 14, 16)], tags=("head",))
    c.flat("skull_back", "void", 5.9, [E(cx, 96, 50, 34)], tags=("head",))
    c.add("skull", "bone", 6, [P("skull", cx, 98, 76, 78)], tags=("head",))
    c.glow("eyes", "glow_red", 6.2, [E(cx - 12, 94, 7, 7), E(cx + 12, 94, 7, 7)], tags=("head", "eyes"), color="glow_red_c",
           strength=0.8, opacity=0.5)
    c.add("jaw_open", "bone", 5.8, [P("skull", cx, 110, 64, 30, crop=[3, 12.5, 13, 16])], tags=("head", "mouth_open"), hidden=True)
    c.flat("jaw_gap", "void", 5.7, [E(cx, 124, 44, 16)], tags=("head", "mouth_open"), hidden=True)
    sr, sl = arms["r"], arms["l"]
    std_frames(
        c,
        attack_move={"mouth_open": {"dy": 10}, "head": {"rot": -6, "pivot": [cx, 140]}, "all": c.whole(s=1.04, dy=4, rot=-2)},
        attack_show=("atk", "mouth_open"), attack_hide=("arm_r",),
        hit_move={"head": {"rot": 20, "dx": 14, "dy": 6, "pivot": [cx, 140]}, "arm_l": {"rot": 26, "pivot": sl},
                  "arm_r": {"rot": -30, "pivot": sr}, "all": c.whole(rot=-6, dx=-2, dy=-4, s=0.96)},
        hit_show=(), hit_hide=("eyes",), shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="해골 병사", size="사람")
    return c


# ---------------------------------------------------------------- A: zombie
@creature("zombie", "A")
def zombie():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("zombie", (W, H), (cx, gy), seed=602,
                 note="Zombie, front view. Shambling rotten grey-green undead in torn shirt and trousers, head lolling, "
                      "dull glowing eyes, slack jaw, arms reaching forward with clawed fingers. attack = lurches forward "
                      "biting with both arms grabbing wide; hit = head snapped back, knocked off balance.")
    b = Biped(c, cx, gy, 318, build=0.95, leg=0.44, torso=0.3, head=0.18, shoulder=0.15, hip=0.09, arm_w=0.06,
              leg_w=0.075, arm_len=0.36, stance=1.1, hunch=0.04)
    c.shadow(cx, gy - 2, 150, 20)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("trouser", foot_mat="leather", z=1, thigh=1.1, shin=0.95)
    c.add("rag_legs", "cloth_rag", 1.2, [P("bookmark", cx - 22, yh + 76, 30, 36, flip="y"), P("bookmark", cx + 26, yh + 70, 28, 30, flip="y")],
          tags=("legs",), opacity=0.9)
    b.torso("zombie", z=3, chest=0.95, shape="slim")
    c.add("shirt", "cloth_rag", 3.2, [P("droplet", cx, ys + 56, 100, 124, flip="y"), E(cx, ys + 12, 104, 34)], tags=("torso",),
          clip_to="torso")
    c.flat("tears", "zombie", 3.3, [P("lightning_bolt", cx - 22, ys + 60, 18, 40, rot=10), P("triangle", cx + 24, ys + 104, 26, 30, flip="y")],
           tags=("torso",), clip_to="shirt")
    c.add("belt", "leather", 3.4, [E(cx, yh - 4, 80, 10)], tags=("torso",))
    # idle arms reaching forward (hands in front of the chest, raised)
    b.arm_to("l", (cx - 40, ys + 58), elbow=(b.sh["l"][0] - 16, ys + 58))
    b.arm_to("r", (cx + 44, ys + 48), elbow=(b.sh["r"][0] + 14, ys + 52))
    b.arm("l", "zombie", z=5, upper=1.05, fore=1.0, hand=1.0, claws=0.9, fist=False)
    b.arm("r", "zombie", z=5, upper=1.05, fore=1.0, hand=1.0, claws=0.9, fist=False)
    c.add("sleeve_l", "cloth_rag", 5.1, [seg(b.sh["l"][0], ys, b.elbow["l"][0], b.elbow["l"][1], b.arm_w * 1.2)], tags=("arm_l",),
          pivot=list(b.sh["l"]))
    # attack: arms thrown wide, grabbing
    b.arm_to("l", (b.sh["l"][0] - 60, ys - 10), elbow=(b.sh["l"][0] - 36, ys + 36))
    b.arm("l", "zombie", z=5, upper=1.05, fore=1.0, hand=1.1, claws=1.0, fist=False, suffix="_atk", hidden=True, tags=("atk",))
    b.arm_to("r", (b.sh["r"][0] + 62, ys - 18), elbow=(b.sh["r"][0] + 38, ys + 30))
    b.arm("r", "zombie", z=5, upper=1.05, fore=1.0, hand=1.1, claws=1.0, fist=False, suffix="_atk", hidden=True, tags=("atk",))
    # head lolling to one side
    c.add("neck", "zombie", 6, [E(cx + 2, ys - 6, 24, 30)], tags=("head",))
    c.add("head", "zombie", 7, [E(cx + 6, hy0, 64, 70, rot=12), E(cx + 8, hy0 + 20, 48, 36, rot=12)], tags=("head",))
    c.add("hair", "hair", 7.2, [P("droplet", cx - 14, hy0 - 26, 12, 30, flip="y", rot=30), P("droplet", cx + 4, hy0 - 32, 12, 26, flip="y", rot=8),
                                P("droplet", cx + 24, hy0 - 26, 10, 24, flip="y", rot=-20)], tags=("head",))
    c.flat("sockets", "soot", 7.3, [E(cx - 6, hy0 - 4, 18, 14, rot=12), E(cx + 20, hy0 + 2, 18, 14, rot=12)], tags=("head",))
    c.glow("eyes", "glow_green", 7.4, [E(cx - 6, hy0 - 3, 7, 6), E(cx + 20, hy0 + 3, 7, 6)], tags=("head", "eyes"), color="glow_green_c",
           strength=0.5, opacity=0.3)
    c.flat("mouth", "mouth", 7.4, [E(cx + 8, hy0 + 24, 20, 12, rot=12)], tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.4, [E(cx + 8, hy0 + 26, 28, 24, rot=12)], tags=("head", "mouth_open"), hidden=True)
    c.flat("teeth", "tooth", 7.5, fangs(cx - 2, cx + 18, hy0 + 17, 3, 6), tags=("head", "mouth_open"), hidden=True,
           line={"width": 0.5, "heavy": 0.4})
    x_eyes(c, cx + 7, hy0, 13, 5, mat="soot", z=7.45, width=4, tags=("head",))
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"head": {"rot": -14, "dy": 8, "pivot": [cx, ys]}, "all": c.whole(s=1.05, dy=6, rot=-3)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"head": {"rot": 22, "dx": 8, "dy": -4, "pivot": [cx, ys]}, "arm_l": {"rot": 40, "pivot": sl}, "arm_r": {"rot": -40, "pivot": sr},
                  "all": c.whole(rot=-7, dy=-4, s=0.96)},
        shadow_hit_dx=-4,
    )
    c.meta.update(name_ko="좀비", size="사람")
    return c


# ---------------------------------------------------------------- A: ghost
@creature("ghost", "A")
def ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("ghost", (W, H), (cx, gy), seed=603,
                 note="Ghost, front view. Hovering pale blue-grey shroud spirit, see-through, with hollow dark eye holes "
                      "lit by cold cyan points, wailing mouth, wispy arms and a trailing tail. attack = swells and lunges "
                      "with arms outstretched, mouth screaming; hit = flickers flat and tilted, eyes squeezed.")
    c.shadow(cx, gy - 2, 110, 16, opacity=0.25, blur=7)
    ghost_op = 0.84
    c.add("tail", "ghost", 1, tube([(cx, 250), (cx + 20, 300), (cx - 10, 340)], 90, 16, n=10), tags=("body",), opacity=ghost_op)
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 50, 160)
        c.add(f"arm_{s}", "ghost", 2, tube([sh, (cx + k * 90, 200), (cx + k * 96, 250)], 34, 10, n=9), tags=(f"arm_{s}",),
              pivot=list(sh), opacity=ghost_op)
        c.add(f"arm_{s}_atk", "ghost", 2, tube([sh, (cx + k * 96, 150), (cx + k * 118, 124)], 36, 12, n=9), tags=("atk",),
              hidden=True, opacity=ghost_op)
    c.add("body", "ghost", 3, [P("ghost", cx, 190, 170, 190), E(cx, 142, 150, 120)], tags=("body",), opacity=ghost_op)
    c.flat("sockets", "void", 3.2, [E(cx - 30, 160, 34, 42, rot=-8), E(cx + 30, 160, 34, 42, rot=8)], tags=("eyes", "body"))
    c.glow("pupils", "glow_cyan", 3.3, [E(cx - 30, 164, 9, 9), E(cx + 30, 164, 9, 9)], tags=("eyes", "body"), color="ghost_glow_c",
           strength=1.0, opacity=0.7)
    x_eyes(c, cx, 162, 30, 10, mat="void", z=3.3, width=6, tags=("body",))
    c.flat("mouth", "void", 3.2, [E(cx, 214, 30, 36)], tags=("mouth", "body"))
    c.flat("mouth_open", "void", 3.2, [E(cx, 222, 48, 64)], tags=("mouth_open", "body"), hidden=True)
    c.add("wisps", "ghost", 0.5, [P("wind", cx - 90, 120, 50, 36), P("wind", cx + 96, 260, 46, 32, flip="x")], tags=("wisps",),
          opacity=0.5, line=False)
    std_frames(
        c,
        attack_move={"all": c.whole(s=1.06, dy=-10)},
        shadow_attack={"sx": 1.2, "sy": 1.2, "pivot": [cx, gy - 2]},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": -30, "pivot": [cx - 50, 160]}, "arm_r": {"rot": -20, "pivot": [cx + 50, 160]}, "wisps": {"dx": 10},
                  "all": c.whole(sx=1.08, sy=0.84, rot=-6, dx=4)},
        hit_show=("eyes_hit", "mouth_open"), hit_hide=("eyes", "mouth"), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="유령", size="사람")
    return c


# ---------------------------------------------------------------- A: vampire
@creature("vampire", "A")
def vampire():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("vampire", (W, H), (cx, gy), seed=604,
                 note="Vampire, front view. Pale gaunt undead noble: slicked-back black hair with a widow's peak, pointed "
                      "ears, red glowing eyes, fangs, high-collared black cape with wine lining, dark coat, bone-white "
                      "cravat, clawed hand raised. attack = cape flung open like bat wings, fangs bared, lunging; hit = "
                      "cape arm thrown over the face, recoiling.")
    b = Biped(c, cx, gy, 330, build=0.95, leg=0.47, torso=0.3, head=0.17, shoulder=0.14, hip=0.08, arm_w=0.055,
              leg_w=0.07, arm_len=0.37, stance=0.9)
    c.shadow(cx, gy - 2, 190, 22)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    # cape back (idle: hanging; attack: spread)
    c.add("cape_back", "robe_black", 0.5, [P("bell", cx, ys + 116, 170, 250, crop=[1.6, 1.4, 14.4, 11.6])], tags=("cape",))
    c.add("cape_lining", "cloth_wine", 0.6, [P("bell", cx, ys + 124, 140, 230, crop=[1.6, 1.4, 14.4, 11.6])], tags=("cape",),
          clip_to="cape_back")
    for s, k in (("l", -1), ("r", 1)):
        root = (cx + k * 36, ys + 6)
        c.add(f"cape_wing_{s}", "robe_black", 0.5, membrane(root, (cx + k * 130, ys - 56),
                                                            [(cx + k * 158, ys + 10), (cx + k * 150, ys + 90), (cx + k * 124, ys + 160)],
                                                            (cx + k * 60, ys + 190)), tags=("atk",), hidden=True)
        c.add(f"cape_wing_{s}_in", "cloth_wine", 0.6, membrane((cx + k * 40, ys + 16), (cx + k * 122, ys - 36),
                                                               [(cx + k * 144, ys + 16), (cx + k * 136, ys + 86), (cx + k * 114, ys + 148)],
                                                               (cx + k * 60, ys + 176)), tags=("atk",), hidden=True, line=False)
    b.legs("trouser", foot_mat="leather", foot="boot", z=1, thigh=1.0, shin=0.95)
    b.torso("coat_dark", z=3, chest=1.0, shape="slim")
    c.add("vest", "cloth_wine", 3.2, [P("droplet", cx, ys + 50, 36, 80, flip="y")], tags=("torso",))
    c.add("cravat", "paper", 3.4, [P("droplet", cx, ys + 22, 22, 34, flip="y"), E(cx, ys + 8, 26, 12)], tags=("torso",))
    c.add("brooch", "gem", 3.5, [E(cx, ys + 12, 10, 10)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 6, ys + 112), bend=0.06)
    b.arm_to("r", (b.sh["r"][0] + 30, ys + 36), elbow=(b.sh["r"][0] + 26, ys + 70))
    b.arm("l", "coat_dark", "pale", z=4, upper=1.2, fore=1.1, hand=1.1)
    b.arm("r", "coat_dark", "pale", z=4, upper=1.2, fore=1.1, hand=1.1, fist=False, claws=1.1, claw_mat="pale")
    # hit: forearm raised across the face (cape sleeve)
    b.arm_to("r", (cx - 10, hy0 + 4), elbow=(b.sh["r"][0] + 20, ys + 20))
    b.arm("r", "coat_dark", "pale", z=9, upper=1.2, fore=1.3, hand=1.1, suffix="_hit", hidden=True, tags=("guard",))
    c.add("collar", "robe_black", 5, [P("triangle", cx - 40, ys - 20, 44, 70, rot=-12), P("triangle", cx + 40, ys - 20, 44, 70, rot=12)],
          tags=("torso",))
    c.add("collar_in", "cloth_wine", 5.1, [P("triangle", cx - 36, ys - 14, 28, 48, rot=-12), P("triangle", cx + 36, ys - 14, 28, 48, rot=12)],
          tags=("torso",), line=False)
    c.add("neck", "pale", 6, [E(cx, ys - 6, 22, 24)], tags=("head",))
    c.add("ears", "pale", 6.5, sym([P("droplet", cx - 26, hy0 - 2, 12, 26, rot=-60)], cx), tags=("head",))
    c.add("head", "pale", 7, [E(cx, hy0, 46, 58), P("droplet", cx, hy0 + 16, 36, 32, flip="y")], tags=("head",))
    c.add("hair", "hair", 7.2, [E(cx, hy0 - 22, 52, 26), P("heart", cx, hy0 - 13, 30, 20)], tags=("head",))
    c.glow("eyes", "glow_red", 7.4, [E(cx - 10, hy0 - 2, 10, 5, rot=14), E(cx + 10, hy0 - 2, 10, 5, rot=-14)], tags=("head", "eyes"),
           color="glow_red_c", strength=0.8, opacity=0.5)
    c.flat("brows", "hair", 7.45, brows(cx, hy0 - 9, 10, 12, 3, tilt=22), tags=("head",))
    x_eyes(c, cx, hy0 - 2, 10, 4, z=7.45, width=3, tags=("head",))
    c.flat("mouth", "mouth", 7.4, [seg(cx - 8, hy0 + 18, cx + 8, hy0 + 18, 2.5)], tags=("head", "mouth"))
    c.flat("fang_idle", "tooth", 7.5, [P("triangle", cx - 5, hy0 + 21, 3.5, 6, flip="y"), P("triangle", cx + 5, hy0 + 21, 3.5, 6, flip="y")],
           tags=("head", "mouth"), line={"width": 0.4, "heavy": 0.3})
    c.flat("mouth_open", "mouth", 7.4, [E(cx, hy0 + 20, 20, 13)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.5, [P("triangle", cx - 6, hy0 + 18, 4.5, 9, flip="y"), P("triangle", cx + 6, hy0 + 18, 4.5, 9, flip="y")],
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"arm_l": {"rot": 70, "pivot": sl}, "arm_r": {"rot": -40, "pivot": sr}, "all": c.whole(s=1.05, dy=4)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "cape"),
        hit_move={"arm_l": {"rot": 30, "pivot": sl}, "head": {"rot": 12, "pivot": [cx, ys]}, "all": c.whole(rot=6, dx=6, dy=-4, s=0.96)},
        hit_show=("eyes_hit", "guard"), hit_hide=("eyes", "arm_r"), shadow_hit_dx=4,
    )
    c.meta.update(name_ko="흡혈귀", size="사람")
    return c


# ---------------------------------------------------------------- A: werewolf
@creature("werewolf", "A")
def werewolf():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("werewolf", (W, H), (cx, gy), seed=605,
                 note="Werewolf, front view. Hulking hunched wolf-man: dark shaggy fur, pale chest ruff, wolf head with "
                      "upright ears, long snout, yellow eyes and fangs, long clawed arms, bent digitigrade legs, torn "
                      "trousers. attack = claws raised high, jaws wide in a roar; hit = head knocked aside, staggering back.")
    b = Biped(c, cx, gy, 430, build=1.2, leg=0.42, torso=0.32, head=0.17, shoulder=0.17, hip=0.095, arm_w=0.075,
              leg_w=0.09, arm_len=0.46, stance=1.35, hunch=0.07)
    c.shadow(cx, gy - 2, 280, 32)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    # bent legs: knee forward-out, hock back
    for s, k in (("l", -1), ("r", 1)):
        hx, hy = b.hipj[s]
        kx, ky = hx + k * 30, yh + 70
        ax, ay = hx + k * 20, gy - 44
        fx, fy = hx + k * 40, gy - 10
        c.add(f"leg_{s}", "fur_dark", 1, [seg(hx, hy, kx, ky, 64), seg(kx, ky, ax, ay, 40), seg(ax, ay, fx, fy, 30)], tags=("legs",))
        c.add(f"foot_{s}", "fur_dark", 1.1, [E(fx + k * 6, fy, 54, 24)] + [P("triangle", fx + k * 6 + d * 14, fy + 12, 9, 16, rot=180)
                                                                         for d in (-1, 0, 1)], tags=("legs",))
    c.add("trousers", "cloth_blue", 1.3, [E(cx, yh + 10, 150, 60), P("bookmark", cx - 50, yh + 56, 40, 50, flip="y"),
                                          P("bookmark", cx + 52, yh + 50, 36, 44, flip="y")], tags=("legs",))
    c.add("torso", "fur_dark", 3, [E(cx, ys + 50, 220, 120), E(cx, yh - 40, 150, 110), E(cx, yh - 4, 130, 44)], tags=("torso",))
    c.add("ruff", "fur_grey", 3.2, [P("cloud", cx, ys + 34, 150, 70, flip="y"), P("droplet", cx, ys + 84, 70, 90, flip="y")],
          tags=("torso",), clip_to="torso")
    b.arm_to("l", (b.sh["l"][0] - 34, ys + 178), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 34, ys + 170), bend=0.14)
    b.arm("l", "fur_dark", z=4, upper=1.15, fore=1.0, hand=1.2, fist=False, claws=1.2)
    b.arm("r", "fur_dark", z=4, upper=1.15, fore=1.0, hand=1.2, fist=False, claws=1.2)
    b.arm_to("l", (b.sh["l"][0] - 70, ys - 56), elbow=(b.sh["l"][0] - 60, ys + 20))
    b.arm("l", "fur_dark", z=4, upper=1.15, fore=1.0, hand=1.25, fist=False, claws=1.3, suffix="_atk", hidden=True, tags=("atk",))
    b.arm_to("r", (b.sh["r"][0] + 70, ys - 50), elbow=(b.sh["r"][0] + 62, ys + 24))
    b.arm("r", "fur_dark", z=4, upper=1.15, fore=1.0, hand=1.25, fist=False, claws=1.3, suffix="_atk", hidden=True, tags=("atk",))
    # head
    c.add("mane", "fur_dark", 5, [P("cloud", cx, ys - 10, 190, 80), E(cx, ys + 6, 170, 60)], tags=("head",))
    c.add("ears", "fur_dark", 6.4, [P("triangle", cx - 40, hy0 - 44, 34, 60, rot=-20), P("triangle", cx + 40, hy0 - 44, 34, 60, rot=20)],
          tags=("head",))
    c.add("ears_in", "hide_pink", 6.45, [P("triangle", cx - 38, hy0 - 38, 16, 34, rot=-20), P("triangle", cx + 38, hy0 - 38, 16, 34, rot=20)],
          tags=("head",), line=False, opacity=0.6)
    c.add("head", "fur_dark", 7, [E(cx, hy0 - 6, 100, 84)], tags=("head",))
    c.add("cheeks", "fur_grey", 7.1, [P("cloud", cx, hy0 + 20, 110, 40, flip="y")], tags=("head",))
    c.add("snout", "fur_grey", 7.3, [E(cx, hy0 + 18, 50, 56)], tags=("head",))
    c.add("nose", "eye", 7.5, [E(cx, hy0 + 6, 22, 14)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.4, [E(cx - 26, hy0 - 14, 16, 9, rot=18), E(cx + 26, hy0 - 14, 16, 9, rot=-18)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.8, opacity=0.45)
    c.flat("pupils", "eye", 7.45, [E(cx - 26, hy0 - 14, 3.5, 8), E(cx + 26, hy0 - 14, 3.5, 8)], tags=("head", "eyes"))
    c.flat("brows", "eye", 7.46, brows(cx, hy0 - 24, 26, 26, 5, tilt=22), tags=("head",))
    x_eyes(c, cx, hy0 - 14, 26, 7, z=7.45, width=4.5, tags=("head",))
    c.flat("mouth", "mouth", 7.4, smile(cx, hy0 + 36, 40, 10, frown=True), tags=("head", "mouth"))
    c.flat("fang_idle", "tooth", 7.5, [P("triangle", cx - 12, hy0 + 36, 6, 12, flip="y"), P("triangle", cx + 12, hy0 + 36, 6, 12, flip="y")],
           tags=("head", "mouth"), line={"width": 0.5, "heavy": 0.4})
    c.flat("mouth_open", "mouth", 7.4, [E(cx, hy0 + 44, 50, 40)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.5, fangs(cx - 22, cx + 22, hy0 + 26, 5, 12) + fangs(cx - 16, cx + 16, hy0 + 64, 4, 10, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"head": {"rot": -4, "dy": -4, "pivot": [cx, ys]}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 24, "pivot": sl}, "arm_r": {"rot": -20, "pivot": sr}, "head": {"rot": 16, "pivot": [cx, ys]},
                  "all": c.whole(rot=6, dx=2, dy=-4, s=0.95)},
        shadow_hit_dx=2,
    )
    c.meta.update(name_ko="늑대인간", size="큼")
    return c



# ---------------------------------------------------------------- A: gargoyle
@creature("gargoyle", "A")
def gargoyle():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("gargoyle", (W, H), (cx, gy), seed=606,
                 note="Gargoyle, front view. Crouching weathered-stone demon: stone bat wings half open, swept-back horns, "
                      "pointed ears, glowing ember eyes, snarling fanged mouth, clawed hands on its knees, spade-tipped tail. "
                      "attack = springs up with wings flared and claws raised, mouth open; hit = knocked back, eye light "
                      "dimmed.")
    c.shadow(cx, gy - 2, 200, 24)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 40, 196), 128, 88, "stone_dark", "stone", 1, (f"wing_{s}", "wings"))
    c.add("tail", "stone_dark", 1.4, tube([(cx + 30, 330), (cx + 120, 356), (cx + 150, 300)], 26, 10, n=10), tags=("tail",))
    c.add("tail_tip", "stone", 1.5, [P("spade", cx + 152, 286, 26, 28)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"thigh_{s}", "stone_dark", 2, [E(cx + k * 56, 300, 66, 84, rot=k * -30)], tags=("legs",))
        c.add(f"foot_{s}", "stone_dark", 2.1, [E(cx + k * 70, 352, 60, 24)] + [P("triangle", cx + k * 70 + d * 16, 362, 9, 14, rot=180)
                                                                              for d in (-1, 0, 1)], tags=("legs",))
    c.add("torso", "stone", 3, [E(cx, 256, 124, 116), E(cx, 216, 150, 60)], tags=("torso",))
    c.flat("chest_crack", "void", 3.1, [P("lightning_bolt", cx + 20, 250, 12, 36, rot=-14)], tags=("torso",), clip_to="torso")
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 64, 214)
        arms[s] = list(sh)
        c.add(f"arm_{s}", "stone", 4, [seg(sh[0], sh[1], cx + k * 92, 272, 28), seg(cx + k * 92, 272, cx + k * 66, 312, 24)],
              tags=(f"arm_{s}",), pivot=list(sh))
        c.add(f"hand_{s}", "stone", 4.2, [E(cx + k * 64, 318, 30, 24)] + [P("triangle", cx + k * 64 + d * 9, 332, 6, 13, rot=180) for d in (-1, 0, 1)],
              tags=(f"arm_{s}",), pivot=list(sh))
        c.add(f"arm_{s}_atk", "stone", 4, [seg(sh[0], sh[1], cx + k * 110, 170, 28), seg(cx + k * 110, 170, cx + k * 118, 118, 24)],
              tags=("atk",), hidden=True)
        c.add(f"hand_{s}_atk", "stone", 4.2, [E(cx + k * 118, 110, 30, 26)] + [P("triangle", cx + k * 118 + d * 9, 94, 6, 14) for d in (-1, 0, 1)],
              tags=("atk",), hidden=True)
    c.add("horns", "stone_dark", 5.5, tube([(cx - 22, 138), (cx - 50, 114), (cx - 40, 76)], 16, 5, n=8)
          + tube([(cx + 22, 138), (cx + 50, 114), (cx + 40, 76)], 16, 5, n=8), tags=("head",))
    c.add("ears", "stone", 5.6, [P("triangle", cx - 44, 158, 22, 40, rot=-60), P("triangle", cx + 44, 158, 22, 40, rot=60)], tags=("head",))
    c.add("head", "stone", 6, [E(cx, 166, 76, 66), E(cx, 186, 58, 40)], tags=("head",))
    c.add("brow", "stone_dark", 6.2, [E(cx - 16, 154, 30, 12, rot=20), E(cx + 16, 154, 30, 12, rot=-20)], tags=("head",))
    c.glow("eyes", "ember", 6.3, [E(cx - 15, 162, 11, 8, rot=14), E(cx + 15, 162, 11, 8, rot=-14)], tags=("head", "eyes"),
           color="ember_glow", strength=0.9, opacity=0.5)
    c.flat("eyes_hit", "void", 6.3, [E(cx - 15, 163, 12, 4, rot=14), E(cx + 15, 163, 12, 4, rot=-14)], tags=("head", "eyes_hit"), hidden=True)
    c.flat("mouth", "void", 6.3, smile(cx, 194, 34, 12, frown=True), tags=("head", "mouth"))
    c.flat("fang_idle", "stone", 6.4, [P("triangle", cx - 10, 194, 5, 9, flip="y"), P("triangle", cx + 10, 194, 5, 9, flip="y")],
           tags=("head", "mouth"), line={"width": 0.5, "heavy": 0.4})
    c.flat("mouth_open", "void", 6.3, [E(cx, 198, 36, 26)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "bone_old", 6.4, fangs(cx - 14, cx + 14, 187, 4, 8) + fangs(cx - 10, cx + 10, 210, 3, 7, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    wl, wr = [cx - 40, 196], [cx + 40, 196]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 16, "pivot": wl}, "wing_r": {"rot": -16, "pivot": wr}, "all": c.whole(s=1.04, dy=-12)},
        shadow_attack={"sx": 0.85, "sy": 0.85, "pivot": [cx, gy - 2]},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"wing_l": {"rot": -14, "pivot": wl}, "wing_r": {"rot": 14, "pivot": wr}, "head": {"rot": 14, "pivot": [cx, 200]},
                  "all": c.whole(rot=6, dy=-4, s=0.95)},
        hit_show=("eyes_hit", "mouth_open"), hit_hide=("eyes", "mouth"), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="가고일", size="사람")
    return c


def plate_armor(c, b, mat, trim, tabard, z0=3.0):
    """Full plate on a Biped: breastplate, faulds, pauldrons, greaves drawn over the skeleton points."""
    cx, ys, yh = b.cx, b.y_sh, b.y_hip
    b.legs(mat, foot_mat=mat, foot="boot", z=1, thigh=1.15, shin=1.05)
    for s, k in (("l", -1), ("r", 1)):
        kx, ky = b.knee[s]
        c.add(f"knee_{s}", trim, 1.3, [E(kx, ky, b.leg_w * 1.2, b.leg_w * 0.9)], tags=("legs",))
    c.add("breastplate", mat, z0, [E(cx, ys + 30, b.sw * 2.1, b.H * 0.16), P("droplet", cx, ys + b.H * 0.16, b.sw * 1.7, b.H * 0.26, flip="y")],
          tags=("torso",))
    c.add("faulds", mat, z0 - 0.1, [P("bell", cx, yh + 10, b.hw * 2.6, b.H * 0.13, crop=[1.6, 1.4, 14.4, 11.6])], tags=("torso",))
    c.add("tabard", tabard, z0 + 0.2, [P("bookmark", cx, yh + b.H * 0.05, b.hw * 1.1, b.H * 0.22)], tags=("torso",))
    c.add("belt", "leather", z0 + 0.3, [E(cx, yh - 6, b.hw * 2.3, 12)], tags=("torso",))
    c.add("gorget", trim, z0 + 0.4, [E(cx, ys - 2, b.sw * 1.1, 22)], tags=("torso",))


# ---------------------------------------------------------------- A: living armor
@creature("living_armor", "A")
def living_armor():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("living_armor", (W, H), (cx, gy), seed=607,
                 note="Living armor, front view. Empty rust-stained plate armor animated by a dark void: great helm with a "
                      "slit through which two violet lights burn, wine tabard, kite shield, long sword. attack = sword "
                      "raised overhead behind the shield; hit = helm knocked askew, frame tilting, lights snuffed.")
    b = Biped(c, cx, gy, 330, build=1.05, leg=0.45, torso=0.3, head=0.16, shoulder=0.16, hip=0.09, arm_w=0.07,
              leg_w=0.085, arm_len=0.37, stance=1.1)
    c.shadow(cx, gy - 2, 170, 22)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    plate_armor(c, b, "armor", "armor_dark", "cloth_wine")
    b.arm_to("l", (b.sh["l"][0] - 16, ys + 96), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 10, ys + 110), bend=0.08)
    b.arm("l", "armor", z=4, upper=1.1, fore=1.0, hand=1.2)
    b.arm("r", "armor", z=4, upper=1.1, fore=1.0, hand=1.2)
    hx, hy = b.hand["r"]
    c.add("sword", "armor", 3.9, [held("sword", (hx, hy), 128, 94, grip=0.3)], tags=("arm_r",), pivot=list(b.sh["r"]))
    lx, ly = b.hand["l"]
    c.add("shield", "armor_dark", 4.6, [heater_shield(lx - 8, ly - 6, 86, 116)], tags=("arm_l", "shield"), pivot=list(b.sh["l"]))
    c.add("shield_face", "cloth_wine", 4.65, [heater_shield(lx - 8, ly - 10, 64, 88)], tags=("arm_l", "shield"), pivot=list(b.sh["l"]))
    c.add("shield_band", "armor", 4.7, [P("square", lx - 8, ly - 16, 12, 90, rot=-30)], tags=("arm_l", "shield"), pivot=list(b.sh["l"]),
          clip_to="shield_face")
    b.arm_to("r", (b.sh["r"][0] + 20, ys - 30), elbow=(b.sh["r"][0] + 42, ys + 12))
    b.arm("r", "armor", z=4, upper=1.1, fore=1.0, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    c.add("sword_atk", "armor", 3.9, [held("sword", b.hand["r"], 112, -155, grip=0.45)], tags=("atk",), hidden=True)
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = b.sh[s]
        c.add(f"pauldron_{s}", "armor", 5, [E(sx + k * 4, sy + 2, 58, 44, rot=k * 14)], tags=(f"pauldron",))
    c.add("helm", "armor", 7, [E(cx, hy0 - 6, 58, 50), P("square", cx, hy0 + 12, 54, 40)], tags=("head",))
    c.add("helm_crest", "armor_dark", 7.1, [P("square", cx, hy0 - 8, 8, 56)], tags=("head",), clip_to="helm")
    c.flat("visor", "void", 7.2, [P("square", cx, hy0 + 4, 44, 9)], tags=("head",))
    c.glow("eyes", "glow_violet", 7.3, [E(cx - 10, hy0 + 4, 8, 5), E(cx + 10, hy0 + 4, 8, 5)], tags=("head", "eyes"),
           color="glow_violet_c", strength=1.0, opacity=0.6)
    c.flat("breaths", "armor_dark", 7.25, [P("square", cx + d * 8, hy0 + 24, 3, 10) for d in (-2, -1, 0, 1, 2)], tags=("head",))
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"shield": {"dx": 8, "dy": -10}, "head": {"rot": -4, "pivot": [cx, ys]}, "all": c.whole(s=1.04, dy=4)},
        attack_show=("atk",), attack_hide=("arm_r",),
        hit_move={"head": {"rot": 24, "dx": 12, "dy": 4, "pivot": [cx, ys]}, "arm_r": {"rot": -10, "pivot": sr}, "arm_l": {"rot": 14, "pivot": sl},
                  "all": c.whole(rot=-6, dy=-4, s=0.96)},
        hit_show=(), hit_hide=("eyes",), shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="살아 있는 갑옷", size="사람")
    return c


# ---------------------------------------------------------------- A: demon
@creature("demon", "A")
def demon():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("demon", (W, H), (cx, gy), seed=608,
                 note="Demon, front view. Towering dark-crimson fiend: great ram-like horns, burning yellow eyes, wide "
                      "fanged grin, crimson bat wings, clawed hands, shaggy goat legs with hooves, spade-tipped tail. "
                      "attack = wings flung wide and both claws raised, roaring; hit = wings buckle, head thrown back.")
    b = Biped(c, cx, gy, 420, build=1.2, leg=0.42, torso=0.31, head=0.16, shoulder=0.17, hip=0.095, arm_w=0.07,
              leg_w=0.09, arm_len=0.42, stance=1.3, hunch=0.03)
    c.shadow(cx, gy - 2, 270, 30)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 50, ys + 10), 166, 110, "membrane_red", "demon", 0.5, (f"wing_{s}", "wings"))
    c.add("tail", "demon", 0.8, tube([(cx + 20, yh + 10), (cx + 140, yh + 90), (cx + 190, yh + 20)], 22, 8, n=12), tags=("tail",))
    c.add("tail_tip", "demon", 0.9, [P("spade", cx + 194, yh - 2, 30, 34, rot=30)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        hx, hy = b.hipj[s]
        kx, ky = hx + k * 26, yh + 76
        ax, ay = hx + k * 12, gy - 40
        c.add(f"leg_{s}", "fur_dark", 1, [E(hx + k * 8, hy + 30, 78, 100), seg(kx, ky, ax, ay, 34), seg(ax, ay, hx + k * 24, gy - 14, 26)],
              tags=("legs",))
        c.add(f"hoof_{s}", "horn", 1.1, [P("cylinder", hx + k * 26, gy - 10, 34, 24)], tags=("legs",))
    b.torso("demon", z=3, chest=1.05, shape="chest")
    c.flat("abs", "demon", 3.1, [seg(cx - 20, ys + 90, cx + 20, ys + 90, 3), seg(cx - 18, ys + 110, cx + 18, ys + 110, 3), seg(cx, ys + 40, cx, ys + 124, 3)],
           tags=("torso",), color="coat_seam", opacity=0.35)
    c.add("loin", "robe_black", 3.3, [P("bookmark", cx, yh + 30, 60, 56), E(cx, yh + 2, 120, 22)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 28, ys + 160), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 28, ys + 156), bend=0.12)
    b.arm("l", "demon", z=4, upper=1.1, fore=1.0, hand=1.2, fist=False, claws=1.1, claw_mat="claw")
    b.arm("r", "demon", z=4, upper=1.1, fore=1.0, hand=1.2, fist=False, claws=1.1, claw_mat="claw")
    b.arm_to("l", (b.sh["l"][0] - 60, ys - 70), elbow=(b.sh["l"][0] - 56, ys + 10))
    b.arm("l", "demon", z=4, upper=1.1, fore=1.0, hand=1.3, fist=False, claws=1.3, suffix="_atk", hidden=True, tags=("atk",))
    b.arm_to("r", (b.sh["r"][0] + 60, ys - 66), elbow=(b.sh["r"][0] + 58, ys + 12))
    b.arm("r", "demon", z=4, upper=1.1, fore=1.0, hand=1.3, fist=False, claws=1.3, suffix="_atk", hidden=True, tags=("atk",))
    c.add("horns", "horn", 6.4, tube([(cx - 26, hy0 - 26), (cx - 90, hy0 - 60), (cx - 70, hy0 + 10), (cx - 52, hy0 - 16)], 24, 7, n=14)
          + tube([(cx + 26, hy0 - 26), (cx + 90, hy0 - 60), (cx + 70, hy0 + 10), (cx + 52, hy0 - 16)], 24, 7, n=14), tags=("head",))
    c.add("ears", "demon", 6.5, sym([P("triangle", cx - 38, hy0 + 2, 16, 30, rot=-70)], cx), tags=("head",))
    c.add("head", "demon", 7, [E(cx, hy0, 66, 64), P("droplet", cx, hy0 + 20, 54, 44, flip="y")], tags=("head",))
    c.add("brow", "demon", 7.3, [E(cx - 14, hy0 - 12, 28, 12, rot=22), E(cx + 14, hy0 - 12, 28, 12, rot=-22)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.2, [E(cx - 14, hy0 - 4, 13, 7, rot=18), E(cx + 14, hy0 - 4, 13, 7, rot=-18)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=1.0, opacity=0.6)
    x_eyes(c, cx, hy0 - 4, 14, 5, z=7.35, width=3.5, tags=("head",))
    c.flat("mouth", "mouth", 7.3, smile(cx, hy0 + 22, 40, 14), tags=("head", "mouth"))
    c.flat("grin_teeth", "tooth", 7.4, fangs(cx - 16, cx + 16, hy0 + 20, 6, 6), tags=("head", "mouth"), line={"width": 0.4, "heavy": 0.3})
    c.flat("mouth_open", "mouth", 7.3, [E(cx, hy0 + 26, 40, 30)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.4, fangs(cx - 16, cx + 16, hy0 + 13, 4, 10) + fangs(cx - 12, cx + 12, hy0 + 41, 3, 8, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    c.add("goatee", "fur_dark", 7.35, [P("droplet", cx, hy0 + 44, 14, 22, flip="y")], tags=("head", "mouth"))
    wl, wr = [cx - 50, ys + 10], [cx + 50, ys + 10]
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 14, "pivot": wl}, "wing_r": {"rot": -14, "pivot": wr}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"wing_l": {"rot": -18, "pivot": wl}, "wing_r": {"rot": 18, "pivot": wr}, "arm_l": {"rot": 24, "pivot": sl},
                  "arm_r": {"rot": -24, "pivot": sr}, "head": {"rot": -14, "dy": -4, "pivot": [cx, ys]}, "all": c.whole(rot=-5, dy=-4, s=0.95)},
        shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="악마", size="큼")
    return c


# ---------------------------------------------------------------- A: ghoul
@creature("ghoul", "A")
def ghoul():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("ghoul", (W, H), (cx, gy), seed=609,
                 note="Ghoul, front view. Gaunt grey-violet corpse-eater crouched low: bald head with long pointed ears, "
                      "sunken glowing eyes, wide mouth crowded with teeth, bony shoulders, long arms with hooked claws "
                      "touching the ground, rag loincloth. attack = pounces up with both claws spread, mouth gaping; hit = "
                      "flinches back, eyes squeezed.")
    c.shadow(cx, gy - 2, 200, 24)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"thigh_{s}", "ghoul", 1, [E(cx + k * 44, 312, 44, 70, rot=k * -34), seg(cx + k * 60, 334, cx + k * 50, 358, 22)], tags=("legs",))
        c.add(f"foot_{s}", "ghoul", 1.1, [E(cx + k * 54, 360, 40, 16)] + [P("triangle", cx + k * 54 + d * 11, 368, 6, 10, rot=180) for d in (-1, 0, 1)],
              tags=("legs",))
    c.add("torso", "ghoul", 2, [E(cx, 262, 100, 110), E(cx, 226, 128, 50)], tags=("torso",))
    c.flat("ribs", "ghoul", 2.1, [p for i in range(3) for p in smile(cx, 244 + i * 14, 70 - i * 8, 6, depth=0.6)], tags=("torso",),
           color="coat_seam", opacity=0.4)
    c.add("loin", "cloth_rag", 2.3, [P("bookmark", cx, 318, 50, 40), E(cx, 302, 84, 16)], tags=("torso",))
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 58, 226)
        arms[s] = list(sh)
        c.add(f"arm_{s}", "ghoul", 3, [E(sh[0], sh[1], 34, 30), seg(sh[0], sh[1], cx + k * 92, 290, 20), seg(cx + k * 92, 290, cx + k * 84, 346, 16)],
              tags=(f"arm_{s}",), pivot=list(sh))
        c.add(f"claw_{s}", "claw", 3.2, [seg(cx + k * 84, 346, cx + k * (84 + d * 10), 364, 5) for d in (-1.2, 0, 1.2)] + [E(cx + k * 84, 344, 20, 14)],
              tags=(f"arm_{s}",), pivot=list(sh))
        c.add(f"arm_{s}_atk", "ghoul", 3, [E(sh[0], sh[1], 34, 30), seg(sh[0], sh[1], cx + k * 110, 180, 20), seg(cx + k * 110, 180, cx + k * 116, 124, 16)],
              tags=("atk",), hidden=True)
        c.add(f"claw_{s}_atk", "claw", 3.2, [seg(cx + k * 116, 124, cx + k * (116 + d * 12), 100, 5) for d in (-1.2, 0, 1.2)] + [E(cx + k * 116, 126, 20, 14)],
              tags=("atk",), hidden=True)
    c.add("ears", "ghoul", 4.5, [P("droplet", cx - 50, 160, 20, 58, rot=-70), P("droplet", cx + 50, 160, 20, 58, rot=70)], tags=("head",))
    c.add("head", "ghoul", 5, [E(cx, 168, 70, 70), E(cx, 192, 54, 40)], tags=("head",))
    c.flat("sockets", "soot", 5.2, [E(cx - 15, 166, 20, 16, rot=12), E(cx + 15, 166, 20, 16, rot=-12)], tags=("head",))
    c.glow("eyes", "glow_yellow", 5.3, [E(cx - 15, 167, 7, 6), E(cx + 15, 167, 7, 6)], tags=("head", "eyes"), color="glow_yellow_c",
           strength=0.8, opacity=0.5)
    x_eyes(c, cx, 167, 15, 6, mat="soot", z=5.35, width=4, tags=("head",))
    c.flat("mouth", "mouth", 5.3, smile(cx, 196, 44, 14, depth=0.3), tags=("head", "mouth"))
    c.flat("teeth", "tooth", 5.4, fangs(cx - 18, cx + 18, 194, 7, 6), tags=("head", "mouth"), line={"width": 0.4, "heavy": 0.3})
    c.flat("mouth_open", "mouth", 5.3, [E(cx, 202, 48, 34)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 5.4, fangs(cx - 20, cx + 20, 188, 7, 9) + fangs(cx - 16, cx + 16, 218, 6, 8, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.4, "heavy": 0.3})
    std_frames(
        c,
        attack_move={"all": c.whole(s=1.04, dy=-18)},
        shadow_attack={"sx": 0.8, "sy": 0.8, "pivot": [cx, gy - 2]},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"head": {"rot": 16, "pivot": [cx, 214]}, "arm_l": {"rot": 22, "pivot": arms["l"]}, "arm_r": {"rot": -30, "pivot": arms["r"]},
                  "all": c.whole(rot=-7, dy=-6, s=0.96)},
        shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="구울", size="사람")
    return c


# ---------------------------------------------------------------- A: headless knight
@creature("headless_knight", "A")
def headless_knight():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("headless_knight", (W, H), (cx, gy), seed=610,
                 note="Headless knight, front view. Blackened plate armor with a tattered wine cape and no head: a cold "
                      "cyan ghost-flame rises from the neck, its own helm (eyes still glowing inside) carried under the "
                      "left arm, long sword in the right. attack = sword raised overhead, flame flaring; hit = staggers "
                      "back, flame blown sideways.")
    b = Biped(c, cx, gy, 318, build=1.1, leg=0.46, torso=0.31, head=0.12, shoulder=0.165, hip=0.09, arm_w=0.07,
              leg_w=0.085, arm_len=0.37, stance=1.15)
    c.shadow(cx, gy - 2, 190, 24)
    ys, yh = b.y_sh, b.y_hip
    c.add("cape", "cloth_wine", 0.5, [P("bell", cx, ys + 120, 190, 250, crop=[1.6, 1.4, 14.4, 11.6]),
                                      P("mountains", cx, ys + 238, 180, 40, op="sub")], tags=("cape",))
    plate_armor(c, b, "armor_dark", "armor", "robe_black")
    b.arm_to("l", (cx - 26, ys + 70), elbow=(b.sh["l"][0] - 18, ys + 70))
    b.arm_to("r", (b.sh["r"][0] + 12, ys + 110), bend=0.08)
    b.arm("l", "armor_dark", z=6, upper=1.1, fore=1.0, hand=1.2)
    b.arm("r", "armor_dark", z=4, upper=1.1, fore=1.0, hand=1.2)
    hx, hy = b.hand["r"]
    c.add("sword", "armor", 3.9, [held("sword", (hx, hy), 130, 96, grip=0.28)], tags=("arm_r",), pivot=list(b.sh["r"]))
    # carried helm (under the left arm)
    lx, ly = cx - 50, ys + 64
    c.add("helm_carried", "armor_dark", 5.5, [E(lx, ly - 6, 60, 52), P("square", lx, ly + 12, 56, 38)], tags=("arm_l", "helm"),
          pivot=list(b.sh["l"]))
    c.flat("helm_visor", "void", 5.6, [P("square", lx, ly + 3, 44, 10)], tags=("arm_l", "helm"), pivot=list(b.sh["l"]))
    c.glow("eyes", "glow_cyan", 5.7, [E(lx - 9, ly + 3, 9, 5), E(lx + 9, ly + 3, 9, 5)], tags=("arm_l", "helm", "eyes"),
           color="ghost_glow_c", strength=1.0, opacity=0.6, pivot=list(b.sh["l"]))
    b.arm_to("r", (b.sh["r"][0] + 20, ys - 30), elbow=(b.sh["r"][0] + 42, ys + 12))
    b.arm("r", "armor_dark", z=4, upper=1.1, fore=1.0, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    c.add("sword_atk", "armor", 3.9, [held("sword", b.hand["r"], 112, -155, grip=0.45)], tags=("atk",), hidden=True)
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = b.sh[s]
        c.add(f"pauldron_{s}", "armor_dark", 5, [E(sx + k * 4, sy + 2, 60, 46, rot=k * 14)], tags=("pauldron",))
        c.add(f"spike_{s}", "armor", 4.9, [P("triangle", sx + k * 12, sy - 26, 12, 22, rot=k * 20)], tags=("pauldron",))
    c.add("neck_ring", "armor", 6.5, [E(cx, ys - 4, 50, 18)], tags=("torso",))
    c.add("flame", "ghost_glow", 6.4, [P("fire", cx, ys - 44, 56, 76), P("fire", cx - 12, ys - 30, 30, 44, rot=-14, flip="x")],
          tags=("flame",), emit=0.9, opacity=0.85, line={"width": 0.7, "heavy": 0.5}, glow={"radius": 4, "opacity": 0.4, "color": "ghost_glow_c"})
    c.add("flame_core", "glow_white", 6.45, [P("fire", cx, ys - 34, 26, 40)], tags=("flame",), emit=1.0, line=False, opacity=0.8)
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"flame": {"sx": 1.15, "sy": 1.2, "pivot": [cx, ys]}, "all": c.whole(s=1.04, dy=4)},
        attack_show=("atk",), attack_hide=("arm_r",),
        hit_move={"flame": {"rot": -30, "pivot": [cx, ys]}, "arm_r": {"rot": -10, "pivot": sr}, "arm_l": {"rot": 10, "pivot": sl},
                  "all": c.whole(rot=6, dx=2, dy=-4, s=0.96)},
        hit_show=(), hit_hide=(), shadow_hit_dx=2,
    )
    c.meta.update(name_ko="머리 없는 기사", size="사람")
    return c


# ================================================================ B (idle only)
@creature("robed_skeleton", "B")
def robed_skeleton():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("robed_skeleton", (W, H), (cx, gy), seed=621,
                 note="Robed skeleton (skeleton mage), front view. Hooded skull with violet eye lights inside a tattered "
                      "black robe, bony hands, one raised with a crackle of violet light, the other gripping a gnarled staff "
                      "topped with a glowing gem.")
    c.shadow(cx, gy - 2, 170, 22)
    c.add("robe", "robe_black", 2, [P("bell", cx, 250, 170, 240, crop=[1.6, 1.4, 14.4, 11.6]), P("mountains", cx, 364, 170, 30, op="sub")],
          tags=("body",))
    c.add("robe_trim", "cloth_wine", 2.1, [P("square", cx, 250, 16, 230)], tags=("body",), clip_to="robe", opacity=0.9)
    c.add("rope", "bone_old", 2.2, [E(cx, 214, 96, 10)], tags=("body",))
    c.add("staff", "bark", 1.8, [seg(cx + 70, 360, cx + 74, 90, 9), E(cx + 74, 86, 24, 24)], tags=("staff",))
    c.glow("gem", "glow_violet", 1.9, [P("diamond", cx + 74, 76, 22, 30)], tags=("staff",), color="glow_violet_c", strength=1.0, opacity=0.6)
    c.add("sleeve_r", "robe_black", 3, [seg(cx + 40, 150, cx + 66, 196, 34)], tags=("arms",))
    c.add("hand_r", "bone", 3.1, claw_hand(cx + 72, 204, -80, 16), tags=("arms",))
    c.add("sleeve_l", "robe_black", 3, [seg(cx - 40, 150, cx - 76, 150, 34)], tags=("arms",))
    c.add("hand_l", "bone", 3.1, claw_hand(cx - 96, 146, -110, 16), tags=("arms",))
    c.glow("spell", "glow_violet", 3.2, [P("lightning_bolt", cx - 104, 112, 16, 34, rot=10), P("star", cx - 92, 124, 12, 12)], tags=("arms",),
           color="glow_violet_c", strength=1.0, opacity=0.5)
    c.add("hood", "robe_black", 4, [P("droplet", cx, 112, 100, 120), E(cx, 140, 100, 60)], tags=("head",))
    c.flat("hood_in", "void", 4.1, [E(cx, 126, 64, 70)], tags=("head",))
    c.add("skull", "bone", 4.2, [P("skull", cx, 128, 50, 54)], tags=("head",))
    c.glow("eyes", "glow_violet", 4.3, [E(cx - 9, 124, 6, 6), E(cx + 9, 124, 6, 6)], tags=("head",), color="glow_violet_c", strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="로브 입은 해골", size="사람")
    return c


@creature("bone_dog", "B")
def bone_dog():
    W, H = 384, 384
    gy = 366
    c = Creature("bone_dog", (W, H), (200, gy), seed=622,
                 note="Bone dog, 3/4 front view facing the lower left. Skeletal hound: long canine skull with red eye "
                      "lights, spine and rib cage, bone legs, a whip of tail vertebrae, rusty broken chain collar.")
    c.shadow(206, gy - 4, 260, 28)
    bones_limb(c, "leg_hind_far", [(290, 236), (306, 296), (300, 346)], 11, "bone_old", 1, ("legs",), (290, 236))
    bones_limb(c, "leg_front_far", [(172, 246), (180, 300), (176, 346)], 11, "bone_old", 1, ("legs",), (172, 246))
    c.add("tail", "bone", 1.5, [E(306 + i * 9, 206 - i * 6 + i * i * 1.0, 12 - i, 10 - i) for i in range(7)], tags=("tail",))
    c.add("spine", "bone", 2, [E(170 + i * 16, 206 + (i - 4) ** 2 * 0.6, 13, 11) for i in range(9)], tags=("body",))
    c.add("ribs", "bone", 2.2, [P("moon", 180 + i * 18, 236, 30, 40 - i * 3, rot=-45) for i in range(5)], tags=("body",))
    c.add("pelvis", "bone", 2.3, [E(292, 226, 40, 30)], tags=("body",))
    bones_limb(c, "leg_hind", [(292, 236), (312, 298), (304, 352)], 13, "bone", 3, ("legs",), (292, 236))
    bones_limb(c, "leg_front", [(150, 242), (140, 300), (134, 350)], 13, "bone", 3.1, ("legs",), (150, 242))
    for x in (304, 134, 300, 176):
        c.add(f"paw_{x}", "bone", 3.2, [E(x - 6, 356, 26, 10)], tags=("legs",))
    c.add("chain", "iron", 3.4, [P("ring", 150 + i * 12, 206 + i * 6, 12, 10, rot=i * 40) for i in range(4)], tags=("head",))
    c.flat("skull_void", "void", 3.9, [E(104, 186, 50, 30)], tags=("head",))
    c.add("skull", "bone", 4, [E(120, 176, 70, 56), P("droplet", 84, 204, 34, 70, rot=-128)], tags=("head",))
    c.flat("sockets", "void", 4.1, [E(108, 172, 18, 14, rot=20), E(136, 166, 14, 12)], tags=("head",))
    c.glow("eyes", "glow_red", 4.2, [E(108, 172, 7, 6), E(136, 166, 6, 5)], tags=("head",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.flat("teeth_line", "void", 4.1, [seg(64, 226, 104, 212, 4)], tags=("head",))
    c.flat("teeth", "bone_old", 4.15, [P("triangle", 74 + i * 9, 222 - i * 3, 5, 9, flip="y") for i in range(4)], tags=("head",))
    c.add("jaw", "bone", 3.95, [P("droplet", 92, 228, 20, 56, rot=-112)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="뼈 개", size="사람")
    return c


@creature("wraith", "B")
def wraith():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("wraith", (W, H), (cx, gy), seed=623,
                 note="Wraith, front view, floating. Tall hooded shade in a tattered black shroud that frays into wisps "
                      "below, a void where the face should be with two cold cyan eye points, long skeletal hands "
                      "reaching out, ghostly pale edges.")
    c.shadow(cx, gy - 2, 110, 16, opacity=0.25, blur=7)
    c.add("shroud", "robe_black", 2, [P("bell", cx, 214, 160, 260, crop=[1.6, 1.4, 14.4, 11.6]), P("mountains", cx, 330, 150, 60, op="sub")],
          tags=("body",), opacity=0.92)
    c.add("wisps", "ghost", 1.8, [P("droplet", cx - 40, 320, 26, 60, flip="y", rot=10), P("droplet", cx + 10, 334, 24, 56, flip="y"),
                                  P("droplet", cx + 50, 318, 22, 54, flip="y", rot=-12)], tags=("body",), opacity=0.55, line=False)
    c.add("edge", "ghost", 2.1, [P("bell", cx, 214, 160, 260, crop=[1.6, 1.4, 14.4, 11.6]), P("bell", cx, 222, 138, 240, crop=[1.6, 1.4, 14.4, 11.6], op="sub")],
          tags=("body",), opacity=0.5, line=False)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"sleeve_{s}", "robe_black", 2.5, tube([(cx + k * 40, 140), (cx + k * 90, 170), (cx + k * 112, 200)], 36, 26, n=8, cap=True),
              tags=("arms",), opacity=0.92)
        c.add(f"hand_{s}", "bone", 2.6, claw_hand(cx + k * 118, 210, 90 - k * 40, 22, n=4, spread=18), tags=("arms",))
    c.add("hood", "robe_black", 3, [P("droplet", cx, 96, 110, 130), E(cx, 126, 110, 60)], tags=("head",))
    c.flat("face_void", "void", 3.1, [E(cx, 116, 64, 74)], tags=("head",))
    c.glow("eyes", "glow_cyan", 3.2, [E(cx - 12, 112, 8, 6), E(cx + 12, 112, 8, 6)], tags=("head",), color="ghost_glow_c", strength=1.0, opacity=0.7)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="망자", size="사람")
    return c


@creature("pumpkin_ghost", "B")
def pumpkin_ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("pumpkin_ghost", (W, H), (cx, gy), seed=624,
                 note="Pumpkin ghost, front view, floating. Carved dull-orange pumpkin head with ember-lit triangle eyes "
                      "and a jagged grin, curly vine stem, a tattered pale ghost cloak below with wispy arms.")
    c.shadow(cx, gy - 2, 110, 16, opacity=0.25, blur=7)
    c.add("cloak", "ghost", 1.5, [P("ghost", cx, 250, 150, 170)], tags=("body",), opacity=0.84)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "ghost", 1.6, tube([(cx + k * 50, 222), (cx + k * 94, 240), (cx + k * 100, 280)], 28, 8, n=8, cap=True), tags=("arms",),
              opacity=0.84)
    c.add("pumpkin", "pumpkin", 3, [E(cx, 150, 150, 120), E(cx - 44, 152, 70, 110), E(cx + 44, 152, 70, 110)], tags=("head",))
    c.flat("ribs", "pumpkin", 3.1, [seg(cx - 22, 100, cx - 26, 200, 3), seg(cx + 22, 100, cx + 26, 200, 3), seg(cx - 56, 108, cx - 64, 192, 3),
                                    seg(cx + 56, 108, cx + 64, 192, 3)], tags=("head",), color="coat_seam", opacity=0.4)
    c.add("stem", "bark", 2.9, [seg(cx + 2, 96, cx + 8, 70, 14)], tags=("head",))
    c.add("vine", "leaf", 2.95, [P("spiral", cx + 30, 74, 30, 28), P("leaf", cx - 18, 84, 28, 20, rot=-30)], tags=("head",))
    c.glow("face", "fire_mid", 3.2, [P("triangle", cx - 32, 136, 34, 30), P("triangle", cx + 32, 136, 34, 30), P("triangle", cx, 158, 14, 12),
                                     E(cx, 186, 96, 30), P("mountains", cx, 176, 90, 16, op="sub"), P("square", cx - 20, 198, 12, 10, op="sub"),
                                     P("square", cx + 20, 198, 12, 10, op="sub")], tags=("head",), color="ember_glow", strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="호박 유령", size="사람")
    return c


@creature("giant_knight", "B")
def giant_knight():
    W, H = 512, 768
    cx, gy = 256, 748
    c = Creature("giant_knight", (W, H), (cx, gy), seed=625,
                 note="Giant knight, front view (twice human height). Colossal dark plate armour with tarnished gold trim, "
                      "a tall plumed great helm with violet eye light in the slit, torn wine cape, both gauntlets resting on "
                      "the pommel of a huge greatsword planted point-down in front.")
    b = Biped(c, cx, gy, 690, build=1.15, leg=0.45, torso=0.3, head=0.13, shoulder=0.165, hip=0.09, arm_w=0.07,
              leg_w=0.085, arm_len=0.36, stance=1.2)
    c.shadow(cx, gy - 2, 380, 44)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    c.add("cape", "cloth_wine", 0.5, [P("bell", cx, ys + 240, 360, 500, crop=[1.6, 1.4, 14.4, 11.6]), P("mountains", cx, ys + 480, 340, 60, op="sub")],
          tags=("cape",))
    plate_armor(c, b, "armor_dark", "gold", "cloth_wine")
    b.arm_to("l", (cx - 20, yh - 20), elbow=(b.sh["l"][0] - 30, ys + 120))
    b.arm_to("r", (cx + 20, yh - 20), elbow=(b.sh["r"][0] + 30, ys + 120))
    b.arm("l", "armor_dark", "armor", z=5, upper=1.15, fore=1.05, hand=1.3)
    b.arm("r", "armor_dark", "armor", z=5, upper=1.15, fore=1.05, hand=1.3)
    c.add("blade", "armor", 4.6, [P("square", cx, yh + 150, 44, 280), P("triangle", cx, yh + 304, 44, 40, flip="y")], tags=("sword",))
    c.flat("fuller", "armor_dark", 4.65, [P("square", cx, yh + 150, 8, 250)], tags=("sword",), opacity=0.7)
    c.add("guard", "gold", 4.7, [P("square", cx, yh + 6, 150, 20)], tags=("sword",))
    c.add("grip", "leather", 4.55, [P("square", cx, yh - 30, 18, 70)], tags=("sword",))
    c.add("pommel", "gold", 4.8, [E(cx, yh - 70, 30, 30)], tags=("sword",))
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = b.sh[s]
        c.add(f"pauldron_{s}", "armor_dark", 5.5, [E(sx + k * 6, sy + 4, 110, 80, rot=k * 14)], tags=("pauldron",))
        c.add(f"pauldron_trim_{s}", "gold", 5.55, [E(sx + k * 6, sy + 24, 104, 30, rot=k * 14)], tags=("pauldron",), clip_to=f"pauldron_{s}")
    c.add("helm", "armor_dark", 7, [E(cx, hy0 - 6, 96, 80), P("square", cx, hy0 + 20, 88, 60)], tags=("head",))
    c.add("plume", "cloth_wine", 6.9, [P("feather", cx + 10, hy0 - 70, 50, 90, rot=10)], tags=("head",))
    c.add("helm_trim", "gold", 7.1, [P("square", cx, hy0 - 4, 10, 90)], tags=("head",), clip_to="helm")
    c.flat("visor", "void", 7.2, [P("square", cx, hy0 + 8, 70, 12)], tags=("head",))
    c.glow("eyes", "glow_violet", 7.3, [E(cx - 16, hy0 + 8, 12, 6), E(cx + 16, hy0 + 8, 12, 6)], tags=("head",), color="glow_violet_c",
           strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 기사", size="거대")
    return c


@creature("imp", "B")
def imp():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("imp", (W, H), (cx, gy), seed=626,
                 note="Imp, front view, hovering. Small pot-bellied red-brown devil with bat wings, big pointed ears, stubby "
                      "horns, glowing yellow eyes, a wide fanged grin, pointed tail and a little bronze pitchfork.")
    c.shadow(cx, gy - 2, 100, 14, opacity=0.28, blur=6)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 18, 200), 96, 56, "membrane_red", "imp", 1, ("wings",))
    c.add("tail", "imp", 1.2, tube([(cx + 10, 262), (cx + 70, 290), (cx + 86, 250)], 10, 4, n=8, cap=True) + [P("spade", cx + 88, 240, 18, 20, rot=20)],
          tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "imp", 1.5, [seg(cx + k * 14, 264, cx + k * 22, 296, 14), E(cx + k * 26, 302, 20, 10)], tags=("legs",))
    c.add("body", "imp", 2, [E(cx, 238, 66, 70)], tags=("body",))
    c.add("belly", "hide_pink", 2.1, [E(cx, 248, 40, 40)], tags=("body",), clip_to="body", opacity=0.5, line=False)
    c.add("arm_l", "imp", 2.5, [seg(cx - 28, 220, cx - 46, 250, 12), E(cx - 48, 256, 14, 14)], tags=("arms",))
    c.add("fork", "bronze", 2.4, [seg(cx + 50, 300, cx + 56, 150, 5), seg(cx + 44, 156, cx + 68, 156, 5), seg(cx + 44, 156, cx + 44, 136, 4),
                                  seg(cx + 56, 156, cx + 56, 132, 4), seg(cx + 68, 156, cx + 68, 136, 4)], tags=("weapon",))
    c.add("arm_r", "imp", 2.5, [seg(cx + 28, 220, cx + 48, 226, 12), E(cx + 52, 226, 14, 14)], tags=("arms",))
    c.add("ears", "imp", 2.9, [P("triangle", cx - 42, 170, 22, 44, rot=-66), P("triangle", cx + 42, 170, 22, 44, rot=66)], tags=("head",))
    c.add("head", "imp", 3, [E(cx, 176, 70, 62)], tags=("head",))
    c.add("horns", "horn", 3.1, [P("triangle", cx - 16, 144, 10, 18, rot=-14), P("triangle", cx + 16, 144, 10, 18, rot=14)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 13, 172, 13, 9, rot=16), E(cx + 13, 172, 13, 9, rot=-16)], tags=("head",), color="glow_yellow_c",
           strength=0.8, opacity=0.45)
    c.flat("pupils", "eye", 3.25, [E(cx - 13, 172, 3, 7), E(cx + 13, 172, 3, 7)], tags=("head",))
    c.flat("mouth", "mouth", 3.3, smile(cx, 194, 36, 12), tags=("head",))
    c.flat("teeth", "tooth", 3.35, [P("triangle", cx - 8, 193, 4, 6, flip="y"), P("triangle", cx + 8, 193, 4, 6, flip="y")], tags=("head",),
           line={"width": 0.4, "heavy": 0.3})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="임프", size="작음")
    return c


@creature("mimic_door", "B")
def mimic_door():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("mimic_door", (W, H), (cx, gy), seed=627,
                 note="Door mimic, front view. Arched iron-banded wooden door in a stone frame whose middle splits into a "
                      "fanged mouth with a long tongue lolling out; two yellow eyes glare through the barred window above.")
    c.shadow(cx, gy - 2, 210, 22)
    c.add("frame", "stone_dark", 1, [P("doorway", cx, 214, 220, 310)], tags=("frame",))
    c.add("door", "wood_door", 2, [P("door", cx, 222, 170, 280)], tags=("door",))
    c.add("bands", "iron", 2.2, [P("square", cx, 180, 172, 12), P("square", cx, 300, 172, 12)], tags=("door",), clip_to="door")
    c.add("hinges", "iron", 2.3, [P("square", cx - 70, 180, 30, 16), P("square", cx - 70, 300, 30, 16)], tags=("door",))
    c.flat("window", "void", 2.4, [P("square", cx, 132, 70, 44)], tags=("door",))
    c.glow("eyes", "glow_yellow", 2.5, [E(cx - 16, 132, 16, 11, rot=12), E(cx + 16, 132, 16, 11, rot=-12)], tags=("door",), color="glow_yellow_c",
           strength=0.9, opacity=0.5)
    c.flat("pupils", "eye", 2.55, [E(cx - 16, 132, 4, 9), E(cx + 16, 132, 4, 9)], tags=("door",))
    c.add("bars", "iron", 2.6, [P("square", cx + d * 18, 132, 5, 46) for d in (-1, 0, 1)], tags=("door",))
    c.flat("mouth", "mouth", 2.7, [E(cx, 250, 140, 70)], tags=("door",))
    c.add("teeth", "tooth", 2.8, fangs(cx - 64, cx + 64, 222, 8, 18, jitter=0.3) + fangs(cx - 56, cx + 56, 280, 7, 16, down=False, jitter=0.3),
          tags=("door",), line={"width": 0.6, "heavy": 0.5})
    c.add("tongue", "tongue", 2.9, tube([(cx - 6, 262), (cx - 30, 300), (cx - 20, 344)], 30, 16, n=8, cap=True), tags=("door",))
    c.add("ring", "iron", 3, [P("ring", cx + 56, 250, 22, 22)], tags=("door",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="미믹(문)", size="사람")
    return c


# ================================================================ C (idle only)
@creature("hungry_ghost", "C")
def hungry_ghost():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("hungry_ghost", (W, H), (cx, gy), seed=631,
                 note="Hungry ghost, front view, floating. Emaciated grey spirit with a hugely swollen belly, a needle-thin "
                      "neck, huge sunken glowing eyes in a gaunt face, a tiny pursed mouth, stick-thin arms clutching at "
                      "nothing, lower body fading into tattered wisps.")
    c.shadow(cx, gy - 2, 100, 14, opacity=0.25, blur=7)
    c.add("wisps", "ghost", 1, [P("droplet", cx - 26, 320, 30, 70, flip="y", rot=12), P("droplet", cx + 22, 326, 26, 60, flip="y", rot=-10)],
          tags=("body",), opacity=0.6, line=False)
    c.add("belly", "corpse_grey", 2, [E(cx, 262, 120, 110)], tags=("body",))
    c.add("chest", "corpse_grey", 2.1, [E(cx, 196, 60, 50)], tags=("body",))
    c.flat("ribs", "corpse_grey", 2.2, [p for i in range(3) for p in smile(cx, 190 + i * 10, 44 - i * 6, 5, depth=0.6)], tags=("body",), color="coat_seam", opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        bones_limb(c, f"arm_{s}", [(cx + k * 24, 180), (cx + k * 64, 220), (cx + k * 56, 262)], 8, "corpse_grey", 2.5, ("arms",), (cx + k * 24, 180))
        c.add(f"hand_{s}", "corpse_grey", 2.6, claw_hand(cx + k * 56, 266, 90, 16, n=4, spread=16), tags=("arms",))
    c.add("neck", "corpse_grey", 2.3, [seg(cx, 176, cx, 146, 8)], tags=("head",))
    c.add("head", "corpse_grey", 3, [E(cx, 118, 64, 72)], tags=("head",))
    c.flat("sockets", "void", 3.1, [E(cx - 13, 112, 20, 24), E(cx + 13, 112, 20, 24)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 13, 114, 7, 8), E(cx + 13, 114, 7, 8)], tags=("head",), color="glow_yellow_c", strength=0.9, opacity=0.5)
    c.flat("mouth", "mouth", 3.2, [E(cx, 142, 6, 6)], tags=("head",))
    c.add("hair", "hair", 3.3, [P("droplet", cx - 20, 90, 10, 26, flip="y", rot=30), P("droplet", cx + 16, 86, 10, 22, flip="y", rot=-20)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="아귀", size="사람")
    return c


@creature("soul_wall", "C")
def soul_wall():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("soul_wall", (W, H), (cx, gy), seed=632,
                 note="Wall of souls, front view. A heaving slab of translucent pale-blue spirit stuff packed with moaning "
                      "ghostly faces (dark hollow eyes and mouths, a few with cold glowing pupils) and ghostly hands "
                      "pushing out of it; no bodies or gore, only spirit shapes.")
    c.shadow(cx, gy - 2, 400, 40, opacity=0.3)
    c.add("slab", "ghost", 1, [P("square", cx, 290, 400, 380), P("cloud", cx, 110, 400, 80)], tags=("body",), opacity=0.88)
    faces = [(cx - 120, 170, 1.0), (cx, 150, 1.1), (cx + 120, 170, 1.0), (cx - 160, 290, 0.9), (cx - 50, 270, 1.2), (cx + 70, 280, 1.0),
             (cx + 160, 300, 0.9), (cx - 100, 400, 1.0), (cx + 20, 390, 1.1), (cx + 130, 410, 0.9)]
    for i, (x, y, s) in enumerate(faces):
        c.add(f"face_{i}", "ghost", 2 + i * 0.01, [E(x, y, 70 * s, 84 * s)], tags=("body",), opacity=0.95)
        c.flat(f"face_{i}_holes", "void", 2.005 + i * 0.01, [E(x - 13 * s, y - 8 * s, 14 * s, 18 * s), E(x + 13 * s, y - 8 * s, 14 * s, 18 * s),
                                                            E(x, y + 20 * s, 14 * s, 22 * s)], tags=("body",))
        if i % 3 == 0:
            c.glow(f"face_{i}_eyes", "glow_cyan", 2.008 + i * 0.01, [E(x - 13 * s, y - 6 * s, 5 * s, 5 * s), E(x + 13 * s, y - 6 * s, 5 * s, 5 * s)],
                   tags=("body",), color="ghost_glow_c", strength=1.0, opacity=0.6)
    for i, (x, y, ang) in enumerate(((cx - 200, 220, -150), (cx + 200, 240, -30), (cx - 190, 380, 160), (cx + 196, 370, 20), (cx - 20, 90, -100))):
        c.add(f"hand_{i}", "ghost", 3, claw_hand(x, y, ang, 30, n=4, spread=18) + [seg(x - 30 * math.cos(math.radians(ang)), y - 30 * math.sin(math.radians(ang)), x, y, 18)],
              tags=("hands",), opacity=0.9)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="망자가 뭉친 벽", size="큼")
    return c


@creature("bone_beast", "C")
def bone_beast():
    W, H = 512, 512
    gy = 494
    c = Creature("bone_beast", (W, H), (262, gy), seed=633,
                 note="Bone beast, 3/4 front view facing the lower left. A hulking skeletal ox-like beast: horned skull "
                      "with red eye lights, thick spine with jutting spikes, heavy rib cage, massive bone legs, tattered "
                      "hide scraps and rusty chains hanging.")
    c.shadow(270, gy - 4, 380, 40)
    bones_limb(c, "leg_hind_far", [(380, 320), (400, 400), (392, 470)], 18, "bone_old", 1, ("legs",), (380, 320))
    bones_limb(c, "leg_front_far", [(210, 330), (220, 400), (214, 470)], 18, "bone_old", 1, ("legs",), (210, 330))
    c.add("spine", "bone", 2, [E(200 + i * 22, 250 - 10 * math.sin(i / 2.4), 22, 18) for i in range(10)], tags=("body",))
    c.add("spikes", "bone", 1.9, [P("triangle", 200 + i * 22, 226 - 10 * math.sin(i / 2.4), 12, 30, rot=-10) for i in range(1, 10, 2)], tags=("body",))
    c.add("ribs", "bone", 2.2, [P("moon", 230 + i * 26, 290, 46, 70 - i * 5, rot=-45) for i in range(5)], tags=("body",))
    c.add("pelvis", "bone", 2.3, [E(392, 280, 70, 50)], tags=("body",))
    c.add("hide", "fur_brown", 2.4, [P("bookmark", 300, 330, 40, 50), P("bookmark", 350, 320, 30, 40)], tags=("body",), opacity=0.9)
    c.add("chains", "iron", 2.5, [P("ring", 250 + i * 14, 330 + i * 10, 14, 12, rot=i * 40) for i in range(5)], tags=("body",))
    bones_limb(c, "leg_hind", [(394, 320), (420, 404), (410, 476)], 24, "bone", 3, ("legs",), (394, 320))
    bones_limb(c, "leg_front", [(190, 330), (176, 404), (172, 476)], 24, "bone", 3.1, ("legs",), (190, 330))
    for x in (410, 172):
        c.add(f"hoof_{x}", "horn", 3.2, [P("cylinder", x - 4, 480, 40, 20)], tags=("legs",))
    c.flat("skull_void", "void", 3.9, [E(140, 240, 70, 40)], tags=("head",))
    c.add("skull", "bone", 4, [E(160, 226, 110, 90), P("droplet", 110, 266, 60, 100, rot=-130)], tags=("head",))
    c.add("horns", "bone_old", 4.1, tube([(180, 190), (230, 160), (250, 110)], 26, 8, n=8, cap=True) + tube([(140, 192), (100, 150), (110, 100)], 22, 7, n=8, cap=True),
          tags=("head",))
    c.flat("sockets", "void", 4.2, [E(140, 222, 24, 20), E(180, 214, 20, 18)], tags=("head",))
    c.glow("eyes", "glow_red", 4.3, [E(140, 222, 9, 8), E(180, 214, 8, 7)], tags=("head",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.flat("teeth", "void", 4.25, [seg(84, 296, 130, 280, 5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="뼈 짐승", size="큼")
    return c


@creature("skull_mimic", "C")
def skull_mimic():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("skull_mimic", (W, H), (cx, gy), seed=634,
                 note="Skull mimic, front view. What looks like a heap of old skulls is one creature: the crowning skull "
                      "has glowing red eyes and a long tongue, bony claws creep out of the pile, the other skulls grin "
                      "with hollow sockets.")
    c.shadow(cx, gy - 2, 230, 26)
    pile = [(cx - 70, 330, 64), (cx, 336, 70), (cx + 72, 330, 62), (cx - 40, 286, 64), (cx + 40, 286, 64), (cx - 90, 290, 50), (cx + 92, 292, 48)]
    for i, (x, y, s) in enumerate(pile):
        c.flat(f"back_{i}", "void", 1 + i * 0.01, [E(x, y - s * 0.06, s * 0.66, s * 0.44)], tags=("pile",))
        c.add(f"skull_{i}", "bone_old", 1.005 + i * 0.01, [P("skull", x, y, s, s * 1.02)], tags=("pile",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"claw_{s}", "bone", 2, claw_hand(cx + k * 126, 346, 90 - k * 50, 26, n=4, spread=20) + [seg(cx + k * 100, 330, cx + k * 126, 346, 12)],
              tags=("claws",))
    c.flat("top_back", "void", 2.9, [E(cx, 226, 56, 38)], tags=("head",))
    c.add("top", "bone", 3, [P("skull", cx, 230, 84, 86)], tags=("head",))
    c.glow("eyes", "glow_red", 3.1, [E(cx - 13, 226, 10, 10), E(cx + 13, 226, 10, 10)], tags=("head",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.add("tongue", "tongue", 3.2, tube([(cx, 262), (cx + 16, 290), (cx - 6, 314)], 16, 8, n=8, cap=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="해골 흉내 괴물", size="작음")
    return c


@creature("pumpkin_bat", "C")
def pumpkin_bat():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("pumpkin_bat", (W, H), (cx, gy), seed=635,
                 note="Pumpkin bat, front view, flying. A carved dull-orange pumpkin body with ember-lit eyes and a fanged "
                      "grin, stubby bat ears, a curly stem, and dark leathery bat wings spread wide.")
    c.shadow(cx, gy - 2, 90, 14, opacity=0.25, blur=7)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 40, 190), 94, 56, "membrane", "hide_bat", 1, ("wings",))
    c.add("ears", "hide_bat", 1.5, [P("triangle", cx - 36, 144, 26, 40, rot=-20), P("triangle", cx + 36, 144, 26, 40, rot=20)], tags=("body",))
    c.add("pumpkin", "pumpkin", 2, [E(cx, 196, 120, 100), E(cx - 36, 198, 60, 94), E(cx + 36, 198, 60, 94)], tags=("body",))
    c.flat("ribs", "pumpkin", 2.1, [seg(cx - 20, 154, cx - 22, 240, 3), seg(cx + 20, 154, cx + 22, 240, 3)], tags=("body",), color="coat_seam", opacity=0.4)
    c.add("stem", "bark", 1.9, [seg(cx + 2, 150, cx + 6, 128, 12), P("spiral", cx + 24, 130, 22, 20)], tags=("body",))
    c.glow("face", "fire_mid", 2.2, [P("triangle", cx - 24, 184, 24, 22), P("triangle", cx + 24, 184, 24, 22), E(cx, 216, 70, 22),
                                     P("mountains", cx, 208, 64, 12, op="sub")], tags=("body",), color="ember_glow", strength=1.0, opacity=0.6)
    c.flat("fangs", "tooth", 2.3, [P("triangle", cx - 10, 214, 6, 12, flip="y"), P("triangle", cx + 10, 214, 6, 12, flip="y")], tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="호박 박쥐", size="작음")
    return c


@creature("snake_ghost", "C")
def snake_ghost():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("snake_ghost", (W, H), (cx, gy), seed=636,
                 note="Snake ghost, front view. A translucent pale-blue spectral serpent coiling in the air, cold glowing "
                      "eyes and a gaping jaw, its body fraying into wisps toward the tail.")
    c.shadow(cx, gy - 2, 150, 20, opacity=0.25, blur=7)
    body = [(cx + 110, 330), (cx - 120, 300), (cx + 90, 230), (cx - 30, 170), (cx, 120)]
    c.add("wisp", "ghost", 0.8, [P("wind", cx + 130, 330, 70, 40), P("wind", cx - 140, 290, 60, 36, flip="x")], tags=("body",), opacity=0.5, line=False)
    c.add("body", "ghost", 1, tube(body, 26, 62, n=40, cap=True, stretch=2.4), tags=("body",), opacity=0.82)
    c.add("belly", "ghost_glow", 1.1, tube(body, 10, 26, n=40, cap=True, stretch=2.4), tags=("body",), clip_to="body", opacity=0.5, line=False)
    c.add("head", "ghost", 2, [E(cx, 104, 80, 60), E(cx, 126, 56, 40)], tags=("head",), opacity=0.88)
    c.flat("mouth", "void", 2.1, [E(cx, 136, 44, 30)], tags=("head",))
    c.flat("fangs", "ghost_glow", 2.2, [P("triangle", cx - 12, 126, 6, 14, flip="y"), P("triangle", cx + 12, 126, 6, 14, flip="y")], tags=("head",))
    c.glow("eyes", "glow_cyan", 2.3, [E(cx - 20, 96, 14, 9, rot=16), E(cx + 20, 96, 14, 9, rot=-16)], tags=("head",), color="ghost_glow_c",
           strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="뱀 유령", size="사람")
    return c


@creature("owl", "C")
def owl():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("owl", (W, H), (cx, gy), seed=637,
                 note="Owl, front view, perched. Dusky brown owl with tall ear tufts, a pale facial disc, huge glowing amber "
                      "eyes, small hooked beak, speckled chest, folded wings and grey talons.")
    c.shadow(cx, gy - 2, 140, 18)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"talons_{s}", "horn", 1, [seg(cx + k * 20, 330, cx + k * 20 + d * 10, 352, 6, ext=0.1) for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "feather_brown", 2, [E(cx, 262, 150, 170)], tags=("body",))
    c.add("chest", "feather_pale", 2.1, [P("droplet", cx, 280, 90, 130, flip="y")], tags=("body",), clip_to="body", opacity=0.8)
    c.flat("speckles", "feather_brown", 2.2, [P("moon", cx + dx, 260 + dy, 12, 12, rot=-45) for dx, dy in ((-20, 0), (20, 0), (0, 24), (-24, 44), (24, 44), (0, 66))],
           tags=("body",), clip_to="chest", opacity=0.8)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_{s}", "feather_brown", 2.5, [P("droplet", cx + k * 64, 272, 56, 150, flip="y", rot=k * -8)], tags=("body",))
    c.add("tufts", "feather_brown", 2.9, [P("triangle", cx - 44, 126, 26, 50, rot=-24), P("triangle", cx + 44, 126, 26, 50, rot=24)], tags=("head",))
    c.add("head", "feather_brown", 3, [E(cx, 170, 130, 110)], tags=("head",))
    c.add("disc", "feather_pale", 3.1, [E(cx - 28, 172, 62, 66), E(cx + 28, 172, 62, 66)], tags=("head",), opacity=0.9)
    c.glow("eyes", "glow_yellow", 3.2, [E(cx - 28, 170, 36, 36), E(cx + 28, 170, 36, 36)], tags=("head",), color="glow_yellow_c", strength=0.6, opacity=0.35)
    c.flat("pupils", "eye", 3.25, [E(cx - 28, 170, 16, 16), E(cx + 28, 170, 16, 16)], tags=("head",))
    c.add("beak", "horn", 3.3, [P("droplet", cx, 196, 16, 24, flip="y")], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="부엉이", size="작음")
    return c


@creature("hellhound", "C")
def hellhound():
    W, H = 384, 384
    gy = 366
    c = Creature("hellhound", (W, H), (200, gy), seed=638,
                 note="Hellhound, 3/4 front view facing the lower left. Lean black demonic hound with glowing ember cracks "
                      "along its body, a mane and tail of flame, short curved horns, burning eyes and a snarling fanged maw.")
    c.shadow(206, gy - 4, 270, 30)
    leg3(c, "leg_hind_far", [(292, 238), (306, 300), (300, 346)], 24, 16, "soot", 1, ("legs",), paw=(28, 12))
    leg3(c, "leg_front_far", [(170, 246), (176, 304), (172, 346)], 22, 16, "soot", 1, ("legs",), paw=(28, 12))
    c.add("tail", "fire_outer", 1.5, [P("fire", 340, 190, 50, 70, rot=30), P("fire", 330, 210, 30, 44, rot=10)], tags=("tail",), emit=0.9,
          line={"width": 0.7, "heavy": 0.5})
    c.add("body", "ash", 2, [E(234, 222, 186, 100, rot=-6), E(160, 232, 96, 104)], tags=("body",))
    c.glow("cracks", "ember", 2.1, [P("lightning_bolt", 230, 216, 12, 40, rot=30), P("lightning_bolt", 280, 226, 10, 34, rot=-20),
                                    P("lightning_bolt", 170, 240, 10, 30, rot=10)], tags=("body",), color="ember_glow", strength=0.9, opacity=0.5, clip_to="body")
    leg3(c, "leg_hind", [(290, 244), (310, 300), (300, 352)], 34, 22, "ash", 3, ("legs",), paw=(36, 14), claws=3)
    c.add("thigh", "ash", 3.05, [E(288, 248, 70, 92, rot=-10)], tags=("legs",))
    leg3(c, "leg_front", [(132, 246), (126, 304), (124, 350)], 32, 22, "ash", 3.1, ("legs",), paw=(38, 15), claws=3)
    c.add("mane", "fire_outer", 3.3, [P("fire", 150 + d * 24, 170 - abs(d) * 6, 36, 60, rot=d * 20) for d in (-1, 0, 1, 2)], tags=("head",), emit=0.9,
          line={"width": 0.7, "heavy": 0.5})
    c.add("mane_core", "fire_mid", 3.35, [P("fire", 160 + d * 24, 180 - abs(d) * 6, 20, 34, rot=d * 20) for d in (-1, 0, 1)], tags=("head",), emit=1.0, line=False)
    c.add("head", "ash", 4, [E(116, 174, 84, 72)], tags=("head",))
    c.add("horns", "horn", 4.1, [P("moon", 110, 130, 30, 30, rot=-100), P("moon", 140, 128, 26, 26, rot=-80)], tags=("head",))
    c.add("snout", "ash", 4.3, [P("droplet", 86, 200, 40, 70, rot=-128)], tags=("head",))
    c.add("nose", "eye", 4.5, [E(64, 222, 16, 12, rot=-30)], tags=("head",))
    c.glow("eyes", "ember", 4.4, [E(98, 170, 14, 8, rot=20), E(130, 166, 11, 7, rot=10)], tags=("head",), color="ember_glow", strength=1.0, opacity=0.6)
    c.flat("maw", "mouth", 4.25, [P("droplet", 90, 232, 34, 58, rot=-112)], tags=("head",))
    c.flat("fangs", "tooth", 4.28, [P("triangle", 80, 222, 6, 12, flip="y"), P("triangle", 96, 218, 6, 11, flip="y"), P("triangle", 86, 244, 5, 10)],
           tags=("head",), line={"width": 0.4, "heavy": 0.3})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="지옥개", size="사람")
    return c
