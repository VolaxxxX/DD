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
	"beast_panda", "beast_polar", "beast_cow", "beast_dog", "beast_cat",
	"beast_elephant", "beast_koala", "beast_bunny", "beast_pig", "beast_giraffe"]
const CHARS := ["char_a", "char_b", "char_c", "char_d", "char_e", "char_f",
	"char_g", "char_h", "char_i", "char_j", "char_k", "char_l",
	"humanoid_orc", "humanoid_human", "humanoid_orc"]   # orc weighted for menace
# Small animated flyers for the FEY family — tinted luminous + hovering they
# read as glowing sprites, far better than the procedural prism fairy.
const FEY := ["fey_parrot", "beast_bee", "fey_chick"]
# Proper animated undead from the Kenney Graveyard kit (idle/walk).
const UNDEAD := ["undead_skeleton", "undead_zombie", "undead_ghost", "undead_vampire"]

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
	["hound", "beast_dog"], ["dog", "beast_dog"], ["mastiff", "beast_dog"], ["cur", "beast_dog"],
	["mammoth", "beast_elephant"], ["elephant", "beast_elephant"], ["tusker", "beast_elephant"], ["behemoth", "beast_elephant"],
	["hare", "beast_bunny"], ["rabbit", "beast_bunny"], ["lapin", "beast_bunny"],
	["leech", "beast_caterpillar"], ["sangsue", "beast_caterpillar"], ["slug", "beast_caterpillar"],
	["stalker", "beast_tiger"], ["rodeur", "beast_tiger"], ["prowler", "beast_tiger"], ["lurker", "beast_tiger"],
	["crow", "beast_bee"], ["raven", "beast_bee"], ["swarm", "beast_bee"], ["nuee", "beast_bee"], ["corbeau", "beast_bee"], ["flock", "beast_bee"],
	["toad", "beast_hog"], ["frog", "beast_hog"], ["crapaud", "beast_hog"],
	["lizard", "beast_crab"], ["reptile", "beast_crab"], ["scuttle", "beast_crab"],
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
		2:  # UNDEAD — real animated skeleton/zombie/ghost/vampire
			pool = UNDEAD
			# ghost reads better faintly translucent-blue; others stay as-is.
			var hh: int = abs(int(String(id).hash()))
			if UNDEAD[hh % UNDEAD.size()] == "undead_ghost":
				tint = Color(0.7, 0.85, 1.0)
		6:  # FEY — small luminous animated flyer
			pool = FEY
			tint = Color(0.8, 0.9, 1.0)
			emissive = true
		5:  # ABERRATION — a Quaternius slime mesh dressed as an eldritch horror
			# (deep violet, faint inner glow) instead of a cartoon green blob.
			var slm := _obj_mesh("res://assets/models/qmonsters/Slime.obj")
			if slm != null and slm is MeshInstance3D:
				var m := StandardMaterial3D.new()
				m.albedo_color = Color(0.30, 0.11, 0.42)
				m.roughness = 0.45
				m.metallic = 0.0
				m.emission_enabled = true
				m.emission = Color(0.55, 0.18, 0.78)
				m.emission_energy_multiplier = 0.7
				m.rim_enabled = true
				m.rim = 0.6
				m.rim_tint = 0.5
				(slm as MeshInstance3D).material_override = m
				return slm
			pool = ["beast_crab", "beast_caterpillar", "beast_bee"]
			tint = Color(0.7, 0.35, 0.85)
			emissive = true
		7:  # DRACONIC — a real Quaternius dragon mesh (static, breathes via idle).
			var drg := _obj_mesh("res://assets/models/qmonsters/Dragon.obj")
			if drg != null: return drg
			pool = ["beast_lion", "beast_tiger", "beast_hog"]
			tint = Color(0.85, 0.45, 0.4)
		3:  # CONSTRUCT — character tinted cold stone-grey (a golem)
			pool = CHARS
			tint = Color(0.6, 0.62, 0.66)
		4:  # ELEMENTAL — character as a blazing energy-being (strong glow).
			pool = CHARS
			tint = _elemental_tint(id)
			emissive = true
		_:
			return null
	if pool.is_empty(): return null
	var h: int = abs(int(String(id).hash()))
	return _make(pool[h % pool.size()], tint, emissive)

# Elemental colour by name keyword: fire / frost / storm / earth, else amber.
static func _elemental_tint(id: StringName) -> Color:
	var s := String(id).to_lower()
	if "fire" in s or "ember" in s or "flame" in s or "cinder" in s or "feu" in s or "ash" in s: return Color(1.0, 0.5, 0.18)
	if "frost" in s or "ice" in s or "glace" in s or "winter" in s or "snow" in s: return Color(0.55, 0.85, 1.0)
	if "storm" in s or "thunder" in s or "spark" in s or "orage" in s or "shock" in s: return Color(0.85, 0.85, 1.0)
	if "stone" in s or "earth" in s or "rock" in s or "terre" in s or "mud" in s: return Color(0.7, 0.55, 0.35)
	return Color(1.0, 0.7, 0.3)

static func _beast_for_name(id: StringName) -> String:
	var s := String(id).to_lower()
	for pair in BEAST_KEYWORDS:
		if s.contains(String(pair[0])): return String(pair[1])
	return ""

# Wraps an imported OBJ Mesh (static) in a MeshInstance3D node.
static func _obj_mesh(path: String) -> Node3D:
	if not ResourceLoader.exists(path): return null
	var res := load(path)
	if res is Mesh:
		var mi := MeshInstance3D.new()
		mi.mesh = res
		return mi
	if res is PackedScene:
		return (res as PackedScene).instantiate()
	return null

static func _make(name: String, tint: Color, emissive: bool) -> Node3D:
	var scn := _load(name)
	if scn == null: return null
	var n := scn.instantiate()
	if tint != Color(1, 1, 1) or emissive:
		_tint(n, tint, emissive)
	return n

static func _tint(node: Node, tint: Color, emissive: bool = false) -> void:
	# Tint the node itself when it IS the mesh (OBJ-wrapped meshes are a bare
	# MeshInstance3D with no children — they were being skipped before).
	if node is MeshInstance3D:
		_tint_mesh(node as MeshInstance3D, tint, emissive)
	for c in node.get_children():
		_tint(c, tint, emissive)

static func _tint_mesh(mi: MeshInstance3D, tint: Color, emissive: bool) -> void:
	var base := mi.get_active_material(0)
	var m: StandardMaterial3D = (base as StandardMaterial3D).duplicate() if base is StandardMaterial3D else StandardMaterial3D.new()
	m.albedo_color = m.albedo_color * tint
	m.metallic = minf(m.metallic, 0.1)
	if emissive:
		m.emission_enabled = true
		m.emission = tint
		m.emission_energy_multiplier = 1.2
	mi.material_override = m
