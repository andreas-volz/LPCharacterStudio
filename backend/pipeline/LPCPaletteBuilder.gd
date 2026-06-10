class_name LPCPaletteBuilder
extends RefCounted

## Resolves LPC palette compatibility information into runtime-ready
## palette bindings.
##
## This builder contains the LPC-specific palette resolution logic and
## acts as the boundary between the LPC palette model and the SATF
## recoloring model.
##
## During the build process, palette compatibility definitions are
## evaluated against a sheet reference and resolved through the palette
## catalog. Collection targets, material domains, default variants,
## compatibility rules, and palette metadata are interpreted here.
##
## The goal of this builder is to isolate LPC-specific complexity and
## produce a clean array of PaletteBinding objects for the next pipeline
## stage.
##
## Consumers of the resulting bindings should not need to understand
## LPC palette collections, compatibility definitions, palette targets,
## or ULPC-specific lookup rules.

var _palette_catalog: LPCPaletteCatalog

func _init(_palette_catalog_param: LPCPaletteCatalog) -> void:
	_palette_catalog = _palette_catalog_param

## here all the dirty LPC checks and handling could happen
## if everything is successful then return the clean mapping for the next pipeline step
func build(sheet_reference: SheetReference, palette_compatibility_array: Array[LPCPaletteCompatibility]) -> LPCPaletteBuildResult:
	var lpc_palette_build_result := LPCPaletteBuildResult.new()
	var lpc_satf_palette_trace_map := LPCSATFPaletteTraceMap.new()
	var palette_binding_array: Array[PaletteBinding] = []
	lpc_palette_build_result.palette_binding = palette_binding_array
	lpc_palette_build_result.lpc_satf_palette_trace_map = lpc_satf_palette_trace_map
	
	var palette_compatibility_index: Dictionary = _build_palette_compatibility_index(palette_compatibility_array)
	var palette_selections_domains: Array[String] = sheet_reference.get_palette_selections_domains()
	var need_default_palette_domains: Array[String] = _identify_palette_domains_default_needs(SATFUtils.array_to_array_string(palette_compatibility_index.keys()), palette_selections_domains)
	
	# build all PaletteBinding which are default for this Asset and *NOT* in the SheetReference
	for need_palette_material_domain: String in need_default_palette_domains:
		var palette_binding := PaletteBinding.new()
		var palette_domain: LPCPaletteDomain = _palette_catalog.get_domain(need_palette_material_domain)
		
		var palette_compatibility: LPCPaletteCompatibility = palette_compatibility_index[need_palette_material_domain]
		
		# source and target is the same for the default case
		var source_collection: LPCPaletteCollection = palette_domain.get_collection(palette_compatibility.base_collection.get_or(palette_domain.default_collection))
		var source_base_variant: PaletteVariant = source_collection.get_variant(palette_compatibility.base_variant.get_or(palette_domain.base_variant))
		var target_base_variant: PaletteVariant = source_base_variant
		
		# this is the implementation to direct take over the source color from the LPC Json instead of a palette definition
		if palette_compatibility.palette_source.is_empty():
			palette_binding.source_colors = source_base_variant.colors
		else:
			palette_binding.source_colors = palette_compatibility.palette_source
		
		palette_binding.target_palette = target_base_variant
		
		# construct a default LPCPaletteSelection as it would look like constructed by the material defautls
		var palette_selection := LPCPaletteSelection.new(need_palette_material_domain, LPCPaletteCollectionTarget.new(need_palette_material_domain, source_collection.id), source_base_variant.id)
		
		# build the UI (and debug) mapping between the LPC and SATF layers
		# this allows in the UI to display screens of mixed data aggregations
		lpc_satf_palette_trace_map.lpc_palette_selection_to_palette_binding[palette_selection] = palette_binding
		lpc_satf_palette_trace_map.palette_binding_to_lpc_palette_selection[palette_binding] = palette_selection
		
		palette_binding_array.append(palette_binding)
	
	# calculate the PaletteBinding which are explicit in the SheetReference
	for palette_selection: LPCPaletteSelection in sheet_reference.get_palette_selections():
		# the material_domain has to exist in the selected SheetReference AND in the assets PaletteCompatibility to work
		if _palette_catalog.has_domain(palette_selection.material_domain) and palette_compatibility_index.has(palette_selection.material_domain):
			var palette_binding := PaletteBinding.new()
			var palette_domain: LPCPaletteDomain = _palette_catalog.get_domain(palette_selection.material_domain)
			
			var palette_compatibility: LPCPaletteCompatibility = palette_compatibility_index[palette_selection.material_domain]
			var source_collection: LPCPaletteCollection = palette_domain.get_collection(palette_compatibility.base_collection.get_or(palette_domain.default_collection))
				 
			var target_collection: LPCPaletteCollection
			if palette_selection.target_collection.material_domain.has_value():
				var all_material: LPCPaletteDomain = _palette_catalog.get_domain(palette_selection.target_collection.material_domain.get_or())
				target_collection = all_material.get_collection(palette_selection.target_collection.collection)
			else:
				target_collection = palette_domain.get_collection(palette_selection.target_collection.collection)
			
			var base_variant: PaletteVariant = source_collection.get_variant(palette_compatibility.base_variant.get_or(palette_domain.base_variant))
			var target_variant: PaletteVariant = target_collection.get_variant(palette_selection.variant)
			
			# this is the implementation to direct take over the source color from the LPC Json instead of a palette definition
			if palette_compatibility.palette_source.is_empty():
				palette_binding.source_colors = base_variant.colors
			else:
				palette_binding.source_colors = palette_compatibility.palette_source
				
			palette_binding.target_palette = target_variant
				
			palette_binding_array.append(palette_binding)
			
			# build the UI (and debug) mapping between the LPC and SATF layers
			# this allows in the UI to display screens of mixed data aggregations
			lpc_satf_palette_trace_map.lpc_palette_selection_to_palette_binding[palette_selection] = palette_binding
			lpc_satf_palette_trace_map.palette_binding_to_lpc_palette_selection[palette_binding] = palette_selection

	
	return lpc_palette_build_result

func _build_palette_compatibility_index(palette_compatibility_array: Array[LPCPaletteCompatibility]) -> Dictionary:
	var dict: Dictionary = {}
	
	for palette_compatibility: LPCPaletteCompatibility in palette_compatibility_array:
		dict[palette_compatibility.material_domain] = palette_compatibility
	
	return dict

func _identify_palette_domains_default_needs(compatible_domains: Array[String], selected_domains: Array[String]) -> Array[String]:
	var default_needs: Array[String] = []
	
	default_needs = SATFUtils.array_to_array_string(ArrayOperations.difference(compatible_domains, selected_domains))
	
	return default_needs
