extends CanvasLayer
# Minimal HUD: danger pulse, outcome feedback, virtual controls.

@onready var pulse: ColorRect = $DangerPulse
@onready var outcome_label: Label = $OutcomeLabel

const OUTCOME_TEXT := {
	0: "DISASTER",
	1: "FAIL",
	2: "MIXED",
	3: "SUCCESS",
	4: "TRIUMPH",
}

const OUTCOME_COLOR := {
	0: Color(1.0, 0.1, 0.1),
	1: Color(1.0, 0.5, 0.2),
	2: Color(1.0, 1.0, 0.4),
	3: Color(0.4, 1.0, 0.5),
	4: Color(0.5, 0.9, 1.0),
}

func _ready() -> void:
	Bus.event_resolved.connect(_on_event)
	Bus.apex_manifested.connect(_on_apex)
	Bus.zone_changed.connect(_on_zone)
	pulse.modulate.a = 0.0
	outcome_label.text = ""

func _on_event(_id: int, outcome: int, _n: StringName) -> void:
	outcome_label.text = OUTCOME_TEXT.get(outcome, "?")
	outcome_label.modulate = OUTCOME_COLOR.get(outcome, Color.WHITE)
	create_tween().tween_property(outcome_label, "modulate:a", 0.0, 2.0).from(1.0)
	pulse.color = OUTCOME_COLOR.get(outcome, Color.WHITE)
	pulse.modulate.a = 0.6
	create_tween().tween_property(pulse, "modulate:a", 0.0, 1.2)

func _on_apex(_kind: int, _zone: int) -> void:
	pulse.color = Color(1, 0.2, 0.1)
	pulse.modulate.a = 1.0
	create_tween().tween_property(pulse, "modulate:a", 0.0, 3.0)

func _on_zone(idx: int, _seed: int) -> void:
	outcome_label.text = "ZONE %d" % (idx + 1)
	outcome_label.modulate = Color.WHITE
	create_tween().tween_property(outcome_label, "modulate:a", 0.0, 3.0).from(1.0)
