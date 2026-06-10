extends Node3D
# Character creation: name + class picker + stat point allocation + 3D preview.

signal characters_ready(player_defs: Array)  # [{name, kind, stats}] — 1 (solo) ou 2 (duo)

@onready var name_edit: LineEdit = $UI/Root/Panel/V/NameRow/NameEdit
@onready var class_label: Label = $UI/Root/Panel/V/ClassName
@onready var tagline_label: Label = $UI/Root/Panel/V/Tagline
@onready var stats_grid: GridContainer = $UI/Root/Panel/V/StatsGrid
@onready var points_label: Label = $UI/Root/Panel/V/PointsLabel
@onready var prev_btn: Button = $UI/Root/Panel/V/ClassRow/Prev
@onready var next_btn: Button = $UI/Root/Panel/V/ClassRow/Next
@onready var play_btn: Button = $UI/Root/Panel/V/Play
@onready var preview_anchor: Node3D = $PreviewAnchor

var _classes: Array
var _idx: int = 0
var _avatar: Player3D
var _stats: Dictionary = {}
var _points_left: int = 0
var _stat_value_labels: Dictionary = {}     # key -> Label
var _stat_plus_buttons: Dictionary = {}     # key -> Button
var _stat_minus_buttons: Dictionary = {}    # key -> Button
var _base_for_class: Dictionary = {}        # cached base stats for current class
var _duo: bool = false
var _collected: Array = []                  # player defs already confirmed
var _duo_btn: CheckButton

func _ready() -> void:
	Lang.load_pref()
	_classes = PlayerClass.all()
	prev_btn.pressed.connect(_prev)
	next_btn.pressed.connect(_next)
	play_btn.pressed.connect(_confirm)
	# Language row: FR | EN | ID
	var lang_row := HBoxContainer.new()
	lang_row.alignment = BoxContainer.ALIGNMENT_CENTER
	lang_row.add_theme_constant_override("separation", 12)
	for lc in ["fr", "en", "id"]:
		var b := Button.new()
		b.text = lc.to_upper()
		b.custom_minimum_size = Vector2(64, 40)
		var code := lc
		b.pressed.connect(func():
			Lang.code = code
			Lang.save_pref()
			_update_play_label()
			_duo_btn.text = Lang.ui("duo")
			_refresh())
		lang_row.add_child(b)
	var v0 := $UI/Root/Panel/V
	v0.add_child(lang_row)
	v0.move_child(lang_row, 0)
	_duo_btn = CheckButton.new()
	_duo_btn.text = Lang.ui("duo")
	_duo_btn.add_theme_font_size_override("font_size", 16)
	_duo_btn.toggled.connect(func(on: bool): _duo = on; _update_play_label())
	var v := $UI/Root/Panel/V
	v.add_child(_duo_btn)
	v.move_child(_duo_btn, 1)
	_build_stat_rows()
	_load_class(_idx)
	_spin_avatar()

func _update_play_label() -> void:
	if _duo and _collected.is_empty():
		play_btn.text = Lang.ui("p1_ok")
	elif _duo:
		play_btn.text = Lang.ui("p2_ok")
	else:
		play_btn.text = Lang.ui("enter")

func _spin_avatar() -> void:
	var t := create_tween().set_loops()
	t.tween_property(preview_anchor, "rotation:y", TAU, 8.0)

func _build_stat_rows() -> void:
	stats_grid.columns = 4
	for k in PlayerClass.stat_keys():
		var name_lbl := Label.new()
		name_lbl.text = PlayerClass.stat_label(k)
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.custom_minimum_size = Vector2(120, 0)
		stats_grid.add_child(name_lbl)

		var minus := Button.new()
		minus.text = "-"
		minus.custom_minimum_size = Vector2(36, 36)
		var key := k
		minus.pressed.connect(func(): _adjust(key, -1))
		stats_grid.add_child(minus)
		_stat_minus_buttons[k] = minus

		var val_lbl := Label.new()
		val_lbl.text = "8"
		val_lbl.add_theme_font_size_override("font_size", 18)
		val_lbl.custom_minimum_size = Vector2(36, 0)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_grid.add_child(val_lbl)
		_stat_value_labels[k] = val_lbl

		var plus := Button.new()
		plus.text = "+"
		plus.custom_minimum_size = Vector2(36, 36)
		plus.pressed.connect(func(): _adjust(key, 1))
		stats_grid.add_child(plus)
		_stat_plus_buttons[k] = plus

func _load_class(idx: int) -> void:
	var c: Dictionary = _classes[idx]
	_base_for_class = c.base_stats.duplicate()
	_stats.clear()
	for k in PlayerClass.stat_keys():
		_stats[k] = int(_base_for_class.get(k, 8))
	_points_left = PlayerClass.ALLOC_POINTS
	_refresh()

func _refresh() -> void:
	var c: Dictionary = _classes[_idx]
	class_label.text = String(c.name)
	tagline_label.text = String(c.tagline)
	points_label.text = Lang.ui("points") % _points_left
	for k in PlayerClass.stat_keys():
		var v: int = int(_stats[k])
		var base: int = int(_base_for_class.get(k, 8))
		var lbl: Label = _stat_value_labels[k]
		lbl.text = str(v)
		if v > base:    lbl.add_theme_color_override("font_color", Color(0.55, 1.0, 0.55))
		elif v < base:  lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.55))
		else:           lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		_stat_plus_buttons[k].disabled = (_points_left <= 0) or (v >= PlayerClass.STAT_MAX)
		_stat_minus_buttons[k].disabled = (v <= base) or (v <= PlayerClass.STAT_MIN)
	_rebuild_avatar()

func _adjust(k: StringName, delta: int) -> void:
	var v: int = int(_stats[k]) + delta
	var base: int = int(_base_for_class.get(k, 8))
	if delta > 0 and _points_left <= 0: return
	if v < maxi(base, PlayerClass.STAT_MIN): return
	if v > PlayerClass.STAT_MAX: return
	_stats[k] = v
	_points_left -= delta
	_refresh()

func _rebuild_avatar() -> void:
	if _avatar and is_instance_valid(_avatar):
		_avatar.queue_free()
	_avatar = Player3D.new()
	preview_anchor.add_child(_avatar)
	_avatar.build(_classes[_idx])

func _prev() -> void:
	_idx = (_idx - 1 + _classes.size()) % _classes.size()
	_load_class(_idx)

func _next() -> void:
	_idx = (_idx + 1) % _classes.size()
	_load_class(_idx)

func _confirm() -> void:
	var n := name_edit.text.strip_edges()
	if n == "": n = "Voyageur" if _collected.is_empty() else "Compagnon"
	_collected.append({"name": n, "kind": int(_classes[_idx].kind), "stats": _stats.duplicate()})
	if _duo and _collected.size() < 2:
		# Reset the form for player 2.
		name_edit.text = ""
		_duo_btn.disabled = true
		_idx = (_idx + 1) % _classes.size()
		_load_class(_idx)
		_update_play_label()
		return
	characters_ready.emit(_collected)
