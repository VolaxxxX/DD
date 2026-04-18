class_name Creature extends Node3D
# Runtime creature instance. Pairs archetype + FSM + rendering.

var id: int
var archetype: Archetype
var fsm := AIFSM.new()
var rng: DRNG
var alive: bool = true
var view: Sprite3D

func setup(_id: int, _arch: Archetype, _rng: DRNG, pos: Vector3) -> void:
	id = _id
	archetype = _arch
	rng = _rng
	position = pos
	_build_view()
	Bus.entity_spawned.emit(id, archetype.id, pos)

func _build_view() -> void:
	view = Sprite3D.new()
	view.texture = _placeholder_texture()
	view.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	view.pixel_size = 0.02
	view.modulate = _tier_color()
	view.position = Vector3(0, 0.5, 0)
	add_child(view)

func _placeholder_texture() -> Texture2D:
	var img := Image.create(16, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)

func _tier_color() -> Color:
	match archetype.tier:
		Archetype.Tier.COMMON:   return Color(0.85, 0.85, 0.85)
		Archetype.Tier.UNCOMMON: return Color(0.6, 1.0, 0.6)
		Archetype.Tier.RARE:     return Color(0.4, 0.7, 1.0)
		Archetype.Tier.ELITE:    return Color(0.9, 0.4, 1.0)
		Archetype.Tier.APEX:     return Color(1.0, 0.5, 0.2)
		_:                       return Color(1.0, 0.2, 0.2)

func ai_tick(ctx: Dictionary) -> void:
	if not alive: return
	var prev := fsm.state
	fsm.tick(self, ctx)
	if fsm.state != prev:
		Bus.entity_state_changed.emit(id, fsm.state)
	_move_by_state(ctx)

func _move_by_state(ctx: Dictionary) -> void:
	var step := 0.3
	match fsm.state:
		AIFSM.S.HUNT:
			var tgt: Vector3 = ctx.get("target_pos", position)
			position = position.move_toward(tgt, step)
		AIFSM.S.FLEE:
			var tgt2: Vector3 = ctx.get("target_pos", position)
			var dir := (position - tgt2).normalized()
			position += dir * step
		AIFSM.S.IDLE:
			position.x += (rng.range_i(-10, 11)) * 0.01
			position.z += (rng.range_i(-10, 11)) * 0.01
		_:
			pass

func apply_mutation() -> void:
	if archetype.mutation_pool.is_empty(): return
	var trait_id: StringName = archetype.mutation_pool[rng.range_i(0, archetype.mutation_pool.size())]
	archetype.aggression = mini(100, archetype.aggression + 15)
	archetype.tier = mini(Archetype.Tier.MYTHIC, archetype.tier + 1)
	archetype.id = StringName("%s+%s" % [archetype.id, trait_id])
	if view: view.modulate = _tier_color()

func kill() -> void:
	if not alive: return
	alive = false
	Bus.entity_died.emit(id)
	queue_free()
