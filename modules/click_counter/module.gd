extends GameModule

const TARGET_COUNT: int = 10

@onready var _count_label: Label = $UI/Center/Rows/CountLabel
@onready var _increment_button: Button = $UI/Center/Rows/IncrementButton

var _ctx: ModuleContext = null
var _count: int = 0
var _finished: bool = false
var _confirm_held: bool = false


func _ready() -> void:
	_increment_button.pressed.connect(_on_increment_pressed)
	_refresh_label()


func enter(ctx: ModuleContext) -> void:
	super.enter(ctx)
	_ctx = ctx


func exit() -> void:
	_ctx = null
	super.exit()


func _process(_delta: float) -> void:
	if _ctx == null:
		return
	var held: bool = _ctx.is_action_pressed(&"click_counter_confirm")
	if held and not _confirm_held:
		_increment()
	_confirm_held = held


func save_state() -> Dictionary:
	return {"count": _count}


func load_state(state: Dictionary) -> void:
	_count = _sanitize_count(state.get("count", 0))
	_finished = _count >= TARGET_COUNT
	_confirm_held = false
	_refresh_label()


func execute_command(command: StringName, _payload: Dictionary = {}) -> bool:
	if command == &"reset":
		_count = 0
		_finished = false
		_confirm_held = false
		_refresh_label()
		return true
	return false


func _on_increment_pressed() -> void:
	_increment()


func _increment() -> void:
	if _ctx == null or not _ctx.input_enabled or _finished:
		return
	_count += 1
	_refresh_label()
	if _count >= TARGET_COUNT:
		_finished = true
		var result: ModuleResult = ModuleResult.new()
		result.module_id = &"click_counter"
		result.outcome = &"completed"
		result.data = {"count": _count}
		finished.emit(result)


func _refresh_label() -> void:
	_count_label.text = "Count: %d / %d" % [_count, TARGET_COUNT]


func _sanitize_count(value: Variant) -> int:
	if value is int:
		var as_int: int = value
		return clampi(as_int, 0, TARGET_COUNT)
	if value is float:
		var as_float: float = value
		if not is_finite(as_float) or as_float != floorf(as_float):
			return 0
		return clampi(int(as_float), 0, TARGET_COUNT)
	return 0
