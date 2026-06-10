extends Node
# Applies a SystemFont theme globally so every Label/Button/RichTextLabel uses
# a nicer typeface than the default. Autoloaded as "ThemeLoader".

func _ready() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray([
		"Cinzel", "Marcellus", "EB Garamond", "Garamond",
		"Optima", "Avenir Next", "Georgia", "DejaVu Serif",
		"Noto Serif", "serif"])
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	var theme := Theme.new()
	for control_class in ["Label", "Button", "RichTextLabel", "LineEdit", "CheckButton"]:
		theme.set_font("font", control_class, font)
	# Make buttons feel less harsh.
	theme.set_color("font_color", "Button", Color(1, 0.95, 0.85))
	theme.set_color("font_hover_color", "Button", Color(1, 1, 1))
	theme.set_constant("outline_size", "Label", 2)
	theme.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.7))
	theme.set_constant("outline_size", "RichTextLabel", 2)
	theme.set_color("font_outline_color", "RichTextLabel", Color(0, 0, 0, 0.7))
	get_tree().root.theme = theme
