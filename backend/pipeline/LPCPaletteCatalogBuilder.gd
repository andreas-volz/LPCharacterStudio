class_name LPCPaletteCatalogBuilder
extends RefCounted

## Constructs an LPCPaletteCatalog from repository data.
##
## The builder loads palette definitions, collections, variants, and
## compatibility information from ULPC data sources and assembles the
## corresponding LPC model objects.
##
## Parsing, normalization, and model construction responsibilities are
## centralized here to keep repository implementations focused on data
## access concerns.
##
## The resulting catalog serves as the authoritative source of palette
## information for editor and import workflows.

func build_material_registry(palette_repository: LPCPaletteRepository) -> LPCPaletteCatalog:
	var material_registry := LPCPaletteCatalog.new()
	
	for material_name in palette_repository.get_material_list():
		var palette_domain := _build_palette_domain(palette_repository, material_name)
		material_registry.add_palette_domain(palette_domain)
	
	return material_registry

func _build_palette_domain(palette_repository: LPCPaletteRepository, id: String) -> LPCPaletteDomain:
	var palette_domain := LPCPaletteDomain.new()
	palette_domain.id = id
	
	var material_meta_dict = palette_repository.get_material_meta(id)
	if material_meta_dict.has("type"):
		if material_meta_dict["type"] == "material":
			if material_meta_dict.has("label"):
				palette_domain.label = material_meta_dict["label"]
			if material_meta_dict.has("desc"):
				palette_domain.description = material_meta_dict["desc"]
			if material_meta_dict.has("default"):
				palette_domain.default_collection = material_meta_dict["default"]
			if material_meta_dict.has("base"):
				palette_domain.base_variant = material_meta_dict["base"]
	
			var material_dict = palette_repository.get_material(id)
			for collection_id: String in material_dict:
				var collection_dict: Dictionary = material_dict[collection_id]
				
				# trim the material part prefix in the PaletteCollection
				var new_collection_id: String = collection_id.trim_prefix(palette_domain.id + "_")
				var palette_collection := _build_palette_collection(new_collection_id, collection_dict)
				palette_domain.add_palette_collection(palette_collection)
	
	return palette_domain
	
func _build_palette_collection(collection_id: String, collection_dict: Dictionary) -> LPCPaletteCollection:
	var palette_collection := LPCPaletteCollection.new()
	palette_collection.id = collection_id
	
	for palette_id in collection_dict:
		var color_array: Array[String] = SATFUtils.array_to_array_string(collection_dict[palette_id])
		var palette_variant: PaletteVariant = _build_palette_variant(palette_id, color_array)
		palette_collection.add_palette_variant(palette_variant)
	
	return palette_collection
	
func _build_palette_variant(palette_id: String, color_array: Array[String]) -> PaletteVariant:
	var palette_variant := PaletteVariant.new()
	palette_variant.id = palette_id
	var legal_colors := true
	
	for color in color_array:
		if not Color.html_is_valid(color):
			legal_colors = false
			push_error("Color '%s' not valid and so ignore complete palette id '%s' " % [color, palette_id])

	if legal_colors:
		palette_variant.colors = color_array
	
	return palette_variant
