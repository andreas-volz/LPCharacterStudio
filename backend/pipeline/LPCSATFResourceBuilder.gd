class_name LPCSATFResourceBuilder
extends RefCounted

# TODO: maybe remove this class and call normalize() from outside...
func generate_satf_resource(grid_sprite_composition: GridSpriteComposition, preview: bool = false) -> SATFSpriteResource:

	var satf_sprite_resource := ApplicationContext.lpc_grid_sprite_strategy.normalize(grid_sprite_composition, preview)

	return satf_sprite_resource
