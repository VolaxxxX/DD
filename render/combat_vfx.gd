class_name CombatVFX extends RefCounted
# Burst particles emitted on combat outcomes. Self-cleaning.

static func sparks(parent: Node3D, position: Vector3, color: Color = Color(1.0, 0.85, 0.45)) -> void:
	var p := _make_burst(parent, position, 24, 0.4, color, Vector3(0, 1, 0), 70.0, Vector3(0, -1.5, 0), 0.04, 4.0)
	_autofree(p, 0.7)

static func blood_spray(parent: Node3D, position: Vector3) -> void:
	var p := _make_burst(parent, position, 30, 0.6, Color(0.65, 0.05, 0.05), Vector3(0, 1, 0), 80.0, Vector3(0, -3.0, 0), 0.05, 0.0)
	_autofree(p, 0.9)

static func dust_puff(parent: Node3D, position: Vector3, color: Color = Color(0.6, 0.55, 0.45)) -> void:
	var p := _make_burst(parent, position, 18, 0.6, color, Vector3(0, 1, 0), 90.0, Vector3(0, -0.4, 0), 0.10, 0.6)
	_autofree(p, 1.0)

static func radiant_flash(parent: Node3D, position: Vector3) -> void:
	var p := _make_burst(parent, position, 40, 0.6, Color(1.0, 0.95, 0.65), Vector3(0, 1, 0), 180.0, Vector3.ZERO, 0.05, 6.0)
	_autofree(p, 0.8)

static func void_implode(parent: Node3D, position: Vector3) -> void:
	var p := _make_burst(parent, position, 30, 0.8, Color(0.45, 0.15, 0.85), Vector3(0, 0, 0), 360.0, Vector3.ZERO, 0.06, 3.0)
	_autofree(p, 1.1)

static func _make_burst(parent: Node3D, position: Vector3, amount: int, lifetime: float, color: Color, dir: Vector3, spread: float, gravity: Vector3, size: float, emission_e: float) -> GPUParticles3D:
	var pg := GPUParticles3D.new()
	pg.position = position
	pg.one_shot = true
	pg.explosiveness = 1.0
	pg.amount = amount
	pg.lifetime = lifetime
	var pm := ParticleProcessMaterial.new()
	pm.direction = dir
	pm.spread = spread
	pm.gravity = gravity
	pm.initial_velocity_min = 1.5
	pm.initial_velocity_max = 4.5
	pm.scale_min = size * 0.6
	pm.scale_max = size
	pm.color = color
	pg.process_material = pm
	var mesh := SphereMesh.new()
	mesh.radius = 0.5; mesh.height = 1.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = emission_e > 0.0
	mat.emission = color
	mat.emission_energy_multiplier = emission_e
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	pg.draw_pass_1 = mesh
	parent.add_child(pg)
	pg.restart()
	return pg

static func _autofree(p: GPUParticles3D, after: float) -> void:
	var t := p.get_tree().create_timer(after)
	t.timeout.connect(func():
		if is_instance_valid(p): p.queue_free())
