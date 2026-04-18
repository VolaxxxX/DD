class_name CreatureRegistry extends RefCounted
# Named creature templates. The factory rolls tier + biome, then picks from here.

const F_HUMANOID := 0
const F_BEAST := 1
const F_UNDEAD := 2
const F_CONSTRUCT := 3
const F_ELEMENTAL := 4
const F_ABERRATION := 5
const F_FEY := 6
const F_DRACONIC := 7

const T_COMMON := 0
const T_UNCOMMON := 1
const T_RARE := 2
const T_ELITE := 3
const T_APEX := 4
const T_MYTHIC := 5

const R_PREDATOR := 0
const R_PREY := 1
const R_TERRITORIAL := 2
const R_SCAVENGER := 3
const R_MODIFIER := 4
const R_APEX := 5

static func templates() -> Array:
	return [
		# --- HUMANOID ---
		{"id": &"gutter_scavenger", "name": "le crocheteur", "family": F_HUMANOID, "tier": T_COMMON, "role": R_SCAVENGER, "intel": 40, "aggr": 25, "biomes": [&"city", &"ruins"]},
		{"id": &"hooded_outlaw", "name": "le bandit encapuchonné", "family": F_HUMANOID, "tier": T_COMMON, "role": R_TERRITORIAL, "intel": 55, "aggr": 55, "biomes": [&"forest", &"ruins"]},
		{"id": &"ash_inquisitor", "name": "l'inquisiteur des cendres", "family": F_HUMANOID, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 70, "aggr": 70, "biomes": [&"city", &"corrupted"]},
		{"id": &"sunken_hermit", "name": "l'ermite des bas-fonds", "family": F_HUMANOID, "tier": T_RARE, "role": R_MODIFIER, "intel": 85, "aggr": 20, "biomes": [&"ruins", &"anomaly"]},
		{"id": &"flesh_broker", "name": "le marchand de chair", "family": F_HUMANOID, "tier": T_ELITE, "role": R_TERRITORIAL, "intel": 75, "aggr": 65, "biomes": [&"corrupted", &"city"]},
		{"id": &"nameless_pilgrim", "name": "le pèlerin sans nom", "family": F_HUMANOID, "tier": T_APEX, "role": R_MODIFIER, "intel": 95, "aggr": 10, "biomes": [&"forest", &"city", &"ruins", &"corrupted", &"anomaly"]},

		# --- BEAST ---
		{"id": &"dire_wolf", "name": "le loup-terrible", "family": F_BEAST, "tier": T_COMMON, "role": R_PREDATOR, "intel": 25, "aggr": 75, "biomes": [&"forest"]},
		{"id": &"thornback_stag", "name": "le cerf-d'épines", "family": F_BEAST, "tier": T_COMMON, "role": R_PREY, "intel": 35, "aggr": 30, "biomes": [&"forest"]},
		{"id": &"blood_crow_swarm", "name": "la nuée aux yeux rouges", "family": F_BEAST, "tier": T_UNCOMMON, "role": R_SCAVENGER, "intel": 30, "aggr": 60, "biomes": [&"forest", &"ruins", &"city"]},
		{"id": &"plague_hound", "name": "le chien-de-peste", "family": F_BEAST, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 25, "aggr": 80, "biomes": [&"corrupted"]},
		{"id": &"sandstalker", "name": "le rôdeur de sable", "family": F_BEAST, "tier": T_RARE, "role": R_PREDATOR, "intel": 40, "aggr": 85, "biomes": [&"ruins"]},
		{"id": &"mother_leech", "name": "la sangsue-mère", "family": F_BEAST, "tier": T_RARE, "role": R_TERRITORIAL, "intel": 20, "aggr": 60, "biomes": [&"corrupted"]},
		{"id": &"old_wood_stag", "name": "le cerf-du-bois-ancien", "family": F_BEAST, "tier": T_ELITE, "role": R_APEX, "intel": 90, "aggr": 15, "biomes": [&"forest"]},

		# --- UNDEAD ---
		{"id": &"wight", "name": "le spectre-chair", "family": F_UNDEAD, "tier": T_COMMON, "role": R_SCAVENGER, "intel": 25, "aggr": 55, "biomes": [&"ruins", &"corrupted"]},
		{"id": &"ash_revenant", "name": "le revenant-cendre", "family": F_UNDEAD, "tier": T_COMMON, "role": R_PREDATOR, "intel": 40, "aggr": 65, "biomes": [&"ruins", &"city"]},
		{"id": &"bone_choir", "name": "le chœur d'ossements", "family": F_UNDEAD, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 60, "aggr": 40, "biomes": [&"ruins"]},
		{"id": &"drowned_herald", "name": "le héraut-noyé", "family": F_UNDEAD, "tier": T_RARE, "role": R_MODIFIER, "intel": 65, "aggr": 50, "biomes": [&"corrupted", &"ruins"]},
		{"id": &"lich_scholar", "name": "le liche-érudit", "family": F_UNDEAD, "tier": T_ELITE, "role": R_TERRITORIAL, "intel": 95, "aggr": 45, "biomes": [&"ruins"]},
		{"id": &"whisper_shade", "name": "l'ombre-chuchotante", "family": F_UNDEAD, "tier": T_APEX, "role": R_MODIFIER, "intel": 80, "aggr": 20, "biomes": [&"corrupted", &"anomaly"]},

		# --- CONSTRUCT ---
		{"id": &"clockwork_sentinel", "name": "la sentinelle-d'horloge", "family": F_CONSTRUCT, "tier": T_COMMON, "role": R_TERRITORIAL, "intel": 40, "aggr": 70, "biomes": [&"city", &"ruins"]},
		{"id": &"marble_guardian", "name": "le gardien-de-marbre", "family": F_CONSTRUCT, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 30, "aggr": 80, "biomes": [&"ruins"]},
		{"id": &"thought_engine", "name": "la machine-à-pensées", "family": F_CONSTRUCT, "tier": T_RARE, "role": R_MODIFIER, "intel": 90, "aggr": 30, "biomes": [&"ruins", &"city"]},
		{"id": &"stitched_golem", "name": "le golem-cousu", "family": F_CONSTRUCT, "tier": T_ELITE, "role": R_PREDATOR, "intel": 45, "aggr": 75, "biomes": [&"corrupted", &"city"]},
		{"id": &"singing_automaton", "name": "l'automate-chanteur", "family": F_CONSTRUCT, "tier": T_APEX, "role": R_MODIFIER, "intel": 70, "aggr": 30, "biomes": [&"anomaly", &"city"]},

		# --- ELEMENTAL ---
		{"id": &"ember_sprite", "name": "le lutin-de-braise", "family": F_ELEMENTAL, "tier": T_COMMON, "role": R_MODIFIER, "intel": 30, "aggr": 55, "biomes": [&"ruins", &"corrupted"]},
		{"id": &"frost_herald", "name": "le héraut-de-givre", "family": F_ELEMENTAL, "tier": T_COMMON, "role": R_MODIFIER, "intel": 40, "aggr": 45, "biomes": [&"anomaly"]},
		{"id": &"stone_lord", "name": "le seigneur-de-pierre", "family": F_ELEMENTAL, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 50, "aggr": 40, "biomes": [&"ruins"]},
		{"id": &"storm_rider", "name": "le chevaucheur-d'orage", "family": F_ELEMENTAL, "tier": T_RARE, "role": R_PREDATOR, "intel": 60, "aggr": 70, "biomes": [&"anomaly", &"forest"]},
		{"id": &"void_spark", "name": "l'étincelle-du-vide", "family": F_ELEMENTAL, "tier": T_APEX, "role": R_MODIFIER, "intel": 40, "aggr": 60, "biomes": [&"anomaly", &"corrupted"]},

		# --- ABERRATION ---
		{"id": &"mind_thief", "name": "le voleur-de-pensées", "family": F_ABERRATION, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 85, "aggr": 45, "biomes": [&"anomaly"]},
		{"id": &"fleshwarp", "name": "la chair-tordue", "family": F_ABERRATION, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 25, "aggr": 75, "biomes": [&"corrupted"]},
		{"id": &"thousand_eye", "name": "la chose-aux-mille-yeux", "family": F_ABERRATION, "tier": T_RARE, "role": R_MODIFIER, "intel": 75, "aggr": 40, "biomes": [&"anomaly"]},
		{"id": &"echo_parasite", "name": "le parasite-d'écho", "family": F_ABERRATION, "tier": T_RARE, "role": R_MODIFIER, "intel": 55, "aggr": 50, "biomes": [&"anomaly", &"corrupted"]},
		{"id": &"the_nameless", "name": "le sans-nom", "family": F_ABERRATION, "tier": T_ELITE, "role": R_APEX, "intel": 95, "aggr": 60, "biomes": [&"anomaly", &"corrupted"]},
		{"id": &"tessellation", "name": "la tessellation", "family": F_ABERRATION, "tier": T_APEX, "role": R_MODIFIER, "intel": 70, "aggr": 55, "biomes": [&"anomaly"]},

		# --- FEY ---
		{"id": &"thorn_duchess", "name": "la duchesse-d'épines", "family": F_FEY, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 80, "aggr": 55, "biomes": [&"forest"]},
		{"id": &"pale_jester", "name": "le bouffon-blême", "family": F_FEY, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 70, "aggr": 50, "biomes": [&"forest", &"anomaly"]},
		{"id": &"dream_weaver", "name": "la tisseuse-de-rêves", "family": F_FEY, "tier": T_RARE, "role": R_MODIFIER, "intel": 90, "aggr": 30, "biomes": [&"anomaly"]},
		{"id": &"market_faer", "name": "le marchand-fée", "family": F_FEY, "tier": T_RARE, "role": R_MODIFIER, "intel": 85, "aggr": 25, "biomes": [&"forest", &"city", &"ruins"]},
		{"id": &"hollow_child", "name": "l'enfant-creux", "family": F_FEY, "tier": T_APEX, "role": R_MODIFIER, "intel": 60, "aggr": 35, "biomes": [&"forest", &"anomaly"]},
	]

static func for_biome_and_tier(biome: StringName, tier: int) -> Array:
	var out: Array = []
	for t in templates():
		if int(t.tier) == tier and biome in t.biomes:
			out.append(t)
	return out

static func fallback_family_for_biome(biome: StringName) -> int:
	match String(biome):
		"forest":    return F_BEAST
		"city":      return F_HUMANOID
		"ruins":     return F_UNDEAD
		"corrupted": return F_ABERRATION
		"anomaly":   return F_ABERRATION
		_:           return F_BEAST

static func name_for_id(id: StringName) -> String:
	for t in templates():
		if t.id == id: return String(t.name)
	return "l'entité"
