class_name EcoPlayerView
extends Node2D

## §5.1, §9.13. 플레이어 표시. 18파츠 정규 리그(HEAD 1, EYE 2, TORSO 3, LIMB 6,
## FOLD 3, CAP 3) + ProceduralSquishRig. rung 이 바뀌면 scale_factor 만 갱신하고
## 텍스처를 재생성하지 않는다(§4.3-4 R-01). q 는 읽지 않는다.

const PALETTE_SEED_ID: String = "eco_player"
const CANVAS_SIZE: Vector2i = Vector2i(96, 96)

var rig: ProceduralSquishRig
var palette: ProceduralPalette
var scale_factor: float = 1.0
var facing: int = 1

var _canvas_size_used: Vector2i = CANVAS_SIZE


func setup(world_seed: int) -> void:
	var stream: ProceduralSeed = Procedural.derive_seed(world_seed, PALETTE_SEED_ID)
	palette = Procedural.make_palette(stream, 0)
	rig = _build_rig()
	queue_redraw()


func set_scale_factor(value: float) -> void:
	scale_factor = maxf(value, 0.0001)
	queue_redraw()


func set_facing(value: int) -> void:
	facing = 1 if value >= 0 else -1
	scale.x = absf(scale.x) * float(facing)


func step(delta: float) -> void:
	if rig != null:
		rig.step(delta)
	queue_redraw()


func disturb(impulse: Vector2, local_point: Vector2 = Vector2.ZERO) -> void:
	if rig != null:
		rig.disturb(impulse, local_point)


func _draw() -> void:
	if rig == null or palette == null:
		return
	var canvas: ProceduralCanvas = Procedural.make_canvas(_canvas_size_used.x, _canvas_size_used.y)
	rig.draw(canvas, palette)
	var texture: ImageTexture = canvas.to_texture()
	if texture == null:
		return
	var draw_scale: float = scale_factor
	var offset: Vector2 = -Vector2(_canvas_size_used) * 0.5 * draw_scale
	draw_texture_rect(texture, Rect2(offset, Vector2(_canvas_size_used) * draw_scale), false)


## 18개 파츠: HEAD 1, EYE 2, TORSO 3, LIMB 6, FOLD 3, CAP 3.
func _build_rig() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = ProceduralSquishRig.new(&"pelvis")
	root.joint_kind = ProceduralSquishRig.JointKind.SOFT
	root.rest_position = Vector2(48.0, 60.0)
	root.squash = 0.35
	root.body_part = _part(&"torso_low", ProceduralBodyPart.Kind.TORSO, 20.0, 16.0, 14.0)

	var spine_mid: ProceduralSquishRig = _joint(&"spine_mid", Vector2(0.0, -18.0), 0.30)
	spine_mid.body_part = _part(&"torso_mid", ProceduralBodyPart.Kind.TORSO, 18.0, 15.0, 13.0)
	root.attach(spine_mid)

	var spine_top: ProceduralSquishRig = _joint(&"spine_top", Vector2(0.0, -16.0), 0.25)
	spine_top.body_part = _part(&"torso_top", ProceduralBodyPart.Kind.TORSO, 14.0, 13.0, 9.0)
	spine_mid.attach(spine_top)

	var head: ProceduralSquishRig = _joint(&"head", Vector2(0.0, -12.0), 0.20)
	head.body_part = _part(&"head", ProceduralBodyPart.Kind.HEAD, 12.0, 9.0, 8.0)
	spine_top.attach(head)

	var eye_l: ProceduralSquishRig = _joint(&"eye_l", Vector2(-4.0, -2.0), 0.0)
	eye_l.body_part = _accent(&"eye_l", ProceduralBodyPart.Kind.EYE, 2.0, 2.0, 2.0, ProceduralPalette.ROLE_INK)
	head.attach(eye_l)
	var eye_r: ProceduralSquishRig = _joint(&"eye_r", Vector2(4.0, -2.0), 0.0)
	eye_r.body_part = _accent(&"eye_r", ProceduralBodyPart.Kind.EYE, 2.0, 2.0, 2.0, ProceduralPalette.ROLE_INK)
	head.attach(eye_r)

	var cap_head: ProceduralSquishRig = _joint(&"cap_head", Vector2(0.0, -4.0), 0.10)
	cap_head.body_part = _accent(&"cap_head", ProceduralBodyPart.Kind.CAP, 4.0, 4.0, 1.0, ProceduralPalette.ROLE_RIM)
	head.attach(cap_head)

	for side_index: int in 2:
		var sign: float = -1.0 if side_index == 0 else 1.0
		var arm_upper: ProceduralSquishRig = _joint(StringName("arm_upper_%d" % side_index), Vector2(sign * 10.0, -14.0), 0.40)
		arm_upper.body_part = _part(StringName("arm_upper_%d" % side_index), ProceduralBodyPart.Kind.LIMB, 12.0, 6.0, 4.5)
		spine_top.attach(arm_upper)
		var arm_lower: ProceduralSquishRig = _joint(StringName("arm_lower_%d" % side_index), Vector2(sign * 2.0, 11.0), 0.45)
		arm_lower.body_part = _part(StringName("arm_lower_%d" % side_index), ProceduralBodyPart.Kind.LIMB, 11.0, 4.5, 3.0)
		arm_upper.attach(arm_lower)
		var leg_upper: ProceduralSquishRig = _joint(StringName("leg_upper_%d" % side_index), Vector2(sign * 6.0, 10.0), 0.35)
		leg_upper.body_part = _part(StringName("leg_upper_%d" % side_index), ProceduralBodyPart.Kind.LIMB, 14.0, 7.0, 5.0)
		root.attach(leg_upper)
		var leg_lower: ProceduralSquishRig = _joint(StringName("leg_lower_%d" % side_index), Vector2(sign * 1.0, 13.0), 0.40)
		leg_lower.body_part = _part(StringName("leg_lower_%d" % side_index), ProceduralBodyPart.Kind.LIMB, 13.0, 5.0, 3.5)
		leg_upper.attach(leg_lower)
		var fold: ProceduralSquishRig = _joint(StringName("fold_%d" % side_index), Vector2(sign * 3.0, 4.0), 0.55)
		fold.squash = 0.55
		fold.body_part = _part(StringName("fold_%d" % side_index), ProceduralBodyPart.Kind.FOLD, 8.0, 5.0, 3.0)
		root.attach(fold)

	var fold_back: ProceduralSquishRig = _joint(&"fold_back", Vector2(0.0, 6.0), 0.5)
	fold_back.body_part = _part(&"fold_back", ProceduralBodyPart.Kind.FOLD, 9.0, 6.0, 3.0)
	root.attach(fold_back)

	var cap_shoulder_l: ProceduralSquishRig = _joint(&"cap_shoulder_l", Vector2(-9.0, -15.0), 0.10)
	cap_shoulder_l.body_part = _accent(&"cap_shoulder_l", ProceduralBodyPart.Kind.CAP, 4.0, 4.0, 1.0, ProceduralPalette.ROLE_RIM)
	spine_top.attach(cap_shoulder_l)
	var cap_shoulder_r: ProceduralSquishRig = _joint(&"cap_shoulder_r", Vector2(9.0, -15.0), 0.10)
	cap_shoulder_r.body_part = _accent(&"cap_shoulder_r", ProceduralBodyPart.Kind.CAP, 4.0, 4.0, 1.0, ProceduralPalette.ROLE_RIM)
	spine_top.attach(cap_shoulder_r)

	return root


func _joint(id: StringName, rest_position: Vector2, squash_limit: float) -> ProceduralSquishRig:
	var joint: ProceduralSquishRig = ProceduralSquishRig.new(id)
	joint.joint_kind = ProceduralSquishRig.JointKind.SOFT
	joint.rest_position = rest_position
	joint.squash = squash_limit
	return joint


func _part(id: StringName, kind: int, length: float, base_radius: float, tip_radius: float) -> ProceduralBodyPart:
	var part: ProceduralBodyPart = ProceduralBodyPart.new(id, kind)
	part.length = length
	part.base_radius = base_radius
	part.tip_radius = tip_radius
	part.shade = ProceduralBodyPart.Shade.VOLUMETRIC
	part.body_role = ProceduralPalette.ROLE_BODY
	part.shade_role = ProceduralPalette.ROLE_BODY_DARK
	part.rim_role = ProceduralPalette.ROLE_KEY_LIGHT
	return part


func _accent(id: StringName, kind: int, length: float, base_radius: float, tip_radius: float, role: StringName) -> ProceduralBodyPart:
	var part: ProceduralBodyPart = _part(id, kind, length, base_radius, tip_radius)
	part.body_role = role
	part.shade = ProceduralBodyPart.Shade.FLAT
	return part
