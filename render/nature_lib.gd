class_name NatureLib extends RefCounted
# Curated Kenney Nature Kit (CC0) props mapped to biomes for a coherent,
# low-poly art direction. Three roles per biome:
#   hero    — large landmark silhouettes (trees, columns, menhirs)
#   scatter — mid props (rocks, stumps, bushes, mushrooms)
#   ground  — tiny detail (grass, flowers)
# All models share one Kenney atlas, so they read as one consistent world.

# Props live in two folders: Kenney Nature Kit (nature/) and the curated
# Graveyard/Survival/Town decor (decor/). _load searches both.
const _DIRS := ["res://assets/models/nature/%s.glb", "res://assets/models/decor/%s.glb"]
static var _cache: Dictionary = {}

# biome -> { hero:[], scatter:[], ground:[], tint:Color (1,1,1 = none) }
const POOLS := {
	&"forest": {
		"hero": ["tree_default", "tree_detailed", "tree_oak", "tree_fat", "tree_default_dark", "gy_pine", "gy_pine_crooked"],
		"scatter": ["stump_round", "stump_old", "rock_smallA", "rock_smallB", "plant_bush", "plant_bushLarge", "mushroom_red", "mushroom_tanGroup", "log", "sv_rock_a", "sv_rock_b", "gy_trunk", "sv_resource_wood", "sv_campfire_pit"],
		"ground": ["grass", "grass_large", "grass_leafs", "flower_redA", "flower_yellowA", "plant_bushSmall"],
		"tint": Color(1, 1, 1),
	},
	&"city": {
		"hero": ["ct_tower_square_base", "ct_tower_square_mid", "ct_gate", "ct_wall", "tn_fountain_round", "tn_cart_high"],
		"scatter": ["ct_wall_half", "ct_flag", "ct_stairs_stone", "tn_cart", "tn_barrel", "tn_planks", "tn_chimney", "tn_banner_red", "gy_lightpost_single"],
		"ground": ["grass_leafs", "plant_bushSmall"],
		"tint": Color(0.85, 0.85, 0.88),
	},
	&"ruins": {
		"hero": ["statue_column", "statue_columnDamaged", "ct_wall_corner", "ct_siege_ram_demolished", "gy_altar_stone", "gy_pillar_large", "gy_stone_wall_damaged"],
		"scatter": ["rock_largeA", "gy_debris", "gy_rocks", "ct_wall_half", "ct_siege_catapult_demolished", "ct_rocks_large", "gy_urn_square", "statue_head"],
		"ground": ["grass", "plant_bushSmall", "flower_yellowA"],
		"tint": Color(0.95, 0.9, 0.78),
	},
	&"corrupted": {
		"hero": ["tree_default_dark", "gy_pine_crooked", "gy_pine_fall_crooked", "gy_cross", "rock_tallC", "gy_gravestone_broken"],
		"scatter": ["rock_tallA", "stump_oldTall", "mushroom_redTall", "gy_debris", "gy_coffin_old", "gy_urn_round"],
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
		"hero": ["tree_default_dark", "tree_oak_dark", "stump_oldTall", "gy_pine_fall", "tree_thin", "gy_trunk_long"],
		"scatter": ["stump_round", "rock_smallA", "plant_bush", "plant_bushLarge", "mushroom_tan", "log", "sv_barrel", "sv_box", "gy_debris"],
		"ground": ["grass_leafs", "plant_flatTall", "plant_bushSmall"],
		"tint": Color(0.7, 0.85, 0.7),
	},
	&"highland": {
		"hero": ["rock_largeA", "rock_largeC", "rock_largeD", "rock_tallA", "rock_tallC", "statue_obelisk", "gy_rocks_tall"],
		"scatter": ["rock_smallA", "rock_smallB", "rock_smallC", "stump_round", "plant_bush", "sv_rock_a", "sv_rock_b", "sv_signpost"],
		"ground": ["grass", "grass_large", "flower_yellowA"],
		"tint": Color(0.92, 0.95, 0.95),
	},
	&"crypt": {
		"hero": ["gy_crypt", "gy_crypt_large", "gy_crypt_small", "md_column", "gy_pillar_obelisk", "gy_cross_column"],
		"scatter": ["gy_gravestone_bevel", "gy_gravestone_broken", "gy_coffin", "gy_urn_round", "gy_candle_multiple", "md_chest", "md_banner", "md_stones"],
		"ground": ["plant_bushSmall", "gy_candle", "md_coin"],
		"tint": Color(0.6, 0.6, 0.72),
	},
	&"coast": {
		"hero": ["tree_palmTall", "tree_palmShort", "rock_largeB", "rock_largeC", "rock_tallE", "sv_signpost"],
		"scatter": ["sv_rock_sand_a", "sv_rock_sand_b", "sv_rock_sand_c", "sv_rock_flat", "log", "sv_fish_large", "sv_barrel", "sv_bucket"],
		"ground": ["grass", "flower_yellowA"],
		"tint": Color(1.0, 0.96, 0.85),
	},
}

static func _load(name: String) -> PackedScene:
	if _cache.has(name): return _cache[name]
	for fmt in _DIRS:
		var p: String = fmt % name
		if ResourceLoader.exists(p):
			var scn := load(p)
			_cache[name] = scn
			return scn
	_cache[name] = null
	return null

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
			m.metallic = minf(m.metallic, 0.1)   # no mirror -> never black on Mobile
			mi.material_override = m
		_tint(c, tint)

# Pick a random model name from a role pool for a biome.
static func pick(biome: StringName, role: String, rng: DRNG) -> String:
	var arr: Array = pool(biome).get(role, [])
	if arr.is_empty(): return ""
	return arr[rng.range_i(0, arr.size())]

static func biome_tint(biome: StringName) -> Color:
	return pool(biome).get("tint", Color(1, 1, 1))
