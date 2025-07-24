extends Control

@onready var multiplayer_menu := $HBoxContainer/VBoxContainer2/MultiplayerMenu

func start() -> void:
	var board_scene := load("res://board.tscn")
	$HBoxContainer.add_child(board_scene.instantiate())
	print("test")

func _ready() -> void:
	multiplayer_menu.start.connect(start)
