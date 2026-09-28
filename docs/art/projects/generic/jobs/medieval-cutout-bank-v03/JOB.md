# Medieval Cutout Bank v03

## Goal

Extend the preserved v02 collage bank with imagegen-edited medieval cutouts
covering one person, one animal, one independent object, and one environment.
Every imagegen cutout master is retained unchanged; composition candidates are
stored separately. The v02 sources, parts, rigs, and assemblies are not edited.

## Source and rights

Four unchanged Cleveland Museum of Art CC0 print scans are copied into
`assets/art/generic/jobs/medieval-cutout-bank-v03/source_images/`:

- `1934-247_print.jpg` — St. John the Baptist (full standing figure).
- `1999-47_print.jpg` — Saint George Slaying the Dragon (animal).
- `1934-337_print.jpg` — St. George on Foot (banner and pole object).
- `1929-557_print.jpg` — Saint Jerome in a Landscape (environment).

The original CMA records and credit lines remain in the v02 `sources.json`;
this job's `source_manifest.json` links each asset to its accession and source.

## Outputs

- Transparent subject PNG masters go in
  `assets/art/generic/jobs/medieval-cutout-bank-v03/source_cutouts/` exactly as
  returned by built-in imagegen, before any further processing.
- The exact opaque imagegen background master is in `source_backgrounds/`.
- Working copies go in
  `assets/art/generic/jobs/medieval-cutout-bank-v03/candidates/cutouts/` and
  `assets/art/generic/jobs/medieval-cutout-bank-v03/candidates/backgrounds/`.
- The four-source imagegen assembly is in
  `assets/art/generic/jobs/medieval-cutout-bank-v03/assemblies/`.
- Each output begins as a candidate; none is approved or promoted.

## Imagegen execution

Use the built-in imagegen editing path. Attach the local source scan as the edit
target, inspect it first, request genuine alpha for person/animal/object assets,
and save the exact output prompt and result path in `source_manifest.json`.
Preserve the source scans and the untouched imagegen cutout masters.

## Visual gate

- Person is a complete standing figure with visible source engraving retained.
- Animal reads as a distinct animal cutout, with no surrounding figure.
- Object is separated from the figure holding it and retains its printed edges.
- Background is a usable scenery-only image without a focal person.
- Actual transparent alpha is present on subject cutouts.
- Pieces in a collage remain visibly cut and pasted; do not blend into one
  coherent painting.

## Prompt set

See `PROMPTS_v01.md` for all four edit prompts and the assembly prompt passed
to imagegen.

## Review

`assets/art/generic/jobs/medieval-cutout-bank-v03/preview/imagegen_cutouts_review_v01.jpg`
is a non-destructive visual sheet showing the three transparent masters over a
checkerboard, the full background, and the assembly.
`scripts/make_review_sheet.py` recreates it.
