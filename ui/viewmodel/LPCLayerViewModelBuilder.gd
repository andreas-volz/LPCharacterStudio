class_name LPCLayerViewModelBuilder
extends RefCounted

static func build(sheet_collection: SheetCollection, lpc_satf_layer_trace_map: LPCSATFLayerCollectionTraceMap , satf_sprite_resource: SATFSpriteResource) -> Array[LPCLayerViewModel]:
	var lpc_layer_view_model_array: Array[LPCLayerViewModel] = []
	
	for sheet: SheetReference in sheet_collection.get_sheets():
		var lpc_layer_view_model := LPCLayerViewModel.new()
		var grid_layer_data_array: Array[GridLayerData] = lpc_satf_layer_trace_map.sheet_reference_to_grid_layer_data_array[sheet]
		if grid_layer_data_array.is_empty():
			# if there's no layers move on
			continue
		var grid_layer_data_front: GridLayerData = grid_layer_data_array.front()
		
		lpc_layer_view_model.type_name = sheet.type_name
		lpc_layer_view_model.asset_reference_base_path = sheet.asset_reference.base_path
		lpc_layer_view_model.satf_sprite_preview_resource = satf_sprite_resource
		lpc_layer_view_model.display_name = ApplicationContext.lpc_repository.get_name(sheet.asset_reference.base_path)
		
		if lpc_satf_layer_trace_map.sheet_reference_to_palette_trace_map_array.has(sheet):
			var lpc_satf_palette_trace_map_array: Array[LPCSATFPaletteTraceMap] = lpc_satf_layer_trace_map.sheet_reference_to_palette_trace_map_array[sheet]
			
			# in this special case it's ok to access the front() object and use it for UI display
			# in the LPC case all palette information from the SATF flattened layers are the same!
			var lpc_satf_palette_trace_map: LPCSATFPaletteTraceMap = lpc_satf_palette_trace_map_array.front()
			
			# store all palette information in the view model
			for palette_binding: PaletteBinding in grid_layer_data_front.palette_bindings:
				
				#var palette_binding: PaletteBinding = lpc_satf_palette_trace_map.lpc_palette_selection_to_palette_binding[palette_selection]
				var palette_selection: LPCPaletteSelection = lpc_satf_palette_trace_map.palette_binding_to_lpc_palette_selection[palette_binding]
				var palette_info := LPCLayerViewModel.PaletteInfo.new()
				palette_info.material_domain = palette_selection.material_domain
			
				for hex_color in palette_binding.target_palette.colors:
					palette_info.palette_colors.append(Color(hex_color))
					
				# set the "push star" for all palettes with the PUSH info
				if palette_selection.palette_resolve_rule == LPCPaletteSelection.PaletteResolveRule.PUSH:
					palette_info.push_star = true
					
				lpc_layer_view_model.palette_info_array.append(palette_info)
				
		# store which layers should be visible to represent the layer icon
		for grid_layer_data: GridLayerData in grid_layer_data_array:
			var layer_index: int = ApplicationContext.main_grid_sprite_composition.grid_layer_collection.get_layer_index_from_id(grid_layer_data.layer_id.get_or())
			lpc_layer_view_model.visible_layer_indices.append(layer_index)
			
		lpc_layer_view_model_array.append(lpc_layer_view_model)
		
		# for now sort the view list by type_name in the UI
		lpc_layer_view_model_array.sort_custom(func(a: LPCLayerViewModel, b: LPCLayerViewModel):
			return a.type_name < b.type_name
		)
		
	return lpc_layer_view_model_array
