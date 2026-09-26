extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const EVENT_EGG_TAKE: StringName = &"ppp_egg_take"
const EVENT_RIFT_READY: StringName = &"ppp_rift_ready"
const EVENT_RIFT_ENTER: StringName = &"ppp_rift_enter"
const EVENT_RIFT_FILL: StringName = &"ppp_rift_fill"

var _inside: Dictionary = {}


func apply(director: RefCounted, result: Dictionary) -> void:
	var collect: int = int(result.get("collect", -1))
	if collect >= 0:
		collect_objective(director, collect)
	if bool(result.get("enter", false)) and director.world.rift_open:
		_clear(director)


func collect_objective(director: RefCounted, index: int) -> void:
	var world: RefCounted = director.world
	var body: RefCounted = world.bodies[index]
	if body.destroyed or body.kind != BodyKind.OBJECTIVE:
		return
	world.objective_count = mini(world.objective_count + 1, world.objective_total)
	director.destroy_body(index, &"collected")
	director.push_event(EVENT_EGG_TAKE, body.position(), float(world.objective_count))


func update(director: RefCounted, delta: float) -> void:
	var world: RefCounted = director.world
	var was_open: bool = world.rift_open
	world.rift_open = world.objective_count >= world.objective_needed
	var rift: RefCounted = director.rift()
	if world.rift_open and not was_open and rift != null:
		director.push_event(EVENT_RIFT_READY, rift.position(), 1.0)
	var player: RefCounted = world.player()
	if rift != null and player != null and world.rift_open and not director.level_cleared:
		if player.position().distance_to(rift.position()) <= director.spec.rift_radius + director.player_half_width() * 0.5:
			_clear(director)
	for index: int in world.bodies.size():
		var body: RefCounted = world.bodies[index]
		if body.kind != BodyKind.OBJECTIVE:
			continue
		if body.destroyed:
			_inside.erase(index)
			if not body.collected and body.respawn_timer > 0.0:
				body.respawn_timer -= delta
				if body.respawn_timer <= 0.0:
					director.respawn_body(index)
			continue
		if rift == null:
			continue
		var inside: bool = body.position().distance_to(rift.position()) <= director.spec.rift_radius
		if inside and not bool(_inside.get(index, false)):
			director.push_event(EVENT_RIFT_FILL, rift.position(), 0.08)
		_inside[index] = inside


func _clear(director: RefCounted) -> void:
	if director.level_cleared:
		return
	director.level_cleared = true
	var rift: RefCounted = director.rift()
	director.push_event(EVENT_RIFT_ENTER, rift.position() if rift != null else Vector2.ZERO, 1.0)
