extends RefCounted

const REASON_STORE_ABSENT: String = "store_absent"
const REASON_REPLY_INVALID: String = "store_reply_invalid"

var requester: StringName = &""
var last_result: Dictionary = {}
var accepted: int = 0
var refused: int = 0
var _store: Object = null


func bind(store: Object, requester_id: StringName) -> RefCounted:
	_store = store
	requester = requester_id
	return self


func has_store() -> bool:
	return _store != null and is_instance_valid(_store) and _store.has_method("request_mutation")


func request(axis_name: StringName, patch: Dictionary) -> Dictionary:
	var result: Dictionary
	if not has_store():
		result = {"ok": false, "reason": REASON_STORE_ABSENT, "detail": String(axis_name)}
	else:
		var reply: Variant = _store.call("request_mutation", axis_name, patch.duplicate(true), requester)
		if reply is Dictionary and (reply as Dictionary).has("ok"):
			result = (reply as Dictionary).duplicate(true)
		else:
			result = {"ok": false, "reason": REASON_REPLY_INVALID, "detail": String(axis_name)}
	if bool(result.get("ok", false)):
		accepted += 1
	else:
		refused += 1
	last_result = result
	return result
