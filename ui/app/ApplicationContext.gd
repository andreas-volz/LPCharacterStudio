# Global class ApplicationContext
extends Node

var lpc_loader_service := LPCLoaderService.new()
var lpc_repository := LPCAssetRepository.new()
var lpc_palette_repository := LPCPaletteRepository.new()
var lpc_palette_catalog: LPCPaletteCatalog
var lpc_random := LPCRandomizer.new(lpc_repository, lpc_palette_repository)
var lpc_grid_spec_data := GridSpecData.new()
var lpc_grid_layer_collection_builder := LPCGridLayerCollectionBuilder.new(lpc_repository)
var lpc_grid_sprite_strategy: GridSpriteStrategy
var lpc_satf_resource_builder := LPCSATFResourceBuilder.new()

# this holds the layer data from the main editor view
var main_grid_sprite_composition := GridSpriteComposition.new()
var main_lpc_satf_layer_collection_trace_map: LPCSATFLayerCollectionTraceMap

var body_type := "male"

var sheet_collection_default := SheetCollection.make([
	SheetReference.new("body", AssetReference.new("body/body"), [
		LPCPaletteSelection.new("body",  LPCPaletteCollectionTarget.new("", "ulpc"), "blue")
		]),
	#SheetReference.new("body", AssetReference.new("body/body"), [
		#
		#]),
	SheetReference.new("head", AssetReference.new("head/heads/human/heads_human_male"), [
		LPCPaletteSelection.new("body", LPCPaletteCollectionTarget.new("", "ulpc"), "blue"),
		LPCPaletteSelection.new("eye", LPCPaletteCollectionTarget.new("", "ulpc"), "blue")
		]),

])

var sheet_collection_active := sheet_collection_default.clone()

func init_service():
	lpc_loader_service.init_service()
	
	_init_repositories()
	_init_palettes()
	_init_spec_data()
	_init_default_layer_collection()
	_init_sprite_strategy()

func reset_active_sheet_collection():
	sheet_collection_active = sheet_collection_default.clone()

#
# internal functions
#

func _init_repositories():
	lpc_repository.load_from_path(lpc_loader_service.get_sheet_definitions_path())
	lpc_palette_repository.load_from_path(lpc_loader_service.get_palette_definitions_path())

func _init_spec_data():
	lpc_grid_spec_data.load_from_path("res://specification/lpc-spec.json")
	main_grid_sprite_composition.grid_spec_data = lpc_grid_spec_data

func _init_default_layer_collection():
	var grid_layer_collection: GridLayerCollection = lpc_grid_layer_collection_builder.create_from_sheet_collection(ApplicationContext.sheet_collection_active, ApplicationContext.body_type).grid_layer_collection
	main_grid_sprite_composition.grid_layer_collection = grid_layer_collection

func _init_sprite_strategy():
	var lpc_grid_sprite_strategy_builder := LPCGridSpriteStrategyBuilder.new()
	lpc_grid_sprite_strategy = lpc_grid_sprite_strategy_builder.build_sprite_strategy()
	const LPC_DIRECTION_MAPPING := preload("res://resources/LPCDirection.tres")
	lpc_grid_sprite_strategy.set_satf_direction_mapping(LPC_DIRECTION_MAPPING)

func _init_palettes():
	var lpc_material_registry_builder := LPCPaletteCatalogBuilder.new()
	lpc_palette_catalog = lpc_material_registry_builder.build_material_registry(lpc_palette_repository)
	lpc_grid_layer_collection_builder.palette_catalog = lpc_palette_catalog
