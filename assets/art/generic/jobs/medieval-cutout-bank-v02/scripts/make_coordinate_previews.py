"""Create temporary coordinate overlays for hand-authored polygon checks."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCES = ROOT / "source_images"
OUT = ROOT / "preview" / "coordinate_checks"
OUT.mkdir(parents=True, exist_ok=True)

try:
    FONT = ImageFont.truetype("arial.ttf", 16)
except OSError:
    FONT = ImageFont.load_default()

def crop_grid(file_name, box, output):
    im = Image.open(SOURCES / file_name).convert("RGB").crop(box)
    draw = ImageDraw.Draw(im)
    x0, y0, x1, y1 = box
    for x in range((x0 // 200) * 200, x1 + 1, 200):
        lx = x - x0
        draw.line((lx, 0, lx, im.height), fill="#ff00ff", width=1)
        draw.text((lx + 2, 2), str(x), fill="#ff00ff", font=FONT, stroke_width=2, stroke_fill="white")
    for y in range((y0 // 200) * 200, y1 + 1, 200):
        ly = y - y0
        draw.line((0, ly, im.width, ly), fill="#00aaff", width=1)
        draw.text((2, ly + 2), str(y), fill="#0070aa", font=FONT, stroke_width=2, stroke_fill="white")
    path = OUT / output
    im.save(path, quality=92)
    print(path)

crop_grid("1958-411_print.jpg", (0, 2400, 1953, 3400), "sebastian_lower_grid.jpg")
crop_grid("1948-457_print.jpg", (400, 100, 1500, 1300), "michael_upper_grid.jpg")
crop_grid("1948-457_print.jpg", (1000, 900, 2247, 2300), "michael_lower_grid.jpg")
