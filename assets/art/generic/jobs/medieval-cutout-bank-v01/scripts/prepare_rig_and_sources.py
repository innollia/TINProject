"""Record print-resolution source variants and draw a non-runtime rig guide."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
RIG = {
    "id": "stgeorge_fullbody_rig_v01",
    "status": "candidate",
    "kind": "2D cutout skeleton guide; not a Godot/runtime rig",
    "source_accession": "1934.337",
    "source_file": "1934-337-print.jpg",
    "coordinate_unit": "source-image pixels",
    "bones": [
        {"name": "root", "parent": None, "from": [1110, 1590], "to": [1110, 1590], "part": ""},
        {"name": "torso", "parent": "root", "from": [1110, 1590], "to": [1110, 1110], "part": "stgeorge_chest_armor"},
        {"name": "neck_head", "parent": "torso", "from": [1110, 1110], "to": [1135, 390], "part": "stgeorge_head_helmet"},
        {"name": "left_upper_arm", "parent": "torso", "from": [835, 720], "to": [600, 930], "part": "stgeorge_left_upper_arm"},
        {"name": "left_forearm_hand", "parent": "left_upper_arm", "from": [600, 930], "to": [530, 1070], "part": "stgeorge_left_forearm_hand"},
        {"name": "right_upper_arm", "parent": "torso", "from": [1390, 720], "to": [1490, 1010], "part": "stgeorge_right_upper_arm"},
        {"name": "right_forearm_hand", "parent": "right_upper_arm", "from": [1490, 1010], "to": [1700, 1205], "part": "stgeorge_right_forearm_hand"},
        {"name": "pelvis", "parent": "torso", "from": [1110, 1590], "to": [1110, 1770], "part": "stgeorge_pelvis_skirt"},
        {"name": "left_thigh", "parent": "pelvis", "from": [920, 1770], "to": [900, 2180], "part": "stgeorge_left_thigh"},
        {"name": "left_shin_boot", "parent": "left_thigh", "from": [900, 2180], "to": [865, 2925], "part": "stgeorge_left_shin_boot"},
        {"name": "right_thigh", "parent": "pelvis", "from": [1240, 1770], "to": [1240, 2200], "part": "stgeorge_right_thigh"},
        {"name": "right_shin_boot", "parent": "right_thigh", "from": [1240, 2200], "to": [1320, 2930], "part": "stgeorge_right_shin_boot"},
    ],
    "attachment_points": [
        {"name": "left_wing_root", "source_art": "1952.99", "position": [795, 770], "bind_to": "torso"},
        {"name": "right_wing_root", "source_art": "1952.99", "position": [1501, 746], "bind_to": "torso"},
    ],
    "notes": [
        "Rest-pose landmarks are hand-placed over the printed pose and require visual tuning.",
        "Armor overlaps the joints in the source; the cutout masks need refinement before animation.",
        "Wing attachments are reference points only; the Schongauer wings need scale and pose fitting.",
    ],
}


def main() -> None:
    source_path = ROOT / "sources.json"
    sources = json.loads(source_path.read_text(encoding="utf-8"))
    print_ids = ("1934.337", "1952.99", "1958.173", "1964.150.1")
    for item in sources:
        if item["accession_number"] not in print_ids:
            continue
        file_name = item["accession_number"].replace(".", "-") + "-print.jpg"
        image_path = ROOT / "source_images" / file_name
        if image_path.exists():
            with Image.open(image_path) as image:
                item["print_image_file"] = file_name
                item["print_image_source"] = (
                    "https://openaccess-cdn.clevelandart.org/"
                    + item["accession_number"]
                    + "/"
                    + item["accession_number"]
                    + "_print.jpg"
                )
                item["print_image_resolution"] = f"{image.width}x{image.height}"
                item["print_image_license"] = item["license"]
    source_path.write_text(json.dumps(sources, ensure_ascii=False, indent=2), encoding="utf-8")

    rig_path = ROOT / "rigs" / "stgeorge_fullbody_rig_v01.json"
    rig_path.parent.mkdir(parents=True, exist_ok=True)
    rig_path.write_text(json.dumps(RIG, ensure_ascii=False, indent=2), encoding="utf-8")

    source_image = Image.open(ROOT / "source_images" / RIG["source_file"]).convert("RGB")
    source_image.thumbnail((900, 1400), Image.Resampling.LANCZOS)
    factor_x = source_image.width / 2214
    factor_y = source_image.height / 3400
    draw = ImageDraw.Draw(source_image)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except OSError:
        font = ImageFont.load_default()
    colors = {"torso": "#00e5ff", "arm": "#ffcc00", "leg": "#ff4fa3", "head": "#92ff45"}
    for bone in RIG["bones"]:
        x1, y1 = bone["from"]
        x2, y2 = bone["to"]
        a = (round(x1 * factor_x), round(y1 * factor_y))
        b = (round(x2 * factor_x), round(y2 * factor_y))
        category = "torso"
        if "arm" in bone["name"] or "forearm" in bone["name"]:
            category = "arm"
        elif "thigh" in bone["name"] or "shin" in bone["name"]:
            category = "leg"
        elif "head" in bone["name"]:
            category = "head"
        color = colors[category]
        draw.line((a, b), fill=color, width=5)
        draw.ellipse((a[0] - 7, a[1] - 7, a[0] + 7, a[1] + 7), fill=color, outline="#151515", width=2)
        draw.ellipse((b[0] - 7, b[1] - 7, b[0] + 7, b[1] + 7), fill=color, outline="#151515", width=2)
        draw.text((b[0] + 8, b[1] + 4), bone["name"], fill=color, font=font, stroke_width=2, stroke_fill="#151515")
    preview_path = ROOT / "preview" / "stgeorge_rig_preview_v01.png"
    source_image.save(preview_path, optimize=True)
    print(f"sources_updated={source_path}")
    print(f"rig={rig_path}")
    print(f"preview={preview_path}")


if __name__ == "__main__":
    main()
