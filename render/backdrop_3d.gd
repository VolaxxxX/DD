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
	_build_atmosphere(biome, corruption)
	_build_ambient_critters(biome, DRNG.new(int(Time.get_ticks_msec())))
	_build_ground_fauna(biome, DRNG.new((int(biome.hash()) >> 4) ^ 0xFA0A))

var _time_of_day: int = 0   # 0=noon, 1=dusk, 2=pre-dawn

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
		"coast":
			for i in 3:
				_fauna_crab(Vector3(4.0 + float(i) * 2.6, 0, -5.0 - float(i) * 1.2))
		"city", "crypt":
			for i in 3:
				_fauna_rat(Vector3(-5.0 - float(i) * 2.0, 0, -5.0 - float(i)))
		"swamp":
			_fauna_frog(Vector3(5.5, 0.06, -6.0))
			_fauna_frog(Vector3(-6.0, 0.06, -7.5))
			for i in 3:
				_fauna_dragonfly(Vector3(_frng_h(rng, -8, 8), _frng_h(rng, 0.6, 1.4), _frng_h(rng, -9, -4)))
		"highland":
			_fauna_goat(Vector3(8.0, 0, -9.0))
			_fauna_goat(Vector3(-9.5, 0, -10.5))
		"ruins":
			_fauna_lizard(Vector3(5.0, 0, -5.5))
			_fauna_lizard(Vector3(-6.5, 0, -7.0))
		"corrupted":
			for i in 2:
				_fauna_tendril_bug(Vector3(-5.0 + float(i) * 10.0, 0, -7.0))
		"anomaly":
			for i in 3:
				_fauna_orbiting_shard(Vector3(_frng_h(rng, -9, 9), _frng_h(rng, 1.0, 2.4), _frng_h(rng, -10, -5)))

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
	var count := 420
	var base_col: Color
	var tip_col: Color
	var blade := true              # blade=true: thin box; false: pebble sphere
	match String(biome):
		"forest":    base_col = Color(0.16, 0.34, 0.12); tip_col = Color(0.38, 0.55, 0.20)
		"highland":  base_col = Color(0.25, 0.36, 0.16); tip_col = Color(0.55, 0.55, 0.30)
		"swamp":     base_col = Color(0.10, 0.26, 0.14); tip_col = Color(0.30, 0.45, 0.22); count = 320
		"coast":     base_col = Color(0.55, 0.50, 0.32); tip_col = Color(0.72, 0.68, 0.45); count = 220
		"corrupted": base_col = Color(0.28, 0.08, 0.26); tip_col = Color(0.65, 0.20, 0.55); count = 300
		"city":      base_col = Color(0.24, 0.24, 0.26); tip_col = Color(0.38, 0.38, 0.40); blade = false; count = 260
		"ruins":     base_col = Color(0.38, 0.34, 0.26); tip_col = Color(0.55, 0.50, 0.38); blade = false; count = 280
		"crypt":     base_col = Color(0.14, 0.13, 0.15); tip_col = Color(0.26, 0.24, 0.28); blade = false; count = 220
		"anomaly":   base_col = Color(0.12, 0.16, 0.38); tip_col = Color(0.35, 0.45, 0.95); count = 240
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
		var x := _frng_h(rng, -22, 22)
		var z := _frng_h(rng, -18, 4)
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

func _build_far_silhouettes(biome: StringName, corruption: float) -> void:
	# A row of large dim shapes ~30 m behind the encounter, plus a second further
	# row, to fill the empty sky and give the scene a sense of distance.
	# All shapes use a flat dark material so they read as silhouettes against
	# the sky / fog.
	var rng := DRNG.new(int(biome.hash()) ^ 0x5EED)
	var horizon: Color = BIOME_SKY_HORIZON.get(biome, Color(0.6, 0.6, 0.6))
	var silhouette_col: Color = horizon.darkened(0.55).lerp(Color(0.10, 0.02, 0.15), corruption * 0.5)
	var par := Node3D.new()
	par.name = "FarSilhouettes"
	add_child(par)
	# Two depth rows so they layer.
	for row in 2:
		var z_base := -22.0 - float(row) * 12.0
		var count := 9
		var y_scale_range := Vector2(4.0, 9.0)
		match String(biome):
			"highland":  count = 11; y_scale_range = Vector2(6.0, 14.0)
			"coast":     count = 7;  y_scale_range = Vector2(0.8, 2.5)   # rocky islets
			"swamp":     count = 10; y_scale_range = Vector2(3.0, 6.0)   # dead trees + cypress
			"forest":    count = 11; y_scale_range = Vector2(4.0, 8.0)
			"city":      count = 8;  y_scale_range = Vector2(5.0, 12.0)  # towers
			"ruins":     count = 8;  y_scale_range = Vector2(3.0, 8.0)   # broken columns
			"crypt":     count = 7;  y_scale_range = Vector2(4.0, 7.0)   # tombstones / mausolea
			"corrupted": count = 9;  y_scale_range = Vector2(3.0, 7.0)
			"anomaly":   count = 8;  y_scale_range = Vector2(3.0, 8.0)
		for i in count:
			var x := _frng_h(rng, -28, 28)
			var z := z_base + _frng_h(rng, -3, 3)
			var h := _frng_h(rng, y_scale_range.x, y_scale_range.y)
			var w := _frng_h(rng, 1.5, 4.0)
			var mesh: Mesh
			match String(biome):
				"city":
					var box := BoxMesh.new(); box.size = Vector3(w, h, w * 0.8); mesh = box
				"crypt":
					var box := BoxMesh.new(); box.size = Vector3(w * 0.7, h, w * 0.4); mesh = box
				"ruins":
					var cyl := CylinderMesh.new(); cyl.top_radius = w * 0.3; cyl.bottom_radius = w * 0.4; cyl.height = h; mesh = cyl
				"swamp":
					var cyl := CylinderMesh.new(); cyl.top_radius = 0.08; cyl.bottom_radius = w * 0.18; cyl.height = h; mesh = cyl
				"coast":
					var sph := SphereMesh.new(); sph.radius = w * 0.6; sph.height = h * 1.2; mesh = sph
				_:
					var pri := PrismMesh.new(); pri.size = Vector3(w * 2.5, h, w * 1.2); mesh = pri
			var mi := MeshInstance3D.new()
			mi.mesh = mesh
			mi.position = Vector3(x, h * 0.5, z)
			mi.rotation.y = _frng_h(rng, 0, 6.28)
			var mat := StandardMaterial3D.new()
			# Dimmer for the second row so layering reads.
			var fade := 1.0 - float(row) * 0.25
			mat.albedo_color = silhouette_col.darkened(0.2 * (1.0 - fade))
			mat.roughness = 1.0
			mat.metallic_specular = 0.0
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
			mi.material_override = mat
			par.add_child(mi)
	# Mid-ground filler: a closer, smaller row at z≈-13 that bridges the gap
	# between the playable decor (z≥-8) and the far silhouettes (z≤-22). Still
	# fully behind the action so it never hides mobs or UI.
	var mid_col := silhouette_col.lightened(0.12)
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
	mat.albedo_color = base.lerp(Color(0.28, 0.05, 0.22), corruption * 0.4)
	mat.roughness = 0.92
	mat.metallic_specular = 0.05
	# Real surface detail: noise albedo (mottling) + noise normal map (grain).
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
