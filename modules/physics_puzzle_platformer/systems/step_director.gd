extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const BodySpec = preload("res://modules/physics_puzzle_platformer/domain/body_spec.gd")
const InteractionRules = preload("res://modules/physics_puzzle_platformer/domain/interaction_rules.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const ContactBuffer = preload("res://modules/physics_puzzle_platformer/systems/contact_buffer.gd")
const Damage = preload("res://modules/physics_puzzle_platformer/systems/damage.gd")
const Kinematics = preload("res://modules/physics_puzzle_platformer/systems/kinematics.gd")
const LevelFactory = preload("res://modules/physics_puzzle_platformer/systems/level_factory.gd")
const ObjectiveTracker = preload("res://modules/physics_puzzle_platformer/systems/objective_tracker.gd")
const ToolHolder = preload("res://modules/physics_puzzle_platformer/systems/tool_holder.gd")

const EVENT_JUMP: StringName = &"ppp_jump"
const EVENT_LAND_SOFT: StringName = &"ppp_land_soft"
const EVENT_LAND_HARD: StringName = &"ppp_land_hard"
const EVENT_SHATTER: StringName = &"ppp_shatter"
const EVENT_WAKE: StringName = &"ppp_wake"
const EVENT_SPAWNED: StringName = &"ppp_body_spawned"
const EVENT_REMOVED: StringName = &"ppp_body_removed"
const EVENT_TOOL_USE: StringName = &"ppp_tool_use"
const EVENT_STEP_PAPER: StringName = &"ppp_step_paper"
const EVENT_STEP_STONE: StringName = &"ppp_step_stone"
const EVENT_STEP_GLASS: StringName = &"ppp_step_glass"
const ONCE_PER_TICK: Array[StringName] = [&"ppp_impact_soft", &"ppp_impact_hard", EVENT_STEP_PAPER, EVENT_STEP_STONE, EVENT_STEP_GLASS]
const SKIPPED_CODES: Array[StringName] = [&"rest", &"push", &"stand", &"ride", &"carry", &"grab", &"swap"]
const LAND_SOFT_SPEED: float = 120.0
const LAND_HARD_SPEED: float = 300.0
const STEP_INTERVAL: float = 0.18
const STEP_SPEED: float = 40.0

var world: RefCounted
var spec: RefCounted
var tools: Dictionary = {}
var nodes: Array = []
var parent: Node
var params: Dictionary = {}
var kinematics: Array = []
var prev_velocity: Array[Vector2] = []
var index_of: Dictionary = {}
var events: Array[Dictionary] = []
var facing: int = 1
var coyote: float = 0.0
var jump_buffer: float = 0.0
var jump_cut_ready: bool = false
var grounded: bool = false
var ground_velocity: Vector2 = Vector2.ZERO
var ground_material: String = ""
var player_dead: bool = false
var level_cleared: bool = false
var tool_holder: RefCounted = ToolHolder.new()
var damage: RefCounted = Damage.new()
var objectives: RefCounted = ObjectiveTracker.new()
var buffer: RefCounted = ContactBuffer.new()
var debris: Array[Dictionary] = []
var cosmetic: RandomNumberGenerator = RandomNumberGenerator.new()
var space: RID
var tick_count: int = 0
var _rift_index: int = -1
var _last_air_speed: float = 0.0
var _step_timer: float = 0.0
var _space_paused: bool = false


func setup(level_spec: RefCounted, tool_registry: Dictionary, parent_node: Node, dealt_tool_id: String, player_params: Dictionary, cosmetic_seed: int) -> void:
	spec = level_spec
	tools = tool_registry
	parent = parent_node
	params = player_params.duplicate(true)
	cosmetic.seed = cosmetic_seed
	space = (parent as CanvasItem).get_world_2d().space
	LevelFactory.configure_space(space)
	var built: Dictionary = LevelFactory.build(spec, tools, parent, dealt_tool_id, params)
	world = built["world"]
	nodes = built["nodes"]
	kinematics = built["kinematics"]
	index_of.clear()
	prev_velocity.clear()
	for index: int in nodes.size():
		var node: Node = nodes[index]
		if node != null:
			index_of[node.get_instance_id()] = index
		prev_velocity.append(Vector2.ZERO)
	_rift_index = -1
	for index: int in world.bodies.size():
		if world.bodies[index].kind == BodyKind.RIFT:
			_rift_index = index
			break


func teardown() -> void:
	if _space_paused and space.is_valid():
		PhysicsServer2D.space_set_active(space, true)
	_space_paused = false
	for node: Variant in nodes:
		_free_node(node)
	for piece: Dictionary in debris:
		_free_node(piece.get("node"))
	nodes.clear()
	debris.clear()
	index_of.clear()
	prev_velocity.clear()


func _free_node(node: Variant) -> void:
	if node == null or not is_instance_valid(node):
		return
	var target: Node = node
	if target.get_parent() != null:
		target.get_parent().remove_child(target)
	target.free()


func rift() -> RefCounted:
	return world.bodies[_rift_index] if _rift_index >= 0 else null


func player_node() -> RigidBody2D:
	var index: int = world.player_index()
	if index < 0:
		return null
	return nodes[index] as RigidBody2D


func player_scale() -> float:
	return float(params.get("scale", 1.0))


func player_half_width() -> float:
	return Tuning.PLAYER_W * player_scale() * 0.5


func socket_position() -> Vector2:
	var node: RigidBody2D = player_node()
	if node == null:
		return spec.spawn
	return node.global_position + Vector2(float(facing) * Tuning.TOOL_SOCKET_FORWARD, -Tuning.TOOL_SOCKET_UP) * player_scale()


func tool_spec(tool_id: String) -> RefCounted:
	return tools.get(tool_id, null)


func push_event(id: StringName, position: Vector2, strength: float) -> void:
	if ONCE_PER_TICK.has(id):
		for event: Dictionary in events:
			if event["id"] == id:
				return
	events.append({"id": id, "x": position.x, "y": position.y, "strength": strength})


func count_tool_use() -> void:
	world.tools_used += 1
	push_event(EVENT_TOOL_USE, socket_position(), 1.0)


func tick(delta: float, input: Dictionary) -> Array[Dictionary]:
	events.clear()
	if world.hitstop > 0.0:
		world.hitstop = maxf(world.hitstop - delta, 0.0)
		if world.hitstop <= 0.0:
			_set_space_paused(false)
		return events
	tick_count += 1
	_read_states()
	_collect_contacts()
	for entry: Dictionary in buffer.sorted():
		var result: Dictionary = InteractionRules.resolve(entry, world.bodies, delta, world.invuln, world.rift_open)
		_apply_result(entry, result)
	damage.commit(self)
	objectives.update(self, delta)
	if not player_dead and not level_cleared:
		_control_player(input, delta)
		tool_holder.update(self, input, delta)
	Kinematics.step(kinematics, nodes, world.bodies, world.kin_time + delta, spec.wind_x, delta)
	world.kin_time += delta
	_aftercare(delta)
	_commit()
	if world.hitstop > 0.0:
		_set_space_paused(true)
	return events


func _set_space_paused(paused: bool) -> void:
	if paused == _space_paused or not space.is_valid():
		return
	_space_paused = paused
	PhysicsServer2D.space_set_active(space, not paused)


func _read_states() -> void:
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		var node: Node = nodes[index]
		if body.destroyed or node == null:
			continue
		if node is RigidBody2D:
			var rigid: RigidBody2D = node
			var velocity: Vector2 = rigid.linear_velocity
			if velocity.length() > Tuning.MAX_LINEAR_VEL:
				velocity = velocity.limit_length(Tuning.MAX_LINEAR_VEL)
				rigid.linear_velocity = velocity
			if absf(rigid.angular_velocity) > Tuning.MAX_ANGULAR_VEL:
				rigid.angular_velocity = clampf(rigid.angular_velocity, -Tuning.MAX_ANGULAR_VEL, Tuning.MAX_ANGULAR_VEL)
			body.x = rigid.global_position.x
			body.y = rigid.global_position.y
			body.angle = rigid.rotation
			body.vx = velocity.x
			body.vy = velocity.y
			body.av = rigid.angular_velocity
			if body.kind == BodyKind.OBJECTIVE or body.kind == BodyKind.PROP_SLEEPING:
				body.sleeping = rigid.sleeping


func _collect_contacts() -> void:
	buffer.clear()
	var seen: Dictionary = {}
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		var node: Node = nodes[index]
		if body.destroyed or node == null or body.held:
			continue
		if node is RigidBody2D:
			var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state((node as RigidBody2D).get_rid())
			if state == null:
				continue
			for contact: int in state.get_contact_count():
				var other: int = int(index_of.get(state.get_contact_collider_id(contact), -1))
				if other < 0 or other == index:
					continue
				var key: int = mini(index, other) * 4096 + maxi(index, other)
				if seen.has(key):
					continue
				seen[key] = true
				_add_entry(index, other, state.get_contact_local_normal(contact), state.get_contact_local_position(contact))
		elif node is Area2D and body.kind == BodyKind.HAZARD_AREA:
			var overlapping: Array[int] = []
			for other_node: Node2D in (node as Area2D).get_overlapping_bodies():
				var other_index: int = int(index_of.get(other_node.get_instance_id(), -1))
				if other_index >= 0:
					overlapping.append(other_index)
			overlapping.sort()
			for other_index: int in overlapping:
				var area_key: int = mini(index, other_index) * 4096 + maxi(index, other_index)
				if seen.has(area_key):
					continue
				seen[area_key] = true
				_add_entry(index, other_index, Vector2.UP, world.bodies[other_index].position())


func _add_entry(a: int, b: int, normal: Vector2, point: Vector2) -> void:
	var body_a: RefCounted = world.bodies[a]
	var body_b: RefCounted = world.bodies[b]
	var code: StringName = InteractionRules.rule_for(body_a.kind, body_b.kind)
	if SKIPPED_CODES.has(code):
		return
	var velocity_a: Vector2 = prev_velocity[a]
	var velocity_b: Vector2 = prev_velocity[b]
	var relative: Vector2 = velocity_a - velocity_b
	var speed: float = absf(relative.dot(normal)) if normal.length_squared() > 0.0001 else relative.length()
	var direction: Vector2 = body_b.position() - body_a.position()
	direction = direction.normalized() if direction.length_squared() > 0.0001 else -normal
	var toward_b: float = maxf(velocity_a.dot(direction), 0.0)
	var toward_a: float = maxf(velocity_b.dot(-direction), 0.0)
	var sleeping: bool = body_a.sleeping or body_b.sleeping
	match code:
		InteractionRules.IMPACT:
			if speed <= Tuning.IMPACT_THRESHOLD and toward_a <= Tuning.IMPACT_THRESHOLD and toward_b <= Tuning.IMPACT_THRESHOLD:
				return
		InteractionRules.WAKE:
			if not sleeping and speed <= Tuning.IMPACT_THRESHOLD and toward_a <= Tuning.IMPACT_THRESHOLD and toward_b <= Tuning.IMPACT_THRESHOLD:
				return
		InteractionRules.KNOCK:
			if not sleeping and velocity_a.length() <= Tuning.KNOCK_SPEED and velocity_b.length() <= Tuning.KNOCK_SPEED and speed <= Tuning.IMPACT_THRESHOLD:
				return
		InteractionRules.CLACK:
			if speed <= Tuning.IMPACT_THRESHOLD and tool_holder.armed_hook != a and tool_holder.armed_hook != b:
				return
	buffer.add({
		"a": a, "b": b, "speed": speed, "toward_a": toward_a, "toward_b": toward_b,
		"speed_a": velocity_a.length(), "speed_b": velocity_b.length(),
		"velocity_a": velocity_a, "velocity_b": velocity_b, "point": point, "normal": normal,
	}, body_a.kind, body_b.kind)


func _apply_result(entry: Dictionary, result: Dictionary) -> void:
	if not bool(result.get("applied", false)):
		return
	damage.add(result)
	for pair: Array in result.get("wake", []):
		wake_body(int(pair[0]), int(pair[1]))
	for knock: Array in result.get("knock", []):
		var target: int = int(knock[0])
		var node: RigidBody2D = nodes[target] as RigidBody2D
		if node != null and not world.bodies[target].frozen:
			node.sleeping = false
			node.apply_central_impulse((knock[1] as Vector2) * node.mass)
			world.bodies[int(knock[2])].knocked.append(target)
	for item: Array in result.get("freeze", []):
		freeze_body(int(item[0]), float(item[1]))
	objectives.apply(self, result)
	var point: Vector2 = entry.get("point", Vector2.ZERO)
	for event_id: Variant in result.get("events", []):
		push_event(StringName(event_id), point, float(entry.get("speed", 0.0)))
	if StringName(result.get("code", &"")) == InteractionRules.CLACK:
		tool_holder.on_clack(self, entry)


func wake_body(index: int, other: int) -> void:
	var body: RefCounted = world.bodies[index]
	var node: RigidBody2D = nodes[index] as RigidBody2D
	if node == null or body.destroyed:
		return
	var was_sleeping: bool = body.sleeping
	body.sleeping = false
	body.still_time = 0.0
	node.sleeping = false
	if was_sleeping and other >= 0 and not body.frozen:
		var away: Vector2 = body.position() - world.bodies[other].position()
		if away.length_squared() > 0.0001:
			node.apply_central_impulse(away.normalized() * Tuning.WAKE_PUSH * node.mass)
	if was_sleeping:
		push_event(EVENT_WAKE, body.position(), 1.0)


func freeze_body(index: int, duration: float) -> void:
	var body: RefCounted = world.bodies[index]
	var node: RigidBody2D = nodes[index] as RigidBody2D
	if node == null or body.destroyed or body.held or body.kind == BodyKind.PLAYER:
		return
	node.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	node.freeze = true
	body.frozen = true
	body.frozen_time = maxf(body.frozen_time, duration)


func unfreeze_body(index: int) -> void:
	var body: RefCounted = world.bodies[index]
	var node: RigidBody2D = nodes[index] as RigidBody2D
	body.frozen = false
	body.frozen_time = 0.0
	if node == null or body.latched or body.held:
		return
	node.freeze = false
	node.linear_velocity = Vector2.ZERO
	node.angular_velocity = 0.0
	prev_velocity[index] = Vector2.ZERO
	if body.kind == BodyKind.PROP_SLEEPING:
		node.sleeping = true
		body.sleeping = true


func destroy_body(index: int, reason: StringName) -> void:
	var body: RefCounted = world.bodies[index]
	if body.destroyed:
		return
	var position: Vector2 = body.position()
	body.destroyed = true
	body.collected = reason == &"collected"
	body.held = false
	body.frozen = false
	body.latched = false
	tool_holder.forget(index)
	var node: Node = nodes[index]
	var size: float = body.radius * 2.0
	if node != null:
		index_of.erase(node.get_instance_id())
		_free_node(node)
		nodes[index] = null
	push_event(EVENT_REMOVED, position, float(index))
	if reason == &"broken":
		_spawn_debris(position, size, body.material)
		push_event(EVENT_SHATTER, position, float(MaterialTable.debris_count(body.material)))
		_wake_neighbours(position)
	if body.kind == BodyKind.OBJECTIVE and reason != &"collected":
		body.respawn_timer = Tuning.OBJECTIVE_RESPAWN
	elif body.kind == BodyKind.TOOL_CARRIED:
		body.respawn_timer = Tuning.TOOL_RESPAWN


func respawn_body(index: int) -> void:
	var body: RefCounted = world.bodies[index]
	var node: RigidBody2D = null
	if body.kind == BodyKind.OBJECTIVE:
		var authored: RefCounted = spec.body_by_id(body.spec_id)
		if authored == null:
			return
		node = LevelFactory.make_body_node(authored, spec.gravity_mul) as RigidBody2D
		body.hp = authored.hp
	elif body.kind == BodyKind.TOOL_CARRIED:
		var tool: RefCounted = tool_spec(body.tool_id)
		if tool == null:
			return
		node = LevelFactory.make_tool_node(tool, spec.gravity_mul)
		body.hp = tool.hp
	if node == null:
		return
	node.position = Vector2(body.home_x, body.home_y)
	parent.add_child(node)
	if body.kind == BodyKind.OBJECTIVE:
		node.sleeping = true
	body.x = body.home_x
	body.y = body.home_y
	body.vx = 0.0
	body.vy = 0.0
	body.destroyed = false
	body.collected = false
	body.respawn_timer = 0.0
	body.sleeping = body.kind == BodyKind.OBJECTIVE
	body.knocked.clear()
	nodes[index] = node
	index_of[node.get_instance_id()] = index
	prev_velocity[index] = Vector2.ZERO
	push_event(EVENT_SPAWNED, body.position(), float(index))


func spawn_tool(spec_id: String, tool: RefCounted, home: Vector2, held: bool) -> int:
	var runtime: RefCounted = LevelFactory.make_tool_runtime(spec_id, tool, home)
	var node: RigidBody2D = LevelFactory.make_tool_node(tool, spec.gravity_mul)
	node.position = home
	if held:
		LevelFactory.set_held(node, true)
		runtime.held = true
	parent.add_child(node)
	world.bodies.append(runtime)
	nodes.append(node)
	prev_velocity.append(Vector2.ZERO)
	var index: int = world.bodies.size() - 1
	index_of[node.get_instance_id()] = index
	push_event(EVENT_SPAWNED, home, float(index))
	return index


func _spawn_debris(position: Vector2, size: float, material: String) -> void:
	var count: int = MaterialTable.debris_count(material)
	for _piece: int in count:
		if debris.size() >= Tuning.DEBRIS_ACTIVE_MAX:
			_free_node(debris[0].get("node"))
			debris.remove_at(0)
		var edge: float = maxf(size * cosmetic.randf_range(Tuning.DEBRIS_SIZE_MIN, Tuning.DEBRIS_SIZE_MAX), 3.0)
		var node: RigidBody2D = LevelFactory.make_debris_node(edge, material, spec.gravity_mul)
		node.position = position + Vector2(cosmetic.randf_range(-size, size), cosmetic.randf_range(-size, size)) * 0.3
		node.linear_velocity = Vector2(cosmetic.randf_range(-160.0, 160.0), cosmetic.randf_range(-260.0, -60.0))
		node.angular_velocity = cosmetic.randf_range(-12.0, 12.0)
		parent.add_child(node)
		debris.append({"node": node, "life": Tuning.DEBRIS_LIFE, "material": material, "size": edge})


func _wake_neighbours(position: Vector2) -> void:
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		var node: RigidBody2D = nodes[index] as RigidBody2D
		if node == null or body.destroyed or body.frozen or body.held:
			continue
		if body.position().distance_to(position) <= Tuning.WAKE_RADIUS_ON_DESTROY + body.radius:
			node.sleeping = false
			if body.sleeping:
				body.sleeping = false


func _control_player(input: Dictionary, delta: float) -> void:
	var node: RigidBody2D = player_node()
	if node == null:
		return
	var probe: Dictionary = _probe_ground(node)
	var was_grounded: bool = grounded
	grounded = bool(probe["grounded"])
	ground_velocity = probe["velocity"]
	ground_material = String(probe["material"])
	var velocity: Vector2 = node.linear_velocity
	if grounded:
		coyote = Tuning.COYOTE_TIME
		if not was_grounded and _last_air_speed > LAND_SOFT_SPEED:
			push_event(EVENT_LAND_HARD if _last_air_speed > LAND_HARD_SPEED else EVENT_LAND_SOFT, node.global_position, _last_air_speed)
	else:
		coyote = maxf(coyote - delta, 0.0)
		_last_air_speed = maxf(velocity.y, 0.0)
	if bool(input.get("jump_down", false)):
		jump_buffer = Tuning.JUMP_BUFFER
	else:
		jump_buffer = maxf(jump_buffer - delta, 0.0)
	var axis: float = clampf(float(input.get("axis", 0.0)), -1.0, 1.0)
	if axis != 0.0:
		facing = 1 if axis > 0.0 else -1
	var drive: float = axis
	if not grounded and ((axis < 0.0 and bool(probe["wall_left"])) or (axis > 0.0 and bool(probe["wall_right"]))):
		drive = 0.0
	var base_x: float = ground_velocity.x if grounded else 0.0
	var target_x: float = base_x + drive * Tuning.MOVE_SPEED
	var new_x: float = velocity.x
	if grounded:
		new_x = move_toward(velocity.x, target_x, Tuning.ACCEL_GROUND * delta)
	elif drive != 0.0:
		new_x = move_toward(velocity.x, target_x, Tuning.ACCEL_AIR * delta)
	else:
		new_x = velocity.x * (1.0 - Tuning.AIR_DRAG * delta)
	var new_y: float = velocity.y
	if jump_buffer > 0.0 and coyote > 0.0:
		new_y = Tuning.JUMP_VELOCITY + minf(ground_velocity.y, 0.0)
		jump_buffer = 0.0
		coyote = 0.0
		jump_cut_ready = true
		grounded = false
		push_event(EVENT_JUMP, node.global_position, 1.0)
	elif jump_cut_ready and not bool(input.get("jump_held", false)) and new_y < 0.0:
		new_y *= Tuning.JUMP_CUT
		jump_cut_ready = false
	if new_y >= 0.0:
		jump_cut_ready = false
	new_y = minf(new_y, Tuning.MAX_FALL_SPEED)
	node.apply_central_impulse(Vector2(new_x - velocity.x, new_y - velocity.y) * node.mass)
	if grounded and absf(velocity.x - ground_velocity.x) > STEP_SPEED:
		_step_timer -= delta
		if _step_timer <= 0.0:
			_step_timer = STEP_INTERVAL
			var step_id: StringName = EVENT_STEP_STONE
			if ground_material == "paper" or ground_material == "wax":
				step_id = EVENT_STEP_PAPER
			elif ground_material == "glass" or ground_material == "void":
				step_id = EVENT_STEP_GLASS
			push_event(step_id, node.global_position, absf(velocity.x))
	var left: float = spec.bounds.position.x + player_half_width()
	var right: float = spec.bounds.end.x - player_half_width()
	if node.global_position.x < left or node.global_position.x > right:
		node.global_position = Vector2(clampf(node.global_position.x, left, right), node.global_position.y)
		node.linear_velocity = Vector2(0.0, node.linear_velocity.y)


func _probe_ground(node: RigidBody2D) -> Dictionary:
	var result: Dictionary = {"grounded": false, "velocity": Vector2.ZERO, "material": "", "wall_left": false, "wall_right": false}
	var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(node.get_rid())
	if state == null:
		return result
	var half_w: float = player_half_width()
	var half_h: float = Tuning.PLAYER_H * player_scale() * 0.5
	for contact: int in state.get_contact_count():
		var relative: Vector2 = state.get_contact_local_position(contact) - node.global_position
		var other: int = int(index_of.get(state.get_contact_collider_id(contact), -1))
		if other >= 0 and world.bodies[other].held:
			continue
		if relative.y > half_h * 0.45 and absf(relative.x) < half_w + 2.0:
			result["grounded"] = true
			result["velocity"] = state.get_contact_collider_velocity_at_position(contact)
			if other >= 0:
				result["material"] = world.bodies[other].material
		elif absf(relative.y) < half_h * 0.4:
			if relative.x < 0.0:
				result["wall_left"] = true
			else:
				result["wall_right"] = true
	return result


func _aftercare(delta: float) -> void:
	world.invuln = maxf(world.invuln - delta, 0.0)
	world.elapsed += delta
	var limit_y: float = spec.bounds.end.y + Tuning.OFFMAP_MARGIN
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		if body.destroyed:
			if body.kind == BodyKind.TOOL_CARRIED and body.respawn_timer > 0.0:
				body.respawn_timer -= delta
				if body.respawn_timer <= 0.0:
					respawn_body(index)
			continue
		if body.frozen and not body.latched:
			body.frozen_time -= delta
			if body.frozen_time <= 0.0:
				unfreeze_body(index)
		if not BodyKind.is_rigid(body.kind):
			continue
		body.t += delta
		if body.t_max > 0.0 and body.t >= body.t_max:
			destroy_body(index, &"broken")
			continue
		if body.kind == BodyKind.PROP_SLEEPING and not body.sleeping and not body.frozen:
			if body.velocity().length() < Tuning.SLEEP_RELAX_SPEED:
				body.still_time += delta
				if body.still_time >= Tuning.SLEEP_RELAX:
					var node: RigidBody2D = nodes[index] as RigidBody2D
					if node != null:
						node.sleeping = true
					body.sleeping = true
					body.still_time = 0.0
			else:
				body.still_time = 0.0
		if body.y > limit_y:
			if body.kind == BodyKind.PLAYER:
				player_dead = true
			elif not body.held:
				destroy_body(index, &"lost")
	var kept: Array[Dictionary] = []
	for piece: Dictionary in debris:
		piece["life"] = float(piece["life"]) - delta
		if float(piece["life"]) <= 0.0:
			_free_node(piece.get("node"))
		else:
			kept.append(piece)
	debris = kept


func _commit() -> void:
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		var node: Node = nodes[index]
		if body.destroyed or node == null:
			prev_velocity[index] = Vector2.ZERO
			continue
		if node is RigidBody2D:
			var rigid: RigidBody2D = node
			prev_velocity[index] = rigid.linear_velocity
			body.x = rigid.global_position.x
			body.y = rigid.global_position.y
		else:
			prev_velocity[index] = body.velocity()


func sync_runtime() -> void:
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		var node: Node = nodes[index]
		if body.destroyed or not node is RigidBody2D:
			continue
		var rigid: RigidBody2D = node
		body.x = rigid.global_position.x
		body.y = rigid.global_position.y
		body.angle = rigid.rotation
		body.vx = rigid.linear_velocity.x
		body.vy = rigid.linear_velocity.y
		body.av = rigid.angular_velocity
		if body.kind == BodyKind.OBJECTIVE or body.kind == BodyKind.PROP_SLEEPING:
			body.sleeping = rigid.sleeping


func known_spec_ids() -> Array:
	var ids: Array = []
	for body: RefCounted in world.bodies:
		ids.append(body.spec_id)
	for authored: RefCounted in spec.bodies:
		if authored.kind == BodyKind.TOOL_PLACEMENT:
			ids.append(LevelFactory.TOOL_PREFIX + authored.id)
	return ids


func restore(saved: Dictionary) -> void:
	world.objective_count = clampi(int(saved.get("objective_count", 0)), 0, mini(world.objective_needed, world.objective_total))
	world.player_hp = clampf(float(saved.get("player_hp", Tuning.PLAYER_HP)), 0.0, Tuning.PLAYER_HP)
	if world.player_hp <= 0.0:
		world.player_hp = Tuning.PLAYER_HP
	world.deaths = int(saved.get("deaths", 0))
	world.resets = int(saved.get("resets", 0))
	world.elapsed = float(saved.get("elapsed", 0.0))
	world.kin_time = float(saved.get("kin_time", 0.0))
	world.tools_used = int(saved.get("tools_used", 0))
	world.hitstop = 0.0
	world.phase = StringName(saved.get("phase", "intro"))
	for entry: Dictionary in kinematics:
		var index: int = int(entry["index"])
		var moving: AnimatableBody2D = nodes[index] as AnimatableBody2D
		if moving != null:
			var target: Vector2 = Kinematics.position_at(entry["path"], world.kin_time, spec.wind_x)
			moving.sync_to_physics = false
			moving.position = target
			moving.sync_to_physics = true
			world.bodies[index].x = target.x
			world.bodies[index].y = target.y
	var dealt: int = world.find(LevelFactory.DEALT_TOOL_ID)
	for item: Dictionary in saved.get("bodies", []):
		var spec_id: String = String(item["spec_id"])
		var index: int = world.find(spec_id)
		if index < 0 and spec_id.begins_with(LevelFactory.TOOL_PREFIX) and not bool(item.get("destroyed", false)):
			var placement_tool: RefCounted = tool_spec(String(item.get("tool_id", "")))
			var placement: RefCounted = spec.body_by_id(spec_id.substr(LevelFactory.TOOL_PREFIX.length()))
			if placement_tool == null or placement == null:
				continue
			index = spawn_tool(spec_id, placement_tool, placement.pos, false)
		if index < 0:
			continue
		var body: RefCounted = world.bodies[index]
		if body.kind != int(item.get("kind", body.kind)):
			continue
		if index == dealt and String(item.get("tool_id", "")) != body.tool_id:
			continue
		_restore_body(index, item)
	world.player().hp = world.player_hp
	_commit()


func _restore_body(index: int, item: Dictionary) -> void:
	var body: RefCounted = world.bodies[index]
	if bool(item.get("destroyed", false)):
		if body.kind == BodyKind.OBJECTIVE and bool(item.get("collected", false)):
			destroy_body(index, &"collected")
		elif body.kind == BodyKind.TOOL_PLACEMENT or BodyKind.is_mutation_prop(body.kind):
			destroy_body(index, &"restored")
		return
	var node: Node = nodes[index]
	var position := Vector2(float(item.get("x", body.x)), float(item.get("y", body.y)))
	body.x = position.x
	body.y = position.y
	body.angle = float(item.get("angle", 0.0))
	body.vx = float(item.get("vx", 0.0))
	body.vy = float(item.get("vy", 0.0))
	body.av = float(item.get("av", 0.0))
	body.t = float(item.get("t", 0.0))
	body.tool_cooldown = float(item.get("tool_cooldown", 0.0))
	if body.hp >= 0.0:
		body.hp = float(item.get("hp", body.hp))
	if node is RigidBody2D:
		var rigid: RigidBody2D = node
		var held: bool = bool(item.get("held", false)) and body.kind == BodyKind.TOOL_CARRIED
		body.held = held
		LevelFactory.set_held(rigid, held)
		rigid.global_position = position
		rigid.rotation = body.angle
		rigid.linear_velocity = body.velocity()
		rigid.angular_velocity = body.av
		if body.kind == BodyKind.OBJECTIVE or body.kind == BodyKind.PROP_SLEEPING:
			body.sleeping = bool(item.get("sleeping", false))
			rigid.sleeping = body.sleeping
