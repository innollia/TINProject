"""Build neutral-background review sheets from proc_bake raster assemblies."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSEMBLIES = ROOT / "assemblies" / "candidate"
ITEMS = [
    ("winged_patchwork_knight_walk", "Walk / 23 joined pieces"),
    ("gilded_saint_cutout_idle", "Idle / 23 joined pieces"),
    ("torn_reliquary_messenger_alert", "Alert / 24 joined pieces"),
]
PAPER = (232, 220, 197, 255)


def font(size: int) -> ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/arial.ttf"),
        Path("C:/Windows/Fonts/georgia.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def flatten(image: Image.Image) -> Image.Image:
    background = Image.new("RGBA", image.size, PAPER)
    background.alpha_composite(image.convert("RGBA"))
    return background.convert("RGB")


def main() -> None:
    card_w, card_h = 430, 780
    margin, gap = 26, 20
    sheet = Image.new("RGB", (margin * 2 + card_w * 3 + gap * 2, card_h + margin * 2), (246, 240, 225))
    draw = ImageDraw.Draw(sheet)
    title_font = font(27)
    sub_font = font(17)
    body_font = font(15)
    draw.text((margin, 13), "MEDIEVAL CUTOUT ASSEMBLIES / CANDIDATES", fill=(45, 37, 29), font=title_font)
    draw.text((margin, 48), "Raster pixels from CC0 museum prints; joints and motion baked with tools/proc_bake.",
              fill=(85, 70, 53), font=sub_font)
    for i, (name, label) in enumerate(ITEMS):
        x = margin + i * (card_w + gap)
        y = 88
        draw.rounded_rectangle((x, y, x + card_w, y + card_h), radius=7,
                               fill=(250, 247, 238), outline=(187, 172, 146), width=2)
        draw.text((x + 15, y + 12), label, fill=(45, 37, 29), font=sub_font)
        image = Image.open(ASSEMBLIES / f"{name}_rest.png").convert("RGBA")
        image.thumbnail((card_w - 32, card_h - 86), Image.Resampling.LANCZOS)
        flat = flatten(image)
        left = x + (card_w - flat.width) // 2
        top = y + 48 + (card_h - 60 - flat.height) // 2
        sheet.paste(flat, (left, top))
        draw.text((x + 15, y + card_h - 28), "CANDIDATE — visible cuts and mixed print sources retained",
                  fill=(104, 68, 45), font=body_font)
    output = ASSEMBLIES / "assemblies_contact_sheet_v02.jpg"
    sheet.save(output, quality=94)
    for name, _ in ITEMS:
        strip = Image.open(ASSEMBLIES / f"{name}_strip.png").convert("RGBA")
        flattened = flatten(strip)
        flattened.save(ASSEMBLIES / f"{name}_strip_review.jpg", quality=92)
    print(output)


if __name__ == "__main__":
    main()
