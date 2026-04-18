class_name AIFSM extends RefCounted
# Finite state machine for creature AI behavior.

enum S { IDLE, HUNT, FLEE, NEGOTIATE, ADAPT, MUTATE }

var state: int = S.IDLE
var stress: int = 0
var survived_events: int = 0

func tick(c: Creature, ctx: Dictionary) -> void:
	var threat: int = ctx.get("threat", 0)
	var allies: int = ctx.get("allies", 0)
	match state:
		S.IDLE:
			if threat > c.archetype.aggression: _to(S.FLEE)
			elif threat > 0 and c.archetype.aggression > 50: _to(S.HUNT)
			elif c.archetype.intelligence > 60 and allies > 0: _to(S.NEGOTIATE)
		S.HUNT:
			if threat > c.archetype.aggression + 20: _to(S.FLEE)
			elif threat == 0: _to(S.IDLE); survived_events += 1
		S.FLEE:
			if threat == 0: _to(S.IDLE); survived_events += 1
		S.NEGOTIATE:
			if ctx.get("rejected", false): _to(S.HUNT)
			elif threat == 0: _to(S.IDLE)
		S.ADAPT:
			if survived_events > 3 and c.archetype.mutation_pool.size() > 0: _to(S.MUTATE)
		S.MUTATE:
			c.apply_mutation()
			_to(S.IDLE)
	if survived_events >= 3 and state == S.IDLE and c.archetype.mutation_pool.size() > 0:
		_to(S.ADAPT)

func _to(s: int) -> void:
	if s != state:
		state = s
