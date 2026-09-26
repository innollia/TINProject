"""mp05 addition: one review sheet with every enemy (rows) x combat state (columns).

    py -3 -B state_grid.py --scale 0.5 --out ../preview/sheet_enemy_states_0.5x.png
    py -3 -B state_grid.py --scale 1 --out ../preview/sheet_enemy_states_1x.png

Columns: baseline, telegraph, signature, break | exposure, phase1_*, phase2_*.
Each sprite is placed with its pivot (body centre) on the cell centre, the same way
the game centres an enemy on its stage position, with its _shadow.png under it.
The words on the sheet are review captions only; the assets themselves carry no text.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

JOB = Path(__file__).resolve().parents[1]
ORDER = [
    ("enemy_kiln_door_ward", "Kiln Door Ward"),
    ("enemy_latency_bell_ringer", "Latency Bell Ringer"),
    ("enemy_mana_triage_surrogate", "Mana Triage Surrogate"),
    ("enemy_organ_quorum_witness", "Organ Quorum Witness"),
    ("enemy_permit_inspector", "Permit Inspector"),
    ("enemy_residue_cantor", "Residue Cantor"),
    ("enemy_seam_arbiter", "Seam Arbiter"),
    ("enemy_worksheet_instructor", "Worksheet Instructor"),
    ("enemy_wrong_return_scribe", "Wrong-Return Scribe"),
]
COLUMNS = [
    ("baseline", "기본"),
    ("telegraph", "기술 예고"),
    ("signature", "대표 기술"),
    (("break", "exposure"), "무너짐 / 드러남"),
    ("phase1_", "단계 1"),
    ("phase2_", "단계 2"),
]


def font(size: int):
    for name in ("malgun.ttf", "arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def find(folder: Path, key) -> Path | None:
    keys = key if isinstance(key, tuple) else (key,)
    for k in keys:
        if k.endswith("_"):
            hits = [h for h in sorted(folder.glob(k + "*.png")) if not h.stem.endswith(("_shadow", "_emit"))]
            if hits:
                return hits[0]
        elif (folder / f"{k}.png").exists():
            return folder / f"{k}.png"
    return None


def caption(path: Path) -> str:
    stem = path.stem
    if stem.startswith("phase"):
        return " ".join(w.capitalize() for w in stem.split("_")[1:])
    if stem == "exposure":
        return "드러남 (깨지지 않음)"
    return ""


def pivot(path: Path, image: Image.Image) -> list:
    man = path.with_suffix(".json")
    if man.exists():
        data = json.loads(man.read_text(encoding="utf-8"))
        if data.get("pivot"):
            return data["pivot"]
    return [image.width / 2.0, image.height / 2.0]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scale", type=float, default=0.5)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--bg", default="#57505c")
    args = ap.parse_args()
    s = args.scale
    rows = [(label, [find(JOB / "output" / enemy, key) for key, _ in COLUMNS]) for enemy, label in ORDER]
    sizes = [Image.open(p).size for _, cells in rows for p in cells if p]
    cw = int(max(w for w, _ in sizes) * s) + 16
    ch = int(max(h for _, h in sizes) * s) + 8
    k = max(s, 0.5) / 0.5
    f_head, f_row, f_cap = font(int(18 * k)), font(int(16 * k)), font(int(12 * k))
    label_w, head_h, cap_h, gap = int(190 * k), int(40 * k), int(20 * k), 12
    width = label_w + len(COLUMNS) * cw + gap
    height = head_h + len(rows) * (ch + cap_h) + gap
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    text, dim, rule = "#ddd4e2", "#a79eb0", "#4a4450"
    for c, (_, title) in enumerate(COLUMNS):
        x = label_w + c * cw + cw // 2
        draw.text((x, head_h // 2), title, fill=text, font=f_head, anchor="mm")
    for r, (label, cells) in enumerate(rows):
        y0 = head_h + r * (ch + cap_h)
        if r:
            draw.line([(gap, y0 - 1), (width - gap, y0 - 1)], fill=rule, width=2)
        draw.text((gap, y0 + ch // 2), label, fill=text, font=f_row, anchor="lm")
        for c, path in enumerate(cells):
            x0 = label_w + c * cw
            cx, cy = x0 + cw / 2.0, y0 + ch / 2.0
            if path is None:
                draw.text((cx, cy), "—", fill=dim, font=f_row, anchor="mm")
                continue
            im = Image.open(path).convert("RGBA")
            px, py = pivot(path, im)
            size = (max(1, round(im.width * s)), max(1, round(im.height * s)))
            pos = (round(cx - px * s), round(cy - py * s))
            shadow = path.with_name(path.stem + "_shadow.png")
            if shadow.exists():
                sheet.alpha_composite(Image.open(shadow).convert("RGBA").resize(size, Image.Resampling.LANCZOS), pos)
            sheet.alpha_composite(im.resize(size, Image.Resampling.LANCZOS), pos)
            note = caption(path)
            if note:
                draw.text((cx, y0 + ch + cap_h // 2 - 2), note, fill=dim, font=f_cap, anchor="mm")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
