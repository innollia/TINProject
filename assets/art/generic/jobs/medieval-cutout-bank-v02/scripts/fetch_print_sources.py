"""Fetch CMA print JPEGs for the vetted CC0 source bank."""

from __future__ import annotations

import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "source_images"


def fetch(row: dict) -> tuple[str, str]:
    url = row.get("print_source")
    if not url:
        return row["accession_number"], "no print image"
    name = row["accession_number"].replace(".", "-") + "_print.jpg"
    target = DEST / name
    if target.exists():
        return row["accession_number"], "cached"
    try:
        req = Request(url, headers={"User-Agent": "TINProject-medieval-assets/1.0"})
        with urlopen(req, timeout=120) as response, target.open("wb") as out:
            out.write(response.read())
        return row["accession_number"], f"downloaded {target.stat().st_size} bytes"
    except Exception as exc:
        return row["accession_number"], f"ERROR {type(exc).__name__}: {exc}"


def main() -> None:
    rows = json.loads((ROOT / "sources.json").read_text(encoding="utf-8"))["records"]
    with ThreadPoolExecutor(max_workers=5) as pool:
        futures = [pool.submit(fetch, row) for row in rows]
        for future in as_completed(futures):
            accession, status = future.result()
            print(f"{accession}: {status}", flush=True)


if __name__ == "__main__":
    main()
