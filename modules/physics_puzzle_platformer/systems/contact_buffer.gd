extends RefCounted

const InteractionRules = preload("res://modules/physics_puzzle_platformer/domain/interaction_rules.gd")

var _entries: Array[Dictionary] = []


func clear() -> void:
	_entries.clear()


func size() -> int:
	return _entries.size()


func add(entry: Dictionary, kind_a: int, kind_b: int) -> void:
	var code: StringName = InteractionRules.rule_for(kind_a, kind_b)
	entry["code"] = code
	entry["order"] = _entries.size()
	entry["key"] = sort_key(code, kind_a, kind_b, mini(int(entry.get("a", 0)), int(entry.get("b", 0))), _entries.size())
	_entries.append(entry)


static func sort_key(code: StringName, kind_a: int, kind_b: int, body_index: int, order: int) -> int:
	var tier: int = InteractionRules.tier_of(code)
	var rank: int = mini(InteractionRules.rank_of(kind_a), InteractionRules.rank_of(kind_b))
	return (((tier * 16 + rank) * 1024 + clampi(body_index, 0, 1023)) * 65536) + clampi(order, 0, 65535)


func sorted() -> Array[Dictionary]:
	var keys: Array[int] = []
	var by_key: Dictionary = {}
	for entry: Dictionary in _entries:
		var key: int = int(entry["key"])
		keys.append(key)
		by_key[key] = entry
	keys.sort()
	var result: Array[Dictionary] = []
	for key: int in keys:
		result.append(by_key[key])
	return result
