class_name SituationRegistryEN extends RefCounted
# English translation pack for SituationRegistry. Keyed by situation id.
# Choices appear in the SAME ORDER as the French canonical templates.

static func pack() -> Dictionary:
	return {
		&"inscription": {
			"title": "A stone covered in signs.",
			"choices": [
				{"text": "You trace the signs with your finger.", "good_narr": "An ancient word lights up inside you. You know one thing more.", "bad_narr": "The sign answers you. Something has written itself into your skin."},
				{"text": "You murmur the signs under your breath.", "good_narr": "The stone shivers. You receive more than you gave.", "bad_narr": "Something was listening. You should not have."},
				{"text": "You pass on without touching it.", "good_narr": "You leave in silence. Something watches you go without moving.", "bad_narr": "The sign calls you despite yourself. You look away in time."},
			]},
		&"collapse": {
			"title": "The ground gives way beneath your feet.",
			"choices": [
				{"text": "You leap for the ledge, measured.", "good_narr": "You land safe. Your breath comes back.", "bad_narr": "You miss the ledge. Something cracks in your arm."},
				{"text": "You sprint before it all comes down.", "good_narr": "You cross just as the stone gives. You are still running after.", "bad_narr": "An edge tears your thigh open as you pass."},
				{"text": "You lower yourself down to see what lies beneath.", "good_narr": "Under the passage you find something useful.", "bad_narr": "The bottom is deeper than expected. You climb back drained."},
			]},
		&"shrine": {
			"title": "A forgotten altar, still warm.",
			"choices": [
				{"text": "You lay a hand on the stone, in silence.", "good_narr": "A warmth passes through. One of your wounds closes cleanly.", "bad_narr": "Nothing happens. The altar has already given more than it could return."},
				{"text": "You offer a drop of blood to the groove.", "good_narr": "Something accepts. The world seems sharper to you.", "bad_narr": "Something accepts too eagerly. You feel a new weight."},
				{"text": "You break the stone with one sharp blow.", "good_narr": "Under the stone, a useful fragment. You pocket it.", "bad_narr": "Under the stone, an eye. It looks at you. You step back."},
			]},
		&"stranger": {
			"title": "A hooded figure holds out a purse.",
			"choices": [
				{"text": "You accept the gift, with thanks.", "good_narr": "The purse holds exactly what you needed.", "bad_narr": "The purse was a gift. The contract was not written."},
				{"text": "You take the purse and run.", "good_narr": "You vanish with what it offered. No one cries out.", "bad_narr": "Something strikes your back as you flee."},
				{"text": "You refuse, politely, and pass on.", "good_narr": "The figure bows and dissolves into the fog.", "bad_narr": "When you turn around, it is already gone. You are not sure it ever existed."},
			]},
		&"storm": {
			"title": "A storm falls on you, brutal.",
			"choices": [
				{"text": "You burrow under an overhang of stone.", "good_narr": "You wait it out. The world smells of wet and of burning.", "bad_narr": "The storm lasts longer than your patience."},
				{"text": "You walk into it, head down.", "good_narr": "You come out soaked but hardened.", "bad_narr": "The hail splits your lip, your brow, your leather."},
				{"text": "You raise your arms and call the wind.", "good_narr": "The wind listens to you. Briefly. But it listens.", "bad_narr": "The wind answers. It says your name."},
			]},
		&"blood_trail": {
			"title": "A trail of fresh blood leads toward the trees.",
			"choices": [
				{"text": "You follow the trail, in silence.", "good_narr": "At its end, a fresh corpse. And something useful on it.", "bad_narr": "At its end, the thing that bled. Still alive. Wrong."},
				{"text": "You erase the trail so no one follows you.", "good_narr": "No one will find you here. That is a good thing.", "bad_narr": "Erasing takes time. Too much time."},
				{"text": "You head the opposite way.", "good_narr": "You move off. Much later, you hear something scream back there.", "bad_narr": "You move off. But the trail is in front of you now too."},
			]},
		&"deep_well": {
			"title": "A well cut straight into the stone. The water is still.",
			"choices": [
				{"text": "You lean over the edge. You see your reflection — then something else.", "good_narr": "The other face tells you what you need to know, then vanishes.", "bad_narr": "The other face smiles at you. You pull back. Too late."},
				{"text": "You murmur your name into the well.", "good_narr": "The well answers with your own voice, younger. An old breath returns to you.", "bad_narr": "The well answers with your voice, but it says something other than what you said."},
				{"text": "You drop a stone and listen for the bottom.", "good_narr": "You count for a long time. You learn the depth. You leave reassured.", "bad_narr": "You never hear the stone touch bottom."},
			]},
		&"beggar_child": {
			"title": "A child sitting on the road. Thin. Silent.",
			"choices": [
				{"text": "You give him half your provisions.", "good_narr": "He looks at you without a word. Later, you will find a coin in your pocket that you never had.", "bad_narr": "He swallows it all in silence and bolts. You realize what you have just given away."},
				{"text": "You ask his name — and rifle through his bundle.", "good_narr": "You find something precious. The child weeps but does not follow you.", "bad_narr": "The child raises his eyes. They are too old. Far too old."},
				{"text": "You pretend not to see him and walk past.", "good_narr": "You pass. You are no better and no worse than before.", "bad_narr": "You feel his gaze on the back of your neck for miles."},
			]},
		&"crossroads": {
			"title": "The path divides. To the left, silence. To the right, birds.",
			"choices": [
				{"text": "You go toward the silence.", "good_narr": "You find something no one wanted you to find.", "bad_narr": "The silence was not a silence. It was a waiting."},
				{"text": "You go toward the birds.", "good_narr": "You walk inside the song. The road is safe, for today.", "bad_narr": "The birds stop dead. It was not for you that they were singing."},
				{"text": "You close your eyes and follow what pulls inside you.", "good_narr": "You take the third road — the one you only see with your eyes shut.", "bad_narr": "You walk a long time. You find yourself at the same crossroads. Three times."},
			]},
		&"burning_tree": {
			"title": "A tree burns. No smoke. No heat.",
			"choices": [
				{"text": "You lay your hand on the bark. The flame passes through you.", "good_narr": "You feel an old knowledge run through you. You will not dare to share it.", "bad_narr": "The flame passes through you, yes. But it leaves something behind on the way."},
				{"text": "You fell the tree. The flame stops dead.", "good_narr": "The tree falls in silence. The flame goes out. The world seems simpler.", "bad_narr": "The tree bleeds. Not sap. Blood. It strikes you as it falls."},
				{"text": "You look away and keep walking.", "good_narr": "You leave. Later, you will no longer be able to say if you truly saw it.", "bad_narr": "You leave. The tree walks behind you for six steps. You do not dare turn around."},
			]},
		&"warm_carcass": {
			"title": "A carcass, still warm. No tracks around it.",
			"choices": [
				{"text": "You examine the wounds. What killed this was no beast.", "good_narr": "You understand something about the killer. Perhaps you will know how to avoid it.", "bad_narr": "You understand something about the killer. You should not have."},
				{"text": "You take the meat. Too bad for the rest.", "good_narr": "You eat. You set out stronger. It was what you needed.", "bad_narr": "You eat. Something in the flesh was never meant to be eaten."},
				{"text": "You leave without touching it. You leave fast.", "good_narr": "You leave. It is probably the best decision you have made today.", "bad_narr": "You leave. Something watches you from the nearest tree."},
			]},
		&"the_double": {
			"title": "At the end of the path, someone. He has your face.",
			"choices": [
				{"text": "You attack without hesitation. There is no room for two of you.", "good_narr": "You strike him. He crumbles like black glass. You take a shard with you.", "bad_narr": "You strike your own face. You feel the cut on yours."},
				{"text": "You speak to him. You ask him who he is.", "good_narr": "He answers softly. He teaches you something you had forgotten.", "bad_narr": "He repeats your every word, backwards. Then he takes your shadow."},
				{"text": "You avert your eyes and give him a wide berth.", "good_narr": "You pass. He stays there, motionless. You do not look back.", "bad_narr": "You pass. You feel he has taken your place on the path you just left."},
			]},
		&"broken_statue": {
			"title": "A broken statue, half-buried. The face is missing.",
			"choices": [
				{"text": "You set upright what you can. You clean the stone.", "good_narr": "You make a small, just gesture. Something in you realigns.", "bad_narr": "You work a long time. You no longer know why. You have gained nothing."},
				{"text": "You search the base. Statues often hide things.", "good_narr": "You find a hollow. In the hollow, something left there for you.", "bad_narr": "You find a hollow. Something was in it. Now it follows you."},
				{"text": "You press your forehead to the stone. You listen.", "good_narr": "The stone tells you of the war it saw. It was long ago.", "bad_narr": "The stone remembers. It wants you to remember too."},
			]},
		&"buried_pilgrim": {
			"title": "Half-buried bones still clutch a pendant.",
			"choices": [
				{"text": "You dig out the pendant. It is warm.", "good_narr": "The pendant wakes an old knowledge. You understand why he walked here.", "bad_narr": "The pendant opens. Something inside looks at you before you snap it shut."},
				{"text": "You speak a blessing and leave everything in place.", "good_narr": "A peace passes through you. You carry one fear less.", "bad_narr": "Your words are lost. You pray too long. The cold takes you."},
				{"text": "You tear the pendant free with one sharp pull.", "good_narr": "You have it. It weighs more than its size.", "bad_narr": "A broken root claws your arm. Perhaps it was not a root."},
			]},
		&"iron_door": {
			"title": "A sealed iron door stands where nothing should be.",
			"choices": [
				{"text": "You drive your shoulder into it. Once. Again.", "good_narr": "The lock gives. Behind it: a hollow that smells of gold. You leave laden.", "bad_narr": "Something in your arm gave way before the door did."},
				{"text": "You press your palm to it and listen to what sleeps behind.", "good_narr": "What sleeps behind entrusts you with a name. You keep it.", "bad_narr": "What sleeps behind has woken. It follows you, now."},
				{"text": "You turn back without touching the door.", "good_narr": "You leave. The door is gone when you look back. Just as well.", "bad_narr": "You leave. But you know you will return. You already know when."},
			]},
		&"wounded_merc": {
			"title": "A wounded mercenary reaches out a hand to you.",
			"choices": [
				{"text": "You kneel and bind his wound.", "good_narr": "He entrusts you his blade before closing his eyes. You gain more than you think.", "bad_narr": "Leaning in, you slip. His blade falls and marks your thigh."},
				{"text": "You are already going through his pockets while you speak softly.", "good_narr": "You find three coins, a map, a seal. He saw nothing.", "bad_narr": "His hand grips your wrist, stronger than it should be. He whispers a word."},
				{"text": "You cut his suffering short with one clean stroke.", "good_narr": "It was the just thing to do. You take his ring.", "bad_narr": "His eyes never leave you. You still see them when you close your own."},
			]},
		&"cold_fork": {
			"title": "Two paths. The wind blows down only one.",
			"choices": [
				{"text": "You take the one that blows. You want to know where the wind comes from.", "good_narr": "At its end, a silent overlook. You understand a thing no one should.", "bad_narr": "At its end, what was blowing. It had a mouth. It saw you."},
				{"text": "You take the other. No wind, no surprises.", "good_narr": "The path is gentle. Your strength returns.", "bad_narr": "The path is so calm you doubt you chose it. You walk a long time."},
				{"text": "You ask the crossing a question, out loud.", "good_narr": "The crossroads answers — on one side, with wind; on the other, with silence. You know which to take.", "bad_narr": "The crossroads heard you. It offers a third road. You come out of it, later, with no memory of what was there."},
			]},
		&"caged_beast": {
			"title": "A wounded wolf, caught in an iron cage. The bars are rusted.",
			"choices": [
				{"text": "You speak to it softly while you work out the mechanism.", "good_narr": "The wolf moves off without a growl. Perhaps one day it will come back to defend you.", "bad_narr": "You get too close. Its jaws snap shut, faster than your hand."},
				{"text": "You smash the cage in with a stone.", "good_narr": "The cage gives. The wolf bolts. You find a few coins in the trap.", "bad_narr": "The stone ricochets. Something in your wrist gave way before the cage did."},
				{"text": "You pass on. This is not your fight.", "good_narr": "The wolf follows you with its eyes. You do not know if it is grudge or memory.", "bad_narr": "Later, in the night, you hear a howl. It says your name."},
			]},
		&"burning_library": {
			"title": "A ruined library. A few books still smolder. One unburned page drifts toward you.",
			"choices": [
				{"text": "You catch the page and read it before it goes out.", "good_narr": "Three words. A name. A date. You now know something the living have forgotten.", "bad_narr": "The words enter your skin and stay. They bleed when you think."},
				{"text": "You rush in to save more books.", "good_narr": "You haul out half a shelf, burned but rich.", "bad_narr": "The roof comes down. You crawl out on all fours, your back torn open."},
				{"text": "You let the ash speak to you.", "good_narr": "The voices pass through you and lighten you. A curse departs with the smoke.", "bad_narr": "A thousand voices scream the same word at you. It is not yours."},
			]},
		&"ferryman": {
			"title": "A silent ferryman holds out his hand. His boat does not quite touch the water.",
			"choices": [
				{"text": "You pay in coin, politely, asking no questions.", "good_narr": "The far shore arrives sooner than expected. You gain time.", "bad_narr": "The moment you step ashore, something in you is missing. A year, perhaps."},
				{"text": "You slip him painted lead coins.", "good_narr": "He smiles, pockets the coins without looking. You leave richer.", "bad_narr": "He turns around in the middle of the water. He knows every one of your lies."},
				{"text": "You offer him your name instead of money.", "good_narr": "He accepts. You cross, lighter by one name. You will have others left.", "bad_narr": "He takes the name and keeps it. You will remember the consequences later."},
			]},
		&"hanging_cage": {
			"title": "A cage hanging from a tree. A man inside. Alive.",
			"choices": [
				{"text": "You ask him why.", "good_narr": "He teaches you three things about this land you did not know.", "bad_narr": "He laughs, for a long time. You do not forget that laugh."},
				{"text": "You cut the rope.", "good_narr": "He crashes down, thanks you, hands you a ring and flees.", "bad_narr": "The cage falls. On you. The man's arm too."},
				{"text": "You turn back before he sees you.", "good_narr": "You leave in silence. He does not move.", "bad_narr": "You see him watching you in your dream, that night."},
			]},
		&"path_doll": {
			"title": "A child's doll, set upright in the middle of the path. The eyes are painted on.",
			"choices": [
				{"text": "You bend down to examine it.", "good_narr": "Under the doll, a tiny trapdoor. Under the trapdoor, something useful.", "bad_narr": "The eyes blink. Once. You leave. You look back. It is gone."},
				{"text": "You step on it as you pass.", "good_narr": "Nothing. Just a crunch of porcelain.", "bad_narr": "Something screams inside your head. A child's voice. Yours, perhaps."},
				{"text": "You speak its name — the one you never learned.", "good_narr": "The doll bows gently. An old fear leaves you.", "bad_narr": "You spoke the right name. Now it knows yours."},
			]},
		&"bear_trap": {
			"title": "A bear trap, jaws open. There is still blood on it, fresh.",
			"choices": [
				{"text": "You go around it, marking the spot.", "good_narr": "You learn to read this kind of sign. You will avoid others.", "bad_narr": "You tell yourself you will remember. You will remember half of it."},
				{"text": "You spring it with a branch to examine it.", "good_narr": "The mechanism is ingenious. You learn to build one.", "bad_narr": "The branch snaps sooner than expected. The trap bites your forearm."},
				{"text": "You trigger the trap with a kick.", "good_narr": "Loud but safe. You leave unharmed.", "bad_narr": "A shard of metal cuts your thigh."},
			]},
		&"echo_cave": {
			"title": "A mouth of stone. Inside, your own echo answers one second late.",
			"choices": [
				{"text": "You shout your name. You listen to what comes back.", "good_narr": "The echo says your name — then three others. You understand who you have forgotten.", "bad_narr": "The echo says your name — then the name of your death. You retain it despite yourself."},
				{"text": "You sing the silence — four notes no one ever taught you.", "good_narr": "The cavern takes up your song. Something in you comes undone.", "bad_narr": "The song goes on after you fall silent. You leave drained."},
				{"text": "You shout a false name to see if the cavern follows.", "good_narr": "It follows. You learn that it is dumb. That is precious to know.", "bad_narr": "It does not follow. It shouts the true name instead. And snickers."},
			]},
		&"ancient_gate": {
			"title": "A stone arch with no door. On the other side, the landscape is not the same.",
			"choices": [
				{"text": "You walk through.", "good_narr": "You come back out the same side, later. You know something. You will never be able to say it.", "bad_narr": "You come back, but otherwise. Something follows you, at your back, half a step behind."},
				{"text": "You toss a pebble and wait.", "good_narr": "The pebble does not come back. You know enough. You leave.", "bad_narr": "The pebble comes back — warm. You leave fast, but not fast enough."},
				{"text": "You lay your hand on the arch.", "good_narr": "Something very old answers you. You leave lightened.", "bad_narr": "Something very old knows you, now."},
			]},
		&"lost_letter": {
			"title": "A rain-stained letter, still legible. The handwriting trembles. It is addressed to you.",
			"choices": [
				{"text": "You read it to the end.", "good_narr": "Someone, somewhere, guessed that you would come here.", "bad_narr": "The letter is from you. Older. With a warning you can no longer follow."},
				{"text": "You tear it up without reading it.", "good_narr": "The wind carries off the pieces. You feel lighter.", "bad_narr": "The ink sticks to your fingers. You read the contents later, in a dream, unable to stop."},
				{"text": "You fold it and set it on a stone, to return it to whoever knows.", "good_narr": "Three zones on, someone hands you a coin. For the letter, he says.", "bad_narr": "You lose it along the way. Someone will read it, no doubt."},
			]},
		&"sleeping_giant": {
			"title": "A colossal figure asleep on the hillside. The ground rises and falls with its breathing.",
			"choices": [
				{"text": "You make a wide detour, without a sound.", "good_narr": "You pass. The giant goes on breathing. You learn that not every fear wakes.", "bad_narr": "The detour is longer than your patience."},
				{"text": "You move closer, to see its face.", "good_narr": "Its face looks like yours, but older. You learn what you may become.", "bad_narr": "It opens one eye. It looks at you for a second. It closes it. You will never sleep the same."},
				{"text": "You murmur a word close to its ear.", "good_narr": "It smiles in its sleep. It teaches you another word. A greater one.", "bad_narr": "It teaches you a word. You can never again say it aloud without waking it."},
			]},
		&"cursed_coin": {
			"title": "A gold coin in the hollow of a rock. It gleams as if someone had just set it down.",
			"choices": [
				{"text": "You take it without hesitation.", "good_narr": "It is surprisingly heavy. You leave richer. For now.", "bad_narr": "The coin burns into your palm. It carries your mark now."},
				{"text": "You stare at it a long time without touching it.", "good_narr": "You learn to recognize traps that are too beautiful. You leave.", "bad_narr": "You leave without taking it. It appears in your pocket, later."},
				{"text": "You replace it with another coin.", "good_narr": "Your trick is played. You keep the real one. The next traveler takes the false.", "bad_narr": "You thought you were playing. You only chose a different trap."},
			]},
		&"whisper_dark": {
			"title": "A whisper in the darkness. It knows your name. It says it has a question for you.",
			"choices": [
				{"text": "You tell it: ask your question.", "good_narr": "Its question is simple. You have known the answer for a long time. You say it. The whisper departs, satisfied.", "bad_narr": "Its question has no answer. You invent one. It knows you are lying."},
				{"text": "You scream into the dark to drown it out.", "good_narr": "Your cry lasts longer than its own. You leave.", "bad_narr": "Something answers you, twice as loud. You leave staggering."},
				{"text": "You play dead, motionless.", "good_narr": "The whisper passes you by. You learn that some fears have no scent.", "bad_narr": "It circles you, slowly, for a long time. In the end it brushes the back of your neck."},
			]},
		&"snake_oil": {
			"title": "A merchant by the roadside offers a vial \"that cures everything\".",
			"choices": [
				{"text": "You haggle at length, feigning interest.", "good_narr": "He finally gives up a true vial, out of fatigue. You leave with a real remedy.", "bad_narr": "He talks more than you, for a long time. You leave exhausted, with nothing."},
				{"text": "You ask him what is really in it.", "good_narr": "He laughs, gives you the real thing he had kept for himself. A wound closes.", "bad_narr": "He smiles, hands you the vial. You drink. It was the wrong one."},
				{"text": "You take a vial from him and walk away.", "good_narr": "He does not pursue you. You find the real vial later.", "bad_narr": "You drink to quiet your thirst. You understand your mistake too late."},
			]},
		&"frozen_pool": {
			"title": "A pool of frozen water in high summer. Something stirs, slowly, beneath the ice.",
			"choices": [
				{"text": "You smash the ice open to see.", "good_narr": "Under the ice, a fish, enormous, motionless. You leave with a scale — useful.", "bad_narr": "Under the ice, a face. Open. Watching you. You close the hole in a hurry."},
				{"text": "You go around it, without looking.", "good_narr": "The cold wraps you gently, washes you. You leave refreshed.", "bad_narr": "The way around is longer than expected. You walk a long time."},
				{"text": "You lay your hand on the ice and listen.", "good_narr": "The ice tells you of three winters. You learn more than you thought possible.", "bad_narr": "The ice drinks your warmth. You pull your hand back too late."},
			]},
		&"empty_shoes": {
			"title": "A pair of small shoes, lined up in the middle of the path. No one around.",
			"choices": [
				{"text": "You turn back without hesitating.", "good_narr": "You walk a long way, but you feel lighter for having fled a story that was not yours.", "bad_narr": "You walk a long way. Too long."},
				{"text": "You bury the shoes under a stone, murmuring a word.", "good_narr": "You leave at peace. Somewhere, something thanks you without a sound.", "bad_narr": "While you bury them, you hear small footsteps circling you."},
				{"text": "You pick them up and look for the owner.", "good_narr": "You find a small abandoned village. In it, something useful.", "bad_narr": "You find a child walking barefoot. He looks at you. You can never forget."},
			]},
		&"fallen_comet": {
			"title": "A burning shard fallen from the sky. The ground smokes around it. It breathes, barely.",
			"choices": [
				{"text": "You break it open to see what is inside.", "good_narr": "Inside, a fragment hard as bone, shining. You slip it into your pocket.", "bad_narr": "It bursts in your hands. A burning splinter tears your palm open."},
				{"text": "You lay your hand on it to listen.", "good_narr": "It tells you where it came from. You now know the name of a star.", "bad_narr": "It writes its name into your skin. It burns for a long time."},
				{"text": "You wait for it to cool before deciding.", "good_narr": "You leave with a warm fragment, easier to carry.", "bad_narr": "It cools too fast. It has nothing left to give."},
			]},
		&"mad_vagabond": {
			"title": "A vagabond laughs alone, talks to a bush, answers it. He holds a small shining object.",
			"choices": [
				{"text": "You ask him what he is saying to the bush.", "good_narr": "He tells you a thing no one else would have said. That thing will serve you.", "bad_narr": "He tells you a thing no one should say. You have heard it."},
				{"text": "You steal the small object while he laughs.", "good_narr": "The object is useful. He does not even notice.", "bad_narr": "He stops laughing. He looks at you — clear, lucid. Never again will you steal from him unpunished."},
				{"text": "You pass on without looking at him.", "good_narr": "You leave. He keeps laughing at your back.", "bad_narr": "You leave. He stops laughing at that very instant. You do not know why."},
			]},
		&"charred_map": {
			"title": "A map charred at the edges. It shows this land — with marks you have never seen.",
			"choices": [
				{"text": "You study the marks carefully.", "good_narr": "You recognize one place, perhaps two. It will serve you later.", "bad_narr": "You spend too long on it. The day fades before you have learned anything."},
				{"text": "You lay the map over the ground with a ritual gesture.", "good_narr": "The ground adjusts itself slightly to the map. You see something in it that was not there before.", "bad_narr": "The ground adjusts too much. Something was waiting for someone to do exactly that."},
				{"text": "You fold it and pocket it for later.", "good_narr": "You decide to think on it later. Perhaps you never will.", "bad_narr": "You forget to read it. The map disappears from your pocket, afterwards."},
			]},
		&"head_pole": {
			"title": "A severed head set on a stake. The eyes follow yours when you move.",
			"choices": [
				{"text": "You ask it its name.", "good_narr": "It answers. It tells you what happened here. You will know how to avoid its own mistake.", "bad_narr": "It tells you your name. Not its own. You leave fast."},
				{"text": "You knock it down with a kick.", "good_narr": "It rolls, falls silent. You leave in peace.", "bad_narr": "It rolls away screaming your name. You will hear it again later."},
				{"text": "You place a coin in its mouth.", "good_narr": "It falls silent. Something heavy leaves you.", "bad_narr": "It swallows the coin and asks for the next one. And the next."},
			]},
		&"festival_lights": {
			"title": "At the end of a deserted street, lit lanterns sway above empty tables. Not a sound.",
			"choices": [
				{"text": "You sit down at a table as if you were expected.", "good_narr": "Someone brings you an invisible dish. You eat. Something ancient passes through you.", "bad_narr": "You eat. You stand up. You no longer remember several hours."},
				{"text": "You snatch a lantern and leave in a hurry.", "good_narr": "You leave with a lantern that never goes out.", "bad_narr": "The lantern follows you. Forever. You will learn to sleep with it."},
				{"text": "You make a wide detour, without entering the street.", "good_narr": "You will never know what happened there. It is probably better.", "bad_narr": "You will dream of the street. Often."},
			]},
		&"breathing_earth": {
			"title": "A patch of earth rises and falls, like a sleeping chest. Gently.",
			"choices": [
				{"text": "You lay your palm on it and match your breath to its own.", "good_narr": "The earth calms you. An old fear settles.", "bad_narr": "Your breath takes on its breath. You leave a little sick — the earth, no doubt, is better for it."},
				{"text": "You drive your blade into it to see.", "good_narr": "It bleeds — a little. You leave with a handful of extraordinary brown earth.", "bad_narr": "It bleeds — a lot. The blood is not red."},
				{"text": "You walk the widest possible circle around it.", "good_narr": "You leave. The silence is total afterwards.", "bad_narr": "The circle is larger than you thought. You walk until nightfall."},
			]},
		&"carriage_wreck": {
			"title": "An overturned carriage, the horses gone, a trunk thrown open. Cloth still drifts in the air.",
			"choices": [
				{"text": "You search the trunk.", "good_narr": "You find a useful ring and an interesting letter.", "bad_narr": "Something in the trunk bites your hand — a lively mechanical trap."},
				{"text": "You put everything back as if you had never come.", "good_narr": "You leave with two coins and an excellent conscience.", "bad_narr": "You put it all back well. But you forget something. You will not know what."},
				{"text": "You look for the horses first.", "good_narr": "You find a wounded horse, tend it, ride on with it.", "bad_narr": "You do not find them. Night falls."},
			]},
		&"dreaming_fish": {
			"title": "An immense fish, beached on the sand, alive. It does not struggle. It sleeps. It dreams.",
			"choices": [
				{"text": "You touch its flank and dream with it for a moment.", "good_narr": "You learn what a being dreams that has never known fear.", "bad_narr": "You learn its dream. It becomes yours. You are no longer sure you are awake."},
				{"text": "You push it gently toward the water.", "good_narr": "It half-wakes, looks at you, swims off. Later, you will find a gift on the beach.", "bad_narr": "It is heavier than you thought. It takes all your strength."},
				{"text": "You cut a piece from it to eat.", "good_narr": "You eat your fill and keep the rest.", "bad_narr": "Its flesh is not made for the living. You vomit for a long time."},
			]},
		&"singing_crowns": {
			"title": "Three crowns set in a circle. When the wind blows, they sing — each one note.",
			"choices": [
				{"text": "You join their song with your voice.", "good_narr": "You learn a fourth note. No one else knows it.", "bad_narr": "One crown falls silent when you sing. Now you know which one."},
				{"text": "You take one and leave.", "good_narr": "It is heavy. But it weighs less than your future.", "bad_narr": "The two that remain begin to scream your name. For a long time."},
				{"text": "You ask the crowns a question.", "good_narr": "They answer you one after another. You now know who was king here.", "bad_narr": "They answer all at once. You understand nothing. You leave."},
			]},
		&"night_fire": {
			"title": "A fire by the roadside. A traveler beckons: come, sit.",
			"choices": [
				{"text": "You sit down. You listen to what he has to say.", "good_narr": "You share bread and three stories. You leave with something in your belly and in your head.", "bad_narr": "The bread he hands you has a strange taste. You only notice after you have eaten it."},
				{"text": "You accept the welcome, but sleep with a hand on your dagger.", "good_narr": "You wake early. He still sleeps. You take what pleases you from his pack.", "bad_narr": "He wakes first. He knew that look."},
				{"text": "You give thanks and camp farther on.", "good_narr": "You sleep a short but safe sleep. By morning he is gone, leaving no trace.", "bad_narr": "You camp farther on. You do not sleep. You listen to the wind all night."},
			]},
		&"wild_herbs": {
			"title": "A clearing. Herbs you recognize — some heal, some kill.",
			"choices": [
				{"text": "You sort them patiently, following what you know.", "good_narr": "You find the right combination. A wound closes cleanly.", "bad_narr": "You confuse two leaves. You realize it by the taste."},
				{"text": "You let your instinct guide you without thinking.", "good_narr": "You chew a leaf. Something in you settles.", "bad_narr": "The instinct was not yours. You chew what you should not have."},
				{"text": "You gather everything; you will sort it later.", "good_narr": "You leave with a full bag. You will find a use for it.", "bad_narr": "Gathering takes time. You spend more of it than you should."},
			]},
		&"old_hunter": {
			"title": "An old hunter, crouched, points a finger. \"A boar, two steps on. Help me or move along.\"",
			"choices": [
				{"text": "You accept. You run to drive it out.", "good_narr": "The boar falls. The hunter gives you a cut of meat and a knife.", "bad_narr": "The boar charges you. The hunter arrives too late."},
				{"text": "You refuse. You continue on your way.", "good_narr": "You leave. Later, you smell roasting meat behind you. You have no regrets.", "bad_narr": "You leave. The hunter says nothing. He does not forget."},
				{"text": "You ask him instead if he has seen other travelers.", "good_narr": "He recounts three encounters. You now know who walks this land.", "bad_narr": "He does not listen. He stares at the bush. He walks off without answering."},
			]},
		&"friendly_raven": {
			"title": "A raven lands on your shoulder. It does not flee. It looks you in the eye.",
			"choices": [
				{"text": "You talk to it, calmly, as to a fellow traveler.", "good_narr": "It croaks three times. You understand every croak. You know one thing more.", "bad_narr": "It flies off without answering. You wonder what it would have said."},
				{"text": "You offer it a poisoned crumb, to see.", "good_narr": "It refuses. You learn that it was wiser than you. You leave in silence.", "bad_narr": "It accepts. It swallows. It looks at you, long, before falling. You carry it with you."},
				{"text": "You follow it when it takes flight.", "good_narr": "It leads you to a shortcut. You gain hours.", "bad_narr": "It leads you far, then vanishes. You retrace your steps."},
			]},
		&"sea_cave": {
			"title": "A sea cave. The sand glitters — metal, perhaps. The tide is rising.",
			"choices": [
				{"text": "You plunge your hand into the sand.", "good_narr": "A fistful of ancient coins. And a ring that never tarnishes.", "bad_narr": "Something bites your hand — an enormous crab, hidden."},
				{"text": "You wait for the tide to go out to see better.", "good_narr": "When the water withdraws, you see exactly what to take.", "bad_narr": "The tide takes its time. Night catches you."},
				{"text": "You sing for the sea before touching anything.", "good_narr": "The water listens. You leave lightened of a curse, with a useful shell.", "bad_narr": "The water rises faster than expected. You get out soaked, heart pounding."},
			]},
		&"brackish_spring": {
			"title": "A spring of brackish water. The taste is foul. But it is still water.",
			"choices": [
				{"text": "You drink carefully, in small sips.", "good_narr": "You quench your thirst. It is enough to go on.", "bad_narr": "The taste was not only bitter. You feel it later."},
				{"text": "You study what grows around it before drinking.", "good_narr": "You see the marks on the stones. The spring runs purer higher up.", "bad_narr": "Nothing useful. You decide not to drink. You leave thirsty."},
				{"text": "You fill your flask and leave.", "good_narr": "You will have water for two days. That is precious.", "bad_narr": "The flask stains brown. You realize too late."},
			]},
		&"old_monk": {
			"title": "An old monk sweeps a stone threshold. He looks at you without surprise.",
			"choices": [
				{"text": "You ask him for a blessing.", "good_narr": "He lays his hand on your brow. Something in you grows calm.", "bad_narr": "He refuses politely. \"Keep your fears. They serve you.\""},
				{"text": "You ask him for a drink and search the place while he is away.", "good_narr": "You find two coins and a piece of bread. He notices nothing.", "bad_narr": "You look up. He is watching you from the threshold. He knows."},
				{"text": "You ask him what he knows of these lands.", "good_narr": "He tells you a century in four sentences. You better understand what awaits you.", "bad_narr": "He smiles, says nothing. You leave with your questions."},
			]},
		&"scholar": {
			"title": "A wandering scholar opens a chest full of maps, vials, books. \"What are you after?\"",
			"choices": [
				{"text": "You ask him what he has of value.", "good_narr": "He sells you a useful map at a low price. The journey resumes, better prepared.", "bad_narr": "He offers you useless things. You leave with nothing."},
				{"text": "You haggle for a flask, letting him believe you have plenty.", "good_narr": "He lets it go for nothing. You leave with a true remedy.", "bad_narr": "He takes offense. He shuts his chest. You leave with nothing."},
				{"text": "You ask him a learned question.", "good_narr": "He answers at length. You come away with three useful things.", "bad_narr": "He talks, and talks, and talks. You retain none of it."},
			]},
		&"lost_child": {
			"title": "A lost child, face clean, asks where his home is. He says the name of a village.",
			"choices": [
				{"text": "You tell him what you know and point him the best way you can.", "good_narr": "He thanks you. Later, his family will reward you.", "bad_narr": "He does not believe you. He goes the other way. You do not know what becomes of him."},
				{"text": "You ask him for more details before answering.", "good_narr": "Something is off in his answers. You step back just in time.", "bad_narr": "You realize the child does not exist. You leave fast."},
				{"text": "You touch his forehead, gently, in silence.", "good_narr": "He smiles, shows you the way. It really was a child. You had forgotten how that goes.", "bad_narr": "He smiles. His skin is cold. You pull your hand back too late."},
			]},
		&"healer_cottage": {
			"title": "A small house, chimney smoking, smelling of burnt herbs. An old woman waves you in.",
			"choices": [
				{"text": "You enter and pay for her craft.", "good_narr": "She heals you. You leave with the wound closed.", "bad_narr": "She tells you she can do nothing for you today. Come back tomorrow."},
				{"text": "You demand she heal you without payment.", "good_narr": "She heals you out of fear. You leave unharmed, conscience less clean.", "bad_narr": "She healed you. But she added something. You feel it, later."},
				{"text": "You play the lost child so she heals you for free.", "good_narr": "She pities you. Heals you. Feeds you. You leave with a full belly.", "bad_narr": "She sees through your act. The broth she hands you is not what she claims."},
			]},
		&"mirror_lake": {
			"title": "A perfectly flat lake reflects a sky that is not the one above you.",
			"choices": [
				{"text": "You lean over to see the sky below.", "good_narr": "You see stars no one above has ever known. You memorize one.", "bad_narr": "A star looks back at you. You feel it following you, from now on."},
				{"text": "You plunge your hand into the sky's reflection.", "good_narr": "You pull out a handful of night. It will serve you.", "bad_narr": "A hand grabs you from below. You break free, but something stays on your wrist."},
				{"text": "You leave without looking any further.", "good_narr": "You learn that one can refuse to learn. That is a strength.", "bad_narr": "You leave. But you dream of the sky below the following night."},
			]},
		&"glowing_fungi": {
			"title": "A ring of blue mushrooms, glowing. They pulse softly, together.",
			"choices": [
				{"text": "You pick one to examine it.", "good_narr": "The glow helps you see in the dark. You leave with a living lantern.", "bad_narr": "You inhale its spores as you bend down. You only realize afterwards."},
				{"text": "You dance slowly inside the circle.", "good_narr": "The circle accepts your step. A curse dissolves into the light.", "bad_narr": "The circle closes around you for a moment. You come out marked."},
				{"text": "You walk around it without entering.", "good_narr": "You leave. One spore followed you anyway — a kind one.", "bad_narr": "You leave. You will never know what waited on the other side."},
			]},
		&"wind_harp": {
			"title": "A harp strung between two rocks. The wind has played it so long the strings shine.",
			"choices": [
				{"text": "You tune your voice to its note.", "good_narr": "You learn a song you did not know. It will serve you, for calming.", "bad_narr": "You sing too long. The wind has emptied you."},
				{"text": "You take the harp.", "good_narr": "It is heavy but useful. You leave with an instrument that sings by itself.", "bad_narr": "The strings cut you. When you pull, they pull back."},
				{"text": "You thank the wind aloud and leave.", "good_narr": "A breeze keeps you company afterwards, for hours. You walk without fear.", "bad_narr": "The wind does not answer. You leave with nothing."},
			]},
		&"sailor_grave": {
			"title": "A wooden cross planted in the sand. A name carved, almost worn away. Beside it, a bottle, still sealed.",
			"choices": [
				{"text": "You speak the name aloud so it is said one more time.", "good_narr": "You leave at peace. Something follows you, benevolent, to the next zone.", "bad_narr": "You speak the name. Nothing happens. You leave."},
				{"text": "You open the bottle.", "good_narr": "A message — a treasure map, a stone's throw away. You find a few coins.", "bad_narr": "An empty message. And a scent whose smell you will never forget."},
				{"text": "You dig up the cross to see if there is something beneath.", "good_narr": "A rusted box. Inside, a knife. A good tool.", "bad_narr": "There are bones, and then something that follows you afterwards, half a step behind."},
			]},
		&"star_map": {
			"title": "On a stone slab, a precise drawing — it is the sky. But the sky of very long ago.",
			"choices": [
				{"text": "You compare it with what you see above you.", "good_narr": "You spot three stars that have changed. You understand what that means.", "bad_narr": "You stare upward, for a long time. You find nothing useful."},
				{"text": "You trace the lines with your finger.", "good_narr": "A map appears in your mind. You will know how to find this place again.", "bad_narr": "A line extends into your hand. You carry it afterwards."},
				{"text": "You erase part of it to confound the next one.", "good_narr": "A small pleasure, a true gain. You leave with a smile.", "bad_narr": "The stone closes on your touch. You pull back your hand with a mark."},
			]},
		&"burning_pyre": {
			"title": "A pyre smolders. Someone — on the pyre. No one else around.",
			"choices": [
				{"text": "You smother the pyre with earth.", "good_narr": "You save someone, perhaps. He flees without a word. You find coins in the ash.", "bad_narr": "The fire tears your hands apart. The person does not get up."},
				{"text": "You pray for what burns.", "good_narr": "You pray. A peace comes. The pyre goes out on its own, soon after.", "bad_narr": "You pray. Something listens. Not what you thought."},
				{"text": "You leave fast. This is not your story.", "good_narr": "You leave. The smoke recedes. You forget quickly.", "bad_narr": "You leave. You feel the gaze of someone in the pyre. You quicken your pace."},
			]},
		&"frozen_tower": {
			"title": "An intact tower, sheathed in ice in high summer. A door stands open at the top.",
			"choices": [
				{"text": "You climb.", "good_narr": "At the top, an open book. You read three pages. You will come out of it changed.", "bad_narr": "The climb is longer than it looks. You come back down with nothing."},
				{"text": "You lay your hand on the ice and speak to it.", "good_narr": "The ice listens. It takes a curse and keeps it for you.", "bad_narr": "The ice listens. And gives you back something you had forgotten to lose."},
				{"text": "You circle it, careful.", "good_narr": "You spot a trapdoor in the ground. In it, an interesting fragment.", "bad_narr": "You find three sets of tracks around the tower. All lead inside. None come out."},
			]},
		&"underwater_shadow": {
			"title": "A shadow moves underwater, slowly, only a few meters out. It never rises.",
			"choices": [
				{"text": "You move away from the shore without running.", "good_narr": "You leave. The shadow follows you a while, then gives up.", "bad_narr": "The shadow follows you a long time. You walk without stopping, heart strung tight."},
				{"text": "You toss it a pebble in greeting.", "good_narr": "It throws the pebble back out of the water. You pick it up. It has changed.", "bad_narr": "It does not return the pebble. It rises, slowly, toward the surface. You leave without looking."},
				{"text": "You murmur an ancient word to the water.", "good_narr": "The shadow stops. It listens. It entrusts you something, in the silence.", "bad_narr": "The shadow stops. It listens to you. Too well."},
			]},
		&"lit_shrine": {
			"title": "A freshly lit altar. Someone passed by not long ago.",
			"choices": [
				{"text": "You leave a coin on it and murmur a prayer.", "good_narr": "A warmth wraps around you. You leave with the wound closed.", "bad_narr": "You leave. Nothing happens. But something is appeased."},
				{"text": "You relight the candle while pocketing the coin.", "good_narr": "You leave with the coin and an easy conscience.", "bad_narr": "The coin burns in your pocket, for a long time."},
				{"text": "You add a lock of your hair to the candle.", "good_narr": "You leave with a knowledge that was not there before.", "bad_narr": "You left more than hair behind. You will feel it."},
			]},
		&"tired_soldier": {
			"title": "A soldier sits in the dust, his broken sword beside him. \"You wouldn't know where a man could sleep?\"",
			"choices": [
				{"text": "You point him to a quiet corner you noticed.", "good_narr": "He thanks you and entrusts you a soldier's secret — useful.", "bad_narr": "He does not believe you. He turns his back."},
				{"text": "You take his broken sword and leave.", "good_narr": "He says nothing. The blade turns out not so broken after all.", "bad_narr": "He was faster than he looked. The broken blade finds its target."},
				{"text": "You give a nod and pass without a word.", "good_narr": "You leave. He falls asleep where he sat.", "bad_narr": "His eyes follow you. You quicken your pace."},
			]},
		&"glowing_chest": {
			"title": "A small chest pulsing softly through its planks. It looks alive.",
			"choices": [
				{"text": "You open it calmly.", "good_narr": "Inside, a precious fragment. You slip it into your pocket.", "bad_narr": "Inside, a vapor. You breathe in a lungful."},
				{"text": "You smash it with a kick.", "good_narr": "You get a good coin out of it and a piece of crystal.", "bad_narr": "A splinter slices your shin."},
				{"text": "You lay your hand on it and listen to what it has to say.", "good_narr": "The chest absorbs something in you. You leave lighter.", "bad_narr": "The chest passes on what it carried. You carry it now."},
			]},
		&"blood_fruit": {
			"title": "A blood-red fruit hangs from an otherwise dead tree. It still smells fresh.",
			"choices": [
				{"text": "You eat it raw.", "good_narr": "The juice is sweet and fills you. You set out with new strength.", "bad_narr": "It was sweet at first, then bitter. Very bitter."},
				{"text": "You pick it and keep it for later.", "good_narr": "You keep it. It does not rot. A good omen.", "bad_narr": "It melts between your fingers. You leave with nothing."},
				{"text": "You leave it on the tree as an offering.", "good_narr": "The tree shivers. You receive an ancient word in return.", "bad_narr": "You leave. The tree says nothing. The fruit rots behind you."},
			]},
		&"wandering_horse": {
			"title": "A saddled horse grazes peacefully, riderless. It watches you without fear.",
			"choices": [
				{"text": "You speak to it softly and lead it by the bridle.", "good_narr": "It follows you. You cross the zone far faster.", "bad_narr": "It moves off when you approach. It wants nothing to do with you."},
				{"text": "You mount it by force.", "good_narr": "You succeed. It accepts your authority. You ride off on it.", "bad_narr": "It throws you to the ground. Something in your arm gave way."},
				{"text": "You circle around to see what it is grazing on.", "good_narr": "You find the remains of its rider — and what he carried.", "bad_narr": "You find nothing. The horse watches you, annoyed."},
			]},
		&"burning_scroll": {
			"title": "A burning scroll that does not burn away. It floats at the height of a man.",
			"choices": [
				{"text": "You speak the word it is waiting for.", "good_narr": "It goes out and falls into your hand. You can read it.", "bad_narr": "You said the word. But not the one it was waiting for."},
				{"text": "You try to read it through the flames.", "good_narr": "You retain three words. They will serve you.", "bad_narr": "The flame burns your eyes. You leave weeping."},
				{"text": "You grab it despite the fire.", "good_narr": "You take the burn. The scroll is yours.", "bad_narr": "The fire refuses to go out. You let go, screaming."},
			]},
		&"whispering_wind": {
			"title": "The wind speaks to you clearly. Three words, slowly. It asks you for something.",
			"choices": [
				{"text": "You answer aloud.", "good_narr": "The wind keeps you company afterwards, gentle, for a long time.", "bad_narr": "The wind cuts off your voice. You leave without finishing."},
				{"text": "You sing a single note in reply.", "good_narr": "The wind carries you. Your strength returns without effort.", "bad_narr": "The note is false. The wind takes up its own, louder."},
				{"text": "You fall silent and wait for it to pass.", "good_narr": "You wait. The wind finally moves on. You leave.", "bad_narr": "The wind does not stop. You walk against it a long time."},
			]},
		&"wounded_animal": {
			"title": "A stag on the ground, an arrow lodged in its flank. It is still breathing.",
			"choices": [
				{"text": "You draw out the arrow gently.", "good_narr": "It rises, weakly, and gives you one look before fleeing. Later, you will find a useful antler on your way.", "bad_narr": "It thrashes. The arrow's shaft scrapes you."},
				{"text": "You finish it with one clean blow.", "good_narr": "You eat an honest meal. You set out with a full belly.", "bad_narr": "It watches you while you strike. You will never sleep the same."},
				{"text": "You lay your hand on it and take some of its pain.", "good_narr": "It gets up. You feel its name in your head. From now on you can call it.", "bad_narr": "You take too much. You stagger."},
			]},
		&"old_well_treasure": {
			"title": "A dried-up well. At the bottom, metal glints faintly. The stone is crumbling.",
			"choices": [
				{"text": "You climb down by force, without a rope.", "good_narr": "You come back up with a fistful of coins and an engraved ring.", "bad_narr": "You slip. Your arm strikes the stone. You climb out alone, with great pain."},
				{"text": "You find a rope and descend carefully.", "good_narr": "You come back up unharmed, with what you wanted.", "bad_narr": "The descent takes hours. You come back up drained."},
				{"text": "You pretend to leave and return at dusk.", "good_narr": "Easier in the dark. You leave with two more coins.", "bad_narr": "The well is deeper at night. You leave with nothing."},
			]},
	}
