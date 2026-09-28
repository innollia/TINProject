# Medieval Cutout Bank v05 — imagegen record

All calls used the built-in `image_gen` tool with `transparent_background=true`. Exact outputs are retained under `assets/art/generic/jobs/medieval-cutout-bank-v05/source_cutouts/`. No CLI/API fallback was used.

## Body part sheet

Input: v02 `source_images/1934-337_print.jpg` (Cleveland Museum of Art CC0, accession 1934.337).

> Use case: background-extraction / precise-object-edit. Asset: one coherent rig-ready cutout sheet for a single game NPC, based on the supplied CC0 St George engraving. Create a transparent PNG contact sheet of exactly these DISCONNECTED body pieces from the same knight, each separated by generous transparent gutters and each fully visible: (1) helmeted head, (2) chainmail neck, (3) armored chest, (4) armored abdomen, (5) fauld/pelvis, (6-7) left and right upper arms, (8-9) left and right forearms WITHOUT hands, (10-11) left and right separate gauntlet hands, (12-13) left and right thighs, (14-15) left and right shins WITHOUT feet, (16-17) left and right separate armored boots/feet. Reconstruct only hidden surfaces needed behind shoulders, elbows, wrists, hips, knees and ankles so the pieces can overlap during animation. Preserve the historical engraved hatch strokes, print grain, armor construction, silhouette, and three-quarter perspective of the input. The result should look like physical paper cutouts from the supplied old print, arranged as an exploded puppet, not one intact figure. Keep original proportions consistent across every piece. No spear, sword, shield, wings, dragon, scenery, labels, numbers, lines connecting parts, shadows, white backdrop, checkerboard, paper rectangles, extra limbs, or duplicated hands. Every separated piece must have true alpha transparency around it.

## Sword and shield sheet

Inputs: v02 `source_images/1934-337_print.jpg` (1934.337) and `source_images/1999-47_print.jpg` (1999.47), both Cleveland Museum of Art CC0.

> Use case: background-extraction / precise-object-edit. Asset: two independent equipable props for the previously designed articulated St George knight NPC. Image 1 is the St George engraver's armored figure and visible sheathed sword hilt; Image 2 is a CC0 early-16th-century woodcut with heraldic shields near its upper left. Make exactly two completely disconnected, full-length paper-cut parts on genuine transparent alpha, with a very wide transparent gutter between them: (A) a straight one-handed knight sword with complete blade, crossguard, grip and pommel, oriented point downward, inspired by the hilt in Image 1; (B) one small medieval heraldic shield with visible rim, front face and an attachment/grip visible on its back edge, drawing from the shield forms in Image 2. Preserve the hatch marks, ink pressure, aged-print texture and slight mismatch between the two historical print sources, so their combination visibly reads as collage. Both props must be unobstructed and individually riggable; no hand attached to either prop. No extra objects, people, arms, fingers, scenery, words, symbols resembling legible text, labels, paper rectangle, white background, checkerboard, glow or cast shadow. Preserve true transparency around and between the props.

## Grape insignia

Input: v02 `parts/fragments/229_2022-99_scrap5.png`, derived from Cleveland Museum of Art CC0 accession 2022.99.

> Use case: background-extraction / precise-object-edit. Asset: one small independently attachable collage insignia for an articulated medieval knight NPC. Isolate the central grapevine motif from the supplied historical gold-ground print fragment: one grape cluster, its vine and two leaves on a small irregularly torn piece of gilded paper. Preserve the exact old print linework, muted worn gold, fiber texture and hand-cut uneven edge. Make the surrounding background genuinely transparent. The motif is a single standalone piece, not a rectangular crop; enough uneven border remains to visibly read as a pasted source fragment when placed on armor. No new illustration style, no knight, no armor, no extra motifs, no labels, no words, no shadow, no white or checkerboard background.

## Derivatives

`scripts/extract_rig_parts.py` separates the transparent sheets by fixed gutters and applies a deterministic alpha ramp to remove soft extraction halos. It does not repaint source pixels. The exact imagegen outputs remain alongside the cropped candidates. `scripts/bake_knight_pilot.py` uses the existing `tools/proc_bake/procbake/rig.py` motion and foot IK to transform the PNG parts into candidate GIFs and frame strips.

## Painted shield variant

Input: v02 `source_images/1964-150-1_print.jpg` (Cleveland Museum of Art CC0, accession 1964.150.1). This was generated after the first GIF review showed too little visible contrast between the cut-and-pasted sources. The earlier engraved shield remains a separate candidate.

> Use case: background-extraction / precise-object-edit. Asset: one separately equipable medieval shield cutout for a visibly collaged game NPC. From the supplied CC0 painted Archangel Michael panel, extract ONLY the large pale faceted kite shield in the lower-right foreground, including its gray-white planes, aged paint crackle, central round red-cross medallion, and sharp bottom tip. Remove the person, the fingers lying on the top edge, sword, frame, ground and all surroundings. Reconstruct just the short stretch of upper rim previously covered by the fingers, matching the original paint. Preserve the original painted texture, proportions, front-facing orientation, and irregular physical cutout edge. Output exactly one complete shield on genuine transparent alpha with generous transparent padding, no hand attached, no writing, no shadow, no white or checkerboard backdrop.
