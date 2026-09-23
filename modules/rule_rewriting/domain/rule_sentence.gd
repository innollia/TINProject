class_name RuleSentence
extends RefCounted

var subject: StringName
var operator: StringName
var predicate: StringName
var predicate_role: StringName
var source_cells: Array[Vector2i] = []


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
		and operator == other.operator \
		and predicate == other.predicate \
		and predicate_role == other.predicate_role
