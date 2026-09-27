"""Room building blocks for backgrounds (base_clean only: floor, walls, fixed
structure, flat floor marks).  Two cameras:

* ``IsoRoom``  - quarter view (2:1 isometric): left wall (Y=0) + right wall (X=0)
                 meeting at the far corner, diamond floor tiles.
* ``FrontRoom`` - front / wide / side view: back wall face-on, floor band below
                 seen from above with perspective joints toward a vanishing point.
Everything returns lists of forms (see g06kit.F).
"""

from __future__ import annotations

from . import F, box, ell, icon, quad, rect
from .iso import Iso

LINE_ENV = {"width": 2.0, "heavy": 2.2, "breaks": 0.3}
LINE_THIN = {"width": 1.4, "heavy": 1.6, "breaks": 0.3}


def full(W, H, **kw):
    return rect(-40, -40, W + 40, H + 40, **kw)


class IsoRoom:
    def __init__(self, W=2560, H=1440, origin=(1180, 560), k=250.0, kz=320.0, xmax=6.0, ymax=7.0, zmax=3.4):
        self.W, self.H = W, H
        self.iso = Iso(origin, k, kz)
        self.xmax, self.ymax, self.zmax = xmax, ymax, zmax

    # ---------------------------------------------------------------- floor
    def floor_tiles(self, mat_a, mat_b=None, tile=0.5, joint="floor_joint", z=1.0, inset=0.94, checker_opacity=0.35,
                    shade=None):
        io = self.iso
        forms = [F("floor_joint", [full(self.W, self.H)], joint, 0.0, kind="wash")]
        pa, pb = [], []
        n = int(max(self.xmax, self.ymax) / tile) + 2
        for i in range(n):
            for jj in range(n):
                X0, Y0 = i * tile, jj * tile
                d = tile * (1 - inset) / 2
                pc = io.floor(X0 + d, Y0 + d, X0 + tile - d, Y0 + tile - d)
                (pa if (i + jj) % 2 == 0 else pb).append(pc)
        sh = shade or {"max_radius": 6, "soft": 0.1, "bump": 0.8, "threshold": 0.4, "highlight": 0.86,
                       "highlight_amount": 0.3, "ragged": 0.12}
        forms.append(F("tiles_a", pa, mat_a, z, shade=sh, line={"width": 1.0, "heavy": 0.8, "breaks": 0.2,
                                                                    "color": "floor_joint", "opacity": 0.7}))
        forms.append(F("tiles_b", pb, mat_b or mat_a, z + 0.01, shade=sh,
                       line={"width": 1.0, "heavy": 0.8, "breaks": 0.2, "color": "floor_joint", "opacity": 0.7}))
        if mat_b is None:
            forms.append(F("tiles_checker", pb, "grime", z + 0.02, kind="wash", blend="multiply",
                           opacity=checker_opacity))
        return forms

    def floor_stains(self, spots, z=2.0, color="grime", opacity=0.45, blur=18):
        """spots: [(X, Y, size_m, stretch)] - three size classes, lighter as they get bigger."""
        io = self.iso
        pieces = []
        for X, Y, s, st in spots:
            x, y = io.p(X, Y)
            pieces.append(icon("cloud" if s > 0.6 else "metaballs", x, y, s * io.k * 1.6, s * io.k * 0.8 * st,
                               rot=(X * 37 + Y * 11) % 30 - 15))
        return [F("floor_stains", pieces, color, z, kind="wash", blend="multiply", opacity=opacity, blur=blur,
                  rough={"amp": 0.6, "soft": 10, "cell": 40})]

    # ---------------------------------------------------------------- walls
    def walls(self, mat_left, mat_right, z=3.0, left_color=None, right_color=None):
        io = self.iso
        lw = io.wall_x(0, self.xmax, 0, self.zmax)
        rw = io.wall_y(0, self.ymax, 0, self.zmax)
        fl = F("wall_left", [lw], mat_left, z, kind="flat", textured=True, line=LINE_ENV)
        fr = F("wall_right", [rw], mat_right, z + 0.01, kind="flat", textured=True, line=LINE_ENV)
        if left_color:
            fl["color"] = left_color
        if right_color:
            fr["color"] = right_color
        fl["grime"] = {"stamps": ["cloud", "droplet"], "size": 150, "soft": 18, "density": 0.06,
                       "strength": 0.2, "color": "grime", "lo": 0.2}
        fr["grime"] = dict(fl["grime"])
        corner = F("corner", [quad([io.p(0, 0, 0), io.p(0, 0.03, 0), io.p(0, 0.03, self.zmax), io.p(0, 0, self.zmax)])],
                   "@corner", z + 0.05, kind="flat", opacity=0.8)
        return [fl, fr, corner]

    def wainscot(self, mat, top=0.95, skirt=0.12, panel=0.8, z=3.2, mat_skirt="wood_dark",
                 left_color=None, right_color=None, gaps_left=(), gaps_right=()):
        """Wood panelling along both walls with panel divisions; ``gaps_*`` = [(a0, a1)]
        spans (metres along the wall) left open for doors."""
        io = self.iso

        def spans(total, gaps):
            cur, out = 0.0, []
            for a0, a1 in sorted(gaps):
                if a0 > cur:
                    out.append((cur, a0))
                cur = max(cur, a1)
            if cur < total:
                out.append((cur, total))
            return out

        forms = []
        for side, total, gaps, color in (("l", self.xmax, gaps_left, left_color), ("r", self.ymax, gaps_right,
                                                                                    right_color)):
            wall = io.wall_x if side == "l" else io.wall_y
            pan, sk, rail, divs = [], [], [], []
            for a0, a1 in spans(total, gaps):
                pan.append(wall(a0, a1, skirt, top))
                sk.append(wall(a0, a1, 0, skirt))
                rail.append(wall(a0, a1, top, top + 0.05))
                a = a0 + panel
                while a < a1 - 0.1:
                    divs.append(wall(a - 0.015, a + 0.015, skirt + 0.04, top - 0.04))
                    a += panel
            f = F(f"wainscot_{side}", pan, mat, z, kind="flat", textured=True, line=LINE_THIN)
            if color:
                f["color"] = color
            forms += [f,
                      F(f"skirting_{side}", sk, mat_skirt, z + 0.01, kind="flat", line=LINE_THIN),
                      F(f"rail_{side}", rail, mat_skirt, z + 0.02, kind="flat", line=LINE_THIN),
                      F(f"panel_divs_{side}", divs, "@joint_dark", z + 0.03, kind="flat", opacity=0.6)]
        return forms

    def door(self, name, side, a0, a1, height=2.1, z=4.0, frame="wood_dark", leaf="wood_ochre", state="closed",
             inside="@void_room", inside_floor=None, window=False):
        """Door in a wall. ``side`` 'l' (left wall, a = X) or 'r' (right wall, a = Y).
        state 'closed' | 'open' (dark doorway, leaf swung back against the wall)."""
        io = self.iso
        wall = io.wall_x if side == "l" else io.wall_y
        fw = 0.08
        forms = [F(name + "_frame", [wall(a0 - fw, a0, 0, height + fw), wall(a1, a1 + fw, 0, height + fw),
                                     wall(a0 - fw, a1 + fw, height, height + fw)], frame, z, kind="flat",
                   line=LINE_THIN)]
        if state == "open":
            forms.append(F(name + "_void", [wall(a0, a1, 0, height)], inside, z + 0.01, kind="flat"))
            if inside_floor:
                # a sliver of the next room's floor, seen through the doorway
                forms.append(F(name + "_floor", [wall(a0, a1, 0, 0.16)], inside_floor, z + 0.02, kind="flat",
                               opacity=0.7))
        else:
            lf = F(name + "_leaf", [wall(a0, a1, 0, height)], leaf, z + 0.01, kind="flat", textured=True, line=LINE_THIN)
            if leaf == "wood_red":
                lf["color"] = "#4a2e23"   # darker leaf: the textured red-brown read too bright on a door
            forms.append(lf)
            inset = 0.14
            forms.append(F(name + "_panels", [wall(a0 + inset, a1 - inset, 1.15, height - 0.18),
                                              wall(a0 + inset, a1 - inset, 0.18, 0.95)], "@ink", z + 0.02,
                           kind="flat", opacity=0.18))
            if window:
                forms.append(F(name + "_pane", [wall(a0 + 0.18, a1 - 0.18, 1.35, 1.9)], "glass_booth", z + 0.03,
                               kind="flat", line=LINE_THIN))
            hx = a1 - 0.14 if side == "l" else a0 + 0.14
            p = io.p(hx, 0, 1.0) if side == "l" else io.p(0, hx, 1.0)
            forms.append(F(name + "_handle", [ell(p[0], p[1], 16, 12)], "brass", z + 0.04,
                           line={"width": 0.8, "heavy": 0.8}))
        return forms

    def window(self, name, side, a0, a1, z0, z1, z=4.0, frame="wood_dark", glass="glass_booth", mullions=1,
               beyond=None):
        """Glazed opening.  ``beyond``: optional forms drawn inside the glass (dim far view)."""
        io = self.iso
        wall = io.wall_x if side == "l" else io.wall_y
        fw = 0.07
        forms = [F(name + "_glass", [wall(a0, a1, z0, z1)], glass, z, kind="flat")]
        if beyond:
            forms += beyond
        refl = []
        span = a1 - a0
        for t0, t1 in ((0.12, 0.2), (0.26, 0.3), (0.62, 0.72)):
            p0 = a0 + span * t0
            p1 = a0 + span * t1
            refl.append(quad([io.p(p0, 0, z1 - 0.05) if side == "l" else io.p(0, p0, z1 - 0.05),
                              io.p(p1, 0, z1 - 0.05) if side == "l" else io.p(0, p1, z1 - 0.05),
                              io.p(p1 - span * 0.18, 0, z0 + 0.05) if side == "l" else io.p(0, p1 - span * 0.18, z0 + 0.05),
                              io.p(p0 - span * 0.18, 0, z0 + 0.05) if side == "l" else io.p(0, p0 - span * 0.18, z0 + 0.05)]))
        forms.append(F(name + "_reflect", refl, "@reflect", z + 0.2, kind="flat", opacity=0.12, clip_to=name + "_glass"))
        frames = [wall(a0 - fw, a1 + fw, z0 - fw, z0), wall(a0 - fw, a1 + fw, z1, z1 + fw),
                  wall(a0 - fw, a0, z0, z1), wall(a1, a1 + fw, z0, z1)]
        for m in range(1, mullions + 1):
            a = a0 + span * m / (mullions + 1)
            frames.append(wall(a - fw / 2, a + fw / 2, z0, z1))
        forms.append(F(name + "_frame", frames, frame, z + 0.3, kind="flat", line=LINE_THIN))
        sill = wall(a0 - fw * 1.6, a1 + fw * 1.6, z0 - fw * 1.8, z0 - fw)
        forms.append(F(name + "_sill", [sill], frame, z + 0.31, kind="flat", line=LINE_THIN))
        return forms


class FrontRoom:
    """Back wall face-on from y=0 to ``horizon``; floor from ``horizon`` to the
    bottom, its joints converging to (vx, vy)."""

    def __init__(self, W=2560, H=1440, horizon=860, vanish=(1280, -600)):
        self.W, self.H = W, H
        self.hz = horizon
        self.vx, self.vy = vanish

    def floor_x_at(self, x_bottom, y):
        """x of a floor line that hits the bottom edge at x_bottom, at height y."""
        t = (y - self.vy) / (self.H - self.vy)
        return self.vx + (x_bottom - self.vx) * t

    def floor_boards(self, mat, n=14, joint="floor_joint", z=1.0, rows=5, spread=1.8, shade=None):
        """Planks / tiles converging toward the vanishing point."""
        W, H, hz = self.W, self.H, self.hz
        forms = [F("floor_joint", [rect(-40, hz - 10, W + 40, H + 40)], joint, 0.5, kind="wash")]
        xs = [self.vx + (i / n - 0.5) * W * spread for i in range(n + 1)]
        ys = [hz + (H - hz) * ((r / rows) ** 1.35) for r in range(rows + 1)]
        pieces = []
        for i in range(n):
            for r in range(rows):
                y0, y1 = ys[r], ys[r + 1]
                g = 3 + 5 * (r / rows)
                a = self.floor_x_at(xs[i], y0) + g * 0.5
                b = self.floor_x_at(xs[i + 1], y0) - g * 0.5
                c = self.floor_x_at(xs[i + 1], y1) - g
                d = self.floor_x_at(xs[i], y1) + g
                pieces.append(quad([(a, y0 + g * 0.4), (b, y0 + g * 0.4), (c, y1 - g * 0.4), (d, y1 - g * 0.4)]))
        sh = shade or {"max_radius": 6, "soft": 0.1, "bump": 0.8, "threshold": 0.4, "highlight": 0.86,
                       "highlight_amount": 0.3, "ragged": 0.12}
        forms.append(F("floor", pieces, mat, z, shade=sh, line={"width": 1.0, "heavy": 0.8, "breaks": 0.2,
                                                                  "color": "floor_joint", "opacity": 0.7}))
        return forms

    def back_wall(self, mat, z=3.0, top=0, color=None):
        f = F("back_wall", [rect(-40, top - 40, self.W + 40, self.hz)], mat, z, kind="flat", textured=True,
              line=LINE_ENV)
        f["grime"] = {"stamps": ["cloud", "droplet"], "size": 150, "soft": 18, "density": 0.06,
                      "strength": 0.2, "color": "grime", "lo": 0.2}
        if color:
            f["color"] = color
        return [f]

    def baseboard(self, mat="wood_dark", h=40, z=3.3):
        return [F("baseboard", [rect(-40, self.hz - h, self.W + 40, self.hz + 4)], mat, z, kind="flat",
                  line=LINE_THIN)]
