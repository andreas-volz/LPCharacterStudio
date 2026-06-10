class_name LPCLayerContainer
extends VBoxContainer

const LPC_LAYER_ITEM = preload("uid://c0syxgvi4h8hw")


func update(layer_item_array: Array[LPCLayerViewModel]):
	clear()
	
	for layer_item in layer_item_array:
		var layer_item_control := LPC_LAYER_ITEM.instantiate()
		add_child(layer_item_control)
		layer_item_control.update(layer_item)

func clear():
	for child in get_children():
		child.queue_free()
