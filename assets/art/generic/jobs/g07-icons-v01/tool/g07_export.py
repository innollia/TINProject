"""g07 export helpers (run after build.py).

    py -3 -B g07_export.py sheet16 --out ../preview/sheet16_icons.png ../output/icon_a/icon_a.png ...
        One row of 16 cells (cell = the first image's size), transparent, extra rows when > 16.

    py -3 -B g07_export.py slice9 --margin 48 [--margin-y 48] --stretch 3x2 ../output/ui_x/ui_x.png
        Cuts a 9-slice frame into 9 PNGs (<frame>_9s_<tl|t|tr|l|c|r|bl|b|br>.png next to the source),
        writes <frame>_9s.json (margins) and a stretched check image in ../preview/<frame>_9s_check.png.

Neither command changes the source PNGs.
"""

from __future__ import annotations

import argparse
import glob
import json
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]


def expand(patterns):
    out = []
    for p in patterns:
        hits = sorted(glob.glob(p))
        out.extend(hits or [p])
    return [Path(p) for p in out if not p.endswith(("_shadow.png", "_emit.png"))]


def sheet16(args) -> int:
    files = expand(args.files)
    imgs = [Image.open(p).convert("RGBA") for p in files]
    cw, ch = imgs[0].size
    cols = min(16, len(imgs))
    rows = (len(imgs) + 15) // 16
    sheet = Image.new("RGBA", (cw * 16 if len(imgs) >= 16 or args.full else cw * cols, ch * rows), (0, 0, 0, 0))
    for i, im in enumerate(imgs):
        if im.size != (cw, ch):
            im = im.resize((cw, ch), Image.Resampling.LANCZOS)
        sheet.alpha_composite(im, ((i % 16) * cw, (i // 16) * ch))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.out)
    order = [p.stem for p in files]
    args.out.with_suffix(".json").write_text(json.dumps({"cell": [cw, ch], "columns": 16, "order": order,
                                                         "status": "candidate"}, indent=1) + "\n", encoding="utf-8")
    print(args.out, sheet.size, len(imgs), "cells")
    return 0


def nine(im, mx, my):
    w, h = im.size
    xs, ys = [0, mx, w - mx, w], [0, my, h - my, h]
    names = [["tl", "t", "tr"], ["l", "c", "r"], ["bl", "b", "br"]]
    parts = {}
    for j in range(3):
        for i in range(3):
            parts[names[j][i]] = im.crop((xs[i], ys[j], xs[i + 1], ys[j + 1]))
    return parts


def stretched(parts, mx, my, W, H):
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cw, ch = W - 2 * mx, H - 2 * my
    place = {
        "tl": ((0, 0), (mx, my)), "t": ((mx, 0), (cw, my)), "tr": ((W - mx, 0), (mx, my)),
        "l": ((0, my), (mx, ch)), "c": ((mx, my), (cw, ch)), "r": ((W - mx, my), (mx, ch)),
        "bl": ((0, H - my), (mx, my)), "b": ((mx, H - my), (cw, my)), "br": ((W - mx, H - my), (mx, my)),
    }
    for key, (pos, size) in place.items():
        if size[0] <= 0 or size[1] <= 0:
            continue
        out.alpha_composite(parts[key].resize(size, Image.Resampling.BILINEAR), pos)
    return out


def slice9(args) -> int:
    sx, sy = (float(v) for v in args.stretch.lower().split("x"))
    for path in expand(args.files):
        im = Image.open(path).convert("RGBA")
        mx = int(args.margin)
        my = int(args.margin_y if args.margin_y is not None else args.margin)
        parts = nine(im, mx, my)
        for key, part in parts.items():
            part.save(path.with_name(f"{path.stem}_9s_{key}.png"))
        meta = {"source": path.name, "size": list(im.size), "margin": [mx, my, mx, my],
                "margin_order": "left, top, right, bottom", "center_mode": "stretch", "status": "candidate"}
        path.with_name(f"{path.stem}_9s.json").write_text(json.dumps(meta, indent=1) + "\n", encoding="utf-8")
        W, H = int(im.width * sx), int(im.height * sy)
        check = stretched(parts, mx, my, W, H)
        bg = Image.new("RGBA", (W + 32, H + 32), "#b3a8b7")
        bg.alpha_composite(check, (16, 16))
        stem = path.stem if path.stem == path.parent.name else f"{path.parent.name}_{path.stem}"
        out = JOB / "preview" / f"{stem}_9s_check.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        bg.convert("RGB").save(out)
        print(path.name, "->", out.name, (W, H))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("sheet16")
    a.add_argument("files", nargs="+")
    a.add_argument("--out", type=Path, required=True)
    a.add_argument("--full", action="store_true", help="always 16 columns wide")
    b = sub.add_parser("slice9")
    b.add_argument("files", nargs="+")
    b.add_argument("--margin", type=int, default=48)
    b.add_argument("--margin-y", type=int, default=None)
    b.add_argument("--stretch", default="3x2")
    args = ap.parse_args()
    return sheet16(args) if args.cmd == "sheet16" else slice9(args)


if __name__ == "__main__":
    raise SystemExit(main())
