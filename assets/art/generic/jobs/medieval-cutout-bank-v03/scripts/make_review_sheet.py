"""Create a non-destructive visual QA sheet for the v03 imagegen outputs."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
TILES = [
    ("Person cutout master", ROOT / "source_cutouts/person_st_john_baptist_imagegen_original.png", True),
    ("Animal cutout master", ROOT / "source_cutouts/animal_dragon_imagegen_original.png", True),
    ("Object cutout master", ROOT / "source_cutouts/object_banner_pole_imagegen_original.png", True),
    ("Environment candidate", ROOT / "candidates/backgrounds/landscape_no_figure.png", False),
    ("Four-source collage candidate", ROOT / "assemblies/landscape_dragon_figure_banner_montage_v01.png", False),
]
PREVIEW = ROOT / "preview"
PREVIEW.mkdir(parents=True, exist_ok=True)


def checker(size: tuple[int, int]) -> Image.Image:
    tile = 32
    image = Image.new("RGB", size, (242, 236, 223))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(214, 208, 197))
    return image


def trim_transparent(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return image
    pad = 24
    left, top, right, bottom = bbox
    return image.crop((max(0, left - pad), max(0, top - pad),
                       min(image.width, right + pad), min(image.height, bottom + pad)))


def main() -> None:
    columns, cell_w, cell_h = 3, 440, 610
    margin, gap = 28, 18
    rows = 2
    sheet = Image.new("RGB", (margin * 2 + columns * cell_w + (columns - 1) * gap,
                               margin * 2 + rows * cell_h + gap), (248, 245, 236))
    draw = ImageDraw.Draw(sheet)
    font_path = Path("C:/Windows/Fonts/arial.ttf")
    font = ImageFont.truetype(str(font_path), 20) if font_path.exists() else ImageFont.load_default()
    for index, (label, path, transparent) in enumerate(TILES):
        row, col = divmod(index, columns)
        x = margin + col * (cell_w + gap)
        y = margin + row * (cell_h + gap)
        draw.rounded_rectangle((x, y, x + cell_w, y + cell_h), radius=8,
                               fill=(255, 253, 247), outline=(174, 162, 142), width=2)
        draw.text((x + 14, y + 10), label, fill=(45, 38, 30), font=font)
        image = Image.open(path).convert("RGBA")
        if transparent:
            image = trim_transparent(image)
            bg = checker((cell_w - 28, cell_h - 64)).convert("RGBA")
            image.thumbnail((bg.width - 12, bg.height - 12), Image.Resampling.LANCZOS)
            bg.alpha_composite(image, ((bg.width - image.width) // 2, (bg.height - image.height) // 2))
            preview = bg.convert("RGB")
        else:
            image.thumbnail((cell_w - 28, cell_h - 64), Image.Resampling.LANCZOS)
            preview = Image.new("RGB", (cell_w - 28, cell_h - 64), (242, 236, 223))
            preview.paste(image.convert("RGB"), ((preview.width - image.width) // 2,
                                                    (preview.height - image.height) // 2))
        sheet.paste(preview, (x + 14, y + 48))
    output = PREVIEW / "imagegen_cutouts_review_v01.jpg"
    sheet.save(output, quality=94)
    print(output)


if __name__ == "__main__":
    main()
