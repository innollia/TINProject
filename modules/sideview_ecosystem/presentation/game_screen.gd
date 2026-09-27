class_name EcoGameScreen
extends Control

## §5.1, §11.1. 화면 루트. 풀사이즈 ColorRect + OverlayHost 만. 상시 HUD 자식 0개.
## 3화면(로딩/사망/잠)을 여기 담고, BubbleOverlay 는 normal 상태에서만 보인다.

var bubble: EcoBubbleOverlay
var loading_screen: EcoLoadingScreen
var death_screen: EcoDeathScreen
var sleep_screen: EcoSleepScreen
var background: ColorRect

var _director: EcoStepDirector
var _module: Object


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	background = ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	bubble = EcoBubbleOverlay.new()
	bubble.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bubble)

	loading_screen = EcoLoadingScreen.new()
	loading_screen.visible = false
	loading_screen.continue_pressed.connect(_on_continue_pressed)
	add_child(loading_screen)

	death_screen = EcoDeathScreen.new()
	death_screen.visible = false
	death_screen.retry_pressed.connect(_on_retry_pressed)
	death_screen.exit_pressed.connect(_on_exit_pressed)
	add_child(death_screen)

	sleep_screen = EcoSleepScreen.new()
	sleep_screen.visible = false
	sleep_screen.wake_pressed.connect(_on_wake_pressed)
	sleep_screen.exit_pressed.connect(_on_exit_pressed)
	add_child(sleep_screen)


func bind(module_ref: Object, director: EcoStepDirector) -> void:
	_module = module_ref
	_director = director
	if director != null:
		loading_screen.setup(director.world_seed)


func show_loading_ready() -> void:
	loading_screen.visible = true
	loading_screen.show_continue()


func step(delta: float) -> void:
	if _director == null:
		return
	bubble.step(delta)
	match _director.mode:
		EcoStepDirector.MODE_LOADING:
			loading_screen.visible = true
			loading_screen.step(delta)
		EcoStepDirector.MODE_DYING, EcoStepDirector.MODE_DEAD:
			death_screen.visible = true
			if death_screen.illustration.rig == null:
				death_screen.setup(_director.world_seed)
			death_screen.step(delta)
		EcoStepDirector.MODE_ASLEEP:
			sleep_screen.visible = true
			if _director.index != null:
				sleep_screen.setup(_director.world_seed, _director.index.all_room_ids(), _director.index.all_links(), _director.world.rooms_visited)
			sleep_screen.step(delta)
		_:
			loading_screen.visible = false
			death_screen.visible = false
			sleep_screen.visible = false


func _on_continue_pressed() -> void:
	if _module != null and _module.has_method("continue_from_loading"):
		_module.call("continue_from_loading")


func _on_retry_pressed() -> void:
	if _director != null:
		_director.respawn()


func _on_wake_pressed() -> void:
	if _director != null:
		_director.mode = EcoStepDirector.MODE_NORMAL


func _on_exit_pressed() -> void:
	if _module != null and _module.has_method("request_menu"):
		_module.call("request_menu")
