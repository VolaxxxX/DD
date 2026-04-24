class_name PlayerState extends RefCounted
# Holds the chosen character + run-state injuries.

var name: String = "Voyageur"
var class_kind: int = PlayerClass.Kind.SOLDAT
var class_data: Dictionary = {}
var stat: int = 10                          # FORCE base
var injuries: Array[StringName] = []
var alive: bool = true

func setup(p_name: String, kind: int) -> void:
	name = p_name if p_name.strip_edges() != "" else "Voyageur"
	class_kind = kind
	class_data = PlayerClass.by_kind(kind)
	stat = int(class_data.force)
	injuries.clear()
	alive = true

func has_injury(id: StringName) -> bool:
	return id in injuries

func add_injury(id: StringName) -> bool:
	# Returns true if newly added.
	if has_injury(id): return false
	var resist: Array = class_data.get("injury_resist", [])
	if id in resist: return false
	injuries.append(id)
	return true

func tone_locked(tone: int) -> bool:
	for inj_id in injuries:
		var inj: Dictionary = InjuryRegistry.by_id(inj_id)
		if int(inj.get("lock_tone", -1)) == tone: return true
	return false

func effective_force() -> int:
	var s := stat
	for inj_id in injuries:
		var inj: Dictionary = InjuryRegistry.by_id(inj_id)
		s -= int(inj.get("force_penalty", 0))
	return maxi(1, s)

func tone_modifier(tone: int) -> int:
	var bonus: Array = class_data.get("tone_bonus", [])
	var malus: Array = class_data.get("tone_malus", [])
	if tone in bonus: return 2
	if tone in malus: return -2
	return 0
