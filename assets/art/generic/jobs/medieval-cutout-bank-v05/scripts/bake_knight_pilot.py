"""Bake the separated knight cutouts with proc_bake joints and planted feet."""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

JOB = Path(__file__).resolve().parents[1]
PROJECT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(PROJECT / "tools/proc_bake"))

from procbake.creature import Part, Placement  # noqa: E402
from procbake.rig import Rig, gait_targets, motion_targets  # noqa: E402

MANIFEST = JOB / "candidates/parts_manifest_v05.json"
OUT = JOB / "assemblies"
FPS = 20
CANVAS = (800, 850)
GLOBAL_SCALE = 0.50
GLOBAL_OFFSET = np.array([140.0, 72.0])


class Puppet:
    def __init__(self, parts: list[Part]):
        self.parts = parts
        self._by_id = {part.id: part for part in parts}


def load_records(with_wings: bool) -> list[dict]:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    records = [r for r in manifest["parts"] if r["id"] != "shield"]
    painted = next((r for r in records if r["id"] == "painted_shield"), None)
    if painted is not None:
        painted["id"] = "shield"
    for item in records:
        item["visual_scale"] = 1.0
        item["rest_rotation"] = math.pi / 2 if item["id"] in (
            "left_thigh", "right_thigh", "left_shin", "right_shin"
        ) else 0.0
    by_id = {r["id"]: r for r in records}
    by_id["sword"]["visual_scale"] = 0.42
    by_id["sword"]["draw_order"] = 6
    by_id["shield"]["visual_scale"] = 0.30
    if "grape_insignia" in by_id:
        by_id["grape_insignia"]["visual_scale"] = 0.115
    if with_wings:
        wing_root = PROJECT / "assets/art/generic/jobs/medieval-cutout-bank-v04/candidates/cutouts"
        for side, name, pivot, target in [
            ("left", "archangel_left_wing.png", (640, 480), (300, 360)),
            ("right", "archangel_right_wing.png", (150, 540), (595, 360)),
        ]:
            path = wing_root / name
            records.append({
                "id": f"{side}_wing", "file": str(path), "parent": "chest",
                "pivot_local": list(pivot), "rest_joint": list(target),
                "draw_order": -10, "visual_scale": 0.36,
                "rest_rotation": 0.0,
                "source_accession": "1952.99",
            })
    return records


def make_rig(records: list[dict]) -> tuple[Rig, dict]:
    records_by_id = {r["id"]: r for r in records}
    # Parent-first order is separate from drawing order.
    order = [
        "chest", "neck", "head", "abdomen", "pelvis", "grape_insignia",
        "left_upper_arm", "left_forearm", "left_hand", "sword",
        "right_upper_arm", "right_forearm", "right_hand", "shield",
        "left_thigh", "left_shin", "left_foot",
        "right_thigh", "right_shin", "right_foot",
        "left_wing", "right_wing",
    ]
    parts = []
    placement = {}
    for name in order:
        if name not in records_by_id:
            continue
        record = records_by_id[name]
        attached = name != "chest"
        part = Part(
            id=name,
            shape="limb_femur",
            parent=record["parent"],
            stiffness=165.0 if name == "chest" else 125.0,
            damping=0.78 if name == "chest" else 0.72,
            follow="rigid" if attached else "soft",
        )
        parts.append(part)
        placement[name] = Placement(
            np.asarray(record["rest_joint"], dtype=np.float64), record["rest_rotation"], 1.0
        )
    rig = Rig(Puppet(parts), placement, {"gravity": 0.0, "squash_limit": 0.04})
    return rig, placement


def _transformed(image: Image.Image, pivot: tuple[float, float], position: np.ndarray,
                 angle: float, scale: float) -> tuple[Image.Image, tuple[int, int]]:
    w, h = image.size
    c, s = math.cos(angle), math.sin(angle)
    matrix = scale * np.array([[c, -s], [s, c]])
    corners = np.array([[0, 0], [w, 0], [w, h], [0, h]], dtype=np.float64)
    dest = (corners - np.asarray(pivot)) @ matrix.T + position
    left, top = np.floor(dest.min(axis=0) - 2).astype(int)
    right, bottom = np.ceil(dest.max(axis=0) + 2).astype(int)
    inv = np.linalg.inv(matrix)
    coeffs = (
        float(inv[0, 0]), float(inv[0, 1]),
        float(pivot[0] + inv[0, 0] * (left - position[0]) + inv[0, 1] * (top - position[1])),
        float(inv[1, 0]), float(inv[1, 1]),
        float(pivot[1] + inv[1, 0] * (left - position[0]) + inv[1, 1] * (top - position[1])),
    )
    warped = image.transform((right - left, bottom - top), Image.Transform.AFFINE,
                             coeffs, resample=Image.Resampling.BICUBIC)
    return warped, (int(left), int(top))


def render(records: list[dict], pose: dict, images: dict[str, Image.Image]) -> Image.Image:
    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    for item in sorted(records, key=lambda r: r["draw_order"]):
        image = images[item["id"]]
        placement = pose[item["id"]]
        point = placement.position * GLOBAL_SCALE + GLOBAL_OFFSET
        graphic, corner = _transformed(
            image,
            tuple(item["pivot_local"]),
            point,
            placement.rotation - item["rest_rotation"],
            GLOBAL_SCALE * item["visual_scale"],
        )
        canvas.alpha_composite(graphic, corner)
    return canvas


def animate(kind: str, with_wings: bool) -> dict:
    records = load_records(with_wings)
    images = {}
    for item in records:
        path = Path(item["file"])
        if not path.is_absolute():
            path = JOB / path
        images[item["id"]] = Image.open(path).convert("RGBA")
    rig, rest = make_rig(records)
    duration = 1.4 if kind == "walk" else 2.0
    frames_count = round(duration * FPS)
    cycle = duration
    amount = {
        "chest": {"mode": "bob", "amp": 5 if kind == "walk" else 2, "freq": 2 * math.pi / cycle, "rot": 1.2},
        "head": {"mode": "sway", "amp": 2, "freq": 2 * math.pi / cycle, "rot": 6 if kind != "look" else 18},
        "left_upper_arm": {"mode": "swing", "amp": 1.5, "freq": 2 * math.pi / cycle, "rot": 8 if kind != "use" else -23},
        "right_upper_arm": {"mode": "swing", "amp": 1.5, "freq": 2 * math.pi / cycle, "rot": -7 if kind != "use" else 18, "phase": math.pi},
        "left_forearm": {"mode": "swing", "amp": 1, "freq": 2 * math.pi / cycle, "rot": 7 if kind != "use" else -29},
        "right_forearm": {"mode": "swing", "amp": 1, "freq": 2 * math.pi / cycle, "rot": -6 if kind != "use" else 24, "phase": math.pi},
    }
    if kind == "look":
        amount["chest"] = {"mode": "sway", "amp": 3, "freq": 2 * math.pi / cycle, "rot": 5}
    if kind == "walk":
        amount["left_upper_arm"]["rot"] = 12
        amount["right_upper_arm"]["rot"] = -12
    legs = [
        {"chain": ["left_thigh", "left_shin", "left_foot"], "bend": 1.0},
        {"chain": ["right_thigh", "right_shin", "right_foot"], "bend": -1.0},
    ]
    for _ in range(72):
        rig.step(1 / 60, motion_targets(rig, kind, rig.time, amount))
    frames = []
    for _ in range(frames_count):
        rig.step(cycle / frames_count, motion_targets(rig, kind, rig.time, amount))
        if kind == "walk":
            gait_targets(rig, legs, rig.time, ground=1220, stride=42,
                         lift=36, duty=0.63, cycle=cycle)
        frames.append(render(records, rig.placement(), images))
    OUT.mkdir(parents=True, exist_ok=True)
    variant = "winged" if with_wings else "plain"
    stem = f"knight_{variant}_{kind}"
    gif = OUT / f"{stem}.gif"
    frames[0].save(gif, save_all=True, append_images=frames[1:],
                   duration=round(1000 / FPS), loop=0, disposal=2, optimize=True)
    frames[0].save(OUT / f"{stem}_rest.png", optimize=True)
    columns = 8
    rows = math.ceil(frames_count / columns)
    strip = Image.new("RGBA", (CANVAS[0] * columns, CANVAS[1] * rows), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, ((index % columns) * CANVAS[0], (index // columns) * CANVAS[1]))
    strip.save(OUT / f"{stem}_strip.png", optimize=True)
    report = {
        "id": stem, "status": "candidate", "tool": "tools/proc_bake/procbake/rig.py",
        "motion": kind, "wings": with_wings, "fps": FPS,
        "frames": frames_count, "canvas": list(CANVAS),
        "uses_planted_foot_ik": kind == "walk",
        "rest_joints": {k: v.position.tolist() for k, v in rest.items()},
        "parts": [r["id"] for r in records],
        "output": str(gif.relative_to(JOB)),
    }
    (JOB / "rigs" / f"{stem}.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    return report


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kind", choices=["idle", "walk", "look", "use", "all"], default="all")
    parser.add_argument("--wings", choices=["plain", "winged", "both"], default="both")
    args = parser.parse_args()
    wing_values = (False, True) if args.wings == "both" else (args.wings == "winged",)
    kinds = ("idle", "walk", "look", "use") if args.kind == "all" else (args.kind,)
    for wings in wing_values:
        for kind in kinds:
            report = animate(kind, wings)
            print(report["id"], report["frames"], flush=True)


if __name__ == "__main__":
    main()
