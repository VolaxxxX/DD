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
# creature id so the same creature always looks the same. null if none fits.
static func instance_for(family: int, id: StringName) -> Node3D:
	var pool: Array = []
	var tint := Color(1, 1, 1)
	match family:
		1:  # BEAST
			pool = BEASTS
		0:  # HUMANOID
			pool = CHARS
		2:  # UNDEAD — reuse characters, tinted corpse-pale
			pool = CHARS
			tint = Color(0.62, 0.72, 0.6)
		_:
			return null
	if pool.is_empty(): return null
	var h: int = abs(int(String(id).hash()))
	var name: String = pool[h % pool.size()]
	var scn := _load(name)
	if scn == null: return null
	var n := scn.instantiate()
	if tint != Color(1, 1, 1):
		_tint(n, tint)
	return n

static func _tint(node: Node, tint: Color) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var base := mi.get_active_material(0)
			var m: StandardMaterial3D = (base as StandardMaterial3D).duplicate() if base is StandardMaterial3D else StandardMaterial3D.new()
			m.albedo_color = m.albedo_color * tint
			mi.material_override = m
		_tint(c, tint)
