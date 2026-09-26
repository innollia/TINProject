class_name TopDownActionRpgScreen
extends Control

signal intent_requested(kind: StringName, payload: Dictionary)

const STATE_INPUT_BUBBLE: StringName = &"input_bubble"
const STATE_FIELD: StringName = &"field"
const STATE_DIALOGUE_CHOICE_FOCUS: StringName = &"dialogue_choice_focus"
const STATE_NARRATION: StringName = &"narration"
const STATE_COMBAT_COMMAND: StringName = &"combat_command"
const STATE_TARGET_SELECT: StringName = &"target_select"
const STATE_CHARGE_COUNTER: StringName = &"charge_counter"
const STATE_GUARD_DODGE_BREAK: StringName = &"guard_dodge_break_feedback"
const STATE_EQUIPMENT_NO_TURN: StringName = &"equipment_no_turn"
const STATE_DOCUMENT_MAX: StringName = &"document_max"
const STATE_DOCUMENT_CORRUPTED: StringName = &"document_corrupted"
const STATE_AFTERMATH_REVISIT: StringName = &"aftermath_revisit"
const STATE_FAILURE_DEATH: StringName = &"failure_death"
const STATE_RECOVERY: StringName = &"recovery"
const STATE_SUCCESS: StringName = &"success"
const STATE_ESC_MENU: StringName = &"esc_menu"

const INTENT_FIELD_MOVE: StringName = &"field_move"
const INTENT_FIELD_FOCUS: StringName = &"field_focus"
const INTENT_FIELD_INTERACT: StringName = &"field_interact"
const INTENT_DIALOGUE_ADVANCE: StringName = &"dialogue_advance"
const INTENT_DIALOGUE_FOCUS: StringName = &"dialogue_focus"
const INTENT_CHOICE_CONFIRM: StringName = &"choice_confirm"
const INTENT_DIALOGUE_CANCEL: StringName = &"dialogue_cancel"
const INTENT_DOCUMENT_ADVANCE: StringName = &"document_advance"
const INTENT_COMBAT_CATEGORY_FOCUS: StringName = &"combat_category_focus"
const INTENT_COMBAT_CATEGORY: StringName = &"combat_category"
const INTENT_COMBAT_ACTION_FOCUS: StringName = &"combat_action_focus"
const INTENT_COMBAT_ACTION: StringName = &"combat_action"
const INTENT_COMBAT_TARGET_FOCUS: StringName = &"combat_target_focus"
const INTENT_COMBAT_TARGET: StringName = &"combat_target"
const INTENT_COMBAT_CANCEL: StringName = &"combat_cancel"
const INTENT_COMBAT_END_TURN: StringName = &"combat_end_turn"
const INTENT_COMBAT_REACTION: StringName = &"combat_reaction"
const INTENT_COMBAT_RECEIVE: StringName = &"combat_receive"

const CATEGORY_SKILL_MAGIC: String = "skill"
const CATEGORY_ROW_TOKENS: Array[String] = ["attack", CATEGORY_SKILL_MAGIC, "defend", "item", "escape", "equipment"]
const CATEGORY_LABELS: Dictionary = {
	"attack": "Attack",
	"skill": "Skill/Magic",
	"defend": "Defend",
	"item": "Item",
	"escape": "Escape",
	"equipment": "Equipment",
}
const LABEL_END_TURN: String = "End Turn"
const LABEL_BACK: String = "Back"
const LABEL_ACTIONS_PREFIX: String = "행동 "

const MAX_CHOICE_ROWS: int = 6
const MAX_DOCUMENT_LINES: int = TopDownActionRpgGameState.DOCUMENT_PAGE_LINE_CAP
const DOCUMENT_TITLE_LINE_BUDGET: int = MAX_DOCUMENT_LINES - 1
const FIELD_MOVE_AXIS: StringName = &"field_move_axis"
const TARGET_MODE_LABELS: Dictionary = {
	"SELF": "self",
	"ONE_ENEMY": "one enemy",
	"ONE_ALLY": "one ally",
	"ALL_ENEMIES": "all enemies",
	"ALL_ALLIES": "all allies",
	"RANDOM_ENEMY": "random",
}
const COMBAT_ACTIVE_MODES: Array[String] = ["encounter_prepare", "encounter_transition", "combat", "encounter_result"]
const CORRUPTED_PRESENTATION: String = "corrupted"
const REDACTED_PRESENTATION: String = "redacted"
const ESCAPE_ALLOW_KEY: String = "escape"

const INK: Color = Color("d6d2c7")
const INK_MUTED: Color = Color("9aa1aa")
const SURFACE_LINE: Color = Color("2f3742")
const PANEL_FILL: Color = Color(0.043, 0.055, 0.071, 0.92)

@onready var _field_layer: TopDownActionRpgVectorLayer = get_node_or_null("%FieldLayer")
@onready var _combat_layer: TopDownActionRpgVectorLayer = get_node_or_null("%CombatLayer")

@onready var _dialogue_layer: Control = get_node_or_null("%DialogueLayer")
@onready var _portrait_row: TopDownActionRpgRow = get_node_or_null("%PortraitRow")
@onready var _speaker_label: Label = get_node_or_null("%SpeakerLabel")
@onready var _body_label: Label = get_node_or_null("%BodyLabel")
@onready var _dialogue_advance: TopDownActionRpgRow = get_node_or_null("%DialogueAdvance")
@onready var _text_column: VBoxContainer = get_node_or_null("%TextColumn")
@onready var _choice_panel: PanelContainer = get_node_or_null("%ChoicePanel")
@onready var _choice_rows: VBoxContainer = get_node_or_null("%ChoiceRows")

@onready var _document_layer: Control = get_node_or_null("%DocumentLayer")
@onready var _document_title: Label = get_node_or_null("%DocumentTitle")
@onready var _document_body: VBoxContainer = get_node_or_null("%DocumentBody")
@onready var _document_advance: TopDownActionRpgRow = get_node_or_null("%DocumentAdvance")

@onready var _narration_layer: Control = get_node_or_null("%NarrationLayer")
@onready var _narration_band: PanelContainer = get_node_or_null("%NarrationBand")
@onready var _narration_body: Label = get_node_or_null("%NarrationBody")

@onready var _combat_ui: Control = get_node_or_null("%CombatUi")
@onready var _command_rail: PanelContainer = get_node_or_null("%CommandRail")
@onready var _command_rows: VBoxContainer = get_node_or_null("%CommandRows")
@onready var _command_footer: Label = get_node_or_null("%CommandFooter")
@onready var _player_band: PanelContainer = get_node_or_null("%PlayerBand")
@onready var _player_name: Label = get_node_or_null("%PlayerName")
@onready var _player_hp: Label = get_node_or_null("%PlayerHp")
@onready var _player_mp: Label = get_node_or_null("%PlayerMp")
@onready var _player_status: VBoxContainer = get_node_or_null("%PlayerStatus")
@onready var _action_slots: Label = get_node_or_null("%ActionSlots")

var game_state: TopDownActionRpgGameState = null
var field_controller: TopDownActionRpgFieldController = null
var conversation_controller: TopDownActionRpgConversationController = null
var combat_controller: TopDownActionRpgCombatController = null
var combat_state: TopDownActionRpgCombatState = null
var recovery_controller: TopDownActionRpgRecoveryController = null
var catalog: TopDownActionRpgContentLoader.Catalog = null

var missing_art_keys: Array = []

var _shell_open: bool = false
var _input_bubble_active: bool = false
var _aftermath_active: bool = false
var _recovery_surface_active: bool = false
var _failure_active: bool = false
var _success_active: bool = false
var _narration_lines: PackedStringArray = PackedStringArray()
var _rail_focus: int = 0
var _rail_expanded: bool = false
var _rail_token: String = ""
var _timing_override: float = -1.0
var _condition_overrides: Dictionary = {}
var _actor_definitions: Dictionary = {}
var _action_row_override: Array = []
var _feedback_marks: Array = []
var _choice_rows_view: Array = []
var _command_rows_view: Array = []
var _document_rows_view: Array = []
var _status_rows_view: Array = []
var _bound: bool = false
var _state: StringName = &""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	_apply_surface_styles()
	_connect_rows()
	refresh()


func _apply_surface_styles() -> void:
	var panels: Array[PanelContainer] = [
		get_node_or_null("%DialogueBand") as PanelContainer,
		get_node_or_null("%DocumentSurface") as PanelContainer,
		_choice_panel,
		_narration_band,
		_command_rail,
		_player_band,
	]
	for panel: PanelContainer in panels:
		if panel == null:
			continue
		var style := StyleBoxFlat.new()
		style.bg_color = PANEL_FILL
		style.border_color = SURFACE_LINE
		style.set_border_width_all(1)
		style.set_corner_radius_all(0)
		style.content_margin_left = 0.0
		style.content_margin_right = 0.0
		style.content_margin_top = 0.0
		style.content_margin_bottom = 0.0
		panel.add_theme_stylebox_override("panel", style)


func _connect_rows() -> void:
	var containers: Array[VBoxContainer] = [_choice_rows, _command_rows, _document_body, _player_status]
	for container: VBoxContainer in containers:
		if container == null:
			continue
		for child: Node in container.get_children():
			if child is TopDownActionRpgRow:
				(child as TopDownActionRpgRow).row_activated.connect(_on_row_activated)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		refresh()


func bind_runtime(
	p_game_state: TopDownActionRpgGameState,
	p_field: TopDownActionRpgFieldController,
	p_conversation: TopDownActionRpgConversationController,
	p_combat: TopDownActionRpgCombatController,
	p_combat_state: TopDownActionRpgCombatState,
	p_recovery: TopDownActionRpgRecoveryController
) -> bool:
	game_state = p_game_state
	field_controller = p_field
	conversation_controller = p_conversation
	combat_controller = p_combat
	combat_state = p_combat_state
	recovery_controller = p_recovery
	catalog = p_field.catalog if p_field != null else null
	if catalog == null and p_conversation != null:
		catalog = p_conversation.catalog
	if catalog == null and p_combat != null:
		catalog = p_combat.catalog
	if catalog == null and p_recovery != null:
		catalog = p_recovery.catalog
	_bound = game_state != null and field_controller != null and conversation_controller != null
	refresh()
	return _bound


func unbind_runtime() -> void:
	game_state = null
	field_controller = null
	conversation_controller = null
	combat_controller = null
	combat_state = null
	recovery_controller = null
	catalog = null
	_bound = false
	refresh()


func set_shell_open(value: bool) -> void:
	if _shell_open == value:
		return
	_shell_open = value
	refresh()


func set_input_bubble_active(value: bool) -> void:
	if _input_bubble_active == value:
		return
	_input_bubble_active = value
	refresh()


func set_aftermath_active(value: bool) -> void:
	if _aftermath_active == value:
		return
	_aftermath_active = value
	refresh()


func set_recovery_surface(value: bool) -> void:
	if _recovery_surface_active == value:
		return
	_recovery_surface_active = value
	refresh()


func set_failure_active(value: bool) -> void:
	if _failure_active == value:
		return
	_failure_active = value
	refresh()


func set_success_active(value: bool) -> void:
	if _success_active == value:
		return
	_success_active = value
	refresh()


func set_narration_lines(lines: PackedStringArray) -> void:
	_narration_lines = lines
	refresh()


func set_timing_projection(value: float) -> void:
	_timing_override = clampf(value, 0.0, 1.0)
	refresh()


func clear_timing_projection() -> void:
	_timing_override = -1.0
	refresh()


func set_condition_projection(actor_id: StringName, ratio: float) -> void:
	_condition_overrides[String(actor_id)] = clampf(ratio, 0.0, 1.0)
	refresh()


func set_actor_definitions(definitions: Dictionary) -> void:
	_actor_definitions = definitions.duplicate()
	refresh()


func set_action_rows(rows: Array) -> void:
	_action_row_override = rows.duplicate(true)
	refresh()


func clear_action_rows() -> void:
	_action_row_override = []
	refresh()


func set_rail_focus(index: int) -> void:
	var value: int = maxi(index, 0)
	if _rail_focus == value:
		return
	_rail_focus = value
	refresh()


func push_feedback(kind: String, position: Vector2, strength: float = 1.0) -> void:
	_feedback_marks.append({"kind": kind, "position": position, "strength": clampf(strength, 0.0, 1.0)})
	refresh()


func clear_feedback() -> void:
	_feedback_marks = []
	refresh()


func current_state() -> StringName:
	return _state


func refresh() -> void:
	_state = _resolve_state()
	if not _bound or game_state == null:
		_hide_all()
		return
	_render_field()
	_render_dialogue()
	_render_document()
	_render_narration()
	_render_combat()
	_apply_layer_visibility()


func _hide_all() -> void:
	for layer: CanvasItem in [_field_layer, _combat_layer, _dialogue_layer, _document_layer, _narration_layer, _combat_ui]:
		if layer != null:
			layer.visible = false


func _apply_layer_visibility() -> void:
	var mode: String = String(game_state.mode)
	var combat_on: bool = COMBAT_ACTIVE_MODES.has(mode)
	var document_on: bool = conversation_controller != null and not conversation_controller.document_id.is_empty()
	var dialogue_on: bool = mode == "dialogue" and not document_on
	var narration_on: bool = not _narration_lines.is_empty()
	_set_visible(_field_layer, not combat_on)
	_set_visible(_combat_layer, combat_on)
	_set_visible(_combat_ui, combat_on)
	_set_visible(_dialogue_layer, dialogue_on)
	_set_visible(_document_layer, document_on)
	_set_visible(_narration_layer, narration_on and not combat_on and not dialogue_on and not document_on)


func _set_visible(target: CanvasItem, value: bool) -> void:
	if target != null:
		target.visible = value


func _resolve_state() -> StringName:
	if not _bound or game_state == null:
		return &""
	if _shell_open:
		return STATE_ESC_MENU
	if _input_bubble_active:
		return STATE_INPUT_BUBBLE
	var mode: String = String(game_state.mode)
	if mode == "field" and _recovery_pending():
		return STATE_FAILURE_DEATH
	match mode:
		"field":
			if _failure_active:
				return STATE_FAILURE_DEATH
			if _recovery_surface_active:
				return STATE_RECOVERY
			if _aftermath_active:
				return STATE_AFTERMATH_REVISIT
			if _success_active:
				return STATE_SUCCESS
			if not _narration_lines.is_empty():
				return STATE_NARRATION
			return STATE_FIELD
		"dialogue":
			if conversation_controller != null and not conversation_controller.document_id.is_empty():
				return STATE_DOCUMENT_CORRUPTED if _document_has_corruption() else STATE_DOCUMENT_MAX
			return STATE_DIALOGUE_CHOICE_FOCUS
		"service":
			return STATE_EQUIPMENT_NO_TURN
		"recovery":
			return STATE_FAILURE_DEATH
		"encounter_result":
			if String(combat_state.result) in ["victory", "escape"]:
				return STATE_SUCCESS
			return STATE_FAILURE_DEATH
		"field_return":
			return STATE_AFTERMATH_REVISIT
		"encounter_prepare", "encounter_transition":
			return STATE_COMBAT_COMMAND
		"combat":
			return _resolve_combat_state()
	return STATE_FIELD


func _recovery_pending() -> bool:
	return recovery_controller != null and not recovery_controller.pending_definition.is_empty()


func _resolve_combat_state() -> StringName:
	if combat_state == null:
		return STATE_COMBAT_COMMAND
	if String(combat_state.submode) == "target_select":
		return STATE_TARGET_SELECT
	for actor: TopDownActionRpgCombatState.ActorState in combat_state.actors:
		if actor.charge_state != null and actor.charge_state.is_active():
			return STATE_CHARGE_COUNTER
	for actor: TopDownActionRpgCombatState.ActorState in combat_state.actors:
		if actor.stance_state != "normal":
			return STATE_GUARD_DODGE_BREAK
	if String(combat_controller.current_category) in ["equipment", "item"]:
		return STATE_EQUIPMENT_NO_TURN
	for intent: TopDownActionRpgCombatState.QueuedIntent in combat_controller.commands:
		if intent.no_turn:
			return STATE_EQUIPMENT_NO_TURN
	return STATE_COMBAT_COMMAND


func _submit(kind: StringName, payload: Dictionary) -> void:
	intent_requested.emit(kind, payload)


func _stable_hash(text: String) -> int:
	var value: int = 2166136261
	for index: int in range(text.length()):
		value = (value ^ text.unicode_at(index)) & 0xFFFFFFFF
		value = (value * 16777619) & 0xFFFFFFFF
	return value


func _register_art_key(key: String) -> void:
	var trimmed: String = key.strip_edges()
	if trimmed.is_empty() or missing_art_keys.has(trimmed):
		return
	missing_art_keys.append(trimmed)
	missing_art_keys.sort()


func _grow_pool(parent: VBoxContainer, view: Array, role: String, minimum_height: float) -> void:
	if parent == null:
		return
	while view.size() < MAX_CHOICE_ROWS + 8:
		var row := TopDownActionRpgRow.new()
		row.name = "Row%d" % view.size()
		row.role = role
		row.custom_minimum_size = Vector2(0.0, minimum_height)
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.row_activated.connect(_on_row_activated)
		parent.add_child(row)
		view.append(row)


func _on_row_activated(row_id: StringName) -> void:
	submit_row(row_id)


func submit_row(row_id: StringName) -> void:
	match _state:
		STATE_FIELD, STATE_AFTERMATH_REVISIT, STATE_RECOVERY, STATE_INPUT_BUBBLE:
			_submit(INTENT_FIELD_INTERACT, {"interactable_id": String(row_id)})
		STATE_DIALOGUE_CHOICE_FOCUS:
			_submit(INTENT_CHOICE_CONFIRM, {"choice_id": String(row_id)})
		STATE_COMBAT_COMMAND, STATE_TARGET_SELECT, STATE_CHARGE_COUNTER, STATE_GUARD_DODGE_BREAK, STATE_EQUIPMENT_NO_TURN:
			_submit_command_row(row_id)


func _submit_command_row(row_id: StringName) -> void:
	var text: String = String(row_id)
	if text == LABEL_BACK:
		_submit(INTENT_COMBAT_CANCEL, {})
		return
	if text == LABEL_END_TURN:
		_submit(INTENT_COMBAT_END_TURN, {})
		return
	if _rail_expanded:
		_submit(INTENT_COMBAT_ACTION, {"action_id": text})


func submit_move(direction: Vector2) -> void:
	if _state in [STATE_FIELD, STATE_AFTERMATH_REVISIT, STATE_RECOVERY, STATE_INPUT_BUBBLE]:
		_submit(INTENT_FIELD_MOVE, {"direction": direction, "axis": FIELD_MOVE_AXIS})


func submit_focus(step: int) -> void:
	match _state:
		STATE_FIELD, STATE_AFTERMATH_REVISIT, STATE_RECOVERY, STATE_INPUT_BUBBLE:
			_submit(INTENT_FIELD_FOCUS, {"step": step})
		STATE_DIALOGUE_CHOICE_FOCUS:
			_submit(INTENT_DIALOGUE_FOCUS, {"step": step})
		STATE_COMBAT_COMMAND, STATE_EQUIPMENT_NO_TURN, STATE_CHARGE_COUNTER, STATE_GUARD_DODGE_BREAK:
			if _rail_expanded:
				_submit(INTENT_COMBAT_ACTION_FOCUS, {"step": step})
			else:
				_submit(INTENT_COMBAT_CATEGORY_FOCUS, {"step": step})
		STATE_TARGET_SELECT:
			_submit(INTENT_COMBAT_TARGET_FOCUS, {"step": step})


func submit_confirm() -> void:
	match _state:
		STATE_FIELD, STATE_AFTERMATH_REVISIT, STATE_RECOVERY, STATE_INPUT_BUBBLE:
			var focused: TopDownActionRpgFieldController.Interactable = field_controller.focused_interactable()
			_submit(INTENT_FIELD_INTERACT, {"interactable_id": String(focused.interactable_id) if focused != null else ""})
		STATE_DIALOGUE_CHOICE_FOCUS:
			if conversation_controller.at_choice_set():
				var row: Dictionary = conversation_controller.focused_choice()
				_submit(INTENT_CHOICE_CONFIRM, {"choice_id": String(row.get("choice_id", ""))})
			else:
				_submit(INTENT_DIALOGUE_ADVANCE, {"page_index": conversation_controller.page_index})
		STATE_DOCUMENT_MAX, STATE_DOCUMENT_CORRUPTED:
			_submit(INTENT_DOCUMENT_ADVANCE, {"page_index": conversation_controller.document_page_index})
		STATE_TARGET_SELECT:
			_submit(INTENT_COMBAT_TARGET, {"target_actor_id": String(combat_controller.target_focus_actor_id)})
		STATE_CHARGE_COUNTER:
			_submit(INTENT_COMBAT_REACTION, {"charge_stage": String(_charge_stage())})
		STATE_COMBAT_COMMAND, STATE_EQUIPMENT_NO_TURN, STATE_GUARD_DODGE_BREAK:
			_submit_focused_command()


func submit_cancel() -> void:
	match _state:
		STATE_DIALOGUE_CHOICE_FOCUS:
			_submit(INTENT_DIALOGUE_CANCEL, {"page_index": conversation_controller.page_index})
		STATE_DOCUMENT_MAX, STATE_DOCUMENT_CORRUPTED:
			_submit(INTENT_DIALOGUE_CANCEL, {"document_id": String(conversation_controller.document_id)})
		STATE_COMBAT_COMMAND, STATE_EQUIPMENT_NO_TURN, STATE_GUARD_DODGE_BREAK:
			if _rail_expanded:
				_rail_expanded = false
				_rail_focus = 0
				_submit(INTENT_COMBAT_CANCEL, {})
				refresh()
			else:
				_submit(INTENT_COMBAT_END_TURN, {})
		STATE_TARGET_SELECT:
			_submit(INTENT_COMBAT_CANCEL, {})
		STATE_CHARGE_COUNTER:
			_submit(INTENT_COMBAT_RECEIVE, {})


func _charge_stage() -> String:
	if combat_state == null:
		return ""
	for actor: TopDownActionRpgCombatState.ActorState in combat_state.actors:
		if actor.charge_state != null and actor.charge_state.is_active():
			return String(actor.charge_state.stage)
	return ""


func _submit_focused_command() -> void:
	if not _rail_expanded:
		var token: String = CATEGORY_ROW_TOKENS[clampi(_rail_focus, 0, CATEGORY_ROW_TOKENS.size() - 1)]
		_rail_expanded = true
		_rail_token = token
		_rail_focus = 0
		_submit(INTENT_COMBAT_CATEGORY, {"category": token})
		refresh()
		return
	if _command_rows_view.is_empty():
		return
	var row_id: StringName = _command_rows_view[clampi(_rail_focus, 0, _command_rows_view.size() - 1)].row_id
	if row_id == LABEL_BACK:
		_rail_expanded = false
		_rail_focus = 0
		_submit(INTENT_COMBAT_CANCEL, {})
		refresh()
	elif row_id != LABEL_END_TURN:
		_submit(INTENT_COMBAT_ACTION, {"action_id": String(row_id)})


func _render_field() -> void:
	if _field_layer == null or field_controller == null:
		return
	var actor: Dictionary = game_state.field_actor()
	var region: Dictionary = catalog.record(game_state.region_id()) if catalog != null else {}
	var topology: String = String(region.get("topology", {}).get("shape", "")) if region.get("topology", {}) is Dictionary else ""
	var focused: TopDownActionRpgFieldController.Interactable = field_controller.focused_interactable()
	var focused_id: String = String(focused.interactable_id) if focused != null else ""
	var markers: Array = []
	for entry: TopDownActionRpgFieldController.Interactable in field_controller.interactables:
		if not entry.focusable:
			continue
		var record: Dictionary = catalog.record(String(entry.interactable_id)) if catalog != null else {}
		_register_prop_art_key(record)
		markers.append({
			"position": entry.position,
			"kind": entry.kind,
			"focused": String(entry.interactable_id) == focused_id,
			"disabled": _field_disabled(entry, record),
			"variant": _field_variant(entry, record),
		})
	var model: Dictionary = {
		"markers": markers,
		"player_position": Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0))),
		"player_facing": int(actor.get("facing", 0)),
		"player_serial": game_state.resolution_serial,
		"topology": topology,
		"region_serial": _region_visit_serial(),
	}
	_field_layer.set_field_model(model)
	_field_layer.feedback = _feedback_marks
	_field_layer.set_dim_ratio(0.0)


func _region_visit_serial() -> int:
	var regions: Dictionary = game_state.world.get("regions", {}) if game_state.world.get("regions", {}) is Dictionary else {}
	var record: Dictionary = regions.get(game_state.region_id(), {}) if regions.get(game_state.region_id(), {}) is Dictionary else {}
	return int(record.get("visit_count", 0))


func _register_prop_art_key(record: Dictionary) -> void:
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	var current: String = _current_prop_state(record)
	for state: Variant in states:
		if state is Dictionary and String((state as Dictionary).get("state_id", "")) == current:
			_register_art_key(String((state as Dictionary).get("art_key", "")))


func _current_prop_state(record: Dictionary) -> String:
	if record.is_empty():
		return ""
	var recorded: String = game_state.prop_state(String(record.get("id", "")))
	return recorded if not recorded.is_empty() else String(record.get("initial_state_id", ""))


func _field_variant(entry: TopDownActionRpgFieldController.Interactable, record: Dictionary) -> String:
	if record.is_empty():
		return "normal"
	if entry.kind == "npc":
		var appearance: Dictionary = record.get("appearance", {}) if record.get("appearance", {}) is Dictionary else {}
		_register_art_key(String(appearance.get("body_key", "")))
		var presence: String = String(game_state.npc_state(String(entry.interactable_id)).get("presence", ""))
		if presence == "absent":
			return "absent"
		return "changed" if not presence.is_empty() else "normal"
	var current: String = _current_prop_state(record)
	var initial: String = String(record.get("initial_state_id", ""))
	if current.is_empty() or current == initial:
		return "normal"
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	for state: Variant in states:
		if not state is Dictionary:
			continue
		if String((state as Dictionary).get("state_id", "")) != current:
			continue
		if not bool((state as Dictionary).get("visible", true)):
			return "absent"
		return "changed"
	return "changed"


func _field_disabled(entry: TopDownActionRpgFieldController.Interactable, record: Dictionary) -> bool:
	if not entry.enabled:
		return true
	if entry.kind == "passage":
		return field_controller.route_state(String(entry.interactable_id)) != "open"
	if entry.kind == "npc":
		return String(game_state.npc_state(String(entry.interactable_id)).get("presence", "")) == "absent"
	if record.is_empty():
		return false
	var current: String = _current_prop_state(record)
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	for state: Variant in states:
		if state is Dictionary and String((state as Dictionary).get("state_id", "")) == current:
			return not bool((state as Dictionary).get("interactable", true))
	return false


func _render_dialogue() -> void:
	if _dialogue_layer == null or conversation_controller == null:
		return
	var page: Dictionary = conversation_controller.current_page()
	var has_choices: bool = conversation_controller.at_choice_set() and not conversation_controller.choice_rows().is_empty()
	_set_visible(_choice_panel, has_choices)
	if page.is_empty() and not has_choices:
		_speaker_label.text = ""
		_body_label.text = ""
		_set_visible(_portrait_row, false)
		_set_visible(_dialogue_advance, false)
		_grow_pool(_choice_rows, _choice_rows_view, TopDownActionRpgRow.ROLE_CHOICE, 48.0)
		return
	var presentation: String = conversation_controller.page_presentation_class()
	var speaker: Dictionary = _page_speaker(page)
	_speaker_label.text = String(speaker.get("display_name", ""))
	_body_label.text = conversation_controller.page_text()
	_body_label.add_theme_color_override("font_color", INK_MUTED if presentation == "narration" else INK)
	var appearance: Dictionary = speaker.get("appearance", {}) if speaker.get("appearance", {}) is Dictionary else {}
	var portrait_key: String = String(appearance.get("portrait_key", ""))
	_set_visible(_portrait_row, not portrait_key.is_empty())
	if not portrait_key.is_empty():
		_register_art_key(portrait_key)
		_portrait_row.set_tone_serial(_stable_hash(portrait_key))
	_set_visible(_dialogue_advance, not page.is_empty() and not has_choices)
	_text_column.custom_minimum_size.x = 820.0 if has_choices else 1080.0
	_render_choice_rows()


func _page_speaker(page: Dictionary) -> Dictionary:
	if String(page.get("speaker", "")) != "npc":
		return {}
	var record: Dictionary = conversation_controller.current_conversation()
	var npc_id: String = String(record.get("speaker_npc_id", ""))
	var npc: Dictionary = catalog.record(npc_id) if catalog != null and not npc_id.is_empty() else {}
	return npc


func _render_choice_rows() -> void:
	_grow_pool(_choice_rows, _choice_rows_view, TopDownActionRpgRow.ROLE_CHOICE, 48.0)
	var rows: Array = conversation_controller.choice_rows()
	var visible_rows: Array = []
	for row: Dictionary in rows:
		if bool(row.get("visible", false)):
			visible_rows.append(row)
	var focused: Dictionary = conversation_controller.focused_choice()
	var focused_id: String = String(focused.get("choice_id", ""))
	var last_committed: String = String(game_state.conversation_state(String(conversation_controller.conversation_id)).get("last_choice_id", ""))
	var used: int = 0
	for view: TopDownActionRpgRow in _choice_rows_view:
		if used >= mini(visible_rows.size(), MAX_CHOICE_ROWS):
			view.visible = false
			used += 1
			continue
		view.visible = true
		var row: Dictionary = visible_rows[used]
		var choice_id: String = String(row.get("choice_id", ""))
		view.row_id = StringName(choice_id)
		view.set_text(String(row.get("text", "")))
		view.set_presentation_class(String(row.get("presentation_class", "neutral")))
		view.set_disabled_state(not bool(row.get("available", true)))
		view.set_focus_state(choice_id == focused_id)
		view.set_selected_state(choice_id == last_committed)
		view.set_trailing(String(row.get("unavailable_reason", "")))
		used += 1


func _document_has_corruption() -> bool:
	if conversation_controller == null:
		return false
	var page: Dictionary = conversation_controller.document_page()
	if String(page.get("presentation", "plain")) != CORRUPTED_PRESENTATION:
		return false
	return not _page_corruption_rules(page).is_empty() or not conversation_controller.document_lines().is_empty()


func _page_corruption_rules(page: Dictionary) -> Array:
	var rules: Array = page.get("corruption_rules", []) if page.get("corruption_rules", []) is Array else []
	var active: Array = []
	for rule: Variant in rules:
		if not rule is Dictionary:
			continue
		var trigger: Variant = (rule as Dictionary).get("trigger", {})
		if game_state == null or catalog == null:
			continue
		if not TopDownActionRpgContentLoader.evaluate_condition(trigger, game_state, catalog):
			continue
		active.append(rule)
	return active


func _render_document() -> void:
	if _document_layer == null or conversation_controller == null:
		return
	var record: Dictionary = catalog.record(String(conversation_controller.document_id)) if catalog != null else {}
	var page: Dictionary = conversation_controller.document_page()
	var lines: Array = conversation_controller.document_lines()
	var title: String = String(record.get("display_name", ""))
	_document_title.text = title
	_document_title.visible = not title.is_empty()
	_register_art_key(String(record.get("surface_key", "")))
	var rules: Array = _page_corruption_rules(page)
	var page_mode: String = String(page.get("presentation", "plain"))
	var page_serial: int = _stable_hash(String(page.get("page_id", "")))
	var budget: int = DOCUMENT_TITLE_LINE_BUDGET if not title.is_empty() else MAX_DOCUMENT_LINES
	_grow_pool(_document_body, _document_rows_view, TopDownActionRpgRow.ROLE_DOCUMENT, 32.0)
	var used: int = 0
	for view: TopDownActionRpgRow in _document_rows_view:
		if used >= mini(lines.size(), budget):
			view.visible = false
			used += 1
			continue
		view.visible = true
		view.row_id = &""
		view.set_text(String(lines[used]))
		view.set_presentation_class("neutral")
		view.set_focus_state(false)
		view.set_disabled_state(false)
		view.set_trailing("")
		var mode: String = ""
		var serial: int = 0
		var severity: int = 0
		for rule: Dictionary in rules:
			if int(rule.get("line_index", -1)) != used:
				continue
			mode = String(rule.get("mode", ""))
			serial = _stable_hash(String(rule.get("rule_id", "")) + str(used))
			severity = int(rule.get("severity", 0))
		if mode.is_empty() and page_mode == CORRUPTED_PRESENTATION:
			mode = TopDownActionRpgRow.CORRUPTION_MODES[(page_serial + used) % TopDownActionRpgRow.CORRUPTION_MODES.size()]
			serial = page_serial + used
			severity = 1
		elif mode.is_empty() and page_mode == REDACTED_PRESENTATION:
			mode = "drop_glyph"
			serial = page_serial + used
			severity = 1
		view.set_corruption(mode, serial, severity)
		used += 1
	_set_visible(_document_advance, not lines.is_empty())
	if _field_layer != null:
		var reading: Dictionary = record.get("reading", {}) if record.get("reading", {}) is Dictionary else {}
		var visible_ratio: float = float(reading.get("world_visible_ratio", 0.35))
		_field_layer.set_dim_ratio(clampf(1.0 - visible_ratio, 0.0, 0.92))


func _render_narration() -> void:
	if _narration_layer == null:
		return
	_narration_body.text = "\n".join(_narration_lines)


func _actor_definition(actor: TopDownActionRpgCombatState.ActorState) -> Dictionary:
	var record: Variant = _actor_definitions.get(String(actor.actor_id), {})
	return record if record is Dictionary else {}


func _player_actor() -> TopDownActionRpgCombatState.ActorState:
	if combat_state == null:
		return null
	for actor: TopDownActionRpgCombatState.ActorState in combat_state.actors:
		if actor.side == "player_side":
			return actor
	return null


func _enemy_actors() -> Array:
	var result: Array = []
	if combat_state == null:
		return result
	for actor: TopDownActionRpgCombatState.ActorState in combat_state.actors:
		if actor.side == "enemy_side" and actor.is_actionable():
			result.append(actor)
	result.sort_custom(func(a: TopDownActionRpgCombatState.ActorState, b: TopDownActionRpgCombatState.ActorState) -> bool:
		if a.target_priority != b.target_priority:
			return a.target_priority < b.target_priority
		return a.encounter_slot < b.encounter_slot
	)
	return result


func _primary_enemy() -> TopDownActionRpgCombatState.ActorState:
	var enemies: Array = _enemy_actors()
	if enemies.is_empty():
		return null
	return enemies[0]


func _timing_projection() -> float:
	if _timing_override >= 0.0:
		return _timing_override
	var actor: TopDownActionRpgCombatState.ActorState = _primary_enemy()
	if actor == null or combat_state == null:
		return 0.0
	var remaining: int = maxi(0, actor.next_window_tick - combat_state.scheduler_tick)
	var span: int = maxi(1, TopDownActionRpgCombatState.BASE_SCHEDULE_TICKS)
	return clampf(1.0 - float(remaining) / float(span), 0.0, 1.0)


func _timing_ready() -> bool:
	if _timing_override >= 0.0:
		return _timing_override <= 0.0
	var actor: TopDownActionRpgCombatState.ActorState = _primary_enemy()
	if actor == null or combat_state == null:
		return true
	return actor.next_window_tick <= combat_state.scheduler_tick


func _condition_projection(actor: TopDownActionRpgCombatState.ActorState) -> float:
	if actor == null:
		return 1.0
	if _condition_overrides.has(String(actor.actor_id)):
		return clampf(float(_condition_overrides[String(actor.actor_id)]), 0.0, 1.0)
	var bar: Dictionary = _actor_definition(actor).get("condition_bar", {}) if _actor_definition(actor).get("condition_bar", {}) is Dictionary else {}
	if bar.is_empty() or String(bar.get("kind", "hp")) == "hp":
		return clampf(float(actor.hp_ratio_at()) / 100.0, 0.0, 1.0)
	return clampf(float(bar.get("start_value", 0)) / maxf(1.0, float(bar.get("max_value", 1))), 0.0, 1.0)


func _condition_is_injected(actor: TopDownActionRpgCombatState.ActorState) -> bool:
	if actor == null:
		return false
	if _condition_overrides.has(String(actor.actor_id)):
		return true
	var bar: Dictionary = _actor_definition(actor).get("condition_bar", {}) if _actor_definition(actor).get("condition_bar", {}) is Dictionary else {}
	return not bar.is_empty() and String(bar.get("kind", "hp")) != "hp"


func _render_combat() -> void:
	if _combat_layer == null or combat_controller == null or combat_state == null:
		return
	var enemies: Array = _enemy_actors()
	var focus_id: StringName = combat_controller.target_focus_actor_id
	if focus_id.is_empty() and not enemies.is_empty():
		focus_id = enemies[0].actor_id
	var focused_actor: TopDownActionRpgCombatState.ActorState = combat_state.find_actor(focus_id)
	if focused_actor == null:
		focused_actor = _primary_enemy()
	var entries: Array = []
	var slot: int = 0
	for actor: TopDownActionRpgCombatState.ActorState in enemies:
		var definition: Dictionary = _actor_definition(actor)
		_register_art_key(String(definition.get("body", {}).get("silhouette_key", "")) if definition.get("body", {}) is Dictionary else "")
		entries.append({
			"actor_id": String(actor.actor_id),
			"side": actor.side,
			"position": _enemy_position(slot),
			"body_scale": _body_scale(definition),
			"serial": _stable_hash(String(actor.actor_id)),
			"alive": actor.alive and not actor.removed,
			"stance": actor.stance_state,
			"charge_stage": String(actor.charge_state.stage) if actor.charge_state != null and actor.charge_state.is_active() else "",
			"focused": actor == focused_actor,
		})
		slot += 1
	var player: TopDownActionRpgCombatState.ActorState = _player_actor()
	if player != null:
		entries.append({
			"actor_id": String(player.actor_id),
			"side": player.side,
			"position": Vector2(430.0, 470.0),
			"body_scale": 0.85,
			"serial": _stable_hash(String(player.actor_id)),
			"alive": player.alive,
			"stance": player.stance_state,
			"charge_stage": "",
			"focused": false,
		})
	var selected: Array = []
	if String(combat_state.submode) == "target_select":
		var pending: Dictionary = _pending_action()
		var mode: String = String(pending.get("intent", {}).get("target_mode", "SELF")) if pending.get("intent", {}) is Dictionary else "SELF"
		if mode == "ALL_ENEMIES" or mode == "RANDOM_ENEMY":
			for actor: TopDownActionRpgCombatState.ActorState in enemies:
				selected.append(actor.actor_id)
	var model: Dictionary = {
		"actors": entries,
		"selected_actor_ids": selected,
		"timing_ratio": _timing_projection(),
		"timing_ready": _timing_ready(),
		"condition_ratio": _condition_projection(focused_actor),
		"condition_ratio_injected": _condition_is_injected(focused_actor),
		"feedback": _feedback_marks,
	}
	_combat_layer.set_combat_model(model)
	_combat_layer.set_dim_ratio(0.0)
	_render_command_rail()
	_render_player_band(player)


func _enemy_position(index: int) -> Vector2:
	if index == 0:
		return Vector2(760.0, 290.0)
	var offset: float = 150.0 * float(index)
	var side: float = 1.0 if index % 2 == 1 else -1.0
	return Vector2(760.0 - side * offset, 330.0 + 60.0 * float((index - 1) / 2))


func _body_scale(definition: Dictionary) -> float:
	var scale_class: String = String(definition.get("body", {}).get("scale_class", "human")) if definition.get("body", {}) is Dictionary else "human"
	match scale_class:
		"small":
			return 0.7
		"large":
			return 1.25
		"architectural":
			return 1.5
		_:
			return 1.0


func _pending_action() -> Dictionary:
	if combat_controller == null or catalog == null:
		return {}
	var action_id: String = String(combat_controller.get_meta("pending_action_id", ""))
	if action_id.is_empty():
		return {}
	return catalog.record(action_id)


func _render_command_rail() -> void:
	if _command_rows == null or combat_controller == null or combat_state == null:
		return
	var category: String = _rail_category()
	var rows: Array = _rail_row_model(category)
	_grow_pool(_command_rows, _command_rows_view, TopDownActionRpgRow.ROLE_COMMAND, 40.0)
	if _rail_focus >= rows.size():
		_rail_focus = 0
	var used: int = 0
	var footer: String = ""
	for view: TopDownActionRpgRow in _command_rows_view:
		if used >= rows.size():
			view.visible = false
			used += 1
			continue
		view.visible = true
		var row: Dictionary = rows[used]
		view.row_id = StringName(String(row.get("id", "")))
		view.set_text(String(row.get("label", "")))
		view.set_trailing(String(row.get("trailing", "")))
		view.set_presentation_class(String(row.get("presentation_class", "neutral")))
		view.set_disabled_state(not bool(row.get("available", true)))
		view.set_focus_state(used == _rail_focus)
		if used == _rail_focus:
			footer = String(row.get("detail", ""))
			if not bool(row.get("available", true)) and footer.is_empty():
				footer = String(row.get("trailing", ""))
		used += 1
	if _command_footer != null:
		_command_footer.text = footer
	_set_visible(_command_rail, rows.size() > 0)


func _rail_category() -> String:
	if not _rail_expanded:
		return ""
	var current: String = String(combat_controller.current_category)
	return current if CATEGORY_ROW_TOKENS.has(current) else _rail_token


func _rail_row_model(category: String) -> Array:
	var rows: Array = []
	if category.is_empty():
		var actor: TopDownActionRpgCombatState.ActorState = _player_actor()
		for token: String in CATEGORY_ROW_TOKENS:
			var available: bool = _category_available(actor, token)
			rows.append({
				"id": token,
				"label": String(CATEGORY_LABELS.get(token, token)),
				"trailing": "" if available else "unavailable",
				"presentation_class": "neutral",
				"available": available,
				"detail": "" if available else "encounter policy",
			})
		rows.append({
			"id": LABEL_END_TURN,
			"label": LABEL_END_TURN,
			"trailing": "",
			"presentation_class": "result",
			"available": true,
			"detail": "close command window",
		})
		return rows
	for row: Dictionary in _submenu_row_model(category):
		rows.append(row)
	rows.append({
		"id": LABEL_BACK,
		"label": LABEL_BACK,
		"trailing": "",
		"presentation_class": "neutral",
		"available": true,
		"detail": "",
	})
	return rows


func _rail_source_categories(token: String) -> Array:
	if combat_controller == null:
		return [token]
	return combat_controller.rail_source_categories(token)


func _category_available(actor: TopDownActionRpgCombatState.ActorState, token: String) -> bool:
	if token == "escape":
		return _escape_allowed()
	if actor == null or catalog == null:
		return false
	var sources: Array = _rail_source_categories(token)
	for action_id: String in catalog.ids_of_kind("actions"):
		var record: Dictionary = catalog.record(action_id)
		if not sources.has(String(record.get("category", ""))):
			continue
		if String(record.get("owner", "")) not in ["player", "npc"]:
			continue
		return true
	return false


func _escape_allowed() -> bool:
	if combat_controller == null:
		return false
	var allow: Dictionary = combat_controller.encounter_definition.get("allow", {}) if combat_controller.encounter_definition.get("allow", {}) is Dictionary else {}
	return bool(allow.get(ESCAPE_ALLOW_KEY, false))


func _submenu_row_model(category: String) -> Array:
	var rows: Array = []
	if combat_controller == null or combat_state == null:
		return rows
	var entries: Array = _action_row_override
	if entries.is_empty():
		entries = combat_controller.available_commands(combat_controller.current_actor_id)
	var pending_id: String = String(combat_controller.get_meta("pending_action_id", ""))
	var sources: Array = _rail_source_categories(category) if not category.is_empty() else []
	for entry: Variant in entries:
		if not entry is Dictionary:
			continue
		var record_id: String = String((entry as Dictionary).get("id", ""))
		if not sources.is_empty() and not sources.has(_record_category(record_id)):
			continue
		var record: Dictionary = catalog.record(record_id) if catalog != null else {}
		var available: bool = bool((entry as Dictionary).get("available", true))
		var reason: String = _reason_label(String((entry as Dictionary).get("reason", "")))
		rows.append({
			"id": record_id,
			"label": String(record.get("display_name", record_id)),
			"trailing": reason,
			"presentation_class": "neutral" if available else "unavailable",
			"available": available,
			"focused": record_id == pending_id,
			"detail": _action_detail(record, available, reason),
		})
	return rows


func _record_category(action_id: String) -> String:
	if catalog == null:
		return ""
	return String(catalog.record(action_id).get("category", ""))


func _action_detail(record: Dictionary, available: bool, reason: String) -> String:
	if not available:
		return reason
	if record.is_empty():
		return ""
	var intent: Dictionary = record.get("intent", {}) if record.get("intent", {}) is Dictionary else {}
	var cost: Dictionary = record.get("cost", {}) if record.get("cost", {}) is Dictionary else {}
	var parts: Array = [String(TARGET_MODE_LABELS.get(String(intent.get("target_mode", "SELF")), "self"))]
	parts.append("turn " + str(int(cost.get("turn_cost", 1))))
	var resources: Dictionary = cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else {}
	for key: String in TopDownActionRpgGameState.COMBAT_RESOURCE_KEYS:
		if int(resources.get(key, 0)) > 0:
			parts.append(key + " " + str(int(resources[key])))
	return "  ".join(parts)


func _reason_label(reason: String) -> String:
	match reason:
		"skipped_cooldown":
			return "cooldown"
		"skipped_insufficient_resource":
			return "resource"
		"skipped_blocked_by_status":
			return "blocked"
		"skipped_phase_invalidated":
			return "phase"
		"skipped_no_valid_target":
			return "no target"
		"skipped_action_unavailable":
			return "unavailable"
		"skipped_dead_actor":
			return "no actor"
		"":
			return ""
		_:
			return "unavailable"


func _render_player_band(actor: TopDownActionRpgCombatState.ActorState) -> void:
	if _player_band == null or actor == null:
		_set_visible(_player_band, false)
		return
	_player_name.text = actor.display_name
	_player_hp.text = "HP " + str(actor.hp) + " / " + str(actor.max_hp)
	_player_mp.text = "MP " + str(actor.mp) + " / " + str(actor.max_mp)
	_action_slots.text = LABEL_ACTIONS_PREFIX + str(_free_slots(actor))
	var instances: Array = []
	for instance: TopDownActionRpgCombatState.StatusInstance in actor.status_instances:
		if instance.active:
			instances.append(instance)
	_grow_pool(_player_status, _status_rows_view, TopDownActionRpgRow.ROLE_NARRATION, 20.0)
	var used: int = 0
	for view: TopDownActionRpgRow in _status_rows_view:
		if used >= instances.size():
			view.visible = false
			used += 1
			continue
		var instance: TopDownActionRpgCombatState.StatusInstance = instances[used]
		view.visible = true
		view.row_id = &""
		view.set_focus_state(false)
		view.set_disabled_state(not actor.can_act)
		view.set_presentation_class("official" if instance.stacks > 1 else "neutral")
		view.set_text(_status_label(instance))
		used += 1


func _free_slots(actor: TopDownActionRpgCombatState.ActorState) -> int:
	var consumed: int = 0
	for intent: TopDownActionRpgCombatState.QueuedIntent in combat_controller.commands:
		if intent.actor_id == actor.actor_id and not intent.no_turn:
			consumed += 1
	return maxi(0, TopDownActionRpgCombatState.effective_action_slots(actor) - consumed)


func _status_label(instance: TopDownActionRpgCombatState.StatusInstance) -> String:
	if catalog == null:
		return String(instance.definition_id)
	var record: Dictionary = catalog.record(String(instance.definition_id))
	var label: String = String(record.get("display_name", ""))
	if label.is_empty():
		label = String(instance.definition_id)
	if instance.stacks > 1:
		label += " x" + str(instance.stacks)
	return label
