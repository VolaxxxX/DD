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
# Per-family run karma injected by the director: {"kills": int, "spared": int}.
var karma: Dictionary = {"kills": 0, "spared": 0}
# Multi-hit: tough creatures can't be ended in one exchange. They need several
# resolving blows/words across rounds. Set from tier at construction.
var max_hits: int = 1
var hits_taken: int = 0

func _init(_zone: Zone, _creature: Creature, _rng: DRNG, _player: PlayerState) -> void:
	zone = _zone
	creature = _creature
	rng = _rng
	player = _player
	creature_name = _resolve_name()
	# Tougher tiers take more than one resolving exchange to put down/turn away.
	match int(creature.archetype.tier):
		Archetype.Tier.ELITE:  max_hits = 2
		Archetype.Tier.APEX:   max_hits = 3
		Archetype.Tier.MYTHIC: max_hits = 4
		_:                     max_hits = 1
	choices = _build_choices()

func _resolve_name() -> String:
	if creature.archetype.id != &"":
		var named := CreatureRegistry.name_for_id(creature.archetype.id)
		# name_for_id falls back to a localized "the entity" sentinel when the
		# id is unknown — treat any of the three as "no real name".
		if not (named in ["l'entité", "the entity", "sang entitas"]): return named
	return PhrasePool.family_descriptor(creature.archetype.family, creature.archetype.tier)

func _build_choices() -> Array[Dictionary]:
	var tones: Array[int] = []
	var fam := creature.archetype.family
	# A creature can be reasoned with only if its FAMILY can speak/parley
	# (or its intel is high enough to be an exception, like the Old Wood Stag).
	# Beasts, Elementals, Constructs are not speakers regardless of intel.
	var speaks: bool = (fam == Archetype.Family.HUMANOID
		or fam == Archetype.Family.UNDEAD
		or fam == Archetype.Family.FEY
		or fam == Archetype.Family.DRACONIC
		or (fam == Archetype.Family.ABERRATION and creature.archetype.intelligence >= 70)
		or creature.archetype.intelligence >= 85)        # apex exception
	tones.append(PhrasePool.Tone.AGGRESSIVE)
	if speaks and creature.archetype.intelligence >= 40:
		tones.append(PhrasePool.Tone.DIPLOMATIC)
	tones.append(PhrasePool.Tone.CAUTIOUS)
	# CURIOUS available everywhere — observing is always possible.
	tones.append(PhrasePool.Tone.CURIOUS)
	if speaks and creature.archetype.intelligence >= 30:
		tones.append(PhrasePool.Tone.DECEPTIVE)
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

	# Context-aware texts: variants specific to the creature's family, the
	# zone's biome and its tier, deduplicated across the three buttons.
	var used: Array = []
	for t in allowed:
		var txt := PhrasePool.pick_choice(rng, t, int(fam), zone.biome, int(creature.archetype.tier), used)
		used.append(txt)
		out.append({
			"tone": t,
			"text": txt,
			"kind": _tone_to_kind(t),
		})
	# Fourth choice: WILD — strange, off-script. No stat rolled; rolls on a
	# pure chaos table when picked. Always present.
	out.append({
		"tone": PhrasePool.Tone.WILD,
		"text": PhrasePool.pick_wild_choice(rng),
		"kind": EventResolver.Kind.ANOMALY,
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
	# WILD: pure chaos table, ignores stats and tone-stat. Anything can happen.
	if tone == PhrasePool.Tone.WILD:
		return _resolve_wild()
	var difficulty: int = 10 + creature.archetype.aggression / 10 + int(zone.chaos * 5)
	var world_mod: int = -int(zone.corruption * 3)
	difficulty += BiomeRules.tone_difficulty_mod(zone.biome, tone)
	# Route taken into this zone (safe door eases rolls, risky door hardens).
	difficulty += zone.route_diff_mod
	# Karma: families remember. A known killer faces tighter guards and
	# closed ears; consistent mercy opens doors for words.
	if int(karma.kills) >= 3:
		difficulty += 2
		if tone == PhrasePool.Tone.DIPLOMATIC: difficulty += 1
	elif int(karma.spared) >= 2 and int(karma.kills) == 0:
		if tone == PhrasePool.Tone.DIPLOMATIC or tone == PhrasePool.Tone.DECEPTIVE:
			difficulty -= 2
	# Story mode: globally gentler rolls for relaxed sessions.
	if Settings.story_mode:
		difficulty -= 2
	# Onboarding: first zone is gentler so the player can learn the system.
	if zone.index == 0:
		difficulty -= 3
	var stat_key: StringName = PlayerClass.tone_stat(tone)
	var actor_stat: int = player.roll_stat_for_tone(tone) + BiomeRules.stat_mod(zone.biome, stat_key)
	# Apply relic bonuses for this roll context.
	actor_stat += player.relic_bonus({
		"tone": tone, "stat": stat_key, "family": int(creature.archetype.family),
		"biome": zone.biome, "dragon_present": zone.dragon_id != &"",
	})
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
	# Multi-hit gate: if this exchange WOULD end a tough creature (kill or turn
	# away) but it still has resolve left, downgrade it to a stagger — the
	# creature stays and the fight continues for another round.
	var would_end: bool = bool(cons.get("creature_dies", false)) or bool(cons.get("creature_flees", false))
	if would_end and max_hits > 1 and hits_taken + 1 < max_hits:
		hits_taken += 1
		cons["creature_dies"] = false
		cons["creature_flees"] = false
		cons["creature_staggered"] = true
		cons["hits_taken"] = hits_taken
		cons["hits_max"] = max_hits
		cons["narrative"] = "%s\n%s" % [narrative, _stagger_line(hits_taken, max_hits)]
		# Fresh choices for the next round (so the wording varies).
		choices = _build_choices()
		return cons
	# Trigger followup dialogue on diplomatic/mystical success vs smart creature.
	if creature.archetype.intelligence >= 70 and outcome >= FateEngine.Outcome.SUCCESS:
		if tone == PhrasePool.Tone.DIPLOMATIC or tone == PhrasePool.Tone.MYSTICAL:
			cons["creature_flees"] = false  # keep creature on stage for the conversation
			followup_choices = _build_followup_choices()
			has_followup = true
			cons["has_followup"] = true
	return cons

# Short "it's still standing" line shown when a tough creature is staggered.
func _stagger_line(taken: int, total: int) -> String:
	var left := total - taken
	var dots := ""
	for i in total: dots += "◆" if i < taken else "◇"
	var tail: Dictionary
	if left <= 1:
		tail = {"fr": "Il vacille — encore un assaut et il tombe.",
			"en": "It reels — one more blow and it falls.",
			"id": "Ia terhuyung — satu serangan lagi dan ia tumbang."}
	else:
		tail = {"fr": "Ce n'est pas suffisant. Il tient encore debout.",
			"en": "Not enough. It is still standing.",
			"id": "Belum cukup. Ia masih berdiri."}
	return "%s  [%s]" % [Lang.t(tail), dots]

func _followup_pool() -> Array:
	match Lang.code:
		"en": return [
			{"text": "You ask for its name.",
			 "narr_good": "%s gives it to you. It is not a human name. You will keep it.",
			 "narr_bad":  "%s does not answer. The moment passes.",
			 "stat": &"esprit"},
			{"text": "You ask what it fears.",
			 "narr_good": "%s tells you what it fears. It is useful. It is terrible.",
			 "narr_bad":  "%s laughs. It fears nothing you could understand.",
			 "stat": &"instinct"},
			{"text": "You ask what lies beyond these lands.",
			 "narr_good": "%s tells you the road. Now you know where not to go.",
			 "narr_bad":  "%s tells you the truth. You would rather not have known.",
			 "stat": &"esprit"},
			{"text": "You ask what you are becoming.",
			 "narr_good": "%s looks at you a long time. Then it tells you. You did not know.",
			 "narr_bad":  "%s tells you. You would rather not have asked.",
			 "stat": &"instinct"},
			{"text": "You ask for a favor.",
			 "narr_good": "%s accepts. Something in you mends. You will not forget.",
			 "narr_bad":  "%s laughs softly. You have nothing left to offer in exchange.",
			 "stat": &"charisme",
			 "heal_chance": true},
			{"text": "You ask the question you have carried since your first zone.",
			 "narr_good": "%s answers. The world makes a little sense now.",
			 "narr_bad":  "%s does not understand you. Or will not.",
			 "stat": &"esprit"},
		]
		"id": return [
			{"text": "Kau menanyakan namanya.",
			 "narr_good": "%s memberikannya padamu. Itu bukan nama manusia. Kau akan menyimpannya.",
			 "narr_bad":  "%s tak menjawab. Saat itu berlalu.",
			 "stat": &"esprit"},
			{"text": "Kau bertanya apa yang ia takuti.",
			 "narr_good": "%s memberitahumu apa yang ia takuti. Itu berguna. Itu mengerikan.",
			 "narr_bad":  "%s tertawa. Ia tak takut pada apa pun yang bisa kau pahami.",
			 "stat": &"instinct"},
			{"text": "Kau bertanya apa yang ada setelah tanah ini.",
			 "narr_good": "%s menceritakan jalannya. Kini kau tahu ke mana tak boleh pergi.",
			 "narr_bad":  "%s mengatakan yang sebenarnya. Kau lebih suka tak pernah tahu.",
			 "stat": &"esprit"},
			{"text": "Kau bertanya, kau ini sedang menjadi apa.",
			 "narr_good": "%s menatapmu lama. Lalu ia memberitahumu. Kau tak pernah tahu.",
			 "narr_bad":  "%s memberitahumu. Kau lebih suka tak pernah bertanya.",
			 "stat": &"instinct"},
			{"text": "Kau meminta satu kebaikan.",
			 "narr_good": "%s menerima. Sesuatu dalam dirimu pulih. Kau takkan lupa.",
			 "narr_bad":  "%s tertawa pelan. Kau tak punya apa-apa lagi untuk ditukar.",
			 "stat": &"charisme",
			 "heal_chance": true},
			{"text": "Kau mengajukan pertanyaan yang kau bawa sejak zona pertamamu.",
			 "narr_good": "%s menjawab. Dunia sedikit masuk akal sekarang.",
			 "narr_bad":  "%s tak memahamimu. Atau tak mau.",
			 "stat": &"esprit"},
		]
	return [
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

func _build_followup_choices() -> Array[Dictionary]:
	# Three short conversational openings the creature is now willing to discuss.
	var pool: Array = _followup_pool()
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
			# A failed roll: even if you did NOT attack, a HOSTILE creature can
			# still lunge and wound you — only a placid one lets you off (it just
			# leaves). The creature's aggression (shown by its mood tag) decides.
			var hostile := tone == PhrasePool.Tone.AGGRESSIVE or creature.archetype.aggression >= 45
			if hostile:
				c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
			else:
				c.creature_flees = true
			if tone == PhrasePool.Tone.CURIOUS: c.stat_delta = -1
		FateEngine.Outcome.CRIT_FAIL:
			# Catastrophe: you're wounded regardless. It's only FATAL if you
			# provoked the fight or the creature is genuinely deadly.
			c.mutate = (tone == PhrasePool.Tone.CURIOUS or tone == PhrasePool.Tone.MYSTICAL)
			c.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
			if tone == PhrasePool.Tone.AGGRESSIVE or creature.archetype.aggression >= 60:
				c.fatal = _roll_fatal(tone)
				# Second-chance: once per run, a fatal blow drops the player to
				# critical (TERROR + the injury) instead of killing them outright.
				if c.fatal and Progress.can_use_second_chance():
					Progress.consume_second_chance()
					c.fatal = false
					c["second_chance"] = true
					if not (&"terror" in player.injuries):
						c.injury = &"terror"
	return c

# Pure-chaos resolution for the WILD choice. Ignores stats, rolls on a flat
# outcome distribution, and adds occasional weird side-effects (relic gift,
# free heal, fragment bonus, creature flees, mutation, stat shift...) so the
# 4th choice always feels like a moment of strangeness.
func _resolve_wild() -> Dictionary:
	# Flat outcome distribution: 15/20/25/25/15 -> CF/F/MIX/S/CS
	var r := rng.range_i(0, 100)
	var outcome: int
	if r < 15:       outcome = FateEngine.Outcome.CRIT_FAIL
	elif r < 35:     outcome = FateEngine.Outcome.FAIL
	elif r < 60:     outcome = FateEngine.Outcome.MIXED
	elif r < 85:     outcome = FateEngine.Outcome.SUCCESS
	else:            outcome = FateEngine.Outcome.CRIT_SUCCESS
	# Story mode kindness: never wipe the player on a wild crit-fail.
	if Settings.story_mode and outcome == FateEngine.Outcome.CRIT_FAIL:
		outcome = FateEngine.Outcome.FAIL
	var c := {
		"stat_delta": 0,
		"creature_dies": false, "creature_flees": false, "mutate": false,
		"injury": &"", "heal": &"", "fatal": false,
		"narrative": PhrasePool.pick_wild_outcome(rng, outcome),
		"outcome": outcome,
		"tone": PhrasePool.Tone.WILD,
	}
	# Bonus weird side-effects, weighted by outcome.
	var weird := rng.range_i(0, 100)
	match outcome:
		FateEngine.Outcome.CRIT_SUCCESS:
			if weird < 60: c.creature_flees = true
			elif weird < 80: c["fragments"] = 6
			else: c["grant_relic"] = true
		FateEngine.Outcome.SUCCESS:
			if weird < 40: c.creature_flees = true
			elif weird < 70: c["fragments"] = 3
			elif weird < 85 and not player.injuries.is_empty():
				c.heal = player.injuries[rng.range_i(0, player.injuries.size())]
			else:
				c.stat_delta = 1
				c["stat"] = [&"instinct", &"esprit", &"charisme"][rng.range_i(0, 3)]
		FateEngine.Outcome.MIXED:
			if weird < 50:
				c.stat_delta = 1
				c["stat"] = [&"instinct", &"esprit"][rng.range_i(0, 2)]
				if not Settings.story_mode and rng.chance(40, 100):
					c.injury = InjuryRegistry.pick_for(rng, PhrasePool.Tone.MYSTICAL, zone.biome)
			else:
				c.mutate = true
		FateEngine.Outcome.FAIL:
			if weird < 50:
				c.injury = InjuryRegistry.pick_for(rng, PhrasePool.Tone.MYSTICAL, zone.biome)
			elif weird < 80:
				c["fragments"] = -2
			else:
				c.stat_delta = -1
				c["stat"] = [&"charisme", &"esprit"][rng.range_i(0, 2)]
		FateEngine.Outcome.CRIT_FAIL:
			c.injury = InjuryRegistry.pick_for(rng, PhrasePool.Tone.MYSTICAL, zone.biome)
			c.fatal = _roll_fatal(PhrasePool.Tone.MYSTICAL) and not Settings.story_mode
			# Second-chance still applies on a wild collapse.
			if c.fatal and Progress.can_use_second_chance():
				Progress.consume_second_chance()
				c.fatal = false
				c["second_chance"] = true
				if not (&"terror" in player.injuries):
					c.injury = &"terror"
	return c

func _roll_fatal(tone: int) -> bool:
	# Story mode: no permadeath from regular encounters — the run only ends
	# by extraction (injuries still stack and hurt).
	if Settings.story_mode: return false
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
