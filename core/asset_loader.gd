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

# Only the bespoke per-id model, never the generic family fallback. Lets the
# caller try a higher-quality animated source before the static family GLB.
static func instance_for_creature_id_only(id: StringName) -> Node3D:
	var scn := _load("res://assets/models/%s.glb" % String(id))
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

# Pose a static (animation-less) rig into a natural rest stance: swing the
# upper arms down out of the T-pose, with a faint elbow bend. Tuned for the
# bundled KayKit rigs (rotating the arm bone's LOCAL X drops it straight down
# for both sides). Safe no-op when there's no skeleton or no arm bones.
static func pose_rest(node: Node3D) -> void:
	var sk := _find_skeleton(node)
	if sk == null: return
	for side in ["l", "r"]:
		var ua := _find_bone_like(sk, ["upperarm." + side, "upperarm_" + side, "upper_arm." + side, "shoulder." + side, "arm." + side])
		if ua != -1:
			_local_rotate(sk, ua, Vector3(1, 0, 0), deg_to_rad(-66.0))
		var la := _find_bone_like(sk, ["lowerarm." + side, "lowerarm_" + side, "lower_arm." + side, "forearm." + side])
		if la != -1:
			_local_rotate(sk, la, Vector3(1, 0, 0), deg_to_rad(-16.0))   # slight elbow bend

static func _local_rotate(sk: Skeleton3D, idx: int, axis: Vector3, ang: float) -> void:
	var r := sk.get_bone_pose_rotation(idx)
	sk.set_bone_pose_rotation(idx, r * Quaternion(axis.normalized(), ang))

# Continuous idle: gentle Y bob on the root + tiny chest sway + head bob via
# an internal BoneIdleLife node ticking each frame. Idempotent (safe to call
# again after a pose_rest reset).
static func idle_life(node: Node3D) -> void:
	if node == null or not is_instance_valid(node): return
	if node.has_meta("idle_life"): return
	node.set_meta("idle_life", true)
	var helper := _BoneIdleLife.new()
	helper.target = node
	helper.base_y = node.position.y
	helper.phase = (float(node.get_instance_id() % 10000) / 10000.0) * TAU
	node.add_child(helper)

# Tiny inner class — a Node that ticks each frame to drive the breath cycle.
class _BoneIdleLife extends Node:
	var target: Node3D
	var base_y: float
	var phase: float = 0.0
	var t: float = 0.0
	var _sk: Skeleton3D = null
	var _chest := -1
	var _head := -1
	var _chest_rest := Quaternion.IDENTITY
	var _head_rest := Quaternion.IDENTITY

	func _ready() -> void:
		_sk = _find_skel(target)
		if _sk != null:
			_chest = _find_like(_sk, ["chest", "spine", "torso"])
			_head = _find_like(_sk, ["head", "neck"])
			if _chest != -1: _chest_rest = _sk.get_bone_pose_rotation(_chest)
			if _head != -1: _head_rest = _sk.get_bone_pose_rotation(_head)

	func _process(delta: float) -> void:
		if not is_instance_valid(target): return
		t += delta
		var p := t + phase
		# Root vertical bob, very subtle — under 1.5 cm.
		target.position.y = base_y + sin(p * 1.8) * 0.012
		# Tiny side-to-side sway.
		target.rotation.z = sin(p * 0.7) * 0.012
		if _sk == null: return
		# Chest breathes: small forward tilt on the inhale.
		if _chest != -1:
			var breath := (sin(p * 1.5) + 1.0) * 0.5   # 0..1
			var q := _chest_rest * Quaternion(Vector3(1, 0, 0), breath * 0.025)
			_sk.set_bone_pose_rotation(_chest, q)
		# Head bob, phase-shifted from chest, plus a slow yaw look-around.
		if _head != -1:
			var nod := sin(p * 1.5 + 1.2) * 0.020
			var look := sin(p * 0.4) * 0.08
			var q := _head_rest * Quaternion(Vector3(1, 0, 0), nod) * Quaternion(Vector3(0, 1, 0), look)
			_sk.set_bone_pose_rotation(_head, q)

	static func _find_skel(n: Node) -> Skeleton3D:
		if n is Skeleton3D: return n
		for c in n.get_children():
			var r := _find_skel(c)
			if r != null: return r
		return null

	static func _find_like(sk: Skeleton3D, patterns: Array) -> int:
		for i in sk.get_bone_count():
			var nm := sk.get_bone_name(i).to_lower()
			for p in patterns:
				if nm == String(p).to_lower(): return i
		for i in sk.get_bone_count():
			var nm2 := sk.get_bone_name(i).to_lower()
			for p in patterns:
				if nm2.contains(String(p).to_lower()): return i
		return -1

static func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D: return n
	for c in n.get_children():
		var r := _find_skeleton(c)
		if r != null: return r
	return null

static func _find_bone_like(sk: Skeleton3D, patterns: Array) -> int:
	for i in sk.get_bone_count():
		var nm := sk.get_bone_name(i).to_lower()
		for p in patterns:
			if nm == String(p).to_lower(): return i
	for i in sk.get_bone_count():
		var nm2 := sk.get_bone_name(i).to_lower()
		for p in patterns:
			if nm2.contains(String(p).to_lower()): return i
	return -1

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
