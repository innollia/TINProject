extends GameModule

## Kit 05 — Stone Story RPG
## 플레이어는 직접 조종하지 않는다. **장비가 AI 정책을 바꾼다.**

const REGION_HUB := "region_under_sign"
const REGION_COMBAT := "region_hollow_cistern"
const CLASS_START := "class_ashbound"

var content: StoneStoryContent = null
var tuning: StoneStoryTuning = null
var state: Dictionary = {}
var load_result: String = ""
var ready_gate: bool = false

var _frame: StoneStoryFrame = null
var _view: StoneStoryView = null
var _lobby: StoneStoryLobby = null
## "lobby" 또는 "expedition". 직접 조종은 전부 로비에서만.
var mode: String = "lobby"
var _pending: Dictionary = {}
var _acc: float = 0.0
var _started: bool = false
var _stream: StoneStoryRng = StoneStoryRng.new(0, "empty")
var _serial: int = 0
var _verb_cache: Dictionary = {}


func _ready() -> void:
	_bootstrap()


func _bootstrap() -> void:
	tuning = StoneStoryTuning.new()
	if tuning.load_all() != OK:
		push_error("StoneStoryRpg: tuning load failed")
		return
	content = StoneStoryContent.new()
	if not content.load_all():
		for e in content.errors:
			push_error("StoneStoryRpg content: " + str(e))
		return
	_build_ui()
	ready_gate = true


func _build_ui() -> void:
	_frame = StoneStoryFrame.new()
	_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_frame)
	_view = StoneStoryView.new()
	_view.visible = false
	_frame.get_view().add_child(_view)
	_lobby = StoneStoryLobby.new()
	_lobby.region_chosen.connect(_on_region_chosen)
	_lobby.star_changed.connect(_on_star_changed)
	_lobby.gear_toggled.connect(_on_gear_toggled)
	_lobby.go_requested.connect(_on_go)
	_frame.get_view().add_child(_lobby)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	if not ready_gate:
		_bootstrap()
	if state.is_empty():
		state = StoneStoryRunState.fresh(tuning, content.get_def("class", CLASS_START))
		if not _pending.is_empty():
			var r: Dictionary = StoneStoryRunState.from_dict(_pending, tuning)
			if not r["state"].is_empty():
				state = r["state"]
				load_result = str(r["result"])
		if str(state["region_id"]).is_empty():
			_start_region(REGION_HUB, 1)
	_pending = {}
	_started = true
	_stream = StoneStoryCore.stream(int(state["run_seed"]), StoneStoryCore.TAG_SIM)
	_enter_lobby()


func exit() -> void:
	_started = false
	_pending = {}
	super.exit()


func save_state() -> Dictionary:
	return StoneStoryRunState.to_dict(state)


func load_state(data: Dictionary) -> void:
	_pending = data.duplicate(true)


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return data.duplicate(true)


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not ready_gate or state.is_empty():
		return false
	if context == null or not context.input_enabled:
		return false
	match command:
		&"ssr_next_region":
			_advance_region()
			return true
		&"ssr_set_star":
			return _set_star(int(payload.get("star", 0)))
		&"ssr_retry":
			_restart_encounter()
			return true
		&"ssr_equip":
			return _equip(str(payload.get("item_id", "")))
		&"ssr_unequip":
			return _unequip(str(payload.get("item_id", "")))
		&"ssr_respec":
			return _do_respec(str(payload.get("stat", "")))
	return false


# --- 로비 (직접 조종 없는 유일한 조작 지점) -----------------------

func _equip(item_id: String) -> bool:
	if item_id.is_empty() or not content.db["item"].has(item_id):
		return false
	var p: Dictionary = state["player"]
	for entry in p["gear"]:
		if str((entry as Dictionary).get("item_id", "")) == item_id:
			return false
	p["gear"].append(StoneStoryContent.make_item_state(item_id))
	p["loadout"]["main"] = item_id
	return true


func _unequip(item_id: String) -> bool:
	var p: Dictionary = state["player"]
	var keep: Array = []
	var removed: bool = false
	for entry in p["gear"]:
		if str((entry as Dictionary).get("item_id", "")) == item_id:
			removed = true
			continue
		keep.append(entry)
	if not removed:
		return false
	p["gear"] = keep
	if str(p["loadout"]["main"]) == item_id:
		p["loadout"]["main"] = str(keep[0].get("item_id", "")) if not keep.is_empty() else ""
	return true


func _set_star(star: int) -> bool:
	if star < 1 or star > 20:
		return false
	state["star_level"] = star
	state["world"]["last_star_level"] = star
	return true


func _do_respec(stat: String) -> bool:
	if not StoneStoryRunState.has_verb(state["player"]["stones"], "respec", _verb_map()):
		return false
	if int(state["respec_used"]) >= int(tuning.e("respec_max")):
		return false
	var p: Dictionary = state["player"]
	if not p["stats"].has(stat):
		return false
	if int(state["world"]["currency"]) < int(tuning.e("respec_cost")):
		return false
	state["world"]["currency"] = int(state["world"]["currency"]) - int(tuning.e("respec_cost"))
	state["respec_used"] = int(state["respec_used"]) + 1
	p["stat_points"] = int(p["stat_points"]) + 1
	StoneStoryRunState.refresh_max(p, tuning)
	return true


# --- 30Hz 틱 -------------------------------------------------------

func _process(_delta: float) -> void:
	if not _started or not ready_gate:
		return
	_pump_input()
	if mode == "lobby":
		return
	_acc += _delta
	var hz: int = maxi(1, tuning.ci("sim_hz"))
	var steps: int = 0
	var cap: int = maxi(1, tuning.ci("max_catchup"))
	while _acc >= 1.0 / float(hz) and steps < cap:
		_acc -= 1.0 / float(hz)
		_tick()
		steps += 1
	if steps >= cap:
		_acc = 0.0


func _tick() -> void:
	var enc: Dictionary = state.get("encounter", {})
	if enc.is_empty():
		state["tick"] = int(state["tick"]) + 1
		return
	var p: Dictionary = state["player"]
	var tick: int = int(state["tick"]) + 1
	state["tick"] = tick
	_serial += 1

	_tick_stamina(p, tick)

	# 4~5. AI 는 장비 정책만 실행한다. 데미지는 판정기가 만든다.
	var intent: Dictionary = StoneStoryPlayerAI.decide(state, enc, content, tuning)
	enc["player_stance"] = str(intent["stance"])
	_player_attack(p, enc, intent, tick)

	# 6. 적 행동
	var order: Array = enc.get("foes", []).duplicate()
	order.sort_custom(func(a, b): return int(a["spawn_index"]) < int(b["spawn_index"]))
	for f in order:
		if not bool(f["alive"]):
			continue
		var def: Dictionary = content.get_def(_kind_of(f), str(f["foe_id"]))
		StoneStoryFoeMachine.refresh_distance(f, p["pos"])
		if not StoneStoryFoeMachine.chill_skips(f, _stream, tick):
			StoneStoryFoeMachine.step(f, def, _stream, tick)
		StoneStoryFoeMachine.move_step(f, p["pos"])
		_foe_attack(f, def, enc, p, tick)

	# 7. 투사체
	_tick_projectiles(enc, p)

	# 8~12
	_reap(enc, p)
	_check_phase(enc, tick)
	_check_end(enc, p, tick)


## 뷰는 상태를 읽기만 한다. 여기서 판정하지 않는다.
func _sync_view() -> void:
	if _view != null:
		_view.encounter = state.get("encounter", {})
		_view.queue_redraw()


func _tick_stamina(p: Dictionary, tick: int) -> void:
	if tick - int(p["last_stamina_spend_tick"]) >= tuning.ci("stamina_regen_delay"):
		p["stamina"] = mini(int(p["stamina_max"]),
				int(p["stamina"]) + int(ceil(tuning.cf("stamina_regen_per_tick"))))


func _player_attack(p: Dictionary, enc: Dictionary, intent: Dictionary, tick: int) -> void:
	var wid: String = str(intent["weapon"])
	if wid.is_empty():
		return
	var weapon: Dictionary = content.item(wid)
	if weapon.is_empty():
		return
	var item: Dictionary = _item_of(p, wid)
	var target_id: String = str(intent["target_id"])
	var acts: int = maxi(1, int(intent["actions_per_turn"]))
	for a in acts:
		for f in enc.get("foes", []):
			if not bool(f["alive"]):
				continue
			if not target_id.is_empty() and str(f["foe_id"]) != target_id:
				continue
			StoneStoryFoeMachine.refresh_distance(f, p["pos"])
			if int(f["dist"]) > int(weapon.get("attack", {}).get("reach", 4)):
				continue
			var me: Dictionary = {
				"attributes": intent["attributes"],
				"affinity_attr": str(p["affinity_attr"]),
				"seed": int(state["run_seed"]),
			}
			var res: Dictionary = StoneStoryCombat.resolve_attack(
					weapon, item, content.db["affix"], p["stats"], tuning, me, f, _serial + a)
			var dmg: float = StoneStoryCombat.apply_stance(float(res["damage"]),
					str(enc.get("player_stance", "neutral")), tuning)
			dmg *= (1.0 - clampf(float(f.get("defense", 0.0)), 0.0, tuning.cf("defense_max")))
			_hit_foe(f, dmg)
			var burst: Array[String] = StoneStoryCombat.accumulate(
					f, weapon.get("status_build", {}), p["stats"], tuning)
			for b in burst:
				_hit_foe(f, StoneStoryCombat.burst_damage(b, float(res["damage"]), p["stats"], tuning))
			StoneStoryCombat.resolve_poise(
					float(weapon.get("attack", {}).get("poise_damage", 10)), f, tick, tuning)


func _hit_foe(f: Dictionary, dmg: float) -> void:
	if dmg <= 0.0:
		return
	f["hp"] = int(f["hp"]) - maxi(1, int(round(dmg)))


func _foe_attack(f: Dictionary, def: Dictionary, enc: Dictionary, p: Dictionary, _tick: int) -> void:
	var sid: String = str(f["state_id"])
	var state_def: Dictionary = def.get("states", {}).get(sid, {})
	var on_enter: String = str(state_def.get("on_enter", ""))
	if on_enter.is_empty() or int(f["state_time"]) != 0:
		return
	for atk_id in f.get("attacks", []):
		var atk: Dictionary = content.get_def("attack", str(atk_id))
		if str(atk.get("handler", "")) == on_enter:
			_fire_attack(atk, f, enc, p)
			return


func _fire_attack(atk: Dictionary, f: Dictionary, enc: Dictionary, p: Dictionary) -> void:
	if int(f["dist"]) > int(atk.get("reach", 4)) + 2:
		return
	if str(enc.get("player_stance", "neutral")) == "evade" and bool(atk.get("evadable", true)):
		return
	var dmg: float = float(f["damage"]) * float(atk.get("damage_mult", 1.0))
	dmg *= (1.0 - _player_defense())
	dmg = StoneStoryCombat.apply_stance(dmg, str(enc.get("player_stance", "neutral")), tuning)
	p["hp"] = int(p["hp"]) - maxi(1, int(round(dmg)))


func _player_defense() -> float:
	var t: int = int(state["player"]["stats"]["toughness"])
	return clampf(tuning.stat_effective(t) * 0.004, 0.0, tuning.cf("defense_max"))


func _tick_projectiles(enc: Dictionary, p: Dictionary) -> void:
	var keep: Array = []
	for pj in enc.get("projectiles", []):
		if bool(pj.get("from_player", false)):
			keep.append(pj)
			continue
		var hit: bool = StoneStoryFoeMachine.step_projectile(pj, p["pos"], 3)
		if hit:
			if str(enc.get("player_stance", "neutral")) == "evade" and bool(pj.get("evadable", true)):
				continue
			p["hp"] = int(p["hp"]) - maxi(1, int(round(float(pj.get("damage", 0)) * (1.0 - _player_defense()))))
			continue
		if int(pj["lifetime"]) > 0:
			keep.append(pj)
	enc["projectiles"] = keep


func _reap(enc: Dictionary, p: Dictionary) -> void:
	for f in enc.get("foes", []):
		if bool(f["alive"]) and int(f["hp"]) <= 0:
			f["alive"] = false
			_grant(f, p)
	var b: Dictionary = enc.get("boss", {})
	if not b.is_empty() and bool(b.get("alive", true)) and int(b["hp"]) <= 0:
		b["alive"] = false
		_grant(b, p)


func _grant(f: Dictionary, p: Dictionary) -> void:
	var drops: Array = f.get("def", {}).get("death_drops", [])
	var money: int = 0
	for d in drops:
		if str(d.get("kind", "")) == "currency":
			money += _stream.range_int(int(f.get("spawn_index", 0)), int(d["min"]), int(d["max"]))
		elif str(d.get("kind", "")) == "material":
			var mid: String = str(d.get("id", "mat_ash"))
			var n: int = _stream.range_int(int(f.get("spawn_index", 0)) + 31, int(d["min"]), int(d["max"]))
			p["inventory"]["materials"][mid] = int(p["inventory"]["materials"].get(mid, 0)) + n
	state["world"]["currency"] = int(state["world"]["currency"]) + money
	StoneStoryRunState.gain_xp(p, int(tuning.e("xp_per_kill")), tuning)


func _check_phase(enc: Dictionary, tick: int) -> void:
	var b: Dictionary = enc.get("boss", {})
	if b.is_empty() or not bool(b.get("alive", true)):
		return
	var chain: Array = enc.get("chain", [])
	var pi: int = int(enc.get("phase_index", 0))
	if pi >= chain.size() - 1:
		return
	if float(b["hp"]) / maxf(1.0, float(b["hp_max"])) > float(chain[pi].get("hp_threshold", 0.0)):
		return
	enc["phase_index"] = pi + 1
	var ndef: Dictionary = content.get_def("boss", str(chain[pi + 1]["foe_id"]))
	if ndef.is_empty():
		return
	var fresh: Dictionary = StoneStoryFoeMachine.make_foe(ndef, tuning, int(enc["star_level"]), int(enc["seed"]))
	fresh["pos"] = b["pos"]
	fresh["is_boss"] = true
	enc["boss"] = fresh


func _check_end(enc: Dictionary, p: Dictionary, tick: int) -> void:
	if str(enc.get("state", "active")) != "active":
		return
	var b: Dictionary = enc.get("boss", {})
	var boss_dead: bool = b.is_empty() or not bool(b.get("alive", true))
	var alive: int = 0
	for f in enc.get("foes", []):
		if bool(f["alive"]):
			alive += 1
	if boss_dead and alive == 0:
		enc["state"] = "cleared"
		enc["cleared_at_tick"] = tick
		state["world"]["loop_point"][str(enc["region_id"])] = p["pos"].duplicate(true)
		var opened: Array = StoneStoryRunState.grant_unlocks(
				state["world"], content.get_def("region", str(enc["region_id"])))
		var line: String = "비웠다. 통화 " + str(int(state["world"]["currency"]))
		if not opened.is_empty():
			var names: Array[String] = []
			for rid in opened:
				names.append(str(content.get_def("region", str(rid)).get("name", rid)))
			line += " · 열림: " + " ".join(names)
		_to_lobby(line)
	elif int(p["hp"]) <= 0:
		enc["state"] = "failed"
		_on_death()
		_to_lobby("쓰러졌다. 남은 것: 통화 " + str(int(state["world"]["currency"])))


func _on_death() -> void:
	var w: Dictionary = state["world"]
	var rid: String = str(state["region_id"])
	# 죽음 페널티 0. 자원·레벨은 남는다.
	if StoneStoryRunState.has_verb(state["player"]["stones"], "loop", _verb_map()) and w["loop_point"].has(rid):
		state["player"]["pos"] = w["loop_point"][rid].duplicate(true)
	else:
		state["player"]["pos"] = {"x": 0, "y": 0}
	_restart_encounter()


func _restart_encounter() -> void:
	state["run_seed"] = maxi(1, absi(int(state["run_seed"]) + 1))
	state["player"]["hp"] = int(state["player"]["hp_max"])
	state["player"]["stamina"] = int(state["player"]["stamina_max"])
	state["encounter"] = StoneStoryEncounter.build(content, tuning, str(state["region_id"]),
			int(state["star_level"]), int(state["run_seed"]), state["player"])
	_stream = StoneStoryCore.stream(int(state["run_seed"]), StoneStoryCore.TAG_SIM)
	_refresh_view()


# --- 지역 ----------------------------------------------------------

func _start_region(region_id: String, star_level: int) -> void:
	state["region_id"] = region_id
	state["star_level"] = star_level
	state["world"]["last_star_level"] = star_level
	state["run_seed"] = maxi(1, ProceduralSeed.combine(ProceduralSeed.hash_text(region_id), star_level))
	state["encounter"] = StoneStoryEncounter.build(content, tuning, region_id, star_level,
			int(state["run_seed"]), state["player"])
	_stream = StoneStoryCore.stream(int(state["run_seed"]), StoneStoryCore.TAG_SIM)
	_refresh_view()


func _advance_region() -> void:
	if str(state["region_id"]) == REGION_HUB:
		_start_region(REGION_COMBAT, maxi(3, int(state["star_level"])))
	else:
		_start_region(REGION_HUB, int(state["star_level"]))


# --- 유틸 ----------------------------------------------------------

func _kind_of(f: Dictionary) -> String:
	return "boss" if bool(f.get("is_boss", false)) else "foe"


func _item_of(p: Dictionary, item_id: String) -> Dictionary:
	for entry in p.get("gear", []):
		var inst: Dictionary = entry
		if str(inst.get("item_id", "")) == item_id:
			return inst
	return StoneStoryContent.make_item_state(item_id)


## 로비 -> 탐험. 플레이어가 누르는 유일한 큰 버튼.
func _on_go() -> void:
	if String(state["region_id"]) != String(_pending_region):
		_start_region(String(_pending_region), int(_pending_star))
	state["encounter"] = StoneStoryEncounter.build(content, tuning, String(state["region_id"]),
			int(state["star_level"]), int(state["run_seed"]), state["player"])
	_stream = StoneStoryCore.stream(int(state["run_seed"]), StoneStoryCore.TAG_SIM)
	mode = "expedition"
	if _view != null:
		_view.visible = true
	if _lobby != null:
		_lobby.visible = false
	_refresh_view()


## 탐험 끝나면 로비로. 결과 1줄이 남는다.
func _to_lobby(line: String = "") -> void:
	mode = "lobby"
	if _view != null:
		_view.visible = false
	if _lobby != null:
		_lobby.visible = true
		_lobby.bind(state, content, tuning)
		_lobby.restore_focus()
		if not line.is_empty():
			_lobby.report.push_front(line)
			while _lobby.report.size() > 4:
				_lobby.report.pop_back()


func _enter_lobby() -> void:
	mode = "lobby"
	_pending_region = String(state.get("region_id", REGION_HUB))
	_pending_star = int(state.get("star_level", 1))
	if _view != null:
		_view.visible = false
	if _lobby != null:
		_lobby.visible = true
		_lobby.bind(state, content, tuning)


var _pending_region: String = REGION_HUB
var _pending_star: int = 1


func _on_region_chosen(rid: String) -> void:
	if _lobby != null and not _lobby.is_open(rid):
		return                     # R5: disabled 는 intent 를 내보내지 않는다
	_pending_region = rid


func _on_star_changed(value: int) -> void:
	_pending_star = value
	state["star_level"] = value


func _on_gear_toggled(item_id: String) -> void:
	if item_id.is_empty():
		return
	var p: Dictionary = state["player"]
	var has: bool = false
	var keep: Array = []
	for g in p["gear"]:
		if str((g as Dictionary).get("item_id", "")) == item_id:
			has = true
			continue
		keep.append(g)
	if has:
		p["gear"] = keep
	else:
		p["gear"].append(StoneStoryContent.make_item_state(item_id))
	if _lobby != null:
		_lobby.bind(state, content, tuning)


## 로비에서만 입력을 받는다. 탐험 중에는 어떤 키도 AI 를 못 건드린다.
const LOBBY_ACTIONS: Array[StringName] = [
	&"stone_story_rpg_up", &"stone_story_rpg_down", &"stone_story_rpg_left",
	&"stone_story_rpg_right", &"stone_story_rpg_confirm", &"stone_story_rpg_cancel",
]


func _pressed(action: StringName) -> bool:
	return context != null and context.allows_action(action) and Input.is_action_just_pressed(action)


func _lobby_allows() -> bool:
	return context != null and context.input_enabled


func _pump_input() -> void:
	if context == null or not context.input_enabled:
		return
	if mode == "lobby":
		# 실제 키가 눌린 프레임에만 넘긴다. 매 프레임 보내면 focus 가 회전한다.
		if _lobby == null or not _lobby_allows():
			return
		for action in LOBBY_ACTIONS:
			if _pressed(action) and _lobby.handle(action):
				return
		return
	# 탐험 중에는 취소로 로비 복귀만 허용한다.
	# ModuleContext 에 just_pressed 가 없으므로 허용 액션을 직접 확인한다.
	if _pressed(&"stone_story_rpg_cancel"):
		_to_lobby("돌아왔다")


func _refresh_view() -> void:
	if _view == null:
		return
	_view.bind(state, state.get("encounter", {}),
			content.get_def("region", str(state.get("region_id", ""))), content, tuning)


func _verb_map() -> Dictionary:
	if _verb_cache.is_empty():
		for sid in content.ids("stone"):
			_verb_cache[str(sid)] = str(content.get_def("stone", str(sid)).get("verb", ""))
	return _verb_cache
