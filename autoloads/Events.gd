extends Node

@warning_ignore("unused_signal")
signal change_layer_visibility_by_type_name(type_name: StringName, state: bool)

@warning_ignore("unused_signal")
signal change_layer_visibility_by_id(layer_id: StringName, state: bool)

@warning_ignore("unused_signal")
signal remove_type_name_from_collection(type_name: StringName)

@warning_ignore("unused_signal")
signal variant_preview_scale(value: float)
