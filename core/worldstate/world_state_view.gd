class_name WorldStateView
extends RefCounted

# PURPOSE: 모듈에 건네는 읽기 전용 핸들. 정본:
# core/worldstate/DESIGN_DECISION.md §3. OWNER: W7.
#
# 구조적으로 못 쓰게 만든다. 이 뷰는 WorldState 를 참조하지 않는다. 스냅샷
# 사본 하나만 들고, 스토어는 그 사본을 밀어 넣기만 한다. 스토어는 뷰에서 읽지
# 않는다. 그래서 모듈이 리플렉션으로 뷰를 어떻게 다루어도 원본에 닿는 경로가
# 없다. (값 복사가 아니라 참조로 전달된다는 §3 규칙과도 모순되지 않는다:
# 전달되는 것은 스토어의 참조가 아니라 그 스냅샷을 들고 있는 뷰다)
#
# get_* 는 전부 새 인스턴스를 만든다. 모듈이 받은 AxisBody 에 apply() 를 불러도
# 스토어의 사본과 원본은 그대로다. 그리고 이 클래스에는 위조 메서드가 하나도 없다.
# set/add/remove/apply/write/load/focus/refresh 같은 이름은 존재하지 않는다.
#
# 쓰기를 원하면 모듈은 WorldState.request_mutation() 을 호출해야 하고, 그것은
# ModuleContext.arrival 에 들어 있지 않다. 모듈이 가진 것으로는 호출할 수 없다.
#
# 이 클래스는 Node 가 아니다. 씬 트리, Input, InputMap, get_tree, /root,
# autoload 를 쓰지 않는다.

const KEY_OK: StringName = &"ok"
const KEY_REASON: StringName = &"reason"
const KEY_DETAIL: StringName = &"detail"
const KEY_SATISFIED: StringName = &"satisfied"
const KEY_UNMET: StringName = &"unmet"

## 스냅샷을 만든 스토어의 축 이름 문자열. 뷰 밖에서 읽을 일이 없다.
const _STORE_VERSION: String = "ax"
const _BODY: String = "body"
const _CREATURES: String = "creatures"
const _PLACES: String = "places"
const _FOCUS: String = "focus_place_id"

var _snapshot: Dictionary = {}


## arrival 에 뷰가 없으면 null 이다. 모듈은 "없음"을 처리하거나 멈춘다.
static func from_arrival(arrival: Dictionary) -> WorldStateView:
	var carried: Variant = arrival.get(WorldState.ARRIVAL_KEY)
	if not carried is WorldStateView:
		return null
	return carried


## 스토어 전용. 갱신된 스냅샷을 밀어 넣는다. 중첩 값은 전부 복사된다.
func _refresh(snapshot: Dictionary) -> void:
	_snapshot = snapshot.duplicate(true)


# ── 읽기 ───────────────────────────────────────────────────────────────────
func get_store_version() -> int:
	return int(_snapshot.get(_STORE_VERSION, 0))


## 몸이 아직 없다. 없는 것은 기본 몸이 아니다.
func has_body() -> bool:
	return _snapshot.has(_BODY)


## 없는 축은 null 이다. 빈 몸을 지어내지 않는다.
func get_body() -> AxisBody:
	if not has_body():
		return null
	var body: AxisBody = AxisBody.new()
	if not body.apply((_snapshot[_BODY] as Dictionary).duplicate(true))[WorldState.KEY_OK]:
		return null
	return body


func get_creature_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in _snapshot.get(_CREATURES, {}):
		ids.append(String(key))
	ids.sort()
	return ids


func has_creature(id: String) -> bool:
	return (_snapshot.get(_CREATURES, {}) as Dictionary).has(id)


## 없는 id 는 null 이다. 새 AxisCreature 를 지어내지 않는다. 되돌릴 수 없는
## 기록이면 조용히 빈 개체를 내주지 않고 null 로 말한다. (§7 정직한 실패)
func get_creature(id: String) -> AxisCreature:
	if not has_creature(id):
		return null
	var creature: AxisCreature = AxisCreature.new()
	if not creature.apply(((_snapshot[_CREATURES] as Dictionary)[id] as Dictionary).duplicate(true))[WorldState.KEY_OK]:
		return null
	return creature


func get_place_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in _snapshot.get(_PLACES, {}):
		ids.append(String(key))
	ids.sort()
	return ids


func has_place(id: String) -> bool:
	return (_snapshot.get(_PLACES, {}) as Dictionary).has(id)


func get_place(id: String) -> AxisPlace:
	if not has_place(id):
		return null
	var built: Dictionary = AxisPlace.create(id, ((_snapshot[_PLACES] as Dictionary)[id] as Dictionary).duplicate(true))
	if not built[KEY_OK]:
		return null
	return built[WorldState.KEY_VALUE]


func get_focus_place_id() -> String:
	return String(_snapshot.get(_FOCUS, ""))


## DESIGN_DECISION §5 장면 A 판정 테스트. 장소가 요구하는 몸 조건을 이 몸이
## 만족하는지. 미충족 항목이 남으면 이름으로 온다. 없는 값은 없는 것으로 판정한다.
func body_satisfies(place_id: String) -> Dictionary:
	if not has_place(place_id):
		return {KEY_OK: false, KEY_REASON: WorldState.REASON_PLACE_UNKNOWN, KEY_DETAIL: place_id, KEY_SATISFIED: false, KEY_UNMET: [] as Array[String]}
	if not has_body():
		return {KEY_OK: false, KEY_REASON: WorldState.REASON_AXIS_ABSENT, KEY_DETAIL: _BODY, KEY_SATISFIED: false, KEY_UNMET: [] as Array[String]}
	return get_body().satisfies(get_place(place_id).get_requires_body())


## 모듈 자신의 저장 뷰. 이 사본을 저장해도 원본은 안 바뀐다.
func to_dictionary() -> Dictionary:
	return _snapshot.duplicate(true)
