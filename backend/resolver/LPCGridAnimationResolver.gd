class_name LPCGridAnimationResolver
extends GridAnimationResolver

func resolve(anim_spec: GridSpecAnimation, layer_data: GridLayerData, animation_name: StringName) -> OptionalStringName:
	var resolved_animation_name := OptionalStringName.new()
		
	var animation_names := layer_data.get_animation_names()
	
	# if the requested animation is in the current Layer set then this is the easy key and return it
	if animation_names.has(animation_name):
		resolved_animation_name.set_value(animation_name) 
	else:
		## if not try to resolve it by the fallback mechanism for custom_animations
		if layer_data.animations.size() > 1:
			resolved_animation_name = anim_spec.get_inherits_from()
	
	return resolved_animation_name
