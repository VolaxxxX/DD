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
]

var _langs_played: Array = []         # for polyglot tracking
var second_chance_used_this_run: bool = false
var run_start_msec: int = 0

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

func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null: return
	f.store_var({
		"kills": kills, "dragons_seen": dragons_seen, "bosses_seen": bosses_seen,
		"runs_completed": runs_completed, "runs_total": runs_total,
		"deepest_zone": deepest_zone, "achievements": achievements,
		"langs": _langs_played,
	})

# ---------- API ----------

func record_kill(creature_id: StringName) -> void:
	var k := String(creature_id)
	kills[k] = int(kills.get(k, 0)) + 1
	_maybe_unlock(&"first_blood")
	if _total_kills() >= 100:
		_maybe_unlock(&"hundred_dead")
	save()

func record_dragon(dragon_id: StringName) -> void:
	if String(dragon_id) not in dragons_seen:
		dragons_seen.append(String(dragon_id))
	_maybe_unlock(&"dragon_witness")
	save()

func record_boss(boss_id: StringName) -> void:
	if String(boss_id) not in bosses_seen:
		bosses_seen.append(String(boss_id))
	save()

func record_zone_depth(idx: int) -> void:
	deepest_zone = maxi(deepest_zone, idx)
	save()

func record_run_start() -> void:
	runs_total += 1
	second_chance_used_this_run = false
	run_start_msec = Time.get_ticks_msec()
	save()

func can_use_second_chance() -> bool:
	return not second_chance_used_this_run

func consume_second_chance() -> void:
	second_chance_used_this_run = true

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

func record_titan_survived() -> void:
	_maybe_unlock(&"titan_breaker")
	save()

func record_language(lang: String) -> void:
	if lang not in _langs_played: _langs_played.append(lang)
	if _langs_played.size() >= 3: _maybe_unlock(&"polyglot")
	save()

func _maybe_unlock(id: StringName) -> bool:
	if String(id) in achievements: return false
	achievements.append(String(id))
	return true

func _total_kills() -> int:
	var n := 0
	for v in kills.values(): n += int(v)
	return n

func kill_count(creature_id: StringName) -> int:
	return int(kills.get(String(creature_id), 0))

func unlocked(achievement_id: StringName) -> bool:
	return String(achievement_id) in achievements
