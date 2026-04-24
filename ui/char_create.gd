extends Node3D
# Character creation screen: name + class picker with live 3D preview.

signal character_chosen(name: String, kind: int)

@onready var name_edit: LineEdit = $UI/Root/Panel/V/NameRow/NameEdit
@onready var class_label: Label = $UI/Root/Panel/V/ClassName
@onready var tagline_label: Label = $UI/Root/Panel/V/Tagline
@onready var stats_label: RichTextLabel = $UI/Root/Panel/V/Stats
@onready var prev_btn: Button = $UI/Root/Panel/V/ClassRow/Prev
@onready var next_btn: Button = $UI/Root/Panel/V/ClassRow/Next
@onready var play_btn: Button = $UI/Root/Panel/V/Play
@onready var preview_anchor: Node3D = $PreviewAnchor

var _classes: Array
var _idx: int = 0
var _avatar: Player3D

func _ready() -> void:
	_classes = PlayerClass.all()
	prev_btn.pressed.connect(_prev)
	next_btn.pressed.connect(_next)
	play_btn.pressed.connect(_confirm)
	_refresh()
	_spin_avatar()

func _spin_avatar() -> void:
	var t := create_tween().set_loops()
	t.tween_property(preview_anchor, "rotation:y", TAU, 8.0)

func _refresh() -> void:
	var c: Dictionary = _classes[_idx]
	class_label.text = String(c.name)
	tagline_label.text = String(c.tagline)
	var bonus_names := _tone_names(c.tone_bonus)
	var malus_names := _tone_names(c.tone_malus)
	var resist_names: Array[String] = []
	for r in c.injury_resist:
		var inj: Dictionary = InjuryRegistry.by_id(r)
		if not inj.is_empty(): resist_names.append(String(inj.name))
	var lines := PackedStringArray()
	lines.append("[b]FORCE[/b]  %d" % int(c.force))
	if not bonus_names.is_empty(): lines.append("[color=#9fffa8]Affinités[/color]  " + ", ".join(bonus_names))
	if not malus_names.is_empty(): lines.append("[color=#ff8b8b]Faiblesses[/color]  " + ", ".join(malus_names))
	if not resist_names.is_empty(): lines.append("[color=#a0c8ff]Résistance[/color]  " + ", ".join(resist_names))
	stats_label.text = "\n".join(lines)
	_rebuild_avatar()

func _tone_names(arr: Array) -> Array[String]:
	var labels := {0: "Agressif", 1: "Diplomate", 2: "Prudent", 3: "Curieux", 4: "Trompeur", 5: "Mystique"}
	var out: Array[String] = []
	for t in arr: out.append(labels.get(int(t), "?"))
	return out

func _rebuild_avatar() -> void:
	if _avatar and is_instance_valid(_avatar):
		_avatar.queue_free()
	_avatar = Player3D.new()
	preview_anchor.add_child(_avatar)
	_avatar.build(_classes[_idx])

func _prev() -> void:
	_idx = (_idx - 1 + _classes.size()) % _classes.size()
	_refresh()

func _next() -> void:
	_idx = (_idx + 1) % _classes.size()
	_refresh()

func _confirm() -> void:
	var n := name_edit.text.strip_edges()
	if n == "": n = "Voyageur"
	character_chosen.emit(n, int(_classes[_idx].kind))
