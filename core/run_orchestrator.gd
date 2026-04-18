class_name RunOrchestrator extends Node
# Orchestrates a single run: seeds, world gen, memory commit on end.

const ZONE_COUNT_MIN := 2
const ZONE_COUNT_MAX := 4

var master_seed: int
var rng: DRNG
var world: WorldEngine
var memory: WorldMemory

func start_run(seed: int) -> void:
	master_seed = seed
	rng = DRNG.new(seed)
	memory = WorldMemory.load_or_new()
	world = WorldEngine.new(rng.derive(0xABC123), memory)
	add_child(world)
	var zone_count := rng.range_i(ZONE_COUNT_MIN, ZONE_COUNT_MAX + 1)
	world.generate(zone_count)
	Bus.run_ended.connect(_on_end, CONNECT_ONE_SHOT)
	print("[RUN] started seed=%d zones=%d" % [seed, zone_count])

func _on_end(cause: StringName) -> void:
	var snap := world.commit_memory(cause)
	memory.merge(snap)
	memory.save()
	Bus.memory_committed.emit(snap)
	print("[RUN] ended cause=%s" % cause)
