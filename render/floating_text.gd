class_name FloatingText extends RefCounted
# Spawns a transient Label3D that drifts up + fades. Use for damage/heal numbers,
# stat gains, and short status callouts above creatures or players.

static func spawn(parent: Node3D, world_pos: Vector3, text: String, color: Color, size: float = 0.4) -> void:
	var lbl := Label3D.new()
	lbl.text = text
	lbl.modulate = color
	lbl.font_size = 48
	lbl.outline_size = 8
	lbl.outline_modulate = Color(0, 0, 0, 0.85)
	lbl.pixel_size = 0.004 * size
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.position = world_pos
	parent.add_child(lbl)
	var t := lbl.create_tween().set_parallel(true)
	t.tween_property(lbl, "position", world_pos + Vector3(0, 1.2, 0), 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(lbl, "modulate:a", 0.0, 1.4).set_delay(0.5)
	t.chain().tween_callback(func():
		if is_instance_valid(lbl): lbl.queue_free())
