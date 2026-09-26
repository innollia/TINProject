extends RefCounted

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")


static func progress(path: Dictionary, time: float) -> float:
	var duration: float = maxf(float(path.get("duration", 1.0)), 0.0001)
	if String(path.get("loop", "once")) == "pingpong":
		var cycle: float = fposmod(time, duration * 2.0) / duration
		return cycle if cycle <= 1.0 else 2.0 - cycle
	return clampf(time / duration, 0.0, 1.0)


static func position_at(path: Dictionary, time: float, wind_x: float) -> Vector2:
	var u: float = progress(path, time)
	var eased: float = 0.5 - 0.5 * cos(PI * u)
	var start: Vector2 = path.get("from", Vector2.ZERO)
	var finish: Vector2 = path.get("to", Vector2.ZERO)
	var drift: float = Tuning.WIND_DRIFT * (wind_x / Tuning.WIND_REFERENCE) * sin(PI * u)
	return start.lerp(finish, eased) + Vector2(drift, 0.0)


static func step(entries: Array, nodes: Array, bodies: Array, time: float, wind_x: float, delta: float) -> void:
	for entry: Dictionary in entries:
		var index: int = int(entry["index"])
		var node: Node2D = nodes[index] as Node2D
		if node == null:
			continue
		var target: Vector2 = position_at(entry["path"], time, wind_x)
		var velocity: Vector2 = (target - node.position) / maxf(delta, 0.0001)
		node.position = target
		bodies[index].x = target.x
		bodies[index].y = target.y
		bodies[index].vx = velocity.x
		bodies[index].vy = velocity.y
