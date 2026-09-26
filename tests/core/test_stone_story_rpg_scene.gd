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


# --- A3 --------------------------------------------------------------

func test_a3_three_silhouettes_and_every_creature_uses_one() -> void:
	var forms: Array = []
	for sid in _content.ids("silhouette"):
		forms.append(str(_content.get_def("silhouette", str(sid)).get("form", "")))
	forms.sort()
	assert_eq(forms, ["angular", "crab", "lump"], "A3 three silhouettes")
	for kind in ["foe", "boss", "miniboss", "class"]:
		for id in _content.ids(kind):
			var sid: String = str(_content.get_def(kind, str(id)).get("silhouette", ""))
			assert_true(_content.db["silhouette"].has(sid), "A3 %s uses an authored silhouette" % id)


func _critter(attrs: Dictionary, sil_id: String = "sil_angular") -> StoneStoryCritter:
	return StoneStoryCritter.build(_content.get_def("silhouette", sil_id), attrs, {"width_units": 30, "height_units": 50}, 7)


func test_a3_attributes_reshape_the_silhouette() -> void:
	var base: Dictionary = {"limbs": 2, "surprise": 0.0, "wrongness": 0.0, "roundness": 0.0}
	var plain := _critter(base)
	var r := base.duplicate()
	r["roundness"] = 10.0
	assert_gt(_critter(r).body.size(), plain.body.size(), "A3 roundness rounds the corners")
	var l := base.duplicate()
	l["limbs"] = 8
	assert_eq(_critter(l).leg_count, 8, "A3 limbs is the leg count")
	var s := base.duplicate()
	s["surprise"] = 9.0
	assert_eq(_critter(s).eye_count, 4, "A3 surprise adds eyes")
	assert_eq(plain.eye_count, 1, "A3 every creature has an eye")
	var w := base.duplicate()
	w["wrongness"] = 10.0
	var bw: Rect2 = StoneStoryInk.bounds(_critter(w).body)
	var bp: Rect2 = StoneStoryInk.bounds(plain.body)
	assert_almost_eq(bp.end.x, -bp.position.x, 0.02, "A3 wrongness 0 is symmetric")
	assert_gt(bw.end.x, -bw.position.x * 1.15, "A3 wrongness swells one side")


func test_a3_silhouettes_stay_distinct() -> void:
	var a: Dictionary = {"limbs": 4, "surprise": 0.0, "wrongness": 0.0, "roundness": 0.0}
	var crab: Rect2 = StoneStoryInk.bounds(_critter(a, "sil_crab").body)
	var ang: Rect2 = StoneStoryInk.bounds(_critter(a, "sil_angular").body)
	assert_gt(crab.size.x / crab.size.y, ang.size.x / ang.size.y * 1.8, "A3 the crab is wide, the angular one is tall")
	assert_eq(_critter(a, "sil_crab").leg_style, "splay")
	assert_eq(_critter(a, "sil_lump").leg_style, "stub")


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
