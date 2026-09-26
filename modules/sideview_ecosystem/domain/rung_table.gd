class_name EcoRungTable
extends RefCounted

const USED_NAMES: Array[String] = ["speck", "hand", "doll"]
const SPEC: Dictionary = {
	"speck": {"run_speed": 168.0, "accel": 1100.0, "jump_height": 156.0, "safe_fall_speed": 900.0, "max_climb": 24.0, "break_power": 0},
	"hand": {"run_speed": 156.0, "accel": 1012.0, "jump_height": 252.0, "safe_fall_speed": 1200.0, "max_climb": 24.0, "break_power": 2},
	"doll": {"run_speed": 168.0, "accel": 1100.0, "jump_height": 300.0, "safe_fall_speed": 1500.0, "max_climb": 24.0, "break_power": 4},
}
const REASON_LADDER_MISMATCH: String = "ladder_invalid"

var ladder: EcoLadder
var _by_name: Dictionary = {}


static func make(p_ladder: EcoLadder) -> Dictionary:
	if p_ladder == null:
		return {"ok": false, "reason": REASON_LADDER_MISMATCH, "detail": "no ladder", "value": null}
	for i: int in USED_NAMES.size():
		if p_ladder.index_of(USED_NAMES[i]) != i:
			return {"ok": false, "reason": REASON_LADDER_MISMATCH, "detail": "ladder order differs at " + USED_NAMES[i], "value": null}
	var table: EcoRungTable = EcoRungTable.new()
	table.ladder = p_ladder
	for i: int in USED_NAMES.size():
		var n: String = USED_NAMES[i]
		var row: Dictionary = SPEC[n]
		var body: EcoBodyRung = EcoBodyRung.new()
		body.rung = n
		body.index = i
		body.scale_value = p_ladder.value_of(n)
		body.run_speed = float(row["run_speed"])
		body.accel = float(row["accel"])
		body.jump_height = float(row["jump_height"])
		body.safe_fall_speed = float(row["safe_fall_speed"])
		body.max_climb = float(row["max_climb"])
		body.break_power = int(row["break_power"])
		table._by_name[n] = body
	return {"ok": true, "reason": "", "detail": "", "value": table}


func names() -> Array[String]:
	return USED_NAMES.duplicate()


func has_name(n: String) -> bool:
	return _by_name.has(n)


func by_name(n: String) -> EcoBodyRung:
	return _by_name.get(n) as EcoBodyRung


func index_of(n: String) -> int:
	return USED_NAMES.find(n)


func band_value(band_name: String) -> float:
	return ladder.value_of(band_name)


func abilities_of(n: String, band_name: String) -> int:
	var body: EcoBodyRung = by_name(n)
	if body == null:
		return 0
	return body.abilities_in(band_value(band_name))


func from_axis_value(v: float) -> EcoBodyRung:
	for n: String in USED_NAMES:
		var body: EcoBodyRung = _by_name[n]
		if is_equal_approx(body.scale_value, v):
			return body
	return null
