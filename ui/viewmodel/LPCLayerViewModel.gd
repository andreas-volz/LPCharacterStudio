class_name LPCLayerViewModel
extends RefCounted

class PaletteInfo:
	var palette_name: String
	var material_domain: String
	var palette_colors: PackedColorArray = []
	var push_star: bool

var satf_sprite_preview_resource: SATFSpriteResource
var type_name: String
var asset_reference_base_path: String
var display_name: String
var palette_info_array: Array[PaletteInfo] = []
var visible_layer_indices: Array[int] = []
