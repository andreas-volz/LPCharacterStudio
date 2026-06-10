class_name LayerItem
extends PanelContainer

var _layer_data: LayerViewModel

@onready var z_index_label: Label = %ZIndexLabel
@onready var name_label: Label = %NameLabel
@onready var path_label: Label = %PathLabel

func update(layer_data: LayerViewModel):
	name_label.text = "[" + layer_data.group + "]"
	path_label.text = layer_data.layer_id
	z_index_label.text = "z=" + str(layer_data.z_index)
	
	_layer_data = layer_data

func _on_visible_button_button_down() -> void:
	Events.change_layer_visibility_by_id.emit(_layer_data.layer_id, false)


func _on_visible_button_button_up() -> void:
	Events.change_layer_visibility_by_id.emit(_layer_data.layer_id, true)
