extends GutTest

## Kit 05 장면 계약: A1 팔레트 · A2 구조물 · A3 실루엣 · 소품 규칙(V9) · D-5 · D-7 · V13 배치

const PALETTE_SRC := "res://modules/stone_story_rpg/presentation/palette.gd"
const VIEW_SRC := "res://modules/stone_story_rpg/presentation/view.gd"
const WINDOWS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(1920, 1280)]

var _tuning: StoneStoryTuning
var _content: StoneStoryContent


func before_all() -> void:
	_tuning = StoneStoryTuning.new()
	assert_eq(_tuning.load_all(), OK, "tuning loads")
	_content = StoneStoryContent.new()
	assert_true(_content.load_all(), "content loads: " + str(_content.errors))


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s: String = f.get_as_text()
	f.close()
	return s


func _fresh_content() -> StoneStoryContent:
	var c := StoneStoryContent.new()
	c.load_all()
	c.errors.clear()
	return c


func _enter() -> Node:
	var inst: Node = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	add_child_autofree(inst)
	await get_tree().process_frame
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	inst.call("enter", ctx)
	await get_tree().process_frame
	return inst


# --- A1 --------------------------------------------------------------

func test_a1_every_region_uses_an_authored_five_colour_palette() -> void:
	for rid in _content.ids("region"):
		var r: Dictionary = _content.get_def("region", str(rid))
		var pid: String = str(r.get("palette", ""))
		assert_true(_content.db["palette"].has(pid), "A1 %s names an authored palette" % rid)
		var def: Dictionary = _content.get_def("palette", pid)
		assert_eq((def["colors"] as Dictionary).size(), 5, "A1 %s has exactly five colours" % pid)
		var pal: ProceduralPalette = StoneStoryPalette.for_region(_content, r)
		for k in def["colors"]:
			assert_eq(pal.get_color(StringName(k)).to_html(false), Color.html(str(def["colors"][k])).to_html(false),
					"A1 %s/%s is used as authored" % [pid, k])


func test_a1_scene_colours_never_come_from_the_generator() -> void:
	var src: String = _read(PALETTE_SRC)
	assert_false(src.contains("make_palette"), "A1 the PVE generator does not pick scene colours")
	assert_true(src.contains("from_dictionary"), "A1 authored colours enter through ProceduralPalette")
	assert_true(src.contains("shifted(") and src.contains("mix_roles("), "A1 variations come from PVE shifted/mix_roles")


func test_a1_achromatic_palette_is_rejected() -> void:
	var c := _fresh_content()
	c.db["palette"]["pal_grey_test"] = {"id": "pal_grey_test", "colors": {
		"sky": "#808080", "horizon": "#f7c948", "ground": "#e8823a", "structure": "#16474d", "accent": "#ff4f93"}}
	c._validate_visuals()
	assert_true(str(c.errors).contains("palette_achromatic:pal_grey_test/sky"), "A1 a grey face colour is refused")


func test_d5_lobby_and_hub_scene_share_one_palette() -> void:
	var inst: Node = await _enter()
	var lobby: Object = inst.get("_lobby")
	var hub: Dictionary = _content.get_def("region", "region_under_sign")
	var hub_pal: ProceduralPalette = StoneStoryPalette.for_region(_content, hub)
	assert_eq(StoneStoryPalette.authored_hex(lobby.get("pal")), StoneStoryPalette.authored_hex(hub_pal),
			"D-5 the lobby uses the hub palette")
	inst.call("_on_go")
	await get_tree().process_frame
	var view: Object = inst.get("_view")
	assert_eq(StoneStoryPalette.authored_hex(view.get("pal")), StoneStoryPalette.authored_hex(hub_pal),
			"D-5 the hub expedition uses the same palette as the lobby")
	inst.call("exit")


# --- A2 --------------------------------------------------------------

func test_a2_three_structures_are_explicit_geometry() -> void:
	var kinds: Array = []
	for sid in _content.ids("structure"):
		var d: Dictionary = _content.get_def("structure", str(sid))
		kinds.append(str(d.get("kind", "")))
		var layer_list: Array = d.get("layers", [])
		assert_gt(layer_list.size(), 3, "A2 %s has authored layers" % sid)
		for l in layer_list:
			var n: int = int(l.has("fill")) + int(l.has("beams")) + int(l.has("joints"))
			assert_eq(n, 1, "A2 %s layer is one explicit primitive" % sid)
		assert_gte(StoneStoryContent.visible_ratio(layer_list), 0.25, "A2/V7 %s is a large thing" % sid)
	kinds.sort()
	assert_eq(kinds, ["arch", "canyon", "dome"], "A2 dome / canyon / arch exist")


func test_a2_regions_name_their_structure() -> void:
	assert_eq(str(_content.get_def("region", "region_hollow_cistern").get("structure", "")), "str_dome_ribs")
	assert_eq(str(_content.get_def("region", "region_under_sign").get("structure", "")), "str_arch_cathedral")
	var src: String = _read(VIEW_SRC)
	assert_false(src.contains("_draw_far_structure"), "A2 the rectangle-stack drawer is gone")


# --- A3-b 절차 애니메이션 개체 -----------------------------------------

const GROUND_AT := Vector2(400.0, 500.0)
const CRITTER_SRC := "res://modules/stone_story_rpg/presentation/critter.gd"


func test_a3_three_body_plans_and_every_creature_uses_one() -> void:
	var forms: Array = []
	for sid in _content.ids("silhouette"):
		var def: Dictionary = _content.get_def("silhouette", str(sid))
		forms.append(str(def.get("form", "")))
		assert_eq(_content.body_plan_errors(str(sid), def), [] as Array[String], "A3 %s is a valid body plan" % sid)
	forms.sort()
	assert_eq(forms, ["crawler", "hauler", "strider"], "A3 three body plans")
	for kind in ["foe", "boss", "miniboss", "class"]:
		for id in _content.ids(kind):
			var sid2: String = str(_content.get_def(kind, str(id)).get("silhouette", ""))
			assert_true(_content.db["silhouette"].has(sid2), "A3 %s uses an authored body plan" % id)


func test_a3_retired_coordinate_silhouette_is_rejected() -> void:
	var bad: Dictionary = {"id": "sil_x", "form": "crab", "body": [[0, 0]], "mark": [], "eyes": {"stalk": 0.2},
			"spine": {"nodes": [5, 6], "length": 1.0}, "ride": 0.3, "girth": 0.2, "vary": 0.1, "head": {"size": 1.0}}
	var errs: Array[String] = _content.body_plan_errors("sil_x", bad)
	assert_has(errs, "silhouette_bad_form:sil_x")
	assert_has(errs, "silhouette_retired_key:sil_x/mark", "A3 the pink band is gone")
	assert_has(errs, "silhouette_retired_key:sil_x/eyes", "A3 stalk eyes are gone")
	var src: String = _read(CRITTER_SRC)
	assert_false(src.contains("stalk"), "A3 no stalk eyes")
	assert_false(src.contains("horn"), "A3 no horns")
	assert_true(src.contains("static func ik("), "A3 limbs are solved by IK")


func _critter(attrs: Dictionary, sil_id: String = "sil_strider", fly: bool = false) -> StoneStoryCritter:
	var c := StoneStoryCritter.build(_content.get_def("silhouette", sil_id), attrs,
			{"width_units": 30, "height_units": 50}, 7, 1.0, fly)
	c.place(GROUND_AT)
	return c


## 게임처럼 앵커가 칸 단위(7px)로 뛴다. 몸은 스스로 따라가야 한다.
func _run(c: StoneStoryCritter, seconds: float, speed: float = 0.0) -> void:
	var x: float = c.anchor.x
	var acc: float = 0.0
	for i in int(seconds * 60.0):
		acc += speed / 60.0
		if absf(acc) >= 7.0:
			x += signf(acc) * 7.0
			acc -= signf(acc) * 7.0
		c.facing = 1.0 if speed >= 0.0 else -1.0
		c.place(Vector2(x, GROUND_AT.y))
		c.step(1.0 / 60.0)


func _base(limbs: int) -> Dictionary:
	return {"limbs": limbs, "surprise": 0.0, "wrongness": 0.0, "roundness": 0.0}


func _mean_rad(c: StoneStoryCritter) -> float:
	var s: float = 0.0
	for r in c.rad:
		s += r
	return s / float(maxi(1, c.rad.size()))


func _leg_lengths(c: StoneStoryCritter) -> Array[float]:
	var out: Array[float] = []
	for L in c.limbs:
		if str(L["kind"]) == "leg" or str(L["kind"]) == "pull":
			out.append(float(L["l1"]) + float(L["l2"]))
	return out


func test_a3_attributes_drive_the_body() -> void:
	var crawl := _critter(_base(8), "sil_crawler")
	assert_eq(crawl.leg_count, 8, "A3 limbs is the limb count")
	assert_eq(crawl.legs_n, 8, "A3 a crawler walks on all of them")
	var walker := _critter(_base(4))
	assert_eq([walker.legs_n, walker.arms_n], [2, 2], "A3 a strider stands on two and carries two")
	var haul := _critter(_base(4), "sil_hauler")
	assert_eq(haul.arms_n, 4, "A3 a hauler pulls itself with its arms")
	var fat := _base(4)
	fat["roundness"] = 10.0
	assert_gt(_mean_rad(_critter(fat)), _mean_rad(walker) * 1.4, "A3 roundness thickens the body")
	assert_true(walker.ridges, "A3 low roundness shows a ridged back")
	assert_false(_critter(fat).ridges)
	var sur := _base(4)
	sur["surprise"] = 9.0
	assert_eq(_critter(sur).eye_count, 3, "A3 surprise adds small eyes")
	assert_eq(walker.eye_count, 1, "A3 every creature has an eye")
	var legs0: Array[float] = _leg_lengths(crawl)
	assert_almost_eq(legs0.max(), legs0.min(), 0.001, "A3 wrongness 0 is symmetric")
	assert_eq(crawl.kink_at, -1, "A3 wrongness 0 keeps the spine straight")
	var wr := _base(8)
	wr["wrongness"] = 10.0
	var bent := _critter(wr, "sil_crawler")
	var legs1: Array[float] = _leg_lengths(bent)
	assert_gt(legs1.max(), legs1.min() * 1.3, "A3 wrongness lengthens one leg")
	assert_gte(bent.kink_at, 0, "A3 wrongness kinks the spine")


func test_a3_ik_keeps_bone_lengths_and_planted_feet_touch_the_ground() -> void:
	for sid in ["sil_crawler", "sil_strider", "sil_hauler"]:
		var c := _critter(_base(6), sid)
		_run(c, 2.5, 70.0)
		var planted: int = 0
		for i in c.limbs.size():
			var d: Dictionary = c.limbs[i]
			var kind: String = str(d["kind"])
			if kind != "leg" and kind != "pull" and kind != "arm":
				continue
			var lp: PackedVector2Array = c.limb_points(i)
			assert_almost_eq(lp[0].distance_to(lp[1]), float(d["l1"]), 0.01, "A3 %s upper bone keeps its length" % sid)
			assert_almost_eq(lp[1].distance_to(lp[2]), float(d["l2"]), 0.01, "A3 %s lower bone keeps its length" % sid)
			if kind != "arm" and c.planted(i):
				planted += 1
				assert_almost_eq((d["foot"] as Vector2).y, GROUND_AT.y, 0.01, "A3 %s a planted foot is on the ground" % sid)
		assert_gt(planted, 0, "A3 %s stands on something" % sid)


func test_a3_walking_steps_alternate_and_the_tail_drags() -> void:
	var c := _critter(_base(6), "sil_crawler")
	_run(c, 1.0)
	var steps0: int = c.steps_taken
	c.max_concurrent_steps = 0
	_run(c, 1.5, 70.0)
	var last: int = c.nodes.size() - 1
	var lag_head: float = c._target(0).x - c.nodes[0].x
	var lag_tail: float = c._target(last).x - c.nodes[last].x
	_run(c, 1.5, 70.0)
	assert_gte(c.steps_taken - steps0, 8, "A3 the feet step on their own while it walks")
	assert_gt(c.max_concurrent_steps, 0)
	assert_lt(c.max_concurrent_steps, c.legs_n, "A3 never lifts every foot at once")
	assert_gt(lag_tail, lag_head + 2.0, "A3 the tail trails behind the head")
	_run(c, 2.0)
	var rest_tail: float = absf(c._target(last).x - c.nodes[last].x)
	assert_lt(rest_tail, lag_tail, "A3 the tail catches up when it stops")


func test_a3_body_plans_stay_distinct() -> void:
	var crawl := _critter(_base(6), "sil_crawler")
	var walk := _critter(_base(4), "sil_strider")
	var haul := _critter(_base(4), "sil_hauler")
	for c in [crawl, walk, haul]:
		_run(c, 1.0)
	var H: float = walk.size_px.y
	var head_h := func(c: StoneStoryCritter) -> float: return (GROUND_AT.y - c.nodes[0].y) / c.size_px.y
	var length := func(c: StoneStoryCritter) -> float: return absf(c.nodes[0].x - c.nodes[c.nodes.size() - 1].x) / c.size_px.y
	assert_gt(head_h.call(walk), head_h.call(crawl) + 0.2, "A3 the strider holds its head up")
	assert_gt(length.call(crawl), length.call(walk) * 1.3, "A3 the crawler is long and low")
	for i in range(1, haul.tail_from):
		assert_lt(GROUND_AT.y - haul.nodes[i].y - haul.rad[i], H * 0.12, "A3 the hauler drags its body on the ground")
	var fly := _critter(_base(5), "sil_hauler", true)
	_run(fly, 1.0)
	assert_eq(fly.tentacles_n, 5, "A3 a flyer hangs tentacles instead of legs")
	assert_eq(fly.legs_n, 0)
	for p in fly.nodes:
		assert_gt(GROUND_AT.y - p.y, fly.size_px.y * 0.3, "A3 a flyer floats")


func test_a3_player_uses_the_same_rig() -> void:
	var cls: Dictionary = _content.get_def("class", "class_ashbound")
	assert_eq(str(cls.get("silhouette", "")), "sil_strider", "A3 the player is a strider too")
	var c := StoneStoryCritter.build(_content.get_def("silhouette", "sil_strider"), cls.get("base_attributes", {}),
			cls.get("shape", {}), 148)
	c.place(GROUND_AT)
	_run(c, 0.5)
	var weapon: Dictionary = {}
	for L in c.limbs:
		if bool(L.get("weapon", false)):
			weapon = L
	assert_false(weapon.is_empty(), "A3 the player holds the weapon in a hand")
	var sh: Vector2 = c.nodes[int(weapon["node"])]
	assert_lt(c.hand_point(GROUND_AT).distance_to(sh), float(weapon["l1"]) + float(weapon["l2"]) + 0.5, "A3 the hand is on the arm")


# --- V9 소품 규칙 ------------------------------------------------------

func test_v9_every_placed_prop_traces_to_a_world_rule() -> void:
	for rid in _content.ids("region"):
		var r: Dictionary = _content.get_def("region", str(rid))
		assert_eq(_content.scene_errors(str(rid), r), [] as Array[String], "V9 %s scene obeys R6-R8" % rid)
		var broken: Array = []
		for p in r.get("props", []):
			if not str(p.get("breaks", "")).is_empty():
				broken.append(str(p["breaks"]))
		assert_lte(broken.size(), 1, "V9 %s: at most one prop breaks a rule besides the structure" % rid)


func test_v9_unruled_strangeness_is_rejected() -> void:
	var c := _fresh_content()
	var r: Dictionary = c.get_def("region", "region_under_sign").duplicate(true)
	r["props"].append({"prop_id": "prop_vat", "x": 500, "y": 120})
	assert_true(str(c.scene_errors("t", r)).contains("prop_floats_without_rule"), "V9 floating needs the gravity rule")
	var r2: Dictionary = c.get_def("region", "region_under_sign").duplicate(true)
	r2["props"].append({"prop_id": "prop_deadtree", "x": 700, "y": 300})
	assert_true(str(c.scene_errors("t", r2)).contains("prop_duplicate_without_rule"), "V9 a copy needs the placement rule")
	var r3: Dictionary = c.get_def("region", "region_under_sign").duplicate(true)
	r3["props"].append({"prop_id": "prop_vat", "x": 700, "y": 350, "breaks": "placement", "twin": {"x": 650, "y": 340, "scale": 0.5}})
	assert_true(str(c.scene_errors("t", r3)).contains("all_rules_broken"), "V9 three broken rules at once are refused")


# --- D-7 허브 ---------------------------------------------------------

func test_d7_hub_expedition_works_the_well_instead_of_bouncing() -> void:
	var inst: Node = await _enter()
	inst.call("_on_go")
	assert_eq(str(inst.get("mode")), "expedition", "D-7 the hub expedition starts")
	var st: Dictionary = inst.get("state")
	var work: Array = st["encounter"]["work"]
	assert_false(work.is_empty(), "D-7 the hub well is work to do")
	var total: int = int(work[0]["ticks_total"])
	assert_gte(total, 60, "D-7 the visit lasts at least two seconds")
	for i in 5:
		inst.call("_tick")
	assert_eq(str(inst.get("mode")), "expedition", "D-7 the hub does not bounce back at once")
	for i in total + 5:
		inst.call("_tick")
	assert_eq(str(inst.get("mode")), "lobby", "D-7 the hub returns once the well is worked")
	var after: Dictionary = inst.get("state")
	assert_gt(int(after["player"]["inventory"]["materials"].get("mat_ash", 0)), 0, "D-7 the well yields ash")
	assert_true(after["world"]["unlocked_regions"].has("region_hollow_cistern"), "D-7 the visit still opens the cistern")
	inst.call("exit")


# --- V13 배치 ---------------------------------------------------------

func test_v13_frame_fills_16_9_and_keeps_the_safe_area() -> void:
	for win in WINDOWS:
		var root_scale: float = minf(float(win.x) / 1280.0, float(win.y) / 720.0)
		var lay: Dictionary = StoneStoryFrame.layout_for(Vector2(1280, 720), root_scale)
		assert_gte(int(lay["view_w"]), StoneStoryFrame.VIEW_W, "V13 %s keeps the 960 safe width" % str(win))
		assert_gte(int(lay["safe_x"]), 0, "V13 %s safe area is inside the view" % str(win))
		var shown: Vector2 = lay["shown"]
		assert_almost_eq(shown.y, 720.0, 0.5, "V13 %s fills the height" % str(win))
		assert_lte(shown.x, 1280.5, "V13 %s does not overflow the width" % str(win))
		assert_gte(shown.x, 1279.0, "V13 %s fills a 16:9 width" % str(win))
		var px: Vector2i = lay["pixels"]
		assert_eq(px.y, roundi(720.0 * root_scale), "V13 %s rasterises at the real pixel height" % str(win))


func _no_overlap(boxes: Array, bounds: Rect2, tag: String) -> void:
	assert_gt(boxes.size(), 3, tag + " drew text")
	for i in boxes.size():
		var a: Rect2 = boxes[i]["rect"]
		assert_true(bounds.encloses(a), "%s '%s' is not clipped" % [tag, str(boxes[i]["text"])])
		for j in range(i + 1, boxes.size()):
			var b: Rect2 = boxes[j]["rect"]
			assert_false(a.grow(-1.0).intersects(b.grow(-1.0)),
					"%s '%s' overlaps '%s'" % [tag, str(boxes[i]["text"]), str(boxes[j]["text"])])


func test_v13_lobby_with_maximum_data_has_no_overlap_or_clipping() -> void:
	var inst: Node = await _enter()
	var st: Dictionary = inst.get("state")
	for id in _content.ids("item"):
		inst.call("execute_command", &"ssr_equip", {"item_id": str(id)})
	st["star_level"] = 20
	st["world"]["currency"] = 999999
	for rid in _content.ids("region"):
		if not st["world"]["unlocked_regions"].has(str(rid)):
			st["world"]["unlocked_regions"].append(str(rid))
	var lobby: Object = inst.get("_lobby")
	lobby.call("bind", st, _content, _tuning)
	lobby.set("report", ["비웠다. 통화 999999 · 잿 99 · 열림: 빈 기둥 우물 빈 기둥 우물 빈 기둥 우물", "쓰러졌다. 남은 것: 통화 999999", "돌아왔다"] as Array[String])
	for f in [0, 1, 2, 3]:
		lobby.set("focus", f)
		(lobby as CanvasItem).queue_redraw()
		await get_tree().process_frame
		await get_tree().process_frame
		_no_overlap(lobby.get("layout_boxes"), Rect2(0, 0, 960, 640), "V13 lobby focus %d" % f)
	inst.call("exit")


func test_v13_expedition_hud_has_no_overlap_or_clipping() -> void:
	var inst: Node = await _enter()
	for id in _content.ids("item"):
		inst.call("execute_command", &"ssr_equip", {"item_id": str(id)})
	inst.set("_pending_region", "region_hollow_cistern")
	inst.set("_pending_star", 20)
	inst.call("_on_go")
	var st: Dictionary = inst.get("state")
	st["world"]["currency"] = 999999
	for i in 4:
		await get_tree().process_frame
	var view: Control = inst.get("_view")
	_no_overlap(view.get("hud_boxes"), Rect2(0, 0, view.size.x, 640), "V13 HUD")
	inst.call("exit")
