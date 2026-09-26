extends Control

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const LevelFactory = preload("res://modules/physics_puzzle_platformer/systems/level_factory.gd")
const ToolHolder = preload("res://modules/physics_puzzle_platformer/systems/tool_holder.gd")
const ProceduralBridge = preload("res://modules/physics_puzzle_platformer/presentation/procedural_bridge.gd")
const BackdropDynamics = preload("res://modules/physics_puzzle_platformer/presentation/backdrop_dynamics.gd")
const BodyView = preload("res://modules/physics_puzzle_platformer/presentation/body_view.gd")
const WorldRootView = preload("res://modules/physics_puzzle_platformer/presentation/world_root.gd")
const ParallaxRootView = preload("res://modules/physics_puzzle_platformer/presentation/parallax_root.gd")
const TrailRenderer = preload("res://modules/physics_puzzle_platformer/presentation/trail_renderer.gd")
const LevelTitleView = preload("res://modules/physics_puzzle_platformer/presentation/level_title.gd")
const BubbleOverlayView = preload("res://modules/physics_puzzle_platformer/presentation/bubble_overlay.gd")

const VIEW_NAME: StringName = &"View"
const INTRO_FADE: float = 0.45
const HURT_FLASH: float = 0.25
const DEAD_ALPHA: float = 0.86
const SOCKET := Vector2(14.0, -23.0)

var roles: Dictionary = {}
var world_root: Node2D
var parallax: Node2D
var trail: Node2D
var title: Control
var bubble_overlay: Control
var views: Dictionary = {}
var _module: Node
var _director: RefCounted
var _base: ColorRect
var _container: SubViewportContainer
var _viewport: SubViewport
var _bodies: Node2D
var _fore: Node2D
var _fade: ColorRect
var _vignette: TextureRect
var _textures: Dictionary = {}
var _last_phase: StringName = &""
var _flash: float = 0.0
var _hurt: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	_base = ColorRect.new()
	_base.name = "Base"
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_base)
	_container = SubViewportContainer.new()
	_container.name = "WorldView"
	_container.stretch = false
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.focus_mode = Control.FOCUS_NONE
	add_child(_container)
	_viewport = SubViewport.new()
	_viewport.name = "WorldViewport"
	_viewport.size = Vector2i(int(Tuning.VIEW_W), int(Tuning.VIEW_H))
	_viewport.disable_3d = true
	_viewport.transparent_bg = true
	_viewport.handle_input_locally = false
	_viewport.physics_object_picking = false
	_viewport.gui_disable_input = true
	_container.add_child(_viewport)
	world_root = WorldRootView.new()
	world_root.name = "WorldRoot"
	_viewport.add_child(world_root)
	parallax = ParallaxRootView.new()
	parallax.name = "ParallaxRoot"
	world_root.add_child(parallax)
	_bodies = Node2D.new()
	_bodies.name = "Bodies"
	world_root.add_child(_bodies)
	trail = TrailRenderer.new()
	trail.name = "Trails"
	world_root.add_child(trail)
	_fore = Node2D.new()
	_fore.name = "Fore"
	world_root.add_child(_fore)
	title = LevelTitleView.new()
	add_child(title)
	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.visible = false
	add_child(_fade)
	_vignette = TextureRect.new()
	_vignette.name = "Hurt"
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vignette.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_vignette.visible = false
	add_child(_vignette)
	bubble_overlay = BubbleOverlayView.new()
	add_child(bubble_overlay)
	resized.connect(_layout)
	_layout()


func setup(module: Node) -> void:
	_module = module


func get_world_parent() -> Node:
	return _bodies


func get_camera() -> Camera2D:
	return world_root.camera


func bind_level(director: RefCounted) -> void:
	_director = director
	views.clear()
	_textures.clear()
	var spec: RefCounted = director.spec
	roles = ProceduralBridge.palette_roles(spec.parallax_seed)
	_base.color = roles[&"base"]
	_fade.color = roles[&"ink"]
	_vignette.texture = ProceduralBridge.frame_texture(Vector2i(64, 36), 3, roles[&"ink"])
	parallax.build(spec, roles, _fore)
	var player: RefCounted = director.world.player()
	world_root.setup(spec.bounds, spec.camera_y, player.x if player != null else spec.spawn.x, int(spec.parallax_seed))
	trail.setup(roles[&"ink_dim"])
	if _module != null:
		bubble_overlay.setup(_module.bubble, roles)
	_attach_views()
	_last_phase = &""
	_flash = 0.0
	_hurt = 0.0


func clear_level() -> void:
	_director = null
	views.clear()
	if trail != null:
		trail.clear()
	if parallax != null:
		parallax.clear()
	if title != null:
		title.hide_now()


func refresh(delta: float = 0.0) -> void:
	if _director == null or _module == null:
		return
	var world: RefCounted = _director.world
	_attach_views()
	var player: RefCounted = world.player()
	var player_node: RigidBody2D = _director.player_node()
	var holder: RefCounted = _director.tool_holder
	var held: int = world.held_tool_index()
	for index: int in world.bodies.size():
		var node: Node = _director.nodes[index]
		if node == null:
			continue
		var view: Node2D = views.get(node.get_instance_id(), null)
		if view == null:
			continue
		var body: RefCounted = world.bodies[index]
		view.visible = not (body.kind == BodyKind.TOOL_CARRIED and body.held)
		match body.kind:
			BodyKind.PLAYER:
				var tool_texture: Texture2D = null
				if held >= 0:
					tool_texture = _tool_texture(world.bodies[held].tool_id)
				view.show_tool(tool_texture, _director.facing, SOCKET * _director.player_scale(), holder.charge_fraction(), holder.drop_ready(), delta)
			BodyKind.RIFT:
				view.set_fill(world.objective_count, world.objective_needed, world.rift_open)
			BodyKind.TOOL_CARRIED:
				if not body.held and not body.destroyed:
					var tool: RefCounted = _director.tool_spec(body.tool_id)
					if tool != null and tool.trail != "none":
						trail.track(body.spec_id, body.position(), body.velocity().length(), tool.trail, delta)
		view.advance(delta)
	for piece: Dictionary in _director.debris:
		var debris_node: Node = piece.get("node")
		if debris_node != null and is_instance_valid(debris_node):
			var debris_view: Node2D = views.get(debris_node.get_instance_id(), null)
			if debris_view != null:
				debris_view.modulate.a = clampf(float(piece["life"]) / (Tuning.DEBRIS_LIFE * 0.4), 0.0, 1.0)
	trail.advance(delta)
	if player != null:
		var velocity_x: float = player_node.linear_velocity.x if player_node != null else 0.0
		world_root.follow(player.x, velocity_x, delta)
		var half := Vector2(Tuning.PLAYER_W, Tuning.PLAYER_H) * _director.player_scale() * 0.5
		parallax.advance(world_root.camera.position, player.position(), Rect2(player.position() - half, half * 2.0), delta)
	_update_overlays(world, delta)


func _update_overlays(world: RefCounted, delta: float) -> void:
	var phase: StringName = world.phase
	if phase != _last_phase:
		_on_phase(phase)
		_last_phase = phase
	title.advance(delta)
	if phase == &"play":
		title.hide_now()
	bubble_overlay.refresh(delta)
	match phase:
		&"intro":
			_fade.visible = world.phase_time < INTRO_FADE
			_fade.color = roles[&"base"]
			_fade.modulate.a = clampf(1.0 - world.phase_time / INTRO_FADE, 0.0, 1.0)
		&"dead":
			_fade.visible = true
			_fade.color = roles[&"ink"]
			_fade.modulate.a = clampf(world.phase_time / Tuning.DEAD_RECOVER_DELAY, 0.0, 1.0) * DEAD_ALPHA
		&"clear":
			_flash = maxf(_flash - delta, 0.0)
			_fade.visible = true
			if _flash > 0.0:
				_fade.color = roles[&"base"]
				_fade.modulate.a = _flash / Tuning.CLEAR_FLASH
			else:
				_fade.color = roles[&"base"]
				_fade.modulate.a = clampf((world.phase_time - Tuning.CLEAR_FLASH) / maxf(Tuning.CLEAR_DURATION - Tuning.CLEAR_FLASH, 0.01), 0.0, 1.0)
		_:
			_fade.visible = false
	_hurt = maxf(_hurt - delta, 0.0)
	_vignette.visible = _hurt > 0.0
	_vignette.modulate.a = _hurt / HURT_FLASH * 0.6


func _on_phase(phase: StringName) -> void:
	var spec: RefCounted = _director.spec
	match phase:
		&"intro":
			if not _module.bubble.active:
				title.show_name(spec.name, roles[&"ink"], Tuning.INTRO_DURATION)
			else:
				title.hide_now()
		&"clear":
			_flash = Tuning.CLEAR_FLASH
			title.show_name(spec.name, roles[&"ink"], Tuning.CLEAR_DURATION)
		_:
			title.hide_now()


func on_events(events: Array) -> void:
	if _director == null:
		return
	for event: Dictionary in events:
		var id: StringName = StringName(event["id"])
		var at := Vector2(float(event.get("x", 0.0)), float(event.get("y", 0.0)))
		var strength: float = float(event.get("strength", 1.0))
		match id:
			&"ppp_land_soft", &"ppp_land_hard":
				var land: float = clampf(strength / 420.0, 0.2, 1.0)
				_squash_player(-0.9 * land)
				parallax.dynamics.pulse(BackdropDynamics.PULSE_LAND, at, BackdropDynamics.LAND_RADIUS, land)
				if id == &"ppp_land_hard":
					world_root.shake(2.0)
			&"ppp_jump":
				_squash_player(0.8)
			&"ppp_impact_soft", &"ppp_impact_hard":
				var hit: float = clampf(strength / 600.0, 0.2, 1.0)
				parallax.dynamics.pulse(BackdropDynamics.PULSE_IMPACT, at, BackdropDynamics.IMPACT_RADIUS, hit)
				_squash_near(at, 0.9 * hit)
				if id == &"ppp_impact_hard":
					world_root.shake(3.0)
			&"ppp_shatter":
				parallax.dynamics.pulse(BackdropDynamics.PULSE_BREAK, at, BackdropDynamics.IMPACT_RADIUS, strength)
				world_root.shake(Tuning.CAM_SHAKE_MAX)
			&"ppp_hurt":
				_hurt = HURT_FLASH
				_squash_player(-0.7)
			&"ppp_egg_take", &"ppp_rift_ready":
				_squash_kind(BodyKind.RIFT, 1.2)
			&"ppp_tool_throw", &"ppp_tool_shove", &"ppp_tool_field":
				_squash_player(0.5)


func _squash_player(amount: float) -> void:
	_squash_kind(BodyKind.PLAYER, amount)


func _squash_kind(kind: int, amount: float) -> void:
	var world: RefCounted = _director.world
	for index: int in world.bodies.size():
		if world.bodies[index].kind != kind:
			continue
		var node: Node = _director.nodes[index]
		if node != null and views.has(node.get_instance_id()):
			views[node.get_instance_id()].kick_squash(amount)


func _squash_near(at: Vector2, amount: float) -> void:
	var world: RefCounted = _director.world
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		if not BodyKind.is_rigid(body.kind) or body.destroyed:
			continue
		if body.position().distance_to(at) > body.radius + 24.0:
			continue
		var node: Node = _director.nodes[index]
		if node != null and views.has(node.get_instance_id()):
			views[node.get_instance_id()].kick_squash(amount)


func _attach_views() -> void:
	var world: RefCounted = _director.world
	for index: int in world.bodies.size():
		var node: Node = _director.nodes[index]
		if node == null or views.has(node.get_instance_id()):
			continue
		var view: Node2D = _make_view(world.bodies[index])
		if view != null:
			view.name = VIEW_NAME
			node.add_child(view)
			views[node.get_instance_id()] = view
	for piece: Dictionary in _director.debris:
		var debris_node: Node = piece.get("node")
		if debris_node == null or not is_instance_valid(debris_node) or views.has(debris_node.get_instance_id()):
			continue
		var edge: float = float(piece.get("size", 4.0))
		var debris_view: Node2D = BodyView.new()
		debris_view.name = VIEW_NAME
		debris_view.setup_texture(_shape_texture("box", Vector2(edge, edge), PackedVector2Array(), ProceduralBridge.fill_role(BodyKind.PROP_DYNAMIC, String(piece.get("material", "wood")))), Vector2(edge, edge))
		debris_node.add_child(debris_view)
		views[debris_node.get_instance_id()] = debris_view


func _make_view(body: RefCounted) -> Node2D:
	var view: Node2D = BodyView.new()
	view.kind = body.kind
	view.spec_id = body.spec_id
	match body.kind:
		BodyKind.PLAYER:
			var size := Vector2(Tuning.PLAYER_W, Tuning.PLAYER_H) * _director.player_scale()
			view.setup_texture(_shape_texture("capsule", size, PackedVector2Array(), &"player"), size)
			view.setup_player_tool(ProceduralBridge.dot_texture(1.5, roles[&"ink"]))
			return view
		BodyKind.RIFT:
			var radius: float = _director.spec.rift_radius
			var ring_key: String = "ring|%s" % radius
			if not _textures.has(ring_key):
				_textures[ring_key] = ProceduralBridge.ring_texture(radius, 2.0, roles[&"ink"])
			var wedge_key: String = "wedge|%s|%d" % [radius, _director.world.objective_needed]
			if not _textures.has(wedge_key):
				_textures[wedge_key] = ProceduralBridge.wedge_texture(radius - 3.0, _director.world.objective_needed, roles[&"goal"])
			view.setup_rift(_textures[ring_key], _textures[wedge_key], _director.world.objective_needed)
			return view
		BodyKind.TOOL_CARRIED:
			var texture: Texture2D = _tool_texture(body.tool_id)
			if texture == null:
				return null
			var tool: RefCounted = _director.tool_spec(body.tool_id)
			view.setup_texture(texture, tool.size)
			return view
		BodyKind.TOOL_PLACEMENT:
			var placement_texture: Texture2D = _tool_texture(body.tool_id)
			var mark_key: String = "mark"
			if not _textures.has(mark_key):
				_textures[mark_key] = ProceduralBridge.ring_texture(ToolHolder.PLACEMENT_RADIUS + 6.0, 2.0, roles[&"accent"])
			view.setup_texture(_textures[mark_key], Vector2.ONE * (ToolHolder.PLACEMENT_RADIUS + 6.0) * 2.0)
			if placement_texture != null:
				var icon := Sprite2D.new()
				icon.name = "Icon"
				icon.texture = placement_texture
				icon.scale = Vector2(0.7, 0.7)
				view.add_child(icon)
			return view
	var authored: RefCounted = _director.spec.body_by_id(body.spec_id)
	if authored == null:
		return null
	var role: StringName = ProceduralBridge.fill_role(body.kind, body.material)
	if authored.shape == "box" or authored.shape == "segment":
		var style_key: String = "style|%s" % role
		if not _textures.has(style_key):
			_textures[style_key] = ProceduralBridge.box_stylebox(roles[role], roles[&"ink"])
		view.setup_style(_textures[style_key], Vector2(maxf(authored.size.x, 4.0), authored.size.y))
	else:
		view.setup_texture(_shape_texture(authored.shape, authored.size, authored.points, role), authored.size)
	if body.kind == BodyKind.HAZARD_AREA:
		view.modulate.a = 0.55
	return view


func _tool_texture(tool_id: String) -> Texture2D:
	var tool: RefCounted = _director.tool_spec(tool_id)
	if tool == null:
		return null
	return _shape_texture(tool.shape, tool.size, PackedVector2Array(), ProceduralBridge.fill_role(BodyKind.PROP_DYNAMIC, tool.material))


func _shape_texture(shape: String, size: Vector2, points: PackedVector2Array, role: StringName) -> Texture2D:
	var key: String = "%s|%s|%s|%s" % [shape, size, var_to_str(points), role]
	if not _textures.has(key):
		_textures[key] = ProceduralBridge.shape_texture(shape, size, points, roles[role], roles[&"ink"])
	return _textures[key]


func _layout() -> void:
	if _container == null:
		return
	var view := Vector2(Tuning.VIEW_W, Tuning.VIEW_H)
	var available: Vector2 = size if size.x > 0.0 and size.y > 0.0 else view
	var factor: float = minf(available.x / view.x, available.y / view.y)
	_container.size = view
	_container.scale = Vector2(factor, factor)
	_container.position = (available - view * factor) * 0.5
	var whole: bool = is_equal_approx(factor, roundf(factor))
	_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if whole else CanvasItem.TEXTURE_FILTER_LINEAR


func world_rect() -> Rect2:
	return Rect2(_container.position, _container.size * _container.scale)
