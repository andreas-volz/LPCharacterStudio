class_name LPCPaletteDomain
extends RefCounted

## Represents a material domain within the LPC palette system.
##
## A material domain groups related palette data and defines the semantic
## area a palette applies to, such as body, eye, cloth, or similar domains.
##
## The term "material domain" originates from the ULPC palette model and
## should not be confused with Godot materials or rendering concepts.
##
## Domains provide the primary organizational structure for palette
## collections and are used during palette lookup and compatibility
## resolution.

## Unique identifier of the material domain (e.g. body, eye, cloth).
var id: String

## Human-readable label used for editor/UI representation.
var label: String

## Optional description explaining the purpose or semantics of this domain.
var description: String

## Default palette collection (LCPPaletteCollection name) used when no explicit 
## selection is provided.
## This defines the fallback collection for this material domain.
var default_collection: String

## Default palette variant used as the base PaletteVariant for this domain.
## A PaletteVariant represents a named source palette definition (e.g. "light", "white")
## that defines the initial color set before any recoloring or overrides are applied.
var base_variant: String # base PaletteVariant name

# TODO think about if this is overcomplicated and if not just a Dictionary that holds the data is enough
var _collections_index: Dictionary = {} # key=collection_id:String, value=collection:int (index in _collections)
var _collections: Array[LPCPaletteCollection] = [] # never insert anything direct - use add_palette_collection()

func add_palette_collection(palette_collection: LPCPaletteCollection):
	var collection_id: String = palette_collection.id
	_collections_index[collection_id] = _collections.size()
	_collections.append(palette_collection)

func get_collections() -> Array[LPCPaletteCollection]:
	return _collections
	
## The returned object is a direct reference to the internal state.
## If not found return the fallback (which is null by default)
func get_collection(collection_id: String, fallback: LPCPaletteCollection = null) -> LPCPaletteCollection:
	if _collections_index.has(collection_id):
		var collection_index := get_collection_index(collection_id)
		if collection_index != -1:
			return _collections[collection_index]
	return fallback

## return the collection_index or '-1' if not found
func get_collection_index(collection_id: String) -> int:
	return _collections_index.get(collection_id, -1)
