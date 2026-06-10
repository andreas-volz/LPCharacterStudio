class_name VariantContainer
extends PanelContainer

@onready var container: VBoxContainer = %Container
@onready var palette_display: PaletteDisplay = %PaletteDisplay
@onready var variant_control: VariantControl = %VariantControl

var _view_model: AssetVariantViewModel

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func set_view_model(view_model: AssetVariantViewModel):
	_view_model = view_model
	variant_control.satf_sprite.satf_sprite_resource = view_model.satf_sprite_preview_resource
	variant_control.satf_sprite.graphic_root_path = ApplicationContext.lpc_loader_service.get_spritesheets_path()
	palette_display.colors = view_model.palette_colors
	variant_control.satf_sprite.direction = 2 # TODO: 2 means "down", but there needs to be a better API
	variant_control.update_minimum_size()

func _on_set_variant_scale(value: float):
	variant_control.sprite_scale = Vector2(value / 100.0, value / 100.0)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			var intent := ApplySheetCollectionIntent.new()
			intent.sheet_collection = _view_model.sheet_collection
			ApplicationController.handle_intent(intent)
