"""Build 8-direction view recipes into RPG Maker style cells.  Resumable.

    py -3 -B build8.py --all                              # every recipe that has a "view"
    py -3 -B build8.py ../recipes/player_down_left.json   # one view (+ its mirrored view)
    py -3 -B build8.py --all --asset player --force

Per cell: output/<asset>/<direction>_<column>.png  (column 0 = left foot forward,
1 = standing, 2 = right foot forward), <direction>_<column>_shadow.png (contact
shadow layer) and <direction>_<column>.json (manifest).  A cell whose manifest
build key matches recipe + palette + tool code + frame is skipped, so an
interrupted run can be started again.  Then run export_sheet8.py.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build import JOB, build_key, rel, resolved_blob  # noqa: E402
from iconkit.render import TOOL_VERSION, Renderer, load_json, load_recipe, tool_source_hash  # noqa: E402
from iconkit.walk8 import COLUMN_MEANING, DIRECTIONS, WALK_PATTERN, frame_recipe, sheet_slot, view_frames  # noqa: E402


def view_recipes(paths: list[Path]) -> list[dict]:
    out = []
    for path in paths:
        recipe = load_recipe(path)
        if "view" in recipe and "canvas" in recipe:
            out.append(recipe)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("recipes", nargs="*", type=Path)
    ap.add_argument("--all", action="store_true", help="every view recipe in ../recipes")
    ap.add_argument("--asset", default="", help="only recipes of this asset")
    ap.add_argument("--views", default="", help="comma separated directions to build (after mirroring)")
    ap.add_argument("--cols", default="", help="comma separated columns to build, e.g. 1")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--out", type=Path, default=JOB / "output")
    args = ap.parse_args()

    paths = list(args.recipes)
    if args.all:
        paths = sorted((JOB / "recipes").glob("*.json"))
    recipes = [r for r in view_recipes(paths) if not args.asset or r.get("asset") == args.asset]
    if not recipes:
        ap.error("no view recipes given (a view recipe has a \"view\" key)")
    want_views = {v.strip() for v in args.views.split(",") if v.strip()}
    want_cols = {int(c) for c in args.cols.split(",") if c.strip()}
    tool_hash = tool_source_hash()
    renderer = Renderer()
    args.out.mkdir(parents=True, exist_ok=True)
    log = args.out / "build_log.txt"
    built = skipped = 0
    for recipe in recipes:
        asset = recipe["asset"]
        out_dir = args.out / asset
        out_dir.mkdir(parents=True, exist_ok=True)
        for frame in view_frames(recipe):
            if (want_views and frame["view"] not in want_views) or (want_cols and frame["col"] not in want_cols):
                continue
            name = frame["name"]
            png, man = out_dir / f"{name}.png", out_dir / f"{name}.json"
            fr = frame_recipe(recipe, frame)
            key = build_key(fr, frame, tool_hash)
            if not args.force and png.exists() and man.exists() and load_json(man).get("build_key") == key:
                skipped += 1
                print(f"skip  {asset}/{name}")
                continue
            t0 = time.time()
            result = renderer.render(fr, frame)
            result["image"].save(png)
            shadow_png = out_dir / f"{name}_shadow.png"
            shadow_name = None
            if result["shadow"] is not None:
                result["shadow"].save(shadow_png)
                shadow_name = shadow_png.name
            elif shadow_png.exists():
                shadow_png.unlink()
            seconds = round(time.time() - t0, 2)
            sheet, row = sheet_slot(frame["view"])
            manifest = {
                "asset": asset,
                "frame": name,
                "direction": frame["view"],
                "direction_code": DIRECTIONS[frame["view"]]["code"],
                "column": frame["col"],
                "column_meaning": COLUMN_MEANING[frame["col"]],
                "walk_pattern": list(WALK_PATTERN),
                "sheet": sheet,
                "sheet_row": row,
                "status": "candidate",
                "approval": "not approved - only the user approves",
                "file": png.name,
                "size": list(result["image"].size),
                "alpha": True,
                "pivot": result["pivot"],
                "pivot_meaning": recipe.get("pivot_meaning", "ground contact point"),
                "shadow_file": shadow_name,
                "mirror": bool(frame.get("mirror", False)),
                "mirrored_from": frame.get("mirrored_from"),
                "recipe": rel(Path(recipe["_path"])),
                "recipe_sha256": hashlib.sha256(resolved_blob(recipe)).hexdigest(),
                "palette": recipe["palette"],
                "style": recipe.get("style", "sprite"),
                "tool_version": TOOL_VERSION,
                "build_key": key,
                "icon_kinds": len(result["icons"]),
                "icon_instances": result["instances"],
                "icons": result["icons"],
                "icon_source": "addons/at-icons/node2d (MIT, Valentin Fossati & contributors)",
                "rendered_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                "render_seconds": seconds,
            }
            man.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
            with log.open("a", encoding="utf-8") as fh:
                fh.write(f"{manifest['rendered_at']} built {asset}/{name} {manifest['size']} {seconds}s\n")
            built += 1
            print(f"built {asset}/{name} {manifest['size']} in {seconds}s")
    print(f"done: built {built}, skipped {skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
