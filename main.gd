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
var players: Array = []
var _rng: DRNG
var _char_create_root: Node3D
var _started: bool = false

var _menu_root: Node3D
var _bestiary_root: Node3D

func _ready() -> void:
	_show_main_menu()

func _show_main_menu() -> void:
	ui.visible = false
	_clear_overlays()
	_menu_root = preload("res://ui/main_menu.tscn").instantiate()
	add_child(_menu_root)
	_menu_root.start_new_game.connect(_on_menu_new_game)
	_menu_root.open_bestiary.connect(_on_menu_bestiary)

func _on_menu_new_game() -> void:
	_clear_overlays()
	_show_char_create()

func _on_menu_bestiary() -> void:
	_clear_overlays()
	_bestiary_root = preload("res://ui/bestiary.tscn").instantiate()
	add_child(_bestiary_root)
	_bestiary_root.back_pressed.connect(func(): _show_main_menu())

func _clear_overlays() -> void:
	for n in [_menu_root, _bestiary_root, _char_create_root]:
		if n and is_instance_valid(n): n.queue_free()
	_menu_root = null
	_bestiary_root = null
	_char_create_root = null

func _show_char_create() -> void:
	ui.visible = false
	_char_create_root = preload("res://ui/char_create.tscn").instantiate()
	add_child(_char_create_root)
	_char_create_root.characters_ready.connect(_on_characters_ready)

func _on_characters_ready(player_defs: Array) -> void:
	players.clear()
	for d in player_defs:
		var p := PlayerState.new()
		p.setup(String(d.name), int(d.kind), d.stats)
		players.append(p)
	player_state = players[0]
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

	director = SceneDirector.new(orchestrator.world, resolver, _rng.derive(0xD12EC), players)
	add_child(director)
	director.turn_changed.connect(func(p: PlayerState): ui.set_player(p))

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
	boss_node = null
	creature_node = null
	situation_node = null
	_setup_camera()
	camera.fov = 50.0
	var z := orchestrator.world.active_zone()
	backdrop = Backdrop3D.new()
	stage.add_child(backdrop)
	backdrop.build(z.biome, z.corruption)
	decor = Decor3D.new()
	stage.add_child(decor)
	decor.build(z.biome, z.corruption, _rng.derive(z.index + 100))
	_rebuild_player_avatars()
	if z.dragon_id != &"":
		_dragon_flyby(z.dragon_id, z.dragon_intro)

var avatar_nodes: Array = []   # Player3D, one per player

func _rebuild_player_avatars() -> void:
	for a in avatar_nodes:
		if is_instance_valid(a): a.queue_free()
	avatar_nodes.clear()
	for i in players.size():
		var av := Player3D.new()
		var x := -3.6 if i == 0 else 3.6
		av.position = Vector3(x, 0, 1.2)
		av.scale = Vector3.ONE * 0.85
		av.rotation_degrees.y = 25.0 if i == 0 else -25.0
		stage.add_child(av)
		av.build(players[i].class_data)
		av.apply_injuries(players[i].injuries)
		avatar_nodes.append(av)

func _refresh_avatars_injuries() -> void:
	for i in players.size():
		if i < avatar_nodes.size() and is_instance_valid(avatar_nodes[i]):
			avatar_nodes[i].apply_injuries(players[i].injuries)

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
	_reset_camera_if_boss()
	if creature_node and is_instance_valid(creature_node):
		creature_node.queue_free()
	creature_node = Creature3D.new()
	creature_node.position = Vector3(0, 0, 0)
	stage.add_child(creature_node)
	creature_node.build(arch)
	Cinematic.play_for_creature(arch.id, int(arch.tier), creature_node, camera, get_tree())

func _on_zone_intro(text: String, _biome: StringName) -> void:
	ui.present_intro(text)

var situation_node: Situation3D

func _on_encounter(enc) -> void:
	if situation_node and is_instance_valid(situation_node):
		situation_node.queue_free()
		situation_node = null
	if enc is SituationEncounter:
		if creature_node and is_instance_valid(creature_node):
			creature_node.queue_free()
			creature_node = null
		_reset_camera_if_boss()
		situation_node = Situation3D.new()
		stage.add_child(situation_node)
		situation_node.build(StringName(enc.template.id))
		situation_node.scale = Vector3.ZERO
		var t := create_tween()
		t.tween_property(situation_node, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		ui.present_intro(String(enc.template.title))
		ui.present_encounter(enc)
	else:
		_spawn_creature(enc.creature.archetype)
		ui.present_encounter(enc)

func _reset_camera_if_boss() -> void:
	if boss_node and is_instance_valid(boss_node):
		boss_node.queue_free()
	boss_node = null
	if camera.position != Vector3(0, 2.2, 6.0) or camera.fov != 50.0:
		Cinematic.reset_camera(camera)

func _on_narrative(text: String, tone: int, outcome: int) -> void:
	ui.show_narrative(text, tone, outcome)

func _on_creature_reaction(reaction: StringName) -> void:
	if creature_node and is_instance_valid(creature_node):
		creature_node.react(reaction)

func _on_stats(force: int, injuries: Array) -> void:
	ui.update_stats(force, injuries)
	_refresh_avatars_injuries()

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
	if situation_node and is_instance_valid(situation_node):
		situation_node.queue_free()
		situation_node = null
	if boss_node and is_instance_valid(boss_node):
		boss_node.queue_free()
	boss_node = WorldBoss3D.new()
	boss_node.position = Vector3(0, 0, -2)
	stage.add_child(boss_node)
	boss_node.build(StringName(boss.id))
	Cinematic.play_world_boss(StringName(boss.id), boss_node, camera, get_tree())
