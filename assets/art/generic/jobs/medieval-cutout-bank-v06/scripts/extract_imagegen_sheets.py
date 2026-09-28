"""Separate the v06 imagegen contact sheets without changing their saved masters."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage


JOB = Path(__file__).resolve().parents[1]
SOURCE = JOB / "source_cutouts"
DESTINATION = JOB / "candidates"

SHEETS = [
    {
        "file": "durer_horse_parts_imagegen_original.png",
        "source_accession": "1965.231",
        "family": "horse",
        "category": "animal",
        "names": [
            "mane", "neck", "head", "tail", "torso", "pelvis",
            "right_fore_upper", "left_hind_upper", "left_fore_upper", "right_hind_upper",
            "right_hind_lower", "left_hind_lower", "left_fore_lower", "right_fore_lower",
        ],
    },
    {
        "file": "mercenary_body_parts_hands_separate_imagegen_original.png",
        "source_accession": "1942.118",
        "family": "mercenary",
        "category": "human",
        "names": [
            "head", "left_upper_arm", "right_upper_arm", "neck", "chest",
            "left_forearm", "right_forearm", "abdomen", "left_hand", "right_hand",
            "right_thigh", "left_thigh", "pelvis", "left_shin", "right_shin",
            "left_foot", "right_foot",
        ],
    },
    {
        "file": "archangel_dragon_parts_imagegen_original.png",
        "source_accession": "1952.99",
        "family": "dragon",
        "category": "animal",
        "names": [
            "head", "upper_torso", "pelvis", "lower_torso", "neck",
            "left_wing", "right_wing", "tail_tip", "tail_middle", "tail_base",
            "left_forelimb", "right_forelimb", "left_hindlimb", "right_hindlimb",
        ],
    },
    {
        "file": "landscape_objects_imagegen_original.png",
        "source_accession": "1929.557",
        "family": "landscape",
        "category": "scenery",
        "names": ["tree", "tower_ruin", "stone_bridge", "village", "rock_cluster", "shrub"],
    },
    {
        "file": "equipment_five_imagegen_original.png",
        "source_accession": "1942.118;1965.231",
        "source_accessions_by_part": {
            "pole_spear": "1942.118",
            "broad_sword": "1942.118",
            "hourglass": "1965.231",
            "sheathed_sword": "1965.231",
            "armor_harness": "1965.231",
        },
        "family": "equipment",
        "category": "equipment",
        "names": ["pole_spear", "broad_sword", "hourglass", "sheathed_sword", "armor_harness"],
    },
]


def extract_sheet(spec: dict) -> list[dict]:
    image = Image.open(SOURCE / spec["file"]).convert("RGBA")
    pixels = np.asarray(image).copy()
    original_alpha = pixels[:, :, 3]
    regions, total = ndimage.label(original_alpha > 128)
    objects = ndimage.find_objects(regions)
    if total != len(spec["names"]):
        raise ValueError(f"{spec['file']}: {total} regions for {len(spec['names'])} names")

    records = []
    folder = DESTINATION / spec["family"]
    folder.mkdir(parents=True, exist_ok=True)
    for index, (name, bounds) in enumerate(zip(spec["names"], objects), start=1):
        if bounds is None:
            raise ValueError(f"{spec['file']}: missing region {index}")
        y_range, x_range = bounds
        left = max(0, x_range.start - 8)
        top = max(0, y_range.start - 8)
        right = min(image.width, x_range.stop + 8)
        bottom = min(image.height, y_range.stop + 8)
        piece = pixels[top:bottom, left:right].copy()
        region = regions[top:bottom, left:right] == index
        alpha = np.clip((piece[:, :, 3].astype(np.float32) - 95.0) * (255.0 / 145.0), 0, 255)
        piece[:, :, 3] = np.where(region, alpha, 0).astype(np.uint8)
        filename = f"{spec['family']}_{name}.png"
        output = folder / filename
        Image.fromarray(piece, "RGBA").save(output, optimize=True)
        records.append({
            "id": f"{spec['family']}_{name}",
            "status": "candidate",
            "category": spec["category"],
            "file": str(output.relative_to(JOB)).replace("\\", "/"),
            "imagegen_master": f"source_cutouts/{spec['file']}",
            "source_accession": spec.get("source_accessions_by_part", {}).get(name, spec["source_accession"]),
            "crop_box_in_master": [left, top, right, bottom],
            "size": [right - left, bottom - top],
            "alpha_extrema": [int(piece[:, :, 3].min()), int(piece[:, :, 3].max())],
            "rig_status": "unassigned",
        })
    return records


def main() -> None:
    records = []
    for spec in SHEETS:
        records.extend(extract_sheet(spec))
    manifest = {
        "job": "medieval-cutout-bank-v06",
        "status": "candidate",
        "extracted_part_count": len(records),
        "completed_object_count": 0,
        "object_target": 300,
        "alpha_matting": "connected regions at alpha >128, linear alpha ramp from 95 to 240",
        "parts": records,
    }
    output = DESTINATION / "parts_manifest_v06.json"
    output.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(records)} isolated candidate PNGs in {DESTINATION}")


if __name__ == "__main__":
    main()
