class_name Creature3D extends Node3D
# Procedural 3D creature body built from primitives per family.
# Holds animation hooks for idle/attack/hit/die/flee reactions.

const FAMILY_COLOR := {
	Archetype.Family.HUMANOID:   Color(0.85, 0.75, 0.60),
	Archetype.Family.BEAST:      Color(0.50, 0.32, 0.20),
	Archetype.Family.UNDEAD:     Color(0.55, 0.58, 0.55),
	Archetype.Family.CONSTRUCT:  Color(0.55, 0.58, 0.66),
	Archetype.Family.ELEMENTAL:  Color(1.00, 0.55, 0.20),
	Archetype.Family.ABERRATION: Color(0.55, 0.25, 0.70),
	Archetype.Family.FEY:        Color(0.90, 0.72, 1.00),
	Archetype.Family.DRACONIC:   Color(0.70, 0.18, 0.18),
}

var archetype: Archetype
var body: Node3D
var _parts: Array[MeshInstance3D] = []
var _material: StandardMaterial3D
var _animator: Animator
var _base_y: float = 0.0
var _idle_started: bool = false

func build(_arch: Archetype) -> void:
	archetype = _arch
	body = Node3D.new()
	add_child(body)
	_material = _make_material()
	match archetype.family:
		Archetype.Family.HUMANOID:   _build_humanoid()
		Archetype.Family.BEAST:      _build_beast()
		Archetype.Family.UNDEAD:     _build_undead()
		Archetype.Family.CONSTRUCT:  _build_construct()
		Archetype.Family.ELEMENTAL:  _build_elemental()
		Archetype.Family.ABERRATION: _build_aberration()
		Archetype.Family.FEY:        _build_fey()
		Archetype.Family.DRACONIC:   _build_draconic()
	_apply_tier_scale()
	_animator = Animator.new()
	add_child(_animator)
	_animator.target = body
	_animator.start_idle()

func _make_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = FAMILY_COLOR.get(archetype.family, Color.WHITE)
	m.roughness = 0.7
	if archetype.family == Archetype.Family.ELEMENTAL:
		m.emission_enabled = true
		m.emission = Color(1.0, 0.6, 0.2)
		m.emission_energy_multiplier = 1.5
	elif archetype.family == Archetype.Family.ABERRATION:
		m.emission_enabled = true
		m.emission = Color(0.7, 0.2, 1.0)
		m.emission_energy_multiplier = 0.8
	elif archetype.family == Archetype.Family.FEY:
		m.emission_enabled = true
		m.emission = Color(0.9, 0.8, 1.0)
		m.emission_energy_multiplier = 0.6
	if archetype.tier >= Archetype.Tier.ELITE:
		m.emission_enabled = true
		m.emission_energy_multiplier += 1.0
	return m

func _add_part(mesh: Mesh, pos: Vector3, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _material
	mi.position = pos
	mi.scale = scale_v
	mi.rotation_degrees = rot_deg
	body.add_child(mi)
	_parts.append(mi)
	return mi

# ---------- Family builders ----------

func _build_humanoid() -> void:
	var head := SphereMesh.new(); head.radius = 0.22; head.height = 0.44
	_add_part(head, Vector3(0, 1.7, 0))
	var torso := BoxMesh.new(); torso.size = Vector3(0.45, 0.7, 0.25)
	_add_part(torso, Vector3(0, 1.15, 0))
	var leg_l := CylinderMesh.new(); leg_l.top_radius = 0.08; leg_l.bottom_radius = 0.08; leg_l.height = 0.7
	_add_part(leg_l, Vector3(-0.12, 0.45, 0))
	_add_part(leg_l, Vector3(0.12, 0.45, 0))
	var arm := CylinderMesh.new(); arm.top_radius = 0.07; arm.bottom_radius = 0.07; arm.height = 0.65
	_add_part(arm, Vector3(-0.3, 1.2, 0), Vector3.ONE, Vector3(0, 0, 15))
	_add_part(arm, Vector3(0.3, 1.2, 0), Vector3.ONE, Vector3(0, 0, -15))

func _build_beast() -> void:
	var body_m := CapsuleMesh.new(); body_m.radius = 0.35; body_m.height = 1.2
	_add_part(body_m, Vector3(0, 0.7, 0), Vector3.ONE, Vector3(0, 0, 90))
	var head := SphereMesh.new(); head.radius = 0.28; head.height = 0.56
	_add_part(head, Vector3(0.75, 0.85, 0))
	var leg := CylinderMesh.new(); leg.top_radius = 0.08; leg.bottom_radius = 0.08; leg.height = 0.55
	_add_part(leg, Vector3(0.35, 0.3, 0.2))
	_add_part(leg, Vector3(0.35, 0.3, -0.2))
	_add_part(leg, Vector3(-0.35, 0.3, 0.2))
	_add_part(leg, Vector3(-0.35, 0.3, -0.2))
	var tail := CylinderMesh.new(); tail.top_radius = 0.02; tail.bottom_radius = 0.12; tail.height = 0.6
	_add_part(tail, Vector3(-0.8, 0.9, 0), Vector3.ONE, Vector3(0, 0, -60))

func _build_undead() -> void:
	var skull := SphereMesh.new(); skull.radius = 0.24; skull.height = 0.48
	var s := _add_part(skull, Vector3(0, 1.65, 0))
	var pale := _material.duplicate() as StandardMaterial3D
	pale.albedo_color = Color(0.9, 0.88, 0.8)
	s.material_override = pale
	var cloak := BoxMesh.new(); cloak.size = Vector3(0.6, 1.2, 0.15)
	_add_part(cloak, Vector3(0, 0.9, 0))
	var tatter := BoxMesh.new(); tatter.size = Vector3(0.22, 0.45, 0.08)
	_add_part(tatter, Vector3(-0.25, 0.35, 0.05), Vector3.ONE, Vector3(0, 0, 10))
	_add_part(tatter, Vector3(0.2, 0.3, -0.04), Vector3.ONE, Vector3(0, 0, -8))
	var arm := BoxMesh.new(); arm.size = Vector3(0.1, 0.6, 0.1)
	_add_part(arm, Vector3(-0.4, 1.1, 0), Vector3.ONE, Vector3(0, 0, 20))
	_add_part(arm, Vector3(0.4, 1.1, 0), Vector3.ONE, Vector3(0, 0, -20))

func _build_construct() -> void:
	var base := BoxMesh.new(); base.size = Vector3(0.7, 0.4, 0.5)
	_add_part(base, Vector3(0, 0.2, 0))
	var core := BoxMesh.new(); core.size = Vector3(0.55, 0.8, 0.45)
	_add_part(core, Vector3(0, 0.85, 0))
	var head := BoxMesh.new(); head.size = Vector3(0.35, 0.35, 0.35)
	_add_part(head, Vector3(0, 1.45, 0))
	var arm := BoxMesh.new(); arm.size = Vector3(0.18, 0.7, 0.18)
	_add_part(arm, Vector3(-0.45, 0.95, 0))
	_add_part(arm, Vector3(0.45, 0.95, 0))
	var eye := SphereMesh.new(); eye.radius = 0.06; eye.height = 0.12
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1, 0.6, 0.2)
	glow.emission_enabled = true
	glow.emission = Color(1, 0.8, 0.3)
	glow.emission_energy_multiplier = 3.0
	var e := _add_part(eye, Vector3(0, 1.45, 0.2))
	e.material_override = glow

func _build_elemental() -> void:
	var core := SphereMesh.new(); core.radius = 0.35; core.height = 0.7
	_add_part(core, Vector3(0, 1.1, 0))
	var orb := SphereMesh.new(); orb.radius = 0.12; orb.height = 0.24
	_add_part(orb, Vector3(-0.4, 1.4, 0))
	_add_part(orb, Vector3(0.4, 0.9, 0))
	_add_part(orb, Vector3(0, 1.6, -0.2))
	_add_part(orb, Vector3(0.2, 0.6, 0.2))

func _build_aberration() -> void:
	var main := SphereMesh.new(); main.radius = 0.45; main.height = 0.9
	_add_part(main, Vector3(0, 1.0, 0))
	var nub := SphereMesh.new(); nub.radius = 0.15; nub.height = 0.3
	_add_part(nub, Vector3(-0.4, 1.3, 0.2))
	_add_part(nub, Vector3(0.35, 1.25, -0.2))
	_add_part(nub, Vector3(0.1, 0.5, 0.3))
	var tent := CylinderMesh.new(); tent.top_radius = 0.03; tent.bottom_radius = 0.1; tent.height = 0.8
	_add_part(tent, Vector3(-0.3, 0.8, 0.3), Vector3.ONE, Vector3(30, 0, 30))
	_add_part(tent, Vector3(0.3, 0.8, -0.3), Vector3.ONE, Vector3(-20, 0, -30))

func _build_fey() -> void:
	var head := SphereMesh.new(); head.radius = 0.16; head.height = 0.32
	_add_part(head, Vector3(0, 1.55, 0))
	var torso := CapsuleMesh.new(); torso.radius = 0.14; torso.height = 0.7
	_add_part(torso, Vector3(0, 1.05, 0))
	var leg := CylinderMesh.new(); leg.top_radius = 0.05; leg.bottom_radius = 0.05; leg.height = 0.55
	_add_part(leg, Vector3(-0.08, 0.4, 0))
	_add_part(leg, Vector3(0.08, 0.4, 0))
	var wing := PrismMesh.new(); wing.size = Vector3(0.5, 0.6, 0.05)
	_add_part(wing, Vector3(-0.25, 1.2, -0.1), Vector3.ONE, Vector3(0, 0, 25))
	_add_part(wing, Vector3(0.25, 1.2, -0.1), Vector3.ONE, Vector3(0, 180, -25))

func _build_draconic() -> void:
	var body_m := CapsuleMesh.new(); body_m.radius = 0.5; body_m.height = 1.8
	_add_part(body_m, Vector3(0, 0.9, 0), Vector3.ONE, Vector3(0, 0, 90))
	var neck := CylinderMesh.new(); neck.top_radius = 0.25; neck.bottom_radius = 0.35; neck.height = 0.8
	_add_part(neck, Vector3(0.9, 1.4, 0), Vector3.ONE, Vector3(0, 0, -60))
	var head := BoxMesh.new(); head.size = Vector3(0.55, 0.35, 0.35)
	_add_part(head, Vector3(1.4, 1.8, 0))
	var wing := PrismMesh.new(); wing.size = Vector3(1.4, 1.2, 0.08)
	_add_part(wing, Vector3(-0.1, 1.5, -0.5), Vector3.ONE, Vector3(0, 0, 30))
	_add_part(wing, Vector3(-0.1, 1.5, 0.5), Vector3.ONE, Vector3(0, 180, -30))
	var tail := CylinderMesh.new(); tail.top_radius = 0.05; tail.bottom_radius = 0.25; tail.height = 1.2
	_add_part(tail, Vector3(-1.3, 1.0, 0), Vector3.ONE, Vector3(0, 0, -70))
	var leg := CylinderMesh.new(); leg.top_radius = 0.15; leg.bottom_radius = 0.15; leg.height = 0.7
	_add_part(leg, Vector3(0.4, 0.4, 0.3))
	_add_part(leg, Vector3(0.4, 0.4, -0.3))
	_add_part(leg, Vector3(-0.4, 0.4, 0.3))
	_add_part(leg, Vector3(-0.4, 0.4, -0.3))

func _apply_tier_scale() -> void:
	var s := 1.0 + float(archetype.tier) * 0.12
	body.scale = Vector3.ONE * s

# ---------- Reactions driven by SceneDirector ----------

func react(reaction: StringName) -> void:
	if _animator == null: return
	match reaction:
		&"die":    _animator.play_die()
		&"flee":   _animator.play_flee()
		&"hit":    _animator.play_hit()
		&"mutate": _animator.play_mutate()
		_:         pass
