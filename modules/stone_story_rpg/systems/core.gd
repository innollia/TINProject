class_name StoneStoryCore
extends RefCounted

## 이 Kit 이 쓰는 난수 팩토리와 소프트캡 곡선.
## 발생기는 전부 ProceduralSeed 위다 (systems/rng.gd).

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


static func stream(world_seed: int, tag: String) -> StoneStoryRng:
	return StoneStoryRng.new(world_seed, tag)


# --- 소프트캡 -------------------------------------------------------
## 세 번째 구간은 knee_b 가 아니라 at_knee_b(출력값)에서 이어진다.
## knee_b 에서 이어 쓰면 1 스텝에 +25 가 들어가는 불연속이 생긴다.

static func effective(value: int, knee_a: float, knee_b: float, slope_b: float, slope_c: float) -> float:
	if value <= knee_a:
		return float(value)
	var at_knee_b: float = knee_a + (knee_b - knee_a) * slope_b
	if value <= knee_b:
		return knee_a + (value - knee_a) * slope_b
	return at_knee_b + (value - knee_b) * slope_c


static func normalizer(knee_a: float, knee_b: float, slope_b: float, slope_c: float) -> float:
	return effective(int(knee_b), knee_a, knee_b, slope_b, slope_c)
