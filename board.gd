@tool
extends Control

@onready var token_row_container := $TokenRowContainer

@export var row_count := 4

var token_row_scene := preload("res://token_row.tscn")

func _reset_board():
	for child in token_row_container.get_children():
		child.queue_free()
	for i in range(row_count):
		var new_token_row := token_row_scene.instantiate()
		new_token_row.token_count = i * 2 + 1
		new_token_row.initial_token_count = new_token_row.token_count
		token_row_container.add_child(new_token_row) 

func _set_up_rows() -> void:
	if token_row_container.get_child_count() != row_count:
		_reset_board()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_set_up_rows()

func _ready() -> void:
	_set_up_rows()
