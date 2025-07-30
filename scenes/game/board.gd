@tool
extends Control

@onready var token_row_container := $TokenRowContainer

@export var row_count := 4

var token_row_scene := preload("res://scenes/game/token_row.tscn")

func get_all_rows() -> Array[Node]:
	return token_row_container.get_children()

func get_row(index: int) -> Node:
	return token_row_container.get_child(index)

func _reset_board() -> void:
	for child in token_row_container.get_children():
		child.queue_free()
	for i in range(row_count):
		var new_token_row := token_row_scene.instantiate()
		token_row_container.add_child(new_token_row) 
		new_token_row.initial_token_count = i * 2 + 1

func _set_up_rows() -> void:
	if token_row_container.get_child_count() != row_count:
		_reset_board()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_set_up_rows()

func _ready() -> void:
	_set_up_rows()
