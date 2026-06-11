extends Node
# Builds a polished global theme with rounded panels, subtle gold trim,
# proper button states. Replaces the default Godot widget look.
# Autoloaded as "ThemeLoader".

func _ready() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray([
		"Cinzel", "Marcellus", "EB Garamond", "Garamond",
		"Optima", "Avenir Next", "Georgia", "DejaVu Serif",
		"Noto Serif", "serif"])
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY

	var theme := Theme.new()
	for control_class in ["Label", "Button", "RichTextLabel", "LineEdit", "CheckButton", "OptionButton"]:
		theme.set_font("font", control_class, font)

	# ----- Panels -----
	var panel := _make_panel_stylebox()
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)

	# ----- Buttons -----
	var btn_normal := _make_button_stylebox(Color(0.10, 0.10, 0.14, 0.85), Color(0.55, 0.45, 0.20, 0.95))
	var btn_hover  := _make_button_stylebox(Color(0.16, 0.14, 0.10, 0.95), Color(1.00, 0.80, 0.35, 1.00))
	var btn_press  := _make_button_stylebox(Color(0.20, 0.16, 0.10, 1.00), Color(1.00, 0.90, 0.45, 1.00))
	var btn_disabl := _make_button_stylebox(Color(0.08, 0.08, 0.10, 0.55), Color(0.30, 0.30, 0.30, 0.40))
	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_press)
	theme.set_stylebox("disabled", "Button", btn_disabl)
	theme.set_stylebox("focus",    "Button", btn_hover)
	theme.set_color("font_color",          "Button", Color(0.98, 0.93, 0.82))
	theme.set_color("font_hover_color",    "Button", Color(1, 1, 0.95))
	theme.set_color("font_pressed_color",  "Button", Color(1, 1, 1))
	theme.set_color("font_disabled_color", "Button", Color(0.5, 0.5, 0.5))
	theme.set_constant("h_separation",  "HBoxContainer", 8)
	theme.set_constant("separation",    "VBoxContainer", 8)

	# ----- Labels -----
	theme.set_constant("outline_size",    "Label", 2)
	theme.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.7))
	theme.set_constant("outline_size",    "RichTextLabel", 2)
	theme.set_color("font_outline_color", "RichTextLabel", Color(0, 0, 0, 0.7))

	# ----- Sliders (HSlider) -----
	var slider_bg := StyleBoxFlat.new()
	slider_bg.bg_color = Color(0.06, 0.06, 0.10, 0.9)
	slider_bg.corner_radius_top_left = 4
	slider_bg.corner_radius_top_right = 4
	slider_bg.corner_radius_bottom_left = 4
	slider_bg.corner_radius_bottom_right = 4
	slider_bg.border_color = Color(0.45, 0.40, 0.25, 0.85)
	slider_bg.border_width_left = 1; slider_bg.border_width_right = 1
	slider_bg.border_width_top = 1;  slider_bg.border_width_bottom = 1
	slider_bg.content_margin_left = 6; slider_bg.content_margin_right = 6
	slider_bg.content_margin_top = 6; slider_bg.content_margin_bottom = 6
	var slider_fg := StyleBoxFlat.new()
	slider_fg.bg_color = Color(0.95, 0.78, 0.30, 0.95)
	slider_fg.corner_radius_top_left = 3
	slider_fg.corner_radius_top_right = 3
	slider_fg.corner_radius_bottom_left = 3
	slider_fg.corner_radius_bottom_right = 3
	theme.set_stylebox("slider", "HSlider", slider_bg)
	theme.set_stylebox("grabber_area", "HSlider", slider_fg)
	theme.set_stylebox("grabber_area_highlight", "HSlider", slider_fg)

	# ----- LineEdit -----
	var edit := StyleBoxFlat.new()
	edit.bg_color = Color(0.05, 0.05, 0.08, 0.9)
	edit.border_color = Color(0.55, 0.45, 0.20, 0.9)
	edit.border_width_left = 1; edit.border_width_right = 1
	edit.border_width_top = 1; edit.border_width_bottom = 1
	edit.corner_radius_top_left = 6
	edit.corner_radius_top_right = 6
	edit.corner_radius_bottom_left = 6
	edit.corner_radius_bottom_right = 6
	edit.content_margin_left = 10; edit.content_margin_right = 10
	edit.content_margin_top = 6; edit.content_margin_bottom = 6
	theme.set_stylebox("normal", "LineEdit", edit)
	theme.set_stylebox("focus",  "LineEdit", edit)
	theme.set_color("font_color",            "LineEdit", Color(1, 0.96, 0.85))
	theme.set_color("caret_color",           "LineEdit", Color(1, 0.85, 0.40))
	theme.set_color("font_placeholder_color","LineEdit", Color(0.6, 0.55, 0.45))

	# ----- CheckButton -----
	theme.set_color("font_color",       "CheckButton", Color(1, 0.96, 0.85))
	theme.set_color("font_hover_color", "CheckButton", Color(1, 1, 0.95))

	get_tree().root.theme = theme

func _make_panel_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.05, 0.08, 0.88)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.border_color = Color(0.55, 0.45, 0.20, 0.95)
	sb.border_width_left = 1; sb.border_width_right = 1
	sb.border_width_top = 1;  sb.border_width_bottom = 1
	sb.shadow_color = Color(0, 0, 0, 0.7)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, 6)
	sb.content_margin_left = 18; sb.content_margin_right = 18
	sb.content_margin_top = 16; sb.content_margin_bottom = 16
	return sb

func _make_button_stylebox(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.border_color = border
	sb.border_width_left = 1; sb.border_width_right = 1
	sb.border_width_top = 1;  sb.border_width_bottom = 1
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 2)
	sb.content_margin_left = 16; sb.content_margin_right = 16
	sb.content_margin_top = 10; sb.content_margin_bottom = 10
	return sb

