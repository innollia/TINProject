class_name EcoSocialTable
extends RefCounted

const NEUTRAL: int = 0
const FLEE: int = 1
const DEFEND: int = 2
const ATTACK: int = 3
const AVOID: int = 4
const NAMES: Array[String] = ["NEUTRAL", "FLEE", "DEFEND", "ATTACK", "AVOID"]
const TABLE: Dictionary = {
	"skitter": [NEUTRAL, NEUTRAL, FLEE],
	"warden": [NEUTRAL, NEUTRAL, ATTACK],
	"maw": [NEUTRAL, NEUTRAL, ATTACK],
	"anchor": [NEUTRAL, NEUTRAL, ATTACK],
	"brood": [NEUTRAL, FLEE, ATTACK],
}
const PACK_RAISE: Dictionary = {FLEE: NEUTRAL, NEUTRAL: ATTACK, ATTACK: ATTACK, AVOID: FLEE, DEFEND: ATTACK}


static func lookup(axis_name: String, player_rung_index: int) -> int:
	var row: Array = TABLE.get(axis_name, [])
	if player_rung_index < 0 or player_rung_index >= row.size():
		return NEUTRAL
	return int(row[player_rung_index])


static func raised(society: int) -> int:
	return int(PACK_RAISE.get(society, society))


static func cell_count() -> int:
	var n: int = 0
	for k: String in TABLE.keys():
		n += (TABLE[k] as Array).size()
	return n
