extends GutTest

const Selector = preload("res://modules/physics_puzzle_platformer/systems/selector.gd")
const SaveCodec = preload("res://modules/physics_puzzle_platformer/domain/save_codec.gd")
const RunState = preload("res://modules/physics_puzzle_platformer/domain/run_state.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const SELECTOR_PATH: String = "res://modules/physics_puzzle_platformer/systems/selector.gd"
const LEVELS: Array[String] = ["lv_a", "lv_b", "lv_c", "lv_d", "lv_e", "lv_f", "lv_g", "lv_h"]
const TOOLS: Array[String] = ["tl_a", "tl_b", "tl_c", "tl_d", "tl_e", "tl_f"]


func _mutable() -> Dictionary:
	var result: Dictionary = {}
	for level_id: String in LEVELS:
		result[level_id] = ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"]
	return result


func _build(run_seed: int) -> Dictionary:
	return Selector.build(run_seed, LEVELS, TOOLS, _mutable())


func test_same_seed_same_sequence() -> void:
	for run_seed: int in range(1, 101):
		assert_eq(JSON.stringify(_build(run_seed)), JSON.stringify(_build(run_seed)), "seed %d" % run_seed)


func test_different_seed_different_sequence() -> void:
	var differing: int = 0
	for pair: int in 1000:
		var first: Dictionary = _build(pair * 2 + 1)
		var second: Dictionary = _build(pair * 2 + 2)
		if JSON.stringify(first) != JSON.stringify(second):
			differing += 1
	assert_gte(differing, 995)


func test_sequence_length_is_eight() -> void:
	for run_seed: int in range(1, 200):
		assert_eq((_build(run_seed)["sequence"] as Array).size(), Tuning.LEVEL_COUNT)


func test_tools_length_is_eight() -> void:
	for run_seed: int in range(1, 200):
		assert_eq((_build(run_seed)["tool_ids"] as Array).size(), Tuning.TOOL_COUNT)


func test_indices_within_registry() -> void:
	for run_seed: int in range(1, 300):
		var built: Dictionary = _build(run_seed)
		for entry: Dictionary in built["sequence"]:
			assert_true(LEVELS.has(String(entry["level_id"])))
		for tool_id: String in built["tool_ids"]:
			assert_true(TOOLS.has(tool_id))


func test_repeats_are_not_suppressed() -> void:
	var stream: Array[String] = []
	var run_seed: int = 1
	while stream.size() < 20000:
		for entry: Dictionary in _build(run_seed)["sequence"]:
			stream.append(String(entry["level_id"]))
		run_seed += 1
	var longest: int = 1
	var current: int = 1
	for index: int in range(1, stream.size()):
		current = current + 1 if stream[index] == stream[index - 1] else 1
		longest = maxi(longest, current)
	assert_gte(longest, 5, "five identical draws in a row happen at least once")
	var repeats_inside_runs: int = 0
	for seed_value: int in range(1, 2001):
		var ids: Array = []
		for entry: Dictionary in _build(seed_value)["sequence"]:
			ids.append(entry["level_id"])
		for index: int in range(1, ids.size()):
			if ids[index] == ids[index - 1]:
				repeats_inside_runs += 1
	assert_gt(repeats_inside_runs, 0, "a level can follow itself inside one run")


func _strip_comments(text: String) -> String:
	var lines: PackedStringArray = []
	for line: String in text.split("\n"):
		var cut: int = line.find("#")
		lines.append(line.substr(0, cut) if cut >= 0 else line)
	return "\n".join(lines)


func test_no_duplicate_suppression_code() -> void:
	var text: String = _strip_comments(FileAccess.get_file_as_string(SELECTOR_PATH)).to_lower()
	for token: String in ["last_", "seen", "weight", "pity"]:
		assert_eq(text.find(token), -1, "selector has no '%s'" % token)


func test_selector_never_reads_levels_seen() -> void:
	var run := RunState.new()
	var before: String = JSON.stringify(_build(77))
	run.levels_seen = {"lv_a": 40, "lv_b": 1}
	for level_id: String in LEVELS:
		run.levels_seen[level_id] = 999
	assert_eq(JSON.stringify(_build(77)), before)
	var text: String = FileAccess.get_file_as_string(SELECTOR_PATH)
	assert_eq(text.find("levels_seen"), -1)
	assert_eq(text.find("tools_seen"), -1)


func test_selector_ignores_cosmetic_rng() -> void:
	var before: String = JSON.stringify(_build(4242))
	var cosmetic := RandomNumberGenerator.new()
	cosmetic.seed = RunState.cosmetic_seed(4242)
	for _draw: int in 1000:
		cosmetic.randf()
	assert_eq(JSON.stringify(_build(4242)), before)


func test_mutation_chance_within_bounds() -> void:
	var slots: int = 0
	var mutated: int = 0
	for run_seed: int in range(1, 10001):
		for entry: Dictionary in _build(run_seed)["sequence"]:
			slots += 1
			if not (entry["mutations"] as Array).is_empty():
				mutated += 1
	var ratio: float = float(mutated) / float(slots)
	assert_between(ratio, 0.55, 0.70)


func test_mutation_max_two() -> void:
	for run_seed: int in range(1, 3000):
		for entry: Dictionary in _build(run_seed)["sequence"]:
			assert_lte((entry["mutations"] as Array).size(), Tuning.MUTATION_MAX)


func _saved_run(run_seed: int) -> Dictionary:
	var run := RunState.new()
	run.run_seed = run_seed
	run.run_index = 1
	var built: Dictionary = _build(run_seed)
	run.sequence = built["sequence"]
	run.tool_ids = built["tool_ids"]
	return SaveCodec.encode(run, null)


func test_selector_reassigns_removed_level() -> void:
	var saved: Dictionary = _saved_run(9001)
	var original: Array = saved["run"]["sequence"].duplicate(true)
	saved["run"]["sequence"][3]["level_id"] = "lv_removed"
	var decoded: Dictionary = SaveCodec.decode(saved, LEVELS, TOOLS)
	assert_false(bool(decoded["resequence"]))
	assert_eq(decoded["reassign_slots"], [3])
	var run: RefCounted = decoded["run"]
	for slot: int in decoded["reassign_slots"]:
		run.sequence[slot] = Selector.reassign_level(run.run_seed, slot, LEVELS, _mutable())
	for index: int in Tuning.LEVEL_COUNT:
		if index == 3:
			assert_true(LEVELS.has(String(run.sequence[index]["level_id"])), "slot 3 was drawn again from the registry")
		else:
			assert_eq(JSON.stringify(run.sequence[index]), JSON.stringify(original[index]), "slot %d kept" % index)
	var again: Dictionary = Selector.reassign_level(run.run_seed, 3, LEVELS, _mutable())
	assert_eq(JSON.stringify(again), JSON.stringify(run.sequence[3]), "the redraw is deterministic")


func test_invalid_seed_resequences_everything() -> void:
	for bad: Variant in [0, -5, 2147483648, 1.5, "12", null]:
		var saved: Dictionary = _saved_run(123)
		saved["run"]["run_seed"] = bad
		saved["run"]["cursor"] = 5
		var decoded: Dictionary = SaveCodec.decode(saved, LEVELS, TOOLS)
		assert_true(bool(decoded["resequence"]), "seed %s forces a new sequence" % str(bad))
		assert_eq(decoded["run"].cursor, 0)
		assert_true(decoded["run"].sequence.is_empty())


func test_save_load_preserves_sequence() -> void:
	var saved: Dictionary = _saved_run(55555)
	var text: String = JSON.stringify(saved["run"]["sequence"])
	var parsed: Variant = JSON.parse_string(JSON.stringify(saved))
	var decoded: Dictionary = SaveCodec.decode(parsed, LEVELS, TOOLS)
	assert_false(bool(decoded["resequence"]))
	var again: Dictionary = SaveCodec.encode(decoded["run"], null)
	assert_eq(JSON.stringify(again["run"]["sequence"]), text)
	assert_eq(JSON.stringify(again["run"]["tool_ids"]), JSON.stringify(saved["run"]["tool_ids"]))
