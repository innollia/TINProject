"""g05-fantasy-v01: medieval-fantasy creatures (front-view battlers).

Each function returns a kit.Creature.  Coordinates are final px.  A items get
idle / attack / hit, B and C items idle only.
"""

from __future__ import annotations

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
