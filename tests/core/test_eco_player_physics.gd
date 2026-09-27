extends GutTest

const DT: float = 1 / 60.0

var _table: EcoRungTable
var _content: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_content = EcoRegionLoader.load_all(_table)["value"]


func _room(band: String, target: float, w: int, h: int, extra_rows: Dictionary = {}) -> EcoRoomSpec:
	var room: EcoRoomSpec = EcoRoomSpec.new()
	room.id = "probe_flat"
	room.region_id = "reg_probe"
	room.band = band
	room.target_body_px = target
	room.tiles_w = w
	room.tiles_h = h
	var bytes: PackedByteArray = PackedByteArray()
	for y: int in h:
		for x: int in w:
			var k: int = EcoTileKind.EMPTY
			if y == h - 1 or y == 0 or x == 0 or x == w - 1:
				k = EcoTileKind.SOLID
			if extra_rows.has(y) and x > 0 and x < w - 1:
				k = int(extra_rows[y])
			bytes.append(k)
	room.terrain = bytes
	room.shelters = [{"id": "shelter_probe", "cell": Vector2i(3, h - 2)}]
	return room


func _director(room: EcoRoomSpec, rung: String) -> EcoStepDirector:
	var idx: EcoContentIndex = EcoContentIndex.new()
	idx.content_seed = 7
	idx.archetypes = _content.archetypes
	idx.archetype_ids = _content.archetype_ids
	var region: EcoRegionSpec = EcoRegionSpec.new()
	region.id = "reg_probe"
	region.rooms = [room]
	region.room_ids = PackedStringArray([room.id])
	idx.regions = [region]
	idx.rooms = {room.id: room}
	idx.start_room = room.id
	idx.start_shelter = "shelter_probe"
	idx.start_rung = rung
	var d: EcoStepDirector = EcoStepDirector.make(idx, _table)
	d.world.body_rung = rung
	d.enter_room(room.id, Vector2(room.tiles_w * 12.0, (room.tiles_h - 1) * EcoBodyRung.TILE))
	return d


func _settle_frames(d: EcoStepDirector, n: int, intent: Dictionary = {}) -> void:
	for i: int in n:
		d.step_frame(intent)


func test_eco_jump_height_per_rung() -> void:
	var cases: Array = [["speck", "speck", 96.0], ["hand", "hand", 240.0], ["doll", "doll", 384.0]]
	for c: Array in cases:
		var d: EcoStepDirector = _director(_room(c[1], c[2], 60, 60), c[0])
		_settle_frames(d, 20)
		assert_true(d.world.on_ground, "%s grounded" % c[0])
		var start_y: float = d.world.position_px.y
		var top: float = start_y
		for i: int in 90:
			d.step_frame({"jump_held": true, "any_input": true})
			top = minf(top, d.world.position_px.y)
		var rise: float = start_y - top
		assert_almost_eq(rise, _table.by_name(c[0]).jump_height, 2.0, "%s apex" % c[0])


func test_eco_jump_cut() -> void:
	var d: EcoStepDirector = _director(_room("speck", 96.0, 40, 30), "speck")
	_settle_frames(d, 20)
	d.player.read_input({"jump_held": true})
	d.player.begin_frame(d.world, DT)
	var sub: float = DT / 4
	d.player.substep(d.world, d.col, 1, 1, sub)
	var v_before: float = d.world.velocity_px.y
	assert_lt(v_before, 0.0)
	d.player.read_input({"jump_held": false})
	d.player.substep(d.world, d.col, 1, 1, sub)
	var expected: float = v_before * EcoPlayerBody.JUMP_CUT_MULT + EcoBodyRung.GRAVITY_BASE * sub
	assert_almost_eq(d.world.velocity_px.y, expected, 0.5)


func test_eco_coyote_and_buffer() -> void:
	var d: EcoStepDirector = _director(_room("speck", 96.0, 40, 30), "speck")
	_settle_frames(d, 20)
	var sub: float = DT / 4
	d.world.on_ground = false
	d.world.coyote_left = EcoPlayerBody.COYOTE_TIME - sub
	d.world.jump_buffer_left = EcoPlayerBody.JUMP_BUFFER
	d.player.read_input({})
	var ev: Dictionary = d.player.substep(d.world, d.col, 1, 1, sub)
	assert_true(ev["jumped"], "inside the coyote window")
	var d2: EcoStepDirector = _director(_room("speck", 96.0, 40, 30), "speck")
	_settle_frames(d2, 20)
	d2.world.position_px.y -= 200.0
	d2.world.on_ground = false
	d2.world.coyote_left = 0.0
	d2.world.jump_buffer_left = EcoPlayerBody.JUMP_BUFFER
	d2.player.read_input({})
	assert_false(d2.player.substep(d2.world, d2.col, 1, 1, sub)["jumped"], "coyote spent")
	assert_almost_eq(EcoPlayerBody.COYOTE_TIME, 0.10, 0.0001)
	assert_almost_eq(EcoPlayerBody.JUMP_BUFFER, 0.12, 0.0001)
	var d3: EcoStepDirector = _director(_room("speck", 96.0, 40, 30), "speck")
	_settle_frames(d3, 20)
	d3.world.position_px.y -= 4.0
	d3.world.on_ground = false
	d3.world.coyote_left = 0.0
	d3.step_frame({"jump_held": true})
	var jumped: bool = false
	for i: int in 6:
		d3.step_frame({"jump_held": true})
		if d3.world.velocity_px.y < -300.0:
			jumped = true
	assert_true(jumped, "buffered jump fires on landing")


func test_eco_fall_damage_formula() -> void:
	for n: String in _table.names():
		var b: EcoBodyRung = _table.by_name(n)
		assert_eq(EcoPlayerBody.fall_damage(b.safe_fall_speed, b.safe_fall_speed), 0.0)
		assert_almost_eq(EcoPlayerBody.fall_damage(b.safe_fall_speed + 700.0, b.safe_fall_speed), 0.5, 0.0001)
		assert_eq(EcoPlayerBody.fall_damage(b.lethal_fall_speed(), b.safe_fall_speed), 1.0)
		assert_eq(EcoPlayerBody.fall_damage(b.lethal_fall_speed() + 500.0, b.safe_fall_speed), 1.0)


func test_eco_one_way_platform() -> void:
	var room: EcoRoomSpec = _room("speck", 96.0, 30, 30, {24: EcoTileKind.ONE_WAY})
	var d: EcoStepDirector = _director(room, "speck")
	_settle_frames(d, 20)
	var floor_y: float = 29 * EcoBodyRung.TILE
	assert_almost_eq(d.world.position_px.y, floor_y, 1.0)
	for i: int in 50:
		d.step_frame({"jump_held": true, "any_input": true})
	_settle_frames(d, 60)
	assert_almost_eq(d.world.position_px.y, 24 * EcoBodyRung.TILE, 1.0, "jumped up through and stands on it")
	d.step_frame({"curl_held": true, "jump_held": true, "any_input": true})
	_settle_frames(d, 90, {"curl_held": true, "any_input": true})
	assert_almost_eq(d.world.position_px.y, floor_y, 1.0, "curl + jump drops through")


func test_eco_gap_squeeze_speed() -> void:
	var room: EcoRoomSpec = _room("speck", 96.0, 40, 30)
	var gap: EcoPassageSpec = EcoPassageSpec.new()
	gap.id = "gap_probe"
	gap.kind = EcoPassageKind.GAP
	gap.width_class = "WIDE"
	gap.cell = Vector2i(10, 1)
	gap.span = Vector2i(20, 27)
	room.passages = [gap]
	var d: EcoStepDirector = _director(room, "hand")
	d.world.position_px = Vector2(20 * EcoBodyRung.TILE, 29 * EcoBodyRung.TILE)
	d.col.rebuild()
	_settle_frames(d, 10)
	d.world.velocity_px.x = d.player.body.run_speed
	d.player.read_input({"move_axis": 1.0})
	d.player.substep(d.world, d.col, 1, 1, DT / 4)
	assert_true(d.player.squeezing, "hand body in a WIDE gap of a speck room is squeezed")
	assert_lte(d.world.velocity_px.x, d.player.body.run_speed * EcoPlayerBody.SQUEEZE_SPEED_MULT + 1.0)


func test_eco_settle_multipliers() -> void:
	var rows: Array = [[0.0, 0.0, 1.0, 1.0], [120.0, 0.0, 1.0, 1.0], [210.0, 0.55, 1.14, 0.93], [300.0, 1.0, 1.35, 0.86], [360.0, 0.0, 1.0, 1.0], [419.9, 0.0, 1.0, 1.0]]
	for r: Array in rows:
		assert_almost_eq(EcoSettleSystem.press_at(r[0]), r[1], 0.001, "press at %s" % r[0])
		assert_almost_eq(EcoSettleSystem.gravity_mult_at(r[0]), r[2], 0.001, "gravity at %s" % r[0])
		assert_almost_eq(EcoSettleSystem.drift_friction_at(r[0]), r[3], 0.001, "d friction at %s" % r[0])
	assert_eq(EcoSettleSystem.drift_friction_at(150.0), 1.0, "press <= 0.35 leaves d friction alone")
	assert_eq(EcoSettleSystem.phase_at(250.0), EcoSettleSystem.PHASE_PRESSING)


func test_eco_frame_order_is_fixed() -> void:
	var d: EcoStepDirector = _director(_room("speck", 96.0, 40, 30), "speck")
	d.log_stages = true
	d.step_frame({})
	assert_eq(Array(d.stage_log), Array(EcoStepDirector.STAGES))
	assert_eq(EcoStepDirector.STAGES.size(), 13)
	var src: String = FileAccess.get_file_as_string("res://modules/sideview_ecosystem/systems/creature.gd")
	assert_false(src.contains("decide("), "creature.step never thinks")


func test_eco_room_transition_keeps_rung() -> void:
	var d: EcoStepDirector = EcoStepDirector.make(_content, _table)
	d.world.body_rung = "speck"
	d.enter_room("filter_bed_00", Vector2(38 * EcoBodyRung.TILE, 23 * EcoBodyRung.TILE))
	d.world.t_settle = 50.0
	for i: int in 120:
		d.step_frame({"move_axis": 1.0, "any_input": true})
		if d.world.current_room_id != "filter_bed_00":
			break
	assert_eq(d.world.current_room_id, "filter_bed_01")
	assert_eq(d.world.previous_room_id, "filter_bed_00")
	assert_eq(d.world.body_rung, "speck")
	assert_gt(d.world.t_settle, 50.0)
	assert_lt(d.world.t_settle, 53.0)
	assert_true(d.world.rooms_visited.has("filter_bed_01"))
