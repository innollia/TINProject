class_name EcoDeathScreen
extends Control

## §5.1, §11.6.3. 사망 화면. 가운데 일러스트(명도 1.0 → 0.4, 1.5초) + 우하단
## 버튼 2개(다시 T3, 나가다 T4). 본문 텍스트 0자. 사망 원인 표시 0.

signal retry_pressed
signal exit_pressed

var illustration: EcoScreenIllustration
var _modulate_timer: float = 0.0
const FADE_TIME: float = 1.5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	illustration = EcoScreenIllustration.new()
	illustration.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(illustration)
	var box: HBoxContainer = HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	box.position -= Vector2(48.0, 48.0)
	add_child(box)
	var retry: Button = Button.new()
	retry.text = "다시"
	retry.pressed.connect(func() -> void: retry_pressed.emit())
	box.add_child(retry)
	var exit_btn: Button = Button.new()
	exit_btn.text = "나가다"
	exit_btn.pressed.connect(func() -> void: exit_pressed.emit())
	box.add_child(exit_btn)
	retry.grab_focus()


func setup(world_seed: int) -> void:
	illustration.setup(world_seed, "death")
	_modulate_timer = 0.0
	illustration.modulate = Color(1.0, 1.0, 1.0, 1.0)


func step(delta: float) -> void:
	illustration.step(delta)
	_modulate_timer = minf(_modulate_timer + delta, FADE_TIME)
	var t: float = _modulate_timer / FADE_TIME
	var value: float = lerpf(1.0, 0.4, t)
	illustration.modulate = Color(value, value, value, 1.0)
