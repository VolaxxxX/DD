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

		# --- WELL: deep, dark water ---
		{"id": &"deep_well",
		 "title": "Un puits creusé droit dans la pierre. L'eau est immobile.",
		 "biomes": [&"ruins", &"city", &"crypt", &"highland"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu te penches au bord. Tu vois ton reflet — puis autre chose.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "L'autre visage te dit ce que tu dois savoir, puis disparaît."},
			 "bad":  {"injury": &"curse", "narr": "L'autre visage te sourit. Tu te recules. Trop tard."}},
			{"tone": T_MYST, "text": "Tu murmures ton nom dans le puits.",
			 "good": {"heal": &"exhaustion", "narr": "Le puits te répond avec ta propre voix, plus jeune. Tu retrouves un souffle ancien."},
			 "bad":  {"injury": &"terror", "narr": "Le puits te répond avec ta voix, mais elle dit autre chose que ce que tu as dit."}},
			{"tone": T_CAUT, "text": "Tu jettes une pierre et tu écoutes le fond.",
			 "good": {"narr": "Tu comptes longtemps. Tu apprends la profondeur. Tu pars rassuré."},
			 "bad":  {"narr": "Tu n'entends jamais la pierre toucher le fond."}},
		 ]},

		# --- BEGGAR: starving child ---
		{"id": &"beggar_child",
		 "title": "Un enfant assis sur la route. Maigre. Silencieux.",
		 "biomes": [&"city", &"ruins", &"coast", &"highland"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui donnes la moitié de tes vivres.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il te regarde sans parler. Plus tard, tu trouveras une pièce dans ta poche que tu n'avais pas."},
			 "bad":  {"injury": &"exhaustion", "narr": "Il avale tout en silence puis détale. Tu réalises ce que tu viens de céder."}},
			{"tone": T_DECE, "text": "Tu lui demandes son nom — et tu fouilles son baluchon.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Tu trouves quelque chose de précieux. L'enfant pleure mais ne te suit pas."},
			 "bad":  {"injury": &"curse", "narr": "L'enfant lève les yeux. Ils sont trop vieux. Bien trop vieux."}},
			{"tone": T_CAUT, "text": "Tu fais semblant de ne pas le voir et tu passes.",
			 "good": {"narr": "Tu passes. Tu n'es ni meilleur ni pire qu'avant."},
			 "bad":  {"injury": &"terror", "narr": "Tu sens son regard sur ta nuque pendant des kilomètres."}},
		 ]},

		# --- FORK: two roads ---
		{"id": &"crossroads",
		 "title": "Le chemin se divise. À gauche, le silence. À droite, des oiseaux.",
		 "biomes": [&"forest", &"highland", &"swamp", &"ruins"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu vas vers le silence.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Tu trouves quelque chose qu'on n'avait pas voulu que tu trouves."},
			 "bad":  {"injury": &"terror", "narr": "Le silence n'était pas un silence. C'était une attente."}},
			{"tone": T_CAUT, "text": "Tu vas vers les oiseaux.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu marches dans le chant. La route est sûre, pour aujourd'hui."},
			 "bad":  {"injury": &"bleeding", "narr": "Les oiseaux s'arrêtent net. Ce n'était pas pour toi qu'ils chantaient."}},
			{"tone": T_MYST, "text": "Tu fermes les yeux et tu suis ce qui tire en toi.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Tu prends la troisième route — celle qu'on ne voit qu'en fermant les yeux."},
			 "bad":  {"injury": &"curse", "narr": "Tu marches longtemps. Tu te retrouves au même carrefour. Trois fois."}},
		 ]},

		# --- BURNING TREE: tree on fire, no smoke ---
		{"id": &"burning_tree",
		 "title": "Un arbre brûle. Sans fumée. Sans chaleur.",
		 "biomes": [&"forest", &"highland", &"anomaly", &"corrupted"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu poses la main sur l'écorce. La flamme passe à travers toi.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu sens un savoir vieux te traverser. Tu n'oseras pas le partager."},
			 "bad":  {"injury": &"curse", "narr": "La flamme te traverse, oui. Mais elle laisse quelque chose en passant."}},
			{"tone": T_AGGR, "text": "Tu abats l'arbre. La flamme cesse net.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "L'arbre tombe en silence. La flamme s'éteint. Le monde semble plus simple."},
			 "bad":  {"injury": &"bleeding", "narr": "L'arbre saigne. Pas de la sève. Du sang. Il te frappe au passage."}},
			{"tone": T_CAUT, "text": "Tu détournes le regard et continues.",
			 "good": {"narr": "Tu pars. Plus tard, tu ne sauras plus dire si tu l'as vraiment vu."},
			 "bad":  {"injury": &"terror", "narr": "Tu pars. L'arbre marche derrière toi pendant six pas. Tu n'oses pas te retourner."}},
		 ]},

		# --- ANIMAL CARCASS: still warm ---
		{"id": &"warm_carcass",
		 "title": "Une carcasse encore tiède. Aucune trace autour.",
		 "biomes": [&"forest", &"highland", &"swamp", &"corrupted"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu examines les plaies. Ce qui a tué cela n'est pas une bête.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu comprends quelque chose sur le tueur. Tu saluras peut-être l'éviter."},
			 "bad":  {"injury": &"terror", "narr": "Tu comprends quelque chose sur le tueur. Tu n'aurais pas dû."}},
			{"tone": T_AGGR, "text": "Tu prends la viande. Tant pis pour le reste.",
			 "good": {"heal": &"exhaustion", "narr": "Tu manges. Tu repars plus solide. C'est ce qu'il fallait."},
			 "bad":  {"injury": &"poison", "narr": "Tu manges. Quelque chose dans la chair n'aurait pas dû être mangé."}},
			{"tone": T_CAUT, "text": "Tu pars sans toucher. Tu pars vite.",
			 "good": {"narr": "Tu pars. C'est probablement la meilleure décision que tu aies prise aujourd'hui."},
			 "bad":  {"narr": "Tu pars. Quelque chose te suit du regard depuis l'arbre voisin."}},
		 ]},

		# --- DOUBLE: someone who looks like you ---
		{"id": &"the_double",
		 "title": "Au bout du chemin, quelqu'un. Il a ton visage.",
		 "biomes": [&"anomaly", &"corrupted", &"swamp", &"crypt"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu l'attaques sans hésiter. Il n'y a pas de place pour deux toi.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu le frappes. Il s'effrite comme du verre noir. Tu emportes un éclat."},
			 "bad":  {"injury": &"bleeding", "narr": "Tu frappes ton propre visage. Tu sens la coupure sur le tien."}},
			{"tone": T_DIPL, "text": "Tu lui parles. Tu lui demandes qui il est.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il te répond doucement. Il t'apprend quelque chose que tu avais oublié."},
			 "bad":  {"injury": &"curse", "narr": "Il répète chacun de tes mots, à l'envers. Puis il prend ton ombre."}},
			{"tone": T_CAUT, "text": "Tu détournes les yeux et tu passes très loin de lui.",
			 "good": {"narr": "Tu passes. Il reste là, immobile. Tu ne te retournes pas."},
			 "bad":  {"injury": &"terror", "narr": "Tu passes. Tu sens qu'il a pris ta place dans le chemin que tu viens de quitter."}},
		 ]},

		# --- BROKEN STATUE: half-buried saint ---
		{"id": &"broken_statue",
		 "title": "Une statue brisée à demi enterrée. Le visage manque.",
		 "biomes": [&"ruins", &"crypt", &"city", &"forest"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu redresses ce que tu peux. Tu nettoies la pierre.",
			 "good": {"heal": &"terror", "narr": "Tu fais un geste petit, juste. Quelque chose en toi se réaligne."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu travailles longtemps. Tu ne sais plus pourquoi. Tu n'as rien gagné."}},
			{"tone": T_DECE, "text": "Tu cherches dans le socle. Les statues cachent souvent.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Tu trouves un creux. Dans le creux, quelque chose qu'on avait laissé pour toi."},
			 "bad":  {"injury": &"curse", "narr": "Tu trouves un creux. Quelque chose y était. Maintenant ça te suit."}},
			{"tone": T_MYST, "text": "Tu poses ton front contre la pierre. Tu écoutes.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "La pierre te raconte la guerre qu'elle a vue. C'était il y a longtemps."},
			 "bad":  {"injury": &"terror", "narr": "La pierre se souvient. Elle veut que tu te souviennes aussi."}},
		 ]},

		# --- BURIED PILGRIM: bones half-buried in mud ---
		{"id": &"buried_pilgrim",
		 "title": "Des ossements à moitié enfouis tiennent encore un pendentif.",
		 "biomes": [&"swamp", &"corrupted", &"ruins", &"crypt", &"forest"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu déterres le pendentif. Il est tiède.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Le pendentif réveille un savoir ancien. Tu comprends pourquoi il marchait ici."},
			 "bad":  {"injury": &"curse", "narr": "Le pendentif s'ouvre. Quelque chose à l'intérieur te regarde avant que tu refermes."}},
			{"tone": T_DIPL, "text": "Tu prononces une bénédiction et laisses tout en place.",
			 "good": {"heal": &"terror", "narr": "Une paix te traverse. Tu portes une crainte de moins."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tes mots se perdent. Tu pries trop longtemps. Le froid te prend."}},
			{"tone": T_AGGR, "text": "Tu arraches le pendentif d'un geste sec.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu l'as. Il pèse plus lourd que sa taille."},
			 "bad":  {"injury": &"bleeding", "narr": "Une racine cassée te griffe le bras. Ce n'était peut-être pas une racine."}},
		 ]},

		# --- DOOR: an iron door that should not be here ---
		{"id": &"iron_door",
		 "title": "Une porte de fer scellée se dresse, là où rien ne devrait être.",
		 "biomes": [&"forest", &"highland", &"anomaly", &"corrupted"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu cognes l'épaule contre. Une fois. Encore.",
			 "good": {"stat_delta": 2, "stat": &"force", "narr": "La serrure cède. Derrière : un vide qui sent l'or. Tu repars chargé."},
			 "bad":  {"injury": &"broken_arm", "narr": "Quelque chose dans ton bras a cédé avant la porte."}},
			{"tone": T_MYST, "text": "Tu poses la paume et écoutes ce qui dort derrière.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Ce qui dort derrière te confie un nom. Tu le gardes."},
			 "bad":  {"injury": &"curse", "narr": "Ce qui dort derrière s'est réveillé. Il te suit, désormais."}},
			{"tone": T_CAUT, "text": "Tu fais demi-tour sans avoir touché la porte.",
			 "good": {"narr": "Tu pars. La porte n'est plus là quand tu te retournes. Tant mieux."},
			 "bad":  {"narr": "Tu pars. Mais tu sais que tu reviendras. Tu sais déjà quand."}},
		 ]},

		# --- LOST MERCENARY: wounded fellow traveler ---
		{"id": &"wounded_merc",
		 "title": "Un mercenaire blessé tend une main vers toi.",
		 "biomes": [&"forest", &"city", &"ruins", &"highland", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu t'agenouilles et bandes sa plaie.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il te confie sa lame avant de fermer les yeux. Tu y gagnes plus que tu ne penses."},
			 "bad":  {"injury": &"bleeding", "narr": "En te penchant, tu glisses. Sa lame tombe et te marque la cuisse."}},
			{"tone": T_DECE, "text": "Tu fouilles déjà ses poches en lui parlant doucement.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Tu trouves trois pièces, une carte, un sceau. Il n'a rien vu."},
			 "bad":  {"injury": &"curse", "narr": "Sa main s'agrippe à ton poignet, plus forte qu'elle ne devrait. Il chuchote un mot."}},
			{"tone": T_AGGR, "text": "Tu écourtes sa souffrance d'un coup net.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "C'était la chose juste à faire. Tu emportes son anneau."},
			 "bad":  {"injury": &"terror", "narr": "Ses yeux ne te quittent pas. Tu les vois encore quand tu fermes les tiens."}},
		 ]},

		# --- TWO ROADS: a fork with a cold wind from one side ---
		{"id": &"cold_fork",
		 "title": "Deux chemins. Le vent ne souffle que par l'un.",
		 "biomes": [&"forest", &"highland", &"coast", &"swamp", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu prends celui qui souffle. Tu veux savoir d'où vient le vent.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Au bout, un belvédère silencieux. Tu comprends une chose que personne ne devrait."},
			 "bad":  {"injury": &"terror", "narr": "Au bout, ce qui soufflait. Il avait une bouche. Il t'a vu."}},
			{"tone": T_CAUT, "text": "Tu prends l'autre. Sans vent, sans surprise.",
			 "good": {"heal": &"exhaustion", "narr": "Le chemin est doux. Tu reprends des forces."},
			 "bad":  {"narr": "Le chemin est si calme que tu doutes de l'avoir choisi. Tu marches longtemps."}},
			{"tone": T_MYST, "text": "Tu poses une question au croisement, à voix haute.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Le carrefour te répond — d'un côté, par le vent ; de l'autre, par le silence. Tu sais lequel prendre."},
			 "bad":  {"injury": &"curse", "narr": "Le carrefour t'a entendu. Il propose une troisième route. Tu en sors, plus tard, sans souvenir de ce qui s'y trouvait."}},
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
