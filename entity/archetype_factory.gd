class_name ArchetypeFactory extends RefCounted
# Generates a procedural roster of archetypes per zone.

const FAMILY_BY_BIOME := {
	&"forest":    [Archetype.Family.BEAST, Archetype.Family.FEY, Archetype.Family.HUMANOID],
	&"city":      [Archetype.Family.HUMANOID, Archetype.Family.CONSTRUCT, Archetype.Family.UNDEAD],
	&"ruins":     [Archetype.Family.UNDEAD, Archetype.Family.CONSTRUCT, Archetype.Family.ABERRATION],
	&"corrupted": [Archetype.Family.ABERRATION, Archetype.Family.UNDEAD, Archetype.Family.ELEMENTAL],
	&"anomaly":   [Archetype.Family.ABERRATION, Archetype.Family.FEY, Archetype.Family.ELEMENTAL],
}

static func roster(rng: DRNG, biome: StringName, chaos: float) -> Array[Archetype]:
	var out: Array[Archetype] = []
	var families: Array = FAMILY_BY_BIOME.get(biome, [Archetype.Family.BEAST])
	var size := 4 + int(chaos * 6.0)
	for i in size:
		var tier := _tier_roll(rng, chaos)
		# ALWAYS use a real, named creature when one exists — procedural mobs
		# (generic ids + mismatched auto-names like a "lion" that renders as a
		# llama) are only a last resort if a biome has no template at all.
		var named: Array = CreatureRegistry.for_biome_and_tier(biome, tier)
		if named.is_empty():
			named = CreatureRegistry.for_biome(biome)   # any tier in this biome
		var a: Archetype
		if not named.is_empty():
			a = _from_template(named[rng.range_i(0, named.size())])
		else:
			a = _procedural(rng, families, tier, chaos)
		out.append(a)
	return out

static func _from_template(t: Dictionary) -> Archetype:
	var a := Archetype.new()
	a.id = StringName(t.id)
	a.family = int(t.family)
	a.tier = int(t.tier)
	a.role = int(t.role)
	a.intelligence = int(t.intel)
	a.aggression = int(t.aggr)
	a.ecology_weight = maxi(10, 100 - a.tier * 15)
	a.influence_radius = 6.0 + a.tier * 2.0
	a.mutation_pool = []
	return a

static func _procedural(rng: DRNG, families: Array, tier: int, chaos: float) -> Archetype:
	var a := Archetype.new()
	a.family = families[rng.range_i(0, families.size())]
	a.tier = tier
	a.role = _role_for(a.family, rng)
	a.intelligence = rng.range_i(10, 90)
	a.aggression = rng.range_i(10, 90 + int(chaos * 10))
	a.ecology_weight = maxi(10, 100 - a.tier * 15)
	a.influence_radius = 6.0 + a.tier * 2.0
	a.id = StringName("a_%d_%d_%d" % [a.family, a.tier, rng.next() & 0xFFFF])
	a.mutation_pool = _mut_pool(a.family, rng)
	return a

static func _tier_roll(rng: DRNG, chaos: float) -> int:
	var roll := rng.range_i(0, 1000)
	var common_cap := int(500 - chaos * 250)        # 25..50%
	if roll < common_cap:        return Archetype.Tier.COMMON
	if roll < 800:               return Archetype.Tier.UNCOMMON   # ~30%
	if roll < 920:               return Archetype.Tier.RARE       # ~12%
	if roll < 980:               return Archetype.Tier.ELITE      # ~6%
	if roll < 998:               return Archetype.Tier.APEX       # ~1.8%
	return Archetype.Tier.MYTHIC                                  # ~0.2%

static func _role_for(fam: int, rng: DRNG) -> int:
	match fam:
		Archetype.Family.BEAST:
			return [Archetype.Role.PREDATOR, Archetype.Role.PREY][rng.range_i(0, 2)]
		Archetype.Family.HUMANOID:   return Archetype.Role.TERRITORIAL
		Archetype.Family.UNDEAD:     return Archetype.Role.SCAVENGER
		Archetype.Family.CONSTRUCT:  return Archetype.Role.TERRITORIAL
		Archetype.Family.ELEMENTAL:  return Archetype.Role.MODIFIER
		Archetype.Family.ABERRATION: return Archetype.Role.MODIFIER
		Archetype.Family.FEY:        return Archetype.Role.MODIFIER
		_:                           return Archetype.Role.PREDATOR

static func _mut_pool(fam: int, rng: DRNG) -> Array[StringName]:
	var pool: Array[StringName] = []
	var n := rng.range_i(1, 4)
	for i in n: pool.append(StringName("m_%d_%d" % [fam, rng.next() & 0xFF]))
	return pool
