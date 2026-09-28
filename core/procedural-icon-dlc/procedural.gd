class_name DlcProcedural
extends RefCounted

# PURPOSE: top level entry of the PVE (절차 비주얼 엔진). A Kit starts here and
# then uses the specific classes. Every generator in TIN is reached through one
# seed, so a whole screen is reproducible from one integer.
# OWNER: PVE.
#
# This class holds no state. All methods are static, and none of them touch the
# scene tree, Input, InputMap, autoloads or /root. That is deliberate: a Kit
# builds visuals from its own data, never from a service lookup.
#
# ENGINE_VERSION 2 (see core/procedural/DESIGN_DECISION.md §6, §12)
#   1 -> 2  정규 형상(DlcProceduralShape) 도입. 스펙은 DlcProceduralShape.build_from_spec()
#          하나로 들어간다. DlcProceduralSquishRig / DlcProceduralDeformField /
#          DlcProceduralBackdropDynamics 는 to_shape() 로 정규 형상이 된다.
#          스펙 JSON 의 "version" 은 이 값과 같아야 한다.
#   삭제 없음. 추가 없음. 1 의 공개 시그니처는 전부 그대로 살아 있다.
#
# 네 개의 dict 팩토리(build_sprite / render_frame / make_rig / make_backdrop)는
# 얇은 껍데기다. 스펙 키를 클래스 멤버로 옮기고 그 클래스를 부를 뿐, 자기 로직이 없다.
# 스펙이 틀리면 push_error 와 함께 null 이다. 조용히 기본값으로 메우지 않는다.
# 모든 키는 JSON 으로도 들어온다: Vector2 / Vector2i 자리에 [x, y] 배열을 써도 된다.

const ENGINE_VERSION: int = 2


## The only sanctioned way to start generation.
static func derive_seed(world_seed: int, id: String, version: int = ENGINE_VERSION) -> DlcProceduralSeed:
	return DlcProceduralSeed.new(world_seed, id, version)


static func make_noise(stream: DlcProceduralSeed, field: StringName = DlcProceduralNoiseField.FIELD_DETAIL) -> DlcProceduralNoiseField:
	return DlcProceduralNoiseField.new(stream.value, field)


static func make_palette(stream: DlcProceduralSeed, variant: int = 0) -> DlcProceduralPalette:
	return DlcProceduralPaletteScheme.new().build(stream, variant)


static func make_canvas(width: int, height: int) -> DlcProceduralCanvas:
	return DlcProceduralCanvas.new(width, height)


## build_sprite(spec): a spec driven compose() over DlcProceduralCreatureBuilder.
## Frozen spec keys, shared by every Kit:
##   "seed_id": String        required. palette stream = derive_seed(seed, seed_id)
##   "variant": int           palette variant, default 0
##   "size": Vector2i         canvas size, default 64 x 64
##   "parts": Array[Dictionary]  required, non empty. Each entry is a
##                            DlcProceduralBodyPart.configure() spec.
## Optional keys, one to one onto DlcProceduralCreatureBuilder members:
##   "seed": int (world seed, default 0), "squash": float, "facing": int,
##   "outline_role": StringName, "outline_width": float,
##   "version": int (when present it must equal ENGINE_VERSION).
## Bake it once at load time and keep the texture. Never call this per frame.
static func build_sprite(_spec: Dictionary) -> ImageTexture:
	var builder: DlcProceduralCreatureBuilder = _sprite_builder(_spec, "DlcProcedural.build_sprite")
	if builder == null:
		return null
	return builder.compose()


## render_frame(spec): one animation frame of a baked sprite. Frozen spec keys:
##   "sprite": Dictionary      the build_sprite spec. Baked once, on the first call.
##   "pose": Dictionary        this frame's inputs, all optional:
##       "impulse": Vector2    contact impulse (px/s) into the sprite's squish rig
##       "point": Vector2      where it lands, in sprite pixels. Default: crown (top centre)
##       "wind": Vector2       steady push (px) on the crown, and wind on the background layer
##       "view_offset": Vector2  camera motion for the background layer
##   "delta": float            seconds to advance. 0 redraws without stepping.
##   "background": Dictionary  optional make_backdrop spec. The sprite rides on its
##                             anchor 0 (camera lag, wind). No anchor → one at the base.
## The spec dictionary is also the frame state: the first call keeps what it built
## under spec["_frame"] (engine owned — do not edit), so pass the SAME dictionary
## every frame. Nothing is regenerated after that first call.
## Order (README "one frame of animation"): disturb → step the rig → step the
## background → redraw the baked sprite through the rig's bone (squashed along it,
## turned with it) → texture. The rig is two joints: the base (bottom centre of the
## sprite, planted) and the crown (top centre, soft). Pushing the crown down
## squashes the sprite, pushing it sideways or wind leans it. No tween.
static func render_frame(_spec: Dictionary) -> ImageTexture:
	var state: Dictionary = _spec.get("_frame", {})
	if state.is_empty():
		state = _start_frame(_spec)
		if state.is_empty():
			return null
		_spec["_frame"] = state
	var rig: DlcProceduralSquishRig = state["rig"]
	var backdrop: DlcProceduralBackdropDynamics = state["backdrop"]
	var base: Vector2 = state["base"]
	var crown: Vector2 = state["crown"]
	var pose: Dictionary = _spec.get("pose", {})
	if pose.has("impulse"):
		rig.disturb(_vector(pose["impulse"], Vector2.ZERO), _vector(pose.get("point", crown), crown) - base)
	if pose.has("wind"):
		var wind: Vector2 = _vector(pose["wind"], Vector2.ZERO)
		rig.to_shape().force = wind
		if backdrop != null:
			backdrop.set_wind(wind)
	if backdrop != null and pose.has("view_offset"):
		backdrop.set_view_offset(_vector(pose["view_offset"], Vector2.ZERO))
	var delta: float = float(_spec.get("delta", 0.0))
	if delta > 0.0:
		rig.step(delta)
		if backdrop != null:
			backdrop.step(delta)
	var shape: DlcProceduralShape = rig.to_shape()
	var rest: PackedVector2Array = shape.get_rest()
	var points: PackedVector2Array = shape.get_points()
	var rest_bone: Vector2 = rest[1] - rest[0]
	var live_bone: Vector2 = points[1] - points[0]
	var along: float = clampf(
		live_bone.length() / maxf(rest_bone.length(), 0.0001),
		1.0 - DlcProceduralSquishRig.MAX_SQUASH, 1.0 + DlcProceduralSquishRig.MAX_SQUASH
	)
	var shift: Vector2 = backdrop.get_offset(0) if backdrop != null else Vector2.ZERO
	var forward: Transform2D = Transform2D(0.0, points[0] + shift) \
		* Transform2D(rest_bone.angle_to(live_bone), Vector2.ZERO) \
		* DlcProceduralBodyPart._squash_basis(rest_bone.angle(), along, 1.0 / along) \
		* Transform2D(0.0, -base)
	var frame: DlcProceduralCanvas = state["frame"]
	_resample(state["canvas"], frame, forward.affine_inverse())
	return frame.to_texture()


## make_rig(spec): build a DlcProceduralSquishRig graph from a spec and return its root.
##   "seed_id": String, "variant": int  accepted for spec symmetry. A rig makes no
##                                      random choice, so they change nothing.
##   "joints": Array[Dictionary], parents before children, exactly one root:
##     { "id": StringName (unique, required), "parent": StringName ("" or absent = root),
##       "kind": "rigid" | "soft" | "pinned" (default soft),
##       "rest_position": Vector2 (parent frame, px), "rest_rotation": float (radians),
##       "stiffness": float, "damping_ratio": float, "squash": float (0..MAX_SQUASH),
##       "part": DlcProceduralBodyPart spec Dictionary (optional) }
## Keep this a thin factory: the graph logic belongs in DlcProceduralSquishRig.
static func make_rig(_spec: Dictionary) -> DlcProceduralSquishRig:
	var entries: Variant = _spec.get("joints", null)
	if not (entries is Array) or (entries as Array).is_empty():
		push_error("DlcProcedural.make_rig: spec needs a non empty 'joints' array.")
		return null
	var by_id: Dictionary = {}
	var root: DlcProceduralSquishRig = null
	for raw: Variant in (entries as Array):
		if not (raw is Dictionary):
			push_error("DlcProcedural.make_rig: every joint must be a Dictionary.")
			return null
		var entry: Dictionary = raw
		var joint_id: StringName = StringName(String(entry.get("id", "")))
		if joint_id == &"" or by_id.has(joint_id):
			push_error("DlcProcedural.make_rig: joint needs a unique 'id' (got '%s')." % joint_id)
			return null
		var kind_value: int = _joint_kind_of(entry.get("kind", "soft"))
		if kind_value < 0:
			push_error("DlcProcedural.make_rig: joint '%s' has unknown kind '%s'." % [joint_id, entry.get("kind")])
			return null
		var joint: DlcProceduralSquishRig = DlcProceduralSquishRig.new(joint_id)
		joint.joint_kind = kind_value
		joint.rest_position = _vector(entry.get("rest_position", Vector2.ZERO), Vector2.ZERO)
		joint.rest_rotation = float(entry.get("rest_rotation", 0.0))
		joint.stiffness = maxf(float(entry.get("stiffness", DlcProceduralSquishRig.DEFAULT_STIFFNESS)), 0.0001)
		joint.damping_ratio = maxf(float(entry.get("damping_ratio", DlcProceduralSquishRig.DEFAULT_DAMPING_RATIO)), 0.0)
		joint.squash = clampf(float(entry.get("squash", joint.squash)), 0.0, DlcProceduralSquishRig.MAX_SQUASH)
		if entry.has("part"):
			if not (entry["part"] is Dictionary):
				push_error("DlcProcedural.make_rig: joint '%s' part must be a Dictionary." % joint_id)
				return null
			var part: DlcProceduralBodyPart = DlcProceduralBodyPart.new(joint_id)
			part.configure(entry["part"])
			joint.body_part = part
		var parent_id: StringName = StringName(String(entry.get("parent", "")))
		if parent_id == &"":
			if root != null:
				push_error("DlcProcedural.make_rig: '%s' is a second root. A rig has exactly one." % joint_id)
				return null
			root = joint
		else:
			if not by_id.has(parent_id):
				push_error("DlcProcedural.make_rig: joint '%s' names parent '%s', which is not an earlier joint." % [joint_id, parent_id])
				return null
			(by_id[parent_id] as DlcProceduralSquishRig).attach(joint)
		by_id[joint_id] = joint
	return root


## make_backdrop(spec): build a DlcProceduralBackdropDynamics layer.
##   "seed_id": String        noise stream = derive_seed(seed, seed_id). Required with "field"
##   "variant": int           stream variant, default 0
##   "layer": Layer name      sky | far | mid | near | foreground (default mid)
##   "parallax": float, "stiffness": float, "damping_ratio": float
##   "field": StringName      noise field name (shape | detail | flow | squish), optional
##   "field_amplitude": float
##   "anchors": Array[Vector2]  rest world positions
## Optional: "seed": int (world seed), "phase_speed": float, "wind": Vector2, "wind_gain": float.
## Keep this a thin factory: the motion logic belongs in DlcProceduralBackdropDynamics.
static func make_backdrop(_spec: Dictionary) -> DlcProceduralBackdropDynamics:
	var layer_value: int = _backdrop_layer_of(_spec.get("layer", "mid"))
	if layer_value < 0:
		push_error("DlcProcedural.make_backdrop: unknown layer '%s'." % _spec.get("layer"))
		return null
	var layer: DlcProceduralBackdropDynamics = DlcProceduralBackdropDynamics.new(layer_value)
	layer.configure(
		float(_spec.get("parallax", DlcProceduralBackdropDynamics.DEFAULT_PARALLAX)),
		float(_spec.get("field_amplitude", 0.0)),
		float(_spec.get("stiffness", DlcProceduralBackdropDynamics.DEFAULT_STIFFNESS)),
		float(_spec.get("damping_ratio", DlcProceduralBackdropDynamics.DEFAULT_DAMPING_RATIO))
	)
	var field_name: StringName = StringName(String(_spec.get("field", "")))
	if field_name != &"":
		if not DlcProceduralNoiseField.PRESETS.has(field_name):
			push_error("DlcProcedural.make_backdrop: unknown noise field '%s'." % field_name)
			return null
		if not _spec.has("seed_id"):
			push_error("DlcProcedural.make_backdrop: a noise field needs 'seed_id'.")
			return null
		var stream: DlcProceduralSeed = derive_seed(int(_spec.get("seed", 0)), String(_spec["seed_id"]))
		var variant: int = int(_spec.get("variant", 0))
		if variant != 0:
			stream = stream.derive_index(variant)
		layer.attach_field(
			make_noise(stream, field_name),
			float(_spec.get("phase_speed", DlcProceduralBackdropDynamics.DEFAULT_PHASE_SPEED))
		)
	var anchors: Variant = _spec.get("anchors", [])
	if not (anchors is Array):
		push_error("DlcProcedural.make_backdrop: 'anchors' must be an array of positions.")
		return null
	if not layer.set_anchor_capacity((anchors as Array).size()):
		return null
	for raw: Variant in (anchors as Array):
		layer.add_anchor(_vector(raw, Vector2.ZERO))
	if _spec.has("wind"):
		layer.set_wind(_vector(_spec["wind"], Vector2.ZERO), float(_spec.get("wind_gain", 1.0)))
	return layer


# ── 내부 ─────────────────────────────────────────────────────────────────

## build_sprite 스펙 → 파트가 채워진 빌더. 틀린 스펙이면 push_error 와 null.
static func _sprite_builder(spec: Dictionary, caller: String) -> DlcProceduralCreatureBuilder:
	if spec.has("version") and int(spec["version"]) != ENGINE_VERSION:
		push_error("%s: spec version %d != ENGINE_VERSION %d." % [caller, int(spec["version"]), ENGINE_VERSION])
		return null
	if not spec.has("seed_id"):
		push_error("%s: spec needs 'seed_id'." % caller)
		return null
	var entries: Variant = spec.get("parts", null)
	if not (entries is Array) or (entries as Array).is_empty():
		push_error("%s: spec needs a non empty 'parts' array." % caller)
		return null
	var stream: DlcProceduralSeed = derive_seed(int(spec.get("seed", 0)), String(spec["seed_id"]))
	var builder: DlcProceduralCreatureBuilder = DlcProceduralCreatureBuilder.new(
		_vector_i(spec.get("size", Vector2i(64, 64)), Vector2i(64, 64))
	)
	builder.set_palette(make_palette(stream, int(spec.get("variant", 0))))
	if spec.has("squash"):
		builder.squash = float(spec["squash"])
	if spec.has("facing"):
		builder.facing = int(spec["facing"])
	if spec.has("outline_role"):
		builder.outline_role = StringName(String(spec["outline_role"]))
	if spec.has("outline_width"):
		builder.outline_width = float(spec["outline_width"])
	for raw: Variant in (entries as Array):
		if not (raw is Dictionary):
			push_error("%s: every part must be a Dictionary." % caller)
			return null
		var part: DlcProceduralBodyPart = DlcProceduralBodyPart.new()
		part.configure(raw)
		builder.add_part(part)
	return builder


## render_frame 의 첫 호출: 스프라이트를 한 번 굽고, 밑동(고정)·정수리(soft) 두 관절짜리
## 리그와 (있으면) 배경 레이어를 만든다.
static func _start_frame(spec: Dictionary) -> Dictionary:
	var sprite: Variant = spec.get("sprite", null)
	if not (sprite is Dictionary):
		push_error("DlcProcedural.render_frame: spec needs a 'sprite' build_sprite spec.")
		return {}
	var builder: DlcProceduralCreatureBuilder = _sprite_builder(sprite, "DlcProcedural.render_frame")
	if builder == null:
		return {}
	if not builder.is_bakeable():
		push_error("DlcProcedural.render_frame: bake refused. points is not invariant.")
		return {}
	var canvas: DlcProceduralCanvas = builder.compose_canvas()
	var used: Rect2i = canvas.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		push_error("DlcProcedural.render_frame: the sprite baked to an empty canvas.")
		return {}
	var base: Vector2 = Vector2(float(used.position.x) + float(used.size.x) * 0.5, float(used.end.y))
	var crown: Vector2 = Vector2(base.x, float(used.position.y))
	var rig: DlcProceduralSquishRig = DlcProceduralSquishRig.new(&"base")
	rig.joint_kind = DlcProceduralSquishRig.JointKind.PINNED
	rig.rest_position = base
	var top: DlcProceduralSquishRig = DlcProceduralSquishRig.new(&"crown")
	top.rest_position = crown - base
	top.squash = DlcProceduralSquishRig.MAX_SQUASH
	rig.attach(top)
	if rig.to_shape() == null:
		return {}
	var backdrop: DlcProceduralBackdropDynamics = null
	if spec.has("background"):
		if not (spec["background"] is Dictionary):
			push_error("DlcProcedural.render_frame: 'background' must be a make_backdrop spec.")
			return {}
		backdrop = make_backdrop(spec["background"])
		if backdrop == null:
			return {}
		if backdrop.get_anchor_count() == 0:
			backdrop.set_anchor_capacity(1)
			backdrop.add_anchor(base)
	return {
		"canvas": canvas,
		"frame": DlcProceduralCanvas.new(canvas.width, canvas.height),
		"rig": rig,
		"backdrop": backdrop,
		"base": base,
		"crown": crown,
	}


## target 의 픽셀 중심마다 inverse 로 source 를 쌍선형 샘플한다. 알파 가중 평균이라
## 가장자리가 검게 번지지 않는다. 색은 source 에서만 온다.
static func _resample(source: DlcProceduralCanvas, target: DlcProceduralCanvas, inverse: Transform2D) -> void:
	target.clear()
	for y: int in target.height:
		for x: int in target.width:
			var at: Vector2 = inverse * Vector2(float(x) + 0.5, float(y) + 0.5) - Vector2(0.5, 0.5)
			var x0: int = floori(at.x)
			var y0: int = floori(at.y)
			if x0 < -1 or y0 < -1 or x0 >= source.width or y0 >= source.height:
				continue
			var tx: float = at.x - float(x0)
			var ty: float = at.y - float(y0)
			var c00: Color = source.get_pixel(x0, y0)
			var c10: Color = source.get_pixel(x0 + 1, y0)
			var c01: Color = source.get_pixel(x0, y0 + 1)
			var c11: Color = source.get_pixel(x0 + 1, y0 + 1)
			var w00: float = (1.0 - tx) * (1.0 - ty) * c00.a
			var w10: float = tx * (1.0 - ty) * c10.a
			var w01: float = (1.0 - tx) * ty * c01.a
			var w11: float = tx * ty * c11.a
			var alpha: float = w00 + w10 + w01 + w11
			if alpha < 0.5 / 255.0:
				continue
			var mixed: Color = (c00 * w00 + c10 * w10 + c01 * w01 + c11 * w11) / alpha
			mixed.a = alpha
			target.set_pixel(x, y, mixed)


static func _joint_kind_of(raw: Variant) -> int:
	if raw is int or raw is float:
		var number: int = int(raw)
		return number if number >= 0 and number <= DlcProceduralSquishRig.JointKind.PINNED else -1
	match String(raw).to_lower():
		"rigid":
			return DlcProceduralSquishRig.JointKind.RIGID
		"soft":
			return DlcProceduralSquishRig.JointKind.SOFT
		"pinned":
			return DlcProceduralSquishRig.JointKind.PINNED
		_:
			return -1


static func _backdrop_layer_of(raw: Variant) -> int:
	if raw is int or raw is float:
		var number: int = int(raw)
		return number if number >= 0 and number <= DlcProceduralBackdropDynamics.Layer.FOREGROUND else -1
	match String(raw).to_lower():
		"sky":
			return DlcProceduralBackdropDynamics.Layer.SKY
		"far":
			return DlcProceduralBackdropDynamics.Layer.FAR
		"mid":
			return DlcProceduralBackdropDynamics.Layer.MID
		"near":
			return DlcProceduralBackdropDynamics.Layer.NEAR
		"foreground":
			return DlcProceduralBackdropDynamics.Layer.FOREGROUND
		_:
			return -1


static func _vector(raw: Variant, fallback: Vector2) -> Vector2:
	if raw is Vector2:
		return raw
	if raw is Vector2i:
		return Vector2(raw)
	if raw is Array and (raw as Array).size() >= 2:
		return Vector2(float(raw[0]), float(raw[1]))
	return fallback


static func _vector_i(raw: Variant, fallback: Vector2i) -> Vector2i:
	if raw is Vector2i:
		return raw
	if raw is Vector2:
		return Vector2i(raw)
	if raw is Array and (raw as Array).size() >= 2:
		return Vector2i(int(raw[0]), int(raw[1]))
	return fallback
