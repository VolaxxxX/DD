class_name NatureLib extends RefCounted
# Curated Kenney Nature Kit (CC0) props mapped to biomes for a coherent,
# low-poly art direction. Three roles per biome:
#   hero    — large landmark silhouettes (trees, columns, menhirs)
#   scatter — mid props (rocks, stumps, bushes, mushrooms)
#   ground  — tiny detail (grass, flowers)
# All models share one Kenney atlas, so they read as one consistent world.

const _DIR := "res://assets/models/nature/%s.glb"
static var _cache: Dictionary = {}

# biome -> { hero:[], scatter:[], ground:[], tint:Color (1,1,1 = none) }
const POOLS := {
	&"forest": {
		"hero": ["tree_default", "tree_detailed", "tree_oak", "tree_fat", "tree_default_dark"],
		"scatter": ["stump_round", "stump_old", "rock_smallA", "rock_smallB", "plant_bush", "plant_bushLarge", "mushroom_red", "mushroom_tanGroup", "log"],
		"ground": ["grass", "grass_large", "grass_leafs", "flower_redA", "flower_yellowA", "plant_bushSmall"],
		"tint": Color(1, 1, 1),
	},
	&"city": {
		"hero": ["statue_column", "statue_columnDamaged", "rock_largeA", "tree_default_dark"],
		"scatter": ["rock_smallB", "rock_smallC", "plant_bush", "statue_block", "log"],
		"ground": ["grass_leafs", "plant_bushSmall"],
		"tint": Color(0.85, 0.85, 0.88),
	},
	&"ruins": {
		"hero": ["statue_column", "statue_columnDamaged", "statue_obelisk", "statue_ring", "rock_largeC"],
		"scatter": ["rock_largeA", "rock_smallA", "statue_block", "statue_head", "stump_square"],
		"ground": ["grass", "plant_bushSmall", "flower_yellowA"],
		"tint": Color(0.95, 0.9, 0.78),
	},
	&"corrupted": {
		"hero": ["tree_default_dark", "tree_cone_dark", "tree_blocks", "statue_obelisk", "rock_tallC"],
		"scatter": ["rock_tallA", "rock_tallE", "stump_oldTall", "mushroom_redTall", "mushroom_red"],
		"ground": ["flower_purpleA", "flower_purpleB", "plant_bushSmall"],
		"tint": Color(0.62, 0.3, 0.6),
	},
	&"anomaly": {
		"hero": ["statue_obelisk", "statue_ring", "rock_tallC", "rock_tallG", "tree_blocks"],
		"scatter": ["rock_tallA", "rock_smallA", "rock_largeD", "statue_block"],
		"ground": ["flower_purpleA", "grass_leafs"],
		"tint": Color(0.5, 0.62, 1.0),
	},
	&"swamp": {
		"hero": ["tree_default_dark", "tree_oak_dark", "stump_oldTall", "stump_old", "tree_thin"],
		"scatter": ["stump_round", "rock_smallA", "plant_bush", "plant_bushLarge", "mushroom_tan", "mushroom_tanGroup", "log"],
		"ground": ["grass_leafs", "plant_flatTall", "plant_bushSmall"],
		"tint": Color(0.7, 0.85, 0.7),
	},
	&"highland": {
		"hero": ["rock_largeA", "rock_largeC", "rock_largeD", "rock_tallA", "rock_tallC", "statue_obelisk"],
		"scatter": ["rock_smallA", "rock_smallB", "rock_smallC", "stump_round", "plant_bush"],
		"ground": ["grass", "grass_large", "flower_yellowA"],
		"tint": Color(0.92, 0.95, 0.95),
	},
	&"crypt": {
		"hero": ["statue_column", "statue_columnDamaged", "statue_head", "statue_block", "rock_largeB"],
		"scatter": ["rock_smallA", "rock_smallB", "statue_block", "stump_square"],
		"ground": ["plant_bushSmall"],
		"tint": Color(0.6, 0.6, 0.72),
	},
	&"coast": {
		"hero": ["tree_palmTall", "tree_palmShort", "rock_largeB", "rock_largeC", "rock_tallE"],
		"scatter": ["rock_smallA", "rock_smallB", "rock_smallC", "log", "plant_bush"],
		"ground": ["grass", "flower_yellowA"],
		"tint": Color(1.0, 0.96, 0.85),
	},
}

static func _load(name: String) -> PackedScene:
	if _cache.has(name): return _cache[name]
	var p := _DIR % name
	if not ResourceLoader.exists(p):
		_cache[name] = null
		return null
	var scn := load(p)
	_cache[name] = scn
	return scn

static func pool(biome: StringName) -> Dictionary:
	return POOLS.get(biome, POOLS[&"forest"])

# Instantiate a prop, applying the biome tint as a per-instance modulate on its
# meshes (keeps the shared atlas but pushes each biome's colour identity).
static func instance(name: String, tint: Color = Color(1, 1, 1)) -> Node3D:
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
			# Multiply over the atlas via a fresh material instance.
			var base := mi.get_active_material(0)
			var m: StandardMaterial3D
			if base is StandardMaterial3D:
				m = (base as StandardMaterial3D).duplicate()
			else:
				m = StandardMaterial3D.new()
			m.albedo_color = m.albedo_color * tint
			mi.material_override = m
		_tint(c, tint)

# Pick a random model name from a role pool for a biome.
static func pick(biome: StringName, role: String, rng: DRNG) -> String:
	var arr: Array = pool(biome).get(role, [])
	if arr.is_empty(): return ""
	return arr[rng.range_i(0, arr.size())]

static func biome_tint(biome: StringName) -> Color:
	return pool(biome).get("tint", Color(1, 1, 1))
