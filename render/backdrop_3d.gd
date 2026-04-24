class_name Backdrop3D extends Node3D
# Atmospheric backdrop: gradient sky, fog, key+fill+rim lighting, ground.

const BIOME_SKY_TOP := {
	&"forest":    Color(0.18, 0.30, 0.32),
	&"city":      Color(0.20, 0.22, 0.30),
	&"ruins":     Color(0.32, 0.22, 0.18),
	&"corrupted": Color(0.22, 0.05, 0.20),
	&"anomaly":   Color(0.05, 0.10, 0.30),
}
const BIOME_SKY_HORIZON := {
	&"forest":    Color(0.78, 0.72, 0.55),
	&"city":      Color(0.55, 0.55, 0.58),
	&"ruins":     Color(0.85, 0.65, 0.45),
	&"corrupted": Color(0.55, 0.20, 0.35),
	&"anomaly":   Color(0.40, 0.30, 0.85),
}
const BIOME_GROUND := {
	&"forest":    Color(0.15, 0.22, 0.12),
	&"city":      Color(0.18, 0.18, 0.20),
	&"ruins":     Color(0.30, 0.25, 0.20),
	&"corrupted": Color(0.20, 0.06, 0.18),
	&"anomaly":   Color(0.08, 0.10, 0.22),
}
const BIOME_LIGHT_TINT := {
	&"forest":    Color(1.00, 0.96, 0.85),
	&"city":      Color(0.95, 0.95, 1.00),
	&"ruins":     Color(1.00, 0.85, 0.65),
	&"corrupted": Color(0.85, 0.70, 1.00),
	&"anomaly":   Color(0.75, 0.85, 1.00),
}

var ground: MeshInstance3D
var sun: DirectionalLight3D
var fill: DirectionalLight3D
var rim: DirectionalLight3D
var env: WorldEnvironment

func build(biome: StringName, corruption: float) -> void:
	_build_environment(biome, corruption)
	_build_ground(biome, corruption)
	_build_lights(biome, corruption)

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
	e.adjustment_saturation = 1.1
	e.adjustment_contrast = 1.05
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
