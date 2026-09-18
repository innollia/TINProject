extends GameModule

const ACTIONS: Array[StringName] = [&"memory_customs_left", &"memory_customs_right", &"memory_customs_up", &"memory_customs_down", &"memory_customs_confirm", &"memory_customs_cancel"]
const NAMES: Array[String] = ["몸", "기억", "우산", "찻잔"]
const SOLUTION: Array[bool] = [true, true, false, false]

var selected: int = 0
var stamps: Array[bool] = [false, false, false, false]
var changes: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _cards: Array[ColorRect] = []
var _marks: Array[Label] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("132d31")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("기억 세관", Vector2(62, 46), 42, Color("e7fff9"))
	_label("문턱은 손에 든 것을 받지 않는다. 걷는 사람과 지나온 일만 통과한다.", Vector2(64, 106), 20, Color("a8d5cc"))
	for index: int in range(4):
		var column: int = index % 2
		var row: int = index / 2
		var card := ColorRect.new()
		card.position = Vector2(270 + column * 330, 185 + row * 180)
		card.size = Vector2(280, 130)
		card.color = Color("285158")
		background.add_child(card)
		_cards.append(card)
		_label(NAMES[index], card.position + Vector2(24, 35), 32, Color("e7fff9"))
		var mark := _label("미도장", card.position + Vector2(150, 43), 20, Color("8fbab2"))
		mark.size.x = 110
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_marks.append(mark)
	_label("방향키 통과표 선택   Z 도장/취소   X 사물함", Vector2(64, 558), 20, Color("e7fff9"))
	_status = _label("통과할 것에만 도장을 찍는다.", Vector2(64, 618), 19, Color("a8d5cc"))
	_refresh()

func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_refresh()

func exit() -> void:
	_held.clear()
	super.exit()

func _process(_delta: float) -> void:
	if not _can_input(): _held.clear(); return
	for index: int in range(ACTIONS.size()):
		var pressed: bool = context.is_action_pressed(ACTIONS[index])
		var previous: bool = bool(_held.get(ACTIONS[index], false))
		_held[ACTIONS[index]] = pressed
		if pressed and not previous:
			if index == 0: execute_command(&"move", {"x": -1, "y": 0})
			elif index == 1: execute_command(&"move", {"x": 1, "y": 0})
			elif index == 2: execute_command(&"move", {"x": 0, "y": -1})
			elif index == 3: execute_command(&"move", {"x": 0, "y": 1})
			elif index == 4: execute_command(&"stamp")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"move":
			var x: Variant = payload.get("x")
			var y: Variant = payload.get("y")
			if not x is int or not y is int or absi(x) + absi(y) != 1: return false
			var column: int = posmod(selected % 2 + x, 2)
			var row: int = posmod(selected / 2 + y, 2)
			selected = row * 2 + column
		&"stamp":
			stamps[selected] = not stamps[selected]
			changes = mini(changes + 1, 9999)
			if stamps == SOLUTION:
				requested.emit(&"observation", {"id": "memory_customs.pass", "text": "기억 세관은 몸과 기억에만 도장을 찍었을 때 문턱을 열었다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"selected": selected, "stamps": stamps.duplicate(), "changes": changes}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	selected = int(clean["selected"])
	stamps.assign(clean["stamps"])
	changes = int(clean["changes"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_stamps: Array[bool] = [false, false, false, false]
	if data.get("stamps") is Array and data["stamps"].size() == 4:
		var candidate: Array[bool] = []
		for value: Variant in data["stamps"]:
			if not value is bool: candidate.clear(); break
			candidate.append(value)
		if candidate.size() == 4: clean_stamps = candidate
	return {"selected": _integer(data.get("selected"), 0, 0, 3), "stamps": clean_stamps, "changes": _integer(data.get("changes"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(4):
		_cards[index].color = Color("4b7b78") if index == selected else Color("285158")
		_marks[index].text = "통과" if stamps[index] else "미도장"
		_marks[index].add_theme_color_override("font_color", Color("ffd18a") if stamps[index] else Color("8fbab2"))
	_status.text = "도장 변경 %d회 · 몸과 기억만 문턱 앞에 남는다." % changes

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 70)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	add_child(label)
	return label
