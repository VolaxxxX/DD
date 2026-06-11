class_name Zone extends Node3D
# A single procedural zone: biome, chaos, corruption, ecosystem.

const BIOMES := [&"forest", &"city", &"ruins", &"corrupted", &"anomaly", &"swamp", &"highland", &"crypt", &"coast"]

var rng: DRNG
var memory: WorldMemory
var index: int
var seed: int
var biome: StringName
var sub_biome: int = 0
var chaos: float
var corruption: float
var ecosystem: Ecosystem
var dragon_id: StringName = &""
var dragon_intro: String = ""
var dragon_effect: String = ""
var dragon_value: int = 0
var dragon_gift_used: bool = false   # for free_crit_cursed

func _init(_rng: DRNG, _mem: WorldMemory, _idx: int) -> void:
	rng = _rng
	memory = _mem
	index = _idx
	seed = _rng.next()

func generate() -> void:
	biome = BIOMES[rng.range_i(0, BIOMES.size())]
	var sub_count: int = int(PropLoader.SUB_COUNT.get(biome, 1))
	sub_biome = rng.range_i(0, sub_count)
	chaos = float(rng.range_i(20, 90)) / 100.0
	var drift: float = float(memory.data.get("corruption_drift", 0)) / 1000.0
	corruption = clampf(chaos + drift, 0.0, 1.0)
	ecosystem = Ecosystem.new(rng.derive(0xEC05), self)
	add_child(ecosystem)
	ecosystem.populate()
	if chaos > 0.7:
		DragonSystem.maybe_manifest(self, rng.derive(0xD4A6))
	print("[ZONE %d] biome=%s chaos=%.2f corruption=%.2f" % [index, biome, chaos, corruption])
