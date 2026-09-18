extends GutTest

func test_empty_context_blocks_input() -> void:
	var context := ModuleContext.new()
	assert_false(context.input_enabled)
	assert_false(context.is_action_pressed(&"unknown"))
	assert_eq(context.get_axis(&"negative", &"positive"), 0.0)

func test_save_snapshots_are_detached() -> void:
	var saves := SaveService.new()
	add_child_autofree(saves)
	var state: Dictionary = {"nested": {"value": 7}}
	saves.set_module_state(&"fixture", 1, state)
	state["nested"]["value"] = 8
	assert_eq(saves.get_module_state(&"fixture")["state"]["nested"]["value"], 7)
	var exported: Dictionary = saves.export_data()
	exported["modules"]["fixture"]["state"]["nested"]["value"] = 9
	assert_eq(saves.get_module_state(&"fixture")["state"]["nested"]["value"], 7)

func test_invalid_envelope_retains_state() -> void:
	var saves := SaveService.new()
	add_child_autofree(saves)
	saves.global_state = {"kept": true}
	var before: Dictionary = saves.export_data()
	assert_eq(saves.import_data({}), ERR_INVALID_DATA)
	assert_eq(saves.export_data(), before)

func test_json_state_rejects_engine_objects() -> void:
	assert_false(SaveService.is_json_safe({"position": Vector3.ONE}))
	assert_false(SaveService.is_json_safe({"number": NAN}))
	assert_true(SaveService.is_json_safe({"x": 1.0, "flags": [true, null]}))

func test_default_migration_copies_state() -> void:
	var module := GameModule.new()
	add_child_autofree(module)
	var state: Dictionary = {"nested": {"value": 1}}
	var migrated: Dictionary = module.migrate_save(1, state)
	migrated["nested"]["value"] = 2
	assert_eq(state["nested"]["value"], 1)
	assert_false(module.execute_command(&"unknown"))
