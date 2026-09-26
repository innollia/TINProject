extends GutTest

const MANIFEST_PATH: String = "res://modules/descent_exploration/audio_manifest.json"
const TABLE: Array = [
	["desc_swim", "SFX", 3, -14.0, 0.35],
	["desc_surge", "SFX", 1, -6.0, 0.0],
	["desc_land", "SFX", 2, -10.0, 0.10],
	["desc_pickup", "SFX", 1, -8.0, 0.0],
	["desc_denied", "SFX", 2, -12.0, 0.20],
	["desc_consume", "SFX", 1, -6.0, 0.0],
	["desc_bristle", "SFX", 2, -5.0, 0.05],
	["desc_anchor", "SFX", 1, -9.0, 0.0],
	["desc_fact", "SFX", 1, -10.0, 0.0],
	["desc_hurt", "SFX", 1, -4.0, 0.0],
	["desc_downed", "SFX", 1, -2.0, 0.0],
	["desc_descend", "SFX", 1, -8.0, 0.0],
	["desc_ambience", "Music", 1, -18.0, 0.0],
]


func _manifest() -> AudioManifest:
	return AudioManifest.from_file(MANIFEST_PATH)


func test_manifest_parses_with_the_desc_prefix_and_thirteen_events() -> void:
	var manifest := _manifest()
	assert_eq(manifest.id_prefix, &"desc")
	assert_eq(manifest.events.size(), 13)


func test_every_event_uses_an_allowed_bus_and_a_unique_prefixed_id() -> void:
	var seen: Array[StringName] = []
	for event: AudioManifestEvent in _manifest().events:
		assert_true(AudioManifest.ALLOWED_BUSES.has(event.bus), String(event.id))
		assert_true(String(event.id).begins_with("desc_"), String(event.id))
		assert_false(seen.has(event.id), String(event.id))
		seen.append(event.id)
		assert_ne(event.bus, &"Voice")


func test_events_match_the_plan_table_exactly() -> void:
	var manifest := _manifest()
	for row: Array in TABLE:
		var event: AudioManifestEvent = manifest.get_event(StringName(row[0]))
		assert_not_null(event, row[0])
		if event == null:
			continue
		assert_eq(event.bus, StringName(row[1]), row[0])
		assert_eq(event.max_polyphony, int(row[2]), row[0])
		assert_almost_eq(event.volume_db, float(row[3]), 0.0001, row[0])
		assert_almost_eq(event.min_interval_seconds, float(row[4]), 0.0001, row[0])
		assert_eq(event.file, "res://modules/descent_exploration/audio/%s.wav" % String(row[0]).trim_prefix("desc_"), row[0])


func test_manifest_validates_once_the_renders_exist() -> void:
	var manifest := _manifest()
	var missing: Array[String] = []
	for event: AudioManifestEvent in manifest.events:
		if not ResourceLoader.exists(event.file):
			missing.append(event.file.get_file())
	if not missing.is_empty():
		pending("OQ-6: %d wav renders are not in the repository yet (%s)" % [missing.size(), ", ".join(missing)])
		return
	assert_eq(manifest.validate(), PackedStringArray())
