extends Control
# Run summary panel shown after every run. Reads stats from Progress.

signal closed()

func setup(zones: int, kills: int, time_sec: int, new_discoveries: int, cause: String) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(540, 460)
	panel.position = Vector2(-270, -230)
	add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)
	var title := Label.new()
	title.text = Lang.ui("summary_title")
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var subtitle := Label.new()
	subtitle.text = cause
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.85, 0.80, 0.85))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(subtitle)
	v.add_child(_stat_row(Lang.ui("summary_zones"), str(zones)))
	v.add_child(_stat_row(Lang.ui("summary_kills"), str(kills)))
	var mn := time_sec / 60
	var sc := time_sec % 60
	v.add_child(_stat_row(Lang.ui("summary_time"), "%d:%02d" % [mn, sc]))
	v.add_child(_stat_row(Lang.ui("summary_discov"), str(new_discoveries)))
	# Achievements newly unlocked count
	var ach := Label.new()
	ach.text = "★ %d / %d" % [_count_unlocked(), Progress.ACHIEVEMENTS.size()]
	ach.add_theme_font_size_override("font_size", 22)
	ach.add_theme_color_override("font_color", Color(1, 0.85, 0.30))
	ach.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ach)
	var ok := Button.new()
	ok.text = Lang.ui("summary_again")
	ok.custom_minimum_size = Vector2(0, 54)
	ok.add_theme_font_size_override("font_size", 22)
	ok.pressed.connect(func():
		Audio.play(&"click")
		closed.emit()
		queue_free())
	v.add_child(ok)

func _stat_row(label: String, value: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	var r := Label.new()
	r.text = value
	r.add_theme_font_size_override("font_size", 22)
	r.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	row.add_child(r)
	return row

func _count_unlocked() -> int:
	var n := 0
	for a in Progress.ACHIEVEMENTS:
		if Progress.unlocked(a.id): n += 1
	return n
