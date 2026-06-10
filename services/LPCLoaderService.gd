class_name LPCLoaderService
extends RefCounted

const PATH := "user://lpc_loader.cfg"

var _app_config = AppConfig.new(PATH)

func init_service() -> void:
	_app_config.load()

func get_sheet_definitions_path() -> String:
	return _app_config.get_value("path", "sheet_definitons", "sheet_defintions")
	
func set_sheet_defintions_path(path: String):
	_app_config.set_value("path", "sheet_definitons", path)
	_app_config.save()
	
func get_spritesheets_path() -> String:
	return _app_config.get_value("path", "spritesheets", "spritesheets")
	
func set_spritesheets_path(path: String):
	_app_config.set_value("path", "spritesheets", path)
	_app_config.save()
	
func get_palette_definitions_path() -> String:
	return _app_config.get_value("path", "palette_definitions", "palette_definitions")
	
func set_palette_definitions_path(path: String):
	_app_config.set_value("path", "palette_definitions", path)
	_app_config.save()
