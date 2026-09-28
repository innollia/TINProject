"""Build a checkerboard review sheet for generated assembly candidates."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CANDIDATE_DIR = ROOT / "assemblies" / "candidate"
ENTRIES = [
    {
        "file": "winged_st_george_imagegen_v01.png",
        "label": "Winged St George / initial pose",
        "source_accessions": ["1934.337", "1952.99"],
        "status": "candidate",
        "method": "image-generation interpretation",
        "note": "First composite study; source details may be reinterpreted.",
    },
    {
        "file": "winged_st_george_pose_v02_imagegen_candidate.png",
        "label": "Winged St George / stepping pose",
        "source_accessions": ["1934.337", "1952.99"],
        "status": "candidate",
        "method": "image-generation interpretation",
        "note": "Different arm and wing pose; source details may be reinterpreted.",
    },
    {
        "file": "annunciation_angel_imagegen_interpretation_v01.png",
        "label": "Annunciation angel / generated interpretation",
        "source_accessions": ["1958.173"],
        "status": "out_of_brief_variant_candidate",
        "method": "image-generation interpretation",
        "note": "Prompt requested the source kneeling pose; the output changed it to standing. Retained as a separate variation, not as a source-faithful cutout.",
    },
]


def checkerboard(size: tuple[int, int], tile: int = 20) -> Image.Image:
    image = Image.new("RGB", size, "#f3f3f3")
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill="#d1d1d1")
    return image


def main() -> None:
    manifest_items = []
    for entry in ENTRIES:
        path = CANDIDATE_DIR / entry["file"]
        image = Image.open(path).convert("RGBA")
        alpha_bbox = image.getchannel("A").getbbox()
        manifest_items.append({
            **entry,
            "dimensions": list(image.size),
            "alpha_bbox": list(alpha_bbox) if alpha_bbox else None,
            "alpha_extrema": list(image.getchannel("A").getextrema()),
            "project_relative_file": str(path.relative_to(ROOT)).replace("\\", "/"),
        })

    manifest_path = CANDIDATE_DIR / "assemblies_manifest_v01.json"
    manifest_path.write_text(json.dumps({
        "batch": "medieval-cutout-bank-v01",
        "approval_status": "all unapproved candidates",
        "assemblies": manifest_items,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    tile_w, tile_h, pad = 430, 620, 20
    sheet = Image.new("RGB", (3 * tile_w + 4 * pad, tile_h + 2 * pad), "#222222")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("arial.ttf", 19)
    except OSError:
        font = ImageFont.load_default()
    for index, item in enumerate(manifest_items):
        image = Image.open(CANDIDATE_DIR / item["file"]).convert("RGBA")
        image.thumbnail((tile_w - 20, tile_h - 72), Image.Resampling.LANCZOS)
        tile = checkerboard((tile_w, tile_h - 55))
        tile.paste(image, ((tile_w - image.width) // 2, 0), image)
        x = pad + index * (tile_w + pad)
        y = pad
        sheet.paste(tile, (x, y))
        draw.text((x + 8, y + tile.height + 8), item["label"], fill="white", font=font)
    output = ROOT / "preview" / "assembly_candidates_contact_sheet_v01.png"
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, optimize=True)
    print(f"assemblies={len(manifest_items)}")
    print(f"manifest={manifest_path}")
    print(f"preview={output}")


if __name__ == "__main__":
    main()
