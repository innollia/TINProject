class_name ProceduralNoiseField
extends RefCounted

# PURPOSE: deterministic wrapper over FastNoiseLite. Holds the frozen named
# field presets (phase / frequency / octaves) so no Kit invents its own values.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.
#
# Sample coordinates and `phase` are both in PIXEL space; the wrapper applies
# `frequency` itself so `frequency` stays a plain field of this class and
# scrolling is a phase offset instead of a new noise instance.
#
# `sample` returns -1..1. Channels: x = shape/fbm, y = ridged detail,
# z = flow. Same (seed, field) always returns the same values.

const FIELD_SHAPE: StringName = &"shape"
const FIELD_DETAIL: StringName = &"detail"
const FIELD_FLOW: StringName = &"flow"
const FIELD_SQUISH: StringName = &"squish"

const DEFAULT_FREQUENCY: float = 0.01
const DEFAULT_OCTAVES: int = 3
const DEFAULT_LACUNARITY: float = 2.0
const DEFAULT_GAIN: float = 0.5

const SALT_DETAIL: int = 0x1F123BB5
const SALT_FLOW: int = 0x2C1B3C6D

const PRESETS: Dictionary = {
	FIELD_SHAPE: {
		"frequency": 0.0035, "octaves": 2, "lacunarity": 2.0, "gain": 0.5,
		"fractal": &"fbm", "noise_type": &"simplex_smooth", "ridged": false,
	},
	FIELD_DETAIL: {
		"frequency": 0.014, "octaves": 4, "lacunarity": 2.0, "gain": 0.5,
		"fractal": &"fbm", "noise_type": &"simplex", "ridged": true,
	},
	FIELD_FLOW: {
		"frequency": 0.006, "octaves": 3, "lacunarity": 2.1, "gain": 0.45,
		"fractal": &"fbm", "noise_type": &"perlin", "ridged": false,
	},
	FIELD_SQUISH: {
		"frequency": 0.009, "octaves": 2, "lacunarity": 2.0, "gain": 0.55,
		"fractal": &"fbm", "noise_type": &"simplex", "ridged": true,
	},
}

var field: StringName = FIELD_DETAIL
var frequency: float = DEFAULT_FREQUENCY
var octaves: int = DEFAULT_OCTAVES
var lacunarity: float = DEFAULT_LACUNARITY
var gain: float = DEFAULT_GAIN
var ridged: bool = false

var _phase: Vector2 = Vector2.ZERO
var _primary: FastNoiseLite = null
var _secondary: FastNoiseLite = null
var _tertiary: FastNoiseLite = null


func _init(p_seed: int = 0, p_field: StringName = FIELD_DETAIL) -> void:
	configure(p_seed, p_field)


## Rebinds the noise to a seed and to one of the named presets.
func configure(p_seed: int, p_field: StringName = FIELD_DETAIL) -> void:
	field = p_field if PRESETS.has(p_field) else FIELD_DETAIL
	var preset: Dictionary = PRESETS[field]
	frequency = float(preset["frequency"])
	octaves = int(preset["octaves"])
	lacunarity = float(preset["lacunarity"])
	gain = float(preset["gain"])
	ridged = bool(preset["ridged"])
	var fractal_name: StringName = StringName(preset["fractal"])
	var noise_name: StringName = StringName(preset["noise_type"])
	_primary = _make_noise(p_seed, fractal_name, noise_name, false)
	_secondary = _make_noise(ProceduralSeed.mix(p_seed, SALT_DETAIL), fractal_name, noise_name, ridged)
	_tertiary = _make_noise(ProceduralSeed.mix(p_seed, SALT_FLOW), fractal_name, noise_name, false)
	_phase = Vector2.ZERO


func set_phase(phase: Vector2) -> void:
	_phase = phase


func get_phase() -> Vector2:
	return _phase


## Scrolls the field. `speed` is in pixel units per second.
func advance(delta: float, speed: Vector2) -> void:
	_phase += speed * delta


## Primary channel, -1..1.
func sample(x: float, y: float) -> float:
	return _primary.get_noise_2d(x * frequency + _phase.x, y * frequency + _phase.y)


## Primary + ridged detail channels.
func sample_v(x: float, y: float) -> Vector2:
	var sx: float = x * frequency + _phase.x
	var sy: float = y * frequency + _phase.y
	return Vector2(_primary.get_noise_2d(sx, sy), _secondary.get_noise_2d(sx, sy))


## x = shape, y = ridged detail, z = flow.
func sample3(x: float, y: float) -> Vector3:
	var sx: float = x * frequency + _phase.x
	var sy: float = y * frequency + _phase.y
	return Vector3(
		_primary.get_noise_2d(sx, sy),
		_secondary.get_noise_2d(sx, sy),
		_tertiary.get_noise_2d(sx, sy)
	)


func _make_noise(p_seed: int, fractal_name: StringName, noise_name: StringName, use_ridged: bool) -> FastNoiseLite:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.noise_type = _noise_type_of(noise_name)
	noise.seed = ProceduralSeed.hash_int(p_seed) & ProceduralSeed.POSITIVE_MASK_31
	noise.frequency = 1.0
	noise.fractal_type = _fractal_type_of(fractal_name, use_ridged)
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	noise.fractal_gain = gain
	noise.domain_warp_enabled = false
	return noise


func _fractal_type_of(fractal_name: StringName, use_ridged: bool) -> int:
	if use_ridged:
		return FastNoiseLite.FRACTAL_RIDGED
	match fractal_name:
		&"none":
			return FastNoiseLite.FRACTAL_NONE
		&"ridged":
			return FastNoiseLite.FRACTAL_RIDGED
		_:
			return FastNoiseLite.FRACTAL_FBM


func _noise_type_of(noise_name: StringName) -> int:
	match noise_name:
		&"simplex":
			return FastNoiseLite.TYPE_SIMPLEX
		&"simplex_smooth":
			return FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		&"perlin":
			return FastNoiseLite.TYPE_PERLIN
		&"cellular":
			return FastNoiseLite.TYPE_CELLULAR
		&"value_cubic":
			return FastNoiseLite.TYPE_VALUE_CUBIC
		_:
			return FastNoiseLite.TYPE_VALUE
