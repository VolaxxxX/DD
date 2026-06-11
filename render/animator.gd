class_name Animator extends Node
# Tween-based animation controller for 3D body nodes.

var target: Node3D
var _idle_tween: Tween
var _base_pos: Vector3
var _base_rot: Vector3
var _base_scale: Vector3

func _ready() -> void:
	if target:
		_base_pos = target.position
		_base_rot = target.rotation_degrees
		_base_scale = target.scale

func start_idle() -> void:
	if target == null: return
	_base_pos = target.position
	_base_rot = target.rotation_degrees
	_base_scale = target.scale
	_stop_idle()
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(target, "position:y", _base_pos.y + 0.06, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(target, "position:y", _base_pos.y, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_idle() -> void:
	if _idle_tween and _idle_tween.is_valid(): _idle_tween.kill()

func play_hit() -> void:
	if target == null: return
	var t := create_tween()
	t.tween_property(target, "position:x", _base_pos.x - 0.25, 0.08)
	t.tween_property(target, "position:x", _base_pos.x + 0.15, 0.08)
	t.tween_property(target, "position:x", _base_pos.x, 0.10)
	_flash(Color(1.0, 0.3, 0.3))

func play_attack() -> void:
	# Forward lunge + downward tilt + recoil. Used for procedural creatures
	# without an imported attack animation.
	if target == null: return
	var t := create_tween()
	t.tween_property(target, "position:z", _base_pos.z + 0.85, 0.12).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(target, "rotation_degrees:x", _base_rot.x - 18.0, 0.10)
	t.tween_property(target, "position:z", _base_pos.z, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(target, "rotation_degrees:x", _base_rot.x, 0.25)
	_flash(Color(1.0, 0.6, 0.2))

func play_die() -> void:
	if target == null: return
	_stop_idle()
	var t := create_tween().set_parallel(true)
	t.tween_property(target, "rotation_degrees:z", _base_rot.z + 90.0, 0.6).set_ease(Tween.EASE_IN)
	t.tween_property(target, "position:y", _base_pos.y - 0.6, 0.6).set_ease(Tween.EASE_IN)
	t.tween_property(target, "scale", _base_scale * 0.9, 0.6)
	var fade := create_tween()
	fade.tween_interval(0.4)
	fade.tween_callback(_fade_out)

func play_flee() -> void:
	if target == null: return
	_stop_idle()
	var t := create_tween().set_parallel(true)
	t.tween_property(target, "position:z", _base_pos.z - 6.0, 0.9).set_ease(Tween.EASE_IN)
	t.tween_property(target, "scale", _base_scale * 0.3, 0.9)

func play_mutate() -> void:
	if target == null: return
	var t := create_tween()
	t.tween_property(target, "scale", _base_scale * 1.25, 0.3)
	t.tween_property(target, "scale", _base_scale * 0.9, 0.2)
	t.tween_property(target, "scale", _base_scale * 1.1, 0.2)
	_flash(Color(0.8, 0.2, 1.0))
	start_idle()

func _flash(color: Color) -> void:
	for child in target.get_children():
		if child is MeshInstance3D:
			var mi := child as MeshInstance3D
			var original := mi.material_override
			var mat := StandardMaterial3D.new()
			if original is StandardMaterial3D:
				var orig_mat := original as StandardMaterial3D
				mat.albedo_color = orig_mat.albedo_color
			mat.emission_enabled = true
			mat.emission = color
			mat.emission_energy_multiplier = 2.0
			mi.material_override = mat
			var t := create_tween()
			t.tween_interval(0.25)
			t.tween_callback(func(): mi.material_override = original)

func _fade_out() -> void:
	var t := create_tween()
	t.tween_interval(0.3)
	t.tween_callback(func():
		if is_instance_valid(target) and is_instance_valid(target.get_parent()):
			target.get_parent().queue_free()
	)
