class_name WorldBoss3D extends Node3D
# Massive cinematic world-boss visual. One unique build per boss id.
# Built from primitives — emphasis on silhouette, scale, glow.

const BOSS_HEIGHT := 8.0    # towering presence

func build(boss_id: StringName) -> void:
	for c in get_children(): c.queue_free()
	var loaded: Node3D = AssetLoader.instance_for_boss(boss_id)
	if loaded != null:
		add_child(loaded)
		# Bosses arrive in a dramatic attack pose, then settle to idle (queued).
		AssetLoader.play_named_action(loaded, &"attack", false)
		_glow_light(Vector3(0, 4, 0), Color(1, 0.85, 0.55), 6.0, 25.0)
		return
	match String(boss_id):
		"prismatic_ascendant":  _prismatic_ascendant()
		"nameless_sovereign":   _nameless_sovereign()
		"sea_beneath_stone":    _sea_beneath_stone()
		"gallows_parliament":   _gallows_parliament()
		"silent_orchestra":     _silent_orchestra()
		"that_which_dreams_us": _that_which_dreams_us()
		_:                      _prismatic_ascendant()

func _add(mesh: Mesh, pos: Vector3, color: Color, emission_e: float = 0.0, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, rough: float = 0.6) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.rotation_degrees = rot_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	if emission_e > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_e
	mi.material_override = mat
	add_child(mi)
	return mi

func _glow_light(pos: Vector3, color: Color, energy: float = 4.0, range_v: float = 12.0) -> void:
	var ol := OmniLight3D.new()
	ol.position = pos
	ol.light_color = color
	ol.light_energy = energy
	ol.omni_range = range_v
	add_child(ol)

# ---------- Bosses ----------

func _prismatic_ascendant() -> void:
	# Towering crystalline prism, all colors alternating, vertical light beams.
	var palette := [Color(1.0, 0.3, 0.3), Color(1.0, 0.85, 0.3), Color(0.4, 1.0, 0.4),
					Color(0.4, 0.7, 1.0), Color(0.85, 0.4, 1.0), Color(1.0, 0.5, 0.85)]
	for i in 6:
		var p := PrismMesh.new(); p.size = Vector3(2.4, 6.0, 2.4)
		var rot := Vector3(0, i * 60.0, 0)
		_add(p, Vector3(0, 3.0, 0), palette[i], 1.6, Vector3(0.6, 1.0, 0.6), rot, 0.2)
	# Crowning floating shard
	var crown := PrismMesh.new(); crown.size = Vector3(2.0, 3.0, 2.0)
	_add(crown, Vector3(0, 8.0, 0), Color(1, 1, 1), 3.0, Vector3.ONE, Vector3(0, 30, 0), 0.0)
	# Vertical light pillars
	for i in 8:
		var beam := CylinderMesh.new(); beam.top_radius = 0.10; beam.bottom_radius = 0.20; beam.height = 12.0
		var ang := i * TAU / 8.0
		_add(beam, Vector3(cos(ang) * 3.5, 6.0, sin(ang) * 3.5), palette[i % palette.size()], 4.0, Vector3.ONE)
	_glow_light(Vector3(0, 6, 0), Color(1, 1, 1), 6.0, 25.0)

func _nameless_sovereign() -> void:
	# Empty obsidian throne, floating crown halo, void-purple aura.
	var seat := BoxMesh.new(); seat.size = Vector3(3.5, 0.6, 2.4)
	_add(seat, Vector3(0, 1.6, 0), Color(0.05, 0.04, 0.08), 0.0, Vector3.ONE, Vector3.ZERO, 0.3)
	var back := BoxMesh.new(); back.size = Vector3(3.5, 5.5, 0.5)
	_add(back, Vector3(0, 4.5, -1.0), Color(0.05, 0.04, 0.08), 0.0, Vector3.ONE, Vector3.ZERO, 0.3)
	var arm := BoxMesh.new(); arm.size = Vector3(0.4, 1.5, 2.0)
	_add(arm, Vector3(-1.7, 2.6, 0), Color(0.05, 0.04, 0.08))
	_add(arm, Vector3(1.7, 2.6, 0), Color(0.05, 0.04, 0.08))
	# spires
	for i in 5:
		var spire := PrismMesh.new(); spire.size = Vector3(0.5, _frng(i, 1.5, 2.5), 0.5)
		_add(spire, Vector3(-1.5 + i * 0.75, 7.5, -1.0), Color(0.10, 0.05, 0.15), 0.5)
	# floating crown halo
	for i in 12:
		var ang := i * TAU / 12.0
		var pt := SphereMesh.new(); pt.radius = 0.10; pt.height = 0.20
		_add(pt, Vector3(cos(ang) * 1.5, 8.5, sin(ang) * 1.5), Color(0.85, 0.3, 1.0), 5.0)
	_glow_light(Vector3(0, 8, 0), Color(0.7, 0.2, 1.0), 8.0, 25.0)
	_glow_light(Vector3(0, 3, 1), Color(0.4, 0.1, 0.6), 4.0, 15.0)

func _sea_beneath_stone() -> void:
	# Massive eye rising through cracked ground, surrounded by tentacles.
	var eye := SphereMesh.new(); eye.radius = 2.2; eye.height = 4.4
	_add(eye, Vector3(0, 2.5, 0), Color(0.95, 0.85, 0.50), 1.5, Vector3.ONE, Vector3.ZERO, 0.1)
	var pupil := SphereMesh.new(); pupil.radius = 1.0; pupil.height = 2.0
	_add(pupil, Vector3(0, 2.5, 1.5), Color(0.05, 0.02, 0.08), 0.0, Vector3.ONE, Vector3.ZERO, 0.1)
	var iris := SphereMesh.new(); iris.radius = 1.7; iris.height = 3.4
	_add(iris, Vector3(0, 2.5, 1.0), Color(0.20, 0.10, 0.35), 0.5, Vector3.ONE, Vector3.ZERO, 0.2)
	# tentacles
	for i in 8:
		var ang := i * TAU / 8.0
		var t := CylinderMesh.new()
		t.top_radius = 0.10; t.bottom_radius = 0.45; t.height = 5.0
		_add(t, Vector3(cos(ang) * 3.5, 2.5, sin(ang) * 3.5), Color(0.30, 0.20, 0.30), 0.4, Vector3.ONE, Vector3(_frng(i, 20, 60), rad_to_deg(ang), 0))
	# cracked ground stones around
	for i in 10:
		var ang := i * TAU / 10.0
		var stone := PrismMesh.new(); stone.size = Vector3(_frng(i, 0.8, 1.3), _frng(i, 0.4, 1.0), _frng(i, 0.8, 1.3))
		_add(stone, Vector3(cos(ang) * 5.0, 0.3, sin(ang) * 5.0), Color(0.30, 0.25, 0.20))
	_glow_light(Vector3(0, 2.5, 1.5), Color(0.95, 0.85, 0.50), 6.0, 20.0)

func _gallows_parliament() -> void:
	# 12 hanging figures + drifting ash particles + lantern glow.
	for i in 12:
		var ang := i * TAU / 12.0
		var rope := CylinderMesh.new()
		rope.top_radius = 0.04; rope.bottom_radius = 0.04; rope.height = 4.0
		_add(rope, Vector3(cos(ang) * 4.0, 6.0, sin(ang) * 4.0), Color(0.30, 0.22, 0.15))
		var body := CapsuleMesh.new()
		body.radius = 0.35; body.height = 1.6
		_add(body, Vector3(cos(ang) * 4.0, 3.5, sin(ang) * 4.0), Color(0.15, 0.10, 0.08))
		# Tattered robe (extra prism per figure)
		var robe := PrismMesh.new(); robe.size = Vector3(0.6, 1.4, 0.10)
		_add(robe, Vector3(cos(ang) * 4.0, 3.2, sin(ang) * 4.0), Color(0.08, 0.05, 0.05), 0.0, Vector3.ONE, Vector3(0, rad_to_deg(ang), 0))
		var head := SphereMesh.new()
		head.radius = 0.32; head.height = 0.64
		_add(head, Vector3(cos(ang) * 4.0, 4.6, sin(ang) * 4.0), Color(0.10, 0.06, 0.05))
		# Glowing eye sockets per hanged judge
		for side in [-1, 1]:
			var eye := SphereMesh.new(); eye.radius = 0.05; eye.height = 0.10
			_add(eye, Vector3(cos(ang) * 4.0 + side * 0.08, 4.65, sin(ang) * 4.0 + 0.20), Color(0.9, 0.85, 0.65), 6.0)
		# crossbeam segment
		var beam := BoxMesh.new(); beam.size = Vector3(2.0, 0.2, 0.2)
		_add(beam, Vector3(cos(ang) * 4.0, 8.0, sin(ang) * 4.0), Color(0.20, 0.14, 0.10), 0.0, Vector3.ONE, Vector3(0, rad_to_deg(ang) + 90, 0))
		# Hanging lantern beneath each figure
		var lantern := SphereMesh.new(); lantern.radius = 0.12; lantern.height = 0.24
		_add(lantern, Vector3(cos(ang) * 4.0, 2.2, sin(ang) * 4.0), Color(1.0, 0.65, 0.25), 4.0)
	# central scale of judgment
	var post := CylinderMesh.new(); post.top_radius = 0.10; post.bottom_radius = 0.15; post.height = 4.0
	_add(post, Vector3(0, 2.0, 0), Color(0.30, 0.22, 0.15))
	var pan := CylinderMesh.new(); pan.top_radius = 0.6; pan.bottom_radius = 0.6; pan.height = 0.08
	_add(pan, Vector3(-0.8, 4.0, 0), Color(0.55, 0.50, 0.40), 0.4)
	_add(pan, Vector3(0.8, 4.0, 0), Color(0.55, 0.50, 0.40), 0.4)
	# Sacred verdict orb at the top of the post
	var orb := SphereMesh.new(); orb.radius = 0.30; orb.height = 0.60
	_add(orb, Vector3(0, 4.7, 0), Color(1.0, 0.95, 0.65), 5.0)
	_add_ash_particles(Vector3(0, 6, 0), Color(0.85, 0.80, 0.65, 0.7), 60)
	_glow_light(Vector3(0, 5, 0), Color(0.9, 0.85, 0.65), 5.0, 30.0)
	_glow_light(Vector3(0, 2.2, 0), Color(1.0, 0.55, 0.20), 3.5, 14.0)

func _silent_orchestra() -> void:
	# Orchestra spiral + music-note particles + ghostly conductor outline.
	for i in 14:
		var ang := i * TAU / 14.0
		var radius := 4.5 + sin(i) * 0.5
		var y := 2.0 + i * 0.25 + sin(i * 0.7) * 0.6
		var color := Color(0.55, 0.40, 0.20).lerp(Color(0.85, 0.65, 0.30), float(i) / 14.0)
		var which := i % 4
		match which:
			0:
				var lute := CapsuleMesh.new(); lute.radius = 0.35; lute.height = 1.4
				_add(lute, Vector3(cos(ang) * radius, y, sin(ang) * radius), color, 0.3, Vector3.ONE, Vector3(rad_to_deg(ang), 0, 30))
				# Strings glow
				var strings := BoxMesh.new(); strings.size = Vector3(0.04, 0.9, 0.04)
				_add(strings, Vector3(cos(ang) * radius, y + 0.35, sin(ang) * radius), Color(1, 0.95, 0.7), 3.0, Vector3.ONE, Vector3(rad_to_deg(ang), 0, 30))
			1:
				var drum := CylinderMesh.new(); drum.top_radius = 0.55; drum.bottom_radius = 0.55; drum.height = 0.65
				_add(drum, Vector3(cos(ang) * radius, y, sin(ang) * radius), color, 0.2)
				# Drum skin glow
				var skin := CylinderMesh.new(); skin.top_radius = 0.50; skin.bottom_radius = 0.50; skin.height = 0.05
				_add(skin, Vector3(cos(ang) * radius, y + 0.32, sin(ang) * radius), Color(0.9, 0.85, 0.65), 4.0)
			2:
				var horn := CylinderMesh.new(); horn.top_radius = 0.50; horn.bottom_radius = 0.10; horn.height = 1.2
				_add(horn, Vector3(cos(ang) * radius, y, sin(ang) * radius), color, 0.4, Vector3.ONE, Vector3(0, 0, 25))
				# Bell mouth glow
				var bell := TorusMesh.new(); bell.inner_radius = 0.40; bell.outer_radius = 0.50
				_add(bell, Vector3(cos(ang) * radius + 0.5, y + 0.25, sin(ang) * radius), color, 1.5, Vector3.ONE, Vector3(0, 0, 90))
			3:
				var box := BoxMesh.new(); box.size = Vector3(0.30, 1.2, 0.10)
				_add(box, Vector3(cos(ang) * radius, y, sin(ang) * radius), color)
	# Ghostly conductor — outlined by floating dots
	for i in 30:
		var ang := i * TAU / 30.0
		var dot := SphereMesh.new(); dot.radius = 0.04; dot.height = 0.08
		_add(dot, Vector3(cos(ang) * 0.6, 3.0 + sin(i * 0.5) * 1.5, sin(ang) * 0.6), Color(1, 0.95, 0.85), 6.0)
	# Music notes drifting up (small floating spheres)
	for i in 18:
		var note := SphereMesh.new(); note.radius = 0.06; note.height = 0.12
		_add(note, Vector3(_frng(i, -5, 5), _frng(i + 7, 1, 7), _frng(i + 11, -4, 4)), Color(1.0, 0.90, 0.65), 4.0)
	_glow_light(Vector3(0, 4, 0), Color(1, 0.85, 0.55), 5.0, 28.0)
	_glow_light(Vector3(0, 6, 0), Color(0.95, 0.80, 0.45), 3.5, 18.0)

func _that_which_dreams_us() -> void:
	# Massive closed eye + fracture rings + dreaming orbs + chromatic shells.
	var lid := SphereMesh.new(); lid.radius = 3.2; lid.height = 4.4
	_add(lid, Vector3(0, 3.0, 0), Color(0.20, 0.12, 0.30), 0.3, Vector3(1.4, 0.5, 1.4), Vector3(0, 0, 0), 0.7)
	# Inner pulse (slightly visible)
	var pulse := SphereMesh.new(); pulse.radius = 2.9; pulse.height = 4.0
	_add(pulse, Vector3(0, 3.0, 0), Color(0.55, 0.30, 0.85), 1.0, Vector3(1.4, 0.5, 1.4))
	var lash := BoxMesh.new(); lash.size = Vector3(8.5, 0.18, 0.5)
	_add(lash, Vector3(0, 3.0, 0), Color(0.05, 0.03, 0.08))
	# fracture rings (tori) at angles
	for i in 5:
		var ring := TorusMesh.new()
		ring.inner_radius = 5.0 + i * 1.2; ring.outer_radius = 5.4 + i * 1.2
		var col := Color(0.35, 0.20, 0.85).lerp(Color(0.85, 0.45, 1.0), float(i) / 5.0)
		_add(ring, Vector3(0, 3.0 + i * 0.4, 0), col, 1.2 + i * 0.3, Vector3.ONE, Vector3(70 + i * 10, i * 25, i * 5))
	# Smaller circling shards
	for i in 18:
		var ang := i * TAU / 18.0
		var shard := PrismMesh.new(); shard.size = Vector3(0.18, 0.55, 0.06)
		_add(shard, Vector3(cos(ang) * 4.5, 3.0 + sin(ang * 2) * 0.6, sin(ang) * 4.5), Color(0.65, 0.40, 1.0), 3.0, Vector3.ONE, Vector3(0, rad_to_deg(ang), _frng(i, -30, 30)))
	# distant orbs (other dreamers)
	for i in 12:
		var ang := i * TAU / 12.0
		var orb := SphereMesh.new(); orb.radius = 0.18; orb.height = 0.36
		_add(orb, Vector3(cos(ang) * 8.0, 3.0 + sin(ang * 2) * 2.0, sin(ang) * 8.0), Color(0.95, 0.85, 1.00), 5.0)
	_add_ash_particles(Vector3(0, 4, 0), Color(0.55, 0.40, 1.0, 0.6), 90)
	_glow_light(Vector3(0, 3, 0), Color(0.50, 0.25, 1.0), 7.0, 35.0)
	_glow_light(Vector3(0, 6, 4), Color(0.85, 0.45, 1.0), 4.0, 22.0)

func _add_ash_particles(pos: Vector3, color: Color, amount: int) -> void:
	var p := GPUParticles3D.new()
	p.position = pos
	p.amount = amount
	p.lifetime = 4.0
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 50.0
	pm.gravity = Vector3(0, -0.15, 0)
	pm.initial_velocity_min = 0.3
	pm.initial_velocity_max = 0.9
	pm.scale_min = 0.03; pm.scale_max = 0.10
	pm.color = color
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(6, 2, 6)
	p.process_material = pm
	var mesh := SphereMesh.new(); mesh.radius = 0.05; mesh.height = 0.1
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true; mat.emission = color
	mat.emission_energy_multiplier = 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	p.draw_pass_1 = mesh
	add_child(p)

func _frng(seed_v: int, lo: float, hi: float) -> float:
	# deterministic per-index pseudo-random.
	var s: int = (seed_v * 2654435761) & 0xFFFFFFFF
	var r: float = float(s % 10000) / 10000.0
	return lo + r * (hi - lo)
