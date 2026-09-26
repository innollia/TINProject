extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const BodySpec = preload("res://modules/physics_puzzle_platformer/domain/body_spec.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const WorldState = preload("res://modules/physics_puzzle_platformer/domain/world_state.gd")

const LAYER_WORLD: int = 1
const LAYER_TERRAIN: int = 2
const LAYER_DEBRIS: int = 4
const PLAYER_ID: String = "player"
const RIFT_ID: String = "rift"
const DEALT_TOOL_ID: String = "tool:dealt"
const TOOL_PREFIX: String = "tool:"


static func configure_space(space: RID) -> void:
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY, Tuning.GRAVITY)
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0.0, 1.0))
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_LINEAR_DAMP, Tuning.LINEAR_DAMP)
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_ANGULAR_DAMP, Tuning.ANGULAR_DAMP)
	PhysicsServer2D.space_set_param(space, PhysicsServer2D.SPACE_PARAM_BODY_LINEAR_VELOCITY_SLEEP_THRESHOLD, Tuning.SLEEP_THRESHOLD_LINEAR)
	PhysicsServer2D.space_set_param(space, PhysicsServer2D.SPACE_PARAM_BODY_ANGULAR_VELOCITY_SLEEP_THRESHOLD, Tuning.SLEEP_THRESHOLD_ANGULAR)
	PhysicsServer2D.space_set_param(space, PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS, Tuning.SOLVER_ITERATIONS)
	PhysicsServer2D.space_set_param(space, PhysicsServer2D.SPACE_PARAM_CONTACT_RECYCLE_RADIUS, Tuning.CONTACT_RECYCLE_RADIUS)


static func make_shape(shape: String, size: Vector2, points: PackedVector2Array) -> Shape2D:
	match shape:
		"capsule":
			var capsule := CapsuleShape2D.new()
			capsule.radius = size.x * 0.5
			capsule.height = maxf(size.y, size.x)
			return capsule
		"circle":
			var circle := CircleShape2D.new()
			circle.radius = size.x * 0.5
			return circle
		"triangle":
			var triangle := ConvexPolygonShape2D.new()
			triangle.points = triangle_points(size)
			return triangle
		"hull":
			var hull := ConvexPolygonShape2D.new()
			hull.points = points
			return hull
		"segment":
			var segment := RectangleShape2D.new()
			segment.size = Vector2(maxf(size.x, 4.0), size.y)
			return segment
	var box := RectangleShape2D.new()
	box.size = size
	return box


static func triangle_points(size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-size.x * 0.5, size.y * 0.5), Vector2(size.x * 0.5, size.y * 0.5), Vector2(0.0, -size.y * 0.5)])


static func attach_shape(node: CollisionObject2D, shape: Shape2D) -> void:
	var holder := CollisionShape2D.new()
	holder.name = "Shape"
	holder.shape = shape
	node.add_child(holder)


static func make_body_node(body: RefCounted, gravity_mul: float) -> CollisionObject2D:
	var node: CollisionObject2D = null
	match BodyKind.node_type(body.kind):
		BodyKind.NODE_STATIC:
			var fixed := StaticBody2D.new()
			fixed.physics_material_override = MaterialTable.make_physics_material(body.material, body.friction_override, body.bounce_override)
			fixed.collision_layer = LAYER_WORLD | LAYER_TERRAIN
			fixed.collision_mask = LAYER_WORLD
			node = fixed
		BodyKind.NODE_KINEMATIC:
			var moving := AnimatableBody2D.new()
			moving.sync_to_physics = true
			moving.physics_material_override = MaterialTable.make_physics_material(body.material, body.friction_override, body.bounce_override)
			moving.collision_layer = LAYER_WORLD | LAYER_TERRAIN
			moving.collision_mask = LAYER_WORLD
			node = moving
		BodyKind.NODE_AREA:
			var area := Area2D.new()
			area.monitorable = false
			area.monitoring = body.kind == BodyKind.HAZARD_AREA
			area.collision_layer = 0
			area.collision_mask = LAYER_WORLD
			node = area
		_:
			var rigid := RigidBody2D.new()
			configure_rigid(rigid, body.mass(), MaterialTable.make_physics_material(body.material, body.friction_override, body.bounce_override), gravity_mul)
			rigid.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE if maxf(body.size.x, body.size.y) < 48.0 else RigidBody2D.CCD_MODE_DISABLED
			node = rigid
	node.name = body.id
	attach_shape(node, make_shape(body.shape, body.size, body.points))
	node.position = body.pos
	node.rotation = body.angle
	return node


static func configure_rigid(rigid: RigidBody2D, mass: float, material: PhysicsMaterial, gravity_mul: float) -> void:
	rigid.mass = maxf(mass, 0.02)
	rigid.physics_material_override = material
	rigid.gravity_scale = gravity_mul
	rigid.contact_monitor = true
	rigid.max_contacts_reported = Tuning.CONTACT_MAX_REPORTED
	rigid.can_sleep = true
	rigid.collision_layer = LAYER_WORLD
	rigid.collision_mask = LAYER_WORLD
	rigid.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC


static func make_player_node(spawn: Vector2, params: Dictionary, gravity_mul: float) -> RigidBody2D:
	var player := RigidBody2D.new()
	player.name = "Player"
	var material := PhysicsMaterial.new()
	material.friction = Tuning.FRICTION_GROUND
	material.bounce = Tuning.BOUNCE_PLAYER
	var scale: float = float(params.get("scale", 1.0))
	configure_rigid(player, float(params.get("mass", 1.0)), material, gravity_mul)
	player.lock_rotation = true
	player.can_sleep = false
	player.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	attach_shape(player, make_shape("capsule", Vector2(Tuning.PLAYER_W, Tuning.PLAYER_H) * scale, PackedVector2Array()))
	player.position = spawn
	return player


static func make_tool_node(tool: RefCounted, gravity_mul: float) -> RigidBody2D:
	var node := RigidBody2D.new()
	node.name = "Tool"
	var material := PhysicsMaterial.new()
	material.friction = tool.friction
	material.bounce = tool.bounce
	configure_rigid(node, tool.mass, material, gravity_mul)
	node.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	attach_shape(node, make_shape(tool.shape, tool.size, PackedVector2Array()))
	return node


static func make_debris_node(size: float, material: String, gravity_mul: float) -> RigidBody2D:
	var node := RigidBody2D.new()
	node.name = "Debris"
	var physics := MaterialTable.make_physics_material(material)
	node.mass = 0.02
	node.physics_material_override = physics
	node.gravity_scale = gravity_mul
	node.collision_layer = LAYER_DEBRIS
	node.collision_mask = LAYER_TERRAIN
	node.can_sleep = true
	attach_shape(node, make_shape("box", Vector2(size, size), PackedVector2Array()))
	return node


static func make_runtime(body: RefCounted) -> RefCounted:
	var runtime: RefCounted = BodySpec.BodyRuntime.new()
	runtime.spec_id = body.id
	runtime.kind = body.kind
	runtime.x = body.pos.x
	runtime.y = body.pos.y
	runtime.angle = body.angle
	runtime.home_x = body.pos.x
	runtime.home_y = body.pos.y
	runtime.hp = body.hp
	runtime.material = body.material
	runtime.mass = body.mass() if BodyKind.is_rigid(body.kind) else 0.0
	runtime.radius = BodySpec.bounding_radius(body.shape, body.size, body.points)
	runtime.breakable = body.breakable
	runtime.t_max = body.t_max
	runtime.sleeping = body.kind == BodyKind.PROP_SLEEPING or body.kind == BodyKind.OBJECTIVE
	runtime.tool_id = body.tool
	return runtime


static func make_tool_runtime(spec_id: String, tool: RefCounted, home: Vector2) -> RefCounted:
	var runtime: RefCounted = BodySpec.BodyRuntime.new()
	runtime.spec_id = spec_id
	runtime.kind = BodyKind.TOOL_CARRIED
	runtime.x = home.x
	runtime.y = home.y
	runtime.home_x = home.x
	runtime.home_y = home.y
	runtime.hp = tool.hp
	runtime.material = tool.material
	runtime.mass = tool.mass
	runtime.radius = BodySpec.bounding_radius(tool.shape, tool.size, PackedVector2Array())
	runtime.breakable = tool.breakable
	runtime.fire_linger = tool.fire_linger
	runtime.tool_id = tool.id
	return runtime


static func build(spec: RefCounted, tools: Dictionary, parent: Node, dealt_tool_id: String, params: Dictionary) -> Dictionary:
	var world: RefCounted = WorldState.new()
	world.level_id = spec.id
	world.objective_needed = spec.objective_needed
	world.objective_total = spec.objective_total()
	world.player_hp = Tuning.PLAYER_HP
	var nodes: Array = []
	var kinematics: Array = []
	var ordered: Array = []
	for pass_index: int in 3:
		for body: RefCounted in spec.bodies:
			var node_kind: StringName = BodyKind.node_type(body.kind)
			var in_pass: bool = false
			match pass_index:
				0:
					in_pass = node_kind == BodyKind.NODE_STATIC or node_kind == BodyKind.NODE_KINEMATIC
				1:
					in_pass = node_kind == BodyKind.NODE_AREA
				2:
					in_pass = node_kind == BodyKind.NODE_RIGID
			if in_pass:
				ordered.append(body)
	var rigid_start: int = -1
	for body: RefCounted in ordered:
		if BodyKind.is_rigid(body.kind) and rigid_start < 0:
			rigid_start = world.bodies.size()
			_add_rift(spec, world, nodes, parent)
			_add_player(spec, world, nodes, parent, params)
		var node: CollisionObject2D = make_body_node(body, spec.gravity_mul)
		if body.kind == BodyKind.TILE_KINEMATIC:
			var path: Dictionary = spec.kinematic_for(body.id)
			node.position = path["from"]
			kinematics.append({"index": world.bodies.size(), "path": path})
		parent.add_child(node)
		if node is RigidBody2D and starts_asleep(body.kind):
			(node as RigidBody2D).sleeping = true
		var runtime: RefCounted = make_runtime(body)
		runtime.x = node.position.x
		runtime.y = node.position.y
		world.bodies.append(runtime)
		nodes.append(node)
	if rigid_start < 0:
		_add_rift(spec, world, nodes, parent)
		_add_player(spec, world, nodes, parent, params)
	var tool: RefCounted = tools.get(dealt_tool_id, null)
	if tool != null:
		var home: Vector2 = spec.spawn + Vector2(Tuning.TOOL_SOCKET_FORWARD, -Tuning.TOOL_SOCKET_UP)
		var runtime: RefCounted = make_tool_runtime(DEALT_TOOL_ID, tool, home)
		runtime.held = true
		var node: RigidBody2D = make_tool_node(tool, spec.gravity_mul)
		set_held(node, true)
		node.position = home
		parent.add_child(node)
		world.bodies.append(runtime)
		nodes.append(node)
	return {"world": world, "nodes": nodes, "kinematics": kinematics}


static func _add_rift(spec: RefCounted, world: RefCounted, nodes: Array, parent: Node) -> void:
	var rift := Area2D.new()
	rift.name = "Rift"
	rift.monitoring = false
	rift.monitorable = false
	rift.collision_layer = 0
	rift.collision_mask = 0
	attach_shape(rift, make_shape("circle", Vector2(spec.rift_radius, spec.rift_radius) * 2.0, PackedVector2Array()))
	rift.position = spec.rift_pos
	parent.add_child(rift)
	var runtime: RefCounted = BodySpec.BodyRuntime.new()
	runtime.spec_id = RIFT_ID
	runtime.kind = BodyKind.RIFT
	runtime.x = spec.rift_pos.x
	runtime.y = spec.rift_pos.y
	runtime.hp = BodyKind.INFINITE_HP
	runtime.material = "goal"
	world.bodies.append(runtime)
	nodes.append(rift)


static func _add_player(spec: RefCounted, world: RefCounted, nodes: Array, parent: Node, params: Dictionary) -> void:
	var node: RigidBody2D = make_player_node(spec.spawn, params, spec.gravity_mul)
	parent.add_child(node)
	var runtime: RefCounted = BodySpec.BodyRuntime.new()
	runtime.spec_id = PLAYER_ID
	runtime.kind = BodyKind.PLAYER
	runtime.x = spec.spawn.x
	runtime.y = spec.spawn.y
	runtime.home_x = spec.spawn.x
	runtime.home_y = spec.spawn.y
	runtime.hp = Tuning.PLAYER_HP
	runtime.material = "wax"
	runtime.mass = node.mass
	world.bodies.append(runtime)
	nodes.append(node)


static func starts_asleep(kind: int) -> bool:
	return kind == BodyKind.PROP_SLEEPING or kind == BodyKind.OBJECTIVE


static func set_held(node: RigidBody2D, held: bool) -> void:
	node.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC if held else RigidBody2D.FREEZE_MODE_STATIC
	node.freeze = held
	node.collision_layer = 0 if held else LAYER_WORLD
	node.collision_mask = 0 if held else LAYER_WORLD
