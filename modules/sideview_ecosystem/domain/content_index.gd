class_name EcoContentIndex
extends RefCounted

var schema: int = 1
var content_seed: int = 0
var regions: Array[EcoRegionSpec] = []
var rooms: Dictionary = {}
var archetypes: Dictionary = {}
var archetype_ids: PackedStringArray = []
var start_room: String = ""
var start_shelter: String = ""
var start_rung: String = ""
var passage_room: Dictionary = {}
var trigger_room: Dictionary = {}
var shelter_room: Dictionary = {}
var links: Array[Dictionary] = []


func room(room_id: String) -> EcoRoomSpec:
	return rooms.get(room_id) as EcoRoomSpec


func room_count() -> int:
	return rooms.size()


func passage(passage_id: String) -> EcoPassageSpec:
	var owner: EcoRoomSpec = room(str(passage_room.get(passage_id, "")))
	if owner == null:
		return null
	return owner.passage(passage_id)


func all_room_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for region: EcoRegionSpec in regions:
		ids.append_array(region.room_ids)
	return ids


func archetype(archetype_id: String) -> Dictionary:
	return archetypes.get(archetype_id, {})
