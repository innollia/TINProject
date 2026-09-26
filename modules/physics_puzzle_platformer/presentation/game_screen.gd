extends Control

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

var _module: Node
var _director: RefCounted
var _container: SubViewportContainer
var _viewport: SubViewport
var _world_root: Node2D
var _bodies: Node2D
var _camera: Camera2D


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container = SubViewportContainer.new()
	_container.name = "WorldView"
	_container.stretch = false
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_container)
	_viewport = SubViewport.new()
	_viewport.name = "WorldViewport"
	_viewport.size = Vector2i(int(Tuning.VIEW_W), int(Tuning.VIEW_H))
	_viewport.disable_3d = true
	_viewport.handle_input_locally = false
	_viewport.physics_object_picking = false
	_container.add_child(_viewport)
	_world_root = Node2D.new()
	_world_root.name = "WorldRoot"
	_viewport.add_child(_world_root)
	_bodies = Node2D.new()
	_bodies.name = "Bodies"
	_world_root.add_child(_bodies)
	_camera = Camera2D.new()
	_camera.name = "Camera"
	_world_root.add_child(_camera)
	resized.connect(_layout)
	_layout()


func setup(module: Node) -> void:
	_module = module


func get_world_parent() -> Node:
	return _bodies


func bind_level(director: RefCounted) -> void:
	_director = director


func clear_level() -> void:
	_director = null


func on_events(_events: Array) -> void:
	pass


func refresh() -> void:
	if _director == null or _camera == null:
		return
	var player: RefCounted = _director.world.player()
	if player != null:
		_camera.position = Vector2(player.x, _director.spec.camera_y)


func _layout() -> void:
	if _container == null:
		return
	var view: Vector2 = Vector2(Tuning.VIEW_W, Tuning.VIEW_H)
	var available: Vector2 = size if size.x > 0.0 and size.y > 0.0 else view
	var factor: float = minf(available.x / view.x, available.y / view.y)
	_container.size = view
	_container.scale = Vector2(factor, factor)
	_container.position = (available - view * factor) * 0.5
