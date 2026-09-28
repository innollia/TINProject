# Imagegen prompts — v01

All cutout edit jobs use the corresponding source scan as the only input image and request true transparency. The background edit uses the second source scan. The collage uses the listed candidate inputs only. All outputs are candidates.

## Archangel body cutout

```text
Use case: background-extraction. Asset type: articulated historical 2D paper-collage figure.
Input Image 1 is the edit target, the Cleveland Museum engraving The Archangel Michael Piercing the Dragon (accession 1952.99).
Extract only the central Archangel Michael figure from the top of the head to the visible feet, excluding both large feathered wings and excluding the dragon/devil beneath him. Preserve his original pose, face, hair, robe, hands, armor details, and only the visible portions of the weapon held in his hands. Keep the engraving linework, shading, paper texture within the silhouette, and the exact source contours. At the shoulder overlaps, end the figure cleanly where the wings cover it; do not reconstruct hidden body or arm sections. Remove the print background and provide genuine transparency. Do not add, repair, recolor, or invent any anatomy, props, letters, or scenery.
```

## Archangel left wing cutout

```text
Use case: background-extraction. Asset type: independent riggable medieval paper-cut wing.
Input Image 1 is the edit target, the Cleveland Museum engraving The Archangel Michael Piercing the Dragon (accession 1952.99).
Extract only the large feathered wing on the viewer's left side of Archangel Michael. Include the complete visible outer contour and visible feather groups. Cut exactly along the places where the wing disappears behind the figure or other source forms; do not invent hidden wing roots or feathers. Preserve the original engraving marks, proportions, paper texture, and silhouette. Remove everything else and provide genuine transparency. No added marks, lettering, or background.
```

## Archangel right wing cutout

```text
Use case: background-extraction. Asset type: independent riggable medieval paper-cut wing.
Input Image 1 is the edit target, the Cleveland Museum engraving The Archangel Michael Piercing the Dragon (accession 1952.99).
Extract only the large feathered wing on the viewer's right side of Archangel Michael. Include the complete visible outer contour and visible feather groups. Cut exactly along the places where the wing disappears behind the figure or other source forms; do not invent hidden wing roots or feathers. Preserve the original engraving marks, proportions, paper texture, and silhouette. Remove everything else and provide genuine transparency. No added marks, lettering, or background.
```

## Scenery-only landscape background

```text
Use case: precise-object-edit. Asset type: wide medieval engraving environment background for a paper collage.
Input Image 1 is the edit target, the Cleveland Museum engraving Saint Jerome in Penitence (accession 1949.33).
Keep the full original landscape, river, rocks, plants, hills, distant buildings, and aged engraving texture. Remove the foreground human figures and the small distant people only, then continue nearby ground, water, rocks, and linework through the cleared regions in the same source style. Preserve the original canvas and tonal range. Do not add new focal objects, people, animals, lettering, or a new background. Deliver an opaque full-canvas environment image.
```

## Patchwork collage assembly

```text
Use case: compositing. Asset type: visibly cut-and-pasted medieval collage candidate.
Input Image 1 is the scenery-only Saint Jerome landscape candidate. Input Image 2 is the full Archangel Michael figure cutout candidate with its source wings still attached. Input Image 3 is the preserved v03 dragon cutout. Input Image 4 is the preserved v03 banner-and-pole cutout.
Keep the landscape full-canvas. Place the full winged angel left of center, the banner leaning at the far left, and the dragon large across the lower right foreground, overlapping the landscape. Make the different print textures, paper tones, scales, irregular pale cut edges, and overlaps plainly visible so the result reads as a collage assembled from different prints, not a restored single painting. Do not blend, repaint, harmonize, or add any other subject or writing.
```
