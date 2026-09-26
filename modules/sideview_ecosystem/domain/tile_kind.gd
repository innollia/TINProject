class_name EcoTileKind
extends RefCounted

const EMPTY: int = 0
const SOLID: int = 1
const ONE_WAY: int = 2
const SALT: int = 3
const DRIFT: int = 4
const SOIL: int = 5
const CHARS: Array[String] = [".", "#", "=", "s", "d", "p"]
const MATERIALS: Array[String] = ["", "mat.slate", "mat.plank", "mat.salt", "mat.drift_powder", "mat.pressed_soil"]
const NAMES: Array[String] = ["EMPTY", "SOLID", "ONE_WAY", "SALT", "DRIFT", "SOIL"]


static func from_char(c: String) -> int:
	return CHARS.find(c)


static func is_solid(k: int) -> bool:
	return k == SOLID or k == SALT or k == DRIFT


static func is_one_way(k: int) -> bool:
	return k == ONE_WAY


static func material_of(k: int) -> String:
	if k < 0 or k >= MATERIALS.size():
		return ""
	return MATERIALS[k]
