class_name EcoRegionLoader
extends RefCounted

const CONTENT_ROOT: String = "res://modules/sideview_ecosystem/content"
const SCHEMA: int = 1
const REGION_PREFIX: String = "reg_"
const ARCHETYPE_PREFIX: String = "arc_"
const FIX_PREFIX: String = "fix."
const PLACE_PREFIX: String = "place."
const ID_PATTERN: String = "^[a-z0-9_]+$"
const AXIS_NAME_PATTERN: String = "^[a-z_]+$"
const MAX_REGIONS: int = 10
const MAX_ROOMS: int = 99
const ROWS_MIN: int = 12
const ROWS_MAX: int = 200
const COLS_MIN: int = 16
const COLS_MAX: int = 240
const TARGET_MIN: float = 24.0
const TARGET_MAX: float = 420.0
const MAX_DENS: int = 9
const MAX_TETHERED: int = 10
const BODY_PARTS_MIN: int = 8
const BODY_PARTS_MAX: int = 12
const LINEAGE_MIN: int = 3
const LINEAGE_MAX: int = 4
const SIDES: Array[String] = ["left", "right", "top", "bottom"]
const OPPOSITE: Dictionary = {"left": "right", "right": "left", "top": "bottom", "bottom": "top"}

const SCHEMA_FILE_KEYS: Array[String] = ["schema", "content_seed"]
const INDEX_KEYS: Array[String] = ["schema", "regions", "start_room", "start_shelter", "start_rung"]
const ARCHETYPE_INDEX_KEYS: Array[String] = ["schema", "archetypes"]
const REGION_KEYS: Array[String] = ["schema", "id", "display_name", "rooms", "links"]
const ROOM_KEYS: Array[String] = ["id", "band", "target_body_px", "place_id", "tiles", "exits", "passages", "triggers", "shelters", "dens", "tethered"]
const EXIT_KEYS: Array[String] = ["id", "side", "from", "to", "to_room", "to_exit"]
const LINK_KEYS: Array[String] = ["from", "to", "via"]
const TRIGGER_KEYS: Array[String] = ["id", "object", "cell", "span"]
const SHELTER_KEYS: Array[String] = ["id", "cell"]
const DEN_KEYS: Array[String] = ["id", "cell", "lineage_of", "stage"]
const TETHER_KEYS: Array[String] = ["axis_id", "archetype", "cell", "rung"]
const LINEAGE_KEYS: Array[String] = ["archetype", "advance_chance"]
const ARCHETYPE_KEYS: Array[String] = [
	"schema", "id", "axis_name", "rung", "variant_rungs", "density", "hp", "move_speed", "chase_speed_mult",
	"think_period", "sense_radius_px", "hearing_radius_px", "fov_deg", "reaction_latency", "aggression",
	"courage", "attack_range_ratio", "attack_windup", "attack_damage", "body_parts", "confined_only",
	"graze_radius_px", "pack_bonus_count", "lineage",
]
const POSITIVE_KEYS: Array[String] = ["density", "hp", "move_speed", "chase_speed_mult", "think_period", "attack_range_ratio"]
const NON_NEGATIVE_KEYS: Array[String] = ["sense_radius_px", "hearing_radius_px", "attack_windup", "attack_damage", "graze_radius_px"]
const UNIT_KEYS: Array[String] = ["aggression", "courage"]

var _errors: PackedStringArray = []
var _ids: Dictionary = {}
var _table: EcoRungTable
var _id_pattern: RegEx = RegEx.create_from_string(ID_PATTERN)


static func load_all(table: EcoRungTable) -> Dictionary:
	return load_from_texts(read_content_texts(CONTENT_ROOT), table)


static func read_content_texts(root: String) -> Dictionary:
	var texts: Dictionary = {}
	for sub: String in ["", "regions", "archetypes"]:
		var dir_path: String = root if sub.is_empty() else root.path_join(sub)
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			continue
		for file_name: String in dir.get_files():
			if file_name.get_extension() == "json":
				var key: String = file_name if sub.is_empty() else sub.path_join(file_name)
				texts[key] = FileAccess.get_file_as_string(dir_path.path_join(file_name))
	return texts


static func load_from_texts(texts: Dictionary, table: EcoRungTable) -> Dictionary:
	var loader: EcoRegionLoader = EcoRegionLoader.new()
	loader._table = table
	var index: EcoContentIndex = loader._build(texts)
	var ok: bool = loader._errors.is_empty()
	return {
		"ok": ok,
		"reason": "" if ok else loader._errors[0].get_slice(" ", 0),
		"detail": "" if ok else loader._errors[0],
		"value": index if ok else null,
		"errors": loader._errors,
	}


func _err(reason: String, where: String) -> void:
	_errors.append("%s %s" % [reason, where])


func _parse(texts: Dictionary, key: String) -> Variant:
	if not texts.has(key):
		_err("json_invalid", key + " missing")
		return null
	var json: JSON = JSON.new()
	if json.parse(str(texts[key])) != OK or not json.data is Dictionary:
		_err("json_invalid", key)
		return null
	return json.data


func _closed(d: Dictionary, allowed: Array[String], where: String) -> bool:
	var clean: bool = true
	for key: Variant in d.keys():
		if not allowed.has(str(key)):
			_err("key_unknown", "%s.%s" % [where, key])
			clean = false
	return clean


func _claim(id_value: String, where: String) -> void:
	if _ids.has(id_value):
		_err("id_duplicate", where + " " + id_value)
	_ids[id_value] = true


static func _num(v: Variant) -> bool:
	return (v is float or v is int) and is_finite(float(v))


static func _whole(v: Variant) -> bool:
	return _num(v) and float(v) == floorf(float(v))


static func _cell(v: Variant) -> Variant:
	if not v is Array or (v as Array).size() != 2 or not _whole(v[0]) or not _whole(v[1]):
		return null
	return Vector2i(int(v[0]), int(v[1]))


func _string_id(v: Variant) -> bool:
	return v is String and _id_pattern.search(v) != null


func _build(texts: Dictionary) -> EcoContentIndex:
	var index: EcoContentIndex = EcoContentIndex.new()
	var schema_file: Variant = _parse(texts, "schema_version.json")
	if schema_file is Dictionary:
		_closed(schema_file, SCHEMA_FILE_KEYS, "schema_version")
		if not _whole(schema_file.get("schema")) or int(schema_file.get("schema")) != SCHEMA:
			_err("schema_unsupported", "schema_version")
		if not _whole(schema_file.get("content_seed")):
			_err("value_invalid", "schema_version.content_seed")
		else:
			index.content_seed = int(schema_file["content_seed"])
	_load_archetypes(texts, index)
	var region_index: Variant = _parse(texts, "regions/index.json")
	if not region_index is Dictionary:
		return index
	_closed(region_index, INDEX_KEYS, "regions/index")
	if not _whole(region_index.get("schema")) or int(region_index.get("schema")) != SCHEMA:
		_err("schema_unsupported", "regions/index")
	var region_ids: Variant = region_index.get("regions")
	if not region_ids is Array or (region_ids as Array).is_empty() or (region_ids as Array).size() > MAX_REGIONS:
		_err("value_invalid", "regions/index.regions")
		return index
	var seen_regions: Dictionary = {}
	for i: int in (region_ids as Array).size():
		var rid: Variant = region_ids[i]
		if not _string_id(rid) or not str(rid).begins_with(REGION_PREFIX):
			_err("value_invalid", "regions/index.regions[%d]" % i)
			continue
		if seen_regions.has(rid):
			_err("id_duplicate", "region " + str(rid))
			continue
		seen_regions[rid] = true
		var region: EcoRegionSpec = _load_region(texts, str(rid), i, index)
		if region != null:
			index.regions.append(region)
	_check_exits(index)
	_check_links(index)
	_check_start(region_index, index)
	return index


func _load_archetypes(texts: Dictionary, index: EcoContentIndex) -> void:
	var arc_index: Variant = _parse(texts, "archetypes/index.json")
	if not arc_index is Dictionary:
		return
	_closed(arc_index, ARCHETYPE_INDEX_KEYS, "archetypes/index")
	if not _whole(arc_index.get("schema")) or int(arc_index.get("schema")) != SCHEMA:
		_err("schema_unsupported", "archetypes/index")
	var ids: Variant = arc_index.get("archetypes")
	if not ids is Array or (ids as Array).is_empty():
		_err("value_invalid", "archetypes/index.archetypes")
		return
	for aid: Variant in ids:
		if not _string_id(aid) or not str(aid).begins_with(ARCHETYPE_PREFIX) or index.archetypes.has(aid):
			_err("value_invalid", "archetypes/index " + str(aid))
			continue
		var d: Variant = _parse(texts, "archetypes/%s.json" % aid)
		if d is Dictionary:
			index.archetypes[str(aid)] = d
			index.archetype_ids.append(str(aid))
	for aid: String in index.archetype_ids:
		_check_archetype(index.archetypes[aid], aid, index)


func _check_archetype(d: Dictionary, aid: String, index: EcoContentIndex) -> void:
	var where: String = "archetype " + aid
	_closed(d, ARCHETYPE_KEYS, where)
	if not _whole(d.get("schema")) or int(d.get("schema")) != SCHEMA:
		_err("schema_unsupported", where)
	if str(d.get("id", "")) != aid:
		_err("value_invalid", where + ".id")
	if not d.get("axis_name") is String or RegEx.create_from_string(AXIS_NAME_PATTERN).search(str(d.get("axis_name"))) == null:
		_err("value_invalid", where + ".axis_name")
	var base_rung: String = str(d.get("rung", ""))
	if not _table.has_name(base_rung):
		_err("value_invalid", where + ".rung")
	var variants: Variant = d.get("variant_rungs")
	if not variants is Array or (variants as Array).is_empty() or (variants as Array).size() > 2:
		_err("value_invalid", where + ".variant_rungs")
	else:
		for v: Variant in variants:
			if not v is String or _table.ladder.index_of(v) < 0:
				_err("value_invalid", where + ".variant_rungs " + str(v))
		if not (variants as Array).has(base_rung):
			_err("value_invalid", where + ".variant_rungs lacks rung")
		if (variants as Array).size() == 2:
			var a: int = _table.ladder.index_of(str(variants[0]))
			var b: int = _table.ladder.index_of(str(variants[1]))
			if absi(a - b) != 1:
				_err("variant_not_adjacent", where)
	for key: String in POSITIVE_KEYS:
		if not _num(d.get(key)) or float(d.get(key)) <= 0.0:
			_err("value_invalid", "%s.%s" % [where, key])
	for key: String in NON_NEGATIVE_KEYS:
		if not _num(d.get(key)) or float(d.get(key)) < 0.0:
			_err("value_invalid", "%s.%s" % [where, key])
	for key: String in UNIT_KEYS:
		if not _num(d.get(key)) or float(d.get(key)) < 0.0 or float(d.get(key)) > 1:
			_err("value_invalid", "%s.%s" % [where, key])
	if not _num(d.get("fov_deg")) or float(d.get("fov_deg")) <= 0.0 or float(d.get("fov_deg")) > 360.0:
		_err("value_invalid", where + ".fov_deg")
	var latency: Variant = d.get("reaction_latency")
	if not latency is Array or (latency as Array).size() != 2 or not _num(latency[0]) or not _num(latency[1]) or float(latency[0]) < 0.0 or float(latency[0]) > float(latency[1]):
		_err("value_invalid", where + ".reaction_latency")
	if not _whole(d.get("body_parts")) or int(d.get("body_parts")) < BODY_PARTS_MIN or int(d.get("body_parts")) > BODY_PARTS_MAX:
		_err("value_invalid", where + ".body_parts")
	if not d.get("confined_only") is bool:
		_err("value_invalid", where + ".confined_only")
	if not _whole(d.get("pack_bonus_count")) or int(d.get("pack_bonus_count")) < 0:
		_err("value_invalid", where + ".pack_bonus_count")
	var lineage: Variant = d.get("lineage")
	if not lineage is Array or (lineage as Array).size() < LINEAGE_MIN or (lineage as Array).size() > LINEAGE_MAX:
		_err("value_invalid", where + ".lineage")
		return
	for i: int in (lineage as Array).size():
		var stage: Variant = lineage[i]
		if not stage is Dictionary:
			_err("value_invalid", "%s.lineage[%d]" % [where, i])
			continue
		_closed(stage, LINEAGE_KEYS, "%s.lineage[%d]" % [where, i])
		var stage_arc: String = str(stage.get("archetype", "?"))
		if not stage.get("archetype") is String or (not stage_arc.is_empty() and not index.archetypes.has(stage_arc)):
			_err("value_invalid", "%s.lineage[%d].archetype" % [where, i])
		var chance: Variant = stage.get("advance_chance")
		if not _num(chance) or float(chance) < 0.0 or float(chance) > 1:
			_err("value_invalid", "%s.lineage[%d].advance_chance" % [where, i])
	var last: Variant = lineage[(lineage as Array).size() - 1]
	if last is Dictionary and _num(last.get("advance_chance")) and float(last.get("advance_chance")) != 0.0:
		_err("lineage_last_stage_nonzero", where)


func _load_region(texts: Dictionary, rid: String, region_i: int, index: EcoContentIndex) -> EcoRegionSpec:
	var d: Variant = _parse(texts, "regions/%s.json" % rid)
	if not d is Dictionary:
		return null
	var where: String = "region " + rid
	_closed(d, REGION_KEYS, where)
	if not _whole(d.get("schema")) or int(d.get("schema")) != SCHEMA:
		_err("schema_unsupported", where)
	if str(d.get("id", "")) != rid:
		_err("value_invalid", where + ".id")
	if not d.get("display_name") is String or str(d.get("display_name")).is_empty():
		_err("value_invalid", where + ".display_name")
	var region: EcoRegionSpec = EcoRegionSpec.new()
	region.id = rid
	region.display_name = str(d.get("display_name", ""))
	region.index = region_i
	var rooms: Variant = d.get("rooms")
	if not rooms is Array or (rooms as Array).is_empty() or (rooms as Array).size() > MAX_ROOMS:
		_err("value_invalid", where + ".rooms")
		return region
	for i: int in (rooms as Array).size():
		if not rooms[i] is Dictionary:
			_err("value_invalid", "%s.rooms[%d]" % [where, i])
			continue
		var room: EcoRoomSpec = _load_room(rooms[i], rid, i, index)
		if room != null:
			region.rooms.append(room)
			region.room_ids.append(room.id)
			index.rooms[room.id] = room
	var links: Variant = d.get("links", [])
	if not links is Array:
		_err("value_invalid", where + ".links")
		return region
	for i: int in (links as Array).size():
		var link: Variant = links[i]
		var link_where: String = "%s.links[%d]" % [where, i]
		if not link is Dictionary or not _closed(link, LINK_KEYS, link_where):
			if not link is Dictionary:
				_err("value_invalid", link_where)
			continue
		if not link.get("from") is String or not link.get("to") is String or not link.get("via", "") is String:
			_err("value_invalid", link_where)
			continue
		var entry: Dictionary = {"from": str(link["from"]), "to": str(link["to"]), "via": str(link.get("via", "")), "region": rid}
		if not region.room_ids.has(entry["from"]):
			_err("value_invalid", link_where + " from outside region")
			continue
		region.links.append(entry)
		index.links.append(entry)
	return region


func _load_room(d: Dictionary, rid: String, room_i: int, index: EcoContentIndex) -> EcoRoomSpec:
	var room_id: String = str(d.get("id", ""))
	var where: String = "%s/%s" % [rid, room_id]
	if not _string_id(d.get("id")):
		_err("value_invalid", where + ".id")
		return null
	_closed(d, ROOM_KEYS, where)
	_claim(room_id, where)
	var room: EcoRoomSpec = EcoRoomSpec.new()
	room.id = room_id
	room.region_id = rid
	room.index = room_i
	var band: String = str(d.get("band", ""))
	if _table.ladder.index_of(band) < 0:
		_err("band_not_in_table", where)
	elif not _table.has_name(band):
		_err("band_not_used", where)
	room.band = band
	var target: Variant = d.get("target_body_px")
	if not _num(target) or float(target) < TARGET_MIN or float(target) > TARGET_MAX:
		_err("value_invalid", where + ".target_body_px")
	else:
		room.target_body_px = float(target)
	var place: Variant = d.get("place_id", "")
	if not place is String or (not str(place).is_empty() and not str(place).begins_with(PLACE_PREFIX)):
		_err("value_invalid", where + ".place_id")
	else:
		room.place_id = str(place)
	if not _load_tiles(d.get("tiles"), room, where):
		return room
	for list_key: String in ["exits", "passages", "triggers", "shelters", "dens", "tethered"]:
		if d.has(list_key) and not d[list_key] is Array:
			_err("value_invalid", "%s.%s" % [where, list_key])
			return room
	for e: Variant in d.get("exits", []):
		_load_exit(e, room, where)
	for p: Variant in d.get("passages", []):
		_load_passage(p, room, where, index)
	var salt_rows: Dictionary = {}
	for t: Variant in d.get("triggers", []):
		_load_trigger(t, room, where, index, salt_rows)
	_check_salt(room, salt_rows, where)
	for s: Variant in d.get("shelters", []):
		_load_shelter(s, room, where, index)
	var dens: Array = d.get("dens", [])
	if dens.size() > MAX_DENS:
		_err("den_slots_exceeded", where)
	for den: Variant in dens:
		_load_den(den, room, where, index)
	var tethered: Array = d.get("tethered", [])
	if tethered.size() > MAX_TETHERED:
		_err("value_invalid", where + ".tethered count")
	for tether: Variant in tethered:
		_load_tether(tether, room, where, index)
	return room


func _load_tiles(tiles: Variant, room: EcoRoomSpec, where: String) -> bool:
	if not tiles is Array or (tiles as Array).size() < ROWS_MIN or (tiles as Array).size() > ROWS_MAX:
		_err("value_invalid", where + ".tiles rows")
		return false
	var width: int = -1
	var bytes: PackedByteArray = PackedByteArray()
	for y: int in (tiles as Array).size():
		var row: Variant = tiles[y]
		if not row is String:
			_err("value_invalid", "%s.tiles[%d]" % [where, y])
			return false
		var line: String = row
		if width < 0:
			width = line.length()
			if width < COLS_MIN or width > COLS_MAX:
				_err("value_invalid", where + ".tiles width")
				return false
		elif line.length() != width:
			_err("tiles_ragged", "%s row %d" % [where, y])
			return false
		for x: int in width:
			var k: int = EcoTileKind.from_char(line[x])
			if k < 0:
				_err("tile_char_unknown", "%s (%d,%d) '%s'" % [where, x, y, line[x]])
				return false
			bytes.append(k)
	room.tiles_w = width
	room.tiles_h = (tiles as Array).size()
	room.terrain = bytes
	return true


func _rect_empty(room: EcoRoomSpec, r: Rect2i) -> bool:
	for y: int in range(r.position.y, r.end.y):
		for x: int in range(r.position.x, r.end.x):
			if room.tile_at(x, y) != EcoTileKind.EMPTY:
				return false
	return true


func _row_all(room: EcoRoomSpec, y: int, x0: int, x1: int, kinds: Array[int]) -> bool:
	for x: int in range(x0, x1):
		if not kinds.has(room.tile_at(x, y)):
			return false
	return true


func _load_exit(e: Variant, room: EcoRoomSpec, where: String) -> void:
	if not e is Dictionary:
		_err("value_invalid", where + ".exits")
		return
	var exit_where: String = "%s/%s" % [room.id, e.get("id", "?")]
	if not _closed(e, EXIT_KEYS, exit_where):
		return
	var side: String = str(e.get("side", ""))
	if not e.get("id") is String or not SIDES.has(side) or not _whole(e.get("from")) or not _whole(e.get("to")) or not e.get("to_room") is String or not e.get("to_exit") is String:
		_err("value_invalid", exit_where)
		return
	var a: int = int(e["from"])
	var b: int = int(e["to"])
	var side_len: int = room.tiles_h if side == "left" or side == "right" else room.tiles_w
	if a < 0 or a > b or b >= side_len:
		_err("value_invalid", exit_where + " range")
		return
	for i: int in range(a, b + 1):
		var c: Vector2i = _edge_cell(room, side, i)
		if room.tile_at(c.x, c.y) != EcoTileKind.EMPTY:
			_err("exit_blocked", exit_where)
			return
	room.exits.append({"id": str(e["id"]), "side": side, "from": a, "to": b, "to_room": str(e["to_room"]), "to_exit": str(e["to_exit"])})


static func _edge_cell(room: EcoRoomSpec, side: String, i: int) -> Vector2i:
	match side:
		"left":
			return Vector2i(0, i)
		"right":
			return Vector2i(room.tiles_w - 1, i)
		"top":
			return Vector2i(i, 0)
	return Vector2i(i, room.tiles_h - 1)


func _load_passage(p: Variant, room: EcoRoomSpec, where: String, index: EcoContentIndex) -> void:
	if not p is Dictionary:
		_err("value_invalid", where + ".passages")
		return
	var parsed: Dictionary = EcoPassageSpec.from_dictionary(p, room.id)
	if not parsed["ok"]:
		_err(str(parsed["reason"]), str(parsed["detail"]))
		return
	var spec: EcoPassageSpec = parsed["value"]
	var p_where: String = "%s/%s" % [room.id, spec.id]
	_claim(spec.id, p_where)
	var r: Rect2i = spec.rect_tiles()
	if not room.contains_rect(r):
		_err("value_invalid", p_where + " rect outside room")
		return
	if not _rect_empty(room, r):
		_err("passage_over_solid", p_where)
	var rect_px: Rect2 = spec.rect_px()
	match spec.kind:
		EcoPassageKind.GAP:
			var w_gap: float = EcoGapClass.multiplier(spec.width_class) * room.module_px()
			if rect_px.size.x < w_gap + 2.0 * EcoBodyRung.TILE:
				_err("gap_rect_too_narrow", p_where)
		EcoPassageKind.STEP:
			if rect_px.size.y < spec.height_px:
				_err("value_invalid", p_where + " rect lower than height_px")
		EcoPassageKind.DROP:
			var below: int = r.end.y
			if absf(rect_px.size.y - spec.fall_px) > EcoBodyRung.TILE or below >= room.tiles_h or not _row_all(room, below, r.position.x, r.end.x, [EcoTileKind.SOLID, EcoTileKind.SALT, EcoTileKind.DRIFT]):
				_err("drop_height_mismatch", p_where)
	room.passages.append(spec)
	index.passage_room[spec.id] = room.id


func _load_trigger(t: Variant, room: EcoRoomSpec, where: String, index: EcoContentIndex, salt_rows: Dictionary) -> void:
	if not t is Dictionary:
		_err("value_invalid", where + ".triggers")
		return
	var t_where: String = "%s/%s" % [room.id, t.get("id", "?")]
	if not _closed(t, TRIGGER_KEYS, t_where):
		return
	if not _string_id(t.get("id")):
		_err("value_invalid", t_where + ".id")
		return
	var object_name: String = str(t.get("object", ""))
	if not EcoTransitionRule.is_object(object_name):
		_err("trigger_object_unknown", t_where)
		return
	var c: Variant = _cell(t.get("cell"))
	var s: Variant = _cell(t.get("span"))
	if c == null or s == null or (s as Vector2i).x < 1 or (s as Vector2i).y < 1:
		_err("value_invalid", t_where + " cell/span")
		return
	var r: Rect2i = Rect2i(c, s)
	if not room.contains_rect(r):
		_err("value_invalid", t_where + " rect outside room")
		return
	_claim(str(t["id"]), t_where)
	var bottom: int = r.end.y - 1
	if object_name == "salt_bed":
		if not _row_all(room, bottom, r.position.x, r.end.x, [EcoTileKind.SALT]):
			_err("salt_outside_bed", t_where + " bottom row is not salt")
		for x: int in range(r.position.x, r.end.x):
			salt_rows[Vector2i(x, bottom)] = true
	elif object_name == "collapse_floor":
		if not _row_all(room, bottom, r.position.x, r.end.x, [EcoTileKind.SOLID]):
			_err("value_invalid", t_where + " collapse floor row is not solid")
	room.triggers.append({"id": str(t["id"]), "object": object_name, "cell": c, "span": s})
	index.trigger_room[str(t["id"])] = room.id


func _check_salt(room: EcoRoomSpec, salt_rows: Dictionary, where: String) -> void:
	for y: int in room.tiles_h:
		for x: int in room.tiles_w:
			if room.tile_at(x, y) == EcoTileKind.SALT and not salt_rows.has(Vector2i(x, y)):
				_err("salt_outside_bed", "%s (%d,%d)" % [where, x, y])
				return


func _load_shelter(s: Variant, room: EcoRoomSpec, where: String, index: EcoContentIndex) -> void:
	if not s is Dictionary:
		_err("value_invalid", where + ".shelters")
		return
	var s_where: String = "%s/%s" % [room.id, s.get("id", "?")]
	if not _closed(s, SHELTER_KEYS, s_where):
		return
	var c: Variant = _cell(s.get("cell"))
	if not _string_id(s.get("id")) or c == null or not room.contains_cell(c):
		_err("value_invalid", s_where)
		return
	var cell: Vector2i = c
	if room.tile_at(cell.x, cell.y) != EcoTileKind.EMPTY or not EcoTileKind.is_solid(room.tile_at(cell.x, cell.y + 1)):
		_err("value_invalid", s_where + " must stand on solid ground")
	_claim(str(s["id"]), s_where)
	room.shelters.append({"id": str(s["id"]), "cell": cell})
	index.shelter_room[str(s["id"])] = room.id


func _stage_can_fit(archetype_id: String, room: EcoRoomSpec, index: EcoContentIndex) -> bool:
	if archetype_id.is_empty():
		return true
	var arc: Dictionary = index.archetype(archetype_id)
	var band_i: int = _table.ladder.index_of(room.band)
	for v: Variant in arc.get("variant_rungs", []):
		if _table.ladder.index_of(str(v)) <= band_i:
			return true
	return false


func _load_den(den: Variant, room: EcoRoomSpec, where: String, index: EcoContentIndex) -> void:
	if not den is Dictionary:
		_err("value_invalid", where + ".dens")
		return
	var d_where: String = "%s/%s" % [room.id, den.get("id", "?")]
	if not _closed(den, DEN_KEYS, d_where):
		return
	var c: Variant = _cell(den.get("cell"))
	var lineage_of: String = str(den.get("lineage_of", ""))
	if not _string_id(den.get("id")) or c == null or not room.contains_cell(c) or not index.archetypes.has(lineage_of) or not _whole(den.get("stage")):
		_err("value_invalid", d_where)
		return
	var lineage: Array = index.archetype(lineage_of).get("lineage", [])
	var stage: int = int(den["stage"])
	if stage < 0 or stage >= lineage.size():
		_err("value_invalid", d_where + ".stage")
		return
	for s: int in lineage.size():
		var stage_arc: String = str((lineage[s] as Dictionary).get("archetype", "")) if lineage[s] is Dictionary else ""
		if not _stage_can_fit(stage_arc, room, index):
			_err("creature_above_band", "%s stage %d" % [d_where, s])
	_claim(str(den["id"]), d_where)
	room.dens.append({"id": str(den["id"]), "cell": c, "lineage_of": lineage_of, "stage": stage})


func _load_tether(tether: Variant, room: EcoRoomSpec, where: String, index: EcoContentIndex) -> void:
	if not tether is Dictionary:
		_err("value_invalid", where + ".tethered")
		return
	var t_where: String = "%s/%s" % [room.id, tether.get("axis_id", "?")]
	if not _closed(tether, TETHER_KEYS, t_where):
		return
	var axis_id: String = str(tether.get("axis_id", ""))
	var arc_id: String = str(tether.get("archetype", ""))
	var c: Variant = _cell(tether.get("cell"))
	var rung_name: String = str(tether.get("rung", ""))
	if not axis_id.begins_with(FIX_PREFIX) or axis_id.length() <= FIX_PREFIX.length() or not index.archetypes.has(arc_id) or c == null or not room.contains_cell(c):
		_err("value_invalid", t_where)
		return
	if not (index.archetype(arc_id).get("variant_rungs", []) as Array).has(rung_name):
		_err("value_invalid", t_where + ".rung")
		return
	if _table.ladder.index_of(rung_name) > _table.ladder.index_of(room.band):
		_err("creature_above_band", t_where)
	_claim(axis_id, t_where)
	room.tethered.append({"axis_id": axis_id, "archetype": arc_id, "cell": c, "rung": rung_name})


func _check_exits(index: EcoContentIndex) -> void:
	for room_id: Variant in index.rooms.keys():
		var room: EcoRoomSpec = index.rooms[room_id]
		for e: Dictionary in room.exits:
			var where: String = "%s/%s" % [room.id, e["id"]]
			var other: EcoRoomSpec = index.room(str(e["to_room"]))
			if other == null:
				_err("exit_unpaired", where)
				continue
			var back: Dictionary = other.exit_by_id(str(e["to_exit"]))
			if back.is_empty() or str(back["to_room"]) != room.id or str(back["to_exit"]) != str(e["id"]):
				_err("exit_unpaired", where)
				continue
			if str(OPPOSITE[e["side"]]) != str(back["side"]) or int(e["to"]) - int(e["from"]) != int(back["to"]) - int(back["from"]):
				_err("exit_unpaired", where + " side or length")


func _check_links(index: EcoContentIndex) -> void:
	for link: Dictionary in index.links:
		var where: String = "%s>%s" % [link["from"], link["to"]]
		var from_room: EcoRoomSpec = index.room(str(link["from"]))
		var to_room: EcoRoomSpec = index.room(str(link["to"]))
		if from_room == null or to_room == null:
			_err("value_invalid", where + " unknown room")
			continue
		var paired: bool = false
		for e: Dictionary in from_room.exits:
			if str(e["to_room"]) == to_room.id:
				paired = true
		if not paired:
			_err("link_without_exit", where)
		var via: String = str(link["via"])
		if via.is_empty():
			continue
		var owner_room: EcoRoomSpec = null
		if from_room.passage(via) != null:
			owner_room = from_room
		elif to_room.passage(via) != null:
			owner_room = to_room
		if owner_room == null:
			_err("via_unknown", where + " " + via)
			continue
		var spec: EcoPassageSpec = owner_room.passage(via)
		var anyone: bool = false
		for n: String in _table.names():
			if EcoPassageResolver.passable(spec, _table.by_name(n), _table.band_value(owner_room.band), owner_room.target_body_px):
				anyone = true
		if not anyone:
			_err("via_impassable", where + " " + via)


func _check_start(region_index: Dictionary, index: EcoContentIndex) -> void:
	index.start_room = str(region_index.get("start_room", ""))
	index.start_shelter = str(region_index.get("start_shelter", ""))
	index.start_rung = str(region_index.get("start_rung", ""))
	var room: EcoRoomSpec = index.room(index.start_room)
	if room == null or room.shelter_by_id(index.start_shelter).is_empty() or not _table.has_name(index.start_rung):
		_err("start_invalid", "%s/%s/%s" % [index.start_room, index.start_shelter, index.start_rung])
