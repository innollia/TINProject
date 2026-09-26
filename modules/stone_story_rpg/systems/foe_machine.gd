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
	var stream: StoneStoryRng = StoneStoryCore.stream(seed_value, StoneStoryCore.TAG_SURPRISE + "." + str(def["id"]))
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


static func step(foe: Dictionary, def: Dictionary, stream: StoneStoryRng, tick: int) -> void:
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


static func move_step(foe: Dictionary, target_pos: Dictionary, others: Array = []) -> void:
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
	# behaviors[현재].moves 가 false 면 제자리에서 주기 행동만 한다. (03 §3.3)
	var beh_now: Dictionary = (foe.get("def", {}) as Dictionary).get("behaviors", {}).get(str(int(foe["behavior"])), {})
	if not bool(beh_now.get("moves", true)):
		return
	var per_unit: int = maxi(1, int(foe["walk_frames_per_unit"]))
	if foe["tags"].has("slow"):
		per_unit *= 2
	foe["move_accum"] = int(foe["move_accum"]) + 1
	if int(foe["move_accum"]) < per_unit:
		return
	foe["move_accum"] = 0
	var fx: int = int(foe["pos"]["x"])
	var fy: int = int(foe["pos"]["y"])
	var dx: int = int(target_pos["x"]) - fx
	var dy: int = int(target_pos["y"]) - fy
	if dx == 0 and dy == 0:
		return
	var sx: int = signi(dx)
	var sy: int = signi(dy)
	# 주 축 먼저, 막히면 다른 축. 둘 다 막히면 그 자리에 선다. (다른 개체에 겹쳐 서지 않는다)
	var tries: Array = [Vector2i(sx, 0), Vector2i(0, sy)] if absi(dx) > absi(dy) else [Vector2i(0, sy), Vector2i(sx, 0)]
	for s: Vector2i in tries:
		if s == Vector2i.ZERO:
			continue
		if crowded(foe, fx + s.x, fy + s.y, others):
			continue
		foe["pos"]["x"] = fx + s.x
		foe["pos"]["y"] = fy + s.y
		return


## 4칸 = 가로 28px. 보통 크기 개체(폭 25px 안팎)가 서로 덮지 않는 간격.
const PERSONAL_SPACE_SQ: int = 16


## 다른 개체와 4칸보다 가까워지는 걸음이면 true. 이미 가까우면 멀어지는 걸음은 허용한다.
static func crowded(foe: Dictionary, nx: int, ny: int, others: Array) -> bool:
	var fx: int = int(foe["pos"]["x"])
	var fy: int = int(foe["pos"]["y"])
	for o in others:
		var od: Dictionary = o
		if is_same(od, foe) or not bool(od.get("alive", true)):
			continue
		var ox: int = int(od["pos"]["x"])
		var oy: int = int(od["pos"]["y"])
		var after: int = (ox - nx) * (ox - nx) + (oy - ny) * (oy - ny)
		var before: int = (ox - fx) * (ox - fx) + (oy - fy) * (oy - fy)
		if after < PERSONAL_SPACE_SQ and after < before:
			return true
	return false


static func refresh_distance(foe: Dictionary, target_pos: Dictionary) -> void:
	var dx: int = int(target_pos["x"]) - int(foe["pos"]["x"])
	var dy: int = int(target_pos["y"]) - int(foe["pos"]["y"])
	foe["dist"] = int(round(sqrt(float(dx * dx + dy * dy))))


## behaviors "2"(이동)로 다가오다 공격 사거리에 들면 "1"(주기 행동: cooldown -> 공격 -> recover)로 바꾼다.
## 사거리에서 2 넘게 벗어나면 다시 "2". awaken / stagger 중에는 바꾸지 않는다.
static func update_behavior(foe: Dictionary, def: Dictionary, reach: int) -> void:
	if not bool(foe["alive"]):
		return
	var sid: String = str(foe["state_id"])
	if sid == "awaken" or sid == "stagger":
		return
	var behs: Dictionary = def.get("behaviors", {})
	if not behs.has("1") or not behs.has("2"):
		return
	var d: int = int(foe["dist"])
	if int(foe["behavior"]) == 2 and d <= reach:
		foe["behavior"] = 1
		foe["state_id"] = str(behs["1"].get("default_state", "cooldown"))
		foe["state_time"] = 0
		foe["move_accum"] = 0
	elif int(foe["behavior"]) == 1 and d > reach + 2:
		foe["behavior"] = 2
		foe["state_id"] = str(behs["2"].get("default_state", "approach"))
		foe["state_time"] = 0


## chill 은 이산 확률 스킵. 결정론 유지.
static func chill_skips(foe: Dictionary, stream: StoneStoryRng, tick: int) -> bool:
	for s in foe["statuses"]:
		if str(s["id"]) != "chill":
			continue
		var pct: int = floori(float(s.get("magnitude", 0.25)) * 100.0)
		return stream.at(tick) % 100 < pct
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
