"""Reject known structural failures in an Inkscape at-icons candidate SVG."""

from __future__ import annotations

import argparse
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


SVG = "http://www.w3.org/2000/svg"
INKSCAPE = "http://www.inkscape.org/namespaces/inkscape"
DIRECT_MEANING = {
    "tree": {"tree"},
    "bomb": {"bomb"},
    "rabbit": {"rabbit", "bunny"},
    "human": {"human", "person", "person_body"},
}


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def load_svg(path: Path) -> ET.Element:
    return ET.parse(path).getroot()


def rendered_layers(root: ET.Element) -> bytes:
    layers = [
        node
        for node in root.iter()
        if node.tag == f"{{{SVG}}}g"
        and node.get(f"{{{INKSCAPE}}}groupmode") == "layer"
    ]
    return b"".join(ET.tostring(layer, encoding="utf-8") for layer in layers)


def check(target: str, previous: Path, candidate: Path) -> list[str]:
    errors: list[str] = []
    old = load_svg(previous)
    new = load_svg(candidate)

    old_art = rendered_layers(old)
    new_art = rendered_layers(new)
    if not old_art or not new_art:
        errors.append("Cannot compare artwork: an Inkscape layer is missing.")
    elif old_art == new_art:
        errors.append("Candidate artwork is identical to the previous stage.")

    forbidden = DIRECT_MEANING[target]
    embedded = set()
    for node in new.iter():
        if local_name(node.tag) in {"clipPath", "mask", "image"}:
            errors.append(f"Forbidden SVG element: {local_name(node.tag)}")
        if "clip-path" in node.attrib or "mask" in node.attrib:
            errors.append("Clipping or masking attribute found.")
        style = node.get("style", "")
        if "clip-path:" in style or "mask:" in style:
            errors.append("Clipping or masking style found.")
        if local_name(node.tag) == "symbol":
            symbol_id = node.get("id", "")
            if ":at-node2d-" in symbol_id:
                embedded.add(symbol_id.rsplit(":at-node2d-", 1)[-1].replace("-", "_"))

    direct = sorted(embedded & forbidden)
    if direct:
        errors.append(
            "Source symbols with the target's literal meaning remain: "
            + ", ".join(direct)
            + ". Remove unused definitions in Inkscape, then review the artwork."
        )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", choices=sorted(DIRECT_MEANING), required=True)
    parser.add_argument("--previous", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    args = parser.parse_args()
    try:
        errors = check(args.target, args.previous, args.candidate)
    except (OSError, ET.ParseError) as exc:
        print(f"CHECK ERROR: {exc}", file=sys.stderr)
        return 2
    for error in errors:
        print(f"FAIL: {error}")
    if errors:
        return 1
    print("Structural check passed. Inspect silhouette, source meaning, and A/B direction on screen.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
