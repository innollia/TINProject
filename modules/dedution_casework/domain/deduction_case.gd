class_name DeductionCaseDefinition
extends Resource

@export var case_id: StringName
@export var title: String = ""
@export var scene_ids: Array[StringName] = []
@export var scene_names: Array[String] = []
@export var findings: Array[String] = []
@export var details: Array[String] = []
@export var event_ids: Array[StringName] = []
@export var event_names: Array[String] = []
@export var timeline_solution: Array[StringName] = []
@export var answer_slots: Array[DeductionSlotDefinition] = []
@export var minimum_rechecks: int = 0
@export var solved_text: String = ""
