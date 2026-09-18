extends GameModule

const ACTIONS: Array[StringName] = [&"glyph_gallery_left", &"glyph_gallery_right", &"glyph_gallery_up", &"glyph_gallery_down", &"glyph_gallery_confirm", &"glyph_gallery_cancel"]
const SYMBOLS: Array[String] = ["○", "◇", "△"]
const RULES: Array[String] = ["원은 아래", "마름모는 왼쪽", "삼각은 위"]

var station: int = 0
var seen: Array[bool] = [false, false, false]
var _held: Dictionary = {}
var _request_sent: bool = false
var _status: Label
var _cards: Array[ColorRect] = []

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("241b35")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("접힌 기호관", Vector2(64, 60), 42, Color("f0d5ff"))
	_label("표찰은 방향을 말하지 않고 몸짓을 남긴다.", Vector2(66, 118), 20, Color("bea9cb"))
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(105 + index * 350, 220)
		card.size = Vector2(240, 260)
		card.color = Color("463557")
		background.add_child(card)
		_cards.append(card)
		_label(SYMBOLS[index], card.position + Vector2(120, 105), 70, Color("ffd58a"), true)
		_label(["낮은 종", "접힌 거울", "마른 깃발"][index], card.position + Vector2(120, 195), 18, Color("f4e9f7"), true)
	_label("←→ 전시대 이동   Z 읽기·통과   X 다시 읽기", Vector2(64, 560), 20, Color("f0d5ff"))
	_status = _label("첫 표찰 앞에 섰다.", Vector2(64, 620), 19, Color("bea9cb"))
	_refresh()

func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_refresh()

func exit() -> void:
	_held.clear()
	super.exit()

func _process(_delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
	for index: int in range(ACTIONS.size()):
		var pressed: bool = context.is_action_pressed(ACTIONS[index])
		var previous: bool = bool(_held.get(ACTIONS[index], false))
		_held[ACTIONS[index]] = pressed
		if pressed and not previous:
			if index == 0: execute_command(&"move", {"direction": "left"})
			elif index == 1: execute_command(&"move", {"direction": "right"})
			elif index >= 4: execute_command(&"observe")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"move":
			var direction: Variant = payload.get("direction")
			if direction == "left": station = maxi(0, station - 1)
			elif direction == "right": station = mini(2, station + 1)
			else: return false
		&"observe":
			seen[station] = true
			var words: String = "%s. %s 쪽으로 몸을 기울이라는 뜻이었다." % [RULES[station], RULES[station].get_slice(" ", 1)]
			_status.text = words
			requested.emit(&"observation", {"id": "glyph_gallery.rule_%d" % station, "text": words})
			if station == 2 and not seen.has(false):
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"station": station, "seen": seen.duplicate()}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	station = int(clean["station"])
	seen.assign(clean["seen"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_seen: Array[bool] = [false, false, false]
	if data.get("seen") is Array and data["seen"].size() == 3:
		for index: int in range(3): clean_seen[index] = data["seen"][index] is bool and data["seen"][index]
	var value: Variant = data.get("station")
	var clean_station: int = clampi(int(value), 0, 2) if value is int or value is float else 0
	return {"station": clean_station, "seen": clean_seen}

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(_cards.size()):
		_cards[index].color = Color("76548b") if index == station else Color("463557")

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 80)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered:
		label.position.x -= 500
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
