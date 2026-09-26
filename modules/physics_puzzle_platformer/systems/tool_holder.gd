extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const LevelFactory = preload("res://modules/physics_puzzle_platformer/systems/level_factory.gd")

const EVENT_GRAB: StringName = &"ppp_tool_grab"
const EVENT_CHARGE: StringName = &"ppp_tool_charge"
const EVENT_THROW: StringName = &"ppp_tool_throw"
const EVENT_SHOVE: StringName = &"ppp_tool_shove"
const EVENT_FIELD: StringName = &"ppp_tool_field"
const EVENT_LATCH: StringName = &"ppp_tool_latch"
const PLACEMENT_RADIUS: float = 12.0
const ROPE_MIN_LENGTH: float = 24.0

var charging: bool = false
var charge_time: float = 0.0
var hold_time: float = 0.0
var pressing: bool = false
var press_time: float = 0.0
var rope_anchor_index: int = -1
var rope_length: float = 0.0
var armed_hook: int = -1
var _grace: Dictionary = {}


func charge_fraction() -> float:
	if not charging:
		return 0.0
	return clampf(charge_time / Tuning.TOOL_CHARGE_FULL, 0.0, 1.0)


func drop_ready() -> bool:
	if not pressing:
		return false
	if charging:
		return charge_time >= Tuning.TOOL_CHARGE_FULL + Tuning.TOOL_HOLD_HINT
	return press_time >= Tuning.TOOL_HOLD_HINT


func update(director: RefCounted, input: Dictionary, delta: float) -> void:
	var world: RefCounted = director.world
	var player_index: int = world.player_index()
	if player_index < 0 or director.nodes[player_index] == null:
		return
	var player: RefCounted = world.bodies[player_index]
	player.tool_cooldown = maxf(player.tool_cooldown - delta, 0.0)
	_update_grace(director, delta)
	var held: int = world.held_tool_index()
	var socket: Vector2 = director.socket_position()
	if held >= 0:
		_place_held(director, held, socket)
		hold_time += delta
	else:
		hold_time = 0.0
	if bool(input.get("grab_down", false)) and player.tool_cooldown <= 0.0 and not pressing:
		var target: int = _find_pickup(director, socket)
		if target >= 0:
			_take(director, target, held, socket)
			player.tool_cooldown = Tuning.TOOL_COOLDOWN
			charging = false
		elif held >= 0:
			var tool: RefCounted = director.tool_spec(world.bodies[held].tool_id)
			if tool != null:
				pressing = true
				press_time = 0.0
				match tool.use:
					"throw", "anchor_line":
						charging = true
						charge_time = 0.0
						director.push_event(EVENT_CHARGE, socket, 0.0)
					"shove":
						_shove(director, tool, socket)
						player.tool_cooldown = tool.cooldown
					"cool_field":
						_cool(director, tool, socket)
						player.tool_cooldown = tool.cooldown
		elif rope_anchor_index >= 0:
			release_rope(director)
			player.tool_cooldown = Tuning.TOOL_COOLDOWN
	if pressing:
		held = world.held_tool_index()
		if held < 0:
			pressing = false
			charging = false
		else:
			press_time += delta
			if charging:
				charge_time = minf(charge_time + delta, Tuning.TOOL_MAX_HOLD)
			if not bool(input.get("grab_held", false)):
				if drop_ready():
					drop(director, held, socket)
					player.tool_cooldown = 0.0
				elif charging:
					_throw(director, held, socket)
					player.tool_cooldown = Tuning.TOOL_COOLDOWN
				pressing = false
				charging = false
	_update_rope(director)


func _place_held(director: RefCounted, index: int, socket: Vector2) -> void:
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	if node == null:
		return
	node.global_position = socket
	node.rotation = 0.0
	var body: RefCounted = director.world.bodies[index]
	body.x = socket.x
	body.y = socket.y


func _find_pickup(director: RefCounted, socket: Vector2) -> int:
	var best: int = -1
	var best_distance: float = INF
	var reach: float = float(director.params.get("reach", Tuning.GRAB_RADIUS))
	for index: int in director.world.bodies.size():
		var body: RefCounted = director.world.bodies[index]
		if body.destroyed:
			continue
		var radius: float = 0.0
		if body.kind == BodyKind.TOOL_PLACEMENT:
			radius = PLACEMENT_RADIUS
		elif body.kind == BodyKind.TOOL_CARRIED and not body.held:
			radius = body.radius
		else:
			continue
		var distance: float = socket.distance_to(body.position()) - radius
		if distance <= reach and distance < best_distance:
			best = index
			best_distance = distance
	return best


func _take(director: RefCounted, target: int, held: int, socket: Vector2) -> void:
	var world: RefCounted = director.world
	if held >= 0:
		drop(director, held, socket)
	var body: RefCounted = world.bodies[target]
	if body.kind == BodyKind.TOOL_PLACEMENT:
		var tool: RefCounted = director.tool_spec(body.tool_id)
		if tool == null:
			return
		director.destroy_body(target, &"consumed")
		director.spawn_tool(LevelFactory.TOOL_PREFIX + body.spec_id, tool, Vector2(body.home_x, body.home_y), true)
	else:
		if target == rope_anchor_index:
			release_rope(director)
		if target == armed_hook:
			armed_hook = -1
		var node: RigidBody2D = director.nodes[target] as RigidBody2D
		if node == null:
			return
		if body.frozen:
			director.unfreeze_body(target)
		LevelFactory.set_held(node, true)
		body.held = true
		body.knocked.clear()
		_place_held(director, target, socket)
	director.push_event(EVENT_GRAB, socket, 1.0)


func drop(director: RefCounted, index: int, socket: Vector2) -> void:
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	var body: RefCounted = director.world.bodies[index]
	body.held = false
	if node == null:
		return
	LevelFactory.set_held(node, false)
	node.global_position = socket
	node.linear_velocity = Vector2.ZERO
	node.angular_velocity = 0.0
	director.prev_velocity[index] = Vector2.ZERO
	_start_grace(director, index)


func _throw(director: RefCounted, index: int, socket: Vector2) -> void:
	var body: RefCounted = director.world.bodies[index]
	var tool: RefCounted = director.tool_spec(body.tool_id)
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	var player_node: RigidBody2D = director.player_node()
	if tool == null or node == null or player_node == null:
		return
	var charge: float = clampf(charge_time / Tuning.TOOL_CHARGE_FULL, 0.0, 1.0)
	LevelFactory.set_held(node, false)
	node.global_position = socket
	var speed: float = Tuning.TOOL_THROW_IMPULSE * tool.impulse_scale * (1.0 + Tuning.TOOL_CHARGE_BONUS * charge)
	var velocity: Vector2 = Vector2(float(director.facing) * speed, Tuning.TOOL_THROW_UP) + Vector2(player_node.linear_velocity.x * 0.5, 0.0)
	node.linear_velocity = velocity
	node.angular_velocity = float(director.facing) * 8.0
	body.held = false
	body.knocked.clear()
	body.vx = velocity.x
	body.vy = velocity.y
	director.prev_velocity[index] = velocity
	_start_grace(director, index)
	if tool.use == "anchor_line":
		if rope_anchor_index >= 0:
			release_rope(director)
		armed_hook = index
	director.count_tool_use()
	director.push_event(EVENT_THROW, socket, charge)


func _shove(director: RefCounted, tool: RefCounted, socket: Vector2) -> void:
	var direction: Vector2 = Vector2(float(director.facing), 0.0)
	var half_arc: float = deg_to_rad(tool.arc_deg * 0.5)
	for index: int in director.world.bodies.size():
		var body: RefCounted = director.world.bodies[index]
		var node: RigidBody2D = director.nodes[index] as RigidBody2D
		if node == null or body.destroyed or body.held or body.frozen or body.latched or body.kind == BodyKind.PLAYER:
			continue
		var offset: Vector2 = body.position() - socket
		if offset.length() - body.radius > tool.reach:
			continue
		if offset.length() > 1.0 and absf(direction.angle_to(offset)) > half_arc:
			continue
		var push: Vector2 = offset.normalized() if offset.length() > 1.0 else direction
		var ratio: float = minf(1.0, tool.mass / maxf(body.mass, 0.0001))
		var change: Vector2 = (push + Vector2(0.0, -Tuning.SHOVE_LIFT)).normalized() * Tuning.SHOVE_SPEED * ratio
		if body.sleeping:
			director.wake_body(index, -1)
		node.sleeping = false
		node.apply_central_impulse(change * node.mass)
	director.count_tool_use()
	director.push_event(EVENT_SHOVE, socket + direction * tool.reach * 0.5, tool.reach)
	director.push_event(EVENT_THROW, socket, 0.0)


func _cool(director: RefCounted, tool: RefCounted, socket: Vector2) -> void:
	var center: Vector2 = socket + Vector2(float(director.facing), 0.0) * tool.radius * 0.6
	for index: int in director.world.bodies.size():
		var body: RefCounted = director.world.bodies[index]
		var node: RigidBody2D = director.nodes[index] as RigidBody2D
		if node == null or body.destroyed or body.held or body.latched or body.kind == BodyKind.PLAYER:
			continue
		if body.position().distance_to(center) <= tool.radius:
			director.freeze_body(index, tool.duration)
	director.count_tool_use()
	director.push_event(EVENT_FIELD, center, tool.radius)


func on_clack(director: RefCounted, entry: Dictionary) -> void:
	if armed_hook < 0:
		return
	var a: int = int(entry.get("a", -1))
	var b: int = int(entry.get("b", -1))
	if a != armed_hook and b != armed_hook:
		return
	var other: int = b if a == armed_hook else a
	if director.world.bodies[other].kind != BodyKind.TILE_STATIC:
		return
	var hook: RefCounted = director.world.bodies[armed_hook]
	var player: RefCounted = director.world.player()
	armed_hook = -1
	if player == null or hook.destroyed:
		return
	var distance: float = player.position().distance_to(hook.position())
	if distance > Tuning.ROPE_MAX_LENGTH:
		return
	var index: int = director.world.bodies.find(hook)
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	if node == null:
		return
	node.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	node.freeze = true
	hook.latched = true
	rope_anchor_index = index
	rope_length = maxf(distance, ROPE_MIN_LENGTH)
	director.push_event(EVENT_LATCH, hook.position(), rope_length)


func release_rope(director: RefCounted) -> void:
	if rope_anchor_index < 0:
		return
	var index: int = rope_anchor_index
	rope_anchor_index = -1
	if index >= director.world.bodies.size():
		return
	var hook: RefCounted = director.world.bodies[index]
	hook.latched = false
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	if node != null and not hook.held and not hook.frozen:
		node.freeze = false


func forget(index: int) -> void:
	if rope_anchor_index == index:
		rope_anchor_index = -1
	if armed_hook == index:
		armed_hook = -1
	_grace.erase(index)


func rope_points(director: RefCounted) -> PackedVector2Array:
	var points := PackedVector2Array()
	if rope_anchor_index < 0:
		return points
	var player: RefCounted = director.world.player()
	var hook: RefCounted = director.world.bodies[rope_anchor_index]
	if player == null or hook.destroyed:
		return points
	points.append(player.position())
	points.append(hook.position())
	return points


func _update_rope(director: RefCounted) -> void:
	if rope_anchor_index < 0:
		return
	var hook: RefCounted = director.world.bodies[rope_anchor_index]
	var player_node: RigidBody2D = director.player_node()
	if hook.destroyed or hook.held or player_node == null:
		rope_anchor_index = -1
		return
	var offset: Vector2 = player_node.global_position - hook.position()
	var distance: float = offset.length()
	if distance <= rope_length or distance < 0.001:
		return
	var normal: Vector2 = offset / distance
	var radial: float = player_node.linear_velocity.dot(normal)
	var change: Vector2 = -normal * (maxf(radial, 0.0) + (distance - rope_length) * Tuning.ROPE_BAUMGARTE)
	player_node.apply_central_impulse(change * player_node.mass)


func _start_grace(director: RefCounted, index: int) -> void:
	var node: RigidBody2D = director.nodes[index] as RigidBody2D
	var player_node: RigidBody2D = director.player_node()
	if node == null or player_node == null:
		return
	node.add_collision_exception_with(player_node)
	_grace[index] = Tuning.TOOL_OWNER_GRACE


func _update_grace(director: RefCounted, delta: float) -> void:
	for index: int in _grace.keys():
		var remaining: float = float(_grace[index]) - delta
		if remaining > 0.0:
			_grace[index] = remaining
			continue
		_grace.erase(index)
		var node: RigidBody2D = director.nodes[index] as RigidBody2D if index < director.nodes.size() else null
		var player_node: RigidBody2D = director.player_node()
		if node != null and player_node != null:
			node.remove_collision_exception_with(player_node)
