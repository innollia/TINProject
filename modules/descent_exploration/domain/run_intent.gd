class_name RunIntent
extends RefCounted

var up: bool = false
var down: bool = false
var left: bool = false
var right: bool = false
var surge: bool = false
var consume: bool = false


static func create(p_up: bool = false, p_down: bool = false, p_left: bool = false, p_right: bool = false, p_surge: bool = false, p_consume: bool = false) -> RunIntent:
	var intent := RunIntent.new()
	intent.up = p_up
	intent.down = p_down
	intent.left = p_left
	intent.right = p_right
	intent.surge = p_surge
	intent.consume = p_consume
	return intent


func direction() -> Vector2:
	return Vector2(float(right) - float(left), float(down) - float(up))


func is_idle() -> bool:
	return not (up or down or left or right or surge or consume)


func copy() -> RunIntent:
	return create(up, down, left, right, surge, consume)
