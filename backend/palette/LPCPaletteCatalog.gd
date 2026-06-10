class_name LPCPaletteCatalog
extends RefCounted

## Represents the complete palette catalog available to the LPC system.
##
## The catalog acts as the root aggregate for palette-related data loaded
## from ULPC sources. It contains palette domains, collections, variants,
## and compatibility information required to resolve palette selections.
##
## The catalog is primarily used during import and editor workflows.
## Runtime systems typically consume normalized SATF palette data instead
## of accessing the catalog directly.
##
## A catalog may contain multiple collections originating from different
## palette sets (e.g. ULPC, LPCR) and provides the lookup foundation for
## palette resolution and compatibility checks.

# TODO: overcomplicated, use Dictioanry for direct access
var _domains_index: Dictionary = {} # key=materials_id:String, value=material:int (index in _materials)
var _domains: Array[LPCPaletteDomain] # never insert anything direct - use add_palette_material()

func add_palette_domain(palette_domain: LPCPaletteDomain):
	var palette_domain_id: String = palette_domain.id
	_domains_index[palette_domain_id] = _domains.size()
	_domains.append(palette_domain)

func get_domains() -> Array[LPCPaletteDomain]:
	return _domains
	
func has_domain(material_id: String) -> bool:
	if _domains_index.has(material_id):
		return true
	return false
	
func get_domain(material_id: String) -> LPCPaletteDomain:
	if has_domain(material_id):
		var material_index := get_domain_index(material_id)
		if material_index != -1:
			return _domains[material_index]
	# TODO: think about to implement this also with fallback=null design and remove has_domain()
	return LPCPaletteDomain.new() # return empty object
	
## return the material_index or '-1' if not found
func get_domain_index(material_id: String) -> int:
	return _domains_index.get(material_id, -1)
