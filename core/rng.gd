class_name DRNG extends RefCounted
# Deterministic integer RNG (xorshift64*).
# Floats forbidden for multiplayer sync correctness.

var _s: int

func _init(seed: int) -> void:
	_s = seed if seed != 0 else 0x1E3779B97F4A7C15

func next() -> int:
	_s ^= _s >> 12
	_s ^= _s << 25
	_s ^= _s >> 27
	return (_s * 0x2545F4914F6CDD1D) & 0x7FFFFFFFFFFFFFFF

func range_i(lo: int, hi: int) -> int:
	return lo + (next() % maxi(1, hi - lo))

func chance(num: int, den: int) -> bool:
	return (next() % den) < num

func derive(tag: int) -> DRNG:
	return DRNG.new(next() ^ tag)
