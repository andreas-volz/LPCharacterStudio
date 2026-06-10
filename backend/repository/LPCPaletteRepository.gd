class_name LPCPaletteRepository
extends RefCounted

## Provides access to palette-related ULPC JSON definitions.
##
## Repository implementations load palette collections, variants,
## compatibility information, and associated metadata from the underlying
## ULPC palette data source.
##
## The repository is intentionally limited to data access responsibilities.
## Interpretation, normalization, and model construction are performed by
## dedicated builder components.

## -------------------------
## Internal properties
## -------------------------
var _vfs: JsonVFS = null

## key=material:String, value: collection: Dictionary
## key=collection:String, value: color_palette: Dictionary
## key=color_palette:String, value: color: String(hex)
var _materials_dict: Dictionary = {}

## key=material:String, value: meta: Dictionary
## key=meta:String, value: <various>
var _materials_meta_dict: Dictionary = {}

## key=collection:String, value: color_palette: Dictionary
## key=color_palette:String, value: color: String(hex)
var _collection_dict: Dictionary = {}

## -------------------------
## Public API
## -------------------------

func load_from_path(path: String):
	_vfs = JsonVFS.new(path)
	_build_materials_dict()
	pass
	
## Returns the full raw dictionary of a palette by palette_path
## No transformation or material_domain-specific processing
func get_raw_palette(palette_path: String) -> Dictionary:
	var palette_dict: Dictionary = {}
	if has_palette(palette_path):
		palette_dict = _vfs.get_index()[palette_path]
	return palette_dict
	
func get_material(material_id: String) -> Dictionary:
	var material_dict: Dictionary = {}
	if _materials_dict.has(material_id):
		material_dict = _materials_dict[material_id]
	return material_dict
	
func get_material_meta(material_id: String) -> Dictionary:
	var material_dict: Dictionary = {}
	if _materials_meta_dict.has(material_id):
		material_dict = _materials_meta_dict[material_id]
	return material_dict
	
## Checks if a palette exists
func has_palette(palette_path: String) -> bool:
	var exists: bool = false
	if _vfs.get_index().has(palette_path):
		exists = true
	return exists

func get_material_list() -> Array[String]:
	return SATFUtils.array_to_array_string(_materials_dict.keys())

				
func _build_materials_dict():
	for material: JsonVFS.TreeNode in _vfs.get_tree().children:
		var material_name: String = material.name
		_materials_dict[material_name] = {}
		_materials_meta_dict[material_name] = {}
		for collection_name in material.dicts:
			if not _is_meta_sheet(collection_name):
				# is a collection
				var collection: Dictionary = material.dicts[collection_name]
				_materials_dict[material_name][collection_name] = collection
				_collection_dict[collection_name] = collection
			else:
				# is a meta description
				var meta: Dictionary = material.dicts[collection_name]
				_materials_meta_dict[material_name] = meta
				
## identify the special meta_<leave.name>.json files
func _is_meta_sheet(name: String) -> bool:
	if name.begins_with("meta_"):
		return true
	return false
