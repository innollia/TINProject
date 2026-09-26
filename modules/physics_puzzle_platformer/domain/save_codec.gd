extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const RunState = preload("res://modules/physics_puzzle_platformer/domain/run_state.gd")
const WorldState = preload("res://modules/physics_puzzle_platformer/domain/world_state.gd")

const SCHEMA: int = 3
const MODULE_ID: String = "physics_puzzle_platformer"
const MUTATION_OPS: Array[String] = ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"]
const SAVED_KINDS: Array[int] = [
	BodyKind.PLAYER, BodyKind.TOOL_CARRIED, BodyKind.TOOL_PLACEMENT, BodyKind.OBJECTIVE, BodyKind.PROP_DYNAMIC,
	BodyKind.PROP_SLEEPING, BodyKind.OBSTACLE_DYNAMIC, BodyKind.DECOR_DYNAMIC,
]
const BUBBLE_STATES: Array[String] = ["intact", "popped", "rising", "restoring"]


static func encode(run: RefCounted, world: RefCounted) -> Dictionary:
	var sequence: Array = []
	for entry: Dictionary in run.sequence:
		sequence.append({"level_id": String(entry.get("level_id", "")), "mutations": encode_mutations(entry.get("mutations", []))})
	var data: Dictionary = {
		"schema": SCHEMA,
		"module": MODULE_ID,
		"run": {
			"run_seed": run.run_seed,
			"run_index": run.run_index,
			"cursor": run.cursor,
			"run_complete": run.run_complete,
			"total_objectives": run.total_objectives,
			"sequence": sequence,
			"tool_ids": Array(run.tool_ids),
			"levels_seen": _count_dictionary(run.levels_seen),
			"tools_seen": _count_dictionary(run.tools_seen),
			"completed_levels": Array(run.completed_levels),
			"deaths": run.deaths,
			"resets": run.resets,
			"tools_used": run.tools_used,
			"bubble": _encode_bubble(run.bubble),
		},
		"world": {},
	}
	if world != null and not world.level_id.is_empty() and (world.phase == WorldState.PHASE_PLAY or world.phase == WorldState.PHASE_INTRO):
		data["world"] = encode_world(world)
	return data


static func encode_world(world: RefCounted) -> Dictionary:
	var bodies: Array = []
	var held_seen: bool = false
	for body: RefCounted in world.bodies:
		if not SAVED_KINDS.has(body.kind):
			continue
		var held: bool = body.held and body.kind == BodyKind.TOOL_CARRIED and not held_seen and not body.destroyed
		if held:
			held_seen = true
		var finite: bool = _all_finite([body.x, body.y, body.angle, body.vx, body.vy, body.av, body.hp, body.t, body.tool_cooldown])
		bodies.append({
			"spec_id": body.spec_id,
			"kind": body.kind,
			"x": _finite(body.x),
			"y": _finite(body.y),
			"angle": _finite(body.angle),
			"vx": _finite(body.vx),
			"vy": _finite(body.vy),
			"av": _finite(body.av),
			"sleeping": body.sleeping,
			"hp": _finite(body.hp),
			"destroyed": body.destroyed or not finite,
			"collected": body.collected,
			"t": _finite(body.t),
			"held": held,
			"tool_id": body.tool_id,
			"tool_cooldown": _finite(body.tool_cooldown),
			"frozen": false,
		})
	return {
		"slot": world.slot,
		"level_id": world.level_id,
		"applied_mutations": encode_mutations(world.applied_mutations),
		"phase": String(world.phase),
		"objective_count": world.objective_count,
		"objective_needed": world.objective_needed,
		"player_hp": _finite(world.player_hp),
		"deaths": world.deaths,
		"resets": world.resets,
		"elapsed": _finite(world.elapsed),
		"kin_time": _finite(world.kin_time),
		"tools_used": world.tools_used,
		"hitstop": clampf(_finite(world.hitstop), 0.0, Tuning.HITSTOP),
		"bodies": bodies,
	}


static func encode_mutations(value: Variant) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for item: Variant in value:
		if item is Dictionary and MUTATION_OPS.has(String((item as Dictionary).get("op", ""))):
			var arg: Variant = (item as Dictionary).get("arg", 0)
			if not (arg is int or arg is float) or not is_finite(float(arg)):
				continue
			result.append({"op": String(item["op"]), "arg": arg})
	return result


static func migrate(old_version: int, data: Dictionary) -> Dictionary:
	var result: Dictionary = data.duplicate(true)
	if old_version >= SCHEMA:
		return result
	if old_version <= 1:
		var world_v1: Variant = result.get("world", {})
		if world_v1 is Dictionary:
			var world_dict: Dictionary = world_v1
			if not world_dict.has("objective_needed"):
				world_dict["objective_needed"] = world_dict.get("objective_target", 2)
			world_dict.erase("objective_target")
	var run_v2: Variant = result.get("run", {})
	if run_v2 is Dictionary:
		var run_dict: Dictionary = run_v2
		if not run_dict.has("cursor"):
			run_dict["cursor"] = 0
		var sequence: Variant = run_dict.get("sequence", [])
		if sequence is Array:
			for entry: Variant in sequence:
				if entry is Dictionary and (entry as Dictionary).has("level") and not (entry as Dictionary).has("level_id"):
					entry["level_id"] = entry["level"]
					(entry as Dictionary).erase("level")
	var world_v2: Variant = result.get("world", {})
	if world_v2 is Dictionary:
		var bodies: Variant = (world_v2 as Dictionary).get("bodies", [])
		if bodies is Array:
			for body: Variant in bodies:
				if body is Dictionary and (body as Dictionary).has("body_id") and not (body as Dictionary).has("spec_id"):
					body["spec_id"] = body["body_id"]
					(body as Dictionary).erase("body_id")
	result["schema"] = SCHEMA
	result["module"] = MODULE_ID
	return result


static func decode(data: Variant, level_ids: Array, tool_ids: Array) -> Dictionary:
	var outcome: Dictionary = {"has_run": false, "rejected": false, "found_version": 0, "run": null, "world": {}, "resequence": false, "reassign_slots": [], "reassign_tools": []}
	if not data is Dictionary or (data as Dictionary).is_empty():
		return outcome
	var raw: Dictionary = data
	var version: int = int(_number(raw.get("schema", SCHEMA), SCHEMA))
	if version > SCHEMA:
		outcome["rejected"] = true
		outcome["found_version"] = version
		return outcome
	if version < SCHEMA:
		raw = migrate(version, raw)
	var run_raw: Variant = raw.get("run", {})
	if not run_raw is Dictionary:
		return outcome
	var run: RefCounted = RunState.new()
	var run_dict: Dictionary = run_raw
	outcome["has_run"] = true
	run.run_index = maxi(int(_number(run_dict.get("run_index", 0), 0)), 0)
	run.run_complete = bool(run_dict.get("run_complete", false)) if run_dict.get("run_complete", false) is bool else false
	run.cursor = clampi(int(_number(run_dict.get("cursor", 0), 0)), 0, Tuning.LEVEL_COUNT)
	run.total_objectives = maxi(int(_number(run_dict.get("total_objectives", 0), 0)), 0)
	run.deaths = maxi(int(_number(run_dict.get("deaths", 0), 0)), 0)
	run.resets = maxi(int(_number(run_dict.get("resets", 0), 0)), 0)
	run.tools_used = maxi(int(_number(run_dict.get("tools_used", 0), 0)), 0)
	run.levels_seen = _count_dictionary(run_dict.get("levels_seen", {}))
	run.tools_seen = _count_dictionary(run_dict.get("tools_seen", {}))
	var completed_raw: Variant = run_dict.get("completed_levels", [])
	if completed_raw is Array:
		for value: Variant in completed_raw:
			if _is_integer(value) and int(value) >= 0 and int(value) < Tuning.LEVEL_COUNT and not run.completed_levels.has(int(value)):
				run.completed_levels.append(int(value))
	run.bubble = _decode_bubble(run_dict.get("bubble", {}))
	var seed_value: Variant = run_dict.get("run_seed", 0)
	var sequence_raw: Variant = run_dict.get("sequence", [])
	var tools_raw: Variant = run_dict.get("tool_ids", [])
	if not RunState.seed_is_valid(seed_value) or not sequence_raw is Array or (sequence_raw as Array).size() != Tuning.LEVEL_COUNT or not tools_raw is Array or (tools_raw as Array).size() != Tuning.TOOL_COUNT:
		outcome["resequence"] = true
		run.cursor = 0
		run.run_complete = false
		run.completed_levels.clear()
		outcome["run"] = run
		return outcome
	run.run_seed = int(seed_value)
	for index: int in (sequence_raw as Array).size():
		var entry: Variant = sequence_raw[index]
		var level_id: String = ""
		var mutations: Array = []
		if entry is Dictionary:
			level_id = String((entry as Dictionary).get("level_id", "")) if (entry as Dictionary).get("level_id", "") is String else ""
			mutations = encode_mutations((entry as Dictionary).get("mutations", []))
		if not level_ids.has(level_id):
			outcome["reassign_slots"].append(index)
		run.sequence.append({"level_id": level_id, "mutations": mutations})
	for index: int in (tools_raw as Array).size():
		var tool_value: Variant = tools_raw[index]
		var tool_id: String = String(tool_value) if tool_value is String else ""
		if not tool_ids.has(tool_id):
			outcome["reassign_tools"].append(index)
		run.tool_ids.append(tool_id)
	if run.cursor >= Tuning.LEVEL_COUNT:
		run.run_complete = true
	outcome["run"] = run
	var world_raw: Variant = raw.get("world", {})
	if world_raw is Dictionary and not (world_raw as Dictionary).is_empty():
		outcome["world"] = sanitize_world(world_raw)
	return outcome


static func sanitize_world(raw: Dictionary) -> Dictionary:
	var phase: String = String(raw.get("phase", "intro")) if raw.get("phase", "intro") is String else "intro"
	if phase != "play" and phase != "intro":
		phase = "intro"
	var needed: int = clampi(int(_number(raw.get("objective_needed", 2), 2)), Tuning.OBJECTIVE_MIN, Tuning.OBJECTIVE_MAX)
	var world: Dictionary = {
		"slot": int(_number(raw.get("slot", -1), -1)),
		"level_id": String(raw.get("level_id", "")) if raw.get("level_id", "") is String else "",
		"applied_mutations": encode_mutations(raw.get("applied_mutations", [])),
		"phase": phase,
		"objective_needed": needed,
		"objective_count": clampi(int(_number(raw.get("objective_count", 0), 0)), 0, needed),
		"player_hp": clampf(_number(raw.get("player_hp", Tuning.PLAYER_HP), Tuning.PLAYER_HP), 0.0, Tuning.PLAYER_HP),
		"deaths": maxi(int(_number(raw.get("deaths", 0), 0)), 0),
		"resets": maxi(int(_number(raw.get("resets", 0), 0)), 0),
		"elapsed": maxf(_number(raw.get("elapsed", 0.0), 0.0), 0.0),
		"kin_time": maxf(_number(raw.get("kin_time", 0.0), 0.0), 0.0),
		"tools_used": maxi(int(_number(raw.get("tools_used", 0), 0)), 0),
		"hitstop": clampf(_number(raw.get("hitstop", 0.0), 0.0), 0.0, Tuning.HITSTOP),
		"bodies": [],
	}
	var player_seen: bool = false
	var held_seen: bool = false
	var ids_seen: Dictionary = {}
	var bodies_raw: Variant = raw.get("bodies", [])
	if not bodies_raw is Array:
		return world
	for item: Variant in bodies_raw:
		if not item is Dictionary:
			continue
		var body: Dictionary = item
		if not body.get("spec_id") is String or String(body["spec_id"]).is_empty():
			continue
		var spec_id: String = String(body["spec_id"])
		if ids_seen.has(spec_id):
			continue
		var kind: int = int(_number(body.get("kind", 0), 0))
		if not SAVED_KINDS.has(kind):
			continue
		if kind == BodyKind.PLAYER:
			if player_seen:
				continue
			player_seen = true
		ids_seen[spec_id] = true
		var numbers: Array = []
		for key: String in ["x", "y", "angle", "vx", "vy", "av", "hp", "t", "tool_cooldown"]:
			numbers.append(body.get(key, 0.0))
		var finite: bool = _all_finite(numbers)
		var held: bool = body.get("held", false) is bool and bool(body["held"]) and kind == BodyKind.TOOL_CARRIED and not held_seen
		if held:
			held_seen = true
		world["bodies"].append({
			"spec_id": spec_id,
			"kind": kind,
			"x": _number(body.get("x", 0.0), 0.0),
			"y": _number(body.get("y", 0.0), 0.0),
			"angle": _number(body.get("angle", 0.0), 0.0),
			"vx": clampf(_number(body.get("vx", 0.0), 0.0), -Tuning.MAX_LINEAR_VEL, Tuning.MAX_LINEAR_VEL),
			"vy": clampf(_number(body.get("vy", 0.0), 0.0), -Tuning.MAX_LINEAR_VEL, Tuning.MAX_LINEAR_VEL),
			"av": clampf(_number(body.get("av", 0.0), 0.0), -Tuning.MAX_ANGULAR_VEL, Tuning.MAX_ANGULAR_VEL),
			"sleeping": body.get("sleeping", false) is bool and bool(body["sleeping"]),
			"hp": _number(body.get("hp", 3.0), 0.0),
			"destroyed": (body.get("destroyed", false) is bool and bool(body["destroyed"])) or not finite,
			"collected": body.get("collected", false) is bool and bool(body["collected"]),
			"t": maxf(_number(body.get("t", 0.0), 0.0), 0.0),
			"held": held,
			"tool_id": String(body.get("tool_id", "")) if body.get("tool_id", "") is String else "",
			"tool_cooldown": clampf(_number(body.get("tool_cooldown", 0.0), 0.0), 0.0, 2.0),
			"frozen": false,
		})
	return world


static func filter_bodies(world: Dictionary, known_spec_ids: Array) -> Dictionary:
	var result: Dictionary = world.duplicate(true)
	var kept: Array = []
	for body: Dictionary in result.get("bodies", []):
		if known_spec_ids.has(String(body["spec_id"])):
			kept.append(body)
	result["bodies"] = kept
	return result


static func _encode_bubble(bubble: Dictionary) -> Dictionary:
	var states: Dictionary = {}
	var cells: Dictionary = {}
	for key: Variant in bubble.get("states", {}):
		states[String(key)] = String(bubble["states"][key])
	for key: Variant in bubble.get("cells", {}):
		var cell: Variant = bubble["cells"][key]
		if cell is Vector2i:
			cells[String(key)] = [(cell as Vector2i).x, (cell as Vector2i).y]
		elif cell is Array and (cell as Array).size() == 2:
			cells[String(key)] = [int(cell[0]), int(cell[1])]
	return {"done": bool(bubble.get("done", false)), "states": states, "cells": cells}


static func _decode_bubble(value: Variant) -> Dictionary:
	var result: Dictionary = {"done": false, "states": {}, "cells": {}}
	if not value is Dictionary:
		return result
	var raw: Dictionary = value
	result["done"] = raw.get("done", false) is bool and bool(raw["done"])
	if raw.get("states", {}) is Dictionary:
		for key: Variant in raw["states"]:
			var state: Variant = raw["states"][key]
			if key is String and state is String and BUBBLE_STATES.has(String(state)):
				result["states"][String(key)] = String(state)
	if raw.get("cells", {}) is Dictionary:
		for key: Variant in raw["cells"]:
			var cell: Variant = raw["cells"][key]
			if key is String and cell is Array and (cell as Array).size() == 2 and _is_integer(cell[0]) and _is_integer(cell[1]):
				result["cells"][String(key)] = Vector2i(int(cell[0]), int(cell[1]))
	return result


static func _count_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	for key: Variant in value:
		if key is String and _is_integer(value[key]) and int(value[key]) > 0:
			result[String(key)] = int(value[key])
	return result


static func _finite(value: float) -> float:
	return value if is_finite(value) else 0.0


static func _all_finite(values: Array) -> bool:
	for value: Variant in values:
		if not (value is int or value is float) or not is_finite(float(value)):
			return false
	return true


static func _number(value: Variant, fallback: float) -> float:
	if (value is int or value is float) and is_finite(float(value)):
		return float(value)
	return fallback


static func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))
