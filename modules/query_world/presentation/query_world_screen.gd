class_name QueryWorldScreen
extends Control

## Query World Kit 표현층.
## 상태(QueryWorldState)를 화면으로. 진실은 domain이 소유하고 여기선 표현+intent만.
## 상시 HUD 없음. UI 아이콘 없음(텍스트/타이포/여백/선/색만). 어둠이 기본값.

signal intent_requested(intent: StringName, payload: Dictionary)

# --- 색 (어두운 배경 위 국소 조명. 정보를 캐내는 차갑고 건조한 톤) ---------
const BG_DEEP := Color("05050a")
const BG_PANEL := Color("111119")
const INK := Color("d8dae2")
const INK_DIM := Color("6a6c78")
const ACCENT := Color("7aa2f7")       # 검색창/능동 focus
const REVEAL_GREEN := Color("8fcf7a")  # 열람함
const REVEAL_RED := Color("d16b7e")    # 미열람
const REVEAL_YELLOW := Color("e0b062") # 마지막 열람
const HOVER_TINT := Color("e0b062")
const OVERGROWN := Color("d16b7e")     # 뭉탱이 충돌: 너무 큰 존재

var _state: QueryWorldState = null

# 노드 (코드로 구성)
var _bg: Control
var _search_field: LineEdit
var _result_list: VBoxContainer
var _status_line: Label
var _reader: PanelContainer
var _reader_body: RichTextLabel
var _reader_title: Label
var _tracker: HFlowContainer
var _tracker_panel: PanelContainer
var _mode_reading: bool = false
var _bundle_overgrown: bool = false   # 뭉탱이 인계: HP 200 몸이 넘어왔는가
var _result_buttons: Array[Button] = []
var _preserve_field_focus: bool = true
var _hover_ids: Array[String] = []   # 현재 열람 파편의 hover span id 목록 (qw_peek 순회용)
var _hover_index: int = -1           # 키보드로 순회 중인 hover span 인덱스 (-1 = 없음)


func _ready() -> void:
	_build()


func bind_state(state: QueryWorldState, arrival: Dictionary = {}) -> void:
	_state = state
	_bundle_overgrown = bool(arrival.get("overgrown_body", false))
	_refresh_all()


func unbind_state() -> void:
	_state = null


# --- 구성 ---------------------------------------------------------------
func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_bg = _AmbientBackground.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 48)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	# 검색창 — 화면의 첫 focus, 유일한 능동 조작.
	# 절차적 '조회 단말' 프레임을 뒤에 그려 낡은 기록 열람기 실루엣을 준다.
	var search_stack := Control.new()
	search_stack.custom_minimum_size = Vector2(0, 60)
	search_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(search_stack)
	var terminal := _TerminalFrame.new()
	terminal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	search_stack.add_child(terminal)
	var field_margin := MarginContainer.new()
	field_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	field_margin.add_theme_constant_override("margin_left", 14)
	field_margin.add_theme_constant_override("margin_right", 14)
	field_margin.add_theme_constant_override("margin_top", 6)
	field_margin.add_theme_constant_override("margin_bottom", 6)
	search_stack.add_child(field_margin)
	_search_field = LineEdit.new()
	_search_field.placeholder_text = "검색어를 입력하고 Enter"
	_search_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_search_field.focus_mode = Control.FOCUS_ALL
	_search_field.add_theme_font_size_override("font_size", 22)
	_search_field.add_theme_color_override("font_color", INK)
	_search_field.add_theme_color_override("font_placeholder_color", INK_DIM)
	_search_field.add_theme_color_override("caret_color", ACCENT)
	_search_field.add_theme_stylebox_override("normal", _box(Color(0, 0, 0, 0), Color.TRANSPARENT, 0))
	_search_field.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), Color.TRANSPARENT, 0))
	_search_field.text_submitted.connect(_on_submit)
	_search_field.gui_input.connect(_on_search_gui_input)
	field_margin.add_child(_search_field)

	# 상태선 — 결과 개수/좁히기 신호. 상시 HUD 아님(검색 결과에 대한 즉시 피드백).
	_status_line = Label.new()
	_status_line.add_theme_font_size_override("font_size", 13)
	_status_line.add_theme_color_override("font_color", INK_DIM)
	col.add_child(_status_line)

	# 본문 영역: 결과 목록 <-> 파편 열람
	var body := Control.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_result_list = VBoxContainer.new()
	_result_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_result_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_result_list)

	_reader = PanelContainer.new()
	_reader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reader.add_theme_stylebox_override("panel", _box(BG_PANEL, INK_DIM.darkened(0.4), 1))
	body.add_child(_reader)
	var reader_col := VBoxContainer.new()
	reader_col.add_theme_constant_override("separation", 12)
	var rmargin := MarginContainer.new()
	rmargin.add_theme_constant_override("margin_left", 24)
	rmargin.add_theme_constant_override("margin_right", 24)
	rmargin.add_theme_constant_override("margin_top", 20)
	rmargin.add_theme_constant_override("margin_bottom", 20)
	_reader.add_child(rmargin)
	rmargin.add_child(reader_col)
	# 상단 줄: 제목 + 눈에 보이는 뒤로가기 버튼 (마우스로도 나갈 수 있어야 함)
	var reader_head := HBoxContainer.new()
	reader_col.add_child(reader_head)
	_reader_title = Label.new()
	_reader_title.add_theme_font_size_override("font_size", 13)
	_reader_title.add_theme_color_override("font_color", INK_DIM)
	_reader_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reader_head.add_child(_reader_title)
	var back_btn := Button.new()
	back_btn.text = "← 뒤로 (Esc)"
	back_btn.focus_mode = Control.FOCUS_ALL
	back_btn.add_theme_font_size_override("font_size", 14)
	back_btn.add_theme_color_override("font_color", INK)
	back_btn.add_theme_color_override("font_hover_color", ACCENT)
	back_btn.add_theme_stylebox_override("normal", _box(BG_PANEL.lightened(0.05), INK_DIM.darkened(0.3), 1))
	back_btn.add_theme_stylebox_override("hover", _box(BG_PANEL.lightened(0.1), ACCENT, 1))
	back_btn.add_theme_stylebox_override("focus", _box(BG_PANEL.lightened(0.08), ACCENT, 2))
	back_btn.pressed.connect(close_reader)
	reader_head.add_child(back_btn)
	_reader_body = RichTextLabel.new()
	_reader_body.bbcode_enabled = true
	_reader_body.fit_content = true
	_reader_body.scroll_active = false
	_reader_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reader_body.add_theme_font_size_override("normal_font_size", 20)
	_reader_body.add_theme_color_override("default_color", INK)
	_reader_body.focus_mode = Control.FOCUS_ALL
	_reader_body.meta_hover_started.connect(_on_meta_hover)
	_reader_body.meta_hover_ended.connect(_on_meta_hover_end)
	_reader_body.gui_input.connect(_on_reader_body_gui_input)
	reader_col.add_child(_reader_body)
	_reader.hide()

	# 노출 추적 뷰 — 호출 시에만(상시 HUD 아님). 초록/빨강/노랑.
	_tracker_panel = PanelContainer.new()
	_tracker_panel.add_theme_stylebox_override("panel", _box(BG_PANEL.darkened(0.2), INK_DIM.darkened(0.5), 1))
	var tmargin := MarginContainer.new()
	tmargin.add_theme_constant_override("margin_left", 14)
	tmargin.add_theme_constant_override("margin_right", 14)
	tmargin.add_theme_constant_override("margin_top", 10)
	tmargin.add_theme_constant_override("margin_bottom", 10)
	_tracker_panel.add_child(tmargin)
	_tracker = HFlowContainer.new()
	_tracker.add_theme_constant_override("h_separation", 6)
	_tracker.add_theme_constant_override("v_separation", 6)
	tmargin.add_child(_tracker)
	col.add_child(_tracker_panel)
	_tracker_panel.hide()


# --- 렌더 ---------------------------------------------------------------
## 순수 렌더. domain을 변경하지 않는다(진실은 module이 domain에 위임해 갱신).
## 마지막 질의 이력이 있으면 그 결과를, 없으면 빈 화면을 그린다.
func _refresh_all() -> void:
	if _state == null:
		return
	_search_field.text = _state.seed_query
	if _state.query_history.is_empty():
		_show_results({"matched": [], "count": 0, "capped": false, "empty": true})
	else:
		var last: Dictionary = _state.query_history[_state.query_history.size() - 1]
		_show_results({
			"matched": last.get("matched", []),
			"count": int(last.get("count", 0)),
			"capped": int(last.get("count", 0)) > QueryWorldState.RESULT_CAP,
			"empty": (last.get("matched", []) as Array).is_empty(),
		})
	_refresh_tracker()


func _on_submit(raw: String) -> void:
	if _state == null or raw.strip_edges().is_empty():
		return
	intent_requested.emit(&"query", {"raw": raw})


func present_query_result(raw: String, result: Dictionary) -> void:
	_mode_reading = false
	_reader.hide()
	_preserve_field_focus = true
	_show_results(result)
	# 완료 결론 질의 도달 여부는 module이 판정 후 알림.


## 검색창에서 아래 방향키 → 결과 목록 첫 항목으로 이동(키보드 전용 플레이).
func _on_search_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_DOWN and not _result_buttons.is_empty():
			_focus(_result_buttons[0])
			accept_event()


func _show_results(result: Dictionary) -> void:
	for c: Node in _result_list.get_children():
		c.queue_free()
	_result_buttons.clear()
	var count: int = int(result.get("count", 0))
	var matched: Array = result.get("matched", [])
	if bool(result.get("empty", true)):
		_status_line.text = "결과 없음 — 다른 단어로 물어보라 (물음은 기록에 남는다)"
	elif bool(result.get("capped", false)):
		_status_line.text = "매칭 %d건 중 %d건만 표시 — 더 좁혀 물어라" % [count, matched.size()]
	else:
		_status_line.text = "%d건" % count

	# 뭉탱이 충돌: HP 200 몸이 넘어오면 "너무 큰 존재"가 결과를 가린다
	if _bundle_overgrown and not matched.is_empty():
		var over := _result_row("▓▓▓  [ 너무 큰 존재가 결과를 가린다 ]  ▓▓▓", OVERGROWN, true)
		over.disabled = true
	for fid: Variant in matched:
		var frag: Dictionary = _state.fragments.get(String(fid), {})
		var preview: String = String(frag.get("body", "")).substr(0, 34)
		var status: StringName = _state.reveal_status(String(fid))
		var color: Color = _status_color(status)
		var row := _result_row("%s   %s…" % [String(fid).to_upper(), preview], color, false)
		if _bundle_overgrown:
			row.modulate = Color(1, 1, 1, 0.35)  # 가려짐
		row.pressed.connect(_on_open.bind(String(fid)))
		_result_buttons.append(row)
	# 검색창에 focus를 유지한다 — 결과가 떠도 바로 이어서 타이핑할 수 있어야 한다.
	# 결과 목록으로는 아래 방향키(또는 Tab)로 내려간다.
	if not _preserve_field_focus:
		if not _result_buttons.is_empty():
			_focus(_result_buttons[0])
		else:
			_focus(_search_field)
	else:
		_focus(_search_field)


func _result_row(text: String, color: Color, muted: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 40)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", color if not muted else INK_DIM)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_focus_color", INK)
	b.add_theme_stylebox_override("normal", _box(BG_PANEL, Color.TRANSPARENT, 0))
	b.add_theme_stylebox_override("hover", _box(BG_PANEL.lightened(0.06), ACCENT.darkened(0.4), 1))
	b.add_theme_stylebox_override("focus", _box(BG_PANEL.lightened(0.04), ACCENT, 2))
	b.add_theme_stylebox_override("pressed", _box(BG_PANEL.lightened(0.08), ACCENT, 2))
	b.gui_input.connect(_on_result_gui_input.bind(b))
	_result_list.add_child(b)
	return b


## 결과 목록에서 위 방향키 → 첫 항목이면 검색창으로 복귀(키보드 전용 플레이).
func _on_result_gui_input(event: InputEvent, row: Button) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_UP and not _result_buttons.is_empty() and row == _result_buttons[0]:
			_focus(_search_field)
			accept_event()


func _on_open(fragment_id: String) -> void:
	intent_requested.emit(&"open", {"fragment_id": fragment_id})


func present_fragment(fragment_id: String) -> void:
	if _state == null or not _state.fragments.has(fragment_id):
		return
	_mode_reading = true
	var frag: Dictionary = _state.fragments[fragment_id]
	_reader_title.text = "%s   ·   단어에 마우스를 올리거나 Tab/Shift+Tab으로 숨은 조각을 순회" % fragment_id.to_upper()
	_reader_body.text = _compose_body(frag)
	_reader.show()
	_hover_ids.clear()
	for h: Variant in (frag.get("hover_reveals", []) as Array):
		_hover_ids.append(String((h as Dictionary).get("id", "")))
	_hover_index = -1
	_focus(_reader_body)
	_refresh_tracker()


## qw_peek — hover의 키보드 전용 대응. 마우스 커서 없이도 국소 질의(hover)를 순회한다.
## 마우스 hover와 동일한 peek_hover()를 재사용해 같은 hidden 텍스트를 상태선에 낸다.
func peek_next() -> void:
	if _hover_ids.is_empty():
		return
	_hover_index = (_hover_index + 1) % _hover_ids.size()
	_peek_current()


func peek_prev() -> void:
	if _hover_ids.is_empty():
		return
	if _hover_index <= 0:
		_hover_index = _hover_ids.size() - 1
	else:
		_hover_index -= 1
	_peek_current()


func _peek_current() -> void:
	if _state == null or _hover_index < 0 or _hover_index >= _hover_ids.size():
		return
	var fid: String = _state.last_opened
	var hidden: String = _state.peek_hover(fid, _hover_ids[_hover_index])
	if not hidden.is_empty():
		_status_line.text = "◂ (%d/%d) %s" % [_hover_index + 1, _hover_ids.size(), hidden]


func has_peekable_hovers() -> bool:
	return not _hover_ids.is_empty()


## 본문에 hover 가능한 span을 [url] 메타로 감싼다 → 국소 질의(툴팁 아님).
func _compose_body(frag: Dictionary) -> String:
	var body: String = String(frag.get("body", ""))
	var hovers: Array = frag.get("hover_reveals", [])
	# span 역순으로 삽입해 인덱스 밀림 방지
	var sorted: Array = hovers.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["span_from"]) > int(b["span_from"]))
	for h: Variant in sorted:
		var hover: Dictionary = h
		var from: int = clampi(int(hover["span_from"]), 0, body.length())
		var to: int = clampi(int(hover["span_to"]), from, body.length())
		var seg: String = body.substr(from, to - from)
		var wrapped: String = "[url=%s][color=#%s]%s[/color][/url]" % [String(hover["id"]), HOVER_TINT.to_html(false), seg]
		body = body.substr(0, from) + wrapped + body.substr(to)
	return body


func _on_meta_hover(meta: Variant) -> void:
	if _state == null:
		return
	# meta = hover_id, 소속 fragment는 last_opened
	var fid: String = _state.last_opened
	var hidden: String = _state.peek_hover(fid, String(meta))
	if not hidden.is_empty():
		_status_line.text = "◂ %s" % hidden


func _on_meta_hover_end(_meta: Variant) -> void:
	_status_line.text = ""


func close_reader() -> void:
	_mode_reading = false
	_reader.hide()
	_hover_ids.clear()
	_hover_index = -1
	if not _result_buttons.is_empty():
		_focus(_result_buttons[0])
	else:
		_focus(_search_field)


## 파편 열람 중 Tab/Shift+Tab으로 hover span을 순회(qw_peek, 마우스 없이 국소 질의).
func _on_reader_body_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_TAB:
			if key.shift_pressed:
				peek_prev()
			else:
				peek_next()
			accept_event()


func is_reading() -> bool:
	return _mode_reading


## 검색창(텍스트 입력)이 지금 focus를 갖고 있는가 — module이 타이핑 중엔 액션 폴링을 멈추게.
func search_has_focus() -> bool:
	return _search_field != null and _search_field.has_focus()


func focus_search() -> void:
	_focus(_search_field)


func toggle_tracker() -> void:
	if _tracker_panel.visible:
		_tracker_panel.hide()
	else:
		_refresh_tracker()
		_tracker_panel.show()


func _refresh_tracker() -> void:
	if _state == null:
		return
	for c: Node in _tracker.get_children():
		c.queue_free()
	var ids: Array = _state.fragments.keys()
	ids.sort()
	for fid: Variant in ids:
		var cell := ColorRect.new()
		cell.custom_minimum_size = Vector2(20, 20)
		cell.color = _status_color(_state.reveal_status(String(fid)))
		_tracker.add_child(cell)


func _status_color(status: StringName) -> Color:
	match status:
		&"revealed": return REVEAL_GREEN
		&"last": return REVEAL_YELLOW
		_: return REVEAL_RED


func mark_completed() -> void:
	_status_line.text = "◆ 이 사건을 이해했다"


## focus를 잡되, 헤드리스(디스플레이/스크린리더 없음)에서는 건너뛴다.
## 실게임에는 디스플레이가 있어 정상 동작하고, 자동 테스트의 접근성 경고를 피한다.
func _focus(control: Control) -> void:
	if control == null or not control.is_inside_tree():
		return
	if DisplayServer.get_name() == "headless":
		return
	control.grab_focus()


func _box(color: Color, border: Color, width: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(width)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s


# --- 절차적 배경 (placeholder ColorRect 월드 금지 → 실제 procedural draw) ---
class _AmbientBackground extends Control:
	var _t: float = 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, Color("05050a"))
		# 어둠 속 미세한 격자 노이즈 — 정보가 잠겨 있는 데이터 표면 느낌
		var step: float = 46.0
		var cols: int = int(size.x / step) + 2
		var rows: int = int(size.y / step) + 2
		for iy: int in range(rows):
			for ix: int in range(cols):
				var px: float = ix * step
				var py: float = iy * step
				var phase: float = sin(_t * 0.6 + ix * 0.7 + iy * 0.9)
				var a: float = 0.03 + 0.03 * (phase * 0.5 + 0.5)
				draw_rect(Rect2(px, py, 2.0, 2.0), Color(0.5, 0.55, 0.7, a))
		# 중앙 상단 국소 조명 (검색창 근처를 은은히 밝힘)
		var center := Vector2(size.x * 0.5, size.y * 0.18)
		for r: int in range(6):
			var radius: float = 120.0 + r * 60.0
			draw_circle(center, radius, Color(0.12, 0.14, 0.22, 0.02))


# --- 절차적 조회 단말 프레임 (낡은 기록 열람기 실루엣) --------------------
class _TerminalFrame extends Control:
	var _t: float = 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		# 바탕 패널 (내부 브러시 채움: 위→아래로 미세한 명암 그라데이션 대신 2단 면)
		draw_rect(Rect2(0, 0, w, h), Color("111119"))
		draw_rect(Rect2(0, 0, w, h * 0.5), Color(0.09, 0.10, 0.15, 0.5))
		# 프레임 테두리 (유색 어두운 구조선)
		var edge := Color(0.30, 0.36, 0.52, 0.9)
		draw_rect(Rect2(0, 0, w, h), edge, false, 1.5)
		# 좌측 '단말' 표식: 세 개의 짧은 눈금선 (조회기 느낌의 실루엣)
		var mark := Color(0.42, 0.46, 0.60, 0.7)
		for i: int in range(3):
			var y: float = h * 0.32 + i * 6.0
			draw_line(Vector2(10, y), Vector2(24, y), mark, 1.0)
		# 우측 caret-light: 커서가 살아있음을 알리는 은은한 맥동 점
		var pulse: float = 0.4 + 0.35 * (sin(_t * 3.0) * 0.5 + 0.5)
		draw_circle(Vector2(w - 16, h * 0.5), 3.0, Color(0.48, 0.63, 0.97, pulse))
