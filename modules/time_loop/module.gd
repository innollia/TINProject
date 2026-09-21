extends GameModule

const ACTIONS: Array[StringName] = [&"time_loop_left", &"time_loop_right", &"time_loop_up", &"time_loop_down", &"time_loop_confirm", &"time_loop_cancel"]
const MODE_NAMES: Array[String] = ["반복 관찰", "다음 경로", "루프 증명"]
const EVENT_NAMES: Array[String] = ["창문이 열림", "종이 울림", "그림자가 건넘"]
const EVENT_TEXT: Array[String] = [
	"첫 박자에 창문이 열리며 안쪽 벽에 짧은 빛이 남는다.",
	"둘째 박자에 종이 울리고, 그 진동이 바닥의 선을 바꾼다.",
	"셋째 박자에 그림자가 건너가며 다음 루프의 문이 보인다."
]
const SOLUTION: Array[int] = [0, 1, 2]
const SOLVED_TEXT: String = "창문·종·그림자의 순서를 기억한 뒤 다음 루프의 문을 열었다."

var mode: int = 0
var focus: int = 0
var beat: int = 0
var known: Array[bool] = [false, false, false]
var route: Array[int] = [0, 0, 0]
var loops: int = 0
var resets: int = 0
var attempts: int = 0
var mistakes: int = 0
var solved: bool = false
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _clock_label: Label
var _body: Label
var _status: Label
var _event_cards: Array[ColorRect] = []
var _event_marks: Array[Label] = []
var _route_rows: Array[ColorRect] = []
var _route_labels: Array[Label] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("171f2d")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("세 박자 뒤의 방", Vector2(60, 40), 40, Color("f0dfb2"))
	_label("이번 루프의 기억은 남고, 방의 시계만 처음으로 돌아간다", Vector2(64, 96), 20, Color("bac7d1"))
	_mode_label = _label("반복 관찰", Vector2(64, 132), 18, Color("ddac6b"))
	_clock_label = _label("", Vector2(770, 94), 20, Color("e8cb89"))
	var room := ColorRect.new()
	room.color = Color("29384b")
	room.position = Vector2(60, 178)
	room.size = Vector2(610, 350)
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(room)
	_label("되풀이되는 방", Vector2(88, 204), 24, Color("f0dfb2"))
	_body = _label("", Vector2(92, 244), 19, Color("dbe7ef"))
	_body.size = Vector2(540, 80)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(92, 342 + index * 54)
		card.size = Vector2(540, 42)
		card.color = Color("38516a")
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(card)
		_event_cards.append(card)
		var title := _label(EVENT_NAMES[index], card.position + Vector2(14, 8), 17, Color("f0dfb2"))
		title.size.x = 240
		var mark := _label("기억 안 함", card.position + Vector2(390, 8), 16, Color("acbfca"))
		mark.size.x = 130
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_event_marks.append(mark)
	var loop_card := ColorRect.new()
	loop_card.position = Vector2(92, 504)
	loop_card.size = Vector2(540, 42)
	loop_card.color = Color("594963")
	loop_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(loop_card)
	_label("되감기", loop_card.position + Vector2(14, 8), 17, Color("f0dfb2"))
	_label("기억을 남기고 박자를 처음으로", loop_card.position + Vector2(236, 8), 16, Color("c9bed4"))
	var route_panel := ColorRect.new()
	route_panel.color = Color("302c3e")
	route_panel.position = Vector2(700, 178)
	route_panel.size = Vector2(390, 350)
	route_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(route_panel)
	_label("다음 경로", Vector2(730, 204), 24, Color("f0dfb2"))
	_label("기억한 세 박자를 칸에 옮긴다", Vector2(732, 242), 17, Color("c7bfd0"))
	for index: int in range(3):
		var row := ColorRect.new()
		row.position = Vector2(728, 286 + index * 76)
		row.size = Vector2(334, 58)
		row.color = Color("4a4260")
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(row)
		_route_rows.append(row)
		var row_label := _label("", row.position + Vector2(14, 8), 17, Color("f5e9ff"))
		row_label.size = Vector2(306, 44)
		_route_labels.append(row_label)
	_label("←→ 대상/칸 선택   ↑↓ 경로 변경   Z 관찰/판정   X 뒤로", Vector2(64, 568), 18, Color("e4c68a"))
	_status = _label("이번 박자의 사건을 찾아 기록하세요.", Vector2(64, 624), 18, Color("bac7d1"))
	_status.size = Vector2(1030, 54)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	if not _can_input():
		_held.clear()
		return
	for index: int in range(ACTIONS.size()):
		var pressed: bool = context.is_action_pressed(ACTIONS[index])
		var previous: bool = bool(_held.get(ACTIONS[index], false))
		_held[ACTIONS[index]] = pressed
		if pressed and not previous:
			if index == 0: execute_command(&"move", {"step": -1})
			elif index == 1: execute_command(&"move", {"step": 1})
			elif index == 2: execute_command(&"cycle", {"step": -1})
			elif index == 3: execute_command(&"cycle", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			var limit: int = 2 if mode == 1 else 3
			if mode == 2:
				return false
			focus = posmod(focus + int(step), limit + 1)
		&"cycle":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 0:
				focus = posmod(focus + int(step), 4)
			elif mode == 1:
				route[focus] = posmod(route[focus] + int(step), 3)
			else:
				return false
		&"confirm":
			if mode == 0: _observe_or_rewind()
			elif mode == 1: _evaluate_route()
			else: _finish()
		&"back":
			if mode == 2:
				mode = 1
				focus = 0
			elif mode == 1:
				mode = 0
				focus = 0
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func _observe_or_rewind() -> void:
	if focus == 3:
		loops = mini(loops + 1, 9999)
		resets = mini(resets + 1, 9999)
		beat = 0
		if known.all(func(value: bool) -> bool: return value):
			mode = 1
			focus = 0
			_message = "세 번의 기억이 남았다. 다음 루프의 순서를 적어 보자."
		else:
			_message = "방이 처음 박자로 돌아갔다. 기억은 남아 있다."
		return
	if focus != beat:
		mistakes = mini(mistakes + 1, 9999)
		_message = "아직 그 박자가 아니다. 다음 되감기에서 다시 맞춰 보자."
	else:
		if not known[focus]:
			known[focus] = true
			requested.emit(&"observation", {"id": "time_loop.event_%d" % focus, "text": EVENT_TEXT[focus]})
		_message = EVENT_TEXT[focus]
		beat = posmod(beat + 1, 3)
		if beat == 0: loops = mini(loops + 1, 9999)

func _evaluate_route() -> void:
	attempts = mini(attempts + 1, 9999)
	if route == SOLUTION:
		solved = true
		mode = 2
		focus = 0
		_message = "기억한 세 박자가 문을 여는 순서와 맞았다. Z로 루프를 닫자."
	else:
		mistakes = mini(mistakes + 1, 9999)
		_message = "문이 다른 박자에서 닫혔다. 되감지 않고 경로를 다시 고칠 수 있다."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "time_loop.solved", "text": SOLVED_TEXT})
	requested.emit(&"portal", {"exit": "forward"})

func save_state() -> Dictionary:
	return {"mode": mode, "focus": focus, "beat": beat, "known": known.duplicate(), "route": route.duplicate(), "loops": loops, "resets": resets, "attempts": attempts, "mistakes": mistakes, "solved": solved}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	beat = int(clean["beat"])
	known.assign(clean["known"])
	route.assign(clean["route"])
	loops = int(clean["loops"])
	resets = int(clean["resets"])
	attempts = int(clean["attempts"])
	mistakes = int(clean["mistakes"])
	solved = bool(clean["solved"])
	_message = ""
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_known: Array[bool] = [false, false, false]
	if data.get("known") is Array and data["known"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["known"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3: clean_known = candidate
	var clean_route: Array[int] = [0, 0, 0]
	if data.get("route") is Array and data["route"].size() == 3:
		var candidate_route: Array[int] = []
		for value: Variant in data["route"]:
			if not value is int and not value is float or not is_finite(float(value)):
				candidate_route.clear()
				break
			candidate_route.append(clampi(int(value), 0, 2))
		if candidate_route.size() == 3: clean_route = candidate_route
	var clean_mode: int = _integer(data.get("mode"), 0, 0, 2)
	var focus_max: int = 2 if clean_mode == 1 else 3
	return {"mode": clean_mode, "focus": _integer(data.get("focus"), 0, 0, focus_max), "beat": _integer(data.get("beat"), 0, 0, 2), "known": clean_known, "route": clean_route, "loops": _integer(data.get("loops"), 0, 0, 9999), "resets": _integer(data.get("resets"), 0, 0, 9999), "attempts": _integer(data.get("attempts"), 0, 0, 9999), "mistakes": _integer(data.get("mistakes"), 0, 0, 9999), "solved": data.get("solved") if data.get("solved") is bool else false}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	_mode_label.text = MODE_NAMES[mode]
	_clock_label.text = "루프 %d · 박자 %d/3" % [loops, beat + 1]
	for index: int in range(3):
		_event_cards[index].color = Color("795c4d") if mode == 0 and index == focus else Color("38516a")
		_event_marks[index].text = "기억함" if known[index] else "기억 안 함"
		_event_marks[index].add_theme_color_override("font_color", Color("f0cd8b") if known[index] else Color("acbfca"))
		_route_rows[index].color = Color("806b55") if mode == 1 and index == focus else Color("4a4260")
		_route_labels[index].text = "%d박자  ·  %s" % [index + 1, EVENT_NAMES[route[index]]]
	if mode == 0:
		if focus == 3:
			_body.text = "Z를 누르면 박자가 처음으로 돌아갑니다. 기억한 사건은 다음 루프에도 남습니다."
		else:
			_body.text = EVENT_TEXT[focus] if known[focus] else "현재 박자에 일어나는 사건을 맞혀 기록하세요. 틀리면 다음 루프에서 다시 확인할 수 있습니다."
	elif mode == 1:
		_body.text = "세 번의 관찰에서 남은 순서를 위에서부터 옮기세요. 오답 뒤에도 경로를 다시 고칠 수 있습니다."
	else:
		_body.text = "창문이 열리고, 종이 울리고, 그림자가 건넌 순서가 다음 문을 움직였다."
	if _message.is_empty():
		_status.text = "기억 %d/3 · 되감기 %d회 · 판정 %d회 · 오답 %d회" % [known.count(true), resets, attempts, mistakes]
	else:
		_status.text = _message

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label
