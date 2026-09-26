class_name EcoWorldState
extends RefCounted

var body_rung: String = "speck"
var integrity: float = 1
var position_px: Vector2 = Vector2.ZERO
var velocity_px: Vector2 = Vector2.ZERO
var facing: int = 1
var on_ground: bool = false
var coyote_left: float = 0.0
var jump_buffer_left: float = 0.0
var holding: bool = false
var held_creature_id: int = -1
var t_settle: float = 0.0
var current_band: String = "speck"
var t_in_room: float = 0.0
var current_room_id: String = ""
var previous_room_id: String = ""
var rooms_visited: PackedStringArray = []
var broken_walls: PackedStringArray = []
var trigger_flags: Dictionary = {}
var shelters_touched: PackedStringArray = []
var respawn_room: String = ""
var respawn_pos_px: Vector2 = Vector2.ZERO
var creatures: Dictionary = {}
var dens: Dictionary = {}
var deaths: int = 0
var sleeps: int = 0
var compressed_beds: Dictionary = {}
var drift_drops: Dictionary = {}
var local_wounds: Array = []
var t_since_death: float = 0.0


func visit(room_id: String) -> void:
	if not rooms_visited.has(room_id):
		rooms_visited.append(room_id)


func touch_shelter(shelter_id: String) -> void:
	if not shelters_touched.has(shelter_id):
		shelters_touched.append(shelter_id)


func break_wall(passage_id: String) -> void:
	if not broken_walls.has(passage_id):
		broken_walls.append(passage_id)


func is_wall_broken(passage_id: String) -> bool:
	return broken_walls.has(passage_id)


func is_consumed(trigger_id: String) -> bool:
	return bool(trigger_flags.get(trigger_id, false))
