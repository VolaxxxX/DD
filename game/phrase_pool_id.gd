class_name PhrasePoolID extends RefCounted
# Indonesian narrative pack. Same API shape as PhrasePool (FR canonical).
# Tone integers: 0=AGGRESSIVE 1=DIPLOMATIC 2=CAUTIOUS 3=CURIOUS 4=DECEPTIVE 5=MYSTICAL
# Outcome integers match FateEngine.Outcome: 0=CRIT_FAIL 1=FAIL 2=MIXED 3=SUCCESS 4=CRIT_SUCCESS

static func choices_for(tone: int) -> Array:
	match tone:
		0: return [
			"Kau mengangkat bilahmu tanpa sepatah kata dan maju.",
			"Kau menerjang, rasa takut berubah jadi amarah.",
			"Kau membidik leher — satu serangan, tepat.",
			"Kau menyerang lebih dulu, ke jantung keheningannya.",
			"Kau menggeram makian dan menerkamnya.",
			"Kau berpura ke kiri, menebas ke kanan. Hanya itu rencanamu.",
			"Kau meludahi wajahnya sebelum menghunus senjata.",
			"Kau menyerang tanpa teriak. Sekadar pekerjaan yang harus diselesaikan.",
			"Kau membayangkan akhir hidupnya, lalu mewujudkannya.",
			"Kau ambil risiko satu tebasan lebar. Jika meleset, kau mati.",
			"Kau melemparkan apa pun yang ada di tanganmu — demi memangkas jarak.",
			"Kau membuka pertempuran dengan pukulan curang. Bukan saatnya bersikap mulia.",
			"Kau merangsek, merunduk rapat, seperti hendak mencekik.",
			"Kau berteriak, berharap ia gentar. Kau tak memberinya waktu menjawab.",
		]
		1: return [
			"Kau membuka kedua telapak tanganmu dan bicara pelan.",
			"Kau membisikkan kata kuno, berharap ia mengenalinya.",
			"Kau berlutut perlahan, kepala tertunduk.",
			"Kau menawarkan pertukaran — suaramu gemetar tapi bertahan.",
			"Kau menyebut leluhurnya, atau apa yang kau bayangkan tentang mereka.",
			"Kau menyebutkan namamu. Hanya itu yang bisa kau berikan.",
			"Kau menyenandungkan nina bobo. Kau bahkan tak tahu dari mana asalnya.",
			"Kau bertanya apa yang dicarinya. Kau sungguh mendengarkan.",
			"Kau bicara soal jalan, soal cuaca, soal apa saja kecuali dirinya.",
			"Kau mengajukan satu pertanyaan sederhana: mengapa tinggal di sini?",
			"Kau bersumpah tak membawa senjata. Kau nyaris tak berbohong.",
			"Kau bicara padanya seperti pada anak yang ketakutan.",
			"Kau membisikkan sebuah rahasia. Kau sudah menyesalinya.",
			"Kau berkata ia boleh pergi. Kau juga.",
		]
		2: return [
			"Kau mundur selangkah, terukur, tanpa melepas tatapannya.",
			"Kau memutar perlahan, menjaga jarak.",
			"Kau melebur ke bayangan sebatang akar dan menahan napas.",
			"Kau melempar batu jauh-jauh, berharap mengalihkannya.",
			"Kau menunggu sampai ia bosan, diam seperti kematian.",
			"Kau berjalan berjingkat, seperti dalam mimpi.",
			"Kau merebahkan diri di rumput tinggi. Kau menjadi tanah.",
			"Kau berbalik tanpa suara, menyusuri jejakmu sendiri.",
			"Kau menyelinap ke balik batang pohon, menghitung sampai sepuluh.",
			"Kau melepas sepatu botmu dan berjalan telanjang kaki, perlahan.",
			"Kau mengikuti arah angin — ia akan menutupi baumu.",
			"Kau merunduk ke dalam parit. Malam akan berlalu, mungkin.",
			"Kau berpura-pura mati sebelum gagasan itu terlintas di kepalanya.",
		]
		3: return [
			"Kau mendekat untuk mengamati tanda di tubuhnya.",
			"Kau memungut pecahan yang jatuh di kakinya dan memeriksanya.",
			"Kau memasang telinga — bunyi asing keluar dari kerongkongannya.",
			"Kau mencari dengan matamu apa yang sedang ia lindungi.",
			"Kau bertanya keras-keras, sekadar mencoba.",
			"Kau memperhatikan bayangannya. Geraknya tak seperti bayanganmu.",
			"Kau menghitung napasnya. Ada yang janggal.",
			"Kau melihat bekas luka lama. Kau mengenali sebuah pola di sana.",
			"Kau menatap tangannya lekat-lekat. Tangan itu bercerita lain.",
			"Kau mengikuti arah pandangnya. Apa pun yang sedang ia tatap.",
			"Kau menyimak keheningan di sekitarnya. Terlalu bersih.",
			"Kau menangkap satu detail yang takkan dilihat siapa pun. Kau menyimpannya.",
			"Kau bertanya-tanya, dulu ia ini apa.",
		]
		4: return [
			"Kau menunjukkan satu tangan kosong, tangan lain di belatimu.",
			"Kau bersumpah hanya pengelana tersesat. Kau sudah menghitung giginya.",
			"Kau pura-pura terluka — satu rintihan di saat yang pas.",
			"Kau bicara soal jalan, soal dingin — sementara jemarimu meraba-raba.",
			"Kau menawarkan kesepakatan yang tak akan pernah kau tepati.",
			"Kau bilang kau kenal seseorang. Bohong.",
			"Kau memainkan rasa takut, sempurna. Kau gemetar dengan cara yang tepat.",
			"Kau menunjuk sesuatu di belakang punggungnya. Lalu kau bertindak.",
			"Kau bilang ada yang lain di belakangmu. Tak ada siapa-siapa.",
			"Kau menjanjikan utang budi. Kau takkan pernah membayarnya.",
			"Kau bersumpah demi sesuatu yang keramat — yang kau karang kemarin.",
			"Kau memberi nama palsu. Kau cukup memercayainya agar ia juga percaya.",
			"Kau berlagak mengenalnya. Bahkan kau bersikeras.",
		]
		5: return [
			"Kau menggores tanda kuno di debu tanpa melihat.",
			"Kau mengucapkan kata yang bukan milik bahasa manusia mana pun.",
			"Kau memejamkan mata dan membiarkan sesuatu yang lain melihat untukmu.",
			"Kau menempelkan tangan ke tanah dan mendengar jawaban bumi.",
			"Kau mempersembahkan setetes darahmu pada angin. Satu saja.",
			"Kau melafalkan nama yang tak kau ingat pernah kau ketahui.",
			"Kau membalik napasmu: menghirup saat membuang, membuang saat menghirup.",
			"Kau menggambar lingkaran tak kasatmata di sekelilingmu dan mengundangnya masuk.",
			"Kau menukar satu kenanganmu dengan satu kebenaran.",
			"Kau memotong sejumput rambutmu dan menguburnya.",
			"Kau merapal terbalik doa yang tak pernah kau pelajari.",
			"Kau menyentuh tanah di tiga titik yang tepat. Kau tak pernah tahu dari mana kau tahu.",
			"Kau mempersembahkan keheninganmu pada yang sedang mendengarkan. Itulah yang paling berharga.",
		]
	return ["Kau melangkah ke samping."]

static func outcomes_for(tone: int, outcome: int) -> Array:
	if tone == 0:
		match outcome:
			4: return [
				"Bilahmu menemukan celah. %s rubuh tanpa suara. Sesuatu dalam dirimu menyetujuinya.",
				"Satu pukulan sempurna. %s jatuh sebelum mengerti.",
				"Kau menyerang sekali. Cukup. %s berdiri sejenak, lalu rubuh perlahan.",
				"%s bahkan tak sempat menatapmu. Kau sudah memisahkan tulang-tulangnya.",
				"Tarian singkat dan tepat. Saat berhenti, %s sudah tergeletak.",
			]
			3: return [
				"%s tumbang di pertukaran ketiga. Kau bernapas.",
				"Pertarungan singkat. %s menyerah. Kau berdarah sedikit.",
				"Kau melakukan yang harus dilakukan. %s takkan bangkit lagi. Kau pun tak sepenuhnya.",
				"Kau melepaskan serangan penentu di saat yang tepat. %s mundur, terhuyung, tak kembali.",
				"Kau menang, dengan keringat dan keberuntungan. %s tetap di tanah.",
			]
			2: return [
				"%s mundur pincang, tapi kau tak utuh.",
				"Kalian berpisah dalam diam. Masing-masing kehilangan sesuatu.",
				"Kau memukulnya mundur. Ia kabur. Kau berdarah sambil menatap jalan.",
				"Pertarungan berubah kacau. Kalian berhenti tanpa ada yang tuntas.",
				"Kau unggul cukup lama hingga ia memutuskan pergi.",
			]
			1: return [
				"Seranganmu meleset. %s membalas dan kau merasakan daging terbuka.",
				"%s mengelak — ayunanmu mengkhianatimu. Kau membayarnya.",
				"Kau menyerang terlalu cepat. %s menghukummu. Kau belajar.",
				"Bilahmu menemukan tulang — tulangmu sendiri. %s bahkan tak berdarah.",
				"Kau meleset dari sasaranmu. %s tidak.",
			]
			0: return [
				"%s mencabikmu bahkan sebelum kakimu mendarat. Kau terhuyung.",
				"Kau sudah tersungkur. %s menatapmu tanpa terburu-buru.",
				"Yang kau kira binatang ternyata perangkap. Dan ia menutup.",
				"%s mematahkan sesuatu dalam dirimu yang tak cepat pulih.",
				"Kau mengerti, terlambat, bahwa seharusnya kau tak pernah mencoba.",
			]
	elif tone == 1:
		match outcome:
			4: return [
				"%s membungkuk. Ikatan sunyi terjalin di antara kalian. Ia berlalu.",
				"Kata-katamu menyentuh tempat yang tua. %s menundukkan kepala dan membiarkanmu lewat.",
				"Sesuatu dalam diri %s mengenali sesuatu dalam dirimu. Kalian berpisah sebagai saudara.",
				"%s menjawabmu, panjang. Kau belajar lebih banyak dari yang kau harapkan.",
				"%s meninggalkan sebuah tanda untukmu — kecil, berharga. Kau takkan lupa.",
			]
			3: return [
				"%s mendengarkan. Bahunya turun. Ia pergi tanpa sesal.",
				"Kalian menemukan kesepakatan. Tak ada yang berdarah hari ini.",
				"%s merelakan jalan untukmu. Bukan kepercayaan. Tapi jalan.",
				"%s menggerutu sesuatu dan melewatimu. Hanya itu yang kau butuhkan.",
				"Suara kalian bersentuhan sekejap. Lalu masing-masing kembali pada suaranya sendiri.",
			]
			2: return [
				"%s ragu, lalu membuang muka. Hanya itu yang kau dapat.",
				"Ia memberimu jalan yang sempit, tapi matanya tetap curiga.",
				"%s tak menjawabmu, tapi juga tak menyerangmu. Kau terima itu.",
				"Kau mendapat gencatan. Bukan damai — tapi lebih baik dari perang.",
				"%s menunjukkan jalan lain. Kau mengambilnya tanpa bertanya.",
			]
			1: return [
				"%s tak mengerti. Atau tak mau. Sikap tubuhnya berubah.",
				"Kata-katamu meluncur begitu saja darinya. Ia maju, tanpa tergesa.",
				"%s tertawa. Sama sekali bukan seperti yang kau harapkan.",
				"Kau bicara terlalu banyak, atau terlalu sedikit. %s kehilangan kesabaran.",
				"Kata-katamu terdengar palsu bahkan bagimu. Bagi %s juga.",
			]
			0: return [
				"%s menganggap telapak terbukamu kelemahan. Ia menyerang.",
				"Kau bicara. Seharusnya tidak. %s bereaksi seperti binatang.",
				"%s menjawab dengan kata yang tak kau pahami. Lalu dengan sesuatu yang lain.",
				"Sesuatu yang kau ucapkan membangunkan amarah lama.",
				"%s membungkammu dengan gerakan yang tak menyerupai gerakan manusia.",
			]
	elif tone == 2:
		match outcome:
			4: return [
				"%s tak pernah melihatmu. Kau sudah jauh.",
				"Kau lenyap seperti bayangan. %s masih mencari ketika angin berbalik.",
				"Kau lewat di belakangnya selagi ia menoleh ke arah lain. Sempurna.",
				"%s lewat semeter darimu tanpa melihat. Kau menahan senyum.",
				"Kau bergerak seperti udara. %s takkan pernah tahu kau di sini.",
			]
			3: return [
				"Kau menjauh. %s kehilangan jejakmu.",
				"Kau menaruh cukup jarak. Napas kembali, perlahan.",
				"Kau menemukan cekungan di tanah. Kau nyaris tertidur di sana.",
				"%s menyerah setelah beberapa langkah. Kau pergi tanpa menoleh.",
				"Kau melakukannya dengan benar — pelan, tepat. Kau keluar dari sini utuh.",
			]
			2: return [
				"Kau lolos, tapi kini ia tahu kau pernah di sini.",
				"Kalian tak saling berhadapan. Untuk kali ini.",
				"Kau bersembunyi cukup baik untuk selamat, tak cukup untuk menghilang.",
				"%s melihatmu dari sudut matanya, dan membiarkanmu pergi.",
				"Kau lari. Sesuatu dalam diri %s memutuskan itu sudah cukup.",
			]
			1: return [
				"%s mengangkat kepala — kau terlihat. Kau lari.",
				"Kakimu mematahkan ranting. %s menoleh ke arahmu.",
				"Kau mengira dirimu tersembunyi. %s mengikutimu sejak awal.",
				"%s sudah mencium baumu bahkan sebelum kau bergerak.",
				"Kau ragu terlalu lama. %s memangkas jarak dengan satu lompatan.",
			]
			0: return [
				"%s ada di belakangmu sejak tadi.",
				"Kau mundur ke dalam perangkap lain. Tanah runtuh.",
				"Kau lari ke arah yang salah. Ada arah lain.",
				"%s tak mengikutimu. Ia menunggu di tempat tujuanmu.",
				"Kau bersembunyi di tempat ia berburu. Hari yang buruk.",
			]
	elif tone == 3:
		match outcome:
			4: return [
				"Kau menemukan serpihan yang mengubah segalanya. Sebuah ingatan terbuka.",
				"Kau memahami sesuatu yang tak pernah dilihat siapa pun pada %s.",
				"Detail yang kau amati menyingkap jauh lebih banyak dari dugaanmu.",
				"Kau mengenali polanya. Itu kuno, dan itu berguna.",
				"%s membiarkanmu melihat, tanpa bergerak. Kau belajar dalam diam.",
			]
			3: return [
				"Satu detail mengajarimu sesuatu yang berguna tentang tempat ini.",
				"%s membiarkanmu mengamati. Kau belajar.",
				"Apa yang kau lihat takkan terlupakan. Kau tahu sesuatu yang baru.",
				"Kau merangkai tiga serpihan menjadi satu pikiran. Kau pergi lebih kaya.",
				"%s menatapmu mengamatinya. Tak satu pun bergerak. Itu sudah cukup.",
			]
			2: return [
				"Kau belajar sedikit. Kau kehilangan sedikit.",
				"Pecahan di tanganmu berdengung. Kau belum tahu kenapa.",
				"Kau membawa sesuatu, tapi kau meninggalkan sesuatu yang lain.",
				"%s melihatmu mengamati. Itu berarti sesuatu, sekarang.",
				"Sekarang kau tahu. Kau tak lagi yakin ingin tahu.",
			]
			1: return [
				"Kau berlama-lama. %s merasakan rasa ingin tahumu dan membencinya.",
				"Yang kau sentuh menyentuhmu balik. Panas.",
				"%s sadar kau mengorek-ngorek. Ia tak menyukainya.",
				"Kau mengamati sesuatu yang seharusnya tak kau amati. Terlalu lama.",
				"Kau membuka pintu yang bukan pintu. Kau merasakan dingin.",
			]
			0: return [
				"Kau menatap terlalu dalam. Sesuatu menatap balik.",
				"Serpihan itu menyayat telapakmu. %s bangkit. Kau membangunkan sesuatu yang lain.",
				"Kau mengetahui yang seharusnya tak kau ketahui. Pengetahuan itu menagih harganya.",
				"%s mengerti apa yang kau pahami. Ia lebih suka kau mati membawanya.",
				"Yang kau tatap kini menatapmu. Dan ia mendekat.",
			]
	elif tone == 4:
		match outcome:
			4: return [
				"%s memercayaimu. Kau pergi membawa miliknya. Ia baru tahu saat pagi tiba.",
				"Kebohonganmu begitu sempurna sampai kau sendiri hampir percaya. %s membungkuk.",
				"Kau memainkan peran dengan sempurna. %s bahkan berterima kasih.",
				"%s pergi dengan yakin telah berbuat baik. Kau nyaris tersenyum.",
				"Kau mendapatkan semuanya. %s tak melihat apa pun datang.",
			]
			3: return [
				"%s ragu, tapi menurunkan kewaspadaan. Cukup.",
				"Kau mendapat yang kau mau. %s pergi membawa separuh keping.",
				"%s membiarkanmu lewat. Nanti baru ia berpikir itu aneh.",
				"Kau mendapat keuntungan. Tak semuanya. Tapi yang terpenting.",
				"%s tak tahu baru saja tertipu. Itulah intinya.",
			]
			2: return [
				"%s menebak sebagian tipuanmu. Kau menang sebagian, kalah sebagian.",
				"Senyummu bertahan. Pas cukup. Kau lolos.",
				"Kau mendapat yang kau mau, tapi %s akan mengingatnya.",
				"Kalian berbagi kebohongan. Tak ada yang tertipu. Tak ada yang mengakuinya.",
				"%s menerima kesepakatan itu. Suatu hari ia akan membaliknya padamu.",
			]
			1: return [
				"%s membaca kebohonganmu bahkan sebelum kau selesai. Wajahnya berubah.",
				"Belatimu gemetar di saat yang salah. %s melihatnya.",
				"Satu detail kecil mengkhianatimu. %s tak pernah melewatkan detail.",
				"%s menatapmu lekat. Kau merasa sudah kalah.",
				"Logatmu mengkhianatimu, atau tanganmu, atau tatapanmu. Ia melihatnya.",
			]
			0: return [
				"%s bermain lebih baik darimu. Saat kau sadar, semua terlambat.",
				"Jebakan itu untukmu sejak awal. %s tersenyum.",
				"Kau mengira sedang menipu. %s justru mengandalkannya.",
				"Bukan kau pembohong dalam kisah ini. Tapi %s.",
				"Kau menemukan pengkhianatan tepat saat ia merenggut segalanya darimu.",
			]
	elif tone == 5:
		match outcome:
			4: return [
				"Sesuatu menjawab. %s menyingkir, seperti di depan pintu.",
				"Tandanya bertahan. Dunia terbuka sekejap — lalu menutup di atas rahasiamu.",
				"Sesuatu yang mahabesar mengenalimu. %s mundur, lebih kecil dari sebelumnya.",
				"Kau menerima sebuah nama yang tak akan berani kau ulangi. Tapi kau mengetahuinya.",
				"Ritus itu berhasil. Dunia bergetar sedetik. Hanya kau yang merasakannya.",
			]
			3: return [
				"Getaran melintasi udara. %s mundur, ragu.",
				"Kau mendengar suara yang bukan suaramu. Ia memberimu arah.",
				"Sesuatu mendengarkan. Dan menjawab, dengan caranya.",
				"Gerakan itu bekerja, kecil, bersih. Sesuatu berubah.",
				"Kau merasakan benang terentang antara dirimu dan sesuatu yang lain. Itulah yang kau mau.",
			]
			2: return [
				"Ritus itu setengah berhasil. Kau mendapat serpihan. Kau membayar serpihan.",
				"Sesuatu mendengarkan, tapi tak menjawab. Belum.",
				"Kau mendapat jawaban. Kau tak yakin telah mengajukan pertanyaan yang benar.",
				"Tandanya goyah. Kau tetap mempelajari sesuatu.",
				"Kau menyentuh sisi bawah dunia, sekejap. Ia menyentuhmu balik.",
			]
			1: return [
				"Kata-kata itu melawanmu. %s merasakan kelemahanmu dan mendekat.",
				"Angin menolak persembahanmu. Telapakmu berdarah sia-sia.",
				"Kau merasa tak punya hak. Gerakan itu berbalik melawanmu.",
				"Sesuatu terkekeh dalam diam. Telingamu tak diciptakan untuk itu.",
				"Kau salah mengucap satu kata. %s mendengar kesalahan itu sebelum kau.",
			]
			0: return [
				"Kau mengucapkan yang seharusnya tak diucapkan. Sesuatu yang tua kini mengawasimu.",
				"Tanda itu berbalik melawanmu. %s tak perlu lagi bergerak.",
				"Sesuatu melintas menembus tubuhmu. Kau tahu kau tak lagi sendirian, selamanya.",
				"Kau membuka yang seharusnya tetap tertutup. Harganya akan ditagih nanti.",
				"Ritus itu berhasil, tapi bukan untukmu. %s memungut apa yang kau panggil.",
			]
	return ["Tidak terjadi apa-apa."]

# ---------- Contextual choice variants ----------
# Family order matches Archetype.Family:
# 0 HUMANOID, 1 BEAST, 2 UNDEAD, 3 CONSTRUCT, 4 ELEMENTAL, 5 ABERRATION, 6 FEY, 7 DRACONIC

static func family_choices(tone: int, family: int) -> Array:
	var pools := {}
	match tone:
		0: pools = {
			0: ["Kau membidik lutut — orang yang tersungkur tak mengejar siapa pun.",
				"Kau menebas tempat zirahnya menganga, di bawah lengan."],
			1: ["Kau membidik moncongnya — rasa sakit akan membuatnya mundur.",
				"Kau menunggu ia melompat untuk menebas dari bawah."],
			2: ["Kau membidik kakinya — biar ia merangkak, seperti seharusnya ia tetap berbaring.",
				"Kau menebas tulang. Tak ada lagi yang tersisa untuk dipotong."],
			3: ["Kau mencari sambungannya — setiap mesin punya cacat.",
				"Kau menebas cahaya di dadanya. Pasti itu jantungnya."],
			4: ["Kau menebas pusat pusaran, tempat semuanya bertaut.",
				"Kau menyerang tanpa bertanya apakah bilahmu bisa memotong sesuatu di sini."],
			5: ["Kau menebas tanpa melihat — memandangnya utuh terlalu mahal harganya.",
				"Kau membidik matanya. Yang di tengah. Yang menatapmu."],
			6: ["Kau menyerang sebelum ia menyelesaikan kalimatnya. Besi lebih dulu.",
				"Kau melanggar semua adat: menyerang peri. Biarlah."],
			7: ["Kau menyelinap di bawah pertahanannya, menuju sisik yang hilang.",
				"Kau menerjang lurus ke arah moncongnya. Setidaknya kau melihatnya dari depan."],
		}
		1: pools = {
			0: ["Kau mengingatkannya bahwa kalian dulu satu kaum, sebelum semua ini.",
				"Kau mengulurkan ransummu. Orang yang makan akan mendengarkan."],
			1: ["Kau menunduk dan memperlihatkan lehermu. Bahasa kawanan.",
				"Kau meletakkan daging di antara kalian, lalu mundur selangkah."],
			2: ["Kau mengucapkan kata-kata yang menjadi hak orang mati. Mungkin ia menunggunya.",
				"Kau bertanya siapa yang ia tunggu. Orang mati selalu menunggu seseorang."],
			3: ["Kau menyebutkan nama dan niatmu, jelas, seperti sebuah protokol.",
				"Kau menunjukkan tangan kosongmu pada sang penjaga, telapak menghadap langit."],
			4: ["Kau bicara pada elemen seperti bicara pada cuaca: tanpa menuntut apa pun.",
				"Kau menyapa apa yang menggerakkannya, bukan apa yang diperlihatkannya."],
			5: ["Kau memikirkan kalimatmu alih-alih mengucapkannya. Mungkin di sanalah ia mendengar.",
				"Kau memberi hormat pada wujud lamanya, sebelum ia menjadi ini."],
			6: ["Kau menimbang setiap kata — pakta dengan peri ditagih kata demi kata.",
				"Kau menawarkan satu kebenaran tentang dirimu. Peri hidup dari itu."],
			7: ["Kau menyapanya dengan gelar-gelarnya. Naga mengoleksi nama-nama mereka.",
				"Kau menawarkan satu-satunya benda berkilau yang kau miliki."],
		}
		2: pools = {
			0: ["Kau mengangkat tangan dan mundur — selangkah, lalu dua, tanpa memunggunginya."],
			1: ["Kau menghindari tatapannya dan mundur melawan angin, sangat perlahan."],
			2: ["Kau menyusuri tepi wilayahnya — orang mati jarang menjaga lebih jauh."],
			3: ["Kau diam tak bergerak. Banyak penjaga hanya melihat gerakan."],
			4: ["Kau mencari titik tempat udara tenang, dan berdiri di sana."],
			5: ["Kau menatap tanah. Yang penting, jangan memandangnya langsung."],
			6: ["Kau membalik jaketmu, seperti dalam dongeng-dongeng lama."],
			7: ["Kau menyusutkan diri di sela bebatuan. Tak ada yang bisa lari dari naga."],
		}
		3: pools = {
			0: ["Kau memeriksa perlengkapannya — dari mana asalnya, siapa yang membayarnya?"],
			1: ["Kau membaca tubuhnya: bekas luka berburu, atau bekas melarikan diri?"],
			2: ["Kau mencari di tubuhnya apa yang membunuhnya, kali pertama."],
			3: ["Kau mencari tanda sang pembuat di balik karat."],
			4: ["Kau mengamati apa yang menghidupinya. Setiap api punya sumber."],
			5: ["Kau menghitung anggota tubuhnya. Hasilnya berubah setiap kali."],
			6: ["Kau memperhatikan bayangannya — peri tak selalu membawa bayangan yang benar."],
			7: ["Kau membaca sisiknya seperti catatan sejarah. Setiap bekas bakar adalah tanggal."],
		}
		4: pools = {
			0: ["Kau menyebut nama seorang kapten karangan yang katanya melindungimu."],
			1: ["Kau menirukan lolongan kawanannya yang terluka, agak jauh di sebelah kiri."],
			2: ["Kau berjalan seperti orang mati berjalan. Kau menjadi salah satu dari mereka."],
			3: ["Kau mengulangi gerakan yang terukir di alasnya — mungkin segel untuk lewat."],
			4: ["Kau melempar kantong airmu jauh-jauh: biar air menyibukkannya di tempat lain."],
			5: ["Kau memikirkan hal lain kuat-kuat. Biar ia membaca hal lain itu."],
			6: ["Kau menawarkan taruhan curang — permainan peri melawan peri."],
			7: ["Kau menyanjungnya — keangkuhannya lebih berat daripada dirimu."],
		}
		5: pools = {
			0: ["Kau menggambar tanda pengelana di udara di antara kalian berdua."],
			1: ["Kau meniup telapakmu dan mempersembahkan baumu pada dunia."],
			2: ["Kau mengarang ritus peristirahatan. Canggung, tapi penuh hormat."],
			3: ["Kau menempelkan tangan ke permukaannya dan mencari gema sang pembuat."],
			4: ["Kau menyebut elemen itu dengan nama tuanya. Para elemen mengingatnya."],
			5: ["Kau membuka pikiranmu, secelah saja, untuk melihat apa yang masuk."],
			6: ["Kau menggambar lingkaran garam — semua yang tersisa padamu."],
			7: ["Kau bersumpah demi api. Satu-satunya bahasa yang mereka semua hormati."],
		}
	return pools.get(family, [])

static func biome_choices(tone: int, biome: StringName) -> Array:
	var pools := {}
	match tone:
		2: pools = {
			&"forest":    ["Kau memanjat dahan-dahan rendah dan membiarkan hutan menyembunyikanmu."],
			&"city":      ["Kau melebur ke ceruk sebuah pintu mati."],
			&"ruins":     ["Kau menyelinap ke balik dinding yang runtuh."],
			&"corrupted": ["Kau mengikuti urat tanah yang sehat, tempat bumi tak berdenyut."],
			&"anomaly":   ["Kau berjalan di tempat cahaya jatuh lurus. Itu langka, di sini."],
			&"swamp":     ["Kau membenamkan diri ke air sampai leher, di antara gelagah."],
			&"highland":  ["Kau merapat ke batu karang, terlindung dari angin."],
			&"crypt":     ["Kau meniup mati lenteramu dan menghitung langkah dalam gelap."],
			&"coast":     ["Kau menyusuri garis pasang, tempat pasir menghapus jejakmu."],
		}
		3: pools = {
			&"forest":    ["Kau membaca bekas cakaran di batang-batang pohon. Sebuah peta terbentuk."],
			&"city":      ["Kau mengeja sisa-sisa papan nama. Seseorang pernah hidup di sini."],
			&"ruins":     ["Kau membandingkan ukiran di alas batu dengan yang berdiri di hadapanmu."],
			&"corrupted": ["Kau mengamati bagaimana kebusukan tanah ini telah mengubahnya."],
			&"anomaly":   ["Kau melempar kerikil dan mengikuti lintasannya. Lintasan itu keliru."],
			&"swamp":     ["Kau mengikuti gelembung yang naik. Sesuatu bernapas di bawah sana."],
			&"highland":  ["Kau mengamati batu-batu tegak di puncak. Sebuah barisan."],
			&"crypt":     ["Kau membaca nama-nama di lempengan batu. Namanya mungkin ada di sana."],
			&"coast":     ["Kau memeriksa apa yang ditinggalkan laut semalam."],
		}
		5: pools = {
			&"forest":    ["Kau menekankan telapakmu pada pohon tertua dan menunggu."],
			&"city":      ["Kau memanggil nama-nama penghuni lama, sekenanya."],
			&"ruins":     ["Kau membangunkan gema bebatuan dengan satu kata yang diketuk dua kali."],
			&"corrupted": ["Kau mencicipi kebusukan itu dengan ujung jari. Demi memahami."],
			&"anomaly":   ["Kau berdoa dengan arah terbalik. Di sini, itu mungkin berhasil."],
			&"swamp":     ["Kau menitipkan satu harapan pada air hitam dan menyaksikannya diambil."],
			&"highland":  ["Kau meneriakkan namamu pada angin dan menyimak apa yang ia bawa pulang."],
			&"crypt":     ["Kau menyalakan lilin untuk orang mati — dan satu untukmu."],
			&"coast":     ["Kau menulis sepatah kata di pasir dan membiarkan ombak mengambilnya."],
		}
	return pools.get(biome, [])

static func tier_choices(tone: int) -> Array:
	# Extra lines that only appear against ELITE+ creatures — the player should
	# feel the danger in the phrasing itself.
	match tone:
		0: return [
			"Kau tahu kau tak bisa menang. Kau tetap menyerang.",
			"Satu celah. Satu kesempatan. Kau mengambilnya."]
		2: return [
			"Di hadapan makhluk seperti ini, lari bukanlah aib.",
			"Kau berdoa semoga ia sudah kenyang, dan kau mundur."]
		3: return [
			"Kau mengukir setiap detail dalam ingatan. Jika kau selamat, itu akan berharga mahal."]
		5: return [
			"Kau memanggil semua yang kau tahu sekaligus. Sekarang atau tidak sama sekali."]
	return []

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
