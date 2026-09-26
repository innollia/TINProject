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
## 몸통 축 기본 길이(월드 단위). 다리 수에 비례해 조금 커진다.
const BODY_SPAN: float = 22.0

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

	# shape 블록은 **놀랍다 공식의 설명자**다. 형체 기하의 스케일로 재 쓰지 않는다.
	# 형체 크기는 여기서 정한다. 다리가 많으면 크고, 동그라우면 뭉툭하다.
	var span: float = BODY_SPAN * lerpf(0.75, 1.35, clampf(float(limbs) / 12.0, 0.0, 1.0))
	var body_r: float = span * lerpf(0.20, 0.34, round)
	var parts: Array = []

	# 0 몸통
	parts.append({
		"length": span, "base_radius": body_r, "tip_radius": body_r * lerpf(0.45, 0.9, round),
		"at": 0.0, "angle": 0.0, "scale": 1.0,
	})
	# 1 머리. 틀림이 높을수록 축에서 벗어난다.
	parts.append({
		"length": body_r * 0.9, "base_radius": body_r * 0.62, "tip_radius": body_r * 0.34,
		"at": 1.0, "angle": wrong * 70.0, "scale": 1.0,
	})
	# 2 꼬리. 다리 1개짜리는 없다.
	if limbs > 1:
		parts.append({
			"length": span * 0.30, "base_radius": body_r * 0.36, "tip_radius": body_r * 0.07,
			"at": 0.0, "angle": -wrong * 50.0 - 30.0, "scale": 1.0,
		})
	# 3.. 다리. 많으면 방사형으로 촘촘히.
	var limb_count: int = limbs
	for i in limb_count:
		var side: float = 1.0 if (i % 2 == 0) else -1.0
		var fan: float = lerpf(80.0, 26.0, round) + float(i) * 4.0
		parts.append({
			"length": span * (0.30 + 0.03 * float(i % 3)),
			"base_radius": maxf(0.9, body_r * 0.18),
			"tip_radius": maxf(0.5, body_r * 0.07),
			"at": clampf(0.18 + 0.62 * float(i) / maxf(1.0, float(limb_count - 1)), 0.12, 0.95),
			"angle": side * fan + wrong * 10.0 * float(i % 3),
			"scale": 1.0,
		})

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
		"jitter": 0.0,
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


## 파트 구분을 돌려준다. _spec() 의 순서와 같은 인덱스.
## 0 = 몸통, 1 = 머리, 2 = 꼬리, 3.. = 다리
func part_role(index: int) -> StringName:
	if index == 0:
		return &"body"
	if index == 1:
		return &"head"
	if index == 2:
		return &"tail"
	return &"limb"


## 몸통 축 위의 위치(0..1). 다리는 여기서 뻗는다.
func body_axis(index: int) -> float:
	if shape == null or shape.rest.is_empty():
		return 0.5
	var a: Vector2 = shape.rest[0]
	var b: Vector2 = shape.rest[shape.node_count() - 1]
	var p: Vector2 = shape.rest[clampi(index, 0, shape.node_count() - 1)]
	if a.distance_squared_to(b) < 0.0001:
		return 0.0
	return clampf(a.distance_to(p) / a.distance_to(b), 0.0, 1.0)


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
