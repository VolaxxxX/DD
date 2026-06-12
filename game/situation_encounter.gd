class_name SituationEncounter extends RefCounted
# Non-creature encounter (discovery, hazard, shrine, stranger).
# Reuses the same {choices, resolve} contract as Encounter so the UI is unchanged.

var zone: Zone
var rng: DRNG
var player: PlayerState
var template: Dictionary
var choices: Array[Dictionary] = []
var creature_name: String = Lang.t({"fr": "le lieu", "en": "the place", "id": "tempat itu"})  # for run-over message
var creature = null                          # nil — flags this as situation

func _init(_zone: Zone, _rng: DRNG, _player: PlayerState, _template: Dictionary) -> void:
	zone = _zone
	rng = _rng
	player = _player
	template = SituationRegistry.localize(_template)
	choices = _build_choices()

func _build_choices() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in template.choices:
		# Skip if tone locked by injuries
		if player.tone_locked(int(c.tone)): continue
		out.append({"tone": int(c.tone), "text": String(c.text), "kind": 3})
		if out.size() >= 3: break
	# Pad if injuries locked too many
	while out.size() < template.choices.size() and out.size() < 3:
		var c: Dictionary = template.choices[out.size()]
		out.append({"tone": int(c.tone), "text": String(c.text), "kind": 3})
	return out

func resolve(choice_idx: int, _resolver: EventResolver, _coop_mod: int) -> Dictionary:
	var ui_choice: Dictionary = choices[choice_idx]
	var tone: int = int(ui_choice.tone)
	var template_choice: Dictionary = {}
	for c in template.choices:
		if int(c.tone) == tone:
			template_choice = c; break
	if template_choice.is_empty():
		template_choice = template.choices[choice_idx]
	# Roll using the tone's stat, zone difficulty and biome identity.
	var stat_key: StringName = PlayerClass.tone_stat(tone)
	var actor_stat: int = player.effective_stat(stat_key) + player.tone_modifier(tone) + BiomeRules.stat_mod(zone.biome, stat_key)
	var difficulty: int = 10 + int(zone.chaos * 6) + BiomeRules.tone_difficulty_mod(zone.biome, tone)
	difficulty += zone.route_diff_mod
	if Settings.story_mode:
		difficulty -= 2
	var roll := rng.range_i(1, 21) + actor_stat - difficulty
	var success: bool = roll >= 0
	var section: Dictionary = template_choice.good if success else template_choice.bad
	var result := {
		"narrative": String(section.get("narr", "")),
		"outcome": 3 if success else 1,
		"tone": tone,
		"stat_delta": int(section.get("stat_delta", 0)),
		"stat": StringName(section.get("stat", &"force")),
		"creature_dies": false,
		"creature_flees": false,
		"mutate": false,
		"injury": StringName(section.get("injury", &"")),
		"heal": StringName(section.get("heal", &"")),
		"fatal": false,
		# NPC trade extensions (applied by the director).
		"fragments": int(section.get("fragments", 0)),
		"grant_relic": bool(section.get("grant_relic", false)),
	}
	return result
