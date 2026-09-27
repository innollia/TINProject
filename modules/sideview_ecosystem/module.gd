extends GameModule

const MODULE_ID: StringName = &"sideview_ecosystem"
const SAVE_VERSION: int = 4
const BINDINGS: Array = [
	[&"eco_left", [KEY_A, KEY_LEFT]],
	[&"eco_right", [KEY_D, KEY_RIGHT]],
	[&"eco_jump", [KEY_SPACE, KEY_W, KEY_UP]],
	[&"eco_curl", [KEY_S, KEY_DOWN]],
	[&"eco_use", [KEY_E, KEY_K]],
]

var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
var save_service: EcoSaveService = EcoSaveService.new()
var index: EcoContentIndex
var table: EcoRungTable
var director: EcoStepDirector
var load_errors: PackedStringArray = []
var _pending_state: Variant = null
var _use_was_held: bool = false


static func register_actions() -> void:
	for pair: Array in BINDINGS:
		var action: StringName = pair[0]
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode: int in pair[1]:
			var ev: InputEventKey = InputEventKey.new()
			ev.physical_keycode = keycode
			if not InputMap.action_has_event(action, ev):
				InputMap.action_add_event(action, ev)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	register_actions()
	if value != null and not value.arrival.is_empty():
		var arrived: EcoWorldstateBridge = EcoWorldstateBridge.from_arrival(value.arrival)
		bridge.view = arrived.view
	_boot()
	_bind_presentation()


func _bind_presentation() -> void:
	var host: Node = get_node_or_null("OverlayLayer/OverlayHost")
	if host == null:
		return
	var screen: EcoGameScreen = host.get_node_or_null("EcoGameScreen")
	if screen == null:
		screen = EcoGameScreen.new()
		screen.name = "EcoGameScreen"
		host.add_child(screen)
	screen.bind(self, director)
	var world_root: Node = get_node_or_null("WorldRoot")
	if world_root != null and world_root.get_child_count() == 0:
		var built: EcoWorldRoot = EcoWorldRoot.new()
		world_root.add_child(built)


func attach_world_store(store: WorldState) -> void:
	bridge.attach_world_store(store)


func _boot() -> void:
	load_errors.clear()
	var ladder: Dictionary = EcoLadder.load_or_fallback(EcoWorldstateBridge.store_rung_values())
	if not ladder["ok"]:
		load_errors.append(str(ladder["reason"]))
		push_error("sideview_ecosystem: " + str(ladder["detail"]))
		return
	var made: Dictionary = EcoRungTable.make(ladder["value"])
	if not made["ok"]:
		load_errors.append(str(made["reason"]))
		return
	table = made["value"]
	var loaded: Dictionary = EcoRegionLoader.load_all(table)
	if not loaded["ok"]:
		load_errors = loaded["errors"]
		for e: String in load_errors:
			push_error("sideview_ecosystem content: " + e)
		return
	index = loaded["value"]
	var saved: Variant = _pending_state if _pending_state != null else save_service.read_file()
	var begun: Dictionary = EcoSaveService.begin(bridge, index, table, saved)
	if not begun["ok"]:
		load_errors.append(str(begun["reason"]))
		return
	director = EcoStepDirector.make(index, table, bridge, save_service)
	director.start(begun["world"], int(begun["world_seed"]))
	director.mode = EcoStepDirector.MODE_LOADING
	_on_ready_to_continue()


func _on_ready_to_continue() -> void:
	var host: Node = get_node_or_null("OverlayLayer/OverlayHost")
	var screen: Node = host.get_node_or_null("EcoGameScreen") if host != null else null
	if screen != null and screen.has_method("show_loading_ready"):
		screen.call("show_loading_ready")
	else:
		continue_from_loading()


func continue_from_loading() -> void:
	if director != null and director.mode == EcoStepDirector.MODE_LOADING:
		director.mode = EcoStepDirector.MODE_NORMAL


func build_intent() -> Dictionary:
	var intent: Dictionary = EcoPlayerBody.intent_from_context(context)
	var use_held: bool = bool(intent.get("use_held", false))
	intent["use_pressed"] = use_held and not _use_was_held
	_use_was_held = use_held
	return intent


func _physics_process(_delta: float) -> void:
	if director == null or context == null or not context.input_enabled:
		return
	director.step_frame(build_intent())
	_sync_presentation()


func _sync_presentation() -> void:
	var world_root: Node = get_node_or_null("WorldRoot")
	var built: Node = world_root.get_node_or_null("EcoWorldRoot") if world_root != null else null
	if built != null and built.has_method("sync"):
		built.call("sync", director)
	var host: Node = get_node_or_null("OverlayLayer/OverlayHost")
	var screen: Node = host.get_node_or_null("EcoGameScreen") if host != null else null
	if screen != null and screen.has_method("step"):
		screen.call("step", 1.0 / 60.0)


func save_state() -> Dictionary:
	if director == null:
		return {}
	return director.encode()


func load_state(state: Dictionary) -> void:
	var decoded: Dictionary = EcoSaveCodec.decode(state)
	if not decoded["ok"]:
		push_warning("sideview_ecosystem: save not loaded (" + str(decoded["reason"]) + ")")
		return
	_pending_state = state
	if index != null:
		_boot()


func migrate_save(old_version: int, data: Dictionary) -> Dictionary:
	if old_version == SAVE_VERSION:
		return data.duplicate(true)
	return {}


func exit() -> void:
	if context != null:
		context.input_enabled = false
	if director != null:
		director._save("S5")
	bridge.release()
	super.exit()


func request_menu() -> void:
	if director != null:
		director._save("S5")
	requested.emit(&"menu", {})
