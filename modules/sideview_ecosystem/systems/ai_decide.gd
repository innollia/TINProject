class_name EcoAIDecide
extends RefCounted

const ALERT_BASE: float = 0.6
const FLEE_BASE: float = 2.0
const FLEE_SPREAD: float = 1.5
const FLEE_EXIT_MULT: float = 2.4
const AVOID_RANGE_MULT: float = 1.8
const IDLE_TO_PATROL_S: float = 4.0
const AWAY_TO_RETURN_S: float = 3.0
const SLEEP_PRESS_MIN: float = 0.8
const SLEEP_QUIET_THINKS: float = 20.0
const HOME_REACHED_PX: float = 12.0
const PATROL_SPAN_TILES: float = 4.0
const DEN_RADIUS_TILES: float = 8.0


static func _roll(world_seed: int, c: EcoCreature, what: String, count: int) -> ProceduralSeed:
	return Procedural.derive_seed(world_seed, "think/%d/%s/%d" % [c.id, what, count])


static func society_for(c: EcoCreature, player_rung_index: int, pack_count: int) -> int:
	var s: int = EcoSocialTable.lookup(c.archetype.axis_name, player_rung_index)
	if c.archetype.pack_bonus_count > 0 and pack_count >= c.archetype.pack_bonus_count:
		s = EcoSocialTable.raised(s)
	return s


static func can_strike(c: EcoCreature, confined: bool) -> bool:
	return not c.archetype.confined_only or confined


static func decide(c: EcoCreature, sense: Dictionary, ctx: Dictionary) -> void:
	if not c.alive or c.held:
		return
	var seed_v: int = int(ctx.get("world_seed", 0))
	var n: int = int(ctx.get("think_count", 0))
	var detected: bool = bool(sense.get("detected", false))
	var distance: float = float(sense.get("distance", INF))
	var rung_index: int = int(ctx.get("player_rung_index", 0))
	var confined: bool = bool(ctx.get("confined", false))
	var reaction: float = float(c.traits.get("reaction_latency", 0.1))
	var range_px: float = c.attack_range_px()
	match c.state:
		EcoCreature.State.FLEE:
			if distance > c.archetype.sense_radius_px * FLEE_EXIT_MULT or c.state_left <= 0.0:
				c.set_state(EcoCreature.State.RETURN, 0.0)
			return
		EcoCreature.State.STRIKE, EcoCreature.State.RECOVER:
			return
	if detected and [EcoCreature.State.IDLE, EcoCreature.State.PATROL, EcoCreature.State.SLEEP, EcoCreature.State.RETURN, EcoCreature.State.GRAZE].has(c.state):
		c.mem.last_seen_rung = str(ctx.get("player_rung", ""))
		c.society = society_for(c, rung_index, int(ctx.get("pack_count", 0)))
		c.reaction_left = reaction
		if c.society == EcoSocialTable.FLEE:
			c.set_state(EcoCreature.State.FLEE, FLEE_BASE + FLEE_SPREAD * _roll(seed_v, c, "flee", n).unit())
		else:
			c.set_state(EcoCreature.State.ALERT, ALERT_BASE + reaction)
		return
	match c.state:
		EcoCreature.State.ALERT:
			if c.state_left > 0.0:
				return
			if c.society == EcoSocialTable.ATTACK and detected:
				if distance <= range_px and can_strike(c, confined):
					c.set_state(EcoCreature.State.STRIKE, c.archetype.attack_windup)
				else:
					c.set_state(EcoCreature.State.APPROACH, INF)
			elif c.society == EcoSocialTable.AVOID and distance <= range_px * AVOID_RANGE_MULT:
				c.set_state(EcoCreature.State.FLEE, FLEE_BASE)
			else:
				c.set_state(EcoCreature.State.RETURN, 0.0)
		EcoCreature.State.APPROACH:
			if not detected:
				c.set_state(EcoCreature.State.RETURN, 0.0)
			elif distance <= range_px:
				if can_strike(c, confined):
					c.set_state(EcoCreature.State.STRIKE, c.archetype.attack_windup)
				else:
					c.set_state(EcoCreature.State.RETURN, 0.0)
		EcoCreature.State.RETURN:
			if absf(c.pos_px.x - c.home_px.x) <= HOME_REACHED_PX:
				c.set_state(EcoCreature.State.IDLE, _roll(seed_v, c, "idle", n).range_f(0.8, 2.2))
		EcoCreature.State.IDLE:
			if c.quiet_seconds >= c.archetype.think_period * SLEEP_QUIET_THINKS and float(ctx.get("press", 0.0)) > SLEEP_PRESS_MIN:
				c.set_state(EcoCreature.State.SLEEP, INF)
			elif c.state_left <= 0.0 or c.idle_seconds >= IDLE_TO_PATROL_S:
				var s: ProceduralSeed = _roll(seed_v, c, "patrol", n)
				c.patrol_target_x = c.home_px.x + s.range_f(-PATROL_SPAN_TILES, PATROL_SPAN_TILES) * EcoBodyRung.TILE
				c.idle_seconds = 0.0
				c.set_state(EcoCreature.State.PATROL, s.range_f(2.0, 5.0))
		EcoCreature.State.PATROL:
			if absf(c.pos_px.x - c.home_px.x) > DEN_RADIUS_TILES * EcoBodyRung.TILE:
				c.away_seconds += c.archetype.think_period
			else:
				c.away_seconds = 0.0
			if c.away_seconds >= AWAY_TO_RETURN_S:
				c.set_state(EcoCreature.State.RETURN, 0.0)
			elif c.state_left <= 0.0:
				c.set_state(EcoCreature.State.IDLE, _roll(seed_v, c, "idle", n).range_f(0.8, 2.2))
