class_name LayerViewModelBuilder
extends RefCounted

static func build(grid_layer_collection_param: GridLayerCollection) -> Array[LayerViewModel]:
	var layer_view_model_array: Array[LayerViewModel] = []
	
	for grid_layer: GridLayerData in grid_layer_collection_param.get_layers():
		var layer_view_model := LayerViewModel.new()
		#layer_view_model.slot = grid_layer.slot.get_or()
		layer_view_model.group = grid_layer.group.get_or()
		layer_view_model.z_index = grid_layer.z_index.get_or()
		layer_view_model.layer_id = grid_layer.layer_id.get_or()
		layer_view_model_array.append(layer_view_model)
			
		# sort the view list by z_index in the UI
		layer_view_model_array.sort_custom(func(a: LayerViewModel, b: LayerViewModel):
			return a.z_index > b.z_index
		)
		
	return layer_view_model_array
