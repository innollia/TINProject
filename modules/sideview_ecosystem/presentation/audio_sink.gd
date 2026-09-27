class_name EcoAudioSink
extends Node

## §5.1, §12. audio_events.tres 를 재생. W3 플레이어가 없으면 조용히 no-op.

var _manifest: Resource
var _player: Node


func _ready() -> void:
	_manifest = load("res://modules/sideview_ecosystem/audio_events.tres")
	if ClassDB.class_exists("AudioEventPlayer"):
		_player = ClassDB.instantiate("AudioEventPlayer")
		if _player != null and _player.has_method("setup"):
			add_child(_player)
			_player.call("setup", _manifest)


func play(event_id: StringName, pitch_scale_value: float = 1.0) -> void:
	if _player == null or not _player.has_method("play_event"):
		return
	_player.call("play_event", event_id, pitch_scale_value)
