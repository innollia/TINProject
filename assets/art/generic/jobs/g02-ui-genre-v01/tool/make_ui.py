"""Write g02 genre 9-slice window-frame recipes (192x192, 48 px corners) into ../recipes/.

    py -3 -B make_ui.py [--only id] [--tier A] [--build]

Rules (09 §12.7 + GENERIC.md): no text, dark translucent inside, strong dark
ink structure line.  Everything that is not a corner ornament is uniform along
its edge, so the four edges can be stretched (or tiled) and the centre filled.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
UIS = {}
S, M = 192, 48          # canvas, 9-slice margin
C = S / 2.0


def P(icon, x, y, w, h=None, **kw):
    p = {"icon": icon, "at": [float(x), float(y)], "size": [w, h] if h is not None else w}
    p.update(kw)
    return p


def F(name, z, pieces, mat=None, **kw):
    f = {"name": name, "z": z, "pieces": pieces}
    if mat:
        f["material"] = mat
    f.update(kw)
    return f


def ui(uid, tier, name, genre, seed=1):
    def deco(fn):
        UIS[uid] = {"tier": tier, "name": name, "genre": genre, "seed": seed, "fn": fn}
        return fn
    return deco


def corners(icon, inset, w, h=None, **kw):
    """The same ornament in the four corners (mirrored); ``inset`` = px or (x, y) from the canvas edge."""
    h = h or w
    ix, iy = inset if isinstance(inset, (list, tuple)) else (inset, inset)
    out = []
    for fx, fy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        flip = ("x" if fx else "") + ("y" if fy else "")
        out.append(P(icon, S - ix if fx else ix, S - iy if fy else iy, w, h, flip=flip or None, **kw))
    return out


def ring(icon, outer, inner, **kw):
    return [P(icon, C, C, outer, outer, **kw), P(icon, C, C, inner, inner, op="sub", **kw)]


CHAMFER = [[3, 1], [13, 1], [15, 3], [15, 13], [13, 15], [3, 15], [1, 13], [1, 3]]


@ui("ui_mo_panel", "A", "현대 알림 창틀", "현대·도시", seed=401)
def _():
    return [F("fill", 0, [P("square", C, C, 176, 176)], None, kind="flat", color="#1d1b23", opacity=0.88),
            F("rim", 1, ring("square", 184, 170), "iron_dark", shade={"bump": 0.4}),
            F("inner_line", 2, ring("square", 164, 161), "chrome", kind="flat", opacity=0.45),
            F("top_sheen", 1.5, [P("square", C, 20, 150, 10)], None, kind="flat", color="white_ink", opacity=0.06),
            F("status_dot", 3, [P("circle", 24, 24, 7, 7)], "neon_cyan", kind="flat", emit=0.9),
            F("status_ring", 2.9, [P("circle", 24, 24, 12, 12)], "iron", kind="flat", opacity=0.8)]


@ui("ui_sf_panel", "A", "SF 홀로 창틀", "SF·우주", seed=402)
def _():
    return [F("fill", 0, [P("square", C, C, 178, 178, poly=CHAMFER, fit="box")], None, kind="flat", color="#141c26", opacity=0.84),
            F("rim", 1, [P("square", C, C, 186, 186, poly=CHAMFER, fit="box"), P("square", C, C, 172, 172, poly=CHAMFER, fit="box", op="sub")],
              "iron_dark"),
            F("line_outer", 2, [P("square", C, C, 170, 170, poly=CHAMFER, fit="box"), P("square", C, C, 167, 167, poly=CHAMFER, fit="box", op="sub")],
              "neon_cyan", kind="flat", opacity=0.75, emit=0.6),
            F("line_inner", 2, [P("square", C, C, 158, 158, poly=CHAMFER, fit="box"), P("square", C, C, 156, 156, poly=CHAMFER, fit="box", op="sub")],
              "neon_cyan", kind="flat", opacity=0.3, emit=0.3),
            F("brackets", 3, corners("square", (30, 6), 20, 6) + corners("square", (6, 30), 6, 20), "neon_cyan", kind="flat", emit=0.9,
              glow={"radius": 2.5, "opacity": 0.4, "color": "neon_glow_c"}),
            F("pips", 3, [P("circle", 36, 10, 4, 4), P("circle", 44, 10, 4, 4)], "neon_amber", kind="flat", emit=0.8)]


@ui("ui_we_panel", "A", "서부 나무판 창틀", "서부", seed=403)
def _():
    grain_h = {"stamp": "pill", "pre_rot": -45, "length": 30, "width": 2.2, "angle": 0, "jitter": 3, "density": 0.9, "strength": 0.16}
    grain_v = dict(grain_h, angle=90)
    return [F("fill", 0, [P("square", C, C, 170, 170)], None, kind="flat", color="#1f1914", opacity=0.9),
            F("plank_top", 1, [P("square", C, 12, 188, 22), P("square", C, 180, 188, 22)], "wood", texture=grain_h),
            F("plank_side", 0.9, [P("square", 12, C, 22, 188), P("square", 180, C, 22, 188)], "wood", texture=grain_v),
            F("gap", 1.5, [P("square", C, 23.5, 150, 1.6), P("square", C, 168.5, 150, 1.6), P("square", 23.5, C, 1.6, 150),
                           P("square", 168.5, C, 1.6, 150)], None, kind="flat", color="coat_seam", opacity=0.8),
            F("brackets", 2, corners("square", 14, 26, 26), "iron", shade={"bump": 0.5}),
            F("nails", 3, corners("circle", 9, 6, 6) + corners("circle", 20, 5, 5), "iron_dark")]



def recipe(uid, meta):
    return {"asset": uid, "status": "candidate",
            "note": f"{meta['name']} ({meta['genre']}, tier {meta['tier']}). 9-slice window frame, margins {M} px, no text.",
            "palette": "palette_g02.json", "style": "prop", "style_override": {"cast": {"opacity": 0.0}},
            "canvas": [S, S], "pivot": [0, 0], "pivot_meaning": "top-left; 9-slice margins in <id>_9slice.json",
            "seed": meta["seed"], "forms": meta["fn"]()}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", default="")
    ap.add_argument("--tier", default="")
    ap.add_argument("--build", action="store_true")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    written = []
    for uid, meta in UIS.items():
        if (only and uid not in only) or (args.tier and meta["tier"] not in args.tier):
            continue
        path = JOB / "recipes" / f"{uid}.json"
        path.write_text(json.dumps(recipe(uid, meta), ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        written.append(path)
    print(f"wrote {len(written)} ui recipes")
    if args.build and written:
        rc = subprocess.call([sys.executable, "-B", str(Path(__file__).with_name("build.py")), *map(str, written)])
        if rc:
            return rc
        ids = [p.stem for p in written]
        return subprocess.call([sys.executable, "-B", str(Path(__file__).with_name("ui_slice.py")), *ids])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
