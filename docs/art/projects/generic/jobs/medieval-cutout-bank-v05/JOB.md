# Medieval Cutout Bank v05 — rig-ready knight pilot

## Decision and intended use

The user chose a reusable medieval collage NPC asset bank, starting with one knight. One three-quarter source view is sufficient. The knight patrols, stops, looks toward an interaction target, and visibly uses a separately attached sword and shield. Wings are optional, separately attached parts. The first motion set is idle, grounded walk, look, and equipment use. Preview GIFs and a reusable Godot NPC scene are required; the GIF alone is not game integration.

The image must visibly read as a collage made from different historical prints. Gaps through the body at moving joints, duplicated hands, baked-in weapons, or a single undivided painting fail the pilot. Head, neck, chest, abdomen, pelvis, upper and lower arms, hands, thighs, shins, feet, sword, shield, and wings have distinct semantic IDs and pivots. These are components of the knight; the user-corrected target is **300 complete objects**, so the knight can count at most once when completed.

## Source, rights, and preservation

The first figure source is Albrecht Dürer's *St. George on Foot*, c. 1504–5, Cleveland Museum of Art Open Access accession 1934.337, CC0. Its preserved scan is `assets/art/generic/jobs/medieval-cutout-bank-v02/source_images/1934-337_print.jpg`. The v02 source and extracted files, v03/v04 imagegen masters, and previous GIFs remain untouched. Additional source artwork is drawn from the 54 documented v02 CC0 prints only when the pilot actually needs it.

Built-in imagegen is used to reconstruct hidden joint surfaces and obtain a coherent separated part set. Exact outputs are retained under this job's `source_cutouts/`; cropped RGBA parts go under `candidates/parts/`. Each derivative records its imagegen parent and any original artwork accession. No result is promoted beyond candidate without user review.

## Visual and technical contract

- One three-quarter view based on the St. George print; no new camera direction is required.
- Preserve the recognizable early-16th-century engraving strokes and armor construction. Keep distinct pasted-source boundaries where artwork from another print is used. Never generate a painted studio background into a part.
- Real RGBA transparency, no checkered or white drawn backdrop, text, watermark, paper rectangle, or cast shadow baked into a body part.
- Hidden surface reconstruction must leave enough overlap under parent pieces to prevent transparent holes during bending.
- Semantic parent joint, pivot, draw order, equipment socket, and source record for every accepted part.
- Sword and shield detach from their respective hands. Wings detach from the torso without leaving duplicate wing marks on the body.
- `proc_bake` supplies procedural pose and spring motion; grounded walking must also use planted foot targets, not only independent limb swings.
- Produce idle, walk, look, and equipment-use loops as GIF and transparent frame strips; make the same motions usable by the Godot NPC candidate.

## Review

Inspect the separated parts at original resolution and the assembled knight at its actual display size. Inspect consecutive frames for planted feet, body drag, joint overlap, hand grip, wing removal, and equipment attachment. The NPC candidate is review-ready only after it visibly patrols and reacts in a Godot scene. No candidate is a Gold Standard or approved game art until the user says so.

## Current candidate state

The imagegen runs yielded 17 separated body pieces, an engraved sword and shield, an alternate painted shield, and one decorative gold insignia. The two optional wings reuse the preserved v04 imagegen cutouts. These files form **one assembled knight candidate**, not 22 objects. The older v02 collection's 281 scraps are preserved source material, not 281 completed objects. The corrected counting rule is in `BANK_PLAN.md`; `OBJECT_REGISTER.md` records this knight as an unverified assembly candidate.

The Python bake produces plain and winged idle, walk, look, and equipment-use candidate GIFs. The Godot `knight_npc.tscn` and `demo/knight_npc_demo.tscn` are candidate runtime assets; they do not alter a Kit module. The Godot scene still requires direct visual review before its behavior can be called verified.

The static landscape composite is `preview/knight_in_landscape_v05.png`. Review locations and the runtime scene controls are recorded in `USAGE.md`. The walk strip currently shows a modest step at its intended scale; this is a specific visual point to inspect before copying the rig to other NPCs.

