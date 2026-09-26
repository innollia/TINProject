extends Node2D

const MAX_POINTS: int = 24
const FADE_TIME: float = 0.35
const MIN_SPEED: float = 120.0
const WIDTHS: Dictionary = {"short": 2.0, "long": 3.0}
const LIMITS: Dictionary = {"short": 12, "long": 24}

var color: Color
var _trails: Dictionary = {}


func setup(line_color: Color) -> void:
	color = line_color
	clear()


func clear() -> void:
	for key: Variant in _trails:
		var line: Line2D = _trails[key]["line"]
		if is_instance_valid(line):
			remove_child(line)
			line.free()
	_trails.clear()


func track(key: String, position_value: Vector2, speed: float, style: String, delta: float) -> void:
	if not LIMITS.has(style):
		return
	if not _trails.has(key):
		var line := Line2D.new()
		line.name = "Trail"
		line.width = float(WIDTHS[style])
		line.default_color = color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		add_child(line)
		_trails[key] = {"line": line, "points": [], "fade": 0.0, "limit": int(LIMITS[style])}
	var trail: Dictionary = _trails[key]
	if speed >= MIN_SPEED:
		var points: Array = trail["points"]
		points.append(position_value)
		while points.size() > int(trail["limit"]):
			points.pop_front()
		trail["fade"] = FADE_TIME
	trail["seen"] = true


func advance(delta: float) -> void:
	var gone: Array = []
	for key: Variant in _trails:
		var trail: Dictionary = _trails[key]
		if not bool(trail.get("seen", false)) or (trail["points"] as Array).size() > 0:
			trail["fade"] = float(trail["fade"]) - delta
		trail["seen"] = false
		var line: Line2D = trail["line"]
		var alpha: float = clampf(float(trail["fade"]) / FADE_TIME, 0.0, 1.0)
		line.modulate.a = alpha
		line.points = PackedVector2Array(trail["points"])
		if alpha <= 0.0:
			gone.append(key)
	for key: Variant in gone:
		var line: Line2D = _trails[key]["line"]
		remove_child(line)
		line.free()
		_trails.erase(key)


func point_count() -> int:
	var total: int = 0
	for key: Variant in _trails:
		total += (_trails[key]["points"] as Array).size()
	return total
