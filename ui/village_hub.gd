extends Control
# Hub Village: safe stop between zones. Players spend fragments on healers,
# merchants, storytellers, and travelers. No combat, no situations.

signal continue_journey()

var _player: PlayerState

func setup(player: PlayerState) -> void:
	_player = player
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.08, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 620)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)
	# Header
	var title := Label.new()
	title.text = Lang.ui("village_title")
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.92, 0.78))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var sub := Label.new()
	sub.text = Lang.ui("village_subtitle")
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color(0.78, 0.78, 0.85))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)
	_refresh_purse(v)
	# NPC offers
	_make_offer(v, "❣", &"healer", Lang.ui("npc_healer"), Lang.ui("npc_healer_desc"), 2,
		func(): return _service_heal())
	_make_offer(v, "✦", &"sage", Lang.ui("npc_sage"), Lang.ui("npc_sage_desc"), 4,
		func(): return _service_blessing())
	_make_offer(v, "⚒", &"merchant", Lang.ui("npc_merchant"), Lang.ui("npc_merchant_desc"), 3,
		func(): return _service_potion())
	_make_offer(v, "♛", &"keeper", Lang.ui("npc_keeper"), Lang.ui("npc_keeper_desc"), 6,
		func(): return _service_second_chance())
	# Continue
	var go := Button.new()
	go.text = Lang.ui("village_continue")
	go.custom_minimum_size = Vector2(0, 54)
	go.add_theme_font_size_override("font_size", 22)
	go.pressed.connect(func():
		Audio.play(&"click")
		continue_journey.emit()
		queue_free())
	v.add_child(go)

var _purse_label: Label

func _refresh_purse(parent: VBoxContainer) -> void:
	if _purse_label == null:
		_purse_label = Label.new()
		_purse_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_purse_label.add_theme_font_size_override("font_size", 22)
		_purse_label.add_theme_color_override("font_color", Color(1, 0.85, 0.40))
		parent.add_child(_purse_label)
	_purse_label.text = "✦ %d %s" % [Progress.fragments, Lang.ui("fragments")]

func _make_offer(parent: VBoxContainer, glyph: String, id: StringName, name: String, desc: String, cost: int, action: Callable) -> void:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 88)
	parent.add_child(row)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	row.add_child(h)
	var sym := Label.new()
	sym.text = glyph
	sym.add_theme_font_size_override("font_size", 36)
	sym.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	sym.custom_minimum_size = Vector2(50, 0)
	h.add_child(sym)
	var vv := VBoxContainer.new()
	vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(vv)
	var nm := Label.new()
	nm.text = name
	nm.add_theme_font_size_override("font_size", 18)
	nm.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	vv.add_child(nm)
	var ds := Label.new()
	ds.text = desc
	ds.add_theme_font_size_override("font_size", 13)
	ds.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	ds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vv.add_child(ds)
	var btn := Button.new()
	btn.text = "✦ %d" % cost
	btn.custom_minimum_size = Vector2(96, 56)
	btn.add_theme_font_size_override("font_size", 20)
	btn.disabled = Progress.fragments < cost
	btn.pressed.connect(func():
		Audio.play(&"click")
		if Progress.spend(cost):
			var result: String = action.call()
			nm.text = name + "  —  " + result
			btn.disabled = true
			_purse_label.text = "✦ %d %s" % [Progress.fragments, Lang.ui("fragments")])
	h.add_child(btn)

# ---- services ----

func _service_heal() -> String:
	if _player.injuries.size() == 0:
		Progress.fragments += 2  # refund — nothing to heal
		Progress.save()
		return Lang.ui("village_refund")
	# Remove the first (oldest) injury.
	var removed_id: StringName = _player.injuries[0]
	_player.injuries.remove_at(0)
	var inj: Dictionary = InjuryRegistry.by_id(removed_id)
	return "− %s" % String(inj.get("name", "?"))

func _service_blessing() -> String:
	# Marks a temporary buff applied at next zone (handled in scene_director).
	var blessings := [&"force", &"esprit", &"vivacite", &"instinct", &"charisme", &"endurance"]
	var pick: StringName = blessings[randi() % blessings.size()]
	Progress.next_zone_blessing = pick
	Progress.save()
	return "+2 %s" % PlayerClass.stat_label(pick)

func _service_potion() -> String:
	# Permanent +1 to a random stat on this player for the run.
	var keys: Array = PlayerClass.stat_keys()
	var pick: StringName = keys[randi() % keys.size()]
	_player.stats[pick] = int(_player.stats.get(pick, 8)) + 1
	return "+1 %s" % PlayerClass.stat_label(pick)

func _service_second_chance() -> String:
	if Progress.can_use_second_chance():
		Progress.fragments += 6  # refund — already had it
		Progress.save()
		return Lang.ui("village_refund_unused")
	Progress.second_chance_used_this_run = false
	return Lang.ui("village_chance_restored")
