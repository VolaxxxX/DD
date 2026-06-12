class_name NPCRegistry extends RefCounted
# One signature NPC per biome, with a spawn chance per encounter slot (max one
# meeting per zone). They persist across runs — on a second meeting they
# remember you (different greeting). Each has a distinct mechanical identity.
# Templates are produced in the ACTIVE language (Lang.t applied at build time),
# shaped exactly like SituationRegistry templates so SituationEncounter
# resolves them unchanged.

const T_AGGR := 0
const T_DIPL := 1
const T_CAUT := 2
const T_CURI := 3
const T_DECE := 4
const T_MYST := 5

static func all() -> Array:
	return [
		{"id": &"npc_herborist", "biome": &"forest", "chance": 14,
		 "first": {"fr": "Une vieille femme cueille des herbes entre les racines. Elle ne lève pas les yeux : « Approche, voyageur. »",
			"en": "An old woman gathers herbs between the roots. She doesn't look up: \"Come closer, traveler.\"",
			"id": "Seorang wanita tua memetik herba di sela akar. Ia tak mendongak: \"Mendekatlah, pengelana.\""},
		 "again": {"fr": "La Cueilleuse sourit sans se retourner : « Te revoilà. La forêt m'avait prévenue. »",
			"en": "The Gatherer smiles without turning: \"You again. The forest told me you'd come.\"",
			"id": "Sang Pemetik tersenyum tanpa menoleh: \"Kau lagi. Hutan sudah memberitahuku.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu lui demandes un remède, poliment.", "en": "You politely ask her for a remedy.", "id": "Kau memintanya ramuan, dengan sopan."},
			 "good": {"heal": &"bleeding", "narr": {"fr": "Elle écrase trois feuilles, applique la pâte. La douleur reflue aussitôt.", "en": "She crushes three leaves and applies the paste. The pain recedes at once.", "id": "Ia melumat tiga helai daun, mengoles pastanya. Nyeri surut seketika."}},
			 "bad": {"narr": {"fr": "« Pas pour toi. Pas aujourd'hui. » Elle retourne à ses racines.", "en": "\"Not for you. Not today.\" She returns to her roots.", "id": "\"Bukan untukmu. Tidak hari ini.\" Ia kembali ke akar-akarnya."}}},
			{"tone": T_DECE,
			 "text": {"fr": "Tu fais mine de l'aider pour glisser des herbes dans ta poche.", "en": "You pretend to help while slipping herbs into your pocket.", "id": "Kau pura-pura membantu sambil menyelipkan herba ke sakumu."},
			 "good": {"heal": &"poison", "fragments": 3, "narr": {"fr": "Tu repars avec de quoi te purger — et trois graines qui valent cher.", "en": "You leave with a cure — and three seeds worth good coin.", "id": "Kau pergi membawa penawar — dan tiga biji yang berharga."}},
			 "bad": {"injury": &"poison", "narr": {"fr": "Les herbes volées te brûlent la paume. Certaines plantes choisissent leur maître.", "en": "The stolen herbs burn your palm. Some plants choose their master.", "id": "Herba curian membakar telapakmu. Sebagian tanaman memilih tuannya."}}},
		 ]},
		{"id": &"npc_fence", "biome": &"city", "chance": 14,
		 "first": {"fr": "Un homme au manteau trop large s'adosse au mur : « Psst. J'achète, je vends, j'oublie. »",
			"en": "A man in an oversized coat leans on the wall: \"Psst. I buy, I sell, I forget.\"",
			"id": "Pria berjubah kebesaran bersandar di tembok: \"Psst. Kubeli, kujual, kulupakan.\""},
		 "again": {"fr": "Le Receleur te reconnaît : « Tiens, ma meilleure clientèle. Toujours vivante, en plus. »",
			"en": "The Fence recognizes you: \"Well, my best customer. Still alive, no less.\"",
			"id": "Si Penadah mengenalimu: \"Wah, pelanggan terbaikku. Masih hidup pula.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu négocies un objet de valeur contre tes fragments. (-8 ✦)", "en": "You bargain fragments for something of value. (-8 ✦)", "id": "Kau menawar barang berharga dengan fragmenmu. (-8 ✦)"},
			 "good": {"fragments": -8, "grant_relic": true, "narr": {"fr": "Il déballe un objet qui n'aurait jamais dû finir ici. Marché conclu.", "en": "He unwraps something that should never have ended up here. Deal.", "id": "Ia membuka bungkusan benda yang seharusnya tak berakhir di sini. Sepakat."}},
			 "bad": {"fragments": -4, "narr": {"fr": "Tu paies l'acompte. Il disparaît par une porte que tu n'avais pas vue.", "en": "You pay the deposit. He vanishes through a door you hadn't seen.", "id": "Kau bayar uang muka. Ia lenyap lewat pintu yang tak kau lihat."}}},
			{"tone": T_CAUT,
			 "text": {"fr": "Tu passes ton chemin — ce sourire ne te dit rien de bon.", "en": "You walk on — that smile bodes nothing good.", "id": "Kau berlalu — senyum itu bukan pertanda baik."},
			 "good": {"fragments": 2, "narr": {"fr": "Plus loin, tu trouves la bourse qu'il venait de faire tomber. Justice de rue.", "en": "Further on you find the purse he just dropped. Street justice.", "id": "Tak jauh, kau temukan kantong uang yang baru ia jatuhkan. Keadilan jalanan."}},
			 "bad": {"narr": {"fr": "Il te suit du regard jusqu'au coin de la rue. Tu presses le pas.", "en": "His gaze follows you to the corner. You quicken your step.", "id": "Tatapannya mengikutimu sampai tikungan. Kau percepat langkah."}}},
		 ]},
		{"id": &"npc_archivist", "biome": &"ruins", "chance": 14,
		 "first": {"fr": "Entre deux colonnes, un érudit épousseta un fragment de fresque : « Chaque pierre ici a un nom. Veux-tu en connaître un ? »",
			"en": "Between two columns, a scholar dusts a fresco fragment: \"Every stone here has a name. Would you learn one?\"",
			"id": "Di antara dua pilar, seorang cendekiawan membersihkan pecahan fresko: \"Setiap batu di sini punya nama. Mau tahu satu?\""},
		 "again": {"fr": "L'Archiviste hoche la tête : « Encore toi. Les ruines aiment les habitués. »",
			"en": "The Archivist nods: \"You again. Ruins are fond of regulars.\"",
			"id": "Sang Arsiparis mengangguk: \"Kau lagi. Reruntuhan menyukai pelanggan tetap.\""},
		 "choices": [
			{"tone": T_CURI,
			 "text": {"fr": "Tu écoutes sa leçon d'histoire jusqu'au bout.", "en": "You hear his history lesson to the end.", "id": "Kau menyimak pelajaran sejarahnya sampai habis."},
			 "good": {"stat_delta": 2, "stat": &"esprit", "narr": {"fr": "Trois dynasties, une trahison, un mot de passe. Ton esprit s'aiguise.", "en": "Three dynasties, one betrayal, one password. Your mind sharpens.", "id": "Tiga dinasti, satu pengkhianatan, satu kata sandi. Pikiranmu menajam."}},
			 "bad": {"injury": &"exhaustion", "narr": {"fr": "Quatre heures. La leçon dure quatre heures. Tu ressors vidé.", "en": "Four hours. The lesson lasts four hours. You leave drained.", "id": "Empat jam. Pelajarannya empat jam. Kau keluar terkuras."}}},
			{"tone": T_MYST,
			 "text": {"fr": "Tu lui demandes le nom qu'il ne faut pas prononcer ici.", "en": "You ask him for the name that must not be spoken here.", "id": "Kau menanyakan nama yang pantang diucapkan di sini."},
			 "good": {"stat_delta": 1, "stat": &"esprit", "fragments": 5, "narr": {"fr": "Il l'écrit dans la poussière, puis l'efface. Tu as vu. Cela suffit.", "en": "He writes it in the dust, then wipes it away. You saw. That is enough.", "id": "Ia menulisnya di debu, lalu menghapusnya. Kau melihatnya. Itu cukup."}},
			 "bad": {"injury": &"curse", "narr": {"fr": "Il le prononce. Les colonnes frémissent. Quelque chose t'a entendu écouter.", "en": "He speaks it. The columns shudder. Something heard you listening.", "id": "Ia mengucapkannya. Pilar-pilar bergetar. Sesuatu mendengarmu menyimak."}}},
		 ]},
		{"id": &"npc_pilgrim", "biome": &"corrupted", "chance": 14,
		 "first": {"fr": "Un pèlerin couvert de pustules luminescentes te bénit de loin : « La chair est négociable, voyageur. »",
			"en": "A pilgrim covered in glowing pustules blesses you from afar: \"Flesh is negotiable, traveler.\"",
			"id": "Seorang peziarah berbintil cahaya memberkatimu dari jauh: \"Daging bisa dinegosiasikan, pengelana.\""},
		 "again": {"fr": "Le Pèlerin s'illumine : « Te revoilà ! La corruption se souvient de ton odeur. »",
			"en": "The Pilgrim brightens: \"You return! The corruption remembers your scent.\"",
			"id": "Sang Peziarah berbinar: \"Kau kembali! Korupsi mengingat baumu.\""},
		 "choices": [
			{"tone": T_MYST,
			 "text": {"fr": "Tu acceptes sa bénédiction impure.", "en": "You accept his impure blessing.", "id": "Kau menerima berkat najisnya."},
			 "good": {"stat_delta": 2, "stat": &"force", "injury": &"curse", "narr": {"fr": "La force coule en toi comme un métal chaud — et quelque chose s'accroche à ton ombre.", "en": "Strength pours into you like hot metal — and something latches onto your shadow.", "id": "Kekuatan mengalir seperti logam panas — dan sesuatu mencengkeram bayanganmu."}},
			 "bad": {"injury": &"poison", "narr": {"fr": "La bénédiction tourne mal. Ton sang proteste.", "en": "The blessing goes wrong. Your blood protests.", "id": "Berkat itu berbalik buruk. Darahmu memberontak."}}},
			{"tone": T_AGGR,
			 "text": {"fr": "Tu le chasses — cette chose n'est plus humaine.", "en": "You drive him off — that thing is no longer human.", "id": "Kau mengusirnya — makhluk itu bukan manusia lagi."},
			 "good": {"fragments": 4, "narr": {"fr": "Il fuit en riant. Là où il se tenait, le sol a recraché ce qu'il avait avalé.", "en": "He flees laughing. Where he stood, the ground spat back what it had swallowed.", "id": "Ia kabur sambil tertawa. Di bekasnya berdiri, tanah memuntahkan apa yang pernah ditelannya."}},
			 "bad": {"injury": &"terror", "narr": {"fr": "Il ne bouge pas. Il SOURIT. Tu recules le premier.", "en": "He doesn't move. He SMILES. You are the one who backs away.", "id": "Ia tak bergerak. Ia TERSENYUM. Kaulah yang mundur duluan."}}},
		 ]},
		{"id": &"npc_echo", "biome": &"anomaly", "chance": 14,
		 "first": {"fr": "Quelqu'un te fait face. C'est toi — avec une seconde de retard dans les gestes : « On échange ? »",
			"en": "Someone faces you. It's you — gestures lagging one second behind: \"Shall we trade?\"",
			"id": "Seseorang menghadapmu. Itu dirimu — gerakannya tertunda satu detik: \"Mau bertukar?\""},
		 "again": {"fr": "Ton Écho t'attendait : « Tu reviens toujours. C'est ce que JE ferais. »",
			"en": "Your Echo was waiting: \"You always come back. It's what I would do.\"",
			"id": "Gemamu menunggumu: \"Kau selalu kembali. Itu yang akan KUlakukan.\""},
		 "choices": [
			{"tone": T_MYST,
			 "text": {"fr": "Tu acceptes l'échange — qu'il prenne ce qu'il veut.", "en": "You accept the trade — let it take what it wants.", "id": "Kau menerima pertukaran — biar ia ambil yang ia mau."},
			 "good": {"stat_delta": 2, "stat": &"instinct", "narr": {"fr": "Il prend un souvenir que tu n'aimais pas. Il laisse un réflexe que tu n'avais pas.", "en": "It takes a memory you never liked. It leaves a reflex you never had.", "id": "Ia mengambil kenangan yang tak kau suka. Ia meninggalkan refleks yang tak pernah kau punya."}},
			 "bad": {"stat_delta": -1, "stat": &"esprit", "narr": {"fr": "Tu ne sais plus lequel de vous deux est reparti. L'autre a tes papiers.", "en": "You no longer know which of you walked away. The other one has your name.", "id": "Kau tak tahu lagi siapa yang pergi. Yang satunya membawa namamu."}}},
			{"tone": T_CAUT,
			 "text": {"fr": "Tu refuses de croiser son regard et recules lentement.", "en": "You refuse to meet its gaze and back away slowly.", "id": "Kau menolak menatapnya dan mundur perlahan."},
			 "good": {"stat_delta": 1, "stat": &"vivacite", "narr": {"fr": "Il s'efface en haussant TES épaules. Tu te sens plus léger d'une hésitation.", "en": "It fades, shrugging YOUR shoulders. You feel lighter by one hesitation.", "id": "Ia memudar sambil mengangkat bahuMU. Kau merasa lebih ringan satu keraguan."}},
			 "bad": {"injury": &"terror", "narr": {"fr": "Dans son dos qui s'éloigne, tu reconnais ta propre démarche de fuite.", "en": "In its retreating back you recognize your own way of fleeing.", "id": "Di punggungnya yang menjauh, kau mengenali cara larimu sendiri."}}},
		 ]},
		{"id": &"npc_ferryman", "biome": &"swamp", "chance": 14,
		 "first": {"fr": "Une barque glisse sans bruit. Le passeur tend une main gantée : « La traversée se paie. D'une manière ou d'une autre. »",
			"en": "A skiff glides soundlessly. The ferryman extends a gloved hand: \"Passage has a price. One way or another.\"",
			"id": "Sampan meluncur tanpa suara. Si tukang perahu mengulurkan tangan bersarung: \"Penyeberangan ada harganya. Dengan satu atau lain cara.\""},
		 "again": {"fr": "Le Passeur incline son chapeau : « Encore toi. L'eau noire parle de toi, parfois. »",
			"en": "The Ferryman tips his hat: \"You again. The black water speaks of you, sometimes.\"",
			"id": "Si Tukang Perahu menyentuh topinya: \"Kau lagi. Air hitam kadang membicarakanmu.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu paies la traversée. (-6 ✦)", "en": "You pay for passage. (-6 ✦)", "id": "Kau membayar penyeberangan. (-6 ✦)"},
			 "good": {"fragments": -6, "heal": &"exhaustion", "narr": {"fr": "La barque traverse la moitié du marais pendant que tu dors enfin.", "en": "The skiff crosses half the marsh while you finally sleep.", "id": "Sampan melintasi separuh rawa sementara kau akhirnya tertidur."}},
			 "bad": {"fragments": -6, "narr": {"fr": "Il te dépose à vingt mètres. « Le tarif a changé en route. »", "en": "He drops you twenty meters on. \"The fare changed mid-crossing.\"", "id": "Ia menurunkanmu dua puluh meter saja. \"Tarifnya berubah di tengah jalan.\""}}},
			{"tone": T_DECE,
			 "text": {"fr": "Tu montes en promettant de payer sur l'autre rive.", "en": "You board, promising to pay on the far bank.", "id": "Kau naik sambil berjanji membayar di seberang."},
			 "good": {"heal": &"exhaustion", "narr": {"fr": "Sur l'autre rive, il a oublié. Ou il fait semblant. Tu ne demandes pas.", "en": "On the far bank he has forgotten. Or pretends to. You don't ask.", "id": "Di seberang, ia lupa. Atau pura-pura lupa. Kau tak bertanya."}},
			 "bad": {"injury": &"terror", "narr": {"fr": "À mi-traversée, il s'arrête et te regarde. L'eau est très noire, très calme.", "en": "Mid-crossing he stops and looks at you. The water is very black, very still.", "id": "Di tengah penyeberangan ia berhenti dan menatapmu. Airnya sangat hitam, sangat tenang."}}},
		 ]},
		{"id": &"npc_shepherd", "biome": &"highland", "chance": 14,
		 "first": {"fr": "Un berger partage son feu sans un mot. Après un long silence : « Les pierres dressées, là-haut. N'y dors jamais. »",
			"en": "A shepherd shares his fire without a word. After a long silence: \"The standing stones, up there. Never sleep among them.\"",
			"id": "Seorang gembala berbagi api unggun tanpa kata. Setelah hening panjang: \"Batu-batu tegak di atas sana. Jangan pernah tidur di antaranya.\""},
		 "again": {"fr": "Le Berger pousse une pierre du feu vers toi : « Assieds-toi. Le vent t'a annoncé. »",
			"en": "The Shepherd nudges a fire-stone toward you: \"Sit. The wind announced you.\"",
			"id": "Sang Gembala mendorong batu api ke arahmu: \"Duduklah. Angin sudah mengabarkanmu.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu partages ton repas et ses silences.", "en": "You share your food and his silences.", "id": "Kau berbagi makanan dan keheningannya."},
			 "good": {"stat_delta": 1, "stat": &"endurance", "heal": &"terror", "narr": {"fr": "Une nuit de feu, de fromage dur et de paix. Tes épaules se dénouent.", "en": "A night of fire, hard cheese and peace. Your shoulders unknot.", "id": "Semalam dengan api, keju keras, dan damai. Bahumu mengendur."}},
			 "bad": {"narr": {"fr": "Il s'endort au milieu de ta phrase. Le feu, lui, t'écoute poliment.", "en": "He falls asleep mid-sentence. The fire, at least, listens politely.", "id": "Ia tertidur di tengah kalimatmu. Setidaknya apinya menyimak dengan sopan."}}},
			{"tone": T_CURI,
			 "text": {"fr": "Tu lui demandes ce qu'il garde vraiment, ici-haut.", "en": "You ask what he truly guards, up here.", "id": "Kau bertanya apa yang sungguh ia jaga di atas sini."},
			 "good": {"stat_delta": 1, "stat": &"instinct", "narr": {"fr": "Il désigne le troupeau, puis la vallée, puis toi. Dans cet ordre. Tu comprends.", "en": "He points at the flock, then the valley, then you. In that order. You understand.", "id": "Ia menunjuk kawanan, lalu lembah, lalu dirimu. Berurutan. Kau mengerti."}},
			 "bad": {"injury": &"terror", "narr": {"fr": "« Je garde le col. Pour que rien ne DESCENDE. » Tu regardes les pierres autrement.", "en": "\"I guard the pass. So nothing comes DOWN.\" You look at the stones differently.", "id": "\"Kujaga celah gunung. Agar tak ada yang TURUN.\" Kau memandang batu-batu itu dengan cara lain."}}},
		 ]},
		{"id": &"npc_mourner", "biome": &"crypt", "chance": 14,
		 "first": {"fr": "Une silhouette voilée pleure sur une dalle sans nom. Elle s'interrompt : « Tu pleures quelqu'un, toi aussi. Ça se voit. »",
			"en": "A veiled figure weeps over a nameless slab. She pauses: \"You mourn someone too. It shows.\"",
			"id": "Sosok bercadar menangisi lempengan tanpa nama. Ia berhenti: \"Kau juga berduka. Terlihat jelas.\""},
		 "again": {"fr": "La Pleureuse t'attend près de la même dalle : « Les vivants reviennent toujours ici. Les morts aussi. »",
			"en": "The Mourner waits by the same slab: \"The living always return here. So do the dead.\"",
			"id": "Sang Pelayat menunggu di lempengan yang sama: \"Yang hidup selalu kembali ke sini. Yang mati juga.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu t'agenouilles et pleures avec elle.", "en": "You kneel and weep with her.", "id": "Kau berlutut dan menangis bersamanya."},
			 "good": {"heal": &"terror", "narr": {"fr": "Le chagrin partagé pèse moitié moins. Elle sèche tes larmes avec son voile.", "en": "Shared grief weighs half as much. She dries your tears with her veil.", "id": "Duka yang dibagi beratnya separuh. Ia mengusap air matamu dengan cadarnya."}},
			 "bad": {"injury": &"exhaustion", "narr": {"fr": "Vous pleurez jusqu'à l'aube. Toutes les larmes ont un prix.", "en": "You weep until dawn. All tears have a cost.", "id": "Kalian menangis hingga fajar. Semua air mata ada harganya."}}},
			{"tone": T_CURI,
			 "text": {"fr": "Tu lui demandes QUI repose sous cette dalle.", "en": "You ask WHO rests beneath that slab.", "id": "Kau bertanya SIAPA yang berbaring di bawah lempengan itu."},
			 "good": {"stat_delta": 1, "stat": &"esprit", "narr": {"fr": "« Personne, encore. » Elle entretient la tombe de quelqu'un qui n'est pas mort. Tu apprends la patience des cryptes.", "en": "\"No one, yet.\" She tends the grave of someone not yet dead. You learn the patience of crypts.", "id": "\"Belum ada.\" Ia merawat makam seseorang yang belum mati. Kau belajar kesabaran makam."}},
			 "bad": {"injury": &"terror", "narr": {"fr": "Elle soulève son voile pour répondre. Tu aurais préféré ne pas savoir.", "en": "She lifts her veil to answer. You would rather not have known.", "id": "Ia mengangkat cadarnya untuk menjawab. Kau lebih suka tak pernah tahu."}}},
		 ]},
		{"id": &"npc_castaway", "biome": &"coast", "chance": 14,
		 "first": {"fr": "Un naufragé trie les débris de SON navire : « Tout se récupère, ami. Même nous. »",
			"en": "A castaway sorts the debris of HIS own ship: \"Everything can be salvaged, friend. Even us.\"",
			"id": "Seorang korban karam memilah puing kapalnya SENDIRI: \"Semua bisa diselamatkan, kawan. Bahkan kita.\""},
		 "again": {"fr": "Le Naufragé te salue de loin : « Toujours pas de bateau. Toujours pas pressé. »",
			"en": "The Castaway waves from afar: \"Still no ship. Still no hurry.\"",
			"id": "Si Korban Karam melambai dari jauh: \"Masih tanpa kapal. Masih tak terburu-buru.\""},
		 "choices": [
			{"tone": T_DIPL,
			 "text": {"fr": "Tu l'aides à trier les débris.", "en": "You help him sort the wreckage.", "id": "Kau membantunya memilah puing."},
			 "good": {"fragments": 6, "narr": {"fr": "Sous la coque brisée, une cassette intacte. Il partage sans compter.", "en": "Under the broken hull, an intact strongbox. He shares without counting.", "id": "Di bawah lambung pecah, sebuah peti utuh. Ia berbagi tanpa menghitung."}},
			 "bad": {"injury": &"bleeding", "narr": {"fr": "Une planche cède, un clou te trouve. Il s'excuse au nom de son navire.", "en": "A plank gives, a nail finds you. He apologizes on his ship's behalf.", "id": "Papan patah, paku menemukanmu. Ia minta maaf atas nama kapalnya."}}},
			{"tone": T_DECE,
			 "text": {"fr": "Tu l'envoies chercher de l'eau douce et fouilles la cassette.", "en": "You send him for fresh water and rifle the strongbox.", "id": "Kau menyuruhnya mencari air tawar lalu menggeledah peti."},
			 "good": {"fragments": 9, "narr": {"fr": "La cassette s'ouvre au troisième essai. La mer ne dira rien — elle a l'habitude.", "en": "The box opens on the third try. The sea won't tell — she's used to it.", "id": "Peti terbuka di percobaan ketiga. Laut takkan bercerita — ia sudah terbiasa."}},
			 "bad": {"fragments": -5, "injury": &"bleeding", "narr": {"fr": "Le piège à mâchoires dans la cassette, c'était SA retraite. Bien défendue.", "en": "The jaw-trap in the box was HIS retirement fund. Well defended.", "id": "Perangkap rahang dalam peti itu tabungan pensiunnya. Terjaga rapat."}}},
		 ]},
	]

static func for_biome(biome: StringName) -> Dictionary:
	for n in all():
		if n.biome == biome: return n
	return {}

# Builds a SituationRegistry-shaped template in the ACTIVE language.
static func template(npc: Dictionary, returning: bool) -> Dictionary:
	var title: Dictionary = npc.again if returning else npc.first
	var choices: Array = []
	for c in npc.choices:
		var good: Dictionary = (c.good as Dictionary).duplicate()
		var bad: Dictionary = (c.bad as Dictionary).duplicate()
		good.narr = Lang.t(good.narr)
		bad.narr = Lang.t(bad.narr)
		choices.append({"tone": int(c.tone), "text": Lang.t(c.text), "good": good, "bad": bad})
	return {
		"id": npc.id,
		"title": Lang.t(title),
		"biomes": [npc.biome],
		"choices": choices,
	}
