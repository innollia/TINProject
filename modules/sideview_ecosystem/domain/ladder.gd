class_name EcoLadder
extends RefCounted

const LADDER_PATH: String = "res://content/scale/ladder.json"
const FALLBACK_NAMES: Array[String] = ["speck", "hand", "doll", "common", "tall", "colossal"]
const LADDER_VERSION: int = 1
const STEP_COUNT: int = 6
const TOP_BAND_MAX: float = 99.0
const EDGE_SNAP: float = 0.001
const SOURCE_FILE: String = "file"
const SOURCE_STORE_CONSTANT: String = "store_constant"
const REASON_INVALID: String = "ladder_invalid"
const NAME_PATTERN: String = "^[a-z_]+$"

var names: Array[String] = []
var values: Array[float] = []
var edges: Array[float] = []
var band_min: Array[float] = []
var band_max: Array[float] = []
var source: String = ""


static func load_or_fallback(store_values: Array) -> Dictionary:
	if FileAccess.file_exists(LADDER_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LADDER_PATH))
		if not parsed is Dictionary:
			return _fail("json_invalid " + LADDER_PATH)
		return from_dictionary(parsed, SOURCE_FILE)
	return from_store_values(store_values)


static func from_store_values(store_values: Array) -> Dictionary:
	if store_values.size() != STEP_COUNT:
		return _fail("store values must have %d entries" % STEP_COUNT)
	var picked: Array = []
	for v: Variant in store_values:
		if not (v is float or v is int):
			return _fail("store value is not a number")
		picked.append(float(v))
	var computed_edges: Array = []
	for i: int in STEP_COUNT - 1:
		computed_edges.append(snappedf(sqrt(float(picked[i]) * float(picked[i + 1])), EDGE_SNAP))
	var mins: Array = [0.0]
	var maxs: Array = []
	for i: int in STEP_COUNT - 1:
		mins.append(computed_edges[i])
		maxs.append(computed_edges[i])
	maxs.append(TOP_BAND_MAX)
	var d: Dictionary = {
		"version": LADDER_VERSION,
		"rungs": Array(FALLBACK_NAMES),
		"values": picked,
		"edges": computed_edges,
		"band_min": mins,
		"band_max": maxs,
	}
	return from_dictionary(d, SOURCE_STORE_CONSTANT)


static func from_dictionary(d: Dictionary, p_source: String) -> Dictionary:
	var version: Variant = d.get("version")
	if not (version is float or version is int) or int(version) != LADDER_VERSION or float(version) != floorf(float(version)):
		return _fail("version must be %d" % LADDER_VERSION)
	var rung_names: Variant = d.get("rungs")
	if not rung_names is Array or (rung_names as Array).size() != STEP_COUNT:
		return _fail("rungs must have %d names" % STEP_COUNT)
	var pattern: RegEx = RegEx.create_from_string(NAME_PATTERN)
	var seen: Dictionary = {}
	for n: Variant in rung_names:
		if not n is String or pattern.search(n) == null or seen.has(n):
			return _fail("rung names must be unique lowercase names")
		seen[n] = true
	var nums: Dictionary = {}
	for key: String in ["values", "edges", "band_min", "band_max"]:
		var arr: Variant = d.get(key)
		var want: int = STEP_COUNT - 1 if key == "edges" else STEP_COUNT
		if not arr is Array or (arr as Array).size() != want:
			return _fail("%s must have %d numbers" % [key, want])
		var typed: Array[float] = []
		for v: Variant in arr:
			if not (v is float or v is int) or not is_finite(float(v)):
				return _fail("%s holds a non-finite or non-number value" % key)
			typed.append(float(v))
		nums[key] = typed
	var vals: Array[float] = nums["values"]
	var edg: Array[float] = nums["edges"]
	var mins: Array[float] = nums["band_min"]
	var maxs: Array[float] = nums["band_max"]
	for i: int in STEP_COUNT:
		if vals[i] <= 0.0:
			return _fail("values must be positive")
		if i > 0 and vals[i] <= vals[i - 1]:
			return _fail("values must strictly increase")
	for i: int in range(1, STEP_COUNT - 1):
		if edg[i] <= edg[i - 1]:
			return _fail("edges must strictly increase")
	if mins[0] != 0.0:
		return _fail("band_min[0] must be 0")
	for i: int in range(1, STEP_COUNT):
		if not is_equal_approx(mins[i], maxs[i - 1]):
			return _fail("band_min[i] must equal band_max[i-1]")
	if maxs[STEP_COUNT - 1] != TOP_BAND_MAX:
		return _fail("band_max top must be %s" % TOP_BAND_MAX)
	var ladder: EcoLadder = EcoLadder.new()
	for n: Variant in rung_names:
		ladder.names.append(str(n))
	ladder.values = vals
	ladder.edges = edg
	ladder.band_min = mins
	ladder.band_max = maxs
	ladder.source = p_source
	return {"ok": true, "reason": "", "detail": "", "value": ladder}


static func _fail(detail: String) -> Dictionary:
	return {"ok": false, "reason": REASON_INVALID, "detail": detail, "value": null}


func index_of(rung_name: String) -> int:
	return names.find(rung_name)


func value_of(rung_name: String) -> float:
	var i: int = names.find(rung_name)
	if i < 0:
		return 0.0
	return values[i]


func name_of(value: float) -> String:
	for i: int in values.size():
		if is_equal_approx(values[i], value):
			return names[i]
	return ""


func band_bounds(rung_name: String) -> Vector2:
	var i: int = names.find(rung_name)
	if i < 0:
		return Vector2.ZERO
	return Vector2(band_min[i], band_max[i])


func to_dictionary() -> Dictionary:
	return {
		"version": LADDER_VERSION,
		"rungs": Array(names),
		"values": Array(values),
		"edges": Array(edges),
		"band_min": Array(band_min),
		"band_max": Array(band_max),
	}
