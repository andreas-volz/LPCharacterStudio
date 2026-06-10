class_name LPCAssetRepository
extends RefCounted

## Provides access to LPC asset definitions stored in ULPC JSON data.
##
## Repository implementations are responsible for loading and exposing
## raw asset metadata without applying palette resolution or runtime
## transformations.
##
## The repository acts as an infrastructure component that isolates file
## system and JSON parsing concerns from the domain model.
##
## Asset data retrieved from this repository is typically consumed by
## builders that construct higher-level LPC model objects.

## -------------------------
## Internal properties
## -------------------------
var _vfs: JsonVFS = null

## store the combination of all {type_name: String}->{relative_path: String}->[variant: String]
## this is e.g. used for the randomizer
var _sheet_variant_dict: Dictionary = {}

## -------------------------
## Public API
## -------------------------

class SheetCategoryTreeViewModel:
	var name: String = ""
	var display_name: String = ""
	var relative_path: String = ""                    # the realtive path from root to this node
	var children: Array[SheetCategoryTreeViewModel] = []
	var is_sheet: bool = false

func load_from_path(path: String):
	_vfs = JsonVFS.new(path)
	_build_sheet_variant_dict(_vfs._json_tree)

## Returns a lightweight tree for use e.g. in UI Tree
func get_sheet_category_tree_model(body_type: String) -> SheetCategoryTreeViewModel:
	var tree_model: SheetCategoryTreeViewModel = _build_sheet_category_tree_view_model(body_type, _get_json_tree())
	return tree_model

## Checks if a sheet exists
func has_sheet(sheet_path: String) -> bool:
	var exists: bool = false
	if _vfs.get_index().has(sheet_path):
		exists = true
	return exists

## Returns the full raw dictionary of a sheet by sheet_path
## No transformation or domain-specific processing
func get_raw_sheet(sheet_path: String) -> Dictionary:
	var sheet_dict: Dictionary = {}
	if has_sheet(sheet_path):
		sheet_dict = _vfs.get_index()[sheet_path]
	return sheet_dict

func get_sheet_type_names() -> Array:
	return _sheet_variant_dict.keys()

func get_sheet_paths(type_name: String) -> Array:
	if _sheet_variant_dict.has(type_name):
		return _sheet_variant_dict[type_name].keys()
	return []

func get_name(sheet_path: String) -> String:
	var sheet: Dictionary = get_raw_sheet(sheet_path)
	if sheet:
		if sheet.has("name"):
			return sheet["name"]
	return ""

func get_type_name(sheet_path: String) -> String:
	var sheet: Dictionary = get_raw_sheet(sheet_path)
	if sheet:
		if sheet.has("type_name"):
			return sheet["type_name"]
	return ""

## check if the specified sheet has a section "variant"
func has_variants(sheet_path: String):
	var sheet: Dictionary = get_raw_sheet(sheet_path)
	if sheet:
		if sheet.has("variants"):
			return true
	return false

## Returns all variant names for a given sheet_path
func get_variants(sheet_path: String) -> Array:
	var sheet: Dictionary = get_raw_sheet(sheet_path)
	if sheet:
		if sheet.has("variants"):
			var variants = sheet["variants"]
			if variants is Array:
				return variants
	return []

## check if the specified sheet has a section "recolors"
func has_recolors(sheet_path: String):
	var sheet: Dictionary = get_raw_sheet(sheet_path)
	if sheet:
		if sheet.has("recolors"):
			return true
	return false
		
## parse the "recolors" section from the ULPC Json into a helpful structure
func get_palette_compatibility_array(sheet_dict: Dictionary) -> Array[LPCPaletteCompatibility]:
	var palette_compatibility_array: Array[LPCPaletteCompatibility] = []
	var recolors_array: Array[Dictionary] = []
	# test how many colors exist in the recolors dict of the JSON sheet
	var color_test := true
	var color_num := 0
	if sheet_dict.has("recolors"):
		var recolors_dict: Dictionary = sheet_dict["recolors"]
		while(color_test):
			var color_name := "color_" + str(color_num + 1)
			if recolors_dict.has(color_name):
				var color_dict: Dictionary = recolors_dict[color_name]
				recolors_array.append(color_dict)
				var palette_compatibility: LPCPaletteCompatibility = _parse_recolors_dict(color_dict)
				palette_compatibility_array.append(palette_compatibility)
				color_num += 1
			else:
				color_test = false
				if color_num == 0:
					recolors_array.append(recolors_dict)
					var palette_compatibility: LPCPaletteCompatibility = _parse_recolors_dict(recolors_dict)
					palette_compatibility_array.append(palette_compatibility)
				
	return palette_compatibility_array

## this makes the not good iterable layer Dictionaries available in an Array
func get_layers_array(sheet_dict: Dictionary) -> Array[Dictionary]:
	var layers_array: Array[Dictionary] = []
	# test how many layers exist in the JSON sheet
	var layer_test := true
	var layer_num := 0
	while(layer_test):
		var layer_name := "layer_" + str(layer_num + 1)
		if sheet_dict.has(layer_name):
			var layer_dict: Dictionary = sheet_dict[layer_name]
			layers_array.append(layer_dict)

			layer_num += 1
		else:
			layer_test = false
	return layers_array

## -------------------------
## Internal API
## -------------------------

## Access the raw JsonVFS tree
func _get_json_tree() -> JsonVFS.TreeNode:
	return _vfs.get_tree()

## Access the flat index of all sheets
func _get_json_index() -> Dictionary:
	return _vfs.get_index()

func _parse_recolors_dict(recolors_dict: Dictionary) -> LPCPaletteCompatibility:
	var palette_compatibility := LPCPaletteCompatibility.new()
	
	if recolors_dict.has("material"):
		palette_compatibility.material_domain = recolors_dict["material"]
		
	if recolors_dict.has("base"):
		var base_variant = recolors_dict["base"]
		if base_variant != null:
			var base: String = base_variant
			var base_split := base.split(".")
			if base_split.size() == 1:
				palette_compatibility.base_variant.set_value(base_split[0])
			if base_split.size() == 2:
				palette_compatibility.base_collection.set_value(base_split[0])
				palette_compatibility.base_variant.set_value(base_split[1])
		
	if recolors_dict.has("palettes"):
		for palette_collection: String in recolors_dict["palettes"]:
			var palette_collection_split := palette_collection.split(".")
			var palette_compatiblility := LPCPaletteCollectionTarget.new()
			if palette_collection_split.size() == 1:
				palette_compatiblility.collection = palette_collection_split[0]
			elif palette_collection_split.size() == 2:
				palette_compatiblility.material_domain.set_value(palette_collection_split[0])
				palette_compatiblility.collection = palette_collection_split[1]
			else:
				push_error("unknown Palette scheme!")

			palette_compatibility.collections.append(palette_compatiblility)
			
	if recolors_dict.has("source"):
		palette_compatibility.palette_source = SATFUtils.array_to_array_string(recolors_dict["source"])
		
	if recolors_dict.has("type_name"):
		palette_compatibility.type_name.set_value(recolors_dict["type_name"])
		
	if recolors_dict.has("label"):
		palette_compatibility.label.set_value(recolors_dict["label"])
		
	return palette_compatibility

func _build_sheet_category_tree_view_model(body_type:String, tree: JsonVFS.TreeNode, leave: SheetCategoryTreeViewModel = null):
	if leave == null:
		leave = SheetCategoryTreeViewModel.new()
		leave.name = "root"
		leave.display_name = "Root"
	
	var sorted_tree_children: Array = tree.children
	sorted_tree_children.sort()
	for dir: JsonVFS.TreeNode in sorted_tree_children:
		var sub_leave := SheetCategoryTreeViewModel.new()
		leave.children.append(sub_leave)
		# set the capitalized sub folder name as fallback UI name
		# later below check if there is a meta_<leave.name>.json with a "label" and overwrite it
		sub_leave.name = dir.name
		sub_leave.display_name = dir.name.capitalize()
		sub_leave.is_sheet = false
		sub_leave.relative_path = dir.relative_path
		_build_sheet_category_tree_view_model(body_type, dir, sub_leave)
		
	for dict_container: Dictionary in tree.get_sorted_dicts():
		var sheet_dict_name: String = dict_container.name # the JSON file name without .json
		var sheet_dict: Dictionary = dict_container.dict
		
		if _is_meta_sheet(sheet_dict_name):
			# use "label" property if available to overwrite the name of the current folder
			if sheet_dict.has("label"):
				leave.display_name = sheet_dict["label"]
		else: 
			var sub_leave := SheetCategoryTreeViewModel.new()
			
			if _has_body_type_in_layers(sheet_dict, body_type):
				leave.children.append(sub_leave)
				sub_leave.name = sheet_dict_name
				sub_leave.display_name = sheet_dict.name
				sub_leave.is_sheet = true
				sub_leave.relative_path = leave.relative_path + "/" + sheet_dict_name
		
	return leave

func _build_sheet_variant_dict(tree: JsonVFS.TreeNode):
	for dir: JsonVFS.TreeNode in tree.children:
		_build_sheet_variant_dict(dir)
		
	for dict_name: String in tree.dicts:
		if not _is_meta_sheet(dict_name):
			var dict: Dictionary = tree.dicts[dict_name]
			# TODO: save the recolors dict?
			if dict.has("variants"):
				if not _sheet_variant_dict.has(dict.type_name):
					_sheet_variant_dict[dict.type_name] = {}
				var path_id := tree.relative_path + "/" + dict_name
				_sheet_variant_dict[dict.type_name][path_id] = dict.variants

## check if the sheet Dictionary is compatible to a specific layer_type
func _has_body_type_in_layers(sheet_dict: Dictionary, body_type: String) -> bool:
	# test how many layers exist in the JSON sheet
	var layer_test := true
	var layer_num := 0
	while(layer_test):
		var layer_name := "layer_" + str(layer_num + 1)
		if sheet_dict.has(layer_name):
			for key_name in sheet_dict[layer_name]:
				if key_name == body_type:
					return true
			
			layer_num += 1
		else:
			layer_test = false
		
	return false
	
# Helper for searching sheets by type, tags, or metadata
#func _search_sheets(criteria: Dictionary) -> Array[JsonVFS.TreeNode]:
	#return []

## identify the special meta_<leave.name>.json files
func _is_meta_sheet(name: String) -> bool:
	if name.begins_with("meta_"):
		return true
	return false
