"""2:1 isometric ("quarter view") helpers for rooms and furniture.

World axes: X runs from the far corner toward screen-left-down (along the left
wall), Y from the far corner toward screen-right-down (along the right wall), Z up.
    screen = origin + X * (-k, k/2) + Y * (k, k/2) + Z * (0, -kz)
k = floor px per metre along an axis, kz = vertical px per metre (320 = the
character scale, so heights stay consistent with people).
Visible box faces: top (+Z), left-front (+X), right-front (+Y).
"""

from __future__ import annotations

from . import F, quad


class Iso:
    def __init__(self, origin, k=250.0, kz=320.0):
        self.ox, self.oy = origin
        self.k = k
        self.kz = kz

    def p(self, X, Y, Z=0.0):
        return (self.ox + (Y - X) * self.k, self.oy + (X + Y) * self.k * 0.5 - Z * self.kz)

    # -- planes -----------------------------------------------------------------------------
    def floor(self, X0, Y0, X1, Y1, Z=0.0, **kw):
        return quad([self.p(X0, Y0, Z), self.p(X0, Y1, Z), self.p(X1, Y1, Z), self.p(X1, Y0, Z)], **kw)

    def wall_x(self, X0, X1, Z0, Z1, Y=0.0, **kw):
        """Plane of constant Y (the LEFT wall when Y=0), spanning X0..X1, Z0..Z1."""
        return quad([self.p(X0, Y, Z1), self.p(X1, Y, Z1), self.p(X1, Y, Z0), self.p(X0, Y, Z0)], **kw)

    def wall_y(self, Y0, Y1, Z0, Z1, X=0.0, **kw):
        """Plane of constant X (the RIGHT wall when X=0), spanning Y0..Y1, Z0..Z1."""
        return quad([self.p(X, Y0, Z1), self.p(X, Y1, Z1), self.p(X, Y1, Z0), self.p(X, Y0, Z0)], **kw)

    # -- boxes ------------------------------------------------------------------------------
    def box_faces(self, X0, Y0, Z0, X1, Y1, Z1):
        top = quad([self.p(X0, Y0, Z1), self.p(X0, Y1, Z1), self.p(X1, Y1, Z1), self.p(X1, Y0, Z1)])
        left = quad([self.p(X1, Y0, Z1), self.p(X1, Y1, Z1), self.p(X1, Y1, Z0), self.p(X1, Y0, Z0)])
        right = quad([self.p(X0, Y1, Z1), self.p(X1, Y1, Z1), self.p(X1, Y1, Z0), self.p(X0, Y1, Z0)])
        return top, left, right

    def box(self, name, X0, Y0, Z0, X1, Y1, Z1, mat_top, mat_left, mat_right, z=0.0, kind="flat", line=None,
            top_kw=None, left_kw=None, right_kw=None):
        """Three flat faces.  Light comes from the top-left (V1): the left-front face is
        the lit side face, the right-front face the dark one."""
        t, l, r = self.box_faces(X0, Y0, Z0, X1, Y1, Z1)
        out = []
        for nm, pc, mat, zz, extra in ((name + "_right", r, mat_right, z, right_kw),
                                        (name + "_left", l, mat_left, z + 0.001, left_kw),
                                        (name + "_top", t, mat_top, z + 0.002, top_kw)):
            if isinstance(mat, (tuple, list)):   # (material, colour override): keeps the texture
                f = F(nm, [pc], mat[0], zz, kind=kind, color=mat[1], textured=True)
            else:
                f = F(nm, [pc], mat, zz, kind=kind)
            if line is not None:
                f["line"] = line
            if extra:
                f.update(extra)
            out.append(f)
        return out
