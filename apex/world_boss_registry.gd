class_name WorldBossRegistry extends RefCounted
# Six mythic world bosses. Rare manifestations — last-zone events.
# Player-facing strings are localized: "name"/"intro"/"title" (fr) + "_en"/"_id".

static func templates() -> Array:
	return [
		{"id": &"prismatic_ascendant",
		 "name": "l'Ascendant-Prismatique",
		 "name_en": "the Prismatic Ascendant",
		 "name_id": "sang Prismatik Agung",
		 "intro": "La lumière se plie sans source. Toutes les ombres pointent vers toi.",
		 "intro_en": "Light bends without a source. Every shadow points toward you.",
		 "intro_id": "Cahaya membelok tanpa sumber. Semua bayangan menunjuk ke arahmu.",
		 "title": "Celui-qui-a-été-tous-les-dragons",
		 "title_en": "He-Who-Was-All-Dragons",
		 "title_id": "Dia-yang-Pernah-Menjadi-Semua-Naga",
		 "effect": "all_tones_mixed",
		 "trigger_hint": "biome:anomaly+corruption>0.7"},
		{"id": &"nameless_sovereign",
		 "name": "le Souverain-Sans-Nom",
		 "name_en": "the Nameless Sovereign",
		 "name_id": "sang Penguasa Tanpa Nama",
		 "intro": "Un trône vide te regarde. Tu as oublié ton propre nom pour un instant.",
		 "intro_en": "An empty throne watches you. For a moment, you forgot your own name.",
		 "intro_id": "Sebuah takhta kosong menatapmu. Sesaat tadi, kau lupa namamu sendiri.",
		 "title": "roi des choses qui n'ont jamais existé",
		 "title_en": "king of things that never existed",
		 "title_id": "raja segala hal yang tak pernah ada",
		 "effect": "strip_memory",
		 "trigger_hint": "runs_completed>=3"},
		{"id": &"sea_beneath_stone",
		 "name": "la Mer-Sous-Pierre",
		 "name_en": "the Sea-Beneath-Stone",
		 "name_id": "sang Laut di Bawah Batu",
		 "intro": "Sous tes pieds, quelque chose d'immense respire. La roche tremble en silence.",
		 "intro_en": "Beneath your feet, something immense breathes. The rock trembles in silence.",
		 "intro_id": "Di bawah kakimu, sesuatu yang mahabesar bernapas. Batu bergetar dalam diam.",
		 "title": "ce qui dort sous les ruines",
		 "title_en": "that which sleeps beneath the ruins",
		 "title_id": "yang tertidur di bawah reruntuhan",
		 "effect": "flood_corruption",
		 "trigger_hint": "biome:ruins+corruption>0.6"},
		{"id": &"gallows_parliament",
		 "name": "le Parlement-des-Potences",
		 "name_en": "the Gallows Parliament",
		 "name_id": "sang Majelis Tiang Gantungan",
		 "intro": "Douze silhouettes pendues votent sur ton sort. Aucune n'a de bouche.",
		 "intro_en": "Twelve hanged figures vote on your fate. None of them has a mouth.",
		 "intro_id": "Dua belas sosok tergantung memungut suara atas nasibmu. Tak satu pun punya mulut.",
		 "title": "l'assemblée des morts-jugés",
		 "title_en": "the assembly of the judged dead",
		 "title_id": "majelis arwah yang dihakimi",
		 "effect": "judge_every_choice",
		 "trigger_hint": "biome:city+elite_killed"},
		{"id": &"silent_orchestra",
		 "name": "l'Orchestre-Muet",
		 "name_en": "the Silent Orchestra",
		 "name_id": "sang Orkestra Bisu",
		 "intro": "Cent instruments tenus par personne. Pas un son. Tu entends pourtant la musique.",
		 "intro_en": "A hundred instruments held by no one. Not a sound. And yet you hear the music.",
		 "intro_id": "Seratus alat musik tanpa pemegang. Tak ada suara. Namun kau mendengar musiknya.",
		 "title": "la symphonie qui dévore les langues",
		 "title_en": "the symphony that devours tongues",
		 "title_id": "simfoni pelahap segala bahasa",
		 "effect": "disable_dialogue",
		 "trigger_hint": "biome:corrupted+intel>80"},
		{"id": &"that_which_dreams_us",
		 "name": "Ce-Qui-Nous-Rêve",
		 "name_en": "That-Which-Dreams-Us",
		 "name_id": "Yang-Memimpikan-Kita",
		 "intro": "Tu comprends, trop tard, que tu n'es pas celui qui regarde. Tu es le rêve.",
		 "intro_en": "You understand, too late, that you are not the one watching. You are the dream.",
		 "intro_id": "Kau mengerti, terlambat, bahwa bukan kau yang sedang menonton. Kaulah mimpinya.",
		 "title": "le rêveur dont nous sommes le songe",
		 "title_en": "the dreamer whose dream we are",
		 "title_id": "sang pemimpi yang memimpikan kita semua",
		 "effect": "invert_outcomes",
		 "trigger_hint": "final_zone+runs_completed>=5"},
		{"id": &"drowning_god",
		 "name": "le Dieu-Noyé",
		 "name_en": "the Drowned God",
		 "name_id": "sang Dewa Tenggelam",
		 "intro": "L'eau du monde se met à respirer. Quelque chose remonte. Quelque chose qui a toujours été là.",
		 "intro_en": "The world's water begins to breathe. Something rises. Something that was always there.",
		 "intro_id": "Air dunia mulai bernapas. Sesuatu naik ke permukaan. Sesuatu yang selalu ada di sana.",
		 "title": "l'ancien sous toutes les marées",
		 "title_en": "the ancient beneath all tides",
		 "title_id": "yang purba di bawah segala pasang",
		 "effect": "drown_zone",
		 "trigger_hint": "biome:coast/swamp/corrupted + final_zone + runs>=2"},
	]

# ---------- localized accessors (FR canonical fallback) ----------

static func _loc(d: Dictionary, field: String) -> String:
	if Lang.code == "fr": return String(d.get(field, ""))
	return String(d.get(field + "_" + Lang.code, d.get(field, "")))

static func name_of(d: Dictionary) -> String:
	return _loc(d, "name")

static func intro_of(d: Dictionary) -> String:
	return _loc(d, "intro")

static func title_of(d: Dictionary) -> String:
	return _loc(d, "title")

static func pick(rng: DRNG) -> Dictionary:
	var arr: Array = templates()
	return arr[rng.range_i(0, arr.size())]

static func by_id(id: StringName) -> Dictionary:
	for t in templates():
		if t.id == id: return t
	return {}
