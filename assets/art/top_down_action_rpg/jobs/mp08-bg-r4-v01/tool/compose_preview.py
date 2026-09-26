"""Compose built assets into a game-screen preview from a scene JSON.

    py -3 -B compose_preview.py ../recipes/scene_h0_v2.json

Scene:
    {"background": "output/<asset>/<frame>.png",      # source-resolution background
     "scale": 0.5,                                     # source px -> preview px
     "items": [{"asset": "...", "frame": "...", "at": [x, y], "layer": "floor|world",
                "id": "player", "interactive": true}],
     "lighting": {...} | absent,                       # v02: scene light (iconkit/lighting.py)
     "out": "preview/<name>.png", "full_out": "preview/<name>_source.png",
     "lightmap_out": "preview/<name>_light.png"}       # v02: light multiplier, for review

``at`` is the pixel of the background (source px) where the item's pivot goes.
Floor-layer items are drawn first; world items are depth-sorted by ``at`` y.
Each item's separate contact shadow (if built) is drawn under all world items.
v02: each item's ``_emit.png`` (flames, embers) is kept in a separate emission
layer (hidden by whatever is drawn in front of it) and, when the scene has
``lighting``, added back after the scene is multiplied by the light map.
Without ``lighting`` the result is the v01 diffuse-light composite.
Paths are relative to the job folder.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from iconkit import lighting  # noqa: E402

JOB = Path(__file__).resolve().parents[1]


def load_item(item: dict):
    folder = JOB / "output" / item["asset"]
    frame = item.get("frame", item["asset"])
    img = Image.open(folder / f"{frame}.png").convert("RGBA")
    man = json.loads((folder / f"{frame}.json").read_text(encoding="utf-8"))
    shadow = emit = None
    if man.get("shadow_file"):
        shadow = Image.open(folder / man["shadow_file"]).convert("RGBA")
    if man.get("emit_file"):
        emit = Image.open(folder / man["emit_file"]).convert("RGBA")
    return img, shadow, emit, man


def premul(img: Image.Image) -> np.ndarray:
    a = np.asarray(img, dtype=np.float32) / 255.0
    return a[..., :3] * a[..., 3:4]


class EmitLayer:
    """Premultiplied additive light that later opaque sprites hide."""

    def __init__(self, w: int, h: int):
        self.rgb = np.zeros((h, w, 3), dtype=np.float32)

    def _window(self, pos, size):
        x, y = pos
        w, h = size
        H, W = self.rgb.shape[:2]
        x0, y0, x1, y1 = max(0, x), max(0, y), min(W, x + w), min(H, y + h)
        if x1 <= x0 or y1 <= y0:
            return None
        return x0, y0, x1, y1, x0 - x, y0 - y

    def occlude(self, img: Image.Image, pos) -> None:
        win = self._window(pos, img.size)
        if win is None:
            return
        x0, y0, x1, y1, sx, sy = win
        a = np.asarray(img.getchannel("A"), dtype=np.float32)[sy:sy + y1 - y0, sx:sx + x1 - x0] / 255.0
        self.rgb[y0:y1, x0:x1] *= (1.0 - a)[..., None]

    def add(self, img: Image.Image, pos) -> None:
        win = self._window(pos, img.size)
        if win is None:
            return
        x0, y0, x1, y1, sx, sy = win
        self.rgb[y0:y1, x0:x1] += premul(img)[sy:sy + y1 - y0, sx:sx + x1 - x0]


def bbox_of(img: Image.Image, pos) -> list | None:
    box = img.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox()
    if not box:
        return None
    return [box[0] + pos[0], box[1] + pos[1], box[2] + pos[0], box[3] + pos[1]]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scene", type=Path)
    args = ap.parse_args()
    scene = json.loads(args.scene.read_text(encoding="utf-8"))
    bg_path = JOB / scene["background"]
    base = Image.open(bg_path).convert("RGBA")
    canvas = base.copy()
    emit = EmitLayer(*canvas.size)
    bg_man_path = bg_path.with_suffix(".json")
    if bg_man_path.exists():
        bg_man = json.loads(bg_man_path.read_text(encoding="utf-8"))
        # mp08: backgrounds are built with shadow_output "separate"; lay their own floor shadow back
        # for the check image (the runtime asset keeps it as a separate file).
        if bg_man.get("shadow_file") and scene.get("background_shadow", True):
            canvas.alpha_composite(Image.open(bg_path.parent / bg_man["shadow_file"]).convert("RGBA"), (0, 0))
        if bg_man.get("emit_file"):
            emit.add(Image.open(bg_path.parent / bg_man["emit_file"]).convert("RGBA"), (0, 0))
    entries = []
    for index, item in enumerate(scene["items"]):
        img, shadow, item_emit, man = load_item(item)
        px, py = man.get("pivot") or [0, 0]
        x, y = item["at"]
        pos = (int(round(x - px)), int(round(y - py)))
        entries.append({"item": item, "img": img, "shadow": shadow, "emit": item_emit, "pos": pos, "man": man,
                        "index": index})
    floor = [e for e in entries if e["item"].get("layer") == "floor"]
    world = [e for e in entries if e["item"].get("layer") != "floor"]
    world.sort(key=lambda e: (e["item"].get("sort_y", e["item"]["at"][1]), e["index"]))

    def draw(e):
        canvas.alpha_composite(e["img"], e["pos"])
        emit.occlude(e["img"], e["pos"])
        if e["emit"] is not None:
            emit.add(e["emit"], e["pos"])

    for e in floor:
        if e["shadow"] is not None:
            canvas.alpha_composite(e["shadow"], e["pos"])
        draw(e)
    for e in world:
        if e["shadow"] is not None:
            canvas.alpha_composite(e["shadow"], e["pos"])
    for e in world:
        draw(e)
    # mp08: full-canvas transparent foreground layers (same origin as the background) go on top
    for fg_path in scene.get("foreground", []):
        fg = Image.open(JOB / fg_path).convert("RGBA")
        canvas.alpha_composite(fg, (0, 0))
        emit.occlude(fg, (0, 0))

    rgb = np.asarray(canvas.convert("RGB"), dtype=np.float32) / 255.0
    light_spec = scene.get("lighting")
    maps = None
    if light_spec:
        items = {}
        for e in entries:
            key = e["item"].get("id") or f"{e['item']['asset']}#{e['index']}"
            items[key] = {"at": e["item"]["at"], "bbox": bbox_of(e["img"], e["pos"]),
                          "interactive": bool(e["item"].get("interactive"))}
        maps = lighting.build(light_spec, canvas.width, canvas.height, items)
        rgb = lighting.apply(rgb, emit.rgb, maps, light_spec)
    final = Image.fromarray((rgb * 255.0 + 0.5).clip(0, 255).astype(np.uint8), "RGB")

    scale = float(scene.get("scale", 0.5))
    size = (int(round(canvas.width * scale)), int(round(canvas.height * scale)))
    out = JOB / scene["out"]
    out.parent.mkdir(parents=True, exist_ok=True)
    final.resize(size, Image.Resampling.LANCZOS).save(out)
    if scene.get("full_out"):
        final.save(JOB / scene["full_out"])
    if maps is not None and scene.get("lightmap_out"):
        lm = np.clip(maps["light"] / max(1.0, float(light_spec.get("max", 1.3))), 0.0, 1.0)
        Image.fromarray((lm * 255.0 + 0.5).astype(np.uint8), "RGB").resize(size, Image.Resampling.LANCZOS).save(
            JOB / scene["lightmap_out"])
    record = {
        "status": "candidate",
        "note": "Composited preview for review only, not a runtime asset.",
        "size": list(size),
        "background": scene["background"],
        "variant": scene.get("variant"),
        "lighting": light_spec or "none (painted diffuse top light only)",
        "items": [{"asset": e["item"]["asset"], "frame": e["item"].get("frame"), "at_source_px": e["item"]["at"],
                   "at_logical_px": [round(v * scale, 1) for v in e["item"]["at"]],
                   "layer": e["item"].get("layer", "world"), "interactive": bool(e["item"].get("interactive"))}
                  for e in entries],
    }
    out.with_suffix(".json").write_text(json.dumps(record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(out, size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
