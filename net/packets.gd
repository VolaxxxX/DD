class_name Packets extends RefCounted
# Compact event packet encoding (<128 bytes each).

enum T { INPUT_INTENT, EVENT_RESOLVED, WORLD_DELTA, MEMORY_COMMIT }

static func pack_intent(action: int, target: int, tick: int) -> PackedByteArray:
	var b := StreamPeerBuffer.new()
	b.put_u8(T.INPUT_INTENT)
	b.put_u16(action)
	b.put_u32(target)
	b.put_u32(tick)
	return b.data_array

static func pack_event(eid: int, outcome: int, refs: PackedInt32Array) -> PackedByteArray:
	var b := StreamPeerBuffer.new()
	b.put_u8(T.EVENT_RESOLVED)
	b.put_u32(eid)
	b.put_u8(outcome)
	b.put_u8(refs.size())
	for r in refs: b.put_u32(r)
	return b.data_array
