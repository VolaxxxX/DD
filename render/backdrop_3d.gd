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
	_build_environment(biome, corruption)
	_build_ground(biome, corruption)
	_build_lights(biome, corruption)
	_apply_sub_tint(biome, sub_biome)
	_build_atmosphere(biome, corruption)
	_build_ambient_critters(biome, DRNG.new(int(Time.get_ticks_msec())))

func _apply_sub_tint(biome: StringName, sub_biome: int) -> void:
	# Multiply the directional sun + fill light by the sub-biome tint so each
	# variant of the same biome reads differently (warmer, cooler, darker).
	var tint: Color = PropLoader.sub_tint(biome, sub_biome)
	if sun: sun.light_color = sun.light_color * tint
	if fill: fill.light_color = fill.light_color * tint

func _build_ambient_critters(biome: StringName, rng: DRNG) -> void:
	# Tiny billboard sprites drifting in the sky / water for life.
	var n := 0
	var color := Color.WHITE
	var height_lo := 4.0
	var height_hi := 9.0
	match String(biome):
		"forest":   n = 4; color = Color(0.20, 0.18, 0.15)        # crows
		"coast":    n = 6; color = Color(0.95, 0.95, 0.95)        # gulls
		"highland": n = 4; color = Color(0.90, 0.90, 0.95)        # eagles
		"city":    n = 3; color = Color(0.15, 0.15, 0.15)
		"swamp":   n = 3; color = Color(0.55, 0.70, 0.45); height_lo = 0.5; height_hi = 3.0
		_:         return
	for i in n:
		var mi := MeshInstance3D.new()
		var mesh := QuadMesh.new(); mesh.size = Vector2(0.6, 0.25)
		mi.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mi.material_override = mat
		var x := randf_range(-20, 20)
		var z := randf_range(-15, -3)
		var y := randf_range(height_lo, height_hi)
		mi.position = Vector3(x, y, z)
		add_child(mi)
		# Drifting motion in a loop
		var t := mi.create_tween().set_loops()
		var endpoint := mi.position + Vector3(randf_range(-15, 15), randf_range(-1, 1), randf_range(-5, 5))
		t.tween_property(mi, "position", endpoint, randf_range(8, 16)).set_trans(Tween.TRANS_SINE)
		t.tween_property(mi, "position", mi.position, randf_range(8, 16)).set_trans(Tween.TRANS_SINE)

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
	e.fog_density = 0.012 + corruption * 0.025
	e.fog_sun_scatter = 0.4
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.0
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_strength = 0.9
	e.glow_bloom = 0.15
	e.adjustment_enabled = true
	# Per-biome grading.
	match String(biome):
		"forest":    e.adjustment_saturation = 1.20; e.adjustment_contrast = 1.05; e.adjustment_brightness = 1.00
		"city":      e.adjustment_saturation = 0.85; e.adjustment_contrast = 1.10; e.adjustment_brightness = 0.95
		"ruins":     e.adjustment_saturation = 1.05; e.adjustment_contrast = 1.10; e.adjustment_brightness = 1.05
		"corrupted": e.adjustment_saturation = 0.70; e.adjustment_contrast = 1.20; e.adjustment_brightness = 0.90
		"anomaly":   e.adjustment_saturation = 1.30; e.adjustment_contrast = 1.15; e.adjustment_brightness = 1.05
		"swamp":     e.adjustment_saturation = 0.85; e.adjustment_contrast = 1.05; e.adjustment_brightness = 0.90
		"highland":  e.adjustment_saturation = 1.10; e.adjustment_contrast = 1.05; e.adjustment_brightness = 1.10
		"crypt":     e.adjustment_saturation = 0.65; e.adjustment_contrast = 1.25; e.adjustment_brightness = 0.85
		"coast":     e.adjustment_saturation = 1.10; e.adjustment_contrast = 1.05; e.adjustment_brightness = 1.05
		_:           e.adjustment_saturation = 1.10; e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)

func _build_ground(biome: StringName, corruption: float) -> void:
	ground = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	plane.subdivide_width = 20
	plane.subdivide_depth = 20
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	var base: Color = BIOME_GROUND.get(biome, Color(0.2, 0.2, 0.2))
	mat.albedo_color = base.lerp(Color(0.28, 0.05, 0.22), corruption * 0.4)
	mat.roughness = 0.95
	mat.metallic_specular = 0.05
	ground.material_override = mat
	ground.position = Vector3(0, 0, -2)
	add_child(ground)

func _build_lights(biome: StringName, corruption: float) -> void:
	var tint: Color = BIOME_LIGHT_TINT.get(biome, Color.WHITE)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -28, 0)
	sun.light_energy = 1.1 - corruption * 0.3
	sun.light_color = tint
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	sun.light_angular_distance = 1.5
	add_child(sun)

	fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-15, 130, 0)
	fill.light_energy = 0.35
	fill.light_color = tint.lerp(Color(0.6, 0.7, 1.0), 0.55)
	add_child(fill)

	rim = DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-8, 200, 0)
	rim.light_energy = 0.45
	rim.light_color = Color(1.0, 0.85, 0.7).lerp(Color(0.8, 0.6, 1.0), corruption)
	add_child(rim)
