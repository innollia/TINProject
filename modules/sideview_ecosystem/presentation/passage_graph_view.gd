class_name EcoPassageGraphView
extends Control

## §5.1, §11.6.2. 잠 화면의 방문 그래프. 방문한 룸만 원, link 는 1px 선. 미방문은
## 1px 점. 이름·숫자·순서 0.

var rooms_visited: PackedStringArray = PackedStringArray()
var all_room_ids: PackedStringArray = PackedStringArray()
var links: Array = []
var _positions: Dictionary = {}


func setup(p_all_room_ids: PackedStringArray, p_links: Array, p_rooms_visited: PackedStringArray) -> void:
	all_room_ids = p_all_room_ids
	links = p_links
	rooms_visited = p_rooms_visited
	_layout()
	queue_redraw()


func _layout() -> void:
	_positions.clear()
	var count: int = maxi(all_room_ids.size(), 1)
	var columns: int = maxi(ceili(sqrt(float(count))), 1)
	for index: int in all_room_ids.size():
		var col: int = index % columns
		var row: int = index / columns
		_positions[all_room_ids[index]] = Vector2(24.0 + float(col) * 20.0, 24.0 + float(row) * 20.0)


func _draw() -> void:
	for link: Dictionary in links:
		var from_id: String = String(link.get("from", ""))
		var to_id: String = String(link.get("to", ""))
		if not (_positions.has(from_id) and _positions.has(to_id)):
			continue
		draw_line(_positions[from_id], _positions[to_id], Color(1.0, 1.0, 1.0, 0.35), 1.0)
	for room_id: String in all_room_ids:
		var pos: Vector2 = _positions[room_id]
		if rooms_visited.has(room_id):
			draw_circle(pos, 4.0, Color(1.0, 1.0, 1.0, 0.9))
		else:
			draw_rect(Rect2(pos, Vector2(1.0, 1.0)), Color(1.0, 1.0, 1.0, 0.4), true)
