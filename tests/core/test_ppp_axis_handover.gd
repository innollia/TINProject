extends GutTest

const AxisMutation = preload("res://modules/physics_puzzle_platformer/systems/axis_mutation.gd")
const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")

const REQUESTER: StringName = &"physics_puzzle_platformer"


class FakeStore:
	extends RefCounted
	var calls: Array = []
	var reply: Variant = {"ok": false, "reason": "requester_not_owner", "detail": ""}

	func request_mutation(axis_name: StringName, patch: Variant, requester: StringName) -> Variant:
		calls.append([axis_name, patch, requester])
		return reply


func test_request_without_store_is_refused_quietly() -> void:
	var writer: RefCounted = AxisMutation.new().bind(null, REQUESTER)
	var result: Dictionary = writer.request(&"body", {"missing": ["left_arm"]})
	assert_false(bool(result["ok"]))
	assert_eq(String(result["reason"]), AxisMutation.REASON_STORE_ABSENT)
	assert_eq(writer.refused, 1)
	assert_eq(writer.accepted, 0)


func test_refusal_is_returned_and_patch_is_copied() -> void:
	var store := FakeStore.new()
	var writer: RefCounted = AxisMutation.new().bind(store, REQUESTER)
	var patch: Dictionary = {"missing": ["left_arm"]}
	var result: Dictionary = writer.request(&"body", patch)
	assert_false(bool(result["ok"]))
	assert_eq(String(result["reason"]), "requester_not_owner")
	assert_eq(store.calls.size(), 1)
	assert_eq(store.calls[0][2], REQUESTER, "requester id is the module id")
	(store.calls[0][1] as Dictionary)["missing"].append("right_arm")
	assert_eq(patch["missing"], ["left_arm"], "the caller's patch is never shared with the store")


func test_accepted_reply_passes_through() -> void:
	var store := FakeStore.new()
	store.reply = {"ok": true, "reason": "", "detail": ""}
	var writer: RefCounted = AxisMutation.new().bind(store, REQUESTER)
	assert_true(bool(writer.request(&"creature", {"state": "dead"})["ok"]))
	assert_eq(writer.accepted, 1)


func test_malformed_reply_is_a_refusal() -> void:
	var store := FakeStore.new()
	store.reply = 7
	var writer: RefCounted = AxisMutation.new().bind(store, REQUESTER)
	assert_eq(String(writer.request(&"body", {"scale": 0.62})["reason"]), AxisMutation.REASON_REPLY_INVALID)


func test_module_refusal_leaves_world_untouched() -> void:
	var module: Node = ENTRY.instantiate()
	add_child(module)
	var context := ModuleContext.new()
	context.module_id = REQUESTER
	module.load_state({})
	module.enter(context)
	var before: Dictionary = module.save_state()
	var result: Dictionary = module.request_axis_mutation(&"body", {"missing": ["left_arm"]})
	assert_false(bool(result["ok"]))
	assert_eq(JSON.stringify(module.save_state()), JSON.stringify(before), "a refused request changes no saved field")
	module.exit()
	remove_child(module)
	module.free()
