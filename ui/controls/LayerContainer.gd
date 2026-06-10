class_name LayerContainer
extends VBoxContainer

const LAYER_ITEM = preload("uid://d2kuysw5foire")

func update(layer_item_array: Array[LayerViewModel]):
	clear()
	
	for item in layer_item_array:
		var layer_item := LAYER_ITEM.instantiate()
		add_child(layer_item)
		layer_item.update(item)

func clear():
	for child in get_children():
		child.queue_free()
