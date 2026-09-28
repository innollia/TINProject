"""Collect CC0 medieval CMA image candidates and build a contact sheet.

The script stores original CMA web JPEGs unchanged. Full-resolution print files
are fetched separately only for selected works used in cutouts.
"""

from __future__ import annotations

import json
import time
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "source_images"
API = "https://openaccess-api.clevelandart.org/api/artworks/"
ACCESSIONS = [
    # Figurative medieval/early Renaissance works selected from CMA Open Access.
    "1958.411", "1932.227", "1956.719", "1949.33", "1934.247",
    "1964.150", "2022.99", "1929.557", "1951.354", "1937.577",
    "1959.99.3", "1962.257.1", "1968.20", "1973.215", "1947.483",
    "2025.186", "1948.457", "2015.20", "1925.1000", "1986.9",
    "1949.7", "1928.748", "1965.307", "1942.633.1", "1939.669",
    "1928.635", "1942.633", "1922.88", "1942.118", "1965.231",
    "1964.99", "1927.305", "1979.80", "1963.500", "1952.110",
    "1962.257", "1948.170", "1985.8", "1916.788", "1916.813",
]


def request_json(url: str) -> dict:
    req = Request(url, headers={"User-Agent": "TINProject-medieval-assets/1.0"})
    with urlopen(req, timeout=45) as response:
        return json.load(response)


def safe_name(accession: str) -> str:
    return accession.replace(".", "-")


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)
    prior = json.loads((ROOT.parent / "medieval-cutout-bank-v01" / "sources.json").read_text(encoding="utf-8"))
    accessions = list(dict.fromkeys([item["accession_number"] for item in prior] + ACCESSIONS))
    records = []
    for accession in accessions:
        url = API + "?" + urlencode({"accession_number": accession})
        record = request_json(url)["data"][0]
        if record.get("share_license_status") != "CC0":
            print(f"SKIP non-CC0 {accession} {record.get('title')}")
            continue
        if int(record.get("creation_date_latest") or 9999) > 1600:
            print(f"SKIP post-1600 {accession} {record.get('title')}")
            continue
        images = record.get("images") or {}
        web = images.get("web") or {}
        print_image = images.get("print") or {}
        if not web.get("url"):
            print(f"SKIP no web image {accession} {record.get('title')}")
            continue
        file_name = safe_name(accession) + "_web.jpg"
        target = DEST / file_name
        if not target.exists():
            req = Request(web["url"], headers={"User-Agent": "TINProject-medieval-assets/1.0"})
            with urlopen(req, timeout=90) as response, target.open("wb") as out:
                out.write(response.read())
        creators = record.get("creators") or []
        artist = next((c.get("description") or c.get("creator_description") for c in creators
                       if c.get("role") == "artist"), "Unknown")
        records.append({
            "museum": "Cleveland Museum of Art",
            "accession_number": accession,
            "title": record.get("title"),
            "artist": artist,
            "date": record.get("creation_date"),
            "date_earliest": record.get("creation_date_earliest"),
            "date_latest": record.get("creation_date_latest"),
            "type": record.get("type"),
            "technique": record.get("technique"),
            "culture": record.get("culture"),
            "image_file": file_name,
            "image_source": web["url"],
            "web_dimensions": [int(web.get("width") or 0), int(web.get("height") or 0)],
            "print_source": print_image.get("url"),
            "print_dimensions": [int(print_image.get("width") or 0), int(print_image.get("height") or 0)],
            "source_page": record.get("url"),
            "license": record.get("share_license_status"),
            "creditline": record.get("creditline"),
            "tombstone": record.get("tombstone"),
        })
        time.sleep(0.06)

    records.sort(key=lambda row: (int(row["date_earliest"] or 9999), row["accession_number"]))
    (ROOT / "sources.json").write_text(json.dumps({
        "batch": "medieval-cutout-bank-v02",
        "source_policy": "Cleveland Museum of Art Open Access; CC0 image assets only; artworks dated no later than 1600",
        "source_api": "https://openaccess-api.clevelandart.org/api/artworks/",
        "records": records,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    cols, cell_w, cell_h = 5, 260, 275
    rows = (len(records) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell_w, rows * cell_h), "#222222")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("arial.ttf", 13)
    except OSError:
        font = ImageFont.load_default()
    for i, row in enumerate(records):
        im = Image.open(DEST / row["image_file"]).convert("RGB")
        im.thumbnail((cell_w - 12, cell_h - 58), Image.Resampling.LANCZOS)
        x, y = (i % cols) * cell_w, (i // cols) * cell_h
        sheet.paste(im, (x + (cell_w - im.width) // 2, y + 4))
        label = f"{row['accession_number']} | {row['date']}\n{row['title'][:35]}"
        draw.multiline_text((x + 6, y + cell_h - 50), label, fill="white", font=font, spacing=2)
    preview = ROOT / "preview" / "source_contact_sheet_v02.jpg"
    preview.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(preview, quality=90)
    print(f"sources={len(records)}")
    print(f"manifest={ROOT / 'sources.json'}")
    print(f"contact_sheet={preview}")


if __name__ == "__main__":
    main()
