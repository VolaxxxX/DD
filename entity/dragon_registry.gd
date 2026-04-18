class_name DragonRegistry extends RefCounted
# 11 dragons: 5 chromatic + 5 metallic + 1 exotic.
# Used by DragonSystem when a zone rolls an apex manifestation.

enum Lineage { CHROMATIC, METALLIC, EXOTIC }

static func templates() -> Array:
	return [
		# --- Chromatic ---
		{"id": &"cinderborn", "name": "Cendre-née, le dragon rouge", "lineage": Lineage.CHROMATIC, "tier": 3, "element": &"fire",
		 "zone_effect": "aggression_boost", "value": 40,
		 "intro": "L'air devient lourd. Quelque part au-delà de ta vue, quelque chose brûle."},
		{"id": &"stormfather", "name": "le Père-d'Orage, dragon bleu", "lineage": Lineage.CHROMATIC, "tier": 3, "element": &"lightning",
		 "zone_effect": "swingy_rolls", "value": 50,
		 "intro": "Le ciel s'ouvre en silence. Pas de tonnerre. Seule la promesse."},
		{"id": &"rotcrown", "name": "Pourri-Couronne, dragon vert", "lineage": Lineage.CHROMATIC, "tier": 3, "element": &"poison",
		 "zone_effect": "corruption_double", "value": 1,
		 "intro": "La terre perd ses couleurs. Tout ce qui respire ralentit."},
		{"id": &"mire_king", "name": "le Roi-des-Marais, dragon noir", "lineage": Lineage.CHROMATIC, "tier": 3, "element": &"acid",
		 "zone_effect": "mixed_becomes_fail", "value": 3,
		 "intro": "Quelque chose a décidé que la chance t'abandonnerait."},
		{"id": &"hollowfrost", "name": "Givre-Creux, dragon blanc", "lineage": Lineage.CHROMATIC, "tier": 3, "element": &"cold",
		 "zone_effect": "slow_coop", "value": 1,
		 "intro": "Le monde se ralentit. Tu entends ton propre pouls."},

		# --- Metallic ---
		{"id": &"lawbringer", "name": "Porte-Loi, dragon d'or", "lineage": Lineage.METALLIC, "tier": 3, "element": &"radiant",
		 "zone_effect": "intel_boost", "value": 30,
		 "intro": "Une clarté froide traverse le ciel. Même les pierres semblent réfléchir."},
		{"id": &"moonvowed", "name": "Serment-de-Lune, dragon d'argent", "lineage": Lineage.METALLIC, "tier": 3, "element": &"force",
		 "zone_effect": "reveal_stat", "value": 1,
		 "intro": "Tu sais, pour la première fois, que quelque chose t'observe avec bienveillance."},
		{"id": &"tidekeeper", "name": "le Garde-Marée, dragon bronze", "lineage": Lineage.METALLIC, "tier": 3, "element": &"sonic",
		 "zone_effect": "peace_truce", "value": 2,
		 "intro": "Un chant traverse la zone. Toutes les armes semblent soudain lourdes."},
		{"id": &"silvertongue", "name": "Langue-d'Argent, dragon laiton", "lineage": Lineage.METALLIC, "tier": 3, "element": &"heat",
		 "zone_effect": "deceptive_boost", "value": 2,
		 "intro": "Quelque chose dans l'air te dit que le mensonge est plus beau que la vérité, aujourd'hui."},
		{"id": &"veilstep", "name": "Pas-de-Voile, dragon cuivre", "lineage": Lineage.METALLIC, "tier": 3, "element": &"acid",
		 "zone_effect": "free_crit_cursed", "value": 1,
		 "intro": "Un cadeau t'est offert. Tu ne sais pas encore ce qu'il te coûtera."},

		# --- Exotic ---
		{"id": &"unlit_wyrm", "name": "l'Éteint, ver d'obsidienne", "lineage": Lineage.EXOTIC, "tier": 4, "element": &"void",
		 "zone_effect": "delete_creature", "value": 1,
		 "intro": "Quelque chose manque. Tu ne peux pas dire quoi. C'est plus sûr ainsi."},
	]

static func pick(rng: DRNG, chaos: float) -> Dictionary:
	var arr: Array = templates()
	var pool: Array = []
	var lineage_weights := {Lineage.CHROMATIC: 45, Lineage.METALLIC: 40, Lineage.EXOTIC: 13}
	var total := 0
	for k in lineage_weights: total += lineage_weights[k]
	var r := rng.range_i(0, total)
	var acc := 0
	var chosen_lineage := Lineage.CHROMATIC
	for k in lineage_weights:
		acc += lineage_weights[k]
		if r < acc:
			chosen_lineage = k; break
	for t in arr:
		if int(t.lineage) == chosen_lineage: pool.append(t)
	if pool.is_empty(): return arr[rng.range_i(0, arr.size())]
	return pool[rng.range_i(0, pool.size())]
