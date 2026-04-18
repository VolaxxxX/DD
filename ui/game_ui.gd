extends CanvasLayer
# Main game UI: narrative panel, choice buttons, stat icons.

signal choice_selected(index: int)

@onready var narrative: RichTextLabel = $Root/NarrativeBox/Narrative
@onready var intro_label: Label = $Root/IntroLabel
@onready var choice0: Button = $Root/ChoicesBox/Choice0
@onready var choice1: Button = $Root/ChoicesBox/Choice1
@onready var choice2: Button = $Root/ChoicesBox/Choice2
@onready var hp_label: Label = $Root/StatsBox/HPLabel
@onready var stat_label: Label = $Root/StatsBox/StatLabel
@onready var zone_label: Label = $Root/StatsBox/ZoneLabel
@onready var fade: ColorRect = $Root/Fade

var choice_buttons: Array[Button] = []

const TONE_COLOR := {
	0: Color(1.0, 0.45, 0.35),  # AGGRESSIVE
	1: Color(0.75, 0.9, 1.0),   # DIPLOMATIC
	2: Color(0.95, 0.95, 0.75), # CAUTIOUS
	3: Color(0.85, 0.75, 1.0),  # CURIOUS
}

const OUTCOME_TINT := {
	0: Color(1.0, 0.25, 0.25), # CRIT_FAIL
	1: Color(1.0, 0.55, 0.30), # FAIL
	2: Color(1.0, 0.95, 0.55), # MIXED
	3: Color(0.55, 1.0, 0.55), # SUCCESS
	4: Color(0.55, 0.95, 1.0), # CRIT_SUCCESS
}

func _ready() -> void:
	choice_buttons = [choice0, choice1, choice2]
	for i in choice_buttons.size():
		var idx := i
		choice_buttons[i].pressed.connect(func(): _on_choice_pressed(idx))
	_hide_choices()
	narrative.text = ""
	intro_label.text = ""
	fade.modulate.a = 0.0

func present_intro(text: String) -> void:
	_hide_choices()
	narrative.text = ""
	intro_label.text = text
	intro_label.modulate = Color(1, 1, 1, 0)
	var t := create_tween()
	t.tween_property(intro_label, "modulate:a", 1.0, 0.6)
	t.tween_interval(1.6)
	t.tween_property(intro_label, "modulate:a", 0.0, 0.8)

func present_encounter(enc: Encounter) -> void:
	narrative.text = ""
	_show_choices()
	for i in choice_buttons.size():
		var btn := choice_buttons[i]
		if i < enc.choices.size():
			var c: Dictionary = enc.choices[i]
			btn.visible = true
			btn.text = c.text
			btn.modulate = TONE_COLOR.get(c.tone, Color.WHITE)
			btn.disabled = false
		else:
			btn.visible = false

func show_narrative(text: String, _tone: int, outcome: int) -> void:
	_hide_choices()
	narrative.modulate = OUTCOME_TINT.get(outcome, Color.WHITE)
	narrative.text = text
	_flash_fade(OUTCOME_TINT.get(outcome, Color.WHITE), 0.25 if outcome == 2 else 0.5)

func update_stats(hp: int, stat: int) -> void:
	hp_label.text = "VIE : " + _hearts(hp)
	stat_label.text = "FORCE : " + _bars(stat, 20)

func update_zone(index: int, biome: StringName) -> void:
	zone_label.text = "ZONE %d — %s" % [index + 1, String(biome).to_upper()]

func _hearts(hp: int) -> String:
	var s := ""
	for i in maxi(0, hp): s += "♥ "
	return s.strip_edges() if s else "—"

func _bars(v: int, maxv: int) -> String:
	var filled := clampi(v, 0, maxv)
	var s := ""
	for i in filled: s += "|"
	return s

func show_run_over(cause: StringName) -> void:
	_hide_choices()
	narrative.modulate = Color(1, 0.4, 0.4)
	narrative.text = "\n\n[center][b]FIN DU PÉRIPLE[/b]\n%s[/center]" % cause
	fade.color = Color(0, 0, 0)
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.6, 1.5)

func _on_choice_pressed(idx: int) -> void:
	for b in choice_buttons: b.disabled = true
	choice_selected.emit(idx)

func _hide_choices() -> void:
	for b in choice_buttons: b.visible = false

func _show_choices() -> void:
	for b in choice_buttons: b.visible = true

func _flash_fade(color: Color, alpha: float) -> void:
	fade.color = color
	fade.modulate.a = alpha
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 1.0)
