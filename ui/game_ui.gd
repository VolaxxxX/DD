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

const TONE_GLYPH := {
	0: "⚔",   # AGGRESSIVE - sword
	1: "✿",   # DIPLOMATIC - flower / open hand
	2: "◯",   # CAUTIOUS - circle / step aside
	3: "?",   # CURIOUS - question
	4: "♣",   # DECEPTIVE - club / mask
	5: "✦",   # MYSTICAL - star / sigil
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
	setup_pause_button()

var _lang_btn: Button
var _last_force: int = 0
var _last_injuries: Array = []

func _cycle_lang() -> void:
	var order := ["fr", "en", "id"]
	Lang.code = order[(order.find(Lang.code) + 1) % order.size()]
	Lang.save_pref()
	_lang_btn.text = Lang.code.to_upper()
	update_stats(_last_force, _last_injuries)

signal pause_requested()

func setup_pause_button() -> void:
	var pb := Button.new()
	pb.text = "❚❚"
	pb.custom_minimum_size = Vector2(56, 40)
	pb.anchor_left = 0.0; pb.anchor_right = 0.0
	pb.offset_left = 12.0; pb.offset_right = 68.0
	pb.offset_top = 60.0; pb.offset_bottom = 100.0
	pb.pressed.connect(func():
		Audio.play(&"click")
		pause_requested.emit())
	$Root.add_child(pb)

var _player: PlayerState = null

func set_player(p: PlayerState) -> void:
	_player = p
	name_label.text = "%s — %s" % [p.name, String(p.class_data.name)]
	update_stats(p.effective_force(), p.injuries, p.relics)

# The stat key the active player is best at — used to star the choice that
# plays to their strengths (subtle build-around guidance, no numbers shown).
func _best_stat_key() -> String:
	if _player == null: return ""
	var best_key := ""
	var best_val := -999
	for k in _player.stats.keys():
		var v: int = _player.effective_stat(StringName(k))
		if v > best_val:
			best_val = v
			best_key = String(k)
	return best_key

var _intro_tween: Tween
var _intro_active: bool = false

func present_intro(text: String) -> void:
	# Render in the narrative box (the dark bar above the choices) so the player
	# can read the title while the choices are visible. Stays until the next
	# narrative outcome (or a new intro replaces it).
	if _intro_tween and _intro_tween.is_valid(): _intro_tween.kill()
	intro_label.text = ""
	intro_label.modulate.a = 0.0
	_intro_active = true
	narrative.modulate = Color(1, 0.95, 0.78)
	narrative.text = "[center][b]%s[/b][/center]" % text
	narrative.visible_characters = -1
	narrative.modulate.a = 0.0
	_intro_tween = create_tween()
	_intro_tween.tween_property(narrative, "modulate:a", 1.0, 0.45)

func _dismiss_intro() -> void:
	# Outcome text takes over the narrative box, so we just clear the flag.
	_intro_active = false

const TONE_STAT_LABEL := {
	0: "force", 1: "charisme", 2: "vivacite", 3: "instinct", 4: "charisme", 5: "esprit",
}

func present_encounter(enc) -> void:
	# Keep the intro visible in the narrative box if one was just set, so the
	# player reads "the fey with red eyes" while picking a choice.
	if not _intro_active: narrative.text = ""
	_show_choices()
	for i in choice_buttons.size():
		var btn := choice_buttons[i]
		if i < enc.choices.size():
			var c: Dictionary = enc.choices[i]
			btn.visible = true
			# Format: "<glyph>  text\n— STAT" so the player sees which stat is rolled.
			var stat_key: String = TONE_STAT_LABEL.get(c.tone, "force")
			var stat_short: String = PlayerClass.stat_label(StringName(stat_key))
			# Star the choice that rolls the player's strongest stat.
			var star := "  ★" if stat_key == _best_stat_key() else ""
			btn.text = "%s %s  ·  %s%s" % [TONE_GLYPH.get(c.tone, ""), c.text, stat_short, star]
			btn.modulate = TONE_COLOR.get(c.tone, Color.WHITE)
			btn.modulate.a = 0.0
			btn.disabled = false
		else:
			btn.visible = false
	# Smooth choice fade-in, staggered.
	for i in choice_buttons.size():
		var btn := choice_buttons[i]
		if not btn.visible: continue
		var t := btn.create_tween()
		t.tween_interval(0.15 + i * 0.10)
		t.tween_property(btn, "modulate:a", 1.0, 0.30)

func show_narrative(text: String, _tone: int, outcome: int) -> void:
	_hide_choices()
	_dismiss_intro()
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

func update_stats(force: int, injuries: Array, relics: Array = []) -> void:
	var prev := _last_force
	_last_force = force
	_last_injuries = injuries.duplicate()
	var relic_str := ""
	for rid in relics:
		var r: Dictionary = RelicRegistry.by_id(rid)
		relic_str += String(r.get("icon", "✦")) + " "
	# Tween the displayed value so changes feel weighty.
	if prev != force:
		var n := prev
		var d := 1 if force > prev else -1
		var step_count: int = absi(force - prev)
		var t := create_tween()
		for s in step_count:
			n += d
			var cap := n
			t.tween_callback(func():
				stat_label.text = "%s  %d   ✦ %d   %s" % [Lang.ui("force"), cap, Progress.fragments, relic_str])
			t.tween_interval(0.06)
		# Brief color flash on the label.
		var col := Color(0.55, 1.0, 0.55) if force > prev else Color(1.0, 0.55, 0.55)
		stat_label.modulate = col
		var fb := create_tween()
		fb.tween_property(stat_label, "modulate", Color(1, 0.9, 0.5), 0.4)
	else:
		stat_label.text = "%s  %d   ✦ %d   %s" % [Lang.ui("force"), force, Progress.fragments, relic_str]
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

func update_encounter_progress(current: int, total: int) -> void:
	# Show dots: filled for done, hollow for upcoming.
	var s := ""
	for i in total:
		s += "●" if i < current else "○"
	zone_label.text = "%s  %s" % [zone_label.text.split("  ")[0], s] if zone_label.text.contains("  ") else s

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
	# Press feedback: brief shrink + release on the chosen button.
	var btn := choice_buttons[idx]
	var t := btn.create_tween()
	t.tween_property(btn, "scale", Vector2.ONE * 0.92, 0.06)
	t.tween_property(btn, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Subtle pivot for the punch (so scale shrinks around its center).
	btn.pivot_offset = btn.size / 2.0
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
