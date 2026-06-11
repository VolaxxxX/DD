class_name FloatingText extends RefCounted
# Polished floating world-space text: weight, shadow, scale punch, fade.

static func spawn(parent: Node3D, world_pos: Vector3, text: String, color: Color, size: float = 0.4) -> void:
	var lbl := Label3D.new()
	lbl.text = text
	lbl.modulate = color
	lbl.font_size = 64
	lbl.outline_size = 12
	lbl.outline_modulate = Color(0, 0, 0, 0.95)
	lbl.pixel_size = 0.0035 * size
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.position = world_pos
	lbl.scale = Vector3.ZERO
	parent.add_child(lbl)
	# Punch in, drift up, fade out.
	var t := lbl.create_tween().set_parallel(true)
	t.tween_property(lbl, "scale", Vector3.ONE * 1.15, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(lbl, "position", world_pos + Vector3(0, 1.4, 0), 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(lbl, "scale", Vector3.ONE, 0.10)
	t.parallel().tween_property(lbl, "modulate:a", 0.0, 1.2).set_delay(0.4)
	t.chain().tween_callback(func():
		if is_instance_valid(lbl): lbl.queue_free())
