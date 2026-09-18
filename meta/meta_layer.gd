extends Node

signal narration_changed(text: String)

const TEXT: Dictionary = {
	"module_entered": "%s 준비 완료 · 완료 횟수 %d",
	"module_finished": "%s 결과: %s · 전체 완료 횟수 %d",
}

var completion_counts: Dictionary = {}
var last_module: String = ""
var last_outcome: String = ""


func restore(global_state: Dictionary) -> void:
	completion_counts.clear()
	last_module = ""
	last_outcome = ""
	var stored: Variant = global_state.get("progression", {})
	if not stored is Dictionary:
		return
	var progression: Dictionary = stored
	var counts: Variant = progression.get("completion_counts", {})
	if counts is Dictionary:
		for id: Variant in counts:
			var count: Variant = counts[id]
			if count is int or count is float:
				completion_counts[String(id)] = maxi(0, int(count))
	last_module = str(progression.get("last_module", ""))
	last_outcome = str(progression.get("last_outcome", ""))


func capture(global_state: Dictionary) -> Dictionary:
	var state: Dictionary = global_state.duplicate(true)
	state["progression"] = {
		"completion_counts": completion_counts.duplicate(true),
		"last_module": last_module,
		"last_outcome": last_outcome,
	}
	return state


func describe_module(id: StringName, display_name: String) -> void:
	var count: int = int(completion_counts.get(String(id), 0))
	narration_changed.emit(TEXT["module_entered"] % [display_name, count])


func record_result(result: ModuleResult) -> void:
	last_module = String(result.module_id)
	last_outcome = String(result.outcome)
	completion_counts[last_module] = int(completion_counts.get(last_module, 0)) + 1
	var total: int = 0
	for count: Variant in completion_counts.values():
		total += int(count)
	narration_changed.emit(TEXT["module_finished"] % [last_module, last_outcome, total])
