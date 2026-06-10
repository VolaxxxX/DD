class_name Player3D extends Node3D
# Stylised player avatar built from primitives. Used in char-create preview AND in-game.
# Reacts to injuries (slumps, bleeds, frosts, etc.) via apply_injuries().

var class_data: Dictionary
var skin_color: Color = Color(0.92, 0.78, 0.65)
var hair_color: Color = Color(0.30, 0.20, 0.15)
var _body_mi: MeshInstance3D
var _root: Node3D
var _injury_overlays: Node3D                 # everything added by injuries
var _tremor_tween: Tween

func build(cls: Dictionary, p_skin: Color = Color(0.92, 0.78, 0.65), p_hair: Color = Color(0.30, 0.20, 0.15)) -> void:
	class_data = cls
	skin_color = p_skin
	hair_color = p_hair
	for c in get_children(): c.queue_free()
	_root = Node3D.new()
	add_child(_root)
	# Try a per-class external GLB first.
	var loaded: Node3D = AssetLoader.instance_for_player(int(cls.kind))
	if loaded != null:
		_root.add_child(loaded)
		_normalize_player_scale(loaded)
		AssetLoader.play_named_action(loaded, &"idle", true)
		_injury_overlays = Node3D.new()
		add_child(_injury_overlays)
		return
	_build_body()
	_build_head()
	_build_arms()
	_build_legs()
	_build_accessory()
	_injury_overlays = Node3D.new()
	add_child(_injury_overlays)

func _normalize_player_scale(loaded: Node3D) -> void:
	var aabb := _aabb_of(loaded)
	if aabb.size.y > 0.001:
		var factor: float = 1.7 / aabb.size.y
		loaded.scale = loaded.scale * clampf(factor, 0.05, 50.0)
		var na := _aabb_of(loaded)
		loaded.position.y = -na.position.y

func _aabb_of(node: Node) -> AABB:
	var combined := AABB()
	var first := true
	for child in node.get_children():
		if child is MeshInstance3D:
			var mi: MeshInstance3D = child
			var a := mi.get_aabb()
			a.position = mi.transform * a.position
			a.size = mi.scale * a.size
			if first: combined = a; first = false
			else: combined = combined.merge(a)
		var sub := _aabb_of(child)
		if sub.size != Vector3.ZERO:
			if first: combined = sub; first = false
			else: combined = combined.merge(sub)
	return combined

func _build_body() -> void:
	var body := CapsuleMesh.new()
	body.radius = 0.22
	body.height = 0.85
	_body_mi = _add_part(body, Vector3(0, 0.95, 0), class_data.body_color, 0.7)

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

func _add_part(mesh: Mesh, pos: Vector3, color: Color, rough: float = 0.7, scale: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, emission: Color = Color(0, 0, 0)) -> MeshInstance3D:
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
	_root.add_child(mi)
	return mi

# ----------------------- Injury reactions -----------------------

func apply_injuries(injuries: Array) -> void:
	# Wipe any previous overlay nodes and rebuild from scratch.
	if _injury_overlays == null: return
	for c in _injury_overlays.get_children(): c.queue_free()
	if _tremor_tween and _tremor_tween.is_valid(): _tremor_tween.kill()
	_root.rotation_degrees = Vector3.ZERO
	_root.position = Vector3.ZERO

	var has_exhaustion := false
	for inj_id in injuries:
		match String(inj_id):
			"bleeding":    _add_blood()
			"broken_arm":  _add_sling()
			"terror":      _start_tremor()
			"curse":       _add_curse_wisps()
			"poison":      _tint_body(Color(0.55, 0.85, 0.50), 0.45)
			"exhaustion":  has_exhaustion = true
	if has_exhaustion:
		_root.rotation_degrees.x = 8.0     # slump forward
		_root.position.y = -0.05

func _overlay(mesh: Mesh, pos: Vector3, color: Color, emission_e: float = 0.0, scale_v: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh; mi.position = pos; mi.scale = scale_v
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color; mat.roughness = 0.5
	if emission_e > 0.0:
		mat.emission_enabled = true; mat.emission = color
		mat.emission_energy_multiplier = emission_e
	mi.material_override = mat
	_injury_overlays.add_child(mi)
	return mi

func _add_blood() -> void:
	for i in 5:
		var drop := SphereMesh.new(); drop.radius = 0.025; drop.height = 0.05
		var pos := Vector3(-0.1 + i * 0.05, 1.0 - i * 0.15, 0.22)
		_overlay(drop, pos, Color(0.55, 0.05, 0.05), 0.5)

func _add_sling() -> void:
	# White bandage across the chest + the right arm dangling lower.
	var sling := BoxMesh.new(); sling.size = Vector3(0.5, 0.07, 0.03)
	_overlay(sling, Vector3(0, 1.05, 0.20), Color(0.85, 0.82, 0.75), 0.0, Vector3.ONE).rotation_degrees = Vector3(0, 0, -22)
	# Dangling arm: small capsule replacing the bent posture.
	var arm := CapsuleMesh.new(); arm.radius = 0.07; arm.height = 0.5
	_overlay(arm, Vector3(0.30, 0.80, 0.18), class_data.body_color.darkened(0.3), 0.0, Vector3.ONE).rotation_degrees = Vector3(0, 0, -45)

func _start_tremor() -> void:
	_tremor_tween = create_tween().set_loops()
	_tremor_tween.tween_property(_root, "position:x", 0.015, 0.05)
	_tremor_tween.tween_property(_root, "position:x", -0.015, 0.05)
	_tremor_tween.tween_property(_root, "position:x", 0.0, 0.05)

func _add_curse_wisps() -> void:
	for i in 4:
		var ang := i * TAU / 4.0
		var w := SphereMesh.new(); w.radius = 0.06; w.height = 0.12
		_overlay(w, Vector3(cos(ang) * 0.4, 1.7 + sin(i) * 0.1, sin(ang) * 0.4), Color(0.55, 0.20, 0.85), 3.0)

func _tint_body(tint: Color, mix: float) -> void:
	# Retint the body mesh by replacing its material.
	if _body_mi == null: return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = class_data.body_color.lerp(tint, mix)
	mat.roughness = 0.65
	mat.emission_enabled = true
	mat.emission = tint
	mat.emission_energy_multiplier = 0.6
	_body_mi.material_override = mat
