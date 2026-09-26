class_name StoneStoryCore
extends RefCounted

## 결정론 RNG. 이 Kit 은 randf()/randi()/Time.get_ticks_* 를 쓰지 않는다.

const MASK: int = 0x7FFFFFFF

const TAG_TERRAIN := "region.terrain"
const TAG_OBSTACLE := "region.obstacle"
const TAG_FOE_POOL := "region.foe_pool"
const TAG_FOE_PLACE := "region.foe_place"
const TAG_FOE_SCALE := "region.foe_scale"
const TAG_DROP := "region.drop"
const TAG_SHOP := "shop.stock"
const TAG_AFFIX_UPGRADE := "affix.upgrade"
const TAG_AFFIX_LEFT := "affix.left"
const TAG_AFFIX_RIGHT := "affix.right"
const TAG_AFFIX_BOOST := "affix.boost"
const TAG_RECIPE := "recipe.craft"
const TAG_TEXTURE := "texture"
const TAG_SIM := "sim.roll"
const TAG_SURPRISE := "surprise"

const STREAM_SIZE: int = 48


static func mix(a: int, b: int) -> int:
	var x: int = (a ^ (b * 0x9E3779B1)) & MASK
	x = ((x ^ (x >> 15)) * 0x2545F491) & MASK
	x = ((x ^ (x >> 13)) * 0x27220A95) & MASK
	return (x ^ (x >> 16)) & MASK


static func text_hash(s: String) -> int:
	var h: int = 2166136261
	for i in s.length():
		h = (h ^ s.unicode_at(i)) & 0xFFFFFFFF
		h = (h * 16777619) & 0xFFFFFFFF
	return h & MASK


## 상태가 없는 스트림. 재생성 가능. 순서 소비만 한다.
static func stream(seed_value: int, tag: String) -> PackedInt64Array:
	var s: int = mix(seed_value, text_hash(tag))
	var out := PackedInt64Array()
	out.resize(STREAM_SIZE)
	for i in STREAM_SIZE:
		s = (s ^ (s << 13)) & MASK
		s = (s >> 17) & MASK
		s = (s ^ (s << 5)) & MASK
		out[i] = s
	return out


static func at(st: PackedInt64Array, index: int) -> int:
	if st.is_empty():
		return 0
	return st[index % st.size()]


static func unit(st: PackedInt64Array, index: int) -> float:
	return float(at(st, index)) / float(MASK)


static func range_int(st: PackedInt64Array, index: int, lo: int, hi: int) -> int:
	if hi <= lo:
		return lo
	return lo + (at(st, index) % (hi - lo + 1))


static func weighted(st: PackedInt64Array, index: int, weights: Dictionary) -> Variant:
	var total: int = 0
	for k in weights:
		total += int(weights[k])
	if total <= 0:
		return null
	var roll: int = at(st, index) % total
	var acc: int = 0
	for k in weights:
		acc += int(weights[k])
		if roll < acc:
			return k
	return null


# --- 소프트캡 -------------------------------------------------------

static func effective(value: int, knee_a: float, knee_b: float, slope_b: float, slope_c: float) -> float:
	if value <= knee_a:
		return float(value)
	var at_knee_b: float = knee_a + (knee_b - knee_a) * slope_b
	if value <= knee_b:
		return knee_a + (value - knee_a) * slope_b
	return at_knee_b + (value - knee_b) * slope_c


static func normalizer(knee_a: float, knee_b: float, slope_b: float, slope_c: float) -> float:
	return effective(int(knee_b), knee_a, knee_b, slope_b, slope_c)
