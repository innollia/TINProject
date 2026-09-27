class_name EcoCreatureAxis
extends RefCounted

const MEMORY_MAX: int = 8
const STATE_ALIVE: String = "alive"
const STATE_DEAD: String = "dead"
const EVENT_KINDS: Array[String] = ["seen_player", "struck_player", "squeezed_by", "killed_by_player", "killed_by_creature", "stage_advanced"]

var id: String = ""
var archetype: String = ""
var stage: int = 0
var state: String = STATE_ALIVE
var traits: Dictionary = {}
var memory: Array = []
var den: String = ""
var present: bool = false


static func from_view(view: WorldStateView, creature_id: String) -> EcoCreatureAxis:
	var axis: EcoCreatureAxis = EcoCreatureAxis.new()
	axis.id = creature_id
	if view == null or not view.has_creature(creature_id):
		return axis
	var c: AxisCreature = view.get_creature(creature_id)
	if c == null:
		return axis
	axis.present = true
	axis.archetype = str(c.get_archetype()) if c.get_archetype() is String else ""
	var st: Variant = c.get_stage()
	axis.stage = int(st) if (st is int or st is float) else 0
	axis.state = str(c.get_state()) if c.get_state() is String else STATE_ALIVE
	axis.traits = (c.get_traits() as Dictionary).duplicate(true) if c.get_traits() is Dictionary else {}
	axis.memory = (c.get_memory() as Array).duplicate(true) if c.get_memory() is Array else []
	axis.den = str(c.get_den()) if c.get_den() is String else ""
	return axis


func remember(kind: String, room_id: String, t: float) -> bool:
	if not EVENT_KINDS.has(kind):
		return false
	memory.append({"kind": kind, "room_id": room_id, "t": t})
	while memory.size() > MEMORY_MAX:
		memory.pop_front()
	return true


func to_patch() -> Dictionary:
	var patch: Dictionary = {"id": id, "archetype": archetype, "stage": stage, "state": state, "traits": traits.duplicate(true), "memory": memory.duplicate(true)}
	if not den.is_empty():
		patch["den"] = den
	return patch
