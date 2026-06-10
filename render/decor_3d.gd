class_name Decor3D extends Node3D
# Biome-specific decor with stronger silhouettes and layered foliage.

func build(biome: StringName, corruption: float, rng: DRNG) -> void:
	_grass_tufts(biome, rng)
	# Try Kenney prop layout first; on failure fall back to procedural.
	if _try_kenney(biome, corruption, rng):
		return
	match biome:
		&"forest":    _forest(rng, corruption)
		&"city":      _city(rng, corruption)
		&"ruins":     _ruins(rng, corruption)
		&"corrupted": _corrupted(rng, corruption)
		&"anomaly":   _anomaly(rng, corruption)
		&"swamp":     _swamp(rng, corruption)
		&"highland":  _highland(rng, corruption)
		&"crypt":     _crypt(rng, corruption)
		&"coast":     _coast(rng, corruption)
		_:            _forest(rng, corruption)

func _place(mesh: Mesh, pos: Vector3, color: Color, scale_v: Vector3 = Vector3.ONE, emission: float = 0.0, rough: float = 0.85, rot_y: float = 0.0, sway: bool = false) -> void:
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
	if sway:
		mi.set_meta("sway_amp", 0.05 + (randf() * 0.04))
		mi.set_meta("sway_phase", randf() * TAU)

func _process(delta: float) -> void:
	# Apply wind sway on all meshes marked with sway metadata.
	var t := Time.get_ticks_msec() / 1000.0
	for child in get_children():
		if child is MeshInstance3D and child.has_meta("sway_amp"):
			var amp: float = child.get_meta("sway_amp")
			var ph: float = child.get_meta("sway_phase")
			child.rotation.z = sin(t * 0.8 + ph) * amp

func _grass_tufts(biome: StringName, rng: DRNG) -> void:
	var color := Color(0.18, 0.30, 0.12)
	match String(biome):
		"forest":    color = Color(0.20, 0.40, 0.15)
		"city":      color = Color(0.22, 0.22, 0.22)
		"ruins":     color = Color(0.40, 0.36, 0.25)
		"corrupted": color = Color(0.30, 0.10, 0.25)
		"anomaly":   color = Color(0.18, 0.25, 0.45)
		"swamp":     color = Color(0.15, 0.30, 0.18)
		"highland":  color = Color(0.30, 0.40, 0.20)
		"crypt":     color = Color(0.15, 0.14, 0.15)
		"coast":     color = Color(0.55, 0.48, 0.30)
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
		_place(leaves, Vector3(x + off.x, off.y, z + off.z), tint, Vector3(s, s * 0.85, s), 0.0, 0.85, 0.0, true)

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

func _swamp(rng: DRNG, _corr: float) -> void:
	# Stagnant water plane + dead twisted trees + lily pads + mist orbs.
	var water := PlaneMesh.new(); water.size = Vector2(40, 25)
	_place(water, Vector3(0, 0.05, -3), Color(0.10, 0.18, 0.14), Vector3.ONE, 0.2, 0.25)
	for i in 7:
		var x := _frng(rng, -8, 8); var z := _frng(rng, -7, -1)
		var h := _frng(rng, 2.5, 4.0)
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.10; trunk.bottom_radius = 0.22; trunk.height = h
		_place(trunk, Vector3(x, h * 0.5, z), Color(0.18, 0.14, 0.10), Vector3.ONE, 0.0, 0.95, _frng(rng, 0, 0.4))
		# bare twisted branches
		var branch := CylinderMesh.new()
		branch.top_radius = 0.04; branch.bottom_radius = 0.07; branch.height = 0.9
		_place(branch, Vector3(x + 0.3, h * 0.85, z), Color(0.20, 0.15, 0.10), Vector3.ONE, 0.0, 0.95, 0.0)
		_place(branch, Vector3(x - 0.3, h * 0.7, z + 0.2), Color(0.20, 0.15, 0.10), Vector3.ONE, 0.0, 0.95, 0.0)
	# lily pads
	for i in 8:
		var pad := CylinderMesh.new(); pad.top_radius = 0.30; pad.bottom_radius = 0.30; pad.height = 0.04
		_place(pad, Vector3(_frng(rng, -7, 7), 0.07, _frng(rng, -6, -1)), Color(0.20, 0.40, 0.18))
	# mist orbs
	for i in 5:
		var orb := SphereMesh.new(); orb.radius = 0.18; orb.height = 0.36
		_place(orb, Vector3(_frng(rng, -6, 6), _frng(rng, 0.4, 1.4), _frng(rng, -5, -1)), Color(0.55, 0.65, 0.50), Vector3.ONE, 1.4)

func _highland(rng: DRNG, _corr: float) -> void:
	# Distant mountain silhouettes + boulders + tall grass + windswept tree.
	for i in 5:
		var mountain := PrismMesh.new()
		var mw := _frng(rng, 3.5, 6.0)
		mountain.size = Vector3(mw, _frng(rng, 4.0, 7.0), mw * 0.8)
		var x := _frng(rng, -14, 14); var z := _frng(rng, -14, -8)
		_place(mountain, Vector3(x, mountain.size.y * 0.5, z), Color(0.25, 0.28, 0.32), Vector3.ONE, 0.0, 0.95, _frng(rng, 0, 6.28))
	for i in 7:
		var rock := SphereMesh.new()
		var r := _frng(rng, 0.4, 0.9); rock.radius = r; rock.height = r * 1.4
		_place(rock, Vector3(_frng(rng, -8, 8), r * 0.5, _frng(rng, -6, -1)), Color(0.40, 0.42, 0.38))
	# A single twisted tree
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.18; trunk.bottom_radius = 0.30; trunk.height = 2.4
	_place(trunk, Vector3(-3, 1.2, -2), Color(0.30, 0.22, 0.15))
	var canopy := SphereMesh.new(); canopy.radius = 0.95; canopy.height = 1.0
	_place(canopy, Vector3(-3, 2.6, -2), Color(0.20, 0.32, 0.18), Vector3(1.4, 0.6, 1.0))

func _crypt(rng: DRNG, _corr: float) -> void:
	# Stone tomb walls + sarcophagi + candles + cobwebs (bars).
	for i in 4:
		var wall := BoxMesh.new()
		wall.size = Vector3(_frng(rng, 1.5, 3.5), _frng(rng, 2.0, 3.0), 0.4)
		var x := _frng(rng, -7, 7); var z := _frng(rng, -7, -3)
		_place(wall, Vector3(x, wall.size.y * 0.5, z), Color(0.18, 0.17, 0.18), Vector3.ONE, 0.0, 0.9)
	for i in 4:
		var sarco := BoxMesh.new(); sarco.size = Vector3(0.8, 0.6, 1.8)
		_place(sarco, Vector3(_frng(rng, -5, 5), 0.3, _frng(rng, -5, -1)), Color(0.30, 0.28, 0.26))
	for i in 6:
		var cx := _frng(rng, -6, 6); var cz := _frng(rng, -5, -1)
		var candle := CylinderMesh.new(); candle.top_radius = 0.04; candle.bottom_radius = 0.04; candle.height = 0.25
		_place(candle, Vector3(cx, 0.13, cz), Color(0.85, 0.80, 0.65))
		var flame := SphereMesh.new(); flame.radius = 0.06; flame.height = 0.12
		_place(flame, Vector3(cx, 0.30, cz), Color(1.0, 0.55, 0.20), Vector3.ONE, 4.0)
	# Stone arch
	var arch_l := BoxMesh.new(); arch_l.size = Vector3(0.4, 3.0, 0.4)
	_place(arch_l, Vector3(-1.6, 1.5, -2), Color(0.22, 0.20, 0.20))
	_place(arch_l, Vector3(1.6, 1.5, -2), Color(0.22, 0.20, 0.20))
	var arch_top := BoxMesh.new(); arch_top.size = Vector3(3.4, 0.4, 0.4)
	_place(arch_top, Vector3(0, 3.2, -2), Color(0.22, 0.20, 0.20))

func _coast(rng: DRNG, _corr: float) -> void:
	# Sea horizon + rocky outcrops + driftwood + gulls (small white triangles).
	var sea := PlaneMesh.new(); sea.size = Vector2(60, 30)
	_place(sea, Vector3(0, 0.04, -10), Color(0.15, 0.30, 0.40), Vector3.ONE, 0.4, 0.15)
	for i in 5:
		var rock := SphereMesh.new()
		var r := _frng(rng, 0.6, 1.4); rock.radius = r; rock.height = r * 1.3
		_place(rock, Vector3(_frng(rng, -10, 10), r * 0.4, _frng(rng, -8, -3)), Color(0.30, 0.30, 0.32))
	for i in 4:
		var log := CylinderMesh.new(); log.top_radius = 0.10; log.bottom_radius = 0.12; log.height = 1.4
		_place(log, Vector3(_frng(rng, -6, 6), 0.10, _frng(rng, -3, -1)), Color(0.40, 0.30, 0.20), Vector3.ONE, 0.0, 0.95, _frng(rng, 0, 6.28))
	# distant gulls
	for i in 6:
		var gull := PrismMesh.new(); gull.size = Vector3(0.30, 0.08, 0.10)
		_place(gull, Vector3(_frng(rng, -10, 10), _frng(rng, 4, 7), _frng(rng, -12, -6)), Color(0.95, 0.95, 0.95), Vector3.ONE, 0.5)

func _try_kenney(biome: StringName, corruption: float, rng: DRNG) -> bool:
	# Pull props from the per-biome Kenney inventory. Returns true if anything
	# loaded successfully — false leaves the procedural builder in charge.
	var hero: Array = PropLoader.pool_for(biome, &"hero")
	var ground: Array = PropLoader.pool_for(biome, &"ground")
	var any := 0
	# Place 9 "hero" props in a half-arc behind the encounter.
	for i in 9:
		var pick: Array = hero[rng.range_i(0, hero.size())] if hero.size() > 0 else []
		if pick.size() < 2: continue
		var n: Node3D = PropLoader.instance(pick[0], pick[1])
		if n == null: continue
		any += 1
		var x := _frng(rng, -9, 9)
		var z := _frng(rng, -8, -1)
		var scl := _frng(rng, 1.2, 2.4) * float(pick[2])
		n.position = Vector3(x, float(pick[3]), z)
		n.rotation.y = _frng(rng, 0, 6.28)
		n.scale = Vector3.ONE * scl
		add_child(n)
		# Corruption tint via per-instance modulate on the meshes.
		if corruption > 0.4:
			_tint_children(n, Color(1.0, 1.0, 1.0).lerp(Color(0.55, 0.20, 0.45), corruption * 0.5))
	# Place 14 "ground" props (bushes, rocks, mushrooms) scattered.
	for i in 14:
		var pick: Array = ground[rng.range_i(0, ground.size())] if ground.size() > 0 else []
		if pick.size() < 2: continue
		var n: Node3D = PropLoader.instance(pick[0], pick[1])
		if n == null: continue
		any += 1
		var x := _frng(rng, -8, 8)
		var z := _frng(rng, -7, -0.5)
		var scl := _frng(rng, 0.8, 1.6) * float(pick[2])
		n.position = Vector3(x, float(pick[3]), z)
		n.rotation.y = _frng(rng, 0, 6.28)
		n.scale = Vector3.ONE * scl
		add_child(n)
	return any > 0

func _tint_children(node: Node, tint: Color) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			var mi: MeshInstance3D = c
			var mat := StandardMaterial3D.new()
			mat.albedo_color = tint
			mi.material_override = mat
		_tint_children(c, tint)

func _frng(rng: DRNG, lo: float, hi: float) -> float:
	var span := int((hi - lo) * 100.0)
	return lo + float(rng.range_i(0, maxi(1, span))) / 100.0
