class_name AppConfig
extends RefCounted

var _config_path: String
var _cfg := ConfigFile.new()

func _init(path: String) -> void:
	_config_path = path

func load():
	_cfg.load(_config_path)

func save():
	_cfg.save(_config_path)

func get_value(section, key, default):
	return _cfg.get_value(section, key, default)

func set_value(section, key, value):
	_cfg.set_value(section, key, value)
