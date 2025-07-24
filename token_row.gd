@tool
extends Control
class_name TokenRow

@export var token_count: int = 3
@export var initial_token_count: int = 3
@onready var tokens := $Tokens

@export var token_spacing: int = 64
@export var token_width: int = 64

var token_scene := preload("res://token.tscn")

func _setup_tokens() -> void:
	while tokens.get_child_count() != token_count:
		if token_count < tokens.get_child_count():
			tokens.remove_child(tokens.get_child(0))
		elif token_count > tokens.get_child_count():
			var token := token_scene.instantiate()
			_attach_token_signals(token)
			tokens.add_child(token)
	
	var total_width := initial_token_count * token_width + (initial_token_count - 1) * token_spacing
	var start_x: float = (tokens.get_rect().size.x - total_width) / 2.0
	var start_y: float = tokens.get_rect().size.y / 2.0 - 64

	for i in range(tokens.get_child_count()):
		var token = tokens.get_child(i)
		token.position = Vector2(start_x + i * (token_width + token_spacing) - token_spacing/2, start_y)

func _process(_delta: float) -> void:
	_setup_tokens()

func _for_each_child_from(token: Token, f: Callable):
	var children := tokens.get_children()
	var index := children.find(token)
	
	for i: int in range(index, children.size()):
		f.call(children[i])

func _on_token_mouse_entered(token: Token) -> void:
	var highlight := func(token: Token) -> void: token.highlight(true)
	_for_each_child_from(token, highlight)

func _on_token_mouse_exited(token: Token) -> void:
	for child: Token in tokens.get_children():
		child.highlight(false)

func _on_token_clicked(token: Token) -> void:
	_for_each_child_from(token, func(token: Token) -> void: token_count -= 1)

func _attach_token_signals(token: Token):
	token.mouse_off.connect(_on_token_mouse_exited)
	token.mouse_over.connect(_on_token_mouse_entered)
	token.clicked.connect(_on_token_clicked)

func _ready() -> void:
	for token in tokens.get_children():
		_attach_token_signals(token)
	
	_setup_tokens()
