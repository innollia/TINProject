class_name StoneStoryLobby
extends Control

## 로비. 플레이어가 직접 조종하는 유일한 장소.
## 여기서 고르는 것은 ①어디를 ②몇 개로 ③무엇을 unequip/equip ④탐험을 누른다.
##
## UI 규칙 (docs/UI_WORKFLOW.md, docs/UI_IMPLEMENTATION_RULES.md)
##   R2  focus 는 **형태**(굵은 테두리 + 왼쪽 막대)로만. 색으로 구분하지 않는다.
##       선택(장착됨/현재 지역)과 focus(다음 대상)를 다른 표기로 분리한다.
##       닫고 열면 이전 focus 로 돌아온다. 대상이 사라지면 다음 유효 항목.
##   R3  행 높이와 열 위치를 고정한다. 내용이 바뀌어도 조작 위치가 밀리지 않는다.
##       긴 문자열은 고정 폭에서 자른다. 최대 데이터에서 겹침/잘림 0.
##   R5  disabled 는 형태가 다르다(점선). 그리고 intent 를 내보내지 않는다.
## 로비는 허브(표지 아래)다. 허브 지역의 팔레트와 장면을 그대로 쓴다. (D-5)

const FOCUS_REGION := 0
const FOCUS_STAR := 1
const FOCUS_GEAR := 2
const FOCUS_GO := 3
const FOCUS_COUNT := 4

const REGION_HUB := "region_under_sign"
const REGION_ROWS: int = 3
const GEAR_ROWS: int = 5
const ROW_H: int = 28

const SCENE_SHIFT := 140.0
const LEFT := Rect2(16, 150, 460, 466)
const INFO := Rect2(492, 452, 452, 164)
const X_TITLE := 28
const X_BODY := 52
const X_RIGHT := 512
const Y_TITLE := 58
const Y_REGION := 186
const Y_STAR := 316
const Y_STAR_MARKS := 342
const Y_GEAR := 386
const Y_GEAR0 := 414
const Y_HINT := Y_GEAR0 + GEAR_ROWS * ROW_H + 6
const Y_GO := 596
const Y_INFO := 482
const PLAYER_AT := Vector2(826, 434)
const PLAYER_SCALE := 1.8

const FS_TITLE: int = 30
const FS_HEAD: int = 22
const FS_ROW: int = 20
const FS_SMALL: int = 16
const FS_BIG: int = 26

const MAX_ROW_W: int = 400
const MAX_HINT_W: int = 408
const MAX_INFO_W: int = 420

var pal: ProceduralPalette = null
var state: Dictionary = {}
var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null

var focus: int = FOCUS_REGION
var region_index: int = 0
var gear_index: int = 0
var report: Array[String] = []
var owned: Array[String] = []
var layout_boxes: Array = []
var clock: float = 0.0
var _focus_memory: int = FOCUS_REGION
var _hub: Dictionary = {}
var _preview: StoneStoryCritter = null
var _preview_key: String = ""

signal region_chosen(region_id: String)
signal star_changed(value: int)
signal gear_toggled(item_id: String)
signal go_requested()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind(run_state: Dictionary, content_ref: StoneStoryContent, tuning_ref: StoneStoryTuning) -> void:
	state = run_state
	content = content_ref
	tuning = tuning_ref
	_hub = content.get_def("region", REGION_HUB) if content != null else {}
	pal = StoneStoryPalette.for_region(content, _hub)
	_rebuild_owned()
	_clamp_selection()
	_preview_key = ""
	queue_redraw()


func _process(delta: float) -> void:
	clock += delta
	if _preview != null:
		_preview.step(delta)
	if visible:
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
		FOCUS_GEAR:
			gear_index = wrapi(gear_index - 1, 0, maxi(1, mini(GEAR_ROWS, owned.size())))
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

func _ox() -> float:
	return floorf((maxf(float(StoneStoryFrame.VIEW_W), size.x) - float(StoneStoryFrame.VIEW_W)) * 0.5)


## 로비도 공간이다. 허브의 하늘·바닥·구조물을 그대로 그린다. (V11: 검정 배경 + 흰 글자 금지)
func _draw_room(ox: float) -> void:
	var w: float = maxf(float(StoneStoryFrame.VIEW_W), size.x)
	var hz: float = float(StoneStoryContent.SCENE_HORIZON_Y)
	var seed_v: int = REGION_HUB.hash()
	StoneStorySky.draw(self, pal, _hub, w, hz, clock, null, ox, seed_v)
	StoneStoryGround.draw(self, pal, _hub, w, hz, float(StoneStoryFrame.VIEW_H), null, ox + SCENE_SHIFT, seed_v)
	if content != null:
		StoneStoryStructure.draw(self, content.get_def("structure", str(_hub.get("structure", ""))), pal, ox + SCENE_SHIFT, null)
		for e in StoneStoryProps.placements(content, _hub):
			StoneStoryProps.draw_shadow(self, e, pal, ox + SCENE_SHIFT, clock, null)
			StoneStoryProps.draw_one(self, e, pal, ox + SCENE_SHIFT, clock, null)


func _draw() -> void:
	layout_boxes.clear()
	if pal == null:
		return
	var ox: float = _ox()
	_draw_room(ox)
	if state.is_empty() or content == null:
		return
	draw_set_transform(Vector2(ox, 0.0))
	var txt: Color = StoneStoryPalette.text(pal)
	var dim: Color = StoneStoryPalette.text_dim(pal)
	var acc: Color = StoneStoryPalette.accent(pal)
	_title()
	_draw_player_preview()
	_tablet(LEFT)
	_tablet(INFO)
	_draw_regions(txt, dim, acc)
	_draw_star(txt, dim, acc)
	_draw_gear(txt, dim, acc)
	_draw_go(txt, dim, acc)
	_draw_side(dim, txt)
	draw_set_transform(Vector2.ZERO)


func _title() -> void:
	_text(Vector2(X_TITLE, Y_TITLE), str(_hub.get("name", "표지 아래")), FS_TITLE, StoneStoryPalette.text(pal), true)
	var money: String = "%d" % int(state.get("world", {}).get("currency", 0))
	var mw: float = font().get_string_size(money, HORIZONTAL_ALIGNMENT_LEFT, -1, FS_HEAD).x
	var mx: float = 932.0 - mw
	StoneStoryInk.disc(self, Vector2(mx - 18.0, Y_TITLE - 8.0), 10.0, StoneStoryPalette.ink(pal))
	StoneStoryInk.disc(self, Vector2(mx - 18.0, Y_TITLE - 8.0), 7.5, StoneStoryPalette.accent(pal))
	_text(Vector2(mx, Y_TITLE), money, FS_HEAD, StoneStoryPalette.text(pal), true)


func _tablet(r: Rect2) -> void:
	var outer: PackedVector2Array = _rounded(r, 16.0)
	StoneStoryInk.fill(self, _rounded(Rect2(r.position + Vector2(0, 5), r.size), 16.0), StoneStoryPalette.shadow(pal))
	StoneStoryInk.fill(self, outer, StoneStoryPalette.panel(pal))
	StoneStoryInk.edge(self, _rounded(r.grow(-5.0), 12.0), StoneStoryPalette.panel_edge(pal), 2.0)


func _rounded(r: Rect2, rad: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners: Array = [
		[r.position + Vector2(r.size.x - rad, rad), -PI * 0.5],
		[r.position + Vector2(r.size.x - rad, r.size.y - rad), 0.0],
		[r.position + Vector2(rad, r.size.y - rad), PI * 0.5],
		[r.position + Vector2(rad, rad), PI],
	]
	for c in corners:
		for i in 5:
			var a: float = float(c[1]) + (PI * 0.5) * float(i) / 4.0
			pts.append((c[0] as Vector2) + Vector2(cos(a), sin(a)) * rad)
	return pts


func _draw_player_preview() -> void:
	var p: Dictionary = state.get("player", {})
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(p, content)
	var key: String = JSON.stringify(attrs)
	if _preview == null or key != _preview_key:
		var cls: Dictionary = content.get_def("class", str(p.get("class_id", "")))
		var sil: Dictionary = content.get_def("silhouette", str(cls.get("silhouette", "sil_angular")))
		_preview = StoneStoryCritter.build(sil, attrs, cls.get("shape", {}), 131 + 17, PLAYER_SCALE)
		_preview_key = key
	_preview.facing = -1.0
	_preview.look = Vector2(-1.0, 0.2)
	var looks: Array = []
	for g in p.get("gear", []):
		var def: Dictionary = content.item(str((g as Dictionary).get("item_id", "")))
		var lk: String = str(def.get("look", ""))
		if not lk.is_empty() and not looks.has(lk):
			looks.append(lk)
	var pol: Dictionary = StoneStoryRunState.resolve_policy(p, content)
	var stance: String = "guard" if bool(pol.get("always_guard", false)) else "neutral"
	_preview.draw(self, PLAYER_AT, pal, null, StoneStoryPalette.accent(pal), StoneStoryPalette.sclera(pal))
	StoneStoryCritter.draw_gear(self, _preview, PLAYER_AT, looks, stance, pal, null)


func _draw_regions(txt: Color, dim: Color, acc: Color) -> void:
	_head(Vector2(X_BODY - 20, Y_REGION), "지역", focus == FOCUS_REGION, acc, txt, dim, REGION_ROWS)
	var shown: Array = all_regions()
	for i in mini(shown.size(), REGION_ROWS):
		var rid: String = str(shown[i])
		var def: Dictionary = content.get_def("region", rid)
		var y: int = Y_REGION + 30 + i * ROW_H
		var label: String = _fit(str(def.get("name", rid)), 260, FS_ROW)
		if not is_open(rid):
			# R5 disabled: 점선 + 흐린 글. confirm 은 아무 일도 하지 않는다.
			_dashed_rect(Rect2i(X_BODY, y - 17, 300, 22), dim)
			_text(Vector2(X_BODY + 30, y), label, FS_ROW, dim)
			_text_right(X_BODY + 292, y, "닫힘", FS_SMALL, dim)
			continue
		var sel: bool = rid == current_region()
		if sel:
			_focus_box(Rect2i(X_BODY - 8, y - 20, 330, 27), focus == FOCUS_REGION, acc)
		_swatch(Vector2(X_BODY + 10, y - 7), def)
		_text(Vector2(X_BODY + 30, y), label, FS_ROW, txt if sel else dim)
		_text_right(X_BODY + 312, y, "★%d" % star_value(), FS_SMALL, acc if sel else dim)


func _swatch(c: Vector2, region_def: Dictionary) -> void:
	var rp: ProceduralPalette = StoneStoryPalette.for_region(content, region_def)
	StoneStoryInk.disc(self, c, 9.0, StoneStoryPalette.ink(pal))
	draw_circle(c, 7.5, StoneStoryPalette.sky(rp), true, -1.0, true)
	var half := PackedVector2Array()
	for i in 9:
		var a: float = float(i) / 8.0 * PI
		half.append(c + Vector2(cos(a), sin(a)) * 7.5)
	StoneStoryInk.fill(self, half, StoneStoryPalette.ground(rp))


## 별은 폰트가 아니라 절차 도형이다. (이미지 0, 글리프 의존 0)
func _draw_star(txt: Color, dim: Color, acc: Color) -> void:
	_head(Vector2(X_BODY - 20, Y_STAR), "별", focus == FOCUS_STAR, acc, txt, dim, 1)
	var pitch: int = 17
	if focus == FOCUS_STAR:
		_focus_box(Rect2i(X_BODY - 8, Y_STAR_MARKS - 14, 20 * pitch + 58, 30), true, acc)
	for i in 20:
		var on: bool = i < star_value()
		_mark(Vector2(X_BODY + 6 + i * pitch, Y_STAR_MARKS), on, acc if on else dim, 6.5)
	_text(Vector2(X_BODY + 20 * pitch + 12, Y_STAR_MARKS + 9), str(star_value()), FS_BIG, txt)


func _mark(at: Vector2, filled: bool, col: Color, r: float) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a: float = -PI * 0.5 + TAU * float(i) / 10.0
		pts.append(at + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.46))
	if filled:
		StoneStoryInk.fill(self, pts, col)
		return
	StoneStoryInk.edge(self, pts, col, 1.4)


func _draw_gear(txt: Color, dim: Color, acc: Color) -> void:
	_head(Vector2(X_BODY - 20, Y_GEAR), "장비", focus == FOCUS_GEAR, acc, txt, dim, GEAR_ROWS)
	var eq: Array = _equipped_ids()
	var rows: int = _gear_window_size()
	for i in rows:
		var iid: String = str(owned[i])
		var def: Dictionary = content.item(iid)
		var on: bool = eq.has(iid)
		var y: int = Y_GEAR0 + i * ROW_H
		if i == gear_index:
			_focus_box(Rect2i(X_BODY - 8, y - 20, MAX_ROW_W + 16, 27), focus == FOCUS_GEAR, acc)
		# 선택(장착됨)은 별도 표기. focus 와 다른 형태다.
		var box := Rect2(Vector2(X_BODY + 2, y - 14), Vector2(12, 12))
		if on:
			draw_rect(box, acc)
			draw_rect(box.grow(1.0), StoneStoryPalette.ink(pal), false, 1.5)
		else:
			draw_rect(box, dim, false, 1.6)
		var label: String = _fit(str(def.get("name", iid)), MAX_ROW_W - 180, FS_ROW)
		var tag: String = _fit(_tag(def), 150, FS_SMALL)
		_text(Vector2(X_BODY + 24, y), label, FS_ROW, txt if (on or i == gear_index) else dim)
		_text_right(X_BODY + MAX_ROW_W, y, tag, FS_SMALL, acc if on else dim)
	if rows == 0:
		_text(Vector2(X_BODY, Y_GEAR0), "가진 것이 없다", FS_ROW, dim)
	var hint: String = _gear_hint()
	if not hint.is_empty():
		_text(Vector2(X_BODY, Y_HINT), _fit(hint, MAX_HINT_W, FS_SMALL), FS_SMALL, dim)


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


func _draw_go(txt: Color, dim: Color, acc: Color) -> void:
	var r := Rect2(X_BODY - 8, Y_GO - 27, 250, 38)
	var body: PackedVector2Array = _rounded(r, 12.0)
	StoneStoryInk.fill(self, body, StoneStoryPalette.accent(pal) if focus == FOCUS_GO else StoneStoryPalette.panel_edge(pal))
	if focus == FOCUS_GO:
		StoneStoryInk.edge(self, _rounded(r.grow(4.0), 15.0), StoneStoryPalette.text(pal), 3.0)
	var ink: Color = StoneStoryPalette.ink(pal) if focus == FOCUS_GO else txt
	var tri := PackedVector2Array([Vector2(r.end.x - 34, Y_GO - 17), Vector2(r.end.x - 16, Y_GO - 8), Vector2(r.end.x - 34, Y_GO + 1)])
	StoneStoryInk.fill(self, tri, ink)
	_text(Vector2(X_BODY + 8, Y_GO), "탐험을 보낸다", FS_HEAD, ink, focus != FOCUS_GO)


## 정책/빌드/결과. 고정 좌표로 나눠 겹치지 않게 한다. (R3)
func _draw_side(dim: Color, txt: Color) -> void:
	var pol: Dictionary = StoneStoryRunState.resolve_policy(state.get("player", {}), content)
	var a: String = "정책  스탠스=%s  타깃=%s" % [str(pol.get("open_with", "attack")), str(pol.get("focus_priority", "nearest"))]
	var b: String = "행동%+d  상주가드=%s  절대후퇴=%s" % [
			int(pol.get("actions_per_turn_mod", 0)),
			"예" if bool(pol.get("always_guard", false)) else "아니오",
			"예" if bool(pol.get("never_retreat", false)) else "아니오"]
	_text(Vector2(X_RIGHT, Y_INFO), _fit(a, MAX_INFO_W, FS_SMALL), FS_SMALL, txt)
	_text(Vector2(X_RIGHT, Y_INFO + 22), _fit(b, MAX_INFO_W, FS_SMALL), FS_SMALL, dim)
	_text(Vector2(X_RIGHT, Y_INFO + 44), _fit(_build_line(), MAX_INFO_W, FS_SMALL), FS_SMALL, dim)
	for i in mini(report.size(), 3):
		_text(Vector2(X_RIGHT, Y_INFO + 76 + i * 22), _fit(str(report[i]), MAX_INFO_W, FS_SMALL), FS_SMALL, txt if i == 0 else dim)


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


func _head(at: Vector2, label: String, focused: bool, acc: Color, txt: Color, dim: Color, rows: int) -> void:
	_text(at + Vector2(20, 0), label, FS_HEAD, txt if focused else dim)
	if focused:
		var h: float = 30.0 + float(rows) * float(ROW_H)
		draw_rect(Rect2(at.x, at.y - 18.0, 6.0, h), acc)


## focus 표시. 색이 아니라 **형태**로만. (R2) 굵은 둥근 테두리 = focus, 점선 = focus 가 떠난 현재 선택.
func _focus_box(r: Rect2i, focused: bool, col: Color) -> void:
	if focused:
		StoneStoryInk.edge(self, _rounded(Rect2(r), 8.0), col, 3.0)
		return
	_dashed_rect(r, StoneStoryPalette.text_dim(pal))


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
	while x < x2:
		draw_line(Vector2(x, y), Vector2(mini(x + 6, x2), y), col, 2.0, true)
		draw_line(Vector2(x, y2), Vector2(mini(x + 6, x2), y2), col, 2.0, true)
		x += 11
	while y < y2:
		draw_line(Vector2(r.position.x, y), Vector2(r.position.x, mini(y + 6, y2)), col, 2.0, true)
		draw_line(Vector2(x2, y), Vector2(x2, mini(y + 6, y2)), col, 2.0, true)
		y += 11


func _box(at: Vector2, s: String, px: int) -> Rect2:
	var sz: Vector2 = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px)
	return Rect2(Vector2(at.x, at.y - font().get_ascent(px)), sz)


func _text(at: Vector2, s: String, px: int, col: Color, outline: bool = false) -> void:
	if s.is_empty():
		return
	if outline:
		draw_string_outline(font(), at, s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 6, StoneStoryPalette.ink(pal))
	draw_string(font(), at, s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)
	layout_boxes.append({"text": s, "rect": _box(at, s, px)})


func _text_right(right_x: float, y: float, s: String, px: int, col: Color) -> void:
	if s.is_empty():
		return
	var w: float = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	_text(Vector2(right_x - w, y), s, px, col)


static var _font_res: SystemFont = null


static func font() -> Font:
	if _font_res == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Malgun Gothic", "Gulim", "Arial Unicode MS", "Segoe UI", "sans-serif"])
		f.font_weight = 700
		f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		_font_res = f
	return _font_res
