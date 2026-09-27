class_name EcoTrailRenderer
extends Node2D

## §5.1. 착지·연속 접촉이 남기는 궤적 줄. 최대 24점, 0.35초 페이드.

const MAX_POINTS: int = 24
const FADE_TIME: float = 0.35

var _points: Array = []


func add_point(position: Vector2) -> void:
	_points.append([position, FADE_TIME])
	if _points.size() > MAX_POINTS:
		_points.pop_front()
	queue_redraw()


func step(delta: float) -> void:
	var changed: bool = false
	for index: int in range(_points.size() - 1, -1, -1):
		_points[index][1] -= delta
		if _points[index][1] <= 0.0:
			_points.remove_at(index)
		changed = true
	if changed:
		queue_redraw()


func clear_trail() -> void:
	_points.clear()
	queue_redraw()


func _draw() -> void:
	for entry: Array in _points:
		var alpha: float = clampf(float(entry[1]) / FADE_TIME, 0.0, 1.0)
		draw_circle(entry[0], 2.0, Color(1.0, 1.0, 1.0, alpha * 0.3))
