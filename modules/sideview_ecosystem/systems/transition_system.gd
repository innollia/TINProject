class_name EcoTransitionSystem
extends RefCounted

const EPS_TIME: float = 0.000001
const WITNESS_RADIUS_PX: float = 144.0

var state: EcoTransitionState = EcoTransitionState.new()
var completed_id: String = ""


static func trigger_rect_px(t: Dictionary) -> Rect2:
	var c: Vector2i = t["cell"]
	var s: Vector2i = t["span"]
	return Rect2(Vector2(c) * EcoBodyRung.TILE, Vector2(s) * EcoBodyRung.TILE)


static func foot_in(t: Dictionary, foot: Vector2) -> bool:
	return trigger_rect_px(t).has_point(foot - Vector2(0.0, 0.5))


func on_death() -> void:
	state.reset()
	completed_id = ""


func probe(world: EcoWorldState, room: EcoRoomSpec, frame: Dictionary, dt: float) -> String:
	completed_id = ""
	if room == null:
		return ""
	var foot: Vector2 = world.position_px
	var inside: Dictionary = {}
	for t: Dictionary in room.triggers:
		var id: String = str(t["id"])
		var object_name: String = str(t["object"])
		if EcoTransitionRule.source_of(object_name) != world.body_rung:
			continue
		if EcoTransitionRule.kind_of(object_name) == EcoTransitionRule.KIND_CONSUME and world.is_consumed(id):
			continue
		if foot_in(t, foot):
			inside = t
			break
	if inside.is_empty():
		if state.active:
			state.reset()
		return ""
	var id: String = str(inside["id"])
	var object_name: String = str(inside["object"])
	var rule: Dictionary = EcoTransitionRule.rule_of(object_name)
	if not state.active or state.trigger_id != id:
		state.begin(world.body_rung, str(rule["to"]), str(rule["kind"]), id)
	var any_input: bool = bool(frame.get("any_input", false))
	match object_name:
		"salt_bed":
			if world.on_ground:
				state.elapsed += dt
			else:
				state.elapsed = 0.0
			if state.elapsed + EPS_TIME >= float(rule["duration_s"]):
				completed_id = id
		"collapse_floor":
			if bool(frame.get("landed", false)) and float(frame.get("landing_speed", INF)) <= float(rule["landing_speed_max"]):
				state.hits += 1
			if state.hits >= int(rule["hits_required"]):
				completed_id = id
		"salt_dust_bed":
			if any_input:
				state.still_seconds = 0.0
			else:
				state.still_seconds += dt
			if state.still_seconds + EPS_TIME >= float(rule["still_seconds"]):
				completed_id = id
		"narrow_cradle":
			if any_input:
				state.still_seconds = 0.0
				state.witness_frames = 0
			else:
				state.still_seconds += dt
				if int(frame.get("witnesses", 0)) >= int(rule["witness_count"]):
					state.witness_frames += 1
			if state.still_seconds + EPS_TIME >= float(rule["still_seconds"]) and state.witness_frames >= int(rule["witness_frames"]):
				completed_id = id
	return completed_id


func commit(world: EcoWorldState, room: EcoRoomSpec, table: EcoRungTable, bridge: EcoWorldstateBridge) -> Dictionary:
	var trigger_id: String = completed_id if not completed_id.is_empty() else state.trigger_id
	var t: Dictionary = room.trigger_by_id(trigger_id) if room != null else {}
	if t.is_empty():
		return {"ok": false, "reason": "no_trigger"}
	var object_name: String = str(t["object"])
	var from_rung: String = world.body_rung
	var to_rung: String = EcoTransitionRule.target_of(object_name)
	var toll: Dictionary = EcoToll.for_step(table.index_of(from_rung), table.index_of(to_rung))
	var result: Dictionary = {"ok": true, "reason": "", "from": from_rung, "to": to_rung, "trigger_id": trigger_id}
	if bridge != null and bridge.has_store():
		var merged: Array = EcoToll.merge_max(bridge.read_body().wounds, toll)
		var r1: Dictionary = bridge.write_wounds(merged)
		if not bool(r1.get("ok", false)):
			result["ok"] = false
			result["reason"] = str(r1.get("reason", ""))
		else:
			var r2: Dictionary = bridge.write_scale(table.ladder.value_of(to_rung))
			if not bool(r2.get("ok", false)):
				result["ok"] = false
				result["reason"] = str(r2.get("reason", ""))
	else:
		world.local_wounds = EcoToll.merge_max(world.local_wounds, toll)
	if result["ok"]:
		world.body_rung = to_rung
		if EcoTransitionRule.kind_of(object_name) == EcoTransitionRule.KIND_CONSUME:
			world.trigger_flags[trigger_id] = true
		if object_name == "salt_bed":
			var c: float = float(world.compressed_beds.get(trigger_id, 0.0))
			world.compressed_beds[trigger_id] = minf(EcoTransitionRule.SALT_BED_TRACE_MAX, c + EcoTransitionRule.SALT_BED_PRESS_STEP)
	state.reset()
	completed_id = ""
	return result
