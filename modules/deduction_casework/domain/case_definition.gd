class_name DeductionCaseworkCaseDefinition
extends RefCounted

const SCHEMA_VERSION: int = 1

var id: StringName = &""
var title: String = ""
var start_scene_id: StringName = &""
var scenes: Array[SceneDefinition] = []
var closeups: Array[CloseupDefinition] = []
var entities: Array[EntityDefinition] = []
var messages: Array[MessageDefinition] = []
var panels: Array[PanelDefinition] = []
var solutions: Array[SolutionDefinition] = []
var hints: Array[HintDefinition] = []
var review: ReviewDefinition = null
var next_case_ids: Array[StringName] = []


func is_valid() -> bool:
	return DeductionContentValidator.is_stable_id(String(id)) and not title.strip_edges().is_empty() \
		and DeductionContentValidator.is_stable_id(String(start_scene_id))


func has_scene(target_id: StringName) -> bool:
	return get_scene(target_id) != null


func get_scene(target_id: StringName) -> SceneDefinition:
	for scene: SceneDefinition in scenes:
		if scene.id == target_id:
			return scene
	return null


func has_closeup(target_id: StringName) -> bool:
	return get_closeup(target_id) != null


func get_closeup(target_id: StringName) -> CloseupDefinition:
	for closeup: CloseupDefinition in closeups:
		if closeup.id == target_id:
			return closeup
	return null


func has_entity(target_id: StringName) -> bool:
	return get_entity(target_id) != null


func get_entity(target_id: StringName) -> EntityDefinition:
	for entity: EntityDefinition in entities:
		if entity.id == target_id:
			return entity
	return null


func has_message(target_id: StringName) -> bool:
	return get_message(target_id) != null


func get_message(target_id: StringName) -> MessageDefinition:
	for message: MessageDefinition in messages:
		if message.id == target_id:
			return message
	return null


func has_panel(target_id: StringName) -> bool:
	return get_panel(target_id) != null


func get_panel(target_id: StringName) -> PanelDefinition:
	for panel: PanelDefinition in panels:
		if panel.id == target_id:
			return panel
	return null


func has_hint(target_id: StringName) -> bool:
	return get_hint(target_id) != null


func get_hint(target_id: StringName) -> HintDefinition:
	for hint: HintDefinition in hints:
		if hint.id == target_id:
			return hint
	return null


func to_dict() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"id": String(id),
		"title": title,
		"start_scene_id": String(start_scene_id),
		"scenes": DeductionContentValidator.list_to_dict(scenes),
		"closeups": DeductionContentValidator.list_to_dict(closeups),
		"entities": DeductionContentValidator.list_to_dict(entities),
		"messages": DeductionContentValidator.list_to_dict(messages),
		"panels": DeductionContentValidator.list_to_dict(panels),
		"solutions": DeductionContentValidator.list_to_dict(solutions),
		"hints": DeductionContentValidator.list_to_dict(hints),
		"review": review.to_dict() if review != null else null,
		"next_case_ids": DeductionContentValidator.strings_to_dict(next_case_ids)
	}


static func from_dict(data: Variant) -> DeductionCaseworkCaseDefinition:
	if not data is Dictionary or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.CASE_KEYS) \
		or not DeductionContentValidator.is_json_safe(data):
		return null
	if not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
		or not DeductionContentValidator.is_stable_id(data.get("id")) \
		or not DeductionContentValidator.is_stable_id(data.get("start_scene_id")) \
		or not DeductionContentValidator.is_optional_string(data, "title"):
		return null
	var definition := DeductionCaseworkCaseDefinition.new()
	definition.id = StringName(data["id"])
	definition.title = String(data.get("title", ""))
	definition.start_scene_id = StringName(data["start_scene_id"])
	definition.scenes = SceneDefinition.read_list(data.get("scenes", []))
	definition.closeups = CloseupDefinition.read_list(data.get("closeups", []))
	definition.entities = EntityDefinition.read_list(data.get("entities", []))
	definition.messages = MessageDefinition.read_list(data.get("messages", []))
	definition.panels = PanelDefinition.read_list(data.get("panels", []))
	definition.solutions = SolutionDefinition.read_list(data.get("solutions", []))
	definition.hints = HintDefinition.read_list(data.get("hints", []))
	if not DeductionContentValidator.list_is_complete(definition.scenes) \
		or not DeductionContentValidator.list_is_complete(definition.closeups) \
		or not DeductionContentValidator.list_is_complete(definition.entities) \
		or not DeductionContentValidator.list_is_complete(definition.messages) \
		or not DeductionContentValidator.list_is_complete(definition.panels) \
		or not DeductionContentValidator.list_is_complete(definition.solutions) \
		or not DeductionContentValidator.list_is_complete(definition.hints):
		return null
	if data.has("review") and data["review"] != null:
		definition.review = ReviewDefinition.from_dict(data["review"])
		if definition.review == null:
			return null
	definition.next_case_ids = DeductionContentValidator.read_optional_ids(data.get("next_case_ids", []))
	return definition if definition.is_valid() else null


class SceneDefinition:
	extends RefCounted

	var id: StringName = &""
	var scene_path: String = ""
	var start_focus_id: StringName = &""
	var hotspots: Array[HotspotDefinition] = []
	var transitions: Array[TransitionDefinition] = []


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"scene_path": scene_path,
			"start_focus_id": String(start_focus_id),
			"hotspots": DeductionContentValidator.list_to_dict(hotspots),
			"transitions": DeductionContentValidator.list_to_dict(transitions)
		}


	static func read_list(data: Variant) -> Array[SceneDefinition]:
		var result: Array[SceneDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(SceneDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> SceneDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.SCENE_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("start_focus_id")) \
			or not DeductionContentValidator.is_resource_path(data.get("scene_path"), ".tscn"):
			return null
		var scene := SceneDefinition.new()
		scene.id = StringName(data["id"])
		scene.scene_path = String(data["scene_path"])
		scene.start_focus_id = StringName(data["start_focus_id"])
		scene.hotspots = HotspotDefinition.read_list(data.get("hotspots", []))
		scene.transitions = TransitionDefinition.read_list(data.get("transitions", []))
		if not DeductionContentValidator.list_is_complete(scene.hotspots) \
			or not DeductionContentValidator.list_is_complete(scene.transitions):
			return null
		return scene


class HotspotDefinition:
	extends RefCounted

	var id: StringName = &""
	var focus_id: StringName = &""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"focus_id": String(focus_id)
		}


	static func read_list(data: Variant) -> Array[HotspotDefinition]:
		var result: Array[HotspotDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(HotspotDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> HotspotDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.HOTSPOT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")):
			return null
		var hotspot := HotspotDefinition.new()
		hotspot.id = StringName(data["id"])
		hotspot.focus_id = DeductionContentValidator.read_id(data.get("focus_id", ""))
		return hotspot


class TransitionDefinition:
	extends RefCounted

	var id: StringName = &""
	var destination_scene_id: StringName = &""
	var focus_id: StringName = &""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"destination_scene_id": String(destination_scene_id),
			"focus_id": String(focus_id)
		}


	static func read_list(data: Variant) -> Array[TransitionDefinition]:
		var result: Array[TransitionDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(TransitionDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> TransitionDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.TRANSITION_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")):
			return null
		var transition := TransitionDefinition.new()
		transition.id = StringName(data["id"])
		transition.destination_scene_id = DeductionContentValidator.read_id(data.get("destination_scene_id", ""))
		transition.focus_id = DeductionContentValidator.read_id(data.get("focus_id", ""))
		return transition


class CloseupDefinition:
	extends RefCounted

	var id: StringName = &""
	var scene_path: String = ""
	var parent_scene_id: StringName = &""
	var return_focus_id: StringName = &""
	var hotspots: Array[HotspotDefinition] = []


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"scene_path": scene_path,
			"parent_scene_id": String(parent_scene_id),
			"return_focus_id": String(return_focus_id),
			"hotspots": DeductionContentValidator.list_to_dict(hotspots)
		}


	static func read_list(data: Variant) -> Array[CloseupDefinition]:
		var result: Array[CloseupDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(CloseupDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> CloseupDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.CLOSEUP_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("parent_scene_id")) \
			or not DeductionContentValidator.is_stable_id(data.get("return_focus_id")) \
			or not DeductionContentValidator.is_resource_path(data.get("scene_path"), ".tscn"):
			return null
		var closeup := CloseupDefinition.new()
		closeup.id = StringName(data["id"])
		closeup.scene_path = String(data["scene_path"])
		closeup.parent_scene_id = StringName(data["parent_scene_id"])
		closeup.return_focus_id = StringName(data["return_focus_id"])
		closeup.hotspots = HotspotDefinition.read_list(data.get("hotspots", []))
		if not DeductionContentValidator.list_is_complete(closeup.hotspots):
			return null
		return closeup


class EntityDefinition:
	extends RefCounted

	var id: StringName = &""
	var kind: StringName = &""
	var display_text: String = ""
	var source_text_id: StringName = &""
	var tags: Array[StringName] = []


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"kind": String(kind),
			"display_text": display_text,
			"source_text_id": String(source_text_id),
			"tags": DeductionContentValidator.strings_to_dict(tags)
		}


	static func read_list(data: Variant) -> Array[EntityDefinition]:
		var result: Array[EntityDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(EntityDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> EntityDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.ENTITY_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("kind")) \
			or not DeductionContentValidator.is_optional_string(data, "display_text"):
			return null
		var entity := EntityDefinition.new()
		entity.id = StringName(data["id"])
		entity.kind = StringName(data["kind"])
		entity.display_text = String(data.get("display_text", ""))
		entity.source_text_id = DeductionContentValidator.read_id(data.get("source_text_id", ""))
		entity.tags = DeductionContentValidator.read_optional_ids(data.get("tags", []))
		return entity


class EffectDefinition:
	extends RefCounted

	var type: StringName = &""
	var params: Dictionary = {}


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"type": String(type),
			"params": params.duplicate(true)
		}


	static func read_list(data: Variant) -> Array[EffectDefinition]:
		var result: Array[EffectDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(EffectDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> EffectDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.EFFECT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("type")) \
			or not data.get("params", {}) is Dictionary:
			return null
		var effect := EffectDefinition.new()
		effect.type = StringName(data["type"])
		effect.params = DeductionContentValidator.json_copy(data.get("params", {}))
		return effect


class MessageDefinition:
	extends RefCounted

	var id: StringName = &""
	var title: String = ""
	var body: String = ""
	var source_refs: Array[StringName] = []
	var prerequisite_condition: ConditionDefinition = null
	var effects: Array[EffectDefinition] = []
	var detail_scene_id: StringName = &""


	func to_dict() -> Dictionary:
		var data: Dictionary = {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"source_refs": DeductionContentValidator.strings_to_dict(source_refs),
			"prerequisite_condition": prerequisite_condition.to_dict() if prerequisite_condition != null else null,
			"effects": DeductionContentValidator.list_to_dict(effects),
			"detail_scene_id": String(detail_scene_id)
		}
		if not title.is_empty():
			data["title"] = title
		if not body.is_empty():
			data["body"] = body
		return data


	static func read_list(data: Variant) -> Array[MessageDefinition]:
		var result: Array[MessageDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(MessageDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> MessageDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.MESSAGE_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_optional_string(data, "title") \
			or not DeductionContentValidator.is_optional_string(data, "body"):
			return null
		var message := MessageDefinition.new()
		message.id = StringName(data["id"])
		message.title = DeductionContentValidator.read_string(data.get("title", ""))
		message.body = DeductionContentValidator.read_string(data.get("body", ""))
		message.source_refs = DeductionContentValidator.to_string_names(data.get("source_refs", []))
		message.effects = EffectDefinition.read_list(data.get("effects", []))
		if not DeductionContentValidator.list_is_complete(message.effects):
			return null
		if data.has("prerequisite_condition") and data["prerequisite_condition"] != null:
			message.prerequisite_condition = ConditionDefinition.from_dict(data["prerequisite_condition"])
			if message.prerequisite_condition == null:
				return null
		message.detail_scene_id = DeductionContentValidator.read_id(data.get("detail_scene_id", ""))
		return message


class SegmentDefinition:
	extends RefCounted

	var id: StringName = &""
	var display_text: String = ""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"display_text": display_text
		}


	static func read_list(data: Variant) -> Array[SegmentDefinition]:
		var result: Array[SegmentDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(SegmentDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> SegmentDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.SEGMENT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_optional_string(data, "display_text"):
			return null
		var segment := SegmentDefinition.new()
		segment.id = StringName(data["id"])
		segment.display_text = String(data.get("display_text", ""))
		return segment


class PanelSlotDefinition:
	extends RefCounted

	var id: StringName = &""
	var segment_id: StringName = &""
	var accepted_kinds: Array[StringName] = []
	var accepted_entity_ids: Array[StringName] = []
	var persistent: bool = false
	var move_policy: StringName = &"move"


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"segment_id": String(segment_id),
			"accepted_kinds": DeductionContentValidator.strings_to_dict(accepted_kinds),
			"accepted_entity_ids": DeductionContentValidator.strings_to_dict(accepted_entity_ids),
			"persistent": persistent,
			"move_policy": String(move_policy)
		}


	static func read_list(data: Variant) -> Array[PanelSlotDefinition]:
		var result: Array[PanelSlotDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(PanelSlotDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> PanelSlotDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.PANEL_SLOT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("segment_id")) \
			or not data.get("persistent", false) is bool \
			or not DeductionContentValidator.MOVE_POLICIES.has(DeductionContentValidator.read_string(data.get("move_policy", "move"))):
			return null
		var slot := PanelSlotDefinition.new()
		slot.id = StringName(data["id"])
		slot.segment_id = StringName(data["segment_id"])
		slot.accepted_kinds = DeductionContentValidator.read_optional_ids(data.get("accepted_kinds", []))
		slot.accepted_entity_ids = DeductionContentValidator.read_optional_ids(data.get("accepted_entity_ids", []))
		slot.persistent = data.get("persistent", false)
		slot.move_policy = StringName(DeductionContentValidator.read_string(data.get("move_policy", "move")))
		return slot


class PanelDefinition:
	extends RefCounted

	var id: StringName = &""
	var kind: StringName = &""
	var title: String = ""
	var accepted_entity_kinds: Array[StringName] = []
	var slots: Array[PanelSlotDefinition] = []
	var segments: Array[SegmentDefinition] = []
	var almost_threshold: int = 0
	var required_for_completion: bool = true
	var unlock_condition: ConditionDefinition = null


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"kind": String(kind),
			"title": title,
			"accepted_entity_kinds": DeductionContentValidator.strings_to_dict(accepted_entity_kinds),
			"slots": DeductionContentValidator.list_to_dict(slots),
			"segments": DeductionContentValidator.list_to_dict(segments),
			"almost_threshold": almost_threshold,
			"required_for_completion": required_for_completion,
			"unlock_condition": unlock_condition.to_dict() if unlock_condition != null else null
		}


	static func read_list(data: Variant) -> Array[PanelDefinition]:
		var result: Array[PanelDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(PanelDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> PanelDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.PANEL_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("kind")) \
			or not DeductionContentValidator.is_optional_string(data, "title") \
			or not DeductionContentValidator.is_integer(data.get("almost_threshold", 0)) \
			or int(data.get("almost_threshold", 0)) < 0 \
			or not data.get("required_for_completion", true) is bool:
			return null
		var panel := PanelDefinition.new()
		panel.id = StringName(data["id"])
		panel.kind = StringName(data["kind"])
		panel.title = String(data.get("title", ""))
		panel.accepted_entity_kinds = DeductionContentValidator.read_optional_ids(data.get("accepted_entity_kinds", []))
		panel.slots = PanelSlotDefinition.read_list(data.get("slots", []))
		panel.segments = SegmentDefinition.read_list(data.get("segments", []))
		if not DeductionContentValidator.list_is_complete(panel.slots) \
			or not DeductionContentValidator.list_is_complete(panel.segments):
			return null
		panel.almost_threshold = int(data.get("almost_threshold", 0))
		panel.required_for_completion = data.get("required_for_completion", true)
		if data.has("unlock_condition") and data["unlock_condition"] != null:
			panel.unlock_condition = ConditionDefinition.from_dict(data["unlock_condition"])
			if panel.unlock_condition == null:
				return null
		return panel


class ConditionDefinition:
	extends RefCounted

	var all_of: Array[ConditionDefinition] = []
	var any_of: Array[ConditionDefinition] = []
	var negated: ConditionDefinition = null
	var requires_discovered_entity_id: StringName = &""
	var requires_resolved_message_id: StringName = &""
	var requires_solved_case_id: StringName = &""
	var requires_assignment_id: StringName = &""
	var requires_assignment_entity_id: StringName = &""


	func is_leaf() -> bool:
		return all_of.is_empty() and any_of.is_empty() and negated == null


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"all_of": DeductionContentValidator.list_to_dict(all_of),
			"any_of": DeductionContentValidator.list_to_dict(any_of),
			"not": negated.to_dict() if negated != null else null,
			"requires_discovered_entity_id": String(requires_discovered_entity_id),
			"requires_resolved_message_id": String(requires_resolved_message_id),
			"requires_solved_case_id": String(requires_solved_case_id),
			"requires_assignment_id": String(requires_assignment_id),
			"requires_assignment_entity_id": String(requires_assignment_entity_id)
		}


	static func read_list(data: Variant) -> Array[ConditionDefinition]:
		var result: Array[ConditionDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(ConditionDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> ConditionDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.CONDITION_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")):
			return null
		var condition := ConditionDefinition.new()
		condition.all_of = ConditionDefinition.read_list(data.get("all_of", []))
		condition.any_of = ConditionDefinition.read_list(data.get("any_of", []))
		if not DeductionContentValidator.list_is_complete(condition.all_of) \
			or not DeductionContentValidator.list_is_complete(condition.any_of):
			return null
		if data.has("not") and data["not"] != null:
			condition.negated = ConditionDefinition.from_dict(data["not"])
			if condition.negated == null:
				return null
		condition.requires_discovered_entity_id = DeductionContentValidator.read_id(data.get("requires_discovered_entity_id", ""))
		condition.requires_resolved_message_id = DeductionContentValidator.read_id(data.get("requires_resolved_message_id", ""))
		condition.requires_solved_case_id = DeductionContentValidator.read_id(data.get("requires_solved_case_id", ""))
		condition.requires_assignment_id = DeductionContentValidator.read_id(data.get("requires_assignment_id", ""))
		condition.requires_assignment_entity_id = DeductionContentValidator.read_id(data.get("requires_assignment_entity_id", ""))
		return condition


class AssignmentDefinition:
	extends RefCounted

	var slot_id: StringName = &""
	var entity_id: StringName = &""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"slot_id": String(slot_id),
			"entity_id": String(entity_id)
		}


	static func read_list(data: Variant) -> Array[AssignmentDefinition]:
		var result: Array[AssignmentDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(AssignmentDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> AssignmentDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.ASSIGNMENT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("slot_id")) \
			or not DeductionContentValidator.is_stable_id(data.get("entity_id")):
			return null
		var assignment := AssignmentDefinition.new()
		assignment.slot_id = StringName(data["slot_id"])
		assignment.entity_id = StringName(data["entity_id"])
		return assignment


class SolutionDefinition:
	extends RefCounted

	var id: StringName = &""
	var panel_id: StringName = &""
	var required_assignments: Array[AssignmentDefinition] = []
	var forbidden_assignments: Array[AssignmentDefinition] = []
	var all_of_conditions: Array[ConditionDefinition] = []
	var completion_review_id: StringName = &""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"panel_id": String(panel_id),
			"required_assignments": DeductionContentValidator.list_to_dict(required_assignments),
			"forbidden_assignments": DeductionContentValidator.list_to_dict(forbidden_assignments),
			"all_of_conditions": DeductionContentValidator.list_to_dict(all_of_conditions),
			"completion_review_id": String(completion_review_id)
		}


	static func read_list(data: Variant) -> Array[SolutionDefinition]:
		var result: Array[SolutionDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(SolutionDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> SolutionDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.SOLUTION_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_stable_id(data.get("panel_id")):
			return null
		var solution := SolutionDefinition.new()
		solution.id = StringName(data["id"])
		solution.panel_id = StringName(data["panel_id"])
		solution.required_assignments = AssignmentDefinition.read_list(data.get("required_assignments", []))
		solution.forbidden_assignments = AssignmentDefinition.read_list(data.get("forbidden_assignments", []))
		solution.all_of_conditions = ConditionDefinition.read_list(data.get("all_of_conditions", []))
		if not DeductionContentValidator.list_is_complete(solution.required_assignments) \
			or not DeductionContentValidator.list_is_complete(solution.forbidden_assignments) \
			or not DeductionContentValidator.list_is_complete(solution.all_of_conditions):
			return null
		solution.completion_review_id = DeductionContentValidator.read_id(data.get("completion_review_id", ""))
		return solution


class HintDefinition:
	extends RefCounted

	var id: StringName = &""
	var title: String = ""
	var body: String = ""
	var prerequisite_condition: ConditionDefinition = null
	var one_shot: bool = false


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"title": title,
			"body": body,
			"prerequisite_condition": prerequisite_condition.to_dict() if prerequisite_condition != null else null,
			"one_shot": one_shot
		}


	static func read_list(data: Variant) -> Array[HintDefinition]:
		var result: Array[HintDefinition] = []
		if not data is Array:
			return result
		for item: Variant in data:
			result.append(HintDefinition.from_dict(item))
		return result


	static func from_dict(data: Variant) -> HintDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.HINT_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_optional_string(data, "title") or not DeductionContentValidator.is_optional_string(data, "body") \
			or not data.get("one_shot", false) is bool:
			return null
		var hint := HintDefinition.new()
		hint.id = StringName(data["id"])
		hint.title = String(data.get("title", ""))
		hint.body = String(data.get("body", ""))
		hint.one_shot = data.get("one_shot", false)
		if data.has("prerequisite_condition") and data["prerequisite_condition"] != null:
			hint.prerequisite_condition = ConditionDefinition.from_dict(data["prerequisite_condition"])
			if hint.prerequisite_condition == null:
				return null
		return hint


class ReviewDefinition:
	extends RefCounted

	var id: StringName = &""
	var conclusion: String = ""
	var referenced_case_ids: Array[StringName] = []
	var scene_path: String = ""


	func to_dict() -> Dictionary:
		return {
			"schema_version": DeductionCaseworkCaseDefinition.SCHEMA_VERSION,
			"id": String(id),
			"conclusion": conclusion,
			"referenced_case_ids": DeductionContentValidator.strings_to_dict(referenced_case_ids),
			"scene_path": scene_path
		}


	static func from_dict(data: Variant) -> ReviewDefinition:
		if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, DeductionContentValidator.REVIEW_KEYS) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not DeductionContentValidator.is_stable_id(data.get("id")) \
			or not DeductionContentValidator.is_optional_string(data, "conclusion") or not DeductionContentValidator.is_optional_string(data, "scene_path"):
			return null
		var scene_path: String = String(data.get("scene_path", ""))
		if not scene_path.is_empty() and not DeductionContentValidator.is_resource_path(scene_path, ".tscn"):
			return null
		var review := ReviewDefinition.new()
		review.id = StringName(data["id"])
		review.conclusion = String(data.get("conclusion", ""))
		review.referenced_case_ids = DeductionContentValidator.read_optional_ids(data.get("referenced_case_ids", []))
		review.scene_path = scene_path
		return review
