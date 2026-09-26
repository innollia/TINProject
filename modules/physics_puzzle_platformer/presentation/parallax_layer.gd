extends Node2D

const ProceduralBridge = preload("res://modules/physics_puzzle_platformer/presentation/procedural_bridge.gd")

var layer_name: String = ""
var elements: Array[Dictionary] = []
var sprites: Array[Sprite2D] = []


func build(name_value: String, items: Array[Dictionary], alpha: float, dynamics: RefCounted) -> void:
	layer_name = name_value
	name = name_value.capitalize() + "Layer"
	for sprite: Sprite2D in sprites:
		remove_child(sprite)
		sprite.free()
	sprites.clear()
	elements = items
	self_modulate.a = 1.0
	modulate.a = alpha
	for item: Dictionary in items:
		var sprite := Sprite2D.new()
		sprite.texture = item["texture"]
		sprite.scale = Vector2.ONE / ProceduralBridge.BACKDROP_RES
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.position = item["rest"]
		add_child(sprite)
		sprites.append(sprite)
		item["index"] = dynamics.add_element(layer_name, item["rest"])


func refresh(dynamics: RefCounted, player_rect: Rect2) -> void:
	for index: int in sprites.size():
		var sprite: Sprite2D = sprites[index]
		var at: Vector2 = dynamics.world_position(layer_name, int(elements[index]["index"]))
		sprite.position = at
		if layer_name == "fore":
			var size: Vector2 = elements[index]["size"]
			sprite.visible = not Rect2(at - size * 0.5, size).intersects(player_rect)


func element_count() -> int:
	return sprites.size()
