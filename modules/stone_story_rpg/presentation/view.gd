class_name StoneStoryView
extends Control

## 월드 + HUD 를 그린다. 상태를 읽기만 하고 판정하지 않는다.
## 순서: 하늘 -> 바닥 -> 구조물(큰 것 1개) -> 뜬 소품 -> 깊이 정렬(소품·장애물·개체) -> 근경 -> HUD

const SAFE_W: int = StoneStoryFrame.VIEW_W
const VIEW_H: int = StoneStoryFrame.VIEW_H
const HORIZON_Y: int = StoneStoryContent.SCENE_HORIZON_Y
const PX_PER_UNIT: float = 7.0
const DEPTH_PX: float = 5.0
const STAGE_X: float = 480.0
const STAGE_Y: float = 432.0
const FS_HUD: int = 18
const FS_SMALL: int = 16
const FS_NAME: int = 20

var state: Dictionary = {}
var encounter: Dictionary = {}
var region: Dictionary = {}
var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null
var message: String = ""
var message_frames: int = 0

var pal: ProceduralPalette = null
var backdrop: StoneStoryBackdrop = null
var critters: Dictionary = {}
var _player: StoneStoryCritter = null
var _last: Dictionary = {}
var _dying: Array = []
var _player_class: Dictionary = {}
var stats: StoneStoryDrawStats = StoneStoryDrawStats.new()
var clock: float = 0.0
var hud_boxes: Array = []
var _font_res: SystemFont = null


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
	pal = StoneStoryPalette.for_region(content, region_def)
	if backdrop == null:
		backdrop = StoneStoryBackdrop.new()
	backdrop.build(str(region_def.get("id", "")), int(run_state.get("run_seed", 0)))
	critters.clear()
	_last.clear()
	_dying.clear()
	_rebuild_critters()
	queue_redraw()


func say(s: String) -> void:
	message = s
	message_frames = 90


func _sil(def: Dictionary) -> Dictionary:
	if content == null:
		return {}
	return content.get_def("silhouette", str(def.get("silhouette", "sil_lump")))


func _key(f: Dictionary) -> String:
	if bool(f.get("is_boss", false)):
		return "boss:" + str(f.get("foe_id", ""))
	return "foe:" + str(int(f.get("spawn_index", 0)))


func _make(f: Dictionary) -> StoneStoryCritter:
	var def: Dictionary = f.get("def", {})
	var seed_v: int = int(f.get("seed", 0)) + int(f.get("spawn_index", 0)) * 7919 + str(f.get("foe_id", "")).hash() % 1000
	var tags: Array = f.get("tags", [])
	return StoneStoryCritter.build(_sil(def), f.get("attributes", {}), f.get("shape", {}), absi(seed_v),
			float(f.get("scale", 1.0)), tags.has("flying"))


func _rebuild_critters() -> void:
	var live: Dictionary = {}
	for f in encounter.get("foes", []):
		var k: String = _key(f)
		if not bool(f.get("alive", true)):
			continue
		live[k] = true
		if not critters.has(k):
			critters[k] = _make(f)
	var b: Dictionary = encounter.get("boss", {})
	if not b.is_empty() and bool(b.get("alive", true)):
		var kb: String = _key(b)
		live[kb] = true
		if not critters.has(kb):
			critters[kb] = _make(b)
	for k in critters.keys():
		if not live.has(k):
			critters.erase(k)
	var p: Dictionary = state.get("player", {})
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(p, content)
	_player_class = content.get_def("class", str(p.get("class_id", ""))) if content != null else {}
	_player = StoneStoryCritter.build(_sil(_player_class), attrs, _player_class.get("shape", {}),
			int(p.get("level", 1)) * 131 + 17)


func _process(delta: float) -> void:
	clock += delta
	if backdrop != null:
		backdrop.step(delta)
	_sync_anim(delta)
	for k in critters:
		(critters[k] as StoneStoryCritter).step(delta)
	for d in _dying:
		(d["critter"] as StoneStoryCritter).step(delta)
	_dying = _dying.filter(func(d): return (d["critter"] as StoneStoryCritter).dying < 1.0)
	if _player != null:
		_player.step(delta)
	if message_frames > 0:
		message_frames -= 1
	queue_redraw()


func _all_foes() -> Array:
	var out: Array = []
	for f in encounter.get("foes", []):
		out.append(f)
	var b: Dictionary = encounter.get("boss", {})
	if not b.is_empty():
		out.append(b)
	return out


func _sync_anim(delta: float) -> void:
	if state.is_empty():
		return
	var ppos: Vector2 = _world(state["player"]["pos"])
	var nearest: Vector2 = Vector2.INF
	var present: Dictionary = {}
	for f in _all_foes():
		var k: String = _key(f)
		present[k] = true
		var alive: bool = bool(f.get("alive", true))
		var c: StoneStoryCritter = critters.get(k, null)
		if c == null and alive:
			c = _make(f)
			critters[k] = c
		if c == null:
			continue
		var at: Vector2 = _world(f["pos"])
		if not alive:
			if c.dying < 0.0:
				c.dying = 0.0
				_dying.append({"critter": c, "at": _to_px(f["pos"]), "boss": bool(f.get("is_boss", false))})
			critters.erase(k)
			continue
		var last: Dictionary = _last.get(k, {})
		var moved: bool = not last.is_empty() and (last["pos"] as Vector2).distance_to(at) > 0.01
		c.walk = move_toward(c.walk, 1.0 if moved else 0.0, delta * (6.0 if moved else 2.5))
		if not last.is_empty() and int(f.get("hp", 0)) < int(last.get("hp", 0)):
			c.hit = 1.0
		c.facing = 1.0 if ppos.x >= at.x else -1.0
		c.look = (ppos - at) * Vector2(1.0, 0.4)
		c.lean = _attack_lean(f)
		_last[k] = {"pos": at, "hp": int(f.get("hp", 0))}
		if nearest == Vector2.INF or absf(at.x - ppos.x) < absf(nearest.x - ppos.x):
			nearest = at
	for k in critters.keys():
		if not present.has(k):
			critters.erase(k)
	if _player == null:
		return
	var stance: String = str(encounter.get("player_stance", "neutral"))
	var working: bool = not encounter.get("work", []).is_empty() and _alive_count() == 0
	if nearest != Vector2.INF:
		_player.facing = 1.0 if nearest.x >= ppos.x else -1.0
		_player.look = (nearest - ppos) * Vector2(1.0, 0.4)
	elif working:
		_player.facing = -1.0
		_player.look = Vector2(-1.0, 0.3)
	var pl: Dictionary = _last.get("player", {})
	if not pl.is_empty() and int(state["player"]["hp"]) < int(pl.get("hp", 0)):
		_player.hit = 1.0
	_last["player"] = {"hp": int(state["player"]["hp"])}
	match stance:
		"guard":
			_player.lean = -0.25
		"evade":
			_player.lean = -0.5
		"superarmor":
			_player.lean = 0.35
		_:
			_player.lean = (0.45 + 0.35 * sin(clock * 5.2)) if nearest != Vector2.INF else 0.0
	if working:
		_player.lean = 0.2 + 0.5 * maxf(0.0, sin(clock * 6.0))


func _alive_count() -> int:
	var n: int = 0
	for f in _all_foes():
		if bool(f.get("alive", true)):
			n += 1
	return n


func _attack_lean(f: Dictionary) -> float:
	var def: Dictionary = f.get("def", {})
	var sd: Dictionary = def.get("states", {}).get(str(f.get("state_id", "")), {})
	if str(sd.get("on_enter", "")).is_empty():
		return 0.0
	var frames: float = maxf(1.0, float(sd.get("frames", 10)))
	var k: float = clampf(float(f.get("state_time", 0)) / frames, 0.0, 1.0)
	return sin(k * PI) * 0.9 - (0.3 if k < 0.25 else 0.0)


func _world(w: Dictionary) -> Vector2:
	return Vector2(float(w.get("x", 0)), float(w.get("y", 0)))


func _ox() -> float:
	return floorf((maxf(float(SAFE_W), size.x) - float(SAFE_W)) * 0.5)


func _to_px(w: Dictionary) -> Vector2:
	return Vector2(_ox() + STAGE_X + float(w.get("x", 0)) * PX_PER_UNIT, STAGE_Y + float(w.get("y", 0)) * DEPTH_PX)


func _depth_scale(w: Dictionary) -> float:
	return 1.0 + float(w.get("y", 0)) * 0.012


func _draw() -> void:
	var w: float = maxf(float(SAFE_W), size.x)
	var ox: float = _ox()
	stats.reset()
	stats.view_w = int(w)
	stats.view_h = VIEW_H
	stats.total_pixels = int(w) * VIEW_H
	hud_boxes.clear()
	if pal == null:
		pal = StoneStoryPalette.from_def({})
	var seed_v: int = str(region.get("id", "")).hash()
	StoneStorySky.draw(self, pal, region, w, float(HORIZON_Y), clock, stats, ox, seed_v)
	StoneStoryGround.draw(self, pal, region, w, float(HORIZON_Y), float(VIEW_H), stats, ox, seed_v)
	if state.is_empty():
		return
	var sdef: Dictionary = {}
	if content != null:
		sdef = content.get_def("structure", str(region.get("structure", "")))
	StoneStoryStructure.draw(self, sdef, pal, ox, stats, float(VIEW_H))
	var entries: Array = []
	for e in StoneStoryProps.placements(content, region):
		if StoneStoryProps.is_floating(e):
			StoneStoryProps.draw_shadow(self, e, pal, ox, clock, stats)
			StoneStoryProps.draw_one(self, e, pal, ox, clock, stats)
		else:
			entries.append({"y": float(e["y"]), "kind": "prop", "e": e})
	for o in encounter.get("obstacles", []):
		entries.append({"y": _to_px(o["pos"]).y, "kind": "obstacle", "o": o})
	for f in _all_foes():
		if not bool(f.get("alive", true)):
			continue
		var c: StoneStoryCritter = critters.get(_key(f), null)
		if c != null:
			entries.append({"y": _to_px(f["pos"]).y, "kind": "foe", "f": f, "c": c})
	for d in _dying:
		entries.append({"y": (d["at"] as Vector2).y, "kind": "dying", "d": d})
	if _player != null:
		entries.append({"y": _to_px(state["player"]["pos"]).y + 0.5, "kind": "player"})
	entries.sort_custom(func(a, b): return float(a["y"]) < float(b["y"]))
	for en in entries:
		match str(en["kind"]):
			"prop":
				StoneStoryProps.draw_shadow(self, en["e"], pal, ox, clock, stats)
				StoneStoryProps.draw_one(self, en["e"], pal, ox, clock, stats)
			"obstacle":
				_draw_obstacle(en["o"], ox)
			"foe":
				_draw_foe(en["f"], en["c"])
			"dying":
				var dd: Dictionary = en["d"]
				(dd["critter"] as StoneStoryCritter).draw(self, dd["at"], pal, stats,
						_foe_body(bool(dd["boss"])), StoneStoryPalette.accent(pal))
			"player":
				_draw_player()
	_draw_projectiles()
	var near_sway := PackedVector2Array()
	if backdrop != null:
		near_sway = backdrop.offsets(StoneStoryBackdrop.Band.NEAR)
	StoneStoryGround.draw_near(self, pal, w, float(VIEW_H), clock, stats, seed_v, near_sway)
	_draw_hud(w, ox)
	if message_frames > 0:
		_text_center(w * 0.5, 300.0, message, FS_HUD)


func _foe_body(is_boss: bool) -> Color:
	if is_boss:
		return pal.shifted(StoneStoryPalette.STRUCTURE, 0.30, 1.05)
	return StoneStoryPalette.ink(pal)


func _draw_obstacle(o: Dictionary, ox: float) -> void:
	var def: Dictionary = content.get_def("obstacle", str(o.get("obstacle_id", ""))) if content != null else {}
	var look: Dictionary = content.get_def("prop", str(def.get("look", ""))) if content != null else {}
	var at: Vector2 = _to_px(o["pos"])
	var k: float = _depth_scale(o["pos"])
	if look.is_empty():
		StoneStoryInk.fill(self, StoneStoryInk.ellipse(at + Vector2(0.0, -14.0), 12.0 * k, 16.0 * k, 12), StoneStoryPalette.role(pal, "stone"), stats)
		return
	var e: Dictionary = {"def": look, "x": at.x - ox, "y": at.y, "scale": 0.9 * k, "breaks": "", "shadow_y": -1.0}
	StoneStoryProps.draw_shadow(self, e, pal, ox, clock, stats)
	StoneStoryProps.draw_one(self, e, pal, ox, clock, stats)


func _draw_foe(f: Dictionary, c: StoneStoryCritter) -> void:
	var at: Vector2 = _to_px(f["pos"])
	var boss: bool = bool(f.get("is_boss", false))
	c.draw(self, at, pal, stats, _foe_body(boss), StoneStoryPalette.accent(pal))
	var top: Vector2 = at + Vector2(0.0, -c.hover() - c.height() * 1.02)
	if f.get("tags", []).has("ranged"):
		var orb: Vector2 = top + Vector2(sin(clock * 2.0) * 4.0, -8.0)
		StoneStoryInk.disc(self, orb, 4.0, StoneStoryPalette.accent(pal), stats)
		StoneStoryInk.disc(self, orb + Vector2(-1.2, -1.2), 1.4, StoneStoryPalette.sclera(pal), stats)
	if bool(f.get("staggered", false)):
		for i in 3:
			var a: float = clock * 4.0 + TAU * float(i) / 3.0
			StoneStoryInk.disc(self, top + Vector2(cos(a) * 12.0, sin(a) * 4.0 - 6.0), 2.4, StoneStoryPalette.sclera(pal), stats)
	_draw_status(top, f.get("status_build", {}))
	if boss:
		_draw_boss_bar(f, top)


func _draw_status(top: Vector2, build_v: Dictionary) -> void:
	var col: Color = StoneStoryPalette.sclera(pal)
	var edge: Color = StoneStoryPalette.ink(pal)
	var x: float = top.x - 14.0
	for k in ["bleed", "poison", "frost"]:
		var v: float = float(build_v.get(k, 0.0))
		if v <= 0.0:
			continue
		var n: int = clampi(1 + int(ceil(v / 25.0)), 1, 4)
		for i in n:
			var p: Vector2 = Vector2(x, top.y - 14.0 - float(i) * 7.0)
			match k:
				"bleed":
					StoneStoryInk.fill(self, PackedVector2Array([p + Vector2(0, -4), p + Vector2(3, 1), p + Vector2(0, 3), p + Vector2(-3, 1)]), edge, stats)
				"poison":
					StoneStoryInk.disc(self, p, 3.0, edge, stats)
					StoneStoryInk.disc(self, p + Vector2(-0.8, -0.8), 1.1, col, stats)
				_:
					StoneStoryInk.fill(self, PackedVector2Array([p + Vector2(0, -4), p + Vector2(2, 0), p + Vector2(0, 4), p + Vector2(-2, 0)]), col, stats)
		x += 14.0


func _draw_boss_bar(b: Dictionary, top: Vector2) -> void:
	var wd: float = 150.0
	var y: float = top.y - 22.0
	var ratio: float = clampf(float(b.get("hp", 0)) / maxf(1.0, float(b.get("hp_max", 1))), 0.0, 1.0)
	var track := Rect2(top.x - wd * 0.5, y, wd, 8.0)
	draw_rect(track, StoneStoryPalette.ink(pal))
	draw_rect(Rect2(track.position + Vector2(2.0, 2.0), Vector2((wd - 4.0) * ratio, 4.0)), StoneStoryPalette.sclera(pal))
	stats.note_rect(Rect2i(track), StoneStoryPalette.ink(pal), true)


func _draw_player() -> void:
	var p: Dictionary = state["player"]
	var at: Vector2 = _to_px(p["pos"])
	var stance: String = str(encounter.get("player_stance", "neutral"))
	var body_col: Color = StoneStoryPalette.accent(pal)
	var mark_col: Color = StoneStoryPalette.sclera(pal)
	if stance == "superarmor":
		var ring: Color = StoneStoryPalette.accent(pal)
		ring.a = 0.22 + 0.10 * sin(clock * 6.0)
		StoneStoryInk.fill(self, StoneStoryInk.ellipse(at, _player.width() * 1.1, _player.width() * 0.32, 22), ring, stats)
	_player.draw(self, at, pal, stats, body_col, mark_col)
	var looks: Array = []
	for g in p.get("gear", []):
		var def: Dictionary = content.item(str((g as Dictionary).get("item_id", ""))) if content != null else {}
		var lk: String = str(def.get("look", ""))
		if not lk.is_empty() and not looks.has(lk):
			looks.append(lk)
	StoneStoryCritter.draw_gear(self, _player, at, looks, stance, pal, stats)
	var smax: float = maxf(1.0, float(p.get("stamina_max", 1)))
	var ratio: float = clampf(float(p.get("stamina", 0)) / smax, 0.0, 1.0)
	var bw: float = 44.0
	var bar := Rect2(at.x - bw * 0.5, at.y + 10.0, bw, 5.0)
	draw_rect(bar, StoneStoryPalette.ink(pal))
	draw_rect(Rect2(bar.position + Vector2(1.0, 1.0), Vector2((bw - 2.0) * ratio, 3.0)), StoneStoryPalette.sclera(pal))
	_draw_work(at)


func _draw_work(at: Vector2) -> void:
	var work: Array = encounter.get("work", [])
	if work.is_empty() or _alive_count() > 0:
		return
	var job: Dictionary = work[0]
	var total: float = maxf(1.0, float(job.get("ticks_total", 1)))
	var done: float = clampf(1.0 - float(job.get("ticks_left", 0)) / total, 0.0, 1.0)
	var center: Vector2 = at + Vector2(-36.0, -_player.height() - 24.0)
	var n: int = 12
	for i in n:
		var a: float = -PI * 0.5 + TAU * float(i) / float(n)
		var on: bool = float(i) / float(n) < done
		StoneStoryInk.disc(self, center + Vector2(cos(a), sin(a)) * 10.0, 2.6 if on else 1.6,
				StoneStoryPalette.sclera(pal) if on else StoneStoryPalette.ink(pal), stats)


func _draw_projectiles() -> void:
	for pj in encounter.get("projectiles", []):
		var at: Vector2 = _to_px(pj["pos"]) + Vector2(0.0, -26.0)
		StoneStoryInk.disc(self, at, 5.0, StoneStoryPalette.accent(pal), stats)
		StoneStoryInk.disc(self, at + Vector2(-1.5, -1.5), 2.0, StoneStoryPalette.sclera(pal), stats)


func _draw_hud(w: float, ox: float) -> void:
	var p: Dictionary = state["player"]
	var wd: Dictionary = state.get("world", {})
	var coin := Vector2(ox + 28.0, 30.0)
	StoneStoryInk.disc(self, coin, 9.0, StoneStoryPalette.ink(pal), stats)
	StoneStoryInk.disc(self, coin, 7.0, StoneStoryPalette.accent(pal), stats)
	StoneStoryInk.disc(self, coin + Vector2(-2.0, -2.0), 2.4, StoneStoryPalette.sclera(pal), stats)
	_text(Vector2(ox + 44.0, 37.0), str(int(wd.get("currency", 0))), FS_HUD)
	_text_center(w * 0.5, 38.0, str(region.get("name", "")), FS_NAME)
	var star_at := Vector2(ox + float(SAFE_W) - 70.0, 30.0)
	_star(star_at, 10.0)
	_text(Vector2(star_at.x + 16.0, 37.0), str(int(state.get("star_level", 1))), FS_HUD)
	var hp: float = float(p.get("hp", 0))
	var hpm: float = maxf(1.0, float(p.get("hp_max", 1)))
	var bar := Rect2(ox + 24.0, float(VIEW_H) - 40.0, 180.0, 14.0)
	draw_rect(bar, StoneStoryPalette.ink(pal))
	draw_rect(Rect2(bar.position + Vector2(3.0, 3.0), Vector2((bar.size.x - 6.0) * clampf(hp / hpm, 0.0, 1.0), 8.0)), StoneStoryPalette.sclera(pal))
	stats.note_rect(Rect2i(bar), StoneStoryPalette.ink(pal), true)
	_text(Vector2(bar.end.x + 12.0, bar.end.y + 1.0), "%d/%d" % [int(hp), int(hpm)], FS_SMALL)
	var names: Array[String] = []
	for g in p.get("gear", []):
		var def: Dictionary = content.item(str((g as Dictionary).get("item_id", ""))) if content != null else {}
		names.append(str(def.get("name", "")))
	if not names.is_empty():
		_text_right(ox + float(SAFE_W) - 24.0, float(VIEW_H) - 26.0, _fit(" · ".join(names), 420, FS_SMALL), FS_SMALL)


func _star(c: Vector2, r: float) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a: float = -PI * 0.5 + TAU * float(i) / 10.0
		var rr: float = r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	var outer := PackedVector2Array()
	for q in pts:
		outer.append(c + (q - c) * 1.28)
	StoneStoryInk.fill(self, outer, StoneStoryPalette.ink(pal), stats)
	StoneStoryInk.fill(self, pts, StoneStoryPalette.accent(pal), stats)


func font() -> Font:
	if _font_res == null:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Malgun Gothic", "Gulim", "Arial Unicode MS", "Segoe UI", "sans-serif"])
		f.font_weight = 700
		f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		_font_res = f
	return _font_res


func _fit(s: String, max_w: int, px: int) -> String:
	if font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= float(max_w):
		return s
	var out: String = s
	while out.length() > 1 and font().get_string_size(out + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > float(max_w):
		out = out.substr(0, out.length() - 1)
	return out + "…"


func _box(at: Vector2, s: String, px: int) -> Rect2:
	var sz: Vector2 = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px)
	var asc: float = font().get_ascent(px)
	return Rect2(Vector2(at.x, at.y - asc), Vector2(sz.x, sz.y))


func _text(at: Vector2, s: String, px: int) -> void:
	if s.is_empty():
		return
	draw_string_outline(font(), at, s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 5, StoneStoryPalette.ink(pal))
	draw_string(font(), at, s, HORIZONTAL_ALIGNMENT_LEFT, -1, px, StoneStoryPalette.text(pal))
	hud_boxes.append({"text": s, "rect": _box(at, s, px)})


func _text_right(right_x: float, y: float, s: String, px: int) -> void:
	if s.is_empty():
		return
	var wd: float = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	_text(Vector2(right_x - wd, y), s, px)


func _text_center(cx: float, y: float, s: String, px: int) -> void:
	if s.is_empty():
		return
	var wd: float = font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	_text(Vector2(cx - wd * 0.5, y), s, px)
