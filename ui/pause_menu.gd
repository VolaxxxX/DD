extends Control
# In-game pause overlay. Triggered by an HUD button or by the BACK key on
# mobile / ESC on desktop. Pauses the scene tree.

signal resumed()
signal quit_to_menu()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.78)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 380)
	panel.position = Vector2(-200, -190)
	add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)
	var title := Label.new()
	title.text = Lang.ui("pause_title")
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var resume := Button.new()
	resume.text = Lang.ui("pause_resume")
	resume.custom_minimum_size = Vector2(0, 56)
	resume.add_theme_font_size_override("font_size", 22)
	resume.pressed.connect(_resume)
	v.add_child(resume)
	var settings := Button.new()
	settings.text = Lang.ui("menu_settings")
	settings.custom_minimum_size = Vector2(0, 48)
	settings.pressed.connect(func():
		Audio.play(&"click")
		var panel2: Control = preload("res://ui/settings_panel.gd").new()
		panel2.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(panel2)
		panel2.closed.connect(func(): pass))
	v.add_child(settings)
	var quit := Button.new()
	quit.text = Lang.ui("pause_quit")
	quit.custom_minimum_size = Vector2(0, 48)
	quit.add_theme_color_override("font_color", Color(1, 0.55, 0.55))
	quit.pressed.connect(func():
		Audio.play(&"click")
		get_tree().paused = false
		quit_to_menu.emit()
		queue_free())
	v.add_child(quit)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		_resume()

func _resume() -> void:
	Audio.play(&"click")
	get_tree().paused = false
	resumed.emit()
	queue_free()
