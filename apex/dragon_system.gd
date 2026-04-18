class_name DragonSystem extends RefCounted
# Apex ecosystem modifiers. Not scripted bosses — world forces.

enum Kind { CHROMATIC, METALLIC, EXOTIC }

static func maybe_manifest(zone: Zone, rng: DRNG) -> void:
	var killed: Dictionary = zone.memory.data.get("killed_apex", {})
	var cooldown: int = int(killed.get(zone.index, 0))
	if cooldown > 0:
		killed[zone.index] = cooldown - 1
		zone.memory.data["killed_apex"] = killed
		return
	if not rng.chance(int(zone.chaos * 30), 100): return
	var kind: int = rng.range_i(0, 3)
	_apply_modifier(zone, kind)
	Bus.apex_manifested.emit(kind, zone.index)
	print("[APEX] zone=%d kind=%d" % [zone.index, kind])

static func _apply_modifier(zone: Zone, kind: int) -> void:
	match kind:
		Kind.CHROMATIC:
			for a in zone.ecosystem.roster:
				a.aggression = mini(100, a.aggression + 25)
		Kind.METALLIC:
			for a in zone.ecosystem.roster:
				a.intelligence = mini(100, a.intelligence + 25)
		Kind.EXOTIC:
			zone.corruption = clampf(zone.corruption + 0.3, 0.0, 1.0)
