class_name ModuleDirector
extends Node

signal module_changed(id: StringName)
signal module_finished(result: ModuleResult)
signal module_requested(kind: StringName, payload: Dictionary)

var current_module: GameModule
var current_id: StringName = &""
var busy: bool = false
var _host: Node
var _catalog: Dictionary = {}
var _router: InputRouter
var _saves: SaveService
var _transition: TransitionService
var _pending_result: ModuleResult
var _configured: bool = false

func setup(host: Node, catalog: Array[ModuleManifest], router: InputRouter, saves: SaveService, transition: TransitionService) -> void:
	_host = host
	_router = router
	_saves = saves
	_transition = transition
	_catalog.clear()
	_configured = host != null and router != null and saves != null and transition != null
	for manifest: ModuleManifest in catalog:
		if manifest == null or manifest.id.is_empty() or manifest.save_version < 1 or manifest.entry_scene.is_empty():
			_configured = false
			continue
		if _catalog.has(manifest.id):
			_configured = false
		_catalog[manifest.id] = manifest

func change_module(id: StringName, restore_snapshot: bool = false, arrival: Dictionary = {}, identity: Dictionary = {}, discard_current: bool = false) -> Error:
	if busy:
		return ERR_BUSY
	if not _configured:
		return ERR_UNCONFIGURED
	if not _catalog.has(id):
		return ERR_DOES_NOT_EXIST
	var manifest: ModuleManifest = _catalog[id]
	if not ResourceLoader.exists(manifest.entry_scene, "PackedScene"):
		return ERR_FILE_NOT_FOUND
	busy = true
	var packed := ResourceLoader.load(manifest.entry_scene) as PackedScene
	if packed == null:
		busy = false
		return ERR_INVALID_DATA
	var instance: Node = packed.instantiate()
	if not instance is GameModule:
		instance.free()
		busy = false
		return ERR_INVALID_DATA
	var next: GameModule = instance as GameModule
	var record: Dictionary = _saves.get_module_state(id)
	if not record.is_empty() and int(record["schema_version"]) > manifest.save_version:
		next.free()
		busy = false
		return ERR_INVALID_DATA
	if not restore_snapshot and not discard_current:
		capture_current()
		record = _saves.get_module_state(id)
	var state: Dictionary = record.get("state", {}).duplicate(true)
	if not record.is_empty() and int(record["schema_version"]) < manifest.save_version:
		state = next.migrate_save(int(record["schema_version"]), state)
	if not SaveService.is_json_safe(state):
		next.free()
		busy = false
		return ERR_INVALID_DATA
	var context := ModuleContext.new()
	context.module_id = id
	context.arrival = arrival.duplicate(true)
	context.identity_view = identity.duplicate(true)
	for action: String in manifest.input_actions:
		context.allowed_actions.append(StringName(action))
	var prior_lock: bool = _router.locked
	_router.set_locked(true)
	if current_module != null:
		current_module.process_mode = Node.PROCESS_MODE_DISABLED
	await _transition.fade_out()
	_dispose_current()
	current_module = next
	current_id = id
	var next_mode: Node.ProcessMode = next.process_mode
	next.process_mode = Node.PROCESS_MODE_DISABLED
	next.context = context
	next.finished.connect(_on_finished.bind(next))
	next.requested.connect(_on_requested.bind(next))
	_host.add_child(next)
	next.load_state(state)
	next.enter(context)
	_router.activate(context)
	_saves.current_module = id
	await _transition.fade_in()
	next.process_mode = next_mode
	_router.set_locked(prior_lock)
	module_changed.emit(id)
	busy = false
	if _pending_result != null:
		var pending: ModuleResult = _pending_result
		_pending_result = null
		module_finished.emit(pending)
	return OK

func capture_current() -> void:
	if current_module == null:
		return
	var manifest: ModuleManifest = _catalog[current_id]
	_saves.set_module_state(current_id, manifest.save_version, current_module.save_state())
	_saves.current_module = current_id

func unload_module() -> void:
	if busy:
		return
	capture_current()
	_dispose_current()
	if _saves != null:
		_saves.current_module = &""

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if busy or current_module == null or _router.locked:
		return false
	return current_module.execute_command(command, payload)

func _dispose_current() -> void:
	_router.deactivate()
	_pending_result = null
	if current_module != null:
		var previous: GameModule = current_module
		current_module = null
		current_id = &""
		previous.exit()
		_host.remove_child(previous)
		previous.free()

func _on_requested(kind: StringName, payload: Dictionary, source: GameModule) -> void:
	if busy or not is_instance_valid(source) or source != current_module:
		return
	if source.context == null or not source.context.input_enabled:
		return
	if _router == null or _router.locked:
		return
	module_requested.emit(kind, payload.duplicate(true))

func _on_finished(result: ModuleResult, source: GameModule) -> void:
	if source != current_module or result == null:
		return
	result.module_id = current_id
	if busy:
		_pending_result = result
	else:
		module_finished.emit(result)
