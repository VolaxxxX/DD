class_name PhrasePoolID extends RefCounted
# Indonesian narrative pack (compact). Same API shape as PhrasePool.

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"Kau mengangkat bilahmu tanpa sepatah kata dan maju.",
			"Kau menerjang, rasa takut berubah jadi amarah.",
			"Kau membidik leher — satu serangan, tepat.",
			"Kau menyerang lebih dulu, ke jantung keheningannya.",
			"Kau ambil risiko satu tebasan lebar. Jika meleset, kau mati.",
		]
		1: return [
			"Kau membuka telapak tangan dan bicara pelan.",
			"Kau berlutut perlahan, kepala tertunduk.",
			"Kau menawarkan pertukaran — suaramu gemetar tapi bertahan.",
			"Kau bertanya apa yang dicarinya. Kau sungguh mendengarkan.",
			"Kau menyebutkan namamu. Hanya itu yang bisa kau berikan.",
		]
		2: return [
			"Kau mundur selangkah, terukur, tanpa melepas tatapannya.",
			"Kau memutar jauh, menjaga jarak.",
			"Kau melebur ke bayangan dan menahan napas.",
			"Kau melempar batu jauh-jauh, berharap mengalihkannya.",
			"Kau menunggu sampai ia bosan, diam seperti kematian.",
		]
		3: return [
			"Kau mendekat untuk mengamati tanda di tubuhnya.",
			"Kau memungut pecahan yang jatuh dan memeriksanya.",
			"Kau memperhatikan bayangannya. Geraknya tak seperti bayanganmu.",
			"Kau mencari apa yang sedang ia lindungi.",
			"Kau bertanya-tanya, dulu ia ini apa.",
		]
		4: return [
			"Kau menunjukkan satu tangan kosong, tangan lain di belatimu.",
			"Kau bersumpah hanya pengelana tersesat. Kau sudah menghitung giginya.",
			"Kau pura-pura terluka — satu rintihan di saat yang pas.",
			"Kau menawarkan kesepakatan yang tak akan pernah kau tepati.",
			"Kau memberi nama palsu. Kau cukup memercayainya agar ia juga percaya.",
		]
		5: return [
			"Kau menggores tanda kuno di debu tanpa melihat.",
			"Kau mengucapkan kata yang bukan milik bahasa manusia mana pun.",
			"Kau memejamkan mata dan membiarkan sesuatu yang lain melihat untukmu.",
			"Kau mempersembahkan setetes darahmu pada angin. Satu saja.",
			"Kau mempersembahkan keheninganmu pada yang sedang mendengarkan.",
		]
	return ["Kau melangkah ke samping."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	var T := {
		0: { 4: ["Bilahmu menemukan celah. %s rubuh tanpa suara.", "Satu pukulan sempurna. %s jatuh sebelum mengerti."],
			 3: ["%s tumbang di pertukaran ketiga. Kau bernapas.", "Pertarungan singkat. %s menyerah. Kau berdarah sedikit."],
			 2: ["%s mundur pincang, tapi kau tak utuh.", "Kalian berpisah dalam diam. Masing-masing kehilangan sesuatu."],
			 1: ["Seranganmu meleset. %s membalas dan daging terbuka.", "Kau meleset dari sasaranmu. %s tidak."],
			 0: ["%s mencabikmu sebelum kakimu mendarat.", "Kau sudah tersungkur. %s menatapmu tanpa terburu-buru."] },
		1: { 4: ["%s membungkuk. Ikatan sunyi terjalin di antara kalian.", "Kata-katamu menyentuh sesuatu yang tua. %s membiarkanmu lewat."],
			 3: ["%s mendengarkan. Bahunya turun. Ia pergi tanpa sesal.", "Kalian menemukan kesepakatan. Tak ada yang berdarah hari ini."],
			 2: ["%s ragu, lalu membuang muka. Hanya itu yang kau dapat.", "Kau mendapat gencatan. Bukan damai — tapi lebih baik dari perang."],
			 1: ["%s tak mengerti. Atau tak mau. Sikap tubuhnya berubah.", "Kata-katamu terdengar palsu bahkan bagimu. Bagi %s juga."],
			 0: ["%s menganggap telapak terbukamu kelemahan. Ia menyerang.", "Sesuatu yang kau ucapkan membangunkan amarah lama."] },
		2: { 4: ["%s tak pernah melihatmu. Kau sudah jauh.", "Kau bergerak seperti udara. %s takkan pernah tahu kau di sini."],
			 3: ["Kau menjauh. %s kehilangan jejakmu.", "Kau melakukannya dengan benar — pelan, tepat. Kau keluar utuh."],
			 2: ["Kau lolos, tapi kini ia tahu kau pernah di sini.", "%s melihatmu dari sudut matanya, dan membiarkanmu pergi."],
			 1: ["%s mengangkat kepala — kau terlihat. Kau lari.", "Ia mencium baumu bahkan sebelum kau bergerak."],
			 0: ["%s ada di belakangmu sejak tadi.", "Ia tak mengikutimu. Ia menunggu di tempat tujuanmu."] },
		3: { 4: ["Kau menemukan serpihan yang mengubah segalanya.", "Kau memahami sesuatu yang tak pernah dilihat siapa pun pada %s."],
			 3: ["Satu detail mengajarimu sesuatu yang benar tentang tempat ini.", "%s membiarkanmu mengamati. Kau belajar."],
			 2: ["Kau belajar sedikit. Kau kehilangan sedikit.", "Sekarang kau tahu. Kau tak lagi yakin ingin tahu."],
			 1: ["Kau berlama-lama. %s merasakan rasa ingin tahumu dan membencinya.", "Yang kau sentuh menyentuhmu balik. Panas."],
			 0: ["Kau menatap terlalu dalam. Sesuatu menatap balik.", "%s mengerti apa yang kau pahami. Ia memilihmu mati bersamanya."] },
		4: { 4: ["%s memercayaimu. Kau pergi membawa miliknya.", "Kebohonganmu begitu sempurna sampai kau sendiri hampir percaya."],
			 3: ["%s ragu, tapi menurunkan kewaspadaan. Cukup.", "Ia tak tahu baru saja tertipu. Itulah intinya."],
			 2: ["%s menebak sebagian tipuanmu. Kau menang sebagian, kalah sebagian.", "Kalian berbagi kebohongan. Tak ada yang tertipu. Tak ada yang mengakuinya."],
			 1: ["%s membaca kebohonganmu sebelum kau selesai bicara.", "Satu detail kecil mengkhianatimu. %s tak pernah melewatkan detail."],
			 0: ["%s bermain lebih baik darimu. Saat kau sadar, semua terlambat.", "Jebakan itu untukmu sejak awal. %s tersenyum."] },
		5: { 4: ["Sesuatu menjawab. %s menyingkir, seperti di depan pintu.", "Tandanya bertahan. Dunia terbuka untuk satu tarikan napas."],
			 3: ["Getaran melintasi udara. %s mundur, ragu.", "Sesuatu mendengarkan. Dan menjawab, dengan caranya."],
			 2: ["Ritus itu setengah berhasil. Kau mendapat serpihan. Kau membayar serpihan.", "Kau menyentuh sisi bawah dunia. Ia menyentuhmu balik."],
			 1: ["Kata-kata itu melawanmu. %s merasakan kelemahanmu dan mendekat.", "Kau salah mengucap satu kata. %s mendengar kesalahan itu sebelum kau."],
			 0: ["Kau mengucapkan yang seharusnya tak diucapkan. Sesuatu yang tua kini mengawasi.", "Ritus itu berhasil — untuk %s. Ia memungut apa yang kau panggil."] },
	}
	var tone_d: Dictionary = T.get(tone, {})
	return tone_d.get(outcome, ["Tidak terjadi apa-apa."])

static func biome_intro(biome: StringName, corruption: float) -> String:
	var base := ""
	match String(biome):
		"forest":    base = "Kau memasuki hutan. Dedaunan menelan langkahmu."
		"city":      base = "Kau menyusuri tembok kota yang terlupakan. Mata, di mana-mana."
		"ruins":     base = "Kau berjalan di antara batu-batu yang mengenal berabad-abad."
		"corrupted": base = "Tanah ini sakit. Bumi berdenyut di bawah kakimu."
		"anomaly":   base = "Tak ada di sini yang menuruti aturan yang kau kenal."
		"swamp":     base = "Airnya membusuk. Setiap langkah melepaskan bau purba."
		"highland":  base = "Angin memotong napasmu. Langit luas, tak acuh."
		"crypt":     base = "Udara berbau batu basah. Kau hanya mendengar napasmu sendiri."
		"coast":     base = "Garam memerihkan mata. Sesuatu di kejauhan bukanlah kayu apung."
		_:           base = "Kau terus berjalan."
	if corruption > 0.6: base += " Sesuatu mengawasimu tanpa mata."
	return base
