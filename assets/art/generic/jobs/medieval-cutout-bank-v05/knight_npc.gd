extends CharacterBody2D

signal interacted

const ASSET_ROOT := "res://assets/art/generic/jobs/medieval-cutout-bank-v05/"
const WING_ROOT := "res://assets/art/generic/jobs/medieval-cutout-bank-v04/candidates/cutouts/"
const PART_ORDER: Array[String] = [
	"chest", "neck", "head", "abdomen", "pelvis", "grape_insignia",
	"left_upper_arm", "left_forearm", "left_hand", "sword",
	"right_upper_arm", "right_forearm", "right_hand", "shield",
	"left_thigh", "left_shin", "left_foot",
	"right_thigh", "right_shin", "right_foot",
	"left_wing", "right_wing",
]

@export var auto_demo := true
@export var wings_enabled := true
@export var painted_shield_enabled := true
@export var patrol_half_width := 80.0
@export var patrol_speed := 24.0

var action: String = "idle"
var _clock := 0.0
var _action_time := 0.0
var _patrol_origin := 0.0
var _direction := 1.0
var _records: Dictionary = {}
var _sprites: Dictionary = {}
var _positions: Dictionary = {}
var _angles: Dictionary = {}

@onready var _visual_root: Node2D = $VisualRoot


func _ready() -> void:
	_patrol_origin = global_position.x
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ASSET_ROOT + "candidates/parts_manifest_v05.json"))
	if not parsed is Dictionary:
		push_error("Knight part manifest is invalid")
		return
	for raw: Variant in parsed["parts"]:
		var record: Dictionary = (raw as Dictionary).duplicate(true)
		if painted_shield_enabled and str(record["id"]) == "shield":
			continue
		if not painted_shield_enabled and str(record["id"]) == "painted_shield":
			continue
		if str(record["id"]) == "painted_shield":
			record["id"] = "shield"
		_register_part(record)
	_register_part({
		"id": "left_wing", "file": WING_ROOT + "archangel_left_wing.png",
		"parent": "chest", "pivot_local": [640, 480], "rest_joint": [300, 360],
		"draw_order": -10,
	})
	_register_part({
		"id": "right_wing", "file": WING_ROOT + "archangel_right_wing.png",
		"parent": "chest", "pivot_local": [150, 540], "rest_joint": [595, 360],
		"draw_order": -10,
	})
	_update_pose(0.0)


func _register_part(record: Dictionary) -> void:
	var id: String = str(record["id"])
	var file_path: String = str(record["file"])
	if not file_path.begins_with("res://"):
		file_path = ASSET_ROOT + file_path
	var texture: Texture2D = load(file_path) as Texture2D
	if texture == null:
		push_error("Missing knight part: " + file_path)
		return
	var sprite := Sprite2D.new()
	sprite.name = id
	sprite.texture = texture
	sprite.centered = false
	var pivot: Array = record["pivot_local"]
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	sprite.scale = Vector2.ONE * 0.5 * _visual_scale(id)
	sprite.z_index = int(record["draw_order"])
	_visual_root.add_child(sprite)
	_records[id] = record
	_sprites[id] = sprite
	_positions[id] = _rest(id)
	_angles[id] = _rest_angle(id)


func _physics_process(delta: float) -> void:
	_clock += delta
	_action_time += delta
	if auto_demo:
		_update_demo()
	velocity = Vector2.ZERO
	if action == "walk":
		velocity.x = _direction * patrol_speed
		move_and_slide()
	_update_pose(delta)


func _update_demo() -> void:
	var phase := fmod(_clock, 8.0)
	if phase < 2.0:
		_set_action("walk")
		_direction = 1.0
	elif phase < 2.5:
		_set_action("idle")
	elif phase < 3.5:
		_set_action("look")
	elif phase < 4.5:
		_set_action("use")
	elif phase < 6.5:
		_set_action("walk")
		_direction = -1.0
	else:
		_set_action("idle")
	if global_position.x > _patrol_origin + patrol_half_width:
		_direction = -1.0
	elif global_position.x < _patrol_origin - patrol_half_width:
		_direction = 1.0


func set_action(value: String) -> void:
	if value in ["idle", "walk", "look", "use"]:
		_set_action(value)


func set_wings_enabled(value: bool) -> void:
	wings_enabled = value
	for id: String in ["left_wing", "right_wing"]:
		if _sprites.has(id):
			(_sprites[id] as Sprite2D).visible = value


func interact() -> void:
	_set_action("look")
	interacted.emit()


func _set_action(value: String) -> void:
	if action != value:
		action = value
		_action_time = 0.0


func _update_pose(delta: float) -> void:
	if _records.is_empty():
		return
	var period := 1.4 if action == "walk" else 2.0
	var wave := TAU * _action_time / period
	var chest_bob := -absf(sin(wave)) * (5.0 if action == "walk" else 2.0)
	_positions["chest"] = _rest("chest") + Vector2(0.0, chest_bob)
	_angles["chest"] = deg_to_rad(sin(wave * 2.0) * (5.0 if action == "look" else 1.2))
	for id: String in PART_ORDER:
		if not _records.has(id) or id == "chest":
			continue
		var record: Dictionary = _records[id]
		var parent: String = str(record.get("parent", ""))
		var parent_pos: Vector2 = _positions[parent]
		var parent_angle: float = _angles[parent]
		var offset: Vector2 = (_rest(id) - _rest(parent)).rotated(parent_angle - _rest_angle(parent))
		_positions[id] = parent_pos + offset
		var target_angle: float = parent_angle + _rest_angle(id) - _rest_angle(parent) + _motion_angle(id, wave)
		var previous_angle: float = _angles[id]
		_angles[id] = lerp_angle(previous_angle, target_angle, clampf(delta * 12.0, 0.0, 1.0))
	if action == "walk":
		_solve_leg("left", 0.0, 1.0, period)
		_solve_leg("right", 0.5, -1.0, period)
	for id: String in PART_ORDER:
		if not _sprites.has(id):
			continue
		var sprite: Sprite2D = _sprites[id]
		sprite.position = (_positions[id] - Vector2(500.0, 1220.0)) * 0.5
		sprite.rotation = _angles[id] - _rest_angle(id)
		if id.ends_with("_wing"):
			sprite.visible = wings_enabled


func _motion_angle(id: String, wave: float) -> float:
	if id == "head":
		return deg_to_rad(sin(wave) * (18.0 if action == "look" else 6.0))
	if id == "left_upper_arm":
		return deg_to_rad(sin(wave) * (-23.0 if action == "use" else 12.0 if action == "walk" else 5.0))
	if id == "left_forearm":
		return deg_to_rad(sin(wave) * (-29.0 if action == "use" else 7.0))
	if id == "right_upper_arm":
		return deg_to_rad(sin(wave + PI) * (18.0 if action == "use" else 12.0 if action == "walk" else 5.0))
	if id == "right_forearm":
		return deg_to_rad(sin(wave + PI) * (24.0 if action == "use" else 6.0))
	if id.ends_with("_wing"):
		return deg_to_rad(sin(wave) * 8.0)
	return 0.0


func _solve_leg(side: String, offset: float, bend: float, period: float) -> void:
	var thigh := side + "_thigh"
	var shin := side + "_shin"
	var foot := side + "_foot"
	var pelvis_pos: Vector2 = _positions["pelvis"]
	var hip: Vector2 = pelvis_pos + (_rest(thigh) - _rest("pelvis"))
	var phase := fmod(_action_time / period + offset, 1.0)
	var duty := 0.63
	var stride := 42.0
	var lift := 36.0
	var x := 0.0
	var y := 1220.0
	if phase < duty:
		x = _rest(foot).x + stride * (0.5 - phase / duty)
	else:
		var swing := (phase - duty) / (1.0 - duty)
		x = _rest(foot).x + stride * (-0.5 + swing)
		y -= lift * sin(PI * swing)
	var target := Vector2(x, y)
	var upper_length := _rest(thigh).distance_to(_rest(shin))
	var lower_length := _rest(shin).distance_to(_rest(foot))
	var delta_pos := target - hip
	var reach := clampf(delta_pos.length(), absf(upper_length - lower_length) + 0.001,
		upper_length + lower_length - 0.001)
	var base := delta_pos.angle()
	var cosine := (upper_length * upper_length + reach * reach - lower_length * lower_length) / (2.0 * upper_length * reach)
	var upper_angle := base - acos(clampf(cosine, -1.0, 1.0)) * bend
	var knee := hip + Vector2.RIGHT.rotated(upper_angle) * upper_length
	_positions[thigh] = hip
	_angles[thigh] = upper_angle
	_positions[shin] = knee
	_angles[shin] = (target - knee).angle()
	_positions[foot] = target
	_angles[foot] = 0.0


func _rest(id: String) -> Vector2:
	var array: Array = _records[id]["rest_joint"]
	return Vector2(float(array[0]), float(array[1]))


func _rest_angle(id: String) -> float:
	return PI * 0.5 if id in ["left_thigh", "right_thigh", "left_shin", "right_shin"] else 0.0


func _visual_scale(id: String) -> float:
	if id == "sword":
		return 0.42
	if id == "shield":
		return 0.30 if painted_shield_enabled else 0.44
	if id == "grape_insignia":
		return 0.115
	if id.ends_with("_wing"):
		return 0.36
	return 1.0
