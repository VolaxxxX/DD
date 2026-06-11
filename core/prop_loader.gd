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

# Sub-biome count per biome (used to randomize variants at zone generation).
const SUB_COUNT := {
	&"forest": 3, &"city": 3, &"ruins": 3, &"crypt": 3,
	&"swamp": 2, &"highland": 2, &"coast": 2,
	&"corrupted": 2, &"anomaly": 2,
}

# Localized sub-biome names. Indexed by [biome][sub_id][lang].
const SUB_NAMES := {
	&"forest": [
		{"fr": "Bocage clair",      "en": "Sunlit Grove",      "id": "Hutan Cerah"},
		{"fr": "Forêt profonde",    "en": "Deep Forest",       "id": "Hutan Dalam"},
		{"fr": "Lisière brûlée",    "en": "Burnt Edge",        "id": "Pinggir Terbakar"},
	],
	&"city": [
		{"fr": "Quartier du marché","en": "Market District",   "id": "Distrik Pasar"},
		{"fr": "Tours du donjon",   "en": "Castle Towers",     "id": "Menara Kastil"},
		{"fr": "Bas-quartiers",     "en": "Slums",             "id": "Pemukiman Kumuh"},
	],
	&"ruins": [
		{"fr": "Temple effondré",   "en": "Fallen Temple",     "id": "Kuil Runtuh"},
		{"fr": "Champ de bataille", "en": "Old Battlefield",   "id": "Bekas Medan Perang"},
		{"fr": "Aile oubliée",      "en": "Forgotten Wing",    "id": "Sayap Terlupakan"},
	],
	&"crypt": [
		{"fr": "Cimetière à ciel ouvert", "en": "Open Graveyard", "id": "Pemakaman Terbuka"},
		{"fr": "Tombeau scellé",    "en": "Sealed Tomb",       "id": "Makam Tersegel"},
		{"fr": "Ossuaire",          "en": "Ossuary",           "id": "Tempat Tulang"},
	],
	&"swamp": [
		{"fr": "Bourbier ténébreux","en": "Murky Bog",         "id": "Rawa Pekat"},
		{"fr": "Hameau noyé",       "en": "Drowned Hamlet",    "id": "Dusun Tenggelam"},
	],
	&"highland": [
		{"fr": "Pic de pierre",     "en": "Stone Peak",        "id": "Puncak Batu"},
		{"fr": "Col du vent",       "en": "Windswept Pass",    "id": "Celah Berangin"},
	],
	&"coast": [
		{"fr": "Côte des épaves",   "en": "Wreckage Shore",    "id": "Pantai Bangkai"},
		{"fr": "Falaises sacrées",  "en": "Sacred Cliffs",     "id": "Tebing Suci"},
	],
	&"corrupted": [
		{"fr": "Terre flétrie",     "en": "Blighted Land",     "id": "Tanah Layu"},
		{"fr": "Terre qui saigne",  "en": "Bleeding Earth",    "id": "Tanah Berdarah"},
	],
	&"anomaly": [
		{"fr": "Faille du réel",    "en": "Reality Tear",      "id": "Robekan Realita"},
		{"fr": "Temps figé",        "en": "Frozen Time",       "id": "Waktu Beku"},
	],
}

static func sub_name(biome: StringName, sub_id: int) -> String:
	var arr: Array = SUB_NAMES.get(biome, [])
	if sub_id >= arr.size(): return ""
	var d: Dictionary = arr[sub_id]
	return String(d.get(Lang.code, d.get("fr", "")))

# Tint shift per sub-biome for the backdrop (HSV offsets to lightly recolor).
static func sub_tint(biome: StringName, sub_id: int) -> Color:
	# Returns a multiplier color (1,1,1) for neutral.
	var base := Color(1, 1, 1)
	match String(biome):
		"forest":
			match sub_id:
				0: return Color(1.05, 1.10, 0.95)   # warm sunlight
				1: return Color(0.85, 0.95, 0.90)   # darker deep
				2: return Color(1.10, 0.85, 0.70)   # burnt orange
		"city":
			match sub_id:
				0: return Color(1.00, 0.95, 0.85)   # market warm
				1: return Color(0.95, 0.95, 1.05)   # castle cooler
				2: return Color(0.80, 0.80, 0.85)   # slums grey
		"ruins":
			match sub_id:
				0: return Color(1.05, 1.00, 0.90)   # temple gold
				1: return Color(0.85, 0.85, 0.80)   # battlefield ashen
				2: return Color(0.80, 0.85, 0.95)   # forgotten cooler
		"crypt":
			match sub_id:
				0: return Color(0.95, 0.95, 0.85)   # graveyard
				1: return Color(0.75, 0.75, 0.90)   # tomb deeper
				2: return Color(1.00, 0.95, 0.80)   # ossuary bone
		"swamp":
			return Color(0.90, 0.95, 0.85) if sub_id == 0 else Color(0.80, 0.90, 1.00)
		"highland":
			return Color(0.95, 0.95, 1.00) if sub_id == 0 else Color(1.10, 1.05, 0.85)
		"coast":
			return Color(0.85, 0.95, 1.00) if sub_id == 0 else Color(1.05, 1.00, 0.85)
		"corrupted":
			return Color(0.85, 0.70, 0.90) if sub_id == 0 else Color(1.10, 0.55, 0.70)
		"anomaly":
			return Color(0.80, 0.85, 1.10) if sub_id == 0 else Color(0.70, 0.95, 1.05)
	return base

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
	[&"kayforest", &"Rock_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_D_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_E_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_1_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_B_Color1", 1.0, 0.0],
]

const SWAMP_PROPS := [
	[&"kayhalloween", &"tree_dead_large", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_medium", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_small", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_large_decorated", 1.0, 0.0],
	[&"kayforest", &"Bush_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Bush_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Mushroom_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_F_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_G_Color1", 1.0, 0.0],
	[&"kayhalloween", &"bone_A", 1.0, 0.0],
	[&"kayhalloween", &"lantern_standing", 1.0, 0.0],
]

const COAST_PROPS := [
	[&"kayforest", &"Rock_3_F_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_G_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_3_H_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_D_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_2_E_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_1_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_C_Color1", 1.0, 0.0],
	[&"kayhalloween", &"shrine", 1.0, 0.0],
	[&"kayhalloween", &"lantern_standing", 1.0, 0.0],
	[&"kayhalloween", &"post", 1.0, 0.0],
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

# ---------- Sub-biome variant pools ----------
# Each sub-biome has hero + ground arrays.  Selection is keyed by [biome][sub_id].

const FOREST_DEEP_HERO := [
	[&"kayforest", &"Tree_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_2_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_2_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_3_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_3_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_3_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_A_Color1", 1.0, 0.0],
]
const FOREST_BURNT_HERO := [
	[&"kayforest", &"Tree_Bare_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_1_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_1_C_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_Bare_2_C_Color1", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_large", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_medium", 1.0, 0.0],
]

const CITY_MARKET_HERO := [
	[&"town", &"market-stall", 1.0, 0.0],
	[&"town", &"cart", 1.0, 0.0],
	[&"town", &"fountain", 1.0, 0.0],
	[&"town", &"well", 1.0, 0.0],
	[&"town", &"stall", 1.0, 0.0],
]
const CITY_CASTLE_HERO := [
	[&"castle", &"tower-base", 1.0, 0.0],
	[&"castle", &"tower-square-mid-open", 1.0, 0.0],
	[&"castle", &"tower-hexagon-mid", 1.0, 0.0],
	[&"castle", &"flag-banner-long", 1.0, 0.0],
	[&"castle", &"wall-half", 1.0, 0.0],
]
const CITY_SLUMS_HERO := [
	[&"town", &"wall-broken", 1.0, 0.0],
	[&"town", &"cottage", 1.0, 0.0],
	[&"kayhalloween", &"fence_broken", 1.0, 0.0],
	[&"kayhalloween", &"fence_pillar_broken", 1.0, 0.0],
	[&"kayhalloween", &"post", 1.0, 0.0],
]

const RUINS_TEMPLE_HERO := [
	[&"kaydungeon", &"column", 1.0, 0.0],
	[&"kaydungeon", &"pillar", 1.0, 0.0],
	[&"kaydungeon", &"pillar_decorated", 1.0, 0.0],
	[&"arena", &"statue", 1.0, 0.0],
	[&"kaydungeon", &"wall_doorway", 1.0, 0.0],
]
const RUINS_BATTLE_HERO := [
	[&"kaydungeon", &"sword_shield_broken", 1.0, 0.0],
	[&"kaydungeon", &"rubble_large", 1.0, 0.0],
	[&"kaydungeon", &"rubble_half", 1.0, 0.0],
	[&"kaydungeon", &"wall_broken", 1.0, 0.0],
	[&"castle", &"siege-tower-demolished", 1.0, 0.0],
]
const RUINS_FORGOTTEN_HERO := [
	[&"kaydungeon", &"shelves", 1.0, 0.0],
	[&"kaydungeon", &"table_long_broken", 1.0, 0.0],
	[&"kaydungeon", &"chair", 1.0, 0.0],
	[&"kaydungeon", &"chest", 1.0, 0.0],
	[&"kaydungeon", &"wall_archedwindow_open", 1.0, 0.0],
]

const CRYPT_GRAVE_HERO := [
	[&"kayhalloween", &"gravestone", 1.0, 0.0],
	[&"kayhalloween", &"grave_A", 1.0, 0.0],
	[&"kayhalloween", &"grave_B", 1.0, 0.0],
	[&"kayhalloween", &"gravemarker_A", 1.0, 0.0],
	[&"kayhalloween", &"gravemarker_B", 1.0, 0.0],
	[&"kayhalloween", &"tree_dead_large", 1.0, 0.0],
]
const CRYPT_TOMB_HERO := [
	[&"kayhalloween", &"crypt", 1.0, 0.0],
	[&"kayhalloween", &"coffin", 1.0, 0.0],
	[&"kayhalloween", &"coffin_decorated", 1.0, 0.0],
	[&"kayhalloween", &"arch", 1.0, 0.0],
	[&"kayhalloween", &"arch_gate", 1.0, 0.0],
	[&"kayhalloween", &"candle_triple", 1.0, 0.0],
]
const CRYPT_OSSUARY_HERO := [
	[&"kayhalloween", &"bone_A", 1.0, 0.0],
	[&"kayhalloween", &"bone_B", 1.0, 0.0],
	[&"kayhalloween", &"bone_C", 1.0, 0.0],
	[&"kayhalloween", &"skull", 1.0, 0.0],
	[&"kayhalloween", &"skull_candle", 1.0, 0.0],
	[&"kayhalloween", &"ribcage", 1.0, 0.0],
]

const SWAMP_DROWNED_HERO := [
	[&"kayhalloween", &"tree_dead_large_decorated", 1.0, 0.0],
	[&"kayhalloween", &"post_skull", 1.0, 0.0],
	[&"kayhalloween", &"lantern_hanging", 1.0, 0.0],
	[&"kayhalloween", &"fence_broken", 1.0, 0.0],
	[&"town", &"cottage", 1.0, 0.0],
	[&"kayhalloween", &"bone_C", 1.0, 0.0],
]
const HIGHLAND_PASS_HERO := [
	[&"kayforest", &"Rock_1_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Rock_1_B_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_A_Color1", 1.0, 0.0],
	[&"kayforest", &"Tree_4_B_Color1", 1.0, 0.0],
	[&"kayhalloween", &"tree_pine_yellow_large", 1.0, 0.0],
	[&"kayhalloween", &"tree_pine_yellow_medium", 1.0, 0.0],
]
const COAST_SACRED_HERO := [
	[&"kayhalloween", &"shrine", 1.0, 0.0],
	[&"kayhalloween", &"shrine_candles", 1.0, 0.0],
	[&"kayhalloween", &"lantern_standing", 1.0, 0.0],
	[&"kayhalloween", &"post_lantern", 1.0, 0.0],
	[&"kayforest", &"Rock_2_A_Color1", 1.0, 0.0],
]
const CORRUPTED_BLEED_HERO := [
	[&"kayhalloween", &"tree_dead_large_decorated", 1.0, 0.0],
	[&"kayhalloween", &"tree_pine_orange_large", 1.0, 0.0],
	[&"kayhalloween", &"tree_pine_orange_medium", 1.0, 0.0],
	[&"kayhalloween", &"pumpkin_orange_jackolantern", 1.0, 0.0],
	[&"kayhalloween", &"pumpkin_yellow_jackolantern", 1.0, 0.0],
]
const ANOMALY_FROZEN_HERO := [
	[&"kaydungeon", &"floor_tile_extralarge_grates_open", 1.0, 0.0],
	[&"kaydungeon", &"floor_tile_big_grate_open", 1.0, 0.0],
	[&"arena", &"trophy", 1.0, 0.0],
	[&"kaydungeon", &"sword_shield_gold", 1.0, 0.0],
	[&"kaydungeon", &"chest_gold", 1.0, 0.0],
]

static func pool_for(biome: StringName, role: StringName, sub_id: int = 0) -> Array:
	# Sub-biome dispatch: distinct "hero" pools per variant. The ground pool
	# stays the same across variants of a biome to keep grass/rocks coherent.
	if role == &"hero":
		match String(biome):
			"forest":
				match sub_id:
					1: return FOREST_DEEP_HERO
					2: return FOREST_BURNT_HERO
					_: return FOREST_TREES
			"city":
				match sub_id:
					1: return CITY_CASTLE_HERO
					2: return CITY_SLUMS_HERO
					_: return CITY_MARKET_HERO
			"ruins":
				match sub_id:
					1: return RUINS_BATTLE_HERO
					2: return RUINS_FORGOTTEN_HERO
					_: return RUINS_TEMPLE_HERO
			"crypt":
				match sub_id:
					1: return CRYPT_TOMB_HERO
					2: return CRYPT_OSSUARY_HERO
					_: return CRYPT_GRAVE_HERO
			"swamp":     return SWAMP_DROWNED_HERO if sub_id == 1 else SWAMP_PROPS
			"highland":  return HIGHLAND_PASS_HERO if sub_id == 1 else HIGHLAND_PROPS
			"coast":     return COAST_SACRED_HERO  if sub_id == 1 else COAST_PROPS
			"corrupted": return CORRUPTED_BLEED_HERO if sub_id == 1 else CORRUPTED_PROPS
			"anomaly":   return ANOMALY_FROZEN_HERO  if sub_id == 1 else ANOMALY_PROPS
	# Ground pool — biome-level.
	match String(biome):
		"forest":     return FOREST_GROUND
		_:            return []
