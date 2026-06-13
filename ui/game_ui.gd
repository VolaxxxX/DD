extends CanvasLayer
# Main game UI: narrative panel, choice buttons, status bar with class + injuries.

signal choice_selected(index: int)

@onready var narrative: RichTextLabel = $Root/NarrativeBox/Narrative
@onready var narrative_box: PanelContainer = $Root/NarrativeBox
@onready var intro_label: Label = $Root/IntroLabel
@onready var choice0: Button = $Root/ChoicesBox/Choice0
@onready var choice1: Button = $Root/ChoicesBox/Choice1
@onready var choice2: Button = $Root/ChoicesBox/Choice2
@onready var choice3: Button = $Root/ChoicesBox/Choice3
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
	6: Color(1.0, 0.55, 0.85),  # WILD — pink-magenta, off-script
}

const TONE_GLYPH := {
	0: "⚔",   # AGGRESSIVE - sword
	1: "✿",   # DIPLOMATIC - flower / open hand
	2: "◯",   # CAUTIOUS - circle / step aside
	3: "?",   # CURIOUS - question
	4: "♣",   # DECEPTIVE - club / mask
	5: "✦",   # MYSTICAL - star / sigil
	6: "✺",   # WILD - chaos rosette
}

const OUTCOME_TINT := {
	0: Color(1.0, 0.25, 0.25),
	1: Color(1.0, 0.55, 0.30),
	2: Color(1.0, 0.95, 0.55),
	3: Color(0.55, 1.0, 0.55),
	4: Color(0.55, 0.95, 1.0),
}

func _ready() -> void:
	choice_buttons = [choice0, choice1, choice2, choice3]
	for i in choice_buttons.size():
		var idx := i
		choice_buttons[i].pressed.connect(func(): _on_choice_pressed(idx))
		_apply_glass_button_style(choice_buttons[i])
	_hide_choices()
	narrative.text = ""
	narrative_box.visible = false
	intro_label.text = ""
	fade.modulate.a = 0.0
	# Stats bar (top) needs a dark backdrop or the text vanishes on light biomes.
	var stats_bg := ColorRect.new()
	stats_bg.color = Color(0, 0, 0, 0.55)
	stats_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	stats_bg.offset_top = 0
	stats_bg.offset_bottom = 56
	stats_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(stats_bg)
	$Root.move_child(stats_bg, 0)   # behind the stats labels
	# In-game language switch — cycles FR -> EN -> ID at any moment.
	_lang_btn = Button.new()
	_lang_btn.text = Lang.code.to_upper()
	_lang_btn.custom_minimum_size = Vector2(56, 40)
	_lang_btn.anchor_left = 1.0; _lang_btn.anchor_right = 1.0
	_lang_btn.offset_left = -70.0; _lang_btn.offset_right = -12.0
	_lang_btn.offset_top = 60.0; _lang_btn.offset_bottom = 100.0
	_lang_btn.pressed.connect(_cycle_lang)
	_style_hud_button(_lang_btn)
	$Root.add_child(_lang_btn)
	setup_pause_button()
	# Responsive: pick up orientation changes (portrait toggle) and re-layout
	# the bottom UI band to fit the new aspect ratio.
	get_viewport().size_changed.connect(_relayout_for_screen)
	_relayout_for_screen()

func _relayout_for_screen() -> void:
	# Bottom-anchored values are the same; we just give the box more height
	# and the choices more room in portrait (where vertical space is huge).
	var portrait := DisplayServer.window_get_size().y > DisplayServer.window_get_size().x
	if portrait:
		narrative_box.offset_top = -440.0
		narrative_box.offset_bottom = -310.0
		narrative_box.offset_left = 24.0
		narrative_box.offset_right = -24.0
		choices_box.offset_top = -300.0
		choices_box.offset_bottom = -24.0
		choices_box.offset_left = 24.0
		choices_box.offset_right = -24.0
		choices_box.add_theme_constant_override("separation", 10)
		for b in choice_buttons:
			b.custom_minimum_size = Vector2(0, 62)
			b.add_theme_font_size_override("font_size", 17)
	else:
		narrative_box.offset_top = -274.0
		narrative_box.offset_bottom = -206.0
		narrative_box.offset_left = 90.0
		narrative_box.offset_right = -90.0
		choices_box.offset_top = -196.0
		choices_box.offset_bottom = -10.0
		choices_box.offset_left = 90.0
		choices_box.offset_right = -90.0
		choices_box.add_theme_constant_override("separation", 5)
		for b in choice_buttons:
			b.custom_minimum_size = Vector2(0, 42)
			b.add_theme_font_size_override("font_size", 13)

@onready var choices_box: VBoxContainer = $Root/ChoicesBox

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
	pb.text = "⚙"
	pb.add_theme_font_size_override("font_size", 22)
	pb.custom_minimum_size = Vector2(56, 44)
	pb.anchor_left = 0.0; pb.anchor_right = 0.0
	pb.offset_left = 12.0; pb.offset_right = 68.0
	pb.offset_top = 60.0; pb.offset_bottom = 104.0
	pb.pressed.connect(func():
		Audio.play(&"click")
		pause_requested.emit())
	_style_hud_button(pb)
	$Root.add_child(pb)

# Solid dark pill so HUD buttons stay readable over light biomes (coast/highland)
# and don't blend into bright backgrounds.
func _style_hud_button(b: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.06, 0.09, 0.85)
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.85, 0.72, 0.4, 0.7)
	sb.set_content_margin_all(6)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("hover", sb)
	b.add_theme_stylebox_override("pressed", sb)
	b.add_theme_color_override("font_color", Color(1, 0.96, 0.85))

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
var _last_story: String = ""   # last outcome, shown as a "previously" recap line

func reset_story_log() -> void:
	_last_story = ""

func _strip_bb(s: String) -> String:
	# Remove bbcode tags for the recap line + clamp length.
	var out := ""
	var depth := 0
	for ch in s:
		if ch == "[": depth += 1
		elif ch == "]": depth = maxi(0, depth - 1)
		elif depth == 0: out += ch
	out = out.replace("\n", " ").strip_edges()
	if out.length() > 90: out = out.substr(0, 88) + "…"
	return out

func present_intro(text: String) -> void:
	# Render in the narrative box (the dark bar above the choices) so the player
	# can read what's happening while the choices are visible. Stays until the
	# next narrative outcome (or a new intro replaces it).
	if _intro_tween and _intro_tween.is_valid(): _intro_tween.kill()
	intro_label.text = ""
	intro_label.modulate.a = 0.0
	_intro_active = true
	narrative_box.visible = true
	narrative.modulate = Color(1, 0.96, 0.85)
	# Compact layout: line 1 = bold gold title, line 2 = scene description,
	# optional tag line (mood / etc) in smaller dim text. Keeps the box small
	# so the playable scene above stays clearly visible.
	var parts := text.split("\n", false)
	var body := ""
	# "Previously" recap line so the story stays continuous — what just happened
	# before this new encounter. Dim, small, italic.
	if _last_story != "":
		body = "[center][i][font_size=11][color=#8a8678]↪ %s[/color][/font_size][/i][/center]\n" % _last_story
	if parts.size() > 0:
		body += "[center][b][color=#ffd98a]%s[/color][/b][/center]" % parts[0]
	if parts.size() > 1:
		body += "\n[center]%s[/center]" % parts[1]
	# Anything beyond line 2 = small tags (mood etc).
	if parts.size() > 2:
		var tag := " · ".join(parts.slice(2))
		body += "\n[center][color=#b8b3a3]%s[/color][/center]" % tag
	narrative.text = body
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

# Companion "Flair": estimates each choice's hidden margin (player stat for
# the tone vs the encounter's difficulty mods) and returns the safest index.
# The numbers never surface — just a paw mark from a fox that knows.
func _flair_index(enc) -> int:
	if _player == null: return -1
	var best := -1
	var best_margin := -INF
	for i in enc.choices.size():
		var tone: int = int(enc.choices[i].tone)
		if tone == PhrasePool.Tone.WILD: continue   # chaos rolls have no margin
		var stat_key: StringName = PlayerClass.tone_stat(tone)
		var s: float = float(_player.effective_stat(stat_key) + _player.tone_modifier(tone) + BiomeRules.stat_mod(enc.zone.biome, stat_key))
		var d: float = 10.0 + enc.zone.chaos * 5.0 + float(BiomeRules.tone_difficulty_mod(enc.zone.biome, tone))
		if enc.creature != null:
			d += float(enc.creature.archetype.aggression) / 10.0
		match enc.zone.dragon_effect:
			"slow_flight":
				if tone == 2: d += enc.zone.dragon_value
			"peace_truce":
				if tone == 1: d -= enc.zone.dragon_value
			"deceptive_boost":
				if tone == 4: d -= enc.zone.dragon_value
			"guided_instinct":
				if stat_key == &"instinct": s += enc.zone.dragon_value
		var margin := s - d
		if margin > best_margin:
			best_margin = margin
			best = i
	return best

func present_encounter(enc) -> void:
	# Keep the intro visible in the narrative box if one was just set, so the
	# player reads "the fey with red eyes" while picking a choice.
	if not _intro_active: narrative.text = ""
	_show_choices()
	var flair := _flair_index(enc)
	for i in choice_buttons.size():
		var btn := choice_buttons[i]
		if i < enc.choices.size():
			var c: Dictionary = enc.choices[i]
			btn.visible = true
			# WILD has no stat — show "?" instead so the player feels the
			# wildness; flair/star don't apply to chaos rolls.
			if int(c.tone) == PhrasePool.Tone.WILD:
				var wild_tag := Lang.t({"fr": "ÉTRANGE", "en": "STRANGE", "id": "ANEH"})
				btn.text = "%s %s  ·  %s ?" % [TONE_GLYPH.get(c.tone, ""), c.text, wild_tag]
			else:
				# Format: "<glyph>  text  ·  STAT" so the player sees which stat is rolled.
				var stat_key: String = TONE_STAT_LABEL.get(c.tone, "force")
				var stat_short: String = PlayerClass.stat_label(StringName(stat_key))
				# Star the choice that rolls the player's strongest stat.
				var star := "  ★" if stat_key == _best_stat_key() else ""
				# Companion's paw on the statistically safest path.
				var paw := "🐾 " if i == flair else ""
				btn.text = "%s%s %s  ·  %s%s" % [paw, TONE_GLYPH.get(c.tone, ""), c.text, stat_short, star]
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
	narrative_box.visible = true
	_last_story = _strip_bb(text)   # remember for the next encounter's recap
	narrative.modulate = OUTCOME_TINT.get(outcome, Color.WHITE)
	narrative.text = "[center]%s[/center]" % text
	var raw_len := text.length()
	narrative.visible_characters = 0
	var tw := create_tween()
	tw.tween_property(narrative, "visible_characters", raw_len, maxf(0.6, raw_len * 0.02))
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
	narrative_box.visible = true
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

# Semi-transparent "glass" styling for the choice buttons so the 3D scene
# shows through instead of being masked by an opaque bar.
func _apply_glass_button_style(btn: Button) -> void:
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb := StyleBoxFlat.new()
		var a := 0.34
		if state == "hover": a = 0.5
		elif state == "pressed": a = 0.62
		sb.bg_color = Color(0.05, 0.05, 0.08, a)
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		sb.corner_radius_bottom_left = 8
		sb.corner_radius_bottom_right = 8
		sb.border_width_left = 1
		sb.border_width_bottom = 1
		sb.border_width_right = 1
		sb.border_width_top = 1
		sb.border_color = Color(0.85, 0.72, 0.4, 0.30 if state == "normal" else 0.55)
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		btn.add_theme_stylebox_override(state, sb)

func _flash_fade(color: Color, alpha: float) -> void:
	fade.color = color
	fade.modulate.a = alpha
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 1.0)
