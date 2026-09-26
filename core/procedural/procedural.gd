class_name Procedural
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
#   1 -> 2  정규 형상(ProceduralShape) 도입. 스펙은 ProceduralShape.build_from_spec()
#          하나로 들어간다. ProceduralSquishRig / ProceduralDeformField /
#          ProceduralBackdropDynamics 는 to_shape() 로 정규 형상이 된다.
#          스펙 JSON 의 "version" 은 이 값과 같아야 한다.
#   삭제 없음. 추가 없음. 1 의 공개 시그니처는 전부 그대로 살아 있다.
#
# 네 개의 dict 팩토리(build_sprite / render_frame / make_rig / make_backdrop)는
# 얇은 껍데기다. 스펙 키를 클래스 멤버로 옮기고 그 클래스를 부를 뿐, 자기 로직이 없다.
# 스펙이 틀리면 push_error 와 함께 null 이다. 조용히 기본값으로 메우지 않는다.
# 모든 키는 JSON 으로도 들어온다: Vector2 / Vector2i 자리에 [x, y] 배열을 써도 된다.

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


## build_sprite(spec): a spec driven compose() over ProceduralCreatureBuilder.
## Frozen spec keys, shared by every Kit:
##   "seed_id": String        required. palette stream = derive_seed(seed, seed_id)
##   "variant": int           palette variant, default 0
##   "size": Vector2i         canvas size, default 64 x 64
##   "parts": Array[Dictionary]  required, non empty. Each entry is a
##                            ProceduralBodyPart.configure() spec.
## Optional keys, one to one onto ProceduralCreatureBuilder members:
##   "seed": int (world seed, default 0), "squash": float, "facing": int,
##   "outline_role": StringName, "outline_width": float,
##   "version": int (when present it must equal ENGINE_VERSION).
## Bake it once at load time and keep the texture. Never call this per frame.
static func build_sprite(_spec: Dictionary) -> ImageTexture:
	var builder: ProceduralCreatureBuilder = _sprite_builder(_spec, "Procedural.build_sprite")
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
## The squash stays inside the crown joint's default limit (ProceduralSquishRig
## `squash`, 0.35): at most 1 / 0.65 ≈ 1.54 times wider. The frame keeps the sprite's
## canvas size and cuts what falls outside, so give "size" room around the sprite.
## A frame whose pose did not change returns the previous call's texture.
static func render_frame(_spec: Dictionary) -> ImageTexture:
	var state: Dictionary = _spec.get("_frame", {})
	if state.is_empty():
		state = _start_frame(_spec)
		if state.is_empty():
			return null
		_spec["_frame"] = state
	var rig: ProceduralSquishRig = state["rig"]
	var backdrop: ProceduralBackdropDynamics = state["backdrop"]
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
	var shape: ProceduralShape = rig.to_shape()
	var rest: PackedVector2Array = shape.get_rest()
	var points: PackedVector2Array = shape.get_points()
	var rest_bone: Vector2 = rest[1] - rest[0]
	var live_bone: Vector2 = points[1] - points[0]
	var limit: float = float(state["limit"])
	var along: float = clampf(
		live_bone.length() / maxf(rest_bone.length(), 0.0001), 1.0 - limit, 1.0 + limit
	)
	var shift: Vector2 = backdrop.get_offset(0) if backdrop != null else Vector2.ZERO
	var forward: Transform2D = Transform2D(0.0, points[0] + shift) \
		* Transform2D(rest_bone.angle_to(live_bone), Vector2.ZERO) \
		* ProceduralBodyPart._squash_basis(rest_bone.angle(), along, 1.0 / along) \
		* Transform2D(0.0, -base)
	if state.has("texture") and forward == state["forward"]:
		return state["texture"]
	var frame: ProceduralCanvas = state["frame"]
	_resample(state["canvas"], frame, forward, state["used"])
	var texture: ImageTexture = frame.to_texture()
	state["forward"] = forward
	state["texture"] = texture
	return texture


## make_rig(spec): build a ProceduralSquishRig graph from a spec and return its root.
##   "seed_id": String, "variant": int  accepted for spec symmetry. A rig makes no
##                                      random choice, so they change nothing.
##   "joints": Array[Dictionary], parents before children, exactly one root:
##     { "id": StringName (unique, required), "parent": StringName ("" or absent = root),
##       "kind": "rigid" | "soft" | "pinned" (default soft),
##       "rest_position": Vector2 (parent frame, px), "rest_rotation": float (radians),
##       "stiffness": float, "damping_ratio": float, "squash": float (0..MAX_SQUASH),
##       "part": ProceduralBodyPart spec Dictionary (optional) }
## Keep this a thin factory: the graph logic belongs in ProceduralSquishRig.
static func make_rig(_spec: Dictionary) -> ProceduralSquishRig:
	var entries: Variant = _spec.get("joints", null)
	if not (entries is Array) or (entries as Array).is_empty():
		push_error("Procedural.make_rig: spec needs a non empty 'joints' array.")
		return null
	var by_id: Dictionary = {}
	var root: ProceduralSquishRig = null
	for raw: Variant in (entries as Array):
		if not (raw is Dictionary):
			push_error("Procedural.make_rig: every joint must be a Dictionary.")
			return null
		var entry: Dictionary = raw
		var joint_id: StringName = StringName(String(entry.get("id", "")))
		if joint_id == &"" or by_id.has(joint_id):
			push_error("Procedural.make_rig: joint needs a unique 'id' (got '%s')." % joint_id)
			return null
		var kind_value: int = _joint_kind_of(entry.get("kind", "soft"))
		if kind_value < 0:
			push_error("Procedural.make_rig: joint '%s' has unknown kind '%s'." % [joint_id, entry.get("kind")])
			return null
		var joint: ProceduralSquishRig = ProceduralSquishRig.new(joint_id)
		joint.joint_kind = kind_value
		joint.rest_position = _vector(entry.get("rest_position", Vector2.ZERO), Vector2.ZERO)
		joint.rest_rotation = float(entry.get("rest_rotation", 0.0))
		joint.stiffness = maxf(float(entry.get("stiffness", ProceduralSquishRig.DEFAULT_STIFFNESS)), 0.0001)
		joint.damping_ratio = maxf(float(entry.get("damping_ratio", ProceduralSquishRig.DEFAULT_DAMPING_RATIO)), 0.0)
		joint.squash = clampf(float(entry.get("squash", joint.squash)), 0.0, ProceduralSquishRig.MAX_SQUASH)
		if entry.has("part"):
			if not (entry["part"] is Dictionary):
				push_error("Procedural.make_rig: joint '%s' part must be a Dictionary." % joint_id)
				return null
			var part: ProceduralBodyPart = ProceduralBodyPart.new(joint_id)
			part.configure(entry["part"])
			joint.body_part = part
		var parent_id: StringName = StringName(String(entry.get("parent", "")))
		if parent_id == &"":
			if root != null:
				push_error("Procedural.make_rig: '%s' is a second root. A rig has exactly one." % joint_id)
				return null
			root = joint
		else:
			if not by_id.has(parent_id):
				push_error("Procedural.make_rig: joint '%s' names parent '%s', which is not an earlier joint." % [joint_id, parent_id])
				return null
			(by_id[parent_id] as ProceduralSquishRig).attach(joint)
		by_id[joint_id] = joint
	return root


## make_backdrop(spec): build a ProceduralBackdropDynamics layer.
##   "seed_id": String        noise stream = derive_seed(seed, seed_id). Required with "field"
##   "variant": int           stream variant, default 0
##   "layer": Layer name      sky | far | mid | near | foreground (default mid)
##   "parallax": float, "stiffness": float, "damping_ratio": float
##   "field": StringName      noise field name (shape | detail | flow | squish), optional
##   "field_amplitude": float
##   "anchors": Array[Vector2]  rest world positions
## Optional: "seed": int (world seed), "phase_speed": float, "wind": Vector2, "wind_gain": float.
## Keep this a thin factory: the motion logic belongs in ProceduralBackdropDynamics.
static func make_backdrop(_spec: Dictionary) -> ProceduralBackdropDynamics:
	var layer_value: int = _backdrop_layer_of(_spec.get("layer", "mid"))
	if layer_value < 0:
		push_error("Procedural.make_backdrop: unknown layer '%s'." % _spec.get("layer"))
		return null
	var layer: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(layer_value)
	layer.configure(
		float(_spec.get("parallax", ProceduralBackdropDynamics.DEFAULT_PARALLAX)),
		float(_spec.get("field_amplitude", 0.0)),
		float(_spec.get("stiffness", ProceduralBackdropDynamics.DEFAULT_STIFFNESS)),
		float(_spec.get("damping_ratio", ProceduralBackdropDynamics.DEFAULT_DAMPING_RATIO))
	)
	var field_name: StringName = StringName(String(_spec.get("field", "")))
	if field_name != &"":
		if not ProceduralNoiseField.PRESETS.has(field_name):
			push_error("Procedural.make_backdrop: unknown noise field '%s'." % field_name)
			return null
		if not _spec.has("seed_id"):
			push_error("Procedural.make_backdrop: a noise field needs 'seed_id'.")
			return null
		var stream: ProceduralSeed = derive_seed(int(_spec.get("seed", 0)), String(_spec["seed_id"]))
		var variant: int = int(_spec.get("variant", 0))
		if variant != 0:
			stream = stream.derive_index(variant)
		layer.attach_field(
			make_noise(stream, field_name),
			float(_spec.get("phase_speed", ProceduralBackdropDynamics.DEFAULT_PHASE_SPEED))
		)
	var anchors: Variant = _spec.get("anchors", [])
	if not (anchors is Array):
		push_error("Procedural.make_backdrop: 'anchors' must be an array of positions.")
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
static func _sprite_builder(spec: Dictionary, caller: String) -> ProceduralCreatureBuilder:
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
	var stream: ProceduralSeed = derive_seed(int(spec.get("seed", 0)), String(spec["seed_id"]))
	var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(
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
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure(raw)
		builder.add_part(part)
	return builder


## render_frame 의 첫 호출: 스프라이트를 한 번 굽고, 밑동(고정)·정수리(soft) 두 관절짜리
## 리그와 (있으면) 배경 레이어를 만든다.
static func _start_frame(spec: Dictionary) -> Dictionary:
	var sprite: Variant = spec.get("sprite", null)
	if not (sprite is Dictionary):
		push_error("Procedural.render_frame: spec needs a 'sprite' build_sprite spec.")
		return {}
	var builder: ProceduralCreatureBuilder = _sprite_builder(sprite, "Procedural.render_frame")
	if builder == null:
		return {}
	if not builder.is_bakeable():
		push_error("Procedural.render_frame: bake refused. points is not invariant.")
		return {}
	var canvas: ProceduralCanvas = builder.compose_canvas()
	var used: Rect2i = canvas.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		push_error("Procedural.render_frame: the sprite baked to an empty canvas.")
		return {}
	var base: Vector2 = Vector2(float(used.position.x) + float(used.size.x) * 0.5, float(used.end.y))
	var crown: Vector2 = Vector2(base.x, float(used.position.y))
	var rig: ProceduralSquishRig = ProceduralSquishRig.new(&"base")
	rig.joint_kind = ProceduralSquishRig.JointKind.PINNED
	rig.rest_position = base
	var top: ProceduralSquishRig = ProceduralSquishRig.new(&"crown")
	top.rest_position = crown - base
	rig.attach(top)
	if rig.to_shape() == null:
		return {}
	var backdrop: ProceduralBackdropDynamics = null
	if spec.has("background"):
		if not (spec["background"] is Dictionary):
			push_error("Procedural.render_frame: 'background' must be a make_backdrop spec.")
			return {}
		backdrop = make_backdrop(spec["background"])
		if backdrop == null:
			return {}
		if backdrop.get_anchor_count() == 0:
			backdrop.set_anchor_capacity(1)
			backdrop.add_anchor(base)
	return {
		"canvas": canvas,
		"frame": ProceduralCanvas.new(canvas.width, canvas.height),
		"used": used,
		"limit": clampf(top.squash, 0.0, ProceduralSquishRig.MAX_SQUASH),
		"rig": rig,
		"backdrop": backdrop,
		"base": base,
		"crown": crown,
	}


## source 를 forward(원본 픽셀 → 대상 픽셀)로 옮겨 target 에 다시 칠한다. 대상 픽셀 중심마다
## 원본을 쌍선형으로 샘플하며 알파 가중 평균이라 가장자리가 검게 번지지 않는다. 색은 source
## 에서만 온다. 원본의 칠해진 영역(used)이 닿을 수 있는 대상 사각형만 돈다.
static func _resample(source: ProceduralCanvas, target: ProceduralCanvas, forward: Transform2D, used: Rect2i) -> void:
	target.clear()
	var reach: Rect2 = ProceduralBodyPart._transformed_rect(forward, Rect2(used).grow(1.0)).grow(1.0)
	var area: Rect2i = Rect2i(
		floori(reach.position.x), floori(reach.position.y),
		ceili(reach.end.x) - floori(reach.position.x), ceili(reach.end.y) - floori(reach.position.y)
	).intersection(Rect2i(0, 0, target.width, target.height))
	if area.size.x <= 0 or area.size.y <= 0:
		return
	var inverse: Transform2D = forward.affine_inverse()
	var src: PackedByteArray = source.pixels
	var out: PackedByteArray = target.pixels
	var source_width: int = source.width
	var source_height: int = source.height
	var stride: int = source_width * 4
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			var at: Vector2 = inverse * Vector2(float(x) + 0.5, float(y) + 0.5) - Vector2(0.5, 0.5)
			var x0: int = floori(at.x)
			var y0: int = floori(at.y)
			if x0 < -1 or y0 < -1 or x0 >= source_width or y0 >= source_height:
				continue
			var has_left: bool = x0 >= 0
			var has_right: bool = x0 + 1 < source_width
			var has_top: bool = y0 >= 0
			var has_bottom: bool = y0 + 1 < source_height
			var i00: int = y0 * stride + x0 * 4
			var i10: int = i00 + 4
			var i01: int = i00 + stride
			var i11: int = i01 + 4
			var a00: float = float(src[i00 + 3]) if has_left and has_top else 0.0
			var a10: float = float(src[i10 + 3]) if has_right and has_top else 0.0
			var a01: float = float(src[i01 + 3]) if has_left and has_bottom else 0.0
			var a11: float = float(src[i11 + 3]) if has_right and has_bottom else 0.0
			if a00 + a10 + a01 + a11 <= 0.0:
				continue
			var tx: float = at.x - float(x0)
			var ty: float = at.y - float(y0)
			var w00: float = (1.0 - tx) * (1.0 - ty) * a00
			var w10: float = tx * (1.0 - ty) * a10
			var w01: float = (1.0 - tx) * ty * a01
			var w11: float = tx * ty * a11
			var alpha: float = w00 + w10 + w01 + w11
			if alpha < 0.5:
				continue
			var index: int = (y * target.width + x) * 4
			for channel: int in 3:
				var mixed: float = 0.0
				if w00 > 0.0:
					mixed += float(src[i00 + channel]) * w00
				if w10 > 0.0:
					mixed += float(src[i10 + channel]) * w10
				if w01 > 0.0:
					mixed += float(src[i01 + channel]) * w01
				if w11 > 0.0:
					mixed += float(src[i11 + channel]) * w11
				out[index + channel] = clampi(roundi(mixed / alpha), 0, 255)
			out[index + 3] = clampi(roundi(alpha), 0, 255)
	target.pixels = out


static func _joint_kind_of(raw: Variant) -> int:
	if raw is int or raw is float:
		var number: int = int(raw)
		return number if number >= 0 and number <= ProceduralSquishRig.JointKind.PINNED else -1
	match String(raw).to_lower():
		"rigid":
			return ProceduralSquishRig.JointKind.RIGID
		"soft":
			return ProceduralSquishRig.JointKind.SOFT
		"pinned":
			return ProceduralSquishRig.JointKind.PINNED
		_:
			return -1


static func _backdrop_layer_of(raw: Variant) -> int:
	if raw is int or raw is float:
		var number: int = int(raw)
		return number if number >= 0 and number <= ProceduralBackdropDynamics.Layer.FOREGROUND else -1
	match String(raw).to_lower():
		"sky":
			return ProceduralBackdropDynamics.Layer.SKY
		"far":
			return ProceduralBackdropDynamics.Layer.FAR
		"mid":
			return ProceduralBackdropDynamics.Layer.MID
		"near":
			return ProceduralBackdropDynamics.Layer.NEAR
		"foreground":
			return ProceduralBackdropDynamics.Layer.FOREGROUND
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
