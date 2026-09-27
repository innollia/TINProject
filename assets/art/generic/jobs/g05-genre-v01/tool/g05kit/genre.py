"""g05-genre-v01: creatures of the non-fantasy genres — horror/occult, SF/space, cyberpunk,
steampunk, post-apocalypse, pirates/sea, western (front-view battlers)."""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, along, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile,
                  std_frames, sym, tube, x_eyes)
from .parts import arch_leg, bat_wing, bones_limb, claw_hand, pincer, spikes_on, wing_at


def suckers_on(ctrl, n, w0, w1, t0=0.15, t1=0.9, side=1):
    """Small round suckers along one side of a tentacle Bezier."""
    def mk(x, y, ang, i, t):
        w = (w0 + (w1 - w0) * t) * 0.34
        a = math.radians(ang + 90 * side)
        return E(x + math.cos(a) * w * 1.1, y + math.sin(a) * w * 1.1, w, w * 0.8)
    return along(ctrl, n, mk, t0, t1)


# ---------------------------------------------------------------- A: security robot
@creature("robot", "A")
def robot():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("robot", (W, H), (cx, gy), seed=1001,
                 note="Security robot, front view. Boxy gunmetal bipedal machine with scuffed yellow hazard stripes, a "
                      "dome head with a cyan visor bar and a red-tipped antenna, chest light panel, piston legs, a blaster "
                      "arm and a clamp hand. attack = blaster arm raised and aimed, visor turned red; hit = head knocked "
                      "aside, visor dark, frame tilted.")
    c.shadow(cx, gy - 2, 170, 22)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "metal_robot", 1, [seg(cx + k * 26, 250, cx + k * 32, 306, 22), seg(cx + k * 32, 306, cx + k * 30, 350, 18)],
              tags=("legs",))
        c.flat(f"knee_{s}", "armor_dark", 1.1, [E(cx + k * 32, 306, 22, 20)], tags=("legs",))
        c.add(f"foot_{s}", "armor_dark", 1.2, [P("square", cx + k * 34, 356, 46, 18)], tags=("legs",))
    c.add("hips", "armor_dark", 1.8, [P("square", cx, 252, 80, 26)], tags=("torso",))
    c.add("torso", "metal_robot", 2, [P("square", cx, 196, 124, 108)], tags=("torso",))
    c.flat("stripes", "paint_yellow", 2.1, [seg(cx - 70 + i * 26, 250, cx - 40 + i * 26, 214, 9) for i in range(6)], tags=("torso",),
           clip_to="torso", opacity=0.9)
    c.flat("panel", "void", 2.2, [P("square", cx, 184, 60, 38)], tags=("torso",))
    c.glow("lights", "glow_cyan", 2.3, [P("square", cx - 18, 178, 10, 8), P("square", cx, 178, 10, 8), P("square", cx + 18, 178, 10, 8),
                                        P("square", cx - 9, 192, 26, 5)], tags=("torso", "eyes"), color="glow_cyan_c", strength=0.8, opacity=0.4)
    c.glow("lights_red", "glow_red", 2.3, [P("square", cx - 18, 178, 10, 8), P("square", cx, 178, 10, 8), P("square", cx + 18, 178, 10, 8)],
           tags=("torso", "red"), color="glow_red_c", strength=0.8, opacity=0.4, hidden=True)
    arms = {}
    for s, k in (("l", -1), ("r", 1)):
        sh = (cx + k * 70, 160)
        arms[s] = list(sh)
        c.add(f"shoulder_{s}", "armor_dark", 3.5, [E(sh[0], sh[1], 38, 38)], tags=("shoulders",))
        c.add(f"arm_{s}", "metal_robot", 3, [seg(sh[0], sh[1], cx + k * 84, 214, 18), seg(cx + k * 84, 214, cx + k * 86, 256, 16)],
              tags=(f"arm_{s}",), pivot=list(sh))
    c.add("blaster", "armor_dark", 3.2, [P("cylinder", cx + 88, 270, 30, 44)], tags=("arm_r",), pivot=arms["r"])
    c.flat("bore", "void", 3.3, [E(cx + 88, 290, 14, 8)], tags=("arm_r",), pivot=arms["r"])
    c.add("clamp", "armor_dark", 3.2, [P("moon", cx - 92, 268, 26, 26, rot=100), P("moon", cx - 80, 268, 26, 26, rot=-10, flip="x")],
          tags=("arm_l",), pivot=arms["l"])
    # attack: blaster arm raised straight at the viewer (foreshortened muzzle)
    c.add("arm_r_atk", "metal_robot", 3, [seg(cx + 70, 160, cx + 92, 150, 20)], tags=("atk",), hidden=True)
    c.add("blaster_atk", "armor_dark", 3.6, [E(cx + 98, 150, 44, 44)], tags=("atk",), hidden=True)
    c.flat("bore_atk", "void", 3.7, [E(cx + 98, 150, 20, 20)], tags=("atk",), hidden=True)
    c.add("head", "metal_robot", 5, [P("circle", cx, 118, 84, 70, half="top"), P("square", cx, 124, 84, 24)], tags=("head",))
    c.add("antenna", "armor_dark", 4.9, [seg(cx + 22, 96, cx + 30, 62, 4)], tags=("head",))
    c.glow("antenna_tip", "glow_red", 5.1, [E(cx + 30, 60, 9, 9)], tags=("head",), color="glow_red_c", strength=0.9, opacity=0.5)
    c.flat("visor", "void", 5.2, [P("square", cx, 112, 66, 16)], tags=("head",))
    c.glow("eyes_v", "glow_cyan", 5.3, [P("square", cx, 112, 56, 6)], tags=("head", "eyes"), color="glow_cyan_c", strength=1.0, opacity=0.6)
    c.glow("eyes_red", "glow_red", 5.3, [P("square", cx - 16, 112, 18, 7), P("square", cx + 16, 112, 18, 7)], tags=("head", "red"),
           color="glow_red_c", strength=1.0, opacity=0.6, hidden=True)
    c.add("jaw", "armor_dark", 5.4, [P("square", cx, 134, 50, 10)], tags=("head",))
    sl, sr = arms["l"], arms["r"]
    std_frames(
        c,
        attack_move={"arm_l": {"rot": 14, "pivot": sl}, "all": c.whole(s=1.03, dy=4)},
        attack_show=("atk", "red"), attack_hide=("arm_r", "eyes"),
        hit_move={"head": {"rot": 18, "dx": 8, "pivot": [cx, 144]}, "arm_l": {"rot": 24, "pivot": sl}, "arm_r": {"rot": -20, "pivot": sr},
                  "all": c.whole(rot=-6, dy=-4, s=0.96)},
        hit_show=(), hit_hide=("eyes",), shadow_hit_dx=-2,
    )
    c.meta.update(name_ko="경비 로봇", size="사람")
    return c


# ---------------------------------------------------------------- A: alien
@creature("alien", "A")
def alien():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("alien", (W, H), (cx, gy), seed=1002,
                 note="Grey alien, front view. Slender grey being with a huge bulb head, enormous black almond eyes, tiny "
                      "nose slits and mouth, thin neck and limbs, long three-fingered hands, a plain dark suit. attack = "
                      "one hand thrust out with fingers spread, eyes flooding violet; hit = reels back, eyes narrowed.")
    b = Biped(c, cx, gy, 300, build=0.8, leg=0.44, torso=0.26, head=0.34, neck=0.05, shoulder=0.13, hip=0.08, arm_w=0.045,
              leg_w=0.06, arm_len=0.42, stance=0.95)
    c.shadow(cx, gy - 2, 130, 18)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("robe_black", foot_mat="alien", z=1, thigh=1.0, shin=0.9)
    b.torso("robe_black", z=3, chest=0.9, shape="slim")
    c.flat("suit_line", "glow_cyan", 3.1, [P("square", cx, ys + 50, 4, 70)], tags=("torso",), opacity=0.5)
    b.arm_to("l", (b.sh["l"][0] - 10, ys + 118), bend=0.05)
    b.arm_to("r", (b.sh["r"][0] + 10, ys + 118), bend=0.05)
    for s in "lr":
        b.arm(s, "alien", z=4, upper=1.0, fore=0.9, hand=1.0)
        hx, hy = b.hand[s]
        c.add(f"fingers_{s}", "alien", 4.3, [seg(hx, hy, hx + d * 8, hy + 26, 4, ext=0.1) for d in (-1, 0, 1)], tags=(f"arm_{s}",),
              pivot=list(b.sh[s]))
    b.arm_to("r", (b.sh["r"][0] + 50, ys + 10), elbow=(b.sh["r"][0] + 24, ys + 36))
    b.arm("r", "alien", z=4, upper=1.0, fore=0.9, hand=1.1, suffix="_atk", hidden=True, tags=("atk",))
    hx, hy = b.hand["r"]
    c.add("fingers_atk", "alien", 4.3, [seg(hx, hy, hx + 28 * math.cos(math.radians(a)), hy + 28 * math.sin(math.radians(a)), 4, ext=0.1)
                                        for a in (-110, -70, -30)], tags=("atk",), hidden=True)
    c.add("neck", "alien", 5, [seg(cx, ys + 4, cx, hy0 + 44, 16)], tags=("head",))
    c.add("head", "alien", 6, [P("droplet", cx, hy0 + 4, 104, 118, flip="y"), E(cx, hy0 - 16, 108, 84)], tags=("head",))
    for s, k in (("l", -1), ("r", 1)):
        c.flat(f"eye_{s}", "void", 6.2, [P("droplet", cx + k * 24, hy0 + 8, 30, 50, rot=k * -58)], tags=("head", "eyes"))
        c.flat(f"glint_{s}", "eye_white", 6.3, [E(cx + k * 20, hy0, 7, 5)], tags=("head", "eyes"), opacity=0.7, line=False)
        c.glow(f"eye_{s}_glow", "glow_violet", 6.2, [P("droplet", cx + k * 24, hy0 + 8, 30, 50, rot=k * -58)], tags=("head", "glow"),
               color="glow_violet_c", strength=1.0, opacity=0.6, hidden=True)
        c.flat(f"eye_{s}_hit", "void", 6.2, [P("droplet", cx + k * 24, hy0 + 10, 30, 16, rot=k * -40)], tags=("head", "eyes_hit"),
               hidden=True)
    c.flat("nose", "soot", 6.3, [E(cx - 3, hy0 + 30, 2.5, 3), E(cx + 3, hy0 + 30, 2.5, 3)], tags=("head",))
    c.flat("mouth", "soot", 6.3, [seg(cx - 6, hy0 + 42, cx + 6, hy0 + 42, 2)], tags=("head", "mouth"))
    c.flat("mouth_open", "mouth", 6.3, [E(cx, hy0 + 43, 10, 7)], tags=("head", "mouth_open"), hidden=True)
    sl, sr = list(b.sh["l"]), list(b.sh["r"])
    std_frames(
        c,
        attack_move={"head": {"rot": -6, "pivot": [cx, ys]}, "all": c.whole(s=1.04, dy=2)},
        attack_show=("atk", "glow", "mouth_open"), attack_hide=("arm_r", "eyes", "mouth"),
        hit_move={"head": {"rot": 14, "pivot": [cx, ys]}, "arm_l": {"rot": 30, "pivot": sl}, "arm_r": {"rot": -34, "pivot": sr},
                  "all": c.whole(rot=6, dy=-4, s=0.96)},
        shadow_hit_dx=2,
    )
    c.meta.update(name_ko="외계인", size="사람")
    return c


# ---------------------------------------------------------------- A: tentacle horror
@creature("tentacle_horror", "A")
def tentacle_horror():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("tentacle_horror", (W, H), (cx, gy), seed=1003,
                 note="Tentacle horror, front view. Lumpy wet violet mass heaving out of the ground, ringed toothed maw in "
                      "the middle, a crown of glowing yellow eyes, eight thick suckered tentacles writhing outward. attack = "
                      "tentacles reared high and forward, maw gaping wide; hit = tentacles recoil and droop, eyes squeezed.")
    c.shadow(cx, gy - 2, 360, 40)
    tents = [(-1, [(cx - 60, 400), (cx - 170, 430), (cx - 220, 350), (cx - 190, 290)]),
             (-1, [(cx - 70, 330), (cx - 180, 280), (cx - 190, 180), (cx - 130, 150)]),
             (-1, [(cx - 50, 270), (cx - 110, 170), (cx - 80, 80), (cx - 30, 70)]),
             (-1, [(cx - 30, 420), (cx - 120, 480), (cx - 200, 470), (cx - 230, 430)]),
             (1, [(cx + 60, 400), (cx + 170, 430), (cx + 220, 350), (cx + 190, 290)]),
             (1, [(cx + 70, 330), (cx + 180, 280), (cx + 190, 180), (cx + 130, 150)]),
             (1, [(cx + 50, 270), (cx + 110, 170), (cx + 80, 80), (cx + 30, 70)]),
             (1, [(cx + 30, 420), (cx + 120, 480), (cx + 200, 470), (cx + 230, 430)])]
    for i, (k, ctrl) in enumerate(tents):
        z = 1 + (0.5 if i % 4 == 3 else 0) + i * 0.01
        c.add(f"tent_{i}", "tentacle", z, tube(ctrl, 46, 10, n=16, cap=True), tags=("tents", f"tent_{k}"), pivot=list(ctrl[0]))
        c.add(f"tent_{i}_s", "sucker", z + 0.005, suckers_on(ctrl, 7, 46, 10, side=k), tags=("tents", f"tent_{k}"), pivot=list(ctrl[0]),
              clip_to=f"tent_{i}", line=False)
    c.add("mass", "tentacle", 2, [P("metaballs", cx, 330, 250, 230), E(cx, 360, 220, 180), E(cx, 440, 260, 100)], tags=("body",))
    c.flat("maw", "mouth", 2.5, [E(cx, 360, 110, 92)], tags=("body", "mouth"))
    c.flat("teeth", "tooth", 2.6, along([(cx - 52, 360), (cx, 300), (cx + 52, 360)], 7, lambda x, y, a, i, t: P("triangle", x, y + 8, 12, 20, a + 90))
           + along([(cx - 52, 362), (cx, 414), (cx + 52, 362)], 6, lambda x, y, a, i, t: P("triangle", x, y - 8, 11, 18, a - 90)),
           tags=("body", "mouth"), line={"width": 0.5, "heavy": 0.4})
    c.flat("maw_open", "mouth", 2.5, [E(cx, 360, 140, 128)], tags=("body", "mouth_open"), hidden=True)
    c.flat("teeth_open", "tooth", 2.6, along([(cx - 68, 350), (cx, 268), (cx + 68, 350)], 8, lambda x, y, a, i, t: P("triangle", x, y + 10, 13, 24, a + 90))
           + along([(cx - 68, 366), (cx, 440), (cx + 68, 366)], 7, lambda x, y, a, i, t: P("triangle", x, y - 10, 12, 22, a - 90)),
           tags=("body", "mouth_open"), hidden=True, line={"width": 0.5, "heavy": 0.4})
    eyes = [(cx - 70, 262, 18), (cx - 26, 240, 24), (cx + 26, 240, 24), (cx + 70, 262, 18), (cx - 100, 310, 12), (cx + 100, 310, 12)]
    c.flat("sockets", "void", 2.7, [E(x, y, s * 1.5, s * 1.3) for x, y, s in eyes], tags=("body",))
    c.glow("eyes", "glow_yellow", 2.8, [E(x, y, s, s * 0.8) for x, y, s in eyes], tags=("body", "eyes"), color="glow_yellow_c",
           strength=0.9, opacity=0.5)
    c.flat("pupils", "eye", 2.85, [E(x, y, s * 0.24, s * 0.7) for x, y, s in eyes], tags=("body", "eyes"))
    c.flat("eyes_hit", "tentacle", 2.8, [seg(x - s * 0.6, y, x + s * 0.6, y, 4) for x, y, s in eyes], tags=("body", "eyes_hit"),
           hidden=True, color="coat_seam")
    std_frames(
        c,
        attack_move={"tent_-1": {"rot": 12, "sy": 1.06, "pivot": [cx - 40, 400]}, "tent_1": {"rot": -12, "sy": 1.06, "pivot": [cx + 40, 400]},
                     "all": c.whole(s=1.0)},
        attack_show=("mouth_open",), attack_hide=("mouth",),
        hit_move={"tent_-1": {"rot": -12, "sy": 0.9, "pivot": [cx - 40, 400]}, "tent_1": {"rot": 12, "sy": 0.9, "pivot": [cx + 40, 400]},
                  "all": c.whole(sy=0.92, sx=1.03, rot=3)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="촉수 괴물", size="큼")
    return c


# ---------------------------------------------------------------- A: eyeball
@creature("eyeball", "A")
def eyeball():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("eyeball", (W, H), (cx, gy), seed=1004,
                 note="Eyeball monster, front view. A floating giant eye in heavy dark lids, dull yellowed white with faint "
                      "dark veins, rust iris and black pupil, four dangling tendrils beneath. attack = lids stretched wide, "
                      "pupil shrunk to a slit and the iris glowing; hit = lids squeezed shut, squashed and tilted.")
    c.shadow(cx, gy - 2, 120, 16, opacity=0.28, blur=6)
    for i, x in enumerate((cx - 36, cx - 12, cx + 12, cx + 36)):
        c.add(f"tendril_{i}", "tentacle", 1, tube([(x, 250), (x + (i - 1.5) * 10, 290), (x - (i - 1.5) * 8, 330)], 16, 5, n=10, cap=True),
              tags=("tendrils",))
    c.add("lids", "hide_bat", 2, [E(cx, 196, 196, 170)], tags=("body",))
    c.add("white", "eye_white", 2.5, [E(cx, 198, 150, 118)], tags=("body", "eyes"))
    c.flat("veins", "cloth_wine", 2.6, [seg(cx - 70, 190, cx - 40, 200, 2.5), seg(cx - 44, 200, cx - 30, 214, 2), seg(cx + 72, 206, cx + 44, 196, 2.5),
                                        seg(cx + 46, 196, cx + 36, 178, 2), seg(cx - 20, 250, cx - 8, 232, 2)], tags=("body", "eyes"),
           clip_to="white", opacity=0.6)
    c.add("iris", "iris", 2.7, [E(cx, 198, 70, 70)], tags=("body", "eyes"))
    c.flat("pupil", "eye", 2.8, [E(cx, 198, 32, 32)], tags=("body", "eyes"))
    c.flat("glint", "eye_white", 2.9, [E(cx - 16, 184, 12, 9)], tags=("body", "eyes"), line=False)
    c.add("white_atk", "eye_white", 2.5, [E(cx, 196, 166, 146)], tags=("atk",), hidden=True)
    c.glow("iris_atk", "glow_red", 2.7, [E(cx, 196, 78, 78)], tags=("atk",), color="glow_red_c", strength=0.8, opacity=0.5, hidden=True)
    c.flat("pupil_atk", "eye", 2.8, [E(cx, 196, 10, 44)], tags=("atk",), hidden=True)
    c.add("lid_top", "hide_bat", 3, [P("circle", cx, 150, 192, 70, half="top")], tags=("lidtop",), hidden=True)
    c.add("lids_shut", "hide_bat", 3, [E(cx, 198, 170, 130)], tags=("eyes_hit",), hidden=True)
    c.flat("lash_line", "void", 3.1, [smile(cx, 202, 150, 30, depth=0.8)[0], smile(cx, 202, 150, 30, depth=0.8)[1]], tags=("eyes_hit",),
           hidden=True)
    std_frames(
        c,
        attack_move={"tendrils": {"sy": 1.1, "pivot": [cx, 250]}, "all": c.whole(s=1.08, dy=-8)},
        attack_show=("atk",), attack_hide=("eyes",),
        hit_move={"tendrils": {"rot": 20, "pivot": [cx, 250]}, "all": c.whole(sx=1.08, sy=0.88, rot=-10, dy=-4)},
        hit_show=("eyes_hit",), hit_hide=("eyes",), shadow_hit_dx=0,
    )
    c.meta.update(name_ko="눈알 괴물", size="사람")
    return c


# ================================================================ B (idle only)
@creature("winged_horror", "B")
def winged_horror():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("winged_horror", (W, H), (cx, gy), seed=1021,
                 note="Winged horror, front view, hovering. Faceless gaunt thing of black rubbery hide: inward-curling "
                      "horns over a blank smooth head, enormous ragged membrane wings, long thin limbs ending in hooked "
                      "claws, a barbed whip tail curling below.")
    c.shadow(cx, gy - 2, 200, 24, opacity=0.28, blur=7)
    for s, k in (("l", -1), ("r", 1)):
        bat_wing(c, f"wing_{s}", s, (cx + k * 30, 190), 200, 130, "membrane", "robe_black", 1, ("wings",), n_fingers=4)
    c.add("tail", "robe_black", 1.2, tube([(cx, 300), (cx + 40, 380), (cx - 30, 440), (cx + 20, 470)], 22, 6, n=14, cap=True)
          + [P("triangle", cx + 24, 478, 20, 26, rot=160)], tags=("tail",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"leg_{s}", "robe_black", 1.5, [seg(cx + k * 22, 300, cx + k * 44, 360, 20), seg(cx + k * 44, 360, cx + k * 36, 420, 14)]
              + claw_hand(cx + k * 36, 424, 90, 18), tags=("legs",))
    c.add("body", "robe_black", 2, [P("droplet", cx, 250, 90, 130, flip="y"), E(cx, 214, 110, 70)], tags=("body",))
    c.flat("ribs", "membrane", 2.1, [p for i in range(3) for p in smile(cx, 226 + i * 14, 60 - i * 8, 6, depth=0.6)], tags=("body",), opacity=0.5)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "robe_black", 2.5, [seg(cx + k * 44, 196, cx + k * 90, 250, 16), seg(cx + k * 90, 250, cx + k * 86, 300, 12)]
              + claw_hand(cx + k * 86, 304, 90, 20, n=4, spread=16), tags=("arms",))
    c.add("head", "robe_black", 3, [P("droplet", cx, 150, 60, 80), E(cx, 164, 56, 50)], tags=("head",))
    c.add("horns", "horn", 2.9, tube([(cx - 20, 136), (cx - 60, 110), (cx - 36, 70)], 14, 4, n=8, cap=True)
          + tube([(cx + 20, 136), (cx + 60, 110), (cx + 36, 70)], 14, 4, n=8, cap=True), tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="날개 달린 괴물", size="큼")
    return c


@creature("clown_monster", "B")
def clown_monster():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("clown_monster", (W, H), (cx, gy), seed=1022,
                 note="Clown monster, front view. Too-tall stooped harlequin creature: chalk-white face split by a grin "
                      "of needle teeth ear to ear, glowing red pinprick eyes, ruffled wine collar, faded diamond-patched "
                      "costume with pom-poms, spindly arms with long clawed fingers.")
    b = Biped(c, cx, gy, 340, build=0.85, leg=0.46, torso=0.29, head=0.15, shoulder=0.15, hip=0.08, arm_w=0.045,
              leg_w=0.06, arm_len=0.46, stance=1.3, hunch=0.05)
    c.shadow(cx, gy - 2, 160, 20)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("cloth_blue", foot_mat="cloth_wine", foot="boot", z=1, thigh=1.3, shin=1.2, foot_w=2.0)
    b.torso("cloth_wine", z=3, chest=1.0, shape="slim")
    c.flat("diamonds", "cloth_blue", 3.1, [P("diamond", cx + dx, ys + 40 + dy, 24, 30) for dx, dy in ((-24, 0), (24, 0), (0, 36), (-24, 72), (24, 72))],
           tags=("torso",), clip_to="torso", opacity=0.8)
    c.add("pompoms", "clown_white", 3.2, [E(cx, ys + 30 + i * 30, 14, 14) for i in range(3)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 30, ys + 140), bend=0.14)
    b.arm_to("r", (b.sh["r"][0] + 30, ys + 136), bend=0.14)
    for s in "lr":
        b.arm(s, "cloth_wine", "clown_white", z=4, upper=1.4, fore=1.3, hand=1.4)
        hx, hy = b.hand[s]
        c.add(f"fingers_{s}", "clown_white", 4.3, [seg(hx, hy, hx + d * 9, hy + 34, 3.5, ext=0.1) for d in (-1.5, -0.5, 0.5, 1.5)], tags=("arms",))
    c.add("collar", "cloth_wine", 5, [P("flower", cx, ys - 4, 110, 50)], tags=("head",))
    c.add("head", "clown_white", 7, [E(cx, hy0, 56, 62)], tags=("head",))
    c.add("hair", "cloth_wine", 6.9, [E(cx - 34, hy0 - 10, 34, 34), E(cx + 34, hy0 - 10, 34, 34)], tags=("head",))
    c.flat("eye_marks", "cloth_blue", 7.1, [P("diamond", cx - 13, hy0 - 6, 14, 22), P("diamond", cx + 13, hy0 - 6, 14, 22)], tags=("head",))
    c.glow("eyes", "glow_red", 7.2, [E(cx - 13, hy0 - 6, 5, 5), E(cx + 13, hy0 - 6, 5, 5)], tags=("head",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.add("nose", "cloth_wine", 7.3, [E(cx, hy0 + 6, 14, 12)], tags=("head",))
    c.flat("mouth", "mouth", 7.25, smile(cx, hy0 + 20, 54, 16, depth=0.35), tags=("head",))
    c.flat("teeth", "tooth", 7.3, fangs(cx - 24, cx + 24, hy0 + 18, 10, 6), tags=("head",), line={"width": 0.4, "heavy": 0.3})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="광대 괴물", size="사람")
    return c


@creature("jack_in_the_box", "B")
def jack_in_the_box():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("jack_in_the_box", (W, H), (cx, gy), seed=1023,
                 note="Jack-in-the-box monster, front view. Scuffed wine-and-bronze painted toy box with a side crank, "
                      "a coiled spring neck and a grinning jester head with a two-pointed belled cap and glowing eyes, "
                      "little white-gloved arms.")
    c.shadow(cx, gy - 2, 180, 22)
    c.add("box", "cloth_wine", 2, [P("square", cx, 300, 150, 130)], tags=("box",))
    c.add("box_trim", "bronze", 2.1, [P("square", cx, 238, 156, 12), P("square", cx, 362, 156, 10)], tags=("box",))
    c.flat("box_mark", "gold", 2.2, [P("star", cx, 300, 50, 50)], tags=("box",), opacity=0.8)
    c.add("crank", "iron", 1.9, [seg(cx + 76, 300, cx + 104, 300, 8), seg(cx + 104, 300, cx + 104, 326, 7), E(cx + 104, 330, 14, 14)], tags=("box",))
    c.add("lid", "cloth_wine", 1.8, [P("square", cx - 40, 222, 80, 14, rot=-40)], tags=("box",))
    c.add("spring", "iron", 2.5, [P("ring", cx + (i % 2) * 6 - 3, 224 - i * 13, 44, 14) for i in range(6)], tags=("spring",))
    c.add("collar", "paper", 3, [P("flower", cx, 150, 90, 36)], tags=("head",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "cloth_blue", 3.1, [seg(cx + k * 30, 160, cx + k * 60, 190, 10)], tags=("head",))
        c.add(f"glove_{s}", "clown_white", 3.2, [E(cx + k * 64, 196, 18, 18)], tags=("head",))
    c.add("head", "clown_white", 4, [E(cx, 114, 70, 70)], tags=("head",))
    c.add("cap", "cloth_blue", 4.2, [P("droplet", cx - 30, 70, 40, 70, rot=-40), P("droplet", cx + 30, 70, 40, 70, rot=40), E(cx, 86, 76, 24)],
          tags=("head",))
    c.add("bells", "gold", 4.3, [E(cx - 56, 46, 14, 14), E(cx + 56, 46, 14, 14)], tags=("head",))
    c.glow("eyes", "glow_yellow", 4.4, [E(cx - 14, 110, 10, 10), E(cx + 14, 110, 10, 10)], tags=("head",), color="glow_yellow_c", strength=0.9, opacity=0.5)
    c.add("cheeks", "cloth_wine", 4.35, [E(cx - 24, 126, 12, 8), E(cx + 24, 126, 12, 8)], tags=("head",), opacity=0.7, line=False)
    c.flat("mouth", "mouth", 4.4, smile(cx, 132, 44, 14), tags=("head",))
    c.flat("teeth", "tooth", 4.45, fangs(cx - 18, cx + 18, 131, 6, 5), tags=("head",), line={"width": 0.4, "heavy": 0.3})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="깜짝 상자", size="작음")
    return c


@creature("dark_matter", "B")
def dark_matter():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("dark_matter", (W, H), (cx, gy), seed=1024,
                 note="Dark matter mass, front view, floating. A heaving lump of near-black void with a faint violet rim, "
                      "specks of starlight drifting inside, a tilted ring of debris orbiting it and one huge pale eye "
                      "opening in the middle.")
    c.shadow(cx, gy - 2, 180, 24, opacity=0.3, blur=8)
    c.add("ring_back", "stone_dark", 1, [E(cx, 214, 330, 80, rot=-12), E(cx, 206, 290, 56, rot=-12, op="sub"), P("square", cx, 250, 400, 80, op="sub", rot=-12)],
          tags=("ring",))
    c.add("mass", "void", 2, [P("metaballs", cx, 200, 230, 210), E(cx, 206, 190, 180)], tags=("body",),
          line={"width": 1.0, "heavy": 1.0, "color": "glow_violet_c"}, glow={"radius": 5, "opacity": 0.35, "color": "glow_violet_c"}, emit=0.2)
    c.glow("stars", "glow_white", 2.2, [P("star", cx + dx, 200 + dy, s, s) for dx, dy, s in ((-60, -40, 10), (50, -60, 8), (70, 30, 9), (-40, 60, 7),
                                                                                             (10, 70, 6), (-80, 10, 6), (30, -20, 5))],
           tags=("body",), color="glow_violet_c", strength=0.9, opacity=0.4, clip_to="mass")
    c.flat("eye_white", "eye_white", 2.4, [E(cx, 204, 70, 44)], tags=("body",))
    c.glow("iris", "glow_violet", 2.5, [E(cx, 204, 34, 34)], tags=("body",), color="glow_violet_c", strength=1.0, opacity=0.5)
    c.flat("pupil", "void", 2.6, [E(cx, 204, 10, 26)], tags=("body",))
    c.add("ring_front", "stone_dark", 3, [E(cx, 214, 330, 80, rot=-12), E(cx, 206, 290, 56, rot=-12, op="sub"), P("square", cx, 176, 400, 80, op="sub", rot=-12)],
          tags=("ring",))
    c.add("debris", "rubble", 3.1, [P("rocks", cx - 150, 236, 26, 22), P("rocks", cx + 140, 186, 22, 18), P("hexagon", cx + 100, 250, 14, 14)], tags=("ring",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="암흑 물질 덩어리", size="사람")
    return c


@creature("android", "B")
def android():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("android", (W, H), (cx, gy), seed=1025,
                 note="Android, front view. Slim synthetic humanoid in scuffed off-white plating over dark joints, a "
                      "smooth face with one panel torn open to wires and a glowing cyan lens, cable bundles at the neck, "
                      "a short stun baton with a cyan tip.")
    b = Biped(c, cx, gy, 320, build=0.9, leg=0.46, torso=0.29, head=0.16, shoulder=0.14, hip=0.08, arm_w=0.05,
              leg_w=0.065, arm_len=0.37, stance=1.1)
    c.shadow(cx, gy - 2, 140, 18)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    b.legs("armor_dark", foot_mat="eye_white", foot="boot", z=1, thigh=1.1, shin=1.0)
    for s in "lr":
        kx, ky = b.knee[s]
        c.add(f"shin_plate_{s}", "eye_white", 1.2, [E(kx, ky + 30, b.leg_w * 1.1, 40)], tags=("legs",))
    b.torso("armor_dark", z=3, chest=0.95, shape="slim")
    c.add("chest_plate", "eye_white", 3.1, [E(cx, ys + 30, 80, 50), P("droplet", cx, ys + 70, 50, 60, flip="y")], tags=("torso",))
    c.glow("core", "glow_cyan", 3.2, [E(cx, ys + 40, 14, 14)], tags=("torso",), color="glow_cyan_c", strength=1.0, opacity=0.6)
    b.arm_to("l", (b.sh["l"][0] - 8, ys + 110), bend=0.08)
    b.arm_to("r", (b.sh["r"][0] + 16, ys + 96), bend=0.14)
    b.arm("l", "armor_dark", "eye_white", z=4, upper=1.2, fore=1.1, hand=1.2)
    b.arm("r", "armor_dark", "eye_white", z=4, upper=1.2, fore=1.1, hand=1.2)
    for s in "lr":
        ex, ey = b.elbow[s]
        c.add(f"arm_plate_{s}", "eye_white", 4.1, [E(ex, ey - 16, b.arm_w * 1.3, 30)], tags=("arms",))
    hx, hy = b.hand["r"]
    c.add("baton", "armor_dark", 3.9, [seg(hx, hy + 10, hx + 10, hy - 60, 8)], tags=("weapon",))
    c.glow("baton_tip", "glow_cyan", 3.95, [E(hx + 11, hy - 64, 12, 14)], tags=("weapon",), color="glow_cyan_c", strength=1.0, opacity=0.6)
    c.add("cables", "armor_dark", 5, [seg(cx - 6, ys - 2, cx - 4, hy0 + 28, 6), seg(cx + 6, ys - 2, cx + 4, hy0 + 28, 6)], tags=("head",))
    c.add("head", "eye_white", 6, [E(cx, hy0, 50, 60)], tags=("head",))
    c.flat("torn", "void", 6.1, [P("triangle", cx + 12, hy0 - 2, 22, 30, rot=30)], tags=("head",))
    c.flat("wires", "gold", 6.15, [seg(cx + 8, hy0 - 8, cx + 16, hy0 + 8, 2), seg(cx + 14, hy0 - 10, cx + 20, hy0 + 4, 2)], tags=("head",))
    c.glow("eye_l", "glow_cyan", 6.2, [E(cx - 11, hy0 - 4, 10, 5)], tags=("head",), color="glow_cyan_c", strength=1.0, opacity=0.5)
    c.glow("lens", "glow_cyan", 6.25, [E(cx + 13, hy0 - 1, 9, 9)], tags=("head",), color="glow_cyan_c", strength=1.0, opacity=0.6)
    c.flat("mouth", "armor_dark", 6.2, [seg(cx - 8, hy0 + 16, cx + 6, hy0 + 16, 2)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="안드로이드", size="사람")
    return c


@creature("combat_drone", "B")
def combat_drone():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("combat_drone", (W, H), (cx, gy), seed=1026,
                 note="Combat drone, front view, hovering. Armoured gunmetal quad-rotor with hazard-yellow panels, four "
                      "shrouded rotors on struts, a central red camera eye, a twin-barrel gun pod slung underneath, blinking "
                      "status lights.")
    c.shadow(cx, gy - 2, 120, 16, opacity=0.28, blur=6)
    for s, k in (("l", -1), ("r", 1)):
        for j, (ox, oy) in enumerate(((104, 150), (80, 206))):
            c.add(f"strut_{s}{j}", "armor_dark", 1, [seg(cx + k * 30, 180, cx + k * ox, oy, 10)], tags=("body",))
            c.add(f"rotor_{s}{j}", "metal_robot", 1.2 + j * 0.1, [E(cx + k * ox, oy, 66, 20), E(cx + k * ox, oy, 54, 12, op="sub")], tags=("body",))
            c.flat(f"blades_{s}{j}", "armor_dark", 1.15 + j * 0.1, [E(cx + k * ox, oy, 54, 6, rot=8)], tags=("body",), opacity=0.7)
    c.add("hull", "metal_robot", 2, [P("hexagon", cx, 184, 110, 80)], tags=("body",))
    c.flat("panels", "paint_yellow", 2.1, [seg(cx - 50 + i * 20, 210, cx - 34 + i * 20, 176, 6) for i in range(6)], tags=("body",),
           clip_to="hull", opacity=0.8)
    c.flat("eye_ring", "armor_dark", 2.2, [E(cx, 184, 40, 40)], tags=("body",))
    c.glow("eye", "glow_red", 2.3, [E(cx, 184, 22, 22)], tags=("body",), color="glow_red_c", strength=1.0, opacity=0.6)
    c.flat("pupil", "void", 2.35, [E(cx, 184, 8, 8)], tags=("body",))
    c.add("gunpod", "armor_dark", 2.5, [P("square", cx, 236, 50, 26), seg(cx - 10, 244, cx - 10, 272, 8), seg(cx + 10, 244, cx + 10, 272, 8)],
          tags=("body",))
    c.glow("status", "glow_green", 2.6, [E(cx - 40, 164, 5, 5), E(cx + 40, 164, 5, 5)], tags=("body",), color="glow_green_c", strength=1.0, opacity=0.5)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="전투 드론", size="작음")
    return c


@creature("guard_doll", "B")
def guard_doll():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("guard_doll", (W, H), (cx, gy), seed=1027,
                 note="Clockwork guard doll, front view. Stiff wooden toy soldier automaton: tall wine shako with a brass "
                      "plate, painted round cheeks and fixed staring eyes, wine tunic with brass buttons and cross belts, "
                      "jointed wooden limbs, a bayonet musket held upright, a wind-up key turning behind its back.")
    b = Biped(c, cx, gy, 330, build=0.95, leg=0.44, torso=0.28, head=0.15, shoulder=0.14, hip=0.085, arm_w=0.055,
              leg_w=0.07, arm_len=0.36, stance=0.8)
    c.shadow(cx, gy - 2, 140, 18)
    ys, yh, hy0 = b.y_sh, b.y_hip, b.head_y
    c.add("key", "brass", 0.5, [seg(cx + 40, ys + 60, cx + 80, ys + 50, 8), P("club", cx + 92, ys + 46, 30, 30, rot=80)], tags=("key",))
    b.legs("robe_black", foot_mat="robe_black", foot="boot", z=1, thigh=1.1, shin=1.0)
    for s in "lr":
        kx, ky = b.knee[s]
        c.add(f"kneejoint_{s}", "wood", 1.2, [E(kx, ky, b.leg_w * 1.1, b.leg_w * 1.1)], tags=("legs",))
    b.torso("cloth_wine", z=3, chest=1.0, shape="barrel")
    c.add("belts", "paper", 3.2, [seg(cx - 40, ys + 4, cx + 36, yh - 10, 7), seg(cx + 40, ys + 4, cx - 36, yh - 10, 7)], tags=("torso",), cast=False)
    c.add("buttons", "brass", 3.3, [E(cx, ys + 20 + i * 22, 8, 8) for i in range(4)], tags=("torso",))
    b.arm_to("l", (b.sh["l"][0] - 6, ys + 104), bend=0.04)
    b.arm_to("r", (b.sh["r"][0] + 6, ys + 88), elbow=(b.sh["r"][0] + 10, ys + 50))
    b.arm("l", "cloth_wine", "clown_white", z=4, upper=1.2, fore=1.1, hand=1.2)
    b.arm("r", "cloth_wine", "clown_white", z=4, upper=1.2, fore=1.1, hand=1.2)
    for s in "lr":
        c.add(f"epaulette_{s}", "gold", 4.5, [E(b.sh[s][0], b.sh[s][1], 30, 16)], tags=("torso",))
    hx, hy = b.hand["r"]
    c.add("musket", "wood", 3.9, [seg(hx + 6, hy + 60, hx + 8, hy - 150, 9)], tags=("weapon",))
    c.add("barrel", "iron", 3.95, [seg(hx + 8, hy - 90, hx + 8, hy - 160, 5), P("triangle", hx + 8, hy - 176, 6, 26)], tags=("weapon",))
    c.add("head", "wood", 6, [E(cx, hy0 + 4, 52, 56)], tags=("head",))
    c.add("shako", "cloth_wine", 6.5, [P("cylinder", cx, hy0 - 40, 50, 60)], tags=("head",))
    c.add("shako_plate", "brass", 6.6, [P("shield", cx, hy0 - 38, 20, 24)], tags=("head",))
    c.add("plume", "clown_white", 6.4, [P("droplet", cx, hy0 - 78, 16, 30)], tags=("head",))
    c.add("chinstrap", "gold", 6.7, [smile(cx, hy0 + 20, 48, 20, depth=0.6)[0], smile(cx, hy0 + 20, 48, 20, depth=0.6)[1]], tags=("head",), kind="flat")
    dot_eyes(c, cx, hy0 + 2, 11, 9, 9, z=6.8, tags=("head",))
    c.add("cheeks", "cloth_wine", 6.75, [E(cx - 16, hy0 + 14, 12, 9), E(cx + 16, hy0 + 14, 12, 9)], tags=("head",), line=False, opacity=0.8)
    c.flat("mouth", "mouth", 6.8, [seg(cx - 6, hy0 + 22, cx + 6, hy0 + 22, 2)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="태엽 경비 인형", size="사람")
    return c


@creature("steam_golem", "B")
def steam_golem():
    W, H = 512, 512
    cx, gy = 256, 494
    c = Creature("steam_golem", (W, H), (cx, gy), seed=1028,
                 note="Steam golem, front view. Hulking riveted brass-and-iron boiler automaton: glowing furnace grate "
                      "in the belly, twin smokestacks behind the shoulders, pressure gauges on the chest, round porthole "
                      "eyes lit orange, piston arms ending in three-fingered iron claws, squat stomping legs.")
    c.shadow(cx, gy - 2, 330, 36)
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"stack_{s}", "iron", 0.5, [P("cylinder", cx + k * 96, 110, 40, 110)], tags=("body",))
        c.add(f"stack_rim_{s}", "brass", 0.6, [E(cx + k * 96, 58, 48, 16)], tags=("body",))
        c.add(f"leg_{s}", "iron", 1, [P("cylinder", cx + k * 70, 420, 80, 90), P("square", cx + k * 76, 470, 110, 40)], tags=("legs",))
    c.add("boiler", "brass", 2, [E(cx, 290, 250, 250)], tags=("body",))
    c.add("bands", "iron", 2.1, [P("square", cx, 220, 260, 16), P("square", cx, 360, 260, 16)], tags=("body",), clip_to="boiler")
    c.flat("rivets", "iron", 2.2, [E(cx + dx, y, 6, 6) for y in (220, 360) for dx in range(-110, 120, 22)], tags=("body",), clip_to="boiler")
    c.add("grate_frame", "iron", 2.3, [P("square", cx, 310, 110, 70)], tags=("body",))
    c.glow("furnace", "fire_mid", 2.4, [P("square", cx, 310, 90, 52)], tags=("body",), color="ember_glow", strength=1.0, opacity=0.6)
    c.add("grate", "iron", 2.5, [P("square", cx + d * 18, 310, 6, 56) for d in (-2, -1, 0, 1, 2)], tags=("body",))
    c.add("gauges", "brass", 2.6, [P("gauge", cx - 60, 252, 40, 40), P("gauge", cx + 60, 252, 40, 40)], tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        sx, sy = cx + k * 130, 230
        c.add(f"shoulder_{s}", "iron", 3, [E(sx, sy, 80, 80)], tags=("arms",))
        c.add(f"piston_{s}", "armor", 3.1, [seg(sx + k * 10, sy + 20, sx + k * 26, sy + 120, 26)], tags=("arms",))
        c.add(f"forearm_{s}", "iron", 3.2, [P("cylinder", sx + k * 28, sy + 140, 50, 70)], tags=("arms",))
        c.add(f"claw_{s}", "armor_dark", 3.3, [P("moon", sx + k * 28 + d * 14, sy + 190, 26, 26, rot=135 + d * 40) for d in (-1, 0, 1)], tags=("arms",))
    c.add("head", "iron", 4, [P("circle", cx, 156, 110, 90, half="top"), P("square", cx, 164, 110, 30)], tags=("head",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"porthole_{s}", "brass", 4.1, [E(cx + k * 26, 148, 34, 34)], tags=("head",))
    c.glow("eyes", "fire_core", 4.2, [E(cx - 26, 148, 22, 22), E(cx + 26, 148, 22, 22)], tags=("head",), color="ember_glow", strength=1.0, opacity=0.5)
    c.add("vent", "iron", 4.15, [P("square", cx, 176, 50, 10)], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="증기 골렘", size="큼")
    return c


@creature("mutant_rat", "B")
def mutant_rat():
    W, H = 384, 384
    gy = 366
    c = Creature("mutant_rat", (W, H), (196, gy), seed=1029,
                 note="Mutant rat, 3/4 front view facing the lower left. Dog-sized rat with patchy mangy grey fur, swollen "
                      "pink growths on the back, a crooked third eye, glowing sickly-green eyes, long yellowed incisors, "
                      "spiny ridge, long bare tail.")
    c.shadow(200, gy - 4, 280, 30)
    c.add("tail", "hide_pink", 0.8, tube([(290, 320), (350, 350), (360, 290), (330, 250)], 20, 6, n=16, cap=True), tags=("tail",))
    c.add("body", "fur_rat", 2, [E(230, 280, 200, 150, rot=-12), E(160, 280, 110, 110)], tags=("body",))
    c.add("growths", "flesh_mutant", 2.2, [E(256, 222, 60, 44), E(214, 212, 40, 30), E(290, 250, 36, 30)], tags=("body",))
    c.add("spines", "claw", 2.1, spikes_on([(150, 214), (220, 196), (300, 226)], 7, 20, 12, 0.0, 1.0, side=-1), tags=("body",))
    c.add("haunch", "fur_rat", 2.5, [E(274, 312, 90, 96, rot=-10)], tags=("legs",))
    c.add("hindfoot", "hide_pink", 2.6, [E(278, 356, 56, 16)], tags=("legs",))
    for x, y in ((122, 346), (170, 352)):
        c.add(f"paw_{x}", "hide_pink", 3, [E(x, y, 26, 14)] + [seg(x - 8 + i * 8, y + 4, x - 10 + i * 8, y + 14, 3, ext=0.1) for i in range(3)], tags=("legs",))
        c.add(f"foreleg_{x}", "fur_rat", 2.9, [seg(x + 8, y - 50, x, y - 6, 20)], tags=("legs",))
    c.add("head", "fur_rat", 4, [P("droplet", 110, 250, 96, 140, rot=-122), E(144, 232, 90, 80)], tags=("head",))
    c.add("ear", "hide_pink", 4.1, [E(128, 184, 46, 50)], tags=("head",))
    c.add("growth_head", "flesh_mutant", 4.15, [E(160, 206, 26, 22)], tags=("head",))
    c.add("nose", "hide_pink", 4.3, [E(54, 294, 18, 14, rot=-30)], tags=("head",))
    c.glow("eyes", "glow_green", 4.3, [E(110, 236, 12, 12), E(142, 226, 9, 9), E(124, 212, 7, 7)], tags=("head",), color="glow_green_c",
           strength=1.0, opacity=0.5)
    c.add("teeth", "bone_old", 4.4, [P("square", 72, 312, 10, 20, rot=-20), P("square", 82, 310, 10, 20, rot=-20)], tags=("head",),
          line={"width": 0.5, "heavy": 0.4})
    std_frames(c, a_state=False)
    c.meta.update(name_ko="돌연변이 쥐", size="사람")
    return c


@creature("mutant_roach", "B")
def mutant_roach():
    W, H = 384, 384
    cx, gy = 192, 366
    c = Creature("mutant_roach", (W, H), (cx, gy), seed=1030,
                 note="Mutant cockroach, front view. Huge glossy amber-brown roach rearing slightly: broad pronotum shield "
                      "with a pale rim, whip-long antennae, glowing green radiation-sick eyes, spiny jointed legs, "
                      "chewing mandibles, cracked wing cases.")
    c.shadow(cx, gy - 2, 300, 34)
    for s, k in (("l", -1), ("r", 1)):
        for i in range(3):
            root = (cx + k * (50 + i * 10), 270 + i * 20)
            knee = (cx + k * (110 + i * 22), 240 + i * 30)
            foot = (cx + k * (130 + i * 20), gy - 10)
            arch_leg(c, f"leg_{s}{i}", root, knee, foot, 14, 6, "chitin_rust", 1 + i * 0.02, ("legs",), tip_mat="claw")
            c.add(f"spines_{s}{i}", "claw", 1.05 + i * 0.02, [P("triangle", (root[0] + knee[0]) / 2 + k * 4, (root[1] + knee[1]) / 2 - 8, 5, 10, rot=k * 40)],
                  tags=("legs",))
    c.add("abdomen", "chitin_amber", 2, [E(cx, 260, 190, 170)], tags=("body",))
    c.flat("wing_split", "robe_black", 2.1, [seg(cx, 180, cx, 340, 4), P("lightning_bolt", cx + 40, 250, 10, 36, rot=-10)], tags=("body",),
           clip_to="abdomen", opacity=0.7)
    c.add("pronotum", "chitin_rust", 3, [P("circle", cx, 208, 170, 90, half="bottom"), E(cx, 206, 170, 26)], tags=("head",))
    c.add("rim", "belly", 3.05, [P("circle", cx, 208, 170, 90, half="bottom"), P("circle", cx, 204, 150, 76, half="bottom", op="sub")],
          tags=("head",), opacity=0.7, line=False)
    c.add("head", "chitin_amber", 3.2, [E(cx, 262, 80, 56)], tags=("head",))
    c.glow("eyes", "glow_green", 3.3, [E(cx - 28, 254, 20, 24, rot=-20), E(cx + 28, 254, 20, 24, rot=20)], tags=("head",), color="glow_green_c",
           strength=0.9, opacity=0.5)
    c.add("antennae", "chitin_rust", 3.4, tube([(cx - 14, 238), (cx - 90, 120), (cx - 150, 60)], 6, 2, n=12, cap=True)
          + tube([(cx + 14, 238), (cx + 90, 120), (cx + 150, 60)], 6, 2, n=12, cap=True), tags=("head",))
    c.add("mandibles", "claw", 3.5, [P("moon", cx - 10, 290, 18, 18, rot=135), P("moon", cx + 10, 290, 18, 18, rot=-135, flip="x")], tags=("head",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="돌연변이 바퀴벌레", size="사람")
    return c


@creature("cactus_monster", "B")
def cactus_monster():
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("cactus_monster", (W, H), (cx, gy), seed=1031,
                 note="Cactus monster, front view. Saguaro-shaped cactus creature with ribbed dusty-green flesh, two "
                      "raised arms, pale spines all over, a scowling carved face with glowing amber eyes, a dull wine "
                      "blossom on its head, root feet dug into a clump of dry earth.")
    c.shadow(cx, gy - 2, 180, 22)
    c.add("earth", "rubble", 1, [E(cx, 350, 150, 36)], tags=("body",))
    c.add("roots", "bark", 1.1, tube([(cx - 20, 340), (cx - 50, 356), (cx - 70, 360)], 10, 4, n=5, cap=True)
          + tube([(cx + 20, 340), (cx + 50, 354), (cx + 74, 360)], 10, 4, n=5, cap=True), tags=("body",))
    for s, k in (("l", -1), ("r", 1)):
        c.add(f"arm_{s}", "cactus", 1.5, tube([(cx + k * 40, 240), (cx + k * 90, 240), (cx + k * 94, 180), (cx + k * 90, 140)], 34, 28, n=10, cap=True),
              tags=("arms",))
    c.add("trunk", "cactus", 2, [P("pill", cx, 230, 140, 230, rot=45), E(cx, 240, 106, 220)], tags=("body",))
    c.flat("ribs", "leaf_dark", 2.1, [seg(cx + d * 22, 140, cx + d * 24, 340, 3) for d in (-2, -1, 0, 1, 2)], tags=("body",), clip_to="trunk", opacity=0.5)
    c.flat("spines", "bone_old", 2.2, [seg(x, y, x + (4 if (i % 2) else -4), y - 8, 1.4) for i, (x, y) in enumerate(
        [(cx - 40, 170), (cx + 36, 190), (cx - 30, 300), (cx + 44, 310), (cx - 50, 250), (cx + 50, 250), (cx, 330), (cx - 10, 150), (cx + 20, 150)])],
           tags=("body",))
    c.flat("sockets", "void", 2.4, [E(cx - 20, 206, 26, 18, rot=12), E(cx + 20, 206, 26, 18, rot=-12)], tags=("body",))
    c.glow("eyes", "glow_yellow", 2.5, [E(cx - 20, 207, 9, 6), E(cx + 20, 207, 9, 6)], tags=("body",), color="ember_glow", strength=1.0, opacity=0.5)
    c.flat("mouth", "void", 2.4, smile(cx, 250, 50, 14, frown=True), tags=("body",))
    c.add("blossom", "petal", 3, [P("flower", cx, 124, 50, 40)], tags=("body",))
    std_frames(c, a_state=False)
    c.meta.update(name_ko="선인장 괴물", size="사람")
    return c


@creature("skeleton_pirate", "B")
def skeleton_pirate():
    from .kit import held
    W, H = 320, 384
    cx, gy = 160, 366
    c = Creature("skeleton_pirate", (W, H), (cx, gy), seed=1032,
                 note="Skeleton pirate, front view. Bony pirate in a tattered long wine coat with brass buttons, a black "
                      "tricorn with a bone-coloured trim, a green eye light in one socket, a rusty cutlass raised, a "
                      "wooden peg leg.")
    c.shadow(cx, gy - 2, 160, 20)
    bones_limb(c, "leg_l", [(cx - 16, 252), (cx - 20, 306), (cx - 22, 352)], 11, "bone", 1, ("legs",), (cx - 16, 252))
    c.add("foot_l", "leather", 1.1, [E(cx - 30, 358, 34, 14)], tags=("legs",))
    c.add("peg", "wood", 1, [seg(cx + 16, 252, cx + 20, 306, 14), seg(cx + 20, 306, cx + 22, 356, 10)], tags=("legs",))
    c.add("coat", "cloth_wine", 2, [P("bell", cx, 220, 140, 170, crop=[1.6, 1.4, 14.4, 11.6]), P("mountains", cx, 300, 140, 26, op="sub"),
                                    P("triangle", cx, 290, 50, 120, op="sub")], tags=("body",))
    c.add("ribcage", "bone", 2.5, [E(cx, 190, 64, 60)], tags=("body",))
    c.flat("rib_gaps", "void", 2.6, [p for i in range(3) for p in smile(cx, 180 + i * 13, 54 - i * 6, 7, depth=0.55)], tags=("body",))
    c.add("lapels", "cloth_wine", 2.7, [P("triangle", cx - 30, 180, 30, 80, rot=10), P("triangle", cx + 30, 180, 30, 80, rot=-10)], tags=("body",))
    c.add("buttons", "brass", 2.8, [E(cx - 36, 200 + i * 20, 7, 7) for i in range(3)] + [E(cx + 36, 200 + i * 20, 7, 7) for i in range(3)],
          tags=("body",))
    c.add("sash", "cloth_blue", 2.9, [E(cx, 236, 90, 14)], tags=("body",))
    bones_limb(c, "arm_l", [(cx - 44, 150), (cx - 56, 200), (cx - 58, 244)], 9, "bone", 3, ("arms",), (cx - 44, 150))
    c.add("hand_l", "bone", 3.1, claw_hand(cx - 58, 250, 90, 15), tags=("arms",))
    bones_limb(c, "arm_r", [(cx + 44, 150), (cx + 76, 176), (cx + 74, 126)], 9, "bone", 3, ("arms",), (cx + 44, 150))
    c.add("hand_r", "bone", 3.1, claw_hand(cx + 74, 120, -90, 15), tags=("arms",))
    c.add("cutlass", "armor", 3.05, [held("cutlass", (cx + 74, 122), 90, -110, grip=0.42)], tags=("arms",))
    c.add("sleeves", "cloth_wine", 3.2, [seg(cx - 44, 150, cx - 54, 190, 22), seg(cx + 44, 150, cx + 72, 172, 22)], tags=("arms",))
    c.flat("skull_back", "void", 3.9, [E(cx, 106, 44, 30)], tags=("head",))
    c.add("skull", "bone", 4, [P("skull", cx, 110, 64, 66)], tags=("head",))
    c.glow("eye", "glow_green", 4.2, [E(cx - 10, 106, 6, 6)], tags=("head",), color="glow_green_c", strength=1.0, opacity=0.6)
    c.add("hat", "robe_black", 4.5, [P("triangle", cx, 70, 130, 52, flip="y"), E(cx, 62, 76, 30)], tags=("head",))
    c.add("hat_trim", "bone_old", 4.55, [P("triangle", cx, 70, 130, 52, flip="y"), P("triangle", cx, 66, 116, 42, flip="y", op="sub")],
          tags=("head",), line=False)
    std_frames(c, a_state=False)
    c.meta.update(name_ko="해골 해적", size="사람")
    return c
