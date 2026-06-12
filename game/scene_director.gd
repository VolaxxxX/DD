class_name SceneDirector extends Node
# Orchestrates the encounter flow with class-aware player + injury system.

signal encounter_presented(encounter)
signal encounter_progress(current: int, total: int)
signal narrative_logged(text: String, tone: int, outcome: int)
signal zone_intro(text: String, biome: StringName)
signal creature_reaction(reaction: StringName)
signal stats_changed(force: int, injuries: Array, relics: Array)
signal injury_added(injury_id: StringName)
signal second_chance_triggered()
signal first_encounter(creature_id: StringName, name: String)
signal stat_changed_for_player(stat_key: StringName, delta: int, player_idx: int)
signal healed(injury_id: StringName, player_idx: int)
signal world_boss_spawned(boss: Dictionary)
signal village_offered(player: PlayerState)
signal relic_acquired(relic_id: StringName, player_idx: int)
signal path_offered(options: Array)
signal final_duel(dragon_id: StringName)
signal run_over(cause: StringName)

const ENCOUNTERS_PER_ZONE := 4

var world: WorldEngine
var resolver: EventResolver
var rng: DRNG
var players: Array = []          # Array[PlayerState] — 1 (solo) or 2 (duo)
var active_idx: int = 0
var current   # Encounter or SituationEncounter (duck-typed)
var _encounters_in_zone: int = 0
var _awaiting_choice: bool = false
var _elite_kills_this_run: int = 0
# Karma: per-family memory of this run. Kill a family often and its members
# meet you harder; consistently spare one and words open doors.
var _karma_kills: Dictionary = {}    # family int -> kills
var _karma_spared: Dictionary = {}   # family int -> spared via words/retreat
var _last_dragon_id: StringName = &""   # a dragon seen this run = finale duel
var _npc_done_this_zone: bool = false
var _pending_boss: Dictionary = {}
var _world_boss_triggered: bool = false

signal turn_changed(player: PlayerState)

var player: PlayerState:
	get: return players[active_idx]

func _init(_world: WorldEngine, _resolver: EventResolver, _rng: DRNG, _players: Array) -> void:
	world = _world
	resolver = _resolver
	rng = _rng
	players = _players

func _rotate_player() -> void:
	if players.size() < 2: return
	var tries := 0
	while tries < players.size():
		active_idx = (active_idx + 1) % players.size()
		if players[active_idx].alive: break
		tries += 1
	turn_changed.emit(player)

func _all_dead() -> bool:
	for p in players:
		if p.alive: return false
	return true

func begin() -> void:
	_emit_zone_intro()
	await _wait(1.5)
	next_encounter()

func _emit_zone_intro() -> void:
	var z := world.active_zone()
	if z.dragon_id != &"":
		_last_dragon_id = z.dragon_id
	var sub := PropLoader.sub_name(z.biome, z.sub_biome)
	var header: String = "%s — %s" % [String(z.biome).to_upper(), sub] if sub != "" else String(z.biome).to_upper()
	var txt := header + "\n" + PhrasePool.biome_intro(z.biome, z.corruption)
	var rule := BiomeRules.label(z.biome)
	if rule != "": txt += "\n" + rule
	zone_intro.emit(txt, z.biome)

func next_encounter() -> void:
	if _encounters_in_zone >= ENCOUNTERS_PER_ZONE:
		_advance_zone()
		return
	_rotate_player()
	var z := world.active_zone()
	var er := rng.derive(_encounters_in_zone + 1)
	# Biome NPC: each biome has a signature character with a spawn chance,
	# at most one meeting per zone. They remember you across runs.
	if not _npc_done_this_zone and _encounters_in_zone > 0:
		var npc: Dictionary = NPCRegistry.for_biome(z.biome)
		if not npc.is_empty() and er.range_i(0, 100) < int(npc.chance):
			_npc_done_this_zone = true
			var meetings: int = Progress.record_npc_meeting(StringName(npc.id))
			current = SituationEncounter.new(z, er, player, NPCRegistry.template(npc, meetings > 1))
			_awaiting_choice = true
			encounter_progress.emit(_encounters_in_zone + 1, ENCOUNTERS_PER_ZONE)
			encounter_presented.emit(current)
			return
	# 30% situation, 70% creature.
	var as_situation := er.range_i(0, 100) < 30 and _encounters_in_zone > 0
	if as_situation:
		var tpl: Dictionary = SituationRegistry.pick(er, z.biome)
		current = SituationEncounter.new(z, er, player, tpl)
	else:
		var alive: Array[Creature] = []
		for c in z.ecosystem.creatures:
			if c.alive: alive.append(c)
		if alive.is_empty():
			_advance_zone()
			return
		var pick: Creature = alive[er.range_i(0, alive.size())]
		current = Encounter.new(z, pick, er, player)
		var fam := int(pick.archetype.family)
		(current as Encounter).karma = {
			"kills": int(_karma_kills.get(fam, 0)),
			"spared": int(_karma_spared.get(fam, 0)),
		}
		if Progress.first_kill_of(pick.archetype.id):
			first_encounter.emit(pick.archetype.id, (current as Encounter).creature_name)
	_awaiting_choice = true
	encounter_progress.emit(_encounters_in_zone + 1, ENCOUNTERS_PER_ZONE)
	encounter_presented.emit(current)

func choose(idx: int) -> void:
	if not _awaiting_choice or current == null: return
	_awaiting_choice = false
	# Followup phase if the encounter is waiting on a 2nd dialogue round.
	if current is Encounter and (current as Encounter).has_followup:
		var enc := current as Encounter
		var result_fu: Dictionary = enc.resolve_followup(idx)
		narrative_logged.emit(result_fu.narrative, result_fu.tone, result_fu.outcome)
		_apply(result_fu)
		await _wait(2.5)
		_encounters_in_zone += 1
		next_encounter()
		return
	var coop_mod: int = 0
	if players.size() > 1 and not _all_dead():
		var both_alive := true
		for p in players:
			if not p.alive: both_alive = false
		if both_alive: coop_mod = 1
	var result: Dictionary = current.resolve(idx, resolver, coop_mod)
	if result.get("second_chance", false):
		second_chance_triggered.emit()
	narrative_logged.emit(result.narrative, result.tone, result.outcome)
	_apply(result)
	if not player.alive:
		if _all_dead():
			Save.clear()
			run_over.emit(StringName("%s %s" % [Lang.ui("killed_by"), current.creature_name]))
			return
		# Duo: the survivor carries on, marked by grief.
		for p in players:
			if p.alive: p.add_injury(&"terror")
		narrative_logged.emit(Lang.ui("grief"), 1, 1)
		await _wait(2.5)
		_encounters_in_zone += 1
		next_encounter()
		return
	# Multi-phase duel routing (world boss / finale dragon).
	if result.get("duel_phase_done", false) and current is DuelEncounter:
		var duel := current as DuelEncounter
		if not result.duel_finished:
			await _wait(2.6)
			zone_intro.emit("%s\n%s" % [duel.phase_title(), duel.creature_name], world.active_zone().biome)
			_awaiting_choice = true
			encounter_presented.emit(duel)
			return
		await _wait(2.6)
		_finish_duel(duel, bool(result.duel_victory))
		return
	# If encounter triggered a followup dialogue, present its choices instead of moving on.
	if result.get("has_followup", false) and current is Encounter:
		await _wait(2.0)
		_awaiting_choice = true
		var enc := current as Encounter
		enc.choices = enc.followup_choices
		encounter_presented.emit(enc)
		return
	await _wait(2.5)
	_encounters_in_zone += 1
	next_encounter()

func _apply(result: Dictionary) -> void:
	var stat_delta: int = int(result.get("stat_delta", 0))
	if stat_delta != 0:
		var stat_key: StringName = result.get("stat", &"force")
		player.stats[stat_key] = maxi(1, int(player.stats.get(stat_key, 8)) + stat_delta)
		stat_changed_for_player.emit(stat_key, stat_delta, active_idx)
	var inj_id: StringName = result.get("injury", &"")
	if inj_id != &"":
		if player.add_injury(inj_id):
			injury_added.emit(inj_id)
	var heal_id: StringName = result.get("heal", &"")
	if heal_id != &"" and heal_id in player.injuries:
		player.injuries.erase(heal_id)
		healed.emit(heal_id, active_idx)
	if bool(result.get("fatal", false)):
		player.alive = false
	# NPC trades: fragment gains/losses and relic gifts.
	var frag_delta: int = int(result.get("fragments", 0))
	if frag_delta != 0:
		Progress.fragments = maxi(0, Progress.fragments + frag_delta)
		Progress.save()
	if bool(result.get("grant_relic", false)):
		var gift: Dictionary = RelicRegistry.pick_random(rng)
		if player.add_relic(StringName(gift.id)):
			relic_acquired.emit(StringName(gift.id), active_idx)
	var has_creature: bool = current.creature != null
	if has_creature and result.get("creature_dies", false):
		var kfam := int(current.creature.archetype.family)
		_karma_kills[kfam] = int(_karma_kills.get(kfam, 0)) + 1
		creature_reaction.emit(&"die")
		Progress.record_kill(current.creature.archetype.id)
		var tier := int(current.creature.archetype.tier)
		if tier >= Archetype.Tier.ELITE:
			_elite_kills_this_run += 1
			Progress.record_elite_kill()
		# Relic drop: ELITE 30 %, APEX 60 %, MYTHIC 100 %.
		var drop_chance := 0
		if tier == Archetype.Tier.ELITE:    drop_chance = 30
		elif tier == Archetype.Tier.APEX:   drop_chance = 60
		elif tier == Archetype.Tier.MYTHIC: drop_chance = 100
		if drop_chance > 0 and rng.range_i(0, 100) < drop_chance:
			var relic: Dictionary = RelicRegistry.pick_random(rng)
			if player.add_relic(StringName(relic.id)):
				relic_acquired.emit(StringName(relic.id), active_idx)
		current.creature.kill()
	elif has_creature and result.get("creature_flees", false):
		# Sparing through words or restraint builds mercy karma with the family.
		var tone_used := int(result.get("tone", 0))
		if tone_used in [1, 2, 4] and int(result.get("outcome", 0)) >= FateEngine.Outcome.SUCCESS:
			var sfam := int(current.creature.archetype.family)
			_karma_spared[sfam] = int(_karma_spared.get(sfam, 0)) + 1
		creature_reaction.emit(&"flee")
		current.creature.kill()
	elif has_creature and result.get("mutate", false):
		creature_reaction.emit(&"mutate")
		current.creature.apply_mutation()
	elif has_creature:
		# If the player took an injury, the creature successfully attacked.
		var atk_inj: StringName = result.get("injury", &"")
		if atk_inj != &"":
			creature_reaction.emit(&"attack")
		else:
			creature_reaction.emit(&"hit")
	stats_changed.emit(player.effective_force(), player.injuries.duplicate(), player.relics.duplicate())

func _advance_zone() -> void:
	_encounters_in_zone = 0
	Progress.record_zone_cleared()
	# Apply Witch's Knot passive on every player who has it.
	for p in players:
		for rid in p.relics:
			var r: Dictionary = RelicRegistry.by_id(rid)
			if String(r.get("passive", "")) == "heal_on_zone" and p.injuries.size() > 0:
				var removed: StringName = p.injuries[0]
				p.injuries.remove_at(0)
				healed.emit(removed, players.find(p))
				break
	var next_idx := world.active_zone_index + 1
	if next_idx >= world.zones.size():
		# Run finale: only an EVIL dragon seen during this run descends to bar
		# the way out — good and beyond-aligned dragons let you leave in peace.
		# No dragon (or a benevolent one) = the classic quiet extraction, so
		# the finale stays an event, not a habit.
		if _last_dragon_id != &"":
			var dd: Dictionary = DragonRegistry.by_id(_last_dragon_id)
			if not dd.is_empty() and int(dd.get("align", 1)) == DragonRegistry.Align.EVIL:
				_awaiting_choice = false
				_start_final_duel()
				return
		Save.clear()
		run_over.emit(StringName(Lang.ui("extracted")))
		return
	# Apply a queued blessing (from the village storyteller) on entry.
	if Progress.next_zone_blessing != &"":
		for p in players:
			p.stats[Progress.next_zone_blessing] = int(p.stats.get(Progress.next_zone_blessing, 8)) + 2
		Progress.next_zone_blessing = &""
		Progress.save()
	# Village stop offered between zones (~35% chance after zone 0, always
	# after the 2nd cleared zone).  Guarantees player relief.
	var any_inj := false
	for p in players:
		if p.injuries.size() > 0: any_inj = true
	var should_village := (world.active_zone_index >= 1 and (rng.range_i(0, 100) < 35 or any_inj))
	if should_village:
		_awaiting_choice = false
		village_offered.emit(players[active_idx])
		return
	_offer_path()

func resume_after_village() -> void:
	# Called by main.gd when the village panel is closed.
	_offer_path()

# ---- Path choice: two doors into the next zone ----
# Safe route: the zone as generated, gentler rolls, fewer fragments.
# Risky route: an alternate biome, harder rolls, far richer fragments.
var _path_options: Array = []

func _offer_path() -> void:
	var next_idx := world.active_zone_index + 1
	if next_idx >= world.zones.size():
		_enter_next_zone()
		return
	var nz: Zone = world.zones[next_idx]
	var prng := rng.derive(0x9A7B + next_idx)
	var alt_biome: StringName = nz.biome
	var guard := 0
	while alt_biome == nz.biome and guard < 8:
		alt_biome = Zone.BIOMES[prng.range_i(0, Zone.BIOMES.size())]
		guard += 1
	_path_options = [
		{"biome": nz.biome, "kind": "safe", "diff": -1, "frag": 0.75},
		{"biome": alt_biome, "kind": "risky", "diff": 2, "frag": 1.6},
	]
	_awaiting_choice = false
	path_offered.emit(_path_options)

func choose_path(idx: int) -> void:
	if _path_options.is_empty(): return
	var opt: Dictionary = _path_options[clampi(idx, 0, _path_options.size() - 1)]
	_path_options = []
	var next_idx := world.active_zone_index + 1
	if next_idx < world.zones.size():
		var nz: Zone = world.zones[next_idx]
		nz.regenerate_as(StringName(opt.biome))
		nz.route_diff_mod = int(opt.diff)
		nz.route_fragment_scale = float(opt.frag)
	_enter_next_zone()

func _enter_next_zone() -> void:
	world.advance_zone()
	Save.save_run(players, world)
	Progress.fragment_scale = world.active_zone().route_fragment_scale if world.active_zone_index < world.zones.size() else 1.0
	_npc_done_this_zone = false
	if world.active_zone().dragon_id != &"":
		_last_dragon_id = world.active_zone().dragon_id
	if _maybe_trigger_world_boss():
		# The titan blocks the threshold: the zone starts with a 3-phase duel.
		await _wait(4.0)
		_start_boss_duel()
		return
	_emit_zone_intro()
	await _wait(2.0)
	next_encounter()

func _maybe_trigger_world_boss() -> bool:
	if _world_boss_triggered: return false
	if world.active_zone_index != world.zones.size() - 1: return false
	var boss: Dictionary = WorldBossSystem.maybe_trigger(world.memory, world.active_zone(), _elite_kills_this_run, rng.derive(0x80551))
	if boss.is_empty(): return false
	_world_boss_triggered = true
	_pending_boss = boss
	world_boss_spawned.emit(boss)
	zone_intro.emit("[%s]\n%s" % [WorldBossRegistry.title_of(boss).to_upper(), WorldBossRegistry.intro_of(boss)], world.active_zone().biome)
	return true

# ---- Multi-phase duels (world boss + dragon finale) ----

func _start_boss_duel() -> void:
	var duel := DuelEncounter.new(world.active_zone(), rng.derive(0xD0E1), player,
		&"boss", StringName(_pending_boss.id), WorldBossRegistry.name_of(_pending_boss))
	current = duel
	_awaiting_choice = true
	zone_intro.emit("%s\n%s" % [duel.phase_title(), duel.creature_name], world.active_zone().biome)
	encounter_presented.emit(duel)

func _start_final_duel() -> void:
	var d: Dictionary = DragonRegistry.by_id(_last_dragon_id)
	var dname := DragonRegistry.name_of(d) if not d.is_empty() else Lang.t({"fr": "le dragon", "en": "the dragon", "id": "sang naga"})
	final_duel.emit(_last_dragon_id)
	var duel := DuelEncounter.new(world.active_zone(), rng.derive(0xF17A), player,
		&"dragon", _last_dragon_id, dname)
	current = duel
	_awaiting_choice = true
	zone_intro.emit("%s\n%s" % [duel.phase_title(), dname], world.active_zone().biome)
	encounter_presented.emit(duel)

func _finish_duel(duel: DuelEncounter, victory: bool) -> void:
	if victory:
		narrative_logged.emit(duel.victory_text(), 0, 4)
		Progress.fragments += int(round(25 * Progress.fragment_scale))
		var relic: Dictionary = RelicRegistry.pick_random(rng)
		if player.add_relic(StringName(relic.id)):
			relic_acquired.emit(StringName(relic.id), active_idx)
		if duel.foe_kind == &"boss":
			Progress.record_titan_survived()
		Progress.save()
	else:
		narrative_logged.emit(duel.defeat_text(), 0, 1)
	stats_changed.emit(player.effective_force(), player.injuries.duplicate(), player.relics.duplicate())
	await _wait(3.2)
	if duel.foe_kind == &"dragon":
		# Finale: win or survive-diminished, the run concludes here.
		Save.clear()
		run_over.emit(StringName(Lang.ui("extracted")))
		return
	# Boss survived: the last zone now plays out normally — and the biome
	# theme returns in place of the battle music.
	Music.play_biome(world.active_zone().biome)
	_emit_zone_intro()
	await _wait(2.0)
	next_encounter()

func karma_info(family: int) -> Dictionary:
	return {"kills": int(_karma_kills.get(family, 0)), "spared": int(_karma_spared.get(family, 0))}

func _wait(seconds: float) -> void:
	await Engine.get_main_loop().create_timer(seconds).timeout
