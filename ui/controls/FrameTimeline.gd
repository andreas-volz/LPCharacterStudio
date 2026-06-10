class_name FrameTimeline
extends HBoxContainer

const FRAME_CONTROL = preload("uid://bwcsbhhmcvivy")

const ANIMATION_ILLEGAL := -1

var satf_sprite_resource: SATFSpriteResource = null
var animation: int = ANIMATION_ILLEGAL
var direction: int = ANIMATION_ILLEGAL
var animation_frame: int = ANIMATION_ILLEGAL 

func clear():
	for child in get_children():
		child.queue_free()

	
func update(resource_param: SATFSpriteResource, animation_param:int, direction_param: int, animation_frame_param: int):
	var dirty_resource_flag := false
	var dirty_animation_flag := false
	var dirty_direction_flag := false
	var dirty_animation_frame_flag := false
	
	if resource_param != satf_sprite_resource:
		dirty_resource_flag = true
		satf_sprite_resource = resource_param
	
	var new_animation := clampi(animation_param, 0,  maxi(0, satf_sprite_resource.animations.size() - 1))
	if new_animation != animation:
		dirty_animation_flag = true
		animation = new_animation
	
	var new_direction := clampi(direction_param, 0, maxi(0, satf_sprite_resource.animations[animation].directions.size() - 1))
	if direction_param != direction:
		dirty_direction_flag = true
		direction = new_direction
	
	var frames_size: int = satf_sprite_resource.animations[animation].directions[direction].frame_ids.size()
	var new_animation_frame = clampi(animation_frame_param, 0, maxi(0, frames_size - 1))
	if animation_frame_param != animation_frame:
		dirty_animation_frame_flag = true
		animation_frame = new_animation_frame
	
	# create new frames 
	# TODO: as optimization only remove/add changed frame number
	# create different "dirty" states
	if dirty_resource_flag or dirty_animation_flag or dirty_direction_flag or dirty_animation_frame_flag:
		clear()
		
		for frame_num in frames_size:
			var frame_control: FrameControl = FRAME_CONTROL.instantiate()
			add_child(frame_control)
			frame_control.satf_sprite.satf_sprite_resource = satf_sprite_resource
			frame_control.satf_sprite.graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path()
			frame_control.satf_sprite.direction = direction
			frame_control.satf_sprite.animation = animation
			frame_control.satf_sprite.animation_frame = frame_num
			#frame_control.update_size()
			if frame_num == animation_frame:
				frame_control.set_selected(true)
	
			#print(frame_control.satf_sprite.get_size())
