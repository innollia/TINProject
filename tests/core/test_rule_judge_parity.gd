extends GutTest

# The board judge in tools/rule_judge copies the module's state-affecting turn.
# This test is the only thing that catches the two from diverging, so it pins the
# copy against the real module turn by turn. If the module's turn order, limits or
# rule-resolution loop ever change, this fails instead of the judge quietly
# reporting numbers that no longer describe the game.

const TurnSim = preload("res://tools/rule_judge/turn_sim.gd")
const ENTRY_SCENE: String = "res://modules/rule_rewriting/entry.tscn"
const TURNS_PER_BOARD: int = 16
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const PARITY_BOARDS: Array[StringName] = [
	&"rule_01_open_gate", &"rule_02_shift_win", &"rule_03_pit_and_chain",
	&"rule_04_second_runner", &"rule_05_word_seed", &"rule_06_key_from_risk",
	&"rule_07_moving_gate", &"rule_08_safe_crossing", &"rule_09_first_metrix",
	&"rule_10_shared_frames", &"rule_11_metrix_storage", &"rule_12_wall_alignment",
	&"rule_13_hotbar_phrase", &"rule_15_relay", &"rule_16_overlap_rules"
]

var _seed: int = 0


func before_each() -> void:
	_seed = 0


func test_turn_simulator_reproduces_the_module_turn_for_every_board() -> void:
	for board_id: StringName in PARITY_BOARDS:
		await _compare_board(board_id)


func _compare_board(board_id: StringName) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level.get("ok", false), "could not load %s" % board_id)
	var game := _spawn()
	await _load_board(game, board_id)
	var sim_state: RuleGridState = level["state"]
	var sim_turn := 0
	var sim_solved := false
	var sim_failed := false
	var turns: int = TURNS_PER_BOARD
	for turn: int in range(turns):
		var direction := _next_direction()
		var accepted: bool = game.execute_command(&"move", {"direction": direction})
		var result := TurnSim.step(sim_state, direction, sim_turn, sim_solved, sim_failed)
		var next_state: RuleGridState = result["state"]
		var module_state: RuleGridState = game.get("grid_state")
		var label: String = "%s turn %d input=%s module_accepted=%s sim_path=%s" % [board_id, turn, direction, accepted, String(result["path"])]
		var diff := _entity_diff(next_state, module_state)
		assert_true(diff.is_empty(), "physical state diverged at %s | %s" % [label, diff])
		assert_eq(
			TurnSim.rule_resolution_signature(result["rules"]),
			TurnSim.rule_resolution_signature(game.get("rule_set")),
			"active rules diverged at %s" % label
		)
		assert_eq(int(result["turn_index"]), int(game.get("turn_index")), "turn_index diverged at %s" % label)
		assert_eq(bool(result["solved"]), bool(game.get("solved")), "solved diverged at %s" % label)
		assert_eq(bool(result["failed"]), bool(game.get("failed")), "failed diverged at %s" % label)
		sim_state = next_state
		sim_turn = int(result["turn_index"])
		sim_solved = bool(result["solved"])
		sim_failed = bool(result["failed"])
		if sim_solved or sim_failed:
			break


func _entity_diff(left: RuleGridState, right: RuleGridState) -> String:
	var right_by_id: Dictionary = {}
	for entity: RuleGridEntity in right.entities:
		right_by_id[entity.id] = entity
	var notes: Array[String] = []
	for entity: RuleGridEntity in left.entities:
		var other: RuleGridEntity = right_by_id.get(entity.id)
		if other == null:
			notes.append("%s missing in module" % entity.id)
			continue
		if entity.position != other.position or entity.facing != other.facing:
			notes.append("%s sim(%d,%d f%d,%d) module(%d,%d f%d,%d)" % [
				entity.id, entity.position.x, entity.position.y, entity.facing.x, entity.facing.y,
				other.position.x, other.position.y, other.facing.x, other.facing.y
			])
		if entity.creation_serial != other.creation_serial:
			notes.append("%s serial sim %d module %d" % [entity.id, entity.creation_serial, other.creation_serial])
	for entity: RuleGridEntity in right.entities:
		if not _has_id(left, entity.id):
			notes.append("%s extra in module" % entity.id)
	return "; ".join(notes)


func _has_id(state: RuleGridState, entity_id: String) -> bool:
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return true
	return false


func test_simulator_reads_the_module_limits_instead_of_copying_them() -> void:
	var values := TurnSim.limits()
	assert_false(values.is_empty(), "module constant map is empty")
	assert_true(values.has("MAX_CONTACT_PASSES") or values.has(&"MAX_CONTACT_PASSES"))
	assert_true(values.has("MAX_WORD_FIXED_POINT_STEPS") or values.has(&"MAX_WORD_FIXED_POINT_STEPS"))


func _next_direction() -> Vector2i:
	_seed = (_seed * 1103515245 + 12345) & 0x7fffffff
	return DIRECTIONS[(_seed >> 8) % DIRECTIONS.size()]


func _spawn() -> GameModule:
	var packed := load(ENTRY_SCENE) as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"rule_rewriting"
	injected.input_enabled = true
	for suffix: String in ["left", "right", "up", "down", "confirm", "cancel", "undo", "reset"]:
		injected.allowed_actions.append(StringName("rule_rewriting_%s" % suffix))
	game.context = injected
	add_child_autofree(game)
	return game


func _load_board(game: GameModule, board_id: StringName) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	var state: Dictionary = game.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	state["solved"] = false
	state["failed"] = false
	state["turn_index"] = 0
	state["completed_board_ids"] = []
	state["undo_stack"] = []
	game.load_state(state)
	await get_tree().process_frame
