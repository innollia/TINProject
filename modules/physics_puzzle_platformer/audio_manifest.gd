extends RefCounted

const AUDIO_ROOT: String = "res://modules/physics_puzzle_platformer/audio/"

const audio_manifest: Dictionary = {
	"id_prefix": "ppp",
	"events": [
		{"id": "ppp_step_paper", "file": AUDIO_ROOT + "step_paper.wav", "bus": "SFX", "max_polyphony": 4, "volume_db": -14.0, "min_interval_seconds": 0.18},
		{"id": "ppp_step_stone", "file": AUDIO_ROOT + "step_stone.wav", "bus": "SFX", "max_polyphony": 4, "volume_db": -13.0, "min_interval_seconds": 0.18},
		{"id": "ppp_step_glass", "file": AUDIO_ROOT + "step_glass.wav", "bus": "SFX", "max_polyphony": 3, "volume_db": -15.0, "min_interval_seconds": 0.18},
		{"id": "ppp_jump", "file": AUDIO_ROOT + "jump.wav", "bus": "SFX", "max_polyphony": 2, "volume_db": -15.0, "min_interval_seconds": 0.0},
		{"id": "ppp_land_soft", "file": AUDIO_ROOT + "land_soft.wav", "bus": "SFX", "max_polyphony": 3, "volume_db": -13.0, "min_interval_seconds": 0.0},
		{"id": "ppp_land_hard", "file": AUDIO_ROOT + "land_hard.wav", "bus": "SFX", "max_polyphony": 2, "volume_db": -8.0, "min_interval_seconds": 0.0},
		{"id": "ppp_tool_grab", "file": AUDIO_ROOT + "tool_grab.wav", "bus": "SFX", "max_polyphony": 2, "volume_db": -12.0, "min_interval_seconds": 0.22},
		{"id": "ppp_tool_charge", "file": AUDIO_ROOT + "tool_charge.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -16.0, "min_interval_seconds": 0.5},
		{"id": "ppp_tool_throw", "file": AUDIO_ROOT + "tool_throw.wav", "bus": "SFX", "max_polyphony": 3, "volume_db": -11.0, "min_interval_seconds": 0.22},
		{"id": "ppp_impact_soft", "file": AUDIO_ROOT + "impact_soft.wav", "bus": "SFX", "max_polyphony": 5, "volume_db": -14.0, "min_interval_seconds": 0.06},
		{"id": "ppp_impact_hard", "file": AUDIO_ROOT + "impact_hard.wav", "bus": "SFX", "max_polyphony": 4, "volume_db": -8.0, "min_interval_seconds": 0.06},
		{"id": "ppp_shatter", "file": AUDIO_ROOT + "shatter.wav", "bus": "SFX", "max_polyphony": 4, "volume_db": -9.0, "min_interval_seconds": 0.0},
		{"id": "ppp_egg_take", "file": AUDIO_ROOT + "egg_take.wav", "bus": "SFX", "max_polyphony": 2, "volume_db": -6.0, "min_interval_seconds": 0.0},
		{"id": "ppp_rift_ready", "file": AUDIO_ROOT + "rift_ready.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0, "min_interval_seconds": 0.0},
		{"id": "ppp_rift_enter", "file": AUDIO_ROOT + "rift_enter.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -3.0, "min_interval_seconds": 0.0},
		{"id": "ppp_hurt", "file": AUDIO_ROOT + "hurt.wav", "bus": "SFX", "max_polyphony": 2, "volume_db": -6.0, "min_interval_seconds": 0.65},
		{"id": "ppp_reset", "file": AUDIO_ROOT + "reset.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -7.0, "min_interval_seconds": 0.0},
		{"id": "ppp_level_clear", "file": AUDIO_ROOT + "level_clear.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -5.0, "min_interval_seconds": 0.0},
		{"id": "ppp_run_clear", "file": AUDIO_ROOT + "run_clear.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -3.0, "min_interval_seconds": 0.0},
	],
}


static func event_ids() -> Array[String]:
	var ids: Array[String] = []
	for event: Dictionary in audio_manifest["events"]:
		ids.append(String(event["id"]))
	return ids


static func find(id: String) -> Dictionary:
	for event: Dictionary in audio_manifest["events"]:
		if String(event["id"]) == id:
			return event
	return {}
