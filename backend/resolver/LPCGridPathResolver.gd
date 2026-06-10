class_name LPCGridPathResolver
extends GridPathResolver

## -----------------------------
## Internal data
## -----------------------------

## those "virtual" animation image folders are mapped to specific real folders
var _animation_folder_remap: Dictionary = {
	"combat_idle": ["combat"],
	"thrust": ["watering"],
	"backslash": ["1h_slash", "1h_backslash"],
	"halfslash": ["1h_halfslash"]
}

## the reverse dict of animation_folder_remap for easy access
var _animation_folder_reverse_remap := {}

var _graphic_root_path: String

## -----------------------------
## Constructor / Initialization
## -----------------------------

func _init() -> void:
	_build_animation_folder_reverse_remap()

## -----------------------------
## Public API
## -----------------------------

func resolve(layer_data: GridLayerData, animation_name: StringName) -> OptionalString:
	var resolved_path: String
	
	var remapped_animation_name := _remap_shared_image_animation_path(animation_name)
	
	resolved_path = layer_data.asset_reference.base_path
	
	# this seems to be a reliable detector for custom_animations
	if layer_data.animations.size() > 1:
		resolved_path += "/" + remapped_animation_name
	
	# if palette_selections is empty then the old variant colored PNGs are used (recolors feature)
	if layer_data.palette_bindings.is_empty():
		if layer_data.asset_reference.variant.has_value():
			resolved_path += "/" + layer_data.asset_reference.variant.get_or()
	
	var optional_resolved_path := OptionalString.new()
	if not _graphic_root_path.is_empty():
		var check_path = _graphic_root_path + "/" + resolved_path + ".png"
		if not UniversalTextureLoader.exists(check_path):
			# TODO: don't use push_warning, better write some log files!
			push_warning("Early loading Texture check failed! Ignoring: ", check_path)
		else:
			optional_resolved_path.set_value(resolved_path)
		
	return optional_resolved_path
	

## -----------------------------
## Internal helpers
## -----------------------------
	
# remap the folder with animations as some share images in the same folder
func _remap_shared_image_animation_path(animation_name: String) -> String:
	if _animation_folder_reverse_remap.has(animation_name):
		return _animation_folder_reverse_remap[animation_name]
	return animation_name
	
# helper function to build a folder reverse remap index
func _build_animation_folder_reverse_remap():
	for key in _animation_folder_remap:
		for value in _animation_folder_remap[key]:
			_animation_folder_reverse_remap[value] = key
