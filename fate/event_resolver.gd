class_name EventResolver extends RefCounted
# Wraps FateEngine into concrete in-world events.

enum Kind { COMBAT, DIALOGUE, ANOMALY, ENCOUNTER }

var fate: FateEngine
var _next_id: int = 1

func _init(_fate: FateEngine) -> void:
	fate = _fate

func resolve(kind: int, actor_stat: int, difficulty: int, coop: int, world: int, refs: Array) -> Dictionary:
	var eid := _next_id
	_next_id += 1
	Bus.event_triggered.emit(eid, kind, refs)
	var outcome := fate.resolve(actor_stat, difficulty, coop, world)
	var narrative := _narrative(kind, outcome)
	Bus.event_resolved.emit(eid, outcome, narrative)
	return {"id": eid, "outcome": outcome, "narrative": narrative}

func _narrative(kind: int, outcome: int) -> StringName:
	return StringName("k%d_o%d" % [kind, outcome])
