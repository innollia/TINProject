"""Pack each effect's frames into one horizontal strip: output/sheets/<name>.png

    py -3 -B tool\\pack_strip.py                 # every asset in output/
    py -3 -B tool\\pack_strip.py heart lava      # only these

Frames are concatenated edge to edge with no transparent gutter, so the strip
plays back as an animation at a fixed cell size.  A frame's contact shadow
(<frame>_shadow.png) is composited under its sprite first, because in game the
shadow is a separate layer under the effect.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
OUT = JOB / "output"
SHEETS = OUT / "sheets"
FRAME_RE = re.compile(r"^f(\d+)\.png$")


def frames_of(asset_dir: Path) -> list[Path]:
    found = []
    for p in asset_dir.glob("f*.png"):
        m = FRAME_RE.match(p.name)
        if m and not p.name.endswith(("_shadow.png", "_emit.png")):
            found.append((int(m.group(1)), p))
    return [p for _, p in sorted(found)]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("assets", nargs="*")
    args = ap.parse_args()
    SHEETS.mkdir(parents=True, exist_ok=True)
    names = args.assets or sorted(p.name for p in OUT.iterdir() if p.is_dir())
    for name in names:
        d = OUT / name
        if not d.is_dir():
            print("skip (no such asset)", name)
            continue
        frames = frames_of(d)
        if not frames:
            print("skip (no frames)", name)
            continue
        cell = Image.open(frames[0]).size
        strip = Image.new("RGBA", (cell[0] * len(frames), cell[1]), (0, 0, 0, 0))
        x = 0
        for f in frames:
            im = Image.open(f).convert("RGBA")
            if im.size != cell:
                im = im.resize(cell, Image.Resampling.LANCZOS)
            sh = f.with_name(f.stem + "_shadow.png")
            if sh.exists():
                strip.alpha_composite(Image.open(sh).convert("RGBA"), (x, 0))
            strip.alpha_composite(im, (x, 0))
            x += cell[0]
        out = SHEETS / f"{name}.png"
        strip.save(out)
        print(f"{out.name}  {len(frames)} frames  {strip.size[0]}x{strip.size[1]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
