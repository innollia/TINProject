extends GutTest

# Wave 1 수용 테스트: 파트 실루엣, 개체 합성, 리그, 네 dict 팩토리.
# 정본: core/procedural/README.md "Wave 1 checklist", DESIGN_DECISION.md §0, §2, §4, §5
#
# 세 가지를 본다.
#   결정론    같은 입력 → 같은 픽셀(바이트 단위).
#   비어 있지 않음  실제로 칠해지고, 실제로 움직인다. "텍스처가 만들어졌다" 는 통과가 아니다.
#   경계      Node · autoload · Input · 이미지 파일 · 리터럴 RGB 를 쓰지 않는다.

const FIXTURES: String = "res://core/procedural/tests/fixtures/"
const STEP: float = 1.0 / 60.0
const IMAGE_EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp", "svg", "bmp", "tga", "exr", "hdr", "ktx", "dds"]
const WAVE1_SOURCES: Array[String] = [
	"res://core/procedural/procedural.gd",
	"res://core/procedural/sprite/body_part.gd",
	"res://core/procedural/sprite/creature_builder.gd",
	"res://core/procedural/anim/squish_rig.gd",
]


# ── 보조 ─────────────────────────────────────────────────────────────────

func load_spec(file_name: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(FIXTURES + file_name)
	assert_false(text.is_empty(), "fixture missing: %s" % file_name)
	var parsed: Variant = JSON.parse_string(text)
	assert_typeof(parsed, TYPE_DICTIONARY, "fixture is not an object: %s" % file_name)
	return parsed


func palette_for(seed_id: String) -> ProceduralPalette:
	return Procedural.make_palette(Procedural.derive_seed(0, seed_id))


func painted(canvas: ProceduralCanvas) -> int:
	var count: int = 0
	for index: int in range(3, canvas.pixels.size(), 4):
		if canvas.pixels[index] > 0:
			count += 1
	return count


func largest_byte_difference(a: PackedByteArray, b: PackedByteArray) -> int:
	if a.size() != b.size():
		return 255
	var worst: int = 0
	for index: int in a.size():
		worst = maxi(worst, absi(int(a[index]) - int(b[index])))
	return worst


func same_color(a: Color, b: Color, tolerance: float = 1.5 / 255.0) -> bool:
	return absf(a.r - b.r) <= tolerance and absf(a.g - b.g) <= tolerance \
		and absf(a.b - b.b) <= tolerance and absf(a.a - b.a) <= tolerance


func has_color(canvas: ProceduralCanvas, color: Color) -> bool:
	for y: int in canvas.height:
		for x: int in canvas.width:
			if same_color(canvas.get_pixel(x, y), color):
				return true
	return false


func critter_builder(overrides: Dictionary = {}) -> ProceduralCreatureBuilder:
	var spec: Dictionary = load_spec("sprite_critter.json")
	var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(Vector2i(64, 48))
	builder.set_palette(palette_for("fixture.critter"))
	builder.outline_width = float(overrides.get("outline_width", 1.0))
	builder.squash = float(overrides.get("squash", 0.0))
	builder.facing = int(overrides.get("facing", 1))
	for entry: Variant in (spec["parts"] as Array):
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure(entry as Dictionary)
		if overrides.has("shade"):
			part.shade = int(overrides["shade"])
			part.body_role = ProceduralPalette.ROLE_BODY
		builder.add_part(part)
	return builder


func limb(extra: Dictionary = {}) -> ProceduralBodyPart:
	var part: ProceduralBodyPart = ProceduralBodyPart.new(&"limb")
	var spec: Dictionary = {"length": 24.0, "base_radius": 10.0, "tip_radius": 4.0, "bend": 20.0}
	spec.merge(extra, true)
	part.configure(spec)
	return part


func rig_spec() -> Dictionary:
	return {
		"seed_id": "fixture.rig",
		"joints": [
			{"id": "hips", "rest_position": [32.0, 44.0],
				"part": {"length": 12.0, "base_radius": 12.0, "tip_radius": 10.0, "angle": -90.0}},
			{"id": "chest", "parent": "hips", "rest_position": [0.0, -12.0], "squash": 0.5,
				"part": {"length": 10.0, "base_radius": 11.0, "tip_radius": 8.0, "angle": -90.0}},
			{"id": "head", "parent": "chest", "rest_position": [0.0, -12.0],
				"part": {"length": 6.0, "base_radius": 10.0, "tip_radius": 8.0, "angle": -90.0, "shade": "rim"}},
			{"id": "badge", "parent": "chest", "kind": "rigid", "rest_position": [5.0, -4.0],
				"part": {"length": 1.0, "base_radius": 3.0, "tip_radius": 3.0, "body_role": "accent", "shade": "flat"}},
			{"id": "foot", "parent": "hips", "kind": "pinned", "rest_position": [0.0, 2.0]},
		],
	}


func settle_rig(rig: ProceduralSquishRig, frames: int) -> void:
	for _i: int in frames:
		rig.step(STEP)


func point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside: bool = false
	var last: int = polygon.size() - 1
	for index: int in polygon.size():
		var a: Vector2 = polygon[index]
		var b: Vector2 = polygon[last]
		if (a.y > point.y) != (b.y > point.y):
			var cross_x: float = a.x + (point.y - a.y) / (b.y - a.y) * (b.x - a.x)
			if point.x < cross_x:
				inside = not inside
		last = index
	return inside


func signed_area(loop: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in loop.size():
		var a: Vector2 = loop[index]
		var b: Vector2 = loop[(index + 1) % loop.size()]
		total += a.x * b.y - b.x * a.y
	return total * 0.5


# ── ProceduralBodyPart.draw / bounds ────────────────────────────────────

func test_part_draw_is_deterministic() -> void:
	var pose: Dictionary = {"origin": Vector2(12.0, 30.0), "rotation": -0.4, "scale": 1.2, "squash": 0.2}
	var first: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	var second: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	limb().draw(first, palette_for("fixture.part"), pose)
	limb().draw(second, palette_for("fixture.part"), pose)
	assert_gt(painted(first), 150, "the part painted almost nothing")
	assert_eq(first.pixels, second.pixels, "same part, palette and pose gave different pixels")


func test_part_draw_uses_the_body_role_colour() -> void:
	var palette: ProceduralPalette = palette_for("fixture.part")
	var canvas: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	limb().draw(canvas, palette, {"origin": Vector2(16.0, 32.0)})
	assert_true(has_color(canvas, palette.get_color(ProceduralPalette.ROLE_BODY)), "no pixel carries the body role")
	var shaded: bool = has_color(canvas, palette.mix_roles(ProceduralPalette.ROLE_BODY, ProceduralPalette.ROLE_SHADE, ProceduralBodyPart._SHADE_MIX))
	assert_true(shaded, "the volumetric part has no shade crescent")


func test_part_bounds_contain_every_painted_pixel_tightly() -> void:
	for extra: Dictionary in [
		{},
		{"wiggle": 0.5},
		{"shade": "ink"},
		{"segments": [{"kind": "capsule"}, {"kind": "box"}, {"kind": "triangle"}]},
	]:
		var part: ProceduralBodyPart = limb(extra)
		var extent: Rect2 = part.bounds()
		var pad: Vector2 = Vector2(3.0, 3.0)
		var origin: Vector2 = -extent.position + pad
		var canvas: ProceduralCanvas = ProceduralCanvas.new(ceili(extent.size.x + pad.x * 2.0), ceili(extent.size.y + pad.y * 2.0))
		part.draw(canvas, palette_for("fixture.bounds"), {"origin": origin})
		var used: Rect2i = canvas.get_used_rect()
		var expected: Rect2 = Rect2(pad, extent.size)
		assert_gt(used.size.x, 0, "nothing painted for %s" % extra)
		assert_true(float(used.position.x) >= floorf(expected.position.x) and float(used.position.y) >= floorf(expected.position.y), "painted above / left of bounds() for %s" % extra)
		assert_true(float(used.end.x) <= ceilf(expected.end.x) and float(used.end.y) <= ceilf(expected.end.y), "painted below / right of bounds() for %s" % extra)
		assert_lt(absf(float(used.position.x) - expected.position.x), 2.0, "bounds() is loose on the left for %s" % extra)
		assert_lt(absf(float(used.end.x) - expected.end.x), 2.0, "bounds() is loose on the right for %s" % extra)
		assert_lt(absf(float(used.position.y) - expected.position.y), 2.0, "bounds() is loose on top for %s" % extra)
		assert_lt(absf(float(used.end.y) - expected.end.y), 2.0, "bounds() is loose at the bottom for %s" % extra)


func test_part_draw_follows_the_pose() -> void:
	var palette: ProceduralPalette = palette_for("fixture.pose")
	var straight: ProceduralBodyPart = limb({"bend": 0.0})
	var flat: ProceduralCanvas = ProceduralCanvas.new(96, 96)
	straight.draw(flat, palette, {"origin": Vector2(30.0, 48.0)})
	var turned: ProceduralCanvas = ProceduralCanvas.new(96, 96)
	straight.draw(turned, palette, {"origin": Vector2(48.0, 20.0), "rotation": PI * 0.5})
	var squashed: ProceduralCanvas = ProceduralCanvas.new(96, 96)
	straight.draw(squashed, palette, {"origin": Vector2(30.0, 48.0), "squash": 0.4})
	var doubled: ProceduralCanvas = ProceduralCanvas.new(96, 96)
	straight.draw(doubled, palette, {"origin": Vector2(20.0, 48.0), "scale": 2.0})
	var flat_rect: Rect2i = flat.get_used_rect()
	var turned_rect: Rect2i = turned.get_used_rect()
	assert_gt(flat_rect.size.x, flat_rect.size.y, "a +X part should be wider than tall")
	assert_gt(turned_rect.size.y, turned_rect.size.x, "rotation by 90 degrees did not stand the part up")
	var squashed_rect: Rect2i = squashed.get_used_rect()
	assert_lt(squashed_rect.size.x, flat_rect.size.x, "squash did not shorten the part along its axis")
	assert_gt(squashed_rect.size.y, flat_rect.size.y, "squash did not widen the part across its axis")
	assert_gt(doubled.get_used_rect().size.x, int(flat_rect.size.x * 1.8), "scale 2 did not double the part")


func test_part_configure_reads_json_names() -> void:
	var part: ProceduralBodyPart = ProceduralBodyPart.new()
	part.configure({"kind": "torso", "shade": "ink", "joint": "middle"})
	assert_eq(part.kind, ProceduralBodyPart.Kind.TORSO)
	assert_eq(part.shade, ProceduralBodyPart.Shade.INK)
	assert_eq(part.joint, ProceduralBodyPart.Joint.MIDDLE)
	assert_almost_eq(part.at, 0.5, 0.0001)
	var numeric: ProceduralBodyPart = ProceduralBodyPart.new()
	numeric.configure({"kind": ProceduralBodyPart.Kind.EYE, "joint": ProceduralBodyPart.Joint.TIP})
	assert_eq(numeric.kind, ProceduralBodyPart.Kind.EYE)
	assert_almost_eq(numeric.at, 1.0, 0.0001, "an enum joint must convert to at too")


func test_part_segments_start_at_the_joint() -> void:
	var part: ProceduralBodyPart = limb({"bend": 0.0, "segments": [{"kind": "capsule"}, {"kind": "capsule"}, {"kind": "box"}]})
	var joints: PackedVector2Array = part.segment_endpoints()
	assert_eq(joints.size(), 4)
	assert_eq(joints[0], Vector2.ZERO)
	assert_lt(part.field_at(Vector2(1.0, 0.0)), 0.0, "the first segment is missing")
	assert_lt(part.field_at(Vector2(23.0, 0.0)), 0.0, "the last segment is missing")
	assert_gt(part.field_at(Vector2(12.0, 30.0)), 0.0)


func test_part_deform_field_warps_the_silhouette() -> void:
	var palette: ProceduralPalette = palette_for("fixture.deform")
	var part: ProceduralBodyPart = limb({"bend": 0.0})
	var field: ProceduralDeformField = ProceduralDeformField.new(4, 4)
	field.build_grid(4, 4, Rect2(-6.0, -8.0, 36.0, 16.0))
	var still: ProceduralCanvas = ProceduralCanvas.new(64, 48)
	part.draw(still, palette, {"origin": Vector2(16.0, 24.0), "deform": field})
	field.excite(2600.0, 30.0, Vector2(12.0, 0.0))
	for _i: int in 6:
		field.step(STEP)
	var warped: ProceduralCanvas = ProceduralCanvas.new(64, 48)
	part.draw(warped, palette, {"origin": Vector2(16.0, 24.0), "deform": field})
	assert_gt(largest_byte_difference(still.pixels, warped.pixels), 60, "the deform field did not move the silhouette")


# ── ProceduralCreatureBuilder ────────────────────────────────────────────

func test_builder_compose_is_deterministic() -> void:
	var first: ProceduralCanvas = critter_builder().compose_canvas()
	var second: ProceduralCanvas = critter_builder().compose_canvas()
	assert_eq(first.width, 64)
	assert_eq(first.height, 48)
	assert_gt(painted(first), 500, "the critter is nearly empty")
	assert_eq(first.pixels, second.pixels, "two builds of one spec differ")
	var builder: ProceduralCreatureBuilder = critter_builder()
	assert_eq(builder.compose_canvas().pixels, builder.compose_canvas().pixels, "composing twice changed the bake")


func test_builder_honours_anchor_parent() -> void:
	var builder: ProceduralCreatureBuilder = critter_builder()
	var built: ProceduralShape = builder.to_shape()
	assert_eq(built.anchor_parent[1], 0, "head must hang from the torso")
	assert_eq(built.anchor_parent[2], 1, "eye must hang from the head")
	assert_eq(built.anchor_parent[3], 0, "front leg must hang from the torso, not the eye")
	var torso_axis: Vector2 = built.get_rest_dir(0)
	var expected: Vector2 = built.get_rest()[0] + torso_axis * (0.8 * built.span[0])
	assert_almost_eq(built.get_rest()[3].distance_to(expected), 0.0, 0.001, "the front leg is not at 0.8 of the torso")


func test_builder_paints_accent_parts_in_their_own_role() -> void:
	var builder: ProceduralCreatureBuilder = critter_builder()
	var canvas: ProceduralCanvas = builder.compose_canvas()
	var built: ProceduralShape = builder.to_shape()
	var eye: Vector2 = built.get_rest()[2] + builder.canvas_origin + built.get_rest_dir(2) * 0.5
	var ink: Color = builder.palette.get_color(ProceduralPalette.ROLE_INK)
	assert_true(same_color(canvas.get_pixel(floori(eye.x), floori(eye.y)), ink), "the ink eye vanished into the body")
	assert_true(has_color(canvas, builder.palette.get_color(ProceduralPalette.ROLE_BODY)), "no pixel carries the body role")


func test_builder_facing_mirrors_the_silhouette() -> void:
	var right: ProceduralCanvas = critter_builder({"shade": ProceduralBodyPart.Shade.FLAT, "outline_width": 0.0}).compose_canvas()
	var left: ProceduralCanvas = critter_builder({"shade": ProceduralBodyPart.Shade.FLAT, "outline_width": 0.0, "facing": -1}).compose_canvas()
	assert_ne(right.pixels, left.pixels, "facing -1 changed nothing")
	var mismatched: int = 0
	for y: int in right.height:
		for x: int in right.width:
			if not same_color(right.get_pixel(x, y), left.get_pixel(right.width - 1 - x, y), 0.0001):
				mismatched += 1
	assert_eq(mismatched, 0, "facing -1 is not the mirror image of facing +1")


func test_builder_squash_flattens_and_keeps_the_feet() -> void:
	var standing: Rect2i = critter_builder().compose_canvas().get_used_rect()
	var squashed: Rect2i = critter_builder({"squash": 0.3}).compose_canvas().get_used_rect()
	var stretched: Rect2i = critter_builder({"squash": -0.3}).compose_canvas().get_used_rect()
	assert_lt(squashed.size.y, standing.size.y, "squash did not flatten")
	assert_gt(squashed.size.x, standing.size.x, "squash did not widen")
	assert_gt(stretched.size.y, standing.size.y, "negative squash did not stretch")
	assert_lt(absi(squashed.end.y - standing.end.y), 2, "squash lifted the feet off their row")


func test_outline_is_one_closed_clockwise_ring_on_the_silhouette() -> void:
	var builder: ProceduralCreatureBuilder = critter_builder()
	var ring: PackedVector2Array = builder.outline()
	assert_gt(ring.size(), 40, "the contour is too short for this silhouette")
	assert_gt(signed_area(ring), 100.0, "the ring is not clockwise on screen (positive area, y down)")
	var field: Callable = builder._fused_field()
	for index: int in ring.size():
		var here: Vector2 = ring[index]
		var after: Vector2 = ring[(index + 1) % ring.size()]
		assert_gt(here.distance_to(after), 0.0, "repeated point at %d" % index)
		assert_lt(here.distance_to(after), 1.5, "the ring jumps at %d, so it is not one closed contour" % index)
		assert_lt(absf(float(field.call(here))), 0.75, "contour point %d is off the silhouette edge" % index)
	var built: ProceduralShape = builder.to_shape()
	var torso_middle: Vector2 = built.get_rest()[0] + builder.canvas_origin + built.get_rest_dir(0) * 11.0
	assert_true(point_in_polygon(torso_middle, ring), "the ring does not enclose the torso")
	assert_false(point_in_polygon(Vector2(0.5, 0.5), ring), "the ring encloses the canvas corner")
	assert_eq(ring, critter_builder().outline(), "outline is not deterministic")


func test_outline_follows_facing() -> void:
	var right: PackedVector2Array = critter_builder().outline()
	var left: PackedVector2Array = critter_builder({"facing": -1}).outline()
	assert_eq(right.size(), left.size())
	var mirrored: Dictionary = {}
	for point: Vector2 in right:
		mirrored[Vector2(snappedf(64.0 - point.x, 0.01), snappedf(point.y, 0.01))] = true
	var matched: int = 0
	for point: Vector2 in left:
		if mirrored.has(Vector2(snappedf(point.x, 0.01), snappedf(point.y, 0.01))):
			matched += 1
	assert_gt(matched, int(left.size() * 0.95), "the left facing contour is not the mirror of the right one")


func test_compose_refuses_without_a_palette() -> void:
	var builder: ProceduralCreatureBuilder = critter_builder()
	builder.palette = null
	assert_eq(builder.compose_canvas().width, 1)
	assert_push_error("compose_canvas: bake refused. set_palette")
	assert_null(builder.compose())
	assert_push_error("compose: bake refused. set_palette")


func test_builder_rebuilds_the_shape_when_a_part_changes() -> void:
	var builder: ProceduralCreatureBuilder = critter_builder()
	var before: Vector2 = builder.to_shape().get_rest()[1]
	builder.parts[0].length = 30.0
	var after: Vector2 = builder.to_shape().get_rest()[1]
	assert_gt(before.distance_to(after), 5.0, "a longer torso did not move the head")


# ── ProceduralSquishRig ──────────────────────────────────────────────────

func test_rig_is_one_shape_for_every_joint() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var head: ProceduralSquishRig = rig.get_joint(&"chest").get_joint(&"head")
	assert_not_null(head)
	assert_eq(head.to_shape(), rig.to_shape(), "a child joint built a second canonical shape")
	assert_eq(rig.to_shape().node_count(), 5)
	assert_almost_eq(head.get_position().distance_to(Vector2(32.0, 20.0)), 0.0, 0.001, "rest positions do not chain through parent frames")


func test_rig_step_integrates_from_the_root() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var head: ProceduralSquishRig = rig.get_joint(&"chest").get_joint(&"head")
	var head_rest: Vector2 = head.get_position()
	rig.disturb(Vector2(260.0, 0.0), Vector2(0.0, 0.0))
	var peak: float = 0.0
	for _i: int in 20:
		rig.step(STEP)
		peak = maxf(peak, head.get_position().distance_to(head_rest))
	assert_gt(peak, 1.0, "the head did not follow the pushed hips")
	settle_rig(rig, 900)
	assert_almost_eq(head.get_position().distance_to(head_rest), 0.0, 0.01, "the rig never came back to rest")


func test_rig_disturb_stays_inside_the_subtree() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var chest: ProceduralSquishRig = rig.get_joint(&"chest")
	var head: ProceduralSquishRig = chest.get_joint(&"head")
	var hips_rest: Vector2 = rig.get_position()
	var chest_rest: Vector2 = chest.get_position()
	var head_rest: Vector2 = head.get_position()
	head.disturb(Vector2(0.0, 400.0))
	rig.step(STEP)
	assert_eq(rig.get_position(), hips_rest, "the root moved when only the head was hit")
	assert_eq(chest.get_position(), chest_rest, "the head's parent moved when only the head was hit")
	assert_gt(head.get_position().distance_to(head_rest), 0.5, "the struck joint did not move")


func test_rig_rigid_joint_rides_its_parent_exactly() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var chest: ProceduralSquishRig = rig.get_joint(&"chest")
	var badge: ProceduralSquishRig = chest.get_joint(&"badge")
	chest.disturb(Vector2(-300.0, 120.0))
	var travelled: float = 0.0
	var badge_rest: Vector2 = badge.get_position()
	for _i: int in 30:
		rig.step(STEP)
		assert_almost_eq((badge.get_position() - chest.get_position()).distance_to(Vector2(5.0, -4.0)), 0.0, 0.0001, "the rigid joint lagged or wobbled")
		travelled = maxf(travelled, badge.get_position().distance_to(badge_rest))
	assert_gt(travelled, 0.5, "the rigid joint did not move with its parent")


func test_rig_pinned_joint_never_moves() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var foot: ProceduralSquishRig = rig.get_joint(&"foot")
	var rest: Vector2 = foot.get_position()
	rig.disturb(Vector2(500.0, -500.0), Vector2(0.0, 2.0))
	for _i: int in 30:
		rig.step(STEP)
		assert_eq(foot.get_position(), rest, "a pinned joint moved")


func test_rig_landing_squashes_then_recovers() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var chest: ProceduralSquishRig = rig.get_joint(&"chest")
	assert_almost_eq(chest.get_scale(), 1.0, 0.0001, "a rig at rest is already squashed")
	# 땅이 밑동을 위로 민다. 위쪽 관절은 늦게 따라오므로 뼈가 짧아진다.
	rig.disturb(Vector2(0.0, -300.0), Vector2.ZERO)
	var lowest: float = 1.0
	for _i: int in 30:
		rig.step(STEP)
		lowest = minf(lowest, chest.get_scale())
	assert_lt(lowest, 0.9, "landing did not squash the chest bone")
	assert_true(lowest >= 1.0 - chest.squash - 0.0001, "the squash went past the joint's limit")
	settle_rig(rig, 900)
	assert_almost_eq(chest.get_scale(), 1.0, 0.001, "the squash never recovered")


func test_rig_rotation_reads_the_bone() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var head: ProceduralSquishRig = rig.get_joint(&"chest").get_joint(&"head")
	assert_almost_eq(head.get_rotation(), 0.0, 0.0001)
	head.disturb(Vector2(420.0, 0.0))
	var peak: float = 0.0
	for _i: int in 12:
		rig.step(STEP)
		peak = maxf(peak, head.get_rotation())
	assert_gt(peak, 0.05, "pushing the head right did not turn its bone clockwise")
	settle_rig(rig, 900)
	assert_almost_eq(head.get_rotation(), 0.0, 0.001)


func test_rig_draw_is_deterministic_and_moves() -> void:
	var palette: ProceduralPalette = palette_for("fixture.rig")
	var first: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var second: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	var still: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	first.draw(still, palette)
	assert_gt(painted(still), 300, "the rig drew almost nothing")
	assert_true(has_color(still, palette.get_color(ProceduralPalette.ROLE_ACCENT)), "the accent badge is missing")
	for rig: ProceduralSquishRig in [first, second]:
		rig.disturb(Vector2(0.0, -650.0))
		settle_rig(rig, 5)
	var a: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	var b: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	first.draw(a, palette)
	second.draw(b, palette)
	assert_eq(a.pixels, b.pixels, "the same rig and the same impulses drew different pixels")
	assert_gt(largest_byte_difference(still.pixels, a.pixels), 60, "the drawing did not follow the rig")


func test_rig_attach_refuses_a_cycle() -> void:
	var a: ProceduralSquishRig = ProceduralSquishRig.new(&"a")
	var b: ProceduralSquishRig = ProceduralSquishRig.new(&"b")
	a.attach(b)
	b.attach(a)
	assert_push_error("ancestor")
	assert_null(a.parent)
	assert_eq(b.joint_count(), 0)


# ── Procedural 팩토리 ────────────────────────────────────────────────────

func test_build_sprite_from_pure_json() -> void:
	var spec: Dictionary = load_spec("sprite_critter.json")
	var texture: ImageTexture = Procedural.build_sprite(spec)
	assert_not_null(texture)
	var image: Image = texture.get_image()
	assert_eq(image.get_width(), 64)
	assert_eq(image.get_height(), 48)
	var again: ImageTexture = Procedural.build_sprite(load_spec("sprite_critter.json"))
	assert_eq(image.get_data(), again.get_image().get_data(), "build_sprite is not deterministic")
	var visible: int = 0
	var data: PackedByteArray = image.get_data()
	for index: int in range(3, data.size(), 4):
		if data[index] > 0:
			visible += 1
	assert_gt(visible, 500, "build_sprite returned an almost empty image")


func test_build_sprite_variant_changes_the_palette_not_the_shape() -> void:
	var spec: Dictionary = load_spec("sprite_critter.json")
	var other: Dictionary = load_spec("sprite_critter.json")
	other["variant"] = 7
	var a: Image = Procedural.build_sprite(spec).get_image()
	var b: Image = Procedural.build_sprite(other).get_image()
	assert_ne(a.get_data(), b.get_data(), "variant did not change the colours")
	var same_mask: bool = true
	for y: int in a.get_height():
		for x: int in a.get_width():
			if (a.get_pixel(x, y).a > 0.0) != (b.get_pixel(x, y).a > 0.0):
				same_mask = false
	assert_true(same_mask, "variant changed the silhouette")


func test_build_sprite_rejects_bad_specs() -> void:
	assert_null(Procedural.build_sprite({"seed_id": "x"}))
	assert_push_error("'parts'")
	assert_null(Procedural.build_sprite({"parts": [{"length": 4.0}]}))
	assert_push_error("'seed_id'")
	var spec: Dictionary = load_spec("sprite_critter.json")
	spec["version"] = Procedural.ENGINE_VERSION + 1
	assert_null(Procedural.build_sprite(spec))
	assert_push_error("ENGINE_VERSION")


func test_make_rig_builds_the_authored_graph() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig(rig_spec())
	assert_not_null(rig)
	assert_eq(rig.part_id, &"hips")
	assert_eq(rig.joint_count(), 2)
	var chest: ProceduralSquishRig = rig.get_joint(&"chest")
	assert_eq(chest.rest_position, Vector2(0.0, -12.0))
	assert_almost_eq(chest.squash, 0.5, 0.0001)
	assert_eq(chest.get_joint(&"badge").joint_kind, ProceduralSquishRig.JointKind.RIGID)
	assert_eq(rig.get_joint(&"foot").joint_kind, ProceduralSquishRig.JointKind.PINNED)
	assert_eq(chest.get_joint(&"head").body_part.shade, ProceduralBodyPart.Shade.RIM)
	assert_almost_eq(chest.body_part.length, 10.0, 0.0001)


func test_make_rig_rejects_bad_specs() -> void:
	assert_null(Procedural.make_rig({"joints": []}))
	assert_push_error("'joints'")
	assert_null(Procedural.make_rig({"joints": [{"id": "a"}, {"id": "b", "parent": "nobody"}]}))
	assert_push_error("not an earlier joint")
	assert_null(Procedural.make_rig({"joints": [{"id": "a"}, {"id": "b"}]}))
	assert_push_error("second root")
	assert_null(Procedural.make_rig({"joints": [{"id": "a", "kind": "wobbly"}]}))
	assert_push_error("unknown kind")


func test_make_backdrop_applies_the_spec() -> void:
	var spec: Dictionary = {
		"seed_id": "fixture.backdrop", "variant": 2, "layer": "far",
		"parallax": 0.3, "stiffness": 60.0, "damping_ratio": 0.8,
		"field": "squish", "field_amplitude": 3.0,
		"anchors": [[0.0, 10.0], [40.0, 12.0], [80.0, 9.0]],
		"wind": [6.0, 0.0],
	}
	var layer: ProceduralBackdropDynamics = Procedural.make_backdrop(spec)
	assert_not_null(layer)
	assert_eq(layer.layer, ProceduralBackdropDynamics.Layer.FAR)
	assert_almost_eq(layer.parallax, 0.3, 0.0001)
	assert_eq(layer.get_anchor_count(), 3)
	assert_eq(layer.get_rest_position(1), Vector2(40.0, 12.0))
	assert_not_null(layer.field)
	assert_eq(layer.wind, Vector2(6.0, 0.0))
	var twin: ProceduralBackdropDynamics = Procedural.make_backdrop(spec)
	for current: ProceduralBackdropDynamics in [layer, twin]:
		current.set_view_offset(Vector2(30.0, 0.0))
		for _i: int in 40:
			current.step(STEP)
	for index: int in 3:
		assert_eq(layer.get_offset(index), twin.get_offset(index), "two layers from one spec moved apart")
		assert_gt(layer.get_offset(index).length(), 0.5, "anchor %d did not move" % index)


func test_make_backdrop_rejects_bad_specs() -> void:
	assert_null(Procedural.make_backdrop({"layer": "ceiling"}))
	assert_push_error("unknown layer")
	assert_null(Procedural.make_backdrop({"layer": "mid", "field": "squish"}))
	assert_push_error("'seed_id'")
	assert_null(Procedural.make_backdrop({"layer": "mid", "seed_id": "x", "field": "marble"}))
	assert_push_error("unknown noise field")


func test_render_frame_bakes_once_and_redraws_at_rest() -> void:
	var frame: Dictionary = {"sprite": load_spec("sprite_critter.json"), "pose": {}, "delta": 0.0}
	var first: ImageTexture = Procedural.render_frame(frame)
	assert_not_null(first)
	assert_true(frame.has("_frame"), "render_frame did not keep its state in the spec")
	var baked: ProceduralCanvas = frame["_frame"]["canvas"]
	assert_lt(largest_byte_difference(first.get_image().get_data(), baked.pixels), 2, "a frame at rest is not the baked sprite")
	frame["delta"] = STEP
	Procedural.render_frame(frame)
	assert_eq(frame["_frame"]["canvas"], baked, "render_frame baked the sprite again")


func test_render_frame_is_deterministic_and_squashes_on_impact() -> void:
	var runs: Array = []
	for _run: int in 2:
		var frame: Dictionary = {"sprite": load_spec("sprite_critter.json"), "pose": {}, "delta": 0.0}
		var rest_height: int = Procedural.render_frame(frame).get_image().get_used_rect().size.y
		frame["delta"] = STEP
		var heights: PackedInt32Array = PackedInt32Array()
		var images: Array[PackedByteArray] = []
		for index: int in 24:
			frame["pose"] = {"impulse": [0.0, 300.0]} if index == 0 else {}
			var image: Image = Procedural.render_frame(frame).get_image()
			images.append(image.get_data())
			heights.append(image.get_used_rect().size.y)
		runs.append([images, heights, rest_height])
	var first_images: Array = runs[0][0]
	var second_images: Array = runs[1][0]
	for index: int in first_images.size():
		assert_eq(first_images[index], second_images[index], "frame %d differs between identical runs" % index)
	var heights: PackedInt32Array = runs[0][1]
	var rest_height: int = runs[0][2]
	var lowest: int = rest_height
	for height: int in heights:
		lowest = mini(lowest, height)
	assert_lt(lowest, rest_height - 1, "pushing the crown down did not squash the sprite")


func test_render_frame_wind_leans_and_recovers() -> void:
	var frame: Dictionary = {"sprite": load_spec("sprite_critter.json"), "pose": {}, "delta": 0.0}
	var rest_image: Image = Procedural.render_frame(frame).get_image()
	var rest_rect: Rect2i = rest_image.get_used_rect()
	frame["delta"] = STEP
	frame["pose"] = {"wind": [5.0, 0.0]}
	var leaning: Image = null
	for _i: int in 90:
		leaning = Procedural.render_frame(frame).get_image()
	assert_gt(leaning.get_used_rect().end.x, rest_rect.end.x, "wind did not lean the sprite")
	frame["pose"] = {"wind": [0.0, 0.0]}
	var settled: Image = null
	for _i: int in 600:
		settled = Procedural.render_frame(frame).get_image()
	assert_lt(largest_byte_difference(settled.get_data(), rest_image.get_data()), 3, "the sprite never stood back up")


func test_render_frame_rejects_a_bad_sprite() -> void:
	assert_null(Procedural.render_frame({"sprite": {"seed_id": "x"}}))
	assert_push_error("'parts'")
	assert_null(Procedural.render_frame({}))
	assert_push_error("'sprite'")


# ── 경계: Node · autoload · Input · 이미지 파일 · 리터럴 RGB ─────────────

func test_every_engine_class_is_refcounted_not_a_node() -> void:
	var instances: Array = [
		ProceduralBodyPart.new(),
		ProceduralCreatureBuilder.new(),
		ProceduralSquishRig.new(),
		Procedural.make_rig(rig_spec()),
		Procedural.make_backdrop({"layer": "near"}),
	]
	for instance: Variant in instances:
		assert_true(instance is RefCounted, "%s is not RefCounted" % instance)
		assert_false(instance is Node, "%s is a Node" % instance)
	for path: String in _engine_sources():
		var extends_line: String = ""
		for raw: String in FileAccess.get_file_as_string(path).split("\n"):
			if raw.strip_edges().begins_with("extends "):
				extends_line = raw.strip_edges()
				break
		assert_eq(extends_line, "extends RefCounted", "%s does not extend RefCounted" % path)


func test_no_autoload_points_into_or_is_used_by_the_engine() -> void:
	var names: Array[String] = []
	for property: Dictionary in ProjectSettings.get_property_list():
		var key: String = String(property.get("name", ""))
		if not key.begins_with("autoload/"):
			continue
		names.append(key.substr(9))
		var target: String = String(ProjectSettings.get_setting(key, "")).trim_prefix("*")
		assert_false(target.begins_with("res://core/procedural"), "autoload %s points into the engine" % key)
	for path: String in _engine_sources():
		var code: String = _strip_comments(FileAccess.get_file_as_string(path))
		for needle: String in ["Engine.get_singleton", "get_node(", "get_tree", "/root", "Input.", "InputMap", "SceneTree"]:
			assert_false(code.contains(needle), "%s uses %s" % [path, needle])
		for autoload_name: String in names:
			assert_false(code.contains(autoload_name), "%s names autoload %s" % [path, autoload_name])


func test_no_image_file_and_no_image_loading() -> void:
	var files: PackedStringArray = PackedStringArray()
	_walk_all("res://core/procedural", files)
	assert_gt(files.size(), 10)
	for path: String in files:
		assert_false(IMAGE_EXTENSIONS.has(path.get_extension().to_lower()), "image file in the engine: %s" % path)
	for path: String in _engine_sources():
		var code: String = _strip_comments(FileAccess.get_file_as_string(path))
		for needle: String in ["load_from_file", "Image.load", "ResourceLoader", "preload(", "load(\""]:
			assert_false(code.contains(needle), "%s loads a resource with %s" % [path, needle])


func test_wave1_sources_name_no_literal_rgb() -> void:
	var literal: RegEx = RegEx.new()
	literal.compile("Color8?\\s*\\(\\s*[-0-9.\"]|Color\\s*\\.\\s*(html|from_string|from_hsv|from_ok_hsl|from_rgbe9995|hex)")
	for path: String in WAVE1_SOURCES:
		var code: String = _strip_comments(FileAccess.get_file_as_string(path))
		assert_false(code.is_empty(), path)
		assert_null(literal.search(code), "%s names a literal colour" % path)


func test_wave1_stubs_no_longer_refuse() -> void:
	# 스텁은 push_error 후 빈 값을 돌려줬다. 네 팩토리와 세 클래스가 그 문구를 더 갖지 않는다.
	for path: String in WAVE1_SOURCES:
		var code: String = FileAccess.get_file_as_string(path)
		assert_false(code.contains("intentionally not implemented"), "%s still carries a stub refusal" % path)
		assert_false(code.contains("WAVE 1 MUST IMPLEMENT"), "%s still carries a stub marker" % path)


func _engine_sources() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var all_files: PackedStringArray = PackedStringArray()
	_walk_all("res://core/procedural", all_files)
	for path: String in all_files:
		if path.ends_with(".gd") and not path.contains("/tests/"):
			out.append(path)
	out.sort()
	return out


func _walk_all(dir_path: String, out: PackedStringArray) -> void:
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
			_walk_all(full, out)
		else:
			out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()


func _strip_comments(source: String) -> String:
	var out: String = ""
	for raw_line: String in source.split("\n"):
		var line: String = raw_line
		var hash_at: int = line.find("#")
		if hash_at >= 0:
			line = line.substr(0, hash_at)
		out += line + "\n"
	return out
