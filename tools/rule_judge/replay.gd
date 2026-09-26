extends SceneTree

# Route replay for board authoring: plays a written route through the judge's turn
# simulator and prints what each turn did, so a board can be checked by its author
# without a scene tree.
#
# Run:  godot --headless --path . --script res://tools/rule_judge/replay.gd -- <board>:<route> [<board>:<route> ...]
# A route is a string of U/R/D/L. Append "!" to a pair to print only the summary line.

const TurnSim = preload("res://tools/rule_judge/turn_sim.gd")
const GLYPH_DIRECTIONS: Dictionary = {
	"U": Vector2i.UP, "R": Vector2i.RIGHT, "D": Vector2i.DOWN, "L": Vector2i.LEFT
}


func _initialize() -> void:
	for pair: String in OS.get_cmdline_user_args():
		var quiet := pair.ends_with("!")
		var text := pair.trim_suffix("!")
		var separator := text.find(":")
		if separator <= 0:
			print("REPLAY bad argument %s" % pair)
			continue
		_replay(StringName(text.substr(0, separator)), text.substr(separator + 1), quiet)
	quit(0)


func _replay(board_id: StringName, route: String, quiet: bool) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		print("REPLAY %s UNLOADABLE %s" % [board_id, level.get("error", "")])
		return
	var state: RuleGridState = level["state"]
	var rules := TurnSim.resolve_word_rules(state)
	var turn := 0
	var solved := false
	var failed := false
	var previous_rules := _rule_list(rules)
	if not quiet:
		print("=== %s route=%s" % [board_id, route])
		print("    start rules=%s you=%s" % [previous_rules, _you_cells(state, rules)])
	var index := 0
	for glyph: String in route.to_upper().split(""):
		if not GLYPH_DIRECTIONS.has(glyph):
			continue
		index += 1
		var result := TurnSim.step(state, GLYPH_DIRECTIONS[glyph], turn, solved, failed, rules)
		state = result["state"]
		rules = result["rules"]
		turn = int(result["turn_index"])
		solved = bool(result["solved"])
		failed = bool(result["failed"])
		if quiet:
			continue
		var line := "    %3d %s you=%s" % [index, glyph, _you_cells(state, rules)]
		var current_rules := _rule_list(rules)
		if current_rules != previous_rules:
			line += " rules=%s" % current_rules
			previous_rules = current_rules
		if solved:
			line += " SOLVED"
		if failed:
			line += " FAILED"
		print(line)
	print("REPLAY %s steps=%d turn=%d solved=%s failed=%s" % [board_id, index, turn, str(solved), str(failed)])


func _you_cells(state: RuleGridState, rules: RuleSet) -> String:
	var cells: Array[String] = []
	for entity: RuleGridEntity in TurnSim.you_entities(state, rules):
		cells.append("%s(%d,%d)" % [entity.id, entity.position.x, entity.position.y])
	return "[%s]" % ", ".join(cells)


func _rule_list(rules: RuleSet) -> String:
	var parts: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		var text := "%s%s %s %s%s" % [
			"NOT " if sentence.subject_is_negated else "", sentence.subject, sentence.operator,
			"NOT " if sentence.is_negated else "", sentence.predicate
		]
		if not parts.has(text):
			parts.append(text)
	parts.sort()
	return "[%s]" % ", ".join(parts)
