class_name EcoCreatureView
extends Node2D

## §5.1, §7.2, §9.13. 개체 1개 표시. 아키타입 5종이 구조가 서로 다른 리그를
## 쓴다(거미 금지 규칙 준수 — skitter 는 여러 다리를 쓰지만 신체 배치가 방사형
## 절지류가 아니라 좌우 대칭 소형 사족형이다). body_parts 수는 §7.2 표와 같다.

const CANVAS_SIZE: Vector2i = Vector2i(160, 160)

var archetype_id: StringName = &""
var rig: ProceduralSquishRig
var palette: ProceduralPalette
var scale_factor: float = 1.0

var _canvas_size_used: Vector2i = CANVAS_SIZE


func setup(p_archetype_id: StringName, world_seed: int, creature_id: int) -> void:
	archetype_id = p_archetype_id
	var stream: ProceduralSeed = Procedural.derive_seed(world_seed, "eco_creature_%s_%d" % [String(archetype_id), creature_id])
	palette = Procedural.make_palette(stream, creature_id % 4)
	rig = _build_rig(archetype_id)
	queue_redraw()


func set_scale_factor(value: float) -> void:
	scale_factor = maxf(value, 0.0001)
	queue_redraw()


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
	var offset: Vector2 = -Vector2(_canvas_size_used) * 0.5 * scale_factor
	draw_texture_rect(texture, Rect2(offset, Vector2(_canvas_size_used) * scale_factor), false)


func _build_rig(id: StringName) -> ProceduralSquishRig:
	match String(id):
		"skitter":
			return _build_skitter()
		"warden":
			return _build_warden()
		"maw":
			return _build_maw()
		"anchor":
			return _build_anchor()
		"brood":
			return _build_brood()
		_:
			return _build_skitter()


## skitter — 8 파츠. 작은 6다리 사족형(방사형 아님, 좌우 3쌍). 몸통 1 + 다리 6 + 꼬리 1.
func _build_skitter() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = _joint(&"body", Vector2(40.0, 40.0), 0.4)
	root.body_part = _part(&"body", ProceduralBodyPart.Kind.TORSO, 16.0, 9.0, 7.0)
	for pair_index: int in 3:
		var sign_z: float = -1.0 if pair_index == 0 else (0.0 if pair_index == 1 else 1.0)
		for side: int in 2:
			var sign_x: float = -1.0 if side == 0 else 1.0
			var leg: ProceduralSquishRig = _joint(StringName("leg_%d_%d" % [pair_index, side]), Vector2(sign_x * 7.0, sign_z * 5.0), 0.45)
			leg.body_part = _part(StringName("leg_%d_%d" % [pair_index, side]), ProceduralBodyPart.Kind.LIMB, 9.0, 2.6, 1.4)
			root.attach(leg)
	var tail: ProceduralSquishRig = _joint(&"tail", Vector2(0.0, 9.0), 0.5)
	tail.body_part = _part(&"tail", ProceduralBodyPart.Kind.TAIL, 10.0, 3.0, 0.8)
	root.attach(tail)
	return root


## warden — 12 파츠. 방어형, 4다리 + 등판 3장(각질) + 머리 + 눈.
func _build_warden() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = _joint(&"body", Vector2(60.0, 60.0), 0.25)
	root.body_part = _part(&"body", ProceduralBodyPart.Kind.TORSO, 30.0, 16.0, 13.0)
	var head: ProceduralSquishRig = _joint(&"head", Vector2(0.0, -16.0), 0.2)
	head.body_part = _part(&"head", ProceduralBodyPart.Kind.HEAD, 10.0, 8.0, 6.0)
	root.attach(head)
	var eye: ProceduralSquishRig = _joint(&"eye", Vector2(0.0, -1.0), 0.0)
	eye.body_part = _accent(&"eye", ProceduralBodyPart.Kind.EYE, 2.0, 2.5, 2.5, ProceduralPalette.ROLE_INK)
	head.attach(eye)
	for plate_index: int in 3:
		var plate: ProceduralSquishRig = _joint(StringName("plate_%d" % plate_index), Vector2(0.0, -6.0 + float(plate_index) * 8.0), 0.05)
		plate.squash = 0.05
		plate.body_part = _accent(StringName("plate_%d" % plate_index), ProceduralBodyPart.Kind.CAP, 10.0, 12.0, 3.0, ProceduralPalette.ROLE_RIM)
		root.attach(plate)
	for pair_index: int in 2:
		var sign_z: float = -1.0 if pair_index == 0 else 1.0
		for side: int in 2:
			var sign_x: float = -1.0 if side == 0 else 1.0
			var leg: ProceduralSquishRig = _joint(StringName("leg_%d_%d" % [pair_index, side]), Vector2(sign_x * 12.0, sign_z * 10.0), 0.3)
			leg.body_part = _part(StringName("leg_%d_%d" % [pair_index, side]), ProceduralBodyPart.Kind.LIMB, 16.0, 5.5, 3.5)
			root.attach(leg)
	return root


## maw — 10 파츠. 근접 돌진형, 큰 턱(아귀) + 짧은 다리 4 + 촉수 2.
func _build_maw() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = _joint(&"body", Vector2(50.0, 55.0), 0.3)
	root.body_part = _part(&"body", ProceduralBodyPart.Kind.TORSO, 20.0, 13.0, 15.0)
	var jaw_upper: ProceduralSquishRig = _joint(&"jaw_upper", Vector2(0.0, -13.0), 0.15)
	jaw_upper.body_part = _part(&"jaw_upper", ProceduralBodyPart.Kind.HEAD, 12.0, 11.0, 4.0)
	root.attach(jaw_upper)
	var jaw_lower: ProceduralSquishRig = _joint(&"jaw_lower", Vector2(0.0, -2.0), 0.2)
	jaw_lower.body_part = _part(&"jaw_lower", ProceduralBodyPart.Kind.HEAD, 11.0, 10.0, 3.0)
	root.attach(jaw_lower)
	var eye_l: ProceduralSquishRig = _joint(&"eye_l", Vector2(-6.0, -14.0), 0.0)
	eye_l.body_part = _accent(&"eye_l", ProceduralBodyPart.Kind.EYE, 2.0, 2.0, 2.0, ProceduralPalette.ROLE_DANGER)
	root.attach(eye_l)
	var eye_r: ProceduralSquishRig = _joint(&"eye_r", Vector2(6.0, -14.0), 0.0)
	eye_r.body_part = _accent(&"eye_r", ProceduralBodyPart.Kind.EYE, 2.0, 2.0, 2.0, ProceduralPalette.ROLE_DANGER)
	root.attach(eye_r)
	for side: int in 2:
		var sign_x: float = -1.0 if side == 0 else 1.0
		var leg: ProceduralSquishRig = _joint(StringName("leg_%d" % side), Vector2(sign_x * 10.0, 12.0), 0.4)
		leg.body_part = _part(StringName("leg_%d" % side), ProceduralBodyPart.Kind.LIMB, 12.0, 5.0, 3.0)
		root.attach(leg)
	for tentacle_index: int in 2:
		var sign_x2: float = -1.0 if tentacle_index == 0 else 1.0
		var tentacle: ProceduralSquishRig = _joint(StringName("tentacle_%d" % tentacle_index), Vector2(sign_x2 * 12.0, -4.0), 0.55)
		tentacle.body_part = _part(StringName("tentacle_%d" % tentacle_index), ProceduralBodyPart.Kind.TAIL, 14.0, 3.5, 0.8)
		root.attach(tentacle)
	return root


## anchor — 11 파츠. 가장 크고 느린 자루형, 다리 없음. 몸통 3절 + 촉수 다발 6 + 입 2.
func _build_anchor() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = _joint(&"body_low", Vector2(80.0, 100.0), 0.35)
	root.body_part = _part(&"body_low", ProceduralBodyPart.Kind.TORSO, 34.0, 22.0, 17.0)
	var mid: ProceduralSquishRig = _joint(&"body_mid", Vector2(0.0, -28.0), 0.3)
	mid.body_part = _part(&"body_mid", ProceduralBodyPart.Kind.TORSO, 30.0, 19.0, 13.0)
	root.attach(mid)
	var top: ProceduralSquishRig = _joint(&"body_top", Vector2(0.0, -22.0), 0.25)
	top.body_part = _part(&"body_top", ProceduralBodyPart.Kind.TORSO, 22.0, 13.0, 8.0)
	mid.attach(top)
	var mouth_l: ProceduralSquishRig = _joint(&"mouth_l", Vector2(-6.0, -8.0), 0.1)
	mouth_l.body_part = _accent(&"mouth_l", ProceduralBodyPart.Kind.EYE, 3.0, 3.0, 1.0, ProceduralPalette.ROLE_DANGER)
	top.attach(mouth_l)
	var mouth_r: ProceduralSquishRig = _joint(&"mouth_r", Vector2(6.0, -8.0), 0.1)
	mouth_r.body_part = _accent(&"mouth_r", ProceduralBodyPart.Kind.EYE, 3.0, 3.0, 1.0, ProceduralPalette.ROLE_DANGER)
	top.attach(mouth_r)
	for tentacle_index: int in 6:
		var angle_deg: float = -75.0 + float(tentacle_index) * 30.0
		var offset: Vector2 = Vector2(1.0, -0.3).rotated(deg_to_rad(angle_deg)) * 16.0
		var tentacle: ProceduralSquishRig = _joint(StringName("tentacle_%d" % tentacle_index), offset, 0.6)
		tentacle.body_part = _part(StringName("tentacle_%d" % tentacle_index), ProceduralBodyPart.Kind.TAIL, 20.0, 4.0, 0.6)
		root.attach(tentacle)
	return root


## brood — 9 파츠. 무리형, 여러 눈알이 달린 작은 몸(다리 없이 꿈틀거리는 소형).
## 몸통 1 + 눈 4쌍(=8) 는 9를 넘으므로 눈 4개 + 촉수 4로 9를 맞춘다.
func _build_brood() -> ProceduralSquishRig:
	var root: ProceduralSquishRig = _joint(&"body", Vector2(30.0, 30.0), 0.5)
	root.body_part = _part(&"body", ProceduralBodyPart.Kind.TORSO, 12.0, 8.0, 8.0)
	for eye_index: int in 4:
		var angle_deg: float = float(eye_index) * 90.0 + 45.0
		var offset: Vector2 = Vector2(1.0, 0.0).rotated(deg_to_rad(angle_deg)) * 6.0
		var eye: ProceduralSquishRig = _joint(StringName("eye_%d" % eye_index), offset, 0.0)
		eye.body_part = _accent(StringName("eye_%d" % eye_index), ProceduralBodyPart.Kind.EYE, 2.0, 1.8, 1.8, ProceduralPalette.ROLE_INK)
		root.attach(eye)
	for tentacle_index: int in 4:
		var angle_deg2: float = float(tentacle_index) * 90.0
		var offset2: Vector2 = Vector2(1.0, 0.0).rotated(deg_to_rad(angle_deg2)) * 7.0
		var tentacle: ProceduralSquishRig = _joint(StringName("tentacle_%d" % tentacle_index), offset2, 0.55)
		tentacle.body_part = _part(StringName("tentacle_%d" % tentacle_index), ProceduralBodyPart.Kind.TAIL, 8.0, 2.4, 0.6)
		root.attach(tentacle)
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
	part.rim_role = ProceduralPalette.ROLE_RIM
	return part


func _accent(id: StringName, kind: int, length: float, base_radius: float, tip_radius: float, role: StringName) -> ProceduralBodyPart:
	var part: ProceduralBodyPart = _part(id, kind, length, base_radius, tip_radius)
	part.body_role = role
	part.shade = ProceduralBodyPart.Shade.FLAT
	return part
