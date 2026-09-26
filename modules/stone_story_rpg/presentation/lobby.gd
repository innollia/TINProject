class_name StoneStoryLobby
extends Control

## 로비. 플레이어가 직접 조종하는 유일한 장소.
## 여기서 고르는 것은 ①어디를 ②무엇을 unequip/equip ③별 몇 개로 ④탐험을 누른다.

const FOCUS_REGION := 0
const FOCUS_STAR := 1
const FOCUS_GEAR := 2
const FOCUS_GO := 3
const FOCUS_ACTIONS := 4
const FOCUS_COUNT := 5

const GEAR_PAGE: int = 8

var pal: ProceduralPalette = null
var state: Dictionary = {}
var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null

var focus: int = FOCUS_REGION
var region_index: int = 0
var star: int = 1
var gear_index: int = 0
var gear_page: int = 0
var report: Array[String] = []
var owned: Array[String] = []

signal focus_moved(delta: int)
signal star_changed(value: int)
signal region_chosen(region_id: String)
signal gear_toggled(item_id: String)
signal go_requested()


func bind(run_state: Dictionary, content_ref: StoneStoryContent, tuning_ref: StoneStoryTuning) -> void:
	state = run_state
	content = content_ref
	tuning = tuning_ref
	pal = StoneStoryPalette.build("lobby", int(run_state.get("run_seed", 0)))
	star = int(run_state.get("star_level", 1))
	_rebuild_owned()
	queue_redraw()


func _rebuild_owned() -> void:
	owned.clear()
	for id in content.ids("item"):
		var it: Dictionary = content.item(str(id))
		if str(it.get("kind", "")) == "material":
			continue
		owned.append(str(id))
	owned.sort()


func regions() -> Array:
	var out: Array = []
	var unlocked: Array = state.get("world", {}).get("unlocked_regions", [])
	for id in content.ids("region"):
		var rid: String = str(id)
		if unlocked.is_empty() or unlocked.has(rid) or rid == REGION_HUB:
			out.append(rid)
	out.sort()
	return out


const REGION_HUB := "region_under_sign"


func current_region() -> String:
	var r: Array = regions()
	if r.is_empty():
		return REGION_HUB
	return str(r[clampi(region_index, 0, r.size() - 1)])


# --- 입력 ----------------------------------------------------------

func handle(action: StringName) -> bool:
	match action:
		&"stone_story_rpg_up":
			focus = wrapi(focus - 1, 0, FOCUS_COUNT)
			_on_focus()
			return true
		&"stone_story_rpg_down":
			focus = wrapi(focus + 1, 0, FOCUS_COUNT)
			_on_focus()
			return true
		&"stone_story_rpg_left":
			_left()
			return true
		&"stone_story_rpg_right":
			_right()
			return true
		&"stone_story_rpg_confirm":
			_confirm()
			return true
	return false


func _on_focus() -> void:
	focus_moved.emit(0)
	queue_redraw()


func _left() -> void:
	if content == null:
		return
	match focus:
		FOCUS_REGION:
			region_index = wrapi(region_index - 1, 0, maxi(1, regions().size()))
		FOCUS_STAR:
			star = maxi(1, star - 1)
			star_changed.emit(star)
		FOCUS_GEAR:
			_on_focus()
		_:
			pass
	queue_redraw()


func _right() -> void:
	if content == null:
		return
	match focus:
		FOCUS_REGION:
			region_index = wrapi(region_index + 1, 0, maxi(1, regions().size()))
		FOCUS_STAR:
			star = mini(20, star + 1)
			star_changed.emit(star)
		FOCUS_GEAR:
			_on_focus()
		_:
			pass
	queue_redraw()


func _confirm() -> void:
	match focus:
		FOCUS_REGION:
			region_chosen.emit(current_region())
		FOCUS_STAR:
			star = clampi(star, 1, 20)
			star_changed.emit(star)
		FOCUS_GEAR:
			var page: Array = _gear_page_items()
			if page.is_empty():
				return
			var id: String = str(page[clampi(gear_index, 0, page.size() - 1)])
			gear_toggled.emit(id)
			queue_redraw()
		FOCUS_GO:
			go_requested.emit()
		_:
			pass


func _gear_page_items() -> Array:
	var start: int = gear_page * GEAR_PAGE
	var end: int = mini(owned.size(), start + GEAR_PAGE)
	if start >= end:
		return []
	return owned.slice(start, end)


func _equipped_ids() -> Array:
	var out: Array = []
	for g in state.get("player", {}).get("gear", []):
		out.append(str((g as Dictionary).get("item_id", "")))
	return out


# --- 그리기 --------------------------------------------------------

func _draw() -> void:
	draw_rect(Rect2i(0, 0, 960, 640), StoneStoryPalette.fill(pal))
	if state.is_empty() or content == null or pal == null:
		return
	var ink: Color = StoneStoryPalette.line(pal)
	var dim: Color = StoneStoryPalette.line_dim(pal)
	var txt: Color = StoneStoryPalette.text(pal)
	var acc: Color = StoneStoryPalette.accent(pal)

	_text(Vector2(24, 36), "표지 아래", 14, txt)
	_text_right(936, 36, "통화 " + str(int(state.get("world", {}).get("currency", 0))), 12, dim)
	draw_line(Vector2(24, 46), Vector2(936, 46), dim, 1.0, true)

	# 1) 어디를  y 80..
	var regs: Array = regions()
	_section(Vector2(24, 80), "지역", focus == FOCUS_REGION, acc, dim)
	for i in regs.size():
		var rid: String = str(regs[i])
		var def: Dictionary = content.get_def("region", rid)
		var sel: bool = i == clampi(region_index, 0, maxi(0, regs.size() - 1))
		if sel:
			_focus_box(Rect2i(34, 96 + i * 18, 260, 17), focus == FOCUS_REGION, ink, acc)
		_text(Vector2(44, 106 + i * 18), str(def.get("name", rid)), 12, txt if sel else dim)

	# 2) 몇 개로  y 170..
	_section(Vector2(24, 176), "별  ★" + str(star), focus == FOCUS_STAR, acc, dim)
	if focus == FOCUS_STAR:
		_focus_box(Rect2i(34, 190, 300, 16), true, ink, acc)
	_text(Vector2(44, 200), "★".repeat(clampi(star, 0, 20)) + "☆".repeat(20 - clampi(star, 0, 20)), 12, txt)

	# 3) 무엇을  y 250..
	var y0: int = 250
	_section(Vector2(24, y0), "장비", focus == FOCUS_GEAR, acc, dim)
	_text(Vector2(300, y0), "Z 로 켜고 끈다", 10, dim)
	var page: Array = _gear_page_items()
	var eq: Array = _equipped_ids()
	for i in page.size():
		var iid: String = str(page[i])
		var def: Dictionary = content.item(iid)
		var on: bool = eq.has(iid)
		var cur: bool = i == gear_index
		if cur:
			_focus_box(Rect2i(34, y0 + 10 + i * 16, 240, 15), focus == FOCUS_GEAR, ink, acc)
		_text(Vector2(44, y0 + 20 + i * 16),
				("[+] " if on else "[ ] ") + str(def.get("name", iid)), 10, acc if on else (txt if cur else dim))
	# 힌트는 선택 항목 바로 아래 별도 줄
	var hint: String = _gear_hint(page)
	if not hint.is_empty():
		_text(Vector2(300, y0 + 20 + maxi(0, gear_index) * 16), hint, 10, dim)
	_text(Vector2(300, y0 + 40 + page.size() * 16),
			"해금 %d  보유 %d  전체 %d" % [_unlocked_count(), page.size(), owned.size()], 10, dim)

	# 4) 탐험  y 520..
	if focus == FOCUS_GO:
		_focus_box(Rect2i(18, 500, 168, 22), true, ink, acc)
	_text(Vector2(26, 516), "탐험을 보낸다", 12, txt)
	_text(Vector2(220, 506), _policy_line(), 10, dim)
	_text(Vector2(220, 522), _build_line(), 10, dim)
	for i in mini(report.size(), 3):
		_text(Vector2(220, 538 + i * 14), str(report[i]), 10, txt)

	# 5) 잠금 상태. 탐험이 해금의 유일한 수단이다.
	_section(Vector2(24, 560), "닫힌 지역", false, acc, dim)
	var closed: int = content.ids("region").size() - _unlocked_count()
	if closed > 0:
		_text(Vector2(44, 584), "%d 곳이 아직 닫혀 있다. 탐험이 엽니다." % closed, 10, dim)
	else:
		_text(Vector2(44, 584), "모든 지역이 열렸다", 10, dim)
	_text(Vector2(24, 620), "위아래 이동 · 좌우 조절 · Z 확정 · X 돌아가기", 10, dim)


func _section(at: Vector2, label: String, focused: bool, acc: Color, dim: Color) -> void:
	_text(at, label, 12, acc if focused else dim)
	if focused:
		draw_line(at + Vector2(-6, 3), at + Vector2(-6 - 6, 3), acc, 1.0, true)


func _unlocked_count() -> int:
	return regions().size()


## focus 표시. 색이 아니라 **형태**로. (UI 규칙 R2)
func _focus_box(r: Rect2i, focused: bool, ink: Color, acc: Color) -> void:
	_dashed_rect(r, ink if focused else acc)







func _gear_hint(page: Array) -> String:
	if page.is_empty():
		return ""
	var iid: String = str(page[clampi(gear_index, 0, page.size() - 1)])
	var def: Dictionary = content.item(iid)
	var d: Dictionary = def.get("attr_delta", {})
	var parts: Array[String] = []
	if int(d.get("surprise", 0)) != 0:
		parts.append("놀랍다" + _sign(int(d["surprise"])))
	if int(d.get("wrongness", 0)) != 0:
		parts.append("틀림" + _sign(int(d["wrongness"])))
	if int(d.get("roundness", 0)) != 0:
		parts.append("동그라미" + _sign(int(d["roundness"])))
	var pol: Dictionary = def.get("policy_delta", {})
	if not pol.is_empty():
		parts.append("정책 " + ", ".join(pol.keys()))
	return "  ".join(parts)


func _sign(v: int) -> String:
	return ("+" if v > 0 else "") + str(v)


## 장비가 만드는 AI 정책을 미리 보여준다. 이 게임의 핵심 정보다.
func _policy_line() -> String:
	var pol: Dictionary = StoneStoryRunState.resolve_policy(state.get("player", {}), content)
	var retreat: String = "없음" if float(pol.get("retreat_hp_below", 0.0)) <= 0.0 else str(pol.get("retreat_hp_below"))
	return "정책  스탠스=" + str(pol.get("open_with", "attack")) \
			+ "  타깃=" + str(pol.get("focus_priority", "nearest")) \
			+ "  후퇴<" + retreat \
			+ "  행동+" + str(pol.get("actions_per_turn_mod", 0)) \
			+ "  상주가드=" + ("예" if bool(pol.get("always_guard", false)) else "아니오") \
			+ "  절대후퇴=" + ("예" if bool(pol.get("never_retreat", false)) else "아니오")


func _build_line() -> String:
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(state.get("player", {}), content)
	return "이동체  다리 " + str(int(attrs.get("limbs", 1))) \
			+ "  놀랍다 " + str(int(attrs.get("surprise", 0.0))) \
			+ "  틀림 " + str(int(attrs.get("wrongness", 0.0))) \
			+ "  동그라미 " + str(int(attrs.get("roundness", 0.0))) \
			+ "  상성축 " + str(state.get("player", {}).get("affinity_attr", "limbs"))


func _dashed_rect(r: Rect2i, col: Color) -> void:
	var x: int = r.position.x
	var y: int = r.position.y
	var x2: int = r.position.x + r.size.x
	var y2: int = r.position.y + r.size.y
	while x < x2:
		draw_line(Vector2(x, y), Vector2(mini(x + 4, x2), y), col, 1.0, true)
		x += 8
	x = r.position.x
	while x < x2:
		draw_line(Vector2(x, y2), Vector2(mini(x + 4, x2), y2), col, 1.0, true)
		x += 8
	while y < y2:
		draw_line(Vector2(r.position.x, y), Vector2(r.position.x, mini(y + 4, y2)), col, 1.0, true)
		y += 8
	y = r.position.y
	while y < y2:
		draw_line(Vector2(x2, y), Vector2(x2, mini(y + 4, y2)), col, 1.0, true)
		y += 8


func _text(at: Vector2, s: String, px: int, col: Color) -> void:
	if s.is_empty():
		return
	draw_string(font(), Vector2i(at), s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)


func _text_right(right_x: int, y: int, s: String, px: int, col: Color) -> void:
	if s.is_empty():
		return
	var w: int = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	draw_string(font(), Vector2i(right_x - w, y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)


static var _font_res: SystemFont = null


static func font() -> Font:
	if _font_res == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Malgun Gothic", "Gulim", "Arial Unicode MS", "Segoe UI", "sans-serif"])
		f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		_font_res = f
	return _font_res
