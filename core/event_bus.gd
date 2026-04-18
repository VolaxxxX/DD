extends Node
# Global signal hub. Autoloaded as "Bus" (see project.godot).
# All cross-system communication goes through here.

signal entity_spawned(id: int, archetype_id: StringName, pos: Vector3)
signal entity_state_changed(id: int, state: int)
signal entity_died(id: int)
signal event_triggered(event_id: int, kind: int, refs: Array)
signal event_resolved(event_id: int, outcome: int, narrative: StringName)
signal zone_changed(zone_index: int, seed: int)
signal apex_manifested(dragon_kind: int, zone_index: int)
signal run_ended(cause: StringName)
signal memory_committed(snapshot: Dictionary)
signal player_moved(player_id: int, pos: Vector3)
