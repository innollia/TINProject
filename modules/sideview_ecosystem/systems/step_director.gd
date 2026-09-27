class_name EcoStepDirector
extends RefCounted

const FIXED_SUBSTEPS: int = 4
const FRAME_DT: float = 1 / 60.0
const STAGES: Array[String] = [
	"advance_settle", "read_input", "update_rung_probe", "sense_creatures", "think_creatures", "think_brood_pack",
	"substep_physics", "update_den", "commit_transition", "update_camera", "update_presentation", "update_overlay",
	"push_axis_patches",
]
const MODE_LOADING: StringName = &"loading"
const MODE_NORMAL: StringName = &"normal"
const MODE_DYING: StringName = &"dying"
const MODE_DEAD: StringName = &"dead"
const MODE_ASLEEP: StringName = &"asleep"
const DYING_TIME: float = 0.8
const RUNG_CUT_TIME: float = 0.9
const PLATE_RETURN_TIME: float = 0.5
const CAUSE_FALL: String = "fall"
const CAUSE_CREATURE: String = "creature"
const HOLD_STATES_BLOCK_SLEEP: Array[int] = [EcoCreature.State.APPROACH, EcoCreature.State.STRIKE]

var index: EcoContentIndex
var table: EcoRungTable
var world: EcoWorldState
var bridge: EcoWorldstateBridge
var save: EcoSaveService
var settle: EcoSettleSystem = EcoSettleSystem.new()
var transition: EcoTransitionSystem = EcoTransitionSystem.new()
var player: EcoPlayerBody = EcoPlayerBody.new()
var col: EcoCollisionResolver = EcoCollisionResolver.new()
var creatures: EcoCreatureManager
var room: EcoRoomSpec
var world_seed: int = 0
var mode: StringName = MODE_NORMAL
var log_stages: bool = false
var stage_log: PackedStringArray = []
var think_calls_outside_stage: int = 0
var errors: PackedStringArray = []
var events: Array[Dictionary] = []
var rung_cut_left: float = 0.0
var dying_left: float = 0.0
var sleep_hold: float = 0.0
var plate_timers: Dictionary = {}
var last_landed: bool = false
var last_landing_speed: float = 0.0
var clatter: bool = false
var q: float = 0.0
var frames: int = 0
var missing_arm: bool = false


static func make(p_index: EcoContentIndex, p_table: EcoRungTable, p_bridge: EcoWorldstateBridge = null, p_save: EcoSaveService = null) -> EcoStepDirector:
	var d: EcoStepDirector = EcoStepDirector.new()
	d.index = p_index
	d.table = p_table
	d.bridge = p_bridge if p_bridge != null else EcoWorldstateBridge.new()
	d.save = p_save
	d.creatures = EcoCreatureManager.make(p_index, p_table)
	d.world_seed = p_index.content_seed
	d.world = EcoSaveService.new_world(p_index)
	d.enter_room(d.world.current_room_id, d.world.position_px)
	return d


func start(p_world: EcoWorldState, p_world_seed: int) -> void:
	world = p_world
	world_seed = p_world_seed
	enter_room(world.current_room_id, world.position_px)


func body() -> EcoBodyRung:
	return table.by_name(world.body_rung)


func band_value() -> float:
	return table.band_value(room.band) if room != null else 0.0


func _refresh_body() -> void:
	if room == null or body() == null:
		return
	player.set_body(body(), band_value(), room.target_body_px)
	var aabb: Rect2 = player.aabb_at(world.position_px)
	var lift: float = 0.0
	while not col.is_free(Rect2(aabb.position - Vector2(0.0, lift), aabb.size)) and lift < aabb.size.y:
		lift += EcoBodyRung.TILE * 0.5
	world.position_px.y -= lift


func enter_room(room_id: String, foot: Vector2) -> void:
	var next: EcoRoomSpec = index.room(room_id)
	if next == null:
		errors.append("room_unknown " + room_id)
		return
	if room != null and creatures.room == room:
		creatures.unload_room(world)
	if room != null and room.id != room_id:
		world.previous_room_id = room.id
	room = next
	world.current_room_id = room_id
	world.current_band = room.band
	world.t_in_room = 0.0
	world.visit(room_id)
	world.position_px = foot
	plate_timers.clear()
	col.plates_open = {}
	col.setup(room, world)
	creatures.load_room(world, room, world_seed)
	_refresh_body()


func _stage(n: String) -> void:
	if log_stages:
		stage_log.append(n)


func _emit(kind: String, extra: Dictionary = {}) -> void:
	var e: Dictionary = {"kind": kind}
	e.merge(extra)
	events.append(e)


func encode() -> Dictionary:
	creatures.store_all(world)
	return EcoSaveCodec.encode(world, index.content_seed, world_seed)


func _save(point: String) -> void:
	if save != null:
		save.write_file(encode(), point)


func step_frame(intent: Dictionary) -> void:
	events.clear()
	frames += 1
	if mode == MODE_DYING:
		dying_left -= FRAME_DT
		if dying_left <= 0.0:
			mode = MODE_DEAD
		return
	if mode != MODE_NORMAL or room == null or body() == null:
		return
	world.t_in_room += FRAME_DT
	world.t_since_death += FRAME_DT
	_stage(STAGES[0])
	var settle_ev: Dictionary = settle.advance(world, room, FRAME_DT)
	if not (settle_ev["drift_dropped"] as PackedStringArray).is_empty():
		col.rebuild()
	if bool(settle_ev["entered_pressing"]):
		_emit("pressing")
	if bool(settle_ev["audio_on"]):
		_emit("settle_load")
	_stage(STAGES[1])
	var frozen: bool = rung_cut_left > 0.0
	rung_cut_left = maxf(0.0, rung_cut_left - FRAME_DT)
	player.read_input({} if frozen else intent)
	_stage(STAGES[2])
	var center: Vector2 = player.aabb_at(world.position_px).get_center()
	var probe_frame: Dictionary = {
		"any_input": player.any_input, "landed": last_landed, "landing_speed": last_landing_speed,
		"witnesses": creatures.witnesses(center),
	}
	q = body().scale_value / band_value() if band_value() > 0.0 else 0.0
	transition.probe(world, room, probe_frame, FRAME_DT)
	_stage(STAGES[3])
	_stage(STAGES[4])
	var ctx: Dictionary = {"world_seed": world_seed, "player_rung": world.body_rung, "player_rung_index": table.index_of(world.body_rung), "press": settle.press}
	creatures.sense_and_think(ctx, col, center, world.velocity_px.y, clatter, FRAME_DT)
	clatter = false
	_stage(STAGES[5])
	creatures.brood_pack(table.index_of(world.body_rung))
	_stage(STAGES[6])
	_physics()
	if mode != MODE_NORMAL:
		return
	_stage(STAGES[7])
	_update_den()
	_stage(STAGES[8])
	if not transition.completed_id.is_empty():
		_commit()
	_stage(STAGES[9])
	_stage(STAGES[10])
	_stage(STAGES[11])
	_stage(STAGES[12])
	_push_axis()
	_check_exit()
	_check_shelter()


func _physics() -> void:
	var sub_dt: float = FRAME_DT / FIXED_SUBSTEPS
	player.begin_frame(world, FRAME_DT)
	last_landed = false
	last_landing_speed = 0.0
	if player.use_pressed:
		_use()
	for i: int in FIXED_SUBSTEPS:
		var ev: Dictionary = player.substep(world, col, settle.gravity_mult, settle.friction_mult, sub_dt)
		if bool(ev["jumped"]):
			_emit("jump")
		if bool(ev["squeeze_entered"]):
			_emit("squeeze")
		if bool(ev["landed"]):
			last_landed = true
			last_landing_speed = float(ev["landing_speed"])
			world.integrity -= EcoPlayerBody.fall_damage(last_landing_speed, body().safe_fall_speed)
			_emit("land", {"speed": last_landing_speed})
		for c: EcoCreature in creatures.live:
			if c.held:
				c.pos_px = world.position_px + Vector2(world.facing * (player.width() * 0.5 + c.w_px * 0.5), 0.0)
				continue
			c.step(sub_dt, col, world.position_px, settle.gravity_mult)
		_contact(sub_dt)
		if world.integrity <= 0.0:
			_die()
			return


func _use() -> void:
	if world.holding:
		var held: EcoCreature = creatures.by_id(world.held_creature_id)
		world.holding = false
		world.held_creature_id = -1
		if held != null:
			held.held = false
			held.set_state(EcoCreature.State.FLEE, 1.6)
		return
	var aabb: Rect2 = player.aabb_at(world.position_px)
	var reach: float = float(player.derived.get("use_range_px", 0.0))
	for c: EcoCreature in creatures.live:
		if c.aabb().intersects(aabb.grow(reach)) and EcoCreatureContact.can_grab(c, player.mass(), missing_arm, col):
			world.holding = true
			world.held_creature_id = c.id
			c.held = true
			return
	var wall: EcoPassageSpec = player.try_strike(world, col)
	_emit("strike")
	if wall != null and world.is_wall_broken(wall.id):
		clatter = true
		_emit("shatter", {"id": wall.id})


func _contact(sub_dt: float) -> void:
	var aabb: Rect2 = player.aabb_at(world.position_px)
	for p: EcoPassageSpec in room.passages:
		if p.kind != EcoPassageKind.PRESS:
			continue
		var load_info: Dictionary = EcoCreatureContact.plate_load(p, aabb, player.mass(), world.on_ground, creatures.live)
		var total: float = float(load_info["load"])
		var was_open: bool = bool(col.plates_open.get(p.id, false))
		if total >= p.mass_required:
			plate_timers[p.id] = PLATE_RETURN_TIME
			if not was_open:
				col.plates_open[p.id] = true
				col.rebuild()
				_emit("plate", {"id": p.id})
			if total > EcoCreatureContact.PRESS_PRESSURE_MULT * p.mass_required:
				for c: EcoCreature in load_info["riders"]:
					c.kill("crush")
		elif was_open:
			plate_timers[p.id] = float(plate_timers.get(p.id, 0.0)) - sub_dt
			if float(plate_timers[p.id]) <= 0.0 and not p.rect_px().intersects(aabb):
				col.plates_open[p.id] = false
				col.rebuild()
	for c: EcoCreature in creatures.live:
		if not c.alive:
			continue
		if c.soil_seconds >= EcoCreatureContact.BURY_SECONDS:
			c.kill("buried")
			continue
		if c.state == EcoCreature.State.STRIKE:
			var roll: float = Procedural.derive_seed(world_seed, "strike/%d/%d" % [c.id, frames]).unit()
			if EcoCreatureContact.strike_cancelled(c, aabb, roll):
				c.set_state(EcoCreature.State.RECOVER, EcoCreature.RECOVER_TIME)
				continue
			if c.state_left <= 0.0:
				if EcoCreatureContact.strike_hits(c, aabb):
					var largest: bool = table.index_of(world.body_rung) == table.names().size() - 1
					world.integrity -= EcoCreatureContact.strike_damage(c, largest)
					world.velocity_px = Vector2(world.facing * -EcoCreatureContact.KNOCKBACK_X, EcoCreatureContact.KNOCKBACK_Y)
					creatures.axis_events.append({"id": c.id, "kind": "struck_player"})
					_emit("creature_strike", {"id": c.id})
				c.set_state(EcoCreature.State.RECOVER, EcoCreature.RECOVER_TIME)
		elif c.state == EcoCreature.State.RECOVER:
			if c.state_left <= 0.0:
				c.set_state(EcoCreature.State.APPROACH if c.society == EcoSocialTable.ATTACK else EcoCreature.State.RETURN, INF)


func _update_den() -> void:
	for c: EcoCreature in creatures.live:
		if not c.alive and c.state == EcoCreature.State.DEAD and not bool(c.traits.get("death_seen", false)):
			c.traits["death_seen"] = true
			_emit("creature_death", {"id": c.id})
			var kind: String = "killed_by_player" if c.killed_by == "player" else "killed_by_creature"
			creatures.axis_events.append({"id": c.id, "kind": kind})


func _commit() -> void:
	var from_rung: String = world.body_rung
	var r: Dictionary = transition.commit(world, room, table, bridge)
	if not bool(r["ok"]):
		push_warning("sideview_ecosystem transition not applied: " + str(r["reason"]))
		return
	rung_cut_left = RUNG_CUT_TIME
	col.rebuild()
	_refresh_body()
	var center: Vector2 = player.aabb_at(world.position_px).get_center()
	creatures.force_alert(center, world.body_rung, table.index_of(world.body_rung))
	_emit("rung_cut", {"from": from_rung, "to": world.body_rung})
	_save("S2")


func _push_axis() -> void:
	if creatures.axis_events.is_empty():
		return
	var pending: Array[Dictionary] = creatures.axis_events.duplicate()
	creatures.axis_events.clear()
	if not bridge.has_store():
		return
	var grouped: Dictionary = {}
	for e: Dictionary in pending:
		if not grouped.has(e["id"]):
			grouped[e["id"]] = []
		(grouped[e["id"]] as Array).append(str(e["kind"]))
	for id: Variant in grouped.keys():
		var c: EcoCreature = creatures.by_id(int(id))
		if c == null:
			continue
		var axis: EcoCreatureAxis = bridge.read_creature(c.axis_id)
		axis.archetype = c.archetype.axis_name
		axis.stage = c.lineage_stage
		axis.state = EcoCreatureAxis.STATE_ALIVE if c.alive else EcoCreatureAxis.STATE_DEAD
		if axis.traits.is_empty():
			var t: Dictionary = c.traits.duplicate()
			t.erase("death_seen")
			t.erase("rung_index")
			t["rung"] = c.rung
			axis.traits = t
		if c.alive and not c.den_id.is_empty():
			axis.den = c.den_id
		for kind: String in grouped[id]:
			axis.remember(kind, room.id, world.t_in_room)
		bridge.write_creature(axis)


func _die() -> void:
	world.deaths += 1
	world.t_since_death = 0.0
	transition.on_death()
	if world.holding:
		var held: EcoCreature = creatures.by_id(world.held_creature_id)
		if held != null:
			held.held = false
	world.holding = false
	world.held_creature_id = -1
	mode = MODE_DYING
	dying_left = DYING_TIME
	_emit("death")


func respawn() -> void:
	if mode != MODE_DEAD and mode != MODE_DYING:
		return
	if world.respawn_room != world.current_room_id:
		enter_room(world.respawn_room, world.respawn_pos_px)
	else:
		world.position_px = world.respawn_pos_px
	world.integrity = 1
	world.velocity_px = Vector2.ZERO
	world.facing = 1
	_refresh_body()
	mode = MODE_NORMAL
	_save("S4")


func wake() -> void:
	if mode == MODE_ASLEEP:
		mode = MODE_NORMAL


func _check_shelter() -> void:
	if not world.on_ground:
		sleep_hold = 0.0
		return
	var foot: Vector2 = world.position_px - Vector2(0.0, 0.5)
	var on: Dictionary = {}
	for s: Dictionary in room.shelters:
		var cell: Vector2i = s["cell"]
		if Rect2(Vector2(cell) * EcoBodyRung.TILE, Vector2.ONE * EcoBodyRung.TILE).has_point(foot):
			on = s
	if on.is_empty():
		sleep_hold = 0.0
		return
	world.touch_shelter(str(on["id"]))
	world.respawn_room = room.id
	world.respawn_pos_px = EcoSaveService.shelter_foot(on["cell"])
	var threatened: bool = false
	for c: EcoCreature in creatures.live:
		if c.alive and HOLD_STATES_BLOCK_SLEEP.has(c.state):
			threatened = true
	if player.curl_held and not threatened:
		sleep_hold += FRAME_DT
	else:
		sleep_hold = 0.0
	if sleep_hold + EcoTransitionSystem.EPS_TIME >= EcoPlayerBody.SLEEP_HOLD_S:
		sleep_hold = 0.0
		world.sleeps += 1
		world.t_settle = 0.0
		world.integrity = 1
		mode = MODE_ASLEEP
		_emit("sleep")
		_save("S1")


func _check_exit() -> void:
	var size: Vector2 = room.size_px()
	var foot: Vector2 = world.position_px
	var center: Vector2 = player.aabb_at(foot).get_center()
	var side: String = ""
	if center.x < 0.0:
		side = "left"
	elif center.x > size.x:
		side = "right"
	elif center.y > size.y:
		side = "bottom"
	elif center.y < 0.0:
		side = "top"
	if side.is_empty():
		return
	var along: int = floori((foot.y - 1) / EcoBodyRung.TILE) if side == "left" or side == "right" else floori(foot.x / EcoBodyRung.TILE)
	var chosen: Dictionary = {}
	for e: Dictionary in room.exits:
		if str(e["side"]) == side and along >= int(e["from"]) - 1 and along <= int(e["to"]) + 1:
			chosen = e
	if chosen.is_empty():
		for e: Dictionary in room.exits:
			if str(e["side"]) == side:
				chosen = e
	if chosen.is_empty():
		world.position_px = Vector2(clampf(foot.x, 0.0, size.x), clampf(foot.y, 0.0, size.y))
		world.velocity_px = Vector2.ZERO
		return
	var other: EcoRoomSpec = index.room(str(chosen["to_room"]))
	var back: Dictionary = other.exit_by_id(str(chosen["to_exit"])) if other != null else {}
	if back.is_empty():
		errors.append("exit_unpaired_runtime %s/%s" % [room.id, chosen["id"]])
		return
	var shift: float = (int(back["from"]) - int(chosen["from"])) * EcoBodyRung.TILE
	var other_size: Vector2 = other.size_px()
	var w_half: float = player.width() * 0.5
	var new_foot: Vector2 = foot
	match side:
		"left":
			new_foot = Vector2(other_size.x - w_half - 1, foot.y + shift)
		"right":
			new_foot = Vector2(w_half + 1, foot.y + shift)
		"bottom":
			new_foot = Vector2(foot.x + shift, player.height() + 2.0)
		"top":
			new_foot = Vector2(foot.x + shift, other_size.y - 2.0)
	var v: Vector2 = world.velocity_px
	enter_room(other.id, new_foot)
	world.velocity_px = v
	_emit("room_changed", {"room": other.id})
	_save("S3")
