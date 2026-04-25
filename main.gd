extends Node3D
# Entry point: shows character creation, then starts the run.

@onready var stage: Node3D = $Stage
@onready var camera: Camera3D = $Camera3D
@onready var ui: CanvasLayer = $GameUI

var orchestrator: RunOrchestrator
var fate: FateEngine
var resolver: EventResolver
var director: SceneDirector
var backdrop: Backdrop3D
var decor: Decor3D
var creature_node: Creature3D
var boss_node: WorldBoss3D
var player_state: PlayerState
var _rng: DRNG
var _char_create_root: Node3D
var _started: bool = false

func _ready() -> void:
	_show_char_create()

func _show_char_create() -> void:
	ui.visible = false
	_char_create_root = preload("res://ui/char_create.tscn").instantiate()
	add_child(_char_create_root)
	_char_create_root.character_chosen.connect(_on_char_chosen)

func _on_char_chosen(name: String, kind: int, stats: Dictionary) -> void:
	player_state = PlayerState.new()
	player_state.setup(name, kind, stats)
	if _char_create_root and is_instance_valid(_char_create_root):
		_char_create_root.queue_free()
	ui.visible = true
	_start_game()

func _start_game() -> void:
	_started = true
	var seed := int(Time.get_unix_time_from_system())
	_rng = DRNG.new(seed ^ 0xCAFE)

	orchestrator = RunOrchestrator.new()
	add_child(orchestrator)
	orchestrator.start_run(seed)

	fate = FateEngine.new(DRNG.new(seed ^ 0xFA7E))
	resolver = EventResolver.new(fate)

	director = SceneDirector.new(orchestrator.world, resolver, _rng.derive(0xD12EC), player_state)
	add_child(director)

	_setup_camera()
	_build_stage_for_active_zone()

	ui.set_player(player_state)
	ui.update_zone(orchestrator.world.active_zone_index, orchestrator.world.active_zone().biome)

	director.zone_intro.connect(_on_zone_intro)
	director.encounter_presented.connect(_on_encounter)
	director.narrative_logged.connect(_on_narrative)
	director.creature_reaction.connect(_on_creature_reaction)
	director.stats_changed.connect(_on_stats)
	director.run_over.connect(_on_run_over)
	director.world_boss_spawned.connect(_on_world_boss)
	ui.choice_selected.connect(_on_choice)
	Bus.zone_changed.connect(_on_zone_changed)

	director.begin()

func _setup_camera() -> void:
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 50.0
	camera.position = Vector3(0, 2.2, 6.0)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)

func _build_stage_for_active_zone() -> void:
	for child in stage.get_children(): child.queue_free()
	var z := orchestrator.world.active_zone()
	backdrop = Backdrop3D.new()
	stage.add_child(backdrop)
	backdrop.build(z.biome, z.corruption)
	decor = Decor3D.new()
	stage.add_child(decor)
	decor.build(z.biome, z.corruption, _rng.derive(z.index + 100))
	if z.dragon_id != &"":
		_dragon_flyby(z.dragon_id, z.dragon_intro)

func _dragon_flyby(id: StringName, intro: String) -> void:
	var dragon := Dragon3D.new()
	stage.add_child(dragon)
	dragon.build(id)
	dragon.position = Vector3(-22, 7, -8)
	dragon.scale = Vector3.ONE * 0.85
	if intro != "":
		ui.present_intro(intro)
	var t := create_tween().set_parallel(true)
	t.tween_property(dragon, "position", Vector3(22, 9, -10), 6.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(dragon, "rotation:y", -0.4, 6.0)
	# Auto-cleanup
	get_tree().create_timer(6.5).timeout.connect(func():
		if is_instance_valid(dragon): dragon.queue_free())

func _spawn_creature(arch: Archetype) -> void:
	if boss_node and is_instance_valid(boss_node):
		boss_node.queue_free()
		boss_node = null
		_setup_camera()
	if creature_node and is_instance_valid(creature_node):
		creature_node.queue_free()
	creature_node = Creature3D.new()
	creature_node.position = Vector3(0, 0, 0)
	stage.add_child(creature_node)
	creature_node.build(arch)
	creature_node.scale = Vector3.ZERO
	var t := create_tween()
	t.tween_property(creature_node, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_zone_intro(text: String, _biome: StringName) -> void:
	ui.present_intro(text)

func _on_encounter(enc) -> void:
	if enc is SituationEncounter:
		if creature_node and is_instance_valid(creature_node):
			creature_node.queue_free()
			creature_node = null
		ui.present_intro(String(enc.template.title))
		ui.present_encounter(enc)
	else:
		_spawn_creature(enc.creature.archetype)
		ui.present_encounter(enc)

func _on_narrative(text: String, tone: int, outcome: int) -> void:
	ui.show_narrative(text, tone, outcome)

func _on_creature_reaction(reaction: StringName) -> void:
	if creature_node and is_instance_valid(creature_node):
		creature_node.react(reaction)

func _on_stats(force: int, injuries: Array) -> void:
	ui.update_stats(force, injuries)

func _on_choice(idx: int) -> void:
	director.choose(idx)

func _on_run_over(cause: StringName) -> void:
	ui.show_run_over(cause)

func _on_zone_changed(idx: int, _seed: int) -> void:
	ui.update_zone(idx, orchestrator.world.zones[idx].biome)
	_build_stage_for_active_zone()

func _on_world_boss(boss: Dictionary) -> void:
	if creature_node and is_instance_valid(creature_node):
		creature_node.queue_free()
		creature_node = null
	if boss_node and is_instance_valid(boss_node):
		boss_node.queue_free()
	boss_node = WorldBoss3D.new()
	boss_node.position = Vector3(0, 0, -2)
	stage.add_child(boss_node)
	boss_node.build(StringName(boss.id))
	boss_node.scale = Vector3.ZERO
	# Cinematic: camera pulls back, boss scales up.
	var t := create_tween().set_parallel(true)
	t.tween_property(boss_node, "scale", Vector3.ONE, 1.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(camera, "position", Vector3(0, 4.5, 12.0), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "fov", 60.0, 1.8)
	# Slow rotate around boss for awe
	var spin := create_tween().set_loops()
	spin.tween_property(boss_node, "rotation:y", TAU, 30.0)
