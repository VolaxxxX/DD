class_name CreatureRegistry extends RefCounted
# Named creature templates. The factory rolls tier + biome, then picks from here.
# Names are localized: "name" (fr, canonical), "name_en", "name_id".

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
		{"id": &"gutter_scavenger", "name": "le crocheteur", "name_en": "the lockpick", "name_id": "si pembobol", "family": F_HUMANOID, "tier": T_COMMON, "role": R_SCAVENGER, "intel": 40, "aggr": 25, "biomes": [&"city", &"ruins"]},
		{"id": &"hooded_outlaw", "name": "le bandit encapuchonné", "name_en": "the hooded outlaw", "name_id": "si bandit berkerudung", "family": F_HUMANOID, "tier": T_COMMON, "role": R_TERRITORIAL, "intel": 55, "aggr": 55, "biomes": [&"forest", &"ruins"]},
		{"id": &"ash_inquisitor", "name": "l'inquisiteur des cendres", "name_en": "the ash inquisitor", "name_id": "sang inkuisitor abu", "family": F_HUMANOID, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 70, "aggr": 70, "biomes": [&"city", &"corrupted"]},
		{"id": &"sunken_hermit", "name": "l'ermite des bas-fonds", "name_en": "the hermit of the depths", "name_id": "sang pertapa kedalaman", "family": F_HUMANOID, "tier": T_RARE, "role": R_MODIFIER, "intel": 85, "aggr": 20, "biomes": [&"ruins", &"anomaly"]},
		{"id": &"flesh_broker", "name": "le marchand de chair", "name_en": "the flesh broker", "name_id": "si pedagang daging", "family": F_HUMANOID, "tier": T_ELITE, "role": R_TERRITORIAL, "intel": 75, "aggr": 65, "biomes": [&"corrupted", &"city"]},
		{"id": &"nameless_pilgrim", "name": "le pèlerin sans nom", "name_en": "the nameless pilgrim", "name_id": "sang peziarah tanpa nama", "family": F_HUMANOID, "tier": T_APEX, "role": R_MODIFIER, "intel": 95, "aggr": 10, "biomes": [&"forest", &"city", &"ruins", &"corrupted", &"anomaly"]},

		# --- BEAST ---
		{"id": &"dire_wolf", "name": "le loup-terrible", "name_en": "the dire wolf", "name_id": "si serigala buas", "family": F_BEAST, "tier": T_COMMON, "role": R_PREDATOR, "intel": 25, "aggr": 75, "biomes": [&"forest"]},
		{"id": &"thornback_stag", "name": "le cerf-d'épines", "name_en": "the thornback stag", "name_id": "si rusa berduri", "family": F_BEAST, "tier": T_COMMON, "role": R_PREY, "intel": 35, "aggr": 30, "biomes": [&"forest"]},
		{"id": &"blood_crow_swarm", "name": "la nuée aux yeux rouges", "name_en": "the red-eyed swarm", "name_id": "kawanan bermata merah", "family": F_BEAST, "tier": T_UNCOMMON, "role": R_SCAVENGER, "intel": 30, "aggr": 60, "biomes": [&"forest", &"ruins", &"city"]},
		{"id": &"plague_hound", "name": "le chien-de-peste", "name_en": "the plague hound", "name_id": "si anjing wabah", "family": F_BEAST, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 25, "aggr": 80, "biomes": [&"corrupted"]},
		{"id": &"sandstalker", "name": "le rôdeur de sable", "name_en": "the sand stalker", "name_id": "si pengintai pasir", "family": F_BEAST, "tier": T_RARE, "role": R_PREDATOR, "intel": 40, "aggr": 85, "biomes": [&"ruins"]},
		{"id": &"mother_leech", "name": "la sangsue-mère", "name_en": "the mother leech", "name_id": "sang induk lintah", "family": F_BEAST, "tier": T_RARE, "role": R_TERRITORIAL, "intel": 20, "aggr": 60, "biomes": [&"corrupted", &"swamp"]},
		{"id": &"old_wood_stag", "name": "le cerf-du-bois-ancien", "name_en": "the stag of the old wood", "name_id": "sang rusa hutan tua", "family": F_BEAST, "tier": T_ELITE, "role": R_APEX, "intel": 90, "aggr": 15, "biomes": [&"forest"]},

		# --- UNDEAD ---
		{"id": &"wight", "name": "le spectre-chair", "name_en": "the flesh-wight", "name_id": "si hantu daging", "family": F_UNDEAD, "tier": T_COMMON, "role": R_SCAVENGER, "intel": 25, "aggr": 55, "biomes": [&"ruins", &"corrupted"]},
		{"id": &"ash_revenant", "name": "le revenant-cendre", "name_en": "the ash revenant", "name_id": "si arwah abu", "family": F_UNDEAD, "tier": T_COMMON, "role": R_PREDATOR, "intel": 40, "aggr": 65, "biomes": [&"ruins", &"city"]},
		{"id": &"bone_choir", "name": "le chœur d'ossements", "name_en": "the bone choir", "name_id": "paduan suara tulang", "family": F_UNDEAD, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 60, "aggr": 40, "biomes": [&"ruins"]},
		{"id": &"drowned_herald", "name": "le héraut-noyé", "name_en": "the drowned herald", "name_id": "sang bentara tenggelam", "family": F_UNDEAD, "tier": T_RARE, "role": R_MODIFIER, "intel": 65, "aggr": 50, "biomes": [&"corrupted", &"ruins"]},
		{"id": &"lich_scholar", "name": "le liche-érudit", "name_en": "the scholar-lich", "name_id": "sang lich cendekia", "family": F_UNDEAD, "tier": T_ELITE, "role": R_TERRITORIAL, "intel": 95, "aggr": 45, "biomes": [&"ruins"]},
		{"id": &"whisper_shade", "name": "l'ombre-chuchotante", "name_en": "the whispering shade", "name_id": "bayangan berbisik", "family": F_UNDEAD, "tier": T_APEX, "role": R_MODIFIER, "intel": 80, "aggr": 20, "biomes": [&"corrupted", &"anomaly"]},

		# --- CONSTRUCT ---
		{"id": &"clockwork_sentinel", "name": "la sentinelle-d'horloge", "name_en": "the clockwork sentinel", "name_id": "si penjaga mesin jam", "family": F_CONSTRUCT, "tier": T_COMMON, "role": R_TERRITORIAL, "intel": 40, "aggr": 70, "biomes": [&"city", &"ruins"]},
		{"id": &"marble_guardian", "name": "le gardien-de-marbre", "name_en": "the marble guardian", "name_id": "si penjaga pualam", "family": F_CONSTRUCT, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 30, "aggr": 80, "biomes": [&"ruins"]},
		{"id": &"thought_engine", "name": "la machine-à-pensées", "name_en": "the thought-engine", "name_id": "si mesin pikiran", "family": F_CONSTRUCT, "tier": T_RARE, "role": R_MODIFIER, "intel": 90, "aggr": 30, "biomes": [&"ruins", &"city"]},
		{"id": &"stitched_golem", "name": "le golem-cousu", "name_en": "the stitched golem", "name_id": "si golem jahitan", "family": F_CONSTRUCT, "tier": T_ELITE, "role": R_PREDATOR, "intel": 45, "aggr": 75, "biomes": [&"corrupted", &"city"]},
		{"id": &"singing_automaton", "name": "l'automate-chanteur", "name_en": "the singing automaton", "name_id": "si otomaton penyanyi", "family": F_CONSTRUCT, "tier": T_APEX, "role": R_MODIFIER, "intel": 70, "aggr": 30, "biomes": [&"anomaly", &"city"]},

		# --- ELEMENTAL ---
		{"id": &"ember_sprite", "name": "le lutin-de-braise", "name_en": "the ember sprite", "name_id": "si peri bara", "family": F_ELEMENTAL, "tier": T_COMMON, "role": R_MODIFIER, "intel": 30, "aggr": 55, "biomes": [&"ruins", &"corrupted"]},
		{"id": &"frost_herald", "name": "le héraut-de-givre", "name_en": "the frost herald", "name_id": "si bentara beku", "family": F_ELEMENTAL, "tier": T_COMMON, "role": R_MODIFIER, "intel": 40, "aggr": 45, "biomes": [&"anomaly"]},
		{"id": &"stone_lord", "name": "le seigneur-de-pierre", "name_en": "the stone lord", "name_id": "sang penguasa batu", "family": F_ELEMENTAL, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 50, "aggr": 40, "biomes": [&"ruins"]},
		{"id": &"storm_rider", "name": "le chevaucheur-d'orage", "name_en": "the storm rider", "name_id": "si penunggang badai", "family": F_ELEMENTAL, "tier": T_RARE, "role": R_PREDATOR, "intel": 60, "aggr": 70, "biomes": [&"anomaly", &"forest"]},
		{"id": &"void_spark", "name": "l'étincelle-du-vide", "name_en": "the void-spark", "name_id": "percik kehampaan", "family": F_ELEMENTAL, "tier": T_APEX, "role": R_MODIFIER, "intel": 40, "aggr": 60, "biomes": [&"anomaly", &"corrupted"]},

		# --- ABERRATION ---
		{"id": &"mind_thief", "name": "le voleur-de-pensées", "name_en": "the thought-thief", "name_id": "si pencuri pikiran", "family": F_ABERRATION, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 85, "aggr": 45, "biomes": [&"anomaly"]},
		{"id": &"fleshwarp", "name": "la chair-tordue", "name_en": "the twisted flesh", "name_id": "daging terpilin", "family": F_ABERRATION, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 25, "aggr": 75, "biomes": [&"corrupted"]},
		{"id": &"thousand_eye", "name": "la chose-aux-mille-yeux", "name_en": "the thing of a thousand eyes", "name_id": "makhluk seribu mata", "family": F_ABERRATION, "tier": T_RARE, "role": R_MODIFIER, "intel": 75, "aggr": 40, "biomes": [&"anomaly"]},
		{"id": &"echo_parasite", "name": "le parasite-d'écho", "name_en": "the echo parasite", "name_id": "si parasit gema", "family": F_ABERRATION, "tier": T_RARE, "role": R_MODIFIER, "intel": 55, "aggr": 50, "biomes": [&"anomaly", &"corrupted"]},
		{"id": &"the_nameless", "name": "le sans-nom", "name_en": "the nameless", "name_id": "yang tak bernama", "family": F_ABERRATION, "tier": T_ELITE, "role": R_APEX, "intel": 95, "aggr": 60, "biomes": [&"anomaly", &"corrupted"]},
		{"id": &"tessellation", "name": "la tessellation", "name_en": "the tessellation", "name_id": "sang teselasi", "family": F_ABERRATION, "tier": T_APEX, "role": R_MODIFIER, "intel": 70, "aggr": 55, "biomes": [&"anomaly"]},

		# --- FEY ---
		{"id": &"thorn_duchess", "name": "la duchesse-d'épines", "name_en": "the thorn duchess", "name_id": "sang ratu duri", "family": F_FEY, "tier": T_UNCOMMON, "role": R_TERRITORIAL, "intel": 80, "aggr": 55, "biomes": [&"forest"]},
		{"id": &"pale_jester", "name": "le bouffon-blême", "name_en": "the pale jester", "name_id": "si badut pucat", "family": F_FEY, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 70, "aggr": 50, "biomes": [&"forest", &"anomaly"]},
		{"id": &"dream_weaver", "name": "la tisseuse-de-rêves", "name_en": "the dream-weaver", "name_id": "sang penenun mimpi", "family": F_FEY, "tier": T_RARE, "role": R_MODIFIER, "intel": 90, "aggr": 30, "biomes": [&"anomaly"]},
		{"id": &"market_faer", "name": "le marchand-fée", "name_en": "the faerie merchant", "name_id": "si saudagar peri", "family": F_FEY, "tier": T_RARE, "role": R_MODIFIER, "intel": 85, "aggr": 25, "biomes": [&"forest", &"city", &"ruins"]},
		{"id": &"hollow_child", "name": "l'enfant-creux", "name_en": "the hollow child", "name_id": "si bocah hampa", "family": F_FEY, "tier": T_APEX, "role": R_MODIFIER, "intel": 60, "aggr": 35, "biomes": [&"forest", &"anomaly"]},

		# --- SWAMP ---
		{"id": &"bog_witch", "name": "la sorcière-des-marais", "name_en": "the bog witch", "name_id": "si penyihir rawa", "family": F_HUMANOID, "tier": T_RARE, "role": R_MODIFIER, "intel": 80, "aggr": 35, "biomes": [&"swamp"]},
		{"id": &"will_o_wisp", "name": "le feu-follet", "name_en": "the will-o'-wisp", "name_id": "si api hantu", "family": F_ELEMENTAL, "tier": T_COMMON, "role": R_MODIFIER, "intel": 35, "aggr": 30, "biomes": [&"swamp"]},
		{"id": &"toad_king", "name": "le roi-crapaud", "name_en": "the toad king", "name_id": "sang raja kodok", "family": F_BEAST, "tier": T_ELITE, "role": R_TERRITORIAL, "intel": 50, "aggr": 70, "biomes": [&"swamp"]},

		# --- HIGHLAND ---
		{"id": &"mountain_lion", "name": "le lion-de-pierre", "name_en": "the stone lion", "name_id": "si singa batu", "family": F_BEAST, "tier": T_UNCOMMON, "role": R_PREDATOR, "intel": 35, "aggr": 80, "biomes": [&"highland"]},
		{"id": &"sky_skald", "name": "le scalde-du-ciel", "name_en": "the sky-skald", "name_id": "si penyair langit", "family": F_HUMANOID, "tier": T_RARE, "role": R_MODIFIER, "intel": 75, "aggr": 40, "biomes": [&"highland"]},
		{"id": &"giant_eagle", "name": "l'aigle-géant", "name_en": "the giant eagle", "name_id": "si elang raksasa", "family": F_BEAST, "tier": T_RARE, "role": R_PREDATOR, "intel": 50, "aggr": 65, "biomes": [&"highland", &"coast"]},

		# --- CRYPT ---
		{"id": &"tomb_ghoul", "name": "le goule-des-tombes", "name_en": "the tomb ghoul", "name_id": "si ghul makam", "family": F_UNDEAD, "tier": T_COMMON, "role": R_PREDATOR, "intel": 30, "aggr": 70, "biomes": [&"crypt", &"ruins"]},
		{"id": &"sealed_lord", "name": "le seigneur-scellé", "name_en": "the sealed lord", "name_id": "sang penguasa tersegel", "family": F_UNDEAD, "tier": T_ELITE, "role": R_APEX, "intel": 90, "aggr": 50, "biomes": [&"crypt"]},
		{"id": &"crypt_wraith", "name": "la spectre-des-cryptes", "name_en": "the crypt wraith", "name_id": "si hantu kripta", "family": F_UNDEAD, "tier": T_UNCOMMON, "role": R_MODIFIER, "intel": 65, "aggr": 50, "biomes": [&"crypt"]},

		# --- COAST ---
		{"id": &"drowned_sailor", "name": "le marin-noyé", "name_en": "the drowned sailor", "name_id": "si pelaut tenggelam", "family": F_UNDEAD, "tier": T_COMMON, "role": R_PREDATOR, "intel": 35, "aggr": 60, "biomes": [&"coast"]},
		{"id": &"reef_priestess", "name": "la prêtresse-du-récif", "name_en": "the reef priestess", "name_id": "sang pendeta karang", "family": F_HUMANOID, "tier": T_RARE, "role": R_MODIFIER, "intel": 80, "aggr": 30, "biomes": [&"coast"]},
		{"id": &"tide_horror", "name": "l'horreur-des-marées", "name_en": "the tide horror", "name_id": "si teror pasang", "family": F_ABERRATION, "tier": T_ELITE, "role": R_PREDATOR, "intel": 55, "aggr": 75, "biomes": [&"coast"]},
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
		"swamp":     return F_BEAST
		"highland":  return F_BEAST
		"crypt":     return F_UNDEAD
		"coast":     return F_HUMANOID
		_:           return F_BEAST

# Localized display name for a template dictionary (FR canonical fallback).
static func display_name(t: Dictionary) -> String:
	match Lang.code:
		"en": return String(t.get("name_en", t.name))
		"id": return String(t.get("name_id", t.name))
		_:    return String(t.name)

static func name_for_id(id: StringName) -> String:
	for t in templates():
		if t.id == id: return display_name(t)
	match Lang.code:
		"en": return "the entity"
		"id": return "sang entitas"
		_:    return "l'entité"
