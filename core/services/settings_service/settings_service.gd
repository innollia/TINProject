class_name SettingsService
extends Node

signal changed()
const BUSES: Array[StringName] = [&"Master", &"Music", &"SFX", &"UI", &"Voice"]
var _volumes: Dictionary = {}

func set_volume(bus: StringName, linear: float) -> void:
	if not BUSES.has(bus) or not is_finite(linear):
		return
	_volumes[bus] = clampf(linear, 0.0, 1.0)
	changed.emit()

func get_volume(bus: StringName) -> float:
	return float(_volumes.get(bus, 1.0))

func save_file(path: String = "user://settings.cfg") -> Error:
	var config := ConfigFile.new()
	for bus: StringName in BUSES:
		config.set_value("audio", String(bus), get_volume(bus))
	return config.save(path)

func load_file(path: String = "user://settings.cfg") -> Error:
	var config := ConfigFile.new()
	var error: Error = config.load(path)
	if error != OK:
		return error
	var values: Dictionary = {}
	for bus: StringName in BUSES:
		var value: Variant = config.get_value("audio", String(bus), 1.0)
		if not (value is float or value is int) or not is_finite(float(value)):
			return ERR_INVALID_DATA
		values[bus] = clampf(float(value), 0.0, 1.0)
	_volumes = values
	changed.emit()
	return OK
