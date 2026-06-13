class_name AssetLoader extends RefCounted
# Loads external 3D models from res://assets/models/, with procedural fallback.
# Resolution order for a creature:
#   1. assets/models/<id>.glb              (e.g. dire_wolf.glb)
#   2. assets/models/family_<name>.glb     (e.g. family_beast.glb)
#   3. null  -> caller falls back to procedural primitives.

const FAMILY_NAMES := [
	"humanoid", "beast", "undead", "construct",
	"elemental", "aberration", "fey", "draconic",
]

# Cache instantiated PackedScenes for reuse.
static var _cache: Dictionary = {}

static func _load(path: String) -> PackedScene:
	if _cache.has(path): return _cache[path]
	if not ResourceLoader.exists(path): return null
	var res := load(path)
	# GLB files load as PackedScene when imported by Godot.
	if res is PackedScene:
		_cache[path] = res
		return res
	return null

static func instance_for_creature(id: StringName, family: int) -> Node3D:
	var p := "res://assets/models/%s.glb" % String(id)
	var scn := _load(p)
	if scn == null and family >= 0 and family < FAMILY_NAMES.size():
		scn = _load("res://assets/models/family_%s.glb" % FAMILY_NAMES[family])
	if scn == null: return null
	return scn.instantiate()

static func instance_for_dragon(id: StringName) -> Node3D:
	# Per-dragon file first (both naming conventions), then generic fallback.
	var scn := _load("res://assets/models/%s.glb" % String(id))
	if scn == null:
		scn = _load("res://assets/models/dragon_%s.glb" % String(id))
	if scn == null:
		scn = _load("res://assets/models/dragon.glb")
	if scn == null: return null
	return scn.instantiate()

# Rescale an imported model to a target height and snap its feet to y=0.
# Imported GLBs arrive in wildly different units (cm vs m); this fixes both
# the kilometre-tall whale and the 0.8 m vampire problems.
static func normalize_height(node: Node3D, target_height: float) -> void:
	var aabb := _aabb_in_parent_space(node)
	if aabb.size.y <= 0.001: return
	var factor: float = clampf(target_height / aabb.size.y, 0.0005, 500.0)
	node.scale = node.scale * factor
	var snapped := _aabb_in_parent_space(node)
	node.position.y -= snapped.position.y

# AABB of all meshes under `node`, expressed in node's PARENT space, so the
# result is directly comparable to node.position / node.scale adjustments.
static func _aabb_in_parent_space(node: Node3D) -> AABB:
	var base: Transform3D = Transform3D.IDENTITY
	var parent := node.get_parent()
	if parent is Node3D:
		base = (parent as Node3D).global_transform.affine_inverse()
	var combined := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var a: AABB = (mi as MeshInstance3D).get_aabb()
		var xf: Transform3D = base * (mi as MeshInstance3D).global_transform
		a = xf * a
		if first: combined = a; first = false
		else: combined = combined.merge(a)
	return combined

static func instance_for_boss(id: StringName) -> Node3D:
	var p := "res://assets/models/boss_%s.glb" % String(id)
	var scn := _load(p)
	if scn == null: return null
	return scn.instantiate()

static func instance_for_biome_prop(biome: StringName, kind: StringName) -> Node3D:
	# e.g. instance_for_biome_prop(&"forest", &"tree")
	var p := "res://assets/models/biome_%s_%s.glb" % [String(biome), String(kind)]
	var scn := _load(p)
	if scn == null: return null
	return scn.instantiate()

static func instance_for_player(class_kind: int) -> Node3D:
	var names := ["soldat", "eclaireur", "mystique", "voleur"]
	if class_kind < 0 or class_kind >= names.size(): return null
	var p := "res://assets/models/player_%s.glb" % names[class_kind]
	var scn := _load(p)
	if scn == null: return null
	return scn.instantiate()

# True only if the node has an AnimationPlayer with at least one real,
# non-trivial animation. Static GLB exports (KayKit/Quaternius bind-pose
# models) return false — callers fall back to posed procedural builds so a
# rig never shows its naked T-pose.
static func has_animations(node: Node3D) -> bool:
	if node == null: return false
	var ap := node.find_child("AnimationPlayer", true, false)
	if not (ap is AnimationPlayer): return false
	var names := (ap as AnimationPlayer).get_animation_list()
	for n in names:
		# Godot auto-adds a "RESET" track; ignore it.
		if String(n).to_upper() != "RESET":
			return true
	return false

# Play the model's first animation in loop, if any.
static func play_first_animation(node: Node3D) -> void:
	play_named_action(node, &"idle", true)

# Find an animation matching any of the keywords (case-insensitive).
# Falls back to the first available animation if none match.
static func find_animation_for(node: Node3D, keywords: PackedStringArray) -> String:
	var ap := node.find_child("AnimationPlayer", true, false)
	if not (ap is AnimationPlayer): return ""
	var anim_player: AnimationPlayer = ap
	var names := anim_player.get_animation_list()
	for kw in keywords:
		for n in names:
			if String(n).to_lower().contains(kw.to_lower()):
				return n
	if names.size() > 0: return names[0]
	return ""

# Trigger a named "action" by mapping it to common animation names.
# loop: true for idle/walk, false for one-shot actions.
static func play_named_action(node: Node3D, action: StringName, loop: bool) -> void:
	var ap := node.find_child("AnimationPlayer", true, false)
	if not (ap is AnimationPlayer):
		# Rig has no AnimationPlayer (static GLB or stripped export). Add a
		# procedural breath cycle so the model never freezes in T-pose.
		if action == &"idle": _breathe_loop(node)
		return
	var anim_player: AnimationPlayer = ap
	var keywords: PackedStringArray
	match String(action):
		"idle":   keywords = PackedStringArray(["idle", "stand", "wait", "breathe", "static", "pose"])
		"walk":   keywords = PackedStringArray(["walk", "run", "march", "move"])
		"attack": keywords = PackedStringArray(["attack", "strike", "bite", "swing", "punch", "fire"])
		"hit":    keywords = PackedStringArray(["hit", "hurt", "damage", "impact", "recoil"])
		"die":    keywords = PackedStringArray(["die", "death", "fall", "dead", "ko"])
		"flee":   keywords = PackedStringArray(["run", "walk", "flee", "escape"])
		"fly":    keywords = PackedStringArray(["fly", "flap", "glide", "hover", "wing"])
		"mutate": keywords = PackedStringArray(["mutate", "transform", "shake", "summon"])
		_:        keywords = PackedStringArray([String(action)])
	var anim_name := find_animation_for(node, keywords)
	if anim_name == "":
		# No matching anim — fall back to anything available so we don't show
		# the T-pose. If even that is empty, graft a breath cycle.
		var any_name := find_animation_for(node, PackedStringArray([""]))
		if any_name == "":
			if action == &"idle": _breathe_loop(node)
			return
		anim_name = any_name
	var anim := anim_player.get_animation(anim_name)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	anim_player.play(anim_name)
	# After a one-shot action, queue back to idle via the AnimationPlayer's queue.
	if not loop and action != &"die":
		var idle_name := find_animation_for(node, PackedStringArray(["idle", "stand", "wait"]))
		if idle_name != "" and idle_name != anim_name:
			var idle_anim := anim_player.get_animation(idle_name)
			if idle_anim:
				idle_anim.loop_mode = Animation.LOOP_LINEAR
			anim_player.queue(idle_name)

# Procedural breath cycle for rigs that have no AnimationPlayer or whose anims
# don't include any usable idle — beats showing a T-pose. Subtle Y scale + bob.
static func _breathe_loop(node: Node3D, _loop: bool = true) -> void:
	if node == null or not is_instance_valid(node): return
	if node.has_meta("breathing"): return
	node.set_meta("breathing", true)
	var base_y := node.position.y
	var base_scale := node.scale
	var t := node.create_tween().set_loops()
	t.tween_property(node, "scale", Vector3(base_scale.x, base_scale.y * 1.012, base_scale.z), 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(node, "position:y", base_y + 0.018, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "scale", base_scale, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(node, "position:y", base_y, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
