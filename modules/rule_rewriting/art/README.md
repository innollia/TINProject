# Rule Rewrite world art

Transparent 128×128 SVGs. Entity `kind` maps directly to lowercase file name (`MOTH` → `moth.svg`). Render these as the **physical object** in the board, as Sprite2D or Sprite3D cutout/plane. Keep the same SVG for the 3D view and inventory preview so one entity keeps its identity. Word tiles keep their own typography and should not use these files.

The 28 physical noun kinds in the 14 Reference Game boards all have matching assets: BASIN, BEACON, BELL, BOX, CORE, DOOR, EMBER, FLAG, GATE, GLASS, INK, KEY, LAMP, LANTERN, LARK, LAVA, MOTH, PAD, PANEL, PEARL, POOL, ROCK, RUNE, STAR, TOKEN, TURNER, VINE, WALL. Additional art aliases are BABA, PLAYER, and METRIX. `player.svg` intentionally matches `baba.svg` because PLAYER is a fallback representation of the same physical protagonist. `metrix.svg` is a **preview only** for a derived aggregate; on the board the physical BOX/DOOR boundary remains visible.

The shapes use multiple transformed path fragments from `res://addons/at-icons/control/` (MIT; see its LICENSE.txt): wing, wave, spiral, triangle, aperture, and others. Fragments are cropped, mirrored, stretched, recolored, and embedded as paths in each file so Godot imports the SVGs without external file links. The script `build_art.py` is the source recipe; run it from any working directory. It does not modify the original at-icons assets.

`contact_sheet_720p.svg` is a 1280×720 inventory of the artwork on a dark field. It is an art review sheet, not a gameplay screenshot. Board integration and actual three resolution visual QA remain separate work.

Raster exports are supplied beside each SVG for predictable Godot import, and `contact_sheet_720p.png` is the actual 1280×720 review image. `cell_scale_preview.png` compares all forms at 48 px inside 94 px cells (a small-cell proxy, not a captured game frame). Regenerate PNGs with `python render_preview.py` after changing SVGs; this script needs Pillow and ImageMagick.

Art QA at cell scale: MOTH has broad two-lobe wings and dark body; ROCK has an irregular faceted mass; BOX reads as a shallow crate; DOOR has a dark open center; KEY has a toothed diagonal stem; GATE is a barred opening. LARK's beak and angular body distinguish it from MOTH; WALL uses a broken horizontal brick silhouette; FLAG is a pennant, VINE a curling stem, GLASS a transparent pane, and LAVA a flame pool. BABA and PLAYER intentionally share one character silhouette. Original at-icons pictograms are not presented as standalone world objects. Actual in-game 2D and 3D screenshots are still needed after integration.
