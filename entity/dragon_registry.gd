class_name DragonRegistry extends RefCounted
# 11 dragons: 5 chromatic (evil), 5 metallic (good), 1 exotic (beyond).
# Each has its own weight (rarity), power tier, alignment and zone effect.
# Weights: higher = more common. The Unlit Wyrm is near-mythical (weight 1).
# Player-facing strings are localized: "name"/"intro" (fr, canonical) + "_en"/"_id".

enum Lineage { CHROMATIC, METALLIC, EXOTIC }
enum Align { EVIL, GOOD, BEYOND }

static func templates() -> Array:
	return [
		# --- Chromatic (evil) ---
		{"id": &"cinderborn", "name": "Cendre-née, le dragon rouge", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "name_en": "Cinderborn, the red dragon",
		 "name_id": "Lahir-dari-Abu, naga merah",
		 "tier": 3, "weight": 16, "element": &"fire",
		 "zone_effect": "aggression_boost", "value": 40,
		 "intro": "L'air devient lourd. Quelque part au-delà de ta vue, quelque chose brûle.",
		 "intro_en": "The air grows heavy. Somewhere beyond your sight, something burns.",
		 "intro_id": "Udara terasa berat. Di suatu tempat di luar pandanganmu, sesuatu terbakar."},
		{"id": &"stormfather", "name": "le Père-d'Orage, dragon bleu", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "name_en": "the Stormfather, blue dragon",
		 "name_id": "sang Bapa Badai, naga biru",
		 "tier": 3, "weight": 12, "element": &"lightning",
		 "zone_effect": "swingy_rolls", "value": 50,
		 "intro": "Le ciel s'ouvre en silence. Pas de tonnerre. Seule la promesse.",
		 "intro_en": "The sky opens in silence. No thunder. Only the promise.",
		 "intro_id": "Langit terbuka dalam diam. Tak ada guntur. Hanya janjinya."},
		{"id": &"rotcrown", "name": "Pourri-Couronne, dragon vert", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "name_en": "Rotcrown, green dragon",
		 "name_id": "Mahkota-Busuk, naga hijau",
		 "tier": 4, "weight": 8, "element": &"poison",
		 "zone_effect": "corruption_double", "value": 1,
		 "intro": "La terre perd ses couleurs. Tout ce qui respire ralentit.",
		 "intro_en": "The earth loses its colors. Everything that breathes slows.",
		 "intro_id": "Tanah kehilangan warnanya. Semua yang bernapas melambat."},
		{"id": &"mire_king", "name": "le Roi-des-Marais, dragon noir", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "name_en": "the Mire King, black dragon",
		 "name_id": "sang Raja Rawa, naga hitam",
		 "tier": 4, "weight": 6, "element": &"acid",
		 "zone_effect": "mixed_becomes_fail", "value": 3,
		 "intro": "Quelque chose a décidé que la chance t'abandonnerait.",
		 "intro_en": "Something has decided that luck will abandon you.",
		 "intro_id": "Sesuatu telah memutuskan bahwa keberuntungan akan meninggalkanmu."},
		{"id": &"hollowfrost", "name": "Givre-Creux, dragon blanc", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "name_en": "Hollowfrost, white dragon",
		 "name_id": "Beku-Hampa, naga putih",
		 "tier": 2, "weight": 18, "element": &"cold",
		 "zone_effect": "slow_flight", "value": 3,
		 "intro": "Le monde se ralentit. Tu entends ton propre pouls.",
		 "intro_en": "The world slows. You hear your own pulse.",
		 "intro_id": "Dunia melambat. Kau mendengar denyut nadimu sendiri."},

		# --- Metallic (good) ---
		{"id": &"lawbringer", "name": "Porte-Loi, dragon d'or", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "name_en": "Lawbringer, gold dragon",
		 "name_id": "Pembawa-Hukum, naga emas",
		 "tier": 5, "weight": 3, "element": &"radiant",
		 "zone_effect": "intel_boost", "value": 30,
		 "intro": "Une clarté froide traverse le ciel. Même les pierres semblent réfléchir.",
		 "intro_en": "A cold clarity crosses the sky. Even the stones seem to think.",
		 "intro_id": "Cahaya dingin melintasi langit. Bahkan bebatuan seakan berpikir."},
		{"id": &"moonvowed", "name": "Serment-de-Lune, dragon d'argent", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "name_en": "Moonvowed, silver dragon",
		 "name_id": "Sumpah-Rembulan, naga perak",
		 "tier": 4, "weight": 7, "element": &"force",
		 "zone_effect": "guided_instinct", "value": 2,
		 "intro": "Tu sais, pour la première fois, que quelque chose t'observe avec bienveillance.",
		 "intro_en": "You know, for the first time, that something watches you with kindness.",
		 "intro_id": "Untuk pertama kalinya, kau tahu ada sesuatu yang mengawasimu dengan welas asih."},
		{"id": &"tidekeeper", "name": "le Garde-Marée, dragon bronze", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "name_en": "the Tidekeeper, bronze dragon",
		 "name_id": "sang Penjaga Pasang, naga perunggu",
		 "tier": 3, "weight": 12, "element": &"sonic",
		 "zone_effect": "peace_truce", "value": 4,
		 "intro": "Un chant traverse la zone. Toutes les armes semblent soudain lourdes.",
		 "intro_en": "A song crosses the zone. Every weapon suddenly feels heavy.",
		 "intro_id": "Sebuah nyanyian melintasi zona. Semua senjata mendadak terasa berat."},
		{"id": &"silvertongue", "name": "Langue-d'Argent, dragon laiton", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "name_en": "Silvertongue, brass dragon",
		 "name_id": "Lidah-Perak, naga kuningan",
		 "tier": 2, "weight": 14, "element": &"heat",
		 "zone_effect": "deceptive_boost", "value": 4,
		 "intro": "Quelque chose dans l'air te dit que le mensonge est plus beau que la vérité, aujourd'hui.",
		 "intro_en": "Something in the air tells you that today, the lie is more beautiful than the truth.",
		 "intro_id": "Sesuatu di udara membisikkan bahwa hari ini, dusta lebih indah daripada kebenaran."},
		{"id": &"veilstep", "name": "Pas-de-Voile, dragon cuivre", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "name_en": "Veilstep, copper dragon",
		 "name_id": "Langkah-Tirai, naga tembaga",
		 "tier": 3, "weight": 9, "element": &"acid",
		 "zone_effect": "free_crit_cursed", "value": 1,
		 "intro": "Un cadeau t'est offert. Tu ne sais pas encore ce qu'il te coûtera.",
		 "intro_en": "A gift is offered to you. You do not yet know what it will cost.",
		 "intro_id": "Sebuah hadiah diberikan padamu. Kau belum tahu berapa harganya nanti."},

		# --- Exotic (beyond good and evil) ---
		{"id": &"unlit_wyrm", "name": "l'Éteint, ver d'obsidienne", "lineage": Lineage.EXOTIC, "align": Align.BEYOND,
		 "name_en": "the Unlit, obsidian wyrm",
		 "name_id": "sang Padam, ular naga obsidian",
		 "tier": 5, "weight": 1, "element": &"void",
		 "zone_effect": "delete_creature", "value": 1,
		 "intro": "Quelque chose manque. Tu ne peux pas dire quoi. C'est plus sûr ainsi.",
		 "intro_en": "Something is missing. You cannot say what. It is safer that way.",
		 "intro_id": "Ada yang hilang. Kau tak bisa bilang apa. Lebih aman begitu."},
	]

# ---------- localized accessors (FR canonical fallback) ----------

static func _loc(d: Dictionary, field: String) -> String:
	if Lang.code == "fr": return String(d.get(field, ""))
	return String(d.get(field + "_" + Lang.code, d.get(field, "")))

static func name_of(d: Dictionary) -> String:
	return _loc(d, "name")

static func intro_of(d: Dictionary) -> String:
	return _loc(d, "intro")

static func pick(rng: DRNG, chaos: float) -> Dictionary:
	# Per-dragon weighted pick. High chaos slightly favors the powerful (tier>=4).
	var arr: Array = templates()
	var total := 0
	var weights: Array = []
	for t in arr:
		var w: int = int(t.weight)
		if chaos > 0.8 and int(t.tier) >= 4: w += 2
		weights.append(w)
		total += w
	var r := rng.range_i(0, total)
	var acc := 0
	for i in arr.size():
		acc += weights[i]
		if r < acc: return arr[i]
	return arr[0]

static func by_id(id: StringName) -> Dictionary:
	for t in templates():
		if t.id == id: return t
	return {}
