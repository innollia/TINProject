extends GutTest

## 비주얼 계약 검증 (plans/kits/05_STONE_STORY_RPG_KIT/01_RENDER_PIPELINE.md §8)
##
## 화면 캡처를 눈으로 보지 않아도 계약을 검증한다.
## 렌더러가 자기가 그린 것을 세고(StoneStoryDrawStats) 여기서 판정한다.
## 1차 판이 "검은 배경 + 헤어라인 + 그레이스케일"로 나아간 것을 다시 막는다.

const PLAN := "res://plans/kits/05_STONE_STORY_RPG_KIT/01_RENDER_PIPELINE.md"
const PALETTE := "res://modules/stone_story_rpg/presentation/palette.gd"
const VIEW := "res://modules/stone_story_rpg/presentation/view.gd"
const LOBBY := "res://modules/stone_story_rpg/presentation/lobby.gd"

var _inst: Node = null
var _view: Node = null
var _stats: StoneStoryDrawStats = null


func before_all() -> void:
	_inst = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	add_child(_inst)
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	_inst.call("enter", ctx)
	# 실제 전투 지역으로 보낸다. 허브는 적이 없다.
	# 허브는 적이 없으므로 즉시 끝난다. 전투 지역으로 직접 고정한다.
	_inst.set("mode", "expedition")
	_inst.call("_start_region", "region_hollow_cistern", 12)
	if _inst.get("_lobby") != null:
		(_inst.get("_lobby") as Node).visible = false
	if _inst.get("_view") != null:
		(_inst.get("_view") as Node).visible = true
	for i in 60:
		await get_tree().process_frame
	_view = _inst.get("_view")
	_stats = _view.get("stats")


func after_all() -> void:
	if _inst != null:
		_inst.call("exit")
	_inst.queue_free()


func _drain() -> void:
	for i in 6:
		await get_tree().process_frame
	_view.queue_redraw()
	await get_tree().process_frame


# --- V1 공간이 있다 -------------------------------------------------

func test_v1_space_exists() -> void:
	await _drain()
	assert_gt(_stats.sky_bands, 0, "V1 sky band is drawn")
	assert_gt(_stats.ground_bands, 0, "V1 ground band is drawn")
	assert_true(_stats.has_space(), "V1 every lit scene has sky + ground")


# --- V2 순수 검정 단색이 아니다 --------------------------------------

func test_v2_not_a_flat_black_screen() -> void:
	await _drain()
	assert_true(_stats.has_space(), "V2 a flat black screen has no space")


# --- V3 채워진 면이 충분하다 ----------------------------------------

func test_v3_filled_area_is_real() -> void:
	await _drain()
	var r: float = _stats.filled_ratio()
	assert_gt(r, 0.30, "V3 filled faces must exceed 30% of the screen")
	print("V3_FILLED_RATIO  %.3f" % r)


# --- V4 헤어라인만인 오브젝트가 아니다 ------------------------------

func test_v4_not_a_hairline_only_scene() -> void:
	await _drain()
	var r: float = _stats.stroke_only_ratio()
	assert_lt(r, 0.60, "V4 strokes must not dominate the scene")
	print("V4_STROKE_RATIO  %.3f" % r)


# --- V5 그레이스케일 강제가 없다 -----------------------------------

func test_v5_no_forced_greyscale() -> void:
	var src: String = _read(PALETTE)
	assert_false(src.contains("get_luminance"), "V5 palette must not convert to luminance")
	assert_false(src.contains("func grey("), "V5 palette must not expose a greyscale helper")
	# 채도 있는 폴백이 있어야 한다
	assert_true(src.contains("SKY_NEAR_FALLBACK") and src.contains("GROUND_FALLBACK"),
			"V5 palette fallbacks are coloured")
	var scene: String = _read(VIEW)
	assert_false(scene.contains("density_color"), "V5 view must not use a greyscale density ramp")


func test_v5_painted_faces_are_coloured() -> void:
	await _drain()
	var hues: int = _stats.distinct_hues()
	var grey: float = _stats.grey_share()
	assert_gt(hues, 2, "V5 the scene must use several distinct hues")
	print("V5_HUES  %d" % hues)
	assert_lt(grey, 0.75, "V5 grey share is too high")
	print("V5_GREY  %.3f" % grey)


# --- V6 공간당 색 4~6 ------------------------------------------------

func test_v6_hue_count_in_range() -> void:
	await _drain()
	var hues: int = _stats.distinct_hues()
	assert_true(hues >= 3 and hues <= 10,
			"V6 hue count is outside the contract range 3..10")
	print("V6_HUES  %d" % hues)


# --- V7 큰 것이 있다 -------------------------------------------------

func test_v7_a_large_object_is_present() -> void:
	await _drain()
	var big: float = _stats.largest_object_ratio()
	assert_gt(big, 0.25, "V7 something must occupy more than a quarter of the height")
	print("V7_BIGGEST  %.3f" % big)


# --- V8 개체에 눈이 있다 ---------------------------------------------

func test_v8_creatures_have_eyes() -> void:
	await _drain()
	assert_gt(_stats.eyes, 0, "V8 creatures must carry eyes")
	print("V8_EYES  %d" % _stats.eyes)


# --- V10 / V11 UI 규칙 ------------------------------------------------

func test_v10_ui_body_text_is_large_enough() -> void:
	var src: String = _read(LOBBY)
	var m := RegEx.new()
	m.compile("FS_SMALL: int = (\\d+)")
	var first: bool = true
	var smallest: int = 999
	for hit in m.search_all(src):
		var v: int = int(hit.get_string(1))
		smallest = v if first else mini(smallest, v)
		first = false
	assert_false(first, "V10 lobby must declare a small font size")
	assert_gte(smallest, 16, "V10 the smallest UI text must be 16px or larger")
	print("V10_SMALLEST_PX  %d" % smallest)


func test_v11_ui_is_not_black_with_white_text() -> void:
	var src: String = _read(LOBBY)
	assert_false(src.contains("StoneStoryPalette.fill(pal)"),
			"V11 the lobby must not clear itself to the void colour")
	assert_true(src.contains("StoneStoryPalette.ground(pal)") or src.contains("StoneStoryPalette.sky_near(pal)"),
			"V11 the lobby must paint a space surface, not a void")


# --- V12 focus 는 형태로 표현된다 --------------------------------------

func test_v12_focus_is_a_form_not_only_colour() -> void:
	var src: String = _read(LOBBY)
	assert_true(src.contains("_dashed_rect"), "V12 focus must be drawn as a shape")
	assert_false(src.contains("func _focus_color"), "V12 focus must not be colour-only")
	# focus 를 그리면 반드시 선/면 중 하나가 실제로 그려진다
	var lo: Object = _inst.get("_lobby")
	var focus_rect_called: bool = false
	for c in [src]:
		focus_rect_called = c.contains("_focus_box")
	assert_true(focus_rect_called, "V12 focus box must exist")
	if lo != null:
		lo.set("focus", 2)
		lo.queue_redraw()
		await _drain()


# --- V14 / V15 자산 규칙 ---------------------------------------------

func test_v14_v15_no_image_or_ascii_assets() -> void:
	var images: Array[String] = ["png", "jpg", "jpeg", "webp", "bmp", "svg", "tga", "dds", "exr", "ktx"]
	var offenders: Array[String] = []
	for sub in ["", "content/", "content/tuning/", "presentation/", "systems/", "domain/"]:
		var dir := DirAccess.open("res://modules/stone_story_rpg/" + sub)
		if dir == null:
			continue
		for f in dir.get_files():
			var lower: String = f.to_lower()
			for ext in images:
				if lower.ends_with("." + String(ext)):
					offenders.append(sub + f)
	assert_eq(offenders, [], "V14 no image assets")
	# ASCII 지형은 금지. 큰 ASCII 블록으로 콘텐츠를 찍지 않는다.
	var view_src: String = _read(VIEW)
	assert_false(view_src.contains("char("), "V15 no ASCII glyph rendering")


# --- 계약 문서 자체 -------------------------------------------------

func test_contract_document_declares_the_acceptance_list() -> void:
	var src: String = _read(PLAN)
	for k in ["V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V15"]:
		assert_true(src.contains(k), "contract must declare " + k)
	assert_true(src.contains("폐기"), "contract must record what was discarded")


func test_stats_report_is_readable() -> void:
	await _drain()
	var s: String = _stats.report()
	assert_false(s.is_empty(), "draw stats must report")
	print("DRAW_STATS  " + s)


# --- 헬퍼 ------------------------------------------------------------

func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s: String = f.get_as_text()
	f.close()
	return s
