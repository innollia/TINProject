# Medieval cutout bank v05 — knight candidate

## Review files

- `assets/art/generic/jobs/medieval-cutout-bank-v05/preview/knight_in_landscape_v05.png`: static collage composition against the preserved v04 landscape.
- `assets/art/generic/jobs/medieval-cutout-bank-v05/assemblies/knight_winged_walk.gif`: winged walk loop. The same folder contains `idle`, `look`, and `use`, each in `plain` and `winged` variants.
- Each GIF has a matching `_strip.png` showing all frames and `_rest.png` showing its first pose. The strips are transparent; black in some viewers is only the viewer's background.
- `source_cutouts/`: exact built-in imagegen outputs. `candidates/parts/`, `candidates/equipment/`, and `candidates/ornaments/`: mechanically separated RGBA derivatives. `candidates/parts_manifest_v05.json` records source, pivot, rest joint, and draw order.

## Godot candidate

Open `res://assets/art/generic/jobs/medieval-cutout-bank-v05/demo/knight_npc_demo.tscn` to inspect the independent NPC scene. `knight_npc.tscn` is the reusable node. Its defaults show wings and the painted shield. The exported switches `wings_enabled` and `painted_shield_enabled` select a plain knight or the older engraved shield before the scene starts. `auto_demo` cycles patrol, stop, look, and equipment use. When another scene drives it, disable `auto_demo` and call `set_action("idle" | "walk" | "look" | "use")`, `set_wings_enabled(bool)`, or `interact()`.

The separate Python bake uses `tools/proc_bake` for joint motion and foot IK. The Godot script reconstructs the same joints and action vocabulary for a runtime candidate. Its actual in-engine visuals and contact behavior have **not** been run or verified in this job. The still preview and GIFs prove only the baked candidate art.

## Production status

This pilot is **one assembled knight object candidate** made from 17 anatomy cutouts, separate equipment, and optional wings. Its pieces, two shield appearances, animation frames, and winged/plain appearances do not increase the 300-object count. Runtime behavior remains unverified, so this knight is not yet in the completed-object total. None are user-approved Gold Standards. The strongest open visual question is whether the knight's walk has enough displacement and foot lift at game scale; review the consecutive strip frames and runtime scene before replicating this rig across the bank.
