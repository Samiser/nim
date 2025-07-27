extends Control

var players: Array[Player]

func _ready() -> void:
	Lobby.player_loaded.rpc_id(1)

func start_game() -> void:
	print("start!")
