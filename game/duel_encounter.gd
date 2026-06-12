class_name DuelEncounter extends RefCounted
# Multi-phase confrontation against a named colossus (world boss or the
# run-finale dragon). Three rounds of deliberate choices; win 2+ phases to
# prevail. No mid-fight permadeath — the drama resolves at the end.
# Duck-typed like Encounter/SituationEncounter: {zone, choices, creature,
# creature_name, resolve()}.

const PHASES := 3

var zone: Zone
var rng: DRNG
var player: PlayerState
var foe_kind: StringName            # &"boss" or &"dragon"
var foe_id: StringName
var creature = null                 # duck-type: no creature node logic
var creature_name: String           # shown in run-over if it kills you
var phase: int = 0
var phase_wins: int = 0
var choices: Array[Dictionary] = []

func _init(_zone: Zone, _rng: DRNG, _player: PlayerState, _kind: StringName, _id: StringName, _name: String) -> void:
	zone = _zone
	rng = _rng
	player = _player
	foe_kind = _kind
	foe_id = _id
	creature_name = _name
	choices = _build_choices()

func phase_title() -> String:
	var names := [
		Lang.t({"fr": "PHASE I — L'Ouverture", "en": "PHASE I — The Opening", "id": "FASE I — Pembukaan"}),
		Lang.t({"fr": "PHASE II — La Tempête", "en": "PHASE II — The Storm", "id": "FASE II — Badai"}),
		Lang.t({"fr": "PHASE III — Le Dénouement", "en": "PHASE III — The Reckoning", "id": "FASE III — Penghakiman"}),
	]
	return names[clampi(phase, 0, PHASES - 1)]

func _build_choices() -> Array[Dictionary]:
	# Each phase offers force / cunning-mysticism / endurance-caution. The
	# texts escalate with the phase so the duel feels like a story.
	var pool: Array = []
	match phase:
		0: pool = [
			{"tone": 0, "t": {"fr": "Tu frappes le premier, avant qu'il ne déploie toute sa masse.",
				"en": "You strike first, before it unfolds its full mass.",
				"id": "Kau menyerang lebih dulu, sebelum ia membentangkan seluruh tubuhnya."}},
			{"tone": 5, "t": {"fr": "Tu traces un cercle de protection et jauges sa vraie nature.",
				"en": "You trace a warding circle and take measure of its true nature.",
				"id": "Kau menggambar lingkaran pelindung dan menakar wujud aslinya."}},
			{"tone": 2, "t": {"fr": "Tu esquives sa première charge — observe, survis, apprends.",
				"en": "You dodge its first charge — watch, survive, learn.",
				"id": "Kau menghindari serangan pertamanya — amati, bertahan, pelajari."}},
		]
		1: pool = [
			{"tone": 0, "t": {"fr": "Tu vises la blessure ouverte à la phase précédente.",
				"en": "You target the wound opened in the last exchange.",
				"id": "Kau membidik luka yang terbuka pada serangan sebelumnya."}},
			{"tone": 5, "t": {"fr": "Tu retournes sa propre puissance contre lui.",
				"en": "You turn its own power back against it.",
				"id": "Kau membalikkan kekuatannya sendiri melawannya."}},
			{"tone": 3, "t": {"fr": "Tu cherches le rythme dans sa fureur — chaque colosse a un battement.",
				"en": "You find the rhythm in its fury — every colossus has a heartbeat.",
				"id": "Kau mencari irama dalam amukannya — setiap raksasa punya detak."}},
		]
		2: pool = [
			{"tone": 0, "t": {"fr": "Tout ou rien : tu engages tout ce qu'il te reste dans un dernier assaut.",
				"en": "All or nothing: you spend everything you have left in one final assault.",
				"id": "Segalanya atau tidak sama sekali: kau kerahkan semua yang tersisa dalam serangan terakhir."}},
			{"tone": 5, "t": {"fr": "Tu prononces le mot que tu gardais pour la fin.",
				"en": "You speak the word you were saving for the end.",
				"id": "Kau mengucapkan kata yang kau simpan untuk saat terakhir."}},
			{"tone": 1, "t": {"fr": "Tu exiges qu'il cède — d'égal à égal, comme le veut l'ancienne loi.",
				"en": "You demand it yield — equal to equal, as the old law commands.",
				"id": "Kau menuntutnya menyerah — setara dengan setara, sesuai hukum lama."}},
		]
	var out: Array[Dictionary] = []
	for c in pool:
		out.append({"tone": int(c.tone), "text": Lang.t(c.t), "kind": EventResolver.Kind.COMBAT})
	return out

func resolve(choice_idx: int, resolver: EventResolver, coop_mod: int) -> Dictionary:
	var choice: Dictionary = choices[choice_idx]
	var tone: int = choice.tone
	var difficulty: int = 13 + phase * 2 + int(zone.chaos * 3) + zone.route_diff_mod
	# Titans are the hardest fights in the game; the finale dragon is slightly
	# kinder since it ends the run either way.
	if foe_kind == &"boss": difficulty += 3
	elif foe_kind == &"dragon": difficulty += 2
	if Settings.story_mode: difficulty -= 2
	var stat_key: StringName = PlayerClass.tone_stat(tone)
	var actor_stat: int = player.roll_stat_for_tone(tone) + BiomeRules.stat_mod(zone.biome, stat_key)
	actor_stat += player.relic_bonus({
		"tone": tone, "stat": stat_key, "family": 7 if foe_kind == &"dragon" else 5,
		"biome": zone.biome, "dragon_present": true,
	})
	var r: Dictionary = resolver.resolve(choice.kind, actor_stat, difficulty, coop_mod, -int(zone.corruption * 3), [foe_id])
	var outcome: int = r.outcome
	var won_phase: bool = outcome >= FateEngine.Outcome.SUCCESS
	if won_phase: phase_wins += 1
	var narrative := _phase_narrative(outcome)
	var result := {
		"narrative": narrative,
		"outcome": outcome,
		"tone": tone,
		"stat_delta": 0,
		"creature_dies": false, "creature_flees": false, "mutate": false,
		"injury": &"", "heal": &"", "fatal": false,
		"duel_phase_done": true,
		"duel_finished": false,
		"duel_victory": false,
	}
	# Losing an exchange against a colossus always costs flesh.
	if outcome <= FateEngine.Outcome.FAIL:
		result.injury = InjuryRegistry.pick_for(rng, tone, zone.biome)
	phase += 1
	if phase >= PHASES:
		result.duel_finished = true
		result.duel_victory = phase_wins >= 2
		# Total collapse (0 wins) risks death — unless story mode. Titans are
		# less forgiving than the finale dragon.
		if phase_wins == 0 and not Settings.story_mode:
			result.fatal = rng.chance(70 if foe_kind == &"boss" else 60, 100)
	else:
		choices = _build_choices()
	return result

func _phase_narrative(outcome: int) -> String:
	var lines: Dictionary
	if outcome >= FateEngine.Outcome.CRIT_SUCCESS:
		lines = {"fr": "%s vacille — tu as frappé plus juste que tu ne l'espérais.",
			"en": "%s staggers — you struck truer than you dared hope.",
			"id": "%s terhuyung — seranganmu lebih tepat dari yang kau harap."}
	elif outcome == FateEngine.Outcome.SUCCESS:
		lines = {"fr": "%s recule d'un pas. Un pas de colosse, c'est une victoire.",
			"en": "%s gives one step back. From a colossus, one step is a victory.",
			"id": "%s mundur selangkah. Bagi raksasa, satu langkah adalah kemenangan."}
	elif outcome == FateEngine.Outcome.MIXED:
		lines = {"fr": "Vous vous blessez mutuellement. %s n'a pas l'habitude de saigner.",
			"en": "You wound each other. %s is not used to bleeding.",
			"id": "Kalian saling melukai. %s tak terbiasa berdarah."}
	elif outcome == FateEngine.Outcome.FAIL:
		lines = {"fr": "%s te balaie. Le sol te rattrape durement.",
			"en": "%s sweeps you aside. The ground catches you hard.",
			"id": "%s menyapumu. Tanah menangkapmu dengan keras."}
	else:
		lines = {"fr": "%s te brise quelque chose. Le monde devient blanc un instant.",
			"en": "%s breaks something in you. The world goes white for a moment.",
			"id": "%s mematahkan sesuatu dalam dirimu. Dunia memutih sesaat."}
	return Lang.t(lines) % creature_name

func victory_text() -> String:
	if foe_kind == &"dragon":
		return Lang.t({
			"fr": "%s s'élève une dernière fois, te jauge — et incline la tête. Le ciel t'appartient. Tu sors de la Dérive en vainqueur.",
			"en": "%s rises one last time, takes your measure — and bows its head. The sky is yours. You leave the Drift victorious.",
			"id": "%s membubung untuk terakhir kali, menakar dirimu — lalu menundukkan kepala. Langit menjadi milikmu. Kau keluar dari Arus sebagai pemenang."}) % creature_name
	return Lang.t({
		"fr": "%s se replie dans les profondeurs dont il venait. La zone respire à nouveau.",
		"en": "%s withdraws into the depths it came from. The zone breathes again.",
		"id": "%s mundur ke kedalaman asalnya. Zona ini bernapas kembali."}) % creature_name

func defeat_text() -> String:
	return Lang.t({
		"fr": "%s domine. Tu survis — diminué, mais vivant. Certains combats ne se gagnent pas.",
		"en": "%s prevails. You survive — lessened, but alive. Some battles are not for winning.",
		"id": "%s menang. Kau selamat — berkurang, tapi hidup. Beberapa pertarungan memang bukan untuk dimenangkan."}) % creature_name
