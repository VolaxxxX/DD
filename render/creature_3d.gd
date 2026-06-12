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

# Per-id visual overrides.  Each entry can carry: color, accent, eye, scale,
# and a list of "feats" — discrete decorations added on top of the family base.
const ID_VISUAL := {
	# --- HUMANOID ---
	&"gutter_scavenger":  {"color": Color(0.40, 0.35, 0.25), "feats": [&"hood", &"dagger_held"]},
	&"hooded_outlaw":     {"color": Color(0.30, 0.25, 0.20), "feats": [&"hood", &"sword_held"]},
	&"ash_inquisitor":    {"color": Color(0.85, 0.85, 0.80), "feats": [&"mask", &"halo"]},
	&"sunken_hermit":     {"color": Color(0.45, 0.40, 0.30), "feats": [&"hood", &"staff_held"]},
	&"flesh_broker":      {"color": Color(0.60, 0.20, 0.20), "feats": [&"mask", &"vines"]},
	&"nameless_pilgrim":  {"color": Color(0.20, 0.20, 0.25), "feats": [&"hood", &"halo", &"staff_held"]},
	&"bog_witch":         {"color": Color(0.20, 0.30, 0.18), "feats": [&"hood", &"staff_held", &"flame_aura"]},
	&"sky_skald":         {"color": Color(0.65, 0.60, 0.45), "feats": [&"crown", &"staff_held"]},
	&"reef_priestess":    {"color": Color(0.30, 0.55, 0.65), "feats": [&"halo", &"vines"]},

	# --- BEAST ---
	&"dire_wolf":         {"color": Color(0.30, 0.22, 0.18), "eye": Color(1.0, 0.20, 0.20), "feats": [&"fangs", &"spikes_back"]},
	&"thornback_stag":    {"color": Color(0.50, 0.30, 0.18), "feats": [&"antlers", &"spikes_back"]},
	&"blood_crow_swarm":  {"color": Color(0.20, 0.10, 0.10), "feats": [&"swarm_orbs"]},
	&"plague_hound":      {"color": Color(0.45, 0.55, 0.30), "feats": [&"fangs", &"flame_aura"]},
	&"sandstalker":       {"color": Color(0.75, 0.65, 0.40), "feats": [&"fangs", &"tail_blade"]},
	&"mother_leech":      {"color": Color(0.55, 0.20, 0.20), "feats": [&"many_eyes"]},
	&"old_wood_stag":     {"color": Color(0.35, 0.45, 0.20), "feats": [&"antlers", &"halo", &"vines"]},
	&"mountain_lion":     {"color": Color(0.55, 0.45, 0.30), "feats": [&"fangs"]},
	&"giant_eagle":       {"color": Color(0.75, 0.70, 0.55), "feats": [&"wings_pair"]},
	&"toad_king":         {"color": Color(0.30, 0.55, 0.25), "feats": [&"crown", &"fangs"]},

	# --- UNDEAD ---
	&"wight":             {"color": Color(0.55, 0.55, 0.55), "feats": [&"hood"]},
	&"ash_revenant":      {"color": Color(0.30, 0.20, 0.18), "feats": [&"flame_aura"]},
	&"bone_choir":        {"color": Color(0.85, 0.82, 0.72), "feats": [&"skull_stack"]},
	&"drowned_herald":    {"color": Color(0.30, 0.40, 0.45), "feats": [&"hood", &"halo"]},
	&"lich_scholar":      {"color": Color(0.35, 0.30, 0.50), "feats": [&"hood", &"book_floating"]},
	&"whisper_shade":     {"color": Color(0.05, 0.05, 0.10), "eye": Color(1.0, 1.0, 1.0), "feats": [&"hood"]},
	&"tomb_ghoul":        {"color": Color(0.45, 0.40, 0.30), "feats": [&"fangs"]},
	&"sealed_lord":       {"color": Color(0.20, 0.20, 0.30), "feats": [&"crown", &"sword_held", &"halo"]},
	&"crypt_wraith":      {"color": Color(0.20, 0.25, 0.30), "feats": [&"hood", &"flame_aura"]},
	&"drowned_sailor":    {"color": Color(0.30, 0.35, 0.45), "feats": [&"vines"]},

	# --- CONSTRUCT ---
	&"clockwork_sentinel":{"color": Color(0.55, 0.45, 0.25), "feats": [&"gear_face", &"sword_held"]},
	&"marble_guardian":   {"color": Color(0.85, 0.82, 0.78), "feats": [&"crown"]},
	&"thought_engine":    {"color": Color(0.30, 0.35, 0.50), "feats": [&"glow_orb"]},
	&"stitched_golem":    {"color": Color(0.55, 0.30, 0.30), "feats": [&"vines", &"fangs"]},
	&"singing_automaton": {"color": Color(0.60, 0.55, 0.30), "feats": [&"halo", &"glow_orb"]},

	# --- ELEMENTAL ---
	&"ember_sprite":      {"color": Color(1.0, 0.55, 0.20), "feats": [&"flame_aura"]},
	&"frost_herald":      {"color": Color(0.65, 0.85, 1.0), "feats": [&"halo"]},
	&"stone_lord":        {"color": Color(0.55, 0.50, 0.45), "feats": [&"crown"]},
	&"storm_rider":       {"color": Color(0.45, 0.55, 0.85), "feats": [&"halo", &"flame_aura"]},
	&"void_spark":        {"color": Color(0.20, 0.05, 0.30), "feats": [&"halo", &"glow_orb"]},
	&"will_o_wisp":       {"color": Color(0.65, 1.0, 0.85), "feats": [&"flame_aura", &"glow_orb"]},

	# --- ABERRATION ---
	&"mind_thief":        {"color": Color(0.35, 0.20, 0.55), "feats": [&"third_eye", &"many_eyes"]},
	&"fleshwarp":         {"color": Color(0.55, 0.25, 0.30), "feats": [&"vines", &"fangs"]},
	&"thousand_eye":      {"color": Color(0.30, 0.20, 0.45), "feats": [&"many_eyes", &"third_eye"]},
	&"echo_parasite":     {"color": Color(0.50, 0.30, 0.70), "feats": [&"swarm_orbs"]},
	&"the_nameless":      {"color": Color(0.05, 0.02, 0.12), "feats": [&"halo", &"third_eye"]},
	&"tessellation":      {"color": Color(0.45, 0.45, 0.85), "feats": [&"halo", &"glow_orb"]},
	&"tide_horror":       {"color": Color(0.20, 0.30, 0.40), "feats": [&"many_eyes", &"vines"]},

	# --- FEY ---
	&"thorn_duchess":     {"color": Color(0.60, 0.30, 0.55), "feats": [&"crown", &"vines"]},
	&"pale_jester":       {"color": Color(0.95, 0.95, 0.85), "feats": [&"mask", &"bell"]},
	&"dream_weaver":      {"color": Color(0.85, 0.65, 1.0), "feats": [&"halo", &"glow_orb"]},
	&"market_faer":       {"color": Color(0.95, 0.80, 0.50), "feats": [&"crown", &"glow_orb"]},
	&"hollow_child":      {"color": Color(0.85, 0.85, 0.90), "feats": [&"mask"]},
}

var archetype: Archetype
var body: Node3D
var _parts: Array[MeshInstance3D] = []
var _material: StandardMaterial3D
var _accent: StandardMaterial3D
var _animator: Animator
var _eye_color: Color = Color(1, 1, 1)
var _head_pos: Vector3 = Vector3(0, 1.6, 0)
var _head_radius: float = 0.20
var _imported_root: Node3D = null

func _normalize_imported_scale(loaded: Node3D) -> void:
	# Many imported GLBs have wildly different export scales (1 unit = 1m or 1cm
	# or 100x). We probe AABB once and shrink to ~1.8m tall target.
	var aabb := _aabb_of(loaded)
	var size_y: float = aabb.size.y
	if size_y > 0.001:
		var target := 1.7
		var factor: float = target / size_y
		# Clamp to a reasonable range so micro-jitter doesn't run wild.
		factor = clampf(factor, 0.05, 50.0)
		loaded.scale = loaded.scale * factor
		# Snap to ground.
		var new_aabb := _aabb_of(loaded)
		loaded.position.y = -new_aabb.position.y

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

func build(_arch: Archetype) -> void:
	archetype = _arch
	body = Node3D.new()
	add_child(body)
	# Try external GLB first.
	var loaded: Node3D = AssetLoader.instance_for_creature(archetype.id, int(archetype.family))
	if loaded != null:
		body.add_child(loaded)
		_imported_root = loaded
		_normalize_imported_scale(loaded)
		AssetLoader.play_named_action(loaded, &"idle", true)
		_apply_tier_scale()
		_animator = Animator.new()
		add_child(_animator)
		_animator.target = body
		_animator.start_idle()
		return
	var override: Dictionary = ID_VISUAL.get(archetype.id, {})
	var col: Color = override.get("color", FAMILY_COLOR.get(archetype.family, Color.WHITE))
	var acc: Color = override.get("accent", FAMILY_ACCENT.get(archetype.family, Color.WHITE))
	_eye_color = override.get("eye", EYE_COLOR.get(archetype.family, Color.WHITE))
	# Per-individual variance: deterministic jitter from the spawn seed so each
	# instance of the same creature looks subtly distinct.
	var seed_h: int = (Time.get_ticks_usec() * 2654435761) & 0xFFFFFFFF
	var hue_shift: float = (float(seed_h % 1000) / 1000.0 - 0.5) * 0.08
	var sat_shift: float = (float((seed_h >> 10) % 1000) / 1000.0 - 0.5) * 0.10
	var val_shift: float = (float((seed_h >> 20) % 1000) / 1000.0 - 0.5) * 0.10
	col = _shift_color(col, hue_shift, sat_shift, val_shift)
	acc = _shift_color(acc, hue_shift * 0.5, sat_shift, val_shift)
	_material = _make_material(col, 0.7, false)
	_accent = _make_material(acc, 0.6, false)
	body.scale = Vector3.ONE * (0.95 + float((seed_h >> 4) % 1000) / 10000.0)
	match archetype.family:
		Archetype.Family.HUMANOID:   _build_humanoid()
		Archetype.Family.BEAST:      _build_beast()
		Archetype.Family.UNDEAD:     _build_undead()
		Archetype.Family.CONSTRUCT:  _build_construct()
		Archetype.Family.ELEMENTAL:  _build_elemental()
		Archetype.Family.ABERRATION: _build_aberration()
		Archetype.Family.FEY:        _build_fey()
		Archetype.Family.DRACONIC:   _build_draconic()
	_apply_feats(override.get("feats", []))
	_apply_tier_scale()
	_apply_outline()
	_animator = Animator.new()
	add_child(_animator)
	_animator.target = body
	_animator.start_idle()

static func _shift_color(c: Color, dh: float, ds: float, dv: float) -> Color:
	var h := c.h + dh
	var s := clampf(c.s + ds, 0.0, 1.0)
	var v := clampf(c.v + dv, 0.0, 1.0)
	return Color.from_hsv(fposmod(h, 1.0), s, v, c.a)

func _apply_outline() -> void:
	# Inverted-hull outline: clone every mesh, flip culling and slightly enlarge.
	for child in body.get_children():
		if not (child is MeshInstance3D): continue
		var orig := child as MeshInstance3D
		var shell := MeshInstance3D.new()
		shell.mesh = orig.mesh
		shell.transform = orig.transform
		shell.scale = orig.scale * 1.06
		var om := StandardMaterial3D.new()
		om.albedo_color = Color(0.04, 0.03, 0.06)
		om.cull_mode = BaseMaterial3D.CULL_FRONT
		om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shell.material_override = om
		body.add_child(shell)

func _make_material(col: Color, rough: float, glow: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	# Per-family surface properties break the plastic look.
	if archetype != null:
		var f := archetype.family
		match f:
			Archetype.Family.HUMANOID:
				m.roughness = 0.65; m.metallic = 0.05
			Archetype.Family.BEAST:
				m.roughness = 0.85; m.metallic = 0.0
				m.rim_enabled = true; m.rim = 0.4; m.rim_tint = 0.2     # subsurface-ish wet fur
			Archetype.Family.UNDEAD:
				m.roughness = 0.92; m.metallic = 0.0
			Archetype.Family.CONSTRUCT:
				m.roughness = 0.35; m.metallic = 0.6                    # metallic armor
				m.metallic_specular = 0.7
			Archetype.Family.ELEMENTAL:
				m.roughness = 0.30; m.metallic = 0.0
				m.emission_enabled = true; m.emission = Color(1.0, 0.6, 0.2)
				m.emission_energy_multiplier = 1.6
			Archetype.Family.ABERRATION:
				m.roughness = 0.45; m.metallic = 0.1
				m.emission_enabled = true; m.emission = Color(0.7, 0.2, 1.0)
				m.emission_energy_multiplier = 0.8
				m.rim_enabled = true; m.rim = 0.5; m.rim_tint = 0.5      # eldritch sheen
			Archetype.Family.FEY:
				m.roughness = 0.55; m.metallic = 0.0
				m.emission_enabled = true; m.emission = Color(0.9, 0.8, 1.0)
				m.emission_energy_multiplier = 0.6
				m.rim_enabled = true; m.rim = 0.6; m.rim_tint = 0.3      # ethereal glow on edges
			Archetype.Family.DRACONIC:
				m.roughness = 0.40; m.metallic = 0.4                    # scaly armor
				m.metallic_specular = 0.6
				m.rim_enabled = true; m.rim = 0.3; m.rim_tint = 0.1
		if archetype.tier >= Archetype.Tier.ELITE:
			m.emission_enabled = true
			m.emission_energy_multiplier = max(m.emission_energy_multiplier, 0.0) + 0.9
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
	glow.albedo_color = _eye_color
	glow.emission_enabled = true
	glow.emission = _eye_color
	glow.emission_energy_multiplier = 4.0
	var mi := _add(eye, pos, glow)
	# Pulse the emission energy so the eyes feel alive.
	var dup_mat := glow.duplicate() as StandardMaterial3D
	mi.material_override = dup_mat
	var t := mi.create_tween().set_loops()
	t.tween_property(dup_mat, "emission_energy_multiplier", 6.0, 0.9).set_trans(Tween.TRANS_SINE)
	t.tween_property(dup_mat, "emission_energy_multiplier", 3.5, 0.9).set_trans(Tween.TRANS_SINE)

# ---------- Family builders ----------

func _build_humanoid() -> void:
	_head_pos = Vector3(0, 1.65, 0); _head_radius = 0.22
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
	_head_pos = Vector3(0.78, 0.85, 0); _head_radius = 0.30
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
	_head_pos = Vector3(0, 1.55, 0); _head_radius = 0.20
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
	_head_pos = Vector3(0, 1.55, 0); _head_radius = 0.19
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
	_head_pos = Vector3(0, 1.45, 0); _head_radius = 0.30
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
	_head_pos = Vector3(0, 1.30, 0); _head_radius = 0.40
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
	_head_pos = Vector3(0, 1.55, 0); _head_radius = 0.17
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
	_head_pos = Vector3(1.45, 1.85, 0); _head_radius = 0.28
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

# ---------- Decoration feats ----------

func _apply_feats(feats: Array) -> void:
	for f in feats:
		match String(f):
			"horns":           _feat_horns()
			"antlers":         _feat_antlers()
			"crown":           _feat_crown()
			"halo":            _feat_halo()
			"hood":            _feat_hood()
			"mask":            _feat_mask()
			"fangs":           _feat_fangs()
			"spikes_back":     _feat_spikes_back()
			"sword_held":      _feat_weapon(&"sword")
			"staff_held":      _feat_weapon(&"staff")
			"dagger_held":     _feat_weapon(&"dagger")
			"book_floating":   _feat_book_floating()
			"third_eye":       _feat_third_eye()
			"many_eyes":       _feat_many_eyes()
			"swarm_orbs":      _feat_swarm_orbs()
			"glow_orb":        _feat_glow_orb()
			"flame_aura":      _feat_flame_aura()
			"vines":           _feat_vines()
			"bell":            _feat_bell()
			"tail_blade":      _feat_tail_blade()
			"skull_stack":     _feat_skull_stack()
			"gear_face":       _feat_gear_face()
			"wings_pair":      _feat_wings_pair()

func _feat_horns() -> void:
	var horn := PrismMesh.new(); horn.size = Vector3(0.08, 0.30, 0.08)
	_add(horn, _head_pos + Vector3(_head_radius * 0.5, _head_radius * 0.9, 0), _accent, Vector3.ONE, Vector3(0, 0, -15))
	_add(horn, _head_pos + Vector3(-_head_radius * 0.5, _head_radius * 0.9, 0), _accent, Vector3.ONE, Vector3(0, 0, 15))

func _feat_antlers() -> void:
	for side in [-1, 1]:
		var base := CylinderMesh.new(); base.top_radius = 0.03; base.bottom_radius = 0.05; base.height = 0.45
		_add(base, _head_pos + Vector3(side * _head_radius * 0.6, _head_radius * 1.1, 0), _accent, Vector3.ONE, Vector3(0, 0, side * -25))
		var fork := CylinderMesh.new(); fork.top_radius = 0.02; fork.bottom_radius = 0.03; fork.height = 0.30
		_add(fork, _head_pos + Vector3(side * 0.32, _head_radius * 1.5, 0), _accent, Vector3.ONE, Vector3(0, 0, side * -55))
		_add(fork, _head_pos + Vector3(side * 0.20, _head_radius * 1.7, 0.05), _accent, Vector3.ONE, Vector3(0, 0, side * -10))

func _feat_crown() -> void:
	var ring := TorusMesh.new(); ring.inner_radius = _head_radius * 0.75; ring.outer_radius = _head_radius * 1.0
	_add(ring, _head_pos + Vector3(0, _head_radius * 0.95, 0), _accent, Vector3.ONE, Vector3(0, 0, 0))
	for i in 5:
		var ang := i * TAU / 5.0
		var spike := PrismMesh.new(); spike.size = Vector3(0.06, 0.18, 0.06)
		_add(spike, _head_pos + Vector3(cos(ang) * _head_radius * 0.85, _head_radius * 1.2, sin(ang) * _head_radius * 0.85), _accent)

func _feat_halo() -> void:
	var halo := TorusMesh.new(); halo.inner_radius = _head_radius * 1.4; halo.outer_radius = _head_radius * 1.7
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1, 0.95, 0.7); glow.emission_enabled = true
	glow.emission = Color(1, 0.95, 0.7); glow.emission_energy_multiplier = 3.0
	_add(halo, _head_pos + Vector3(0, _head_radius * 1.3, 0), glow, Vector3.ONE, Vector3(90, 0, 0))

func _feat_hood() -> void:
	var hood := SphereMesh.new(); hood.radius = _head_radius * 1.3; hood.height = _head_radius * 2.2
	_add(hood, _head_pos + Vector3(0, _head_radius * 0.2, -_head_radius * 0.2), _accent, Vector3(1, 1.1, 1))

func _feat_mask() -> void:
	var mask := BoxMesh.new(); mask.size = Vector3(_head_radius * 1.7, _head_radius * 1.2, 0.06)
	_add(mask, _head_pos + Vector3(0, 0, _head_radius * 0.95), _accent)

func _feat_fangs() -> void:
	var f := PrismMesh.new(); f.size = Vector3(0.04, 0.10, 0.04)
	_add(f, _head_pos + Vector3(0.06, -_head_radius * 0.15, _head_radius * 0.95), _accent, Vector3.ONE, Vector3(180, 0, 0))
	_add(f, _head_pos + Vector3(-0.06, -_head_radius * 0.15, _head_radius * 0.95), _accent, Vector3.ONE, Vector3(180, 0, 0))

func _feat_spikes_back() -> void:
	for i in 5:
		var s := PrismMesh.new(); s.size = Vector3(0.08, 0.18, 0.08)
		_add(s, Vector3(0, 1.05 + i * 0.05, -0.2 - i * 0.10), _accent)

func _feat_weapon(kind: StringName) -> void:
	# Right hand position approximated for humanoids; for others use offset from torso.
	var base_pos: Vector3 = Vector3(0.42, 0.85, 0.0)
	if archetype.family != Archetype.Family.HUMANOID:
		base_pos = _head_pos + Vector3(_head_radius * 1.5, -_head_radius, 0)
	match String(kind):
		"sword":
			var blade := BoxMesh.new(); blade.size = Vector3(0.05, 0.75, 0.04)
			_add(blade, base_pos, _accent, Vector3.ONE, Vector3(0, 0, 5))
			var hilt := BoxMesh.new(); hilt.size = Vector3(0.18, 0.06, 0.06)
			_add(hilt, base_pos + Vector3(0, -0.40, 0), _accent)
		"staff":
			var rod := CylinderMesh.new(); rod.top_radius = 0.04; rod.bottom_radius = 0.04; rod.height = 1.6
			_add(rod, base_pos + Vector3(0, 0.20, 0), _accent)
			var orb := SphereMesh.new(); orb.radius = 0.10; orb.height = 0.20
			var glow := StandardMaterial3D.new()
			glow.albedo_color = _eye_color; glow.emission_enabled = true
			glow.emission = _eye_color; glow.emission_energy_multiplier = 4.0
			_add(orb, base_pos + Vector3(0, 1.0, 0), glow)
		"dagger":
			var blade := BoxMesh.new(); blade.size = Vector3(0.04, 0.34, 0.03)
			_add(blade, base_pos, _accent)
			var hilt := BoxMesh.new(); hilt.size = Vector3(0.12, 0.05, 0.05)
			_add(hilt, base_pos + Vector3(0, -0.18, 0), _accent)

func _feat_book_floating() -> void:
	var book := BoxMesh.new(); book.size = Vector3(0.30, 0.04, 0.22)
	_add(book, _head_pos + Vector3(0.4, -0.1, 0), _accent, Vector3.ONE, Vector3(0, 25, 10))
	var page := BoxMesh.new(); page.size = Vector3(0.28, 0.02, 0.20)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1, 0.95, 0.7); glow.emission_enabled = true
	glow.emission = Color(1, 0.95, 0.7); glow.emission_energy_multiplier = 2.0
	_add(page, _head_pos + Vector3(0.4, -0.07, 0), glow, Vector3.ONE, Vector3(0, 25, 10))

func _feat_third_eye() -> void:
	_add_eye(_head_pos + Vector3(0, _head_radius * 0.7, _head_radius * 1.0), 0.06)

func _feat_many_eyes() -> void:
	for i in 6:
		var ang := i * TAU / 6.0
		_add_eye(_head_pos + Vector3(cos(ang) * _head_radius * 0.95, _head_radius * 0.4 + sin(ang) * _head_radius * 0.5, _head_radius * 0.95), 0.045)

func _feat_swarm_orbs() -> void:
	for i in 8:
		var ang := i * TAU / 8.0
		var orb := SphereMesh.new(); orb.radius = 0.12; orb.height = 0.24
		var glow := StandardMaterial3D.new()
		glow.albedo_color = _material.albedo_color; glow.emission_enabled = true
		glow.emission = _eye_color; glow.emission_energy_multiplier = 2.0
		_add(orb, Vector3(cos(ang) * 0.7, 1.0 + sin(ang) * 0.4, sin(ang) * 0.7), glow)

func _feat_glow_orb() -> void:
	var orb := SphereMesh.new(); orb.radius = 0.18; orb.height = 0.36
	var glow := StandardMaterial3D.new()
	glow.albedo_color = _eye_color; glow.emission_enabled = true
	glow.emission = _eye_color; glow.emission_energy_multiplier = 5.0
	_add(orb, _head_pos + Vector3(0.55, 0.0, 0.0), glow)

func _feat_flame_aura() -> void:
	for i in 5:
		var ang := i * TAU / 5.0
		var f := SphereMesh.new(); f.radius = 0.10; f.height = 0.20
		var glow := StandardMaterial3D.new()
		glow.albedo_color = Color(1, 0.55, 0.20); glow.emission_enabled = true
		glow.emission = Color(1, 0.55, 0.20); glow.emission_energy_multiplier = 4.0
		_add(f, Vector3(cos(ang) * 0.6, 0.4 + sin(i) * 0.2, sin(ang) * 0.6), glow)

func _feat_vines() -> void:
	for i in 4:
		var v := CylinderMesh.new(); v.top_radius = 0.02; v.bottom_radius = 0.04; v.height = 0.7
		var ang := i * TAU / 4.0
		_add(v, Vector3(cos(ang) * 0.25, 0.7, sin(ang) * 0.25), _accent, Vector3.ONE, Vector3(15, rad_to_deg(ang), 5))

func _feat_bell() -> void:
	var stem := CylinderMesh.new(); stem.top_radius = 0.02; stem.bottom_radius = 0.02; stem.height = 0.30
	_add(stem, _head_pos + Vector3(0, _head_radius * 1.6, 0), _accent)
	var bell := SphereMesh.new(); bell.radius = 0.10; bell.height = 0.16
	_add(bell, _head_pos + Vector3(0, _head_radius * 1.85, 0), _accent)

func _feat_tail_blade() -> void:
	var blade := PrismMesh.new(); blade.size = Vector3(0.20, 0.40, 0.06)
	var pos := Vector3(-1.0, 0.85, 0) if archetype.family != Archetype.Family.HUMANOID else Vector3(0, 0.4, -0.4)
	_add(blade, pos, _accent, Vector3.ONE, Vector3(0, 0, 30))

func _feat_skull_stack() -> void:
	for i in 4:
		var skull := SphereMesh.new(); skull.radius = 0.16 - i * 0.02; skull.height = (0.16 - i * 0.02) * 2
		_add(skull, Vector3(0, 0.4 + i * 0.35, 0), _accent)

func _feat_gear_face() -> void:
	var gear := TorusMesh.new(); gear.inner_radius = 0.10; gear.outer_radius = 0.18
	_add(gear, _head_pos + Vector3(0, 0, _head_radius * 0.9), _accent, Vector3.ONE, Vector3(90, 0, 0))

func _feat_wings_pair() -> void:
	var w := PrismMesh.new(); w.size = Vector3(1.2, 0.8, 0.05)
	_add(w, Vector3(0, 1.2, -0.4), _material, Vector3.ONE, Vector3(0, 0, 20))
	_add(w, Vector3(0, 1.2, 0.4), _material, Vector3.ONE, Vector3(0, 180, -20))

var _mutation_count: int = 0

func _add_mutation_mark() -> void:
	# Adds a small visible "mutation": an extra glowing eye on the head, a vine
	# on the body, or a twisted growth, cycling through forms.
	_mutation_count += 1
	match _mutation_count % 3:
		0:
			# extra eye on the head
			_add_eye(_head_pos + Vector3(_head_radius * 0.6, _head_radius * 0.8, _head_radius * 0.5), 0.05)
		1:
			# twisted vine from torso
			var vine := CylinderMesh.new(); vine.top_radius = 0.04; vine.bottom_radius = 0.08; vine.height = 0.45
			_add(vine, Vector3(0.20, 0.85, 0.20), _accent, Vector3.ONE, Vector3(35, 0, 25))
		2:
			# bulbous growth on the head
			var nub := SphereMesh.new(); nub.radius = 0.10; nub.height = 0.20
			_add(nub, _head_pos + Vector3(-_head_radius * 0.6, _head_radius * 0.5, 0), _accent)

func react(reaction: StringName) -> void:
	if _animator == null: return
	# If we have an imported GLB animation player, route the action to it too.
	if _imported_root != null:
		AssetLoader.play_named_action(_imported_root, reaction, false)
	match reaction:
		&"die":    _animator.play_die()
		&"flee":   _animator.play_flee()
		&"hit":    _animator.play_hit()
		&"attack": _animator.play_attack()
		&"mutate":
			_add_mutation_mark()
			_animator.play_mutate()
