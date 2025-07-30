extends Node

var current_turn_peer_id: int = -1
var turn_order: Array = []

func start_game() -> void:
	turn_order = Lobby.get_peer_ids()
	advance_turn()

func advance_turn() -> void:
	if turn_order.is_empty():
		return

	var current_index := turn_order.find(current_turn_peer_id)
	current_turn_peer_id = turn_order[(current_index + 1) % turn_order.size()]
	print("New turn: ", current_turn_peer_id)

	_set_current_turn.rpc(current_turn_peer_id)

@rpc("authority", "call_remote", "reliable")
func _set_current_turn(peer_id: int) -> void:
	Lobby.current_turn_peer_id = peer_id
