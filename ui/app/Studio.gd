class_name Studio
extends Control

const SETTINGS_WINDOW = preload("uid://r81wbda1t1oc")

var lpc_sheet_definitions_list: Array = []

var lpc_direction := DirectionSelector.ButtonDirection.DOWN
var lpc_direction_array := ["up", "left", "down", "right"] # order is important
var lpc_selected_animation: String

var layer_state_store := LayerStateStore.new()

@onready var sheet_definition_tree: Tree = %SheetDefinitionTree
@onready var body_types: OptionButton = %BodyTypes
@onready var variant_list: HFlowContainer = %VariantList
@onready var satf_animation_player: SATFAnimationPlayer = %SATFAnimationPlayer

@onready var animation_selector: OptionButton = %AnimationSelector
@onready var direction_selector: DirectionSelector = %DirectionSelector

@onready var satf_animation_preview: SATFSprite = %SATFAnimationPreview
@onready var frame_container: FrameTimeline = %FrameContainer

@onready var layer_container: LayerContainer = %LayerContainer # TODO: rename SATFLayerContainer
@onready var lpc_layer_container: LPCLayerContainer = %LPCLayerContainer

@onready var match_body_color_check: CheckBox = %MatchBodyColorCheck
@onready var palette_option: OptionButton = %PaletteOption


func _ready() -> void:
	randomize()
	
	ApplicationContext.init_service()
		
	# TODO: init should be done only if no config found or if messed up to not overwrite user settings
	#_init_default_lpc_path()
	satf_animation_preview.graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path()
	
	ApplicationContext.reset_active_sheet_collection()
	
	fill_animation_selector()
	#configure_directions() # FIXME
	
	# TODO rework the frame change signaling
	satf_animation_preview.animation_frame_changed.connect(_satf_animation_preview_frame_changed)

	var sheet_category_tree_model := ApplicationContext.lpc_repository.get_sheet_category_tree_model(ApplicationContext.body_type)
	fill_category_tree(sheet_category_tree_model)
	
	Events.change_layer_visibility_by_type_name.connect(_on_change_layer_visibility_by_type_name)
	Events.change_layer_visibility_by_id.connect(_on_change_layer_visibility_by_id)
	
	Events.remove_type_name_from_collection.connect(_on_remove_type_name_from_collection)
		
	ApplicationController.apply_sheet_collection_intent.connect(_on_apply_sheet_collection_intent)
	
	create_collection_from_active()
	update_main_preview()
	play_lcp_animation()
	update_lpc_layer_view()
		
	#ResourceSaver.save(satf_sprite_resource, "res://resources/satf_sprite.tres")



func _init_default_lpc_path():
	#var lpc_path := "user://ULPC"
	var lpc_path := "/home/andreas/src/git/ULPC_Recolor/Universal-LPC-Spritesheet-Character-Generator"
	var lpc_sheet_definitions_path := lpc_path + "/sheet_definitions"
	var lpc_spritesheets_path := lpc_path + "/spritesheets"
	var lpc_palette_definitions_path := lpc_path + "/palette_definitions"
	ApplicationContext.lpc_loader_service.set_sheet_defintions_path(lpc_sheet_definitions_path)
	ApplicationContext.lpc_loader_service.set_spritesheets_path(lpc_spritesheets_path)
	ApplicationContext.lpc_loader_service.set_palette_definitions_path(lpc_palette_definitions_path)
	
	
func fill_category_tree(tree_model: LPCAssetRepository.SheetCategoryTreeViewModel, item :TreeItem = null):
	if item == null:
		sheet_definition_tree.clear()
		item = sheet_definition_tree.create_item()
		item.set_text(0, tree_model.display_name)
	
	for leave:LPCAssetRepository.SheetCategoryTreeViewModel in tree_model.children:
		var sub_item := sheet_definition_tree.create_item(item)
		sub_item.set_text(0, leave.display_name)
		sub_item.set_collapsed_recursive(true)
		if leave.is_sheet:
			var metadata_dict = {}
			metadata_dict["relative_path"] = leave.relative_path
			sub_item.set_metadata(0, metadata_dict)
		fill_category_tree(leave, sub_item)

		
## fill the animation selector with animations and at the same time try to restore
## the before animation with same name
func fill_animation_selector():
	animation_selector.clear()
	var animations = satf_animation_preview.get_animation_names()
	var selected_new_index := 0
	for anim_index in animations.size():
		var anim = animations[anim_index]
		animation_selector.add_item(anim)
		if anim == lpc_selected_animation:
			selected_new_index = anim_index
	
	if animations.size() > 0:
		lpc_selected_animation = animations[selected_new_index]
		animation_selector.select(selected_new_index)
	

	
func _on_sheet_definition_tree_item_selected() -> void:
	var selected_item := sheet_definition_tree.get_selected()
	var metadata_dict = selected_item.get_metadata(0)
	var match_body_color := match_body_color_check.button_pressed
	
	if metadata_dict == null:
		return
	
	palette_option.clear()
	
	var sheet_path: String = metadata_dict["relative_path"]

	var type_name: String = ApplicationContext.lpc_repository.get_type_name(sheet_path)
	
	if ApplicationContext.lpc_repository.has_variants(sheet_path):
		var path_variants := ApplicationContext.lpc_repository.get_variants(sheet_path)

		variant_list.clear()
		
		for variant_name: String in path_variants:
			var sheet_collection_preview := ApplicationContext.sheet_collection_active.clone()
			# TODO: merge sheet_collection with a "white background and outline shader character"
			
			var sheet_reference := SheetReference.new(type_name, AssetReference.new(sheet_path, variant_name))
			sheet_collection_preview.register_sheet(sheet_reference, match_body_color)
			
			var grid_layer_collection_build_result := ApplicationContext.lpc_grid_layer_collection_builder.create_from_sheet_collection(sheet_collection_preview, ApplicationContext.body_type)
			var grid_sprite_composition := GridSpriteComposition.new()
			grid_sprite_composition.grid_spec_data = ApplicationContext.lpc_grid_spec_data
			grid_sprite_composition.grid_layer_collection = grid_layer_collection_build_result.grid_layer_collection
			var satf_sprite_res := ApplicationContext.lpc_satf_resource_builder.generate_satf_resource(grid_sprite_composition, true)
			
			var asset_variant_view_model := AssetVariantViewModelBuilder.build(sheet_collection_preview, satf_sprite_res, null)
			
			variant_list.add_preview(asset_variant_view_model)
			
	elif ApplicationContext.lpc_repository.has_recolors(sheet_path):
		
		# TODO: better make this somehow an UI model that gives a ready to display content
		var sheet_dict := ApplicationContext.lpc_repository.get_raw_sheet(sheet_path)
		var recolors: Array[LPCPaletteCompatibility] = ApplicationContext.lpc_repository.get_palette_compatibility_array(sheet_dict)
		
		# collect how many different material domains are in the asset and add them to the selector
		var material_index := 0
		for recolor: LPCPaletteCompatibility in recolors:
			var palette_domain_id: String = recolor.material_domain
			
			if ApplicationContext.lpc_palette_catalog.has_domain(palette_domain_id):
				palette_option.add_item(palette_domain_id, material_index)
				palette_option.set_item_metadata(material_index, sheet_path)
				material_index += 1

		# if there're some (should be in this case) than load the selected one
		if material_index > 0:
			var recolor_filter: String = palette_option.get_item_text(palette_option.get_selected_id())
			load_palette_variants_preview(sheet_path, recolors, recolor_filter, recolors[0], match_body_color)
		
	else:
		push_error("No 'variants' or 'recolors' block available for UI selection")

func create_collection_from_active():
	var grid_layer_collection_build_result := ApplicationContext.lpc_grid_layer_collection_builder.create_from_sheet_collection(ApplicationContext.sheet_collection_active, ApplicationContext.body_type)
	ApplicationContext.main_grid_sprite_composition.grid_layer_collection = grid_layer_collection_build_result.grid_layer_collection
	ApplicationContext.main_lpc_satf_layer_collection_trace_map = grid_layer_collection_build_result.lpc_satf_layer_collection_trace_map

func update_main_preview():
	var satf_sprite_resource := ApplicationContext.lpc_satf_resource_builder.generate_satf_resource(ApplicationContext.main_grid_sprite_composition)
		
	satf_animation_preview.set_satf_sprite_resource(satf_sprite_resource)
	update_satf_layer_view()
	
func update_satf_layer_view():
	var layer_view_model_array: Array[LayerViewModel] = LayerViewModelBuilder.build(ApplicationContext.main_grid_sprite_composition.grid_layer_collection)
	layer_container.update(layer_view_model_array)
	fill_animation_selector()
	
func update_lpc_layer_view():
	var lpc_layer_view_model_array: Array[LPCLayerViewModel] = LPCLayerViewModelBuilder.build(ApplicationContext.sheet_collection_active, ApplicationContext.main_lpc_satf_layer_collection_trace_map, satf_animation_preview.satf_sprite_resource)
	lpc_layer_container.update(lpc_layer_view_model_array)
	
func _on_bodytypes_button_item_selected(index: int) -> void:
	ApplicationContext.body_type = body_types.get_item_text(index)
	var sheet_category_tree_model := ApplicationContext.lpc_repository.get_sheet_category_tree_model(ApplicationContext.body_type)
	fill_category_tree(sheet_category_tree_model)
	variant_list.clear()
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()

func _on_reset_button_pressed() -> void:
	variant_list.clear()
	ApplicationContext.reset_active_sheet_collection()
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()

func _on_animation_selector_item_selected(index: int) -> void:
	lpc_selected_animation = animation_selector.get_item_text(index)
	play_lcp_animation()
	
func play_lcp_animation():
	if satf_animation_player == null:
		return
	#var directions = satf_animation_preview.get_directions()
	# TODO: port to use LCPDirection strings
	var selected_direction = lpc_direction_array[lpc_direction]
	#
	#if not directions.has(selected_direction):
		#if directions.size() > 0:
			#selected_direction = directions[0] # choose first available direction as fallback
		#else:
			#push_warning("Animation direction without any frames")
			#return
	
	var satf_full_name = "SATF" + "/" + lpc_selected_animation + "_" + selected_direction
		
	# configure for the demo animation always a loop
	var looping := true
	if looping:
		var anim: Animation = satf_animation_player.get_animation(satf_full_name)
		if anim != null:
			anim.loop_mode = Animation.LOOP_LINEAR
		
	satf_animation_player.play(satf_full_name)
	
	
func configure_directions():
	# TODO: fix directions
	var directions = [] #= anim_preview.get_directions()
	
	if directions.has("up"):
		direction_selector.enable_button(DirectionSelector.ButtonDirection.UP, true)
	else:
		direction_selector.enable_button(DirectionSelector.ButtonDirection.UP, false)
		
	if directions.has("left"):
		direction_selector.enable_button(DirectionSelector.ButtonDirection.LEFT, true)
	else:
		direction_selector.enable_button(DirectionSelector.ButtonDirection.LEFT, false)
		
	if directions.has("down"):
		direction_selector.enable_button(DirectionSelector.ButtonDirection.DOWN, true)
	else:
		direction_selector.enable_button(DirectionSelector.ButtonDirection.DOWN, false)
		
	if directions.has("right"):
		direction_selector.enable_button(DirectionSelector.ButtonDirection.RIGHT, true)
	else:
		direction_selector.enable_button(DirectionSelector.ButtonDirection.RIGHT, false)

func load_palette_variants_preview(sheet_path: String, recolor_array: Array[LPCPaletteCompatibility], recolor_filter: String, recolor: LPCPaletteCompatibility, match_body_color: bool):
	var asset_reference := AssetReference.new(sheet_path)
	var type_name: String = ApplicationContext.lpc_repository.get_type_name(sheet_path)
	#print("recolor_filter: ", recolor_filter)
		
	# TODO: move this code to LPCBlueprintBuilder or something similar
	
	var sheet_collection_preview: SheetCollection = ApplicationContext.sheet_collection_active.clone()
	var sheet_reference_preview: SheetReference = sheet_collection_preview.get_sheet(type_name)
	
	# only use the preview from the type_name slot if the asset_reference is the same
	if sheet_reference_preview != null and sheet_reference_preview.asset_reference.equals(asset_reference):
		# in this case make a copy and modify the palette variants below
		sheet_reference_preview = sheet_reference_preview.clone()
	else:
		# if the new type_name part isn't yet in the preview (the asset replace case -> then create a new one with default palette)
		sheet_reference_preview = SheetReference.new(type_name, asset_reference) # construct with default palette
	
	variant_list.clear()
	
	for collection : LPCPaletteCollectionTarget in recolor.collections:
		# if the palette material_domain has no value then inherit the material_domain from the assets recolor entry
		var palette_domain: LPCPaletteDomain
		if collection.material_domain.has_value():
			palette_domain = ApplicationContext.lpc_palette_catalog.get_domain(collection.material_domain.get_or())
		else:
			palette_domain = ApplicationContext.lpc_palette_catalog.get_domain(recolor.material_domain)
		
		var palette_collection: LPCPaletteCollection = palette_domain.get_collection(collection.collection)
		
		for palette_variant: PaletteVariant in palette_collection.get_variants():
			
			var palette_selection := LPCPaletteSelection.new(recolor.material_domain, collection, palette_variant.id)
			if match_body_color:
				palette_selection.palette_resolve_rule = LPCPaletteSelection.PaletteResolveRule.PUSH
			sheet_reference_preview.register_palette_selection(palette_selection)
	
			sheet_collection_preview.register_sheet(sheet_reference_preview, match_body_color)
			var grid_layer_collection_build_result := ApplicationContext.lpc_grid_layer_collection_builder.create_from_sheet_collection(sheet_collection_preview, ApplicationContext.body_type)
			var grid_sprite_composition := GridSpriteComposition.new()
			grid_sprite_composition.grid_layer_collection = grid_layer_collection_build_result.grid_layer_collection
			grid_sprite_composition.grid_spec_data = ApplicationContext.lpc_grid_spec_data
			var satf_sprite_res: SATFSpriteResource = ApplicationContext.lpc_satf_resource_builder.generate_satf_resource(grid_sprite_composition, true)

			# call the builder with a cloned SheetColection as the same preview is reused for the next color palette variant
			var asset_variant_view_model := AssetVariantViewModelBuilder.build(sheet_collection_preview.clone(), satf_sprite_res, palette_variant)

			variant_list.add_preview(asset_variant_view_model)
			
func open_sheet_collection_saver():
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.json"])
	dialog.filename_filter = "*.json"
	dialog.title = "Save..."

	dialog.canceled.connect(dialog.queue_free)
	dialog.file_selected.connect(func(path: String):
		save_active_sheet_collection(path)
		dialog.queue_free()
	)

	add_child(dialog)
	dialog.popup_centered(Vector2i(500, 500))
	
func open_sheet_collection_loader():
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.json"])
	dialog.filename_filter = "*.json"
	dialog.title = "Load..."

	dialog.canceled.connect(dialog.queue_free)
	dialog.file_selected.connect(func(path: String):
		load_active_sheet_collection(path)
		dialog.queue_free()
	)

	add_child(dialog)
	dialog.popup_centered(Vector2i(500, 500))
		
func save_active_sheet_collection(path: String):
	var save_dict := ApplicationContext.sheet_collection_active.to_dict()
	JsonVFS.json_to_file(save_dict, path)

func load_active_sheet_collection(path: String):
	var load_json: Dictionary = JsonVFS.json_from_file(path)
	ApplicationContext.sheet_collection_active.from_dict(load_json)
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()
	
func _on_direction_selector_direction_pressed(direction: DirectionSelector.ButtonDirection) -> void:
	lpc_direction = direction
	play_lcp_animation()

func _on_random_button_pressed() -> void:
	var type_name_array := ["hat", "hair", "legs", "vest"]
	
	for type_name in type_name_array:
		var sheet_ref := ApplicationContext.lpc_random.generate_sheet_reference(type_name)
		ApplicationContext.sheet_collection_active.register_sheet(sheet_ref)

	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()
	
		
	ResourceSaver.save(satf_animation_preview.satf_sprite_resource, "res://resources/satf_random.tres")

func _satf_animation_preview_frame_changed(value: int):
	frame_container.update(satf_animation_preview.satf_sprite_resource, satf_animation_preview.animation, satf_animation_preview.direction, satf_animation_preview.animation_frame)


func _on_variant_button_pressed() -> void:
	ApplicationContext.sheet_collection_active = ApplicationContext.lpc_random.randomize_variation(ApplicationContext.sheet_collection_active, 1.0)
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()
	
func _on_change_layer_visibility_by_id(layer_id: StringName, state: bool):
	var layer_index: int = ApplicationContext.main_grid_sprite_composition.grid_layer_collection.get_layer_index_from_id(layer_id)
	satf_animation_preview.set_layer_visible(state, layer_index)

func _on_change_layer_visibility_by_type_name(type_name: StringName, state: bool):
	var sheet_reference: SheetReference = ApplicationContext.sheet_collection_active.get_sheet(type_name)
	
	var grid_layer_data_array: Array[GridLayerData] = ApplicationContext.main_lpc_satf_layer_collection_trace_map.sheet_reference_to_grid_layer_data_array[sheet_reference]
	
	for grid_layer_data: GridLayerData in grid_layer_data_array:
		var layer_index: int = ApplicationContext.main_grid_sprite_composition.grid_layer_collection.get_layer_index_from_id(grid_layer_data.layer_id.get_or())
		satf_animation_preview.set_layer_visible(state, layer_index)

func _on_remove_type_name_from_collection(type_name: StringName):
	ApplicationContext.sheet_collection_active.remove_sheet(type_name)
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()
	

func _on_palette_option_item_selected(index: int) -> void:
	var sheet_path: String = palette_option.get_item_metadata(index)
	var recolor_filter: String = palette_option.get_item_text(index)
	var sheet_dict := ApplicationContext.lpc_repository.get_raw_sheet(sheet_path)
	var recolors: Array[LPCPaletteCompatibility] = ApplicationContext.lpc_repository.get_palette_compatibility_array(sheet_dict)
	var match_body_color := match_body_color_check.button_pressed
	load_palette_variants_preview(sheet_path, recolors, recolor_filter, recolors[index], match_body_color)


func _on_variant_scale_control_request_variant_scale(variant_scale: float) -> void:
	pass # Replace with function body.



func _on_apply_sheet_collection_intent():
	create_collection_from_active()
	update_main_preview()
	update_lpc_layer_view()


func _on_settings_button_pressed() -> void:
	var settings_window: SettingsWindow = SETTINGS_WINDOW.instantiate()
	add_child(settings_window)
	settings_window.update_settings.connect(func():
		# TODO: the reinit "concept" is a complete mess!
		ApplicationContext.init_service()
		#ApplicationContext.reset_active_sheet_collection()
		var sheet_category_tree_model := ApplicationContext.lpc_repository.get_sheet_category_tree_model(ApplicationContext.body_type)
		fill_category_tree(sheet_category_tree_model)
		fill_animation_selector()
		create_collection_from_active()
		update_main_preview()
		update_lpc_layer_view()
		play_lcp_animation()
	)
	settings_window.popup_centered()


func _on_load_button_pressed() -> void:
	open_sheet_collection_loader()



func _on_save_button_pressed() -> void:
	open_sheet_collection_saver()
