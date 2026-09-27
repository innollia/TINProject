class_name EcoSleepScreen
extends Control

## §5.1, §11.6.2. 잠 화면. 가운데 일러스트(잠든 개체) + 좌측 방문 그래프 + 우하단
## 버튼 2개(일어나다 T5, 나가다 T6). 숫자·카운트·게이지 0개.

signal wake_pressed
signal exit_pressed

var illustration: EcoScreenIllustration
var graph: EcoPassageGraphView


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	graph = EcoPassageGraphView.new()
	graph.set_anchors_preset(Control.PRESET_TOP_LEFT)
	graph.size = Vector2(300.0, 400.0)
	graph.position = Vector2(24.0, 24.0)
	add_child(graph)
	illustration = EcoScreenIllustration.new()
	illustration.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(illustration)
	var box: HBoxContainer = HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	box.position -= Vector2(48.0, 48.0)
	add_child(box)
	var wake: Button = Button.new()
	wake.text = "일어나다"
	wake.pressed.connect(func() -> void: wake_pressed.emit())
	box.add_child(wake)
	var exit_btn: Button = Button.new()
	exit_btn.text = "나가다"
	exit_btn.pressed.connect(func() -> void: exit_pressed.emit())
	box.add_child(exit_btn)
	wake.grab_focus()


func setup(world_seed: int, all_room_ids: PackedStringArray, links: Array, rooms_visited: PackedStringArray) -> void:
	illustration.setup(world_seed, "sleep")
	graph.setup(all_room_ids, links, rooms_visited)


func step(delta: float) -> void:
	illustration.step(delta)
