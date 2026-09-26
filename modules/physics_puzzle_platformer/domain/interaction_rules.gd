extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const CARRY: StringName = &"carry"
const GRAB: StringName = &"grab"
const SWAP: StringName = &"swap"
const COLLECT: StringName = &"collect"
const FILL: StringName = &"fill"
const ENTER: StringName = &"enter"
const HAZARD: StringName = &"hazard"
const IMPACT: StringName = &"impact"
const WAKE: StringName = &"wake"
const KNOCK: StringName = &"knock"
const CLACK: StringName = &"clack"
const STAND: StringName = &"stand"
const RIDE: StringName = &"ride"
const REST: StringName = &"rest"
const PUSH: StringName = &"push"

const CODES: Array[StringName] = [CARRY, GRAB, SWAP, COLLECT, FILL, ENTER, HAZARD, IMPACT, WAKE, KNOCK, CLACK, STAND, RIDE, REST, PUSH]

const TIER: Dictionary = {
	COLLECT: 0, FILL: 0, ENTER: 1, CARRY: 2, SWAP: 2, GRAB: 2, WAKE: 3, HAZARD: 4,
	IMPACT: 5, KNOCK: 5, STAND: 6, RIDE: 6, PUSH: 6, REST: 6, CLACK: 6,
}

const RANK: Array[int] = [
	BodyKind.PLAYER, BodyKind.TOOL_CARRIED, BodyKind.OBJECTIVE, BodyKind.TOOL_PLACEMENT, BodyKind.RIFT,
	BodyKind.PROP_SLEEPING, BodyKind.PROP_DYNAMIC, BodyKind.OBSTACLE_DYNAMIC, BodyKind.DECOR_DYNAMIC,
	BodyKind.HAZARD_AREA, BodyKind.HAZARD_STATIC, BodyKind.TILE_KINEMATIC, BodyKind.TILE_STATIC,
]

const TABLE: Array = [
	[&"push", &"carry", &"grab", &"collect", &"impact", &"wake", &"impact", &"push", &"stand", &"ride", &"enter", &"hazard", &"hazard"],
	[&"carry", &"knock", &"swap", &"knock", &"knock", &"knock", &"knock", &"knock", &"clack", &"clack", &"rest", &"hazard", &"hazard"],
	[&"grab", &"swap", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"collect", &"knock", &"rest", &"push", &"push", &"wake", &"push", &"push", &"rest", &"rest", &"fill", &"hazard", &"hazard"],
	[&"impact", &"knock", &"rest", &"push", &"impact", &"wake", &"impact", &"push", &"rest", &"rest", &"rest", &"hazard", &"hazard"],
	[&"wake", &"knock", &"rest", &"wake", &"wake", &"wake", &"wake", &"wake", &"rest", &"rest", &"rest", &"hazard", &"hazard"],
	[&"impact", &"knock", &"rest", &"push", &"impact", &"wake", &"impact", &"push", &"rest", &"rest", &"rest", &"hazard", &"hazard"],
	[&"push", &"knock", &"rest", &"push", &"push", &"wake", &"push", &"push", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"stand", &"clack", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"ride", &"clack", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"enter", &"rest", &"rest", &"fill", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"hazard", &"hazard", &"rest", &"hazard", &"hazard", &"hazard", &"hazard", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
	[&"hazard", &"hazard", &"rest", &"hazard", &"hazard", &"hazard", &"hazard", &"rest", &"rest", &"rest", &"rest", &"rest", &"rest"],
]

const EVENT_IMPACT_SOFT: StringName = &"ppp_impact_soft"
const EVENT_IMPACT_HARD: StringName = &"ppp_impact_hard"
const EVENT_EGG_TAKE: StringName = &"ppp_egg_take"
const EVENT_HURT: StringName = &"ppp_hurt"
const HARD_IMPACT_SPEED: float = 420.0


static func rule_for(kind_a: int, kind_b: int) -> StringName:
	if not BodyKind.is_valid(kind_a) or not BodyKind.is_valid(kind_b):
		return REST
	return StringName((TABLE[kind_a - 1] as Array)[kind_b - 1])


static func tier_of(code: StringName) -> int:
	return int(TIER.get(code, 6))


static func rank_of(kind: int) -> int:
	var index: int = RANK.find(kind)
	return index if index >= 0 else RANK.size()


static func impact_damage(speed: float, target_mass: float, other_mass: float, other_material: String, threshold: float) -> float:
	if speed <= threshold:
		return 0.0
	var share: float = 1.0
	if other_mass > 0.0:
		share = other_mass / maxf(target_mass + other_mass, 0.0001)
	var raw: float = (speed - threshold) * Tuning.IMPACT_DAMAGE_SCALE * share * MaterialTable.damage_scale(other_material)
	return ceilf(raw * 100.0 - 0.000001) / 100.0


static func resolve(entry: Dictionary, bodies: Array, dt: float, player_invuln: float, rift_open: bool) -> Dictionary:
	var result: Dictionary = {"applied": true, "code": entry.get("code", REST), "damage": [], "wake": [], "knock": [], "freeze": [], "collect": -1, "fill": -1, "enter": false, "events": []}
	var a: int = int(entry.get("a", -1))
	var b: int = int(entry.get("b", -1))
	if a < 0 or b < 0 or a >= bodies.size() or b >= bodies.size():
		result["applied"] = false
		return result
	var body_a: RefCounted = bodies[a]
	var body_b: RefCounted = bodies[b]
	if body_a.destroyed or body_b.destroyed:
		return result
	var code: StringName = rule_for(body_a.kind, body_b.kind)
	result["code"] = code
	match code:
		COLLECT:
			result["collect"] = b if body_b.kind == BodyKind.OBJECTIVE else a
			result["events"].append(EVENT_EGG_TAKE)
		FILL:
			result["fill"] = b if body_b.kind == BodyKind.RIFT else a
		ENTER:
			result["enter"] = rift_open
		HAZARD:
			_resolve_hazard(result, body_a, body_b, a, b, dt, player_invuln)
		IMPACT:
			_resolve_impact(result, entry, body_a, body_b, a, b, player_invuln)
		WAKE:
			if body_a.sleeping:
				result["wake"].append([a, b])
			if body_b.sleeping:
				result["wake"].append([b, a])
			_resolve_impact(result, entry, body_a, body_b, a, b, player_invuln)
		KNOCK:
			_resolve_knock(result, entry, body_a, body_b, a, b, player_invuln)
		CLACK:
			var tool_index: int = a if body_a.kind == BodyKind.TOOL_CARRIED else b
			var tool: RefCounted = bodies[tool_index]
			var tile: RefCounted = body_b if tool_index == a else body_a
			var speed: float = float(entry.get("speed", 0.0))
			var amount: float = impact_damage(speed, tool.mass, 0.0, tile.material, Tuning.CLACK_THRESHOLD)
			if amount > 0.0 and not tool.frozen:
				result["damage"].append([tool_index, amount, &"impact"])
			if speed > Tuning.IMPACT_THRESHOLD:
				result["events"].append(EVENT_IMPACT_HARD if speed >= HARD_IMPACT_SPEED else EVENT_IMPACT_SOFT)
	return result


static func _resolve_hazard(result: Dictionary, body_a: RefCounted, body_b: RefCounted, a: int, b: int, dt: float, player_invuln: float) -> void:
	var hazard: RefCounted = body_a if BodyKind.is_hazard(body_a.kind) else body_b
	var victim: RefCounted = body_b if hazard == body_a else body_a
	var victim_index: int = b if hazard == body_a else a
	if victim.frozen:
		return
	if victim.kind == BodyKind.PLAYER:
		if hazard.kind == BodyKind.HAZARD_AREA:
			result["damage"].append([victim_index, Tuning.HAZARD_DPS * dt, &"hazard_dps"])
		elif player_invuln <= 0.0:
			result["damage"].append([victim_index, Tuning.HAZARD_TOUCH_DAMAGE, &"hazard_touch"])
			result["events"].append(EVENT_HURT)
		return
	if BodyKind.is_damageable(victim.kind) or BodyKind.is_breakable(victim.kind):
		result["damage"].append([victim_index, Tuning.HAZARD_DPS * dt, &"hazard_dps"])


static func _resolve_impact(result: Dictionary, entry: Dictionary, body_a: RefCounted, body_b: RefCounted, a: int, b: int, player_invuln: float) -> void:
	var speed: float = float(entry.get("speed", 0.0))
	if body_a.kind == BodyKind.PLAYER or body_b.kind == BodyKind.PLAYER:
		var player: RefCounted = body_a if body_a.kind == BodyKind.PLAYER else body_b
		var other: RefCounted = body_b if player == body_a else body_a
		var player_index: int = a if player == body_a else b
		var toward: float = float(entry.get("toward_a", 0.0)) if player == body_a else float(entry.get("toward_b", 0.0))
		var amount: float = impact_damage(toward, player.mass, other.mass, other.material, Tuning.IMPACT_THRESHOLD)
		if amount > 0.0 and player_invuln <= 0.0 and not player.frozen:
			result["damage"].append([player_index, amount, &"impact"])
			result["events"].append(EVENT_HURT)
		return
	var hit: bool = false
	if BodyKind.is_damageable(body_a.kind) and not body_a.frozen:
		var amount_a: float = impact_damage(speed, body_a.mass, body_b.mass, body_b.material, Tuning.IMPACT_THRESHOLD)
		if amount_a > 0.0:
			result["damage"].append([a, amount_a, &"impact"])
			hit = true
	if BodyKind.is_damageable(body_b.kind) and not body_b.frozen:
		var amount_b: float = impact_damage(speed, body_b.mass, body_a.mass, body_a.material, Tuning.IMPACT_THRESHOLD)
		if amount_b > 0.0:
			result["damage"].append([b, amount_b, &"impact"])
			hit = true
	if hit or speed > Tuning.IMPACT_THRESHOLD:
		result["events"].append(EVENT_IMPACT_HARD if speed >= HARD_IMPACT_SPEED else EVENT_IMPACT_SOFT)


static func _resolve_knock(result: Dictionary, entry: Dictionary, body_a: RefCounted, body_b: RefCounted, a: int, b: int, player_invuln: float) -> void:
	var tool_index: int = a
	var target_index: int = b
	if body_a.kind != BodyKind.TOOL_CARRIED or (body_b.kind == BodyKind.TOOL_CARRIED and float(entry.get("speed_b", 0.0)) > float(entry.get("speed_a", 0.0))):
		tool_index = b
		target_index = a
	var tool: RefCounted = body_a if tool_index == a else body_b
	var target: RefCounted = body_b if tool_index == a else body_a
	var tool_speed: float = float(entry.get("speed_a", 0.0)) if tool_index == a else float(entry.get("speed_b", 0.0))
	var tool_velocity: Vector2 = entry.get("velocity_a", Vector2.ZERO) if tool_index == a else entry.get("velocity_b", Vector2.ZERO)
	if target.sleeping:
		result["wake"].append([target_index, tool_index])
	if tool_speed > Tuning.KNOCK_SPEED and not target.frozen and not tool.knocked.has(target_index):
		var ratio: float = minf(1.0, tool.mass / maxf(target.mass, 0.0001))
		result["knock"].append([target_index, tool_velocity * Tuning.KNOCK_GAIN * ratio, tool_index])
		if tool.fire_linger > 0.0 and target.kind == BodyKind.PROP_DYNAMIC:
			var linger: float = tool.fire_linger * (Tuning.FIRE_WAX_FACTOR if target.material == "wax" else 1.0)
			result["freeze"].append([target_index, linger])
	_resolve_impact(result, entry, body_a, body_b, a, b, player_invuln)
