extends Node3D
# Entry point. Wires together run, world, player, camera, and HUD.

@onready var camera: Camera3D = $Camera3D
@onready var hud: CanvasLayer = $HUD

var orchestrator: RunOrchestrator
var fate: FateEngine
var resolver: EventResolver
var player: Player
var sim_timer: Timer
var _zone_views: Dictionary = {}

func _ready() -> void:
	var seed := int(Time.get_unix_time_from_system())
	orchestrator = RunOrchestrator.new()
	add_child(orchestrator)
	orchestrator.start_run(seed)

	fate = FateEngine.new(DRNG.new(seed ^ 0xFA7E))
	resolver = EventResolver.new(fate)

	_build_zone_views()
	_spawn_player()
	_setup_camera()
	_start_sim_ticker()

	Bus.zone_changed.connect(_on_zone_changed)

func _build_zone_views() -> void:
	for z in orchestrator.world.zones:
		var v := ZoneView.new()
		v.position = Vector3(z.index * 200.0, 0, 0)
		add_child(v)
		v.build(z)
		z.position = Vector3(z.index * 200.0, 0, 0)
		_zone_views[z.index] = v

func _spawn_player() -> void:
	player = Player.new()
	add_child(player)
	player.setup(1, resolver)
	player.position = orchestrator.world.active_zone().position + Vector3(0, 0, 0)

func _setup_camera() -> void:
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 24.0
	camera.rotation_degrees = Vector3(-55, -45, 0)
	camera.position = player.position + Vector3(14, 18, 14)

func _process(_delta: float) -> void:
	if player and camera:
		var target := player.position + Vector3(14, 18, 14)
		camera.position = camera.position.lerp(target, 0.12)

func _start_sim_ticker() -> void:
	sim_timer = Timer.new()
	sim_timer.wait_time = 0.25
	sim_timer.autostart = true
	sim_timer.timeout.connect(_sim_tick)
	add_child(sim_timer)

func _sim_tick() -> void:
	var z := orchestrator.world.active_zone()
	if z and z.ecosystem:
		z.ecosystem.tick(player.position)
	if Input.is_action_just_pressed("ui_page_down"):
		orchestrator.world.advance_zone()

func _on_zone_changed(idx: int, _seed: int) -> void:
	var z := orchestrator.world.zones[idx]
	player.position = z.position + Vector3(0, 0, 0)

func get_active_ecosystem() -> Ecosystem:
	var z := orchestrator.world.active_zone()
	return z.ecosystem if z else null
