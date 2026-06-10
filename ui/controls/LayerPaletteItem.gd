class_name LayerPaletteItem
extends HBoxContainer

func set_palette_name(pname: String):
	%PaletteName.text = pname

func set_palette_colors(colors: PackedColorArray):
	%PaletteDisplay.colors = colors

func set_push_star(value: bool):
	%PushStarButton.set_pressed(value)
