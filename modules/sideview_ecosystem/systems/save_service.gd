class_name EcoSaveService
extends RefCounted

const SAVE_PATH: String = "user://sideview_ecosystem_save.json"
const REASON_AXIS_RUNG_FOREIGN: String = "axis_rung_foreign"
const POINTS: Array[String] = ["S1", "S2", "S3", "S4", "S5"]

var path: String = SAVE_PATH
var write_log: PackedStringArray = []
var enabled: bool = true


static func shelter_foot(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * EcoBodyRung.TILE + EcoBodyRung.TILE * 0.5, (cell.y + 1) * EcoBodyRung.TILE)


static func new_world(index: EcoContentIndex) -> EcoWorldState:
	var w: EcoWorldState = EcoWorldState.new()
	w.current_room_id = index.start_room
	w.body_rung = index.start_rung
	var room: EcoRoomSpec = index.room(index.start_room)
	if room != null:
		w.current_band = room.band
		var shelter: Dictionary = room.shelter_by_id(index.start_shelter)
		if not shelter.is_empty():
			w.position_px = shelter_foot(shelter["cell"])
	w.respawn_room = w.current_room_id
	w.respawn_pos_px = w.position_px
	w.shelters_touched = PackedStringArray([index.start_shelter])
	return w


func write_file(data: Dictionary, point: String) -> int:
	if not POINTS.has(point):
		push_warning("sideview_ecosystem save outside S1..S5: " + point)
		return ERR_INVALID_PARAMETER
	write_log.append(point)
	if not enabled:
		return OK
	var tmp: String = path + ".tmp"
	var f: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("sideview_ecosystem save failed: " + str(FileAccess.get_open_error()))
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var err: int = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(path))
	if err != OK:
		push_warning("sideview_ecosystem save rename failed: " + str(err))
	return err


func read_file() -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_warning("sideview_ecosystem save unreadable")
		return null
	return parsed


func delete_file() -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func begin(bridge: EcoWorldstateBridge, index: EcoContentIndex, table: EcoRungTable, saved: Variant) -> Dictionary:
	var result: Dictionary = {"ok": true, "reason": "", "world": null, "world_seed": index.content_seed, "wrote_start_rung": false, "warnings": PackedStringArray()}
	var world: EcoWorldState = null
	var saved_rung: String = ""
	if saved is Dictionary:
		var decoded: Dictionary = EcoSaveCodec.decode(saved)
		if decoded["ok"]:
			world = decoded["value"]
			result["world_seed"] = int(decoded["world_seed"])
			saved_rung = world.body_rung
			if int(decoded["content_seed"]) != index.content_seed:
				(result["warnings"] as PackedStringArray).append("content_seed_mismatch")
		else:
			(result["warnings"] as PackedStringArray).append(str(decoded["reason"]))
	if world == null:
		world = new_world(index)
	if index.room(world.current_room_id) == null:
		if index.room(world.respawn_room) != null:
			world.current_room_id = world.respawn_room
			world.position_px = world.respawn_pos_px
		else:
			var fresh: EcoWorldState = new_world(index)
			world.current_room_id = fresh.current_room_id
			world.position_px = fresh.position_px
			world.respawn_room = fresh.respawn_room
			world.respawn_pos_px = fresh.respawn_pos_px
	var room: EcoRoomSpec = index.room(world.current_room_id)
	world.current_band = room.band
	var axis: EcoBodyAxis = bridge.read_body() if bridge != null else EcoBodyAxis.new()
	if bridge != null and bridge.has_store():
		world.local_wounds = []
		if axis.has_scale:
			var body: EcoBodyRung = table.from_axis_value(axis.scale_value)
			if body == null:
				push_error("sideview_ecosystem: body.scale is not a rung this module can build")
				result["ok"] = false
				result["reason"] = REASON_AXIS_RUNG_FOREIGN
				result["world"] = world
				return result
			if not saved_rung.is_empty() and saved_rung != body.rung:
				(result["warnings"] as PackedStringArray).append("rung_differs_from_axis")
			world.body_rung = body.rung
		else:
			var start_value: float = table.ladder.value_of(index.start_rung)
			var wrote: Dictionary = bridge.write_scale(start_value)
			result["wrote_start_rung"] = bool(wrote.get("ok", false))
			world.body_rung = index.start_rung
	elif axis.has_scale and table.from_axis_value(axis.scale_value) != null:
		world.body_rung = table.from_axis_value(axis.scale_value).rung
	elif not table.has_name(world.body_rung):
		world.body_rung = index.start_rung
	result["world"] = world
	return result
