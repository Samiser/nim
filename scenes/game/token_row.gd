@tool
extends Control
class_name TokenRow

var token_count: int:
	set(value):
		if token_count != value:
			token_count = value
			if is_inside_tree():
				_setup_tokens()
var initial_token_count: int:
	set(value):
		initial_token_count = value
		token_count = value

@onready var tokens := $Tokens

@export var token_spacing: int = 64
@export var token_width: int = 64

var token_scene := preload("res://scenes/game/token.tscn")

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
		var token := tokens.get_child(i)
		token.position = Vector2(start_x + i * (token_width + token_spacing) - token_spacing/2, start_y)

func _clear_highlight() -> void:
	for child: Token in tokens.get_children():
			child.highlight(false)

func _handle_token_hover(token: Token, highlight: bool) -> void:
	if token:
		_for_each_child_from(token, func(t: Token) -> void: t.highlight(highlight))
	else:
		_clear_highlight()

func _handle_token_click(token: Token) -> void:
	_for_each_child_from(token, func(_t: Token) -> void: token_count -= 1)

@rpc("authority", "call_remote", "reliable")
func _rpc_apply_token_hover(index: int, highlight: bool) -> void:
	if index >= 0:
		_for_each_child_from(tokens.get_child(index), func(t: Token) -> void: t.highlight(highlight))
	else:
		_clear_highlight()

@rpc("authority", "call_remote", "reliable")
func _rpc_apply_token_click(index: int) -> void:
	var token := tokens.get_child(index)
	_for_each_child_from(token, func(_t: Token) -> void: token_count -= 1)
	_clear_highlight()

@rpc("any_peer", "call_remote", "reliable")
func _rpc_request_token_hover(index: int, highlight: bool) -> void:
	if not Lobby.multiplayer.is_server(): return
	_handle_token_hover(tokens.get_child(index) if index >= 0 else null, highlight)
	_rpc_apply_token_hover.rpc(index, highlight)

@rpc("any_peer", "call_remote", "reliable")
func _rpc_request_token_click(index: int) -> void:
	if not Lobby.multiplayer.is_server(): return
	var token := tokens.get_child(index)
	_handle_token_click(token)
	_rpc_apply_token_click.rpc(index)

func _process(_delta: float) -> void:
	_setup_tokens()

func _for_each_child_from(token: Token, f: Callable) -> void:
	var children := tokens.get_children()
	var index := children.find(token)
	
	for i: int in range(index, children.size()):
		f.call(children[i])

func _on_token_mouse_entered(token: Token) -> void:
	if Lobby.multiplayer.is_server():
		_handle_token_hover(token, true)
	else:
		var index := tokens.get_children().find(token)
		_rpc_request_token_hover.rpc_id(1, index, true)

func _on_token_mouse_exited(token: Token) -> void:
	if Lobby.multiplayer.is_server():
		_handle_token_hover(null, false)
	else:
		_rpc_request_token_hover.rpc_id(1, -1, false)

func _on_token_clicked(token: Token) -> void:
	if Lobby.multiplayer.is_server():
		_handle_token_click(token)
	else:
		var index := tokens.get_children().find(token)
		_rpc_request_token_click.rpc_id(1, index)

func _attach_token_signals(token: Token) -> void:
	token.mouse_off.connect(_on_token_mouse_exited)
	token.mouse_over.connect(_on_token_mouse_entered)
	token.clicked.connect(_on_token_clicked)

func _ready() -> void:
	if not Engine.is_editor_hint():
		for token in tokens.get_children():
			_attach_token_signals(token)
	_setup_tokens()
