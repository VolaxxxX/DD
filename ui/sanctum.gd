extends Node3D
# The Sanctuaire — the lived-in hub the Voyageur returns to between runs.
# It grows visually instead of distributing stats: PNJ saved come live here,
# every defeated creature becomes a small trophy, and the Keeper speaks the
# next meta-story fragment if one is pending.

signal back_pressed()

const KEEPER_NAME := {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"}

@onready var anchor: Node3D = $Anchor if has_node("Anchor") else null

var _backdrop: Backdrop3D
var _cam: Camera3D
var _ui_layer: CanvasLayer

func _ready() -> void:
	# Ambient scene: a calm clearing biome backdrop, a centerpiece altar, then
	# one prop per saved resident + one trophy per distinct defeated creature.
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.10, 0.13, 0.22)
	sky_mat.sky_horizon_color = Color(0.55, 0.50, 0.60)
	sky_mat.ground_horizon_color = Color(0.40, 0.36, 0.32)
	sky_mat.ground_bottom_color = Color(0.06, 0.06, 0.08)
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color(0.6, 0.55, 0.7)
	e.fog_density = 0.008
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.92, 0.78)
	add_child(sun)

	_backdrop = Backdrop3D.new()
	add_child(_backdrop)
	_backdrop.build(&"highland", 0.1, 0)

	# Centerpiece: an altar (the Sanctuary's heart).
	var altar := NatureLib.instance("gy_altar_stone")
	if altar != null:
		altar.position = Vector3(0, 0, -2.0)
		altar.scale = Vector3.ONE * 1.4
		add_child(altar)
	# Lantern lights to make it feel inhabited.
	for off in [Vector3(-3, 0, -3), Vector3(3, 0, -3), Vector3(-2.5, 0, 1.5), Vector3(2.5, 0, 1.5)]:
		var lamp := NatureLib.instance("tn_lantern")
		if lamp != null:
			lamp.position = off
			add_child(lamp)

	# Residents: a small humanoid figure per saved PNJ, arranged in an arc.
	var rcount: int = Progress.sanctum_residents.size()
	for i in rcount:
		var person := FaunaLib.instance_for(0, StringName("res_%d" % i))
		if person == null: continue
		var ang: float = -1.2 + (1.0 + float(i)) * (2.4 / float(maxi(1, rcount + 1)))
		person.position = Vector3(cos(ang) * 4.2, 0, sin(ang) * 4.2 - 0.3)
		person.rotation.y = ang + PI
		add_child(person)

	# Trophies: a small obelisk per distinct defeated creature.
	var tcount: int = Progress.sanctum_trophies.size()
	for i in tcount:
		var tro := NatureLib.instance("gy_gravestone_cross" if i % 2 == 0 else "statue_block")
		if tro == null: continue
		var col := i / 6
		var row := i % 6
		tro.position = Vector3(-6.5 + col * 1.1, 0, -5.5 + row * 0.9)
		tro.scale = Vector3.ONE * 0.6
		add_child(tro)

	# Camera.
	_cam = Camera3D.new()
	_cam.position = Vector3(0, 3.0, 6.0)
	_cam.fov = 55.0
	add_child(_cam)
	_cam.look_at(Vector3(0, 1.0, -1.5), Vector3.UP)
	_cam.make_current()

	# UI layer: title, Keeper speech (if a story fragment was queued), Back.
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)
	_build_ui()

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(root)

	var title := Label.new()
	title.text = Lang.t({"fr": "🜂 LE SANCTUAIRE", "en": "🜂 THE SANCTUARY", "id": "🜂 SANCTUARI"})
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.70))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0; title.anchor_right = 1
	title.offset_top = 26; title.offset_bottom = 76
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title)

	# Summary line: residents / trophies / echoes / story progression.
	var sub := Label.new()
	sub.text = Lang.t({
		"fr": "👥 %d résident·e·s   ·   🗿 %d trophées   ·   🜂 %d Échos   ·   📜 %d/%d" % [
			Progress.sanctum_residents.size(), Progress.sanctum_trophies.size(),
			Progress.echoes, Progress.story_index, MetaStory.step_count()],
		"en": "👥 %d residents   ·   🗿 %d trophies   ·   🜂 %d Echoes   ·   📜 %d/%d" % [
			Progress.sanctum_residents.size(), Progress.sanctum_trophies.size(),
			Progress.echoes, Progress.story_index, MetaStory.step_count()],
		"id": "👥 %d penghuni   ·   🗿 %d trofi   ·   🜂 %d Gema   ·   📜 %d/%d" % [
			Progress.sanctum_residents.size(), Progress.sanctum_trophies.size(),
			Progress.echoes, Progress.story_index, MetaStory.step_count()],
	})
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color(0.88, 0.82, 0.6))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.anchor_left = 0; sub.anchor_right = 1
	sub.offset_top = 78; sub.offset_bottom = 110
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sub)

	# Keeper speech bubble (shows the most recently revealed story fragment).
	if Progress.story_index > 0:
		var step := MetaStory.step(Progress.story_index - 1, Lang.code,
			Progress.voyageur_name, Progress.flair_name)
		if not step.is_empty():
			var panel := PanelContainer.new()
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0.05, 0.05, 0.08, 0.85)
			sb.set_corner_radius_all(12)
			sb.set_border_width_all(2)
			sb.border_color = Color(0.85, 0.72, 0.4, 0.7)
			sb.set_content_margin_all(18)
			panel.add_theme_stylebox_override("panel", sb)
			panel.anchor_left = 0.1; panel.anchor_right = 0.9
			panel.anchor_top = 1.0; panel.anchor_bottom = 1.0
			panel.offset_top = -210; panel.offset_bottom = -100
			root.add_child(panel)
			var vb := VBoxContainer.new()
			panel.add_child(vb)
			var who := Label.new()
			who.text = "— " + String(step.get("speaker", ""))
			who.add_theme_font_size_override("font_size", 15)
			who.add_theme_color_override("font_color", Color(0.85, 0.72, 0.4))
			vb.add_child(who)
			var body := Label.new()
			body.text = String(step.get("text", ""))
			body.add_theme_font_size_override("font_size", 17)
			body.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
			body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vb.add_child(body)

	# Back button.
	var back := Button.new()
	back.text = Lang.t({"fr": "← Retour", "en": "← Back", "id": "← Kembali"})
	back.add_theme_font_size_override("font_size", 18)
	back.custom_minimum_size = Vector2(140, 48)
	back.anchor_left = 0; back.anchor_right = 0
	back.offset_left = 20; back.offset_right = 160
	back.offset_top = 20; back.offset_bottom = 68
	back.pressed.connect(func():
		Audio.play(&"click")
		back_pressed.emit())
	root.add_child(back)
