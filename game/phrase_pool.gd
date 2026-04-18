class_name PhrasePool extends RefCounted
# Pool of narrative phrases for choices and outcomes.
# Tone integers: 0=AGGRESSIVE 1=DIPLOMATIC 2=CAUTIOUS 3=CURIOUS
# Outcome integers match FateEngine.Outcome: 0=CRIT_FAIL 1=FAIL 2=MIXED 3=SUCCESS 4=CRIT_SUCCESS

enum Tone { AGGRESSIVE, DIPLOMATIC, CAUTIOUS, CURIOUS }

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"Tu lèves ta lame sans un mot et t'avances.",
			"Tu charges, la peur transmuée en rage.",
			"Tu vises la gorge — un seul coup, précis.",
			"Tu frappes le premier, au cœur de son silence.",
			"Tu grondes une insulte et fonds sur lui.",
		]
		1: return [
			"Tu tends les paumes, ouvertes, et parles doucement.",
			"Tu murmures un mot ancien, espérant qu'il le reconnaisse.",
			"Tu t'agenouilles lentement, tête basse.",
			"Tu proposes un échange — ta voix tremble mais reste calme.",
			"Tu évoques ses ancêtres, ou ce que tu imagines d'eux.",
		]
		2: return [
			"Tu recules d'un pas mesuré, sans quitter son regard.",
			"Tu contournes lentement, à bonne distance.",
			"Tu te fonds dans l'ombre d'une racine et retiens ton souffle.",
			"Tu jettes une pierre plus loin, espérant le détourner.",
			"Tu attends qu'il se lasse, immobile comme la mort.",
		]
		3: return [
			"Tu t'approches pour examiner la marque sur son flanc.",
			"Tu ramasses un éclat tombé à ses pieds et l'observes.",
			"Tu tends l'oreille — un son étrange sort de sa gorge.",
			"Tu cherches du regard ce qu'il protège ainsi.",
			"Tu poses une question à voix haute, pour voir.",
		]
	return ["Tu fais un pas de côté."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	if tone == 0:  # AGGRESSIVE
		match outcome:
			4: return [
				"Ta lame trouve la brèche. %s s'effondre sans bruit. Quelque chose en toi approuve.",
				"Un coup parfait. %s chute avant d'avoir compris.",
			]
			3: return [
				"%s tombe au troisième échange. Tu respires.",
				"Le combat est bref. %s cède. Tu saignes un peu.",
			]
			2: return [
				"%s recule en boitant, mais tu n'es pas indemne.",
				"Vous vous séparez en silence. Chacun a perdu quelque chose.",
			]
			1: return [
				"Ton coup glisse. %s riposte et tu sens la chair s'ouvrir.",
				"%s esquive — ton élan te trahit. Tu paies.",
			]
			0: return [
				"%s te déchire avant même que tu aies posé le pied. Tu vacilles.",
				"Tu es déjà au sol. %s te regarde sans hâte.",
			]
	elif tone == 1:  # DIPLOMATIC
		match outcome:
			4: return [
				"%s s'incline. Un pacte silencieux passe entre vous. Il s'éloigne.",
				"Tes mots touchent un endroit ancien. %s baisse la tête et te laisse passer.",
			]
			3: return [
				"%s écoute. Les épaules tombent. Il s'en va sans regret.",
				"Vous trouvez un arrangement. Personne ne saigne aujourd'hui.",
			]
			2: return [
				"%s hésite, puis détourne le regard. C'est tout ce que tu obtiens.",
				"Il t'accorde un passage étroit, mais garde un œil méfiant.",
			]
			1: return [
				"%s ne comprend pas. Ou ne veut pas. Sa posture change.",
				"Tes mots glissent sur lui. Il s'avance, sans hâte.",
			]
			0: return [
				"%s prend tes paumes ouvertes pour une faiblesse. Il frappe.",
				"Tu as parlé. Tu n'aurais pas dû. %s réagit comme une bête.",
			]
	elif tone == 2:  # CAUTIOUS
		match outcome:
			4: return [
				"%s ne te voit jamais. Tu es déjà loin.",
				"Tu disparais comme une ombre. %s cherche encore quand le vent tourne.",
			]
			3: return [
				"Tu gagnes du terrain. %s perd ta trace.",
				"Tu mets assez de distance. Le souffle revient, lent.",
			]
			2: return [
				"Tu t'éloignes, mais il sait maintenant que tu étais là.",
				"Vous ne vous affrontez pas. Pour cette fois.",
			]
			1: return [
				"%s lève la tête — il t'a repéré. Tu cours.",
				"Ton pied brise une brindille. %s se tourne vers toi.",
			]
			0: return [
				"%s était déjà derrière toi depuis longtemps.",
				"Tu recules dans un autre piège. Le sol cède.",
			]
	elif tone == 3:  # CURIOUS
		match outcome:
			4: return [
				"Tu découvres un fragment qui change tout. Une mémoire s'ouvre.",
				"Tu comprends quelque chose que personne d'autre n'a jamais vu chez %s.",
			]
			3: return [
				"Un détail t'apprend quelque chose d'utile sur ce lieu.",
				"%s te laisse observer. Tu apprends.",
			]
			2: return [
				"Tu apprends un peu. Tu perds un peu.",
				"L'éclat que tu tiens bourdonne. Tu ne sais pas encore pourquoi.",
			]
			1: return [
				"Tu t'attardes trop. %s sent ta curiosité et s'en irrite.",
				"Ce que tu touches te touche en retour. Ça brûle.",
			]
			0: return [
				"Tu as regardé trop profondément. Quelque chose t'a vu aussi.",
				"Le fragment t'entaille la paume. %s se dresse. Tu as réveillé autre chose.",
			]
	return ["Rien ne se passe."]

static func pick_choice(rng: DRNG, tone: int) -> String:
	var arr: Array = choices_for(tone)
	return arr[rng.range_i(0, arr.size())]

static func pick_outcome(rng: DRNG, tone: int, outcome: int, creature_name: String) -> String:
	var arr: Array = outcomes_for(tone, outcome)
	var tpl: String = arr[rng.range_i(0, arr.size())]
	return tpl % creature_name

static func family_descriptor(family: int, tier: int) -> String:
	var base := ""
	match family:
		0: base = "le vagabond"        # HUMANOID
		1: base = "la bête"            # BEAST
		2: base = "le revenant"        # UNDEAD
		3: base = "le gardien de fer"  # CONSTRUCT
		4: base = "l'élémentaire"      # ELEMENTAL
		5: base = "la chose"           # ABERRATION
		6: base = "la silhouette fée"  # FEY
		7: base = "le draconide"       # DRACONIC
		_: base = "l'entité"
	if tier >= 3 and base.begins_with("le "):
		base = "le grand " + base.substr(3)
	elif tier >= 3 and base.begins_with("la "):
		base = "la grande " + base.substr(3)
	return base

static func biome_intro(biome: StringName, corruption: float) -> String:
	var base := ""
	match String(biome):
		"forest":    base = "Tu entres dans la forêt. Les feuilles étouffent tes pas."
		"city":      base = "Tu longes les murs d'une cité oubliée. Des yeux, partout."
		"ruins":     base = "Tu marches entre des pierres qui ont connu des siècles."
		"corrupted": base = "La terre est malade. Le sol palpite sous tes pieds."
		"anomaly":   base = "Rien ici n'obéit aux règles que tu connais."
		_:           base = "Tu avances."
	if corruption > 0.6: base += " Quelque chose te regarde sans yeux."
	return base
