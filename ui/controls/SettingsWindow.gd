class_name SettingsWindow
extends Window

signal update_settings

@onready var sheet_definitions_path_line_edit: LineEdit = %SheetDefinitionsPathLineEdit
@onready var sheet_definitions_folder_select_button: Button = %SheetDefinitionsFolderSelectButton

@onready var spritesheets_path_line_edit: LineEdit = %SpritesheetsPathLineEdit
@onready var spritesheets_folder_select_button: Button = %SpritesheetsFolderSelectButton

@onready var palette_definitions_path_line_edit: LineEdit = %PaletteDefinitionsPathLineEdit
@onready var palette_definitions_folder_select_button: Button = %PaletteDefinitionsFolderSelectButton


func _ready() -> void:
	sheet_definitions_path_line_edit.text = ApplicationContext.lpc_loader_service.get_sheet_definitions_path()
	sheet_definitions_folder_select_button.pressed.connect(open_folder_picker.bind(sheet_definitions_path_line_edit))
	
	spritesheets_path_line_edit.text = ApplicationContext.lpc_loader_service.get_spritesheets_path()
	spritesheets_folder_select_button.pressed.connect(open_folder_picker.bind(spritesheets_path_line_edit))
	
	palette_definitions_path_line_edit.text = ApplicationContext.lpc_loader_service.get_palette_definitions_path()
	palette_definitions_folder_select_button.pressed.connect(open_folder_picker.bind(palette_definitions_path_line_edit))

func close():
	ApplicationContext.lpc_loader_service.set_sheet_defintions_path(sheet_definitions_path_line_edit.text)
	ApplicationContext.lpc_loader_service.set_spritesheets_path(spritesheets_path_line_edit.text)
	ApplicationContext.lpc_loader_service.set_palette_definitions_path(palette_definitions_path_line_edit.text)
	update_settings.emit()
	hide()

func open_folder_picker(line_edit: LineEdit):
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.title = "Select Folder"

	dialog.canceled.connect(dialog.queue_free)
	dialog.dir_selected.connect(func(path: String):
		line_edit.text = path
		dialog.queue_free()
	)

	add_child(dialog)
	dialog.popup_centered(Vector2i(800, 500))

func _on_close_requested() -> void:
	close()
	
func _on_close_button_pressed() -> void:
	close()
