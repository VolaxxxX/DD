extends Control
# Opening prologue: a few tappable narrative cards that set up WHO you are and
# WHY you're here, shown over the (already built) 3D scene before the run.

signal done()

const CARDS := {
	"fr": [
		"Le monde que tu connaissais s'est fendu.\nCe qu'il en reste flotte, se mêle et se défait sans fin.\nOn appelle cela la Dérive.",
		"Tu es un Voyageur.\nTu as franchi le seuil — par fuite, par dette, ou par folie.\nComme tous ceux d'avant toi, tu ne peux plus revenir en arrière.",
		"Devant toi s'étendent des terres mouvantes :\ndes créatures qui parlent, des ruines qui se souviennent,\net plus haut, le vol des dragons.",
		"Une seule issue : traverser, zone après zone, jusqu'à l'extraction.\nChaque rencontre exigera un choix.\nLe destin, lui, pèse en silence.\n\nAvance, Voyageur.",
	],
	"en": [
		"The world you knew has split apart.\nWhat remains drifts, mingles and unravels without end.\nThey call it the Drift.",
		"You are a Traveler.\nYou crossed the threshold — by flight, by debt, or by madness.\nLike all who came before, you cannot turn back.",
		"Before you lie shifting lands:\ncreatures that speak, ruins that remember,\nand high above, the flight of dragons.",
		"One way out: cross it, zone by zone, to the extraction.\nEvery encounter will demand a choice.\nFate, meanwhile, weighs in silence.\n\nGo on, Traveler.",
	],
	"id": [
		"Dunia yang kau kenal telah retak.\nSisanya mengambang, bercampur, dan terurai tanpa akhir.\nMereka menyebutnya Arus.",
		"Kau seorang Pengelana.\nKau melewati ambang — karena lari, utang, atau kegilaan.\nSeperti semua sebelummu, kau tak bisa kembali.",
		"Di hadapanmu terbentang tanah yang berubah-ubah:\nmakhluk yang bicara, reruntuhan yang mengingat,\ndan jauh di atas, naga-naga terbang.",
		"Satu jalan keluar: lintasi, zona demi zona, hingga jalan keluar.\nSetiap pertemuan menuntut sebuah pilihan.\nTakdir, sementara itu, menimbang dalam diam.\n\nMelangkahlah, Pengelana.",
	],
}

var _cards: Array = []
var _idx: int = 0
var _label: RichTextLabel
var _hint: Label
var _panel: PanelContainer
var _busy: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_cards = CARDS.get(Lang.code, CARDS["fr"])
	# Dim veil so text reads over the scene.
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.55)
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	# Title.
	var title := Label.new()
	title.text = "AETHER DRIFT"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0.0; title.anchor_right = 1.0
	title.anchor_top = 0.16; title.offset_top = 0
	add_child(title)
	# Card panel.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(720, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.04, 0.07, 0.85)
	sb.set_corner_radius_all(14)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.85, 0.72, 0.4, 0.5)
	sb.set_content_margin_all(28)
	_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(_panel)
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.custom_minimum_size = Vector2(660, 0)
	_label.add_theme_font_size_override("normal_font_size", 21)
	_panel.add_child(_label)
	# Tap hint.
	_hint = Label.new()
	_hint.text = Lang.t({"fr": "Touche pour continuer  ›", "en": "Tap to continue  ›", "id": "Sentuh untuk lanjut  ›"})
	_hint.add_theme_font_size_override("font_size", 16)
	_hint.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 0.8))
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.anchor_left = 0.0; _hint.anchor_right = 1.0
	_hint.anchor_top = 0.82
	add_child(_hint)
	# Skip button.
	var skip := Button.new()
	skip.text = Lang.t({"fr": "Passer", "en": "Skip", "id": "Lewati"})
	skip.anchor_left = 1.0; skip.anchor_right = 1.0
	skip.offset_left = -120; skip.offset_right = -20
	skip.offset_top = 24; skip.offset_bottom = 60
	skip.pressed.connect(_finish)
	add_child(skip)
	_show_card(0)

func _show_card(i: int) -> void:
	_busy = true
	_label.text = "[center]%s[/center]" % _cards[i]
	_panel.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_panel, "modulate:a", 1.0, 0.5)
	t.tween_callback(func(): _busy = false)

func _gui_input(event: InputEvent) -> void:
	if _busy: return
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_next()

func _next() -> void:
	_idx += 1
	if _idx >= _cards.size():
		_finish()
	else:
		Audio.play(&"click")
		_show_card(_idx)

func _finish() -> void:
	if _busy: return
	_busy = true
	Audio.play(&"click")
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	t.tween_callback(func():
		done.emit()
		queue_free())
