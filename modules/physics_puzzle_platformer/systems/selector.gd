extends RefCounted

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")

const OP_ARGS: Dictionary = {
	"gravity_scale": [0.7, 1.45],
	"prop_size": [0.78, 1.3],
	"prop_offset": [-56.0, 56.0],
	"wind": [-190.0, 190.0],
	"hazard_shift": [0, 1],
}


static func new_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(1, Tuning.RUN_SEED_MAX)


static func build(run_seed: int, level_ids: Array, tool_ids: Array, mutable_by_level: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed
	var sequence: Array[Dictionary] = []
	var tools: Array[String] = []
	for _slot: int in Tuning.LEVEL_COUNT:
		var level_id: String = String(level_ids[rng.randi_range(0, level_ids.size() - 1)])
		var tool_id: String = String(tool_ids[rng.randi_range(0, tool_ids.size() - 1)])
		var mutations: Array = []
		if rng.randf() < Tuning.MUTATION_CHANCE:
			mutations = pick_mutations(rng, mutable_by_level.get(level_id, []))
		sequence.append({"level_id": level_id, "mutations": mutations})
		tools.append(tool_id)
	return {"sequence": sequence, "tool_ids": tools}


static func pick_mutations(rng: RandomNumberGenerator, allowed: Array) -> Array:
	var result: Array = []
	if allowed.is_empty():
		return result
	var pool: Array = allowed.duplicate()
	var count: int = mini(rng.randi_range(1, Tuning.MUTATION_MAX), pool.size())
	for _pick: int in count:
		var index: int = rng.randi_range(0, pool.size() - 1)
		var op: String = String(pool[index])
		pool.remove_at(index)
		result.append({"op": op, "arg": pick_arg(rng, op)})
	return result


static func pick_arg(rng: RandomNumberGenerator, op: String) -> Variant:
	if op == "material_swap":
		return rng.randi_range(0, MaterialTable.SWAP_CHOICES.size() - 1)
	var values: Array = OP_ARGS.get(op, [0])
	return values[rng.randi_range(0, values.size() - 1)]


static func slot_rng(run_seed: int, slot: int, salt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = ((run_seed * 1000003 + slot * 7919 + salt * 104729) & 0x7FFFFFFF) + 1
	return rng


static func reassign_level(run_seed: int, slot: int, level_ids: Array, mutable_by_level: Dictionary) -> Dictionary:
	var rng: RandomNumberGenerator = slot_rng(run_seed, slot, 1)
	var level_id: String = String(level_ids[rng.randi_range(0, level_ids.size() - 1)])
	var mutations: Array = []
	if rng.randf() < Tuning.MUTATION_CHANCE:
		mutations = pick_mutations(rng, mutable_by_level.get(level_id, []))
	return {"level_id": level_id, "mutations": mutations}


static func reassign_tool(run_seed: int, slot: int, tool_ids: Array) -> String:
	var rng: RandomNumberGenerator = slot_rng(run_seed, slot, 2)
	return String(tool_ids[rng.randi_range(0, tool_ids.size() - 1)])
