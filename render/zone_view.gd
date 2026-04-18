class_name ZoneView extends Node3D
# Builds the visible ground + ambient lighting for a zone.

const BIOME_COLORS := {
	&"forest":    Color(0.15, 0.35, 0.18),
	&"city":      Color(0.25, 0.25, 0.30),
	&"ruins":     Color(0.30, 0.27, 0.20),
	&"corrupted": Color(0.20, 0.10, 0.25),
	&"anomaly":   Color(0.10, 0.15, 0.35),
}

func build(zone: Zone) -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	var base: Color = BIOME_COLORS.get(zone.biome, Color(0.2, 0.2, 0.2))
	mat.albedo_color = base.lerp(Color(0.6, 0.1, 0.6), zone.corruption * 0.4)
	ground.material_override = mat
	add_child(ground)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 0.9 - zone.corruption * 0.3
	add_child(sun)
