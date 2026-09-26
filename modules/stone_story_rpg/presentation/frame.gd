class_name StoneStoryFrame
extends Control

## 고정 내부 버퍼 960x640 + 정수 배 확대.
## project.godot 을 고치지 않는다. 비율은 런타임에 잰다.
## PVE 는 정수 스케일러를 제공하지 않는다. (탐색 결과 확인) 이 클래스가 그 대체다.

signal buffer_resized

const VIEW_W: int = 960
const VIEW_H: int = 640

var scale_factor: int = 1

var _view: SubViewport = null
var _display: TextureRect = null
var _backdrop: ColorRect = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	_build()
	resized.connect(_recompute)
	var vp := get_viewport()
	if vp != null:
		vp.size_changed.connect(_recompute)
	_recompute()


func _build() -> void:
	# 여백 = 순수 검정. 뷰포트 밖은 항상 검정이어야 화면 경계가 없다.
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0, 0, 0, 1)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_backdrop)

	_view = SubViewport.new()
	_view.size = Vector2i(VIEW_W, VIEW_H)
	_view.transparent_bg = false
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.msaa_2d = Viewport.MSAA_DISABLED
	_view.use_hdr_2d = false
	_view.handle_input_locally = false
	add_child(_view)

	_display = TextureRect.new()
	_display.texture = _view.get_texture()
	_display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_display.stretch_mode = TextureRect.STRETCH_SCALE
	_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_display)


func get_view() -> SubViewport:
	return _view


## 창 크기가 바뀔 때만. 매 프레임 하지 않는다.
func _recompute() -> void:
	var win := DisplayServer.window_get_size()
	var logical := size
	if logical.x <= 0.0 or logical.y <= 0.0:
		logical = Vector2(VIEW_W, VIEW_H)
	var rx: float = maxf(1.0, float(win.x) / logical.x)
	var ry: float = maxf(1.0, float(win.y) / logical.y)
	var k: int = maxi(1, floori(minf(rx, ry)))
	if k != scale_factor:
		scale_factor = k
	_layout(logical)
	buffer_resized.emit()


func _layout(logical: Vector2) -> void:
	var w: float = float(VIEW_W * scale_factor)
	var h: float = float(VIEW_H * scale_factor)
	if w > logical.x:
		w = logical.x
	if h > logical.y:
		h = logical.y
	_display.position = Vector2(floorf((logical.x - w) * 0.5), floorf((logical.y - h) * 0.5))
	_display.size = Vector2(w, h)
	_view.size = Vector2i(VIEW_W, VIEW_H)


## 창 크기 -> 내부 정수 배. 검수용.
static func scale_for(win: Vector2i) -> int:
	return maxi(1, floori(minf(float(win.x) / float(VIEW_W), float(win.y) / float(VIEW_H))))
