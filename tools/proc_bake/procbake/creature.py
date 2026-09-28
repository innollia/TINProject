"""Part tree -> one animal.

Same construction as core/procedural/sprite/creature_builder.gd, with the
capsule/triangle/box geometry swapped for authored SVG silhouettes:

    1. every part of the base role is fused with a smooth minimum, so a stack
       of limbs reads as one body instead of a pile of shapes
    2. the fused silhouette is inked, then filled, then shaded away from the
       light, then given a lit edge
    3. parts that carry a different role (an eye, a belly, a mouth) are painted
       on top in their own role, never fused

The order matters.  Ink goes down first so the fill covers its inner half and
the line ends up outside the silhouette.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np

from .canvas import Canvas
from .palette import (ROLE_BODY, ROLE_INK, ROLE_KEY_LIGHT, ROLE_RIM, ROLE_SHADE)
from .sdf import coverage, poly_sdf_points, smooth_min
from .shapes import Shape, ShapeLibrary

SHADE_STYLES = ("flat", "volumetric", "rim", "ink")
_FAR = np.float32(1.0e6)
_MARGIN = 4
INK_CEILING = 0.20      # the contour may not be lighter than this, whatever the palette says
SHADE_MIX = 0.72         # how far the underside goes toward the shade role
KEY_MIX = 0.55          # how far the lit edge goes toward the key light role


@dataclass
class Part:
    id: str
    shape: str
    parent: str | None = None
    at: float = 0.0                     # normalised arc position on the parent spine
    angle: float = 0.0                  # degrees, relative to the parent bone
    scale: float = 1.0
    offset: tuple = (0.0, 0.0)          # extra px in the parent's frame
    role: str = ROLE_BODY
    shade: str = "volumetric"
    detail: bool = False                # paint on top, never fuse
    squash_follows: str = ""            # part id whose bone this one squashes with
    stiffness: float = 140.0
    damping: float = 0.60
    follow: str = "soft"                # soft | rigid | pinned

    @staticmethod
    def from_dict(raw: dict) -> "Part":
        shade = str(raw.get("shade", "volumetric")).lower()
        if shade not in SHADE_STYLES:
            raise ValueError(f"part {raw.get('id')!r}: shade must be one of {SHADE_STYLES}")
        offset = raw.get("offset", (0.0, 0.0))
        if isinstance(offset, (list, tuple)):
            offset = (float(offset[0]), float(offset[1]))
        return Part(
            id=str(raw["id"]),
            shape=str(raw["shape"]),
            parent=(str(raw["parent"]) if raw.get("parent") else None),
            at=float(raw.get("at", 0.0)),
            angle=float(raw.get("angle", 0.0)),
            scale=float(raw.get("scale", 1.0)),
            offset=offset,
            role=str(raw.get("role", ROLE_BODY)),
            shade=shade,
            detail=bool(raw.get("detail", False)),
            squash_follows=str(raw.get("squash_follows", "")),
            stiffness=float(raw.get("stiffness", 140.0)),
            damping=float(raw.get("damping", 0.60)),
            follow=str(raw.get("follow", "soft")).lower(),
        )


@dataclass
class Placement:
    """Where every part sits this frame.  Written by rest_placement() or by the rig."""
    position: np.ndarray
    rotation: float
    scale: float = 1.0
    squash: tuple | None = None          # (along, across, axis_rad)

    def affine(self) -> np.ndarray:
        p = self.position
        r, s = self.rotation, self.scale
        if self.squash is not None:
            along, across, axis = self.squash
            c, sn = math.cos(axis), math.sin(axis)
            base = np.array([[along, 0.0], [0.0, across]])
            rot = np.array([[c, -sn], [sn, c]])
            lin = s * (rot @ base @ rot.T)
        else:
            lin = np.array([[math.cos(r) * s, math.sin(r) * s],
                            [-math.sin(r) * s, math.cos(r) * s]])
        out = np.eye(3)
        out[:2, :2] = lin
        out[:2, 2] = p
        return out

    def min_scale(self) -> float:
        """Smallest singular value - keeps the antialiased edge ~1px wide."""
        linear = self.affine()[:2, :2]
        largest = float(np.linalg.norm(linear, 2))
        if largest < 1e-9:
            return 1.0
        return abs(float(np.linalg.det(linear))) / largest


@dataclass
class Creature:
    parts: list
    library: ShapeLibrary
    palette: object
    canvas_size: tuple = (256, 256)
    outline_width: float = 2.0
    outline_role: str = ROLE_INK
    shade_depth: float | None = None
    key_role: str = ROLE_KEY_LIGHT
    fusion: float = 3.2
    _by_id: dict = field(default_factory=dict, repr=False)
    _order: list = field(default_factory=list, repr=False)
    legs_spec: list = field(default_factory=list, repr=False)

    def __post_init__(self):
        self._by_id = {}
        self._order = []
        self._legs = list(self.legs_spec or [])
        for part in self.parts:
            if part.id in self._by_id:
                raise ValueError(f"duplicate part id {part.id!r}")
            self._by_id[part.id] = part
            self._order.append(part.id)
        roots = [p for p in self.parts if p.parent is None]
        if len(roots) != 1:
            raise ValueError(f"a creature needs exactly one root part, found {len(roots)}")
        for part in self.parts:
            if part.parent is not None and part.parent not in self._by_id:
                raise ValueError(f"part {part.id!r} names parent {part.parent!r}, which is not a part")
            if part.squash_follows and part.squash_follows not in self._by_id:
                raise ValueError(f"part {part.id!r} squash_follows {part.squash_follows!r}, not a part")

    def world_scales(self) -> dict:
        """World scale of every part.

        `scale` is relative to the PARENT, so it compounds down a chain: three
        parts at 0.4 each land at 0.4 / 0.16 / 0.064, which is how a 4px foot
        ends up on a full sized animal.  Nothing in the spec makes that visible,
        so the composed result is reported and the bake warns when a part is
        driven below the point where it can read.
        """
        out: dict = {}
        for part in self.parts:
            place = self.rest_placement().get(part.id)
            out[part.id] = round(part.scale if place is None else place.scale, 4)
        return out

    def tiny_parts(self, floor: float = 0.22) -> list:
        """Fusing parts whose WORLD scale fell below what can read as anything.

        Two exemptions, both earned rather than assumed.  Overlay parts (eyes,
        pupils, markings) are excluded because a pupil is supposed to be small and
        flagging it buries the real failures in noise.  A part that carries no
        leg chain is also excluded: a foot, a tail tip or a feeler is small ON
        PURPOSE on a tapering animal, and demanding 0.22 of the torso off one
        produces a creature with club feet.  What must not be small is a bone
        that has to hold the animal up, and the leg gate already covers that.
        """
        scales = self.world_scales()
        load_bearing = set()
        for entry in self._legs:
            load_bearing.update(str(p) for p in entry.get("chain", ())[:2])
        return sorted(pid for pid, s in scales.items()
                      if s < floor and not self._by_id[pid].detail
                      and pid not in load_bearing)

    # ------------------------------------------------------------------ geometry
    def shape_of(self, part: Part) -> Shape:
        return self.library.get(part.shape)

    def rest_placement(self) -> dict:
        """The authored pose.

        A child's seat is a point on the parent's spine, so `at` means what
        `at` means in the engine's anchor block: normalised arc position along
        the thing it hangs from.  A child inherits its parent's world rotation
        plus the local heading of the bone it sits on, so a leg drawn pointing
        down stays pointing down when the torso turns.
        """
        out: dict[str, Placement] = {}
        for part_id in self._order:
            part = self._by_id[part_id]
            if part.parent is None:
                out[part_id] = Placement(np.zeros(2), 0.0, part.scale)
                continue
            parent = self._by_id[part.parent]
            parent_place = out[parent.id]
            parent_shape = self.shape_of(parent)
            seat_local = parent_shape.spine_at(part.at) + np.asarray(part.offset, dtype=np.float64)
            seat_world = parent_place.position + _rotate(seat_local, parent_place.rotation) * parent_place.scale
            bone = parent_shape.spine_dir_at(part.at)
            bone_local = math.atan2(float(bone[1]), float(bone[0]))
            out[part_id] = Placement(seat_world,
                                     parent_place.rotation + bone_local + math.radians(part.angle),
                                     parent_place.scale * part.scale)
        return out

    def content_bounds(self, placement: dict, pad: float = 0.0):
        boxes = []
        for part_id, place in placement.items():
            shape = self.shape_of(self._by_id[part_id])
            boxes.append(shape.world_bbox(place.position, place.rotation, place.scale, place.squash, pad))
        if not boxes:
            return (0.0, 0.0, 1.0, 1.0)
        return (min(b[0] for b in boxes), min(b[1] for b in boxes),
                max(b[2] for b in boxes), max(b[3] for b in boxes))

    def default_canvas(self, placement: dict | None = None, margin: int = 4) -> tuple:
        placement = placement or self.rest_placement()
        x0, y0, x1, y1 = self.content_bounds(placement, pad=4.0)
        return (max(int(math.ceil(x1 - x0)) + margin * 2, 8),
                max(int(math.ceil(y1 - y0)) + margin * 2, 8))

    # ------------------------------------------------------------------ render
    def render(self, placement: dict, canvas: Canvas | None = None) -> Canvas:
        """Paint one pose.  Never regenerates geometry, only the field."""
        if canvas is None:
            canvas = Canvas(*self.default_canvas(placement))
        origin = self._origin(placement)
        depth = self.shade_depth
        if depth is None:
            diag = math.hypot(canvas.width, canvas.height)
            depth = min(max(diag * 0.055, 2.0), 9.0)

        base_role = self._by_id[self._order[0]].role
        fuse_ids = [pid for pid in self._order
                    if not self._by_id[pid].detail and self._by_id[pid].role == base_role]
        overlay_ids = [pid for pid in self._order if pid not in fuse_ids]

        if fuse_ids:
            field = self._fuse(fuse_ids, placement, origin, canvas)
            base = self._by_id[fuse_ids[0]]
            self._paint_cel(canvas, field, (0, 0), base.role, base.shade, depth, self.outline_width)
        for pid in overlay_ids:
            part = self._by_id[pid]
            window, field = self._part_field(pid, placement, origin, canvas, inflate=2.0)
            if window is None:
                continue
            self._paint_cel(canvas, field, (window[0], window[1]), part.role, part.shade,
                            depth, self.outline_width)
        return canvas

    def _origin(self, placement: dict) -> np.ndarray:
        """Canvas offset to ADD to every world position, so the figure lands
        `pad` px inside the frame with its tight bounds centred horizontally."""
        x0, y0, _, _ = self.content_bounds(placement, pad=6.0)
        return np.array([_MARGIN - x0, _MARGIN - y0], dtype=np.float64)

    def _fuse(self, ids, placement, origin, canvas: Canvas) -> np.ndarray:
        union = np.full((canvas.height, canvas.width), _FAR, dtype=np.float32)
        for pid in ids:
            part = self._by_id[pid]
            place = placement[pid]
            contours = self.shape_of(part).transformed(place.position + origin, place.rotation,
                                                      place.scale, place.squash)
            window, piece = self._part_field(pid, placement, origin, canvas, pad=part_fusion(part, self.fusion))
            if window is None:
                continue
            target = union[window[1]:window[3], window[0]:window[2]]
            np.copyto(target, smooth_min(target, piece, part_fusion(part, self.fusion)))
        return union

    def _part_field(self, pid, placement, origin, canvas: Canvas, inflate: float = 2.0, pad: float = 0.0):
        part = self._by_id[pid]
        place = placement[pid]
        contours = self.shape_of(part).transformed(place.position + origin, place.rotation,
                                                  place.scale, place.squash)
        window = self._window(contours, origin, canvas, pad=max(inflate, pad))
        if window is None:
            return None, None
        return window, _field(contours, window, canvas, place.min_scale())

    @staticmethod
    def _window(contours, origin, canvas: Canvas, pad: float):
        pts = np.concatenate(contours, axis=0)
        x0 = max(0, int(math.floor(pts[:, 0].min() - pad)))
        y0 = max(0, int(math.floor(pts[:, 1].min() - pad)))
        x1 = min(canvas.width, int(math.ceil(pts[:, 0].max() + pad)) + 1)
        y1 = min(canvas.height, int(math.ceil(pts[:, 1].max() + pad)) + 1)
        if x1 <= x0 or y1 <= y0:
            return None
        return (x0, y0, x1, y1)

    def _paint_cel(self, canvas: Canvas, field, window, role: str, style: str, depth: float,
                   outline: float) -> None:
        if field is None:
            return
        pal = self.palette
        x0, y0 = window
        if outline > 0.0 and pal.has(self.outline_role):
            canvas.paint_ink(field, pal.get(self.outline_role), outline, x0=x0, y0=y0)
        canvas.paint_field(field, pal.get(role), x0=x0, y0=y0)
        if style == "flat":
            return
        canvas.paint_shade(field, pal.mix(role, ROLE_SHADE, SHADE_MIX), depth, x0=x0, y0=y0)
        if style == "volumetric" and pal.has(self.key_role):
            canvas.paint_key(field, pal.mix(role, self.key_role, KEY_MIX),
                             max(1.0, depth * 0.22), x0=x0, y0=y0)
        elif style == "rim" and pal.has(ROLE_RIM):
            canvas.paint_rim(field, pal.get(ROLE_RIM), max(1.0, depth * 0.22), x0=x0, y0=y0)
        elif style == "ink" and pal.has(self.outline_role):
            canvas.paint_ink(field, pal.get(self.outline_role), max(1.0, outline * 0.8),
                             x0=x0, y0=y0)

    # ------------------------------------------------------------------ load
    @staticmethod
    def from_spec(spec: dict, library: ShapeLibrary) -> "Creature":
        from . import palette as pal_mod
        size = spec.get("size", (256, 256))
        if isinstance(size, (list, tuple)):
            size = (int(size[0]), int(size[1]))
        else:
            size = (int(size), int(size))
        seed = int(spec.get("seed", 0))
        variant = int(spec.get("variant", 0))
        palette = pal_mod.from_spec(spec.get("palette") or {}, seed, variant)
        parts = [Part.from_dict(raw) for raw in spec["parts"]]
        creature = Creature(
            parts=parts,
            library=library,
            palette=palette,
            canvas_size=size,
            outline_width=float(spec.get("outline_width", 0.0)),
            outline_role=str(spec.get("outline_role", ROLE_INK)),
            shade_depth=(float(spec["shade_depth"]) if "shade_depth" in spec else None),
            fusion=float(spec.get("fusion", 3.2)),
            key_role=str(spec.get("key_role", ROLE_KEY_LIGHT)),
        legs_spec=list(spec.get("legs") or []),
        )
        creature._force_ink()
        creature._scale_outline()
        return creature

    def _force_ink(self) -> None:
        """The contour is the silhouette.  Rain World reads because the line is
        near black; a line in the body's own dark hue is invisible on a light
        background and indistinguishable from the shape on a dark one, so no
        amount of authoring effort can fix it.  Force the value down and keep
        the hue, which preserves a deliberate colour choice without letting it
        sink below legibility.
        """
        if not self.palette.has(self.outline_role):
            return
        colour = self.palette.get(self.outline_role)
        r, g, b, a = colour
        peak = max(r, g, b)
        if peak <= INK_CEILING:
            return
        k = INK_CEILING / peak
        self.palette.set_role(self.outline_role, (r * k, g * k, b * k, a))

    def _scale_outline(self) -> None:
        """The contour scales with the creature; a spec value is only a floor.

        A fixed 2.5px is a hairline on a 300px animal and a blob on a 60px one,
        and every creature in the library is a different size.  Treating the
        authored number as a minimum means existing specs improve without being
        rewritten, and the line always reads as drawn rather than as an
        accident - which is most of the difference between a sprite and a
        silhouette.
        """
        diag = math.hypot(*self.canvas_size)
        self.outline_width = min(max(max(self.outline_width or 0.0, diag * 0.0095), 1.6), 4.5)


def part_fusion(part: Part, base: float = 3.2) -> float:
    """Smooth-union width for this part, in px.

    This is the single knob that decides whether a creature reads as one animal
    or as parts glued to parts.  Too narrow and every joint becomes a visible
    crease; the cel shade then runs down that crease and the creature looks
    grubby.  Wider than the part is thin and the limb melts into the body, so
    it scales with the part rather than being a constant.
    """
    return base * max(part.scale, 0.05)


def _rotate(v: np.ndarray, angle: float) -> np.ndarray:
    c, s = math.cos(angle), math.sin(angle)
    return np.array([c * v[0] - s * v[1], s * v[0] + c * v[1]], dtype=np.float64)


def _field(contours, window, canvas: Canvas, aa: float) -> np.ndarray:
    x0, y0, x1, y1 = window
    w, h = x1 - x0, y1 - y0
    xs = x0 + np.arange(w, dtype=np.float64) + 0.5
    ys = y0 + np.arange(h, dtype=np.float64) + 0.5
    gx, gy = np.meshgrid(xs, ys)
    pts = np.stack([gx.ravel(), gy.ravel()], axis=1)
    dist, _ = poly_sdf_points(contours, pts)
    return (dist * aa).reshape(h, w).astype(np.float32)
