class_name PlayerClass extends RefCounted
# Four playable archetypes. Each defines starting FORCE, tone affinities, and visual style.

enum Kind { SOLDAT, ECLAIREUR, MYSTIQUE, VOLEUR }

static func all() -> Array:
	return [
		{
			"kind": Kind.SOLDAT,
			"name": "Soldat",
			"tagline": "Lame d'abord. Questions ensuite.",
			"force": 14,
			"tone_bonus": [0],     # AGGRESSIVE
			"tone_malus": [5],     # MYSTICAL
			"body_color": Color(0.55, 0.30, 0.30),
			"hair_color": Color(0.30, 0.20, 0.15),
			"accessory": &"sword",
			"injury_resist": [&"broken_arm"],
		},
		{
			"kind": Kind.ECLAIREUR,
			"name": "Éclaireur",
			"tagline": "Voir avant d'être vu.",
			"force": 11,
			"tone_bonus": [2, 3],  # CAUTIOUS, CURIOUS
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
			"force": 10,
			"tone_bonus": [1, 5],  # DIPLOMATIC, MYSTICAL
			"tone_malus": [0],     # AGGRESSIVE
			"body_color": Color(0.30, 0.30, 0.55),
			"hair_color": Color(0.85, 0.85, 0.90),
			"accessory": &"staff",
			"injury_resist": [&"curse"],
		},
		{
			"kind": Kind.VOLEUR,
			"name": "Voleur",
			"tagline": "Sourire devant. Lame derrière.",
			"force": 12,
			"tone_bonus": [4, 2],  # DECEPTIVE, CAUTIOUS
			"tone_malus": [1],     # DIPLOMATIC
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
