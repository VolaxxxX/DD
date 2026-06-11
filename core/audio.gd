extends Node
# Procedural audio: short generated tones for key events. Autoloaded as "Audio".

var _players: Dictionary = {}        # key -> AudioStreamPlayer

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

func _adsr(t: float) -> float:
	# Quick attack, gentle decay.
	if t < 0.05: return t / 0.05
	if t < 0.20: return 1.0 - (t - 0.05) * 0.6 / 0.15
	if t > 0.85: return 0.4 * (1.0 - (t - 0.85) / 0.15)
	return 0.4
