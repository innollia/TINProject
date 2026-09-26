extends RefCounted

const GRAVITY: float = 1400.0
const PHYSICS_HZ: int = 120
const FIXED_DT: float = 1.0 / 120.0
const MAX_FRAME_DT: float = 0.25
const LINEAR_DAMP: float = 0.08
const ANGULAR_DAMP: float = 0.9
const SLEEP_THRESHOLD_LINEAR: float = 4.0
const SLEEP_THRESHOLD_ANGULAR: float = 6.0
const SOLVER_ITERATIONS: int = 24
const CONTACT_RECYCLE_RADIUS: float = 0.5
const MASS_PER_AREA: float = 0.001

const PLAYER_W: float = 32.0
const PLAYER_H: float = 46.0
const PLAYER_DENSITY: float = 0.90
const MOVE_SPEED: float = 196.0
const ACCEL_GROUND: float = 1450.0
const ACCEL_AIR: float = 620.0
const FRICTION_GROUND: float = 0.86
const BOUNCE_PLAYER: float = 0.0
const JUMP_VELOCITY: float = -470.0
const JUMP_CUT: float = 0.42
const COYOTE_TIME: float = 0.10
const JUMP_BUFFER: float = 0.12
const MAX_FALL_SPEED: float = 820.0
const APEX_ASSIST: float = 0.0
const AIR_DRAG: float = 0.9

const GRAB_RADIUS: float = 26.0
const TOOL_COOLDOWN: float = 0.22
const TOOL_THROW_IMPULSE: float = 330.0
const TOOL_THROW_UP: float = -140.0
const TOOL_MAX_HOLD: float = 6.0
const TOOL_HOLD_HINT: float = 0.35
const TOOL_CHARGE_FULL: float = 0.6
const TOOL_CHARGE_BONUS: float = 0.4
const TOOL_SOCKET_FORWARD: float = 14.0
const TOOL_SOCKET_UP: float = 23.0
const TOOL_OWNER_GRACE: float = 0.15
const KNOCK_SPEED: float = 240.0
const KNOCK_GAIN: float = 0.6
const SHOVE_SPEED: float = 380.0
const SHOVE_LIFT: float = 0.25
const ROPE_MAX_LENGTH: float = 260.0
const ROPE_BAUMGARTE: float = 6.0
const FIRE_WAX_FACTOR: float = 2.0

const IMPACT_THRESHOLD: float = 235.0
const IMPACT_DAMAGE_SCALE: float = 0.035
const CLACK_THRESHOLD: float = 300.0
const PLAYER_HP: float = 5.0
const INVULN_TIME: float = 0.65
const HITSTOP: float = 0.055
const HITSTOP_MAX: float = 0.11
const HAZARD_DPS: float = 3.0
const HAZARD_TOUCH_DAMAGE: float = 1.0
const DEAD_RECOVER_DELAY: float = 0.6
const DEBRIS_LIFE: float = 1.2
const DEBRIS_SCALE: float = 0.12
const DEBRIS_SIZE_MIN: float = 0.22
const DEBRIS_SIZE_MAX: float = 0.38
const DEBRIS_ACTIVE_MAX: int = 48
const WAKE_RADIUS_ON_DESTROY: float = 80.0
const OFFMAP_MARGIN: float = 120.0

const LEVEL_COUNT: int = 8
const TOOL_COUNT: int = 8
const MUTATION_CHANCE: float = 0.62
const MUTATION_MAX: int = 2
const OBJECTIVE_MIN: int = 1
const OBJECTIVE_MAX: int = 12
const INTRO_DURATION: float = 0.9
const CLEAR_DURATION: float = 0.9
const CLEAR_FLASH: float = 0.35

const CAM_ZOOM: float = 1.0
const CAM_DEADZONE_X: float = 120.0
const CAM_FOLLOW_SPEED: float = 6.5
const CAM_LOOKAHEAD: float = 58.0
const CAM_Y: float = 288.0
const CAM_SHAKE_DECAY: float = 9.0
const CAM_SHAKE_MAX: float = 6.0
const CAM_BOUNDS_PAD: float = 40.0
const VIEW_W: float = 1280.0
const VIEW_H: float = 720.0

const OBJECTIVE_RESPAWN: float = 2.5
const TOOL_RESPAWN: float = 1.4
const SLEEP_RELAX: float = 3.0
const SLEEP_RELAX_SPEED: float = 4.0
const WAKE_PUSH: float = 40.0

const MAX_LINEAR_VEL: float = 980.0
const MAX_ANGULAR_VEL: float = 18.0
const CONTACT_MAX_REPORTED: int = 8

const WIND_DRIFT: float = 48.0
const WIND_REFERENCE: float = 190.0

const RUN_SEED_MAX: int = 2147483647
const COSMETIC_MUL: int = 2654435761
const COSMETIC_ADD: int = 1013904223
