"""Mechanically split the imagegen puppet sheets into RGBA candidate parts."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from PIL import Image

JOB = Path(__file__).resolve().parents[1]
BODY = JOB / "source_cutouts/knight_body_parts_sheet_imagegen_original.png"
EQUIPMENT = JOB / "source_cutouts/knight_equipment_sheet_imagegen_original.png"
PAINTED_SHIELD = JOB / "source_cutouts/painted_shield_imagegen_original.png"

# Coordinates mark transparent gutters in the two unmodified imagegen masters.
# Each pivot is in the master's pixel space. Targets are rest joint positions
# in one shared puppet canvas, before the final render scale is applied.
BODY_PARTS = [
    ("head", (390, 0, 650, 230), (510, 210), (500, 236), "neck", 13),
    ("neck", (405, 230, 615, 305), (510, 235), (500, 255), "chest", 12),
    ("chest", (352, 305, 670, 575), (510, 315), (500, 330), None, 10),
    ("abdomen", (375, 575, 645, 707), (510, 583), (500, 555), "chest", 11),
    ("pelvis", (345, 707, 695, 851), (510, 720), (500, 675), "abdomen", 14),
    ("left_upper_arm", (85, 220, 337, 516), (260, 315), (395, 335), "chest", 9),
    ("right_upper_arm", (690, 216, 925, 516), (763, 310), (615, 335), "chest", 15),
    ("left_forearm", (83, 516, 315, 735), (260, 555), (350, 510), "left_upper_arm", 8),
    ("right_forearm", (695, 516, 943, 735), (762, 552), (652, 520), "right_upper_arm", 16),
    ("left_hand", (20, 735, 222, 849), (177, 773), (250, 680), "left_forearm", 7),
    ("right_hand", (790, 735, 1008, 881), (852, 770), (725, 680), "right_forearm", 17),
    ("left_thigh", (306, 851, 515, 1025), (405, 865), (445, 770), "pelvis", 6),
    ("right_thigh", (512, 851, 734, 1025), (621, 865), (560, 770), "pelvis", 18),
    ("left_shin", (314, 1025, 510, 1375), (405, 1047), (455, 940), "left_thigh", 5),
    ("right_shin", (545, 1025, 725, 1375), (639, 1047), (565, 940), "right_thigh", 19),
    ("left_foot", (248, 1375, 468, 1536), (365, 1395), (460, 1220), "left_shin", 4),
    ("right_foot", (570, 1375, 813, 1536), (663, 1395), (570, 1220), "right_shin", 20),
]

EQUIPMENT_PARTS = [
    ("sword", (42, 15, 450, 1530), (240, 140), (215, 550), "left_hand", 21),
    ("shield", (520, 420, 975, 1065), (900, 665), (720, 690), "right_hand", 22),
]


def extract(master: Path, parts: list[tuple], category: str) -> list[dict]:
    source = Image.open(master).convert("RGBA")
    records = []
    for name, zone, pivot, target, parent, draw_order in parts:
        tile = source.crop(zone)
        pixels = np.asarray(tile).copy()
        alpha = pixels[:, :, 3].astype(np.float32)
        # Deterministic alpha matte: remove imagegen's soft gray halo while
        # keeping antialiased print edges. The exact source is preserved above.
        pixels[:, :, 3] = np.clip((alpha - 95.0) * (255.0 / 145.0), 0, 255).astype(np.uint8)
        visible = Image.fromarray(pixels, "RGBA")
        bbox = visible.getchannel("A").getbbox()
        if bbox is None:
            raise ValueError(f"empty candidate part: {name}")
        pad = 4
        box = (
            max(0, bbox[0] - pad), max(0, bbox[1] - pad),
            min(tile.width, bbox[2] + pad), min(tile.height, bbox[3] + pad),
        )
        cut = visible.crop(box)
        local_pivot = [pivot[0] - zone[0] - box[0], pivot[1] - zone[1] - box[1]]
        output = JOB / "candidates" / category / f"knight_{name}.png"
        output.parent.mkdir(parents=True, exist_ok=True)
        cut.save(output, optimize=True)
        records.append({
            "id": name,
            "status": "candidate",
            "category": category,
            "file": output.relative_to(JOB).as_posix(),
            "imagegen_master": master.relative_to(JOB).as_posix(),
            "original_source_accessions": ["1934.337"] if category == "parts" else ["1934.337", "1999.47"],
            "sheet_zone": list(zone),
            "crop_within_zone": list(box),
            "size": list(cut.size),
            "pivot_local": local_pivot,
            "rest_joint": list(target),
            "parent": parent,
            "draw_order": draw_order,
            "alpha_extrema": list(cut.getchannel("A").getextrema()),
        })
    return records


def main() -> None:
    records = extract(BODY, BODY_PARTS, "parts")
    records += extract(EQUIPMENT, EQUIPMENT_PARTS, "equipment")
    if PAINTED_SHIELD.is_file():
        image = Image.open(PAINTED_SHIELD).convert("RGBA")
        pixels = np.asarray(image).copy()
        alpha = pixels[:, :, 3].astype(np.float32)
        pixels[:, :, 3] = np.clip((alpha - 95.0) * (255.0 / 145.0), 0, 255).astype(np.uint8)
        cleaned = Image.fromarray(pixels, "RGBA")
        bbox = cleaned.getchannel("A").getbbox()
        if bbox is None:
            raise ValueError("empty painted shield")
        box = (max(0, bbox[0] - 4), max(0, bbox[1] - 4),
               min(image.width, bbox[2] + 4), min(image.height, bbox[3] + 4))
        candidate = cleaned.crop(box)
        shield_file = JOB / "candidates/equipment/knight_painted_shield.png"
        candidate.save(shield_file, optimize=True)
        records.append({
            "id": "painted_shield", "status": "candidate", "category": "equipment",
            "file": shield_file.relative_to(JOB).as_posix(),
            "imagegen_master": PAINTED_SHIELD.relative_to(JOB).as_posix(),
            "original_source_accessions": ["1964.150.1"],
            "sheet_zone": [0, 0, image.width, image.height],
            "crop_within_zone": list(box), "size": list(candidate.size),
            "pivot_local": [900 - box[0], 360 - box[1]],
            "rest_joint": [760, 650], "parent": "right_hand", "draw_order": 22,
            "alpha_extrema": list(candidate.getchannel("A").getextrema()),
        })
    ornament = JOB / "candidates/ornaments/knight_grape_insignia.png"
    if ornament.is_file():
        with Image.open(ornament) as icon:
            records.append({
                "id": "grape_insignia", "status": "candidate", "category": "ornament",
                "file": ornament.relative_to(JOB).as_posix(),
                "imagegen_master": "source_cutouts/knight_grape_insignia_imagegen_original.png",
                "original_source_accessions": ["2022.99"],
                "size": list(icon.size), "pivot_local": [icon.width // 2, icon.height // 2],
                "rest_joint": [500, 445], "parent": "chest", "draw_order": 11,
                "alpha_extrema": list(icon.getchannel("A").getextrema()),
            })
    manifest = {
        "job": "medieval-cutout-bank-v05",
        "status": "candidate",
        "semantic_part_count": len([r for r in records if r.get("category") != "ornament"]),
        "source_rights": "Cleveland Museum of Art Open Access CC0; see v02/sources.json",
        "alpha_matting": "linear ramp from alpha 95 to 240; exact imagegen masters preserved",
        "parts": records,
        "optional_wings": [
            "../../medieval-cutout-bank-v04/candidates/cutouts/archangel_left_wing.png",
            "../../medieval-cutout-bank-v04/candidates/cutouts/archangel_right_wing.png",
        ],
    }
    out = JOB / "candidates/parts_manifest_v05.json"
    out.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{manifest['semantic_part_count']} semantic parts and {len(records) - manifest['semantic_part_count']} ornaments -> {out}")


if __name__ == "__main__":
    main()
