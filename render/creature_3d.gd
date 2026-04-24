class_name Creature3D extends Node3D
# Procedural 3D creature: layered primitives with accent material + glowing eyes.

const FAMILY_COLOR := {
	Archetype.Family.HUMANOID:   Color(0.78, 0.62, 0.48),
	Archetype.Family.BEAST:      Color(0.45, 0.28, 0.18),
	Archetype.Family.UNDEAD:     Color(0.55, 0.58, 0.55),
	Archetype.Family.CONSTRUCT:  Color(0.50, 0.55, 0.62),
	Archetype.Family.ELEMENTAL:  Color(1.00, 0.45, 0.15),
	Archetype.Family.ABERRATION: Color(0.55, 0.20, 0.70),
	Archetype.Family.FEY:        Color(0.85, 0.65, 1.00),
	Archetype.Family.DRACONIC:   Color(0.65, 0.15, 0.15),
}

const FAMILY_ACCENT := {
	Archetype.Family.HUMANOID:   Color(0.40, 0.30, 0.20),
	Archetype.Family.BEAST:      Color(0.20, 0.12, 0.06),
	Archetype.Family.UNDEAD:     Color(0.92, 0.90, 0.82),
	Archetype.Family.CONSTRUCT:  Color(0.30, 0.32, 0.36),
	Archetype.Family.ELEMENTAL:  Color(1.00, 0.85, 0.40),
	Archetype.Family.ABERRATION: Color(0.20, 0.05, 0.35),
	Archetype.Family.FEY:        Color(1.00, 0.95, 0.85),
	Archetype.Family.DRACONIC:   Color(0.25, 0.06, 0.06),
}

const EYE_COLOR := {
	Archetype.Family.HUMANOID:   Color(0.10, 0.10, 0.10),
	Archetype.Family.BEAST:      Color(1.00, 0.85, 0.30),
	Archetype.Family.UNDEAD:     Color(0.55, 0.95, 1.00),
	Archetype.Family.CONSTRUCT:  Color(1.00, 0.55, 0.20),
	Archetype.Family.ELEMENTAL:  Color(1.00, 0.95, 0.60),
	Archetype.Family.ABERRATION: Color(1.00, 0.30, 0.85),
	Archetype.Family.FEY:        Color(0.85, 1.00, 0.85),
	Archetype.Family.DRACONIC:   Color(1.00, 0.45, 0.15),
}

var archetype: Archetype
var body: Node3D
var _parts: Array[MeshInstance3D] = []
var _material: StandardMaterial3D
var _accent: StandardMaterial3D
var _animator: Animator

func build(_arch: Archetype) -> void:
	archetype = _arch
	body = Node3D.new()
	add_child(body)
	_material = _make_material(FAMILY_COLOR.get(archetype.family, Color.WHITE), 0.7, false)
	_accent = _make_material(FAMILY_ACCENT.get(archetype.family, Color.WHITE), 0.6, false)
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

func _make_material(col: Color, rough: float, glow: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	if glow or archetype == null: pass
	if archetype != null:
		var f := archetype.family
		if f == Archetype.Family.ELEMENTAL:
			m.emission_enabled = true
			m.emission = Color(1.0, 0.6, 0.2)
			m.emission_energy_multiplier = 1.4
		elif f == Archetype.Family.ABERRATION:
			m.emission_enabled = true
			m.emission = Color(0.7, 0.2, 1.0)
			m.emission_energy_multiplier = 0.7
		elif f == Archetype.Family.FEY:
			m.emission_enabled = true
			m.emission = Color(0.9, 0.8, 1.0)
			m.emission_energy_multiplier = 0.5
		if archetype.tier >= Archetype.Tier.ELITE:
			m.emission_enabled = true
			m.emission_energy_multiplier += 0.8
	return m

func _add(mesh: Mesh, pos: Vector3, mat: StandardMaterial3D = null, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat if mat != null else _material
	mi.position = pos
	mi.scale = scale_v
	mi.rotation_degrees = rot_deg
	body.add_child(mi)
	_parts.append(mi)
	return mi

func _add_eye(pos: Vector3, radius: float = 0.05) -> void:
	var eye := SphereMesh.new()
	eye.radius = radius; eye.height = radius * 2
	var glow := StandardMaterial3D.new()
	glow.albedo_color = EYE_COLOR.get(archetype.family, Color(1, 1, 1))
	glow.emission_enabled = true
	glow.emission = EYE_COLOR.get(archetype.family, Color(1, 1, 1))
	glow.emission_energy_multiplier = 4.0
	_add(eye, pos, glow)

# ---------- Family builders ----------

func _build_humanoid() -> void:
	var head := SphereMesh.new(); head.radius = 0.22; head.height = 0.44
	_add(head, Vector3(0, 1.65, 0))
	var torso := CapsuleMesh.new(); torso.radius = 0.24; torso.height = 0.85
	_add(torso, Vector3(0, 1.05, 0), _accent)
	var pant := CapsuleMesh.new(); pant.radius = 0.12; pant.height = 0.7
	_add(pant, Vector3(-0.13, 0.45, 0))
	_add(pant, Vector3(0.13, 0.45, 0))
	var arm := CapsuleMesh.new(); arm.radius = 0.07; arm.height = 0.65
	_add(arm, Vector3(-0.32, 1.05, 0), _accent, Vector3.ONE, Vector3(0, 0, 12))
	_add(arm, Vector3(0.32, 1.05, 0), _accent, Vector3.ONE, Vector3(0, 0, -12))
	var hand := SphereMesh.new(); hand.radius = 0.08; hand.height = 0.16
	_add(hand, Vector3(-0.40, 0.72, 0))
	_add(hand, Vector3(0.40, 0.72, 0))
	var boot := BoxMesh.new(); boot.size = Vector3(0.20, 0.10, 0.24)
	_add(boot, Vector3(-0.13, 0.05, 0.04), _accent)
	_add(boot, Vector3(0.13, 0.05, 0.04), _accent)
	_add_eye(Vector3(-0.07, 1.70, 0.20), 0.035)
	_add_eye(Vector3(0.07, 1.70, 0.20), 0.035)

func _build_beast() -> void:
	var torso := CapsuleMesh.new(); torso.radius = 0.38; torso.height = 1.3
	_add(torso, Vector3(0, 0.7, 0), _material, Vector3.ONE, Vector3(0, 0, 90))
	var head := SphereMesh.new(); head.radius = 0.30; head.height = 0.6
	_add(head, Vector3(0.78, 0.85, 0))
	var snout := BoxMesh.new(); snout.size = Vector3(0.30, 0.18, 0.20)
	_add(snout, Vector3(1.00, 0.78, 0), _accent)
	var ear := PrismMesh.new(); ear.size = Vector3(0.12, 0.22, 0.08)
	_add(ear, Vector3(0.65, 1.10, 0.18), _accent, Vector3.ONE, Vector3(0, 0, -10))
	_add(ear, Vector3(0.65, 1.10, -0.18), _accent, Vector3.ONE, Vector3(0, 0, -10))
	var leg := CylinderMesh.new(); leg.top_radius = 0.09; leg.bottom_radius = 0.09; leg.height = 0.55
	_add(leg, Vector3(0.40, 0.28, 0.22), _accent)
	_add(leg, Vector3(0.40, 0.28, -0.22), _accent)
	_add(leg, Vector3(-0.40, 0.28, 0.22), _accent)
	_add(leg, Vector3(-0.40, 0.28, -0.22), _accent)
	var tail := CylinderMesh.new(); tail.top_radius = 0.02; tail.bottom_radius = 0.13; tail.height = 0.7
	_add(tail, Vector3(-0.85, 0.95, 0), _material, Vector3.ONE, Vector3(0, 0, -55))
	_add_eye(Vector3(0.92, 0.95, 0.18), 0.05)
	_add_eye(Vector3(0.92, 0.95, -0.18), 0.05)

func _build_undead() -> void:
	var hood := SphereMesh.new(); hood.radius = 0.30; hood.height = 0.55
	_add(hood, Vector3(0, 1.55, 0), _accent, Vector3(1, 1.1, 1))
	var skull := SphereMesh.new(); skull.radius = 0.20; skull.height = 0.40
	_add(skull, Vector3(0, 1.50, 0.10))
	var cloak := BoxMesh.new(); cloak.size = Vector3(0.7, 1.25, 0.18)
	_add(cloak, Vector3(0, 0.85, 0), _accent)
	var tatter := BoxMesh.new(); tatter.size = Vector3(0.20, 0.50, 0.08)
	_add(tatter, Vector3(-0.27, 0.30, 0.06), _accent, Vector3.ONE, Vector3(0, 0, 8))
	_add(tatter, Vector3(0.22, 0.25, -0.04), _accent, Vector3.ONE, Vector3(0, 0, -6))
	var arm := BoxMesh.new(); arm.size = Vector3(0.10, 0.65, 0.10)
	_add(arm, Vector3(-0.42, 1.0, 0), _accent, Vector3.ONE, Vector3(0, 0, 18))
	_add(arm, Vector3(0.42, 1.0, 0), _accent, Vector3.ONE, Vector3(0, 0, -18))
	_add_eye(Vector3(-0.07, 1.55, 0.30), 0.04)
	_add_eye(Vector3(0.07, 1.55, 0.30), 0.04)

func _build_construct() -> void:
	var base := BoxMesh.new(); base.size = Vector3(0.75, 0.4, 0.55)
	_add(base, Vector3(0, 0.2, 0), _accent)
	var core := BoxMesh.new(); core.size = Vector3(0.60, 0.85, 0.50)
	_add(core, Vector3(0, 0.85, 0))
	var bevel := BoxMesh.new(); bevel.size = Vector3(0.66, 0.10, 0.56)
	_add(bevel, Vector3(0, 1.30, 0), _accent)
	var head := BoxMesh.new(); head.size = Vector3(0.38, 0.36, 0.38)
	_add(head, Vector3(0, 1.55, 0))
	var arm := BoxMesh.new(); arm.size = Vector3(0.18, 0.75, 0.18)
	_add(arm, Vector3(-0.48, 0.95, 0), _accent)
	_add(arm, Vector3(0.48, 0.95, 0), _accent)
	var fist := BoxMesh.new(); fist.size = Vector3(0.24, 0.22, 0.24)
	_add(fist, Vector3(-0.48, 0.5, 0))
	_add(fist, Vector3(0.48, 0.5, 0))
	_add_eye(Vector3(0, 1.55, 0.21), 0.07)

func _build_elemental() -> void:
	var core := SphereMesh.new(); core.radius = 0.38; core.height = 0.76
	_add(core, Vector3(0, 1.1, 0))
	var halo := TorusMesh.new(); halo.inner_radius = 0.45; halo.outer_radius = 0.55
	_add(halo, Vector3(0, 1.1, 0), _accent, Vector3.ONE, Vector3(70, 0, 20))
	var orb := SphereMesh.new(); orb.radius = 0.13; orb.height = 0.26
	_add(orb, Vector3(-0.42, 1.45, 0))
	_add(orb, Vector3(0.42, 0.85, 0))
	_add(orb, Vector3(0, 1.65, -0.20))
	_add(orb, Vector3(0.20, 0.55, 0.20))
	_add(orb, Vector3(-0.30, 0.7, -0.15))

func _build_aberration() -> void:
	var main := SphereMesh.new(); main.radius = 0.50; main.height = 1.0
	_add(main, Vector3(0, 1.0, 0))
	var nub := SphereMesh.new(); nub.radius = 0.16; nub.height = 0.32
	_add(nub, Vector3(-0.42, 1.30, 0.20), _accent)
	_add(nub, Vector3(0.36, 1.25, -0.20), _accent)
	_add(nub, Vector3(0.10, 0.50, 0.32), _accent)
	var tent := CylinderMesh.new(); tent.top_radius = 0.03; tent.bottom_radius = 0.10; tent.height = 0.85
	_add(tent, Vector3(-0.32, 0.78, 0.30), _accent, Vector3.ONE, Vector3(28, 0, 32))
	_add(tent, Vector3(0.32, 0.78, -0.30), _accent, Vector3.ONE, Vector3(-22, 0, -32))
	_add(tent, Vector3(0, 0.55, 0.40), _accent, Vector3.ONE, Vector3(40, 0, 0))
	# multi-eyes
	for off in [Vector3(-0.18, 1.15, 0.42), Vector3(0.18, 1.15, 0.42), Vector3(0, 1.30, 0.40), Vector3(-0.05, 0.95, 0.46)]:
		_add_eye(off, 0.05)

func _build_fey() -> void:
	var head := SphereMesh.new(); head.radius = 0.17; head.height = 0.34
	_add(head, Vector3(0, 1.55, 0))
	var torso := CapsuleMesh.new(); torso.radius = 0.15; torso.height = 0.7
	_add(torso, Vector3(0, 1.05, 0), _accent)
	var leg := CylinderMesh.new(); leg.top_radius = 0.05; leg.bottom_radius = 0.05; leg.height = 0.6
	_add(leg, Vector3(-0.08, 0.40, 0))
	_add(leg, Vector3(0.08, 0.40, 0))
	var wing := PrismMesh.new(); wing.size = Vector3(0.55, 0.7, 0.04)
	_add(wing, Vector3(-0.28, 1.20, -0.10), _material, Vector3.ONE, Vector3(0, 0, 22))
	_add(wing, Vector3(0.28, 1.20, -0.10), _material, Vector3.ONE, Vector3(0, 180, -22))
	# crown
	var crown := PrismMesh.new(); crown.size = Vector3(0.20, 0.12, 0.06)
	_add(crown, Vector3(0, 1.74, 0), _accent)
	_add_eye(Vector3(-0.06, 1.58, 0.16), 0.030)
	_add_eye(Vector3(0.06, 1.58, 0.16), 0.030)

func _build_draconic() -> void:
	var torso := CapsuleMesh.new(); torso.radius = 0.50; torso.height = 1.9
	_add(torso, Vector3(0, 0.95, 0), _material, Vector3.ONE, Vector3(0, 0, 90))
	var neck := CylinderMesh.new(); neck.top_radius = 0.22; neck.bottom_radius = 0.36; neck.height = 0.85
	_add(neck, Vector3(0.95, 1.45, 0), _material, Vector3.ONE, Vector3(0, 0, -55))
	var head := BoxMesh.new(); head.size = Vector3(0.55, 0.36, 0.36)
	_add(head, Vector3(1.45, 1.85, 0))
	var jaw := BoxMesh.new(); jaw.size = Vector3(0.50, 0.14, 0.32)
	_add(jaw, Vector3(1.50, 1.66, 0), _accent)
	# horns
	var horn := PrismMesh.new(); horn.size = Vector3(0.10, 0.35, 0.10)
	_add(horn, Vector3(1.30, 2.10, 0.12), _accent, Vector3.ONE, Vector3(0, 0, -10))
	_add(horn, Vector3(1.30, 2.10, -0.12), _accent, Vector3.ONE, Vector3(0, 0, -10))
	# wings
	var wing := PrismMesh.new(); wing.size = Vector3(1.5, 1.3, 0.08)
	_add(wing, Vector3(-0.10, 1.55, -0.55), _accent, Vector3.ONE, Vector3(0, 0, 30))
	_add(wing, Vector3(-0.10, 1.55, 0.55), _accent, Vector3.ONE, Vector3(0, 180, -30))
	var tail := CylinderMesh.new(); tail.top_radius = 0.06; tail.bottom_radius = 0.28; tail.height = 1.3
	_add(tail, Vector3(-1.35, 1.05, 0), _material, Vector3.ONE, Vector3(0, 0, -68))
	var leg := CylinderMesh.new(); leg.top_radius = 0.16; leg.bottom_radius = 0.16; leg.height = 0.75
	_add(leg, Vector3(0.45, 0.42, 0.32), _accent)
	_add(leg, Vector3(0.45, 0.42, -0.32), _accent)
	_add(leg, Vector3(-0.45, 0.42, 0.32), _accent)
	_add(leg, Vector3(-0.45, 0.42, -0.32), _accent)
	_add_eye(Vector3(1.55, 1.92, 0.16), 0.06)
	_add_eye(Vector3(1.55, 1.92, -0.16), 0.06)

func _apply_tier_scale() -> void:
	var s := 1.0 + float(archetype.tier) * 0.12
	body.scale = Vector3.ONE * s

func react(reaction: StringName) -> void:
	if _animator == null: return
	match reaction:
		&"die":    _animator.play_die()
		&"flee":   _animator.play_flee()
		&"hit":    _animator.play_hit()
		&"mutate": _animator.play_mutate()
