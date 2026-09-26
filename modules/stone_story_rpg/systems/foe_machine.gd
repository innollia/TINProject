class_name StoneStoryFoeMachine
extends RefCounted

## 적 상태 기계 + 투사체.

static func make_foe(def: Dictionary, tuning: StoneStoryTuning, star_level: int, seed_value: int) -> Dictionary:
	var beh1: Dictionary = def["behaviors"]["1"]
	var beh2: Dictionary = def.get("behaviors", {}).get("2", {})
	var wake: int = int(beh2.get("wake_distance", beh1.get("wake_distance", 0)))
	var behavior: int = 2 if beh2.has("default_state") else 1
	var init_state: String = "awaken" if wake > 0 else str(beh1["default_state"])

	# 4-속성은 개체 고유다. 놀랍다만 shape + 시드에서 파생한다.
	var base: Dictionary = def.get("attributes", {})
	var shape: Dictionary = def.get("shape", {})
	var stream: PackedInt64Array = StoneStoryCore.stream(seed_value ^ StoneStoryCore.text_hash(str(def["id"])), StoneStoryCore.TAG_SURPRISE)
	var attrs: Dictionary = {
		StoneStoryAttributes.LIMBS: StoneStoryAttributes.clamp_limbs(int(base.get(StoneStoryAttributes.LIMBS, 1))),
		StoneStoryAttributes.SURPRISE: StoneStoryAttributes.surprise(base, shape, stream),
		StoneStoryAttributes.WRONGNESS: StoneStoryAttributes.clamp_scalar(float(base.get(StoneStoryAttributes.WRONGNESS, 0.0))),
		StoneStoryAttributes.ROUND: StoneStoryAttributes.clamp_scalar(float(base.get(StoneStoryAttributes.ROUND, 0.0))),
	}

	var hp_max: int = tuning.tier_value(int(def["hp"]), star_level)
	return {
		"foe_id": str(def["id"]),
		"name": str(def.get("name", def["id"])),
		"affinity_attr": str(def.get("affinity_attr", "limbs")),
		"attributes": attrs,
		"shape": shape,
		"hp": hp_max,
		"hp_max": hp_max,
		"damage": tuning.tier_value(int(def.get("damage", 0)), star_level),
		"defense": float(def.get("defense", 0.0)),
		"behavior": behavior,
		"state_id": init_state,
		"state_time": 0,
		"cycle_index": 0,
		"special_counter": 0,
		"pos": {"x": 0, "y": 0},
		"dist": 999,
		"alive": true,
		"tags": def.get("tags", []).duplicate(),
		"immunities": def.get("immunities", []).duplicate(),
		"status_resist": def.get("resistances", {"bleed": 0.0, "poison": 0.0, "frost": 0.0}).duplicate(),
		"poise": tuning.tier_value(int(def.get("poise", 10)), star_level),
		"statuses": [],
		"status_build": {"bleed": 0.0, "poison": 0.0, "frost": 0.0},
		"staggered": false,
		"stagger_frames": 0,
		"attacks": def.get("attacks", []).duplicate(),
		"wake_distance": wake,
		"walk_frames_per_unit": int(beh2.get("walk_frames_per_unit", beh1.get("walk_frames_per_unit", 3))),
		"move_accum": 0,
		"seed": seed_value,
		"scale": 1.0,
		"spawn_index": 0,
		"is_boss": false,
		"def": def,
	}


static func step(foe: Dictionary, def: Dictionary, stream: PackedInt64Array, tick: int) -> void:
	if not bool(foe["alive"]):
		return
	var states: Dictionary = def.get("states", {})
	var state_id: String = str(foe["state_id"])
	var state: Dictionary = states.get(state_id, {})
	if state.is_empty():
		foe["state_id"] = "cooldown"
		foe["state_time"] = 0
		return

	foe["state_time"] = int(foe["state_time"]) + 1
	var frames: int = int(state.get("frames", 0))
	if frames <= 0:
		_transition(foe, state)
		return
	if int(foe["state_time"]) >= frames - 1:
		_transition(foe, state)


static func _transition(foe: Dictionary, state: Dictionary) -> void:
	var next: Array = state.get("next", [])
	if next.is_empty():
		foe["state_time"] = 0
		return
	var idx: int = int(foe["cycle_index"]) % next.size()
	foe["cycle_index"] = int(foe["cycle_index"]) + 1
	foe["state_id"] = str(next[idx])
	foe["state_time"] = 0
	foe["staggered"] = false


static func move_step(foe: Dictionary, target_pos: Dictionary) -> void:
	if not bool(foe["alive"]):
		return
	if bool(foe["staggered"]) or str(foe["state_id"]) == "stagger":
		return
	if str(foe["state_id"]) == "awaken":
		if int(foe["dist"]) <= int(foe["wake_distance"]):
			var def: Dictionary = foe["def"]
			var beh2: Dictionary = def.get("behaviors", {}).get("2", {})
			foe["state_id"] = str(beh2.get("default_state", "approach"))
			foe["state_time"] = 0
		return
	if foe["tags"].has("static") or foe["tags"].has("fixed_direction"):
		return
	var per_unit: int = maxi(1, int(foe["walk_frames_per_unit"]))
	if foe["tags"].has("slow"):
		per_unit *= 2
	foe["move_accum"] = int(foe["move_accum"]) + 1
	if int(foe["move_accum"]) < per_unit:
		return
	foe["move_accum"] = 0
	var dx: int = int(target_pos["x"]) - int(foe["pos"]["x"])
	var dy: int = int(target_pos["y"]) - int(foe["pos"]["y"])
	if absi(dx) > absi(dy):
		foe["pos"]["x"] = int(foe["pos"]["x"]) + (1 if dx > 0 else -1)
	elif dy != 0:
		foe["pos"]["y"] = int(foe["pos"]["y"]) + (1 if dy > 0 else -1)


static func refresh_distance(foe: Dictionary, target_pos: Dictionary) -> void:
	var dx: int = int(target_pos["x"]) - int(foe["pos"]["x"])
	var dy: int = int(target_pos["y"]) - int(foe["pos"]["y"])
	foe["dist"] = int(round(sqrt(float(dx * dx + dy * dy))))


## chill 은 이산 확률 스킵. 결정론 유지.
static func chill_skips(foe: Dictionary, stream: PackedInt64Array, tick: int) -> bool:
	for s in foe["statuses"]:
		if str(s["id"]) != "chill":
			continue
		var pct: int = floori(float(s.get("magnitude", 0.25)) * 100.0)
		return StoneStoryCore.at(stream, tick) % 100 < pct
	return false


## lifetime == 0 은 이동 없는 즉시 판정형.
static func step_projectile(p: Dictionary, target_pos: Dictionary, reach_units: int) -> bool:
	if int(p["lifetime"]) > 0:
		p["pos"]["x"] = int(p["pos"]["x"]) + int(p["vel"]["x"])
		p["pos"]["y"] = int(p["pos"]["y"]) + int(p["vel"]["y"])
		p["lifetime"] = int(p["lifetime"]) - 1
		if int(p["lifetime"]) <= 0:
			return false
	var dx: int = int(target_pos["x"]) - int(p["pos"]["x"])
	var dy: int = int(target_pos["y"]) - int(p["pos"]["y"])
	if dx * dx + dy * dy <= reach_units * reach_units:
		return true
	if int(p["lifetime"]) <= 0:
		return false
	return false
