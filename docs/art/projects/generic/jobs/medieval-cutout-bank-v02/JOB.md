# Medieval Cutout Bank v02

## Goal

Build a source-pixel collage bank for assembling medieval figures and other
paper-cut compositions. A finished test piece must read as joined fragments from
different artworks. If it reads as one intact painting, it fails this brief.

## Source and rights

- Source: Cleveland Museum of Art Open Access API and image CDN.
- Every selected record is checked for `share_license_status: CC0` and a latest
  creation date no later than 1600.
- `assets/art/generic/jobs/medieval-cutout-bank-v02/sources.json` records the
  museum accession, title, artist, date, credit line, source page, API image
  URLs, and web/print dimensions.
- Original downloaded JPEGs are kept unchanged in `source_images/`.

## Part bank

- Target count: 300 separately addressable PNGs.
- Figure cuts: 17 articulated human pieces, plus two source-derived wings.
- Additional source scraps: 281 irregular high-detail windows cut from the 54
  collected artworks.
- Pixels inside each cut mask come from the corresponding CMA image. The print
  paper and plate backgrounds remain visible so the sources stay visibly
  separate in a collage.
- `parts/parts_manifest_v02.json` records each cut polygon, source dimensions,
  source file, pivot, output size, and license provenance.
- The manifest is the exact 300-part bank. Two unindexed Sebastian foot PNGs
  are also present in the folder and are excluded from the count and assemblies.
- The 281 scraps are unreviewed source fragments; they are not semantic claims
  that an image crop is a hand, limb, or other specific anatomy.

## Animation

`scripts/bake_collage_assemblies.py` imports `Rig` and `motion_targets` from
`tools/proc_bake/procbake/rig.py`. Its rig drives the raster source cuts; the
tool's vector silhouette renderer is not used for visible output.

Three review builds are baked as candidates:

- `winged_patchwork_knight_walk.gif` — 23 linked image pieces, one-second loop.
- `gilded_saint_cutout_idle.gif` — 23 linked image pieces, two-second loop.
- `torn_reliquary_messenger_alert.gif` — 24 linked image pieces, 1.5-second loop.
- `assemblies_contact_sheet_v02.jpg` shows a still from each build. Each build
  also has a frame strip and a machine-readable proc_bake rig report.

Animation uses 20 frames per second so the GIF frame duration exactly matches
the sampled loop period. The distinct source-print edges remain visible across
all animated frames. These are assembly studies, not approved game assets.

## Review and status

- All outputs begin as `candidate` and remain unapproved until the user reviews
  the actual cutouts and assembled motion.
- Review `preview/parts/catalog_*.jpg` before selecting scraps.
- Review each animated assembly against the collage gate above. Reject a pose
  that reads as a single restored artwork.
- No cutout or assembly in this job is promoted to a Gold Standard.

## Repeatable scripts

1. `scripts/collect_cma_sources.py`
2. `scripts/fetch_print_sources.py`
3. `scripts/extract_parts_v02.py`
4. `scripts/bake_collage_assemblies.py`
5. `scripts/make_assembly_review.py`
