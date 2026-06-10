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

# Play the model's first animation in loop, if any.
static func play_first_animation(node: Node3D) -> void:
	var ap := node.find_child("AnimationPlayer", true, false)
	if ap is AnimationPlayer:
		var names := (ap as AnimationPlayer).get_animation_list()
		if names.size() > 0:
			(ap as AnimationPlayer).play(names[0])
			(ap as AnimationPlayer).get_animation(names[0]).loop_mode = Animation.LOOP_LINEAR
