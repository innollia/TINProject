"""Machine checks for a shape library, so "quality" is a measurement not a claim.

    python -m procbake.check                 # whole library
    python -m procbake.check torso_frog head_beak
    python -m procbake.check --json

Three numbers decide whether a body part survives:

  concave   how many separate inward-curving arc runs the outline has.  One is
            an egg.  Three or more means there is a neck, a waist, a joint, a
            notch - the landmarks an animal silhouette is made of.
  min_rad   the tightest curvature radius, in px.  Under ~1.5px is a corner,
            and corners are the thing this whole project bans.
  straight  fraction of the outline that is nearly straight line.  High means
            a shape was built out of polygon edges instead of drawn.

Plus spine checks: monotone in +X, on the centreline, and inside the outline.
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

import numpy as np

from .shapes import ShapeLibrary
from .svgpath import SvgError, parse_path, read_svg

RESAMPLE_DIV = 320.0     # samples per full perimeter - scale relative on purpose
RESAMPLE_MIN = 0.35      # px, so tiny parts keep their detail
SMOOTH = 5               # samples in the curvature moving average
CONCAVE_CHORD = 0.5      # px a run must bow inward by to count as a concavity
CONCAVE_SPAN = 4.0       # px, floor on a run's chord length
CONCAVE_SPAN_FRAC = 0.022  # ...and that floor as a fraction of the perimeter
CONCAVE_BOW_FRAC = 0.11   # a landmark bows at least this much of its own chord
CONCAVE_MIN_SAMPLES = 4   # samples a run must last, kills per-pixel stair-steps
HULL_TOL = 1.0           # px an outline vertex may sit inside its hull and still count as hull
SMOOTH_FRAC = 0.02       # moving-average width as a fraction of the point count


def _smooth_closed(poly: np.ndarray, frac: float = SMOOTH_FRAC) -> np.ndarray:
    """Moving average around a closed loop.

    A contour traced out of pixels is a staircase that also sits about half a
    pixel inside its own true boundary.  Both artefacts read as landmarks.  One
    smoothing pass removes them and leaves the real notches, which is what lets
    the same threshold work on a 40px sprite and a 2000px backdrop.
    """
    n = len(poly)
    w = max(int(round(n * frac)), 1)
    if w < 3 or n < 8:
        return poly
    k = np.ones(w) / w
    padded = np.vstack([poly[-w:], poly, poly[:w]])
    out = np.empty_like(poly)
    for axis in (0, 1):
        out[:, axis] = np.convolve(padded[:, axis], k, mode="valid")[:n]
    return out
MIN_RADIUS_GATE = 1.5    # px, a bend tighter than this counts as "sharp"
SHARP_GATE = 0.14        # share of the outline allowed to be that tight
WINDOW = 5               # +/- samples in the turning-angle window


def _dedupe(poly: np.ndarray) -> np.ndarray:
    out = [poly[0]]
    for p in poly[1:]:
        if np.linalg.norm(p - out[-1]) > 1e-6:
            out.append(p)
    if len(out) > 1 and np.linalg.norm(out[0] - out[-1]) < 1e-6:
        out.pop()
    return np.asarray(out, dtype=np.float64)


def _perimeter(poly: np.ndarray) -> float:
    closed = np.vstack([poly, poly[:1]])
    return float(np.linalg.norm(np.diff(closed, axis=0), axis=1).sum())


def _resample(points: np.ndarray, step: float | None = None) -> np.ndarray:
    """Resample to a FIXED NUMBER of samples per perimeter.

    A fixed pixel step makes the measurement mean different things at different
    sizes: sampled at 0.4px a 200px ellipse reads as 10 concavities and a
    40px sprite as 22, all of it pixel stair-step, and adding three real notches
    to that ellipse changes nothing.  Normalising by perimeter means the
    curvature window is the same fraction of the shape either way, so a circle
    scores 0 whether it is 40px or 2000px across and only real landmarks count.
    """
    if step is None:
        step = max(_perimeter(points) / RESAMPLE_DIV, RESAMPLE_MIN)
    closed = np.vstack([points, points[:1]])
    out = []
    for i in range(len(closed) - 1):
        a, b = closed[i], closed[i + 1]
        n = max(int(math.ceil(np.linalg.norm(b - a) / step)), 1)
        out.extend(a + (b - a) * (t / n) for t in range(n))
    return _dedupe(np.asarray(out, dtype=np.float64))


def _signed_area(poly: np.ndarray) -> float:
    nxt = np.roll(poly, -1, axis=0)
    return 0.5 * float(np.sum(poly[:, 0] * nxt[:, 1] - nxt[:, 0] * poly[:, 1]))


def _curvature(poly: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Smoothed signed curvature and per-vertex arc length.

    The turning angle is measured across a +/-WINDOW sample span and divided by
    that span's arc length, so kappa is 1/R in px^-1 regardless of how densely
    the outline happens to be sampled.  A raw 3-point difference divided by one
    edge length is off by 2x and explodes on duplicate points, which is what
    made every shape look like a pile of corners.
    """
    n = len(poly)
    prev = poly - np.roll(poly, WINDOW, axis=0)
    nxt = np.roll(poly, -WINDOW, axis=0)
    arc = np.linalg.norm(prev, axis=1) + np.linalg.norm(nxt, axis=1)
    a1 = np.arctan2(prev[:, 1], prev[:, 0])
    a2 = np.arctan2(nxt[:, 1], nxt[:, 0])
    turn = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
    kappa = turn / np.maximum(arc, 1e-9)
    if SMOOTH > 1:                       # circular box blur, keeps the ends honest
        kernel = np.ones(SMOOTH) / SMOOTH
        padded = np.concatenate([kappa[-SMOOTH:], kappa, kappa[:SMOOTH]])
        kappa = np.convolve(padded, kernel, mode="same")[SMOOTH:-SMOOTH]
    return kappa, arc


def _convex_hull(points: np.ndarray) -> np.ndarray:
    """Andrew's monotone chain.  Orientation-free, so no winding convention to
    get wrong - which is what sank two earlier attempts at this measurement."""
    pts = np.unique(np.round(points, 4), axis=0)
    pts = pts[np.lexsort((pts[:, 1], pts[:, 0]))]
    if len(pts) < 3:
        return pts

    def build(seq):
        out: list[np.ndarray] = []
        for p in seq:
            while len(out) >= 2:
                a, b = out[-2], out[-1]
                if (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) > 0:
                    break
                out.pop()
            out.append(p)
        return out

    lower = build(pts)
    upper = build(pts[::-1])
    return np.asarray(lower[:-1] + upper[:-1], dtype=np.float64)


def _on_hull(points: np.ndarray, hull: np.ndarray, tol: float) -> np.ndarray:
    """Per-vertex flag: is this outline vertex ON the convex hull?

    "On" means within `tol` of the hull boundary, not merely inside it.  A
    contour traced from pixels sits about half a pixel inside its own hull, so
    a potato has to count as all-hull or nothing ever registers.
    """
    n, m = len(points), len(hull)
    if m < 3:
        return np.ones(n, dtype=bool)
    area = float(np.sum(hull[:, 0] * np.roll(hull[:, -1], 1) - np.roll(hull[:, 0], 1) * hull[:, 1]))
    ref = 1.0 if area > 0 else -1.0
    depth = np.full(n, np.inf)
    for k in range(m):
        a, b = hull[k], hull[(k + 1) % m]
        edge = b - a
        length = float(np.linalg.norm(edge))
        if length < 1e-9:
            continue
        # inward normal, whichever way this hull happens to be wound
        normal = np.array([edge[1], -edge[0]]) / length * ref
        signed = (points - a) @ normal
        depth = np.minimum(depth, signed)
    return depth <= tol


def _notch_runs(points: np.ndarray, tol: float) -> tuple[int, float]:
    """(count of inward landmark runs, share of perimeter off the hull).

    A potato has zero runs and zero off-hull share.  Every neck notch, waist
    pinch, cleft between toes and gap between plumes is one run.  This is the
    measure the whole project actually cares about: how far a silhouette departs
    from a smooth blob, and in how many separate places.
    """
    hull = _convex_hull(points)
    if len(hull) < 3:
        return 0, 0.0
    off_tol = max(tol, HULL_TOL)
    off = _on_hull(points, hull, off_tol)
    closed = np.concatenate([off, off[:1]])
    runs, i, total = 0, 0, len(points)
    while i < total:
        if not closed[i]:
            j = i
            while j < total and not closed[j]:
                j += 1
            if j - i >= CONCAVE_MIN_SAMPLES:
                runs += 1
            i = j
        else:
            i += 1
    share = 1.0 - float(off.sum()) / float(total)
    return runs, share


def _concavity(poly: np.ndarray) -> int:
    """Number of inward landmark runs - the G2 silhouette-read gate."""
    return _notch_runs(poly, tol=0.0)[0]


def silhouette_deviation(poly: np.ndarray) -> float:
    """Share of the outline that is not on its own convex hull, 0..1."""
    if len(poly) < 8:
        return 0.0
    return _notch_runs(poly, tol=0.0)[1]


def _min_radius(poly: np.ndarray) -> float:
    """Tightest sustained bend, in px.  Informational: a fang tip is tight on
    purpose and does not read as a corner."""
    kappa, _ = _curvature(poly)
    k = np.abs(kappa)
    k = k[k > 1e-9]
    if not len(k):
        return math.inf
    return float(1.0 / np.percentile(k, 99.5))


def _sharp_fraction(poly: np.ndarray) -> float:
    """Share of the outline bent tighter than MIN_RADIUS_GATE.

    This is the real "no angular shapes" test.  A silhouette that is tight
    everywhere looks faceted; one that is tight over a few percent of its
    perimeter has deliberate points (a fang, a toe, a crest) and still reads as
    a drawn curve.  Gating on the tightest radius alone rejects every fang.
    """
    kappa, arc = _curvature(poly)
    tight = np.abs(kappa) > (1.0 / MIN_RADIUS_GATE)
    return float(arc[tight].sum() / max(arc.sum(), 1e-9))


def _near_outline(poly: np.ndarray, p, tol: float = 1.2) -> bool:
    """Inside the silhouette, treating a point within `tol` px of the edge as
    inside.  A joint authored exactly on the boundary is not a defect."""
    if _point_in(poly, p):
        return True
    d = np.min(np.hypot(poly[:, 0] - p[0], poly[:, 1] - p[1]))
    return float(d) <= tol


# --------------------------------------------------------------- baked output
def trace_mask(mask: np.ndarray, seed: tuple[int, int] | None = None) -> np.ndarray:
    """Ordered boundary of a binary mask by Moore-neighbour tracing.

    Marching squares looked like the right tool and is not: on an antialiased
    sprite a 1px leg makes the contour touch itself, the segment chain shatters
    into hundreds of fragments, and the measurement is meaningless.  Walking the
    boundary pixel by pixel just works, including on thin parts and holes (the
    outer loop is the longest).
    """
    h, w = mask.shape
    if not mask.any():
        return np.zeros((0, 2))

    def solid(x, y):
        return 0 <= x < w and 0 <= y < h and bool(mask[y, x])

    ring = ((1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1))

    def walk(start: tuple[int, int]) -> np.ndarray:
        b_idx = 4 if not solid(start[0] - 1, start[1]) else 6
        cur = start
        first_dir = None
        pts: list[tuple[float, float]] = []
        guard = 0
        limit = 8 * (w + h) + 64
        while guard < limit:
            guard += 1
            # A FULL revolution, backtrack slot included.  Stopping one step
            # short makes a 1px spur - a needle-thin horn or a tail barb after
            # the 40px downscale - look like a sealed island, the trace gives
            # up, and the whole silhouette scores as a blob.  Every batch that
            # used a needle-tipped part hit this and wrongly banned the part.
            a, found = (b_idx + 1) % 8, False
            for step in range(8):
                k = (b_idx + 1 + step) % 8
                if solid(cur[0] + ring[k][0], cur[1] + ring[k][1]):
                    a, found = k, True
                    break
            if not found:
                return np.zeros((0, 2))
            nxt = (cur[0] + ring[a][0], cur[1] + ring[a][1])
            if first_dir is None:
                first_dir = a
            elif nxt == start and a == first_dir:
                break
            pts.append((nxt[0] + 0.5, nxt[1] + 0.5))
            cur = nxt
            b_idx = (a + 4) % 8
        return np.asarray(pts, dtype=np.float64)

    # Seed from the body's widest row, not the first pixel in scan order: a
    # stray 1px speck above the animal would otherwise be traced on its own and
    # the real outline never measured.  Then try a few more seeds and keep the
    # longest loop, so a speck or an interior hole cannot win.
    counts = mask.sum(axis=1)
    rows = np.argsort(-counts)[:6]
    seeds: list[tuple[int, int]] = []
    for y in rows:
        xs = np.flatnonzero(mask[y])
        if len(xs):
            seeds.append((int(xs[0]), int(y)))
    ys, xs_all = np.where(mask)
    step = max(len(ys) // 8, 1)
    for i in range(0, len(ys), step):
        seeds.append((int(xs_all[i]), int(ys[i])))

    if seed is not None:
        seeds = [seed]
    best = np.zeros((0, 2))
    for seed in seeds:
        loop = walk(seed)
        if len(loop) > len(best):
            best = loop
        if len(best) > 2 * (h + w):
            break
    return best


def contour_of(field: np.ndarray, level: float = 0.5) -> np.ndarray:
    """Largest closed contour of a scalar field."""
    mask = field > level
    return trace_mask(mask)

def _interior_seeds(mask: np.ndarray, boundary: np.ndarray, limit: int = 12) -> list:
    """Pixels well inside the shape - seeds for hunting holes.

    Kept because hole-hunting is worth having, but NOT wired into the gate.
    Seeding a Moore trace from an interior pixel does not reliably find a hole:
    a pixel with no solid neighbour returns an empty loop, and one adjacent to
    the rim walks the outer boundary instead.  Counting those as holes reported
    three "holes" in nineteen creatures that plainly have none, which is worse
    than having no check at all.  Until it is calibrated against shapes with
    known holes, holes are judged by eye on the contact sheet.
    """
    if len(boundary) < 8:
        return []
    band = np.zeros(mask.shape, dtype=bool)
    xs = np.clip(boundary[:, 0].astype(int), 0, mask.shape[1] - 1)
    ys = np.clip(boundary[:, 1].astype(int), 0, mask.shape[0] - 1)
    band[ys, xs] = True
    for _ in range(3):
        grown = band.copy()
        grown[1:, :] |= band[:-1, :]
        grown[:-1, :] |= band[1:, :]
        grown[:, 1:] |= band[:, :-1]
        grown[:, :-1] |= band[:, 1:]
        band = grown
    ys, xs = np.where(mask & ~band)
    if not len(ys):
        return []
    out, step = [], max(len(ys) // limit, 1)
    for i in range(0, len(ys), step):
        out.append((int(xs[i]), int(ys[i])))
    return out


def _hole_count(canvas, outer: np.ndarray) -> int:
    """How many enclosed holes the finished silhouette has."""
    mask = canvas.px[:, :, 3] > 0.5
    if mask.sum() < 40:
        return 0
    outer_area = abs(_signed_area(outer)) if len(outer) >= 3 else 0.0
    if outer_area <= 0:
        return 0
    holes = 0
    for seed in _interior_seeds(mask, outer):
        loop = trace_mask(mask, seed)
        if len(loop) < 10:
            continue
        area = abs(_signed_area(loop))
        if 0.01 * outer_area < area < 0.45 * outer_area:
            holes += 1
            if holes >= 3:
                break
    return holes


def silhouette_report(canvas, small: int = 40) -> dict:
    """Readability of the FINISHED sprite, at full size and shrunk to `small`.

    A creature that only reads at full size is a blob.  Shrinking it to 40px
    and re-running the concavity test is the closest machine equivalent of
    "squint at it from across the room".
    """
    from PIL import Image
    alpha = canvas.px[:, :, 3]
    out = {"used": list(canvas.used_rect())}
    poly = _smooth_closed(contour_of(alpha, 0.5))
    if len(poly) < 8:
        out["error"] = "empty silhouette"
        return out
    out["concave_1x"] = _concavity(_resample(poly))
    out["dev_1x"] = round(silhouette_deviation(_resample(poly)), 3)
    img = canvas.to_image()
    factor = small / max(img.height, 1)
    small_img = img.resize((max(int(img.width * factor), 4), small), Image.Resampling.LANCZOS)
    small_poly = _smooth_closed(
        contour_of(np.asarray(small_img.split()[3], dtype=np.float32) / 255.0, 0.5))
    if len(small_poly) >= 8:
        out["concave_small"] = _concavity(_resample(small_poly))
        out["dev_small"] = round(silhouette_deviation(_resample(small_poly)), 3)
    else:
        out["concave_small"] = 0
        out["dev_small"] = 0.0
    out["fill_ratio"] = round(float((alpha > 0.5).mean()), 3)
    return out


SILHOUETTE_GATE = 3       # inward landmarks the whole creature must keep at 40px
SILHOUETTE_DEV = 0.06     # share of the outline that must sit off its own hull
SILHOUETTE_FILL = 0.12    # below this the sprite is mostly empty canvas


def _straight_fraction(path_d: str) -> float:
    straight = total = 0.0
    for contour in parse_path(path_d):
        pts = np.asarray(contour)
        if len(pts) < 3:
            continue
        lengths = np.linalg.norm(np.diff(np.vstack([pts, pts[:1]]), axis=0), axis=1)
        total += float(lengths.sum())
        straight += float(lengths.sum())
    return 1.0 if total <= 0 else straight / total


def _point_in(poly: np.ndarray, p) -> bool:
    x, y = float(p[0]), float(p[1])
    inside = False
    n = len(poly)
    for i in range(n):
        x0, y0 = poly[i]
        x1, y1 = poly[(i + 1) % n]
        if (y0 > y) != (y1 > y):
            xi = x0 + (y - y0) / (y1 - y0) * (x1 - x0)
            if x < xi:
                inside = not inside
    return inside


def measure(path: Path) -> dict:
    data = read_svg(path)
    out = {"name": path.stem, "file": str(path), "errors": []}
    try:
        from .svgpath import parse_joints
        joints = parse_joints(data["meta"])
    except SvgError as exc:
        out["errors"].append(str(exc))
        joints = np.zeros((1, 2))
    out["spine_points"] = int(len(joints))

    poly = np.concatenate([np.asarray(c) for c in data["contours"]], axis=0)
    res = _resample(poly)
    out["concave"] = _concavity(res)
    out["min_radius"] = round(_min_radius(res), 2)
    out["sharp"] = round(_sharp_fraction(res), 3)
    xs = poly[:, 0]
    ys = poly[:, 1]
    out["width"] = round(float(xs.max() - xs.min()), 1)
    out["height"] = round(float(ys.max() - ys.min()), 1)
    out["detail"] = str(data["meta"].get("detail", "0")) not in ("", "0", "false")

    dx = np.diff(joints[:, 0])
    out["spine_monotone"] = bool(len(dx) == 0 or np.all(dx > -1e-6))
    out["spine_inside"] = all(_near_outline(poly, j) for j in joints)
    out["spine_length"] = round(float(np.linalg.norm(np.diff(joints, axis=0), axis=1).sum()), 1)

    # Hard gates.  Small overlay parts (eyes) are lenses by definition, so the
    # concavity gate does not apply to them or to anything under 26px wide.
    big = out["width"] >= 26 and not out["detail"]
    if big and out["concave"] < 2:
        out["errors"].append(f"G2 concave={out['concave']} < 2 (shape is a blob)")
    if out["sharp"] > SHARP_GATE:
        out["errors"].append(f"G8 sharp={out['sharp']} > {SHARP_GATE} (faceted outline)")
    if out["spine_points"] < 2:
        out["errors"].append("spine needs 2+ points")
    if not out["spine_monotone"]:
        out["errors"].append("spine is not monotone in +X")
    if not out["spine_inside"]:
        out["errors"].append("spine point falls outside the silhouette")
    out["ok"] = not out["errors"]
    return out


def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    as_json = "--json" in argv
    argv = [a for a in argv if not a.startswith("--")]
    root = Path(__file__).resolve().parent.parent
    lib = ShapeLibrary([root / "shapes"])
    if argv:
        rows = []
        for name in argv:
            src = lib.sources.get(name)
            if not src:
                rows.append({"name": name, "file": "", "errors": ["not in library"],
                             "ok": False, "concave": 0, "min_radius": 0})
                continue
            rows.append(measure(Path(src)))
    else:
        rows = [measure(Path(lib.sources[n])) for n in lib.names()]

    if as_json:
        print(json.dumps(rows, indent=2))
        return 0 if all(r["ok"] for r in rows) else 1

    print(f"{'shape':20s} {'conc':>4s} {'minrad':>7s} {'sharp':>6s} {'w':>6s} {'h':>6s} {'sp':>3s}  status")
    for r in rows:
        status = "ok" if r["ok"] else "; ".join(r["errors"])
        print(f"{r['name']:20s} {r.get('concave', 0):4d} {r.get('min_radius', 0):7.2f} {r.get('sharp', 0):6.3f} "
              f"{r.get('width', 0):6.1f} {r.get('height', 0):6.1f} "
              f"{r.get('spine_points', 0):3d}  {status}")
    bad = [r for r in rows if not r["ok"]]
    print(f"\n{len(rows) - len(bad)}/{len(rows)} pass")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
