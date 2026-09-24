class_name RuleParser
extends RefCounted

const WORD_NOUN: StringName = &"noun"
const WORD_OPERATOR: StringName = &"operator"
const WORD_PROPERTY: StringName = &"property"
const OPERATOR_IS: StringName = &"IS"
const OPERATOR_HAS: StringName = &"HAS"
const OPERATOR_OWNS: StringName = &"OWNS"
const OPERATOR_INSIDE: StringName = &"INSIDE"
const OPERATOR_AND: StringName = &"AND"
const OPERATOR_NOT: StringName = &"NOT"
const CONDITIONS: Array[StringName] = [&"ON", &"NEAR", &"FACING"]


static func parse(width: int, height: int, entities: Array[RuleGridEntity]) -> RuleSet:
	var result := RuleSet.new()
	if width <= 0 or height <= 0:
		return result

	var word_cells: Dictionary = {}
	var ordered: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in entities:
		if entity != null:
			ordered.append(entity)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	for entity: RuleGridEntity in ordered:
		if not _inside_board(entity.position, width, height):
			continue
		var word := _word_token_for(entity)
		if word == null:
			continue
		var cell_words := _words_at(word_cells, word.position)
		cell_words.append(word)
		word_cells[word.position] = cell_words

	for y: int in range(height):
		for x: int in range(width):
			var start := Vector2i(x, y)
			_parse_line(result, word_cells, start, Vector2i.RIGHT, width, height)
			_parse_line(result, word_cells, start, Vector2i.DOWN, width, height)
	return result


static func _parse_line(
	result: RuleSet,
	word_cells: Dictionary,
	start: Vector2i,
	step: Vector2i,
	width: int,
	height: int
) -> void:
	if _words_at(word_cells, start).is_empty():
		return
	if _has_prefix_condition_before(word_cells, start, step):
		return
	var choices: Array = []
	var cell := start
	while _inside_board(cell, width, height):
		var cell_words := _words_at(word_cells, cell)
		if cell_words.is_empty():
			break
		choices.append(cell_words)
		cell += step
	_expand_line(result, choices, 0, [])


static func _expand_line(
	result: RuleSet,
	choices: Array,
	index: int,
	words: Array[RuleGridEntity]
) -> void:
	if index >= choices.size():
		return
	var cell_choices: Variant = choices[index]
	if not cell_choices is Array:
		return
	for choice: Variant in cell_choices:
		if not choice is RuleGridEntity:
			continue
		words.append(choice)
		for sentence: RuleSentence in _parse_tokens(words):
			if sentence.operator == OPERATOR_OWNS \
				and _has_owns_condition_suffix_extension(choices, index):
				continue
			result.add(sentence)
		_expand_line(result, choices, index + 1, words)
		words.pop_back()


static func _parse_tokens(words: Array[RuleGridEntity]) -> Array[RuleSentence]:
	var result: Array[RuleSentence] = []
	if words.size() < 3:
		return result
	var position := 0
	var conditions: Array[Dictionary] = []
	position = _parse_condition_chain(words, position, &"prefix", conditions)

	var subjects: Array[Dictionary] = []
	while position < words.size():
		var subject_negated := false
		if _is_operator(words, position, OPERATOR_NOT):
			subject_negated = true
			position += 1
		if not _has_role(words, position, WORD_NOUN):
			return result
		subjects.append({"value": words[position].word_value, "negated": subject_negated})
		position += 1
		if not _is_operator(words, position, OPERATOR_AND):
			break
		position += 1
		if position >= words.size():
			return result

	position = _parse_condition_chain(words, position, &"infix", conditions)
	if position >= words.size() or not _has_role(words, position, WORD_OPERATOR):
		return result
	var operator_value: StringName = words[position].word_value
	position += 1
	if operator_value == OPERATOR_INSIDE:
		if not _is_operator(words, position, OPERATOR_IS):
			return result
		position += 1
		operator_value = &"INSIDE_IS"
	elif operator_value != OPERATOR_IS and operator_value != OPERATOR_HAS and operator_value != OPERATOR_OWNS:
		return result

	var predicates: Array[Dictionary] = []
	var predicate_role: StringName = &""
	while position < words.size():
		var predicate_negated := false
		if _is_operator(words, position, OPERATOR_NOT):
			predicate_negated = true
			position += 1
		if position >= words.size():
			return result
		var current_role: StringName = words[position].word_role
		if current_role != WORD_NOUN and current_role != WORD_PROPERTY:
			return result
		if predicate_role.is_empty():
			predicate_role = current_role
		elif predicate_role != current_role:
			return result
		predicates.append({"value": words[position].word_value, "negated": predicate_negated})
		position += 1
		if not _is_operator(words, position, OPERATOR_AND):
			break
		position += 1
		if position >= words.size():
			return result
	if predicates.is_empty():
		return result

	if operator_value == OPERATOR_HAS and predicate_role != WORD_NOUN:
		return result
	if operator_value == OPERATOR_OWNS and predicate_role != WORD_NOUN:
		return result
	if operator_value == &"INSIDE_IS" and predicate_role != WORD_NOUN:
		return result
	if operator_value == OPERATOR_IS and predicate_role != WORD_NOUN and predicate_role != WORD_PROPERTY:
		return result

	if operator_value == OPERATOR_OWNS:
		position = _parse_condition_chain(words, position, &"suffix", conditions)
	if position != words.size():
		return result

	var source_cells: Array[Vector2i] = []
	var source_ids: Array[String] = []
	for word: RuleGridEntity in words:
		source_cells.append(word.position)
		source_ids.append(word.id)
	for subject: Dictionary in subjects:
		for predicate: Dictionary in predicates:
			var sentence := RuleSentence.new(
				StringName(subject["value"]),
				operator_value,
				StringName(predicate["value"]),
				predicate_role,
				source_cells
			)
			sentence.subject_is_negated = bool(subject["negated"])
			sentence.is_negated = bool(predicate["negated"])
			sentence.conditions.assign(conditions)
			sentence.source_entity_ids.assign(source_ids)
			result.append(sentence)
	return result


static func _parse_condition_chain(
	words: Array[RuleGridEntity],
	start: int,
	position_kind: StringName,
	conditions: Array[Dictionary]
) -> int:
	var position := start
	while position < words.size() and _is_condition(words, position):
		var kind: StringName = words[position].word_value
		position += 1
		var negated := false
		if _is_operator(words, position, OPERATOR_NOT):
			negated = true
			position += 1
		if not _has_role(words, position, WORD_NOUN):
			return start
		conditions.append({
			"kind": kind,
			"target": words[position].word_value,
			"negated": negated,
			"position": position_kind
		})
		position += 1
		if _is_operator(words, position, OPERATOR_AND) \
			and position + 1 < words.size() \
			and _is_condition(words, position + 1):
			position += 1
			continue
		break
	return position


static func _has_prefix_condition_before(
	word_cells: Dictionary,
	start: Vector2i,
	step: Vector2i
) -> bool:
	var noun_targets := _words_at(word_cells, start - step)
	var condition_words := _words_at(word_cells, start - step * 2)
	var negated_condition_words := _words_at(word_cells, start - step * 3)
	for target: RuleGridEntity in noun_targets:
		if target.word_role != WORD_NOUN:
			continue
		for condition: RuleGridEntity in condition_words:
			if condition.word_role == WORD_OPERATOR and CONDITIONS.has(condition.word_value):
				return true
			if condition.word_role == WORD_OPERATOR and condition.word_value == OPERATOR_NOT:
				for negated_condition: RuleGridEntity in negated_condition_words:
					if negated_condition.word_role == WORD_OPERATOR \
						and CONDITIONS.has(negated_condition.word_value):
						return true
	return false


static func _has_owns_condition_suffix_extension(choices: Array, index: int) -> bool:
	if index + 1 >= choices.size():
		return false
	var condition_choices: Variant = choices[index + 1]
	if not condition_choices is Array:
		return false
	for condition: Variant in condition_choices:
		if not condition is RuleGridEntity or condition.word_role != WORD_OPERATOR \
			or not CONDITIONS.has(condition.word_value):
			continue
		var target_index := index + 2
		if target_index < choices.size():
			var target_choices: Variant = choices[target_index]
			if target_choices is Array:
				for target: Variant in target_choices:
					if target is RuleGridEntity and target.word_role == WORD_NOUN:
						return true
	return false


static func _word_token_for(entity: RuleGridEntity) -> RuleGridEntity:
	if entity.is_word:
		return entity
	if not entity.runtime_tags.has(&"WORD") and not entity.base_tags.has(&"WORD"):
		return null
	var word := RuleGridEntity.new()
	word.id = entity.id
	word.kind = entity.kind
	word.position = entity.position
	word.is_word = true
	word.word_role = WORD_NOUN
	word.word_value = entity.kind
	return word


static func _words_at(word_cells: Dictionary, cell: Vector2i) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	for entity: Variant in word_cells.get(cell, []):
		if entity is RuleGridEntity:
			result.append(entity)
	return result


static func _has_role(words: Array[RuleGridEntity], position: int, role: StringName) -> bool:
	return position >= 0 and position < words.size() and words[position].word_role == role


static func _is_operator(words: Array[RuleGridEntity], position: int, value: StringName) -> bool:
	return _has_role(words, position, WORD_OPERATOR) and words[position].word_value == value


static func _is_condition(words: Array[RuleGridEntity], position: int) -> bool:
	return _has_role(words, position, WORD_OPERATOR) and CONDITIONS.has(words[position].word_value)


static func _inside_board(cell: Vector2i, width: int, height: int) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height
