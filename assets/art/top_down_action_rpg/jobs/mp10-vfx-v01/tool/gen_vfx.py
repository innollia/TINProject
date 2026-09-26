"""mp10-vfx-v01 recipe generator (session 10, TIN icon-collage mass production).

    py -3 -B gen_vfx.py            # writes ../recipes/palette_mp10.json and every vfx recipe
    py -3 -B gen_vfx.py vfx_hit    # only the named assets (palette is always rewritten)

Effects change geometry frame by frame, so each frame gets its own forms
(tagged with the frame name, hidden by default) and the recipe's ``frames``
list shows one tag set per frame.  The JSON recipes this writes are the build
input and stay next to the results; this script is how they were made.

Coordinates are final output px.  Angles are degrees on screen (0 = right,
90 = down).  Palette: palette_h0_mood.json (V1) + the fx materials below.
"""

from __future__ import annotations

import copy
import json
import math
import sys
from pathlib import Path

JOB = Path(__file__).resolve().parents[1]
RECIPES = JOB / "recipes"
PALETTE = "palette_mp10.json"

# circle.svg paints ~0.4..15.6 of the 16-unit box; with fit "box" a size of
# 2r*K gives a disc of radius r.
K_CIRCLE = 16.0 / 15.2

# ----------------------------------------------------------------- palette
FX_COLORS = {
    "kiln_amber": "#b07a3c",
    "record_grey": "#8f8a80",
    "extreme_red": "#b34c3c",
    "fx_glow_warm": "#ffc987",
}
FX_MATERIALS = {
    # neutral bright shapes (guard arcs, brackets, wedges): V1 bone paper
    "fx_bone": {"base": "#b3a486", "shadow": "#8a7d64", "light": "#cfc2a3", "line": "#3a2f25"},
    # flash cores (emissive)
    "fx_flash": {"base": "#e9dcbc", "shadow": "#b3a486", "light": "#fff3d6", "line": "#4a3f33"},
    # hot sparks (emissive): V1 ember family
    "fx_ember": {"base": "#d0763a", "shadow": "#8a4424", "light": "#f5a860", "line": "#2a1208"},
    # dark debris / ink flecks
    "fx_ink": {"base": "#1a1420", "shadow": "#0f0a11", "light": "#2c2433", "line": "#07050a"},
    # muted (miss): V1 worn grey-violet
    "fx_mute": {"base": "#6e6878", "shadow": "#4d4856", "light": "#857e90", "line": "#15101b"},
    # brighter muted grey for thin miss arcs and drain drops (readable on the dark combat plate)
    "fx_mute_light": {"base": "#938da0", "shadow": "#6e6878", "light": "#aaa4b6", "line": "#15101b"},
    # drain droplets (resource spend)
    "fx_drain": {"base": "#5a5362", "shadow": "#3a3440", "light": "#756d80", "line": "#0f0a11"},
    # status tints (content tint_key names, values are this job's design)
    "fx_amber": {"base": "#b07a3c", "shadow": "#7a5128", "light": "#dca764", "line": "#241608"},
    "fx_amber_hot": {"base": "#e09a4c", "shadow": "#b07a3c", "light": "#ffd08a", "line": "#241608"},
    "fx_grey": {"base": "#8f8a80", "shadow": "#625e57", "light": "#b3ada0", "line": "#1c1a17"},
    "fx_grey_dark": {"base": "#5c5852", "shadow": "#403d39", "light": "#76716a", "line": "#141210"},
    # document corruption red (= top_down_row.gd EXTREME)
    "fx_red": {"base": "#b34c3c", "shadow": "#7a2f26", "light": "#d0685a", "line": "#2a0d0a"},
    # void cut
    "fx_void": {"base": "#07050a", "shadow": "#07050a", "light": "#231d29", "line": "#07050a"},
    "fx_void_rim": {"base": "#3b3046", "shadow": "#231d29", "light": "#5a4a66", "line": "#07050a"},
    # aftermath stains (V1 soot / grime)
    "fx_soot": {"base": "#2a2428", "shadow": "#1a1519", "light": "#3a3338", "line": "#0e0a12",
                "grime": {"stamps": ["metaballs", "sponge", "cloud"], "size": 18, "soft": 2, "density": 0.35,
                          "strength": 0.35, "color": "grime"}},
    "fx_grime": {"base": "#6e6448", "shadow": "#4d4632", "light": "#857a58", "line": "#1a160c"},
    "fx_rubble": {"base": "#4f4855", "shadow": "#36303d", "light": "#655d6c", "line": "#0c080e"},
    # residue sludge / fibres
    "fx_sludge": {"base": "#6b4a26", "shadow": "#45301a", "light": "#9a6c3a", "line": "#1a1008",
                  "grime": {"stamps": ["metaballs", "sponge"], "size": 10, "soft": 1, "density": 0.35,
                            "strength": 0.3, "color": "grime"}},
    # folded record paper (misfolded)
    "fx_paper": {"base": "#9a9386", "shadow": "#6c665d", "light": "#bab3a4", "line": "#1c1a17",
                 "texture": {"stamp": "leaf", "pre_rot": 45, "length": 10, "width": 3, "angle": 0, "jitter": 10,
                             "density": 0.8, "strength": 0.05},
                 "grime": {"stamps": ["sponge", "metaballs"], "size": 8, "soft": 1.0, "density": 0.25,
                           "strength": 0.25, "color": "foxing"}},
    # contract cord / band
    "fx_cord": {"base": "#7d786e", "shadow": "#55514b", "light": "#a19b8f", "line": "#141210",
                "texture": {"stamp": "pill", "pre_rot": -45, "length": 8, "width": 2, "angle": 90, "jitter": 6,
                            "density": 0.8, "strength": 0.08}},
    # token plate
    "fx_plate": {"base": "#1f1924", "shadow": "#141017", "light": "#2e2634", "line": "#07050a"},
}


def write_palette() -> None:
    base = json.loads((RECIPES / "palette_h0_mood.json").read_text(encoding="utf-8"))
    pal = copy.deepcopy(base)
    pal["id"] = "palette_mp10"
    pal["status"] = "candidate"
    pal["source"] = ("mp10-vfx-v01: palette_h0_mood.json (V1) unchanged, plus fx_* materials for effects and "
                     "status tints. Outline, shadow and shared colours are V1's. kiln_amber / record_grey have "
                     "no colour value in content (tint_key names only), so the values here are this job's design.")
    pal["colors"].update(FX_COLORS)
    pal["materials"].update(FX_MATERIALS)
    (RECIPES / PALETTE).write_text(json.dumps(pal, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


# ----------------------------------------------------------------- helpers
def r2(v: float) -> float:
    return round(float(v), 2)


def piece(icon: str, at, size, rot: float = 0.0, **kw) -> dict:
    d = {"icon": icon, "at": [r2(at[0]), r2(at[1])]}
    d["size"] = [r2(s) if s is not None else None for s in size] if isinstance(size, (list, tuple)) else r2(size)
    if rot:
        d["rot"] = r2(rot)
    d.update(kw)
    return d


def polar(c, r: float, a_deg: float):
    a = math.radians(a_deg)
    return (c[0] + r * math.cos(a), c[1] + r * math.sin(a))


def wedge_poly(a0: float, a1: float, radius: float = 12.0) -> list:
    """Icon-unit polygon (centre 8,8) covering the angular range a0..a1 (degrees)."""
    steps = max(2, int(abs(a1 - a0) / 12.0) + 1)
    pts = [[8.0, 8.0]]
    for i in range(steps + 1):
        a = math.radians(a0 + (a1 - a0) * i / steps)
        pts.append([r2(8.0 + radius * math.cos(a)), r2(8.0 + radius * math.sin(a))])
    return pts


def arc(c, r_out: float, width: float, a0: float, a1: float, squash: float = 1.0) -> list:
    """Ring segment pieces (add + sub).  Put one arc centre per form."""
    d = 2.0 * r_out
    inner = 2.0 * max(0.5, r_out - width)
    add = piece("circle", c, [d * K_CIRCLE, d * K_CIRCLE * squash], fit="box")
    if abs((a1 - a0) - 360.0) > 1e-6:
        add["poly"] = wedge_poly(a0, a1)
    sub = piece("circle", c, [inner, inner * squash], op="sub")
    return [add, sub]


def disc(c, r: float, squash: float = 1.0, **kw) -> dict:
    return piece("circle", c, [2 * r, 2 * r * squash], **kw)


def shard(c, length: float, width: float, a_deg: float, **kw) -> dict:
    """Tapered diamond whose long axis points along a_deg."""
    return piece("diamond", c, [width, length], rot=a_deg + 90.0, **kw)


def bar(c, length: float, width: float, a_deg: float = 0.0, **kw) -> dict:
    """Straight bar with small rounded ends (nine-sliced square)."""
    corner = max(1.0, min(width, length) / 2.0)
    return piece("square", c, [length, width], rot=a_deg, slice={"border": 4, "corner": r2(corner)}, **kw)


def polyline(points, width: float, **kw) -> list:
    out = []
    for (x0, y0), (x1, y1) in zip(points[:-1], points[1:]):
        L = math.hypot(x1 - x0, y1 - y0)
        a = math.degrees(math.atan2(y1 - y0, x1 - x0))
        out.append(bar(((x0 + x1) / 2, (y0 + y1) / 2), L + width * 0.6, width, a, **kw))
    return out


def sparkle(c, size: float, rot: float = 0.0, **kw) -> dict:
    """Four-point sparkle cut from stars.svg (the large one)."""
    return piece("stars", c, size, rot=rot, crop=[0.8, 4.8, 8.8, 14.8], **kw)


def transform(pieces: list, pivot, rot: float = 0.0, dx: float = 0.0, dy: float = 0.0) -> list:
    """Rotate piece centres about ``pivot`` and add the rotation to each piece."""
    out = []
    a = math.radians(rot)
    for p in pieces:
        q = copy.deepcopy(p)
        x, y = q["at"][0] - pivot[0], q["at"][1] - pivot[1]
        q["at"] = [r2(pivot[0] + x * math.cos(a) - y * math.sin(a) + dx),
                   r2(pivot[1] + x * math.sin(a) + y * math.cos(a) + dy)]
        if rot:
            q["rot"] = r2(q.get("rot", 0.0) + rot)
        out.append(q)
    return out


def frac(v: float) -> float:
    return v - math.floor(v)


class Asset:
    def __init__(self, asset: str, canvas, pivot, pivot_meaning: str, note: str, seed: int,
                 style: str = "sprite", meta: dict | None = None, style_override: dict | None = None):
        self.d = {"asset": asset, "status": "candidate", "note": note, "palette": PALETTE, "style": style,
                  "canvas": list(canvas), "pivot": list(pivot), "pivot_meaning": pivot_meaning, "seed": seed}
        if style_override:
            self.d["style_override"] = style_override
        self.d["vfx"] = {"blend": "normal", **(meta or {})}
        self.forms: list = []
        self.frames: list = []
        self._n = 0

    def form(self, tags, label: str, pieces: list, material: str, kind: str = "flat", z: float = 0.0, **kw) -> dict:
        self._n += 1
        tags = [tags] if isinstance(tags, str) else list(tags)
        f = {"name": f"{tags[0]}__{label}_{self._n}", "tags": tags, "hidden": True, "z": z, "kind": kind,
             "material": material, "pieces": pieces}
        f.update(kw)
        self.forms.append(f)
        return f

    def frame(self, name: str, show=None) -> None:
        self.frames.append({"name": name, "show": list(show or [name])})

    def write(self) -> Path:
        self.d["forms"] = self.forms
        self.d["frames"] = self.frames
        path = RECIPES / f"{self.d['asset']}.json"
        path.write_text(json.dumps(self.d, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
        return path


def glow(radius: float, opacity: float, color: str = "lamp_glow") -> dict:
    return {"radius": radius, "opacity": opacity, "color": color}


# ======================================================================= A. combat results
C1 = (96.0, 96.0)
C2 = (192.0, 192.0)
TILT = 8.0  # small global tilt so bursts do not sit exactly on the screen axes


def burst(c, n: int, lengths, width: float, a0: float = 0.0) -> list:
    """Jagged radial spikes starting at the centre (uneven lengths)."""
    out = []
    for k in range(n):
        a = a0 + 360.0 * k / n + (7.0 if k % 2 else -5.0)
        L = lengths[k % len(lengths)]
        out.append(shard(polar(c, L * 0.5, a), L, width * (0.8 if k % 2 else 1.0), a))
    return out


def meta(cell, frames, loop=False, static=None, **kw) -> dict:
    d = {"cell": list(cell), "frames": frames, "loop": loop}
    if static:
        d["static_frame"] = static
    d.update(kw)
    return d


def vfx_hit() -> Asset:
    A = Asset("vfx_hit", (192, 192), C1, "hit point (feedback kind 'hit' position)",
              "Hit (09 12.4 / feedback kind hit). Jagged ember burst under a flash core, four near-cardinal bone "
              "wedges (the game's four hit strokes), ember sparks on the diagonals, dark flecks. Emissive parts "
              "go to _emit.png.", seed=1001, meta=meta((192, 192), 5, static="hit_2"))
    C = C1
    #     flash, fop, burst lengths, bop, wedges(r, L, w, op), sparks(r, L, op), flecks(r, op)
    plan = [(62, 1.0, (22, 30, 18, 26), 0.9, None, None, None),
            (92, 1.0, (34, 46, 30, 40), 0.8, (42, 32, 9, 1.0), (38, 14, 1.0), None),
            (56, 0.85, (24, 32, 20, 28), 0.55, (50, 28, 8, 1.0), (50, 12, 0.9), (46, 1.0)),
            (26, 0.55, None, 0.0, (55, 19, 6, 0.8), (57, 8, 0.8), (53, 0.8)),
            (0, 0.0, None, 0.0, (58, 11, 4, 0.45), (60, 5, 0.5), (58, 0.5))]
    for i, (fl, fop, bl, bop, wd, sp, fk) in enumerate(plan, 1):
        t = f"hit_{i}"
        if bl:
            A.form(t, "burst", burst(C, 10, bl, 10, TILT), "fx_ember", z=1, opacity=bop, emit=0.6,
                   glow=glow(4, 0.4, "ember_glow"))
        if fl:
            A.form(t, "flash", [sparkle(C, fl, TILT), sparkle(C, fl * 0.58, TILT + 45.0), disc(C, fl * 0.18)],
                   "fx_flash", z=5, opacity=fop, emit=1.0, glow=glow(6, 0.6))
        if wd:
            r, L, w, op = wd
            A.form(t, "wedges", [shard(polar(C, r * (1.0 if a % 180 else 0.86), a + TILT),
                                       L * (1.0 if a % 180 else 0.8), w, a + TILT) for a in (0, 90, 180, 270)],
                   "fx_bone", z=3, opacity=op, emit=0.4, glow=glow(3, 0.35))
        if sp:
            r, L, op = sp
            A.form(t, "sparks", [shard(polar(C, r, a + TILT), L, max(3.0, L * 0.36), a + TILT)
                                 for a in (45, 135, 225, 315)],
                   "fx_ember", z=4, opacity=op, emit=0.9, glow=glow(3, 0.5, "ember_glow"))
        if fk:
            r, op = fk
            A.form(t, "flecks", [piece("square", polar(C, r * (0.9 + 0.1 * (k % 2)), a), [5, 5], rot=a + 20)
                                 for k, a in enumerate((20, 110, 160, 250, 300, 340))],
                   "fx_ink", z=2, opacity=op)
        A.frame(t)
    return A


def chevron(c, half_w: float, rise: float, width: float) -> list:
    x, y = c
    return polyline([(x - half_w, y + rise * 0.5), (x, y - rise * 0.5), (x + half_w, y + rise * 0.5)], width)


def vfx_hit_critical() -> Asset:
    A = Asset("vfx_hit_critical", (192, 192), C1, "hit point (feedback kind 'critical' position)",
              "Critical hit (09 12.4 QA / feedback kind critical). Bigger flash and burst than vfx_hit, eight "
              "wedges, and the game's two stacked up-chevrons rising above the hit point.",
              seed=1002, meta=meta((192, 192), 5, static="critical_2"))
    C = C1
    plan = [  # flash, fop, burst, bop, wedge r, wedge op, chevron y (lower), chevron op
        (100, 1.0, (30, 44, 26, 38), 0.95, None, 0.0, None, 0.0),
        (84, 1.0, (40, 54, 34, 48), 0.8, 44, 1.0, 84, 1.0),
        (50, 0.85, (26, 34, 22, 30), 0.5, 52, 0.95, 74, 1.0),
        (22, 0.55, None, 0.0, 56, 0.7, 66, 0.8),
        (0, 0.0, None, 0.0, 59, 0.4, 60, 0.45)]
    for i, (fl, fop, bl, bop, wr, wop, cy, cop) in enumerate(plan, 1):
        t = f"critical_{i}"
        if bl:
            A.form(t, "burst", burst(C, 12, bl, 11, TILT), "fx_ember", z=1, opacity=bop, emit=0.7,
                   glow=glow(5, 0.45, "ember_glow"))
        if fl:
            A.form(t, "flash", [sparkle(C, fl, TILT), sparkle(C, fl * 0.62, TILT + 45.0), disc(C, fl * 0.2)],
                   "fx_flash", z=5, opacity=fop, emit=1.0, glow=glow(7, 0.65))
        if wr:
            A.form(t, "wedges", [shard(polar(C, wr * (1.0 if k % 2 == 0 else 0.9), a + TILT),
                                       (28 if k % 2 == 0 else 20) * (1.0 - 0.12 * (i - 2)), 8 if k % 2 == 0 else 6,
                                       a + TILT) for k, a in enumerate(range(0, 360, 45))],
                   "fx_bone", z=3, opacity=wop, emit=0.4, glow=glow(3, 0.35))
        if cy:
            A.form(t, "chevrons", chevron((96, cy), 22, 18, 7) + chevron((96, cy - 14), 22, 18, 7), "fx_ember",
                   z=6, opacity=cop, emit=0.9, glow=glow(4, 0.5, "ember_glow"))
        A.frame(t)
    return A


def vfx_miss() -> Asset:
    A = Asset("vfx_miss", (192, 192), C1, "strike point that was missed (feedback kind 'miss' position)",
              "Miss (feedback kind miss). The game's two arcs bowing away from each other '( )' drift apart in a "
              "muted grey while a faint streak passes through the gap. No flash.",
              seed=1003, meta=meta((192, 192), 4, static="miss_2"))
    R = 46.0
    plan = [(14, 0.6, 6, (72, 0.45)), (24, 1.0, 7, (98, 0.55)), (34, 0.75, 6, (122, 0.35)), (44, 0.4, 5, None)]
    for i, (d, op, w, streak) in enumerate(plan, 1):
        t = f"miss_{i}"
        A.form(t, "arc_r", arc((96 + d - R, 96), R, w + 2, -46, 46), "fx_mute_light", z=2, opacity=op)
        A.form(t, "arc_l", arc((96 - d + R, 96), R, w + 2, 134, 226), "fx_mute_light", z=2, opacity=op)
        if streak:
            x, sop = streak
            A.form(t, "streak", [shard((x, 96), 70, 6, 0.0), shard((x - 14, 106), 36, 4, 0.0)], "fx_mute_light", z=1,
                   opacity=sop)
        A.frame(t)
    return A


def vfx_guard() -> Asset:
    A = Asset("vfx_guard", (192, 192), C1, "guarded actor point (feedback kind 'guard' / event stance_guard)",
              "Guard (feedback kind guard, event stance_guard). The game's two shell arcs above and below close in; "
              "sparks flash at their tips when they clamp.", seed=1004, meta=meta((192, 192), 4, static="guard_3"))
    C = C1
    plan = [(62, 6, 0.5, 0.0), (52, 8, 0.85, 0.0), (44, 9, 1.0, 1.0), (44, 8, 0.65, 0.35)]
    for i, (R, w, op, spark) in enumerate(plan, 1):
        t = f"guard_{i}"
        A.form(t, "arcs", arc(C, R, w, -153, -27) + arc(C, R, w, 27, 153), "fx_bone", z=2, opacity=op,
               emit=0.3, glow=glow(3, 0.3))
        if spark:
            tips = [polar(C, R - w / 2, a) for a in (-153, -27, 27, 153)]
            A.form(t, "tips", [sparkle(p, 20 * spark + 6, TILT) for p in tips], "fx_flash", z=4, opacity=spark,
                   emit=1.0, glow=glow(4, 0.5))
        A.frame(t)
    return A


def arc_segments(a0: float, a1: float, n: int, gap: float) -> list:
    step = (a1 - a0) / n
    return [(a0 + k * step + gap / 2, a0 + (k + 1) * step - gap / 2) for k in range(n)]


def vfx_guard_broken() -> Asset:
    A = Asset("vfx_guard_broken", (192, 192), C1, "guarded actor point (event guard_broken)",
              "Guard broken (event guard_broken). The shell arcs crack into three pieces each and fly apart.",
              seed=1005, meta=meta((192, 192), 4, static="guard_broken_2"))
    C = C1
    R, w = 44.0, 8.0
    plan = [(0.0, 0.0, 1.0, 1.0), (4.0, 3.0, 1.0, 0.8), (11.0, 9.0, 0.8, 0.0), (18.0, 16.0, 0.4, 0.0)]
    for i, (d, spin, op, crack) in enumerate(plan, 1):
        t = f"guard_broken_{i}"
        gap = 2.0 if i == 1 else 7.0
        for side, (a0, a1) in enumerate(((-153, -27), (27, 153))):
            for k, (s0, s1) in enumerate(arc_segments(a0, a1, 3, gap)):
                mid = (s0 + s1) / 2
                off = polar((0, 0), d, mid)
                pcs = transform(arc(C, R, w, s0, s1), polar(C, R, mid), rot=spin * (1 if k % 2 else -1),
                                dx=off[0], dy=off[1] + (d * 0.4 if i > 2 else 0.0))
                A.form(t, f"seg{side}{k}", pcs, "fx_bone", z=2, opacity=op, emit=0.3, glow=glow(3, 0.3))
        if crack:
            pts = [polar(C, R - w / 2, a) for a in (-111, -69, 69, 111)]
            A.form(t, "cracks", [sparkle(p, 16, TILT) for p in pts], "fx_flash", z=4, opacity=crack, emit=1.0,
                   glow=glow(4, 0.5))
        if i >= 2:
            chips = [shard(polar(C, R + 6 + d * 1.3, a), 9, 4, a + 60) for a in (-130, -90, -50, 50, 90, 130)]
            A.form(t, "chips", chips, "fx_bone", z=3, opacity=op * 0.9)
        A.frame(t)
    return A


def vfx_dodge() -> Asset:
    A = Asset("vfx_dodge", (192, 192), C1, "dodging actor point (feedback kind 'dodge' / event stance_dodge)",
              "Dodge (feedback kind dodge, event stance_dodge). The game's two horizontal speed lines sweep "
              "sideways with shorter streaks and a small dust puff where the body pushed off.",
              seed=1006, meta=meta((192, 192), 4, static="dodge_2"))
    plan = [(70, 60, 0.7, 0.0), (96, 128, 1.0, 0.7), (116, 104, 0.75, 0.5), (130, 60, 0.4, 0.2)]
    for i, (x, L, op, dust) in enumerate(plan, 1):
        t = f"dodge_{i}"
        A.form(t, "lines", [shard((x, 74), L, 7, 0.0), shard((x - 6, 118), L * 0.92, 7, 0.0)], "fx_bone", z=2,
               opacity=op, emit=0.25, glow=glow(3, 0.25))
        A.form(t, "streaks", [shard((x - 18, 96), L * 0.5, 4, 0.0), shard((x + 10, 88), L * 0.3, 3, 0.0),
                              shard((x - 4, 106), L * 0.35, 3, 0.0)], "fx_mute", z=1, opacity=op * 0.9)
        if dust:
            A.form(t, "dust", [piece("metaballs", (48 + 6 * i, 134), [30 + 6 * i, 16 + 3 * i], rot=-12),
                               piece("sponge", (64 + 6 * i, 142), [18, 11], flip="x")], "fx_mute", z=0, opacity=dust)
        A.frame(t)
    return A


def rect_dashes(c, hw: float, hh: float, dash: float, gap: float, thick: float) -> list:
    """Dash centres, lengths and angles along a rectangle outline."""
    cx, cy = c
    out = []
    for (x0, y0, x1, y1) in ((cx - hw, cy - hh, cx + hw, cy - hh), (cx + hw, cy - hh, cx + hw, cy + hh),
                             (cx + hw, cy + hh, cx - hw, cy + hh), (cx - hw, cy + hh, cx - hw, cy - hh)):
        L = math.hypot(x1 - x0, y1 - y0)
        n = max(1, int((L + gap) // (dash + gap)))
        used = n * dash + (n - 1) * gap
        start = (L - used) / 2
        a = math.degrees(math.atan2(y1 - y0, x1 - x0))
        for k in range(n):
            s = (start + k * (dash + gap) + dash / 2) / L
            out.append(((x0 + (x1 - x0) * s, y0 + (y1 - y0) * s), dash, a))
    return out


CRACK = [(118, 50), (160, 118), (146, 158), (204, 214), (196, 250), (262, 334)]
CRACK_DIR = (CRACK[-1][0] - CRACK[0][0], CRACK[-1][1] - CRACK[0][1])


def crack_side(p) -> int:
    """+1 = upper-right of the break line, -1 = lower-left."""
    vx, vy = CRACK_DIR
    wx, wy = p[0] - CRACK[0][0], p[1] - CRACK[0][1]
    return 1 if vx * wy - vy * wx < 0 else -1


def frame_halves(A: Asset, t: str, shift: float, spin: float, op: float, z: float = 2.0) -> None:
    for side in (1, -1):
        pcs = [bar(p, L, 7, a) for p, L, a in rect_dashes(C2, 104, 140, 22, 12, 7) if crack_side(p) == side]
        pcs = transform(pcs, C2, rot=spin * side, dx=shift * side, dy=-shift * side)
        A.form(t, f"half{side}", pcs, "fx_bone", z=z, opacity=op, emit=0.3, glow=glow(3, 0.3))


def vfx_break() -> Asset:
    A = Asset("vfx_break", (384, 384), C2, "enemy centre (event break_applied; enemy body_scale 1.0 fits)",
              "Break moment (feedback kind break, event break_applied). The game's dashed frame around the enemy "
              "splits along a bright diagonal crack and sheds shards; the last frame is where "
              "art_effect_break_window starts.", seed=1007, meta=meta((384, 384), 5, static="break_3"))
    shards_out = [((150, 96), 150), ((214, 178), -40), ((182, 236), 120), ((240, 262), 20), ((132, 150), 200),
                  ((226, 118), -70)]
    plan = [  # shift, spin, frame op, crack op, flash, shard travel, shard op
        (0.0, 0.0, 0.9, 0.0, 74, 0.0, 0.0),
        (0.0, 0.0, 1.0, 1.0, 40, 0.0, 0.9),
        (8.0, 2.0, 1.0, 0.9, 0, 18.0, 1.0),
        (14.0, 3.0, 0.95, 0.6, 0, 34.0, 0.7),
        (12.0, 2.5, 0.9, 0.45, 0, 0.0, 0.0)]
    for i, (shift, spin, fop, cop, fl, travel, sop) in enumerate(plan, 1):
        t = f"break_{i}"
        frame_halves(A, t, shift, spin, fop)
        if cop:
            A.form(t, "crack", polyline(CRACK, 6), "fx_flash", z=4, opacity=cop, emit=1.0, glow=glow(5, 0.55))
        if fl:
            A.form(t, "flash", [sparkle((168, 150), fl, TILT), disc((168, 150), fl * 0.16)], "fx_flash", z=5,
                   emit=1.0, glow=glow(6, 0.6))
        if sop:
            pcs = []
            for (p, a) in shards_out:
                q = polar(p, travel, a)
                pcs.append(piece("triangle", (q[0], q[1] + travel * 0.35), [14, 18], rot=a + travel * 3))
            A.form(t, "shards", pcs, "fx_bone", z=3, opacity=sop, emit=0.2)
        A.frame(t)
    return A


def stamp_squares(xs, y: float, size: float) -> list:
    pcs = []
    for x in xs:
        pcs.append(piece("square", (x, y), [size, size], slice={"border": 4, "corner": r2(size * 0.18)}))
        pcs.append(piece("square", (x, y), [size * 0.5, size * 0.5], slice={"border": 4, "corner": 2.0},
                         op="sub"))
    return pcs


def vfx_status_apply() -> Asset:
    A = Asset("vfx_status_apply", (192, 192), C1, "affected actor point (feedback kind 'status' / event status_applied)",
              "Status applied (feedback kind status, event status_applied). The game's three small squares drop "
              "in and stamp onto the target with an impact ring. Two colour sets: amber (tint_key kiln_amber) "
              "and grey (tint_key record_grey).", seed=1008,
              meta=meta((192, 192), 4, static="amber_3", states=["amber", "grey"]))
    xs = (70, 96, 122)
    for tint, mat, hot, em in (("amber", "fx_amber", "fx_amber_hot", 0.6), ("grey", "fx_grey", "fx_grey", 0.15)):
        plan = [(66, 16, 0.6, 0.0, 0.0), (92, 27, 1.0, 0.0, 0.8), (96, 23, 1.0, 1.0, 1.0), (96, 23, 0.6, 0.35, 0.3)]
        for i, (y, s, op, ring, ticks) in enumerate(plan, 1):
            t = f"{tint}_{i}"
            A.form(t, "stamps", stamp_squares(xs, y, s), mat, z=3, opacity=op, emit=em * 0.5, glow=glow(3, 0.3))
            if i == 1:
                A.form(t, "fall", [shard((x, y - 20), 16, 4, 90) for x in xs], mat, z=1, opacity=0.35)
            if ring:
                R = 44 if i == 3 else 54
                A.form(t, "ring", arc(C1, R, 4, 0, 360, squash=0.55), hot, z=2, opacity=ring, emit=em,
                       glow=glow(3, 0.4))
            if ticks:
                A.form(t, "ticks", [bar(polar((96, 96), 34, a), 10, 3, a) for a in (200, 240, 300, 340, 20, 160)],
                       hot, z=2, opacity=ticks, emit=em)
            A.frame(t)
    return A


def vfx_charge_gather() -> Asset:
    A = Asset("vfx_charge_gather", (192, 192), C1, "charging actor point",
              "Charge gathering (09 12.4 charge), loops while an action is being charged. Three rings of motes "
              "stream inward to a warm core; two orbit arcs turn around it.",
              seed=1009, meta=meta((192, 192), 4, loop=True, static="charge_3"))
    for i in range(4):
        t = f"charge_{i + 1}"
        for k in range(3):
            f = frac(k / 3.0 + i / 4.0)
            r = 28.0 + 36.0 * (1.0 - f)
            op = 0.35 + 0.65 * f
            base = k * 20.0 + i * 12.0
            pcs = [shard(polar(C1, r, base + a), 12 - 4 * (1 - f), 4, base + a + 12) for a in range(0, 360, 60)]
            A.form(t, f"motes{k}", pcs, "fx_bone", z=2, opacity=op, emit=0.5 * op, glow=glow(3, 0.35))
        core = (8, 10, 12, 10)[i]
        A.form(t, "core", [disc(C1, core), sparkle(C1, core * 3.2, TILT + i * 20)], "fx_ember", z=4,
               emit=1.0, glow=glow(5, 0.6, "ember_glow"))
        spin = i * 22.0
        A.form(t, "orbit_a", arc(C1, 38, 4, spin - 40, spin + 30), "fx_bone", z=3, opacity=0.8, emit=0.3)
        A.form(t, "orbit_b", arc(C1, 38, 4, spin + 140, spin + 210), "fx_bone", z=3, opacity=0.8, emit=0.3)
        A.frame(t)
    return A


def vfx_resource_gain() -> Asset:
    A = Asset("vfx_resource_gain", (192, 192), C1, "resource point (HP/MP restore)",
              "Resource gain (09 12.4 resource change, increase). Light motes and small sparkles rise and fade. "
              "Direction (up) and shape tell it apart from vfx_resource_spend, not colour alone.",
              seed=1010, meta=meta((192, 192), 4, static="gain_2"))
    motes = [(70, 146, "d"), (84, 132, "s"), (96, 150, "d"), (108, 128, "s"), (122, 144, "d"), (78, 158, "s"),
             (114, 156, "d")]
    for i in range(4):
        t = f"gain_{i + 1}"
        pcs_d, pcs_s = [], []
        for k, (x, y0, kind) in enumerate(motes):
            y = y0 - 24 * i - (k % 3) * 4
            if y < 44:
                continue
            if kind == "d":
                pcs_d.append(disc((x, y), 4.5 - 0.5 * i))
            else:
                pcs_s.append(sparkle((x, y), 15 - 2 * i, TILT))
        op = (0.75, 1.0, 0.8, 0.45)[i]
        if pcs_d:
            A.form(t, "motes", pcs_d, "fx_flash", z=2, opacity=op, emit=0.8, glow=glow(3, 0.45))
        if pcs_s:
            A.form(t, "sparkles", pcs_s, "fx_flash", z=3, opacity=op, emit=1.0, glow=glow(3, 0.5))
        if i < 2:
            A.form(t, "base", arc((96, 160), 30 + 8 * i, 3, 200, 340, squash=0.4), "fx_bone", z=1,
                   opacity=0.6 - 0.2 * i, emit=0.3)
        A.frame(t)
    return A


def vfx_resource_spend() -> Asset:
    A = Asset("vfx_resource_spend", (192, 192), C1, "resource point (HP/MP spent or lost)",
              "Resource spend (09 12.4 resource change, decrease). Muted drops fall and stretch, then splash in "
              "a small ring. Falling direction and drop shape tell it apart from vfx_resource_gain.",
              seed=1011, meta=meta((192, 192), 4, static="spend_2"))
    drops = [(72, 52), (90, 62), (104, 48), (120, 58), (84, 40)]
    for i in range(4):
        t = f"spend_{i + 1}"
        pcs = []
        for k, (x, y0) in enumerate(drops):
            y = y0 + 26 * i + (k % 2) * 6
            if y > 150:
                continue
            pcs.append(piece("droplet", (x, y), [14 - i, 19 + 3 * i]))
        op = (0.8, 1.0, 0.85, 0.5)[i]
        if pcs:
            A.form(t, "drops", pcs, "fx_mute_light", z=2, opacity=op, line={"width": 1.0, "heavy": 0.8,
                                                                            "color": "#4d4856"})
        if i >= 2:
            A.form(t, "splash", arc((96, 150), 26 + 8 * (i - 2), 4, 180, 360, squash=0.45), "fx_mute_light", z=1,
                   opacity=0.8 - 0.3 * (i - 2))
        A.frame(t)
    return A


def l_bracket(corner, sx: int, sy: int, arm: float, thick: float) -> list:
    x, y = corner
    return [bar((x + sx * (arm / 2 - thick / 2), y), arm, thick, 0.0),
            bar((x, y + sy * (arm / 2 - thick / 2)), arm, thick, 90.0)]


def brackets(c, hw: float, hh: float, arm: float, thick: float) -> list:
    cx, cy = c
    out = []
    for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1)):
        out += l_bracket((cx - sx * hw, cy - sy * hh), sx, sy, arm, thick)
    return out


def vfx_target_confirm() -> Asset:
    A = Asset("vfx_target_confirm", (384, 384), C2, "enemy centre (target confirmed; enemy body_scale 1.0 fits)",
              "Target confirmation (feedback kind queued, 09 4.4 confirm). The game's four corner brackets snap "
              "in around the enemy bounds (202x272 source px at body_scale 1.0) and the centre square appears.",
              seed=1012, meta=meta((384, 384), 4, static="confirm_4", bracket_bounds=[202, 272]))
    for i, (k, op, flash) in enumerate(((1.14, 0.6, 0.0), (1.06, 0.9, 0.0), (1.0, 1.0, 1.0), (1.0, 1.0, 0.0)), 1):
        t = f"confirm_{i}"
        hw, hh = 101 * k, 136 * k
        A.form(t, "brackets", brackets(C2, hw, hh, 56, 7), "fx_flash", z=2, opacity=op, emit=0.6, glow=glow(4, 0.4))
        if i >= 3:
            A.form(t, "centre", [piece("square", C2, [28, 28], slice={"border": 4, "corner": 4}),
                                 piece("square", C2, [18, 18], slice={"border": 4, "corner": 2}, op="sub")],
                   "fx_flash", z=3, emit=0.6)
        if flash:
            A.form(t, "flash", [sparkle((C2[0] + sx * hw, C2[1] + sy * hh), 26, TILT)
                                for sx, sy in ((1, 1), (-1, 1), (-1, -1), (1, -1))], "fx_flash", z=4, emit=1.0,
                   glow=glow(5, 0.55))
        A.frame(t)
    return A


# ======================================================================= B. art_effect_* keys
def art_effect_charge_tell() -> Asset:
    A = Asset("art_effect_charge_tell", (384, 384), C2, "enemy centre (charge_state stage; body_scale 1.0 fits)",
              "Enemy charge tell (09 12.10 art_effect_charge_tell; combat_state.gd charge stages). Follows the "
              "game's order: telegraph = right half ring filling top to bottom, reaction = closed ring pulsing "
              "(the answer window), strike = up-pointing wedge flashes while the ring collapses, cancelled = "
              "ring breaks apart (event charge_cancelled). Ember colour, emissive.", seed=2001,
              meta=meta((384, 384), 14, loop=False, states={"telegraph": 4, "reaction": 4, "strike": 3,
                                                             "cancelled": 3},
                        loop_states=["reaction"], static_frame="reaction_2"))
    R = 150.0
    for i in range(1, 5):
        t = f"telegraph_{i}"
        end = -90 + 45 * i
        A.form(t, "arc", arc(C2, R, 10, -90, end), "fx_ember", z=2, opacity=0.75 + 0.06 * i, emit=0.8,
               glow=glow(5, 0.5, "ember_glow"))
        A.form(t, "lead", [sparkle(polar(C2, R - 5, end), 24, TILT), disc(polar(C2, R - 5, end), 5)], "fx_flash",
               z=3, emit=1.0, glow=glow(5, 0.55))
        A.form(t, "ticks", [bar(polar(C2, R - 20, a), 12, 4, a) for a in range(-90, end + 1, 45)], "fx_ember", z=2,
               opacity=0.8, emit=0.6)
        A.frame(t)
    for i, (w, op, tick) in enumerate(((12, 0.8, 0.6), (16, 1.0, 1.0), (12, 0.85, 0.7), (9, 0.7, 0.5)), 1):
        t = f"reaction_{i}"
        A.form(t, "ring", arc(C2, R, w, 0, 360), "fx_ember", z=2, opacity=op, emit=0.9, glow=glow(6, 0.55, "ember_glow"))
        A.form(t, "ticks", [bar(polar(C2, R - w - 10, a), 14, 4, a) for a in range(0, 360, 30)], "fx_amber_hot",
               z=3, opacity=tick, emit=0.8)
        A.frame(t)
    tri = [(192, 46), (252, 128), (132, 128)]
    for i, (Rr, rop, tscale, top_) in enumerate(((150, 1.0, 0.7, 0.9), (122, 0.8, 1.0, 1.0), (98, 0.4, 1.0, 0.5)), 1):
        t = f"strike_{i}"
        A.form(t, "ring", arc(C2, Rr, 14 if i == 1 else 10, 0, 360), "fx_ember", z=2, opacity=rop, emit=0.9,
               glow=glow(6, 0.55, "ember_glow"))
        cx, cy = 192, 104
        pts = [(cx + (x - cx) * tscale, cy + (y - cy) * tscale) for x, y in tri]
        A.form(t, "wedge", polyline(pts + [pts[0]], 9), "fx_amber_hot", z=4, opacity=top_, emit=1.0,
               glow=glow(6, 0.6, "flame_glow"))
        if i == 2:
            A.form(t, "flash", [sparkle((192, 100), 70, TILT), disc((192, 100), 10)], "fx_flash", z=5, emit=1.0,
                   glow=glow(7, 0.6))
        A.frame(t)
    for i, (d, op) in enumerate(((6, 0.85), (16, 0.55), (28, 0.25)), 1):
        t = f"cancelled_{i}"
        for k, (s0, s1) in enumerate(arc_segments(0, 360, 8, 10 + 4 * i)):
            mid = (s0 + s1) / 2
            off = polar((0, 0), d, mid)
            pcs = transform(arc(C2, R, 9, s0, s1), polar(C2, R, mid), rot=(6 * i) * (1 if k % 2 else -1),
                            dx=off[0], dy=off[1] + 3 * i)
            A.form(t, f"seg{k}", pcs, "fx_ember", z=2, opacity=op, emit=0.5 * op)
        A.frame(t)
    return A


def art_effect_break_window() -> Asset:
    A = Asset("art_effect_break_window", (384, 384), C2, "enemy centre (stance 'broken'; body_scale 1.0 fits)",
              "Break window (09 12.10), loops while the enemy stays broken. Continues vfx_break's last frame: the "
              "split frame halves hang apart and the crack glows open and shut.", seed=2002,
              meta=meta((384, 384), 4, loop=True, static_frame="window_1"))
    for i, (shift, cw, cop, gop) in enumerate(((12.0, 6, 0.45, 0.35), (13.0, 8, 0.7, 0.5), (14.0, 10, 0.9, 0.65),
                                              (13.0, 8, 0.7, 0.5)), 1):
        t = f"window_{i}"
        frame_halves(A, t, shift, 2.5, 0.9)
        A.form(t, "gap", polyline(CRACK, cw + 8), "fx_ember", z=3, opacity=gop, emit=0.8, blur=2.5,
               glow=glow(6, 0.5, "ember_glow"))
        A.form(t, "crack", polyline(CRACK, cw * 0.6), "fx_flash", z=4, opacity=cop, emit=1.0, glow=glow(4, 0.5))
        A.frame(t)
    return A


def corruption_asset(mode: str, canvas, note: str, seed: int, frames_fn) -> Asset:
    pivot = (0, canvas[1] // 2) if canvas[0] > canvas[1] else (canvas[0] // 2, canvas[1] // 2)
    A = Asset(f"art_effect_document_corruption_{mode}", canvas, pivot,
              "left end of the token span on the text line centre" if canvas[0] > canvas[1] else "glyph centre",
              note, seed=seed,
              meta=meta(canvas, 3, static=f"{mode}_3", art_key="art_effect_document_corruption",
                        corruption_mode=mode, line_height_source_px=64,
                        **({"slice": {"left": 32, "right": 32}} if canvas[0] > canvas[1] else {})))
    frames_fn(A)
    return A


def corruption_recolor() -> Asset:
    def fr(A: Asset):
        for i in range(1, 4):
            t = f"recolor_{i}"
            if i >= 2:
                A.form(t, "smear", [bar((192, 32), 352, 36, 0.0)], "fx_red", z=1, opacity=0.3 + 0.08 * i,
                       rough={"amp": 0.45, "soft": 2, "cell": 10})
            A.form(t, "rule", [bar((192 if i > 1 else 150, 56), 352 if i > 1 else 240, 3, 0.0)], "fx_red", z=2,
                   emit=0.3)
            if i == 3:
                A.form(t, "tick", l_bracket((10, 10), 1, 1, 12, 3), "fx_red", z=3, emit=0.3)
            A.frame(t)
    return corruption_asset("recolor", (384, 64),
                            "Document corruption 'recolor' (09 7.3 red span; top_down_row.gd recolor). Red smear "
                            "behind a token span with a narrow rule under it, and the severity corner tick. The red "
                            "never comes alone: the rule and tick change the line shape too. Three-slice: the left "
                            "and right 32 px stay fixed, the middle stretches to the span.", 2003, fr)


def corruption_replace_token() -> Asset:
    def fr(A: Asset):
        c = (32, 32)
        for i in range(1, 4):
            t = f"replace_token_{i}"
            dx = 4 if i == 3 else 0
            box = [piece("square", (c[0] + dx, c[1]), [40, 40], slice={"border": 4, "corner": 4}),
                   piece("square", (c[0] + dx, c[1]), [32, 32], slice={"border": 4, "corner": 2}, op="sub")]
            if i >= 2:
                A.form(t, "fill", [piece("square", (c[0] + dx, c[1]), [36, 36], slice={"border": 4, "corner": 3})],
                       "fx_plate", z=1)
            A.form(t, "box", box, "fx_grey", z=2, opacity=0.6 if i == 1 else 1.0)
            if i == 3:
                A.form(t, "bar", [bar((9, 32), 44, 2.5, 90.0)], "fx_grey", z=2)
            A.frame(t)
    return corruption_asset("replace_token", (64, 64),
                            "Document corruption 'replace_token' (09 7.3 glyph break; top_down_row.gd "
                            "replace_token). A boxed blank covers one glyph, then jitters sideways with a thin "
                            "bar at its left. No glyph drawn.", 2004, fr)


def corruption_shatter_line() -> Asset:
    def fr(A: Asset):
        segs = [(16, 100), (106, 190), (196, 280), (286, 368)]
        offs = [0, -4, 3, -2]
        for i in range(1, 4):
            t = f"shatter_line_{i}"
            pcs = []
            for k, (x0, x1) in enumerate(segs):
                if i == 1:
                    continue
                g = 0 if i == 1 else 3
                y = 56 + (offs[k] if i == 3 else 0)
                a = (-2.5 if k % 2 else 2.0) if i == 3 else 0.0
                pcs.append(bar(((x0 + x1) / 2, y), x1 - x0 - 2 * g, 3, a))
            if i == 1:
                pcs = [bar((192, 56), 352, 3, 0.0)]
            A.form(t, "rule", pcs, "fx_grey", z=2)
            if i >= 2:
                A.form(t, "chips", [piece("square", (x, 60 + 2 * i), [3, 3], rot=30) for x in (103, 193, 283)],
                       "fx_grey", z=2, opacity=0.8)
            A.frame(t)
    return corruption_asset("shatter_line", (384, 64),
                            "Document corruption 'shatter_line' (09 7.3 line split; top_down_row.gd shatter_line). "
                            "The line's rule cracks into four pieces that step up and down. Three-slice like "
                            "recolor.", 2005, fr)


def corruption_drop_glyph() -> Asset:
    def fr(A: Asset):
        for i in range(1, 4):
            t = f"drop_glyph_{i}"
            A.form(t, "gaps", [bar((22, 32), 44, 2.5, 90.0), bar((42, 32), 44, 2.5, 90.0)], "fx_grey", z=2,
                   opacity=(0.5, 1.0, 1.0)[i - 1])
            if i == 3:
                A.form(t, "fall", [piece("square", (28 + 5 * k, 52 + 3 * k), [3.5, 3.5], rot=20 * k)
                                   for k in range(3)], "fx_grey", z=2, opacity=0.8)
            A.frame(t)
    return corruption_asset("drop_glyph", (64, 64),
                            "Document corruption 'drop_glyph' (09 7.3 glyph break; top_down_row.gd drop_glyph). "
                            "Two thin bars mark where glyphs dropped out; small bits fall from the gap.", 2006, fr)


def art_effect_portal_void_cut() -> Asset:
    A = Asset("art_effect_portal_void_cut", (384, 384), (192, 352), "foot of the cut on the floor (field)",
              "Void cut (09 12.10; 12_MAGIC_THEORY 3.3 scissors cut the void). A bright cut line opens into a "
              "narrow slit of void with torn paper-like rims and drifting flecks. Kept narrower than a person so "
              "it never reads as a walkable door. Opening = frames 1-3, hold loop = 4-5, closing = play 3-1 "
              "backwards. Floor contact shadow in _shadow.png.", seed=2007,
              meta=meta((384, 384), 5, loop=False, static="cut_4", loop_frames=["cut_4", "cut_5"]))
    top, bottom = 96.0, 346.0
    cy, H = (top + bottom) / 2, bottom - top
    flecks = [(-34, 150), (30, 200), (-28, 250), (38, 120), (-40, 300), (26, 280)]
    plan = [(0, 0, 1.0, 0.0), (14, 24, 0.6, 0.0), (28, 42, 0.3, 0.6), (34, 48, 0.0, 1.0), (31, 45, 0.0, 1.0)]
    for i, (w, rim, line_op, fl) in enumerate(plan, 1):
        t = f"cut_{i}"
        A.form(t, "contact", [disc((192, 350), 22 + w * 0.6, squash=0.3)], "fx_void", kind="shadow", z=0,
               color="shadow_contact", opacity=0.45, blur=3)
        if rim:
            A.form(t, "rim", [piece("diamond", (192, cy), [rim, H + 10])], "fx_void_rim", z=1, emit=0.35,
                   rough={"amp": 0.55, "soft": 1.5, "cell": 8}, glow=glow(4, 0.35, "#8a78a0"))
            A.form(t, "void", [piece("diamond", (192, cy), [w, H - 6])], "fx_void", z=2,
                   rough={"amp": 0.35, "soft": 1.0, "cell": 8})
        if line_op:
            A.form(t, "cut", [piece("diamond", (192, cy), [5, H + 6])], "fx_flash", z=3, opacity=line_op, emit=1.0,
                   glow=glow(5, 0.6))
            if i == 1:
                A.form(t, "snips", [sparkle((192, top + 4), 26, TILT), sparkle((192, bottom - 6), 20, TILT)],
                       "fx_flash", z=4, emit=1.0, glow=glow(4, 0.5))
        if fl:
            pcs = []
            for k, (dx, y) in enumerate(flecks):
                drift = (i - 3) * 8
                pcs.append(piece("triangle", (192 + dx * (1 + 0.15 * (i - 3)), y - drift - k * 2), [8, 10],
                                 rot=k * 50 + i * 25))
            A.form(t, "flecks", pcs, "fx_bone", z=3, opacity=fl * 0.85)
        A.frame(t)
    return A


def trace_forms(A: Asset, t: str, op: float, grow: float, long: bool) -> None:
    if long:
        c = (192.0, 96.0)
        A.form(t, "drag", [piece("pill", (c[0] - 10, c[1]), [300 * grow, 30], rot=-4, ground=True),
                           piece("metaballs", (c[0] - 150, c[1] + 4), [60 * grow, 44], ground=True)],
               "fx_soot", kind="mass", z=1, opacity=op * 0.85, shade={"bump": 0.2, "highlight_amount": 0.1},
               rough={"amp": 0.5, "soft": 2, "cell": 10})
        A.form(t, "scratches", [bar((c[0] - 6, c[1] - 9 + 6 * k), 250 * grow, 2, -4 + k) for k in range(4)],
               "fx_grime", z=2, opacity=op * 0.7)
        debris = [(c[0] + 150, c[1] - 4), (c[0] + 132, c[1] + 16), (c[0] + 164, c[1] + 14), (c[0] + 118, c[1] - 18)]
    else:
        c = (96.0, 96.0)
        A.form(t, "stain", [piece("metaballs", (c[0] - 8, c[1] + 4), [96 * grow, 70 * grow], rot=18, ground=True),
                            piece("sponge", (c[0] + 22, c[1] - 12), [44 * grow, 36 * grow], rot=-30, ground=True)],
               "fx_soot", kind="mass", z=1, opacity=op * 0.85, shade={"bump": 0.2, "highlight_amount": 0.1},
               rough={"amp": 0.5, "soft": 2, "cell": 9})
        A.form(t, "scuffs", [bar((c[0] - 30 + 16 * k, c[1] + 26 - 4 * k), 44, 3, -24 + 6 * k) for k in range(3)],
               "fx_grime", z=2, opacity=op * 0.7)
        debris = [(c[0] + 40, c[1] + 20), (c[0] - 44, c[1] - 18), (c[0] + 30, c[1] - 36), (c[0] - 20, c[1] + 40)]
    A.form(t, "debris", [piece("triangle" if k % 2 else "square", p, [9, 7], rot=40 * k) for k, p in enumerate(debris)],
           "fx_rubble", kind="mass", z=3, opacity=min(1.0, op * 1.1))
    A.form(t, "scrap", [piece("file", (c[0] + (60 if long else 2), c[1] + (-20 if long else -30)), [18, 22], rot=26,
                              ground=True)], "fx_paper", kind="mass", z=3, opacity=op,
           shade={"bump": 0.25, "highlight_amount": 0.25})


def art_effect_aftermath_trace() -> Asset:
    A = Asset("art_effect_aftermath_trace", (192, 192), C1, "centre of the trace on the floor (floor layer)",
              "Aftermath trace (09 12.10, 8.2, 12.8): pressed soot stain, scuffs, grit and a paper scrap on the "
              "60-degree floor, fading in. Dark plum-brown instead of blood (no permanent gore).", seed=2008,
              meta=meta((192, 192), 4, static="trace_4", layer="floor"))
    for i, (op, g) in enumerate(((0.3, 0.82), (0.6, 0.92), (0.85, 1.0), (1.0, 1.0)), 1):
        t = f"trace_{i}"
        trace_forms(A, t, op, g, False)
        A.frame(t)
    return A


def art_effect_aftermath_trace_drag() -> Asset:
    A = Asset("art_effect_aftermath_trace_drag", (384, 192), (192, 96), "centre of the drag mark on the floor",
              "Aftermath trace, long drag variant (same key art_effect_aftermath_trace): something heavy was "
              "dragged left to right, leaving a smear, parallel scratches and grit at the end.", seed=2009,
              meta=meta((384, 192), 4, static="drag_4", layer="floor", art_key="art_effect_aftermath_trace"))
    for i, (op, g) in enumerate(((0.3, 0.8), (0.6, 0.9), (0.85, 1.0), (1.0, 1.0)), 1):
        t = f"drag_{i}"
        trace_forms(A, t, op, g, True)
        A.frame(t)
    return A


# ======================================================================= C. statuses
# Enemy body reference inside a 384 cell (game _draw_actor, body_scale 1.0): centre (192,192),
# half width 81, half height 116 -> head top y 76, feet y 308, waist y ~206.
def status_asset(sid: str, note: str, seed: int, stacks: int) -> Asset:
    states = {f"stack{s}": 4 for s in range(1, stacks + 1)} if stacks > 1 else {"loop": 4}
    return Asset(sid, (384, 384), C2, "enemy centre (status overlay drawn over the enemy; body_scale 1.0)",
                 note, seed=seed,
                 meta=meta((384, 384), 4 * max(1, stacks), loop=True,
                           static=(f"stack1_1" if stacks > 1 else "loop_1"), states=states, status_id=sid))


def st_concentration_load() -> Asset:
    A = status_asset("st_concentration_load",
                     "st_concentration_load (stacks 3, blocks magic and charge commit, tint kiln_amber). Heavy amber "
                     "halo rings press down over the head, one ring per stack, with hot beads and down-chevrons.",
                     3001, 3)
    for s in range(1, 4):
        for i, (dy, hot) in enumerate(((0, 0.6), (3, 0.8), (6, 1.0), (3, 0.8)), 1):
            t = f"stack{s}_{i}"
            for k in range(s):
                y = 74 - 13 * k + dy
                A.form(t, f"ring{k}", arc((192, y), 46 - 4 * k, 7 + (1 if i == 3 else 0), 0, 360, squash=0.3),
                       "fx_amber", z=2 + k, emit=0.35, glow=glow(3, 0.35, "ember_glow"))
                beads = [polar((192, y), 46 - 4 * k, a) for a in (40, 90, 140)]
                beads = [(bx, by - (46 - 4 * k) * (1 - 0.3) * math.sin(math.radians(a)) * 0.0)
                         for (bx, by), a in zip(beads, (40, 90, 140))]
                A.form(t, f"beads{k}", [disc((192 + (46 - 4 * k) * math.cos(math.radians(a)),
                                              y + (46 - 4 * k) * 0.3 * math.sin(math.radians(a))), 5)
                                        for a in (40, 90, 140)], "fx_amber_hot", z=2.5 + k, opacity=hot, emit=hot,
                       glow=glow(3, 0.5, "ember_glow"))
            A.form(t, "press", chevron((192, 100 + dy), 16, -10, 4) + chevron((172, 104 + dy), 10, -7, 3)
                   + chevron((212, 104 + dy), 10, -7, 3), "fx_amber", z=1, opacity=0.7)
            A.frame(t)
    return A


def st_overflowed() -> Asset:
    A = status_asset("st_overflowed",
                     "st_overflowed (blocks magic, tint kiln_amber; 12_MAGIC_THEORY 8 involuntary emission). Amber "
                     "wisps leak up from the shoulders and sides, a brimming rim spills over the head and drips.",
                     3002, 1)
    vents = [(132, 128), (252, 128), (116, 190), (268, 190), (140, 246), (244, 246)]
    for i in range(4):
        t = f"loop_{i + 1}"
        wisps = []
        for k, (x, y) in enumerate(vents):
            f = frac(i / 4.0 + k * 0.37)
            wy = y - 12 - 34 * f
            wisps.append((piece("droplet", (x + (6 if k % 2 else -6) * f, wy), [12 - 5 * f, 24 - 6 * f]), 1.0 - 0.8 * f))
        for k, (p, op) in enumerate(wisps):
            A.form(t, f"wisp{k}", [p], "fx_amber_hot", z=3, opacity=op, emit=0.9 * op, glow=glow(4, 0.5, "ember_glow"))
        A.form(t, "rim", arc((192, 84), 58, 6, 190, 350, squash=0.32) + arc((192, 84), 58, 4, 10, 170, squash=0.32),
               "fx_amber_hot", z=2, emit=0.7, glow=glow(4, 0.45, "ember_glow"))
        drips = []
        for k, x in enumerate((146, 176, 214, 240)):
            f = frac(i / 4.0 + k * 0.29)
            drips.append(piece("droplet", (x, 96 + 30 * f), [7, 11]))
        A.form(t, "drips", drips, "fx_amber", z=2, emit=0.4)
        A.frame(t)
    return A


def st_medium_residue() -> Asset:
    A = status_asset("st_medium_residue",
                     "st_medium_residue (stacks 3, agility -1, cures st_misfolded, tint kiln_amber). Sticky amber-brown "
                     "residue pools at the feet with fibres in it; each stack adds a clump higher on a leg; drips "
                     "fall into the pool.", 3003, 3)
    clumps = [((160, 280), (46, 30)), ((228, 262), (40, 26)), ((150, 236), (34, 22))]
    for s in range(1, 4):
        for i in range(4):
            t = f"stack{s}_{i + 1}"
            wob = (1.0, 1.03, 1.0, 0.97)[i]
            A.form(t, "pool", [piece("metaballs", (192, 316), [170 * wob, 44], ground=True),
                               piece("sponge", (150, 322), [60, 24], ground=True)], "fx_sludge", kind="mass", z=1,
                   shade={"bump": 0.5, "highlight_amount": 0.4}, line={"width": 0.9, "heavy": 0.8, "color": "#9a6c3a"})
            A.form(t, "fibres", [bar((170 + 22 * k, 314 + (k % 2) * 6), 26, 2, -20 + 25 * k) for k in range(3)],
                   "fx_bone", z=2, opacity=0.55)
            for k in range(s - 1 + 1):
                if k == 0:
                    continue
                (x, y), (w, h) = clumps[k - 1]
                A.form(t, f"clump{k}", [piece("metaballs", (x, y), [w, h], rot=20 * k)], "fx_sludge", kind="mass",
                       z=2, shade={"bump": 0.5, "highlight_amount": 0.4},
                       line={"width": 0.9, "heavy": 0.8, "color": "#9a6c3a"})
            drips = []
            for k in range(s):
                (x, y), _ = clumps[k] if k < len(clumps) else clumps[-1]
                f = frac(i / 4.0 + k * 0.33)
                drips.append(piece("droplet", (x + 4, y + 16 + 22 * f), [8, 11]))
            A.form(t, "drips", drips, "fx_sludge", z=2, line={"width": 0.8, "heavy": 0.6, "color": "#9a6c3a"})
            if i == 2:
                A.form(t, "bubble", arc((214, 312), 7, 2, 0, 360), "fx_amber", z=3, opacity=0.8)
            A.frame(t)
    return A


def facet(c, size: float) -> tuple:
    """Unrotated folded facet: light half (apex left) and a foreshortened shadow half (apex right)
    meeting on a vertical crease at ``c``.  Rotate both with ``transform``."""
    light = [piece("triangle", (c[0] - size * 0.31, c[1]), [size * 0.9, size * 0.62], rot=-90)]
    dark = [piece("triangle", (c[0] + size * 0.21, c[1]), [size * 0.9, size * 0.42], rot=90)]
    return light, dark


def st_misfolded() -> Asset:
    A = status_asset("st_misfolded",
                     "st_misfolded (single, tint record_grey; 12_MAGIC_THEORY 3.2 failed rigid fold). Folded paper "
                     "facets hang at wrong angles around the body and wobble; each shows a light face, a shadow "
                     "face and the crease.", 3004, 1)
    spots = [((120, 110), 44, 20), ((266, 124), 40, -35), ((104, 214), 38, 70), ((282, 236), 42, -110)]
    for i in range(4):
        t = f"loop_{i + 1}"
        for k, (c, size, rot) in enumerate(spots):
            wob = 8.0 * math.sin(math.radians(90 * i + 70 * k))
            bob = 3.0 * math.cos(math.radians(90 * i + 50 * k))
            cc = (c[0], c[1] + bob)
            light, dark = facet(cc, size)
            light = transform(light, cc, rot=rot + wob)
            dark = transform(dark, cc, rot=rot + wob)
            A.form(t, f"light{k}", light, "fx_paper", kind="mass", z=2 + k * 0.1,
                   shade={"bump": 0.2, "highlight_amount": 0.3})
            A.form(t, f"dark{k}", dark, "fx_grey_dark", kind="mass", z=2 + k * 0.1 + 0.05,
                   shade={"bump": 0.2, "highlight_amount": 0.1})
            A.form(t, f"crease{k}", [bar(cc, size * 0.8, 2.5, rot + wob + 90)], "fx_ink", z=2.5 + k * 0.1,
                   opacity=0.8)
        A.frame(t)
    return A


def st_contract_bound() -> Asset:
    A = status_asset("st_contract_bound",
                     "st_contract_bound (single, agility -1, blocks charge commit, tint record_grey). A stitched "
                     "cord band wraps the waist with a knot at the front and tightens and eases.", 3005, 1)
    for i, (R, w) in enumerate(((104, 12), (100, 13), (96, 14), (100, 13)), 1):
        t = f"loop_{i}"
        c = (192, 206)
        A.form(t, "back", arc(c, R, 5, 190, 350, squash=0.26), "fx_cord", z=1, opacity=0.5)
        A.form(t, "front", arc(c, R, w, 8, 172, squash=0.26), "fx_cord", kind="mass", z=3,
               shade={"bump": 0.35, "highlight_amount": 0.3}, line={"width": 0.8, "heavy": 0.8, "color": "#a19b8f"})
        stitches = []
        for a in range(20, 170, 18):
            p = (c[0] + (R - w / 2) * math.cos(math.radians(a)), c[1] + (R - w / 2) * 0.26 * math.sin(math.radians(a)))
            stitches.append(bar(p, w + 2, 2, 90 + (a - 90) * 0.25))
        A.form(t, "stitches", stitches, "fx_grey_dark", z=4, opacity=0.9)
        A.form(t, "knot", [piece("knot", (192, 206 + R * 0.26 + 4), [30, 30], rot=-10 + 4 * (i % 2),
                                 crop=[1.5, 2.5, 13.5, 14.5])], "fx_cord", kind="mass", z=5,
               shade={"bump": 0.4, "highlight_amount": 0.3})
        A.frame(t)
    return A


def ledger_slip(c, tick: float) -> tuple:
    x, y = c
    slip = [piece("square", c, [64, 16], slice={"border": 4, "corner": 3})]
    rule = [bar((x + 6, y), 34, 2, 0.0)]
    ticks = []
    if tick > 0:
        ticks = [piece("checkmark", (x - 22, y - 1), [12 * tick + 2, 10 * tick + 2])]
    return slip, rule, ticks


def st_recorded() -> Asset:
    A = status_asset("st_recorded",
                     "st_recorded (stacks 3, agility -1, tint record_grey). Ledger slips float beside the body on a "
                     "thin tag line, one slip per stack; the newest slip's tick writes itself in. No text.", 3006, 3)
    for s in range(1, 4):
        for i, (bob, tick) in enumerate(((0, 0.0), (-2, 0.5), (-3, 1.0), (-1, 1.0)), 1):
            t = f"stack{s}_{i}"
            A.form(t, "tag", polyline([(272, 170), (298, 150 + bob)], 2), "fx_grey", z=1, opacity=0.6)
            for k in range(s):
                c = (318, 150 + 30 * k + bob * (1 + 0.3 * k))
                slip, rule, ticks = ledger_slip(c, tick if k == s - 1 else 1.0)
                A.form(t, f"slip{k}", slip, "fx_paper", kind="mass", z=2 + k * 0.1,
                       shade={"bump": 0.2, "highlight_amount": 0.25})
                A.form(t, f"rule{k}", rule, "fx_grey_dark", z=2.05 + k * 0.1)
                if ticks:
                    A.form(t, f"tick{k}", ticks, "fx_ink", z=2.07 + k * 0.1)
            A.frame(t)
    return A


def st_tokens() -> Asset:
    A = Asset("st_tokens", (128, 128), (64, 64), "token centre (player combat band status row)",
              "Status tokens for the player combat band (content presentation.icon_key = status id). Dark plate, "
              "tint rim (amber = kiln_amber, grey = record_grey), the status motif, and 1-3 pips for stacks. "
              "No text or numbers.", seed=3007,
              meta=meta((128, 128), 12, static=None, sheet_cols=16))
    c = (64.0, 64.0)
    tint = {"st_concentration_load": "fx_amber", "st_overflowed": "fx_amber", "st_medium_residue": "fx_amber",
            "st_misfolded": "fx_grey", "st_contract_bound": "fx_grey", "st_recorded": "fx_grey"}
    frames = [("st_concentration_load", 3), ("st_overflowed", 1), ("st_medium_residue", 3), ("st_misfolded", 1),
              ("st_contract_bound", 1), ("st_recorded", 3)]
    for sid, stacks in frames:
        for s in range(1, stacks + 1):
            t = f"{sid}_{s}" if stacks > 1 else sid
            mat = tint[sid]
            A.form(t, "plate", [disc(c, 50)], "fx_plate", kind="mass", z=0,
                   shade={"bump": 0.3, "highlight_amount": 0.2})
            A.form(t, "rim", arc(c, 52, 6, 0, 360), mat, z=1, emit=0.25 if mat == "fx_amber" else 0.0)
            if sid == "st_concentration_load":
                A.form(t, "m1", arc((64, 44), 26, 5, 0, 360, squash=0.32), "fx_amber", z=2, emit=0.4)
                A.form(t, "m2", arc((64, 56), 22, 5, 0, 360, squash=0.32), "fx_amber", z=2, emit=0.4)
                A.form(t, "m3", chevron((64, 76), 12, -8, 4), "fx_amber_hot", z=2, emit=0.6)
            elif sid == "st_overflowed":
                A.form(t, "m1", arc((64, 70), 26, 5, 10, 170, squash=0.35), "fx_amber", z=2, emit=0.4)
                A.form(t, "m2", [piece("droplet", (52, 48), [10, 20]), piece("droplet", (66, 40), [11, 24]),
                                 piece("droplet", (78, 50), [9, 18])], "fx_amber_hot", z=2, emit=0.8,
                       glow=glow(3, 0.5, "ember_glow"))
                A.form(t, "m3", [piece("droplet", (46, 84), [7, 10]), piece("droplet", (82, 86), [7, 10])],
                       "fx_amber", z=2)
            elif sid == "st_medium_residue":
                A.form(t, "m1", [piece("metaballs", (64, 70), [58, 34])], "fx_sludge", kind="mass", z=2,
                       shade={"bump": 0.5, "highlight_amount": 0.4}, line={"width": 0.8, "heavy": 0.7,
                                                                            "color": "#9a6c3a"})
                A.form(t, "m2", [bar((58, 66), 22, 2, -25), bar((72, 74), 18, 2, 30)], "fx_bone", z=3, opacity=0.6)
                A.form(t, "m3", [piece("droplet", (50, 90), [7, 10])], "fx_sludge", z=2)
            elif sid == "st_misfolded":
                light, dark = facet(c, 58)
                A.form(t, "m1", transform(light, c, rot=-20), "fx_paper", kind="mass", z=2,
                       shade={"bump": 0.2, "highlight_amount": 0.3})
                A.form(t, "m2", transform(dark, c, rot=-20), "fx_grey_dark", kind="mass", z=2.1)
                A.form(t, "m3", [bar(c, 46, 2.5, 70)], "fx_ink", z=2.2)
            elif sid == "st_contract_bound":
                A.form(t, "m1", arc((64, 62), 36, 8, 8, 172, squash=0.32), "fx_cord", kind="mass", z=2,
                       shade={"bump": 0.35, "highlight_amount": 0.3})
                A.form(t, "m2", arc((64, 62), 36, 3, 190, 350, squash=0.32), "fx_cord", z=1.5, opacity=0.6)
                A.form(t, "m3", [piece("knot", (64, 76), [26, 26], crop=[1.5, 2.5, 13.5, 14.5])], "fx_cord",
                       kind="mass", z=3, shade={"bump": 0.4, "highlight_amount": 0.3})
            elif sid == "st_recorded":
                A.form(t, "m1", [piece("square", (64, 60), [52, 44], slice={"border": 4, "corner": 4})], "fx_paper",
                       kind="mass", z=2, shade={"bump": 0.2, "highlight_amount": 0.25})
                A.form(t, "m2", [bar((70, 48 + 11 * k), 30, 2.5, 0.0) for k in range(3)], "fx_grey_dark", z=3)
                A.form(t, "m3", [piece("checkmark", (46, 50), [11, 9]), piece("checkmark", (46, 61), [11, 9])],
                       "fx_ink", z=3)
            if stacks > 1:
                xs = {1: [64], 2: [57, 71], 3: [50, 64, 78]}[s]
                A.form(t, "pips", [disc((x, 102), 4) for x in xs], mat, z=4,
                       emit=0.4 if mat == "fx_amber" else 0.0)
            A.frame(t)
    return A


BUILDERS = {
    "vfx_hit": vfx_hit,
    "vfx_hit_critical": vfx_hit_critical,
    "vfx_miss": vfx_miss,
    "vfx_guard": vfx_guard,
    "vfx_guard_broken": vfx_guard_broken,
    "vfx_dodge": vfx_dodge,
    "vfx_break": vfx_break,
    "vfx_status_apply": vfx_status_apply,
    "vfx_charge_gather": vfx_charge_gather,
    "vfx_resource_gain": vfx_resource_gain,
    "vfx_resource_spend": vfx_resource_spend,
    "vfx_target_confirm": vfx_target_confirm,
    "art_effect_charge_tell": art_effect_charge_tell,
    "art_effect_break_window": art_effect_break_window,
    "art_effect_document_corruption_recolor": corruption_recolor,
    "art_effect_document_corruption_replace_token": corruption_replace_token,
    "art_effect_document_corruption_shatter_line": corruption_shatter_line,
    "art_effect_document_corruption_drop_glyph": corruption_drop_glyph,
    "art_effect_portal_void_cut": art_effect_portal_void_cut,
    "art_effect_aftermath_trace": art_effect_aftermath_trace,
    "art_effect_aftermath_trace_drag": art_effect_aftermath_trace_drag,
    "st_concentration_load": st_concentration_load,
    "st_overflowed": st_overflowed,
    "st_medium_residue": st_medium_residue,
    "st_misfolded": st_misfolded,
    "st_contract_bound": st_contract_bound,
    "st_recorded": st_recorded,
    "st_tokens": st_tokens,
}


def main(argv: list) -> int:
    write_palette()
    names = argv or list(BUILDERS)
    for name in names:
        path = BUILDERS[name]().write()
        print("wrote", path.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
