class_name StoneStoryBackdrop
extends RefCounted

## 배경도 형체다. 3-겹 깊이 띠.
##
## PVE 의 ProceduralBackdropDynamics 가 배경 요소를 각각 chain + force(바람) +
## 시야 오프셋으로 다룬다. 그 정규 형상(to_shape)의 points 를 읽어 그린다.
## PVE 팩토리(make_backdrop)는 WAVE 1 스텁이므로 쓰지 않는다.

enum Band { FAR, MID, NEAR }

const BANDS: Array[int] = [Band.FAR, Band.MID, Band.NEAR]
const BAND_PVE_LAYER: Dictionary = {
	Band.FAR: ProceduralBackdropDynamics.Layer.FAR,
	Band.MID: ProceduralBackdropDynamics.Layer.MID,
	Band.NEAR: ProceduralBackdropDynamics.Layer.NEAR,
}
const PARALLAX: Array[float] = [0.25, 0.55, 1.0]
## DENSITY: bg1 라운드 근거 3단계. 원경 -> 중경 -> 근경
const DENSITY: Array[int] = [2, 1, 0]      # mood / navigation / evidence
const STIFFNESS: Array[float] = [30.0, 60.0, 120.0]
const DAMPING: Array[float] = [0.85, 0.60, 0.35]
const AMPLITUDE: Array[float] = [2.0, 4.0, 7.0]
const COUNT: Array[int] = [18, 26, 34]

var dynamics: Dictionary = {}       # Band -> ProceduralBackdropDynamics
var rest_positions: Dictionary = {} # Band -> PackedVector2Array
var band_of_point: Dictionary = {}   # Band -> PackedInt32Array


func build(region_id: String, world_seed: int) -> void:
	dynamics.clear()
	rest_positions.clear()
	band_of_point.clear()
	for b in BANDS:
		var s: StoneStoryRng = StoneStoryCore.stream(world_seed,
				StoneStoryCore.TAG_TEXTURE + "." + region_id + "." + str(b))
		var dyn := ProceduralBackdropDynamics.new(BAND_PVE_LAYER[b])
		dyn.configure(PARALLAX[b], AMPLITUDE[b], STIFFNESS[b], DAMPING[b])
		var field: ProceduralNoiseField = Procedural.make_noise(s.child(0), ProceduralNoiseField.FIELD_DETAIL)
		dyn.attach_field(field, ProceduralBackdropDynamics.DEFAULT_PHASE_SPEED)
		dyn.set_anchor_capacity(COUNT[b] + 2)
		for i in COUNT[b]:
			dyn.add_anchor(Vector2(
					float(s.range_int(i, -960, 960)),
					float(s.range_int(i + 313, -140, 140))))
		dynamics[b] = dyn
		_snap(b, dyn)


func _snap(b: int, dyn: ProceduralBackdropDynamics) -> void:
	var pts := PackedVector2Array()
	var idx := PackedInt32Array()
	for i in dyn.get_anchor_count():
		pts.append(dyn.get_rest_position(i))
		idx.append(dyn.get_node_index(i))
	rest_positions[b] = pts
	band_of_point[b] = idx


func step(delta: float) -> void:
	for b in BANDS:
		var dyn: ProceduralBackdropDynamics = dynamics.get(b, null)
		if dyn != null:
			dyn.step(delta)


func set_view_offset(v: Vector2) -> void:
	for b in BANDS:
		var dyn: ProceduralBackdropDynamics = dynamics.get(b, null)
		if dyn != null:
			dyn.set_view_offset(v)


## ��대별로 그릴 점 배열. 카메라 오프셋과 시차가 이미 들어 있다.
func draw_points(b: int) -> PackedVector2Array:
	var dyn: ProceduralBackdropDynamics = dynamics.get(b, null)
	if dyn == null:
		return PackedVector2Array()
	var out := PackedVector2Array()
	for i in dyn.get_anchor_count():
		out.append(dyn.get_rest_position(i) + dyn.get_offset(i))
	return out


func density_role(b: int) -> int:
	return DENSITY[clampi(b, 0, DENSITY.size() - 1)]


## 근경 -> 원경 순으로 그린다. 뒤에 있는 것이 먼저.
static func draw_order() -> Array[int]:
	return [Band.NEAR, Band.MID, Band.FAR]
