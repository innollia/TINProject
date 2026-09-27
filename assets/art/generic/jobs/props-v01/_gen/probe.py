"""Scratch: find the single-brick crop inside a 3x3 brick wall.

    py -3 -B _gen/probe.py
"""

from __future__ import annotations

import json
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]

CROPS = [(6.0, 5.8, 8.8, 9.0), (6.4, 6.2, 8.4, 8.6), (5.9, 5.7, 9.1, 9.3),
         (1.0, 1.0, 4.4, 4.4)]
COLORS = ["#3a2340", "#6a2b3a", "#2b3f6b", "#8a7434"]
W = 150
forms = []
for i, (crop, col) in enumerate(zip(CROPS, COLORS)):
    forms.append({"name": f"c{i}", "kind": "flat", "color": col,
                  "pieces": [{"icon": "brick_wall", "crop": list(crop),
                              "at": [W // 2 + (i % 2) * W, 60 + (i // 2) * 110],
                              "size": [110, 84], "squash": 0.5}]})
rec = {"asset": "zz_probe", "palette": "palette_props.json", "style": "prop",
       "canvas": [2 * W, 200], "pivot": [W, 100], "seed": 1, "forms": forms}
out = JOB / "recipes" / "zz_probe.json"
out.write_text(json.dumps(rec, indent=2) + "\n", encoding="utf-8")
print(out)
