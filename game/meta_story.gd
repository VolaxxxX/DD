class_name MetaStory extends RefCounted
# Meta-narrative: WHY the Voyageur is stranded in the Drift, and how to truly
# escape. Each run (success OR failure) reveals one fragment when the player
# returns to the Sanctuaire. Death advances the story too — it is never wasted.

const STEPS := [
	{
		"speaker": {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"},
		"text": {
			"fr": "Tu n'es pas le premier, {name}. Le seuil te ramène ici parce que tu portes encore quelque chose de l'autre côté.",
			"en": "You're not the first, {name}. The threshold returns you here because you still carry something from the other side.",
			"id": "Kau bukan yang pertama, {name}. Ambang batas mengembalikanmu kerana kau masih membawa sesuatu dari sisi lain.",
		},
	},
	{
		"speaker": {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"},
		"text": {
			"fr": "Les Confins ne sont qu'un voile. Au Cœur de la Dérive, il y a une chose qui ressemble à une porte. Mais ce n'est pas une porte.",
			"en": "The Reaches are only a veil. At the Heart of the Drift lies something that looks like a door. But it is not a door.",
			"id": "Tepian hanyalah tabir. Di Jantung Arus terdapat sesuatu yang menyerupai pintu. Tapi itu bukan pintu.",
		},
	},
	{
		"speaker": {"fr": "Un pèlerin sans nom", "en": "A nameless pilgrim", "id": "Sang peziarah tanpa nama"},
		"text": {
			"fr": "J'ai vu d'autres comme toi, {name}. Ils tombaient, recommencaient, tombaient encore. Aucun ne portait son nom jusqu'au bout.",
			"en": "I've seen others like you, {name}. They'd fall, restart, fall again. None carried their name to the end.",
			"id": "Aku pernah melihat yang lain sepertimu, {name}. Mereka jatuh, mulai lagi, jatuh lagi. Tak ada yang membawa nama hingga akhir.",
		},
	},
	{
		"speaker": {"fr": "Flair", "en": "Flair", "id": "Flair"},
		"text": {
			"fr": "{flair} renifle l'air et grogne doucement. Le Cœur sait que tu reviens. Chaque traversée, il t'attend un peu plus.",
			"en": "{flair} sniffs the air and growls softly. The Heart knows you return. Each crossing, it waits for you a little more.",
			"id": "{flair} mengendus udara dan menggeram pelan. Jantung tahu kau kembali. Setiap penjelajahan, ia menunggumu sedikit lebih lama.",
		},
	},
	{
		"speaker": {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"},
		"text": {
			"fr": "Les morts ne sont pas perdues, {name}. Chaque échec laisse un écho. C'est avec ces échos que les anciens ont bâti ce lieu — ce Sanctuaire que tu vois grandir.",
			"en": "Deaths are not wasted, {name}. Each failure leaves an echo. With those echoes the ancients built this place — this Sanctuary you see grow.",
			"id": "Kematian tidak sia-sia, {name}. Setiap kegagalan meninggalkan gema. Dengan gema itu para sesepuh membangun tempat ini — Sanctuari yang kau lihat tumbuh.",
		},
	},
	{
		"speaker": {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"},
		"text": {
			"fr": "Au bout, il faudra renoncer à ce que tu portes encore. La porte ne s'ouvre que pour celui qui n'a plus rien à laisser tomber.",
			"en": "At the end, you'll have to let go of what you still carry. The door only opens for one who has nothing left to drop.",
			"id": "Pada akhirnya, kau harus melepas apa yang masih kau bawa. Pintu itu hanya terbuka bagi yang tak punya apa-apa lagi untuk dijatuhkan.",
		},
	},
	{
		"speaker": {"fr": "La Gardienne", "en": "The Keeper", "id": "Sang Penjaga"},
		"text": {
			"fr": "Reviens autant qu'il faudra, {name}. Le Sanctuaire t'attendra. Et nous aussi.",
			"en": "Come back as many times as you must, {name}. The Sanctuary will wait. So will we.",
			"id": "Pulanglah sebanyak yang perlu, {name}. Sanctuari akan menunggu. Kami pun.",
		},
	},
]

static func step_count() -> int:
	return STEPS.size()

# Returns {speaker, text} with {name} / {flair} placeholders substituted.
static func step(idx: int, lang: String, voyageur: String, flair: String) -> Dictionary:
	if idx < 0 or idx >= STEPS.size(): return {}
	var s: Dictionary = STEPS[idx]
	var speak: String = s.speaker.get(lang, s.speaker.get("fr", ""))
	var text: String = s.text.get(lang, s.text.get("fr", ""))
	var v: String = voyageur if voyageur != "" else ("Voyageur" if lang == "fr" else ("Traveler" if lang == "en" else "Pengelana"))
	var f: String = flair if flair != "" else "Flair"
	text = text.replace("{name}", v).replace("{flair}", f)
	return {"speaker": speak, "text": text}
