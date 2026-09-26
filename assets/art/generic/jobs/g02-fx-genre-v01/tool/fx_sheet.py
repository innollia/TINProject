"""Pack effect frames f0..f4 into one-row sheets (192x192 cells).

    py -3 -B fx_sheet.py fx_mo_muzzle_flash [...]

Writes output/<id>/<id>_sheet.png (+ <id>_sheet_emit.png when frames have an
emission layer) and <id>_sheet.json (cell size, frame count, origin), plus a
preview/<id>_sheet_on_dark.png check image.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
CELL, FRAMES = 192, 5


def pack(folder, suffix):
    sheet = Image.new("RGBA", (CELL * FRAMES, CELL), (0, 0, 0, 0))
    found = 0
    for k in range(FRAMES):
        p = folder / f"f{k}{suffix}.png"
        if p.exists():
            sheet.alpha_composite(Image.open(p).convert("RGBA"), (k * CELL, 0))
            found += 1
    return sheet, found


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ids", nargs="+")
    ap.add_argument("--bg", default="#3b3542")
    args = ap.parse_args()
    for fid in args.ids:
        folder = JOB / "output" / fid
        sheet, n = pack(folder, "")
        sheet.save(folder / f"{fid}_sheet.png")
        emit, ne = pack(folder, "_emit")
        if ne:
            emit.save(folder / f"{fid}_sheet_emit.png")
        rec = json.loads((JOB / "recipes" / f"{fid}.json").read_text(encoding="utf-8"))
        meta = {"id": fid, "status": "candidate", "cell": [CELL, CELL], "frames": n, "layout": "one row, left to right",
                "origin": rec.get("pivot"), "emit_sheet": f"{fid}_sheet_emit.png" if ne else None,
                "blend": {"sheet": "normal", "emit_sheet": "additive"}}
        (folder / f"{fid}_sheet.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        prev = Image.new("RGBA", sheet.size, args.bg)
        prev.alpha_composite(sheet)
        (JOB / "preview").mkdir(exist_ok=True)
        prev.convert("RGB").save(JOB / "preview" / f"{fid}_sheet_on_dark.png")
        print(fid, n, "frames", "emit" if ne else "")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
