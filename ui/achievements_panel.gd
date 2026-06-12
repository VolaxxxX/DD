extends Control
# Achievement list with unlocked/locked state, localized.

signal closed()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 560)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)
	var title := Label.new()
	title.text = Lang.ui("menu_achievements")
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(500, 420)
	v.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for a in Progress.ACHIEVEMENTS:
		list.add_child(_row(a))
	# Footer counter
	var unlocked := 0
	for a in Progress.ACHIEVEMENTS:
		if Progress.unlocked(a.id): unlocked += 1
	var footer := Label.new()
	footer.text = "%d / %d" % [unlocked, Progress.ACHIEVEMENTS.size()]
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color(1, 0.95, 0.65))
	v.add_child(footer)
	var close := Button.new()
	close.text = Lang.ui("back")
	close.custom_minimum_size = Vector2(0, 48)
	close.pressed.connect(func():
		Audio.play(&"click")
		closed.emit()
		queue_free())
	v.add_child(close)

func _row(a: Dictionary) -> Control:
	var unlocked := Progress.unlocked(a.id)
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 70)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	row.add_child(h)
	# Status badge
	var badge := Label.new()
	badge.text = "★" if unlocked else "✦"
	badge.add_theme_font_size_override("font_size", 32)
	badge.add_theme_color_override("font_color", Color(1, 0.85, 0.30) if unlocked else Color(0.5, 0.5, 0.5))
	badge.custom_minimum_size = Vector2(40, 0)
	h.add_child(badge)
	# Title + desc
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	var title := Label.new()
	title.text = Lang.t(a.title)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.85) if unlocked else Color(0.6, 0.6, 0.6))
	v.add_child(title)
	var desc := Label.new()
	desc.text = Lang.t(a.desc)
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85) if unlocked else Color(0.5, 0.5, 0.5))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(desc)
	return row
