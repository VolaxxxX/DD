class_name Ecosystem extends Node
# Holds all creatures for a zone, runs AI ticks, computes threat.

var rng: DRNG
var zone: Zone
var creatures: Array[Creature] = []
var roster: Array[Archetype] = []
var _next_id: int = 1

func _init(_rng: DRNG, _zone: Zone) -> void:
	rng = _rng
	zone = _zone

func populate() -> void:
	roster = ArchetypeFactory.roster(rng.derive(0xR05), zone.biome, zone.chaos)
	var density := 12 + int(zone.chaos * 24.0)
	for i in density:
		var arch := _weighted_pick()
		var c := Creature.new()
		var pos := Vector3(rng.range_i(-40, 40), 0, rng.range_i(-40, 40))
		zone.add_child(c)
		c.setup(_next_id, arch, rng.derive(_next_id), pos)
		creatures.append(c)
		_next_id += 1
	print("[ECO] zone=%d roster=%d creatures=%d" % [zone.index, roster.size(), creatures.size()])

func _weighted_pick() -> Archetype:
	var total := 0
	for a in roster: total += a.ecology_weight
	if total <= 0: return roster[0]
	var r := rng.range_i(0, total)
	var acc := 0
	for a in roster:
		acc += a.ecology_weight
		if r < acc: return a
	return roster[0]

func tick(player_pos: Vector3 = Vector3.ZERO) -> void:
	var living: Array[Creature] = []
	for c in creatures:
		if c.alive: living.append(c)
	creatures = living
	for c in creatures:
		var ctx := {
			"threat": _threat_at(c.position),
			"allies": _allies_near(c),
			"target_pos": player_pos,
		}
		c.ai_tick(ctx)

func _threat_at(p: Vector3) -> int:
	var t := 0
	for c in creatures:
		if not c.alive: continue
		if c.position.distance_to(p) < c.archetype.influence_radius:
			t += c.archetype.aggression / 10
	return t

func _allies_near(self_c: Creature) -> int:
	var n := 0
	for c in creatures:
		if c == self_c or not c.alive: continue
		if c.archetype.family == self_c.archetype.family:
			if c.position.distance_to(self_c.position) < 8.0: n += 1
	return n

func nearest_to(p: Vector3, max_dist: float) -> Creature:
	var best: Creature = null
	var best_d := max_dist
	for c in creatures:
		if not c.alive: continue
		var d := c.position.distance_to(p)
		if d < best_d:
			best_d = d
			best = c
	return best
