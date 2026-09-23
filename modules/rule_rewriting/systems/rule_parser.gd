class_name RuleParser
extends RefCounted

const WORD_NOUN: StringName = &"noun"
const WORD_OPERATOR: StringName = &"operator"
const WORD_PROPERTY: StringName = &"property"
const OPERATOR_IS: StringName = &"IS"


static func parse(width: int, height: int, entities: Array[RuleGridEntity]) -> RuleSet:
	var result := RuleSet.new()
	if width <= 0 or height <= 0:
		return result

	var word_cells: Dictionary = {}
	var words: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in entities:
		if entity != null:
			words.append(entity)
	words.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	for entity: RuleGridEntity in words:
		if not entity.is_word or not _inside_board(entity.position, width, height):
			continue
		var cell_words := _words_at(word_cells, entity.position)
		cell_words.append(entity)
		word_cells[entity.position] = cell_words

	for y: int in range(height):
		for x: int in range(width):
			var start := Vector2i(x, y)
			_parse_line(result, word_cells, start, Vector2i.RIGHT)
			_parse_line(result, word_cells, start, Vector2i.DOWN)
	return result


static func _parse_line(
	result: RuleSet,
	word_cells: Dictionary,
	start: Vector2i,
	step: Vector2i
) -> void:
	var first := _words_at(word_cells, start)
	var second := _words_at(word_cells, start + step)
	var third := _words_at(word_cells, start + step * 2)
	for subject: RuleGridEntity in first:
		if subject.word_role != WORD_NOUN:
			continue
		for operator_word: RuleGridEntity in second:
			if operator_word.word_role != WORD_OPERATOR or operator_word.word_value != OPERATOR_IS:
				continue
			for predicate: RuleGridEntity in third:
				if predicate.word_role != WORD_PROPERTY and predicate.word_role != WORD_NOUN:
					continue
				var sentence := RuleSentence.new(
					subject.word_value,
					operator_word.word_value,
					predicate.word_value,
					predicate.word_role,
					[start, start + step, start + step * 2]
				)
				result.add(sentence)


static func _words_at(word_cells: Dictionary, cell: Vector2i) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	for entity: Variant in word_cells.get(cell, []):
		if entity is RuleGridEntity:
			result.append(entity)
	return result


static func _inside_board(cell: Vector2i, width: int, height: int) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height
