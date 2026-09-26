extends GutTest

# 정규 형상(ProceduralShape) 수용 테스트.
# 정본: core/procedural/DESIGN_DECISION.md §8-2, §10
# 픽스처는 core/procedural/tests/fixtures/ 의 순수 JSON 이다.

const FIXTURES: String = "res://core/procedural/tests/fixtures/"


func load_spec(file_name: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(FIXTURES + file_name)
	assert_false(text.is_empty(), "fixture missing: %s" % file_name)
	var parsed: Variant = JSON.parse_string(text)
	assert_typeof(parsed, TYPE_DICTIONARY, "fixture is not an object: %s" % file_name)
	return parsed


func build(fixture: String) -> ProceduralShape:
	var shape: ProceduralShape = ProceduralShape.new()
	assert_true(shape.build_from_spec(load_spec(fixture)), "build_from_spec failed: %s" % fixture)
	return shape


func settle(shape: ProceduralShape, frames: int = 240) -> void:
	for _i: int in frames:
		shape.step(1.0 / 60.0)


# ── a. 결정성 — 같은 (spec_hash, version) 은 항상 같은 정지 형상 ──────────

func test_a_same_spec_produces_identical_rest() -> void:
	var first: ProceduralShape = build("object_grass_blade.json")
	var second: ProceduralShape = build("object_grass_blade.json")
	assert_eq(first.spec_hash, second.spec_hash)
	assert_eq(first.rest, second.rest)
	assert_eq(first.radius, second.radius)
	assert_eq(first.links, second.links)


func test_a_spec_hash_is_stable_across_key_order() -> void:
	var spec: Dictionary = load_spec("object_rock.json")
	var one: ProceduralShape = ProceduralShape.new()
	var two: ProceduralShape = ProceduralShape.new()
	assert_true(one.build_from_spec(spec))
	var reordered: Dictionary = {}
	var keys: Array = spec.keys()
	keys.reverse()
	for key: Variant in keys:
		reordered[key] = spec[key]
	assert_true(two.build_from_spec(reordered))
	assert_eq(one.spec_hash, two.spec_hash)
	assert_eq(one.rest, two.rest)


func test_a_every_fixture_builds_and_is_deterministic() -> void:
	for fixture: String in [
		"object_rock.json",
		"object_grass_blade.json",
		"object_pond_surface.json",
		"motion_contact_push.json",
		"motion_hanging_banner.json",
	]:
		var one: ProceduralShape = build(fixture)
		var two: ProceduralShape = build(fixture)
		assert_eq(one.spec_hash, two.spec_hash, fixture)
		assert_eq(one.rest, two.rest, fixture)
		assert_gt(one.node_count(), 0, fixture)


# ── b. 형상 / 콜라이더 일치 — 같은 배열에서 나온다 ────────────────────────

func test_b_get_points_is_the_canonical_array() -> void:
	var shape: ProceduralShape = build("object_rock.json")
	# get_points() 가 정규 배열 그 자체여야 화면과 물리가 갈라지지 않는다.
	assert_eq(shape.get_points(), shape.points)
	assert_eq(shape.get_points().size(), shape.node_count())


func test_b_render_and_collider_read_one_array() -> void:
	var shape: ProceduralShape = build("motion_contact_push.json")
	shape.collider_enabled = true
	var collider: Dictionary = shape.derive_collider()
	assert_eq(String(collider["source"]), "points")
	var before: Vector2 = shape.read_collider_point(collider, 3)
	# stage 2 는 접선 성분만 준다. 수평 체인에 수평으로 밀면 아무 일도 없다.
	# 그래서 반드시 접선에 수직으로 민다.
	shape.apply_impulse(Vector2(6.0, 1.0), 40.0, 900.0, Vector2.UP)
	settle(shape, 30)
	var after: Vector2 = shape.read_collider_point(collider, 3)
	# 콜라이더가 보는 값이 변했다 = 화면이 그리는 배열과 물리가 같은 배열이다.
	assert_gt(before.distance_to(after), 0.5, "collider point did not follow the render array")


func test_b_rigid_collider_reads_rest_and_grid_reads_points() -> void:
	var rock: ProceduralShape = build("object_rock.json")
	assert_eq(String(rock.derive_collider()["source"]), "rest")
	var pond: ProceduralShape = build("object_pond_surface.json")
	pond.collider_enabled = true
	assert_eq(String(pond.derive_collider()["source"]), "points")


func test_b_collider_keeps_node_indices() -> void:
	var shape: ProceduralShape = build("object_rock.json")
	var collider: Dictionary = shape.derive_collider()
	var segments: PackedInt32Array = collider["segments"]
	assert_eq(segments.size() % 2, 0)
	for slot: int in range(0, segments.size(), 2):
		assert_lt(segments[slot], shape.node_count())
		assert_lt(segments[slot + 1], shape.node_count())


# ── c. 변형 반응 — 정점이 실제로 밀린다 ──────────────────────────────────

func test_c_pinned_root_never_moves() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	shape.apply_impulse(Vector2(1.0, 0.0), 40.0, 2000.0, Vector2.RIGHT)
	settle(shape)
	assert_almost_eq(shape.get_points()[0].distance_to(shape.get_rest()[0]), 0.0, 0.0001)


func test_c_upper_nodes_bend_under_wind() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	var tip_before: float = shape.get_points()[4].x
	settle(shape, 120)
	var tip_after: float = shape.get_points()[4].x
	assert_gt(tip_after, tip_before + 1.0, "wind did not lay the blade over")


func test_c_free_nodes_hold_their_own_rest_shape() -> void:
	# §12-1. free 는 매달린 장식용이다. 자기 rest 로 돌아온다.
	var shape: ProceduralShape = build("motion_hanging_banner.json")
	shape.force = Vector2.ZERO
	var rest: PackedVector2Array = shape.get_rest().duplicate()
	shape.apply_impulse(Vector2(5.0, 1.0), 60.0, 1500.0, Vector2.RIGHT)
	settle(shape, 400)
	for index: int in shape.node_count():
		var node: int = index
		if node == 0:
			continue
		assert_almost_eq(
			shape.get_points()[node].distance_to(rest[node]), 0.0, 0.01,
			"free node %d did not return to its own rest" % node
		)


func test_c_impulse_along_tangent_does_not_slide() -> void:
	# stage 2 는 접선 성분만 준다. 순수 접선 임펄스는 이동을 만들지 않는다.
	var shape: ProceduralShape = build("motion_contact_push.json")
	shape.force = Vector2.ZERO
	var node: int = 1
	var tangent: Vector2 = shape.get_points()[node + 1] - shape.get_points()[node]
	assert_gt(tangent.length(), 0.0)
	shape.apply_impulse(shape.get_points()[node], 6.0, 1200.0, tangent.normalized())
	settle(shape, 300)
	assert_almost_eq(shape.get_points()[node].distance_to(shape.get_rest()[node]), 0.0, 0.05)


func test_c_grid_coupling_propagates_displacement() -> void:
	var pond: ProceduralShape = build("object_pond_surface.json")
	# 격자가 실제로 깔렸는지 먼저 본다. 전부 원점에 겹친 퇴화 격자는 통과로 치지 않는다.
	var rest: PackedVector2Array = pond.get_rest()
	assert_eq(rest.size(), 8 * 5)
	assert_gt(rest[pond.node_count() - 1].distance_to(rest[0]), 100.0, "the grid is degenerate")
	var centre: int = int(pond.get_grid_side_x() / 2) + int(pond.get_grid_side_y() / 2) * pond.get_grid_side_x()
	pond.apply_impulse(rest[centre], 8.0, 1400.0, Vector2.UP)
	settle(pond, 20)
	var moved: int = 0
	for index: int in pond.node_count():
		if pond.get_points()[index].distance_to(pond.get_rest()[index]) > 0.05:
			moved += 1
	# 결합이 전파되지 않으면 밀린 정점은 하나뿐이다.
	assert_gt(moved, 1, "coupling did not propagate beyond the touched vertex")


func test_c_grid_neighbour_count_is_symmetric() -> void:
	var pond: ProceduralShape = build("object_pond_surface.json")
	for index: int in pond.node_count():
		var neighbours: PackedInt32Array = pond.get_neighbours(index)
		for other: int in neighbours:
			assert_true(pond.get_neighbours(other).has(index), "neighbour relation is not symmetric at %d" % index)


# ── 기존 클래스 위임 (§7-4, §7-5) — 정규 배열이 하나여야 한다 ───────────

func test_deform_field_is_a_facade_over_one_shape() -> void:
	var field: ProceduralDeformField = ProceduralDeformField.new(6, 4)
	assert_not_null(field.to_shape())
	# §0. 정규 배열이 둘이면 axiom 이 깨진다.
	assert_eq(field.points, field.to_shape().get_points())
	assert_eq(field.rest, field.to_shape().get_rest())
	assert_eq(field.get_vertex_count(), 24)
	field.excite(900.0, 20.0, Vector2(30.0, 20.0))
	for _i: int in 12:
		field.step(1.0 / 60.0)
	var moved: int = 0
	for index: int in field.get_vertex_count():
		if field.to_shape().get_points()[index].distance_to(field.to_shape().get_rest()[index]) > 0.05:
			moved += 1
	assert_gt(moved, 0, "excite did not move any vertex through the facade")
	assert_lt(moved, 24, "a local gust spread to the whole grid, so coupling is missing")


func test_deform_field_coupling_makes_the_gust_spread() -> void:
	var bare: ProceduralDeformField = ProceduralDeformField.new(6, 4)
	var bound: ProceduralDeformField = ProceduralDeformField.new(6, 4)
	bound.set_coupling(0.4)
	# 반경 6px 는 격자 한 칸보다 작다. 그래서 직접 맞은 정점은 정확히 하나다.
	# 결합이 없으면 그 하나만 움직이고, 결합이 있으면 이웃으로 번진다.
	var strike: Vector2 = bare.to_shape().get_points()[7]
	for field: ProceduralDeformField in [bare, bound]:
		field.excite(1400.0, 6.0, strike)
		for _i: int in 10:
			field.step(1.0 / 60.0)
	assert_eq(bare.get_coupling(), 0.0)
	assert_gt(bound.get_coupling(), 0.0)
	var bare_moved: int = 0
	var bound_moved: int = 0
	for index: int in bare.get_vertex_count():
		if bare.to_shape().get_points()[index].distance_to(bare.to_shape().get_rest()[index]) > 0.05:
			bare_moved += 1
		if bound.to_shape().get_points()[index].distance_to(bound.to_shape().get_rest()[index]) > 0.05:
			bound_moved += 1
	assert_eq(bare_moved, 1, "an uncoupled grid should move only the struck vertex")
	assert_gt(bound_moved, bare_moved, "coupling did not spread the gust to neighbours")


func test_deform_field_grid_is_never_bakeable() -> void:
	assert_false(ProceduralDeformField.new(4, 4).is_bakeable())


func test_deform_field_get_point_tracks_the_shape() -> void:
	var field: ProceduralDeformField = ProceduralDeformField.new(6, 4)
	# 노드에 정확히 걸리는 정규 좌표를 고른다. 6 열 이므로 u = 2/5, 4 행 이므로 v = 2/3.
	# (0.5, 0.5) 는 네 정점 사이라 이 테스트에 쓰면 안 된다.
	var node: int = 2 + 2 * 6
	assert_almost_eq(field.get_point(2.0 / 5.0, 2.0 / 3.0).distance_to(field.to_shape().get_points()[node]), 0.0, 0.001)
	field.set_wind(Vector2(40.0, 0.0), 1.0)
	for _i: int in 90:
		field.step(1.0 / 60.0)
	assert_almost_eq(
		field.get_point(2.0 / 5.0, 2.0 / 3.0).distance_to(field.to_shape().get_points()[node]), 0.0, 0.001,
		"get_point stopped reading the live array"
	)
	assert_gt(field.get_offset(2.0 / 5.0, 2.0 / 3.0).length(), 0.1, "wind did not move the surface")


func test_backdrop_uses_the_same_shape_and_same_rules() -> void:
	var layer: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.MID)
	layer.configure(0.5, 3.0, 70.0, 0.75)
	for index: int in 6:
		layer.add_anchor(Vector2(float(index) * 20.0, 100.0))
	assert_eq(layer.get_anchor_count(), 6)
	# §7-5. 배경은 자기 코드 경로가 없다. 정규 형상 그 자체다.
	assert_not_null(layer.to_shape())
	assert_eq(layer.get_node_index(0), 0)
	# 정규 배열이 하나뿐이다.
	assert_eq(layer.to_shape().node_count(), 6)


func test_backdrop_lags_behind_the_camera_and_catches_up() -> void:
	var layer: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.MID)
	layer.configure(0.5, 0.0, 70.0, 0.75)
	layer.set_anchor_capacity(1)
	layer.add_anchor(Vector2.ZERO)
	layer.set_view_offset(Vector2(100.0, 0.0))
	layer.step(1.0 / 60.0)
	var lagging: float = layer.get_offset(0).x
	assert_gt(lagging, 0.0, "the layer did not move at all")
	assert_lt(lagging, 50.0, "the layer did not lag behind the camera")
	for _i: int in 600:
		layer.step(1.0 / 60.0)
	var settled: float = layer.get_offset(0).x
	# 패럴랙스 0.5 × 뷰 100 = 목표 50. 늦었다가 따라잡는다.
	assert_almost_eq(settled, 50.0, 0.5, "the layer never caught up to its target")


func test_backdrop_pulse_disturbs_every_anchor() -> void:
	var layer: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.FAR)
	layer.configure(0.5, 0.0, 70.0, 0.75)
	for index: int in 4:
		layer.add_anchor(Vector2(float(index) * 30.0, 50.0))
	layer.pulse(400.0)
	layer.step(1.0 / 60.0)
	for index: int in 4:
		assert_gt(layer.get_offset(index).length(), 0.1, "anchor %d ignored the pulse" % index)


func test_backdrop_parallax_scales_the_response() -> void:
	var near: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.NEAR)
	var far: ProceduralBackdropDynamics = ProceduralBackdropDynamics.new(ProceduralBackdropDynamics.Layer.FAR)
	for layer: ProceduralBackdropDynamics in [near, far]:
		layer.set_anchor_capacity(1)
		layer.add_anchor(Vector2.ZERO)
		layer.set_view_offset(Vector2(80.0, 0.0))
	near.configure(1.0, 0.0, 70.0, 0.75)
	far.configure(0.2, 0.0, 70.0, 0.75)
	for _i: int in 900:
		near.step(1.0 / 60.0)
		far.step(1.0 / 60.0)
	assert_almost_eq(near.get_offset(0).x, 80.0, 0.5)
	assert_almost_eq(far.get_offset(0).x, 16.0, 0.5)


# ── bake 경로 (§2.1, §2.4) ─────────────────────────────────────────────

## 바위는 순수 JSON 이고 bake 가능해야 한다. "텍스처가 만들어졌다" 만으로는 부족하다.
func test_bake_rock_from_the_fixture() -> void:
	var builder: ProceduralCreatureBuilder = _rock_builder()
	assert_true(builder.is_bakeable(), "a plain rigid object must be bakeable")
	var canvas: ProceduralCanvas = builder.compose_canvas()
	assert_eq(canvas.width, 64)
	assert_eq(canvas.height, 64)
	# 실제로 뭔가 그려졌는지 본다. 팔레트 색이 켜진 픽셀이 있어야 한다.
	var painted: int = 0
	for y: int in canvas.height:
		for x: int in canvas.width:
			if canvas.get_pixel(x, y).a > 0.0:
				painted += 1
	assert_gt(painted, 200, "compose_canvas produced an empty canvas")
	assert_true(builder.compose() != null, "compose returned no texture")


func test_bake_is_refused_when_a_rigid_shape_gets_a_deform_field() -> void:
	var builder: ProceduralCreatureBuilder = _rock_builder()
	assert_true(builder.is_bakeable())
	# §2.4 표. rigid 도 deform 필드가 붙으면 bake 금지다.
	builder.to_shape().set_deform_field_bound(true)
	builder.to_shape().rebuild_springs()
	assert_false(builder.is_bakeable())
	var canvas: ProceduralCanvas = builder.compose_canvas()
	assert_eq(canvas.width, 1, "refused bake still produced a canvas")
	assert_push_error("bake refused")


func test_outline_has_no_duplicate_points() -> void:
	# outline() 은 닫힌 윤곽 하나다. 이웃한 두 점(끝 → 처음 포함)이 같으면 안 된다.
	var builder: ProceduralCreatureBuilder = _rock_builder()
	var contour: PackedVector2Array = builder.outline()
	assert_gt(contour.size(), 8, "marching squares found no crossings")
	for slot: int in contour.size():
		assert_ne(contour[slot], contour[(slot + 1) % contour.size()], "repeated point at %d" % slot)


func test_part_bounds_agree_with_its_field() -> void:
	var part: ProceduralBodyPart = ProceduralBodyPart.new(&"probe", ProceduralBodyPart.Kind.LIMB)
	part.configure({"id": "probe", "length": 20.0, "base_radius": 8.0, "tip_radius": 2.0, "bend": 30.0, "wiggle": 0.4})
	var extent: Rect2 = part.bounds()
	# bounds 안쪽 중심은 내부(음수)여야 하고, 밖은 바깥(양수)여야 한다.
	var centre: Vector2 = extent.get_center()
	assert_lt(part.field_at(centre), part.radius_at(0.5), "bounds centre is not inside the silhouette")
	assert_gt(part.field_at(extent.position - Vector2(20.0, 20.0)), 0.0, "bounds corner is not outside")


func test_part_radius_interpolates_base_to_tip() -> void:
	var part: ProceduralBodyPart = ProceduralBodyPart.new()
	part.configure({"base_radius": 10.0, "tip_radius": 4.0})
	assert_almost_eq(part.radius_at(0.0), 5.0, 0.001)
	assert_almost_eq(part.radius_at(1.0), 2.0, 0.001)
	assert_almost_eq(part.radius_at(0.5), 3.5, 0.001)


func test_part_joint_to_at_legacy_conversion() -> void:
	assert_almost_eq(ProceduralBodyPart.joint_to_at(&"root"), 0.0, 0.001)
	assert_almost_eq(ProceduralBodyPart.joint_to_at(&"middle"), 0.5, 0.001)
	assert_almost_eq(ProceduralBodyPart.joint_to_at(&"tip"), 1.0, 0.001)
	# §7-2. 구형 스펙이 그대로 동작해야 한다 — 06 계획서가 인용 중이니까.
	var part: ProceduralBodyPart = ProceduralBodyPart.new()
	part.configure({"id": "legacy", "length": 10.0, "base_radius": 4.0, "tip_radius": 2.0, "joint": "middle"})
	assert_almost_eq(part.at, 0.5, 0.001)


func test_rig_turns_into_one_shape() -> void:
	var root: ProceduralSquishRig = ProceduralSquishRig.new(&"root")
	var spine: ProceduralSquishRig = ProceduralSquishRig.new(&"spine")
	var tail: ProceduralSquishRig = ProceduralSquishRig.new(&"tail")
	spine.rest_position = Vector2(10.0, 0.0)
	tail.rest_position = Vector2(8.0, 0.0)
	root.attach(spine)
	spine.attach(tail)
	var shape: ProceduralShape = root.to_shape()
	assert_not_null(shape)
	assert_eq(shape.node_count(), 3)
	# 부모가 먼저 오는 순서여야 정규 형상이 받아들인다.
	assert_eq(shape.anchor_parent[0], -1)
	assert_eq(shape.anchor_parent[1], 0)
	assert_eq(shape.anchor_parent[2], 1)
	assert_almost_eq(shape.get_rest()[1].distance_to(Vector2(10.0, 0.0)), 0.0, 0.001)
	assert_almost_eq(shape.get_rest()[2].distance_to(Vector2(18.0, 0.0)), 0.0, 0.001)
	# 리그가 두 번째 물리 루프를 갖지 않는다.
	assert_eq(root.to_shape(), shape)


func test_rig_disturb_reaches_the_whole_subtree() -> void:
	var root: ProceduralSquishRig = ProceduralSquishRig.new(&"root")
	var spine: ProceduralSquishRig = ProceduralSquishRig.new(&"spine")
	var tail: ProceduralSquishRig = ProceduralSquishRig.new(&"tail")
	spine.rest_position = Vector2(10.0, 0.0)
	tail.rest_position = Vector2(8.0, 0.0)
	root.attach(spine)
	spine.attach(tail)
	var shape: ProceduralShape = root.to_shape()
	root.disturb(Vector2(0.0, 400.0), Vector2(8.0, 0.0))
	for _i: int in 12:
		shape.step(1.0 / 60.0)
	assert_gt(shape.get_points()[1].y - shape.get_rest()[1].y, 0.1, "the child joint ignored the impulse")
	assert_gt(shape.get_points()[2].y - shape.get_rest()[2].y, 0.1, "the grandchild joint ignored the impulse")


func _rock_builder() -> ProceduralCreatureBuilder:
	var spec: Dictionary = load_spec("object_rock.json")
	var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(Vector2i(64, 64))
	builder.set_palette(Procedural.make_palette(Procedural.derive_seed(0, "fixture.prop.rock")))
	for entry: Variant in (spec["parts"] as Array):
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure(entry as Dictionary)
		builder.add_part(part)
	return builder


# ── 수용 기준 §6-3. 가장 중요하다 ───────────────────────────────────────
# "풀 한 덩어리를 만들고 움직이는 바디를 그 위로 통과시킨 뒤 정점 좌표가 실제로
#  밀렸는지 단언한다. 텍스처가 만들어졌다 는 단언은 통과로 치지 않는다."

const BLADE_TIP: int = 4
const BODY_HALF_WIDTH: float = 2.0
const SWEEP_FROM: float = -14.0
const SWEEP_TO: float = 16.0
const SWEEP_FRAMES: int = 48
const PUSH_STRENGTH: float = 260.0
const DISPLACEMENT_THRESHOLD: float = 1.0


## 바디는 여기서 하나의 점이다. 움직임의 원천은 접촉과 힘뿐이기 때문이다. (§0)
## 속도 대신 위치를 주므로 프레임레이트에 결과가 의존하지 않는다.
func test_c_body_pushed_through_grass_displaces_the_tips() -> void:
	var grass: ProceduralShape = build("object_grass_blade.json")
	var tip_before: Vector2 = grass.get_points()[BLADE_TIP]
	var peak: float = 0.0
	for frame: int in SWEEP_FRAMES:
		var travelled: float = lerpf(SWEEP_FROM, SWEEP_TO, float(frame) / float(SWEEP_FRAMES - 1))
		var body: Vector2 = Vector2(travelled, 6.0)
		var push: Vector2 = Vector2(0.0, 1.0)
		grass.apply_impulse(body, BODY_HALF_WIDTH, PUSH_STRENGTH, push)
		grass.step(1.0 / 60.0)
		peak = maxf(peak, grass.get_points()[BLADE_TIP].distance_to(tip_before))
	assert_gt(
		peak, DISPLACEMENT_THRESHOLD,
		"a body passing through the grass did not move the blade tip (peak %f px)" % peak
	)


## 밀린 뒤에는 다시 선다. 단, 바람이 멈춘 뒤에. (§12-1)
## 이 픽스처에는 force 가 있으므로 바람이 부는 동안의 정지점은 "눕힌 상태" 다.
## 스프링이 세우는 것은 바람이 멈춘 뒤다.
func test_c_grass_returns_to_rest_after_the_body_leaves() -> void:
	var grass: ProceduralShape = build("object_grass_blade.json")
	var rest: PackedVector2Array = grass.get_rest().duplicate()
	for frame: int in SWEEP_FRAMES:
		grass.apply_impulse(Vector2(lerpf(SWEEP_FROM, SWEEP_TO, float(frame) / float(SWEEP_FRAMES - 1)), 6.0), BODY_HALF_WIDTH, PUSH_STRENGTH, Vector2.UP)
		grass.step(1.0 / 60.0)
	assert_gt(grass.get_points()[BLADE_TIP].distance_to(rest[BLADE_TIP]), DISPLACEMENT_THRESHOLD)
	grass.force = Vector2.ZERO
	settle(grass, 900)
	for index: int in range(1, grass.node_count()):
		var node: int = index
		assert_almost_eq(
			grass.get_points()[node].distance_to(rest[node]), 0.0, 0.05,
			"node %d never stood back up" % node
		)


## 바람이 부는 동안에는 눕힌 채로 정지한다. 이게 §3.2 의 풀 정의다.
func test_c_wind_holds_the_blade_over_while_it_blows() -> void:
	var grass: ProceduralShape = build("object_grass_blade.json")
	assert_gt(grass.force, Vector2.ZERO)
	settle(grass, 300)
	var lean: float = grass.get_points()[BLADE_TIP].x - grass.get_rest()[BLADE_TIP].x
	assert_gt(lean, 5.0, "steady wind did not lay the blade over")
	grass.force = Vector2.ZERO
	settle(grass, 900)
	assert_almost_eq(grass.get_points()[BLADE_TIP].x, grass.get_rest()[BLADE_TIP].x, 0.05)


## 정점 좌표가 아니라 정규 배열 자체가 밀린다. points 를 복사하지 않는다.
func test_c_the_canonical_array_itself_is_what_moves() -> void:
	var grass: ProceduralShape = build("object_grass_blade.json")
	var canonical: PackedVector2Array = grass.get_points()
	grass.apply_impulse(Vector2(0.0, 6.0), BODY_HALF_WIDTH, PUSH_STRENGTH, Vector2.UP)
	settle(grass, 12)
	# get_points() 가 새 배열을 돌려주면 이것이 실패한다.
	assert_eq(grass.get_points()[BLADE_TIP].distance_to(canonical[BLADE_TIP]), 0.0)
	assert_gt(canonical[BLADE_TIP].distance_to(grass.get_rest()[BLADE_TIP]), DISPLACEMENT_THRESHOLD)


# ── d. 팔레트 결정성 ─────────────────────────────────────────────────────

func test_d_palette_is_deterministic_per_seed() -> void:
	var first: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(1234, "fixture"))
	var second: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(1234, "fixture"))
	for role: StringName in first.get_role_names():
		assert_eq(first.get_color(role), second.get_color(role), String(role))


func test_d_palette_differs_per_seed() -> void:
	var first: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(1, "fixture"))
	var second: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(2, "fixture"))
	assert_ne(first.get_color(ProceduralPalette.ROLE_BODY), second.get_color(ProceduralPalette.ROLE_BODY))


# ── e. 금지 API — 주석이 아니라 실제 호출이 0건이어야 한다 ───────────────

func test_e_engine_sources_declare_no_forbidden_api() -> void:
	var forbidden: Array[String] = ["Input.", "InputMap", "get_tree()", "/root", "extends Node"]
	var sources: PackedStringArray = _engine_sources()
	assert_gt(sources.size(), 8, "engine source walk found too few files")
	for path: String in sources:
		var source: String = FileAccess.get_file_as_string(path)
		assert_false(source.is_empty(), path)
		var code: String = _strip_comments(source)
		for needle: String in forbidden:
			assert_false(code.contains(needle), "%s uses %s" % [path, needle])


## 엔진 소스만 훑는다. tests/ 는 검사 대상이 아니다 — 테스트는 금지 문자열을
## 이름으로 직접 써야 하기 때문이다. DESIGN_DECISION §8-2 e.
func _engine_sources() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	_walk("res://core/procedural", out)
	out.sort()
	return out


func _walk(dir_path: String, out: PackedStringArray) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full: String = dir_path.path_join(entry)
		if dir.current_is_dir():
			if entry != "tests":
				_walk(full, out)
		elif entry.ends_with(".gd"):
			out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()


## 주석과 문자열 리터럴을 지운다. 주석이 "금지 API" 를 언급하는 것은 허용이다.
func _strip_comments(source: String) -> String:
	var out: String = ""
	for raw_line: String in source.split("\n"):
		var line: String = raw_line
		var hash_at: int = line.find("#")
		if hash_at >= 0:
			line = line.substr(0, hash_at)
		out += line + "\n"
	return out


# ── bake 판정 (§2.4) — 자료형으로만 ─────────────────────────────────────

func test_bake_allowed_for_invariant_rigid() -> void:
	var rock: ProceduralShape = build("object_rock.json")
	assert_true(rock.is_bakeable(), "a plain rigid shape must be bakeable")
	settle(rock)
	assert_true(rock.points_match_rest(0.0), "rigid points moved")
	assert_true(rock.require_bakeable())


func test_bake_forbidden_for_every_soft_kind() -> void:
	assert_false(build("object_grass_blade.json").is_bakeable())
	assert_false(build("object_pond_surface.json").is_bakeable())
	assert_false(build("motion_contact_push.json").is_bakeable())
	assert_false(build("motion_hanging_banner.json").is_bakeable())


func test_bake_forbidden_when_rigid_has_deform_field() -> void:
	var rock: ProceduralShape = build("object_rock.json")
	rock.set_deform_field_bound(true)
	rock.rebuild_springs()
	assert_false(rock.is_bakeable())


# ── 앵커 규약 (§4) ───────────────────────────────────────────────────────

func test_anchor_default_is_attached_and_parent_is_previous() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	assert_eq(shape.anchor_mode[0], ProceduralShape.AnchorMode.PINNED)
	for index: int in range(1, shape.node_count()):
		var node: int = index
		assert_eq(shape.anchor_mode[node], ProceduralShape.AnchorMode.ATTACHED, "node %d" % node)
		assert_eq(shape.anchor_parent[node], node - 1, "node %d" % node)


func test_anchor_rejects_attached_on_root() -> void:
	var shape: ProceduralShape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	assert_true(shape.allocate(3, ProceduralShape.Kind.SOFT_CHAIN))
	assert_false(shape.set_anchor(0, ProceduralShape.AnchorMode.ATTACHED, -1, 0.0, Vector2.ZERO, 0.0))
	assert_push_error("node 0 has no parent")
	assert_true(shape.set_anchor(0, ProceduralShape.AnchorMode.PINNED, -1, 0.0, Vector2.ZERO, 0.0))


func test_anchor_rejects_forward_parent() -> void:
	var shape: ProceduralShape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	assert_true(shape.allocate(3, ProceduralShape.Kind.SOFT_CHAIN))
	assert_false(shape.set_anchor(1, ProceduralShape.AnchorMode.ATTACHED, 2, 0.0, Vector2.ZERO, 0.0))
	assert_push_error("must be an earlier index")


func test_chain_keeps_its_length_on_the_first_frame() -> void:
	# stage 4 식에 자식 자신의 span 이 없으면 체인이 첫 프레임에 무너진다.
	# 바람이 없는 픽스처를 쓴다 — force 가 있으면 첫 프레임에 타깃이 이미 밀린다.
	var shape: ProceduralShape = build("motion_contact_push.json")
	var rest: PackedVector2Array = shape.get_rest().duplicate()
	shape.step(1.0 / 60.0)
	for index: int in shape.node_count():
		var node: int = index
		assert_almost_eq(
			shape.get_points()[node].distance_to(rest[node]), 0.0, 0.001,
			"node %d jumped on the first step" % node
		)


func test_chain_segment_lengths_match_the_spec() -> void:
	var shape: ProceduralShape = build("motion_contact_push.json")
	var rest: PackedVector2Array = shape.get_rest()
	for index: int in range(1, shape.node_count()):
		var node: int = index
		assert_almost_eq(rest[node].distance_to(rest[node - 1]), 4.0, 0.001, "node %d" % node)


func test_rigid_at_places_part_along_parent() -> void:
	var rock: ProceduralShape = build("object_rock.json")
	# parts[0] 은 angle 12 도다. parts[1] 은 그 방향으로 0.55 * length 만큼 가고
	# 자기 angle -38 도를 추가로 돌린다.
	var axis: Vector2 = rock.get_rest_dir(0)
	var anchor_point: Vector2 = rock.get_rest()[0] + axis * (0.55 * rock.span[0])
	var child_dir: Vector2 = axis.rotated(deg_to_rad(-38.0))
	assert_almost_eq(rock.get_rest_dir(1).dot(child_dir), 1.0, 0.001)
	assert_almost_eq((rock.get_rest()[1] - anchor_point).length(), 0.0, 0.001)


# ── 스펙 규약 (§1) — 위반은 조용히 넘기지 않는다 ───────────────────────
# assert_push_error 는 콜백이 아니라 "이 테스트가 낸 push_error 의 텍스트" 를
# 소비한다. 그래서 먼저违规을 일으키고 그 다음 텍스트를 Assert 한다.

func test_spec_version_must_match_engine_version() -> void:
	var spec: Dictionary = load_spec("object_rock.json")
	spec["version"] = Procedural.ENGINE_VERSION + 1
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("ENGINE_VERSION")


func test_spec_rejects_two_kind_blocks() -> void:
	var spec: Dictionary = load_spec("object_grass_blade.json")
	spec["parts"] = [{"id": "x", "length": 1.0, "base_radius": 1.0, "tip_radius": 1.0}]
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("exactly one of parts / chain / grid")


func test_spec_rejects_missing_version() -> void:
	var spec: Dictionary = load_spec("object_rock.json")
	spec.erase("version")
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("missing 'version'")


func test_grid_anchor_cannot_be_attached() -> void:
	var spec: Dictionary = load_spec("object_pond_surface.json")
	spec["grid"]["anchor"] = {"mode": "attached", "parent": 0}
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("no parent")


func test_chain_budget_is_enforced() -> void:
	var spec: Dictionary = load_spec("object_grass_blade.json")
	var long_chain: Array = []
	for index: int in ProceduralShape.MAX_CHAIN_NODES + 4:
		long_chain.append({"length": 1.0, "radius": 1.0})
	spec["chain"] = long_chain
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("MAX_CHAIN_NODES")


func test_grid_budget_is_enforced() -> void:
	var spec: Dictionary = load_spec("object_pond_surface.json")
	spec["grid"]["width"] = ProceduralShape.MAX_GRID_SIDE + 1
	var shape: ProceduralShape = ProceduralShape.new()
	assert_false(shape.build_from_spec(spec))
	assert_push_error("MAX_GRID_SIDE")


func test_bake_is_refused_loudly_for_a_soft_shape() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	assert_false(shape.require_bakeable())
	assert_push_error("bake refused")


func test_collider_derivation_is_refused_when_disabled() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	assert_true(shape.derive_collider().is_empty())
	assert_push_error("disabled the collider")


func test_set_root_transform_is_refused_on_a_soft_shape() -> void:
	var shape: ProceduralShape = build("object_grass_blade.json")
	shape.set_root_transform(Transform2D(0.0, Vector2(10.0, 10.0)))
	assert_push_error("Pin the root node")
