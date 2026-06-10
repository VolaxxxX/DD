class_name PhrasePoolEN extends RefCounted
# English narrative pack (compact). Same API shape as PhrasePool.

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"You raise your blade without a word and step in.",
			"You charge, fear transmuted into fury.",
			"You aim for the throat — one strike, exact.",
			"You strike first, into the heart of its silence.",
			"You take the risk of one wide blow. If it misses, you die.",
		]
		1: return [
			"You open your palms and speak softly.",
			"You kneel, slowly, head bowed.",
			"You offer a trade — your voice trembles but holds.",
			"You ask what it is looking for. You truly listen.",
			"You tell it your name. It is all you have to give.",
		]
		2: return [
			"You step back, measured, never breaking its gaze.",
			"You circle wide, keeping your distance.",
			"You melt into shadow and hold your breath.",
			"You throw a stone far away, hoping to turn its head.",
			"You wait it out, still as the dead.",
		]
		3: return [
			"You move closer to study the mark on its flank.",
			"You pick up a fallen shard and turn it over.",
			"You watch its shadow. It does not move like yours.",
			"You look for whatever it is protecting.",
			"You wonder what it was, before.",
		]
		4: return [
			"You show one empty hand, the other on your dagger.",
			"You swear you are only a lost traveler. You are already counting its teeth.",
			"You fake an injury — one well-placed groan.",
			"You offer a bargain you will never honor.",
			"You give it a false name. You believe it enough that it might too.",
		]
		5: return [
			"You trace an old sign in the dust without looking.",
			"You speak a word that belongs to no living tongue.",
			"You close your eyes and let something else watch for you.",
			"You offer one drop of your blood to the wind. Just one.",
			"You offer your silence to whatever is listening.",
		]
	return ["You step aside."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	var T := {
		0: { 4: ["Your blade finds the gap. %s drops without a sound.", "One perfect blow. %s falls before understanding."],
			 3: ["%s falls on the third exchange. You breathe.", "The fight is short. %s yields. You bleed a little."],
			 2: ["%s limps away, but you are not unhurt.", "You part in silence. Both of you lost something."],
			 1: ["Your blow slides. %s answers and flesh opens.", "You miss what you aimed for. %s does not."],
			 0: ["%s tears into you before your foot lands.", "You are already down. %s watches, unhurried."] },
		1: { 4: ["%s bows. A silent pact passes between you.", "Your words touch something old. %s lets you pass."],
			 3: ["%s listens. The shoulders drop. It leaves without regret.", "You find an arrangement. Nobody bleeds today."],
			 2: ["%s hesitates, then looks away. That is all you get.", "You get a truce. Not peace — but better than war."],
			 1: ["%s does not understand. Or will not. Its posture changes.", "Your words ring false even to you. To %s as well."],
			 0: ["%s takes your open palms for weakness. It strikes.", "Something you said woke an old anger."] },
		2: { 4: ["%s never sees you. You are already gone.", "You move like air. %s will never know you were here."],
			 3: ["You gain ground. %s loses your trail.", "You did it right — slow, exact. You leave intact."],
			 2: ["You slip away, but now it knows you were here.", "%s catches you from the corner of its eye, and lets you go."],
			 1: ["%s lifts its head — you are seen. You run.", "It had your scent before you ever moved."],
			 0: ["%s was behind you all along.", "It did not follow you. It was waiting where you were going."] },
		3: { 4: ["You find a fragment that changes everything.", "You understand something no one has ever seen in %s."],
			 3: ["A detail teaches you something true about this place.", "%s lets you watch. You learn."],
			 2: ["You learn a little. You lose a little.", "Now you know. You are no longer sure you wanted to."],
			 1: ["You linger too long. %s feels your curiosity and hates it.", "What you touch touches back. It burns."],
			 0: ["You looked too deep. Something looked back.", "%s understands what you understood. It prefers you dead with it."] },
		4: { 4: ["%s believes you. You leave with what it had.", "Your lie is so perfect you almost believe it yourself."],
			 3: ["%s doubts, but lowers its guard. Enough.", "It doesn't know it has been had. That is the idea."],
			 2: ["%s guesses part of the ruse. You win some, you lose some.", "You share the lie. No one is fooled. No one says it."],
			 1: ["%s reads your lie before you finish it.", "A tiny detail betrays you. %s does not miss details."],
			 0: ["%s plays better than you. By the time you see it, it is done.", "The trap was for you from the start. %s smiles."] },
		5: { 4: ["Something answers. %s steps aside, as before a door.", "The sign holds. The world opens for one breath."],
			 3: ["A shiver crosses the air. %s backs away, uncertain.", "Something listens. And answers, in its way."],
			 2: ["The rite half-works. You gain a fragment. You pay a fragment.", "You touch the underside of the world. It touches back."],
			 1: ["The words resist you. %s feels your weakness and comes closer.", "You mispronounce one word. %s hears the error before you do."],
			 0: ["You spoke what should not be spoken. Something old is watching now.", "The rite succeeds — for %s. It collects what you called."] },
	}
	var tone_d: Dictionary = T.get(tone, {})
	return tone_d.get(outcome, ["Nothing happens."])

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
