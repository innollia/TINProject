class_name DescentState
extends RefCounted

const SCHEMA: int = 1
const MODULE_ID: String = "descent_exploration"
const PHASES: Array[String] = ["first_frame", "playing", "transition", "ending", "finished"]
const ENDING_IDS: Array[String] = ["ending.hollow", "ending.return", "ending.swallow"]
const INTEGRITY_MAX: int = 3
const MAX_CARRY_MASS: int = 4
const DEFAULT_POSITION: Vector2 = Vector2(320.0, 96.0)
const DEFAULT_STRATUM_ID: String = "stratum_roots"
const WORLD_W: float = 640.0
const WORLD_H: float = 1024.0
const SEED_MAX: int = 2147483647
const BASE_BOX: Vector2 = Vector2(9.0, 7.0)
const BOX_PER_MASS: Vector2 = Vector2(2.0, 2.0)

var schema: int = SCHEMA
var run_id: String = ""
var world_seed: int = 0
var phase: String = "first_frame"
var stratum_index: int = 0
var stratum_id: String = DEFAULT_STRATUM_ID
var facts: FactLedger = FactLedger.new()
var mass: int = 0
var carried: Array[MatterItem] = []
var consumed: Array[Dictionary] = []
var position: Vector2 = DEFAULT_POSITION
var velocity: Vector2 = Vector2.ZERO
var facing: int = 1
var integrity: int = INTEGRITY_MAX
var invulnerable_for: float = 0.0
var surge_cooldown_for: float = 0.0
var surge_active_for: float = 0.0
var surge_vector: Vector2 = Vector2.ZERO
var downed_for: float = 0.0
var anchors_taken: Array[String] = []
var sites_done: Array[String] = []
var routes_opened: Array[String] = []
var open_bristles: Array[String] = []
var checkpoint: Dictionary = {}
var ending_id: String = ""
var elapsed_play: float = 0.0
var transition_pending: bool = false
var transition_to: String = ""
var flow: Vector2 = Vector2.ZERO
var phase_time: float = 0.0


static func new_state() -> DescentState:
	return DescentState.new()


func is_downed() -> bool:
	return integrity <= 0


func carried_mass() -> int:
	var total: int = 0
	for item: MatterItem in carried:
		total += item.size
	return total


func recompute_mass() -> void:
	mass = clampi(carried_mass(), 0, MAX_CARRY_MASS)


static func box_size(for_mass: int) -> Vector2:
	var clamped: int = clampi(for_mass, 0, MAX_CARRY_MASS)
	return BASE_BOX + BOX_PER_MASS * float(clamped)


static func box_at(at: Vector2, for_mass: int) -> Rect2:
	var size: Vector2 = box_size(for_mass)
	return Rect2(at - size * 0.5, size)


func body_box() -> Rect2:
	return box_at(position, mass)


func enter_stratum(id: String, index: int, spawn_position: Vector2, spawn_facing: int) -> void:
	stratum_id = id
	stratum_index = maxi(index, 0)
	position = spawn_position
	velocity = Vector2.ZERO
	flow = Vector2.ZERO
	facing = -1 if spawn_facing < 0 else 1
	surge_active_for = 0.0
	surge_vector = Vector2.ZERO
	transition_pending = false
	transition_to = ""
	open_bristles.clear()


func add_fact(id: String) -> bool:
	return facts.grant(id)


func pick_up(item: MatterItem) -> bool:
	if item == null or item.size < MatterItem.SIZE_MIN:
		return false
	if carried_mass() + item.size > MAX_CARRY_MASS:
		return false
	carried.append(item)
	recompute_mass()
	return true


func consume(index: int, site_id: String) -> bool:
	if index < 0 or index >= carried.size():
		return false
	var item: MatterItem = carried[index]
	carried.remove_at(index)
	recompute_mass()
	consumed.append({"matter": item.id, "site": site_id, "stratum": stratum_id})
	return true


func apply_damage(amount: int) -> bool:
	if amount <= 0 or integrity <= 0 or invulnerable_for > 0.0:
		return false
	integrity = maxi(0, integrity - amount)
	if integrity == 0:
		downed_for = 0.0
	return true


func carried_ids() -> Array[String]:
	var ids: Array[String] = []
	for item: MatterItem in carried:
		ids.append(item.id)
	return ids


func consumed_matter_ids() -> Array[String]:
	var ids: Array[String] = []
	for record: Dictionary in consumed:
		ids.append(String(record.get("matter", "")))
	return ids


func carried_dictionaries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item: MatterItem in carried:
		out.append(item.to_dictionary())
	return out


func make_checkpoint(anchor_id: String, at: Vector2) -> Dictionary:
	return {
		"stratum_id": stratum_id,
		"anchor_id": anchor_id,
		"position": [at.x, at.y],
		"mass": mass,
		"facts": facts.to_array(),
		"carried": carried_dictionaries(),
	}


func reset_transients() -> void:
	velocity = Vector2.ZERO
	flow = Vector2.ZERO
	invulnerable_for = 0.0
	surge_cooldown_for = 0.0
	surge_active_for = 0.0
	surge_vector = Vector2.ZERO
	downed_for = 0.0
	transition_pending = false
	transition_to = ""
	open_bristles.clear()
	phase_time = 0.0
	elapsed_play = 0.0


func to_save() -> Dictionary:
	return {
		"schema": SCHEMA,
		"module_id": MODULE_ID,
		"run_id": run_id,
		"world_seed": world_seed,
		"phase": phase,
		"stratum_index": stratum_index,
		"stratum_id": stratum_id,
		"facts": facts.to_array(),
		"mass": mass,
		"carried": carried_dictionaries(),
		"consumed": consumed.duplicate(true),
		"position": [position.x, position.y],
		"facing": facing,
		"integrity": integrity,
		"anchors_taken": anchors_taken.duplicate(),
		"sites_done": sites_done.duplicate(),
		"routes_opened": routes_opened.duplicate(),
		"checkpoint": checkpoint.duplicate(true),
		"ending_id": ending_id,
	}


static func from_save(data: Dictionary) -> DescentState:
	var state := DescentState.new()
	state.schema = SCHEMA
	state.run_id = _read_string(data.get("run_id"), "")
	state.world_seed = clampi(_read_int(data.get("world_seed"), 0), 0, SEED_MAX)
	var raw_phase: String = _read_string(data.get("phase"), "first_frame")
	state.phase = raw_phase if PHASES.has(raw_phase) else "first_frame"
	state.stratum_index = maxi(_read_int(data.get("stratum_index"), 0), 0)
	state.stratum_id = _read_string(data.get("stratum_id"), DEFAULT_STRATUM_ID)
	state.facts.from_array(data.get("facts", []))
	state.carried = read_carried(data.get("carried", []))
	state.recompute_mass()
	state.consumed = _read_consumed(data.get("consumed", []))
	state.position = read_position(data.get("position"), DEFAULT_POSITION)
	state.facing = -1 if _read_int(data.get("facing"), 1) < 0 else 1
	state.integrity = clampi(_read_int(data.get("integrity"), INTEGRITY_MAX), 0, INTEGRITY_MAX)
	state.anchors_taken = _read_strings(data.get("anchors_taken", []))
	state.sites_done = _read_strings(data.get("sites_done", []))
	state.routes_opened = _read_strings(data.get("routes_opened", []))
	state.checkpoint = read_checkpoint(data.get("checkpoint", {}))
	var raw_ending: String = _read_string(data.get("ending_id"), "")
	state.ending_id = raw_ending if ENDING_IDS.has(raw_ending) else ""
	return state


static func read_carried(source: Variant) -> Array[MatterItem]:
	var items: Array[MatterItem] = []
	if not source is Array:
		return items
	for entry: Variant in source as Array:
		var item: MatterItem = MatterItem.from_dictionary(entry)
		if item != null:
			items.append(item)
	var total: int = 0
	for item: MatterItem in items:
		total += item.size
	while total > MAX_CARRY_MASS and not items.is_empty():
		total -= items[items.size() - 1].size
		items.remove_at(items.size() - 1)
	return items


static func read_position(source: Variant, fallback: Vector2) -> Vector2:
	if not source is Array or (source as Array).size() != 2:
		return fallback
	var pair: Array = source
	if not (pair[0] is int or pair[0] is float) or not (pair[1] is int or pair[1] is float):
		return fallback
	var x: float = float(pair[0])
	var y: float = float(pair[1])
	if not is_finite(x) or not is_finite(y):
		return fallback
	return Vector2(clampf(x, 0.0, WORLD_W), clampf(y, 0.0, WORLD_H))


static func read_checkpoint(source: Variant) -> Dictionary:
	if not source is Dictionary or (source as Dictionary).is_empty():
		return {}
	var data: Dictionary = source
	var id: String = _read_string(data.get("stratum_id"), "")
	var anchor: String = _read_string(data.get("anchor_id"), "")
	if id.is_empty() or anchor.is_empty():
		return {}
	var spot: Vector2 = read_position(data.get("position"), Vector2(-1.0, -1.0))
	if spot.x < 0.0:
		return {}
	var items: Array[MatterItem] = read_carried(data.get("carried", []))
	var dictionaries: Array[Dictionary] = []
	var total: int = 0
	for item: MatterItem in items:
		dictionaries.append(item.to_dictionary())
		total += item.size
	var ledger := FactLedger.new()
	ledger.from_array(data.get("facts", []))
	return {
		"stratum_id": id,
		"anchor_id": anchor,
		"position": [spot.x, spot.y],
		"mass": total,
		"facts": ledger.to_array(),
		"carried": dictionaries,
	}


static func _read_consumed(source: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if not source is Array:
		return records
	for entry: Variant in source as Array:
		if not entry is Dictionary:
			continue
		var record: Dictionary = entry
		var matter: Variant = record.get("matter")
		var site: Variant = record.get("site")
		var stratum: Variant = record.get("stratum")
		if matter is String and site is String and stratum is String and not (matter as String).is_empty():
			records.append({"matter": matter, "site": site, "stratum": stratum})
	return records


static func _read_strings(source: Variant) -> Array[String]:
	var values: Array[String] = []
	if not source is Array:
		return values
	for entry: Variant in source as Array:
		if entry is String and not (entry as String).is_empty() and not values.has(entry as String):
			values.append(entry as String)
	return values


static func _read_string(source: Variant, fallback: String) -> String:
	return source as String if source is String else fallback


static func _read_int(source: Variant, fallback: int) -> int:
	if source is int:
		return source as int
	if source is float and is_finite(source as float):
		return int(source as float)
	return fallback
