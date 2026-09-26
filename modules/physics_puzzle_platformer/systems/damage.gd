extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const EVENT_HURT: StringName = &"ppp_hurt"

var _pending: Dictionary = {}
var _modes: Dictionary = {}


func clear() -> void:
	_pending.clear()
	_modes.clear()


func add(result: Dictionary) -> void:
	for item: Array in result.get("damage", []):
		var index: int = int(item[0])
		_pending[index] = float(_pending.get(index, 0.0)) + float(item[1])
		var mode: StringName = StringName(item[2])
		if mode != &"hazard_dps" or not _modes.has(index):
			_modes[index] = mode


func has_pending() -> bool:
	return not _pending.is_empty()


func commit(director: RefCounted) -> void:
	var world: RefCounted = director.world
	var keys: Array = _pending.keys()
	keys.sort()
	for index: int in keys:
		if index < 0 or index >= world.bodies.size():
			continue
		var body: RefCounted = world.bodies[index]
		if body.destroyed or body.frozen:
			continue
		var amount: float = float(_pending[index])
		if amount <= 0.0:
			continue
		if body.kind == BodyKind.PLAYER:
			world.player_hp = maxf(world.player_hp - amount, 0.0)
			body.hp = world.player_hp
			if StringName(_modes.get(index, &"impact")) != &"hazard_dps":
				world.invuln = Tuning.INVULN_TIME
				world.hitstop = minf(world.hitstop + Tuning.HITSTOP, Tuning.HITSTOP_MAX)
				director.push_event(EVENT_HURT, body.position(), amount)
			if world.player_hp <= 0.0:
				director.player_dead = true
			continue
		if body.hp < 0.0:
			continue
		body.hp = maxf(body.hp - amount, 0.0)
		if body.hp <= 0.0 and body.breakable:
			director.destroy_body(index, &"broken")
	clear()
