class_name StoneStoryRng
extends RefCounted

## 결정론 난수. 손으로 만든 발생기를 두지 않는다.
## PVE 의 ProceduralSeed 를 그대로 쓴다. 그 구현은 동결 계약이고 시험이 있다.
## index 마다 derive_index 로 자식 시드를 뽑으므로 **호출 순서와 무관**하다.

var _s: ProceduralSeed


func _init(world_seed: int, tag: String) -> void:
	_s = ProceduralSeed.new(world_seed, tag, Procedural.ENGINE_VERSION)


func child(index: int) -> ProceduralSeed:
	return _s.derive_index(index)


func at(index: int) -> int:
	return _s.derive_index(index).range_i(0, 0x3FFFFFFF)


func unit(index: int) -> float:
	return _s.derive_index(index).unit()


func range_int(index: int, lo: int, hi: int) -> int:
	if hi <= lo:
		return lo
	return _s.derive_index(index).range_i(lo, hi)


func chance(index: int, probability: float) -> bool:
	return _s.derive_index(index).chance(probability)


func weighted(index: int, weights: Dictionary) -> Variant:
	var total: int = 0
	for k in weights:
		total += int(weights[k])
	if total <= 0:
		return null
	var roll: int = _s.derive_index(index).range_i(0, total - 1)
	var acc: int = 0
	for k in weights:
		acc += int(weights[k])
		if roll < acc:
			return k
	return null
