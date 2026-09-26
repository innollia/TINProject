class_name MatterItem
extends RefCounted

const VERBS: Array[String] = ["plug", "feed", "strike", "weigh"]
const SIZE_MIN: int = 1
const SIZE_MAX: int = 3

var id: String = ""
var size: int = 1
var verb: String = "weigh"
var tag: String = ""
var source_stratum: String = ""


static func create(p_id: String, p_size: int, p_verb: String, p_tag: String, p_source: String = "") -> MatterItem:
	var item := MatterItem.new()
	item.id = p_id
	item.size = p_size
	item.verb = p_verb
	item.tag = p_tag
	item.source_stratum = p_source
	return item


static func is_valid_dictionary(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	var source: Dictionary = data
	var raw_id: Variant = source.get("id")
	if not raw_id is String or (raw_id as String).is_empty():
		return false
	var raw_size: Variant = source.get("size")
	if not (raw_size is int or raw_size is float):
		return false
	var number: float = float(raw_size)
	if not is_finite(number) or number != floorf(number) or number < SIZE_MIN or number > SIZE_MAX:
		return false
	var raw_verb: Variant = source.get("verb")
	if not raw_verb is String or not VERBS.has(raw_verb as String):
		return false
	var raw_tag: Variant = source.get("tag")
	if not raw_tag is String or (raw_tag as String).is_empty():
		return false
	var raw_source: Variant = source.get("source_stratum", "")
	return raw_source is String


static func from_dictionary(data: Variant) -> MatterItem:
	if not is_valid_dictionary(data):
		return null
	var source: Dictionary = data
	return create(String(source["id"]), int(source["size"]), String(source["verb"]), String(source["tag"]), String(source.get("source_stratum", "")))


func to_dictionary() -> Dictionary:
	return {"id": id, "size": size, "verb": verb, "tag": tag, "source_stratum": source_stratum}


func copy() -> MatterItem:
	return create(id, size, verb, tag, source_stratum)
