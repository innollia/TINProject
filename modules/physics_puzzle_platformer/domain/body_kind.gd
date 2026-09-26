extends RefCounted

const PLAYER: int = 1
const TOOL_CARRIED: int = 2
const TOOL_PLACEMENT: int = 3
const OBJECTIVE: int = 4
const PROP_DYNAMIC: int = 5
const PROP_SLEEPING: int = 6
const OBSTACLE_DYNAMIC: int = 7
const DECOR_DYNAMIC: int = 8
const TILE_STATIC: int = 9
const TILE_KINEMATIC: int = 10
const RIFT: int = 11
const HAZARD_STATIC: int = 12
const HAZARD_AREA: int = 13

const ALL: Array[int] = [
	PLAYER, TOOL_CARRIED, TOOL_PLACEMENT, OBJECTIVE, PROP_DYNAMIC, PROP_SLEEPING, OBSTACLE_DYNAMIC,
	DECOR_DYNAMIC, TILE_STATIC, TILE_KINEMATIC, RIFT, HAZARD_STATIC, HAZARD_AREA,
]

const NODE_RIGID: StringName = &"rigid"
const NODE_STATIC: StringName = &"static"
const NODE_KINEMATIC: StringName = &"kinematic"
const NODE_AREA: StringName = &"area"

const INFINITE_HP: float = -1.0

const INFO: Dictionary = {
	PLAYER: {"name": "player", "node": NODE_RIGID, "hp": 5.0, "damageable": true, "breakable": false, "objective": false, "sensor": false, "authored": false},
	TOOL_CARRIED: {"name": "tool_carried", "node": NODE_RIGID, "hp": 3.0, "damageable": true, "breakable": true, "objective": false, "sensor": false, "authored": false},
	TOOL_PLACEMENT: {"name": "tool_placement", "node": NODE_AREA, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": true, "sensor": true, "authored": true},
	OBJECTIVE: {"name": "objective", "node": NODE_RIGID, "hp": 1.0, "damageable": false, "breakable": true, "objective": true, "sensor": false, "authored": true},
	PROP_DYNAMIC: {"name": "prop_dynamic", "node": NODE_RIGID, "hp": 3.0, "damageable": true, "breakable": true, "objective": false, "sensor": false, "authored": true},
	PROP_SLEEPING: {"name": "prop_sleeping", "node": NODE_RIGID, "hp": 3.0, "damageable": true, "breakable": true, "objective": false, "sensor": false, "authored": true},
	OBSTACLE_DYNAMIC: {"name": "obstacle_dynamic", "node": NODE_RIGID, "hp": 6.0, "damageable": true, "breakable": false, "objective": false, "sensor": false, "authored": true},
	DECOR_DYNAMIC: {"name": "decor_dynamic", "node": NODE_RIGID, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": false, "sensor": false, "authored": true},
	TILE_STATIC: {"name": "tile_static", "node": NODE_STATIC, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": false, "sensor": false, "authored": true},
	TILE_KINEMATIC: {"name": "tile_kinematic", "node": NODE_KINEMATIC, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": false, "sensor": false, "authored": true},
	RIFT: {"name": "rift", "node": NODE_AREA, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": true, "sensor": true, "authored": false},
	HAZARD_STATIC: {"name": "hazard_static", "node": NODE_STATIC, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": false, "sensor": false, "authored": true},
	HAZARD_AREA: {"name": "hazard_area", "node": NODE_AREA, "hp": INFINITE_HP, "damageable": false, "breakable": false, "objective": false, "sensor": true, "authored": true},
}

const JOINT_SEGMENTS: int = 5
const JOINT_SEGMENT_LEN: float = 16.0
const JOINT_STIFFNESS: float = 0.85
const JOINT_DAMPING: float = 0.35
const JOINT_BREAK_FORCE: float = 900.0
const JOINT_MAX_LENGTH: float = 80.0


static func is_valid(kind: int) -> bool:
	return INFO.has(kind)


static func info(kind: int) -> Dictionary:
	return INFO.get(kind, {})


static func kind_name(kind: int) -> String:
	return String(info(kind).get("name", ""))


static func from_authored_name(value: String) -> int:
	for kind: int in ALL:
		var entry: Dictionary = INFO[kind]
		if bool(entry["authored"]) and String(entry["name"]) == value:
			return kind
	return 0


static func node_type(kind: int) -> StringName:
	return StringName(info(kind).get("node", &""))


static func is_rigid(kind: int) -> bool:
	return node_type(kind) == NODE_RIGID


static func is_area(kind: int) -> bool:
	return node_type(kind) == NODE_AREA


static func is_solid_static(kind: int) -> bool:
	var node: StringName = node_type(kind)
	return node == NODE_STATIC or node == NODE_KINEMATIC


static func is_hazard(kind: int) -> bool:
	return kind == HAZARD_STATIC or kind == HAZARD_AREA


static func default_hp(kind: int) -> float:
	return float(info(kind).get("hp", INFINITE_HP))


static func is_damageable(kind: int) -> bool:
	return bool(info(kind).get("damageable", false))


static func is_breakable(kind: int) -> bool:
	return bool(info(kind).get("breakable", false))


static func is_mutation_prop(kind: int) -> bool:
	return kind == PROP_DYNAMIC or kind == PROP_SLEEPING or kind == DECOR_DYNAMIC or kind == OBSTACLE_DYNAMIC
