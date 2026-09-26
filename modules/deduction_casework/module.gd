extends GameModule

const ACTIONS: Array[StringName] = [
	&"deduction_casework_left", &"deduction_casework_right", &"deduction_casework_up",
	&"deduction_casework_down", &"deduction_casework_confirm", &"deduction_casework_cancel"
]
const FOCUS_DIRECTIONS: Dictionary = {
	&"deduction_casework_left": &"left",
	&"deduction_casework_right": &"right",
	&"deduction_casework_up": &"up",
	&"deduction_casework_down": &"down"
}

var content_catalog: Array[StringName] = []
var runtime: DeductionCaseRuntime = null

var _catalog: DeductionContentLoader.CaseCatalog = null
var _pending_state: Variant = null
var _held_actions: Dictionary = {}
@onready var _case_screen: DeductionCaseScreen = get_node_or_null("CaseScreen") as DeductionCaseScreen


func _ready() -> void:
	if _case_screen != null and not _case_screen.intent_requested.is_connected(_on_screen_intent):
		_case_screen.intent_requested.connect(_on_screen_intent)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held_actions.clear()
	_catalog = DeductionContentLoader.load_catalog()
	content_catalog = _catalog.list_case_ids()
	runtime = DeductionCaseRuntime.new()
	runtime.load(_catalog, DeductionSaveAdapter.sanitize(_catalog, _pending_state))
	_bind_presentation()
	_pending_state = null


func exit() -> void:
	_held_actions.clear()
	if _case_screen != null:
		_case_screen.unbind_runtime()
	runtime = null
	_catalog = null
	super.exit()


func _process(_delta: float) -> void:
	if runtime == null or context == null or not context.input_enabled:
		_held_actions.clear()
		return
	for action: StringName in ACTIONS:
		var pressed := context.is_action_pressed(action)
		var previous := bool(_held_actions.get(action, false))
		_held_actions[action] = pressed
		if pressed and not previous:
			_dispatch_action(action)


func save_state() -> Dictionary:
	if runtime != null:
		return runtime.save_state().to_dict()
	return DeductionSaveAdapter.sanitize_shape(content_catalog, _pending_state).to_dict()


func load_state(state: Dictionary) -> void:
	_pending_state = state.duplicate(true)
	if runtime != null and _catalog != null:
		runtime.load(_catalog, DeductionSaveAdapter.sanitize(_catalog, _pending_state))
		_pending_state = null


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return DeductionSaveAdapter.sanitize_shape(content_catalog, data).to_dict()


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if runtime == null:
		return false
	return bool(runtime.dispatch(command, payload).get("accepted", false))


func _dispatch_action(action: StringName) -> void:
	if FOCUS_DIRECTIONS.has(action):
		runtime.dispatch(&"focus_move", {"direction": String(FOCUS_DIRECTIONS[action])})
		return
	if action == &"deduction_casework_cancel":
		runtime.dispatch(&"cancel")
		return
	runtime.dispatch(&"interact", {"target_id": String(runtime.focus_id)})


func _bind_presentation() -> void:
	if _case_screen != null and runtime != null:
		_case_screen.bind_runtime(runtime)


func _on_screen_intent(intent: StringName, payload: Dictionary) -> void:
	if runtime != null:
		runtime.dispatch(intent, payload)
