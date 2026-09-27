class_name EcoBodyAxis
extends RefCounted

const FIELD_SCALE: String = "scale"
const FIELD_WOUNDS: String = "wounds"
const FIELD_MISSING: String = "missing"
const FIELD_FACTS: String = "facts"

var present: bool = false
var has_scale: bool = false
var scale_value: float = 0.0
var has_wounds: bool = false
var wounds: Array = []
var missing: Array = []
var facts: Dictionary = {}


static func from_view(view: WorldStateView) -> EcoBodyAxis:
	var axis: EcoBodyAxis = EcoBodyAxis.new()
	if view == null or not view.has_body():
		return axis
	var body: AxisBody = view.get_body()
	if body == null:
		return axis
	axis.present = true
	var s: Variant = body.get_scale()
	if (s is float or s is int) and body.has_scale():
		axis.has_scale = true
		axis.scale_value = float(s)
	var w: Variant = body.get_wounds()
	if w is Array:
		axis.has_wounds = body.has_field(&"wounds")
		axis.wounds = (w as Array).duplicate(true)
	var m: Variant = body.get_missing()
	if m is Array:
		axis.missing = (m as Array).duplicate(true)
	var f: Variant = body.get_facts()
	if f is Dictionary:
		axis.facts = (f as Dictionary).duplicate(true)
	return axis


static func wounds_patch(merged: Array) -> Dictionary:
	return {FIELD_WOUNDS: merged.duplicate(true)}


static func scale_patch(value: float) -> Dictionary:
	return {FIELD_SCALE: value}


func to_patch() -> Dictionary:
	var patch: Dictionary = {}
	if has_scale:
		patch[FIELD_SCALE] = scale_value
	if has_wounds:
		patch[FIELD_WOUNDS] = wounds.duplicate(true)
	return patch
