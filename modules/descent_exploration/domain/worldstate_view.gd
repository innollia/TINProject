class_name DescentWorldstateView
extends RefCounted

const ARRIVAL_KEY: String = "world_state_view"
const REGION_ID: String = "region_hollow"
const BODY_KEY: String = "body"
const CREATURES_KEY: String = "creatures"
const PLACES_KEY: String = "places"

var _snapshot: Dictionary = {}
var _present: bool = false
var _body: BodyRead = null
var _warnings: Array[String] = []


static func from_arrival(arrival: Dictionary) -> DescentWorldstateView:
	var carried: Variant = arrival.get(ARRIVAL_KEY)
	if carried is Object and is_instance_valid(carried) and (carried as Object).has_method("to_dictionary"):
		var snapshot: Variant = (carried as Object).call("to_dictionary")
		if snapshot is Dictionary:
			return from_snapshot(snapshot as Dictionary)
	return DescentWorldstateView.new()


static func from_snapshot(snapshot: Dictionary) -> DescentWorldstateView:
	var view := DescentWorldstateView.new()
	view._snapshot = snapshot.duplicate(true)
	view._present = true
	var body_source: Variant = view._snapshot.get(BODY_KEY)
	if body_source is Dictionary:
		view._body = BodyRead.from_body(body_source)
	else:
		view._warnings.append("descent: the arrival view carries no body; body rules are not applied this run")
	return view


func is_present() -> bool:
	return _present


func has_body() -> bool:
	return _body != null


func body() -> BodyRead:
	return _body


func startup_warnings() -> Array[String]:
	return _warnings.duplicate()


func limb_deficit() -> Variant:
	return null if _body == null else _body.limb_deficit()


func hands_free() -> Variant:
	return null if _body == null else _body.hands_free()


func has_wound(spec: Dictionary) -> bool:
	return _body != null and _body.has_wound(spec)


func has_creature(id: String) -> bool:
	return _creature(id) != null


func creature_state(id: String) -> Variant:
	var record: Variant = _creature(id)
	if record == null:
		return null
	return (record as Dictionary).get("state")


func creature_den(id: String) -> Variant:
	var record: Variant = _creature(id)
	if record == null:
		return null
	return (record as Dictionary).get("den")


func has_place(id: String) -> bool:
	return _place(id) != null


func place_region(id: String) -> Variant:
	var record: Variant = _place(id)
	if record == null:
		return null
	return (record as Dictionary).get("region_id")


func place_requires_body(id: String) -> Variant:
	var record: Variant = _place(id)
	if record == null:
		return null
	var requirement: Variant = (record as Dictionary).get("requires_body", {})
	return (requirement as Dictionary).duplicate(true) if requirement is Dictionary else null


func body_wounds() -> Array:
	if _body == null:
		return []
	return _body.wounds()


func _creature(id: String) -> Variant:
	var creatures: Variant = _snapshot.get(CREATURES_KEY)
	if not creatures is Dictionary:
		return null
	var record: Variant = (creatures as Dictionary).get(id)
	return record if record is Dictionary else null


func _place(id: String) -> Variant:
	var places: Variant = _snapshot.get(PLACES_KEY)
	if not places is Dictionary:
		return null
	var record: Variant = (places as Dictionary).get(id)
	return record if record is Dictionary else null
