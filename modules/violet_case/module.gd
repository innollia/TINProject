extends GameModule

const ACTIONS: Array[StringName] = [&"violet_case_left", &"violet_case_right", &"violet_case_up", &"violet_case_down", &"violet_case_confirm", &"violet_case_cancel"]
const MODE_NAMES: Array[String] = ["현장 조사", "증거 기록", "추리 입력", "사건 재구성", "사건 선택"]
const CASES: Array[Dictionary] = [
	{
		"id": "case_01",
		"title": "자정의 보랏빛 사건",
		"subtitle": "사라진 첫 신호 · 조사 기록 01",
		"hotspots": ["신호 열쇠", "잠긴 창문", "바닥의 이름표"],
		"findings": [
			"신호 열쇠 왼쪽 홈에 보랏빛 잉크와 가는 쇳가루가 함께 묻어 있다. 시계공 작업대에서 보던 잉크다.",
			"창문 잠금 장치는 안쪽 그대로다. 밖에서 들어온 흔적보다 신호 자체가 복제된 흔적에 가깝다.",
			"바닥의 찢긴 이름표에는 ‘서…’만 남았다. 지워진 이름을 되찾겠다는 문장이 뒤집혀 있다."
		],
		"suspects": ["서윤 · 시계공", "마루 · 뱃사공", "연화 · 합창단원"],
		"methods": ["창문으로 훔치기", "보랏빛 잉크로 신호 복제", "종 바꿔치기"],
		"motives": ["자기 이름을 되찾기", "경주에서 이기기", "비를 멈추기"],
		"solution": [0, 1, 0],
		"reconstruction": "서윤은 보랏빛 잉크로 신호를 복제해 자기 이름을 되찾으려 했다.",
		"observation_id": "violet_case.solution",
		"theories": []
	},
	{
		"id": "case_02",
		"title": "끝없이 노래하는 오르골",
		"subtitle": "사라진 소녀 · 조사 기록 02",
		"hotspots": ["현재 오르골", "경찰 인계 문서", "사칭범 복장 사진", "일곱 오르골 제작 흔적", "청동 소녀상 설계도", "실종 전 계약문", "무한동력 장부"],
		"findings": [
			"부서지거나 묻힌 오르골도 다시 누군가의 손에 돌아온다는 소문이 여러 마을의 장부에 반복된다.",
			"경찰 인계 문서에는 소녀를 데려간 경찰의 이름과 근무 기록이 없다. 인계 자체가 만들어진 문장이다.",
			"사진 속 복장은 경찰 제복과 비슷하지만 단추 배열이 다르다. 목격자는 모두 같은 가짜 배지를 기억한다.",
			"일곱 오르골의 안쪽 틀에는 같은 금속 가루가 남았다. 누군가 한 작업장에서 묶어 만들었다.",
			"청동 소녀상은 내부가 비어 있지 않다. 다만 춤추는 소녀가 있다는 설을 입증할 수 있는 공간은 아니다.",
			"소녀가 사라지기 전 체결한 계약에는 ‘영원한 노래’와 공연 수익 배분이 적혀 있다.",
			"장부에는 오르골을 무한동력 장치로 팔려 한 계산이 있다. 동화가 아니라 사업의 흔적이다."
		],
		"suspects": ["가짜 경찰 · 사칭범", "청동상 관리인", "오르골 제작자"],
		"methods": ["가짜 인계 기록으로 데려가기", "청동상 안에 숨기기", "오르골을 일곱 개로 나누기"],
		"motives": ["공연 수익을 독점하기", "영원한 춤의 전설을 만들기", "무한동력 사업을 시작하기"],
		"solution": [0, 0, 0],
		"reconstruction": "확정된 것은 가짜 경찰이 인계 기록을 꾸며 소녀를 데려갔다는 사실이다. 오르골과 소녀의 물질적 연결은 남아 있지만, 청동상·악마·무한동력에 관한 설은 아직 닫히지 않았다.",
		"observation_id": "violet_case.music_box_solution",
		"theories": ["오르골은 실제 신체 조각이다.", "청동상 안에서 소녀가 아직 춤춘다.", "악마의 계약이 영원한 노래를 주었다.", "소녀를 무한동력으로 이용했다."]
	},
	{
		"id": "case_03",
		"title": "붉은 행운벌레",
		"subtitle": "살아남은 목격담 · 조사 기록 03",
		"hotspots": ["낡은 도감", "생존자 진술 A", "생존자 진술 B", "붉은 표본 사진", "목숨 하나 추가 기록"],
		"findings": [
			"도감은 몸길이를 ‘잉글랜드 남성의 속눈썹 13토막’으로 잰다. 단위부터 목격자의 과장이 섞여 있다.",
			"첫 생존자는 위험이 오기 직전에 벌레를 봤다고 말하지만, 벌레가 자신을 구했다고는 말하지 않는다.",
			"두 번째 생존자는 벌레를 본 뒤의 기억을 서로 다른 날짜로 기록했다. 살아남은 뒤 기억이 다시 쓰였을 수 있다.",
			"사진 속 붉은 생물은 진드기와 거미의 특징을 함께 보이지만 사진 밖의 크기와 움직임은 확인할 수 없다.",
			"‘목숨 하나 추가’ 표시는 재난 전 기록에는 없고, 살아남은 사람들이 같은 문구를 나중에 덧붙인 흔적이다."
		],
		"suspects": ["생물 그 자체", "생존자들의 집단 기억", "재난 기록을 만든 사람"],
		"methods": ["위험 직전 나타나기", "살아남은 기억을 서로 맞추기", "도감의 단위를 부풀리기"],
		"motives": ["생존 신호를 남기기", "목격담을 전설로 만들기", "도감의 빈 칸을 채우기"],
		"solution": [1, 1, 1],
		"reconstruction": "벌레가 행운을 준다는 사실은 확정되지 않는다. 위험 직전의 목격과 살아남은 뒤의 기억이 서로 영향을 주며, 행운의 전설이 만들어졌다는 쪽이 현재 기록에 가장 잘 맞는다.",
		"observation_id": "violet_case.red_luck_bug_solution",
		"theories": ["벌레는 목숨을 하나 늘린다.", "벌레는 위험 직전에만 나타난다.", "모든 목격담은 기억 왜곡이다."],
		"answer_names": ["가장 그럴듯한 설명", "기억이 바뀐 방식", "전설이 생긴 이유"],
		"deduction_prompt": "목격담의 신뢰성을 세 문장으로 평가하세요. 오답도 기록되지만 미확정 이론을 사실로 확정하지는 않습니다."
	}
]

var mode: int = 0
var focus: int = 0
var case_index: int = 0
var case_states: Array = []
var completed_cases: Array[String] = []
var _case_picker_origin: int = 0
var inspected: Array[bool] = [false, false, false]
var answers: Array[int] = [0, 0, 0]
var mistakes: int = 0
var solved: bool = false
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _title_label: Label
var _subtitle_label: Label
var _mode_label: Label
var _notebook_title: Label
var _notebook_body: Label
var _status: Label
var _hotspot_cards: Array[ColorRect] = []
var _hotspot_names: Array[Label] = []
var _hotspot_marks: Array[Label] = []
var _answer_cards: Array[ColorRect] = []
var _answer_labels: Array[Label] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("191625")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)
	_title_label = _label(String(CASES[0]["title"]), Vector2(60, 42), 39, Color("f7e9ff"))
	_subtitle_label = _label(String(CASES[0]["subtitle"]), Vector2(64, 100), 20, Color("c3aed2"))
	_mode_label = _label("현장 조사", Vector2(64, 136), 18, Color("e6b6ff"))
	var scene_panel := ColorRect.new()
	scene_panel.color = Color("292238")
	scene_panel.position = Vector2(60, 178)
	scene_panel.size = Vector2(630, 350)
	_background.add_child(scene_panel)
	var window := ColorRect.new()
	window.color = Color("4b3f72")
	window.position = Vector2(416, 213)
	window.size = Vector2(205, 130)
	_background.add_child(window)
	var window_bar := ColorRect.new()
	window_bar.color = Color("211b2f")
	window_bar.position = Vector2(510, 213)
	window_bar.size = Vector2(8, 130)
	_background.add_child(window_bar)
	var desk := ColorRect.new()
	desk.color = Color("5b3d55")
	desk.position = Vector2(100, 385)
	desk.size = Vector2(530, 90)
	_background.add_child(desk)
	var key := ColorRect.new()
	key.color = Color("e5c76b")
	key.position = Vector2(174, 350)
	key.size = Vector2(140, 18)
	_background.add_child(key)
	var key_ring := ColorRect.new()
	key_ring.color = Color("c4a85b")
	key_ring.position = Vector2(160, 343)
	key_ring.size = Vector2(22, 32)
	_background.add_child(key_ring)
	var tag := ColorRect.new()
	tag.color = Color("d9c2df")
	tag.position = Vector2(348, 407)
	tag.size = Vector2(76, 42)
	_background.add_child(tag)
	var moon := ColorRect.new()
	moon.color = Color("e7c9ff35")
	moon.position = Vector2(506, 235)
	moon.size = Vector2(32, 32)
	_background.add_child(moon)
	for index: int in range(7):
		var card := ColorRect.new()
		card.position = Vector2(84 + (index % 3) * 200, 232 + (index / 3) * 76)
		card.size = Vector2(174, 62)
		card.color = Color("3b3050")
		card.z_index = 2
		add_child(card)
		_hotspot_cards.append(card)
		var name_label := _label(String(CASES[0]["hotspots"][index]) if index < 3 else "", card.position + Vector2(12, 9), 17, Color("f7e9ff"))
		name_label.z_index = 3
		name_label.size.x = 150
		_hotspot_names.append(name_label)
		var mark := _label("미확인", card.position + Vector2(12, 34), 14, Color("bca9ca"))
		mark.z_index = 3
		mark.size.x = 150
		_hotspot_marks.append(mark)
	var notebook := ColorRect.new()
	notebook.color = Color("30263e")
	notebook.position = Vector2(720, 178)
	notebook.size = Vector2(372, 350)
	_background.add_child(notebook)
	_notebook_title = _label("사건 메모", Vector2(750, 210), 25, Color("ffd88c"))
	_notebook_title.z_index = 2
	_notebook_body = _label("현장을 훑고 세 단서를 모두 기록한 뒤, 세 칸의 추리를 완성하세요.", Vector2(750, 262), 18, Color("eadff2"))
	_notebook_body.size = Vector2(310, 240)
	_notebook_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notebook_body.z_index = 2
	for index: int in range(3):
		var answer_card := ColorRect.new()
		answer_card.position = Vector2(746, 258 + index * 72)
		answer_card.size = Vector2(320, 58)
		answer_card.color = Color("4c3d61")
		answer_card.z_index = 2
		add_child(answer_card)
		_answer_cards.append(answer_card)
		var answer_label := _label("", answer_card.position + Vector2(14, 10), 16, Color("f7e9ff"))
		answer_label.z_index = 3
		answer_label.size.x = 292
		_answer_labels.append(answer_label)
	_label("←→ 대상/답 선택   ↑↓ 화면·칸 이동   Z 조사/판정   X 뒤로", Vector2(62, 570), 18, Color("e6b6ff"))
	_status = _label("세 단서를 찾아 사건의 문장을 완성하세요.", Vector2(62, 625), 18, Color("c3aed2"))
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
			elif index == 2: execute_command(&"vertical", {"step": -1})
			elif index == 3: execute_command(&"vertical", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 2:
				answers[focus] = posmod(answers[focus] + int(step), 3)
			elif mode == 3 or mode == 4:
				return false
			else:
				focus = posmod(focus + int(step), _hotspot_count())
		&"vertical":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 4:
				case_index = posmod(case_index + int(step), CASES.size())
			elif mode == 2:
				focus = posmod(focus + int(step), 3)
			elif mode == 3:
				mode = 2
				focus = mini(focus, 2)
			elif mode == 0 and int(step) == -1:
				_case_picker_origin = case_index
				mode = 4
				focus = case_index
			else:
				mode = posmod(mode + int(step), 3)
				if mode == 2:
					focus = mini(focus, 2)
		&"confirm":
			if mode == 4:
				_select_case()
			elif mode == 2:
				_submit()
			elif mode == 3:
				_finish_case()
			elif focus < inspected.size() and not inspected[focus]:
				inspected[focus] = true
				var finding: String = _findings()[focus]
				_status.text = finding
				requested.emit(&"observation", {"id": "%s.clue_%d" % [String(_current_case()["id"]), focus], "text": finding})
			elif mode == 1:
				_status.text = "이미 기록한 단서다. 세 문장을 연결해 보세요."
		&"back":
			if mode == 4:
				case_index = _case_picker_origin
				_load_current_case()
				mode = 0
			elif mode == 3:
				mode = 2
			elif mode != 0:
				mode = 0
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	if mode != 4:
		_store_current_case()
	_refresh()
	return true

func _submit() -> void:
	if not inspected.all(func(value: bool) -> bool: return value):
		_status.text = "아직 읽지 않은 증거가 있다. 현장 조사로 돌아가세요."
		return
	if answers == _solution():
		solved = true
		mode = 3
		focus = 0
		if String(_current_case()["id"]) not in completed_cases:
			completed_cases.append(String(_current_case()["id"]))
		_status.text = "세 문장이 맞물렸다. Z로 사건을 닫고 귀환하세요."
	else:
		mistakes = mini(mistakes + 1, 9999)
		_status.text = "추리가 어긋났다. 기록을 다시 읽고 세 칸을 고쳐 쓰세요."

func _finish_case() -> void:
	if not solved:
		return
	requested.emit(&"observation", {"id": String(_current_case()["observation_id"]), "text": String(_current_case()["reconstruction"])})
	_request_sent = true
	requested.emit(&"portal", {"exit": "forward"})

func save_state() -> Dictionary:
	if mode != 4:
		_store_current_case()
	return {"case_index": case_index, "case_states": case_states.duplicate(true), "completed_cases": completed_cases.duplicate(), "mode": mode, "focus": focus, "inspected": inspected.duplicate(), "answers": answers.duplicate(), "mistakes": mistakes, "solved": solved}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	case_index = int(clean["case_index"])
	case_states = clean["case_states"].duplicate(true)
	completed_cases.clear()
	for value: Variant in clean["completed_cases"]:
		completed_cases.append(String(value))
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	_case_picker_origin = case_index
	_load_current_case()
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_case_index: int = _integer(data.get("case_index"), 0, 0, CASES.size() - 1)
	var clean_states: Array = []
	var has_case_states: bool = data.get("case_states") is Array and data["case_states"].size() == CASES.size()
	for index: int in range(CASES.size()):
		var source: Variant = data["case_states"][index] if has_case_states else (data if index == 0 else {})
		clean_states.append(_normalize_case_state(source, index))
	var clean_completed: Array[String] = []
	if data.get("completed_cases") is Array:
		for value: Variant in data["completed_cases"]:
			if value is String and _case_index(String(value)) >= 0 and String(value) not in clean_completed:
				clean_completed.append(String(value))
	var active: Dictionary = clean_states[clean_case_index]
	var maximum_focus: int = maxi(2, int(CASES[clean_case_index]["hotspots"].size()) - 1)
	return {"case_index": clean_case_index, "case_states": clean_states, "completed_cases": clean_completed, "mode": _integer(data.get("mode"), 0, 0, 4), "focus": _integer(data.get("focus"), 0, 0, maximum_focus), "inspected": active["inspected"].duplicate(), "answers": active["answers"].duplicate(), "mistakes": active["mistakes"], "solved": active["solved"]}

func _normalize_case_state(value: Variant, index: int) -> Dictionary:
	var clean: Dictionary = _default_case_state(index)
	if not value is Dictionary:
		return clean
	var source: Dictionary = value
	var hotspot_count: int = int(CASES[index]["hotspots"].size())
	if source.get("inspected") is Array and source["inspected"].size() == hotspot_count:
		var candidate_inspected: Array[bool] = []
		for item: Variant in source["inspected"]:
			if not item is bool:
				candidate_inspected.clear()
				break
			candidate_inspected.append(item)
		if candidate_inspected.size() == hotspot_count:
			clean["inspected"] = candidate_inspected
	if source.get("answers") is Array and source["answers"].size() == 3:
		var candidate_answers: Array[int] = []
		for item: Variant in source["answers"]:
			if not item is int and not item is float or not is_finite(float(item)):
				candidate_answers.clear()
				break
			candidate_answers.append(clampi(int(item), 0, 2))
		if candidate_answers.size() == 3:
			clean["answers"] = candidate_answers
	clean["mistakes"] = _integer(source.get("mistakes"), 0, 0, 9999)
	clean["solved"] = source.get("solved") if source.get("solved") is bool else false
	return clean

func _default_case_state(index: int) -> Dictionary:
	var clean_inspected: Array[bool] = []
	for _unused: int in range(CASES[index]["hotspots"].size()):
		clean_inspected.append(false)
	return {"inspected": clean_inspected, "answers": [0, 0, 0], "mistakes": 0, "solved": false}

func _store_current_case() -> void:
	if case_states.size() != CASES.size():
		return
	case_states[case_index] = {"inspected": inspected.duplicate(), "answers": answers.duplicate(), "mistakes": mistakes, "solved": solved}

func _load_current_case() -> void:
	var clean: Dictionary = _normalize_case_state(case_states[case_index], case_index)
	inspected.assign(clean["inspected"])
	answers.assign(clean["answers"])
	mistakes = int(clean["mistakes"])
	solved = bool(clean["solved"])

func _select_case() -> void:
	_load_current_case()
	mode = 0
	focus = 0
	_request_sent = false

func _current_case() -> Dictionary:
	return CASES[case_index]

func _findings() -> Array:
	return _current_case()["findings"]

func _solution() -> Array:
	return _current_case()["solution"]

func _hotspot_count() -> int:
	return int(_current_case()["hotspots"].size())

func _case_index(id: String) -> int:
	for index: int in range(CASES.size()):
		if String(CASES[index]["id"]) == id:
			return index
	return -1

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	var current: Dictionary = _current_case()
	var hotspots: Array = current["hotspots"]
	var findings: Array = current["findings"]
	_title_label.text = String(current["title"])
	_subtitle_label.text = String(current["subtitle"])
	_mode_label.text = MODE_NAMES[mode]
	for index: int in range(_hotspot_cards.size()):
		var visible: bool = mode != 4 and index < hotspots.size()
		_hotspot_cards[index].visible = visible
		_hotspot_names[index].visible = visible
		_hotspot_marks[index].visible = visible
		if visible:
			_hotspot_names[index].text = String(hotspots[index])
			_hotspot_cards[index].color = Color("725d8c") if index == focus and mode < 2 else Color("3b3050")
			_hotspot_marks[index].text = "기록 완료" if inspected[index] else "미확인"
			_hotspot_marks[index].add_theme_color_override("font_color", Color("ffd88c") if inspected[index] else Color("bca9ca"))
	if mode == 0:
		_notebook_title.text = "현장 메모 · " + String(hotspots[focus])
		_notebook_body.text = findings[focus] if inspected[focus] else "Z를 눌러 이 장소를 자세히 기록하세요. 단서는 서로 다른 부분에 흩어져 있다."
	elif mode == 1:
		_notebook_title.text = "증거 기록 · %d/%d" % [inspected.count(true), hotspots.size()]
		_notebook_body.text = findings[focus] if inspected[focus] else "아직 확인하지 않은 흔적이다. 현장 조사로 돌아가 Z를 누르세요."
	elif mode == 2:
		_notebook_title.text = "추리 입력 · " + _answer_name(focus)
		_notebook_body.text = String(current.get("deduction_prompt", "확정 가능한 사건의 세 문장을 맞춰 보세요. 오답은 기록되지만 미확정 이론을 정답으로 확정하지는 않습니다."))
	elif mode == 3:
		_notebook_title.text = "사건 재구성"
		_notebook_body.add_theme_font_size_override("font_size", 16)
		var theories: Array = current["theories"]
		var theory_text: String = ""
		for theory: String in theories:
			theory_text += "\n· " + theory
		_notebook_body.text = "확정 기록\n\n" + String(current["reconstruction"]) + ("\n\n미확정 이론" + theory_text if not theories.is_empty() else "")
	else:
		_notebook_title.text = "사건 선택 · %d/%d" % [case_index + 1, CASES.size()]
		_notebook_body.text = "↑↓ 사건을 고르고 Z로 엽니다. 완료한 사건: %d/%d" % [completed_cases.size(), CASES.size()]
	if mode != 3:
		_notebook_body.add_theme_font_size_override("font_size", 18)
	for index: int in range(3):
		_answer_cards[index].visible = mode == 2 or mode == 4
		_answer_labels[index].visible = mode == 2 or mode == 4
		_answer_cards[index].color = Color("806b9e") if ((mode == 2 and index == focus) or (mode == 4 and index == case_index)) else Color("4c3d61")
		if mode == 4:
			_answer_labels[index].text = "%02d  ·  %s%s" % [index + 1, CASES[index]["title"], "  · 완료" if String(CASES[index]["id"]) in completed_cases else ""]
		else:
			_answer_labels[index].text = "%s  ·  %s" % [_answer_name(index), _answer_text(index, answers[index])]
	if mode == 2:
		_status.text = "칸 %d/3 · ←→ 답 선택 · Z 판정 · 오답 %d회" % [focus + 1, mistakes]
	elif mode == 3:
		_status.text = "Z 사건 닫기 · X 추리로 돌아가기"
	elif mode == 4:
		_status.text = "↑↓ 사건 선택 · Z 열기 · X 돌아가기"

func _answer_text(slot: int, value: int) -> String:
	if slot == 0: return _current_case()["suspects"][value]
	if slot == 1: return _current_case()["methods"][value]
	return _current_case()["motives"][value]

func _answer_name(slot: int) -> String:
	var names: Array = _current_case().get("answer_names", ["범인", "수법", "동기"])
	return String(names[slot])

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered:
		label.size.x = 220
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
