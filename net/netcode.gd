class_name Netcode extends Node
# Host/client netcode. ENet over UDP, event-based.

const PORT := 35115

var peer: ENetMultiplayerPeer
var is_host: bool = false
var tick: int = 0
var shared_seed: int = 0

func host() -> int:
	is_host = true
	peer = ENetMultiplayerPeer.new()
	shared_seed = int(Time.get_unix_time_from_system())
	var err := peer.create_server(PORT, 2)
	if err != OK:
		push_error("[NET] host failed: %d" % err)
		return 0
	multiplayer.multiplayer_peer = peer
	print("[NET] hosting on %d seed=%d" % [PORT, shared_seed])
	return shared_seed

func join(ip: String) -> void:
	is_host = false
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		push_error("[NET] join failed: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("[NET] joining %s" % ip)

@rpc("any_peer", "reliable")
func send_intent(action: int, target: int, t: int) -> void:
	if is_host:
		_process_intent(multiplayer.get_remote_sender_id(), action, target, t)

@rpc("authority", "reliable")
func push_event(eid: int, outcome: int, refs: PackedInt32Array) -> void:
	Bus.event_resolved.emit(eid, outcome, StringName("net"))

func _process_intent(pid: int, action: int, target: int, t: int) -> void:
	# Host validates + feeds EventResolver, then push_event.rpc() to all.
	# Left minimal for MVP; main.gd drives resolution locally.
	pass
