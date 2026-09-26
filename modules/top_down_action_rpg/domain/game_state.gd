class_name TopDownActionRpgGameState
extends RefCounted

const SCHEMA_VERSION: int = 1
const STATE_FORMAT: String = "top_down_action_rpg.save.v1"
const MAX_JSON_DEPTH: int = 64
const MAX_TICK: int = 9999
const COMMIT_LOG_CAP: int = 256
const AXIS_MIN: int = -3
const AXIS_MAX: int = 3
const CLOCK_STAGE_COUNT: int = 6
const IRREVERSIBLE_STAGE: int = 4
const TERMINAL_STAGE: int = 5
const DOCUMENT_PAGE_LINE_CAP: int = 9
const PLAYER_CONTINUITY: String = "single"
const PLAYER_ROLE_ID: String = "player_continuity_head"

const MODES: Array[String] = [
	"field",
	"dialogue",
	"service",
	"encounter_prepare",
	"encounter_transition",
	"combat",
	"encounter_result",
	"field_return",
	"recovery",
]

const AXES: Array[String] = [
	"protocol_legitimacy",
	"recognition_drift",
	"continuity_pressure",
	"resource_scarcity",
]

const CLOCK_IDS: Array[String] = [
	"clock_institutional_response",
	"clock_contamination",
	"clock_public_record",
	"clock_resource_collapse",
	"clock_personal_collapse",
	"clock_crown_alignment",
]

const EQUIPMENT_SLOTS: Array[String] = ["weapon", "offhand", "armor", "accessory"]

const SELF_LAYERS: Array[String] = [
	"body",
	"memory",
	"role",
	"belief",
	"institution",
	"desire",
	"social_recognition",
]

const MAGIC_CHILDREN: Array[String] = [
	"concentration_fields",
	"body_load",
	"circulation",
	"crafts",
	"contracts",
	"glossary",
]

const ROUTE_STATES: Array[String] = [
	"locked",
	"open",
	"conditional",
	"redirected",
	"closed",
	"debt-bearing",
]

const COMBAT_RESOURCE_KEYS: Array[String] = ["hp", "mp", "equipment_charge"]

const MANA_PROFILES: Array[String] = [
	"retention_high_emission_low",
	"retention_low_emission_high",
	"retention_balanced",
	"retention_overflow",
	"blocked_emission",
	"concentration_reactive",
	"medium_reactive",
	"sensory_misclassification",
]

const DEBT_RESOURCE_KEYS: Array[String] = ["res_labor_pledge", "res_contract_tally"]

const AXIS_TOKENS: Dictionary = {
	"protocol_legitimacy": [
		"unlicensed_floor", "unlicensed", "provisional", "sanctioned",
		"contested", "successor", "successor_peak",
	],
	"recognition_drift": [
		"person", "patient", "operator", "artifact",
		"organ-authority", "unclassified", "unclassified_peak",
	],
	"continuity_pressure": [
		"single_floor", "single", "linked", "branched",
		"loop-bound", "crown-debt", "crown_debt_peak",
	],
	"resource_scarcity": [
		"buffered", "rationed", "localized", "strained",
		"failing", "collapsed", "externally-mediated",
	],
}

const CLOCK_STAGE_TOKENS: Dictionary = {
	"clock_institutional_response": [
		"noticed", "assigned", "contested", "intervened", "filed", "superseded",
	],
	"clock_contamination": [
		"clean", "exposed", "active", "systemic", "irreversible", "collapsed",
	],
	"clock_public_record": [
		"private", "circulating", "contested", "filing", "canonical", "retired",
	],
	"clock_resource_collapse": [
		"buffered", "rationed", "localized", "failing", "collapsed", "externally_mediated",
	],
	"clock_personal_collapse": [
		"role_bound", "divergent", "contested", "intervened", "self_authored", "lost",
	],
	"clock_crown_alignment": [
		"vacant", "contested", "aligned", "intervened", "fixed", "locked",
	],
}

const SECTION_KEYS: Array[String] = [
	"field", "combat", "player", "world", "recovery", "progression",
	"transaction", "commit_log",
]

const WORLD_KEYS: Array[String] = [
	"crown", "axes", "clocks", "regions", "routes", "props", "npcs",
	"relationships", "encounters", "records", "resources", "magic", "flags",
	"effects_fired",
]

const RESUME_BOUNDARY_KEYS: Array[String] = [
	"field", "dialogue", "service", "encounter_prepare", "encounter_transition",
	"combat", "encounter_result", "field_return", "recovery",
]

var schema_version: int = SCHEMA_VERSION
var state_format: String = STATE_FORMAT
var save_version: int = 1
var run_id: String = "run_undersign"
var content_revision: String = ""

var mode: String = "field"
var field: Dictionary = {}
var combat: Dictionary = {}
var player: Dictionary = {}
var world: Dictionary = {}
var recovery: Dictionary = {}
var progression: Dictionary = {}
var transaction: Dictionary = {}
var commit_log: Array = []

var rng_state: int = 0x9E3779B9
var resolution_serial: int = 0


static func create_default(entry_region_id: String, entry_anchor_id: String) -> TopDownActionRpgGameState:
	var state := TopDownActionRpgGameState.new()
	state.run_id = "run_" + entry_region_id
	state.field = _default_field(entry_region_id, entry_anchor_id)
	state.combat = _default_combat()
	state.player = _default_player()
	state.world = _default_world(entry_region_id)
	state.recovery = _default_recovery()
	state.progression = _default_progression()
	state.transaction = _default_transaction()
	state.commit_log = []
	state.mode = "field"
	state.combat["resume_boundary"] = "field"
	return state


static func axis_token(axis: String, value: int) -> String:
	var ladder: Array = AXIS_TOKENS.get(axis, [])
	if ladder.is_empty():
		return ""
	return String(ladder[clampi(value - AXIS_MIN, 0, ladder.size() - 1)])


static func axis_value_of_token(axis: String, token: String) -> int:
	var ladder: Array = AXIS_TOKENS.get(axis, [])
	var index: int = ladder.find(token)
	return AXIS_MIN + index if index >= 0 else 0


static func clock_stage_token(clock_id: String, stage: int) -> String:
	var ladder: Array = CLOCK_STAGE_TOKENS.get(clock_id, [])
	if ladder.is_empty():
		return ""
	return String(ladder[clampi(stage, 0, ladder.size() - 1)])


static func clock_stage_of_token(clock_id: String, token: String) -> int:
	var ladder: Array = CLOCK_STAGE_TOKENS.get(clock_id, [])
	var index: int = ladder.find(token)
	return index if index >= 0 else 0


static func is_valid_axis(axis: String) -> bool:
	return AXES.has(axis)


static func is_valid_axis_value(value: int) -> bool:
	return value >= AXIS_MIN and value <= AXIS_MAX


static func is_valid_clock(clock_id: String) -> bool:
	return CLOCK_IDS.has(clock_id)


static func derive_mode(payload: Dictionary) -> String:
	var combat_section: Dictionary = payload.get("combat", {}) if payload.get("combat", {}) is Dictionary else {}
	var recovery_section: Dictionary = payload.get("recovery", {}) if payload.get("recovery", {}) is Dictionary else {}
	var boundary: String = String(combat_section.get("resume_boundary", "field"))
	if RESUME_BOUNDARY_KEYS.has(boundary):
		return boundary
	if not String(recovery_section.get("pending_outcome_id", "")).is_empty():
		return "recovery"
	if not String(combat_section.get("active_encounter_id", "")).is_empty():
		return "combat"
	return "field"


func to_dict() -> Dictionary:
	return {
		"state_format": state_format,
		"save_version": save_version,
		"run_id": run_id,
		"content_revision": content_revision,
		"field": _sanitize_dictionary(field),
		"combat": _sanitize_dictionary(combat),
		"player": _sanitize_dictionary(player),
		"world": _sanitize_dictionary(world),
		"recovery": _sanitize_dictionary(recovery),
		"progression": _sanitize_dictionary(progression),
		"transaction": _sanitize_dictionary(transaction),
		"commit_log": _sanitize_json(commit_log),
	}


func from_dict(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if String(data.get("state_format", "")) != STATE_FORMAT:
		return false
	if not _is_integer(data.get("save_version")):
		return false
	var section_set: Dictionary = {}
	for key: Variant in data.keys():
		if key is not String:
			return false
		section_set[key] = true
	for key: String in SECTION_KEYS:
		if not section_set.has(key):
			return false
	var world_section: Dictionary = data.get("world", {}) if data.get("world", {}) is Dictionary else {}
	if not _is_world_shape(world_section):
		return false
	schema_version = SCHEMA_VERSION
	state_format = STATE_FORMAT
	save_version = int(data["save_version"])
	run_id = String(data.get("run_id", "run_undersign"))
	content_revision = String(data.get("content_revision", ""))
	field = _sanitize_dictionary(data.get("field"))
	combat = _sanitize_dictionary(data.get("combat"))
	player = _sanitize_dictionary(data.get("player"))
	world = _sanitize_dictionary(world_section)
	recovery = _sanitize_dictionary(data.get("recovery"))
	progression = _sanitize_dictionary(data.get("progression"))
	transaction = _sanitize_dictionary(data.get("transaction"))
	commit_log = _sanitize_dictionary_list(data.get("commit_log"))
	mode = derive_mode(data)
	var rng_value: Variant = world.get("rng_state", rng_state)
	rng_state = absi(int(rng_value)) if _is_integer(rng_value) else 0x9E3779B9
	if rng_state == 0:
		rng_state = 0x9E3779B9
	var serial_value: Variant = transaction.get("resolution_serial", resolution_serial)
	resolution_serial = maxi(0, int(serial_value)) if _is_integer(serial_value) else 0
	_normalize()
	return true


func set_mode(next_mode: String) -> bool:
	if not MODES.has(next_mode):
		return false
	mode = next_mode
	combat["resume_boundary"] = next_mode
	return true


func region_id() -> String:
	return String(field.get("region_id", ""))


func set_region(next_region_id: String, next_anchor_id: String) -> void:
	field["region_id"] = next_region_id
	field["anchor_id"] = next_anchor_id
	ensure_clocks(next_region_id)
	var region_record: Dictionary = world["regions"].get(next_region_id, {}) if world.get("regions", {}) is Dictionary else {}
	if region_record is Dictionary and not region_record.is_empty():
		field["scene_id"] = String(region_record.get("scene_id", next_region_id))


func field_actor() -> Dictionary:
	var actor: Variant = field.get("actor", {})
	return actor if actor is Dictionary else {}


func set_field_actor(x: float, y: float, facing: int) -> void:
	field["actor"] = {"x": x, "y": y, "facing": clampi(facing, 0, 3)}


func axis_value(axis: String) -> int:
	var axes: Dictionary = world.get("axes", {}) if world.get("axes", {}) is Dictionary else {}
	var record: Variant = axes.get(axis, {})
	if record is Dictionary and _is_integer(record.get("value")):
		return clampi(int(record["value"]), AXIS_MIN, AXIS_MAX)
	return 0


func set_axis_value(axis: String, value: int, event_id: String) -> bool:
	if not is_valid_axis(axis) or not is_valid_axis_value(value):
		return false
	var axes: Dictionary = world.get("axes", {}) if world.get("axes", {}) is Dictionary else {}
	axes[axis] = {"value": value, "last_write_event_id": event_id}
	world["axes"] = axes
	return true


func axis_claim(region: String, claim_id: String, token: String) -> void:
	var axes: Dictionary = world.get("axes", {}) if world.get("axes", {}) is Dictionary else {}
	var primary: Dictionary = axes.get("recognition_drift", {}) if axes.get("recognition_drift", {}) is Dictionary else {"value": 0}
	var claims: Array = primary.get("disputed_claims", []) if primary.get("disputed_claims", []) is Array else []
	for claim: Variant in claims:
		if claim is Dictionary and String(claim.get("claim_id", "")) == claim_id:
			claim["token"] = token
			claim["source_region_id"] = region
			primary["disputed_claims"] = claims
			axes["recognition_drift"] = primary
			world["axes"] = axes
			return
	claims.append({"claim_id": claim_id, "token": token, "source_region_id": region})
	primary["disputed_claims"] = claims
	axes["recognition_drift"] = primary
	world["axes"] = axes


func ensure_clocks(region: String) -> void:
	var clocks: Dictionary = world.get("clocks", {}) if world.get("clocks", {}) is Dictionary else {}
	clocks[region] = _canonical_clock_entry(clocks.get(region, {}))
	world["clocks"] = clocks


func clock_stage(region: String, clock_id: String) -> int:
	var clocks: Dictionary = world.get("clocks", {}) if world.get("clocks", {}) is Dictionary else {}
	var entry: Variant = clocks.get(region, {})
	if not entry is Dictionary:
		return 0
	var record: Variant = entry.get(clock_id, {})
	if not record is Dictionary or not _is_integer(record.get("stage_index")):
		return 0
	return clampi(int(record["stage_index"]), 0, TERMINAL_STAGE)


func advance_clock(region: String, clock_id: String, ticks: int, event_id: String) -> int:
	if not is_valid_clock(clock_id) or ticks < 0:
		return -1
	ensure_clocks(region)
	var entry: Dictionary = world["clocks"][region]
	var record: Dictionary = entry[clock_id]
	var stage: int = clampi(int(record.get("stage_index", 0)) + ticks, 0, TERMINAL_STAGE)
	record["stage_index"] = stage
	record["tick"] = clampi(int(record.get("tick", 0)) + ticks, 0, MAX_TICK)
	record["last_signal"] = String(record.get("last_signal", ""))
	record["committed_event_id"] = event_id
	entry[clock_id] = record
	return stage


func clock_is_irreversible(region: String, clock_id: String) -> bool:
	return clock_stage(region, clock_id) >= IRREVERSIBLE_STAGE


func set_clock_stage(region: String, clock_id: String, stage: int, event_id: String) -> int:
	if not is_valid_clock(clock_id):
		return -1
	ensure_clocks(region)
	var entry: Dictionary = world["clocks"][region]
	var record: Dictionary = entry[clock_id]
	record["stage_index"] = clampi(stage, 0, TERMINAL_STAGE)
	record["committed_event_id"] = event_id
	entry[clock_id] = record
	return int(record["stage_index"])


func crown_record() -> Dictionary:
	var crown: Variant = world.get("crown", {})
	return crown if crown is Dictionary else {}


func write_crown_alignment(precedence: String, operator_id: String, object_phase: int, event_id: String) -> bool:
	if precedence.strip_edges().is_empty():
		return false
	world["crown"] = {
		"precedence": precedence,
		"operator_id": operator_id,
		"object_phase": maxi(0, object_phase),
		"alignment_event_id": event_id,
	}
	set_axis_value("continuity_pressure", axis_value_of_token("continuity_pressure", "crown-debt"), event_id)
	return true


func magic_section() -> Dictionary:
	var magic: Variant = world.get("magic", {})
	return magic if magic is Dictionary else {}


func magic_child(child: String) -> Dictionary:
	if not MAGIC_CHILDREN.has(child):
		return {}
	var section: Dictionary = magic_section()
	var record: Variant = section.get(child, {})
	return record if record is Dictionary else {}


func open_contract_count() -> int:
	var contracts: Dictionary = magic_child("contracts")
	var count: int = 0
	for key: Variant in contracts:
		var contract: Variant = contracts[key]
		if contract is Dictionary and String(contract.get("obligation_state", "")) == "open":
			count += 1
	return count


func resource_amount(key: String) -> int:
	var resources: Dictionary = world.get("resources", {}) if world.get("resources", {}) is Dictionary else {}
	if DEBT_RESOURCE_KEYS.has(key):
		return -1
	var record: Variant = resources.get(key, {})
	if record is Dictionary and _is_integer(record.get("amount")):
		return maxi(0, int(record["amount"]))
	return 0


func grant_resource(key: String, amount: int, provenance: String = "") -> bool:
	if amount <= 0 or DEBT_RESOURCE_KEYS.has(key):
		return false
	var resources: Dictionary = world.get("resources", {}) if world.get("resources", {}) is Dictionary else {}
	var record: Dictionary = resources.get(key, {}) if resources.get(key, {}) is Dictionary else {"amount": 0}
	record["amount"] = maxi(0, int(record.get("amount", 0)) + amount)
	if not provenance.is_empty():
		record["provenance"] = provenance
	resources[key] = record
	world["resources"] = resources
	return true


func consume_resource(key: String, amount: int) -> bool:
	if amount <= 0 or DEBT_RESOURCE_KEYS.has(key):
		return false
	var resources: Dictionary = world.get("resources", {}) if world.get("resources", {}) is Dictionary else {}
	var record: Variant = resources.get(key, {})
	if not record is Dictionary or int(record.get("amount", 0)) < amount:
		return false
	record["amount"] = int(record["amount"]) - amount
	resources[key] = record
	world["resources"] = resources
	return true


func route_state(edge_id: String) -> String:
	var routes: Dictionary = world.get("routes", {}) if world.get("routes", {}) is Dictionary else {}
	var record: Variant = routes.get(edge_id, {})
	if record is Dictionary and ROUTE_STATES.has(String(record.get("route_state", ""))):
		return String(record["route_state"])
	return "locked"


func set_route_state(edge_id: String, next_state: String, event_id: String) -> bool:
	if not ROUTE_STATES.has(next_state):
		return false
	var routes: Dictionary = world.get("routes", {}) if world.get("routes", {}) is Dictionary else {}
	var record: Dictionary = routes.get(edge_id, {}) if routes.get(edge_id, {}) is Dictionary else {}
	record["route_state"] = next_state
	record["gate_id"] = String(record.get("gate_id", ""))
	record["last_write_event_id"] = event_id
	routes[edge_id] = record
	world["routes"] = routes
	return true


func npc_state(npc_id: String) -> Dictionary:
	var npcs: Dictionary = world.get("npcs", {}) if world.get("npcs", {}) is Dictionary else {}
	var record: Variant = npcs.get(npc_id, {})
	return record if record is Dictionary else {}


func set_npc_state(npc_id: String, key: String, value: Variant) -> bool:
	if npc_id.is_empty() or not ["presence", "state_key", "region_id", "acting_role"].has(key):
		return false
	var npcs: Dictionary = world.get("npcs", {}) if world.get("npcs", {}) is Dictionary else {}
	var record: Dictionary = npcs.get(npc_id, {}) if npcs.get(npc_id, {}) is Dictionary else {}
	record[key] = value
	npcs[npc_id] = record
	world["npcs"] = npcs
	return true


func relationship_state(relationship_id: String) -> String:
	var relationships: Dictionary = world.get("relationships", {}) if world.get("relationships", {}) is Dictionary else {}
	var record: Variant = relationships.get(relationship_id, {})
	if record is Dictionary:
		return String(record.get("state_id", ""))
	return ""


func set_relationship_state(relationship_id: String, state_id: String) -> bool:
	if relationship_id.is_empty() or state_id.is_empty():
		return false
	var relationships: Dictionary = world.get("relationships", {}) if world.get("relationships", {}) is Dictionary else {}
	var record: Dictionary = relationships.get(relationship_id, {}) if relationships.get(relationship_id, {}) is Dictionary else {}
	record["state_id"] = state_id
	record["visited_state_ids"] = _append_unique(_string_array(record.get("visited_state_ids", [])), state_id)
	relationships[relationship_id] = record
	world["relationships"] = relationships
	return true


func prop_state(prop_id: String) -> String:
	var props: Dictionary = world.get("props", {}) if world.get("props", {}) is Dictionary else {}
	var record: Variant = props.get(prop_id, {})
	if record is Dictionary:
		return String(record.get("state_id", ""))
	return ""


func set_prop_state(prop_id: String, state_id: String) -> bool:
	if prop_id.is_empty() or state_id.is_empty():
		return false
	var props: Dictionary = world.get("props", {}) if world.get("props", {}) is Dictionary else {}
	props[prop_id] = {"state_id": state_id}
	world["props"] = props
	return true


func set_flag(key: String, value: bool) -> bool:
	if not key.begins_with("world_"):
		return false
	var flags: Dictionary = world.get("flags", {}) if world.get("flags", {}) is Dictionary else {}
	flags[key] = value
	world["flags"] = flags
	return true


func flag_is(key: String) -> bool:
	var flags: Dictionary = world.get("flags", {}) if world.get("flags", {}) is Dictionary else {}
	return bool(flags.get(key, false))


func mark_effect_fired(effect_id: String) -> bool:
	if effect_id.is_empty():
		return false
	var fired: Dictionary = world.get("effects_fired", {}) if world.get("effects_fired", {}) is Dictionary else {}
	if fired.has(effect_id):
		return false
	fired[effect_id] = true
	world["effects_fired"] = fired
	return true


func effect_has_fired(effect_id: String) -> bool:
	var fired: Dictionary = world.get("effects_fired", {}) if world.get("effects_fired", {}) is Dictionary else {}
	return bool(fired.get(effect_id, false))


func encounter_resolution(encounter_id: String) -> String:
	var encounters: Dictionary = world.get("encounters", {}) if world.get("encounters", {}) is Dictionary else {}
	var record: Variant = encounters.get(encounter_id, {})
	if record is Dictionary:
		return String(record.get("resolution", ""))
	return ""


func record_encounter_resolution(encounter_id: String, resolution: String) -> void:
	var encounters: Dictionary = world.get("encounters", {}) if world.get("encounters", {}) is Dictionary else {}
	var record: Dictionary = encounters.get(encounter_id, {}) if encounters.get(encounter_id, {}) is Dictionary else {}
	record["resolution"] = resolution
	record["clear_count"] = int(record.get("clear_count", 0)) + (1 if resolution == "victory" else 0)
	encounters[encounter_id] = record
	world["encounters"] = encounters


func visit_region(next_region_id: String) -> int:
	var regions: Dictionary = world.get("regions", {}) if world.get("regions", {}) is Dictionary else {}
	var record: Dictionary = regions.get(next_region_id, {}) if regions.get(next_region_id, {}) is Dictionary else {}
	record["visit_count"] = int(record.get("visit_count", 0)) + 1
	regions[next_region_id] = record
	world["regions"] = regions
	ensure_clocks(next_region_id)
	return int(record["visit_count"])


func grant_equipment(equipment_id: String, count: int) -> bool:
	if equipment_id.is_empty() or count <= 0:
		return false
	var owned: Dictionary = progression.get("equipment", {}) if progression.get("equipment", {}) is Dictionary else {}
	owned[equipment_id] = int(owned.get(equipment_id, 0)) + count
	progression["equipment"] = owned
	return true


func equip(equipment_id: String, slot: String) -> bool:
	if not EQUIPMENT_SLOTS.has(slot) or int(progression["equipment"].get(equipment_id, 0)) <= 0:
		return false
	var slots: Dictionary = progression.get("equipment_slots", {}) if progression.get("equipment_slots", {}) is Dictionary else {}
	slots[slot] = equipment_id
	progression["equipment_slots"] = slots
	return true


func equipped_id(slot: String) -> String:
	var slots: Dictionary = progression.get("equipment_slots", {}) if progression.get("equipment_slots", {}) is Dictionary else {}
	return String(slots.get(slot, ""))


func grant_item(item_id: String, count: int) -> bool:
	if item_id.is_empty() or count <= 0:
		return false
	var items: Dictionary = progression.get("items", {}) if progression.get("items", {}) is Dictionary else {}
	items[item_id] = int(items.get(item_id, 0)) + count
	progression["items"] = items
	return true


func consume_item(item_id: String, count: int) -> bool:
	if count <= 0:
		return false
	var items: Dictionary = progression.get("items", {}) if progression.get("items", {}) is Dictionary else {}
	if int(items.get(item_id, 0)) < count:
		return false
	items[item_id] = int(items[item_id]) - count
	progression["items"] = items
	return true


func item_count(item_id: String) -> int:
	var items: Dictionary = progression.get("items", {}) if progression.get("items", {}) is Dictionary else {}
	return int(items.get(item_id, 0))


func mark_document_read(document_id: String) -> int:
	var documents: Dictionary = progression.get("documents", {}) if progression.get("documents", {}) is Dictionary else {}
	documents[document_id] = int(documents.get(document_id, 0)) + 1
	progression["documents"] = documents
	return int(documents[document_id])


func document_read_count(document_id: String) -> int:
	var documents: Dictionary = progression.get("documents", {}) if progression.get("documents", {}) is Dictionary else {}
	return int(documents.get(document_id, 0))


func mark_conversation_state(conversation_id: String, state: Dictionary) -> void:
	var conversations: Dictionary = progression.get("conversations", {}) if progression.get("conversations", {}) is Dictionary else {}
	conversations[conversation_id] = state
	progression["conversations"] = conversations


func conversation_state(conversation_id: String) -> Dictionary:
	var conversations: Dictionary = progression.get("conversations", {}) if progression.get("conversations", {}) is Dictionary else {}
	var record: Variant = conversations.get(conversation_id, {})
	return record if record is Dictionary else {}


func choice_taken(conversation_id: String, choice_id: String) -> bool:
	return _string_array(conversation_state(conversation_id).get("taken_choice_ids", [])).has(choice_id)


func unlock_action(action_id: String) -> void:
	var unlocked: Array = _string_array(progression.get("unlocked_action_ids", []))
	if not unlocked.has(action_id):
		unlocked.append(action_id)
		progression["unlocked_action_ids"] = unlocked


func is_action_unlocked(action_id: String) -> bool:
	return _string_array(progression.get("unlocked_action_ids", [])).has(action_id)


func append_commit_log(entry: Dictionary) -> void:
	if not entry.is_empty():
		commit_log.append(_sanitize_dictionary(entry))
		while commit_log.size() > COMMIT_LOG_CAP:
			commit_log.remove_at(0)


func queue_delayed_write(event_id: String, clock_id: String, region: String, target_stage: int) -> bool:
	if event_id.is_empty() or not is_valid_clock(clock_id):
		return false
	var writes: Array = transaction.get("delayed_writes", []) if transaction.get("delayed_writes", []) is Array else []
	writes.append({
		"event_id": event_id,
		"clock_id": clock_id,
		"region_id": region,
		"target_stage": clampi(target_stage, 0, TERMINAL_STAGE),
	})
	transaction["delayed_writes"] = writes
	return true


func next_resolution_serial() -> int:
	resolution_serial += 1
	transaction["resolution_serial"] = resolution_serial
	return resolution_serial


func seed_rng(seed_value: int) -> void:
	rng_state = seed_value if seed_value != 0 else 0x9E3779B9
	transaction["rng_state"] = rng_state


static func stable_seed(encounter_id: String, attempt_serial: int) -> int:
	var hash_value: int = 2166136261
	for index: int in range(encounter_id.length()):
		hash_value = ((hash_value ^ encounter_id.unicode_at(index)) * 16777619) & 0xFFFFFFFF
	hash_value = (hash_value ^ (attempt_serial * 2654435761)) & 0xFFFFFFFF
	return hash_value if hash_value != 0 else 0x9E3779B9


func _normalize() -> void:
	if not world.get("axes", {}) is Dictionary:
		world["axes"] = {}
	for axis: String in AXES:
		var record: Variant = world["axes"].get(axis, {})
		if not record is Dictionary:
			record = {"value": 0, "last_write_event_id": ""}
		if not _is_integer(record.get("value")) or not is_valid_axis_value(int(record["value"])):
			record["value"] = 0
		if not record.get("last_write_event_id", "") is String:
			record["last_write_event_id"] = ""
		record["disputed_claims"] = _sanitize_dictionary_list(record.get("disputed_claims", []))
		world["axes"][axis] = record
	if not world.get("clocks", {}) is Dictionary:
		world["clocks"] = {}
	if not world.get("magic", {}) is Dictionary:
		world["magic"] = {}
	for child: String in MAGIC_CHILDREN:
		if not world["magic"].get(child, {}) is Dictionary:
			world["magic"][child] = {}
	for key: String in WORLD_KEYS:
		if key in ["crown", "axes", "clocks", "magic"]:
			continue
		if not world.get(key, {}) is Dictionary:
			world[key] = {}
	world["clocks"] = _canonical_clocks_section()
	if not world.get("crown", {}) is Dictionary:
		world["crown"] = {"precedence": "", "operator_id": "", "object_phase": 0, "alignment_event_id": ""}
	if not player.get("body", {}) is Dictionary:
		player["body"] = {}
	for layer: String in SELF_LAYERS:
		if not player.get(layer, {}) is Dictionary:
			player[layer] = {}
	for key: String in ["resources", "equipment", "equipment_slots", "items", "conversations", "documents", "unlocked_action_ids"]:
		var container: Dictionary = progression if not ["resources"].has(key) else world
		if not container.get(key, {}) is Dictionary and not (key == "unlocked_action_ids" and container.get(key, []) is Array):
			container[key] = {} if key != "unlocked_action_ids" else []
	if not transaction.get("delayed_writes", []) is Array:
		transaction["delayed_writes"] = []


static func _is_world_shape(value: Dictionary) -> bool:
	for key: Variant in value.keys():
		if key is not String:
			return false
		if not WORLD_KEYS.has(key):
			return false
	return true


static func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))


static func _default_clock() -> Dictionary:
	return {"stage_index": 0, "tick": 0, "last_signal": "", "committed_event_id": ""}


static func _canonical_clock_record(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var record: Dictionary = _default_clock()
	if _is_integer(source.get("stage_index")):
		record["stage_index"] = clampi(int(source["stage_index"]), 0, TERMINAL_STAGE)
	if _is_integer(source.get("tick")):
		record["tick"] = clampi(int(source["tick"]), 0, MAX_TICK)
	var signal_value: Variant = source.get("last_signal", "")
	if signal_value is String:
		record["last_signal"] = String(signal_value)
	var event_value: Variant = source.get("committed_event_id", "")
	if event_value is String:
		record["committed_event_id"] = String(event_value)
	return record


static func _canonical_clock_entry(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var entry: Dictionary = {}
	for clock_id: String in CLOCK_IDS:
		entry[clock_id] = _canonical_clock_record(source.get(clock_id, {}))
	return entry


func _canonical_clocks_section() -> Dictionary:
	var source: Dictionary = world.get("clocks", {}) if world.get("clocks", {}) is Dictionary else {}
	var regions: Dictionary = world.get("regions", {}) if world.get("regions", {}) is Dictionary else {}
	var order: Array[String] = []
	for region: Variant in source.keys():
		if not order.has(String(region)):
			order.append(String(region))
	for region: Variant in regions.keys():
		if not order.has(String(region)):
			order.append(String(region))
	var clocks: Dictionary = {}
	for region_id: String in order:
		clocks[region_id] = _canonical_clock_entry(source.get(region_id, {}))
	return clocks


static func _default_field(entry_region_id: String, entry_anchor_id: String) -> Dictionary:
	return {
		"region_id": entry_region_id,
		"scene_id": entry_region_id,
		"anchor_id": entry_anchor_id,
		"actor": {"x": 0.0, "y": 0.0, "facing": 0},
		"active_interaction_id": "",
	}


static func _default_combat() -> Dictionary:
	return {
		"active_encounter_id": "",
		"resume_boundary": "field",
		"pre_command_intent": [],
		"attempt_serial": 0,
		"result": "",
	}


static func _default_player() -> Dictionary:
	var created: Dictionary = {
		"continuity_head_id": PLAYER_ROLE_ID,
		"body": {
			"vitals": {"hp": 0, "max_hp": 0, "mp": 0, "max_mp": 0},
			"injury": {},
			"mana_profile": "",
		},
	}
	for layer: String in SELF_LAYERS:
		if not created.has(layer):
			created[layer] = {}
	return created


static func _default_world(entry_region_id: String) -> Dictionary:
	var created: Dictionary = {
		"crown": {"precedence": "", "operator_id": "", "object_phase": 0, "alignment_event_id": ""},
		"regions": {entry_region_id: {"visit_count": 0, "state": "as_authored", "state_tag": "", "scene_id": entry_region_id}},
		"routes": {},
		"props": {},
		"npcs": {},
		"relationships": {},
		"encounters": {},
		"records": {},
		"resources": {},
		"flags": {},
		"effects_fired": {},
	}
	var axes: Dictionary = {}
	for axis: String in AXES:
		axes[axis] = {"value": 0, "last_write_event_id": "", "disputed_claims": []}
	created["axes"] = axes
	var magic: Dictionary = {}
	for child: String in MAGIC_CHILDREN:
		magic[child] = {}
	created["magic"] = magic
	var clocks: Dictionary = {entry_region_id: _canonical_clock_entry({})}
	created["clocks"] = clocks
	return created


static func _default_recovery() -> Dictionary:
	return {
		"active_checkpoint_id": "",
		"checkpoint_state": {},
		"continuity": {"head_id": PLAYER_ROLE_ID, "continuity_pressure": PLAYER_CONTINUITY, "recovery_count": 0},
		"pending_outcome_id": "",
		"pending_content_error": "",
		"history": [],
	}


static func _default_progression() -> Dictionary:
	return {
		"equipment": {},
		"equipment_slots": {},
		"items": {},
		"conversations": {},
		"documents": {},
		"unlocked_action_ids": [],
	}


static func _default_transaction() -> Dictionary:
	return {
		"last_committed_event_id": "",
		"last_commit_sequence": 0,
		"delayed_writes": [],
		"resolution_serial": 0,
		"rng_state": 0x9E3779B9,
	}


static func _string_array(value: Variant) -> Array:
	var result: Array = []
	if value is Array:
		for item: Variant in value:
			if item is String:
				result.append(String(item))
	return result


static func _append_unique(values: Array, entry: String) -> Array:
	if not values.has(entry):
		values.append(entry)
	return values


static func _sanitize_dictionary(value: Variant, depth: int = 0) -> Dictionary:
	var result: Dictionary = {}
	if depth > MAX_JSON_DEPTH or not value is Dictionary:
		return result
	for key: Variant in value:
		if not key is String:
			continue
		result[key] = _sanitize_json(value[key], depth + 1)
	return result


static func _sanitize_dictionary_list(value: Variant, depth: int = 0) -> Array:
	var result: Array = []
	if depth > MAX_JSON_DEPTH or not value is Array:
		return result
	for element: Variant in value:
		result.append(_sanitize_json(element, depth + 1))
	return result


static func _sanitize_json(value: Variant, depth: int = 0) -> Variant:
	if depth > MAX_JSON_DEPTH:
		return null
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return value
		TYPE_FLOAT:
			return value if is_finite(value) else null
		TYPE_ARRAY:
			var result: Array = []
			for element: Variant in value:
				result.append(_sanitize_json(element, depth + 1))
			return result
		TYPE_DICTIONARY:
			return _sanitize_dictionary(value, depth)
		_:
			return null
