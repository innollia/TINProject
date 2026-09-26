class_name ProceduralSeed
extends RefCounted

# PURPOSE: single deterministic seed source for every TIN procedural generator.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.
#
# The same (world_seed, id, version) always yields the same `value` on every
# platform and every run. Hashing is done here on purpose: the engine's own
# `hash()` is not a cross-version stability contract.
#
# Draw order matters. `make_rng()` hands out an independent stream; the short
# helpers below share one lazily created stream, so mixing both styles in a
# single build step makes results depend on call order. Kits that need
# order-independent variation must call `make_rng()`.

const DEFAULT_VERSION: int = 1
const FNV_OFFSET_BASIS: int = 2166136261
const FNV_PRIME: int = 16777619
const MASK_32: int = 0xFFFFFFFF
const POSITIVE_MASK_31: int = 0x7FFFFFFF

var world_seed: int = 0
var id: String = ""
var version: int = DEFAULT_VERSION
var value: int = 0

var _rng: RandomNumberGenerator = null


func _init(p_world_seed: int = 0, p_id: String = "", p_version: int = DEFAULT_VERSION) -> void:
	world_seed = p_world_seed
	id = p_id
	version = p_version
	value = hash_int(combine(hash_text(p_id), hash_int(combine(p_world_seed, p_version)))) & POSITIVE_MASK_31


## Order-independent child seed. Path form: "<id>/<sub_id>".
func derive(sub_id: String) -> ProceduralSeed:
	return ProceduralSeed.new(world_seed, id + "/" + sub_id, version)


## Order-independent child seed for a list index.
func derive_index(index: int) -> ProceduralSeed:
	return derive("i" + str(index))


## Fresh independent random stream for this seed.
func make_rng() -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = value
	return rng


func unit() -> float:
	return _stream().randf()


func range_f(from_value: float, to_value: float) -> float:
	var low: float = minf(from_value, to_value)
	var high: float = maxf(from_value, to_value)
	return _stream().randf_range(low, high)


func range_i(from_value: int, to_value: int) -> int:
	var low: int = mini(from_value, to_value)
	var high: int = maxi(from_value, to_value)
	return _stream().randi_range(low, high)


func chance(probability: float) -> bool:
	return _stream().randf() < probability


func sign_f() -> float:
	return 1.0 if chance(0.5) else -1.0


func pick(items: Array) -> Variant:
	if items.is_empty():
		return null
	return items[range_i(0, items.size() - 1)]


static func hash_text(text: String) -> int:
	var h: int = FNV_OFFSET_BASIS
	var index: int = 0
	while index < text.length():
		h = (((h ^ text.unicode_at(index)) & MASK_32) * FNV_PRIME) & MASK_32
		index += 1
	return _finalize(h)


static func hash_int(source: int) -> int:
	return _finalize(source & MASK_32)


## Order-sensitive blend of two integers into one 32 bit digest.
static func combine(first: int, second: int) -> int:
	var h: int = FNV_OFFSET_BASIS
	h = (((h ^ (first & MASK_32)) & MASK_32) * FNV_PRIME) & MASK_32
	h = (((h ^ (second & MASK_32)) & MASK_32) * FNV_PRIME) & MASK_32
	return _finalize(h)


## Order-sensitive mixing step used for progressive combination.
static func mix(first: int, second: int) -> int:
	var a: int = first & MASK_32
	var b: int = second & MASK_32
	return _finalize(a ^ (b + 0x9E3779B9 + (a << 6) + (a >> 2)))


func _stream() -> RandomNumberGenerator:
	if _rng == null:
		_rng = make_rng()
	return _rng


static func _finalize(value: int) -> int:
	var h: int = value & POSITIVE_MASK_31
	h = ((h ^ (h >> 16)) * 0x85EBCA6B) & MASK_32
	h = h & POSITIVE_MASK_31
	h = ((h ^ (h >> 13)) * 0xC2B2AE35) & MASK_32
	h = h & POSITIVE_MASK_31
	return (h ^ (h >> 16)) & MASK_32
