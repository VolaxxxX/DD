extends Node
# Persistent run-to-run progress: kill counts per creature, dragons faced,
# bosses defeated, and unlocked achievements. Autoloaded as "Progress".

const PATH := "user://progress.dat"

var kills: Dictionary = {}             # creature_id (String) -> int
var dragons_seen: Array = []           # dragon_id list
var bosses_seen: Array = []            # boss_id list
var runs_completed: int = 0
var runs_total: int = 0
var deepest_zone: int = 0
var achievements: Array = []           # array of unlocked achievement ids

const ACHIEVEMENTS := [
	{"id": &"first_blood",    "title": {"fr": "Premier sang", "en": "First blood", "id": "Darah pertama"},
	 "desc":  {"fr": "Tuer ta première créature.", "en": "Kill your first creature.", "id": "Bunuh makhluk pertamamu."}},
	{"id": &"hundred_dead",   "title": {"fr": "Cent morts", "en": "Hundred kills", "id": "Seratus tewas"},
	 "desc":  {"fr": "Tuer 100 créatures au total.", "en": "Kill 100 creatures.", "id": "Bunuh 100 makhluk."}},
	{"id": &"dragon_witness", "title": {"fr": "Témoin d'un dragon", "en": "Dragon witness", "id": "Saksi naga"},
	 "desc":  {"fr": "Voir un dragon traverser le ciel.", "en": "Witness a dragon flyby.", "id": "Saksikan naga melintas."}},
	{"id": &"titan_breaker",  "title": {"fr": "Briseur de titan", "en": "Titan breaker", "id": "Penghancur titan"},
	 "desc":  {"fr": "Survivre à un world boss.", "en": "Survive a world boss.", "id": "Bertahan dari titan dunia."}},
	{"id": &"clean_run",      "title": {"fr": "Sans une égratignure", "en": "Without a scratch", "id": "Tanpa luka"},
	 "desc":  {"fr": "Finir un run sans aucune blessure.", "en": "Finish a run with no injuries.", "id": "Selesaikan run tanpa luka."}},
	{"id": &"five_runs",      "title": {"fr": "Vétéran", "en": "Veteran", "id": "Veteran"},
	 "desc":  {"fr": "Compléter 5 runs.", "en": "Complete 5 runs.", "id": "Selesaikan 5 run."}},
	{"id": &"polyglot",       "title": {"fr": "Polyglotte", "en": "Polyglot", "id": "Penguasa bahasa"},
	 "desc":  {"fr": "Jouer dans les 3 langues.", "en": "Play in all 3 languages.", "id": "Mainkan dalam 3 bahasa."}},
	{"id": &"duo_survives",   "title": {"fr": "Lien indéfectible", "en": "Unbreakable bond", "id": "Ikatan tak terputuskan"},
	 "desc":  {"fr": "Compléter un run en duo sans perdre personne.", "en": "Finish a duo run with both alive.", "id": "Selesaikan run duo, keduanya hidup."}},
	{"id": &"relic_hoarder", "title": {"fr": "Collectionneur", "en": "Hoarder", "id": "Pengumpul"},
	 "desc": {"fr": "Porter 3 reliques en même temps.", "en": "Hold 3 relics at once.", "id": "Bawa 3 relik sekaligus."}},
	{"id": &"all_classes",   "title": {"fr": "Mille visages", "en": "Many faces", "id": "Banyak wajah"},
	 "desc": {"fr": "Jouer avec les 4 classes.", "en": "Play all 4 classes.", "id": "Mainkan keempat kelas."}},
	{"id": &"village_friend","title": {"fr": "Ami du village", "en": "Village friend", "id": "Sahabat desa"},
	 "desc": {"fr": "Visiter le village 5 fois.", "en": "Visit the village 5 times.", "id": "Kunjungi desa 5 kali."}},
	{"id": &"long_traveler", "title": {"fr": "Voyageur infatigable", "en": "Tireless traveler", "id": "Pengembara tak kenal lelah"},
	 "desc": {"fr": "Tenter 20 runs.", "en": "Attempt 20 runs.", "id": "Coba 20 run."}},
	{"id": &"second_chancer","title": {"fr": "Frôlé par la mort", "en": "Brushed by death", "id": "Disentuh kematian"},
	 "desc": {"fr": "Survivre grâce à la seconde chance.", "en": "Survive via the second chance.", "id": "Selamat lewat kesempatan kedua."}},
	{"id": &"witness_all_dragons", "title": {"fr": "Œil pour les onze", "en": "Eyes for the eleven", "id": "Mata bagi sebelas"},
	 "desc": {"fr": "Voir les 11 dragons.", "en": "Witness all 11 dragons.", "id": "Saksikan semua 11 naga."}},
	{"id": &"all_titans",   "title": {"fr": "Briseur de mondes", "en": "World breaker", "id": "Pemecah dunia"},
	 "desc": {"fr": "Voir les 7 titans.", "en": "Witness all 7 titans.", "id": "Saksikan semua 7 titan."}},
]

# Track helpers for the new achievements
var _classes_played: Array = []
var _village_visits: int = 0

var _langs_played: Array = []         # for polyglot tracking
var second_chance_used_this_run: bool = false
var run_start_msec: int = 0
var fragments: int = 0                # short-term currency, spent IN run
var fragment_scale: float = 1.0       # route multiplier (set per zone, not saved)
var npc_meetings: Dictionary = {}     # npc_id -> times met (persists: they remember you)
var next_zone_blessing: StringName = &""   # buff applied at next zone start

# --- Persistent meta-progression fields (replace the +1-stat Sanctuaire) ---
var echoes: int = 0                   # RARE currency, earned ONLY on extraction
var family_karma: Dictionary = {}     # family int -> {"kills": int, "spared": int}
var tone_usage: Dictionary = {}       # tone int -> count
var class_usage: Dictionary = {}      # class kind int -> count
var story_index: int = 0              # # of meta-story fragments revealed
var voyageur_name: String = ""        # custom Traveler name (empty = use class name)
var flair_name: String = ""           # custom Companion name (empty = random)
var npc_bonds: Dictionary = {}        # npc_id -> {"helped": int, "betrayed": int, "owes": bool}
var tone_unlocks: Array = []          # ids of unlocked tone variants (mastery)
var class_unlocks: Array = []         # ids of unlocked class passives (mastery)
var sanctum_residents: Array = []     # npc_ids of PNJs that live in the Sanctuaire
var sanctum_trophies: Array = []      # creature_ids displayed as trophies
const ECHOES_PER_EXTRACTION := 1      # base; +1 per zone past 3

const KILL_REWARD := 1
const ELITE_REWARD := 3
const APEX_REWARD := 5
const DRAGON_REWARD := 5
const TITAN_REWARD := 15
const ZONE_REWARD := 10

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(PATH): return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null: return
	var v = f.get_var()
	if typeof(v) != TYPE_DICTIONARY: return
	kills = v.get("kills", {})
	dragons_seen = v.get("dragons_seen", [])
	bosses_seen = v.get("bosses_seen", [])
	runs_completed = int(v.get("runs_completed", 0))
	runs_total = int(v.get("runs_total", 0))
	deepest_zone = int(v.get("deepest_zone", 0))
	achievements = v.get("achievements", [])
	_langs_played = v.get("langs", [])
	fragments = int(v.get("fragments", 0))
	# v.get("meta_level", 0) — legacy +1-stat Sanctuaire field, ignored on
	# purpose so old saves load cleanly (replaced by the lived-in Sanctuaire).
	_classes_played = v.get("classes_played", [])
	_village_visits = int(v.get("village_visits", 0))
	npc_meetings = v.get("npc_meetings", {})
	echoes = int(v.get("echoes", 0))
	family_karma = v.get("family_karma", {})
	tone_usage = v.get("tone_usage", {})
	class_usage = v.get("class_usage", {})
	story_index = int(v.get("story_index", 0))
	voyageur_name = String(v.get("voyageur_name", ""))
	flair_name = String(v.get("flair_name", ""))
	npc_bonds = v.get("npc_bonds", {})
	tone_unlocks = v.get("tone_unlocks", [])
	class_unlocks = v.get("class_unlocks", [])
	sanctum_residents = v.get("sanctum_residents", [])
	sanctum_trophies = v.get("sanctum_trophies", [])

func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null: return
	f.store_var({
		"kills": kills, "dragons_seen": dragons_seen, "bosses_seen": bosses_seen,
		"runs_completed": runs_completed, "runs_total": runs_total,
		"deepest_zone": deepest_zone, "achievements": achievements,
		"langs": _langs_played, "fragments": fragments,
		"classes_played": _classes_played, "village_visits": _village_visits,
		"npc_meetings": npc_meetings,
		"echoes": echoes, "family_karma": family_karma,
		"tone_usage": tone_usage, "class_usage": class_usage,
		"story_index": story_index,
		"voyageur_name": voyageur_name, "flair_name": flair_name,
		"npc_bonds": npc_bonds,
		"tone_unlocks": tone_unlocks, "class_unlocks": class_unlocks,
		"sanctum_residents": sanctum_residents,
		"sanctum_trophies": sanctum_trophies,
	})

# Returns the new meeting count (1 = first time ever).
func record_npc_meeting(npc_id: StringName) -> int:
	var k := String(npc_id)
	npc_meetings[k] = int(npc_meetings.get(k, 0)) + 1
	save()
	return int(npc_meetings[k])

# ---------- API ----------

func record_kill(creature_id: StringName) -> void:
	var k := String(creature_id)
	kills[k] = int(kills.get(k, 0)) + 1
	fragments += int(round(KILL_REWARD * fragment_scale))
	_maybe_unlock(&"first_blood")
	if _total_kills() >= 100:
		_maybe_unlock(&"hundred_dead")
	save()

func record_elite_kill() -> void:
	fragments += int(round(ELITE_REWARD * fragment_scale))
	save()

func record_dragon(dragon_id: StringName) -> void:
	if String(dragon_id) not in dragons_seen:
		dragons_seen.append(String(dragon_id))
	fragments += int(round(DRAGON_REWARD * fragment_scale))
	_maybe_unlock(&"dragon_witness")
	save()

func record_zone_cleared() -> void:
	fragments += int(round(ZONE_REWARD * fragment_scale))
	save()

func record_titan_survived() -> void:
	fragments += int(round(TITAN_REWARD * fragment_scale))
	_maybe_unlock(&"titan_breaker")
	save()

func spend(amount: int) -> bool:
	if fragments < amount: return false
	fragments -= amount
	save()
	return true

func record_boss(boss_id: StringName) -> void:
	if String(boss_id) not in bosses_seen:
		bosses_seen.append(String(boss_id))
	save()

func record_zone_depth(idx: int) -> void:
	deepest_zone = maxi(deepest_zone, idx)
	save()

func record_run_start() -> void:
	runs_total += 1
	if runs_total >= 20: _maybe_unlock(&"long_traveler")
	if dragons_seen.size() >= 11: _maybe_unlock(&"witness_all_dragons")
	if bosses_seen.size() >= 7: _maybe_unlock(&"all_titans")
	second_chance_used_this_run = false
	run_start_msec = Time.get_ticks_msec()
	save()

func can_use_second_chance() -> bool:
	return not second_chance_used_this_run

func consume_second_chance() -> void:
	second_chance_used_this_run = true
	_maybe_unlock(&"second_chancer")
	save()

func record_class_played(kind: int) -> void:
	if kind not in _classes_played: _classes_played.append(kind)
	if _classes_played.size() >= 4:
		_maybe_unlock(&"all_classes")
	save()

func record_village_visit() -> void:
	_village_visits += 1
	if _village_visits >= 5:
		_maybe_unlock(&"village_friend")
	save()

func check_relic_hoarder(count: int) -> void:
	if count >= 3:
		_maybe_unlock(&"relic_hoarder")
		save()

func run_duration_seconds() -> int:
	if run_start_msec == 0: return 0
	return int((Time.get_ticks_msec() - run_start_msec) / 1000.0)

func first_kill_of(creature_id: StringName) -> bool:
	# True if this id has never been killed before.
	return int(kills.get(String(creature_id), 0)) == 0

func record_run_end(extracted: bool, any_injuries: bool, duo_both_alive: bool) -> void:
	if extracted:
		runs_completed += 1
		_maybe_unlock(&"titan_breaker") if &"titan_breaker" in achievements else null
		if not any_injuries: _maybe_unlock(&"clean_run")
		if duo_both_alive: _maybe_unlock(&"duo_survives")
		if runs_completed >= 5: _maybe_unlock(&"five_runs")
	save()

func record_language(lang: String) -> void:
	if lang not in _langs_played: _langs_played.append(lang)
	if _langs_played.size() >= 3: _maybe_unlock(&"polyglot")
	save()

signal achievement_unlocked(id: StringName)

func _maybe_unlock(id: StringName) -> bool:
	if String(id) in achievements: return false
	achievements.append(String(id))
	achievement_unlocked.emit(id)
	return true

func _total_kills() -> int:
	var n := 0
	for v in kills.values(): n += int(v)
	return n

func kill_count(creature_id: StringName) -> int:
	return int(kills.get(String(creature_id), 0))

func unlocked(achievement_id: StringName) -> bool:
	return String(achievement_id) in achievements

# ---------- PHASE 1-6: Persistent meta-progression API ----------

# Family karma persists ACROSS runs (kills/spared cumulatively per family).
func record_family_action(family: int, kind: String) -> void:
	var k := str(family)
	var entry: Dictionary = family_karma.get(k, {"kills": 0, "spared": 0})
	if kind == "kill":
		entry["kills"] = int(entry.get("kills", 0)) + 1
	elif kind == "spared":
		entry["spared"] = int(entry.get("spared", 0)) + 1
	family_karma[k] = entry
	save()

func family_kills(family: int) -> int:
	return int(family_karma.get(str(family), {}).get("kills", 0))

func family_spared(family: int) -> int:
	return int(family_karma.get(str(family), {}).get("spared", 0))

# Tone & class mastery: counts cumulate, unlocks fire automatically at thresholds.
const TONE_UNLOCK_THRESHOLDS := [10, 25, 60]   # mastery tiers per tone
const CLASS_UNLOCK_THRESHOLDS := [3, 8, 20]    # runs played with that class

func record_tone_use(tone: int) -> Array:
	var k := str(tone)
	tone_usage[k] = int(tone_usage.get(k, 0)) + 1
	var freshly: Array = []
	for tier in TONE_UNLOCK_THRESHOLDS.size():
		if int(tone_usage[k]) >= TONE_UNLOCK_THRESHOLDS[tier]:
			var uid := "tone_%d_t%d" % [tone, tier]
			if uid not in tone_unlocks:
				tone_unlocks.append(uid)
				freshly.append(uid)
	if not freshly.is_empty(): save()
	return freshly

func record_class_run(kind: int) -> Array:
	var k := str(kind)
	class_usage[k] = int(class_usage.get(k, 0)) + 1
	var freshly: Array = []
	for tier in CLASS_UNLOCK_THRESHOLDS.size():
		if int(class_usage[k]) >= CLASS_UNLOCK_THRESHOLDS[tier]:
			var uid := "class_%d_t%d" % [kind, tier]
			if uid not in class_unlocks:
				class_unlocks.append(uid)
				freshly.append(uid)
	if not freshly.is_empty(): save()
	return freshly

func has_tone_unlock(tone: int, tier: int) -> bool:
	return ("tone_%d_t%d" % [tone, tier]) in tone_unlocks

func has_class_unlock(kind: int, tier: int) -> bool:
	return ("class_%d_t%d" % [kind, tier]) in class_unlocks

# Rare currency (Échos) — awarded ONLY on a successful extraction.
func award_extraction_echoes(zones_cleared: int) -> int:
	var gained: int = ECHOES_PER_EXTRACTION + maxi(0, zones_cleared - 3)
	echoes += gained
	save()
	return gained

func spend_echoes(amount: int) -> bool:
	if echoes < amount: return false
	echoes -= amount
	save()
	return true

# Story fragments revealed at the Sanctuary on RETURN (success OR death).
# Returns the new fragment index revealed (-1 if nothing new).
func reveal_next_story_step(max_steps: int) -> int:
	if story_index >= max_steps: return -1
	var idx := story_index
	story_index += 1
	save()
	return idx

# Naming.
func set_voyageur_name(n: String) -> void:
	voyageur_name = n.strip_edges().substr(0, 24)
	save()

func set_flair_name(n: String) -> void:
	flair_name = n.strip_edges().substr(0, 24)
	save()

# NPC bonds: long-term relationship (helped vs betrayed). owes == intervention pending.
func bond_helped(npc_id: StringName) -> void:
	var k := String(npc_id)
	var b: Dictionary = npc_bonds.get(k, {"helped": 0, "betrayed": 0, "owes": false})
	b["helped"] = int(b.get("helped", 0)) + 1
	if int(b["helped"]) >= 3 and int(b.get("betrayed", 0)) == 0:
		b["owes"] = true
	npc_bonds[k] = b
	save()

func bond_betrayed(npc_id: StringName) -> void:
	var k := String(npc_id)
	var b: Dictionary = npc_bonds.get(k, {"helped": 0, "betrayed": 0, "owes": false})
	b["betrayed"] = int(b.get("betrayed", 0)) + 1
	b["owes"] = false
	npc_bonds[k] = b
	save()

func bond_consume_owes(npc_id: StringName) -> bool:
	var k := String(npc_id)
	var b: Dictionary = npc_bonds.get(k, {})
	if not bool(b.get("owes", false)): return false
	b["owes"] = false
	npc_bonds[k] = b
	save()
	return true

func bond_state(npc_id: StringName) -> Dictionary:
	return npc_bonds.get(String(npc_id), {"helped": 0, "betrayed": 0, "owes": false})

# Sanctuaire vivant — residents (PNJ saved) & trophies (creatures defeated).
func add_sanctum_resident(npc_id: StringName) -> bool:
	var k := String(npc_id)
	if k in sanctum_residents: return false
	sanctum_residents.append(k)
	save()
	return true

func add_sanctum_trophy(creature_id: StringName) -> bool:
	var k := String(creature_id)
	if k in sanctum_trophies: return false
	sanctum_trophies.append(k)
	save()
	return true
