class_name LPCGridSpriteStrategyBuilder
extends RefCounted

func build_sprite_strategy() -> GridSpriteStrategy:
	var grid_sprite_strategy := GridSpriteStrategy.new()
	# create the Resolver Context
	var grid_resolver_context := GridResolverContext.new()
	
	# create the Path Resolver and assign the graphic path
	var lpc_grid_path_resolver := LPCGridPathResolver.new()
	grid_resolver_context.grid_path_resolver = lpc_grid_path_resolver
	lpc_grid_path_resolver._graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path() # this allows "EarlyLoading" texture check
	
	# create the Animation Resolver
	var lpc_grid_animation_resolver := LPCGridAnimationResolver.new()
	grid_resolver_context.grid_animation_resolver = lpc_grid_animation_resolver
	
	# create the Rect Resolver
	var simple_grid_rect_resolver := SimpleGridRectResolver.new()
	simple_grid_rect_resolver._graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path() # this allows to check image size and generate the texture rects
	grid_resolver_context.grid_rect_resolver = simple_grid_rect_resolver
	
	grid_sprite_strategy.set_resolver_context(grid_resolver_context) # assign the Resolver Context
	
	return grid_sprite_strategy
