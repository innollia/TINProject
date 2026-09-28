"""Extract polygon-defined source-art parts and make a review sheet.

Coordinates stay in the original museum image pixel space. This script performs
only mechanical masking/cropping; it does not redraw source artwork.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


JOB_ROOT = Path(__file__).resolve().parents[1]
SCALE = 3
PADDING = 18
THUMB_W = 270
THUMB_H = 300
CELL_W = 310
CELL_H = 350
COLS = 4


def checker(size: tuple[int, int], tile: int = 16) -> Image.Image:
    image = Image.new("RGB", size, "#f1f1f1")
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill="#d6d6d6")
    return image


def main() -> None:
    recipe_path = JOB_ROOT / "recipes" / "parts_v01.json"
    recipe = json.loads(recipe_path.read_text(encoding="utf-8"))
    sources = json.loads((JOB_ROOT / "sources.json").read_text(encoding="utf-8"))
    sources_by_accession = {item["accession_number"].replace(".", ""): item for item in sources}

    rows = []
    records = []
    for part in recipe["parts"]:
        source_path = JOB_ROOT / "source_images" / part["source_file"]
        source = Image.open(source_path).convert("RGBA")
        width, height = source.size
        scaled_mask = Image.new("L", (width * SCALE, height * SCALE), 0)
        points = [(int(x * SCALE), int(y * SCALE)) for x, y in part["polygon"]]
        ImageDraw.Draw(scaled_mask).polygon(points, fill=255)
        mask = scaled_mask.resize(source.size, Image.Resampling.LANCZOS)
        source.putalpha(mask)

        bounds = mask.getbbox()
        if bounds is None:
            raise ValueError(f"Empty mask for {part['id']}")
        left, top, right, bottom = bounds
        crop_box = (
            max(0, left - PADDING),
            max(0, top - PADDING),
            min(width, right + PADDING),
            min(height, bottom + PADDING),
        )
        cutout = source.crop(crop_box)

        source_accession = part["source_accession"]
        folder = JOB_ROOT / "parts" / source_accession.replace(".", "")
        folder.mkdir(parents=True, exist_ok=True)
        output_path = folder / f"{part['id']}.png"
        cutout.save(output_path, optimize=True)

        item = sources_by_accession[source_accession.replace(".", "")]
        records.append({
            "id": part["id"],
            "category": part["category"],
            "status": "candidate",
            "source_accession": source_accession,
            "source_title": item["title"].strip(),
            "source_artist": item["artist"],
            "source_date": item["date"],
            "source_license": item["license"],
            "source_page": item["source_page"],
            "source_file": part["source_file"],
            "source_dimensions": [width, height],
            "polygon_source_pixels": part["polygon"],
            "crop_origin_source_pixels": [crop_box[0], crop_box[1]],
            "anchor_source_pixels": part["anchor"],
            "output_file": str(output_path.relative_to(JOB_ROOT)).replace("\\", "/"),
            "output_dimensions": list(cutout.size),
        })

        preview = checker((THUMB_W, THUMB_H))
        cutout.thumbnail((THUMB_W - 12, THUMB_H - 12), Image.Resampling.LANCZOS)
        preview.paste(cutout, ((THUMB_W - cutout.width) // 2, (THUMB_H - cutout.height) // 2), cutout)
        rows.append((part["id"], preview))

    manifest_path = JOB_ROOT / "parts" / "parts_manifest_v01.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps({
        "batch": recipe["batch"],
        "status": "candidate",
        "mask_method": "supersampled polygon mask with Lanczos downsample",
        "source_pixels_are_preserved_inside_each_polygon": True,
        "parts": records,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    sheet = Image.new("RGB", (COLS * CELL_W, ((len(rows) + COLS - 1) // COLS) * CELL_H), "#252525")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except OSError:
        font = ImageFont.load_default()
    for index, (part_id, preview) in enumerate(rows):
        x = (index % COLS) * CELL_W
        y = (index // COLS) * CELL_H
        sheet.paste(preview, (x + (CELL_W - THUMB_W) // 2, y + 8))
        draw.text((x + 8, y + THUMB_H + 17), part_id, fill="white", font=font)
    preview_path = JOB_ROOT / "preview" / "parts_contact_sheet_v01.png"
    preview_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(preview_path, optimize=True)
    print(f"parts={len(records)}")
    print(f"manifest={manifest_path}")
    print(f"preview={preview_path}")


if __name__ == "__main__":
    main()
