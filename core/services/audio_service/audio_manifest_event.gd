class_name AudioManifestEvent
extends Resource

@export var id: StringName = &""
@export_file("*.wav,*.ogg,*.mp3") var file: String = ""
@export var bus: StringName = &"SFX"
@export_range(1, 64, 1) var max_polyphony: int = 1
@export var volume_db: float = 0.0
@export var min_interval_seconds: float = 0.0

static func from_dictionary(data: Dictionary) -> AudioManifestEvent:
	var item := AudioManifestEvent.new()
	if not data.has("id"):
		return item
	item.id = StringName(str(data["id"]))
	item.file = str(data.get("file", ""))
	item.bus = StringName(str(data.get("bus", "SFX")))
	item.max_polyphony = int(data.get("max_polyphony", 1))
	item.volume_db = float(data.get("volume_db", 0.0))
	item.min_interval_seconds = float(data.get("min_interval_seconds", 0.0))
	return item
