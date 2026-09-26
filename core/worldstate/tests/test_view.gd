extends GutTest

const VIEW_SCRIPT: GDScript = preload("res://core/worldstate/world_state_view.gd")
const CREATURE_SCRIPT: GDScript = preload("res://core/worldstate/axis_creature.gd")
const OWNER: StringName = &"sideview_ecosystem"
const GARDENER: String = "fix.gardener"
const STAIR: String = "place.tea_stair"
const MASK: String = "place.mirror_march"
const OPEN: String = "place.open_yard"

## 뷰의 공개 메서드가 허용하는 전부. 여기에 없는 이름이 하나라도 생기면 그 뷰는
## 더 이상 읽기 전용이 아니다. (Object 의 set/get 같은 상속 메서드는 제외한다.)
const ALLOWED_VIEW_METHODS: Array[String] = [
	"from_arrival",
	"get_store_version",
	"has_body",
	"get_body",
	"get_creature_ids",
	"has_creature",
	"get_creature",
	"get_place_ids",
	"has_place",
	"get_place",
	"get_focus_place_id",
	"body_satisfies",
	"to_dictionary",
]


func _store() -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	store.declare_owner(WorldState.AXIS_CREATURE, OWNER)
	store.load_snapshot({
		"ax": 1,
		"owners": {"body": String(OWNER), "creature": String(OWNER)},
		"body": {"scale": 1.5, "missing": ["left_arm"]},
		"creatures": {GARDENER: {"id": GARDENER, "archetype": "gardener", "state": "alive"}},
		"places": {
			STAIR: {"region_id": "region.hall", "tags": ["indoor"], "requires_body": {"scale_min": 0.7}},
			OPEN: {"region_id": "region.waste", "tags": ["outdoor"], "requires_body": {}},
		},
		"focus_place_id": STAIR,
	})
	return store


func _public_methods(script: GDScript) -> Array[String]:
	var names: Array[String] = []
	for method: Dictionary in script.get_script_method_list():
		var method_name: String = String(method["name"])
		if not method_name.begins_with("_"):
			names.append(method_name)
	return names


# ── 구조 ───────────────────────────────────────────────────────────────────
func test_the_view_exposes_no_mutating_method() -> void:
	var exposed: Array[String] = _public_methods(VIEW_SCRIPT)
	assert_eq(exposed.size(), ALLOWED_VIEW_METHODS.size(), "the public surface of the view is exactly the frozen list")
	for method_name: String in exposed:
		assert_true(ALLOWED_VIEW_METHODS.has(method_name), method_name)
		assert_true(method_name.begins_with("get_") or method_name in ["from_arrival", "has_body", "has_creature", "has_place", "body_satisfies", "to_dictionary"], method_name)


func test_the_view_holds_no_reference_to_the_store() -> void:
	var view: WorldStateView = _store().issue_view()
	var held: Array[String] = []
	for property: Dictionary in VIEW_SCRIPT.get_script_property_list():
		if not (int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		var value: Variant = view.get(str(property["name"]))
		if value is WorldState or value is WorldStateView:
			held.append(str(property["name"]))
	assert_eq(held, [] as Array[String])
	for method: Dictionary in VIEW_SCRIPT.get_script_method_list():
		for argument: Variant in method["args"] as Array:
			assert_ne(str((argument as Dictionary)["type"]), "WorldState", str(method["name"]))
			assert_ne(str((argument as Dictionary)["type"]), "WorldStateView", str(method["name"]))
	assert_eq(view.to_dictionary().keys(), ["ax", "owners", "body", "creatures", "places", "focus_place_id"])


func test_the_view_publishes_only_its_own_private_storage() -> void:
	var published: Array[String] = []
	for property: Dictionary in VIEW_SCRIPT.get_script_property_list():
		if (int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE) and not String(property["name"]).begins_with("_"):
			published.append(String(property["name"]))
	assert_eq(published, [] as Array[String], "every field the view owns is private by name")


# ── 복사본 ─────────────────────────────────────────────────────────────────
func test_the_view_hands_out_copies_so_a_module_cannot_write_through_it() -> void:
	var store: WorldState = _store()
	var view: WorldStateView = store.issue_view()
	var handed_out: AxisBody = view.get_body()
	## 옛 테스트는 내어준 복사본에 missing 을 비워 넣었다. 부재는 확정 사실이므로 이제
	## 거절된다. 복사본을 쥔 손이 그 사실의 주인이라는 사실은 여전하다.
	var cleared: Dictionary = handed_out.apply({"scale": 0.12, "missing": []})
	assert_false(cleared["ok"], "a recorded part is not un-recorded through a handed out copy either")
	assert_eq(cleared["reason"], WorldState.REASON_FACT_PERMANENT)
	assert_true(handed_out.apply({"scale": 0.12})["ok"], "the module owns the copy it was handed")
	var reread: AxisBody = view.get_body()
	assert_eq(float(reread.get_scale()), 1.5)
	assert_eq(reread.get_missing(), ["left_arm"] as Array[String])
	var creature: AxisCreature = view.get_creature(GARDENER)
	assert_true(creature.apply({"id": GARDENER, "archetype": "gardener", "state": "dead"})["ok"])
	assert_eq((view.get_creature(GARDENER) as AxisCreature).get_state(), "alive")
	var place: AxisPlace = view.get_place(STAIR)
	assert_eq(place.get_requires_body(), {"scale_min": 0.7})
	var saved: Dictionary = view.to_dictionary()
	saved["body"]["scale"] = 999.0
	assert_eq(float((view.get_body() as AxisBody).get_scale()), 1.5)
	assert_eq(float((store.issue_view().get_body() as AxisBody).get_scale()), 1.5)
	assert_true(handed_out != reread, "each read is a new instance")


func test_the_view_reports_absence_instead_of_a_placeholder() -> void:
	var view: WorldStateView = WorldState.new().issue_view()
	assert_false(view.has_body())
	assert_null(view.get_body())
	assert_eq(view.get_creature_ids(), [] as Array[String])
	assert_eq(view.get_place_ids(), [] as Array[String])
	assert_null(view.get_creature("fix.nobody"))
	assert_null(view.get_place("place.nobody"))
	assert_false(view.has_creature("fix.nobody"))
	assert_false(view.has_place("place.nobody"))
	assert_eq(view.get_focus_place_id(), "")
	assert_eq(view.get_store_version(), 1)
	assert_eq(view.body_satisfies(STAIR)["reason"], &"place_unknown")
	var store: WorldState = WorldState.new()
	store.load_snapshot({"ax": 1, "places": {STAIR: {"region_id": "region.hall", "requires_body": {"scale_min": 0.7}}}})
	view = store.issue_view()
	var headless: Dictionary = view.body_satisfies(STAIR)
	assert_eq(headless["reason"], &"axis_absent")
	assert_false(headless["satisfied"])
	assert_eq(headless["unmet"], [] as Array[String])


# ── 인계 ───────────────────────────────────────────────────────────────────
func test_the_view_follows_the_store_without_being_asked() -> void:
	var store: WorldState = _store()
	var view: WorldStateView = store.issue_view()
	assert_true(view.body_satisfies(OPEN)["satisfied"], "a place that asks for nothing is entered by a body that has facts")
	assert_true(view.body_satisfies(STAIR)["satisfied"])
	assert_eq(view.get_focus_place_id(), STAIR)
	store.request_mutation(WorldState.AXIS_BODY, {"wounds": [{"part": "face", "kind": "scar", "severity": 1, "permanent": true}]}, OWNER)
	store.focus_place(MASK)
	assert_eq(view.get_focus_place_id(), STAIR, "an unknown place is refused, so the cursor held")
	store.focus_place(OPEN)
	assert_eq(view.get_focus_place_id(), OPEN, "the store refreshed the view, not the module")
	var seen: AxisBody = view.get_body()
	assert_true(seen.has_wound("face", "scar"), "a fact written by one kit is visible to the next view")
	assert_false(view.has_place(MASK))
	var before: Dictionary = view.to_dictionary()
	store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.28}, OWNER)
	assert_eq(view.body_satisfies(STAIR)["unmet"], ["scale_below_min"] as Array[String])
	assert_ne(view.to_dictionary(), before)


func test_the_view_is_carried_through_arrival_by_reference() -> void:
	var store: WorldState = _store()
	var arrival: Dictionary = store.make_arrival()
	assert_true(arrival.has(WorldState.ARRIVAL_KEY))
	var view: WorldStateView = WorldStateView.from_arrival(arrival.duplicate(true))
	assert_true(view != null)
	assert_eq(view.get_store_version(), 1)
	assert_eq(view.get_place_ids(), [OPEN, STAIR] as Array[String])
	assert_null(WorldStateView.from_arrival({}))
	assert_null(WorldStateView.from_arrival({WorldState.ARRIVAL_KEY: "not a view"}))
	var context: ModuleContext = ModuleContext.new()
	context.arrival = arrival.duplicate(true)
	var carried: WorldStateView = WorldStateView.from_arrival(context.arrival)
	assert_true(carried != null, "a ModuleContext deep copy keeps the view object itself")
	assert_eq(carried.get_creature_ids(), [GARDENER] as Array[String])
	carried.to_dictionary()["body"]["scale"] = 5.0
	assert_eq(float((store.issue_view().get_body() as AxisBody).get_scale()), 1.5)


func test_a_dead_view_does_not_block_the_store() -> void:
	var store: WorldState = _store()
	var view: WorldStateView = store.issue_view()
	assert_eq(view.get_store_version(), 1)
	view = null
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, OWNER)["ok"], "a released view never blocks a write")
	assert_eq(float((store.issue_view().get_body() as AxisBody).get_scale()), 0.65)


# ── 파생 요약 없음 ─────────────────────────────────────────────────────────
func test_the_creature_axis_exposes_no_aggregate_of_its_memory() -> void:
	var banned: Array[String] = ["score", "total", "count", "sum", "karma", "trust", "favor", "tally", "level", "deaths", "average", "ratio"]
	var exposed: Array[String] = []
	for method_name: String in _public_methods(CREATURE_SCRIPT):
		for banned_name: String in banned:
			if method_name.contains(banned_name):
				exposed.append(method_name)
	assert_eq(exposed, [] as Array[String])
	var creature: AxisCreature = CREATURE_SCRIPT.new()
	creature.apply({"id": GARDENER, "archetype": "gardener", "memory": [{"kind": "planted"}]})
	var first: Dictionary = creature.to_dictionary()
	creature.apply({"id": GARDENER, "memory": [{"kind": "planted"}, {"kind": "withered"}, {"kind": "buried"}]})
	var second: Dictionary = creature.to_dictionary()
	first["memory"] = second["memory"]
	assert_eq(second, first, "three remembered events change nothing but the event list")
	assert_eq(second.keys(), ["id", "archetype", "memory"] as Array)
