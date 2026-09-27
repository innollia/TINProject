## 히로인 초상 자리. 그림 에셋 대신 작품 색으로 칠한 실루엣(머리·어깨·머리카락)을 그린다.
extends Control

var tint := Color("f2c9d0")
var hair := Color("3b2a33")
var breath := 0.0
var mood := 0.0 # 대답 순간 살짝 떠오름


func _process(delta: float) -> void:
	breath += delta
	mood = move_toward(mood, 0.0, delta * 1.5)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var cx := w * 0.5
	var bob := sin(breath * 1.6) * 3.0 - mood * 10.0
	# 후광
	draw_circle(Vector2(cx, h * 0.34 + bob), w * 0.42, Color(tint, 0.12))
	# 어깨·몸
	var body := PackedVector2Array([
		Vector2(cx - w * 0.40, h), Vector2(cx - w * 0.30, h * 0.66 + bob), Vector2(cx - w * 0.10, h * 0.56 + bob),
		Vector2(cx + w * 0.10, h * 0.56 + bob), Vector2(cx + w * 0.30, h * 0.66 + bob), Vector2(cx + w * 0.40, h)])
	draw_colored_polygon(body, tint.darkened(0.35))
	# 목
	draw_rect(Rect2(cx - w * 0.05, h * 0.44 + bob, w * 0.10, h * 0.14), tint.darkened(0.1))
	# 뒷머리
	draw_circle(Vector2(cx, h * 0.33 + bob), w * 0.21, hair)
	draw_rect(Rect2(cx - w * 0.21, h * 0.33 + bob, w * 0.42, h * 0.26), hair)
	# 얼굴
	draw_circle(Vector2(cx, h * 0.35 + bob), w * 0.16, tint)
	# 앞머리
	draw_arc(Vector2(cx, h * 0.33 + bob), w * 0.17, PI * 1.05, PI * 1.95, 24, hair, w * 0.09)
	# 감은 눈(인용구 속 인물이라 표정은 비워 둠)
	var ey := h * 0.37 + bob
	draw_arc(Vector2(cx - w * 0.06, ey), w * 0.025, 0.2, PI - 0.2, 8, hair, 2.0)
	draw_arc(Vector2(cx + w * 0.06, ey), w * 0.025, 0.2, PI - 0.2, 8, hair, 2.0)
