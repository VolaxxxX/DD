class_name DragonRegistry extends RefCounted
# 11 dragons: 5 chromatic (evil), 5 metallic (good), 1 exotic (beyond).
# Each has its own weight (rarity), power tier, alignment and zone effect.
# Weights: higher = more common. The Unlit Wyrm is near-mythical (weight 1).

enum Lineage { CHROMATIC, METALLIC, EXOTIC }
enum Align { EVIL, GOOD, BEYOND }

static func templates() -> Array:
	return [
		# --- Chromatic (evil) ---
		{"id": &"cinderborn", "name": "Cendre-née, le dragon rouge", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "tier": 3, "weight": 16, "element": &"fire",
		 "zone_effect": "aggression_boost", "value": 40,
		 "intro": "L'air devient lourd. Quelque part au-delà de ta vue, quelque chose brûle."},
		{"id": &"stormfather", "name": "le Père-d'Orage, dragon bleu", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "tier": 3, "weight": 12, "element": &"lightning",
		 "zone_effect": "swingy_rolls", "value": 50,
		 "intro": "Le ciel s'ouvre en silence. Pas de tonnerre. Seule la promesse."},
		{"id": &"rotcrown", "name": "Pourri-Couronne, dragon vert", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "tier": 4, "weight": 8, "element": &"poison",
		 "zone_effect": "corruption_double", "value": 1,
		 "intro": "La terre perd ses couleurs. Tout ce qui respire ralentit."},
		{"id": &"mire_king", "name": "le Roi-des-Marais, dragon noir", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "tier": 4, "weight": 6, "element": &"acid",
		 "zone_effect": "mixed_becomes_fail", "value": 3,
		 "intro": "Quelque chose a décidé que la chance t'abandonnerait."},
		{"id": &"hollowfrost", "name": "Givre-Creux, dragon blanc", "lineage": Lineage.CHROMATIC, "align": Align.EVIL,
		 "tier": 2, "weight": 18, "element": &"cold",
		 "zone_effect": "slow_flight", "value": 3,
		 "intro": "Le monde se ralentit. Tu entends ton propre pouls."},

		# --- Metallic (good) ---
		{"id": &"lawbringer", "name": "Porte-Loi, dragon d'or", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "tier": 5, "weight": 3, "element": &"radiant",
		 "zone_effect": "intel_boost", "value": 30,
		 "intro": "Une clarté froide traverse le ciel. Même les pierres semblent réfléchir."},
		{"id": &"moonvowed", "name": "Serment-de-Lune, dragon d'argent", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "tier": 4, "weight": 7, "element": &"force",
		 "zone_effect": "guided_instinct", "value": 2,
		 "intro": "Tu sais, pour la première fois, que quelque chose t'observe avec bienveillance."},
		{"id": &"tidekeeper", "name": "le Garde-Marée, dragon bronze", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "tier": 3, "weight": 12, "element": &"sonic",
		 "zone_effect": "peace_truce", "value": 4,
		 "intro": "Un chant traverse la zone. Toutes les armes semblent soudain lourdes."},
		{"id": &"silvertongue", "name": "Langue-d'Argent, dragon laiton", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "tier": 2, "weight": 14, "element": &"heat",
		 "zone_effect": "deceptive_boost", "value": 4,
		 "intro": "Quelque chose dans l'air te dit que le mensonge est plus beau que la vérité, aujourd'hui."},
		{"id": &"veilstep", "name": "Pas-de-Voile, dragon cuivre", "lineage": Lineage.METALLIC, "align": Align.GOOD,
		 "tier": 3, "weight": 9, "element": &"acid",
		 "zone_effect": "free_crit_cursed", "value": 1,
		 "intro": "Un cadeau t'est offert. Tu ne sais pas encore ce qu'il te coûtera."},

		# --- Exotic (beyond good and evil) ---
		{"id": &"unlit_wyrm", "name": "l'Éteint, ver d'obsidienne", "lineage": Lineage.EXOTIC, "align": Align.BEYOND,
		 "tier": 5, "weight": 1, "element": &"void",
		 "zone_effect": "delete_creature", "value": 1,
		 "intro": "Quelque chose manque. Tu ne peux pas dire quoi. C'est plus sûr ainsi."},
	]

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
