extends SceneTree
## g06 recipes/scene_s0N_*.json에서 물건 배치를 읽어 art_candidates.json에 배경 캔버스 좌표(px, 2560x1440)로
## bbox(top-left+size)를 굽는 1회성 빌드 도구. compose_preview.py와 같은 산수(pos = at - pivot)를 쓴다.
## 실행 후 art_candidates.json을 다시 쓰고 끝난다(게임 코드는 건드리지 않음).

const OUT_PATH := "res://modules/deduction_casework/content/art_candidates.json"

const RECIPE_DIRS := {
	1: "C:/Users/fixme/Desktop/TINProject/assets/art/deduction_casework/jobs/g06-stage01-v01/recipes/",
	2: "C:/Users/fixme/Desktop/TINProject/assets/art/deduction_casework/jobs/g06-stage02-v01/recipes/",
	3: "C:/Users/fixme/Desktop/TINProject/assets/art/deduction_casework/jobs/g06-stage03-v01/recipes/",
}
const OUTPUT_DIRS := {
	1: "res://assets/art/deduction_casework/jobs/g06-stage01-v01/output/",
	2: "res://assets/art/deduction_casework/jobs/g06-stage02-v01/output/",
	3: "res://assets/art/deduction_casework/jobs/g06-stage03-v01/output/",
}

const SCENE_STAGE := {
	"case_01_saint_orin": {"scene_lab": ["1", "scene_s01_lab"], "scene_booth": ["1", "scene_s01_booth"], "scene_locker": ["1", "scene_s01_locker"], "scene_corridor": ["1", "scene_s01_corridor"]},
	"case_02_morren_empty_chair": {"scene_dining": ["2", "scene_s02_dining"], "scene_foyer": ["2", "scene_s02_foyer"], "scene_study": ["2", "scene_s02_study"], "scene_service": ["2", "scene_s02_service"], "scene_grave": ["2", "scene_s02_grave"]},
	"case_03_n153_last_tour": {"scene_chamber": ["3", "scene_s03_chamber"], "scene_control": ["3", "scene_s03_control"], "scene_locker": ["3", "scene_s03_locker"], "scene_service": ["3", "scene_s03_service"], "scene_seal": ["3", "scene_s03_seal"]},
}

## 핫스팟id -> 대표 item id (recipe hotspots 값의 첫 asset#part 또는 asset명에서 items[].id를 찾아 매칭)
const HOTSPOT_ITEM := {
	"case_01_saint_orin": {
		"hotspot_lab_bench": "bench", "hotspot_lab_lens_case": "lens_case",
		"hotspot_lab_stim_calibration": "printer", "hotspot_lab_stim_behavior": "printer",
		"hotspot_lab_task_board": "task_board", "hotspot_lab_grell_gauze": "gauze",
		"hotspot_booth_eye_card": "eye_card", "hotspot_booth_recorder": "recorder",
		"hotspot_booth_log_sheet": "log_sheet", "hotspot_booth_grell_pager": "pager",
		"hotspot_locker_cabinet": "locker", "hotspot_locker_coat": "labcoat",
		"hotspot_locker_notebook": "notebook", "hotspot_locker_sketchbook": "sketchbook",
		"hotspot_locker_repair_card": "repair_card", "hotspot_locker_name_cards": "name_cards",
		"hotspot_locker_roster": "roster",
		"hotspot_corridor_instruments": "disinfect_tool", "hotspot_corridor_copier": "copier",
		"hotspot_corridor_guard_log": "guard_board",
	},
	"case_02_morren_empty_chair": {
		"hotspot_dining_guest_seat": "guest_setting", "hotspot_dining_visual_seats": "chair_silla",
		"hotspot_dining_seat_plan": "seat_plan", "hotspot_dining_silla_cup": "silla_cup",
		"hotspot_dining_ruca_pocket": "chr_s02_luca_stand",
		"hotspot_foyer_attendance": "attendance", "hotspot_foyer_photos": "photos",
		"hotspot_foyer_yona_bag": "yona_bag", "hotspot_foyer_shoes": "shoes",
		"hotspot_study_record_gap": "safe", "hotspot_study_will": "desk",
		"hotspot_study_silla": "chr_s02_silla_slumped", "hotspot_study_window_sill": "sill_soil",
		"hotspot_service_peter": "chr_s02_peter_stand", "hotspot_service_key_list": "key_board", "hotspot_service_payroll": "payroll",
		"hotspot_grave_footprints": "footprints", "hotspot_grave_case44": "case44_page",
	},
	"case_03_n153_last_tour": {
		"hotspot_chamber_debris": "debris", "hotspot_chamber_shoes": "shoes", "hotspot_chamber_n_lux": "nlux", "hotspot_chamber_derral": "chr_s03_derral_axe",
		"hotspot_control_entry_log": "entry_printer", "hotspot_control_skeleton_scan": "scan", "hotspot_control_dorn_draft": "terminal",
		"hotspot_control_dorn_call": "phone", "hotspot_control_conflict_envelope": "envelope",
		"hotspot_locker_overcoat": "overshoes", "hotspot_locker_ri_an_locker": "rian_locker", "hotspot_locker_door_film": "door_film",
		"hotspot_service_key_board": "key_board", "hotspot_service_interlock": "interlock", "hotspot_service_demo_tape": "tape_reader", "hotspot_service_residual_checklist": "cap_checklist",
		"hotspot_seal_receipt": "table", "hotspot_seal_notebook": "table",
	},
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var cases: Dictionary = {}
	for case_id: String in SCENE_STAGE:
		var scenes: Dictionary = {}
		var hotspots: Dictionary = {}
		for scene_id: String in SCENE_STAGE[case_id]:
			var pair: Array = SCENE_STAGE[case_id][scene_id]
			var stage: int = int(pair[0])
			var recipe_path: String = RECIPE_DIRS[stage] + String(pair[1]) + ".json"
			var recipe: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(recipe_path))
			var bg_path: String = OUTPUT_DIRS[stage] + String(recipe["background"]).replace("output/", "")
			scenes[scene_id] = {"path": bg_path, "canvas": recipe.get("canvas_size", [2560, 1440])}
			var items_by_id: Dictionary = {}
			for item: Dictionary in recipe.get("items", []):
				items_by_id[String(item.get("id", ""))] = item
			var characters_by_asset: Dictionary = {}
			for character: Dictionary in recipe.get("characters", []):
				characters_by_asset[String(character.get("asset", ""))] = character
			for hotspot_id: String in HOTSPOT_ITEM.get(case_id, {}).keys():
				if not recipe.get("hotspots", {}).has(hotspot_id):
					continue
				var item_id: String = HOTSPOT_ITEM[case_id][hotspot_id]
				var item: Dictionary = {}
				if items_by_id.has(item_id):
					item = items_by_id[item_id]
				elif item_id.begins_with("chr_") and characters_by_asset.has(item_id):
					item = characters_by_asset[item_id]
				if item.is_empty():
					continue
				var box := _bbox(stage, item)
				if box.is_empty():
					continue
				hotspots[hotspot_id] = box
		cases[case_id] = {"scenes": scenes, "hotspots": hotspots}
	var doc := {
		"schema_version": 3,
		"note": "g06 그림 세션 candidate(미승인) 경로 + 배경 캔버스 픽셀 좌표(px, background 원본 해상도 기준). box=[x,y,w,h] top-left. 그림 복사·수정 없음. 파일이나 좌표가 없으면 placeholder.",
		"cases": cases,
	}
	var file := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(doc, "  "))
	file.close()
	print("WROTE ", OUT_PATH)
	for case_id: String in cases:
		print(case_id, " hotspots_with_box=", cases[case_id]["hotspots"].size(), "/", HOTSPOT_ITEM.get(case_id, {}).size())
	quit(0)


func _bbox(stage: int, item: Dictionary) -> Dictionary:
	var asset: String = String(item.get("asset", ""))
	var frame: String = String(item.get("frame", asset))
	var manifest_path: String = OUTPUT_DIRS[stage] + asset + "/" + frame + ".json"
	if not FileAccess.file_exists(manifest_path):
		return {}
	var man: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var size: Array = man.get("size", [])
	var pivot: Array = man.get("pivot", [0, 0])
	var at: Array = item.get("at", [])
	if size.size() < 2 or at.size() < 2:
		return {}
	var x: float = float(at[0]) - float(pivot[0])
	var y: float = float(at[1]) - float(pivot[1])
	return {"path": OUTPUT_DIRS[stage] + asset + "/" + frame + ".png", "box": [x, y, float(size[0]), float(size[1])]}
