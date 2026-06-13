class_name Backdrop3D extends Node3D
# Atmospheric backdrop: gradient sky, fog, key+fill+rim lighting, ground.

const BIOME_SKY_TOP := {
	&"forest":    Color(0.18, 0.30, 0.32),
	&"city":      Color(0.20, 0.22, 0.30),
	&"ruins":     Color(0.32, 0.22, 0.18),
	&"corrupted": Color(0.22, 0.05, 0.20),
	&"anomaly":   Color(0.05, 0.10, 0.30),
	&"swamp":     Color(0.15, 0.20, 0.18),
	&"highland":  Color(0.30, 0.40, 0.55),
	&"crypt":     Color(0.05, 0.05, 0.08),
	&"coast":     Color(0.20, 0.30, 0.40),
}
const BIOME_SKY_HORIZON := {
	&"forest":    Color(0.78, 0.72, 0.55),
	&"city":      Color(0.55, 0.55, 0.58),
	&"ruins":     Color(0.85, 0.65, 0.45),
	&"corrupted": Color(0.55, 0.20, 0.35),
	&"anomaly":   Color(0.40, 0.30, 0.85),
	&"swamp":     Color(0.60, 0.55, 0.40),
	&"highland":  Color(0.85, 0.80, 0.75),
	&"crypt":     Color(0.20, 0.18, 0.25),
	&"coast":     Color(0.85, 0.70, 0.55),
}
const BIOME_GROUND := {
	&"forest":    Color(0.15, 0.22, 0.12),
	&"city":      Color(0.18, 0.18, 0.20),
	&"ruins":     Color(0.30, 0.25, 0.20),
	&"corrupted": Color(0.20, 0.06, 0.18),
	&"anomaly":   Color(0.08, 0.10, 0.22),
	&"swamp":     Color(0.12, 0.18, 0.10),
	&"highland":  Color(0.22, 0.25, 0.18),
	&"crypt":     Color(0.10, 0.09, 0.10),
	&"coast":     Color(0.55, 0.50, 0.40),
}
const BIOME_LIGHT_TINT := {
	&"forest":    Color(1.00, 0.96, 0.85),
	&"city":      Color(0.95, 0.95, 1.00),
	&"ruins":     Color(1.00, 0.85, 0.65),
	&"corrupted": Color(0.85, 0.70, 1.00),
	&"anomaly":   Color(0.75, 0.85, 1.00),
	&"swamp":     Color(0.80, 0.95, 0.75),
	&"highland":  Color(1.00, 0.95, 0.90),
	&"crypt":     Color(0.55, 0.55, 0.75),
	&"coast":     Color(1.00, 0.92, 0.78),
}

var ground: MeshInstance3D
var sun: DirectionalLight3D
var fill: DirectionalLight3D
var rim: DirectionalLight3D
var env: WorldEnvironment

func build(biome: StringName, corruption: float, sub_biome: int = 0) -> void:
	# Each zone gets a deterministic time-of-day so two runs in the same forest
	# feel different — bright noon vs golden dusk vs pre-dawn cold.
	_time_of_day = (Time.get_ticks_msec() / 1000) % 3
	_build_environment(biome, corruption)
	_build_ground(biome, corruption)
	_build_lights(biome, corruption)
	_apply_sub_tint(biome, sub_biome)
	_build_far_silhouettes(biome, corruption)
	_build_vegetation_field(biome, corruption)
	_build_water(biome)
	_build_signature_props(biome, corruption)
	_build_points_of_interest(biome, corruption)
	_build_weather(biome, corruption)
	_build_atmosphere(biome, corruption)
	_build_ambient_critters(biome, DRNG.new(int(Time.get_ticks_msec())))
	_build_ground_fauna(biome, DRNG.new((int(biome.hash()) >> 4) ^ 0xFA0A))

var _time_of_day: int = 0   # 0=noon, 1=dusk, 2=pre-dawn
var _nature_root: Node3D = null

func _process(_delta: float) -> void:
	# Gentle wind sway on foliage props (marked with sway_amp meta).
	if _nature_root == null or not is_instance_valid(_nature_root): return
	var t := Time.get_ticks_msec() / 1000.0
	for child in _nature_root.get_children():
		if child is Node3D and child.has_meta("sway_amp"):
			var amp: float = child.get_meta("sway_amp")
			var ph: float = child.get_meta("sway_phase")
			(child as Node3D).rotation.z = sin(t * 0.9 + ph) * amp

func _apply_sub_tint(biome: StringName, sub_biome: int) -> void:
	# Multiply the directional sun + fill light by the sub-biome tint so each
	# variant of the same biome reads differently (warmer, cooler, darker).
	var tint: Color = PropLoader.sub_tint(biome, sub_biome)
	if sun: sun.light_color = sun.light_color * tint
	if fill: fill.light_color = fill.light_color * tint

func _build_ambient_critters(biome: StringName, rng: DRNG) -> void:
	# Small genuine 3D birds (body + 2 wings + occasional beak) drifting in
	# the sky for life. No billboards — real geometry so the silhouette holds
	# from any angle.
	var n := 0
	var color := Color.WHITE
	var height_lo := 4.0
	var height_hi := 9.0
	match String(biome):
		"forest":   n = 4; color = Color(0.20, 0.18, 0.15)        # crows
		"coast":    n = 6; color = Color(0.95, 0.95, 0.95)        # gulls
		"highland": n = 4; color = Color(0.90, 0.90, 0.95)        # eagles
		"city":     n = 3; color = Color(0.15, 0.15, 0.15)
		"swamp":    n = 3; color = Color(0.55, 0.70, 0.45); height_lo = 0.5; height_hi = 3.0
		_:          return
	for i in n:
		var bird := Node3D.new()
		var x := randf_range(-20, 20)
		var z := randf_range(-15, -3)
		var y := randf_range(height_lo, height_hi)
		bird.position = Vector3(x, y, z)
		add_child(bird)
		# Body (small capsule)
		var body_m := CapsuleMesh.new()
		body_m.radius = 0.05; body_m.height = 0.18
		_ambient_part(bird, body_m, Vector3(0, 0, 0), color, Vector3(0, 0, 90))
		# Two wings (thin prisms angled outward)
		var wing := PrismMesh.new()
		wing.size = Vector3(0.20, 0.04, 0.06)
		_ambient_part(bird, wing, Vector3(0, 0.02, 0), color, Vector3(0, 0, 12))
		_ambient_part(bird, wing, Vector3(0, 0.02, 0), color, Vector3(180, 0, -12))
		# Drifting motion in a loop
		var endpoint := bird.position + Vector3(randf_range(-15, 15), randf_range(-1, 1), randf_range(-5, 5))
		var t := bird.create_tween().set_loops()
		t.tween_property(bird, "position", endpoint, randf_range(10, 18)).set_trans(Tween.TRANS_SINE)
		t.tween_property(bird, "position", bird.position, randf_range(10, 18)).set_trans(Tween.TRANS_SINE)
		# Flap the wings (subtle scale pulse).
		var flap := bird.create_tween().set_loops()
		flap.tween_property(bird, "scale", Vector3(1, 0.85, 1), 0.30).set_trans(Tween.TRANS_SINE)
		flap.tween_property(bird, "scale", Vector3(1, 1.0, 1), 0.30).set_trans(Tween.TRANS_SINE)

func _ambient_part(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rot_deg: Vector3 = Vector3.ZERO) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mi.material_override = mat
	parent.add_child(mi)

# ---------- Signature props ----------
# Big readable backdrop elements per biome — placed in the mid-ground (z<-10)
# so they fill the frame behind the action without ever obscuring mobs or UI.
func _build_signature_props(biome: StringName, corruption: float) -> void:
	var rng := DRNG.new((int(biome.hash()) >> 5) ^ 0xBE110)
	# Real Kenney Nature Kit props compose the biome's identity (low-poly,
	# one shared atlas = coherent look). Falls back to procedural shapes only
	# if the models are missing.
	if _build_nature_props(biome, corruption, rng):
		return
	match String(biome):
		"forest":     _sig_forest(rng, corruption)
		"city":       _sig_city(rng)
		"ruins":      _sig_ruins(rng)
		"corrupted":  _sig_corrupted(rng)
		"anomaly":    _sig_anomaly(rng)
		"swamp":      _sig_swamp(rng)
		"highland":   _sig_highland(rng)
		"crypt":      _sig_crypt(rng)
		"coast":      _sig_coast(rng)

# Composes the biome from real Kenney models: a ring of hero landmarks framing
# the playspace, a dense scatter of mid-props, and ground detail. Returns true
# if anything was placed. Respects the playspace exclusion so nothing covers
# the creature or the UI.
func _build_nature_props(biome: StringName, corruption: float, rng: DRNG) -> bool:
	var pool := NatureLib.pool(biome)
	var tint: Color = NatureLib.biome_tint(biome)
	tint = tint.lerp(Color(0.55, 0.2, 0.5), corruption * 0.35)
	var root := Node3D.new()
	root.name = "NatureProps"
	add_child(root)
	_nature_root = root
	var placed := 0
	# --- Hero landmarks: 10 large props in an arc behind & beside the action.
	var hero: Array = pool.get("hero", [])
	for i in 10:
		if hero.is_empty(): break
		var name: String = hero[rng.range_i(0, hero.size())]
		var n := NatureLib.instance(name, tint)
		if n == null: continue
		var xz := _nature_xz(rng, 5.0, 16.0, -16.0, -3.0)
		if xz == Vector2.INF: continue
		root.add_child(n)
		var target_h := _frng_h(rng, 3.0, 6.5)
		AssetLoader.normalize_height(n, target_h)
		n.position = Vector3(xz.x, n.position.y, xz.y)
		n.rotation.y = _frng_h(rng, 0, TAU)
		var s := _frng_h(rng, 0.85, 1.2)
		n.scale *= Vector3(s, _frng_h(rng, 0.9, 1.25), s)
		_mark_sway_if_foliage(n, name)
		placed += 1
	# --- Scatter: 16 mid-props (rocks/stumps/bushes/mushrooms) closer in.
	var scatter: Array = pool.get("scatter", [])
	for i in 16:
		if scatter.is_empty(): break
		var name: String = scatter[rng.range_i(0, scatter.size())]
		var n := NatureLib.instance(name, tint)
		if n == null: continue
		var xz := _nature_xz(rng, 2.6, 13.0, -12.0, -2.0)
		if xz == Vector2.INF: continue
		root.add_child(n)
		AssetLoader.normalize_height(n, _frng_h(rng, 0.6, 1.6))
		n.position = Vector3(xz.x, n.position.y, xz.y)
		n.rotation.y = _frng_h(rng, 0, TAU)
		_mark_sway_if_foliage(n, name)
		placed += 1
	# --- Ground detail: 22 tiny props (grass/flowers) carpeting the field.
	var ground: Array = pool.get("ground", [])
	for i in 22:
		if ground.is_empty(): break
		var name: String = ground[rng.range_i(0, ground.size())]
		var n := NatureLib.instance(name, tint)
		if n == null: continue
		var xz := _nature_xz(rng, 1.8, 12.0, -10.0, 1.0)
		if xz == Vector2.INF: continue
		root.add_child(n)
		AssetLoader.normalize_height(n, _frng_h(rng, 0.25, 0.55))
		n.position = Vector3(xz.x, n.position.y, xz.y)
		n.rotation.y = _frng_h(rng, 0, TAU)
		_mark_sway_if_foliage(n, name)
		placed += 1
	return placed > 0

# Random x/z outside the playspace (creature footprint + avatar slots + UI
# sightline). Returns Vector2.INF if no clear spot found in a few tries.
func _nature_xz(rng: DRNG, r_min: float, r_max: float, z_lo: float, z_hi: float) -> Vector2:
	for _i in 6:
		var x := _frng_h(rng, -r_max, r_max)
		var z := _frng_h(rng, z_lo, z_hi)
		# Keep the central play column clear (creature at x~0.6,z~0.4; avatars
		# flank at z~2.8). Exclude a generous front-centre box.
		if absf(x) < 2.4 and z > -2.5: continue
		if Vector2(x, z).length() < r_min: continue
		return Vector2(x, z)
	return Vector2.INF

func _mark_sway_if_foliage(n: Node3D, name: String) -> void:
	var nm := name.to_lower()
	if "tree" in nm or "bush" in nm or "grass" in nm or "plant" in nm or "flower" in nm:
		n.set_meta("sway_amp", 0.03 + randf() * 0.025)
		n.set_meta("sway_phase", randf() * TAU)

func _sig_part(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rough: float = 0.85, emit: float = 0.0, sc: Vector3 = Vector3.ONE, rot_y: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = sc
	mi.rotation.y = rot_y
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	if emit > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emit
	mi.material_override = mat
	parent.add_child(mi)
	return mi

func _sig_root() -> Node3D:
	var n := Node3D.new()
	add_child(n)
	return n

func _sig_forest(rng: DRNG, corruption: float) -> void:
	# Tall trees flanking the playspace, glowing mushrooms at the base.
	var root := _sig_root()
	var trunk_c := Color(0.20, 0.13, 0.08).lerp(Color(0.30, 0.05, 0.20), corruption * 0.5)
	var leaf_c := Color(0.16, 0.34, 0.14).lerp(Color(0.40, 0.10, 0.30), corruption * 0.5)
	for i in 8:
		var side := -1 if i % 2 == 0 else 1
		var x := float(side) * _frng_h(rng, 9.0, 16.0)
		var z := _frng_h(rng, -16.0, -6.0)
		var h := _frng_h(rng, 4.5, 7.5)
		var trunk := CylinderMesh.new(); trunk.top_radius = 0.18; trunk.bottom_radius = 0.32; trunk.height = h
		_sig_part(root, trunk, Vector3(x, h * 0.5, z), trunk_c, 0.95, 0.0, Vector3.ONE, _frng_h(rng, 0, TAU))
		# Layered canopy
		for j in 3:
			var s := _frng_h(rng, 1.4, 2.0)
			var canopy := SphereMesh.new(); canopy.radius = 1.0; canopy.height = 1.7
			var tint := leaf_c.lerp(Color(0.05, 0.10, 0.05), float(j) * 0.15)
			_sig_part(root, canopy, Vector3(x + _frng_h(rng, -0.4, 0.4), h + float(j) * 0.5, z + _frng_h(rng, -0.4, 0.4)), tint, 0.85, 0.0, Vector3(s, s * 0.85, s))
	# Glowing mushrooms
	for i in 14:
		var x := _frng_h(rng, -14, 14)
		var z := _frng_h(rng, -10, -3)
		if absf(x) < 2.5 and z > -5: continue
		var stem := CylinderMesh.new(); stem.top_radius = 0.07; stem.bottom_radius = 0.09; stem.height = _frng_h(rng, 0.3, 0.6)
		_sig_part(root, stem, Vector3(x, stem.height * 0.5, z), Color(0.85, 0.80, 0.70))
		var cap := SphereMesh.new(); cap.radius = 0.18; cap.height = 0.18
		var glow_col := Color(0.55, 0.85, 1.0) if rng.range_i(0, 2) == 0 else Color(1.0, 0.65, 0.45)
		_sig_part(root, cap, Vector3(x, stem.height + 0.05, z), glow_col, 0.4, 2.5)

func _sig_city(rng: DRNG) -> void:
	# Lamp posts with warm bulbs, low broken walls.
	var root := _sig_root()
	for i in 6:
		var side := -1 if i % 2 == 0 else 1
		var x := float(side) * _frng_h(rng, 6.0, 12.0)
		var z := _frng_h(rng, -12, -4)
		var post := CylinderMesh.new(); post.top_radius = 0.05; post.bottom_radius = 0.06; post.height = 3.0
		_sig_part(root, post, Vector3(x, 1.5, z), Color(0.18, 0.18, 0.20), 0.6)
		var arm := BoxMesh.new(); arm.size = Vector3(0.6, 0.04, 0.04)
		_sig_part(root, arm, Vector3(x - 0.30 * sign(x), 3.0, z), Color(0.18, 0.18, 0.20))
		var bulb := SphereMesh.new(); bulb.radius = 0.14; bulb.height = 0.28
		var bulb_pos := Vector3(x - 0.55 * sign(x), 2.92, z)
		_sig_part(root, bulb, bulb_pos, Color(1.0, 0.85, 0.55), 0.3, 4.0)
		# Real point light from the bulb.
		var ol := OmniLight3D.new()
		ol.position = bulb_pos
		ol.light_color = Color(1.0, 0.80, 0.50)
		ol.light_energy = 1.2
		ol.omni_range = 6.0
		root.add_child(ol)
	# Broken walls
	for i in 5:
		var wall := BoxMesh.new(); wall.size = Vector3(_frng_h(rng, 1.5, 3.0), _frng_h(rng, 1.0, 2.0), 0.25)
		var wx := _frng_h(rng, -14, 14)
		var wz := _frng_h(rng, -13, -7)
		if absf(wx) < 4 and wz > -9: continue
		_sig_part(root, wall, Vector3(wx, wall.size.y * 0.5, wz), Color(0.32, 0.28, 0.24), 0.9, 0.0, Vector3.ONE, _frng_h(rng, -0.4, 0.4))

func _sig_ruins(rng: DRNG) -> void:
	# Tall fluted columns + horizontal beams + carved capitals.
	var root := _sig_root()
	var stone := Color(0.55, 0.50, 0.40)
	for i in 7:
		var x := _frng_h(rng, -16, 16)
		var z := _frng_h(rng, -16, -7)
		if absf(x) < 3 and z > -10: continue
		var h := _frng_h(rng, 3.5, 6.5)
		var col := CylinderMesh.new(); col.top_radius = 0.32; col.bottom_radius = 0.40; col.height = h
		_sig_part(root, col, Vector3(x, h * 0.5, z), stone, 0.92)
		# Capital
		var cap := BoxMesh.new(); cap.size = Vector3(1.0, 0.25, 1.0)
		_sig_part(root, cap, Vector3(x, h + 0.13, z), stone.lightened(0.1))
		# A few have a fallen beam
		if rng.range_i(0, 2) == 0:
			var beam := BoxMesh.new(); beam.size = Vector3(2.0, 0.35, 0.45)
			_sig_part(root, beam, Vector3(x + 1.4, h - 0.6, z), stone.darkened(0.05), 0.9, 0.0, Vector3.ONE, _frng_h(rng, -0.3, 0.3))

func _sig_corrupted(rng: DRNG) -> void:
	# Pulsing crystal spires + drooping flesh-vines on the ground.
	var root := _sig_root()
	for i in 9:
		var x := _frng_h(rng, -15, 15)
		var z := _frng_h(rng, -14, -6)
		if absf(x) < 2.5 and z > -7: continue
		var spike := CylinderMesh.new(); spike.top_radius = 0.04; spike.bottom_radius = 0.35; spike.height = _frng_h(rng, 2.0, 5.5)
		_sig_part(root, spike, Vector3(x, spike.height * 0.5, z), Color(0.45, 0.10, 0.55), 0.35, 1.8)
	for i in 5:
		var orb := SphereMesh.new(); orb.radius = _frng_h(rng, 0.25, 0.45); orb.height = orb.radius * 2.0
		var x := _frng_h(rng, -10, 10)
		var z := _frng_h(rng, -10, -5)
		if absf(x) < 2 and z > -7: continue
		var orb_pos := Vector3(x, _frng_h(rng, 0.6, 1.8), z)
		var mi := _sig_part(root, orb, orb_pos, Color(1.0, 0.30, 0.85), 0.3, 3.0)
		var t := mi.create_tween().set_loops()
		t.tween_property(mi, "scale", Vector3.ONE * 1.25, 1.6).set_trans(Tween.TRANS_SINE)
		t.tween_property(mi, "scale", Vector3.ONE, 1.6).set_trans(Tween.TRANS_SINE)

func _sig_anomaly(rng: DRNG) -> void:
	# Floating monoliths suspended off the ground, slowly drifting.
	var root := _sig_root()
	for i in 6:
		var x := _frng_h(rng, -14, 14)
		var z := _frng_h(rng, -14, -6)
		if absf(x) < 3 and z > -8: continue
		var y := _frng_h(rng, 1.5, 5.5)
		var slab := BoxMesh.new(); slab.size = Vector3(_frng_h(rng, 0.8, 1.6), _frng_h(rng, 1.4, 3.0), _frng_h(rng, 0.3, 0.6))
		var mi := _sig_part(root, slab, Vector3(x, y, z), Color(0.20, 0.30, 0.65), 0.5, 0.8, Vector3.ONE, _frng_h(rng, 0, TAU))
		var t := mi.create_tween().set_loops()
		t.tween_property(mi, "position:y", y + 0.6, 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(mi, "position:y", y, 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var rot := mi.create_tween().set_loops()
		rot.tween_property(mi, "rotation:y", mi.rotation.y + TAU, 22.0)

func _sig_swamp(rng: DRNG) -> void:
	# Dead twisted trees rising from the water, hanging moss, will-o-wisp orbs.
	var root := _sig_root()
	for i in 9:
		var x := _frng_h(rng, -14, 14)
		var z := _frng_h(rng, -16, -5)
		if absf(x) < 2.5 and z > -7: continue
		var h := _frng_h(rng, 3.0, 5.5)
		var trunk := CylinderMesh.new(); trunk.top_radius = 0.10; trunk.bottom_radius = 0.30; trunk.height = h
		_sig_part(root, trunk, Vector3(x, h * 0.5, z), Color(0.13, 0.10, 0.08), 0.95, 0.0, Vector3.ONE, _frng_h(rng, -0.3, 0.3))
		# 2-3 dead branches
		for b in 3:
			var branch := CylinderMesh.new(); branch.top_radius = 0.03; branch.bottom_radius = 0.07; branch.height = _frng_h(rng, 0.8, 1.6)
			var bxp := Vector3(x + _frng_h(rng, -0.4, 0.4), h * _frng_h(rng, 0.55, 0.95), z + _frng_h(rng, -0.4, 0.4))
			var mi := _sig_part(root, branch, bxp, Color(0.18, 0.13, 0.09), 0.95)
			mi.rotation = Vector3(_frng_h(rng, -0.5, 0.5), _frng_h(rng, 0, TAU), _frng_h(rng, -0.4, 0.4) + sign(_frng_h(rng, -1, 1)) * 0.8)
	# Floating wisps
	for i in 6:
		var x := _frng_h(rng, -10, 10)
		var z := _frng_h(rng, -10, -3)
		if absf(x) < 2 and z > -6: continue
		var wisp := SphereMesh.new(); wisp.radius = 0.10; wisp.height = 0.20
		var p := Vector3(x, _frng_h(rng, 0.5, 1.6), z)
		var mi := _sig_part(root, wisp, p, Color(0.55, 1.0, 0.65), 0.3, 4.5)
		var t := mi.create_tween().set_loops()
		t.tween_property(mi, "position:y", p.y + 0.4, _frng_h(rng, 2.0, 3.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(mi, "position:y", p.y, _frng_h(rng, 2.0, 3.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _sig_highland(rng: DRNG) -> void:
	# Standing stones (menhirs), big boulders, gnarled wind-bent tree.
	var root := _sig_root()
	for i in 5:
		var x := _frng_h(rng, -12, 12)
		var z := _frng_h(rng, -14, -7)
		if absf(x) < 3 and z > -10: continue
		var h := _frng_h(rng, 2.0, 3.5)
		var stone := BoxMesh.new(); stone.size = Vector3(0.7, h, 0.5)
		_sig_part(root, stone, Vector3(x, h * 0.5, z), Color(0.42, 0.42, 0.40), 0.92, 0.0, Vector3.ONE, _frng_h(rng, 0, TAU))
	for i in 6:
		var rock := SphereMesh.new(); var r := _frng_h(rng, 0.8, 1.5)
		rock.radius = r; rock.height = r * 1.4
		var x := _frng_h(rng, -14, 14); var z := _frng_h(rng, -12, -4)
		if absf(x) < 2.5 and z > -6: continue
		_sig_part(root, rock, Vector3(x, r * 0.45, z), Color(0.38, 0.40, 0.36))
	# A windswept tree
	var trunk := CylinderMesh.new(); trunk.top_radius = 0.18; trunk.bottom_radius = 0.30; trunk.height = 2.8
	_sig_part(root, trunk, Vector3(-4.2, 1.4, -8.5), Color(0.28, 0.20, 0.13))
	var canopy := SphereMesh.new(); canopy.radius = 1.1; canopy.height = 1.2
	_sig_part(root, canopy, Vector3(-3.8, 3.0, -8.5), Color(0.25, 0.32, 0.20), 0.85, 0.0, Vector3(1.6, 0.65, 1.1))

func _sig_crypt(rng: DRNG) -> void:
	# Sarcophagi, stone arch, candle clusters with real point lights.
	var root := _sig_root()
	for i in 4:
		var sarco := BoxMesh.new(); sarco.size = Vector3(0.8, 0.7, 1.9)
		var x := _frng_h(rng, -9, 9); var z := _frng_h(rng, -11, -5)
		if absf(x) < 2.5 and z > -7: continue
		_sig_part(root, sarco, Vector3(x, 0.35, z), Color(0.28, 0.26, 0.24), 0.9, 0.0, Vector3.ONE, _frng_h(rng, -0.2, 0.2))
		var lid := BoxMesh.new(); lid.size = Vector3(0.85, 0.10, 2.0)
		_sig_part(root, lid, Vector3(x, 0.72, z), Color(0.32, 0.30, 0.28))
	# Stone arch
	var arch_l := BoxMesh.new(); arch_l.size = Vector3(0.45, 3.5, 0.45)
	_sig_part(root, arch_l, Vector3(-2.2, 1.75, -7), Color(0.22, 0.20, 0.20))
	_sig_part(root, arch_l, Vector3(2.2, 1.75, -7), Color(0.22, 0.20, 0.20))
	var arch_top := BoxMesh.new(); arch_top.size = Vector3(4.85, 0.5, 0.45)
	_sig_part(root, arch_top, Vector3(0, 3.75, -7), Color(0.22, 0.20, 0.20))
	# Candles with real flickering point lights
	for i in 5:
		var cx := _frng_h(rng, -7, 7); var cz := _frng_h(rng, -8, -3)
		if absf(cx) < 1.5 and cz > -5: continue
		var candle := CylinderMesh.new(); candle.top_radius = 0.05; candle.bottom_radius = 0.05; candle.height = 0.4
		_sig_part(root, candle, Vector3(cx, 0.2, cz), Color(0.92, 0.86, 0.70))
		var flame := SphereMesh.new(); flame.radius = 0.07; flame.height = 0.14
		_sig_part(root, flame, Vector3(cx, 0.46, cz), Color(1.0, 0.6, 0.25), 0.3, 5.0)
		var ol := OmniLight3D.new()
		ol.position = Vector3(cx, 0.7, cz)
		ol.light_color = Color(1.0, 0.65, 0.30)
		ol.light_energy = 0.9
		ol.omni_range = 3.5
		root.add_child(ol)
		# Flicker
		var t := ol.create_tween().set_loops()
		t.tween_property(ol, "light_energy", 0.65, _frng_h(rng, 0.12, 0.25))
		t.tween_property(ol, "light_energy", 1.05, _frng_h(rng, 0.12, 0.25))
		t.tween_property(ol, "light_energy", 0.85, _frng_h(rng, 0.12, 0.25))

func _sig_coast(rng: DRNG) -> void:
	# Wave-worn rocks at the water line + driftwood logs + a few seashells.
	var root := _sig_root()
	for i in 6:
		var r := _frng_h(rng, 0.7, 1.5)
		var rock := SphereMesh.new(); rock.radius = r; rock.height = r * 1.2
		var x := _frng_h(rng, -14, 14); var z := _frng_h(rng, -10, -4)
		if absf(x) < 2.5 and z > -6: continue
		_sig_part(root, rock, Vector3(x, r * 0.35, z), Color(0.32, 0.32, 0.34), 0.85, 0.0, Vector3(1.2, 0.7, 1.0))
	for i in 4:
		var log := CylinderMesh.new(); log.top_radius = 0.12; log.bottom_radius = 0.14; log.height = _frng_h(rng, 1.4, 2.4)
		var x := _frng_h(rng, -10, 10); var z := _frng_h(rng, -7, -3)
		if absf(x) < 2 and z > -5: continue
		_sig_part(root, log, Vector3(x, 0.12, z), Color(0.42, 0.30, 0.20), 0.95, 0.0, Vector3.ONE, _frng_h(rng, 0, TAU)).rotation.z = 1.57
	for i in 7:
		var shell := SphereMesh.new(); shell.radius = 0.08; shell.height = 0.10
		var x := _frng_h(rng, -10, 10); var z := _frng_h(rng, -6, -3)
		if absf(x) < 2 and z > -5: continue
		_sig_part(root, shell, Vector3(x, 0.04, z), Color(0.95, 0.88, 0.78), 0.4)

# ---------- Weather ----------
# Per-biome weather particles layered over the whole stage. GPU particles,
# unshaded materials — cheap on mobile.
func _build_weather(biome: StringName, corruption: float) -> void:
	match String(biome):
		"swamp":
			_weather_rain(420, Color(0.65, 0.75, 0.80, 0.55))
		"highland":
			_weather_snow(280)
		"corrupted":
			_weather_ash(220, corruption)
		"coast":
			_weather_rain(120, Color(0.80, 0.88, 0.92, 0.30))   # light sea drizzle
		_:
			pass

func _weather_emitter(amount: int, lifetime: float) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.fixed_fps = 30
	p.position = Vector3(0, 9.0, -3)
	add_child(p)
	return p

func _weather_rain(amount: int, tint: Color) -> void:
	var p := _weather_emitter(amount, 1.1)
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0.08, -1, 0)
	pm.spread = 2.0
	pm.gravity = Vector3(0, -14.0, 0)
	pm.initial_velocity_min = 7.0
	pm.initial_velocity_max = 9.0
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(16, 0.5, 11)
	p.process_material = pm
	# Long thin streak so motion reads as rain, not dots.
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.012, 0.42, 0.012)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	p.draw_pass_1 = mesh

func _weather_snow(amount: int) -> void:
	var p := _weather_emitter(amount, 7.0)
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 12.0
	pm.gravity = Vector3(0.25, -0.85, 0)
	pm.initial_velocity_min = 0.3
	pm.initial_velocity_max = 0.8
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(16, 0.5, 11)
	# Lateral drift wobble.
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.35
	pm.turbulence_noise_scale = 1.6
	p.process_material = pm
	var mesh := SphereMesh.new()
	mesh.radius = 0.025
	mesh.height = 0.05
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.96, 1.0, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	p.draw_pass_1 = mesh

func _weather_ash(amount: int, corruption: float) -> void:
	var p := _weather_emitter(amount, 9.0)
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 20.0
	pm.gravity = Vector3(-0.15, -0.35, 0)
	pm.initial_velocity_min = 0.15
	pm.initial_velocity_max = 0.5
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(16, 0.5, 11)
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.6
	pm.turbulence_noise_scale = 1.2
	p.process_material = pm
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.004)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.18, 0.20, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# A fraction of flakes still glow as embers, scaled by corruption.
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.35, 0.15)
	mat.emission_energy_multiplier = 0.35 + corruption * 0.5
	mesh.material = mat
	p.draw_pass_1 = mesh

# ---------- Water ----------
# Biome-appropriate water bodies with a scrolling noise normal so the surface
# genuinely moves and catches the sky. Positions avoid the playspace.
func _build_water(biome: StringName) -> void:
	match String(biome):
		"swamp":
			_water_plane(Vector3(0, 0.035, -8), Vector2(60, 26), Color(0.08, 0.16, 0.12, 0.92), 0.45)
		"coast":
			_water_plane(Vector3(0, 0.03, -20), Vector2(90, 28), Color(0.10, 0.28, 0.38, 0.95), 0.25)
		"forest":
			_water_disc(Vector3(7.5, 0.03, -8.5), 3.6, Color(0.10, 0.22, 0.24, 0.92))
		"highland":
			_water_disc(Vector3(-8.5, 0.03, -10.0), 3.0, Color(0.12, 0.24, 0.34, 0.95))
		"city":
			_water_disc(Vector3(5.5, 0.02, -5.5), 1.1, Color(0.14, 0.16, 0.20, 0.85))
			_water_disc(Vector3(-6.5, 0.02, -7.5), 0.8, Color(0.14, 0.16, 0.20, 0.85))
		"ruins":
			_water_disc(Vector3(-6.0, 0.02, -6.0), 1.4, Color(0.16, 0.18, 0.16, 0.85))
		_:
			pass

func _water_material(tint: Color, rough: float = 0.10) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = tint
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.metallic = 0.85
	m.metallic_specular = 0.9
	m.roughness = rough
	var n := FastNoiseLite.new()
	n.seed = 4242
	n.frequency = 0.06
	n.fractal_octaves = 4
	var nt := NoiseTexture2D.new()
	nt.noise = n
	nt.width = 256; nt.height = 256
	nt.seamless = true
	nt.as_normal_map = true
	nt.bump_strength = 3.0
	m.normal_enabled = true
	m.normal_texture = nt
	m.normal_scale = 0.5
	m.uv1_scale = Vector3(8, 8, 8)
	return m

func _animate_water(mat: StandardMaterial3D) -> void:
	# Endless slow normal-map drift = living surface.
	var t := create_tween().set_loops()
	t.tween_property(mat, "uv1_offset", Vector3(1, 0.6, 0), 24.0).from(Vector3.ZERO)

func _water_plane(pos: Vector3, size: Vector2, tint: Color, rough: float) -> void:
	var mi := MeshInstance3D.new()
	var p := PlaneMesh.new()
	p.size = size
	mi.mesh = p
	mi.position = pos
	var mat := _water_material(tint, rough)
	mi.material_override = mat
	add_child(mi)
	_animate_water(mat)

func _water_disc(pos: Vector3, radius: float, tint: Color) -> void:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = 0.012
	mi.mesh = c
	mi.position = pos
	var mat := _water_material(tint)
	mi.material_override = mat
	add_child(mi)
	_animate_water(mat)

# ---------- Ground fauna ----------
# Tiny biome-appropriate animals living in the mid-ground. Pure primitives +
# looping tweens; never enters the playspace.
func _build_ground_fauna(biome: StringName, rng: DRNG) -> void:
	match String(biome):
		"forest":
			_fauna_rabbit(Vector3(6.0, 0, -6.5))
			_fauna_rabbit(Vector3(-7.5, 0, -8.0))
			_fauna_deer(Vector3(-11.0, 0, -11.0))
			for i in 4:
				_fauna_butterfly(Vector3(_frng_h(rng, -9, 9), _frng_h(rng, 0.5, 1.6), _frng_h(rng, -8, -3)))
		"coast":
			for i in 3:
				_fauna_crab(Vector3(4.0 + float(i) * 2.6, 0, -5.0 - float(i) * 1.2))
			_fauna_fish_jumper(Vector3(-6.0, 0.0, -18.0))
			_fauna_fish_jumper(Vector3(7.0, 0.0, -19.0))
		"city":
			for i in 3:
				_fauna_rat(Vector3(-5.0 - float(i) * 2.0, 0, -5.0 - float(i)))
			_fauna_pigeon(Vector3(5.5, 0, -6.0))
			_fauna_pigeon(Vector3(-4.0, 0, -9.0))
		"crypt":
			for i in 3:
				_fauna_rat(Vector3(-5.0 - float(i) * 2.0, 0, -5.0 - float(i)))
			for i in 3:
				_fauna_bat(Vector3(_frng_h(rng, -7, 7), _frng_h(rng, 2.2, 3.8), _frng_h(rng, -9, -4)))
		"swamp":
			_fauna_frog(Vector3(5.5, 0.06, -6.0))
			_fauna_frog(Vector3(-6.0, 0.06, -7.5))
			for i in 3:
				_fauna_dragonfly(Vector3(_frng_h(rng, -8, 8), _frng_h(rng, 0.6, 1.4), _frng_h(rng, -9, -4)))
			_fauna_fish_jumper(Vector3(4.0, 0.0, -9.0))
		"highland":
			_fauna_goat(Vector3(8.0, 0, -9.0))
			_fauna_goat(Vector3(-9.5, 0, -10.5))
			for i in 3:
				_fauna_butterfly(Vector3(_frng_h(rng, -8, 8), _frng_h(rng, 0.4, 1.2), _frng_h(rng, -7, -3)))
		"ruins":
			_fauna_lizard(Vector3(5.0, 0, -5.5))
			_fauna_lizard(Vector3(-6.5, 0, -7.0))
			for i in 2:
				_fauna_bat(Vector3(_frng_h(rng, -7, 7), _frng_h(rng, 2.5, 4.0), _frng_h(rng, -10, -6)))
		"corrupted":
			for i in 2:
				_fauna_tendril_bug(Vector3(-5.0 + float(i) * 10.0, 0, -7.0))
			for i in 3:
				_fauna_butterfly(Vector3(_frng_h(rng, -8, 8), _frng_h(rng, 0.6, 1.8), _frng_h(rng, -8, -4)), Color(0.85, 0.25, 0.75))
		"anomaly":
			for i in 3:
				_fauna_orbiting_shard(Vector3(_frng_h(rng, -9, 9), _frng_h(rng, 1.0, 2.4), _frng_h(rng, -10, -5)))
			for i in 2:
				_fauna_jellyfish(Vector3(_frng_h(rng, -8, 8), _frng_h(rng, 1.5, 3.0), _frng_h(rng, -9, -5)))

func _fauna_body(pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	add_child(n)
	return n

func _fauna_rabbit(pos: Vector3) -> void:
	var r := _fauna_body(pos)
	var fur := Color(0.55, 0.48, 0.40)
	var body := SphereMesh.new(); body.radius = 0.10; body.height = 0.16
	_ambient_part(r, body, Vector3(0, 0.10, 0), fur)
	var head := SphereMesh.new(); head.radius = 0.06; head.height = 0.11
	_ambient_part(r, head, Vector3(0.09, 0.17, 0), fur)
	var ear := CapsuleMesh.new(); ear.radius = 0.012; ear.height = 0.10
	_ambient_part(r, ear, Vector3(0.08, 0.26, 0.02), fur)
	_ambient_part(r, ear, Vector3(0.08, 0.26, -0.02), fur)
	# Hop loop: two quick hops, pause, turn.
	var t := r.create_tween().set_loops()
	for hop in 2:
		t.tween_property(r, "position", r.position + Vector3(0.35, 0, 0).rotated(Vector3.UP, r.rotation.y), 0.28).set_trans(Tween.TRANS_SINE)
		t.parallel().tween_property(r, "position:y", 0.16, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.tween_property(r, "position:y", pos.y, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_interval(2.2)
	t.tween_property(r, "rotation:y", PI, 0.4)
	for hop in 2:
		t.tween_property(r, "position", pos, 0.28).set_trans(Tween.TRANS_SINE)
		t.parallel().tween_property(r, "position:y", 0.16, 0.14)
		t.tween_property(r, "position:y", pos.y, 0.14)
	t.tween_interval(2.8)
	t.tween_property(r, "rotation:y", 0.0, 0.4)

func _fauna_deer(pos: Vector3) -> void:
	var d := _fauna_body(pos)
	var coat := Color(0.42, 0.30, 0.20)
	var body := CapsuleMesh.new(); body.radius = 0.16; body.height = 0.65
	_ambient_part(d, body, Vector3(0, 0.55, 0), coat, Vector3(0, 0, 90))
	var neck := CapsuleMesh.new(); neck.radius = 0.05; neck.height = 0.35
	_ambient_part(d, neck, Vector3(0.30, 0.75, 0), coat, Vector3(0, 0, -30))
	var head := BoxMesh.new(); head.size = Vector3(0.18, 0.08, 0.08)
	_ambient_part(d, head, Vector3(0.42, 0.92, 0), coat)
	for s in [-1, 1]:
		var leg := CylinderMesh.new(); leg.top_radius = 0.025; leg.bottom_radius = 0.02; leg.height = 0.45
		_ambient_part(d, leg, Vector3(0.18, 0.23, 0.08 * s), coat.darkened(0.2))
		_ambient_part(d, leg, Vector3(-0.18, 0.23, 0.08 * s), coat.darkened(0.2))
	# Graze loop: head dips, slow steps.
	var t := d.create_tween().set_loops()
	t.tween_property(d, "rotation:x", 0.12, 1.6).set_trans(Tween.TRANS_SINE)
	t.tween_interval(2.0)
	t.tween_property(d, "rotation:x", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	t.tween_property(d, "position", pos + Vector3(0.8, 0, 0.5), 3.0).set_trans(Tween.TRANS_SINE)
	t.tween_interval(1.5)
	t.tween_property(d, "position", pos, 3.0).set_trans(Tween.TRANS_SINE)

func _fauna_crab(pos: Vector3) -> void:
	var c := _fauna_body(pos)
	var shell := Color(0.75, 0.35, 0.25)
	var body := SphereMesh.new(); body.radius = 0.08; body.height = 0.09
	_ambient_part(c, body, Vector3(0, 0.05, 0), shell)
	var claw := SphereMesh.new(); claw.radius = 0.03; claw.height = 0.05
	_ambient_part(c, claw, Vector3(0.09, 0.04, 0.05), shell.lightened(0.1))
	_ambient_part(c, claw, Vector3(0.09, 0.04, -0.05), shell.lightened(0.1))
	# Sideways scuttle dash-pause.
	var t := c.create_tween().set_loops()
	t.tween_property(c, "position:z", pos.z + 0.9, 0.6).set_trans(Tween.TRANS_QUAD)
	t.tween_interval(1.4)
	t.tween_property(c, "position:z", pos.z, 0.6).set_trans(Tween.TRANS_QUAD)
	t.tween_interval(2.0)

func _fauna_rat(pos: Vector3) -> void:
	var r := _fauna_body(pos)
	var fur := Color(0.25, 0.23, 0.22)
	var body := CapsuleMesh.new(); body.radius = 0.045; body.height = 0.16
	_ambient_part(r, body, Vector3(0, 0.045, 0), fur, Vector3(0, 0, 90))
	var tail := CylinderMesh.new(); tail.top_radius = 0.006; tail.bottom_radius = 0.012; tail.height = 0.14
	_ambient_part(r, tail, Vector3(-0.12, 0.03, 0), fur.lightened(0.2), Vector3(0, 0, -80))
	# Nervous dashes between two points.
	var t := r.create_tween().set_loops()
	t.tween_property(r, "position", pos + Vector3(1.4, 0, 0.6), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.8)
	t.tween_property(r, "position", pos, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_interval(2.6)

func _fauna_frog(pos: Vector3) -> void:
	var f := _fauna_body(pos)
	var skin := Color(0.25, 0.45, 0.20)
	var body := SphereMesh.new(); body.radius = 0.06; body.height = 0.08
	_ambient_part(f, body, Vector3(0, 0.04, 0), skin)
	var eye := SphereMesh.new(); eye.radius = 0.015; eye.height = 0.03
	_ambient_part(f, eye, Vector3(0.04, 0.09, 0.025), Color(0.9, 0.9, 0.5))
	_ambient_part(f, eye, Vector3(0.04, 0.09, -0.025), Color(0.9, 0.9, 0.5))
	# Throat pulse + occasional hop.
	var t := f.create_tween().set_loops()
	t.tween_property(f, "scale", Vector3(1.06, 0.95, 1.06), 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property(f, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_interval(1.2)
	t.tween_property(f, "position", pos + Vector3(0.4, 0, 0.2), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_interval(2.4)
	t.tween_property(f, "position", pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.6)

func _fauna_dragonfly(pos: Vector3) -> void:
	var d := _fauna_body(pos)
	var body := CapsuleMesh.new(); body.radius = 0.012; body.height = 0.10
	_ambient_part(d, body, Vector3.ZERO, Color(0.20, 0.55, 0.65), Vector3(0, 0, 90))
	var wing := BoxMesh.new(); wing.size = Vector3(0.06, 0.004, 0.025)
	_ambient_part(d, wing, Vector3(0.01, 0.012, 0.03), Color(0.85, 0.92, 0.95, 0.7))
	_ambient_part(d, wing, Vector3(0.01, 0.012, -0.03), Color(0.85, 0.92, 0.95, 0.7))
	var t := d.create_tween().set_loops()
	var p2 := pos + Vector3(randf_range(-1.5, 1.5), randf_range(-0.3, 0.4), randf_range(-1.0, 1.0))
	t.tween_property(d, "position", p2, randf_range(1.2, 2.0)).set_trans(Tween.TRANS_SINE)
	t.tween_property(d, "position", pos, randf_range(1.2, 2.0)).set_trans(Tween.TRANS_SINE)

func _fauna_goat(pos: Vector3) -> void:
	var g := _fauna_body(pos)
	var coat := Color(0.80, 0.78, 0.72)
	var body := CapsuleMesh.new(); body.radius = 0.12; body.height = 0.45
	_ambient_part(g, body, Vector3(0, 0.38, 0), coat, Vector3(0, 0, 90))
	var head := BoxMesh.new(); head.size = Vector3(0.14, 0.10, 0.08)
	_ambient_part(g, head, Vector3(0.26, 0.50, 0), coat)
	var horn := CylinderMesh.new(); horn.top_radius = 0.005; horn.bottom_radius = 0.015; horn.height = 0.08
	_ambient_part(g, horn, Vector3(0.24, 0.58, 0.03), Color(0.45, 0.40, 0.32), Vector3(0, 0, -25))
	_ambient_part(g, horn, Vector3(0.24, 0.58, -0.03), Color(0.45, 0.40, 0.32), Vector3(0, 0, -25))
	for s in [-1, 1]:
		var leg := CylinderMesh.new(); leg.top_radius = 0.02; leg.bottom_radius = 0.018; leg.height = 0.32
		_ambient_part(g, leg, Vector3(0.12, 0.16, 0.06 * s), coat.darkened(0.15))
		_ambient_part(g, leg, Vector3(-0.12, 0.16, 0.06 * s), coat.darkened(0.15))
	var t := g.create_tween().set_loops()
	t.tween_property(g, "rotation:x", 0.18, 1.4).set_trans(Tween.TRANS_SINE)
	t.tween_interval(2.4)
	t.tween_property(g, "rotation:x", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	t.tween_interval(3.0)

func _fauna_lizard(pos: Vector3) -> void:
	var l := _fauna_body(pos)
	var skin := Color(0.45, 0.42, 0.28)
	var body := CapsuleMesh.new(); body.radius = 0.025; body.height = 0.14
	_ambient_part(l, body, Vector3(0, 0.02, 0), skin, Vector3(0, 0, 90))
	var tail := CylinderMesh.new(); tail.top_radius = 0.004; tail.bottom_radius = 0.012; tail.height = 0.10
	_ambient_part(l, tail, Vector3(-0.10, 0.02, 0), skin, Vector3(0, 0, -90))
	# Bask motionless, then dart.
	var t := l.create_tween().set_loops()
	t.tween_interval(3.2)
	t.tween_property(l, "position", pos + Vector3(1.0, 0, -0.4), 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_interval(2.4)
	t.tween_property(l, "position", pos, 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _fauna_tendril_bug(pos: Vector3) -> void:
	var b := _fauna_body(pos)
	for i in 4:
		var seg := SphereMesh.new(); seg.radius = 0.05 - float(i) * 0.008; seg.height = seg.radius * 2.0
		_ambient_part(b, seg, Vector3(-float(i) * 0.07, 0.05, 0), Color(0.45, 0.12, 0.40))
	var t := b.create_tween().set_loops()
	t.tween_property(b, "position", pos + Vector3(0.9, 0, 0.5), 2.6).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(b, "scale", Vector3(1.1, 0.9, 1.1), 1.3)
	t.tween_property(b, "position", pos, 2.6).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(b, "scale", Vector3.ONE, 1.3)

func _fauna_butterfly(pos: Vector3, tint: Color = Color(0.95, 0.75, 0.35)) -> void:
	var b := _fauna_body(pos)
	var wing := BoxMesh.new(); wing.size = Vector3(0.07, 0.005, 0.05)
	_ambient_part(b, wing, Vector3(0.035, 0, 0), tint)
	_ambient_part(b, wing, Vector3(-0.035, 0, 0), tint.lightened(0.15))
	# Wing flutter: rapid scale flap.
	var flap := b.create_tween().set_loops()
	flap.tween_property(b, "scale", Vector3(0.4, 1, 1), 0.09).set_trans(Tween.TRANS_SINE)
	flap.tween_property(b, "scale", Vector3.ONE, 0.09).set_trans(Tween.TRANS_SINE)
	# Erratic wandering path.
	var path := b.create_tween().set_loops()
	for i in 4:
		var nxt := pos + Vector3(randf_range(-1.8, 1.8), randf_range(-0.4, 0.6), randf_range(-1.2, 1.2))
		path.tween_property(b, "position", nxt, randf_range(1.4, 2.4)).set_trans(Tween.TRANS_SINE)
	path.tween_property(b, "position", pos, randf_range(1.4, 2.2)).set_trans(Tween.TRANS_SINE)

func _fauna_bat(pos: Vector3) -> void:
	var b := _fauna_body(pos)
	var body := SphereMesh.new(); body.radius = 0.035; body.height = 0.06
	_ambient_part(b, body, Vector3.ZERO, Color(0.12, 0.10, 0.12))
	var wing := PrismMesh.new(); wing.size = Vector3(0.16, 0.03, 0.06)
	_ambient_part(b, wing, Vector3(0.09, 0, 0), Color(0.15, 0.12, 0.15))
	_ambient_part(b, wing, Vector3(-0.09, 0, 0), Color(0.15, 0.12, 0.15))
	# Jittery circular flight.
	var t := b.create_tween().set_loops()
	var r := randf_range(1.2, 2.2)
	var dur := randf_range(2.6, 3.8)
	for i in 4:
		var ang := TAU * float(i + 1) / 4.0
		t.tween_property(b, "position", pos + Vector3(cos(ang) * r, sin(ang * 2.0) * 0.4, sin(ang) * r), dur / 4.0).set_trans(Tween.TRANS_SINE)
	var flap := b.create_tween().set_loops()
	flap.tween_property(b, "scale", Vector3(0.55, 1, 1), 0.07)
	flap.tween_property(b, "scale", Vector3.ONE, 0.07)

func _fauna_pigeon(pos: Vector3) -> void:
	var p := _fauna_body(pos)
	var grey := Color(0.55, 0.55, 0.60)
	var body := SphereMesh.new(); body.radius = 0.06; body.height = 0.10
	_ambient_part(p, body, Vector3(0, 0.06, 0), grey)
	var head := SphereMesh.new(); head.radius = 0.03; head.height = 0.055
	_ambient_part(p, head, Vector3(0.055, 0.11, 0), Color(0.35, 0.40, 0.50))
	# Peck-walk loop: small forward steps with head bobs, then a startled hop.
	var t := p.create_tween().set_loops()
	for i in 3:
		t.tween_property(p, "position", pos + Vector3(0.18 * float(i + 1), 0, 0.06 * float(i)), 0.45)
		t.tween_property(p, "rotation:x", 0.35, 0.18)
		t.tween_property(p, "rotation:x", 0.0, 0.18)
	t.tween_interval(1.2)
	t.tween_property(p, "position:y", 0.35, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(p, "position", pos, 0.4)
	t.tween_property(p, "position:y", pos.y, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_interval(1.8)

func _fauna_fish_jumper(pos: Vector3) -> void:
	# Periodic silver arc out of the water with a splash mote at re-entry.
	var f := _fauna_body(pos)
	var fish := CapsuleMesh.new(); fish.radius = 0.04; fish.height = 0.22
	_ambient_part(f, fish, Vector3.ZERO, Color(0.75, 0.82, 0.88), Vector3(0, 0, 55))
	f.position.y = -0.4   # hidden under water between jumps
	var t := f.create_tween().set_loops()
	t.tween_interval(randf_range(3.0, 6.0))
	# Arc up + flip
	t.tween_property(f, "position:y", pos.y + 1.1, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(f, "position:x", pos.x + 0.8, 0.9)
	t.parallel().tween_property(f, "rotation:z", -2.6, 0.9)
	t.tween_property(f, "position:y", -0.4, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Reset for next leap
	t.tween_callback(func():
		if is_instance_valid(f):
			f.position = pos + Vector3(randf_range(-1.0, 1.0), -0.4, randf_range(-0.5, 0.5))
			f.rotation.z = 0.0)

func _fauna_jellyfish(pos: Vector3) -> void:
	# Anomaly: translucent bell drifting through the air, pulsing as it rises.
	var j := _fauna_body(pos)
	var bell := SphereMesh.new(); bell.radius = 0.18; bell.height = 0.22
	_ambient_part(j, bell, Vector3.ZERO, Color(0.55, 0.75, 1.0))
	for i in 4:
		var ang := TAU * float(i) / 4.0
		var tent := CylinderMesh.new(); tent.top_radius = 0.008; tent.bottom_radius = 0.015; tent.height = 0.30
		_ambient_part(j, tent, Vector3(cos(ang) * 0.08, -0.22, sin(ang) * 0.08), Color(0.65, 0.80, 1.0))
	var pulse := j.create_tween().set_loops()
	pulse.tween_property(j, "scale", Vector3(1.15, 0.85, 1.15), 0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(j, "scale", Vector3.ONE, 0.9).set_trans(Tween.TRANS_SINE)
	var drift := j.create_tween().set_loops()
	drift.tween_property(j, "position", pos + Vector3(randf_range(-1.5, 1.5), 0.8, randf_range(-1, 1)), 4.0).set_trans(Tween.TRANS_SINE)
	drift.tween_property(j, "position", pos, 4.0).set_trans(Tween.TRANS_SINE)

func _fauna_orbiting_shard(pos: Vector3) -> void:
	var s := _fauna_body(pos)
	var shard := PrismMesh.new(); shard.size = Vector3(0.10, 0.22, 0.06)
	_ambient_part(s, shard, Vector3.ZERO, Color(0.55, 0.70, 1.0))
	var t := s.create_tween().set_loops()
	t.tween_property(s, "rotation:y", TAU, 7.0)
	var bob := s.create_tween().set_loops()
	bob.tween_property(s, "position:y", pos.y + 0.4, 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(s, "position:y", pos.y, 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Dense low-cost vegetation/debris field via MultiMesh — hundreds of small
# blades/pebbles filling the ground plane so it never reads as an empty mat.
# Kept low (<0.45m) and outside the central creature footprint, so it adds
# life without hiding mobs or UI.
func _build_vegetation_field(biome: StringName, corruption: float) -> void:
	var rng := DRNG.new((int(biome.hash()) >> 2) ^ 0xF1E1D)
	var count := 620
	var base_col: Color
	var tip_col: Color
	var blade := true              # blade=true: thin box; false: pebble sphere
	match String(biome):
		"forest":    base_col = Color(0.16, 0.34, 0.12); tip_col = Color(0.38, 0.55, 0.20)
		"highland":  base_col = Color(0.25, 0.36, 0.16); tip_col = Color(0.55, 0.55, 0.30)
		"swamp":     base_col = Color(0.10, 0.26, 0.14); tip_col = Color(0.30, 0.45, 0.22); count = 480
		"coast":     base_col = Color(0.55, 0.50, 0.32); tip_col = Color(0.72, 0.68, 0.45); count = 340
		"corrupted": base_col = Color(0.28, 0.08, 0.26); tip_col = Color(0.65, 0.20, 0.55); count = 440
		"city":      base_col = Color(0.24, 0.24, 0.26); tip_col = Color(0.38, 0.38, 0.40); blade = false; count = 380
		"ruins":     base_col = Color(0.38, 0.34, 0.26); tip_col = Color(0.55, 0.50, 0.38); blade = false; count = 400
		"crypt":     base_col = Color(0.14, 0.13, 0.15); tip_col = Color(0.26, 0.24, 0.28); blade = false; count = 320
		"anomaly":   base_col = Color(0.12, 0.16, 0.38); tip_col = Color(0.35, 0.45, 0.95); count = 360
		_:           base_col = Color(0.2, 0.3, 0.15); tip_col = Color(0.4, 0.5, 0.25)
	base_col = base_col.lerp(Color(0.25, 0.06, 0.22), corruption * 0.35)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var mesh: Mesh
	if blade:
		var b := BoxMesh.new()
		b.size = Vector3(0.05, 0.34, 0.05)
		mesh = b
	else:
		var s := SphereMesh.new()
		s.radius = 0.09; s.height = 0.13
		mesh = s
	var mat := StandardMaterial3D.new()
	mat.albedo_color = base_col.lerp(tip_col, 0.45)
	mat.roughness = 0.95
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mesh.surface_set_material(0, mat)
	mm.mesh = mesh
	mm.instance_count = count
	var placed := 0
	var guard := 0
	while placed < count and guard < count * 4:
		guard += 1
		var x := _frng_h(rng, -28, 28)
		var z := _frng_h(rng, -24, 5)
		# Keep the creature footprint + avatar slots visually clean.
		if absf(x) < 1.6 and z > -3.0: continue
		var sc := _frng_h(rng, 0.6, 1.5)
		var basis := Basis(Vector3.UP, _frng_h(rng, 0, TAU)).scaled(Vector3(sc, sc * _frng_h(rng, 0.7, 1.4), sc))
		# Lean blades slightly for a wind-combed look.
		if blade:
			basis = basis.rotated(Vector3(1, 0, 0).normalized(), _frng_h(rng, -0.12, 0.12))
		var y := 0.0 if blade else 0.04
		mm.set_instance_transform(placed, Transform3D(basis, Vector3(x, y, z - 2.0)))
		placed += 1
	mm.instance_count = placed
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)

# A single huge, biome-defining landmark far on the horizon — something to
# travel toward. Tinted into the atmosphere so it reads as distant, never
# blocking the action. Built from real Kenney models scaled up where it fits,
# or a distinctive procedural silhouette.
func _build_points_of_interest(biome: StringName, corruption: float) -> void:
	var rng := DRNG.new((int(biome.hash()) >> 6) ^ 0x901)
	var horizon: Color = BIOME_SKY_HORIZON.get(biome, Color(0.6, 0.6, 0.6))
	# POI colour: dark, pushed toward the horizon haze (aerial perspective).
	var col := Color(0.2, 0.22, 0.28).lerp(horizon, 0.4).lerp(Color(0.18, 0.05, 0.2), corruption * 0.35)
	var root := Node3D.new()
	root.name = "POI"
	add_child(root)
	# Place the landmark off-centre on the horizon so the centre stays open.
	var side := -1.0 if rng.range_i(0, 2) == 0 else 1.0
	var base_pos := Vector3(side * _frng_h(rng, 8.0, 16.0), 0, -_frng_h(rng, 48.0, 62.0))
	match String(biome):
		"forest":
			# A colossal world-tree towering over the canopy.
			var t := NatureLib.instance("tree_oak", col)
			if t: root.add_child(t); AssetLoader.normalize_height(t, 30.0); t.position = base_pos
		"swamp":
			var t := NatureLib.instance("tree_oak_dark", col)
			if t: root.add_child(t); AssetLoader.normalize_height(t, 26.0); t.position = base_pos
		"ruins":
			# A great broken obelisk + flanking columns.
			var o := NatureLib.instance("statue_obelisk", col)
			if o: root.add_child(o); AssetLoader.normalize_height(o, 34.0); o.position = base_pos
		"crypt", "city":
			# A leaning broken tower (stacked damaged columns).
			for i in 5:
				var c := NatureLib.instance("statue_columnDamaged", col)
				if c == null: continue
				root.add_child(c); AssetLoader.normalize_height(c, 9.0)
				c.position = base_pos + Vector3(i * 0.4, i * 7.2, 0)
				c.rotation.z = 0.04 * i
		"highland":
			# A distant peak (big cone) crowned with a monolith.
			var peak := _poi_mesh(root, _cone(14.0, 24.0), base_pos + Vector3(0, 12.0, 0), col)
			var mono := NatureLib.instance("statue_obelisk", col.lightened(0.05))
			if mono: root.add_child(mono); AssetLoader.normalize_height(mono, 8.0); mono.position = base_pos + Vector3(0, 24.0, 0)
		"coast":
			# A lighthouse-like tower + a sea arch.
			_poi_mesh(root, _cylinder(2.2, 1.4, 20.0), base_pos + Vector3(0, 10.0, 0), col)
			_poi_mesh(root, _torus(5.0, 7.0), base_pos + Vector3(side * -10.0, 6.0, 4.0), col, Vector3(0, 0, 0))
		"corrupted":
			# An immense jagged crystal spire, faintly glowing.
			var spire := _poi_mesh(root, _cone(4.0, 30.0), base_pos + Vector3(0, 15.0, 0), Color(0.5, 0.12, 0.55))
			var m := spire.get_active_material(0)
			if m is StandardMaterial3D:
				(m as StandardMaterial3D).emission_enabled = true
				(m as StandardMaterial3D).emission = Color(0.6, 0.15, 0.7)
				(m as StandardMaterial3D).emission_energy_multiplier = 0.8
		"anomaly":
			# A floating island ring drifting in the sky.
			var ring := _poi_mesh(root, _torus(8.0, 11.0), base_pos + Vector3(0, 20.0, 0), Color(0.4, 0.5, 0.95), Vector3(20, 0, 10))
			var rm := ring.get_active_material(0)
			if rm is StandardMaterial3D:
				(rm as StandardMaterial3D).emission_enabled = true
				(rm as StandardMaterial3D).emission = Color(0.4, 0.55, 1.0)
				(rm as StandardMaterial3D).emission_energy_multiplier = 0.6
			var spin := ring.create_tween().set_loops()
			spin.tween_property(ring, "rotation:y", TAU, 60.0)
		_:
			var t := NatureLib.instance("tree_default", col)
			if t: root.add_child(t); AssetLoader.normalize_height(t, 24.0); t.position = base_pos

func _poi_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, col: Color, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot_deg
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func _cone(radius: float, height: float) -> CylinderMesh:
	var c := CylinderMesh.new(); c.top_radius = 0.05; c.bottom_radius = radius; c.height = height
	return c

func _cylinder(top: float, bottom: float, height: float) -> CylinderMesh:
	var c := CylinderMesh.new(); c.top_radius = top; c.bottom_radius = bottom; c.height = height
	return c

func _torus(inner: float, outer: float) -> TorusMesh:
	var t := TorusMesh.new(); t.inner_radius = inner; t.outer_radius = outer
	return t

func _build_far_silhouettes(biome: StringName, corruption: float) -> void:
	# A row of large dim shapes ~30 m behind the encounter, plus a second further
	# row, to fill the empty sky and give the scene a sense of distance.
	# All shapes use a flat dark material so they read as silhouettes against
	# the sky / fog.
	var rng := DRNG.new(int(biome.hash()) ^ 0x5EED)
	var horizon: Color = BIOME_SKY_HORIZON.get(biome, Color(0.6, 0.6, 0.6))
	var par := Node3D.new()
	par.name = "FarSilhouettes"
	add_child(par)
	# Two depth rows so they layer. Far shapes are tinted TOWARD the horizon
	# (aerial perspective) instead of harsh black, and pushed well back, so
	# they recede into the sky rather than stamping ugly cut-outs onto it.
	for row in 2:
		var z_base := -32.0 - float(row) * 16.0
		var count := 9
		var y_scale_range := Vector2(4.0, 9.0)
		match String(biome):
			"highland":  count = 11; y_scale_range = Vector2(7.0, 16.0)
			"coast":     count = 7;  y_scale_range = Vector2(1.2, 3.0)   # rocky islets
			"swamp":     count = 10; y_scale_range = Vector2(4.0, 8.0)   # dead trees + cypress
			"forest":    count = 12; y_scale_range = Vector2(5.0, 10.0)
			"city":      count = 8;  y_scale_range = Vector2(6.0, 14.0)  # towers
			"ruins":     count = 8;  y_scale_range = Vector2(4.0, 9.0)   # broken columns
			"crypt":     count = 7;  y_scale_range = Vector2(5.0, 9.0)
			"corrupted": count = 9;  y_scale_range = Vector2(4.0, 9.0)
			"anomaly":   count = 8;  y_scale_range = Vector2(4.0, 9.0)
		# Distant relief reads as DIM shapes: a dark, desaturated, slightly
		# horizon-tinted silhouette — never bright blocks. Far row dimmer still.
		var base_dark := Color(0.18, 0.19, 0.24).lerp(horizon, 0.22)
		var silhouette_col: Color = base_dark.darkened(0.15 + float(row) * 0.18)
		silhouette_col = silhouette_col.lerp(Color(0.16, 0.04, 0.18), corruption * 0.4)
		for i in count:
			var x := _frng_h(rng, -34, 34)
			var z := z_base + _frng_h(rng, -4, 4)
			var h := _frng_h(rng, y_scale_range.x, y_scale_range.y)
			var w := _frng_h(rng, 2.0, 4.5)
			var mesh: Mesh
			match String(biome):
				"city":
					var box := BoxMesh.new(); box.size = Vector3(w, h, w * 0.8); mesh = box
				"crypt":
					var box := BoxMesh.new(); box.size = Vector3(w * 0.7, h, w * 0.4); mesh = box
				"ruins":
					var cyl := CylinderMesh.new(); cyl.top_radius = w * 0.3; cyl.bottom_radius = w * 0.4; cyl.height = h; mesh = cyl
				"swamp", "forest":
					# Conifer-ish: tall narrow cone — soft, not jagged.
					var cyl := CylinderMesh.new(); cyl.top_radius = 0.05; cyl.bottom_radius = w * 0.55; cyl.height = h; mesh = cyl
				_:
					# Rolling hills: a wide flattened dome reads as distant relief
					# instead of a sharp black triangle.
					var dome := SphereMesh.new()
					dome.radius = w * 1.6
					dome.height = h * 1.4
					mesh = dome
			var mi := MeshInstance3D.new()
			mi.mesh = mesh
			var y_pos := h * 0.5
			if mesh is SphereMesh:
				y_pos = 0.0   # dome sunk so only the top rises over the horizon
			mi.position = Vector3(x, y_pos, z)
			mi.rotation.y = _frng_h(rng, 0, 6.28)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = silhouette_col
			mat.roughness = 1.0
			mat.metallic_specular = 0.0
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			par.add_child(mi)
	# Mid-ground filler: a closer, smaller row at z≈-13 that bridges the gap
	# between the playable decor (z≥-8) and the far silhouettes (z≤-22). Still
	# fully behind the action so it never hides mobs or UI.
	var mid_col: Color = Color(0.20, 0.21, 0.26).lerp(horizon, 0.18).lerp(Color(0.16, 0.04, 0.18), corruption * 0.3)
	for i in 7:
		var x := _frng_h(rng, -18, 18)
		if absf(x) < 3.0: continue   # keep the center sightline to the horizon open
		var z := -13.0 + _frng_h(rng, -2, 2)
		var h := _frng_h(rng, 1.2, 3.2)
		var w := _frng_h(rng, 0.6, 1.6)
		var mesh: Mesh
		match String(biome):
			"city", "crypt":
				var box := BoxMesh.new(); box.size = Vector3(w, h, w * 0.7); mesh = box
			"ruins":
				var cyl := CylinderMesh.new(); cyl.top_radius = w * 0.25; cyl.bottom_radius = w * 0.35; cyl.height = h; mesh = cyl
			"coast":
				var sph := SphereMesh.new(); sph.radius = w * 0.7; sph.height = h; mesh = sph
			_:
				var cone := CylinderMesh.new(); cone.top_radius = 0.05; cone.bottom_radius = w * 0.5; cone.height = h; mesh = cone
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = Vector3(x, h * 0.5, z)
		mi.rotation.y = _frng_h(rng, 0, 6.28)
		var mmat := StandardMaterial3D.new()
		mmat.albedo_color = mid_col
		mmat.roughness = 1.0
		mmat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
		mi.material_override = mmat
		par.add_child(mi)
	# Distant bird flocks crossing the sky (skip underground/abyssal moods).
	if not (String(biome) in ["crypt", "corrupted", "anomaly"]):
		_spawn_bird_flock(par, rng)

func _spawn_bird_flock(par: Node3D, rng: DRNG) -> void:
	# 4-6 dark chevrons gliding across the far sky in a loose V, looping with
	# a long pause so the sky feels alive without being busy.
	var flock := Node3D.new()
	par.add_child(flock)
	var count := 4 + rng.range_i(0, 3)
	for i in count:
		var bird := MeshInstance3D.new()
		var m := PrismMesh.new()
		m.size = Vector3(0.55, 0.10, 0.22)
		bird.mesh = m
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.08, 0.08, 0.10)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bird.material_override = mat
		# Loose V formation offsets.
		var row := (i + 1) / 2
		var side := 1 if i % 2 == 0 else -1
		bird.position = Vector3(float(side * row) * 1.4, -absf(float(row)) * 0.35, float(row) * 0.8)
		flock.add_child(bird)
		# Wing-beat: tiny vertical bob per bird, phase-shifted.
		var bob := bird.create_tween().set_loops()
		bob.tween_property(bird, "position:y", bird.position.y + 0.18, 0.55 + float(i) * 0.04).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(bird, "position:y", bird.position.y, 0.55 + float(i) * 0.04).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var fy := 10.0 + _frng_h(rng, 0, 4)
	flock.position = Vector3(-34, fy, -26)
	var travel := flock.create_tween().set_loops()
	travel.tween_property(flock, "position", Vector3(34, fy + 2.0, -28), 26.0)
	travel.tween_callback(func():
		if is_instance_valid(flock): flock.position = Vector3(-34, fy, -26))
	travel.tween_interval(14.0)

func _frng_h(rng: DRNG, lo: float, hi: float) -> float:
	var span := int((hi - lo) * 100.0)
	return lo + float(rng.range_i(0, maxi(1, span))) / 100.0

func _build_atmosphere(biome: StringName, corruption: float) -> void:
	var amount := 80
	var col := Color(1, 1, 1, 0.8)
	var gravity := Vector3(0, -0.2, 0)
	var velocity := 0.4
	var spread := 18.0
	var lifetime := 8.0
	var scale_min := 0.02
	var scale_max := 0.06
	var emit_rate := 18.0
	match String(biome):
		"forest":    col = Color(0.95, 0.90, 0.65, 0.7); gravity = Vector3(0.1, -0.05, 0); emit_rate = 14.0
		"city":      col = Color(0.85, 0.85, 0.95, 0.6); gravity = Vector3(0.05, -0.1, 0); emit_rate = 10.0
		"ruins":     col = Color(0.95, 0.85, 0.60, 0.7); gravity = Vector3(0.15, -0.08, 0); emit_rate = 14.0
		"corrupted": col = Color(0.85, 0.30, 0.55, 0.8); gravity = Vector3(0, 0.05, 0); emit_rate = 22.0
		"anomaly":   col = Color(0.55, 0.75, 1.0, 0.9); gravity = Vector3(0, 0.10, 0); emit_rate = 24.0
		"swamp":     col = Color(0.60, 0.95, 0.55, 0.7); gravity = Vector3(0, -0.30, 0); emit_rate = 16.0
		"highland":  col = Color(1.0, 1.0, 1.0, 0.85);   gravity = Vector3(0.30, -0.15, 0); emit_rate = 18.0
		"crypt":     col = Color(0.65, 0.55, 0.85, 0.5); gravity = Vector3(0, 0.02, 0); emit_rate = 8.0
		"coast":     col = Color(0.85, 0.85, 0.95, 0.7); gravity = Vector3(-0.20, -0.08, 0); emit_rate = 14.0
	var p := GPUParticles3D.new()
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = spread
	pm.gravity = gravity
	pm.initial_velocity_min = velocity * 0.3
	pm.initial_velocity_max = velocity
	pm.scale_min = scale_min
	pm.scale_max = scale_max
	pm.color = col
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(12, 4, 8)
	p.process_material = pm
	var mesh := SphereMesh.new(); mesh.radius = 0.04; mesh.height = 0.08
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = 1.5
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	p.draw_pass_1 = mesh
	p.amount = amount
	p.lifetime = lifetime
	p.fixed_fps = 30
	p.position = Vector3(0, 3, -2)
	add_child(p)

func _build_environment(biome: StringName, corruption: float) -> void:
	env = WorldEnvironment.new()
	var e := Environment.new()
	var sky_top: Color = BIOME_SKY_TOP.get(biome, Color(0.2, 0.2, 0.3)).lerp(Color(0.15, 0.02, 0.15), corruption * 0.4)
	var sky_h: Color = BIOME_SKY_HORIZON.get(biome, Color(0.6, 0.6, 0.6)).lerp(Color(0.45, 0.10, 0.30), corruption * 0.4)
	# Custom shader sky: real gradient + sun halo + animated fbm clouds + stars.
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = preload("res://render/sky.gdshader")
	sky_mat.set_shader_parameter("top_color", sky_top)
	sky_mat.set_shader_parameter("horizon_color", sky_h)
	sky_mat.set_shader_parameter("ground_color", sky_top.darkened(0.6))
	# Time-of-day drives sun tint, cloud mood and stars.
	var sun_tint := Color(1.0, 0.95, 0.85)
	var coverage := 0.42
	var stars := 0.0
	match _time_of_day:
		0: sun_tint = Color(1.0, 0.97, 0.88); coverage = 0.38
		1: sun_tint = Color(1.0, 0.72, 0.45); coverage = 0.52        # dusk: golden, heavier clouds
		2: sun_tint = Color(0.80, 0.85, 1.0); coverage = 0.30; stars = 0.7   # pre-dawn
	match String(biome):
		"swamp", "crypt": coverage += 0.18
		"corrupted": coverage += 0.12; sun_tint = sun_tint.lerp(Color(0.9, 0.5, 0.8), 0.3)
		"anomaly": coverage -= 0.10; stars = maxf(stars, 0.45)
		"highland", "coast": coverage -= 0.06
	sky_mat.set_shader_parameter("sun_tint", sun_tint)
	sky_mat.set_shader_parameter("cloud_coverage", clampf(coverage + corruption * 0.15, 0.1, 0.85))
	sky_mat.set_shader_parameter("cloud_color", Color(1, 1, 1).lerp(sky_h, 0.25))
	sky_mat.set_shader_parameter("stars_amount", stars)
	sky_mat.set_shader_parameter("haze", 0.22 + corruption * 0.2)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.8
	e.fog_enabled = true
	e.fog_light_color = sky_h
	e.fog_sun_scatter = 0.25
	# AgX: filmic response that keeps saturated emissives (eyes, runes, fires)
	# from clipping to neon — the single biggest "pro look" switch available
	# on the Mobile renderer.
	e.tonemap_mode = Environment.TONE_MAPPER_AGX
	e.tonemap_exposure = 1.25
	e.glow_enabled = true
	e.glow_intensity = 0.8
	e.glow_strength = 1.05
	e.glow_bloom = 0.18
	e.glow_hdr_threshold = 1.0
	e.adjustment_enabled = true
	e.fog_aerial_perspective = 0.30
	# Volumetric fog requires Forward+ — not available on the mobile renderer.
	# Keep depth fog light so the playspace stays crisp; the far silhouettes
	# carry the sense of depth instead of a milky veil.
	e.fog_density = 0.007 + corruption * 0.015
	# Thin ground mist only.
	e.fog_height_density = 0.015
	e.fog_height = 0.8
	# Per-biome grading — stronger character per zone.
	match String(biome):
		"forest":    e.adjustment_saturation = 1.30; e.adjustment_contrast = 1.10; e.adjustment_brightness = 1.00
		"city":      e.adjustment_saturation = 0.80; e.adjustment_contrast = 1.20; e.adjustment_brightness = 0.92
		"ruins":     e.adjustment_saturation = 1.10; e.adjustment_contrast = 1.15; e.adjustment_brightness = 1.05
		"corrupted": e.adjustment_saturation = 0.55; e.adjustment_contrast = 1.40; e.adjustment_brightness = 0.85
		"anomaly":   e.adjustment_saturation = 1.45; e.adjustment_contrast = 1.25; e.adjustment_brightness = 1.05
		"swamp":     e.adjustment_saturation = 0.75; e.adjustment_contrast = 1.15; e.adjustment_brightness = 0.85
		"highland":  e.adjustment_saturation = 1.15; e.adjustment_contrast = 1.10; e.adjustment_brightness = 1.15
		"crypt":     e.adjustment_saturation = 0.45; e.adjustment_contrast = 1.45; e.adjustment_brightness = 0.78
		"coast":     e.adjustment_saturation = 1.20; e.adjustment_contrast = 1.10; e.adjustment_brightness = 1.10
		_:           e.adjustment_saturation = 1.10; e.adjustment_contrast = 1.10
	# AgX response is slightly flatter than Filmic — give the grade back a
	# touch of saturation so each biome keeps its color identity.
	e.adjustment_saturation += 0.10
	e.ambient_light_energy = 0.9
	env.environment = e
	# Depth-of-field lives on CameraAttributes in Godot 4 (not Environment).
	var attrs := CameraAttributesPractical.new()
	attrs.dof_blur_far_enabled = true
	attrs.dof_blur_far_distance = 16.0
	attrs.dof_blur_far_transition = 14.0
	attrs.dof_blur_amount = 0.055
	env.camera_attributes = attrs
	add_child(env)

func _build_ground(biome: StringName, corruption: float) -> void:
	ground = MeshInstance3D.new()
	ground.mesh = _displaced_ground_mesh(biome)
	var mat := StandardMaterial3D.new()
	var base: Color = BIOME_GROUND.get(biome, Color(0.2, 0.2, 0.2))
	mat.roughness = 0.92
	mat.metallic_specular = 0.05
	# Photographic PBR ground (Polyhaven CC0): real diffuse + normal per biome.
	var diff_path := "res://assets/textures/ground/%s_diff.jpg" % String(biome)
	var nor_path := "res://assets/textures/ground/%s_nor.jpg" % String(biome)
	if ResourceLoader.exists(diff_path):
		mat.albedo_texture = load(diff_path)
		# Light tint keeps the biome grade + corruption mood over the photo.
		mat.albedo_color = Color(1, 1, 1).lerp(base.lightened(0.35), 0.35)
		mat.albedo_color = mat.albedo_color.lerp(Color(0.55, 0.25, 0.50), corruption * 0.35)
		mat.uv1_scale = Vector3(14, 14, 14)
		if ResourceLoader.exists(nor_path):
			mat.normal_enabled = true
			mat.normal_texture = load(nor_path)
			mat.normal_scale = 0.85
	else:
		# Fallback: procedural noise detail (albedo mottling + normal grain).
		mat.albedo_color = base.lerp(Color(0.28, 0.05, 0.22), corruption * 0.4)
		var n := FastNoiseLite.new()
		n.seed = int(biome.hash()) & 0x7FFFFFFF
		n.frequency = 0.012
		n.fractal_octaves = 4
		var albedo_tex := NoiseTexture2D.new()
		albedo_tex.noise = n
		albedo_tex.width = 512; albedo_tex.height = 512
		albedo_tex.seamless = true
		mat.albedo_texture = albedo_tex
		mat.uv1_scale = Vector3(6, 6, 6)
		var n2 := FastNoiseLite.new()
		n2.seed = (int(biome.hash()) >> 3) & 0x7FFFFFFF
		n2.frequency = 0.05
		n2.fractal_octaves = 5
		var normal_tex := NoiseTexture2D.new()
		normal_tex.noise = n2
		normal_tex.width = 512; normal_tex.height = 512
		normal_tex.seamless = true
		normal_tex.as_normal_map = true
		normal_tex.bump_strength = 6.0
		mat.normal_enabled = true
		mat.normal_texture = normal_tex
		mat.normal_scale = 0.7
	ground.material_override = mat
	ground.position = Vector3(0, 0, -2)
	add_child(ground)

# Grid mesh with gentle rolling hills outside the flat play area, so the
# terrain has real relief instead of an infinite billiard table.
func _displaced_ground_mesh(biome: StringName) -> ArrayMesh:
	var size := 90.0
	var div := 56
	var hn := FastNoiseLite.new()
	hn.seed = (int(biome.hash()) >> 7) & 0x7FFFFFFF
	hn.frequency = 0.06
	hn.fractal_octaves = 3
	var amp := 0.9
	match String(biome):
		"highland": amp = 1.8
		"swamp", "coast": amp = 0.35
		"city", "crypt": amp = 0.45
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := size / float(div)
	for iz in div:
		for ix in div:
			var x0 := -size * 0.5 + float(ix) * step
			var z0 := -size * 0.5 + float(iz) * step
			var p00 := Vector3(x0, _ground_h(hn, x0, z0, amp), z0)
			var p10 := Vector3(x0 + step, _ground_h(hn, x0 + step, z0, amp), z0)
			var p01 := Vector3(x0, _ground_h(hn, x0, z0 + step, amp), z0 + step)
			var p11 := Vector3(x0 + step, _ground_h(hn, x0 + step, z0 + step, amp), z0 + step)
			var uv00 := Vector2(float(ix) / div, float(iz) / div)
			var uv10 := Vector2(float(ix + 1) / div, float(iz) / div)
			var uv01 := Vector2(float(ix) / div, float(iz + 1) / div)
			var uv11 := Vector2(float(ix + 1) / div, float(iz + 1) / div)
			st.set_uv(uv00); st.add_vertex(p00)
			st.set_uv(uv01); st.add_vertex(p01)
			st.set_uv(uv10); st.add_vertex(p10)
			st.set_uv(uv10); st.add_vertex(p10)
			st.set_uv(uv01); st.add_vertex(p01)
			st.set_uv(uv11); st.add_vertex(p11)
	st.generate_normals()
	return st.commit()

# Height function: dead flat inside the play disc (radius 7 around the stage
# center at z=-2 local → world z≈-2..6 covered), rising smoothly outside.
func _ground_h(hn: FastNoiseLite, x: float, z: float, amp: float) -> float:
	# Local coords: stage center in this mesh's space is (0, 0) since the
	# ground node itself sits at z=-2.
	var d := Vector2(x, z + 2.0).length()      # distance from encounter focus
	var mask := clampf((d - 7.0) / 8.0, 0.0, 1.0)
	mask = mask * mask * (3.0 - 2.0 * mask)    # smoothstep
	var h := hn.get_noise_2d(x, z) * amp
	return h * mask

func _build_lights(biome: StringName, corruption: float) -> void:
	var tint: Color = BIOME_LIGHT_TINT.get(biome, Color.WHITE)
	# Time-of-day modulates angle + warmth + energy.
	var sun_rot := Vector3(-45, -28, 0)
	var sun_energy_mul := 1.0
	var warmth_mul := Color(1, 1, 1)
	match _time_of_day:
		0:   # NOON: high sun, bright, neutral
			sun_rot = Vector3(-65, -20, 0)
			sun_energy_mul = 1.10
			warmth_mul = Color(1.00, 0.98, 0.92)
		1:   # DUSK: low sun, warm, golden
			sun_rot = Vector3(-15, -45, 0)
			sun_energy_mul = 0.85
			warmth_mul = Color(1.20, 0.85, 0.55)
		2:   # PRE-DAWN: low cool, blue
			sun_rot = Vector3(-12, -160, 0)
			sun_energy_mul = 0.55
			warmth_mul = Color(0.65, 0.75, 1.00)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = sun_rot
	sun.light_energy = (1.1 - corruption * 0.3) * sun_energy_mul
	sun.light_color = tint * warmth_mul
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	sun.light_angular_distance = 1.5
	# Soft penumbra: with the 4096 atlas + soft filter the edges melt naturally.
	sun.shadow_blur = 1.6
	sun.shadow_opacity = 0.88
	add_child(sun)

	fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-15, 130, 0)
	fill.light_energy = 0.40
	fill.light_color = tint.lerp(Color(0.55, 0.70, 1.00), 0.55) * warmth_mul
	add_child(fill)

	# Rim light — explicitly stronger so creature silhouettes glow against the
	# darker background.  Mounted behind the camera-relative encounter focal point.
	rim = DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-12, 195, 0)
	rim.light_energy = 0.85
	var rim_warm := Color(1.00, 0.85, 0.55) if _time_of_day == 1 else Color(0.85, 0.95, 1.00)
	rim.light_color = rim_warm.lerp(Color(0.85, 0.55, 1.00), corruption)
	add_child(rim)
