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
	# Showcase dragon (a metallic gold one — bright, regal).
	_dragon = Dragon3D.new()
	anchor.add_child(_dragon)
	_dragon.build(&"lawbringer")
	_dragon.position = Vector3(0, 0.5, -3.0)
	_dragon.scale = Vector3.ONE * 0.6
	var spin := create_tween().set_loops()
	spin.tween_property(anchor, "rotation:y", TAU, 22.0)
	_refresh_lang()

func _set_lang(c: String) -> void:
	Lang.code = c
	Lang.save_pref()
	_refresh_lang()

func _refresh_lang() -> void:
	tagline_label.text = Lang.ui("tagline")
	new_btn.text = Lang.ui("menu_new")
	codex_btn.text = Lang.ui("menu_codex")
	quit_btn.text = Lang.ui("menu_quit")
