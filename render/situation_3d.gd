class_name Situation3D extends Node3D
# 3D centerpiece for non-creature situations — the player always sees the scene.

func build(situation_id: StringName) -> void:
	for c in get_children(): c.queue_free()
	match String(situation_id):
		"inscription":    _inscription()
		"collapse":       _collapse()
		"shrine":         _shrine()
		"stranger":       _stranger()
		"storm":          _storm()
		"blood_trail":    _blood_trail()
		"deep_well":      _well()
		"beggar_child":   _child()
		"crossroads":     _crossroads()
		"burning_tree":   _burning_tree()
		"warm_carcass":   _carcass()
		"the_double":     _double()
		"broken_statue":  _statue()
		_:                _shrine()

func _add(mesh: Mesh, pos: Vector3, color: Color, emission_e: float = 0.0, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, rough: float = 0.8) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh; mi.position = pos; mi.scale = scale_v; mi.rotation_degrees = rot_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color; mat.roughness = rough
	if emission_e > 0.0:
		mat.emission_enabled = true; mat.emission = color
		mat.emission_energy_multiplier = emission_e
	mi.material_override = mat
	add_child(mi)
	return mi

func _glyph_dots(center: Vector3, color: Color, n: int = 6) -> void:
	for i in n:
		var d := SphereMesh.new(); d.radius = 0.03; d.height = 0.06
		_add(d, center + Vector3(fmod(i * 0.13, 0.4) - 0.2, fmod(i * 0.21, 0.5) - 0.1, 0.06), color, 3.0)

func _inscription() -> void:
	var slab := BoxMesh.new(); slab.size = Vector3(1.2, 1.8, 0.25)
	_add(slab, Vector3(0, 0.9, 0), Color(0.45, 0.42, 0.38), 0.0, Vector3.ONE, Vector3(0, 8, -3))
	_glyph_dots(Vector3(0, 1.1, 0.1), Color(0.55, 0.85, 1.0), 9)

func _collapse() -> void:
	for i in 6:
		var s := BoxMesh.new(); s.size = Vector3(0.6 + i * 0.1, 0.18, 0.5)
		_add(s, Vector3(-0.8 + i * 0.3, 0.1 + i * 0.12, -i * 0.15), Color(0.40, 0.36, 0.32), 0.0, Vector3.ONE, Vector3(i * 4, i * 9, i * 6))
	var hole := CylinderMesh.new(); hole.top_radius = 0.9; hole.bottom_radius = 0.9; hole.height = 0.05
	_add(hole, Vector3(0, 0.01, 0.4), Color(0.03, 0.03, 0.05))

func _shrine() -> void:
	var base := BoxMesh.new(); base.size = Vector3(1.4, 0.3, 1.0)
	_add(base, Vector3(0, 0.15, 0), Color(0.50, 0.47, 0.42))
	var altar := BoxMesh.new(); altar.size = Vector3(0.9, 0.7, 0.7)
	_add(altar, Vector3(0, 0.65, 0), Color(0.55, 0.52, 0.46))
	var flame := SphereMesh.new(); flame.radius = 0.10; flame.height = 0.20
	_add(flame, Vector3(0, 1.15, 0), Color(1.0, 0.75, 0.35), 4.0)

func _stranger() -> void:
	var cloak := CapsuleMesh.new(); cloak.radius = 0.30; cloak.height = 1.3
	_add(cloak, Vector3(0, 0.85, 0), Color(0.18, 0.15, 0.20))
	var hood := SphereMesh.new(); hood.radius = 0.24; hood.height = 0.44
	_add(hood, Vector3(0, 1.55, 0), Color(0.14, 0.12, 0.16))
	var purse := SphereMesh.new(); purse.radius = 0.10; purse.height = 0.18
	_add(purse, Vector3(0.35, 1.0, 0.15), Color(0.65, 0.50, 0.25), 0.6)

func _storm() -> void:
	for i in 4:
		var cloud := SphereMesh.new(); cloud.radius = 0.5 + i * 0.1; cloud.height = 0.6
		_add(cloud, Vector3(-0.6 + i * 0.45, 3.2 + fmod(i * 0.3, 0.5), 0), Color(0.25, 0.25, 0.30))
	for i in 3:
		var bolt := PrismMesh.new(); bolt.size = Vector3(0.06, 1.2, 0.06)
		_add(bolt, Vector3(-0.4 + i * 0.5, 2.2, 0), Color(0.95, 0.95, 1.0), 5.0, Vector3.ONE, Vector3(0, 0, 8 - i * 8))

func _blood_trail() -> void:
	for i in 7:
		var drop := SphereMesh.new(); drop.radius = 0.10 - i * 0.008; drop.height = 0.05
		_add(drop, Vector3(-1.2 + i * 0.4, 0.03, 0.3 - i * 0.25), Color(0.55, 0.05, 0.05), 0.4)

func _well() -> void:
	var ring := TorusMesh.new(); ring.inner_radius = 0.55; ring.outer_radius = 0.8
	_add(ring, Vector3(0, 0.3, 0), Color(0.42, 0.40, 0.38))
	var water := CylinderMesh.new(); water.top_radius = 0.55; water.bottom_radius = 0.55; water.height = 0.04
	_add(water, Vector3(0, 0.25, 0), Color(0.05, 0.10, 0.18), 0.5, Vector3.ONE, Vector3.ZERO, 0.1)
	var post := CylinderMesh.new(); post.top_radius = 0.05; post.bottom_radius = 0.05; post.height = 1.4
	_add(post, Vector3(-0.7, 0.9, 0), Color(0.35, 0.25, 0.15))
	_add(post, Vector3(0.7, 0.9, 0), Color(0.35, 0.25, 0.15))
	var beam := CylinderMesh.new(); beam.top_radius = 0.04; beam.bottom_radius = 0.04; beam.height = 1.5
	_add(beam, Vector3(0, 1.55, 0), Color(0.35, 0.25, 0.15), 0.0, Vector3.ONE, Vector3(0, 0, 90))

func _child() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.16; body.height = 0.7
	_add(body, Vector3(0, 0.45, 0), Color(0.30, 0.26, 0.22))
	var head := SphereMesh.new(); head.radius = 0.14; head.height = 0.28
	_add(head, Vector3(0, 0.95, 0), Color(0.85, 0.70, 0.58))
	var bowl := CylinderMesh.new(); bowl.top_radius = 0.12; bowl.bottom_radius = 0.08; bowl.height = 0.08
	_add(bowl, Vector3(0.3, 0.05, 0.15), Color(0.45, 0.35, 0.22))

func _crossroads() -> void:
	var post := CylinderMesh.new(); post.top_radius = 0.06; post.bottom_radius = 0.07; post.height = 2.0
	_add(post, Vector3(0, 1.0, 0), Color(0.35, 0.26, 0.16))
	var sign1 := BoxMesh.new(); sign1.size = Vector3(0.8, 0.18, 0.05)
	_add(sign1, Vector3(0.3, 1.7, 0), Color(0.45, 0.34, 0.20), 0.0, Vector3.ONE, Vector3(0, 20, 0))
	_add(sign1, Vector3(-0.3, 1.45, 0), Color(0.45, 0.34, 0.20), 0.0, Vector3.ONE, Vector3(0, -25, 0))

func _burning_tree() -> void:
	var trunk := CylinderMesh.new(); trunk.top_radius = 0.15; trunk.bottom_radius = 0.28; trunk.height = 2.2
	_add(trunk, Vector3(0, 1.1, 0), Color(0.20, 0.13, 0.08))
	for i in 6:
		var flame := SphereMesh.new(); flame.radius = 0.22 - i * 0.02; flame.height = 0.4
		_add(flame, Vector3(fmod(i * 0.25, 0.6) - 0.3, 2.2 + i * 0.25, fmod(i * 0.17, 0.4) - 0.2), Color(1.0, 0.55, 0.15), 3.5)

func _carcass() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.35; body.height = 1.2
	_add(body, Vector3(0, 0.3, 0), Color(0.45, 0.30, 0.22), 0.0, Vector3.ONE, Vector3(0, 15, 90))
	var rib := TorusMesh.new(); rib.inner_radius = 0.18; rib.outer_radius = 0.24
	_add(rib, Vector3(0.1, 0.45, 0), Color(0.85, 0.80, 0.70), 0.0, Vector3.ONE, Vector3(0, 90, 0))

func _double() -> void:
	# A dark mirror of the player silhouette.
	var body := CapsuleMesh.new(); body.radius = 0.22; body.height = 0.85
	_add(body, Vector3(0, 0.95, 0), Color(0.08, 0.06, 0.12))
	var head := SphereMesh.new(); head.radius = 0.18; head.height = 0.36
	_add(head, Vector3(0, 1.55, 0), Color(0.10, 0.08, 0.14))
	for side in [-1, 1]:
		var eye := SphereMesh.new(); eye.radius = 0.035; eye.height = 0.07
		_add(eye, Vector3(side * 0.07, 1.6, 0.16), Color(1, 1, 1), 5.0)

func _statue() -> void:
	var base := BoxMesh.new(); base.size = Vector3(1.0, 0.4, 1.0)
	_add(base, Vector3(0, 0.2, 0), Color(0.48, 0.45, 0.40))
	var torso := CapsuleMesh.new(); torso.radius = 0.25; torso.height = 1.0
	_add(torso, Vector3(0, 1.0, 0), Color(0.55, 0.52, 0.47), 0.0, Vector3.ONE, Vector3(0, 0, 8))
	# missing head — broken neck stump
	var stump := CylinderMesh.new(); stump.top_radius = 0.10; stump.bottom_radius = 0.14; stump.height = 0.15
	_add(stump, Vector3(0.05, 1.6, 0), Color(0.50, 0.47, 0.42))
	var arm := CapsuleMesh.new(); arm.radius = 0.08; arm.height = 0.6
	_add(arm, Vector3(-0.35, 1.1, 0), Color(0.55, 0.52, 0.47), 0.0, Vector3.ONE, Vector3(0, 0, 40))
