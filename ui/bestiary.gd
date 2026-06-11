extends Node3D
# Bestiary: scrollable codex of all creatures, dragons and titans.
# Each entry has a 3D thumbnail rendered into a SubViewport.

signal back_pressed()

@onready var list: VBoxContainer = $UI/Root/Scroll/List
@onready var back_btn: Button = $UI/Root/BackBtn
@onready var title: Label = $UI/Root/Title
@onready var tab_all: Button = $UI/Root/TabRow/TabAll
@onready var tab_creatures: Button = $UI/Root/TabRow/TabCreatures
@onready var tab_dragons: Button = $UI/Root/TabRow/TabDragons
@onready var tab_titans: Button = $UI/Root/TabRow/TabTitans

const THUMB_SIZE := Vector2i(128, 128)

var _filter: String = "all"

func _ready() -> void:
	back_btn.pressed.connect(func(): back_pressed.emit())
	tab_all.pressed.connect(func(): _set_filter("all"))
	tab_creatures.pressed.connect(func(): _set_filter("creatures"))
	tab_dragons.pressed.connect(func(): _set_filter("dragons"))
	tab_titans.pressed.connect(func(): _set_filter("titans"))
	_refresh_labels()
	_populate()

func _refresh_labels() -> void:
	title.text = Lang.ui("menu_codex")
	back_btn.text = Lang.ui("back")
	tab_all.text = Lang.ui("all")
	tab_creatures.text = Lang.ui("creatures")
	tab_dragons.text = Lang.ui("dragons")
	tab_titans.text = Lang.ui("titans")

func _set_filter(f: String) -> void:
	_filter = f
	_populate()

func _populate() -> void:
	for c in list.get_children(): c.queue_free()
	# Build entries with deferred thumbnails to keep mobile perf sane.
	if _filter in ["all", "creatures"]:
		for t in CreatureRegistry.templates():
			list.add_child(_creature_entry(t))
	if _filter in ["all", "dragons"]:
		for t in DragonRegistry.templates():
			list.add_child(_dragon_entry(t))
	if _filter in ["all", "titans"]:
		for t in WorldBossRegistry.templates():
			list.add_child(_titan_entry(t))
	# Defer first thumbnail visibility check to next frame.
	call_deferred("_check_visible_thumbs")
	if not get_tree().process_frame.is_connected(_check_visible_thumbs):
		get_tree().process_frame.connect(_check_visible_thumbs)

func _check_visible_thumbs() -> void:
	# Render thumbnails only when their row is on screen. Cheap heuristic:
	# compare row global rect against scroll viewport rect.
	var scroll: ScrollContainer = $UI/Root/Scroll
	var scroll_rect := scroll.get_global_rect()
	for child in list.get_children():
		if not child.has_meta("thumb_pending"): continue
		var r := child.get_global_rect()
		if r.intersects(scroll_rect.grow(120)):
			_realize_thumb(child)

# ---------- entry builders ----------

func _placeholder_thumb() -> Control:
	var c := ColorRect.new()
	c.color = Color(0.08, 0.07, 0.10, 1)
	c.custom_minimum_size = Vector2(THUMB_SIZE.x, THUMB_SIZE.y)
	return c

func _realize_thumb(row: Control) -> void:
	if not row.has_meta("thumb_pending"): return
	row.remove_meta("thumb_pending")
	var kind: String = row.get_meta("thumb_kind")
	var data: Dictionary = row.get_meta("thumb_data")
	var holder: Control = row.get_meta("thumb_holder")
	var real: Control
	match kind:
		"creature": real = _build_thumb_creature(data)
		"dragon":   real = _build_thumb_dragon(StringName(data.id))
		"titan":    real = _build_thumb_titan(StringName(data.id))
	if real == null: return
	real.custom_minimum_size = Vector2(THUMB_SIZE.x, THUMB_SIZE.y)
	var parent := holder.get_parent()
	var idx := holder.get_index()
	parent.remove_child(holder)
	holder.queue_free()
	parent.add_child(real)
	parent.move_child(real, idx)

func _row(thumb: Control, name: String, tag: String, tag_color: Color, body_lines: Array[String]) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 160)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	panel.add_child(h)
	thumb.custom_minimum_size = Vector2(THUMB_SIZE.x, THUMB_SIZE.y)
	h.add_child(thumb)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	h.add_child(v)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	v.add_child(head)
	var name_lbl := Label.new()
	name_lbl.text = name
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	head.add_child(name_lbl)
	var tag_lbl := Label.new()
	tag_lbl.text = "  %s  " % tag
	tag_lbl.add_theme_font_size_override("font_size", 14)
	tag_lbl.add_theme_color_override("font_color", tag_color)
	head.add_child(tag_lbl)
	for line in body_lines:
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.text = line
		l.add_theme_font_size_override("normal_font_size", 14)
		v.add_child(l)
	return panel

func _creature_entry(t: Dictionary) -> Control:
	var tag := _tier_tag(int(t.tier))
	var color := _tier_color(int(t.tier))
	var thumb := _placeholder_thumb()
	var fam := _family_name(int(t.family))
	var biome_list: String = ""
	for b in t.biomes: biome_list += String(b) + "  "
	var kills := Progress.kill_count(StringName(t.id))
	var lines: Array[String] = []
	lines.append("[i]%s[/i]   INT %d   AGR %d   [color=#ffd57a]× %d[/color]" % [fam, int(t.intel), int(t.aggr), kills])
	lines.append("[color=#a0c8ff]%s[/color]  %s" % [Lang.ui("biomes"), biome_list.strip_edges()])
	lines.append("[color=#9fffa8]%s[/color]  %s" % [Lang.ui("weakness"), _approach_hint(t)])
	var row := _row(thumb, String(t.name), tag, color, lines)
	row.set_meta("thumb_pending", true)
	row.set_meta("thumb_kind", "creature")
	row.set_meta("thumb_data", t)
	row.set_meta("thumb_holder", thumb)
	return row

func _dragon_entry(t: Dictionary) -> Control:
	var weight: int = int(t.weight)
	var rarity_str := "%s — %s" % [Lang.ui("tag_dragon"), _dragon_rarity_word(weight)]
	var color := _dragon_color(int(t.align))
	var thumb := _placeholder_thumb()
	var align_str := ["méchant", "bon", "au-delà"][int(t.align)]
	var lines: Array[String] = []
	lines.append("[i]%s — puissance %d[/i]" % [align_str, int(t.tier)])
	lines.append("[color=#ffd57a]%s[/color]  %s" % [Lang.ui("effect"), _dragon_effect_text(String(t.zone_effect), int(t.value))])
	lines.append("[color=#cccccc]%s[/color]" % String(t.intro))
	var row := _row(thumb, String(t.name), rarity_str, color, lines)
	row.set_meta("thumb_pending", true)
	row.set_meta("thumb_kind", "dragon")
	row.set_meta("thumb_data", t)
	row.set_meta("thumb_holder", thumb)
	return row

func _titan_entry(t: Dictionary) -> Control:
	var color := Color(1, 0.5, 0.55)
	var thumb := _placeholder_thumb()
	var lines: Array[String] = []
	lines.append("[i]%s[/i]" % String(t.title))
	lines.append("[color=#ffd57a]%s[/color]  %s" % [Lang.ui("effect"), _titan_effect_text(String(t.effect))])
	lines.append("[color=#cccccc]%s[/color]" % String(t.intro))
	var row := _row(thumb, String(t.name), Lang.ui("tag_wboss"), color, lines)
	row.set_meta("thumb_pending", true)
	row.set_meta("thumb_kind", "titan")
	row.set_meta("thumb_data", t)
	row.set_meta("thumb_holder", thumb)
	return row

# ---------- thumbnails (SubViewport) ----------

func _new_viewport(cam_pos: Vector3, cam_look: Vector3 = Vector3.ZERO) -> SubViewportContainer:
	var cont := SubViewportContainer.new()
	cont.stretch = true
	cont.custom_minimum_size = Vector2(THUMB_SIZE.x, THUMB_SIZE.y)
	var vp := SubViewport.new()
	vp.size = THUMB_SIZE
	vp.transparent_bg = false
	cont.add_child(vp)
	var cam := Camera3D.new()
	cam.position = cam_pos
	cam.look_at_from_position(cam_pos, cam_look, Vector3.UP)
	cam.fov = 35.0
	vp.add_child(cam)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-45, -30, 0)
	key.light_energy = 1.1
	vp.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-15, 130, 0)
	fill.light_energy = 0.4
	fill.light_color = Color(0.75, 0.85, 1.0)
	vp.add_child(fill)
	return cont

func _build_thumb_creature(t: Dictionary) -> Control:
	var cont := _new_viewport(Vector3(0, 1.4, 4.0), Vector3(0, 1.0, 0))
	var arch := Archetype.new()
	arch.id = StringName(t.id)
	arch.family = int(t.family)
	arch.tier = int(t.tier)
	arch.intelligence = int(t.intel)
	arch.aggression = int(t.aggr)
	var c3 := Creature3D.new()
	cont.get_child(0).add_child(c3)
	c3.build(arch)
	return cont

func _build_thumb_dragon(id: StringName) -> Control:
	var cont := _new_viewport(Vector3(0, 1.5, 9.0), Vector3(0, 1.0, 0))
	var d := Dragon3D.new()
	cont.get_child(0).add_child(d)
	d.build(id)
	d.scale = Vector3.ONE * 0.55
	d.rotation_degrees.y = -20.0
	return cont

func _build_thumb_titan(id: StringName) -> Control:
	var cont := _new_viewport(Vector3(0, 5.0, 14.0), Vector3(0, 3.0, 0))
	var b := WorldBoss3D.new()
	cont.get_child(0).add_child(b)
	b.build(id)
	b.scale = Vector3.ONE * 0.4
	return cont

# ---------- helpers ----------

func _tier_tag(tier: int) -> String:
	match tier:
		0: return Lang.ui("tag_common")
		1: return Lang.ui("tag_uncommon")
		2: return Lang.ui("tag_rare")
		3: return Lang.ui("tag_elite")
		4: return Lang.ui("tag_apex")
		5: return Lang.ui("tag_mythic")
		_: return "?"

func _tier_color(tier: int) -> Color:
	match tier:
		0: return Color(0.85, 0.85, 0.85)
		1: return Color(0.55, 0.95, 0.55)
		2: return Color(0.55, 0.75, 1.0)
		3: return Color(0.85, 0.55, 1.0)
		4: return Color(1.0, 0.65, 0.30)
		5: return Color(1.0, 0.30, 0.30)
		_: return Color.WHITE

func _family_name(fam: int) -> String:
	match fam:
		0: return "Humanoïde"
		1: return "Bête"
		2: return "Mort-vivant"
		3: return "Construct"
		4: return "Élémentaire"
		5: return "Aberration"
		6: return "Fée"
		7: return "Draconide"
		_: return "Entité"

func _approach_hint(t: Dictionary) -> String:
	var intel: int = int(t.intel)
	var aggr: int = int(t.aggr)
	var fam: int = int(t.family)
	var hints: Array[String] = []
	if intel >= 70: hints.append("Diplomatie")
	if intel >= 30 and intel < 70: hints.append("Tromperie")
	if intel < 30: hints.append("Combat ou Discrétion")
	if aggr >= 70 and intel < 50: hints.append("Fuir")
	if fam == 2 or fam == 5: hints.append("Mystique")
	if fam == 6: hints.append("Curieux ou Mystique")
	if fam == 3: hints.append("Combat ou Mystique")
	return ", ".join(hints) if hints.size() > 0 else "Toutes approches"

func _dragon_color(align: int) -> Color:
	match align:
		0: return Color(1.0, 0.40, 0.40)   # EVIL
		1: return Color(0.55, 1.0, 0.75)   # GOOD
		2: return Color(0.85, 0.55, 1.0)   # BEYOND
		_: return Color.WHITE

func _dragon_rarity_word(w: int) -> String:
	if w <= 2: return "Quasi-mythique"
	if w <= 5: return "Très rare"
	if w <= 10: return "Rare"
	if w <= 15: return "Peu commun"
	return "Commun"

func _dragon_effect_text(effect: String, value: int) -> String:
	match effect:
		"aggression_boost":   return "Toutes les créatures gagnent +%d en agression" % value
		"intel_boost":        return "Toutes les créatures gagnent +%d en intelligence" % value
		"corruption_double":  return "La corruption de la zone est doublée"
		"swingy_rolls":       return "Les succès deviennent critiques, les échecs deviennent déroutes (%d%%)" % value
		"mixed_becomes_fail": return "Les résultats mitigés deviennent des échecs"
		"slow_flight":        return "Fuir devient nettement plus difficile (+%d)" % value
		"peace_truce":        return "Diplomatie facilitée (-%d à la difficulté)" % value
		"deceptive_boost":    return "Tromperie facilitée (-%d à la difficulté)" % value
		"guided_instinct":    return "+%d à toutes les actions guidées par l'INSTINCT" % value
		"free_crit_cursed":   return "Ton premier échec critique est annulé contre une malédiction"
		"delete_creature":    return "Une créature de la zone est effacée de l'existence"
		_:                    return effect

func _titan_effect_text(effect: String) -> String:
	match effect:
		"all_tones_mixed":     return "Tous les tons sont teintés d'incertitude"
		"strip_memory":        return "Il efface ce qui te définissait"
		"flood_corruption":    return "La corruption envahit la zone"
		"judge_every_choice":  return "Chaque choix est pesé"
		"disable_dialogue":    return "Les mots ne servent plus à rien"
		"invert_outcomes":     return "Le hasard se retourne contre toi"
		_:                     return effect
