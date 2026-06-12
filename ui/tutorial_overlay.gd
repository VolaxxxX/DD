extends Control
# One-shot tutorial overlay shown on the first encounter. Skippable.

const SEEN_PATH := "user://tutorial_seen.cfg"

static func should_show() -> bool:
	return not FileAccess.file_exists(SEEN_PATH)

static func mark_seen() -> void:
	var f := FileAccess.open(SEEN_PATH, FileAccess.WRITE)
	if f: f.store_string("1")

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 480)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)
	var title := Label.new()
	title.text = Lang.ui("tutorial_title")
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.custom_minimum_size = Vector2(500, 320)
	body.text = Lang.ui("tutorial_body")
	body.add_theme_font_size_override("normal_font_size", 16)
	v.add_child(body)
	var ok := Button.new()
	ok.text = Lang.ui("tutorial_ok")
	ok.custom_minimum_size = Vector2(0, 52)
	ok.add_theme_font_size_override("font_size", 20)
	ok.pressed.connect(func():
		Audio.play(&"click")
		mark_seen()
		queue_free())
	v.add_child(ok)
