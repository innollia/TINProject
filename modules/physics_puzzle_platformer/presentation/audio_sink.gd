extends Node

const AudioManifestData = preload("res://modules/physics_puzzle_platformer/audio_manifest.gd")

var played: Dictionary = {}
var _player: AudioEventPlayer
var _known: Array[String] = []


func _ready() -> void:
	_known = AudioManifestData.event_ids()
	_player = AudioEventPlayer.new()
	_player.name = "EventPlayer"
	_player.set_voice_pool_size(8)
	add_child(_player)
	_player.setup(AudioManifest.from_dictionary(AudioManifestData.audio_manifest))


func play_events(events: Array) -> void:
	for event: Variant in events:
		if not event is Dictionary:
			continue
		var id: String = String((event as Dictionary).get("id", ""))
		if not _known.has(id):
			continue
		played[id] = int(played.get(id, 0)) + 1
		if _player != null and _player.has_event(StringName(id)):
			_player.play(StringName(id), 0.06)


func stop() -> void:
	if _player != null:
		_player.stop_all()
