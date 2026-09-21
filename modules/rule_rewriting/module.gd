extends GameModule

const ACTIONS: Array[StringName] = [&"rule_rewriting_left", &"rule_rewriting_right", &"rule_rewriting_up", &"rule_rewriting_down", &"rule_rewriting_confirm", &"rule_rewriting_cancel"]
const MODE_NAMES: Array[String] = ["관찰실", "규칙 재작성", "작동 증명"]
const CLUES: Array[String] = [
	"멈춘 바닥의 문장 끝에는 지워진 동사가 남아 있다. 밀어내는 힘은 문턱을 향한다.",
	"문턱의 표면은 닫혀 있지 않다. 같은 문장을 다시 읽으면 되감기는 방향이 보인다.",
	"기록판의 화살표는 두 규칙을 한 번씩 바꾼 뒤에만 빛난다. 먼저 공간의 반응을 확인해야 한다."
]
const CLUE_NAMES: Array[String] = ["바닥 표찰", "문턱 표찰", "기록판"]
const RULE_NAMES: Array[String] = ["바닥의 동사", "문턱의 동사"]
const RULE_OPTIONS: Array[Array] = [
	["멈춘다", "밀어낸다", "이어진다"],
	["닫힌다", "비켜난다", "되감긴다"]
]
const SOLUTION: Array[int] = [1, 2]
const SOLVED_TEXT: String = "바닥은 밀어내고 문턱은 되감긴다. 두 문장을 다시 쓰자 신호실의 출구가 열렸다."

var mode: int = 0
var focus: int = 0
var observed: Array[bool] = [false, false, false]
var rules: Array[int] = [0, 0]
var attempts: int = 0
var rewrites: int = 0
var evaluations: int = 0
var solved: bool = false
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _world_label: Label
var _status: Label
var _clue_cards: Array[ColorRect] = []
var _clue_marks: Array[Label] = []
var _rule_rows: Array[ColorRect] = []
var _rule_labels: Array[Label] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("17252b")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("규칙 재작성실", Vector2(60, 40), 40, Color("f4e2ad"))
	_label("문장 하나를 고치면 공간의 판정도 다시 움직인다", Vector2(64, 96), 20, Color("b6d0c5"))
	_mode_label = _label("관찰실", Vector2(64, 132), 18, Color("e5b96c"))
	var room := ColorRect.new()
	room.color = Color("263e45")
	room.position = Vector2(60, 178)
	room.size = Vector2(610, 350)
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(room)
	_label("반응하는 방", Vector2(88, 204), 24, Color("f4e2ad"))
	_world_label = _label("", Vector2(92, 244), 19, Color("d9ebe1"))
	_world_label.size = Vector2(540, 90)
	_world_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(92, 342 + index * 54)
		card.size = Vector2(540, 42)
		card.color = Color("31515a")
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(card)
		_clue_cards.append(card)
		var title := _label(CLUE_NAMES[index], card.position + Vector2(14, 8), 17, Color("f4e2ad"))
		title.size.x = 170
		var mark := _label("미확인", card.position + Vector2(390, 8), 16, Color("a8c4b8"))
		mark.size.x = 130
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_clue_marks.append(mark)
	var rules_panel := ColorRect.new()
	rules_panel.color = Color("302c40")
	rules_panel.position = Vector2(700, 178)
	rules_panel.size = Vector2(390, 350)
	rules_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(rules_panel)
	_label("기록판", Vector2(730, 204), 24, Color("f4e2ad"))
	_label("두 문장을 바꾸고 다시 시험한다", Vector2(732, 242), 17, Color("c7b7d4"))
	for index: int in range(2):
		var row := ColorRect.new()
		row.position = Vector2(728, 294 + index * 92)
		row.size = Vector2(334, 70)
		row.color = Color("4b4260")
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(row)
		_rule_rows.append(row)
		var rule_label := _label("", row.position + Vector2(14, 12), 18, Color("f5e9ff"))
		rule_label.size = Vector2(306, 50)
		rule_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_rule_labels.append(rule_label)
	_label("←→ 대상 선택   ↑↓ 문장 바꾸기   Z 기록/시험   X 뒤로", Vector2(64, 568), 18, Color("e5c68b"))
	_status = _label("세 표찰을 순서와 상관없이 읽고, 두 문장을 다시 써 보세요.", Vector2(64, 624), 18, Color("b6d0c5"))
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
			if mode == 1:
				focus = posmod(focus + int(step), 2)
			elif mode == 0:
				focus = posmod(focus + int(step), 3)
			else:
				return false
		&"cycle":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 1:
				var next_value: int = posmod(rules[focus] + int(step), 3)
				if next_value != rules[focus]:
					rules[focus] = next_value
					rewrites = mini(rewrites + 1, 9999)
					solved = false
					_message = "문장이 바뀌었다. 방의 반응을 다시 시험해 보자."
			elif mode == 0:
				focus = posmod(focus + int(step), 3)
			else:
				return false
		&"confirm":
			if mode == 0:
				_observe_or_open_rules()
			elif mode == 1:
				_evaluate_rules()
			else:
				_finish()
		&"back":
			if mode == 2:
				mode = 1
				focus = 0
				_message = "작동 증명을 다시 읽거나 문장을 고쳐 쓸 수 있다."
			elif mode == 1:
				mode = 0
				focus = 0
				_message = "표찰을 다시 읽을 수 있다."
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"mode": mode, "focus": focus, "observed": observed.duplicate(), "rules": rules.duplicate(), "attempts": attempts, "rewrites": rewrites, "evaluations": evaluations, "solved": solved}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	observed.assign(clean["observed"])
	rules.assign(clean["rules"])
	attempts = int(clean["attempts"])
	rewrites = int(clean["rewrites"])
	evaluations = int(clean["evaluations"])
	solved = bool(clean["solved"])
	_message = ""
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _observe_or_open_rules() -> void:
	if not observed[focus]:
		observed[focus] = true
		_message = CLUES[focus]
		requested.emit(&"observation", {"id": "rule_rewriting.clue_%d" % focus, "text": CLUES[focus]})
	elif observed.all(func(value: bool) -> bool: return value):
		mode = 1
		focus = 0
		_message = "세 표찰이 이어졌다. 기록판의 두 문장을 다시 써 보자."
	else:
		_message = "아직 읽지 않은 표찰이 있다."

func _evaluate_rules() -> void:
	evaluations = mini(evaluations + 1, 9999)
	if rules == SOLUTION:
		solved = true
		mode = 2
		focus = 0
		_message = "두 규칙이 방의 반응과 맞았다. Z로 작동 증명을 닫자."
	else:
		attempts = mini(attempts + 1, 9999)
		_message = "방이 멈췄다. 규칙 하나가 아직 반대로 쓰였다. 다시 고쳐 시험하자."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "rule_rewriting.solved", "text": SOLVED_TEXT})
	requested.emit(&"portal", {"exit": "forward"})

func _normalize(data: Dictionary) -> Dictionary:
	var clean_observed: Array[bool] = [false, false, false]
	if data.get("observed") is Array and data["observed"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["observed"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3:
			clean_observed = candidate
	var clean_rules: Array[int] = [0, 0]
	if data.get("rules") is Array and data["rules"].size() == 2:
		var candidate_rules: Array[int] = []
		for value: Variant in data["rules"]:
			if not value is int and not value is float or not is_finite(float(value)):
				candidate_rules.clear()
				break
			candidate_rules.append(clampi(int(value), 0, 2))
		if candidate_rules.size() == 2:
			clean_rules = candidate_rules
	var clean_mode: int = _integer(data.get("mode"), 0, 0, 2)
	var focus_max: int = 1 if clean_mode == 1 else 2
	return {"mode": clean_mode, "focus": _integer(data.get("focus"), 0, 0, focus_max), "observed": clean_observed, "rules": clean_rules, "attempts": _integer(data.get("attempts"), 0, 0, 9999), "rewrites": _integer(data.get("rewrites"), 0, 0, 9999), "evaluations": _integer(data.get("evaluations"), 0, 0, 9999), "solved": data.get("solved") if data.get("solved") is bool else false}

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
	for index: int in range(3):
		_clue_cards[index].color = Color("725b4a") if mode == 0 and index == focus else Color("31515a")
		_clue_marks[index].text = "기록 완료" if observed[index] else "미확인"
		_clue_marks[index].add_theme_color_override("font_color", Color("f2d28b") if observed[index] else Color("a8c4b8"))
	for index: int in range(2):
		_rule_rows[index].color = Color("806b55") if mode == 1 and index == focus else Color("4b4260")
		_rule_labels[index].text = "%s\n%s" % [RULE_NAMES[index], RULE_OPTIONS[index][rules[index]]]
	_world_label.text = "바닥은 %s. 문턱은 %s.\n현재 반응: %s" % [RULE_OPTIONS[0][rules[0]], RULE_OPTIONS[1][rules[1]], _reaction()]
	if _message.is_empty():
		_status.text = "표찰 %d/3 · 다시 쓰기 %d회 · 시험 %d회" % [observed.count(true), rewrites, evaluations]
	else:
		_status.text = _message

func _reaction() -> String:
	if rules == SOLUTION:
		return "밀려난 바닥이 되감긴 문턱까지 길을 잇는다."
	if rules[0] == 1:
		return "바닥이 움직이지만 문턱 앞에서 멈춘다."
	if rules[1] == 2:
		return "문턱이 되감기지만 바닥이 길을 만들지 못한다."
	return "두 규칙이 서로의 움직임을 막고 있다."

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
