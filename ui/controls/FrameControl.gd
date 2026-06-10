@tool
class_name FrameControl
extends SATFSpriteControl

@onready var frame_select: Panel = $FrameSelect
@onready var checker_board: TextureRect = $CheckerBoard

func set_selected(state: bool):
	frame_select.visible = state
	
#func update_size():
	#super.update_size()
