from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "preview" / "medieval_cutout_bank_v04_review.jpg"
CANVAS = Image.new("RGB", (1760, 1220), "#242322")
DRAW = ImageDraw.Draw(CANVAS)
try:
    TITLE_FONT = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 30)
    LABEL_FONT = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 20)
except OSError:
    TITLE_FONT = ImageFont.load_default()
    LABEL_FONT = ImageFont.load_default()
DRAW.text((44, 26), "MEDIEVAL CUTOUT BANK V04 — CANDIDATES", fill="#f3eee6", font=TITLE_FONT)

items = [
    ("archangel_body.png", "ARCHANGEL FIGURE — WINGS RETAINED"),
    ("archangel_left_wing.png", "LEFT WING CUTOUT"),
    ("archangel_right_wing.png", "RIGHT WING CUTOUT"),
    ("landscape_penitence_no_figure.png", "PENITENCE LANDSCAPE BACKGROUND"),
    ("winged_archangel_patchwork_montage_v01.png", "ARCHANGEL + DRAGON + BANNER COLLAGE"),
]
card_w, card_h = 540, 520
left, top, gap_x, gap_y = 44, 90, 28, 24
for index, (name, label) in enumerate(items):
    col, row = index % 3, index // 3
    x = left + col * (card_w + gap_x)
    y = top + row * (card_h + gap_y)
    DRAW.rounded_rectangle((x, y, x + card_w, y + card_h), radius=12, fill="#343230", outline="#625d56", width=2)
    label_y = y + card_h - 44
    DRAW.text((x + 16, label_y), label, fill="#f3eee6", font=LABEL_FONT)
    path = ROOT / ("candidates/cutouts/" + name if name.endswith(".png") and name in {"archangel_body.png", "archangel_left_wing.png", "archangel_right_wing.png"} else "candidates/backgrounds/" + name if name == "landscape_penitence_no_figure.png" else "assemblies/" + name)
    image = Image.open(path).convert("RGBA")
    box = (x + 12, y + 12, card_w - 24, card_h - 68)
    thumb = ImageOps.contain(image, (box[2], box[3]), method=Image.Resampling.LANCZOS)
    px = x + 12 + (box[2] - thumb.width) // 2
    py = y + 12 + (box[3] - thumb.height) // 2
    if image.getchannel("A").getextrema() != (255, 255):
        tile = Image.new("RGB", thumb.size, "#dddddd")
        checker = ImageDraw.Draw(tile)
        step = 18
        for yy in range(0, thumb.height, step):
            for xx in range(0, thumb.width, step):
                if (xx // step + yy // step) % 2:
                    checker.rectangle((xx, yy, xx + step - 1, yy + step - 1), fill="#bcbcbc")
        tile.paste(thumb, mask=thumb.getchannel("A"))
    else:
        tile = Image.new("RGB", thumb.size, "#ece9e3")
        tile.paste(thumb, mask=thumb.getchannel("A"))
    CANVAS.paste(tile, (px, py))
CANVAS.save(OUT, quality=92, optimize=True)
print(OUT)
