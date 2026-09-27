class_name EcoDenSystem
extends RefCounted

const REFILL_BY_PLAYER: float = 1 / 3.0
const REFILL_OTHER: float = 1
const REFILL_BY_CAUSE: Dictionary = {"player": REFILL_BY_PLAYER, "creature": REFILL_OTHER, "hazard": REFILL_OTHER, "buried": REFILL_OTHER, "crush": REFILL_OTHER}


static func refill_chance(killed_by: String) -> float:
	return float(REFILL_BY_CAUSE.get(killed_by, 0.0))


static func roll(world_seed: int, den_id: String, rolls: int, p: float) -> bool:
	return Procedural.derive_seed(world_seed, "den/" + den_id + "/" + str(rolls)).unit() < p


static func stage_archetype(index: EcoContentIndex, lineage_of: String, stage: int) -> String:
	var lineage: Array = index.archetype(lineage_of).get("lineage", [])
	if stage < 0 or stage >= lineage.size():
		return ""
	return str((lineage[stage] as Dictionary).get("archetype", ""))


static func stage_chance(index: EcoContentIndex, lineage_of: String, stage: int) -> float:
	var lineage: Array = index.archetype(lineage_of).get("lineage", [])
	if stage < 0 or stage >= lineage.size():
		return 0.0
	return float((lineage[stage] as Dictionary).get("advance_chance", 0.0))


static func ensure(world: EcoWorldState, index: EcoContentIndex, den: Dictionary) -> Dictionary:
	var id: String = str(den["id"])
	if not world.dens.has(id):
		var stage: int = int(den["stage"])
		world.dens[id] = {"stage": stage, "occupied": not stage_archetype(index, str(den["lineage_of"]), stage).is_empty(), "creature_id": -1, "rolls": 0}
	return world.dens[id]


static func lineage_roll(world: EcoWorldState, index: EcoContentIndex, den: Dictionary, world_seed: int) -> bool:
	var state: Dictionary = ensure(world, index, den)
	var lineage_of: String = str(den["lineage_of"])
	var stage: int = int(state["stage"])
	var last: int = (index.archetype(lineage_of).get("lineage", []) as Array).size() - 1
	if bool(state["occupied"]) or stage >= last:
		return false
	var rolls: int = int(state.get("rolls", 0))
	var advanced: bool = roll(world_seed, str(den["id"]), rolls, stage_chance(index, lineage_of, stage))
	state["rolls"] = rolls + 1
	if advanced:
		state["stage"] = stage + 1
		state["occupied"] = not stage_archetype(index, lineage_of, stage + 1).is_empty()
		state["creature_id"] = -1
	return advanced


static func refill_roll(world: EcoWorldState, den_id: String, killed_by: String, world_seed: int) -> bool:
	if not world.dens.has(den_id):
		return false
	var state: Dictionary = world.dens[den_id]
	var rolls: int = int(state.get("rolls", 0))
	var ok: bool = roll(world_seed, den_id, rolls, refill_chance(killed_by))
	state["rolls"] = rolls + 1
	state["occupied"] = ok
	if not ok:
		state["creature_id"] = -1
	return ok
