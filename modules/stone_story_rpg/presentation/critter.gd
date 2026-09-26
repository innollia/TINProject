class_name StoneStoryCritter
extends RefCounted

## 실루엣 3종(content/silhouette)의 좌표 폴리곤을 4속성이 변형한다. (17 §A3-a)
##   다리     -> 다리 개수
##   동그라미 -> 모서리 둥글기 (0 = 각, 10 = 원에 가까움)
##   틀림     -> 한쪽 부풂 + 기울기 + 눈 위치 이탈
##   놀랍다   -> 눈 개수 (1 + floor(놀랍다/3)) + 떨림

const K_PX: float = 1.12
const MIN_W: float = 18.0
const MIN_H: float = 18.0

var form: String = "angular"
var attrs: Dictionary = {}
var seed_value: int = 0
var size_px: Vector2 = Vector2(30.0, 40.0)
var flying: bool = false
var leg_style: String = "stilt"
var leg_count: int = 1
var eye_count: int = 1
var eye_r: float = 0.08
var body: PackedVector2Array = PackedVector2Array()
var mark: PackedVector2Array = PackedVector2Array()
var horns: Array[PackedVector2Array] = []
var eyes: PackedVector2Array = PackedVector2Array()
var eye_scale: PackedFloat32Array = PackedFloat32Array()
var stalks: PackedVector2Array = PackedVector2Array()
var leg_root: PackedVector2Array = PackedVector2Array()
var leg_knee: PackedVector2Array = PackedVector2Array()
var leg_tip: PackedVector2Array = PackedVector2Array()
var leg_phase: PackedFloat32Array = PackedFloat32Array()
var noise: ProceduralNoiseField = null

var t: float = 0.0
var walk: float = 0.0
var lean: float = 0.0
var hit: float = 0.0
var facing: float = 1.0
var look: Vector2 = Vector2.ZERO
var dying: float = -1.0
var blink_every: float = 3.0
var blink_at: float = 0.0


static func build(sil: Dictionary, attributes: Dictionary, shape: Dictionary, seed_in: int,
		scale_mult: float = 1.0, is_flying: bool = false) -> StoneStoryCritter:
	var c := StoneStoryCritter.new()
	c.attrs = attributes.duplicate()
	c.seed_value = seed_in
	c.flying = is_flying
	c.form = str(sil.get("form", "angular"))
	var w: float = maxf(MIN_W, float(shape.get("width_units", 24)) * K_PX * scale_mult)
	var h: float = maxf(MIN_H, float(shape.get("height_units", 30)) * K_PX * scale_mult)
	c.size_px = Vector2(w, h)
	c.noise = Procedural.make_noise(Procedural.derive_seed(seed_in, "critter.wobble"), ProceduralNoiseField.FIELD_SHAPE)
	var s: StoneStoryRng = StoneStoryCore.stream(seed_in, StoneStoryCore.TAG_TEXTURE + ".critter")
	c.blink_every = 2.2 + s.unit(7) * 3.4
	c.blink_at = s.unit(8) * c.blink_every
	c._shape_from(sil, s)
	return c


func _r() -> float:
	return clampf(float(attrs.get(StoneStoryAttributes.ROUND, 0.0)) / 10.0, 0.0, 1.0)


func _w() -> float:
	return clampf(float(attrs.get(StoneStoryAttributes.WRONGNESS, 0.0)) / 10.0, 0.0, 1.0)


func _warp(p: Vector2) -> Vector2:
	var w: float = _w()
	var q: Vector2 = p
	if q.x > 0.0:
		q.x *= 1.0 + 0.34 * w
		q.y *= 1.0 + 0.08 * w
	else:
		q.x *= 1.0 - 0.10 * w
	q.x += -q.y * 0.20 * w
	return q


func _round_poly(pts: PackedVector2Array, r: float) -> PackedVector2Array:
	var iters: int = 0
	if r >= 0.15:
		iters = 1
	if r >= 0.45:
		iters = 2
	if r >= 0.80:
		iters = 3
	var out: PackedVector2Array = StoneStoryInk.chaikin(pts, iters, 0.25) if iters > 0 else pts
	if r <= 0.0:
		return out
	var bb: Rect2 = StoneStoryInk.bounds(out)
	var ctr: Vector2 = bb.get_center()
	var rad: Vector2 = bb.size * 0.5
	var blended := PackedVector2Array()
	for p in out:
		var d: Vector2 = p - ctr
		var a: float = atan2(d.y / maxf(0.001, rad.y), d.x / maxf(0.001, rad.x))
		var e: Vector2 = ctr + Vector2(cos(a) * rad.x, sin(a) * rad.y)
		blended.append(p.lerp(e, r * 0.45))
	return blended


func _shape_from(sil: Dictionary, s: StoneStoryRng) -> void:
	var r: float = _r()
	var w: float = _w()
	var raw := StoneStoryInk.to_points(sil.get("body", []))
	if raw.size() < 3:
		raw = StoneStoryInk.ellipse(Vector2(0.0, -0.5), 0.5, 0.45, 12)
	var warped := PackedVector2Array()
	for p in raw:
		warped.append(_warp(p))
	body = _round_poly(warped, r)
	var mraw := StoneStoryInk.to_points(sil.get("mark", []))
	mark = PackedVector2Array()
	for p in mraw:
		mark.append(_warp(p))
	if mark.size() >= 3:
		mark = _round_poly(mark, r * 0.6)
	horns.clear()
	for hp in sil.get("horns", []):
		var hh := PackedVector2Array()
		for p in StoneStoryInk.to_points(hp):
			hh.append(_warp(p))
		horns.append(hh)

	var ed: Dictionary = sil.get("eyes", {})
	var at: Array = ed.get("at", [0.0, -0.6])
	var spread: float = float(ed.get("spread", 0.15))
	var stalk: float = float(ed.get("stalk", 0.0))
	eye_r = float(ed.get("size", 0.08))
	var surprise: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	eye_count = clampi(1 + int(floor(surprise / 3.0)), 1, 4)
	eyes = PackedVector2Array()
	eye_scale = PackedFloat32Array()
	stalks = PackedVector2Array()
	var base_eye: Vector2 = _warp(Vector2(float(at[0]), float(at[1])))
	base_eye.x += w * 0.10
	for i in eye_count:
		var off: float = (float(i) - float(eye_count - 1) * 0.5) * spread
		var e: Vector2 = base_eye + Vector2(off, -absf(off) * 0.25)
		if w > 0.0 and i == eye_count - 1:
			e.y += w * 0.06
		var root: Vector2 = e
		if stalk > 0.0:
			e.y -= stalk
		eyes.append(e)
		stalks.append(root)
		var big: float = 1.0
		if eye_count > 1:
			big = 0.85 + 0.3 * s.unit(20 + i)
		if w > 0.4 and i == 0:
			big *= 1.0 + 0.5 * w
		eye_scale.append(big)

	var ld: Dictionary = sil.get("limbs", {})
	leg_style = str(ld.get("style", "stilt"))
	leg_count = StoneStoryAttributes.clamp_limbs(int(attrs.get(StoneStoryAttributes.LIMBS, 1)))
	var ends: Array = ld.get("from", [[-0.2, -0.2], [0.2, -0.2]])
	var a: Vector2 = _warp(Vector2(float(ends[0][0]), float(ends[0][1])))
	var b: Vector2 = _warp(Vector2(float(ends[1][0]), float(ends[1][1])))
	var reach: float = float(ld.get("reach", 0.2))
	var knee_h: float = float(ld.get("knee", 0.1))
	var odd: int = seed_value % maxi(1, leg_count)
	leg_root = PackedVector2Array()
	leg_knee = PackedVector2Array()
	leg_tip = PackedVector2Array()
	leg_phase = PackedFloat32Array()
	for i in leg_count:
		var u: float = 0.5 if leg_count == 1 else float(i) / float(leg_count - 1)
		var root: Vector2 = a.lerp(b, u)
		var side: float = -1.0 if root.x < 0.0 else 1.0
		var long: float = 1.0 + (0.55 * w if i == odd else 0.0)
		var tip: Vector2
		var knee: Vector2
		match leg_style:
			"splay":
				tip = Vector2(root.x + side * (reach * (0.55 + 0.9 * absf(root.x)) * long), 0.0)
				knee = Vector2(root.x + (tip.x - root.x) * 0.42, root.y - knee_h * long)
			"stub":
				tip = Vector2(root.x * 1.12, 0.0)
				knee = Vector2(root.x * 1.08, root.y + (tip.y - root.y) * 0.5 - knee_h)
			_:
				tip = Vector2(root.x * 1.05 + side * reach * 0.12 * long, 0.0)
				knee = Vector2(root.x + side * reach * 0.30 * long, root.y + (0.0 - root.y) * 0.45)
		leg_root.append(root)
		leg_knee.append(knee)
		leg_tip.append(tip)
		leg_phase.append(float(i % 2) * PI + float(i) * 0.37)


func step(delta: float) -> void:
	t += delta
	hit = maxf(0.0, hit - delta * 3.2)
	if dying >= 0.0:
		dying = minf(1.0, dying + delta * 1.6)


func blinking() -> bool:
	return fposmod(t + blink_at, blink_every) < 0.13


func height() -> float:
	return size_px.y


func width() -> float:
	return size_px.x


func hover() -> float:
	if not flying:
		return 0.0
	return size_px.y * 0.75 + sin(t * 2.3 + float(seed_value % 17)) * 4.0


func _wob(i: int) -> float:
	if noise == null:
		return 0.0
	return noise.sample(float(i) * 97.0, t * 60.0)


func pose_body(origin: Vector2) -> PackedVector2Array:
	var breath: float = sin(t * 1.7 + float(seed_value % 29) * 0.21)
	var squash: float = 1.0 - 0.10 * hit
	var sy: float = (1.0 + 0.028 * breath) * squash
	var sx: float = (1.0 - 0.014 * breath) * (2.0 - squash)
	var collapse: float = 1.0
	if dying >= 0.0:
		collapse = 1.0 - 0.82 * dying
		sx *= 1.0 + 0.35 * dying
	var shake: float = sin(t * 55.0) * hit * 3.0
	var surprise: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	var wob_amp: float = 0.9 + surprise * 0.12
	var out := PackedVector2Array()
	out.resize(body.size())
	for i in body.size():
		var p: Vector2 = body[i]
		var lean_x: float = -p.y * lean * 0.22
		var x: float = (p.x * facing + lean_x * facing) * size_px.x * sx + shake
		var y: float = p.y * size_px.y * sy * collapse
		out[i] = origin + Vector2(x, y) + Vector2(_wob(i), _wob(i + 50)) * wob_amp
	return out


func map_point(origin: Vector2, p: Vector2) -> Vector2:
	var breath: float = sin(t * 1.7 + float(seed_value % 29) * 0.21)
	var squash: float = 1.0 - 0.10 * hit
	var sy: float = (1.0 + 0.028 * breath) * squash
	var sx: float = (1.0 - 0.014 * breath) * (2.0 - squash)
	var collapse: float = 1.0
	if dying >= 0.0:
		collapse = 1.0 - 0.82 * dying
		sx *= 1.0 + 0.35 * dying
	var shake: float = sin(t * 55.0) * hit * 3.0
	var lean_x: float = -p.y * lean * 0.22
	return origin + Vector2((p.x + lean_x) * facing * size_px.x * sx + shake, p.y * size_px.y * sy * collapse)


func leg_points(origin: Vector2, i: int) -> PackedVector2Array:
	var root: Vector2 = map_point(origin, leg_root[i])
	var ph: float = leg_phase[i]
	var speed: float = 7.0 + float(leg_count) * 0.35
	var cyc: float = sin(t * speed + ph)
	var lift: float = maxf(0.0, cos(t * speed + ph))
	var stride: float = size_px.x * 0.10 * walk
	var tip_n: Vector2 = leg_tip[i]
	var knee_n: Vector2 = leg_knee[i]
	var tip: Vector2 = origin + Vector2(tip_n.x * facing * size_px.x + cyc * stride,
			-lift * size_px.y * 0.07 * walk)
	if dying >= 0.0:
		tip.y = origin.y
	var knee: Vector2 = origin + Vector2(knee_n.x * facing * size_px.x + cyc * stride * 0.5,
			knee_n.y * size_px.y - lift * size_px.y * 0.05 * walk)
	if flying:
		var dangle: float = sin(t * 3.1 + ph) * size_px.x * 0.06
		tip = root + Vector2(dangle, size_px.y * 0.34)
		knee = root.lerp(tip, 0.5) + Vector2(-dangle * 0.8, 0.0)
	return PackedVector2Array([root, knee, tip])


func leg_width() -> float:
	return clampf(size_px.y * 0.055, 1.6, 6.0)


func eye_points(origin: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	var surprise: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	for i in eyes.size():
		var p: Vector2 = map_point(origin, eyes[i])
		p += Vector2(_wob(i + 200), _wob(i + 260)) * (0.3 + surprise * 0.22)
		out.append(p)
	return out


func stalk_points(origin: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in stalks.size():
		out.append(map_point(origin, stalks[i]))
	return out


func eye_radius(i: int) -> float:
	var base: float = clampf(eye_r * size_px.y, 2.2, 11.0)
	var k: float = eye_scale[i] if i < eye_scale.size() else 1.0
	return base * k


func mark_points(origin: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in mark:
		out.append(map_point(origin, p))
	return out


func horn_points(origin: Vector2, k: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in horns[k]:
		out.append(map_point(origin, p))
	return out


func draw(ci: CanvasItem, origin: Vector2, pal: ProceduralPalette, stats: StoneStoryDrawStats,
		body_col: Color, mark_col: Color) -> void:
	var o: Vector2 = origin + Vector2(0.0, -hover())
	var shr: float = size_px.x * (0.58 if not flying else 0.34)
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(origin + Vector2(0.0, 1.0), shr, maxf(2.0, shr * 0.20), 18),
			StoneStoryPalette.shadow(pal), stats)
	var lw: float = leg_width()
	var leg_col: Color = body_col.darkened(0.22)
	for i in leg_count:
		var lp: PackedVector2Array = leg_points(o, i)
		StoneStoryInk.beam(ci, lp[0], lp[1], lw * 1.3, lw, leg_col, stats)
		StoneStoryInk.beam(ci, lp[1], lp[2], lw, lw * 0.55, leg_col, stats)
		StoneStoryInk.disc(ci, lp[1], lw * 0.55, leg_col, stats)
	var sp: PackedVector2Array = stalk_points(o)
	var ep: PackedVector2Array = eye_points(o)
	for i in sp.size():
		if sp[i].distance_to(ep[i]) > 1.5:
			StoneStoryInk.beam(ci, sp[i], ep[i], lw * 1.1, lw * 0.8, body_col, stats)
	for k in horns.size():
		StoneStoryInk.fill(ci, horn_points(o, k), body_col.darkened(0.08), stats)
	var bp: PackedVector2Array = pose_body(o)
	if not StoneStoryInk.fill(ci, bp, body_col, stats, size_px.y / 640.0):
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(o + Vector2(0.0, -size_px.y * 0.5), size_px.x * 0.5, size_px.y * 0.4, 16), body_col, stats)
	var bb: Rect2 = StoneStoryInk.bounds(bp)
	var hl_at: Vector2 = bb.position + bb.size * Vector2(0.5 - 0.18 * facing, 0.30)
	var hl := PackedVector2Array()
	for p in bp:
		hl.append(p.lerp(hl_at, 0.58))
	var hl_col: Color = body_col.lerp(StoneStoryPalette.sclera(pal), 0.16)
	StoneStoryInk.fill(ci, hl, hl_col, stats)
	if mark.size() >= 3:
		StoneStoryInk.fill(ci, mark_points(o), mark_col, stats)
	StoneStoryInk.edge(ci, bp, body_col.darkened(0.40), 1.3)
	_draw_eyes(ci, ep, pal, stats)


func _draw_eyes(ci: CanvasItem, ep: PackedVector2Array, pal: ProceduralPalette, stats: StoneStoryDrawStats) -> void:
	var white: Color = StoneStoryPalette.sclera(pal)
	var pupil: Color = StoneStoryPalette.ink(pal).darkened(0.3)
	var shut: bool = blinking()
	for i in ep.size():
		var er: float = eye_radius(i)
		var c: Vector2 = ep[i]
		if dying >= 0.0:
			StoneStoryInk.beam(ci, c + Vector2(-er, -er) * 0.7, c + Vector2(er, er) * 0.7, er * 0.45, er * 0.45, pupil, stats)
			StoneStoryInk.beam(ci, c + Vector2(-er, er) * 0.7, c + Vector2(er, -er) * 0.7, er * 0.45, er * 0.45, pupil, stats)
			if stats != null:
				stats.note_eye()
			continue
		if shut:
			StoneStoryInk.fill(ci, StoneStoryInk.ellipse(c, er, maxf(0.8, er * 0.22), 14), pupil, stats)
			if stats != null:
				stats.note_eye()
			continue
		StoneStoryInk.disc(ci, c, er + 0.9, pupil, stats)
		StoneStoryInk.disc(ci, c, er, white, stats)
		var dir: Vector2 = look
		if dir.length_squared() > 1.0:
			dir = dir.normalized()
		var pc: Vector2 = c + dir * er * 0.38
		StoneStoryInk.disc(ci, pc, er * 0.52, pupil, stats)
		StoneStoryInk.disc(ci, pc + Vector2(-er * 0.18, -er * 0.2), maxf(0.6, er * 0.16), white, stats)
		if stats != null:
			stats.note_eye()


func hand_point(origin: Vector2) -> Vector2:
	var o: Vector2 = origin + Vector2(0.0, -hover())
	return map_point(o, Vector2(0.42, -0.46))


static func draw_gear(ci: CanvasItem, c: StoneStoryCritter, origin: Vector2, looks: Array,
		stance: String, pal: ProceduralPalette, stats: StoneStoryDrawStats) -> void:
	var hand: Vector2 = c.hand_point(origin)
	var h: float = c.size_px.y
	var f: float = c.facing
	# 무기는 몸의 기울기를 따른다. 선딜에 뒤로, 판정 틱에 앞으로 (view.swing_lean).
	var swing: float = clampf(c.lean, -0.6, 1.0) * 0.9
	var blade: Color = StoneStoryPalette.sclera(pal)
	var edge: Color = StoneStoryPalette.ink(pal)
	var wood: Color = StoneStoryPalette.role(pal, "wood")
	var fire: Color = StoneStoryPalette.accent(pal)
	var shield_on: bool = looks.has("shield")
	for look_id in looks:
		var lk: String = str(look_id)
		if lk == "shield":
			continue
		var ang: float = -1.05 + swing
		if stance == "guard" and shield_on:
			ang = -0.35
		var dir: Vector2 = Vector2(cos(ang) * f, sin(ang))
		match lk:
			"spear":
				var tip: Vector2 = hand + dir * h * 1.25
				var butt: Vector2 = hand - dir * h * 0.35
				StoneStoryInk.beam(ci, butt, tip, 3.4, 2.6, wood, stats)
				var nrm: Vector2 = Vector2(-dir.y, dir.x)
				StoneStoryInk.fill(ci, PackedVector2Array([tip + dir * h * 0.26, tip + nrm * 5.5, tip - nrm * 5.5]), blade, stats)
			"dagger":
				var tip2: Vector2 = hand + dir * h * 0.46
				var nrm2: Vector2 = Vector2(-dir.y, dir.x)
				StoneStoryInk.fill(ci, PackedVector2Array([hand + nrm2 * 3.0, tip2, hand - nrm2 * 3.0]), blade, stats)
				StoneStoryInk.beam(ci, hand - nrm2 * 5.0, hand + nrm2 * 5.0, 2.6, 2.6, edge, stats)
			"staff":
				var top: Vector2 = hand + Vector2(0.12 * f, -1.0).normalized() * h * 0.95
				var bottom: Vector2 = hand + Vector2(-0.05 * f, 1.0).normalized() * h * 0.42
				StoneStoryInk.beam(ci, bottom, top, 3.2, 2.6, wood, stats)
				StoneStoryInk.disc(ci, top, 7.0 + sin(c.t * 3.0) * 0.8, fire, stats)
				StoneStoryInk.disc(ci, top + Vector2(-2.0, -2.0), 2.4, blade, stats)
			"brand":
				var tip3: Vector2 = hand + dir * h * 0.40
				StoneStoryInk.beam(ci, hand, tip3, 3.4, 3.0, wood, stats)
				var flick: float = sin(c.t * 13.0) * 3.0
				var up: Vector2 = Vector2(-dir.y, dir.x) * -f
				StoneStoryInk.fill(ci, PackedVector2Array([
					tip3 + Vector2(-5.0, 0.0), tip3 + dir * 9.0 + up * 3.0 + Vector2(flick, -14.0),
					tip3 + Vector2(5.0, 0.0), tip3 + Vector2(0.0, 4.0)]), fire, stats)
			_:
				var tip4: Vector2 = hand + dir * h * 0.85
				var nrm4: Vector2 = Vector2(-dir.y, dir.x)
				StoneStoryInk.fill(ci, PackedVector2Array([hand + nrm4 * 3.4, tip4 + nrm4 * 1.2, tip4 + dir * 6.0, tip4 - nrm4 * 1.2, hand - nrm4 * 3.4]), blade, stats)
				StoneStoryInk.edge(ci, PackedVector2Array([hand + nrm4 * 3.4, tip4 + nrm4 * 1.2, tip4 + dir * 6.0, tip4 - nrm4 * 1.2, hand - nrm4 * 3.4]), edge, 1.0)
				StoneStoryInk.beam(ci, hand - nrm4 * 7.0, hand + nrm4 * 7.0, 3.0, 3.0, edge, stats)
	if shield_on:
		var raise: float = 0.0 if stance != "guard" else 1.0
		var ctr: Vector2 = c.map_point(origin + Vector2(0.0, -c.hover()), Vector2(0.52, -0.42 - 0.12 * raise))
		ctr.x += f * c.size_px.x * 0.12 * raise
		var sw: float = c.size_px.x * 0.46
		var sh: float = h * 0.52
		var board := PackedVector2Array([
			ctr + Vector2(-sw * 0.5, -sh * 0.5), ctr + Vector2(sw * 0.5, -sh * 0.55),
			ctr + Vector2(sw * 0.55, sh * 0.35), ctr + Vector2(0.0, sh * 0.6), ctr + Vector2(-sw * 0.55, sh * 0.35)])
		StoneStoryInk.fill(ci, board, wood, stats)
		StoneStoryInk.edge(ci, board, edge, 1.4)
		StoneStoryInk.disc(ci, ctr, maxf(2.5, sw * 0.16), fire, stats)
