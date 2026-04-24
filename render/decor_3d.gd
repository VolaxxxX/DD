class_name Decor3D extends Node3D
# Biome-specific decor with stronger silhouettes and layered foliage.

func build(biome: StringName, corruption: float, rng: DRNG) -> void:
	_grass_tufts(biome, rng)
	match biome:
		&"forest":    _forest(rng, corruption)
		&"city":      _city(rng, corruption)
		&"ruins":     _ruins(rng, corruption)
		&"corrupted": _corrupted(rng, corruption)
		&"anomaly":   _anomaly(rng, corruption)
		_:            _forest(rng, corruption)

func _place(mesh: Mesh, pos: Vector3, color: Color, scale_v: Vector3 = Vector3.ONE, emission: float = 0.0, rough: float = 0.85, rot_y: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.rotation.y = rot_y
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	mi.material_override = mat
	add_child(mi)

func _grass_tufts(biome: StringName, rng: DRNG) -> void:
	var color := Color(0.18, 0.30, 0.12)
	match String(biome):
		"forest":    color = Color(0.20, 0.40, 0.15)
		"city":      color = Color(0.22, 0.22, 0.22)
		"ruins":     color = Color(0.40, 0.36, 0.25)
		"corrupted": color = Color(0.30, 0.10, 0.25)
		"anomaly":   color = Color(0.18, 0.25, 0.45)
	for i in 24:
		var x := _frng(rng, -10, 10)
		var z := _frng(rng, -9, 0.5)
		var h := _frng(rng, 0.05, 0.18)
		var tuft := BoxMesh.new()
		tuft.size = Vector3(_frng(rng, 0.05, 0.18), h, _frng(rng, 0.05, 0.18))
		_place(tuft, Vector3(x, h * 0.5, z), color, Vector3.ONE, 0.0, 0.95, _frng(rng, 0, 6.28))

func _tree(rng: DRNG, x: float, z: float, corr: float) -> void:
	var trunk_h := _frng(rng, 2.2, 3.4)
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.18; trunk.bottom_radius = 0.32; trunk.height = trunk_h
	_place(trunk, Vector3(x, trunk_h * 0.5, z), Color(0.25, 0.16, 0.08).lerp(Color(0.30, 0.05, 0.20), corr))
	# Layered foliage: 3 staggered ellipsoids.
	var leaf_base := Color(0.18, 0.42, 0.16).lerp(Color(0.45, 0.10, 0.30), corr)
	for i in 3:
		var off := Vector3(_frng(rng, -0.35, 0.35), trunk_h + _frng(rng, -0.1, 0.6) + i * 0.4, _frng(rng, -0.35, 0.35))
		var s := _frng(rng, 0.85, 1.2)
		var leaves := SphereMesh.new()
		leaves.radius = 0.9; leaves.height = 1.5
		var tint := leaf_base.lerp(Color(0.05, 0.12, 0.05), float(i) * 0.15)
		_place(leaves, Vector3(x + off.x, off.y, z + off.z), tint, Vector3(s, s * 0.85, s))

func _forest(rng: DRNG, corr: float) -> void:
	for i in 9:
		_tree(rng, _frng(rng, -8, 8), _frng(rng, -7, -1), corr)
	# Mushrooms / rocks
	for i in 5:
		var x := _frng(rng, -6, 6)
		var z := _frng(rng, -5, -1)
		var rock := SphereMesh.new(); rock.radius = _frng(rng, 0.25, 0.55); rock.height = rock.radius * 1.3
		_place(rock, Vector3(x, rock.radius * 0.4, z), Color(0.32, 0.30, 0.28))

func _city(rng: DRNG, corr: float) -> void:
	for i in 7:
		var x := _frng(rng, -9, 9)
		var z := _frng(rng, -8, -1)
		var h := _frng(rng, 2.5, 6.0)
		var w := _frng(rng, 1.0, 1.8)
		var bldg := BoxMesh.new(); bldg.size = Vector3(w, h, w)
		var col := Color(0.22, 0.24, 0.30).lerp(Color(0.35, 0.15, 0.30), corr)
		_place(bldg, Vector3(x, h * 0.5, z), col, Vector3.ONE, 0.0, 0.7)
		# Roof peak
		var roof := PrismMesh.new(); roof.size = Vector3(w * 1.05, w * 0.5, w * 1.05)
		_place(roof, Vector3(x, h + w * 0.25, z), col.darkened(0.2))
		# Lit windows
		for j in 3:
			if rng.chance(55, 100):
				var win := BoxMesh.new(); win.size = Vector3(0.18, 0.22, 0.04)
				var wy := _frng(rng, 0.6, h - 0.3)
				_place(win, Vector3(x, wy, z + w * 0.51), Color(1.0, 0.82, 0.50), Vector3.ONE, 2.5)

func _ruins(rng: DRNG, corr: float) -> void:
	for i in 8:
		var x := _frng(rng, -8, 8)
		var z := _frng(rng, -7, -1)
		var h := _frng(rng, 1.0, 3.5)
		var pillar := CylinderMesh.new()
		pillar.top_radius = 0.30; pillar.bottom_radius = 0.36; pillar.height = h
		_place(pillar, Vector3(x, h * 0.5, z), Color(0.50, 0.45, 0.36).lerp(Color(0.40, 0.15, 0.35), corr))
		# Capital stone on top
		var cap := BoxMesh.new(); cap.size = Vector3(0.85, 0.18, 0.85)
		_place(cap, Vector3(x, h + 0.09, z), Color(0.55, 0.50, 0.40))
	# Stepped plinth
	var plinth := BoxMesh.new(); plinth.size = Vector3(4, 0.3, 4)
	_place(plinth, Vector3(0, 0.15, -2), Color(0.45, 0.42, 0.36))
	var plinth2 := BoxMesh.new(); plinth2.size = Vector3(2.4, 0.3, 2.4)
	_place(plinth2, Vector3(0, 0.45, -2), Color(0.50, 0.47, 0.40))

func _corrupted(rng: DRNG, _corr: float) -> void:
	for i in 11:
		var x := _frng(rng, -9, 9)
		var z := _frng(rng, -8, -1)
		var h := _frng(rng, 1.2, 4.5)
		var spike := CylinderMesh.new()
		spike.top_radius = 0.04; spike.bottom_radius = 0.32; spike.height = h
		var col := Color(0.50, 0.10, 0.50)
		_place(spike, Vector3(x, h * 0.5, z), col, Vector3.ONE, 1.5, 0.4)
	# Pulsing orbs
	for i in 4:
		var x := _frng(rng, -6, 6)
		var z := _frng(rng, -5, -1)
		var orb := SphereMesh.new(); orb.radius = 0.22; orb.height = 0.44
		_place(orb, Vector3(x, _frng(rng, 0.6, 1.6), z), Color(1.0, 0.35, 0.85), Vector3.ONE, 3.0)

func _anomaly(rng: DRNG, _corr: float) -> void:
	for i in 12:
		var x := _frng(rng, -9, 9)
		var y := _frng(rng, 0.8, 5.0)
		var z := _frng(rng, -8, -1)
		var orb := SphereMesh.new()
		orb.radius = _frng(rng, 0.18, 0.45); orb.height = orb.radius * 2
		var col := Color(0.40, 0.65, 1.0).lerp(Color(0.85, 0.45, 1.0), _frng(rng, 0, 1))
		_place(orb, Vector3(x, y, z), col, Vector3.ONE, 2.6)
	# Floating shards
	for i in 6:
		var shard := PrismMesh.new(); shard.size = Vector3(0.4, 0.9, 0.2)
		var x := _frng(rng, -7, 7); var y := _frng(rng, 1.5, 3.5); var z := _frng(rng, -6, -2)
		_place(shard, Vector3(x, y, z), Color(0.65, 0.55, 1.0), Vector3.ONE, 1.8, 0.3, _frng(rng, 0, 6.28))
	# Warp floor
	var plate := BoxMesh.new(); plate.size = Vector3(20, 0.1, 12)
	_place(plate, Vector3(0, -0.05, -3), Color(0.10, 0.12, 0.30), Vector3.ONE, 0.5, 0.2)

func _frng(rng: DRNG, lo: float, hi: float) -> float:
	var span := int((hi - lo) * 100.0)
	return lo + float(rng.range_i(0, maxi(1, span))) / 100.0
