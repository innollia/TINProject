class_name Procedural
extends RefCounted

# PURPOSE: top level entry of the PVE (절차 비주얼 엔진). A Kit starts here and
# then uses the specific classes. Every generator in TIN is reached through one
# seed, so a whole screen is reproducible from one integer.
# OWNER: PVE. THE FOUR FACTORIES BELOW ARE NOT IMPLEMENTED BY DESIGN.
#
# This class holds no state. All methods are static, and none of them touch the
# scene tree, Input, InputMap, autoloads or /root. That is deliberate: a Kit
# builds visuals from its own data, never from a service lookup.
#
# ENGINE_VERSION 2 (see core/procedural/DESIGN_DECISION.md §6, §12)
#   1 -> 2  정규 형상(ProceduralShape) 도입. 스펙은 ProceduralShape.build_from_spec()
#          하나로 들어간다. ProceduralSquishRig / ProceduralDeformField /
#          ProceduralBackdropDynamics 는 to_shape() 로 정규 형상이 된다.
#          스펙 JSON 의 "version" 은 이 값과 같아야 한다.
#   삭제 없음. 추가 없음. 1 의 공개 시그니처는 전부 그대로 살아 있다.

const ENGINE_VERSION: int = 2


## The only sanctioned way to start generation.
static func derive_seed(world_seed: int, id: String, version: int = ENGINE_VERSION) -> ProceduralSeed:
	return ProceduralSeed.new(world_seed, id, version)


static func make_noise(stream: ProceduralSeed, field: StringName = ProceduralNoiseField.FIELD_DETAIL) -> ProceduralNoiseField:
	return ProceduralNoiseField.new(stream.value, field)


static func make_palette(stream: ProceduralSeed, variant: int = 0) -> ProceduralPalette:
	return ProceduralPaletteScheme.new().build(stream, variant)


static func make_canvas(width: int, height: int) -> ProceduralCanvas:
	return ProceduralCanvas.new(width, height)


# WAVE 1 MUST IMPLEMENT
#   build_sprite(spec): a spec driven compose() over ProceduralCreatureBuilder.
#   Frozen spec keys so Kits can share one dictionary shape:
#     "seed_id": String, "variant": int, "size": Vector2i, "parts": Array[Dictionary]
#   Each entry of "parts" is a ProceduralBodyPart.configure() spec. Derive the
#   palette with make_palette(), build the parts, compose, return the texture.
#   Until the spec shape is agreed in code, Kits must call
#   ProceduralCreatureBuilder directly instead of guessing here.
static func build_sprite(_spec: Dictionary) -> ImageTexture:
	push_error("Procedural.build_sprite() is intentionally not implemented. Second use site required. Call ProceduralShape.build_from_spec() instead.")
	return null


# WAVE 1 MUST IMPLEMENT
#   render_frame(spec): one animation frame. Frozen spec keys:
#     "sprite": Dictionary (the build_sprite spec), "pose": Dictionary,
#     "delta": float, "background": Dictionary (optional backdrop spec)
#   Expected order: step the rig, step the deform fields, redraw, return texture.
#   See README.md "one frame of animation" for the exact order.
static func render_frame(_spec: Dictionary) -> ImageTexture:
	push_error("Procedural.render_frame() is intentionally not implemented. Second use site required. Step a ProceduralShape and read its points instead.")
	return null


# WAVE 1 MUST IMPLEMENT
#   make_rig(spec): build a ProceduralSquishRig graph from a spec.
#     "seed_id": String, "variant": int,
#     "joints": Array[Dictionary] where each entry is
#       { "id": StringName, "parent": StringName, "kind": JointKind name,
#         "rest_position": Vector2, "rest_rotation": float,
#         "stiffness": float, "damping_ratio": float, "squash": float,
#         "part": ProceduralBodyPart spec Dictionary }
#   Keep this a thin factory: the graph logic belongs in ProceduralSquishRig.
static func make_rig(_spec: Dictionary) -> ProceduralSquishRig:
	push_error("Procedural.make_rig() is intentionally not implemented. Second use site required. Use ProceduralSquishRig directly.")
	return null


# WAVE 1 MUST IMPLEMENT
#   make_backdrop(spec): build a ProceduralBackdropDynamics layer.
#     "seed_id": String, "variant": int, "layer": Layer name,
#     "parallax": float, "stiffness": float, "damping_ratio": float,
#     "field": StringName (noise field name), "field_amplitude": float,
#     "anchors": Array[Vector2] (rest world positions)
#   Keep this a thin factory: the motion logic belongs in ProceduralBackdropDynamics.
static func make_backdrop(_spec: Dictionary) -> ProceduralBackdropDynamics:
	push_error("Procedural.make_backdrop() is intentionally not implemented. Second use site required. Use ProceduralBackdropDynamics directly.")
	return null
