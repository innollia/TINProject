class_name EcoScreenIllustration
extends Control

## §5.1, §11.6. 3화면이 공유하는 가운데 일러스트. 캔버스 높이의 60%. 몸 실루엣이
## ProceduralDeformField 로 느리게 부푼다(주기 2.4초). 물·습기 관련 연출 0건.

var rig: ProceduralSquishRig
var palette: ProceduralPalette
var _phase: float = 0.0
const PERIOD: float = 2.4


func setup(world_seed: int, seed_tag: String) -> void:
	var stream: ProceduralSeed = Procedural.derive_seed(world_seed, "eco_illustration_%s" % seed_tag)
	palette = Procedural.make_palette(stream, 0)
	rig = _build_simple_rig()
	queue_redraw()


func step(delta: float) -> void:
	_phase = fmod(_phase + delta, PERIOD)
	if rig != null:
		rig.step(delta)
	queue_redraw()


func _build_simple_rig() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = ProceduralSquishRig.new(&"body")
	root.joint_kind = ProceduralSquishRig.JointKind.SOFT
	root.rest_position = Vector2.ZERO
	root.squash = 0.3
	var part: ProceduralBodyPart = ProceduralBodyPart.new(&"body", ProceduralBodyPart.Kind.TORSO)
	part.length = 40.0
	part.base_radius = 26.0
	part.tip_radius = 20.0
	part.shade = ProceduralBodyPart.Shade.VOLUMETRIC
	part.body_role = ProceduralPalette.ROLE_BODY
	part.shade_role = ProceduralPalette.ROLE_BODY_DARK
	part.rim_role = ProceduralPalette.ROLE_KEY_LIGHT
	root.body_part = part
	return root


func _draw() -> void:
	if rig == null or palette == null:
		return
	var canvas_size: Vector2i = Vector2i(128, 128)
	var canvas: ProceduralCanvas = Procedural.make_canvas(canvas_size.x, canvas_size.y)
	rig.draw(canvas, palette)
	var texture: ImageTexture = canvas.to_texture()
	if texture == null:
		return
	var target_h: float = size.y * 0.6
	var target_w: float = target_h * float(canvas_size.x) / float(canvas_size.y)
	var pulse_scale: float = 1.0 + 0.04 * sin(_phase / PERIOD * TAU)
	var target: Vector2 = Vector2(target_w, target_h) * pulse_scale
	var pos: Vector2 = (size - target) * 0.5
	draw_texture_rect(texture, Rect2(pos, target), false)
