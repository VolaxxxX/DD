class_name Lang extends RefCounted
# Language selection: fr (default), en, id. Persisted to user://lang.cfg.

static var code: String = "fr"

static func load_pref() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://lang.cfg") == OK:
		code = String(cfg.get_value("lang", "code", "fr"))

static func save_pref() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("lang", "code", code)
	cfg.save("user://lang.cfg")

# Pick a value from {fr:..., en: ..., id: ...} with FR fallback.
static func t(d: Dictionary) -> String:
	return String(d.get(code, d.get("fr", "")))

# Common UI strings.
static func ui(key: String) -> String:
	var table := {
		"force":     {"fr": "FORCE", "en": "MIGHT", "id": "KEKUATAN"},
		"zone":      {"fr": "Z.", "en": "Z.", "id": "Z."},
		"run_over":  {"fr": "FIN DU PÉRIPLE", "en": "THE JOURNEY ENDS", "id": "PERJALANAN BERAKHIR"},
		"killed_by": {"fr": "tué par", "en": "slain by", "id": "dibunuh oleh"},
		"extracted": {"fr": "extrait", "en": "extracted", "id": "berhasil keluar"},
		"enter":     {"fr": "ENTRER DANS LA DÉRIVE", "en": "ENTER THE DRIFT", "id": "MASUKI ARUS"},
		"p1_ok":     {"fr": "VALIDER JOUEUR 1", "en": "CONFIRM PLAYER 1", "id": "KONFIRMASI PEMAIN 1"},
		"p2_ok":     {"fr": "VALIDER JOUEUR 2 — ENTRER", "en": "CONFIRM PLAYER 2 — ENTER", "id": "KONFIRMASI PEMAIN 2 — MASUK"},
		"duo":       {"fr": "MODE DUO (à deux sur ce téléphone)", "en": "DUO MODE (two players, one phone)", "id": "MODE DUO (dua pemain, satu HP)"},
		"points":    {"fr": "POINTS À RÉPARTIR : %d", "en": "POINTS TO ALLOCATE: %d", "id": "POIN UNTUK DIBAGI: %d"},
		"name":      {"fr": "NOM", "en": "NAME", "id": "NAMA"},
		"subtitle":  {"fr": "Choisis qui tu seras.", "en": "Choose who you will be.", "id": "Pilih siapa dirimu."},
		"grief":     {"fr": "Ton compagnon ne se relève pas. Tu continues seul, et quelque chose en toi reste là-bas.",
		              "en": "Your companion does not rise. You walk on alone, and something of you stays behind.",
		              "id": "Rekanmu tidak bangkit lagi. Kau melanjutkan sendirian, dan sebagian dirimu tertinggal di sana."},
	}
	return t(table.get(key, {}))
