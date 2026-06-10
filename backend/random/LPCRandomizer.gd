class_name LPCRandomizer
extends RefCounted


# =========================================================
# State
# =========================================================

var _lpc_repo: LPCAssetRepository
var _lpc_palette_repo: LPCPaletteRepository
var _rng := RandomNumberGenerator.new()

## Stores the active seed (-1 means "no fixed seed")
var _seed: int = -1

# =========================================================
# Initialization
# =========================================================

## Constructor requires a valid LPCAssetRepository reference
func _init(repo: LPCAssetRepository, palette_repo: LPCPaletteRepository) -> void:
	_lpc_repo = repo
	_lpc_palette_repo = palette_repo

# =========================================================
# Seed Control
# =========================================================

## Sets a fixed seed for deterministic results
func set_seed(seed_param: int) -> void:
	_seed = seed_param

## Clears the fixed seed and returns to non-deterministic behavior
func clear_seed() -> void:
	_seed = -1

## Returns the currently active seed (-1 if none is set)
func get_seed() -> int:
	return _seed

# =========================================================
# Core Randomization API
# =========================================================

## Returns a fully randomized character configuration
## If seed >= 0, overrides internal seed for this call only
#func randomize_all(seed_param: int = -1) -> Dictionary:
	#return {}


## Randomizes only the given type_names (e.g. ["helmet", "hair"])
#func randomize_types(active: Dictionary, types: Array, seed_param: int = -1) -> Dictionary:
	#return {}


## Randomizes entries based on a path filter (e.g. "hair/")
#func randomize_by_path(active: Dictionary, path_filter: String, seed_param: int = -1) -> Dictionary:
	#return {}

## Applies variation to an existing configuration
## strength [0.0 - 1.0] defines probability of change per entry
func randomize_variation(active_sheet: SheetCollection, strength: float, seed_param: int = -1) -> SheetCollection:
	var rng = _init_rng(seed_param)
	strength = clampf(strength, 0.0, 1.0)

	var new_active_sheet: SheetCollection = active_sheet.clone()
	
	# TODO: better implement this by _sheet_variant_dict??
	for type_name in active_sheet.get_sheets_type_names():
		var rand_strength: float = rng.randf()
		if rand_strength <= strength:
			var sheet_ref: SheetReference = new_active_sheet.get_sheet(type_name)
			var sheet_dict: Dictionary = _lpc_repo.get_raw_sheet(sheet_ref.asset_reference.base_path)

			if _lpc_repo.has_variants(sheet_ref.asset_reference.base_path):
				var variants: Array = _lpc_repo.get_variants(sheet_ref.asset_reference.base_path)
				var new_variant: String = _pick_random(variants, rng)
				sheet_ref.asset_reference.variant.set_value(new_variant)
			elif _lpc_repo.has_recolors(sheet_ref.asset_reference.base_path):
				var palette_compatibility_array:Array[LPCPaletteCompatibility] = _lpc_repo.get_palette_compatibility_array(sheet_dict)
				
				for palette_compatibility: LPCPaletteCompatibility in palette_compatibility_array:
					var collection: LPCPaletteCollectionTarget = _pick_random(palette_compatibility.collections, rng)
					# TODO implement random palette chooser
					pass
	
	return new_active_sheet

func generate_sheet_reference(type_name: String, seed_param: int = -1) -> SheetReference:
	var rng = _init_rng(seed_param)
	var sheet_ref := SheetReference.new(type_name)
	var sheet_path_array: Array = _lpc_repo.get_sheet_paths(type_name)
	# TODO this works only for classic variant assets -> support palette images
	if not sheet_path_array.is_empty():
		var sheet_path: String = _pick_random(sheet_path_array, rng)
		sheet_ref.asset_reference.base_path = sheet_path
		var variants: Array = _lpc_repo.get_variants(sheet_path)
		var new_variant: String = _pick_random(variants, rng)
		sheet_ref.asset_reference.variant.set_value(new_variant)
	
	return sheet_ref

## Advanced entry point using a flexible rule set
#func randomize_with_rules(active: Dictionary, rules: Dictionary, seed_param: int = -1) -> Dictionary:
	#return {}


## Returns a random entry for a single type (e.g. "helmet")
#func randomize_single(type_name: String, seed_param: int = -1) -> Dictionary:
	#return {}


## Returns a variation of a single existing entry
#func randomize_single_variation(type_name: String, current: Dictionary, strength: float, seed_param: int = -1) -> Dictionary:
	#return {}


# =========================================================
# Optional Utility API
# =========================================================

## Returns all available type names from repository
#func get_available_types() -> Array:
	#return []


## Returns all files for a given type
#func get_files_for_type(type_name: String) -> Array:
	#return []


## Returns all variants for a given type + path
#func get_variants(type_name: String, path: String) -> Array:
	#return []


# =========================================================
# Internal Core Methods
# =========================================================

## Initializes RNG depending on seed state
## if seed_param is -1 then return the LPCRandomizer global RandomNumberGenerator
func _init_rng(seed_param: int) -> RandomNumberGenerator:
	if seed_param == -1:
		return _rng
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_param
	return rng

func _pick_random(array: Array, rng: RandomNumberGenerator):
	if array.is_empty():
		return null
	return array[rng.randi_range(0, array.size() - 1)]

## Core selection logic for a random entry
#func _pick_random_entry(type_name: String, filters: Dictionary) -> Dictionary:
	#return {}


## Picks a similar entry based on current file
#func _pick_similar_entry(type_name: String, current_file: String) -> Dictionary:
	#return {}


## Applies rule-based filtering on files
#func _filter_files(type_name: String, files: Array, filters: Dictionary) -> Array:
	#return []


## Determines whether a type should be modified based on rules
#func _should_modify(type_name: String, rules: Dictionary) -> bool:
	#return false


## Applies full rule set to a configuration
#func _apply_rules(active: Dictionary, rules: Dictionary) -> Dictionary:
	#return {}


## Helper: checks if path matches any pattern in list
#func _matches_any(path: String, patterns: Array) -> bool:
	#return false
