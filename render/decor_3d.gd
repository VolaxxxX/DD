class_name Decor3D extends Node3D
# Builds biome-specific 3D decor around the creature stage.

func build(biome: StringName, corruption: float, rng: DRNG) -> void:
	match biome:
		&"forest":    _forest(rng, corruption)
		&"city":      _city(rng, corruption)
		&"ruins":     _ruins(rng, corruption)
		&"corrupted": _corrupted(rng, corruption)
		&"anomaly":   _anomaly(rng, corruption)
		_:            _forest(rng, corruption)

func _place(mesh: Mesh, pos: Vector3, color: Color, scale_v: Vector3 = Vector3.ONE, emission: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	mi.material_override = mat
	add_child(mi)

func _forest(rng: DRNG, corr: float) -> void:
	for i in 8:
		var x := _frng(rng, -7, 7)
		var z := _frng(rng, -6, -1)
		var trunk := CylinderMesh.new(); trunk.top_radius = 0.2; trunk.bottom_radius = 0.3; trunk.height = 2.5
		_place(trunk, Vector3(x, 1.25, z), Color(0.25, 0.16, 0.08).lerp(Color(0.3, 0.05, 0.2), corr))
		var leaves := SphereMesh.new(); leaves.radius = 0.9; leaves.height = 1.6
		var leaf_color := Color(0.18, 0.40, 0.15).lerp(Color(0.45, 0.1, 0.3), corr)
		_place(leaves, Vector3(x, 2.9, z), leaf_color, Vector3(1.1, 0.9, 1.1))

func _city(rng: DRNG, corr: float) -> void:
	for i in 6:
		var x := _frng(rng, -8, 8)
		var z := _frng(rng, -7, -1)
		var h := _frng(rng, 2.0, 5.0)
		var bldg := BoxMesh.new(); bldg.size = Vector3(1.4, h, 1.4)
		var col := Color(0.25, 0.26, 0.30).lerp(Color(0.35, 0.15, 0.3), corr)
		_place(bldg, Vector3(x, h * 0.5, z), col)
		if rng.chance(40, 100):
			var win := BoxMesh.new(); win.size = Vector3(0.15, 0.15, 0.05)
			_place(win, Vector3(x, h * 0.7, z + 0.72), Color(1.0, 0.85, 0.5), Vector3.ONE, 2.0)

func _ruins(rng: DRNG, corr: float) -> void:
	for i in 7:
		var x := _frng(rng, -7, 7)
		var z := _frng(rng, -6, -1)
		var h := _frng(rng, 1.0, 3.0)
		var pillar := CylinderMesh.new(); pillar.top_radius = 0.3; pillar.bottom_radius = 0.35; pillar.height = h
		_place(pillar, Vector3(x, h * 0.5, z), Color(0.45, 0.40, 0.32).lerp(Color(0.4, 0.15, 0.35), corr))
	var floor_plate := BoxMesh.new(); floor_plate.size = Vector3(3, 0.15, 3)
	_place(floor_plate, Vector3(0, -0.075, -2), Color(0.35, 0.32, 0.28))

func _corrupted(rng: DRNG, _corr: float) -> void:
	for i in 9:
		var x := _frng(rng, -8, 8)
		var z := _frng(rng, -7, -1)
		var h := _frng(rng, 1.5, 4.0)
		var spike := ConeMesh.new(); spike.top_radius = 0.05; spike.bottom_radius = 0.35; spike.height = h
		_place(spike, Vector3(x, h * 0.5, z), Color(0.35, 0.05, 0.35), Vector3.ONE, 0.6)

func _anomaly(rng: DRNG, _corr: float) -> void:
	for i in 10:
		var x := _frng(rng, -9, 9)
		var y := _frng(rng, 1.0, 4.0)
		var z := _frng(rng, -8, -1)
		var orb := SphereMesh.new(); orb.radius = _frng(rng, 0.15, 0.4); orb.height = orb.radius * 2
		_place(orb, Vector3(x, y, z), Color(0.35, 0.55, 1.0), Vector3.ONE, 2.2)
	# floor warp
	var floor_plate := BoxMesh.new(); floor_plate.size = Vector3(18, 0.1, 10)
	_place(floor_plate, Vector3(0, -0.05, -3), Color(0.08, 0.10, 0.25))

func _frng(rng: DRNG, lo: float, hi: float) -> float:
	var span := int((hi - lo) * 100.0)
	return lo + float(rng.range_i(0, maxi(1, span))) / 100.0
