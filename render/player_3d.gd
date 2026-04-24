class_name Player3D extends Node3D
# Stylised player avatar built from primitives. Used in char-create preview and (optionally) in-game.

var class_data: Dictionary
var skin_color: Color = Color(0.92, 0.78, 0.65)
var hair_color: Color = Color(0.30, 0.20, 0.15)

func build(cls: Dictionary, p_skin: Color = Color(0.92, 0.78, 0.65), p_hair: Color = Color(0.30, 0.20, 0.15)) -> void:
	class_data = cls
	skin_color = p_skin
	hair_color = p_hair
	for c in get_children(): c.queue_free()
	_build_body()
	_build_head()
	_build_arms()
	_build_legs()
	_build_accessory()

func _build_body() -> void:
	var body := CapsuleMesh.new()
	body.radius = 0.22
	body.height = 0.85
	_add_part(body, Vector3(0, 0.95, 0), class_data.body_color, 0.7)

func _build_head() -> void:
	var head := SphereMesh.new()
	head.radius = 0.18
	head.height = 0.36
	_add_part(head, Vector3(0, 1.55, 0), skin_color, 0.4)
	# hair cap
	var hair := SphereMesh.new()
	hair.radius = 0.19
	hair.height = 0.18
	_add_part(hair, Vector3(0, 1.65, 0), hair_color, 0.6, Vector3(1.05, 0.55, 1.05))

func _build_arms() -> void:
	var arm := CapsuleMesh.new()
	arm.radius = 0.07
	arm.height = 0.55
	_add_part(arm, Vector3(0.30, 0.95, 0), class_data.body_color, 0.7, Vector3.ONE, Vector3(0, 0, 8))
	_add_part(arm, Vector3(-0.30, 0.95, 0), class_data.body_color, 0.7, Vector3.ONE, Vector3(0, 0, -8))
	# hands
	var hand := SphereMesh.new()
	hand.radius = 0.08
	hand.height = 0.16
	_add_part(hand, Vector3(0.34, 0.62, 0), skin_color, 0.5)
	_add_part(hand, Vector3(-0.34, 0.62, 0), skin_color, 0.5)

func _build_legs() -> void:
	var leg := CapsuleMesh.new()
	leg.radius = 0.10
	leg.height = 0.6
	var leg_color: Color = class_data.body_color.darkened(0.3)
	_add_part(leg, Vector3(0.13, 0.35, 0), leg_color, 0.7)
	_add_part(leg, Vector3(-0.13, 0.35, 0), leg_color, 0.7)
	# boots
	var boot := BoxMesh.new()
	boot.size = Vector3(0.18, 0.12, 0.22)
	var boot_color := Color(0.15, 0.10, 0.08)
	_add_part(boot, Vector3(0.13, 0.06, 0.04), boot_color, 0.8)
	_add_part(boot, Vector3(-0.13, 0.06, 0.04), boot_color, 0.8)

func _build_accessory() -> void:
	var acc: StringName = class_data.get("accessory", &"sword")
	match String(acc):
		"sword":
			var blade := BoxMesh.new()
			blade.size = Vector3(0.05, 0.7, 0.02)
			_add_part(blade, Vector3(0.42, 0.85, 0), Color(0.85, 0.85, 0.95), 0.2, Vector3.ONE, Vector3(0, 0, 5))
			var hilt := BoxMesh.new()
			hilt.size = Vector3(0.18, 0.06, 0.06)
			_add_part(hilt, Vector3(0.42, 0.45, 0), Color(0.5, 0.35, 0.2), 0.6)
		"bow":
			var stave := CylinderMesh.new()
			stave.top_radius = 0.02; stave.bottom_radius = 0.02; stave.height = 1.0
			_add_part(stave, Vector3(0.42, 0.95, 0), Color(0.4, 0.25, 0.15), 0.6, Vector3.ONE, Vector3(0, 0, 12))
		"staff":
			var rod := CylinderMesh.new()
			rod.top_radius = 0.04; rod.bottom_radius = 0.04; rod.height = 1.5
			_add_part(rod, Vector3(0.42, 1.05, 0), Color(0.35, 0.20, 0.15), 0.7)
			var orb := SphereMesh.new()
			orb.radius = 0.10; orb.height = 0.20
			_add_part(orb, Vector3(0.42, 1.85, 0), Color(0.5, 0.7, 1.0), 0.2, Vector3.ONE, Vector3.ZERO, Color(0.3, 0.5, 1.0))
		"dagger":
			var blade := BoxMesh.new()
			blade.size = Vector3(0.04, 0.32, 0.02)
			_add_part(blade, Vector3(0.40, 0.65, 0), Color(0.75, 0.75, 0.85), 0.2, Vector3.ONE, Vector3(0, 0, 5))

func _add_part(mesh: Mesh, pos: Vector3, color: Color, rough: float = 0.7, scale: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, emission: Color = Color(0, 0, 0)) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale
	mi.rotation_degrees = rot_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	if emission.a > 0.0 or emission.r + emission.g + emission.b > 0.01:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 1.5
	mi.material_override = mat
	add_child(mi)
