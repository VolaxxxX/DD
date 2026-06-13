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
	# Safety: ensure no leftover slow-motion / camera lock if returning from a run.
	Engine.time_scale = 1.0
	_cam_hold = false
	ui.visible = false
	_clear_overlays()
	_menu_root = preload("res://ui/main_menu.tscn").instantiate()
	add_child(_menu_root)
	_menu_root.start_new_game.connect(_on_menu_new_game)
	_menu_root.continue_run.connect(_on_menu_continue)
	_menu_root.open_bestiary.connect(_on_menu_bestiary)
	_menu_root.open_settings.connect(_on_menu_settings)
	_menu_root.open_achievements.connect(_on_menu_achievements)
	Music.play_menu()

func _on_menu_settings() -> void:
	_open_panel(preload("res://ui/settings_panel.gd").new())

func _on_menu_achievements() -> void:
	_open_panel(preload("res://ui/achievements_panel.gd").new())

func _open_panel(panel: Control) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 75
	add_child(layer)
	layer.add_child(panel)
	panel.closed.connect(func():
		if is_instance_valid(layer): layer.queue_free())

func _on_menu_continue() -> void:
	var s := Save.load_run()
	if s.is_empty():
		_on_menu_new_game()
		return
	_clear_overlays()
	players.clear()
	for d in s.players:
		var p := PlayerState.new()
		p.setup(String(d.name), int(d.class_kind), d.stats)
		p.injuries = (d.injuries as Array).duplicate()
		p.alive = bool(d.alive)
		players.append(p)
	player_state = players[0]
	ui.visible = true
	_start_game_with_saved_seed(int(s.seed), int(s.zone_index))

func _start_game_with_saved_seed(seed: int, zone_index: int) -> void:
	_started = true
	_rng = DRNG.new(seed ^ 0xCAFE)
	orchestrator = RunOrchestrator.new()
	add_child(orchestrator)
	orchestrator.start_run(seed)
	fate = FateEngine.new(DRNG.new(seed ^ 0xFA7E))
	resolver = EventResolver.new(fate)
	director = SceneDirector.new(orchestrator.world, resolver, _rng.derive(0xD12EC), players)
	add_child(director)
	director.turn_changed.connect(func(p: PlayerState): ui.set_player(p))
	# Fast-forward to the saved zone.
	while orchestrator.world.active_zone_index < zone_index and orchestrator.world.active_zone_index < orchestrator.world.zones.size() - 1:
		orchestrator.world.advance_zone()
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
	director.stat_changed_for_player.connect(_on_player_stat_change)
	director.healed.connect(_on_player_heal)
	director.injury_added.connect(_on_player_injury)
	director.second_chance_triggered.connect(_on_second_chance)
	director.first_encounter.connect(_on_first_encounter)
	director.encounter_progress.connect(func(c: int, t: int): ui.update_encounter_progress(c, t))
	director.village_offered.connect(_on_village_offered)
	director.relic_acquired.connect(_on_relic_acquired)
	director.path_offered.connect(_on_path_offered)
	director.final_duel.connect(_on_final_duel)
	ui.choice_selected.connect(_on_choice)
	Bus.zone_changed.connect(_on_zone_changed)
	director.begin()

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
		Progress.record_class_played(int(d.kind))
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
	director.stat_changed_for_player.connect(_on_player_stat_change)
	director.healed.connect(_on_player_heal)
	director.injury_added.connect(_on_player_injury)
	director.second_chance_triggered.connect(_on_second_chance)
	director.first_encounter.connect(_on_first_encounter)
	director.encounter_progress.connect(func(c: int, t: int): ui.update_encounter_progress(c, t))
	director.village_offered.connect(_on_village_offered)
	director.relic_acquired.connect(_on_relic_acquired)
	director.path_offered.connect(_on_path_offered)
	director.final_duel.connect(_on_final_duel)
	ui.choice_selected.connect(_on_choice)
	if not ui.pause_requested.is_connected(_open_pause_menu):
		ui.pause_requested.connect(_open_pause_menu)
	Bus.zone_changed.connect(_on_zone_changed)

	Progress.record_run_start()
	director.begin()

func _open_pause_menu() -> void:
	var pm: Control = preload("res://ui/pause_menu.gd").new()
	var layer := CanvasLayer.new(); layer.layer = 95
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer); layer.add_child(pm)
	pm.resumed.connect(func():
		if is_instance_valid(layer): layer.queue_free())
	pm.quit_to_menu.connect(func():
		if is_instance_valid(layer): layer.queue_free()
		_show_main_menu())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _started:
		_open_pause_menu()
	# Hold a finger / mouse button on the 3D area to orbit the camera around the
	# encounter focal point — release to glide back to the rest pose.
	if event is InputEventScreenTouch:
		var t: InputEventScreenTouch = event
		if t.pressed: _start_orbit(t.position)
		else: _end_orbit()
	elif event is InputEventScreenDrag:
		var d: InputEventScreenDrag = event
		_apply_orbit_delta(d.relative)
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed: _start_orbit(mb.position)
			else: _end_orbit()
	elif event is InputEventMouseMotion and _orbit_active:
		_apply_orbit_delta((event as InputEventMouseMotion).relative)

var _orbit_active: bool = false
var _orbit_yaw: float = 0.0       # radians
var _orbit_pitch: float = 0.0     # radians
var _orbit_radius: float = 6.4
var _orbit_return_tween: Tween

func _start_orbit(screen_pos: Vector2) -> void:
	# Ignore taps on the choice buttons / HUD top bar — only treat presses on
	# the 3D viewport (anywhere below the top bar and above the choices) as
	# orbit gestures.
	var vp_size := get_viewport().get_visible_rect().size
	if screen_pos.y < 110: return                                   # HUD top
	if screen_pos.y > vp_size.y - 220: return                       # choices
	if _orbit_return_tween and _orbit_return_tween.is_valid():
		_orbit_return_tween.kill()
	_orbit_active = true

func _end_orbit() -> void:
	if not _orbit_active: return
	_orbit_active = false
	# Glide back to the rest pose so the encounter framing stays consistent.
	if _orbit_return_tween and _orbit_return_tween.is_valid():
		_orbit_return_tween.kill()
	_orbit_return_tween = create_tween().set_parallel(true)
	_orbit_return_tween.tween_property(self, "_orbit_yaw", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_orbit_return_tween.tween_property(self, "_orbit_pitch", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _apply_orbit_delta(rel: Vector2) -> void:
	if not _orbit_active: return
	_orbit_yaw -= rel.x * 0.006
	_orbit_pitch = clampf(_orbit_pitch - rel.y * 0.004, -0.6, 0.9)
	# Wrap yaw so it never explodes.
	_orbit_yaw = wrapf(_orbit_yaw, -PI, PI)

# Run finale: the dragon that haunted this run lands to bar the way out.
func _on_final_duel(dragon_id: StringName) -> void:
	if creature_node and is_instance_valid(creature_node):
		creature_node.queue_free()
		creature_node = null
	if situation_node and is_instance_valid(situation_node):
		situation_node.queue_free()
		situation_node = null
	_reset_camera_if_boss()
	var dragon := Dragon3D.new()
	dragon.position = Vector3(0.8, 0, -2.5)
	dragon.scale = Vector3.ONE * 1.15
	dragon.rotation_degrees.y = 15.0
	stage.add_child(dragon)
	dragon.build(dragon_id)
	# Landed entrance: drops from the sky with a quake.
	dragon.position.y = 9.0
	var t := dragon.create_tween()
	t.tween_property(dragon, "position:y", 0.0, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(func():
		_shake_camera(0.5, 1.2)
		_light_burst(Color(1.0, 0.6, 0.3), 9.0, 1.0)
		for off in [Vector3(-1.5, 0.3, 0.8), Vector3(1.5, 0.3, 0.8)]:
			CombatVFX.dust_puff(stage, dragon.position + off, Color(0.75, 0.68, 0.55)))
	Audio.play(&"dragon")
	Audio.play(&"boss")
	Music.play_boss(&"prismatic_ascendant")
	_darken_environment(0.35, 1.5)
	# Track it like a boss so the camera idle loop yields during the duel.
	boss_node = null
	_final_dragon = dragon

var _final_dragon: Dragon3D = null

# Path choice between zones: two doors with visible biome + stakes.
func _on_path_offered(options: Array) -> void:
	var layer := CanvasLayer.new(); layer.layer = 85
	add_child(layer)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size = Vector2(560, 0)
	panel.add_child(v)
	var title := Label.new()
	title.text = Lang.t({"fr": "Deux chemins s'ouvrent devant toi.",
		"en": "Two paths open before you.",
		"id": "Dua jalan terbuka di depanmu."})
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	for i in options.size():
		var opt: Dictionary = options[i]
		var biome_name: String = String(opt.biome).to_upper()
		var desc: String
		if String(opt.kind) == "safe":
			desc = Lang.t({"fr": "Voie sûre — épreuves plus douces, fragments réduits",
				"en": "Safe route — gentler trials, fewer fragments",
				"id": "Jalur aman — ujian lebih ringan, fragmen berkurang"})
		else:
			desc = Lang.t({"fr": "Voie périlleuse — épreuves rudes, fragments x1.6",
				"en": "Perilous route — harsh trials, fragments x1.6",
				"id": "Jalur berbahaya — ujian berat, fragmen x1.6"})
		var btn := Button.new()
		btn.text = "🚪  %s\n%s" % [biome_name, desc]
		btn.custom_minimum_size = Vector2(0, 72)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var idx := i
		btn.pressed.connect(func():
			Audio.play(&"click")
			if is_instance_valid(layer): layer.queue_free()
			director.choose_path(idx))
		v.add_child(btn)

func _on_village_offered(player: PlayerState) -> void:
	Progress.record_village_visit()
	Music.play_menu()  # peaceful theme for the village pause
	var panel: Control = preload("res://ui/village_hub.gd").new()
	panel.setup(player)
	var layer := CanvasLayer.new(); layer.layer = 85
	add_child(layer); layer.add_child(panel)
	panel.continue_journey.connect(func():
		if is_instance_valid(layer): layer.queue_free()
		director.resume_after_village())

func _setup_camera() -> void:
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 50.0
	camera.position = Vector3(0, 2.2, 6.0)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)

var _breath_time: float = 0.0
var _cam_hold: bool = false   # true while a cinematic owns the camera

func _process(delta: float) -> void:
	if camera == null or boss_node != null or _cam_hold: return
	_breath_time += delta
	# Multi-frequency idle drift — closer to a hand-held cinematic camera,
	# not a metronome.
	var off_y := sin(_breath_time * 0.55) * 0.035 + sin(_breath_time * 1.7) * 0.012
	var off_x := sin(_breath_time * 0.37) * 0.028 + sin(_breath_time * 1.3 + 1.7) * 0.014
	# Orbital component: rotate around the focal point (0, 1, 0) at radius
	# _orbit_radius.  Yaw 0 / pitch 0 puts the camera back at its rest pose.
	var focal := Vector3(0, 1.0, 0)
	var cy := cos(_orbit_pitch)
	var orbit_offset := Vector3(
		sin(_orbit_yaw) * cy,
		sin(_orbit_pitch),
		cos(_orbit_yaw) * cy
	) * _orbit_radius
	var rest_pos := focal + Vector3(0, 1.2, 0) + orbit_offset    # base pose lifted 1.2 m
	var pos := rest_pos + Vector3(off_x + _shake_offset.x, off_y + _shake_offset.y, _shake_offset.z)
	camera.position = pos
	camera.look_at(focal, Vector3.UP)
	if _shake_t > 0.0:
		_shake_t = maxf(0.0, _shake_t - delta / _shake_dur)
		var k := _shake_t * _shake_t
		_shake_offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * (_shake_amp * k)
	else:
		_shake_offset = Vector3.ZERO

var _shake_t: float = 0.0
var _shake_dur: float = 0.4
var _shake_amp: float = 0.0
var _shake_offset: Vector3 = Vector3.ZERO

func _shake_camera(amp: float, dur: float) -> void:
	_shake_amp = amp
	_shake_dur = dur
	_shake_t = 1.0

func _slowmo(scale: float, duration: float) -> void:
	Engine.time_scale = scale
	get_tree().create_timer(duration * scale, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0)

func _light_burst(color: Color, energy: float, duration: float) -> void:
	# A short-lived OmniLight3D at the encounter focal point that fades.
	# Creates the "lightning strike" feel on crits without baked light maps.
	if stage == null: return
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 14.0
	light.position = Vector3(0, 1.6, 0)
	stage.add_child(light)
	var t := light.create_tween()
	t.tween_property(light, "light_energy", energy, 0.06)
	t.tween_property(light, "light_energy", 0.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_callback(func():
		if is_instance_valid(light): light.queue_free())

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
	backdrop.build(z.biome, z.corruption, z.sub_biome)
	decor = Decor3D.new()
	stage.add_child(decor)
	decor.build(z.biome, z.corruption, _rng.derive(z.index + 100), z.sub_biome)
	_rebuild_player_avatars()
	Music.play_biome(z.biome)
	Audio.set_ambient_biome(z.biome)
	if z.dragon_id != &"":
		_dragon_flyby(z.dragon_id, z.dragon_intro)

var avatar_nodes: Array = []   # Player3D, one per player

func _rebuild_player_avatars() -> void:
	for a in avatar_nodes:
		if is_instance_valid(a): a.queue_free()
	avatar_nodes.clear()
	for i in players.size():
		var av := Player3D.new()
		# Solo: stand off-center to the left so the creature is visible in the
		# right half of the frame. Duo: flanks on either side, narrower spread.
		var x := -2.4 if i == 0 else 2.4
		if players.size() == 1: x = -2.2
		av.position = Vector3(x, 0, 2.8)
		av.scale = Vector3.ONE * 0.85
		av.rotation_degrees.y = 25.0 if i == 0 else -25.0
		stage.add_child(av)
		av.build(players[i].class_data)
		av.apply_injuries(players[i].injuries)
		avatar_nodes.append(av)
	_rebuild_companion()

var companion: Companion3D = null
var _companion_introduced: bool = false

func _rebuild_companion() -> void:
	# The spirit-fox companion: hovers near player 1, reacts to every roll AND
	# carries the "Flair" mechanic — it sniffs out the safest choice each
	# encounter (the marker is computed from hidden margins in game_ui).
	if companion and is_instance_valid(companion): companion.queue_free()
	companion = Companion3D.new()
	stage.add_child(companion)
	var seed_v: int = (_rng.derive(0xC0A1).range_i(0, 9999)) if _rng != null else 7
	companion.build(seed_v)
	companion.set_home(Vector3(-3.4, 0, 2.4))
	if not _companion_introduced:
		_companion_introduced = true
		Toast.info("%s %s — %s" % [
			Lang.t({"fr": "✨ Compagnon :", "en": "✨ Companion:", "id": "✨ Teman:"}),
			companion.companion_name,
			Lang.t({"fr": "son flair 🐾 marque le choix le plus sûr",
				"en": "its instinct 🐾 marks the safest choice",
				"id": "nalurinya 🐾 menandai pilihan teraman"})])

func _refresh_avatars_injuries() -> void:
	for i in players.size():
		if i < avatar_nodes.size() and is_instance_valid(avatar_nodes[i]):
			avatar_nodes[i].apply_injuries(players[i].injuries)

func _dragon_flyby(id: StringName, intro: String) -> void:
	Progress.record_dragon(id)
	var dragon := Dragon3D.new()
	stage.add_child(dragon)
	dragon.build(id)
	# Closer, larger, slightly banked — it should OWN the sky for those seconds.
	dragon.position = Vector3(-30, 9, -7)
	dragon.scale = Vector3.ONE * 1.35
	dragon.rotation_degrees.z = -6.0
	if intro != "":
		ui.present_intro(intro)
	Audio.play(&"dragon")
	var t := create_tween().set_parallel(true)
	t.tween_property(dragon, "position", Vector3(30, 11, -9), 7.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(dragon, "rotation:y", -0.45, 7.5)
	# Mid-pass: the closest point. Roar again, shake the ground, flash the sky.
	get_tree().create_timer(3.4).timeout.connect(func():
		if not is_instance_valid(dragon): return
		Audio.play(&"dragon", 0.85)
		_shake_camera(0.22, 0.9)
		_light_burst(Color(1.0, 0.85, 0.60), 3.5, 1.0))
	# Auto-cleanup
	get_tree().create_timer(8.2).timeout.connect(func():
		if is_instance_valid(dragon): dragon.queue_free())

func _spawn_creature(arch: Archetype) -> void:
	_reset_camera_if_boss()
	if creature_node and is_instance_valid(creature_node):
		creature_node.queue_free()
	creature_node = Creature3D.new()
	# Sit slightly to the right of dead center and forward of the decor zone so
	# the silhouette reads clearly against the backdrop.
	creature_node.position = Vector3(0.6, 0.0, -0.5)
	stage.add_child(creature_node)
	creature_node.build(arch)
	_focal_spotlight(creature_node.position + Vector3(0, 1.0, 0))
	Cinematic.play_for_creature(arch.id, int(arch.tier), creature_node, camera, get_tree(), int(arch.family))
	# Turn each player avatar to look at the creature.
	for a in avatar_nodes:
		if is_instance_valid(a):
			a.look_at(creature_node.position + Vector3(0, 1.0, 0), Vector3.UP)
			# look_at faces -Z; flip so character looks forward.
			a.rotation.y += PI

func _on_zone_intro(text: String, _biome: StringName) -> void:
	ui.present_intro(text)

var situation_node: Situation3D
var _encounter_counter: int = 0

func _on_encounter(enc) -> void:
	# Show the tutorial overlay on the very first encounter ever played.
	var tut := preload("res://ui/tutorial_overlay.gd")
	if tut.should_show():
		var layer := CanvasLayer.new()
		layer.layer = 80
		add_child(layer)
		var overlay: Control = tut.new()
		layer.add_child(overlay)
		overlay.tree_exited.connect(func():
			if is_instance_valid(layer): layer.queue_free())
	# Multi-phase duel (world boss / finale dragon): the colossus visual is
	# already on stage — do NOT clear it, spawn creatures or reset the camera.
	# The phase title arrives separately via zone_intro.
	if enc is DuelEncounter:
		ui.present_encounter(enc)
		return
	_encounter_counter += 1
	# Per-encounter ear refresh: small pitch nudge on the active music track.
	Music.nudge_for_encounter(_encounter_counter)
	# Per-encounter visual refresh: shift the sun a bit so the scene feels alive.
	_nudge_environment(_encounter_counter)
	# Decor evolution inside the same zone: props drift, fresh ambience motes.
	if _encounter_counter > 1 and decor and is_instance_valid(decor):
		decor.evolve(_encounter_counter)
	if situation_node and is_instance_valid(situation_node):
		situation_node.queue_free()
		situation_node = null
	if enc is SituationEncounter:
		if creature_node and is_instance_valid(creature_node):
			creature_node.queue_free()
			creature_node = null
		_reset_camera_if_boss()
		situation_node = Situation3D.new()
		situation_node.position = Vector3(0.4, 0, -0.5)
		stage.add_child(situation_node)
		situation_node.build(StringName(enc.template.id))
		_focal_spotlight(situation_node.position + Vector3(0, 1.0, 0))
		Cinematic.play_for_situation(StringName(enc.template.id), situation_node, camera, get_tree())
		ui.present_intro(String(enc.template.title))
		ui.present_encounter(enc)
	else:
		_spawn_creature(enc.creature.archetype)
		# Tactical mood line: derived from the creature's REAL stats, so she
		# can read at a glance whether talking, tricking or fleeing has a shot.
		# Scene description (what's happening) + name + tactical mood, all in
		# the dark narrative box so she reads the situation before choosing.
		var opening := PhrasePool.encounter_opening(_rng.derive(_encounter_counter), int(enc.creature.archetype.family), enc.zone.biome)
		ui.present_intro("%s\n%s\n%s" % [enc.creature_name, opening, _mood_line(enc.creature.archetype)])
		ui.present_encounter(enc)

func _mood_line(a: Archetype) -> String:
	var tags: Array[String] = []
	if a.aggression >= 70:
		tags.append(Lang.t({"fr": "⚔ agressif", "en": "⚔ aggressive", "id": "⚔ agresif"}))
	elif a.aggression <= 30:
		tags.append(Lang.t({"fr": "🕊 placide", "en": "🕊 placid", "id": "🕊 tenang"}))
	if a.intelligence >= 70:
		tags.append(Lang.t({"fr": "🧠 rusé — la parole peut porter", "en": "🧠 cunning — words may land", "id": "🧠 cerdik — kata-kata bisa berhasil"}))
	elif a.intelligence < 30:
		tags.append(Lang.t({"fr": "🐾 bestial — inutile de parler", "en": "🐾 feral — talking is useless", "id": "🐾 buas — bicara sia-sia"}))
	if int(a.tier) >= 3:
		tags.append(Lang.t({"fr": "☠ redoutable", "en": "☠ fearsome", "id": "☠ menakutkan"}))
	# Karma: the family's memory of you this run.
	if director != null:
		var k: Dictionary = director.karma_info(int(a.family))
		if int(k.kills) >= 3:
			tags.append(Lang.t({"fr": "🩸 il connaît ton odeur de tueur",
				"en": "🩸 it knows your killer's scent",
				"id": "🩸 ia mengenali bau pembunuhmu"}))
		elif int(k.spared) >= 2 and int(k.kills) == 0:
			tags.append(Lang.t({"fr": "🕊 ta clémence te précède",
				"en": "🕊 your mercy precedes you",
				"id": "🕊 belas kasihmu mendahuluimu"}))
	return " · ".join(tags)

func _reset_camera_if_boss() -> void:
	if boss_node and is_instance_valid(boss_node):
		boss_node.queue_free()
	boss_node = null
	if camera.position != Vector3(0, 2.2, 6.0) or camera.fov != 50.0:
		Cinematic.reset_camera(camera)

func _on_narrative(text: String, tone: int, outcome: int) -> void:
	# If a relic actively boosted this roll, surface its icon next to the narration.
	var prefix := ""
	if director != null and director.current is Encounter:
		var enc: Encounter = director.current as Encounter
		var p: PlayerState = director.player
		for rid in p.relics:
			var ctx := {
				"tone": tone, "stat": PlayerClass.tone_stat(tone),
				"family": int(enc.creature.archetype.family),
				"biome": enc.zone.biome,
				"dragon_present": enc.zone.dragon_id != &"",
			}
			if RelicRegistry.bonus_for(rid, ctx) > 0:
				var r: Dictionary = RelicRegistry.by_id(rid)
				prefix += String(r.get("icon", "✦")) + " "
	if prefix != "":
		ui.show_narrative(prefix + text, tone, outcome)
	else:
		ui.show_narrative(text, tone, outcome)
	if companion and is_instance_valid(companion):
		companion.react(outcome)
	_play_outcome_vfx(tone, outcome)

func _play_outcome_vfx(tone: int, outcome: int) -> void:
	# Slow-motion + camera shake + light burst on extreme outcomes.
	match outcome:
		0:  # CRIT_FAIL
			_slowmo(0.35, 0.6)
			_shake_camera(0.30, 0.4)
			_light_burst(Color(1.0, 0.20, 0.20), 6.0, 0.6)
		4:  # CRIT_SUCCESS
			_slowmo(0.45, 0.5)
			_light_burst(Color(1.0, 0.95, 0.55), 7.0, 0.7)
	if creature_node == null or not is_instance_valid(creature_node): return
	var pos: Vector3 = creature_node.position + Vector3(0, 1.0, 0)
	match outcome:
		0:  # CRIT_FAIL - the player suffers
			CombatVFX.blood_spray(stage, Vector3(0, 1.2, 2.0))
		1:  # FAIL
			CombatVFX.dust_puff(stage, pos)
		2:  # MIXED
			CombatVFX.dust_puff(stage, pos)
			CombatVFX.sparks(stage, pos, Color(1.0, 0.7, 0.3))
		3:  # SUCCESS
			match tone:
				0: CombatVFX.sparks(stage, pos)
				1, 4: CombatVFX.dust_puff(stage, pos, Color(0.8, 0.9, 1.0))
				2: CombatVFX.dust_puff(stage, pos)
				3: CombatVFX.radiant_flash(stage, pos)
				5: CombatVFX.void_implode(stage, pos)
		4:  # CRIT_SUCCESS
			match tone:
				0:    CombatVFX.blood_spray(stage, pos); CombatVFX.sparks(stage, pos)
				5:    CombatVFX.void_implode(stage, pos); CombatVFX.radiant_flash(stage, pos)
				_:    CombatVFX.radiant_flash(stage, pos)

func _on_creature_reaction(reaction: StringName) -> void:
	if creature_node and is_instance_valid(creature_node):
		creature_node.react(reaction)
	if reaction == &"die":
		_kills_this_run += 1
		# Death burst + light + particles for a satisfying kill moment.
		if creature_node and is_instance_valid(creature_node):
			var pos: Vector3 = creature_node.position + Vector3(0, 1.0, 0)
			_light_burst(Color(1.0, 0.85, 0.55), 5.0, 0.55)
			CombatVFX.dust_puff(stage, pos, Color(0.95, 0.85, 0.60))

func _on_stats(force: int, injuries: Array, relics: Array = []) -> void:
	ui.update_stats(force, injuries, relics)
	_refresh_avatars_injuries()

func _on_choice(idx: int) -> void:
	# Nudge the camera according to the picked tone, for tactile feedback,
	# and play a matching body action on the acting player's avatar.
	if director.current != null and idx < director.current.choices.size():
		var tone: int = int(director.current.choices[idx].tone)
		Cinematic.nudge_for_tone(camera, tone)
		var act_idx: int = director.active_idx
		if act_idx >= 0 and act_idx < avatar_nodes.size() and is_instance_valid(avatar_nodes[act_idx]):
			avatar_nodes[act_idx].act_tone(tone)
	director.choose(idx)

func _on_run_over(cause: StringName) -> void:
	Audio.play(&"death")
	# Dramatic cinematic: slow camera fall + zoom + fade to black.
	var cause_s := String(cause)
	var extracted := cause_s.contains("extrait") or cause_s.contains("extracted") or cause_s.contains("keluar")
	_play_death_cinematic(extracted)
	# Track stats and achievements.
	var any_inj := false
	var duo_both := players.size() >= 2
	for p in players:
		if p.injuries.size() > 0: any_inj = true
		if not p.alive: duo_both = false
	Progress.record_zone_depth(orchestrator.world.active_zone_index if orchestrator else 0)
	Progress.record_run_end(extracted, any_inj, duo_both)
	if _world_boss_seen_this_run:
		Progress.record_titan_survived()
	Progress.record_language(Lang.code)
	ui.show_run_over(cause)
	# Run summary panel after the cinematic settles.
	get_tree().create_timer(4.5, true, false, true).timeout.connect(_show_run_summary.bind(String(cause)))

func _play_death_cinematic(extracted: bool) -> void:
	_cam_hold = true   # released on return to menu (_show_main_menu)
	Engine.time_scale = 0.55
	# Camera tween: pull back, slight rise for extraction, slight fall for death.
	var target_pos := Vector3(0, 4.5, 9.0) if extracted else Vector3(0, 1.4, 7.5)
	var target_fov := 38.0
	var t := camera.create_tween().set_parallel(true)
	t.tween_property(camera, "position", target_pos, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "fov", target_fov, 2.0)
	# Title flash.
	Cinematic._flash_screen(get_tree(),
		Color(1, 0.95, 0.65, 0.35) if extracted else Color(0.05, 0.05, 0.10, 0.65),
		1.2)
	get_tree().create_timer(2.2, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0)

func _show_run_summary(cause: String) -> void:
	var panel := preload("res://ui/run_summary.gd").new()
	panel.setup(
		(orchestrator.world.active_zone_index + 1) if orchestrator else 0,
		_kills_this_run,
		Progress.run_duration_seconds(),
		_new_discoveries_this_run,
		cause)
	var layer := CanvasLayer.new(); layer.layer = 90
	add_child(layer); layer.add_child(panel)
	panel.closed.connect(func():
		if is_instance_valid(layer): layer.queue_free()
		_show_main_menu()
		_new_discoveries_this_run = 0
		_kills_this_run = 0)

var _world_boss_seen_this_run: bool = false
var _new_discoveries_this_run: int = 0
var _kills_this_run: int = 0

func _on_player_stat_change(stat_key: StringName, delta: int, player_idx: int) -> void:
	var pos := _avatar_world_pos(player_idx) + Vector3(0, 1.6, 0)
	var col := Color(0.4, 1.0, 0.4) if delta > 0 else Color(1.0, 0.5, 0.4)
	var sign := "+" if delta > 0 else ""
	FloatingText.spawn(stage, pos, "%s%d %s" % [sign, delta, String(stat_key).to_upper()], col, 0.6)

func _on_player_heal(injury_id: StringName, player_idx: int) -> void:
	var pos := _avatar_world_pos(player_idx) + Vector3(0, 1.6, 0)
	FloatingText.spawn(stage, pos, "+ %s" % Lang.ui("heal"), Color(0.6, 1.0, 0.7), 0.5)
	_flash_avatar(player_idx, Color(0.55, 1.0, 0.55))

func _on_second_chance() -> void:
	# Dramatic moment: full white flash + slow-mo + sound + caption.
	Cinematic._flash_screen(get_tree(), Color(1, 1, 0.85, 0.95), 1.2)
	Audio.play(&"crit")
	_slowmo(0.2, 1.2)
	_shake_camera(0.40, 0.6)
	var pos := _avatar_world_pos(director.active_idx) + Vector3(0, 2.0, 0)
	FloatingText.spawn(stage, pos, "✦ " + Lang.ui("second_chance"), Color(1, 0.95, 0.65), 0.85)

func _on_relic_acquired(relic_id: StringName, player_idx: int) -> void:
	var r: Dictionary = RelicRegistry.by_id(relic_id)
	var icon: String = String(r.get("icon", "✦"))
	var rname: String = Lang.t(r.get("name", {}))
	var pos := _avatar_world_pos(player_idx) + Vector3(0, 1.8, 0)
	FloatingText.spawn(stage, pos, "%s  %s" % [icon, rname], Color(1, 0.85, 0.30), 0.85)
	Cinematic._flash_screen(get_tree(), Color(1, 0.85, 0.30, 0.35), 0.4)
	Audio.play(&"crit")
	if player_idx < players.size():
		Progress.check_relic_hoarder(players[player_idx].relics.size())

func _on_first_encounter(creature_id: StringName, name: String) -> void:
	# Tint the screen briefly + reveal the creature's name with extra emphasis.
	Cinematic._flash_screen(get_tree(), Color(0.55, 0.85, 1.0, 0.45), 0.5)
	Audio.play(&"intro")
	ui.present_intro("◇ %s\n%s" % [Lang.ui("first_encounter"), name])
	_new_discoveries_this_run += 1

func _on_creature_killed_for_summary() -> void:
	_kills_this_run += 1

func _on_player_injury(injury_id: StringName) -> void:
	var pos := _avatar_world_pos(director.active_idx) + Vector3(0, 1.6, 0)
	var inj: Dictionary = InjuryRegistry.by_id(injury_id)
	var fallback := Lang.t({"fr": "BLESSÉ", "en": "WOUNDED", "id": "TERLUKA"})
	var name: String = String(inj.get("name", fallback)) if not inj.is_empty() else fallback
	FloatingText.spawn(stage, pos, "− %s" % name, Color(1.0, 0.45, 0.35), 0.55)
	_shake_camera(0.18, 0.3)
	_flash_avatar(director.active_idx, Color(1.0, 0.30, 0.30))

func _flash_avatar(idx: int, color: Color) -> void:
	if idx >= avatar_nodes.size(): return
	var a = avatar_nodes[idx]
	if not is_instance_valid(a): return
	a.flash(color, 0.35)

func _avatar_world_pos(player_idx: int) -> Vector3:
	if player_idx >= 0 and player_idx < avatar_nodes.size() and is_instance_valid(avatar_nodes[player_idx]):
		return avatar_nodes[player_idx].global_position
	return Vector3.ZERO

func _on_zone_changed(idx: int, _seed: int) -> void:
	# Smooth fade-out, swap stage, fade-in — like Hollow Knight's room cuts.
	_encounter_counter = 0
	ui.update_zone(idx, orchestrator.world.zones[idx].biome)
	var layer := CanvasLayer.new(); layer.layer = 70
	add_child(layer)
	var fade := ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.color = Color(0, 0, 0, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade)
	var t := fade.create_tween()
	t.tween_property(fade, "color", Color(0, 0, 0, 1), 0.4)
	t.tween_callback(_build_stage_for_active_zone)
	t.tween_property(fade, "color", Color(0, 0, 0, 0), 0.6)
	t.tween_callback(func():
		if is_instance_valid(layer): layer.queue_free())

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
	Audio.play(&"boss")
	Music.play_boss(StringName(boss.id))
	Progress.record_boss(StringName(boss.id))
	_world_boss_seen_this_run = true
	_darken_environment(0.35, 1.5)
	Cinematic.play_world_boss(StringName(boss.id), boss_node, camera, get_tree())
	# Ground impact when the grow-in lands (1.8s entrance tween): quake +
	# dust ring + light burst — the world acknowledges the titan's weight.
	get_tree().create_timer(1.8).timeout.connect(func():
		if boss_node == null or not is_instance_valid(boss_node): return
		_shake_camera(0.45, 1.1)
		_light_burst(Color(1.0, 0.75, 0.45), 8.0, 0.9)
		for off in [Vector3(-2.0, 0.3, 0.5), Vector3(2.0, 0.3, 0.5), Vector3(0, 0.3, 1.5)]:
			CombatVFX.dust_puff(stage, boss_node.position + off, Color(0.75, 0.68, 0.55)))

var _focal_light: OmniLight3D

func _focal_spotlight(at: Vector3) -> void:
	# Soft warm rim that pops the creature out of the backdrop. Lives until the
	# next creature spawn or zone change (it's parented to `stage`).
	if _focal_light and is_instance_valid(_focal_light):
		_focal_light.queue_free()
	_focal_light = OmniLight3D.new()
	_focal_light.position = at + Vector3(0, 1.5, 1.5)
	_focal_light.light_color = Color(1.0, 0.92, 0.78)
	_focal_light.light_energy = 2.2
	_focal_light.omni_range = 6.0
	_focal_light.omni_attenuation = 1.2
	stage.add_child(_focal_light)

func _nudge_environment(encounter_idx: int) -> void:
	# Tiny per-encounter shift in sun rotation + warmth + fill intensity.  Keeps
	# the backdrop from looking identical between sequential fights in the same
	# zone, without rebuilding any geometry.
	if backdrop == null: return
	var sun = backdrop.get("sun")
	if sun and is_instance_valid(sun) and sun is DirectionalLight3D:
		var dl: DirectionalLight3D = sun
		var base_rot := dl.rotation_degrees
		var delta := Vector3(
			sin(float(encounter_idx) * 0.7) * 6.0,
			cos(float(encounter_idx) * 0.5) * 10.0,
			sin(float(encounter_idx) * 0.3) * 4.0)
		var t := dl.create_tween()
		t.tween_property(dl, "rotation_degrees", base_rot + delta, 1.8).set_trans(Tween.TRANS_SINE)
		# Quick warmth flicker so the scene feels recomposed.
		var base_col := dl.light_color
		var warm := Color(base_col.r * 1.08, base_col.g, base_col.b * 0.94)
		var tc := dl.create_tween()
		tc.tween_property(dl, "light_color", warm, 0.6)
		tc.tween_property(dl, "light_color", base_col, 1.2)

func _darken_environment(target_energy: float, duration: float) -> void:
	# Drop directional + fill light energy on the active backdrop so the boss
	# stands out via its own glow lights.
	if backdrop == null: return
	for prop in ["sun", "fill"]:
		var n = backdrop.get(prop)
		if n and is_instance_valid(n) and n is DirectionalLight3D:
			var t: Tween = n.create_tween()
			t.tween_property(n, "light_energy", target_energy, duration).set_trans(Tween.TRANS_SINE)
