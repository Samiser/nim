extends Node

signal player_connected(peer_id: int, player_info: Player)
signal player_disconnected(peer_id: int)
signal server_disconnected

const DEFAULT_SERVER_IP = "127.0.0.1"
const PORT = 6969

var player_info := Player.new()

var players := {}
var players_loaded := 0

signal reset
signal start

func create_game() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, 2)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	print("waiting for players...")
	
	return Error.OK
	
func join_game(address: String = "") -> Error:
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	return Error.OK

func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("call_local", "reliable")
func load_game(game_scene_path: String) -> void:
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info: Player) -> void:
	print(new_player_info)
	var new_player_id := multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
