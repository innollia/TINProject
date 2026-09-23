class_name RuleSet
extends RefCounted

var sentences: Array[RuleSentence] = []


func clear() -> void:
	sentences.clear()


func add(sentence: RuleSentence) -> void:
	for existing: RuleSentence in sentences:
		if existing.has_same_meaning(sentence):
			return
	sentences.append(sentence)


func has_property(noun: StringName, property: StringName) -> bool:
	for sentence: RuleSentence in sentences:
		if sentence.subject == noun \
			and sentence.predicate_role == &"property" \
			and sentence.predicate == property:
			return true
	return false


func transforms_for(noun: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for sentence: RuleSentence in sentences:
		if sentence.subject == noun and sentence.predicate_role == &"noun":
			result.append(sentence.predicate)
	return result


func properties_for(noun: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for sentence: RuleSentence in sentences:
		if sentence.subject == noun and sentence.predicate_role == &"property":
			result.append(sentence.predicate)
	return result
