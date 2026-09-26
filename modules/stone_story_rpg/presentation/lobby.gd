class_name StoneStoryLobby
extends Control

## 로비. 플레이어가 직접 조종하는 유일한 장소.
## 여기서 고르는 것은 ①어디를 ②몇 개로 ③무엇을 unequip/equip ④탐험을 누른다.
##
## UI 규칙 (docs/UI_WORKFLOW.md, docs/UI_IMPLEMENTATION_RULES.md)
##   R2  focus 는 **형태**(점선 테두리)로만. 색으로 구분하지 않는다.
##       선택(장착됨)과 focus(다음 대상)를 다른 표기로 분리한다.
##       닫고 열면 이전 focus 로 돌아온다. 대상이 사라지면 다음 유효 항목.
##   R3  행 높이와 열 위치를 고정한다. 내용이 바뀌어도 조작 위치가 밀리지 않는다.
##       긴 문자열은 고정 폭에서 자른다. 최대 데이터에서 겹침/잘림 0.
##   R5  disabled 는 형태가 다르다(짧은 실선). 그리고 intent 를 내보내지 않는다.
## 크기: 12 / 14 / 18. (기존 8/10 은 쓰지 않는다)

const FOCUS_REGION := 0
const FOCUS_STAR := 1
const FOCUS_GEAR := 2
const FOCUS_GO := 3
const FOCUS_COUNT := 4

const REGION_HUB := "region_under_sign"
const GEAR_ROWS: int = 6
const ROW_H: int = 24

# 고정 격자. 내용이 바뀌어도 좌표는 이 값뿐이다.
const X_TITLE := 24
const X_BODY := 44
const X_RIGHT := 470
const Y_TITLE := 44
const Y_RULE := 58
const Y_REGION := 100
const Y_STAR := 200
const Y_STAR_MARKS := 228
const Y_GEAR := 268
const Y_GEAR0 := 300
const Y_HINT := 300 + GEAR_ROWS * ROW_H + 12
const Y_GO := 512
const Y_KEYS := 620

const FS_TITLE: int = 18
const FS_HEAD: int = 14
const FS_ROW: int = 14
const FS_SMALL: int = 12
const FS_BIG: int = 18

const MAX_ROW_W: int = 400
const MAX_HINT_W: int = 460

var pal: ProceduralPalette = null
var state: Dictionary = {}
var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null

var focus: int = FOCUS_REGION
var region_index: int = 0
var gear_index: int = 0
var report: Array[String] = []
var owned: Array[String] = []
var _focus_memory: int = FOCUS_REGION

signal region_chosen(region_id: String)
signal star_changed(value: int)
signal gear_toggled(item_id: String)
signal go_requested()


func bind(run_state: Dictionary, content_ref: StoneStoryContent, tuning_ref: StoneStoryTuning) -> void:
	state = run_state
	content = content_ref
	tuning = tuning_ref
	pal = StoneStoryPalette.build("lobby", int(run_state.get("run_seed", 0)))
	_rebuild_owned()
	_clamp_selection()
	queue_redraw()


func _rebuild_owned() -> void:
	owned.clear()
	for id in content.ids("item"):
		if str(content.item(str(id)).get("kind", "")) == "material":
			continue
		owned.append(str(id))
	owned.sort()


## 해금된 지역만 선택 대상. 닫힌 지역은 R5 disabled 다.
## `unlocked_regions` 가 곧 진실이다. 비어 있으면 아무것도 열리지 않는다.
func regions() -> Array:
	var out: Array = []
	var unlocked: Array = state.get("world", {}).get("unlocked_regions", [])
	for id in content.ids("region"):
		if unlocked.has(str(id)):
			out.append(str(id))
	out.sort()
	return out


func all_regions() -> Array:
	var out: Array = []
	for id in content.ids("region"):
		out.append(str(id))
	out.sort()
	return out


func is_open(rid: String) -> bool:
	return state.get("world", {}).get("unlocked_regions", []).has(rid)


func current_region() -> String:
	var r: Array = regions()
	if r.is_empty():
		return REGION_HUB
	return str(r[clampi(region_index, 0, r.size() - 1)])


## 별의 진실은 state["star_level"] 하나뿐이다. 파생 상태를 두지 않는다.
func star_value() -> int:
	return clampi(int(state.get("star_level", 1)), 1, 20)


func _emit_star(v: int) -> void:
	star_changed.emit(clampi(v, 1, 20))
	queue_redraw()


func _clamp_selection() -> void:
	var n: int = regions().size()
	region_index = clampi(region_index, 0, maxi(0, n - 1))
	var rows: int = _gear_window_size()
	gear_index = clampi(gear_index, 0, maxi(0, mini(rows, owned.size()) - 1))


func _gear_window_size() -> int:
	return mini(GEAR_ROWS, owned.size())


# --- 입력 (R5: disabled 는 intent 를 내보내지 않는다) -----------------

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
			return _confirm()
	return false


func _on_focus() -> void:
	_focus_memory = focus
	queue_redraw()


## 탐험에서 돌아오면 여기서부터 이어간다. (R2: 닫기 후 복귀)
func restore_focus() -> void:
	focus = _focus_memory
	queue_redraw()


func _left() -> void:
	if content == null:
		return
	match focus:
		FOCUS_REGION:
			if regions().size() > 1:
				region_index = wrapi(region_index - 1, 0, regions().size())
		FOCUS_STAR:
			_emit_star(maxi(1, star_value() - 1))

		_:
			pass
	queue_redraw()


func _right() -> void:
	if content == null:
		return
	match focus:
		FOCUS_REGION:
			if regions().size() > 1:
				region_index = wrapi(region_index + 1, 0, regions().size())
		FOCUS_STAR:
			_emit_star(mini(20, star_value() + 1))

		FOCUS_GEAR:
			# 다음 칸. 목록 끝이면 처음으로. (R2: 안전한 다음 focus)
			gear_index = wrapi(gear_index + 1, 0, maxi(1, mini(GEAR_ROWS, owned.size())))
		_:
			pass
	queue_redraw()


func _confirm() -> bool:
	match focus:
		FOCUS_REGION:
			region_chosen.emit(current_region())
		FOCUS_STAR:
			_emit_star(star_value())

		FOCUS_GEAR:
			if gear_index >= owned.size():
				return false
			gear_toggled.emit(str(owned[gear_index]))
			queue_redraw()
		FOCUS_GO:
			go_requested.emit()
		_:
			pass
	return true


func _equipped_ids() -> Array:
	var out: Array = []
	for g in state.get("player", {}).get("gear", []):
		out.append(str((g as Dictionary).get("item_id", "")))
	return out


# --- 그리기 ---------------------------------------------------------

func _draw() -> void:
	draw_rect(Rect2i(0, 0, 960, 640), StoneStoryPalette.fill(pal))
	if state.is_empty() or content == null or pal == null:
		return
	var ink: Color = StoneStoryPalette.line(pal)
	var dim: Color = StoneStoryPalette.line_dim(pal)
	var txt: Color = StoneStoryPalette.text(pal)
	var acc: Color = StoneStoryPalette.accent(pal)

	_text(Vector2(X_TITLE, Y_TITLE), "표지 아래", FS_TITLE, txt)
	_text_right(936, Y_TITLE, "통화 %d" % int(state.get("world", {}).get("currency", 0)), FS_SMALL, dim)
	draw_line(Vector2(X_TITLE, Y_RULE), Vector2(936, Y_RULE), dim, 1.0, true)

	_draw_regions(ink, dim, txt, acc)
	_draw_star(ink, dim, txt, acc)
	_draw_gear(ink, dim, txt, acc)
	_draw_go(ink, dim, txt, acc)
	_draw_side(dim, txt)
	_text(Vector2(X_TITLE, Y_KEYS), "위아래 이동 · 좌우 조절 · Z 확정 · X 돌아가기", FS_SMALL, dim)


func _draw_regions(ink: Color, dim: Color, txt: Color, acc: Color) -> void:
	_head(Vector2(X_TITLE, Y_REGION), "지역", focus == FOCUS_REGION, acc, dim)
	var open: Array = regions()
	var shown: Array = []
	for rid in all_regions():
		shown.append(rid)
	for i in mini(shown.size(), 5):
		var rid: String = str(shown[i])
		var opened: bool = is_open(rid)
		var def: Dictionary = content.get_def("region", rid)
		var y: int = Y_REGION + 26 + i * ROW_H
		if not opened:
			# R5 disabled: 짧은 실선 + 흐린 글. confirm 은 아무 일도 하지 않는다.
			draw_line(Vector2(X_BODY, y - 4), Vector2(X_BODY + 16, y - 4), dim, 1.0, true)
			_text(Vector2(X_BODY + 24, y), str(def.get("name", rid)) + "   닫힘", FS_ROW, dim)
			continue
		var sel: bool = rid == current_region()
		if sel:
			_focus_box(Rect2i(X_BODY - 8, y - 14, 300, 20), focus == FOCUS_REGION, ink)
		_text(Vector2(X_BODY, y), str(def.get("name", rid)), FS_ROW, txt)
		_text_right(X_BODY + 290, y, "★%d" % star_value(), FS_SMALL, (acc if sel else dim))
	if focus == FOCUS_REGION and open.size() > 0:
		_text(Vector2(X_BODY, Y_REGION + 26 + mini(shown.size(), 5) * ROW_H),
				"← → 로 고른다", FS_SMALL, dim)


## 별은 폰트가 아니라 절차 도형이다. (이미지 0, 글리프 의존 0)
func _draw_star(ink: Color, dim: Color, txt: Color, acc: Color) -> void:
	_head(Vector2(X_TITLE, Y_STAR), "별", focus == FOCUS_STAR, acc, dim)
	var pitch: int = 22
	var x: int = X_BODY
	var y: int = Y_STAR_MARKS
	if focus == FOCUS_STAR:
		_focus_box(Rect2i(X_BODY - 8, y - 12, 20 * pitch + 60, 20), true, ink)
	for i in 20:
		var on: bool = i < star_value()
		_mark(Vector2(x + i * pitch, y), on, ink if on else dim, 8)
	_text(Vector2(X_BODY + 20 * pitch + 20, y + 6), str(star_value()), FS_BIG, txt)
	_text(Vector2(X_BODY, y + 34), "별이 높을수록 적이 세지고 무엇이 열리느냐가 달라진다", FS_SMALL, dim)


## 20칸 눈금. 채워진 칸만 진하게.
func _mark(at: Vector2, filled: bool, col: Color, r: int) -> void:
	if filled:
		draw_rect(Rect2i(Vector2i(at) - Vector2i(r / 2, r / 2), Vector2i(r, r)), col)
		return
	draw_rect(Rect2i(Vector2i(at) - Vector2i(r / 2, r / 2), Vector2i(r, r)), col, false, 1.0)


func _draw_gear(ink: Color, dim: Color, txt: Color, acc: Color) -> void:
	_head(Vector2(X_TITLE, Y_GEAR), "장비", focus == FOCUS_GEAR, acc, dim)
	_text(Vector2(X_RIGHT, Y_GEAR), "Z 로 켜고 끈다", FS_SMALL, dim)
	var eq: Array = _equipped_ids()
	var rows: int = _gear_window_size()
	for i in rows:
		var iid: String = str(owned[i])
		var def: Dictionary = content.item(iid)
		var on: bool = eq.has(iid)
		var y: int = Y_GEAR0 + i * ROW_H
		if i == gear_index:
			_focus_box(Rect2i(X_BODY - 8, y - 15, 400, 20), focus == FOCUS_GEAR, ink)
		# 선택(장착됨)은 별도 표기. focus 와 다른 형태다.
		var box: Rect2i = Rect2i(Vector2(X_BODY, y - 11), Vector2i(6, 6))
		if on:
			draw_rect(box, acc)
		else:
			draw_rect(box, dim, false, 1.0)
		var label_col: Color = dim
		var tag_col: Color = dim
		if i == gear_index:
			label_col = txt
		if on:
			tag_col = acc
		var label: String = _fit(str(def.get("name", iid)), MAX_ROW_W - 24, FS_ROW)
		var tag: String = _fit(_tag(def), 150, FS_SMALL)
		_text(Vector2(X_BODY + 16, y), label, FS_ROW, label_col)
		_text_right(X_BODY + MAX_ROW_W - 8, y, tag, FS_SMALL, tag_col)
	if rows == 0:
		_text(Vector2(X_BODY, Y_GEAR0), "가진 것이 없다", FS_ROW, dim)

	var hint: String = _gear_hint()
	if not hint.is_empty():
		_text(Vector2(X_BODY, Y_HINT), _fit(hint, MAX_HINT_W, FS_SMALL), FS_SMALL, dim)
	_text(Vector2(X_BODY, Y_HINT + 20),
			"열린 지역 %d · 전체 %d" % [regions().size(), all_regions().size()], FS_SMALL, dim)


func _tag(def: Dictionary) -> String:
	var kind: String = str(def.get("kind", ""))
	if kind == "weapon":
		return "무기 %d" % int(def.get("damage", 0))
	if kind == "shield":
		return "방패"
	if kind == "catalyst":
		return "매체"
	return kind


func _gear_hint() -> String:
	if gear_index >= owned.size():
		return ""
	var def: Dictionary = content.item(str(owned[gear_index]))
	var d: Dictionary = def.get("attr_delta", {})
	var parts: Array[String] = []
	if int(d.get("surprise", 0)) != 0:
		parts.append("놀랍다" + _sign(int(d["surprise"])))
	if int(d.get("wrongness", 0)) != 0:
		parts.append("틀림" + _sign(int(d["wrongness"])))
	if int(d.get("roundness", 0)) != 0:
		parts.append("동그라미" + _sign(int(d["roundness"])))
	var pol: Dictionary = def.get("policy_delta", {})
	for k in pol:
		parts.append("정책:" + str(k))
	return "  ".join(parts)


func _sign(v: int) -> String:
	return ("+" if v > 0 else "") + str(v)


func _draw_go(ink: Color, dim: Color, txt: Color, acc: Color) -> void:
	if focus == FOCUS_GO:
		_focus_box(Rect2i(X_TITLE - 6, Y_GO - 18, 200, 26), true, ink)
	_text(Vector2(X_TITLE, Y_GO), "탐험을 보낸다", FS_HEAD, txt)


## 정책/빌드/결과. 고정 좌표 두 줄로 나눠 겹치지 않게 한다. (R3)
func _draw_side(dim: Color, txt: Color) -> void:
	var pol: Dictionary = StoneStoryRunState.resolve_policy(state.get("player", {}), content)
	var a: String = "정책  스탠스=%s  타깃=%s" % [str(pol.get("open_with", "attack")), str(pol.get("focus_priority", "nearest"))]
	var b: String = "행동%+d  상주가드=%s  절대후퇴=%s" % [
			int(pol.get("actions_per_turn_mod", 0)),
			"예" if bool(pol.get("always_guard", false)) else "아니오",
			"예" if bool(pol.get("never_retreat", false)) else "아니오"]
	_text(Vector2(X_RIGHT, Y_GO - 18), _fit(a, 460, FS_SMALL), FS_SMALL, dim)
	_text(Vector2(X_RIGHT, Y_GO), _fit(b, 460, FS_SMALL), FS_SMALL, dim)
	_text(Vector2(X_RIGHT, Y_GO + 20), _fit(_build_line(), 460, FS_SMALL), FS_SMALL, dim)
	for i in mini(report.size(), 3):
		_text(Vector2(X_RIGHT, Y_GO + 44 + i * 20), _fit(str(report[i]), 460, FS_SMALL), FS_SMALL, txt)


## 장비가 만드는 AI 정책. 이 게임의 핵심 정보다.
func _policy_line() -> String:
	var pol: Dictionary = StoneStoryRunState.resolve_policy(state.get("player", {}), content)
	return "정책 스탠스=%s 타깃=%s 행동%+d 상주가드=%s" % [
			str(pol.get("open_with", "attack")),
			str(pol.get("focus_priority", "nearest")),
			int(pol.get("actions_per_turn_mod", 0)),
			"예" if bool(pol.get("always_guard", false)) else "아니오"]


func _build_line() -> String:
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(state.get("player", {}), content)
	var p: Dictionary = state.get("player", {})
	return "이동체 다리%d 놀랍다%d 틀림%d 동그라미%d 상성축=%s" % [
			int(attrs.get("limbs", 1)), int(attrs.get("surprise", 0.0)),
			int(attrs.get("wrongness", 0.0)), int(attrs.get("roundness", 0.0)),
			str(p.get("affinity_attr", "limbs"))]


func _head(at: Vector2, label: String, focused: bool, acc: Color, dim: Color) -> void:
	_text(at, label, FS_HEAD, (acc if focused else dim))
	if focused:
		draw_line(at + Vector2(-6, -4), at + Vector2(-6, 6), acc, 1.0, true)


## focus 표시. 색이 아니라 **형태**로만. (R2)
func _focus_box(r: Rect2i, focused: bool, ink: Color) -> void:
	_dashed_rect(r, ink if focused else StoneStoryPalette.line_dim(pal))


## 고정 폭에서 자른다. 최대 데이터에서 옆으로 밀리지 않게. (R3)
func _fit(s: String, max_w: int, px: int) -> String:
	if font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= float(max_w):
		return s
	var out: String = s
	while out.length() > 1 and font().get_string_size(out + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > float(max_w):
		out = out.substr(0, out.length() - 1)
	return out + "…"


func _dashed_rect(r: Rect2i, col: Color) -> void:
	var x: int = r.position.x
	var y: int = r.position.y
	var x2: int = r.position.x + r.size.x
	var y2: int = r.position.y + r.size.y
	var d: int = 0
	while x < x2:
		draw_line(Vector2(x, y), Vector2(mini(x + 5, x2), y), col, 1.0, true)
		x += 10
		d += 1
	x = r.position.x
	while x < x2:
		draw_line(Vector2(x, y2), Vector2(mini(x + 5, x2), y2), col, 1.0, true)
		x += 10
	while y < y2:
		draw_line(Vector2(r.position.x, y), Vector2(r.position.x, mini(y + 5, y2)), col, 1.0, true)
		y += 10
	y = r.position.y
	while y < y2:
		draw_line(Vector2(x2, y), Vector2(x2, mini(y + 5, y2)), col, 1.0, true)
		y += 10


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
