extends GutTest

const KitScript = preload("res://addons/tin_integrations/runtime/tin_integration_kit.gd")
const TemplateScript = preload("res://addons/tin_integrations/templates/visual_novel_template.gd")

var kit: Variant

func before_each() -> void:
	kit = KitScript.new()

func test_visual_novel_dialogue_choices_history_and_typewriter() -> void:
	var lines: Array[Dictionary] = [
		{"speaker": "A", "text": "첫 줄"},
		{"speaker": "B", "text": "선택", "choices": ["왼쪽", "오른쪽"]},
	]
	assert_eq(kit.dialogue_begin(lines), lines[0])
	assert_false(kit.dialogue_choose(2))
	assert_true(kit.dialogue_next().has("choices"))
	assert_true(kit.dialogue_choose(1))
	assert_eq(kit.dialogue_history().size(), 1)
	assert_eq(kit.typewriter_visible("abcdef", 10.0, 0.3), "abc")
	assert_eq(kit.typewriter_visible("abcdef", 0.0, 1.0), "abcdef")

func test_save_inventory_quest_relationship_timeline_and_localization() -> void:
	var payload := {"chapter": 2, "safe": true}
	var envelope: Dictionary = kit.encode_save_slot("slot-a", payload)
	assert_eq(kit.decode_save_slot(envelope), payload)
	assert_eq(kit.decode_save_slot({"schema_version": 2, "payload": payload}), {})
	assert_eq(kit.inventory_add("key", 2), 2)
	assert_true(kit.inventory_remove("key"))
	assert_false(kit.inventory_remove("key", 2))
	kit.quest_set("case", "active")
	assert_eq(kit.quest_status("case"), "active")
	assert_eq(kit.relationship_adjust("junho", 150), 100)
	assert_eq(kit.relationship_adjust("junho", -250), -100)
	kit.timeline_mark("door_open")
	assert_true(kit.timeline_has("door_open"))
	assert_eq(kit.localize("hello", "ko", {"en": {"hello": "Hello"}, "ko": {"hello": "안녕"}}), "안녕")
	assert_eq(kit.localize("missing", "ko", {"en": {"missing": "Fallback"}}), "Fallback")

func test_input_settings_checkpoint_evidence_and_achievement_adapters() -> void:
	kit.rebind(&"confirm", 90)
	assert_eq(kit.rebound_key(&"confirm"), 90)
	kit.setting_set("volume", -12.0)
	assert_eq(kit.setting_get("volume"), -12.0)
	kit.checkpoint_save("before_case", {"module": "violet_case", "step": 3})
	assert_eq(kit.checkpoint_load("before_case")["step"], 3)
	kit.evidence_add("ink", {"found": true})
	var required: Array[String] = ["ink", "window"]
	assert_false(kit.evidence_has_all(required))
	kit.evidence_add("window", {"found": true})
	assert_true(kit.evidence_has_all(required))
	assert_true(kit.achievement_unlock("first_clue"))
	assert_false(kit.achievement_unlock("first_clue"))
	assert_true(kit.achievement_has("first_clue"))

func test_scene_transition_audio_hotspot_camera_and_event_queues() -> void:
	kit.scene_push("room_a")
	kit.scene_push("room_b")
	assert_eq(kit.scene_pop(), "room_b")
	kit.transition_begin("fade", 0.8)
	kit.transition_complete()
	kit.audio_queue_cue("click", -4.0)
	assert_eq(kit.audio_drain(), [{"id": "click", "volume_db": -4.0}])
	assert_eq(kit.hotspot_visit("window"), 1)
	assert_eq(kit.hotspot_visit("window"), 2)
	assert_eq(kit.camera_shake(4.0, 0.2, 12.0), {"amplitude": 4.0, "duration": 0.2, "frequency": 12.0})
	kit.emit_event("clue_found", {"id": "ink"})
	assert_eq(kit.drain_events(), [{"id": "clue_found", "payload": {"id": "ink"}}])

func test_capture_restore_is_detached_and_template_emits_lines() -> void:
	kit.inventory_add("letter")
	var snapshot: Dictionary = kit.capture()
	kit.inventory_add("letter")
	assert_true(kit.restore(snapshot))
	assert_eq(kit.capture()["state"]["inventory"], {"letter": 1})
	var template: Variant = TemplateScript.new()
	add_child_autofree(template)
	var seen: Array[Dictionary] = []
	template.line_changed.connect(func(line: Dictionary) -> void: seen.append(line))
	var template_lines: Array[Dictionary] = [{"speaker": "기록", "text": "시작"}]
	template.begin(template_lines)
	assert_eq(seen.size(), 1)
	assert_eq(seen[0]["text"], "시작")
