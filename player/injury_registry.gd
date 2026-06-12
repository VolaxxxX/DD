class_name InjuryRegistry extends RefCounted
# Wounds that accumulate. Each one alters gameplay. Death is situational, not a wound counter.

static func all() -> Array:
	return [
		{"id": &"bleeding",     "name": "Saignement",
		 "name_en": "Bleeding", "name_id": "Pendarahan",
		 "desc": "Tu perds du sang. Chaque effort te coûte.",
		 "desc_en": "You are losing blood. Every effort costs you.",
		 "desc_id": "Kau kehilangan darah. Setiap upaya ada harganya.",
		 "force_penalty": 1, "lock_tone": -1, "color": Color(1, 0.3, 0.3)},
		{"id": &"broken_arm",   "name": "Bras brisé",
		 "name_en": "Broken arm", "name_id": "Lengan patah",
		 "desc": "Ton bras d'arme pend, inutile.",
		 "desc_en": "Your weapon arm hangs, useless.",
		 "desc_id": "Lengan senjatamu tergantung, tak berguna.",
		 "force_penalty": 0, "lock_tone": 0, "color": Color(0.9, 0.6, 0.4)},
		{"id": &"terror",       "name": "Terreur",
		 "name_en": "Terror", "name_id": "Teror",
		 "desc": "Quelque chose s'est cassé en toi. Fuir n'est plus une pensée.",
		 "desc_en": "Something broke inside you. Fleeing is no longer a thought.",
		 "desc_id": "Sesuatu patah dalam dirimu. Melarikan diri bukan lagi pilihan.",
		 "force_penalty": 0, "lock_tone": 2, "color": Color(0.7, 0.6, 1.0)},
		{"id": &"curse",        "name": "Malédiction",
		 "name_en": "Curse", "name_id": "Kutukan",
		 "desc": "Un mot ancien adhère à ton ombre. Le mystique se retourne contre toi.",
		 "desc_en": "An old word clings to your shadow. The mystic turns against you.",
		 "desc_id": "Sebuah kata kuno melekat pada bayanganmu. Yang mistis berbalik melawanmu.",
		 "force_penalty": 0, "lock_tone": 5, "color": Color(0.85, 0.4, 1.0)},
		{"id": &"poison",       "name": "Poison",
		 "name_en": "Poison", "name_id": "Racun",
		 "desc": "Quelque chose circule dans tes veines. Lent. Sûr.",
		 "desc_en": "Something moves through your veins. Slow. Certain.",
		 "desc_id": "Sesuatu mengalir dalam nadimu. Pelan. Pasti.",
		 "force_penalty": 2, "lock_tone": -1, "color": Color(0.5, 1.0, 0.4)},
		{"id": &"exhaustion",   "name": "Épuisement",
		 "name_en": "Exhaustion", "name_id": "Kelelahan",
		 "desc": "Le corps refuse. La voix tremble.",
		 "desc_en": "The body refuses. The voice trembles.",
		 "desc_id": "Tubuh menolak. Suara gemetar.",
		 "force_penalty": 1, "lock_tone": -1, "color": Color(0.7, 0.7, 0.7)},
	]

static func by_id(id: StringName) -> Dictionary:
	for w in all():
		if w.id == id: return _localized(w)
	return {}

# Shallow copy with name/desc swapped to the active language, so every caller
# (HUD chips, floating text, panels) displays the right language for free.
static func _localized(w: Dictionary) -> Dictionary:
	if Lang.code != "en" and Lang.code != "id": return w
	var c: Dictionary = w.duplicate()
	c.name = w.get("name_" + Lang.code, w.name)
	c.desc = w.get("desc_" + Lang.code, w.desc)
	return c

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
