extends SceneTree

# Board judge: layered breadth-first search over a Rule Rewrite board, reporting how
# many distinct solutions appear at each turn depth. A curve that stays at zero for a
# long time and then produces a few specific solutions is a shaped puzzle; a curve that
# explodes as depth grows is not, because the player stumbles into a win.
#
# Run:  godot --headless --path . --script res://tools/rule_judge/judge.gd -- <boards> <max_nodes> <max_depth> [flags]
# <boards> is one board ID, a comma-separated list, or "all" (the default) for every
# board in content/index.json.
#
# Flags:
#   --frozen    also search with every rule change forbidden. COMPLETE with no win is
#               proof that the board cannot be solved without changing a rule.
#   --required  declared_rule_required: for each initial rule, search again with that
#               rule removed from every parse, and classify what the rule does.
#   --out       write the measurement to docs/research/rule_rewrite/judge/<board>.json.
#   --full      all three.
#
# When the node budget runs out the curve stops and the board is reported UNRESOLVED
# past that depth. Budgeted counts are never presented as totals, and no solution
# within budget is never presented as proof of unsolvability.

const TurnSim = preload("res://tools/rule_judge/turn_sim.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const DIRECTION_GLYPHS: Dictionary = {
	Vector2i.UP: "U", Vector2i.RIGHT: "R", Vector2i.DOWN: "D", Vector2i.LEFT: "L"
}
const DEFAULT_MAX_NODES: int = 60000
const DEFAULT_MAX_DEPTH: int = 20
const OUTPUT_DIRECTORY: String = "res://docs/research/rule_rewrite/judge"
const REPORT_SCHEMA_VERSION: int = 1


func _initialize() -> void:
	var positional: Array[String] = []
	var flags: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			flags[arg.substr(2)] = true
		else:
			positional.append(arg)
	var filter: Dictionary = {}
	if positional.size() > 0 and positional[0] != "all" and not positional[0].is_empty():
		for board_id: String in positional[0].split(",", false):
			filter[board_id.strip_edges()] = true
	var max_nodes: int = int(positional[1]) if positional.size() > 1 else DEFAULT_MAX_NODES
	var max_depth: int = int(positional[2]) if positional.size() > 2 else DEFAULT_MAX_DEPTH
	var full := flags.has("full")
	var options := {
		"frozen": full or flags.has("frozen"),
		"required": full or flags.has("required"),
		"out": full or flags.has("out")
	}
	for board_id: StringName in RuleLevelLoader.list_level_ids():
		if not filter.is_empty() and not filter.has(String(board_id)):
			continue
		var started := Time.get_ticks_msec()
		var report := _judge(board_id, max_nodes, max_depth, options)
		print("    elapsed_ms=%d" % (Time.get_ticks_msec() - started))
		if bool(options["out"]) and not report.is_empty():
			_write_report(board_id, report)
	quit(0)


func _judge(board_id: StringName, max_nodes: int, max_depth: int, options: Dictionary) -> Dictionary:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		print("JUDGE %s UNLOADABLE %s" % [board_id, level.get("error", "")])
		return {}
	TurnSim.suppressed_meanings = {}
	var start: RuleGridState = level["state"]
	var start_rules := TurnSim.resolve_word_rules(start)
	var start_signature := TurnSim.rule_resolution_signature(start_rules)
	var occupancy := _occupancy(start)
	var reachable := _reachable(start, start_rules)
	print("=== %s  %dx%d  %s" % [board_id, start.width, start.height, level["title"]])
	print("    entities=%d words=%d  cells=%d non_wall_cells=%d  floor_ratio=%.2f  board_fill=%.2f" % [
		start.entities.size(), _word_count(start), start.width * start.height,
		occupancy["non_wall_cells"], occupancy["non_wall_ratio"], occupancy["fill_ratio"]
	])
	print("    initial_rules=%s" % str(_rule_texts(start_rules)))
	print("    reachable_by_walk=%d" % reachable)

	var search := _search(start, start_rules, start_signature, max_nodes, max_depth, false)
	_print_search(search, true)
	var report := {
		"schema_version": REPORT_SCHEMA_VERSION,
		"board_id": String(board_id),
		"title": String(level["title"]),
		"measured_on": Time.get_date_string_from_system(),
		"state_sha256": JSON.stringify(start.to_dictionary()).sha256_text(),
		"budget": {"max_nodes": max_nodes, "max_depth": max_depth},
		"board": {
			"width": start.width,
			"height": start.height,
			"entities": start.entities.size(),
			"words": _word_count(start),
			"non_wall_cells": occupancy["non_wall_cells"],
			"floor_ratio": snappedf(float(occupancy["non_wall_ratio"]), 0.001),
			"board_fill": snappedf(float(occupancy["fill_ratio"]), 0.001),
			"reachable_by_walk": reachable
		},
		"initial_rules": _rule_texts(start_rules),
		"search": _search_summary(search),
		"rules_frozen": null,
		"declared_rule_required": null
	}

	if bool(options["frozen"]):
		var frozen := _search(start, start_rules, start_signature, max_nodes, max_depth, true)
		var frozen_verdict := _frozen_verdict(frozen)
		print("    rules_frozen: %s nodes=%d depth_reached=%d%s" % [
			frozen_verdict, frozen["nodes"], frozen["depth_reached"],
			(" route=%s" % frozen["first_route"]) if bool(frozen["solved_any"]) else ""
		])
		var frozen_summary := _search_summary(frozen)
		frozen_summary["verdict"] = frozen_verdict
		report["rules_frozen"] = frozen_summary

	if bool(options["required"]):
		report["declared_rule_required"] = _declared_rule_required(start, start_rules, search, max_nodes, max_depth)
	TurnSim.suppressed_meanings = {}
	return report


# Removing one initial rule (every sentence with its meaning, on every parse) and
# searching again says what the rule does for the board:
#   REQUIRED            the board has no solution without it (COMPLETE search)
#   NO_SOLUTION_IN_BUDGET  none found, search not complete
#   OBSTACLE            the board gets shorter without it
#   NOT_NEEDED          the shortest solution length does not change
#   HELPS               still solvable without it, but only by a longer route
#   BASELINE_UNRESOLVED the unmodified board has no solution in budget to compare with
func _declared_rule_required(
	start: RuleGridState,
	start_rules: RuleSet,
	baseline: Dictionary,
	max_nodes: int,
	max_depth: int
) -> Array:
	var keys: Array[String] = []
	var labels: Dictionary = {}
	for sentence: RuleSentence in start_rules.sentences:
		var key := TurnSim.meaning_key(sentence)
		if labels.has(key):
			continue
		keys.append(key)
		labels[key] = _sentence_text(sentence)
	var results: Array = []
	var baseline_depth := int(baseline["first_solution_depth"])
	for key: String in keys:
		TurnSim.suppressed_meanings = {key: true}
		var rules := TurnSim.resolve_word_rules(start)
		var search := _search(start, rules, TurnSim.rule_resolution_signature(rules), max_nodes, max_depth, false)
		TurnSim.suppressed_meanings = {}
		var verdict := "NO_SOLUTION_IN_BUDGET"
		if bool(search["solved_any"]):
			var depth := int(search["first_solution_depth"])
			if baseline_depth < 0:
				verdict = "BASELINE_UNRESOLVED"
			elif depth < baseline_depth:
				verdict = "OBSTACLE"
			elif depth == baseline_depth:
				verdict = "NOT_NEEDED"
			else:
				verdict = "HELPS"
		elif bool(search["frontier_drained"]):
			verdict = "REQUIRED"
		print("    required[%s]: %s nodes=%d depth_reached=%d%s" % [
			labels[key], verdict, search["nodes"], search["depth_reached"],
			(" shortest=%d" % int(search["first_solution_depth"])) if bool(search["solved_any"]) else ""
		])
		results.append({
			"rule": labels[key],
			"verdict": verdict,
			"nodes": search["nodes"],
			"depth_reached": search["depth_reached"],
			"complete": search["frontier_drained"],
			"first_solution_depth": search["first_solution_depth"],
			"first_solution_route": search["first_route"]
		})
	return results


func _frozen_verdict(search: Dictionary) -> String:
	if bool(search["solved_any"]):
		return "SOLVABLE_WITHOUT_RULE_CHANGE"
	if bool(search["frontier_drained"]):
		return "RULE_CHANGE_REQUIRED"
	return "NO_UNCHANGED_SOLUTION_IN_BUDGET"


func _print_search(search: Dictionary, with_curve: bool) -> void:
	print("    nodes=%d depth_reached=%d %s" % [search["nodes"], search["depth_reached"], _verdict_text(search)])
	if with_curve:
		print("    depth  A_rule_traj  B_end_state  C_move_path   cumulative_A")
		var cumulative := 0
		for depth: int in range(int(search["depth_reached"]) + 1):
			cumulative += int(search["curve_a"][depth])
			print("    %5d  %11d  %12d  %10d  %13d" % [
				depth, int(search["curve_a"][depth]), int(search["curve_b"][depth]),
				int(search["curve_c"][depth]), cumulative
			])
	if not bool(search["solved_any"]):
		print("    NO_SOLUTION_WITHIN_BUDGET")
		return
	print("    first_solution_depth=%d rule_changes=%d route=%s" % [
		int(search["first_solution_depth"]), int(search["first_rule_changes"]), search["first_route"]
	])
	print("    growth_verdict=%s" % _growth_verdict(search["curve_a"], search["depth_reached"]))
	print("    sample_routes=%s" % str(search["sample_routes"].slice(0, 3)))


func _verdict_text(search: Dictionary) -> String:
	if bool(search["frontier_drained"]):
		return "COMPLETE (whole reachable state space enumerated)"
	if bool(search["budget_exhausted"]):
		return "UNRESOLVED (node budget exhausted; absence here is not proof of unsolvability)"
	return "UNRESOLVED (depth cap reached; absence here is not proof of unsolvability)"


func _search_summary(search: Dictionary) -> Dictionary:
	var verdict := "UNRESOLVED_DEPTH"
	if bool(search["frontier_drained"]):
		verdict = "COMPLETE"
	elif bool(search["budget_exhausted"]):
		verdict = "UNRESOLVED_BUDGET"
	var depth_count := int(search["depth_reached"]) + 1
	return {
		"verdict": verdict,
		"nodes": search["nodes"],
		"depth_reached": search["depth_reached"],
		"solved": search["solved_any"],
		"first_solution_depth": search["first_solution_depth"],
		"first_solution_route": search["first_route"],
		"first_solution_rule_changes": search["first_rule_changes"],
		"growth": _growth_verdict(search["curve_a"], search["depth_reached"]) if bool(search["solved_any"]) else "",
		"curve_rule_trajectories": search["curve_a"].slice(0, depth_count),
		"curve_end_states": search["curve_b"].slice(0, depth_count),
		"curve_move_paths": search["curve_c"].slice(0, depth_count),
		"sample_routes": search["sample_routes"]
	}


# frozen=true forbids every transition that changes the active rule signature,
# including the winning one.
func _search(
	start: RuleGridState,
	start_rules: RuleSet,
	start_signature: String,
	max_nodes: int,
	max_depth: int,
	frozen: bool
) -> Dictionary:
	var curve_a: Array[int] = []
	var curve_b: Array[int] = []
	var curve_c: Array[int] = []
	var seen: Dictionary = {}
	var sol_a: Dictionary = {}
	var sol_b: Dictionary = {}
	var sol_c: Dictionary = {}
	var signature_ids: Dictionary = {start_signature: 0}
	var sample_routes: Array[String] = []
	var nodes := 0
	var depth_reached := 0
	var solved_any := false
	var first_solution_depth := -1
	var first_route := ""
	var first_rule_changes := -1
	var exhausted := false
	var drained := false

	curve_a.resize(max_depth + 1)
	curve_b.resize(max_depth + 1)
	curve_c.resize(max_depth + 1)
	var frontier: Array[Dictionary] = [{
		"state": start,
		"rules": start_rules,
		"signature": start_signature,
		"turn": 0,
		"solved": false,
		"failed": false,
		"trail": "0",
		"changes": 0,
		"route": ""
	}]
	seen[TurnSim.state_key(start)] = 0

	for depth: int in range(max_depth + 1):
		depth_reached = depth
		var next_frontier: Array[Dictionary] = []
		for node: Dictionary in frontier:
			if bool(node["solved"]):
				var trail: String = node["trail"]
				var route: String = node["route"]
				if not sol_a.has(trail):
					sol_a[trail] = true
					curve_a[depth] += 1
					if sample_routes.size() < 8:
						sample_routes.append("%s | rule_changes=%d" % [route, int(node["changes"])])
				var end_key := TurnSim.state_key(node["state"])
				if not sol_b.has(end_key):
					sol_b[end_key] = true
					curve_b[depth] += 1
				if not sol_c.has(route):
					sol_c[route] = true
					curve_c[depth] += 1
				if not solved_any:
					solved_any = true
					first_solution_depth = depth
					first_route = route
					first_rule_changes = int(node["changes"])
				continue
			if bool(node["failed"]):
				continue
			for direction: Vector2i in DIRECTIONS:
				var result := TurnSim.step(
					node["state"], direction, int(node["turn"]),
					bool(node["solved"]), bool(node["failed"]), node["rules"]
				)
				if not bool(result["ok"]):
					continue
				var child_rules: RuleSet = result["rules"]
				var child_state: RuleGridState = result["state"]
				var signature := TurnSim.rule_resolution_signature(child_rules)
				var changed := signature != String(node["signature"])
				if frozen and signature != start_signature:
					continue
				var key := TurnSim.state_key(child_state)
				if seen.has(key):
					continue
				seen[key] = depth + 1
				nodes += 1
				if not signature_ids.has(signature):
					signature_ids[signature] = signature_ids.size()
				var trail: String = node["trail"]
				if changed:
					trail = "%s>%d" % [trail, int(signature_ids[signature])]
				next_frontier.append({
					"state": child_state,
					"rules": child_rules,
					"signature": signature,
					"turn": int(result["turn_index"]),
					"solved": bool(result["solved"]),
					"failed": bool(result["failed"]),
					"trail": trail,
					"changes": int(node["changes"]) + (1 if changed else 0),
					"route": "%s%s" % [node["route"], String(DIRECTION_GLYPHS[direction])]
				})
				if nodes >= max_nodes:
					exhausted = true
					break
			if exhausted:
				break
		if exhausted:
			break
		frontier = next_frontier
		if frontier.is_empty():
			drained = true
			break
	return {
		"curve_a": curve_a,
		"curve_b": curve_b,
		"curve_c": curve_c,
		"nodes": nodes,
		"depth_reached": depth_reached,
		"budget_exhausted": exhausted,
		"frontier_drained": drained,
		"solved_any": solved_any,
		"first_solution_depth": first_solution_depth,
		"first_route": first_route,
		"first_rule_changes": first_rule_changes,
		"sample_routes": sample_routes
	}


func _growth_verdict(curve: Array[int], depth_reached: int) -> String:
	var worst := 0.0
	var worst_depth := -1
	for depth: int in range(1, depth_reached + 1):
		var previous := int(curve[depth - 1])
		var current := int(curve[depth])
		if previous <= 0:
			continue
		var ratio := float(current) / float(previous)
		if ratio > worst:
			worst = ratio
			worst_depth = depth
	if worst_depth < 0:
		return "no_growth_after_first_solution"
	return "max_step_ratio=%.1f at depth %d" % [worst, worst_depth]


func _write_report(board_id: StringName, report: Dictionary) -> void:
	var directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("%s.json" % board_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("    could not write %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(report, "  ", false) + "\n")
	file.close()
	print("    wrote %s/%s.json" % [OUTPUT_DIRECTORY, board_id])


func _word_count(state: RuleGridState) -> int:
	var count := 0
	for entity: RuleGridEntity in state.entities:
		if entity.is_word:
			count += 1
	return count


func _occupancy(state: RuleGridState) -> Dictionary:
	var wall_cells: Dictionary = {}
	var filled: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		filled[entity.position] = true
		if not entity.is_word and entity.kind == &"WALL":
			wall_cells[entity.position] = true
	var total := state.width * state.height
	var wall := wall_cells.size()
	return {
		"non_wall_cells": total - wall,
		"non_wall_ratio": float(total - wall) / float(total),
		"fill_ratio": float(filled.size()) / float(total)
	}


func _reachable(state: RuleGridState, rules: RuleSet) -> int:
	var start_cells: Array[Vector2i] = []
	for entity: RuleGridEntity in TurnSim.you_entities(state, rules):
		start_cells.append(entity.position)
	var blocked: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if not entity.is_word and RuleEvaluator.has_property(entity, &"STOP", rules, state):
			blocked[entity.position] = true
	var seen: Dictionary = {}
	var queue: Array[Vector2i] = []
	for cell: Vector2i in start_cells:
		if not seen.has(cell):
			seen[cell] = true
			queue.append(cell)
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for step: Vector2i in DIRECTIONS:
			var next_cell: Vector2i = cell + step
			if next_cell.x < 0 or next_cell.y < 0 or next_cell.x >= state.width or next_cell.y >= state.height:
				continue
			if seen.has(next_cell) or blocked.has(next_cell):
				continue
			seen[next_cell] = true
			queue.append(next_cell)
	return seen.size()


func _sentence_text(sentence: RuleSentence) -> String:
	var text := "%s%s %s %s%s" % [
		"NOT " if sentence.subject_is_negated else "", sentence.subject,
		"INSIDE IS" if sentence.operator == &"INSIDE_IS" else String(sentence.operator),
		"NOT " if sentence.is_negated else "", sentence.predicate
	]
	for condition: Dictionary in sentence.conditions:
		text += " %s%s %s" % [
			"NOT " if bool(condition.get("negated", false)) else "",
			String(condition.get("kind", "")), String(condition.get("target", ""))
		]
	return text


func _rule_texts(rules: RuleSet) -> Array[String]:
	var parts: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		var text := _sentence_text(sentence)
		if not parts.has(text):
			parts.append(text)
	parts.sort()
	return parts
