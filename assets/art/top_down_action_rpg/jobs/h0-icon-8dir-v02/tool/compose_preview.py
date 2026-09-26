"""Compose built assets into a game-screen preview from a scene JSON.

    py -3 -B compose_preview.py ../recipes/scene_h0_preview.json

Scene:
    {"background": "output/<asset>/<frame>.png",      # source-resolution background
     "scale": 0.5,                                     # source px -> preview px
     "items": [{"asset": "...", "frame": "...", "at": [x, y], "layer": "floor|world"}],
     "out": "preview/<name>.png", "full_out": "preview/<name>_source.png"}

``at`` is the pixel of the background (source px) where the item's pivot goes.
Floor-layer items are drawn first; world items are depth-sorted by ``at`` y.
Each item's separate contact shadow (if built) is drawn under all world items.
Paths are relative to the job folder.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]


def load_item(item: dict):
    folder = JOB / "output" / item["asset"]
    frame = item.get("frame", item["asset"])
    img = Image.open(folder / f"{frame}.png").convert("RGBA")
    man = json.loads((folder / f"{frame}.json").read_text(encoding="utf-8"))
    shadow = None
    if man.get("shadow_file"):
        shadow = Image.open(folder / man["shadow_file"]).convert("RGBA")
    return img, shadow, man


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scene", type=Path)
    args = ap.parse_args()
    scene = json.loads(args.scene.read_text(encoding="utf-8"))
    base = Image.open(JOB / scene["background"]).convert("RGBA")
    canvas = base.copy()
    entries = []
    for index, item in enumerate(scene["items"]):
        img, shadow, man = load_item(item)
        px, py = man.get("pivot") or [0, 0]
        x, y = item["at"]
        pos = (int(round(x - px)), int(round(y - py)))
        entries.append({"item": item, "img": img, "shadow": shadow, "pos": pos, "man": man, "index": index})
    floor = [e for e in entries if e["item"].get("layer") == "floor"]
    world = [e for e in entries if e["item"].get("layer") != "floor"]
    world.sort(key=lambda e: (e["item"].get("sort_y", e["item"]["at"][1]), e["index"]))
    for e in floor:
        if e["shadow"] is not None:
            canvas.alpha_composite(e["shadow"], e["pos"])
        canvas.alpha_composite(e["img"], e["pos"])
    for e in world:
        if e["shadow"] is not None:
            canvas.alpha_composite(e["shadow"], e["pos"])
    for e in world:
        canvas.alpha_composite(e["img"], e["pos"])
    scale = float(scene.get("scale", 0.5))
    size = (int(round(canvas.width * scale)), int(round(canvas.height * scale)))
    out = JOB / scene["out"]
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").resize(size, Image.Resampling.LANCZOS).save(out)
    if scene.get("full_out"):
        canvas.convert("RGB").save(JOB / scene["full_out"])
    record = {
        "status": "candidate",
        "note": "Composited preview for review only, not a runtime asset.",
        "size": list(size),
        "background": scene["background"],
        "items": [{"asset": e["item"]["asset"], "frame": e["item"].get("frame"), "at_source_px": e["item"]["at"],
                   "at_logical_px": [round(v * scale, 1) for v in e["item"]["at"]],
                   "layer": e["item"].get("layer", "world")} for e in entries],
    }
    out.with_suffix(".json").write_text(json.dumps(record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(out, size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
