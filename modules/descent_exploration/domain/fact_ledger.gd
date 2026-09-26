class_name FactLedger
extends RefCounted

var _ids: Array[String] = []


func has(id: String) -> bool:
	return _ids.has(id)


func grant(id: String) -> bool:
	if id.is_empty() or _ids.has(id):
		return false
	_ids.append(id)
	return true


func size() -> int:
	return _ids.size()


func is_empty() -> bool:
	return _ids.is_empty()


func to_array() -> Array[String]:
	return _ids.duplicate()


func from_array(values: Variant) -> void:
	_ids.clear()
	if not values is Array:
		return
	for value: Variant in values as Array:
		if value is String and not (value as String).is_empty() and not _ids.has(value as String):
			_ids.append(value as String)


func copy() -> FactLedger:
	var clone := FactLedger.new()
	clone._ids = _ids.duplicate()
	return clone
