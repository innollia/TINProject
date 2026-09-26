class_name StoneStoryFrame
extends Control

## 논리 좌표는 960x640 안전 영역. 화면비가 넓으면 논리 폭만 MAX_W 까지 넓힌다.
## 버퍼는 실제 화면 픽셀 크기로 만들고 2D 좌표만 논리 크기로 고정한다(size_2d_override).
## 면이 실제 해상도에서 래스터화되므로 확대 번짐이 없다.

signal buffer_resized

const VIEW_W: int = 960
const VIEW_H: int = 640
const MAX_W: int = 1138

var scale_factor: float = 1.0
var view_w: int = VIEW_W
var safe_x: int = 0
var pixel_size: Vector2i = Vector2i(VIEW_W, VIEW_H)

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
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0, 0, 0, 1)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_backdrop)

	_view = SubViewport.new()
	_view.size = Vector2i(VIEW_W, VIEW_H)
	_view.size_2d_override = Vector2i(VIEW_W, VIEW_H)
	_view.size_2d_override_stretch = true
	_view.transparent_bg = false
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.msaa_2d = Viewport.MSAA_4X
	_view.use_hdr_2d = false
	_view.handle_input_locally = false
	add_child(_view)

	_display = TextureRect.new()
	_display.texture = _view.get_texture()
	_display.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_display.stretch_mode = TextureRect.STRETCH_SCALE
	_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_display)


func get_view() -> SubViewport:
	return _view


static func layout_for(logical: Vector2, physical_scale: float) -> Dictionary:
	var lx: float = maxf(1.0, logical.x)
	var ly: float = maxf(1.0, logical.y)
	var w: int = clampi(int(round(float(VIEW_H) * lx / ly)), VIEW_W, MAX_W)
	var s: float = minf(lx / float(w), ly / float(VIEW_H))
	var shown := Vector2(float(w) * s, float(VIEW_H) * s)
	var px := Vector2i(maxi(1, roundi(shown.x * physical_scale)), maxi(1, roundi(shown.y * physical_scale)))
	return {
		"view_w": w,
		"safe_x": (w - VIEW_W) / 2,
		"logical_scale": s,
		"shown": shown,
		"offset": ((Vector2(lx, ly) - shown) * 0.5).floor(),
		"pixels": px,
	}


func physical_scale() -> float:
	var vp := get_viewport()
	if vp == null:
		return 1.0
	var vis: Vector2 = vp.get_visible_rect().size
	var win: Vector2i = DisplayServer.window_get_size()
	if vis.x <= 0.0 or vis.y <= 0.0 or win.x <= 0 or win.y <= 0:
		return 1.0
	return clampf(minf(float(win.x) / vis.x, float(win.y) / vis.y), 0.25, 8.0)


func _recompute() -> void:
	var logical: Vector2 = size
	if logical.x <= 0.0 or logical.y <= 0.0:
		logical = Vector2(VIEW_W, VIEW_H)
	var lay: Dictionary = layout_for(logical, physical_scale())
	view_w = int(lay["view_w"])
	safe_x = int(lay["safe_x"])
	scale_factor = float(lay["logical_scale"])
	pixel_size = lay["pixels"]
	_view.size = pixel_size
	_view.size_2d_override = Vector2i(view_w, VIEW_H)
	_display.position = lay["offset"]
	_display.size = lay["shown"]
	buffer_resized.emit()
