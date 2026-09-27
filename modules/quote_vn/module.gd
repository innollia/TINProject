## 인용된 사랑: 모든 묘사와 대사가 고전 소설의 인용구인 비주얼노벨.
## 마우스: 클릭으로 진행, 버튼 클릭. 키보드: Space/Enter 진행, 1~5·방향키 선택, L 로그, A 자동, S 스킵, Esc 닫기/처음.
extends GameModule

const Story := preload("res://modules/quote_vn/core/story.gd")
const TransitionShader := preload("res://modules/quote_vn/ui/transition.gdshader")
const Portrait := preload("res://modules/quote_vn/ui/portrait.gd")
const CORPUS_DIR := "res://modules/quote_vn/corpus/"
const PALETTE := {
	"pride": [Color("2c3e50"), Color("8e6f5a"), Color("f3d6c6"), Color("5a3b2e")],
	"jane": [Color("1d1f2b"), Color("4b4f63"), Color("e9dcd0"), Color("2a1f1c")],
	"persuasion": [Color("20394a"), Color("6f93a3"), Color("f1ddd2"), Color("6b4a3a")],
	"chunhyang": [Color("3a1f2b"), Color("b0574f"), Color("f6dccc"), Color("1a1414")],
	"dongbaek": [Color("2e3a1f"), Color("c4604f"), Color("f0d2bf"), Color("2b1d14")],
	"bombom": [Color("33401f"), Color("9fb05a"), Color("f0d2bf"), Color("2b1d14")],
}
const TYPE_SPEED := 45.0

var story: Story
var corpora: Array = []
var ev: Dictionary = {}
var waiting_choice := false
var busy := false
var auto_mode := false
var skip_mode := false
var auto_timer := 0.0
var log_lines: PackedStringArray = []
var seed_value := 0
var fx_index := 0
var on_title := true

var bg_top: ColorRect
var bg_bottom: ColorRect
var portrait: Control
var name_panel: PanelContainer
var name_label: Label
var text_panel: PanelContainer
var ko_label: RichTextLabel
var orig_label: Label
var source_label: Label
var next_mark: Label
var choice_box: VBoxContainer
var prompt_label: Label
var menu: HBoxContainer
var auto_btn: Button
var skip_btn: Button
var log_panel: PanelContainer
var log_text: RichTextLabel
var banner: Label
var banner_sub: Label
var title_layer: Control
var overlay: ColorRect
var flash: ColorRect
var stage: Control
var font_serif: SystemFont
var font_sans: SystemFont


func _ready() -> void:
	font_serif = SystemFont.new()
	font_serif.font_names = PackedStringArray(["Batang", "Gungsuh", "Malgun Gothic", "Noto Serif CJK KR"])
	font_sans = SystemFont.new()
	font_sans.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR"])
	corpora = load_corpora()
	_build_ui()
	_show_title()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	if value != null:
		value.input_enabled = true


## 작품 묶음: corpus/set.json의 순서(가~마). 파일만 바꿔 끼우면 다른 묶음이 된다.
static func load_corpora() -> Array:
	var ids: Array = ["pride", "jane", "persuasion", "chunhyang", "dongbaek"]
	var set_path := CORPUS_DIR + "set.json"
	if FileAccess.file_exists(set_path):
		var s = JSON.parse_string(FileAccess.get_file_as_string(set_path))
		if typeof(s) == TYPE_DICTIONARY and s.has("works"):
			ids = s.works
	var out: Array = []
	for id in ids:
		var p: String = CORPUS_DIR + str(id) + ".json"
		if FileAccess.file_exists(p):
			var c = JSON.parse_string(FileAccess.get_file_as_string(p))
			if typeof(c) == TYPE_DICTIONARY and c.pairs.size() > 0:
				out.append(c)
	return out


# ---------------------------------------------------------------- UI 구성
func _panel_style(bg: Color, border: Color, radius := 14) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 8
	return sb


func _button(text: String, cb: Callable, min_w := 96, focusable := true) -> Button:
	var b := Button.new()
	if not focusable:
		b.focus_mode = Control.FOCUS_NONE
	b.text = text
	b.custom_minimum_size = Vector2(min_w, 38)
	b.add_theme_font_override("font", font_sans)
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_stylebox_override("normal", _panel_style(Color(0.08, 0.06, 0.1, 0.7), Color(1, 1, 1, 0.25), 10))
	b.add_theme_stylebox_override("hover", _panel_style(Color(0.35, 0.18, 0.28, 0.9), Color("f5c6d6"), 10))
	b.add_theme_stylebox_override("focus", _panel_style(Color(0.35, 0.18, 0.28, 0.9), Color("ffe08a"), 10))
	b.add_theme_stylebox_override("pressed", _panel_style(Color(0.5, 0.25, 0.35, 1), Color("ffe08a"), 10))
	b.pressed.connect(cb)
	return b


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	stage = Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(stage)
	bg_top = ColorRect.new()
	bg_top.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(bg_top)
	bg_bottom = ColorRect.new()
	bg_bottom.anchor_left = 0; bg_bottom.anchor_right = 1; bg_bottom.anchor_top = 0.55; bg_bottom.anchor_bottom = 1
	stage.add_child(bg_bottom)
	# 창문 빛줄기(배경 장식)
	for i in 4:
		var beam := ColorRect.new()
		beam.color = Color(1, 1, 1, 0.04)
		beam.position = Vector2(140 + i * 260, 0)
		beam.size = Vector2(90, 720)
		beam.rotation = -0.25
		stage.add_child(beam)
	portrait = Portrait.new()
	portrait.position = Vector2(440, 70)
	portrait.size = Vector2(400, 470)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(portrait)
	# 클릭으로 진행하는 투명 영역
	var click := Button.new()
	click.flat = true
	click.focus_mode = Control.FOCUS_NONE
	click.set_anchors_preset(Control.PRESET_FULL_RECT)
	click.pressed.connect(_advance)
	stage.add_child(click)
	# 대사창
	text_panel = PanelContainer.new()
	text_panel.position = Vector2(90, 500)
	text_panel.size = Vector2(1100, 190)
	text_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.04, 0.08, 0.86), Color(1, 0.85, 0.9, 0.5), 18))
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(text_panel)
	var tv := VBoxContainer.new()
	tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tv.add_theme_constant_override("separation", 6)
	text_panel.add_child(tv)
	ko_label = RichTextLabel.new()
	ko_label.fit_content = true
	ko_label.bbcode_enabled = false
	ko_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ko_label.add_theme_font_override("normal_font", font_serif)
	ko_label.add_theme_font_size_override("normal_font_size", 25)
	ko_label.custom_minimum_size = Vector2(1050, 70)
	tv.add_child(ko_label)
	orig_label = Label.new()
	orig_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	orig_label.add_theme_font_override("font", font_serif)
	orig_label.add_theme_font_size_override("font_size", 15)
	orig_label.modulate = Color(1, 1, 1, 0.6)
	orig_label.custom_minimum_size = Vector2(1050, 0)
	tv.add_child(orig_label)
	source_label = Label.new()
	source_label.add_theme_font_override("font", font_sans)
	source_label.add_theme_font_size_override("font_size", 14)
	source_label.modulate = Color("ffe08a")
	source_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tv.add_child(source_label)
	next_mark = Label.new()
	next_mark.text = "▼"
	next_mark.position = Vector2(1160, 660)
	next_mark.modulate = Color("ffe08a")
	stage.add_child(next_mark)
	# 이름표
	name_panel = PanelContainer.new()
	name_panel.position = Vector2(110, 462)
	name_panel.add_theme_stylebox_override("panel", _panel_style(Color("7a2f4a"), Color("ffd3e0"), 12))
	name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(name_panel)
	name_label = Label.new()
	name_label.add_theme_font_override("font", font_sans)
	name_label.add_theme_font_size_override("font_size", 20)
	name_panel.add_child(name_label)
	# 선택지
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(cc)
	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 10)
	choice_box.custom_minimum_size = Vector2(980, 0)
	cc.add_child(choice_box)
	prompt_label = Label.new()
	prompt_label.add_theme_font_override("font", font_serif)
	prompt_label.add_theme_font_size_override("font_size", 22)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# 메뉴
	menu = HBoxContainer.new()
	menu.position = Vector2(760, 16)
	menu.add_theme_constant_override("separation", 8)
	stage.add_child(menu)
	menu.add_child(_button("로그 (L)", _toggle_log, 96, false))
	auto_btn = _button("자동 (A)", _toggle_auto, 96, false)
	menu.add_child(auto_btn)
	skip_btn = _button("스킵 (S)", _toggle_skip, 96, false)
	menu.add_child(skip_btn)
	menu.add_child(_button("처음 (Esc)", _show_title, 96, false))
	# 가운데 알림(갈림길·결말)
	banner = Label.new()
	banner.position = Vector2(0, 180)
	banner.size = Vector2(1280, 60)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_override("font", font_serif)
	banner.add_theme_font_size_override("font_size", 38)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_theme_constant_override("outline_size", 8)
	stage.add_child(banner)
	banner_sub = Label.new()
	banner_sub.position = Vector2(0, 240)
	banner_sub.size = Vector2(1280, 40)
	banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_sub.add_theme_font_override("font", font_sans)
	banner_sub.add_theme_font_size_override("font_size", 18)
	banner_sub.add_theme_color_override("font_outline_color", Color.BLACK)
	banner_sub.add_theme_constant_override("outline_size", 6)
	stage.add_child(banner_sub)
	# 로그
	log_panel = PanelContainer.new()
	log_panel.position = Vector2(140, 70)
	log_panel.size = Vector2(1000, 580)
	log_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.03, 0.06, 0.95), Color("ffd3e0"), 16))
	log_panel.visible = false
	root.add_child(log_panel)
	var lv := VBoxContainer.new()
	log_panel.add_child(lv)
	var lt := Label.new()
	lt.text = "지난 대화  (L 또는 Esc로 닫기, 휠·방향키로 넘기기)"
	lt.add_theme_font_override("font", font_sans)
	lv.add_child(lt)
	log_text = RichTextLabel.new()
	log_text.custom_minimum_size = Vector2(950, 470)
	log_text.scroll_following = true
	log_text.focus_mode = Control.FOCUS_ALL
	log_text.add_theme_font_override("normal_font", font_serif)
	log_text.add_theme_font_size_override("normal_font_size", 17)
	lv.add_child(log_text)
	lv.add_child(_button("닫기", _toggle_log))
	# 타이틀
	title_layer = Control.new()
	title_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_layer)
	var tbg := ColorRect.new()
	tbg.set_anchors_preset(Control.PRESET_FULL_RECT)
	tbg.color = Color("140d16")
	title_layer.add_child(tbg)
	var tvb := VBoxContainer.new()
	tvb.position = Vector2(340, 170)
	tvb.custom_minimum_size = Vector2(600, 0)
	tvb.add_theme_constant_override("separation", 14)
	title_layer.add_child(tvb)
	var t1 := Label.new()
	t1.text = "인용된 사랑"
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.add_theme_font_override("font", font_serif)
	t1.add_theme_font_size_override("font_size", 64)
	t1.add_theme_color_override("font_color", Color("ffd3e0"))
	tvb.add_child(t1)
	var t2 := Label.new()
	var names: PackedStringArray = []
	for c in corpora:
		names.append("%s 「%s」" % [c.slot, c.title_ko])
	t2.text = "모든 묘사와 대사는 고전의 한 구절입니다\n" + "  ".join(names)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t2.add_theme_font_override("font", font_sans)
	t2.add_theme_font_size_override("font_size", 17)
	tvb.add_child(t2)
	var sb := _button("이야기 시작  (Enter)", _start_new, 300)
	sb.name = "StartButton"
	tvb.add_child(sb)
	var hint := Label.new()
	hint.text = "마우스: 클릭으로 진행 · 키보드: Space/Enter 진행, 1~5 또는 ↑↓ 선택"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_override("font", font_sans)
	hint.modulate = Color(1, 1, 1, 0.55)
	tvb.add_child(hint)
	# 전환 효과 덮개와 섬광
	overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = TransitionShader
	overlay.material = mat
	root.add_child(overlay)
	flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(flash)


# ---------------------------------------------------------------- 전환 효과
## mode: 0 페이드 1 와이프 2 블라인드 3 조리개 4 디졸브 5 대각선
func transition(mode: int, mid: Callable, tint := Color.BLACK, dur := 0.45) -> void:
	busy = true
	var mat: ShaderMaterial = overlay.material
	mat.set_shader_parameter("mode", mode)
	mat.set_shader_parameter("tint", tint)
	if skip_mode:
		dur = 0.05
	var tw := create_tween()
	tw.tween_method(func(v): mat.set_shader_parameter("progress", v), 0.0, 1.0, dur)
	await tw.finished
	mid.call()
	var tw2 := create_tween()
	tw2.tween_method(func(v): mat.set_shader_parameter("progress", v), 1.0, 0.0, dur)
	await tw2.finished
	busy = false


func shake(strength := 12.0) -> void:
	var tw := create_tween()
	for i in 6:
		tw.tween_property(stage, "position", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), 0.04)
	tw.tween_property(stage, "position", Vector2.ZERO, 0.05)


func do_flash(c := Color(1, 1, 1, 0.8)) -> void:
	flash.color = c
	create_tween().tween_property(flash, "color:a", 0.0, 0.5)


func _apply_palette(work: String) -> void:
	var p: Array = PALETTE.get(work, PALETTE.pride)
	bg_top.color = p[0]
	bg_bottom.color = p[1].darkened(0.4)
	portrait.tint = p[2]
	portrait.hair = p[3]


# ---------------------------------------------------------------- 흐름
func _show_title() -> void:
	on_title = true
	auto_mode = false
	skip_mode = false
	_update_mode_buttons()
	log_panel.visible = false
	title_layer.visible = true
	var sb: Button = title_layer.find_child("StartButton", true, false)
	if sb:
		sb.grab_focus()


func _start_new() -> void:
	if corpora.is_empty():
		banner.text = "작품 묶음(corpus)을 찾지 못했습니다"
		return
	seed_value = randi() if seed_value == 0 else seed_value
	start_story(seed_value)
	seed_value = 0


func start_story(s: int) -> void:
	story = Story.new()
	story.setup(corpora, s)
	log_lines.clear()
	on_title = false
	var mid := func():
		title_layer.visible = false
		_apply_palette(corpora[0].id)
		_clear_choices()
	await transition(3, mid)
	_advance()


func _clear_choices() -> void:
	for c in choice_box.get_children():
		choice_box.remove_child(c)
		if c != prompt_label:
			c.queue_free()
	waiting_choice = false


func _set_text(name_text: String, ko: String, orig: String, src: String) -> void:
	name_panel.visible = name_text != ""
	name_label.text = name_text
	ko_label.text = ko
	ko_label.visible_characters = 0 if not skip_mode else -1
	orig_label.text = orig
	source_label.text = src
	text_panel.visible = true
	log_lines.append(("[%s] " % name_text if name_text != "" else "") + ko + ("\n    " + orig if orig != "" else "") + "\n    — " + src)


func _typing_done() -> bool:
	return ko_label.visible_characters < 0 or ko_label.visible_characters >= ko_label.get_total_character_count()


func _advance() -> void:
	if on_title or busy or waiting_choice or story == null or log_panel.visible:
		return
	if not _typing_done():
		ko_label.visible_characters = -1
		return
	banner.text = ""
	banner_sub.text = ""
	ev = story.next_event()
	_show_event(ev)


func _src(e: Dictionary, who: String) -> String:
	return "%s 「%s」 %s · %s" % [e.slot, e.title, e.author, who]


func _show_event(e: Dictionary) -> void:
	match e.type:
		"title":
			text_panel.visible = false
			name_panel.visible = false
			banner.text = e.text
			banner_sub.text = e.sub
			do_flash(Color(1, 0.9, 0.95, 0.5))
		"narration":
			var en: bool = e.lang == "en"
			_set_text("", e.ko, e.orig if en else "", _src(e, "서술"))
		"hero":
			_set_text("나", e.ko, e.orig if e.lang == "en" else "", _src(e, "남자 주인공의 대사"))
		"heroine":
			_apply_palette(e.work)
			portrait.mood = 1.0
			_set_text(story.works[e.work].heroine, e.ko, e.orig if e.lang == "en" else "", _src(e, "히로인의 대사"))
		"choice":
			_show_choice(e)
		"crossroad":
			fx_index = (fx_index + 1) % 3
			var modes := [2, 4, 5]
			var mid := func():
				text_panel.visible = false
				name_panel.visible = false
				banner.text = e.text
				banner_sub.text = e.ratio
			await transition(modes[fx_index], mid, Color("1a0a12"), 0.6)
			shake(14.0)
			do_flash(Color(1, 0.3, 0.4, 0.45))
		"ending":
			var mid2 := func():
				_apply_palette(e.work)
				text_panel.visible = false
				name_panel.visible = false
				banner.text = "끝 — " + e.text
				banner_sub.text = e.ratio + "\n(Enter 또는 클릭: 처음으로)"
			await transition(0, mid2, Color.WHITE, 0.9)
			do_flash(Color(1, 1, 1, 0.6))
		"end":
			_show_title()


func _show_choice(e: Dictionary) -> void:
	var build := func():
		_clear_choices()
		text_panel.visible = false
		name_panel.visible = false
		prompt_label.text = e.prompt + "  (1~%d, ↑↓, Enter, 클릭)" % e.options.size()
		choice_box.add_child(prompt_label)
		for i in e.options.size():
			var o: Dictionary = e.options[i]
			var label := "%d.  %s" % [i + 1, o.ko]
			if o.lang == "en":
				label += "\n      " + o.orig
			label += "\n      — %s 「%s」" % [o.slot, o.title]
			var b := _button(label, _on_choice.bind(i), 960)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			b.add_theme_font_override("font", font_serif)
			choice_box.add_child(b)
		waiting_choice = true
		(choice_box.get_child(1) as Button).grab_focus()
	await transition(1 if e.kind == "talk" else 3, build, Color(0.05, 0.02, 0.05, 1), 0.25)


func _on_choice(i: int) -> void:
	if not waiting_choice or busy:
		return
	story.choose(ev, i)
	var o: Dictionary = ev.options[i]
	if ev.kind == "desc":
		log_lines.append("[묘사 선택] " + o.ko + "\n    — " + o.slot + " 「" + o.title + "」")
	_clear_choices()
	if ev.kind == "desc":
		_apply_palette(o.work)
		_set_text("", o.ko, o.orig if o.lang == "en" else "", _src(o, "히로인 묘사"))
		portrait.mood = 0.6
	else:
		_advance()


# ---------------------------------------------------------------- 메뉴
func _toggle_log() -> void:
	if on_title:
		return
	log_panel.visible = not log_panel.visible
	if log_panel.visible:
		log_text.text = "\n\n".join(log_lines)
		log_text.grab_focus()


func _toggle_auto() -> void:
	auto_mode = not auto_mode
	skip_mode = false if auto_mode else skip_mode
	_update_mode_buttons()


func _toggle_skip() -> void:
	skip_mode = not skip_mode
	auto_mode = false if skip_mode else auto_mode
	_update_mode_buttons()


func _update_mode_buttons() -> void:
	if auto_btn:
		auto_btn.text = "자동 켜짐" if auto_mode else "자동 (A)"
		skip_btn.text = "스킵 켜짐" if skip_mode else "스킵 (S)"


func _process(delta: float) -> void:
	if story == null or on_title:
		return
	if ko_label.visible_characters >= 0 and not _typing_done():
		ko_label.visible_characters += maxi(1, int(TYPE_SPEED * delta * (4.0 if skip_mode else 1.0)) + 1)
	next_mark.visible = text_panel.visible and _typing_done() and not waiting_choice
	next_mark.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)
	if (auto_mode or skip_mode) and not waiting_choice and not busy and _typing_done() and not log_panel.visible:
		auto_timer += delta
		if auto_timer >= (0.15 if skip_mode else 2.2):
			auto_timer = 0.0
			if ev.get("type", "") != "ending":
				_advance()
	else:
		auto_timer = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.keycode
	if log_panel.visible:
		if k in [KEY_L, KEY_ESCAPE]:
			_toggle_log()
		get_viewport().set_input_as_handled()
		return
	if on_title:
		return # 타이틀은 포커스된 시작 버튼이 Enter를 받는다
	if waiting_choice:
		if k >= KEY_1 and k <= KEY_9 and k - KEY_1 < ev.options.size():
			_on_choice(k - KEY_1)
			get_viewport().set_input_as_handled()
		return # ↑↓ Enter는 버튼 포커스가 처리
	match k:
		KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
			if ev.get("type", "") == "ending":
				_show_title()
			else:
				_advance()
		KEY_L:
			_toggle_log()
		KEY_A:
			_toggle_auto()
		KEY_S:
			_toggle_skip()
		KEY_ESCAPE:
			_show_title()
		_:
			return
	get_viewport().set_input_as_handled()
