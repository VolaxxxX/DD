class_name Companion3D extends Node3D
# Tiny floating spirit-fox that follows the player through the whole run.
# Purely cosmetic: bobs near the avatar and REACTS to every outcome — cheers
# on crits, spins on success, hides on failure. Built to be adored.

const NAMES := ["Pip", "Lumi", "Noa", "Boule", "Mochi", "Plume", "Fae", "Miel"]
const PALETTES := [
	{"body": Color(1.00, 0.80, 0.55), "glow": Color(1.00, 0.70, 0.35)},   # ember fox
	{"body": Color(0.70, 0.85, 1.00), "glow": Color(0.55, 0.75, 1.00)},   # frost fox
	{"body": Color(0.85, 0.75, 1.00), "glow": Color(0.75, 0.55, 1.00)},   # violet wisp
	{"body": Color(0.75, 1.00, 0.80), "glow": Color(0.45, 0.95, 0.60)},   # leaf sprite
	{"body": Color(1.00, 0.75, 0.85), "glow": Color(1.00, 0.55, 0.75)},   # rose wisp
]

var companion_name: String = "Pip"
var _root: Node3D
var _base_pos: Vector3
var _bob_time: float = 0.0
var _reacting: bool = false

func build(seed_v: int) -> void:
	for c in get_children(): c.queue_free()
	companion_name = NAMES[seed_v % NAMES.size()]
	var pal: Dictionary = PALETTES[(seed_v / 7) % PALETTES.size()]
	_root = Node3D.new()
	add_child(_root)
	# Body: plump teardrop.
	_part(SphereMesh.new(), Vector3(0, 0, 0), pal.body, 0.0, Vector3(1.0, 0.85, 1.0), 0.16)
	# Head: round, slightly forward.
	_part(SphereMesh.new(), Vector3(0.10, 0.13, 0), pal.body, 0.0, Vector3.ONE, 0.11)
	# Ears: two perky cones.
	for s in [-1, 1]:
		var ear := CylinderMesh.new()
		ear.top_radius = 0.005; ear.bottom_radius = 0.035; ear.height = 0.09
		var mi := MeshInstance3D.new()
		mi.mesh = ear
		mi.position = Vector3(0.10, 0.235, 0.05 * s)
		mi.rotation_degrees = Vector3(12 * s, 0, -8)
		mi.material_override = _mat(pal.body.darkened(0.1))
		_root.add_child(mi)
	# Eyes: two dark beads — big and cute.
	for s in [-1, 1]:
		_part(SphereMesh.new(), Vector3(0.185, 0.15, 0.045 * s), Color(0.12, 0.10, 0.12), 0.4, Vector3.ONE, 0.022)
	# Tail: glowing wisp trail.
	_part(SphereMesh.new(), Vector3(-0.16, 0.02, 0), pal.glow, 2.5, Vector3(1.3, 0.7, 0.7), 0.07)
	_part(SphereMesh.new(), Vector3(-0.26, 0.05, 0), pal.glow, 3.0, Vector3.ONE, 0.04)
	# Soft glow light.
	var ol := OmniLight3D.new()
	ol.light_color = pal.glow
	ol.light_energy = 0.7
	ol.omni_range = 2.5
	ol.position = Vector3(0, 0.1, 0)
	_root.add_child(ol)

func _part(mesh: SphereMesh, pos: Vector3, color: Color, emit: float, sc: Vector3, radius: float) -> void:
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = sc
	mi.material_override = _mat(color, emit)
	_root.add_child(mi)

func _mat(color: Color, emit: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.6
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emit
	return m

func set_home(pos: Vector3) -> void:
	_base_pos = pos
	position = pos

func _process(delta: float) -> void:
	if _reacting: return
	_bob_time += delta
	# Gentle hover bob + lazy figure-eight drift around the home point.
	position = _base_pos + Vector3(
		sin(_bob_time * 0.7) * 0.15,
		0.95 + sin(_bob_time * 1.8) * 0.10,
		cos(_bob_time * 0.5) * 0.10)
	rotation.y = sin(_bob_time * 0.4) * 0.3

# Outcome reactions: 0 CRIT_FAIL, 1 FAIL, 2 MIXED, 3 SUCCESS, 4 CRIT_SUCCESS.
func react(outcome: int) -> void:
	if _root == null or not is_instance_valid(_root): return
	_reacting = true
	var t := create_tween()
	match outcome:
		4:  # ecstatic: triple backflip + pop
			t.tween_property(self, "rotation:x", -TAU, 0.6).set_trans(Tween.TRANS_CUBIC)
			t.parallel().tween_property(self, "position:y", position.y + 0.8, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(self, "position:y", position.y, 0.3).set_trans(Tween.TRANS_BOUNCE)
			t.parallel().tween_property(self, "rotation:x", 0.0, 0.01)
			t.tween_property(self, "scale", Vector3.ONE * 1.3, 0.12)
			t.tween_property(self, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)
		3:  # happy spin
			t.tween_property(self, "rotation:y", rotation.y + TAU, 0.5).set_trans(Tween.TRANS_CUBIC)
			t.parallel().tween_property(self, "position:y", position.y + 0.3, 0.25)
			t.tween_property(self, "position:y", position.y, 0.25).set_trans(Tween.TRANS_BOUNCE)
		2:  # curious head tilt
			t.tween_property(self, "rotation:z", 0.35, 0.3).set_trans(Tween.TRANS_SINE)
			t.tween_interval(0.4)
			t.tween_property(self, "rotation:z", 0.0, 0.3)
		1:  # worried shrink + look away
			t.tween_property(self, "scale", Vector3.ONE * 0.75, 0.25)
			t.parallel().tween_property(self, "rotation:y", rotation.y + 2.6, 0.4)
			t.tween_interval(0.5)
			t.tween_property(self, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK)
			t.parallel().tween_property(self, "rotation:y", rotation.y, 0.35)
		0:  # terrified: dive low and tremble
			t.tween_property(self, "position:y", position.y - 0.55, 0.18).set_trans(Tween.TRANS_QUAD)
			for i in 4:
				t.tween_property(self, "position:x", position.x + 0.05, 0.05)
				t.tween_property(self, "position:x", position.x - 0.05, 0.05)
			t.tween_property(self, "position:y", position.y, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_callback(func(): _reacting = false)
