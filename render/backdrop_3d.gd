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
	_build_atmosphere(biome, corruption)
	_build_ambient_critters(biome, DRNG.new(int(Time.get_ticks_msec())))

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
	# Soft cloud band along the horizon to break the sky color.
	for i in 6:
		var cloud := SphereMesh.new()
		cloud.radius = 4.0
		cloud.height = 2.0
		var mi := MeshInstance3D.new()
		mi.mesh = cloud
		mi.position = Vector3(_frng_h(rng, -30, 30), _frng_h(rng, 8, 14), -36)
		var cm := StandardMaterial3D.new()
		cm.albedo_color = horizon.lerp(Color(1, 1, 1), 0.3)
		cm.albedo_color.a = 0.35
		cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cm.roughness = 1.0
		mi.material_override = cm
		par.add_child(mi)

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
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = sky_top
	sky_mat.sky_horizon_color = sky_h
	sky_mat.ground_horizon_color = sky_h.darkened(0.3)
	sky_mat.ground_bottom_color = sky_top.darkened(0.5)
	sky_mat.sun_angle_max = 25.0
	sky_mat.sun_curve = 0.2
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.8
	e.fog_enabled = true
	e.fog_light_color = sky_h
	e.fog_sun_scatter = 0.25
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.0
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_strength = 1.10
	e.glow_bloom = 0.25
	e.glow_hdr_threshold = 0.9
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
	env.environment = e
	# Depth-of-field lives on CameraAttributes in Godot 4 (not Environment).
	var attrs := CameraAttributesPractical.new()
	attrs.dof_blur_far_enabled = true
	attrs.dof_blur_far_distance = 10.0
	attrs.dof_blur_far_transition = 6.0
	attrs.dof_blur_amount = 0.08
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
	sun.directional_shadow_max_distance = 30.0
	sun.light_angular_distance = 1.5
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
