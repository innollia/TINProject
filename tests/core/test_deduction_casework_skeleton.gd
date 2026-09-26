extends GutTest

const MODULE_ID: StringName = &"deduction_casework"
const LEGACY_MODULE_ID: StringName = &"dedution_casework"
const MODULE_DIRECTORY: String = "res://modules/deduction_casework"
const ENTRY_SCENE: String = "res://modules/deduction_casework/entry.tscn"
const CONTENT_DIRECTORY: String = "res://modules/deduction_casework/content"
const INDEX_PATH: String = "res://modules/deduction_casework/content/index.json"
const CASES_DIRECTORY: String = "cases"
const GENERIC_SCENE: String = "res://modules/deduction_casework/presentation/authored_case_scene.tscn"
const START_SCENE_ID: String = "scene_lab"
const START_FOCUS_ID: String = "hotspot_lab_bench"
const MAIN_PANEL_ID: String = "panel_main_statement"
const MAIN_SOLUTION_ID: String = "solution_main_statement"
const REVIEW_ID: String = "review_main"
const FOUNDATION_UNAVAILABLE_TEXT: String = "AUTHORED CASE CONTENT IS NOT AVAILABLE."
const DeductionCaseworkCaseState = preload("res://modules/deduction_casework/domain/case_state.gd")
const CASE_ID: StringName = &"case_01_saint_orin"
const CASE_PATH: String = "res://modules/deduction_casework/content/cases/case_01_saint_orin.json"
const SECOND_CASE_ID: StringName = &"case_02_morren_empty_chair"
const FINAL_CASE_ID: StringName = &"case_12_missing_axiom"
const GATE_CASE_ID: StringName = &"case_11_tarr_shore_cave"
const CASE_IDS: Array[StringName] = [
	&"case_01_saint_orin",
	&"case_02_morren_empty_chair",
	&"case_03_n153_last_tour",
	&"case_04_bellma_exchange_247",
	&"case_05_lake_express",
	&"case_06_haywolsa",
	&"case_07_karmin_dock",
	&"case_08_hart_observatory",
	&"case_09_mara_darkroom",
	&"case_10_forte_terminal",
	&"case_11_tarr_shore_cave",
	&"case_12_missing_axiom"
]
const EXPECTED_ACTIONS: Array[String] = [
	"deduction_casework_left",
	"deduction_casework_right",
	"deduction_casework_up",
	"deduction_casework_down",
	"deduction_casework_confirm",
	"deduction_casework_cancel"
]
const SAVE_KEYS: Array[String] = [
	"schema_version",
	"active_case_id",
	"last_case_id",
	"case_progress_by_id",
	"route_state"
]
const TRANSIENT_KEYS: Array[String] = [
	"focus_id",
	"hover_id",
	"dragged_entity_id",
	"animation_progress"
]

var _owned_actions: Array[StringName] = []

func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		InputMap.erase_action(action)
	_owned_actions.clear()

func test_manifest_declares_only_the_corrected_canonical_contract() -> void:
	var manifest := load(MODULE_DIRECTORY.path_join("module_manifest.tres")) as ModuleManifest
	assert_not_null(manifest)
	if manifest == null:
		return
	assert_eq(manifest.id, MODULE_ID)
	assert_ne(manifest.id, LEGACY_MODULE_ID)
	assert_eq(manifest.entry_scene, ENTRY_SCENE)
	assert_eq(manifest.save_version, 1)
	assert_true(FileAccess.file_exists(manifest.entry_scene))
	var actions: Array[String] = []
	for action: Variant in manifest.input_actions:
		actions.append(String(action))
	assert_eq(actions, EXPECTED_ACTIONS)


func test_catalog_registers_the_authored_12_case_chain_in_order() -> void:
	assert_eq(DeductionContentLoader.CONTENT_DIRECTORY, CONTENT_DIRECTORY)
	assert_eq(DeductionContentLoader.INDEX_PATH, INDEX_PATH)
	var catalog: DeductionContentLoader.CaseCatalog = DeductionContentLoader.load_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.size(), 12)
	assert_eq(catalog.size(), CASE_IDS.size())
	assert_eq(catalog.unavailable_case_ids.size(), 0)
	assert_true(catalog.unavailable_case_ids.is_empty())
	assert_eq(catalog.list_case_ids(), CASE_IDS)
	assert_eq(catalog.to_dict(), {"available": _strings(CASE_IDS), "unavailable": []})
	for index: int in range(CASE_IDS.size()):
		var case_id := CASE_IDS[index]
		var ordinal := "%02d" % (index + 1)
		assert_true(String(case_id).begins_with("case_%s_" % ordinal), "%s keeps the 01..12 order" % case_id)
		assert_true(catalog.has_case(case_id), "%s is available" % case_id)
		assert_true(DeductionContentLoader.validate_case(case_id), "%s validates" % case_id)
		var definition := DeductionContentLoader.load_case(case_id)
		assert_not_null(definition)
		if definition == null:
			continue
		assert_eq(definition.id, DeductionContentLoader.get_definition(case_id).id)
		assert_eq(definition.to_dict(), DeductionContentLoader.validate_case_document(
			_case_document(case_id), case_id).to_dict())
		assert_true(definition.has_scene(definition.start_scene_id))
		var scene := definition.get_scene(definition.start_scene_id)
		assert_not_null(scene)
		if scene != null:
			assert_eq(String(scene.scene_path), GENERIC_SCENE)
			assert_true(FileAccess.file_exists(scene.scene_path))
			assert_false(scene.hotspots.is_empty())
			assert_true(scene.start_focus_id in _hotspot_ids(scene.hotspots))
		var expected_next: Array[StringName] = []
		if index + 1 < CASE_IDS.size():
			expected_next.append(CASE_IDS[index + 1])
		assert_eq(definition.next_case_ids, expected_next, "%s routes onward" % case_id)
		assert_not_null(definition.review)
		if definition.review != null:
			assert_eq(String(definition.review.id), REVIEW_ID)
			assert_false(definition.review.conclusion.strip_edges().is_empty())
		assert_eq(_required_panel_ids(definition), [MAIN_PANEL_ID])
		var main := _main_solution(definition)
		assert_not_null(main, "%s has a review-linked main solution" % case_id)
		if main != null:
			assert_eq(String(main.id), MAIN_SOLUTION_ID)
			assert_eq(String(main.panel_id), MAIN_PANEL_ID)
			assert_eq(String(main.completion_review_id), REVIEW_ID)
			assert_false(main.required_assignments.is_empty())


func test_catalog_rejects_legacy_and_unregistered_case_ids() -> void:
	var catalog: DeductionContentLoader.CaseCatalog = DeductionContentLoader.load_catalog()
	for rejected_id: StringName in [
		LEGACY_MODULE_ID, &"empty_signal", &"clockwork_song", &"case_02_saint_orin",
		&"case_02_probe", &"case_13_missing_axiom", &""
	]:
		assert_null(DeductionContentLoader.load_case(rejected_id), "%s must not load" % rejected_id)
		assert_null(DeductionContentLoader.get_definition(rejected_id), "%s must not resolve" % rejected_id)
		assert_false(DeductionContentLoader.validate_case(rejected_id), "%s must not validate" % rejected_id)
		assert_false(catalog.has_case(rejected_id), "%s must not be in the catalog" % rejected_id)
		assert_false(catalog.unavailable_case_ids.has(rejected_id), "%s must not be flagged" % rejected_id)
	assert_null(DeductionContentLoader.validate_case_document(_case_document(), &"case_probe"))
	var revalidated := DeductionContentLoader.validate_case_document(_case_document(), CASE_ID)
	assert_true(revalidated is DeductionCaseworkCaseDefinition)
	if revalidated != null:
		assert_eq(revalidated.to_dict(), DeductionContentLoader.load_case(CASE_ID).to_dict())
	var route_only := _case_document()
	route_only["next_case_ids"] = []
	route_only["review"]["id"] = REVIEW_ID
	route_only["review"]["conclusion"] = "route only probe"
	var route_definition := DeductionContentLoader.validate_case_document(route_only, CASE_ID)
	assert_true(route_definition is DeductionCaseworkCaseDefinition,
		"a de-duplicated case document still validates")
	if route_definition != null:
		assert_eq(_strings(route_definition.next_case_ids), [])
	var typed_definition := DeductionContentLoader.load_case(CASE_ID)
	var typed_catalog := DeductionContentLoader.CaseCatalog.new()
	typed_catalog.definitions.append(typed_definition)
	assert_true(typed_catalog.has_case(CASE_ID))
	assert_same(typed_catalog.get_definition(CASE_ID), typed_definition)
	assert_eq(typed_catalog.to_dict(), {"available": [String(CASE_ID)], "unavailable": []})
	for legacy_path: String in [
		"../../dedution_casework/content/case_01_empty_signal.tres",
		"../../dedution_casework/content/case_01_empty_signal.json",
		"cases/../escape.json"
	]:
		assert_false(DeductionContentValidator.is_content_path(legacy_path))
	assert_true(DeductionContentValidator.is_content_path("cases/case_01_saint_orin.json"))
	for case_id: StringName in CASE_IDS:
		assert_true(DeductionContentValidator.is_content_path(
			"%s/%s.json" % [CASES_DIRECTORY, String(case_id)]), "%s index path is stable" % case_id)


func test_entry_mounts_case_screen_and_generic_placeholder_boxes() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	assert_same(screen.get_parent(), game)
	assert_eq(game.content_catalog, CASE_IDS)
	var initial: Dictionary = runtime.snapshot()
	assert_true(bool(initial["content_available"]))
	assert_eq(String(initial["case_id"]), String(CASE_ID))
	assert_eq(String(initial["scene_id"]), START_SCENE_ID)
	assert_eq(String(initial["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))
	assert_eq(String(initial["surface_id"]), "")
	assert_eq(String(initial["focus_id"]), START_FOCUS_ID)
	assert_eq(String(initial["feedback_reason"]), "")
	assert_eq(_strings(initial["solved_case_ids"]), [])
	var authored_world := screen.get_node_or_null("%AuthoredWorld") as Control
	var foundation := screen.get_node_or_null("%FoundationLayer") as Control
	var drawer := screen.get_node_or_null("%ContextualDrawer") as DeductionContextualDrawer
	assert_not_null(authored_world)
	assert_not_null(foundation)
	assert_not_null(drawer)
	if authored_world == null or foundation == null or drawer == null:
		return
	assert_true(authored_world.visible)
	assert_false(foundation.visible)
	assert_false(drawer.is_drawer_open())
	var mounted := authored_world.get_child(0) as DeductionAuthoredCaseScene
	assert_eq(authored_world.get_child_count(), 1)
	assert_not_null(mounted)
	if mounted == null:
		return
	var target_grid := mounted.get_node_or_null("%TargetGrid") as GridContainer
	var exit_grid := mounted.get_node_or_null("%ExitGrid") as GridContainer
	var stage_index := mounted.get_node_or_null("%StageIndex") as Label
	var surface_state := mounted.get_node_or_null("%SurfaceState") as Label
	var empty_state := mounted.get_node_or_null("%EmptyState") as Label
	assert_not_null(target_grid)
	assert_not_null(exit_grid)
	assert_not_null(stage_index)
	assert_not_null(surface_state)
	if target_grid == null or exit_grid == null or stage_index == null or surface_state == null:
		return
	assert_eq(String(stage_index.text), "STAGE 1/4")
	assert_eq(String(surface_state.text), "STAGE")
	if empty_state != null:
		assert_false(empty_state.visible)
	var target_boxes := _boxes(target_grid)
	var exit_boxes := _boxes(exit_grid)
	assert_eq(target_boxes.size(), 6)
	assert_eq(exit_boxes.size(), 3)
	var focusable := _strings(initial["focusable_ids"])
	assert_eq(focusable.size(), 9)
	for index: int in range(target_boxes.size()):
		assert_eq(String(target_boxes[index].get_meta(&"box_id")), focusable[index])
		assert_eq(String(target_boxes[index].get_meta(&"kind")), "target")
		assert_true(bool(target_boxes[index].get_meta(&"enabled")))
		assert_eq(target_boxes[index].focus_mode, Control.FOCUS_ALL)
	for index: int in range(exit_boxes.size()):
		assert_eq(String(exit_boxes[index].get_meta(&"box_id")), focusable[6 + index])
		assert_eq(String(exit_boxes[index].get_meta(&"kind")), "exit")
		assert_eq(String(exit_boxes[index].get_meta(&"focus_target")), "")
	var focused_box := _box_by_id(target_boxes, START_FOCUS_ID)
	assert_not_null(focused_box)
	if focused_box != null:
		assert_eq(String(focused_box.get_meta(&"focus_target")), "msg_lab_bench")
		assert_true(focused_box.has_focus())
	await get_tree().process_frame
	await get_tree().process_frame


func test_scene_hotspot_click_opens_message_detail_and_restores_focus() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	var definition := runtime.definition
	var message := definition.get_message(&"msg_lab_bench") if definition != null else null
	assert_not_null(definition)
	assert_not_null(message)
	if definition == null or message == null:
		return
	var opened := runtime.dispatch(&"interact", {"target_id": START_FOCUS_ID})
	assert_true(bool(opened.get("accepted", false)))
	assert_true(bool(opened.get("changed", false)))
	var snapshot: Dictionary = opened["snapshot"]
	assert_eq(String(snapshot["surface_id"]), "msg_lab_bench")
	assert_eq(String(snapshot["return_focus_id"]), START_FOCUS_ID)
	assert_eq(String(snapshot["focus_id"]), START_FOCUS_ID)
	assert_eq(String(snapshot["surface"]["kind"]), "message")
	assert_eq(_strings(snapshot["discovered_entity_ids"]),
		["ent_person_mira", "ent_body_eyes", "ent_decoy_drug"])
	assert_eq(_strings(snapshot["resolved_message_ids"]), ["msg_lab_bench"])
	assert_eq(_strings(snapshot["revealed_panel_ids"]), [MAIN_PANEL_ID])
	await get_tree().process_frame
	var detail := screen.get_node_or_null("%DetailSurface") as Control
	var drawer := screen.get_node_or_null("%ContextualDrawer") as DeductionContextualDrawer
	var detail_actions := screen.get_node_or_null("%DetailActions") as VBoxContainer
	var detail_close := screen.get_node_or_null("%DetailClose") as DeductionFocusableCaseControl
	var world := screen.get_node_or_null("%AuthoredWorld") as Control
	assert_not_null(detail)
	assert_not_null(drawer)
	assert_not_null(detail_actions)
	assert_not_null(detail_close)
	assert_not_null(world)
	if detail == null or drawer == null or detail_actions == null or detail_close == null \
			or world == null:
		return
	assert_true(detail.visible)
	assert_false(drawer.is_drawer_open())
	assert_eq(String((screen.get_node("%DetailKind") as Label).text), "MESSAGE")
	assert_eq(String((screen.get_node("%DetailTitle") as Label).text), String(message.title))
	assert_eq(String((screen.get_node("%DetailBody") as RichTextLabel).text), String(message.body))
	assert_eq(detail_actions.get_child_count(), 0)
	assert_eq(StringName(detail_close.target_id), &"close_detail")
	assert_eq(StringName(detail_close.intent), &"cancel")
	var mounted := world.get_child(0) as DeductionAuthoredCaseScene
	assert_not_null(mounted)
	var target_boxes := _boxes(_target_grid(mounted))
	assert_eq(target_boxes.size(), 6)
	for box: Control in target_boxes:
		assert_false(bool(box.get_meta(&"enabled")))
		assert_eq(box.focus_mode, Control.FOCUS_NONE)
		assert_false(bool(box.get_meta(&"selected")))
	var closed := runtime.dispatch(&"cancel")
	assert_true(bool(closed.get("accepted", false)))
	var restored: Dictionary = closed["snapshot"]
	assert_eq(String(restored["surface_id"]), "")
	assert_eq(String(restored["return_focus_id"]), "")
	assert_eq(String(restored["focus_id"]), START_FOCUS_ID)
	assert_eq(_strings(runtime.focusable_ids()), _strings(restored["focusable_ids"]))
	await get_tree().process_frame
	assert_false(detail.visible)
	var restored_boxes := _boxes(_target_grid(mounted))
	assert_eq(restored_boxes.size(), 6)
	assert_eq(String(restored_boxes[0].get_meta(&"box_id")), START_FOCUS_ID)
	for box: Control in restored_boxes:
		assert_true(bool(box.get_meta(&"enabled")))
		assert_eq(box.focus_mode, Control.FOCUS_ALL)
	var repeated := runtime.dispatch(&"interact", {"target_id": START_FOCUS_ID})
	assert_true(bool(repeated.get("accepted", false)))
	assert_false(bool(repeated.get("changed", true)))
	assert_eq(String(repeated.get("reason", "")), String(DeductionMessageResolver.REASON_ALREADY_RESOLVED))
	assert_eq(_strings(repeated["snapshot"]["discovered_entity_ids"]),
		["ent_person_mira", "ent_body_eyes", "ent_decoy_drug"])
	assert_eq(_strings(repeated["snapshot"]["resolved_message_ids"]), ["msg_lab_bench"])
	assert_false(detail.visible)
	await get_tree().process_frame
	await get_tree().process_frame


func test_region_transition_replaces_snapshot_and_restores_origin_focus() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	var moved := runtime.dispatch(&"focus_move", {"direction": "right"})
	assert_true(bool(moved.get("accepted", false)))
	assert_eq(String(moved["snapshot"]["focus_id"]), "hotspot_lab_lens_case")
	var entered := runtime.dispatch(&"interact", {"target_id": "trans_lab_to_booth"})
	assert_true(bool(entered.get("accepted", false)))
	assert_true(bool(entered.get("changed", false)))
	assert_eq(String(entered.get("scene_id", "")), "scene_booth")
	var booth: Dictionary = entered["snapshot"]
	assert_eq(String(booth["scene_id"]), "scene_booth")
	assert_eq(String(booth["focus_id"]), "hotspot_booth_eye_card")
	assert_eq(String(booth["surface_id"]), "")
	assert_eq(String(booth["return_focus_id"]), "")
	assert_eq(_strings(booth["focusable_ids"]),
		["hotspot_booth_eye_card", "hotspot_booth_recorder", "hotspot_booth_log_sheet",
			"hotspot_booth_grell_pager", "trans_booth_to_lab"])
	await get_tree().process_frame
	var world := screen.get_node_or_null("%AuthoredWorld") as Control
	assert_not_null(world)
	if world == null:
		return
	assert_eq(world.get_child_count(), 1)
	var booth_scene := world.get_child(0) as DeductionAuthoredCaseScene
	assert_not_null(booth_scene)
	if booth_scene == null:
		return
	assert_eq(String((booth_scene.get_node("%StageIndex") as Label).text), "STAGE 2/4")
	assert_eq(String((booth_scene.get_node("%SurfaceState") as Label).text), "STAGE")
	assert_eq(_boxes(booth_scene.get_node("%TargetGrid") as GridContainer).size(), 4)
	assert_eq(_boxes(booth_scene.get_node("%ExitGrid") as GridContainer).size(), 1)
	var returned := runtime.dispatch(&"interact", {"target_id": "trans_booth_to_lab"})
	assert_true(bool(returned.get("accepted", false)))
	var restored: Dictionary = returned["snapshot"]
	assert_eq(String(restored["scene_id"]), START_SCENE_ID)
	assert_eq(String(restored["focus_id"]), START_FOCUS_ID)
	var state: Dictionary = runtime.save_state().to_dict()["case_progress_by_id"][CASE_ID]
	assert_eq(_strings(state["visited_scene_ids"]), [START_SCENE_ID, "scene_booth"])
	assert_eq(String(state["current_scene_id"]), START_SCENE_ID)
	await get_tree().process_frame
	assert_eq(world.get_child_count(), 1)
	var lab_scene := world.get_child(0) as DeductionAuthoredCaseScene
	assert_not_null(lab_scene)
	if lab_scene == null:
		return
	assert_eq(String((lab_scene.get_node("%StageIndex") as Label).text), "STAGE 1/4")
	assert_eq(_boxes(lab_scene.get_node("%TargetGrid") as GridContainer).size(), 6)
	var focus_box := _box_by_id(_boxes(lab_scene.get_node("%TargetGrid") as GridContainer), START_FOCUS_ID)
	assert_not_null(focus_box)
	if focus_box != null:
		assert_true(focus_box.has_focus())
	var unknown := runtime.dispatch(&"interact", {"target_id": "trans_nowhere"})
	assert_false(bool(unknown.get("accepted", true)))
	assert_eq(String(unknown.get("reason", "")), String(DeductionCaseRuntime.REASON_UNKNOWN_TARGET))
	assert_eq(String(unknown["snapshot"]["scene_id"]), START_SCENE_ID)
	await get_tree().process_frame
	await get_tree().process_frame


func test_blocked_and_invalid_messages_leave_progress_untouched() -> void:
	var runtime := _new_runtime(_authored_catalog(), {})
	var before := runtime.save_state().to_dict()
	var wrong_region := runtime.dispatch(&"interact", {"target_id": "hotspot_locker_notebook"})
	assert_false(bool(wrong_region.get("accepted", true)))
	assert_eq(String(wrong_region.get("reason", "")), String(DeductionCaseRuntime.REASON_UNKNOWN_TARGET))
	assert_eq(runtime.save_state().to_dict(), before)
	for hotspot_id: String in ["hotspot_lab_task_board", "hotspot_lab_stim_behavior"]:
		assert_true(bool(runtime.dispatch(&"interact", {"target_id": hotspot_id}).get("accepted", false)))
		runtime.dispatch(&"cancel")
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "trans_lab_to_locker"}).get("accepted", false)))
	var resolved_state := runtime.save_state().to_dict()
	var blocked := runtime.dispatch(&"interact", {"target_id": "hotspot_locker_notebook"})
	assert_false(bool(blocked.get("accepted", true)))
	assert_eq(String(blocked.get("reason", "")), String(DeductionMessageResolver.REASON_PREREQUISITE_UNMET))
	assert_eq(_strings(blocked["snapshot"]["resolved_message_ids"]),
		["msg_lab_task_board", "msg_lab_stim_behavior"])
	assert_eq(runtime.save_state().to_dict(), resolved_state)
	assert_eq(String(blocked["snapshot"]["feedback_reason"]), "prerequisite_unmet")
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "trans_locker_to_lab"}).get("accepted", false)))
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "trans_lab_to_booth"}).get("accepted", false)))
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "hotspot_booth_recorder"}).get("accepted", false)))
	runtime.dispatch(&"cancel")
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "trans_booth_to_lab"}).get("accepted", false)))
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": "trans_lab_to_locker"}).get("accepted", false)))
	var unlocked := runtime.dispatch(&"interact", {"target_id": "hotspot_locker_notebook"})
	assert_true(bool(unlocked.get("accepted", false)))
	assert_true(bool(unlocked.get("changed", false)))
	assert_eq(_strings(unlocked["snapshot"]["resolved_message_ids"]),
		["msg_lab_task_board", "msg_lab_stim_behavior", "msg_booth_recorder", "msg_locker_notebook"])
	var unlocked_state := runtime.save_state().to_dict()
	var document := _case_document()
	document["messages"][0]["effects"][0]["params"] = {"entity_id": "ent_missing"}
	var definition := DeductionContentLoader.validate_case_document(document, CASE_ID)
	assert_true(definition is DeductionCaseworkCaseDefinition)
	if definition == null:
		return
	var broken_catalog := DeductionContentLoader.CaseCatalog.new()
	broken_catalog.definitions.append(definition)
	var broken := _new_runtime(broken_catalog, {})
	var broken_before := broken.save_state().to_dict()
	var invalid := broken.dispatch(&"interact", {"target_id": START_FOCUS_ID})
	assert_false(bool(invalid.get("accepted", true)))
	assert_eq(String(invalid.get("reason", "")), String(DeductionMessageResolver.REASON_INVALID_EFFECT))
	assert_eq(_strings(invalid["snapshot"]["revealed_panel_ids"]), [])
	assert_eq(_strings(invalid["snapshot"]["discovered_entity_ids"]), [])
	assert_eq(broken.save_state().to_dict(), broken_before)
	var unknown_target := runtime.dispatch(&"interact", {"target_id": "hotspot_nowhere"})
	assert_false(bool(unknown_target.get("accepted", true)))
	assert_eq(String(unknown_target.get("reason", "")), String(DeductionCaseRuntime.REASON_UNKNOWN_TARGET))
	assert_eq(runtime.save_state().to_dict(), unlocked_state)
	var unknown_intent := runtime.dispatch(&"teleport", {})
	assert_false(bool(unknown_intent.get("accepted", true)))
	assert_eq(String(unknown_intent.get("reason", "")), String(DeductionCaseRuntime.REASON_UNKNOWN_INTENT))
	assert_eq(runtime.save_state().to_dict(), unlocked_state)
	assert_eq(String(runtime.snapshot()["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))


func test_panel_drag_assign_rolls_back_wrong_entity_and_solves_main_statement() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	var solved_events: Array = []
	runtime.case_solved.connect(func(case_id: StringName, solution_id: StringName) -> void:
		solved_events.append([String(case_id), String(solution_id)])
	)
	for hotspot_id: String in [
		"hotspot_lab_lens_case", "hotspot_lab_bench", "hotspot_lab_stim_calibration",
		"hotspot_lab_stim_behavior", "hotspot_lab_task_board", "hotspot_lab_grell_gauze"
	]:
		var opened_hotspot := await _step(runtime, &"interact", {"target_id": hotspot_id})
		assert_true(bool(opened_hotspot.get("accepted", false)), "%s should resolve" % hotspot_id)
		await _step(runtime, &"cancel")
	for leg: Array in [
		["trans_lab_to_locker", "hotspot_locker_repair_card", "trans_locker_to_lab"],
		["trans_lab_to_corridor", "hotspot_corridor_instruments", ""]
	]:
		var walked := await _step(runtime, &"interact", {"target_id": leg[0]})
		assert_true(bool(walked.get("accepted", false)), "%s should be walkable" % leg[0])
		var read := await _step(runtime, &"interact", {"target_id": leg[1]})
		assert_true(bool(read.get("accepted", false)), "%s should resolve" % leg[1])
		await _step(runtime, &"cancel")
		if not String(leg[2]).is_empty():
			var back := await _step(runtime, &"interact", {"target_id": leg[2]})
			assert_true(bool(back.get("accepted", false)), "%s should be walkable" % leg[2])
	assert_eq(_strings(runtime.snapshot()["resolved_message_ids"]),
		["msg_lab_lens_case", "msg_lab_bench", "msg_lab_stim_calibration", "msg_lab_stim_behavior",
			"msg_lab_task_board", "msg_lab_grell_gauze", "msg_locker_repair_card", "msg_corridor_instruments"])
	assert_eq(_strings(runtime.snapshot()["revealed_panel_ids"]),
		[MAIN_PANEL_ID, "panel_inter_frame_0134", "panel_inter_repair_response"])
	var opened := await _step(runtime, &"interact", {"target_id": MAIN_PANEL_ID})
	assert_true(bool(opened.get("accepted", false)))
	var panel_snapshot: Dictionary = opened["snapshot"]
	assert_eq(String(panel_snapshot["surface_id"]), MAIN_PANEL_ID)
	assert_eq(String(panel_snapshot["focus_id"]), "slot_main_actor")
	assert_eq(String(panel_snapshot["return_focus_id"]), "hotspot_corridor_instruments")
	assert_eq(_strings(panel_snapshot["focusable_ids"]).slice(0, 5),
		["slot_main_actor", "slot_main_visual", "slot_main_touch", "slot_main_method", "slot_main_cause"])
	assert_eq(String(panel_snapshot["panels"][MAIN_PANEL_ID]["status"]), "not_filled")
	assert_true(bool(panel_snapshot["panels"][MAIN_PANEL_ID]["unlocked"]))
	var drawer := screen.get_node_or_null("%ContextualDrawer") as DeductionContextualDrawer
	assert_not_null(drawer)
	if drawer == null:
		return
	var slot_grid := drawer.get_node_or_null("%SlotGrid") as GridContainer
	assert_not_null(slot_grid)
	if slot_grid == null:
		return
	var main_panel := runtime.definition.get_panel(StringName(MAIN_PANEL_ID))
	assert_not_null(main_panel)
	assert_true(drawer.is_drawer_open())
	assert_eq(String((drawer.get_node("%DrawerTitle") as Label).text), String(main_panel.title))
	assert_eq(String((drawer.get_node("%DrawerStatus") as Label).text), "NOT FILLED")
	assert_eq(slot_grid.get_child_count(), 5)
	var selected := runtime.dispatch(&"interact", {"target_id": "ent_body_eyes"})
	assert_true(bool(selected.get("accepted", false)))
	assert_eq(String(selected["snapshot"]["selected_entity_id"]), "ent_body_eyes")
	runtime.dragged_entity_id = &"ent_person_mira"
	var before_wrong := runtime.save_state().to_dict()
	var rejected := await _step(runtime, &"interact", {"target_id": "slot_main_visual"})
	assert_false(bool(rejected.get("accepted", true)))
	assert_eq(String(rejected.get("reason", "")), String(DeductionPanelWorkspace.REASON_REJECTED_KIND))
	assert_eq(runtime.save_state().to_dict(), before_wrong)
	assert_eq(String(rejected["snapshot"]["panels"][MAIN_PANEL_ID]["slots"][1]["entity_id"]), "")
	assert_eq(String(rejected["snapshot"]["panels"][MAIN_PANEL_ID]["status"]), "not_filled")
	assert_eq(StringName(runtime.dragged_entity_id), &"ent_person_mira")
	assert_eq(String(rejected["snapshot"]["dragged_entity_id"]), "ent_person_mira")
	assert_eq(String(rejected["snapshot"]["feedback_reason"]), "rejected_kind")
	var dropped := await _step(runtime, &"interact", {"target_id": "slot_main_actor"})
	assert_true(bool(dropped.get("accepted", false)))
	assert_true(bool(dropped.get("changed", false)))
	assert_eq(String(dropped["snapshot"]["panels"][MAIN_PANEL_ID]["slots"][0]["entity_id"]), "ent_person_mira")
	assert_eq(String(dropped["snapshot"]["selected_entity_id"]), "")
	assert_eq(String(dropped["snapshot"]["dragged_entity_id"]), "")
	assert_eq(StringName(runtime.dragged_entity_id), &"")
	var filled := runtime.save_state().to_dict()
	var occupied_select := await _step(runtime, &"interact", {"target_id": "ent_person_grell"})
	assert_true(bool(occupied_select.get("accepted", false)))
	var occupied := await _step(runtime, &"interact", {"target_id": "slot_main_actor"})
	assert_false(bool(occupied.get("accepted", true)))
	assert_eq(String(occupied.get("reason", "")), String(DeductionPanelWorkspace.REASON_OCCUPIED))
	assert_eq(runtime.save_state().to_dict(), filled)
	assert_eq(String(occupied["snapshot"]["panels"][MAIN_PANEL_ID]["slots"][0]["entity_id"]), "ent_person_mira")
	for pair: Array in [
		["slot_main_visual", "ent_action_no_read"],
		["slot_main_touch", "ent_action_touch_correct"],
		["slot_main_method", "ent_method_input_first_check"]
	]:
		var assigned := await _step(runtime, &"assign", {
			"panel_id": MAIN_PANEL_ID, "slot_id": pair[0], "entity_id": pair[1]
		})
		assert_true(bool(assigned.get("accepted", false)), "%s should accept %s" % [pair[0], pair[1]])
	assert_eq(String(runtime.snapshot()["panels"][MAIN_PANEL_ID]["status"]), "almost")
	var almost_state := runtime.save_state().to_dict()
	var premature := await _step(runtime, &"submit_panel", {"panel_id": MAIN_PANEL_ID})
	assert_false(bool(premature.get("accepted", true)))
	assert_eq(String(premature.get("reason", "")), String(DeductionCaseRuntime.REASON_PANEL_UNSOLVED))
	assert_eq(String(premature.get("panel_status", "")), "almost")
	assert_eq(runtime.save_state().to_dict(), almost_state)
	assert_eq(String(runtime.snapshot()["case_status"]), String(DeductionCaseProgress.STATUS_OPEN)
	)
	var last := await _step(runtime, &"assign", {
		"panel_id": MAIN_PANEL_ID, "slot_id": "slot_main_cause", "entity_id": "ent_action_self_damage"
	})
	assert_true(bool(last.get("accepted", false)))
	assert_eq(String(last["snapshot"]["panels"][MAIN_PANEL_ID]["status"]), "solved")
	var solved := await _step(runtime, &"submit_panel", {"panel_id": MAIN_PANEL_ID})
	assert_true(bool(solved.get("accepted", false)))
	assert_true(bool(solved.get("case_solved", false)))
	assert_eq(String(solved.get("solution_id", "")), MAIN_SOLUTION_ID)
	var solved_snapshot: Dictionary = solved["snapshot"]
	assert_eq(String(solved_snapshot["case_status"]), String(DeductionCaseProgress.STATUS_SOLVED))
	assert_eq(String(solved_snapshot["panels"][MAIN_PANEL_ID]["status"]), "solved")
	assert_eq(String(solved_snapshot["review"]["id"]), REVIEW_ID)
	assert_false(bool(solved_snapshot["review"]["completed"]))
	assert_eq(_strings(solved_snapshot["review"]["next_case_ids"]), [String(SECOND_CASE_ID)])
	var solved_state := runtime.save_state().to_dict()
	assert_true(SaveService.is_json_safe(solved_state))
	assert_eq(String(solved_state["case_progress_by_id"][CASE_ID]["status"]),
		String(DeductionCaseProgress.STATUS_SOLVED))
	assert_eq(_strings(solved_state["case_progress_by_id"][CASE_ID]["accepted_solution_ids"]),
		[MAIN_SOLUTION_ID])
	assert_eq(solved_events, [[String(CASE_ID), MAIN_SOLUTION_ID]])
	assert_eq(String((drawer.get_node("%DrawerStatus") as Label).text), "SOLVED")
	var solved_state_copy := runtime.save_state().to_dict()
	for wrong_next: String in ["case_02_missing", String(CASE_IDS[2])]:
		var unknown_next := await _step(runtime, &"review_confirm", {"next_case_id": wrong_next})
		assert_false(bool(unknown_next.get("accepted", true)))
		assert_eq(String(unknown_next.get("reason", "")), String(DeductionCaseProgression.REASON_UNKNOWN_NEXT_CASE))
		assert_eq(runtime.save_state().to_dict(), solved_state_copy)
	var reviewed := await _step(runtime, &"review_confirm", {})
	assert_true(bool(reviewed.get("accepted", false)))
	assert_eq(String(reviewed.get("review_id", "")), REVIEW_ID)
	var reviewed_snapshot: Dictionary = reviewed["snapshot"]
	assert_eq(String(reviewed_snapshot["case_status"]), String(DeductionCaseProgress.STATUS_REVIEWED))
	assert_true(bool(reviewed_snapshot["review"]["completed"]))
	assert_eq(_strings(reviewed_snapshot["solved_case_ids"]), [String(CASE_ID)])
	var reviewed_state := runtime.save_state().to_dict()
	assert_eq(_strings(reviewed_state["route_state"]["reviewed_case_ids"]), [String(CASE_ID)])
	assert_eq(_strings(reviewed_state["route_state"]["unlocked_case_ids"]), [String(SECOND_CASE_ID)])
	assert_eq(String(reviewed_state["active_case_id"]), String(CASE_ID))
	assert_eq(String(reviewed_state["last_case_id"]), String(CASE_ID))
	for key: String in TRANSIENT_KEYS:
		assert_false(reviewed_state.has(key))
	var closed := await _step(runtime, &"cancel")
	assert_true(bool(closed.get("accepted", false)))
	assert_eq(String(closed["snapshot"]["surface_id"]), "")
	assert_eq(String(closed["snapshot"]["focus_id"]), "hotspot_corridor_instruments")
	assert_false(drawer.is_drawer_open())
	await get_tree().process_frame
	await get_tree().process_frame


func test_every_authored_stage_02_to_12_is_catalog_reachable_and_solvable() -> void:
	var catalog := _authored_catalog()
	for index: int in range(1, CASE_IDS.size()):
		var case_id := CASE_IDS[index]
		var definition := catalog.get_definition(case_id)
		assert_eq(catalog.list_case_ids().find(case_id), index, "%s keeps its stage slot" % case_id)
		assert_not_null(definition)
		if definition == null:
			continue
		assert_eq(definition.scenes.size() >= 3, true, "%s has its own scene set" % case_id)
		assert_eq(_required_panel_ids(definition), [MAIN_PANEL_ID])
		var runtime := _new_runtime(catalog, _chain_state(catalog, index))
		var snapshot := runtime.snapshot()
		assert_eq(String(snapshot["case_id"]), String(case_id), "%s is the active case" % case_id)
		assert_true(bool(snapshot["content_available"]))
		assert_eq(String(snapshot["scene_id"]), String(definition.start_scene_id))
		assert_eq(String(snapshot["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))
		assert_eq(String(snapshot["surface_id"]), "")
		assert_eq(String(snapshot["focus_id"]), String(
			definition.get_scene(definition.start_scene_id).start_focus_id))
		assert_eq(_strings(snapshot["solved_case_ids"]), _strings(CASE_IDS.slice(0, index)))
		_solve_active_case(runtime)
		var submitted := runtime.dispatch(&"submit_panel", {"panel_id": MAIN_PANEL_ID})
		assert_true(bool(submitted.get("case_solved", false)), "%s is solvable" % case_id)
		assert_eq(String(submitted.get("solution_id", "")), MAIN_SOLUTION_ID)
		var solved_snapshot: Dictionary = submitted["snapshot"]
		assert_eq(String(solved_snapshot["case_status"]), String(DeductionCaseProgress.STATUS_SOLVED))
		assert_eq(String(solved_snapshot["panels"][MAIN_PANEL_ID]["status"]), "solved")
		assert_eq(_strings(solved_snapshot["resolved_message_ids"]).size(),
			definition.messages.size(), "%s resolves every authored message" % case_id)
		var expected_next: Array[StringName] = []
		if index + 1 < CASE_IDS.size():
			expected_next.append(CASE_IDS[index + 1])
		assert_eq(_strings(solved_snapshot["review"]["next_case_ids"]), _strings(expected_next))
		var reviewed := runtime.dispatch(&"review_confirm",
			{} if expected_next.is_empty() else {"next_case_id": String(expected_next[0])})
		assert_true(bool(reviewed.get("accepted", false)), "%s reviews" % case_id)
		var saved := runtime.save_state().to_dict()
		assert_eq(_strings(saved["route_state"]["reviewed_case_ids"]),
			_strings(CASE_IDS.slice(0, index + 1)))
		assert_eq(String(saved["route_state"]["reviewed_case_ids"][index]), String(case_id))
		if expected_next.is_empty():
			assert_eq(String(saved["active_case_id"]), String(case_id))
		else:
			assert_eq(String(saved["active_case_id"]), String(expected_next[0]))
		assert_true(SaveService.is_json_safe(saved))


func test_review_confirm_walks_the_full_12_case_route_chain() -> void:
	var runtime := _new_runtime(_authored_catalog(), {})
	for index: int in range(CASE_IDS.size()):
		var case_id := CASE_IDS[index]
		var is_last := index + 1 == CASE_IDS.size()
		var definition := runtime.definition
		assert_not_null(definition)
		if definition == null:
			return
		assert_eq(String(definition.id), String(case_id), "step %d runs %s" % [index, case_id])
		var entered: Dictionary = runtime.snapshot()
		assert_eq(String(entered["case_id"]), String(case_id))
		assert_eq(String(entered["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))
		assert_eq(String(entered["scene_id"]), String(definition.start_scene_id))
		assert_eq(_strings(entered["solved_case_ids"]), _strings(CASE_IDS.slice(0, index)))
		_solve_active_case(runtime)
		var submitted := runtime.dispatch(&"submit_panel", {"panel_id": MAIN_PANEL_ID})
		assert_true(bool(submitted.get("case_solved", false)), "%s solves in the chain" % case_id)
		var expected_next: Array[StringName] = []
		if not is_last:
			expected_next.append(CASE_IDS[index + 1])
		assert_eq(_strings(submitted["snapshot"]["review"]["next_case_ids"]), _strings(expected_next))
		var wrong_next := runtime.dispatch(&"review_confirm", {"next_case_id": "case_99_missing"})
		assert_false(bool(wrong_next.get("accepted", true)), "%s refuses an unrouted next" % case_id)
		assert_eq(String(wrong_next.get("reason", "")),
			String(DeductionCaseProgression.REASON_UNKNOWN_NEXT_CASE))
		var reviewed := runtime.dispatch(&"review_confirm",
			{} if is_last else {"next_case_id": String(CASE_IDS[index + 1])})
		assert_true(bool(reviewed.get("accepted", false)), "%s reviews" % case_id)
		assert_eq(String(reviewed.get("review_id", "")), REVIEW_ID)
		var reviewed_snapshot: Dictionary = reviewed["snapshot"]
		assert_eq(_strings(reviewed_snapshot["solved_case_ids"]), _strings(CASE_IDS.slice(0, index + 1)))
		var after_review := runtime.save_state().to_dict()
		var reviewed_progress: Dictionary = after_review["case_progress_by_id"][String(case_id)]
		assert_eq(String(reviewed_progress["status"]), String(DeductionCaseProgress.STATUS_REVIEWED),
			"%s is stored as reviewed" % case_id)
		assert_true(bool(reviewed_progress["reviewed"]))
		assert_eq(_strings(reviewed_progress["accepted_solution_ids"]), [MAIN_SOLUTION_ID])
		assert_eq(_strings(after_review["route_state"]["reviewed_case_ids"]),
			_strings(CASE_IDS.slice(0, index + 1)))
		if is_last:
			assert_eq(String(reviewed_snapshot["case_id"]), String(case_id))
			assert_eq(String(reviewed_snapshot["case_status"]), String(DeductionCaseProgress.STATUS_REVIEWED))
			assert_true(bool(reviewed_snapshot["review"]["completed"]))
			assert_eq(String(reviewed_snapshot["scene_id"]), String(definition.start_scene_id))
		else:
			assert_eq(String(reviewed_snapshot["case_id"]), String(CASE_IDS[index + 1]),
				"%s hands the runtime onward" % case_id)
			assert_eq(String(reviewed_snapshot["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))
			assert_false(bool(reviewed_snapshot["review"]["completed"]))
			assert_eq(String(reviewed_snapshot["scene_id"]), String(runtime.definition.start_scene_id))
	var final_state := runtime.save_state().to_dict()
	assert_eq(final_state.keys(), SAVE_KEYS)
	assert_true(SaveService.is_json_safe(final_state))
	assert_eq(_strings(final_state["case_progress_by_id"].keys()), _strings(CASE_IDS))
	assert_eq(_strings(final_state["route_state"]["reviewed_case_ids"]), _strings(CASE_IDS))
	assert_eq(_strings(final_state["route_state"]["unlocked_case_ids"]), _strings(CASE_IDS.slice(1)))
	assert_eq(String(final_state["active_case_id"]), String(FINAL_CASE_ID))
	assert_eq(String(final_state["last_case_id"]), String(FINAL_CASE_ID))
	for case_id: StringName in CASE_IDS:
		var progress: Dictionary = final_state["case_progress_by_id"][String(case_id)]
		assert_eq(String(progress["case_id"]), String(case_id))
		assert_eq(String(progress["status"]), String(DeductionCaseProgress.STATUS_REVIEWED))
		assert_eq(_strings(progress["accepted_solution_ids"]), [MAIN_SOLUTION_ID])
	for key: String in TRANSIENT_KEYS:
		assert_false(final_state.has(key))


func test_case_12_panels_stay_locked_until_case_11_is_reviewed() -> void:
	var catalog := _authored_catalog()
	var definition := catalog.get_definition(FINAL_CASE_ID)
	assert_not_null(definition)
	if definition == null:
		return
	var panel_ids := _panel_ids(definition)
	assert_true(panel_ids.size() >= 2)
	var locked := _new_runtime(catalog, {
		"schema_version": DeductionCaseworkCaseState.SCHEMA_VERSION,
		"active_case_id": String(FINAL_CASE_ID),
		"last_case_id": String(FINAL_CASE_ID),
		"case_progress_by_id": {
			String(GATE_CASE_ID): DeductionCaseProgression.initial_progress(
				DeductionContentLoader.load_case(GATE_CASE_ID)).to_dict()
		},
		"route_state": {"unlocked_case_ids": [String(FINAL_CASE_ID)], "reviewed_case_ids": []}
	})
	assert_eq(String(locked.definition.id), String(FINAL_CASE_ID))
	assert_eq(String(locked.snapshot()["case_status"]), String(DeductionCaseProgress.STATUS_OPEN))
	assert_eq(_strings(locked.snapshot()["solved_case_ids"]), [])
	var locked_panels: Dictionary = locked.snapshot()["panels"]
	for panel_id: String in panel_ids:
		assert_false(bool(locked_panels[panel_id]["unlocked"]), "%s is locked before case 11" % panel_id)
		assert_eq(String(locked_panels[panel_id]["status"]), "undiscovered")
	var locked_before := locked.save_state().to_dict()
	var opened := locked.dispatch(&"interact", {"target_id": MAIN_PANEL_ID})
	assert_false(bool(opened.get("accepted", true)))
	assert_eq(String(opened.get("reason", "")), String(DeductionPanelWorkspace.REASON_PANEL_LOCKED))
	var first_assignment := _main_solution(definition).required_assignments[0]
	var assigned := locked.dispatch(&"assign", {
		"panel_id": MAIN_PANEL_ID, "slot_id": String(first_assignment.slot_id),
		"entity_id": String(first_assignment.entity_id)
	})
	assert_false(bool(assigned.get("accepted", true)))
	assert_eq(String(assigned.get("reason", "")), String(DeductionPanelWorkspace.REASON_PANEL_LOCKED))
	var submitted := locked.dispatch(&"submit_panel", {"panel_id": MAIN_PANEL_ID})
	assert_false(bool(submitted.get("accepted", true)))
	assert_eq(String(submitted.get("reason", "")), String(DeductionCaseRuntime.REASON_PANEL_UNSOLVED))
	var revealed := locked.dispatch(&"interact", {"target_id": "panel_inter_common_structure"})
	assert_false(bool(revealed.get("accepted", true)))
	assert_eq(String(revealed.get("reason", "")), String(DeductionPanelWorkspace.REASON_PANEL_LOCKED))
	assert_eq(locked.save_state().to_dict(), locked_before)
	var unlocked := _new_runtime(catalog, _chain_state(catalog, CASE_IDS.size() - 1))
	assert_eq(String(unlocked.definition.id), String(FINAL_CASE_ID))
	assert_eq(_strings(unlocked.snapshot()["solved_case_ids"]), _strings(CASE_IDS.slice(0, CASE_IDS.size() - 1)))
	var unlocked_panels: Dictionary = unlocked.snapshot()["panels"]
	for panel_id: String in panel_ids:
		assert_true(bool(unlocked_panels[panel_id]["unlocked"]), "%s unlocks after case 11" % panel_id)
	var opened_after := unlocked.dispatch(&"interact", {"target_id": MAIN_PANEL_ID})
	assert_true(bool(opened_after.get("accepted", false)))
	assert_eq(String(opened_after["snapshot"]["surface_id"]), MAIN_PANEL_ID)
	assert_eq(String(unlocked.snapshot()["surface_id"]), MAIN_PANEL_ID)
	_solve_active_case(unlocked)
	var final_submit := unlocked.dispatch(&"submit_panel", {"panel_id": MAIN_PANEL_ID})
	assert_true(bool(final_submit.get("case_solved", false)), "case 12 closes the chain")
	assert_eq(_strings(final_submit["snapshot"]["review"]["next_case_ids"]), [])
	var closed := unlocked.dispatch(&"review_confirm", {})
	assert_true(bool(closed.get("accepted", false)))
	var closed_state := unlocked.save_state().to_dict()
	assert_eq(_strings(closed_state["route_state"]["reviewed_case_ids"]), _strings(CASE_IDS))
	assert_eq(_strings(closed_state["route_state"]["unlocked_case_ids"]), _strings(CASE_IDS.slice(1)))
	assert_eq(String(closed_state["active_case_id"]), String(FINAL_CASE_ID))
	assert_eq(String(closed_state["last_case_id"]), String(FINAL_CASE_ID))


func test_case_screen_intent_reaches_module_runtime() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	var results: Array[Dictionary] = []
	runtime.intent_resolved.connect(func(result: Dictionary) -> void:
		results.append(result)
	)
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": MAIN_PANEL_ID}).get("accepted", false)))
	await get_tree().process_frame
	var drawer := screen.get_node_or_null("%ContextualDrawer") as DeductionContextualDrawer
	assert_not_null(drawer)
	if drawer == null:
		return
	assert_true(drawer.is_drawer_open())
	var close_button := drawer.get_node_or_null("%CloseButton") as Control
	assert_not_null(close_button)
	if close_button == null:
		return
	results.clear()
	close_button.emit_signal(&"activated", &"cancel", {})
	assert_eq(results.size(), 1)
	if results.size() == 1:
		assert_eq(String(results[0]["intent"]), "cancel")
		assert_true(bool(results[0]["accepted"]))
	assert_eq(String(runtime.snapshot()["surface_id"]), "")
	assert_eq(String(runtime.snapshot()["focus_id"]), START_FOCUS_ID)
	assert_false(drawer.is_drawer_open())
	var submit_button := drawer.get_node_or_null("%SubmitButton") as DeductionFocusableCaseControl
	assert_not_null(submit_button)
	if submit_button != null:
		assert_eq(String(submit_button.base_text), "SUBMIT")
		assert_eq(StringName(submit_button.intent), &"submit_panel")
		assert_eq(String(submit_button.payload["panel_id"]), MAIN_PANEL_ID)
		assert_false(game.execute_command(submit_button.intent, submit_button.payload))
		assert_eq(String(runtime.snapshot()["case_status"]), String(DeductionCaseProgress.STATUS_OPEN)
		)
	await get_tree().process_frame
	await get_tree().process_frame


func test_case_screen_reacts_to_snapshot_surfaces_and_focus() -> void:
	var game := _spawn()
	if game == null:
		return
	var screen := game.get_node_or_null("CaseScreen") as DeductionCaseScreen
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(screen)
	assert_not_null(runtime)
	if screen == null or runtime == null:
		return
	var drawer := screen.get_node_or_null("%ContextualDrawer") as DeductionContextualDrawer
	var detail := screen.get_node_or_null("%DetailSurface") as Control
	var detail_actions := screen.get_node_or_null("%DetailActions") as VBoxContainer
	var detail_close := screen.get_node_or_null("%DetailClose") as Control
	var world := screen.get_node_or_null("%AuthoredWorld") as Control
	var foundation := screen.get_node_or_null("%FoundationLayer") as Control
	var foundation_body := screen.get_node_or_null("%FoundationBody") as Label
	assert_not_null(drawer)
	assert_not_null(detail)
	assert_not_null(detail_actions)
	assert_not_null(detail_close)
	assert_not_null(world)
	assert_not_null(foundation)
	assert_not_null(foundation_body)
	if drawer == null or detail == null or detail_actions == null or detail_close == null \
			or world == null or foundation == null or foundation_body == null:
		return
	assert_false(drawer.is_drawer_open())
	assert_false(detail.visible)
	screen.apply_snapshot({
		"content_available": true,
		"surface_id": "detail_probe",
		"focus_id": "detail_action",
		"panels": {},
		"discovered_entity_ids": [],
		"selected_entity_id": "",
		"feedback_reason": ""
	}, {
		"surfaces": {
			"detail_probe": {
				"kind": "message",
				"title": "Probe detail",
				"body": "Detail body",
				"focus_id": "detail_action",
				"actions": [{
					"id": "detail_action",
					"text": "CONTINUE",
					"intent": "cancel",
					"payload": {}
				}]
			}
		}
	})
	assert_true(detail.visible)
	assert_eq(String((screen.get_node("%DetailTitle") as Label).text), "Probe detail")
	assert_eq(String((screen.get_node("%DetailBody") as RichTextLabel).text), "Detail body")
	assert_eq(detail_actions.get_child_count(), 1)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(detail_close.has_focus())
	screen.apply_snapshot({"content_available": false})
	assert_false(detail.visible)
	assert_false(drawer.is_drawer_open())
	assert_eq(world.get_child_count(), 0)
	assert_false(world.visible)
	assert_true(foundation.visible)
	assert_eq(String(foundation_body.text), FOUNDATION_UNAVAILABLE_TEXT)
	await get_tree().process_frame
	screen.apply_snapshot(runtime.snapshot(), runtime.definition.to_dict())
	assert_true(world.visible)
	assert_eq(world.get_child_count(), 1)
	assert_true(bool(runtime.dispatch(&"interact", {"target_id": MAIN_PANEL_ID}).get("accepted", false)))
	await get_tree().process_frame
	assert_true(drawer.is_drawer_open())
	var slot_grid := drawer.get_node_or_null("%SlotGrid") as GridContainer
	assert_not_null(slot_grid)
	if slot_grid == null:
		return
	assert_eq(slot_grid.get_child_count(), 5)
	var focus_owner := get_viewport().gui_get_focus_owner() as DeductionFocusableCaseControl
	assert_not_null(focus_owner)
	if focus_owner != null:
		assert_true(drawer.is_ancestor_of(focus_owner))
		assert_true(focus_owner.focus_mode == Control.FOCUS_ALL)
	var snapshot_focus_id := String(runtime.snapshot()["focus_id"])
	var matching_focus_item: DeductionFocusableCaseControl = null
	for child: Node in slot_grid.get_children():
		var item := child as DeductionFocusableCaseControl
		if item != null and String(item.target_id) == snapshot_focus_id:
			matching_focus_item = item
			break
	assert_not_null(matching_focus_item)
	if matching_focus_item != null:
		assert_true(matching_focus_item.is_visible_in_tree())
	await get_tree().process_frame
	await get_tree().process_frame


func test_save_state_is_versioned_json_safe_and_round_trips() -> void:
	var game := _spawn()
	assert_not_null(game.runtime)
	assert_true(game.runtime is DeductionCaseRuntime)
	assert_eq(game.content_catalog, CASE_IDS)
	var snapshot := game.save_state()
	assert_eq(snapshot.keys(), SAVE_KEYS)
	assert_true(SaveService.is_json_safe(snapshot))
	assert_eq(snapshot, _fresh_state())
	for key: String in TRANSIENT_KEYS:
		assert_false(snapshot.has(key))
	var decoded: Variant = JSON.parse_string(JSON.stringify(snapshot))
	assert_true(decoded is Dictionary)
	if not decoded is Dictionary:
		return
	game.load_state(decoded as Dictionary)
	assert_eq(game.save_state(), snapshot)
	var state := DeductionCaseworkCaseState.from_dict(decoded)
	assert_not_null(state)
	if state != null:
		assert_eq(state.to_dict().keys(), SAVE_KEYS)
		assert_true(SaveService.is_json_safe(state.to_dict()))
		assert_eq(DeductionSaveAdapter.decode(DeductionSaveAdapter.encode(state)), snapshot)
	assert_eq(game.migrate_save(0, snapshot), snapshot)
	assert_true(SaveService.is_json_safe(game.migrate_save(0, {"active_case_id": 42, "route_state": 7})))
	var catalog := _authored_catalog()
	game.load_state(_chain_state(catalog, 6))
	var twelve := game.save_state()
	assert_eq(twelve.keys(), SAVE_KEYS)
	assert_true(SaveService.is_json_safe(twelve))
	assert_eq(_strings(twelve["case_progress_by_id"].keys()), _strings(CASE_IDS))
	assert_eq(String(twelve["active_case_id"]), String(CASE_IDS[6]))
	assert_eq(String(twelve["last_case_id"]), String(CASE_IDS[6]))
	assert_eq(_strings(twelve["route_state"]["reviewed_case_ids"]), _strings(CASE_IDS.slice(0, 6)))
	assert_eq(_strings(twelve["route_state"]["unlocked_case_ids"]), _strings(CASE_IDS.slice(1, 7)))
	for index: int in range(CASE_IDS.size()):
		var case_id := CASE_IDS[index]
		var definition := catalog.get_definition(case_id)
		var progress: Dictionary = twelve["case_progress_by_id"][String(case_id)]
		assert_eq(String(progress["case_id"]), String(case_id))
		assert_eq(String(progress["current_scene_id"]), String(definition.start_scene_id))
		assert_eq(_strings(progress["visited_scene_ids"]), [String(definition.start_scene_id)])
		assert_eq(String(progress["status"]), String(
			DeductionCaseProgress.STATUS_REVIEWED if index < 6 else DeductionCaseProgress.STATUS_OPEN))
		assert_eq(_strings(progress["unlocked_hint_ids"]), [String(definition.hints[0].id)])
	for key: String in TRANSIENT_KEYS:
		assert_false(twelve.has(key))
	var reloaded: Variant = JSON.parse_string(JSON.stringify(twelve))
	assert_true(reloaded is Dictionary)
	if reloaded is Dictionary:
		game.load_state(reloaded as Dictionary)
		assert_eq(game.save_state(), twelve)
	await get_tree().process_frame
	await get_tree().process_frame


func test_stale_and_malformed_state_loads_to_a_safe_catalog_state() -> void:
	var malformed := {
		"schema_version": 999,
		"active_case_id": String(LEGACY_MODULE_ID),
		"last_case_id": "missing_case",
		"case_progress_by_id": {
			String(LEGACY_MODULE_ID): {"story": "old prototype", "score": NAN, "engine": Vector2.ONE},
			"missing_case": {"visited_scene_ids": ["legacy_scene", Vector3.ONE, INF]},
			42: {"ignored": true}
		},
		"route_state": {
			"unlocked_case_ids": [String(LEGACY_MODULE_ID), "missing_case", 42],
			"reviewed_case_ids": ["missing_case"]
		},
		"focus_id": "focus_probe",
		"hover_id": "hover_probe",
		"dragged_entity_id": "ent_missing",
		"animation_progress": 0.5
	}
	assert_null(DeductionCaseworkCaseState.from_dict(malformed))
	var game := _spawn()
	var migrated := game.migrate_save(0, malformed)
	assert_eq(migrated.keys(), SAVE_KEYS)
	assert_true(SaveService.is_json_safe(migrated))
	game.load_state(malformed)
	var clean := game.save_state()
	assert_true(SaveService.is_json_safe(clean))
	assert_eq(clean, _fresh_state())
	for key: String in TRANSIENT_KEYS:
		assert_false(clean.has(key))
	var catalog := _authored_catalog()
	var stale := DeductionCaseProgression.initial_progress(DeductionContentLoader.load_case(CASE_ID)).to_dict()
	stale["current_scene_id"] = "scene_removed"
	stale["visited_scene_ids"] = ["scene_removed", "scene_booth"]
	stale["discovered_entity_ids"] = ["ent_not_authored", "ent_person_mira"]
	stale["revealed_panel_ids"] = ["panel_not_authored", MAIN_PANEL_ID]
	stale["unlocked_hint_ids"] = ["hint_not_authored"]
	stale["status"] = "reviewed"
	var runtime := _new_runtime(catalog, {
		"schema_version": 1,
		"active_case_id": "missing_case",
		"last_case_id": String(CASE_ID),
		"case_progress_by_id": {
			String(CASE_ID): stale,
			"legacy_case": {"story": "discard"}
		},
		"route_state": {
			"unlocked_case_ids": [String(CASE_ID), "legacy_case"],
			"reviewed_case_ids": ["legacy_case"]
		}
	})
	var filtered := runtime.save_state().to_dict()
	assert_eq(filtered.keys(), SAVE_KEYS)
	assert_true(SaveService.is_json_safe(filtered))
	assert_eq(String(filtered["active_case_id"]), String(CASE_ID))
	assert_eq(String(filtered["last_case_id"]), String(CASE_ID))
	assert_eq(_strings(filtered["case_progress_by_id"].keys()), [String(CASE_ID)])
	assert_eq(_strings(filtered["route_state"]["unlocked_case_ids"]), [String(CASE_ID)])
	assert_eq(_strings(filtered["route_state"]["reviewed_case_ids"]), [])
	var filtered_progress: Dictionary = filtered["case_progress_by_id"][CASE_ID]
	assert_eq(String(filtered_progress["case_id"]), String(CASE_ID))
	assert_eq(String(filtered_progress["current_scene_id"]), START_SCENE_ID)
	assert_eq(String(filtered_progress["status"]), String(DeductionCaseProgress.STATUS_OPEN))
	assert_true(filtered_progress["panel_status"] is Dictionary)
	var definition := DeductionContentLoader.load_case(CASE_ID)
	assert_not_null(definition)
	if definition != null:
		for scene_id: String in _strings(filtered_progress["visited_scene_ids"]):
			assert_true(definition.has_scene(StringName(scene_id)), "%s is not an authored scene" % scene_id)
		for entity_id: String in _strings(filtered_progress["discovered_entity_ids"]):
			assert_true(definition.has_entity(StringName(entity_id)), "%s is not an authored entity" % entity_id)
		for panel_id: String in _strings(filtered_progress["revealed_panel_ids"]):
			assert_true(definition.has_panel(StringName(panel_id)), "%s is not an authored panel" % panel_id)
		for hint_id: String in _strings(filtered_progress["unlocked_hint_ids"]):
			assert_true(definition.has_hint(StringName(hint_id)), "%s is not an authored hint" % hint_id)
	assert_eq(String(runtime.snapshot()["focus_id"]), START_FOCUS_ID)
	assert_eq(String(runtime.snapshot()["scene_id"]), START_SCENE_ID)
	for key: String in TRANSIENT_KEYS:
		assert_false(filtered.has(key))
	var twelve := _chain_state(catalog, 6)
	twelve["case_progress_by_id"][String(LEGACY_MODULE_ID)] = {"story": "old prototype"}
	twelve["case_progress_by_id"]["case_13_missing_axiom"] = {"visited_scene_ids": ["scene_removed"]}
	twelve["route_state"]["unlocked_case_ids"].append("case_13_missing_axiom")
	twelve["route_state"]["unlocked_case_ids"].append(String(LEGACY_MODULE_ID))
	twelve["route_state"]["reviewed_case_ids"].append("case_13_missing_axiom")
	twelve["route_state"]["reviewed_case_ids"].append(String(LEGACY_MODULE_ID))
	var kept := _new_runtime(catalog, twelve).save_state().to_dict()
	assert_eq(_strings(kept["case_progress_by_id"].keys()), _strings(CASE_IDS))
	assert_eq(_strings(kept["route_state"]["reviewed_case_ids"]), _strings(CASE_IDS.slice(0, 6)))
	assert_eq(_strings(kept["route_state"]["unlocked_case_ids"]), _strings(CASE_IDS.slice(1, 7)))
	assert_eq(String(kept["active_case_id"]), String(CASE_IDS[6]))
	assert_eq(String(kept["last_case_id"]), String(CASE_IDS[6]))
	assert_true(SaveService.is_json_safe(kept))
	await get_tree().process_frame
	await get_tree().process_frame


func test_reset_requires_confirmation_and_clears_only_the_active_case() -> void:
	var game := _spawn()
	if game == null:
		return
	var catalog := _authored_catalog()
	game.runtime = _new_runtime(catalog, _chain_state(catalog, 6))
	game.call("_bind_presentation")
	var runtime := game.get("runtime") as DeductionCaseRuntime
	assert_not_null(runtime)
	if runtime == null:
		return
	var active := CASE_IDS[6]
	var definition := runtime.definition
	assert_eq(String(definition.id), String(active))
	var start_scene := definition.get_scene(definition.start_scene_id)
	assert_not_null(start_scene)
	if start_scene == null:
		return
	assert_false(start_scene.transitions.is_empty())
	var walked := runtime.dispatch(&"interact", {"target_id": String(start_scene.transitions[0].id)})
	assert_true(bool(walked.get("accepted", false)))
	var before := game.save_state()
	assert_ne(String(before["case_progress_by_id"][String(active)]["current_scene_id"]),
		String(definition.start_scene_id))
	assert_eq(_strings(before["case_progress_by_id"][String(active)]["visited_scene_ids"]).size(), 2)
	assert_false(game.execute_command(&"reset_confirm"))
	assert_eq(game.save_state(), before)
	assert_false(game.execute_command(&"unknown"))
	assert_eq(game.save_state(), before)
	assert_true(game.execute_command(&"reset"))
	assert_eq(game.save_state(), before)
	assert_true(bool(runtime.snapshot()["reset_pending"]))
	assert_true(game.execute_command(&"reset_confirm"))
	var after := game.save_state()
	assert_eq(_strings(after["case_progress_by_id"].keys()), _strings(CASE_IDS))
	assert_eq(after["case_progress_by_id"][String(active)],
		DeductionCaseProgression.initial_progress(definition).to_dict())
	for case_id: StringName in CASE_IDS:
		if case_id == active:
			continue
		assert_eq(after["case_progress_by_id"][String(case_id)], before["case_progress_by_id"][String(case_id)],
			"%s must be untouched" % case_id)
	assert_eq(String(after["active_case_id"]), String(active))
	assert_eq(String(after["last_case_id"]), String(active))
	assert_eq(after["route_state"], before["route_state"])
	assert_eq(String(runtime.snapshot()["scene_id"]), String(definition.start_scene_id))
	assert_eq(String(runtime.snapshot()["focus_id"]), String(start_scene.start_focus_id))
	assert_true(SaveService.is_json_safe(after))
	assert_false(bool(runtime.snapshot()["reset_pending"]))
	assert_false(game.execute_command(&"reset_confirm"))
	assert_eq(game.save_state(), after)
	await get_tree().process_frame
	await get_tree().process_frame


func _spawn() -> GameModule:
	var packed := load(ENTRY_SCENE) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var game := packed.instantiate() as GameModule
	assert_not_null(game)
	if game == null:
		return null
	var context := ModuleContext.new()
	context.module_id = MODULE_ID
	context.input_enabled = true
	for action: String in EXPECTED_ACTIONS:
		var action_id := StringName(action)
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)
			_owned_actions.append(action_id)
		context.allowed_actions.append(action_id)
	game.context = context
	add_child_autofree(game)
	game.load_state({})
	game.enter(context)
	return game


func _authored_catalog() -> DeductionContentLoader.CaseCatalog:
	return DeductionContentLoader.load_catalog()


func _new_runtime(catalog: DeductionContentLoader.CaseCatalog, data: Dictionary) -> DeductionCaseRuntime:
	var state := DeductionSaveAdapter.sanitize(catalog, data)
	assert_true(SaveService.is_json_safe(state.to_dict()))
	var runtime := DeductionCaseRuntime.new()
	runtime.load(catalog, state)
	return runtime


func _case_document(case_id: StringName = CASE_ID) -> Dictionary:
	var path: String = CASE_PATH if case_id == CASE_ID \
		else CONTENT_DIRECTORY.path_join("%s/%s.json" % [CASES_DIRECTORY, String(case_id)])
	var document: Variant = DeductionContentValidator.parse_json_document(
		FileAccess.get_file_as_string(path)
	)
	assert_true(document is Dictionary, "%s is readable" % path)
	if not document is Dictionary:
		return {}
	var copy: Dictionary = (document as Dictionary).duplicate(true)
	copy["id"] = String(case_id)
	return copy


func _chain_state(
	catalog: DeductionContentLoader.CaseCatalog, reviewed_count: int
) -> Dictionary:
	var case_ids := catalog.list_case_ids()
	var progress_by_id: Dictionary = {}
	var unlocked: Array[String] = []
	var reviewed: Array[String] = []
	for index: int in range(case_ids.size()):
		var case_id := case_ids[index]
		var definition := catalog.get_definition(case_id)
		var progress := DeductionCaseProgression.initial_progress(definition)
		if index < reviewed_count:
			progress.reviewed = true
			progress.status = DeductionCaseProgress.STATUS_REVIEWED
			reviewed.append(String(case_id))
			if index + 1 < case_ids.size():
				unlocked.append(String(case_ids[index + 1]))
		if definition != null and not definition.hints.is_empty():
			progress.unlocked_hint_ids.append(definition.hints[0].id)
		progress_by_id[String(case_id)] = progress.to_dict()
	var active_index := clampi(reviewed_count, 0, case_ids.size() - 1)
	return {
		"schema_version": DeductionCaseworkCaseState.SCHEMA_VERSION,
		"active_case_id": String(case_ids[active_index]),
		"last_case_id": String(case_ids[active_index]),
		"case_progress_by_id": progress_by_id,
		"route_state": {"unlocked_case_ids": unlocked, "reviewed_case_ids": reviewed}
	}


func _fresh_state() -> Dictionary:
	return {
		"schema_version": DeductionCaseworkCaseState.SCHEMA_VERSION,
		"active_case_id": String(CASE_ID),
		"last_case_id": String(CASE_ID),
		"case_progress_by_id": {
			String(CASE_ID): DeductionCaseProgression.initial_progress(
				DeductionContentLoader.load_case(CASE_ID)).to_dict()
		},
		"route_state": {"unlocked_case_ids": [], "reviewed_case_ids": []}
	}


func _main_solution(
	definition: DeductionCaseworkCaseDefinition
) -> DeductionCaseworkCaseDefinition.SolutionDefinition:
	if definition == null or definition.review == null:
		return null
	for solution: DeductionCaseworkCaseDefinition.SolutionDefinition in definition.solutions:
		if solution.completion_review_id == definition.review.id:
			return solution
	return null


func _required_panel_ids(definition: DeductionCaseworkCaseDefinition) -> Array:
	var result: Array = []
	if definition == null:
		return result
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		if panel.required_for_completion:
			result.append(String(panel.id))
	return result


func _panel_ids(definition: DeductionCaseworkCaseDefinition) -> Array:
	var result: Array = []
	if definition == null:
		return result
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		result.append(String(panel.id))
	return result


func _hotspot_ids(hotspots: Array) -> Array:
	var result: Array = []
	for hotspot: DeductionCaseworkCaseDefinition.HotspotDefinition in hotspots:
		result.append(String(hotspot.id))
	return result


func _solve_active_case(runtime: DeductionCaseRuntime) -> void:
	var definition := runtime.definition
	assert_not_null(definition)
	if definition == null or runtime.progress == null:
		return
	var solved_ids := DeductionCaseProgression.solved_case_ids(runtime.case_state)
	var progress := runtime.progress
	for _pass: int in range(definition.messages.size() + 1):
		var changed := false
		for message: DeductionCaseworkCaseDefinition.MessageDefinition in definition.messages:
			if progress.resolved_message_ids.has(message.id):
				continue
			var resolved := DeductionMessageResolver.resolve(definition, progress, message.id, solved_ids)
			if bool(resolved.get("changed", false)):
				changed = true
		if not changed:
			break
	var main := _main_solution(definition)
	assert_not_null(main, "%s exposes a review-linked main solution" % definition.id)
	if main == null:
		return
	for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in main.required_assignments:
		var assigned := DeductionPanelWorkspace.assign(
			definition, progress, main.panel_id, assignment.entity_id, assignment.slot_id, solved_ids)
		assert_true(bool(assigned.get("accepted", false)),
			"%s accepts %s into %s" % [definition.id, assignment.entity_id, assignment.slot_id])
	runtime.case_state.case_progress_by_id[String(definition.id)] = progress.to_dict()


func _boxes(grid: GridContainer) -> Array[Control]:
	var result: Array[Control] = []
	if grid == null:
		return result
	for child: Node in grid.get_children():
		var box := child as Control
		if box != null and box.has_meta(&"box_id"):
			result.append(box)
	return result


func _target_grid(mounted: DeductionAuthoredCaseScene) -> GridContainer:
	return mounted.get_node_or_null("%TargetGrid") as GridContainer if mounted != null else null


func _step(runtime: DeductionCaseRuntime, intent: StringName, payload: Dictionary = {}) -> Dictionary:
	var result := runtime.dispatch(intent, payload)
	await get_tree().process_frame
	return result


func _box_by_id(boxes: Array[Control], box_id: String) -> Control:
	for box: Control in boxes:
		if String(box.get_meta(&"box_id")) == box_id:
			return box
	return null


func _strings(values: Array) -> Array:
	var result: Array = []
	for value: Variant in values:
		result.append(String(value))
	return result
