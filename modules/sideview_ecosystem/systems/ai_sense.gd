class_name EcoAISense
extends RefCounted

const WALL_SIGHT_MULT: float = 0.35
const GUST_MULT: float = 1.6
const GUST_FALL_SPEED: float = 300.0
const CLATTER_MULT: float = 1.4
const SIGHT_SAMPLES: int = 12


static func line_blocked(col: EcoCollisionResolver, a: Vector2, b: Vector2) -> bool:
	var t: float = EcoBodyRung.TILE
	for i: int in range(1, SIGHT_SAMPLES):
		var p: Vector2 = a.lerp(b, float(i) / SIGHT_SAMPLES)
		if EcoTileKind.is_solid(col.tile_kind(floori(p.x / t), floori(p.y / t))):
			return true
	return false


static func sense(c: EcoCreature, player_center: Vector2, player_falling_speed: float, clatter: bool, col: EcoCollisionResolver) -> Dictionary:
	var eye: Vector2 = c.aabb().get_center()
	var to_player: Vector2 = player_center - eye
	var distance: float = to_player.length()
	var hear_r: float = c.archetype.hearing_radius_px
	if player_falling_speed > GUST_FALL_SPEED:
		hear_r *= GUST_MULT
	if clatter:
		hear_r *= CLATTER_MULT
	var heard: bool = distance <= hear_r and c.state != EcoCreature.State.FLEE
	var see_r: float = c.archetype.sense_radius_px
	if col != null and line_blocked(col, eye, player_center):
		see_r *= WALL_SIGHT_MULT
	var facing: float = signf(c.vel_px.x) if c.vel_px.x != 0.0 else 1
	var angle: float = rad_to_deg(absf(Vector2(facing, 0.0).angle_to(to_player))) if distance > 0.0 else 0.0
	var seen: bool = distance <= see_r and angle <= c.archetype.fov_deg * 0.5
	return {"seen": seen, "heard": heard, "detected": seen or heard, "distance": distance}
