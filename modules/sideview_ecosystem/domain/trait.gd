class_name EcoTrait
extends RefCounted

const FLEX: StringName = &"FLEX"
const POISE: StringName = &"POISE"
const LEAP: StringName = &"LEAP"
const SHELL: StringName = &"SHELL"
const CLAW: StringName = &"CLAW"
const ORDER: Array[StringName] = [FLEX, POISE, LEAP, SHELL, CLAW]

const ABILITY_FLEX_GAP_MULT: float = 0.85
const ABILITY_POISE_FALL_PX: float = 2000.0
const ABILITY_LEAP_REACH_PX: float = 290.0
const ABILITY_SHELL_POWER: int = 2
const ABILITY_CLAW_POWER: int = 4


static func bit(id: StringName) -> int:
	var index: int = ORDER.find(id)
	if index < 0:
		return 0
	return 1 << index


static func has(mask: int, id: StringName) -> bool:
	var b: int = bit(id)
	return b != 0 and (mask & b) == b


static func add(mask: int, id: StringName) -> int:
	return mask | bit(id)


static func remove(mask: int, id: StringName) -> int:
	return mask & ~bit(id)


static func contains_all(mask: int, other: int) -> bool:
	return (mask & other) == other


static func names_of(mask: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in ORDER:
		if has(mask, id):
			out.append(id)
	return out
