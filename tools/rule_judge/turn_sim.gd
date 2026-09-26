extends RefCounted

# Headless turn simulator for the Rule Rewrite board judge.
#
# This mirrors the state-affecting part of modules/rule_rewriting/module.gd so the
# judge can search boards without a scene tree. It copies behaviour; it shares no
# code with the module. tests/core/test_rule_judge_parity.gd is the only thing that
# catches divergence, so that test must stay in the mandatory verification run.
#
# Module-owned limits are read from the module script at runtime instead of being
# duplicated here, so tuning module.gd cannot leave a stale copy behind.

const MODULE_SCRIPT_PATH: String = "res://modules/rule_rewriting/module.gd"

static var _consts: Dictionary = {}

# Judge-only RuleSet surgery for declared_rule_required. Every parse drops the
# sentences whose meaning key is listed here, so a removed rule cannot come back by
# re-parsing the same words. Empty by default, which keeps the simulator an exact
# copy of the module turn (the parity test runs with it empty).
static var suppressed_meanings: Dictionary = {}


static func limits() -> Dictionary:
	if _consts.is_empty():
		var script: Script = load(MODULE_SCRIPT_PATH) as Script
		if script == null:
			return {}
		_consts = script.get_script_constant_map()
	return _consts


static func _limit(name: StringName, fallback: int) -> int:
	var values := limits()
	if values.has(name):
		return int(values[name])
	if values.has(String(name)):
		return int(values[String(name)])
	return fallback


# Mirrors module.gd _entity_less / movement_solver.gd _priority_less.
# x, then y, then layer, then creation_serial, then id.
static func entity_less(left: RuleGridEntity, right: RuleGridEntity) -> bool:
	if left.position.x != right.position.x:
		return left.position.x < right.position.x
	if left.position.y != right.position.y:
		return left.position.y < right.position.y
	if left.layer != right.layer:
		return left.layer < right.layer
	if left.creation_serial != right.creation_serial:
		return left.creation_serial < right.creation_serial
	return left.id < right.id


static func you_entities(state: RuleGridState, rules: RuleSet) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	if state == null:
		return result
	for entity: RuleGridEntity in state.entities:
		if not entity.is_word and RuleEvaluator.has_property(entity, &"YOU", rules, state):
			result.append(entity)
	result.sort_custom(entity_less)
	return result


static func you_ids(state: RuleGridState, rules: RuleSet) -> Array[String]:
	var result: Array[String] = []
	for entity: RuleGridEntity in you_entities(state, rules):
		result.append(entity.id)
	return result


# Mirrors module.gd _rule_resolution_signature.
static func rule_resolution_signature(rules: RuleSet) -> String:
	var signatures: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		var source_ids := sentence.source_entity_ids.duplicate()
		source_ids.sort()
		var condition_parts: Array[String] = []
		for condition: Dictionary in sentence.conditions:
			condition_parts.append("%s:%s:%s" % [
				String(condition.get("kind", "")),
				String(condition.get("target", "")),
				str(bool(condition.get("negated", false)))
			])
		signatures.append("%s|%s|%s|%s|%s|%s|%s|%s" % [
			String(sentence.subject), str(sentence.subject_is_negated),
			String(sentence.operator), String(sentence.predicate_role),
			String(sentence.predicate), str(sentence.is_negated),
			";".join(condition_parts), ";".join(source_ids)
		])
	signatures.sort()
	return "\n".join(signatures)


# Meaning of a sentence without its sources: the same rule written with other words,
# or at another place, has the same key.
static func meaning_key(sentence: RuleSentence) -> String:
	var condition_parts: Array[String] = []
	for condition: Dictionary in sentence.conditions:
		condition_parts.append("%s:%s:%s" % [
			String(condition.get("kind", "")),
			String(condition.get("target", "")),
			str(bool(condition.get("negated", false)))
		])
	return "%s|%s|%s|%s|%s|%s|%s" % [
		String(sentence.subject), str(sentence.subject_is_negated),
		String(sentence.operator), String(sentence.predicate_role),
		String(sentence.predicate), str(sentence.is_negated), ";".join(condition_parts)
	]


static func _parse(width: int, height: int, entities: Array[RuleGridEntity]) -> RuleSet:
	var rules := RuleParser.parse(width, height, entities)
	if suppressed_meanings.is_empty():
		return rules
	var kept: Array[RuleSentence] = []
	for sentence: RuleSentence in rules.sentences:
		if not suppressed_meanings.has(meaning_key(sentence)):
			kept.append(sentence)
	rules.sentences = kept
	return rules


# Mirrors module.gd _word_parse_input.
static func word_parse_input(state: RuleGridState, rules: RuleSet, disabled_sources: Dictionary) -> Dictionary:
	var entities: Array[RuleGridEntity] = []
	entities.assign(state.entities)
	var promoted_ids: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null or entity.is_word or disabled_sources.has(entity.id) \
			or entity.base_tags.has(&"WORD") or entity.runtime_tags.has(&"WORD") \
			or not RuleEvaluator.has_property(entity, &"WORD", rules, state):
			continue
		var token := RuleGridEntity.new()
		token.id = entity.id
		token.kind = entity.kind
		token.position = entity.position
		token.facing = entity.facing
		token.layer = entity.layer
		token.creation_serial = entity.creation_serial
		token.is_word = true
		token.word_role = &"noun"
		token.word_value = entity.kind
		entities.append(token)
		promoted_ids[entity.id] = true
	return {"entities": entities, "promoted_ids": promoted_ids}


# Mirrors module.gd _varying_word_sources.
static func varying_word_sources(states: Array[Dictionary], start_index: int, next_state: Dictionary) -> Dictionary:
	var all_sources: Dictionary = {}
	var common_sources: Dictionary = {}
	var initialized := false
	var state_count := states.size() + 1
	for state_index: int in range(start_index, state_count):
		var sources: Dictionary = next_state if state_index == states.size() else states[state_index]
		for source_id: Variant in sources.keys():
			all_sources[String(source_id)] = true
		if not initialized:
			common_sources = sources.duplicate()
			initialized = true
		else:
			for source_id: Variant in common_sources.keys():
				if not sources.has(source_id):
					common_sources.erase(source_id)
	var varying_sources: Dictionary = {}
	for source_id: Variant in all_sources.keys():
		if not common_sources.has(source_id):
			varying_sources[String(source_id)] = true
	return varying_sources


# Mirrors module.gd _resolve_word_rules: iterate physical text through WORD promotion
# until the rule signature stops changing, and disable only the derived sources that
# vary inside a cycle.
static func resolve_word_rules(state: RuleGridState) -> RuleSet:
	var physical_rules := _parse(state.width, state.height, state.entities)
	var disabled_word_sources: Dictionary = {}
	var step_limit := mini(_limit(&"MAX_WORD_FIXED_POINT_STEPS", 128), maxi(1, state.entities.size() + 1))
	for _resolve_pass: int in range(maxi(1, state.entities.size() + 1)):
		var current_rules := physical_rules
		var signatures: Array[String] = []
		var promoted_by_state: Array[Dictionary] = []
		var restart_from_physical := false
		for _step: int in range(step_limit):
			var current_signature := rule_resolution_signature(current_rules)
			signatures.append(current_signature)
			var parse_input := word_parse_input(state, current_rules, disabled_word_sources)
			promoted_by_state.append(parse_input["promoted_ids"])
			var next_rules := _parse(state.width, state.height, parse_input["entities"])
			var next_signature := rule_resolution_signature(next_rules)
			if next_signature == current_signature:
				return next_rules
			var repeated_at := signatures.find(next_signature)
			if repeated_at >= 0:
				var next_input := word_parse_input(state, next_rules, disabled_word_sources)
				var cycle_sources := varying_word_sources(promoted_by_state, repeated_at, next_input["promoted_ids"])
				if cycle_sources.is_empty():
					return physical_rules
				for source_id: String in cycle_sources.keys():
					disabled_word_sources[source_id] = true
				restart_from_physical = true
				break
			current_rules = next_rules
		if not restart_from_physical:
			return physical_rules
	return physical_rules


# Mirrors module.gd _append_has_spawns. Returns true when entities were appended.
static func append_has_spawns(state: RuleGridState, turn_index: int, descriptors: Variant) -> bool:
	if not descriptors is Array:
		return false
	var max_counter := _limit(&"MAX_COUNTER", 999999)
	var next_serial := 0
	var used_ids: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null:
			continue
		used_ids[entity.id] = true
		next_serial = maxi(next_serial, entity.creation_serial + 1)
	var changed := false
	for descriptor: Variant in descriptors:
		if not descriptor is Dictionary:
			continue
		var source_id := String(descriptor.get("source_id", ""))
		var kind := StringName(String(descriptor.get("kind", "")))
		var position: Variant = descriptor.get("position")
		var facing: Variant = descriptor.get("facing")
		if source_id.is_empty() or not RuleLevelLoader.OBJECT_CATALOG.has(kind) \
			or not position is Vector2i or not facing is Vector2i \
			or not _inside_board(position, state.width, state.height):
			continue
		var entity := RuleGridEntity.new()
		var id_prefix := "has::%s::%d::%s" % [source_id, mini(turn_index + 1, max_counter), String(kind)]
		entity.id = id_prefix
		var suffix := 1
		while used_ids.has(entity.id):
			entity.id = "%s::%d" % [id_prefix, suffix]
			suffix += 1
		entity.kind = kind
		entity.position = position
		entity.facing = facing
		var layer_value: Variant = descriptor.get("layer", 0)
		if RuleGridEntity._is_integer(layer_value):
			entity.layer = int(layer_value)
		entity.creation_serial = next_serial
		next_serial += 1
		used_ids[entity.id] = true
		state.entities.append(entity)
		changed = true
	return changed


static func _inside_board(cell: Vector2i, width: int, height: int) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


static func _copy_state(state: RuleGridState) -> RuleGridState:
	return RuleGridState.from_dictionary(state.to_dictionary()) as RuleGridState


# Mirrors module.gd _apply_moves.
static func _apply_moves(state: RuleGridState, moves: Variant) -> void:
	if not moves is Array:
		return
	var by_id: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		by_id[entity.id] = entity
	for move_value: Variant in moves:
		if not move_value is Dictionary:
			continue
		var entity: RuleGridEntity = by_id.get(String(move_value.get("entity_id", "")))
		if entity == null:
			continue
		var destination: Variant = move_value.get("to")
		if destination is Vector2i:
			entity.position = destination
		var facing: Variant = move_value.get("facing_to")
		if facing is Vector2i:
			entity.facing = facing
		elif move_value.get("direction") is Vector2i:
			entity.facing = move_value["direction"]


# Mirrors module.gd _apply_transform_stage. Returns false when the turn must abort.
static func _apply_transform_stage(state: RuleGridState, rules: RuleSet, processed: Dictionary) -> Dictionary:
	var result := RuleEvaluator.apply_transformations(state, rules, processed)
	if not bool(result.get("valid", false)):
		return {"ok": false, "rules": rules}
	var transformed_ids: Array = result.get("changed_ids", [])
	var created_ids: Array = result.get("created_ids", [])
	if not transformed_ids.is_empty() or not created_ids.is_empty():
		return {"ok": true, "rules": resolve_word_rules(state)}
	return {"ok": true, "rules": rules}


# Mirrors module.gd _resolve_interactions. Returns solved/failed as the module leaves them.
static func _resolve_contacts(state: RuleGridState, rules: RuleSet, turn_index: int) -> Dictionary:
	var solved := false
	var failed := false
	for _pass: int in range(_limit(&"MAX_CONTACT_PASSES", 4)):
		var result := RuleEvaluator.resolve_contacts(state, rules)
		if not bool(result.get("valid", false)):
			return {"rules": rules, "solved": solved, "failed": failed}
		var removed_ids: Dictionary = {}
		for entity_id: Variant in result.get("removed_ids", []):
			removed_ids[String(entity_id)] = true
		var spawned := append_has_spawns(state, turn_index, result.get("has_spawns", []))
		if not removed_ids.is_empty():
			var survivors: Array[RuleGridEntity] = []
			for entity: RuleGridEntity in state.entities:
				if not removed_ids.has(entity.id):
					survivors.append(entity)
			state.entities = survivors
		var changed := not removed_ids.is_empty() or spawned
		if changed:
			rules = resolve_word_rules(state)
		failed = bool(result.get("failed", false)) and you_ids(state, rules).is_empty()
		solved = bool(result.get("won", false)) and not failed
		if not changed:
			break
	return {"rules": rules, "solved": solved, "failed": failed}


static func _physical_equal(left: RuleGridState, right: RuleGridState) -> bool:
	if left == null or right == null:
		return left == right
	if left.width != right.width or left.height != right.height:
		return false
	if left.entities.size() != right.entities.size():
		return false
	var by_id: Dictionary = {}
	for entity: RuleGridEntity in right.entities:
		by_id[entity.id] = entity
	for entity: RuleGridEntity in left.entities:
		var other: RuleGridEntity = by_id.get(entity.id)
		if other == null or other.position != entity.position or other.facing != entity.facing \
			or other.creation_serial != entity.creation_serial:
			return false
	return true


# One player intent, mirroring module.gd _apply_player_intent.
# Returns a fresh state; never mutates the input state.
# turn_index only advances when the turn actually changed the board, which is what
# module.gd _commit_intent does. That counter is load-bearing: it names HAS spawns.
static func step(
	state: RuleGridState,
	direction: Vector2i,
	turn_index: int,
	was_solved: bool = false,
	was_failed: bool = false,
	known_rules: RuleSet = null
) -> Dictionary:
	var working := _copy_state(state)
	if working == null:
		return {"ok": false, "state": state, "rules": RuleSet.new(), "turn_index": turn_index, "solved": was_solved, "failed": was_failed, "moved": false, "word_moved": false, "path": "null_state"}
	if was_solved:
		var solved_rules := known_rules if known_rules != null else resolve_word_rules(state)
		return {"ok": true, "state": _copy_state(state), "rules": solved_rules, "turn_index": turn_index, "solved": true, "failed": was_failed, "moved": false, "word_moved": false, "path": "already_solved"}
	var rules: RuleSet = known_rules if known_rules != null else resolve_word_rules(working)
	var controlled := you_ids(working, rules)
	var processed: Dictionary = {}
	var moved := false
	var word_moved := false

	var plan := RuleMovementSolver.plan_move_many(working, rules, controlled, direction)
	if bool(plan.get("can_move", false)):
		_apply_moves(working, plan.get("moves", []))
		for entity_id: String in controlled:
			var actor := _find_entity(working, entity_id)
			if actor != null:
				actor.facing = direction
		rules = resolve_word_rules(working)
		var stage := _apply_transform_stage(working, rules, processed)
		if not bool(stage["ok"]):
			return {"ok": true, "state": _copy_state(state), "rules": rules, "turn_index": turn_index, "solved": was_solved, "failed": was_failed, "moved": false, "word_moved": false, "path": "transform_stage"}
		rules = stage["rules"]
		moved = true

	var auto_plan := RuleMovementSolver.plan_move_auto(working, rules)
	if not bool(auto_plan.get("valid", false)):
		return {"ok": true, "state": _copy_state(state), "rules": rules, "turn_index": turn_index, "solved": was_solved, "failed": was_failed, "moved": moved, "word_moved": false, "path": "auto_invalid"}
	_apply_moves(working, auto_plan.get("moves", []))
	if bool(auto_plan.get("word_moved", false)):
		word_moved = true
		rules = resolve_word_rules(working)
		var stage := _apply_transform_stage(working, rules, processed)
		if not bool(stage["ok"]):
			return {"ok": true, "state": _copy_state(state), "rules": rules, "turn_index": turn_index, "solved": was_solved, "failed": was_failed, "moved": moved, "word_moved": false, "path": "transform_stage"}
		rules = stage["rules"]

	var contacts := _resolve_contacts(working, rules, turn_index)
	var solved := bool(contacts["solved"])
	var failed := bool(contacts["failed"])
	var board_changed := not _physical_equal(working, state) or solved != was_solved or failed != was_failed
	return {
		"ok": true,
		"state": working,
		"rules": contacts["rules"],
		"turn_index": (mini(turn_index + 1, _limit(&"MAX_COUNTER", 999999)) if board_changed else turn_index),
		"solved": solved,
		"failed": failed,
		"moved": moved,
		"word_moved": word_moved,
		"path": "ok"
	}


static func _find_entity(state: RuleGridState, entity_id: String) -> RuleGridEntity:
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return entity
	return null


# Canonical, order-independent state key for search dedup.
# The active rules are a function of the physical state (and of the fixed
# suppression set during one search), so the key is the physical state alone.
# signature_in is accepted for callers written against the older key and ignored.
static func state_key(state: RuleGridState, _rules: RuleSet = null, _signature_in: String = "") -> String:
	var parts: PackedStringArray = PackedStringArray()
	for entity: RuleGridEntity in state.entities:
		parts.append("%s:%s:%d,%d:%d,%d:%d:%d" % [
			entity.id, String(entity.kind), entity.position.x, entity.position.y,
			entity.facing.x, entity.facing.y, entity.layer, entity.creation_serial
		])
	parts.sort()
	return "|".join(parts)
