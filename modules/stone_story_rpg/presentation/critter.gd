class_name StoneStoryCritter
extends RefCounted

## 4-속성 개체의 형체와 움직임.
##
## PVE 의 정규 형상(ProceduralShape)을 쓴다. 픽셀 합성 API(build_sprite 등)는
## WAVE 1 스텁이므로 쓰지 않는다. 대신 스텁이 지정한 우회로를 따른다:
## **shape 를 step 하고 points 를 읽는다.**
##
## 4-속성이 형체를 만든다:
##   다리     -> 다리 파트의 개수와 길이. 많으면 1턴 여러 번 (§ actions_per_turn)
##   동그라미 -> 파트의 각도. 0도에 가까울수록 동글다
##   틀림     -> 부품이 축에서 벗어나 있는 정도
##   놀랍다  -> 리듬(세이브 오프셋). 예측 불가일수록 흔들린다

const PART_KINDS: Array[String] = ["limb", "body", "head", "tail", "crown"]

var shape: ProceduralShape = null
var attrs: Dictionary = {}
var seed_value: int = 0
var _bob: float = 0.0
var _phase: float = 0.0


## content 의 attributes + shape 로부터 형체를 만든다.
static func build(foe_id: String, attrs: Dictionary, shape_hint: Dictionary,
		seed_value: int) -> StoneStoryCritter:
	var c := StoneStoryCritter.new()
	c.attrs = attrs.duplicate()
	c.seed_value = seed_value
	c.shape = ProceduralShape.new()
	var spec: Dictionary = _spec(foe_id, c.attrs, shape_hint, seed_value)
	if not c.shape.build_from_spec(spec):
		# 스펙이 잘못되면 최소 형태를 준다. 크래시시키지 않는다.
		c.shape = ProceduralShape.new()
		c.shape.build_from_spec(_spec("stone_fallback", {"limbs": 1, "roundness": 5.0}, {}, seed_value))
	c._phase = float(seed_value % 628) / 100.0
	return c


static func _spec(shape_id: String, attrs: Dictionary, hint: Dictionary, seed_value: int) -> Dictionary:
	var limbs: int = StoneStoryAttributes.clamp_limbs(int(attrs.get(StoneStoryAttributes.LIMBS, 1)))
	var round: float = clampf(float(attrs.get(StoneStoryAttributes.ROUND, 0.0)) / 10.0, 0.0, 1.0)
	var wrong: float = clampf(float(attrs.get(StoneStoryAttributes.WRONGNESS, 0.0)) / 10.0, 0.0, 1.0)
	var motion: float = clampf(float(hint.get("motion_events", 0)) / 12.0, 0.0, 1.0)

	var w: float = maxf(2.0, float(hint.get("width_units", 20.0)))
	var h: float = maxf(2.0, float(hint.get("height_units", 20.0)))
	var parts: Array = []

	# 몸통. 동그라미가 높을수록 더 뭉툭하고 짧다.
	var body_r: float = h * lerpf(0.34, 0.50, round)
	parts.append({
		"length": h, "base_radius": body_r, "tip_radius": body_r * lerpf(0.55, 0.95, round),
		"at": 0.0, "angle": 0.0, "scale": 1.0,
	})
	# 머리. 틀림이 높을수록 옆으로 치우친다.
	var head_off: float = wrong * w * 0.35
	parts.append({
		"length": body_r * 0.9, "base_radius": body_r * 0.55, "tip_radius": body_r * 0.30,
		"at": 1.0, "angle": head_off, "scale": 1.0,
	})
	# 꼬리. 다리 1개짜리는 꼬리가 없다(발이 대신).
	if limbs > 1:
		parts.append({
			"length": h * 0.35, "base_radius": body_r * 0.32, "tip_radius": body_r * 0.08,
			"at": 0.0, "angle": -head_off * 0.6, "scale": 1.0,
		})

	# 다리. many-legged 은 방사형, 적은 좌우.
	for i in limbs:
		var side: float = 1.0 if (i % 2 == 0) else -1.0
		var spread: float = float(i) * (w * 0.30)
		parts.append({
			"length": h * (0.34 + 0.04 * float(i % 3)),
			"base_radius": maxf(1.0, body_r * 0.16),
			"tip_radius": maxf(0.6, body_r * 0.08),
			"at": clampf(0.12 + spread / maxf(w, 1.0), 0.05, 0.95),
			"angle": side * lerpf(70.0, 24.0, round) + wrong * 12.0 * float(i % 2),
			"scale": 1.0,
		})

	# 놀랍다 = 예측 불가일수록 리듬이 크다
	var jitter: float = 0.0
	var surprise: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	if surprise > 0.0:
		jitter = (surprise / 10.0) * 6.0 * (0.4 + motion)

	return {
		"version": Procedural.ENGINE_VERSION,
		"id": shape_id,
		"kind": "rigid",
		"collider": false,
		"physics": {
			"stiffness": lerpf(60.0, 220.0, 1.0 - round),
			"damping": lerpf(0.35, 0.80, wrong),
			"coupling": 0.35,
			"force": [0.0, 0.0],
			"max_substep": 1.0 / 240.0,
		},
		"parts": parts,
		"jitter": jitter,
	}


func step(delta: float) -> void:
	if shape != null:
		shape.step(delta)
	_bob += delta * (2.0 + 0.6 * float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0)))
	# 예측 불가할수록 위아래 흔들림이 크다
	_bob += sin(_phase) * 0.0001


## 정규 배열. 복사본이 아니라 그 자체. (PVE 계약)
func points() -> PackedVector2Array:
	return shape.points if shape != null else PackedVector2Array()


func radii() -> PackedFloat32Array:
	return shape.radius if shape != null else PackedFloat32Array()


func bob_offset() -> float:
	var surprise: float = float(attrs.get(StoneStoryAttributes.SURPRISE, 0.0))
	return sin(_bob * 3.0) * (0.5 + surprise * 0.6)


func node_count() -> int:
	return shape.node_count() if shape != null else 0


## 화면 배치에 필요한 세로 크기. 정규 배열에서 직접 잰다.
func extent_y() -> float:
	var pts := points()
	if pts.is_empty():
		return 24.0
	var lo: float = pts[0].y
	var hi: float = pts[0].y
	for i in pts.size():
		lo = minf(lo, pts[i].y)
		hi = maxf(hi, pts[i].y)
	return (hi - lo) + 6.0


func extent_x() -> float:
	var pts := points()
	if pts.is_empty():
		return 24.0
	var lo: float = pts[0].x
	var hi: float = pts[0].x
	for i in pts.size():
		lo = minf(lo, pts[i].x)
		hi = maxf(hi, pts[i].x)
	return (hi - lo) + 6.0
