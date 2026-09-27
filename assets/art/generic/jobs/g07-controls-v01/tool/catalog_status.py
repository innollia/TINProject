"""Set the status cell of rows in docs/art/projects/generic/catalog/g07_future_kits.md.

    py -3 -B catalog_status.py 완료 --range 1-42
    py -3 -B catalog_status.py 건너뜀 obj_x obj_y

Rows are matched by their '#' number (--range) or by asset id; only the last
table cell (상태) changes.
"""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
CATALOG = ROOT / "docs" / "art" / "projects" / "generic" / "catalog" / "g07_future_kits.md"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("status")
    ap.add_argument("ids", nargs="*")
    ap.add_argument("--range", default="")
    args = ap.parse_args()
    nums = set()
    if args.range:
        a, b = (int(v) for v in args.range.split("-"))
        nums = {str(n) for n in range(a, b + 1)}
    ids = set(args.ids)
    lines = CATALOG.read_text(encoding="utf-8").splitlines()
    changed = 0
    for i, line in enumerate(lines):
        if not line.startswith("| ") or line.startswith("| #") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 7:
            continue
        if cells[0] in nums or cells[2] in ids:
            cells[-1] = args.status
            lines[i] = "| " + " | ".join(cells) + " |"
            changed += 1
    CATALOG.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(CATALOG.name, "rows changed:", changed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
