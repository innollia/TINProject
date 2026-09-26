class_name DescentCollision
extends RefCounted

const REGROW_SECONDS: float = 0.4
const LAND_SPEED_MIN: float = 20.0


static func resolve(state: DescentState, runtime: StratumRuntime, delta: float) -> Dictionary:
	var events: Dictionary = {"broken": [] as Array[String], "landed": false}
	var size: Vector2 = DescentState.box_size(state.mass)
	var half: Vector2 = size * 0.5
	var surging: bool = PlayerMotion.SURGE_BREAKS_BRITTLE and state.surge_active_for > 0.0
	tick_regrow(state, runtime, delta)
	var blockers: Array[Dictionary] = runtime.blockers()
	var moved_x: float = state.velocity.x
	var x: float = state.position.x + moved_x * delta
	var y: float = state.position.y
	for blocker: Dictionary in blockers:
		if bool(blocker.get("broken", false)):
			continue
		var rect: Rect2 = blocker["rect"]
		if not Rect2(Vector2(x, y) - half, size).intersects(rect):
			continue
		if surging and blocker["kind"] == "brittle":
			_break(state, blocker, events)
			continue
		if moved_x > 0.0:
			x = rect.position.x - half.x
		elif moved_x < 0.0:
			x = rect.end.x + half.x
		else:
			continue
		state.velocity.x = 0.0
	var clamped_x: float = clampf(x, runtime.bounds.position.x + half.x, runtime.bounds.end.x - half.x)
	if clamped_x != x:
		state.velocity.x = 0.0
	x = clamped_x
	var moved_y: float = state.velocity.y
	y = state.position.y + moved_y * delta
	for blocker: Dictionary in blockers:
		if bool(blocker.get("broken", false)):
			continue
		var rect: Rect2 = blocker["rect"]
		if not Rect2(Vector2(x, y) - half, size).intersects(rect):
			continue
		if surging and blocker["kind"] == "brittle":
			_break(state, blocker, events)
			continue
		if moved_y > 0.0:
			y = rect.position.y - half.y
			if moved_y >= LAND_SPEED_MIN:
				events["landed"] = true
		elif moved_y < 0.0:
			y = rect.end.y + half.y
		else:
			continue
		state.velocity.y = 0.0
	var clamped_y: float = clampf(y, runtime.bounds.position.y + half.y, runtime.bounds.end.y - half.y)
	if clamped_y != y:
		state.velocity.y = 0.0
	y = clamped_y
	state.position = Vector2(x, y)
	_depenetrate(state, runtime, blockers, surging, events)
	return events


static func tick_regrow(state: DescentState, runtime: StratumRuntime, delta: float) -> void:
	var box: Rect2 = state.body_box()
	for solid: Dictionary in runtime.solids:
		if not bool(solid["broken"]):
			continue
		solid["regrow_for"] = float(solid["regrow_for"]) - delta
		if float(solid["regrow_for"]) > 0.0:
			continue
		if box.intersects(solid["rect"] as Rect2):
			continue
		solid["broken"] = false
		solid["regrow_for"] = 0.0
		state.open_bristles.erase(String(solid["id"]))


static func _break(state: DescentState, solid: Dictionary, events: Dictionary) -> void:
	solid["broken"] = true
	solid["regrow_for"] = float(solid.get("regrow_seconds", REGROW_SECONDS))
	var solid_id: String = String(solid["id"])
	if not state.open_bristles.has(solid_id):
		state.open_bristles.append(solid_id)
	(events["broken"] as Array[String]).append(solid_id)


static func _depenetrate(state: DescentState, runtime: StratumRuntime, blockers: Array[Dictionary], surging: bool, events: Dictionary) -> void:
	for _pass: int in range(2):
		for blocker: Dictionary in blockers:
			if bool(blocker.get("broken", false)):
				continue
			var box: Rect2 = state.body_box()
			var rect: Rect2 = blocker["rect"]
			if not box.intersects(rect):
				continue
			if surging and blocker["kind"] == "brittle":
				_break(state, blocker, events)
				continue
			var left: float = box.end.x - rect.position.x
			var right: float = rect.end.x - box.position.x
			var up: float = box.end.y - rect.position.y
			var down: float = rect.end.y - box.position.y
			var least: float = minf(minf(left, right), minf(up, down))
			if least == up:
				state.position.y -= up
				state.velocity.y = minf(state.velocity.y, 0.0)
			elif least == down:
				state.position.y += down
				state.velocity.y = maxf(state.velocity.y, 0.0)
			elif least == left:
				state.position.x -= left
				state.velocity.x = minf(state.velocity.x, 0.0)
			else:
				state.position.x += right
				state.velocity.x = maxf(state.velocity.x, 0.0)
	var half: Vector2 = DescentState.box_size(state.mass) * 0.5
	state.position.x = clampf(state.position.x, runtime.bounds.position.x + half.x, runtime.bounds.end.x - half.x)
	state.position.y = clampf(state.position.y, runtime.bounds.position.y + half.y, runtime.bounds.end.y - half.y)


static func distance_to_rect(box: Rect2, rect: Rect2) -> float:
	var dx: float = maxf(0.0, maxf(rect.position.x - box.end.x, box.position.x - rect.end.x))
	var dy: float = maxf(0.0, maxf(rect.position.y - box.end.y, box.position.y - rect.end.y))
	return sqrt(dx * dx + dy * dy)


static func distance_to_point(box: Rect2, point: Vector2) -> float:
	var dx: float = maxf(0.0, maxf(box.position.x - point.x, point.x - box.end.x))
	var dy: float = maxf(0.0, maxf(box.position.y - point.y, point.y - box.end.y))
	return sqrt(dx * dx + dy * dy)
