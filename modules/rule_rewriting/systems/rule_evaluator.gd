class_name RuleEvaluator
extends RefCounted

const OPERATOR_IS: StringName = &"IS"
const OPERATOR_HAS: StringName = &"HAS"
const ROLE_PROPERTY: StringName = &"property"
const ROLE_NOUN: StringName = &"noun"
const PROPERTY_FLOAT: StringName = &"FLOAT"
const PROPERTY_SAFE: StringName = &"SAFE"
const PROPERTY_YOU: StringName = &"YOU"


static func has_property(
	entity: RuleGridEntity,
	property: StringName,
	rules: RuleSet,
	state: RuleGridState
) -> bool:
	if entity == null or rules == null or property.is_empty():
		return false
	if entity.base_tags.has(property) or entity.runtime_tags.has(property):
		return true
	var has_positive := false
	var has_negative := false
	for sentence: RuleSentence in rules.sentences:
		if sentence.operator != OPERATOR_IS or sentence.predicate_role != ROLE_PROPERTY \
			or sentence.predicate != property or not _subject_matches(sentence, entity.kind) \
			or not _conditions_match(entity, sentence.conditions, state):
			continue
		if sentence.is_negated:
			has_negative = true
		else:
			has_positive = true
	return has_positive and not has_negative


static func property_stack(
	entity: RuleGridEntity,
	property: StringName,
	rules: RuleSet,
	state: RuleGridState
) -> int:
	if entity == null or rules == null or property.is_empty():
		return 0
	var active_sentences: Array[RuleSentence] = []
	var has_positive := false
	var has_negative := false
	for sentence: RuleSentence in rules.sentences:
		if sentence.operator != OPERATOR_IS or sentence.predicate_role != ROLE_PROPERTY \
			or sentence.predicate != property or not _subject_matches(sentence, entity.kind) \
			or not conditions_match(entity, sentence.conditions, state):
			continue
		if sentence.is_negated:
			has_negative = true
		else:
			has_positive = true
			active_sentences.append(sentence)
	if has_negative:
		return 0 if not (entity.base_tags.has(property) or entity.runtime_tags.has(property)) else 1
	var stack := 1 if entity.base_tags.has(property) or entity.runtime_tags.has(property) else 0
	if not has_positive:
		return stack
	var word_ids: Dictionary = {}
	if state != null:
		var entities_by_id: Dictionary = {}
		for candidate: RuleGridEntity in state.entities:
			entities_by_id[candidate.id] = candidate
		for sentence: RuleSentence in active_sentences:
			for source_id: String in sentence.source_entity_ids:
				if not entities_by_id.has(source_id):
					continue
				var source: RuleGridEntity = entities_by_id[source_id]
				if source.is_word and source.word_role == ROLE_PROPERTY and source.word_value == property:
					word_ids[source_id] = true
	if word_ids.is_empty():
		stack = maxi(stack, active_sentences.size())
	else:
		stack = maxi(stack, word_ids.size())
	return stack


static func entities_interact(
	a: RuleGridEntity,
	b: RuleGridEntity,
	rules: RuleSet,
	state: RuleGridState
) -> bool:
	if a == null or b == null or a.id == b.id:
		return false
	return has_property(a, PROPERTY_FLOAT, rules, state) == has_property(b, PROPERTY_FLOAT, rules, state)


static func resolve_contacts(state: RuleGridState, rules: RuleSet) -> Dictionary:
	if state == null or rules == null:
		return {"valid": false, "removed_ids": [], "defeated_ids": [], "surviving_you_ids": [], "has_spawns": [], "won": false, "failed": false}
	var entities_by_id: Dictionary = {}
	var by_cell: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null or entity.id.is_empty() or entities_by_id.has(entity.id):
			return {"valid": false, "removed_ids": [], "defeated_ids": [], "surviving_you_ids": [], "has_spawns": [], "won": false, "failed": false}
		entities_by_id[entity.id] = entity
		var occupants: Array = by_cell.get(entity.position, [])
		occupants.append(entity)
		by_cell[entity.position] = occupants
	var removed: Dictionary = {}
	var defeated: Dictionary = {}
	for occupants_value: Variant in by_cell.values():
		if not occupants_value is Array:
			continue
		var occupants: Array = occupants_value
		for first_index: int in range(occupants.size()):
			var first_value: Variant = occupants[first_index]
			if not first_value is RuleGridEntity:
				continue
			var first: RuleGridEntity = first_value
			for second_index: int in range(first_index + 1, occupants.size()):
				var second_value: Variant = occupants[second_index]
				if not second_value is RuleGridEntity:
					continue
				var second: RuleGridEntity = second_value
				if not entities_interact(first, second, rules, state):
					continue
				var first_safe := has_property(first, PROPERTY_SAFE, rules, state)
				var second_safe := has_property(second, PROPERTY_SAFE, rules, state)
				var first_sink := has_property(first, &"SINK", rules, state)
				var second_sink := has_property(second, &"SINK", rules, state)
				if first_sink or second_sink:
					if not first_safe:
						removed[first.id] = true
					if not second_safe:
						removed[second.id] = true
				var first_hot_melt := has_property(first, &"MELT", rules, state) \
					and has_property(second, &"HOT", rules, state)
				var second_hot_melt := has_property(second, &"MELT", rules, state) \
					and has_property(first, &"HOT", rules, state)
				if first_hot_melt and not first_safe:
					removed[first.id] = true
				if second_hot_melt and not second_safe:
					removed[second.id] = true
				var open_shut := (has_property(first, &"OPEN", rules, state) \
					and has_property(second, &"SHUT", rules, state)) \
					or (has_property(first, &"SHUT", rules, state) \
					and has_property(second, &"OPEN", rules, state))
				if open_shut:
					if not first_safe:
						removed[first.id] = true
					if not second_safe:
						removed[second.id] = true
				if has_property(first, &"WEAK", rules, state) and not first_safe:
					removed[first.id] = true
				if has_property(second, &"WEAK", rules, state) and not second_safe:
					removed[second.id] = true
				var first_you_defeated := not first.is_word \
					and has_property(first, PROPERTY_YOU, rules, state) \
					and has_property(second, &"DEFEAT", rules, state)
				var second_you_defeated := not second.is_word \
					and has_property(second, PROPERTY_YOU, rules, state) \
					and has_property(first, &"DEFEAT", rules, state)
				if first_you_defeated and not first_safe:
					removed[first.id] = true
					defeated[first.id] = true
				if second_you_defeated and not second_safe:
					removed[second.id] = true
					defeated[second.id] = true
	for entity: RuleGridEntity in state.entities:
		if has_property(entity, &"WEAK", rules, state):
			for other_value: Variant in by_cell.get(entity.position, []):
				if other_value is RuleGridEntity and other_value.id != entity.id \
					and entities_interact(entity, other_value, rules, state) \
					and not has_property(entity, PROPERTY_SAFE, rules, state):
					removed[entity.id] = true
					break
	var removed_ids: Array[String] = []
	var defeated_ids: Array[String] = []
	var surviving_you_ids: Array[String] = []
	var won := false
	var ordered: Array[RuleGridEntity] = []
	ordered.assign(state.entities)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return _priority_less(a, b))
	for entity: RuleGridEntity in ordered:
		if removed.has(entity.id):
			removed_ids.append(entity.id)
		if defeated.has(entity.id):
			defeated_ids.append(entity.id)
		if entity.is_word or not has_property(entity, PROPERTY_YOU, rules, state):
			continue
		if removed.has(entity.id):
			continue
		surviving_you_ids.append(entity.id)
		if has_property(entity, &"WIN", rules, state):
			won = true
			continue
		for win_value: Variant in by_cell.get(entity.position, []):
			if win_value is RuleGridEntity and not removed.has(win_value.id) \
				and has_property(win_value, &"WIN", rules, state) \
				and entities_interact(entity, win_value, rules, state):
				won = true
				break
	var has_spawns := _has_spawn_descriptors(state, rules, removed, entities_by_id)
	return {
		"valid": true,
		"removed_ids": removed_ids,
		"defeated_ids": defeated_ids,
		"surviving_you_ids": surviving_you_ids,
		"has_spawns": has_spawns,
		"won": won,
		"failed": surviving_you_ids.is_empty()
	}


static func _has_spawn_descriptors(
	state: RuleGridState,
	rules: RuleSet,
	removed_ids: Dictionary,
	entities_by_id: Dictionary
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var ordered: Array[RuleGridEntity] = []
	for entity_id_value: Variant in removed_ids.keys():
		var entity_id := String(entity_id_value)
		if entities_by_id.has(entity_id):
			ordered.append(entities_by_id[entity_id])
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return _priority_less(a, b))
	for source: RuleGridEntity in ordered:
		if source.is_word:
			continue
		var candidates: Dictionary = {}
		var suppressed: Dictionary = {}
		for sentence: RuleSentence in rules.sentences:
			if sentence.operator != OPERATOR_HAS or sentence.predicate_role != ROLE_NOUN \
				or not _subject_matches(sentence, source.kind) \
				or not _conditions_match(source, sentence.conditions, state):
				continue
			if sentence.is_negated:
				suppressed[sentence.predicate] = true
			else:
				candidates[sentence.predicate] = true
		var outputs: Array[StringName] = []
		for kind_value: Variant in candidates.keys():
			var kind := StringName(kind_value)
			if not suppressed.has(kind):
				outputs.append(kind)
		outputs.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
		for kind: StringName in outputs:
			result.append({
				"source_id": source.id,
				"kind": String(kind),
				"position": source.position,
				"facing": source.facing,
				"layer": source.layer
			})
	return result


static func apply_transformations(
	state: RuleGridState,
	rules: RuleSet,
	processed_ids: Dictionary = {}
) -> Dictionary:
	if state == null or rules == null:
		return {"valid": false, "changed_ids": [], "created_ids": []}
	var used_ids: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null or entity.id.is_empty() or used_ids.has(entity.id):
			return {"valid": false, "changed_ids": [], "created_ids": []}
		used_ids[entity.id] = true
	var ordered: Array[RuleGridEntity] = []
	ordered.assign(state.entities)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	var changed_ids: Array[String] = []
	var created_ids: Array[String] = []
	var clones: Array[RuleGridEntity] = []
	var next_creation_serial := 0
	for entity: RuleGridEntity in ordered:
		next_creation_serial = maxi(next_creation_serial, entity.creation_serial + 1)
	for entity: RuleGridEntity in ordered:
		if entity.is_word or processed_ids.has(entity.id):
			continue
		var outputs := _unique_nouns(_transforms_for(entity, state, rules))
		if outputs.is_empty():
			continue
		processed_ids[entity.id] = true
		var original_kind := entity.kind
		var retained_kind: StringName = outputs[0]
		if outputs.has(original_kind):
			retained_kind = original_kind
		if entity.kind != retained_kind:
			entity.kind = retained_kind
			changed_ids.append(entity.id)
		for output_kind: StringName in outputs:
			if output_kind == retained_kind:
				continue
			var clone := _copy_entity(entity)
			clone.kind = output_kind
			clone.id = _unique_id("transform::%s::%s" % [entity.id, String(output_kind)], used_ids)
			clone.creation_serial = next_creation_serial
			next_creation_serial += 1
			used_ids[clone.id] = true
			processed_ids[clone.id] = true
			clones.append(clone)
			created_ids.append(clone.id)
			changed_ids.append(clone.id)
	for clone: RuleGridEntity in clones:
		state.entities.append(clone)
	return {"valid": true, "changed_ids": changed_ids, "created_ids": created_ids}


static func _unique_nouns(values: Array[StringName]) -> Array[StringName]:
	var result: Array[StringName] = []
	for value: StringName in values:
		if not value.is_empty() and not result.has(value):
			result.append(value)
	result.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return result


static func _copy_entity(source: RuleGridEntity) -> RuleGridEntity:
	var clone := RuleGridEntity.new()
	clone.id = source.id
	clone.kind = source.kind
	clone.position = source.position
	clone.facing = source.facing
	clone.layer = source.layer
	clone.creation_serial = source.creation_serial
	clone.is_word = false
	clone.base_tags.assign(source.base_tags)
	clone.runtime_tags.assign(source.runtime_tags)
	clone.module_metadata = source.module_metadata.duplicate(true)
	return clone


static func _transforms_for(
	entity: RuleGridEntity,
	state: RuleGridState,
	rules: RuleSet
) -> Array[StringName]:
	var candidates: Array[StringName] = []
	for sentence: RuleSentence in rules.sentences:
		if sentence.operator != OPERATOR_IS or sentence.predicate_role != ROLE_NOUN \
			or not _subject_matches(sentence, entity.kind) \
			or not _conditions_match(entity, sentence.conditions, state):
			continue
		if not candidates.has(sentence.predicate):
			candidates.append(sentence.predicate)
	var result: Array[StringName] = []
	for candidate: StringName in candidates:
		var suppressed := false
		for sentence: RuleSentence in rules.sentences:
			if sentence.operator == OPERATOR_IS and sentence.predicate_role == ROLE_NOUN \
				and sentence.predicate == candidate and sentence.is_negated \
				and _subject_matches(sentence, entity.kind) \
				and _conditions_match(entity, sentence.conditions, state):
				suppressed = true
				break
		if not suppressed:
			result.append(candidate)
	return result


static func conditions_match(
	entity: RuleGridEntity,
	conditions: Array[Dictionary],
	state: RuleGridState
) -> bool:
	return _conditions_match(entity, conditions, state)


static func _conditions_match(
	entity: RuleGridEntity,
	conditions: Array[Dictionary],
	state: RuleGridState
) -> bool:
	for condition: Dictionary in conditions:
		var kind: StringName = StringName(condition.get("kind", ""))
		var target: StringName = StringName(condition.get("target", ""))
		var matches := false
		match kind:
			&"ON":
				matches = _has_matching_entity(state, entity, target, entity.position)
			&"NEAR":
				matches = _has_nearby_entity(state, entity, target)
			&"FACING":
				matches = _has_matching_entity(state, entity, target, entity.position + entity.facing)
			_:
				return false
		if bool(condition.get("negated", false)):
			matches = not matches
		if not matches:
			return false
	return true


static func _has_matching_entity(
	state: RuleGridState,
	subject: RuleGridEntity,
	target_kind: StringName,
	target_cell: Vector2i
) -> bool:
	if state == null:
		return false
	for target: RuleGridEntity in state.entities:
		if target == null or target.id == subject.id or target.kind != target_kind \
			or target.position != target_cell:
			continue
		return true
	return false


static func _has_nearby_entity(state: RuleGridState, subject: RuleGridEntity, target_kind: StringName) -> bool:
	if state == null:
		return false
	for target: RuleGridEntity in state.entities:
		if target == null or target.id == subject.id or target.kind != target_kind:
			continue
		var distance: Vector2i = target.position - subject.position
		if distance != Vector2i.ZERO and absi(distance.x) <= 1 and absi(distance.y) <= 1:
			return true
	return false


static func _subject_matches(sentence: RuleSentence, noun: StringName) -> bool:
	if sentence.subject_is_negated:
		return sentence.subject != noun
	return sentence.subject == noun


static func _priority_less(a: RuleGridEntity, b: RuleGridEntity) -> bool:
	if a.position.x != b.position.x:
		return a.position.x < b.position.x
	if a.position.y != b.position.y:
		return a.position.y < b.position.y
	if a.layer != b.layer:
		return a.layer < b.layer
	if a.creation_serial != b.creation_serial:
		return a.creation_serial < b.creation_serial
	return a.id < b.id


static func _unique_id(prefix: String, used_ids: Dictionary) -> String:
	var candidate := prefix
	var suffix := 1
	while used_ids.has(candidate):
		candidate = "%s::%d" % [prefix, suffix]
		suffix += 1
	return candidate
