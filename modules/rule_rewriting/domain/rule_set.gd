class_name RuleSet
extends RefCounted

var sentences: Array[RuleSentence] = []


func clear() -> void:
	sentences.clear()


func add(sentence: RuleSentence) -> void:
	for existing: RuleSentence in sentences:
		if existing.has_same_meaning(sentence):
			existing.merge_sources(sentence)
			return
	sentences.append(sentence)


func has_property(noun: StringName, property: StringName) -> bool:
	var has_positive := false
	var has_negative := false
	for sentence: RuleSentence in sentences:
		if _is_query_match(sentence, noun, property, &"property"):
			if sentence.is_negated:
				has_negative = true
			else:
				has_positive = true
	return has_positive and not has_negative


func transforms_for(noun: StringName) -> Array[StringName]:
	var candidates: Array[StringName] = []
	for sentence: RuleSentence in sentences:
		if sentence.operator != &"IS" or sentence.conditions.size() > 0 \
			or sentence.predicate_role != &"noun" or not _subject_matches(sentence, noun):
			continue
		if not candidates.has(sentence.predicate):
			candidates.append(sentence.predicate)
	var result: Array[StringName] = []
	for candidate: StringName in candidates:
		var suppressed := false
		for sentence: RuleSentence in sentences:
			if _is_query_match(sentence, noun, candidate, &"noun") and sentence.is_negated:
				suppressed = true
				break
		if not suppressed:
			result.append(candidate)
	return result


func properties_for(noun: StringName) -> Array[StringName]:
	var candidates: Array[StringName] = []
	for sentence: RuleSentence in sentences:
		if sentence.operator != &"IS" or sentence.conditions.size() > 0 \
			or sentence.predicate_role != &"property" or not _subject_matches(sentence, noun):
			continue
		if not candidates.has(sentence.predicate):
			candidates.append(sentence.predicate)
	var result: Array[StringName] = []
	for candidate: StringName in candidates:
		if has_property(noun, candidate):
			result.append(candidate)
	return result


func _is_query_match(
	sentence: RuleSentence,
	noun: StringName,
	predicate: StringName,
	predicate_role: StringName
) -> bool:
	return sentence.operator == &"IS" \
		and sentence.conditions.is_empty() \
		and sentence.predicate_role == predicate_role \
		and sentence.predicate == predicate \
		and _subject_matches(sentence, noun)


func _subject_matches(sentence: RuleSentence, noun: StringName) -> bool:
	if sentence.subject_is_negated:
		return sentence.subject != noun
	return sentence.subject == noun
