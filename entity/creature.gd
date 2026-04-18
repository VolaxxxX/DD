class_name Creature extends Node3D
# Runtime creature instance. Pairs archetype + FSM.
# Visual representation is built separately by render/creature_3d.gd.

var id: int
var archetype: Archetype
var fsm := AIFSM.new()
var rng: DRNG
var alive: bool = true

func setup(_id: int, _arch: Archetype, _rng: DRNG, pos: Vector3) -> void:
	id = _id
	archetype = _arch
	rng = _rng
	position = pos
	Bus.entity_spawned.emit(id, archetype.id, pos)

func ai_tick(ctx: Dictionary) -> void:
	if not alive: return
	var prev := fsm.state
	fsm.tick(self, ctx)
	if fsm.state != prev:
		Bus.entity_state_changed.emit(id, fsm.state)

func apply_mutation() -> void:
	if archetype.mutation_pool.is_empty(): return
	var trait_id: StringName = archetype.mutation_pool[rng.range_i(0, archetype.mutation_pool.size())]
	archetype.aggression = mini(100, archetype.aggression + 15)
	archetype.tier = mini(Archetype.Tier.MYTHIC, archetype.tier + 1)
	archetype.id = StringName("%s+%s" % [archetype.id, trait_id])

func kill() -> void:
	if not alive: return
	alive = false
	Bus.entity_died.emit(id)
