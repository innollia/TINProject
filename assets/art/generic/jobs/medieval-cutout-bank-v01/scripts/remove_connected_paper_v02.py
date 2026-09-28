"""Create an alternate edge-connected paper matte for review."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

from extract_parts import JOB_ROOT, PADDING, SCALE, checker


OUT_DIR = JOB_ROOT / "parts" / "paper_matte_v02"
PREVIEW_PATH = JOB_ROOT / "preview" / "parts_contact_sheet_paper_matte_v02.png"


def border_points(width: int, height: int):
    for x in range(width):
        yield x, 0
        yield x, height - 1
    for y in range(1, height - 1):
        yield 0, y
        yield width - 1, y


def main() -> None:
    recipe = json.loads((JOB_ROOT / "recipes" / "parts_v01.json").read_text(encoding="utf-8"))
    records = []
    cards = []
    for part in recipe["parts"]:
        original = Image.open(JOB_ROOT / "source_images" / part["source_file"]).convert("RGBA")
        width, height = original.size
        mask_big = Image.new("L", (width * SCALE, height * SCALE), 0)
        ImageDraw.Draw(mask_big).polygon([(x * SCALE, y * SCALE) for x, y in part["polygon"]], fill=255)
        mask = mask_big.resize(original.size, Image.Resampling.LANCZOS)
        bounds = mask.getbbox()
        if bounds is None:
            continue
        left, top, right, bottom = bounds
        crop_box = (max(0, left - PADDING), max(0, top - PADDING), min(width, right + PADDING), min(height, bottom + PADDING))
        crop = original.crop(crop_box)
        crop_mask = mask.crop(crop_box)
        luminance = crop.convert("L")
        quantized = luminance.point(lambda value: value // 8 + 1)
        seeds = [(x, y) for x, y in border_points(*crop.size) if luminance.getpixel((x, y)) >= 180]
        for seed in seeds:
            if quantized.getpixel(seed) != 0:
                ImageDraw.floodfill(quantized, seed, 0, thresh=3)
        connected_paper = quantized.point(lambda value: 255 if value == 0 else 0)
        alpha = ImageChops.multiply(crop_mask, ImageChops.invert(connected_paper))
        crop.putalpha(alpha)

        out_path = OUT_DIR / part["source_accession"].replace(".", "") / f"{part['id']}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        crop.save(out_path, optimize=True)
        records.append({
            "id": part["id"],
            "source_accession": part["source_accession"],
            "output_file": str(out_path.relative_to(JOB_ROOT)).replace("\\", "/"),
            "dimensions": list(crop.size),
            "alpha_extrema": list(alpha.getextrema()),
            "method": "antialiased polygon plus edge-connected luminance floodfill",
        })
        preview = checker((270, 300))
        crop.thumbnail((258, 286), Image.Resampling.LANCZOS)
        preview.paste(crop, ((270 - crop.width) // 2, (300 - crop.height) // 2), crop)
        cards.append((part["id"], preview))

    manifest_path = OUT_DIR / "parts_manifest_paper_matte_v02.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps({
        "status": "rejected_experimental",
        "note": "Visual review showed this matte removes engraving linework and leaves noisy edges. Do not use these outputs as source parts.",
        "parts": records,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    cols, cell_w, cell_h = 4, 310, 350
    sheet = Image.new("RGB", (cols * cell_w, ((len(cards) + cols - 1) // cols) * cell_h), "#252525")
    draw = ImageDraw.Draw(sheet)
    for index, (name, preview) in enumerate(cards):
        x, y = (index % cols) * cell_w, (index // cols) * cell_h
        sheet.paste(preview, (x + 20, y + 8))
        draw.text((x + 8, y + 318), name, fill="white")
    PREVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(PREVIEW_PATH, optimize=True)
    print(f"parts={len(records)}")
    print(f"preview={PREVIEW_PATH}")


if __name__ == "__main__":
    main()
