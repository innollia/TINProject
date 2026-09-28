"""Report every leg chain whose rest pose the IK cannot solve.

    python -m procbake.legcheck
    python -m procbake.legcheck specs/creatures/A
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from .bake import leg_report
from .creature import Creature
from .shapes import ShapeLibrary

ROOT = Path(__file__).resolve().parent.parent


def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if argv:
        specs = [Path(p) for p in argv]
        files = []
        for p in specs:
            files.extend(sorted(p.glob("*.json")) if p.is_dir() else [p])
    else:
        files = sorted((ROOT / "specs" / "creatures").rglob("*.json"))
    lib = ShapeLibrary([ROOT / "shapes"])
    broken = 0
    chains = 0
    for path in files:
        spec = json.loads(path.read_text(encoding="utf-8"))
        creature = Creature.from_spec(spec, lib)
        for row in leg_report(creature, spec):
            chains += 1
            if row.get("ok"):
                continue
            broken += 1
            name = "/".join(path.parts[-2:])
            print(f"FAIL {name:34s} {'>'.join(row['chain']):30s} "
                  f"reach={row['reach']:6.1f} span=[{row['min']:5.1f},{row['max']:6.1f}]  {row.get('why','')}")
    print(f"\n{chains - broken}/{chains} leg chains solvable at their rest pose")
    return 1 if broken else 0


if __name__ == "__main__":
    raise SystemExit(main())
