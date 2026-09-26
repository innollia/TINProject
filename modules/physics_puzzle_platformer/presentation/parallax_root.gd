extends Node2D

const BackdropDynamics = preload("res://modules/physics_puzzle_platformer/presentation/backdrop_dynamics.gd")
const ParallaxLayerView = preload("res://modules/physics_puzzle_platformer/presentation/parallax_layer.gd")
const ProceduralBridge = preload("res://modules/physics_puzzle_platformer/presentation/procedural_bridge.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

var dynamics: RefCounted = BackdropDynamics.new()
var back_layers: Array[Node2D] = []
var fore_layer: Node2D


func build(spec: RefCounted, roles: Dictionary, fore_parent: Node2D) -> void:
	clear()
	dynamics = BackdropDynamics.new()
	var view := Vector2(Tuning.VIEW_W, Tuning.VIEW_H)
	var colors: Dictionary = {"far": roles[&"bg_far"], "near": roles[&"bg_near"], "fore": roles[&"bg_fore"]}
	for layer_name: String in BackdropDynamics.LAYER_ORDER:
		var apparent: float = float(BackdropDynamics.LAYER_APPARENT[layer_name])
		var items: Array[Dictionary] = ProceduralBridge.backdrop_elements(spec.parallax_seed, layer_name, spec.bounds, spec.camera_y, apparent, view, colors[layer_name])
		var layer_node: Node2D = ParallaxLayerView.new()
		if layer_name == "fore":
			fore_parent.add_child(layer_node)
			fore_layer = layer_node
		else:
			add_child(layer_node)
			back_layers.append(layer_node)
		layer_node.build(layer_name, items, float(BackdropDynamics.LAYER_ALPHA[layer_name]), dynamics)


func clear() -> void:
	for item_layer: Node2D in back_layers:
		if is_instance_valid(item_layer):
			item_layer.get_parent().remove_child(item_layer)
			item_layer.free()
	back_layers.clear()
	if fore_layer != null and is_instance_valid(fore_layer):
		fore_layer.get_parent().remove_child(fore_layer)
		fore_layer.free()
	fore_layer = null


func layer(layer_name: String) -> Node2D:
	if layer_name == "fore":
		return fore_layer
	for item: Node2D in back_layers:
		if item.layer_name == layer_name:
			return item
	return null


func advance(camera_center: Vector2, player_position: Vector2, player_rect: Rect2, delta: float) -> void:
	dynamics.set_view(camera_center)
	dynamics.push_from(player_position, delta)
	dynamics.step(delta)
	for item: Node2D in back_layers:
		item.refresh(dynamics, player_rect)
	if fore_layer != null:
		fore_layer.refresh(dynamics, player_rect)
