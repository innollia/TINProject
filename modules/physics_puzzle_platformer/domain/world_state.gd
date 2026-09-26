extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const PHASE_INTRO: StringName = &"intro"
const PHASE_PLAY: StringName = &"play"
const PHASE_CLEAR: StringName = &"clear"
const PHASE_DEAD: StringName = &"dead"
const PHASES: Array[StringName] = [PHASE_INTRO, PHASE_PLAY, PHASE_CLEAR, PHASE_DEAD]

var slot: int = 0
var level_id: String = ""
var applied_mutations: Array[Dictionary] = []
var objective_count: int = 0
var objective_needed: int = 2
var objective_total: int = 0
var phase: StringName = PHASE_INTRO
var phase_time: float = 0.0
var player_hp: float = Tuning.PLAYER_HP
var deaths: int = 0
var resets: int = 0
var elapsed: float = 0.0
var kin_time: float = 0.0
var tools_used: int = 0
var hitstop: float = 0.0
var invuln: float = 0.0
var rift_open: bool = false
var bodies: Array = []


func player_index() -> int:
	for index: int in bodies.size():
		if bodies[index].kind == BodyKind.PLAYER:
			return index
	return -1


func player() -> RefCounted:
	var index: int = player_index()
	return bodies[index] if index >= 0 else null


func find(spec_id: String) -> int:
	for index: int in bodies.size():
		if bodies[index].spec_id == spec_id:
			return index
	return -1


func held_tool_index() -> int:
	for index: int in bodies.size():
		var body: RefCounted = bodies[index]
		if body.kind == BodyKind.TOOL_CARRIED and body.held and not body.destroyed:
			return index
	return -1


func is_playing() -> bool:
	return phase == PHASE_PLAY


func set_phase(value: StringName) -> void:
	phase = value if PHASES.has(value) else PHASE_INTRO
	phase_time = 0.0
