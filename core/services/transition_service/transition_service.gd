class_name TransitionService
extends Node

@export var duration: float = 0.15
var _overlay: ColorRect

func setup(overlay: ColorRect) -> void:
	_overlay = overlay
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out() -> void:
	await _fade(1.0)

func fade_in() -> void:
	await _fade(0.0)

func _fade(alpha: float) -> void:
	if _overlay == null:
		return
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if duration > 0.0:
		var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(_overlay, "color:a", alpha, duration)
		await tween.finished
	else:
		_overlay.color.a = alpha
	if alpha == 0.0:
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
