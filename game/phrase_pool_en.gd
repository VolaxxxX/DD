class_name PhrasePoolEN extends RefCounted
# English narrative pack. Same API shape as PhrasePool.
# Tone integers: 0=AGGRESSIVE 1=DIPLOMATIC 2=CAUTIOUS 3=CURIOUS 4=DECEPTIVE 5=MYSTICAL
# Outcome integers match FateEngine.Outcome: 0=CRIT_FAIL 1=FAIL 2=MIXED 3=SUCCESS 4=CRIT_SUCCESS

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"You raise your blade without a word and step in.",
			"You charge, fear transmuted into fury.",
			"You aim for the throat — one strike, exact.",
			"You strike first, into the heart of its silence.",
			"You growl an insult and fall upon it.",
			"You feint left, strike right. It is your only plan.",
			"You spit in its face before you draw.",
			"You attack without a cry. A job to finish, nothing more.",
			"You picture its end, then make it real.",
			"You take the risk of one wide blow. If it misses, you die.",
			"You hurl whatever is in your hand — anything to close the distance.",
			"You open with a low blow. No time to be noble.",
			"You move in, coiled, the way a man strangles.",
			"You scream, hoping it hesitates. You give it no time to answer.",
		]
		1: return [
			"You open your palms and speak softly.",
			"You murmur an old word, hoping it remembers.",
			"You kneel, slowly, head bowed.",
			"You offer a trade — your voice trembles but holds.",
			"You invoke its ancestors, or what you imagine of them.",
			"You tell it your name. It is all you have to give.",
			"You hum a lullaby. You do not even know where it comes from.",
			"You ask what it is looking for. You truly listen.",
			"You talk of the road, the weather, anything but it.",
			"You ask it one simple question: why stay here?",
			"You swear you carry no weapon. You barely lie.",
			"You speak to it the way you would to a frightened child.",
			"You breathe it a secret. You already regret it.",
			"You tell it that it is free to leave. And so are you.",
		]
		2: return [
			"You step back, measured, never breaking its gaze.",
			"You circle wide, keeping your distance.",
			"You melt into the shadow of a root and hold your breath.",
			"You throw a stone far away, hoping to turn its head.",
			"You wait it out, still as the dead.",
			"You walk on the tips of your toes, as in a dream.",
			"You lie down in the tall grass. You become earth.",
			"You backtrack without a sound, following your own trail.",
			"You slip behind a trunk and count to ten.",
			"You pull off your boots and walk barefoot, slowly.",
			"You follow the wind — it will carry your scent away.",
			"You crouch in a ditch. The night will pass, perhaps.",
			"You play dead before the idea occurs to it.",
		]
		3: return [
			"You move closer to study the mark on its flank.",
			"You pick up a fallen shard and turn it over.",
			"You strain to hear — a strange sound rises from its throat.",
			"You look for whatever it is protecting.",
			"You ask a question out loud, just to see.",
			"You watch its shadow. It does not move like yours.",
			"You count its breaths. Something is wrong.",
			"You notice an old scar. You recognize a pattern in it.",
			"You fix on its hands. They tell a different story.",
			"You follow its gaze. Whatever it is staring at.",
			"You listen to the silence around it. It is too clean.",
			"You spot a detail no one else would see. You keep it.",
			"You wonder what it was, before.",
		]
		4: return [
			"You show one empty hand, the other on your dagger.",
			"You swear you are only a lost traveler. You are already counting its teeth.",
			"You fake an injury — one well-placed groan.",
			"You talk of the road, of the cold — while your fingers search.",
			"You offer a bargain you will never honor.",
			"You tell it you know someone. You do not.",
			"You perform fear, perfectly. You tremble the right way.",
			"You point at something behind it. And you act.",
			"You tell it there are others behind you. There is no one.",
			"You promise it a debt. You will never pay it.",
			"You swear on something sacred you invented yesterday.",
			"You give it a false name. You believe it enough that it might too.",
			"You act as if you know it. You even insist.",
		]
		5: return [
			"You trace an old sign in the dust without looking.",
			"You speak a word that belongs to no living tongue.",
			"You close your eyes and let something else watch for you.",
			"You lay your hand on the ground and listen to what the earth answers.",
			"You offer one drop of your blood to the wind. Just one.",
			"You recite a name you did not remember knowing.",
			"You reverse your breath: in on the out, out on the in.",
			"You mark an invisible circle around you and invite it inside.",
			"You offer one of your memories in exchange for a truth.",
			"You cut a lock of your hair and bury it.",
			"You whisper, backwards, a prayer you never learned.",
			"You touch the ground in three exact places. You never knew how you know.",
			"You offer your silence to whatever is listening. It is the most precious thing you have.",
		]
	return ["You step aside."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	if tone == 0:
		match outcome:
			4: return [
				"Your blade finds the gap. %s drops without a sound. Something in you approves.",
				"One perfect blow. %s falls before understanding.",
				"You strike once. It is enough. %s stands there a moment, then folds slowly.",
				"%s never gets the time to watch you die. You have already taken it apart.",
				"A brief, precise dance. When it stops, %s is on the ground.",
			]
			3: return [
				"%s falls on the third exchange. You breathe.",
				"The fight is short. %s yields. You bleed a little.",
				"You did what had to be done. %s will not rise again. Neither will you, entirely.",
				"You land the deciding blow at the right moment. %s staggers back, sways, does not return.",
				"You win, by sweat and by luck. %s stays down.",
			]
			2: return [
				"%s limps away, but you are not unhurt.",
				"You part in silence. Both of you lost something.",
				"You drive it back. It flees. You bleed, watching the road.",
				"The fight dissolves into confusion. You both stop, nothing settled.",
				"You hold the upper hand just long enough for it to decide to leave.",
			]
			1: return [
				"Your blow slides. %s answers and you feel flesh open.",
				"%s dodges — your momentum betrays you. You pay.",
				"You attack too soon. %s punishes you. You learn.",
				"Your blade finds bone, but it is yours. %s has not even bled.",
				"You miss what you aimed for. %s does not.",
			]
			0: return [
				"%s tears into you before your foot even lands. You reel.",
				"You are already down. %s watches, unhurried.",
				"What you took for a beast was a trap. It is closing.",
				"%s breaks something in you that will not mend quickly.",
				"You understand, too late, that you never should have.",
			]
	elif tone == 1:
		match outcome:
			4: return [
				"%s bows. A silent pact passes between you. It moves away.",
				"Your words touch something old. %s lowers its head and lets you pass.",
				"Something in %s recognizes something in you. You part as kin.",
				"%s answers you, at length. You learn more than you hoped.",
				"%s leaves you a token — small, precious. You will not forget.",
			]
			3: return [
				"%s listens. The shoulders drop. It leaves without regret.",
				"You find an arrangement. Nobody bleeds today.",
				"%s grants you the road. Not trust. But the road.",
				"%s grumbles something and walks past you. It is all you needed.",
				"Your voices touch for a moment. Then each takes back its own.",
			]
			2: return [
				"%s hesitates, then looks away. That is all you get.",
				"It grants you a narrow passage, but keeps one wary eye on you.",
				"%s does not answer, but does not attack either. You take it.",
				"You get a truce. Not peace — but better than war.",
				"%s shows you another path. You take it without question.",
			]
			1: return [
				"%s does not understand. Or will not. Its posture changes.",
				"Your words slide off it. It comes forward, unhurried.",
				"%s laughs. Not at all the way you hoped.",
				"You say too much, or too little. %s loses patience.",
				"Your words ring false even to you. To %s as well.",
			]
			0: return [
				"%s takes your open palms for weakness. It strikes.",
				"You spoke. You should not have. %s answers like a beast.",
				"%s replies with a word you do not understand. Then with something else.",
				"Something you said woke an old anger.",
				"%s silences you with a gesture that is not a human gesture.",
			]
	elif tone == 2:
		match outcome:
			4: return [
				"%s never sees you. You are already far away.",
				"You vanish like a shadow. %s is still searching when the wind turns.",
				"You pass behind it while it looks elsewhere. Flawless.",
				"%s passes within arm's reach and never sees you. You hold back your smile.",
				"You move like air. %s will never know you were here.",
			]
			3: return [
				"You gain ground. %s loses your trail.",
				"You put enough distance behind you. Breath returns, slow.",
				"You find a hollow in the ground. You almost sleep there.",
				"%s gives up after a few steps. You leave without looking back.",
				"You did it right — slow, exact. You walk out of here intact.",
			]
			2: return [
				"You slip away, but now it knows you were here.",
				"You do not fight. Not this time.",
				"You hide well enough to survive, not well enough to disappear.",
				"%s catches you from the corner of its eye, and lets you go.",
				"You flee. Something in %s decides that is enough.",
			]
			1: return [
				"%s lifts its head — you are seen. You run.",
				"Your foot snaps a twig. %s turns toward you.",
				"You believe you are hidden. %s has been tracking you from the start.",
				"%s had your scent before you ever moved.",
				"You hesitate too long. %s closes the distance in one leap.",
			]
			0: return [
				"%s was behind you all along.",
				"You back into another trap. The ground gives way.",
				"You flee in the wrong direction. There was another one.",
				"%s did not follow you. It was waiting where you were going.",
				"You hide where it hunts. It is a bad day.",
			]
	elif tone == 3:
		match outcome:
			4: return [
				"You find a fragment that changes everything. A memory opens.",
				"You understand something no one has ever seen in %s.",
				"The detail you study reveals far more than expected.",
				"You recognize the pattern. It is old, and it is useful.",
				"%s lets you look, unmoving. You learn in silence.",
			]
			3: return [
				"A detail teaches you something useful about this place.",
				"%s lets you watch. You learn.",
				"What you see will not be forgotten. You know something new.",
				"You gather three fragments into one thought. You leave richer.",
				"%s watches you watching. Neither of you moves. It is enough.",
			]
			2: return [
				"You learn a little. You lose a little.",
				"The shard in your hand hums. You do not yet know why.",
				"You carry something away, but you leave something behind.",
				"%s saw you looking. That matters, now.",
				"Now you know. You are no longer sure you wanted to.",
			]
			1: return [
				"You linger too long. %s feels your curiosity and hates it.",
				"What you touch touches back. It burns.",
				"%s understands that you are prying. It does not approve.",
				"You study something you should not have. Too long.",
				"You open a door that is not a door. You feel the cold.",
			]
			0: return [
				"You looked too deep. Something saw you too.",
				"The fragment slices your palm. %s rises. You have woken something else.",
				"You learn what you were never meant to know. The knowing costs you.",
				"%s understands what you understood. It prefers you dead with it.",
				"What you were watching is watching you now. And it is coming closer.",
			]
	elif tone == 4:
		match outcome:
			4: return [
				"%s believes you. You leave with what it had. It will not know until morning.",
				"Your lie is so perfect you almost believe it yourself. %s bows.",
				"You play the part flawlessly. %s even thanks you.",
				"%s walks away convinced it did a good deed. You barely smile.",
				"You get everything. %s never saw it coming.",
			]
			3: return [
				"%s doubts, but lowers its guard. Enough.",
				"You get what you wanted. %s leaves with half the coins.",
				"%s lets you pass. Later it will think that was strange.",
				"You gain an advantage. Not everything. But what matters.",
				"%s does not know it has just been had. That is the idea.",
			]
			2: return [
				"%s guesses part of the ruse. You win some, you lose some.",
				"Your smile holds. Just barely. You pass.",
				"You get what you wanted, but %s will remember.",
				"You share the lie. No one is fooled. No one says it.",
				"%s accepts the bargain. One day it will turn it against you.",
			]
			1: return [
				"%s reads your lie before you finish it. Its face changes.",
				"Your dagger trembles at the wrong moment. %s saw it.",
				"A tiny detail betrays you. %s does not miss details.",
				"%s stares at you. You feel you have already lost.",
				"Your accent betrays you, or your hands, or your eyes. It saw.",
			]
			0: return [
				"%s plays better than you. By the time you see it, it is too late.",
				"The trap was for you from the start. %s smiles.",
				"You thought you were cunning. %s was counting on it.",
				"You are not the liar in this story. %s is.",
				"You find the betrayal at the exact moment it costs you everything.",
			]
	elif tone == 5:
		match outcome:
			4: return [
				"Something answers. %s steps aside, as before a door.",
				"The sign holds. The world opens for one breath — and closes over your secret.",
				"Something immense recognizes you. %s backs away, smaller than before.",
				"You receive a name you will not dare repeat. But you know it.",
				"The rite succeeds. The world trembles for a second. You alone felt it.",
			]
			3: return [
				"A shiver crosses the air. %s backs away, uncertain.",
				"You hear a voice that is not yours. It gives you a direction.",
				"Something listens. And answers, in its way.",
				"The gesture works, small and clean. Something changes.",
				"You feel a thread drawn taut between you and something else. It is what you wanted.",
			]
			2: return [
				"The rite half-works. You gain a fragment. You pay a fragment.",
				"Something listens, but does not answer. Not yet.",
				"You get an answer. You are not sure you asked the right question.",
				"The sign barely holds. You learn something all the same.",
				"You touch the underside of the world, briefly. It touches back.",
			]
			1: return [
				"The words resist you. %s feels your weakness and comes closer.",
				"The wind refuses your offering. Your palm bleeds for nothing.",
				"You feel you have no right. The gesture turns on you.",
				"Something sneers in silence. You do not have the ear for it.",
				"You speak the wrong word. %s hears the error before you do.",
			]
			0: return [
				"You spoke what should not be spoken. Something old is watching you now.",
				"The sign turns against you. %s no longer needs to move.",
				"Something passes through you. You feel you are no longer alone, ever.",
				"You opened what was meant to stay shut. The price will be collected later.",
				"The rite succeeds, but not for you. %s claims what you called.",
			]
	return ["Nothing happens."]

# ---------- Contextual choice variants ----------
# Family order matches Archetype.Family:
# 0 HUMANOID, 1 BEAST, 2 UNDEAD, 3 CONSTRUCT, 4 ELEMENTAL, 5 ABERRATION, 6 FEY, 7 DRACONIC

static func family_choices(tone: int, family: int) -> Array:
	var pools := {}
	match tone:
		0: pools = {
			0: ["You aim for the knee — a man on the ground chases no one.",
				"You strike where its armor gapes, beneath the arm."],
			1: ["You aim for the muzzle — the pain will drive it back.",
				"You wait for it to pounce, then strike from below."],
			2: ["You aim for the legs — let it crawl, as it should have stayed.",
				"You strike at the bone. There is nothing else left to cut."],
			3: ["You search for the joint — every mechanism has a flaw.",
				"You strike the glow in its chest. That has to be the heart."],
			4: ["You strike the center of the whirl, where it holds together.",
				"You attack without asking what your blade can even cut here."],
			5: ["You strike without looking — seeing it whole costs too much.",
				"You aim for the eye. The middle one. The one that is fixed on you."],
			6: ["You strike before she finishes her sentence. Iron first.",
				"You betray every custom: attacking a fey. So be it."],
			7: ["You slip under its guard, toward the missing scale.",
				"You charge straight for the maw. Better to see it face on."],
		}
		1: pools = {
			0: ["You remind him you were of the same people, before all this.",
				"You hold out your ration. A man who eats, listens."],
			1: ["You lower your eyes and bare your throat. Pack language.",
				"You set meat down between you, and step back once."],
			2: ["You speak the words owed to the dead. Perhaps it was waiting for them.",
				"You ask who it is waiting for. The dead are always waiting for someone."],
			3: ["You state your name and your intent, clearly, like a protocol.",
				"You show the guardian your empty hands, palms to the sky."],
			4: ["You speak to the element as one speaks to the weather: demanding nothing.",
				"You address what moves it, not what it shows."],
			5: ["You think your sentence instead of saying it. Perhaps that is where it listens.",
				"You greet what it was before it became this."],
			6: ["You weigh every word — a pact with a fey is paid to the letter.",
				"You offer her one truth about yourself. The fey feed on those."],
			7: ["You address it by its titles. Dragons collect their names.",
				"You offer it the only shining thing you own."],
		}
		2: pools = {
			0: ["You raise your hands and back away — one step, then two, never turning your back."],
			1: ["You avoid its gaze and retreat into the wind, very slowly."],
			2: ["You skirt the edge of its territory — the dead rarely guard beyond it."],
			3: ["You hold perfectly still. Many guardians see only movement."],
			4: ["You find the place where the air is calm, and you stay there."],
			5: ["You stare at the ground. Above all, do not look at it directly."],
			6: ["You turn your coat inside out, as in the old stories."],
			7: ["You make yourself small among the rocks. No one outruns a dragon."],
		}
		3: pools = {
			0: ["You study his gear — where is it from, who paid for it?"],
			1: ["You read its flanks: scars of hunting, or of flight?"],
			2: ["You search its body for what killed it, the first time."],
			3: ["You look for the maker's mark beneath the rust."],
			4: ["You look for what feeds it. Every fire has a source."],
			5: ["You count its limbs. The result changes every time."],
			6: ["You look at her shadow — the fey do not always wear the right one."],
			7: ["You read its scales like annals. Every burn is a date."],
		}
		4: pools = {
			0: ["You invoke the name of an invented captain who would vouch for you."],
			1: ["You mimic the cry of a wounded packmate, farther off to the left."],
			2: ["You walk the way the dead walk. You become one of theirs."],
			3: ["You repeat the gesture carved on its plinth — perhaps a seal of passage."],
			4: ["You hurl your waterskin far away: let the water busy it elsewhere."],
			5: ["You think very hard about something else. Let it read something else."],
			6: ["You offer her a rigged bargain — a fey's game against a fey."],
			7: ["You flatter it — its pride weighs more than you do."],
		}
		5: pools = {
			0: ["You trace the traveler's sign in the air between you."],
			1: ["You breathe into your palm and offer your scent to the world."],
			2: ["You improvise the rite of rest. Clumsy, but with respect."],
			3: ["You lay your hand on its surface and listen for the maker's echo."],
			4: ["You name the element by its old name. The elements remember."],
			5: ["You open your mind, just a crack, to see what comes in."],
			6: ["You trace a circle of salt — all that you have left of it."],
			7: ["You swear on fire. The only tongue they all respect."],
		}
	return pools.get(family, [])

static func biome_choices(tone: int, biome: StringName) -> Array:
	var pools := {}
	match tone:
		2: pools = {
			&"forest":    ["You climb into the low branches and let the forest hide you."],
			&"city":      ["You melt into the frame of a dead doorway."],
			&"ruins":     ["You slip behind a slab of fallen wall."],
			&"corrupted": ["You follow the healthy veins of the ground, where the earth does not pulse."],
			&"anomaly":   ["You walk where the light falls straight. It is rare, here."],
			&"swamp":     ["You sink into the water up to your neck, among the reeds."],
			&"highland":  ["You press yourself flat against the rock, out of the wind."],
			&"crypt":     ["You snuff your lantern and count your steps in the dark."],
			&"coast":     ["You follow the tide line, where the sand erases your tracks."],
		}
		3: pools = {
			&"forest":    ["You read the claw marks on the trunks. A map takes shape."],
			&"city":      ["You decipher what remains of a sign. Someone lived here."],
			&"ruins":     ["You compare the carvings on the plinth with what stands before you."],
			&"corrupted": ["You study how the corruption has changed it — this one."],
			&"anomaly":   ["You toss a pebble and follow its arc. The arc is wrong."],
			&"swamp":     ["You follow the bubbles rising. Something breathes below."],
			&"highland":  ["You study the standing stones on the summit. An alignment."],
			&"crypt":     ["You read the names on the slabs. Its own may be among them."],
			&"coast":     ["You examine what the sea laid down in the night."],
		}
		5: pools = {
			&"forest":    ["You press your palm against the oldest tree and wait."],
			&"city":      ["You call the names of the former inhabitants, at random."],
			&"ruins":     ["You wake the echo of the stones with a word struck twice."],
			&"corrupted": ["You taste the corruption on a fingertip. To understand."],
			&"anomaly":   ["You pray in the wrong direction. Here, it might work."],
			&"swamp":     ["You entrust a wish to the black water and watch it take it."],
			&"highland":  ["You shout your name to the wind and listen to what it brings back."],
			&"crypt":     ["You light one candle for the dead — and one for yourself."],
			&"coast":     ["You write a word in the sand and let the wave take it."],
		}
	return pools.get(biome, [])

static func tier_choices(tone: int) -> Array:
	# Extra lines that only appear against ELITE+ creatures — the player should
	# feel the danger in the phrasing itself.
	match tone:
		0: return [
			"You know you cannot win. You strike anyway.",
			"One opening. One chance. You take it."]
		2: return [
			"Before such a thing, fleeing is no shame.",
			"You pray it has already eaten, and you back away."]
		3: return [
			"You burn every detail into memory. If you survive, it will be worth much."]
		5: return [
			"You invoke everything you know at once. It is now or never."]
	return []

static func biome_intro(biome: StringName, corruption: float) -> String:
	var base := ""
	match String(biome):
		"forest":    base = "You enter the forest. The leaves swallow your steps."
		"city":      base = "You walk the walls of a forgotten city. Eyes, everywhere."
		"ruins":     base = "You walk among stones that have known centuries."
		"corrupted": base = "The land is sick. The ground pulses underfoot."
		"anomaly":   base = "Nothing here obeys the rules you know."
		"swamp":     base = "The water festers. Every step frees an ancient smell."
		"highland":  base = "The wind cuts your breath. The sky is vast, indifferent."
		"crypt":     base = "The air smells of wet stone. You hear only your own breathing."
		"coast":     base = "Salt stings your eyes. Something far out is not driftwood."
		_:           base = "You walk on."
	if corruption > 0.6: base += " Something watches you without eyes."
	return base
