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

static func stat_label(k: StringName) -> String:
	match String(k):
		"force":      return "FORCE"
		"esprit":     return "ESPRIT"
		"vivacite":   return "VIVACITÉ"
		"instinct":   return "INSTINCT"
		"charisme":   return "CHARISME"
		"endurance":  return "ENDURANCE"
		_:            return String(k).to_upper()

static func stat_hint(k: StringName) -> String:
	match String(k):
		"force":      return "frapper, briser, tenir."
		"esprit":     return "parler, lire, comprendre."
		"vivacite":   return "esquiver, fuir, surprendre."
		"instinct":   return "sentir, deviner, voir au-delà."
		"charisme":   return "mentir, charmer, ordonner."
		"endurance":  return "encaisser, marcher, durer."
		_:            return ""

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
		if int(c.kind) == kind: return c
	return all()[0]

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
