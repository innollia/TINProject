class_name EcoCreatureManager
extends RefCounted

const WITNESS_RADIUS_PX: float = 144.0
const FORCE_ALERT_RADIUS_PX: float = 144.0

var index: EcoContentIndex
var table: EcoRungTable
var archetypes: Dictionary = {}
var live: Array = []
var room: EcoRoomSpec
var world_seed: int = 0
var think_counts: Dictionary = {}
var axis_events: Array[Dictionary] = []
var events: Array[Dictionary] = []


static func make(p_index: EcoContentIndex, p_table: EcoRungTable) -> EcoCreatureManager:
	var m: EcoCreatureManager = EcoCreatureManager.new()
	m.index = p_index
	m.table = p_table
	for aid: String in p_index.archetype_ids:
		m.archetypes[aid] = EcoCreatureArchetype.from_dictionary(p_index.archetype(aid))
	return m


func all_ids() -> Array:
	var out: Array = []
	for region: EcoRegionSpec in index.regions:
		for room_spec: EcoRoomSpec in region.rooms:
			for slot: int in room_spec.dens.size():
				var den: Dictionary = room_spec.dens[slot]
				var lineage: Array = index.archetype(str(den["lineage_of"])).get("lineage", [])
				for stage: int in lineage.size():
					out.append(EcoIdAllocator.den_id(region.index, room_spec.index, slot, stage))
			for t: int in room_spec.tethered.size():
				out.append(EcoIdAllocator.tether_id(region.index, room_spec.index, t))
	return out


func _region_index(room_spec: EcoRoomSpec) -> int:
	for region: EcoRegionSpec in index.regions:
		if region.id == room_spec.region_id:
			return region.index
	return 0


func _spawn(world: EcoWorldState, id: int, axis_id: String, arc_id: String, rung_name: String, den_id: String, stage: int, cell: Vector2i, tethered: bool) -> EcoCreature:
	var arc: EcoCreatureArchetype = archetypes.get(arc_id)
	if arc == null or rung_name.is_empty():
		return null
	var c: EcoCreature = EcoCreature.new()
	c.id = id
	c.axis_id = axis_id
	c.archetype_id = arc_id
	c.rung = rung_name
	c.den_id = den_id
	c.lineage_stage = stage
	c.tethered = tethered
	c.home_room_id = room.id
	c.home_px = Vector2(cell.x * EcoBodyRung.TILE + EcoBodyRung.TILE * 0.5, (cell.y + 1) * EcoBodyRung.TILE)
	c.pos_px = c.home_px
	c.hp = arc.hp
	c.traits = EcoCreature.make_traits(world_seed, id, table.ladder.index_of(rung_name))
	c.setup_body(arc, table.ladder.value_of(rung_name), table.band_value(room.band), room.target_body_px)
	var saved: Variant = world.creatures.get(str(id))
	if saved is Dictionary:
		c.load_dictionary(saved)
		c.den_id = den_id
		c.home_px = Vector2(cell.x * EcoBodyRung.TILE + EcoBodyRung.TILE * 0.5, (cell.y + 1) * EcoBodyRung.TILE)
		if c.pos_px == Vector2.ZERO:
			c.pos_px = c.home_px
	c.think_left = c.archetype.think_period * float(c.traits.get("phase_offset", 0.0))
	world.creatures[str(id)] = c.to_dictionary()
	return c


func load_room(world: EcoWorldState, p_room: EcoRoomSpec, p_world_seed: int) -> void:
	room = p_room
	world_seed = p_world_seed
	live.clear()
	if room == null:
		return
	var region_i: int = _region_index(room)
	for slot: int in room.dens.size():
		var den: Dictionary = room.dens[slot]
		var before: int = int(EcoDenSystem.ensure(world, index, den)["stage"])
		EcoDenSystem.lineage_roll(world, index, den, world_seed)
		var state: Dictionary = world.dens[str(den["id"])]
		if int(state["stage"]) != before:
			events.append({"kind": "stage_advanced", "den": str(den["id"])})
		if not bool(state["occupied"]):
			continue
		var stage: int = int(state["stage"])
		var arc_id: String = EcoDenSystem.stage_archetype(index, str(den["lineage_of"]), stage)
		var id: int = EcoIdAllocator.den_id(region_i, room.index, slot, stage)
		var arc: EcoCreatureArchetype = archetypes.get(arc_id)
		if arc == null:
			continue
		var saved: Variant = world.creatures.get(str(id))
		if saved is Dictionary and not bool((saved as Dictionary).get("alive", true)):
			continue
		var c: EcoCreature = _spawn(world, id, str(id), arc_id, arc.rung_for(id, room.band, table.ladder), str(den["id"]), stage, den["cell"], false)
		if c != null:
			state["creature_id"] = id
			live.append(c)
	for t: int in room.tethered.size():
		var tether: Dictionary = room.tethered[t]
		var id: int = EcoIdAllocator.tether_id(region_i, room.index, t)
		var saved: Variant = world.creatures.get(str(id))
		if saved is Dictionary and not bool((saved as Dictionary).get("alive", true)):
			continue
		var c: EcoCreature = _spawn(world, id, str(tether["axis_id"]), str(tether["archetype"]), str(tether["rung"]), "", 0, tether["cell"], true)
		if c != null:
			live.append(c)


func unload_room(world: EcoWorldState) -> void:
	for c: EcoCreature in live:
		world.creatures[str(c.id)] = c.to_dictionary()
		if not c.alive and not c.den_id.is_empty():
			if EcoDenSystem.refill_roll(world, c.den_id, c.killed_by, world_seed):
				var revived: Dictionary = world.creatures[str(c.id)]
				revived["alive"] = true
				revived["hp"] = c.archetype.hp
				revived["killed_by"] = EcoCreature.KILLED_NONE
				revived["state"] = EcoCreature.State.IDLE
				revived["pos_px"] = [c.home_px.x, c.home_px.y]
	live.clear()


func store_all(world: EcoWorldState) -> void:
	for c: EcoCreature in live:
		world.creatures[str(c.id)] = c.to_dictionary()


func witnesses(center: Vector2, radius: float = WITNESS_RADIUS_PX) -> int:
	var n: int = 0
	for c: EcoCreature in live:
		if c.alive and c.aabb().get_center().distance_to(center) <= radius:
			n += 1
	return n


func by_id(id: int) -> EcoCreature:
	for c: EcoCreature in live:
		if c.id == id:
			return c
	return null


func force_alert(center: Vector2, player_rung: String, player_rung_index: int) -> void:
	for c: EcoCreature in live:
		if c.alive and not c.held and c.aabb().get_center().distance_to(center) <= FORCE_ALERT_RADIUS_PX:
			c.mem.last_seen_rung = player_rung
			c.society = EcoAIDecide.society_for(c, player_rung_index, _pack_count(c))
			c.set_state(EcoCreature.State.ALERT, EcoAIDecide.ALERT_BASE + float(c.traits.get("reaction_latency", 0.1)))


func _pack_count(c: EcoCreature) -> int:
	if c.archetype.pack_bonus_count <= 0:
		return 0
	var n: int = 0
	for o: EcoCreature in live:
		if o.alive and o.archetype_id == c.archetype_id and o.pos_px.distance_to(c.pos_px) <= c.archetype.graze_radius_px:
			n += 1
	return n


func sense_and_think(ctx: Dictionary, col: EcoCollisionResolver, player_center: Vector2, falling_speed: float, clatter: bool, dt: float) -> void:
	for c: EcoCreature in live:
		if not c.alive:
			continue
		c.mem.age(dt)
		c.state_left -= dt
		var s: Dictionary = EcoAISense.sense(c, player_center, falling_speed, clatter, col)
		if bool(s["detected"]):
			c.mem.record(player_center, float(s["distance"]))
			c.quiet_seconds = 0.0
		else:
			c.quiet_seconds += dt
		if c.state == EcoCreature.State.IDLE:
			c.idle_seconds += dt
		c.think_left -= dt
		if c.think_left > 0.0:
			continue
		c.think_left = c.archetype.think_period
		var before: int = c.state
		var count: int = int(think_counts.get(c.id, 0))
		think_counts[c.id] = count + 1
		var local: Dictionary = ctx.duplicate()
		local["think_count"] = count
		local["confined"] = EcoCreatureContact.confined(c, col)
		local["pack_count"] = _pack_count(c)
		EcoAIDecide.decide(c, s, local)
		if c.state == EcoCreature.State.ALERT and before != EcoCreature.State.ALERT:
			events.append({"kind": "alert", "id": c.id})
			axis_events.append({"id": c.id, "kind": "seen_player"})


func brood_pack(player_rung_index: int) -> void:
	for c: EcoCreature in live:
		if c.alive and c.archetype.pack_bonus_count > 0 and _pack_count(c) >= c.archetype.pack_bonus_count:
			c.society = EcoAIDecide.society_for(c, player_rung_index, _pack_count(c))
