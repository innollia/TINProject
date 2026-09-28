# Imagegen prompts — v01

These are the prompts passed to the built-in `image_gen` tool. For the first
three, `transparent_background` was `true`; for the landscape and assembly it
was `false`.

## Person cutout

```text
Use case: background-extraction. Asset type: standalone historical 2D collage figure.
Input Image 1 is the edit target, a Cleveland Museum print of St. John the Baptist.
Extract the single centered standing figure from hair to sandals, including the robe and both visible hands. Remove the landscape, printed margin, lettering, and signature; output genuine transparency.
Keep the original pose, proportions, monochrome engraving lines, shading, and paper texture that belongs inside the figure silhouette. Preserve the complete figure without cropping.
Do not add, repair, or invent hidden body details; do not add a halo, props, other figures, lettering, or a new background.
```

## Animal cutout

```text
Use case: background-extraction. Asset type: standalone medieval animal cutout for a paper collage.
Input Image 1 is the edit target, the Cleveland Museum engraving Saint George Slaying the Dragon.
Extract the large winged dragon directly beneath the central armored saint as a separate animal cutout. Include its full visible head, wings, body, limbs, and tail; exclude every human, weapon, and neighboring creature. Remove the print background and provide genuine transparency.
Preserve the source engraving's visible creature design, proportions, linework, monochrome shading, and print texture inside the dragon's silhouette. Keep an honest edge where the source hides the dragon behind the saint or other forms; do not invent occluded anatomy. Do not add text, scenery, or other subjects.
```

## Object cutout

```text
Use case: background-extraction. Asset type: independent medieval collage prop.
Input Image 1 is the edit target, the Cleveland Museum print St. George on Foot.
Extract only the tall banner and the visible length of its pole at the left side of the picture. Exclude the knight's hand, arm, body, armor, sword, and all scenery. Cut cleanly at the exact places where the pole or cloth disappears behind the hand or figure; do not invent hidden sections. Remove the print background and provide genuine transparency.
Keep the banner's visible silhouette, folds, monochrome engraving lines, shading, and paper texture inside the banner. No lettering, added ornament, or new background.
```

## Background edit

```text
Use case: precise-object-edit. Asset type: wide medieval environment background.
Input Image 1 is the edit target, the Cleveland Museum drawing Saint Jerome in a Landscape.
Keep the full original landscape composition and aged drawing texture. Remove only the small foreground human figure(s), then continue the ground, plants, and drawing lines naturally through the cleared area. Retain the trees, distant settlement, hills, and original tonal range.
Do not add people, animals, lettering, or new focal objects. Deliver an opaque full-canvas landscape background, not a transparent cutout.
```

## Assembly

```text
Use case: compositing. Asset type: medieval collage scene candidate.
Input Image 1 is the full-canvas landscape background. Input Image 2 is the transparent St. John figure cutout. Input Image 3 is the transparent dragon cutout. Input Image 4 is the transparent banner-and-pole object cutout.
Compose these four supplied assets into one unmistakable pasted-paper montage. Keep the figure standing left of center, the banner leaning beside him, and the dragon large in the foreground to the right, overlapping the lower landscape.
Retain each source's different engraving texture, scale, paper tone, and edge; make seams and irregular pale paper borders plainly visible. Do not blend, repaint, or harmonize the four images into one continuous illustration. Do not add other figures, animals, objects, writing, or a new focal subject. Keep the landscape full-canvas and deliver an opaque scene.
```
