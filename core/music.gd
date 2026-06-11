extends Node
# Procedural ambient music: layered drones that morph by biome/world boss.
# Autoloaded as "Music".  Tracks are tiny WAV streams generated on first play.
# Per-context: a base note + a 3rd + a 5th + a 6th, gentle envelope, looped.

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _cache: Dictionary = {}        # key -> AudioStreamWAV
var _current_key: StringName = &""

# (base_freq_hz, chord_intervals_in_semitones, color)
const _BIOME_TRACKS := {
	&"forest":    [110.0, [0, 7, 12, 19]],          # warm A minor-ish
	&"city":      [98.0,  [0, 3, 7, 10]],           # G m7 — uneasy
	&"ruins":     [87.31, [0, 7, 12, 16]],          # F-ish open
	&"corrupted": [73.42, [0, 6, 11, 13]],          # D dissonant
	&"anomaly":   [82.41, [0, 5, 10, 15]],          # E quartal
	&"swamp":     [65.41, [0, 7, 12, 18]],          # C low drone
	&"highland":  [130.81,[0, 4, 7, 12]],           # C major bright
	&"crypt":     [55.0,  [0, 3, 8, 11]],           # A dark
	&"coast":     [98.0,  [0, 4, 9, 11]],           # G major-ish
}

const _BOSS_TRACKS := {
	&"prismatic_ascendant":  [261.63, [0, 4, 7, 11, 14]],     # bright multi-color chord
	&"nameless_sovereign":   [49.0,   [0, 6, 13, 19]],        # deep regal dissonance
	&"sea_beneath_stone":    [41.20,  [0, 8, 13, 17]],        # subterranean rumble
	&"gallows_parliament":   [73.42,  [0, 3, 6, 12]],         # judgement minor
	&"silent_orchestra":     [196.0,  [0, 5, 12, 19, 24]],    # spectral high chord
	&"that_which_dreams_us": [33.0,   [0, 7, 12, 19, 26]],    # impossible bass
	&"drowning_god":         [27.5,   [0, 5, 10, 11, 17]],    # abyssal drone
}

func _ready() -> void:
	_player_a = _make_player()
	_player_b = _make_player()
	_active = _player_a

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.volume_db = 0.0
	p.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(p)
	return p

func play_biome(biome: StringName) -> void:
	_crossfade(StringName("biome_" + String(biome)), _BIOME_TRACKS.get(biome, _BIOME_TRACKS[&"forest"]))

func play_boss(boss_id: StringName) -> void:
	_crossfade(StringName("boss_" + String(boss_id)), _BOSS_TRACKS.get(boss_id, _BOSS_TRACKS[&"prismatic_ascendant"]), -8.0)

func play_menu() -> void:
	_crossfade(&"menu", [146.83, [0, 5, 12, 17]])

func stop() -> void:
	_player_a.stop()
	_player_b.stop()
	_current_key = &""

func _crossfade(key: StringName, params: Array, _target_db_unused: float = 0.0) -> void:
	if key == _current_key: return
	_current_key = key
	var stream: AudioStreamWAV = _cache.get(key)
	if stream == null:
		stream = _build_drone(params[0], params[1])
		_cache[key] = stream
	var next_player := _player_b if _active == _player_a else _player_a
	next_player.stream = stream
	next_player.volume_db = -50.0
	next_player.play()
	var fade_in := next_player.create_tween()
	fade_in.tween_property(next_player, "volume_db", 0.0, 2.0)
	var fade_out := _active.create_tween()
	fade_out.tween_property(_active, "volume_db", -50.0, 2.0)
	fade_out.tween_callback(func():
		if is_instance_valid(_active): _active.stop())
	_active = next_player

# ---------- Audio synthesis ----------

func _build_drone(base_freq: float, intervals: Array) -> AudioStreamWAV:
	# 8-second loopable drone made of layered sines, slow tremolo, soft attack.
	var sample_rate := 22050
	var dur := 8.0
	var n := int(dur * sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var freqs: Array = []
	for st in intervals:
		freqs.append(base_freq * pow(2.0, float(st) / 12.0))
	for i in n:
		var t := float(i) / float(sample_rate)
		var v := 0.0
		for j in freqs.size():
			var f: float = freqs[j]
			# Slight detune per voice for chorus.
			var detune: float = 1.0 + (float(j) - 1.0) * 0.0007
			var amp: float = 0.8 / float(freqs.size())
			# Tremolo modulation.
			amp *= 0.85 + 0.15 * sin(TAU * 0.12 * t + j)
			v += sin(TAU * f * detune * t) * amp
		# Soft loop crossfade window (fade in/out 0.4s).
		var env := 1.0
		if t < 0.4: env = t / 0.4
		elif t > dur - 0.4: env = (dur - t) / 0.4
		v *= env * 0.6
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
