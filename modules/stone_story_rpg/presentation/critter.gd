class_name StoneStoryCritter
extends RefCounted

## 절차 애니메이션 개체 (17 §A3-b, IMPLEMENTATION_STATUS §5).
## "점 여러 개를 정해진 거리로 이어 뼈대를 만들고, 그 위에 종이 인형을 그린다" (Rain World, Jakobsson).
##   몸   = 척추 노드 체인. 머리가 목표로 가고 나머지는 베를레 적분 + 거리 제약으로 끌려온다.
##          꼬리는 받침이 약해 땅에 끌린다.
##   다리 = 척추 노드에 붙은 2관절 IK. 발은 땅에 박혀 있다가 이상 위치에서 멀어지면 호를 그리며
##          새로 딛는다. 짝 다리가 딛는 중이면 기다린다(교대 걸음).
##   팔   = 어깨 노드의 2관절 IK(무기 손) 또는 늘어진 체인. 비행 개체는 다리 대신 촉수 체인.
## 몸 설계 3계열(content/silhouette): crawler(낮고 긴 몸, 다리 여럿) · strider(두 발, 목, 팔) ·
## hauler(몸을 땅에 끌고 앞팔로 당김). 비율은 시드로 흔든다.
## 4속성:
##   다리     -> 팔다리(다리·팔·촉수) 총수
##   동그라미 -> 몸 굵기와 매끈함 (낮으면 등돌기가 선 마디 몸)
##   틀림     -> 비대칭: 한 다리만 긺 + 그 다리 절뚝임, 척추 한 곳이 솟음, 머리 기울기, 마디 굵기 들쭉날쭉
##   놀랍다   -> 머리가 급하게 홱 돌아가는 빈도, 작은 눈 수 (1 + floor(놀랍다/4))

const K_PX: float = 1.12
const MIN_W: float = 18.0
const MIN_H: float = 18.0
const DT: float = 1.0 / 60.0
const MAX_SUBSTEPS: int = 6
const ITER: int = 3
const DAMP: float = 0.90
const FORMS: Array[String] = ["crawler", "strider", "hauler"]

var form: String = "strider"
var attrs: Dictionary = {}
var seed_value: int = 0
var size_px: Vector2 = Vector2(30.0, 40.0)
var flying: bool = false
var leg_count: int = 1
var eye_count: int = 1
var legs_n: int = 0
var arms_n: int = 0
var tentacles_n: int = 0

var nodes: PackedVector2Array = PackedVector2Array()
var prev: PackedVector2Array = PackedVector2Array()
var rad: PackedFloat32Array = PackedFloat32Array()
var seg: PackedFloat32Array = PackedFloat32Array()
var rest_x: PackedFloat32Array = PackedFloat32Array()
var rest_h: PackedFloat32Array = PackedFloat32Array()
var kx: PackedFloat32Array = PackedFloat32Array()
var ky: PackedFloat32Array = PackedFloat32Array()
var bob: PackedFloat32Array = PackedFloat32Array()
var tail_from: int = 0
var limbs: Array = []
var kink_at: int = -1
var head_tilt: float = 0.0
var snout: float = 0.0
var ridges: bool = false
var spots: PackedVector3Array = PackedVector3Array()
var hue_shift: float = 0.0
var value_shift: float = 0.0
var gravity: float = 400.0

var anchor: Vector2 = Vector2.ZERO
var placed: bool = false
var steps_taken: int = 0
var max_concurrent_steps: int = 0
var _acc: float = 0.0
var _vel: Vector2 = Vector2.ZERO
var _anchor_prev: Vector2 = Vector2.ZERO
var _moving: float = 0.0
var _goal_off: Vector2 = Vector2.ZERO
var _snap_left: float = 1.0
var _snap_n: int = 0
var _hit_seen: float = 0.0
var _rs: StoneStoryRng = null
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
	c.form = str(sil.get("form", "strider"))
	if not FORMS.has(c.form):
		c.form = "strider"
	var w: float = maxf(MIN_W, float(shape.get("width_units", 24)) * K_PX * scale_mult)
	var h: float = maxf(MIN_H, float(shape.get("height_units", 30)) * K_PX * scale_mult)
	c.size_px = Vector2(w, h)
	c.gravity = h * 9.0
	c.noise = Procedural.make_noise(Procedural.derive_seed(seed_in, "critter.wobble"), ProceduralNoiseField.FIELD_SHAPE)
	var s: StoneStoryRng = StoneStoryCore.stream(seed_in, StoneStoryCore.TAG_TEXTURE + ".critter")
	c._rs = StoneStoryCore.stream(seed_in, StoneStoryCore.TAG_TEXTURE + ".critter.live")
	c.blink_every = 2.2 + s.unit(7) * 3.4
	c.blink_at = s.unit(8) * c.blink_every
	c._plan(sil, s)
	return c


## 몸빛. 뷰·로비가 같은 규칙을 쓴다. 검정 몸 + 분홍 띠(A3-a)를 버린다.
static func foe_tones(pal: ProceduralPalette, is_boss: bool) -> Array[Color]:
	if is_boss:
		return [pal.mix_roles(StoneStoryPalette.STRUCTURE, StoneStoryPalette.ACCENT, 0.38),
				pal.mix_roles(StoneStoryPalette.HORIZON, StoneStoryPalette.ACCENT, 0.30)]
	return [StoneStoryPalette.structure(pal).lightened(0.10),
			pal.mix_roles(StoneStoryPalette.STRUCTURE, StoneStoryPalette.HORIZON, 0.55)]


static func player_tones(pal: ProceduralPalette) -> Array[Color]:
	return [StoneStoryPalette.sclera(pal).lerp(StoneStoryPalette.horizon(pal), 0.22),
			pal.mix_roles(StoneStoryPalette.HORIZON, StoneStoryPalette.GROUND, 0.45)]


func _r() -> float:
	return clampf(float(attrs.get(StoneStoryAttributes.ROUND, 0.0)) / 10.0, 0.0, 1.0)


func _w() -> float:
	return clampf(float(attrs.get(StoneStoryAttributes.WRONGNESS, 0.0)) / 10.0, 0.0, 1.0)


func _sur() -> float:
	return clampf(float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0)) / 10.0, 0.0, 1.0)


static func _jit(s: StoneStoryRng, k: int, amount: float) -> float:
	return 1.0 + (s.unit(k) * 2.0 - 1.0) * amount


# --- 설계 ------------------------------------------------------------

func _plan(sil: Dictionary, s: StoneStoryRng) -> void:
	var r: float = _r()
	var w: float = _w()
	var W: float = size_px.x
	var H: float = size_px.y
	var vary: float = clampf(float(sil.get("vary", 0.15)), 0.0, 0.4)
	var sp: Dictionary = sil.get("spine", {})
	var nr: Array = sp.get("nodes", [5, 7])
	var n: int = clampi(s.range_int(1, int(nr[0]), int(nr[1])), 3, 12)
	var body_len: float = W * float(sp.get("length", 1.0)) * _jit(s, 2, vary)
	var tail_frac: float = clampf(float(sp.get("tail", 0.3)) * _jit(s, 3, vary * 2.0), 0.0, 0.9)
	var ride: float = H * float(sil.get("ride", 0.4)) * _jit(s, 4, vary)
	var girth: float = H * float(sil.get("girth", 0.2)) * (0.72 + 0.62 * r) * _jit(s, 5, vary)
	var hd: Dictionary = sil.get("head", {})
	var head_size: float = float(hd.get("size", 1.1)) * _jit(s, 9, vary)
	var head_raise: float = H * float(hd.get("raise", 0.0)) * _jit(s, 11, vary)
	snout = float(hd.get("snout", 0.3)) * _jit(s, 12, vary)
	var br: Array = sil.get("bulge", [0.3, 0.5])
	var bulge: float = lerpf(float(br[0]), float(br[1]), s.unit(6))
	var total: float = body_len * (1.0 + tail_frac)
	var u_tail: float = 1.0 / (1.0 + tail_frac)
	tail_from = n
	nodes.resize(n)
	prev.resize(n)
	rad.resize(n)
	seg.resize(n)
	rest_x.resize(n)
	rest_h.resize(n)
	kx.resize(n)
	ky.resize(n)
	bob.resize(n)
	for i in n:
		var u: float = float(i) / float(n - 1)
		var in_tail: bool = u > u_tail + 0.001
		if in_tail and tail_from == n:
			tail_from = i
		var bu: float = clampf(u / u_tail, 0.0, 1.0)
		var tu: float = clampf((u - u_tail) / maxf(0.001, 1.0 - u_tail), 0.0, 1.0)
		var prof: float = 1.0 - pow(absf(bu - bulge) / maxf(bulge, 1.0 - bulge), 2.0) * 0.42
		var rr: float = girth * prof
		if in_tail:
			rr = lerpf(girth * 0.55, girth * 0.16, tu)
		if i == 0:
			rr = girth * head_size
		rr *= 1.0 + (s.unit(40 + i) - 0.5) * 0.55 * w
		rad[i] = maxf(1.2, rr)
		rest_x[i] = body_len * 0.5 - total * u
		var hh: float = ride
		match form:
			"strider":
				hh = lerpf(ride + head_raise, ride, smoothstep(0.0, 0.55, bu))
			"hauler":
				hh = rad[i] * 0.92 + (head_raise if i == 0 else 0.0)
			_:
				hh = ride + (head_raise if i == 0 else 0.0)
		if in_tail:
			hh = lerpf(hh, rad[i] * 0.9, smoothstep(0.0, 0.6, tu))
		if flying:
			rest_x[i] = lerpf(W * 0.12, -W * 0.18, u)
			hh = H * 0.45 - total * 0.75 * u
		rest_h[i] = hh
		var head: bool = i == 0
		kx[i] = 380.0 if head else (6.0 if in_tail else (34.0 if form != "hauler" else 14.0))
		ky[i] = 380.0 if head else (10.0 if in_tail else 150.0)
		if flying and not head:
			kx[i] = 10.0
			ky[i] = 4.0
	if w > 0.05 and n >= 4:
		kink_at = clampi(int(round(float(maxi(2, tail_from - 1)) * (0.4 + 0.3 * s.unit(13)))), 1, n - 2)
		rest_h[kink_at] += girth * 1.1 * w
	for i in n:
		seg[i] = 0.0 if i == 0 else Vector2(rest_x[i] - rest_x[i - 1], rest_h[i] - rest_h[i - 1]).length()
	head_tilt = (s.unit(14) - 0.5) * 0.9 * w
	ridges = r < 0.35
	hue_shift = (s.unit(15) - 0.5) * 0.035
	value_shift = (s.unit(16) - 0.5) * 0.16
	spots = PackedVector3Array()
	var nsp: int = s.range_int(17, 0, 4)
	for k in nsp:
		spots.append(Vector3(s.range_int(18 + k, 1, maxi(1, tail_from - 1)), s.unit(30 + k) - 0.5, 0.18 + 0.14 * s.unit(35 + k)))

	var sur: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	eye_count = clampi(1 + int(floor(sur / 4.0)), 1, 3)
	leg_count = StoneStoryAttributes.clamp_limbs(int(attrs.get(StoneStoryAttributes.LIMBS, 1)))
	_plan_limbs(sil, s, ride, girth, u_tail, n)


func _node_at(bu: float, u_tail: float, n: int, lo: int = 1) -> int:
	return clampi(int(round(bu * u_tail * float(n - 1))), lo, maxi(lo, n - 2))


func _plan_limbs(sil: Dictionary, s: StoneStoryRng, ride: float, girth: float, u_tail: float, n: int) -> void:
	limbs.clear()
	var w: float = _w()
	var H: float = size_px.y
	var ld: Dictionary = sil.get("legs", {})
	var ad: Dictionary = sil.get("arms", {})
	var span: Array = ld.get("span", [0.15, 0.8])
	var leg_len: float = maxf(4.0, ride * float(ld.get("length", 1.3)) * _jit(s, 50, 0.12))
	if flying:
		tentacles_n = leg_count
		for k in tentacles_n:
			var u: float = lerpf(0.35, 1.0, float(k) / maxf(1.0, float(tentacles_n - 1)))
			var node: int = clampi(int(round(u * float(n - 1))), 1, n - 1)
			var cnt: int = 5
			var total: float = H * (0.42 + 0.25 * s.unit(60 + k)) * (1.0 + (0.5 * w if k == 0 else 0.0))
			limbs.append({"kind": "tentacle", "node": node, "side": 1.0 if k % 2 == 0 else -1.0,
					"seg": total / float(cnt - 1), "pts": PackedVector2Array(), "old": PackedVector2Array(),
					"cnt": cnt, "phase": s.unit(70 + k) * TAU, "width": maxf(1.2, rad[node] * 0.32)})
		return
	match form:
		"strider":
			legs_n = mini(leg_count, 2 if leg_count <= 5 else 4)
			arms_n = leg_count - legs_n
		"hauler":
			arms_n = mini(leg_count, 4)
			legs_n = leg_count - arms_n
		_:
			legs_n = leg_count
			arms_n = 0
	var odd: int = -1
	if w > 0.05 and leg_count > 0:
		odd = s.range_int(51, 0, leg_count - 1)
	var li: int = 0
	# 다리
	var pairs: int = int(ceil(float(legs_n) / 2.0))
	for p in pairs:
		var pu: float = 0.5 if pairs == 1 else lerpf(float(span[0]), float(span[1]), float(p) / float(pairs - 1))
		if form == "strider":
			pu = 0.92 if (pairs == 1 or p == pairs - 1) else 0.30
		var node: int = _node_at(pu, u_tail, n)
		for side in [1.0, -1.0]:
			if li >= legs_n:
				break
			var is_odd: bool = li == odd
			var total: float = leg_len * (1.0 + (0.45 * w if is_odd else 0.0))
			if form == "hauler":
				total = maxf(3.0, girth * 1.1)
			var front: bool = pu < 0.5
			var reach: float = total * (0.30 if front else -0.08)
			if form == "strider":
				reach = total * 0.10
			var bend: float = -1.0 if front else 1.0
			if form == "strider":
				bend = 1.0
			var group: int = (p + (0 if side > 0.0 else 1)) % 2
			limbs.append({"kind": "leg", "node": node, "side": side, "l1": total * 0.5, "l2": total * 0.5,
					"reach": reach + (total * 0.14 if side < 0.0 else 0.0), "bend": bend,
					"up": 1.0 if form == "crawler" else 0.25, "stride": total * (0.55 if form != "hauler" else 0.9),
					"lift": total * (0.32 if form != "hauler" else 0.5), "step_time": 0.11 + total / maxf(1.0, H) * 0.09,
					"limp": 1.0 + (1.3 * w if is_odd else 0.0), "group": group, "foot": Vector2.ZERO,
					"from": Vector2.ZERO, "to": Vector2.ZERO, "k": -1.0,
					"width": maxf(1.3, rad[node] * (0.42 if form != "hauler" else 0.5))})
			li += 1
	# 팔
	var arm_len: float = H * float(ad.get("length", 0.45)) * _jit(s, 52, 0.12)
	var shoulder_u: float = float(ad.get("at", 0.25))
	var shoulder: int = _node_at(shoulder_u, u_tail, n, 0 if form == "hauler" else 1)
	for a in arms_n:
		var is_odd2: bool = li == odd
		var total2: float = arm_len * (1.0 + (0.45 * w if is_odd2 else 0.0))
		var side2: float = 1.0 if a % 2 == 0 else -1.0
		var pulls: bool = form == "hauler"
		var chain: bool = not pulls and a >= 2
		limbs.append({"kind": "chain" if chain else ("pull" if pulls else "arm"), "node": shoulder, "side": side2,
				"l1": total2 * 0.5, "l2": total2 * 0.5, "bend": -1.0, "up": 0.6 if pulls else -0.2,
				"reach": total2 * (0.75 + 0.05 * float(a)), "stride": total2 * 0.6, "lift": total2 * 0.35,
				"step_time": 0.20 * (1.0 + (1.3 * w if is_odd2 else 0.0)), "limp": 1.0 + (1.3 * w if is_odd2 else 0.0),
				"group": a % 2, "foot": Vector2.ZERO, "from": Vector2.ZERO, "to": Vector2.ZERO, "k": -1.0,
				"hand": Vector2.ZERO, "weapon": a == 0 and not pulls, "phase": s.unit(80 + a) * TAU,
				"seg": total2 / 3.0, "cnt": 4, "pts": PackedVector2Array(), "old": PackedVector2Array(),
				"width": maxf(1.2, rad[shoulder] * 0.34)})
		li += 1


# --- 시뮬레이션 ------------------------------------------------------

func place(origin: Vector2) -> void:
	if not placed or origin.distance_to(anchor) > maxf(size_px.x, size_px.y) * 4.0:
		_init_rig(origin)
		return
	anchor = origin


func _init_rig(origin: Vector2) -> void:
	anchor = origin
	_anchor_prev = origin
	_vel = Vector2.ZERO
	placed = true
	for i in nodes.size():
		nodes[i] = _target(i)
		prev[i] = nodes[i]
	for L in limbs:
		var d: Dictionary = L
		match str(d["kind"]):
			"leg", "pull":
				d["foot"] = _ideal(d)
				d["k"] = -1.0
			"arm":
				d["hand"] = _hand_goal(d)
			_:
				var pts := PackedVector2Array()
				var root: Vector2 = nodes[int(d["node"])]
				for k in int(d["cnt"]):
					pts.append(root + Vector2(0.0, float(d["seg"]) * float(k)))
				d["pts"] = pts
				d["old"] = pts.duplicate()


func _target(i: int) -> Vector2:
	var p: Vector2 = anchor + Vector2(facing * rest_x[i], -rest_h[i] - (hover() if flying else 0.0))
	p.y += bob[i] if i < bob.size() else 0.0
	if i == 0:
		p += Vector2(facing * size_px.x * 0.30 * lean, size_px.y * 0.05 * maxf(0.0, lean))
		p += _goal_off
		if noise != null:
			p += Vector2(noise.sample(11.0, t * 40.0), noise.sample(71.0, t * 40.0)) * size_px.y * 0.012
	return p


func step(delta: float) -> void:
	t += delta
	hit = maxf(0.0, hit - delta * 3.2)
	if dying >= 0.0:
		dying = minf(1.0, dying + delta * 1.6)
	if not placed:
		return
	_acc += delta
	var n: int = 0
	while _acc >= DT and n < MAX_SUBSTEPS:
		_sim(DT)
		_acc -= DT
		n += 1
	if n == MAX_SUBSTEPS:
		_acc = 0.0


func _sim(dt: float) -> void:
	var frame_vel: Vector2 = (anchor - _anchor_prev) / dt
	if (anchor - _anchor_prev).length() > 0.01:
		_moving = 0.45
	else:
		_moving = maxf(0.0, _moving - dt)
	_vel = _vel.lerp(frame_vel, 0.08)
	_anchor_prev = anchor
	_think(dt)
	if hit > _hit_seen + 0.3:
		for i in nodes.size():
			var k: float = 1.0 - float(i) / float(maxi(1, nodes.size()))
			prev[i] += Vector2(facing * size_px.y * 0.05, size_px.y * 0.02) * k
	_hit_seen = hit
	var sup: float = 1.0 if dying < 0.0 else maxf(0.0, 1.0 - dying * 1.4)
	var ground: float = anchor.y
	var n: int = nodes.size()
	for i in n:
		bob[i] = 0.0
	for L in limbs:
		var d: Dictionary = L
		if float(d.get("k", -1.0)) >= 0.0 and str(d["kind"]) == "leg":
			bob[int(d["node"])] += sin(PI * float(d["k"])) * float(d["lift"]) * 0.10
	for i in n:
		var p: Vector2 = nodes[i]
		var tg: Vector2 = _target(i)
		var v: Vector2 = (p - prev[i]) * DAMP
		var a: Vector2 = Vector2(kx[i] * (tg.x - p.x) * (sup if i == 0 else 1.0),
				ky[i] * sup * (tg.y - p.y) + gravity * (0.15 if flying else 1.0))
		prev[i] = p
		nodes[i] = p + v + a * dt * dt
	for it in ITER:
		for i in range(1, n):
			var a0: Vector2 = nodes[i - 1]
			var b0: Vector2 = nodes[i]
			var dv: Vector2 = b0 - a0
			var dl: float = dv.length()
			if dl < 0.0001:
				continue
			var diff: float = (dl - seg[i]) / dl
			var wa: float = 0.15 if i == 1 else 0.5
			nodes[i - 1] = a0 + dv * diff * wa
			nodes[i] = b0 - dv * diff * (1.0 - wa)
		for i in n:
			var floor_y: float = ground - rad[i] * 0.85
			if nodes[i].y > floor_y:
				nodes[i] = Vector2(nodes[i].x, floor_y)
				prev[i] = Vector2(lerpf(prev[i].x, nodes[i].x, 0.35), prev[i].y)
	var stepping: int = 0
	for L in limbs:
		var d: Dictionary = L
		match str(d["kind"]):
			"leg", "pull":
				_foot(d, dt, ground)
				if float(d["k"]) >= 0.0:
					stepping += 1
			"arm":
				_arm(d, dt)
			_:
				_chain(d, dt)
	max_concurrent_steps = maxi(max_concurrent_steps, stepping)


## 놀랍다: 머리가 가끔 홱 다른 곳을 본다. 높을수록 자주, 급하게.
func _think(dt: float) -> void:
	var s: float = _sur()
	_snap_left -= dt
	if _snap_left <= 0.0 and _rs != null:
		_snap_n += 1
		var H: float = size_px.y
		var amp: float = H * (0.04 + 0.14 * s)
		if _rs.unit(_snap_n * 3) < 0.35:
			_goal_off = Vector2.ZERO
		else:
			_goal_off = Vector2((_rs.unit(_snap_n * 3 + 1) - 0.5) * 2.0 * amp, (_rs.unit(_snap_n * 3 + 2) - 0.7) * amp)
		_snap_left = lerpf(2.6, 0.35, s) * (0.6 + 0.8 * _rs.unit(_snap_n * 3 + 7))


func _hip(d: Dictionary) -> Vector2:
	var i: int = int(d["node"])
	return nodes[i] + Vector2(0.0, rad[i] * 0.30)


func _ideal(d: Dictionary) -> Vector2:
	var root: Vector2 = _hip(d)
	var lead: float = clampf(_vel.x * 0.10, -float(d["stride"]) * 0.6, float(d["stride"]) * 0.6)
	return Vector2(root.x + facing * float(d["reach"]) + lead, anchor.y)


func _can_step(d: Dictionary) -> bool:
	var g: int = int(d["group"])
	var busy: int = 0
	var cap: int = maxi(1, int(ceil(float(legs_n + (arms_n if form == "hauler" else 0)) / 2.0)))
	for L in limbs:
		var o: Dictionary = L
		if is_same(o, d) or float(o.get("k", -1.0)) < 0.0:
			continue
		var kd: String = str(o["kind"])
		if kd != "leg" and kd != "pull":
			continue
		busy += 1
		if int(o["group"]) != g:
			return false
	return busy < cap


func _foot(d: Dictionary, dt: float, ground: float) -> void:
	var k: float = float(d["k"])
	if k >= 0.0:
		k += dt / (float(d["step_time"]) * float(d["limp"]))
		var e: float = smoothstep(0.0, 1.0, minf(1.0, k))
		var f: Vector2 = (d["from"] as Vector2).lerp(d["to"], e)
		f.y -= sin(PI * minf(1.0, k)) * float(d["lift"]) / float(d["limp"])
		d["foot"] = f
		if k >= 1.0:
			d["foot"] = Vector2((d["to"] as Vector2).x, ground)
			k = -1.0
			steps_taken += 1
		d["k"] = k
		return
	var foot: Vector2 = d["foot"]
	foot.y = ground
	d["foot"] = foot
	if dying >= 0.0:
		return
	var ideal: Vector2 = _ideal(d)
	var off: float = absf(foot.x - ideal.x)
	var reach: float = float(d["l1"]) + float(d["l2"])
	var stretched: bool = foot.distance_to(_hip(d)) > reach * 0.97
	var settle: bool = _moving <= 0.0 and off > float(d["stride"]) * 0.30
	if not (off > float(d["stride"]) or stretched or settle):
		return
	if not stretched and not _can_step(d):
		return
	var dir: float = signf(ideal.x - foot.x)
	d["from"] = foot
	d["to"] = Vector2(ideal.x + dir * float(d["stride"]) * (0.35 if _moving > 0.0 else 0.0), ground)
	d["k"] = 0.0


func _hand_goal(d: Dictionary) -> Vector2:
	var sh: Vector2 = nodes[int(d["node"])]
	var l: float = float(d["l1"]) + float(d["l2"])
	if bool(d.get("weapon", false)):
		var fw: float = clampf(lean, -0.6, 1.0)
		return sh + Vector2(facing * l * (0.42 + 0.45 * fw), l * (0.58 - 0.35 * fw))
	var sw: float = sin(t * 7.0 + float(d["phase"])) * l * 0.22 * clampf(_moving * 3.0, 0.0, 1.0)
	return sh + Vector2(-facing * l * 0.08 + sw, l * 0.82)


func _arm(d: Dictionary, dt: float) -> void:
	var goal: Vector2 = _hand_goal(d)
	if dying >= 0.0:
		goal.y = anchor.y
	var h: Vector2 = d["hand"]
	d["hand"] = h.lerp(goal, 1.0 - exp(-dt * 22.0))


func _chain(d: Dictionary, dt: float) -> void:
	var pts: PackedVector2Array = d["pts"]
	var old: PackedVector2Array = d["old"]
	if pts.is_empty():
		return
	pts[0] = nodes[int(d["node"])] + Vector2(0.0, rad[int(d["node"])] * 0.5)
	old[0] = pts[0]
	var sway: float = sin(t * 2.4 + float(d["phase"])) * size_px.y * 1.6
	for k in range(1, pts.size()):
		var p: Vector2 = pts[k]
		var v: Vector2 = (p - old[k]) * 0.94
		old[k] = p
		pts[k] = p + v + Vector2(sway * float(k) / float(pts.size()), gravity * 0.5) * dt * dt
	var sl: float = float(d["seg"])
	for it in ITER:
		for k in range(1, pts.size()):
			var dv: Vector2 = pts[k] - pts[k - 1]
			var dl: float = dv.length()
			if dl > 0.0001:
				pts[k] = pts[k - 1] + dv * (sl / dl)
		for k in pts.size():
			if pts[k].y > anchor.y:
				pts[k] = Vector2(pts[k].x, anchor.y)
	d["pts"] = pts
	d["old"] = old


## 2관절 IK. bend_pref 쪽으로 무릎/팔꿈치를 꺾는다. 두 뼈 길이는 늘 l1, l2 다.
static func ik(root: Vector2, target: Vector2, l1: float, l2: float, bend_pref: Vector2) -> PackedVector2Array:
	var dv: Vector2 = target - root
	var d: float = clampf(dv.length(), absf(l1 - l2) + 0.001, l1 + l2 - 0.001)
	var dir: Vector2 = dv.normalized() if dv.length_squared() > 0.000001 else Vector2.DOWN
	var cos_a: float = clampf((l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d), -1.0, 1.0)
	var a: float = acos(cos_a)
	var j1: Vector2 = root + dir.rotated(a) * l1
	var j2: Vector2 = root + dir.rotated(-a) * l1
	var mid: Vector2 = root + dir * (d * 0.5)
	var joint: Vector2 = j1 if (j1 - mid).dot(bend_pref) >= (j2 - mid).dot(bend_pref) else j2
	var end: Vector2 = joint + (root + dir * d - joint).normalized() * l2
	return PackedVector2Array([root, joint, end])


func limb_points(i: int) -> PackedVector2Array:
	var d: Dictionary = limbs[i]
	match str(d["kind"]):
		"leg", "pull":
			var pref := Vector2(float(d["bend"]) * facing, -float(d["up"]))
			return ik(_hip(d), d["foot"], float(d["l1"]), float(d["l2"]), pref)
		"arm":
			var pref2 := Vector2(float(d["bend"]) * facing, -float(d["up"]))
			return ik(nodes[int(d["node"])], d["hand"], float(d["l1"]), float(d["l2"]), pref2)
		_:
			return d["pts"]


func planted(i: int) -> bool:
	var d: Dictionary = limbs[i]
	return float(d.get("k", -1.0)) < 0.0


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


func map_point(origin: Vector2, p: Vector2) -> Vector2:
	return origin + Vector2(p.x * facing * size_px.x, p.y * size_px.y)


func head_dir() -> Vector2:
	if nodes.size() < 2:
		return Vector2(facing, 0.0)
	var d: Vector2 = nodes[0] - nodes[1]
	return d.normalized() if d.length_squared() > 0.0001 else Vector2(facing, 0.0)


# --- 그리기 ----------------------------------------------------------

func _tone(c: Color) -> Color:
	var o := Color.from_hsv(fposmod(c.h + hue_shift, 1.0), c.s, clampf(c.v * (1.0 + value_shift), 0.0, 1.0), c.a)
	if dying >= 0.0:
		o = o.darkened(0.30 * dying)
	return o


## 척추를 부드럽게 잇는다 (Catmull-Rom 3분할). 반지름도 같이 보간.
func _smooth_spine() -> Array:
	var pts := PackedVector2Array()
	var rr := PackedFloat32Array()
	var n: int = nodes.size()
	for i in n - 1:
		var p0: Vector2 = nodes[maxi(0, i - 1)]
		var p1: Vector2 = nodes[i]
		var p2: Vector2 = nodes[i + 1]
		var p3: Vector2 = nodes[mini(n - 1, i + 2)]
		for k in 3:
			var u: float = float(k) / 3.0
			var u2: float = u * u
			var u3: float = u2 * u
			pts.append(0.5 * ((2.0 * p1) + (-p0 + p2) * u + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * u2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * u3))
			rr.append(lerpf(rad[i], rad[i + 1], u))
	pts.append(nodes[n - 1])
	rr.append(rad[n - 1])
	return [pts, rr]


static func _tube(ci: CanvasItem, pts: PackedVector2Array, rr: PackedFloat32Array, k: float, grow: float,
		shift: Vector2, col: Color, stats: StoneStoryDrawStats, from_i: int = 0) -> void:
	for i in range(from_i, pts.size()):
		var r: float = rr[i] * k + grow
		StoneStoryInk.disc(ci, pts[i] + shift * rr[i], r, col, stats)
		if i > from_i:
			StoneStoryInk.beam(ci, pts[i - 1] + shift * rr[i - 1], pts[i] + shift * rr[i],
					(rr[i - 1] * k + grow) * 2.0, r * 2.0, col, stats)


func _limb(ci: CanvasItem, i: int, col: Color, outline: Color, grow: float, stats: StoneStoryDrawStats) -> void:
	var d: Dictionary = limbs[i]
	var lp: PackedVector2Array = limb_points(i)
	var wd: float = float(d["width"])
	var kind: String = str(d["kind"])
	if kind == "chain" or kind == "tentacle":
		for k in range(1, lp.size()):
			var t0: float = 1.0 - float(k - 1) / float(lp.size())
			var t1: float = 1.0 - float(k) / float(lp.size())
			StoneStoryInk.beam(ci, lp[k - 1], lp[k], wd * 2.0 * t0 + grow * 2.0, wd * 2.0 * t1 + grow * 2.0, outline, stats)
		for k in range(1, lp.size()):
			var t0b: float = 1.0 - float(k - 1) / float(lp.size())
			var t1b: float = 1.0 - float(k) / float(lp.size())
			StoneStoryInk.beam(ci, lp[k - 1], lp[k], wd * 2.0 * t0b, wd * 2.0 * t1b, col, stats)
			StoneStoryInk.disc(ci, lp[k], wd * t1b, col, stats)
		return
	var w0: float = wd * 2.0
	var w1: float = wd * 1.5
	var w2: float = wd * 0.9
	StoneStoryInk.beam(ci, lp[0], lp[1], w0 + grow * 2.0, w1 + grow * 2.0, outline, stats)
	StoneStoryInk.beam(ci, lp[1], lp[2], w1 + grow * 2.0, w2 + grow * 2.0, outline, stats)
	StoneStoryInk.disc(ci, lp[1], w1 * 0.5 + grow, outline, stats)
	StoneStoryInk.beam(ci, lp[0], lp[1], w0, w1, col, stats)
	StoneStoryInk.beam(ci, lp[1], lp[2], w1, w2, col, stats)
	StoneStoryInk.disc(ci, lp[1], w1 * 0.5, col, stats)
	if kind == "leg" or kind == "pull":
		# 발: 땅을 짚는 짧은 발가락 두 개
		var toe: Vector2 = Vector2(facing, 0.0) * wd * 1.6
		StoneStoryInk.beam(ci, lp[2], lp[2] + toe + Vector2(0.0, 0.5), w2 + grow, 1.2, outline, stats)
		StoneStoryInk.beam(ci, lp[2], lp[2] - toe * 0.6 + Vector2(0.0, 0.5), w2 + grow, 1.2, outline, stats)
		StoneStoryInk.disc(ci, lp[2], w2 * 0.6, col, stats)
	else:
		StoneStoryInk.disc(ci, lp[2], w2 * 0.8, col, stats)


func draw(ci: CanvasItem, origin: Vector2, pal: ProceduralPalette, stats: StoneStoryDrawStats,
		body_col: Color, mark_col: Color) -> void:
	place(origin)
	var base: Color = _tone(body_col)
	var belly: Color = _tone(mark_col)
	var outline: Color = base.darkened(0.55)
	var far: Color = base.darkened(0.28)
	var grow: float = clampf(size_px.y * 0.018, 1.0, 3.0)
	var span: float = absf(nodes[0].x - nodes[nodes.size() - 1].x) * 0.5 + rad[0]
	var sh_w: float = maxf(size_px.x * 0.35, span) * (0.6 if flying else 1.0)
	var mid_x: float = (nodes[0].x + nodes[nodes.size() - 1].x) * 0.5
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(mid_x, anchor.y + 1.0), sh_w, maxf(2.0, sh_w * 0.16), 18),
			StoneStoryPalette.shadow(pal), stats)
	for i in limbs.size():
		if float(limbs[i]["side"]) < 0.0:
			_limb(ci, i, far, outline, grow, stats)
	var sm: Array = _smooth_spine()
	var pts: PackedVector2Array = sm[0]
	var rr: PackedFloat32Array = sm[1]
	_tube(ci, pts, rr, 1.0, grow, Vector2.ZERO, outline, stats)
	if ridges:
		_draw_ridges(ci, outline)
	_tube(ci, pts, rr, 1.0, 0.0, Vector2.ZERO, base, stats)
	_tube(ci, pts, rr, 0.58, 0.0, Vector2(0.0, 0.36), belly, stats, 2)
	_tube(ci, pts, rr, 0.34, 0.0, Vector2(0.0, -0.46), base.lightened(0.20), stats, 2)
	for sp in spots:
		var ni: int = clampi(int(sp.x), 0, nodes.size() - 1)
		StoneStoryInk.disc(ci, nodes[ni] + Vector2(sp.y * rad[ni], -rad[ni] * 0.5), rad[ni] * sp.z, belly.darkened(0.12), stats)
	_draw_head(ci, pal, base, belly, outline, grow, stats)
	for i in limbs.size():
		if float(limbs[i]["side"]) > 0.0:
			_limb(ci, i, base.darkened(0.06), outline, grow, stats)


func _draw_ridges(ci: CanvasItem, col: Color) -> void:
	var r: float = _r()
	var tall: float = (1.0 - r / 0.35) * 0.55 + 0.25
	for i in range(1, maxi(2, tail_from)):
		var a: Vector2 = nodes[i - 1]
		var b: Vector2 = nodes[i]
		var d: Vector2 = (a - b).normalized()
		var up: Vector2 = Vector2(d.y, -d.x)
		if up.y > 0.0:
			up = -up
		var m: Vector2 = b + (a - b) * 0.5
		var base_a: Vector2 = m + up * rad[i] * 0.7 + d * rad[i] * 0.45
		var base_b: Vector2 = m + up * rad[i] * 0.7 - d * rad[i] * 0.45
		var tip: Vector2 = m + up * rad[i] * (1.0 + tall) - d * rad[i] * 0.35
		ci.draw_colored_polygon(PackedVector2Array([base_a, tip, base_b]), col)


func _draw_head(ci: CanvasItem, pal: ProceduralPalette, base: Color, belly: Color, outline: Color,
		grow: float, stats: StoneStoryDrawStats) -> void:
	var p0: Vector2 = nodes[0]
	var rh: float = rad[0]
	var dir: Vector2 = head_dir().rotated(head_tilt * facing)
	var up: Vector2 = Vector2(dir.y, -dir.x)
	if up.y > 0.0:
		up = -up
	var ang: float = dir.angle()
	var skull_c: Vector2 = p0 + dir * rh * 0.12
	var sn: float = clampf(snout, 0.0, 1.2)
	var snout_c: Vector2 = p0 + dir * rh * (0.75 + 0.35 * sn) - up * rh * 0.12
	var open: float = clampf(lean, 0.0, 1.0) if dying < 0.0 else 0.0
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(skull_c, rh * 1.08 + grow, rh * 0.92 + grow, 18, ang), outline, stats)
	if sn > 0.05:
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(snout_c, rh * (0.45 + 0.45 * sn) + grow, rh * 0.52 + grow, 14, ang), outline, stats)
	if open > 0.05:
		var hinge: Vector2 = p0 + dir * rh * 0.1 - up * rh * 0.15
		var jd: Vector2 = dir.rotated(0.75 * open * facing)
		var upper: Vector2 = hinge + dir.rotated(-0.25 * open * facing) * rh * (1.3 + 0.5 * sn)
		var lower: Vector2 = hinge + jd * rh * (1.2 + 0.5 * sn)
		StoneStoryInk.fill(ci, PackedVector2Array([hinge, upper, lower]), outline.darkened(0.3), stats)
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(hinge + jd * rh * 0.6 * (1.0 + 0.4 * sn), rh * 0.62 * (1.0 + 0.4 * sn), rh * 0.26, 12, jd.angle()), belly, stats)
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(skull_c, rh * 1.08, rh * 0.92, 18, ang), base, stats)
	if sn > 0.05:
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(snout_c, rh * (0.45 + 0.45 * sn), rh * 0.52, 14, ang), base, stats)
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(skull_c - up * rh * 0.4, rh * 0.7, rh * 0.32, 12, ang), belly, stats)
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(skull_c + up * rh * 0.45 - dir * rh * 0.15, rh * 0.5, rh * 0.2, 10, ang), base.lightened(0.20), stats)
	_draw_eyes(ci, pal, p0, dir, up, rh, stats)


func _draw_eyes(ci: CanvasItem, pal: ProceduralPalette, p0: Vector2, dir: Vector2, up: Vector2, rh: float,
		stats: StoneStoryDrawStats) -> void:
	var white: Color = StoneStoryPalette.sclera(pal)
	var pupil: Color = StoneStoryPalette.ink(pal).darkened(0.3)
	var shut: bool = blinking()
	var w: float = _w()
	for i in eye_count:
		var er: float = clampf(rh * 0.20, 1.3, 5.5)
		if i == 0 and w > 0.4:
			er *= 1.0 + 0.4 * w
		if i > 0:
			er *= 0.72
		var c: Vector2 = p0 + dir * rh * (0.42 - 0.34 * float(i)) + up * rh * (0.26 + 0.10 * float(i))
		if dying >= 0.0 or shut:
			StoneStoryInk.fill(ci, StoneStoryInk.ellipse(c, er, maxf(0.6, er * 0.25), 10, dir.angle()), pupil, stats)
		else:
			StoneStoryInk.disc(ci, c, er, white, stats)
			var lk: Vector2 = look
			if lk.length_squared() > 1.0:
				lk = lk.normalized()
			StoneStoryInk.disc(ci, c + lk * er * 0.3, er * 0.62, pupil, stats)
		if stats != null:
			stats.note_eye()


func hand_point(origin: Vector2) -> Vector2:
	if placed:
		for L in limbs:
			var d: Dictionary = L
			if bool(d.get("weapon", false)):
				return d["hand"]
		return nodes[0] + Vector2(facing * rad[0] * 1.4, rad[0] * 0.4)
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
		var ctr: Vector2
		if c.placed and c.nodes.size() > 2:
			var torso: Vector2 = c.nodes[mini(2, c.nodes.size() - 1)]
			ctr = torso + Vector2(f * c.size_px.x * (0.22 + 0.12 * raise), -h * 0.02 - h * 0.10 * raise)
		else:
			ctr = c.map_point(origin + Vector2(0.0, -c.hover()), Vector2(0.52, -0.42 - 0.12 * raise))
		var sw: float = c.size_px.x * 0.46
		var sh: float = h * 0.52
		var board := PackedVector2Array([
			ctr + Vector2(-sw * 0.5, -sh * 0.5), ctr + Vector2(sw * 0.5, -sh * 0.55),
			ctr + Vector2(sw * 0.55, sh * 0.35), ctr + Vector2(0.0, sh * 0.6), ctr + Vector2(-sw * 0.55, sh * 0.35)])
		StoneStoryInk.fill(ci, board, wood, stats)
		StoneStoryInk.edge(ci, board, edge, 1.4)
		StoneStoryInk.disc(ci, ctr, maxf(2.5, sw * 0.16), fire, stats)
