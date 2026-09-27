"""Split built 9-slice frames into nine pieces and make a stretched check image.

    py -3 -B ui_slice.py ui_mo_panel [ui_sf_panel ...] [--margin 48]

For each id (output/<id>/<id>.png):
  output/<id>/<id>_9slice.json   margins for Godot NinePatchRect (patch_margin_*), axis mode
  output/<id>/slices/<id>_<tl|t|tr|l|c|r|bl|b|br>.png
  preview/<id>_stretched.png     the frame stretched to 640x240 and 240x400 on a dark floor
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
NAMES = [["tl", "t", "tr"], ["l", "c", "r"], ["bl", "b", "br"]]


def nine(img, m):
    w, h = img.size
    xs, ys = [0, m, w - m, w], [0, m, h - m, h]
    return {NAMES[j][i]: img.crop((xs[i], ys[j], xs[i + 1], ys[j + 1])) for j in range(3) for i in range(3)}


def stretch(parts, m, W, H):
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    xs, ys = [0, m, W - m, W], [0, m, H - m, H]
    for j in range(3):
        for i in range(3):
            p = parts[NAMES[j][i]]
            size = (xs[i + 1] - xs[i], ys[j + 1] - ys[j])
            out.alpha_composite(p.resize(size, Image.Resampling.LANCZOS) if p.size != size else p, (xs[i], ys[j]))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ids", nargs="+")
    ap.add_argument("--margin", type=int, default=48)
    ap.add_argument("--bg", default="#3b3542")
    args = ap.parse_args()
    m = args.margin
    for uid in args.ids:
        src = JOB / "output" / uid / f"{uid}.png"
        img = Image.open(src).convert("RGBA")
        parts = nine(img, m)
        sd = src.parent / "slices"
        sd.mkdir(exist_ok=True)
        for k, p in parts.items():
            p.save(sd / f"{uid}_{k}.png")
        meta = {"id": uid, "status": "candidate", "file": src.name, "size": list(img.size),
                "patch_margin_left": m, "patch_margin_top": m, "patch_margin_right": m, "patch_margin_bottom": m,
                "axis_stretch": "stretch (edges are uniform along their length; tile also works)",
                "slices": {k: f"slices/{uid}_{k}.png" for k in parts}}
        (src.parent / f"{uid}_9slice.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        wide, tall = stretch(parts, m, 640, 240), stretch(parts, m, 240, 400)
        sheet = Image.new("RGBA", (640 + 240 + 48, 400 + 32), args.bg)
        sheet.alpha_composite(wide, (16, 16))
        sheet.alpha_composite(tall, (640 + 32, 16))
        prev = JOB / "preview" / f"{uid}_stretched.png"
        prev.parent.mkdir(exist_ok=True)
        sheet.convert("RGB").save(prev)
        print(prev)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
