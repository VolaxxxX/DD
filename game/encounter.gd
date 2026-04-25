class_name Encounter extends RefCounted
# One creature encounter: builds phrase choices and resolves them.
# Death is situational (rolled per CRIT_FAIL based on creature tier, tone, current injuries),
# not a hp counter. Most bad outcomes inflict an injury instead.

var zone: Zone
var creature: Creature
var rng: DRNG
var player: PlayerState
var choices: Array[Dictionary] = []  # [{tone, text, kind}]
var creature_name: String

func _init(_zone: Zone, _creature: Creature, _rng: DRNG, _player: PlayerState) -> void:
	zone = _zone
	creature = _creature
	rng = _rng
	player = _player
	creature_name = _resolve_name()
	choices = _build_choices()

func _resolve_name() -> String:
	if creature.archetype.id != &"":
		var named := CreatureRegistry.name_for_id(creature.archetype.id)
		if named != "l'entité": return named
	return PhrasePool.family_descriptor(creature.archetype.family, creature.archetype.tier)

func _build_choices() -> Array[Dictionary]:
	var tones: Array[int] = []
	tones.append(PhrasePool.Tone.AGGRESSIVE)
	if creature.archetype.intelligence >= 40:
		tones.append(PhrasePool.Tone.DIPLOMATIC)
	tones.append(PhrasePool.Tone.CAUTIOUS)
	if zone.biome == &"anomaly" or zone.biome == &"corrupted" or zone.biome == &"ruins":
		tones.append(PhrasePool.Tone.CURIOUS)
	if creature.archetype.intelligence >= 30:
		tones.append(PhrasePool.Tone.DECEPTIVE)
	var fam := creature.archetype.family
	var mystical_family := fam == Archetype.Family.FEY or fam == Archetype.Family.ABERRATION or fam == Archetype.Family.DRACONIC
	var mystical_biome := zone.biome == &"anomaly" or zone.biome == &"corrupted"
	if mystical_family or mystical_biome:
		tones.append(PhrasePool.Tone.MYSTICAL)

	# Strip tones locked by current injuries.
	var allowed: Array[int] = []
	for t in tones:
		if not player.tone_locked(t): allowed.append(t)
	if allowed.is_empty(): allowed.append(PhrasePool.Tone.CAUTIOUS)

	var out: Array[Dictionary] = []
	while allowed.size() > 3: allowed.remove_at(rng.range_i(0, allowed.size()))
	while allowed.size() < 3: allowed.append(PhrasePool.Tone.CAUTIOUS)

	for t in allowed:
		out.append({
			"tone": t,
			"text": PhrasePool.pick_choice(rng, t),
			"kind": _tone_to_kind(t),
		})
	return out

func _tone_to_kind(tone: int) -> int:
	match tone:
		PhrasePool.Tone.AGGRESSIVE: return EventResolver.Kind.COMBAT
		PhrasePool.Tone.DIPLOMATIC: return EventResolver.Kind.DIALOGUE
		PhrasePool.Tone.CAUTIOUS:   return EventResolver.Kind.ENCOUNTER
		PhrasePool.Tone.CURIOUS:    return EventResolver.Kind.ANOMALY
		PhrasePool.Tone.DECEPTIVE:  return EventResolver.Kind.DIALOGUE
		PhrasePool.Tone.MYSTICAL:   return EventResolver.Kind.ANOMALY
		_: return EventResolver.Kind.ENCOUNTER

func resolve(choice_idx: int, resolver: EventResolver, coop_mod: int) -> Dictionary:
	var choice: Dictionary = choices[choice_idx]
	var tone: int = choice.tone
	var difficulty: int = 10 + creature.archetype.aggression / 10 + int(zone.chaos * 5)
	var world_mod: int = -int(zone.corruption * 3)
	var actor_stat: int = player.roll_stat_for_tone(tone)
	var r: Dictionary = resolver.resolve(choice.kind, actor_stat, difficulty, coop_mod, world_mod, [creature.id])
	var outcome: int = r.outcome

	var narrative: String = PhrasePool.pick_outcome(rng, tone, outcome, creature_name)
	var cons := _consequences(tone, outcome)
	cons["narrative"] = narrative
	cons["outcome"] = outcome
	cons["tone"] = tone
	return cons

func _consequences(tone: int, outcome: int) -> Dictionary:
	var c := {
		"stat_delta": 0,
		"creature_dies": false, "creature_flees": false, "mutate": false,
		"injury": &"", "fatal": false,
	}
	match outcome:
		FateEngine.Outcome.CRIT_SUCCESS:
			match tone:
				PhrasePool.Tone.AGGRESSIVE: c.creature_dies = true; c.stat_delta = 1
				PhrasePool.Tone.DIPLOMATIC: c.creature_flees = true; c.stat_delta = 1
				PhrasePool.Tone.CAUTIOUS:   c.creature_flees = true
				PhrasePool.Tone.CURIOUS:    c.creature_flees = true; c.stat_delta = 2
				PhrasePool.Tone.DECEPTIVE:  c.creature_flees = true; c.stat_delta = 2
				PhrasePool.Tone.MYSTICAL:   c.creature_flees = true; c.stat_delta = 2; c.mutate = true
		FateEngine.Outcome.SUCCESS:
			match tone:
				PhrasePool.Tone.AGGRESSIVE: c.creature_dies = true
				PhrasePool.Tone.DIPLOMATIC: c.creature_flees = true
				PhrasePool.Tone.CAUTIOUS:   c.creature_flees = true
				PhrasePool.Tone.CURIOUS:    c.stat_delta = 1
				PhrasePool.Tone.DECEPTIVE:  c.creature_flees = true; c.stat_delta = 1
				PhrasePool.Tone.MYSTICAL:   c.stat_delta = 1
		FateEngine.Outcome.MIXED:
			match tone:
				PhrasePool.Tone.AGGRESSIVE: c.creature_flees = true; c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
				PhrasePool.Tone.DIPLOMATIC: c.creature_flees = true
				PhrasePool.Tone.CAUTIOUS:   c.creature_flees = true
				PhrasePool.Tone.CURIOUS:    pass
				PhrasePool.Tone.DECEPTIVE:  c.creature_flees = true; c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
				PhrasePool.Tone.MYSTICAL:   c.stat_delta = 1; c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
		FateEngine.Outcome.FAIL:
			c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
			if tone == PhrasePool.Tone.CURIOUS: c.stat_delta = -1
		FateEngine.Outcome.CRIT_FAIL:
			c.mutate = (tone == PhrasePool.Tone.CURIOUS or tone == PhrasePool.Tone.MYSTICAL)
			c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
			c.fatal = _roll_fatal(tone)
	return c

func _roll_fatal(tone: int) -> bool:
	# Death chance on CRIT_FAIL — scales with creature tier, tone risk, current injuries, corruption.
	var base := 5
	match int(creature.archetype.tier):
		Archetype.Tier.COMMON:    base = 4
		Archetype.Tier.UNCOMMON:  base = 8
		Archetype.Tier.RARE:      base = 16
		Archetype.Tier.ELITE:     base = 32
		Archetype.Tier.APEX:      base = 55
		Archetype.Tier.MYTHIC:    base = 85
	var tone_mult := 1.0
	match tone:
		PhrasePool.Tone.AGGRESSIVE: tone_mult = 1.7
		PhrasePool.Tone.DECEPTIVE:  tone_mult = 1.4
		PhrasePool.Tone.MYSTICAL:   tone_mult = 1.3
		PhrasePool.Tone.CURIOUS:    tone_mult = 1.1
		PhrasePool.Tone.DIPLOMATIC: tone_mult = 0.6
		PhrasePool.Tone.CAUTIOUS:   tone_mult = 0.4
	var threshold := int(base * tone_mult) + player.injuries.size() * 12 + int(zone.corruption * 15)
	threshold -= player.endurance_mitigation()
	return rng.range_i(0, 100) < threshold
