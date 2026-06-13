extends Node3D
# Main menu: TIARA title, slow-rotating dragon centerpiece, new game / bestiary / lang / quit.

signal start_new_game()
signal continue_run()
signal open_bestiary()
signal open_settings()
signal open_achievements()

@onready var title_label: Label = $UI/Root/Title
@onready var tagline_label: Label = $UI/Root/Tagline
@onready var new_btn: Button = $UI/Root/Buttons/NewBtn
@onready var codex_btn: Button = $UI/Root/Buttons/CodexBtn
@onready var quit_btn: Button = $UI/Root/Buttons/QuitBtn
@onready var fr_btn: Button = $UI/Root/Buttons/LangRow/FR
@onready var en_btn: Button = $UI/Root/Buttons/LangRow/EN
@onready var id_btn: Button = $UI/Root/Buttons/LangRow/ID
@onready var anchor: Node3D = $Anchor

var _dragon: Dragon3D
var _stats_label: Label

func _ready() -> void:
	Lang.load_pref()
	# Insert a CONTINUE button at the top if a save exists.
	if Save.has_save():
		var cont := Button.new()
		cont.custom_minimum_size = Vector2(0, 60)
		cont.add_theme_font_size_override("font_size", 22)
		cont.text = Lang.ui("menu_continue")
		cont.pressed.connect(func():
			Audio.play(&"click")
			continue_run.emit())
		var box: VBoxContainer = $UI/Root/Buttons
		box.add_child(cont)
		box.move_child(cont, 0)
	new_btn.pressed.connect(func(): start_new_game.emit())
	codex_btn.pressed.connect(func(): open_bestiary.emit())
	quit_btn.pressed.connect(func(): get_tree().quit())
	# Add SETTINGS + ACHIEVEMENTS buttons after the codex.
	var box: VBoxContainer = $UI/Root/Buttons
	var ach := Button.new()
	ach.custom_minimum_size = Vector2(0, 50)
	ach.add_theme_font_size_override("font_size", 18)
	ach.text = Lang.ui("menu_achievements")
	ach.pressed.connect(func():
		Audio.play(&"click")
		open_achievements.emit())
	box.add_child(ach)
	box.move_child(ach, codex_btn.get_index() + 1)
	var sett := Button.new()
	sett.custom_minimum_size = Vector2(0, 46)
	sett.add_theme_font_size_override("font_size", 16)
	sett.text = Lang.ui("menu_settings")
	sett.pressed.connect(func():
		Audio.play(&"click")
		open_settings.emit())
	box.add_child(sett)
	box.move_child(sett, ach.get_index() + 1)
	fr_btn.pressed.connect(func(): _set_lang("fr"))
	en_btn.pressed.connect(func(): _set_lang("en"))
	id_btn.pressed.connect(func(): _set_lang("id"))
	# Atmospheric backdrop behind the menu: a full biome vista (ground, shader
	# sky, fog, lit props) so the title sits over a living world, not the void.
	var biomes := [&"highland", &"forest", &"coast", &"ruins", &"crypt"]
	var backdrop := Backdrop3D.new()
	add_child(backdrop)
	backdrop.build(biomes[randi() % biomes.size()], 0.2, 0)
	# Pull the showcase dragon back so it glides over the landscape.
	_dragon = Dragon3D.new()
	anchor.add_child(_dragon)
	_dragon.build(&"lawbringer")
	_dragon.position = Vector3(-14, 7.5, -16)
	_dragon.scale = Vector3.ONE * 1.1
	# Slow cinematic flyby that loops across the sky.
	_dragon_flyby_loop()
	# Gentle camera drift for life.
	var cam := $Camera3D as Camera3D
	var cdrift := create_tween().set_loops()
	cdrift.tween_property(cam, "position:x", 0.6, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cdrift.tween_property(cam, "position:x", -0.6, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Title breathing glow.
	var tpulse := create_tween().set_loops()
	tpulse.tween_property(title_label, "modulate", Color(1.0, 0.97, 0.85), 2.2).set_trans(Tween.TRANS_SINE)
	tpulse.tween_property(title_label, "modulate", Color(0.85, 0.75, 0.55), 2.2).set_trans(Tween.TRANS_SINE)
	# Progression record — a "beat your best" hook so each run has a goal.
	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_font_size_override("font_size", 15)
	_stats_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.6))
	var stats_box: VBoxContainer = $UI/Root/Buttons
	stats_box.add_child(_stats_label)
	stats_box.move_child(_stats_label, 0)
	_refresh_stats()
	_refresh_lang()

func _refresh_stats() -> void:
	if _stats_label == null: return
	var dz: int = Progress.deepest_zone + 1
	_stats_label.text = Lang.t({
		"fr": "🏔 Record zone %d   ·   ⚔ %d traversées   ·   💎 %d   ·   🜂 %d échos" % [dz, Progress.runs_completed, Progress.fragments, Progress.echoes],
		"en": "🏔 Best zone %d   ·   ⚔ %d runs   ·   💎 %d   ·   🜂 %d echoes" % [dz, Progress.runs_completed, Progress.fragments, Progress.echoes],
		"id": "🏔 Rekor zona %d   ·   ⚔ %d run   ·   💎 %d   ·   🜂 %d gema" % [dz, Progress.runs_completed, Progress.fragments, Progress.echoes],
	})

func _dragon_flyby_loop() -> void:
	if not is_instance_valid(_dragon): return
	_dragon.position = Vector3(-16, 7.5, -16)
	_dragon.rotation.y = 0.0
	var t := create_tween()
	t.tween_property(_dragon, "position", Vector3(16, 9.5, -18), 14.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(_dragon, "rotation:y", -0.35, 14.0)
	t.tween_callback(_dragon_flyby_loop)

func _set_lang(c: String) -> void:
	Lang.code = c
	Lang.save_pref()
	_refresh_lang()

func _refresh_lang() -> void:
	tagline_label.text = Lang.ui("tagline")
	new_btn.text = Lang.ui("menu_new")
	codex_btn.text = Lang.ui("menu_codex")
	quit_btn.text = Lang.ui("menu_quit")
