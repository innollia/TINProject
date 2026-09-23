class_name RuleEvaluator
extends RefCounted


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
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	var changed_ids: Array[String] = []
	var created_ids: Array[String] = []
	var clones: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in ordered:
		if entity.is_word or processed_ids.has(entity.id):
			continue
		var outputs := _unique_nouns(rules.transforms_for(entity.kind))
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
	clone.is_word = false
	clone.base_tags.assign(source.base_tags)
	clone.runtime_tags.assign(source.runtime_tags)
	return clone


static func _unique_id(prefix: String, used_ids: Dictionary) -> String:
	var candidate := prefix
	var suffix := 1
	while used_ids.has(candidate):
		candidate = "%s::%d" % [prefix, suffix]
		suffix += 1
	return candidate
