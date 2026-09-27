"""g05-genre-v01: creatures of the non-fantasy genres — horror/occult, SF/space, cyberpunk,
steampunk, post-apocalypse, pirates/sea, western (front-view battlers)."""

from __future__ import annotations

import math

from .body import Biped, rot_pt
from .kit import (E, P, Creature, along, brows, creature, dot_eyes, fangs, held, membrane, mirror, poly, seg, smile,
                  std_frames, sym, tube, x_eyes)
from .parts import bat_wing, bones_limb, claw_hand, spikes_on, wing_at


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
