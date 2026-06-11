extends Node
# Procedural audio: short generated tones for key events + a low ambient layer
# that adapts to the current biome.  Autoloaded as "Audio".

var _players: Dictionary = {}        # key -> AudioStreamPlayer
var _ambient: AudioStreamPlayer       # looped low layer (wind/water/dripping)

func _ready() -> void:
	_make(&"click",   _tone([880.0], 0.06, 0.15))
	_make(&"hover",   _tone([660.0], 0.04, 0.10))
	_make(&"success", _tone([523.25, 659.25, 783.99], 0.10, 0.25))
	_make(&"crit",    _tone([392.0, 523.25, 783.99, 1046.50], 0.08, 0.35))
	_make(&"fail",    _tone([196.0, 174.61], 0.18, 0.30))
	_make(&"crit_fail", _tone([110.0, 87.31, 73.42], 0.30, 0.40))
	_make(&"hit",     _tone([220.0, 196.0], 0.05, 0.30))
	_make(&"intro",   _tone([261.63, 329.63, 392.0], 0.30, 0.18))
	_make(&"death",   _tone([130.81, 110.0, 98.0, 87.31], 0.50, 0.35))
	_make(&"boss",    _tone([55.0, 110.0, 41.20], 0.80, 0.45))
	_make(&"dragon",  _tone([146.83, 110.0, 220.0], 0.60, 0.30))
	_ambient = AudioStreamPlayer.new()
	_ambient.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
	_ambient.volume_db = -22.0
	add_child(_ambient)

func set_ambient_biome(biome: StringName) -> void:
	# Layer-low rumble/wind/water generated once per biome and looped.
	var key := StringName("amb_" + String(biome))
	var stream: AudioStreamWAV = _players.get(key).stream if _players.has(key) else null
	if stream == null:
		var freqs: Array = [60.0, 90.0]
		var noise_amt := 0.3
		match String(biome):
			"forest":    freqs = [60.0, 90.0, 180.0]; noise_amt = 0.45  # wind through trees
			"city":      freqs = [55.0, 110.0]; noise_amt = 0.20         # low rumble
			"ruins":     freqs = [50.0, 75.0]; noise_amt = 0.15          # quiet wind
			"corrupted": freqs = [40.0, 65.0, 135.0]; noise_amt = 0.30   # diseased
			"anomaly":   freqs = [33.0, 55.0, 88.0]; noise_amt = 0.25    # otherworldly
			"swamp":     freqs = [50.0, 70.0]; noise_amt = 0.55          # water drips
			"highland":  freqs = [70.0, 110.0]; noise_amt = 0.55         # strong wind
			"crypt":     freqs = [37.0, 55.0]; noise_amt = 0.10          # near-silence
			"coast":     freqs = [55.0, 75.0]; noise_amt = 0.65          # surf
		stream = _ambient_stream(freqs, noise_amt)
		# Cache by storing on a temp dict entry.
		var p := AudioStreamPlayer.new(); p.stream = stream
		_players[key] = p
	if _ambient.stream != stream:
		_ambient.stop()
		_ambient.stream = stream
	if not _ambient.playing: _ambient.play()

func play(key: StringName, pitch: float = 1.0) -> void:
	var p: AudioStreamPlayer = _players.get(key)
	if p == null: return
	p.pitch_scale = pitch
	p.play()

func _make(key: StringName, stream: AudioStreamWAV) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = 0.0
	p.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
	add_child(p)
	_players[key] = p

func _tone(freqs: Array, duration: float, volume: float) -> AudioStreamWAV:
	# Mix multiple sines, ADSR envelope, return a tiny WAV stream.
	var sample_rate := 22050
	var n := int(duration * sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	for i in n:
		var t := float(i) / float(sample_rate)
		var env := _adsr(float(i) / float(n))
		var v := 0.0
		for f in freqs:
			v += sin(TAU * float(f) * t)
		v = (v / float(freqs.size())) * env * volume
		var s16 := int(clamp(v, -1.0, 1.0) * 32767.0)
		pcm.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm
	return stream

func _ambient_stream(freqs: Array, noise_amt: float) -> AudioStreamWAV:
	# 6-second loopable ambient bed: layered sines + filtered noise.
	var sample_rate := 22050
	var dur := 6.0
	var n := int(dur * sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var last_noise := 0.0
	for i in n:
		var t := float(i) / float(sample_rate)
		var v := 0.0
		for j in freqs.size():
			var f: float = freqs[j]
			v += sin(TAU * f * (1.0 + 0.0003 * j) * t) * (0.5 / float(freqs.size()))
		# Pink-ish noise (1-pole lowpass random).
		var rnd := randf() * 2.0 - 1.0
		last_noise = lerp(last_noise, rnd, 0.18)
		v += last_noise * noise_amt
		# Internal fade for seamless loop.
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

func _adsr(t: float) -> float:
	# Quick attack, gentle decay.
	if t < 0.05: return t / 0.05
	if t < 0.20: return 1.0 - (t - 0.05) * 0.6 / 0.15
	if t > 0.85: return 0.4 * (1.0 - (t - 0.85) / 0.15)
	return 0.4
