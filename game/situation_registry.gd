class_name SituationRegistry extends RefCounted
# Non-creature events: discoveries, hazards, shrines, strangers.
# Each situation has 3 choice templates (tone, text), per-tone outcomes, and biome filters.

const T_AGGR := 0
const T_DIPL := 1
const T_CAUT := 2
const T_CURI := 3
const T_DECE := 4
const T_MYST := 5

static func all() -> Array:
	return [
		# --- DISCOVERY: ancient inscription ---
		{"id": &"inscription",
		 "title": "Une pierre couverte de signes.",
		 "biomes": [&"ruins", &"crypt", &"forest", &"highland"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu traces les signes du doigt.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Un mot ancien s'éclaire en toi. Tu sais quelque chose de plus."},
			 "bad":  {"injury": &"curse", "narr": "Le signe te répond. Quelque chose s'est inscrit dans ta peau."}},
			{"tone": T_MYST, "text": "Tu murmures les signes à voix basse.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "La pierre frémit. Tu reçois plus que tu n'as donné."},
			 "bad":  {"injury": &"terror", "narr": "Quelque chose t'a écouté. Tu n'aurais pas dû."}},
			{"tone": T_CAUT, "text": "Tu passes ton chemin sans la toucher.",
			 "good": {"narr": "Tu pars en silence. Quelque chose te suit du regard sans bouger."},
			 "bad":  {"narr": "Le signe t'appelle malgré toi. Tu détournes les yeux à temps."}},
		 ]},

		# --- HAZARD: collapsing path ---
		{"id": &"collapse",
		 "title": "Le sol cède sous tes pieds.",
		 "biomes": [&"ruins", &"crypt", &"corrupted", &"highland", &"city"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu sautes vers le rebord, calculé.",
			 "good": {"narr": "Tu retombes en sécurité. Le souffle te revient."},
			 "bad":  {"injury": &"broken_arm", "narr": "Tu rates le rebord. Quelque chose craque dans ton bras."}},
			{"tone": T_AGGR, "text": "Tu fonces avant que ça lâche complètement.",
			 "good": {"narr": "Tu traverses au moment où la pierre cède. Tu cours encore après."},
			 "bad":  {"injury": &"bleeding", "narr": "Une arête te déchire la cuisse au passage."}},
			{"tone": T_CURI, "text": "Tu te laisses descendre pour voir ce qui est dessous.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Sous le passage tu trouves quelque chose d'utile."},
			 "bad":  {"injury": &"exhaustion", "narr": "Le fond est plus profond que prévu. Tu remontes vidé."}},
		 ]},

		# --- SHRINE: silent altar ---
		{"id": &"shrine",
		 "title": "Un autel oublié, encore tiède.",
		 "biomes": [&"forest", &"ruins", &"crypt", &"highland", &"swamp"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu poses une main sur la pierre, en silence.",
			 "good": {"heal": &"bleeding", "narr": "Une chaleur passe. Une de tes plaies se referme proprement."},
			 "bad":  {"narr": "Rien ne se passe. L'autel a déjà reçu plus qu'il ne pouvait rendre."}},
			{"tone": T_MYST, "text": "Tu offres une goutte de sang à la rainure.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Quelque chose accepte. Le monde te paraît plus net."},
			 "bad":  {"injury": &"curse", "narr": "Quelque chose accepte trop avidement. Tu sens un poids nouveau."}},
			{"tone": T_AGGR, "text": "Tu brises la pierre d'un coup sec.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Sous la pierre, un fragment utile. Tu l'empoches."},
			 "bad":  {"injury": &"terror", "narr": "Sous la pierre, un œil. Il te regarde. Tu recules."}},
		 ]},

		# --- STRANGER: hooded merchant ---
		{"id": &"stranger",
		 "title": "Une silhouette encapuchonnée tend une bourse.",
		 "biomes": [&"forest", &"city", &"ruins", &"highland", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu acceptes le don, en remerciant.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "La bourse contient juste ce qu'il te fallait."},
			 "bad":  {"injury": &"curse", "narr": "La bourse était un cadeau. Le contrat n'était pas écrit."}},
			{"tone": T_DECE, "text": "Tu prends la bourse et files.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Tu disparais avec ce qu'il t'a tendu. Personne ne crie."},
			 "bad":  {"injury": &"bleeding", "narr": "Quelque chose te frappe le dos pendant ta fuite."}},
			{"tone": T_CAUT, "text": "Tu refuses, poliment, et passes ton chemin.",
			 "good": {"narr": "La silhouette s'incline et disparaît dans le brouillard."},
			 "bad":  {"narr": "Quand tu te retournes, il n'est déjà plus là. Tu n'es pas sûr qu'il ait existé."}},
		 ]},

		# --- HAZARD: storm ---
		{"id": &"storm",
		 "title": "Un orage te tombe dessus, brutal.",
		 "biomes": [&"highland", &"coast", &"forest", &"anomaly"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu te terres sous une avancée de pierre.",
			 "good": {"narr": "Tu attends que ça passe. Le monde sent le mouillé et le brûlé."},
			 "bad":  {"injury": &"exhaustion", "narr": "L'orage dure plus longtemps que ta patience."}},
			{"tone": T_AGGR, "text": "Tu marches dedans, tête baissée.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu en sors trempé mais durci."},
			 "bad":  {"injury": &"bleeding", "narr": "La grêle te fend la lèvre, l'arcade, le cuir."}},
			{"tone": T_MYST, "text": "Tu lèves les bras et appelles le vent.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Le vent t'écoute. Brièvement. Mais il t'écoute."},
			 "bad":  {"injury": &"terror", "narr": "Le vent te répond. Il dit ton nom."}},
		 ]},

		# --- DISCOVERY: blood trail ---
		{"id": &"blood_trail",
		 "title": "Une traînée de sang frais part vers les arbres.",
		 "biomes": [&"forest", &"swamp", &"ruins", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu suis la trace, en silence.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Au bout, un cadavre frais. Et quelque chose d'utile sur lui."},
			 "bad":  {"injury": &"terror", "narr": "Au bout, la chose qui a saigné. Toujours vivante. Mauvaise."}},
			{"tone": T_DECE, "text": "Tu effaces la trace pour qu'on ne te suive pas.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Personne ne te trouvera ici. C'est une bonne chose."},
			 "bad":  {"injury": &"exhaustion", "narr": "Effacer prend du temps. Trop de temps."}},
			{"tone": T_CAUT, "text": "Tu prends la direction opposée.",
			 "good": {"narr": "Tu t'éloignes. Bien plus tard, tu entends quelque chose hurler là-bas."},
			 "bad":  {"narr": "Tu t'éloignes. Mais la trace est aussi devant toi maintenant."}},
		 ]},
	]

static func for_biome(biome: StringName) -> Array:
	var out: Array = []
	for s in all():
		if biome in s.biomes: out.append(s)
	return out

static func pick(rng: DRNG, biome: StringName) -> Dictionary:
	var pool: Array = for_biome(biome)
	if pool.is_empty(): pool = all()
	return pool[rng.range_i(0, pool.size())]
