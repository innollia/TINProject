class_name RuleBoardView
extends Control

signal command_requested(command: StringName, payload: Dictionary)


class ItemThumbnail extends Control:
	var entity_texture: Texture2D
	var kind_label: String = ""
	var word_role: StringName = &""
	var slot_number: int = 1
	var stack_count: int = 0

	func configure(
		object_texture: Texture2D,
		item_label: String,
		item_word_role: StringName,
		number: int,
		count: int
	) -> void:
		entity_texture = object_texture
		kind_label = item_label
		word_role = item_word_role
		slot_number = number
		stack_count = count
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		if size.x <= 4.0 or size.y <= 4.0:
			return
		var font := ThemeDB.fallback_font
		if kind_label.is_empty():
			var empty_caption := "[%d]" % slot_number
			var empty_size := _fit_font_size(empty_caption, size.x - 8.0, 15)
			draw_string(font, Vector2(0.0, size.y * 0.5 + float(empty_size) * 0.34), empty_caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, empty_size, Color("f0eee6"))
			return
		draw_string(font, Vector2(5.0, 12.0), str(slot_number), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color("b9c3c8"))
		if word_role != &"":
			var word_tint := _word_tint(word_role)
			var word_box := Rect2(Vector2(5.0, 16.0), Vector2(maxf(1.0, size.x - 10.0), minf(25.0, maxf(16.0, size.y - 31.0))))
			draw_rect(word_box, Color("101419"), true)
			draw_rect(word_box, word_tint.darkened(0.45), false, 1.0)
			var word_size := _fit_font_size(kind_label, word_box.size.x - 5.0, 14)
			draw_string(font, Vector2(word_box.position.x, word_box.position.y + word_box.size.y * 0.5 + float(word_size) * 0.34), kind_label, HORIZONTAL_ALIGNMENT_CENTER, word_box.size.x, word_size, word_tint)
			return
		var icon_size := minf(size.x * 0.62, size.y * 0.52)
		var center := Vector2(size.x * 0.5, size.y * 0.47)
		if entity_texture != null:
			draw_texture_rect(entity_texture, Rect2(center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size), false)
		var caption := kind_label
		if stack_count > 1:
			caption += " ×%d" % stack_count
		var caption_size := _fit_font_size(caption, size.x - 6.0, 11)
		draw_string(font, Vector2(2.0, size.y - 3.0), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x - 4.0, caption_size, Color("f0eee6"))

	func _fit_font_size(text: String, available_width: float, starting_size: int) -> int:
		var font := ThemeDB.fallback_font
		var font_size := starting_size
		while font_size > 8 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > available_width:
			font_size -= 1
		return font_size

	func _word_tint(role: StringName) -> Color:
		if role == &"operator":
			return Color("ece9de")
		if role == &"property":
			return Color("78c7bb")
		return Color("e8a1a5")

const COLORS: Dictionary = {
	"BABA": Color("ef6b66"), "PLAYER": Color("ef6b66"), "ROCK": Color("94aaa8"),
	"WALL": Color("4f5d6c"), "FLAG": Color("f2d36f"), "BOX": Color("bd9165"),
	"DOOR": Color("68aeb0"), "METRIX": Color("8a79c7")
}
const PALETTE: Array[Color] = [
	Color("e77868"), Color("e4bd5b"), Color("70b6a4"), Color("738fda"),
	Color("b381cc"), Color("d89255"), Color("72a9c6")
]
const RULE_FEEDBACK_DURATION: float = 0.58
const FIRST_PERSON_EYE_BACK_DISTANCE: float = 0.65
var _state: RuleGridState
var _rules: RuleSet
var _metrix: Array[Dictionary] = []
var _selected_metrix: Dictionary = {}
var _mode_3d: bool = false
var _inventory_open: bool = false
var _failed: bool = false
var _solved: bool = false
var _solved_cue: float = 0.0
var _solved_cue_cells: Array[Vector2i] = []
var _interactive: bool = true
var _hotbar_slot: int = 0
var _camera_quadrant: int = 0
var _first_person_3d: bool = true
var _selected_you_id: String = ""
var _focused_slot: int = 0
var _held_id: String = ""
var _message: String = ""
var _textures: Dictionary = {}
var _world_view: SubViewportContainer
var _world_viewport: SubViewport
var _world_root: Node3D
var _world_grid_root: Node3D
var _world_metrix_root: Node3D
var _world_entities_root: Node3D
var _world_cue_root: Node3D
var _world_grid_signature: String = ""
var _world_metrix_signature: String = ""
var _world_cue_signature: String = ""
var _world_cue_materials: Array[StandardMaterial3D] = []
var _world_entity_nodes: Dictionary = {}
var _world_entity_signatures: Dictionary = {}
var _last_camera_signature: String = ""
var _hotbar_content_signature: String = ""
var _inventory_content_signature: String = ""
var _last_mode_3d: bool = false
var _feedback_ids: Dictionary = {}
var _feedback_ring_nodes: Dictionary = {}
var _feedback_remaining: float = 0.0
var _camera: Camera3D
var _hotbar_panel: PanelContainer
var _inventory_panel: PanelContainer
var _inventory_grid: GridContainer
var _recovery_panel: PanelContainer
var _recovery_text: Label
var _message_panel: PanelContainer
var _message_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_3d_world()
	_create_hotbar()
	_create_inventory()
	_create_recovery()
	_create_message_panel()
	resized.connect(_on_resized)
	queue_redraw()


func show_state(
	state: RuleGridState,
	rules: RuleSet,
	metrix: Array[Dictionary],
	selected_metrix_id: String,
	selected_you_id: String,
	mode_3d: bool,
	inventory_open: bool,
	focused_slot: int,
	held_id: String,
	hotbar_slot: int,
	camera_quadrant: int,
	first_person_3d: bool,
	failed: bool,
	solved: bool,
	solved_cue: float,
	solved_cue_cells: Array[Vector2i],
	message: String,
	interactive: bool
) -> void:
	_state = state
	_rules = rules
	_metrix = metrix.duplicate(true)
	_mode_3d = mode_3d
	_inventory_open = inventory_open
	_focused_slot = focused_slot
	_held_id = held_id
	_hotbar_slot = hotbar_slot
	_camera_quadrant = posmod(camera_quadrant, 4)
	_first_person_3d = first_person_3d
	_selected_you_id = selected_you_id
	_failed = failed
	_solved = solved
	_solved_cue = maxf(0.0, solved_cue)
	_solved_cue_cells.assign(solved_cue_cells)
	_message = message
	_interactive = interactive
	_selected_metrix = {}
	for shape: Dictionary in _metrix:
		if String(shape.get("id", "")) == selected_metrix_id:
			_selected_metrix = shape
			break
	_world_view.visible = _mode_3d
	_hotbar_panel.visible = _mode_3d
	_inventory_panel.visible = _mode_3d and _inventory_open
	_recovery_panel.visible = _failed
	_recovery_text.text = "조작 대상이 사라졌다\nZ  되돌리기       R  이 보드 다시 시작"
	_message_label.text = _message
	_message_panel.visible = not _message.is_empty()
	var inventory_signature := _inventory_view_signature()
	if _mode_3d and (not _last_mode_3d or inventory_signature != _hotbar_content_signature):
		_rebuild_hotbar()
		_hotbar_content_signature = inventory_signature
	if _mode_3d and _inventory_open \
		and (not _last_mode_3d or inventory_signature != _inventory_content_signature):
		_rebuild_inventory()
		_inventory_content_signature = inventory_signature
	if _mode_3d:
		_resize_inventory_panel()
	_resize_message_panel()
	_sync_world_solved_cue()
	if _mode_3d:
		_sync_world()
	_last_mode_3d = _mode_3d
	queue_redraw()


func show_rule_change_feedback(entity_ids: Array[String]) -> void:
	for ring_value: Variant in _feedback_ring_nodes.values():
		if not ring_value is MeshInstance3D or not is_instance_valid(ring_value):
			continue
		var ring_parent: Node = ring_value.get_parent()
		if ring_parent != null:
			ring_parent.remove_child(ring_value)
		ring_value.queue_free()
	_feedback_ids.clear()
	_feedback_ring_nodes.clear()
	for entity_id: String in entity_ids:
		_feedback_ids[entity_id] = true
	_feedback_remaining = RULE_FEEDBACK_DURATION if not _feedback_ids.is_empty() else 0.0
	set_process(not _feedback_ids.is_empty())
	if _mode_3d:
		_sync_active_feedback_rings()
		_request_world_redraw()
	queue_redraw()


func rotate_camera(quarter_turns: int) -> void:
	_camera_quadrant = posmod(_camera_quadrant + quarter_turns, 4)
	_sync_world()


func _draw() -> void:
	if _state == null or _mode_3d:
		return
	var play_origin := Vector2.ZERO
	var play_size := size
	if _message_panel != null and _message_panel.visible:
		play_origin.y = minf(size.y * 0.25, _message_panel.offset_bottom + 12.0)
		play_size.y = maxf(0.0, size.y - play_origin.y)
	var cell_size := minf(play_size.x * 0.94 / float(_state.width), play_size.y * 0.94 / float(_state.height))
	if cell_size <= 0.0:
		return
	var board_size := Vector2(cell_size * _state.width, cell_size * _state.height)
	var origin := play_origin + (play_size - board_size) * 0.5
	draw_rect(Rect2(origin - Vector2(5.0, 5.0), board_size + Vector2(10.0, 10.0)), Color("11171c"), true)
	for y: int in range(_state.height):
		for x: int in range(_state.width):
			var at := origin + Vector2(float(x), float(y)) * cell_size
			var tone := Color("1a2026") if (x + y) % 2 == 0 else Color("20272d")
			draw_rect(Rect2(at, Vector2.ONE * cell_size), tone, true)
			draw_rect(Rect2(at, Vector2.ONE * cell_size), Color("39434a"), false, 1.0)
	_draw_metrix_boundaries(origin, cell_size)
	var occupied := _entities_by_cell()
	for cell: Vector2i in occupied.keys():
		var entities: Array[RuleGridEntity] = occupied[cell]
		entities.sort_custom(_entity_less)
		var positions := _overlap_offsets(entities.size(), cell_size)
		for index: int in range(entities.size()):
			_draw_entity(entities[index], origin + (Vector2(cell.x, cell.y) + Vector2(0.5, 0.5)) * cell_size + positions[index], cell_size)
	if _solved:
		_draw_solved_cue(origin, cell_size)


func _draw_solved_cue(origin: Vector2, cell_size: float) -> void:
	if _solved_cue <= 0.0:
		draw_rect(Rect2(0.0, 0.0, size.x, 4.0), Color("efd477"), true)
		return
	var strength := clampf(_solved_cue, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin((1.0 - strength) * PI)
	draw_rect(Rect2(0.0, 0.0, size.x, 4.0 + 10.0 * pulse * strength), Color(0.94, 0.83, 0.47, strength), true)
	if _solved_cue_cells.is_empty():
		draw_rect(Rect2(0.0, size.y * 0.4, size.x, size.y * 0.18), Color(0.98, 0.86, 0.5, 0.18 * strength), true)
		return
	for cell: Vector2i in _solved_cue_cells:
		var rect := Rect2(origin + Vector2(cell) * cell_size, Vector2.ONE * cell_size)
		draw_rect(rect, Color(0.98, 0.86, 0.5, 0.34 * strength), true)
		draw_arc(
			rect.get_center(),
			cell_size * (0.30 + 0.52 * (1.0 - strength)),
			0.0,
			TAU,
			32,
			Color(1.0, 0.93, 0.64, strength),
			maxf(2.0, cell_size * 0.05)
		)


func _draw_metrix_boundaries(origin: Vector2, cell_size: float) -> void:
	for shape: Dictionary in _metrix:
		var bounds: Variant = shape.get("bounds")
		if not bounds is Rect2i:
			continue
		var rect := Rect2(origin + Vector2(bounds.position) * cell_size, Vector2(bounds.size) * cell_size)
		var tint := Color("9f8deb", 0.72) if bool(shape.get("inventory", false)) else Color("698780", 0.5)
		draw_rect(rect, tint, false, maxf(2.0, cell_size * 0.035))


func _draw_entity(entity: RuleGridEntity, center: Vector2, cell_size: float) -> void:
	var box := Rect2(center - Vector2.ONE * cell_size * 0.42, Vector2.ONE * cell_size * 0.84)
	if entity.is_word:
		var tint := _word_color(entity)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("101419")
		draw_rect(box, style.bg_color, true)
		draw_rect(box, tint.darkened(0.45), false, 2.0)
		var word := String(entity.word_value)
		var font_size := clampi(int(cell_size * 0.41), 12, 42)
		var text_box := Rect2(box.position + Vector2(2.0, 0.0), box.size - Vector2(4.0, 0.0))
		font_size = _fit_text_size(word, text_box.size.x, font_size)
		draw_string(ThemeDB.fallback_font, Vector2(text_box.position.x, center.y + font_size * 0.34), word, HORIZONTAL_ALIGNMENT_CENTER, text_box.size.x, font_size, tint)
		if _is_active_word(entity.id):
			draw_rect(Rect2(box.position + Vector2(3.0, box.size.y - 4.0), Vector2(box.size.x - 6.0, 2.0)), Color("f2cf75"), true)
		_draw_rule_feedback(entity.id, box, center, cell_size)
		return
	var entity_color := _entity_color(entity.kind)
	draw_rect(box.grow(2.0), Color(0.04, 0.06, 0.08, 0.68), true)
	var texture := _entity_texture(entity.kind)
	if texture != null:
		var inset := maxf(2.0, cell_size * 0.055)
		draw_texture_rect(texture, box.grow(-inset), false)
	else:
		draw_rect(box.grow(-cell_size * 0.12), entity_color, true)
	if _has_property(entity, &"YOU"):
		var selected := entity.id == _selected_you_id
		draw_arc(center, cell_size * (0.4 if selected else 0.34), 0.0, TAU, 40, Color("f5e6b5"), 4.0 if selected else 1.8)
	_draw_rule_feedback(entity.id, box, center, cell_size)


func _draw_rule_feedback(entity_id: String, box: Rect2, center: Vector2, cell_size: float) -> void:
	if _feedback_remaining <= 0.0 or not _feedback_ids.has(entity_id):
		return
	var alpha := clampf(_feedback_remaining / RULE_FEEDBACK_DURATION, 0.0, 1.0)
	var tint := Color(0.98, 0.82, 0.43, alpha)
	draw_rect(box.grow(maxf(3.0, cell_size * 0.055)), tint, false, maxf(2.0, cell_size * 0.035))
	draw_arc(center, cell_size * 0.47, -0.35, TAU - 0.35, 32, tint, maxf(1.5, cell_size * 0.018))


func _create_3d_world() -> void:
	_world_view = SubViewportContainer.new()
	_world_view.name = "World3D"
	_world_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world_view.stretch = true
	_world_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_viewport = SubViewport.new()
	_world_viewport.name = "WorldViewport"
	_world_viewport.size = Vector2i(1280, 720)
	_world_viewport.transparent_bg = false
	_world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_world_view.add_child(_world_viewport)
	add_child(_world_view)
	_world_root = Node3D.new()
	_world_root.name = "WorldRoot"
	_world_viewport.add_child(_world_root)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("10171d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a8b9c7")
	env.ambient_light_energy = 0.62
	environment.environment = env
	_world_root.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	light.light_energy = 1.25
	_world_root.add_child(light)
	_camera = Camera3D.new()
	_camera.current = true
	_camera.fov = 46.0
	_camera.near = 0.05
	_camera.far = 128.0
	_world_root.add_child(_camera)
	_world_grid_root = Node3D.new()
	_world_grid_root.name = "BoardGrid"
	_world_root.add_child(_world_grid_root)
	_world_metrix_root = Node3D.new()
	_world_metrix_root.name = "MetrixBoundaries"
	_world_root.add_child(_world_metrix_root)
	_world_entities_root = Node3D.new()
	_world_entities_root.name = "Entities"
	_world_root.add_child(_world_entities_root)
	_world_cue_root = Node3D.new()
	_world_cue_root.name = "SolvedCue"
	_world_root.add_child(_world_cue_root)
	_world_view.visible = false


func _sync_world() -> void:
	if _state == null or _world_root == null:
		return
	var changed := _sync_world_grid()
	changed = _sync_world_metrix() or changed
	changed = _sync_world_entities() or changed
	var subject: RuleGridEntity = _find_entity(_selected_you_id)
	var subject_signature := "none"
	if subject != null:
		subject_signature = "%s:%d:%d" % [subject.id, subject.position.x, subject.position.y]
	var camera_signature := "%d:%d:%d:%s:%s" % [_state.width, _state.height, _camera_quadrant, _first_person_3d, subject_signature]
	if camera_signature != _last_camera_signature:
		_sync_world_camera()
		_last_camera_signature = camera_signature
		changed = true
	_sync_active_feedback_rings()
	if changed:
		_request_world_redraw()


func _sync_world_grid() -> bool:
	var signature := "%d:%d" % [_state.width, _state.height]
	if signature == _world_grid_signature:
		return false
	for child: Node in _world_grid_root.get_children():
		_world_grid_root.remove_child(child)
		child.free()
	var width := float(_state.width)
	var height := float(_state.height)
	var center := Vector3((width - 1.0) * 0.5, 0.0, (height - 1.0) * 0.5)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(width + 0.2, height + 0.2)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("202830")
	floor_material.roughness = 0.92
	var floor := MeshInstance3D.new()
	floor.mesh = floor_mesh
	floor.material_override = floor_material
	floor.position = Vector3(center.x, -0.08, center.z)
	floor.rotation.x = -PI * 0.5
	_world_grid_root.add_child(floor)
	var tile_mesh := BoxMesh.new()
	tile_mesh.size = Vector3(0.94, 0.12, 0.94)
	var light_tile_material := StandardMaterial3D.new()
	light_tile_material.albedo_color = Color("27323a")
	light_tile_material.roughness = 0.88
	var dark_tile_material := StandardMaterial3D.new()
	dark_tile_material.albedo_color = Color("303b43")
	dark_tile_material.roughness = 0.88
	for y: int in range(_state.height):
		for x: int in range(_state.width):
			var tile := MeshInstance3D.new()
			tile.mesh = tile_mesh
			tile.material_override = light_tile_material if (x + y) % 2 == 0 else dark_tile_material
			tile.position = Vector3(float(x), -0.01, float(y))
			_world_grid_root.add_child(tile)
	_world_grid_signature = signature
	return true


func _sync_world_metrix() -> bool:
	var signature_parts: Array = []
	for shape: Dictionary in _metrix:
		if not bool(shape.get("inventory", false)):
			continue
		var bounds: Variant = shape.get("bounds")
		if not bounds is Rect2i:
			continue
		signature_parts.append([String(shape.get("id", "")), bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y])
	var signature := JSON.stringify(signature_parts)
	if signature == _world_metrix_signature:
		return false
	for child: Node in _world_metrix_root.get_children():
		_world_metrix_root.remove_child(child)
		child.free()
	for shape: Dictionary in _metrix:
		if not bool(shape.get("inventory", false)):
			continue
		var bounds: Variant = shape.get("bounds")
		if not bounds is Rect2i:
			continue
		var outline := BoxMesh.new()
		outline.size = Vector3(float(bounds.size.x), 0.04, float(bounds.size.y))
		var outline_mesh := MeshInstance3D.new()
		outline_mesh.mesh = outline
		var outline_material := StandardMaterial3D.new()
		outline_material.albedo_color = Color("9885e0", 0.22)
		outline_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		outline_mesh.material_override = outline_material
		outline_mesh.position = Vector3(float(bounds.position.x) + (float(bounds.size.x) - 1.0) * 0.5, 0.02, float(bounds.position.y) + (float(bounds.size.y) - 1.0) * 0.5)
		_world_metrix_root.add_child(outline_mesh)
	_world_metrix_signature = signature
	return true


func _sync_world_camera() -> void:
	var width := float(_state.width)
	var height := float(_state.height)
	var center := Vector3((width - 1.0) * 0.5, 0.0, (height - 1.0) * 0.5)
	if _first_person_3d:
		var subject: RuleGridEntity = _find_entity(_selected_you_id)
		if subject != null:
			var forward := _camera_forward()
			var max_x := maxf(0.0, width - 1.0)
			var max_z := maxf(0.0, height - 1.0)
			var eye := Vector3(
				clampf(float(subject.position.x) - forward.x * FIRST_PERSON_EYE_BACK_DISTANCE, 0.0, max_x),
				0.72,
				clampf(float(subject.position.y) - forward.z * FIRST_PERSON_EYE_BACK_DISTANCE, 0.0, max_z)
			)
			_camera.fov = 74.0
			_camera.position = eye
			_camera.look_at(eye + forward * 4.0 + Vector3(0.0, -0.12, 0.0), Vector3.UP)
			return
	var camera_target := center + Vector3(0.0, 0.15, 0.0)
	var distance := maxf(width, height) * 1.1
	var offset := Vector2(distance * 0.68, distance * 0.86).rotated(float(_camera_quadrant) * PI * 0.5)
	_camera.fov = 46.0
	_camera.position = camera_target + Vector3(offset.x, distance * 0.9, offset.y)
	_camera.look_at(camera_target, Vector3.UP)


func _camera_forward() -> Vector3:
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var direction := directions[_camera_quadrant]
	return Vector3(float(direction.x), 0.0, float(direction.y))


func _sync_world_entities() -> bool:
	var changed := false
	var live_ids: Dictionary = {}
	for entity: RuleGridEntity in _state.entities:
		if entity == null:
			continue
		live_ids[entity.id] = true
		var signature := _world_entity_signature(entity)
		var node: Node3D = _world_entity_nodes.get(entity.id)
		if node == null or String(_world_entity_signatures.get(entity.id, "")) != signature:
			if node != null:
				_feedback_ring_nodes.erase(entity.id)
				_world_entities_root.remove_child(node)
				node.queue_free()
			var new_node := _add_world_entity(entity)
			_world_entity_nodes[entity.id] = new_node
			_world_entity_signatures[entity.id] = signature
			node = new_node
			changed = true
		var target := Vector3(float(entity.position.x), 0.0, float(entity.position.y))
		if node.position != target:
			node.position = target
			changed = true
	for entity_id_value: Variant in _world_entity_nodes.keys():
		var entity_id := String(entity_id_value)
		if live_ids.has(entity_id):
			continue
		var stale: Node3D = _world_entity_nodes[entity_id]
		_world_entities_root.remove_child(stale)
		stale.queue_free()
		_world_entity_nodes.erase(entity_id)
		_world_entity_signatures.erase(entity_id)
		_feedback_ring_nodes.erase(entity_id)
		changed = true
	return changed


func _world_entity_signature(entity: RuleGridEntity) -> String:
	return JSON.stringify([
		String(entity.kind), entity.is_word, String(entity.word_role), String(entity.word_value),
		_has_property(entity, &"YOU"), entity.id == _selected_you_id,
		_mode_3d and _first_person_3d and entity.id == _selected_you_id
	])


func _request_world_redraw() -> void:
	if _world_viewport != null:
		_world_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _sync_world_solved_cue() -> void:
	if _world_cue_root == null:
		return
	var cells: Array[Vector2i] = []
	if _mode_3d and _solved and _solved_cue > 0.0:
		cells = _solved_cue_cells
	var signature := JSON.stringify(cells)
	if signature != _world_cue_signature:
		for child: Node in _world_cue_root.get_children():
			_world_cue_root.remove_child(child)
			child.queue_free()
		_world_cue_materials.clear()
		for cell: Vector2i in cells:
			_world_cue_materials.append(_add_world_solved_cue(cell))
		_world_cue_signature = signature
	if _world_cue_materials.is_empty():
		return
	var strength := clampf(_solved_cue, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin((1.0 - strength) * PI)
	for index: int in range(_world_cue_materials.size()):
		var material: StandardMaterial3D = _world_cue_materials[index]
		material.albedo_color = Color(1.0, 0.93, 0.6, strength)
		var cue_node := _world_cue_root.get_child(index) as Node3D
		if cue_node != null:
			cue_node.scale = Vector3.ONE * (0.6 + 0.55 * pulse)
	if _mode_3d:
		_request_world_redraw()


func _add_world_solved_cue(cell: Vector2i) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.93, 0.6, 1.0)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cue := Node3D.new()
	cue.name = "SolvedCueCell"
	cue.position = Vector3(float(cell.x), 0.0, float(cell.y))
	_world_cue_root.add_child(cue)
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.4
	beam_mesh.bottom_radius = 0.4
	beam_mesh.height = 1.5
	beam_mesh.radial_segments = 12
	var beam := MeshInstance3D.new()
	beam.mesh = beam_mesh
	beam.material_override = material
	beam.position = Vector3(0.0, 0.75, 0.0)
	cue.add_child(beam)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.4
	ring_mesh.outer_radius = 0.54
	ring_mesh.ring_segments = 20
	ring_mesh.rings = 8
	var ring := MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.material_override = material
	ring.rotation_degrees.x = 90.0
	ring.position = Vector3(0.0, 0.05, 0.0)
	cue.add_child(ring)
	return material


func _sync_active_feedback_rings() -> void:
	for entity_id_value: Variant in _feedback_ring_nodes.keys():
		var entity_id := String(entity_id_value)
		if _feedback_remaining > 0.0 and _feedback_ids.has(entity_id) \
			and _world_entity_nodes.has(entity_id):
			continue
		var ring: MeshInstance3D = _feedback_ring_nodes[entity_id]
		if is_instance_valid(ring):
			var parent := ring.get_parent()
			if parent != null:
				parent.remove_child(ring)
			ring.queue_free()
		_feedback_ring_nodes.erase(entity_id)
	for entity_id_value: Variant in _feedback_ids.keys():
		var entity_id := String(entity_id_value)
		if _feedback_remaining <= 0.0 or not _world_entity_nodes.has(entity_id) \
			or _feedback_ring_nodes.has(entity_id):
			continue
		var entity_root: Node3D = _world_entity_nodes[entity_id]
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.39
		ring_mesh.outer_radius = 0.46
		ring_mesh.ring_segments = 20
		ring_mesh.rings = 8
		var ring := MeshInstance3D.new()
		ring.name = "RuleChangeFeedback"
		ring.mesh = ring_mesh
		ring.rotation_degrees.x = 90.0
		ring.position = Vector3(0.0, 0.035, 0.0)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.98, 0.82, 0.43, clampf(_feedback_remaining / RULE_FEEDBACK_DURATION, 0.0, 1.0))
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring.material_override = material
		entity_root.add_child(ring)
		_feedback_ring_nodes[entity_id] = ring


func _process(delta: float) -> void:
	if _feedback_remaining <= 0.0:
		set_process(false)
		return
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	var alpha := clampf(_feedback_remaining / RULE_FEEDBACK_DURATION, 0.0, 1.0)
	for ring_value: Variant in _feedback_ring_nodes.values():
		if not ring_value is MeshInstance3D or not is_instance_valid(ring_value):
			continue
		var material := ring_value.material_override as StandardMaterial3D
		if material != null:
			var tint := material.albedo_color
			tint.a = alpha
			material.albedo_color = tint
	if _mode_3d:
		_sync_active_feedback_rings()
		_request_world_redraw()
	queue_redraw()
	if _feedback_remaining <= 0.0:
		_feedback_ids.clear()
		_sync_active_feedback_rings()
		set_process(false)


func _add_world_entity(entity: RuleGridEntity) -> Node3D:
	var entity_root := Node3D.new()
	entity_root.name = "Entity"
	entity_root.position = Vector3(float(entity.position.x), 0.0, float(entity.position.y))
	_world_entities_root.add_child(entity_root)
	if _mode_3d and _first_person_3d and entity.id == _selected_you_id:
		return entity_root
	var color := _word_color(entity) if entity.is_word else _entity_color(entity.kind)
	var is_you := _has_property(entity, &"YOU")
	var marker_height := 0.0
	if entity.is_word:
		var object_size := Vector3(0.7, 0.62, 0.7)
		var box_mesh := BoxMesh.new()
		box_mesh.size = object_size
		var object := MeshInstance3D.new()
		object.mesh = box_mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.74
		material.metallic = 0.08
		object.material_override = material
		object.position = Vector3(0.0, object_size.y * 0.5, 0.0)
		entity_root.add_child(object)
		var text_mesh := TextMesh.new()
		text_mesh.text = String(entity.word_value)
		var label_font: Font = ThemeDB.fallback_font
		text_mesh.font = label_font
		var label_font_size := 64
		var label_pixel_width := label_font.get_string_size(
			text_mesh.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label_font_size
		).x
		while label_font_size > 40 and label_pixel_width * 0.0048 > 0.76:
			label_font_size -= 1
			label_pixel_width = label_font.get_string_size(
				text_mesh.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label_font_size
			).x
		text_mesh.font_size = label_font_size
		text_mesh.depth = 0.015
		text_mesh.pixel_size = 0.0048
		var label := MeshInstance3D.new()
		label.mesh = text_mesh
		var label_material := StandardMaterial3D.new()
		label_material.albedo_color = Color("111419")
		label_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		label_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		label.material_override = label_material
		label.position = Vector3(0.0, object_size.y + 0.035, 0.0)
		entity_root.add_child(label)
		marker_height = object_size.y
	else:
		var texture := _entity_texture(entity.kind)
		if texture != null:
			var sprite := Sprite3D.new()
			sprite.texture = texture
			sprite.pixel_size = 0.009
			sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sprite.position = Vector3(0.0, sprite.pixel_size * float(texture.get_height()) * 0.5, 0.0)
			entity_root.add_child(sprite)
			marker_height = sprite.pixel_size * float(texture.get_height()) * 0.82
		else:
			var fallback_mesh := BoxMesh.new()
			fallback_mesh.size = Vector3(0.72, 0.16, 0.72)
			var fallback := MeshInstance3D.new()
			fallback.mesh = fallback_mesh
			var fallback_material := StandardMaterial3D.new()
			fallback_material.albedo_color = color
			fallback.material_override = fallback_material
			fallback.position.y = 0.08
			entity_root.add_child(fallback)
			marker_height = 0.16
	if is_you:
		var marker := MeshInstance3D.new()
		var marker_mesh := SphereMesh.new()
		marker_mesh.radius = 0.07
		marker_mesh.height = 0.14
		marker.mesh = marker_mesh
		var marker_material := StandardMaterial3D.new()
		marker_material.albedo_color = Color("fff0b0")
		marker.material_override = marker_material
		marker.position = Vector3(0.0, marker_height + 0.18, 0.0)
		entity_root.add_child(marker)
		if entity.id == _selected_you_id:
			var focus_marker := MeshInstance3D.new()
			var focus_mesh := TorusMesh.new()
			focus_mesh.inner_radius = 0.32
			focus_mesh.outer_radius = 0.38
			focus_mesh.ring_segments = 16
			focus_mesh.rings = 8
			focus_marker.mesh = focus_mesh
			var focus_material := StandardMaterial3D.new()
			focus_material.albedo_color = Color("f3d276")
			focus_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			focus_marker.material_override = focus_material
			focus_marker.position = Vector3(0.0, 0.09, 0.0)
			entity_root.add_child(focus_marker)
	return entity_root


func _create_hotbar() -> void:
	_hotbar_panel = PanelContainer.new()
	_hotbar_panel.name = "Hotbar"
	_hotbar_panel.anchor_left = 0.5
	_hotbar_panel.anchor_right = 0.5
	_hotbar_panel.anchor_top = 1.0
	_hotbar_panel.anchor_bottom = 1.0
	_hotbar_panel.offset_left = -342.0
	_hotbar_panel.offset_right = 342.0
	_hotbar_panel.offset_top = -84.0
	_hotbar_panel.offset_bottom = -18.0
	_hotbar_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.08, 0.86)
	style.border_color = Color("697780")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	_hotbar_panel.add_theme_stylebox_override("panel", style)
	add_child(_hotbar_panel)


func _rebuild_hotbar() -> void:
	if _hotbar_panel == null:
		return
	for child: Node in _hotbar_panel.get_children():
		_hotbar_panel.remove_child(child)
		child.free()
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	_hotbar_panel.add_child(row)
	var slots := _inventory_slots()
	for index: int in range(9):
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(68.0, 58.0)
		slot.text = ""
		slot.disabled = not _interactive
		_style_slot(slot, index == _hotbar_slot)
		_add_slot_preview(slot, slots, index, index + 1)
		slot.pressed.connect(func() -> void: command_requested.emit(&"hotbar", {"slot": index}))
		row.add_child(slot)


func _create_inventory() -> void:
	_inventory_panel = PanelContainer.new()
	_inventory_panel.name = "InventoryPanel"
	_inventory_panel.anchor_left = 0.5
	_inventory_panel.anchor_right = 0.5
	_inventory_panel.anchor_top = 0.5
	_inventory_panel.anchor_bottom = 0.5
	_inventory_panel.offset_left = -340.0
	_inventory_panel.offset_right = 340.0
	_inventory_panel.offset_top = -230.0
	_inventory_panel.offset_bottom = 230.0
	_inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_inventory_panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color("d6d7d8")
	style.border_color = Color("252c32")
	style.set_border_width_all(4)
	style.set_corner_radius_all(3)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	_inventory_panel.add_theme_stylebox_override("panel", style)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	_inventory_panel.add_child(body)
	var title := Label.new()
	title.text = "INVENTORY"
	title.add_theme_color_override("font_color", Color("30363b"))
	title.add_theme_font_size_override("font_size", 20)
	body.add_child(title)
	_inventory_grid = GridContainer.new()
	_inventory_grid.name = "InventorySlots"
	_inventory_grid.add_theme_constant_override("h_separation", 4)
	_inventory_grid.add_theme_constant_override("v_separation", 4)
	body.add_child(_inventory_grid)
	add_child(_inventory_panel)


func _rebuild_inventory() -> void:
	if _inventory_grid == null:
		return
	for child: Node in _inventory_grid.get_children():
		_inventory_grid.remove_child(child)
		child.free()
	var inner_width := 1
	if not _selected_metrix.is_empty():
		var bounds: Variant = _selected_metrix.get("bounds")
		if bounds is Rect2i:
			inner_width = maxi(1, bounds.size.x - 2)
	_inventory_grid.columns = inner_width
	var slots := _inventory_slots()
	var slot_width := minf(78.0, maxf(38.0, (size.x * 0.82 - 52.0) / float(inner_width)))
	var inner_height := maxi(1, int(_selected_metrix.get("bounds", Rect2i()).size.y) - 2)
	var slot_height := minf(56.0, maxf(36.0, (size.y * 0.76 - 120.0) / float(inner_height)))
	for index: int in range(slots.size()):
		var button := Button.new()
		button.custom_minimum_size = Vector2(slot_width, slot_height)
		button.text = ""
		button.disabled = not _interactive
		_style_slot(button, index == _focused_slot)
		_add_slot_preview(button, slots, index, index + 1)
		button.pressed.connect(func() -> void: command_requested.emit(&"inventory_slot", {"slot": index}))
		_inventory_grid.add_child(button)
	if slots.is_empty():
		var empty := Label.new()
		empty.text = "빈 인벤토리"
		empty.add_theme_color_override("font_color", Color("383f44"))
		_inventory_grid.add_child(empty)


func _resize_inventory_panel() -> void:
	if _inventory_panel == null:
		return
	var inner_width := 1
	var inner_height := 1
	var bounds: Variant = _selected_metrix.get("bounds")
	if bounds is Rect2i:
		inner_width = maxi(1, bounds.size.x - 2)
		inner_height = maxi(1, bounds.size.y - 2)
	var panel_width := minf(size.x * 0.9, maxf(310.0, float(inner_width) * 78.0 + 52.0))
	var panel_height := minf(size.y * 0.86, maxf(220.0, float(inner_height) * 56.0 + 64.0))
	_inventory_panel.offset_left = -panel_width * 0.5
	_inventory_panel.offset_right = panel_width * 0.5
	_inventory_panel.offset_top = -panel_height * 0.5
	_inventory_panel.offset_bottom = panel_height * 0.5


func _create_recovery() -> void:
	_recovery_panel = PanelContainer.new()
	_recovery_panel.name = "Recovery"
	_recovery_panel.anchor_left = 0.5
	_recovery_panel.anchor_right = 0.5
	_recovery_panel.anchor_top = 0.0
	_recovery_panel.anchor_bottom = 0.0
	_recovery_panel.offset_left = -300.0
	_recovery_panel.offset_right = 300.0
	_recovery_panel.offset_top = 28.0
	_recovery_panel.offset_bottom = 130.0
	_recovery_panel.visible = false
	_recovery_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.07, 0.09, 0.94)
	style.border_color = Color("9f7c67")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	_recovery_panel.add_theme_stylebox_override("panel", style)
	_recovery_text = Label.new()
	_recovery_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_recovery_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_recovery_text.add_theme_font_size_override("font_size", 20)
	_recovery_text.add_theme_color_override("font_color", Color("f0e3ce"))
	_recovery_panel.add_child(_recovery_text)
	add_child(_recovery_panel)


func _create_message_panel() -> void:
	_message_panel = PanelContainer.new()
	_message_panel.name = "TransientMessage"
	_message_panel.anchor_left = 0.5
	_message_panel.anchor_right = 0.5
	_message_panel.anchor_top = 0.0
	_message_panel.anchor_bottom = 0.0
	_message_panel.offset_top = 14.0
	_message_panel.visible = false
	_message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.08, 0.92)
	style.border_color = Color("52616a")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	_message_panel.add_theme_stylebox_override("panel", style)
	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.add_theme_font_size_override("font_size", 17)
	_message_label.add_theme_color_override("font_color", Color("d9e3e6"))
	_message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_message_panel.add_child(_message_label)
	add_child(_message_panel)


func _resize_message_panel() -> void:
	if _message_panel == null or _message_label == null:
		return
	var panel_width := minf(960.0, maxf(240.0, size.x - 48.0))
	var text_width := maxf(1.0, panel_width - 32.0)
	var font_width := ThemeDB.fallback_font.get_string_size(_message, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 17).x
	var estimated_lines := maxi(1, ceili(font_width / text_width))
	var panel_height := minf(104.0, maxf(44.0, float(estimated_lines) * 23.0 + 18.0))
	_message_panel.offset_left = -panel_width * 0.5
	_message_panel.offset_right = panel_width * 0.5
	_message_panel.offset_bottom = 14.0 + panel_height
	_message_label.custom_minimum_size = Vector2(text_width, panel_height - 16.0)


func _inventory_slots() -> Array[Dictionary]:
	if _selected_metrix.is_empty():
		return []
	var raw_slots: Variant = _selected_metrix.get("slots", [])
	return raw_slots if raw_slots is Array else []


func _inventory_view_signature() -> String:
	var parts: Array = [
		String(_selected_metrix.get("id", "")), _focused_slot, _held_id, _hotbar_slot,
		_interactive, _inventory_open
	]
	var entities_by_id: Dictionary = {}
	for entity: RuleGridEntity in _state.entities:
		entities_by_id[entity.id] = entity
	for slot: Dictionary in _inventory_slots():
		var slot_parts: Array = []
		var raw_ids: Variant = slot.get("entity_ids", [])
		if raw_ids is Array:
			for entity_id_value: Variant in raw_ids:
				var entity: RuleGridEntity = entities_by_id.get(String(entity_id_value))
				if entity == null:
					slot_parts.append(String(entity_id_value))
					continue
				slot_parts.append([
					entity.id, String(entity.kind), entity.is_word, String(entity.word_role),
					String(entity.word_value)
				])
		parts.append(slot_parts)
	return JSON.stringify(parts)


func _add_slot_preview(button: Button, slots: Array[Dictionary], index: int, number: int) -> void:
	var preview := ItemThumbnail.new()
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview.configure(null, "", &"", number, 0)
	if index < slots.size():
		var raw_ids: Variant = slots[index].get("entity_ids", [])
		var first_entity: RuleGridEntity
		var count := 0
		if raw_ids is Array:
			for entity_id_value: Variant in raw_ids:
				if not entity_id_value is String:
					continue
				var entity := _find_entity(entity_id_value)
				if entity == null:
					continue
				if first_entity == null:
					first_entity = entity
				count += 1
		if first_entity != null:
			var label := String(first_entity.word_value) if first_entity.is_word else String(first_entity.kind)
			preview.configure(
				_entity_texture(first_entity.kind) if not first_entity.is_word else null,
				label,
				first_entity.word_role if first_entity.is_word else &"",
				number,
				count
			)
	button.add_child(preview)


func _style_slot(button: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("242c32")
	normal.border_color = Color("73818a")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(3)
	var chosen := normal.duplicate() as StyleBoxFlat
	chosen.bg_color = Color("3e4750")
	chosen.border_color = Color("f0cf70")
	chosen.set_border_width_all(4)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", chosen)
	button.add_theme_stylebox_override("pressed", chosen)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_color_override("font_color", Color("f0eee6"))
	button.add_theme_color_override("font_disabled_color", Color("788087"))
	if selected:
		button.add_theme_stylebox_override("normal", chosen)


func _entities_by_cell() -> Dictionary:
	var result: Dictionary = {}
	for entity: RuleGridEntity in _state.entities:
		var at_cell: Array[RuleGridEntity] = []
		var existing: Variant = result.get(entity.position, [])
		if existing is Array:
			for value: Variant in existing:
				if value is RuleGridEntity:
					at_cell.append(value)
		at_cell.append(entity)
		result[entity.position] = at_cell
	return result


func _overlap_offsets(count: int, cell_size: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if count <= 1:
		result.append(Vector2.ZERO)
		return result
	var radius := minf(cell_size * 0.23, 20.0)
	for index: int in range(count):
		var angle := TAU * float(index) / float(count) - PI * 0.5
		result.append(Vector2(cos(angle), sin(angle)) * radius)
	return result


func _entity_less(left: RuleGridEntity, right: RuleGridEntity) -> bool:
	if left.layer != right.layer:
		return left.layer < right.layer
	if left.creation_serial != right.creation_serial:
		return left.creation_serial < right.creation_serial
	return left.id < right.id


func _entity_texture(kind: StringName) -> Texture2D:
	var key := String(kind)
	if not _textures.has(key):
		var path := "res://modules/rule_rewriting/art/%s.svg" % key.to_lower()
		if ResourceLoader.exists(path):
			var texture := load(path) as Texture2D
			if texture != null:
				_textures[key] = texture
	return _textures.get(key) as Texture2D


func _entity_color(kind: StringName) -> Color:
	if COLORS.has(String(kind)):
		return COLORS[String(kind)]
	return PALETTE[posmod(kind.hash(), PALETTE.size())]


func _word_color(entity: RuleGridEntity) -> Color:
	if entity.word_role == &"operator":
		return Color("ece9de")
	if entity.word_role == &"property":
		return Color("78c7bb")
	return Color("e8a1a5")


func _fit_text_size(text: String, available_width: float, starting_size: int) -> int:
	var font := ThemeDB.fallback_font
	var font_size := starting_size
	while font_size > 8 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > available_width:
		font_size -= 1
	return font_size


func _is_active_word(entity_id: String) -> bool:
	if _rules == null:
		return false
	for sentence: RuleSentence in _rules.sentences:
		if sentence.source_entity_ids.has(entity_id):
			return true
	return false


func _has_property(entity: RuleGridEntity, property: StringName) -> bool:
	return _state != null and RuleEvaluator.has_property(entity, property, _rules, _state)


func _find_entity(entity_id: String) -> RuleGridEntity:
	if _state == null:
		return null
	for entity: RuleGridEntity in _state.entities:
		if entity.id == entity_id:
			return entity
	return null


func _on_resized() -> void:
	_resize_inventory_panel()
	_resize_message_panel()
	if _hotbar_panel != null and _state != null:
		_rebuild_hotbar()
		if _inventory_grid != null and _inventory_panel.visible:
			_rebuild_inventory()
	queue_redraw()
