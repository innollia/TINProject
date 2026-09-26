class_name HazardField
extends RefCounted

const BUOY_PER_LIMB: float = 6.0
const TIDE_MAIN_FLOW: Vector2 = Vector2(0.0, -62.0)
const RETURN_FLOW: Vector2 = Vector2(0.0, -26.0)
const USE_RADIUS: float = 8.0


static func flow_at(runtime: StratumRuntime, point: Vector2, body: BodyRead) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	var inside: bool = false
	for current: Dictionary in runtime.currents:
		if bool(current["stilled"]):
			continue
		if (current["rect"] as Rect2).has_point(point):
			total += current["flow"] as Vector2
			inside = true
	if inside and body != null:
		var deficit: Variant = body.limb_deficit()
		if deficit is int:
			total.y -= BUOY_PER_LIMB * float(deficit as int)
	return total


static func apply(state: DescentState, runtime: StratumRuntime, delta: float, body: BodyRead = null) -> Dictionary:
	var events: Dictionary = {"opened": [] as Array[String]}
	var next_flow: Vector2 = flow_at(runtime, state.position, body)
	state.velocity += next_flow - state.flow
	state.flow = next_flow
	var box: Rect2 = state.body_box()
	for membrane: Dictionary in runtime.membranes:
		if bool(membrane["open"]):
			continue
		var near: bool = DescentCollision.distance_to_rect(box, membrane["rect"] as Rect2) <= USE_RADIUS
		var holding: bool = near and MatterLoop.first_index_with_verb(state.carried, String(membrane["verb"])) >= 0
		if holding and not RequiresBodyGate.is_open(membrane["requires_body"], body):
			holding = false
		if not holding:
			membrane["progress"] = 0.0
			continue
		membrane["progress"] = float(membrane["progress"]) + delta
		if float(membrane["progress"]) + 0.000001 >= float(membrane["hold_seconds"]):
			membrane["open"] = true
			(events["opened"] as Array[String]).append(String(membrane["id"]))
	return events
