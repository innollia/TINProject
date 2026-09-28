# PVE 공개 계약표 — PROCEDURAL CONTRACT DUMP 출력

> 이 파일은 손으로 쓰지 않는다. 설계 정본은 `DESIGN_DECISION.md`, 목록은
> `tools/procedural_contract_dump.gd` 가 엔진에서 직접 읽어 뽑은 것이다.
> 재생성: godot --headless --script res://tools/procedural_contract_dump.gd --dump
> ENGINE_VERSION = 2
> 기본값 인자는 도구가 `<default>` 로 찍는다. 실제 값은 소스를 봐라.
> `worldstate` 계열은 `core/worldstate/CONTRACT.md` 가 담당한다.

── Procedural (res://core/procedural/procedural.gd) extends RefCounted
   const ENGINE_VERSION: int
   static func derive_seed(world_seed: int, id: String, version: int = <default>) -> ProceduralSeed  [min 2, max 3]
   static func make_noise(stream: ProceduralSeed, field: StringName = <default>) -> ProceduralNoiseField  [min 1, max 2]
   static func make_palette(stream: ProceduralSeed, variant: int = <default>) -> ProceduralPalette  [min 1, max 2]
   static func make_canvas(width: int, height: int) -> ProceduralCanvas  [min 2, max 2]
   static func build_sprite(_spec: Dictionary) -> ImageTexture  [min 1, max 1]
   static func render_frame(_spec: Dictionary) -> ImageTexture  [min 1, max 1]
   static func make_rig(_spec: Dictionary) -> ProceduralSquishRig  [min 1, max 1]
   static func make_backdrop(_spec: Dictionary) -> ProceduralBackdropDynamics  [min 1, max 1]

── ProceduralBackdropDynamics (res://core/procedural/anim/backdrop_dynamics.gd) extends RefCounted
   enum Layer { SKY, FAR, MID, NEAR, FOREGROUND }
   const DEFAULT_PARALLAX: float
   const DEFAULT_STIFFNESS: float
   const DEFAULT_DAMPING_RATIO: float
   const DEFAULT_PHASE_SPEED: float
   var layer: Layer
   var parallax: float
   var wind: Vector2
   var wind_gain: float
   var view_offset: Vector2
   var field: ProceduralNoiseField
   var field_amplitude: float
   var shape: ProceduralShape
   var index: int
   var node: int
   var shared: Vector2
   func _init(p_layer: Layer = <default>) -> void  [min 0, max 1]
   func add_anchor(rest_world_position: Vector2) -> int  [min 1, max 1]
   func set_anchor_capacity(capacity: int) -> bool  [min 1, max 1]
   func get_anchor_count() -> int  [min 0, max 0]
   func get_rest_position(index: int) -> Vector2  [min 1, max 1]
   func get_offset(index: int) -> Vector2  [min 1, max 1]
   func configure(p_parallax: float, p_field_amplitude: float, stiffness: float, damping_ratio: float) -> void  [min 4, max 4]
   func attach_field(p_field: ProceduralNoiseField, phase_speed: float = <default>) -> void  [min 1, max 2]
   func set_view_offset(offset: Vector2) -> void  [min 1, max 1]
   func set_wind(p_wind: Vector2, gain: float = <default>) -> void  [min 1, max 2]
   func pulse(strength: float) -> void  [min 1, max 1]
   func step(delta: float) -> void  [min 1, max 1]
   func reset() -> void  [min 0, max 0]
   func to_shape() -> ProceduralShape  [min 0, max 0]
   func get_node_index(anchor_index: int) -> int  [min 1, max 1]

── ProceduralBodyPart (res://core/procedural/sprite/body_part.gd) extends RefCounted
   enum Kind { LIMB, TORSO, HEAD, EYE, TAIL, FIN, FOLD, CAP }
   enum Joint { NONE, ROOT, MIDDLE, TIP }
   enum Shade { FLAT, VOLUMETRIC, RIM, INK }
   enum SegmentKind { CAPSULE, TRIANGLE, BOX }
   const KIND_NAMES: Dictionary
   const JOINT_NAMES: Dictionary
   const SHADE_NAMES: Dictionary
   const SEGMENT_NAMES: Dictionary
   const DEFAULT_LENGTH: float
   const DEFAULT_BASE_RADIUS: float
   const DEFAULT_TIP_RADIUS: float
   const DEFAULT_FUSION: float
   const MAX_SQUASH_LOCAL: float
   var id: StringName
   var kind: Kind
   var joint: Joint
   var shade: Shade
   var length: float
   var base_radius: float
   var tip_radius: float
   var bend: float
   var wiggle: float
   var body_role: StringName
   var shade_role: StringName
   var rim_role: StringName
   var joint_id: StringName
   var at: float
   var angle: float
   var scale: float
   var anchor_mode: int
   var anchor_parent: int
   var anchor_offset: Vector2
   var segments: Array
   var fusion: float
   var raw_kind: Variant
   var raw_joint: Variant
   var raw_shade: Variant
   var anchor: Dictionary
   var pair: Variant
   var out: PackedVector2Array
   var steps: int
   var curve: float
   var along: float
   var turned: float
   var wave: float
   var base: Vector2
   var joints: PackedVector2Array
   var out: PackedVector2Array
   var steps: int
   var curve: float
   var endpoints: PackedVector2Array
   var count: int
   var distance: float
   var from_joint: Vector2
   var to_joint: Vector2
   var start_t: float
   var end_t: float
   var start_radius: float
   var end_radius: float
   var w0: float
   var w1: float
   var w2: float
   var inside: bool
   var edge: float
   var axis: Vector2
   var length_sq: float
   var t: float
   var centre: Vector2
   var radius: float
   var endpoints: PackedVector2Array
   var extent: float
   var minimum: Vector2
   var maximum: Vector2
   var origin: Vector2
   var rotation: float
   var scale_factor: float
   var squash: float
   var extent: Rect2
   var along_scale: float
   var across_scale: float
   var span: Rect2
   var bounds_px: Rect2i
   var body_color: Color
   var shade_color: Color
   var field: Callable
   var centre: Vector2
   var shade_field: Callable
   var moved: Vector2
   var corners: PackedVector2Array
   var minimum: Vector2
   var maximum: Vector2
   var margin: float
   var left: int
   var top: int
   var right: int
   var bottom: int
   var copy: ProceduralBodyPart
   func _init(p_id: StringName = <default>, p_kind: Kind = <default>) -> void  [min 0, max 2]
   func configure(spec: Dictionary) -> void  [min 1, max 1]
   func _configure_anchor(raw: Variant) -> void  [min 1, max 1]
   func rest_joints() -> PackedVector2Array  [min 0, max 0]
   func _joint_at(t: float) -> Vector2  [min 1, max 1]
   func segment_endpoints() -> PackedVector2Array  [min 0, max 0]
   func max_radius() -> float  [min 0, max 0]
   func axis() -> Vector2  [min 0, max 0]
   func segment_count() -> int  [min 0, max 0]
   func segment_kind(index: int) -> int  [min 1, max 1]
   func radius_at(t: float) -> float  [min 1, max 1]
   func field_at(point: Vector2) -> float  [min 1, max 1]
   func _fuse(current: float, incoming: float, blend: float) -> float  [min 3, max 3]
   static func _cross(a: Vector2, b: Vector2) -> float  [min 2, max 2]
   func bounds() -> Rect2  [min 0, max 0]
   func draw(canvas: ProceduralCanvas, palette: ProceduralPalette, pose: Dictionary = <default>) -> void  [min 2, max 3]
   func _field_transformed(origin: Vector2, rotation: float, along_scale: float, across_scale: float) -> Callable  [min 4, max 4]
   func _to_canvas_rect(span: Rect2, origin: Vector2, rotation: float, canvas: ProceduralCanvas) -> Rect2i  [min 4, max 4]
   func joint_anchor_spec() -> Dictionary  [min 0, max 0]
   func get_kind_name() -> StringName  [min 0, max 0]
   func get_joint_name() -> StringName  [min 0, max 0]
   func get_shade_name() -> StringName  [min 0, max 0]
   func to_dictionary() -> Dictionary  [min 0, max 0]
   func duplicate_part() -> ProceduralBodyPart  [min 0, max 0]
   func body_color(palette: ProceduralPalette) -> Color  [min 1, max 1]
   func shade_color(palette: ProceduralPalette) -> Color  [min 1, max 1]
   func rim_color(palette: ProceduralPalette) -> Color  [min 1, max 1]
   static func kind_from_name(name: StringName) -> Kind  [min 1, max 1]
   static func joint_from_name(name: StringName) -> Joint  [min 1, max 1]
   static func shade_from_name(name: StringName) -> Shade  [min 1, max 1]
   static func segment_kind_from_name(name: StringName) -> int  [min 1, max 1]
   static func joint_to_at(joint_name: StringName) -> float  [min 1, max 1]
   static func _lookup(table: Dictionary, name: StringName, fallback: int) -> int  [min 3, max 3]

── ProceduralCanvas (res://core/procedural/raster/canvas.gd) extends RefCounted
   var width: int
   var height: int
   var pixels: PackedByteArray
   var r: int
   var g: int
   var b: int
   var a: int
   var index: int
   var total: int
   var index: int
   var index: int
   var src_a: float
   var index: int
   var dst_r: float
   var dst_g: float
   var dst_b: float
   var dst_a: float
   var out_a: float
   var carry: float
   var left: int
   var top: int
   var right: int
   var bottom: int
   var y: int
   var x: int
   var radius: float
   var steps: int
   var point: Vector2
   var top: int
   var bottom: int
   var scan: float
   var crossings: PackedFloat32Array
   var last: int
   var a: Vector2
   var b: Vector2
   var t: float
   var pair: int
   var x0: int
   var x1: int
   var rx: float
   var ry: float
   var top: int
   var bottom: int
   var dy: float
   var span: float
   var left: int
   var right: int
   var span: int
   var scratch: PackedByteArray
   var steps: int
   var index: int
   var total: int
   var start_x: int
   var start_y: int
   var from_x: int
   var from_y: int
   var span_x: int
   var span_y: int
   var from: int
   var to: int
   var min_x: int
   var min_y: int
   var max_x: int
   var max_y: int
   var level: int
   var lowest: float
   var highest: float
   var top: int
   var bottom: int
   var dy: float
   var span: float
   var left: int
   var right: int
   var outer: int
   var inner: int
   var red: int
   var green: int
   var blue: int
   var alpha: int
   var count: int
   var sample: int
   var x: int
   var y: int
   var base: int
   var divisor: float
   var base_out: int
   func _init(p_width: int = <default>, p_height: int = <default>) -> void  [min 0, max 2]
   func fill(color: Color) -> void  [min 1, max 1]
   func clear() -> void  [min 0, max 0]
   func is_inside(x: int, y: int) -> bool  [min 2, max 2]
   func set_pixel(x: int, y: int, color: Color) -> void  [min 3, max 3]
   func get_pixel(x: int, y: int) -> Color  [min 2, max 2]
   func blend_pixel(x: int, y: int, color: Color, alpha: float = <default>) -> void  [min 3, max 4]
   func fill_rect(rect: Rect2i, color: Color, alpha: float = <default>) -> void  [min 2, max 3]
   func draw_line(from: Vector2, to: Vector2, color: Color, thickness: float = <default>) -> void  [min 3, max 4]
   func draw_polygon(points: PackedVector2Array, color: Color) -> void  [min 2, max 2]
   func draw_circle(center: Vector2, radius: float, color: Color) -> void  [min 3, max 3]
   func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void  [min 3, max 3]
   func blur(radius: int) -> void  [min 1, max 1]
   func posterize(levels: int) -> void  [min 1, max 1]
   func copy_from(source: ProceduralCanvas) -> void  [min 1, max 1]
   func shift(source: ProceduralCanvas, offset: Vector2i) -> void  [min 2, max 2]
   func get_used_rect() -> Rect2i  [min 0, max 0]
   func to_image() -> Image  [min 0, max 0]
   func to_texture() -> ImageTexture  [min 0, max 0]
   func _offset(x: int, y: int) -> int  [min 2, max 2]
   func _channel(value: float) -> int  [min 1, max 1]
   func _quantize(byte_value: float, steps: int) -> int  [min 2, max 2]
   func _minimum_y(points: PackedVector2Array) -> float  [min 1, max 1]
   func _maximum_y(points: PackedVector2Array) -> float  [min 1, max 1]
   func _stamp_disc(center: Vector2, radius: float, color: Color) -> void  [min 3, max 3]
   func _blur_axis(source: PackedByteArray, target: PackedByteArray, span: int, horizontal: bool) -> void  [min 4, max 4]

── ProceduralCreatureBuilder (res://core/procedural/sprite/creature_builder.gd) extends RefCounted
   const MARGIN: int
   var canvas_size: Vector2i
   var outline_role: StringName
   var outline_width: float
   var squash: float
   var facing: int
   var palette: ProceduralPalette
   var parts: Array
   var shape: ProceduralShape
   var ids: Array
   var built: ProceduralShape
   var part: ProceduralBodyPart
   var mode: int
   var parent: int
   var canvas: ProceduralCanvas
   var union: Callable
   var region: Rect2i
   var centre: Vector2
   var shade_call: Callable
   var extent: Rect2
   var centre: Vector2
   var wanted: Vector2
   var minimum: Vector2
   var maximum: Vector2
   var extent: Rect2
   var origin: Vector2
   var world_angle: float
   var moved: Vector2
   var union: Callable
   var entries: Array
   var best: float
   var local: Vector2
   var canvas_origin: Vector2
   var origin: Vector2
   var rotated: Vector2
   var across: float
   var along: float
   var clamped: float
   var built: ProceduralShape
   var index: int
   var index: int
   var extent: Rect2
   var left: int
   var top: int
   var right: int
   var bottom: int
   var out: PackedVector2Array
   var origin: Vector2
   var corners: PackedVector2Array
   var values: PackedFloat32Array
   var crossings: PackedVector2Array
   var a: Vector2
   var b: Vector2
   var fa: float
   var fb: float
   var t: float
   func _init(p_canvas_size: Vector2i = <default>)  [min 0, max 1]
   func add_part(part: ProceduralBodyPart) -> void  [min 1, max 1]
   func remove_part(part_id: StringName) -> bool  [min 1, max 1]
   func get_part(part_id: StringName) -> ProceduralBodyPart  [min 1, max 1]
   func get_part_ids() -> Array[StringName]  [min 0, max 0]
   func set_palette(value: ProceduralPalette) -> void  [min 1, max 1]
   func _invalidate() -> void  [min 0, max 0]
   func to_shape() -> ProceduralShape  [min 0, max 0]
   func is_bakeable() -> bool  [min 0, max 0]
   func compose_canvas() -> ProceduralCanvas  [min 0, max 0]
   func _place_in_canvas() -> void  [min 0, max 0]
   func _shape_bounds() -> Rect2  [min 0, max 0]
   func outline() -> PackedVector2Array  [min 0, max 0]
   func compose() -> ImageTexture  [min 0, max 0]
   func derive_collider() -> Dictionary  [min 0, max 0]
   func describe() -> Dictionary  [min 0, max 0]
   func _fused_field() -> Callable  [min 0, max 0]
   func _to_local(canvas_point: Vector2, part: ProceduralBodyPart) -> Vector2  [min 2, max 2]
   func _part_index(part: ProceduralBodyPart) -> int  [min 1, max 1]
   func _part_origin(part: ProceduralBodyPart) -> Vector2  [min 1, max 1]
   func _part_world_angle(part: ProceduralBodyPart) -> float  [min 1, max 1]
   func _union_rect() -> Rect2i  [min 0, max 0]
   func _marching_squares(field: Callable, region: Rect2i, level: float) -> PackedVector2Array  [min 3, max 3]

── ProceduralDeformField (res://core/procedural/anim/deform_field.gd) extends RefCounted
   const DEFAULT_AMPLITUDE: float
   const DEFAULT_STIFFNESS: float
   const DEFAULT_DAMPING_RATIO: float
   const DEFAULT_FLOW: Vector2
   var width: int
   var height: int
   var bounds: Rect2
   var amplitude: float
   var wind: Vector2
   var wind_gain: float
   var flow: Vector2
   var noise: ProceduralNoiseField
   var shape: ProceduralShape
   var columns: int
   var rows: int
   var rest: PackedVector2Array
   var points: PackedVector2Array
   var origin: Vector2
   var indices: PackedInt32Array
   var top_left: int
   var top_right: int
   var bottom_left: int
   var bottom_right: int
   var fx: float
   var fy: float
   var x0: int
   var y0: int
   var x1: int
   var y1: int
   var tx: float
   var ty: float
   var top: Vector2
   var bottom: Vector2
   func _init(p_width: int = <default>, p_height: int = <default>) -> void  [min 0, max 2]
   func build_grid(p_width: int, p_height: int, rect: Rect2) -> void  [min 3, max 3]
   func configure(p_amplitude: float, stiffness: float, damping_ratio: float) -> void  [min 3, max 3]
   func set_coupling(coupling: float) -> void  [min 1, max 1]
   func get_coupling() -> float  [min 0, max 0]
   func bind_noise(field: ProceduralNoiseField) -> void  [min 1, max 1]
   func set_wind(p_wind: Vector2, gain: float = <default>) -> void  [min 1, max 2]
   func excite(pulse: float, radius: float, center: Vector2 = <default>) -> void  [min 2, max 3]
   func step(delta: float) -> void  [min 1, max 1]
   func reset() -> void  [min 0, max 0]
   func get_vertex_count() -> int  [min 0, max 0]
   func get_grid_size() -> Vector2i  [min 0, max 0]
   func get_point(u: float, v: float) -> Vector2  [min 2, max 2]
   func get_offset(u: float, v: float) -> Vector2  [min 2, max 2]
   func build_triangles() -> PackedInt32Array  [min 0, max 0]
   func to_shape() -> ProceduralShape  [min 0, max 0]
   func collect_contacts(world_point: Vector2, query_radius: float) -> PackedInt32Array  [min 2, max 2]
   func is_bakeable() -> bool  [min 0, max 0]
   func _sample(source: PackedVector2Array, u: float, v: float) -> Vector2  [min 3, max 3]

── ProceduralNoiseField (res://core/procedural/noise_field.gd) extends RefCounted
   const FIELD_SHAPE: StringName
   const FIELD_DETAIL: StringName
   const FIELD_FLOW: StringName
   const FIELD_SQUISH: StringName
   const DEFAULT_FREQUENCY: float
   const DEFAULT_OCTAVES: int
   const DEFAULT_LACUNARITY: float
   const DEFAULT_GAIN: float
   const SALT_DETAIL: int
   const SALT_FLOW: int
   const PRESETS: Dictionary
   var field: StringName
   var frequency: float
   var octaves: int
   var lacunarity: float
   var gain: float
   var ridged: bool
   var preset: Dictionary
   var fractal_name: StringName
   var noise_name: StringName
   var sx: float
   var sy: float
   var sx: float
   var sy: float
   var noise: FastNoiseLite
   func _init(p_seed: int = <default>, p_field: StringName = <default>) -> void  [min 0, max 2]
   func configure(p_seed: int, p_field: StringName = <default>) -> void  [min 1, max 2]
   func set_phase(phase: Vector2) -> void  [min 1, max 1]
   func get_phase() -> Vector2  [min 0, max 0]
   func advance(delta: float, speed: Vector2) -> void  [min 2, max 2]
   func sample(x: float, y: float) -> float  [min 2, max 2]
   func sample_v(x: float, y: float) -> Vector2  [min 2, max 2]
   func sample3(x: float, y: float) -> Vector3  [min 2, max 2]
   func _make_noise(p_seed: int, fractal_name: StringName, noise_name: StringName, use_ridged: bool) -> FastNoiseLite  [min 4, max 4]
   func _fractal_type_of(fractal_name: StringName, use_ridged: bool) -> int  [min 2, max 2]
   func _noise_type_of(noise_name: StringName) -> int  [min 1, max 1]

── ProceduralPalette (res://core/procedural/palette/palette.gd) extends RefCounted
   const ROLE_KEY_LIGHT: StringName
   const ROLE_SHADE: StringName
   const ROLE_RIM: StringName
   const ROLE_BODY: StringName
   const ROLE_BODY_DARK: StringName
   const ROLE_BELLY: StringName
   const ROLE_ACCENT: StringName
   const ROLE_INK: StringName
   const ROLE_GROUND: StringName
   const ROLE_SKY_NEAR: StringName
   const ROLE_SKY_FAR: StringName
   const ROLE_FOG: StringName
   const ROLE_DANGER: StringName
   const DEFAULT_COLOR: Color
   var roles: Dictionary
   var value: Variant
   var value: Variant
   var names: Array
   var color: Color
   var data: Dictionary
   var color: Color
   var data: Dictionary
   var color: Color
   var copy: ProceduralPalette
   var palette: ProceduralPalette
   var raw: Variant
   var parts: Array
   var alpha: float
   func _init(p_roles: Dictionary = <default>) -> void  [min 0, max 1]
   func has_role(role: StringName) -> bool  [min 1, max 1]
   func get_color(role: StringName) -> Color  [min 1, max 1]
   func get_role_names() -> Array[StringName]  [min 0, max 0]
   func set_role(role: StringName, color: Color) -> void  [min 2, max 2]
   func mix_roles(from_role: StringName, to_role: StringName, weight: float) -> Color  [min 3, max 3]
   func shifted(role: StringName, value_scale: float, saturation_scale: float = <default>) -> Color  [min 2, max 3]
   func to_dictionary() -> Dictionary  [min 0, max 0]
   func to_html_dictionary() -> Dictionary  [min 0, max 0]
   func duplicate_palette() -> ProceduralPalette  [min 0, max 0]
   static func from_dictionary(data: Dictionary) -> ProceduralPalette  [min 1, max 1]

── ProceduralPaletteScheme (res://core/procedural/palette/scheme_builder.gd) extends RefCounted
   const SCHEME_ANALOGOUS: StringName
   const SCHEME_COMPLEMENTARY: StringName
   const SCHEME_SPLIT_COMPLEMENTARY: StringName
   const SCHEME_TRIADIC: StringName
   const SCHEME_TETRADIC: StringName
   const SCHEMES: Array
   const OFFSETS: Dictionary
   const HUE_DANGER: float
   var scheme: StringName
   var base_hue: float
   var saturation: float
   var contrast: float
   var rng: RandomNumberGenerator
   var rng: RandomNumberGenerator
   var names: Array
   var offsets: Array
   var body_hue: float
   var complement_hue: float
   var accent_hue: float
   var neighbour_hue: float
   var palette: ProceduralPalette
   func build(stream: ProceduralSeed, variant: int = <default>) -> ProceduralPalette  [min 1, max 2]
   func build_named(stream: ProceduralSeed, scheme_name: StringName, variant: int = <default>) -> ProceduralPalette  [min 2, max 3]
   func get_scheme_names() -> Array[StringName]  [min 0, max 0]
   func _assemble(scheme_name: StringName, rng: RandomNumberGenerator) -> ProceduralPalette  [min 2, max 2]
   func _hsv(hue: float, sat: float, value: float) -> Color  [min 3, max 3]

── ProceduralSdf (res://core/procedural/raster/sdf.gd) extends RefCounted
   const DEFAULT_FEATHER: float
   var rx: float
   var ry: float
   var pa: Vector2
   var ba: Vector2
   var denom: float
   var h: float
   var d: Vector2
   var nearest: float
   var w0: float
   var w1: float
   var w2: float
   var inside: bool
   var h: float
   var span: float
   var cov: float
   var half: float
   var distance: float
   var cov: float
   var feather: float
   var point: Vector2
   var distance: float
   var cov: float
   static func circle(p: Vector2, center: Vector2, radius: float) -> float  [min 3, max 3]
   static func ellipse(p: Vector2, center: Vector2, radius: Vector2) -> float  [min 3, max 3]
   static func segment(p: Vector2, a: Vector2, b: Vector2) -> float  [min 3, max 3]
   static func capsule(p: Vector2, a: Vector2, b: Vector2, radius: float) -> float  [min 4, max 4]
   static func box(p: Vector2, center: Vector2, half_size: Vector2) -> float  [min 3, max 3]
   static func rounded_box(p: Vector2, center: Vector2, half_size: Vector2, corner: float) -> float  [min 4, max 4]
   static func triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> float  [min 4, max 4]
   static func _cross(a: Vector2, b: Vector2) -> float  [min 2, max 2]
   static func smooth_min(a: float, b: float, blend: float) -> float  [min 3, max 3]
   static func smooth_max(a: float, b: float, blend: float) -> float  [min 3, max 3]
   static func coverage(distance: float, feather: float = <default>) -> float  [min 1, max 2]
   static func stamp_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, color: Color, feather: float = <default>) -> void  [min 4, max 5]
   static func stroke_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, width: float, color: Color) -> void  [min 5, max 5]
   static func shadow_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, offset: Vector2, softness: float, color: Color, strength: float = <default>) -> void  [min 6, max 7]

── ProceduralSeed (res://core/procedural/seed.gd) extends RefCounted
   const DEFAULT_VERSION: int
   const FNV_OFFSET_BASIS: int
   const FNV_PRIME: int
   const MASK_32: int
   const POSITIVE_MASK_31: int
   var world_seed: int
   var id: String
   var version: int
   var value: int
   var rng: RandomNumberGenerator
   var low: float
   var high: float
   var low: int
   var high: int
   var h: int
   var index: int
   var h: int
   var a: int
   var b: int
   var h: int
   func _init(p_world_seed: int = <default>, p_id: String = <default>, p_version: int = <default>) -> void  [min 0, max 3]
   func derive(sub_id: String) -> ProceduralSeed  [min 1, max 1]
   func derive_index(index: int) -> ProceduralSeed  [min 1, max 1]
   func make_rng() -> RandomNumberGenerator  [min 0, max 0]
   func unit() -> float  [min 0, max 0]
   func range_f(from_value: float, to_value: float) -> float  [min 2, max 2]
   func range_i(from_value: int, to_value: int) -> int  [min 2, max 2]
   func chance(probability: float) -> bool  [min 1, max 1]
   func sign_f() -> float  [min 0, max 0]
   func pick(items: Array) -> Variant  [min 1, max 1]
   static func hash_text(text: String) -> int  [min 1, max 1]
   static func hash_int(source: int) -> int  [min 1, max 1]
   static func combine(first: int, second: int) -> int  [min 2, max 2]
   static func mix(first: int, second: int) -> int  [min 2, max 2]
   func _stream() -> RandomNumberGenerator  [min 0, max 0]
   static func _finalize(value: int) -> int  [min 1, max 1]

── ProceduralShape (res://core/procedural/shape.gd) extends RefCounted
   enum Kind { RIGID, SOFT_CHAIN, SOFT_GRID }
   enum AnchorMode { ATTACHED, PINNED, FREE }
   const KIND_RIGID: StringName
   const KIND_SOFT_CHAIN: StringName
   const KIND_SOFT_GRID: StringName
   const MODE_ATTACHED: StringName
   const MODE_PINNED: StringName
   const MODE_FREE: StringName
   const DEFAULT_STIFFNESS: float
   const DEFAULT_DAMPING: float
   const DEFAULT_COUPLING: float
   const DEFAULT_SUBSTEP: float
   const DEFAULT_AT: float
   const MAX_CHAIN_NODES: int
   const MAX_GRID_SIDE: int
   var kind: int
   var spec_id: String
   var spec_hash: int
   var collider_enabled: bool
   var has_deform_field: bool
   var grid_columns: int
   var grid_rows: int
   var rest: PackedVector2Array
   var points: PackedVector2Array
   var radius: PackedFloat32Array
   var links: PackedInt32Array
   var anchor_mode: PackedInt32Array
   var anchor_parent: PackedInt32Array
   var anchor_at: PackedFloat32Array
   var anchor_offset: PackedVector2Array
   var anchor_angle: PackedFloat32Array
   var rest_dir: PackedVector2Array
   var run_dir: PackedVector2Array
   var span: PackedFloat32Array
   var dynamic: PackedByteArray
   var neighbours: PackedInt32Array
   var neighbour_begin: PackedInt32Array
   var target_bias: PackedVector2Array
   var node_ids: Array
   var stiffness: float
   var damping: float
   var coupling: float
   var force: Vector2
   var max_substep: float
   var physics: Dictionary
   var requested: int
   var present: int
   var chain: Array
   var node: Dictionary
   var length: float
   var node_radius: float
   var angle_degrees: float
   var bend: float
   var index: int
   var anchor: Dictionary
   var parts: Array
   var part: Dictionary
   var length: float
   var base_radius: float
   var tip_radius: float
   var at_value: float
   var angle_degrees: float
   var scale_factor: float
   var grid: Dictionary
   var grid_width: int
   var grid_height: int
   var rect: Rect2
   var anchor: Dictionary
   var capacity: int
   var index: int
   var parent: int
   var mode: int
   var index: int
   var parent: int
   var mode: int
   var mode: int
   var parent: int
   var at_value: float
   var offset: Vector2
   var angle_degrees: float
   var columns: int
   var rows: int
   var index: int
   var u: float
   var v: float
   var index: int
   var index: int
   var parent: int
   var base_dir: Vector2
   var parent: int
   var is_dynamic: bool
   var spring: ProceduralSpring.Spring2D
   var spring: ProceduralSpring.Spring2D
   var index: int
   var spring: ProceduralSpring.Spring2D
   var capacity: int
   var previous: int
   var was_grid: bool
   var grown: int
   var out: PackedInt32Array
   var source: String
   var segments: PackedInt32Array
   var circles: PackedInt32Array
   var widths: PackedFloat32Array
   var hits: PackedInt32Array
   var reach: float
   var reach_sq: float
   var hits: PackedInt32Array
   var reach: float
   var spring: ProceduralSpring.Spring2D
   var falloff: float
   var tangent: Vector2
   var spring: ProceduralSpring.Spring2D
   var parent: int
   var local: Vector2
   var follow: Vector2
   var use_coupling: bool
   var drift: bool
   var spring: ProceduralSpring.Spring2D
   var target: Vector2
   var from: int
   var to: int
   var displacement: Vector2
   var other: int
   var assigned: PackedByteArray
   var from_index: int
   var to_index: int
   var travel: Vector2
   var limit: float
   var limit_sq: float
   var spring: ProceduralSpring.Spring2D
   var spring: ProceduralSpring.Spring2D
   var turned: float
   var origin: Vector2
   var travel: Vector2
   var turned: float
   var moved: Vector2
   var parts: Array
   var accumulator: int
   func _init(p_kind: int = <default>) -> void  [min 0, max 1]
   func build_from_spec(spec: Dictionary) -> bool  [min 1, max 1]
   static func _kind_key(p_kind: int) -> StringName  [min 1, max 1]
   func _build_soft_chain(spec: Dictionary) -> bool  [min 1, max 1]
   func _build_rigid(spec: Dictionary) -> bool  [min 1, max 1]
   func _build_soft_grid(spec: Dictionary) -> bool  [min 1, max 1]
   func allocate(node_count: int, p_kind: int) -> bool  [min 2, max 2]
   func node_count() -> int  [min 0, max 0]
   func add_chain_node(length: float, node_radius: float, angle_degrees: float, bend: float) -> bool  [min 4, max 4]
   func add_part(length: float, base_radius: float, tip_radius: float, at_value: float, angle_degrees: float, scale_factor: float) -> bool  [min 6, max 6]
   func set_anchor(index: int, mode: int, parent: int, at_value: float, offset: Vector2, angle_degrees: float) -> bool  [min 6, max 6]
   func _apply_anchor(index: int, anchor: Dictionary, owner_kind: int) -> bool  [min 3, max 3]
   func build_grid(grid_width: int, grid_height: int, rect: Rect2) -> bool  [min 3, max 3]
   func _link(from_index: int, to_index: int) -> void  [min 2, max 2]
   func finalize() -> bool  [min 0, max 0]
   func _allocate_springs() -> void  [min 0, max 0]
   func configure(p_stiffness: float, p_damping: float, p_coupling: float, p_force: Vector2) -> void  [min 4, max 4]
   func set_deform_field_bound(bound: bool) -> void  [min 1, max 1]
   func bind_drift_field(field: ProceduralNoiseField, drift_amplitude: float) -> void  [min 2, max 2]
   func rebuild_springs() -> void  [min 0, max 0]
   func get_points() -> PackedVector2Array  [min 0, max 0]
   func set_target_bias(index: int, bias: Vector2) -> void  [min 2, max 2]
   func kick_node(index: int, impulse: Vector2) -> void  [min 2, max 2]
   func add_free_anchor(rest_world_position: Vector2) -> int  [min 1, max 1]
   func node_id_at(index: int) -> StringName  [min 1, max 1]
   func set_node_stiffness(node: int, node_stiffness: float, node_damping: float) -> void  [min 3, max 3]
   func set_anchor_capacity(capacity: int) -> bool  [min 1, max 1]
   func _grow_capacity(needed: int) -> bool  [min 1, max 1]
   func get_rest() -> PackedVector2Array  [min 0, max 0]
   func get_radius() -> PackedFloat32Array  [min 0, max 0]
   func get_links() -> PackedInt32Array  [min 0, max 0]
   func get_run_dir(index: int) -> Vector2  [min 1, max 1]
   func get_rest_dir(index: int) -> Vector2  [min 1, max 1]
   func get_grid_side_x() -> int  [min 0, max 0]
   func get_grid_side_y() -> int  [min 0, max 0]
   func get_neighbours(index: int) -> PackedInt32Array  [min 1, max 1]
   func derive_collider() -> Dictionary  [min 0, max 0]
   func read_collider_point(collider: Dictionary, node_index: int) -> Vector2  [min 2, max 2]
   func collect_contacts(world_point: Vector2, query_radius: float) -> PackedInt32Array  [min 2, max 2]
   func apply_impulse(world_point: Vector2, query_radius: float, strength: float, direction: Vector2) -> PackedInt32Array  [min 4, max 4]
   func step(delta: float) -> void  [min 1, max 1]
   func _step_chain(delta: float) -> void  [min 1, max 1]
   func _step_grid(delta: float) -> void  [min 1, max 1]
   func _drift_at(index: int) -> Vector2  [min 1, max 1]
   func _update_run_dirs() -> void  [min 0, max 0]
   func _confirm_bake() -> void  [min 0, max 0]
   func is_bakeable() -> bool  [min 0, max 0]
   func require_bakeable() -> bool  [min 0, max 0]
   func points_match_rest(epsilon: float = <default>) -> bool  [min 0, max 1]
   func is_settled(epsilon: float = <default>) -> bool  [min 0, max 1]
   func reset() -> void  [min 0, max 0]
   func get_root_transform() -> Transform2D  [min 0, max 0]
   func set_root_transform(value: Transform2D) -> void  [min 1, max 1]
   static func kind_from_name(name: StringName) -> int  [min 1, max 1]
   static func mode_from_name(name: StringName) -> int  [min 1, max 1]
   static func _joint_to_at(joint: StringName) -> float  [min 1, max 1]
   static func _read_vector(raw: Variant, fallback: Vector2) -> Vector2  [min 2, max 2]
   static func _read_rect(raw: Variant) -> Rect2  [min 1, max 1]
   static func _hash_spec(spec: Dictionary) -> int  [min 1, max 1]

── ProceduralSpring (res://core/procedural/anim/spring.gd) extends RefCounted
   const CRITICAL_DAMPING: float
   const DEFAULT_STIFFNESS: float
   const UNDER_DAMPED_RATIO: float
   const MAX_SUBSTEP: float
   const MAX_SUBSTEPS: int
   var value: float
   var velocity: float
   var target: float
   var stiffness: float
   var damping_ratio: float
   var damping: float
   var steps: int
   var sub_delta: float
   var value: Vector2
   var velocity: Vector2
   var target: Vector2
   var stiffness: float
   var damping_ratio: float
   var damping: float
   var steps: int
   var sub_delta: float
   func _init(p_value: float = <default>, p_stiffness: float = <default>, p_damping_ratio: float = <default>) -> void  [min 0, max 3]
   func configure(p_stiffness: float, p_damping_ratio: float) -> void  [min 2, max 2]
   func set_target(target_value: float) -> void  [min 1, max 1]
   func kick(impulse: float) -> void  [min 1, max 1]
   func snap(value_now: float) -> void  [min 1, max 1]
   func reset() -> void  [min 0, max 0]
   func step(delta: float) -> float  [min 1, max 1]
   func is_settled(epsilon: float = <default>) -> bool  [min 0, max 1]
   static func critical(p_value: float, p_stiffness: float = <default>) -> ProceduralSpring  [min 1, max 2]
   static func under_damped(p_value: float, p_stiffness: float = <default>, p_damping_ratio: float = <default>) -> ProceduralSpring  [min 1, max 3]
   func _init(p_value: Vector2 = <default>, p_stiffness: float = <default>, p_damping_ratio: float = <default>) -> void  [min 0, max 3]
   func configure(p_stiffness: float, p_damping_ratio: float) -> void  [min 2, max 2]
   func set_target(target_value: Vector2) -> void  [min 1, max 1]
   func kick(impulse: Vector2) -> void  [min 1, max 1]
   func snap(value_now: Vector2) -> void  [min 1, max 1]
   func step(delta: float) -> Vector2  [min 1, max 1]
   func is_settled(epsilon: float = <default>) -> bool  [min 0, max 1]
   inner class ProceduralSpring.Spring2D

── ProceduralSquishRig (res://core/procedural/anim/squish_rig.gd) extends RefCounted
   enum JointKind { RIGID, SOFT, PINNED }
   const DEFAULT_STIFFNESS: float
   const DEFAULT_DAMPING_RATIO: float
   const MAX_SQUASH: float
   var part_id: StringName
   var parent: ProceduralSquishRig
   var joint_kind: JointKind
   var rest_position: Vector2
   var rest_rotation: float
   var stiffness: float
   var damping_ratio: float
   var squash: float
   var body_part: ProceduralBodyPart
   var field: ProceduralDeformField
   var node: ProceduralSquishRig
   var joint: ProceduralSquishRig
   var out: Array
   var joint: ProceduralSquishRig
   var ordered: Array
   var shape: ProceduralShape
   var placed: Dictionary
   var joint: ProceduralSquishRig
   var index: int
   var mode: int
   var parent_index: int
   var angle: float
   var offset: Vector2
   var joint: ProceduralSquishRig
   var node: int
   var total: float
   var node: ProceduralSquishRig
   var node: ProceduralSquishRig
   var node: ProceduralSquishRig
   var shape: ProceduralShape
   var found: int
   var index: int
   var shape: ProceduralShape
   var start: int
   var root: Vector2
   var node: int
   var falloff: float
   var shape: ProceduralShape
   var cursor: int
   var guard: int
   func _init(p_part_id: StringName = <default>) -> void  [min 0, max 1]
   func attach(joint: ProceduralSquishRig) -> ProceduralSquishRig  [min 1, max 1]
   func get_joint(joint_id: StringName) -> ProceduralSquishRig  [min 1, max 1]
   func get_joints() -> Array  [min 0, max 0]
   func joint_count() -> int  [min 0, max 0]
   func find_root() -> ProceduralSquishRig  [min 0, max 0]
   func rest_pose() -> void  [min 0, max 0]
   func ordered_joints() -> Array  [min 0, max 0]
   func _collect_ordered(out: Array) -> void  [min 1, max 1]
   func to_shape() -> ProceduralShape  [min 0, max 0]
   func _accumulated_rotation(joint: ProceduralSquishRig) -> float  [min 1, max 1]
   func _mode_of(joint: ProceduralSquishRig) -> int  [min 1, max 1]
   func _root_stiffness() -> float  [min 0, max 0]
   func _root_damping() -> float  [min 0, max 0]
   func _invalidate() -> void  [min 0, max 0]
   func node_index_of(joint_id: StringName) -> int  [min 1, max 1]
   func get_position() -> Vector2  [min 0, max 0]
   func get_position_at(joint_id: StringName) -> Vector2  [min 1, max 1]
   func get_rotation() -> float  [min 0, max 0]
   func get_scale() -> float  [min 0, max 0]
   func step(delta: float) -> void  [min 1, max 1]
   func disturb(impulse: Vector2, local_point: Vector2 = <default>) -> void  [min 1, max 2]
   func _is_descendant_of(node_index: int, ancestor_index: int) -> bool  [min 2, max 2]
   func is_bakeable() -> bool  [min 0, max 0]
   func draw(_canvas: ProceduralCanvas, _palette: ProceduralPalette) -> void  [min 2, max 2]
