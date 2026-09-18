extends Node

signal readiness_changed(is_ready: bool)

const MetaLayerScript = preload("res://meta/meta_layer.gd")
const SET_IDS: Array[StringName] = [&"signal_desk", &"relay_quay", &"last_echo", &"return_cradle", &"maintenance_cut", &"glyph_gallery", &"switchboard_choir", &"rain_lift", &"borrowed_title", &"glasshouse_return", &"teacup_orbit", &"numberless_clock", &"shadow_ferry", &"receipt_orchard", &"wrong_weather"]
const NORMAL_IDS: Array[StringName] = [&"first_entry", &"signal_desk", &"relay_quay", &"last_echo", &"return_cradle", &"maintenance_cut", &"glyph_gallery", &"switchboard_choir", &"rain_lift", &"borrowed_title", &"glasshouse_return", &"teacup_orbit", &"numberless_clock", &"shadow_ferry", &"receipt_orchard", &"wrong_weather"]
const ROUTES: Dictionary = {
	"signal_desk": {"forward": "relay_quay", "hidden": "maintenance_cut", "side": "glyph_gallery"},
	"relay_quay": {"forward": "last_echo", "back": "signal_desk"},
	"last_echo": {"back": "relay_quay"},
	"return_cradle": {"forward": "signal_desk", "hidden": "maintenance_cut"},
	"maintenance_cut": {"forward": "last_echo", "back": "return_cradle"},
	"glyph_gallery": {"forward": "switchboard_choir"},
	"switchboard_choir": {"forward": "rain_lift"},
	"rain_lift": {"forward": "borrowed_title", "back": "switchboard_choir"},
	"borrowed_title": {"forward": "glasshouse_return"},
	"glasshouse_return": {"forward": "teacup_orbit", "hidden": "borrowed_title"},
	"teacup_orbit": {"forward": "signal_desk", "side": "numberless_clock"},
	"numberless_clock": {"forward": "signal_desk", "side": "shadow_ferry"},
	"shadow_ferry": {"forward": "receipt_orchard", "back": "numberless_clock"},
	"receipt_orchard": {"forward": "wrong_weather", "back": "shadow_ferry"},
	"wrong_weather": {"forward": "signal_desk", "back": "receipt_orchard"},
}

@export var catalog: Array[ModuleManifest] = []
@export var test_mode: bool = false

@onready var director: ModuleDirector = $Core/ModuleDirector
@onready var saves: SaveService = $Core/SaveService
@onready var settings: SettingsService = $Core/SettingsService
@onready var router: InputRouter = $Core/InputRouter
@onready var transition: TransitionService = $Core/TransitionService
@onready var audio: AudioService = $Core/AudioService
@onready var meta_layer: MetaLayerScript = $MetaLayer
@onready var module_host: Node = $ModuleHost
@onready var selector: OptionButton = $UIHost/UI/Shell/Rows/Controls/ModuleSelector
@onready var switch_button: Button = $UIHost/UI/Shell/Rows/Controls/Switch
@onready var save_button: Button = $UIHost/UI/Shell/Rows/Controls/Save
@onready var load_button: Button = $UIHost/UI/Shell/Rows/Controls/Load
@onready var pause_button: Button = $UIHost/UI/Shell/Rows/Controls/Pause
@onready var reset_button: Button = $UIHost/UI/Shell/Rows/Controls/Reset
@onready var volume_slider: HSlider = $UIHost/UI/Shell/Rows/Settings/Volume
@onready var volume_button: Button = $UIHost/UI/Shell/Rows/Settings/SaveSettings
@onready var narrator: Label = $UIHost/UI/Shell/Rows/Narrator
@onready var status: Label = $UIHost/UI/Shell/Rows/Status
@onready var debug_label: Label = $DebugRoot/Label

var is_ready: bool = false
var paused: bool = false
var dev_shell: bool = false
var profile: Dictionary = {"intro_seen": false, "shape": 0, "color": 0, "started": false}
var language: String = "ko"
var records_store: RefCounted
var records_overlay: Control
var useless_clicks: int = 0
var save_path: String = "user://save.json"
var _settings_path: String = "user://settings.cfg"
var _storage_allowed: bool = true
var _operation_pending: bool = false
var _request_pending: bool = false
var _generation: int = 0
var _restoring: bool = false
var _suppress_records_save: bool = false
var _records_save_queued: bool = false
var _last_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT
var _load_started_usec: int = 0
var _last_load_ms: float = 0.0
var _menu: PanelContainer
var _journal: PanelContainer
var _menu_button: Button
var _journal_button: Button
var _resume_button: Button
var _language_button: Button
var _clicker_button: Button
var _quit_button: Button
var _journal_close: Button
var _settings_label: Label
var _menu_volume: HSlider
var _quit_dialog: ConfirmationDialog
var _notice: Label


func _ready() -> void:
	get_tree().auto_accept_quit = false
	_configure_launch()
	if not dev_shell:
		catalog.clear()
		for id: StringName in NORMAL_IDS:
			var filename: String = "manifest.tres" if id == &"first_entry" else "module_manifest.tres"
			var path: String = "res://modules/%s/%s" % [id, filename]
			var manifest := load(path) as ModuleManifest
			if manifest == null:
				_fail("Missing module manifest: " + path, ERR_FILE_NOT_FOUND)
				return
			catalog.append(manifest)
	router.configure_actions()
	_configure_module_actions()
	audio.setup()
	transition.setup($UIHost/UI/TransitionOverlay as ColorRect)
	director.setup(module_host, catalog, router, saves, transition)
	director.module_changed.connect(_on_module_changed)
	director.module_finished.connect(_on_module_finished)
	director.module_requested.connect(_on_module_requested)
	settings.changed.connect(_sync_volume)
	meta_layer.narration_changed.connect(_on_narration_changed)
	switch_button.pressed.connect(_on_switch_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	pause_button.pressed.connect(_toggle_pause)
	reset_button.pressed.connect(_on_reset_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_button.pressed.connect(_on_save_settings_pressed)
	$UIHost/UI/Shell.visible = dev_shell
	$DebugRoot.visible = dev_shell
	_setup_records()
	_build_shared_ui()
	selector.clear()
	for manifest: ModuleManifest in catalog:
		if manifest == null:
			_fail("Catalog contains an empty manifest.", ERR_INVALID_DATA)
			return
		selector.add_item(manifest.display_name)
	if not test_mode and _storage_allowed:
		var settings_error: Error = settings.load_file(_settings_path)
		if settings_error != OK and settings_error != ERR_FILE_NOT_FOUND:
			_fail("Could not load settings.", settings_error)
	_sync_volume()
	if catalog.is_empty():
		_fail("No modules in the catalog.", ERR_UNCONFIGURED)
		return
	var error: Error = OK
	if dev_shell:
		meta_layer.restore(saves.global_state)
		error = await _change_module(catalog[0].id)
	else:
		var resumed: bool = false
		if not test_mode and _storage_allowed:
			error = await _restore_progress_internal(save_path)
			resumed = error == OK
		if not resumed:
			error = await _change_module(&"first_entry")
	is_ready = error == OK
	_update_shared_text()
	readiness_changed.emit(is_ready)


func _configure_launch() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	dev_shell = test_mode or args.has("--dev-shell")
	if test_mode:
		save_path = ""
		_settings_path = ""
		return
	for index: int in range(args.size()):
		var candidate: String = ""
		if args[index] == "--test-profile":
			if index + 1 < args.size():
				candidate = args[index + 1]
		elif args[index].begins_with("--test-profile="):
			candidate = args[index].trim_prefix("--test-profile=")
		else:
			continue
		if not _is_test_path(candidate):
			_storage_allowed = false
			save_path = ""
			_settings_path = ""
			return
		save_path = candidate
		_settings_path = candidate + ".settings.cfg"


func _is_test_path(path: String) -> bool:
	if not path.begins_with("user://tin_tests_"):
		return false
	var tail: String = path.trim_prefix("user://")
	if tail.length() <= "tin_tests_".length() or tail.contains(".."):
		return false
	for index: int in range(tail.length()):
		var code: int = tail.unicode_at(index)
		if not ((code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or code == 95 or code == 45 or code == 46):
			return false
	return true


func _resolve_save_path(path: String) -> String:
	var resolved: String = save_path if path.is_empty() else path
	if not _storage_allowed or resolved.is_empty():
		return ""
	if test_mode and not _is_test_path(resolved):
		return ""
	if save_path.begins_with("user://tin_tests_") and not _is_test_path(resolved):
		return ""
	return resolved


func _process(_delta: float) -> void:
	var blocked: bool = not is_ready or _operation_pending or _request_pending or director.busy
	selector.disabled = blocked or paused
	switch_button.disabled = blocked or paused
	save_button.disabled = blocked or paused or director.current_module == null
	load_button.disabled = blocked or paused
	pause_button.disabled = blocked or director.current_module == null
	reset_button.disabled = blocked or paused or director.current_module == null
	volume_button.disabled = blocked
	pause_button.text = "Resume (P)" if paused else "Pause (P)"
	debug_label.text = "Loaded: %d | Last load: %.1f ms" % [module_host.get_child_count(), _last_load_ms]
	if _menu_button != null:
		_menu_button.disabled = blocked
		_journal_button.disabled = blocked
	if paused and not router.locked:
		router.set_locked(true)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			if _quit_dialog != null and _quit_dialog.visible:
				_quit_dialog.hide()
			else:
				_toggle_pause()
		elif event.keycode == KEY_J:
			var focused: Control = get_viewport().gui_get_focus_owner()
			if focused is LineEdit or focused is TextEdit:
				return
			get_viewport().set_input_as_handled()
			toggle_journal()
		elif dev_shell and event.is_action_pressed(&"meta_pause", false):
			get_viewport().set_input_as_handled()
			_toggle_pause()


func _configure_module_actions() -> void:
	var bindings: Dictionary = {
		&"click_counter_confirm": [KEY_ENTER],
		&"room_3d_rotate": [KEY_ENTER],
		&"box_mover_left": [KEY_A, KEY_LEFT],
		&"box_mover_right": [KEY_D, KEY_RIGHT],
		&"box_mover_up": [KEY_W, KEY_UP],
		&"box_mover_down": [KEY_S, KEY_DOWN],
	}
	for id: StringName in NORMAL_IDS:
		bindings[StringName("%s_left" % id)] = [KEY_LEFT]
		bindings[StringName("%s_right" % id)] = [KEY_RIGHT]
		bindings[StringName("%s_up" % id)] = [KEY_UP]
		bindings[StringName("%s_down" % id)] = [KEY_DOWN]
		bindings[StringName("%s_confirm" % id)] = [KEY_Z]
		bindings[StringName("%s_cancel" % id)] = [KEY_X]
	for action: StringName in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: int in bindings[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			if not InputMap.action_has_event(action, key):
				InputMap.action_add_event(action, key)


func _can_operate() -> bool:
	return is_ready and not paused and not _operation_pending and not _request_pending and not director.busy


func _arrival() -> Dictionary:
	return {"intro_seen": bool(profile["intro_seen"]), "language": language}


func _identity() -> Dictionary:
	return {"shape": int(profile["shape"]), "color": int(profile["color"])}


func _change_module(id: StringName, restore_snapshot: bool = false, discard_current: bool = false) -> Error:
	_operation_pending = true
	_load_started_usec = Time.get_ticks_usec()
	status.text = "Loading module..."
	var previous: Dictionary = saves.export_data()
	var error: Error = await director.change_module(id, restore_snapshot, _arrival(), _identity(), discard_current)
	if error != OK:
		saves.import_data(previous)
	_last_load_ms = float(Time.get_ticks_usec() - _load_started_usec) / 1000.0
	_operation_pending = false
	if error != OK:
		_fail("Could not switch module.", error)
	else:
		status.text = "Module ready."
	return error


func _on_switch_pressed() -> void:
	if not _can_operate() or selector.selected < 0 or selector.selected >= catalog.size():
		return
	await _change_module(catalog[selector.selected].id)


func _on_save_pressed() -> void:
	var error: Error = save_progress()
	if error != OK:
		_fail("Could not save progress.", error)


func _capture_global() -> void:
	var state: Dictionary = meta_layer.capture(saves.global_state)
	state["profile"] = profile.duplicate(true)
	state["language"] = language
	if records_store != null:
		state["records"] = records_store.call("capture")
	saves.global_state = state


func save_progress(path: String = "") -> Error:
	if not is_ready or _operation_pending or _request_pending or director.busy:
		return ERR_BUSY
	var resolved: String = _resolve_save_path(path)
	if resolved.is_empty():
		return ERR_INVALID_PARAMETER
	_operation_pending = true
	var previous: Dictionary = saves.export_data()
	director.capture_current()
	_capture_global()
	var error: Error = saves.save_file(resolved)
	if error != OK:
		saves.import_data(previous)
	else:
		status.text = "Progress saved."
	_operation_pending = false
	return error


func _persist_action() -> Error:
	if test_mode and save_path.is_empty():
		_capture_global()
		return OK
	var error: Error = save_progress()
	if error != OK:
		_fail("Could not save progress.", error)
	return error


func _on_load_pressed() -> void:
	if not _can_operate():
		return
	var error: Error = await restore_progress()
	if error == ERR_FILE_NOT_FOUND:
		status.text = "No saved progress yet. Use Save first."
	elif error != OK:
		_fail("Could not load progress; current module retained.", error)


func restore_progress(path: String = "") -> Error:
	if not _can_operate():
		return ERR_BUSY
	var resolved: String = _resolve_save_path(path)
	if resolved.is_empty():
		return ERR_INVALID_PARAMETER
	return await _restore_progress_internal(resolved)


func _valid_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value)) and float(value) >= 0.0 and float(value) <= 2147483647.0


func _validate_global(state: Dictionary) -> bool:
	if state.has("profile"):
		var candidate: Variant = state["profile"]
		if not candidate is Dictionary:
			return false
		if not candidate.get("intro_seen") is bool or not candidate.get("started") is bool:
			return false
		if not _valid_integer(candidate.get("shape")) or not _valid_integer(candidate.get("color")):
			return false
	elif not dev_shell:
		return false
	if state.has("language") and state["language"] != "ko" and state["language"] != "en":
		return false
	if state.has("records"):
		if not state["records"] is Dictionary or records_store == null:
			return false
		var script: Script = records_store.get_script() as Script
		var validator: RefCounted = script.new()
		if not bool(validator.call("restore", state["records"].duplicate(true))):
			return false
	return true


func _restore_progress_internal(path: String) -> Error:
	_operation_pending = true
	_restoring = true
	var previous: Dictionary = saves.export_data()
	var previous_profile: Dictionary = profile.duplicate(true)
	var previous_language: String = language
	var previous_records: Dictionary = records_store.call("capture") if records_store != null else {}
	var error: Error = saves.load_file(path)
	if error == OK:
		if _catalog_index(saves.current_module) < 0:
			error = ERR_DOES_NOT_EXIST
		elif not _validate_global(saves.global_state):
			error = ERR_INVALID_DATA
		elif not dev_shell and (not bool(saves.global_state["profile"]["started"]) or not SET_IDS.has(saves.current_module)):
			if not bool(saves.global_state["profile"]["started"]) and saves.current_module == &"first_entry":
				error = OK
			else:
				error = ERR_INVALID_DATA
	if error == OK:
		if saves.global_state.has("profile"):
			profile = saves.global_state["profile"].duplicate(true)
		language = str(saves.global_state.get("language", language))
		_suppress_records_save = true
		if records_store != null and saves.global_state.has("records"):
			if not bool(records_store.call("restore", saves.global_state["records"].duplicate(true))):
				error = ERR_INVALID_DATA
		_suppress_records_save = false
		if error == OK:
			error = await director.change_module(saves.current_module, true, _arrival(), _identity())
	if error != OK:
		saves.import_data(previous)
		profile = previous_profile
		language = previous_language
		_suppress_records_save = true
		if records_store != null:
			records_store.call("restore", previous_records)
		_suppress_records_save = false
	else:
		meta_layer.restore(saves.global_state)
		status.text = "Progress loaded."
	if records_overlay != null:
		records_overlay.call("refresh")
	_restoring = false
	_operation_pending = false
	_update_shared_text()
	return error


func _on_module_requested(kind: StringName, payload: Dictionary) -> void:
	if not _can_operate() or director.current_module == null or router.locked:
		return
	var source: GameModule = director.current_module
	if source.context == null or not source.context.input_enabled:
		return
	if not _valid_request(kind, payload, director.current_id):
		return
	var exclusive: bool = kind in [&"portal", &"died", &"start", &"menu", &"language"]
	if exclusive:
		_request_pending = true
	_dispatch_request.call_deferred(kind, payload.duplicate(true), source.get_instance_id(), director.current_id, _generation, exclusive)


func _valid_request(kind: StringName, payload: Dictionary, source: StringName) -> bool:
	match kind:
		&"portal":
			return payload.get("exit") is String and ROUTES.get(String(source), {}).has(payload["exit"])
		&"died":
			return source == &"last_echo" and payload.is_empty()
		&"observation":
			return SET_IDS.has(source) and payload.get("id") is String and not String(payload["id"]).strip_edges().is_empty() and payload.get("text") is String
		&"checkpoint":
			return source == &"first_entry" and payload.get("intro_seen") is bool and payload["intro_seen"]
		&"start":
			return source == &"first_entry" and not bool(profile["started"]) and payload.get("shape") is int and payload.get("color") is int and _valid_integer(payload["shape"]) and _valid_integer(payload["color"])
		&"menu", &"language":
			return payload.is_empty()
	return false


func _dispatch_request(kind: StringName, payload: Dictionary, source_instance: int, source_id: StringName, generation: int, exclusive: bool) -> void:
	if exclusive:
		_request_pending = false
	if not is_ready or paused or _operation_pending or director.busy or generation != _generation or director.current_module == null:
		return
	if director.current_id != source_id or director.current_module.get_instance_id() != source_instance or router.locked:
		return
	if not _valid_request(kind, payload, source_id):
		return
	match kind:
		&"portal":
			var target: StringName = StringName(ROUTES[String(source_id)][payload["exit"]])
			if await _change_module(target) == OK:
				_persist_action()
		&"died":
			await _return_after_death()
		&"observation":
			if records_store != null:
				records_store.call("observe", source_id, payload)
		&"checkpoint":
			if not bool(profile["intro_seen"]):
				profile["intro_seen"] = true
				_persist_action()
		&"start":
			var old_profile: Dictionary = profile.duplicate(true)
			profile["shape"] = int(payload["shape"])
			profile["color"] = int(payload["color"])
			profile["started"] = true
			profile["intro_seen"] = true
			var entrances: Array[StringName] = [&"signal_desk", &"relay_quay", &"return_cradle"]
			if await _change_module(entrances[int(profile["shape"]) % 3]) == OK:
				_persist_action()
			else:
				profile = old_profile
				director.execute_command(&"retry_start")
		&"menu":
			_toggle_pause()
		&"language":
			set_language("en" if language == "ko" else "ko")


func _return_after_death() -> Error:
	var previous: Dictionary = saves.export_data()
	var cleared: Dictionary = previous.duplicate(true)
	var states: Dictionary = cleared["modules"]
	for id: StringName in SET_IDS:
		states.erase(String(id))
	var error: Error = saves.import_data(cleared)
	if error != OK:
		return error
	error = await _change_module(&"return_cradle", false, true)
	if error != OK:
		saves.import_data(previous)
	else:
		_persist_action()
	return error


func _set_paused(value: bool) -> void:
	if paused == value or director.current_module == null:
		return
	paused = value
	if paused:
		_last_process_mode = director.current_module.process_mode
		router.set_locked(true)
		director.current_module.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		director.current_module.process_mode = _last_process_mode
		router.set_locked(false)


func _toggle_pause() -> void:
	if not is_ready or _operation_pending or _request_pending or director.busy or director.current_module == null:
		return
	if paused:
		_menu.hide()
		_journal.hide()
		_quit_dialog.hide()
		_set_paused(false)
	else:
		_set_paused(true)
		_menu.show()
		_resume_button.grab_focus()


func toggle_journal() -> void:
	if not is_ready or _operation_pending or _request_pending or director.busy or director.current_module == null:
		return
	if _journal.visible:
		_journal.hide()
		_set_paused(false)
	else:
		_menu.hide()
		_quit_dialog.hide()
		_set_paused(true)
		_journal.show()
		if records_overlay != null:
			records_overlay.call("refresh")
		_journal_close.grab_focus()


func _on_reset_pressed() -> void:
	if not _can_operate():
		return
	if director.execute_command(&"reset"):
		status.text = "Current module reset. Saved progress is unchanged until Save."
	else:
		status.text = "This module does not support reset."


func _on_volume_changed(value: float) -> void:
	settings.set_volume(&"Master", value)
	audio.set_volume(&"Master", value)


func _sync_volume() -> void:
	var volume: float = settings.get_volume(&"Master")
	volume_slider.set_value_no_signal(volume)
	if _menu_volume != null:
		_menu_volume.set_value_no_signal(volume)
	audio.set_volume(&"Master", volume)


func _on_save_settings_pressed() -> void:
	if not is_ready or _operation_pending or director.busy:
		return
	if test_mode or not _storage_allowed:
		return
	var error: Error = settings.save_file(_settings_path)
	if error != OK:
		_fail("Could not save settings.", error)
	else:
		status.text = "Volume setting saved."


func set_language(value: String) -> bool:
	if value not in ["ko", "en"] or not is_ready or _operation_pending or director.busy:
		return false
	language = value
	_update_shared_text()
	if director.current_module != null and director.current_module.context != null:
		director.current_module.context.arrival = _arrival()
		director.current_module.execute_command(&"language", {"language": language})
	_persist_action()
	return true


func _on_module_changed(id: StringName) -> void:
	_generation += 1
	var index: int = _catalog_index(id)
	if index >= 0:
		selector.select(index)
		meta_layer.describe_module(id, catalog[index].display_name)
	else:
		meta_layer.describe_module(id, String(id))
	if not _restoring and records_store != null and SET_IDS.has(id):
		_suppress_records_save = true
		records_store.call("visit", id)
		_suppress_records_save = false


func _on_module_finished(result: ModuleResult) -> void:
	if result == null:
		status.text = "Module returned an empty result."
		return
	meta_layer.record_result(result)
	saves.global_state = meta_layer.capture(saves.global_state)


func _on_narration_changed(text: String) -> void:
	narrator.text = text


func _catalog_index(id: StringName) -> int:
	for index: int in range(catalog.size()):
		if catalog[index] != null and catalog[index].id == id:
			return index
	return -1


func _setup_records() -> void:
	var path: String = "res://meta/records/records_store.gd"
	if not ResourceLoader.exists(path):
		_fail("Records store is unavailable.", ERR_FILE_NOT_FOUND)
		return
	var script := load(path) as Script
	records_store = script.new()
	if records_store.has_signal("changed"):
		records_store.connect("changed", _on_records_changed)


func _on_records_changed() -> void:
	if _suppress_records_save or _restoring or not is_ready or _records_save_queued:
		return
	_records_save_queued = true
	_flush_records_save.call_deferred()


func _flush_records_save() -> void:
	_records_save_queued = false
	if _restoring:
		return
	if _operation_pending or _request_pending or director.busy:
		_records_save_queued = true
		get_tree().process_frame.connect(_flush_records_save, CONNECT_ONE_SHOT)
		return
	_persist_action()


func add_note(text: String, tags: String = "") -> void:
	if records_store != null and is_ready and not _operation_pending and not director.busy:
		records_store.call("add_note", text, tags)


func select_theme(id: String) -> bool:
	if records_store == null or not is_ready or _operation_pending or director.busy:
		return false
	return bool(records_store.call("select_theme", id))


func _build_shared_ui() -> void:
	var ui: Control = $UIHost/UI
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR"])
	font.allow_system_fallback = true
	ui.add_theme_font_override("font", font)
	var bar := HBoxContainer.new()
	bar.name = "SharedBar"
	ui.add_child(bar)
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	bar.offset_left = -280.0
	bar.offset_right = -12.0
	bar.offset_top = 154.0 if dev_shell else 12.0
	bar.offset_bottom = bar.offset_top + 40.0
	_menu_button = _button(bar, "Menu", _toggle_pause)
	_journal_button = _button(bar, "Journal (J)", toggle_journal)
	_menu = PanelContainer.new()
	_menu.name = "SharedMenu"
	ui.add_child(_menu)
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_menu.add_child(center)
	var rows := VBoxContainer.new()
	rows.custom_minimum_size = Vector2(380, 0)
	rows.add_theme_constant_override("separation", 16)
	center.add_child(rows)
	_resume_button = _button(rows, "Resume", _toggle_pause)
	_settings_label = Label.new()
	rows.add_child(_settings_label)
	_menu_volume = HSlider.new()
	_menu_volume.min_value = 0.0
	_menu_volume.max_value = 1.0
	_menu_volume.step = 0.01
	_menu_volume.custom_minimum_size = Vector2(300, 32)
	rows.add_child(_menu_volume)
	_menu_volume.value_changed.connect(_on_menu_volume_changed)
	_language_button = _button(rows, "Language", _on_language_pressed)
	_clicker_button = _button(rows, "Useless clicks: 0", _on_useless_click)
	_quit_button = _button(rows, "Quit", _on_quit_pressed)
	_notice = Label.new()
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_notice)
	_menu.hide()
	_journal = PanelContainer.new()
	_journal.name = "Journal"
	ui.add_child(_journal)
	_journal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var journal_rows := VBoxContainer.new()
	_journal.add_child(journal_rows)
	_journal_close = _button(journal_rows, "Close (J / Esc)", toggle_journal)
	var overlay_path: String = "res://meta/records/records_overlay.gd"
	if records_store != null and ResourceLoader.exists(overlay_path):
		var script := load(overlay_path) as Script
		records_overlay = script.new() as Control
		records_overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
		journal_rows.add_child(records_overlay)
		records_overlay.call("setup", records_store)
		if records_overlay.has_signal("close_requested"):
			records_overlay.connect("close_requested", toggle_journal)
	_journal.hide()
	_quit_dialog = ConfirmationDialog.new()
	_quit_dialog.name = "QuitConfirmation"
	ui.add_child(_quit_dialog)
	_quit_dialog.confirmed.connect(_confirm_quit)
	ui.move_child($UIHost/UI/TransitionOverlay, -1)
	_update_shared_text()


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 38.0
	parent.add_child(button)
	button.pressed.connect(callback)
	return button


func _update_shared_text() -> void:
	if _menu_button == null:
		return
	var korean: bool = language == "ko"
	_menu_button.text = "메뉴 (Esc)" if korean else "Menu (Esc)"
	_journal_button.text = "기록 (J)" if korean else "Journal (J)"
	_resume_button.text = "계속" if korean else "Resume"
	_settings_label.text = "설정 · 전체 음량" if korean else "Settings · Master volume"
	_language_button.text = "언어: 한국어 / English" if korean else "Language: English / 한국어"
	_clicker_button.text = ("쓸모없는 클릭: %d" if korean else "Useless clicks: %d") % useless_clicks
	_quit_button.text = "종료" if korean else "Quit"
	_journal_close.text = "닫기 (J / Esc)" if korean else "Close (J / Esc)"
	_quit_dialog.title = "종료 확인" if korean else "Confirm quit"
	_quit_dialog.dialog_text = "정말 종료할까요?" if korean else "Quit the game?"
	_quit_dialog.ok_button_text = "종료" if korean else "Quit"
	_quit_dialog.cancel_button_text = "취소" if korean else "Cancel"
	_notice.text = "클릭에는 보상이 없습니다. 기록과 외형은 그대로 남습니다." if korean else "Clicks have no rewards. Records and identity remain unchanged."


func _on_menu_volume_changed(value: float) -> void:
	if not is_ready or not paused or _operation_pending or director.busy:
		return
	_on_volume_changed(value)
	_on_save_settings_pressed()


func _on_language_pressed() -> void:
	set_language("en" if language == "ko" else "ko")


func _on_useless_click() -> void:
	if paused and _menu.visible and not _operation_pending and not director.busy:
		useless_clicks += 1
		_update_shared_text()


func _on_quit_pressed() -> void:
	if paused and not _operation_pending and not director.busy:
		_quit_dialog.popup_centered()


func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST or not is_ready or _operation_pending or _request_pending or director.busy:
		return
	if not paused:
		_toggle_pause()
	_on_quit_pressed()


func _confirm_quit() -> void:
	if not paused or _operation_pending or director.busy:
		return
	if _persist_action() == OK:
		get_tree().quit()


func _fail(message: String, error: Error) -> void:
	status.text = "%s (%s)" % [message, error_string(error)]
	if _notice != null:
		_notice.text = status.text
