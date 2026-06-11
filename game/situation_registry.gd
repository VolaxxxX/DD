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

		# --- CAGED BEAST ---
		{"id": &"caged_beast",
		 "title": "Un loup blessé, pris dans une cage de fer. Les barreaux sont rouillés.",
		 "biomes": [&"forest", &"highland", &"swamp", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui parles doucement, le temps de comprendre le mécanisme.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Le loup s'éloigne sans un grognement. Il reviendra peut-être te défendre un jour."},
			 "bad":  {"injury": &"bleeding", "narr": "Tu approches trop. Sa mâchoire claque, plus rapide que ta main."}},
			{"tone": T_AGGR, "text": "Tu enfonces la cage à coup de pierre.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "La cage cède. Le loup file. Tu trouves quelques pièces dans le piège."},
			 "bad":  {"injury": &"broken_arm", "narr": "La pierre ricoche. Quelque chose dans ton poignet a cédé avant la cage."}},
			{"tone": T_CAUT, "text": "Tu passes ton chemin. Ce n'est pas ton combat.",
			 "good": {"narr": "Le loup te suit du regard. Tu ne sais pas si c'est rancune ou souvenir."},
			 "bad":  {"injury": &"terror", "narr": "Plus tard, dans la nuit, tu entends un hurlement. Il dit ton nom."}},
		 ]},

		# --- BURNING LIBRARY ---
		{"id": &"burning_library",
		 "title": "Une bibliothèque en ruines. Quelques livres fument encore. Une page intacte vole vers toi.",
		 "biomes": [&"ruins", &"city", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu rattrapes la page et la lis avant qu'elle ne s'éteigne.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Trois mots. Un nom. Une date. Tu sais désormais quelque chose que les vivants ont oublié."},
			 "bad":  {"injury": &"curse", "narr": "Les mots t'entrent dans la peau et y restent. Ils saignent quand tu réfléchis."}},
			{"tone": T_AGGR, "text": "Tu te précipites pour sauver d'autres livres.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu en sors la moitié d'une étagère, brûlé mais riche."},
			 "bad":  {"injury": &"bleeding", "narr": "Le toit s'effondre. Tu sors à quatre pattes, le dos déchiré."}},
			{"tone": T_MYST, "text": "Tu laisses la cendre te parler.",
			 "good": {"heal": &"curse", "narr": "Les voix te traversent et t'allègent. Une malédiction part avec la fumée."},
			 "bad":  {"injury": &"terror", "narr": "Mille voix te crient le même mot. Ce n'est pas le tien."}},
		 ]},

		# --- FERRYMAN ---
		{"id": &"ferryman",
		 "title": "Un passeur silencieux te tend la main. Sa barque ne touche pas tout à fait l'eau.",
		 "biomes": [&"swamp", &"coast", &"ruins", &"corrupted"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu paies en pièces, poliment, sans poser de question.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "L'autre rive arrive plus vite que prévu. Tu gagnes du temps."},
			 "bad":  {"injury": &"curse", "narr": "Au moment où tu poses pied à terre, il manque quelque chose en toi. Une année peut-être."}},
			{"tone": T_DECE, "text": "Tu lui glisses des pièces de plomb peintes.",
			 "good": {"stat_delta": 2, "stat": &"charisme", "narr": "Il sourit, range les pièces sans regarder. Tu repars plus riche."},
			 "bad":  {"injury": &"terror", "narr": "Il se retourne au milieu de l'eau. Il connaît chacun de tes mensonges."}},
			{"tone": T_MYST, "text": "Tu lui offres ton nom au lieu de l'argent.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il accepte. Tu traverses, allégé d'un nom. Il t'en restera d'autres."},
			 "bad":  {"injury": &"curse", "narr": "Il prend le nom et le garde. Tu te souviendras des conséquences plus tard."}},
		 ]},

		# --- HANGING CAGE ---
		{"id": &"hanging_cage",
		 "title": "Une cage suspendue à un arbre. Un homme à l'intérieur. Vivant.",
		 "biomes": [&"city", &"ruins", &"highland", &"forest"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui demandes pourquoi.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il t'apprend trois choses sur cette terre que tu ne savais pas."},
			 "bad":  {"injury": &"terror", "narr": "Il rit, longtemps. Tu n'oublies pas ce rire."}},
			{"tone": T_AGGR, "text": "Tu coupes la corde.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Il s'écroule, te remercie, te tend un anneau et s'enfuit."},
			 "bad":  {"injury": &"bleeding", "narr": "La cage tombe. Sur toi. Le bras de l'homme aussi."}},
			{"tone": T_CAUT, "text": "Tu fais demi-tour avant qu'il te voie.",
			 "good": {"narr": "Tu pars en silence. Lui ne bouge pas."},
			 "bad":  {"narr": "Tu le vois te regarder dans ton rêve, cette nuit-là."}},
		 ]},

		# --- DOLL ON THE PATH ---
		{"id": &"path_doll",
		 "title": "Une poupée d'enfant, posée droite au milieu du chemin. Les yeux sont peints.",
		 "biomes": [&"forest", &"crypt", &"corrupted", &"ruins"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu te penches pour l'examiner.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Sous la poupée, une trappe minuscule. Sous la trappe, quelque chose d'utile."},
			 "bad":  {"injury": &"curse", "narr": "Les yeux clignent. Une fois. Tu pars. Tu te retournes. Elle n'est plus là."}},
			{"tone": T_AGGR, "text": "Tu lui marches dessus en passant.",
			 "good": {"narr": "Rien. Juste un craquement de porcelaine."},
			 "bad":  {"injury": &"terror", "narr": "Quelque chose crie dans ta tête. Une voix d'enfant. La tienne, peut-être."}},
			{"tone": T_MYST, "text": "Tu prononces son nom — celui que tu n'as pas appris.",
			 "good": {"heal": &"terror", "narr": "La poupée s'incline doucement. Une crainte ancienne te quitte."},
			 "bad":  {"injury": &"curse", "narr": "Tu as prononcé le bon nom. Maintenant elle sait le tien."}},
		 ]},

		# --- BEAR TRAP ---
		{"id": &"bear_trap",
		 "title": "Un piège à ours, mâchoires ouvertes. Il y a encore du sang dessus, frais.",
		 "biomes": [&"forest", &"highland", &"swamp"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu le contournes en marquant l'endroit.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu apprends à lire ce genre de trace. Tu en éviteras d'autres."},
			 "bad":  {"narr": "Tu te dis que tu te souviendras. Tu te souviendras à moitié."}},
			{"tone": T_CURI, "text": "Tu le désamorces avec une branche pour l'examiner.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Le mécanisme est ingénieux. Tu apprends à en fabriquer un."},
			 "bad":  {"injury": &"broken_arm", "narr": "La branche cède plus vite que prévu. Le piège mord ton avant-bras."}},
			{"tone": T_AGGR, "text": "Tu déclenches le piège d'un coup de pied.",
			 "good": {"narr": "Bruyant mais sûr. Tu repars sans dommage."},
			 "bad":  {"injury": &"bleeding", "narr": "Un éclat de métal te coupe la cuisse."}},
		 ]},

		# --- ECHO CAVE ---
		{"id": &"echo_cave",
		 "title": "Une bouche de pierre. À l'intérieur, ton propre écho répond avec une seconde de retard.",
		 "biomes": [&"highland", &"ruins", &"crypt", &"anomaly"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu cries ton nom. Tu écoutes ce qu'on te renvoie.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "L'écho dit ton nom — puis trois autres. Tu comprends qui tu as oublié."},
			 "bad":  {"injury": &"curse", "narr": "L'écho dit ton nom — puis le nom de ta mort. Tu le retiens malgré toi."}},
			{"tone": T_MYST, "text": "Tu chantes le silence — quatre notes que personne ne t'a apprises.",
			 "good": {"heal": &"terror", "narr": "La caverne reprend ton chant. Quelque chose en toi se dénoue."},
			 "bad":  {"injury": &"exhaustion", "narr": "Le chant continue après que tu t'es tu. Tu repars vidé."}},
			{"tone": T_DECE, "text": "Tu cries un faux nom pour voir si la caverne suit.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Elle suit. Tu apprends qu'elle est bête. C'est précieux à savoir."},
			 "bad":  {"injury": &"terror", "narr": "Elle ne suit pas. Elle crie le vrai nom à la place. Et ricane."}},
		 ]},

		# --- ANCIENT GATE ---
		{"id": &"ancient_gate",
		 "title": "Une arche de pierre sans porte. De l'autre côté, le paysage n'est pas le même.",
		 "biomes": [&"ruins", &"anomaly", &"highland", &"corrupted"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu traverses.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Tu reviens du même côté, plus tard. Tu sais quelque chose. Tu ne pourras jamais le dire."},
			 "bad":  {"injury": &"curse", "narr": "Tu reviens, mais autrement. Quelque chose te suit, dans ton dos, à un demi-pas."}},
			{"tone": T_CAUT, "text": "Tu jettes un caillou et tu attends.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Le caillou ne revient pas. Tu en sais assez. Tu pars."},
			 "bad":  {"narr": "Le caillou revient — chaud. Tu pars vite, mais pas assez."}},
			{"tone": T_MYST, "text": "Tu poses la main sur l'arche.",
			 "good": {"heal": &"exhaustion", "narr": "Quelque chose de très ancien te répond. Tu repars allégé."},
			 "bad":  {"injury": &"curse", "narr": "Quelque chose de très ancien te connaît, désormais."}},
		 ]},

		# --- LOST LETTER ---
		{"id": &"lost_letter",
		 "title": "Une lettre tachée de pluie, encore lisible. L'écriture tremble. Elle t'est adressée.",
		 "biomes": [&"forest", &"city", &"ruins", &"coast", &"highland", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu la lis jusqu'au bout.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Quelqu'un, quelque part, a deviné que tu viendrais ici."},
			 "bad":  {"injury": &"terror", "narr": "La lettre est de toi. Plus vieux. Avec un avertissement que tu ne peux plus suivre."}},
			{"tone": T_DECE, "text": "Tu la déchires sans la lire.",
			 "good": {"narr": "Le vent emporte les morceaux. Tu te sens plus léger."},
			 "bad":  {"injury": &"curse", "narr": "L'encre te colle aux doigts. Tu lis le contenu plus tard, en rêve, sans pouvoir t'arrêter."}},
			{"tone": T_DIPL, "text": "Tu la replies et la mets sur une pierre pour la rendre à qui sait.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Trois zones plus loin, quelqu'un te tend une pièce. Pour la lettre, dit-il."},
			 "bad":  {"narr": "Tu la perds en route. Quelqu'un la lira sans doute."}},
		 ]},

		# --- SLEEPING GIANT ---
		{"id": &"sleeping_giant",
		 "title": "Une silhouette colossale endormie au flanc de la colline. Le sol monte et descend avec sa respiration.",
		 "biomes": [&"highland", &"ruins", &"swamp"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu fais un grand détour, sans un bruit.",
			 "good": {"heal": &"terror", "narr": "Tu passes. Le géant continue de respirer. Tu apprends que toutes les peurs ne se réveillent pas."},
			 "bad":  {"injury": &"exhaustion", "narr": "Le détour est plus long que ta patience."}},
			{"tone": T_CURI, "text": "Tu t'approches, pour voir son visage.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Son visage ressemble au tien, en plus vieux. Tu apprends ce que tu deviendras peut-être."},
			 "bad":  {"injury": &"terror", "narr": "Il ouvre un œil. Il te regarde une seconde. Il referme. Tu ne dormiras plus pareil."}},
			{"tone": T_MYST, "text": "Tu murmures un mot près de son oreille.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il sourit dans son sommeil. Il t'enseigne un autre mot. Plus grand."},
			 "bad":  {"injury": &"curse", "narr": "Il t'enseigne un mot. Tu ne pourras plus le dire à voix haute sans qu'il s'éveille."}},
		 ]},

		# --- CURSED COIN ---
		{"id": &"cursed_coin",
		 "title": "Une pièce d'or au creux d'un caillou. Elle brille comme si on venait de la poser.",
		 "biomes": [&"city", &"anomaly", &"forest", &"coast"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu la prends sans hésiter.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Elle pèse étonnamment. Tu repars plus riche. Pour le moment."},
			 "bad":  {"injury": &"curse", "narr": "La pièce te brûle au creux de la main. Elle a maintenant ta marque."}},
			{"tone": T_CAUT, "text": "Tu la regardes longtemps sans la toucher.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu apprends à reconnaître les pièges trop beaux. Tu pars."},
			 "bad":  {"narr": "Tu pars sans la prendre. Elle apparaît dans ta poche, plus tard."}},
			{"tone": T_DECE, "text": "Tu la remplaces par une autre pièce.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Ton tour est joué. Tu gardes la vraie. La suivante prendra la fausse."},
			 "bad":  {"injury": &"curse", "narr": "Tu as cru jouer. Tu n'as fait que choisir un autre piège."}},
		 ]},

		# --- WHISPER IN THE DARK ---
		{"id": &"whisper_dark",
		 "title": "Un murmure dans l'obscurité. Il connaît ton nom. Il dit qu'il a une question à te poser.",
		 "biomes": [&"anomaly", &"corrupted", &"crypt", &"forest"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui dis : pose ta question.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Sa question est simple. Tu connais la réponse depuis longtemps. Tu la dis. Le murmure s'en va, satisfait."},
			 "bad":  {"injury": &"terror", "narr": "Sa question n'a pas de réponse. Tu en fabriques une. Il sait que tu mens."}},
			{"tone": T_AGGR, "text": "Tu hurles dans le noir pour le couvrir.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Ton cri dure plus longtemps que le sien. Tu pars."},
			 "bad":  {"injury": &"exhaustion", "narr": "Quelque chose te répond, deux fois plus fort. Tu pars en titubant."}},
			{"tone": T_CAUT, "text": "Tu fais le mort, immobile.",
			 "good": {"heal": &"terror", "narr": "Le murmure passe à côté. Tu apprends que certaines peurs n'ont pas d'odeur."},
			 "bad":  {"injury": &"curse", "narr": "Il fait le tour de toi, longtemps. Il finit par t'effleurer la nuque."}},
		 ]},

		# --- SNAKE OIL SELLER ---
		{"id": &"snake_oil",
		 "title": "Un marchand sur le bord du chemin propose une fiole 'qui guérit tout'.",
		 "biomes": [&"forest", &"city", &"coast", &"ruins"],
		 "choices": [
			{"tone": T_DECE, "text": "Tu marchandes longuement, en feignant l'intérêt.",
			 "good": {"stat_delta": 2, "stat": &"charisme", "narr": "Il finit par lâcher une vraie fiole, par fatigue. Tu repars avec un véritable remède."},
			 "bad":  {"injury": &"exhaustion", "narr": "Il parle plus que toi, longtemps. Tu repars épuisé sans rien."}},
			{"tone": T_DIPL, "text": "Tu lui demandes ce qu'il y a vraiment dedans.",
			 "good": {"heal": &"bleeding", "narr": "Il rit, te donne la vraie chose qu'il avait gardée pour lui. Une plaie se referme."},
			 "bad":  {"injury": &"poison", "narr": "Il sourit, te tend la fiole. Tu bois. C'était la mauvaise."}},
			{"tone": T_AGGR, "text": "Tu lui prends une fiole et tu pars.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Il ne te poursuit pas. Tu trouves la vraie fiole plus tard."},
			 "bad":  {"injury": &"poison", "narr": "Tu bois pour calmer ta soif. Tu comprends ton erreur trop tard."}},
		 ]},

		# --- FROZEN POOL ---
		{"id": &"frozen_pool",
		 "title": "Un bassin d'eau gelée en plein été. Quelque chose remue, lentement, sous la glace.",
		 "biomes": [&"highland", &"anomaly", &"corrupted", &"swamp"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu casses la glace à grands coups pour voir.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Sous la glace, un poisson, énorme, immobile. Tu repars avec une écaille — utile."},
			 "bad":  {"injury": &"terror", "narr": "Sous la glace, un visage. Ouvert. Te regardant. Tu refermes le trou en vitesse."}},
			{"tone": T_CAUT, "text": "Tu fais le tour, sans le regarder.",
			 "good": {"heal": &"exhaustion", "narr": "Le froid t'enveloppe doucement, te lave. Tu repars rafraîchi."},
			 "bad":  {"narr": "Le tour est plus grand que prévu. Tu marches longtemps."}},
			{"tone": T_MYST, "text": "Tu poses la main sur la glace et tu écoutes.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "La glace te raconte trois hivers. Tu en apprends plus que tu ne croyais possible."},
			 "bad":  {"injury": &"curse", "narr": "La glace boit ta chaleur. Tu retires la main trop tard."}},
		 ]},

		# --- EMPTY SHOES ---
		{"id": &"empty_shoes",
		 "title": "Une paire de petites chaussures, alignées au milieu du chemin. Personne aux alentours.",
		 "biomes": [&"forest", &"city", &"ruins", &"corrupted"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu fais demi-tour sans hésiter.",
			 "good": {"heal": &"terror", "narr": "Tu marches longtemps, mais tu te sens plus léger d'avoir fui une histoire qui n'était pas la tienne."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu marches longtemps. Trop longtemps."}},
			{"tone": T_DIPL, "text": "Tu enterres les chaussures sous une pierre, en murmurant un mot.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Tu pars apaisé. Quelque part, quelque chose te remercie sans bruit."},
			 "bad":  {"injury": &"terror", "narr": "Pendant que tu enterres, tu entends de petits pas autour de toi."}},
			{"tone": T_CURI, "text": "Tu les ramasses et tu cherches le propriétaire.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu trouves un petit village abandonné. Tu y trouves quelque chose d'utile."},
			 "bad":  {"injury": &"curse", "narr": "Tu trouves un enfant qui marche pieds nus. Il te regarde. Tu ne peux plus oublier."}},
		 ]},

		# --- FALLEN COMET ---
		{"id": &"fallen_comet",
		 "title": "Un éclat brûlant tombé du ciel. Le sol fume autour. Il respire, à peine.",
		 "biomes": [&"highland", &"coast", &"forest", &"anomaly"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu le brises pour voir ce qu'il y a dedans.",
			 "good": {"stat_delta": 2, "stat": &"force", "narr": "À l'intérieur, un fragment dur comme l'os, brillant. Tu le glisses dans ta poche."},
			 "bad":  {"injury": &"bleeding", "narr": "Il explose entre tes mains. Une éclat brûlant te déchire la paume."}},
			{"tone": T_MYST, "text": "Tu poses la main dessus pour entendre.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il te raconte d'où il vient. Tu connais maintenant le nom d'une étoile."},
			 "bad":  {"injury": &"curse", "narr": "Il t'inscrit son nom dans la peau. Il brûle longtemps."}},
			{"tone": T_CAUT, "text": "Tu attends qu'il refroidisse pour décider.",
			 "good": {"narr": "Tu repars avec un fragment tiède, plus simple à porter."},
			 "bad":  {"narr": "Il refroidit trop vite. Il n'a plus rien à donner."}},
		 ]},

		# --- MAD VAGABOND ---
		{"id": &"mad_vagabond",
		 "title": "Un vagabond rit seul, parle à un buisson, lui répond. Il tient un petit objet brillant.",
		 "biomes": [&"city", &"ruins", &"forest", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui demandes ce qu'il dit au buisson.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il te dit une chose que personne d'autre n'aurait dit. Cette chose te sera utile."},
			 "bad":  {"injury": &"curse", "narr": "Il te dit une chose que personne ne devrait dire. Tu l'as entendue."}},
			{"tone": T_DECE, "text": "Tu lui dérobes le petit objet pendant qu'il rit.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "L'objet est utile. Il ne s'en rend même pas compte."},
			 "bad":  {"injury": &"terror", "narr": "Il s'arrête de rire. Il te regarde — clair, lucide. Plus jamais tu ne lui auras volé impunément."}},
			{"tone": T_CAUT, "text": "Tu passes ton chemin sans le regarder.",
			 "good": {"narr": "Tu pars. Il continue de rire dans ton dos."},
			 "bad":  {"narr": "Tu pars. Il s'arrête de rire au même instant. Tu ne sais pas pourquoi."}},
		 ]},

		# --- CHARRED MAP ---
		{"id": &"charred_map",
		 "title": "Une carte brûlée sur les bords. Elle représente cette terre — avec des marques que tu n'as jamais vues.",
		 "biomes": [&"forest", &"ruins", &"highland", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu étudies les marques attentivement.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Tu reconnais un endroit, peut-être deux. Cela te servira plus tard."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu y passes trop de temps. Le jour décline avant que tu aies appris quoi que ce soit."}},
			{"tone": T_MYST, "text": "Tu superposes la carte au sol avec un geste rituel.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Le sol s'adapte légèrement à la carte. Tu y vois quelque chose qui n'y était pas avant."},
			 "bad":  {"injury": &"curse", "narr": "Le sol s'adapte trop. Quelque chose attendait que quelqu'un fasse exactement ça."}},
			{"tone": T_CAUT, "text": "Tu la replies et la mets dans ta poche pour plus tard.",
			 "good": {"narr": "Tu décides de réfléchir plus tard. Tu n'y reviendras peut-être jamais."},
			 "bad":  {"narr": "Tu oublies de la lire. La carte disparaît de ta poche, ensuite."}},
		 ]},

		# --- HEAD ON A POLE ---
		{"id": &"head_pole",
		 "title": "Une tête tranchée plantée sur un piquet. Les yeux suivent ton regard quand tu bouges.",
		 "biomes": [&"city", &"ruins", &"corrupted", &"crypt"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui demandes son nom.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Elle te répond. Elle te raconte ce qui s'est passé ici. Tu sauras éviter sa propre erreur."},
			 "bad":  {"injury": &"terror", "narr": "Elle te dit ton nom. Pas le sien. Tu pars vite."}},
			{"tone": T_AGGR, "text": "Tu la fais tomber d'un coup de pied.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Elle roule, se tait. Tu repars en paix."},
			 "bad":  {"injury": &"curse", "narr": "Elle roule en hurlant ton nom. Tu l'entendras encore plus tard."}},
			{"tone": T_MYST, "text": "Tu poses une pièce dans sa bouche.",
			 "good": {"heal": &"curse", "narr": "Elle se tait. Quelque chose de lourd te quitte."},
			 "bad":  {"injury": &"curse", "narr": "Elle avale la pièce et te demande la suivante. Et la suivante."}},
		 ]},

		# --- FESTIVAL LIGHTS ---
		{"id": &"festival_lights",
		 "title": "Au bout d'une rue déserte, des lampions allumés se balancent au-dessus de tables vides. Pas un bruit.",
		 "biomes": [&"city", &"forest", &"coast"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu t'assieds à une table comme si tu étais attendu.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Quelqu'un t'apporte un plat invisible. Tu manges. Quelque chose d'ancien te traverse."},
			 "bad":  {"injury": &"curse", "narr": "Tu manges. Tu te lèves. Tu ne te souviens plus de quelques heures."}},
			{"tone": T_DECE, "text": "Tu chipes une lanterne et tu pars en vitesse.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu repars avec une lanterne qui ne s'éteint jamais."},
			 "bad":  {"injury": &"curse", "narr": "La lanterne te suit. Pour toujours. Tu apprendras à dormir avec."}},
			{"tone": T_CAUT, "text": "Tu fais un large détour, sans entrer dans la rue.",
			 "good": {"narr": "Tu ne sauras jamais ce qui s'est passé là. C'est probablement mieux."},
			 "bad":  {"narr": "Tu rêveras de la rue. Souvent."}},
		 ]},

		# --- BREATHING EARTH ---
		{"id": &"breathing_earth",
		 "title": "Un coin de terre se soulève et redescend, comme une poitrine qui dort. Doucement.",
		 "biomes": [&"corrupted", &"swamp", &"anomaly", &"forest"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu poses ta paume dessus et synchronises ton souffle.",
			 "good": {"heal": &"terror", "narr": "La terre te calme. Une peur ancienne s'apaise."},
			 "bad":  {"injury": &"poison", "narr": "Ton souffle prend le sien. Tu repars un peu malade — la terre, sans doute, va mieux."}},
			{"tone": T_AGGR, "text": "Tu enfonces ta lame dedans pour voir.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Ça saigne — un peu. Tu pars avec une poignée d'une terre brune extraordinaire."},
			 "bad":  {"injury": &"curse", "narr": "Ça saigne — beaucoup. Le sang n'est pas rouge."}},
			{"tone": T_CAUT, "text": "Tu marches en faisant le plus large des cercles autour.",
			 "good": {"narr": "Tu pars. Le silence est total ensuite."},
			 "bad":  {"injury": &"exhaustion", "narr": "Le cercle est plus grand que tu ne l'avais cru. Tu marches jusqu'à la nuit."}},
		 ]},

		# --- CARRIAGE WRECK ---
		{"id": &"carriage_wreck",
		 "title": "Une calèche renversée, les chevaux disparus, une malle ouverte. Du tissu vole encore.",
		 "biomes": [&"forest", &"city", &"highland", &"ruins"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu fouilles la malle.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu y trouves un anneau utile et une lettre intéressante."},
			 "bad":  {"injury": &"bleeding", "narr": "Quelque chose dans la malle te mord la main — un piège mécanique vivace."}},
			{"tone": T_DECE, "text": "Tu remets tout en place comme si tu n'étais jamais venu.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Tu pars avec deux pièces et une excellente conscience."},
			 "bad":  {"narr": "Tu remets bien. Mais tu oublies quelque chose. Tu ne sauras pas quoi."}},
			{"tone": T_CAUT, "text": "Tu cherches les chevaux d'abord.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu trouves un cheval blessé, le soignes, repars avec lui."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu ne les trouves pas. La nuit tombe."}},
		 ]},

		# --- DREAMING FISH ---
		{"id": &"dreaming_fish",
		 "title": "Un poisson immense, échoué sur le sable, vivant. Il ne se débat pas. Il dort. Il rêve.",
		 "biomes": [&"coast", &"swamp", &"anomaly"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu touches son flanc et tu rêves avec lui un instant.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu apprends ce que rêve un être qui n'a jamais connu la peur."},
			 "bad":  {"injury": &"curse", "narr": "Tu apprends son rêve. Il devient le tien. Tu n'es plus sûr d'être réveillé."}},
			{"tone": T_DIPL, "text": "Tu le pousses doucement vers l'eau.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il s'éveille à demi, te regarde, repart. Plus tard, tu trouveras un cadeau sur la plage."},
			 "bad":  {"injury": &"exhaustion", "narr": "Il est plus lourd que tu pensais. Tu y mets toutes tes forces."}},
			{"tone": T_AGGR, "text": "Tu en prélèves un morceau pour manger.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu manges, te rassasies, gardes le reste."},
			 "bad":  {"injury": &"poison", "narr": "Sa chair n'est pas faite pour les vivants. Tu vomis longtemps."}},
		 ]},

		# --- SINGING CROWNS ---
		{"id": &"singing_crowns",
		 "title": "Trois couronnes posées en cercle. Quand le vent souffle, elles chantent — chacune une note.",
		 "biomes": [&"ruins", &"highland", &"crypt", &"anomaly"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu accompagnes leur chant avec ta voix.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu apprends une quatrième note. Personne d'autre ne la connaît."},
			 "bad":  {"injury": &"curse", "narr": "Une couronne se tait quand tu chantes. Tu sais maintenant laquelle."}},
			{"tone": T_AGGR, "text": "Tu en prends une et tu pars.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Elle est lourde. Mais elle pèse moins que ton avenir."},
			 "bad":  {"injury": &"curse", "narr": "Les deux qui restent se mettent à hurler ton nom. Longtemps."}},
			{"tone": T_DIPL, "text": "Tu poses une question aux couronnes.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Elles te répondent l'une après l'autre. Tu sais désormais qui était roi ici."},
			 "bad":  {"narr": "Elles répondent en même temps. Tu ne comprends rien. Tu pars."}},
		 ]},

		# --- NIGHT FIRE: another traveler offers warmth ---
		{"id": &"night_fire",
		 "title": "Un feu au bord du chemin. Un voyageur fait signe : viens t'asseoir.",
		 "biomes": [&"forest", &"highland", &"coast", &"ruins", &"crypt"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu t'assieds. Tu écoutes ce qu'il a à dire.",
			 "good": {"heal": &"exhaustion", "narr": "Vous partagez du pain et trois histoires. Tu repars avec quelque chose dans le ventre et dans la tête."},
			 "bad":  {"injury": &"poison", "narr": "Le pain qu'il te tend a un drôle de goût. Tu ne le remarques qu'après l'avoir mangé."}},
			{"tone": T_DECE, "text": "Tu acceptes l'accueil, mais tu dors avec une main sur ta dague.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu te réveilles tôt. Lui dort encore. Tu emportes ce qui te plaît dans son sac."},
			 "bad":  {"injury": &"bleeding", "narr": "Il se réveille en premier. Il connaissait ce regard."}},
			{"tone": T_CAUT, "text": "Tu remercies et tu campes plus loin.",
			 "good": {"heal": &"exhaustion", "narr": "Tu dors d'un sommeil court mais sûr. Au matin il est parti, sans laisser de traces."},
			 "bad":  {"narr": "Tu campes plus loin. Tu ne dors pas. Tu écoutes le vent toute la nuit."}},
		 ]},

		# --- WILD HERBS: a clearing of medicinal plants ---
		{"id": &"wild_herbs",
		 "title": "Une clairière. Des herbes que tu reconnais — certaines guérissent, certaines tuent.",
		 "biomes": [&"forest", &"swamp", &"highland", &"coast"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu tries patiemment, en suivant ce que tu sais.",
			 "good": {"heal": &"bleeding", "narr": "Tu trouves la bonne combinaison. Une plaie se referme proprement."},
			 "bad":  {"injury": &"poison", "narr": "Tu confonds deux feuilles. Tu t'en rends compte au goût."}},
			{"tone": T_MYST, "text": "Tu laisses ton instinct te guider sans réfléchir.",
			 "good": {"heal": &"terror", "narr": "Tu mâches une feuille. Quelque chose en toi s'apaise."},
			 "bad":  {"injury": &"curse", "narr": "L'instinct n'était pas le tien. Tu mâches ce qu'il fallait pas."}},
			{"tone": T_AGGR, "text": "Tu cueilles tout, tu trieras plus tard.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu repars avec un sac plein. Tu en trouveras l'usage."},
			 "bad":  {"injury": &"exhaustion", "narr": "Cueillir prend du temps. Tu y passes plus qu'il ne fallait."}},
		 ]},

		# --- OLD HUNTER ---
		{"id": &"old_hunter",
		 "title": "Un vieux chasseur, accroupi, pointe le doigt. 'Un sanglier, deux pas plus loin. Tu m'aides ou tu pars.'",
		 "biomes": [&"forest", &"highland", &"swamp"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu acceptes. Tu cours pour le rabattre.",
			 "good": {"stat_delta": 2, "stat": &"force", "narr": "Le sanglier tombe. Le chasseur te donne un quartier de viande et un couteau."},
			 "bad":  {"injury": &"bleeding", "narr": "Le sanglier te charge. Le chasseur arrive trop tard."}},
			{"tone": T_CAUT, "text": "Tu refuses. Tu continues ton chemin.",
			 "good": {"narr": "Tu pars. Plus tard, tu sens le fumet de viande grillée derrière toi. Tu ne regrettes pas."},
			 "bad":  {"narr": "Tu pars. Le chasseur ne dit rien. Il n'oublie pas."}},
			{"tone": T_DIPL, "text": "Tu lui demandes plutôt s'il a vu d'autres voyageurs.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Il te raconte trois rencontres. Tu sais maintenant qui est dans cette terre."},
			 "bad":  {"narr": "Il ne t'écoute pas. Il fixe le buisson. Il s'en va sans répondre."}},
		 ]},

		# --- FRIENDLY RAVEN ---
		{"id": &"friendly_raven",
		 "title": "Un corbeau se pose sur ton épaule. Il ne fuit pas. Il te regarde dans les yeux.",
		 "biomes": [&"forest", &"ruins", &"highland", &"crypt"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui parles, calmement, comme à un voyageur.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il croasse trois fois. Tu comprends chaque croassement. Tu sais quelque chose en plus."},
			 "bad":  {"narr": "Il s'envole sans répondre. Tu te demandes ce qu'il aurait dit."}},
			{"tone": T_DECE, "text": "Tu lui tends une miette empoisonnée pour voir.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Il refuse. Tu apprends qu'il était plus sage que toi. Tu pars en silence."},
			 "bad":  {"injury": &"curse", "narr": "Il accepte. Il avale. Il te regarde, longtemps, avant de tomber. Tu le portes avec toi."}},
			{"tone": T_CURI, "text": "Tu le suis quand il s'envole.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Il te mène à un raccourci. Tu gagnes des heures."},
			 "bad":  {"injury": &"exhaustion", "narr": "Il te mène loin, puis disparaît. Tu rebrouusses chemin."}},
		 ]},

		# --- SEA CAVE TREASURE ---
		{"id": &"sea_cave",
		 "title": "Une grotte marine. Le sable scintille — du métal, peut-être. La marée monte.",
		 "biomes": [&"coast"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu plonges la main dans le sable.",
			 "good": {"stat_delta": 2, "stat": &"force", "narr": "Une poignée de pièces anciennes. Et un anneau qui ne se ternit pas."},
			 "bad":  {"injury": &"bleeding", "narr": "Quelque chose te mord la main — un crabe énorme, caché."}},
			{"tone": T_CAUT, "text": "Tu attends que la marée parte pour voir mieux.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Quand l'eau se retire, tu vois exactement quoi prendre."},
			 "bad":  {"injury": &"exhaustion", "narr": "La marée prend son temps. La nuit te surprend."}},
			{"tone": T_MYST, "text": "Tu chantes pour la mer avant de toucher quoi que ce soit.",
			 "good": {"heal": &"curse", "narr": "L'eau t'écoute. Tu repars allégé d'une malédiction et avec un coquillage utile."},
			 "bad":  {"injury": &"terror", "narr": "L'eau monte plus vite que prévu. Tu sors trempé, le cœur battant."}},
		 ]},

		# --- BRACKISH SPRING ---
		{"id": &"brackish_spring",
		 "title": "Une source d'eau saumâtre. Le goût est ignoble. Mais ça reste de l'eau.",
		 "biomes": [&"coast", &"swamp", &"highland"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu en bois prudemment, à petites gorgées.",
			 "good": {"heal": &"exhaustion", "narr": "Tu te désaltères. Ça suffit pour continuer."},
			 "bad":  {"injury": &"poison", "narr": "Le goût n'était pas qu'amer. Tu le sens plus tard."}},
			{"tone": T_CURI, "text": "Tu observes ce qui pousse autour avant de boire.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu vois les marques sur les pierres. La source est plus pure plus haut."},
			 "bad":  {"narr": "Rien d'utile. Tu décides de ne pas boire. Tu repars assoiffé."}},
			{"tone": T_AGGR, "text": "Tu remplis ta gourde et tu pars.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu auras de l'eau pour deux jours. C'est précieux."},
			 "bad":  {"injury": &"poison", "narr": "La gourde se teint en brun. Tu réalises trop tard."}},
		 ]},

		# --- OLD MONK ---
		{"id": &"old_monk",
		 "title": "Un vieux moine balaie un seuil de pierre. Il te regarde sans étonnement.",
		 "biomes": [&"ruins", &"crypt", &"highland", &"forest"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui demandes une bénédiction.",
			 "good": {"heal": &"terror", "narr": "Il pose la main sur ton front. Quelque chose en toi se calme."},
			 "bad":  {"narr": "Il refuse poliment. 'Garde tes peurs. Elles te servent.'"}},
			{"tone": T_DECE, "text": "Tu lui demandes à boire et tu fouilles pendant qu'il s'éloigne.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu trouves deux pièces et un morceau de pain. Il ne s'aperçoit de rien."},
			 "bad":  {"injury": &"curse", "narr": "Tu lèves les yeux. Il te fixe depuis le seuil. Il sait."}},
			{"tone": T_CURI, "text": "Tu lui demandes ce qu'il sait de ces terres.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il te raconte un siècle en quatre phrases. Tu comprends mieux ce qui t'attend."},
			 "bad":  {"narr": "Il sourit, ne dit rien. Tu repars avec tes questions."}},
		 ]},

		# --- WANDERING SCHOLAR ---
		{"id": &"scholar",
		 "title": "Un érudit ambulant ouvre un coffre rempli de cartes, fioles, livres. 'Tu cherches quoi ?'",
		 "biomes": [&"city", &"ruins", &"forest", &"highland"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui demandes ce qu'il a de précieux.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Il te vend une carte utile à bas prix. Le voyage reprend, mieux préparé."},
			 "bad":  {"narr": "Il te propose des choses inutiles. Tu pars sans rien."}},
			{"tone": T_DECE, "text": "Tu lui marchandes un flacon en lui faisant croire que tu en as plein.",
			 "good": {"stat_delta": 2, "stat": &"charisme", "narr": "Il te le cède pour rien. Tu repars avec un remède véritable."},
			 "bad":  {"narr": "Il se vexe. Il ferme son coffre. Tu pars sans rien."}},
			{"tone": T_CURI, "text": "Tu lui poses une question savante.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il te répond longtemps. Tu en sors trois choses utiles."},
			 "bad":  {"injury": &"exhaustion", "narr": "Il parle, longtemps, longtemps. Tu n'en retiens rien."}},
		 ]},

		# --- LOST CHILD ---
		{"id": &"lost_child",
		 "title": "Un enfant perdu, le visage propre, demande où est sa maison. Il dit un nom de village.",
		 "biomes": [&"city", &"forest", &"coast", &"highland"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui dis ce que tu sais et tu l'orientes du mieux possible.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il te remercie. Plus tard, sa famille te récompensera."},
			 "bad":  {"narr": "Il ne te croit pas. Il part dans l'autre sens. Tu ne sais pas ce qui lui arrive."}},
			{"tone": T_CAUT, "text": "Tu lui demandes plus de détails avant de répondre.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Quelque chose cloche dans ses réponses. Tu te recules juste à temps."},
			 "bad":  {"injury": &"terror", "narr": "Tu réalises que l'enfant n'existe pas. Tu pars vite."}},
			{"tone": T_MYST, "text": "Tu lui touches le front, gentiment, en silence.",
			 "good": {"heal": &"terror", "narr": "Il sourit, te montre la direction. C'était bien un enfant. Tu l'avais oublié, comment ça se passe."},
			 "bad":  {"injury": &"curse", "narr": "Il sourit. Sa peau est froide. Tu retires la main trop tard."}},
		 ]},

		# --- HEALER COTTAGE ---
		{"id": &"healer_cottage",
		 "title": "Une petite maison, fumée par la cheminée, sent les herbes brûlées. Une femme âgée fait signe d'entrer.",
		 "biomes": [&"forest", &"city", &"highland"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu entres et tu lui paies sa science.",
			 "good": {"heal": &"bleeding", "narr": "Elle te soigne. Tu repars la plaie refermée."},
			 "bad":  {"narr": "Elle te dit qu'elle ne peut rien pour toi aujourd'hui. Repasse demain."}},
			{"tone": T_AGGR, "text": "Tu exiges qu'elle te soigne sans payer.",
			 "good": {"narr": "Elle te soigne par crainte. Tu repars indemne, conscience moins claire."},
			 "bad":  {"injury": &"curse", "narr": "Elle t'a soigné. Mais elle a ajouté quelque chose. Tu le sens, plus tard."}},
			{"tone": T_DECE, "text": "Tu joues l'enfant perdu pour qu'elle te soigne gratuitement.",
			 "good": {"heal": &"exhaustion", "narr": "Elle te plaint. Te soigne. Te nourrit. Tu repars rassasié."},
			 "bad":  {"injury": &"poison", "narr": "Elle voit clair dans ton jeu. Le bouillon qu'elle te tend n'est pas ce qu'elle prétend."}},
		 ]},

		# --- MIRROR LAKE ---
		{"id": &"mirror_lake",
		 "title": "Un lac parfaitement plat reflète un ciel qui n'est pas celui qu'il y a au-dessus de toi.",
		 "biomes": [&"anomaly", &"highland", &"corrupted"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu te penches pour voir le ciel d'en bas.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Tu vois des étoiles que personne au-dessus ne connaît. Tu en mémorises une."},
			 "bad":  {"injury": &"curse", "narr": "Une étoile te regarde. Tu sens qu'elle te suit, désormais."}},
			{"tone": T_MYST, "text": "Tu plonges la main dans le reflet du ciel.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu en sors une poignée de nuit. Elle te servira."},
			 "bad":  {"injury": &"terror", "narr": "Une main t'attrape par en bas. Tu te dégages, mais quelque chose te reste sur le poignet."}},
			{"tone": T_CAUT, "text": "Tu pars sans rien regarder de plus.",
			 "good": {"heal": &"terror", "narr": "Tu apprends qu'on peut refuser d'apprendre. C'est une force."},
			 "bad":  {"narr": "Tu pars. Mais tu rêves du ciel d'en bas la nuit suivante."}},
		 ]},

		# --- GLOWING FUNGI ---
		{"id": &"glowing_fungi",
		 "title": "Un anneau de champignons bleus, lumineux. Ils pulsent doucement, ensemble.",
		 "biomes": [&"corrupted", &"swamp", &"forest", &"anomaly"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu en cueilles un pour l'examiner.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "La lueur t'aide à voir dans le noir. Tu repars avec une lanterne vivante."},
			 "bad":  {"injury": &"poison", "narr": "Tu inhales ses spores en te penchant. Tu ne le réalises qu'après."}},
			{"tone": T_MYST, "text": "Tu danses lentement à l'intérieur du cercle.",
			 "good": {"heal": &"curse", "narr": "Le cercle accepte ton pas. Une malédiction se dissout dans la lumière."},
			 "bad":  {"injury": &"curse", "narr": "Le cercle se referme sur toi un moment. Tu en sors marqué."}},
			{"tone": T_CAUT, "text": "Tu fais le tour sans entrer.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu pars. Une spore t'a suivi quand même — bénéfique."},
			 "bad":  {"narr": "Tu pars. Tu ne sauras jamais ce qu'il y avait de l'autre côté."}},
		 ]},

		# --- WIND-SINGER'S HARP ---
		{"id": &"wind_harp",
		 "title": "Une harpe suspendue entre deux rochers. Le vent en joue depuis si longtemps que les cordes brillent.",
		 "biomes": [&"highland", &"coast", &"ruins"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu accordes ta voix à sa note.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu apprends une chanson que tu ne savais pas. Elle te servira pour calmer."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu chantes trop longtemps. Le vent t'a vidé."}},
			{"tone": T_AGGR, "text": "Tu prends la harpe.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Elle est lourde mais utile. Tu repars avec un instrument qui chante seul."},
			 "bad":  {"injury": &"broken_arm", "narr": "Les cordes te coupent. Quand tu tires, elles tirent en retour."}},
			{"tone": T_DIPL, "text": "Tu remercies le vent à voix haute et tu pars.",
			 "good": {"heal": &"terror", "narr": "Une brise t'accompagne ensuite, pendant des heures. Tu marches sans peur."},
			 "bad":  {"narr": "Le vent ne répond pas. Tu pars sans rien."}},
		 ]},

		# --- SAILOR'S GRAVE ---
		{"id": &"sailor_grave",
		 "title": "Une croix de bois plantée dans le sable. Un nom gravé, presque effacé. Une bouteille à côté, encore scellée.",
		 "biomes": [&"coast", &"crypt", &"ruins"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu prononces le nom à voix haute pour qu'il soit dit encore une fois.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Tu repars apaisé. Quelque chose te suit, bienveillant, jusqu'à la prochaine zone."},
			 "bad":  {"narr": "Tu prononces le nom. Rien ne se passe. Tu pars."}},
			{"tone": T_CURI, "text": "Tu ouvres la bouteille.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Un message — une carte au trésor à un jet de pierre. Tu trouves quelques pièces."},
			 "bad":  {"injury": &"curse", "narr": "Un message vide. Et un parfum dont tu n'oublieras pas l'odeur."}},
			{"tone": T_AGGR, "text": "Tu déterres la croix pour voir s'il y a quelque chose dessous.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Une boîte rouillée. Dedans, un couteau. Bon outil."},
			 "bad":  {"injury": &"curse", "narr": "Il y a des os, et puis quelque chose qui te suit ensuite à un demi-pas."}},
		 ]},

		# --- STAR MAP ---
		{"id": &"star_map",
		 "title": "Sur une dalle de pierre, un dessin précis — c'est le ciel. Mais le ciel d'il y a très longtemps.",
		 "biomes": [&"ruins", &"highland", &"anomaly", &"crypt"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu compares avec ce que tu vois au-dessus de toi.",
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": "Tu repères trois étoiles qui ont changé. Tu comprends ce que ça veut dire."},
			 "bad":  {"injury": &"exhaustion", "narr": "Tu lèves la tête, longtemps. Tu ne trouves rien d'utile."}},
			{"tone": T_MYST, "text": "Tu traces les lignes avec ton doigt.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Une carte apparaît dans ton esprit. Tu sauras retrouver cet endroit."},
			 "bad":  {"injury": &"curse", "narr": "Une ligne se prolonge dans ta main. Tu la portes ensuite."}},
			{"tone": T_DECE, "text": "Tu effaces une partie pour confondre le suivant.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Petit plaisir, vrai gain. Tu pars avec un sourire."},
			 "bad":  {"injury": &"curse", "narr": "La pierre se referme quand tu touches. Tu retires la main avec une marque."}},
		 ]},

		# --- BURNING PYRE ---
		{"id": &"burning_pyre",
		 "title": "Un bûcher fume. Quelqu'un — sur le bûcher. Personne d'autre aux alentours.",
		 "biomes": [&"city", &"ruins", &"corrupted"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu éteins le bûcher avec la terre.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu sauves quelqu'un, peut-être. Il s'enfuit sans un mot. Tu trouves des pièces dans la cendre."},
			 "bad":  {"injury": &"bleeding", "narr": "Le feu te déchire les mains. La personne ne se relève pas."}},
			{"tone": T_DIPL, "text": "Tu pries pour ce qui brûle.",
			 "good": {"heal": &"terror", "narr": "Tu pries. Une paix vient. Le bûcher s'éteint tout seul, peu après."},
			 "bad":  {"injury": &"terror", "narr": "Tu pries. Quelque chose t'écoute. Pas ce que tu pensais."}},
			{"tone": T_CAUT, "text": "Tu pars vite. Ce n'est pas ton histoire.",
			 "good": {"narr": "Tu pars. La fumée s'éloigne. Tu oublies vite."},
			 "bad":  {"narr": "Tu pars. Tu sens le regard de quelqu'un dans le bûcher. Tu accélères."}},
		 ]},

		# --- FROZEN TOWER ---
		{"id": &"frozen_tower",
		 "title": "Une tour intacte, recouverte de glace en plein été. Une porte ouverte au sommet.",
		 "biomes": [&"anomaly", &"highland", &"corrupted"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu grimpes.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Au sommet, un livre ouvert. Tu en lis trois pages. Tu en sortiras transformé."},
			 "bad":  {"injury": &"exhaustion", "narr": "L'escalade est plus longue qu'elle n'en a l'air. Tu redescends sans rien."}},
			{"tone": T_MYST, "text": "Tu poses la main sur la glace et tu lui parles.",
			 "good": {"heal": &"curse", "narr": "La glace t'écoute. Elle prend une malédiction et la garde pour toi."},
			 "bad":  {"injury": &"terror", "narr": "La glace t'écoute. Et te rend quelque chose que tu avais oublié de perdre."}},
			{"tone": T_CAUT, "text": "Tu fais le tour, prudent.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu repères une trappe au sol. Tu y trouves un fragment intéressant."},
			 "bad":  {"narr": "Tu trouves trois traces autour de la tour. Toutes vont à l'intérieur. Aucune n'en sort."}},
		 ]},

		# --- UNDERWATER SHADOW ---
		{"id": &"underwater_shadow",
		 "title": "Une ombre se déplace sous l'eau, lentement, à quelques mètres seulement. Elle ne monte jamais.",
		 "biomes": [&"coast", &"swamp", &"anomaly"],
		 "choices": [
			{"tone": T_CAUT, "text": "Tu t'éloignes du rivage sans courir.",
			 "good": {"narr": "Tu pars. L'ombre te suit un moment, puis abandonne."},
			 "bad":  {"injury": &"terror", "narr": "L'ombre te suit longtemps. Tu marches sans t'arrêter, le cœur tendu."}},
			{"tone": T_DIPL, "text": "Tu lui jettes un caillou pour la saluer.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "Elle rejette le caillou hors de l'eau. Tu le ramasses. Il a changé."},
			 "bad":  {"injury": &"curse", "narr": "Elle ne renvoie pas le caillou. Elle remonte, lentement, vers la surface. Tu pars sans regarder."}},
			{"tone": T_MYST, "text": "Tu murmures un mot ancien à l'eau.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "L'ombre s'arrête. Elle écoute. Elle te confie quelque chose, dans le silence."},
			 "bad":  {"injury": &"terror", "narr": "L'ombre s'arrête. Elle t'écoute. Trop bien."}},
		 ]},

		# --- ROADSIDE SHRINE LIT ---
		{"id": &"lit_shrine",
		 "title": "Un autel récemment éclairé. Quelqu'un est passé il y a peu.",
		 "biomes": [&"forest", &"city", &"ruins", &"crypt", &"highland"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu y déposes une pièce et tu murmures une prière.",
			 "good": {"heal": &"bleeding", "narr": "Une chaleur t'enveloppe. Tu repars la plaie refermée."},
			 "bad":  {"narr": "Tu repars. Rien ne se passe. Mais quelque chose est apaisé."}},
			{"tone": T_DECE, "text": "Tu rallumes la bougie en récupérant la pièce.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Tu repars avec la pièce et la conscience tranquille."},
			 "bad":  {"injury": &"curse", "narr": "La pièce te brûle dans la poche, longtemps."}},
			{"tone": T_MYST, "text": "Tu ajoutes une mèche de tes cheveux à la bougie.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Tu repars avec un savoir qui n'était pas là avant."},
			 "bad":  {"injury": &"curse", "narr": "Tu y as laissé plus que des cheveux. Tu le sentiras."}},
		 ]},

		# --- TIRED SOLDIER ---
		{"id": &"tired_soldier",
		 "title": "Un soldat assis dans la poussière, son épée brisée à côté. 'Tu ne saurais pas où je peux dormir ?'",
		 "biomes": [&"ruins", &"city", &"highland", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui indiques un coin tranquille que tu as repéré.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il te remercie et te confie un secret de campagne — utile."},
			 "bad":  {"narr": "Il ne te croit pas. Il te tourne le dos."}},
			{"tone": T_AGGR, "text": "Tu lui prends son épée brisée et tu pars.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Il ne dit rien. La lame se révèle pas si brisée que ça."},
			 "bad":  {"injury": &"bleeding", "narr": "Il était plus rapide qu'il en avait l'air. La lame brisée trouve sa cible."}},
			{"tone": T_CAUT, "text": "Tu fais un signe et tu pars sans lui parler.",
			 "good": {"narr": "Tu pars. Il s'endort là où il était."},
			 "bad":  {"narr": "Il te suit du regard. Tu accélères."}},
		 ]},

		# --- GLOWING CHEST ---
		{"id": &"glowing_chest",
		 "title": "Un petit coffre qui pulse doucement à travers les planches. Il a l'air vivant.",
		 "biomes": [&"ruins", &"crypt", &"city", &"anomaly"],
		 "choices": [
			{"tone": T_CURI, "text": "Tu l'ouvres calmement.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "À l'intérieur, un fragment précieux. Tu le glisses dans ta poche."},
			 "bad":  {"injury": &"poison", "narr": "À l'intérieur, une vapeur. Tu en respires une bouffée."}},
			{"tone": T_AGGR, "text": "Tu le brises d'un coup de pied.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu en tires une bonne pièce et un morceau de cristal."},
			 "bad":  {"injury": &"bleeding", "narr": "Un éclat te tranche le tibia."}},
			{"tone": T_MYST, "text": "Tu poses la main et tu écoutes ce qu'il a à dire.",
			 "good": {"heal": &"curse", "narr": "Le coffre absorbe quelque chose en toi. Tu repars plus léger."},
			 "bad":  {"injury": &"curse", "narr": "Le coffre te transfère ce qu'il portait. Tu le portes maintenant."}},
		 ]},

		# --- BLOOD FRUIT ---
		{"id": &"blood_fruit",
		 "title": "Un fruit rouge sang pend à un arbre par ailleurs mort. Il sent encore frais.",
		 "biomes": [&"forest", &"corrupted", &"swamp"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu le manges tout cru.",
			 "good": {"heal": &"exhaustion", "narr": "Le jus est sucré et te remplit. Tu repars avec de l'énergie."},
			 "bad":  {"injury": &"poison", "narr": "C'était sucré au début, puis amer. Très amer."}},
			{"tone": T_CAUT, "text": "Tu le cueilles et tu le gardes pour plus tard.",
			 "good": {"stat_delta": 1, "stat": &"endurance", "narr": "Tu le gardes. Il ne pourrit pas. Bon présage."},
			 "bad":  {"narr": "Il fond entre tes doigts. Tu pars sans rien."}},
			{"tone": T_MYST, "text": "Tu le laisses en offrande sur l'arbre.",
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": "L'arbre frémit. Tu reçois un mot ancien en retour."},
			 "bad":  {"narr": "Tu pars. L'arbre ne dit rien. Le fruit pourrit derrière toi."}},
		 ]},

		# --- WANDERING HORSE ---
		{"id": &"wandering_horse",
		 "title": "Un cheval sellé broute paisiblement, sans cavalier. Il te regarde sans crainte.",
		 "biomes": [&"highland", &"coast", &"forest", &"ruins"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu lui parles doucement et tu le mènes par la bride.",
			 "good": {"stat_delta": 2, "stat": &"vivacite", "narr": "Il te suit. Tu traverses la zone bien plus vite."},
			 "bad":  {"narr": "Il s'éloigne quand tu approches. Il ne veut pas de toi."}},
			{"tone": T_AGGR, "text": "Tu le montes en force.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu réussis. Il accepte ton autorité. Tu pars sur lui."},
			 "bad":  {"injury": &"broken_arm", "narr": "Il te jette à terre. Quelque chose dans ton bras a cédé."}},
			{"tone": T_CAUT, "text": "Tu le contournes pour voir ce qu'il broute.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu trouves les restes de son cavalier — et ce qu'il portait."},
			 "bad":  {"narr": "Tu ne trouves rien. Le cheval te regarde, agacé."}},
		 ]},

		# --- BURNING SCROLL ---
		{"id": &"burning_scroll",
		 "title": "Un parchemin enflammé qui ne se consume pas. Il flotte à hauteur d'homme.",
		 "biomes": [&"ruins", &"crypt", &"anomaly", &"corrupted"],
		 "choices": [
			{"tone": T_MYST, "text": "Tu prononces le mot qu'il attend.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il s'éteint et tombe dans ta main. Tu peux le lire."},
			 "bad":  {"injury": &"curse", "narr": "Tu as dit le mot. Mais pas celui qu'il attendait."}},
			{"tone": T_CURI, "text": "Tu essaies de le lire à travers les flammes.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu retiens trois mots. Ils te serviront."},
			 "bad":  {"injury": &"bleeding", "narr": "La flamme te brûle les yeux. Tu pars en pleurant."}},
			{"tone": T_AGGR, "text": "Tu l'attrapes malgré le feu.",
			 "good": {"stat_delta": 1, "stat": &"force", "narr": "Tu encaisses la brûlure. Le parchemin est à toi."},
			 "bad":  {"injury": &"bleeding", "narr": "Le feu refuse de s'éteindre. Tu lâches en hurlant."}},
		 ]},

		# --- WHISPERING WIND ---
		{"id": &"whispering_wind",
		 "title": "Le vent te parle clairement. Trois mots, lentement. Il te demande quelque chose.",
		 "biomes": [&"highland", &"coast", &"anomaly"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu réponds à voix haute.",
			 "good": {"stat_delta": 2, "stat": &"charisme", "narr": "Le vent t'accompagne ensuite, doux, pendant longtemps."},
			 "bad":  {"narr": "Le vent te coupe la voix. Tu pars sans avoir fini."}},
			{"tone": T_MYST, "text": "Tu chantes une seule note en réponse.",
			 "good": {"heal": &"exhaustion", "narr": "Le vent te porte. Tu retrouves des forces sans effort."},
			 "bad":  {"injury": &"terror", "narr": "La note est fausse. Le vent reprend la sienne, plus fort."}},
			{"tone": T_CAUT, "text": "Tu te tais et tu attends qu'il passe.",
			 "good": {"narr": "Tu attends. Le vent finit par s'éloigner. Tu pars."},
			 "bad":  {"injury": &"exhaustion", "narr": "Le vent ne s'arrête pas. Tu marches contre lui longtemps."}},
		 ]},

		# --- WOUNDED ANIMAL ---
		{"id": &"wounded_animal",
		 "title": "Un cerf à terre, une flèche fichée dans le flanc. Il respire encore.",
		 "biomes": [&"forest", &"highland", &"coast"],
		 "choices": [
			{"tone": T_DIPL, "text": "Tu retires la flèche avec douceur.",
			 "good": {"stat_delta": 1, "stat": &"charisme", "narr": "Il se lève, faiblement, et te confie un regard avant de fuir. Plus tard, tu trouveras une bois de cerf utile sur ton chemin."},
			 "bad":  {"injury": &"bleeding", "narr": "Il se débat. Le bois de la flèche te griffe."}},
			{"tone": T_AGGR, "text": "Tu l'achèves d'un coup propre.",
			 "good": {"heal": &"exhaustion", "narr": "Tu manges un repas honnête. Tu repars rassasié."},
			 "bad":  {"injury": &"terror", "narr": "Il te regarde pendant que tu frappes. Tu ne dormiras plus pareil."}},
			{"tone": T_MYST, "text": "Tu poses la main et tu prends un peu de sa douleur.",
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": "Il se relève. Tu sens son nom dans ta tête. Tu peux désormais l'appeler."},
			 "bad":  {"injury": &"poison", "narr": "Tu prends trop. Tu titubes."}},
		 ]},

		# --- OLD WELL TREASURE ---
		{"id": &"old_well_treasure",
		 "title": "Un puits asséché. Au fond, du métal brille faiblement. La pierre est friable.",
		 "biomes": [&"ruins", &"city", &"swamp"],
		 "choices": [
			{"tone": T_AGGR, "text": "Tu descends en force, sans corde.",
			 "good": {"stat_delta": 2, "stat": &"force", "narr": "Tu remontes avec une poignée de pièces et un anneau gravé."},
			 "bad":  {"injury": &"broken_arm", "narr": "Tu glisses. Ton bras heurte la pierre. Tu remontes seul, à grand peine."}},
			{"tone": T_CAUT, "text": "Tu trouves une corde et tu descends prudemment.",
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": "Tu remontes sans dommage avec ce que tu voulais."},
			 "bad":  {"injury": &"exhaustion", "narr": "La descente prend des heures. Tu remontes vidé."}},
			{"tone": T_DECE, "text": "Tu fais semblant de partir et tu reviens à la tombée du jour.",
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": "Plus simple dans le noir. Tu repars avec deux pièces de plus."},
			 "bad":  {"narr": "Le puits est plus profond la nuit. Tu repars sans rien."}},
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
