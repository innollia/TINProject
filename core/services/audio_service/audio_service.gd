class_name AudioService
extends Node

var _music: AudioStreamPlayer

func setup() -> void:
	for bus: String in ["Music", "SFX", "UI", "Voice"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			var index: int = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus)
			AudioServer.set_bus_send(index, "Master")
	if _music == null:
		_music = AudioStreamPlayer.new()
		_music.bus = &"Music"
		add_child(_music)

func set_volume(bus: StringName, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index < 0 or not is_finite(linear):
		return
	var volume: float = clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(index, volume == 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))

func play_music(stream: AudioStream) -> void:
	setup()
	if stream == null:
		stop_music()
		return
	_music.stream = stream
	_music.play()

func stop_music() -> void:
	if _music != null:
		_music.stop()
