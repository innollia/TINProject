"""Shared creature parts (wings, spines) used by every g05 bundle."""

from __future__ import annotations

import math

from .kit import E, P, membrane, poly, seg, tube


# ---------------------------------------------------------------- shared: feathered wing
def wing_at(root, w, h, side, rot=0.0, icon="wing", tips=False):
    """Bird wing icon (full 16-unit box mapped to w x h) whose root (icon (4, 10.5)) stays on ``root``
    for any ``rot``; side "l" spreads to the left.  tips=True keeps only the outer feathers."""
    import math as _m
    k = -1 if side == "l" else 1
    vx, vy = k * -0.25 * w, 0.156 * h          # root offset from the piece centre (unrotated)
    t = _m.radians(rot)
    rx, ry = vx * _m.cos(t) - vy * _m.sin(t), vx * _m.sin(t) + vy * _m.cos(t)
    extra = {"fit": "box"}
    if tips:
        extra["crop"] = [8.8, 0, 16, 16]
    if side == "l":
        extra["flip"] = "x"
    return P(icon, root[0] - rx, root[1] - ry, w, h, rot, **extra)


# ---------------------------------------------------------------- shared: dragon-kind parts
def bat_wing(c, name, side, root, span, up, mat, bone_mat, z, tags, n_fingers=3, hidden=False, droop=0.0):
    """Membrane wing spreading to ``side``: root on the back, wrist up and out, finger tips fanning down."""
    k = -1 if side == "l" else 1
    rx, ry = root
    wrist = (rx + k * span * 0.5, ry - up)
    tips = []
    for i in range(n_fingers):
        f = i / max(1, n_fingers - 1)
        tips.append((rx + k * span * (1.0 - 0.28 * f), ry - up * 0.55 + span * (0.12 + 0.42 * f) + droop * f))
    inner = (rx + k * span * 0.26, ry + span * 0.5 + droop * 0.6)
    extra = {"hidden": True} if hidden else {}
    c.add(name, mat, z, membrane(root, wrist, tips, inner), tags=tags, pivot=list(root), **extra)
    bones = tube([root, ((rx + wrist[0]) / 2, (ry + wrist[1]) / 2 - up * 0.1), wrist], span * 0.07, span * 0.05, n=8)
    for t in tips:
        bones += tube([wrist, t], span * 0.035, span * 0.015, n=8)
    bones.append(P("triangle", wrist[0] + k * span * 0.02, wrist[1] - span * 0.06, span * 0.05, span * 0.09, rot=k * 20))
    c.add(name + "_bones", bone_mat, z + 0.1, bones, tags=tags, pivot=list(root), **extra)


def spikes_on(ctrl, n, h, w, t0=0.1, t1=0.9, side=-1):
    """Triangles standing out of a Bezier spine (side -1 = left normal on screen)."""
    from .kit import along

    def mk(x, y, ang, i, t):
        s = 1.0 - 0.5 * abs(t - 0.5)
        return P("triangle", x, y, w * s, h * s, rot=ang + (90 if side > 0 else -90) + 90)
    return along(ctrl, n, mk, t0, t1)


def bones_limb(c, name, pts, w, mat, z, tags, pivot, joint=1.5, hidden=False):
    """Thin bone chain through pts with knobby joints."""
    pieces = []
    for a, b in zip(pts[:-1], pts[1:]):
        pieces.append(seg(a[0], a[1], b[0], b[1], w, ext=0.1))
    for p in pts:
        pieces.append(E(p[0], p[1], w * joint, w * joint))
    extra = {"hidden": True} if hidden else {}
    c.add(name, mat, z, pieces, tags=tags, pivot=list(pivot), **extra)


def claw_hand(x, y, ang, size, n=3, spread=26.0):
    """Bony / clawed fingers fanning from (x, y) toward screen angle ``ang`` (deg)."""
    out = [E(x, y, size * 0.55, size * 0.5)]
    for i in range(n):
        a = math.radians(ang + (i - (n - 1) / 2) * spread)
        ex, ey = x + math.cos(a) * size, y + math.sin(a) * size
        out.append(seg(x, y, ex, ey, size * 0.18, ext=0.1))
    return out


def heater_shield(x, y, w, h):
    """Heater shield outline (flat top, curved sides, point at the bottom) as a polygon."""
    pts = []
    for i in range(9):
        t = i / 8
        pts.append((x + w / 2 * (1 - 0.55 * t ** 2.2), y - h / 2 + h * 0.62 * t))
    pts.append((x, y + h / 2))
    for i in range(8, -1, -1):
        t = i / 8
        pts.append((x - w / 2 * (1 - 0.55 * t ** 2.2), y - h / 2 + h * 0.62 * t))
    return poly(pts)


def arch_leg(c, name, root, knee, foot, w0, w1, mat, z, tags, pivot=None, hidden=False, tip_mat=None):
    """Arthropod leg: root -> high knee -> foot on the ground, tapering, with a dark tip."""
    pieces = tube([root, ((root[0] + knee[0]) / 2, knee[1] - 6), knee], w0, (w0 + w1) / 2, n=6, cap=True)
    pieces += tube([knee, ((knee[0] + foot[0]) / 2 + (knee[0] - foot[0]) * 0.1, (knee[1] + foot[1]) / 2), foot], (w0 + w1) / 2, w1, n=6, cap=True)
    extra = {"hidden": True} if hidden else {}
    c.add(name, mat, z, pieces, tags=tags, pivot=list(pivot or root), **extra)
    if tip_mat:
        c.add(name + "_tip", tip_mat, z + 0.01, [E(foot[0], foot[1], w1 * 1.4, w1 * 1.6)], tags=tags, pivot=list(pivot or root),
              line=False, **extra)


def pincer(x, y, size, ang, open_=0.35):
    """Crab / scorpion claw: a palm with two curved fingers opening toward angle ``ang`` (deg)."""
    t = math.radians(ang)
    ux, uy = math.cos(t), math.sin(t)
    px, py = x - ux * size * 0.1, y - uy * size * 0.1
    out = [E(px, py, size * 0.72, size * 0.52, ang)]
    tipx, tipy = x + ux * size * 0.55, y + uy * size * 0.55
    for d in (-1, 1):
        a = t + d * open_
        fx, fy = x + math.cos(a) * size * 0.62, y + math.sin(a) * size * 0.62
        out += tube([(x + ux * size * 0.15, y + uy * size * 0.15), ((x + fx) / 2 - uy * d * size * 0.12, (y + fy) / 2 + ux * d * size * 0.12),
                     (fx, fy)], size * 0.26, size * 0.06, n=6)
    return out
