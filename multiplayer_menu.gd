extends Control

@onready var host_button := $VBoxContainer/Host
@onready var join_button := $VBoxContainer/Join
@onready var start_button := $VBoxContainer/StartGame

@export var address = "127.0.0.1"
@export var port = 6969

var peer: ENetMultiplayerPeer

signal reset
signal start

func _on_host_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port, 2)
	if error != OK:
		printerr("cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players...")
	
func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local")
func _start_game():
	start.emit()

func _on_start_button_down() -> void:
	_start_game.rpc()

func _player_connected(id: int):
	print("player connected: ", id)

func _player_disconnected(id: int):
	print("player disconnected: ", id)

func _connected_to_server() -> void:
	print("connected to server!")

func _connection_failed() -> void:
	print("couldn't connect to server")

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_down)
	join_button.pressed.connect(_on_join_button_down)
	start_button.pressed.connect(_on_start_button_down)
	
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
