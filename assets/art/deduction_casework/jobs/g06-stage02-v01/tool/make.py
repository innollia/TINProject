"""Write every recipe of this stage job.

    py -3 -B make.py             # all recipes + stage palettes
    py -3 -B make.py bg_ por_    # only asset ids containing one of the words
    py -3 -B make.py --scenes    # (re)write the scene layout JSONs only

Imports every ``sNN_*.py`` module next to this file; each registers builders on
the stage object defined in ``sNN_common.py`` (attribute ``S``).
"""

from __future__ import annotations

import importlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))


def main(argv) -> int:
    mods = sorted(p.stem for p in HERE.glob("s[0-9][0-9]_*.py"))
    common = [m for m in mods if m.endswith("_common")]
    if not common:
        print("no sNN_common.py")
        return 1
    C = importlib.import_module(common[0])
    for m in mods:
        importlib.import_module(m)
    if "--scenes" in argv:
        scenes = [m for m in mods if m.endswith("_scenes")]
        for m in scenes:
            print(importlib.import_module(m).write_all())
        return 0
    n = C.S.write_all([a for a in argv[1:] if not a.startswith("--")])
    print(f"wrote {n} recipes + {C.S.pal}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
