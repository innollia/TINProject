class_name EcoPlayerBody
extends RefCounted

const GROUND_FRICTION: float = 1500.0
const AIR_CONTROL: float = 0.35
const JUMP_CUT_MULT: float = 0.42
const COYOTE_TIME: float = 0.10
const JUMP_BUFFER: float = 0.12
const MAX_FALL_SPEED: float = 3400.0
const CURL_SPEED_MULT: float = 0.42
const CURL_HEIGHT_RATIO: float = 0.35
const CURL_FRICTION_MULT: float = 1.80
const SQUEEZE_SPEED_MULT: float = 0.45
const SOIL_SPEED_MULT: float = 0.5
const FALL_DAMAGE_MAX: int = 1
const BREAK_STRIKE_TIME: float = 0.28
const BREAK_IMPULSE_X: float = 240.0
const BREAK_IMPULSE_Y: float = -180.0
const SLEEP_HOLD_S: float = 1.2
const DROP_THROUGH_TIME: float = 0.2
const ACTIONS: Array[StringName] = [&"eco_left", &"eco_right", &"eco_jump", &"eco_curl", &"eco_use"]

var body: EcoBodyRung
var derived: Dictionary = {}
var move_axis: float = 0.0
var jump_held: bool = false
var jump_pressed: bool = false
var curl_held: bool = false
var use_pressed: bool = false
var any_input: bool = false
var jump_cut_done: bool = true
var drop_through_left: float = 0.0
var strike_left: float = 0.0
var squeezing: bool = false
var _jump_was_held: bool = false


static func intent_from_context(context: ModuleContext) -> Dictionary:
	if context == null:
		return {}
	return {
		"move_axis": context.get_axis(&"eco_left", &"eco_right"),
		"jump_held": context.is_action_pressed(&"eco_jump"),
		"curl_held": context.is_action_pressed(&"eco_curl"),
		"use_held": context.is_action_pressed(&"eco_use"),
		"any_input": context.is_action_pressed(&"eco_left") or context.is_action_pressed(&"eco_right") or context.is_action_pressed(&"eco_jump") or context.is_action_pressed(&"eco_curl") or context.is_action_pressed(&"eco_use"),
	}


static func fall_damage(landing_speed: float, safe_speed: float) -> float:
	if landing_speed <= safe_speed:
		return 0.0
	return minf(FALL_DAMAGE_MAX, (landing_speed - safe_speed) / EcoBodyRung.FALL_DAMAGE_DIVISOR)


func set_body(p_body: EcoBodyRung, band_value: float, target_body_px: float) -> void:
	body = p_body
	derived = body.derive(band_value, target_body_px)


func read_input(intent: Dictionary) -> void:
	move_axis = clampf(float(intent.get("move_axis", 0.0)), -1, 1)
	jump_held = bool(intent.get("jump_held", false))
	jump_pressed = bool(intent.get("jump_pressed", jump_held and not _jump_was_held))
	_jump_was_held = jump_held
	curl_held = bool(intent.get("curl_held", false))
	use_pressed = bool(intent.get("use_pressed", false))
	any_input = bool(intent.get("any_input", move_axis != 0.0 or jump_held or curl_held or use_pressed))


func width() -> float:
	return float(derived.get("w_px", 0.0))


func height() -> float:
	var h: float = float(derived.get("h_px", 0.0))
	return h * (1 - CURL_HEIGHT_RATIO) if curl_held else h


func aabb_at(foot: Vector2) -> Rect2:
	var w: float = width()
	var h: float = height()
	return Rect2(foot.x - w * 0.5, foot.y - h, w, h)


func mass() -> float:
	return float(derived.get("mass", 0.0))


func begin_frame(world: EcoWorldState, dt: float) -> void:
	if jump_pressed:
		world.jump_buffer_left = JUMP_BUFFER
	if curl_held and jump_pressed:
		drop_through_left = DROP_THROUGH_TIME
		world.jump_buffer_left = 0.0
	strike_left = maxf(0.0, strike_left - dt)


func substep(world: EcoWorldState, col: EcoCollisionResolver, gravity_mult: float, drift_friction: float, dt: float) -> Dictionary:
	var ev: Dictionary = {"landed": false, "landing_speed": 0.0, "jumped": false, "squeeze_entered": false}
	var v: Vector2 = world.velocity_px
	var aabb: Rect2 = aabb_at(world.position_px)
	var speed_mult: float = CURL_SPEED_MULT if curl_held else 1
	if col.in_soil(aabb):
		speed_mult *= SOIL_SPEED_MULT
	var target: float = move_axis * body.run_speed * speed_mult
	var a: float = body.accel * (1 if world.on_ground else AIR_CONTROL)
	if move_axis != 0.0:
		v.x = move_toward(v.x, target, a * dt)
		world.facing = 1 if move_axis > 0.0 else -1
	elif world.on_ground:
		var fr: float = GROUND_FRICTION * (CURL_FRICTION_MULT if curl_held else 1)
		if col.tile_under(aabb) == EcoTileKind.DRIFT:
			fr *= drift_friction
		v.x = move_toward(v.x, 0.0, fr * dt)
	if world.jump_buffer_left > 0.0 and (world.on_ground or world.coyote_left > 0.0) and not curl_held:
		v.y = -body.jump_speed()
		world.jump_buffer_left = 0.0
		world.coyote_left = 0.0
		world.on_ground = false
		jump_cut_done = false
		ev["jumped"] = true
	if not jump_held and v.y < 0.0 and not jump_cut_done:
		v.y *= JUMP_CUT_MULT
		jump_cut_done = true
	var g: float = EcoBodyRung.GRAVITY_BASE * gravity_mult
	v.y = minf(v.y + g * dt * 0.5, MAX_FALL_SPEED)
	var hole: Dictionary = col.gap_hole_at(aabb)
	var was_squeezing: bool = squeezing
	squeezing = not hole.is_empty() and float(hole["w_gap"]) < EcoGapClass.SQUEEZE_RATIO * width() and width() <= float(hole["w_gap"])
	if squeezing:
		v.x *= SQUEEZE_SPEED_MULT
		if not was_squeezing:
			ev["squeeze_entered"] = true
	var rx: Dictionary = col.move_x(aabb, v.x * dt)
	if rx["blocked"] and world.on_ground and v.x != 0.0:
		var lifted: Rect2 = Rect2(aabb.position - Vector2(0.0, body.max_climb), aabb.size)
		if col.is_free(lifted):
			var rx2: Dictionary = col.move_x(lifted, v.x * dt)
			if not rx2["blocked"]:
				rx = rx2
	if rx["blocked"]:
		v.x = 0.0
	aabb = rx["aabb"]
	var falling_speed: float = v.y
	var was_airborne: bool = not world.on_ground
	var ry: Dictionary = col.move_y(aabb, v.y * dt, drop_through_left > 0.0)
	aabb = ry["aabb"]
	if ry["blocked"]:
		v.y = 0.0
	else:
		v.y = minf(v.y + g * dt * 0.5, MAX_FALL_SPEED)
	var grounded: bool = bool(ry["grounded"]) or (v.y >= 0.0 and col.ground_below(aabb) and drop_through_left <= 0.0)
	if grounded:
		world.coyote_left = COYOTE_TIME
		if was_airborne and falling_speed > 0.0:
			ev["landed"] = true
			ev["landing_speed"] = falling_speed
	else:
		world.coyote_left = maxf(0.0, world.coyote_left - dt)
	world.on_ground = grounded
	world.jump_buffer_left = maxf(0.0, world.jump_buffer_left - dt)
	drop_through_left = maxf(0.0, drop_through_left - dt)
	world.velocity_px = v
	world.position_px = Vector2(aabb.position.x + aabb.size.x * 0.5, aabb.end.y)
	return ev


func try_strike(world: EcoWorldState, col: EcoCollisionResolver) -> EcoPassageSpec:
	if not use_pressed or strike_left > 0.0:
		return null
	strike_left = BREAK_STRIKE_TIME
	var reach: float = float(derived.get("use_range_px", 0.0))
	var wall: EcoPassageSpec = col.break_wall_near(aabb_at(world.position_px), world.facing, reach)
	if wall == null:
		return null
	if EcoPassageResolver.breaks_in_one_strike(body, wall.hp):
		world.break_wall(wall.id)
		col.rebuild()
	return wall
