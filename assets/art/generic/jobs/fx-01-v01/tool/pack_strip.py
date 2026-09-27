"""Pack each effect's frames into one horizontal sheet: output/sheets/<asset>.png.

    py -3 -B tool/pack_strip.py                 # every asset
    py -3 -B tool/pack_strip.py bubble flame    # only these

Frames are taken in sorted order (f0, f1, ...), main png only - _emit.png and
_shadow.png are skipped.  The frames butt straight against each other, no gap, so
an animation can be played off the sheet directly.
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
OUT = JOB / "output"
SHEETS = OUT / "sheets"


def frames_of(asset_dir: Path) -> list[Path]:
    return sorted(p for p in asset_dir.glob("f*.png")
                  if not p.name.endswith(("_emit.png", "_shadow.png")))


def pack(asset: str) -> tuple[Path, int] | None:
    src = OUT / asset
    frames = frames_of(src) if src.is_dir() else []
    if not frames:
        return None
    imgs = [Image.open(p).convert("RGBA") for p in frames]
    h = max(i.height for i in imgs)
    w = sum(i.width for i in imgs)
    sheet = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x = 0
    for im in imgs:
        sheet.alpha_composite(im, (x, 0))
        x += im.width
    SHEETS.mkdir(parents=True, exist_ok=True)
    path = SHEETS / f"{asset}.png"
    sheet.save(path)
    return path, len(frames)


def main(argv) -> int:
    names = argv or sorted(p.name for p in OUT.iterdir() if p.is_dir())
    for name in names:
        got = pack(name)
        if got:
            path, n = got
            print(f"{path.relative_to(JOB).as_posix()}  {n} frames  {Image.open(path).size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
