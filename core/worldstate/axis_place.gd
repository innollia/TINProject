class_name AxisPlace
extends RefCounted

# PURPOSE: 장소 축. authored 지형이며 런타임에서 불변이다. 정본:
# core/worldstate/DESIGN_DECISION.md §2.3, §6. OWNER: W7.
#
#   id             String          place id. 세 Kit이 같은 id를 자기 카메라로 그린다.
#   region_id      String          어디에 붙어 있는가
#   tags           Array[String]   authored 표식
#   requires_body  Dictionary      그 장소가 요구하는 몸 조건. 능력 조건이다.
#
# 이 축에는 쓰기 메서드가 없다. 하나도 없다. create() 는 저장/authoring 경로의
# 팩토리일 뿐이고, WorldState.request_mutation() 은 place 를 인자로 받으면
# 판정을 보지 않고 axis_read_only 로 끝난다. (DESIGN_DECISION §6 거부 규칙)
#
# requires_body 는 카르마식 임계값을 받지 않는다. 축 소유자가 ability 키만 정의한다.
# AxisBody.validate_requirement() 이 유일한 판정기이며, 권한·신분 계열 이름은
# requires_body_not_capability 로 거절된다.
#
# 장면의 현재 위치처럼 변하는 값은 이 축에 넣지 않는다. WorldState 의 커서
# (focus_place_id) 가 그 몫이며, 그것조차 모듈은 뷰로 접근할 수 없다.
#
# 이 클래스는 Node 가 아니다. 씬 트리, Input, InputMap, get_tree, /root,
# autoload 를 쓰지 않는다.

const KEY_OK: StringName = &"ok"
const KEY_REASON: StringName = &"reason"
const KEY_DETAIL: StringName = &"detail"
const KEY_VALUE: StringName = &"value"

const FIELD_REGION_ID: StringName = &"region_id"
const FIELD_TAGS: StringName = &"tags"
const FIELD_REQUIRES_BODY: StringName = &"requires_body"
const FIELDS: Array[StringName] = [FIELD_REGION_ID, FIELD_TAGS, FIELD_REQUIRES_BODY]

var _id: String = ""
var _region_id: String = ""
var _tags: Array[String] = []
var _requires_body: Dictionary = {}


## authoring/복원 경로 전용 팩토리. 모듈은 부를 수 없다.
static func create(p_id: String, data: Variant) -> Dictionary:
	if p_id.is_empty():
		return _fail(&"value_type_invalid", "place id must be a non-empty String")
	if not data is Dictionary:
		return _fail(&"snapshot_malformed", "place record must be a Dictionary")
	var source: Dictionary = data as Dictionary
	for key: Variant in source:
		if not key is String or not FIELDS.has(StringName(key)):
			return _fail(&"key_unknown", String(key))
	var region_id: Variant = source.get(String(FIELD_REGION_ID), "")
	if not region_id is String or (region_id as String).is_empty():
		return _fail(&"value_type_invalid", "region_id must be a non-empty String")
	var tags_source: Variant = source.get(String(FIELD_TAGS), [])
	if not tags_source is Array:
		return _fail(&"value_type_invalid", "tags must be an Array")
	var tags: Array[String] = []
	for tag: Variant in tags_source as Array:
		if not tag is String or (tag as String).is_empty():
			return _fail(&"value_type_invalid", "tags entries must be non-empty String")
		if tags.has(tag as String):
			return _fail(&"value_type_invalid", "duplicate tag " + String(tag))
		tags.append(tag as String)
	var requires_body: Variant = source.get(String(FIELD_REQUIRES_BODY), {})
	var checked: Dictionary = AxisBody.validate_requirement(requires_body)
	if not checked[KEY_OK]:
		return checked
	var place: AxisPlace = AxisPlace.new()
	place._id = p_id
	place._region_id = region_id as String
	place._tags = tags
	place._requires_body = (requires_body as Dictionary).duplicate(true)
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: place}


# ── 읽기 ───────────────────────────────────────────────────────────────────
func get_id() -> String:
	return _id


func get_region_id() -> String:
	return _region_id


func get_tags() -> Array[String]:
	return _tags.duplicate()


func has_tag(tag: String) -> bool:
	return _tags.has(tag)


func get_requires_body() -> Dictionary:
	return _requires_body.duplicate(true)


## 요구 조건이 없는 장소. 이 판단은 요구 사전의 존재 여부만 본다. 몸을 보지 않는다.
func requires_nothing() -> bool:
	return _requires_body.is_empty()


func copy() -> AxisPlace:
	var clone: AxisPlace = AxisPlace.new()
	clone._id = _id
	clone._region_id = _region_id
	clone._tags = _tags.duplicate()
	clone._requires_body = _requires_body.duplicate(true)
	return clone


func to_dictionary() -> Dictionary:
	return {
		String(FIELD_REGION_ID): _region_id,
		String(FIELD_TAGS): _tags.duplicate(),
		String(FIELD_REQUIRES_BODY): _requires_body.duplicate(true),
	}


static func _fail(reason: StringName, detail: String) -> Dictionary:
	return {KEY_OK: false, KEY_REASON: reason, KEY_DETAIL: detail}
