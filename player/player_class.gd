class_name PlayerClass extends RefCounted
# Four playable archetypes. Each defines base stats, tone affinities, visual style,
# and a small injury resistance profile. Players spend ALLOC_POINTS extra points
# at character creation to customise within stat caps.

enum Kind { SOLDAT, ECLAIREUR, MYSTIQUE, VOLEUR }

# Stat keys: "force", "esprit", "vivacite", "instinct", "charisme", "endurance"
const ALLOC_POINTS := 6
const STAT_MIN := 4
const STAT_MAX := 18

static func stat_keys() -> Array[StringName]:
	return [&"force", &"esprit", &"vivacite", &"instinct", &"charisme", &"endurance"]

const _STAT_LABELS := {
	"force":     {"fr": "FORCE",     "en": "MIGHT",    "id": "KEKUATAN"},
	"esprit":    {"fr": "ESPRIT",    "en": "MIND",     "id": "PIKIRAN"},
	"vivacite":  {"fr": "VIVACITÉ",  "en": "SWIFTNESS","id": "KELINCAHAN"},
	"instinct":  {"fr": "INSTINCT",  "en": "INSTINCT", "id": "INSTING"},
	"charisme":  {"fr": "CHARISME",  "en": "CHARISMA", "id": "PESONA"},
	"endurance": {"fr": "ENDURANCE", "en": "STAMINA",  "id": "DAYA TAHAN"},
}
const _STAT_HINTS := {
	"force":     {"fr": "frapper, briser, tenir.",
	              "en": "strike, break, hold.",
	              "id": "memukul, mematahkan, menahan."},
	"esprit":    {"fr": "parler, lire, comprendre.",
	              "en": "speak, read, understand.",
	              "id": "berbicara, membaca, memahami."},
	"vivacite":  {"fr": "esquiver, fuir, surprendre.",
	              "en": "dodge, flee, surprise.",
	              "id": "mengelak, lari, mengejutkan."},
	"instinct":  {"fr": "sentir, deviner, voir au-delà.",
	              "en": "sense, guess, see beyond.",
	              "id": "merasakan, menebak, melihat lebih jauh."},
	"charisme":  {"fr": "mentir, charmer, ordonner.",
	              "en": "lie, charm, command.",
	              "id": "berbohong, memikat, memerintah."},
	"endurance": {"fr": "encaisser, marcher, durer.",
	              "en": "take a hit, walk on, endure.",
	              "id": "menahan, berjalan terus, bertahan."},
}

static func stat_label(k: StringName) -> String:
	var d: Dictionary = _STAT_LABELS.get(String(k), {})
	return String(d.get(Lang.code, d.get("fr", String(k).to_upper())))

static func stat_hint(k: StringName) -> String:
	var d: Dictionary = _STAT_HINTS.get(String(k), {})
	return String(d.get(Lang.code, d.get("fr", "")))

static func all() -> Array:
	return [
		{
			"kind": Kind.SOLDAT,
			"name": "Soldat",
			"tagline": "Lame d'abord. Questions ensuite.",
			"base_stats": {&"force": 12, &"esprit": 7, &"vivacite": 8, &"instinct": 7, &"charisme": 7, &"endurance": 11},
			"tone_bonus": [0],
			"tone_malus": [5],
			"body_color": Color(0.55, 0.30, 0.30),
			"hair_color": Color(0.30, 0.20, 0.15),
			"accessory": &"sword",
			"injury_resist": [&"broken_arm"],
		},
		{
			"kind": Kind.ECLAIREUR,
			"name": "Éclaireur",
			"tagline": "Voir avant d'être vu.",
			"base_stats": {&"force": 9, &"esprit": 8, &"vivacite": 12, &"instinct": 11, &"charisme": 7, &"endurance": 9},
			"tone_bonus": [2, 3],
			"tone_malus": [],
			"body_color": Color(0.30, 0.45, 0.25),
			"hair_color": Color(0.20, 0.15, 0.10),
			"accessory": &"bow",
			"injury_resist": [&"terror"],
		},
		{
			"kind": Kind.MYSTIQUE,
			"name": "Mystique",
			"tagline": "Les mots ont du poids.",
			"base_stats": {&"force": 7, &"esprit": 12, &"vivacite": 8, &"instinct": 11, &"charisme": 9, &"endurance": 7},
			"tone_bonus": [1, 5],
			"tone_malus": [0],
			"body_color": Color(0.30, 0.30, 0.55),
			"hair_color": Color(0.85, 0.85, 0.90),
			"accessory": &"staff",
			"injury_resist": [&"curse"],
		},
		{
			"kind": Kind.VOLEUR,
			"name": "Voleur",
			"tagline": "Sourire devant. Lame derrière.",
			"base_stats": {&"force": 9, &"esprit": 8, &"vivacite": 11, &"instinct": 9, &"charisme": 12, &"endurance": 8},
			"tone_bonus": [4, 2],
			"tone_malus": [1],
			"body_color": Color(0.25, 0.25, 0.30),
			"hair_color": Color(0.10, 0.10, 0.10),
			"accessory": &"dagger",
			"injury_resist": [&"bleeding"],
		},
	]

static func by_kind(kind: int) -> Dictionary:
	for c in all():
		if int(c.kind) == kind:
			var d := c.duplicate(true)
			d["name"] = _localized_name(int(c.kind))
			d["tagline"] = _localized_tagline(int(c.kind))
			return d
	return all()[0]

const _NAMES := {
	0: {"fr": "Soldat",     "en": "Soldier",  "id": "Prajurit"},
	1: {"fr": "Éclaireur",  "en": "Scout",    "id": "Pengintai"},
	2: {"fr": "Mystique",   "en": "Mystic",   "id": "Mistikus"},
	3: {"fr": "Voleur",     "en": "Thief",    "id": "Pencuri"},
}
const _TAGLINES := {
	0: {"fr": "Lame d'abord. Questions ensuite.",
	    "en": "Blade first. Questions later.",
	    "id": "Pedang dulu. Tanya kemudian."},
	1: {"fr": "Voir avant d'être vu.",
	    "en": "See before being seen.",
	    "id": "Melihat sebelum terlihat."},
	2: {"fr": "Les mots ont du poids.",
	    "en": "Words have weight.",
	    "id": "Kata-kata punya bobot."},
	3: {"fr": "Sourire devant. Lame derrière.",
	    "en": "Smile in front. Blade behind.",
	    "id": "Senyum di depan. Pisau di belakang."},
}

static func _localized_name(kind: int) -> String:
	var d: Dictionary = _NAMES.get(kind, {})
	return String(d.get(Lang.code, d.get("fr", "?")))

static func _localized_tagline(kind: int) -> String:
	var d: Dictionary = _TAGLINES.get(kind, {})
	return String(d.get(Lang.code, d.get("fr", "")))

static func tone_stat(tone: int) -> StringName:
	# Maps a tone to its primary stat for rolls.
	match tone:
		0: return &"force"        # AGGRESSIVE
		1: return &"charisme"     # DIPLOMATIC
		2: return &"vivacite"     # CAUTIOUS
		3: return &"instinct"     # CURIOUS
		4: return &"charisme"     # DECEPTIVE
		5: return &"esprit"       # MYSTICAL
		_: return &"force"
