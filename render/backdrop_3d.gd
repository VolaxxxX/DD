class_name Backdrop3D extends Node3D
# Sky color, fog, lighting and ground per biome.

const BIOME_SKY := {
	&"forest":    Color(0.55, 0.70, 0.55),
	&"city":      Color(0.45, 0.48, 0.55),
	&"ruins":     Color(0.65, 0.55, 0.42),
	&"corrupted": Color(0.38, 0.15, 0.35),
	&"anomaly":   Color(0.15, 0.18, 0.45),
}

const BIOME_GROUND := {
	&"forest":    Color(0.18, 0.28, 0.15),
	&"city":      Color(0.22, 0.22, 0.25),
	&"ruins":     Color(0.32, 0.28, 0.22),
	&"corrupted": Color(0.22, 0.08, 0.20),
	&"anomaly":   Color(0.08, 0.12, 0.28),
}

var ground: MeshInstance3D
var sun: DirectionalLight3D
var env: WorldEnvironment

func build(biome: StringName, corruption: float) -> void:
	_build_environment(biome, corruption)
	_build_ground(biome, corruption)
	_build_sun(biome, corruption)

func _build_environment(biome: StringName, corruption: float) -> void:
	env = WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	var sky: Color = BIOME_SKY.get(biome, Color(0.4, 0.5, 0.6))
	sky = sky.lerp(Color(0.3, 0.05, 0.25), corruption * 0.5)
	e.background_color = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = sky.lerp(Color.WHITE, 0.3)
	e.ambient_light_energy = 0.6
	e.fog_enabled = true
	e.fog_light_color = sky
	e.fog_density = 0.02 + corruption * 0.03
	env.environment = e
	add_child(env)

func _build_ground(biome: StringName, corruption: float) -> void:
	ground = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	var base: Color = BIOME_GROUND.get(biome, Color(0.2, 0.2, 0.2))
	mat.albedo_color = base.lerp(Color(0.35, 0.1, 0.3), corruption * 0.4)
	mat.roughness = 0.9
	ground.material_override = mat
	ground.position = Vector3(0, 0, -2)
	add_child(ground)

func _build_sun(biome: StringName, corruption: float) -> void:
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 0.9 - corruption * 0.3
	if biome == &"corrupted" or biome == &"anomaly":
		sun.light_color = Color(0.8, 0.7, 1.0)
	else:
		sun.light_color = Color(1.0, 0.95, 0.85)
	add_child(sun)
