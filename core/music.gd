extends Node
# Music player: real CC0 tracks (OpenGameArt) per biome/boss/menu, with the
# procedural synth kept as a fallback for any missing file.
# Autoloaded as "Music".

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _cache: Dictionary = {}        # key -> AudioStream
var _current_key: StringName = &""
var _base_volume_db: float = 0.0   # bus-level fader handles overall balance

# Real music files (all CC0 from opengameart.org).
const _BIOME_FILES := {
	&"forest":    "res://assets/music/forest.ogg",
	&"city":      "res://assets/music/city.ogg",
	&"ruins":     "res://assets/music/ruins.mp3",
	&"corrupted": "res://assets/music/corrupted.ogg",
	&"anomaly":   "res://assets/music/anomaly.ogg",
	&"swamp":     "res://assets/music/swamp.ogg",
	&"highland":  "res://assets/music/highland.mp3",
	&"crypt":     "res://assets/music/crypt.ogg",
	&"coast":     "res://assets/music/coast.mp3",
}
const _MENU_FILE := "res://assets/music/menu.wav"
const _BOSS_FILE := "res://assets/music/boss.mp3"

# Procedural fallback parameters (used only when a file fails to load).
const _BIOME_TRACKS := {
	&"forest":    [110.0,  [0, 7, 12, 19], [0, 7, 5, 12, 7, 0]],
	&"city":      [98.0,   [0, 3, 7, 10],  [0, 3, 7, 3, 10, 7]],
	&"ruins":     [87.31,  [0, 7, 12, 16], [0, 12, 7, 16, 12, 7]],
	&"corrupted": [73.42,  [0, 6, 11, 13], [0, 6, 11, 6, 13, 11]],
	&"anomaly":   [82.41,  [0, 5, 10, 15], [0, 10, 5, 15, 10, 5]],
	&"swamp":     [65.41,  [0, 7, 12, 18], [0, 12, 7, 18, 12, 0]],
	&"highland":  [130.81, [0, 4, 7, 12],  [0, 7, 12, 7, 4, 12]],
	&"crypt":     [55.0,   [0, 3, 8, 11],  [0, 8, 3, 11, 8, 3]],
	&"coast":     [98.0,   [0, 4, 9, 11],  [0, 9, 4, 11, 9, 4]],
}

func _ready() -> void:
	_player_a = _make_player()
	_player_b = _make_player()
	_active = _player_a

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.volume_db = _base_volume_db
	p.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(p)
	return p

func play_biome(biome: StringName) -> void:
	var key := StringName("biome_" + String(biome))
	var stream := _stream_for(key, _BIOME_FILES.get(biome, ""), biome)
	_crossfade(key, stream)

func play_boss(boss_id: StringName) -> void:
	var key := StringName("boss_" + String(boss_id))
	var stream := _stream_for(key, _BOSS_FILE, &"")
	_crossfade(key, stream, -2.0)

func play_menu() -> void:
	var stream := _stream_for(&"menu", _MENU_FILE, &"")
	_crossfade(&"menu", stream)

# Subtle per-encounter freshness on real tracks: a barely-perceptible pitch
# drift (max ±2%) so successive fights don't feel like a frozen loop.
func nudge_for_encounter(encounter_idx: int) -> void:
	var steps := [0.0, 0.01, -0.01, 0.02, -0.02]
	var target_pitch: float = 1.0 + steps[encounter_idx % steps.size()]
	if _active != null and is_instance_valid(_active):
		var t := _active.create_tween()
		t.tween_property(_active, "pitch_scale", target_pitch, 2.0).set_trans(Tween.TRANS_SINE)

func stop() -> void:
	_player_a.stop()
	_player_b.stop()
	_current_key = &""

# Load a real file, enable its loop flag, fall back to the synth on failure.
func _stream_for(key: StringName, path: String, fallback_biome: StringName) -> AudioStream:
	if _cache.has(key): return _cache[key]
	var stream: AudioStream = null
	if path != "" and ResourceLoader.exists(path):
		stream = load(path)
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		elif stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true
		elif stream is AudioStreamWAV:
			var w: AudioStreamWAV = stream
			w.loop_mode = AudioStreamWAV.LOOP_FORWARD
			w.loop_begin = 0
			w.loop_end = w.data.size() / 4 if w.stereo else w.data.size() / 2
	if stream == null:
		var params: Array = _BIOME_TRACKS.get(fallback_biome, _BIOME_TRACKS[&"forest"])
		stream = _build_track(params[0], params[1], params[2])
	_cache[key] = stream
	return stream

func _crossfade(key: StringName, stream: AudioStream, extra_db: float = 0.0) -> void:
	if key == _current_key: return
	_current_key = key
	var next_player := _player_b if _active == _player_a else _player_a
	# Capture the OUTGOING player in a local — the fade-out callback fires 2s
	# later, by which time the member `_active` already points to the NEW
	# player. Referencing `_active` in the callback would stop the track that
	# just started (the long-standing "music cuts after a couple seconds" bug).
	var old_player := _active
	next_player.stream = stream
	next_player.pitch_scale = 1.0
	next_player.volume_db = -50.0
	next_player.play()
	var fade_in := next_player.create_tween()
	fade_in.tween_property(next_player, "volume_db", _base_volume_db + extra_db, 2.0)
	if old_player != null and old_player.playing:
		var fade_out := old_player.create_tween()
		fade_out.tween_property(old_player, "volume_db", -50.0, 2.0)
		fade_out.tween_callback(func():
			if is_instance_valid(old_player): old_player.stop())
	_active = next_player

# ---------- Procedural fallback synthesis ----------

func _build_track(base_freq: float, intervals: Array, melody: Array) -> AudioStreamWAV:
	# 16-second loopable piece: layered sine drones + slow soft melody.
	var sample_rate := 22050
	var dur := 16.0
	var n := int(dur * sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var freqs: Array = []
	for st in intervals:
		freqs.append(base_freq * pow(2.0, float(st) / 12.0))
	var mel_freqs: Array = []
	for st in melody:
		mel_freqs.append(base_freq * 2.0 * pow(2.0, float(st) / 12.0))
	var mel_note_dur: float = dur / maxi(1, mel_freqs.size())
	for i in n:
		var t := float(i) / float(sample_rate)
		var v := 0.0
		for j in freqs.size():
			var f: float = freqs[j]
			var detune: float = 1.0 + (float(j) - 1.0) * 0.0007
			var amp: float = 0.55 / float(freqs.size())
			amp *= 0.85 + 0.15 * sin(TAU * 0.10 * t + j * 0.7)
			v += sin(TAU * f * detune * t) * amp
		if mel_freqs.size() > 0:
			var mi: int = int(t / mel_note_dur) % mel_freqs.size()
			var mf: float = mel_freqs[mi]
			var note_t: float = fposmod(t, mel_note_dur)
			var note_env: float = 1.0
			if note_t < 0.4: note_env = note_t / 0.4
			elif note_t > mel_note_dur - 0.4: note_env = (mel_note_dur - note_t) / 0.4
			note_env = clamp(note_env, 0.0, 1.0)
			var vib: float = sin(TAU * 4.5 * t) * 0.004
			v += sin(TAU * mf * (1.0 + vib) * t) * 0.18 * note_env
		v += sin(TAU * (base_freq * 0.5) * t) * 0.08 * (0.7 + 0.3 * sin(TAU * 0.06 * t))
		var env := 1.0
		if t < 0.6: env = t / 0.6
		elif t > dur - 0.6: env = (dur - t) / 0.6
		v *= env * 0.55
		var s16 := int(clamp(v, -1.0, 1.0) * 32767.0)
		pcm.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = n
	stream.data = pcm
	return stream
