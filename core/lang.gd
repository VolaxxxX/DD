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
		"menu_new":      {"fr": "NOUVELLE DÉRIVE", "en": "NEW DRIFT", "id": "ARUS BARU"},
		"menu_continue": {"fr": "CONTINUER", "en": "CONTINUE", "id": "LANJUTKAN"},
		"heal":          {"fr": "SOIGNÉ", "en": "HEALED", "id": "DISEMBUHKAN"},
		"settings":         {"fr": "PARAMÈTRES", "en": "SETTINGS", "id": "PENGATURAN"},
		"settings_music":   {"fr": "MUSIQUE", "en": "MUSIC", "id": "MUSIK"},
		"settings_sfx":     {"fr": "SONS", "en": "SFX", "id": "SUARA"},
		"settings_quality": {"fr": "QUALITÉ", "en": "QUALITY", "id": "KUALITAS"},
		"quality_low":      {"fr": "Bas",   "en": "Low",    "id": "Rendah"},
		"quality_mid":      {"fr": "Moyen", "en": "Medium", "id": "Sedang"},
		"quality_high":     {"fr": "Haut",  "en": "High",   "id": "Tinggi"},
		"menu_settings":    {"fr": "PARAMÈTRES", "en": "SETTINGS", "id": "PENGATURAN"},
		"menu_achievements":{"fr": "HAUTS FAITS", "en": "ACHIEVEMENTS", "id": "PENCAPAIAN"},
		"unlocked":         {"fr": "Débloqué", "en": "Unlocked", "id": "Terbuka"},
		"locked":           {"fr": "Verrouillé", "en": "Locked", "id": "Terkunci"},
		"tutorial_title":   {"fr": "BIENVENUE", "en": "WELCOME", "id": "SELAMAT DATANG"},
		"tutorial_body": {
			"fr": "Tu vas affronter des créatures à coups de [b]choix[/b], pas d'épée.\n\n[color=#ff7b6b]⚔  AGRESSIF[/color]  attaque, force.\n[color=#bfe7ff]✿  DIPLOMATE[/color]  parler, charme.\n[color=#f3f3bf]◯  PRUDENT[/color]  esquiver, fuir.\n[color=#d8bfff]?  CURIEUX[/color]  observer, apprendre.\n[color=#daff8b]♣  TROMPEUR[/color]  mentir, ruser.\n[color=#ffa0ff]✦  MYSTIQUE[/color]  rituels, mots anciens.\n\nLe jet est caché. Tes [b]stats[/b], la [b]créature[/b], le [b]biome[/b] et la [b]chance[/b] décident.\nUne mauvaise décision = blessure. Plusieurs blessures = mort possible.",
			"en": "You face creatures through [b]choices[/b], not swords.\n\n[color=#ff7b6b]⚔  AGGRESSIVE[/color]  strike, force.\n[color=#bfe7ff]✿  DIPLOMATIC[/color]  speak, charm.\n[color=#f3f3bf]◯  CAUTIOUS[/color]  evade, flee.\n[color=#d8bfff]?  CURIOUS[/color]  observe, learn.\n[color=#daff8b]♣  DECEPTIVE[/color]  lie, trick.\n[color=#ffa0ff]✦  MYSTICAL[/color]  rite, old words.\n\nThe roll is hidden. Your [b]stats[/b], the [b]creature[/b], the [b]biome[/b] and [b]luck[/b] decide.\nA wrong choice = injury. Enough injuries = possible death.",
			"id": "Kau menghadapi makhluk lewat [b]pilihan[/b], bukan pedang.\n\n[color=#ff7b6b]⚔  AGRESIF[/color]  serang, paksa.\n[color=#bfe7ff]✿  DIPLOMATIS[/color]  bicara, pikat.\n[color=#f3f3bf]◯  HATI-HATI[/color]  mengelak, lari.\n[color=#d8bfff]?  PENASARAN[/color]  amati, pelajari.\n[color=#daff8b]♣  PENIPU[/color]  bohong, tipu.\n[color=#ffa0ff]✦  MISTIS[/color]  ritus, kata kuno.\n\nLemparan disembunyikan. [b]Stat[/b]mu, [b]makhluk[/b], [b]bioma[/b], dan [b]keberuntungan[/b] menentukan.\nPilihan salah = luka. Cukup banyak luka = kematian mungkin."
		},
		"tutorial_ok":      {"fr": "J'AI COMPRIS", "en": "GOT IT", "id": "MENGERTI"},
		"second_chance":    {"fr": "Le destin t'épargne. Une seule fois.",
		                     "en": "Fate spares you. Just this once.",
		                     "id": "Takdir mengampunimu. Hanya sekali."},
		"first_encounter":  {"fr": "NOUVELLE RENCONTRE",
		                     "en": "NEW ENCOUNTER",
		                     "id": "PERTEMUAN BARU"},
		"summary_title":    {"fr": "FIN DU PÉRIPLE", "en": "JOURNEY'S END", "id": "AKHIR PERJALANAN"},
		"summary_zones":    {"fr": "Zones traversées", "en": "Zones crossed", "id": "Zona dilalui"},
		"summary_kills":    {"fr": "Créatures vaincues", "en": "Creatures slain", "id": "Makhluk dikalahkan"},
		"summary_time":     {"fr": "Temps", "en": "Time", "id": "Waktu"},
		"summary_discov":   {"fr": "Nouvelles rencontres", "en": "New encounters", "id": "Pertemuan baru"},
		"summary_again":    {"fr": "AU MENU", "en": "TO MENU", "id": "KE MENU"},
		"village_title":    {"fr": "VILLAGE", "en": "VILLAGE", "id": "DESA"},
		"village_subtitle": {"fr": "Une halte avant la suite. Personne ne te frappera ici.",
		                     "en": "A pause before the next step. No one strikes you here.",
		                     "id": "Jeda sebelum langkah berikutnya. Tak ada yang menyerangmu di sini."},
		"village_continue": {"fr": "REPRENDRE LA ROUTE", "en": "BACK TO THE ROAD", "id": "LANJUTKAN PERJALANAN"},
		"village_refund":   {"fr": "Tu n'as rien à soigner. Reprends.", "en": "Nothing to mend. Take it back.", "id": "Tak ada yang perlu disembuhkan."},
		"village_refund_unused": {"fr": "Le destin n'a pas encore frappé. Garde.", "en": "Fate has not struck yet. Keep it.", "id": "Takdir belum menyerang. Simpan saja."},
		"village_chance_restored":{"fr": "Une seconde chance, encore.", "en": "A second chance, again.", "id": "Kesempatan kedua, lagi."},
		"fragments":        {"fr": "fragments", "en": "fragments", "id": "kepingan"},
		"npc_healer":       {"fr": "La Guérisseuse",
		                     "en": "The Healer",
		                     "id": "Sang Penyembuh"},
		"npc_healer_desc":  {"fr": "Apaise une blessure ouverte.",
		                     "en": "Eases one open wound.",
		                     "id": "Meredakan satu luka terbuka."},
		"npc_sage":         {"fr": "Le Conteur",
		                     "en": "The Storyteller",
		                     "id": "Sang Pencerita"},
		"npc_sage_desc":    {"fr": "Bénit ta prochaine zone d'un don de stat.",
		                     "en": "Blesses your next zone with a stat boon.",
		                     "id": "Memberkati zona berikutnya dengan kenaikan stat."},
		"npc_merchant":     {"fr": "Le Marchand",
		                     "en": "The Merchant",
		                     "id": "Sang Pedagang"},
		"npc_merchant_desc":{"fr": "Une fiole permanente — +1 à une stat aléatoire.",
		                     "en": "A lasting flask — +1 to a random stat.",
		                     "id": "Botol abadi — +1 ke stat acak."},
		"npc_keeper":       {"fr": "Le Gardien",
		                     "en": "The Keeper",
		                     "id": "Sang Penjaga"},
		"npc_keeper_desc":  {"fr": "Te rend ta seconde chance, si tu l'as déjà brûlée.",
		                     "en": "Restores your second chance, if you've spent it.",
		                     "id": "Memulihkan kesempatan keduamu."},
		"menu_codex":    {"fr": "BESTIAIRE", "en": "BESTIARY", "id": "BESTIARI"},
		"menu_quit":     {"fr": "QUITTER", "en": "QUIT", "id": "KELUAR"},
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
