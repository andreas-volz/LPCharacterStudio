class_name LPCPaletteCollection
extends RefCounted

## Represents a palette collection within a material domain.
##
## A collection groups multiple palette variants that share the same
## semantic purpose and color replacement rules. Examples include
## collections such as ULPC or LPCR.
##
## Collections contain the actual palette variant definitions used to
## generate recoloring data. Additional metadata may define default
## variants, base variants, or collection-specific behavior.
##
## This class models palette data itself and should not be confused with
## LPCPaletteCollectionTarget, which only references a collection.

var id: String

# TODO think about if this is overcomplicated and only a Dict is enough...
var _variants_index: Dictionary = {} # key=variants_id:String, value=variants:int (index in _variants)
var _variants: Array[PaletteVariant] = [] # never insert anything direct - use add_palette_variant()

func add_palette_variant(palette_variant: PaletteVariant):
	var variant_id: String = palette_variant.id
	_variants_index[variant_id] = _variants.size()
	_variants.append(palette_variant)

# TODO: rename all with _palette_?

func get_variants() -> Array[PaletteVariant]:
	return _variants
	
func has_variant(variant_id: String) -> bool:
	if _variants_index.has(variant_id):
		return true
	return false
	
func get_variant(variant_id: String) -> PaletteVariant:
	if has_variant(variant_id):
		var variant_index := get_variant_index(variant_id)
		if variant_index != -1:
			return _variants[variant_index]
	return PaletteVariant.new() # return empty object

## return the variant_index or '-1' if not found
func get_variant_index(variant_id: String) -> int:
	return _variants_index.get(variant_id, -1)
