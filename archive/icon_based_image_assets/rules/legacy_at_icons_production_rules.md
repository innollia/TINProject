# Legacy at-icons image production rules

Status: archived on 2026-09-25 at the user's direction. These rules are preserved as a separate historical record. They no longer define the active image asset basis. Existing image files remain in their original locations and are not modified by this archive.

The detailed historical workflow is preserved in [`../docs/AT_ICONS_INKSCAPE_WORKFLOW.md`](../docs/AT_ICONS_INKSCAPE_WORKFLOW.md). The original study notes, art recipes, and tools are listed in [`../README.md`](../README.md).

## Former shared source rule

- Use `res://addons/at-icons/` as the common world-art material for Kit Reference Games.
- Do not use these assets as UI icons.
- Do not reuse a source pictogram in the same role as its literal meaning, such as a tree pictogram as a tree body or a leaf pictogram as a leaf.
- Build major objects from multiple unrelated source pieces so the resulting silhouette reads as the intended world object rather than as an unchanged source icon.
- Historical workflows used placement, recoloring, rotation, mirroring, scaling, stretching, and overlap. The source SVGs were not to be overwritten.
- The old project instructions and recipes differed on cropping: the general art rule prohibited cutting/cropping/clipping/masking source fragments, while some generated-art experiments described crop operations. This archive preserves both records and does not resolve that old inconsistency into a current rule.
- 2D and 3D use was allowed through genre-appropriate Sprite2D, Sprite3D, plane, or cutout compositions.

## Former Inkscape workflow

- Use the local Inkscape editor through the `@oai/sky` computer-use connection.
- The symbol collection was built from 618 `node2d` SVG sources. Choose pieces from the full Symbols panel while shaping the object; do not preselect a target-specific pool or place every candidate on the canvas at once.
- Add a few pieces at a time, inspect the actual editor view after each structural step, and replace a piece if its original pictogram meaning reads as the target.
- Save meaningful stages separately as `01_structure`, `02_mass`, `03_features`, and only then `candidate` when the target silhouette is readable and the original pictogram meaning is not dominant.
- A structural checker could reject unchanged art, direct-meaning source symbols, clipping, masking, and raster embedding. Passing that check was never visual approval; the actual editor view still needed review.
- Keep character parts such as head, face, torso, limbs, and clothing as replaceable groups in the character experiments.

## Former Kit-specific recipes

- **Rule Rewrite:** combine at least two unrelated pieces for world objects, transform them to make distinct silhouettes, use the same physical object identity in 2D/3D/inventory previews, keep word tiles as their own typography, and do not use original source icons as UI slot icons.
- **Odd Road Adventure:** treat at-icons as required world-art material for characters, buildings, furniture, machinery, plants, and props; do not use a source pictogram unchanged.
- **Deduction Casework:** use multi-piece collages for locations, documents, people, evidence, and case markers; record recipes so authored content could reproduce them; avoid source pictograms as clickable world objects.

The former Deduction Casework recipe table specified these example sources and targets:

| Target | Former source pieces | Former treatment and readability goal |
|---|---|---|
| Investigation location/interior | `res://addons/at-icons/mesh/institutional_building.svg`, `door.svg`, `chair.svg`, `map.svg` | Crop, overlap, non-uniform scale, and recolor into a multi-plane investigable space |
| Documents/letters/records | `res://addons/at-icons/mesh/file_document.svg`, `book_open.svg`, `mobile_phone.svg` | Rotation, crop, and frame overlap to distinguish detailed clues from a stack of paper |
| People/identity silhouettes | `res://addons/at-icons/mesh/person_body.svg`, `briefcase.svg`, `film_camera.svg` | Separate assembly, mirror, and partial crop for people in the case rather than portraits |
| Objects/tools/evidence | `res://addons/at-icons/mesh/key.svg`, `clock.svg`, `car.svg`, `footsteps.svg` | Directional rotation, overlap, and recolor for small world objects read as hotspots |
| Case marker/board | `res://addons/at-icons/mesh/map.svg`, `book_open.svg`, `briefcase.svg`, `file_document.svg` | Layered collage for a clickable investigation board |

The former plan called for at least two source pieces per major object and authored recipes that content authors could reproduce. Another old Rule Rewrite plan specified crop, rotation, mirroring, overlap, non-uniform scale, recolor, consistent object identity across 2D/3D/inventory previews, and a reduced render of the world object for inventory preview. These are archived requirements only.

These are preserved records of the former basis. They must not be used as requirements for the replacement image asset system.
