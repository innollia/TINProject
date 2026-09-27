extends GameModule

## Query World Kit — GameModule.
## 검색어(능동 질의) + hover(국소 질의)로만 드러나는 세계.
## domain(QueryWorldState) = 진실, presentation(QueryWorldScreen) = 표현+intent.
## 입력은 ModuleContext가 허용한 action만. /root 탐색·service locator 없음.

const QueryWorldStateScript = preload("res://modules/query_world/domain/query_world_state.gd")
const ContentLoaderScript = preload("res://modules/query_world/domain/query_world_content_loader.gd")

const ACTIONS: Array[StringName] = [
	&"query_world_left", &"query_world_right", &"query_world_up",
	&"query_world_down", &"query_world_confirm", &"query_world_cancel",
]

var state: QueryWorldState = null
var content_ids: Array[StringName] = []

var _screen: QueryWorldScreen = null
var _pending_state: Variant = null
var _held: Dictionary = {}
var _cases: Array = []
var _last_query: String = ""
var _completed: bool = false


func _ready() -> void:
	_screen = get_node_or_null("Screen") as QueryWorldScreen
	if _screen != null and not _screen.intent_requested.is_connected(_on_intent):
		_screen.intent_requested.connect(_on_intent)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_last_query = ""
	_completed = false
	_cases = ContentLoaderScript.load_all()
	content_ids = []
	for c: Variant in _cases:
		content_ids.append(StringName(String((c as Dictionary).get("id", ""))))
	state = QueryWorldStateScript.new()
	var chosen: Dictionary = _resolve_case(_pending_state)
	if not chosen.is_empty():
		state.load_case(chosen)
		if _pending_state is Dictionary and String((_pending_state as Dictionary).get("case_id", "")) == String(state.case_id):
			state.load_runtime(_pending_state)
	if _screen != null:
		_screen.bind_state(state, context.arrival)
	# 시드 검색어가 있고 아직 아무 질의도 없으면(신규 진입) 시드 질의를 1회 실행.
	# 저장 복원(이력 존재)에서는 재실행하지 않아 이력이 오염되지 않는다.
	if state != null and not state.seed_query.is_empty() and state.query_history.is_empty():
		_last_query = state.seed_query
		var seed_result: Dictionary = state.run_query(state.seed_query, int(Time.get_ticks_msec()))
		if _screen != null:
			_screen.present_query_result(state.seed_query, seed_result)
	_pending_state = null


func exit() -> void:
	_held.clear()
	if _screen != null:
		_screen.unbind_state()
	state = null
	super.exit()


## 저장된 case_id가 있으면 그 case, 없으면 첫(정렬상 최초) case.
func _resolve_case(saved: Variant) -> Dictionary:
	var want: String = ""
	if saved is Dictionary:
		want = String((saved as Dictionary).get("case_id", ""))
	for c: Variant in _cases:
		var case: Dictionary = c
		if not want.is_empty() and String(case.get("id", "")) == want:
			return case
	if not _cases.is_empty():
		return _cases[0]
	return {}


func _process(_delta: float) -> void:
	if state == null or context == null or not context.input_enabled:
		_held.clear()
		return
	# 검색창에 타이핑 중이면 액션 폴링을 멈춘다 — z/x/방향키가 LineEdit로 가야 한다.
	if _screen != null and _screen.search_has_focus():
		_held.clear()
		return
	for action: StringName in ACTIONS:
		var pressed: bool = context.is_action_pressed(action)
		var was: bool = bool(_held.get(action, false))
		_held[action] = pressed
		if pressed and not was:
			_dispatch(action)


func _dispatch(action: StringName) -> void:
	if _screen == null:
		return
	match action:
		&"query_world_cancel":
			if _screen.is_reading():
				_screen.close_reader()
			else:
				_screen.toggle_tracker()
		&"query_world_confirm":
			# 목록/검색창의 focus된 컨트롤을 누른다
			var focused: Control = get_viewport().gui_get_focus_owner()
			if focused is Button and _screen.is_ancestor_of(focused):
				(focused as Button).pressed.emit()
		_:
			pass  # 방향키는 Godot의 기본 focus 탐색이 처리


func _on_intent(intent: StringName, payload: Dictionary) -> void:
	if state == null or context == null or not context.input_enabled:
		return
	match intent:
		&"query":
			var raw: String = String(payload.get("raw", ""))
			_last_query = raw
			var result: Dictionary = state.run_query(raw, int(Time.get_ticks_msec()))
			_screen.present_query_result(raw, result)
			_check_completion()
		&"open":
			var fid: String = String(payload.get("fragment_id", ""))
			if state.open_fragment(fid):
				_screen.present_fragment(fid)
				_check_completion()


func _check_completion() -> void:
	if _completed:
		return
	if state.evaluate_completion(_last_query):
		_completed = true
		_screen.mark_completed()
		var result := ModuleResult.new()
		result.outcome = &"completed"
		result.data = {"case_id": String(state.case_id), "revealed": state.revealed_count()}
		finished.emit(result)


# --- 저장 / 로드 (JSON-safe) --------------------------------------------
func save_state() -> Dictionary:
	if state != null:
		return state.save_runtime()
	if _pending_state is Dictionary:
		return (_pending_state as Dictionary).duplicate(true)
	return {}


func load_state(saved: Dictionary) -> void:
	_pending_state = saved.duplicate(true)
	if state != null:
		var chosen: Dictionary = _resolve_case(_pending_state)
		if not chosen.is_empty():
			state.load_case(chosen)
			if String((_pending_state as Dictionary).get("case_id", "")) == String(state.case_id):
				state.load_runtime(_pending_state)
		if _screen != null:
			_screen.bind_state(state, context.arrival if context != null else {})
		_pending_state = null


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return data.duplicate(true)


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if state == null:
		return false
	match command:
		&"reset":
			state.reset_runtime()
			_completed = false
			_last_query = ""
			if _screen != null:
				_screen.bind_state(state, context.arrival if context != null else {})
			return true
		&"query":
			var raw: String = String(payload.get("raw", ""))
			_last_query = raw
			state.run_query(raw, 0)
			_check_completion()
			return true
		&"open":
			return state.open_fragment(String(payload.get("fragment_id", "")))
	return false
