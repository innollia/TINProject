"""g05-dark-v01: dark-fantasy / gothic creatures (front-view battlers).

Each function returns a kit.Creature.  Coordinates are final px.  A items get
idle / attack / hit, B and C items idle only.
"""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile, std_frames,
                  sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, heater_shield, spikes_on, wing_at


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
