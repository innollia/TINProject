"""Cut a CC0 medieval collage-part bank from the collected source pixels.

The source-image fragments keep the museum scan beneath visibly irregular cut
edges. No repainting or paper removal is performed. Parts stay candidates.
"""

from __future__ import annotations

import json
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "source_images"
OUT_DIR = ROOT / "parts"
PREVIEW_DIR = ROOT / "preview" / "parts"
BASE_RECIPE = ROOT.parent / "medieval-cutout-bank-v01" / "recipes" / "parts_v01.json"
EXTRA_SOURCES = {
    "1934.337", "1952.99", "1958.173", "1948.457", "1958.411",
    "1928.748", "1964.150.1", "1934.247", "2022.99", "1965.307", "1942.635",
}
TARGET_SCRAPS = 281

# These six second-layer fragments provide smaller neck, belly, hand, and foot
# joints. Their visible seams and source papers are intentional in this collage.
EXTRA_PARTS = [
    {
        "id": "stgeorge_neck_chainmail",
        "category": "neck",
        "source_accession": "1934.337",
        "source_file": "1934-337_print.jpg",
        "polygon": [[930, 442], [1048, 426], [1180, 442], [1282, 505], [1296, 610],
                    [1248, 689], [1140, 713], [1025, 668], [967, 596]],
        "anchor": [1110, 566],
    },
    {
        "id": "stgeorge_belly_plate",
        "category": "abdomen",
        "source_accession": "1934.337",
        "source_file": "1934-337_print.jpg",
        "polygon": [[796, 955], [883, 927], [1030, 960], [1212, 949], [1396, 983],
                    [1440, 1086], [1417, 1240], [1318, 1340], [1098, 1372],
                    [891, 1332], [794, 1246], [761, 1095]],
        "anchor": [1098, 1060],
    },
    {
        "id": "michael_sword_hand",
        "category": "hand",
        "source_accession": "1948.457",
        "source_file": "1948-457_print.jpg",
        "polygon": [[1017, 363], [1071, 323], [1139, 335], [1180, 380], [1193, 450],
                    [1145, 488], [1080, 472], [1038, 425]],
        "anchor": [1095, 431],
    },
    {
        "id": "michael_shield_hand",
        "category": "hand",
        "source_accession": "1948.457",
        "source_file": "1948-457_print.jpg",
        "polygon": [[1517, 1087], [1587, 1050], [1660, 1072], [1694, 1130],
                    [1672, 1190], [1605, 1218], [1542, 1182]],
        "anchor": [1608, 1123],
    },
    {
        "id": "stgeorge_left_boot_foot",
        "category": "foot",
        "source_accession": "1934.337",
        "source_file": "1934-337_print.jpg",
        "polygon": [[738, 2890], [796, 2840], [876, 2830], [932, 2883],
                    [1008, 2928], [1046, 3008], [1024, 3079], [946, 3112],
                    [850, 3084], [778, 3028], [744, 2968]],
        "anchor": [900, 2925],
    },
    {
        "id": "stgeorge_right_boot_foot",
        "category": "foot",
        "source_accession": "1934.337",
        "source_file": "1934-337_print.jpg",
        "polygon": [[1173, 2880], [1225, 2828], [1301, 2818], [1367, 2864],
                    [1432, 2924], [1457, 2997], [1426, 3068], [1357, 3092],
                    [1277, 3065], [1216, 3014], [1182, 2953]],
        "anchor": [1320, 2930],
    },
]


def source_path(row: dict) -> Path:
    accession = row["accession_number"].replace(".", "-")
    print_path = SOURCE_DIR / f"{accession}_print.jpg"
    if print_path.exists():
        return print_path
    return SOURCE_DIR / row["image_file"]


def export_polygon(source: Image.Image, points: list[list[int]], padding: int = 0) -> tuple[Image.Image, tuple[int, int, int, int]]:
    width, height = source.size
    left = max(0, min(p[0] for p in points) - padding)
    top = max(0, min(p[1] for p in points) - padding)
    right = min(width, max(p[0] for p in points) + padding)
    bottom = min(height, max(p[1] for p in points) + padding)
    crop = source.crop((left, top, right, bottom)).convert("RGBA")
    scale = 3
    mask_large = Image.new("L", (crop.width * scale, crop.height * scale), 0)
    local = [((x - left) * scale, (y - top) * scale) for x, y in points]
    ImageDraw.Draw(mask_large).polygon(local, fill=255)
    mask = mask_large.resize(crop.size, Image.Resampling.LANCZOS)
    crop.putalpha(mask)
    return crop, (left, top, right, bottom)


def detail_field(image: Image.Image) -> np.ndarray:
    small = image.convert("RGB")
    small.thumbnail((512, 512), Image.Resampling.LANCZOS)
    rgb = np.asarray(small, dtype=np.float32) / 255.0
    gray = 0.2126 * rgb[..., 0] + 0.7152 * rgb[..., 1] + 0.0722 * rgb[..., 2]
    dx = np.abs(np.diff(gray, axis=1, prepend=gray[:, :1]))
    dy = np.abs(np.diff(gray, axis=0, prepend=gray[:1, :]))
    # Score edges and hatch detail; solid black plate fields no longer win by
    # being dark, while engraving, cloth folds, faces, and paint boundaries do.
    return np.hypot(dx, dy)


def candidate_windows(field: np.ndarray, image_size: tuple[int, int]) -> list[tuple[float, tuple[float, float, float, float]]]:
    fw, fh = field.shape[1], field.shape[0]
    iw, ih = image_size
    ww, wh = max(4, int(fw * 0.27)), max(4, int(fh * 0.22))
    step_x, step_y = max(1, int(fw * 0.105)), max(1, int(fh * 0.09))
    integral = np.pad(field.cumsum(axis=0).cumsum(axis=1), ((1, 0), (1, 0)))
    windows = []
    for y in range(0, max(fh - wh + 1, 1), step_y):
        for x in range(0, max(fw - ww + 1, 1), step_x):
            score = (integral[y + wh, x + ww] - integral[y, x + ww]
                     - integral[y + wh, x] + integral[y, x]) / (ww * wh)
            box = (x / fw, y / fh, min(1.0, (x + ww) / fw), min(1.0, (y + wh) / fh))
            windows.append((float(score), box))
    windows.sort(key=lambda item: item[0], reverse=True)
    return windows


def iou(a, b) -> float:
    x0, y0 = max(a[0], b[0]), max(a[1], b[1])
    x1, y1 = min(a[2], b[2]), min(a[3], b[3])
    inter = max(0.0, x1 - x0) * max(0.0, y1 - y0)
    area_a = (a[2] - a[0]) * (a[3] - a[1])
    area_b = (b[2] - b[0]) * (b[3] - b[1])
    return inter / max(area_a + area_b - inter, 1e-9)


def select_windows(field, image_size, count: int) -> list[tuple[float, tuple[float, float, float, float]]]:
    selected = []
    for score, box in candidate_windows(field, image_size):
        if all(iou(box, prior[1]) < 0.12 for prior in selected):
            selected.append((score, box))
        if len(selected) == count:
            return selected
    return selected


def jagged_poly(box, seed: int, image_size) -> list[list[int]]:
    rng = random.Random(seed)
    iw, ih = image_size
    x0, y0, x1, y1 = box
    left, top, right, bottom = (x0 * iw, y0 * ih, x1 * iw, y1 * ih)
    w, h = right - left, bottom - top
    # Slight paper-torn edges retain enough area to use a crop as a body patch.
    verts = [
        (0.00, rng.uniform(0.04, 0.13)), (rng.uniform(0.10, 0.25), 0.00),
        (rng.uniform(0.38, 0.55), rng.uniform(0.02, 0.09)), (rng.uniform(0.72, 0.90), 0.00),
        (1.00, rng.uniform(0.07, 0.20)), (rng.uniform(0.89, 1.00), rng.uniform(0.34, 0.48)),
        (1.00, rng.uniform(0.68, 0.86)), (rng.uniform(0.74, 0.91), 1.00),
        (rng.uniform(0.38, 0.58), rng.uniform(0.91, 1.00)), (rng.uniform(0.08, 0.26), 1.00),
        (0.00, rng.uniform(0.70, 0.88)), (rng.uniform(0.01, 0.11), rng.uniform(0.36, 0.56)),
    ]
    return [[int(left + x * w), int(top + y * h)] for x, y in verts]


def clip_below_y(polygon: list[list[int]], max_y: int) -> list[list[int]]:
    """Clip a source polygon at the ankle line so the boot can be a separate cut."""
    out: list[list[int]] = []
    for index, current in enumerate(polygon):
        previous = polygon[index - 1]
        current_inside = current[1] <= max_y
        previous_inside = previous[1] <= max_y
        if current_inside != previous_inside:
            dy = current[1] - previous[1]
            t = (max_y - previous[1]) / dy if dy else 0.0
            x = round(previous[0] + t * (current[0] - previous[0]))
            out.append([x, max_y])
        if current_inside:
            out.append(current)
    return out


def make_preview(records: list[dict]) -> None:
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    cols, cell_w, cell_h = 8, 210, 230
    try:
        font = ImageFont.truetype("arial.ttf", 11)
    except OSError:
        font = ImageFont.load_default()
    for sheet_idx in range((len(records) + 63) // 64):
        group = records[sheet_idx * 64:(sheet_idx + 1) * 64]
        rows = math.ceil(len(group) / cols)
        sheet = Image.new("RGB", (cols * cell_w, rows * cell_h), "#272727")
        draw = ImageDraw.Draw(sheet)
        for i, record in enumerate(group):
            img = Image.open(ROOT / record["output_file"]).convert("RGBA")
            img.thumbnail((cell_w - 12, cell_h - 36), Image.Resampling.LANCZOS)
            tile = Image.new("RGBA", (cell_w - 12, cell_h - 36), "#dddddd")
            px = tile.load()
            for yy in range(tile.height):
                for xx in range(tile.width):
                    if (xx // 12 + yy // 12) % 2:
                        px[xx, yy] = (188, 188, 188, 255)
            tile.alpha_composite(img, ((tile.width - img.width) // 2, (tile.height - img.height) // 2))
            x, y = (i % cols) * cell_w, (i // cols) * cell_h
            sheet.paste(tile.convert("RGB"), (x + 6, y + 4))
            draw.text((x + 6, y + cell_h - 25), record["id"][:28], fill="white", font=font)
            draw.text((x + 6, y + cell_h - 12), record["category"], fill="#c8d8ff", font=font)
        sheet.save(PREVIEW_DIR / f"catalog_{sheet_idx + 1:02d}.jpg", quality=88)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    source_manifest = json.loads((ROOT / "sources.json").read_text(encoding="utf-8"))
    source_by_id = {row["accession_number"]: row for row in source_manifest["records"]}
    extracted: list[dict] = []
    source_cache: dict[str, Image.Image] = {}

    def get_source(accession: str, source_file: str | None = None) -> tuple[Image.Image, Path, dict]:
        row = source_by_id[accession]
        path = source_path(row)
        if source_file is not None and accession == "1934.337":
            path = SOURCE_DIR / "1934-337_print.jpg"
        if accession not in source_cache:
            source_cache[accession] = Image.open(path).convert("RGB")
        return source_cache[accession], path, row

    old_recipe = json.loads(BASE_RECIPE.read_text(encoding="utf-8"))
    # Preserve the existing 11 source-cut figure parts and two Schongauer wings,
    # but extract them again from the print files in this batch.
    for part in old_recipe["parts"]:
        accession = part["source_accession"]
        source, path, row = get_source(accession, part["source_file"])
        polygon = part["polygon"]
        if part["id"] == "stgeorge_left_shin_boot":
            polygon = clip_below_y(polygon, 2890)
        elif part["id"] == "stgeorge_right_shin_boot":
            polygon = clip_below_y(polygon, 2890)
        crop, bounds = export_polygon(source, polygon, padding=4)
        output = OUT_DIR / "rig_figure" / f"{part['id']}.png"
        output.parent.mkdir(parents=True, exist_ok=True)
        crop.save(output, optimize=True)
        extracted.append({
            "id": part["id"], "category": part["category"], "status": "candidate",
            "assembly_group": "stgeorge_source_figure",
            "source_accession": accession, "source_title": row["title"],
            "source_artist": row["artist"], "source_date": row["date"],
            "source_license": row["license"], "source_page": row["source_page"],
            "source_file": path.name, "source_dimensions": list(source.size),
            "polygon_source_pixels": polygon, "crop_origin_source_pixels": [bounds[0], bounds[1]],
            "pivot_source_pixels": part["anchor"],
            "output_file": str(output.relative_to(ROOT)).replace("\\", "/"),
            "output_dimensions": list(crop.size),
            "source_pixels_preserved_inside_mask": True,
        })

    for part in EXTRA_PARTS:
        source, path, row = get_source(part["source_accession"], part["source_file"])
        crop, bounds = export_polygon(source, part["polygon"], padding=4)
        output = OUT_DIR / "rig_figure" / f"{part['id']}.png"
        crop.save(output, optimize=True)
        extracted.append({
            "id": part["id"], "category": part["category"], "status": "candidate",
            "assembly_group": "stgeorge_collage_extension",
            "source_accession": part["source_accession"], "source_title": row["title"],
            "source_artist": row["artist"], "source_date": row["date"],
            "source_license": row["license"], "source_page": row["source_page"],
            "source_file": path.name, "source_dimensions": list(source.size),
            "polygon_source_pixels": part["polygon"], "crop_origin_source_pixels": [bounds[0], bounds[1]],
            "pivot_source_pixels": part["anchor"],
            "output_file": str(output.relative_to(ROOT)).replace("\\", "/"),
            "output_dimensions": list(crop.size),
            "source_pixels_preserved_inside_mask": True,
        })

    if len(extracted) != 19:
        raise RuntimeError(f"expected 19 source-figure and wing parts, got {len(extracted)}")

    fragment_root = OUT_DIR / "fragments"
    fragment_root.mkdir(parents=True, exist_ok=True)
    ranked = []
    for row in source_manifest["records"]:
        path = source_path(row)
        source = Image.open(path).convert("RGB")
        field = detail_field(source)
        desired = 6 if row["accession_number"] in EXTRA_SOURCES else 5
        boxes = select_windows(field, source.size, desired)
        for local_index, (score, box) in enumerate(boxes, start=1):
            ranked.append((row, source, path, score, box, local_index))

    # Use 5 crops per source (270) plus one extra from the 11 visually varied
    # anchor works (11), reaching exactly 281 additional unique fragments.
    chosen = []
    by_accession: dict[str, list] = {}
    for item in ranked:
        by_accession.setdefault(item[0]["accession_number"], []).append(item)
    for row in source_manifest["records"]:
        candidates = by_accession[row["accession_number"]]
        wanted = 6 if row["accession_number"] in EXTRA_SOURCES else 5
        chosen.extend(candidates[:wanted])
    chosen = chosen[:TARGET_SCRAPS]
    if len(chosen) != TARGET_SCRAPS:
        raise RuntimeError(f"wanted {TARGET_SCRAPS} fragments, selected {len(chosen)}")

    for index, (row, source, path, score, box, local_index) in enumerate(chosen, start=1):
        sw, sh = source.size
        x0, y0, x1, y1 = box
        x0, y0, x1, y1 = int(x0 * sw), int(y0 * sh), int(x1 * sw), int(y1 * sh)
        normalized = (x0 / sw, y0 / sh, x1 / sw, y1 / sh)
        polygon = jagged_poly(normalized, seed=index * 17 + local_index, image_size=source.size)
        crop, bounds = export_polygon(source, polygon, padding=0)
        output_name = f"{index:03d}_{row['accession_number'].replace('.', '-')}_scrap{local_index}.png"
        output = fragment_root / output_name
        crop.save(output, optimize=True)
        extracted.append({
            "id": f"fragment_{index:03d}_{row['accession_number'].replace('.', '')}_{local_index}",
            "category": "collage_fragment",
            "status": "candidate_unreviewed",
            "assembly_group": "source_scrap_pool",
            "source_accession": row["accession_number"], "source_title": row["title"],
            "source_artist": row["artist"], "source_date": row["date"],
            "source_license": row["license"], "source_page": row["source_page"],
            "source_file": path.name, "source_dimensions": [sw, sh],
            "polygon_source_pixels": polygon, "crop_origin_source_pixels": [bounds[0], bounds[1]],
            "pivot_source_pixels": [round((bounds[0] + bounds[2]) / 2), round((bounds[1] + bounds[3]) / 2)],
            "detail_score": round(score, 6),
            "output_file": str(output.relative_to(ROOT)).replace("\\", "/"),
            "output_dimensions": list(crop.size),
            "source_pixels_preserved_inside_mask": True,
            "mask_method": "deterministic high-detail window plus irregular polygon cut; no paper removal",
        })

    if len(extracted) != 300:
        raise RuntimeError(f"expected exactly 300 parts, got {len(extracted)}")
    manifest = {
        "batch": "medieval-cutout-bank-v02",
        "status": "candidate",
        "part_count": len(extracted),
        "source_artwork_count": len(source_manifest["records"]),
        "source_policy": source_manifest["source_policy"],
        "source_pixels_preserved_inside_each_mask": True,
        "background_removal": "none; visible source paper and print background retained",
        "parts": extracted,
    }
    (OUT_DIR / "parts_manifest_v02.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    make_preview(extracted)
    print(f"parts={len(extracted)} figure_parts=19 collage_fragments={TARGET_SCRAPS}")
    print(f"manifest={OUT_DIR / 'parts_manifest_v02.json'}")
    print(f"preview_dir={PREVIEW_DIR}")


if __name__ == "__main__":
    main()
