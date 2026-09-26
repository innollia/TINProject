"""Recipe interpreter: JSON recipe -> painted RGBA image (+ separate shadow layer + manifest).

Recipe (all coordinates / sizes in FINAL output px; the renderer supersamples):

    {
      "asset": "player", "palette": "palette_h0.json", "style": "sprite",
      "canvas": [192, 192], "pivot": [96, 186], "seed": 7,
      "include": ["shared_parts.json"],            # optional, forms prepended
      "forms": [ {form}, ... ],
      "frames": [ {"name": "idle_down"},
                  {"name": "walk_down_1", "move": {"leg_l": [0, 4]}, "hide": [], "show": [],
                   "mirror": false, "materials": {"tag": "material"}} ]
    }

Form:
    name, tags[], z, kind (mass | block | flat | wash | shadow), material, color,
    pieces[ {icon, <cuts>, at, size, rot, flip, skew, squash|ground, op add|sub|clip,
             alpha, repeat{...}} ],
    pivot, hidden, clip_to, cut_by[], rough{amp, soft, cell}, extrude, ao{...},
    line{width, heavy, breaks, color} | false, shade{...}, texture{...} | false,
    cast{dist, blur, opacity} | false, glow{radius, opacity, color}, opacity,
    grad{to, y0, y1}, blend normal | multiply,
    grime{stamps[], size, density, strength, color, soft, foot, foot_curve} | false   (v02)
    emit: 0..1 | true   (v02: the form also goes to the separate emission layer)

v02 (h0-icon-mood-v02) additions: material/form ``grime`` (icon-stamp stains that
multiply toward a grime colour, plus dirt collecting at the foot of front faces)
and ``emit`` (flames, embers: written to ``<frame>_emit.png`` so a lit preview can
add them back after the scene is darkened).  Everything else is unchanged from v01.
"""

from __future__ import annotations

import copy
import hashlib
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image

from . import paint as P
from .icons import IconLibrary, find_project_root
from .raster import Affine, ShapeFactory, canvas_bounds, placement_size, rasterize, shape_to_canvas

TOOL_VERSION = "0.3-mood"
GROUND_SQUASH = math.sin(math.radians(60.0))   # 0.866: ground depth on a 60 deg camera
HEIGHT_SQUASH = math.cos(math.radians(60.0))   # 0.5: vertical height on a 60 deg camera


# ------------------------------------------------------------------ helpers
def load_json(path) -> dict:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def deep_merge(base: dict, over: dict) -> dict:
    out = copy.deepcopy(base)
    for k, v in (over or {}).items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = deep_merge(out[k], v)
        else:
            out[k] = copy.deepcopy(v)
    return out


def tool_source_hash() -> str:
    """Hash of the code that paints assets.  ``lighting.py`` is compose-time only
    (scene light for previews), so editing it does not force asset rebuilds."""
    h = hashlib.sha256()
    for p in sorted(Path(__file__).resolve().parent.glob("*.py")):
        if p.name == "lighting.py":
            continue
        h.update(p.name.encode())
        h.update(p.read_bytes())
    return h.hexdigest()


def load_palette(path) -> dict:
    """mp07: a palette may name ``"extends": "<base palette file>"``; the base is
    loaded first and this file's keys are deep-merged over it, so a region
    palette only lists what it adds and the shared V1 values stay identical."""
    path = Path(path)
    data = load_json(path)
    base = data.pop("extends", None)
    if base:
        data = deep_merge(load_palette(path.parent / base), data)
    return data


def load_recipe(path) -> dict:
    """Load a recipe, resolving ``include`` files (their forms come first)."""
    path = Path(path).resolve()
    data = load_json(path)
    forms = []
    for inc in data.get("include", []):
        forms.extend(load_recipe(path.parent / inc).get("forms", []))
    data["forms"] = forms + data.get("forms", [])
    data["_path"] = str(path)
    data["_dir"] = str(path.parent)
    return data


def stable_seed(*parts) -> int:
    return int(hashlib.sha256("|".join(str(p) for p in parts).encode()).hexdigest()[:8], 16)


# ------------------------------------------------------------------ frames
def _tags(form: dict) -> set:
    return set(form.get("tags", [])) | {form.get("name", "")}


def _move_piece(piece: dict, mv: dict, pivot) -> None:
    dx, dy = mv.get("dx", 0.0), mv.get("dy", 0.0)
    rot = mv.get("rot", 0.0)
    sx, sy = mv.get("sx", 1.0), mv.get("sy", 1.0)
    px, py = pivot
    x, y = piece["at"]
    x, y = (x - px) * sx, (y - py) * sy
    if rot:
        r = math.radians(rot)
        x, y = x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r)
    piece["at"] = [px + x + dx, py + y + dy]
    if rot:
        piece["rot"] = piece.get("rot", 0.0) + rot
    size = piece.get("size")
    if (sx != 1.0 or sy != 1.0) and size is not None:
        if isinstance(size, (int, float)):
            piece["size"] = size * max(sx, sy)
        else:
            piece["size"] = [None if size[0] is None else size[0] * sx,
                             None if size[1] is None else size[1] * sy]


def apply_move(form: dict, mv) -> None:
    if isinstance(mv, (list, tuple)):
        mv = {"dx": mv[0], "dy": mv[1]}
    pieces = form.get("pieces", [])
    pivot = mv.get("pivot") or form.get("pivot") or (pieces[0]["at"] if pieces else [0, 0])
    for piece in pieces:
        _move_piece(piece, mv, pivot)
    if form.get("pivot"):
        form["pivot"] = [form["pivot"][0] + mv.get("dx", 0.0), form["pivot"][1] + mv.get("dy", 0.0)]


def mirror_forms(forms: list, width: float) -> None:
    for form in forms:
        if form.get("pivot"):
            form["pivot"] = [width - form["pivot"][0], form["pivot"][1]]
        for piece in form.get("pieces", []):
            piece["at"] = [width - piece["at"][0], piece["at"][1]]
            flip = piece.get("flip", "") or ""
            piece["flip"] = flip.replace("x", "") if "x" in flip else flip + "x"
            piece["rot"] = -piece.get("rot", 0.0)
            if piece.get("skew"):
                piece["skew"] = [-piece["skew"][0], -piece["skew"][1]]
            rep = piece.get("repeat")
            if rep:
                if "ellipse" in rep:
                    cx, cy, rx, ry = rep["ellipse"]
                    rep["ellipse"] = [width - cx, cy, rx, ry]
                if "line" in rep:
                    rep["line"] = [[width - x, y] for x, y in rep["line"]]
                if "step" in rep:
                    rep["step"] = [-rep["step"][0], rep["step"][1]]


def scale_forms(forms: list, factor: float, origin) -> None:
    """Uniformly scale every placement around ``origin`` (sizes scale too)."""
    ox, oy = origin

    def pt(p):
        return [ox + (p[0] - ox) * factor, oy + (p[1] - oy) * factor]

    for form in forms:
        if form.get("pivot"):
            form["pivot"] = pt(form["pivot"])
        for piece in form.get("pieces", []):
            piece["at"] = pt(piece["at"])
            size = piece.get("size")
            if isinstance(size, (int, float)):
                piece["size"] = size * factor
            elif size is not None:
                piece["size"] = [None if v is None else v * factor for v in size]
            rep = piece.get("repeat")
            if rep:
                if "ellipse" in rep:
                    cx, cy, rx, ry = rep["ellipse"]
                    c = pt((cx, cy))
                    rep["ellipse"] = [c[0], c[1], rx * factor, ry * factor]
                if "line" in rep:
                    rep["line"] = [pt(p) for p in rep["line"]]
                if "step" in rep:
                    rep["step"] = [rep["step"][0] * factor, rep["step"][1] * factor]
                if "points" in rep:
                    rep["points"] = [pt(p) + list(p[2:]) for p in rep["points"]]


def frame_forms(recipe: dict, frame: dict) -> list:
    hide, show = set(frame.get("hide", [])), set(frame.get("show", []))
    out = []
    for index, form in enumerate(copy.deepcopy(recipe["forms"])):
        tags = _tags(form)
        hidden = bool(form.get("hidden", False))
        if tags & show:
            hidden = False
        if tags & hide:
            hidden = True
        if hidden:
            continue
        for key, mv in (frame.get("move") or {}).items():
            if key in tags:
                apply_move(form, mv)
        for key, mat in (frame.get("materials") or {}).items():
            if key in tags:
                form["material"] = mat
        form["_index"] = index
        out.append(form)
    sa = recipe.get("scale_all")
    if sa:
        scale_forms(out, float(sa["factor"]), sa.get("origin", recipe.get("pivot", [0, 0])))
    if frame.get("mirror"):
        mirror_forms(out, recipe["canvas"][0])
    out.sort(key=lambda f: (f.get("z", 0.0), f["_index"]))
    return out


def slice_piece(piece: dict) -> list:
    """Nine-slice: stretch an icon to [w, h] while its border keeps a fixed px size.

    ``"slice": {"border": units, "corner": px}`` (each a number or [x, y]).
    Borders map ``border`` icon units to ``corner`` px; the middle stretches.
    Sub-pieces overlap slightly so resampling leaves no seams.
    """
    sl = piece["slice"]
    bx, by = (sl["border"], sl["border"]) if isinstance(sl["border"], (int, float)) else sl["border"]
    cx, cy = (sl["corner"], sl["corner"]) if isinstance(sl["corner"], (int, float)) else sl["corner"]
    w, h = piece["size"]
    cx, cy = min(cx, w / 2.0), min(cy, h / 2.0)
    us_x, us_y = [0.0, bx, 16.0 - bx, 16.0], [0.0, by, 16.0 - by, 16.0]
    px_x, px_y = [-w / 2, -w / 2 + cx, w / 2 - cx, w / 2], [-h / 2, -h / 2 + cy, h / 2 - cy, h / 2]
    flip = piece.get("flip", "") or ""
    squash = piece.get("squash") or (GROUND_SQUASH if piece.get("ground") else 1.0)
    G = Affine.scale(1.0, squash) @ Affine.rotate(piece.get("rot", 0.0)) @ Affine.skew(*(piece.get("skew") or (0.0, 0.0)))
    e = sl.get("overlap", 0.2)
    out = []
    for i in range(3):
        for j in range(3):
            ux0, ux1, uy0, uy1 = us_x[i], us_x[i + 1], us_y[j], us_y[j + 1]
            if ux1 - ux0 <= 1e-6 or uy1 - uy0 <= 1e-6:
                continue
            tx0, tx1, ty0, ty1 = px_x[i], px_x[i + 1], px_y[j], px_y[j + 1]
            if tx1 - tx0 <= 1e-6 or ty1 - ty0 <= 1e-6:
                continue
            if "x" in flip:
                tx0, tx1 = -tx1, -tx0
            if "y" in flip:
                ty0, ty1 = -ty1, -ty0
            off = G.apply([((tx0 + tx1) / 2.0, (ty0 + ty1) / 2.0)])[0]
            sub = {k: copy.deepcopy(v) for k, v in piece.items() if k not in ("slice", "size", "at", "crop", "fit")}
            sub["crop"] = [max(0.0, ux0 - e), max(0.0, uy0 - e), min(16.0, ux1 + e), min(16.0, uy1 + e)]
            sub["fit"] = [ux0, uy0, ux1, uy1]
            sub["at"] = [piece["at"][0] + off[0], piece["at"][1] + off[1]]
            sub["size"] = [tx1 - tx0, ty1 - ty0]
            out.append(sub)
    return out


def expand_pieces(pieces: list, rng: np.random.Generator) -> list:
    out = []
    for piece in _expand_repeats(pieces, rng):
        if piece.get("slice"):
            out.extend(slice_piece(piece))
        else:
            out.append(piece)
    return out


def _expand_repeats(pieces: list, rng: np.random.Generator) -> list:
    out = []
    for piece in pieces:
        rep = piece.get("repeat")
        if not rep:
            out.append(piece)
            continue
        base = {k: v for k, v in piece.items() if k != "repeat"}
        jit = rep.get("jitter", {})
        spots = []
        if "grid" in rep:
            nx, ny = rep["grid"]
            sx, sy = rep["step"]
            ox, oy = base["at"]
            skip = [list(s) for s in rep.get("skip", [])]
            for j in range(ny):
                for i in range(nx):
                    if [i, j] in skip:
                        continue
                    stagger = rep.get("stagger", 0.0) if j % 2 else 0.0
                    spots.append((ox + i * sx + stagger, oy + j * sy, 0.0))
        elif "ellipse" in rep:
            cx, cy, rx, ry = rep["ellipse"]
            n = int(rep["count"])
            a0, a1 = rep.get("arc", [0.0, 360.0])
            full = abs((a1 - a0) - 360.0) < 1e-6
            for k in range(n):
                f = k / n if full else (k / (n - 1) if n > 1 else 0.5)
                t = math.radians(a0 + rep.get("phase", 0.0) + (a1 - a0) * f)
                spots.append((cx + rx * math.cos(t), cy + ry * math.sin(t),
                              math.degrees(t) + 90.0 if rep.get("orient") else 0.0))
        elif "line" in rep:
            (x0, y0), (x1, y1) = rep["line"]
            n = int(rep["count"])
            for k in range(n):
                f = k / (n - 1) if n > 1 else 0.5
                spots.append((x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, 0.0))
        elif "points" in rep:
            spots = [(p[0], p[1], p[2] if len(p) > 2 else 0.0) for p in rep["points"]]
        icons = rep.get("icons")
        for k, (x, y, r) in enumerate(spots):
            q = copy.deepcopy(base)
            ja = jit.get("at", 0.0)
            q["at"] = [x + rng.uniform(-ja, ja), y + rng.uniform(-ja, ja) * jit.get("at_y", 1.0)]
            q["rot"] = base.get("rot", 0.0) + r + rng.uniform(-1, 1) * jit.get("rot", 0.0)
            js = jit.get("size", 0.0)
            if js and q.get("size") is not None:
                f = 1.0 + rng.uniform(-js, js)
                q["size"] = (q["size"] * f if isinstance(q["size"], (int, float))
                             else [None if v is None else v * f for v in q["size"]])
            jal = jit.get("alpha", 0.0)
            if jal:
                q["alpha"] = float(base.get("alpha", 1.0)) * (1.0 - rng.uniform(0.0, jal))
            if icons:
                q["icon"] = icons[k % len(icons)] if rep.get("cycle", True) else icons[int(rng.integers(0, len(icons)))]
            if rep.get("flip_random") and rng.random() < 0.5:
                q["flip"] = (q.get("flip", "") or "") + "x"
            out.append(q)
    return out


# ------------------------------------------------------------------ renderer
class Renderer:
    def __init__(self, cache_dir=None):
        root = find_project_root(Path(__file__).resolve())
        self.root = root
        self.lib = IconLibrary(root / "addons" / "at-icons" / "node2d", cache_dir)
        self.shapes = ShapeFactory(self.lib)
        self._stamps: dict = {}
        self.instances = 0

    # -- palette / colours ------------------------------------------------------
    def _color(self, value):
        if value is None:
            return None
        if isinstance(value, str) and not value.startswith("#"):
            value = self.palette["colors"][value]
        return P.hex_rgb(value)

    def _material(self, form: dict) -> dict:
        name = form.get("material")
        mat = copy.deepcopy(self.palette["materials"].get(name, {})) if name else {}
        if form.get("color"):
            mat["base"] = form["color"]
        base = self._color(mat.get("base", "#808080"))
        mat["_base"] = base
        mat["_shadow"] = self._color(mat.get("shadow")) if mat.get("shadow") else base * 0.72
        mat["_light"] = self._color(mat.get("light")) if mat.get("light") else np.minimum(1.0, base * 1.18 + 0.03)
        ink = self._color(self.palette["colors"].get("ink", "#2a1a2d"))
        mat["_line"] = self._color(mat.get("line")) if mat.get("line") else P.lerp(mat["_shadow"], ink, 0.65)
        mat["_side"] = self._color(mat.get("side")) if mat.get("side") else mat["_shadow"]
        mat["_side_shadow"] = (self._color(mat.get("side_shadow")) if mat.get("side_shadow")
                               else mat["_side"] * 0.78)
        return mat

    def _stamp(self, spec: dict, ss: int) -> Image.Image:
        key = json.dumps(spec, sort_keys=True) + f"|{ss}"
        if key not in self._stamps:
            img = self.lib.image(spec.get("stamp", "feather"))
            if spec.get("pre_rot"):
                img = img.rotate(spec["pre_rot"], resample=Image.Resampling.BICUBIC, expand=True)
            box = img.getbbox()
            if box:
                img = img.crop(box)
            length = max(2, int(round(spec.get("length", 12) * ss)))
            width = max(2, int(round(spec.get("width", 3) * ss)))
            self._stamps[key] = img.resize((length, width), Image.Resampling.LANCZOS)
        return self._stamps[key]

    # -- geometry --------------------------------------------------------------
    def _piece_forward(self, piece: dict, ss: int):
        shape = self.shapes.get(piece)
        w, h = placement_size(shape, piece.get("size"))
        flip = piece.get("flip", "") or ""
        fx = -1.0 if "x" in flip else 1.0
        fy = -1.0 if "y" in flip else 1.0
        at = piece["at"]
        A = Affine.translate(at[0] * ss, at[1] * ss)
        squash = piece.get("squash") or (GROUND_SQUASH if piece.get("ground") else None)
        if squash:
            A = A @ Affine.scale(1.0, squash)
        A = (A @ Affine.rotate(piece.get("rot", 0.0)) @ Affine.skew(*(piece.get("skew") or (0.0, 0.0)))
             @ Affine.scale(w * ss * fx, h * ss * fy))
        return shape, shape_to_canvas(shape, A)

    def _form_mask(self, form: dict, ss: int, margin: int, limit: tuple, rng):
        placed = []
        for piece in expand_pieces(form.get("pieces", []), rng):
            shape, fwd = self._piece_forward(piece, ss)
            placed.append((shape, fwd, piece.get("op", "add"), float(piece.get("alpha", 1.0))))
        adds = [canvas_bounds(s, f) for s, f, op, _ in placed if op == "add"]
        if not adds:
            return None
        x0 = int(math.floor(min(b[0] for b in adds))) - margin
        y0 = int(math.floor(min(b[1] for b in adds))) - margin
        x1 = int(math.ceil(max(b[2] for b in adds))) + margin
        y1 = int(math.ceil(max(b[3] for b in adds))) + margin
        lx0, ly0, lx1, ly1 = limit
        x0, y0, x1, y1 = max(x0, lx0), max(y0, ly0), min(x1, lx1), min(y1, ly1)
        if x1 <= x0 or y1 <= y0:
            return None
        M = np.zeros((y1 - y0, x1 - x0), dtype=np.float32)
        window = (x0, y0, x1, y1)
        for shape, fwd, op, alpha in placed:
            self.instances += 1
            if op == "clip":
                cov = np.zeros_like(M)
                r = rasterize(shape, fwd, window)
                if r is not None:
                    arr, px, py = r
                    cov[py - y0:py - y0 + arr.shape[0], px - x0:px - x0 + arr.shape[1]] = arr
                M *= cov
                continue
            r = rasterize(shape, fwd, window)
            if r is None:
                continue
            arr, px, py = r
            sl = M[py - y0:py - y0 + arr.shape[0], px - x0:px - x0 + arr.shape[1]]
            if op == "sub":
                sl *= 1.0 - arr * alpha
            else:
                np.maximum(sl, arr * alpha, out=sl)
        return M, x0, y0

    @staticmethod
    def _crop_to(ref, x0: int, y0: int, shape) -> np.ndarray:
        """Resample a stored (mask, rx, ry) into a window at (x0, y0) of ``shape``."""
        R, rx, ry = ref
        out = np.zeros(shape, dtype=np.float32)
        h, w = shape
        ax0, ay0 = max(x0, rx), max(y0, ry)
        ax1, ay1 = min(x0 + w, rx + R.shape[1]), min(y0 + h, ry + R.shape[0])
        if ax1 > ax0 and ay1 > ay0:
            out[ay0 - y0:ay1 - y0, ax0 - x0:ax1 - x0] = R[ay0 - ry:ay1 - ry, ax0 - rx:ax1 - rx]
        return out

    # -- painting ----------------------------------------------------------------
    def _shade(self, M, mat, shade, ss, rng, noise):
        base, shadow, light = mat["_base"], mat["_shadow"], mat["_light"]
        ys, xs = np.nonzero(M > 0.5)
        if len(xs) == 0:
            return np.broadcast_to(base, M.shape + (3,)).copy()
        extent = min(xs.max() - xs.min() + 1, ys.max() - ys.min() + 1)
        radius = float(np.clip(shade.get("soft", 0.3) * extent, 1.5 * ss, shade.get("max_radius", 48) * ss))
        lam = P.lambert(M, radius, shade.get("bump", 1.0), self.light3)
        rag = shade.get("ragged", 0.2)
        e = shade.get("edge", 0.035)
        thr = shade.get("threshold", 0.56)
        s = P.smoothstep(thr - e, thr + e, lam + (noise - 0.5) * rag)
        rgb = P.lerp(shadow, base, s)
        amt = shade.get("highlight_amount", 0.5)
        if amt > 0:
            hthr = shade.get("highlight", 0.93)
            hl = P.smoothstep(hthr - e, hthr + e, lam + (noise - 0.5) * rag * 0.6)
            rgb = P.lerp(rgb, light, hl * amt)
        deep = shade.get("deep", 0.0)
        if deep > 0:  # third, darkest tone in the core of the shadow side
            dthr = shade.get("deep_threshold", thr - 0.25)
            d = 1.0 - P.smoothstep(dthr - e, dthr + e, lam + (noise - 0.5) * rag)
            rgb = P.lerp(rgb, shadow * 0.8, d * deep)
        return rgb

    def _texture(self, rgb, M, mat, tex, ss, rng):
        if not tex or tex.get("strength", 0) <= 0:
            return rgb
        stamp = self._stamp(tex, ss)
        f = P.stroke_field(M.shape[0], M.shape[1], stamp, rng, angle=tex.get("angle", 0.0),
                           jitter=tex.get("jitter", 12.0), density=tex.get("density", 1.0), mask=M)
        st = tex["strength"]
        up = np.maximum(f, 0.0)[..., None] * st
        dn = np.maximum(-f, 0.0)[..., None] * st
        return rgb + (mat["_light"] - rgb) * up + (mat["_shadow"] * 0.85 - rgb) * dn

    def _lines(self, rgb, M, mat, line, ss, noise):
        if not line:
            return rgb
        band = P.edge_band(M, line.get("width", 1.0) * ss, line.get("heavy", 1.0) * ss, self.light2,
                           breaks=line.get("breaks", 0.0), noise=noise)
        color = self._color(line["color"]) if line.get("color") else mat["_line"]
        return P.lerp(rgb, color, band * line.get("opacity", 1.0))

    # -- v02: grime and emission ------------------------------------------------------
    def _stain_stamps(self, spec: dict, ss: int) -> list:
        key = "stain|" + json.dumps(spec, sort_keys=True) + f"|{ss}"
        if key in self._stamps:
            return self._stamps[key]
        size = float(spec.get("size", 40)) * ss
        soft = float(spec.get("soft", 0.0)) * ss
        aspect = float(spec.get("aspect", 1.0))
        out = []
        for i, name in enumerate(spec.get("stamps", ["metaballs", "sponge", "cloud"])):
            img = self.lib.image(name)
            box = img.getbbox()
            if box:
                img = img.crop(box)
            for k, rot in enumerate((0, 90, 180, 270)):
                f = (0.65, 1.0, 1.35)[(i + k) % 3]
                sw = max(3, int(round(size * f)))
                sh = max(3, int(round(size * f * aspect)))
                im = img.resize((sw, sh), Image.Resampling.LANCZOS).rotate(rot, resample=Image.Resampling.BICUBIC,
                                                                          expand=True)
                arr = np.asarray(im, dtype=np.float32) / 255.0
                if soft > 0:
                    pad = int(soft * 2) + 1
                    arr = P.blur(np.pad(arr, pad), soft)
                out.append(arr)
        self._stamps[key] = out
        return out

    def _grime_spec(self, form: dict, mat: dict, style: dict, key: str = "grime"):
        spec = form.get(key, None)
        if spec is False:
            return None
        base = mat.get(key)
        if base is None and key == "grime":
            base = style.get("grime")
        if isinstance(spec, dict):
            return deep_merge(base or {}, spec)
        return base

    def _grime(self, rgb, M, spec, ss, rng, tt=None):
        """Multiply toward a grime colour where icon-stamp stains (and foot dirt) land."""
        if not spec or spec.get("strength", 0) <= 0:
            return rgb
        field = np.zeros(M.shape, dtype=np.float32)
        if spec.get("density", 0) > 0:
            stamps = self._stain_stamps({k: spec[k] for k in ("stamps", "size", "soft", "aspect") if k in spec}, ss)
            field = P.stain_field(M.shape[0], M.shape[1], stamps, rng, density=spec["density"], mask=M,
                                  lo=spec.get("lo", 0.35), hi=spec.get("hi", 1.0))
        if tt is not None and spec.get("foot", 0) > 0:
            field = np.maximum(field, (tt ** spec.get("foot_curve", 2.0)) * spec["foot"])
        amt = np.clip(field, 0.0, 1.0) * float(spec["strength"]) * np.clip(M, 0.0, 1.0)
        color = self._color(spec.get("color", "grime"))
        return rgb * (1.0 - amt[..., None] * (1.0 - color))

    @staticmethod
    def _emit_strength(form: dict) -> float:
        value = form.get("emit", 0.0)
        if value is True:
            return 1.0
        return float(value or 0.0)

    @staticmethod
    def _emit_layer(emit: P.Buffer, rgb, alpha, x0: int, y0: int, strength: float) -> None:
        if strength > 0:
            emit.composite(rgb, alpha * min(1.0, strength), x0, y0)
        else:
            emit.occlude(alpha, x0, y0)

    def _cast(self, M, x0, y0, cast, ss, target: P.Buffer):
        if not cast or cast.get("opacity", 0) <= 0:
            return
        d = cast.get("dist", 2.0) * ss
        C = P.shift(M, -self.light2[0] * d, -self.light2[1] * d)
        C = P.blur(C, cast.get("blur", 1.0) * ss) * (1.0 - M)
        target.darken(C * cast["opacity"], self._color(cast.get("color", "shade_tint")), x0, y0)

    # -- main ----------------------------------------------------------------------
    def render(self, recipe: dict, frame: dict | None = None) -> dict:
        frame = frame or {"name": recipe.get("asset", "asset")}
        rdir = Path(recipe["_dir"])
        self.palette = load_palette(rdir / recipe["palette"])
        style = deep_merge(self.palette["styles"][recipe.get("style", "sprite")], recipe.get("style_override", {}))
        ss = int(recipe.get("supersample", style.get("supersample", 2)))
        W, H = recipe["canvas"]
        Ws, Hs = W * ss, H * ss
        l3 = np.array(recipe.get("light", style.get("light", [-0.4, -0.62, 0.68])), dtype=np.float64)
        self.light3 = l3 / np.linalg.norm(l3)
        l2 = self.light3[:2]
        self.light2 = l2 / (np.linalg.norm(l2) or 1.0)
        seed = int(recipe.get("seed", 1))
        forms = frame_forms(recipe, frame)
        refs = {f.get("clip_to") for f in forms} | {n for f in forms for n in (f.get("cut_by") or [])}
        refs.discard(None)
        separate_shadows = style.get("shadow_output", "separate") == "separate"
        canvas = P.Buffer(Ws, Hs, fill=style.get("background"))
        shadows = P.Buffer(Ws, Hs)
        emit = P.Buffer(Ws, Hs)  # v02: flames / embers, kept separate for lit previews
        stored: dict = {}
        pad = int(style.get("edge_pad", 64) * ss)
        limit = (-pad, -pad, Ws + pad, Hs + pad)
        self.lib.used = {}
        self.instances = 0
        noise_cell = style.get("noise_cell", 10) * ss

        for form in forms:
            kind = form.get("kind", "mass")
            name = form.get("name", f"form{form['_index']}")
            rng = np.random.default_rng(stable_seed(seed, name, frame.get("seed_salt", "")))
            mat = self._material(form)
            line = form.get("line", mat.get("line_style", style.get("line")))
            if kind in ("flat", "wash", "shadow") and "line" not in form:
                line = None
            extrude = float(form.get("extrude", 0.0)) * ss
            ao = form.get("ao", style.get("ao") if kind == "block" else None)
            glow = form.get("glow")
            margin = int(8 * ss + extrude + (ao.get("blur", 0) * 3 * ss + ao.get("spread", 0) * ss if ao else 0)
                         + (glow.get("radius", 0) * 3 * ss if glow else 0)
                         + form.get("blur", 0) * 3 * ss + (form.get("rough", {}) or {}).get("soft", 0) * 2 * ss)
            res = self._form_mask(form, ss, margin, limit, rng)
            if res is None:
                continue
            M, x0, y0 = res
            if form.get("clip_to") in stored:
                M *= self._crop_to(stored[form["clip_to"]], x0, y0, M.shape)
            for other in form.get("cut_by") or []:
                if other in stored:
                    M *= 1.0 - self._crop_to(stored[other], x0, y0, M.shape)
            noise = P.value_noise(M.shape[0], M.shape[1], noise_cell * form.get("noise_scale", 1.0), rng)
            rough = form.get("rough")
            if rough:
                rn = P.value_noise(M.shape[0], M.shape[1], rough.get("cell", 12) * ss, rng)
                M = P.roughen(M, rn, rough.get("amp", 0.4), rough.get("soft", 2.0) * ss)
            if form.get("blur"):
                M = P.blur(M, form["blur"] * ss)
            mottle = form.get("mottle")
            if mottle:
                mn = P.value_noise(M.shape[0], M.shape[1], mottle.get("cell", 120) * ss, rng)
                M = M * P.smoothstep(mottle.get("lo", 0.45), mottle.get("hi", 0.75), mn)
            if name in refs:
                stored[name] = (M.copy(), x0, y0)
            opacity = float(form.get("opacity", 1.0))
            glow_strength = self._emit_strength(form)

            if kind == "shadow":
                color = self._color(form.get("color", "shadow_contact"))
                if separate_shadows:
                    shadows.composite(np.broadcast_to(color, M.shape + (3,)), M * opacity, x0, y0)
                else:
                    canvas.darken(M * opacity, color, x0, y0)
                continue

            if kind == "wash":
                color = mat["_base"]
                rgb = np.broadcast_to(color, M.shape + (3,)).copy()
                rgb = self._texture(rgb, M, mat, form.get("texture", mat.get("texture")), ss, rng)
                if form.get("blend") == "multiply":
                    canvas.darken(M * opacity, color, x0, y0)
                else:
                    canvas.composite(rgb, M * opacity, x0, y0)
                    self._emit_layer(emit, rgb, M * opacity, x0, y0, glow_strength)
                continue

            if kind == "flat":
                rgb = np.broadcast_to(mat["_base"], M.shape + (3,)).copy()
                grad = form.get("grad")
                if grad:
                    yy = (np.arange(M.shape[0], dtype=np.float32) + y0) / ss
                    span = grad["y1"] - grad["y0"]
                    span = span if abs(span) > 1e-6 else 1e-6
                    t = np.clip((yy - grad["y0"]) / span, 0.0, 1.0)
                    t = t ** grad.get("curve", 1.0)
                    rgb = P.lerp(rgb, self._color(grad["to"]), np.repeat(t[:, None], M.shape[1], 1))
                rgb = self._texture(rgb, M, mat, form.get("texture", mat.get("texture") if form.get("textured") else None), ss, rng)
                if isinstance(form.get("grime"), dict):
                    rgb = self._grime(rgb, M, self._grime_spec(form, mat, style), ss, rng)
                rgb = self._lines(rgb, M, mat, line, ss, noise)
                self._cast(M, x0, y0, form.get("cast"), ss, canvas)
                canvas.composite(rgb, M * opacity, x0, y0)
                self._emit_layer(emit, rgb, M * opacity, x0, y0, glow_strength)
                if glow:
                    G = P.blur(M, glow.get("radius", 3) * ss) * glow.get("opacity", 0.5)
                    if form.get("clip_to") in stored:
                        G *= self._crop_to(stored[form["clip_to"]], x0, y0, M.shape)
                    gcol = self._color(glow.get("color", mat.get("light", "#ffffff")))
                    canvas.lighten(G, gcol, x0, y0)
                    if glow_strength > 0:
                        emit.add(G * glow_strength, gcol, x0, y0)
                continue

            shade = deep_merge(style.get("shade", {}), deep_merge(mat.get("shade", {}), form.get("shade", {})))
            tex = form.get("texture", deep_merge(style.get("texture", {}), mat.get("texture", {})) if mat.get("texture") else None)
            if form.get("texture") is not None and form.get("texture") is not False and mat.get("texture"):
                tex = deep_merge(deep_merge(style.get("texture", {}), mat.get("texture", {})), form["texture"])

            grime = self._grime_spec(form, mat, style)

            if kind == "block":
                T = M
                S, tt = P.extrude_down(T, extrude)
                A = np.maximum(T, S)
                if ao:
                    F = P.shift(T, 0, extrude)
                    F = np.maximum(F, S)
                    aom = P.blur(P.dilate(F, ao.get("spread", 2) * ss), ao.get("blur", 6) * ss) * (1.0 - A)
                    aom = aom * ao.get("opacity", 0.35)
                    tint = self._color(ao.get("color", "shadow_contact"))
                    if separate_shadows:
                        shadows.composite(np.broadcast_to(tint, M.shape + (3,)), aom, x0, y0)
                    else:
                        canvas.darken(aom, tint, x0, y0)
                top_shade = deep_merge(shade, form.get("top_shade", {"bump": 0.14, "ragged": 0.08,
                                                                     "highlight_amount": 0.2}))
                top = self._shade(T, mat, top_shade, ss, rng, noise)
                top = self._texture(top, T, mat, tex, ss, rng)
                top = self._grime(top, T, grime, ss, rng)
                side = P.lerp(mat["_side"], mat["_side_shadow"], tt * form.get("side_grad", 0.55))
                side_tex = mat.get("side_texture") or (dict(tex, angle=90.0) if tex else None)
                smat = dict(mat, _light=P.lerp(mat["_side"], mat["_base"], 0.35), _shadow=mat["_side_shadow"])
                side = self._texture(side, S, smat, side_tex, ss, rng)
                side_grime = self._grime_spec(form, mat, style, "side_grime") or grime
                side = self._grime(side, S, side_grime, ss, rng, tt=tt)
                rgb = P.lerp(side, top, np.clip(T, 0.0, 1.0))
                if line:
                    jw = max(1.0, line.get("junction", 0.8) * ss)
                    J = T * P.shift(S, 0, -jw)
                    color = self._color(line["color"]) if line.get("color") else mat["_line"]
                    rgb = P.lerp(rgb, color, J * line.get("junction_opacity", 0.85))
                rgb = self._lines(rgb, A, mat, line, ss, noise)
                self._cast(A, x0, y0, form.get("cast", None), ss, canvas)
                canvas.composite(rgb, A * opacity, x0, y0)
                self._emit_layer(emit, rgb, A * opacity, x0, y0, glow_strength)
                if name in refs:
                    stored[name] = (A.copy(), x0, y0)
                continue

            # mass
            rgb = self._shade(M, mat, shade, ss, rng, noise)
            grad = form.get("grad")
            if grad:
                yy = (np.arange(M.shape[0], dtype=np.float32) + y0) / ss
                span = grad["y1"] - grad["y0"]
                span = span if abs(span) > 1e-6 else 1e-6
                t = np.clip((yy - grad["y0"]) / span, 0.0, 1.0) ** grad.get("curve", 1.0)
                rgb = P.lerp(rgb, self._color(grad["to"]), np.repeat(t[:, None], M.shape[1], 1) * grad.get("amount", 1.0))
            rgb = self._texture(rgb, M, mat, tex, ss, rng)
            rgb = self._grime(rgb, M, grime, ss, rng)
            rgb = self._lines(rgb, M, mat, line, ss, noise)
            self._cast(M, x0, y0, form.get("cast", style.get("cast")), ss, canvas)
            canvas.composite(rgb, M * opacity, x0, y0)
            self._emit_layer(emit, rgb, M * opacity, x0, y0, glow_strength)
            if glow:
                G = P.blur(M, glow.get("radius", 3) * ss) * glow.get("opacity", 0.5)
                gcol = self._color(glow.get("color", mat.get("light", "#ffffff")))
                canvas.lighten(G, gcol, x0, y0)
                if glow_strength > 0:
                    emit.add(G * glow_strength, gcol, x0, y0)

        sil = style.get("silhouette")
        if sil:
            band = P.edge_band(canvas.a, sil.get("width", 1.4) * ss, sil.get("heavy", 1.0) * ss, self.light2)
            ink = self._color(sil.get("color", "ink"))
            band = band * sil.get("opacity", 1.0)
            canvas.rgb = canvas.rgb * (1.0 - band[..., None]) + ink * (band * canvas.a)[..., None]

        image = P.downsample(canvas.to_image(), ss)
        shadow_img = P.downsample(shadows.to_image(), ss) if shadows.a.max() > 0.003 else None
        emit_img = P.downsample(emit.to_image(), ss) if emit.a.max() > 0.003 else None
        pivot = recipe.get("pivot")
        if pivot and frame.get("mirror"):
            pivot = [W - pivot[0], pivot[1]]
        return {
            "image": image,
            "shadow": shadow_img,
            "emit": emit_img,
            "pivot": pivot,
            "icons": dict(sorted(self.lib.used.items())),
            "instances": self.instances,
        }
