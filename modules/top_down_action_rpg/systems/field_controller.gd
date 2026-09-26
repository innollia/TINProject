class_name TopDownActionRpgFieldController
extends RefCounted

const MAX_TRAVEL_PER_STEP: float = 0.32
const DIAGONAL_CORRECTION: float = 1.41421356
const INTERACTION_RADIUS: float = 1.25
const MAX_FOCUS_STEP: int = 32
const FACING_COUNT: int = 4
const ENCOUNTER_FIELD_ACTIVATIONS: Array[String] = [
	"CONTACT", "ZONE", "INTERACTION", "STORY_FORCED", "CHASE_THRESHOLD",
]
const INTERACTABLE_KINDS: Array[String] = [
	"npc", "passage", "pickup", "chest", "corpse", "lever", "terminal", "shop", "key", "hazard",
]
const INTERACTION_ACTIVATIONS: Array[String] = ["confirm", "automatic", "scripted"]
const REPEAT_POLICIES: Array[String] = ["once", "resettable", "persistent"]


class Interactable:
	extends RefCounted

	var interactable_id: StringName = &""
	var kind: String = "npc"
	var activation: String = "confirm"
	var repeat_policy: String = "once"
	var priority: int = 0
	var position: Vector2 = Vector2.ZERO
	var radius: float = INTERACTION_RADIUS
	var opens: StringName = &""
	var presentation_class: String = "neutral"
	var enabled: bool = true
	var used_count: int = 0
	var focusable: bool = true

	func is_reusable() -> bool:
		return repeat_policy != "once" or used_count == 0

	func to_dict() -> Dictionary:
		return {
			"interactable_id": String(interactable_id),
			"kind": kind,
			"activation": activation,
			"repeat_policy": repeat_policy,
			"priority": priority,
			"x": position.x,
			"y": position.y,
			"radius": radius,
			"opens": String(opens),
			"presentation_class": presentation_class,
			"enabled": enabled,
			"used_count": used_count,
			"focusable": focusable,
		}


class ClusterTrigger:
	extends RefCounted

	var cluster_id: StringName = &""
	var region_id: StringName = &""
	var npc_ids: Array = []
	var thread_ids: Array = []
	var starting_conversation_id: StringName = &""
	var fired: bool = false
	var pending: bool = false

	func to_dict() -> Dictionary:
		return {
			"cluster_id": String(cluster_id),
			"region_id": String(region_id),
			"npc_ids": npc_ids.duplicate(),
			"thread_ids": thread_ids.duplicate(),
			"starting_conversation_id": String(starting_conversation_id),
			"fired": fired,
			"pending": pending,
		}


var game_state: TopDownActionRpgGameState
var catalog: TopDownActionRpgContentLoader.Catalog
var interactables: Array = []
var clusters: Array = []
var focus_index: int = 0
var active_interaction_id: StringName = &""
var blocked_reason: String = ""


func setup(p_state: TopDownActionRpgGameState, p_catalog: TopDownActionRpgContentLoader.Catalog) -> bool:
	game_state = p_state
	catalog = p_catalog
	if game_state == null or catalog == null:
		return false
	rebuild_region()
	return true


func rebuild_region() -> void:
	interactables = []
	clusters = []
	active_interaction_id = &""
	focus_index = 0
	blocked_reason = ""
	if catalog == null or game_state == null:
		return
	var region: Dictionary = catalog.record(game_state.region_id())
	if region.is_empty():
		return
	_seed_region_prop_states(region)
	var index: int = 0
	for entry: Variant in region.get("noncombat_content", {}).get("interactable_prop_ids", []) if (region.get("noncombat_content", {}) is Dictionary) and ((region["noncombat_content"].get("interactable_prop_ids", []) is Array)) else []:
		var prop_record: Dictionary = catalog.record(String(entry))
		if prop_record.is_empty():
			continue
		var interactable := Interactable.new()
		interactable.interactable_id = StringName(String(entry))
		interactable.kind = "chest" if String(prop_record.get("region_id", "")) != "" else "pickup"
		interactable.activation = "confirm"
		interactable.repeat_policy = "resettable"
		interactable.priority = index
		interactable.position = _anchor_position(index)
		var interaction: Dictionary = prop_record.get("interaction", {}) if prop_record.get("interaction", {}) is Dictionary else {}
		interactable.opens = StringName(String(interaction.get("opens", "")))
		interactable.presentation_class = "neutral"
		interactables.append(interactable)
		index += 1
	for npc_id: Variant in region.get("residents", []) if region.get("residents", []) is Array else []:
		if not npc_id is Dictionary:
			continue
		var npc_record: Dictionary = catalog.record(String(npc_id.get("npc_id", "")))
		if npc_record.is_empty():
			continue
		var npc_interactable := Interactable.new()
		npc_interactable.interactable_id = StringName(String(npc_id["npc_id"]))
		npc_interactable.kind = "npc"
		npc_interactable.activation = "confirm"
		npc_interactable.repeat_policy = "repeatable"
		npc_interactable.priority = index
		npc_interactable.position = _anchor_position(index)
		var verbs: Array = npc_record.get("interaction_verbs", []) if npc_record.get("interaction_verbs", []) is Array else []
		if not verbs.is_empty() and verbs[0] is Dictionary:
			npc_interactable.opens = StringName(String(verbs[0].get("opens", "")))
			npc_interactable.presentation_class = String(verbs[0].get("presentation_class", "neutral"))
		interactables.append(npc_interactable)
		index += 1
	for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
		if not exit_entry is Dictionary:
			continue
		var passage := Interactable.new()
		passage.interactable_id = StringName(String(exit_entry.get("edge_id", "")))
		passage.kind = "passage"
		passage.activation = "confirm"
		passage.repeat_policy = "persistent"
		passage.priority = index
		passage.position = _anchor_position(index)
		passage.opens = StringName(String(exit_entry.get("to_region_id", "")))
		interactables.append(passage)
		index += 1
	var cluster: Dictionary = region.get("initial_cluster", {}) if region.get("initial_cluster", {}) is Dictionary else {}
	if not cluster.is_empty():
		var trigger := ClusterTrigger.new()
		trigger.cluster_id = StringName(String(cluster.get("cluster_id", "")))
		trigger.region_id = StringName(game_state.region_id())
		trigger.npc_ids = (cluster.get("npc_ids", []) as Array).duplicate() if cluster.get("npc_ids", []) is Array else []
		trigger.thread_ids = (cluster.get("thread_ids", []) as Array).duplicate() if cluster.get("thread_ids", []) is Array else []
		trigger.starting_conversation_id = StringName(String(cluster.get("starting_conversation_id", "")))
		clusters.append(trigger)
	focus_index = 0
	if interactables_in_reach().is_empty() and not interactables.is_empty():
		var origin: Dictionary = game_state.field.get("actor", {}) if game_state.field.get("actor", {}) is Dictionary else {}
		if absf(float(origin.get("x", 0.0))) < 0.0001 and absf(float(origin.get("y", 0.0))) < 0.0001:
			game_state.set_field_actor(interactables[0].position.x, interactables[0].position.y, 0)


func _seed_region_prop_states(region: Dictionary) -> void:
	var noncombat: Dictionary = region.get("noncombat_content", {}) if region.get("noncombat_content", {}) is Dictionary else {}
	var prop_ids: Array = noncombat.get("interactable_prop_ids", []) if noncombat.get("interactable_prop_ids", []) is Array else []
	for entry: Variant in prop_ids:
		var prop_id: String = String(entry)
		if prop_id.is_empty() or not game_state.prop_state(prop_id).is_empty():
			continue
		var record: Dictionary = catalog.record(prop_id)
		if record.is_empty():
			continue
		var initial: String = String(record.get("initial_state_id", ""))
		if not initial.is_empty():
			game_state.set_prop_state(prop_id, initial)


func _anchor_position(index: int) -> Vector2:
	var columns: int = 4
	var column: int = index % columns
	var row: int = index / columns
	return Vector2(float(column) * 1.5 - 2.25, float(row) * 1.5 - 1.5)


func move(direction: Vector2, collision_blocked: bool) -> bool:
	if game_state == null:
		return false
	var magnitude: float = direction.length()
	if magnitude <= 0.0:
		return false
	var step: Vector2 = direction.normalized() * minf(magnitude, 1.0) * MAX_TRAVEL_PER_STEP
	if absf(direction.x) > 0.0 and absf(direction.y) > 0.0:
		step /= DIAGONAL_CORRECTION
	if collision_blocked:
		step = Vector2(step.x, 0.0) if absf(step.x) >= absf(step.y) else Vector2(0.0, step.y)
	var actor: Dictionary = game_state.field_actor()
	var position := Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0)))
	position += step
	game_state.set_field_actor(position.x, position.y, _facing_from(step))
	_evaluate_triggers()
	return true


func _facing_from(step: Vector2) -> int:
	if absf(step.x) >= absf(step.y):
		return 3 if step.x > 0.0 else 1
	return 2 if step.y > 0.0 else 0


func interactables_in_reach() -> Array:
	var actor: Dictionary = game_state.field_actor()
	var position := Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0)))
	var result: Array = []
	for entry: Interactable in interactables:
		if not entry.enabled or not entry.focusable:
			continue
		if position.distance_to(entry.position) <= entry.radius:
			result.append(entry)
	result.sort_custom(func(a: Interactable, b: Interactable) -> bool:
		if a.priority != b.priority:
			return a.priority > b.priority
		return String(a.interactable_id) < String(b.interactable_id)
	)
	return result


func focus_candidates() -> Array:
	var in_reach: Array = interactables_in_reach()
	var result: Array = in_reach.duplicate()
	for entry: Interactable in interactables:
		if not in_reach.has(entry) and entry.enabled and entry.focusable:
			result.append(entry)
	return result


func move_focus(step: int) -> bool:
	var candidates: Array = focus_candidates()
	if candidates.is_empty():
		return false
	focus_index = wrapi(focus_index + step, 0, candidates.size())
	return true


func focused_interactable() -> Interactable:
	var candidates: Array = focus_candidates()
	if candidates.is_empty():
		return null
	return candidates[clampi(focus_index, 0, candidates.size() - 1)]


func interact() -> Dictionary:
	var target: Interactable = focused_interactable()
	if target == null:
		blocked_reason = "skipped_no_valid_target"
		return {"result": blocked_reason, "interactable_id": ""}
	var in_reach: Array = interactables_in_reach()
	if not in_reach.has(target):
		blocked_reason = "skipped_out_of_reach"
		return {"result": blocked_reason, "interactable_id": String(target.interactable_id)}
	if not target.is_reusable():
		blocked_reason = "skipped_already_used"
		return {"result": blocked_reason, "interactable_id": String(target.interactable_id)}
	target.used_count += 1
	active_interaction_id = target.interactable_id
	game_state.field["active_interaction_id"] = String(target.interactable_id)
	blocked_reason = ""
	var payload: Dictionary = {
		"result": "interacted",
		"interactable_id": String(target.interactable_id),
		"kind": target.kind,
		"opens": String(target.opens),
		"presentation_class": target.presentation_class,
		"activation": target.activation,
	}
	if target.kind == "passage":
		payload["route"] = traverse(String(target.interactable_id))
	_evaluate_triggers()
	return payload


func traverse(edge_id: String) -> Dictionary:
	if game_state == null or catalog == null:
		return {"result": "skipped_no_route"}
	var region: Dictionary = catalog.record(game_state.region_id())
	for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
		if not exit_entry is Dictionary or String(exit_entry.get("edge_id", "")) != edge_id:
			continue
		var route_state: String = String(exit_entry.get("route_state", "locked"))
		if route_state == "closed":
			blocked_reason = "route_closed"
			return {"result": "route_closed", "edge_id": edge_id}
		if route_state in ["conditional", "debt-bearing", "redirected"] and not _condition_met(exit_entry.get("requires_condition", {})):
			blocked_reason = "route_locked"
			return {"result": "route_locked", "edge_id": edge_id, "gate_id": String(exit_entry.get("gate_id", ""))}
		var target_region: String = String(exit_entry.get("to_region_id", ""))
		var anchor: String = _entry_anchor(target_region)
		game_state.set_region(target_region, anchor)
		game_state.visit_region(target_region)
		game_state.field["active_interaction_id"] = ""
		active_interaction_id = &""
		rebuild_region()
		return {"result": "traversed", "edge_id": edge_id, "region_id": target_region, "anchor_id": anchor}
	blocked_reason = "skipped_no_route"
	return {"result": "skipped_no_route", "edge_id": edge_id}


func _entry_anchor(region_id: String) -> String:
	if catalog == null:
		return region_id
	var region: Dictionary = catalog.record(region_id)
	var entry: Dictionary = region.get("entry", {}) if region.get("entry", {}) is Dictionary else {}
	var edge_id: String = String(entry.get("edge_id", ""))
	for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
		if exit_entry is Dictionary and String(exit_entry.get("edge_id", "")) == edge_id:
			return String(exit_entry.get("edge_id", "")) + "_return"
	return edge_id


func route_state(edge_id: String) -> String:
	if game_state == null:
		return "locked"
	var recorded: String = game_state.route_state(edge_id)
	if recorded != "locked":
		return recorded
	if catalog == null:
		return "locked"
	var region: Dictionary = catalog.record(game_state.region_id())
	for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
		if exit_entry is Dictionary and String(exit_entry.get("edge_id", "")) == edge_id:
			return String(exit_entry.get("route_state", "locked"))
	return "locked"


func available_edges() -> Array:
	var result: Array = []
	if catalog == null or game_state == null:
		return result
	var region: Dictionary = catalog.record(game_state.region_id())
	for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
		if exit_entry is Dictionary:
			result.append({
				"edge_id": String(exit_entry.get("edge_id", "")),
				"to_region_id": String(exit_entry.get("to_region_id", "")),
				"gate_id": String(exit_entry.get("gate_id", "")),
				"route_state": route_state(String(exit_entry.get("edge_id", ""))),
				"field_activation": String(exit_entry.get("field_activation", "CONTACT")),
			})
	return result


func set_route_state(edge_id: String, next_state: String, event_id: String) -> bool:
	if game_state == null:
		return false
	return game_state.set_route_state(edge_id, next_state, event_id)


func active_cluster() -> ClusterTrigger:
	for entry: ClusterTrigger in clusters:
		if not entry.fired:
			return entry
	return null


func _evaluate_triggers() -> void:
	if game_state == null or catalog == null:
		return
	var region: Dictionary = catalog.record(game_state.region_id())
	var combat: Dictionary = region.get("combat_content", {}) if region.get("combat_content", {}) is Dictionary else {}
	for encounter_id: Variant in combat.get("encounter_ids", []) if combat.get("encounter_ids", []) is Array else []:
		var encounter: Dictionary = catalog.record(String(encounter_id))
		if encounter.is_empty():
			continue
		if game_state.encounter_resolution(String(encounter_id)) != "":
			continue
		var activation: Dictionary = encounter.get("activation", {}) if encounter.get("activation", {}) is Dictionary else {}
		if _condition_met(activation.get("eligibility", {})):
			pending_encounter(encounter)
			return
	for entry: ClusterTrigger in clusters:
		if entry.fired:
			continue
		entry.pending = true


func pending_encounter(encounter: Dictionary) -> void:
	if game_state == null or encounter.is_empty():
		return
	game_state.combat["active_encounter_id"] = String(encounter.get("id", ""))
	game_state.combat["attempt_serial"] = int(game_state.combat.get("attempt_serial", 0)) + 1
	game_state.set_mode("encounter_prepare")
	active_interaction_id = &""
	game_state.field["active_interaction_id"] = ""


func cluster_snapshot() -> Array:
	var result: Array = []
	for entry: ClusterTrigger in clusters:
		result.append(entry.to_dict())
	return result


func _condition_met(condition: Variant) -> bool:
	if not condition is Dictionary or (condition as Dictionary).is_empty():
		return true
	return TopDownActionRpgContentLoader.evaluate_condition(condition, game_state, catalog)


func field_snapshot() -> Dictionary:
	var result: Dictionary = {
		"region_id": game_state.region_id() if game_state != null else "",
		"focus_index": focus_index,
		"active_interaction_id": String(active_interaction_id),
		"interactables": [],
		"clusters": cluster_snapshot(),
	}
	for entry: Interactable in interactables:
		result["interactables"].append(entry.to_dict())
	return result
