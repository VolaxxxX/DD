class_name PlayerState extends RefCounted
# Holds the chosen character + run-state injuries.

var name: String = "Voyageur"
var class_kind: int = PlayerClass.Kind.SOLDAT
var class_data: Dictionary = {}
var stats: Dictionary = {}                  # stat_key -> int
var injuries: Array[StringName] = []
var relics: Array[StringName] = []                # up to 3 relics carried
var alive: bool = true

const MAX_RELICS := 3

func add_relic(id: StringName) -> bool:
	if id in relics: return false
	if relics.size() >= MAX_RELICS:
		relics.remove_at(0)
	relics.append(id)
	# Star Stone applies its passive immediately.
	var r: Dictionary = RelicRegistry.by_id(id)
	if String(r.get("passive", "")) == "perma_endurance":
		stats[&"endurance"] = int(stats.get(&"endurance", 8)) + 1
	return true

func relic_bonus(ctx: Dictionary) -> int:
	var total := 0
	for rid in relics:
		total += RelicRegistry.bonus_for(rid, ctx)
	return total

func setup(p_name: String, kind: int, p_stats: Dictionary = {}) -> void:
	name = p_name if p_name.strip_edges() != "" else "Voyageur"
	class_kind = kind
	class_data = PlayerClass.by_kind(kind)
	stats.clear()
	if p_stats.is_empty():
		for k in PlayerClass.stat_keys():
			stats[k] = int(class_data.base_stats.get(k, 8))
	else:
		for k in PlayerClass.stat_keys():
			stats[k] = int(p_stats.get(k, class_data.base_stats.get(k, 8)))
	injuries.clear()
	alive = true

func has_injury(id: StringName) -> bool:
	return id in injuries

func add_injury(id: StringName) -> bool:
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

func stat(key: StringName) -> int:
	return int(stats.get(key, 8))

func effective_stat(key: StringName) -> int:
	var s := stat(key)
	for inj_id in injuries:
		var inj: Dictionary = InjuryRegistry.by_id(inj_id)
		if String(inj.get("affects_stat", "")) == String(key):
			s -= int(inj.get("force_penalty", 0))
		elif inj.get("affects_stat", "") == "" and key == &"force":
			s -= int(inj.get("force_penalty", 0))
	return maxi(1, s)

func effective_force() -> int:
	# Backwards-compat for HUD.
	return effective_stat(&"force")

func tone_modifier(tone: int) -> int:
	var bonus: Array = class_data.get("tone_bonus", [])
	var malus: Array = class_data.get("tone_malus", [])
	if tone in bonus: return 2
	if tone in malus: return -2
	return 0

func roll_stat_for_tone(tone: int) -> int:
	# Tone-driven roll: use the tone's primary stat + class affinity bonus.
	var key: StringName = PlayerClass.tone_stat(tone)
	return effective_stat(key) + tone_modifier(tone)

func endurance_mitigation() -> int:
	# Higher endurance reduces fatal threshold (~1 per 2 points instead of 3).
	return int(stat(&"endurance") / 2)
