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
	var p := "res://assets/models/dragon_%s.glb" % String(id)
	var scn := _load(p)
	if scn == null:
		scn = _load("res://assets/models/dragon.glb")
	if scn == null: return null
	return scn.instantiate()

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
	if not (ap is AnimationPlayer): return
	var anim_player: AnimationPlayer = ap
	var keywords: PackedStringArray
	match String(action):
		"idle":   keywords = PackedStringArray(["idle", "stand", "wait", "breathe", "static"])
		"walk":   keywords = PackedStringArray(["walk", "run", "march", "move"])
		"attack": keywords = PackedStringArray(["attack", "strike", "bite", "swing", "punch", "fire"])
		"hit":    keywords = PackedStringArray(["hit", "hurt", "damage", "impact", "recoil"])
		"die":    keywords = PackedStringArray(["die", "death", "fall", "dead", "ko"])
		"flee":   keywords = PackedStringArray(["run", "walk", "flee", "escape"])
		"mutate": keywords = PackedStringArray(["mutate", "transform", "shake", "summon"])
		_:        keywords = PackedStringArray([String(action)])
	var anim_name := find_animation_for(node, keywords)
	if anim_name == "": return
	var anim := anim_player.get_animation(anim_name)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	anim_player.play(anim_name)
