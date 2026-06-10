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
		"menu_new":   {"fr": "NOUVELLE DÉRIVE", "en": "NEW DRIFT", "id": "ARUS BARU"},
		"menu_codex": {"fr": "BESTIAIRE", "en": "BESTIARY", "id": "BESTIARI"},
		"menu_quit":  {"fr": "QUITTER", "en": "QUIT", "id": "KELUAR"},
		"back":       {"fr": "RETOUR", "en": "BACK", "id": "KEMBALI"},
		"tag_common":   {"fr": "Commun",   "en": "Common",   "id": "Umum"},
		"tag_uncommon": {"fr": "Peu commun","en": "Uncommon","id": "Tidak umum"},
		"tag_rare":     {"fr": "Rare",     "en": "Rare",     "id": "Langka"},
		"tag_elite":    {"fr": "Élite",    "en": "Elite",    "id": "Elit"},
		"tag_apex":     {"fr": "Apex",     "en": "Apex",     "id": "Puncak"},
		"tag_mythic":   {"fr": "Mythique", "en": "Mythic",   "id": "Mitos"},
		"tag_dragon":   {"fr": "Dragon",   "en": "Dragon",   "id": "Naga"},
		"tag_wboss":    {"fr": "Titan",    "en": "Titan",    "id": "Titan"},
		"weakness":     {"fr": "Approche conseillée", "en": "Recommended approach", "id": "Pendekatan disarankan"},
		"rarity":       {"fr": "Rareté", "en": "Rarity", "id": "Kelangkaan"},
		"effect":       {"fr": "Effet", "en": "Effect", "id": "Efek"},
		"biomes":       {"fr": "Habitats", "en": "Habitats", "id": "Habitat"},
		"all":          {"fr": "Tout", "en": "All", "id": "Semua"},
		"creatures":    {"fr": "Créatures", "en": "Creatures", "id": "Makhluk"},
		"dragons":      {"fr": "Dragons", "en": "Dragons", "id": "Naga"},
		"titans":       {"fr": "Titans", "en": "Titans", "id": "Titan"},
		"tagline":      {"fr": "Les enfers s'invitent. Chaque pas écrit ton dernier.",
		                 "en": "The depths invite themselves in. Each step writes your last.",
		                 "id": "Kedalaman mengundang dirinya. Setiap langkah menulis langkahmu yang terakhir."},
	}
	return t(table.get(key, {}))
