extends CanvasLayer
# Achievement unlock toast: slides down from the top with sound + emphasis.
# Autoloaded as "Toast".

func _ready() -> void:
	layer = 95
	Progress.achievement_unlocked.connect(show_achievement)

func show_achievement(achievement_id: StringName) -> void:
	var a := _find(achievement_id)
	if a.is_empty(): return
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.offset_left = -220
	panel.offset_right = 220
	panel.offset_top = -120
	panel.offset_bottom = -20
	add_child(panel)
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var star := Label.new()
	star.text = "★"
	star.add_theme_font_size_override("font_size", 42)
	star.add_theme_color_override("font_color", Color(1, 0.85, 0.30))
	box.add_child(star)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(v)
	var hdr := Label.new()
	hdr.text = Lang.ui("unlocked")
	hdr.add_theme_font_size_override("font_size", 13)
	hdr.add_theme_color_override("font_color", Color(0.75, 0.70, 0.50))
	v.add_child(hdr)
	var nm := Label.new()
	nm.text = Lang.t(a.title)
	nm.add_theme_font_size_override("font_size", 20)
	nm.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	v.add_child(nm)
	Audio.play(&"crit")
	# Animate down then back up.
	var t := panel.create_tween()
	t.tween_property(panel, "offset_top", 24, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "offset_bottom", 124, 0.0)
	t.tween_interval(3.0)
	t.tween_property(panel, "offset_top", -120, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_callback(func():
		if is_instance_valid(panel): panel.queue_free())

func _find(id: StringName) -> Dictionary:
	for a in Progress.ACHIEVEMENTS:
		if a.id == id: return a
	return {}

# Generic info toast (no achievement framing): short slide-down message.
func info(text: String) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.offset_left = -260
	panel.offset_right = 260
	panel.offset_top = -110
	panel.offset_bottom = -30
	add_child(panel)
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(lbl)
	var t := panel.create_tween()
	t.tween_property(panel, "offset_top", 20, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "offset_bottom", 100, 0.0)
	t.tween_interval(3.2)
	t.tween_property(panel, "offset_top", -110, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_callback(func():
		if is_instance_valid(panel): panel.queue_free())
