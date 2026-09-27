class_name EcoWorldstateBridge
extends RefCounted

const REQUESTER: StringName = &"sideview_ecosystem"
const AXIS_BODY: StringName = &"body"
const AXIS_CREATURE: StringName = &"creature"
const AXIS_PLACE: StringName = &"place"

var store: WorldState = null
var view: WorldStateView = null
var requests: Array[Dictionary] = []
var warnings: PackedStringArray = []


static func from_arrival(arrival: Dictionary) -> EcoWorldstateBridge:
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	if not arrival.is_empty():
		bridge.view = WorldStateView.from_arrival(arrival)
	return bridge


static func store_rung_values() -> Array:
	return Array(AxisBody.SCALE_RUNGS).duplicate()


func attach_world_store(p_store: WorldState) -> void:
	store = p_store
	if store != null and view == null:
		view = store.issue_view()


func release() -> void:
	store = null
	view = null


func has_store() -> bool:
	return store != null


func has_view() -> bool:
	return view != null


func read_body() -> EcoBodyAxis:
	return EcoBodyAxis.from_view(view)


func read_creature(creature_id: String) -> EcoCreatureAxis:
	return EcoCreatureAxis.from_view(view, creature_id)


func _send(axis: StringName, patch: Dictionary) -> Dictionary:
	requests.append({"axis": String(axis), "patch": patch.duplicate(true)})
	if store == null:
		return {"ok": false, "reason": "store_absent", "detail": ""}
	var result: Dictionary = store.request_mutation(axis, patch, REQUESTER)
	if not bool(result.get("ok", false)):
		warnings.append("%s %s" % [axis, result.get("reason", "")])
		push_warning("sideview_ecosystem axis write refused: %s %s" % [axis, result.get("reason", "")])
	return result


func write_wounds(merged: Array) -> Dictionary:
	return _send(AXIS_BODY, EcoBodyAxis.wounds_patch(merged))


func write_scale(value: float) -> Dictionary:
	return _send(AXIS_BODY, EcoBodyAxis.scale_patch(value))


func write_creature(axis: EcoCreatureAxis) -> Dictionary:
	return _send(AXIS_CREATURE, axis.to_patch())


func write_place(patch: Dictionary) -> Dictionary:
	return _send(AXIS_PLACE, patch)
