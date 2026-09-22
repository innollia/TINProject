extends GameModule

const ACTIONS: Array[StringName] = [
	&"odd_road_adventure_left",
	&"odd_road_adventure_right",
	&"odd_road_adventure_up",
	&"odd_road_adventure_down",
	&"odd_road_adventure_confirm",
	&"odd_road_adventure_cancel",
	&"odd_road_adventure_inventory",
	&"odd_road_adventure_notes",
]
const LOCATION_IDS: Array[String] = ["village", "needle", "shrine", "station"]
const LOCATION_NAMES: Array[String] = ["비뚤마을", "사막의 바늘", "뚱뚱한 수호신 사당", "빈 역"]
const ITEM_IDS: Array[String] = ["red_luck_bug", "red_thread", "paper_ticket"]
const KNOWLEDGE_IDS: Array[String] = ["road_rule", "needle_rule", "shrine_rule", "station_rule"]
const MODE_WORLD: int = 0
const MODE_INVENTORY: int = 1
const MODE_NOTES: int = 2
const MODE_DONE: int = 3

const TARGETS: Dictionary = {
	"village": [
		{"id": "notice", "label": "구부러진 공지판"},
		{"id": "bug", "label": "붉은 행운벌레"},
		{"id": "guide", "label": "길 안내인"},
		{"id": "anvil", "label": "+10 성검을 부순 모루"},
	],
	"needle": [
		{"id": "hole", "label": "바늘구멍"},
		{"id": "guide", "label": "길 안내인"},
		{"id": "thread", "label": "붉은 실 뭉치"},
	],
	"shrine": [
		{"id": "altar", "label": "뚱뚱한 수호신 제단"},
		{"id": "keeper", "label": "사당지기"},
		{"id": "bell", "label": "배 속에서 울리는 종"},
	],
	"station": [
		{"id": "gate", "label": "빈 역의 문"},
		{"id": "cart", "label": "혼자 움직이는 손수레"},
		{"id": "ticket", "label": "구겨진 승차권"},
	],
}

const DEFAULT_WORLD_FLAGS: Dictionary = {
	"needle_open": false,
	"shrine_fed": false,
	"station_open": false,
}
const DEFAULT_LOCATION_STATES: Dictionary = {
	"village": {"visits": 0, "seen": []},
	"needle": {"visits": 0, "seen": []},
	"shrine": {"visits": 0, "seen": []},
	"station": {"visits": 0, "seen": []},
}
const DEFAULT_NPC_STATES: Dictionary = {
	"guide": {"location": "village", "visits": 0, "relationship": "unknown"},
	"keeper": {"location": "shrine", "visits": 0, "relationship": "unknown"},
}
const DEFAULT_EVENT_STATES: Dictionary = {
	"needle_open": false,
	"shrine_fed": false,
	"station_open": false,
}
const DEFAULT_ROUTE_STATES: Dictionary = {
	"village_needle": true,
	"needle_shrine": false,
	"shrine_station": false,
}

var current_location: int = 0
var focus: int = 0
var item_focus: int = 0
var note_focus: int = 0
var mode: int = MODE_WORLD
var inventory: Array[String] = []
var knowledge: Array[String] = []
var notes: Array[String] = []
var used_contexts: Array[String] = []
var world_flags: Dictionary = DEFAULT_WORLD_FLAGS.duplicate(true)
var location_states: Dictionary = DEFAULT_LOCATION_STATES.duplicate(true)
var npc_states: Dictionary = DEFAULT_NPC_STATES.duplicate(true)
var event_states: Dictionary = DEFAULT_EVENT_STATES.duplicate(true)
var route_states: Dictionary = DEFAULT_ROUTE_STATES.duplicate(true)
var interactions: int = 0
var solved: bool = false
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _location_label: Label
var _target_label: Label
var _inventory_label: Label
var _notes_label: Label
var _status: Label

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("1a2730")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("기묘한 로드", Vector2(58, 38), 42, Color("f5dfac"))
	_label("같은 길에서 다른 일이 계속 생긴다", Vector2(62, 94), 20, Color("bdd4c8"))
	_location_label = _label("", Vector2(64, 145), 25, Color("f0c979"))
	_target_label = _label("", Vector2(78, 205), 22, Color("e4eee5"))
	_target_label.size = Vector2(455, 300)
	_target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inventory_label = _label("", Vector2(590, 205), 19, Color("d8c9e9"))
	_inventory_label.size = Vector2(470, 155)
	_inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notes_label = _label("", Vector2(590, 382), 18, Color("c6d9ce"))
	_notes_label.size = Vector2(470, 140)
	_notes_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("←→ 대상/항목   ↑↓ 장소   Z 조사/사용   I 가방   N 기록   X 나가기", Vector2(62, 572), 18, Color("e7c98c"))
	_status = _label("", Vector2(62, 625), 18, Color("b9d4c6"))
	_status.size = Vector2(1030, 56)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_refresh()

func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_refresh()

func exit() -> void:
	_held.clear()
	super.exit()

func _process(_delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
	for index: int in range(ACTIONS.size()):
		var action: StringName = ACTIONS[index]
		var pressed: bool = context.is_action_pressed(action)
		var previous: bool = bool(_held.get(action, false))
		_held[action] = pressed
		if pressed and not previous:
			match index:
				0:
					execute_command(&"select", {"step": -1})
				1:
					execute_command(&"select", {"step": 1})
				2:
					execute_command(&"travel", {"step": -1})
				3:
					execute_command(&"travel", {"step": 1})
				4:
					execute_command(&"confirm")
				5:
					execute_command(&"back")
				6:
					execute_command(&"inventory")
				7:
					execute_command(&"notes")
				_:
					pass

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"select":
			return _select(payload)
		&"travel":
			return _travel(payload)
		&"confirm", &"interact":
			if mode == MODE_WORLD:
				_interact()
			elif mode == MODE_INVENTORY:
				_use_selected_item()
			elif mode == MODE_NOTES:
				_read_selected_note()
			else:
				_finish()
		&"inventory":
			mode = MODE_WORLD if mode == MODE_INVENTORY else MODE_INVENTORY
			_message = "가방에서 현재 대상에 사용할 물건을 고르세요." if mode == MODE_INVENTORY else "주변을 살펴봅니다."
		&"notes":
			mode = MODE_WORLD if mode == MODE_NOTES else MODE_NOTES
			_message = "기록을 다시 읽습니다." if mode == MODE_NOTES else "주변을 살펴봅니다."
		&"back":
			if mode == MODE_INVENTORY or mode == MODE_NOTES:
				mode = MODE_WORLD
				_message = "주변을 살펴봅니다."
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		&"language":
			return payload.get("language") is String
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {
		"current_location": current_location,
		"focus": focus,
		"item_focus": item_focus,
		"note_focus": note_focus,
		"mode": mode,
		"inventory": inventory.duplicate(),
		"knowledge": knowledge.duplicate(),
		"notes": notes.duplicate(),
		"used_contexts": used_contexts.duplicate(),
		"world_flags": world_flags.duplicate(true),
		"location_states": location_states.duplicate(true),
		"npc_states": npc_states.duplicate(true),
		"event_states": event_states.duplicate(true),
		"route_states": route_states.duplicate(true),
		"interactions": interactions,
		"solved": solved,
	}

func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	current_location = int(clean["current_location"])
	focus = int(clean["focus"])
	item_focus = int(clean["item_focus"])
	note_focus = int(clean["note_focus"])
	mode = int(clean["mode"])
	inventory.assign(clean["inventory"])
	knowledge.assign(clean["knowledge"])
	notes.assign(clean["notes"])
	used_contexts.assign(clean["used_contexts"])
	world_flags = clean["world_flags"].duplicate(true)
	location_states = clean["location_states"].duplicate(true)
	npc_states = clean["npc_states"].duplicate(true)
	event_states = clean["event_states"].duplicate(true)
	route_states = clean["route_states"].duplicate(true)
	interactions = int(clean["interactions"])
	solved = bool(clean["solved"])
	_request_sent = false
	_held.clear()
	_message = ""
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _select(payload: Dictionary) -> bool:
	var raw_step: Variant = payload.get("step")
	if raw_step != -1 and raw_step != 1:
		return false
	var step: int = int(raw_step)
	if mode == MODE_WORLD:
		var targets: Array = _targets()
		focus = posmod(focus + step, targets.size())
	elif mode == MODE_INVENTORY:
		if inventory.is_empty():
			return true
		item_focus = posmod(item_focus + step, inventory.size())
	elif mode == MODE_NOTES:
		if notes.is_empty():
			return true
		note_focus = posmod(note_focus + step, notes.size())
	else:
		return false
	_message = ""
	_refresh()
	return true

func _travel(payload: Dictionary) -> bool:
	var raw_step: Variant = payload.get("step")
	if raw_step != -1 and raw_step != 1 or mode != MODE_WORLD:
		return false
	var candidate: int = posmod(current_location + int(raw_step), LOCATION_IDS.size())
	if not _location_unlocked(candidate):
		_message = "%s로 가는 길은 아직 이어지지 않았다." % LOCATION_NAMES[candidate]
		_refresh()
		return true
	current_location = candidate
	focus = 0
	var location_id: String = _location_id()
	var location_state: Dictionary = location_states[location_id]
	location_state["visits"] = mini(int(location_state["visits"]) + 1, 9999)
	location_states[location_id] = location_state
	_message = "%s에 도착했다. 익숙한 방식으로 주변을 살핀다." % LOCATION_NAMES[current_location]
	_refresh()
	return true

func _interact() -> void:
	var target: Dictionary = _target()
	if target.is_empty():
		return
	interactions = mini(interactions + 1, 9999)
	_mark_seen(String(target["id"]))
	match _location_id() + ":" + String(target["id"]):
		"village:notice":
			_observe_once("odd_road.village.notice", "공지판에는 ‘길은 한 번 본 사람을 기억한다’고 적혀 있다.", "road_rule", "길은 본 사람을 기억한다.")
		"village:bug":
			_pickup("red_luck_bug", "붉은 행운벌레가 소매 안으로 기어들어 왔다.")
		"village:guide":
			_talk_guide()
		"village:anvil":
			_observe_once("odd_road.village.anvil", "모루에는 +10 성검을 부순 흔적과 ‘강한 물건도 쓰임은 하나가 아니다’라는 낙서가 있다.", "road_rule", "이 길의 물건은 한 번 쓰고 사라지지 않는다.")
		"needle:hole":
			_observe_once("odd_road.needle.hole", "바늘구멍 안쪽에서 방 하나의 불빛이 새어 나온다. 붉은 것이 가까이 가면 반응할 것 같다.", "needle_rule", "바늘구멍은 붉은 것을 길로 착각한다.")
		"needle:guide":
			_talk_guide()
		"needle:thread":
			_pickup("red_thread", "바늘구멍에서 붉은 실 뭉치를 꺼냈다.")
		"shrine:altar":
			_observe_once("odd_road.shrine.altar", "수호신은 먹을 것보다 ‘다시 찾아오는 것’을 기다리는 눈치다. 가방을 열어 보자.", "shrine_rule", "사당은 한 번의 제물보다 반복 방문을 기억한다.")
		"shrine:keeper":
			_talk_keeper()
		"shrine:bell":
			_observe_once("odd_road.shrine.bell", "제단 안쪽의 종은 아직 울리지 않았지만, 바늘 쪽에서 같은 진동이 돌아온다.", "shrine_rule", "사당과 바늘은 같은 길의 양 끝이다.")
		"station:gate":
			_open_station()
		"station:cart":
			_observe_once("odd_road.station.cart", "손수레는 사람이 타지 않아도 다음 장소를 기억하고 있다.", "station_rule", "빈 역은 목적지보다 방문 기록을 먼저 확인한다.")
		"station:ticket":
			_pickup("paper_ticket", "승차권 뒷면에 아직 쓰이지 않은 목적지가 남아 있다.")
		_:
			_message = "아직 이 대상에 할 일이 없다."
	_refresh()

func _use_selected_item() -> void:
	if inventory.is_empty():
		_message = "가방이 비어 있다. 먼저 주변에서 물건을 찾아야 한다."
		_refresh()
		return
	var target: Dictionary = _target()
	var item_id: String = inventory[item_focus]
	var target_id: String = String(target.get("id", ""))
	var context_id: String = "%s:%s" % [_location_id(), target_id]
	if item_id == "red_luck_bug" and target_id == "hole" and current_location == 1:
		if bool(event_states["needle_open"]):
			_message = "바늘구멍은 이미 붉은 길을 기억하고 있다."
		else:
			event_states["needle_open"] = true
			world_flags["needle_open"] = true
			_add_used_context(context_id)
			_add_knowledge("needle_rule")
			_add_note("붉은 행운벌레를 바늘구멍에 다시 사용하면 사당으로 가는 길이 열린다.")
			_sync_routes()
			_message = "바늘구멍 안의 방이 열렸다. 멀리서 사당의 종이 한 번 울렸다."
	elif item_id == "red_luck_bug" and target_id == "altar" and current_location == 2:
		if bool(event_states["shrine_fed"]):
			_message = "수호신은 이미 행운벌레의 귀환을 기다리고 있다."
		else:
			event_states["shrine_fed"] = true
			world_flags["shrine_fed"] = true
			_add_used_context(context_id)
			_add_knowledge("shrine_rule")
			_add_note("수호신은 제물을 먹고도 행운벌레가 돌아올 길을 남겨 두었다.")
			_sync_routes()
			_message = "수호신이 배를 두드렸다. 빈 역으로 가는 표지판이 생겼다."
	else:
		_message = "%s에는 %s를 쓸 일이 아직 없다." % [String(target.get("label", "여기")), _item_name(item_id)]
	_refresh()

func _talk_guide() -> void:
	var guide: Dictionary = npc_states["guide"]
	guide["visits"] = mini(int(guide["visits"]) + 1, 9999)
	if current_location == 0:
		guide["relationship"] = "met"
		guide["location"] = "needle"
		_add_knowledge("road_rule")
		_add_note("길 안내인은 먼저 바늘 쪽으로 가서 기다리겠다고 했다.")
		_message = "길 안내인이 먼저 사막의 바늘로 갔다. 다음에 만나면 다른 이야기를 들을 수 있다."
	elif current_location == 1:
		guide["relationship"] = "trusted"
		guide["location"] = "needle"
		_add_knowledge("station_rule")
		_add_note("길 안내인은 수호신의 종이 울리면 빈 역도 문을 연다고 말했다.")
		_message = "길 안내인이 같은 이야기를 다른 순서로 들려줬다. 빈 역의 문을 기억했다."
	else:
		_message = "길 안내인은 이 장소에서는 길보다 기록을 먼저 보라고 한다."
	npc_states["guide"] = guide
	_sync_routes()

func _talk_keeper() -> void:
	var keeper: Dictionary = npc_states["keeper"]
	keeper["visits"] = mini(int(keeper["visits"]) + 1, 9999)
	keeper["relationship"] = "known"
	_add_knowledge("shrine_rule")
	_add_note("사당지기는 수호신이 뚱뚱해지는 것보다 다시 찾아오는 손님을 좋아한다고 했다.")
	npc_states["keeper"] = keeper
	_message = "사당지기는 다음 방문에도 같은 자리에서 기다리겠다고 했다."

func _open_station() -> void:
	var guide: Dictionary = npc_states["guide"]
	if not bool(event_states["needle_open"]):
		_message = "역무원 없는 문에는 바늘구멍의 붉은 빛이 먼저 필요하다."
		return
	if not bool(event_states["shrine_fed"]):
		_message = "문은 열렸지만 손수레가 움직이지 않는다. 사당 쪽 기록이 비어 있다."
		return
	if String(guide["relationship"]) != "trusted":
		_message = "문이 길 안내인의 이름을 묻는다. 바늘에서 그와 다시 이야기해야 한다."
		return
	if not bool(event_states["station_open"]):
		event_states["station_open"] = true
		world_flags["station_open"] = true
		_add_note("바늘, 사당, 안내인의 기록이 빈 역에서 하나의 노선이 되었다.")
		_message = "손수레가 목적지를 기억했다. Z를 한 번 더 눌러 다음 공간으로 간다."
		solved = true
		mode = MODE_DONE
	else:
		_message = "빈 역의 문은 이미 다음 공간으로 이어져 있다."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "odd_road_adventure.solved", "text": "바늘과 사당과 안내인의 기록이 하나의 길이 되었다."})
	requested.emit(&"portal", {"exit": "forward"})

func _observe_once(observation_id: String, text: String, knowledge_id: String, note: String) -> void:
	_add_knowledge(knowledge_id)
	_add_note(note)
	_message = text
	if not _has_note(observation_id):
		_add_note(observation_id)
		requested.emit(&"observation", {"id": observation_id, "text": text})

func _pickup(item_id: String, text: String) -> void:
	if inventory.has(item_id):
		_message = "%s는 이미 가방에 있다." % _item_name(item_id)
		return
	inventory.append(item_id)
	_add_note(text)
	_message = text
	requested.emit(&"observation", {"id": "odd_road.item." + item_id, "text": text})

func _read_selected_note() -> void:
	if notes.is_empty():
		_message = "아직 기록이 없다."
	else:
		_message = notes[note_focus]

func _mark_seen(target_id: String) -> void:
	var location_state: Dictionary = location_states[_location_id()]
	var seen: Array = location_state["seen"]
	if not seen.has(target_id):
		seen.append(target_id)
	location_state["seen"] = seen
	location_states[_location_id()] = location_state

func _add_used_context(context_id: String) -> void:
	if not used_contexts.has(context_id):
		used_contexts.append(context_id)

func _add_knowledge(value: String) -> void:
	if KNOWLEDGE_IDS.has(value) and not knowledge.has(value):
		knowledge.append(value)

func _add_note(value: String) -> void:
	if not notes.has(value):
		notes.append(value)
		note_focus = clampi(note_focus, 0, maxi(notes.size() - 1, 0))

func _has_note(value: String) -> bool:
	return notes.has(value)

func _sync_routes() -> void:
	route_states["village_needle"] = true
	route_states["needle_shrine"] = bool(event_states["needle_open"])
	var guide: Dictionary = npc_states["guide"]
	route_states["shrine_station"] = bool(event_states["shrine_fed"]) or String(guide["relationship"]) == "trusted"

func _location_unlocked(index: int) -> bool:
	if index == 0 or index == 1:
		return true
	if index == 2:
		return bool(route_states["needle_shrine"])
	return bool(route_states["shrine_station"])

func _location_id() -> String:
	return LOCATION_IDS[current_location]

func _targets() -> Array:
	return TARGETS[_location_id()]

func _target() -> Dictionary:
	var targets: Array = _targets()
	if targets.is_empty():
		return {}
	return targets[clampi(focus, 0, targets.size() - 1)]

func _item_name(item_id: String) -> String:
	match item_id:
		"red_luck_bug": return "붉은 행운벌레"
		"red_thread": return "붉은 실 뭉치"
		"paper_ticket": return "구겨진 승차권"
		_:
			return item_id

func _normalize(data: Dictionary) -> Dictionary:
	var clean_location: int = _integer(data.get("current_location"), 0, 0, LOCATION_IDS.size() - 1)
	var clean_mode: int = _integer(data.get("mode"), MODE_WORLD, MODE_WORLD, MODE_DONE)
	var clean_inventory: Array[String] = _string_array(data.get("inventory"), ITEM_IDS)
	var clean_knowledge: Array[String] = _string_array(data.get("knowledge"), KNOWLEDGE_IDS)
	var clean_notes: Array[String] = _string_array(data.get("notes"), [])
	var clean_used: Array[String] = _string_array(data.get("used_contexts"), [])
	var clean_flags: Dictionary = _bool_dictionary(data.get("world_flags"), DEFAULT_WORLD_FLAGS)
	var clean_events: Dictionary = _bool_dictionary(data.get("event_states"), DEFAULT_EVENT_STATES)
	var clean_routes: Dictionary = _bool_dictionary(data.get("route_states"), DEFAULT_ROUTE_STATES)
	var clean_locations: Dictionary = _location_dictionary(data.get("location_states"))
	var clean_npcs: Dictionary = _npc_dictionary(data.get("npc_states"))
	var target_count: int = _target_count(clean_location)
	var clean_focus: int = _integer(data.get("focus"), 0, 0, target_count - 1)
	var clean_item_focus: int = _integer(data.get("item_focus"), 0, 0, maxi(clean_inventory.size() - 1, 0))
	var clean_note_focus: int = _integer(data.get("note_focus"), 0, 0, maxi(clean_notes.size() - 1, 0))
	clean_mode = MODE_WORLD if clean_mode == MODE_DONE and not bool(data.get("solved", false)) else clean_mode
	clean_routes["village_needle"] = true
	clean_routes["needle_shrine"] = bool(clean_events["needle_open"])
	var guide: Dictionary = clean_npcs["guide"]
	clean_routes["shrine_station"] = bool(clean_events["shrine_fed"]) or String(guide["relationship"]) == "trusted"
	return {
		"current_location": clean_location,
		"focus": clean_focus,
		"item_focus": clean_item_focus,
		"note_focus": clean_note_focus,
		"mode": clean_mode,
		"inventory": clean_inventory,
		"knowledge": clean_knowledge,
		"notes": clean_notes,
		"used_contexts": clean_used,
		"world_flags": clean_flags,
		"location_states": clean_locations,
		"npc_states": clean_npcs,
		"event_states": clean_events,
		"route_states": clean_routes,
		"interactions": _integer(data.get("interactions"), 0, 0, 9999),
		"solved": data.get("solved") is bool and bool(data["solved"]),
	}

func _string_array(value: Variant, allowed: Array[String]) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for raw: Variant in value:
		if not raw is String:
			continue
		var item: String = String(raw)
		if (allowed.is_empty() or allowed.has(item)) and not result.has(item):
			result.append(item)
	return result

func _bool_dictionary(value: Variant, defaults: Dictionary) -> Dictionary:
	var result: Dictionary = defaults.duplicate(true)
	if value is Dictionary:
		for key: String in defaults:
			if value.get(key) is bool:
				result[key] = value[key]
	return result

func _location_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = DEFAULT_LOCATION_STATES.duplicate(true)
	if value is Dictionary:
		for location_id: String in LOCATION_IDS:
			var raw: Variant = value.get(location_id)
			if not raw is Dictionary:
				continue
			var row: Dictionary = result[location_id]
			row["visits"] = _integer(raw.get("visits"), 0, 0, 9999)
			row["seen"] = _string_array(raw.get("seen"), _target_ids(location_id))
			result[location_id] = row
	return result

func _npc_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = DEFAULT_NPC_STATES.duplicate(true)
	if value is Dictionary:
		for npc_id: String in ["guide", "keeper"]:
			var raw: Variant = value.get(npc_id)
			if not raw is Dictionary:
				continue
			var row: Dictionary = result[npc_id]
			row["visits"] = _integer(raw.get("visits"), 0, 0, 9999)
			if raw.get("location") is String and LOCATION_IDS.has(String(raw["location"])):
				row["location"] = String(raw["location"])
			if raw.get("relationship") is String:
				row["relationship"] = String(raw["relationship"]).left(24)
			result[npc_id] = row
	return result

func _target_ids(location_id: String) -> Array[String]:
	var result: Array[String] = []
	for raw: Variant in TARGETS[location_id]:
		if raw is Dictionary:
			result.append(String(raw["id"]))
	return result

func _target_count(location_index: int) -> int:
	return TARGETS[LOCATION_IDS[location_index]].size()

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	_location_label.text = "%s  ·  %s" % [LOCATION_NAMES[current_location], _mode_name()]
	var targets: Array = _targets()
	var target_lines: Array[String] = []
	for index: int in range(targets.size()):
		var target: Dictionary = targets[index]
		var marker: String = "▶" if mode == MODE_WORLD and index == focus else " "
		target_lines.append("%s %s" % [marker, String(target["label"])])
	_target_label.text = "대상\n" + "\n".join(target_lines)
	var item_lines: Array[String] = []
	if inventory.is_empty():
		item_lines.append("(비어 있음)")
	else:
		for index: int in range(inventory.size()):
			var marker: String = "▶" if mode == MODE_INVENTORY and index == item_focus else " "
			item_lines.append("%s %s" % [marker, _item_name(inventory[index])])
	_inventory_label.text = "가방\n" + "\n".join(item_lines)
	var note_lines: Array[String] = []
	if notes.is_empty():
		note_lines.append("기록 없음")
	else:
		for index: int in range(notes.size()):
			var marker: String = "▶" if mode == MODE_NOTES and index == note_focus else " "
			note_lines.append("%s %s" % [marker, notes[index]])
	_notes_label.text = "기록\n" + "\n".join(note_lines)
	if _message.is_empty():
		_status.text = _default_status()
	else:
		_status.text = _message

func _mode_name() -> String:
	match mode:
		MODE_INVENTORY: return "가방"
		MODE_NOTES: return "기록"
		MODE_DONE: return "길 완성"
		_:
			return "주변 조사"

func _default_status() -> String:
	if mode == MODE_INVENTORY:
		return "Z로 현재 대상에 선택한 물건을 사용합니다. 물건은 여러 장소에서 다시 쓸 수 있습니다."
	if mode == MODE_NOTES:
		return "이전에 얻은 지식과 사건의 결과를 다시 확인합니다."
	if mode == MODE_DONE:
		return "같은 길이 다음 공간으로 이어졌다. Z로 이동합니다."
	return "길 안내인, 바늘, 사당의 기록을 순서와 상관없이 이어 보세요."

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(label)
	return label
