class_name StoneStoryView
extends Control

## 월드 + HUD 를 그린다. 상태를 읽기만 하고 판정하지 않는다.
## 형체는 PVE 정규 형상의 points 를 읽어 선으로 잇는다.

const VIEW_W: int = StoneStoryFrame.VIEW_W
const VIEW_H: int = StoneStoryFrame.VIEW_H
const PX_PER_UNIT: float = 3.0
## 형체 스케일. 정규 형상은 월드 단위이므로 그릴 때 키운다.
const FORM_SCALE: float = 2.6
const CENTER := Vector2(480.0, 300.0)
## 지평선. 화면 높이의 38%. (계약 §4.1)
const HORIZON_Y: int = 243
const FONT_SIZES: Array[int] = [8, 10, 12, 14]

var state: Dictionary = {}
var encounter: Dictionary = {}
var region: Dictionary = {}
var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null
var message: String = ""
var message_frames: int = 0

var pal: ProceduralPalette = null
var backdrop: StoneStoryBackdrop = null
var critters: Dictionary = {}          # foe_id -> StoneStoryCritter
var _player: StoneStoryCritter = null
var _font_res: SystemFont = null
var _font_checked: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind(run_state: Dictionary, enc: Dictionary, region_def: Dictionary,
		content_ref: StoneStoryContent, tuning_ref: StoneStoryTuning) -> void:
	state = run_state
	encounter = enc
	region = region_def
	content = content_ref
	tuning = tuning_ref
	if pal == null:
		pal = StoneStoryPalette.build(str(region_def.get("id", "")), int(run_state.get("run_seed", 0)))
	if backdrop == null:
		backdrop = StoneStoryBackdrop.new()
	backdrop.build(str(region_def.get("id", "")), int(run_state.get("run_seed", 0)))
	_rebuild_critters()
	queue_redraw()


func say(s: String) -> void:
	message = s
	message_frames = 90


func _rebuild_critters() -> void:
	critters.clear()
	var live: Dictionary = {}
	for f in encounter.get("foes", []):
		live[str(f["foe_id"])] = true
		if critters.has(str(f["foe_id"])):
			continue
		critters[str(f["foe_id"])] = StoneStoryCritter.build(
				str(f["foe_id"]), f.get("attributes", {}), f.get("shape", {}), int(f.get("seed", 0)))
	var b: Dictionary = encounter.get("boss", {})
	if not b.is_empty():
		live[str(b["foe_id"])] = true
		if not critters.has(str(b["foe_id"])):
			critters[str(b["foe_id"])] = StoneStoryCritter.build(
					str(b["foe_id"]), b.get("attributes", {}), b.get("shape", {}), int(b.get("seed", 0)))
	for k in critters.keys():
		if not live.has(k):
			critters.erase(k)
	var p: Dictionary = state.get("player", {})
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(p, content)
	_player = StoneStoryCritter.build("player", attrs, {"motion_events": 4}, int(p.get("level", 1)))





func _process(delta: float) -> void:
	if backdrop != null:
		backdrop.step(delta)
		var cam: Vector2 = _player_world() if _player != null else Vector2.ZERO
		backdrop.set_view_offset(-cam * 0.4)
	for k in critters:
		critters[k].step(delta)
	if _player != null:
		_player.step(delta)
	if message_frames > 0:
		message_frames -= 1
	queue_redraw()


func _player_world() -> Vector2:
	return Vector2(float(state["player"]["pos"]["x"]), float(state["player"]["pos"]["y"]))


func _to_px(w: Dictionary) -> Vector2:
	return Vector2(CENTER.x + float(w["x"]) * PX_PER_UNIT, CENTER.y + float(w["y"]) * PX_PER_UNIT * 0.6)


func _draw() -> void:
	draw_rect(Rect2i(0, 0, VIEW_W, VIEW_H), StoneStoryPalette.fill(pal))
	if state.is_empty():
		_text_center(VIEW_W / 2, VIEW_H / 2, "빈 화면", 14, StoneStoryPalette.text_dim(pal))
		return
	_draw_background()
	_draw_space()
	_draw_obstacles()
	_draw_foes()
	_draw_player()
	_draw_hud()
	if message_frames > 0:
		_text_center(VIEW_W / 2, 300, message, 12, StoneStoryPalette.text(pal))


func _draw_background() -> void:
	if backdrop == null:
		return
	for b in StoneStoryBackdrop.draw_order():
		var pts: PackedVector2Array = backdrop.draw_points(b)
		var col: Color = StoneStoryPalette.sky_far(pal)
		var r: float = 1.0 + float(b) * 0.5
		for i in pts.size():
			if i % 3 != 0:
				continue
			draw_circle(pts[i] * 0.5 + CENTER * 0.5, r, col, false, 1.0, true)


## 공간 (2026-09-26 개정). 1차 판은 검정 배경 + 헤어라인이었다. 폐기.
## 하늘/천장 + 지평선 + 바닥 + 구조물. 면으로 채운다. (계약 §4.1, §4.2)
func _draw_space() -> void:
	var s := StoneStoryCore.stream(int(state.get("run_seed", 0)),
			StoneStoryCore.TAG_TEXTURE + ".space")
	var horizon: float = float(HORIZON_Y)

	# 1) 하늘: 위에서 지평선으로 내려가는 3단 그라데이션 면.
	var bands: int = 12
	for i in bands:
		var t0: float = float(i) / float(bands)
		var y0: float = horizon * t0
		var y1: float = horizon * (float(i + 1) / float(bands)) + 1.0
		var col: Color = StoneStoryPalette.sky_far(pal).lerp(StoneStoryPalette.sky_near(pal), t0)
		draw_rect(Rect2i(0, int(y0), VIEW_W, int(y1 - y0) + 1), col)

	# 2) 구름/태양. Ena 씬에는 하늘에 형태가 있다.
	var sun_at := Vector2(VIEW_W * 0.72, horizon * 0.34)
	draw_circle(sun_at, 26.0, StoneStoryPalette.sky_far(pal).lightened(0.25))
	for i in 7:
		var cx: float = 40.0 + s.unit(i) * (VIEW_W - 80.0)
		var cy: float = 24.0 + s.unit(i + 50) * (horizon * 0.55)
		var cw: float = 26.0 + s.unit(i + 90) * 34.0
		_cloud(Vector2(cx, cy), cw, StoneStoryPalette.sky_near(pal).lightened(0.35))

	# 3) 지평선 아래 = 바닥. 근경으로 갈수록 밝고 포화.
	var g_bands: int = 6
	for i in g_bands:
		var t0: float = float(i) / float(g_bands)
		var y0: float = horizon + (VIEW_H - horizon) * t0
		var y1: float = horizon + (VIEW_H - horizon) * (float(i + 1) / float(g_bands)) + 1.0
		var gc: Color = StoneStoryPalette.ground(pal).lerp(
				StoneStoryPalette.ground(pal).darkened(0.35), 1.0 - t0)
		draw_rect(Rect2i(0, int(y0), VIEW_W, int(y1 - y0) + 1), gc)

	# 4) 바닥 결: 면 위에 얹는 얇은 띠. 선이 아니라 면이다.
	for bi in 3:
		var sp: float = [64.0, 40.0, 24.0][bi]
		var y: float = horizon + 40.0 + bi * 54.0
		var shade: Color = StoneStoryPalette.ground(pal).darkened(0.18 + 0.10 * float(bi))
		var k: int = 0
		var x: float = -fposmod(_player_world().x * PX_PER_UNIT * 0.22, sp) - sp
		while x < VIEW_W + sp:
			var w: float = sp * (0.25 + s.unit(bi * 97 + k) * 0.5)
			draw_rect(Rect2i(int(x), int(y), maxi(2, int(w)), 3), shade)
			x += sp * (0.6 + s.unit(bi * 31 + k) * 0.8)
			k += 1

	# 5) 원경 구조물. 화면 높이의 25%+ (V7 큰 것).
	_draw_far_structure(s, horizon)


## 구름은 3개 원의 합. 채워진 면.
func _cloud(at: Vector2, w: float, col: Color) -> void:
	draw_circle(at, w * 0.5, col)
	draw_circle(at + Vector2(w * 0.45, w * 0.10), w * 0.36, col)
	draw_circle(at - Vector2(w * 0.42, w * 0.12), w * 0.32, col)
	draw_rect(Rect2i(Vector2i(at) - Vector2i(int(w * 0.42), int(w * 0.12)), Vector2i(int(w * 0.84), int(w * 0.16))), col)


## 큰 것 1개. 지오메트리 규칙(R9~R12)에서 나온다. content 가 명시한다.
func _draw_far_structure(s: StoneStoryRng, horizon: float) -> void:
	var def: Dictionary = content.get_def("region", str(region.get("id", ""))) if content != null else {}
	var tag: String = str(def.get("structure", "dome"))
	var cx: float = VIEW_W * 0.30
	var base_y: float = horizon
	var col: Color = StoneStoryPalette.structure(pal)
	var lit: Color = col.lightened(0.18)
	match tag:
		"dome":
			# 돔 립. 어두운 선이 아니라 채워진 면.
			var r: float = 300.0
			for i in 9:
				var t: float = float(i) / 8.0
				var rr: float = r * lerpf(1.0, 0.55, t)
				draw_rect(Rect2i(int(cx - rr), int(base_y - rr * 0.72), int(rr * 2.0), int(rr * 0.72)), col.darkened(t * 0.5))
			draw_rect(Rect2i(int(cx - r), int(base_y - 14), int(r * 2.0), 14), col)
			for i in 7:
				var rx: float = cx - r + float(i) * (r * 2.0 / 6.0)
				draw_rect(Rect2i(int(rx), int(base_y - r * 0.70), 3, int(r * 0.70)), lit)
		"canyon":
			draw_rect(Rect2i(0, int(horizon - 190), int(cx - 30.0), 190), col)
			draw_rect(Rect2i(int(cx + 30.0), int(horizon - 150), VIEW_W - int(cx + 30.0), 150), col.darkened(0.18))
			draw_rect(Rect2i(int(cx - 30.0), int(horizon - 190), 30, 190), col.lightened(0.10))
			draw_rect(Rect2i(int(cx), int(horizon - 150), 30, 150), col.lightened(0.10))
		"arch":
			var aw: float = 150.0
			draw_rect(Rect2i(int(cx - aw), int(horizon - 170), 34, 170), col)
			draw_rect(Rect2i(int(cx + aw - 34), int(horizon - 170), 34, 170), col)
			draw_rect(Rect2i(int(cx - aw), int(horizon - 186), int(aw * 2.0), 22), col.lightened(0.12))
		_:
			draw_rect(Rect2i(int(cx - 120), int(horizon - 120), 240, 120), col)


func _draw_obstacles() -> void:
	for o in encounter.get("obstacles", []):
		var at: Vector2 = _to_px(o["pos"])
		var r := Rect2i(Vector2i(at) - Vector2i(10, 20), Vector2i(20, 40))
		if str(o.get("kind", "")) == "rubble":
			_dashed_rect(r, StoneStoryPalette.line_dim(pal))
		else:
			draw_rect(r, StoneStoryPalette.line(pal), false, 1.0)


func _draw_foes() -> void:
	for f in encounter.get("foes", []):
		if not bool(f["alive"]):
			continue
		_draw_critter(f, critters.get(str(f["foe_id"]), null))
	var b: Dictionary = encounter.get("boss", {})
	if not b.is_empty() and bool(b.get("alive", true)):
		_draw_critter(b, critters.get(str(b["foe_id"]), null))
		_draw_boss_bar(b)


func _draw_critter(f: Dictionary, c: StoneStoryCritter) -> void:
	var at: Vector2 = _to_px(f["pos"])
	if c == null:
		draw_circle(at, 16.0, StoneStoryPalette.line(pal), false, 1.0, true)
		return
	var bob: float = c.bob_offset()
	var pts: PackedVector2Array = c.points()
	var rad: PackedFloat32Array = c.radii()
	if pts.is_empty():
		return
	var col: Color = StoneStoryPalette.line(pal)
	var dim: Color = StoneStoryPalette.line_dim(pal)
	var S: float = FORM_SCALE
	var origin: Vector2 = Vector2(at.x, at.y + 14.0)

	# 0) 몸통: 연결된 윤곽으로 닫는다. 채움 금지.
	var body_anchor: Vector2 = origin
	for i in pts.size():
		if c.part_role(i) != &"body":
			continue
		var p: Vector2 = origin + pts[i] * S + Vector2(0, bob)
		draw_circle(p, maxf(2.0, float(rad[i]) * S), col, false, 1.0, true)
		if i > 0:
			draw_line(origin + pts[i - 1] * S + Vector2(0, bob), p, col, 1.0, true)
		body_anchor = p

	# 1) 머리: 링. 틀림이 높을수록 축에서 벗어나 있다.
	for i in pts.size():
		if c.part_role(i) != &"head":
			continue
		var hp: Vector2 = origin + pts[i] * S + Vector2(0, bob)
		draw_line(body_anchor, hp, col, 1.0, true)
		draw_ring(hp, maxf(3.0, float(rad[i]) * S), col)

	# 2) 꼬리: 몸에서 뻗는 선. 끝이 가늘다.
	for i in pts.size():
		if c.part_role(i) != &"tail":
			continue
		var tp: Vector2 = origin + pts[i] * S + Vector2(0, bob)
		draw_line(body_anchor, tp, dim, 1.0, true)

	# 3) 다리: 몸 축에서 바깥으로. 어긋난 각도가 그대로 보인다.
	for i in pts.size():
		if c.part_role(i) != &"limb":
			continue
		var t: float = c.body_axis(i)
		var root: Vector2 = origin + pts[0] * S + (pts[maxi(0, pts.size() - 1)] - pts[0]) * S * t
		var tip: Vector2 = origin + pts[i] * S + Vector2(0, bob)
		draw_line(root, tip, col, 1.0, true)
		draw_circle(tip, maxf(1.0, float(rad[i]) * S * 0.9), col, false, 1.0, true)

	if f["tags"].has("ranged"):
		draw_ring(Vector2(at.x, at.y - c.extent_y() * S * 0.5 - 6.0), 3.0, dim)
	if bool(f.get("staggered", false)):
		_text_center(at.x, at.y - c.extent_y() * S - 16.0, "*", 12, StoneStoryPalette.text(pal))
	_draw_status(at, f.get("status_build", {}), c.extent_y() * S)


## 12분할 링. 1px 고정.
func draw_ring(center: Vector2, r: float, col: Color) -> void:
	if r <= 0.5:
		draw_rect(Rect2i(Vector2i(center) - Vector2i.ONE, Vector2i(3, 3)), col)
		return
	var pts := PackedVector2Array()
	for i in 13:
		var a: float = TAU * float(i) / 12.0
		pts.append(center + Vector2(cos(a) * r, sin(a) * r))
	draw_polyline(pts, col, 1.0)


func _draw_status(at: Vector2, build_v: Dictionary, h: float) -> void:
	var y: float = at.y - h - 6.0
	for k in ["bleed", "poison", "frost"]:
		var v: float = float(build_v.get(k, 0.0))
		if v <= 0.0:
			continue
		var n: int = 1 + int(ceil(v / 25.0))
		for i in n:
			draw_line(Vector2(at.x - 6.0 + i * 3.0, y), Vector2(at.x - 6.0 + i * 3.0, y - 3.0),
					StoneStoryPalette.alert(pal), 1.0, true)


func _draw_player() -> void:
	if _player == null:
		return
	var p: Dictionary = state["player"]
	var at: Vector2 = _to_px(p["pos"])
	var pts: PackedVector2Array = _player.points()
	var rad: PackedFloat32Array = _player.radii()
	var col: Color = StoneStoryPalette.text(pal)
	var origin: Vector2 = Vector2(at.x, at.y + 18.0)
	# 스탠스 링. 가드면 두 겹.
	var stance: String = str(encounter.get("player_stance", "neutral"))
	draw_ring(origin, 26.0, StoneStoryPalette.line_dim(pal))
	if stance == "guard":
		draw_ring(origin, 30.0, StoneStoryPalette.accent(pal))
	elif stance == "superarmor":
		_dashed_circle(origin, 30.0, StoneStoryPalette.line_dim(pal))
	for i in pts.size():
		var role: StringName = _player.part_role(i)
		var q: Vector2 = origin + pts[i] * FORM_SCALE
		var r: float = maxf(1.0, float(rad[i]) * FORM_SCALE)
		if role == &"body":
			draw_circle(q, r, col, false, 1.0, true)
		elif role == &"head":
			draw_ring(q, maxf(3.0, r), col)
		elif role == &"tail":
			draw_line(origin + pts[0] * FORM_SCALE, q, col, 1.0, true)
		else:
			var t: float = _player.body_axis(i)
			var root: Vector2 = origin + pts[0] * FORM_SCALE \
					+ (pts[pts.size() - 1] - pts[0]) * FORM_SCALE * t
			draw_line(root, q, col, 1.0, true)
			draw_circle(q, r * 0.9, col, false, 1.0, true)
	# 기력
	var smax: int = maxi(1, int(p["stamina_max"]))
	var fill_n: int = int(float(p["stamina"]) / float(smax) * 24.0)
	for i in fill_n:
		draw_line(Vector2(at.x - 12.0 + i, at.y + 22.0), Vector2(at.x - 11.0 + i, at.y + 22.0),
				StoneStoryPalette.line_dim(pal), 1.0, true)
	for pj in encounter.get("projectiles", []):
		draw_rect(Rect2i(Vector2i(_to_px(pj["pos"])), Vector2i(2, 2)), StoneStoryPalette.accent(pal))


func _dashed_circle(center: Vector2, r: float, col: Color) -> void:
	for i in 12:
		if i % 2 == 1:
			continue
		var a0: float = TAU * float(i) / 12.0
		var a1: float = TAU * float(i + 1) / 12.0
		draw_line(center + Vector2(cos(a0), sin(a0)) * r,
				center + Vector2(cos(a1), sin(a1)) * r, col, 1.0, true)


func _draw_boss_bar(b: Dictionary) -> void:
	var at: Vector2 = _to_px(b["pos"])
	var w: float = 160.0
	var y: float = at.y - 70.0
	var ratio: float = float(b["hp"]) / maxf(1.0, float(b["hp_max"]))
	draw_line(Vector2(at.x - w * 0.5, y), Vector2(at.x + w * 0.5, y),
			StoneStoryPalette.line_dim(pal), 1.0, true)
	draw_line(Vector2(at.x - w * 0.5, y), Vector2(at.x - w * 0.5 + w * ratio, y),
			StoneStoryPalette.line(pal), 1.0, true)


func _draw_hud() -> void:
	var p: Dictionary = state["player"]
	var w: Dictionary = state["world"]
	_text(Vector2(12, 20), str(int(w.get("currency", 0))), 12)
	_text_center(VIEW_W * 0.5, 20, str(region.get("name", "")), 12)
	_text_right(VIEW_W - 12, 20, "*" + str(int(state.get("star_level", 1))), 12)
	_text(Vector2(12, VIEW_H - 12), str(int(p["hp"])) + "/" + str(int(p["hp_max"])), 12)
	# 로비가 유일한 조작면. 현재 장비 = 현재 정책.
	var ids: Array[String] = []
	for g in p.get("gear", []):
		var it: String = str((g as Dictionary).get("item_id", ""))
		var def: Dictionary = content.item(it) if content != null else {}
		ids.append(str(def.get("name", it)))
	if not ids.is_empty():
		_text_right(VIEW_W - 12, VIEW_H - 28, "  ".join(ids), 10)


func _dashed_rect(r: Rect2i, col: Color) -> void:
	var x: int = r.position.x
	var y: int = r.position.y
	var x2: int = r.position.x + r.size.x
	var y2: int = r.position.y + r.size.y
	var d: int = 0
	while x < x2:
		draw_line(Vector2(x, y), Vector2(mini(x + 3, x2), y), col, 1.0)
		d += 1
		x += 6
	x = r.position.x
	while x < x2:
		draw_line(Vector2(x, y2), Vector2(mini(x + 3, x2), y2), col, 1.0)
		x += 6
	while y < y2:
		draw_line(Vector2(x, y), Vector2(x, mini(y + 3, y2)), col, 1.0)
		y += 6
	y = r.position.y
	while y < y2:
		draw_line(Vector2(x2, y), Vector2(x2, mini(y + 3, y2)), col, 1.0)
		y += 6


func font() -> Font:
	if _font_res == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Malgun Gothic", "Gulim", "Arial Unicode MS", "Segoe UI", "sans-serif"])
		f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		_font_res = f
	return _font_res


func _text(at: Vector2, s: String, px: int) -> void:
	if s.is_empty():
		return
	draw_string(font(), Vector2i(at), s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, StoneStoryPalette.text(pal))


func _text_right(right_x: int, y: int, s: String, px: int) -> void:
	if s.is_empty():
		return
	var w: int = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	draw_string(font(), Vector2i(right_x - w, y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, StoneStoryPalette.text(pal))


func _text_center(cx: float, y: float, s: String, px: int, col: Color = Color(1, 1, 1)) -> void:
	if s.is_empty():
		return
	var w: int = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	draw_string(font(), Vector2i(int(cx) - w / 2, int(y)), s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)
