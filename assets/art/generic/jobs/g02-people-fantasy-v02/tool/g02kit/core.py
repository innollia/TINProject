"""g02 people kit core: geometry, piece/form helpers, poses, portrait transform.

All part coordinates are written in BATTLER space: canvas 320x384, front view,
feet on y=374, x=160 is the body centre.  "r" = the character's right side =
the viewer's LEFT (x < 160); "l" = the viewer's right.  The portrait is the
same character re-framed: head scaled x2 around the head centre and moved to a
fixed face anchor, with a small 3/4 turn toward the viewer's right.

Angles: degrees clockwise on the y-down screen (iconkit convention).  A held
item is authored with its grip at (0, 0) pointing up (-y); ``rest`` is its
direction for the r hand (0 = up, 90 = viewer's right, 180 = down, 270 = left);
the l hand gets the mirror image (-rest).
"""

from __future__ import annotations

import copy
import math

CX = 160.0
BATTLE_CANVAS = [384, 384]      # authored in a 320-wide space, shifted right by BATTLE_SHIFT
BATTLE_PIVOT = [192, 374]
HEAD = (160.0, 126.0)      # centre of the skull / hair mass
FACE = (160.0, 139.0)      # centre of the face oval (72 x 66)
SH = {"r": (113.0, 192.0), "l": (207.0, 192.0)}     # shoulder joints
HAND = {"r": (103.0, 278.0), "l": (217.0, 278.0)}   # grip points at rest
HIP = (160.0, 268.0)
NECK = (160.0, 177.0)

PORTRAIT_CANVAS = [320, 320]
PORTRAIT_K = 2.0
PORTRAIT_HEAD = (160.0, 146.0)
TURN = {"feature": 5.0, "nose": 7.5, "hair": 2.0, "front": 3.0}


def P(icon, x, y, w, h=None, **kw):
    size = [w, h] if h is not None else w
    p = {"icon": icon, "at": [round(float(x), 2), round(float(y), 2)], "size": size}
    p.update(kw)
    return p


def F(name, z, pieces, mat=None, tags=(), **kw):
    f = {"name": name, "z": z, "tags": list(tags), "pieces": pieces}
    if mat:
        f["material"] = mat
    f.update(kw)
    return f


def mx(x):
    return 2 * CX - x


def map_repeat(piece, fpt, k=1.0, rot=0.0, flip_x=False):
    """Carry a piece's ``repeat`` geometry through the same point transform as its ``at``."""
    rep = piece.get("repeat")
    if not rep:
        return
    if "line" in rep:
        rep["line"] = [[round(v, 2) for v in fpt(q)] for q in rep["line"]]
    if "ellipse" in rep:
        cx, cy, rx, ry = rep["ellipse"]
        c = fpt((cx, cy))
        rep["ellipse"] = [round(c[0], 2), round(c[1], 2), rx * k, ry * k]
    if "points" in rep:
        rep["points"] = [[round(v, 2) for v in fpt(q[:2])] + list(q[2:]) for q in rep["points"]]
    if "step" in rep:
        sx, sy = rep["step"]
        if flip_x:
            sx = -sx
        r = math.radians(rot)
        rep["step"] = [round((sx * math.cos(r) - sy * math.sin(r)) * k, 3), round((sx * math.sin(r) + sy * math.cos(r)) * k, 3)]


def mirror(piece, cx=CX):
    q = copy.deepcopy(piece)
    q["at"][0] = round(2 * cx - q["at"][0], 2)
    fl = q.get("flip", "") or ""
    q["flip"] = fl.replace("x", "") if "x" in fl else fl + "x"
    if q.get("rot"):
        q["rot"] = -q["rot"]
    if q.get("skew"):
        q["skew"] = [-q["skew"][0], -q["skew"][1]]
    map_repeat(q, lambda p: (2 * cx - p[0], p[1]), flip_x=True)
    return q


def pair(piece):
    """A piece on the viewer's left plus its mirror on the right."""
    return [piece, mirror(piece)]


def rot_pt(p, c, deg):
    r = math.radians(deg)
    x, y = p[0] - c[0], p[1] - c[1]
    return (c[0] + x * math.cos(r) - y * math.sin(r), c[1] + x * math.sin(r) + y * math.cos(r))


def item_dir(side, rest):
    return rest if side == "r" else -rest


def place_item(pieces, side, rest, origin=None):
    ox, oy = origin or HAND[side]
    out = []
    for p in pieces:
        q = copy.deepcopy(p)
        if side == "l":
            q = mirror(q, 0.0)
        ang = item_dir(side, rest)
        x, y = rot_pt(q["at"], (0.0, 0.0), ang)
        q["at"] = [round(ox + x, 2), round(oy + y, 2)]
        q["rot"] = round(q.get("rot", 0.0) + ang, 2)
        map_repeat(q, lambda p, a=ang: tuple(v + o for v, o in zip(rot_pt(p, (0.0, 0.0), a), (ox, oy))), rot=ang)
        out.append(q)
    return out


# ------------------------------------------------------------------ poses
# per side: (arm rotation around the shoulder, wanted item direction or None, arm foreshortening)
# Long items are only ever raised: a 384 canvas cannot hold a sword pointed sideways.
POSES = {
    "swing": {"r": (150, -20, 1.0), "l": (-28, None, 1.0), "lean": -5, "dx": -5, "legs": 8},
    "thrust": {"r": (35, -45, 0.65), "l": (-20, None, 1.0), "lean": -4, "dx": -6, "legs": 8},
    "aim": {"r": (26, None, 0.52), "l": (-20, None, 1.0), "lean": -2, "dx": -3, "legs": 6, "front": ["r"]},
    "aim2": {"r": (26, None, 0.52), "l": (-26, None, 0.52), "lean": 0, "dx": 0, "legs": 9, "front": ["r", "l"]},
    "punch": {"r": (22, None, 0.5), "l": (-40, None, 1.0), "lean": -6, "dx": -6, "legs": 10, "front": ["r"]},
    "cast": {"r": (120, -10, 1.0), "l": (-62, None, 1.0), "lean": 3, "dx": 0, "legs": 4},
    "throw": {"r": (165, -20, 1.0), "l": (-45, None, 1.0), "lean": 4, "dx": 2, "legs": 6},
    "bow": {"r": (-58, None, 1.0), "l": (-88, 0, 1.0), "lean": 2, "dx": 3, "legs": 6},
    "slam": {"r": (160, -15, 1.0), "l": (-160, None, 1.0), "lean": 3, "dx": 0, "legs": 10},
    "raise": {"r": (30, None, 1.0), "l": (-150, 10, 1.0), "lean": 2, "dx": 2, "legs": 4},
}
HIT_WANT = {"r": 318.0, "l": 42.0}


def _norm(a):
    return (a + 180.0) % 360.0 - 180.0


def _hand_after(side, arm, sy=1.0):
    """Where the r/l grip ends up after the arm is foreshortened by ``sy`` and rotated by ``arm``."""
    sx, syy = SH[side]
    hx, hy = HAND[side]
    return rot_pt((hx, syy + (hy - syy) * sy), SH[side], arm)


def _side_moves(side, arm, want, sy, info, front):
    moves, show, hide = {}, [], []
    if front:
        new = _hand_after(side, arm, sy)
        moves[f"sleeve_{side}"] = {"rot": arm, "sy": sy, "pivot": list(SH[side])}
        moves[f"grip_{side}"] = {"dx": round(new[0] - HAND[side][0], 2), "dy": round(new[1] - HAND[side][1], 2)}
        show.append(f"front_{side}")
        hide.append(f"side_{side}")
        return moves, show, hide
    if arm:
        moves[f"arm_{side}"] = {"rot": arm, "pivot": list(SH[side])}
    rest = info.get("dir")
    if want is not None and rest is not None:
        hand = _hand_after(side, arm or 0.0)
        extra = _norm(want - (rest + (arm or 0.0)))
        if abs(extra) > 0.5:
            moves[f"weapon_{side}"] = {"rot": round(extra, 2), "pivot": [round(hand[0], 2), round(hand[1], 2)]}
    return moves, show, hide


def pose_frames(spec, held_info):
    """battle_idle (+ battle_attack, battle_hit for tier A).
    ``held_info`` = {side: {"dir": absolute rest direction, "reach": px, "gun": bool}}."""
    frames = [{"name": "battle_idle"}]
    if spec.get("tier", "B") != "A":
        return frames
    pose = POSES[spec.get("attack", "swing")]
    move, show, hide = {}, ["brow_angry", "mouth_shout"], ["brow_calm", "mouth_idle"]
    for side in ("r", "l"):
        arm, want, sy = pose[side]
        m, s, h = _side_moves(side, arm, want, sy, held_info.get(side, {}), side in pose.get("front", []))
        move.update(m)
        show += s
        hide += h
    move["head"] = {"dy": 2, "rot": -2, "pivot": [160, 176]}
    move["upper"] = {"rot": pose["lean"], "dx": pose["dx"], "pivot": list(HIP)}
    spread = pose["legs"]
    move["leg_r"] = [-spread, 0]
    move["leg_l"] = [round(spread * 0.6, 1), 0]
    frames.append({"name": "battle_attack", "move": move, "show": show, "hide": hide})
    hit = {}
    for side, arm in (("r", 30), ("l", -30)):
        info = held_info.get(side, {})
        want = HIT_WANT[side] if info.get("reach", 0) >= 60 else None
        hit.update(_side_moves(side, arm, want, 1.0, info, False)[0])
    hit.update({"head": {"rot": 9, "dx": 3, "pivot": [160, 176]}, "upper": {"rot": 7, "dx": 9, "pivot": list(HIP)},
                "leg_r": [4, 0], "leg_l": [7, -2]})
    frames.append({"name": "battle_hit", "move": hit,
                   "show": ["eyes_hit", "brow_hurt", "mouth_hurt"],
                   "hide": ["eyes_open", "brow_calm", "mouth_idle"]})
    return frames


# ------------------------------------------------------------------ battle canvas
BATTLE_SHIFT = 32.0          # authoring space is 320 wide; the battle canvas is 384 (room for raised weapons)
BATTLE_SCALE = 0.9           # figure scaled around the feet so raised weapons and hats stay inside


def shift_forms(forms, dx):
    out = copy.deepcopy(forms)
    for f in out:
        for p in f.get("pieces", []):
            p["at"][0] = round(p["at"][0] + dx, 2)
            rep = p.get("repeat") or {}
            if "line" in rep:
                rep["line"] = [[x + dx, y] for x, y in rep["line"]]
            if "ellipse" in rep:
                rep["ellipse"][0] += dx
            if "points" in rep:
                rep["points"] = [[q[0] + dx] + list(q[1:]) for q in rep["points"]]
    return out


def shift_frames(frames, dx):
    out = copy.deepcopy(frames)
    for fr in out:
        for mv in (fr.get("move") or {}).values():
            if isinstance(mv, dict) and mv.get("pivot"):
                mv["pivot"] = [round(mv["pivot"][0] + dx, 2), mv["pivot"][1]]
    return out


# ------------------------------------------------------------------ portrait
def _scale_piece(p, k, src, dst, dx):
    q = copy.deepcopy(p)
    x, y = q["at"]
    q["at"] = [round(dst[0] + (x + dx - src[0]) * k, 2), round(dst[1] + (y - src[1]) * k, 2)]
    s = q.get("size")
    if isinstance(s, (int, float)):
        q["size"] = round(s * k, 2)
    elif s is not None:
        q["size"] = [None if v is None else round(v * k, 2) for v in s]
    map_repeat(q, lambda pt: (dst[0] + (pt[0] + dx - src[0]) * k, dst[1] + (pt[1] - src[1]) * k), k=k)
    return q


def portrait_forms(forms):
    out = []
    for f in forms:
        tags = set(f.get("tags", []))
        if "no_portrait" in tags or f.get("kind") == "shadow":
            continue
        g = copy.deepcopy(f)
        dx = max([amount for key, amount in TURN.items() if key in tags] or [0.0])
        pieces = []
        for p in g["pieces"]:
            q = _scale_piece(p, PORTRAIT_K, HEAD, PORTRAIT_HEAD, dx)
            if "far" in tags and isinstance(q.get("size"), list) and q["size"][0]:
                q["size"] = [round(q["size"][0] * 0.8, 2), q["size"][1]]
            pieces.append(q)
        g["pieces"] = pieces
        out.append(g)
    return out
