"""Per-stage registry + palette writer shared by every g06 stage job."""

from __future__ import annotations

import copy
import json
from pathlib import Path

from .palettes import build_palette, write_palette


class Stage:
    def __init__(self, job: Path, num: int, pal_id: str, note: str, colors: dict, mats: dict, ppm=320.0):
        self.job = Path(job)
        self.rec = self.job / "recipes"
        self.num = num
        self.pal = pal_id + ".json"
        self.pal_id = pal_id
        self.note = note
        self.colors = colors
        self.mats = mats
        self.ppm = ppm
        self.registry: dict = {}
        self.extra_palettes: list = []   # [(file_name, fn(pal) -> pal)]

    def asset(self, name):
        def deco(fn):
            self.registry[name] = fn
            return fn
        return deco

    def palettes(self):
        pal = build_palette(self.rec / "palette_h0_mood.json", self.pal_id, self.note, self.colors, self.mats)
        write_palette(self.rec / self.pal, pal)
        for name, fn in self.extra_palettes:
            write_palette(self.rec / name, fn(copy.deepcopy(pal)))

    def write_all(self, wanted=()):
        from . import write
        self.palettes()
        n = 0
        for name, fn in self.registry.items():
            if wanted and not any(w in name for w in wanted):
                continue
            write(self.rec, fn())
            n += 1
        return n


def desat_palette(pal: dict, new_id: str, note: str, tint=(0.62, 0.7, 0.6), amount=0.85) -> dict:
    """Same-value monochrome variant (CCTV / old photograph / film)."""
    def conv(hexv):
        h = hexv.lstrip("#")
        r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
        y = min(1.0, (0.299 * r + 0.587 * g + 0.114 * b) * 1.08)
        mix = [(1 - amount) * c + amount * y * t / 0.66 for c, t in zip((r, g, b), tint)]
        return "#" + "".join(f"{int(max(0, min(1, v)) * 255 + 0.5):02x}" for v in mix)

    out = copy.deepcopy(pal)
    out["id"] = new_id
    out["source"] = out.get("source", "") + " " + note
    for k, v in list(out["colors"].items()):
        if isinstance(v, str) and v.startswith("#"):
            out["colors"][k] = conv(v)
    for m in out["materials"].values():
        for key in ("base", "shadow", "light", "line", "side", "side_shadow"):
            if isinstance(m.get(key), str) and m[key].startswith("#"):
                m[key] = conv(m[key])
    for st in out["styles"].values():
        if isinstance(st.get("background"), str):
            st["background"] = conv(st["background"])
    return out


def write_scene(stage: Stage, name, bg, items, chars, exits, hot, scale=0.5, note=None):
    def r(p):
        return [round(p[0], 1), round(p[1], 1)]

    region = name.replace(f"scene_s{stage.num:02d}_", "")
    scene = {"status": "candidate",
             "note": note or ("Stage %02d layout. items = objects drawn by compose_preview.py; characters = placements "
                              "for the game only (never composited in review images); exits = transition hotspot "
                              "polygons (background px)." % stage.num),
             "background": f"output/{bg}/{bg}.png", "scale": scale,
             "items": items, "characters": chars,
             "exits": {k: [r(p) for p in v] for k, v in exits.items()},
             "hotspots": hot,
             "out": f"preview/{name}_bg_objects_1280x720.png"}
    (stage.rec / f"{name}.json").write_text(json.dumps(scene, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return name
