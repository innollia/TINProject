# Procedural Visual System — integration contract

Owner: **W2**. Public signatures in this folder are **frozen**. Three Kits code
against them in parallel, so names, argument order, argument names and return
types do not change without W0 approval. See `CONTRACT.md` for the signature
reference.

No image file exists anywhere in TIN. Every pixel is produced at runtime by the
classes in this folder.

## What each file provides

| File | Class | Provides | State |
|---|---|---|---|
| `procedural.gd` | `Procedural` | Top level entry. Every generator is reached from one seed. | done for seeds, noise, palette, canvas. Dict factories are stubs. |
| `seed.gd` | `ProceduralSeed` | Deterministic `(world_seed, id, version)` digest and draws from it. | done |
| `noise_field.gd` | `ProceduralNoiseField` | `FastNoiseLite` wrapper with the four frozen named field presets. | done |
| `raster/canvas.gd` | `ProceduralCanvas` | RGBA8 pixel buffer: fill, line, polygon, circle, ellipse, blur, posterize, blit. | done |
| `raster/sdf.gd` | `ProceduralSdf` | Signed distance primitives, soft booleans, field rasterisation. | done |
| `palette/palette.gd` | `ProceduralPalette` | Colour **roles** mapped to colours. No literal RGB anywhere. | done |
| `palette/scheme_builder.gd` | `ProceduralPaletteScheme` | Derives a harmonious palette for every role from one seed. | done |
| `anim/spring.gd` | `ProceduralSpring`, `ProceduralSpring.Spring2D` | Damped spring integration, critically damped and under damped. | done |
| `anim/deform_field.gd` | `ProceduralDeformField` | Grid of per vertex springs pulled by noise. The 말랑말랑 core. | done |
| `anim/backdrop_dynamics.gd` | `ProceduralBackdropDynamics` | Camera lag, wind and noise motion for backdrop elements. | done |
| `sprite/body_part.gd` | `ProceduralBodyPart` | Authored part spec: silhouette numbers, roles, joint. | spec done, `draw`/`bounds` are stubs |
| `sprite/creature_builder.gd` | `ProceduralCreatureBuilder` | Part list container, manifest, compose entry points. | container done, `compose*`/`outline` are stubs |
| `anim/squish_rig.gd` | `ProceduralSquishRig` | Joint graph, per joint springs, rest pose. | graph done, `step`/`disturb`/`draw` are stubs |

Wave 1 implements the stubs. Each stub file states exactly what it must
implement, and each stub returns a safe empty value after `push_error` so a
missing implementation is loud instead of silently wrong.

## Hard rules for Kit code

- A Kit never sets a pixel by hand and never names a literal RGB. Colours come
  from `ProceduralPalette` roles, shapes from `ProceduralSdf`.
- A Kit never calls `Input`, `InputMap`, `get_tree()`, `/root` or an autoload
  from this folder, and nothing in this folder does either. Motion input reaches
  a Kit through `ModuleContext`, and this system only turns it into physics.
- Nothing in this folder is a `Node`. There is no autoload and no service
  locator. A Kit owns the instances and frees them with the rest of its module.
- `duplicate_palette()` exists because `RefCounted.duplicate()` would share one
  `roles` dictionary between two palettes. Use it.

## Determinism

1. Everything starts from `Procedural.derive_seed(world_seed, id)`. The same
   three inputs always give the same `ProceduralSeed.value`, on every platform
   and every run. Hashing is explicit (FNV-1a plus a 32 bit finaliser) because
   the engine's own `hash()` is not a cross version contract.
2. Sub streams are path based: `derive("backdrop.far")` gives
   `"world/backdrop.far"`. Order independent, so adding a new element later does
   not change the pixels of the old ones.
3. `ProceduralNoiseField` applies `frequency` and `phase` itself, so scrolling
   is a phase offset and never a second noise instance.
4. `ProceduralPalette` is pure data. Same seed plus same variant gives the same
   colours every time.
5. `ProceduralSeed.make_rng()` hands out an independent stream. The short draw
   helpers (`unit`, `range_f`, `range_i`, `chance`, `sign_f`, `pick`) share one
   lazy stream, so mixing both styles in one build step makes the result depend
   on call order. Use `make_rng()` for anything that must be order independent.
6. `ProceduralSpring` integrates with a fixed substep, so the motion is the same
   at 30, 60 and 240 fps. There is no frame rate dependent easing anywhere here.

## Producing a sprite

Build once, at load time. Never per frame.

```gdscript
var stream: ProceduralSeed = Procedural.derive_seed(world_seed, "creature.slime")
var palette: ProceduralPalette = Procedural.make_palette(stream)
var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(Vector2i(64, 48))
builder.set_palette(palette)
for spec: Dictionary in authored_parts:
    var part: ProceduralBodyPart = ProceduralBodyPart.new()
    part.configure(spec)          # length, base_radius, tip_radius, bend, wiggle, roles
    builder.add_part(part)
var canvas: ProceduralCanvas = builder.compose_canvas()   # wave 1
canvas.posterize(6)                                      # optional build time pass
var texture: ImageTexture = canvas.to_texture()
```

Manual path, when the Kit wants to own the drawing: `Procedural.make_canvas()`
then `ProceduralSdf.stamp_field` / `stroke_field` / `shadow_field` per shape,
then `to_texture()`. `canvas.get_used_rect()` gives the tight bounds.

## Producing one frame of animation

Order matters. Physics first, drawing second, always.

```gdscript
# 1. advance the springs
rig.step(delta)                                  # wave 1 (joint graph)
deform.step(delta)                               # done
backdrop.set_view_offset(camera_motion)
backdrop.step(delta)                             # done
noise.advance(delta, Vector2(14.0, 0.0))         # done, unless a field already advances itself

# 2. read the results
var offset: Vector2 = backdrop.get_offset(index)
var point: Vector2 = deform.get_point(u, v)
var rotation: float = rig.get_rotation()
var scale: float = rig.get_scale()

# 3. draw
canvas.shift(previous_frame_canvas, offset.round())   # reuse, do not regenerate
deform.build_triangles()                               # ArrayMesh indices
canvas.to_texture()
```

Rules for the per frame path:

- Never regenerate a sprite or a background image per frame. Generate once, then
  move it with `ProceduralSpring`, `ProceduralDeformField` and
  `ProceduralBackdropDynamics`. That is the whole point of the system.
- Gusts and impacts go through `kick()` and `excite()`, never through a tween.
- Squish is a spring value, not a scale animation.

## Squishy background recipe

The requirement is physics plus soft deformation, for every backdrop.

```gdscript
var layer: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.FAR)
layer.configure(0.35, 5.0, 70.0, 0.75)          # parallax, noise amplitude, stiffness, damping
layer.attach_field(Procedural.make_noise(stream, ProceduralNoiseField.FIELD_SQUISH), 10.0)
layer.set_wind(Vector2(18.0, 0.0), 0.4)
for element: Vector2 in authored_positions:
    layer.add_anchor(element)

# per frame: layer.set_view_offset(view_motion); layer.step(delta)
# draw each element at authored_position + layer.get_offset(index)
```

For a surface that bulges instead of moving as a whole, add a
`ProceduralDeformField`, bind a `FIELD_SQUISH` noise to it, call `step(delta)`
and draw through `get_point(u, v)`. `excite(pulse, radius)` gives a local gust
with distance falloff.

Damping ratio decides the personality: `1.0` is critically damped and never
overshoots, `0.4` to `0.7` is under damped and wobbles, below `0.35` rings.

## Performance budget

- Seed derivation: pure integer math, free. Call it freely per element.
- Noise sample: about 3 `FastNoiseLite` lookups. Treat as microseconds.
- `ProceduralCanvas` fill and rect fills: 1 pixel write per call inside
  `blend_pixel`. A full 1920x1080 fill is roughly 2M writes, so a full screen
  fill is a build time cost of milliseconds, not a per frame cost.
- `draw_polygon`: one scanline pass over the bounding height. A creature
  silhouette at 64x48 is trivial; avoid it on a full screen every frame.
- `stamp_field` / `stroke_field` / `shadow_field`: one `Callable` invocation per
  pixel inside `bounds`. Always pass a tight `bounds`. Build time only.
- `blur(radius)`: two separable passes, so about 8 byte adds per pixel per
  channel. Build time only.
- `ProceduralDeformField`: `width * height` spring steps per frame. A 24x14
  backdrop grid is 336 springs and stays well under a millisecond. Keep grids at
  or below about 32x18 per layer.
- `ProceduralBackdropDynamics`: one spring per anchor. Anchors are meant to be
  per visible element, not per pixel.
- Target: a whole backdrop of 5 layers, 4 to 8 anchors each and one deform
  field, must stay under 2 ms per frame so the motion never costs a frame.

## Wave 1 checklist

| Symbol | Must implement |
|---|---|
| `ProceduralBodyPart.bounds()` | Local bounds that match `draw()` exactly. |
| `ProceduralBodyPart.draw()` | Silhouette from `ProceduralSdf`, fused with `smooth_min`, shaded from palette roles. Fix and document the local pose convention first. |
| `ProceduralCreatureBuilder.compose_canvas()` | Walk the parts, fuse the union, honour `canvas_size`, `squash` and `facing`. |
| `ProceduralCreatureBuilder.outline()` | One closed contour of the fused silhouette in pixel space. |
| `ProceduralCreatureBuilder.compose()` | `compose_canvas()` then `to_texture()`. |
| `ProceduralSquishRig.step()` | Integrate the graph from the root, inheriting parent transforms. |
| `ProceduralSquishRig.disturb()` | Impulse into a joint and everything under it. |
| `ProceduralSquishRig.draw()` | Draw the attached parts through the joint transform, squash non uniformly. |
| `Procedural.build_sprite()` | Thin factory, spec keys in its own comment. |
| `Procedural.render_frame()` | Thin factory, spec keys in its own comment. |
| `Procedural.make_rig()` | Thin factory, spec keys in its own comment. |
| `Procedural.make_backdrop()` | Thin factory, spec keys in its own comment. |

Until those exist, construct `ProceduralCreatureBuilder`, `ProceduralBodyPart`,
`ProceduralSquishRig` and `ProceduralBackdropDynamics` directly and do not pass
a spec dictionary to the `Procedural` factories.
