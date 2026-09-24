class_name RuleSentence
extends RefCounted

var subject: StringName
var operator: StringName
var predicate: StringName
var predicate_role: StringName
var source_cells: Array[Vector2i] = []
var source_entity_ids: Array[String] = []
var conditions: Array[Dictionary] = []
var subject_is_negated: bool = false
var is_negated: bool = false


func _init(
	new_subject: StringName = &"",
	new_operator: StringName = &"",
	new_predicate: StringName = &"",
	new_predicate_role: StringName = &"",
	new_source_cells: Array[Vector2i] = []
) -> void:
	subject = new_subject
	operator = new_operator
	predicate = new_predicate
	predicate_role = new_predicate_role
	source_cells.assign(new_source_cells)


func has_same_meaning(other: RuleSentence) -> bool:
	return subject == other.subject \
		and subject_is_negated == other.subject_is_negated \
		and operator == other.operator \
		and predicate == other.predicate \
		and predicate_role == other.predicate_role \
		and is_negated == other.is_negated \
		and conditions == other.conditions


func merge_sources(other: RuleSentence) -> void:
	for source_id: String in other.source_entity_ids:
		if not source_entity_ids.has(source_id):
			source_entity_ids.append(source_id)
	for source_cell: Vector2i in other.source_cells:
		if not source_cells.has(source_cell):
			source_cells.append(source_cell)
