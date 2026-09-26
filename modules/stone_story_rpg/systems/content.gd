class_name StoneStoryContent
extends RefCounted

## JSON 로더 + 전수 검증.

const ROOT := "res://modules/stone_story_rpg/content/"

const KINDS: Array[String] = [
	"region", "foe", "boss", "miniboss", "attack", "item", "enchant", "affix",
	"recipe", "class", "stone", "spell", "material", "legend", "shop", "obstacle", "prop",
]

const PREFIX: Dictionary = {
	"region": "region_", "foe": "foe_", "boss": "boss_", "miniboss": "miniboss_",
	"attack": "atk_", "item": "item_", "enchant": "ench_", "affix": "aff_",
	"recipe": "rec_", "class": "class_", "stone": "stone_", "spell": "spell_",
	"material": "mat_", "legend": "legend_", "shop": "shop_", "obstacle": "obs_",
	"prop": "prop_",
}

var db: Dictionary = {}
var errors: Array[String] = []
var warnings: Array[String] = []
var signature: String = ""


func load_all() -> bool:
	errors.clear()
	warnings.clear()
	db.clear()
	for kind in KINDS:
		db[kind] = {}
	for kind in KINDS:
		_load_kind(kind)
	_validate()
	signature = _signature()
	return errors.is_empty()


func _load_kind(kind: String) -> void:
	var dir_path: String = ROOT + kind
	if not DirAccess.dir_exists_absolute(dir_path):
		warnings.append("no_dir:" + kind)
		return
	var names: Array[String] = []
	var d := DirAccess.open(dir_path)
	for f in d.get_files():
		if f.ends_with(".json"):
			names.append(f)
	names.sort()
	for f in names:
		var data: Variant = _read_json(dir_path + "/" + f)
		if typeof(data) != TYPE_DICTIONARY:
			errors.append("not_dict:" + kind + "/" + f)
			continue
		if not data.has("id"):
			errors.append("no_id:" + kind + "/" + f)
			continue
		var id: String = str(data["id"])
		if db[kind].has(id):
			errors.append("dup_id:" + kind + "/" + id)
			continue
		if not id.begins_with(PREFIX[kind]):
			errors.append("bad_prefix:" + kind + "/" + id)
			continue
		data["__kind"] = kind
		db[kind][id] = data


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		errors.append("missing_file:" + path)
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		errors.append("cannot_open:" + path)
		return null
	var txt: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if parsed == null:
		errors.append("bad_json:" + path)
	return parsed


func _signature() -> String:
	var h: int = 2166136261
	for kind in KINDS:
		for id in db[kind]:
			h = StoneStoryCore.mix(h, StoneStoryCore.text_hash(kind + str(id)))
			h = StoneStoryCore.mix(h, StoneStoryCore.text_hash(JSON.stringify(db[kind][id])))
	return str(h)


func get_def(kind: String, id: String) -> Dictionary:
	return db.get(kind, {}).get(id, {})


func ids(kind: String) -> Array:
	return db.get(kind, {}).keys()


func item(id: String) -> Dictionary:
	return get_def("item", id)


func make_item_state(item_id: String) -> Dictionary:
	return {
		"item_id": item_id,
		"upgrade_level": 0,
		"affix_ids": [],
		"enchant_ids": [],
		"serial": 0,
	}


# --- 검증 ---------------------------------------------------------

func _validate() -> void:
	_validate_items()
	_validate_foes()
	_validate_regions()
	_validate_refs()


func _validate_items() -> void:
	for id in db["item"]:
		var it: Dictionary = db["item"][id]
		var kind: String = str(it.get("kind", ""))
		if kind == "weapon":
			if not it.has("damage"):
				errors.append("weapon_no_damage:" + str(id))
			if typeof(it.get("damage", 0)) == TYPE_DICTIONARY:
				errors.append("damage_must_be_scalar:" + str(id))
			var sum: float = 0.0
			for s in it.get("scaling", {}):
				sum += float(it["scaling"][s])
			if sum > 1.0001:
				errors.append("scaling_sum_gt_1:" + str(id))
			for r in it.get("requirement", {}):
				if int(it["requirement"][r]) < 0:
					errors.append("requirement_negative:" + str(id))
			if not it.has("upgrade"):
				warnings.append("no_upgrade_block:" + str(id))
		# 4-속성 델타는 4키만 허용
		for k in it.get("attr_delta", {}):
			if not StoneStoryAttributes.KEYS.has(StringName(k)):
				errors.append("bad_attr_delta_key:" + str(id) + ":" + str(k))
		if it.get("attr_delta", {}).has("limbs"):
			errors.append("attr_delta_limbs_ignored:" + str(id))
		errors.append_array(StoneStoryGearPolicy.validate_content(
				it.get("policy_delta", {}), str(id)))


func _validate_foes() -> void:
	for kind in ["foe", "boss", "miniboss"]:
		for id in db[kind]:
			var d: Dictionary = db[kind][id]
			if not d.has("states"):
				errors.append("no_states:" + str(id))
				continue
			for sid in d["states"]:
				if not d["states"][sid].has("next"):
					errors.append("no_next:" + str(id) + "/" + str(sid))
			for nid in d.get("attacks", []):
				if not db["attack"].has(str(nid)):
					errors.append("missing_attack:" + str(id) + "/" + str(nid))
			var attrs: Dictionary = d.get("attributes", {})
			if not StoneStoryAttributes.is_valid(attrs):
				errors.append("bad_attributes:" + str(id))
			if not StoneStoryAttributes.CYCLE.has(StringName(d.get("affinity_attr", "limbs"))):
				errors.append("bad_affinity_attr:" + str(id))
			if not d.has("shape"):
				warnings.append("no_shape:" + str(id))
	for id in db["attack"]:
		var a: Dictionary = db["attack"][id]
		if not a.has("handler"):
			errors.append("no_handler:" + str(id))
		if int(a.get("frames", 0)) <= 0:
			errors.append("bad_frames:" + str(id))


func _validate_regions() -> void:
	var band_ids: Array = []
	for b in _gen_bands():
		band_ids.append(str(b["id"]))
	for id in db["region"]:
		var r: Dictionary = db["region"][id]
		for g in r.get("gates", {}):
			var star: int = int(r["gates"][g].get("min_star", 0))
			if star < 1 or star > 20:
				errors.append("gate_star_range:" + str(id) + "/" + str(g))
		for key in r.get("spawn_cap", {}):
			if not band_ids.has(str(key)):
				errors.append("spawn_cap_key_not_band:" + str(id) + "/" + str(key))
		for t in r.get("tiles", []):
			for k in t:
				if str(k).ends_with("_density"):
					if not ["evidence", "navigation", "mood"].has(str(t[k])):
						errors.append("bad_density:" + str(id) + ":" + str(t[k]))
		for c in r.get("boss_chain", []):
			var fid: String = str(c["foe_id"])
			if not db["boss"].has(fid):
				errors.append("missing_boss:" + str(id) + "/" + fid)
			var thr: float = float(c.get("hp_threshold", 0.0))
			if thr < 0.0 or thr > 1.0:
				errors.append("bad_threshold:" + str(id) + "/" + fid)


func _gen_bands() -> Array:
	var path: String = ROOT + "tuning/generation.json"
	if not FileAccess.file_exists(path):
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	return parsed.get("bands", [])


func _validate_refs() -> void:
	for id in db["region"]:
		var r: Dictionary = db["region"][id]
		for pool in r.get("foe_pools", []):
			for fid in pool.get("ids", []):
				if not db["foe"].has(str(fid)):
					errors.append("missing_foe:" + str(id) + "/" + str(fid))
		for pool in r.get("obstacle_pool", []):
			for oid in pool.get("ids", []):
				if not db["obstacle"].has(str(oid)):
					errors.append("missing_obstacle:" + str(id) + "/" + str(oid))
		var shop_id: Variant = r.get("shop_id", null)
		if shop_id != null and not str(shop_id).is_empty() and not db["shop"].has(str(shop_id)):
			errors.append("missing_shop:" + str(id) + "/" + str(shop_id))
	for id in db["recipe"]:
		var rc: Dictionary = db["recipe"][id]
		for key in ["output", "input_a", "input_b", "requires_unlock"]:
			var v: String = str(rc.get(key, ""))
			if v.is_empty():
				continue
			var target_kind: String = "item"
			if v.begins_with("aff_"):
				target_kind = "affix"
			elif v.begins_with("ench_"):
				target_kind = "enchant"
			elif v.begins_with("stone_"):
				target_kind = "stone"
			if not db[target_kind].has(v):
				errors.append("recipe_ref:" + str(id) + "/" + v)
	for id in db["class"]:
		var c: Dictionary = db["class"][id]
		for it in c.get("start_items", []):
			if not db["item"].has(str(it)):
				errors.append("class_item:" + str(id) + "/" + str(it))
		var ba: Dictionary = c.get("base_attributes", {})
		if not StoneStoryAttributes.is_valid(ba):
			errors.append("class_base_attributes:" + str(id))
		if not StoneStoryAttributes.CYCLE.has(StringName(c.get("affinity_attr", "limbs"))):
			errors.append("class_affinity_attr:" + str(id))
	for id in db["stone"]:
		var s: Dictionary = db["stone"][id]
		if str(s.get("verb", "")) == "":
			errors.append("stone_no_verb:" + str(id))
		if str(s.get("name", "")) == "":
			errors.append("stone_no_name:" + str(id))
		if s.has("drop_from") and str(s["drop_from"].get("kind", "")) in ["boss", "miniboss"]:
			var fid: String = str(s["drop_from"].get("id", ""))
			if not db[str(s["drop_from"]["kind"])].has(fid):
				errors.append("stone_drop:" + str(id) + "/" + fid)
