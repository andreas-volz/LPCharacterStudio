@tool
class_name PaletteDisplay
extends Control

@export var colors: PackedColorArray

func _ready():
	custom_minimum_size = Vector2(64, 15)

func _draw():
	if colors.is_empty():
		return
		
	var rect := Rect2(Vector2.ZERO, size)

	draw_style_box(
		get_theme_stylebox("panel"),
		rect
	)

	var inner := rect.grow(-1)

	var w := inner.size.x / colors.size()

	for i in colors.size():
		draw_rect(
			Rect2(
				inner.position.x + i * w,
				inner.position.y,
				ceil(w),
				inner.size.y
			),
			colors[i]
		)
