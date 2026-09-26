"""Pack 8-direction cells into RPG Maker sheets and make review previews.

    py -3 -B export_sheet8.py player enemy_ash_hound
    py -3 -B export_sheet8.py player enemy_ash_hound --compare player,enemy_ash_hound

Sheets (output/sheets/), one character per sheet, so the name starts with $:
    $<asset>.png              3 x 4 cells, rows down, left, right, up
    $<asset>_diag.png         3 x 4 cells, rows down_left, down_right, up_left, up_right
    $<asset>_shadow.png, $<asset>_diag_shadow.png   contact shadows, same layout
    $<asset>.json             cell size, pivot, row / column meaning, source cells
Columns: 0 = left foot forward, 1 = standing, 2 = right foot forward; walk 0-1-2-1.
Previews (preview/):
    <asset>_walk8.gif         all 8 directions walking, compass layout, floor colour
    <asset>_cells.png         every cell with its shadow, guide lines at the pivot
                              and at the standing-down head top
    compare_<a>_<b>.png       standing frames of two assets at the same scale
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build import JOB  # noqa: E402
from iconkit.walk8 import COLUMN_MEANING, COLUMNS, DIRECTIONS, SHEETS, WALK_PATTERN  # noqa: E402

FLOOR = "#b3a8b7"
COMPASS = (("up_left", "up", "up_right"), ("left", None, "right"), ("down_left", "down", "down_right"))
ORDER = SHEETS["base"] + SHEETS["diag"]


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Cells:
    """All 24 cells of one asset, checked for size and pivot consistency."""

    def __init__(self, out: Path, asset: str):
        self.asset = asset
        self.dir = out / asset
        self.img, self.shadow, self.man = {}, {}, {}
        missing = []
        for view in ORDER:
            for col in COLUMNS:
                name = f"{view}_{col}"
                png = self.dir / f"{name}.png"
                if not png.exists():
                    missing.append(name)
                    continue
                self.img[name] = Image.open(png).convert("RGBA")
                sp = self.dir / f"{name}_shadow.png"
                self.shadow[name] = Image.open(sp).convert("RGBA") if sp.exists() else None
                self.man[name] = json.loads((self.dir / f"{name}.json").read_text(encoding="utf-8"))
        if missing:
            raise SystemExit(f"{asset}: missing cells {missing}")
        sizes = {im.size for im in self.img.values()}
        pivots = {tuple(m["pivot"]) for m in self.man.values()}
        if len(sizes) != 1 or len(pivots) != 1:
            raise SystemExit(f"{asset}: cells disagree: sizes {sizes} pivots {pivots}")
        self.size = sizes.pop()
        self.pivot = pivots.pop()

    def top_of(self, name: str) -> int:
        box = self.img[name].getchannel("A").point(lambda v: 255 if v > 24 else 0).getbbox()
        return box[1] if box else 0

    def with_shadow(self, name: str, bg=None) -> Image.Image:
        base = Image.new("RGBA", self.size, bg or (0, 0, 0, 0))
        if self.shadow[name] is not None:
            base.alpha_composite(self.shadow[name])
        base.alpha_composite(self.img[name])
        return base


def export_sheets(cells: Cells, out: Path) -> dict:
    w, h = cells.size
    sheets_dir = out / "sheets"
    sheets_dir.mkdir(parents=True, exist_ok=True)
    info = {"asset": cells.asset, "status": "candidate", "approval": "not approved - only the user approves",
            "cell_size": [w, h], "pivot": list(cells.pivot),
            "pivot_meaning": cells.man["down_1"].get("pivot_meaning"),
            "columns": {str(c): COLUMN_MEANING[c] for c in COLUMNS},
            "walk_pattern": list(WALK_PATTERN), "sheets": {}}
    for sheet, rows in SHEETS.items():
        stem = f"${cells.asset}" + ("" if sheet == "base" else "_diag")
        img = Image.new("RGBA", (w * 3, h * 4), (0, 0, 0, 0))
        sh = Image.new("RGBA", (w * 3, h * 4), (0, 0, 0, 0))
        has_shadow = False
        for r, view in enumerate(rows):
            for c in COLUMNS:
                name = f"{view}_{c}"
                img.alpha_composite(cells.img[name], (c * w, r * h))
                if cells.shadow[name] is not None:
                    sh.alpha_composite(cells.shadow[name], (c * w, r * h))
                    has_shadow = True
        img_path = sheets_dir / f"{stem}.png"
        img.save(img_path)
        entry = {"file": img_path.name, "size": list(img.size), "sha256": sha(img_path),
                 "rows": [{"row": r, "direction": v, "direction_code": DIRECTIONS[v]["code"],
                           "cells": [f"{cells.asset}/{v}_{c}.png" for c in COLUMNS]} for r, v in enumerate(rows)]}
        if has_shadow:
            sh_path = sheets_dir / f"{stem}_shadow.png"
            sh.save(sh_path)
            entry["shadow_file"] = sh_path.name
            entry["shadow_sha256"] = sha(sh_path)
        info["sheets"][sheet] = entry
        print(img_path, img.size)
    man_path = sheets_dir / f"${cells.asset}.json"
    man_path.write_text(json.dumps(info, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return info


def walk_gif(cells: Cells, path: Path, ms: int, scale: float) -> None:
    w, h = cells.size
    sw, sh = int(w * scale), int(h * scale)
    label = font(max(12, int(16 * scale)))
    frames = []
    for col in WALK_PATTERN:
        board = Image.new("RGBA", (sw * 3, sh * 3), FLOOR)
        draw = ImageDraw.Draw(board)
        for r, row in enumerate(COMPASS):
            for c, view in enumerate(row):
                if view is None:
                    draw.text((c * sw + 8, r * sh + sh // 2 - 20), f"{cells.asset}\nwalk 0-1-2-1\ncol {col}",
                              fill="#2a1a2e", font=label)
                    continue
                cell = cells.with_shadow(f"{view}_{col}")
                if scale != 1.0:
                    cell = cell.resize((sw, sh), Image.Resampling.LANCZOS)
                board.alpha_composite(cell, (c * sw, r * sh))
                draw.text((c * sw + 4, r * sh + 2), view, fill="#2a1a2e", font=label)
        frames.append(board.convert("RGB").quantize(colors=255, method=Image.Quantize.MEDIANCUT))
    path.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=ms, loop=0, disposal=1)
    print(path, frames[0].size)


def cells_sheet(cells: Cells, path: Path) -> None:
    w, h = cells.size
    lab = font(14)
    left, top_pad = 110, 22
    board = Image.new("RGBA", (left + w * 3, top_pad + h * len(ORDER)), FLOOR)
    draw = ImageDraw.Draw(board)
    head_top = cells.top_of("down_1")
    for c in COLUMNS:
        draw.text((left + c * w + 4, 3), f"col {c}: {COLUMN_MEANING[c]}", fill="#2a1a2e", font=lab)
    for r, view in enumerate(ORDER):
        y0 = top_pad + r * h
        draw.text((6, y0 + h // 2 - 8), f"{view} ({DIRECTIONS[view]['code']})", fill="#2a1a2e", font=lab)
        for c in COLUMNS:
            board.alpha_composite(cells.with_shadow(f"{view}_{c}"), (left + c * w, y0))
        py = y0 + int(cells.pivot[1])
        draw.line((left, py, left + w * 3, py), fill="#5b3f63", width=1)
        draw.line((left, y0 + head_top, left + w * 3, y0 + head_top), fill="#e9e2ec", width=1)
        draw.line((left, y0, left + w * 3, y0), fill="#9d91a3", width=1)
    board.convert("RGB").save(path)
    print(path, board.size)


def union_box(cells: Cells, margin: int = 4) -> tuple[int, int, int, int]:
    """Bounds of everything any cell of the asset paints (sprite + shadow)."""
    box = None
    for name, im in cells.img.items():
        for layer in (im, cells.shadow[name]):
            if layer is None:
                continue
            b = layer.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
            if b:
                box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]),
                                             max(box[2], b[2]), max(box[3], b[3]))
    w, h = cells.size
    return (max(0, box[0] - margin), max(0, box[1] - margin), min(w, box[2] + margin), min(h, box[3] + margin))


def compare(a: Cells, b: Cells, path: Path) -> None:
    """Standing frames of two assets, all 8 directions, same scale, one ground line per row."""
    lab = font(14)
    pad, gap = 14, 10
    crops = {c.asset: union_box(c) for c in (a, b)}

    def cropped(cells: Cells, view: str, scale: float = 1.0):
        x0, y0, x1, y1 = crops[cells.asset]
        img = cells.with_shadow(f"{view}_1").crop((x0, y0, x1, y1))
        if scale != 1.0:
            img = img.resize((max(1, int(img.width * scale)), max(1, int(img.height * scale))), Image.Resampling.LANCZOS)
        return img, (cells.pivot[0] - x0) * scale, (cells.pivot[1] - y0) * scale

    rows = []
    for cells in (a, b):
        items = [cropped(cells, v) for v in ORDER]
        above = max(py for _, _, py in items)
        below = max(im.height - py for im, _, py in items)
        rows.append((cells, items, above, below))
    small = [(cropped(c, v, 0.5)) for v in ("down", "left", "down_left", "up_right") for c in (a, b)]
    s_above = max(py for _, _, py in small)
    s_below = max(im.height - py for im, _, py in small)
    width = max(pad * 2 + sum(im.width for im, _, _ in items) + gap * (len(items) - 1) for _, items, _, _ in rows)
    height = pad + sum(int(ab + be) + 34 for _, _, ab, be in rows) + int(s_above + s_below) + 60
    board = Image.new("RGBA", (width, height), FLOOR)
    draw = ImageDraw.Draw(board)
    y = pad
    for cells, items, above, below in rows:
        ground = y + int(above)
        x = pad
        for view, (im, px, py) in zip(ORDER, items):
            board.alpha_composite(im, (int(x), int(ground - py)))
            draw.text((x + 2, ground + below + 2), view, fill="#2a1a2e", font=lab)
            x += im.width + gap
        draw.line((pad, ground, x - gap, ground), fill="#5b3f63", width=1)
        head = ground - (cells.pivot[1] - cells.top_of("down_1"))
        draw.line((pad, head, x - gap, head), fill="#e9e2ec", width=1)
        draw.text((pad, y - 2), cells.asset, fill="#2a1a2e", font=lab)
        y += int(above + below) + 34
    y += 20
    draw.text((pad, y - 18), "0.5x = 1280x720 game scale (pairs: down, left, down_left, up_right)", fill="#2a1a2e", font=lab)
    ground = y + int(s_above)
    x = pad
    for i, (im, px, py) in enumerate(small):
        board.alpha_composite(im, (int(x), int(ground - py)))
        x += im.width + (gap * 2 if i % 2 else 0)
    draw.line((pad, ground, x, ground), fill="#5b3f63", width=1)
    board.convert("RGB").save(path)
    print(path, board.size)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("assets", nargs="+")
    ap.add_argument("--out", type=Path, default=JOB / "output")
    ap.add_argument("--preview", type=Path, default=JOB / "preview")
    ap.add_argument("--ms", type=int, default=200, help="ms per walk pattern step in the GIF")
    ap.add_argument("--gif-scale", type=float, default=1.0)
    ap.add_argument("--compare", default="", help="two assets, e.g. player,enemy_ash_hound")
    ap.add_argument("--no-gif", action="store_true")
    args = ap.parse_args()

    loaded = {}
    for asset in args.assets:
        cells = Cells(args.out, asset)
        loaded[asset] = cells
        export_sheets(cells, args.out)
        cells_sheet(cells, args.preview / f"{asset}_cells.png")
        if not args.no_gif:
            walk_gif(cells, args.preview / f"{asset}_walk8.gif", args.ms, args.gif_scale)
    if args.compare:
        a, b = [s.strip() for s in args.compare.split(",")]
        ca = loaded.get(a) or Cells(args.out, a)
        cb = loaded.get(b) or Cells(args.out, b)
        compare(ca, cb, args.preview / f"compare_{a}_{b}.png")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
