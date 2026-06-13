extends Control
# A single D&D-style ACT title card that fades over the scene at the start of
# each act of the run, then dismisses itself.

signal done()

# act (1..3) -> {numeral, title, flavor} per language.
const ACTS := {
	1: {
		"fr": ["ACTE I", "Les Confins", "Tu entres dans la Dérive par ses marges. Ici, le monde se souvient encore vaguement de ce qu'il fut."],
		"en": ["ACT I", "The Reaches", "You enter the Drift by its margins. Here the world still dimly remembers what it once was."],
		"id": ["BABAK I", "Tepian", "Kau memasuki Arus dari pinggirannya. Di sini dunia masih samar mengingat wujud lamanya."],
	},
	2: {
		"fr": ["ACTE II", "Les Terres Malades", "Plus profond, la corruption gagne. Les créatures sont plus rares, plus fortes, plus tristes."],
		"en": ["ACT II", "The Sick Lands", "Deeper in, the corruption spreads. The creatures grow rarer, stronger, sadder."],
		"id": ["BABAK II", "Tanah Sakit", "Lebih dalam, korupsi menjalar. Makhluk-makhluk makin langka, makin kuat, makin sedih."],
	},
	3: {
		"fr": ["ACTE III", "Le Cœur de la Dérive", "Le seuil de sortie est proche — mais quelque chose d'immense veille sur le dernier pas."],
		"en": ["ACT III", "The Heart of the Drift", "The way out is near — but something vast guards the final step."],
		"id": ["BABAK III", "Jantung Arus", "Jalan keluar sudah dekat — tapi sesuatu yang besar menjaga langkah terakhir."],
	},
}

func setup(act: int) -> void:
	_act = clampi(act, 1, 3)

var _act: int = 1

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var data: Array = ACTS[_act].get(Lang.code, ACTS[_act]["fr"])
	# Dim veil.
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.0)
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 10)
	add_child(box)
	var numeral := Label.new()
	numeral.text = data[0]
	numeral.add_theme_font_size_override("font_size", 30)
	numeral.add_theme_color_override("font_color", Color(0.8, 0.72, 0.5))
	numeral.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(numeral)
	var title := Label.new()
	title.text = data[1]
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1.0, 0.93, 0.78))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var flavor := Label.new()
	flavor.text = data[2]
	flavor.add_theme_font_size_override("font_size", 18)
	flavor.add_theme_color_override("font_color", Color(0.85, 0.82, 0.9))
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor.custom_minimum_size = Vector2(640, 0)
	box.add_child(flavor)
	# Fade in, hold, fade out, then signal.
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(veil, "color:a", 0.55, 0.6)
	t.parallel().tween_property(self, "modulate:a", 1.0, 0.6)
	t.tween_interval(2.6)
	t.tween_property(self, "modulate:a", 0.0, 0.7)
	t.tween_callback(func():
		done.emit()
		queue_free())
