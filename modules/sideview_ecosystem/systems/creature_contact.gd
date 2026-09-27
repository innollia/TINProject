class_name EcoCreatureContact
extends RefCounted

const CREATURE_SAFE_FALL_SPEED: float = 900.0
const CREATURE_LETHAL_FALL_PX: float = 1889.0
const GRAB_MASS_RATIO: float = 0.75
const MISSING_ARM_GRAB_MULT: float = 0.5
const PRESS_PRESSURE_MULT: float = 1.8
const CONFINE_RATIO: float = 1.60
const DOLL_DAMAGE_MULT: float = 0.35
const LARGE_TARGET_REDUCED: Array[String] = ["maw", "anchor", "brood"]
const COURAGE_RANGE_MULT: float = 2.2
const KNOCKBACK_X: float = 180.0
const KNOCKBACK_Y: float = -120.0
const BURY_SECONDS: float = 1.4
const GRABBABLE_STATES: Array[int] = [EcoCreature.State.SLEEP, EcoCreature.State.IDLE, EcoCreature.State.FLEE]


static func confined(c: EcoCreature, col: EcoCollisionResolver) -> bool:
	var hole: Dictionary = col.gap_hole_at(c.aabb())
	if hole.is_empty():
		return false
	return float(hole["w_gap"]) <= CONFINE_RATIO * c.w_px


static func strike_damage(c: EcoCreature, player_is_largest: bool) -> float:
	var d: float = c.archetype.attack_damage * float(c.traits.get("aggression_mult", 1))
	if player_is_largest and LARGE_TARGET_REDUCED.has(c.archetype.axis_name):
		d *= DOLL_DAMAGE_MULT
	return d


static func strike_hits(c: EcoCreature, player_aabb: Rect2) -> bool:
	var distance: float = c.aabb().get_center().distance_to(player_aabb.get_center())
	return c.aabb().grow(c.attack_range_px()).intersects(player_aabb) and distance <= c.attack_range_px() + (c.w_px + player_aabb.size.x) * 0.5


static func strike_cancelled(c: EcoCreature, player_aabb: Rect2, roll: float) -> bool:
	var distance: float = c.aabb().get_center().distance_to(player_aabb.get_center())
	if distance <= c.attack_range_px() * COURAGE_RANGE_MULT:
		return false
	return roll < c.archetype.courage * float(c.traits.get("courage_mult", 1))


static func can_grab(c: EcoCreature, player_mass: float, missing_arm: bool, col: EcoCollisionResolver) -> bool:
	if not c.alive or not GRABBABLE_STATES.has(c.state) or c.society == EcoSocialTable.ATTACK:
		return false
	if c.archetype.confined_only and not confined(c, col):
		return false
	var limit: float = GRAB_MASS_RATIO * player_mass * (MISSING_ARM_GRAB_MULT if missing_arm else 1)
	return c.mass <= limit


static func plate_load(plate: EcoPassageSpec, player_aabb: Rect2, player_mass: float, player_on_ground: bool, creatures: Array) -> Dictionary:
	var r: Rect2 = plate.rect_px()
	var top: Rect2 = Rect2(r.position.x, r.position.y - 2.0, r.size.x, EcoBodyRung.TILE + 2.0)
	var total: float = 0.0
	var riders: Array = []
	if player_on_ground and top.intersects(Rect2(player_aabb.position.x, player_aabb.end.y - 1, player_aabb.size.x, 2.0)):
		total += player_mass
	for c: EcoCreature in creatures:
		if c.alive and c.on_ground and top.intersects(Rect2(c.aabb().position.x, c.aabb().end.y - 1, c.w_px, 2.0)):
			total += c.mass
			riders.append(c)
	return {"load": total, "riders": riders}
