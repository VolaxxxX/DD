extends Node
# Procedural ambient music: layered drones + slow melodic line that morphs by
# biome/world boss.  Per-encounter pitch nudge keeps the listener's ear fresh
# without crossfading the whole track.
# Autoloaded as "Music".  Tracks are tiny WAV streams generated on first play.

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _cache: Dictionary = {}        # key -> AudioStreamWAV
var _current_key: StringName = &""
var _base_volume_db: float = 0.0  # bus-level fader handles overall balance
var _current_pitch_offset: float = 0.0

# (base_freq_hz, chord_intervals_in_semitones, melody_pattern_semitone_offsets)
# Melody is a slow sequence of notes played in a higher octave over the drone.
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

const _BOSS_TRACKS := {
	&"prismatic_ascendant":  [261.63, [0, 4, 7, 11, 14], [0, 7, 14, 11, 7, 4]],
	&"nameless_sovereign":   [49.0,   [0, 6, 13, 19],    [0, 13, 6, 19, 13, 6]],
	&"sea_beneath_stone":    [41.20,  [0, 8, 13, 17],    [0, 13, 8, 17, 13, 8]],
	&"gallows_parliament":   [73.42,  [0, 3, 6, 12],     [0, 6, 12, 6, 3, 0]],
	&"silent_orchestra":     [196.0,  [0, 5, 12, 19, 24],[0, 12, 19, 24, 19, 12]],
	&"that_which_dreams_us": [33.0,   [0, 7, 12, 19, 26],[0, 12, 19, 26, 19, 7]],
	&"drowning_god":         [27.5,   [0, 5, 10, 11, 17],[0, 10, 5, 17, 11, 5]],
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
	_current_pitch_offset = 0.0
	_crossfade(StringName("biome_" + String(biome)), _BIOME_TRACKS.get(biome, _BIOME_TRACKS[&"forest"]))

func play_boss(boss_id: StringName) -> void:
	_current_pitch_offset = 0.0
	_crossfade(StringName("boss_" + String(boss_id)), _BOSS_TRACKS.get(boss_id, _BOSS_TRACKS[&"prismatic_ascendant"]), -4.0)

func play_menu() -> void:
	_current_pitch_offset = 0.0
	_crossfade(&"menu", [146.83, [0, 5, 12, 17], [0, 5, 12, 17, 12, 5]])

# Subtle per-encounter ear refresh.  Nudges the active player's pitch_scale by
# a small amount derived from `encounter_idx`, so neighbouring fights feel
# distinct without crossfading another stream.
func nudge_for_encounter(encounter_idx: int) -> void:
	# Sequence: 0, +1, -1, +2, -2, +3 semitones (small step pattern).
	var steps := [0, 1, -1, 2, -2, 3, -3]
	var step: int = steps[encounter_idx % steps.size()]
	var target_pitch := pow(2.0, float(step) / 12.0)
	_current_pitch_offset = step
	if _active != null and is_instance_valid(_active):
		var t := _active.create_tween()
		t.tween_property(_active, "pitch_scale", target_pitch, 1.6).set_trans(Tween.TRANS_SINE)

func stop() -> void:
	_player_a.stop()
	_player_b.stop()
	_current_key = &""

func _crossfade(key: StringName, params: Array, extra_db: float = 0.0) -> void:
	if key == _current_key: return
	_current_key = key
	var stream: AudioStreamWAV = _cache.get(key)
	if stream == null:
		var melody: Array = params[2] if params.size() >= 3 else []
		stream = _build_track(params[0], params[1], melody)
		_cache[key] = stream
	var next_player := _player_b if _active == _player_a else _player_a
	next_player.stream = stream
	next_player.pitch_scale = 1.0
	next_player.volume_db = -50.0
	next_player.play()
	var fade_in := next_player.create_tween()
	fade_in.tween_property(next_player, "volume_db", _base_volume_db + extra_db, 2.0)
	var fade_out := _active.create_tween()
	fade_out.tween_property(_active, "volume_db", -50.0, 2.0)
	fade_out.tween_callback(func():
		if is_instance_valid(_active): _active.stop())
	_active = next_player

# ---------- Audio synthesis ----------

func _build_track(base_freq: float, intervals: Array, melody: Array) -> AudioStreamWAV:
	# 16-second loopable piece: layered sine drones + slow soft melody.
	var sample_rate := 22050
	var dur := 16.0
	var n := int(dur * sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	# Drone voices
	var freqs: Array = []
	for st in intervals:
		freqs.append(base_freq * pow(2.0, float(st) / 12.0))
	# Melody voices (one octave above the chord root).
	var mel_freqs: Array = []
	for st in melody:
		mel_freqs.append(base_freq * 2.0 * pow(2.0, float(st) / 12.0))
	var mel_note_dur: float = dur / maxi(1, mel_freqs.size())
	for i in n:
		var t := float(i) / float(sample_rate)
		var v := 0.0
		# Drone chord
		for j in freqs.size():
			var f: float = freqs[j]
			var detune: float = 1.0 + (float(j) - 1.0) * 0.0007
			var amp: float = 0.55 / float(freqs.size())
			# Slow tremolo, each voice phased differently.
			amp *= 0.85 + 0.15 * sin(TAU * 0.10 * t + j * 0.7)
			v += sin(TAU * f * detune * t) * amp
		# Melodic top voice — soft sine with attack/decay envelope per note.
		if mel_freqs.size() > 0:
			var mi: int = int(t / mel_note_dur) % mel_freqs.size()
			var mf: float = mel_freqs[mi]
			var note_t: float = fposmod(t, mel_note_dur)
			var note_env: float = 1.0
			# 0.4s attack, 0.4s release.
			if note_t < 0.4: note_env = note_t / 0.4
			elif note_t > mel_note_dur - 0.4: note_env = (mel_note_dur - note_t) / 0.4
			note_env = clamp(note_env, 0.0, 1.0)
			# Tiny vibrato.
			var vib: float = sin(TAU * 4.5 * t) * 0.004
			v += sin(TAU * mf * (1.0 + vib) * t) * 0.18 * note_env
		# Sub-octave gentle pulse for depth.
		v += sin(TAU * (base_freq * 0.5) * t) * 0.08 * (0.7 + 0.3 * sin(TAU * 0.06 * t))
		# Soft loop crossfade window.
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
