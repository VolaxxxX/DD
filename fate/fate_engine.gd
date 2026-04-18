class_name FateEngine extends RefCounted
# Hidden d20-style resolver. Never exposes numbers to the player.

enum Outcome { CRIT_FAIL, FAIL, MIXED, SUCCESS, CRIT_SUCCESS }

var rng: DRNG

func _init(_rng: DRNG) -> void:
	rng = _rng

func resolve(stat: int, difficulty: int, coop_mod: int, world_mod: int) -> int:
	var roll := rng.range_i(1, 21)  # 1..20
	var total := roll + stat + coop_mod + world_mod
	if roll == 1: return Outcome.CRIT_FAIL
	if roll == 20: return Outcome.CRIT_SUCCESS
	if total >= difficulty + 10: return Outcome.CRIT_SUCCESS
	if total >= difficulty + 3:  return Outcome.SUCCESS
	if total >= difficulty:      return Outcome.MIXED
	if total >= difficulty - 5:  return Outcome.FAIL
	return Outcome.CRIT_FAIL
