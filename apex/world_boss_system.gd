class_name WorldBossSystem extends RefCounted
# Decides if a world boss manifests during a run.
# Very rare: base 0.2%, scaled by corruption drift + runs completed, capped at 5%.
# Requires an elite+ kill this run to unlock.

static func maybe_trigger(memory: WorldMemory, final_zone: Zone, elite_kills_this_run: int, rng: DRNG) -> Dictionary:
	if elite_kills_this_run <= 0: return {}
	var runs_done: int = int(memory.data.get("runs_completed", 0))
	var drift: float = float(memory.data.get("corruption_drift", 0.0))
	var base := 0.002
	var scaled := base + drift / 5000.0 + runs_done / 500.0
	scaled = clampf(scaled, 0.0, 0.05)
	var roll := rng.range_i(0, 100000) / 100000.0
	if roll > scaled: return {}
	var boss: Dictionary = WorldBossRegistry.pick(rng)
	_apply_world_effect(final_zone, boss)
	Bus.apex_manifested.emit(99, final_zone.index)
	print("[WORLD BOSS] %s manifested in zone %d" % [String(boss.name), final_zone.index])
	return boss

static func _apply_world_effect(zone: Zone, boss: Dictionary) -> void:
	match String(boss.effect):
		"all_tones_mixed":
			zone.chaos = clampf(zone.chaos + 0.3, 0.0, 1.0)
		"strip_memory":
			zone.corruption = clampf(zone.corruption + 0.2, 0.0, 1.0)
		"flood_corruption":
			zone.corruption = clampf(zone.corruption + 0.5, 0.0, 1.0)
		"judge_every_choice":
			for a in zone.ecosystem.roster:
				a.intelligence = mini(100, a.intelligence + 20)
		"disable_dialogue":
			for a in zone.ecosystem.roster:
				a.aggression = mini(100, a.aggression + 30)
		"invert_outcomes":
			zone.chaos = clampf(zone.chaos + 0.4, 0.0, 1.0)
			zone.corruption = clampf(zone.corruption + 0.2, 0.0, 1.0)
		"drown_zone":
			# The drowning god floods minds: aggression locked low, charisme moot.
			zone.corruption = clampf(zone.corruption + 0.45, 0.0, 1.0)
			for a in zone.ecosystem.roster:
				a.aggression = mini(100, a.aggression + 35)
				a.intelligence = mini(100, a.intelligence + 15)
