extends Node2D

const CHARGE_SCALE_MAX: float = 1.28
const SQUASH_STIFFNESS: float = 180.0
const SQUASH_DAMPING: float = 0.5
const SQUASH_LIMIT: float = 0.22
const CHARGE_RELEASE_TIME: float = 0.16
const DOT_PULSE_SPEED: float = 9.0

var kind: int = 0
var spec_id: String = ""
var size: Vector2 = Vector2.ONE
var style: StyleBoxTexture
var body_sprite: Sprite2D
var tool_sprite: Sprite2D
var hold_dot: Sprite2D
var fill_ratio: float = 0.0
var wedges: Array[Sprite2D] = []
var ring: Sprite2D
var charge_display: float = 0.0
var _squash: ProceduralSpring = ProceduralSpring.under_damped(0.0, SQUASH_STIFFNESS, SQUASH_DAMPING)
var _charge: ProceduralSpring = ProceduralSpring.under_damped(0.0, SQUASH_STIFFNESS, SQUASH_DAMPING)
var _dot_phase: float = 0.0


static func charge_scale(fraction: float) -> float:
	return 1.0 + (CHARGE_SCALE_MAX - 1.0) * clampf(fraction, 0.0, 1.0)


func setup_style(value: StyleBoxTexture, body_size: Vector2) -> void:
	style = value
	size = body_size
	queue_redraw()


func setup_texture(texture: Texture2D, body_size: Vector2) -> void:
	size = body_size
	body_sprite = Sprite2D.new()
	body_sprite.name = "Body"
	body_sprite.texture = texture
	body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(body_sprite)


func setup_player_tool(dot: Texture2D) -> void:
	tool_sprite = Sprite2D.new()
	tool_sprite.name = "Tool"
	tool_sprite.visible = false
	tool_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(tool_sprite)
	hold_dot = Sprite2D.new()
	hold_dot.name = "HoldDot"
	hold_dot.texture = dot
	hold_dot.visible = false
	add_child(hold_dot)


func setup_rift(ring_texture: Texture2D, wedge_texture: Texture2D, segments: int) -> void:
	ring = Sprite2D.new()
	ring.name = "Ring"
	ring.texture = ring_texture
	add_child(ring)
	var count: int = maxi(segments, 1)
	for index: int in count:
		var wedge := Sprite2D.new()
		wedge.name = "Wedge%d" % index
		wedge.texture = wedge_texture
		wedge.rotation = TAU * float(index) / float(count)
		wedge.self_modulate.a = 0.22
		add_child(wedge)
		wedges.append(wedge)


func set_fill(count: int, needed: int, open: bool) -> void:
	fill_ratio = clampf(float(count) / float(maxi(needed, 1)), 0.0, 1.0)
	for index: int in wedges.size():
		wedges[index].self_modulate.a = 1.0 if index < count else 0.22
	if ring != null:
		ring.self_modulate.a = 1.0 if open else 0.55


func show_tool(texture: Texture2D, facing: int, socket: Vector2, charge: float, drop_ready: bool, delta: float) -> void:
	if tool_sprite == null:
		return
	tool_sprite.visible = texture != null
	if texture == null:
		hold_dot.visible = false
		_charge.snap(0.0)
		charge_display = 0.0
		tool_sprite.scale = Vector2.ONE
		return
	if tool_sprite.texture != texture:
		tool_sprite.texture = texture
	tool_sprite.position = Vector2(socket.x * float(facing), socket.y)
	_charge.configure(SQUASH_STIFFNESS, SQUASH_DAMPING if charge > 0.0 else 1.0)
	_charge.set_target(charge)
	charge_display = clampf(_charge.step(delta), 0.0, 1.0)
	var scale_value: float = charge_scale(charge_display)
	tool_sprite.scale = Vector2(scale_value, scale_value)
	hold_dot.visible = drop_ready
	if drop_ready:
		_dot_phase += delta * DOT_PULSE_SPEED
		var pulse: float = 1.0 + 0.35 * sin(_dot_phase)
		hold_dot.scale = Vector2(pulse, pulse)
		hold_dot.position = tool_sprite.position + Vector2(float(facing) * 10.0, -10.0)
	else:
		_dot_phase = 0.0


func kick_squash(amount: float) -> void:
	_squash.kick(amount)


func advance(delta: float) -> void:
	var value: float = clampf(_squash.step(delta), -SQUASH_LIMIT, SQUASH_LIMIT)
	var squash := Vector2(1.0 + value, 1.0 - value)
	if body_sprite != null:
		body_sprite.scale = squash
	elif style != null:
		scale = squash


func _draw() -> void:
	if style != null:
		draw_style_box(style, Rect2(-size * 0.5, size))
