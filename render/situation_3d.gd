class_name Situation3D extends Node3D
# 3D centerpiece for non-creature situations — the player always sees the scene.

func build(situation_id: StringName) -> void:
	for c in get_children(): c.queue_free()
	# Try a KayKit prop centerpiece first so the situation reads cleanly.
	var kit_prop := _kayprop_for(situation_id)
	if kit_prop != null:
		add_child(kit_prop)
		return
	match String(situation_id):
		"inscription":      _inscription()
		"collapse":         _collapse()
		"shrine":           _shrine()
		"stranger":         _stranger()
		"storm":            _storm()
		"blood_trail":      _blood_trail()
		"deep_well":        _well()
		"beggar_child":     _child()
		"crossroads":       _crossroads()
		"burning_tree":     _burning_tree()
		"warm_carcass":     _carcass()
		"the_double":       _double()
		"broken_statue":    _statue()
		# --- new ones with procedural builds ---
		"hanging_cage":     _hanging_cage()
		"path_doll":        _path_doll()
		"bear_trap":        _bear_trap()
		"echo_cave":        _echo_cave()
		"ancient_gate":     _ancient_gate()
		"lost_letter":      _lost_letter()
		"sleeping_giant":   _sleeping_giant()
		"cursed_coin":      _cursed_coin()
		"whisper_dark":     _whisper_dark()
		"frozen_pool":      _frozen_pool()
		"empty_shoes":      _empty_shoes()
		"fallen_comet":     _fallen_comet()
		"charred_map":      _charred_map()
		"head_pole":        _head_pole()
		"festival_lights":  _festival_lights()
		"breathing_earth":  _breathing_earth()
		"dreaming_fish":    _dreaming_fish()
		"singing_crowns":   _singing_crowns()
		"mirror_lake":      _mirror_lake()
		"glowing_fungi":    _glowing_fungi()
		"wind_harp":        _wind_harp()
		"star_map":         _star_map()
		"caged_beast":      _caged_beast()
		_:                  _shrine()

# Routes specific situations to a single KayKit prop scaled up + centered.
func _kayprop_for(situation_id: StringName) -> Node3D:
	var path := ""
	match String(situation_id):
		"buried_pilgrim":    path = "res://assets/models/biome_kayhalloween/grave_A.glb"
		"burning_library":   path = "res://assets/models/biome_kaydungeon/shelves.glb"
		"ferryman":          path = "res://assets/models/biome_kayhalloween/post.glb"
		# caged_beast handled by a dedicated procedural cage build (no real
		# cage model exists; a lone fence pillar read wrong).
		"wounded_merc":      path = "res://assets/models/biome_kayhalloween/coffin.glb"
		"iron_door":         path = "res://assets/models/biome_kayhalloween/arch_gate.glb"
		"cold_fork":         path = "res://assets/models/biome_kayforest/Tree_Bare_1_A_Color1.glb"
		"sea_cave":          path = "res://assets/models/biome_kayforest/Rock_3_F_Color1.glb"
		"brackish_spring":   path = "res://assets/models/biome_kayhalloween/lantern_standing.glb"
		"old_monk":          path = "res://assets/models/biome_kayhalloween/shrine_candles.glb"
		"scholar":           path = "res://assets/models/biome_kaydungeon/chest_gold.glb"
		"healer_cottage":    path = "res://assets/models/biome_town/cottage.glb"
		"old_hunter":        path = "res://assets/models/biome_kayforest/Tree_4_A_Color1.glb"
		"friendly_raven":    path = "res://assets/models/biome_kayforest/Tree_2_A_Color1.glb"
		"sailor_grave":      path = "res://assets/models/biome_kayhalloween/gravestone.glb"
		"frozen_tower":      path = "res://assets/models/biome_castle/tower-square.glb"
		"underwater_shadow": path = "res://assets/models/biome_kayforest/Rock_3_G_Color1.glb"
		"burning_pyre":      path = "res://assets/models/biome_kayhalloween/skull_candle.glb"
		"lost_child":        path = "res://assets/models/biome_kayhalloween/pumpkin_orange_small.glb"
		"carriage_wreck":    path = "res://assets/models/biome_kayhalloween/coffin_decorated.glb"
		"snake_oil":         path = "res://assets/models/biome_kaydungeon/chest.glb"
		"mad_vagabond":      path = "res://assets/models/biome_kayhalloween/post_skull.glb"
		"night_fire":        path = "res://assets/models/biome_kayhalloween/skull_candle.glb"
		"wild_herbs":        path = "res://assets/models/biome_kayforest/Mushroom_1_A_Color1.glb"
		_: return null
	if not ResourceLoader.exists(path): return null
	var scn = load(path)
	if not (scn is PackedScene): return null
	var n: Node3D = scn.instantiate()
	n.scale = Vector3.ONE * 2.0
	return n

func _add(mesh: Mesh, pos: Vector3, color: Color, emission_e: float = 0.0, scale_v: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, rough: float = 0.8) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh; mi.position = pos; mi.scale = scale_v; mi.rotation_degrees = rot_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color; mat.roughness = rough
	if emission_e > 0.0:
		mat.emission_enabled = true; mat.emission = color
		mat.emission_energy_multiplier = emission_e
	mi.material_override = mat
	add_child(mi)
	return mi

func _glyph_dots(center: Vector3, color: Color, n: int = 6) -> void:
	for i in n:
		var d := SphereMesh.new(); d.radius = 0.03; d.height = 0.06
		_add(d, center + Vector3(fmod(i * 0.13, 0.4) - 0.2, fmod(i * 0.21, 0.5) - 0.1, 0.06), color, 3.0)

func _inscription() -> void:
	var slab := BoxMesh.new(); slab.size = Vector3(1.2, 1.8, 0.25)
	_add(slab, Vector3(0, 0.9, 0), Color(0.45, 0.42, 0.38), 0.0, Vector3.ONE, Vector3(0, 8, -3))
	_glyph_dots(Vector3(0, 1.1, 0.1), Color(0.55, 0.85, 1.0), 9)

func _collapse() -> void:
	for i in 6:
		var s := BoxMesh.new(); s.size = Vector3(0.6 + i * 0.1, 0.18, 0.5)
		_add(s, Vector3(-0.8 + i * 0.3, 0.1 + i * 0.12, -i * 0.15), Color(0.40, 0.36, 0.32), 0.0, Vector3.ONE, Vector3(i * 4, i * 9, i * 6))
	var hole := CylinderMesh.new(); hole.top_radius = 0.9; hole.bottom_radius = 0.9; hole.height = 0.05
	_add(hole, Vector3(0, 0.01, 0.4), Color(0.03, 0.03, 0.05))

func _shrine() -> void:
	var base := BoxMesh.new(); base.size = Vector3(1.4, 0.3, 1.0)
	_add(base, Vector3(0, 0.15, 0), Color(0.50, 0.47, 0.42))
	var altar := BoxMesh.new(); altar.size = Vector3(0.9, 0.7, 0.7)
	_add(altar, Vector3(0, 0.65, 0), Color(0.55, 0.52, 0.46))
	var flame := SphereMesh.new(); flame.radius = 0.10; flame.height = 0.20
	_add(flame, Vector3(0, 1.15, 0), Color(1.0, 0.75, 0.35), 4.0)

func _stranger() -> void:
	var cloak := CapsuleMesh.new(); cloak.radius = 0.30; cloak.height = 1.3
	_add(cloak, Vector3(0, 0.85, 0), Color(0.18, 0.15, 0.20))
	var hood := SphereMesh.new(); hood.radius = 0.24; hood.height = 0.44
	_add(hood, Vector3(0, 1.55, 0), Color(0.14, 0.12, 0.16))
	var purse := SphereMesh.new(); purse.radius = 0.10; purse.height = 0.18
	_add(purse, Vector3(0.35, 1.0, 0.15), Color(0.65, 0.50, 0.25), 0.6)

func _storm() -> void:
	for i in 4:
		var cloud := SphereMesh.new(); cloud.radius = 0.5 + i * 0.1; cloud.height = 0.6
		_add(cloud, Vector3(-0.6 + i * 0.45, 3.2 + fmod(i * 0.3, 0.5), 0), Color(0.25, 0.25, 0.30))
	for i in 3:
		var bolt := PrismMesh.new(); bolt.size = Vector3(0.06, 1.2, 0.06)
		_add(bolt, Vector3(-0.4 + i * 0.5, 2.2, 0), Color(0.95, 0.95, 1.0), 5.0, Vector3.ONE, Vector3(0, 0, 8 - i * 8))

func _blood_trail() -> void:
	for i in 7:
		var drop := SphereMesh.new(); drop.radius = 0.10 - i * 0.008; drop.height = 0.05
		_add(drop, Vector3(-1.2 + i * 0.4, 0.03, 0.3 - i * 0.25), Color(0.55, 0.05, 0.05), 0.4)

func _well() -> void:
	var ring := TorusMesh.new(); ring.inner_radius = 0.55; ring.outer_radius = 0.8
	_add(ring, Vector3(0, 0.3, 0), Color(0.42, 0.40, 0.38))
	var water := CylinderMesh.new(); water.top_radius = 0.55; water.bottom_radius = 0.55; water.height = 0.04
	_add(water, Vector3(0, 0.25, 0), Color(0.05, 0.10, 0.18), 0.5, Vector3.ONE, Vector3.ZERO, 0.1)
	var post := CylinderMesh.new(); post.top_radius = 0.05; post.bottom_radius = 0.05; post.height = 1.4
	_add(post, Vector3(-0.7, 0.9, 0), Color(0.35, 0.25, 0.15))
	_add(post, Vector3(0.7, 0.9, 0), Color(0.35, 0.25, 0.15))
	var beam := CylinderMesh.new(); beam.top_radius = 0.04; beam.bottom_radius = 0.04; beam.height = 1.5
	_add(beam, Vector3(0, 1.55, 0), Color(0.35, 0.25, 0.15), 0.0, Vector3.ONE, Vector3(0, 0, 90))

func _child() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.16; body.height = 0.7
	_add(body, Vector3(0, 0.45, 0), Color(0.30, 0.26, 0.22))
	var head := SphereMesh.new(); head.radius = 0.14; head.height = 0.28
	_add(head, Vector3(0, 0.95, 0), Color(0.85, 0.70, 0.58))
	var bowl := CylinderMesh.new(); bowl.top_radius = 0.12; bowl.bottom_radius = 0.08; bowl.height = 0.08
	_add(bowl, Vector3(0.3, 0.05, 0.15), Color(0.45, 0.35, 0.22))

func _crossroads() -> void:
	var post := CylinderMesh.new(); post.top_radius = 0.06; post.bottom_radius = 0.07; post.height = 2.0
	_add(post, Vector3(0, 1.0, 0), Color(0.35, 0.26, 0.16))
	var sign1 := BoxMesh.new(); sign1.size = Vector3(0.8, 0.18, 0.05)
	_add(sign1, Vector3(0.3, 1.7, 0), Color(0.45, 0.34, 0.20), 0.0, Vector3.ONE, Vector3(0, 20, 0))
	_add(sign1, Vector3(-0.3, 1.45, 0), Color(0.45, 0.34, 0.20), 0.0, Vector3.ONE, Vector3(0, -25, 0))

func _burning_tree() -> void:
	var trunk := CylinderMesh.new(); trunk.top_radius = 0.15; trunk.bottom_radius = 0.28; trunk.height = 2.2
	_add(trunk, Vector3(0, 1.1, 0), Color(0.20, 0.13, 0.08))
	for i in 6:
		var flame := SphereMesh.new(); flame.radius = 0.22 - i * 0.02; flame.height = 0.4
		_add(flame, Vector3(fmod(i * 0.25, 0.6) - 0.3, 2.2 + i * 0.25, fmod(i * 0.17, 0.4) - 0.2), Color(1.0, 0.55, 0.15), 3.5)

func _carcass() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.35; body.height = 1.2
	_add(body, Vector3(0, 0.3, 0), Color(0.45, 0.30, 0.22), 0.0, Vector3.ONE, Vector3(0, 15, 90))
	var rib := TorusMesh.new(); rib.inner_radius = 0.18; rib.outer_radius = 0.24
	_add(rib, Vector3(0.1, 0.45, 0), Color(0.85, 0.80, 0.70), 0.0, Vector3.ONE, Vector3(0, 90, 0))

func _double() -> void:
	# A dark mirror of the player silhouette.
	var body := CapsuleMesh.new(); body.radius = 0.22; body.height = 0.85
	_add(body, Vector3(0, 0.95, 0), Color(0.08, 0.06, 0.12))
	var head := SphereMesh.new(); head.radius = 0.18; head.height = 0.36
	_add(head, Vector3(0, 1.55, 0), Color(0.10, 0.08, 0.14))
	for side in [-1, 1]:
		var eye := SphereMesh.new(); eye.radius = 0.035; eye.height = 0.07
		_add(eye, Vector3(side * 0.07, 1.6, 0.16), Color(1, 1, 1), 5.0)

func _statue() -> void:
	var base := BoxMesh.new(); base.size = Vector3(1.0, 0.4, 1.0)
	_add(base, Vector3(0, 0.2, 0), Color(0.48, 0.45, 0.40))
	var torso := CapsuleMesh.new(); torso.radius = 0.25; torso.height = 1.0
	_add(torso, Vector3(0, 1.0, 0), Color(0.55, 0.52, 0.47), 0.0, Vector3.ONE, Vector3(0, 0, 8))
	# missing head — broken neck stump
	var stump := CylinderMesh.new(); stump.top_radius = 0.10; stump.bottom_radius = 0.14; stump.height = 0.15
	_add(stump, Vector3(0.05, 1.6, 0), Color(0.50, 0.47, 0.42))
	var arm := CapsuleMesh.new(); arm.radius = 0.08; arm.height = 0.6
	_add(arm, Vector3(-0.35, 1.1, 0), Color(0.55, 0.52, 0.47), 0.0, Vector3.ONE, Vector3(0, 0, 40))

# ---------- new procedural builds ----------

func _caged_beast() -> void:
	# A real floor cage: 4 corner posts + top/bottom frame + vertical bars, with
	# a hunched dark beast shape glowing inside.
	var bar_col := Color(0.22, 0.22, 0.25)
	# Corner posts.
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var post := CylinderMesh.new(); post.top_radius = 0.06; post.bottom_radius = 0.06; post.height = 1.7
			_add(post, Vector3(sx * 0.6, 0.85, sz * 0.6), bar_col)
	# Vertical bars on each of the 4 sides.
	for side in 4:
		for b in 3:
			var bar := CylinderMesh.new(); bar.top_radius = 0.025; bar.bottom_radius = 0.025; bar.height = 1.6
			var f := -0.4 + b * 0.4
			var pos: Vector3
			match side:
				0: pos = Vector3(f, 0.8, -0.6)
				1: pos = Vector3(f, 0.8, 0.6)
				2: pos = Vector3(-0.6, 0.8, f)
				3: pos = Vector3(0.6, 0.8, f)
			_add(bar, pos, bar_col)
	# Top + bottom frames.
	var frame := BoxMesh.new(); frame.size = Vector3(1.3, 0.08, 1.3)
	_add(frame, Vector3(0, 1.66, 0), bar_col.darkened(0.1))
	_add(frame, Vector3(0, 0.05, 0), bar_col.darkened(0.2))
	# The captive beast — a hunched dark form with two glowing eyes.
	var beast := SphereMesh.new(); beast.radius = 0.34; beast.height = 0.5
	_add(beast, Vector3(0, 0.45, 0), Color(0.10, 0.09, 0.12), 0.0, Vector3(1.0, 0.8, 1.2))
	_add(SphereMesh.new(), Vector3(-0.10, 0.55, 0.28), Color(1.0, 0.5, 0.2), 4.0, Vector3.ONE * 0.04)
	_add(SphereMesh.new(), Vector3(0.10, 0.55, 0.28), Color(1.0, 0.5, 0.2), 4.0, Vector3.ONE * 0.04)

func _hanging_cage() -> void:
	var rope := CylinderMesh.new(); rope.top_radius = 0.04; rope.bottom_radius = 0.04; rope.height = 3.0
	_add(rope, Vector3(0, 2.5, 0), Color(0.45, 0.35, 0.22))
	for i in 4:
		var bar := CylinderMesh.new(); bar.top_radius = 0.04; bar.bottom_radius = 0.04; bar.height = 1.5
		var ang := i * TAU / 4.0
		_add(bar, Vector3(cos(ang) * 0.35, 1.0, sin(ang) * 0.35), Color(0.30, 0.30, 0.32))
	var ring := TorusMesh.new(); ring.inner_radius = 0.30; ring.outer_radius = 0.42
	_add(ring, Vector3(0, 0.4, 0), Color(0.30, 0.30, 0.32))
	_add(ring, Vector3(0, 1.6, 0), Color(0.30, 0.30, 0.32))

func _path_doll() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.10; body.height = 0.35
	_add(body, Vector3(0, 0.20, 0), Color(0.85, 0.65, 0.55))
	var head := SphereMesh.new(); head.radius = 0.12; head.height = 0.24
	_add(head, Vector3(0, 0.50, 0), Color(0.92, 0.78, 0.65))
	_add(SphereMesh.new(), Vector3(-0.05, 0.53, 0.11), Color(0.05, 0.05, 0.10), 3.0, Vector3.ONE * 0.025)
	_add(SphereMesh.new(), Vector3(0.05, 0.53, 0.11), Color(0.05, 0.05, 0.10), 3.0, Vector3.ONE * 0.025)

func _bear_trap() -> void:
	for side in [-1, 1]:
		var jaw := PrismMesh.new(); jaw.size = Vector3(0.10, 0.50, 0.30)
		_add(jaw, Vector3(0, 0.25, side * 0.18), Color(0.55, 0.55, 0.58), 0.2, Vector3.ONE, Vector3(0, 0, side * -75))
	var plate := CylinderMesh.new(); plate.top_radius = 0.30; plate.bottom_radius = 0.30; plate.height = 0.05
	_add(plate, Vector3(0, 0.05, 0), Color(0.35, 0.32, 0.30))
	var drop := SphereMesh.new(); drop.radius = 0.04; drop.height = 0.08
	_add(drop, Vector3(0.10, 0.10, 0.0), Color(0.55, 0.05, 0.05), 0.5)

func _echo_cave() -> void:
	var mouth := TorusMesh.new(); mouth.inner_radius = 0.85; mouth.outer_radius = 1.10
	_add(mouth, Vector3(0, 1.0, 0), Color(0.15, 0.15, 0.18), 0.0, Vector3(1, 1.2, 0.4), Vector3(0, 0, 0))
	var dark := SphereMesh.new(); dark.radius = 0.85; dark.height = 1.7
	_add(dark, Vector3(0, 1.0, -0.10), Color(0.02, 0.02, 0.04))

func _ancient_gate() -> void:
	for side in [-1, 1]:
		var col := CylinderMesh.new(); col.top_radius = 0.20; col.bottom_radius = 0.25; col.height = 2.4
		_add(col, Vector3(side * 0.8, 1.2, 0), Color(0.45, 0.42, 0.36))
	var top := BoxMesh.new(); top.size = Vector3(2.4, 0.3, 0.5)
	_add(top, Vector3(0, 2.55, 0), Color(0.40, 0.38, 0.34))
	var glow := PlaneMesh.new(); glow.size = Vector2(1.4, 2.2)
	_add(glow, Vector3(0, 1.2, 0), Color(0.45, 0.85, 1.0), 1.4, Vector3.ONE, Vector3(0, 0, 0))

func _lost_letter() -> void:
	var paper := BoxMesh.new(); paper.size = Vector3(0.40, 0.02, 0.30)
	_add(paper, Vector3(0, 0.04, 0), Color(0.85, 0.80, 0.65), 0.0, Vector3.ONE, Vector3(0, 12, -4))
	var stone := SphereMesh.new(); stone.radius = 0.14; stone.height = 0.20
	_add(stone, Vector3(0.10, 0.10, 0.05), Color(0.45, 0.42, 0.40))

func _sleeping_giant() -> void:
	var hill := SphereMesh.new(); hill.radius = 1.6; hill.height = 1.8
	_add(hill, Vector3(0, 0.4, 0), Color(0.30, 0.40, 0.25), 0.0, Vector3(1.8, 0.6, 1.0))
	var head := SphereMesh.new(); head.radius = 0.55; head.height = 1.1
	_add(head, Vector3(-1.4, 0.7, 0), Color(0.78, 0.62, 0.48))
	# closed eye
	var lash := BoxMesh.new(); lash.size = Vector3(0.30, 0.05, 0.05)
	_add(lash, Vector3(-1.6, 0.75, 0.15), Color(0.20, 0.10, 0.05))

func _cursed_coin() -> void:
	var bed := SphereMesh.new(); bed.radius = 0.35; bed.height = 0.18
	_add(bed, Vector3(0, 0.10, 0), Color(0.35, 0.32, 0.28))
	var coin := CylinderMesh.new(); coin.top_radius = 0.18; coin.bottom_radius = 0.18; coin.height = 0.03
	_add(coin, Vector3(0, 0.18, 0), Color(1.0, 0.78, 0.20), 2.0)

func _whisper_dark() -> void:
	# A dark gradient + floating eye dot pair
	var dark := SphereMesh.new(); dark.radius = 1.4; dark.height = 2.8
	_add(dark, Vector3(0, 1.4, -0.5), Color(0.02, 0.02, 0.05), 0.0, Vector3(1.4, 1.4, 0.3))
	for side in [-1, 1]:
		var eye := SphereMesh.new(); eye.radius = 0.08; eye.height = 0.16
		_add(eye, Vector3(side * 0.20, 1.6, 0.35), Color(0.95, 0.65, 0.20), 6.0)

func _frozen_pool() -> void:
	var ice := CylinderMesh.new(); ice.top_radius = 1.10; ice.bottom_radius = 1.10; ice.height = 0.08
	_add(ice, Vector3(0, 0.05, 0), Color(0.75, 0.92, 1.00), 0.3, Vector3.ONE, Vector3.ZERO, 0.15)
	var crack := BoxMesh.new(); crack.size = Vector3(1.4, 0.02, 0.06)
	_add(crack, Vector3(0, 0.10, 0), Color(0.45, 0.65, 0.85), 0.0, Vector3.ONE, Vector3(0, 25, 0))

func _empty_shoes() -> void:
	for side in [-1, 1]:
		var shoe := BoxMesh.new(); shoe.size = Vector3(0.18, 0.10, 0.30)
		_add(shoe, Vector3(side * 0.12, 0.06, 0), Color(0.30, 0.22, 0.15))

func _fallen_comet() -> void:
	var crater := SphereMesh.new(); crater.radius = 0.85; crater.height = 0.5
	_add(crater, Vector3(0, 0.0, 0), Color(0.20, 0.15, 0.10), 0.0, Vector3(1.4, 0.3, 1.4))
	var rock := SphereMesh.new(); rock.radius = 0.35; rock.height = 0.7
	_add(rock, Vector3(0, 0.30, 0), Color(0.45, 0.30, 0.20))
	var glow := SphereMesh.new(); glow.radius = 0.18; glow.height = 0.36
	_add(glow, Vector3(0, 0.40, 0), Color(1.0, 0.55, 0.20), 4.0)

func _charred_map() -> void:
	var map := BoxMesh.new(); map.size = Vector3(0.95, 0.02, 0.65)
	_add(map, Vector3(0, 0.05, 0), Color(0.55, 0.40, 0.30))
	# Burn edge — darker corners
	for side in [-1, 1]:
		var burn := BoxMesh.new(); burn.size = Vector3(0.20, 0.025, 0.20)
		_add(burn, Vector3(side * 0.40, 0.06, 0.25), Color(0.12, 0.08, 0.05))

func _head_pole() -> void:
	var pole := CylinderMesh.new(); pole.top_radius = 0.05; pole.bottom_radius = 0.06; pole.height = 1.8
	_add(pole, Vector3(0, 0.9, 0), Color(0.35, 0.25, 0.15))
	var head := SphereMesh.new(); head.radius = 0.22; head.height = 0.44
	_add(head, Vector3(0, 1.9, 0), Color(0.55, 0.40, 0.35))
	for side in [-1, 1]:
		var eye := SphereMesh.new(); eye.radius = 0.04; eye.height = 0.08
		_add(eye, Vector3(side * 0.07, 1.95, 0.18), Color(0.95, 0.95, 0.65), 4.0)

func _festival_lights() -> void:
	# A rope of small floating spheres + lanterns.
	for i in 7:
		var lt := SphereMesh.new(); lt.radius = 0.10; lt.height = 0.20
		var x := -2.5 + i * 0.85
		var y := 2.4 + sin(i) * 0.20
		_add(lt, Vector3(x, y, -0.5), Color(1.0, 0.65, 0.30), 4.0)

func _breathing_earth() -> void:
	var mound := SphereMesh.new(); mound.radius = 0.95; mound.height = 1.10
	_add(mound, Vector3(0, 0.30, 0), Color(0.30, 0.22, 0.18), 0.0, Vector3(1.4, 0.55, 1.4))
	var glow := SphereMesh.new(); glow.radius = 0.20; glow.height = 0.40
	_add(glow, Vector3(0, 0.55, 0), Color(0.85, 0.30, 0.50), 3.0)

func _dreaming_fish() -> void:
	var body := CapsuleMesh.new(); body.radius = 0.40; body.height = 1.8
	_add(body, Vector3(0, 0.45, 0), Color(0.45, 0.55, 0.65), 0.3, Vector3.ONE, Vector3(0, 0, 90))
	var tail := PrismMesh.new(); tail.size = Vector3(0.05, 0.50, 0.50)
	_add(tail, Vector3(-1.0, 0.45, 0), Color(0.35, 0.45, 0.55))
	var eye := SphereMesh.new(); eye.radius = 0.06; eye.height = 0.12
	_add(eye, Vector3(0.85, 0.55, 0.20), Color(0.80, 0.80, 0.90), 2.0)

func _singing_crowns() -> void:
	for i in 3:
		var ang := i * TAU / 3.0
		var crown := TorusMesh.new(); crown.inner_radius = 0.20; crown.outer_radius = 0.28
		_add(crown, Vector3(cos(ang) * 0.75, 0.30, sin(ang) * 0.75), Color(1.0, 0.78, 0.20), 1.8)
		for s in 5:
			var sp := PrismMesh.new(); sp.size = Vector3(0.06, 0.18, 0.06)
			var sang := s * TAU / 5.0
			_add(sp, Vector3(cos(ang) * 0.75 + cos(sang) * 0.20, 0.45, sin(ang) * 0.75 + sin(sang) * 0.20), Color(1.0, 0.78, 0.20))

func _mirror_lake() -> void:
	var water := CylinderMesh.new(); water.top_radius = 1.30; water.bottom_radius = 1.30; water.height = 0.04
	_add(water, Vector3(0, 0.04, 0), Color(0.05, 0.08, 0.20), 0.6, Vector3.ONE, Vector3.ZERO, 0.05)
	# Star scatter mirrored as emissive points.
	for i in 12:
		var ang := i * TAU / 12.0
		var st := SphereMesh.new(); st.radius = 0.04; st.height = 0.08
		_add(st, Vector3(cos(ang) * 0.85, 0.07, sin(ang) * 0.85), Color(0.95, 0.95, 1.0), 4.5)

func _glowing_fungi() -> void:
	for i in 8:
		var ang := i * TAU / 8.0
		var stem := CylinderMesh.new(); stem.top_radius = 0.04; stem.bottom_radius = 0.06; stem.height = 0.30
		_add(stem, Vector3(cos(ang) * 0.55, 0.15, sin(ang) * 0.55), Color(0.85, 0.85, 0.92))
		var cap := SphereMesh.new(); cap.radius = 0.14; cap.height = 0.22
		_add(cap, Vector3(cos(ang) * 0.55, 0.35, sin(ang) * 0.55), Color(0.45, 0.85, 1.0), 3.0)

func _wind_harp() -> void:
	for side in [-1, 1]:
		var rock := SphereMesh.new(); rock.radius = 0.42; rock.height = 0.7
		_add(rock, Vector3(side * 0.85, 0.30, 0), Color(0.45, 0.42, 0.38))
	for i in 5:
		var str := CylinderMesh.new(); str.top_radius = 0.012; str.bottom_radius = 0.012; str.height = 1.40
		_add(str, Vector3(0, 1.0 - i * 0.20, 0), Color(1.0, 0.95, 0.65), 1.4, Vector3.ONE, Vector3(0, 0, 90))

func _star_map() -> void:
	var dais := BoxMesh.new(); dais.size = Vector3(1.4, 0.10, 1.0)
	_add(dais, Vector3(0, 0.05, 0), Color(0.45, 0.42, 0.38))
	for i in 9:
		var s := SphereMesh.new(); s.radius = 0.05; s.height = 0.10
		var x := -0.55 + (i % 3) * 0.55
		var z := -0.30 + int(i / 3) * 0.30
		_add(s, Vector3(x, 0.13, z), Color(0.95, 0.95, 1.0), 4.0)
