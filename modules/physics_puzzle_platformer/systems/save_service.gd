extends RefCounted

const SaveCodec = preload("res://modules/physics_puzzle_platformer/domain/save_codec.gd")
const Selector = preload("res://modules/physics_puzzle_platformer/systems/selector.gd")

const OBSERVATION_REJECTED: String = "ppp.save_rejected"


static func snapshot(run: RefCounted, bubble: RefCounted, director: RefCounted) -> Dictionary:
	if run == null:
		return {}
	if bubble != null:
		run.bubble = bubble.to_save()
	var world: RefCounted = null
	if director != null:
		director.sync_runtime()
		world = director.world
	return SaveCodec.encode(run, world)


static func read(state: Dictionary, content: RefCounted) -> Dictionary:
	var level_ids: Array = content.level_order.duplicate()
	var tool_ids: Array = content.tool_order.duplicate()
	var decoded: Dictionary = SaveCodec.decode(state, level_ids, tool_ids)
	var outcome: Dictionary = {"run": null, "world": {}, "previous_index": 0, "bubble": {}, "observations": []}
	if bool(decoded["rejected"]):
		outcome["observations"].append({"id": OBSERVATION_REJECTED, "meta": {"found_version": int(decoded["found_version"])}})
	var run: RefCounted = decoded["run"]
	if run == null:
		return outcome
	outcome["previous_index"] = run.run_index
	outcome["bubble"] = run.bubble
	if bool(decoded["resequence"]) or run.run_complete:
		return outcome
	for slot: Variant in decoded["reassign_slots"]:
		run.sequence[int(slot)] = Selector.reassign_level(run.run_seed, int(slot), level_ids, content.mutable_by_level())
	for slot: Variant in decoded["reassign_tools"]:
		run.tool_ids[int(slot)] = Selector.reassign_tool(run.run_seed, int(slot), tool_ids)
	run.total_objectives = total_objectives(run, content)
	var world: Dictionary = decoded["world"]
	if not world.is_empty() and (int(world.get("slot", -1)) != run.cursor or String(world.get("level_id", "")) != run.current_level_id()):
		world = {}
	outcome["run"] = run
	outcome["world"] = world
	return outcome


static func total_objectives(run: RefCounted, content: RefCounted) -> int:
	var total: int = 0
	for level_id: String in run.sequence_level_ids():
		var level: RefCounted = content.level(level_id)
		if level != null:
			total += level.objective_needed
	return total


static func restore_world(director: RefCounted, world: Dictionary) -> void:
	if director == null or world.is_empty():
		return
	director.restore(SaveCodec.filter_bodies(world, director.known_spec_ids()))
