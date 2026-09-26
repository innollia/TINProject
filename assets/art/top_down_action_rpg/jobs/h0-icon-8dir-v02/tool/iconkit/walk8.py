"""8-direction character rig in the RPG Maker layout, on top of iconkit recipes.

Directions (the number is the RPG Maker / numpad direction code)
    down 2, left 4, right 6, up 8, down_left 1, down_right 3, up_left 7, up_right 9
Sheets
    ``$<asset>.png``       3 columns x 4 rows: down, left, right, up
    ``$<asset>_diag.png``  3 columns x 4 rows: down_left, down_right, up_left, up_right
Columns
    0 = the character's LEFT foot forward, 1 = standing (also the idle frame),
    2 = RIGHT foot forward.  A walk plays 0-1-2-1.

A *view recipe* is an ordinary iconkit recipe (see render.py) plus:

    "view": "down_left",             the direction this recipe draws
    "mirror_view": "down_right",     optional: also build the mirrored direction
    "rig": {
      "depth": 0.5,     screen px per world px of north-south travel (character cheat)
      "stride": 14,     foot travel between front and back foot in a step frame (px)
      "lift": 3,        the trailing foot is raised this much (px)
      "bob": 2,         forms tagged ``body`` tags drop this much in the step frames
      "swing": 8,       hand travel for arms (px)
      "body": ["upper"],
      "limbs": [
        {"kind": "leg", "phase": 1, "pivot": [x, y], "len": 30,
         "thigh": "thigh_left", "foot": "foot_left"},        # thigh bends, boot slides
        {"kind": "leg", "phase": -1, "pivot": [x, y], "len": 60, "tag": "leg_hind_left"},
        {"kind": "arm", "phase": -1, "pivot": [x, y], "len": 45, "tag": "arm_left"}
      ],
      "sway": [{"tag": "scarf_tail", "pivot": [x, y], "rot": 5}]
    }

``phase`` +1 limbs go forward in column 0: the left leg and the right arm of a
biped; the front-left and hind-right leg of a trotting quadruped.  ``pivot`` is
the hip / shoulder and ``len`` the distance from it to the foot / hand at rest;
the limb is rotated and stretched about the pivot so its end lands on the step
position, which is the facing direction projected on screen (x, y * depth).

Asymmetric parts: a form with ``"only": "source"`` is drawn in the authored
view only (e.g. a bag on the side that turns away after mirroring).  A form with
``"only": "mirror"`` is drawn in the mirrored view only, is authored in the
MIRRORED view's own coordinates and is never flipped (e.g. a strap that must
keep its direction).  A ``sway`` entry may carry the same ``only`` key.  The
mirrored view swaps columns 0 and 2 so column 0 is always the left foot.
"""

from __future__ import annotations

import copy
import math

from .render import mirror_forms

DIRECTIONS = {
    "down": {"code": 2, "facing": (0.0, 1.0)},
    "left": {"code": 4, "facing": (-1.0, 0.0)},
    "right": {"code": 6, "facing": (1.0, 0.0)},
    "up": {"code": 8, "facing": (0.0, -1.0)},
    "down_left": {"code": 1, "facing": (-1.0, 1.0)},
    "down_right": {"code": 3, "facing": (1.0, 1.0)},
    "up_left": {"code": 7, "facing": (-1.0, -1.0)},
    "up_right": {"code": 9, "facing": (1.0, -1.0)},
}
SHEETS = {
    "base": ("down", "left", "right", "up"),
    "diag": ("down_left", "down_right", "up_left", "up_right"),
}
MIRROR = {"down": "down", "up": "up", "left": "right", "right": "left",
          "down_left": "down_right", "down_right": "down_left",
          "up_left": "up_right", "up_right": "up_left"}
COLUMNS = (0, 1, 2)
COLUMN_MEANING = {0: "left foot forward", 1: "standing (idle)", 2: "right foot forward"}
WALK_PATTERN = (0, 1, 2, 1)
_SIGN = {0: 1.0, 1: 0.0, 2: -1.0}
RIG_DEFAULTS = {"depth": 0.5, "stride": 14.0, "lift": 3.0, "bob": 2.0, "swing": 8.0,
                "arm_depth": 1.0, "foot_tilt": 0.0, "body": ["upper"]}


def facing(view: str) -> tuple[float, float]:
    fx, fy = DIRECTIONS[view]["facing"]
    n = math.hypot(fx, fy)
    return fx / n, fy / n


def sheet_slot(view: str) -> tuple[str, int]:
    for sheet, rows in SHEETS.items():
        if view in rows:
            return sheet, rows.index(view)
    raise KeyError(view)


def limb_move(pivot, length: float, dx: float, dy: float) -> dict:
    """Rotate + stretch a limb hanging down ``length`` px from ``pivot`` so its end moves by (dx, dy)."""
    ex, ey = dx, length + dy
    reach = math.hypot(ex, ey)
    return {"pivot": [float(pivot[0]), float(pivot[1])],
            "rot": round(math.degrees(math.atan2(-ex, ey)), 3),
            "sy": round(reach / length, 4)}


def walk_moves(recipe: dict, col: int, mirrored: bool = False) -> dict:
    """Frame ``move`` dict for one column of the recipe's own (authored) view."""
    rig = dict(RIG_DEFAULTS, **recipe.get("rig", {}))
    s = _SIGN[col]
    moves: dict = {}
    if not s:
        return moves
    fx, fy = facing(recipe["view"])
    ux, uy = fx, fy * float(rig["depth"])
    for limb in rig.get("limbs", []):
        a = float(limb.get("phase", 1)) * s
        length = float(limb["len"])
        if limb.get("kind", "leg") == "leg":
            d = a * float(limb.get("stride", rig["stride"])) / 2.0
            dx, dy = ux * d, uy * d
            if d < 0:
                dy -= float(limb.get("lift", rig["lift"]))
            if limb.get("foot"):
                moves[limb["thigh"]] = limb_move(limb["pivot"], length, dx, dy)
                foot = {"dx": round(dx, 3), "dy": round(dy, 3)}
                tilt = float(limb.get("foot_tilt", rig["foot_tilt"]))
                if d < 0 and tilt:
                    foot["rot"] = round(fx * tilt, 3)  # trailing heel lifts
                moves[limb["foot"]] = foot
            else:
                moves[limb["tag"]] = limb_move(limb["pivot"], length, dx, dy)
        else:
            d = a * float(limb.get("swing", rig["swing"]))
            dx, dy = ux * d, uy * d * float(rig["arm_depth"])
            moves[limb["tag"]] = limb_move(limb["pivot"], length, dx, dy)
    width = recipe["canvas"][0]
    for sw in rig.get("sway", []):
        only = sw.get("only")
        if (only == "mirror" and not mirrored) or (only == "source" and mirrored):
            continue
        pivot = list(sw["pivot"])
        if only == "mirror":
            # authored in mirrored coordinates; the renderer flips afterwards, so pre-flip the pivot
            # (flip . rotate(t, p) . flip = rotate(-t, flip(p)) and the mirrored column sign is -s)
            pivot = [width - pivot[0], pivot[1]]
        moves[sw["tag"]] = {"pivot": pivot, "rot": float(sw.get("rot", 0.0)) * s,
                            "dx": float(sw.get("dx", 0.0)) * s, "dy": float(sw.get("dy", 0.0)) * abs(s)}
    for tag in rig["body"]:
        moves[tag] = {"dx": 0.0, "dy": float(rig["bob"])}
    return moves


def view_frames(recipe: dict) -> list[dict]:
    """Frames for the authored view (columns 0-2) and, if any, its mirrored view."""
    view = recipe["view"]
    if view not in DIRECTIONS:
        raise ValueError(f"unknown view {view!r}")
    frames = [{"name": f"{view}_{c}", "view": view, "col": c, "move": walk_moves(recipe, c)} for c in COLUMNS]
    mview = recipe.get("mirror_view")
    if mview:
        if MIRROR[view] != mview or mview == view:
            raise ValueError(f"{view} cannot mirror to {mview}")
        frames += [{"name": f"{mview}_{c}", "view": mview, "col": c, "mirror": True,
                    "mirrored_from": f"{view}_{2 - c}",
                    "move": walk_moves(recipe, 2 - c, mirrored=True)} for c in COLUMNS]
    return frames


def frame_recipe(recipe: dict, frame: dict) -> dict:
    """The recipe as the renderer must see it for ``frame``.

    ``only`` forms are removed from the views they do not belong to (removed, not
    hidden by name: a hide list would also catch every form that merely carries
    that name as a tag).  In the mirrored view, mirror-only forms are pre-flipped
    so the renderer's flip puts them back where they were authored.
    """
    mirrored = bool(frame.get("mirror"))
    drop = "source" if mirrored else "mirror"
    out = dict(recipe)
    forms = [f for f in copy.deepcopy(recipe["forms"]) if f.get("only") != drop]
    if mirrored:
        mirror_forms([f for f in forms if f.get("only") == "mirror"], recipe["canvas"][0])
    out["forms"] = forms
    return out
