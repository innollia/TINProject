class_name TopDownActionRpgVectorLayer
extends Control

const BASE_SIZE: Vector2 = Vector2(1280.0, 720.0)
const WORLD_ORIGIN: Vector2 = Vector2(640.0, 418.0)
const WORLD_SPAN: Vector2 = Vector2(1000.0, 620.0)
const WORLD_SCALE_CAP: float = 240.0
const STAGE_RECT: Rect2 = Rect2(280.0, 32.0, 960.0, 520.0)
const STAGE_FOCAL: Vector2 = Vector2(760.0, 290.0)
const TIMING_BAR: Rect2 = Rect2(520.0, 464.0, 480.0, 12.0)
const CONDITION_BAR: Rect2 = Rect2(520.0, 486.0, 480.0, 8.0)
const BAR_LINE: float = 2.0
const STAGE_BORDER: float = 1.0
const FOCUS_LINE: float = 2.0
const STRUCTURE_LINE: float = 1.0

const COLOR_GROUND: Color = Color("0a0d11")
const COLOR_PLATE: Color = Color("111720")
const COLOR_PLATE_DEEP: Color = Color("0d1219")
const COLOR_STRUCTURE: Color = Color("39424f")
const COLOR_STRUCTURE_SOFT: Color = Color("232b35")
const COLOR_INK: Color = Color("cdc8bc")
const COLOR_MUTED: Color = Color("6d7580")
const COLOR_FOCUS: Color = Color("e8e4d9")
const COLOR_TRACE: Color = Color("8a7a58")
const COLOR_TIMING: Color = Color("5f9a5c")
const COLOR_CONDITION: Color = Color("bdb6a4")
const COLOR_ENEMY: Color = Color("7d8592")
const COLOR_ALLY: Color = Color("8b8f86")

const MODE_FIELD: String = "field"
const MODE_COMBAT: String = "combat"

@export var mode: String = MODE_FIELD
var dim_ratio: float = 0.0
var timing_ratio: float = 0.0
var timing_ready: bool = true
var condition_ratio: float = 1.0
var condition_ratio_injected: bool = false
var feedback: Array = []

var _markers: Array = []
var _player_position: Vector2 = Vector2.ZERO
var _player_facing: int = 0
var _player_serial: int = 0
var _topology: String = ""
var _region_serial: int = 0
var _actors: Array = []
var _selected_actor_ids: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(false)


func set_field_model(model: Dictionary) -> void:
	_markers = model.get("markers", []) if model.get("markers", []) is Array else []
	_player_position = model.get("player_position", Vector2.ZERO) if model.get("player_position", Vector2.ZERO) is Vector2 else Vector2.ZERO
	_player_facing = int(model.get("player_facing", 0))
	_player_serial = int(model.get("player_serial", 0))
	_topology = String(model.get("topology", ""))
	_region_serial = int(model.get("region_serial", 0))
	queue_redraw()


func set_combat_model(model: Dictionary) -> void:
	_actors = model.get("actors", []) if model.get("actors", []) is Array else []
	_selected_actor_ids = model.get("selected_actor_ids", []) if model.get("selected_actor_ids", []) is Array else []
	timing_ratio = clampf(float(model.get("timing_ratio", 0.0)), 0.0, 1.0)
	timing_ready = bool(model.get("timing_ready", true))
	condition_ratio = clampf(float(model.get("condition_ratio", 1.0)), 0.0, 1.0)
	condition_ratio_injected = bool(model.get("condition_ratio_injected", false))
	feedback = model.get("feedback", []) if model.get("feedback", []) is Array else []
	queue_redraw()


func set_dim_ratio(value: float) -> void:
	var next_ratio: float = clampf(value, 0.0, 0.92)
	if is_equal_approx(next_ratio, dim_ratio):
		return
	dim_ratio = next_ratio
	queue_redraw()


func _draw() -> void:
	if mode == MODE_COMBAT:
		_draw_combat()
	else:
		_draw_field()
	if dim_ratio > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.04, dim_ratio), true)


func _scale_factor() -> Vector2:
	if size.x <= 0.0 or size.y <= 0.0:
		return Vector2.ONE
	return Vector2(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)


func _stable_hash(text: String) -> int:
	var value: int = 2166136261
	for index: int in range(text.length()):
		value = (value ^ text.unicode_at(index)) & 0xFFFFFFFF
		value = (value * 16777619) & 0xFFFFFFFF
	return value


func _base_to_local(point: Vector2) -> Vector2:
	return point * _scale_factor()


func _base_rect_to_local(bounds: Rect2) -> Rect2:
	return Rect2(_base_to_local(bounds.position), bounds.size * _scale_factor())


func _draw_field() -> void:
	var frame: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(frame, COLOR_GROUND, true)
	var unit: Vector2 = _scale_factor()
	_draw_topology(unit)
	var mapping: Dictionary = _world_mapping()
	for entry: Dictionary in _markers:
		var world_position: Variant = entry.get("position", Vector2.ZERO)
		if not world_position is Vector2:
			continue
		var point: Vector2 = _screen_point(mapping, world_position)
		var radius: float = (mapping["scale"] as float) * 0.18
		_draw_marker(point, radius, entry)
	_draw_player()
	_draw_passage_reach(mapping)
	_feedback_layer(unit)


func _draw_topology(unit: Vector2) -> void:
	var ring_count: int = 2 + _stable_hash(_topology) % 3
	var bar_count: int = 3 + _stable_hash(_topology + "bar") % 4
	var offset: int = _stable_hash(_topology + "offset") % 3
	var center: Vector2 = _base_to_local(WORLD_ORIGIN)
	var span: float = 150.0 * unit.x
	for ring: int in range(ring_count):
		var radius: float = span * (0.45 + 0.24 * float(ring + offset))
		draw_arc(center, radius, 0.0, TAU, 48, COLOR_PLATE, 1.0, true)
	var half: float = span * 0.98
	for bar: int in range(bar_count):
		var y: float = center.y - half * 0.72 + (half * 1.44) * (float(bar) / maxf(1.0, float(bar_count - 1)))
		var start: float = center.x - half * (0.36 + 0.12 * float((bar + offset) % 3))
		draw_line(Vector2(start, y), Vector2(center.x + half * 0.86, y), COLOR_PLATE, 1.0, true)
	var well: Vector2 = center + Vector2(half * 0.34, -half * 0.16)
	draw_circle(well, span * 0.16, COLOR_PLATE_DEEP)
	draw_arc(well, span * 0.16, 0.0, TAU, 32, COLOR_STRUCTURE_SOFT, 1.0, true)
	draw_arc(center, span * 0.2, 0.0, TAU, 32, COLOR_STRUCTURE_SOFT, 1.0, true)


func _world_mapping() -> Dictionary:
	var minimum: Vector2 = _player_position
	var maximum: Vector2 = _player_position
	var count: int = 0
	for entry: Dictionary in _markers:
		var world_position: Variant = entry.get("position", Vector2.ZERO)
		if not world_position is Vector2:
			continue
		var point: Vector2 = world_position
		minimum.x = minf(minimum.x, point.x)
		minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x)
		maximum.y = maxf(maximum.y, point.y)
		count += 1
	var span: Vector2 = maximum - minimum
	if span.x < 0.5:
		span.x = 0.5
	if span.y < 0.5:
		span.y = 0.5
	var unit: Vector2 = _scale_factor()
	var target: Vector2 = WORLD_SPAN * unit
	var factor: float = minf(target.x / span.x, target.y / span.y)
	factor = minf(factor, WORLD_SCALE_CAP * unit.x)
	if count == 0:
		factor = WORLD_SCALE_CAP * unit.x
	var origin: Vector2 = (minimum + maximum) * 0.5
	var anchor: Vector2 = _base_to_local(WORLD_ORIGIN)
	return {"scale": factor, "origin": origin, "anchor": anchor}


func _screen_point(mapping: Dictionary, world_position: Vector2) -> Vector2:
	var factor: float = mapping["scale"] as float
	var origin: Vector2 = mapping["origin"] as Vector2
	var anchor: Vector2 = mapping["anchor"] as Vector2
	return anchor + (world_position - origin) * factor


func _draw_marker(point: Vector2, radius: float, entry: Dictionary) -> void:
	var marker_radius: float = clampf(radius, 10.0 * _scale_factor().x, 34.0 * _scale_factor().x)
	var variant: String = String(entry.get("variant", "normal"))
	var kind: String = String(entry.get("kind", ""))
	var focused: bool = bool(entry.get("focused", false))
	var disabled: bool = bool(entry.get("disabled", false))
	var bounds: Rect2 = Rect2(point - Vector2(marker_radius, marker_radius) * 0.72, Vector2(marker_radius, marker_radius) * 1.44)
	if variant == "absent":
		draw_rect(bounds, COLOR_MUTED, false, STRUCTURE_LINE)
		_dashed_rect(bounds, COLOR_STRUCTURE, STRUCTURE_LINE, 5.0)
		return
	var body: Color = COLOR_PLATE_DEEP
	var outline: Color = COLOR_STRUCTURE
	if variant == "changed":
		body = Color("161611")
		outline = COLOR_TRACE
	elif variant == "used":
		outline = COLOR_STRUCTURE_SOFT
	draw_rect(bounds, body, true)
	draw_rect(bounds, outline, false, STRUCTURE_LINE)
	_draw_kind_glyph(point, marker_radius, kind)
	if variant == "changed":
		draw_line(bounds.position + Vector2(-marker_radius * 0.9, bounds.size.y * 0.5), bounds.position + Vector2(-marker_radius * 0.2, bounds.size.y * 0.5), COLOR_TRACE, FOCUS_LINE, true)
	if variant == "used":
		draw_line(bounds.position + Vector2(2.0, bounds.size.y * 0.5), bounds.position + Vector2(bounds.size.x - 2.0, bounds.size.y * 0.5), COLOR_TRACE, STRUCTURE_LINE, true)
	if focused:
		var focus_bounds: Rect2 = bounds.grow(4.0)
		draw_rect(focus_bounds, COLOR_FOCUS, false, FOCUS_LINE)
		_draw_focus_marker(focus_bounds)
	if disabled:
		draw_line(bounds.position + Vector2(2.0, bounds.size.y * 0.5), bounds.position + Vector2(bounds.size.x - 2.0, bounds.size.y * 0.5), COLOR_MUTED, STRUCTURE_LINE, true)


func _draw_kind_glyph(point: Vector2, radius: float, kind: String) -> void:
	match kind:
		"npc":
			draw_circle(point + Vector2(0.0, -radius * 0.28), radius * 0.24, COLOR_INK)
			draw_arc(point + Vector2(0.0, radius * 0.34), radius * 0.44, PI, TAU, 18, COLOR_INK, STRUCTURE_LINE + 1.0, true)
		"passage":
			draw_polyline(PackedVector2Array([point + Vector2(-radius * 0.4, -radius * 0.5), point + Vector2(-radius * 0.1, 0.0), point + Vector2(-radius * 0.4, radius * 0.5)]), COLOR_INK, STRUCTURE_LINE + 1.0, true)
			draw_polyline(PackedVector2Array([point + Vector2(radius * 0.4, -radius * 0.5), point + Vector2(radius * 0.1, 0.0), point + Vector2(radius * 0.4, radius * 0.5)]), COLOR_INK, STRUCTURE_LINE + 1.0, true)
		"terminal", "shop", "chest":
			draw_rect(Rect2(point - Vector2(radius * 0.42, radius * 0.3), Vector2(radius * 0.84, radius * 0.6)), COLOR_INK, false, STRUCTURE_LINE + 1.0)
			draw_line(point - Vector2(radius * 0.42, 0.0), point + Vector2(radius * 0.42, 0.0), COLOR_INK, STRUCTURE_LINE, true)
		"key", "pickup":
			draw_arc(point, radius * 0.3, 0.0, TAU, 18, COLOR_INK, STRUCTURE_LINE + 1.0, true)
			draw_line(point + Vector2(radius * 0.3, 0.0), point + Vector2(radius * 0.66, 0.0), COLOR_INK, STRUCTURE_LINE + 1.0, true)
		"lever", "hazard", "corpse":
			draw_polyline(PackedVector2Array([point + Vector2(-radius * 0.5, radius * 0.4), point + Vector2(0.0, -radius * 0.4), point + Vector2(radius * 0.5, radius * 0.4)]), COLOR_INK, STRUCTURE_LINE + 1.0, true)
		_:
			draw_polyline(PackedVector2Array([point + Vector2(0.0, -radius * 0.42), point + Vector2(radius * 0.42, 0.0), point + Vector2(0.0, radius * 0.42), point + Vector2(-radius * 0.42, 0.0)]), COLOR_INK, STRUCTURE_LINE + 1.0, true)


func _draw_focus_marker(bounds: Rect2) -> void:
	var tip: Vector2 = bounds.position + Vector2(-7.0, bounds.size.y * 0.5)
	draw_colored_polygon(PackedVector2Array([tip + Vector2(-6.0, 0.0), tip + Vector2(0.0, -6.0), tip + Vector2(0.0, 6.0)]), COLOR_FOCUS)
	var corner: Vector2 = bounds.position + Vector2(bounds.size.x, bounds.size.y)
	draw_arc(corner, 9.0, PI, PI * 1.5, 12, COLOR_FOCUS, FOCUS_LINE, true)


func _dashed_rect(bounds: Rect2, color: Color, width: float, dash: float) -> void:
	var top_left: Vector2 = bounds.position
	var top_right: Vector2 = bounds.position + Vector2(bounds.size.x, 0.0)
	var bottom_right: Vector2 = bounds.position + bounds.size
	var bottom_left: Vector2 = bounds.position + Vector2(0.0, bounds.size.y)
	draw_dashed_line(top_left, top_right, color, width, dash)
	draw_dashed_line(top_right, bottom_right, color, width, dash)
	draw_dashed_line(bottom_right, bottom_left, color, width, dash)
	draw_dashed_line(bottom_left, top_left, color, width, dash)


func _draw_player() -> void:
	var unit: Vector2 = _scale_factor()
	var anchor: Vector2 = _base_to_local(WORLD_ORIGIN)
	var body: float = 26.0 * unit.x
	var direction: Vector2 = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][clampi(_player_facing, 0, 3)]
	var forward: Vector2 = direction.orthogonal().rotated(PI * 0.5) * body * 0.5
	var side: Vector2 = direction.orthogonal() * body * 0.34
	var hull: PackedVector2Array = PackedVector2Array([
		anchor + forward,
		anchor + side,
		anchor - forward * 0.7,
		anchor - side,
	])
	draw_colored_polygon(hull, COLOR_PLATE_DEEP)
	draw_polyline(PackedVector2Array([hull[0], hull[1], hull[2], hull[3], hull[0]]), COLOR_FOCUS, FOCUS_LINE, true)
	draw_line(anchor, anchor + forward * 0.7, COLOR_FOCUS, STRUCTURE_LINE, true)
	draw_arc(anchor, body * 0.9, 0.0, TAU, 28, COLOR_STRUCTURE_SOFT, STRUCTURE_LINE, true)
	if _player_serial % 2 == 0:
		draw_arc(anchor, body * 1.14, 0.0, TAU, 28, COLOR_STRUCTURE_SOFT, STRUCTURE_LINE, true)


func _draw_passage_reach(mapping: Dictionary) -> void:
	var unit: Vector2 = _scale_factor()
	var anchor: Vector2 = mapping["anchor"] as Vector2
	var reach: float = 96.0 * unit.x * clampf(mapping["scale"] as float / maxf(1.0, WORLD_SCALE_CAP * unit.x), 0.35, 1.0)
	draw_arc(anchor, reach, 0.0, TAU, 40, COLOR_STRUCTURE_SOFT, STRUCTURE_LINE, true)


func _feedback_layer(unit: Vector2) -> void:
	if feedback.is_empty():
		return
	var mapping: Dictionary = _world_mapping()
	for entry: Dictionary in feedback:
		var world_position: Variant = entry.get("position", Vector2.ZERO)
		var point: Vector2 = mapping["anchor"] as Vector2
		if world_position is Vector2:
			point = _base_to_local(world_position)
		var strength: float = clampf(float(entry.get("strength", 1.0)), 0.0, 1.0)
		_draw_feedback_mark(point, String(entry.get("kind", "")), strength, unit)


func _draw_feedback_mark(point: Vector2, kind: String, strength: float, unit: Vector2) -> void:
	var reach: float = (18.0 + 26.0 * strength) * unit.x
	match kind:
		"hit":
			for offset: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
				draw_line(point + offset * reach * 0.7, point + offset * reach * 1.2, COLOR_INK, FOCUS_LINE, true)
		"miss":
			draw_arc(point + Vector2(-reach * 0.3, 0.0), reach * 0.7, -0.8, 0.8, 14, COLOR_MUTED, STRUCTURE_LINE, true)
			draw_arc(point + Vector2(reach * 0.3, 0.0), reach * 0.7, PI - 0.8, PI + 0.8, 14, COLOR_MUTED, STRUCTURE_LINE, true)
		"critical":
			draw_polyline(PackedVector2Array([point + Vector2(-reach * 0.5, reach * 0.3), point + Vector2(0.0, -reach * 0.4), point + Vector2(reach * 0.5, reach * 0.3)]), COLOR_FOCUS, FOCUS_LINE, true)
			draw_polyline(PackedVector2Array([point + Vector2(-reach * 0.5, reach * 0.6), point + Vector2(0.0, -reach * 0.1), point + Vector2(reach * 0.5, reach * 0.6)]), COLOR_FOCUS, STRUCTURE_LINE, true)
		"guard":
			draw_arc(point, reach * 1.1, -PI * 0.85, -PI * 0.15, 18, COLOR_INK, FOCUS_LINE, true)
			draw_arc(point, reach * 1.1, PI * 0.15, PI * 0.85, 18, COLOR_INK, FOCUS_LINE, true)
		"dodge":
			draw_line(point + Vector2(-reach * 0.8, -reach * 0.5), point + Vector2(reach * 0.8, -reach * 0.5), COLOR_INK, FOCUS_LINE, true)
			draw_line(point + Vector2(-reach * 0.8, reach * 0.5), point + Vector2(reach * 0.8, reach * 0.5), COLOR_INK, FOCUS_LINE, true)
		"break":
			var broken: Rect2 = Rect2(point - Vector2(reach, reach * 0.8), Vector2(reach * 2.0, reach * 1.6))
			_dashed_rect(broken, COLOR_FOCUS, FOCUS_LINE, 7.0)
			draw_line(broken.position + Vector2(broken.size.x * 0.42, 0.0), broken.position + Vector2(broken.size.x * 0.58, broken.size.y), COLOR_FOCUS, FOCUS_LINE, true)
		"status":
			for index: int in range(3):
				var cell: Vector2 = point + Vector2(float(index) * 9.0 * unit.x - 9.0 * unit.x, 0.0)
				draw_rect(Rect2(cell - Vector2(4.0, 4.0) * unit.x, Vector2(8.0, 8.0) * unit.x), COLOR_INK, false, STRUCTURE_LINE)
		"queued":
			_dashed_rect(Rect2(point - Vector2(reach, reach), Vector2(reach * 2.0, reach * 2.0)), COLOR_FOCUS, STRUCTURE_LINE, 9.0)


func _draw_combat() -> void:
	var unit: Vector2 = _scale_factor()
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_GROUND, true)
	var stage: Rect2 = _base_rect_to_local(STAGE_RECT)
	draw_rect(stage, COLOR_PLATE_DEEP, true)
	draw_rect(stage, COLOR_STRUCTURE_SOFT, false, STAGE_BORDER)
	draw_line(stage.position + Vector2(0.0, stage.size.y * 0.72), stage.position + Vector2(stage.size.x, stage.size.y * 0.72), COLOR_STRUCTURE_SOFT, STAGE_BORDER, true)
	for entry: Dictionary in _actors:
		_draw_actor(entry, unit)
	_draw_bars(unit)
	_feedback_layer(unit)


func _draw_actor(entry: Dictionary, unit: Vector2) -> void:
	var point: Vector2 = _base_to_local(entry.get("position", STAGE_FOCAL) if entry.get("position", STAGE_FOCAL) is Vector2 else STAGE_FOCAL)
	var focused: bool = bool(entry.get("focused", false))
	var alive: bool = bool(entry.get("alive", true))
	var stance: String = String(entry.get("stance", "normal"))
	var body: Color = COLOR_ENEMY if String(entry.get("side", "enemy_side")) == "enemy_side" else COLOR_ALLY
	var scale: float = clampf(float(entry.get("body_scale", 1.0)), 0.6, 1.6)
	var radius: float = 58.0 * scale * unit.x
	var bounds: Rect2 = Rect2(point - Vector2(radius * 0.7, radius), Vector2(radius * 1.4, radius * 2.0))
	if not alive:
		_dashed_rect(bounds, COLOR_MUTED, STRUCTURE_LINE, 6.0)
		draw_line(bounds.position, bounds.position + bounds.size, COLOR_STRUCTURE, STRUCTURE_LINE, true)
		return
	var hull: PackedVector2Array = _body_hull(point, radius, int(entry.get("serial", 0)))
	draw_colored_polygon(hull, COLOR_PLATE_DEEP)
	draw_polyline(PackedVector2Array([hull[0], hull[1], hull[2], hull[3], hull[4], hull[0]]), body, FOCUS_LINE, true)
	draw_line(point - Vector2(radius * 0.4, radius * 0.2), point + Vector2(radius * 0.4, radius * 0.2), body, STRUCTURE_LINE, true)
	if stance == "guard" or stance == "guard_broken":
		draw_arc(point, radius * 1.24, -PI * 0.85, -PI * 0.15, 18, COLOR_INK, FOCUS_LINE, true)
		draw_arc(point, radius * 1.24, PI * 0.15, PI * 0.85, 18, COLOR_INK, FOCUS_LINE, true)
	if stance == "dodge":
		draw_arc(point - Vector2(radius * 0.9, 0.0), radius * 0.8, -PI * 0.6, PI * 0.6, 16, COLOR_INK, FOCUS_LINE, true)
	if stance == "broken":
		_dashed_rect(bounds, COLOR_FOCUS, FOCUS_LINE, 7.0)
	_draw_charge_tell(entry, point, radius, unit)
	if focused:
		var bracket: Rect2 = bounds.grow(10.0 * unit.x)
		_draw_target_bracket(bracket)
	if _selected_actor_ids.has(StringName(String(entry.get("actor_id", "")))):
		draw_arc(point, radius * 1.5, 0.0, TAU, 40, COLOR_FOCUS, STRUCTURE_LINE, true)


func _body_hull(point: Vector2, radius: float, serial: int) -> PackedVector2Array:
	var variant: int = serial % 3
	var top: Vector2 = point + Vector2(0.0, -radius)
	var bottom: Vector2 = point + Vector2(0.0, radius)
	match variant:
		0:
			return PackedVector2Array([top, point + Vector2(radius * 0.7, -radius * 0.2), point + Vector2(radius * 0.5, radius * 0.8), bottom, point + Vector2(-radius * 0.5, radius * 0.8), point + Vector2(-radius * 0.7, -radius * 0.2)])
		1:
			return PackedVector2Array([top, point + Vector2(radius * 0.9, -radius * 0.6), point + Vector2(radius * 0.3, radius * 0.9), bottom, point + Vector2(-radius * 0.3, radius * 0.9), point + Vector2(-radius * 0.9, -radius * 0.6)])
		_:
			return PackedVector2Array([top, point + Vector2(radius * 0.55, -radius * 0.5), point + Vector2(radius * 0.95, radius * 0.5), bottom, point + Vector2(-radius * 0.95, radius * 0.5), point + Vector2(-radius * 0.55, -radius * 0.5)])


func _draw_charge_tell(entry: Dictionary, point: Vector2, radius: float, unit: Vector2) -> void:
	var stage: String = String(entry.get("charge_stage", ""))
	if stage.is_empty() or stage == "cancelled" or stage == "completed":
		return
	var thickness: float = FOCUS_LINE
	match stage:
		"telegraph":
			draw_arc(point, radius * 1.36, -PI * 0.5, PI * 0.5, 24, COLOR_FOCUS, STRUCTURE_LINE, true)
		"reaction":
			thickness = FOCUS_LINE + 1.0
			draw_arc(point, radius * 1.36, 0.0, TAU, 40, COLOR_FOCUS, thickness, true)
		_:
			draw_colored_polygon(PackedVector2Array([point + Vector2(0.0, -radius * 1.5), point + Vector2(radius * 0.8, -radius * 0.4), point + Vector2(-radius * 0.8, -radius * 0.4)]), COLOR_FOCUS)


func _draw_target_bracket(bounds: Rect2) -> void:
	var arm: float = minf(bounds.size.x, bounds.size.y) * 0.28
	var corners: Array[Vector2] = [
		bounds.position,
		bounds.position + Vector2(bounds.size.x, 0.0),
		bounds.position + bounds.size,
		bounds.position + Vector2(0.0, bounds.size.y),
	]
	var axes: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	for index: int in range(4):
		var corner: Vector2 = corners[index]
		var first: Vector2 = axes[index]
		var second: Vector2 = axes[(index + 1) % 4]
		draw_line(corner, corner + first * arm, COLOR_FOCUS, FOCUS_LINE, true)
		draw_line(corner, corner + second * arm, COLOR_FOCUS, FOCUS_LINE, true)
	draw_rect(Rect2(bounds.get_center() - Vector2(7.0, 7.0), Vector2(14.0, 14.0)), COLOR_FOCUS, false, STRUCTURE_LINE)


func _draw_bars(unit: Vector2) -> void:
	var timing: Rect2 = _base_rect_to_local(TIMING_BAR)
	draw_rect(timing, COLOR_PLATE_DEEP, true)
	draw_rect(timing, COLOR_STRUCTURE, false, BAR_LINE)
	var fill: float = timing.size.x * timing_ratio
	if timing_ready:
		draw_rect(Rect2(timing.position, Vector2(maxf(fill, timing.size.y), timing.size.y)), COLOR_TIMING, true)
		draw_rect(Rect2(timing.position - Vector2(0.0, 6.0 * unit.y), Vector2(timing.size.y, timing.size.y + 12.0 * unit.y)), COLOR_TIMING, false, FOCUS_LINE)
	else:
		draw_rect(Rect2(timing.position + Vector2(0.0, timing.size.y * 0.25), Vector2(fill, timing.size.y * 0.5)), COLOR_TIMING, true)
	var condition: Rect2 = _base_rect_to_local(CONDITION_BAR)
	draw_rect(condition, COLOR_PLATE_DEEP, true)
	draw_rect(condition, COLOR_STRUCTURE, false, BAR_LINE)
	if condition_ratio > 0.0:
		draw_rect(Rect2(condition.position, Vector2(condition.size.x * condition_ratio, condition.size.y)), COLOR_CONDITION, true)
	if not condition_ratio_injected:
		draw_dashed_line(condition.position + Vector2(condition.size.x * 0.25, condition.size.y * 0.5), condition.position + Vector2(condition.size.x * 0.25, condition.size.y * 1.6), COLOR_STRUCTURE, STRUCTURE_LINE, 4.0)
