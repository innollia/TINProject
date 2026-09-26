extends RefCounted

var _view: WorldStateView = null


static func from_arrival(arrival: Dictionary) -> RefCounted:
	var wrapper: RefCounted = load("res://modules/physics_puzzle_platformer/domain/axis_view.gd").new()
	wrapper._view = WorldStateView.from_arrival(arrival)
	return wrapper


func has_view() -> bool:
	return _view != null


func has_body() -> bool:
	return _view != null and _view.has_body()


func get_body() -> AxisBody:
	if not has_body():
		return null
	return _view.get_body()


func get_focus_place_id() -> String:
	if _view == null:
		return ""
	return _view.get_focus_place_id()


func has_place(place_id: String) -> bool:
	return _view != null and _view.has_place(place_id)


func get_place(place_id: String) -> AxisPlace:
	if not has_place(place_id):
		return null
	return _view.get_place(place_id)


func get_creature_ids() -> Array[String]:
	if _view == null:
		return []
	return _view.get_creature_ids()


func get_creature(creature_id: String) -> AxisCreature:
	if _view == null:
		return null
	return _view.get_creature(creature_id)
