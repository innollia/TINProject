"""Generate people recipes (battle + portrait) from ../recipes/_people.json.

    py -3 -B make_people.py                     # every person in the spec
    py -3 -B make_people.py --only mf_knight,mf_farmer
    py -3 -B make_people.py --tier A --build    # write recipes, then build them

Per person two recipes are written next to the results:
  recipes/<id>_battle.json    canvas 384x384 (human size), frames battle_idle (+ battle_attack, battle_hit for tier A)
  recipes/<id>_portrait.json  canvas 320x320, frame portrait (3/4 bust, fixed face anchor)
Both render into output/<id>/.
"""

from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g02kit import body, head, items, outfit  # noqa: E402
from g02kit.core import (BATTLE_CANVAS, BATTLE_PIVOT, BATTLE_SCALE, BATTLE_SHIFT, PORTRAIT_CANVAS,  # noqa: E402
                         PORTRAIT_HEAD, F, item_dir, place_item, portrait_forms, pose_frames, shift_forms,
                         shift_frames)

JOB = Path(__file__).resolve().parents[1]


def held(spec):
    forms, info, hide = [], {}, set()
    for side in ("r", "l"):
        it = spec.get(f"hand_{side}")
        if not it:
            continue
        layers, rest = items.item(it)
        if rest is None:
            continue
        reach = 0.0
        for suffix, dz, pieces, mat, kw in layers:
            kw = dict(kw)
            variant = kw.pop("variant", None)
            tags = ["upper", f"arm_{side}", f"weapon_{side}", f"grip_{side}"]
            if variant:
                tags.append(f"{variant}_{side}")
                if variant == "front":
                    kw["hidden"] = True
            placed = place_item(pieces, side, rest) if variant != "front" else [
                dict(p, at=[round(p["at"][0] * (1 if side == "r" else -1) + (103 if side == "r" else 217), 2),
                            round(p["at"][1] + 278, 2)]) for p in pieces]
            if variant != "front":
                for p in pieces:
                    reach = max(reach, math.hypot(*p["at"]) + (max(p["size"]) if isinstance(p["size"], list) else p["size"]) / 2)
            name = f"{it['type']}_{side}_{suffix}"
            if "clip_to" in kw:
                kw["clip_to"] = f"{it['type']}_{side}_{kw['clip_to']}"
            forms.append(F(name, round(5.8 + dz + it.get("dz", 0.0), 3), placed, mat, tags, **kw))
        info[side] = {"dir": item_dir(side, rest), "reach": reach}
        if it.get("hide_hand"):
            hide.add(side)
    return forms, info, hide


def build_forms(spec):
    forms = []
    forms += body.shadow()
    forms += body.neck(spec.get("skin", "skin"))
    forms += outfit.garment(spec)
    forms += body.face(spec)
    forms += body.expressions(spec)
    forms += body.hair(spec)
    forms += head.headwear(spec)
    forms += head.facegear(spec)
    forms += outfit.extras(spec)
    extra, info, hide = held(spec)
    forms += extra
    forms = [f for f in forms if not any(f["name"] == f"hand_{s}" for s in hide)]
    for f in forms:
        for s in ("r", "l"):
            if f["name"] in (f"hand_{s}", f"cuff_{s}"):
                f["tags"].append(f"grip_{s}")
    forms += spec.get("forms", [])          # hand-written extra forms, authoring space
    names = [f["name"] for f in forms]
    dup = {n for n in names if names.count(n) > 1}
    if dup:
        raise ValueError(f"{spec['id']}: duplicate form names {sorted(dup)}")
    return forms, info


def recipes_for(spec, palette):
    forms, info = build_forms(spec)
    note = f"{spec['name']} ({spec['genre']}, tier {spec.get('tier', 'B')}). {spec.get('note', '')}".strip()
    battle = {
        "asset": spec["id"], "status": "candidate", "note": note + " Front-view battle picture.",
        "palette": palette, "style": "sprite", "canvas": BATTLE_CANVAS, "pivot": BATTLE_PIVOT,
        "pivot_meaning": "ground contact point between the feet (battle picture, front view)",
        "scale_all": {"factor": round(BATTLE_SCALE * spec.get("figure_scale", 1.0), 4), "origin": BATTLE_PIVOT},
        "seed": spec.get("seed", 1), "forms": shift_forms(forms, BATTLE_SHIFT),
        "frames": shift_frames(pose_frames(spec, info), BATTLE_SHIFT),
    }
    portrait = {
        "asset": spec["id"], "status": "candidate", "note": note + " Dialogue portrait, 3/4 bust, fixed face anchor.",
        "palette": palette, "style": "sprite", "canvas": PORTRAIT_CANVAS, "pivot": [int(PORTRAIT_HEAD[0]), int(PORTRAIT_HEAD[1])],
        "pivot_meaning": "face anchor = head centre, identical in every g02 portrait",
        "seed": spec.get("seed", 1), "forms": portrait_forms(forms), "frames": [{"name": "portrait"}],
    }
    return battle, portrait


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--spec", type=Path, default=None, help="one spec file (default: every recipes/_people*.json)")
    ap.add_argument("--only", default="")
    ap.add_argument("--tier", default="")
    ap.add_argument("--build", action="store_true")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()
    specs = [args.spec] if args.spec else sorted((JOB / "recipes").glob("_people*.json"))
    people, palette = [], "palette_g02.json"
    for sp in specs:
        data = json.loads(sp.read_text(encoding="utf-8"))
        palette = data.get("palette", palette)
        people += data["people"]
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    written = []
    for spec in people:
        if only and spec["id"] not in only:
            continue
        if args.tier and spec.get("tier", "B") not in args.tier:
            continue
        for kind, rec in zip(("battle", "portrait"), recipes_for(spec, palette)):
            path = JOB / "recipes" / f"{spec['id']}_{kind}.json"
            path.write_text(json.dumps(rec, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
            written.append(path)
    print(f"wrote {len(written)} recipes")
    if args.build and written:
        cmd = [sys.executable, "-B", str(Path(__file__).with_name("build.py")), *map(str, written)]
        if args.force:
            cmd.append("--force")
        return subprocess.call(cmd)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
