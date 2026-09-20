class_name TinIntegrationKit
extends RefCounted

const SCHEMA_VERSION: int = 1

var _state: Dictionary = {
	"vn_lines": [],
	"vn_index": 0,
	"vn_history": [],
	"vn_choice": -1,
	"inventory": {},
	"quests": {},
	"relationships": {},
	"timeline": {},
	"locales": {},
	"input_bindings": {},
	"settings": {},
	"checkpoints": {},
	"evidence": {},
	"achievements": [],
	"scene_stack": [],
	"transition": {},
	"audio_queue": [],
	"hotspots": {},
	"last_shake": {},
}
var _events: Array[Dictionary] = []

func dialogue_begin(lines: Array[Dictionary]) -> Dictionary:
	_state["vn_lines"] = lines.duplicate(true)
	_state["vn_index"] = 0
	_state["vn_history"] = []
	_state["vn_choice"] = -1
	return dialogue_current()

func dialogue_current() -> Dictionary:
	var lines: Array = _state["vn_lines"]
	var index: int = int(_state["vn_index"])
	if lines.is_empty() or index < 0 or index >= lines.size():
		return {}
	return lines[index].duplicate(true) if lines[index] is Dictionary else {}

func dialogue_next() -> Dictionary:
	var current := dialogue_current()
	if current.is_empty():
		return {}
	var history: Array = _state["vn_history"]
	history.append(current.duplicate(true))
	_state["vn_history"] = history
	_state["vn_index"] = mini(int(_state["vn_index"]) + 1, maxi(0, (Array(_state["vn_lines"])).size() - 1))
	return dialogue_current()

func dialogue_choose(choice_index: int) -> bool:
	var current := dialogue_current()
	var choices: Variant = current.get("choices", [])
	if not choices is Array or choice_index < 0 or choice_index >= choices.size():
		return false
	_state["vn_choice"] = choice_index
	return true

func dialogue_history() -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for entry: Variant in _state["vn_history"]:
		if entry is Dictionary:
			output.append(entry.duplicate(true))
	return output

func typewriter_visible(text: String, characters_per_second: float, elapsed: float) -> String:
	if characters_per_second <= 0.0 or elapsed <= 0.0:
		return "" if elapsed <= 0.0 else text
	return text.substr(0, mini(text.length(), maxi(0, int(floor(characters_per_second * elapsed)))))

func encode_save_slot(label: String, payload: Dictionary) -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "label": label, "payload": payload.duplicate(true)}

func decode_save_slot(envelope: Dictionary) -> Dictionary:
	if envelope.get("schema_version") != SCHEMA_VERSION or not envelope.get("payload") is Dictionary:
		return {}
	return envelope["payload"].duplicate(true)

func inventory_add(item_id: String, amount: int = 1) -> int:
	if item_id.strip_edges().is_empty() or amount <= 0:
		return int(_state["inventory"].get(item_id, 0))
	var inventory: Dictionary = _state["inventory"]
	inventory[item_id] = mini(int(inventory.get(item_id, 0)) + amount, 9999)
	return int(inventory[item_id])

func inventory_remove(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or int(_state["inventory"].get(item_id, 0)) < amount:
		return false
	var inventory: Dictionary = _state["inventory"]
	inventory[item_id] = int(inventory[item_id]) - amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	return true

func quest_set(quest_id: String, status: String) -> void:
	if not quest_id.strip_edges().is_empty() and not status.strip_edges().is_empty():
		_state["quests"][quest_id] = status

func quest_status(quest_id: String) -> String:
	return String(_state["quests"].get(quest_id, "unknown"))

func relationship_adjust(character_id: String, delta: int) -> int:
	var relationships: Dictionary = _state["relationships"]
	relationships[character_id] = clampi(int(relationships.get(character_id, 0)) + delta, -100, 100)
	return int(relationships[character_id])

func timeline_mark(flag: String, value: bool = true) -> void:
	if not flag.strip_edges().is_empty():
		_state["timeline"][flag] = value

func timeline_has(flag: String) -> bool:
	return bool(_state["timeline"].get(flag, false))

func localize(key: String, locale: String, table: Dictionary, fallback_locale: String = "en") -> String:
	var chosen: Variant = table.get(locale, {})
	if not chosen is Dictionary:
		chosen = {}
	if chosen.has(key):
		return String(chosen[key])
	var fallback: Variant = table.get(fallback_locale, {})
	return String(fallback.get(key, key)) if fallback is Dictionary else key

func rebind(action: StringName, physical_keycode: int) -> void:
	if not action.is_empty() and physical_keycode >= 0:
		_state["input_bindings"][String(action)] = physical_keycode

func rebound_key(action: StringName, fallback: int = -1) -> int:
	return int(_state["input_bindings"].get(String(action), fallback))

func setting_set(key: String, value: Variant) -> void:
	if not key.strip_edges().is_empty() and _json_safe(value):
		_state["settings"][key] = value

func setting_get(key: String, fallback: Variant = null) -> Variant:
	return _state["settings"].get(key, fallback)

func checkpoint_save(checkpoint_id: String, snapshot: Dictionary) -> void:
	if not checkpoint_id.strip_edges().is_empty():
		_state["checkpoints"][checkpoint_id] = snapshot.duplicate(true)

func checkpoint_load(checkpoint_id: String) -> Dictionary:
	var snapshot: Variant = _state["checkpoints"].get(checkpoint_id, {})
	return snapshot.duplicate(true) if snapshot is Dictionary else {}

func evidence_add(evidence_id: String, payload: Dictionary) -> void:
	if not evidence_id.strip_edges().is_empty():
		_state["evidence"][evidence_id] = payload.duplicate(true)

func evidence_has_all(required_ids: Array[String]) -> bool:
	for evidence_id: String in required_ids:
		if not _state["evidence"].has(evidence_id):
			return false
	return true

func achievement_unlock(achievement_id: String) -> bool:
	if achievement_id.strip_edges().is_empty() or _state["achievements"].has(achievement_id):
		return false
	_state["achievements"].append(achievement_id)
	return true

func achievement_has(achievement_id: String) -> bool:
	return _state["achievements"].has(achievement_id)

func scene_push(scene_id: String) -> void:
	if not scene_id.strip_edges().is_empty():
		_state["scene_stack"].append(scene_id)

func scene_pop() -> String:
	if _state["scene_stack"].is_empty():
		return ""
	return String(_state["scene_stack"].pop_back())

func transition_begin(transition_id: String, duration: float) -> void:
	_state["transition"] = {"id": transition_id, "duration": maxf(duration, 0.0), "progress": 0.0, "active": true}

func transition_complete() -> void:
	_state["transition"]["progress"] = 1.0
	_state["transition"]["active"] = false

func audio_queue_cue(cue_id: String, volume_db: float = 0.0) -> void:
	if not cue_id.strip_edges().is_empty():
		_state["audio_queue"].append({"id": cue_id, "volume_db": clampf(volume_db, -80.0, 6.0)})

func audio_drain() -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for cue: Dictionary in _state["audio_queue"]:
		output.append(cue.duplicate(true))
	_state["audio_queue"].clear()
	return output

func hotspot_visit(hotspot_id: String) -> int:
	var hotspots: Dictionary = _state["hotspots"]
	hotspots[hotspot_id] = int(hotspots.get(hotspot_id, 0)) + 1
	return int(hotspots[hotspot_id])

func camera_shake(amplitude: float, duration: float, frequency: float = 18.0) -> Dictionary:
	_state["last_shake"] = {"amplitude": maxf(amplitude, 0.0), "duration": maxf(duration, 0.0), "frequency": maxf(frequency, 0.0)}
	return _state["last_shake"].duplicate(true)

func emit_event(event_id: String, payload: Dictionary = {}) -> void:
	if not event_id.strip_edges().is_empty():
		_events.append({"id": event_id, "payload": payload.duplicate(true)})

func drain_events() -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for event: Dictionary in _events:
		output.append(event.duplicate(true))
	_events.clear()
	return output

func capture() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "state": _state.duplicate(true), "events": _events.duplicate(true)}

func restore(snapshot: Dictionary) -> bool:
	if snapshot.get("schema_version") != SCHEMA_VERSION or not snapshot.get("state") is Dictionary or not snapshot.get("events") is Array:
		return false
	_state = snapshot["state"].duplicate(true)
	_events.clear()
	for event: Variant in snapshot["events"]:
		if event is Dictionary:
			_events.append(event.duplicate(true))
	return true

func _json_safe(value: Variant) -> bool:
	if value == null or value is bool or value is int or value is float or value is String:
		return true
	if value is Array:
		for item: Variant in value:
			if not _json_safe(item):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value:
			if not key is String and not key is StringName:
				return false
			if not _json_safe(value[key]):
				return false
		return true
	return false
