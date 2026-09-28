"""Animate actual CMA source cutouts with the proc_bake spring rig.

The proc_bake rig supplies bone placement and spring motion. Its colored/vector
renderer is not used; every visible pixel below comes from the CC0 raster crops.
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = Path(__file__).resolve().parents[6]
PROC_BAKE = PROJECT_ROOT / "tools" / "proc_bake"
sys.path.insert(0, str(PROC_BAKE))

from procbake.bake import load_library  # noqa: E402
from procbake.creature import Creature  # noqa: E402
from procbake.rig import Rig, motion_targets  # noqa: E402

MANIFEST_PATH = ROOT / "parts" / "parts_manifest_v02.json"
OUT = ROOT / "assemblies" / "candidate"
RIG_OUT = ROOT / "rigs"
SCALE = 0.22
FPS = 20
FRAMES = 18
CYCLE = 1.0
ROOT_SOURCE = (1110.0, 1590.0)

PARTS = [
    # id, manifest ID, parent, source-space rest pivot, proc_bake shape
    ("torso", "stgeorge_chest_armor", None, (1110, 1590), "torso_rodent"),
    ("neck", "stgeorge_neck_chainmail", "torso", (1110, 566), "frill_neck"),
    ("head", "stgeorge_head_helmet", "neck", (1090, 570), "head_blunt"),
    ("abdomen", "stgeorge_belly_plate", "torso", (1098, 1060), "torso_blob"),
    ("pelvis", "stgeorge_pelvis_skirt", "abdomen", (1110, 1590), "torso_rodent"),
    ("left_upper_arm", "stgeorge_left_upper_arm", "torso", (835, 720), "limb_femur"),
    ("left_forearm", "stgeorge_left_forearm_hand", "left_upper_arm", (600, 930), "limb_shin"),
    ("left_hand", "michael_sword_hand", "left_forearm", (530, 1070), "foot_claw"),
    ("right_upper_arm", "stgeorge_right_upper_arm", "torso", (1390, 720), "limb_femur"),
    ("right_forearm", "stgeorge_right_forearm_hand", "right_upper_arm", (1490, 1010), "limb_shin"),
    ("right_hand", "michael_shield_hand", "right_forearm", (1700, 1205), "foot_claw"),
    ("left_thigh", "stgeorge_left_thigh", "pelvis", (920, 1770), "limb_femur"),
    ("left_shin", "stgeorge_left_shin_boot", "left_thigh", (900, 2180), "limb_shin"),
    ("left_foot", "stgeorge_left_boot_foot", "left_shin", (900, 2925), "foot_claw"),
    ("right_thigh", "stgeorge_right_thigh", "pelvis", (1240, 1770), "limb_femur"),
    ("right_shin", "stgeorge_right_shin_boot", "right_thigh", (1240, 2200), "limb_shin"),
    ("right_foot", "stgeorge_right_boot_foot", "right_shin", (1320, 2930), "foot_claw"),
    ("left_wing", "michael_left_wing", "torso", (865, 720), "limb_wingarm"),
    ("right_wing", "michael_right_wing", "torso", (1365, 720), "limb_wingarm"),
]

# These are discrete pasted image pieces selected from other source works. They
# deliberately cross color/print techniques and sit over major body joins.
ASSEMBLIES = [
    {
        "id": "winged_patchwork_knight_walk",
        "motion": "walk",
        "cycle_seconds": 1.0,
        "patches": [
            ("fragment_160_19869_5", "head", (1110, 520), 0.20, -6),
            ("fragment_098_1958173_1", "left_wing", (800, 820), 0.23, -18),
            ("fragment_229_202299_5", "abdomen", (1120, 1210), 0.23, 8),
            ("fragment_147_201520_2", "right_thigh", (1220, 1900), 0.20, 12),
        ],
        "targets": {
            "torso": {"mode": "bob", "amp": 1.8, "freq": 5.4, "rot": 3.5},
            "head": {"mode": "sway", "amp": 1.0, "freq": 3.3, "rot": 7.0, "phase": 0.4},
            "left_upper_arm": {"mode": "swing", "amp": 2.0, "freq": 5.1, "rot": 18.0, "phase": 0.0},
            "right_upper_arm": {"mode": "swing", "amp": 2.0, "freq": 5.1, "rot": -19.0, "phase": 3.1},
            "left_forearm": {"mode": "swing", "amp": 1.2, "freq": 5.1, "rot": 13.0, "phase": 0.5},
            "right_forearm": {"mode": "swing", "amp": 1.2, "freq": 5.1, "rot": -14.0, "phase": 3.6},
            "left_thigh": {"mode": "swing", "amp": 1.8, "freq": 5.1, "rot": 11.0, "phase": 3.1},
            "right_thigh": {"mode": "swing", "amp": 1.8, "freq": 5.1, "rot": -12.0, "phase": 0.0},
            "left_shin": {"mode": "swing", "amp": 1.0, "freq": 5.1, "rot": 10.0, "phase": 4.0},
            "right_shin": {"mode": "swing", "amp": 1.0, "freq": 5.1, "rot": -10.0, "phase": 0.8},
            "left_wing": {"mode": "swing", "amp": 2.0, "freq": 3.8, "rot": 17.0, "phase": 0.0},
            "right_wing": {"mode": "swing", "amp": 2.0, "freq": 3.8, "rot": -17.0, "phase": 3.1},
        },
    },
    {
        "id": "gilded_saint_cutout_idle",
        "motion": "idle",
        "cycle_seconds": 2.0,
        "patches": [
            ("fragment_041_1966238_1", "head", (1090, 520), 0.19, 4),
            ("fragment_090_19641501_4", "torso", (1120, 900), 0.23, -7),
            ("fragment_239_19426331_4", "left_forearm", (580, 1000), 0.21, -9),
            ("fragment_213_1965231_5", "pelvis", (1180, 1550), 0.23, 5),
        ],
        "targets": {
            "torso": {"mode": "pulse", "amp": 1.2, "freq": 1.2, "rot": 2.0},
            "head": {"mode": "sway", "amp": 0.7, "freq": 1.5, "rot": 5.0, "phase": 0.7},
            "left_upper_arm": {"mode": "sway", "amp": 1.0, "freq": 1.0, "rot": 8.0, "phase": 0.2},
            "right_upper_arm": {"mode": "sway", "amp": 1.0, "freq": 1.1, "rot": -8.0, "phase": 1.4},
            "left_wing": {"mode": "swing", "amp": 1.0, "freq": 1.3, "rot": 8.0, "phase": 0.0},
            "right_wing": {"mode": "swing", "amp": 1.0, "freq": 1.3, "rot": -8.0, "phase": 3.1},
        },
    },
    {
        "id": "torn_reliquary_messenger_alert",
        "motion": "alert",
        "cycle_seconds": 1.5,
        "patches": [
            ("fragment_124_195299_1", "left_wing", (880, 760), 0.24, 13),
            ("fragment_206_19229413_3", "right_wing", (1390, 760), 0.23, -12),
            ("fragment_145_1942635_6", "neck", (1100, 630), 0.22, 12),
            ("fragment_221_1928748_3", "right_thigh", (1250, 1840), 0.23, -8),
            ("fragment_254_1937577_4", "head", (1100, 550), 0.18, 10),
        ],
        "targets": {
            "torso": {"mode": "bob", "amp": 1.3, "freq": 3.0, "rot": 2.0},
            "head": {"mode": "sway", "amp": 1.0, "freq": 2.1, "rot": 10.0, "phase": 0.8},
            "left_upper_arm": {"mode": "swing", "amp": 2.0, "freq": 2.8, "rot": 24.0, "phase": 1.2},
            "right_upper_arm": {"mode": "swing", "amp": 2.0, "freq": 2.8, "rot": -20.0, "phase": 4.4},
            "left_wing": {"mode": "swing", "amp": 2.0, "freq": 2.4, "rot": 25.0, "phase": 0.3},
            "right_wing": {"mode": "swing", "amp": 2.0, "freq": 2.4, "rot": -24.0, "phase": 3.4},
        },
    },
]


def rotate(v: np.ndarray, angle: float) -> np.ndarray:
    c, s = math.cos(angle), math.sin(angle)
    return np.array([c * v[0] - s * v[1], s * v[0] + c * v[1]], dtype=np.float64)


def source_position(point) -> np.ndarray:
    return (np.asarray(point, dtype=np.float64) - np.asarray(ROOT_SOURCE, dtype=np.float64)) * SCALE


def make_spec(library, layers: list[dict]) -> dict:
    layer_by_id = {layer["rig_id"]: layer for layer in layers}
    rig_parts = []
    targets = {layer["rig_id"]: (layer["target"], math.radians(layer.get("rest_rotation", 0.0))) for layer in layers}
    for layer in layers:
        parent_id = layer.get("parent")
        target_pos, target_rot = targets[layer["rig_id"]]
        if parent_id is None:
            rig_parts.append({
                "id": layer["rig_id"], "shape": layer["shape"], "role": "body",
                "shade": "flat", "follow": "pinned", "stiffness": 160.0, "damping": 0.7,
            })
            continue
        parent = layer_by_id[parent_id]
        parent_pos, parent_rot = targets[parent_id]
        shape = library.get(parent["shape"])
        at = float(layer.get("at", 0.0))
        seat_local = shape.spine_at(at)
        local_offset = rotate(target_pos - parent_pos, -parent_rot) - seat_local
        bone = shape.spine_dir_at(at)
        bone_local = math.atan2(float(bone[1]), float(bone[0]))
        local_angle = target_rot - parent_rot - bone_local
        rig_parts.append({
            "id": layer["rig_id"], "shape": layer["shape"], "parent": parent_id,
            "at": at, "angle": math.degrees(local_angle),
            "offset": [float(local_offset[0]), float(local_offset[1])],
            "role": "body", "shade": "flat", "follow": layer.get("follow", "soft"),
            "stiffness": float(layer.get("stiffness", 115.0)),
            "damping": float(layer.get("damping", 0.58)),
        })
    return {
        "name": "CMA medieval cutout collage",
        "size": [600, 760],
        "seed": 11,
        # proc_bake requires all three neutral roles even though its renderer
        # is not used for the visible pixels in this raster collage bake.
        "palette": {"body": "#79634c", "ink": "#211b16", "shade": "#392d23"},
        "physics": {"gravity": 0.0, "squash_limit": 0.20},
        "parts": rig_parts,
    }


def part_transform(image: Image.Image, pivot: tuple[float, float], position: np.ndarray,
                   rotation: float, scale: float, squash=None) -> tuple[Image.Image, tuple[int, int]]:
    w, h = image.size
    corners = np.array([[0, 0], [w, 0], [w, h], [0, h]], dtype=np.float64)
    squash_mat = np.eye(2)
    if squash is not None:
        along, across, axis = squash
        c, s = math.cos(axis), math.sin(axis)
        r = np.array([[c, -s], [s, c]], dtype=np.float64)
        squash_mat = r @ np.diag([along, across]) @ r.T
    c, s = math.cos(rotation), math.sin(rotation)
    rot_mat = np.array([[c, -s], [s, c]], dtype=np.float64)
    linear = scale * (rot_mat @ squash_mat)
    pivot_v = np.asarray(pivot, dtype=np.float64)
    dest_corners = (corners - pivot_v) @ linear.T + position
    left = int(math.floor(dest_corners[:, 0].min() - 2))
    top = int(math.floor(dest_corners[:, 1].min() - 2))
    right = int(math.ceil(dest_corners[:, 0].max() + 2))
    bottom = int(math.ceil(dest_corners[:, 1].max() + 2))
    inv = np.linalg.inv(linear)
    coeffs = (
        float(inv[0, 0]), float(inv[0, 1]),
        float(pivot_v[0] + inv[0, 0] * (left - position[0]) + inv[0, 1] * (top - position[1])),
        float(inv[1, 0]), float(inv[1, 1]),
        float(pivot_v[1] + inv[1, 0] * (left - position[0]) + inv[1, 1] * (top - position[1])),
    )
    warped = image.transform((right - left, bottom - top), Image.Transform.AFFINE,
                              coeffs, resample=Image.Resampling.BICUBIC)
    return warped, (left, top)


def advance(rig: Rig, seconds: float, kind: str, targets: dict) -> None:
    elapsed = 0.0
    while elapsed < seconds - 1e-9:
        dt = min(1.0 / 60.0, seconds - elapsed)
        rig.step(dt, motion_targets(rig, kind, rig.time, targets))
        elapsed += dt


def build_layers(manifest: dict, bundle: dict) -> list[dict]:
    records = {r["id"]: r for r in manifest["parts"]}
    layers = []
    source_targets = {}
    for rig_id, manifest_id, parent, target, shape in PARTS:
        if rig_id in ("left_wing", "right_wing") and not bundle.get("wings", True):
            continue
        if manifest_id not in records:
            raise KeyError(f"missing part {manifest_id}")
        target = source_position(target)
        layer = {
            "rig_id": rig_id, "manifest_id": manifest_id, "parent": parent,
            "target": target, "shape": shape, "image_scale": float(bundle.get("body_scale", 1.0)),
            "follow": "soft", "rest_rotation": 0.0,
        }
        layers.append(layer)
        source_targets[rig_id] = target
    if not bundle.get("wings", True):
        layers = [layer for layer in layers if layer["rig_id"] not in ("left_wing", "right_wing")]
    for idx, (manifest_id, parent, target_src, image_scale, rotation_deg) in enumerate(bundle["patches"], start=1):
        if manifest_id not in records:
            raise KeyError(f"missing collage fragment {manifest_id}")
        rig_id = f"pasted_scrap_{idx:02d}"
        parent_layer = next((layer for layer in layers if layer["rig_id"] == parent), None)
        if parent_layer is None:
            parent = "torso"
        layers.append({
            "rig_id": rig_id, "manifest_id": manifest_id, "parent": parent,
            "target": source_position(target_src), "shape": "limb_tentacle",
            "image_scale": image_scale / SCALE,
            "follow": "rigid", "rest_rotation": float(rotation_deg),
        })
    return layers


def frame_bounds(layers, placements, rest_placements, records) -> tuple[int, int, int, int]:
    boxes = []
    for placement_set in placements:
        for layer in layers:
            record = records[layer["manifest_id"]]
            image = Image.open(ROOT / record["output_file"])
            w, h = image.size
            crop = record["crop_origin_source_pixels"]
            pivot_source = record["pivot_source_pixels"]
            pivot = (pivot_source[0] - crop[0], pivot_source[1] - crop[1])
            p = placement_set[layer["rig_id"]]
            rest_rot = rest_placements[layer["rig_id"]].rotation
            angle = p.rotation - rest_rot
            scale = SCALE * layer["image_scale"] * p.scale
            squash = p.squash
            mat = np.eye(2)
            if squash is not None:
                along, across, axis = squash
                c, s = math.cos(axis), math.sin(axis)
                r = np.array([[c, -s], [s, c]], dtype=np.float64)
                mat = r @ np.diag([along, across]) @ r.T
            c, s = math.cos(angle), math.sin(angle)
            rot = np.array([[c, -s], [s, c]], dtype=np.float64)
            a = scale * (rot @ mat)
            q = (np.array([[0, 0], [w, 0], [w, h], [0, h]], dtype=np.float64) - np.asarray(pivot)) @ a.T + p.position
            boxes.append((float(q[:, 0].min()), float(q[:, 1].min()),
                          float(q[:, 0].max()), float(q[:, 1].max())))
    pad = 16
    return (math.floor(min(b[0] for b in boxes)) - pad,
            math.floor(min(b[1] for b in boxes)) - pad,
            math.ceil(max(b[2] for b in boxes)) + pad,
            math.ceil(max(b[3] for b in boxes)) + pad)


def raster_frame(layers, placement, rest_placements, records, bounds) -> Image.Image:
    x0, y0, x1, y1 = bounds
    canvas = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    for layer in layers:
        record = records[layer["manifest_id"]]
        image = Image.open(ROOT / record["output_file"]).convert("RGBA")
        crop = record["crop_origin_source_pixels"]
        pivot_source = record["pivot_source_pixels"]
        pivot = (pivot_source[0] - crop[0], pivot_source[1] - crop[1])
        p = placement[layer["rig_id"]]
        rest_rot = rest_placements[layer["rig_id"]].rotation
        angle = p.rotation - rest_rot
        pos = np.array([p.position[0] - x0, p.position[1] - y0], dtype=np.float64)
        scale = SCALE * layer["image_scale"] * p.scale
        warped, corner = part_transform(image, pivot, pos, angle, scale, p.squash)
        canvas.alpha_composite(warped, corner)
    return canvas


def save_bundle(bundle, manifest, library) -> dict:
    records = {r["id"]: r for r in manifest["parts"]}
    layers = build_layers(manifest, bundle)
    spec = make_spec(library, layers)
    creature = Creature.from_spec(spec, library)
    rest = creature.rest_placement()
    rig = Rig(creature, rest, spec.get("physics"))
    cycle = float(bundle.get("cycle_seconds", CYCLE))
    frame_count = max(2, round(cycle * FPS))
    targets = {
        part_id: {**cfg, "freq": (2.0 * math.pi / cycle) * float(cfg.get("harmonic", 1.0))}
        for part_id, cfg in bundle["targets"].items()
    }
    for _ in range(72):
        rig.step(1.0 / 60.0, motion_targets(rig, bundle["motion"], rig.time, targets))
    sampled = []
    advance_seconds = cycle / frame_count
    for _ in range(frame_count):
        advance(rig, advance_seconds, bundle["motion"], targets)
        sampled.append(rig.placement())
    bounds = frame_bounds(layers, sampled, rest, records)
    frames = [raster_frame(layers, pose, rest, records, bounds) for pose in sampled]
    OUT.mkdir(parents=True, exist_ok=True)
    RIG_OUT.mkdir(parents=True, exist_ok=True)
    name = bundle["id"]
    gif_path = OUT / f"{name}.gif"
    frames[0].save(gif_path, save_all=True, append_images=frames[1:], duration=round(1000 / FPS),
                   loop=0, disposal=2, optimize=True)
    first_path = OUT / f"{name}_rest.png"
    frames[0].save(first_path, optimize=True)
    cols = 6
    rows = math.ceil(len(frames) / cols)
    strip = Image.new("RGBA", (cols * frames[0].width, rows * frames[0].height), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        strip.alpha_composite(frame, ((i % cols) * frame.width, (i // cols) * frame.height))
    strip_path = OUT / f"{name}_strip.png"
    strip.save(strip_path, optimize=True)
    rig_report = {
        "id": name,
        "status": "candidate",
        "animation_tool": "tools/proc_bake/procbake.rig.Rig + motion_targets",
        "visible_pixel_source": "source cutout PNGs from CMA CC0 artwork; no proc_bake vector repaint",
        "motion": bundle["motion"],
        "frame_count": frame_count,
        "fps": FPS,
        "cycle_seconds": cycle,
        "motion_targets": targets,
        "source_parts": [
            {"rig_id": layer["rig_id"], "part_id": layer["manifest_id"],
             "source_accession": records[layer["manifest_id"]]["source_accession"],
             "parent": layer["parent"]}
            for layer in layers
        ],
        "rest_bones": {
            key: {"position": [round(float(x), 3) for x in value.position],
                  "rotation_radians": round(float(value.rotation), 5)}
            for key, value in rest.items()
        },
        "rig_spec": spec,
        "outputs": [str(gif_path), str(first_path), str(strip_path)],
    }
    (RIG_OUT / f"{name}_proc_bake_rig.json").write_text(json.dumps(rig_report, ensure_ascii=False, indent=2), encoding="utf-8")
    return {"id": name, "parts": len(layers), "canvas": list(frames[0].size),
            "gif": str(gif_path), "strip": str(strip_path)}


def main() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    library = load_library()
    summaries = []
    for bundle in ASSEMBLIES:
        summaries.append(save_bundle(bundle, manifest, library))
        print(summaries[-1], flush=True)
    summary_path = OUT / "assemblies_manifest_v02.json"
    summary_path.write_text(json.dumps({
        "batch": "medieval-cutout-bank-v02",
        "status": "candidate",
        "style_gate": "visible cut-and-paste collage required; a single coherent painting read is a failure",
        "assemblies": summaries,
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    print(summary_path)


if __name__ == "__main__":
    main()
