extends RefCounted
## g06 그림 세션 candidate(승인 전) 산출물의 res:// 경로만 참조하는 module-local 조회기.
## 그림 파일을 복사·수정하지 않는다. 파일이 없으면 null을 돌려 호출부가 placeholder로 돌아간다.
## scene id가 사건마다 겹치므로(scene_locker, scene_service) 사건 id로 먼저 나눈다.

const ART_CANDIDATES_PATH: String = "res://modules/deduction_casework/content/art_candidates.json"

static var _cases: Dictionary = {}
static var _textures: Dictionary = {}
static var _loaded: bool = false


static func reload() -> void:
	_loaded = false
	_cases = {}
	_textures = {}


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_cases = {}
	if not FileAccess.file_exists(ART_CANDIDATES_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ART_CANDIDATES_PATH))
	if parsed is Dictionary and (parsed as Dictionary).get("cases", null) is Dictionary:
		_cases = (parsed as Dictionary)["cases"]


static func scene_path(case_id: String, scene_id: String) -> String:
	return _entry(case_id, "scenes", scene_id)


static func hotspot_path(case_id: String, hotspot_id: String) -> String:
	return _entry(case_id, "hotspots", hotspot_id)


## 사건·장면에 해당하는 배경 candidate 텍스처. 없으면 null.
static func scene_texture(case_id: String, scene_id: String) -> Texture2D:
	return _load_texture(scene_path(case_id, scene_id))


## 사건·핫스팟에 해당하는 candidate 텍스처. 없으면 null.
static func hotspot_texture(case_id: String, hotspot_id: String) -> Texture2D:
	return _load_texture(hotspot_path(case_id, hotspot_id))


static func _entry(case_id: String, group: String, entry_id: String) -> String:
	_ensure_loaded()
	var case_entry: Variant = _cases.get(case_id, null)
	if not case_entry is Dictionary:
		return ""
	var table: Variant = (case_entry as Dictionary).get(group, null)
	if not table is Dictionary:
		return ""
	var value: Variant = (table as Dictionary).get(entry_id, null)
	if value is Dictionary:
		return String((value as Dictionary).get("path", ""))
	return String(value) if value != null else ""


## 사건·핫스팟에 해당하는 배경 캔버스 픽셀 좌표의 bbox [x, y, w, h] (top-left). 없으면 빈 배열.
static func hotspot_world_box(case_id: String, hotspot_id: String) -> Array:
	_ensure_loaded()
	var case_entry: Variant = _cases.get(case_id, null)
	if not case_entry is Dictionary:
		return []
	var hotspots: Variant = (case_entry as Dictionary).get("hotspots", null)
	if not hotspots is Dictionary:
		return []
	var entry: Variant = (hotspots as Dictionary).get(hotspot_id, null)
	if not entry is Dictionary:
		return []
	var box: Variant = (entry as Dictionary).get("box", null)
	return box if box is Array and box.size() == 4 else []


static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _textures.has(path):
		return _textures[path]
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		var resource: Resource = ResourceLoader.load(path)
		texture = resource as Texture2D if resource is Texture2D else null
	## 그리기 명령은 RID만 들고 있으므로 참조를 붙잡아 두지 않으면 텍스처가 해제돼 흰 사각형으로 그려진다.
	_textures[path] = texture
	return texture
