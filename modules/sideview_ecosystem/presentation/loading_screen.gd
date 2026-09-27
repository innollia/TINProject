class_name EcoLoadingScreen
extends Control

## §5.1, §11.6.1. 로딩 화면. 가운데 일러스트 + 우하단 계속 버튼(T2). 진행 바 0.
## 본문 텍스트 0자.

signal continue_pressed

var illustration: EcoScreenIllustration
var _button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.09, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	illustration = EcoScreenIllustration.new()
	illustration.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(illustration)
	var box: HBoxContainer = HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	box.position -= Vector2(48.0, 48.0)
	add_child(box)
	_button = Button.new()
	_button.text = "계속"
	_button.visible = false
	_button.pressed.connect(func() -> void: continue_pressed.emit())
	box.add_child(_button)


func setup(world_seed: int) -> void:
	illustration.setup(world_seed, "loading")


func step(delta: float) -> void:
	illustration.step(delta)


func show_continue() -> void:
	_button.visible = true
	_button.grab_focus()
