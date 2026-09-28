"""Compose a review-only still from preserved scene and knight candidates."""

from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
PROJECT = Path(__file__).resolve().parents[6]
BACKGROUND = PROJECT / "assets/art/generic/jobs/medieval-cutout-bank-v04/candidates/backgrounds/landscape_penitence_no_figure.png"
KNIGHT = JOB / "assemblies/knight_winged_idle_rest.png"
OUT = JOB / "preview/knight_in_landscape_v05.png"


def main() -> None:
    canvas_size = (1152, 720)
    background = Image.open(BACKGROUND).convert("RGBA")
    scale = max(canvas_size[0] / background.width, canvas_size[1] / background.height)
    bg_size = (round(background.width * scale), round(background.height * scale))
    background = background.resize(bg_size, Image.Resampling.LANCZOS)
    x = (background.width - canvas_size[0]) // 2
    y = (background.height - canvas_size[1]) // 2
    canvas = background.crop((x, y, x + canvas_size[0], y + canvas_size[1]))
    knight = Image.open(KNIGHT).convert("RGBA")
    knight = knight.resize((520, 552), Image.Resampling.LANCZOS)
    canvas.alpha_composite(knight, (345, 145))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT, optimize=True)
    print(OUT)


if __name__ == "__main__":
    main()
