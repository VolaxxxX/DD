class_name WorldEngine extends Node
# Generates and manages zones for a run.

var rng: DRNG
var memory: WorldMemory
var zones: Array[Zone] = []
var active_zone_index: int = 0

func _init(_rng: DRNG, _mem: WorldMemory) -> void:
	rng = _rng
	memory = _mem

func generate(count: int) -> void:
	for i in count:
		var z := Zone.new(rng.derive(i + 1), memory, i)
		zones.append(z)
		add_child(z)
		z.generate()
	Bus.zone_changed.emit(0, zones[0].seed)

func advance_zone() -> void:
	active_zone_index += 1
	if active_zone_index >= zones.size():
		Bus.run_ended.emit(&"extracted")
		return
	Bus.zone_changed.emit(active_zone_index, zones[active_zone_index].seed)

func active_zone() -> Zone:
	return zones[active_zone_index]

func commit_memory(cause: StringName) -> Dictionary:
	var snap := {"last_death_cause": cause}
	var drift: int = int(memory.data.get("corruption_drift", 0))
	for z in zones: drift += int(z.corruption * 100)
	snap["corruption_drift"] = mini(drift, 1000)
	return snap
