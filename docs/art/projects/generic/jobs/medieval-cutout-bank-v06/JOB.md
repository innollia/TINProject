# Medieval Cutout Bank v06 — imagegen source expansion

## Scope and status

This pass prioritizes built-in imagegen source creation over new rig/runtime work. Four source artworks from the preserved v02 CC0 collection produced five cutout families: horse, mercenary, dragon, scenery, and equipment. The first mercenary result had attached hands; the second imagegen edit separated them. Both exact masters remain in `source_cutouts/`.

The current output is **56 isolated candidate PNGs**: 14 horse, 17 mercenary, 14 dragon, 6 scenery, and 5 equipment. The user clarified that the target is **300 complete objects**, not cutout PNGs. Horse, mercenary, and dragon each need one complete assembly; scenery and equipment need independent placement or grip anchors and a game-scale review. The 56 files therefore contribute **0 completed objects now**. v05's knight is one assembled candidate, still awaiting runtime review. The corrected rule and starting object register are in v05 `BANK_PLAN.md` and `OBJECT_REGISTER.md`. No Gold Standard promotion occurred.

## Historical inputs

All four scans and their CC0 rights records are preserved in `assets/art/generic/jobs/medieval-cutout-bank-v02/`. No v02–v05 art was replaced.

| Family | Cleveland Museum of Art accession | Source | Output |
| --- | --- | --- | --- |
| Horse | 1965.231 | *Knight, Death, and the Devil* | 14 movable anatomy cutouts |
| Mercenary | 1942.118 | *Mercenaries and a Woman with Death in a Tree* | 17 human cutouts, hands separate |
| Dragon | 1952.99 | *The Archangel Michael Piercing the Dragon* | 14 anatomy, wing, and tail cutouts |
| Scenery | 1929.557 | *Saint Jerome in a Landscape* | tree, tower ruin, bridge, village, rocks, shrub |
| Equipment | 1942.118 and 1965.231 | two mercenaries and a mounted knight | sword, pole spear, hourglass, sheathed sword, armor harness |

## Files and processing

- `assets/art/generic/jobs/medieval-cutout-bank-v06/source_cutouts/`: exact built-in imagegen PNG masters.
- `assets/art/generic/jobs/medieval-cutout-bank-v06/candidates/`: individual RGBA derivatives and `parts_manifest_v06.json`.
- `assets/art/generic/jobs/medieval-cutout-bank-v06/preview/v06_generated_sheets_board.png`: neutral-background review board, mechanically composited from the masters.
- `scripts/extract_imagegen_sheets.py`: connected-region crop with a fixed alpha ramp. It neither repaints nor overwrites any master.
- `PROMPTS.md`: the generation inputs and correction prompt.

The generated sheets have clear separated silhouettes. This pass checked the isolated horse, mercenary hand, and scenery tree on a neutral solid background. It did not assemble or animate these new assets. In particular, horse and dragon gait quality remains unproven, the equipment has no grip pivots yet, and the six scenery pieces have no gameplay interaction labels yet.
