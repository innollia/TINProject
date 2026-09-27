"""g05-fantasy-v01: medieval-fantasy creatures (front-view battlers).

Each function returns a kit.Creature.  Coordinates are final px.  A items get
idle / attack / hit, B and C items idle only.
"""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .parts import bat_wing, spikes_on, wing_at
from .kit import (E, P, Creature, brows, creature, dot_eyes, fangs, membrane, mirror, poly, row, seg, smile, std_frames,
                  sym, tube, x_eyes)


# ---------------------------------------------------------------- A: slime
@creature("slime", "A")
def slime():
    W, H = 320, 384
    g = (160, 366)
    c = Creature("slime", (W, H), g, seed=501,
                 note="Slime, front view. Wet green teardrop blob with a darker core, puddle foot and two dark eyes. "
                      "attack = leaps up stretched with a fanged mouth, hit = squashed flat and tilted with squeezed eyes.")
    c.shadow(160, 364, 206, 26)
    c.add("body", "slime", 2, [
        P("droplet", 160, 258, 196, 206),
        E(160, 336, 240, 62),
        E(62, 354, 40, 18), E(262, 356, 44, 16),
    ], tags=("body",))
    c.add("core", "slime_dark", 2.5, [E(172, 304, 86, 66), E(142, 286, 40, 32)], tags=("body",),
          clip_to="body", opacity=0.55, line=False)
    c.add("bubbles", "slime", 2.7, [E(214, 246, 16, 16), E(118, 320, 11, 11), E(206, 330, 8, 8)], tags=("body",),
          clip_to="body", line={"width": 0.6, "heavy": 0.5})
    dot_eyes(c, 160, 262, 34, 24, 34)
    c.flat("brows", "eye", 6.3, brows(160, 238, 34, 30, 7, tilt=20), tags=("brows",), hidden=True)
    x_eyes(c, 160, 262, 34, 13)
    c.flat("mouth", "mouth", 6, smile(160, 296, 34, 20), tags=("mouth",))
    c.flat("mouth_open", "mouth", 6, [E(160, 304, 64, 46)], tags=("mouth_open",), hidden=True)
    c.flat("fangs", "tooth", 6.2, fangs(136, 184, 283, 4, 13) + fangs(144, 176, 326, 2, 9, down=False),
           tags=("mouth_open",), hidden=True, line={"width": 0.6, "heavy": 0.5})
    c.flat("mouth_hurt", "mouth", 6, [E(160, 304, 26, 20)], tags=("mouth_hurt",), hidden=True)
    std_frames(
        c,
        attack_move={"all": c.whole(sx=0.88, sy=1.14, dy=-20)},
        shadow_attack={"sx": 0.78, "sy": 0.78, "pivot": [160, 364]},
        attack_show=("mouth_open", "brows"),
        hit_move={"all": c.whole(sx=1.12, sy=0.84, rot=7, dx=8)},
        hit_show=("eyes_hit", "mouth_hurt"),
    )
    c.meta.update(name_ko="슬라임", size="작음")
    return c


# ---------------------------------------------------------------- A: goblin
@creature("goblin", "A")
def goblin():
    W, H = 320, 384
    cx = 160
    c = Creature("goblin", (W, H), (cx, 366), seed=502,
                 note="Goblin, front view. Small hunched green humanoid: big head, long pointed ears, hooked nose, "
                      "yellow eyes, toothy grin, pot belly, rag loincloth, rusty dagger. attack = dagger raised overhead "
                      "with claws out; hit = knocked back, squeezed eyes, arms flung.")
    b = Biped(c, cx, 366, 262, build=0.92, leg=0.33, torso=0.29, head=0.31, hunch=0.035, arm_len=0.37, stance=1.3)
    c.shadow(cx, 364, 156, 22)
    b.arm_to("l", (b.sh["l"][0] - 18, b.sh["l"][1] + 84), bend=0.14)
    b.arm_to("r", (b.sh["r"][0] + 20, b.sh["r"][1] + 66), bend=0.18)
    b.legs("goblin", foot="claw", z=1, thigh=1.0, shin=0.85)
    ys, yh = b.y_sh, b.y_hip
    c.add("torso", "goblin", 3, [E(cx, ys + 24, 78, 50), E(cx, yh - 22, 74, 64), E(cx, yh - 2, 58, 30)], tags=("torso",))
    c.add("loincloth", "cloth_rag", 3.3, [P("bookmark", cx + 2, yh + 18, 46, 44), E(cx, yh + 2, 70, 18)], tags=("torso",))
    c.add("belt", "leather", 3.5, [E(cx, yh - 2, 80, 11)], tags=("torso",))
    c.add("buckle", "bronze", 3.55, [P("square", cx - 10, yh - 2, 11, 10)], tags=("torso",), kind="flat",
          line={"width": 0.5, "heavy": 0.4})
    c.add("strap", "leather", 3.6, [seg(cx - 30, ys + 4, cx + 26, yh - 10, 8)], tags=("torso",), cast=False)
    # idle arms
    b.arm("l", "goblin", z=4, upper=0.95, fore=0.85, hand=1.2, claws=0.9)
    b.arm("r", "goblin", z=4, upper=0.95, fore=0.85, hand=1.2)
    hx, hy = b.hand["r"]
    c.add("dagger", "iron", 3.9, [P("dagger", hx + 3, hy - 20, 50, 50, rot=-45)], tags=("arm_r",), pivot=list(b.sh["r"]))
    # attack arms (hidden): dagger raised overhead, left claws reaching out
    b.arm_to("r", (b.sh["r"][0] + 4, ys - 92), elbow=(b.sh["r"][0] + 34, ys - 40))
    b.arm("r", "goblin", z=8.5, upper=0.95, fore=0.85, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    hx, hy = b.hand["r"]
    c.add("dagger_atk", "iron", 8.4, [P("dagger", hx - 14, hy - 16, 50, 50, rot=-90)], tags=("atk",), hidden=True)
    b.arm_to("l", (b.sh["l"][0] - 58, ys + 34), elbow=(b.sh["l"][0] - 34, ys + 30))
    b.arm("l", "goblin", z=4, upper=0.95, fore=0.85, hand=1.25, fist=False, suffix="_atk", hidden=True, tags=("atk",), claws=1.0)
    # neck + head
    hy0 = b.head_y
    c.add("neck", "goblin", 5, [E(cx, ys - 4, 34, 30)], tags=("head",))
    c.add("ears", "goblin", 6.5, sym([P("droplet", cx - 56, hy0 - 6, 24, 66, rot=-68)], cx), tags=("head",))
    c.add("ear_in", "hide_pink", 6.55, sym([P("droplet", cx - 52, hy0 - 5, 11, 40, rot=-68)], cx), tags=("head",),
          line=False, opacity=0.7)
    c.add("head", "goblin", 7, [E(cx, hy0, 86, 78), E(cx, hy0 + 22, 70, 40)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.5, [E(cx - 20, hy0 - 4, 18, 14, rot=12), E(cx + 20, hy0 - 4, 18, 14, rot=-12)],
           tags=("head", "eyes"), color="glow_yellow_c", strength=0.55, opacity=0.35)
    c.flat("pupils", "eye", 7.6, [E(cx - 19, hy0 - 4, 5, 10), E(cx + 19, hy0 - 4, 5, 10)], tags=("head", "eyes"))
    c.flat("brows", "eye", 7.7, brows(cx, hy0 - 15, 20, 26, 6, tilt=18), tags=("head",))
    x_eyes(c, cx, hy0 - 4, 20, 8, z=7.6, width=5, tags=("head",))
    c.add("nose", "goblin", 7.8, [P("droplet", cx, hy0 + 10, 20, 30)], tags=("head",))
    c.flat("mouth", "mouth", 7.9, smile(cx, hy0 + 26, 40, 20), tags=("head", "mouth"))
    c.flat("teeth", "tooth", 8.0, fangs(cx - 14, cx + 14, hy0 + 24, 3, 7), tags=("head", "mouth"),
           line={"width": 0.5, "heavy": 0.4})
    c.flat("mouth_open", "mouth", 7.9, [E(cx, hy0 + 30, 40, 28)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 8.0, fangs(cx - 16, cx + 16, hy0 + 18, 4, 9) + fangs(cx - 10, cx + 10, hy0 + 43, 2, 7, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    sr, sl = list(b.sh["r"]), list(b.sh["l"])
    std_frames(
        c,
        attack_move={"head": {"rot": -5, "pivot": [cx, ys]}, "all": c.whole(s=1.05, dy=4, rot=-3)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 55, "pivot": sl}, "arm_r": {"rot": -48, "pivot": sr},
                  "head": {"rot": 10, "pivot": [cx, ys]}, "all": c.whole(rot=8, dx=10, dy=-6, s=0.97)},
        shadow_hit_dx=6,
    )
    c.meta.update(name_ko="고블린", size="사람")
    return c



# ---------------------------------------------------------------- A: orc
@creature("orc", "A")
def orc():
    from .kit import held
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("orc", (W, H), (cx, gy), seed=503,
                 note="Orc, front view. Broad grey-green brute: heavy brow, small red eyes, underbite with two tusks, "
                      "topknot, spiked iron pauldron, crossed leather straps, rag loincloth, big axe. attack = axe wound up "
                      "over the shoulder, roaring, fist forward; hit = rocked back, eyes shut, arms flung.")
    b = Biped(c, cx, gy, 318, build=1.28, leg=0.37, torso=0.34, head=0.2, shoulder=0.185, hip=0.11, arm_w=0.085,
              leg_w=0.1, arm_len=0.38, stance=1.2, hunch=0.04)
    c.shadow(cx, gy - 2, 214, 28)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.arm_to("l", (b.sh["l"][0] - 20, ys + 116), bend=0.1)
    b.arm_to("r", (b.sh["r"][0] + 18, ys + 108), bend=0.14)
    b.legs("trouser", foot_mat="leather", foot="boot", z=1, thigh=1.05, shin=0.95)
    c.add("torso", "orc", 3, [E(cx, ys + 36, 178, 92), E(cx, yh - 34, 128, 92), E(cx, yh - 4, 110, 40)], tags=("torso",))
    c.flat("pecs", "orc", 3.1, [seg(cx - 44, ys + 58, cx - 6, ys + 62, 5), seg(cx + 6, ys + 62, cx + 44, ys + 58, 5)],
           tags=("torso",), color="coat_seam", opacity=0.35)
    c.add("straps", "leather", 3.4, [seg(cx - 70, ys + 8, cx + 40, yh - 12, 12), seg(cx + 70, ys + 8, cx - 40, yh - 12, 12)],
          tags=("torso",), cast=False)
    c.add("belt", "leather", 3.5, [E(cx, yh - 2, 132, 20)], tags=("torso",))
    c.add("buckle", "bronze", 3.55, [P("octagon", cx, yh - 2, 22, 20)], tags=("torso",))
    c.add("loincloth", "cloth_rag", 3.3, [P("bookmark", cx, yh + 34, 66, 64), E(cx, yh + 6, 108, 22)], tags=("torso",))
    # idle arms + axe
    b.arm("l", "orc", z=4, upper=1.0, fore=0.95, hand=1.2)
    b.arm("r", "orc", z=4, upper=1.0, fore=0.95, hand=1.2)
    for s in "lr":
        ex, ey = b.elbow[s]
        hx, hy = b.hand[s]
        c.add(f"bracer_{s}", "leather", 4.15, [seg(ex + (hx - ex) * 0.35, ey + (hy - ey) * 0.35, ex + (hx - ex) * 0.85,
                                                  ey + (hy - ey) * 0.85, b.arm_w * 1.02)], tags=(f"arm_{s}",), pivot=list(b.sh[s]))
    c.add("axe", "iron", 3.9, [held("axe", b.hand["r"], 150, -88)], tags=("arm_r",), pivot=list(b.sh["r"]))
    # attack arms (hidden)
    b.arm_to("r", (b.sh["r"][0] + 30, ys - 22), elbow=(b.sh["r"][0] + 50, ys + 24))
    b.arm("r", "orc", z=4, upper=1.0, fore=0.95, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    c.add("axe_atk", "iron", 3.8, [held("axe", b.hand["r"], 136, -158)], tags=("atk",), hidden=True)
    b.arm_to("l", (b.sh["l"][0] - 22, ys + 40), elbow=(b.sh["l"][0] - 40, ys + 64))
    b.arm("l", "orc", z=8.5, upper=1.0, fore=0.95, hand=1.35, suffix="_atk", hidden=True, tags=("atk",))
    # pauldron on the left shoulder
    sx, sy = b.sh["l"]
    c.add("pauldron", "iron", 5.5, [E(sx + 4, sy + 2, 74, 56, rot=-12)], tags=("pauldron",), pivot=[sx, sy])
    c.add("spikes", "iron", 5.4, [P("triangle", sx - 20, sy - 30, 16, 26, rot=-30), P("triangle", sx + 6, sy - 34, 16, 28, rot=-6)],
          tags=("pauldron",), pivot=[sx, sy])
    # head
    c.add("neck", "orc", 5, [E(cx, ys - 6, 76, 40)], tags=("head",))
    c.add("ears", "orc", 6.5, sym([P("droplet", cx - 38, hy0 - 2, 16, 34, rot=-80)], cx), tags=("head",))
    c.add("head", "orc", 7, [E(cx, hy0 - 4, 70, 60), E(cx, hy0 + 16, 80, 44)], tags=("head",))
    c.add("hair", "hair", 7.2, [E(cx, hy0 - 32, 30, 18), P("droplet", cx + 4, hy0 - 48, 20, 30, rot=14)], tags=("head",))
    c.add("brow", "orc", 7.6, [E(cx, hy0 - 12, 70, 16)], tags=("head",))
    c.glow("eyes", "glow_red", 7.5, [E(cx - 15, hy0 - 3, 12, 8, rot=10), E(cx + 15, hy0 - 3, 12, 8, rot=-10)],
           tags=("head", "eyes"), color="glow_red_c", strength=0.7, opacity=0.4)
    x_eyes(c, cx, hy0 - 3, 15, 6, z=7.65, width=4.5, tags=("head",))
    c.add("nose", "orc", 7.7, [E(cx, hy0 + 8, 22, 16)], tags=("head",))
    c.flat("nostrils", "eye", 7.75, [E(cx - 5, hy0 + 11, 4, 3), E(cx + 5, hy0 + 11, 4, 3)], tags=("head",))
    c.flat("mouth", "mouth", 7.8, smile(cx, hy0 + 26, 40, 10, frown=True), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.8, [E(cx, hy0 + 28, 42, 24)], tags=("head", "mouth_open"), hidden=True)
    c.add("tusks", "tooth", 7.9, [P("triangle", cx - 16, hy0 + 20, 9, 17, rot=-8), P("triangle", cx + 16, hy0 + 20, 9, 17, rot=8)],
          tags=("head",), line={"width": 0.6, "heavy": 0.5})
    sr, sl = list(b.sh["r"]), list(b.sh["l"])
    std_frames(
        c,
        attack_move={"head": {"rot": -4, "pivot": [cx, ys]}, "pauldron": {"rot": 14, "pivot": sl}, "all": c.whole(s=1.04, dy=4, rot=-2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 40, "pivot": sl}, "arm_r": {"rot": -18, "pivot": sr},
                  "head": {"rot": 9, "pivot": [cx, ys]}, "all": c.whole(rot=7, dx=4, dy=-4, s=0.96)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="오크", size="사람")
    return c


# ---------------------------------------------------------------- A: troll
@creature("troll", "A")
def troll():
    from .kit import held
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("troll", (W, H), (cx, gy), seed=504,
                 note="Troll, front view. Tall lanky mossy-grey brute, hunched, arms hanging to the knees, long drooping "
                      "nose, tiny eyes, lower tusks, stringy hair, moss patches, wooden club. attack = club raised overhead "
                      "with both arms up; hit = staggers back with eyes shut.")
    b = Biped(c, cx, gy, 452, build=1.0, leg=0.4, torso=0.3, head=0.17, shoulder=0.16, hip=0.085, arm_w=0.07,
              leg_w=0.075, arm_len=0.52, stance=1.35, hunch=0.07)
    c.shadow(cx, gy - 2, 260, 32)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.arm_to("l", (b.sh["l"][0] - 34, ys + 226), bend=0.08)
    b.arm_to("r", (cx + 50, ys + 54), elbow=(b.sh["r"][0] + 34, ys + 104))
    b.legs("troll", foot="claw", z=1, thigh=1.1, shin=1.0, foot_w=1.9)
    c.add("torso", "troll", 3, [E(cx, ys + 40, 170, 100), E(cx, yh - 46, 130, 120), E(cx, yh - 8, 104, 46)], tags=("torso",))
    c.add("moss", "moss", 3.2, [E(cx - 50, ys + 24, 60, 30), E(cx + 36, yh - 60, 40, 24)], tags=("torso",), clip_to="torso")
    c.add("loincloth", "cloth_rag", 3.3, [P("bookmark", cx - 4, yh + 38, 76, 76), E(cx, yh + 4, 118, 24)], tags=("torso",))
    c.add("rope", "leather", 3.5, [E(cx, yh - 4, 122, 12)], tags=("torso",))
    b.arm("l", "troll", z=4, upper=1.0, fore=0.95, hand=1.35, claws=0.8)
    b.arm("r", "troll", z=4, upper=1.0, fore=0.95, hand=1.35)
    c.add("club", "wood", 3.9, [held("baseball_bat", b.hand["r"], 170, -64, grip=0.4)], tags=("arm_r",), pivot=list(b.sh["r"]))
    # attack: both arms up, club over the head
    b.arm_to("r", (cx + 34, ys - 106), elbow=(b.sh["r"][0] + 46, ys - 40))
    b.arm("r", "troll", z=8.6, upper=1.0, fore=0.95, hand=1.35, suffix="_atk", hidden=True, tags=("atk",))
    c.add("club_atk", "wood", 8.4, [held("baseball_bat", b.hand["r"], 160, -160, grip=0.4)], tags=("atk",), hidden=True)
    b.arm_to("l", (cx - 16, ys - 100), elbow=(b.sh["l"][0] - 40, ys - 36))
    b.arm("l", "troll", z=8.7, upper=1.0, fore=0.95, hand=1.35, suffix="_atk", hidden=True, tags=("atk",))
    # head
    c.add("neck", "troll", 5, [E(cx, ys - 4, 60, 44)], tags=("head",))
    c.add("hair_back", "hair", 6.2, [E(cx, hy0 - 14, 92, 60), P("droplet", cx - 44, hy0 + 20, 20, 60, flip="y", rot=10),
                                     P("droplet", cx + 46, hy0 + 18, 20, 56, flip="y", rot=-10)], tags=("head",))
    c.add("ears", "troll", 6.4, sym([P("droplet", cx - 44, hy0 - 2, 18, 44, rot=-75)], cx), tags=("head",))
    c.add("head", "troll", 7, [E(cx, hy0, 78, 72), E(cx, hy0 + 20, 86, 50)], tags=("head",))
    c.add("hair", "hair", 7.2, [P("droplet", cx - 18, hy0 - 30, 26, 30, flip="y", rot=20), P("droplet", cx + 12, hy0 - 32, 24, 30, flip="y", rot=-14)],
          tags=("head",))
    c.add("brow", "troll", 7.5, [E(cx, hy0 - 12, 70, 14)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.45, [E(cx - 16, hy0 - 4, 9, 7), E(cx + 16, hy0 - 4, 9, 7)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.5, opacity=0.3)
    x_eyes(c, cx, hy0 - 4, 16, 5, z=7.55, width=4, tags=("head",))
    c.add("nose", "troll", 7.7, [P("droplet", cx, hy0 + 12, 24, 44, flip="y")], tags=("head",))
    c.flat("mouth", "mouth", 7.6, smile(cx, hy0 + 34, 44, 10, frown=True), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.6, [E(cx, hy0 + 36, 46, 22)], tags=("head", "mouth_open"), hidden=True)
    c.add("tusks", "tooth", 7.8, [P("triangle", cx - 16, hy0 + 30, 8, 13, rot=-6), P("triangle", cx + 17, hy0 + 30, 8, 13, rot=6)],
          tags=("head",), line={"width": 0.6, "heavy": 0.5})
    sr, sl = list(b.sh["r"]), list(b.sh["l"])
    std_frames(
        c,
        attack_move={"head": {"rot": -3, "pivot": [cx, ys]}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 30, "pivot": sl}, "arm_r": {"rot": -26, "pivot": sr},
                  "head": {"rot": 10, "pivot": [cx, ys]}, "all": c.whole(rot=6, dx=14, dy=-4, s=0.97)},
        shadow_hit_dx=10,
    )
    c.meta.update(name_ko="트롤", size="큼")
    return c


# ---------------------------------------------------------------- A: mimic (treasure chest)
@creature("mimic_chest", "A")
def mimic_chest():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("mimic_chest", (W, H), (cx, gy), seed=505,
                 note="Mimic, front view. Iron-banded wooden treasure chest whose lid is a jaw: rows of teeth, glowing "
                      "eyes in the dark mouth, lolling tongue. attack = lid flung wide, tongue lashing; hit = lid snapped "
                      "almost shut, box tilted.")
    c.shadow(cx, gy - 2, 220, 26)
    # box
    c.add("box", "wood", 2, [P("square", cx, 306, 200, 118)], tags=("box",))
    c.add("bands", "iron", 2.3, [P("square", cx - 62, 306, 20, 120), P("square", cx + 62, 306, 20, 120),
                                 P("square", cx, 252, 204, 14)], tags=("box",), clip_to="box")
    c.add("lockplate", "gold", 2.6, [P("shield", cx, 286, 36, 40)], tags=("box",))
    c.flat("keyhole", "void", 2.7, [P("keyhole", cx, 288, 12, 18)], tags=("box",))
    c.add("feet", "iron", 1.8, [P("square", cx - 86, 362, 26, 16), P("square", cx + 86, 362, 26, 16)], tags=("box",))
    # mouth (between box and lid)
    c.flat("maw", "mouth", 1.5, [E(cx, 238, 188, 70)], tags=("maw",))
    c.glow("eyes", "glow_yellow", 1.7, [E(cx - 34, 236, 20, 12, rot=10), E(cx + 34, 236, 20, 12, rot=-10)], tags=("maw", "eyes"),
           color="glow_yellow_c", strength=0.9, opacity=0.5)
    c.flat("pupils", "eye", 1.75, [E(cx - 34, 236, 5, 11), E(cx + 34, 236, 5, 11)], tags=("maw", "eyes"))
    c.glow("eyes_hit", "glow_yellow", 1.7, [seg(cx - 44, 238, cx - 24, 236, 3.5), seg(cx + 24, 236, cx + 44, 238, 3.5)],
           tags=("maw", "eyes_hit"), color="glow_yellow_c", strength=0.9, opacity=0.4, hidden=True)
    c.add("teeth_low", "tooth", 1.9, fangs(cx - 84, cx + 84, 256, 9, 16, down=False, jitter=0.3), tags=("box",),
          line={"width": 0.6, "heavy": 0.5})
    c.add("tongue", "tongue", 2.8, tube([(cx + 8, 262), (cx + 30, 300), (cx + 12, 338)], 30, 18, n=8), tags=("tongue",))
    # lid
    c.add("lid", "wood", 3, [P("circle", cx, 198, 206, 76, half="top"), P("square", cx, 200, 206, 14)], tags=("lid",))
    c.add("lid_bands", "iron", 3.2, [P("square", cx - 62, 180, 20, 44), P("square", cx + 62, 180, 20, 44), P("square", cx, 202, 208, 10)],
          tags=("lid",), clip_to="lid")
    c.add("teeth_up", "tooth", 2.9, fangs(cx - 90, cx + 90, 206, 10, 20, jitter=0.3), tags=("lid",), line={"width": 0.6, "heavy": 0.5})
    # attack: lid wide open, maw bigger, tongue out
    c.flat("maw_atk", "mouth", 1.4, [E(cx, 206, 196, 110)], tags=("atk",), hidden=True)
    c.add("tongue_atk", "tongue", 4, tube([(cx - 4, 256), (cx - 60, 280), (cx - 70, 330), (cx - 110, 344)], 32, 16, n=12),
          tags=("atk",), hidden=True)
    std_frames(
        c,
        attack_move={"lid": {"dy": -46, "rot": -6, "pivot": [cx, 206]}, "eyes": {"dy": -22}, "all": c.whole(s=1.04, rot=-3)},
        attack_show=("atk",), attack_hide=("tongue",),
        hit_move={"lid": {"dy": 34, "rot": 7, "pivot": [cx, 206]}, "maw": {"dy": 8}, "tongue": {"dy": -18},
                  "all": c.whole(rot=8, dx=6, dy=-4)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=4,
    )
    c.meta.update(name_ko="미믹(보물상자)", size="작음")
    return c


# ---------------------------------------------------------------- A: golem
@creature("golem", "A")
def golem():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("golem", (W, H), (cx, gy), seed=506,
                 note="Stone golem, front view. Huge stacked-rock body, small head with a glowing eye slit, boulder "
                      "shoulders, block fists, glowing rune cracks, moss. attack = both fists raised overhead to smash; "
                      "hit = knocked back, eye light dimmed.")
    c.shadow(cx, gy - 2, 330, 36)

    def rock(name, mat, z, x, y, w, h, tags, flip="", **kw):
        # dark filler behind the rocks icon so its cut line reads as a crack, not a see-through gap
        c.add(name + "_fill", "stone_cap", z - 0.05, [E(x, y + h * 0.05, w * 0.86, h * 0.8)], tags=tags, line=False, **kw)
        c.add(name, mat, z, [P("rocks", x, y, w, h, **({"flip": flip} if flip else {}))], tags=tags, **kw)

    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "stone_dark", 0.9, [P("hexagon", cx + k * 66, 466, 116, 60)], tags=(f"leg_{s}",))
        rock(f"leg_{s}", "stone_dark", 1, cx + k * 62, 410, 100, 92, (f"leg_{s}",), flip="x" if k > 0 else "")
    rock("hips", "stone", 2, cx, 352, 196, 100, ("torso",))
    c.add("torso", "stone", 3, [P("octagon", cx, 256, 232, 190)], tags=("torso",))
    rock("belly", "stone", 3.1, cx - 6, 318, 176, 96, ("torso",), flip="x")
    c.add("core_ring", "stone_dark", 3.3, [P("ring", cx, 238, 60, 60)], tags=("torso",))
    c.glow("runes", "glow_cyan", 3.4, [P("lightning_bolt", cx - 58, 262, 20, 56, rot=20), P("lightning_bolt", cx + 58, 280, 16, 46, rot=-25),
                                       E(cx, 238, 30, 30)], tags=("torso", "runes"), color="glow_cyan_c", strength=0.8, opacity=0.5)
    c.add("moss", "moss", 3.6, [E(cx - 76, 196, 70, 34), E(cx + 72, 300, 46, 24)], tags=("torso",), clip_to="torso")
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = cx + k * 132, 196
        arms[s] = (sx, sy)
        c.add(f"arm_{s}", "stone_dark", 4, [E(sx + k * 10, 262, 70, 90), E(sx + k * 16, 336, 64, 70)], tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"fist_{s}", "stone", 4.3, [P("hexagon", sx + k * 18, 404, 100, 90)], tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"knuckle_{s}", "stone_dark", 4.4, [P("square", sx + k * 18 + d * 22, 380, 18, 14) for d in (-1, 0, 1)],
              tags=(f"arm_{s}",), pivot=[sx, sy])
        rock(f"shoulder_{s}", "stone", 5, sx, sy, 112, 98, ("shoulders",), flip="x" if k > 0 else "")
        c.add(f"arm_{s}_atk", "stone_dark", 4, [E(sx + k * 8, sy - 44, 70, 90), E(cx + k * 100, sy - 92, 64, 66)], tags=("atk",), hidden=True)
        c.add(f"fist_{s}_atk", "stone", 4.3, [P("hexagon", cx + k * 88, sy - 120, 100, 90)], tags=("atk",), hidden=True)
    c.add("head", "stone", 6, [P("square", cx, 152, 92, 70)], tags=("head",))
    rock("brow", "stone", 6.1, cx, 122, 100, 42, ("head",))
    c.flat("visor", "void", 6.2, [P("square", cx, 158, 64, 16)], tags=("head",))
    c.glow("eyes", "glow_cyan", 6.3, [E(cx - 16, 158, 14, 8), E(cx + 16, 158, 14, 8)], tags=("head", "eyes"),
           color="glow_cyan_c", strength=1.0, opacity=0.7)
    c.glow("eyes_hit", "glow_cyan", 6.3, [E(cx - 16, 160, 12, 3), E(cx + 16, 160, 12, 3)], tags=("head", "eyes_hit"),
           color="glow_cyan_c", strength=0.4, opacity=0.3, hidden=True)
    sl, sr = list(arms["l"]), list(arms["r"])
    std_frames(
        c,
        attack_move={"shoulders": {"dy": -10}, "head": {"dy": 6}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("atk",), attack_hide=("arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 12, "pivot": sl}, "arm_r": {"rot": -8, "pivot": sr}, "head": {"rot": 8, "pivot": [cx, 190]},
                  "all": c.whole(rot=5, dx=2, dy=-4, s=0.96)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=2,
    )
    c.meta.update(name_ko="돌 골렘", size="큼")
    return c


# ---------------------------------------------------------------- A: harpy
@creature("harpy", "A")
def harpy():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("harpy", (W, H), (cx, gy), seed=507,
                 note="Harpy, front view. Hovering bird-woman monster: brown feathered wings for arms, fully feathered "
                      "body, grey face with yellow eyes and a wild dark mane, scaly bird legs with hooked talons. attack = "
                      "wings flung up and talons thrust forward, screeching; hit = wings crumpled, knocked sideways.")
    c.shadow(cx, gy - 2, 150, 20, opacity=0.34, blur=6)
    lift = -22
    # wings (behind the body)
    for s, k in (("l", -1), ("r", 1)):
        root = (cx + k * 30, 196 + lift)
        c.add(f"wing_{s}", "feather_brown", 1, [wing_at(root, 184, 158, s, rot=k * -8)], tags=(f"wing_{s}", "wings"), pivot=list(root))
        c.add(f"wing_{s}_tips", "feather_black", 1.1, [wing_at(root, 184, 158, s, rot=k * -8, tips=True)], tags=(f"wing_{s}", "wings"),
              pivot=list(root), clip_to=f"wing_{s}", line={"width": 0.7, "heavy": 0.5})
    # legs
    for s, k in (("l", -1), ("r", 1)):
        hx, hy = cx + k * 20, 262 + lift
        fx, fy = cx + k * 34, 336 + lift
        c.add(f"thigh_{s}", "feather_brown", 2, [E(hx, hy, 40, 50)], tags=(f"leg_{s}", "legs"))
        c.add(f"shin_{s}", "horn", 1.8, [seg(hx + k * 4, hy + 16, fx, fy - 8, 12)], tags=(f"leg_{s}", "legs"))
        c.add(f"talon_{s}", "claw", 1.9, [P("moon", fx + k * d * 9, fy + 6, 14, 14, rot=-45 + k * 20 + d * 25) for d in (-1, 0, 1)],
              tags=(f"leg_{s}", "legs"))
    c.add("body", "feather_brown", 3, [E(cx, 214 + lift, 80, 98), E(cx, 250 + lift, 72, 64)], tags=("body",))
    c.add("breast", "feather_pale", 3.2, [P("droplet", cx, 232 + lift, 46, 76, flip="y")], tags=("body",), clip_to="body")
    c.add("mane", "hair", 4, [E(cx, 136 + lift, 88, 70), P("droplet", cx - 38, 170 + lift, 26, 56, flip="y", rot=16),
                              P("droplet", cx + 38, 170 + lift, 26, 56, flip="y", rot=-16), P("droplet", cx, 176 + lift, 40, 50, flip="y")],
          tags=("head",))
    c.add("neck", "pale", 4.2, [E(cx, 176 + lift, 26, 28)], tags=("head",))
    c.add("head", "pale", 5, [E(cx, 140 + lift, 52, 60)], tags=("head",))
    c.add("crest", "feather_black", 5.5, [P("feather", cx - 16, 106 + lift, 18, 34, rot=-30), P("feather", cx + 4, 100 + lift, 18, 38, rot=5),
                                          P("feather", cx + 22, 108 + lift, 16, 30, rot=35)], tags=("head",))
    c.add("fringe", "hair", 5.6, [P("droplet", cx - 12, 118 + lift, 22, 26, flip="y", rot=24), P("droplet", cx + 12, 118 + lift, 22, 26, flip="y", rot=-24)],
          tags=("head",))
    c.glow("eyes", "glow_yellow", 6, [E(cx - 12, 140 + lift, 13, 9, rot=14), E(cx + 12, 140 + lift, 13, 9, rot=-14)],
           tags=("head", "eyes"), color="glow_yellow_c", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 6.1, [E(cx - 12, 140 + lift, 4, 7), E(cx + 12, 140 + lift, 4, 7)], tags=("head", "eyes"))
    c.flat("brows", "eye", 6.2, brows(cx, 131 + lift, 12, 14, 3.5, tilt=18), tags=("head",))
    x_eyes(c, cx, 140 + lift, 12, 5, z=6.1, width=3.5, tags=("head",))
    c.flat("mouth", "mouth", 6.1, smile(cx, 158 + lift, 16, 6, frown=True), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 6.1, [E(cx, 160 + lift, 16, 14)], tags=("head", "mouth_open"), hidden=True)
    rl, rr = [cx - 30, 196 + lift], [cx + 30, 196 + lift]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 22, "pivot": rl}, "wing_r": {"rot": -22, "pivot": rr},
                     "legs": {"dy": -26, "sy": 0.9, "pivot": [cx, 262 + lift]}, "all": c.whole(s=1.05, dy=-6)},
        shadow_attack={"sx": 0.85, "sy": 0.85, "pivot": [cx, gy - 2]},
        hit_move={"wing_l": {"rot": -14, "pivot": rl}, "wing_r": {"rot": 26, "pivot": rr}, "head": {"rot": -12, "pivot": [cx, 176 + lift]},
                  "all": c.whole(rot=-4, dx=0, dy=8, s=0.94)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="하피", size="사람")
    return c


# ---------------------------------------------------------------- A: minotaur
@creature("minotaur", "A")
def minotaur():
    from .kit import held
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("minotaur", (W, H), (cx, gy), seed=508,
                 note="Minotaur, front view. Huge dark-brown bull-man: wide muzzle with a bronze nose ring, long curved "
                      "horns, small red eyes, shaggy shoulders, leather belt and loincloth, hooves, great maul. attack = maul "
                      "raised overhead with both hands, bellowing; hit = head snapped aside, staggering.")
    b = Biped(c, cx, gy, 440, build=1.3, leg=0.38, torso=0.33, head=0.19, shoulder=0.19, hip=0.105, arm_w=0.085,
              leg_w=0.1, arm_len=0.4, stance=1.2, hunch=0.05)
    c.shadow(cx, gy - 2, 290, 34)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.arm_to("l", (b.sh["l"][0] - 26, ys + 160), bend=0.1)
    b.arm_to("r", (cx + 100, ys + 110), elbow=(b.sh["r"][0] + 26, ys + 70))
    b.legs("fur_brown", foot_mat="horn", foot="hoof", z=1, thigh=1.1, shin=0.95, foot_w=1.3, foot_h=0.8)
    c.add("torso", "fur_brown", 3, [E(cx, ys + 50, 240, 120), E(cx, yh - 46, 170, 120), E(cx, yh - 6, 146, 50)], tags=("torso",))
    c.add("chest_fur", "fur_dark", 3.2, [E(cx, ys + 30, 180, 70), P("droplet", cx, ys + 80, 60, 70, flip="y")], tags=("torso",), clip_to="torso")
    c.add("belt", "leather", 3.5, [E(cx, yh - 2, 176, 24)], tags=("torso",))
    c.add("buckle", "bronze", 3.55, [P("octagon", cx, yh - 2, 28, 26)], tags=("torso",))
    c.add("loincloth", "cloth_wine", 3.3, [P("bookmark", cx, yh + 44, 86, 84), E(cx, yh + 8, 150, 28)], tags=("torso",))
    b.arm("l", "fur_brown", z=4, upper=1.05, fore=0.95, hand=1.2)
    b.arm("r", "fur_brown", z=4, upper=1.05, fore=0.95, hand=1.2)
    c.add("maul", "iron", 4.5, [held("sledgehammer", b.hand["r"], 150, 76, grip=0.5)], tags=("arm_r",), pivot=list(b.sh["r"]))
    b.arm_to("r", (cx + 40, ys - 64), elbow=(b.sh["r"][0] + 40, ys - 10))
    b.arm("r", "fur_brown", z=8.6, upper=1.05, fore=0.95, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    b.arm_to("l", (cx - 14, ys - 56), elbow=(b.sh["l"][0] - 40, ys - 4))
    b.arm("l", "fur_brown", z=8.7, upper=1.05, fore=0.95, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    c.add("maul_atk", "iron", 8.5, [held("sledgehammer", (cx + 12, ys - 58), 160, -150, grip=0.5)], tags=("atk",), hidden=True)
    c.add("hump", "fur_brown", 5, [E(cx, ys - 2, 124, 50)], tags=("head",))
    c.add("horns", "horn", 6.4, tube([(cx - 38, hy0 - 22), (cx - 96, hy0 - 30), (cx - 110, hy0 - 84)], 22, 6, n=12)
          + tube([(cx + 38, hy0 - 22), (cx + 96, hy0 - 30), (cx + 110, hy0 - 84)], 22, 6, n=12), tags=("head",))
    c.add("ears", "fur_brown", 6.5, sym([P("droplet", cx - 56, hy0 - 4, 20, 40, rot=-100)], cx), tags=("head",))
    c.add("head", "fur_brown", 7, [E(cx, hy0 - 10, 88, 76), P("droplet", cx, hy0 + 12, 84, 90, flip="y")], tags=("head",))
    c.add("tuft", "fur_dark", 7.1, [P("cloud", cx, hy0 - 44, 60, 30)], tags=("head",))
    c.add("muzzle", "snout", 7.5, [E(cx, hy0 + 34, 74, 50)], tags=("head",))
    c.flat("nostrils", "mouth", 7.6, [E(cx - 15, hy0 + 32, 12, 9, rot=-20), E(cx + 15, hy0 + 32, 12, 9, rot=20)], tags=("head",))
    c.add("ring", "gold", 7.7, [P("ring", cx, hy0 + 50, 26, 22)], tags=("head",))
    c.glow("eyes", "glow_red", 7.4, [E(cx - 24, hy0 - 4, 12, 8, rot=16), E(cx + 24, hy0 - 4, 12, 8, rot=-16)],
           tags=("head", "eyes"), color="glow_red_c", strength=0.7, opacity=0.4)
    x_eyes(c, cx, hy0 - 4, 24, 6, z=7.45, width=4.5, tags=("head",))
    c.flat("mouth", "mouth", 7.55, smile(cx, hy0 + 52, 44, 8, frown=True), tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.55, [E(cx, hy0 + 58, 44, 22)], tags=("head", "mouth_open"), hidden=True)
    sr, sl = list(b.sh["r"]), list(b.sh["l"])
    std_frames(
        c,
        attack_move={"head": {"rot": -4, "dy": 6, "pivot": [cx, ys]}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"arm_l": {"rot": 28, "pivot": sl}, "arm_r": {"rot": -16, "pivot": sr},
                  "head": {"rot": 14, "pivot": [cx, ys]}, "all": c.whole(rot=6, dx=4, dy=-4, s=0.96)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="미노타우로스", size="큼")
    return c


# ---------------------------------------------------------------- A: lizardman
@creature("lizardman", "A")
def lizardman():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("lizardman", (W, H), (cx, gy), seed=509,
                 note="Lizardman, front view. Green-scaled reptile warrior: blunt snout with slit yellow eyes, spiny head "
                      "frill, pale belly plates, tail sweeping behind, round wooden shield and iron-tipped spear. attack = "
                      "spear raised to throw, shield forward, jaws open; hit = recoils behind the shield, eyes shut.")
    b = Biped(c, cx, gy, 320, build=1.0, leg=0.4, torso=0.31, head=0.19, shoulder=0.16, hip=0.09, arm_w=0.07,
              leg_w=0.085, arm_len=0.37, stance=1.3, hunch=0.03)
    c.shadow(cx + 16, gy - 2, 220, 26)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    c.add("tail", "scale_green", 0.5, tube([(cx + 20, yh), (cx + 110, yh + 60), (cx + 150, gy - 14)], 44, 12, n=12), tags=("tail",))
    b.arm_to("l", (b.sh["l"][0] - 8, ys + 96), bend=0.2)
    b.arm_to("r", (b.sh["r"][0] + 14, ys + 100), bend=0.14)
    b.legs("scale_green", foot="claw", z=1, thigh=1.1, shin=0.9, foot_w=1.8)
    b.torso("scale_green", z=3, chest=0.95, shape="chest")
    c.add("belly", "belly", 3.2, [P("droplet", cx, ys + 74, 70, 120, flip="y")], tags=("torso",), clip_to="torso")
    c.add("harness", "leather", 3.4, [seg(cx - 44, ys + 6, cx + 40, yh - 12, 9)], tags=("torso",), cast=False)
    c.add("belt", "leather", 3.5, [E(cx, yh - 2, 100, 14)], tags=("torso",))
    c.add("skirt", "cloth_rag", 3.3, [P("bookmark", cx, yh + 24, 60, 50)], tags=("torso",))
    b.arm("l", "scale_green", z=4, upper=1.0, fore=0.9, hand=1.2, claws=0.7)
    b.arm("r", "scale_green", z=4, upper=1.0, fore=0.9, hand=1.2)
    hx, hy = b.hand["r"]
    c.add("spear", "wood", 3.9, [seg(hx, hy + 60, hx + 8, hy - 200, 8)], tags=("arm_r",), pivot=list(b.sh["r"]))
    c.add("spear_tip", "iron", 3.95, [P("triangle", hx + 8.5, hy - 214, 18, 34)], tags=("arm_r",), pivot=list(b.sh["r"]))
    lx, ly = b.hand["l"]
    c.add("shield", "wood", 4.6, [E(lx - 6, ly - 10, 104, 110)], tags=("arm_l", "shield"), pivot=list(b.sh["l"]))
    c.add("shield_rim", "iron", 4.65, [E(lx - 6, ly - 10, 108, 114), E(lx - 6, ly - 10, 90, 96, op="sub")], tags=("arm_l", "shield"),
          pivot=list(b.sh["l"]))
    c.add("shield_boss", "iron", 4.7, [E(lx - 6, ly - 10, 30, 30)], tags=("arm_l", "shield"), pivot=list(b.sh["l"]))
    # attack arm: spear raised back, tip pointing up-left
    b.arm_to("r", (b.sh["r"][0] + 26, ys - 40), elbow=(b.sh["r"][0] + 44, ys + 10))
    b.arm("r", "scale_green", z=4, upper=1.0, fore=0.9, hand=1.2, suffix="_atk", hidden=True, tags=("atk",))
    hx, hy = b.hand["r"]
    c.add("spear_atk", "wood", 3.9, [seg(hx + 70, hy + 24, hx - 140, hy - 60, 8)], tags=("atk",), hidden=True)
    c.add("spear_tip_atk", "iron", 3.95, [P("triangle", hx - 152, hy - 65, 18, 34, rot=-68)], tags=("atk",), hidden=True)
    # head: blunt snout seen from the front
    c.add("frill", "scale_teal", 6.3, [P("triangle", cx + d * 18, hy0 - 38 - (6 - abs(d) * 4), 16, 30, rot=d * 18) for d in (-2, -1, 0, 1, 2)],
          tags=("head",))
    c.add("head", "scale_green", 7, [E(cx, hy0 - 4, 66, 58), E(cx, hy0 + 20, 58, 44)], tags=("head",))
    c.add("jaw", "belly", 7.2, [E(cx, hy0 + 34, 44, 18)], tags=("head",), clip_to="head")
    c.glow("eyes", "glow_yellow", 7.4, [E(cx - 18, hy0 - 8, 14, 12, rot=10), E(cx + 18, hy0 - 8, 14, 12, rot=-10)],
           tags=("head", "eyes"), color="glow_yellow_c", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 7.5, [E(cx - 18, hy0 - 8, 3.5, 11), E(cx + 18, hy0 - 8, 3.5, 11)], tags=("head", "eyes"))
    x_eyes(c, cx, hy0 - 8, 18, 6, z=7.5, width=4, tags=("head",))
    c.flat("nostrils", "eye", 7.5, [E(cx - 6, hy0 + 12, 4, 3), E(cx + 6, hy0 + 12, 4, 3)], tags=("head",))
    c.flat("mouth", "mouth", 7.5, [seg(cx - 24, hy0 + 26, cx + 24, hy0 + 26, 3)], tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 7.5, [E(cx, hy0 + 30, 44, 20)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 7.6, fangs(cx - 18, cx + 18, hy0 + 22, 5, 7) + fangs(cx - 12, cx + 12, hy0 + 39, 3, 6, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    sr, sl = list(b.sh["r"]), list(b.sh["l"])
    std_frames(
        c,
        attack_move={"shield": {"dx": 10, "dy": -6}, "tail": {"rot": -8, "pivot": [cx + 20, yh]},
                     "all": c.whole(s=1.04, dy=4, rot=-2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_r"),
        hit_move={"arm_r": {"rot": -30, "pivot": sr}, "arm_l": {"rot": -12, "pivot": sl}, "head": {"rot": 10, "pivot": [cx, ys]},
                  "tail": {"rot": -6, "pivot": [cx + 20, yh]}, "all": c.whole(rot=7, dx=4, dy=-4, s=0.96)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="리자드맨", size="사람")
    return c


# ---------------------------------------------------------------- A: treant
@creature("treant", "A")
def treant():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("treant", (W, H), (cx, gy), seed=510,
                 note="Treant (tree with a face), front view. Gnarled dark trunk with a carved face (hollow glowing eyes, "
                      "jagged mouth), leafy crown, branch arms with twig fingers, splayed roots, moss and shelf fungus. "
                      "attack = branches raised and mouth gaping; hit = crown and trunk bent back, eyes squeezed to slits.")
    c.shadow(cx, gy - 2, 320, 34)
    # roots
    for k in (-1, 1):
        c.add(f"root_{k}", "bark", 1, tube([(cx + k * 30, 420), (cx + k * 90, 460), (cx + k * 150, gy - 8)], 44, 14, n=10), tags=("roots",))
        c.add(f"root2_{k}", "bark", 1.1, tube([(cx + k * 10, 440), (cx + k * 40, 470), (cx + k * 60, gy - 4)], 36, 12, n=8), tags=("roots",))
    c.add("trunk", "bark", 2, [P("droplet", cx, 330, 170, 320, flip="y"), E(cx, 420, 170, 110)], tags=("trunk",))
    c.add("moss", "moss", 2.3, [E(cx - 56, 430, 70, 40), E(cx + 60, 250, 40, 60)], tags=("trunk",), clip_to="trunk")
    c.add("fungus", "mushroom_stem", 2.5, [P("circle", cx + 78, 360, 40, 20, half="top"), P("circle", cx + 70, 378, 30, 16, half="top")],
          tags=("trunk",))
    # face
    c.flat("sockets", "void", 2.6, [E(cx - 34, 300, 42, 30, rot=12), E(cx + 34, 300, 42, 30, rot=-12)], tags=("trunk", "face"))
    c.glow("eyes", "glow_green", 2.7, [E(cx - 34, 302, 14, 10), E(cx + 34, 302, 14, 10)], tags=("trunk", "eyes"),
           color="glow_green_c", strength=0.9, opacity=0.6)
    c.glow("eyes_hit", "glow_green", 2.7, [E(cx - 34, 304, 18, 3), E(cx + 34, 304, 18, 3)], tags=("trunk", "eyes_hit"),
           color="glow_green_c", strength=0.6, opacity=0.4, hidden=True)
    c.add("brow", "bark", 2.8, [E(cx - 36, 282, 56, 18, rot=14), E(cx + 36, 282, 56, 18, rot=-14)], tags=("trunk", "face"))
    c.flat("mouth", "void", 2.6, [P("mountains", cx, 364, 76, 34, flip="y")], tags=("trunk", "mouth"))
    c.flat("mouth_open", "void", 2.6, [E(cx, 370, 84, 56), P("mountains", cx, 352, 80, 20, op="sub")], tags=("trunk", "mouth_open"), hidden=True)
    # branch arms
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = cx + k * 70, 250
        arms[s] = [sx, sy]
        twig = [(cx + k * 190, 340)]
        c.add(f"arm_{s}", "bark", 3, tube([(sx, sy), (cx + k * 150, 262), twig[0]], 38, 16, n=10)
              + tube([twig[0], (cx + k * 204, 382)], 14, 6, n=5) + tube([twig[0], (cx + k * 222, 360)], 12, 5, n=5)
              + tube([twig[0], (cx + k * 180, 386)], 12, 5, n=5), tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"arm_{s}_leaf", "leaf", 3.2, [P("leaf", cx + k * 150, 250, 34, 30, rot=k * 30, **({"flip": "x"} if k < 0 else {}))],
              tags=(f"arm_{s}",), pivot=[sx, sy])
        up = [(sx, sy), (cx + k * 150, 200), (cx + k * 170, 110)]
        c.add(f"arm_{s}_atk", "bark", 3, tube(up, 38, 16, n=10) + tube([up[-1], (cx + k * 150, 70)], 14, 6, n=5)
              + tube([up[-1], (cx + k * 204, 90)], 12, 5, n=5) + tube([up[-1], (cx + k * 196, 130)], 12, 5, n=5),
              tags=("atk",), hidden=True)
    # crown
    c.add("crown_back", "leaf_dark", 4, [P("cloud", cx, 150, 340, 170), E(cx - 110, 190, 120, 90), E(cx + 110, 190, 120, 90)], tags=("crown",))
    c.add("crown", "leaf", 4.5, [P("cloud", cx - 40, 128, 220, 120), P("cloud", cx + 60, 150, 200, 110, flip="x"),
                                 E(cx - 120, 160, 96, 80), E(cx + 120, 110, 80, 60)], tags=("crown",))
    c.add("crown_moss", "moss", 4.6, [E(cx - 20, 200, 180, 36)], tags=("crown",), clip_to="crown", opacity=0.6)
    sl, sr = arms["l"], arms["r"]
    std_frames(
        c,
        attack_move={"crown": {"dy": -6}, "all": c.whole(s=1.03, dy=2)},
        attack_show=("mouth_open", "atk"), attack_hide=("mouth", "arm_l", "arm_r"),
        hit_move={"crown": {"rot": 7, "dx": 2, "pivot": [cx, 250]}, "arm_l": {"rot": 16, "pivot": sl}, "arm_r": {"rot": -14, "pivot": sr},
                  "all": c.whole(rot=4, dx=0, s=0.95)},
        hit_show=("eyes_hit", "mouth_open"), hit_hide=("eyes", "mouth"), shadow_hit_dx=2,
    )
    c.meta.update(name_ko="나무 괴물", size="큼")
    return c


# ---------------------------------------------------------------- A: mushroom
@creature("mushroom", "A")
def mushroom():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("mushroom", (W, H), (cx, gy), seed=511,
                 note="Mushroom monster, front view. Dull red spotted cap over pale gills, stout stem body with a grumpy "
                      "face, stubby arms and feet. attack = hops up with the cap tipped forward, mouth wide; hit = squashed, "
                      "cap knocked askew, eyes squeezed.")
    c.shadow(cx, gy - 2, 170, 22)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "mushroom_stem", 1, [E(cx + k * 30, gy - 12, 46, 26)], tags=("legs",))
    c.add("stem", "mushroom_stem", 2, [P("cylinder", cx, 290, 116, 140), E(cx, 336, 120, 50)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "mushroom_stem", 2.5, [seg(cx + k * 52, 262, cx + k * 78, 300, 20), E(cx + k * 80, 306, 22, 22)],
              tags=(f"arm_{s}",), pivot=[cx + k * 52, 262])
    dot_eyes(c, cx, 276, 24, 18, 22, z=3, tags=("eyes", "body"))
    c.flat("brows", "eye", 3.2, brows(cx, 258, 24, 22, 5, tilt=16), tags=("body",))
    x_eyes(c, cx, 276, 24, 8, z=3.1, width=4.5, tags=("body",))
    c.flat("mouth", "mouth", 3, smile(cx, 306, 30, 10, frown=True), tags=("body", "mouth"))
    c.flat("mouth_open", "mouth", 3, [E(cx, 310, 38, 28)], tags=("body", "mouth_open"), hidden=True)
    c.add("gills", "mushroom_stem", 4, [E(cx, 222, 210, 44)], tags=("cap",))
    c.flat("gill_lines", "mushroom_cap", 4.1, [seg(cx + d * 18, 214, cx + d * 24, 238, 3) for d in range(-5, 6)],
           tags=("cap",), clip_to="gills", opacity=0.5)
    c.add("cap", "mushroom_cap", 5, [P("circle", cx, 186, 248, 170, half="top"), E(cx, 196, 250, 44)], tags=("cap",))
    c.add("spots", "spot", 5.2, [E(cx - 70, 170, 40, 30), E(cx + 10, 136, 50, 34), E(cx + 84, 176, 34, 26), E(cx - 22, 198, 26, 16),
                                 E(cx + 58, 128, 20, 16)], tags=("cap",), clip_to="cap")
    sl, sr = [cx - 52, 262], [cx + 52, 262]
    std_frames(
        c,
        attack_move={"cap": {"rot": -8, "dy": 6, "pivot": [cx, 222]}, "arm_l": {"rot": 60, "pivot": sl}, "arm_r": {"rot": -60, "pivot": sr},
                     "all": c.whole(sy=1.06, sx=0.96, dy=-18)},
        shadow_attack={"sx": 0.8, "sy": 0.8, "pivot": [cx, gy - 2]},
        hit_move={"cap": {"rot": 14, "dx": 8, "pivot": [cx, 222]}, "arm_l": {"rot": -20, "pivot": sl}, "arm_r": {"rot": 30, "pivot": sr},
                  "all": c.whole(sy=0.9, sx=1.06, rot=5)},
        shadow_hit_dx=2,
    )
    c.meta.update(name_ko="버섯 괴물", size="작음")
    return c


# ---------------------------------------------------------------- A: fire spirit
@creature("fire_spirit", "A")
def fire_spirit():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("fire_spirit", (W, H), (cx, gy), seed=512,
                 note="Fire spirit, front view. Hovering elemental of layered flame tongues (dark red rim, orange body, "
                      "yellow-white core) with dark coal eyes and flame arms, trailing into a wisp; whole body is "
                      "emissive. attack = flares up tall with arms flung high, mouth roaring; hit = flame squashed and "
                      "bent aside, eyes squeezed.")
    c.shadow(cx, gy - 2, 120, 18, opacity=0.3, blur=6)

    def flame(x, y, w, h, rot=0.0, flip=False):
        extra = {"flip": "x"} if flip else {}
        return [P("fire", x, y, w, h, rot, **extra), E(x + (-0.06 if flip else 0.06) * w, y + 0.16 * h, w * 0.46, h * 0.42)]

    body = flame(cx, 214, 190, 250) + flame(cx - 54, 250, 90, 130, rot=-18, flip=True) + flame(cx + 54, 250, 90, 130, rot=18) \
        + [P("droplet", cx, 316, 90, 110, flip="y")]
    c.add("outer", "fire_outer", 2, body, tags=("body",), emit=0.8, line={"width": 0.8, "heavy": 0.6})
    c.add("mid", "fire_mid", 2.5, flame(cx, 226, 150, 196) + [P("droplet", cx, 306, 64, 80, flip="y")], tags=("body",), emit=0.9, line=False)
    c.add("core", "fire_core", 3, flame(cx, 244, 96, 124), tags=("body",), emit=1.0, line=False,
          glow={"radius": 4, "opacity": 0.4, "color": "flame_glow"})
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "fire_outer", 3.5, flame(cx + k * 92, 222, 52, 96, rot=k * 40, flip=k < 0), tags=(f"arm_{s}",), emit=0.85,
              pivot=[cx + k * 50, 240], line={"width": 0.8, "heavy": 0.6})
        c.add(f"arm_{s}_c", "fire_mid", 3.6, flame(cx + k * 92, 228, 30, 56, rot=k * 40, flip=k < 0), tags=(f"arm_{s}",), emit=0.95,
              pivot=[cx + k * 50, 240], line=False)
    c.flat("eyes", "soot", 4, [E(cx - 22, 236, 20, 26, rot=-10), E(cx + 22, 236, 20, 26, rot=10)], tags=("eyes",))
    c.glow("pupils", "glow_white", 4.1, [E(cx - 22, 238, 6, 8), E(cx + 22, 238, 6, 8)], tags=("eyes",), color="lamp_glow")
    x_eyes(c, cx, 238, 22, 8, mat="soot", z=4.1, width=5)
    c.flat("mouth", "soot", 4, smile(cx, 272, 34, 14), tags=("mouth",))
    c.flat("mouth_open", "soot", 4, [E(cx, 276, 40, 34)], tags=("mouth_open",), hidden=True)
    c.add("embers", "fire_mid", 1.5, [P("fire", cx - 84, 150, 20, 26, rot=-10), P("fire", cx + 90, 170, 16, 22, rot=12),
                                      P("fire", cx + 60, 110, 14, 18)], tags=("embers",), emit=1.0, line={"width": 0.6, "heavy": 0.5})
    sl, sr = [cx - 50, 240], [cx + 50, 240]
    std_frames(
        c,
        attack_move={"arm_l": {"rot": 40, "pivot": sl}, "arm_r": {"rot": -40, "pivot": sr}, "embers": {"dy": -20},
                     "all": c.whole(sx=0.94, sy=1.16, dy=-6)},
        hit_move={"arm_l": {"rot": -30, "pivot": sl}, "arm_r": {"rot": 6, "pivot": sr}, "embers": {"dx": 10},
                  "all": c.whole(sx=1.04, sy=0.84, rot=10, dx=-6)},
        shadow_hit_dx=4,
    )
    c.meta.update(name_ko="불 정령", size="사람")
    return c


# ---------------------------------------------------------------- A: dragon
@creature("dragon", "A")
def dragon():
    W, H = 768, 640
    cx, gy = 384, 620
    c = Creature("dragon", (W, H), (cx, gy), seed=513,
                 note="Dragon, front view. Dark crimson-scaled dragon rearing on its hind legs: huge membrane wings "
                      "spread behind, long neck with a spiny ridge, horned head with glowing eyes, pale belly plates, "
                      "clawed forelegs, spiked tail curling around the front. attack = wings raised, neck thrown forward, "
                      "jaws wide; hit = wings folded down, head flung aside with eyes shut.")
    c.shadow(cx, gy - 4, 520, 50)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 70, 300), 290, 170, "membrane_red", "horn", 1 + (0.01 if k > 0 else 0), (f"wing_{s}", "wings"))
    tail_c = [(cx + 60, 520), (cx + 200, 588), (cx + 320, 560), (cx + 300, 470)]
    c.add("tail", "scale_red", 1.5, tube(tail_c, 70, 18, n=18), tags=("tail",))
    c.add("tail_tip", "horn", 1.6, [P("triangle", cx + 298, 452, 40, 50, rot=-10)], tags=("tail",))
    c.add("tail_spikes", "horn", 1.4, spikes_on(tail_c, 6, 30, 20, 0.2, 0.9, side=-1), tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"thigh_{s}", "scale_red", 2, [E(cx + k * 120, 500, 130, 170, rot=k * -10)], tags=("legs",))
        c.add(f"foot_{s}", "scale_red", 2.1, [E(cx + k * 150, 596, 110, 40)], tags=("legs",))
        c.add(f"toes_{s}", "claw", 2.2, [P("triangle", cx + k * 150 + d * 30, 612, 16, 26, rot=180 + d * 10) for d in (-1, 0, 1)],
              tags=("legs",))
    c.add("body", "scale_red", 3, [E(cx, 420, 290, 260), E(cx, 520, 230, 120)], tags=("body",))
    c.add("belly", "belly", 3.2, [P("droplet", cx, 450, 150, 250, flip="y")], tags=("body",), clip_to="body")
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = cx + k * 110, 370
        arms[s] = [sx, sy]
        c.add(f"arm_{s}", "scale_red", 4, [seg(sx, sy, cx + k * 150, 440, 50), seg(cx + k * 150, 440, cx + k * 96, 490, 40)],
              tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"claws_{s}", "claw", 4.2, [P("triangle", cx + k * 90 + d * 14, 512, 12, 24, rot=180 - k * 20) for d in (-1, 0, 1)],
              tags=(f"arm_{s}",), pivot=[sx, sy])
    neck = [(cx, 360), (cx - 10, 290), (cx + 10, 220)]
    c.add("neck", "scale_red", 5, tube(neck, 110, 76, n=10), tags=("neck", "head"))
    c.add("throat", "belly", 5.1, tube(neck, 58, 40, n=10), tags=("neck", "head"), clip_to="neck")
    c.add("head_spikes", "horn", 4.9, [P("triangle", cx + d * 26, 140 - 10 * (2 - abs(d)), 18, 40, rot=d * 22) for d in (-2, -1, 0, 1, 2)],
          tags=("head",))
    c.add("horns", "horn", 5.9, tube([(cx - 40, 150), (cx - 96, 120), (cx - 120, 50)], 26, 6, n=12)
          + tube([(cx + 40, 150), (cx + 96, 120), (cx + 120, 50)], 26, 6, n=12), tags=("head",))
    c.add("head", "scale_red", 6, [E(cx, 170, 128, 100), E(cx, 214, 92, 70)], tags=("head",))
    c.add("brows", "scale_red", 6.3, [E(cx - 34, 156, 52, 22, rot=18), E(cx + 34, 156, 52, 22, rot=-18)], tags=("head",))
    c.glow("eyes", "glow_yellow", 6.2, [E(cx - 32, 168, 22, 12, rot=14), E(cx + 32, 168, 22, 12, rot=-14)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.9, opacity=0.5)
    c.flat("pupils", "eye", 6.25, [E(cx - 32, 168, 4, 11), E(cx + 32, 168, 4, 11)], tags=("head", "eyes"))
    x_eyes(c, cx, 168, 32, 8, z=6.25, width=5, tags=("head",))
    c.flat("nostrils", "mouth", 6.4, [E(cx - 14, 214, 10, 7, rot=-20), E(cx + 14, 214, 10, 7, rot=20)], tags=("head",))
    c.flat("mouth", "mouth", 6.4, [seg(cx - 40, 236, cx + 40, 236, 4)], tags=("head", "mouth"))
    c.flat("fangs_idle", "tooth", 6.5, [P("triangle", cx - 30, 244, 9, 14, flip="y"), P("triangle", cx + 30, 244, 9, 14, flip="y")],
           tags=("head", "mouth"), line={"width": 0.6, "heavy": 0.5})
    c.flat("mouth_open", "mouth", 6.4, [E(cx, 250, 96, 70)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 6.5, fangs(cx - 42, cx + 42, 222, 6, 18) + fangs(cx - 34, cx + 34, 282, 5, 14, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.6, "heavy": 0.5})
    c.add("tongue", "tongue", 6.45, [E(cx, 268, 40, 22)], tags=("head", "mouth_open"), hidden=True)
    c.add("neck_spikes", "horn", 4.8, spikes_on(neck, 3, 34, 22, 0.25, 0.85, side=-1) + spikes_on(neck, 3, 34, 22, 0.25, 0.85, side=1),
          tags=("neck", "head"))
    wl, wr = [cx - 70, 300], [cx + 70, 300]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 14, "pivot": wl}, "wing_r": {"rot": -14, "pivot": wr},
                     "head": {"dy": 26, "sx": 1.1, "sy": 1.1, "pivot": [cx, 360]}, "arm_l": {"rot": 30, "pivot": arms["l"]},
                     "arm_r": {"rot": -30, "pivot": arms["r"]}, "all": c.whole(s=1.02)},
        hit_move={"wing_l": {"rot": -24, "pivot": wl}, "wing_r": {"rot": 24, "pivot": wr},
                  "head": {"rot": 16, "dx": 20, "pivot": [cx, 360]}, "all": c.whole(rot=4, s=0.95)},
        shadow_hit_dx=0,
    )
    c.meta.update(name_ko="드래곤", size="거대")
    return c


# ---------------------------------------------------------------- A: wyvern
@creature("wyvern", "A")
def wyvern():
    W, H = 640, 512
    cx, gy = 320, 494
    c = Creature("wyvern", (W, H), (cx, gy), seed=514,
                 note="Wyvern, front view. Lean dark-green two-legged drake hovering on wing-arms, long snaking neck, "
                      "narrow horned head, hooked talons, whip tail ending in a barbed stinger. attack = dives forward "
                      "with talons out and jaws open, stinger arched overhead; hit = wings buckled, head recoiling.")
    c.shadow(cx, gy - 2, 240, 26, opacity=0.32, blur=6)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 40, 250), 250, 150, "membrane_green", "horn", 1, (f"wing_{s}", "wings"))
    tail = [(cx + 20, 330), (cx + 150, 400), (cx + 230, 330), (cx + 210, 250)]
    c.add("tail", "scale_green", 1.5, tube(tail, 44, 12, n=16), tags=("tail",))
    c.add("stinger", "horn", 1.6, [P("droplet", cx + 206, 226, 26, 50, rot=-8)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "scale_green", 2, [E(cx + k * 40, 340, 56, 80, rot=k * -12), seg(cx + k * 50, 370, cx + k * 58, 420, 20)],
              tags=("legs",))
        c.add(f"talon_{s}", "claw", 2.1, [P("moon", cx + k * 58 + d * 12, 432, 18, 18, rot=-45 + d * 30 + k * 10) for d in (-1, 0, 1)],
              tags=("legs",))
    c.add("body", "scale_green", 3, [E(cx, 290, 120, 150)], tags=("body",))
    c.add("belly", "belly", 3.2, [P("droplet", cx, 300, 64, 130, flip="y")], tags=("body",), clip_to="body")
    neck = [(cx, 240), (cx - 30, 180), (cx + 10, 130)]
    c.add("neck", "scale_green", 4, tube(neck, 56, 40, n=10), tags=("head",))
    c.add("throat", "belly", 4.1, tube(neck, 26, 18, n=10), tags=("head",), clip_to="neck")
    c.add("horns", "horn", 4.9, tube([(cx - 12, 98), (cx - 40, 70), (cx - 48, 36)], 14, 4, n=8)
          + tube([(cx + 32, 98), (cx + 60, 72), (cx + 70, 38)], 14, 4, n=8), tags=("head",))
    c.add("head", "scale_green", 5, [E(cx + 10, 108, 70, 58), E(cx + 10, 136, 46, 40)], tags=("head",))
    c.glow("eyes", "glow_red", 5.2, [E(cx - 8, 104, 14, 8, rot=16), E(cx + 28, 104, 14, 8, rot=-16)], tags=("head", "eyes"),
           color="glow_red_c", strength=0.8, opacity=0.5)
    x_eyes(c, cx + 10, 104, 18, 5, z=5.25, width=3.5, tags=("head",))
    c.flat("mouth", "mouth", 5.3, [seg(cx - 8, 146, cx + 28, 146, 3)], tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 5.3, [E(cx + 10, 152, 40, 30)], tags=("head", "mouth_open"), hidden=True)
    c.flat("fangs", "tooth", 5.4, fangs(cx - 6, cx + 26, 140, 4, 9) + fangs(cx, cx + 20, 166, 2, 7, down=False),
           tags=("head", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    wl, wr = [cx - 40, 250], [cx + 40, 250]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 22, "pivot": wl}, "wing_r": {"rot": -22, "pivot": wr}, "legs": {"dy": -20, "pivot": [cx, 330]},
                     "tail": {"rot": -24, "pivot": [cx + 20, 330]}, "head": {"dy": 14, "sx": 1.08, "sy": 1.08, "pivot": [cx, 240]},
                     "all": c.whole(s=1.04, dy=10)},
        shadow_attack={"sx": 1.1, "sy": 1.1, "pivot": [cx, gy - 2]},
        hit_move={"wing_l": {"rot": -30, "pivot": wl}, "wing_r": {"rot": 26, "pivot": wr}, "head": {"rot": 18, "dx": 12, "pivot": [cx, 240]},
                  "tail": {"rot": 10, "pivot": [cx + 20, 330]}, "all": c.whole(rot=6, dy=-10, s=0.95)},
        shadow_hit_dx=0,
    )
    c.meta.update(name_ko="와이번", size="큼")
    return c


# ---------------------------------------------------------------- A: griffon
@creature("griffon", "A")
def griffon():
    W, H = 640, 512
    cx, gy = 320, 494
    c = Creature("griffon", (W, H), (cx, gy), seed=515,
                 note="Griffon, front view. Eagle head with pale feathers and a hooked bronze beak, great brown wings "
                      "spread high, feathered chest and taloned forelegs, tawny lion haunches and a tufted tail behind. "
                      "attack = rears up, wings raised, talons lifted, beak open screeching; hit = wings sagging, head "
                      "jerked aside.")
    c.shadow(cx, gy - 2, 380, 40)
    for s, k in (("l", -1), ("r", 1)):
        root = (cx + k * 60, 250)
        c.add(f"wing_{s}", "feather_brown", 1, [wing_at(root, 290, 250, s, rot=k * -18)], tags=(f"wing_{s}", "wings"), pivot=list(root))
        c.add(f"wing_{s}_tips", "feather_black", 1.1, [wing_at(root, 290, 250, s, rot=k * -18, tips=True)], tags=(f"wing_{s}", "wings"),
              pivot=list(root), clip_to=f"wing_{s}", line={"width": 0.7, "heavy": 0.5})
    c.add("tail", "fur_tawny", 1.5, tube([(cx + 90, 440), (cx + 200, 470), (cx + 250, 390)], 26, 12, n=12), tags=("tail",))
    c.add("tail_tuft", "fur_brown", 1.6, [P("droplet", cx + 252, 372, 34, 48, rot=10)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"haunch_{s}", "fur_tawny", 2, [E(cx + k * 110, 420, 120, 120)], tags=("legs",))
        c.add(f"hindpaw_{s}", "fur_tawny", 2.1, [E(cx + k * 128, 478, 70, 30)], tags=("legs",))
    c.add("body", "fur_tawny", 3, [E(cx, 380, 220, 170)], tags=("body",))
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = cx + k * 56, 360
        arms[s] = [sx, sy]
        c.add(f"arm_{s}", "feather_pale", 4, [E(sx, sy + 10, 60, 80)], tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"shin_{s}", "horn", 3.9, [seg(sx, sy + 40, sx + k * 6, 460, 18)], tags=(f"arm_{s}",), pivot=[sx, sy])
        c.add(f"talon_{s}", "claw", 4.1, [P("moon", sx + k * 6 + d * 14, 474, 22, 22, rot=-45 + d * 30) for d in (-1, 0, 1)],
              tags=(f"arm_{s}",), pivot=[sx, sy])
    c.add("chest", "feather_pale", 4.5, [P("droplet", cx, 300, 160, 190, flip="y")], tags=("body", "chest"))
    c.add("head", "feather_pale", 6, [E(cx, 190, 118, 110), P("droplet", cx, 240, 80, 60, flip="y")], tags=("head",))
    c.add("crest", "feather_pale", 5.9, [P("feather", cx - 44, 148, 30, 50, rot=-40), P("feather", cx + 44, 148, 30, 50, rot=40, flip="x")],
          tags=("head",))
    c.add("brows", "feather_brown", 6.2, [E(cx - 26, 176, 44, 14, rot=16), E(cx + 26, 176, 44, 14, rot=-16)], tags=("head",))
    c.glow("eyes", "glow_yellow", 6.1, [E(cx - 28, 188, 18, 14), E(cx + 28, 188, 18, 14)], tags=("head", "eyes"),
           color="glow_yellow_c", strength=0.4, opacity=0.25)
    c.flat("pupils", "eye", 6.15, [E(cx - 28, 188, 8, 9), E(cx + 28, 188, 8, 9)], tags=("head", "eyes"))
    x_eyes(c, cx, 188, 28, 7, z=6.15, width=4, tags=("head",))
    c.add("beak", "bronze", 6.4, [P("droplet", cx, 222, 40, 60, flip="y"), E(cx, 206, 44, 26)], tags=("head", "mouth"))
    c.add("beak_open", "bronze", 6.4, [P("droplet", cx, 214, 40, 50, flip="y"), E(cx, 202, 44, 24), P("droplet", cx, 252, 30, 30)],
          tags=("head", "mouth_open"), hidden=True)
    c.flat("beak_gap", "mouth", 6.45, [E(cx, 238, 24, 14)], tags=("head", "mouth_open"), hidden=True)
    rl, rr = [cx - 60, 250], [cx + 60, 250]
    std_frames(
        c,
        attack_move={"wing_l": {"rot": 16, "pivot": rl}, "wing_r": {"rot": -16, "pivot": rr}, "arm_l": {"dy": -40, "rot": 20, "pivot": arms["l"]},
                     "arm_r": {"dy": -40, "rot": -20, "pivot": arms["r"]}, "all": c.whole(s=1.03, dy=-6)},
        hit_move={"wing_l": {"rot": -22, "pivot": rl}, "wing_r": {"rot": 22, "pivot": rr}, "head": {"rot": 14, "dx": 10, "pivot": [cx, 260]},
                  "all": c.whole(rot=4, s=0.95)},
        shadow_hit_dx=0,
    )
    c.meta.update(name_ko="그리폰", size="큼")
    return c


# ================================================================ B (idle only)
def serpent_head(c, name, x, y, s, mat, tags, z, open_mouth=False, rot=0.0, eye="glow_yellow", eye_c="glow_yellow_c"):
    """Small dragon / serpent head facing the viewer at (x, y), scale s (1 = 60 px wide)."""
    piv = [x, y + 40 * s]
    c.add(name, mat, z, [E(x, y, 60 * s, 48 * s, rot), E(x, y + 18 * s, 44 * s, 34 * s, rot)], tags=tags, pivot=piv)
    c.add(name + "_horns", "horn", z - 0.02, [P("triangle", x - 20 * s, y - 26 * s, 10 * s, 24 * s, rot - 24),
                                             P("triangle", x + 20 * s, y - 26 * s, 10 * s, 24 * s, rot + 24)], tags=tags, pivot=piv)
    c.glow(name + "_eyes", eye, z + 0.05, [E(x - 13 * s, y - 4 * s, 10 * s, 6 * s, rot + 16), E(x + 13 * s, y - 4 * s, 10 * s, 6 * s, rot - 16)],
           tags=tags, color=eye_c, strength=0.8, opacity=0.45, pivot=piv)
    if open_mouth:
        c.flat(name + "_mouth", "mouth", z + 0.04, [E(x, y + 30 * s, 34 * s, 26 * s)], tags=tags, pivot=piv)
        c.flat(name + "_fangs", "tooth", z + 0.06, fangs(x - 14 * s, x + 14 * s, y + 20 * s, 4, 8 * s) +
               fangs(x - 10 * s, x + 10 * s, y + 42 * s, 3, 6 * s, down=False), tags=tags, pivot=piv, line={"width": 0.5, "heavy": 0.4})
    else:
        c.flat(name + "_mouth", "mouth", z + 0.04, [seg(x - 16 * s, y + 30 * s, x + 16 * s, y + 30 * s, 2.5)], tags=tags, pivot=piv)
        c.flat(name + "_nostrils", "mouth", z + 0.04, [E(x - 6 * s, y + 18 * s, 4 * s, 3 * s), E(x + 6 * s, y + 18 * s, 4 * s, 3 * s)],
               tags=tags, pivot=piv)


@creature("hydra", "B")
def hydra():
    W, H = 768, 640
    cx, gy = 384, 620
    c = Creature("hydra", (W, H), (cx, gy), seed=521,
                 note="Hydra, front view. Squat dark-teal reptile body on four stubby clawed legs, five long spiny necks "
                      "rising in a fan, each ending in a horned serpent head with glowing eyes (two roaring), pale belly "
                      "plates, heavy tail curling at the side.")
    c.shadow(cx, gy - 4, 480, 48)
    c.add("tail", "scale_teal", 1, tube([(cx + 100, 540), (cx + 260, 600), (cx + 330, 520)], 70, 14, n=14, cap=True), tags=("tail",))
    necks = [(-240, 250, 0.9), (-130, 160, 1.0), (0, 120, 1.1), (130, 160, 1.0), (240, 250, 0.9)]
    for i, (dx, hy, s) in enumerate(necks):
        ctrl = [(cx + dx * 0.25, 440), (cx + dx * 0.55, 380), (cx + dx * 1.05, hy + 120), (cx + dx, hy + 30)]
        z = 2 + (2 - abs(i - 2)) * 0.2
        c.add(f"neck_{i}", "scale_teal", z, tube(ctrl, 64 * s, 44 * s, n=14, cap=True), tags=("necks",))
        c.add(f"neck_{i}_belly", "belly", z + 0.01, tube(ctrl, 28 * s, 20 * s, n=14, cap=True), tags=("necks",), clip_to=f"neck_{i}", line=False)
        serpent_head(c, f"head_{i}", cx + dx, hy, s * 1.25, "scale_teal", ("heads",), z + 0.1, open_mouth=i in (1, 4),
                     rot=dx * -0.02)
    for s, k in (("l", -1), ("r", 1)):
        for j, (ox, oy) in enumerate(((130, 520), (60, 548))):
            c.add(f"leg_{s}{j}", "scale_teal", 3 + j * 0.1, [E(cx + k * ox, oy, 90, 110), E(cx + k * (ox + 14), oy + 44, 80, 30)], tags=("legs",))
            c.add(f"claw_{s}{j}", "claw", 3.05 + j * 0.1, [P("triangle", cx + k * (ox + 14) + d * 18, oy + 60, 9, 16, rot=180) for d in (-1, 0, 1)],
                  tags=("legs",))
    c.add("body", "scale_teal", 2.9, [E(cx, 490, 320, 210)], tags=("body",))
    c.add("belly", "belly", 3.0, [E(cx, 520, 200, 150)], tags=("body",), clip_to="body")
    std_frames(c, a_state=False)
    c.meta.update(name_ko="히드라", size="거대")
    return c


@creature("yeti", "B")
def yeti():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("yeti", (W, H), (cx, gy), seed=522,
                 note="Yeti, front view. Hulking ape of shaggy pale-grey fur, dark leathery face with small glowing blue "
                      "eyes, heavy brow and fangs, huge hands and flat feet, frost-matted fur tufts.")
    b = Biped(c, cx, gy, 430, build=1.45, leg=0.32, torso=0.34, head=0.19, shoulder=0.17, hip=0.11, arm_w=0.085,
              leg_w=0.11, arm_len=0.46, stance=1.2, hunch=0.07)
    c.shadow(cx, gy - 2, 300, 34)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("fur_white", foot_mat="snout", z=1, thigh=1.2, shin=1.0, foot_w=1.8, foot_h=0.45)
    c.add("torso", "fur_white", 3, [E(cx, ys + 60, 250, 160), E(cx, yh - 20, 190, 120)], tags=("torso",))
    c.add("tufts", "fur_white", 3.1, spikes_on([(cx - 120, ys + 40), (cx, ys - 20), (cx + 120, ys + 40)], 7, 26, 22, 0.0, 1.0, side=-1),
          tags=("torso",))
    c.add("chest", "fur_white", 3.2, [P("cloud", cx, ys + 64, 120, 60, flip="y")], tags=("torso",), opacity=0.8)
    b.arm_to("l", (b.sh["l"][0] - 40, ys + 160), bend=0.1)
    b.arm_to("r", (b.sh["r"][0] + 40, ys + 156), bend=0.1)
    b.arm("l", "fur_white", "snout", z=4, upper=1.3, fore=1.2, hand=1.5, fist=False, claws=0.7)
    b.arm("r", "fur_white", "snout", z=4, upper=1.3, fore=1.2, hand=1.5, fist=False, claws=0.7)
    c.add("hair", "fur_white", 6.5, [P("cloud", cx, hy0 - 34, 120, 60)], tags=("head",))
    c.add("head", "fur_white", 7, [E(cx, hy0, 100, 96)], tags=("head",))
    c.add("face", "snout", 7.2, [P("droplet", cx, hy0 + 10, 70, 80, flip="y")], tags=("head",))
    c.add("brow", "snout", 7.3, [E(cx, hy0 - 12, 70, 16)], tags=("head",))
    c.glow("eyes", "glow_cyan", 7.35, [E(cx - 16, hy0 - 2, 10, 7), E(cx + 16, hy0 - 2, 10, 7)], tags=("head", "eyes"), color="glow_cyan_c",
           strength=0.7, opacity=0.4)
    c.flat("nostrils", "mouth", 7.4, [E(cx - 6, hy0 + 16, 7, 5), E(cx + 6, hy0 + 16, 7, 5)], tags=("head",))
    c.flat("mouth", "mouth", 7.4, [E(cx, hy0 + 34, 40, 18)], tags=("head",))
    c.flat("fangs", "tooth", 7.45, [P("triangle", cx - 12, hy0 + 30, 7, 13, flip="y"), P("triangle", cx + 12, hy0 + 30, 7, 13, flip="y")],
           tags=("head",), line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="설인", size="큼")
    return c


@creature("giant", "B")
def giant():
    from .kit import held
    W, H = 512, 768
    cx, gy = 256, 748
    c = Creature("giant", (W, H), (cx, gy), seed=523,
                 note="Giant, front view (twice human height). Brutish hill giant with a shaggy beard and topknot, crude "
                      "hide tunic and rope belt, bone necklace, bare feet wrapped in rags, uprooted tree-trunk club resting "
                      "on the ground.")
    b = Biped(c, cx, gy, 700, build=1.25, leg=0.43, torso=0.31, head=0.14, shoulder=0.16, hip=0.095, arm_w=0.068,
              leg_w=0.085, arm_len=0.4, stance=1.15, hunch=0.03)
    c.shadow(cx, gy - 2, 340, 40)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("hide_pink", foot_mat="cloth_rag", foot="boot", z=1, thigh=1.1, shin=1.0)
    c.add("tunic", "fur_brown", 3, [P("bell", cx, ys + 150, 250, 340, crop=[1.6, 1.4, 14.4, 11.6]), E(cx, ys + 40, 250, 100)], tags=("torso",))
    c.add("tunic_edge", "fur_dark", 3.1, [P("mountains", cx, ys + 312, 240, 40, flip="y")], tags=("torso",), clip_to="tunic", opacity=0.8)
    c.add("belt", "leather", 3.3, [E(cx, yh - 10, 200, 20)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 30, ys + 250), bend=0.08)
    b.arm_to("r", (b.sh["r"][0] + 40, ys + 244), bend=0.08)
    b.arm("l", "hide_pink", z=4, upper=1.1, fore=1.0, hand=1.3)
    b.arm("r", "hide_pink", z=4, upper=1.1, fore=1.0, hand=1.3)
    c.add("club", "bark", 3.9, [seg(b.hand["r"][0] + 4, b.hand["r"][1] - 30, b.hand["r"][0] + 14, gy - 20, 44), E(b.hand["r"][0] + 14, gy - 24, 70, 40)],
          tags=("club",))
    c.add("club_roots", "bark", 3.85, tube([(b.hand["r"][0] + 14, gy - 30), (b.hand["r"][0] + 44, gy - 12), (b.hand["r"][0] + 56, gy - 30)], 14, 5, n=6, cap=True),
          tags=("club",))
    c.add("necklace", "bone", 5.5, [P("triangle", cx + d * 22, ys + 30 - abs(d) * 3, 10, 18, flip="y") for d in (-2, -1, 0, 1, 2)],
          tags=("torso",), line={"width": 0.5, "heavy": 0.4})
    c.add("head", "hide_pink", 7, [E(cx, hy0, 90, 96)], tags=("head",))
    c.add("beard", "hair", 7.2, [P("droplet", cx, hy0 + 48, 96, 110, flip="y"), E(cx, hy0 + 20, 96, 40)], tags=("head",))
    c.add("hair", "hair", 7.1, [E(cx, hy0 - 38, 92, 40), P("droplet", cx, hy0 - 66, 30, 40)], tags=("head",))
    c.add("brow", "hair", 7.3, [E(cx - 18, hy0 - 12, 30, 9, rot=12), E(cx + 18, hy0 - 12, 30, 9, rot=-12)], tags=("head",))
    dot_eyes(c, cx, hy0 - 2, 18, 9, 9, z=7.25, tags=("head",))
    c.add("nose", "hide_pink", 7.35, [E(cx, hy0 + 12, 22, 20)], tags=("head",))
    c.flat("mouth", "mouth", 7.4, smile(cx, hy0 + 32, 30, 8, frown=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거인", size="거대")
    return c


@creature("fairy", "B")
def fairy():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("fairy", (W, H), (cx, gy), seed=524,
                 note="Fairy, front view, hovering. Tiny big-headed sprite in a leaf dress with pointed ears, round dark "
                      "eyes, a mischievous grin, four translucent dragonfly wings and a soft glow; sparkles around it.")
    c.shadow(cx, gy - 2, 80, 12, opacity=0.25, blur=6)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"wing_up_{s}", "ghost", 1, [P("droplet", cx + k * 60, 150, 40, 110, rot=k * 60)], tags=("wings",), opacity=0.6,
              line={"width": 0.7, "heavy": 0.5}, emit=0.3)
        c.add(f"wing_lo_{s}", "ghost", 1.1, [P("droplet", cx + k * 48, 214, 30, 80, rot=k * 120)], tags=("wings",), opacity=0.55,
              line={"width": 0.7, "heavy": 0.5}, emit=0.3)
    c.add("aura", "glow_white", 0.5, [E(cx, 190, 120, 140)], tags=("aura",), kind="flat", opacity=0.18, blur=10, line=False, emit=0.5)
    c.add("legs", "pale", 1.5, [seg(cx - 8, 236, cx - 12, 276, 9), seg(cx + 8, 236, cx + 14, 270, 9)], tags=("body",))
    c.add("dress", "leaf", 2, [P("bell", cx, 222, 64, 60, crop=[1.6, 1.4, 14.4, 11.6]), P("leaf", cx - 20, 244, 22, 26, rot=160),
                               P("leaf", cx + 20, 244, 22, 26, rot=200)], tags=("body",))
    c.add("arms", "pale", 2.5, [seg(cx - 22, 204, cx - 44, 224, 8), seg(cx + 22, 204, cx + 40, 184, 8)], tags=("body",))
    c.add("head", "pale", 3, [E(cx, 170, 64, 60)], tags=("head",))
    c.add("ears", "pale", 2.9, [P("triangle", cx - 36, 166, 14, 24, rot=-70), P("triangle", cx + 36, 166, 14, 24, rot=70)], tags=("head",))
    c.add("hair", "fur_tawny", 3.2, [P("cloud", cx, 148, 72, 36), P("droplet", cx - 26, 170, 14, 30, flip="y", rot=10),
                                     P("droplet", cx + 26, 170, 14, 30, flip="y", rot=-10)], tags=("head",))
    dot_eyes(c, cx, 174, 13, 10, 13, z=3.3, tags=("head",))
    c.flat("mouth", "mouth", 3.3, smile(cx, 188, 14, 6), tags=("head",))
    c.glow("sparkles", "glow_white", 4, [P("star", cx - 70, 120, 14, 14), P("star", cx + 74, 250, 12, 12), P("star", cx + 60, 110, 10, 10),
                                         P("star", cx - 60, 270, 10, 10)], tags=("fx",), color="lamp_glow", strength=0.9, opacity=0.5)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="요정", size="작음")
    return c


@creature("beastman", "B")
def beastman():
    from .kit import held
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("beastman", (W, H), (cx, gy), seed=525,
                 note="Beastman (feline), front view. Tawny-furred cat-folk warrior with a dark mane, tufted ears, amber "
                      "slit eyes, whiskers, leather cuirass and belt, a curved cutlass, long striped tail.")
    b = Biped(c, cx, gy, 320, build=1.0, leg=0.45, torso=0.3, head=0.18, shoulder=0.15, hip=0.085, arm_w=0.062,
              leg_w=0.075, arm_len=0.37, stance=1.15)
    c.shadow(cx, gy - 2, 160, 20)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    c.add("tail", "fur_tawny", 0.8, tube([(cx + 20, yh + 10), (cx + 96, yh + 40), (cx + 110, yh - 40)], 18, 10, n=10, cap=True), tags=("tail",))
    c.flat("tail_bands", "fur_brown", 0.85, [E(cx + 60 + i * 16, yh + 34 - i * 18, 18, 8, rot=-40 + i * 16) for i in range(3)], tags=("tail",),
           clip_to="tail")
    b.legs("fur_tawny", foot="claw", z=1, thigh=1.0, shin=0.9)
    c.add("trousers", "cloth_rag", 1.2, [E(cx, yh + 10, 90, 40)], tags=("legs",))
    b.torso("fur_tawny", z=3, chest=0.95, shape="chest")
    c.add("cuirass", "leather", 3.2, [E(cx, ys + 34, 100, 66), P("droplet", cx, ys + 80, 80, 80, flip="y")], tags=("torso",))
    c.add("belt", "leather", 3.4, [E(cx, yh - 4, 90, 12)], tags=("torso",))
    c.add("buckle", "bronze", 3.45, [P("octagon", cx, yh - 4, 14, 14)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 12, ys + 104), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 14, ys + 100), bend=0.14)
    b.arm("l", "fur_tawny", z=4, upper=1.0, fore=0.9, hand=1.2, claws=0.7)
    b.arm("r", "fur_tawny", z=4, upper=1.0, fore=0.9, hand=1.2)
    c.add("cutlass", "armor", 3.9, [held("cutlass", b.hand["r"], 96, -70, grip=0.42)], tags=("torso",))
    c.add("mane", "fur_brown", 6.5, [P("cloud", cx, hy0 + 18, 96, 60, flip="y"), E(cx, hy0 - 6, 88, 70)], tags=("head",))
    c.add("ears", "fur_tawny", 6.6, [P("triangle", cx - 26, hy0 - 34, 22, 32, rot=-14), P("triangle", cx + 26, hy0 - 34, 22, 32, rot=14)],
          tags=("head",))
    c.add("head", "fur_tawny", 7, [E(cx, hy0, 60, 56)], tags=("head",))
    c.add("muzzle", "fur_white", 7.2, [P("cloud", cx, hy0 + 14, 40, 22, flip="y")], tags=("head",))
    c.add("nose", "hide_pink", 7.3, [P("triangle", cx, hy0 + 6, 10, 7, flip="y")], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.3, [E(cx - 12, hy0 - 6, 12, 8, rot=14), E(cx + 12, hy0 - 6, 12, 8, rot=-14)], tags=("head",),
           color="glow_yellow_c", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 7.35, [E(cx - 12, hy0 - 6, 3, 7), E(cx + 12, hy0 - 6, 3, 7)], tags=("head",))
    c.flat("whiskers", "eye", 7.4, [seg(cx - 10, hy0 + 14, cx - 34, hy0 + 10, 1.2), seg(cx - 10, hy0 + 16, cx - 34, hy0 + 20, 1.2),
                                    seg(cx + 10, hy0 + 14, cx + 34, hy0 + 10, 1.2), seg(cx + 10, hy0 + 16, cx + 34, hy0 + 20, 1.2)],
           tags=("head",), opacity=0.8)
    c.flat("mouth", "mouth", 7.4, smile(cx, hy0 + 20, 14, 5), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="수인", size="사람")
    return c


@creature("snake_man", "B")
def snake_man():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("snake_man", (W, H), (cx, gy), seed=526,
                 note="Snake-man (naga), front view. Serpent head with a wide spread hood and glowing yellow eyes on a "
                      "scaled humanoid torso with bronze arm rings, lower body a thick coiled snake tail; holds a "
                      "bronze-tipped trident.")
    c.shadow(cx, gy - 2, 250, 30)
    c.add("coil_back", "scale_olive", 1, [E(cx + 30, 330, 250, 70)], tags=("coil",))
    c.add("tail_end", "scale_olive", 0.9, tube([(cx + 140, 330), (cx + 170, 300), (cx + 150, 270)], 30, 8, n=8, cap=True), tags=("coil",))
    c.add("coil_front", "scale_olive", 1.5, [E(cx - 10, 344, 200, 50)], tags=("coil",))
    c.add("coil_belly", "belly", 1.6, [E(cx - 10, 356, 160, 22)], tags=("coil",), clip_to="coil_front", line=False)
    c.add("waist", "scale_olive", 2, tube([(cx, 324), (cx - 6, 270), (cx, 226)], 70, 60, n=8, cap=True), tags=("body",))
    c.add("torso", "scale_olive", 3, [E(cx, 190, 110, 90), E(cx, 226, 80, 60)], tags=("body",))
    c.add("belly", "belly", 3.1, [P("droplet", cx, 230, 44, 110, flip="y")], tags=("body",), clip_to="torso")
    c.add("hood", "scale_teal", 3.5, [E(cx - 42, 128, 76, 116, rot=-14), E(cx + 42, 128, 76, 116, rot=14), E(cx, 150, 60, 60)], tags=("head",))
    c.flat("hood_mark", "belly", 3.55, [E(cx - 50, 130, 22, 46, rot=-14), E(cx + 50, 130, 22, 46, rot=14)], tags=("head",), clip_to="hood", opacity=0.6)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "scale_olive", 4, [seg(cx + k * 50, 166, cx + k * 72, 218, 22), seg(cx + k * 72, 218, cx + k * 60, 262, 18)], tags=("arms",))
        c.add(f"ring_{s}", "bronze", 4.1, [E(cx + k * 66, 236, 22, 12, rot=k * 20)], tags=("arms",))
        c.add(f"hand_{s}", "scale_olive", 4.2, [E(cx + k * 58, 268, 22, 22)], tags=("arms",))
    c.add("trident", "wood", 3.9, [seg(cx + 58, 340, cx + 64, 90, 7)], tags=("weapon",))
    c.add("trident_head", "bronze", 3.95, [seg(cx + 64, 96, cx + 64, 60, 6), seg(cx + 52, 98, cx + 50, 70, 5), seg(cx + 76, 98, cx + 78, 70, 5),
                                           seg(cx + 50, 100, cx + 78, 100, 6), P("triangle", cx + 64, 54, 9, 14), P("triangle", cx + 50, 64, 7, 12),
                                           P("triangle", cx + 78, 64, 7, 12)], tags=("weapon",))
    c.add("head", "scale_olive", 5, [E(cx, 112, 60, 56), E(cx, 132, 44, 36)], tags=("head",))
    c.glow("eyes", "glow_yellow", 5.2, [E(cx - 14, 108, 13, 9, rot=18), E(cx + 14, 108, 13, 9, rot=-18)], tags=("head",), color="glow_yellow_c",
           strength=0.7, opacity=0.4)
    c.flat("pupils", "eye", 5.25, [E(cx - 14, 108, 3, 8), E(cx + 14, 108, 3, 8)], tags=("head",))
    c.flat("mouth", "mouth", 5.2, [seg(cx - 14, 140, cx + 14, 140, 2.5)], tags=("head",))
    c.add("tongue", "tongue", 5.3, [seg(cx, 140, cx, 156, 3), seg(cx, 154, cx - 5, 164, 2.5), seg(cx, 154, cx + 5, 164, 2.5)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="뱀 인간", size="사람")
    return c


@creature("man_eater_plant", "B")
def man_eater_plant():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("man_eater_plant", (W, H), (cx, gy), seed=527,
                 note="Man-eating plant, front view. Huge toothed trap head (dull wine petal lips, pale fangs, dark gullet "
                      "with a hanging tongue) on a thick thorny stem rising from a clump of broad leaves and grasping vines.")
    c.shadow(cx, gy - 2, 280, 30)
    for i, (x, r) in enumerate(((-110, -60), (-60, -30), (60, 30), (110, 60))):
        c.add(f"leaf_{i}", "leaf", 1 + i * 0.01, [P("leaf", cx + x, 316, 90, 70, rot=r, **({"flip": "x"} if x < 0 else {}))], tags=("leaves",))
    c.add("vines", "leaf_dark", 1.5, tube([(cx - 30, 330), (cx - 120, 300), (cx - 150, 240)], 16, 5, n=10, cap=True)
          + tube([(cx + 30, 330), (cx + 130, 310), (cx + 160, 250)], 16, 5, n=10, cap=True), tags=("vines",))
    c.add("stem", "leaf_dark", 2, tube([(cx, 350), (cx + 26, 280), (cx - 10, 220)], 44, 32, n=10, cap=True), tags=("stem",))
    c.add("thorns", "horn", 2.1, spikes_on([(cx, 350), (cx + 26, 280), (cx - 10, 220)], 5, 16, 10, 0.1, 0.9, side=-1)
          + spikes_on([(cx, 350), (cx + 26, 280), (cx - 10, 220)], 5, 16, 10, 0.1, 0.9, side=1), tags=("stem",))
    c.add("head_back", "petal", 3, [E(cx, 150, 190, 150)], tags=("head",))
    c.flat("gullet", "mouth", 3.1, [E(cx, 152, 150, 110)], tags=("head",))
    c.add("tongue", "tongue", 3.2, tube([(cx, 172), (cx + 10, 200), (cx - 4, 226)], 24, 12, n=8, cap=True), tags=("head",))
    c.add("fangs_up", "tooth", 3.3, fangs(cx - 70, cx + 70, 104, 9, 22), tags=("head",), line={"width": 0.6, "heavy": 0.5})
    c.add("fangs_lo", "tooth", 3.3, fangs(cx - 60, cx + 60, 204, 8, 20, down=False), tags=("head",), line={"width": 0.6, "heavy": 0.5})
    c.add("lip_up", "petal", 3.5, [P("circle", cx, 100, 200, 70, half="top"), E(cx, 100, 200, 20)], tags=("head",))
    c.add("lip_lo", "petal", 3.5, [P("circle", cx, 210, 180, 50, half="bottom"), E(cx, 210, 180, 16)], tags=("head",))
    c.add("spots", "spot", 3.6, [E(cx - 50, 80, 16, 10), E(cx + 40, 76, 20, 12), E(cx + 70, 92, 12, 8), E(cx - 20, 222, 14, 8)],
          tags=("head",), opacity=0.7)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="식인 식물", size="사람")
    return c


def spirit_eyes(c, cx, y, dx, mat, color, z, tags=("head",)):
    c.glow("eyes", mat, z, [E(cx - dx, y, 16, 20, rot=-8), E(cx + dx, y, 16, 20, rot=8)], tags=tags, color=color, strength=1.0, opacity=0.6)


@creature("water_spirit", "B")
def water_spirit():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("water_spirit", (W, H), (cx, gy), seed=528,
                 note="Water spirit, front view. Translucent deep-teal water body rising from a swirling pool: droplet head "
                      "with glowing pale eyes, wave-crest hair, flowing arms ending in splashes, bubbles inside.")
    c.shadow(cx, gy - 2, 180, 24, opacity=0.3)
    op = 0.86
    c.add("pool", "water", 1, [E(cx, 346, 210, 44), P("wave", cx - 60, 340, 70, 40), P("wave", cx + 60, 342, 70, 40, flip="x")], tags=("body",), opacity=op)
    c.add("body", "water", 2, [P("droplet", cx, 250, 110, 190, flip="y"), E(cx, 312, 90, 70)], tags=("body",), opacity=op)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "water", 2.5, tube([(cx + k * 40, 210), (cx + k * 96, 230), (cx + k * 104, 280)], 30, 12, n=10, cap=True)
              + [P("droplet", cx + k * 108, 296, 26, 34, flip="y")], tags=("arms",), opacity=op)
    c.add("head", "water", 3, [P("droplet", cx, 150, 90, 110)], tags=("head",), opacity=op)
    c.add("crest", "water", 3.2, [P("wave", cx, 106, 100, 60)], tags=("head",), opacity=op)
    spirit_eyes(c, cx, 160, 18, "ghost_glow", "ghost_glow_c", 3.4)
    c.flat("mouth", "mouth", 3.4, [E(cx, 186, 16, 8)], tags=("head",), opacity=0.6)
    c.add("bubbles", "ice", 3.5, [E(cx - 20, 250, 12, 12), E(cx + 14, 280, 9, 9), E(cx + 4, 226, 7, 7), E(cx - 8, 300, 8, 8)], tags=("body",),
          opacity=0.7, line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="물 정령", size="사람")
    return c


@creature("wind_spirit", "B")
def wind_spirit():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("wind_spirit", (W, H), (cx, gy), seed=529,
                 note="Wind spirit, front view. Pale grey-green whirlwind: a funnel of curling wind bands tapering to a "
                      "point on the ground, a hooded swirl head with glowing eyes, streaming ribbon arms, leaves caught in "
                      "the gusts.")
    c.shadow(cx, gy - 2, 120, 18, opacity=0.28, blur=6)
    op = 0.84
    bands = [(300, 50, 22), (262, 90, 26), (220, 130, 30), (178, 160, 32)]
    for i, (y, w, h) in enumerate(bands):
        c.add(f"band_{i}", "wind", 1 + i * 0.1, [E(cx + (i % 2) * 8 - 4, y, w * 1.2, h), E(cx + (i % 2) * 8 - 4, y - h * 0.3, w * 1.0, h * 0.6, op="sub")],
              tags=("body",), opacity=op)
    c.add("funnel", "wind", 0.9, [P("triangle", cx, 260, 150, 220, flip="y")], tags=("body",), opacity=0.5, line={"width": 0.7, "heavy": 0.5})
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "wind", 2, tube([(cx + k * 50, 170), (cx + k * 110, 160), (cx + k * 120, 210), (cx + k * 96, 230)], 22, 6, n=12, cap=True),
              tags=("arms",), opacity=op)
    c.add("head", "wind", 3, [P("spiral", cx, 116, 96, 90)], tags=("head",), opacity=0.95)
    c.add("hood", "wind", 2.9, [E(cx, 118, 100, 94)], tags=("head",), opacity=0.55, line=False)
    spirit_eyes(c, cx, 124, 16, "glow_white", "ghost_glow_c", 3.3)
    c.add("leaves", "leaf", 4, [P("leaf", cx - 90, 250, 20, 18, rot=40), P("leaf", cx + 84, 200, 18, 16, rot=-60), P("leaf", cx + 40, 300, 16, 14, rot=120),
                                P("leaf", cx - 50, 180, 14, 12, rot=10)], tags=("fx",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="바람 정령", size="사람")
    return c


@creature("earth_spirit", "B")
def earth_spirit():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("earth_spirit", (W, H), (cx, gy), seed=530,
                 note="Earth spirit, front view. Squat round creature of packed soil and rubble with violet crystal growths "
                      "on its back and shoulders, two glowing amber gem eyes, stubby boulder arms, moss and roots dangling.")
    c.shadow(cx, gy - 2, 250, 30)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"foot_{s}", "rubble", 1, [E(cx + k * 50, 346, 70, 40)], tags=("legs",))
    c.add("crystals_back", "crystal", 1.5, [P("prism", cx + d * 40, 160 - (2 - abs(d)) * 20, 40, 90, rot=d * 16) for d in (-2, -1, 0, 1, 2)],
          tags=("crystals",))
    c.add("body", "rubble", 2, [E(cx, 260, 220, 190)], tags=("body",))
    c.add("soil", "leather", 2.1, [E(cx, 310, 200, 90)], tags=("body",), clip_to="body", opacity=0.5, line=False)
    c.add("moss", "moss", 2.2, [E(cx - 60, 190, 80, 34), E(cx + 70, 230, 50, 26)], tags=("body",), clip_to="body")
    c.add("roots", "bark", 2.3, tube([(cx - 40, 340), (cx - 50, 360), (cx - 70, 366)], 8, 3, n=5, cap=True)
          + tube([(cx + 30, 344), (cx + 36, 362), (cx + 56, 366)], 8, 3, n=5, cap=True), tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "rubble", 3, [E(cx + k * 116, 250, 70, 80), E(cx + k * 126, 304, 64, 56)], tags=("arms",))
        c.add(f"shoulder_crystal_{s}", "crystal", 3.1, [P("prism", cx + k * 120, 204, 30, 54, rot=k * 30)], tags=("crystals",))
    c.flat("eye_holes", "void", 3.5, [E(cx - 36, 240, 36, 30), E(cx + 36, 240, 36, 30)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.6, [P("diamond", cx - 36, 240, 20, 22), P("diamond", cx + 36, 240, 20, 22)], tags=("head",),
           color="ember_glow", strength=1.0, opacity=0.6)
    c.flat("mouth", "void", 3.5, smile(cx, 286, 50, 14, frown=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="땅 정령", size="사람")
    return c


# ================================================================ C (idle only)
@creature("cyclops", "C")
def cyclops():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("cyclops", (W, H), (cx, gy), seed=531,
                 note="Cyclops, front view. Hulking tan-skinned one-eyed giant with a single huge glaring eye under a "
                      "heavy brow, a stubby horn, wild hair, crooked tusks, hide loincloth and a boulder hefted in one hand.")
    b = Biped(c, cx, gy, 440, build=1.3, leg=0.38, torso=0.32, head=0.19, shoulder=0.17, hip=0.1, arm_w=0.078,
              leg_w=0.09, arm_len=0.4, stance=1.25, hunch=0.05)
    c.shadow(cx, gy - 2, 290, 32)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("snout", foot="claw", z=1, thigh=1.1, shin=1.0, foot_w=1.6)
    c.add("torso", "snout", 3, [E(cx, ys + 50, 230, 120), E(cx, yh - 40, 170, 120)], tags=("torso",))
    c.add("loin", "fur_brown", 3.3, [E(cx, yh + 8, 170, 44), P("bookmark", cx, yh + 50, 80, 70)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 30, ys + 170), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 40, ys + 30), elbow=(b.sh["r"][0] + 50, ys + 90))
    b.arm("l", "snout", z=4, upper=1.1, fore=1.0, hand=1.3)
    b.arm("r", "snout", z=4, upper=1.1, fore=1.0, hand=1.3)
    hx, hy = b.hand["r"]
    c.add("boulder_fill", "stone_cap", 3.85, [E(hx + 10, hy - 50, 100, 80)], tags=("rock",), line=False)
    c.add("boulder", "stone", 3.9, [P("rocks", hx + 10, hy - 54, 120, 100)], tags=("rock",))
    c.add("hair", "hair", 6.4, [P("cloud", cx, hy0 - 36, 120, 60)], tags=("head",))
    c.add("head", "snout", 7, [E(cx, hy0, 96, 90), E(cx, hy0 + 24, 100, 54)], tags=("head",))
    c.add("horn", "horn", 6.9, [P("cone", cx, hy0 - 56, 20, 32)], tags=("head",))
    c.flat("eye_white", "eye_white", 7.2, [E(cx, hy0 - 6, 50, 40)], tags=("head",))
    c.add("iris", "iris", 7.3, [E(cx, hy0 - 4, 24, 24)], tags=("head",))
    c.flat("pupil", "eye", 7.35, [E(cx, hy0 - 4, 10, 12)], tags=("head",))
    c.add("brow", "snout", 7.4, [E(cx, hy0 - 26, 70, 14)], tags=("head",))
    c.add("nose", "snout", 7.45, [E(cx, hy0 + 18, 22, 16)], tags=("head",))
    c.flat("mouth", "mouth", 7.5, smile(cx, hy0 + 36, 50, 12, frown=True), tags=("head",))
    c.add("tusks", "tooth", 7.55, [P("triangle", cx - 16, hy0 + 30, 8, 14, rot=-10), P("triangle", cx + 18, hy0 + 32, 7, 11, rot=14)],
          tags=("head",), line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="외눈 거인", size="큼")
    return c


@creature("kobold", "C")
def kobold():
    from .kit import held
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("kobold", (W, H), (cx, gy), seed=532,
                 note="Kobold, front view. Small scaly rust-red reptilian miner with a doglike snout, stubby horns, "
                      "yellow eyes, a leather miner's cap with a lit candle stub, ragged vest, a pickaxe over one shoulder "
                      "and a thin tail.")
    b = Biped(c, cx, gy, 250, build=0.95, leg=0.36, torso=0.28, head=0.26, shoulder=0.15, hip=0.09, arm_w=0.07,
              leg_w=0.08, arm_len=0.36, stance=1.2, hunch=0.03)
    c.shadow(cx, gy - 2, 140, 20)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    c.add("tail", "chitin_rust", 0.8, tube([(cx + 10, yh + 10), (cx + 70, yh + 50), (cx + 90, yh + 20)], 16, 5, n=8, cap=True), tags=("tail",))
    b.legs("chitin_rust", foot="claw", z=1, thigh=1.0, shin=0.9)
    b.torso("chitin_rust", z=3, chest=0.9, shape="slim")
    c.add("vest", "leather", 3.2, [P("droplet", cx - 22, ys + 40, 30, 70, flip="y"), P("droplet", cx + 22, ys + 40, 30, 70, flip="y")], tags=("torso",))
    c.add("belt", "leather", 3.4, [E(cx, yh - 4, 70, 10)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 8, ys + 80), bend=0.12)
    b.arm_to("r", (b.sh["r"][0] + 10, ys + 40), elbow=(b.sh["r"][0] + 24, ys + 60))
    b.arm("l", "chitin_rust", z=4, upper=1.0, fore=0.9, hand=1.2, claws=0.6)
    b.arm("r", "chitin_rust", z=4, upper=1.0, fore=0.9, hand=1.2)
    c.add("pickaxe", "iron", 3.9, [held("pickaxe", b.hand["r"], 100, -120, grip=0.46)], tags=("weapon",))
    c.add("horns", "horn", 6.8, [P("cone", cx - 20, hy0 - 34, 12, 20, rot=-20), P("cone", cx + 20, hy0 - 34, 12, 20, rot=20)], tags=("head",))
    c.add("head", "chitin_rust", 7, [E(cx, hy0, 66, 58)], tags=("head",))
    c.add("snout", "chitin_rust", 7.2, [E(cx, hy0 + 20, 40, 30)], tags=("head",))
    c.flat("nostrils", "mouth", 7.3, [E(cx - 6, hy0 + 14, 4, 3), E(cx + 6, hy0 + 14, 4, 3)], tags=("head",))
    c.flat("mouth", "mouth", 7.3, [seg(cx - 12, hy0 + 28, cx + 12, hy0 + 28, 2.5)], tags=("head",))
    c.glow("eyes", "glow_yellow", 7.3, [E(cx - 14, hy0 - 4, 12, 10, rot=10), E(cx + 14, hy0 - 4, 12, 10, rot=-10)], tags=("head",),
           color="glow_yellow_c", strength=0.5, opacity=0.3)
    c.flat("pupils", "eye", 7.35, [E(cx - 14, hy0 - 4, 3, 8), E(cx + 14, hy0 - 4, 3, 8)], tags=("head",))
    c.add("cap", "leather", 7.5, [P("circle", cx, hy0 - 22, 60, 30, half="top"), E(cx, hy0 - 22, 66, 10)], tags=("head",))
    c.add("candle", "paper", 7.6, [P("square", cx, hy0 - 44, 10, 18)], tags=("head",))
    c.glow("flame", "flame", 7.7, [P("fire", cx, hy0 - 60, 14, 18)], tags=("head",), color="flame_glow", strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="코볼트", size="작음")
    return c


@creature("cockatrice", "C")
def cockatrice():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("cockatrice", (W, H), (cx, gy), seed=533,
                 note="Cockatrice, front view. Rooster-headed beast with a wine comb and wattles, hooked beak and glaring "
                      "eyes, dusty green-brown feathered breast, leathery bat wings raised, scaly chicken legs, and a long "
                      "serpent tail coiling on the ground.")
    c.shadow(cx, gy - 2, 260, 28)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 26, 190), 150, 90, "membrane_green", "horn", 1, ("wings",))
    c.add("tail", "scale_green", 1.3, tube([(cx + 20, 290), (cx + 120, 350), (cx + 170, 300), (cx + 140, 250)], 30, 8, n=14, cap=True), tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "gold", 1.5, [seg(cx + k * 22, 280, cx + k * 28, 340, 12)] + [seg(cx + k * 28, 340, cx + k * 28 + d * 14, 356, 6, ext=0.1)
                                                                                    for d in (-1, 0, 1)], tags=("legs",))
    c.add("body", "feather_brown", 2, [E(cx, 250, 130, 120)], tags=("body",))
    c.add("breast", "scale_green", 2.1, [P("droplet", cx, 250, 70, 100, flip="y")], tags=("body",), clip_to="body", opacity=0.8)
    c.add("neck", "feather_brown", 2.5, [seg(cx, 230, cx, 170, 50)], tags=("head",))
    c.add("head", "feather_brown", 3, [E(cx, 152, 64, 58)], tags=("head",))
    c.add("comb", "cloth_wine", 2.9, [P("cloud", cx, 118, 50, 30), P("droplet", cx - 10, 108, 16, 24, rot=-20), P("droplet", cx + 10, 106, 16, 26, rot=20)],
          tags=("head",))
    c.add("wattles", "cloth_wine", 3.3, [P("droplet", cx - 6, 196, 14, 26, flip="y"), P("droplet", cx + 6, 196, 14, 26, flip="y")], tags=("head",))
    c.add("beak", "gold", 3.2, [P("droplet", cx, 178, 26, 30, flip="y")], tags=("head",))
    c.glow("eyes", "glow_red", 3.25, [E(cx - 16, 148, 12, 10, rot=14), E(cx + 16, 148, 12, 10, rot=-14)], tags=("head",), color="glow_red_c",
           strength=0.8, opacity=0.4)
    c.flat("pupils", "eye", 3.3, [E(cx - 16, 148, 4, 7), E(cx + 16, 148, 4, 7)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="코카트리스", size="사람")
    return c


@creature("unicorn", "C")
def unicorn():
    W, H = 512, 512
    gy = 494
    c = Creature("unicorn", (W, H), (260, gy), seed=534,
                 note="Unicorn, 3/4 front view facing the lower left. Pale grey-white horse with a long spiral bone horn, "
                      "flowing violet-grey mane and tail, feathered fetlocks over dark hooves, calm glowing eyes.")
    c.shadow(270, gy - 4, 360, 40)
    legs = [((356, 330), (368, 400), (362, 470), 30, 1), ((200, 330), (206, 400), (204, 470), 28, 1),
            ((354, 336), (378, 404), (370, 476), 38, 3), ((168, 336), (160, 404), (158, 476), 36, 3.1)]
    from .kit import seg as _seg
    for i, (hip, knee, foot, w, z) in enumerate(legs):
        c.add(f"leg_{i}", "fur_white" if z >= 2 else "feather_pale", z, [_seg(hip[0], hip[1], knee[0], knee[1], w), _seg(knee[0], knee[1], foot[0], foot[1], w * 0.7)],
              tags=("legs",))
        c.add(f"fetlock_{i}", "fur_white", z + 0.03, [P("cloud", foot[0], foot[1] - 4, w * 1.3, w * 0.8, flip="y")], tags=("legs",))
        c.add(f"hoof_{i}", "horn", z + 0.05, [P("cylinder", foot[0], foot[1] + 10, w * 0.9, w * 0.5)], tags=("legs",))
    c.add("tail", "ghost", 1.4, tube([(392, 262), (440, 300), (436, 400)], 40, 14, n=10, cap=True), tags=("tail",))
    c.add("body", "fur_white", 2, [E(290, 290, 230, 120, -6), E(196, 300, 110, 120)], tags=("body",))
    c.add("neck", "fur_white", 3.5, tube([(190, 280), (170, 220), (156, 170)], 90, 66, n=8, cap=True), tags=("head",))
    c.add("mane", "ghost", 3.6, tube([(214, 262), (196, 200), (180, 146)], 34, 22, n=8, cap=True) + [P("droplet", 208, 180, 26, 60, rot=160)],
          tags=("head",))
    c.add("head", "fur_white", 4, [E(138, 160, 76, 66), E(100, 196, 56, 58), E(84, 222, 44, 34)], tags=("head",))
    c.add("ears", "fur_white", 3.9, [P("triangle", 158, 112, 18, 34, rot=14), P("triangle", 140, 114, 16, 30, rot=-6)], tags=("head",))
    c.add("horn", "bone", 4.2, [P("cone", 128, 90, 22, 80, rot=-12)], tags=("head",))
    c.flat("horn_spiral", "bone_old", 4.25, [seg(118 + i * 3, 110 - i * 14, 136 + i * 1, 104 - i * 14, 2.5) for i in range(4)], tags=("head",),
           clip_to="horn")
    c.glow("eyes", "glow_cyan", 4.3, [E(118, 164, 11, 8, rot=20), E(146, 158, 9, 7, rot=10)], tags=("head",), color="ghost_glow_c", strength=0.6, opacity=0.3)
    c.flat("pupils", "eye", 4.35, [E(118, 164, 4, 5), E(146, 158, 3, 4)], tags=("head",))
    c.flat("nostril", "mouth", 4.3, [E(74, 224, 8, 6, rot=-30)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="유니콘", size="큼")
    return c


@creature("giant_snake", "C")
def giant_snake():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("giant_snake", (W, H), (cx, gy), seed=535,
                 note="Giant snake, front view. Huge dark crimson-banded serpent in thick coils, head reared high with jaws "
                      "wide open showing long fangs, yellow slit eyes, pale belly scales, a heavy tail tip curling out.")
    c.shadow(cx, gy - 2, 360, 40)
    c.add("coil_3", "scale_red", 1, [E(cx, 450, 340, 90)], tags=("coils",))
    c.add("coil_2", "scale_red", 1.2, [E(cx + 10, 410, 280, 80)], tags=("coils",))
    c.add("coil_1", "scale_red", 1.4, [E(cx - 6, 374, 220, 70)], tags=("coils",))
    c.flat("bands", "robe_black", 1.5, [seg(cx - 150 + i * 42, 420, cx - 140 + i * 42, 480, 10) for i in range(8)], tags=("coils",), clip_to="coil_3", opacity=0.45)
    c.add("tail", "scale_red", 0.8, tube([(cx + 160, 460), (cx + 220, 440), (cx + 226, 400)], 30, 6, n=8, cap=True), tags=("coils",))
    neck = [(cx + 10, 370), (cx + 70, 300), (cx - 30, 240), (cx, 170)]
    c.add("neck", "scale_red", 2, tube(neck, 76, 60, n=14, cap=True), tags=("head",))
    c.add("neck_belly", "belly", 2.1, tube(neck, 36, 30, n=14, cap=True), tags=("head",), clip_to="neck", line=False)
    c.add("head", "scale_red", 3, [E(cx, 136, 112, 80)], tags=("head",))
    c.flat("mouth", "mouth", 3.1, [E(cx, 170, 90, 70)], tags=("head",))
    c.add("jaw", "scale_red", 3.05, [E(cx, 206, 80, 30)], tags=("head",))
    c.flat("fangs", "tooth", 3.2, [P("triangle", cx - 26, 152, 9, 30, flip="y"), P("triangle", cx + 26, 152, 9, 30, flip="y")], tags=("head",),
           line={"width": 0.5, "heavy": 0.4})
    c.add("tongue", "tongue", 3.25, [seg(cx, 190, cx, 222, 6), seg(cx, 220, cx - 9, 236, 4), seg(cx, 220, cx + 9, 236, 4)], tags=("head",))
    c.glow("eyes", "glow_yellow", 3.3, [E(cx - 30, 120, 20, 14, rot=16), E(cx + 30, 120, 20, 14, rot=-16)], tags=("head",), color="glow_yellow_c",
           strength=0.7, opacity=0.4)
    c.flat("pupils", "eye", 3.35, [E(cx - 30, 120, 4, 13), E(cx + 30, 120, 4, 13)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="거대 뱀", size="큼")
    return c


@creature("light_spirit", "C")
def light_spirit():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("light_spirit", (W, H), (cx, gy), seed=536,
                 note="Light spirit, front view, floating. A small radiant being: warm white-gold orb body with a calm "
                      "face, a halo ring, four soft light-petal wings, a tapering wisp tail; fully emissive.")
    c.shadow(cx, gy - 2, 80, 12, opacity=0.22, blur=7)
    for d in range(4):
        rot = 45 + d * 90
        c.add(f"petal_{d}", "fire_core", 1, [P("droplet", cx + 60 * math.sin(math.radians(rot)), 180 - 60 * math.cos(math.radians(rot)), 40, 80, rot=rot)],
              tags=("wings",), emit=0.8, opacity=0.7, line={"width": 0.6, "heavy": 0.5})
    c.add("tail", "fire_core", 1.5, tube([(cx, 220), (cx + 10, 260), (cx - 8, 300)], 40, 6, n=8, cap=True), tags=("body",), emit=0.9, opacity=0.8, line=False)
    c.add("orb", "glow_white", 2, [E(cx, 180, 100, 100)], tags=("body",), kind="flat", emit=1.0,
          glow={"radius": 8, "opacity": 0.6, "color": "lamp_glow"}, line={"width": 0.8, "heavy": 0.6})
    c.add("core", "fire_core", 2.1, [E(cx, 186, 70, 66)], tags=("body",), emit=1.0, line=False, opacity=0.8)
    c.add("halo", "gold", 3, [E(cx, 118, 70, 18), E(cx, 116, 54, 10, op="sub")], tags=("body",), emit=0.9)
    c.flat("eyes", "bronze", 3.1, [smile(cx - 16, 180, 14, 6)[0], smile(cx - 16, 180, 14, 6)[1]], tags=("body",))
    c.flat("eyes_r", "bronze", 3.1, smile(cx + 16, 180, 14, 6), tags=("body",))
    c.flat("mouth", "bronze", 3.1, smile(cx, 200, 16, 6), tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="빛 정령", size="작음")
    return c


@creature("ice_spirit", "C")
def ice_spirit():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("ice_spirit", (W, H), (cx, gy), seed=537,
                 note="Ice spirit, front view, hovering. Figure of cold blue-grey ice shards: faceted crystal torso, a crown "
                      "of icicle spikes around a smooth face with glowing pale eyes, shard arms, a trail of frozen mist and "
                      "a snowflake emblem on the chest.")
    c.shadow(cx, gy - 2, 110, 16, opacity=0.25, blur=7)
    c.add("mist", "ghost", 0.5, [P("cloud", cx, 330, 160, 50)], tags=("body",), opacity=0.5, line=False)
    c.add("lower", "ice", 1, [P("triangle", cx, 290, 100, 120, flip="y"), P("triangle", cx - 26, 300, 40, 70, flip="y", rot=10),
                              P("triangle", cx + 26, 300, 40, 70, flip="y", rot=-10)], tags=("body",))
    c.add("torso", "ice", 2, [P("diamond", cx, 214, 110, 140)], tags=("body",))
    c.glow("emblem", "glow_cyan", 2.1, [P("snowflake", cx, 214, 40, 40)], tags=("body",), color="ghost_glow_c", strength=0.9, opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "ice", 2.5, [P("triangle", cx + k * 70, 220, 30, 100, rot=k * 150), P("prism", cx + k * 60, 180, 30, 50, rot=k * 40)], tags=("arms",))
    c.add("head", "ice", 3, [E(cx, 132, 60, 64)], tags=("head",))
    c.add("crown", "ice", 2.9, [P("triangle", cx + d * 16, 96 - (2 - abs(d)) * 10, 12, 34 + (2 - abs(d)) * 8, rot=d * 16) for d in (-2, -1, 0, 1, 2)],
          tags=("head",))
    c.glow("eyes", "glow_cyan", 3.2, [E(cx - 12, 134, 10, 6), E(cx + 12, 134, 10, 6)], tags=("head",), color="ghost_glow_c", strength=1.0, opacity=0.6)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="얼음 정령", size="사람")
    return c


@creature("mandrake", "C")
def mandrake():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("mandrake", (W, H), (cx, gy), seed=538,
                 note="Mandrake, front view. Pale knobbly root creature with a tuft of dark leaves on its head, a gaping "
                      "screaming mouth and hollow eyes, forked root legs and twiggy root arms thrown up, soil clinging.")
    c.shadow(cx, gy - 2, 130, 18)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "mushroom_stem", 1, tube([(cx + k * 14, 290), (cx + k * 30, 330), (cx + k * 26, 360)], 26, 8, n=8, cap=True), tags=("legs",))
        c.add(f"arm_{s}", "mushroom_stem", 1.5, tube([(cx + k * 30, 230), (cx + k * 70, 200), (cx + k * 84, 150)], 16, 5, n=8, cap=True)
              + tube([(cx + k * 76, 180), (cx + k * 100, 170)], 7, 3, n=4, cap=True), tags=("arms",))
    c.add("body", "mushroom_stem", 2, [P("droplet", cx, 250, 90, 120, flip="y"), E(cx, 222, 90, 90)], tags=("body",))
    c.add("soil", "leather", 2.1, [E(cx, 300, 60, 30), E(cx - 30, 240, 20, 14)], tags=("body",), clip_to="body", opacity=0.6, line=False)
    c.add("leaves", "leaf_dark", 1.8, [P("leaf", cx + d * 20, 150 - (2 - abs(d)) * 12, 30, 56, rot=d * 26) for d in (-2, -1, 0, 1, 2)], tags=("head",))
    c.flat("eyes", "void", 2.3, [E(cx - 18, 206, 16, 20, rot=10), E(cx + 18, 206, 16, 20, rot=-10)], tags=("body",))
    c.flat("mouth", "void", 2.3, [E(cx, 244, 34, 44)], tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="만드라고라", size="작음")
    return c


@creature("vine_monster", "C")
def vine_monster():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("vine_monster", (W, H), (cx, gy), seed=539,
                 note="Vine monster, front view. A shambling tangle of thorny dark vines knotted into a hunched body, "
                      "a knot of bark for a face with two glowing green eyes, lashing vine arms, leaves and a single wine "
                      "blossom, roots spreading on the ground.")
    c.shadow(cx, gy - 2, 280, 30)
    for i, (x0, x1) in enumerate(((-40, -130), (40, 140), (-10, -60), (10, 70))):
        c.add(f"root_{i}", "bark", 1, tube([(cx + x0, 330), ((cx + x0 + cx + x1) / 2, 356), (cx + x1, 362)], 16, 5, n=6, cap=True), tags=("roots",))
    strands = [[(cx - 60, 330), (cx - 90, 250), (cx - 30, 180), (cx - 50, 120)], [(cx + 60, 330), (cx + 90, 250), (cx + 30, 180), (cx + 50, 120)],
               [(cx - 20, 340), (cx + 40, 260), (cx - 40, 200), (cx + 10, 130)], [(cx + 20, 340), (cx - 40, 260), (cx + 40, 200), (cx - 10, 130)],
               [(cx, 340), (cx + 70, 290), (cx - 70, 230), (cx, 160)]]
    for i, st in enumerate(strands):
        c.add(f"strand_{i}", "leaf_dark", 2 + i * 0.05, tube(st, 34, 20, n=12, cap=True), tags=("body",))
    c.add("thorns", "horn", 2.4, spikes_on(strands[0], 5, 14, 9, 0.1, 0.9, side=-1) + spikes_on(strands[1], 5, 14, 9, 0.1, 0.9, side=1), tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "leaf_dark", 2.6, tube([(cx + k * 40, 200), (cx + k * 120, 190), (cx + k * 150, 250), (cx + k * 130, 300)], 22, 6, n=12, cap=True),
              tags=("arms",))
    c.add("leaves", "leaf", 2.7, [P("leaf", cx - 90, 180, 34, 30, rot=-40), P("leaf", cx + 94, 220, 30, 28, rot=50), P("leaf", cx + 30, 110, 30, 26, rot=10)],
          tags=("body",))
    c.add("face", "bark", 3, [E(cx, 170, 70, 60)], tags=("head",))
    c.glow("eyes", "glow_green", 3.1, [E(cx - 14, 166, 12, 9), E(cx + 14, 166, 12, 9)], tags=("head",), color="glow_green_c", strength=1.0, opacity=0.6)
    c.flat("mouth", "void", 3.1, [P("mountains", cx, 188, 36, 12, flip="y")], tags=("head",))
    c.add("blossom", "petal", 3.2, [P("flower", cx + 44, 136, 34, 34)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="덩굴 괴물", size="사람")
    return c
