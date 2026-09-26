class_name AxisCreature
extends RefCounted

# PURPOSE: 개체 축. 한 개체는 전역 유일 id 로 고정된 개인이다. 정본:
# core/worldstate/DESIGN_DECISION.md §2.2, §4. OWNER: W7.
#
#   id         String              필수. 전역 유일. 이 라운드에서 유일. 바꿀 수 없다.
#   archetype  String              종/유형. 생성자가 정한다. 새 개체의 생성에 필수.
#   stage      int                 lineage 단계
#   state      String              살아있음/사망 등 authored 값
#   traits     Dictionary          성격·공포·욕구 등 난수에서 고정된 것
#   memory     Array[Dictionary]  이 개체가 기억하는 사건 목록
#   den        String              은신처 장소 id
#
# memory 는 점수판이 아니다. "이 몸이 세 번 죽었다" 를 계산하지 않는다. 이 축은
# 기억의 개수·합·점수를 어떤 이름으로도 노출하지 않는다. append 는 배열 전체를
# 다시 쓰는 것으로 한다 (patch.memory = get_memory() + [event]). 개수가 세는
# 것이 아니라, 사건이 쌓이는 것이 유일한 변화다.
#
# den 은 authored id 다. 이 축은 장소 존재 여부를 해석하지 않는다. stale content
# id 정책은 Kit 계획서의 몫이다. (DESIGN_DECISION §2.2, CODE_STYLE 저장)
#
# 이 클래스는 Node 가 아니다. 씬 트리, Input, InputMap, get_tree, /root,
# autoload 를 쓰지 않는다.

const KEY_OK: StringName = &"ok"
const KEY_REASON: StringName = &"reason"
const KEY_DETAIL: StringName = &"detail"
const KEY_VALUE: StringName = &"value"

const FIELD_ID: StringName = &"id"
const FIELD_ARCHETYPE: StringName = &"archetype"
const FIELD_STAGE: StringName = &"stage"
const FIELD_STATE: StringName = &"state"
const FIELD_TRAITS: StringName = &"traits"
const FIELD_MEMORY: StringName = &"memory"
const FIELD_DEN: StringName = &"den"

## 직렬화 순서. id 가 맨 앞.
const FIELDS: Array[StringName] = [FIELD_ARCHETYPE, FIELD_STAGE, FIELD_STATE, FIELD_TRAITS, FIELD_MEMORY, FIELD_DEN]

var _fields: Dictionary = {}


func get_id() -> String:
	return String(_fields.get(String(FIELD_ID), ""))


# ── 읽기 ───────────────────────────────────────────────────────────────────
## 없는 필드는 null 이다. 기본값을 만들지 않는다.
func get_archetype() -> Variant:
	return _copy(_fields.get(String(FIELD_ARCHETYPE)))


func get_stage() -> Variant:
	return _copy(_fields.get(String(FIELD_STAGE)))


func get_state() -> Variant:
	return _copy(_fields.get(String(FIELD_STATE)))


func get_traits() -> Variant:
	return _copy(_fields.get(String(FIELD_TRAITS)))


func get_memory() -> Variant:
	var value: Variant = _fields.get(String(FIELD_MEMORY))
	if value == null:
		return null
	return (value as Array[Dictionary]).duplicate(true)


func get_den() -> Variant:
	return _copy(_fields.get(String(FIELD_DEN)))


## 기억에 있는 사건들. substring 은 이벤트가 가진 String 값을 담는다.
## 점수도 합계도 내지 않는다. 답은 예/아니오뿐이다.
func remembers(match: Dictionary) -> bool:
	var memory: Variant = get_memory()
	if memory == null:
		return false
	for event: Dictionary in memory as Array[Dictionary]:
		var hit: bool = true
		for key: Variant in match:
			if not event.has(key) or event[key] != match[key]:
				hit = false
				break
		if hit:
			return true
	return false


# ── 쓰기 ───────────────────────────────────────────────────────────────────
## 전체 적용. id 를 요구하고, 전역 유일성은 WorldState 가 판정한다. 몸과 달리
## 개체에는 신분 필드가 있으므로 이 호출이 전체와 부분 적용을 모두 겸한다. 없는
## 키는 없는 채로 남고, 실패하면 아무것도 바뀌지 않는다. WorldState 는 새 개인의
## 생성과 기존 개인의 갱신을 이 한 경로로만 태운다.
##
## 부분 적용이므로 화려한 값 하나를 고쳐도 화려하지 않은 값은 그대로 남는다.
func apply(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return _fail(&"patch_not_dictionary", "creature record must be a Dictionary")
	var source: Dictionary = data as Dictionary
	if not source.has(String(FIELD_ID)):
		return _fail(&"creature_id_invalid", "creature record needs an id")
	var checked_id: Dictionary = _validate_field(FIELD_ID, source[FIELD_ID])
	if not checked_id[KEY_OK]:
		return checked_id
	if _fields.has(String(FIELD_ID)) and (checked_id[KEY_VALUE] as String) != (get_id() as String):
		## 이 호출은 갱신 경로다. id 가 다르면 다른 개인이다. 같은 개인을 두 이름으로
		## 부르는 일은 없다. (DESIGN_DECISION §2.2)
		return _fail(&"creature_id_invalid", String(checked_id[KEY_VALUE]))
	var staged: Dictionary = _fields.duplicate(true)
	staged[String(FIELD_ID)] = checked_id[KEY_VALUE]
	var allowed: Array[StringName] = [FIELD_ID]
	allowed.append_array(FIELDS)
	var fault: Dictionary = _stage_fields(source, staged, allowed)
	if not fault.is_empty():
		return fault
	_fields = staged
	return _pass()


func copy() -> AxisCreature:
	var clone: AxisCreature = AxisCreature.new()
	clone._fields = _fields.duplicate(true)
	return clone


func to_dictionary() -> Dictionary:
	var out: Dictionary = {}
	for name: StringName in [FIELD_ID] + FIELDS:
		if _fields.has(String(name)):
			out[String(name)] = AxisBody._plain(_fields[String(name)])
	return out


# ── 검증 ───────────────────────────────────────────────────────────────────
func _stage_fields(source: Dictionary, staged: Dictionary, allowed: Array[StringName]) -> Dictionary:
	for key: Variant in source:
		if not key is String:
			return _fail(&"value_type_invalid", "creature keys must be String")
		if not allowed.has(StringName(key)):
			return _fail(&"key_unknown", String(key))
		var checked: Dictionary = _validate_field(StringName(key), source[key])
		if not checked[KEY_OK]:
			return checked
		staged[String(key)] = checked[KEY_VALUE]
	return {}


func _validate_field(name: StringName, value: Variant) -> Dictionary:
	match name:
		FIELD_ID:
			if not value is String or (value as String).is_empty():
				return _fail(&"creature_id_invalid", "id must be a non-empty String")
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: value}
		FIELD_ARCHETYPE, FIELD_STATE, FIELD_DEN:
			if not value is String or (value as String).is_empty():
				return _fail(&"value_type_invalid", String(name) + " must be a non-empty String")
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: value}
		FIELD_STAGE:
			if not value is int and not value is float:
				return _fail(&"value_type_invalid", "stage must be a number")
			if value is float and not is_finite(value as float):
				return _fail(&"value_not_finite", "stage")
			if value is float and (value as float) != floorf(value as float):
				return _fail(&"value_type_invalid", "stage must be a whole number")
			## stage 는 계약상 정수 필드다. 2.0 을 2 로 만드는 것은 값 이동이 아니라
			## 선언된 필드 타입에 맞춘 것이다. (CONTRACT AxisCreature.FIELD_STAGE)
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: int(value)}
		FIELD_TRAITS:
			if not value is Dictionary:
				return _fail(&"value_type_invalid", "traits must be a Dictionary")
			var staged: Dictionary = _stage_open(value as Dictionary)
			if not staged[KEY_OK]:
				return staged
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: staged[KEY_VALUE]}
		FIELD_MEMORY:
			if not value is Array:
				return _fail(&"memory_is_event_list", "memory must be an Array of event dictionaries")
			var events: Array[Dictionary] = []
			for entry: Variant in value as Array:
				if not entry is Dictionary:
					return _fail(&"memory_is_event_list", "a memory entry is not an event")
				if (entry as Dictionary).is_empty():
					return _fail(&"memory_entry_empty", "a memory entry is empty")
				var staged_event: Dictionary = _stage_open(entry as Dictionary)
				if not staged_event[KEY_OK]:
					return staged_event
				events.append(staged_event[KEY_VALUE])
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: events}
	return _fail(&"key_unknown", String(name))


## 열린 사실 사전. 모든 값을 JSON-safe 로 만들고 배선 형식을 복원한다.
## memory 는 사건 목록이라 숫자·점수가 자리에 들면 거절된다. (DESIGN_DECISION §2.2)
func _stage_open(source: Dictionary) -> Dictionary:
	var staged: Dictionary = {}
	for key: Variant in source:
		if not key is String:
			return _fail(&"value_type_invalid", "fact keys must be String")
		var value: Variant = source[key]
		if value is float and not is_finite(value as float):
			return _fail(&"value_not_finite", String(key))
		if not AxisBody.is_json_safe(value):
			return _fail(&"value_not_json_safe", String(key))
		staged[String(key)] = AxisBody._wire_value(value)
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: staged}


static func _copy(value: Variant) -> Variant:
	return AxisBody._plain(value)


static func _pass() -> Dictionary:
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: ""}


static func _fail(reason: StringName, detail: String) -> Dictionary:
	return {KEY_OK: false, KEY_REASON: reason, KEY_DETAIL: detail}
