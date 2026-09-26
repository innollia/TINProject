class_name AudioManifest
extends Resource

const ALLOWED_BUSES: Array[StringName] = [&"Music", &"SFX", &"UI", &"Voice"]
const BUS_LIST_TEXT: String = "Music, SFX, UI, Voice"

@export var id_prefix: StringName = &""
@export var events: Array[AudioManifestEvent] = []

var _parse_errors: PackedStringArray = PackedStringArray()

static func from_dictionary(data: Dictionary) -> AudioManifest:
	var manifest := AudioManifest.new()
	if not data.has("id_prefix"):
		manifest._parse_errors.append("manifest: missing 'id_prefix'")
	else:
		manifest.id_prefix = StringName(str(data["id_prefix"]))
	if not data.has("events"):
		manifest._parse_errors.append("manifest: missing 'events'")
		return manifest
	var raw: Variant = data["events"]
	if not (raw is Array):
		manifest._parse_errors.append("manifest: 'events' must be an Array")
		return manifest
	var entries: Array = raw
	for index: int in entries.size():
		var entry: Variant = entries[index]
		if not (entry is Dictionary):
			manifest._parse_errors.append("event[%d]: must be a Dictionary" % index)
			continue
		manifest.events.append(AudioManifestEvent.from_dictionary(entry as Dictionary))
	return manifest

static func from_file(path: String) -> AudioManifest:
	if not FileAccess.file_exists(path):
		var missing := AudioManifest.new()
		missing._parse_errors.append("manifest: file not found '%s'" % path)
		return missing
	var handle := FileAccess.open(path, FileAccess.READ)
	if handle == null:
		var unreadable := AudioManifest.new()
		unreadable._parse_errors.append("manifest: cannot open '%s'" % path)
		return unreadable
	var text: String = handle.get_as_text()
	handle.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		var broken := AudioManifest.new()
		broken._parse_errors.append("manifest: '%s' is not a JSON object" % path)
		return broken
	return from_dictionary(parsed as Dictionary)

func validate() -> PackedStringArray:
	var errors := _parse_errors.duplicate()
	if id_prefix.is_empty():
		errors.append("manifest: 'id_prefix' is empty")
	var seen: Dictionary = {}
	for index: int in events.size():
		var item: AudioManifestEvent = events[index]
		var label := "event[%d]" % index
		if item == null:
			errors.append("%s: null entry" % label)
			continue
		label = "event '%s'" % String(item.id)
		if item.id.is_empty():
			errors.append("event[%d]: 'id' is empty" % index)
		elif seen.has(item.id):
			errors.append("%s: duplicate id" % label)
		else:
			seen[item.id] = true
		if item.file.is_empty():
			errors.append("%s: missing 'file'" % label)
		elif not ResourceLoader.exists(item.file):
			errors.append("%s: file not found '%s'" % [label, item.file])
		if not ALLOWED_BUSES.has(item.bus):
			errors.append("%s: bus '%s' is not one of %s" % [label, String(item.bus), BUS_LIST_TEXT])
		if item.max_polyphony < 1:
			errors.append("%s: max_polyphony must be >= 1, got %d" % [label, item.max_polyphony])
		if not is_finite(item.volume_db):
			errors.append("%s: volume_db must be finite" % label)
		if not is_finite(item.min_interval_seconds) or item.min_interval_seconds < 0.0:
			errors.append("%s: min_interval_seconds must be >= 0 and finite" % label)
	return errors

func is_valid() -> bool:
	return validate().is_empty()

func has_event(id: StringName) -> bool:
	return get_event(id) != null

func get_event(id: StringName) -> AudioManifestEvent:
	var wanted := id
	if not id_prefix.is_empty() and not String(id).begins_with(String(id_prefix) + "_"):
		wanted = StringName(String(id_prefix) + "_" + String(id))
	for index: int in events.size():
		var item: AudioManifestEvent = events[index]
		if item == null:
			continue
		if item.id == id or item.id == wanted:
			return item
	return null
