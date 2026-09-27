extends Node

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const ContentIndex = preload("res://modules/physics_puzzle_platformer/systems/content_index.gd")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")
const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const SETTLE_FRAMES: int = 90

var out_dir: String = ""
var capture_size: Vector2i = Vector2i.ZERO
var _frame: SubViewport
var report: Array[String] = []


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--size="):
			var parts: PackedStringArray = arg.substr(7).split("x")
			capture_size = Vector2i(int(parts[0]), int(parts[1]))
	_run.call_deferred()


func _run() -> void:
	var content: RefCounted = ContentIndex.new().read_default()
	for error: String in content.errors:
		report.append("CONTENT_ERROR %s" % error)
	var size: Vector2i = capture_size if capture_size != Vector2i.ZERO else get_window().size
	_frame = SubViewport.new()
	_frame.size = size
	_frame.disable_3d = true
	_frame.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_frame)
	var total: float = 0.0
	for level_id: String in content.level_order:
		var module: Node = _spawn(level_id)
		for _i: int in SETTLE_FRAMES:
			await get_tree().physics_frame
		await RenderingServer.frame_post_draw
		var route: float = _route_length(module)
		var seconds: float = route / Tuning.MOVE_SPEED
		total += seconds
		report.append("LEVEL %s eggs=%d needed=%d route_px=%.0f walk_s=%.1f" % [level_id, _egg_count(module), module.get_world_state().objective_needed, route, seconds])
		if not out_dir.is_empty():
			var path: String = out_dir.path_join("ppp_%s_%dx%d.png" % [level_id, size.x, size.y])
			_frame.get_texture().get_image().save_png(path)
			report.append("CAPTURE %s" % path)
		module.exit()
		_frame.remove_child(module)
		module.free()
	report.append("TOTAL walk_s=%.1f" % total)
	for line: String in report:
		print("PPP_PROBE ", line)
	get_tree().quit(0)


func _spawn(level_id: String) -> Node:
	var module: Node = ENTRY.instantiate()
	_frame.add_child(module)
	var context := ModuleContext.new()
	context.module_id = MANIFEST.id
	context.input_enabled = true
	for action: String in MANIFEST.input_actions:
		context.allowed_actions.append(StringName(action))
	var levels: Array = []
	var tools: Array = []
	for _i: int in Tuning.LEVEL_COUNT:
		levels.append(level_id)
		tools.append("tool_paper_fan")
	context.arrival = {"ppp_seed": 4242, "ppp_sequence": levels, "ppp_tools": tools}
	module.load_state({})
	module.enter(context)
	for action: String in InputBubble.PROFILE:
		module.bubble.pop(action)
	module.step(0.5)
	module.step(1.0)
	return module


func _egg_count(module: Node) -> int:
	var count: int = 0
	for body: RefCounted in module.get_world_state().bodies:
		if body.kind == BodyKind.OBJECTIVE:
			count += 1
	return count


func _route_length(module: Node) -> float:
	var world: RefCounted = module.get_world_state()
	var spec: RefCounted = module.get_director().spec
	var remaining: Array[Vector2] = []
	for body: RefCounted in world.bodies:
		if body.kind == BodyKind.OBJECTIVE:
			remaining.append(Vector2(body.home_x, body.home_y))
	var at: Vector2 = spec.spawn
	var length: float = 0.0
	for _step: int in world.objective_needed:
		var best: int = 0
		for index: int in remaining.size():
			if at.distance_to(remaining[index]) < at.distance_to(remaining[best]):
				best = index
		length += absf(remaining[best].x - at.x) + absf(remaining[best].y - at.y)
		at = remaining[best]
		remaining.remove_at(best)
	length += absf(spec.rift_pos.x - at.x) + absf(spec.rift_pos.y - at.y)
	return length
