class_name Encounter extends RefCounted
# One creature encounter: builds phrase choices and resolves them.

var zone: Zone
var creature: Creature
var rng: DRNG
var choices: Array[Dictionary] = []  # [{tone, text, kind}]
var creature_name: String

func _init(_zone: Zone, _creature: Creature, _rng: DRNG) -> void:
	zone = _zone
	creature = _creature
	rng = _rng
	creature_name = PhrasePool.family_descriptor(creature.archetype.family, creature.archetype.tier)
	choices = _build_choices()

func _build_choices() -> Array[Dictionary]:
	var tones: Array[int] = []
	tones.append(PhrasePool.Tone.AGGRESSIVE)
	if creature.archetype.intelligence >= 40:
		tones.append(PhrasePool.Tone.DIPLOMATIC)
	tones.append(PhrasePool.Tone.CAUTIOUS)
	if zone.biome == &"anomaly" or zone.biome == &"corrupted" or zone.biome == &"ruins":
		tones.append(PhrasePool.Tone.CURIOUS)

	# Always produce 3 choices; shuffle tones deterministically.
	var out: Array[Dictionary] = []
	while tones.size() > 3: tones.remove_at(rng.range_i(0, tones.size()))
	while tones.size() < 3: tones.append(PhrasePool.Tone.CAUTIOUS)

	for t in tones:
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
		_: return EventResolver.Kind.ENCOUNTER

func resolve(choice_idx: int, resolver: EventResolver, player_stat: int, coop_mod: int) -> Dictionary:
	var choice: Dictionary = choices[choice_idx]
	var tone: int = choice.tone
	var difficulty: int = 10 + creature.archetype.aggression / 10 + int(zone.chaos * 5)
	var world_mod: int = -int(zone.corruption * 3)
	var r: Dictionary = resolver.resolve(choice.kind, player_stat, difficulty, coop_mod, world_mod, [creature.id])
	var outcome: int = r.outcome

	var narrative: String = PhrasePool.pick_outcome(rng, tone, outcome, creature_name)
	var cons := _consequences(tone, outcome)
	cons["narrative"] = narrative
	cons["outcome"] = outcome
	cons["tone"] = tone
	return cons

func _consequences(tone: int, outcome: int) -> Dictionary:
	# hp_delta, stat_delta, creature_dies, creature_flees, mutate, memory
	var c := {"hp_delta": 0, "stat_delta": 0, "creature_dies": false, "creature_flees": false, "mutate": false}
	match tone:
		PhrasePool.Tone.AGGRESSIVE:
			match outcome:
				FateEngine.Outcome.CRIT_SUCCESS: c.creature_dies = true; c.stat_delta = 1
				FateEngine.Outcome.SUCCESS:      c.creature_dies = true
				FateEngine.Outcome.MIXED:        c.hp_delta = -1; c.creature_flees = true
				FateEngine.Outcome.FAIL:         c.hp_delta = -1
				FateEngine.Outcome.CRIT_FAIL:    c.hp_delta = -2; c.mutate = true
		PhrasePool.Tone.DIPLOMATIC:
			match outcome:
				FateEngine.Outcome.CRIT_SUCCESS: c.creature_flees = true; c.stat_delta = 1
				FateEngine.Outcome.SUCCESS:      c.creature_flees = true
				FateEngine.Outcome.MIXED:        c.creature_flees = true
				FateEngine.Outcome.FAIL:         c.hp_delta = -1
				FateEngine.Outcome.CRIT_FAIL:    c.hp_delta = -2
		PhrasePool.Tone.CAUTIOUS:
			match outcome:
				FateEngine.Outcome.CRIT_SUCCESS: c.creature_flees = true
				FateEngine.Outcome.SUCCESS:      c.creature_flees = true
				FateEngine.Outcome.MIXED:        c.creature_flees = true
				FateEngine.Outcome.FAIL:         c.hp_delta = -1
				FateEngine.Outcome.CRIT_FAIL:    c.hp_delta = -2
		PhrasePool.Tone.CURIOUS:
			match outcome:
				FateEngine.Outcome.CRIT_SUCCESS: c.stat_delta = 2; c.creature_flees = true
				FateEngine.Outcome.SUCCESS:      c.stat_delta = 1
				FateEngine.Outcome.MIXED:        pass
				FateEngine.Outcome.FAIL:         c.stat_delta = -1
				FateEngine.Outcome.CRIT_FAIL:    c.hp_delta = -1; c.mutate = true
	return c
