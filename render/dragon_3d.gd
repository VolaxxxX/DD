class_name Dragon3D extends Node3D
# Massive dragon silhouette that flies across the sky during zone intro.
# One unique build per dragon id (11 entries: 5 chromatic, 5 metallic, 1 exotic).

const DRAGON_PALETTE := {
	&"cinderborn":   {"body": Color(0.85, 0.20, 0.10), "accent": Color(1.00, 0.65, 0.20), "eye": Color(1.00, 0.85, 0.30)},
	&"stormfather":  {"body": Color(0.20, 0.30, 0.85), "accent": Color(0.85, 0.95, 1.00), "eye": Color(0.65, 0.95, 1.00)},
	&"rotcrown":     {"body": Color(0.20, 0.55, 0.25), "accent": Color(0.45, 0.30, 0.15), "eye": Color(0.85, 1.00, 0.40)},
	&"mire_king":    {"body": Color(0.10, 0.10, 0.12), "accent": Color(0.30, 0.20, 0.30), "eye": Color(0.85, 0.20, 0.85)},
	&"hollowfrost":  {"body": Color(0.85, 0.92, 1.00), "accent": Color(0.55, 0.75, 1.00), "eye": Color(0.50, 0.85, 1.00)},
	&"lawbringer":   {"body": Color(0.95, 0.80, 0.30), "accent": Color(1.00, 1.00, 0.85), "eye": Color(1.00, 1.00, 0.65)},
	&"moonvowed":    {"body": Color(0.85, 0.85, 0.95), "accent": Color(0.65, 0.75, 0.95), "eye": Color(0.85, 0.95, 1.00)},
	&"tidekeeper":   {"body": Color(0.55, 0.40, 0.20), "accent": Color(0.85, 0.65, 0.30), "eye": Color(0.45, 0.85, 0.95)},
	&"silvertongue": {"body": Color(0.85, 0.65, 0.30), "accent": Color(1.00, 0.85, 0.55), "eye": Color(1.00, 0.65, 0.20)},
	&"veilstep":     {"body": Color(0.55, 0.35, 0.20), "accent": Color(0.30, 0.55, 0.45), "eye": Color(0.85, 1.00, 0.55)},
	&"unlit_wyrm":   {"body": Color(0.05, 0.02, 0.10), "accent": Color(0.20, 0.05, 0.30), "eye": Color(1.00, 0.10, 0.10)},
}

var dragon_id: StringName

func build(id: StringName) -> void:
	dragon_id = id
	for c in get_children(): c.queue_free()
	var pal: Dictionary = DRAGON_PALETTE.get(id, {"body": Color.RED, "accent": Color.WHITE, "eye": Color.YELLOW})
	_build_body(pal)
	_build_specials(id, pal)
	_glow_light(Vector3(0, 0, 0), pal.eye, 4.0, 18.0)

func _add(mesh: Mesh, pos: Vector3, color: Color, emission_e: float = 0.0, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, rough: float = 0.5) -> MeshInstance3D:
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

func _glow_light(pos: Vector3, color: Color, energy: float, range_v: float) -> void:
	var ol := OmniLight3D.new()
	ol.position = pos
	ol.light_color = color
	ol.light_energy = energy
	ol.omni_range = range_v
	add_child(ol)

func _build_body(pal: Dictionary) -> void:
	# Long sinuous serpent body (4 segments), neck, head, tail, 4 wings.
	var seg := CapsuleMesh.new(); seg.radius = 0.55; seg.height = 1.4
	for i in 4:
		var off := Vector3(-1.5 + i * 1.0, sin(i * 0.5) * 0.2, 0)
		_add(seg, off, pal.body, 0.0, Vector3.ONE, Vector3(0, 0, 90), 0.4)
	# Neck
	var neck := CylinderMesh.new(); neck.top_radius = 0.30; neck.bottom_radius = 0.50; neck.height = 1.5
	_add(neck, Vector3(2.2, 0.7, 0), pal.body, 0.0, Vector3.ONE, Vector3(0, 0, -50))
	# Head
	var head := BoxMesh.new(); head.size = Vector3(0.85, 0.55, 0.55)
	_add(head, Vector3(3.3, 1.4, 0), pal.body)
	# Jaw
	var jaw := BoxMesh.new(); jaw.size = Vector3(0.80, 0.20, 0.50)
	_add(jaw, Vector3(3.35, 1.10, 0), pal.accent)
	# Eyes
	for side in [-1, 1]:
		var eye := SphereMesh.new(); eye.radius = 0.10; eye.height = 0.20
		_add(eye, Vector3(3.55, 1.55, side * 0.18), pal.eye, 6.0)
	# Tail
	var tail := CylinderMesh.new(); tail.top_radius = 0.10; tail.bottom_radius = 0.45; tail.height = 2.4
	_add(tail, Vector3(-2.5, 0.0, 0), pal.body, 0.0, Vector3.ONE, Vector3(0, 0, -75))
	# 2 main wings
	for side in [-1, 1]:
		var wing := PrismMesh.new(); wing.size = Vector3(3.5, 2.4, 0.10)
		_add(wing, Vector3(0, 1.4, side * 0.7), pal.accent, 0.2, Vector3.ONE, Vector3(0, 90 if side > 0 else -90, 30 * side))
	# 2 secondary wings
	for side in [-1, 1]:
		var wing2 := PrismMesh.new(); wing2.size = Vector3(2.0, 1.4, 0.08)
		_add(wing2, Vector3(-1.0, 1.0, side * 0.5), pal.accent, 0.2, Vector3.ONE, Vector3(0, 90 if side > 0 else -90, 20 * side))
	# Limbs
	for off_x in [1.5, -0.5]:
		for side in [-1, 1]:
			var limb := CapsuleMesh.new(); limb.radius = 0.18; limb.height = 0.85
			_add(limb, Vector3(off_x, -0.2, side * 0.6), pal.body, 0.0, Vector3.ONE, Vector3(0, 0, side * 30))

func _build_specials(id: StringName, pal: Dictionary) -> void:
	match String(id):
		"cinderborn":
			# Embers trailing
			for i in 8:
				var ember := SphereMesh.new(); ember.radius = 0.10; ember.height = 0.20
				_add(ember, Vector3(-3.5 - i * 0.4, sin(i) * 0.4, cos(i) * 0.3), Color(1.0, 0.55, 0.20), 5.0)
		"stormfather":
			# Lightning bolts (thin tilted prisms)
			for i in 6:
				var bolt := PrismMesh.new(); bolt.size = Vector3(0.06, 1.2, 0.06)
				_add(bolt, Vector3(_pseudo(i, -3, 3), -1.5, _pseudo(i + 7, -1, 1)), Color(0.85, 0.95, 1.0), 6.0, Vector3.ONE, Vector3(0, 0, _pseudo(i + 11, -25, 25)))
		"rotcrown":
			# Crown of thorns over head
			for i in 8:
				var ang := i * TAU / 8.0
				var thorn := PrismMesh.new(); thorn.size = Vector3(0.08, 0.30, 0.08)
				_add(thorn, Vector3(3.3 + cos(ang) * 0.45, 1.85, sin(ang) * 0.45), pal.accent, 0.0, Vector3.ONE, Vector3(0, rad_to_deg(ang), 0))
		"mire_king":
			# Inky aura — cluster of black spheres
			for i in 10:
				var ang := i * TAU / 10.0
				var orb := SphereMesh.new(); orb.radius = _pseudo(i, 0.15, 0.30); orb.height = orb.radius * 2
				_add(orb, Vector3(cos(ang) * 1.6, 0.6 + sin(ang * 2) * 0.4, sin(ang) * 0.7), Color(0.10, 0.05, 0.15), 0.5)
		"hollowfrost":
			# Frost shards floating below
			for i in 8:
				var shard := PrismMesh.new(); shard.size = Vector3(0.20, 0.50, 0.05)
				_add(shard, Vector3(_pseudo(i, -2, 2), -1.5, _pseudo(i + 13, -1, 1)), pal.accent, 1.5, Vector3.ONE, Vector3(_pseudo(i, 0, 360), _pseudo(i + 5, 0, 360), 0))
		"lawbringer":
			# Halo + radiant crown
			var halo := TorusMesh.new(); halo.inner_radius = 0.55; halo.outer_radius = 0.70
			_add(halo, Vector3(3.3, 2.0, 0), Color(1.0, 1.0, 0.65), 5.0, Vector3.ONE, Vector3(90, 0, 0))
			for i in 7:
				var ang := i * TAU / 7.0
				var ray := PrismMesh.new(); ray.size = Vector3(0.06, 0.45, 0.06)
				_add(ray, Vector3(3.3 + cos(ang) * 0.65, 2.0 + sin(ang) * 0.65, 0), Color(1.0, 0.95, 0.55), 4.0)
		"moonvowed":
			# Crescent above head
			var moon := TorusMesh.new(); moon.inner_radius = 0.40; moon.outer_radius = 0.55
			_add(moon, Vector3(3.3, 2.2, 0), Color(0.85, 0.95, 1.0), 3.5, Vector3(1, 0.6, 1), Vector3(90, 0, 25))
		"tidekeeper":
			# Resonant rings
			for i in 3:
				var r := TorusMesh.new(); r.inner_radius = 0.8 + i * 0.3; r.outer_radius = 0.95 + i * 0.3
				_add(r, Vector3(3.3, 1.4, 0), pal.accent, 1.2, Vector3.ONE, Vector3(0, 0, 90))
		"silvertongue":
			# Twin tongues / smoke trails from mouth
			for i in 3:
				var trail := CylinderMesh.new(); trail.top_radius = 0.04; trail.bottom_radius = 0.10; trail.height = 0.8
				_add(trail, Vector3(4.0 + i * 0.3, 1.10 + sin(i) * 0.10, _pseudo(i, -0.15, 0.15)), pal.accent, 1.5, Vector3.ONE, Vector3(0, 0, -85))
		"veilstep":
			# Stealth wisps
			for i in 6:
				var wisp := SphereMesh.new(); wisp.radius = 0.18; wisp.height = 0.36
				_add(wisp, Vector3(_pseudo(i, -3, 3), _pseudo(i + 7, -0.5, 1.5), _pseudo(i + 11, -1, 1)), Color(0.55, 0.85, 0.65), 1.0)
		"unlit_wyrm":
			# Reality fracture rings
			for i in 3:
				var ring := TorusMesh.new(); ring.inner_radius = 1.5 + i * 0.6; ring.outer_radius = 1.7 + i * 0.6
				_add(ring, Vector3(0, 0, 0), Color(0.85, 0.10, 0.85), 2.5 + i, Vector3.ONE, Vector3(60 + i * 20, i * 30, 0))
			# Negative-space body markers
			for i in 8:
				var mark := SphereMesh.new(); mark.radius = 0.12; mark.height = 0.24
				_add(mark, Vector3(-3 + i * 1.0, _pseudo(i, -0.5, 0.5), 0), Color(1, 1, 1), 7.0)

func _pseudo(seed_v: int, lo: float, hi: float) -> float:
	var s: int = (seed_v * 2654435761) & 0xFFFFFFFF
	var r: float = float(s % 10000) / 10000.0
	return lo + r * (hi - lo)
