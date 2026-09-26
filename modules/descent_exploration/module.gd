class_name DescentModule
extends GameModule

const MODULE_ID: StringName = &"descent_exploration"
const SAVE_VERSION: int = 1
const FIRST_FRAME_HOLD: float = 0.15
const VEIL_TOTAL: float = 0.90
const VEIL_FADE_OUT: float = 0.35
const VEIL_FLASH_TIME: float = 0.15
const ENDING_HOLD: float = 1.60
const ANCHOR_FLASH: float = 3.00
const WORLDSTATE_REQUEST_MAX_PER_RUN: int = 1
const SWIM_SOUND_SPEED: float = 6.0
const ACTION_UP: StringName = &"descent_exploration_up"
const ACTION_DOWN: StringName = &"descent_exploration_down"
const ACTION_LEFT: StringName = &"descent_exploration_left"
const ACTION_RIGHT: StringName = &"descent_exploration_right"
const ACTION_SURGE: StringName = &"descent_exploration_confirm"
const ACTION_CONSUME: StringName = &"descent_exploration_cancel"
const REQUIRED_ACTIONS: Array[StringName] = [ACTION_UP, ACTION_DOWN, ACTION_LEFT, ACTION_RIGHT, ACTION_SURGE, ACTION_CONSUME]
const AUDIO_MANIFEST_PATH: String = "res://modules/descent_exploration/audio_manifest.json"
const BRITTLE_WOUND: Dictionary = {"part": "torso", "kind": "shard", "severity": 1, "permanent": true}
const PERSIST_KEY: String = "persist_checkpoint"
const REQUEST_KEY: String = "request_mutation"
const PREVIOUS_KEYS_KEY: String = "previous_required_keys"

var state: DescentState = DescentState.new()
var loader: DescentContentLoader = DescentContentLoader.new()
var runtime: StratumRuntime = null
var world: DescentWorldstateView = DescentWorldstateView.new()
var body: BodyRead = null
var clock: DescentClock = DescentClock.new()
var frame_events: Array[StringName] = []
var anchor_flash_for: float = 0.0
var mutation_requested: bool = false

var _audio: AudioEventPlayer = null
var _content_ready: bool = false
var _held_surge: bool = false
var _held_consume: bool = false
var _profile_sent: bool = false
var _swapped: bool = false
var _warned: Array[String] = []
var _bubble: Dictionary = {}


func _ready() -> void:
	set_physics_process(false)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_ensure_content()
	world = DescentWorldstateView.from_arrival(context.arrival)
	body = world.body()
	for message: String in world.startup_warnings():
		_warn_once(message)
	if state.world_seed == 0 or state.run_id.is_empty():
		_seed_run()
	_build_runtime(state.stratum_id)
	if not ["ending", "finished"].has(state.phase):
		state.phase = "first_frame"
		state.phase_time = 0.0
	_held_surge = false
	_held_consume = false
	_profile_sent = false
	frame_events.clear()
	clock.reset()
	_setup_audio()
	set_physics_process(true)


func exit() -> void:
	set_physics_process(false)
	if _audio != null and is_instance_valid(_audio):
		_audio.stop_all()
	super.exit()


func save_state() -> Dictionary:
	return state.to_save()


func load_state(data: Dictionary) -> void:
	_ensure_content()
	var source: Dictionary = data.duplicate(true)
	var raw_version: Variant = source.get("schema", SAVE_VERSION)
	var version: int = int(raw_version) if (raw_version is int or raw_version is float) else 0
	var migrated: Dictionary = migrate_save(version, source)
	var migrated_version: Variant = migrated.get("schema", SAVE_VERSION)
	if not (migrated_version is int or migrated_version is float) or int(migrated_version) != DescentState.SCHEMA:
		migrated = {}
	var loaded: DescentState = DescentState.from_save(migrated)
	if not loader.has_stratum(loaded.stratum_id):
		if migrated.has("stratum_id"):
			_warn_once("descent: stratum '%s' is not authored; continuing in the next authored stratum" % loaded.stratum_id)
		loaded.stratum_id = loader.id_at_or_after(loaded.stratum_index)
		var replacement: Dictionary = loader.get_stratum(loaded.stratum_id)
		loaded.position = StratumRuntime.to_point((replacement.get("spawn", {}) as Dictionary).get("position")) if not replacement.is_empty() else DescentState.DEFAULT_POSITION
	loaded.stratum_index = maxi(loader.authored_index(loaded.stratum_id), 0)
	if not _checkpoint_valid(loaded.checkpoint):
		loaded.checkpoint = _default_checkpoint(loaded)
	if loaded.ending_id.is_empty() and ["ending", "finished"].has(loaded.phase):
		loaded.phase = "playing"
	loaded.reset_transients()
	loaded.phase = "first_frame"
	state = loaded
	clock.reset()
	_build_runtime(state.stratum_id)


func migrate_save(old_version: int, data: Dictionary) -> Dictionary:
	if old_version == SAVE_VERSION:
		return data.duplicate(true)
	return {"schema": SAVE_VERSION}


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	match command:
		&"reset":
			load_state({})
			_seed_run()
			return true
		&"retry":
			load_state(save_state())
			if Vitality.recover(state):
				state.stratum_index = maxi(loader.authored_index(state.stratum_id), 0)
				_build_runtime(state.stratum_id)
			return true
		&"input_profile":
			if not payload.has("required_keys"):
				return false
			return set_key_profile(payload["required_keys"], payload.get("previous"))
	return false


func set_key_profile(profile: Variant, previous: Variant = null) -> bool:
	if not profile is Array or (profile as Array).is_empty():
		return false
	var required: Array[String] = []
	for entry: Variant in profile as Array:
		if not (entry is String or entry is StringName) or String(entry).is_empty():
			return false
		if not required.has(String(entry)):
			required.append(String(entry))
	var before: Array[String] = []
	if previous is Array:
		for entry: Variant in previous as Array:
			if (entry is String or entry is StringName) and not String(entry).is_empty() and not before.has(String(entry)):
				before.append(String(entry))
	var slots: Array[Dictionary] = []
	for action: String in required:
		slots.append({"action": action, "state": "restoring" if before.has(action) else "rising", "pressed": false})
	var traces: Array[String] = []
	for action: String in before:
		if not required.has(action):
			traces.append(action)
	_bubble = {"required": required, "previous": before, "slots": slots, "popped_traces": traces}
	return true


func get_input_bubble_state() -> Dictionary:
	if _bubble.is_empty():
		return {}
	var out: Dictionary = _bubble.duplicate(true)
	var complete: bool = true
	for slot: Dictionary in out["slots"] as Array:
		if not bool(slot["pressed"]):
			complete = false
	out["complete"] = complete
	return out


func can_process() -> bool:
	return context != null and context.input_enabled and ["playing", "first_frame"].has(state.phase) and not state.is_downed() and not state.transition_pending


func read_intent() -> RunIntent:
	if context == null:
		return RunIntent.new()
	var surge_now: bool = context.is_action_pressed(ACTION_SURGE)
	var consume_now: bool = context.is_action_pressed(ACTION_CONSUME)
	var surge_edge: bool = surge_now and not _held_surge
	var consume_edge: bool = consume_now and not _held_consume
	_held_surge = surge_now
	_held_consume = consume_now
	_pop_bubbles()
	if not can_process():
		return RunIntent.new()
	return RunIntent.create(context.is_action_pressed(ACTION_UP), context.is_action_pressed(ACTION_DOWN), context.is_action_pressed(ACTION_LEFT), context.is_action_pressed(ACTION_RIGHT), surge_edge, consume_edge)


func _physics_process(delta: float) -> void:
	step_frame(delta)


func step_frame(delta: float, override: RunIntent = null) -> void:
	frame_events.clear()
	if context == null or runtime == null:
		return
	anchor_flash_for = maxf(0.0, anchor_flash_for - delta)
	match state.phase:
		"first_frame":
			state.phase_time += delta
			if state.phase_time + 0.000001 >= FIRST_FRAME_HOLD:
				state.phase = "playing"
				state.phase_time = 0.0
				_send_profile_once()
		"playing":
			var intent: RunIntent = _frame_intent(override)
			var steps: int = clock.begin_frame(delta)
			for step_index: int in steps:
				var sub: RunIntent = intent if step_index == 0 else _without_edges(intent)
				if not _substep(sub, DescentClock.STEP):
					break
			if (intent.up or intent.down) and absf(state.velocity.y) > SWIM_SOUND_SPEED:
				_event(&"desc_swim")
		"transition":
			_advance_transition(delta)
		"ending":
			state.phase_time += delta
			if state.phase_time + 0.000001 >= ENDING_HOLD:
				_finish()
	_play_events()


func _frame_intent(override: RunIntent) -> RunIntent:
	if override == null:
		return read_intent()
	if not can_process():
		return RunIntent.new()
	return override.copy()


func _without_edges(intent: RunIntent) -> RunIntent:
	var copy: RunIntent = intent.copy()
	copy.surge = false
	copy.consume = false
	return copy


func _substep(intent: RunIntent, h: float) -> bool:
	if state.is_downed():
		var waiting: Dictionary = Vitality.apply(state, [] as Array[Dictionary], h)
		if bool(waiting["recover"]):
			_recover_from_downed()
		return true
	if PlayerMotion.step(state, intent, state.mass, h):
		_event(&"desc_surge")
	var hit: Dictionary = DescentCollision.resolve(state, runtime, h)
	for _broken: String in hit["broken"] as Array[String]:
		_event(&"desc_bristle")
		_request_brittle_wound()
	if bool(hit["landed"]):
		_event(&"desc_land")
	HazardField.apply(state, runtime, h, body)
	var gathered: Dictionary = MatterLoop.tick_pickup(state, runtime)
	for _picked: String in gathered["picked"] as Array[String]:
		_event(&"desc_pickup")
	if bool(gathered["denied"]):
		_event(&"desc_denied")
	var pending: Array[Dictionary] = FaunaAgent.step_all(state, runtime, h)
	var harm: Dictionary = Vitality.apply(state, pending, h)
	if bool(harm["hurt"]):
		_event(&"desc_hurt")
	if bool(harm["downed"]):
		_event(&"desc_downed")
	if not (harm["absorbed"] as Dictionary).is_empty():
		_event(&"desc_consume")
	var touched: Dictionary = AnchorBook.check(state, runtime)
	if not String(touched["anchor"]).is_empty():
		_event(&"desc_anchor")
		anchor_flash_for = ANCHOR_FLASH
		_persist()
	for _fact: String in touched["facts"] as Array[String]:
		_event(&"desc_fact")
	RouteResolver.evaluate(state, runtime)
	var used: Dictionary = MatterLoop.consume(state, runtime, intent.consume, body)
	if bool(used.get("consumed", false)):
		_event(&"desc_consume")
	elif bool(used.get("denied", false)):
		_event(&"desc_denied")
	var reached: Dictionary = runtime.check_exit(state)
	if bool(reached.get("denied", false)):
		_event(&"desc_denied")
	if reached.has("route"):
		_take_route(reached["route"] as Dictionary)
	if state.phase == "playing":
		state.elapsed_play += h
	return state.phase == "playing" and not state.transition_pending


func _take_route(route: Dictionary) -> void:
	var route_id: String = String(route["id"])
	if not state.routes_opened.has(route_id):
		state.routes_opened.append(route_id)
	if String(route["kind"]) == "ending":
		var ending: String = EndingResolver.ending_for(route)
		_begin_ending(ending if not ending.is_empty() else EndingResolver.fallback_ending(runtime.ending_routes()))
		return
	var next: String = String(route["next"])
	if next.is_empty():
		_begin_ending(EndingResolver.fallback_ending(runtime.ending_routes()))
		return
	if not loader.has_stratum(next):
		_warn_once("descent: route %s leads to '%s', which is not authored" % [route_id, next])
		var fallback: String = loader.id_at_or_after(runtime.index + 1)
		if fallback.is_empty() or fallback == runtime.id:
			_begin_ending(EndingResolver.fallback_ending(runtime.ending_routes()))
			return
		next = fallback
	state.transition_pending = true
	state.transition_to = next
	state.phase = "transition"
	state.phase_time = 0.0
	state.velocity = Vector2.ZERO
	_swapped = false
	_event(&"desc_descend")


func _begin_ending(ending: String) -> void:
	state.ending_id = ending if DescentState.ENDING_IDS.has(ending) else EndingResolver.FALLBACK_ENDING
	state.phase = "ending"
	state.phase_time = 0.0
	state.velocity = Vector2.ZERO


func _advance_transition(delta: float) -> void:
	state.phase_time += delta
	if not _swapped and state.phase_time + 0.000001 >= VEIL_FADE_OUT + VEIL_FLASH_TIME:
		_swapped = true
		_enter_stratum(state.transition_to)
	if state.phase_time + 0.000001 >= VEIL_TOTAL:
		if not _swapped:
			_swapped = true
			_enter_stratum(state.transition_to)
		state.transition_pending = false
		state.transition_to = ""
		state.phase = "playing"
		state.phase_time = 0.0


func _enter_stratum(id: String) -> void:
	var target: String = id if loader.has_stratum(id) else loader.id_at_or_after(state.stratum_index + 1)
	var data: Dictionary = loader.get_stratum(target)
	if data.is_empty():
		return
	runtime = StratumRuntime.build(data, state, world)
	for message: String in runtime.warnings:
		_warn_once(message)
	state.enter_stratum(target, int(data["index"]), runtime.spawn_position, runtime.spawn_facing)
	clock.reset()
	_event(&"desc_ambience")


func _recover_from_downed() -> void:
	if not Vitality.recover(state):
		var anchor: Dictionary = runtime.first_anchor()
		state.position = anchor["position"] if not anchor.is_empty() else runtime.spawn_position
		Vitality.restore_body(state)
	if not loader.has_stratum(state.stratum_id):
		state.stratum_id = loader.id_at_or_after(state.stratum_index)
	state.stratum_index = maxi(loader.authored_index(state.stratum_id), 0)
	_build_runtime(state.stratum_id)
	clock.reset()


func _finish() -> void:
	state.phase = "finished"
	state.phase_time = 0.0
	_persist()
	finished.emit(EndingResolver.make_result(state))


func _build_runtime(id: String) -> void:
	var data: Dictionary = loader.get_stratum(id)
	if data.is_empty():
		data = loader.get_stratum(loader.first_id())
	if data.is_empty():
		runtime = null
		return
	runtime = StratumRuntime.build(data, state, world)
	for message: String in runtime.warnings:
		_warn_once(message)


func _checkpoint_valid(point: Dictionary) -> bool:
	if point.is_empty():
		return false
	var data: Dictionary = loader.get_stratum(String(point.get("stratum_id", "")))
	if data.is_empty():
		return false
	for anchor: Variant in data.get("anchors", []) as Array:
		if anchor is Dictionary and String((anchor as Dictionary).get("id", "")) == String(point.get("anchor_id", "")):
			return true
	return false


func _default_checkpoint(loaded: DescentState) -> Dictionary:
	var data: Dictionary = loader.get_stratum(loaded.stratum_id)
	var anchors: Array = data.get("anchors", []) as Array if not data.is_empty() else []
	if anchors.is_empty() or not anchors[0] is Dictionary:
		return {}
	var first: Dictionary = anchors[0]
	return loaded.make_checkpoint(String(first.get("id", "")), StratumRuntime.to_point(first.get("position")))


func _seed_run() -> void:
	var generator := RandomNumberGenerator.new()
	generator.randomize()
	state.world_seed = generator.randi_range(1, DescentState.SEED_MAX)
	state.run_id = "r-%06x" % (state.world_seed & 0xFFFFFF)


func _ensure_content() -> void:
	if _content_ready:
		return
	_content_ready = true
	loader.load_dir()


func _setup_audio() -> void:
	if _audio == null or not is_instance_valid(_audio):
		_audio = AudioEventPlayer.new()
		_audio.name = "DescentAudio"
		add_child(_audio)
		_audio.setup(AudioManifest.from_file(AUDIO_MANIFEST_PATH))


func _event(id: StringName) -> void:
	frame_events.append(id)


func _play_events() -> void:
	if _audio == null or not is_instance_valid(_audio):
		return
	for id: StringName in frame_events:
		_audio.play(id)


func _persist() -> void:
	if context == null:
		return
	var hook: Variant = context.arrival.get(PERSIST_KEY)
	if hook is Callable and (hook as Callable).is_valid():
		(hook as Callable).call(String(MODULE_ID), save_state())


func _request_brittle_wound() -> void:
	if context == null or mutation_requested:
		return
	var request: Variant = context.arrival.get(REQUEST_KEY)
	if not request is Callable or not (request as Callable).is_valid():
		return
	mutation_requested = true
	var wounds: Array = world.body_wounds()
	wounds.append(BRITTLE_WOUND.duplicate(true))
	var answer: Variant = (request as Callable).call("body", {"wounds": wounds})
	if not _accepted(answer):
		var reason: String = str((answer as Dictionary).get("reason", "refused")) if answer is Dictionary else "no answer"
		_warn_once("descent: the body request was refused (%s)" % reason)


func _accepted(answer: Variant) -> bool:
	if not answer is Dictionary:
		return false
	var verdict: Dictionary = answer
	return bool(verdict.get("ok", false)) or bool(verdict.get("accepted", false))


func _send_profile_once() -> void:
	if _profile_sent or context == null:
		return
	_profile_sent = true
	var required: Array[String] = []
	for action: StringName in REQUIRED_ACTIONS:
		required.append(String(action))
	var previous: Array = []
	var carried: Variant = context.arrival.get(PREVIOUS_KEYS_KEY)
	if carried is Array:
		previous = (carried as Array).duplicate()
	requested.emit(&"input_profile", {"required_keys": required, "previous": previous})


func _pop_bubbles() -> void:
	if _bubble.is_empty() or context == null:
		return
	for slot: Dictionary in _bubble["slots"] as Array:
		if context.is_action_pressed(StringName(String(slot["action"]))):
			slot["pressed"] = true
			slot["state"] = "popped"


func _warn_once(message: String) -> void:
	if _warned.has(message):
		return
	_warned.append(message)
	push_warning(message)
