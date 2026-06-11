extends CanvasLayer
# Main game UI: narrative panel, choice buttons, status bar with class + injuries.

signal choice_selected(index: int)

@onready var narrative: RichTextLabel = $Root/NarrativeBox/Narrative
@onready var intro_label: Label = $Root/IntroLabel
@onready var choice0: Button = $Root/ChoicesBox/Choice0
@onready var choice1: Button = $Root/ChoicesBox/Choice1
@onready var choice2: Button = $Root/ChoicesBox/Choice2
@onready var name_label: Label = $Root/StatsBox/NameLabel
@onready var stat_label: Label = $Root/StatsBox/StatLabel
@onready var zone_label: Label = $Root/StatsBox/ZoneLabel
@onready var injuries_box: HBoxContainer = $Root/InjuriesBox
@onready var fade: ColorRect = $Root/Fade

var choice_buttons: Array[Button] = []

const TONE_COLOR := {
	0: Color(1.0, 0.45, 0.35),
	1: Color(0.75, 0.9, 1.0),
	2: Color(0.95, 0.95, 0.75),
	3: Color(0.85, 0.75, 1.0),
	4: Color(0.85, 1.0, 0.55),
	5: Color(1.0, 0.65, 1.0),
}

const OUTCOME_TINT := {
	0: Color(1.0, 0.25, 0.25),
	1: Color(1.0, 0.55, 0.30),
	2: Color(1.0, 0.95, 0.55),
	3: Color(0.55, 1.0, 0.55),
	4: Color(0.55, 0.95, 1.0),
}

func _ready() -> void:
	choice_buttons = [choice0, choice1, choice2]
	for i in choice_buttons.size():
		var idx := i
		choice_buttons[i].pressed.connect(func(): _on_choice_pressed(idx))
	_hide_choices()
	narrative.text = ""
	intro_label.text = ""
	fade.modulate.a = 0.0
	# In-game language switch — cycles FR -> EN -> ID at any moment.
	_lang_btn = Button.new()
	_lang_btn.text = Lang.code.to_upper()
	_lang_btn.custom_minimum_size = Vector2(56, 40)
	_lang_btn.anchor_left = 1.0; _lang_btn.anchor_right = 1.0
	_lang_btn.offset_left = -70.0; _lang_btn.offset_right = -12.0
	_lang_btn.offset_top = 60.0; _lang_btn.offset_bottom = 100.0
	_lang_btn.pressed.connect(_cycle_lang)
	$Root.add_child(_lang_btn)

var _lang_btn: Button
var _last_force: int = 0
var _last_injuries: Array = []

func _cycle_lang() -> void:
	var order := ["fr", "en", "id"]
	Lang.code = order[(order.find(Lang.code) + 1) % order.size()]
	Lang.save_pref()
	_lang_btn.text = Lang.code.to_upper()
	update_stats(_last_force, _last_injuries)

func set_player(p: PlayerState) -> void:
	name_label.text = "%s — %s" % [p.name, String(p.class_data.name)]
	update_stats(p.effective_force(), p.injuries)

func present_intro(text: String) -> void:
	_hide_choices()
	narrative.text = ""
	intro_label.text = text
	intro_label.modulate = Color(1, 1, 1, 0)
	var t := create_tween()
	t.tween_property(intro_label, "modulate:a", 1.0, 0.6)
	t.tween_interval(1.6)
	t.tween_property(intro_label, "modulate:a", 0.0, 0.8)

func present_encounter(enc) -> void:
	narrative.text = ""
	_show_choices()
	for i in choice_buttons.size():
		var btn := choice_buttons[i]
		if i < enc.choices.size():
			var c: Dictionary = enc.choices[i]
			btn.visible = true
			btn.text = c.text
			btn.modulate = TONE_COLOR.get(c.tone, Color.WHITE)
			btn.disabled = false
		else:
			btn.visible = false

func show_narrative(text: String, _tone: int, outcome: int) -> void:
	_hide_choices()
	narrative.modulate = OUTCOME_TINT.get(outcome, Color.WHITE)
	narrative.text = text
	narrative.visible_characters = 0
	var tw := create_tween()
	tw.tween_property(narrative, "visible_characters", text.length(), maxf(0.6, text.length() * 0.02))
	_flash_fade(OUTCOME_TINT.get(outcome, Color.WHITE), 0.25 if outcome == 2 else 0.5)
	match outcome:
		0: Audio.play(&"crit_fail")
		1: Audio.play(&"fail")
		2: Audio.play(&"hit", 1.1)
		3: Audio.play(&"success")
		4: Audio.play(&"crit")

func update_stats(force: int, injuries: Array) -> void:
	_last_force = force
	_last_injuries = injuries.duplicate()
	stat_label.text = "%s  %d" % [Lang.ui("force"), force]
	_render_injuries(injuries)

func _render_injuries(injuries: Array) -> void:
	for c in injuries_box.get_children(): c.queue_free()
	for inj_id in injuries:
		var inj: Dictionary = InjuryRegistry.by_id(inj_id)
		if inj.is_empty(): continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		# Colored dot icon (ColorRect with rounded look via theme stylebox).
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(14, 14)
		dot.color = inj.color
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = inj.color
		stylebox.corner_radius_top_left = 8
		stylebox.corner_radius_top_right = 8
		stylebox.corner_radius_bottom_left = 8
		stylebox.corner_radius_bottom_right = 8
		stylebox.shadow_color = Color(inj.color.r, inj.color.g, inj.color.b, 0.5)
		stylebox.shadow_size = 4
		var pnl := PanelContainer.new()
		pnl.add_theme_stylebox_override("panel", stylebox)
		pnl.custom_minimum_size = Vector2(14, 14)
		row.add_child(pnl)
		var lbl := Label.new()
		lbl.text = String(inj.name)
		lbl.add_theme_color_override("font_color", inj.color)
		lbl.add_theme_font_size_override("font_size", 14)
		row.add_child(lbl)
		injuries_box.add_child(row)

func update_zone(index: int, biome: StringName) -> void:
	zone_label.text = "Z.%d  %s" % [index + 1, String(biome).to_upper()]

func show_run_over(cause: StringName) -> void:
	_hide_choices()
	narrative.modulate = Color(1, 0.4, 0.4)
	narrative.text = "\n\n[center][b]%s[/b]\n%s[/center]" % [Lang.ui("run_over"), cause]
	fade.color = Color(0, 0, 0)
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.6, 1.5)

func _on_choice_pressed(idx: int) -> void:
	for b in choice_buttons: b.disabled = true
	Audio.play(&"click")
	choice_selected.emit(idx)

func _hide_choices() -> void:
	for b in choice_buttons: b.visible = false

func _show_choices() -> void:
	for b in choice_buttons: b.visible = true

func _flash_fade(color: Color, alpha: float) -> void:
	fade.color = color
	fade.modulate.a = alpha
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 1.0)
