class_name WorldState
extends RefCounted

# PURPOSE: 뭉탱이 상태 스토어. 세 Kit의 저장이 원본이 아니라 여기라는 axiom 의
# 구현이다. 정본: core/worldstate/DESIGN_DECISION.md. OWNER: W7.
#
#   > 세 Kit의 저장은 원본이 아니다. 원본은 여기 있고, Kit는 뷰만 갖는다.
#
# 축은 세 개다. 늘리지 않는다.
#   body      AxisBody                     런타임 쓰기: 소유 Kit만
#   creature  Dictionary<String, AxisCreature>  런타임 쓰기: 소유 Kit만
#   place     Dictionary<String, AxisPlace>     런타임 쓰기: 없음 (무조건 거부)
#
# 모듈은 축을 읽고 쓰기를 요청한다. 판정은 여기가 한다. 판정은 소유 Kit 이
# 로드되어 있지 않아도 성립한다. 여기서는 모듈 이름도 Kit 이름도 모른다.
# 소유자는 app 층이 declare_owner() 로 신원만 선언한다. 선언은 저장에도 실리고,
# 그래서 소유 Kit 의 부재와 무관하게 거부 사유를 돌려줄 수 있다.
#
# 정규화 금지 (§4). 이 스토어는 어떤 값도 환산하지 않고 범위로 누르지 않는다.
# 없는 값은 없는 키로 남는다. 복원 실패는 조용히 기본값으로 덮지 않는다.
#
# 몸 축은 확정 사실과 가변 능력을 섞지 않는다 (§2.1.1). body.scale 은 닫힌 6단
# 사다리 값이며 연속 실수가 아니다 (§2.1.2). 사다리가 아닌 값을 거절하는 것은
# 정규화가 아니라 값의 영역을 닫는 것이고, 거절된 값은 한 비트도 바뀌지 않는다.
#
# 이 클래스는 Node 가 아니다. 씬 트리, Input, InputMap, get_tree, /root,
# autoload, 서비스 로케이터를 쓰지 않는다. modules/ 를 한 번도 참조하지 않는다.

const STORE_VERSION: int = 1

const AXIS_BODY: StringName = &"body"
const AXIS_CREATURE: StringName = &"creature"
const AXIS_PLACE: StringName = &"place"
const AXES: Array[StringName] = [AXIS_BODY, AXIS_CREATURE, AXIS_PLACE]

## 실행 중 쓰기가 존재하는 축. place 는 없다.
const WRITABLE_AXES: Array[StringName] = [AXIS_BODY, AXIS_CREATURE]

## ModuleContext.arrival 안에서 이 키로 뷰가 전달된다. 값 복사가 아니라 참조다.
const ARRIVAL_KEY: StringName = &"world_state_view"

const KEY_OK: StringName = &"ok"
const KEY_REASON: StringName = &"reason"
const KEY_DETAIL: StringName = &"detail"
const KEY_SATISFIED: StringName = &"satisfied"
const KEY_UNMET: StringName = &"unmet"
const KEY_VALUE: StringName = &"value"

# ── 거부 사유 ──────────────────────────────────────────────────────────────
const REASON_OK: StringName = &"ok"
## axis 가 body/creature/place 중 하나가 아니다.
const REASON_AXIS_UNKNOWN: StringName = &"axis_unknown"
## place 축에 대한 쓰기. 판정을 보지 않고 무조건 이 값으로 끝난다.
const REASON_AXIS_READ_ONLY: StringName = &"axis_read_only"
## 읽으려는 축이 아직 없다. 없는 것은 0 이나 {} 이 아니다.
const REASON_AXIS_ABSENT: StringName = &"axis_absent"
## 이 축의 런타임 소유자가 아직 선언되지 않았다.
const REASON_OWNER_UNDECLARED: StringName = &"axis_owner_undeclared"
## 이 축의 소유자가 이미 다른 id 로 선언되어 있다. 신원은 저장 호환 대상이다.
const REASON_OWNER_ALREADY_DECLARED: StringName = &"owner_already_declared"
## 요청자가 이 축의 소유자가 아니다.
const REASON_NOT_OWNER: StringName = &"requester_not_owner"
const REASON_PLACE_UNKNOWN: StringName = &"place_unknown"
const REASON_PATCH_NOT_DICTIONARY: StringName = &"patch_not_dictionary"
const REASON_PATCH_EMPTY: StringName = &"patch_empty"
const REASON_KEY_UNKNOWN: StringName = &"key_unknown"
const REASON_NOT_JSON_SAFE: StringName = &"value_not_json_safe"
const REASON_TYPE_INVALID: StringName = &"value_type_invalid"
const REASON_NOT_FINITE: StringName = &"value_not_finite"
## 파생 요약값. §2.1. 어떤 축에도 저장되지 않는다.
const REASON_DERIVED_FORBIDDEN: StringName = &"derived_value_forbidden"
const REASON_WOUND_MALFORMED: StringName = &"wound_malformed"
## 6단 사다리의 rung 이 아니다. 가장 가까운 rung 으로 눌러 맞추지 않는다. (§2.1.2)
const REASON_SCALE_NOT_RUNG: StringName = &"scale_not_rung"
## 1.0 은 사다리 값이 아니다. 이 세계에 "정상 크기"가 없다는 belief 가 금지된다. (§2.1.2)
const REASON_SCALE_RUNG_FORBIDDEN: StringName = &"scale_rung_forbidden"
## 이미 기록된 확정 사실을 지우거나 되돌리려는 요청. 진행 축은 되돌아가지 않는다. (§2.1.1)
const REASON_FACT_PERMANENT: StringName = &"body_fact_is_permanent"
const REASON_REQUIREMENT_KEY_UNKNOWN: StringName = &"requires_body_key_unknown"
## 권한·신분 계열 이름. requires_body 는 능력 조건만 받는다.
const REASON_NOT_CAPABILITY: StringName = &"requires_body_not_capability"
const REASON_CREATURE_ID_INVALID: StringName = &"creature_id_invalid"
## 종/유형은 생성자가 정한다. 태어난 뒤에는 바뀌지 않는다. (DESIGN_DECISION §2.2)
const REASON_ARCHETYPE_FIXED: StringName = &"creature_archetype_fixed"
const REASON_CREATURE_UNKNOWN: StringName = &"creature_unknown"
## memory 는 사건 목록이다. 숫자가 자리하면 거절한다.
const REASON_MEMORY_NOT_EVENTS: StringName = &"memory_is_event_list"
const REASON_MEMORY_ENTRY_EMPTY: StringName = &"memory_entry_empty"
const REASON_SNAPSHOT_MALFORMED: StringName = &"snapshot_malformed"
const REASON_VERSION_UNSUPPORTED: StringName = &"snapshot_version_unsupported"
const REASON_OWNERS_MALFORMED: StringName = &"owners_malformed"

## 스냅샷 봉투 키. 존재 여부가 곧 "없음" 의 보존이다.
const KEY_STORE_VERSION: String = "ax"
const KEY_OWNERS: String = "owners"
const KEY_BODY: String = "body"
const KEY_CREATURES: String = "creatures"
const KEY_PLACES: String = "places"
const KEY_FOCUS: String = "focus_place_id"

var _owners: Dictionary = {}
var _body: AxisBody = null
var _creatures: Dictionary = {}
var _places: Dictionary = {}
var _focus_place_id: String = ""
var _views: Array[WeakRef] = []
## load_json 이 배선 숫자 복원을 걷는 동안의 위치. 값이 아니라 횟수다.
var _wire_cursor: int = 0


# ── 소유 선언 ──────────────────────────────────────────────────────────────
## app 층이 부트에서 한 번 호출한다. Kit 의 인스턴스가 아니라 신원 문자열이라,
## 소유 Kit 이 로드되지 않은 상태에서도 판정이 성립한다. (DESIGN_DECISION §3)
func declare_owner(axis: StringName, requester_id: StringName) -> Dictionary:
	if not AXES.has(axis):
		return _fail(REASON_AXIS_UNKNOWN, String(axis))
	if axis == AXIS_PLACE:
		return _fail(REASON_AXIS_READ_ONLY, "place has no runtime writer")
	if requester_id == &"":
		return _fail(REASON_TYPE_INVALID, "owner id must be a non-empty StringName")
	if _owners.has(String(axis)):
		if _owners[String(axis)] == String(requester_id):
			return _pass()
		return _fail(REASON_OWNER_ALREADY_DECLARED, String(axis))
	_owners[String(axis)] = String(requester_id)
	return _pass()


func get_owner(axis: StringName) -> String:
	return String(_owners.get(String(axis), ""))


# ── 중재 ───────────────────────────────────────────────────────────────────
## 모듈이 부르는 유일한 쓰기 경로. 판정 순서는 고정이며 CONTRACT.md 에 적어 둔다.
##   1 axis_unknown      2 axis_read_only(place)
##   3 axis_owner_undeclared   4 requester_not_owner
##   5 patch_not_dictionary   6 patch_empty   7 축별 규칙
## 거절은 상태를 한 비트도 바꾸지 않는다. reason 은 항상 채워진다.
func request_mutation(axis: StringName, patch: Variant, requester: StringName) -> Dictionary:
	if not AXES.has(axis):
		return _fail(REASON_AXIS_UNKNOWN, String(axis))
	if axis == AXIS_PLACE:
		return _fail(REASON_AXIS_READ_ONLY, "place is authored and immutable at runtime")
	if not _owners.has(String(axis)):
		return _fail(REASON_OWNER_UNDECLARED, String(axis))
	if _owners[String(axis)] != String(requester):
		return _fail(REASON_NOT_OWNER, "%s != %s" % [String(requester), _owners[String(axis)]])
	if not patch is Dictionary:
		return _fail(REASON_PATCH_NOT_DICTIONARY, String(axis))
	var source: Dictionary = patch as Dictionary
	if source.is_empty():
		return _fail(REASON_PATCH_EMPTY, String(axis))
	if axis == AXIS_BODY:
		return _mutate_body(source)
	return _mutate_creature(source)


func _mutate_body(patch: Dictionary) -> Dictionary:
	var staged: AxisBody = _body.copy() if _body != null else AxisBody.new()
	var result: Dictionary = staged.apply(patch)
	if not result[KEY_OK]:
		return result
	_body = staged
	_refresh_views()
	return _pass()


func _mutate_creature(patch: Dictionary) -> Dictionary:
	var id: Variant = patch.get(String(AxisCreature.FIELD_ID))
	if not id is String or (id as String).is_empty():
		return _fail(REASON_CREATURE_ID_INVALID, "creature patch needs a non-empty id")
	var key: String = id as String
	var exists: bool = _creatures.has(key)
	if not exists and not patch.has(String(AxisCreature.FIELD_ARCHETYPE)):
		## archetype 는 생성자가 정한다 (DESIGN_DECISION §2.2). 종/유형 없는 개체는
		## 새로 만들 수도, 없는 개인을 갱신할 수도 없다. 조용히 생성하지 않는다.
		return _fail(REASON_CREATURE_UNKNOWN, key)
	if exists and patch.get(String(AxisCreature.FIELD_ARCHETYPE)) is String:
		## 같은 개인이 다른 종이 될 수는 없다. id 가 바뀐 것도 새 개인이다.
		if (patch[String(AxisCreature.FIELD_ARCHETYPE)] as String) != (_creatures[key] as AxisCreature).get_archetype():
			return _fail(REASON_ARCHETYPE_FIXED, key)
	var staged: AxisCreature = (_creatures[key] as AxisCreature).copy() if exists else AxisCreature.new()
	## 생성이든 갱신이든 하나의 검증 경로를 탄다. 그래서 거절된 요청은 반쪽짜리
	## 개체를 남기지 않는다.
	var result: Dictionary = staged.apply(patch)
	if not result[KEY_OK]:
		return result
	_creatures[key] = staged
	_refresh_views()
	return _pass()


# ── 쿼리 ───────────────────────────────────────────────────────────────────
## §5 장면 A 의 판정 테스트를 한 번에. 세 Kit 이 같은 장소를 같은 몸으로 읽는다.
func body_satisfies(place_id: String) -> Dictionary:
	if not _places.has(place_id):
		return {KEY_OK: false, KEY_REASON: REASON_PLACE_UNKNOWN, KEY_DETAIL: place_id, KEY_SATISFIED: false, KEY_UNMET: [] as Array[String]}
	if _body == null:
		return {KEY_OK: false, KEY_REASON: REASON_AXIS_ABSENT, KEY_DETAIL: "body", KEY_SATISFIED: false, KEY_UNMET: [] as Array[String]}
	return _body.satisfies((_places[place_id] as AxisPlace).get_requires_body())


func get_focus_place_id() -> String:
	return _focus_place_id


## 장면 커서. 축 변경이 아니라 스토어 자신의 위치다. 모듈은 뷰로 접근할 수 없고,
## 요청 경로에도 없다. (place 축은 그대로 읽기 전용이다)
func focus_place(place_id: String) -> Dictionary:
	if not place_id.is_empty() and not _places.has(place_id):
		return _fail(REASON_PLACE_UNKNOWN, place_id)
	_focus_place_id = place_id
	_refresh_views()
	return _pass()


# ── 뷰 발급 ────────────────────────────────────────────────────────────────
## 스토어는 뷰를 직접 참조하지 않는다. 뷰는 스냅샷 사본만 들고, 스토어는 그
## 사본을 밀어 넣기만 한다. 그래서 모듈이 뷰를 리플렉션으로 어떻게 다루어도
## 원본에 닿을 경로가 없다.
func issue_view() -> WorldStateView:
	var view: WorldStateView = WorldStateView.new()
	view._refresh(to_dictionary())
	_views.append(weakref(view))
	return view


func make_arrival() -> Dictionary:
	return {ARRIVAL_KEY: issue_view()}


func _refresh_views() -> void:
	var live: Array[WeakRef] = []
	for reference: WeakRef in _views:
		var view: WorldStateView = reference.get_ref() as WorldStateView
		if view == null:
			continue
		view._refresh(to_dictionary())
		live.append(reference)
	_views = live


# ── 직렬화 ─────────────────────────────────────────────────────────────────
func to_dictionary() -> Dictionary:
	var data: Dictionary = {KEY_STORE_VERSION: STORE_VERSION}
	if not _owners.is_empty():
		var owners: Dictionary = {}
		for axis: StringName in WRITABLE_AXES:
			if _owners.has(String(axis)):
				owners[String(axis)] = _owners[String(axis)]
		data[KEY_OWNERS] = owners
	if _body != null:
		data[KEY_BODY] = _body.to_dictionary()
	if not _creatures.is_empty():
		var creatures: Dictionary = {}
		for id: String in _sorted_ids(_creatures):
			creatures[id] = (_creatures[id] as AxisCreature).to_dictionary()
		data[KEY_CREATURES] = creatures
	if not _places.is_empty():
		var places: Dictionary = {}
		for id: String in _sorted_ids(_places):
			places[id] = (_places[id] as AxisPlace).to_dictionary()
		data[KEY_PLACES] = places
	data[KEY_FOCUS] = _focus_place_id
	return data


func to_json() -> String:
	return JSON.stringify(to_dictionary())


## 복원은 원자적이다. 검증이 하나라도 실패하면 아무것도 바뀌지 않는다.
## 조용히 기본값으로 덮지 않는다. 실패하면 reason 을 돌려준다. (§7)
##
## owners 는 덮어쓰지 않는다. 스냅샷에 적힌 소유자가 이 세션의 선언과 다르면
## owner_already_declared 로 실패한다. 이것이 §7 의 "셋을 정합시킨다" 이다.
func load_snapshot(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return _fail(REASON_SNAPSHOT_MALFORMED, "snapshot must be a Dictionary")
	var source: Dictionary = data as Dictionary
	var stamped: Variant = source.get(KEY_STORE_VERSION)
	if not stamped is int and not stamped is float:
		return _fail(REASON_VERSION_UNSUPPORTED, "missing " + KEY_STORE_VERSION)
	if not is_finite(float(stamped)) or float(stamped) != floorf(float(stamped)) or int(stamped) != STORE_VERSION:
		return _fail(REASON_VERSION_UNSUPPORTED, str(stamped))
	var owners: Dictionary = _read_owners(source.get(KEY_OWNERS, {}))
	if not owners[KEY_OK]:
		return owners
	for axis: StringName in WRITABLE_AXES:
		var key: String = String(axis)
		var claimed: String = String((owners[KEY_VALUE] as Dictionary).get(key, ""))
		if claimed.is_empty():
			continue
		if _owners.has(key) and _owners[key] != claimed:
			return _fail(REASON_OWNER_ALREADY_DECLARED, key)
	var body: AxisBody = null
	if source.has(KEY_BODY):
		var candidate: AxisBody = AxisBody.new()
		var checked: Dictionary = candidate.apply(source[KEY_BODY])
		if not checked[KEY_OK]:
			return checked
		body = candidate
	var creatures: Dictionary = {}
	if source.has(KEY_CREATURES):
		var read: Dictionary = _read_creatures(source[KEY_CREATURES])
		if not read[KEY_OK]:
			return read
		creatures = read[KEY_VALUE]
	var places: Dictionary = {}
	if source.has(KEY_PLACES):
		var read: Dictionary = _read_places(source[KEY_PLACES])
		if not read[KEY_OK]:
			return read
		places = read[KEY_VALUE]
	var focus: Variant = source.get(KEY_FOCUS, "")
	if not focus is String:
		return _fail(REASON_TYPE_INVALID, KEY_FOCUS)
	if not (focus as String).is_empty() and not places.has(focus as String):
		return _fail(REASON_PLACE_UNKNOWN, String(focus))
	for axis: StringName in WRITABLE_AXES:
		var key: String = String(axis)
		if not _owners.has(key) and (owners[KEY_VALUE] as Dictionary).has(key):
			_owners[key] = (owners[KEY_VALUE] as Dictionary)[key]
	_body = body
	_creatures = creatures
	_places = places
	_focus_place_id = focus as String
	_refresh_views()
	return _pass()


func load_json(text: String) -> Dictionary:
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK:
		return _fail(REASON_SNAPSHOT_MALFORMED, parser.get_error_message())
	var flagged: Array = _float_number_tokens(text)
	_wire_cursor = 0
	var restored: Variant = _restore_wire_numbers(parser.data, flagged)
	if _wire_cursor != flagged.size():
		## 텍스트의 숫자 토큰과 파싱된 값의 숫자 개수가 다르다. 이르면 어느 숫자에
		## 어느 표시를 붙였는지 신뢰할 수 없다. 조용히 맞추지 않고 실패한다. (§7)
		return _fail(REASON_SNAPSHOT_MALFORMED, "number tokens do not line up with the parsed value")
	return load_snapshot(restored)


## Godot 의 JSON 파서는 모든 숫자를 float 로 돌려준다. 그러면 스토어가 내보낼 때
## int 로 쓴 200 과 float 로 쓴 1.0 이 파싱 뒤에 같은 값이 되어, 쓰기/복원 왕복이
## 값을 바꾸지 않고 타입만 바꾼다. int/float 구분은 값이 아니라 텍스트에 있으므로
## 거기서 읽는다: 문자열은 건너뛰고 숫자 토큰을 등장 순서대로 훑어, 소수점이나 지수가
## 있는 것만 float 로 표시한다. (CONTRACT 정규화 금지 2 절의 배선 형식 복원)
static func _float_number_tokens(text: String) -> Array:
	var scanner: RegEx = RegEx.new()
	if scanner.compile("\"(?:[^\"\\\\]|\\\\.)*\"|-?\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?") != OK:
		return []
	var flagged: Array = []
	var position: int = 0
	while position < text.length():
		var found: RegExMatch = scanner.search(text, position)
		if found == null:
			break
		position = found.get_end()
		var token: String = found.get_string()
		if token.begins_with("\""):
			continue
		flagged.append(token.contains(".") or token.contains("e") or token.contains("E"))
	return flagged


## 표시를 파싱된 값에 순서대로 적용한다. 파서가 float 로 뭉갠 숫자 중, 텍스트에서
## int 로 쓰였던 것만 int 로 되돌린다. 값 자체는 한 번도 만지지 않는다.
func _restore_wire_numbers(value: Variant, flagged: Array) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			var written_as_float: bool = bool(flagged[_wire_cursor])
			_wire_cursor += 1
			return value if written_as_float else int(value)
		TYPE_ARRAY:
			var out: Array = []
			for element: Variant in value as Array:
				out.append(_restore_wire_numbers(element, flagged))
			return out
		TYPE_DICTIONARY:
			var out_map: Dictionary = {}
			for key: Variant in value as Dictionary:
				out_map[String(key)] = _restore_wire_numbers((value as Dictionary)[key], flagged)
			return out_map
	return value


# ── 검증 ───────────────────────────────────────────────────────────────────
## 스냅샷의 owners 는 권위가 아니라 정합성 단언이다.
func _read_owners(source: Variant) -> Dictionary:
	if not source is Dictionary:
		return _fail(REASON_OWNERS_MALFORMED, KEY_OWNERS)
	var owners: Dictionary = {}
	for key: Variant in source as Dictionary:
		var value: Variant = (source as Dictionary)[key]
		if not key is String or not value is String or (value as String).is_empty():
			return _fail(REASON_OWNERS_MALFORMED, String(key))
		var axis: StringName = StringName(key)
		if not WRITABLE_AXES.has(axis):
			return _fail(REASON_OWNERS_MALFORMED, String(key))
		owners[String(axis)] = value as String
	return _ok_value(owners)


func _read_creatures(source: Variant) -> Dictionary:
	if not source is Dictionary:
		return _fail(REASON_SNAPSHOT_MALFORMED, KEY_CREATURES)
	var out: Dictionary = {}
	for id: String in _sorted_ids(source as Dictionary):
		var record: AxisCreature = AxisCreature.new()
		var checked: Dictionary = record.apply((source as Dictionary)[id])
		if not checked[KEY_OK]:
			return checked
		if record.get_id() != id:
			return _fail(REASON_SNAPSHOT_MALFORMED, "creature key " + id + " does not match its id")
		out[id] = record
	return _ok_value(out)


func _read_places(source: Variant) -> Dictionary:
	if not source is Dictionary:
		return _fail(REASON_SNAPSHOT_MALFORMED, KEY_PLACES)
	var out: Dictionary = {}
	for id: String in _sorted_ids(source as Dictionary):
		var checked: Dictionary = AxisPlace.create(id, (source as Dictionary)[id])
		if not checked[KEY_OK]:
			return checked
		out[id] = checked[KEY_VALUE]
	return _ok_value(out)


# ── 안쪽 ───────────────────────────────────────────────────────────────────
## 스냅샷과 직렬화는 결정론을 위해 id 를 정렬해 내보낸다.
static func _sorted_ids(source: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in source:
		ids.append(String(key))
	ids.sort()
	return ids


func _pass() -> Dictionary:
	return {KEY_OK: true, KEY_REASON: REASON_OK, KEY_DETAIL: ""}


func _ok_value(value: Variant) -> Dictionary:
	return {KEY_OK: true, KEY_REASON: REASON_OK, KEY_DETAIL: "", KEY_VALUE: value}


func _fail(reason: StringName, detail: String) -> Dictionary:
	return {KEY_OK: false, KEY_REASON: reason, KEY_DETAIL: detail}
