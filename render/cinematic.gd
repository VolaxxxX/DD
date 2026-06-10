class_name Cinematic extends RefCounted
# Unique cinematic moves per world boss and per rare creature.
# Stateless: caller passes the target node + camera + an SceneTree for tweens.

const HOME_CAM := Vector3(0, 2.2, 6.0)
const HOME_FOV := 50.0

# ------------------------- World bosses (one per id) ----------------------

static func play_world_boss(boss_id: StringName, target: Node3D, camera: Camera3D, tree: SceneTree) -> void:
	# Common arrival flash.
	_flash_screen(tree, Color(1, 1, 1, 0.85), 0.15)
	target.scale = Vector3.ZERO
	var grow := target.create_tween()
	grow.tween_property(target, "scale", Vector3.ONE, 1.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	match String(boss_id):
		"prismatic_ascendant":
			# Kaleidoscope: camera orbits 360° while pulling back.
			var orbit := camera.create_tween().set_parallel(true)
			orbit.tween_property(camera, "position", Vector3(0, 6.0, 14.0), 3.0).set_trans(Tween.TRANS_SINE)
			orbit.tween_property(camera, "fov", 65.0, 3.0)
			var spin := target.create_tween().set_loops()
			spin.tween_property(target, "rotation:y", TAU, 18.0)
		"nameless_sovereign":
			# Slow dolly-in, then pull back. Purple aura swells.
			var dolly := camera.create_tween()
			dolly.tween_property(camera, "position", Vector3(0, 3.5, 4.0), 1.4).set_trans(Tween.TRANS_SINE)
			dolly.tween_interval(1.0)
			dolly.tween_property(camera, "position", Vector3(0, 5.0, 13.0), 2.0).set_trans(Tween.TRANS_SINE)
			var fov_t := camera.create_tween()
			fov_t.tween_property(camera, "fov", 38.0, 1.4)
			fov_t.tween_interval(1.0)
			fov_t.tween_property(camera, "fov", 60.0, 2.0)
		"sea_beneath_stone":
			# Earthquake shake + dramatic zoom-out as the eye rises.
			_shake_camera(camera, tree, 0.45, 3.0)
			var pull := camera.create_tween()
			pull.tween_property(camera, "position", Vector3(0, 5.5, 16.0), 2.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			pull.parallel().tween_property(camera, "fov", 70.0, 2.5)
		"gallows_parliament":
			# Slow orbit around the circle of twelve.
			var orbit := camera.create_tween()
			orbit.tween_property(camera, "position", Vector3(0, 4.0, 12.0), 1.5).set_trans(Tween.TRANS_SINE)
			var spin := target.create_tween().set_loops()
			spin.tween_property(target, "rotation:y", TAU, 24.0)
		"silent_orchestra":
			# Spiral upwards; FOV widens, then narrows like a held breath.
			var spiral := camera.create_tween()
			spiral.tween_property(camera, "position", Vector3(-3.0, 6.5, 11.0), 2.0).set_trans(Tween.TRANS_SINE)
			spiral.tween_property(camera, "position", Vector3(3.0, 7.0, 12.0), 2.0).set_trans(Tween.TRANS_SINE)
			var fov_t := camera.create_tween()
			fov_t.tween_property(camera, "fov", 75.0, 1.5)
			fov_t.tween_property(camera, "fov", 45.0, 1.5)
		"that_which_dreams_us":
			# Pulled VERY far back, FOV pulses like a heartbeat.
			var pull := camera.create_tween()
			pull.tween_property(camera, "position", Vector3(0, 7.0, 22.0), 3.5).set_trans(Tween.TRANS_EXPO)
			var pulse := camera.create_tween().set_loops(3)
			pulse.tween_property(camera, "fov", 80.0, 0.6)
			pulse.tween_property(camera, "fov", 55.0, 0.6)
		"drowning_god":
			# Rising from beneath: camera tilts down, water spray flash, then pulls back hard.
			_shake_camera(camera, tree, 0.55, 2.2)
			_flash_screen(tree, Color(0.10, 0.30, 0.45, 0.75), 0.45)
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", Vector3(0, 1.8, 5.5), 0.6)
			cam.tween_property(camera, "position", Vector3(0, 8.5, 18.0), 3.0).set_trans(Tween.TRANS_EXPO)
			var fov_t := camera.create_tween()
			fov_t.tween_property(camera, "fov", 75.0, 3.0)
			# Slow rotation so the player sees all 8 tentacles
			var spin := target.create_tween().set_loops()
			spin.tween_property(target, "rotation:y", TAU, 28.0)
		_:
			var t := camera.create_tween().set_parallel(true)
			t.tween_property(camera, "position", Vector3(0, 4.5, 12.0), 1.8).set_trans(Tween.TRANS_SINE)
			t.tween_property(camera, "fov", 60.0, 1.8)

# ------------------------- Rare creatures ---------------------------------

static func play_for_creature(creature_id: StringName, tier: int, target: Node3D, camera: Camera3D, tree: SceneTree, family: int = 0) -> void:
	# COMMON, UNCOMMON, RARE: simple pop, no cinematic.
	if tier < 3:
		target.scale = Vector3.ZERO
		var t := target.create_tween()
		t.tween_property(target, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		return
	# ELITE+: brief arrival flash + small zoom.
	_flash_screen(tree, Color(0.85, 0.6, 0.9, 0.5), 0.20)
	# ELITE without per-id move: pick a family-flavored move.
	var per_id_handled := _try_per_id_creature(creature_id, target, camera, tree)
	if not per_id_handled:
		_family_arrival(family, target, camera, tree)

static func _family_arrival(family: int, target: Node3D, camera: Camera3D, tree: SceneTree) -> void:
	# Family-themed arrival for ELITE-tier creatures without a per-id signature.
	match family:
		0:  # HUMANOID — slow walk-up
			target.scale = Vector3.ONE; target.position = Vector3(0, 0, -2.5)
			var t := target.create_tween()
			t.tween_property(target, "position", Vector3(0, 0, 0), 1.4).set_trans(Tween.TRANS_SINE)
		1:  # BEAST — pounce
			target.scale = Vector3.ONE; target.position = Vector3(0, 0, -3.0)
			var t := target.create_tween()
			t.tween_property(target, "position", Vector3(0, 0.6, -0.5), 0.4).set_trans(Tween.TRANS_EXPO)
			t.tween_property(target, "position", Vector3(0, 0, 0), 0.5).set_trans(Tween.TRANS_BOUNCE)
		2:  # UNDEAD — rise from ground
			target.scale = Vector3.ONE; target.position = Vector3(0, -1.5, 0)
			var t := target.create_tween()
			t.tween_property(target, "position", Vector3(0, 0, 0), 1.4).set_trans(Tween.TRANS_EXPO)
		3:  # CONSTRUCT — assemble from above
			target.scale = Vector3.ONE; target.position = Vector3(0, 4.0, 0)
			var t := target.create_tween()
			t.tween_property(target, "position", Vector3(0, 0, 0), 0.9).set_trans(Tween.TRANS_BOUNCE)
			_shake_camera(camera, tree, 0.10, 0.4)
		4:  # ELEMENTAL — implode in
			target.scale = Vector3.ONE * 3.0; target.modulate = Color(1, 1, 1, 0)
			var t := target.create_tween().set_parallel(true)
			t.tween_property(target, "scale", Vector3.ONE, 0.8).set_trans(Tween.TRANS_BACK)
			t.tween_property(target, "modulate", Color(1, 1, 1, 1), 0.8)
		5:  # ABERRATION — wobbles in, FOV pulse
			_pop(target)
			var cam := camera.create_tween()
			cam.tween_property(camera, "fov", 60.0, 0.5)
			cam.tween_property(camera, "fov", 50.0, 0.5)
		6:  # FEY — fade in from sparkle
			target.scale = Vector3.ONE; target.modulate = Color(1, 1, 1, 0)
			var t := target.create_tween()
			t.tween_property(target, "modulate", Color(1, 1, 1, 1), 1.2)
		7:  # DRACONIC — earth shake, scale up
			_shake_camera(camera, tree, 0.25, 1.0)
			target.scale = Vector3.ZERO
			var t := target.create_tween()
			t.tween_property(target, "scale", Vector3.ONE * 1.3, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		_:
			_pop(target)

static func _try_per_id_creature(creature_id: StringName, target: Node3D, camera: Camera3D, tree: SceneTree) -> bool:
	# APEX/MYTHIC: per-id signature move.
	match String(creature_id):
		"whisper_shade":
			# Fade-in from black silhouette, no scale pop.
			target.scale = Vector3.ONE
			target.modulate = Color(0, 0, 0, 0)
			var t := target.create_tween()
			t.tween_property(target, "modulate", Color(1, 1, 1, 1), 1.4)
		"nameless_pilgrim":
			# Slow walk-up: camera dollies in.
			target.scale = Vector3.ONE
			target.position = Vector3(0, 0, -3.5)
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", Vector3(0, 2.0, 4.5), 1.2)
			var walk := target.create_tween()
			walk.tween_property(target, "position", Vector3(0, 0, 0), 1.8).set_trans(Tween.TRANS_SINE)
		"void_spark":
			_shake_camera(camera, tree, 0.18, 1.0)
			_pop(target)
		"the_nameless":
			# Hard cut to close, then pull back.
			target.scale = Vector3.ONE
			camera.position = Vector3(0, 1.6, 2.5)
			var pull := camera.create_tween()
			pull.tween_interval(0.6)
			pull.tween_property(camera, "position", HOME_CAM, 1.4).set_trans(Tween.TRANS_SINE)
		"tessellation":
			# MYTHIC: kaleidoscopic spiral while it appears.
			_flash_screen(tree, Color(0.55, 0.8, 1.0, 0.8), 0.3)
			target.scale = Vector3.ZERO
			var t := target.create_tween()
			t.tween_property(target, "scale", Vector3.ONE, 1.2).set_trans(Tween.TRANS_BACK)
			var spin := target.create_tween().set_loops()
			spin.tween_property(target, "rotation:y", TAU, 6.0)
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", Vector3(2.5, 3.0, 6.5), 1.5)
			cam.tween_property(camera, "position", Vector3(-2.5, 3.0, 6.5), 1.5)
			cam.tween_property(camera, "position", HOME_CAM, 1.0)
		"singing_automaton":
			# Slow rotate around it.
			_pop(target)
			var spin := target.create_tween().set_loops()
			spin.tween_property(target, "rotation:y", TAU, 12.0)
		"hollow_child":
			# Eerie silence: small, no motion. Slow zoom-in.
			target.scale = Vector3.ONE * 0.7
			var t := target.create_tween()
			t.tween_property(target, "scale", Vector3.ONE * 0.85, 1.0)
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", Vector3(0, 1.8, 4.2), 2.0).set_trans(Tween.TRANS_SINE)
		"old_wood_stag":
			# Tilt up to show full antlers.
			_pop(target)
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", Vector3(0, 3.5, 7.5), 1.6).set_trans(Tween.TRANS_SINE)
		"sealed_lord":
			# Slow rise as if breaking a seal.
			target.position = Vector3(0, -1.0, 0)
			target.scale = Vector3.ONE
			var rise := target.create_tween()
			rise.tween_property(target, "position", Vector3(0, 0, 0), 1.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		_:
			return false
	return true

# Tone feedback: a tiny camera nudge when the player picks a choice tone.
static func nudge_for_tone(camera: Camera3D, tone: int) -> void:
	if camera == null: return
	var base := camera.position
	var t := camera.create_tween()
	match tone:
		0:  # AGGRESSIVE - sharp push-in
			t.tween_property(camera, "position", base + Vector3(0, 0, -0.4), 0.10).set_trans(Tween.TRANS_EXPO)
			t.tween_property(camera, "position", base, 0.18)
		1:  # DIPLOMATIC - slight pull-out
			t.tween_property(camera, "position", base + Vector3(0, 0.05, 0.3), 0.25)
			t.tween_property(camera, "position", base, 0.25)
		2:  # CAUTIOUS - subtle drift left
			t.tween_property(camera, "position", base + Vector3(-0.15, 0, 0), 0.20)
			t.tween_property(camera, "position", base, 0.20)
		3:  # CURIOUS - tilt up
			t.tween_property(camera, "position", base + Vector3(0, 0.15, -0.2), 0.25)
			t.tween_property(camera, "position", base, 0.25)
		4:  # DECEPTIVE - smooth side-step
			t.tween_property(camera, "position", base + Vector3(0.20, 0, 0.1), 0.30)
			t.tween_property(camera, "position", base, 0.30)
		5:  # MYSTICAL - slow zoom-in
			t.tween_property(camera, "position", base + Vector3(0, 0.10, -0.5), 0.45).set_trans(Tween.TRANS_SINE)
			t.tween_property(camera, "position", base, 0.30)

# Situation arrival: brief reveal cinematic per situation kind.
static func play_for_situation(sit_id: StringName, target: Node3D, camera: Camera3D, tree: SceneTree) -> void:
	if target == null: return
	target.scale = Vector3.ZERO
	var t := target.create_tween()
	t.tween_property(target, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	match String(sit_id):
		"collapse":
			_shake_camera(camera, tree, 0.25, 1.0)
			_flash_screen(tree, Color(0.55, 0.25, 0.1, 0.6), 0.18)
		"storm":
			_shake_camera(camera, tree, 0.15, 1.5)
			_flash_screen(tree, Color(1, 1, 1, 0.85), 0.12)
		"deep_well":
			var cam := camera.create_tween()
			cam.tween_property(camera, "position", HOME_CAM + Vector3(0, 1.0, -1.0), 1.0)
		"the_double":
			_flash_screen(tree, Color(0.05, 0.0, 0.10, 0.85), 0.40)
		"shrine":
			_flash_screen(tree, Color(1.0, 0.95, 0.65, 0.55), 0.40)
		"stranger":
			_flash_screen(tree, Color(0.15, 0.05, 0.20, 0.30), 0.20)
		"burning_tree":
			_flash_screen(tree, Color(1.0, 0.5, 0.10, 0.55), 0.18)
		_:
			pass

# --------------------------- helpers --------------------------------------

static func reset_camera(camera: Camera3D) -> void:
	var t := camera.create_tween().set_parallel(true)
	t.tween_property(camera, "position", HOME_CAM, 0.4)
	t.tween_property(camera, "fov", HOME_FOV, 0.4)

static func _pop(target: Node3D) -> void:
	target.scale = Vector3.ZERO
	var t := target.create_tween()
	t.tween_property(target, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

static func _shake_camera(camera: Camera3D, tree: SceneTree, intensity: float, duration: float) -> void:
	var base: Vector3 = camera.position
	var steps := int(duration / 0.04)
	var t := camera.create_tween()
	for i in steps:
		var off := Vector3(randf_range(-intensity, intensity), randf_range(-intensity, intensity), 0)
		t.tween_property(camera, "position", base + off, 0.04)
	t.tween_property(camera, "position", base, 0.05)

static func _flash_screen(tree: SceneTree, color: Color, duration: float) -> void:
	var root := tree.current_scene
	if root == null: return
	var layer := CanvasLayer.new()
	layer.layer = 100
	root.add_child(layer)
	var rect := ColorRect.new()
	rect.color = color
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	var t := rect.create_tween()
	t.tween_property(rect, "modulate:a", 0.0, duration)
	t.tween_callback(func():
		if is_instance_valid(layer): layer.queue_free())
