"""Front-view biped skeleton: keypoints + standard parts for humanoid monsters.

Screen sides: "l" = left half of the picture, "r" = right half.
Heights are fractions of the standing height ``H`` measured up from the ground.

Pose variants: ``arm(side, ..., suffix="_atk", hidden=True, tags=("atk",))`` draws a
second copy of an arm (e.g. raised for the attack frame) that a frame can
``show`` while it ``hide``s the idle arm (tag ``arm_<side>``).  This keeps full
control of the z order (a raised arm can pass in front of the head).
"""

from __future__ import annotations

import math

from .kit import E, P, seg


def rot_pt(p, pivot, deg):
    """Rotate point p around pivot by deg (clockwise on the y-down screen), like iconkit moves."""
    r = math.radians(deg)
    x, y = p[0] - pivot[0], p[1] - pivot[1]
    return (pivot[0] + x * math.cos(r) - y * math.sin(r), pivot[1] + x * math.sin(r) + y * math.cos(r))


class Biped:
    def __init__(self, c, cx, ground, H, build=1.0, leg=0.46, torso=0.31, head=0.19, neck=0.03,
                 shoulder=0.17, hip=0.095, arm_w=0.075, leg_w=0.085, arm_len=0.36, stance=1.0, hunch=0.0):
        self.c, self.cx, self.g, self.H, self.b = c, cx, ground, H, build
        self.leg_w = leg_w * H * build
        self.arm_w = arm_w * H * build
        self.y_hip = ground - leg * H
        self.y_knee = ground - leg * H * 0.5
        self.y_ankle = ground - 0.035 * H
        self.y_sh = self.y_hip - torso * H + hunch * H
        self.y_chest = self.y_sh + 0.09 * H
        self.y_waist = self.y_hip - 0.05 * H
        self.head_h = head * H
        self.head_y = self.y_sh - neck * H - self.head_h * 0.42 + hunch * H * 0.6
        self.sw = shoulder * H * build
        self.hw = hip * H * build
        self.stance = stance
        self.arm_len = arm_len * H
        self.sh = {"l": (cx - self.sw, self.y_sh), "r": (cx + self.sw, self.y_sh)}
        self.hand = {}
        self.elbow = {}
        for s, k in (("l", -1), ("r", 1)):
            sx, sy = self.sh[s]
            ex, ey = sx + k * 0.035 * H, sy + self.arm_len * 0.5
            hx, hy = sx + k * 0.05 * H, sy + self.arm_len
            self.elbow[s], self.hand[s] = (ex, ey), (hx, hy)
        self.hipj = {"l": (cx - self.hw * 0.62, self.y_hip), "r": (cx + self.hw * 0.62, self.y_hip)}
        self.foot = {"l": (cx - self.hw * 0.8 * stance, ground - 0.02 * H), "r": (cx + self.hw * 0.8 * stance, ground - 0.02 * H)}
        self.knee = {s: ((self.hipj[s][0] + self.foot[s][0]) / 2 + (-1 if s == "l" else 1) * 0.012 * H, self.y_knee) for s in "lr"}

    # ------------------------------------------------------------------ helpers
    def arm_to(self, side, hand, elbow=None, bend=0.12):
        """Place a hand; the elbow goes out sideways by ``bend`` * arm length unless given."""
        sx, sy = self.sh[side]
        hx, hy = hand
        if elbow is None:
            mx, my = (sx + hx) / 2, (sy + hy) / 2
            dx, dy = hx - sx, hy - sy
            n = math.hypot(dx, dy) or 1.0
            k = -1 if side == "l" else 1
            px, py = dy / n, -dx / n
            if px * k < 0:
                px, py = -px, -py
            elbow = (mx + px * bend * self.arm_len, my + py * bend * self.arm_len)
        self.hand[side], self.elbow[side] = hand, elbow

    # ------------------------------------------------------------------ parts
    def legs(self, mat, foot_mat=None, foot="circle", z=1.0, thigh=1.15, shin=0.9, foot_w=1.6, foot_h=0.7, tags=()):
        c = self.c
        for s in "lr":
            hx, hy = self.hipj[s]
            kx, ky = self.knee[s]
            fx, fy = self.foot[s]
            pieces = [seg(hx, hy, kx, ky, self.leg_w * thigh), seg(kx, ky, fx, fy - self.leg_w * 0.2, self.leg_w * shin)]
            c.add(f"leg_{s}", mat, z, pieces, tags=("legs", f"leg_{s}", *tags))
            fw, fh = self.leg_w * foot_w, self.leg_w * foot_h
            k = -1 if s == "l" else 1
            if foot == "hoof":
                fp = [P("cylinder", fx, fy - fh * 0.2, fw * 0.8, fh * 1.3)]
            elif foot == "claw":
                fp = [E(fx + k * fw * 0.1, fy - fh * 0.1, fw, fh)] + [
                    P("triangle", fx + k * fw * 0.1 + d * fw * 0.3, fy + fh * 0.35, fw * 0.2, fh * 0.55, rot=180) for d in (-1, 0, 1)]
            elif foot == "boot":
                fp = [E(fx + k * fw * 0.1, fy - fh * 0.15, fw * 1.05, fh * 1.05), E(fx, fy - fh * 0.8, fw * 0.75, fh * 1.2)]
            else:
                fp = [E(fx + k * fw * 0.12, fy, fw, fh)]
            c.add(f"foot_{s}", foot_mat or mat, z + 0.1, fp, tags=("legs", f"leg_{s}", *tags))

    def arm(self, side, mat, hand_mat=None, z=4.0, upper=1.1, fore=0.95, hand=1.25, fist=True, tags=(), suffix="",
            hidden=False, claws=None, claw_mat="claw"):
        c = self.c
        sx, sy = self.sh[side]
        ex, ey = self.elbow[side]
        hx, hy = self.hand[side]
        extra = {"hidden": True} if hidden else {}
        base_tags = (f"arm_{side}",) if not suffix else ()
        pieces = [seg(sx, sy, ex, ey, self.arm_w * upper), seg(ex, ey, hx, hy, self.arm_w * fore)]
        c.add(f"arm_{side}{suffix}", mat, z, pieces, tags=(*base_tags, *tags), pivot=[sx, sy], **extra)
        hw = self.arm_w * hand
        c.add(f"hand_{side}{suffix}", hand_mat or mat, z + 0.2, [E(hx, hy + hw * 0.1, hw, hw * (1.0 if fist else 1.25))],
              tags=(*base_tags, *tags), pivot=[sx, sy], **extra)
        if claws:
            dx, dy = hx - ex, hy - ey
            n = math.hypot(dx, dy) or 1.0
            ux, uy = dx / n, dy / n
            pts = []
            for d in (-1, 0, 1):
                px, py = hx + ux * hw * 0.55 - uy * d * hw * 0.3, hy + uy * hw * 0.55 + ux * d * hw * 0.3
                ang = math.degrees(math.atan2(-ux, uy))
                pts.append(P("triangle", px, py + hw * 0.1, hw * 0.24, hw * claws, rot=ang + 180))
            c.add(f"claws_{side}{suffix}", claw_mat, z + 0.25, pts, tags=(*base_tags, *tags), pivot=[sx, sy], **extra)

    def arms(self, mat, hand_mat=None, z=4.0, upper=1.1, fore=0.95, hand=1.25, fist=True, tags=(), zs=None, claws=None):
        for s in "lr":
            self.arm(s, mat, hand_mat, (zs or {}).get(s, z), upper, fore, hand, fist, tags, claws=claws)

    def torso(self, mat, z=3.0, chest=1.0, belly=1.0, shape="chest", tags=(), name="torso", **kw):
        c, cx, H = self.c, self.cx, self.H
        top, bot = self.y_sh - 0.02 * H, self.y_hip + 0.03 * H
        if shape == "barrel":
            pieces = [E(cx, (top + bot) / 2, self.sw * 2.0 * chest, (bot - top) * 1.05),
                      E(cx, bot - 0.06 * H, self.hw * 2.4 * belly, 0.16 * H)]
        elif shape == "slim":
            pieces = [P("droplet", cx, (top + bot) / 2 + 0.01 * H, self.sw * 1.85 * chest, (bot - top) * 1.12, flip="y"),
                      E(cx, top + 0.05 * H, self.sw * 1.9 * chest, 0.11 * H),
                      E(cx, bot - 0.02 * H, self.hw * 2.0 * belly, 0.1 * H)]
        else:  # "chest": broad shoulders tapering to the hips
            pieces = [E(cx, self.y_chest, self.sw * 2.15 * chest, 0.2 * H),
                      P("droplet", cx, (self.y_chest + bot) / 2 + 0.01 * H, self.sw * 1.8 * chest, (bot - self.y_chest) * 1.35, flip="y"),
                      E(cx, bot - 0.035 * H, self.hw * 2.3 * belly, 0.12 * H)]
        c.add(name, mat, z, pieces, tags=("torso", *tags), **kw)

    def head(self, mat, z=7.0, w=0.9, h=1.0, icon="circle", tags=(), **kw):
        hw = self.head_h * w
        return self.c.add("head", mat, z, [P(icon, self.cx, self.head_y, hw, self.head_h * h)], tags=("head", *tags), **kw)

    def hx(self, f):
        return self.cx + f * self.head_h

    def hy(self, f):
        return self.head_y + f * self.head_h
