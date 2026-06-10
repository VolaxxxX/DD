class_name BiomeRules extends RefCounted
# Mechanical identity per biome: each terrain helps some stats, hinders others,
# and tilts certain tones. The same creature plays differently elsewhere.

# stat_mod: stat_key -> int applied to the player's roll when that stat is used.
# tone_mod: tone -> int applied to the roll difficulty (positive = harder).
static func rules() -> Dictionary:
	return {
		&"forest": {
			"stat_mod": {&"vivacite": 2, &"instinct": 1, &"charisme": -1},
			"tone_mod": {2: -2, 0: 1},     # cautious easier, aggressive slightly harder (cover everywhere)
			"label": "La forêt cache ceux qui savent se taire.",
		},
		&"city": {
			"stat_mod": {&"charisme": 2, &"esprit": 1, &"instinct": -1},
			"tone_mod": {1: -2, 4: -1},    # diplomacy and lies thrive among walls
			"label": "Ici, la parole vaut une lame.",
		},
		&"ruins": {
			"stat_mod": {&"esprit": 2, &"endurance": -1},
			"tone_mod": {3: -2},           # curiosity rewarded
			"label": "Les pierres parlent à qui sait lire.",
		},
		&"corrupted": {
			"stat_mod": {&"endurance": -2, &"esprit": -1, &"force": 1},
			"tone_mod": {5: -1, 1: 2},     # mysticism feeds, words rot
			"label": "La terre malade ronge les faibles.",
		},
		&"anomaly": {
			"stat_mod": {&"instinct": 2, &"esprit": 1, &"force": -2},
			"tone_mod": {5: -2, 0: 2},     # violence misfires, rites resonate
			"label": "Ici, la force ne veut rien dire.",
		},
		&"swamp": {
			"stat_mod": {&"endurance": 2, &"vivacite": -2},
			"tone_mod": {2: 2, 4: -1},     # fleeing is slow, lies float well in the mist
			"label": "Le marais ne laisse personne courir.",
		},
		&"highland": {
			"stat_mod": {&"endurance": 1, &"force": 1, &"charisme": -1},
			"tone_mod": {0: -1, 2: -1},    # open ground favors honest steel and clean retreat
			"label": "Les hauteurs ne récompensent que l'effort.",
		},
		&"crypt": {
			"stat_mod": {&"esprit": 1, &"charisme": -2, &"instinct": 1},
			"tone_mod": {5: -2, 1: 2},     # the dead listen to rites, not speeches
			"label": "Les morts n'écoutent pas les discours.",
		},
		&"coast": {
			"stat_mod": {&"charisme": 1, &"vivacite": 1, &"esprit": -1},
			"tone_mod": {4: -2, 1: -1},    # ports breed liars and traders
			"label": "Tout se négocie, face à la mer.",
		},
	}

static func stat_mod(biome: StringName, stat_key: StringName) -> int:
	var r: Dictionary = rules().get(biome, {})
	var sm: Dictionary = r.get("stat_mod", {})
	return int(sm.get(stat_key, 0))

static func tone_difficulty_mod(biome: StringName, tone: int) -> int:
	var r: Dictionary = rules().get(biome, {})
	var tm: Dictionary = r.get("tone_mod", {})
	return int(tm.get(tone, 0))

const _LABELS := {
	"forest":    {"fr": "La forêt cache ceux qui savent se taire.",
	              "en": "The forest hides those who know how to be silent.",
	              "id": "Hutan menyembunyikan mereka yang tahu cara diam."},
	"city":      {"fr": "Ici, la parole vaut une lame.",
	              "en": "Here, a word cuts like a blade.",
	              "id": "Di sini, sepatah kata setajam pisau."},
	"ruins":     {"fr": "Les pierres parlent à qui sait lire.",
	              "en": "The stones speak to those who can read.",
	              "id": "Batu-batu berbicara pada yang bisa membaca."},
	"corrupted": {"fr": "La terre malade ronge les faibles.",
	              "en": "The sick land devours the weak.",
	              "id": "Tanah sakit menggerogoti yang lemah."},
	"anomaly":   {"fr": "Ici, la force ne veut rien dire.",
	              "en": "Here, strength means nothing.",
	              "id": "Di sini, kekuatan tak berarti apa-apa."},
	"swamp":     {"fr": "Le marais ne laisse personne courir.",
	              "en": "The swamp lets no one run.",
	              "id": "Rawa tidak membiarkan siapa pun berlari."},
	"highland":  {"fr": "Les hauteurs ne récompensent que l'effort.",
	              "en": "The high places reward only effort.",
	              "id": "Dataran tinggi hanya memberi upah pada usaha."},
	"crypt":     {"fr": "Les morts n'écoutent pas les discours.",
	              "en": "The dead do not listen to speeches.",
	              "id": "Yang mati tidak mendengarkan pidato."},
	"coast":     {"fr": "Tout se négocie, face à la mer.",
	              "en": "Everything is negotiable, before the sea.",
	              "id": "Semua bisa dirundingkan, di hadapan laut."},
}

static func label(biome: StringName) -> String:
	var d: Dictionary = _LABELS.get(String(biome), {})
	if d.is_empty():
		var r: Dictionary = rules().get(biome, {})
		return String(r.get("label", ""))
	return String(d.get(Lang.code, d.get("fr", "")))
