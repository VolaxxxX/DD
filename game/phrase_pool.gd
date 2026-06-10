class_name PhrasePool extends RefCounted
# Pool of narrative phrases for choices and outcomes.
# Tone integers: 0=AGGRESSIVE 1=DIPLOMATIC 2=CAUTIOUS 3=CURIOUS 4=DECEPTIVE 5=MYSTICAL
# Outcome integers match FateEngine.Outcome: 0=CRIT_FAIL 1=FAIL 2=MIXED 3=SUCCESS 4=CRIT_SUCCESS

enum Tone { AGGRESSIVE, DIPLOMATIC, CAUTIOUS, CURIOUS, DECEPTIVE, MYSTICAL }

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"Tu lèves ta lame sans un mot et t'avances.",
			"Tu charges, la peur transmuée en rage.",
			"Tu vises la gorge — un seul coup, précis.",
			"Tu frappes le premier, au cœur de son silence.",
			"Tu grondes une insulte et fonds sur lui.",
			"Tu feintes à gauche, frappes à droite. C'est ton seul plan.",
			"Tu lui craches au visage avant de dégainer.",
			"Tu attaques sans cri. Un travail à finir, rien de plus.",
			"Tu visualises sa fin, puis tu la rends réelle.",
			"Tu prends le risque d'un coup large. S'il rate, tu meurs.",
			"Tu lui lances ce que tu as sous la main — pour combler la distance.",
			"Tu ouvres les hostilités par un coup bas. Pas le moment d'être noble.",
			"Tu t'engages, ramassé, comme on étrangle.",
			"Tu hurles, espérant qu'il hésite. Tu ne lui laisses pas le temps de répondre.",
		]
		1: return [
			"Tu tends les paumes, ouvertes, et parles doucement.",
			"Tu murmures un mot ancien, espérant qu'il le reconnaisse.",
			"Tu t'agenouilles lentement, tête basse.",
			"Tu proposes un échange — ta voix tremble mais reste calme.",
			"Tu évoques ses ancêtres, ou ce que tu imagines d'eux.",
			"Tu lui dis ton nom. C'est tout ce que tu peux offrir.",
			"Tu chantonnes une berceuse. Tu ne sais même pas d'où elle vient.",
			"Tu lui demandes ce qu'il cherche. Tu écoutes vraiment.",
			"Tu parles de la route, du temps, de tout sauf de lui.",
			"Tu lui poses une question simple : pourquoi rester ici ?",
			"Tu lui jures que tu n'as pas d'arme. Tu mens à peine.",
			"Tu lui parles comme à un enfant qui aurait peur.",
			"Tu lui souffles un secret. Tu le regrettes déjà.",
			"Tu lui dis qu'il a le droit de partir. Et toi aussi.",
		]
		2: return [
			"Tu recules d'un pas mesuré, sans quitter son regard.",
			"Tu contournes lentement, à bonne distance.",
			"Tu te fonds dans l'ombre d'une racine et retiens ton souffle.",
			"Tu jettes une pierre plus loin, espérant le détourner.",
			"Tu attends qu'il se lasse, immobile comme la mort.",
			"Tu marches sur la pointe des pieds, comme dans un rêve.",
			"Tu te couches dans les herbes hautes. Tu deviens terre.",
			"Tu rebrousses chemin sans bruit, suivant ta propre trace.",
			"Tu te glisses derrière un tronc, comptes jusqu'à dix.",
			"Tu enlèves tes bottes et tu marches pieds nus, lentement.",
			"Tu suis le vent — il couvrira ton odeur.",
			"Tu te baisses dans un fossé. La nuit passera, peut-être.",
			"Tu fais le mort avant que l'idée ne lui vienne.",
		]
		3: return [
			"Tu t'approches pour examiner la marque sur son flanc.",
			"Tu ramasses un éclat tombé à ses pieds et l'observes.",
			"Tu tends l'oreille — un son étrange sort de sa gorge.",
			"Tu cherches du regard ce qu'il protège ainsi.",
			"Tu poses une question à voix haute, pour voir.",
			"Tu observes son ombre. Elle ne bouge pas comme la tienne.",
			"Tu comptes ses respirations. Quelque chose cloche.",
			"Tu remarques une cicatrice ancienne. Tu y reconnais un motif.",
			"Tu te concentres sur ses mains. Elles racontent autre chose.",
			"Tu suis du regard ce qu'il regarde lui. Quoi qu'il fixe.",
			"Tu écoutes le silence autour de lui. Il est trop propre.",
			"Tu repères un détail que personne ne verrait. Tu le retiens.",
			"Tu te demandes ce qu'il était, avant.",
		]
		4: return [
			"Tu lui montres une main vide en gardant l'autre sur ta dague.",
			"Tu lui jures que tu n'es qu'un voyageur perdu. Tu comptes déjà ses dents.",
			"Tu feins la blessure — un gémissement bien placé.",
			"Tu parles de la route, du froid — pendant que tes doigts cherchent.",
			"Tu lui proposes un marché que tu n'honoreras jamais.",
			"Tu lui dis que tu connais quelqu'un. C'est faux.",
			"Tu joues la peur, parfaitement. Tu trembles de la bonne façon.",
			"Tu lui désignes quelque chose dans son dos. Et tu agis.",
			"Tu lui dis qu'il y en a d'autres derrière toi. Il n'y a personne.",
			"Tu lui promets une dette. Tu ne la paieras jamais.",
			"Tu jures sur quelque chose de sacré que tu as inventé hier.",
			"Tu lui donnes un faux nom. Tu y crois assez pour qu'il y croie aussi.",
			"Tu fais comme si tu le connaissais. Tu insistes même.",
		]
		5: return [
			"Tu traces un signe ancien dans la poussière, sans regarder.",
			"Tu prononces un mot qui n'appartient à aucune langue vivante.",
			"Tu fermes les yeux et laisses quelque chose d'autre regarder à ta place.",
			"Tu poses la main sur le sol et écoutes ce que la terre te répond.",
			"Tu offres une goutte de ton sang au vent. Juste une.",
			"Tu récites un nom que tu ne te souvenais pas connaître.",
			"Tu inverses ton souffle : tu inspires sur l'expir, expires sur l'inspir.",
			"Tu marques un cercle invisible autour de toi et l'invites à entrer.",
			"Tu offres un de tes souvenirs en échange d'une vérité.",
			"Tu détaches une mèche de tes cheveux et l'enterres.",
			"Tu murmures à l'envers une prière que tu n'as jamais apprise.",
			"Tu touches le sol à trois endroits exacts. Tu n'as jamais su comment tu sais.",
			"Tu offres ton silence à ce qui écoute. C'est ce qu'il y a de plus précieux.",
		]
	return ["Tu fais un pas de côté."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	if tone == 0:
		match outcome:
			4: return [
				"Ta lame trouve la brèche. %s s'effondre sans bruit. Quelque chose en toi approuve.",
				"Un coup parfait. %s chute avant d'avoir compris.",
				"Tu frappes une fois. C'est suffisant. %s reste là, debout, puis s'écroule lentement.",
				"%s n'a même pas le temps de te regarder mourir. Tu l'as déjà désossé.",
				"Une danse brève et précise. Quand elle s'arrête, %s est par terre.",
			]
			3: return [
				"%s tombe au troisième échange. Tu respires.",
				"Le combat est bref. %s cède. Tu saignes un peu.",
				"Tu fais ce qu'il fallait. %s ne se relèvera pas. Toi non plus, tout à fait.",
				"Tu portes le coup décisif au bon moment. %s recule, vacille, ne revient pas.",
				"Tu gagnes, à la sueur et à la chance. %s reste au sol.",
			]
			2: return [
				"%s recule en boitant, mais tu n'es pas indemne.",
				"Vous vous séparez en silence. Chacun a perdu quelque chose.",
				"Tu le repousses. Il fuit. Tu saignes en regardant la route.",
				"Le combat tourne à la confusion. Vous arrêtez sans avoir tranché.",
				"Tu prends le dessus assez longtemps pour qu'il décide de partir.",
			]
			1: return [
				"Ton coup glisse. %s riposte et tu sens la chair s'ouvrir.",
				"%s esquive — ton élan te trahit. Tu paies.",
				"Tu attaques trop tôt. %s te punit. Tu apprends.",
				"Ta lame trouve l'os, mais c'est le tien. %s n'a même pas saigné.",
				"Tu rates ce que tu visais. %s ne rate pas.",
			]
			0: return [
				"%s te déchire avant même que tu aies posé le pied. Tu vacilles.",
				"Tu es déjà au sol. %s te regarde sans hâte.",
				"Ce que tu prenais pour une bête était une trappe. Elle se referme.",
				"%s te brise quelque chose qui ne se répare pas vite.",
				"Tu comprends, trop tard, que tu n'aurais jamais dû.",
			]
	elif tone == 1:
		match outcome:
			4: return [
				"%s s'incline. Un pacte silencieux passe entre vous. Il s'éloigne.",
				"Tes mots touchent un endroit ancien. %s baisse la tête et te laisse passer.",
				"Quelque chose en %s reconnaît quelque chose en toi. Vous vous séparez frères.",
				"%s te répond, longuement. Tu apprends plus que tu n'espérais.",
				"%s te laisse un signe — petit, précieux. Tu n'oublieras pas.",
			]
			3: return [
				"%s écoute. Les épaules tombent. Il s'en va sans regret.",
				"Vous trouvez un arrangement. Personne ne saigne aujourd'hui.",
				"%s te concède le chemin. Pas la confiance. Mais le chemin.",
				"%s grommelle quelque chose et te dépasse. C'est tout ce qu'il te fallait.",
				"Vos voix se touchent un instant. Puis chacun reprend la sienne.",
			]
			2: return [
				"%s hésite, puis détourne le regard. C'est tout ce que tu obtiens.",
				"Il t'accorde un passage étroit, mais garde un œil méfiant.",
				"%s ne te répond pas, mais ne t'attaque pas non plus. Tu prends ça.",
				"Tu obtiens une trêve. Pas la paix, mais c'est mieux que la guerre.",
				"%s te montre un autre chemin. Tu le prends sans questionner.",
			]
			1: return [
				"%s ne comprend pas. Ou ne veut pas. Sa posture change.",
				"Tes mots glissent sur lui. Il s'avance, sans hâte.",
				"%s rit. Pas du tout comme tu l'espérais.",
				"Tu parles trop, ou trop peu. %s perd patience.",
				"Tes mots sonnent faux à tes propres oreilles. À celles de %s aussi.",
			]
			0: return [
				"%s prend tes paumes ouvertes pour une faiblesse. Il frappe.",
				"Tu as parlé. Tu n'aurais pas dû. %s réagit comme une bête.",
				"%s répond par un mot que tu ne comprends pas. Puis par autre chose.",
				"Quelque chose dans ce que tu as dit a réveillé une vieille colère.",
				"%s te fait taire d'un geste qui ne ressemble pas à un geste humain.",
			]
	elif tone == 2:
		match outcome:
			4: return [
				"%s ne te voit jamais. Tu es déjà loin.",
				"Tu disparais comme une ombre. %s cherche encore quand le vent tourne.",
				"Tu passes derrière lui pendant qu'il regarde ailleurs. Parfait.",
				"%s passe à un mètre de toi sans te voir. Tu retiens ton sourire.",
				"Tu te déplaces comme l'air. %s ne saura jamais que tu étais là.",
			]
			3: return [
				"Tu gagnes du terrain. %s perd ta trace.",
				"Tu mets assez de distance. Le souffle revient, lent.",
				"Tu trouves un creux dans le terrain. Tu y dors presque.",
				"%s renonce après quelques pas. Tu pars sans te retourner.",
				"Tu fais ce qu'il fallait — lent, exact. Tu sors d'ici intact.",
			]
			2: return [
				"Tu t'éloignes, mais il sait maintenant que tu étais là.",
				"Vous ne vous affrontez pas. Pour cette fois.",
				"Tu te caches assez bien pour survivre, pas assez pour disparaître.",
				"%s te repère du coin de l'œil mais te laisse partir.",
				"Tu fuis. Quelque chose en %s décide que ça suffit.",
			]
			1: return [
				"%s lève la tête — il t'a repéré. Tu cours.",
				"Ton pied brise une brindille. %s se tourne vers toi.",
				"Tu te crois caché. %s te suit depuis le début.",
				"%s avait flairé ton odeur avant même que tu bouges.",
				"Tu hésites trop longtemps. %s comble la distance d'un saut.",
			]
			0: return [
				"%s était déjà derrière toi depuis longtemps.",
				"Tu recules dans un autre piège. Le sol cède.",
				"Tu fuis dans la mauvaise direction. Il y en avait une autre.",
				"%s ne t'a pas suivi. Il t'attendait là où tu allais.",
				"Tu te caches là où il chasse. C'est une mauvaise journée.",
			]
	elif tone == 3:
		match outcome:
			4: return [
				"Tu découvres un fragment qui change tout. Une mémoire s'ouvre.",
				"Tu comprends quelque chose que personne d'autre n'a jamais vu chez %s.",
				"Le détail que tu observes te révèle bien plus que prévu.",
				"Tu reconnais le motif. C'est ancien, et c'est utile.",
				"%s te laisse voir, sans bouger. Tu apprends en silence.",
			]
			3: return [
				"Un détail t'apprend quelque chose d'utile sur ce lieu.",
				"%s te laisse observer. Tu apprends.",
				"Ce que tu vois ne s'oubliera pas. Tu sais quelque chose de neuf.",
				"Tu rassembles trois fragments en une pensée. Tu pars plus riche.",
				"%s te regarde l'observer. Ni l'un ni l'autre ne bouge. C'est suffisant.",
			]
			2: return [
				"Tu apprends un peu. Tu perds un peu.",
				"L'éclat que tu tiens bourdonne. Tu ne sais pas encore pourquoi.",
				"Tu emportes quelque chose, mais tu laisses autre chose.",
				"%s t'a vu observer. Ça compte, maintenant.",
				"Tu sais désormais. Mais tu n'es plus sûr de vouloir savoir.",
			]
			1: return [
				"Tu t'attardes trop. %s sent ta curiosité et s'en irrite.",
				"Ce que tu touches te touche en retour. Ça brûle.",
				"%s comprend que tu fouilles. Il n'apprécie pas.",
				"Tu observes quelque chose que tu n'aurais pas dû. Trop longtemps.",
				"Tu ouvres une porte qui n'est pas une porte. Tu sens le froid.",
			]
			0: return [
				"Tu as regardé trop profondément. Quelque chose t'a vu aussi.",
				"Le fragment t'entaille la paume. %s se dresse. Tu as réveillé autre chose.",
				"Tu apprends ce que tu ne devais pas savoir. Le savoir te coûte.",
				"%s comprend ce que tu as compris. Il préfère que tu meures avec.",
				"Ce que tu regardais te regarde maintenant. Et il s'approche.",
			]
	elif tone == 4:
		match outcome:
			4: return [
				"%s te croit. Tu repars avec ce qu'il avait. Il ne le saura qu'au matin.",
				"Ton mensonge est si parfait que tu y crois presque toi-même. %s s'incline.",
				"Tu joues le rôle parfait. %s te remercie même.",
				"%s s'éloigne convaincu d'avoir fait une bonne action. Tu souris à peine.",
				"Tu obtiens tout. %s n'a rien vu venir.",
			]
			3: return [
				"%s doute, mais baisse la garde. C'est suffisant.",
				"Tu obtiens ce que tu voulais. %s s'en va avec la moitié des pièces.",
				"%s te laisse passer. Il pensera plus tard que c'était bizarre.",
				"Tu obtiens un avantage. Pas tout. Mais l'essentiel.",
				"%s ne sait pas qu'il vient de se faire avoir. C'est l'idée.",
			]
			2: return [
				"%s devine une partie de la ruse. Tu gagnes quelque chose, tu perds autre chose.",
				"Ton sourire tient. Juste assez. Tu passes.",
				"Tu obtiens ce que tu voulais, mais %s s'en souviendra.",
				"Vous partagez le mensonge. Personne n'est dupe. Personne ne le dit.",
				"%s accepte le marché. Il le retournera contre toi un jour.",
			]
			1: return [
				"%s lit ton mensonge avant même que tu aies fini. Son visage change.",
				"Ta dague tremble au mauvais moment. %s l'a vue.",
				"Tu te trahis par un détail minuscule. %s ne rate pas les détails.",
				"%s te regarde fixement. Tu sens que tu as déjà perdu.",
				"Ton accent te trahit, ou tes mains, ou ton regard. Il a vu.",
			]
			0: return [
				"%s joue mieux que toi. Quand tu comprends, c'est déjà trop tard.",
				"Le piège était pour toi dès le départ. %s sourit.",
				"Tu pensais ruser. %s comptait dessus.",
				"Tu n'es pas le menteur dans cette histoire. C'est %s.",
				"Tu trouves la trahison au moment exact où elle te coûte tout.",
			]
	elif tone == 5:
		match outcome:
			4: return [
				"Quelque chose répond. %s s'écarte, comme devant une porte.",
				"Le signe tient. Le monde s'ouvre un instant — et se referme sur ton secret.",
				"Quelque chose d'immense te reconnaît. %s recule, plus petit qu'avant.",
				"Tu reçois un nom que tu n'oseras pas répéter. Mais tu le sais.",
				"Le rite réussit. Le monde tremble une seconde. Toi seul l'as senti.",
			]
			3: return [
				"Un frisson traverse l'air. %s recule, incertain.",
				"Tu entends une voix qui n'est pas la tienne. Elle te donne une direction.",
				"Quelque chose t'écoute. Et te répond, à sa manière.",
				"Le geste fonctionne, petit, propre. Quelque chose change.",
				"Tu sens un fil tendu entre toi et autre chose. C'est ce que tu voulais.",
			]
			2: return [
				"Le rite fonctionne à moitié. Tu gagnes un fragment. Tu paies un fragment.",
				"Quelque chose écoute, mais ne répond pas. Pas encore.",
				"Tu obtiens une réponse. Tu n'es pas sûr d'avoir posé la bonne question.",
				"Le signe tient mal. Tu apprends quand même quelque chose.",
				"Tu touches l'envers du monde, brièvement. Il te touche en retour.",
			]
			1: return [
				"Les mots te résistent. %s sent ta faiblesse et s'approche.",
				"Le vent refuse ton offrande. Ta paume saigne pour rien.",
				"Tu sens que tu n'as pas le droit. Le geste se retourne.",
				"Quelque chose ricane en silence. Tu n'as pas l'oreille pour ça.",
				"Tu te trompes de mot. %s entend l'erreur avant toi.",
			]
			0: return [
				"Tu as prononcé ce qu'il ne fallait pas. Quelque chose de vieux te regarde maintenant.",
				"Le signe se retourne contre toi. %s n'a plus besoin de bouger.",
				"Quelque chose passe à travers toi. Tu sens que tu n'es plus seul, jamais.",
				"Tu as ouvert ce qui devait rester clos. Le prix sera collecté plus tard.",
				"Le rite réussit, mais pas pour toi. %s récupère ce que tu as appelé.",
			]
	return ["Rien ne se passe."]

static func pick_choice(rng: DRNG, tone: int) -> String:
	var arr: Array
	match Lang.code:
		"en": arr = PhrasePoolEN.choices_for(tone)
		"id": arr = PhrasePoolID.choices_for(tone)
		_:    arr = choices_for(tone)
	return arr[rng.range_i(0, arr.size())]

static func pick_outcome(rng: DRNG, tone: int, outcome: int, creature_name: String) -> String:
	var arr: Array
	match Lang.code:
		"en": arr = PhrasePoolEN.outcomes_for(tone, outcome)
		"id": arr = PhrasePoolID.outcomes_for(tone, outcome)
		_:    arr = outcomes_for(tone, outcome)
	var tpl: String = arr[rng.range_i(0, arr.size())]
	return tpl % creature_name

static func family_descriptor(family: int, tier: int) -> String:
	var base := ""
	match family:
		0: base = "le vagabond"
		1: base = "la bête"
		2: base = "le revenant"
		3: base = "le gardien de fer"
		4: base = "l'élémentaire"
		5: base = "la chose"
		6: base = "la silhouette fée"
		7: base = "le draconide"
		_: base = "l'entité"
	if tier >= 3 and base.begins_with("le "):
		base = "le grand " + base.substr(3)
	elif tier >= 3 and base.begins_with("la "):
		base = "la grande " + base.substr(3)
	return base

static func biome_intro(biome: StringName, corruption: float) -> String:
	match Lang.code:
		"en": return PhrasePoolEN.biome_intro(biome, corruption)
		"id": return PhrasePoolID.biome_intro(biome, corruption)
	var base := ""
	match String(biome):
		"forest":    base = "Tu entres dans la forêt. Les feuilles étouffent tes pas."
		"city":      base = "Tu longes les murs d'une cité oubliée. Des yeux, partout."
		"ruins":     base = "Tu marches entre des pierres qui ont connu des siècles."
		"corrupted": base = "La terre est malade. Le sol palpite sous tes pieds."
		"anomaly":   base = "Rien ici n'obéit aux règles que tu connais."
		"swamp":     base = "L'eau croupit. Chaque pas libère une odeur ancienne."
		"highland":  base = "Le vent te coupe le souffle. Le ciel est immense, indifférent."
		"crypt":     base = "L'air sent la pierre humide. Tu n'entends plus que ta propre respiration."
		"coast":     base = "Le sel pique les yeux. Quelque chose, au loin, n'est pas du bois flotté."
		_:           base = "Tu avances."
	if corruption > 0.6: base += " Quelque chose te regarde sans yeux."
	return base
