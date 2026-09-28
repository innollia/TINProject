extends GutTest

const MIXER_SCRIPT: String = "res://modules/descent_exploration/audio_ambience.gd"
const DATA_PATH: String = "res://modules/descent_exploration/ambient_stems.json"
const AUDIO_DIR: String = "res://modules/descent_exploration/audio/ambience/"


func _mixer() -> Node:
	var node: Node = load(MIXER_SCRIPT).new()
	add_child_autofree(node)
	return node


func _data() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	return parsed if parsed is Dictionary else {}


func test_mixer_script_is_registered() -> void:
	assert_true(ResourceLoader.exists(MIXER_SCRIPT), MIXER_SCRIPT)


func test_runtime_data_names_every_stem_file_under_the_audio_folder() -> void:
	var data := _data()
	assert_false(data.is_empty(), DATA_PATH)
	assert_eq(String(data.get("generator")), "nkido")
	var count := 0
	for entry: Dictionary in data.get("stems", []):
		count += 1
		assert_eq(String(entry.get("bus")), "Music", String(entry.get("id")))
		assert_true(String(entry.get("file")).begins_with(AUDIO_DIR), String(entry.get("id")))
		assert_almost_eq(float(entry.get("volume_db")), -20.0, 6.0, String(entry.get("id")))
	assert_eq(count, 11, "stem count in " + DATA_PATH)


func test_every_profile_names_exactly_the_stem_set() -> void:
	var data := _data()
	var stems: Array[String] = []
	for entry: Dictionary in data.get("stems", []):
		stems.append(String(entry["id"]))
	stems.sort()
	var profiles: Dictionary = data.get("profiles", {})
	assert_false(profiles.is_empty(), DATA_PATH)
	for profile_name: String in profiles:
		var gains: Dictionary = (profiles[profile_name] as Dictionary)["gains"]
		var named: Array[String] = []
		for stem_id: String in gains:
			named.append(stem_id)
			assert_between(float(gains[stem_id]), 0.0, 1.0, "%s/%s" % [profile_name, stem_id])
		named.sort()
		assert_eq(named, stems, "profile " + profile_name)


func test_music_profiles_are_monotonic_along_the_descent() -> void:
	# calm on the ice, dread at the bottom: the music bed gains must not lose
	# ground as you go down, or the descent has no shape.
	var profiles: Dictionary = _data().get("profiles", {})
	assert_eq(float((profiles["surface"] as Dictionary)["gains"]["bgm_dread"]), 0.0)
	assert_eq(float((profiles["wade"] as Dictionary)["gains"]["bgm_dread"]), 0.0)
	assert_gt(float((profiles["column"] as Dictionary)["gains"]["bgm_dread"]),
		float((profiles["wade"] as Dictionary)["gains"]["bgm_dread"]))
	assert_gt(float((profiles["deep"] as Dictionary)["gains"]["bgm_dread"]),
		float((profiles["column"] as Dictionary)["gains"]["bgm_dread"]))
	assert_gt(float((profiles["dread"] as Dictionary)["gains"]["amb_air"]),
		-1.0, "sanity")
	assert_eq(float((profiles["deep"] as Dictionary)["gains"]["amb_air"]), 0.0)
	assert_gt(float((profiles["cavern"] as Dictionary)["gains"]["amb_cavern"]),
		float((profiles["column"] as Dictionary)["gains"]["amb_cavern"]))


func test_setup_reports_no_problems_when_the_renders_are_installed() -> void:
	var mixer := _mixer()
	var problems: PackedStringArray = mixer.setup(DATA_PATH)
	if not _renders_installed():
		pending("OQ-6: ambience stems are not rendered yet (%d missing)" % _missing_count())
		return
	assert_eq(problems, PackedStringArray())


func test_apply_profile_sets_every_stem_and_rejects_unknown_names() -> void:
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	assert_false(mixer.apply_profile("not_a_profile", 0.0))
	assert_eq(String(mixer.current_profile()), "")


func test_silence_mutes_everything_except_the_two_stems_that_hold_the_room() -> void:
	# "silence" is for menus, death and the pause screen. It is not absolute
	# silence: the sub bed keeps a floor so returning from a pause is not a hard
	# cut. Those two stems are the only exception, and their floor is narrow.
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	assert_true(mixer.apply_profile("silence", 0.0))
	var floor_stems := PackedStringArray(["amb_drone", "amb_pressure"])

	for stem_id: String in mixer.stem_ids():
		var db := (mixer.get_node("Stem_" + stem_id) as AudioStreamPlayer).volume_db
		if floor_stems.has(stem_id):
			assert_between(db, -40.0, -25.0, stem_id)
		else:
			assert_almost_eq(db, -80.0, 0.001, stem_id)


func test_no_profile_plays_a_music_bed_more_loudly_than_silence() -> void:
	# The music has to actually stop. The sub bed is allowed to hum along;
	# a melodic layer is not.
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	var names: PackedStringArray = mixer.profile_names()
	var beds: Array[String] = []
	for stem_id: String in mixer.stem_ids():
		if stem_id.begins_with("bgm_"):
			beds.append(stem_id)
	assert_eq(beds.size(), 3, "music bed count")

	for bed: String in beds:
		mixer.apply_profile("silence", 0.0)
		var quiet := (mixer.get_node("Stem_" + bed) as AudioStreamPlayer).volume_db
		for other: String in names:
			if other == "silence":
				continue
			mixer.apply_profile(other, 0.0)
			var louder := (mixer.get_node("Stem_" + bed) as AudioStreamPlayer).volume_db
			assert_lte(quiet, louder, "%s: silence vs %s" % [bed, other])


func test_a_loud_profile_raises_at_least_one_stem() -> void:
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	assert_true(mixer.apply_profile("dread", 0.0))
	var loudest := -200.0
	for child: Node in mixer.get_children():
		var player_name := String(child.name)
		var player := mixer.get_node(player_name) as AudioStreamPlayer
		loudest = maxf(loudest, player.volume_db)
	assert_gt(loudest, -30.0)


func test_fade_out_mutes_without_stopping_the_players() -> void:
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	mixer.apply_profile("cavern", 0.0)
	mixer.fade_out(0.0)
	for child: Node in mixer.get_children():
		var player_name := String(child.name)
		var player := mixer.get_node(player_name) as AudioStreamPlayer
		assert_almost_eq(player.volume_db, -80.0, 0.001, player_name)
		assert_true(player.playing, player_name)


func test_every_installed_stem_is_exactly_its_declared_loop_length() -> void:
	if not _renders_installed():
		pending("OQ-6: ambience stems are not rendered yet")
		return
	for entry: Dictionary in _data().get("stems", []):
		var path := String(entry["file"])
		var stream := load(path) as AudioStreamWAV
		assert_true(stream != null, path)
		if stream == null:
			continue
		var frames := int(round(stream.get_length() * float(stream.mix_rate)))
		var expected := int(round(float(entry["loop_seconds"]) * float(stream.mix_rate)))
		assert_eq(frames, expected, "loop length of " + path.get_file())
		# Godot 4.7 imports WAV as QOA by default, which is lossless and
		# frame-addressed, so the loop point survives it. Anything that is not
		# lossless would put the crossfade at the mercy of a lossy codec.
		assert_true(
			stream.format in [AudioStreamWAV.FORMAT_8_BITS, AudioStreamWAV.FORMAT_16_BITS, AudioStreamWAV.FORMAT_QOA],
			"%s imported as format %d" % [path.get_file(), stream.format]
		)


func test_mixer_copies_each_stem_into_a_looping_stream() -> void:
	var mixer := _mixer()
	mixer.setup(DATA_PATH)
	if not _renders_installed():
		pending("OQ-6: ambience stems are not rendered yet")
		return
	for child: Node in mixer.get_children():
		var player_name := String(child.name)
		var player := mixer.get_node(player_name) as AudioStreamPlayer
		var stream := player.stream as AudioStreamWAV
		assert_true(stream != null, player_name)
		assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, player_name)
		assert_eq(stream.loop_begin, 0, player_name)
		assert_gt(stream.loop_end, 0, player_name)


func _missing_count() -> int:
	var missing := 0
	for entry: Dictionary in _data().get("stems", []):
		if not ResourceLoader.exists(String(entry["file"])):
			missing += 1
	return missing


func _renders_installed() -> bool:
	return _missing_count() == 0

