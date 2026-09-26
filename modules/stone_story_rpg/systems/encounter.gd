class_name StoneStoryEncounter
extends RefCounted

## 절차 생성. 같은 (region, star, seed) 면 완전히 동일하다.

static func gate_open(region: Dictionary, gate: String, star_level: int) -> bool:
	if not region.has("gates") or not region["gates"].has(gate):
		return true
	return star_level >= int(region["gates"][gate].get("min_star", 0))


static func build(content: StoneStoryContent, tuning: StoneStoryTuning,
		region_id: String, star_level: int, run_seed: int, player: Dictionary) -> Dictionary:
	var region: Dictionary = content.get_def("region", region_id)
	if region.is_empty():
		return {}

	var st_pool: StoneStoryRng = StoneStoryCore.stream(run_seed, StoneStoryCore.TAG_FOE_POOL)
	var st_place: StoneStoryRng = StoneStoryCore.stream(run_seed, StoneStoryCore.TAG_FOE_PLACE)
	var st_scale: StoneStoryRng = StoneStoryCore.stream(run_seed, StoneStoryCore.TAG_FOE_SCALE)
	var st_obs: StoneStoryRng = StoneStoryCore.stream(run_seed, StoneStoryCore.TAG_OBSTACLE)

	var band_id: String = str(tuning.band_of(star_level)["id"])
	var spawn_cap: int = int(region.get("spawn_cap", {}).get(band_id, 4))

	var pool_weights: Dictionary = {}
	for p in region.get("foe_pools", []):
		if star_level < int(p["min_star"]) or star_level > int(p["max_star"]):
			continue
		var first: String = str(p["ids"][0])
		pool_weights[first] = int(pool_weights.get(first, 0)) + int(p["weight"])
	if pool_weights.is_empty():
		spawn_cap = 0

	var foes: Array = []
	var idx: int = 0
	var pool_i: int = 0
	while foes.size() < spawn_cap and pool_i < 24:
		var picked: Variant = st_pool.weighted(pool_i, pool_weights)
		if picked == null:
			break
		var def: Dictionary = content.get_def("foe", str(picked))
		if def.is_empty():
			break
		var foe: Dictionary = StoneStoryFoeMachine.make_foe(def, tuning, star_level, run_seed)
		var span: int = st_place.range_int(idx, 4, 26)
		var side: int = 1 if st_place.unit(idx + 100) > 0.5 else -1
		foe["pos"] = {
			"x": int(player["pos"]["x"]) + side * span,
			"y": int(player["pos"]["y"]) + st_place.range_int(idx + 200, -8, 8),
		}
		var lo: float = float(tuning.generation["foe_scale_min"])
		var hi: float = float(tuning.generation["foe_scale_max"])
		var sc: float = lo + st_scale.unit(idx) * (hi - lo)
		foe["scale"] = sc
		foe["hp"] = maxi(1, int(round(float(foe["hp"]) * sc)))
		foe["hp_max"] = int(foe["hp"])
		foe["spawn_index"] = foes.size()
		foes.append(foe)
		idx += 1
		pool_i += 1

	var boss: Dictionary = {}
	var chain: Array = []
	if gate_open(region, "boss", star_level) and region.has("boss_chain"):
		for c in region["boss_chain"]:
			if star_level >= int(c.get("min_star", 1)):
				chain.append(c)
		if not chain.is_empty():
			var bdef: Dictionary = content.get_def("boss", str(chain[0]["foe_id"]))
			if not bdef.is_empty():
				boss = StoneStoryFoeMachine.make_foe(bdef, tuning, star_level, run_seed)
				boss["pos"] = {"x": int(player["pos"]["x"]) + 50, "y": int(player["pos"]["y"])}
				boss["is_boss"] = true
				boss["adapt_stacks"] = {}
				boss["adapt_last"] = ""

	var obstacles: Array = []
	if gate_open(region, "obstacles", star_level) and region.has("obstacle_pool"):
		var n: int = int(tuning.generation["obstacle_count"].get(band_id, 0))
		var ids: Array = []
		for op in region["obstacle_pool"]:
			if star_level >= int(op.get("min_star", 1)):
				ids.append_array(op["ids"])
		for i in n:
			if ids.is_empty():
				break
			var od: Dictionary = content.get_def("obstacle", str(ids[i % ids.size()]))
			obstacles.append({
				"obstacle_id": str(ids[i % ids.size()]),
				"kind": str(od.get("kind", "pillar")),
				"pos": {
					"x": int(player["pos"]["x"]) + st_obs.range_int(i, -20, 20),
					"y": int(player["pos"]["y"]) + st_obs.range_int(i + 50, -10, 10),
				},
				"blocks_move": bool(od.get("blocks_move", true)),
				"blocks_sight": bool(od.get("blocks_sight", false)),
			})

	var work: Array = []
	var st_drop: StoneStoryRng = StoneStoryCore.stream(run_seed, StoneStoryCore.TAG_DROP)
	var wi: int = 0
	for raw in region.get("props", []):
		var pdef: Dictionary = content.get_def("prop", str((raw as Dictionary).get("prop_id", "")))
		if str(pdef.get("kind", "")) != "mine":
			continue
		var yields: Dictionary = {}
		var units: int = 0
		var table: Dictionary = pdef.get("yields", {})
		for mat in table:
			var pair: Array = table[mat]
			var n: int = st_drop.range_int(wi * 7 + 3, int(pair[0]), int(pair[1]))
			yields[str(mat)] = n
			units += n
		var total: int = maxi(1, units) * maxi(1, int(pdef.get("ticks", 30)))
		work.append({"prop_id": str(pdef["id"]), "ticks_left": total, "ticks_total": total, "yields": yields})
		wi += 1

	return {
		"region_id": region_id,
		"star_level": star_level,
		"seed": run_seed,
		"band_id": band_id,
		"state": "active",
		"foes": foes,
		"boss": boss,
		"chain": region.get("boss_chain", []),
		"phase_index": 0,
		"projectiles": [],
		"obstacles": obstacles,
		"work": work,
		"player_stance": "neutral",
		"ai_state": "engage",
		"cleared_at_tick": 0,
	}
