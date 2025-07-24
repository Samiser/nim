extends Control
class_name Token

@onready var texture := $TextureRect

signal mouse_over(token: Token)
signal mouse_off(token: Token)
signal clicked(token: Token)

var highlighted = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func highlight(state: bool):
	highlighted = state

func _process(delta: float) -> void:
	if highlighted:
		texture.material.blend_mode = 1
	else:
		texture.material.blend_mode = 0

func _ready() -> void:
	texture.material = texture.material.duplicate()
	mouse_entered.connect(func() -> void: mouse_over.emit(self))
	mouse_exited.connect(func() -> void: mouse_off.emit(self))
