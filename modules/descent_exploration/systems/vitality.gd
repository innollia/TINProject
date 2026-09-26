class_name Vitality
extends RefCounted

const INTEGRITY_MAX: int = 3
const DAMAGE_PER_HIT: int = 1
const INVULNERABLE_TIME: float = 1.20
const DOWNED_BLACKOUT: float = 1.40
const DOWNED_FADE_IN: float = 0.30


static func apply(state: DescentState, pending: Array[Dictionary], delta: float) -> Dictionary:
	var result: Dictionary = {"hurt": false, "downed": false, "absorbed": {}, "recover": false}
	state.invulnerable_for = maxf(0.0, state.invulnerable_for - delta)
	if state.is_downed():
		state.downed_for += delta
		if state.downed_for + 0.000001 >= DOWNED_BLACKOUT:
			result["recover"] = true
		return result
	if pending.is_empty() or state.invulnerable_for > 0.0:
		return result
	var hit: Dictionary = pending[0]
	var source: String = String(hit.get("source", ""))
	var shield: int = MatterLoop.first_index_with_verb(state.carried, "strike")
	if shield >= 0:
		var matter_id: String = state.carried[shield].id
		if state.consume(shield, source):
			state.invulnerable_for = INVULNERABLE_TIME
			result["absorbed"] = {"matter": matter_id, "source": source}
			return result
	if state.apply_damage(int(hit.get("amount", DAMAGE_PER_HIT))):
		state.invulnerable_for = INVULNERABLE_TIME
		result["hurt"] = true
		if state.is_downed():
			result["downed"] = true
	return result


static func recover(state: DescentState) -> bool:
	var point: Dictionary = state.checkpoint
	if point.is_empty():
		return false
	state.carried = DescentState.read_carried(point.get("carried", []))
	state.recompute_mass()
	state.stratum_id = String(point.get("stratum_id", state.stratum_id))
	state.position = DescentState.read_position(point.get("position"), state.position)
	restore_body(state)
	return true


static func restore_body(state: DescentState) -> void:
	state.integrity = INTEGRITY_MAX
	state.downed_for = 0.0
	state.invulnerable_for = DOWNED_FADE_IN
	state.velocity = Vector2.ZERO
	state.flow = Vector2.ZERO
	state.surge_active_for = 0.0
	state.surge_cooldown_for = 0.0
	state.surge_vector = Vector2.ZERO
	state.open_bristles.clear()
