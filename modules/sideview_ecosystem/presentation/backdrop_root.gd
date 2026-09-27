class_name EcoBackdropRoot
extends Node2D

## §5.1, §9.12, §11.2. 5층 배경. 각 레이어는 ProceduralBackdropDynamics 1개.
## 모양은 판·막·층·기둥(사각·캡슐 SDF)뿐. 색은 §9.9 팔레트 역할만.

const LAYER_SPECS: Array = [
	{"layer": "sky", "parallax": 0.06, "amplitude": 3.0, "phase": 6.0},
	{"layer": "far", "parallax": 0.22, "amplitude": 6.0, "phase": 9.0},
	{"layer": "mid", "parallax": 0.50, "amplitude": 9.0, "phase": 12.0},
	{"layer": "near", "parallax": 0.78, "amplitude": 13.0, "phase": 15.0},
	{"layer": "foreground", "parallax": 1.12, "amplitude": 18.0, "phase": 18.0},
]

var layers: Array[ProceduralBackdropDynamics] = []
var palette: ProceduralPalette
var _room_w_px: float = 0.0
var _room_h_px: float = 0.0
var _world_seed: int = 0


func setup(world_seed: int, region_index: int, room_w_px: float, room_h_px: float) -> void:
	_world_seed = world_seed
	_room_w_px = room_w_px
	_room_h_px = room_h_px
	var stream: ProceduralSeed = Procedural.derive_seed(world_seed, "eco_backdrop_%d" % region_index)
	palette = Procedural.make_palette(stream, region_index)
	layers.clear()
	for spec: Dictionary in LAYER_SPECS:
		var built: ProceduralBackdropDynamics = Procedural.make_backdrop({
			"seed_id": "eco_backdrop_field_%s" % spec["layer"],
			"seed": world_seed,
			"layer": spec["layer"],
			"parallax": spec["parallax"],
			"field": "detail",
			"field_amplitude": spec["amplitude"],
			"phase_speed": spec["phase"],
			"anchors": _anchor_positions(spec["layer"]),
		})
		layers.append(built)
	queue_redraw()


func _anchor_positions(layer_name: String) -> Array:
	var count: int = 18
	match layer_name:
		"sky":
			count = 18
		"far", "mid":
			count = 24
		"near", "foreground":
			count = 30
	var out: Array = []
	for index: int in count:
		var t: float = float(index) / float(maxi(count - 1, 1))
		out.append(Vector2(_room_w_px * t, _room_h_px * (0.15 + 0.7 * (t - floor(t)))))
	return out


func set_view_offset(offset: Vector2) -> void:
	for layer: ProceduralBackdropDynamics in layers:
		layer.set_view_offset(offset)


func pulse(strength: float) -> void:
	for layer: ProceduralBackdropDynamics in layers:
		layer.pulse(strength)


func step(delta: float) -> void:
	for layer: ProceduralBackdropDynamics in layers:
		layer.step(delta)
	queue_redraw()


func _draw() -> void:
	if palette == null:
		return
	for index: int in layers.size():
		var layer: ProceduralBackdropDynamics = layers[index]
		var role: StringName = ProceduralPalette.ROLE_SKY_FAR if index < 2 else (ProceduralPalette.ROLE_SKY_NEAR if index < 4 else ProceduralPalette.ROLE_GROUND)
		var color: Color = palette.get_color(role)
		for anchor_index: int in layer.get_anchor_count():
			var rest: Vector2 = layer.get_rest_position(anchor_index)
			var live: Vector2 = rest + layer.get_offset(anchor_index)
			draw_rect(Rect2(live - Vector2(6.0, 3.0), Vector2(12.0, 6.0)), color, true)
