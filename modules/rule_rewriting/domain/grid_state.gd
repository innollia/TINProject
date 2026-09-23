class_name RuleGridState
extends RefCounted

var width: int
var height: int
var entities: Array[RuleGridEntity] = []


func to_dictionary() -> Dictionary:
	var serialized_entities: Array[Dictionary] = []
	var ordered: Array[RuleGridEntity] = []
	ordered.assign(entities)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	for entity: RuleGridEntity in ordered:
		serialized_entities.append(entity.to_dictionary())
	return {"width": width, "height": height, "entities": serialized_entities}


static func from_dictionary(data: Variant) -> RuleGridState:
	if not data is Dictionary:
		return null
	var width_value: Variant = data.get("width")
	var height_value: Variant = data.get("height")
	var entity_values: Variant = data.get("entities")
	if not RuleGridEntity._is_integer(width_value) or not RuleGridEntity._is_integer(height_value) \
		or int(width_value) < 1 or int(width_value) > 32 \
		or int(height_value) < 1 or int(height_value) > 32 \
		or not entity_values is Array:
		return null
	var state := RuleGridState.new()
	state.width = int(width_value)
	state.height = int(height_value)
	var ids: Dictionary = {}
	for value: Variant in entity_values:
		var entity := RuleGridEntity.from_dictionary(value)
		if entity == null \
			or ids.has(entity.id) \
			or entity.position.x < 0 or entity.position.y < 0 \
			or entity.position.x >= state.width or entity.position.y >= state.height:
			return null
		ids[entity.id] = true
		state.entities.append(entity)
	return state
