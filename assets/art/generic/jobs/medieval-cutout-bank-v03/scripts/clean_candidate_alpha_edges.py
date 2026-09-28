"""Clear only tiny residual alpha specks on the outer canvas edge of candidates.

The untouched imagegen masters in source_cutouts/ are never modified.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FILES = [
    ROOT / "candidates/cutouts/person_st_john_baptist.png",
    ROOT / "candidates/cutouts/animal_dragon.png",
    ROOT / "candidates/cutouts/object_banner_pole.png",
]
EDGE = 3
THRESHOLD = 5


def main() -> None:
    for path in FILES:
        image = Image.open(path).convert("RGBA")
        alpha = image.getchannel("A")
        pixels = alpha.load()
        changed = 0
        for y in range(image.height):
            for x in range(image.width):
                on_outer_edge = x < EDGE or y < EDGE or x >= image.width - EDGE or y >= image.height - EDGE
                if on_outer_edge and 0 < pixels[x, y] <= THRESHOLD:
                    pixels[x, y] = 0
                    changed += 1
        image.putalpha(alpha)
        image.save(path, optimize=True)
        print(path.name, "cleared outer-edge alpha specks:", changed,
              "final alpha bounds:", alpha.getbbox())


if __name__ == "__main__":
    main()
