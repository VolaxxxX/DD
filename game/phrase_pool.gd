class_name PhrasePool extends RefCounted
# Pool of narrative phrases for choices and outcomes.
# Tone integers: 0=AGGRESSIVE 1=DIPLOMATIC 2=CAUTIOUS 3=CURIOUS 4=DECEPTIVE 5=MYSTICAL
# Outcome integers match FateEngine.Outcome: 0=CRIT_FAIL 1=FAIL 2=MIXED 3=SUCCESS 4=CRIT_SUCCESS

enum Tone { AGGRESSIVE, DIPLOMATIC, CAUTIOUS, CURIOUS, DECEPTIVE, MYSTICAL, WILD }

# A bizarre / out-of-place fourth choice that ignores stats and rolls on its
# own chaos table. Trilingual. Picked from a flat pool — the strangeness is
# the point, no per-family tuning needed.
static func wild_choices() -> Array:
	match Lang.code:
		"en": return [
			"You toss a coin and do the opposite of what it tells you.",
			"You close your eyes and walk straight ahead.",
			"You sing a lullaby to no one.",
			"You greet whatever is watching you without eyes.",
			"You dance a step your mother once taught you.",
			"You offer your shadow to the ground.",
			"You declare aloud that none of this is happening.",
			"You bite your tongue, to see if pain changes the moment.",
			"You count to seven backwards and wait.",
			"You take off one boot and present it as a gift.",
			"You ask the wind for permission to exist here.",
			"You laugh — not at anything in particular.",
		]
		"id": return [
			"Kau lempar koin dan lakukan kebalikan dari yang ia katakan.",
			"Kau memejamkan mata dan berjalan lurus ke depan.",
			"Kau menyanyikan ninabobo untuk tak seorang pun.",
			"Kau menyapa apa pun yang menatapmu tanpa mata.",
			"Kau menari satu langkah yang dulu diajarkan ibumu.",
			"Kau persembahkan bayanganmu pada tanah.",
			"Kau menyatakan dengan suara keras bahwa semua ini tidak terjadi.",
			"Kau menggigit lidahmu, untuk melihat apakah rasa sakit mengubah saat ini.",
			"Kau menghitung mundur sampai tujuh dan menunggu.",
			"Kau melepas satu sepatu bot dan menyerahkannya sebagai hadiah.",
			"Kau meminta izin pada angin untuk ada di sini.",
			"Kau tertawa — tanpa alasan tertentu.",
		]
		_: return [
			"Tu lances une pièce et fais le contraire de ce qu'elle dit.",
			"Tu fermes les yeux et avances droit devant toi.",
			"Tu chantes une berceuse pour personne.",
			"Tu dis bonjour à ce qui te regarde sans yeux.",
			"Tu danses un pas que ta mère t'a appris.",
			"Tu offres ton ombre au sol.",
			"Tu déclares à voix haute que rien de tout ceci n'arrive.",
			"Tu mords ta langue pour voir si la douleur change l'instant.",
			"Tu comptes à l'envers jusqu'à sept et tu attends.",
			"Tu retires une botte et la présentes comme un cadeau.",
			"Tu demandes au vent la permission d'exister ici.",
			"Tu ris — pas de quelque chose en particulier.",
		]

# Pure-chaos outcome narrations for WILD choices. No %s — the absurd act
# doesn't always involve the creature. Picked by FateEngine.Outcome.
static func wild_outcomes(outcome: int) -> Array:
	match Lang.code:
		"en":
			match outcome:
				4: return ["The world considers your gesture — and laughs. Something opens.", "It worked. You don't know how. You don't need to.", "Reality blinks first."]
				3: return ["The strangeness lands. Nobody is more surprised than you.", "A door you hadn't seen stands ajar.", "Something tilts in your favor."]
				2: return ["The world neither approves nor refuses. It simply notes.", "Something shifts. You can't tell yet if it was worth it.", "A bargain is made. The terms will be read later."]
				1: return ["The gesture falls flat. The silence afterward is worse.", "Whatever you tried — it wasn't the password.", "You feel suddenly very small."]
				0: return ["You have invited something. It has accepted.", "The strangeness comes back at you, threefold.", "You should not have done that. You did."]
				_: return ["Nothing answers."]
		"id":
			match outcome:
				4: return ["Dunia menimbang isyaratmu — lalu tertawa. Sesuatu terbuka.", "Berhasil. Kau tak tahu bagaimana. Kau tak perlu tahu.", "Realitas berkedip lebih dulu."]
				3: return ["Keanehan itu mendarat. Tak ada yang lebih terkejut darimu.", "Sebuah pintu yang tak kau lihat terbuka sedikit.", "Sesuatu bergeser ke arahmu."]
				2: return ["Dunia tak menyetujui pun tak menolak. Ia hanya mencatat.", "Sesuatu berubah. Kau belum tahu apakah itu sepadan.", "Sebuah kesepakatan terjadi. Syaratnya akan dibaca nanti."]
				1: return ["Gerakanmu jatuh hambar. Hening setelahnya lebih buruk.", "Apa pun yang kau coba — itu bukan kata sandinya.", "Kau merasa tiba-tiba sangat kecil."]
				0: return ["Kau telah mengundang sesuatu. Ia menerima.", "Keanehan itu kembali kepadamu, tiga kali lipat.", "Seharusnya tak kau lakukan. Kau melakukannya."]
				_: return ["Tak ada yang menjawab."]
		_:
			match outcome:
				4: return ["Le monde considère ton geste — puis rit. Quelque chose s'ouvre.", "Ça a marché. Tu ne sais pas comment. Tu n'as pas besoin de savoir.", "La réalité cligne des yeux la première."]
				3: return ["L'étrangeté trouve sa cible. Personne n'est plus surpris que toi.", "Une porte que tu n'avais pas vue est entrebâillée.", "Quelque chose bascule en ta faveur."]
				2: return ["Le monde n'approuve ni ne refuse. Il prend simplement note.", "Quelque chose se déplace. Tu ne sais pas encore si ça valait le coup.", "Un marché est conclu. Les termes seront lus plus tard."]
				1: return ["Le geste tombe à plat. Le silence qui suit est pire.", "Quoi que tu aies tenté — ce n'était pas le mot de passe.", "Tu te sens soudain très petit."]
				0: return ["Tu as invité quelque chose. Cela a accepté.", "L'étrangeté te revient, au triple.", "Tu n'aurais pas dû. Tu l'as fait."]
				_: return ["Rien ne répond."]

static func pick_wild_choice(rng: DRNG) -> String:
	var arr := wild_choices()
	return arr[rng.range_i(0, arr.size())]

static func pick_wild_outcome(rng: DRNG, outcome: int) -> String:
	var arr := wild_outcomes(outcome)
	return arr[rng.range_i(0, arr.size())]

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

# ---------- Contextual choice variants ----------
# Family order matches Archetype.Family:
# 0 HUMANOID, 1 BEAST, 2 UNDEAD, 3 CONSTRUCT, 4 ELEMENTAL, 5 ABERRATION, 6 FEY, 7 DRACONIC

static func family_choices(tone: int, family: int) -> Array:
	var pools := {}
	match tone:
		0: pools = {
			0: ["Tu vises le genou — un homme à terre ne poursuit personne.",
				"Tu frappes là où son armure baille, sous le bras."],
			1: ["Tu vises le museau — la douleur le fera reculer.",
				"Tu attends qu'il bondisse pour frapper par en dessous."],
			2: ["Tu vises les jambes — qu'il rampe, comme il aurait dû rester.",
				"Tu frappes l'os. Il n'y a plus rien d'autre à trancher."],
			3: ["Tu cherches la jointure — tout mécanisme a un défaut.",
				"Tu frappes la lueur dans sa poitrine. C'est forcément ça, le cœur."],
			4: ["Tu frappes au centre du tourbillon, là où ça tient ensemble.",
				"Tu attaques sans te demander ce que ta lame peut couper ici."],
			5: ["Tu frappes sans regarder — la voir entière coûte trop cher.",
				"Tu vises l'œil. Celui du milieu. Celui qui te fixe."],
			6: ["Tu frappes avant qu'elle finisse sa phrase. Le fer d'abord.",
				"Tu trahis tous les usages : attaquer une fée. Tant pis."],
			7: ["Tu glisses sous sa garde, vers l'écaille manquante.",
				"Tu charges droit vers la gueule. Autant la voir en face."],
		}
		1: pools = {
			0: ["Tu lui rappelles que vous étiez du même peuple, avant tout ça.",
				"Tu lui tends ta ration. Un homme qui mange écoute."],
			1: ["Tu baisses les yeux et exposes ta gorge. Langage de meute.",
				"Tu déposes de la viande entre vous, et tu recules d'un pas."],
			2: ["Tu prononces les mots qu'on doit aux morts. Peut-être les attendait-il.",
				"Tu lui demandes qui il attend. Les morts attendent toujours quelqu'un."],
			3: ["Tu énonces ton nom et ton intention, clairement, comme un protocole.",
				"Tu montres tes mains vides au gardien, paumes vers le ciel."],
			4: ["Tu parles à l'élément comme on parle au temps : sans rien exiger.",
				"Tu t'adresses à ce qui l'anime, pas à ce qu'il montre."],
			5: ["Tu penses ta phrase au lieu de la dire. Peut-être qu'elle écoute là.",
				"Tu salues ce qu'elle était avant de devenir ça."],
			6: ["Tu pèses chaque mot — un pacte avec une fée se paie au mot près.",
				"Tu lui offres une vérité sur toi. Les fées s'en nourrissent."],
			7: ["Tu t'adresses à lui par ses titres. Les dragons collectionnent leurs noms.",
				"Tu lui offres le seul objet brillant que tu possèdes."],
		}
		2: pools = {
			0: ["Tu lèves les mains et recules — un pas, puis deux, sans tourner le dos."],
			1: ["Tu évites son regard et recules face au vent, très lentement."],
			2: ["Tu longes le bord de son territoire — les morts gardent rarement plus loin."],
			3: ["Tu restes immobile. Beaucoup de gardiens ne voient que le mouvement."],
			4: ["Tu cherches l'endroit où l'air est calme, et tu t'y tiens."],
			5: ["Tu fixes le sol. Surtout, ne pas la regarder directement."],
			6: ["Tu retournes ta veste à l'envers, comme dans les vieilles histoires."],
			7: ["Tu te fais petit entre les rochers. On ne distance pas un dragon."],
		}
		3: pools = {
			0: ["Tu détailles son équipement — d'où vient-il, qui l'a payé ?"],
			1: ["Tu lis ses flancs : cicatrices de chasse, ou de fuite ?"],
			2: ["Tu cherches sur lui ce qui l'a tué, la première fois."],
			3: ["Tu cherches la marque du faiseur sous la rouille."],
			4: ["Tu regardes ce qui l'alimente. Tout feu a une source."],
			5: ["Tu comptes ses membres. Le résultat change à chaque fois."],
			6: ["Tu regardes son ombre — les fées n'en portent pas toujours la bonne."],
			7: ["Tu lis ses écailles comme des annales. Chaque brûlure est une date."],
		}
		4: pools = {
			0: ["Tu invoques le nom d'un capitaine inventé qui te couvrirait."],
			1: ["Tu imites le cri d'un congénère blessé, plus loin sur la gauche."],
			2: ["Tu marches comme marchent les morts. Tu deviens l'un des leurs."],
			3: ["Tu répètes le geste gravé sur son socle — peut-être un sceau de passage."],
			4: ["Tu jettes ta gourde au loin : que l'eau l'occupe ailleurs."],
			5: ["Tu penses très fort à autre chose. Qu'elle lise autre chose."],
			6: ["Tu lui proposes un marché truqué — un jeu de fée contre une fée."],
			7: ["Tu le flattes — son orgueil pèse plus lourd que toi."],
		}
		5: pools = {
			0: ["Tu traces le signe du voyageur dans l'air entre vous deux."],
			1: ["Tu souffles dans ta paume et offres ton odeur au monde."],
			2: ["Tu improvises le rite du repos. Maladroit, mais avec respect."],
			3: ["Tu poses ta main sur sa surface et cherches l'écho du faiseur."],
			4: ["Tu nommes l'élément par son vieux nom. Les éléments s'en souviennent."],
			5: ["Tu ouvres ton esprit, juste une fente, pour voir ce qui entre."],
			6: ["Tu traces un cercle de sel — tout ce qu'il t'en reste."],
			7: ["Tu jures sur le feu. La seule langue qu'ils respectent tous."],
		}
	return pools.get(family, [])

static func biome_choices(tone: int, biome: StringName) -> Array:
	var pools := {}
	match tone:
		2: pools = {
			&"forest":    ["Tu grimpes dans les branches basses et laisses la forêt te cacher."],
			&"city":      ["Tu te fonds dans l'embrasure d'une porte morte."],
			&"ruins":     ["Tu te glisses derrière un pan de mur effondré."],
			&"corrupted": ["Tu suis les veines saines du sol, là où la terre ne palpite pas."],
			&"anomaly":   ["Tu marches là où la lumière tombe droit. C'est rare, ici."],
			&"swamp":     ["Tu t'enfonces dans l'eau jusqu'au cou, parmi les roseaux."],
			&"highland":  ["Tu te plaques contre la roche, sous le vent."],
			&"crypt":     ["Tu souffles ta lanterne et comptes tes pas dans le noir."],
			&"coast":     ["Tu suis la ligne de marée, là où le sable efface tes traces."],
		}
		3: pools = {
			&"forest":    ["Tu lis les marques de griffes sur les troncs. Une carte se dessine."],
			&"city":      ["Tu déchiffres ce qui reste d'une enseigne. Quelqu'un vivait ici."],
			&"ruins":     ["Tu compares les gravures du socle avec ce qui te fait face."],
			&"corrupted": ["Tu observes comment la corruption l'a changé, lui."],
			&"anomaly":   ["Tu lances un caillou et suis sa trajectoire. Elle a tort."],
			&"swamp":     ["Tu suis les bulles qui remontent. Quelque chose respire en dessous."],
			&"highland":  ["Tu observes les pierres dressées au sommet. Un alignement."],
			&"crypt":     ["Tu lis les noms sur les dalles. Le sien y est peut-être."],
			&"coast":     ["Tu examines ce que la mer a déposé cette nuit."],
		}
		5: pools = {
			&"forest":    ["Tu presses ta paume contre le plus vieil arbre et tu attends."],
			&"city":      ["Tu appelles les noms des anciens habitants, au hasard."],
			&"ruins":     ["Tu réveilles l'écho des pierres d'un mot frappé deux fois."],
			&"corrupted": ["Tu goûtes la corruption du bout du doigt. Pour comprendre."],
			&"anomaly":   ["Tu pries dans le mauvais sens. Ici, ça pourrait marcher."],
			&"swamp":     ["Tu confies un souhait à l'eau noire et la regardes le prendre."],
			&"highland":  ["Tu cries ton nom au vent et écoutes ce qu'il en rapporte."],
			&"crypt":     ["Tu allumes une bougie pour les morts — et une pour toi."],
			&"coast":     ["Tu écris un mot sur le sable et laisses la vague le prendre."],
		}
	return pools.get(biome, [])

static func tier_choices(tone: int) -> Array:
	# Extra lines that only appear against ELITE+ creatures — the player should
	# feel the danger in the phrasing itself.
	match tone:
		0: return [
			"Tu sais que tu ne peux pas gagner. Tu frappes quand même.",
			"Une seule ouverture. Une seule chance. Tu la prends."]
		2: return [
			"Devant une telle chose, fuir n'est pas une honte.",
			"Tu pries pour qu'il ait déjà mangé, et tu recules."]
		3: return [
			"Tu graves chaque détail en mémoire. Si tu survis, ça vaudra cher."]
		5: return [
			"Tu invoques tout ce que tu sais à la fois. C'est le moment ou jamais."]
	return []

static func pick_choice(rng: DRNG, tone: int, family: int = -1, biome: StringName = &"", tier: int = -1, exclude: Array = []) -> String:
	var arr: Array
	var ctx: Array = []
	match Lang.code:
		"en":
			arr = PhrasePoolEN.choices_for(tone).duplicate()
			ctx += PhrasePoolEN.family_choices(tone, family)
			ctx += PhrasePoolEN.biome_choices(tone, biome)
			if tier >= 3: ctx += PhrasePoolEN.tier_choices(tone)
		"id":
			arr = PhrasePoolID.choices_for(tone).duplicate()
			ctx += PhrasePoolID.family_choices(tone, family)
			ctx += PhrasePoolID.biome_choices(tone, biome)
			if tier >= 3: ctx += PhrasePoolID.tier_choices(tone)
		_:
			arr = choices_for(tone).duplicate()
			ctx += family_choices(tone, family)
			ctx += biome_choices(tone, biome)
			if tier >= 3: ctx += tier_choices(tone)
	# Contextual variants added twice so creature/biome-specific lines surface
	# noticeably more often than the generic ones.
	for c in ctx:
		arr.append(c)
		arr.append(c)
	var pick: String = arr[rng.range_i(0, arr.size())]
	# Avoid texts already used by sibling buttons this encounter.
	var guard := 0
	while pick in exclude and guard < 12:
		pick = arr[rng.range_i(0, arr.size())]
		guard += 1
	return pick

static func pick_outcome(rng: DRNG, tone: int, outcome: int, creature_name: String) -> String:
	var arr: Array
	match Lang.code:
		"en": arr = PhrasePoolEN.outcomes_for(tone, outcome)
		"id": arr = PhrasePoolID.outcomes_for(tone, outcome)
		_:    arr = outcomes_for(tone, outcome)
	var tpl: String = arr[rng.range_i(0, arr.size())]
	return tpl % creature_name

static func family_descriptor(family: int, tier: int) -> String:
	var fr := ["le vagabond", "la bête", "le revenant", "le gardien de fer",
		"l'élémentaire", "la chose", "la silhouette fée", "le draconide"]
	var en := ["the wanderer", "the beast", "the revenant", "the iron guardian",
		"the elemental", "the thing", "the fey shape", "the dragonkin"]
	var id := ["si pengembara", "binatang itu", "si arwah", "penjaga besi",
		"sang elemental", "si makhluk", "siluet peri", "naga keturunan"]
	var idx := clampi(family, 0, 7)
	var base: String
	match Lang.code:
		"en": base = en[idx] if idx < en.size() else "the entity"
		"id": base = id[idx] if idx < id.size() else "makhluk itu"
		_:    base = fr[idx] if idx < fr.size() else "l'entité"
	# Tier prefix per language for ELITE+ creatures.
	if tier >= 3:
		match Lang.code:
			"en":
				if not base.begins_with("the great "): base = "the great " + base.replace("the ", "")
			"id":
				base = "agung " + base
			_:
				if base.begins_with("le "):  base = "le grand "  + base.substr(3)
				elif base.begins_with("la "): base = "la grande " + base.substr(3)
				elif base.begins_with("l'"):  base = "le grand "  + base.substr(2)
	return base

# A short atmospheric sentence describing a creature appearing, by family.
# Shown in the narrative box above the choices so the player knows what's
# happening before deciding. Trilingual.
static func encounter_opening(rng: DRNG, family: int, biome: StringName) -> String:
	var fr := {
		0: ["Une silhouette se détache des ombres et te barre la route.",
			"Quelqu'un t'attendait. Sa main n'est jamais loin de son arme."],
		1: ["Un grognement bas monte des fourrés. La bête t'a senti la première.",
			"Des yeux luisent dans la pénombre. Quelque chose chasse — peut-être toi."],
		2: ["Une forme décharnée se redresse là où rien n'aurait dû bouger.",
			"L'air se refroidit. Ce qui s'avance vers toi a déjà connu la mort."],
		3: ["Un colosse de pierre et de rouille s'anime dans un grincement.",
			"Quelque chose de bâti, pas né, tourne lentement vers toi sa face sans regard."],
		4: ["L'air ondule de chaleur — ou de froid. Un élément a pris forme et t'a vu.",
			"Le sol, le vent, la flamme : quelque chose ici a une volonté, et elle te fixe."],
		5: ["Tes yeux refusent d'abord de comprendre ce qui se tient là.",
			"Une chose qui ne devrait pas exister occupe l'espace devant toi."],
		6: ["Une lueur trop belle danse entre les arbres. Méfie-toi de ce qui est beau, ici.",
			"Une créature de conte te sourit. Les contes finissent rarement bien."],
		7: ["Le souffle te manque : une gueule reptilienne s'incline vers toi.",
			"Des écailles captent la lumière. Ce sang-là est ancien et fier."],
	}
	var en := {
		0: ["A figure peels from the shadows and bars your path.",
			"Someone was waiting. Their hand never strays far from a blade."],
		1: ["A low growl rises from the brush. The beast sensed you first.",
			"Eyes gleam in the gloom. Something is hunting — perhaps you."],
		2: ["A gaunt shape rises where nothing should have stirred.",
			"The air goes cold. What approaches has already known death."],
		3: ["A colossus of stone and rust grinds to life.",
			"Something built, not born, turns its sightless face toward you."],
		4: ["The air shimmers with heat — or cold. An element has taken shape and seen you.",
			"Earth, wind, flame: something here has a will, and it is fixed on you."],
		5: ["Your eyes refuse, at first, to parse what stands there.",
			"A thing that should not exist fills the space before you."],
		6: ["A light too lovely dances between the trees. Beware what is beautiful here.",
			"A creature of fable smiles at you. Fables rarely end well."],
		7: ["Your breath catches: a reptilian maw inclines toward you.",
			"Scales catch the light. That blood is ancient and proud."],
	}
	var id := {
		0: ["Sebuah sosok lepas dari bayangan dan menghadang jalanmu.",
			"Seseorang menunggu. Tangannya tak pernah jauh dari senjata."],
		1: ["Geraman rendah naik dari semak. Binatang itu lebih dulu mencium baumu.",
			"Mata bersinar dalam keremangan. Sesuatu sedang berburu — mungkin kau."],
		2: ["Sosok kurus bangkit di tempat yang seharusnya tak bergerak.",
			"Udara mendingin. Yang mendekat telah mengenal kematian."],
		3: ["Raksasa dari batu dan karat berderak hidup.",
			"Sesuatu yang dibuat, bukan dilahirkan, memutar wajah butanya ke arahmu."],
		4: ["Udara bergetar oleh panas — atau dingin. Sebuah elemen menjelma dan melihatmu.",
			"Tanah, angin, api: sesuatu di sini berkehendak, dan tertuju padamu."],
		5: ["Matamu menolak, mulanya, memahami apa yang berdiri di sana.",
			"Sesuatu yang seharusnya tak ada memenuhi ruang di depanmu."],
		6: ["Cahaya yang terlalu indah menari di antara pepohonan. Waspadai yang indah di sini.",
			"Makhluk dongeng tersenyum padamu. Dongeng jarang berakhir baik."],
		7: ["Napasmu tertahan: moncong reptil menunduk ke arahmu.",
			"Sisik menangkap cahaya. Darah itu purba dan angkuh."],
	}
	var table: Dictionary = fr
	match Lang.code:
		"en": table = en
		"id": table = id
	var arr: Array = table.get(family, table[0])
	return arr[rng.range_i(0, arr.size())]

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
