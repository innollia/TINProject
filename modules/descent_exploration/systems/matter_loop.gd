class_name MatterLoop
extends RefCounted

const MAX_CARRY_MASS: int = 4
const PICKUP_RADIUS: float = 6.0
const USE_RADIUS: float = 8.0
const TARGETLESS_VERBS: Array[String] = ["weigh", "strike"]


static func first_index_with_verb(carried: Array[MatterItem], verb: String) -> int:
	if verb.is_empty() or verb == "weigh":
		return -1
	for index: int in carried.size():
		if carried[index].verb == verb:
			return index
	return -1


static func tick_pickup(state: DescentState, runtime: StratumRuntime) -> Dictionary:
	var events: Dictionary = {"picked": [] as Array[String], "denied": false}
	for entry: Dictionary in runtime.matter:
		if not bool(entry["present"]):
			continue
		var near: bool = DescentCollision.distance_to_point(state.body_box(), entry["position"] as Vector2) <= PICKUP_RADIUS
		if not near:
			entry["touching"] = false
			continue
		var item: MatterItem = (entry["item"] as MatterItem).copy()
		if state.pick_up(item):
			entry["present"] = false
			entry["touching"] = false
			(events["picked"] as Array[String]).append(item.id)
		elif not bool(entry["touching"]):
			events["denied"] = true
		entry["touching"] = true
	return events


static func find_target(state: DescentState, runtime: StratumRuntime, item: MatterItem, body: BodyRead = null) -> Dictionary:
	if item == null or TARGETLESS_VERBS.has(item.verb):
		return {}
	var box: Rect2 = state.body_box()
	if item.verb == "plug":
		for current: Dictionary in runtime.currents:
			if bool(current["stilled"]):
				continue
			if DescentCollision.distance_to_rect(box, current["rect"] as Rect2) <= USE_RADIUS:
				return {"kind": "current", "entry": current}
	for membrane: Dictionary in runtime.membranes:
		if String(membrane["verb"]) != item.verb:
			continue
		if DescentCollision.distance_to_rect(box, membrane["rect"] as Rect2) > USE_RADIUS:
			continue
		if not RequiresBodyGate.is_open(membrane["requires_body"], body):
			continue
		return {"kind": "membrane", "entry": membrane}
	return {}


static func consume(state: DescentState, runtime: StratumRuntime, pressed: bool, body: BodyRead = null) -> Dictionary:
	if not pressed:
		return {}
	for index: int in state.carried.size():
		var item: MatterItem = state.carried[index]
		var target: Dictionary = find_target(state, runtime, item, body)
		if target.is_empty():
			continue
		var entry: Dictionary = target["entry"]
		if not state.consume(index, String(entry["id"])):
			return {"denied": true}
		if target["kind"] == "current":
			entry["stilled"] = true
		else:
			entry["open"] = true
			entry["progress"] = 0.0
		return {"consumed": true, "matter": item.id, "target": String(entry["id"]), "target_kind": String(target["kind"])}
	return {"denied": true}
