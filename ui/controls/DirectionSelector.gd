class_name DirectionSelector
extends GridContainer

signal direction_pressed(direction: ButtonDirection)

enum ButtonDirection { # order is important
	UP,
	LEFT,
	DOWN,
	RIGHT
}

@onready var up_button: Button = $UpButton
@onready var left_button: Button = $LeftButton
@onready var right_button: Button = $RightButton
@onready var down_button: Button = $DownButton

## if called with state=false does disable the button
func enable_button(button: ButtonDirection, state: bool = true):
	match(button):
		ButtonDirection.UP:
			up_button.disabled = !state
		ButtonDirection.LEFT:
			left_button.disabled = !state
		ButtonDirection.DOWN:
			down_button.disabled = !state
		ButtonDirection.RIGHT:
			right_button.disabled = !state
	

func _on_up_button_pressed() -> void:
	direction_pressed.emit(ButtonDirection.UP)


func _on_left_button_pressed() -> void:
	direction_pressed.emit(ButtonDirection.LEFT)


func _on_right_button_pressed() -> void:
	direction_pressed.emit(ButtonDirection.RIGHT)


func _on_down_button_pressed() -> void:
	direction_pressed.emit(ButtonDirection.DOWN)
