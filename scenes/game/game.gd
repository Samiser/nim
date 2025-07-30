extends Control

func _ready() -> void:
	if not multiplayer.is_server():
		Lobby.player_loaded.rpc_id(1)

func start_game() -> void:
	print("start!")
