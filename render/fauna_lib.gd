class_name FaunaLib extends RefCounted
# Animated CC0 creature models (Kenney Cube Pets + Blocky Characters) used for
# the most common creature families so they MOVE (idle/walk anims) instead of
# standing as static procedural primitives. One look per pack = consistent.
#   BEAST            -> animated animals
#   HUMANOID / UNDEAD-> animated blocky characters (undead = tinted pale-green)

const _DIR := "res://assets/models/fauna/%s.glb"
static var _cache: Dictionary = {}

const BEASTS := ["beast_fox", "beast_lion", "beast_tiger", "beast_hog", "beast_deer",
	"beast_crab", "beast_bee", "beast_caterpillar", "beast_monkey", "beast_beaver",
	"beast_panda", "beast_polar", "beast_cow"]
const CHARS := ["char_a", "char_b", "char_c", "char_d", "char_e", "char_f",
	"char_g", "char_h", "char_i", "char_j", "char_k", "char_l"]
# Small animated flyers for the FEY family — tinted luminous + hovering they
# read as glowing sprites, far better than the procedural prism fairy.
const FEY := ["fey_parrot", "beast_bee", "fey_chick"]

# Keyword -> preferred beast model, so a creature's NAME matches its model
# (a "dire wolf" becomes a fox/canine, not a random panda).
const BEAST_KEYWORDS := [
	["wolf", "beast_fox"], ["loup", "beast_fox"], ["serigala", "beast_fox"], ["fox", "beast_fox"], ["hound", "beast_fox"], ["dog", "beast_fox"], ["jackal", "beast_fox"],
	["bear", "beast_polar"], ["ours", "beast_polar"], ["beruang", "beast_polar"],
	["lion", "beast_lion"], ["cat", "beast_lion"], ["panther", "beast_lion"], ["lynx", "beast_lion"],
	["tiger", "beast_tiger"], ["tigre", "beast_tiger"], ["sabre", "beast_tiger"],
	["boar", "beast_hog"], ["hog", "beast_hog"], ["pig", "beast_hog"], ["sanglier", "beast_hog"], ["swine", "beast_hog"], ["tusk", "beast_hog"],
	["stag", "beast_deer"], ["deer", "beast_deer"], ["elk", "beast_deer"], ["cerf", "beast_deer"], ["antler", "beast_deer"], ["doe", "beast_deer"],
	["crab", "beast_crab"], ["crustace", "beast_crab"], ["claw", "beast_crab"], ["shell", "beast_crab"],
	["bee", "beast_bee"], ["wasp", "beast_bee"], ["hornet", "beast_bee"], ["insect", "beast_bee"], ["abeille", "beast_bee"],
	["worm", "beast_caterpillar"], ["grub", "beast_caterpillar"], ["larva", "beast_caterpillar"], ["serpent", "beast_caterpillar"], ["snake", "beast_caterpillar"], ["ver", "beast_caterpillar"],
	["ape", "beast_monkey"], ["monkey", "beast_monkey"], ["simian", "beast_monkey"], ["singe", "beast_monkey"],
	["ox", "beast_cow"], ["bull", "beast_cow"], ["cow", "beast_cow"], ["bison", "beast_cow"], ["beef", "beast_cow"], ["buffle", "beast_cow"],
	["beaver", "beast_beaver"], ["rodent", "beast_beaver"], ["rat", "beast_beaver"],
]

static func _load(name: String) -> PackedScene:
	if _cache.has(name): return _cache[name]
	var p := _DIR % name
	if not ResourceLoader.exists(p):
		_cache[name] = null
		return null
	var scn := load(p)
	_cache[name] = scn
	return scn

# Returns an animated model for the family, deterministically chosen from the
# creature id so the same creature always looks the same. For beasts the model
# is matched to the creature's NAME (wolf->fox, bear->polar...) so it stays
# coherent with the text. null if the family has no fauna mapping.
static func instance_for(family: int, id: StringName) -> Node3D:
	var pool: Array = []
	var tint := Color(1, 1, 1)
	var emissive := false
	match family:
		1:  # BEAST — try a semantic keyword match first.
			var key := _beast_for_name(id)
			if key != "":
				return _make(key, Color(1, 1, 1), false)
			pool = BEASTS
		0:  # HUMANOID
			pool = CHARS
		2:  # UNDEAD — reuse characters, tinted corpse-pale
			pool = CHARS
			tint = Color(0.62, 0.72, 0.6)
		6:  # FEY — small luminous animated flyer
			pool = FEY
			tint = Color(0.8, 0.9, 1.0)
			emissive = true
		_:
			return null
	if pool.is_empty(): return null
	var h: int = abs(int(String(id).hash()))
	return _make(pool[h % pool.size()], tint, emissive)

static func _beast_for_name(id: StringName) -> String:
	var s := String(id).to_lower()
	for pair in BEAST_KEYWORDS:
		if s.contains(String(pair[0])): return String(pair[1])
	return ""

static func _make(name: String, tint: Color, emissive: bool) -> Node3D:
	var scn := _load(name)
	if scn == null: return null
	var n := scn.instantiate()
	if tint != Color(1, 1, 1) or emissive:
		_tint(n, tint, emissive)
	return n

static func _tint(node: Node, tint: Color, emissive: bool = false) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var base := mi.get_active_material(0)
			var m: StandardMaterial3D = (base as StandardMaterial3D).duplicate() if base is StandardMaterial3D else StandardMaterial3D.new()
			m.albedo_color = m.albedo_color * tint
			m.metallic = minf(m.metallic, 0.1)
			if emissive:
				m.emission_enabled = true
				m.emission = tint
				m.emission_energy_multiplier = 1.2
			mi.material_override = m
		_tint(c, tint, emissive)
