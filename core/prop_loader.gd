class_name PropLoader extends RefCounted
# Loads Kenney CC0 prop GLBs (Nature Kit, Fantasy Town, Mini Dungeon, Mini Arena)
# from assets/models/biome_<pack>/<name>.glb. Returns null if missing.

static var _cache: Dictionary = {}

static func instance(pack: StringName, name: StringName) -> Node3D:
	var path := "res://assets/models/biome_%s/%s.glb" % [String(pack), String(name)]
	var scn: PackedScene = _cache.get(path)
	if scn == null:
		if not ResourceLoader.exists(path): return null
		var res := load(path)
		if not (res is PackedScene): return null
		scn = res
		_cache[path] = scn
	return scn.instantiate()

# Per-biome prop inventory. Each entry: (pack, name, base_scale, y_offset).
const FOREST_TREES := [
	[&"kayforest", &"Tree_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_1_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_1_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_1_D_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_2_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_2_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_3_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_A_Color1", 1.0, 0.0],
]
const FOREST_GROUND := [
	[&"kayforest", &"Bush_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Bush_1_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Bush_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Bush_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Bush_4_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Flower_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Flower_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Flower_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Grass_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Mushroom_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Mushroom_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_4_A_Color1", 1.0, 0.0],
]

const HIGHLAND_PROPS := [
	[&"nature", &"cliff_large_rock", 1.0, 0.0],
	[&"nature", &"cliff_corner_rock", 1.0, 0.0],
	[&"nature", &"stone_tallA", 1.0, 0.0],
	[&"nature", &"stone_tallE", 1.0, 0.0],
	[&"nature", &"stone_largeF", 1.0, 0.0],
	[&"nature", &"tree_pineTallA", 1.0, 0.0],
	[&"nature", &"tree_pineTallC_dark", 1.0, 0.0],
]

const SWAMP_PROPS := [
	[&"nature", &"tree_blocks_fall", 1.0, 0.0],
	[&"nature", &"tree_default_fall", 1.0, 0.0],
	[&"nature", &"tree_oak_fall", 1.0, 0.0],
	[&"nature", &"plant_bush", 1.0, 0.0],
	[&"nature", &"mushroom_redTall", 1.0, 0.0],
	[&"nature", &"mushroom_brownTall", 1.0, 0.0],
	[&"nature", &"stone_smallB", 1.0, 0.0],
]

const COAST_PROPS := [
	[&"nature", &"cliff_blockSlopeHalf_rock", 1.0, 0.0],
	[&"nature", &"stone_largeE", 1.0, 0.0],
	[&"nature", &"stone_tallC", 1.0, 0.0],
	[&"nature", &"plant_bush", 1.0, 0.0],
	[&"nature", &"crop_haystack", 1.0, 0.0],
]

const CITY_PROPS := [
	[&"town", &"cottage", 1.0, 0.0],
	[&"town", &"watermill", 1.0, 0.0],
	[&"town", &"windmill", 1.0, 0.0],
	[&"town", &"fountain", 1.0, 0.0],
	[&"town", &"well", 1.0, 0.0],
	[&"town", &"stall", 1.0, 0.0],
	[&"town", &"cart", 1.0, 0.0],
	[&"town", &"banner-pole", 1.0, 0.0],
	[&"town", &"market-stall", 1.0, 0.0],
]

const RUINS_PROPS := [
	[&"arena", &"column", 1.0, 0.0],
	[&"arena", &"column-damaged", 1.0, 0.0],
	[&"arena", &"statue", 1.0, 0.0],
	[&"town", &"wall-broken", 1.0, 0.0],
	[&"town", &"wall-corner-detail", 1.0, 0.0],
	[&"nature", &"stone_largeF", 1.0, 0.0],
]

const CRYPT_PROPS := [
	[&"kayhalloween", &"gravestone", 1.0, 0.0],
	[&"kayhalloween", &"gravestone_pumpkin", 1.0, 0.0],
	[&"kayhalloween", &"grave_A", 1.0, 0.0],
	[&"kayhalloween", &"grave_B", 1.0, 0.0],
	[&"kayhalloween", &"grave_A_destroyed", 1.0, 0.0],
	[&"kayhalloween", &"gravemarker_A", 1.0, 0.0],
	[&"kayhalloween", &"gravemarker_B", 1.0, 0.0],
	[&"kayhalloween", &"crypt", 1.0, 0.0],
	[&"kayhalloween", &"coffin", 1.0, 0.0],
	[&"kayhalloween", &"coffin_decorated", 1.0, 0.0],
	[&"kayhalloween", &"candle_triple", 1.0, 0.0],
	[&"kayhalloween", &"arch", 1.0, 0.0],
	[&"kayhalloween", &"arch_gate", 1.0, 0.0],
	[&"kayhalloween", &"fence_pillar", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_large", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_large_decorated", 1.0, 0.0],
	[&"kayhalloween", &"bone_A", 1.0, 0.0],
	[&"kayhalloween", &"bone_B", 1.0, 0.0],
	[&"kayhalloween", &"bone_C", 1.0, 0.0],
]

const CITY_BIG_PROPS := [
	[&"town", &"cottage", 1.0, 0.0],
	[&"town", &"watermill", 1.0, 0.0],
	[&"town", &"windmill", 1.0, 0.0],
	[&"town", &"fountain", 1.0, 0.0],
	[&"town", &"market-stall", 1.0, 0.0],
	[&"castle", &"tower-base", 1.0, 0.0],
	[&"castle", &"flag-banner-long", 1.0, 0.0],
	[&"castle", &"tower-square-mid-open", 1.0, 0.0],
]

const RUINS_BIG_PROPS := [
	[&"kaydungeon", &"wall_doorway", 1.0, 0.0],
	[&"kaydungeon", &"wall_corner", 1.0, 0.0],
	[&"kaydungeon", &"wall_corner_scaffold", 1.0, 0.0],
	[&"kaydungeon", &"column", 1.0, 0.0],
	[&"kaydungeon", &"pillar", 1.0, 0.0],
	[&"kaydungeon", &"pillar_decorated", 1.0, 0.0],
	[&"kaydungeon", &"barrier_column", 1.0, 0.0],
	[&"castle", &"siege-tower-demolished", 1.0, 0.0],
	[&"castle", &"tower-base", 1.0, 0.0],
	[&"arena", &"statue", 1.0, 0.0],
]

const CORRUPTED_PROPS := [
	[&"nature", &"tree_blocks_fall", 1.0, 0.0],
	[&"nature", &"tree_default_fall", 1.0, 0.0],
	[&"nature", &"tree_oak_fall", 1.0, 0.0],
	[&"nature", &"stone_smallC", 1.0, 0.0],
	[&"nature", &"stone_largeD", 1.0, 0.0],
]

const ANOMALY_PROPS := [
	[&"nature", &"stone_smallD", 1.0, 0.0],
	[&"nature", &"stone_largeF", 1.0, 0.0],
	[&"dungeon", &"stones", 1.0, 0.0],
	[&"arena", &"trophy", 1.0, 0.0],
]

static func pool_for(biome: StringName, role: StringName) -> Array:
	match String(biome):
		"forest":
			if role == &"hero": return FOREST_TREES
			return FOREST_GROUND
		"highland":   return HIGHLAND_PROPS
		"swamp":      return SWAMP_PROPS
		"coast":      return COAST_PROPS
		"city":       return CITY_BIG_PROPS
		"ruins":      return RUINS_BIG_PROPS
		"crypt":      return CRYPT_PROPS
		"corrupted":  return CORRUPTED_PROPS
		"anomaly":    return ANOMALY_PROPS
		_:            return FOREST_TREES
