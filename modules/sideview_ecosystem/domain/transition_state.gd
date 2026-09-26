class_name EcoTransitionState
extends RefCounted

var active: bool = false
var from_rung: String = ""
var to_rung: String = ""
var trigger_kind: String = ""
var trigger_id: String = ""
var elapsed: float = 0.0
var hits: int = 0
var still_seconds: float = 0.0
var witness_frames: int = 0


func reset() -> void:
	active = false
	from_rung = ""
	to_rung = ""
	trigger_kind = ""
	trigger_id = ""
	elapsed = 0.0
	hits = 0
	still_seconds = 0.0
	witness_frames = 0


func begin(p_from: String, p_to: String, p_kind: String, p_id: String) -> void:
	reset()
	active = true
	from_rung = p_from
	to_rung = p_to
	trigger_kind = p_kind
	trigger_id = p_id


func to_dictionary() -> Dictionary:
	return {}
