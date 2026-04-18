class_name WorldMemory extends RefCounted
# Persistent cross-run memory. Loaded from disk, mutated by each run.

const PATH := "user://world_memory.dat"

var data := {
	"killed_apex": {},         # zone_index -> cooldown_runs remaining
	"faction_state": {},       # faction_id -> influence int
	"corruption_drift": 0,     # 0..1000, grows over runs
	"last_death_cause": &"",
	"runs_completed": 0,
}

static func load_or_new() -> WorldMemory:
	var m := WorldMemory.new()
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var v = f.get_var()
			if typeof(v) == TYPE_DICTIONARY:
				for k in v: m.data[k] = v[k]
	return m

func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f: f.store_var(data)

func merge(snap: Dictionary) -> void:
	for k in snap: data[k] = snap[k]
	data["runs_completed"] = int(data.get("runs_completed", 0)) + 1
