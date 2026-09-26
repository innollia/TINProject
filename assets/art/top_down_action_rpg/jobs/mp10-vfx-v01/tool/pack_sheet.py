"""Pack built frames into runtime sprite sheets (no labels) - mp10 addition.

    py -3 -B pack_sheet.py            # every sheet for every recipe with a "vfx" block

Per recipe and state: output/sheets/<asset>[__<state>].png, one row, ``cols``
cells (5 by default; a recipe may set vfx.sheet_cols), cell = canvas size.
Unused cells stay transparent.  A matching <sheet>_emit.png is written when any
frame has an emission layer, and <sheet>.json records cell size, pivot, frame
order, blend, loop and static frame so the game does not have to guess.

Collected sheets (one effect/state per row, same cell size only):
    output/sheets/vfx_all_192.png, vfx_all_384.png, status_tokens_128.png
"""

from __future__ import annotations

import json
from collections import OrderedDict
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
OUT = JOB / "output"
SHEETS = OUT / "sheets"
SKIP = ("_", "palette_", "scene_")


def state_of(frame: str) -> str:
    head, _, tail = frame.rpartition("_")
    return head if tail.isdigit() and head else ""


def load_frames(recipe: dict) -> "OrderedDict[str, list]":
    groups: "OrderedDict[str, list]" = OrderedDict()
    for fr in recipe.get("frames", []):
        groups.setdefault(state_of(fr["name"]), []).append(fr["name"])
    return groups


def pack(paths: list, cell, cols: int, out: Path) -> dict:
    rows = (len(paths) + cols - 1) // cols
    sheet = Image.new("RGBA", (cell[0] * cols, cell[1] * rows), (0, 0, 0, 0))
    emit = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
    has_emit = False
    for k, p in enumerate(paths):
        x, y = (k % cols) * cell[0], (k // cols) * cell[1]
        im = Image.open(p).convert("RGBA")
        sheet.alpha_composite(im, (x, y))
        ep = p.with_name(p.stem + "_emit.png")
        if ep.exists():
            emit.alpha_composite(Image.open(ep).convert("RGBA"), (x, y))
            has_emit = True
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    emit_out = out.with_name(out.stem + "_emit.png")
    if has_emit:
        emit.save(emit_out)
    elif emit_out.exists():
        emit_out.unlink()
    return {"file": out.name, "emit_file": emit_out.name if has_emit else None, "size": list(sheet.size),
            "cols": cols, "rows": rows}


def main() -> int:
    collected = {192: [], 384: [], 128: []}
    written = 0
    for rp in sorted((JOB / "recipes").glob("*.json")):
        if rp.name.startswith(SKIP):
            continue
        recipe = json.loads(rp.read_text(encoding="utf-8"))
        vfx = recipe.get("vfx")
        if not vfx:
            continue
        asset, cell = recipe["asset"], recipe["canvas"]
        cols = int(vfx.get("sheet_cols", 5))
        groups = load_frames(recipe)
        if cols != 5:  # icon-style sheet: everything in one run
            groups = OrderedDict([("", [f for fs in groups.values() for f in fs])])
        for state, frames in groups.items():
            paths = [OUT / asset / f"{f}.png" for f in frames]
            missing = [p.name for p in paths if not p.exists()]
            if missing:
                raise SystemExit(f"{asset}: frames not built yet: {missing}")
            name = asset + (f"__{state}" if state and len(groups) > 1 else "")
            info = pack(paths, cell, cols, SHEETS / f"{name}.png")
            info.update({"status": "candidate", "approval": "not approved - only the user approves",
                         "asset": asset, "state": state or None, "cell": cell, "pivot_in_cell": recipe["pivot"],
                         "pivot_meaning": recipe.get("pivot_meaning"), "frames": frames,
                         "blend": vfx.get("blend", "normal"), "loop": bool(vfx.get("loop", False)) or
                         state in (vfx.get("loop_states") or []), "static_frame": vfx.get("static_frame"),
                         "recipe": f"recipes/{rp.name}"})
            (SHEETS / f"{name}.json").write_text(json.dumps(info, indent=2, ensure_ascii=False) + "\n",
                                                 encoding="utf-8")
            written += 1
            key = cell[0] if cell[0] == cell[1] and cell[0] in collected else None
            if key:
                collected[key].append((name, paths))
    for size, rows in collected.items():
        if not rows:
            continue
        cols = 16 if size == 128 else 5
        flat, index = [], []
        for name, paths in rows:
            if size == 128:
                flat += paths
                index += [p.stem for p in paths]
                continue
            start = len(flat)
            flat += paths + [None] * ((cols - len(paths) % cols) % cols)
            index.append({"row": start // cols, "sheet": name, "frames": [p.stem for p in paths]})
        name = "status_tokens_128" if size == 128 else f"vfx_all_{size}"
        cell = [size, size]
        blank = SHEETS / "_blank.png"
        Image.new("RGBA", (size, size), (0, 0, 0, 0)).save(blank)
        info = pack([p if p else blank for p in flat], cell, cols, SHEETS / f"{name}.png")
        blank.unlink()
        info.update({"status": "candidate", "cell": cell, "index": index,
                     "note": "Collected sheet for review and lookup; per-effect sheets carry pivots and timing."})
        (SHEETS / f"{name}.json").write_text(json.dumps(info, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        written += 1
    print(f"sheets written: {written}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
