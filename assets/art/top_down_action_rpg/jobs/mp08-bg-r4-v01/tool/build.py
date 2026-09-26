"""Build iconkit recipes into PNGs. Resumable: finished frames are skipped.

    py -3 -B build.py ../recipes/player_front.json            # one recipe
    py -3 -B build.py --all                                   # every recipe in ../recipes
    py -3 -B build.py ../recipes/player_front.json --frames idle_down --force

Output per frame: output/<asset>/<frame>.png (+ <frame>_shadow.png when the
recipe has contact-shadow forms, + <frame>_emit.png when it has emissive forms)
and <frame>.json (manifest: status, size,
pivot, icons used with SHA-256, recipe hash, build key).  A frame whose
manifest build key matches the current recipe + palette + tool code is skipped,
so an interrupted run can simply be started again.  Progress is appended to
output/build_log.txt.
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
from iconkit.render import TOOL_VERSION, Renderer, load_json, load_recipe, palette_bytes, tool_source_hash  # noqa: E402

JOB = Path(__file__).resolve().parents[1]
SKIP_PREFIXES = ("_", "palette_", "scene_")


def resolved_blob(recipe: dict) -> bytes:
    data = {k: v for k, v in recipe.items() if not k.startswith("_")}
    return json.dumps(data, sort_keys=True, ensure_ascii=False).encode("utf-8")


def build_key(recipe: dict, frame: dict, tool_hash: str) -> str:
    palette = palette_bytes(recipe["_dir"], recipe["palette"])  # mp08: include extended base palettes
    blob = resolved_blob(recipe) + palette + json.dumps(frame, sort_keys=True).encode() + tool_hash.encode()
    return hashlib.sha256(blob).hexdigest()


def rel(path: Path) -> str:
    try:
        return path.resolve().relative_to(JOB).as_posix()
    except ValueError:
        return str(path)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("recipes", nargs="*", type=Path)
    ap.add_argument("--all", action="store_true", help="build every recipe in ../recipes")
    ap.add_argument("--force", action="store_true", help="rebuild even if up to date")
    ap.add_argument("--frames", default="", help="comma separated frame names to build")
    ap.add_argument("--out", type=Path, default=JOB / "output")
    args = ap.parse_args()

    paths = list(args.recipes)
    if args.all:
        paths = [p for p in sorted((JOB / "recipes").glob("*.json")) if not p.name.startswith(SKIP_PREFIXES)]
    if not paths:
        ap.error("give recipe paths or --all")
    wanted = {f.strip() for f in args.frames.split(",") if f.strip()}
    tool_hash = tool_source_hash()
    renderer = Renderer()
    args.out.mkdir(parents=True, exist_ok=True)
    log = args.out / "build_log.txt"
    built = skipped = 0
    for path in paths:
        recipe = load_recipe(path)
        if "canvas" not in recipe:
            continue
        asset = recipe.get("asset", path.stem)
        frames = recipe.get("frames") or [{"name": asset}]
        for frame in frames:
            name = frame["name"]
            if wanted and name not in wanted:
                continue
            out_dir = args.out / asset
            out_dir.mkdir(parents=True, exist_ok=True)
            png, man = out_dir / f"{name}.png", out_dir / f"{name}.json"
            key = build_key(recipe, frame, tool_hash)
            if not args.force and png.exists() and man.exists() and load_json(man).get("build_key") == key:
                skipped += 1
                print(f"skip  {asset}/{name}")
                continue
            t0 = time.time()
            result = renderer.render(recipe, frame)
            result["image"].save(png)
            shadow_name = None
            shadow_png = out_dir / f"{name}_shadow.png"
            if result["shadow"] is not None:
                result["shadow"].save(shadow_png)
                shadow_name = shadow_png.name
            elif shadow_png.exists():
                shadow_png.unlink()
            emit_name = None
            emit_png = out_dir / f"{name}_emit.png"
            if result.get("emit") is not None:
                result["emit"].save(emit_png)
                emit_name = emit_png.name
            elif emit_png.exists():
                emit_png.unlink()
            seconds = round(time.time() - t0, 2)
            manifest = {
                "asset": asset,
                "frame": name,
                "status": "candidate",
                "approval": "not approved - only the user approves",
                "file": png.name,
                "size": list(result["image"].size),
                # mp08: read alpha from the pixels (a transparent foreground can use the environment style)
                "alpha": result["image"].mode == "RGBA" and result["image"].getchannel("A").getextrema()[0] < 255,
                "pivot": result["pivot"],
                "pivot_meaning": recipe.get("pivot_meaning", "ground contact point"),
                "shadow_file": shadow_name,
                "emit_file": emit_name,
                "mirror": bool(frame.get("mirror", False)),
                "recipe": rel(path),
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
                fh.write(f"{manifest['rendered_at']} built {asset}/{name} {manifest['size']} "
                         f"{seconds}s icons={manifest['icon_kinds']}/{manifest['icon_instances']}\n")
            built += 1
            print(f"built {asset}/{name} {manifest['size']} in {seconds}s")
    print(f"done: built {built}, skipped {skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
