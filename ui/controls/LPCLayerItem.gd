class_name LPCLayerItem
extends PanelContainer

const LAYER_PALETTE_ITEM = preload("uid://55qyur5qalsr")

var _layer_data: LPCLayerViewModel

@onready var type_name_label: Label = %TypeNameLabel
@onready var name_label: Label = %NameLabel
@onready var layer_preview: SATFSpriteControl = %LayerPreview
@onready var layer_palette_container: VBoxContainer = %LayerPaletteContainer

func _ready() -> void:
	layer_preview.satf_sprite.graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path()

func update(layer_data: LPCLayerViewModel):
	type_name_label.text = "[" + layer_data.type_name + "]"
	name_label.text = layer_data.display_name
	layer_preview.satf_sprite.satf_sprite_resource = layer_data.satf_sprite_preview_resource
	
	for palette_info: LPCLayerViewModel.PaletteInfo in layer_data.palette_info_array:
		var layer_palette_item: LayerPaletteItem = LAYER_PALETTE_ITEM.instantiate()
		layer_palette_item.set_palette_name(palette_info.material_domain)
		layer_palette_item.set_palette_colors(palette_info.palette_colors)
		layer_palette_item.set_push_star(palette_info.push_star)
		layer_palette_container.add_child(layer_palette_item)
		
	layer_preview.satf_sprite.set_all_visible(false)
	for layer_index: int in layer_data.visible_layer_indices:
		layer_preview.satf_sprite.set_layer_visible(true, layer_index)
		
	
	
	_layer_data = layer_data

func _on_visible_button_toggled(toggled_on: bool) -> void:
	Events.change_layer_visibility_by_type_name.emit(_layer_data.type_name, !toggled_on)

func _on_remove_button_pressed() -> void:
	Events.remove_type_name_from_collection.emit(_layer_data.type_name)
