extends GutTest

const APP = preload("res://app/app_root.tscn")
const AppScript = preload("res://app/app_root.gd")

var app: AppScript
var paths: Array[String] = []
var audio_layout: AudioBusLayout
var pressed_actions: Array[StringName] = []


func before_each() -> void:
	audio_layout = AudioServer.generate_bus_layout()
	app = APP.instantiate() as AppScript
	app.test_mode = true
	(app.get_node("Core/TransitionService") as TransitionService).duration = 0.0
	add_child_autofree(app)
	await _settle()
	assert_true(app.is_ready)
	assert_eq(app.catalog.size(), 3)
	app.director.unload_module()
	app.catalog.clear()
	app.selector.clear()
	for id: StringName in app.NORMAL_IDS:
		var filename: String = "manifest.tres" if id == &"first_entry" else "module_manifest.tres"
		var manifest: ModuleManifest = load("res://modules/%s/%s" % [id, filename]).duplicate(true) as ModuleManifest
		app.catalog.append(manifest)
		app.selector.add_item(String(id))
	app.director.setup(app.module_host, app.catalog, app.router, app.saves, app.transition)
	assert_eq(await app._change_module(&"first_entry"), OK)


func after_each() -> void:
	for action: StringName in pressed_actions:
		Input.action_release(action)
	pressed_actions.clear()
	await _settle()
	for path: String in paths:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(path + suffix)
	paths.clear()
	AudioServer.set_bus_layout(audio_layout)


func _settle() -> void:
	for frame: int in range(5):
		await get_tree().process_frame


func _path(label: String) -> String:
	var path: String = "user://tin_tests_cycle_%d_%d_%s.json" % [OS.get_process_id(), Time.get_ticks_usec(), label]
	paths.append(path)
	return path


func _request(kind: StringName, payload: Dictionary = {}) -> void:
	app.director.current_module.requested.emit(kind, payload)
	await _settle()


func _tap_action(action: StringName) -> void:
	assert_true(InputMap.has_action(action), "Action is registered: %s" % action)
	assert_true(app.director.current_module.context.allows_action(action), "Active module accepts %s" % action)
	pressed_actions.append(action)
	Input.action_press(action)
	await _settle()
	Input.action_release(action)
	pressed_actions.erase(action)
	await _settle()
	assert_false(Input.is_action_pressed(action))


func _wait_for_gameplay(condition: Callable, description: String) -> bool:
	var deadline: int = Time.get_ticks_msec() + 8000
	for frame: int in range(2400):
		if condition.call():
			return true
		if Time.get_ticks_msec() >= deadline:
			break
		await get_tree().process_frame
	fail_test("Timed out waiting for %s; current module: %s" % [description, app.director.current_id])
	return false


func _wait_for_module(id: StringName) -> bool:
	return await _wait_for_gameplay(func() -> bool:
		return app.director.current_id == id and not app.director.busy and not app._operation_pending and not app._request_pending and app.director.current_module.context != null and app.director.current_module.context.input_enabled,
		"ready module %s" % id)


func _assert_cycle_identity(profile: Dictionary) -> void:
	assert_eq(app.profile, profile, "Gameplay must not rewrite the selected identity or intro flags")
	assert_eq(app.director.current_module.context.identity_view, {"shape": profile["shape"], "color": profile["color"]})
	assert_eq(app.module_host.get_child_count(), 1)


func test_real_actions_intro_death_and_fresh_shortcut() -> void:
	assert_true(app.test_mode)
	assert_eq(app.save_path, "", "Action persistence stays in memory")
	assert_false(app.profile["intro_seen"])
	assert_false(app.profile["started"])
	var entry: GameModule = app.director.current_module
	assert_eq(entry.save_state()["phase"], "keys")
	var intro_actions: Array[StringName] = [
		&"first_entry_up", &"first_entry_down", &"first_entry_left",
		&"first_entry_right", &"first_entry_confirm", &"first_entry_cancel",
	]
	for index: int in range(intro_actions.size()):
		await _tap_action(intro_actions[index])
		assert_eq(entry.save_state()["keys"].size(), index + 1, "Each real tap absorbs one distinct key")
		assert_false(app.paused, "Intro cancel is absorbed, not routed to the menu")
	if not await _wait_for_gameplay(func() -> bool: return is_instance_valid(entry) and entry.save_state()["phase"] == "editor", "absorption and zoom timers to reach editor"):
		return
	await _settle()
	assert_true(app.profile["intro_seen"], "The real intro timer emits its checkpoint")
	assert_false(app.profile["started"])
	assert_true(app.saves.global_state["profile"]["intro_seen"])
	await _tap_action(&"first_entry_up")
	await _tap_action(&"first_entry_right")
	assert_eq(entry.save_state()["shape"], 2)
	assert_eq(entry.save_state()["color"], 1)
	await _tap_action(&"first_entry_confirm")
	if not await _wait_for_module(&"return_cradle"):
		return
	var identity: Dictionary = {"intro_seen": true, "shape": 2, "color": 1, "started": true}
	_assert_cycle_identity(identity)
	await _tap_action(&"return_cradle_down")
	await _tap_action(&"return_cradle_left")
	assert_eq(app.director.current_module.save_state()["frequency"], 90)
	assert_eq(app.director.current_module.save_state()["berth"], 0)
	await _tap_action(&"return_cradle_confirm")
	if not await _wait_for_module(&"maintenance_cut"):
		return
	_assert_cycle_identity(identity)
	app.director.current_module.load_state({"position": {"x": -1.2, "z": 0.0}})
	await _tap_action(&"maintenance_cut_confirm")
	assert_false(app.director.current_module.save_state().has("inspected"), "Shortcut has no inspection knowledge flag")
	assert_true(app.director.current_module.save_state()["light_on"])
	var corridor: Dictionary = app.director.current_module.save_state()
	corridor["position"] = {"x": 0.0, "z": -4.8}
	app.director.current_module.load_state(corridor)
	await _tap_action(&"maintenance_cut_confirm")
	if not await _wait_for_module(&"last_echo"):
		return
	_assert_cycle_identity(identity)
	assert_eq(app.director.current_module.save_state()["spot"], 0)
	await _tap_action(&"last_echo_right")
	await _tap_action(&"last_echo_confirm")
	assert_eq(app.director.current_module.save_state()["friend_visits"], 1)
	await _tap_action(&"last_echo_right")
	await _tap_action(&"last_echo_confirm")
	await _tap_action(&"last_echo_down")
	await _tap_action(&"last_echo_right")
	assert_eq(app.director.current_module.save_state()["spot"], 4)
	assert_eq(app.director.current_id, &"last_echo", "Walking onto the pit platform does not kill the player")
	await _tap_action(&"last_echo_cancel")
	assert_eq(app.director.current_id, &"last_echo", "Inspecting the pit is safe")
	app.add_note("Keep the shortcut clue after returning", "cycle")
	await _settle()
	var records: Dictionary = app.records_store.call("capture")
	assert_eq(records["entries"].size(), 4, "Corridor, friend, shortcut clue and pit were observed through input")
	var intro_snapshot: Dictionary = app.saves.get_module_state(&"first_entry").duplicate(true)
	assert_false(intro_snapshot.is_empty())
	for id: StringName in app.SET_IDS:
		var state: Dictionary = app.saves.get_module_state(id).get("state", {}).duplicate(true)
		state["session_marker"] = "old_cycle"
		app.saves.set_module_state(id, 1, state)
		assert_eq(app.saves.get_module_state(id)["state"]["session_marker"], "old_cycle")
	var generation: int = app._generation
	await _tap_action(&"last_echo_confirm")
	if not await _wait_for_module(&"return_cradle"):
		return
	assert_eq(app._generation, generation + 1, "One deliberate confirm causes exactly one death transition")
	_assert_cycle_identity(identity)
	for id: StringName in app.SET_IDS:
		assert_true(app.saves.get_module_state(id).is_empty(), "Death removes the entire old session snapshot: %s" % id)
	assert_eq(app.saves.get_module_state(&"first_entry"), intro_snapshot)
	assert_eq(app.director.current_module.save_state(), {"berth": 1, "frequency": 100, "inspections": 0, "friend_visits": 0})
	var after_death: Dictionary = app.records_store.call("capture")
	assert_eq(after_death["entries"], records["entries"])
	assert_eq(after_death["notes"], records["notes"])
	assert_eq(after_death["collected_themes"], records["collected_themes"])
	await _tap_action(&"return_cradle_left")
	await _tap_action(&"return_cradle_confirm")
	assert_eq(app.director.current_id, &"return_cradle", "Old frequency 90 must not reopen the shortcut before retuning")
	assert_eq(app.director.current_module.save_state()["frequency"], 100)
	await _tap_action(&"return_cradle_down")
	await _tap_action(&"return_cradle_confirm")
	if not await _wait_for_module(&"maintenance_cut"):
		return
	_assert_cycle_identity(identity)
	var fresh_shortcut: Dictionary = app.director.current_module.save_state()
	assert_almost_eq(float(fresh_shortcut["position"]["x"]), 0.0, 0.0001)
	assert_almost_eq(float(fresh_shortcut["position"]["z"]), 4.3, 0.0001, "Shortcut starts fresh, not at the old lit exit")
	assert_eq(fresh_shortcut["yaw"], 0.0)
	assert_false(fresh_shortcut["light_on"])
	app.director.current_module.load_state({"position": {"x": 0.0, "z": -4.8}})
	await _tap_action(&"maintenance_cut_confirm")
	if not await _wait_for_module(&"last_echo"):
		return
	_assert_cycle_identity(identity)
	assert_eq(app.director.current_module.save_state(), {"spot": 0, "inspections": 0, "friend_visits": 0})
	var after_shortcut: Dictionary = app.records_store.call("capture")
	assert_eq(after_shortcut["entries"], records["entries"])
	assert_eq(after_shortcut["notes"], records["notes"])
	assert_eq(after_shortcut["collected_themes"], records["collected_themes"])
	for id: StringName in app.SET_IDS:
		assert_false(app.saves.get_module_state(id).get("state", {}).has("session_marker"), "Fresh traversal cannot resurrect old snapshots: %s" % id)
	assert_eq(app.saves.get_module_state(&"first_entry"), intro_snapshot)
	assert_eq(app.save_path, "")
	assert_true(pressed_actions.is_empty())


func test_start_mapping_and_detached_identity() -> void:
	var targets: Array[StringName] = [&"signal_desk", &"relay_quay", &"return_cradle"]
	for shape: int in range(3):
		app.profile = {"intro_seen": true, "shape": 0, "color": 0, "started": false}
		assert_eq(await app._change_module(&"first_entry"), OK)
		await _request(&"start", {"shape": shape, "color": 2})
		assert_eq(app.director.current_id, targets[shape])
		assert_eq(app.profile["shape"], shape)
		assert_eq(app.director.current_module.context.identity_view, {"shape": shape, "color": 2})
		app.director.current_module.context.identity_view["color"] = 99
		assert_eq(app.profile["color"], 2)


func test_routes_are_owned_by_app() -> void:
	app.profile["started"] = true
	for source: String in app.ROUTES:
		for portal: String in app.ROUTES[source]:
			assert_eq(await app._change_module(StringName(source)), OK)
			await _request(&"portal", {"exit": portal})
			assert_eq(app.director.current_id, StringName(app.ROUTES[source][portal]))
			assert_eq(app.module_host.get_child_count(), 1)
	await _request(&"portal", {"exit": "nonexistent"})
	assert_false(app.director.busy)


func test_duplicate_death_clears_session_but_keeps_identity_and_records() -> void:
	app.profile = {"intro_seen": true, "shape": 2, "color": 1, "started": true}
	assert_eq(await app._change_module(&"last_echo"), OK)
	app.records_store.call("observe", &"last_echo", {"id": "kept", "text": "Remembered"})
	await _settle()
	for id: StringName in app.SET_IDS:
		app.saves.set_module_state(id, 1, {"session_marker": 7})
	app.saves.set_module_state(&"first_entry", 1, {"retained": true})
	var generation: int = app._generation
	var dying: GameModule = app.director.current_module
	dying.requested.emit(&"died", {})
	dying.requested.emit(&"died", {})
	assert_eq(app.director.current_id, &"last_echo", "Transition is deferred beyond the sender stack")
	await _settle()
	assert_eq(app.director.current_id, &"return_cradle")
	assert_eq(app._generation, generation + 1)
	for id: StringName in app.SET_IDS:
		assert_false(app.saves.get_module_state(id).get("state", {}).has("session_marker"))
	assert_true(app.saves.get_module_state(&"last_echo").is_empty())
	assert_true(app.saves.get_module_state(&"first_entry")["state"]["retained"])
	assert_eq(app.profile["shape"], 2)
	assert_eq(app.profile["color"], 1)
	assert_eq(app.records_store.call("capture")["entries"][0]["id"], "kept")
	await _request(&"died")
	assert_eq(app._generation, generation + 1)


func test_request_guards_and_stale_deferred_request() -> void:
	assert_eq(await app._change_module(&"signal_desk"), OK)
	var stale := GameModule.new()
	add_child_autofree(stale)
	stale.context = ModuleContext.new()
	stale.context.input_enabled = true
	app.director._on_requested(&"portal", {"exit": "forward"}, stale)
	await _settle()
	assert_eq(app.director.current_id, &"signal_desk")
	app.router.set_locked(true)
	await _request(&"portal", {"exit": "forward"})
	assert_eq(app.director.current_id, &"signal_desk")
	app.router.set_locked(false)
	app.director.current_module.context.input_enabled = false
	await _request(&"portal", {"exit": "forward"})
	assert_eq(app.director.current_id, &"signal_desk")
	app.director.current_module.context.input_enabled = true
	app.director.current_module.requested.emit(&"portal", {"exit": "forward"})
	assert_eq(await app._change_module(&"maintenance_cut"), OK)
	await _settle()
	assert_eq(app.director.current_id, &"maintenance_cut")


func test_arrival_and_request_payload_are_deep_copies() -> void:
	var arrival: Dictionary = {"intro_seen": true, "language": "en", "nested": {"value": 1}}
	var identity: Dictionary = {"shape": 1, "color": 2, "nested": {"value": 3}}
	assert_eq(await app.director.change_module(&"first_entry", false, arrival, identity), OK)
	arrival["nested"]["value"] = 9
	identity["nested"]["value"] = 9
	assert_eq(app.director.current_module.context.arrival["nested"]["value"], 1)
	assert_eq(app.director.current_module.context.identity_view["nested"]["value"], 3)
	assert_eq(await app._change_module(&"signal_desk"), OK)
	var payload: Dictionary = {"id": "copy", "text": "Original"}
	app.director.current_module.requested.emit(&"observation", payload)
	payload["text"] = "Changed"
	await _settle()
	assert_eq(app.records_store.call("capture")["entries"][0]["text"], "Original")


func test_checkpoint_language_and_overlays() -> void:
	await _request(&"checkpoint", {"intro_seen": true})
	assert_true(app.profile["intro_seen"])
	assert_true(app.saves.global_state["profile"]["intro_seen"])
	await _request(&"language")
	assert_eq(app.language, "en")
	assert_eq(app.director.current_module.context.arrival["language"], "en")
	await _request(&"menu")
	assert_true(app.paused)
	assert_true(app.router.locked)
	var records: Dictionary = app.records_store.call("capture")
	app._on_useless_click()
	assert_eq(app.useless_clicks, 1)
	assert_eq(app.records_store.call("capture"), records)
	app.toggle_journal()
	assert_true(app.paused)
	assert_true(app.router.locked)
	app.toggle_journal()
	assert_false(app.paused)
	assert_false(app.router.locked)
	assert_eq(app.save_progress(), ERR_INVALID_PARAMETER)
	assert_eq(app.save_progress("user://save.json"), ERR_INVALID_PARAMETER)


func test_restore_roundtrip_and_legacy_records_retention() -> void:
	app.dev_shell = false
	await _request(&"start", {"shape": 1, "color": 2})
	app.add_note("A note", "tag")
	await _settle()
	var path: String = _path("roundtrip")
	assert_eq(app.save_progress(path), OK)
	assert_eq(await app._change_module(&"last_echo"), OK)
	assert_eq(await app.restore_progress(path), OK)
	assert_eq(app.director.current_id, &"relay_quay")
	assert_eq(int(app.profile["shape"]), 1)
	assert_eq(app.records_store.call("capture")["notes"][0]["text"], "A note")
	var records: Dictionary = app.records_store.call("capture")
	app.saves.global_state.erase("records")
	var legacy: String = _path("legacy")
	assert_eq(app.saves.save_file(legacy), OK)
	assert_eq(await app.restore_progress(legacy), OK)
	assert_eq(app.records_store.call("capture"), records)


func test_failed_restore_is_transactional() -> void:
	await _request(&"start", {"shape": 0, "color": 1})
	app.add_note("Keep", "safe")
	await _settle()
	var valid: String = _path("valid")
	assert_eq(app.save_progress(valid), OK)
	var before: Dictionary = app.saves.export_data()
	var profile: Dictionary = app.profile.duplicate(true)
	var records: Dictionary = app.records_store.call("capture")
	var source: GameModule = app.director.current_module
	var invalid: Dictionary = before.duplicate(true)
	invalid["global"]["records"] = {"broken": true}
	var writer := SaveService.new()
	add_child_autofree(writer)
	assert_eq(writer.import_data(invalid), OK)
	var bad: String = _path("invalid_records")
	assert_eq(writer.save_file(bad), OK)
	assert_eq(await app.restore_progress(bad), ERR_INVALID_DATA)
	assert_eq(app.saves.export_data(), before)
	assert_eq(app.profile, profile)
	assert_eq(app.records_store.call("capture"), records)
	assert_same(app.director.current_module, source)
	invalid = before.duplicate(true)
	invalid["current_module"] = "missing"
	assert_eq(writer.import_data(invalid), OK)
	var missing: String = _path("missing_module")
	assert_eq(writer.save_file(missing), OK)
	assert_eq(await app.restore_progress(missing), ERR_DOES_NOT_EXIST)
	assert_eq(app.saves.export_data(), before)
	assert_same(app.director.current_module, source)


func test_death_failure_rolls_back_snapshots() -> void:
	assert_eq(await app._change_module(&"last_echo"), OK)
	app.saves.set_module_state(&"signal_desk", 1, {"marker": 4})
	var before: Dictionary = app.saves.export_data()
	var manifest: ModuleManifest = app.catalog[app._catalog_index(&"return_cradle")]
	var original: String = manifest.entry_scene
	manifest.entry_scene = "res://missing_death_destination.tscn"
	await _request(&"died")
	manifest.entry_scene = original
	assert_eq(app.director.current_id, &"last_echo")
	assert_eq(app.saves.export_data(), before)
	assert_false(app.director.busy)
	assert_false(app._operation_pending)
