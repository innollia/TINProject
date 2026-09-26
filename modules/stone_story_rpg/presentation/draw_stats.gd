class_name StoneStoryDrawStats
extends RefCounted

## 렌더러가 "무엇을 그렸는지"를 스스로 센다.
## 비주얼 계약(01_RENDER_PIPELINE §8 V1~V15)을 헤드리스에서 검증하기 위한 근거다.
## 화면 캡처를 눈으로 보지 않아도 계약 위반을 잡는다.
##
## 계약 항목 매핑:
##   V1  공간 존재        -> bands_filled > 0
##   V2  순수 검정 단색 금지 -> flat_black_ratio 가 낮다
##   V3  채워진 면 비율    -> filled_ratio
##   V4  헤어라인만인 오브젝트 금지 -> stroke_only_ratio
##   V5  그레이스케일 강제 금지 -> palette.gd 정적 검사
##   V6  공간당 색 4~6      -> distinct_hues
##   V7  큰 것 존재        -> largest_object_ratio
##   V8  개체에 눈          -> eye_count

var filled_pixels: int = 0
var total_pixels: int = 1
var filled_rects: int = 0
var filled_shapes: int = 0
var strokes: int = 0
var eyes: int = 0
var sky_bands: int = 0
var ground_bands: int = 0
var structure_heights: Array[float] = []
var colors: Dictionary = {}
var object_heights: Array[float] = []
var view_w: int = 960
var view_h: int = 640


func reset() -> void:
	filled_pixels = 0
	filled_rects = 0
	filled_shapes = 0
	strokes = 0
	eyes = 0
	sky_bands = 0
	ground_bands = 0
	structure_heights.clear()
	colors.clear()
	object_heights.clear()


func note_rect(r: Rect2i, col: Color, filled: bool) -> void:
	if filled:
		filled_rects += 1
		# 화면 밖으로 나간 부분은 세지 않는다. 겹친 면은 중복 계상된다.
		var x0: int = clampi(r.position.x, 0, view_w)
		var y0: int = clampi(r.position.y, 0, view_h)
		var x1: int = clampi(r.position.x + r.size.x, 0, view_w)
		var y1: int = clampi(r.position.y + r.size.y, 0, view_h)
		if x1 > x0 and y1 > y0:
			filled_pixels = mini(total_pixels, filled_pixels + (x1 - x0) * (y1 - y0))
		_note_color(col)
		if r.size.y > 0 and float(r.size.y) / float(view_h) > 0.25:
			structure_heights.append(float(r.size.y) / float(view_h))
	else:
		strokes += 1


func note_shape(approx_pixels: int, col: Color, height_ratio: float = 0.0) -> void:
	filled_shapes += 1
	filled_pixels = mini(total_pixels, filled_pixels + maxi(0, approx_pixels))
	_note_color(col)
	if height_ratio > 0.0:
		object_heights.append(height_ratio)


func note_stroke() -> void:
	strokes += 1


func note_eye() -> void:
	eyes += 1


func note_sky_band() -> void:
	sky_bands += 1


func note_ground_band() -> void:
	ground_bands += 1


func _note_color(col: Color) -> void:
	# 채도를 버린 색(그레이스케일)을 별도로 센다.
	var mx: float = maxf(col.r, maxf(col.g, col.b))
	var mn: float = minf(col.r, minf(col.g, col.b))
	var sat: float = 0.0 if mx <= 0.0001 else (mx - mn) / mx
	var key: String = ""
	if sat < 0.12:
		key = "grey:%d" % int(round(mx * 4.0))
	else:
		key = "hue:%d" % int(round(col.h * 12.0))
	colors[key] = int(colors.get(key, 0)) + 1


# --- 계약 판정값 ----------------------------------------------------

func filled_ratio() -> float:
	return float(filled_pixels) / float(maxi(1, total_pixels))


## 화면 대부분이 단색 검정이면 V2 위반이다.
func flat_black_ratio() -> float:
	var flat: int = int(colors.get("grey:0", 0))
	var total_keys: int = colors.size()
	if total_keys == 0:
		return 1.0
	return float(flat) / float(total_keys)


func stroke_only_ratio() -> float:
	var drawn: int = filled_rects + filled_shapes
	if drawn == 0:
		return 1.0
	return float(strokes) / float(drawn + strokes)


func distinct_hues() -> int:
	var n: int = 0
	for k in colors:
		if str(k).begins_with("hue:"):
			n += 1
	return n


func grey_share() -> float:
	var grey: int = 0
	var hue: int = 0
	for k in colors:
		if str(k).begins_with("grey:"):
			grey += 1
		elif str(k).begins_with("hue:"):
			hue += 1
	if grey + hue == 0:
		return 1.0
	return float(grey) / float(grey + hue)


func largest_object_ratio() -> float:
	var best: float = 0.0
	for h in structure_heights:
		best = maxf(best, h)
	for h in object_heights:
		best = maxf(best, h)
	return best


func has_space() -> bool:
	return sky_bands > 0 and ground_bands > 0


func report() -> String:
	return "filled=%.3f flatblack=%.2f strokes=%.2f hues=%d grey=%.2f sky=%d ground=%d big=%.2f eyes=%d" % [
			filled_ratio(), flat_black_ratio(), stroke_only_ratio(), distinct_hues(),
			grey_share(), sky_bands, ground_bands, largest_object_ratio(), eyes]
