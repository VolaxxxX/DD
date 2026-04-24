class_name InjuryRegistry extends RefCounted
# Wounds that accumulate. Each one alters gameplay. Death is situational, not a wound counter.

static func all() -> Array:
	return [
		{"id": &"bleeding",     "name": "Saignement",
		 "desc": "Tu perds du sang. Chaque effort te coûte.",
		 "force_penalty": 1, "lock_tone": -1, "color": Color(1, 0.3, 0.3)},
		{"id": &"broken_arm",   "name": "Bras brisé",
		 "desc": "Ton bras d'arme pend, inutile.",
		 "force_penalty": 0, "lock_tone": 0, "color": Color(0.9, 0.6, 0.4)},
		{"id": &"terror",       "name": "Terreur",
		 "desc": "Quelque chose s'est cassé en toi. Fuir n'est plus une pensée.",
		 "force_penalty": 0, "lock_tone": 2, "color": Color(0.7, 0.6, 1.0)},
		{"id": &"curse",        "name": "Malédiction",
		 "desc": "Un mot ancien adhère à ton ombre. Le mystique se retourne contre toi.",
		 "force_penalty": 0, "lock_tone": 5, "color": Color(0.85, 0.4, 1.0)},
		{"id": &"poison",       "name": "Poison",
		 "desc": "Quelque chose circule dans tes veines. Lent. Sûr.",
		 "force_penalty": 2, "lock_tone": -1, "color": Color(0.5, 1.0, 0.4)},
		{"id": &"exhaustion",   "name": "Épuisement",
		 "desc": "Le corps refuse. La voix tremble.",
		 "force_penalty": 1, "lock_tone": -1, "color": Color(0.7, 0.7, 0.7)},
	]

static func by_id(id: StringName) -> Dictionary:
	for w in all():
		if w.id == id: return w
	return {}

static func pick_for(rng: DRNG, tone: int, biome: StringName) -> StringName:
	# Each tone tends to inflict different injuries.
	var pool: Array[StringName] = []
	match tone:
		0: pool = [&"bleeding", &"broken_arm", &"bleeding", &"exhaustion"]   # AGGRESSIVE
		1: pool = [&"terror", &"exhaustion", &"curse"]                       # DIPLOMATIC
		2: pool = [&"exhaustion", &"terror", &"bleeding"]                    # CAUTIOUS
		3: pool = [&"curse", &"terror", &"poison"]                           # CURIOUS
		4: pool = [&"bleeding", &"poison", &"exhaustion"]                    # DECEPTIVE
		5: pool = [&"curse", &"curse", &"terror", &"poison"]                 # MYSTICAL
		_: pool = [&"exhaustion"]
	if biome == &"corrupted": pool.append(&"poison")
	if biome == &"anomaly":   pool.append(&"curse")
	return pool[rng.range_i(0, pool.size())]
