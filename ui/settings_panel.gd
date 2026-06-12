extends Control
# A simple sliding settings panel: music + sfx volume, quality dropdown.
# Built entirely in code so it adapts to language at any moment.

signal closed()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 360)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)
	# Title
	var title := Label.new()
	title.text = Lang.ui("settings")
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	# Music slider
	v.add_child(_make_slider(Lang.ui("settings_music"), Settings.music_db, -60.0, 0.0,
		func(val): Settings.set_music_db(val)))
	# SFX slider
	v.add_child(_make_slider(Lang.ui("settings_sfx"), Settings.sfx_db, -60.0, 0.0,
		func(val): Settings.set_sfx_db(val)))
	# Quality dropdown
	var q_row := HBoxContainer.new()
	q_row.add_theme_constant_override("separation", 14)
	v.add_child(q_row)
	var q_lbl := Label.new()
	q_lbl.text = Lang.ui("settings_quality")
	q_lbl.add_theme_font_size_override("font_size", 18)
	q_lbl.custom_minimum_size = Vector2(160, 0)
	q_row.add_child(q_lbl)
	var q_opt := OptionButton.new()
	q_opt.add_item(Lang.ui("quality_low"), 0)
	q_opt.add_item(Lang.ui("quality_mid"), 1)
	q_opt.add_item(Lang.ui("quality_high"), 2)
	q_opt.select(Settings.quality)
	q_opt.item_selected.connect(func(idx: int): Settings.set_quality(idx))
	q_row.add_child(q_opt)
	# Story mode toggle: gentle rolls + no permadeath outside bosses.
	var s_row := HBoxContainer.new()
	s_row.add_theme_constant_override("separation", 14)
	v.add_child(s_row)
	var s_chk := CheckButton.new()
	s_chk.text = Lang.t({
		"fr": "Mode histoire (doux, sans mort)",
		"en": "Story mode (gentle, no death)",
		"id": "Mode cerita (santai, tanpa mati)"})
	s_chk.button_pressed = Settings.story_mode
	s_chk.toggled.connect(func(on: bool):
		Audio.play(&"click")
		Settings.set_story_mode(on))
	s_row.add_child(s_chk)
	# Close
	var close := Button.new()
	close.text = Lang.ui("back")
	close.custom_minimum_size = Vector2(0, 48)
	close.pressed.connect(func():
		Audio.play(&"click")
		closed.emit()
		queue_free())
	v.add_child(close)

func _make_slider(label_text: String, value: float, min_v: float, max_v: float, on_change: Callable) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var l := Label.new()
	l.text = label_text
	l.custom_minimum_size = Vector2(160, 0)
	l.add_theme_font_size_override("font_size", 18)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = 1.0
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.custom_minimum_size = Vector2(180, 0)
	s.value_changed.connect(on_change)
	row.add_child(s)
	return row
