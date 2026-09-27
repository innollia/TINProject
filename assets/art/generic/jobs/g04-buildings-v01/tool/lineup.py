"""Line-up scene for a g04 bundle: every built frame placed on a flat floor, objects only.

    python -B lineup.py [--max-width 3600] [--scale 0.5]

Writes ``recipes/scene_<bundle>_lineup.json`` (compose_preview.py scene format, no ``lighting``)
and renders ``preview/lineup_<bundle>.png`` with compose_preview.py.  Frames with a game light
carry ``"light": {"color", "radius", "at"}`` (a list when there are several) in scene px, for
game code; ``anchors`` (e.g. flame_anchor) are copied the same way.  No characters, no lighting.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
BUNDLE = JOB.name.replace("-v01", "").replace("g04-", "")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--max-width", type=int, default=3600)
    ap.add_argument("--scale", type=float, default=0.5)
    ap.add_argument("--gap", type=int, default=40)
    args = ap.parse_args()
    entries = []
    for man_path in sorted((JOB / "output").glob("*/*.json")):
        man = json.loads(man_path.read_text(encoding="utf-8"))
        if "frame" not in man or "asset" not in man:
            continue
        entries.append(man)
    rows, row, x = [], [], 0
    for man in entries:
        w = man["size"][0]
        if row and x + w > args.max_width:
            rows.append(row)
            row, x = [], 0
        row.append((x, man))
        x += w + args.gap
    if row:
        rows.append(row)
    items = []
    y = args.gap
    width = 0
    for row in rows:
        h = max(m["size"][1] for _, m in row)
        for x0, man in row:
            px, py = man["pivot"]
            ox, oy = x0 + args.gap, y + (h - man["size"][1])
            item = {"asset": man["asset"], "frame": man["frame"], "at": [ox + px, oy + py],
                    "layer": "floor" if man.get("layer_hint") == "floor" else "world"}
            if man.get("state"):
                item["state"] = man["state"]
            gl = man.get("game_light")
            if gl:
                lights = []
                for light in gl if isinstance(gl, list) else [gl]:
                    lx, ly = light.get("at", [px, py])
                    lights.append({"color": light["color"], "radius": light["radius"], "at": [ox + lx, oy + ly]})
                item["light"] = lights[0] if len(lights) == 1 else lights
            if man.get("anchors"):
                item["anchors"] = {k: [ox + v[0], oy + v[1]] for k, v in man["anchors"].items()}
            items.append(item)
            width = max(width, x0 + man["size"][0] + 2 * args.gap)
        y += h + args.gap
    scene = {
        "note": f"g04 {BUNDLE} line-up: every built frame on a flat floor, objects only (no people, no lighting). "
                "'light' = game-code light (colour, radius in source px, position in scene px).",
        "canvas": [int(width), int(y)],
        "background_color": "#57505c",
        "scale": args.scale,
        "items": items,
        "out": f"preview/lineup_{BUNDLE}.png",
    }
    scene_path = JOB / "recipes" / f"scene_{BUNDLE}_lineup.json"
    scene_path.write_text(json.dumps(scene, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(scene_path.name, len(items), "items")
    r = subprocess.run([sys.executable, "-B", str(JOB / "tool" / "compose_preview.py"), str(scene_path)],
                       capture_output=True, text=True)
    print((r.stdout + r.stderr).strip())
    return r.returncode


if __name__ == "__main__":
    raise SystemExit(main())
