"""Rename every global class in the DLC copy so it can coexist with core/procedural.

Godot registers `class_name` globally: two scripts declaring the same one is a
hard startup error, not a warning.  A straight folder copy of core/procedural
would therefore refuse to load next to the original, and there are 14 such
names.  So the copy is prefixed, and this script is the record of the mapping so
the fork stays readable and the two folders can be diffed name by name.

Run once, from the repo root:

    python tools/proc_bake/tools/rename_dlc_classes.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DLC = ROOT / "core" / "procedural-icon-dlc"
PREFIX = "Dlc"

CLASSES = [
    "ProceduralBackdropDynamics", "ProceduralCreatureBuilder", "ProceduralBodyPart",
    "ProceduralPaletteScheme", "ProceduralDeformField", "ProceduralSquishRig",
    "ProceduralNoiseField", "ProceduralCanvas", "ProceduralPalette", "ProceduralShape",
    "ProceduralSpring", "ProceduralSdf", "ProceduralSeed", "Procedural",
]


def mapping() -> dict:
    # longest first, so Procedural never eats the prefix off ProceduralSdf
    return {name: PREFIX + name for name in sorted(CLASSES, key=len, reverse=True)}


def rename_text(text: str, table: dict) -> str:
    pattern = re.compile(r"\b(" + "|".join(table) + r")\b")
    return pattern.sub(lambda m: table[m.group(1)], text)


def main() -> int:
    if not DLC.is_dir():
        print(f"missing {DLC}")
        return 1
    table = mapping()
    changed = []
    for path in sorted(DLC.rglob("*.gd")):
        original = path.read_text(encoding="utf-8")
        updated = rename_text(original, table)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed.append(path.relative_to(ROOT).as_posix())
    print(f"{len(changed)} files rewritten")
    for name in changed:
        print(f"  {name}")
    leftover = []
    for path in sorted(DLC.rglob("*.gd")):
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.startswith("class_name ") and not line.startswith(f"class_name {PREFIX}"):
                leftover.append(f"{path.name}: {line}")
    if leftover:
        print("NOT RENAMED:")
        for line in leftover:
            print(f"  {line}")
        return 1
    print("all class_name declarations prefixed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
