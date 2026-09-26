"""Generate an at-icons composition-count experiment and its candidate board."""

from __future__ import annotations

import html
import json
import shutil
import subprocess
from pathlib import Path
from typing import Any
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
ICON_DIR = ROOT / "addons" / "at-icons" / "node2d"
ICON_SOURCE_SIZE = 16
ICON_DISPLAY_SIZE = 48
ICON_SCALE = ICON_DISPLAY_SIZE / ICON_SOURCE_SIZE
GRID_PITCH = 56
BG = "#eee4d0"
PANEL = "#fbf6e9"
INK = "#302b35"
MUTED = "#776d71"
PALETTE = {
    "leaf": "#66815b",
    "leaf_light": "#9cae78",
    "bark": "#95634d",
    "bark_light": "#c48e5c",
    "skin": "#c88668",
    "skin_light": "#e2ad7d",
    "cloth": "#537b73",
    "cloth_light": "#a0aa7b",
    "plum": "#735367",
    "plum_light": "#c17a78",
    "gold": "#d9a650",
    "cream": "#f0d9ad",
    "blue": "#647f8e",
    "ink": INK,
    "stone": "#99918b",
    "white": "#f5ead3",
}

# An instance is (source icon, center x, center y, rotation, mirror-x, palette key, body slot).
Instance = tuple[str, float, float, int, bool, str, str]


def inst(name: str, x: float, y: float, color: str, slot: str = "object",
         angle: int = 0, mirror: bool = False) -> Instance:
    if angle != 0 or mirror:
        raise ValueError("This experiment forbids per-icon rotation and mirroring")
    return (name, x, y, angle, mirror, color, slot)


def grid_inst(name: str, column: int, row: int, color: str, slot: str = "object") -> Instance:
    return inst(name, 24 + column * GRID_PITCH, 24 + row * GRID_PITCH, color, slot)


def centered_cells(width: int, row: int, names: list[str], color: str,
                   slot: str = "canopy") -> list[Instance]:
    start = (width - len(names)) // 2
    return [grid_inst(name, start + index, row,
                      ["leaf", "leaf_light", "cream"][index % 3] if color == "tree_cycle" else color,
                      slot) for index, name in enumerate(names)]


def repeat_cells(cells: list[tuple[int, int, str, str, str]]) -> list[Instance]:
    return [grid_inst(icon, column, row, color, slot)
            for column, row, icon, color, slot in cells]


def tree_samples() -> dict[str, list[Instance]]:
    canopy_icons = ["cloud", "leaf", "sprout", "sponge"]

    def canopy(widths: list[int]) -> list[Instance]:
        result: list[Instance] = []
        cursor = 0
        for row, width in enumerate(widths):
            names = [canopy_icons[(cursor + index) % len(canopy_icons)] for index in range(width)]
            result.extend(centered_cells(10, row, names, "tree_cycle"))
            cursor += width
        return result

    low = canopy([1, 2, 3]) + [
        grid_inst("cylinder", 4, 3, "bark", "trunk"),
        grid_inst("cylinder", 4, 4, "bark_light", "trunk"),
    ]
    medium = canopy([2, 3, 3]) + [
        grid_inst("cylinder", column, row, "bark" if row % 2 == 0 else "bark_light", "trunk")
        for row in range(3, 6) for column in (4, 5)
    ]
    high = canopy([4, 6, 8] + [9] * 8) + [
        grid_inst("cylinder", column, row, "bark" if (column + row) % 2 == 0 else "bark_light", "trunk")
        for row in range(11, 16) for column in (4, 5)
    ]
    return {"low": low, "medium": medium, "high": high}


def person_samples(modular: bool = False) -> dict[str, list[Instance]]:
    colors = ("skin_light", "skin", "cloth", "cloth_light", "plum", "blue")
    base = [
        (5, 0, "circle", "skin", "head"), (6, 0, "eye", "ink", "face"),
        (4, 1, "wing", "cloth_light", "arm_left"), (5, 1, "shield", "cloth", "torso"),
        (6, 1, "wing", "cloth", "arm_right"), (5, 2, "triangle", "gold", "top"),
        (4, 3, "pencil", "blue", "leg_left"), (5, 3, "box", "plum", "bottom"),
        (6, 3, "pencil", "blue", "leg_right"),
    ]
    additions = [
        (4, 0, "feather", "plum", "head"),
        (3, 1, "hand", "skin_light", "arm_left"), (7, 1, "hand", "skin", "arm_right"),
        (4, 2, "cube", "cloth_light", "top"), (6, 2, "gem", "gold", "top"),
    ]
    medium = repeat_cells(base + additions)

    # A 12-column tiled figure: 16 head/face cells, 30 torso/top cells,
    # 30 arm cells and 24 leg/bottom cells. Every 48 px glyph occupies its
    # own 56 px grid cell, so no pair overlaps.
    high_cells: list[tuple[int, int, str, str, str]] = []
    head_icons = ["circle", "feather", "cloud", "gem"] if modular else ["circle", "feather", "circle", "cloud"]
    for row in range(4):
        for column in range(4, 8):
            is_face = (column, row) in {(5, 1), (6, 1)}
            icon = (["eye", "glasses"][(column + row) % 2] if is_face
                    else head_icons[(column + row) % len(head_icons)])
            high_cells.append((column, row, icon, "skin" if not is_face else "ink", "face" if is_face else "head"))

    torso_icons = ["shield", "cube", "box", "diamond", "triangle", "road"]
    top_coords = {(column, row) for row in (4, 5) for column in range(3, 7)}
    for row in range(4, 9):
        for column in range(3, 9):
            is_top = (column, row) in top_coords
            high_cells.append((column, row, torso_icons[(column + row) % len(torso_icons)],
                               "cloth_light" if (column + row) % 2 else "plum",
                               "top" if is_top else "torso"))

    arm_icons = ["wing", "feather", "hand", "pencil", "arrow_up", "cube"]
    for row in range(4, 9):
        for column in range(3):
            high_cells.append((column, row, arm_icons[(column + row) % len(arm_icons)],
                               colors[(column + row) % len(colors)], "arm_left"))
        for column in range(9, 12):
            high_cells.append((column, row, arm_icons[(column + row + 2) % len(arm_icons)],
                               colors[(column + row) % len(colors)], "arm_right"))

    leg_icons = ["pencil", "arrow_up", "road", "cylinder", "triangle"]
    for row in range(9, 13):
        for column in range(3, 9):
            is_bottom = row == 12
            high_cells.append((column, row, leg_icons[(column + row) % len(leg_icons)],
                               "plum" if is_bottom else "blue",
                               "bottom" if is_bottom else ("leg_left" if column < 6 else "leg_right")))

    high = repeat_cells(high_cells)
    return {"low": repeat_cells(base), "medium": medium, "high": high}


def modular_samples() -> dict[str, list[Instance]]:
    human = person_samples(modular=True)
    # The same count ladder is used, with a swappable base silhouette and
    # clearly separated slots so each SVG layer can be replaced in place.
    return human


def bomb_samples() -> dict[str, list[Instance]]:
    low = [
        grid_inst("hook", 4, 0, "bark", "fuse"),
        grid_inst("sphere", 4, 1, "plum", "shell"),
        grid_inst("ring", 5, 1, "plum_light", "shell"),
    ]
    medium = low + [
        grid_inst("sphere", 3, 1, "plum_light", "shell"),
        grid_inst("sphere", 4, 2, "plum", "shell"),
    ]
    shell_widths = [4, 6, 8, 10, 10, 10, 10, 10, 8, 4, 4, 6]
    shell_icons = ["sphere", "circle", "cube", "diamond", "shield"]
    high: list[Instance] = []
    for row, width in enumerate(shell_widths, start=5):
        start = (10 - width) // 2
        for index in range(width):
            high.append(grid_inst(shell_icons[(row + index) % len(shell_icons)], start + index, row,
                                  ["plum", "plum_light", "bark", "stone"][index % 4], "shell"))
    fuse_icons = ["hook", "cylinder", "arrow_up", "feather"]
    for row in range(5):
        for index, column in enumerate((4, 5)):
            high.append(grid_inst(fuse_icons[(row + index) % len(fuse_icons)], column, row,
                                  "gold" if row % 2 == 0 else "bark_light", "fuse"))
    return {"low": low, "medium": medium, "high": high}


def rabbit_samples() -> dict[str, list[Instance]]:
    low = [
        grid_inst("feather", 3, 0, "plum_light", "ears"),
        grid_inst("feather", 5, 0, "plum", "ears"),
        grid_inst("circle", 4, 1, "cream", "head"),
        grid_inst("cloud", 4, 2, "stone", "body"),
    ]
    medium = low + [
        grid_inst("paw_print", 3, 3, "gold", "feet"),
        grid_inst("paw_print", 5, 3, "gold", "feet"),
        grid_inst("egg", 6, 2, "white", "tail"),
    ]
    high: list[Instance] = []
    # 10 ear tiles, 20 head/face tiles, 50 body tiles, 12 feet tiles,
    # and 8 tail tiles make a single 100-instance large-creature sample.
    for row in range(5):
        for column in (3, 5):
            high.append(grid_inst("feather" if row % 2 == 0 else "leaf", column, row,
                                  "plum" if column == 3 else "plum_light", "ears"))
    head_icons = ["circle", "eye", "glasses", "gem", "cloud"]
    for row in range(5, 9):
        for column in range(2, 7):
            face = row == 6 and column in (3, 5)
            high.append(grid_inst("eye" if face else head_icons[(column + row) % len(head_icons)],
                                  column, row, "ink" if face else "cream", "face" if face else "head"))
    body_icons = ["cloud", "egg", "circle", "feather", "leaf"]
    for row in range(9, 19):
        for column in range(2, 7):
            high.append(grid_inst(body_icons[(column + row) % len(body_icons)], column, row,
                                  "stone" if (column + row) % 2 else "white", "body"))
    foot_icons = ["paw_print", "triangle", "sphere"]
    for row in range(19, 22):
        for column in (1, 2, 6, 7):
            high.append(grid_inst(foot_icons[(column + row) % len(foot_icons)], column, row,
                                  "gold", "feet"))
    for row in range(14, 18):
        for column in (7, 8):
            high.append(grid_inst("egg" if row % 2 == 0 else "cloud", column, row,
                                  "white", "tail"))
    return {"low": low, "medium": medium, "high": high}


def recipes() -> dict[str, dict[str, list[Instance]]]:
    return {
        "large_tree": tree_samples(),
        "neutral_human": person_samples(),
        "modular_parts": modular_samples(),
        "bomb": bomb_samples(),
        "rabbit": rabbit_samples(),
    }


SAMPLES = recipes()
ROW_META = {
    "large_tree": {
        "label": "큰 나무",
        "rule": {
            "low": "잎 glyph 6개 + 원통 2개를 수직 적층",
            "medium": "수관 glyph 8개 + 원통 6개를 2열로 적층",
            "high": "수관 90개 + 원통 10개로 큰 덩어리 실험",
        },
        "scale": {"low": "작은 배경 수목", "medium": "중간 거리 월드 오브젝트", "high": "큰 장면 랜드마크"},
        "risk": {"low": "기둥이 가늘고 수관이 약함", "medium": "원통 반복이 목재 기둥처럼 튐", "high": "수관이 무늬 벽처럼 되고 기둥이 막대 더미로 읽힘"},
    },
    "neutral_human": {
        "label": "인체 기본형",
        "rule": {
            "low": "머리·얼굴·몸통·상의/하의·좌우 팔/다리",
            "medium": "머리·손·의상 슬롯에 다섯 조각 추가",
            "high": "12열 타일 실루엣을 머리·몸통·팔·다리 슬롯으로 분배",
        },
        "scale": {"low": "멀리 있는 인물 실루엣", "medium": "중거리 NPC 기본형", "high": "화면 전경 크기의 인물 덩어리"},
        "risk": {"low": "얼굴과 팔다리 형태가 약함", "medium": "손/안경 glyph의 의미가 튐", "high": "인체 형태보다 격자 모자이크가 먼저 읽힘"},
    },
    "modular_parts": {
        "label": "교체식 인체 파츠",
        "rule": {
            "low": "머리·얼굴·몸통·좌우 팔/다리·상의·하의 분리",
            "medium": "같은 슬롯에 다섯 보조 조각을 배치",
            "high": "100개를 슬롯별 타일로 나누어 대량 파츠 경계 확인",
        },
        "scale": {"low": "파츠 교체 슬롯 구조 확인", "medium": "교체식 캐릭터 제작 후보", "high": "대형 조립체의 슬롯 경계 스트레스 테스트"},
        "risk": {"low": "관절과 표정 세부가 부족함", "medium": "상의와 몸통이 가까워 경계가 약함", "high": "고밀도에서 교체 경계가 사라짐"},
    },
    "bomb": {
        "label": "폭탄",
        "rule": {
            "low": "구형 껍질 2개 + 퓨즈 1개",
            "medium": "껍질 4개 + 퓨즈 1개를 인접 배치",
            "high": "껍질 90개 + 2열 퓨즈 10개로 거대 소품 구성",
        },
        "scale": {"low": "작은 소품", "medium": "손에 드는 초점 소품", "high": "큰 화면 오브젝트 스트레스 테스트"},
        "risk": {"low": "구형/퓨즈 단서가 부족함", "medium": "고리 glyph가 따로 읽힘", "high": "폭탄보다 둥근 모자이크 덩어리로 읽힘"},
    },
    "rabbit": {
        "label": "토끼",
        "rule": {
            "low": "긴 귀 2개 + 머리 + 몸통",
            "medium": "발 2개와 꼬리를 붙여 앉은 자세 구성",
            "high": "귀 10·머리 20·몸통 50·발 12·꼬리 8개로 대형 생물 타일화",
        },
        "scale": {"low": "작은 동물 실루엣", "medium": "월드 생물 크기", "high": "큰 캐릭터형 생물 스트레스 테스트"},
        "risk": {"low": "얼굴 특징과 발이 없음", "medium": "발바닥/달걀 glyph가 튐", "high": "토끼보다 군집이나 패턴으로 읽힘"},
    },
}


def load_icons(names: set[str]) -> dict[str, list[dict[str, str]]]:
    result: dict[str, list[dict[str, str]]] = {}
    for name in sorted(names):
        path = ICON_DIR / f"{name}.svg"
        root = ET.parse(path).getroot()
        viewbox = root.attrib.get("viewBox", "").split()
        if viewbox != ["0", "0", "16", "16"]:
            raise ValueError(f"Unexpected source viewBox for {path}: {viewbox}")
        tags = {element.tag.rsplit("}", 1)[-1] for element in root.iter()}
        if tags - {"svg", "path"}:
            raise ValueError(f"Crop/clip/filter-capable source not allowed in experiment: {path}, tags={tags}")
        paths: list[dict[str, str]] = []
        for element in root.iter():
            if element.tag.rsplit("}", 1)[-1] != "path":
                continue
            attrs = dict(element.attrib)
            attrs.pop("fill", None)
            attrs.pop("style", None)
            paths.append(attrs)
        if not paths:
            raise ValueError(f"No path data found in {path}")
        result[name] = paths
    return result


def esc(value: str) -> str:
    return html.escape(value, quote=True)


def draw_instance(item: Instance, icons: dict[str, list[dict[str, str]]]) -> str:
    name, cx, cy, _, _, color_key, slot = item
    color = PALETTE[color_key]
    paths = "".join(
        "<path " + " ".join(f'{esc(key)}="{esc(value)}"' for key, value in attrs.items())
        + f' fill="{color}"/>' for attrs in icons[name]
    )
    return (
        f'<g data-icon="{name}" data-slot="{slot}" data-size="{ICON_DISPLAY_SIZE}" '
        f'transform="translate({cx - ICON_DISPLAY_SIZE / 2:.1f} {cy - ICON_DISPLAY_SIZE / 2:.1f}) '
        f'scale({ICON_SCALE:.4f})">{paths}</g>'
    )


def count_info(items: list[Instance]) -> tuple[int, int, list[str]]:
    kinds = sorted({item[0] for item in items})
    return len(items), len(kinds), kinds


def validate_items(items: list[Instance], label: str) -> None:
    for index, item in enumerate(items):
        if item[3] != 0 or item[4]:
            raise ValueError(f"Rotation/mirroring is forbidden in {label}: {item}")
        for other in items[index + 1:]:
            if abs(item[1] - other[1]) < ICON_DISPLAY_SIZE and abs(item[2] - other[2]) < ICON_DISPLAY_SIZE:
                raise ValueError(f"Overlapping glyph bounds in {label}: {item} / {other}")


def text(x: float, y: float, value: str, size: int = 18,
         color: str = INK, weight: str = "400") -> str:
    return (f'<text x="{x:.1f}" y="{y:.1f}" font-family="Malgun Gothic, Arial, sans-serif" '
            f'font-size="{size}px" font-weight="{weight}" fill="{color}">{esc(value)}</text>')


def panel(x: float, y: float, width: float, height: float,
          fill: str = PANEL, stroke: str = "#d0c2ab") -> str:
    return (f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" '
            f'rx="18" fill="{fill}" stroke="{stroke}" stroke-width="2"/>')


def group_art(items: list[Instance], icons: dict[str, list[dict[str, str]]],
              x: float, y: float) -> str:
    return f'<g transform="translate({x:.1f} {y:.1f})">' + "".join(draw_instance(i, icons) for i in items) + "</g>"


def item_bounds(items: list[Instance]) -> tuple[float, float, float, float]:
    return (
        min(item[1] - ICON_DISPLAY_SIZE / 2 for item in items),
        min(item[2] - ICON_DISPLAY_SIZE / 2 for item in items),
        max(item[1] + ICON_DISPLAY_SIZE / 2 for item in items),
        max(item[2] + ICON_DISPLAY_SIZE / 2 for item in items),
    )


def group_art_fit(items: list[Instance], icons: dict[str, list[dict[str, str]]],
                  center_x: float, top_y: float) -> str:
    min_x, min_y, max_x, _ = item_bounds(items)
    return group_art(items, icons, center_x - (min_x + max_x) / 2, top_y - min_y)


def metadata() -> dict[str, Any]:
    rows: dict[str, Any] = {}
    for key, levels in SAMPLES.items():
        rows[key] = {}
        for level, items in levels.items():
            validate_items(items, f"{key}/{level}")
            count, kinds_count, kinds = count_info(items)
            rows[key][level] = {
                "label": ROW_META[key]["label"],
                "instances": count,
                "unique_icon_kinds": kinds_count,
                "icons": kinds,
                "composition_rule": ROW_META[key]["rule"][level],
                "readable_at_object_scale": ROW_META[key]["scale"][level],
                "risk": ROW_META[key]["risk"][level],
                "display_icon_size_px": ICON_DISPLAY_SIZE,
                "crop_or_mask": False,
                "no_overlap": True,
                "rotation_or_mirror": False,
            }
    return {
        "source": "res://addons/at-icons/node2d/",
        "catalog_source_svg_count": 618,
        "raw_viewbox_px": ICON_SOURCE_SIZE,
        "uniform_display_icon_size_px": ICON_DISPLAY_SIZE,
        "uniform_source_scale": ICON_SCALE,
        "crop_or_mask": False,
        "no_overlap": True,
        "forbidden_transforms": ["rotation", "mirror", "per-instance scaling", "overlap", "crop", "mask"],
        "composition_transforms": ["translation", "palette recolor"],
        "note": "Each glyph is exported at the same 48x48 size in every variant and occupies a separate 56x56 cell. Density changes come from count and object-scale footprint, not output-resolution changes.",
        "samples": rows,
    }


def make_experiment_board(icons: dict[str, list[dict[str, str]]]) -> str:
    width = 2400
    margin, gap, cell_w = 28, 14, 772
    start_y = 178
    row_order = ["large_tree", "neutral_human", "modular_parts", "bomb", "rabbit"]
    row_heights: dict[str, float] = {}
    for subject in row_order:
        _, min_y, _, max_y = item_bounds(SAMPLES[subject]["high"])
        art_height = max_y - min_y
        row_heights[subject] = 78 + art_height + (130 if subject == "modular_parts" else 104)
    height = int(start_y + sum(row_heights.values()) + 10 * (len(row_order) - 1) + 28)
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
             f'<rect width="{width}" height="{height}" fill="{BG}"/>',
             text(34, 60, "AT-ICONS 조합 밀도 실험", 36, INK, "700"),
             text(36, 101, "원본 16×16 glyph를 모두 48×48로 고정 · 조합마다 56×56 셀 사용 · 크롭/마스킹 없음", 20, MUTED),
             text(36, 135, "고조합은 대상마다 100개 · 회전/미러/개별 크기변경/겹침 없음 · 색변형만 허용", 18, MUTED)]
    for col, label in enumerate(["저조합", "중조합", "고조합"]):
        x = margin + col * (cell_w + gap)
        parts.append(text(x + 20, 166, label, 20, INK, "700"))

    level_order = ["low", "medium", "high"]
    y = start_y
    for subject in row_order:
        cell_h = row_heights[subject]
        for col, level in enumerate(level_order):
            x = margin + col * (cell_w + gap)
            items = SAMPLES[subject][level]
            count, kinds_count, _ = count_info(items)
            parts.append(panel(x, y, cell_w, cell_h))
            parts.append(text(x + 20, y + 31, ROW_META[subject]["label"] + " · " + label_level(level), 20, INK, "700"))
            parts.append(text(x + 20, y + 58, f"사용 아이콘 {count}개 · 종류 {kinds_count}종", 16, MUTED, "600"))
            parts.append(group_art_fit(items, icons, x + cell_w / 2, y + 78))
            _, min_y, _, max_y = item_bounds(SAMPLES[subject]["high"])
            artwork_bottom = y + 78 + (max_y - min_y)
            parts.append(text(x + 20, artwork_bottom + 26, "원리  " + ROW_META[subject]["rule"][level], 15, INK))
            parts.append(text(x + 20, artwork_bottom + 54, "읽힘  " + ROW_META[subject]["scale"][level], 15, INK))
            parts.append(text(x + 20, artwork_bottom + 82, "문제  " + ROW_META[subject]["risk"][level], 15, "#9a4d4a"))
            if subject == "modular_parts":
                parts.append(text(x + 20, artwork_bottom + 110, "슬롯  머리 · 얼굴 · 몸통 · 좌/우 팔 · 좌/우 다리 · 상의 · 하의", 14, MUTED))
        y += cell_h + 10
    parts.append("</svg>")
    return "\n".join(parts)


def label_level(level: str) -> str:
    return {"low": "저조합", "medium": "중조합", "high": "고조합"}[level]


def part_option_instances() -> list[Instance]:
    return [
        inst("badge", 0, 0, "gold", "head"),
        inst("glasses", 0, 0, "blue", "face"),
        inst("box", 0, 0, "plum", "torso"),
        inst("feather", 0, 0, "cream", "arm_left"),
        inst("hand", 0, 0, "skin_light", "arm_right"),
        inst("arrow_up", 0, 0, "bark", "leg_left"),
        inst("road", 0, 0, "blue", "leg_right"),
        inst("book_open", 0, 0, "plum_light", "top"),
        inst("door", 0, 0, "cloth_light", "bottom"),
    ]


def make_candidate_board(icons: dict[str, list[dict[str, str]]]) -> str:
    width, height = 2400, 1880
    margin, gap, card_w, card_h = 28, 18, 1155, 540
    cards = [
        ("large_tree", "medium", "큰 나무 후보", "중간 거리 월드 오브젝트", "원통 반복이 목재 기둥처럼 보이고 수관은 단순함"),
        ("neutral_human", "medium", "중립 인체 기본형 후보", "중거리 NPC / Spine 파츠 교체 기준", "얼굴과 팔 glyph의 원래 의미가 남음"),
        ("rabbit", "medium", "토끼 후보", "월드 생물 / 중간 거리", "새깃·발바닥 glyph가 토끼 이외의 뜻으로 튐"),
        ("bomb", "medium", "폭탄 후보", "손에 드는 초점 소품", "껍질 실루엣보다 고리 glyph가 따로 읽힘"),
    ]
    pieces = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
              f'<rect width="{width}" height="{height}" fill="{BG}"/>',
              text(34, 59, "후보 에셋 보드", 36, INK, "700"),
              text(36, 101, "실험에서 조합 규칙이 비교적 읽히는 밀도를 골랐다. 확정 아트나 Kit 적용 승인으로 보지 않는다.", 20, MUTED),
              text(36, 136, "모든 glyph는 48×48 고정 · 56×56 셀 · 겹침/회전/미러/크롭/마스킹 없음 · 후보별 조합 수 표기", 18, MUTED)]
    for idx, (subject, level, title_value, scale_note, risk) in enumerate(cards):
        row, col = divmod(idx, 2)
        x = margin + col * (card_w + gap)
        y = 164 + row * (card_h + gap)
        items = SAMPLES[subject][level]
        count, kind_count, _ = count_info(items)
        pieces.append(panel(x, y, card_w, card_h))
        pieces.append(text(x + 20, y + 34, title_value, 22, INK, "700"))
        pieces.append(text(x + 20, y + 65, f"조립 {count}개 · 종류 {kind_count}종", 17, MUTED, "600"))
        pieces.append(group_art_fit(items, icons, x + 220, y + 100))
        pieces.append(text(x + 400, y + 150, "조합  " + ROW_META[subject]["rule"][level], 17, INK))
        pieces.append(text(x + 400, y + 192, "규모  " + scale_note, 17, INK))
        pieces.append(text(x + 400, y + 236, "한계  " + risk, 16, "#9a4d4a"))
        pieces.append(text(x + 400, y + 284, "source  " + ", ".join(count_info(items)[2]), 13, MUTED))

    # The fifth card is an exploded, labeled kit with detachable layers and alternate pieces.
    x, y = margin, 164 + 2 * (card_h + gap)
    items = SAMPLES["modular_parts"]["medium"]
    count, kind_count, kinds = count_info(items)
    pieces.append(panel(x, y, card_w, card_h))
    pieces.append(text(x + 20, y + 34, "교체식 인체 파츠 후보", 22, INK, "700"))
    pieces.append(text(x + 20, y + 65, f"기본 조립 {count}개 · 종류 {kind_count}종", 17, MUTED, "600"))
    pieces.append(group_art(items, icons, x - 130, y + 95))
    pieces.append(text(x + 390, y + 104, "교체 슬롯 · 대체 아이콘", 16, INK, "700"))
    option_items = part_option_instances()
    option_labels = ["머리", "얼굴", "몸통", "팔 L", "팔 R", "다리 L", "다리 R", "상의", "하의"]
    for option_idx, (option, slot_label) in enumerate(zip(option_items, option_labels)):
        row, col = divmod(option_idx, 3)
        ox, oy = x + 390 + col * 240, y + 116 + row * 82
        option_item = (option[0], ox + 24, oy + 24, option[3], option[4], option[5], option[6])
        pieces.append(draw_instance(option_item, icons))
        pieces.append(text(ox + 54, oy + 30, slot_label + " ← " + option[0], 14, MUTED))
    _, option_kinds, _ = count_info(option_items)
    pieces.append(text(x + 30, y + 420, "레이어  머리 · 얼굴 · 몸통 · 좌/우 팔 · 좌/우 다리 · 상의 · 하의", 16, INK))
    pieces.append(text(x + 30, y + 452, f"대체안  {len(option_items)}개 · 종류 {option_kinds}종 (기본 조립 수와 별도)", 16, INK))
    pieces.append(text(x + 30, y + 484, "한계  실제 관절 분절 없음; pivot은 parts_manifest.json의 근사값", 15, "#9a4d4a"))

    # Method card.
    x, y = margin + card_w + gap, 164 + 2 * (card_h + gap)
    pieces.append(panel(x, y, card_w, card_h))
    pieces.append(text(x + 22, y + 44, "실험에서 고른 규칙", 23, INK, "700"))
    notes = [
        "1. 비교 열마다 glyph는 48×48, 간격은 56×56 셀로 고정.",
        "2. 대상마다 저/중은 작은 조합, 고는 100개 밀도 스트레스.",
        "3. 회전·미러·개별 확대/축소·겹침 없이 위치와 색만 변형.",
        "4. 원본 아이콘 의미가 튀는 지점과 약한 실루엣을 각 카드에 기록.",
        "5. 매칭 대상 아이콘(tree / human / bomb / bunny)은 원본으로 쓰지 않는다.",
        "6. Spine 실제 import·관절 검수 전에는 리그 완료로 보지 않는다.",
    ]
    for line, note in enumerate(notes):
        pieces.append(text(x + 24, y + 96 + line * 52, note, 17, INK))

    pieces.append("</svg>")
    return "\n".join(pieces)


def composition_svg(title: str, items: list[Instance], icons: dict[str, list[dict[str, str]]],
                    fixed_canvas: tuple[int, int] | None = None) -> str:
    if fixed_canvas is None:
        min_x, min_y, max_x, max_y = item_bounds(items)
        width, height = int(max_x - min_x), int(max_y - min_y)
        dx, dy = -min_x, -min_y
        draw = group_art(items, icons, dx, dy)
    else:
        width, height = fixed_canvas
        draw = "".join(draw_instance(item, icons) for item in items)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}"><title>{esc(title)}</title>' + draw + "</svg>")


def write_parts(icons: dict[str, list[dict[str, str]]], parts_dir: Path) -> dict[str, Any]:
    mid = SAMPLES["modular_parts"]["medium"]
    slot_file = {
        "head": "head.svg", "face": "face.svg", "torso": "torso.svg",
        "arm_left": "arm_left.svg", "arm_right": "arm_right.svg",
        "leg_left": "leg_left.svg", "leg_right": "leg_right.svg",
        "top": "top.svg", "bottom": "bottom.svg",
    }
    pivots = {
        "head": [332, 52], "face": [360, 24], "torso": [304, 80],
        "arm_left": [248, 80], "arm_right": [360, 80],
        "leg_left": [248, 192], "leg_right": [360, 192], "top": [304, 136], "bottom": [304, 192],
    }
    manifest: dict[str, Any] = {
        "canvas_px": {"width": 672, "height": 728},
        "display_icon_size_px": ICON_DISPLAY_SIZE,
        "parts": [],
        "note": "Every layer has the same viewBox and placement coordinates, so it can be swapped in place. Pivots are visual estimates for testing, not a validated Spine skeleton.",
    }
    for slot, filename in slot_file.items():
        subset = [item for item in mid if item[6] == slot]
        count, kind_count, kinds = count_info(subset)
        (parts_dir / filename).write_text(
            composition_svg(slot, subset, icons, fixed_canvas=(672, 728)), encoding="utf-8"
        )
        manifest["parts"].append({
            "slot": slot, "file": filename, "pivot_px": pivots[slot],
            "icon_instances": count, "unique_icon_kinds": kind_count, "icons": kinds,
        })
    (parts_dir / "parts_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def render_svg(svg_path: Path, png_path: Path) -> None:
    subprocess.run(["magick", str(svg_path), str(png_path)], check=True, capture_output=True, text=True)


def clear_previous_outputs() -> None:
    direct_files = [
        "large_tree.svg", "character_neutral.svg", "character_variant_02.svg", "bomb.svg", "rabbit.svg",
        "asset_overview.png", "source_manifest.json", "experiment_board.svg", "experiment_board.png",
        "candidate_asset_board.svg", "candidate_asset_board.png", "composition_manifest.json",
    ]
    root_resolved = OUT.resolve()
    for name in direct_files:
        path = OUT / name
        if path.exists() and path.resolve().parent == root_resolved:
            path.unlink()
    for name in ["size_tests", "character_parts", "experiments", "candidate_assets"]:
        path = OUT / name
        if path.exists() and path.resolve().parent == root_resolved:
            shutil.rmtree(path)


def main() -> None:
    clear_previous_outputs()
    OUT.mkdir(parents=True, exist_ok=True)
    icon_names = {item[0] for group in SAMPLES.values() for level in group.values() for item in level}
    icon_names.update(item[0] for item in part_option_instances())
    forbidden = {"tree", "tree_evergreen", "forest", "human", "person_body", "bunny", "bomb"}
    if icon_names & forbidden:
        raise ValueError(f"Matching object pictogram is forbidden: {sorted(icon_names & forbidden)}")
    icons = load_icons(icon_names)

    experiments_dir = OUT / "experiments"
    candidates_dir = OUT / "candidate_assets"
    parts_dir = OUT / "character_parts"
    for path in [experiments_dir, candidates_dir, parts_dir]:
        path.mkdir(parents=True, exist_ok=True)

    manifest = metadata()
    for object_name, levels in SAMPLES.items():
        for level, items in levels.items():
            source = composition_svg(f"{object_name}_{level}", items, icons)
            (experiments_dir / f"{object_name}_{level}.svg").write_text(source, encoding="utf-8")

    selected = {
        "large_tree": ("large_tree", "medium"),
        "neutral_human": ("neutral_human", "medium"),
        "modular_parts": ("modular_parts", "medium"),
        "bomb": ("bomb", "medium"),
        "rabbit": ("rabbit", "medium"),
    }
    candidate_manifest: dict[str, Any] = {}
    for filename, (subject, level) in selected.items():
        items = SAMPLES[subject][level]
        count, kind_count, kinds = count_info(items)
        candidate_manifest[filename] = {
            "source_sample": f"{subject}/{level}", "icon_instances": count,
            "unique_icon_kinds": kind_count, "icons": kinds,
            "composition_rule": ROW_META[subject]["rule"][level],
            "readable_at_object_scale": ROW_META[subject]["scale"][level],
            "risk": ROW_META[subject]["risk"][level],
        }
        (candidates_dir / f"{filename}.svg").write_text(
            composition_svg(filename, items, icons), encoding="utf-8"
        )
    option_count, option_kind_count, option_kinds = count_info(part_option_instances())
    candidate_manifest["modular_parts_swap_options"] = {
        "icon_instances": option_count, "unique_icon_kinds": option_kind_count, "icons": option_kinds,
        "note": "Alternatives displayed separately; excluded from the 14-instance assembled base count.",
    }

    parts_manifest = write_parts(icons, parts_dir)
    manifest["parts_layer_manifest"] = parts_manifest
    manifest["source_icons_used"] = sorted(icon_names)
    manifest["source_icon_kind_count"] = len(icon_names)
    (OUT / "composition_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (OUT / "candidate_manifest.json").write_text(json.dumps(candidate_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    experiment_svg = OUT / "experiment_board.svg"
    candidate_svg = OUT / "candidate_asset_board.svg"
    experiment_svg.write_text(make_experiment_board(icons), encoding="utf-8")
    candidate_svg.write_text(make_candidate_board(icons), encoding="utf-8")
    render_svg(experiment_svg, OUT / "experiment_board.png")
    render_svg(candidate_svg, OUT / "candidate_asset_board.png")
    license_src = ROOT / "addons" / "at-icons" / "LICENSE.txt"
    (OUT / "AT_ICONS_LICENSE.txt").write_text(license_src.read_text(encoding="utf-8"), encoding="utf-8")
    (OUT / "README.md").write_text(readme_text(), encoding="utf-8")


def readme_text() -> str:
    return """# at-icons 조합 실험

이 폴더는 완성 일러스트가 아니라, 원본 SVG 아이콘을 몇 개까지 어떤 배치로 합쳐야 오브젝트 실루엣이 생기는지 비교하는 실험이다. 이미지 A·B는 게임 전체의 공통 아트 방향 참고로만 사용한다. 붓질·질감·색감·실루엣 감각만 가져오며 캐릭터·구도·의상·표정·포즈를 복제하지 않는다. 적용 범위는 [`STYLE_AND_CAMERA_REFERENCE.md`](../../docs/research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md)에 기록돼 있다.

## 결과 보드

- [실험 보드 PNG](experiment_board.png) / [편집 가능한 SVG](experiment_board.svg): 다섯 대상의 저·중·고조합 밀도와 수치·원리·가독 규모·문제점을 나란히 비교한다.
- [후보 에셋 보드 PNG](candidate_asset_board.png) / [편집 가능한 SVG](candidate_asset_board.svg): 각 대상에서 비교적 읽히는 조합을 골랐다. 최종 게임 에셋 승인판은 아니다.

## 실험 규칙

- 비교에 쓰인 at-icons 원본은 `res://addons/at-icons/node2d/`의 618개 SVG다.
- 모든 원본은 16×16 viewBox이고 모든 단계에서 glyph 크기를 48×48로 고정한다. 해상도별 비교는 하지 않는다.
- 아이콘을 자르거나 마스킹하지 않는다. 회전·미러·개별 크기변경·겹침 없이 56×56 셀에 배치하고 색만 변형한다.
- 같은 아이콘을 여러 번 써도 된다. 큰 나무는 중조합에서 원통 6개, 고조합에서 원통 10개를 반복해 기둥을 만든다.
- 저/중/고 조합 수는 큰 나무 8/14/100, 인체 기본형 9/14/100, 교체식 파츠 9/14/100, 폭탄 3/5/100, 토끼 4/7/100이다. 각 고조합은 오브젝트 규모가 커질 때 100개 격자 조합이 어떤 실루엣과 포화 문제를 만드는지 보는 스트레스 샘플이다.
- 대상과 이름이 같은 `tree`, `human`, `person_body`, `bomb`, `bunny` 아이콘은 쓰지 않는다.
- [composition_manifest.json](composition_manifest.json)은 각 실험의 아이콘 인스턴스 수, 고유 종류 수, 조합 원리, 읽히는 오브젝트 규모와 문제를 기록한다.

## 교체식 인체 파츠

중조합 기본형은 머리·얼굴·몸통·좌/우 팔·좌/우 다리·상의·하의의 같은 672×728 viewBox layer로 분리했다. [character_parts](character_parts/)의 9개 SVG는 각 슬롯을 같은 위치에서 바꿔 볼 수 있도록 정렬돼 있다. [parts_manifest.json](character_parts/parts_manifest.json)은 각 layer의 인스턴스 수와 대략적인 pivot을 기록한다. 이는 Spine용 입력 재료 검토 단계이며 실제 Spine 프로젝트, 가중치, 관절 애니메이션 검수는 포함하지 않는다.

## 다시 만들기

저장소 루트에서 `py -3 assets/shared_art_study/build_art_study.py`를 실행한다. SVG 원본 조합과 두 보드의 PNG만 만든다. PNG 보드는 한 번의 고정 크기 렌더이며 여러 해상도 실험물이 아니다. 렌더링에는 ImageMagick의 `magick` 명령을 쓴다.

파생 아트의 at-icons 라이선스는 [AT_ICONS_LICENSE.txt](AT_ICONS_LICENSE.txt)에 보존했다. 각 Kit는 자체 Primary Reference의 카메라·배치·정보 밀도를 따르며, 이 조합 규칙이 모든 Kit의 화면을 통일하지 않는다.
"""


if __name__ == "__main__":
    main()
