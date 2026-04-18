class_name CoopIntent extends Node
# Manages shared-decision voting windows for co-op events.

const WINDOW_TICKS := 30

var pending: Dictionary = {}        # event_id -> {pid: bool}
var window_open: Dictionary = {}    # event_id -> ticks remaining

func register(eid: int, players: Array) -> void:
	pending[eid] = {}
	for p in players: pending[eid][p] = false
	window_open[eid] = WINDOW_TICKS

func vote(eid: int, pid: int) -> void:
	if eid in pending: pending[eid][pid] = true

func tick() -> int:
	# Returns a coop_mod for any event whose window just expired, else 0.
	var result := 0
	for eid in window_open.keys():
		window_open[eid] -= 1
		if window_open[eid] <= 0:
			var votes := 0
			var total: int = pending[eid].size()
			for v in pending[eid].values(): votes += int(v)
			pending.erase(eid)
			window_open.erase(eid)
			if total > 0 and votes == total: result = 4
			elif votes == 0: result = -2
			else: result = 1
	return result
