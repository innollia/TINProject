class_name AxisBody
extends RefCounted

# PURPOSE: 플레이어 몸 축. 관측 가능한 사실만 저장하고 파생 요약을 저장하지
# 않는다. 정본: core/worldstate/DESIGN_DECISION.md §2.1, §2.1.1, §2.1.2, §2.1.3, §4. OWNER: W7.
#
# 필드는 네 개뿐이다.
#   missing  Array[String]      없는 부위. 부재는 사실이다.
#   wounds   Array[Dictionary]  { part, kind, severity, permanent }
#   scale    number             몸 스케일. 상수가 아니다. 정규화 금지.
#   facts    Dictionary         Kit 물리 규칙이 쓰는 관측 값 (선택). "scale" 키는 닫힘.
#
# 필드는 두 부류로 나뉜다. 섞지 않는다. (DESIGN_DECISION §2.1.1)
#   확정 사실 (진행 축)  missing, wounds. 기록된 사실은 지워지지 않는다.
#   가변 능력 (능력 축)  scale. 되돌아간다.
#   판정 불가            facts. Kit 이 자기 기준으로 적은 관측값이다. 확정 사실로
#                       부르면 Kit 이 자기 관측을 못 고치고, 가변 능력으로 부르면
#                       관측값이 통과 조건이 된다. 정직한 답은 "스토어의 일이 아니다".
#
# scale 은 닫힌 6단 사다리 값이다. 연속 실수가 아니다. (DESIGN_DECISION §2.1.2)
#
# 몸의 크기는 한 곳에만 산다. facts 안의 "scale" 키는 닫혔다. 그 이름은 최상위
# scale 필드가 이미 차지한 이름이고, 두 번째로 쓰면 사다리를 우회하는 크기 채널이
# 하나 더 생긴다. 그래서 그 키가 이름으로 쓰이는 쓰기는 key_unknown 으로 거절한다.
# (DESIGN_DECISION §2.1.3) 이 검사는 _validate_facts 에 있고, 거기로 오는 길이
# apply / check_mutation / request_mutation / load_snapshot / load_json / 뷰 재생성
# 뿐이다. 즉 입구 하나가 막히고 나머지는 증인이 아니라 같은 입구다.
#
# 없는 필드는 없는 키로 남는다. 기본값을 만들지 않는다. 그래서 get_* 는 없는
# 필드에 null 을 돌려준다. "없음"과 "아무것도 없음"을 구분하는 방법은 has_* 다.
# (DESIGN_DECISION §4)
#
# 체력 200 인 몸이 통상 1~3 문법 구간에서 피해 1을 받으면 199 다. 이 축은 그
# 값을 환산하지 않고 범위로 누르지 않는다. 요약값(health, hp, karma, score,
# health_fraction ...)은 어떤 키로도 들어올 수 없다. 저장 주인이 권한다.
#
# 이 클래스는 Node 가 아니다. 씬 트리, Input, InputMap, get_tree, /root,
# autoload 를 쓰지 않는다. 외부 경로도 없다.

const KEY_OK: StringName = &"ok"
const KEY_REASON: StringName = &"reason"
const KEY_DETAIL: StringName = &"detail"
const KEY_VALUE: StringName = &"value"
const KEY_SATISFIED: StringName = &"satisfied"
const KEY_UNMET: StringName = &"unmet"

## 몸 사실 필드. 선언 순서가 곧 직렬화 순서다.
const FIELD_MISSING: StringName = &"missing"
const FIELD_WOUNDS: StringName = &"wounds"
const FIELD_SCALE: StringName = &"scale"
const FIELD_FACTS: StringName = &"facts"
const FIELDS: Array[StringName] = [FIELD_MISSING, FIELD_WOUNDS, FIELD_SCALE, FIELD_FACTS]

## 몸 필드의 부류. 확정 사실은 진행 축이고 되돌아가지 않는다. 가변 능력은 능력 축이고
## 되돌아간다. 어느 필드도 두 부류에 동시에 속하지 않는다. (DESIGN_DECISION §2.1.1)
const CLASS_PERMANENT_FACT: StringName = &"permanent_fact"
const CLASS_MUTABLE_CAPABILITY: StringName = &"mutable_capability"
## facts 는 둘 다 아니다. 스토어가 관측값의 성격을 알 수 없으므로 다룬다.
const CLASS_UNCLASSED: StringName = &"unclassified"
## 키는 String 이다. AxisBody.FIELD_* 상수와 같은 이름이며, 테스트가 그 대응을 단언한다.
const FIELD_CLASSES: Dictionary = {
	"missing": CLASS_PERMANENT_FACT,
	"wounds": CLASS_PERMANENT_FACT,
	"scale": CLASS_MUTABLE_CAPABILITY,
	"facts": CLASS_UNCLASSED,
}

## 닫힌 6단 사다리. body.scale 은 이 값 중 하나여야 한다. 연속 실수가 아니며,
## 가까운 rung 으로 눌러 맞추지도 않는다. (DESIGN_DECISION §2.1.2)
const SCALE_RUNGS: Array[float] = [0.05, 0.12, 0.28, 0.65, 1.5, 3.6]

## 1.0 은 사다리 값이 아니다. "정상 크기"로 읽히기 때문에 금지한다. 이 금지는 몸 축의
## 최상위 scale 필드에만 걸린다. 상처의 severity 나 요구조건의 scale_min 은 다른 문제다.
const SCALE_RUNG_FORBIDDEN: Array[float] = [1.0]

## 상처는 이 네 사실로만 이루어진다. 여분 키는 허용하지 않는다.
const WOUND_PART: StringName = &"part"
const WOUND_KIND: StringName = &"kind"
const WOUND_SEVERITY: StringName = &"severity"
const WOUND_PERMANENT: StringName = &"permanent"
const WOUND_FIELDS: Array[StringName] = [WOUND_PART, WOUND_KIND, WOUND_SEVERITY, WOUND_PERMANENT]

## 요구 조건은 능력 조건이다. 권한 게이트가 아니다. (DESIGN_DECISION §2.3, §5-B)
const REQ_SCALE_MIN: StringName = &"scale_min"
const REQ_SCALE_MAX: StringName = &"scale_max"
const REQ_HAS_ALL_PARTS: StringName = &"has_all_parts"
const REQ_HAS_WOUND: StringName = &"has_wound"
const REQ_HAS_NO_WOUND: StringName = &"has_no_wound"
const REQUIREMENT_KEYS: Array[StringName] = [REQ_SCALE_MIN, REQ_SCALE_MAX, REQ_HAS_ALL_PARTS, REQ_HAS_WOUND, REQ_HAS_NO_WOUND]

## 요구 조건에 쓰이면 안 되는 이름. 신분·평판·점수 축을 여는 열쇠.
const NOT_CAPABILITY_KEYS: Array[StringName] = [
	&"karma", &"favor", &"favour", &"reputation", &"trust", &"standing", &"title",
	&"score", &"level", &"rank", &"tier", &"grade", &"deaths", &"kills", &"debt",
	&"price", &"toll", &"progress", &"completions", &"access", &"clearance",
]

## 임계값 이중이 붙어도 같은 종류의 이름이다. karma_min 은 karma 이고 trust_min 은
## trust 다. 되돌림으로 권한 조건을 능력 조건처럼 위장할 수 없다. (DESIGN_DECISION §2.3)
const THRESHOLD_SUFFIXES: Array[String] = ["_min", "_max", "_threshold", "_at_least", "_at_most"]

## 파생 요약값. 몸 필드 이름과 facts 키 어느 쪽으로도 허용하지 않는다. (DESIGN_DECISION §2.1)
const DERIVED_KEYS: Array[StringName] = [
	&"health", &"health_max", &"health_fraction", &"health_ratio", &"health_pct",
	&"hp", &"hp_max", &"hitpoints", &"condition", &"vitality", &"integrity",
	&"stamina", &"stamina_fraction", &"wound_count", &"missing_count",
]

## facts 안에서 사용할 수 없는 이름. 몸의 크기는 최상위 scale 필드에 하나만 산다.
## 이 목록은 닫혔고 항목은 하나뿐이다. 새 이름을 추측해서 열지 않는다. (§2.1.3)
const FACTS_RESERVED_KEYS: Array[StringName] = [FIELD_SCALE]

const MAX_JSON_DEPTH: int = 32

## 선언 순서. 없는 필드는 키 자체가 없다.
var _fields: Dictionary = {}


# ── 읽기 ───────────────────────────────────────────────────────────────────
func has_field(key: StringName) -> bool:
	return _fields.has(String(key))


func has_scale() -> bool:
	return has_field(FIELD_SCALE)


func get_scale() -> Variant:
	return _copy_value(_fields.get(String(FIELD_SCALE)))


func get_missing() -> Variant:
	var value: Variant = _fields.get(String(FIELD_MISSING))
	if value == null:
		return null
	return (value as Array[String]).duplicate()


func get_wounds() -> Variant:
	var value: Variant = _fields.get(String(FIELD_WOUNDS))
	if value == null:
		return null
	return (value as Array[Dictionary]).duplicate(true)


func get_facts() -> Variant:
	var value: Variant = _fields.get(String(FIELD_FACTS))
	if value == null:
		return null
	return AxisBody._plain(value)


func has_fact(key: StringName) -> bool:
	var facts: Variant = _fields.get(String(FIELD_FACTS))
	return facts is Dictionary and (facts as Dictionary).has(String(key))


func get_fact(key: StringName) -> Variant:
	if not has_fact(key):
		return null
	return _copy_value((_fields[String(FIELD_FACTS)] as Dictionary)[String(key)])


## 부재가 기록되지 않았다는 사실과 "그 부위가 있다"는 사실은 다르다. 여기서는
## 부재 필드가 없으면 그 부위는 없는 것으로 보지 않는다.
func has_missing_part(part: String) -> bool:
	var value: Variant = _fields.get(String(FIELD_MISSING))
	if value == null:
		return false
	return (value as Array[String]).has(part)


## permanent 을 생략하면 영구 여부와 무관하게 찾는다. 개수를 세지 않는다.
func has_wound(part: String, kind: String, permanent: Variant = null) -> bool:
	var value: Variant = _fields.get(String(FIELD_WOUNDS))
	if value == null:
		return false
	for wound: Dictionary in value as Array[Dictionary]:
		if wound[String(WOUND_PART)] != part or wound[String(WOUND_KIND)] != kind:
			continue
		if permanent == null or wound[String(WOUND_PERMANENT)] == permanent:
			return true
	return false


## 이 몸 필드는 어느 부류인가. 확정 사실인가, 가변 능력인가, 아니면 스토어가 다룰 수
## 없는가. 키 자체가 몸 필드가 아니면 key_unknown 이고 그때는 value 가 없다.
func field_class(key: StringName) -> Dictionary:
	if not FIELDS.has(key):
		return _fail(&"key_unknown", String(key))
	return _ok_value(FIELD_CLASSES[String(key)])


# ── 판정 ───────────────────────────────────────────────────────────────────
## 요구 조건을 만족하는가. 없는 값은 없는 것으로 판정한다. 0 이나 1 을 지어 넣지
## 않는다. 미충족 항목은 기계가 읽을 수 있는 문자열로 돌려준다.
func satisfies(requirement: Variant) -> Dictionary:
	var checked: Dictionary = validate_requirement(requirement)
	if not checked[KEY_OK]:
		return {KEY_OK: false, KEY_REASON: checked[KEY_REASON], KEY_DETAIL: checked[KEY_DETAIL], KEY_SATISFIED: false, KEY_UNMET: [] as Array[String]}
	var wanted: Dictionary = requirement as Dictionary
	var unmet: Array[String] = []
	for key: StringName in REQUIREMENT_KEYS:
		if not wanted.has(String(key)):
			continue
		for entry: String in _unmet_for(key, wanted[key]):
			unmet.append(entry)
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_SATISFIED: unmet.is_empty(), KEY_UNMET: unmet}


static func validate_requirement(requirement: Variant) -> Dictionary:
	if not requirement is Dictionary:
		return _fail(&"value_type_invalid", "requires_body must be a Dictionary")
	var wanted: Dictionary = requirement as Dictionary
	for key: Variant in wanted:
		if not key is String:
			return _fail(&"value_type_invalid", "requires_body keys must be String")
		if _is_permission_key(StringName(key)):
			return _fail(&"requires_body_not_capability", String(key))
		if not REQUIREMENT_KEYS.has(StringName(key)):
			return _fail(&"requires_body_key_unknown", String(key))
		var value: Variant = wanted[key]
		match StringName(key):
			REQ_SCALE_MIN, REQ_SCALE_MAX:
				if not value is int and not value is float:
					return _fail(&"value_type_invalid", String(key))
				if value is float and not is_finite(value as float):
					return _fail(&"value_not_finite", String(key))
			REQ_HAS_ALL_PARTS:
				if not value is Array or not _is_string_array(value as Array):
					return _fail(&"value_type_invalid", String(key))
			REQ_HAS_WOUND, REQ_HAS_NO_WOUND:
				if not _is_wound_match(value):
					return _fail(&"value_type_invalid", String(key))
	return _pass()


func _unmet_for(key: StringName, value: Variant) -> Array[String]:
	var unmet: Array[String] = []
	match key:
		REQ_SCALE_MIN, REQ_SCALE_MAX:
			if not has_scale():
				unmet.append("scale_absent")
			elif key == REQ_SCALE_MIN and float(get_scale()) < float(value):
				unmet.append("scale_below_min")
			elif key == REQ_SCALE_MAX and float(get_scale()) > float(value):
				unmet.append("scale_above_max")
		REQ_HAS_ALL_PARTS:
			for part: Variant in value as Array:
				if has_missing_part(String(part)):
					unmet.append("part_missing:" + String(part))
		REQ_HAS_WOUND:
			if not has_field(FIELD_WOUNDS):
				unmet.append("wounds_absent")
			elif not _matches_any_wound(value):
				unmet.append("wound_missing")
		REQ_HAS_NO_WOUND:
			if has_field(FIELD_WOUNDS) and _matches_any_wound(value):
				unmet.append("wound_present")
	return unmet


# ── 쓰기 ───────────────────────────────────────────────────────────────────
## 이 요청이 허용되는지 먼저 묻는다. apply 와 같은 판정, 같은 사유 문자열, 그리고
## 아무것도 고치지 않는다. 쓰지 않고 확인하는 방법이 따로 필요할 때의 그 방법이다.
func check_mutation(patch: Variant) -> Dictionary:
	var staged: Dictionary = _stage(patch)
	return {KEY_OK: staged[KEY_OK], KEY_REASON: staged[KEY_REASON], KEY_DETAIL: staged[KEY_DETAIL]}


## 몸은 신분 필드가 없다. 전체 적용과 부분 적용이 같은 호출이다. 없는 키는
## 그대로 없는 채로 남는다. 실패하면 아무것도 바뀌지 않는다.
func apply(patch: Variant) -> Dictionary:
	var staged: Dictionary = _stage(patch)
	if not staged[KEY_OK]:
		return {KEY_OK: false, KEY_REASON: staged[KEY_REASON], KEY_DETAIL: staged[KEY_DETAIL]}
	var committed: Dictionary = staged[KEY_VALUE]
	_fields = committed
	return _pass()


## 임시 사본에 patch 를 올린다. 성공하면 KEY_VALUE 에 그 사본을 실어 주고, 실패하면
## 원본은 그대로이고 KEY_VALUE 가 없다. (DESIGN_DECISION §4)
func _stage(patch: Variant) -> Dictionary:
	if not patch is Dictionary:
		return _fail(&"patch_not_dictionary", "body patch must be a Dictionary")
	var source: Dictionary = patch as Dictionary
	if source.is_empty():
		return _fail(&"patch_empty", "body patch has no keys")
	var staged: Dictionary = _fields.duplicate(true)
	for key: Variant in source:
		if not key is String:
			return _fail(&"value_type_invalid", "body patch keys must be String")
		var name: StringName = StringName(key)
		if DERIVED_KEYS.has(name):
			return _fail(&"derived_value_forbidden", String(key))
		if not FIELDS.has(name):
			return _fail(&"key_unknown", String(key))
		var checked: Dictionary = _validate_field(name, source[key])
		if not checked[KEY_OK]:
			return checked
		staged[String(name)] = checked[KEY_VALUE]
		if not _is_permanent(name):
			continue
		var dropped: String = _dropped_fact(name, checked[KEY_VALUE])
		if not dropped.is_empty():
			return _fail(&"body_fact_is_permanent", dropped)
	return _ok_value(staged)


## 새 값이 더 이상 담고 있지 않은 확정 사실을 찾는다. 하나라도 있으면 그 필드는 진행
## 축이다. 지워진 사실은 되돌아가지 않으므로 이 요청은 거절된다. 빈 문자열은 "없다"를
## 뜻한다. 기록된 사실이 애초에 없으면 빈 배열로 쓰는 것도 지우는 것이 아니다. (§2.1.1)
func _dropped_fact(name: StringName, value: Variant) -> String:
	var recorded: Variant = _fields.get(String(name))
	if recorded == null:
		return ""
	match name:
		FIELD_MISSING:
			for part: Variant in recorded as Array[String]:
				if not (value as Array[String]).has(part):
					return String(part)
		FIELD_WOUNDS:
			for wound: Dictionary in recorded as Array[Dictionary]:
				if not _records_same_wound(wound, value as Array[Dictionary]):
					return "%s/%s" % [String(wound[String(WOUND_PART)]), String(wound[String(WOUND_KIND)])]
	return ""


## 상처의 동일성은 부위와 종류다. severity 와 permanent 는 재측정할 수 있는 속성이므로
## 같은 사실의 다른 측정으로 본다. 스토어는 재측정을 거절하지 않는다. (§4)
static func _records_same_wound(recorded: Dictionary, incoming: Array[Dictionary]) -> bool:
	for wound: Dictionary in incoming:
		if wound[String(WOUND_PART)] == recorded[String(WOUND_PART)] and wound[String(WOUND_KIND)] == recorded[String(WOUND_KIND)]:
			return true
	return false


## 사본은 _fields 를 그대로 옮긴다. 그 안에는 검증된 값만 있고, 검증은 facts 의 예약
## 이름까지 통과해야만 통과한다. 이 객체 자체는 직렬화되지 않으므로 사본이 옮길 수
## 있는 "아직 오지 않은 상태"는 없다. 그래서 여기 다시 거절할 곳이 없다. (§2.1.3)
func copy() -> AxisBody:
	var clone: AxisBody = AxisBody.new()
	clone._fields = _fields.duplicate(true)
	return clone


func to_dictionary() -> Dictionary:
	var out: Dictionary = {}
	for name: StringName in FIELDS:
		if _fields.has(String(name)):
			out[String(name)] = AxisBody._plain(_fields[String(name)])
	return out


# ── 검증 ───────────────────────────────────────────────────────────────────
func _validate_field(name: StringName, value: Variant) -> Dictionary:
	match name:
		FIELD_MISSING:
			if not value is Array:
				return _fail(&"value_type_invalid", "missing must be an Array")
			var parts: Array[String] = []
			for part: Variant in value as Array:
				if not part is String or (part as String).is_empty():
					return _fail(&"value_type_invalid", "missing entries must be non-empty String")
				if parts.has(part as String):
					return _fail(&"value_type_invalid", "duplicate missing entry " + String(part))
				parts.append(part as String)
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: parts}
		FIELD_WOUNDS:
			if not value is Array:
				return _fail(&"value_type_invalid", "wounds must be an Array")
			var wounds: Array[Dictionary] = []
			for entry: Variant in value as Array:
				var fault: Dictionary = _check_wound(entry)
				if not fault.is_empty():
					return _fail(&"wound_malformed", String(fault[KEY_DETAIL]))
				wounds.append(_wire_value(entry) as Dictionary)
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: wounds}
		FIELD_SCALE:
			if not _is_number(value):
				return _fail(&"value_not_finite", "scale") if value is float else _fail(&"value_type_invalid", "scale")
			var rung: Dictionary = _check_rung(value)
			if not rung[KEY_OK]:
				return rung
			return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: value}
		FIELD_FACTS:
			if not value is Dictionary:
				return _fail(&"value_type_invalid", "facts must be a Dictionary")
			return _validate_facts(value as Dictionary)
	return _fail(&"key_unknown", String(name))


static func _validate_facts(facts: Dictionary) -> Dictionary:
	var staged: Dictionary = {}
	for key: Variant in facts:
		if not key is String:
			return _fail(&"value_type_invalid", "fact keys must be String")
		var name: StringName = StringName(key)
		if DERIVED_KEYS.has(name):
			return _fail(&"derived_value_forbidden", String(key))
		## 몸의 크기 이름은 facts 에 들어올 수 없다. 사다리 규칙의 두 번째 통로다.
		## 이 이름으로 관측값이 들어오면 그 값이 rung 인지 아닌지 아무도 모른다.
		## 그래서 값을 보지 않고 키째로 거절한다. 지우지도 고치지도 않는다. (§2.1.3)
		if FACTS_RESERVED_KEYS.has(name):
			return _fail(&"key_unknown", "facts has no key \"" + String(key) + "\": the body size lives in the body scale field and nowhere else")
		var value: Variant = facts[key]
		if value is float and not is_finite(value as float):
			return _fail(&"value_not_finite", String(key))
		if not is_json_safe(value):
			return _fail(&"value_not_json_safe", String(key))
		staged[String(key)] = _wire_value(value)
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: staged}


static func _check_wound(wound: Variant) -> Dictionary:
	if not wound is Dictionary:
		return _fail(&"wound_malformed", "wound must be a Dictionary")
	var record: Dictionary = wound as Dictionary
	for key: Variant in record:
		if not key is String:
			return _fail(&"wound_malformed", "wound keys must be String")
		if not WOUND_FIELDS.has(StringName(key)):
			return _fail(&"wound_malformed", "unexpected wound key " + String(key))
	if record.size() != WOUND_FIELDS.size():
		return _fail(&"wound_malformed", "wound needs part, kind, severity, permanent")
	if not record[String(WOUND_PART)] is String or (record[String(WOUND_PART)] as String).is_empty():
		return _fail(&"wound_malformed", "wound part must be a non-empty String")
	if not record[String(WOUND_KIND)] is String or (record[String(WOUND_KIND)] as String).is_empty():
		return _fail(&"wound_malformed", "wound kind must be a non-empty String")
	if not _is_number(record[String(WOUND_SEVERITY)]):
		return _fail(&"wound_malformed", "wound severity must be a finite number")
	if not record[String(WOUND_PERMANENT)] is bool:
		return _fail(&"wound_malformed", "wound permanent must be a bool")
	return {}


func _matches_any_wound(value: Variant) -> bool:
	var wanted: Dictionary = value as Dictionary
	for wound: Dictionary in get_wounds() as Array[Dictionary]:
		if _wound_matches(wound, wanted):
			return true
	return false


static func _wound_matches(wound: Dictionary, wanted: Dictionary) -> bool:
	for key: Variant in wanted:
		if wound[String(key)] != wanted[key]:
			return false
	return true


# ── 공유 프리미티브 ────────────────────────────────────────────────────────
## 6단 사다리 판정. 1.0 은 다른 거절 사유를 갖는다. 가장 가까운 rung 으로 눌러 맞추는
## 것은 정규화다. 그래서 하지 않는다. 아무 값도 고치지 않고 거절만 한다. (§4, §2.1.2)
static func _check_rung(value: Variant) -> Dictionary:
	var number: float = float(value)
	if SCALE_RUNG_FORBIDDEN.has(number):
		return _fail(&"scale_rung_forbidden", "1.0 is not a rung and the ladder has no normal size")
	if not SCALE_RUNGS.has(number):
		return _fail(&"scale_not_rung", "%s is not one of the six rungs" % str(value))
	return _pass()


## 이 필드가 확정 사실인가. facts 는 "스토어의 일이 아니다" 라서 여기 걸리지 않는다.
static func _is_permanent(key: StringName) -> bool:
	return FIELD_CLASSES[String(key)] == CLASS_PERMANENT_FACT


## 값은 받아 적는 그대로 저장한다. int 를 float 로 밀지 않고 float 를 int 로 떨구지
## 않는다. (DESIGN_DECISION §4) 배열과 사전은 소유권을 넘기지 않도록 새로 만든다.
static func _wire_value(value: Variant) -> Variant:
	if value is Array:
		var out: Array = []
		for element: Variant in value as Array:
			out.append(_wire_value(element))
		return out
	if value is Dictionary:
		var out_map: Dictionary = {}
		for key: Variant in value as Dictionary:
			out_map[String(key)] = _wire_value((value as Dictionary)[key])
		return out_map
	return value


## JSON-safe 여부는 몸 사실(모든 축의 열린 딕셔너리)과 개체 성격/기억이 함께 쓰는
## 유일한 판정기라 AxisBody 에 산다. 두 실제 사용처가 확인된 뒤에 추출한 것.
static func is_json_safe(value: Variant, depth: int = 0) -> bool:
	if depth > MAX_JSON_DEPTH:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for element: Variant in value as Array:
				if not is_json_safe(element, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value as Dictionary:
				if not key is String or not is_json_safe((value as Dictionary)[key], depth + 1):
					return false
			return true
	return false


## 직렬화는 항상 평범한 Array/Dictionary 로 낸다. typed array 는 JSON 왕복에서
## 타입을 잃기 때문이다. 타입 복원은 읽기 쪽에서 한다. 몸과 개체가 함께 쓰는
## 공유 규칙이므로 여기 산다.
static func _plain(value: Variant) -> Variant:
	if value is Array:
		var out: Array = []
		for element: Variant in value as Array:
			out.append(_plain(element))
		return out
	if value is Dictionary:
		var out_map: Dictionary = {}
		for key: Variant in value as Dictionary:
			out_map[String(key)] = _plain((value as Dictionary)[key])
		return out_map
	return value


static func _copy_value(value: Variant) -> Variant:
	if value is Array or value is Dictionary:
		return AxisBody._plain(value)
	return value


static func _is_number(value: Variant) -> bool:
	return value is int or (value is float and is_finite(value as float))


## 권한·신분 계열 이름인지 판정한다. 임계값 이중이 붙은 형태까지 같은 종류로 본다.
## 목록이 닫혀 있으므로 새 이름을 추측해서 열지 않는다. (CONTRACT 마지막 절)
static func _is_permission_key(name: StringName) -> bool:
	if NOT_CAPABILITY_KEYS.has(name) or DERIVED_KEYS.has(name):
		return true
	var spelled: String = String(name)
	for suffix: String in THRESHOLD_SUFFIXES:
		if not spelled.ends_with(suffix):
			continue
		if NOT_CAPABILITY_KEYS.has(StringName(spelled.left(spelled.length() - suffix.length()))):
			return true
	return false


static func _is_string_array(value: Array) -> bool:
	if value.is_empty():
		return false
	for element: Variant in value:
		if not element is String or (element as String).is_empty():
			return false
	return true


## 요구 조건의 상처 지정은 part + kind 를 필수로 하고 permanent 을 선택으로 받는다.
## severity 는 요구 조건이 아니다. 범위 판정은 Kit 물리 규칙의 몫이다.
static func _is_wound_match(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var wanted: Dictionary = value as Dictionary
	if not wanted.has(String(WOUND_PART)) or not wanted.has(String(WOUND_KIND)):
		return false
	for key: Variant in wanted:
		if not key is String:
			return false
		match StringName(key):
			WOUND_PART, WOUND_KIND:
				if not wanted[key] is String or (wanted[key] as String).is_empty():
					return false
			WOUND_PERMANENT:
				if not wanted[key] is bool:
					return false
			_:
				return false
	return true


static func _pass() -> Dictionary:
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: ""}


static func _ok_value(value: Variant) -> Dictionary:
	return {KEY_OK: true, KEY_REASON: &"ok", KEY_DETAIL: "", KEY_VALUE: value}


static func _fail(reason: StringName, detail: String) -> Dictionary:
	return {KEY_OK: false, KEY_REASON: reason, KEY_DETAIL: detail}
