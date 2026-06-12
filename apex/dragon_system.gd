class_name DragonSystem extends RefCounted
# Dragons are world forces. Each one applies its OWN effect to the zone,
# stored on the zone so encounters can consult it on every roll.

static func maybe_manifest(zone: Zone, rng: DRNG) -> void:
	var killed: Dictionary = zone.memory.data.get("killed_apex", {})
	var cooldown: int = int(killed.get(zone.index, 0))
	if cooldown > 0:
		killed[zone.index] = cooldown - 1
		zone.memory.data["killed_apex"] = killed
		return
	if zone.index == 0: return
	if not rng.chance(int(zone.chaos * 8), 100): return
	var dragon: Dictionary = DragonRegistry.pick(rng, zone.chaos)
	zone.dragon_id = StringName(dragon.id)
	zone.dragon_intro = DragonRegistry.intro_of(dragon)
	zone.dragon_effect = String(dragon.zone_effect)
	zone.dragon_value = int(dragon.value)
	_apply_manifest_effect(zone, rng)
	Bus.apex_manifested.emit(int(dragon.lineage), zone.index)
	print("[DRAGON] zone=%d id=%s effect=%s" % [zone.index, String(dragon.id), zone.dragon_effect])

static func _apply_manifest_effect(zone: Zone, rng: DRNG) -> void:
	# One-shot effects applied at manifestation. Persistent roll effects are
	# read from zone.dragon_effect by Encounter at resolve time.
	match zone.dragon_effect:
		"aggression_boost":
			for a in zone.ecosystem.roster:
				a.aggression = mini(100, a.aggression + zone.dragon_value)
		"intel_boost":
			for a in zone.ecosystem.roster:
				a.intelligence = mini(100, a.intelligence + zone.dragon_value)
		"corruption_double":
			zone.corruption = clampf(zone.corruption * 2.0, 0.0, 1.0)
		"delete_creature":
			# The Unlit Wyrm erases. One creature simply never existed.
			if zone.ecosystem.creatures.size() > 1:
				var idx := rng.range_i(0, zone.ecosystem.creatures.size())
				var victim: Creature = zone.ecosystem.creatures[idx]
				victim.alive = false
		_:
			pass
