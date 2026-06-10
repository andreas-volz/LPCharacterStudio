class_name LPCGridLayerCollectionBuilder
extends RefCounted

## -----------------------------
## Public properties
## -----------------------------

## Repository reference (allowed to be set later)
var repository: LPCAssetRepository
var palette_repository: LPCPaletteRepository

# TODO: think about to move ownership of MaterialRegistry local here
var palette_catalog: LPCPaletteCatalog

## -----------------------------
## Internal data
## -----------------------------

var _default_animations := [
	"spellcast",
	"thrust",
	"walk",
	"slash",
	"shoot",
	"hurt",
	"watering",
	"idle",
	"jump",
	"run",
	"sit",
	"emote",
	"climb",
	"combat",
	"1h_slash",
	"1h_backslash",
	"1h_halfslash",
	"backslash",
	"halfslash"
  ]

## -----------------------------
## Constructor / Initialization
## -----------------------------

func _init(repo: LPCAssetRepository = null, pal_repo: LPCPaletteRepository = null) -> void:
	repository = repo
	palette_repository = pal_repo

## -----------------------------
## Public API
## -----------------------------

func create_from_sheet_collection(sheet_collection: SheetCollection, body_type: String) -> LPCGridLayerCollectionBuildResult:
	var lpc_collection_build_result := LPCGridLayerCollectionBuildResult.new()
	var collection := GridLayerCollection.new()
	var lpc_satf_layer_collection_trace_map := LPCSATFLayerCollectionTraceMap.new()
	lpc_collection_build_result.grid_layer_collection = collection
	lpc_collection_build_result.lpc_satf_layer_collection_trace_map = lpc_satf_layer_collection_trace_map

	# each SheetReference describes one composed LPC asset
	for sheet_ref:SheetReference in sheet_collection.get_sheets():
		var lpc_raw_sheet := repository.get_raw_sheet(sheet_ref.asset_reference.base_path)
		var layers_array: Array[Dictionary] = repository.get_layers_array(lpc_raw_sheet)
		
		# read the animations block from lpc_raw_sheet but then put it on each GridLayerData
		# the reason is that in SATF architecture each layer is complete on it's own
		var animations_array: Array = []
		if lpc_raw_sheet.has("animations"):
			animations_array = lpc_raw_sheet["animations"]
		animations_array = ArrayOperations.union_array_merge(animations_array, _default_animations)
			
		# this is needed to create a trace map to later let the UI find which SheetReference has build which GridLayerDatas
		var grid_layer_data_array_for_trace_map: Array[GridLayerData] = []
		var lpc_satf_palette_trace_map_for_layer_trace_map: Array[LPCSATFPaletteTraceMap] = []
		
		for layer_dict: Dictionary in layers_array:
			var grid_layer_data: GridLayerData = null
			
			# add only layers that support the defined body_type
			if layer_dict.has(body_type):
				grid_layer_data = GridLayerData.new()
				var layer_body_type_path: String = layer_dict[body_type]
				layer_body_type_path = layer_body_type_path.trim_suffix("/")
				grid_layer_data.layer_id.set_value(layer_body_type_path)
				
				var custom_animation := OptionalStringName.new()
				if layer_dict.has("custom_animation"):
					custom_animation.set_value(layer_dict["custom_animation"])
				
				if layer_dict.has("zPos"):
					grid_layer_data.z_index.set_value(layer_dict["zPos"])
				else:
					push_warning("The LPC layer has no 'zPos' defined!")
				
				# the SheetReference path maps into what is group on layer level in SATF
				grid_layer_data.group.set_value(sheet_ref.asset_reference.base_path)
				
				# save variant only if activated (e.g. not used in LPC recolor case activated)
				if sheet_ref.asset_reference.variant.has_value():
					var sheet_variant: String = sheet_ref.asset_reference.variant.get_or()
					# some variants have a space but the path an underscore. This is a "bad data" workaround.
					sheet_variant = sheet_variant.replace(" ", "_")
					grid_layer_data.asset_reference.variant.set_value(sheet_variant)
					
				if lpc_raw_sheet.has("recolors"):
					var lcp_palette_builder := LPCPaletteBuilder.new(palette_catalog)
					var palette_compatibility_array: Array[LPCPaletteCompatibility] = repository.get_palette_compatibility_array(lpc_raw_sheet)
					var lpc_palette_build_result: LPCPaletteBuildResult = lcp_palette_builder.build(sheet_ref, palette_compatibility_array)
					var lpc_palette_mapping_array: Array[PaletteBinding] = lpc_palette_build_result.palette_binding
					grid_layer_data.palette_bindings = lpc_palette_mapping_array
					
					# build the UI (and debug) mapping between the LPC and SATF palettes
					# this allows in the UI to display screens of mixed data aggregations
					lpc_satf_palette_trace_map_for_layer_trace_map.append(lpc_palette_build_result.lpc_satf_palette_trace_map)
					
				
				# implementation of the JSON "replace_in_path" feature (e.g. used for face emotions)
				if lpc_raw_sheet.has("replace_in_path"):
					layer_body_type_path = _replace_in_path_feature(sheet_collection, layer_body_type_path, lpc_raw_sheet["replace_in_path"])
				
				grid_layer_data.asset_reference.base_path = layer_body_type_path
				
				var animations_dict: Dictionary = {} 
				## The loop goes over all animations to ensure each layer has the complete number of all asset
				## animations. Even if this is a little more data in memory.
				for animation_name: String in animations_array:
					var grid_anim_layer: GridLayerAnimation = null
#
					if custom_animation.has_value():
						if custom_animation.get_or() == animation_name:
							grid_anim_layer = GridLayerAnimation.new()
					else:
						grid_anim_layer = GridLayerAnimation.new()
#
					if grid_anim_layer != null:
						animations_dict[animation_name] = grid_anim_layer
							
				grid_layer_data.animations = animations_dict
				
				# add this to a temporary array to later put it into the trace map
				grid_layer_data_array_for_trace_map.append(grid_layer_data)
				
				collection.add_layer(grid_layer_data)
			else:
				# This should in normal usage not reach here as the UI only offers body_type combatible
				# assets. But if someone modifies saved Collections it might happen.
				push_warning("Requested 'body_type: %s' not supported in '%s'" % [body_type, sheet_ref.asset_reference.base_path])

		# build the UI (and debug) mapping between the LPC and SATF layers
		# this allows in the UI to display screens of mixed data aggregations
		lpc_satf_layer_collection_trace_map.sheet_reference_to_grid_layer_data_array[sheet_ref] = grid_layer_data_array_for_trace_map
		lpc_satf_layer_collection_trace_map.sheet_reference_to_palette_trace_map_array[sheet_ref] = lpc_satf_palette_trace_map_for_layer_trace_map
	
	return lpc_collection_build_result
	
	
## -----------------------------
## Internal helpers
## -----------------------------
	
# implementation of the JSON "replace_in_path" feature (e.g. used for face emotions)
func _replace_in_path_feature(sheet_collection: SheetCollection, path: String, replace_in_path: Dictionary) -> String:
	var replaced_path: Dictionary = {}
	
	# this works only in case the to be replaced type_name is available in the SheetCollection
	for replace_type_name in replace_in_path:
		var sheet_reference: SheetReference = sheet_collection.get_sheet(replace_type_name)
		if sheet_reference:
			var replace_type_name_dict: Dictionary = replace_in_path[replace_type_name]
			var replace_path := sheet_reference.asset_reference.base_path
			var referenced_name: String = repository.get_name(replace_path)
			referenced_name = referenced_name.replace(" ", "_")
			if replace_type_name_dict.has(referenced_name):
				var fitting_base: String = replace_type_name_dict[referenced_name]
				replaced_path[replace_type_name] = fitting_base
		else:
			push_warning("replace_in_path_feature only work if the type_name part is selected")
	path = _get_replaced_path(path, replaced_path)
	return path

func _get_replaced_path(path: String, path_dict: Dictionary) -> String:
	var result_path: String = path
	
	var regex = RegEx.new()
	# Regex to match placeholders like ${key} inside a string
	# \$
	#   Matches a literal '$' character (escaped because '$' is normally special in regex)
	# \{
	#   Matches the opening curly brace '{' literally
	# ([^}]+)
	#   Capturing group:
	#   - [^}]  : match any character except '}'
	#   - +     : one or more of those characters
	#   this captures the key inside the placeholder (e.g. "head" in "${head}")
	# \}
	#   Matches the closing curly brace '}' literally
	# Overall:
	#   Matches patterns like "${head}" and captures "head" for lookup/replacement
	regex.compile(r"\$\{([^}]+)\}")

	var matches = regex.search_all(path)

	for path_match in matches:
		var key = path_match.get_string(1)
		if path_dict.has(key):
			result_path = result_path.replace(path_match.get_string(0), path_dict[key])
	
	return result_path
