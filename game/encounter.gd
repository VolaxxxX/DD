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
var followup_choices: Array[Dictionary] = []  # populated after successful diplomacy with smart creature
var has_followup: bool = false

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
	difficulty += BiomeRules.tone_difficulty_mod(zone.biome, tone)
	var stat_key: StringName = PlayerClass.tone_stat(tone)
	var actor_stat: int = player.roll_stat_for_tone(tone) + BiomeRules.stat_mod(zone.biome, stat_key)
	# Dragon presence bends the odds.
	match zone.dragon_effect:
		"slow_flight":
			if tone == PhrasePool.Tone.CAUTIOUS: difficulty += zone.dragon_value
		"peace_truce":
			if tone == PhrasePool.Tone.DIPLOMATIC: difficulty -= zone.dragon_value
		"deceptive_boost":
			if tone == PhrasePool.Tone.DECEPTIVE: difficulty -= zone.dragon_value
		"guided_instinct":
			if stat_key == &"instinct": actor_stat += zone.dragon_value
	var r: Dictionary = resolver.resolve(choice.kind, actor_stat, difficulty, coop_mod, world_mod, [creature.id])
	var outcome: int = r.outcome
	# Outcome-warping dragons.
	match zone.dragon_effect:
		"swingy_rolls":
			if outcome == FateEngine.Outcome.SUCCESS and rng.chance(zone.dragon_value, 100):
				outcome = FateEngine.Outcome.CRIT_SUCCESS
			elif outcome == FateEngine.Outcome.FAIL and rng.chance(zone.dragon_value, 100):
				outcome = FateEngine.Outcome.CRIT_FAIL
		"mixed_becomes_fail":
			if outcome == FateEngine.Outcome.MIXED: outcome = FateEngine.Outcome.FAIL
		"free_crit_cursed":
			if outcome == FateEngine.Outcome.CRIT_FAIL and not zone.dragon_gift_used:
				zone.dragon_gift_used = true
				outcome = FateEngine.Outcome.MIXED
				player.add_injury(&"curse")

	var narrative: String = PhrasePool.pick_outcome(rng, tone, outcome, creature_name)
	var cons := _consequences(tone, outcome)
	cons["narrative"] = narrative
	cons["outcome"] = outcome
	cons["tone"] = tone
	# Trigger followup dialogue on diplomatic/mystical success vs smart creature.
	if creature.archetype.intelligence >= 70 and outcome >= FateEngine.Outcome.SUCCESS:
		if tone == PhrasePool.Tone.DIPLOMATIC or tone == PhrasePool.Tone.MYSTICAL:
			cons["creature_flees"] = false  # keep creature on stage for the conversation
			followup_choices = _build_followup_choices()
			has_followup = true
			cons["has_followup"] = true
	return cons

func _build_followup_choices() -> Array[Dictionary]:
	# Three short conversational openings the creature is now willing to discuss.
	var pool := [
		{"text": "Tu lui demandes son nom.",
		 "narr_good": "%s te le donne. Ce n'est pas un nom humain. Tu le garderas.",
		 "narr_bad":  "%s ne te répond pas. Le moment passe.",
		 "stat": &"esprit"},
		{"text": "Tu lui demandes ce qu'il craint.",
		 "narr_good": "%s te dit ce qu'il craint. C'est utile. C'est terrible.",
		 "narr_bad":  "%s rit. Il ne craint rien que tu pourrais comprendre.",
		 "stat": &"instinct"},
		{"text": "Tu lui demandes ce qu'il y a après ces terres.",
		 "narr_good": "%s te raconte la route. Tu sais maintenant où ne pas aller.",
		 "narr_bad":  "%s te dit la vérité. Tu aurais préféré ne pas savoir.",
		 "stat": &"esprit"},
		{"text": "Tu lui demandes ce que tu deviens, toi.",
		 "narr_good": "%s te regarde longtemps. Puis il te dit. Tu ne savais pas.",
		 "narr_bad":  "%s te dit. Tu aurais préféré ne pas demander.",
		 "stat": &"instinct"},
		{"text": "Tu lui demandes une faveur.",
		 "narr_good": "%s accepte. Quelque chose en toi se répare. Tu n'oublies pas.",
		 "narr_bad":  "%s rit doucement. Tu n'as plus rien à offrir en échange.",
		 "stat": &"charisme",
		 "heal_chance": true},
		{"text": "Tu lui poses la question que tu te poses depuis ta première zone.",
		 "narr_good": "%s te répond. Le monde a un peu de sens maintenant.",
		 "narr_bad":  "%s ne te comprend pas. Ou ne veut pas.",
		 "stat": &"esprit"},
	]
	# Pick 3 deterministically.
	var out: Array[Dictionary] = []
	var idxs := []
	for i in pool.size(): idxs.append(i)
	while idxs.size() > 3:
		idxs.remove_at(rng.range_i(0, idxs.size()))
	for i in idxs:
		var c: Dictionary = pool[i]
		out.append({"tone": PhrasePool.Tone.DIPLOMATIC, "text": String(c.text), "kind": 1, "_followup": c})
	return out

func resolve_followup(idx: int) -> Dictionary:
	var ui_choice: Dictionary = followup_choices[idx]
	var c: Dictionary = ui_choice._followup
	var stat_key: StringName = c.stat
	var actor: int = player.effective_stat(stat_key)
	var success: bool = actor + rng.range_i(1, 11) >= 12
	var narr: String = (c.narr_good if success else c.narr_bad) % creature_name
	var result := {
		"narrative": narr,
		"outcome": 3 if success else 2,
		"tone": PhrasePool.Tone.DIPLOMATIC,
		"stat_delta": 1 if success else 0,
		"stat": stat_key,
		"creature_dies": false,
		"creature_flees": true,  # conversation ends, creature leaves
		"mutate": false,
		"injury": &"",
		"heal": &"",
		"fatal": false,
	}
	if success and c.get("heal_chance", false) and not player.injuries.is_empty():
		result["heal"] = player.injuries[rng.range_i(0, player.injuries.size())]
	has_followup = false
	return result

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
