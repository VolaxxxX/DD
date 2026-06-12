class_name FateEngine extends RefCounted
# Hidden d20-style resolver. Never exposes numbers to the player.
# Carries a hidden "momentum" rubber-band so streaks self-correct: repeated
# failures quietly build a bonus (pity), repeated crit successes cool off.
# Keeps the game from feeling either punishing or trivial without ever
# touching the visible fiction.

enum Outcome { CRIT_FAIL, FAIL, MIXED, SUCCESS, CRIT_SUCCESS }

var rng: DRNG
var _momentum: int = 0     # hidden modifier, clamped to [-2, +3]

func _init(_rng: DRNG) -> void:
	rng = _rng

func resolve(stat: int, difficulty: int, coop_mod: int, world_mod: int) -> int:
	var roll := rng.range_i(1, 21)  # 1..20
	var total := roll + stat + coop_mod + world_mod + _momentum
	var outcome: int
	if roll == 1: outcome = Outcome.CRIT_FAIL
	elif roll == 20: outcome = Outcome.CRIT_SUCCESS
	# Crits require BOTH a high die (top of the d20) and real margin — raw stat
	# advantage alone shouldn't shower the player with critical successes.
	elif roll >= 18 and total >= difficulty + 8: outcome = Outcome.CRIT_SUCCESS
	elif total >= difficulty + 3:  outcome = Outcome.SUCCESS
	elif total >= difficulty:      outcome = Outcome.MIXED
	elif total >= difficulty - 5:  outcome = Outcome.FAIL
	else: outcome = Outcome.CRIT_FAIL
	_update_momentum(outcome)
	return outcome

func _update_momentum(outcome: int) -> void:
	match outcome:
		Outcome.CRIT_FAIL: _momentum = mini(_momentum + 2, 3)
		Outcome.FAIL:      _momentum = mini(_momentum + 1, 3)
		Outcome.SUCCESS:   _momentum = maxi(_momentum - 1, 0) if _momentum > 0 else _momentum
		Outcome.CRIT_SUCCESS: _momentum = maxi(_momentum - 2, -2)
		_: pass   # MIXED leaves momentum untouched
