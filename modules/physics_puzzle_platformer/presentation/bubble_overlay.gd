extends Control

const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")
const ProceduralBridge = preload("res://modules/physics_puzzle_platformer/presentation/procedural_bridge.gd")

const PATTERN_SPEED: Vector2 = Vector2(18.0, -11.0)
const TILE: int = 24
const RISE_DISTANCE: float = 0.55
const TRACE_ALPHA: float = 0.35

var bubble: RefCounted
var glyphs: Dictionary = {}
var rings: Dictionary = {}
var traces: Dictionary = {}
var _roles: Dictionary = {}
var _tile: Texture2D
var _ring_texture: Texture2D
var _trace_texture: Texture2D
var _scroll: Vector2 = Vector2.ZERO
var _time: float = 0.0


func _ready() -> void:
	name = "BubbleOverlay"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	visible = false
	resized.connect(_layout)


func setup(bubble_state: RefCounted, roles: Dictionary) -> void:
	bubble = bubble_state
	_roles = roles
	_tile = ProceduralBridge.pattern_tile(TILE, 2.0, roles[&"bg_near"])
	_ring_texture = ProceduralBridge.ring_texture(30.0, 3.0, roles[&"ink"])
	_trace_texture = ProceduralBridge.wedge_texture(30.0, 7, roles[&"ink_dim"])
	for action: String in InputBubble.PROFILE:
		if glyphs.has(action):
			continue
		var ring := TextureRect.new()
		ring.name = "Ring_" + action
		ring.texture = _ring_texture
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.stretch_mode = TextureRect.STRETCH_SCALE
		ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(ring)
		rings[action] = ring
		var trace := TextureRect.new()
		trace.name = "Trace_" + action
		trace.texture = _trace_texture
		trace.mouse_filter = Control.MOUSE_FILTER_IGNORE
		trace.stretch_mode = TextureRect.STRETCH_SCALE
		trace.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		add_child(trace)
		traces[action] = trace
		var label := Label.new()
		label.name = "Key_" + action
		label.text = key_glyph(action)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_color_override("font_color", roles[&"ink"])
		add_child(label)
		glyphs[action] = label
	for action: Variant in glyphs:
		(glyphs[action] as Label).add_theme_color_override("font_color", roles[&"ink"])
	_layout()


static func key_glyph(action: String) -> String:
	if not InputMap.has_action(action):
		return ""
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key := event as InputEventKey
			var code: Key = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
			return OS.get_keycode_string(code)
	return ""


func refresh(delta: float) -> void:
	var active: bool = bubble != null and bubble.active
	if active != visible:
		visible = active
		if active:
			focus_mode = Control.FOCUS_ALL
			if is_inside_tree():
				grab_focus()
		else:
			if has_focus():
				release_focus()
			focus_mode = Control.FOCUS_NONE
	if not visible:
		return
	_time += delta
	_scroll = (_scroll + PATTERN_SPEED * delta).posmod(float(TILE))
	_layout()
	queue_redraw()


func cell_center(cell: Vector2i) -> Vector2:
	var unit: float = _unit()
	var columns: int = InputBubble.GRID_COLUMNS
	var origin := Vector2(size.x * 0.5 - unit * float(columns - 1) * 0.5, size.y * 0.5 - unit * 0.5)
	return origin + Vector2(cell) * unit


func _unit() -> float:
	return minf(size.x, size.y) * 0.17


func _layout() -> void:
	if bubble == null:
		return
	var unit: float = _unit()
	var diameter: float = unit * 0.8
	for action: Variant in glyphs:
		var key: String = String(action)
		var cell: Vector2i = bubble.get_bubble_cell(key)
		var center: Vector2 = cell_center(cell)
		var state: String = String(bubble.get_bubble_state(key))
		var progress: float = float(bubble.bubble_progress.get(key, 1.0))
		var ring: TextureRect = rings[key]
		var trace: TextureRect = traces[key]
		var label: Label = glyphs[key]
		var lift: float = 0.0
		var grow: float = 1.0
		match state:
			InputBubble.STATE_RISING:
				lift = (1.0 - ease(progress, 0.4)) * size.y * RISE_DISTANCE
			InputBubble.STATE_RESTORING:
				grow = lerpf(0.6, 1.0, progress)
			InputBubble.STATE_INTACT:
				lift = sin(_time * 2.4 + float(cell.x) * 1.3) * unit * 0.03
		var at: Vector2 = center + Vector2(0.0, lift)
		var side: float = diameter * grow
		ring.visible = state != InputBubble.STATE_POPPED
		ring.size = Vector2(side, side)
		ring.position = at - ring.size * 0.5
		var absorbed: float = float(bubble.absorption.get(key, 1.0))
		trace.visible = state == InputBubble.STATE_POPPED
		var trace_side: float = diameter * lerpf(1.25, 1.0, absorbed)
		trace.size = Vector2(trace_side, trace_side)
		trace.position = center - trace.size * 0.5
		trace.modulate.a = lerpf(1.0, TRACE_ALPHA, absorbed)
		label.add_theme_font_size_override("font_size", maxi(int(diameter * 0.3), 10))
		label.size = Vector2(diameter, diameter * 0.5)
		label.position = at - label.size * 0.5
		label.modulate.a = TRACE_ALPHA if state == InputBubble.STATE_POPPED else 1.0


func _draw() -> void:
	if not visible or _roles.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), _roles[&"base"])
	if _tile != null:
		draw_set_transform(-_scroll, 0.0, Vector2.ONE)
		draw_texture_rect(_tile, Rect2(Vector2.ZERO, size + Vector2(TILE, TILE) * 2.0), true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
