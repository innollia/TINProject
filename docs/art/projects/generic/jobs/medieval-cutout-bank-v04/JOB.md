# Medieval Cutout Bank v04

## Goal
Extend v02 and v03 without changing them. Produce a full Archangel Michael figure cutout, two separately extracted wing pieces for alternate rigging, a scenery-only background from a second print, and a visible paper-collage assembly using the full angel, preserved v03 dragon, and banner candidates.

## Sources and rights
Both unchanged source scans come from the v02 Cleveland Museum of Art Open Access collection. Their records, credit lines, source pages, and CC0 status are in `../medieval-cutout-bank-v02/sources.json`:
- `1952-99_print.jpg` — Martin Schongauer, *The Archangel Michael Piercing the Dragon*, c. 1475, accession 1952.99.
- `1949-33_print.jpg` — *Saint Jerome in Penitence*, c. 1480–1500, accession 1949.33.

Copied source scans are retained in `source_images/`. The v02 and v03 source, cutout, and assembly files remain untouched.

## Outputs and status
- Exact built-in imagegen transparent outputs are retained in `source_cutouts/`.
- Exact opaque background output is retained in `source_backgrounds/`.
- Working candidates go in `candidates/` and never overwrite the imagegen masters.
- The collage candidate goes in `assemblies/`.
- Every output starts as `candidate`; none is approved or promoted.

## Intended use
The Archangel figure and wings are a paper-cut assembly study. The body extraction retained visible wing surfaces despite the prompt; use it as a full winged-figure candidate. The two independent wings remain separate alternate rigging parts, and should not be stacked over that full figure unless the duplicate overlap is intentional. No hidden anatomy or wing sections are to be invented.

## Review gates
- Each cutout is PNG with genuine alpha, retaining the source engraving within the silhouette.
- The background contains scenery only; no foreground people remain.
- In the collage, paper edges, scale differences, and source-print differences stay visible. It must read as cut-and-pasted.
- Preserve all exact imagegen masters, source scans, prompt text, and source/license metadata.

