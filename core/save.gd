extends Node
# Persistent save: PlayerStates + run zone index + world seed.
# Auto-saves between zones. Used by main_menu to show "Continue".
# Autoloaded as "Save".

const PATH := "user://run.sav"

func has_save() -> bool:
	return FileAccess.file_exists(PATH)

func save_run(players: Array, world: WorldEngine) -> void:
	if world == null: return
	var d := {
		"version": 1,
		"seed": world.zones[0].seed if world.zones.size() > 0 else 0,
		"zone_index": world.active_zone_index,
		"players": [],
	}
	for p in players:
		var ps: PlayerState = p
		d["players"].append({
			"name": ps.name,
			"class_kind": ps.class_kind,
			"stats": ps.stats.duplicate(),
			"injuries": ps.injuries.duplicate(),
			"alive": ps.alive,
		})
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f: f.store_var(d)

func load_run() -> Dictionary:
	if not has_save(): return {}
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null: return {}
	var v = f.get_var()
	if typeof(v) != TYPE_DICTIONARY: return {}
	# Defensive validation — a corrupted save is preferable to a crash.
	if not v.has("players") or not (v.get("players") is Array): return {}
	if not v.has("seed") or not (v.get("seed") is int): return {}
	if not v.has("zone_index") or not (v.get("zone_index") is int): return {}
	for p in v.players:
		if not (p is Dictionary): return {}
		if not p.has("name") or not p.has("class_kind") or not p.has("stats"): return {}
	return v

func clear() -> void:
	if has_save():
		DirAccess.remove_absolute(PATH)
