extends SceneTree

# Board judge: layered breadth-first search over a Rule Rewrite board, reporting how
# many distinct solutions appear at each turn depth. A curve that stays at zero for a
# long time and then produces a few specific solutions is a shaped puzzle; a curve that
# explodes as depth grows is not, because the player stumbles into a win.
#
# Run:  godot --headless --path . --script res://tools/rule_judge/judge.gd -- <board> <max_nodes> <max_depth>
# Omit <board> to sweep every board in content/index.json.
#
# When the node budget runs out the curve stops and the board is reported UNRESOLVED
# past that depth. Budgeted counts are never presented as totals.

const TurnSim = preload("res://tools/rule_judge/turn_sim.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const DIRECTION_GLYPHS: Dictionary = {
	Vector2i.UP: "U", Vector2i.RIGHT: "R", Vector2i.DOWN: "D", Vector2i.LEFT: "L"
}
const DEFAULT_MAX_NODES: int = 60000
const DEFAULT_MAX_DEPTH: int = 20


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var board_filter: String = args[0] if args.size() > 0 else ""
	var max_nodes: int = int(args[1]) if args.size() > 1 else DEFAULT_MAX_NODES
	var max_depth: int = int(args[2]) if args.size() > 2 else DEFAULT_MAX_DEPTH
	for board_id: StringName in RuleLevelLoader.list_level_ids():
		if not board_filter.is_empty() and String(board_id) != board_filter:
			continue
		_judge(board_id, max_nodes, max_depth)
	quit(0)


func _judge(board_id: StringName, max_nodes: int, max_depth: int) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		print("JUDGE %s UNLOADABLE %s" % [board_id, level.get("error", "")])
		return
	var start: RuleGridState = level["state"]
	var start_rules := TurnSim.resolve_word_rules(start)
	var start_signature := TurnSim.rule_resolution_signature(start_rules)
	var occupancy := _occupancy(start)
	print("=== %s  %dx%d  %s" % [board_id, start.width, start.height, level["title"]])
	print("    entities=%d words=%d  non_wall_cells=%d  floor_ratio=%.2f  board_fill=%.2f" % [
		start.entities.size(), _word_count(start), start.width * start.height,
		occupancy["non_wall_ratio"], occupancy["fill_ratio"]
	])
	print("    initial_rules=%s" % _rule_list(start_rules))
	print("    reachable_by_walk=%s" % str(_reachable(start, start_rules)))

	var search := _search(start, start_rules, start_signature, max_nodes, max_depth)
	var verdict := "UNRESOLVED (budget or depth cap reached; absence here is not proof of unsolvability)"
	if bool(search["frontier_drained"]):
		verdict = "COMPLETE (whole reachable state space enumerated)"
	elif bool(search["budget_exhausted"]):
		verdict = "UNRESOLVED (node budget exhausted; absence here is not proof of unsolvability)"
	print("    nodes=%d depth_reached=%d %s" % [search["nodes"], search["depth_reached"], verdict])
	print("    depth  A_rule_traj  B_end_state  C_move_path   cumulative_A")
	var cumulative := 0
	for depth: int in range(search["depth_reached"] + 1):
		cumulative += int(search["curve_a"][depth])
		print("    %5d  %11d  %12d  %10d  %13d" % [
			depth, int(search["curve_a"][depth]), int(search["curve_b"][depth]),
			int(search["curve_c"][depth]), cumulative
		])
	if not bool(search["solved_any"]):
		print("    NO_SOLUTION_WITHIN_BUDGET")
	else:
		print("    first_solution_depth=%d" % int(search["first_solution_depth"]))
		var growth := _growth_verdict(search["curve_a"], search["depth_reached"])
		print("    growth_verdict=%s" % growth)
		print("    sample_routes=%s" % str(search["sample_routes"].slice(0, 3)))


func _search(start: RuleGridState, start_rules: RuleSet, start_signature: String, max_nodes: int, max_depth: int) -> Dictionary:
	var curve_a: Array[int] = []
	var curve_b: Array[int] = []
	var curve_c: Array[int] = []
	var seen: Dictionary = {}
	var sol_a: Dictionary = {}
	var sol_b: Dictionary = {}
	var sol_c: Dictionary = {}
	var sample_routes: Array[String] = []
	var nodes := 0
	var depth_reached := 0
	var solved_any := false
	var first_solution_depth := -1
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
		"trail": start_signature,
		"route": ""
	}]
	seen[TurnSim.state_key(start, start_rules, start_signature)] = 0

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
						sample_routes.append("%s | rules: %s" % [route, trail])
				if not sol_b.has(TurnSim.state_key(node["state"], node["rules"], String(node["signature"]))):
					sol_b[TurnSim.state_key(node["state"], node["rules"], String(node["signature"]))] = true
					curve_b[depth] += 1
				if not sol_c.has(route):
					sol_c[route] = true
					curve_c[depth] += 1
				if not solved_any:
					solved_any = true
					first_solution_depth = depth
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
				var key := TurnSim.state_key(child_state, child_rules, signature)
				if seen.has(key):
					continue
				seen[key] = depth + 1
				nodes += 1
				var trail: String = node["trail"]
				if not trail.ends_with(signature):
					trail = "%s>%s" % [trail, signature]
				next_frontier.append({
					"state": child_state,
					"rules": child_rules,
					"signature": signature,
					"turn": int(result["turn_index"]),
					"solved": bool(result["solved"]),
					"failed": bool(result["failed"]),
					"trail": trail,
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


func _rule_list(rules: RuleSet) -> String:
	var parts: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		parts.append("%s %s %s" % [sentence.subject, sentence.operator, sentence.predicate])
	parts.sort()
	return "[%s]" % ", ".join(parts)
