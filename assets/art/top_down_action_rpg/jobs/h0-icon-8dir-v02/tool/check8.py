"""Consistency check for 8-direction cells: height, head size, feet, outline, light.

    py -3 -B check8.py player enemy_ash_hound

For the standing frame (column 1) of every direction it measures
    top / bottom       painted bounds (alpha > 0.1); bottom = lowest foot
    head w x h         bounds of the forms tagged "head" rendered alone
    outline            mean luminance of the outermost 2 px of the silhouette
    light              direction from the silhouette centre to the luminance-weighted
                       centre of a render with every form in ONE material (so the
                       colour layout cannot bias it); should point up-left in all 8
and for all 3 columns the lowest foot, so a step that leaves the cell shows.
It also fails if a view recipe overrides light / line / silhouette / style.
Writes preview/<asset>_consistency.json.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build import JOB  # noqa: E402
from iconkit.render import Renderer, load_recipe  # noqa: E402
from iconkit.walk8 import SHEETS, frame_recipe, view_frames  # noqa: E402

ORDER = SHEETS["base"] + SHEETS["diag"]
FORBIDDEN = ("light", "style_override", "supersample")


def bounds(alpha: np.ndarray, thr: float = 0.1):
    ys, xs = np.nonzero(alpha > thr)
    return (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1) if len(xs) else None


def erode(mask: np.ndarray, n: int) -> np.ndarray:
    m = mask.copy()
    for _ in range(n):
        p = np.pad(m, 1)
        m = m & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]
    return m


def measure(img: Image.Image) -> dict:
    a = np.asarray(img, dtype=np.float32) / 255.0
    alpha, rgb = a[..., 3], a[..., :3]
    lum = rgb @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    solid = alpha > 0.5
    edge = solid & ~erode(solid, 2)
    ys, xs = np.nonzero(solid)
    wts = lum[solid] - lum[solid].mean()
    pos = wts.clip(min=0)
    cx, cy = xs.mean(), ys.mean()
    lx = (xs * pos).sum() / pos.sum() - cx
    ly = (ys * pos).sum() / pos.sum() - cy
    b = bounds(alpha)
    return {"top": b[1], "bottom": b[3], "left": b[0], "right": b[2], "height": b[3] - b[1],
            "outline_lum": round(float(lum[edge].mean()), 3),
            "light_deg": round(math.degrees(math.atan2(ly, lx)), 1)}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("assets", nargs="+")
    ap.add_argument("--out", type=Path, default=JOB / "output")
    ap.add_argument("--preview", type=Path, default=JOB / "preview")
    args = ap.parse_args()
    renderer = Renderer()
    ok = True
    for asset in args.assets:
        recipes = [r for r in (load_recipe(p) for p in sorted((JOB / "recipes").glob("*.json")))
                   if r.get("asset") == asset and "view" in r]
        problems = [f"{Path(r['_path']).name}: overrides {k}" for r in recipes for k in FORBIDDEN if k in r]
        styles = {r.get("style", "sprite") for r in recipes} | {r["palette"] for r in recipes}
        if len(styles) != 2:
            problems.append(f"views use different style/palette: {sorted(styles)}")
        rows = {}
        for recipe in recipes:
            head_forms = [f["name"] for f in recipe["forms"] if "head" in f.get("tags", [])]
            others = [f["name"] for f in recipe["forms"] if f["name"] not in head_forms]
            flat = [f["name"] for f in recipe["forms"] if f.get("kind") in ("flat", "wash", "shadow")]
            for frame in view_frames(recipe):
                if frame["col"] != 1:
                    continue
                view = frame["view"]
                row = measure(Image.open(args.out / asset / f"{frame['name']}.png").convert("RGBA"))
                hf = dict(frame, hide=others)
                head = renderer.render(frame_recipe(recipe, hf), hf)["image"]
                hb = bounds(np.asarray(head, dtype=np.float32)[..., 3] / 255.0)
                row["head_w"], row["head_h"] = hb[2] - hb[0], hb[3] - hb[1]
                # light: same geometry painted in ONE material, so colour layout cannot bias it
                lf = dict(frame, hide=flat, materials={"upper": "coat", "legs": "coat"})
                row["light_deg"] = measure(renderer.render(frame_recipe(recipe, lf), lf)["image"])["light_deg"]
                row["lowest_foot_all_cols"] = max(
                    bounds(np.asarray(Image.open(args.out / asset / f"{view}_{c}.png"), dtype=np.float32)[..., 3] / 255.0)[3]
                    for c in (0, 1, 2))
                rows[view] = row
        table = [dict(direction=v, **rows[v]) for v in ORDER if v in rows]
        size = Image.open(args.out / asset / "down_1.png").size
        spread = {k: [min(r[k] for r in table), max(r[k] for r in table)]
                  for k in ("top", "bottom", "height", "head_w", "head_h", "outline_lum", "light_deg")}
        clipped = [r["direction"] for r in table if r["lowest_foot_all_cols"] >= size[1] or r["top"] <= 0]
        if clipped:
            problems.append(f"touches the cell edge: {clipped}")
        report = {"asset": asset, "cell": list(size), "rows": table, "spread": spread, "problems": problems}
        path = args.preview / f"{asset}_consistency.json"
        path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(f"\n{asset}  cell {size}  -> {path.name}")
        print(f"{'direction':11} top bot  hgt  headWxH  outline light  lowest(any col)")
        for r in table:
            print(f"{r['direction']:11} {r['top']:3} {r['bottom']:3} {r['height']:4} {r['head_w']:4}x{r['head_h']:<3}"
                  f" {r['outline_lum']:6} {r['light_deg']:6}  {r['lowest_foot_all_cols']}")
        print("spread", json.dumps(spread))
        for p in problems:
            print("PROBLEM", p)
        ok = ok and not problems
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
