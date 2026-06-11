class_name LPCPaletteCollectionTarget
extends RefCounted

## References a target palette collection used during palette selection
## and compatibility resolution.
##
## A target consists of a collection identifier and an optional material
## domain constraint. The material domain specifies where a palette should
## be resolved within the palette hierarchy.
##
## This class does not contain palette data. It only identifies where a
## palette collection should be looked up.

## Optional material domain indicating the target color/material area this collection
## applies to (e.g. body, eye, cloth).
## If not defined the default from the specified colection is used.
var material_domain := OptionalString.new()

## Identifier of the palette collection to be resolved (e.g. ULPC, LPCR).
## This value is used as a lookup key within the palette catalog.
var collection: String

func _init(domain_param: String = "", collection_param: String = ""):
	if not domain_param.is_empty():
		material_domain.set_value(domain_param)
	collection = collection_param
	
func from_dict(dict: Dictionary) -> bool:
	var result: bool = true
	
	if dict.has("material_domain"):
		material_domain.set_value(dict["base_path"])
		
	if dict.has("collection"):
		collection = dict["collection"]
	else:
		push_warning("no 'collection' in Dictionary")
		result =  false
		
	return result
	
func to_dict() -> Dictionary:
	var dict := {}
	if material_domain.has_value():
		dict["material_domain"] = material_domain.get_or()
	dict["collection"] = collection
	return dict
