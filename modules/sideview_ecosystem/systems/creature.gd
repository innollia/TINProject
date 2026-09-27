class_name EcoCreature
extends RefCounted

enum State { IDLE, PATROL, ALERT, APPROACH, STRIKE, RECOVER, RETURN, FLEE, GRAZE, SLEEP, DEAD }

const STATE_COUNT: int = 11
const KILLED_NONE: String = "none"
const SAFE_FALL_SPEED: float = 900.0
const RECOVER_TIME: float = 0.45

var id: int = 0
var axis_id: String = ""
var archetype_id: String = ""
var rung: String = ""
var den_id: String = ""
var lineage_stage: int = 0
var alive: bool = true
var pos_px: Vector2 = Vector2.ZERO
var vel_px: Vector2 = Vector2.ZERO
var state: int = State.IDLE
var state_left: float = 0.0
var hp: float = 0.0
var killed_by: String = KILLED_NONE
var think_left: float = 0.0
var reaction_left: float = 0.0
var mem: EcoAIMemory = EcoAIMemory.new()
var tethered: bool = false
var home_room_id: String = ""
var home_px: Vector2 = Vector2.ZERO

var archetype: EcoCreatureArchetype
var traits: Dictionary = {}
var h_px: float = 0.0
var w_px: float = 0.0
var mass: float = 0.0
var on_ground: bool = false
var held: bool = false
var soil_seconds: float = 0.0
var idle_seconds: float = 0.0
var away_seconds: float = 0.0
var quiet_seconds: float = 0.0
var patrol_target_x: float = 0.0
var society: int = EcoSocialTable.NEUTRAL
var struck: bool = false


static func make_traits(world_seed: int, creature_id: int, rung_index: int) -> Dictionary:
	var s: ProceduralSeed = Procedural.derive_seed(world_seed, "creature/" + str(creature_id))
	return {
		"rung_index": rung_index,
		"speed_mult": 0.88 + 0.24 * s.derive("speed").unit(),
		"aggression_mult": 0.70 + 0.60 * s.derive("aggression").unit(),
		"courage_mult": 0.75 + 0.50 * s.derive("courage").unit(),
		"reaction_latency": 0.05 + 0.25 * s.derive("reaction").unit(),
		"phase_offset": s.derive("phase").unit(),
		"spike_count": rung_index + 1,
		"head_bloom": s.derive("head").unit(),
		"tail_phase": TAU * s.derive("tail").unit(),
	}


func setup_body(p_archetype: EcoCreatureArchetype, rung_value: float, band_value: float, target_body_px: float) -> void:
	archetype = p_archetype
	h_px = archetype.h_px(rung_value, band_value, target_body_px)
	w_px = h_px * EcoBodyRung.AASPECT_W
	mass = archetype.mass_at(h_px)


func aabb() -> Rect2:
	return Rect2(pos_px.x - w_px * 0.5, pos_px.y - h_px, w_px, h_px)


func attack_range_px() -> float:
	return archetype.attack_range_ratio * h_px


func set_state(s: int, left: float) -> void:
	state = s
	state_left = left


func kill(cause: String) -> void:
	if not alive:
		return
	alive = false
	killed_by = cause
	held = false
	set_state(State.DEAD, INF)


func step(sub_dt: float, col: EcoCollisionResolver, player_foot: Vector2, gravity_mult: float) -> Dictionary:
	var ev: Dictionary = {"landed": false, "landing_speed": 0.0}
	if not alive or held:
		return ev
	var speed: float = archetype.move_speed * float(traits.get("speed_mult", 1))
	var dir: float = 0.0
	match state:
		State.PATROL:
			dir = signf(patrol_target_x - pos_px.x)
		State.APPROACH:
			dir = signf(player_foot.x - pos_px.x)
			speed *= archetype.chase_speed_mult
		State.RETURN:
			dir = signf(home_px.x - pos_px.x)
		State.FLEE:
			dir = -signf(player_foot.x - pos_px.x)
			speed *= archetype.chase_speed_mult
	vel_px.x = move_toward(vel_px.x, dir * speed, speed * 8 * sub_dt)
	var g: float = EcoBodyRung.GRAVITY_BASE * gravity_mult
	vel_px.y = minf(vel_px.y + g * sub_dt, EcoPlayerBody.MAX_FALL_SPEED)
	var box: Rect2 = aabb()
	var rx: Dictionary = col.move_x(box, vel_px.x * sub_dt)
	if rx["blocked"]:
		vel_px.x = 0.0
		if state == State.PATROL:
			patrol_target_x = home_px.x
	box = rx["aabb"]
	var falling: float = vel_px.y
	var ry: Dictionary = col.move_y(box, vel_px.y * sub_dt, false)
	box = ry["aabb"]
	if ry["blocked"]:
		vel_px.y = 0.0
	var was_air: bool = not on_ground
	on_ground = bool(ry["grounded"]) or col.ground_below(box)
	if on_ground and was_air and falling > 0.0:
		ev["landed"] = true
		ev["landing_speed"] = falling
		if falling > SAFE_FALL_SPEED + EcoBodyRung.FALL_DAMAGE_DIVISOR:
			kill("hazard")
	pos_px = Vector2(box.position.x + box.size.x * 0.5, box.end.y)
	if col.in_soil(box):
		soil_seconds += sub_dt
	else:
		soil_seconds = 0.0
	return ev


func to_dictionary() -> Dictionary:
	return {
		"id": id, "axis_id": axis_id, "archetype_id": archetype_id, "den_id": den_id, "rung": rung,
		"lineage_stage": lineage_stage, "alive": alive, "pos_px": [pos_px.x, pos_px.y], "vel_px": [vel_px.x, vel_px.y],
		"state": state, "state_left": state_left if is_finite(state_left) else 0.0, "hp": hp, "killed_by": killed_by,
		"think_left": think_left, "reaction_left": reaction_left, "tethered": tethered, "home_room_id": home_room_id,
		"mem": mem.to_dictionary(),
	}


static func vec(v: Variant) -> Vector2:
	if v is Array and (v as Array).size() == 2 and (v[0] is float or v[0] is int) and (v[1] is float or v[1] is int):
		return Vector2(float(v[0]), float(v[1]))
	return Vector2.ZERO


func load_dictionary(d: Dictionary) -> void:
	id = int(d.get("id", id))
	axis_id = str(d.get("axis_id", str(id)))
	archetype_id = str(d.get("archetype_id", archetype_id))
	den_id = str(d.get("den_id", ""))
	rung = str(d.get("rung", rung))
	lineage_stage = int(d.get("lineage_stage", 0))
	alive = bool(d.get("alive", true))
	pos_px = vec(d.get("pos_px"))
	vel_px = vec(d.get("vel_px"))
	state = clampi(int(d.get("state", 0)), 0, STATE_COUNT - 1)
	state_left = float(d.get("state_left", 0.0))
	hp = float(d.get("hp", hp))
	killed_by = str(d.get("killed_by", KILLED_NONE))
	think_left = float(d.get("think_left", 0.0))
	reaction_left = float(d.get("reaction_left", 0.0))
	tethered = bool(d.get("tethered", false))
	home_room_id = str(d.get("home_room_id", ""))
	var m: Variant = d.get("mem", {})
	mem = EcoAIMemory.from_dictionary(m if m is Dictionary else {})
	if not alive:
		state = State.DEAD
