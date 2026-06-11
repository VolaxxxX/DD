class_name RelicRegistry extends RefCounted
# Persistent run relics — drop from elite/apex/mythic kills and titan survives.
# Each relic gives a passive modifier to a specific roll context.

static func all() -> Array:
	return [
		{"id": &"wolf_fang", "icon": "🦷",
		 "name": {"fr": "Croc de loup", "en": "Wolf Fang", "id": "Taring Serigala"},
		 "desc": {"fr": "+2 en AGRESSIF contre les bêtes.",
		          "en": "+2 to AGGRESSIVE rolls vs beasts.",
		          "id": "+2 untuk AGRESIF terhadap binatang."},
		 "match_family": 1, "tone": 0, "bonus": 2},
		{"id": &"silver_coin", "icon": "🪙",
		 "name": {"fr": "Pièce d'argent", "en": "Silver Coin", "id": "Koin Perak"},
		 "desc": {"fr": "+2 en TROMPEUR en cité.",
		          "en": "+2 to DECEPTIVE rolls in the city.",
		          "id": "+2 untuk PENIPU di kota."},
		 "biome": &"city", "tone": 4, "bonus": 2},
		{"id": &"holy_sigil", "icon": "✟",
		 "name": {"fr": "Sceau sacré", "en": "Holy Sigil", "id": "Lambang Suci"},
		 "desc": {"fr": "+2 en MYSTIQUE contre les morts-vivants.",
		          "en": "+2 to MYSTICAL rolls vs undead.",
		          "id": "+2 untuk MISTIS terhadap mayat hidup."},
		 "match_family": 2, "tone": 5, "bonus": 2},
		{"id": &"iron_ring", "icon": "⚙",
		 "name": {"fr": "Anneau de fer", "en": "Iron Ring", "id": "Cincin Besi"},
		 "desc": {"fr": "+1 à tous les jets de FORCE.",
		          "en": "+1 to all MIGHT rolls.",
		          "id": "+1 untuk semua KEKUATAN."},
		 "stat": &"force", "bonus": 1},
		{"id": &"crow_feather", "icon": "🪶",
		 "name": {"fr": "Plume de corbeau", "en": "Crow Feather", "id": "Bulu Gagak"},
		 "desc": {"fr": "+1 à tous les jets de PRUDENT.",
		          "en": "+1 to all CAUTIOUS rolls.",
		          "id": "+1 untuk semua HATI-HATI."},
		 "tone": 2, "bonus": 1},
		{"id": &"glass_eye", "icon": "👁",
		 "name": {"fr": "Œil de verre", "en": "Glass Eye", "id": "Mata Kaca"},
		 "desc": {"fr": "+2 à tous les jets de CURIEUX.",
		          "en": "+2 to all CURIOUS rolls.",
		          "id": "+2 untuk semua PENASARAN."},
		 "tone": 3, "bonus": 2},
		{"id": &"crystal_shard", "icon": "✦",
		 "name": {"fr": "Éclat cristallin", "en": "Crystal Shard", "id": "Pecahan Kristal"},
		 "desc": {"fr": "+2 à tous les jets de MYSTIQUE.",
		          "en": "+2 to all MYSTICAL rolls.",
		          "id": "+2 untuk semua MISTIS."},
		 "tone": 5, "bonus": 2},
		{"id": &"dragon_scale", "icon": "🐉",
		 "name": {"fr": "Écaille de dragon", "en": "Dragon Scale", "id": "Sisik Naga"},
		 "desc": {"fr": "+1 à tous les jets quand un dragon survole.",
		          "en": "+1 to all rolls during a dragon flyby.",
		          "id": "+1 untuk semua saat naga melintas."},
		 "dragon_present": true, "bonus": 1},
		{"id": &"ash_mark", "icon": "✺",
		 "name": {"fr": "Marque de cendre", "en": "Ash Mark", "id": "Tanda Abu"},
		 "desc": {"fr": "+1 contre les aberrations, peu importe le ton.",
		          "en": "+1 vs aberrations, any tone.",
		          "id": "+1 terhadap aberasi, tone apa pun."},
		 "match_family": 5, "bonus": 1},
		{"id": &"compass", "icon": "🧭",
		 "name": {"fr": "Boussole tordue", "en": "Twisted Compass", "id": "Kompas Bengkok"},
		 "desc": {"fr": "+1 à tous les jets en anomalie ou corruption.",
		          "en": "+1 to all rolls in anomaly or corrupted biomes.",
		          "id": "+1 untuk semua di anomali atau korupsi."},
		 "biomes": [&"anomaly", &"corrupted"], "bonus": 1},
		{"id": &"witch_knot", "icon": "🌀",
		 "name": {"fr": "Nœud de sorcière", "en": "Witch's Knot", "id": "Simpul Penyihir"},
		 "desc": {"fr": "Soigne une blessure à chaque zone passée.",
		          "en": "Heals one wound on each zone cleared.",
		          "id": "Sembuhkan satu luka tiap zona selesai."},
		 "passive": "heal_on_zone"},
		{"id": &"star_stone", "icon": "★",
		 "name": {"fr": "Pierre d'étoile", "en": "Star Stone", "id": "Batu Bintang"},
		 "desc": {"fr": "+1 ENDURANCE de manière permanente.",
		          "en": "+1 STAMINA permanently.",
		          "id": "+1 DAYA TAHAN permanen."},
		 "passive": "perma_endurance"},
		{"id": &"thorn_crown", "icon": "♚",
		 "name": {"fr": "Couronne d'épines", "en": "Thorn Crown", "id": "Mahkota Duri"},
		 "desc": {"fr": "+2 en DIPLOMATE contre les fées.",
		          "en": "+2 to DIPLOMATIC rolls vs fey.",
		          "id": "+2 untuk DIPLOMATIS terhadap peri."},
		 "match_family": 6, "tone": 1, "bonus": 2},
		{"id": &"iron_collar", "icon": "⛓",
		 "name": {"fr": "Collier de fer", "en": "Iron Collar", "id": "Kalung Besi"},
		 "desc": {"fr": "+2 en AGRESSIF contre les constructs.",
		          "en": "+2 to AGGRESSIVE rolls vs constructs.",
		          "id": "+2 untuk AGRESIF terhadap konstruk."},
		 "match_family": 3, "tone": 0, "bonus": 2},
		{"id": &"glowstone", "icon": "✺",
		 "name": {"fr": "Pierre lumineuse", "en": "Glowstone", "id": "Batu Bercahaya"},
		 "desc": {"fr": "+1 à tous les jets dans les biomes obscurs (crypte, corruption, anomalie).",
		          "en": "+1 to all rolls in dark biomes (crypt/corrupted/anomaly).",
		          "id": "+1 untuk semua di bioma gelap."},
		 "biomes": [&"crypt", &"corrupted", &"anomaly"], "bonus": 1},
		{"id": &"red_thread", "icon": "🧵",
		 "name": {"fr": "Fil rouge", "en": "Red Thread", "id": "Benang Merah"},
		 "desc": {"fr": "+2 en MYSTIQUE contre les draconides.",
		          "en": "+2 to MYSTICAL rolls vs draconic.",
		          "id": "+2 untuk MISTIS terhadap naga."},
		 "match_family": 7, "tone": 5, "bonus": 2},
		{"id": &"old_map", "icon": "✦",
		 "name": {"fr": "Vieille carte", "en": "Old Map", "id": "Peta Tua"},
		 "desc": {"fr": "+1 en CURIEUX dans tous les biomes naturels.",
		          "en": "+1 to CURIOUS rolls in natural biomes.",
		          "id": "+1 untuk PENASARAN di bioma alam."},
		 "biomes": [&"forest", &"swamp", &"highland", &"coast"], "tone": 3, "bonus": 1},
		{"id": &"phoenix_feather", "icon": "🪶",
		 "name": {"fr": "Plume de phénix", "en": "Phoenix Feather", "id": "Bulu Phoenix"},
		 "desc": {"fr": "Soigne TERREUR et MALÉDICTION dès la prise.",
		          "en": "Heals TERROR and CURSE on pickup.",
		          "id": "Sembuhkan TEROR dan KUTUKAN saat diambil."},
		 "passive": "cleanse_on_pickup"},
	]

static func by_id(id: StringName) -> Dictionary:
	for r in all():
		if r.id == id: return r
	return {}

static func pick_random(rng: DRNG) -> Dictionary:
	var arr: Array = all()
	return arr[rng.range_i(0, arr.size())]

# Compute total bonus a relic adds to a specific roll.
# context = { tone, stat, family, biome, dragon_present }
static func bonus_for(relic_id: StringName, ctx: Dictionary) -> int:
	var r: Dictionary = by_id(relic_id)
	if r.is_empty(): return 0
	var b: int = int(r.get("bonus", 0))
	if b == 0: return 0
	if r.has("tone") and int(r.tone) != int(ctx.get("tone", -1)): return 0
	if r.has("stat") and r.stat != ctx.get("stat", &""): return 0
	if r.has("match_family") and int(r.match_family) != int(ctx.get("family", -1)): return 0
	if r.has("biome") and r.biome != ctx.get("biome", &""): return 0
	if r.has("biomes"):
		var bs: Array = r.biomes
		if not (ctx.get("biome", &"") in bs): return 0
	if r.has("dragon_present") and not bool(ctx.get("dragon_present", false)): return 0
	return b
