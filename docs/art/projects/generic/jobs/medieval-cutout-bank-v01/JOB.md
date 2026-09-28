# Medieval Cutout Bank v01

Status: **candidate study**. No part, assembly, or visual style in this batch is approved or a Gold Standard.

## Goal

Build a reusable source library from medieval European art, separate useful pieces, and try combinations before deciding which visual directions deserve more production. The first rigging study uses Albrecht Dürer’s *St. George on Foot*; the wing pieces come from Martin Schongauer’s *The Archangel Michael Piercing the Dragon*.

## Contents

- 21 Cleveland Museum of Art works, dated from c. 1350 to 1511, saved as source images under `assets/art/generic/jobs/medieval-cutout-bank-v01/source_images/`.
- Four print-resolution files are included where available. Accession records, image URLs, dimensions, tombstone text, creditlines, and license fields are in `sources.json`.
- Thirteen polygon-masked PNG part candidates: eleven body regions from Dürer’s St. George and two wings from Schongauer’s Archangel Michael.
- One 12-bone rest-pose guide for the full-body figure, plus two tentative wing attachment points.
- Three generated figure assembly variations. They are kept apart from the pixel-preserving cutout parts because image generation can reinterpret source details. The Annunciation angel prompt requested a kneeling source pose, but the output stood upright; that result is labeled as an out-of-brief variation.

## Previews

- `assets/art/generic/jobs/medieval-cutout-bank-v01/preview/source_contact_sheet.png` — all 21 source works.
- `assets/art/generic/jobs/medieval-cutout-bank-v01/preview/parts_contact_sheet_v01.png` — the 13 extracted regions on transparency checkerboards.
- `assets/art/generic/jobs/medieval-cutout-bank-v01/preview/stgeorge_rig_preview_v01.png` — rest-pose bone landmarks over the original print.
- `assets/art/generic/jobs/medieval-cutout-bank-v01/preview/assembly_candidates_contact_sheet_v01.png` — three generated figure variations on transparency checkerboards.
- `assets/art/generic/jobs/medieval-cutout-bank-v01/assemblies/candidate/assemblies_manifest_v01.json` — source links, alpha bounds, and candidate notes for each variation.

## Source and rights record

The museum API records used in this batch report `share_license_status=CC0`. The original accession numbers, museum record links, image URLs, creditlines, and license values are preserved in the asset manifest. The museum’s [Open Access API](https://www.clevelandart.org/open-access-api) describes its CC0 records and image access; the [Open Access page](https://www.clevelandart.org/open-access) describes reuse terms.

## Cutout and rig limits

The PNGs use antialiased polygon masks around hand-selected regions. Pixels inside each mask come from the downloaded source image. The current polygons are coarse: several contain paper, nearby linework, or parts of overlapping objects. The contact sheet is the review evidence for this limitation. Refine masks and joint seams before animating or treating these as clean sprites. The bone guide is a placement draft, not a Godot skeleton or proof of working animation.

Two automatic paper-removal experiments are kept under `parts/paper_matte_v01/` and `parts/paper_matte_v02/` with explicit rejected statuses. The first made no meaningful change; the second removed engraving detail and left noisy edges. Use the polygon-only `parts/<accession>/` images as the current study output, then refine the masks by hand.

The generated assembly is an image-generation interpretation, not a mechanically assembled reconstruction. Do not feed it back as a source part or mark it approved based on this study.

## Reproduction

Run the included scripts with the bundled workspace Python and Pillow:

```powershell
python assets/art/generic/jobs/medieval-cutout-bank-v01/scripts/extract_parts.py
python assets/art/generic/jobs/medieval-cutout-bank-v01/scripts/prepare_rig_and_sources.py
python assets/art/generic/jobs/medieval-cutout-bank-v01/scripts/build_assembly_contact_sheet.py
```

The recipe in `assets/art/generic/jobs/medieval-cutout-bank-v01/recipes/parts_v01.json` stores source-image pixel polygons and anchor points. The cutout manifest records each output’s source accession, source coordinates, dimensions, and candidate status.
