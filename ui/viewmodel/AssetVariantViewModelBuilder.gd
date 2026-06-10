class_name AssetVariantViewModelBuilder
extends RefCounted

static func build(sheet_collection: SheetCollection, satf_sprite_resource: SATFSpriteResource, palette_variant: PaletteVariant) -> AssetVariantViewModel:
	var asset_variant_view_model := AssetVariantViewModel.new()
	
	asset_variant_view_model.satf_sprite_preview_resource = satf_sprite_resource
	asset_variant_view_model.sheet_collection = sheet_collection
	
	if palette_variant != null:
		var packed_colors: PackedColorArray = []
		for hex_color in palette_variant.colors:
			packed_colors.append(Color(hex_color))
		asset_variant_view_model.palette_colors = packed_colors
	
	return asset_variant_view_model
	
