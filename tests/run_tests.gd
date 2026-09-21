extends SceneTree

const AppRootScript = preload("res://app/app_root.gd")
const APP_SCENE: String = "res://app/app_root.tscn"
const IDS: Array[StringName] = [&"click_counter", &"box_mover", &"room_3d"]
const ACTIONS: Array[StringName] = [&"click_counter_confirm", &"box_mover_left", &"box_mover_right", &"box_mover_up", &"box_mover_down", &"room_3d_rotate"]
const BOOT_FRAMES: int = 300

var _app: AppRootScript
var _checks: int = 0
var _failed: int = 0
var _results: Array[ModuleResult] = []
var _paths: Array[String] = []
var _owned: Array[Node] = []
var _prefix: String
var _audio_layout: AudioBusLayout
var _done: bool = false
var _frames: int = 0

func _initialize() -> void:
	_prefix = "user://tin_tests_%d_%d_%d" % [OS.get_process_id(), int(Time.get_unix_time_from_system()), Time.get_ticks_usec()]
	_audio_layout = AudioServer.generate_bus_layout()
	_run.call_deferred()

func _process(_delta: float) -> bool:
	_frames += 1
	if _frames > 12000 and not _done:
		_check(false, "runner frame watchdog expired")
		_finish()
	return false

func _run() -> void:
	var packed: PackedScene = load(APP_SCENE) as PackedScene
	if not _check(packed != null, "app scene loads"):
		_finish()
		return
	var instance: Node = packed.instantiate()
	_app = instance as AppRootScript
	if not _check(_app != null, "app scene has expected root script"):
		instance.free()
		_finish()
		return
	var transition: TransitionService = _app.get_node_or_null("Core/TransitionService") as TransitionService
	if not _check(transition != null, "app transition service exists"):
		_finish()
		return
	transition.duration = 0.0
	_app.test_mode = true
	root.add_child(_app)
	var ready_in_time: bool = false
	for frame: int in range(BOOT_FRAMES):
		if _app.is_ready and not _app.director.busy:
			ready_in_time = true
			break
		await process_frame
	if not _check(ready_in_time, "boot readiness within bounded frames"):
		_finish()
		return
	await _wait_frames(3)
	_check(_app.catalog.size() == 3, "catalog contains three modules")
	_check(_app.director.current_id == IDS[0], "boot selects first module")
	_check_single("boot")
	_app.director.module_finished.connect(_on_finished)
	await _test_switches_and_state()
	await _test_input_and_pause()
	await _test_completion()
	_test_save_service()
	await _test_restore_progress()
	_test_settings_and_audio()
	_finish()

func _check(condition: bool, message: String) -> bool:
	_checks += 1
	if not condition:
		_failed += 1
		printerr("FAIL: " + message)
	return condition

func _same(left: Variant, right: Variant) -> bool:
	if (left is int or left is float) and (right is int or right is float):
		return is_equal_approx(float(left), float(right))
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key: Variant in left:
			if not right.has(key) or not _same(left[key], right[key]):
				return false
		return true
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index: int in range(left.size()):
			if not _same(left[index], right[index]):
				return false
		return true
	return left == right

func _wait_frames(count: int = 3) -> void:
	for frame: int in range(count):
		await process_frame

func _check_single(label: String) -> void:
	_check(_app.module_host.get_child_count() == 1, label + ": exactly one hosted child")
	_check(is_instance_valid(_app.director.current_module), label + ": current module exists")
	if is_instance_valid(_app.director.current_module):
		_check(_app.director.current_module.get_parent() == _app.module_host, label + ": current module is hosted")
	_check(not _app.director.busy and not _app.router.locked, label + ": transition settled")

func _switch(id: StringName) -> bool:
	var error: Error = await _app.director.change_module(id)
	if not _check(error == OK, "switch to " + String(id)):
		return false
	await _wait_frames()
	_check(_app.director.current_id == id, "selected id " + String(id))
	_check_single(String(id))
	return true

func _seed(id: StringName) -> Dictionary:
	match id:
		&"click_counter":
			return {"count": 4}
		&"box_mover":
			return {"x": 112.0, "y": 96.0}
		&"room_3d":
			return {"angle": 0.75}
	return {}

func _reset_state(id: StringName) -> Dictionary:
	match id:
		&"click_counter":
			return {"count": 0}
		&"box_mover":
			return {"x": 56.0, "y": 56.0}
		&"room_3d":
			return {"angle": 0.0}
	return {}

func _test_switches_and_state() -> void:
	for id: StringName in IDS:
		if not await _switch(id):
			return
		var module: GameModule = _app.director.current_module
		module.load_state(_seed(id))
		await _wait_frames()
		_check(_same(module.save_state(), _seed(id)), String(id) + ": load/save state roundtrip")
		var before: Dictionary = module.save_state()
		_check(not _app.director.execute_command(&"unknown_test_command", {"count": 99}), String(id) + ": unknown command rejected")
		_check(_same(before, module.save_state()), String(id) + ": unknown command retains state")
	for cycle: int in range(12):
		for id: StringName in IDS:
			var previous: GameModule = _app.director.current_module
			var prior_context: ModuleContext = previous.context
			if not await _switch(id):
				return
			_check(not is_instance_valid(previous), "cycle %d: previous module freed" % cycle)
			_check(not prior_context.input_enabled, "cycle %d: previous context disabled" % cycle)
			_check(_same(_app.director.current_module.save_state(), _seed(id)), "cycle %d: %s state retained" % [cycle, id])
	var current: GameModule = _app.director.current_module
	var snapshot: Dictionary = current.save_state()
	var error: Error = await _app.director.change_module(&"missing_test_module")
	_check(error == ERR_DOES_NOT_EXIST, "unknown module rejected")
	_check(_app.director.current_module == current and _same(current.save_state(), snapshot), "unknown module preserves current")
	_check_single("unknown module rollback")
	for id: StringName in IDS:
		if not await _switch(id):
			return
		_check(_app.director.execute_command(&"reset"), String(id) + ": reset accepted")
		_check(_same(_app.director.current_module.save_state(), _reset_state(id)), String(id) + ": reset restores defaults")

func _action_for(id: StringName) -> StringName:
	match id:
		&"click_counter":
			return &"click_counter_confirm"
		&"box_mover":
			return &"box_mover_right"
		&"room_3d":
			return &"room_3d_rotate"
	return &""

func _tap(action: StringName) -> void:
	Input.action_press(action)
	await _wait_frames(4)
	Input.action_release(action)
	await _wait_frames(3)

func _release_actions() -> void:
	for action: StringName in ACTIONS:
		if InputMap.has_action(action):
			Input.action_release(action)

func _test_input_and_pause() -> void:
	for id: StringName in IDS:
		if not await _switch(id):
			return
		_check(_app.director.execute_command(&"reset"), String(id) + ": input reset")
		var module: GameModule = _app.director.current_module
		var context: ModuleContext = module.context
		var action: StringName = _action_for(id)
		_check(context.module_id == id and context.allows_action(action), String(id) + ": context permits own input")
		var foreign: StringName = &"room_3d_rotate" if id != &"room_3d" else &"click_counter_confirm"
		var before: Dictionary = module.save_state()
		Input.action_press(foreign)
		_check(not context.is_action_pressed(foreign), String(id) + ": context rejects foreign action")
		await _wait_frames(4)
		Input.action_release(foreign)
		await _wait_frames()
		_check(_same(before, module.save_state()), String(id) + ": foreign action leaves module unchanged")
		Input.action_press(action)
		_check(context.is_action_pressed(action), String(id) + ": injected action reaches context")
		await _wait_frames(4)
		Input.action_release(action)
		await _wait_frames()
		_check(not _same(before, module.save_state()), String(id) + ": injected input changes module")
		before = module.save_state()
		var prior_mode: Node.ProcessMode = module.process_mode
		_app._toggle_pause()
		_check(_app.paused and _app.router.locked, String(id) + ": shell pause locks input")
		_check(module.process_mode == Node.PROCESS_MODE_DISABLED, String(id) + ": pause disables module processing")
		Input.action_press(action)
		_check(not context.is_action_pressed(action), String(id) + ": paused context blocks action")
		_check(not _app.director.execute_command(&"reset"), String(id) + ": paused command blocked")
		await _wait_frames(8)
		Input.action_release(action)
		await _wait_frames()
		_check(_same(before, module.save_state()), String(id) + ": paused state unchanged")
		_app._toggle_pause()
		_check(not _app.paused and not _app.router.locked and module.process_mode == prior_mode, String(id) + ": resume restores processing")
		await _tap(action)
		_check(not _same(before, module.save_state()), String(id) + ": input works after resume")
		var old_context: ModuleContext = context
		var next_id: StringName = &"room_3d" if id != &"room_3d" else &"click_counter"
		if not await _switch(next_id):
			return
		Input.action_press(action)
		_check(not old_context.is_action_pressed(action), String(id) + ": retired context cannot read pressed action")
		Input.action_release(action)
	_release_actions()

func _on_finished(result: ModuleResult) -> void:
	_results.append(result)

func _test_completion() -> void:
	if not await _switch(&"click_counter"):
		return
	var module: GameModule = _app.director.current_module
	var button: Button = module.get_node("UI/Center/Rows/IncrementButton") as Button
	_check(_app.director.execute_command(&"reset"), "completion reset")
	_results.clear()
	for click: int in range(15):
		button.pressed.emit()
	_check(_results.size() == 1, "button completion result emitted exactly once")
	_check(_same(module.save_state(), {"count": 10}), "completion count capped at target")
	if _results.size() == 1:
		_check(_results[0].module_id == &"click_counter" and _results[0].outcome == &"completed", "completion result identity and outcome")
		_check(_same(_results[0].data, {"count": 10}), "completion result payload")
	_check(_app.director.execute_command(&"reset"), "completion reset re-arms module")
	_results.clear()
	module.load_state({"count": 9})
	await _tap(&"click_counter_confirm")
	await _tap(&"click_counter_confirm")
	_check(_results.size() == 1, "processed injected action completes exactly once")
	module.load_state({"count": 10})
	await _tap(&"click_counter_confirm")
	button.pressed.emit()
	_check(_results.size() == 1, "loaded completed state does not emit duplicate completion")

func _path(suffix: String) -> String:
	var path: String = _prefix + "_" + suffix
	_paths.append(path)
	return path

func _write_text(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not _check(file != null, "open test fixture " + path.get_file()):
		return false
	file.store_string(text)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	return _check(error == OK, "write test fixture " + path.get_file())

func _test_save_service() -> void:
	var saves := SaveService.new()
	root.add_child(saves)
	_owned.append(saves)
	saves.current_module = &"click_counter"
	saves.global_state = {"level": 3, "nested": [true, null, "test"]}
	saves.set_module_state(&"click_counter", 1, {"count": 6})
	var expected: Dictionary = saves.export_data()
	var path: String = _path("save.json")
	_check(saves.load_file(_path("missing.json")) == ERR_FILE_NOT_FOUND, "missing save returns file-not-found")
	_check(_same(saves.export_data(), expected), "missing save retains state")
	_check(saves.save_file(path) == OK, "JSON disk save")
	saves.global_state = {"changed": true}
	saves.set_module_state(&"click_counter", 1, {"count": 1})
	_check(saves.load_file(path) == OK, "JSON disk load")
	_check(_same(saves.export_data(), expected), "JSON disk roundtrip preserves envelope")
	_check(saves.save_file(path) == OK, "JSON atomic overwrite")
	_check(saves.load_file(path) == OK and _same(saves.export_data(), expected), "JSON overwrite remains readable")
	saves.global_state = {"changed": true}
	_check(saves.save_file(path) == OK, "JSON overwrite keeps a backup")
	saves.global_state = {"lost": true}
	if _write_text(path, "{broken"):
		_check(saves.load_file(path) == OK, "corrupt main save recovers from backup")
		_check(_same(saves.export_data(), expected), "backup recovery restores the prior envelope")
	var detached: Dictionary = saves.get_module_state(&"click_counter")
	detached["state"]["count"] = 99
	_check(_same(saves.export_data(), expected), "get module state is a detached snapshot")
	var malformed: Array[String] = ["{broken", "[]", "{}", JSON.stringify({"format_version": 999, "current_module": "click_counter", "global": {}, "modules": {}}), JSON.stringify({"format_version": 1, "current_module": "click_counter", "global": {}, "modules": {"click_counter": {"schema_version": 0, "state": {}}}}), JSON.stringify({"format_version": 1, "current_module": "click_counter", "global": {}, "modules": {"click_counter": {"schema_version": 1, "state": []}}})]
	var malformed_path: String = _path("malformed.json")
	for index: int in range(malformed.size()):
		if _write_text(malformed_path, malformed[index]):
			_check(saves.load_file(malformed_path) != OK, "malformed envelope %d rejected" % index)
			_check(_same(saves.export_data(), expected), "malformed envelope %d retains state" % index)
	var unsafe_values: Array = [Vector2.ONE, NAN, INF, {1: "non-string key"}, self]
	for value: Variant in unsafe_values:
		_check(not SaveService.is_json_safe({"value": value}), "JSON unsafe value rejected")
		var unsafe_data: Dictionary = expected.duplicate(true)
		unsafe_data["global"] = {"unsafe": value}
		_check(saves.import_data(unsafe_data) == ERR_INVALID_DATA, "unsafe import rejected")
		_check(_same(saves.export_data(), expected), "unsafe import retains prior state")
	var unsafe_path: String = _path("unsafe.json")
	saves.set_module_state(&"click_counter", 1, {"unsafe": Vector3.ONE})
	_check(saves.save_file(unsafe_path) == ERR_INVALID_DATA, "unsafe module state cannot be saved")
	_check(not FileAccess.file_exists(unsafe_path), "unsafe save does not create disk snapshot")
	_check(saves.import_data(expected) == OK, "safe envelope restored after unsafe save test")

func _test_restore_progress() -> void:
	if not await _switch(&"click_counter"):
		return
	_app.director.current_module.load_state({"count": 3})
	_app.director.capture_current()
	_app.saves.global_state = {"test_marker": "loaded snapshot"}
	var saved: Dictionary = _app.saves.export_data()
	var path: String = _path("app_snapshot.json")
	if not _check(_app.saves.save_file(path) == OK, "app snapshot saved to unique path"):
		return
	_app.director.current_module.load_state({"count": 8})
	_app.director.capture_current()
	var error: Error = await _app.restore_progress(path)
	_check(error == OK, "app same-module restore succeeds")
	_check(_same(_app.director.current_module.save_state(), {"count": 3}), "same-module restore does not overwrite loaded snapshot")
	_check(_same(_app.saves.export_data(), saved), "same-module restore retains loaded envelope")
	if not await _switch(&"box_mover"):
		return
	_app.director.current_module.load_state({"x": 180.0, "y": 100.0})
	error = await _app.restore_progress(path)
	_check(error == OK and _app.director.current_id == &"click_counter", "cross-module restore selects saved module")
	_check(_same(_app.director.current_module.save_state(), {"count": 3}), "cross-module restore loads saved state")
	_check(_same(_app.saves.export_data(), saved), "cross-module restore does not capture outgoing state into snapshot")
	_check_single("snapshot restore")
	var retained: GameModule = _app.director.current_module
	var retained_state: Dictionary = retained.save_state()
	var invalid: Dictionary = saved.duplicate(true)
	invalid["current_module"] = "nonexistent_saved_module"
	var invalid_path: String = _path("invalid_module.json")
	if _write_text(invalid_path, JSON.stringify(invalid)):
		error = await _app.restore_progress(invalid_path)
		_check(error == ERR_DOES_NOT_EXIST, "invalid saved module rejected")
		_check(_app.director.current_module == retained and _same(retained.save_state(), retained_state), "invalid saved module preserves current instance and state")
		_check(_same(_app.saves.export_data(), saved), "invalid saved module rolls back envelope")
	var future_path: String = _path("future_module.json")
	for id: StringName in [&"click_counter", &"room_3d"]:
		var future: Dictionary = saved.duplicate(true)
		future["current_module"] = String(id)
		future["modules"][String(id)] = {"schema_version": 999999, "state": {}}
		if _write_text(future_path, JSON.stringify(future)):
			error = await _app.restore_progress(future_path)
			_check(error == ERR_INVALID_DATA, String(id) + ": future module version rejected")
			_check(_app.director.current_module == retained and _same(retained.save_state(), retained_state), String(id) + ": future version preserves current module")
			_check(_same(_app.saves.export_data(), saved), String(id) + ": future version restores prior envelope")
			_check_single("future version rollback")
	var corrupt_path: String = _path("app_corrupt.json")
	if _write_text(corrupt_path, "{\"format_version\":1}"):
		error = await _app.restore_progress(corrupt_path)
		_check(error != OK and _app.director.current_module == retained, "app malformed envelope preserves current module")
		_check(_same(_app.saves.export_data(), saved), "app malformed envelope preserves save state")

func _test_settings_and_audio() -> void:
	var settings := SettingsService.new()
	var loaded := SettingsService.new()
	root.add_child(settings)
	root.add_child(loaded)
	_owned.append(settings)
	_owned.append(loaded)
	var expected: Dictionary = {}
	for index: int in range(SettingsService.BUSES.size()):
		var bus: StringName = SettingsService.BUSES[index]
		var volume: float = float(index + 1) / 10.0
		settings.set_volume(bus, volume)
		expected[bus] = volume
	var path: String = _path("settings.cfg")
	_check(settings.save_file(path) == OK, "settings ConfigFile disk save")
	_check(loaded.load_file(path) == OK, "settings ConfigFile disk load")
	var config := ConfigFile.new()
	_check(config.load(path) == OK, "settings is valid ConfigFile")
	for bus: StringName in SettingsService.BUSES:
		_check(is_equal_approx(loaded.get_volume(bus), float(expected[bus])), String(bus) + ": settings roundtrip")
		_check(is_equal_approx(float(config.get_value("audio", String(bus), -1.0)), float(expected[bus])), String(bus) + ": config disk value")
	settings.set_volume(&"Master", 2.0)
	_check(is_equal_approx(settings.get_volume(&"Master"), 1.0), "settings upper clamp")
	settings.set_volume(&"Master", -1.0)
	_check(is_zero_approx(settings.get_volume(&"Master")), "settings lower clamp")
	settings.set_volume(&"Master", NAN)
	_check(is_zero_approx(settings.get_volume(&"Master")), "settings ignores nonfinite value")
	var bus_count: int = AudioServer.bus_count
	_app.audio.setup()
	_app.audio.setup()
	_check(AudioServer.bus_count == bus_count, "audio setup is idempotent")
	for bus: StringName in SettingsService.BUSES:
		var index: int = AudioServer.get_bus_index(bus)
		if not _check(index >= 0, String(bus) + ": audio bus exists"):
			continue
		if bus != &"Master":
			_check(AudioServer.get_bus_send(index) == &"Master", String(bus) + ": routes to Master")
		_app.audio.set_volume(bus, 0.25)
		_check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.25), String(bus) + ": audio linear volume")
		_check(not AudioServer.is_bus_mute(index), String(bus) + ": nonzero volume unmutes")
		_app.audio.set_volume(bus, 0.0)
		_check(AudioServer.is_bus_mute(index), String(bus) + ": zero volume mutes")
		_app.audio.set_volume(bus, 0.5)
		_check(not AudioServer.is_bus_mute(index), String(bus) + ": restored volume unmutes")
	_app.audio.play_music(null)
	_app.audio.stop_music()

func _finish() -> void:
	if _done:
		return
	_done = true
	_release_actions()
	if is_instance_valid(_app):
		if _app.is_ready and not _app.director.busy:
			if _app.paused:
				_app._toggle_pause()
			var prior: GameModule = _app.director.current_module
			_app.director.unload_module()
			_check(_app.module_host.get_child_count() == 0, "teardown empties module host")
			_check(not is_instance_valid(prior), "teardown frees current module")
		_app.free()
	for node: Node in _owned:
		if is_instance_valid(node):
			node.free()
	_owned.clear()
	_results.clear()
	for path: String in _paths:
		for suffix: String in ["", ".tmp", ".bak"]:
			var candidate: String = path + suffix
			if FileAccess.file_exists(candidate):
				_check(DirAccess.remove_absolute(candidate) == OK, "cleanup " + candidate.get_file())
	AudioServer.set_bus_layout(_audio_layout)
	print("TIN tests: %d checks, %d passed, %d failed" % [_checks, _checks - _failed, _failed])
	quit(1 if _failed > 0 else 0)
