class_name SheetReference
extends RefCounted

## Represents a reference to a single sheet

var type_name: String  # the type_name is used in the SheetCollection Dictionary as key
var asset_reference: AssetReference
var _palette_selections: Dictionary  # key=LPCPaletteSelection.material_domain:String, value=LPCPaletteSelection

## Initialize the reference; defaults to empty strings
## this ensures the input data is cloned while construction
func _init(type_name_param: String = "", asset_reference_param: AssetReference = AssetReference.new(), palette_selections_param: Array[LPCPaletteSelection] = []) -> void:
	type_name = type_name_param
	asset_reference = asset_reference_param.clone()
	for palette_selection: LPCPaletteSelection in palette_selections_param:
		register_palette_selection(palette_selection.clone())

func register_palette_selection(palette_selection: LPCPaletteSelection) -> void:
	_palette_selections[palette_selection.material_domain] = palette_selection

## Returns the LPCPaletteSelection for the given material_domain.
## The returned object is a direct reference to the internal state.
## If not found return the fallback (which is null by default)
func get_palette_selection(material_domain: String, fallback: LPCPaletteSelection = null) -> LPCPaletteSelection:
	if _palette_selections.has(material_domain):
		return _palette_selections[material_domain]
	return fallback

## Returns an Array of all keys currently stored.
func get_palette_selections_domains() -> Array[String]:
	return SATFUtils.array_to_array_string(_palette_selections.keys()) 

func get_palette_selections() -> Array[LPCPaletteSelection]:
	var array: Array[LPCPaletteSelection] = []
	for elem: LPCPaletteSelection in _palette_selections.values():
		array.append(elem)
	return array
	
	
## creates a deep copy of the SheetReference (to modify it as a new sheet)
func clone() -> SheetReference:
	var new_ref := SheetReference.new(type_name, asset_reference, get_palette_selections())
	return new_ref

## Returns true if the reference is valid
func is_valid() -> bool:
	if asset_reference == null:
		return false
	
	return type_name != "" #and (asset_reference.variant.has_value() or not _palette_selections.is_empty())

func from_dict(dict: Dictionary) -> bool:
	var result: bool = true
	
	if dict.has("type_name"):
		type_name = dict["type_name"]
	else:
		push_warning("no 'type_name' in Dictionary")
		result =  false
		
	if dict.has("asset_reference"):
		result = asset_reference.from_dict(dict["asset_reference"])
	else:
		push_warning("no 'asset_reference' in Dictionary")
		result =  false
		
	if dict.has("palette_selections"):
		var palette_selections = dict["palette_selections"]
		if palette_selections is Array:
			_palette_selections.clear()
			for pal_dict in palette_selections:
				if pal_dict is Dictionary:
					var palette_selection := LPCPaletteSelection.new()
					palette_selection.from_dict(pal_dict)
					register_palette_selection(palette_selection)
		
	return result

func to_dict() -> Dictionary:
	var dict := {}
	dict["type_name"] = type_name
	dict["asset_reference"] = asset_reference.to_dict()
	dict["palette_selections"] = []
	for palette_selection: LPCPaletteSelection in get_palette_selections():
		dict["palette_selections"].append(palette_selection.to_dict())
	return dict
