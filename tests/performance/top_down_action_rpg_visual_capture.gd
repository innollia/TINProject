extends SceneTree

const ENTRY_SCENE: String = "res://modules/top_down_action_rpg/entry.tscn"
const MODULE_ID: StringName = &"top_down_action_rpg"
const REPORT_FILE_NAME: String = "top_down_action_rpg_visual_capture_report.json"
const REPORT_SCHEMA: String = "top_down_action_rpg.visual_capture.v1"
const EVIDENCE_CLASS: String = "deterministic_presentation_capture"
const EVIDENCE_VERSION: String = "1"

const SCREEN_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_screen.gd"
const ROW_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_row.gd"
const VECTOR_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_vector_layer.gd"
const SCREEN_SCENE: String = "res://modules/top_down_action_rpg/presentation/top_down_screen.tscn"
const MODULE_SCRIPT: String = "res://modules/top_down_action_rpg/module.gd"

const ENTRY_REGION: String = "region_h0_undersign_exchange"
const ENTRY_ANCHOR: String = "route_e01_ash_stair"
const KILN_REGION: String = "region_r1_returning_kiln"
const H0_RESIDENT: String = "npc_01_ilyra_senn"
const KILN_DOOR_PROP: String = "prop_r1_wrong_return_door"
const DOOR_ENCOUNTER: String = "enc_r1_door_role_test"
const CHOIR_ENCOUNTER: String = "enc_r1_ash_choir"
const PLAYER_ACTION: String = "act_ash_sweep"
const GUARD_ACTION: String = "act_guard_set"
const ITEM_CATEGORY: String = "item"
const ATTACK_CATEGORY: String = "attack"
const NARRATION_LINE: String = "The shadow over the arrival well has no filed owner."
const PLAYER_SIDE: String = "player_side"

const CAPTURE_STATES: Array[StringName] = [
	TopDownActionRpgScreen.STATE_INPUT_BUBBLE,
	TopDownActionRpgScreen.STATE_FIELD,
	TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS,
	TopDownActionRpgScreen.STATE_NARRATION,
	TopDownActionRpgScreen.STATE_COMBAT_COMMAND,
	TopDownActionRpgScreen.STATE_TARGET_SELECT,
	TopDownActionRpgScreen.STATE_CHARGE_COUNTER,
	TopDownActionRpgScreen.STATE_GUARD_DODGE_BREAK,
	TopDownActionRpgScreen.STATE_EQUIPMENT_NO_TURN,
	TopDownActionRpgScreen.STATE_DOCUMENT_MAX,
	TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED,
	TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT,
	TopDownActionRpgScreen.STATE_FAILURE_DEATH,
	TopDownActionRpgScreen.STATE_RECOVERY,
	TopDownActionRpgScreen.STATE_SUCCESS,
	TopDownActionRpgScreen.STATE_ESC_MENU,
]

const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)
]

const REQUIRED_STATES: Array[StringName] = [
	TopDownActionRpgScreen.STATE_INPUT_BUBBLE,
	TopDownActionRpgScreen.STATE_FIELD,
	TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS,
	TopDownActionRpgScreen.STATE_NARRATION,
	TopDownActionRpgScreen.STATE_COMBAT_COMMAND,
	TopDownActionRpgScreen.STATE_TARGET_SELECT,
	TopDownActionRpgScreen.STATE_CHARGE_COUNTER,
	TopDownActionRpgScreen.STATE_GUARD_DODGE_BREAK,
	TopDownActionRpgScreen.STATE_EQUIPMENT_NO_TURN,
	TopDownActionRpgScreen.STATE_DOCUMENT_MAX,
	TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED,
	TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT,
	TopDownActionRpgScreen.STATE_FAILURE_DEATH,
	TopDownActionRpgScreen.STATE_RECOVERY,
	TopDownActionRpgScreen.STATE_SUCCESS,
	TopDownActionRpgScreen.STATE_ESC_MENU,
]

const WORLD_LAYER_NODES: Array[String] = [
	"%FieldLayer", "%CombatLayer", "%FieldLayer/TopologyLayer",
]

const SHELL_HUD_TOKENS: Array[String] = [
	"Menu", "Journal", "HUD", "Hud", "Debug", "Toolbar", "TopBar", "StatusBar",
	"Minimap", "Objective", "Location", "AutoSave", "Breadcrumb", "Compass", "QuestLog",
]

const PLACEHOLDER_TOKENS: Array[String] = [
	"placeholder", "todo", "fixme", "mock", "dummy", "debug_label", "debug_overlay",
	"debug_hud", "at-icons", "res://addons/at-icons", "lorem", "sample_text",
]

const WORLD_STANDIN_TOKENS: Array[String] = ["ColorRect", "COLOR_RED", "draw_rect"]

const AP_TOKENS: Array[String] = [
	"max_ap", "ap_gauge", "ap_label", "action_points", "action points", "stamina", "momentum",
]

const RED_BAR_SOURCES: Array[String] = [VECTOR_SCRIPT, SCREEN_SCRIPT]
const PRESENTATION_SOURCES: Array[String] = [
	SCREEN_SCRIPT, ROW_SCRIPT, VECTOR_SCRIPT, SCREEN_SCENE, MODULE_SCRIPT
]
const WORLD_RED_ALLOWED_SOURCES: Array[String] = [ROW_SCRIPT]
const ROW_EXTREME_PRESENTATION_LABEL: String = "extreme"

const EXPECTED_COMBAT_BAR_CONSTANTS: int = 2
const EXPECTED_COMBAT_BAR_DRAW_SITES: int = 2
const WALK_LIMIT: int = 128
const DIALOGUE_LIMIT: int = 32
const COMBAT_LIMIT: int = 240
const SETTLE_FRAME_COUNT: int = 4

var _output_directory: String = ""
var _requested_states: Array[StringName] = []
var _requested_sizes: Array[Vector2i] = []
var _module: GameModule = null
var _module_context: ModuleContext = null
var _reports: Array[Dictionary] = []
var _violations: Array[Dictionary] = []
var _source_audit: Dictionary = {}
var _static_violations: Array[Dictionary] = []
var _headless: bool = false
var _png_written: int = 0
var _png_refused: int = 0
var _reports_written: Array[String] = []
var _failed: bool = false
var _done: bool = false


func _initialize() -> void:
	var parsed: Dictionary = _parse_arguments(OS.get_cmdline_user_args())
	if not bool(parsed.get("ok", false)):
		push_error(String(parsed.get("message", "invalid command line")))
		quit(2)
		return
	_output_directory = _validate_output_directory(String(parsed.get("output_directory", "")))
	if _output_directory.is_empty():
		return
	_requested_states = parsed.get("states", CAPTURE_STATES) as Array[StringName]
	_requested_sizes = parsed.get("sizes", CAPTURE_SIZES) as Array[Vector2i]
	_headless = DisplayServer.get_name() == "headless"
	call_deferred("_run")


func _run() -> void:
	var error: Error = DirAccess.make_dir_recursive_absolute(_output_directory)
	if error != OK:
		_fail("could not create output directory: %s" % _output_directory)
		return
	if not DirAccess.dir_exists_absolute(_output_directory):
		_fail("output directory was not created: %s" % _output_directory)
		return
	_audit_static_sources()
	for requested_size: Vector2i in _requested_sizes:
		await _apply_resolution(requested_size)
		for state_name: StringName in _requested_states:
			if not await _prepare(state_name):
				return
			var report: Dictionary = _collect(state_name, requested_size)
			_reports.append(report)
			if not _record_violations(state_name, requested_size, report):
				return
			if not await _capture(state_name, requested_size, report):
				return
			await _teardown()
	await _write_report()
	_finish()


func _apply_resolution(requested_size: Vector2i) -> void:
	if not _headless:
		DisplayServer.window_set_size(requested_size)
	root.size = requested_size
	for _frame: int in range(SETTLE_FRAME_COUNT):
		await process_frame
		await RenderingServer.frame_post_draw


func _prepare(state_name: StringName) -> bool:
	if not await _spawn(_snapshot_for(state_name), state_name):
		return false
	var screen: TopDownActionRpgScreen = _screen_of()
	if screen == null:
		return _fail("no screen bound for state %s" % String(state_name))
	match state_name:
		TopDownActionRpgScreen.STATE_FIELD:
			pass
		TopDownActionRpgScreen.STATE_INPUT_BUBBLE:
			screen.set_input_bubble_active(true)
			screen.refresh()
		TopDownActionRpgScreen.STATE_ESC_MENU:
			screen.set_shell_open(true)
			screen.refresh()
		TopDownActionRpgScreen.STATE_NARRATION:
			screen.set_narration_lines(PackedStringArray([NARRATION_LINE]))
			screen.refresh()
		TopDownActionRpgScreen.STATE_RECOVERY:
			screen.set_recovery_surface(true)
			screen.refresh()
		TopDownActionRpgScreen.STATE_SUCCESS:
			screen.set_success_active(true)
			screen.refresh()
		TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS:
			if not _walk_to(H0_RESIDENT):
				return _fail("could not reach %s" % H0_RESIDENT)
			_module.execute_command(&"interact", {"interactable_id": H0_RESIDENT})
			if not _advance_to_choice_set():
				return _fail("dialogue choice set was not reached")
		TopDownActionRpgScreen.STATE_DOCUMENT_MAX:
			if not _walk_to(KILN_DOOR_PROP):
				return _fail("could not reach %s" % KILN_DOOR_PROP)
			_module.execute_command(&"interact", {"interactable_id": KILN_DOOR_PROP})
			if _mode() != "dialogue" or String(_conversation_of().document_id).is_empty():
				return _fail("authored document did not open for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED:
			if not _walk_to(KILN_DOOR_PROP):
				return _fail("could not reach %s" % KILN_DOOR_PROP)
			_module.execute_command(&"interact", {"interactable_id": KILN_DOOR_PROP})
			_module.execute_command(&"document_advance")
			if String(_conversation_of().document_id).is_empty():
				return _fail("authored corruption page was not reached")
		TopDownActionRpgScreen.STATE_COMBAT_COMMAND:
			if _mode() != "combat":
				return _fail("combat was not entered for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_TARGET_SELECT:
			_module.execute_command(&"combat_category", {"category": ATTACK_CATEGORY})
			_module.execute_command(&"combat_action", {"action_id": PLAYER_ACTION})
			if _combat_of() == null or String(_combat_of().submode) != "target_select":
				return _fail("target select was not entered for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_EQUIPMENT_NO_TURN:
			_module.execute_command(&"combat_category", {"category": ITEM_CATEGORY})
			screen.refresh()
		TopDownActionRpgScreen.STATE_GUARD_DODGE_BREAK:
			_module.execute_command(&"combat_action", {"action_id": GUARD_ACTION})
			if not _stance_is_not_normal():
				return _fail("counter feedback state was not produced for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_CHARGE_COUNTER:
			if not _drive_to_charge_counter():
				return _fail("authored charge counter was not produced for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT:
			if not _finish_encounter("victory"):
				return _fail("victory aftermath was not produced for %s" % String(state_name))
		TopDownActionRpgScreen.STATE_FAILURE_DEATH:
			if not _finish_encounter("defeat"):
				return _fail("failure state was not produced for %s" % String(state_name))
		_:
			return _fail("no deterministic fixture for state %s" % String(state_name))
	var observed: StringName = screen.current_state()
	if observed != state_name:
		return _fail("fixture for %s reached %s" % [String(state_name), String(observed)])
	print("TOPDOWN_CAPTURE_STATE state=%s reached=%s mode=%s" % [
		String(state_name), String(observed), _mode()
	])
	return true


func _snapshot_for(state_name: StringName) -> Dictionary:
	match state_name:
		TopDownActionRpgScreen.STATE_INPUT_BUBBLE, TopDownActionRpgScreen.STATE_FIELD, \
		TopDownActionRpgScreen.STATE_ESC_MENU, TopDownActionRpgScreen.STATE_NARRATION, \
		TopDownActionRpgScreen.STATE_RECOVERY, TopDownActionRpgScreen.STATE_SUCCESS, \
		TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS:
			return {}
		TopDownActionRpgScreen.STATE_DOCUMENT_MAX, TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED:
			return _kiln_document_snapshot()
	return _combat_snapshot()


func _kiln_document_snapshot() -> Dictionary:
	var snapshot: Dictionary = TopDownActionRpgGameState.create_default(ENTRY_REGION, ENTRY_ANCHOR).to_dict()
	snapshot["content_revision"] = "visual_capture_authored_document_fixture"
	_install_kiln(snapshot)
	var world: Dictionary = snapshot["world"]
	world["encounters"] = {DOOR_ENCOUNTER: {"resolution": "victory"}}
	return snapshot


func _combat_snapshot() -> Dictionary:
	var snapshot: Dictionary = TopDownActionRpgGameState.create_default(ENTRY_REGION, ENTRY_ANCHOR).to_dict()
	snapshot["content_revision"] = "visual_capture_authored_encounter_fixture"
	var body: Dictionary = snapshot["player"]["body"] if snapshot["player"]["body"] is Dictionary else {}
	body["vitals"] = {"hp": 220, "max_hp": 220, "mp": 40, "max_mp": 40}
	snapshot["player"]["body"] = body
	_install_kiln(snapshot)
	var combat: Dictionary = snapshot["combat"]
	combat["active_encounter_id"] = CHOIR_ENCOUNTER
	combat["attempt_serial"] = 1
	combat["resume_boundary"] = "encounter_prepare"
	combat["result"] = "running"
	combat["pre_command_intent"] = []
	return snapshot


func _install_kiln(snapshot: Dictionary) -> void:
	var field: Dictionary = snapshot["field"]
	field["region_id"] = KILN_REGION
	field["scene_id"] = KILN_REGION
	field["active_interaction_id"] = ""
	var world: Dictionary = snapshot["world"]
	var regions: Dictionary = world["regions"]
	regions[KILN_REGION] = {
		"visit_count": 0, "state": "as_authored", "state_tag": "", "scene_id": KILN_REGION
	}
	var region_clocks: Dictionary = {}
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		region_clocks[clock_id] = {"stage_index": 0, "tick": 0, "last_signal": "", "committed_event_id": ""}
	world["clocks"][KILN_REGION] = region_clocks


func _spawn(snapshot: Dictionary, state_name: StringName) -> bool:
	var packed: PackedScene = load(ENTRY_SCENE) as PackedScene
	if packed == null:
		return _fail("entry scene did not load for %s" % String(state_name))
	_module = packed.instantiate() as GameModule
	if _module == null:
		return _fail("entry scene did not instantiate a module for %s" % String(state_name))
	_module_context = ModuleContext.new()
	_module_context.module_id = MODULE_ID
	_module_context.input_enabled = true
	for action: StringName in _declared_actions():
		_module_context.allowed_actions.append(action)
	_module.context = _module_context
	root.add_child(_module)
	if not snapshot.is_empty():
		_module.load_state(snapshot.duplicate(true))
	_module.enter(_module_context)
	_module.set_process(false)
	await process_frame
	return _state_of() != null and _screen_of() != null


func _teardown() -> void:
	if _module == null:
		return
	_module.set_process(true)
	_module.exit()
	root.remove_child(_module)
	_module.free()
	_module = null
	_module_context = null
	await process_frame


func _collect(state_name: StringName, requested_size: Vector2i) -> Dictionary:
	var screen: TopDownActionRpgScreen = _screen_of()
	var missing_art: Array[String] = []
	for key: Variant in screen.missing_art_keys:
		missing_art.append(String(key))
	missing_art.sort()
	var shell_nodes: Array[String] = []
	var standins: Array[String] = []
	var visited: Array[Node] = []
	_collect_nodes(screen, visited)
	for node: Node in visited:
		for token: String in SHELL_HUD_TOKENS:
			if String(node.name).contains(token):
				shell_nodes.append("%s/%s" % [node.name, token])
	for node: Node in visited:
		if not String(node.name).begins_with("%"):
			continue
		var unique_path: String = String(node.get_path()).get_file()
		if not WORLD_LAYER_NODES.has(unique_path):
			continue
		if node is ColorRect or node is Label:
			standins.append(unique_path)
	var ap_labels: Array[String] = []
	for node: Node in visited:
		if node is Label:
			var text: String = String((node as Label).text)
			if text.begins_with("AP") or text.contains(" AP") or text.to_lower().contains("action point"):
				ap_labels.append(String(node.name))
	return {
		"state": String(state_name),
		"requested_size": [requested_size.x, requested_size.y],
		"root_size": [root.size.x, root.size.y],
		"mode": _mode(),
		"region_id": _state_of().region_id() if _state_of() != null else "",
		"encounter_id": String(_combat_of().encounter_id) if _combat_of() != null else "",
		"document_id": String(_conversation_of().document_id) if _conversation_of() != null else "",
		"conversation_id": String(_conversation_of().conversation_id) if _conversation_of() != null else "",
		"missing_art_keys": missing_art,
		"world_layer_standins": standins,
		"shell_hud_nodes": shell_nodes,
		"ap_labels": ap_labels,
	}


func _record_violations(state_name: StringName, requested_size: Vector2i, report: Dictionary) -> bool:
	var label: String = "%s@%dx%d" % [String(state_name), requested_size.x, requested_size.y]
	var missing_art: Array = report.get("missing_art_keys", []) if report.get("missing_art_keys", []) is Array else []
	if not missing_art.is_empty():
		_violations.append({
			"kind": "missing_art_key",
			"target": label,
			"detail": missing_art,
			"severity": "blocking",
		})
	var standins: Array = report.get("world_layer_standins", []) if report.get("world_layer_standins", []) is Array else []
	if not standins.is_empty():
		_violations.append({"kind": "world_placeholder_standin", "target": label, "detail": standins, "severity": "blocking"})
	var shell_nodes: Array = report.get("shell_hud_nodes", []) if report.get("shell_hud_nodes", []) is Array else []
	if not shell_nodes.is_empty():
		_violations.append({"kind": "persistent_shell_hud", "target": label, "detail": shell_nodes, "severity": "blocking"})
	var ap_labels: Array = report.get("ap_labels", []) if report.get("ap_labels", []) is Array else []
	if not ap_labels.is_empty():
		_violations.append({"kind": "ap_label", "target": label, "detail": ap_labels, "severity": "blocking"})
	var root_size: Array = report.get("root_size", []) if report.get("root_size", []) is Array else []
	if not _headless and (root_size.size() != 2 or int(root_size[0]) != requested_size.x or int(root_size[1]) != requested_size.y):
		_violations.append({
			"kind": "viewport_size_mismatch",
			"target": label,
			"detail": {"requested": [requested_size.x, requested_size.y], "actual": root_size},
			"severity": "blocking",
		})
	return true


func _capture(state_name: StringName, requested_size: Vector2i, report: Dictionary) -> bool:
	await _settle()
	var filename: String = "%s_%dx%d.png" % [String(state_name), requested_size.x, requested_size.y]
	var path: String = _output_directory.path_join(filename)
	if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
		_png_refused += 1
		return _fail("refusing to overwrite capture path: %s" % path)
	if _headless:
		report["png_path"] = ""
		report["pixel_evidence"] = false
		report["png_skip_reason"] = "headless_display_server_produces_no_frame_pixels"
		print("TOPDOWN_CAPTURE_SKIP state=%s size=%dx%d reason=headless" % [
			String(state_name), requested_size.x, requested_size.y
		])
		return true
	var image: Image = root.get_texture().get_image()
	if image == null:
		return _fail("no frame image available for %s" % String(state_name))
	var actual: Vector2i = Vector2i(image.get_width(), image.get_height())
	report["image_size"] = [actual.x, actual.y]
	report["pixel_evidence"] = true
	report["png_skip_reason"] = ""
	if actual != requested_size:
		return _fail("capture dimensions do not match request for %s: %dx%d" % [String(state_name), actual.x, actual.y])
	var error: Error = image.save_png(path)
	if error != OK:
		return _fail("could not save capture %s: %s" % [path, error_string(error)])
	_png_written += 1
	report["png_path"] = path
	report["png_sha256"] = FileAccess.get_sha256(path)
	print("TOPDOWN_CAPTURE_WROTE state=%s size=%dx%d path=%s" % [
		String(state_name), requested_size.x, requested_size.y, path
	])
	return true


func _settle() -> void:
	for _frame: int in range(SETTLE_FRAME_COUNT):
		await process_frame
		await RenderingServer.frame_post_draw


func _drive_to_charge_counter() -> bool:
	for _step: int in range(COMBAT_LIMIT):
		var controller: TopDownActionRpgCombatController = _controller_of()
		var combat: TopDownActionRpgCombatState = _combat_of()
		if controller == null or combat == null:
			return false
		if String(combat.result) != "running":
			return false
		if controller.awaiting_reaction and controller.pending_charge != null:
			var owner_actor: TopDownActionRpgCombatState.ActorState = combat.find_actor(controller.pending_charge.owner_actor_id)
			if owner_actor != null and owner_actor.charge_state != null and owner_actor.charge_state.is_active():
				return true
			return false
		if _player_window_open():
			_module.execute_command(&"combat_action", {"action_id": PLAYER_ACTION})
			if combat.submode == "target_select":
				_module.execute_command(&"combat_target", {"target_actor_id": _focused_target_or_first()})
		_module.call("_process", 0.0)
	return false


func _finish_encounter(result: String) -> bool:
	var controller: TopDownActionRpgCombatController = _controller_of()
	var combat: TopDownActionRpgCombatState = _combat_of()
	if controller == null or combat == null:
		return false
	if not controller.force_result(result):
		return false
	_module.call("_process", 0.0)
	return true


func _focused_target_or_first() -> String:
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller != null and not String(controller.target_focus_actor_id).is_empty():
		return String(controller.target_focus_actor_id)
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null:
		return ""
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if actor.side != PLAYER_SIDE:
			return String(actor.actor_id)
	return ""


func _stance_is_not_normal() -> bool:
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null:
		return false
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if String(actor.stance_state) != "normal":
			return true
	return false


func _advance_to_choice_set() -> bool:
	for _page: int in range(DIALOGUE_LIMIT):
		var conversation: TopDownActionRpgConversationController = _conversation_of()
		if conversation == null:
			return false
		if conversation.at_choice_set():
			return true
		if _mode() != "dialogue":
			return false
		if not _module.execute_command(&"dialogue_advance"):
			return false
	return false


func _walk_to(interactable_id: String) -> bool:
	var field: TopDownActionRpgFieldController = _field_of()
	if field == null:
		return false
	var target: TopDownActionRpgFieldController.Interactable = null
	for entry: TopDownActionRpgFieldController.Interactable in field.interactables:
		if String(entry.interactable_id) == interactable_id:
			target = entry
			break
	if target == null:
		return false
	for _step: int in range(WALK_LIMIT):
		if _actor_position().distance_to(target.position) <= 0.2:
			return true
		_module.execute_command(&"move", {"direction": target.position - _actor_position()})
		if _mode() != "field" and _mode() != "field_return":
			return false
	return _actor_position().distance_to(target.position) <= 0.6


func _audit_static_sources() -> void:
	var text_by_path: Dictionary = {}
	for path: String in PRESENTATION_SOURCES:
		text_by_path[path] = _read_text(path)
	_source_audit["sources_scanned"] = PRESENTATION_SOURCES.duplicate()
	var placeholder_hits: Array[Dictionary] = []
	var ap_hits: Array[Dictionary] = []
	var standin_hits: Array[Dictionary] = []
	var red_hits: Array[Dictionary] = []
	for path: String in PRESENTATION_SOURCES:
		var text: String = String(text_by_path[path])
		if text.is_empty():
			_static_violations.append({"kind": "unreadable_presentation_source", "target": path})
			continue
		for token: String in PLACEHOLDER_TOKENS:
			if _contains_token(text, token):
				placeholder_hits.append({"target": path, "token": token})
		for token: String in AP_TOKENS:
			if _contains_token(text, token):
				ap_hits.append({"target": path, "token": token})
		if RegEx.create_from_string("\\bAP\\b").search_all(text).size() > 0:
			ap_hits.append({"target": path, "token": "word_ap"})
		if path == SCREEN_SCRIPT:
			for token: String in WORLD_STANDIN_TOKENS:
				if _contains_token(text, token):
					standin_hits.append({"target": path, "token": token})
		if RED_BAR_SOURCES.has(path):
			var red_count: int = _red_color_count(text)
			if red_count > 0:
				red_hits.append({"target": path, "red_color_literals": red_count})
	var row_text: String = String(text_by_path.get(ROW_SCRIPT, ""))
	var row_red: int = _red_color_count(row_text)
	if row_red > 0 and not _declares_extreme_class(row_text):
		red_hits.append({"target": ROW_SCRIPT, "unlabelled_red_color_literals": row_red})
	var vector_text: String = String(text_by_path.get(VECTOR_SCRIPT, ""))
	var bar_constants: int = RegEx.create_from_string("const\\s+[A-Z_]*BAR[A-Z_]*\\s*:\\s*Rect2").search_all(vector_text).size()
	var bar_sites: int = vector_text.count("_base_rect_to_local(TIMING_BAR)") + vector_text.count("_base_rect_to_local(CONDITION_BAR)")
	_source_audit["combat_bar_constants"] = bar_constants
	_source_audit["combat_bar_draw_sites"] = bar_sites
	_source_audit["red_color_literals"] = red_hits
	_source_audit["extreme_class_declared"] = _declares_extreme_class(row_text)
	_source_audit["placeholder_tokens"] = placeholder_hits
	_source_audit["ap_tokens"] = ap_hits
	_source_audit["world_standin_tokens"] = standin_hits
	if not placeholder_hits.is_empty():
		_static_violations.append({"kind": "placeholder_token", "target": "presentation_sources", "detail": placeholder_hits})
	if not ap_hits.is_empty():
		_static_violations.append({"kind": "ap_token", "target": "presentation_sources", "detail": ap_hits})
	if not standin_hits.is_empty():
		_static_violations.append({"kind": "world_standin_token", "target": SCREEN_SCRIPT, "detail": standin_hits})
	if not red_hits.is_empty():
		_static_violations.append({"kind": "red_bar_colour", "target": "combat_bar_sources", "detail": red_hits})
	if bar_constants != EXPECTED_COMBAT_BAR_CONSTANTS or bar_sites != EXPECTED_COMBAT_BAR_DRAW_SITES:
		_static_violations.append({
			"kind": "combat_bar_count",
			"target": VECTOR_SCRIPT,
			"detail": {"constants": bar_constants, "draw_sites": bar_sites},
		})
	print("TOPDOWN_CAPTURE_SOURCE placeholder=%d ap=%d standin=%d red=%d bars=%d/%d" % [
		placeholder_hits.size(), ap_hits.size(), standin_hits.size(), red_hits.size(), bar_constants, bar_sites
	])


func _declares_extreme_class(text: String) -> bool:
	return text.contains(ROW_EXTREME_PRESENTATION_LABEL) and text.contains("EXTREME")


func _contains_token(text: String, token: String) -> bool:
	return text.to_lower().contains(token.to_lower())


func _red_color_count(text: String) -> int:
	var found: int = 0
	var hex_pattern: RegEx = RegEx.create_from_string("Color\\(\"([0-9a-fA-F]{6})\"\\)")
	for match: RegExMatch in hex_pattern.search_all(text):
		var packed: Color = Color(match.get_string(1))
		if _is_red(packed):
			found += 1
	var float_pattern: RegEx = RegEx.create_from_string("Color\\(\\s*([01](?:\\.[0-9]+)?)\\s*,\\s*([01](?:\\.[0-9]+)?)\\s*,\\s*([01](?:\\.[0-9]+)?)")
	for match: RegExMatch in float_pattern.search_all(text):
		var red: float = float(match.get_string(1))
		var green: float = float(match.get_string(2))
		var blue: float = float(match.get_string(3))
		if red > 0.5 and red - green > 0.15 and red - blue > 0.15:
			found += 1
	return found


func _is_red(colour: Color) -> bool:
	return colour.r > 0.5 and colour.r - colour.g > 0.15 and colour.r - colour.b > 0.15


func _write_report() -> bool:
	var path: String = _output_directory.path_join(REPORT_FILE_NAME)
	if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
		return _fail("refusing to overwrite report path: %s" % path)
	var requested: Array[String] = []
	for state_name: StringName in _requested_states:
		requested.append(String(state_name))
	var sizes: Array[Array] = []
	for requested_size: Vector2i in _requested_sizes:
		sizes.append([requested_size.x, requested_size.y])
	var missing_states: Array[String] = []
	for state_name: StringName in REQUIRED_STATES:
		if not _requested_states.has(state_name):
			missing_states.append(String(state_name))
	var reached: Dictionary = {}
	for report: Dictionary in _reports:
		reached[String(report.get("state", ""))] = true
	var missing_art_union: Array[String] = []
	for report: Dictionary in _reports:
		for key: Variant in (report.get("missing_art_keys", []) as Array):
			var value: String = String(key)
			if not missing_art_union.has(value):
				missing_art_union.append(value)
	missing_art_union.sort()
	var payload: Dictionary = {
		"schema": REPORT_SCHEMA,
		"module_id": String(MODULE_ID),
		"evidence_class": EVIDENCE_CLASS,
		"evidence_version": EVIDENCE_VERSION,
		"godot_version": Engine.get_version_info().get("string", ""),
		"rendering_method": ProjectSettings.get_setting("rendering/renderer/rendering_method", ""),
		"display_server": DisplayServer.get_name(),
		"headless": _headless,
		"pixel_evidence_produced": _png_written > 0,
		"human_playthrough_claimed": false,
		"requested_states": requested,
		"requested_sizes": sizes,
		"expected_capture_count": _requested_states.size() * _requested_sizes.size(),
		"png_written": _png_written,
		"png_refused_overwrite": _png_refused,
		"states_reached": _sorted_keys(reached),
		"states_missing_from_request": missing_states,
		"missing_art_keys": missing_art_union,
		"source_audit": _source_audit,
		"static_violations": _static_violations,
		"runtime_violations": _violations,
		"captures": _reports,
		"limitations": [
			"headless runs verify state reachability, resolution request and source audits only",
			"no pixel evidence is produced or claimed when the display server is headless",
			"a real human review pass at 720p, FHD and QHD is still required by the kit acceptance gate",
		],
	}
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _fail("could not open report path: %s" % path)
	file.store_string(JSON.stringify(payload, "  ", true))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return _fail("could not write report: %s" % error_string(error))
	_reports_written.append(path)
	print("TOPDOWN_CAPTURE_REPORT path=%s captures=%d png=%d static_violations=%d runtime_violations=%d" % [
		path, _reports.size(), _png_written, _static_violations.size(), _violations.size()
	])
	return true


func _finish() -> void:
	if _done:
		return
	_done = true
	if _module != null:
		_module.set_process(true)
		_module.exit()
		root.remove_child(_module)
		_module.free()
		_module = null
	var missing_states: Array[String] = []
	for state_name: StringName in REQUIRED_STATES:
		var found: bool = false
		for report: Dictionary in _reports:
			if String(report.get("state", "")) == String(state_name):
				found = true
				break
		if not found:
			missing_states.append(String(state_name))
	if not missing_states.is_empty():
		_failed = true
		printerr("TOPDOWN_CAPTURE_MISSING_STATES " + ", ".join(missing_states))
	if not _static_violations.is_empty():
		_failed = true
	if not _violations.is_empty():
		_failed = true
	if not _reports_written.is_empty() and _failed:
		printerr("TOPDOWN_CAPTURE_VIOLATIONS_BLOCKING")
		quit(1)
		return
	quit(1 if _failed else 0)


func _fail(message: String) -> bool:
	_failed = true
	printerr("TOPDOWN_CAPTURE_FAILED " + message)
	_finish()
	return false


func _declared_actions() -> Array[StringName]:
	var result: Array[StringName] = []
	var manifest: ModuleManifest = load("res://modules/top_down_action_rpg/module_manifest.tres") as ModuleManifest
	if manifest == null:
		return result
	for action: String in manifest.input_actions:
		result.append(StringName(action))
	return result


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _collect_nodes(current: Node, out: Array[Node]) -> void:
	out.append(current)
	for child: Node in current.get_children():
		_collect_nodes(child, out)


func _sorted_keys(source: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in source:
		keys.append(String(key))
	keys.sort()
	return keys


func _state_of() -> TopDownActionRpgGameState:
	if _module == null:
		return null
	return _module.get("_game_state") as TopDownActionRpgGameState


func _field_of() -> TopDownActionRpgFieldController:
	if _module == null:
		return null
	return _module.get("_field") as TopDownActionRpgFieldController


func _conversation_of() -> TopDownActionRpgConversationController:
	if _module == null:
		return null
	return _module.get("_conversation") as TopDownActionRpgConversationController


func _combat_of() -> TopDownActionRpgCombatState:
	if _module == null:
		return null
	return _module.get("_combat") as TopDownActionRpgCombatState


func _controller_of() -> TopDownActionRpgCombatController:
	if _module == null:
		return null
	return _module.get("_combat_controller") as TopDownActionRpgCombatController


func _screen_of() -> TopDownActionRpgScreen:
	if _module == null:
		return null
	return _module.get_node_or_null("TopDownScreen") as TopDownActionRpgScreen


func _mode() -> String:
	var state: TopDownActionRpgGameState = _state_of()
	return String(state.mode) if state != null else ""


func _actor_position() -> Vector2:
	var state: TopDownActionRpgGameState = _state_of()
	if state == null:
		return Vector2.ZERO
	var actor: Dictionary = state.field.get("actor", {}) if state.field.get("actor", {}) is Dictionary else {}
	return Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0)))


func _player_window_open() -> bool:
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller == null or controller.state == null:
		return false
	if String(controller.current_actor_id) != TopDownActionRpgGameState.PLAYER_ROLE_ID:
		return false
	return ["command_category", "command_action", "target_select", "resolution_feedback"].has(String(controller.state.submode))


func _parse_arguments(args: PackedStringArray) -> Dictionary:
	var directory: String = ""
	var states: Array[StringName] = []
	var sizes: Array[Vector2i] = []
	var index: int = 0
	while index < args.size():
		var token: String = args[index]
		if token == "--output-dir" and index + 1 < args.size():
			directory = String(args[index + 1])
			index += 2
			continue
		if token.begins_with("--output-dir="):
			directory = token.trim_prefix("--output-dir=")
			index += 1
			continue
		if token == "--states" and index + 1 < args.size():
			states = _parse_states(String(args[index + 1]))
			index += 2
			continue
		if token == "--resolutions" and index + 1 < args.size():
			sizes = _parse_sizes(String(args[index + 1]))
			index += 2
			continue
		return {"ok": false, "message": "unrecognised argument: " + token}
	if directory.strip_edges().is_empty():
		return {"ok": false, "message": "usage: --output-dir <absolute directory outside the workspace> [--states a,b] [--resolutions 1280x720,...]"}
	var resolved: Dictionary = {
		"ok": true,
		"output_directory": directory.strip_edges(),
		"states": states if not states.is_empty() else CAPTURE_STATES,
		"sizes": sizes if not sizes.is_empty() else CAPTURE_SIZES,
	}
	return resolved


func _parse_states(raw: String) -> Array[StringName]:
	var result: Array[StringName] = []
	for token: String in raw.split(",", false):
		var value: String = token.strip_edges()
		if value.is_empty():
			continue
		var resolved: StringName = &""
		for candidate: StringName in CAPTURE_STATES:
			if String(candidate) == value:
				resolved = candidate
				break
		if resolved.is_empty():
			push_error("unknown capture state: " + value)
			continue
		if not result.has(resolved):
			result.append(resolved)
	return result


func _parse_sizes(raw: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for token: String in raw.split(",", false):
		var parts: PackedStringArray = String(token.strip_edges()).to_lower().split("x")
		if parts.size() != 2:
			push_error("unparsable capture size: " + token)
			continue
		var value := Vector2i(int(parts[0]), int(parts[1]))
		if value.x <= 0 or value.y <= 0:
			push_error("non positive capture size: " + token)
			continue
		if not result.has(value):
			result.append(value)
	return result


func _validate_output_directory(value: String) -> String:
	if not value.is_absolute_path():
		push_error("--output-dir must be an absolute path: " + value)
		return ""
	var output_path: String = value.replace("\\", "/").simplify_path().trim_suffix("/")
	var workspace_path: String = ProjectSettings.globalize_path("res://").replace("\\", "/").simplify_path().trim_suffix("/")
	if _path_is_within(output_path, workspace_path):
		push_error("refusing output directory inside workspace: " + output_path)
		return ""
	var temp_path: String = OS.get_temp_dir().replace("\\", "/").simplify_path().trim_suffix("/")
	if not _path_is_within(output_path, temp_path):
		push_error("refusing output directory outside the system temp directory: " + output_path)
		return ""
	if FileAccess.file_exists(output_path) or DirAccess.dir_exists_absolute(output_path):
		push_error("refusing existing output path: " + output_path)
		return ""
	if _path_contains_link(output_path):
		push_error("refusing output path containing a link: " + output_path)
		return ""
	return output_path


func _path_is_within(path: String, root: String) -> bool:
	var normalized_path: String = path.trim_suffix("/")
	var normalized_root: String = root.trim_suffix("/")
	if OS.get_name() == "Windows":
		normalized_path = normalized_path.to_lower()
		normalized_root = normalized_root.to_lower()
	return normalized_path == normalized_root or normalized_path.begins_with(normalized_root + "/")


func _path_contains_link(path: String) -> bool:
	var current: String = path
	while not current.is_empty():
		var parent_path: String = current.get_base_dir()
		if parent_path.is_empty() or parent_path == current:
			break
		var parent: DirAccess = DirAccess.open(parent_path)
		if parent == null:
			break
		if parent.is_link(current):
			return true
		current = parent_path
	return false
