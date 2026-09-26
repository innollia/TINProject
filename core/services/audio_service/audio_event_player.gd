class_name AudioEventPlayer
extends Node

signal event_played(id: StringName)
signal event_rejected(id: StringName, reason: StringName)

const REASON_UNKNOWN_EVENT: StringName = &"unknown_event"
const REASON_COOLDOWN: StringName = &"cooldown"
const REASON_NO_VOICE: StringName = &"no_voice"
const MAX_POOL_SIZE: int = 256

var manifest: AudioManifest = null
var voice_pool_size: int = 32
var default_min_interval_seconds: float = 0.0

var _settings: SettingsService = null
var _audio: AudioService = null
var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _owner_of: Dictionary = {}
var _sequence_of: Dictionary = {}
var _last_played_usec: Dictionary = {}
var _setup_errors: PackedStringArray = PackedStringArray()
var _sequence: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	if _pool.is_empty():
		_rebuild_pool()

func _exit_tree() -> void:
	stop_all()

func setup(event_manifest: AudioManifest, bus_volumes: SettingsService = null, bus_audio: AudioService = null) -> Error:
	_settings = bus_volumes
	_audio = bus_audio
	_setup_errors = PackedStringArray()
	_streams.clear()
	_last_played_usec.clear()
	if event_manifest == null:
		_setup_errors.append("setup: manifest is null")
		manifest = null
		return ERR_INVALID_DATA
	manifest = event_manifest
	for problem: String in event_manifest.validate():
		if problem.contains("file not found") or problem.contains("missing 'file'"):
			_setup_errors.append(problem)
		else:
			push_error("AudioEventPlayer: " + problem)
	for index: int in event_manifest.events.size():
		var item: AudioManifestEvent = event_manifest.events[index]
		if item == null or item.id.is_empty():
			continue
		if not AudioManifest.ALLOWED_BUSES.has(item.bus):
			continue
		if item.max_polyphony < 1 or item.file.is_empty():
			continue
		var stream: Variant = ResourceLoader.load(item.file)
		if not (stream is AudioStream):
			_setup_errors.append("event '%s': '%s' is not an AudioStream" % [String(item.id), item.file])
			continue
		_streams[item.id] = stream
	_rebuild_pool()
	return OK

func set_voice_pool_size(size: int) -> void:
	voice_pool_size = clampi(size, 1, MAX_POOL_SIZE)
	if is_inside_tree():
		_rebuild_pool()

func has_event(id: StringName) -> bool:
	if manifest == null:
		return false
	var item: AudioManifestEvent = manifest.get_event(id)
	return item != null and _streams.has(item.id)

func get_setup_errors() -> PackedStringArray:
	return PackedStringArray(_setup_errors)

func play(event_id: StringName, pitch_variation: float = 0.0, volume_scale: float = 1.0) -> bool:
	if manifest == null:
		event_rejected.emit(event_id, REASON_UNKNOWN_EVENT)
		return false
	var item: AudioManifestEvent = manifest.get_event(event_id)
	if item == null or not _streams.has(item.id):
		event_rejected.emit(event_id, REASON_UNKNOWN_EVENT)
		return false
	var key: StringName = item.id
	var now: int = Time.get_ticks_usec()
	var cooldown: float = maxf(default_min_interval_seconds, item.min_interval_seconds)
	if cooldown > 0.0:
		var last: int = int(_last_played_usec.get(key, -1))
		if last >= 0 and float(now - last) < cooldown * 1000000.0:
			event_rejected.emit(key, REASON_COOLDOWN)
			return false
	var voice: AudioStreamPlayer = _acquire_voice(key, item.max_polyphony)
	if voice == null:
		event_rejected.emit(key, REASON_NO_VOICE)
		return false
	_last_played_usec[key] = now
	var scale: float = volume_scale if is_finite(volume_scale) else 1.0
	voice.stream = _streams[key]
	voice.bus = item.bus
	voice.volume_db = item.volume_db + linear_to_db(clampf(scale, 0.0001, 4.0))
	voice.pitch_scale = 1.0
	if is_finite(pitch_variation) and pitch_variation > 0.0:
		voice.pitch_scale = maxf(0.05, 1.0 + _rng.randf_range(-pitch_variation, pitch_variation))
	voice.play()
	event_played.emit(key)
	return true

func stop_all() -> void:
	for player: AudioStreamPlayer in _pool:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func set_bus_volume_db(bus: StringName, db: float) -> Error:
	if not AudioManifest.ALLOWED_BUSES.has(bus):
		return ERR_INVALID_PARAMETER
	if not is_finite(db):
		return ERR_INVALID_PARAMETER
	var linear: float = clampf(db_to_linear(maxf(db, -60.0)), 0.0, 1.0)
	if _settings != null:
		_settings.set_volume(bus, linear)
	if _audio != null:
		_audio.set_volume(bus, linear)
	return OK

func _rebuild_pool() -> void:
	for player: AudioStreamPlayer in _pool:
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
	_pool.clear()
	_owner_of.clear()
	_sequence_of.clear()
	var count: int = clampi(voice_pool_size, 1, MAX_POOL_SIZE)
	for index: int in count:
		var player := AudioStreamPlayer.new()
		player.name = "Voice%d" % index
		player.bus = &"SFX"
		add_child(player)
		_pool.append(player)

func _acquire_voice(event_id: StringName, max_polyphony: int) -> AudioStreamPlayer:
	var owned: Array[int] = []
	for index: int in _pool.size():
		if _owner_of.get(_pool[index].get_instance_id(), &"") == event_id:
			owned.append(index)
	for index: int in owned:
		if not _pool[index].is_playing():
			return _claim(_pool[index], event_id)
	if owned.size() < max_polyphony:
		for index: int in _pool.size():
			if not _pool[index].is_playing():
				return _claim(_pool[index], event_id)
	var steal: int = -1
	var oldest: int = 0x7FFFFFFF
	for index: int in owned:
		if not _pool[index].is_playing():
			continue
		if int(_sequence_of.get(_pool[index].get_instance_id(), 0)) < oldest:
			oldest = int(_sequence_of.get(_pool[index].get_instance_id(), 0))
			steal = index
	if steal < 0:
		for index: int in _pool.size():
			if not _pool[index].is_playing():
				continue
			if int(_sequence_of.get(_pool[index].get_instance_id(), 0)) < oldest:
				oldest = int(_sequence_of.get(_pool[index].get_instance_id(), 0))
				steal = index
	if steal < 0:
		return null
	return _claim(_pool[steal], event_id)

func _claim(player: AudioStreamPlayer, event_id: StringName) -> AudioStreamPlayer:
	player.stop()
	var key: int = player.get_instance_id()
	_owner_of[key] = event_id
	_sequence += 1
	_sequence_of[key] = _sequence
	return player
