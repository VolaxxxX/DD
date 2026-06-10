class_name SceneDirector extends Node
# Orchestrates the encounter flow with class-aware player + injury system.

signal encounter_presented(encounter)
signal narrative_logged(text: String, tone: int, outcome: int)
signal zone_intro(text: String, biome: StringName)
signal creature_reaction(reaction: StringName)
signal stats_changed(force: int, injuries: Array)
signal injury_added(injury_id: StringName)
signal world_boss_spawned(boss: Dictionary)
signal run_over(cause: StringName)

const ENCOUNTERS_PER_ZONE := 4

var world: WorldEngine
var resolver: EventResolver
var rng: DRNG
var player: PlayerState
var current: Encounter
var _encounters_in_zone: int = 0
var _awaiting_choice: bool = false
var _elite_kills_this_run: int = 0
var _world_boss_triggered: bool = false

func _init(_world: WorldEngine, _resolver: EventResolver, _rng: DRNG, _player: PlayerState) -> void:
	world = _world
	resolver = _resolver
	rng = _rng
	player = _player

func begin() -> void:
	_emit_zone_intro()
	await _wait(1.5)
	next_encounter()

func _emit_zone_intro() -> void:
	var z := world.active_zone()
	zone_intro.emit(PhrasePool.biome_intro(z.biome, z.corruption), z.biome)

func next_encounter() -> void:
	if _encounters_in_zone >= ENCOUNTERS_PER_ZONE:
		_advance_zone()
		return
	var z := world.active_zone()
	var er := rng.derive(_encounters_in_zone + 1)
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
	_awaiting_choice = true
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
	var result: Dictionary = current.resolve(idx, resolver, 0)
	narrative_logged.emit(result.narrative, result.tone, result.outcome)
	_apply(result)
	if not player.alive:
		run_over.emit(StringName("tué par %s" % current.creature_name))
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
	var inj_id: StringName = result.get("injury", &"")
	if inj_id != &"":
		if player.add_injury(inj_id):
			injury_added.emit(inj_id)
	var heal_id: StringName = result.get("heal", &"")
	if heal_id != &"" and heal_id in player.injuries:
		player.injuries.erase(heal_id)
	if bool(result.get("fatal", false)):
		player.alive = false
	var has_creature: bool = current.creature != null
	if has_creature and result.get("creature_dies", false):
		creature_reaction.emit(&"die")
		if int(current.creature.archetype.tier) >= Archetype.Tier.ELITE:
			_elite_kills_this_run += 1
		current.creature.kill()
	elif has_creature and result.get("creature_flees", false):
		creature_reaction.emit(&"flee")
		current.creature.kill()
	elif has_creature and result.get("mutate", false):
		creature_reaction.emit(&"mutate")
		current.creature.apply_mutation()
	elif has_creature:
		creature_reaction.emit(&"hit")
	stats_changed.emit(player.effective_force(), player.injuries.duplicate())

func _advance_zone() -> void:
	_encounters_in_zone = 0
	var next_idx := world.active_zone_index + 1
	if next_idx >= world.zones.size():
		run_over.emit(&"extrait")
		return
	world.advance_zone()
	_maybe_trigger_world_boss()
	_emit_zone_intro()
	await _wait(2.0)
	next_encounter()

func _maybe_trigger_world_boss() -> void:
	if _world_boss_triggered: return
	if world.active_zone_index != world.zones.size() - 1: return
	var boss: Dictionary = WorldBossSystem.maybe_trigger(world.memory, world.active_zone(), _elite_kills_this_run, rng.derive(0x80551))
	if boss.is_empty(): return
	_world_boss_triggered = true
	world_boss_spawned.emit(boss)
	zone_intro.emit("[%s]\n%s" % [String(boss.title).to_upper(), String(boss.intro)], world.active_zone().biome)

func _wait(seconds: float) -> void:
	await Engine.get_main_loop().create_timer(seconds).timeout
