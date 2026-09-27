extends RefCounted
## g06 아트 세션(candidate, 승인 전) 산출물의 res:// 경로만 참조하는 module-local 조회기.
## 그림 파일을 복사·수정하지 않는다. 파일이 없으면 호출부가 placeholder로 되돌아간다.

const ART_CANDIDATES_PATH: String = "res://modules/deduction_casework/content/art_candidates.json"

static var _cache: Dictionary = {}
static var _loaded: bool = false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_cache = {"scenes": {}, "hotspots": {}}
	if not FileAccess.file_exists(ART_CANDIDATES_PATH):
		return
	var file := FileAccess.open(ART_CANDIDATES_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var dict := parsed as Dictionary
		_cache["scenes"] = dict.get("scenes", {}) if dict.get("scenes", {}) is Dictionary else {}
		_cache["hotspots"] = dict.get("hotspots", {}) if dict.get("hotspots", {}) is Dictionary else {}


## scene_id에 해당하는 배경 candidate 텍스처. 없으면 null.
static func scene_texture(scene_id: String) -> Texture2D:
	_ensure_loaded()
	return _load_texture(String((_cache["scenes"] as Dictionary).get(scene_id, "")))


## hotspot_id(=box_id)에 해당하는 candidate 텍스처. 없으면 null.
static func hotspot_texture(hotspot_id: String) -> Texture2D:
	_ensure_loaded()
	return _load_texture(String((_cache["hotspots"] as Dictionary).get(hotspot_id, "")))


static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = ResourceLoader.load(path)
	return resource as Texture2D if resource is Texture2D else null
