extends Control

@onready var host_button := $VBoxContainer/Host
@onready var join_button := $VBoxContainer/Join
@onready var start_button := $VBoxContainer/StartGame

func _on_host_button_down() -> void:
	Lobby.player_info["name"] = $VBoxContainer/HBoxContainer/Name.text
	var error = Lobby.create_game()
	if error:
		printerr("Error: ", error)

func _on_join_button_down() -> void:
	Lobby.player_info["name"] = $VBoxContainer/HBoxContainer/Name.text
	var error = Lobby.join_game()
	if error:
		printerr("Error: ", error)

func _on_start_button_down() -> void:
	Lobby.load_game.rpc("game.tscn")

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_down)
	join_button.pressed.connect(_on_join_button_down)
	start_button.pressed.connect(_on_start_button_down)
