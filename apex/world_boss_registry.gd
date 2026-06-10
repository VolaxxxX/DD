class_name WorldBossRegistry extends RefCounted
# Six mythic world bosses. Rare manifestations — last-zone events.

static func templates() -> Array:
	return [
		{"id": &"prismatic_ascendant",
		 "name": "l'Ascendant-Prismatique",
		 "intro": "La lumière se plie sans source. Toutes les ombres pointent vers toi.",
		 "title": "Celui-qui-a-été-tous-les-dragons",
		 "effect": "all_tones_mixed",
		 "trigger_hint": "biome:anomaly+corruption>0.7"},
		{"id": &"nameless_sovereign",
		 "name": "le Souverain-Sans-Nom",
		 "intro": "Un trône vide te regarde. Tu as oublié ton propre nom pour un instant.",
		 "title": "roi des choses qui n'ont jamais existé",
		 "effect": "strip_memory",
		 "trigger_hint": "runs_completed>=3"},
		{"id": &"sea_beneath_stone",
		 "name": "la Mer-Sous-Pierre",
		 "intro": "Sous tes pieds, quelque chose d'immense respire. La roche tremble en silence.",
		 "title": "ce qui dort sous les ruines",
		 "effect": "flood_corruption",
		 "trigger_hint": "biome:ruins+corruption>0.6"},
		{"id": &"gallows_parliament",
		 "name": "le Parlement-des-Potences",
		 "intro": "Douze silhouettes pendues votent sur ton sort. Aucune n'a de bouche.",
		 "title": "l'assemblée des morts-jugés",
		 "effect": "judge_every_choice",
		 "trigger_hint": "biome:city+elite_killed"},
		{"id": &"silent_orchestra",
		 "name": "l'Orchestre-Muet",
		 "intro": "Cent instruments tenus par personne. Pas un son. Tu entends pourtant la musique.",
		 "title": "la symphonie qui dévore les langues",
		 "effect": "disable_dialogue",
		 "trigger_hint": "biome:corrupted+intel>80"},
		{"id": &"that_which_dreams_us",
		 "name": "Ce-Qui-Nous-Rêve",
		 "intro": "Tu comprends, trop tard, que tu n'es pas celui qui regarde. Tu es le rêve.",
		 "title": "le rêveur dont nous sommes le songe",
		 "effect": "invert_outcomes",
		 "trigger_hint": "final_zone+runs_completed>=5"},
		{"id": &"drowning_god",
		 "name": "le Dieu-Noyé",
		 "intro": "L'eau du monde se met à respirer. Quelque chose remonte. Quelque chose qui a toujours été là.",
		 "title": "l'ancien sous toutes les marées",
		 "effect": "drown_zone",
		 "trigger_hint": "biome:coast/swamp/corrupted + final_zone + runs>=2"},
	]

static func pick(rng: DRNG) -> Dictionary:
	var arr: Array = templates()
	return arr[rng.range_i(0, arr.size())]

static func by_id(id: StringName) -> Dictionary:
	for t in templates():
		if t.id == id: return t
	return {}
