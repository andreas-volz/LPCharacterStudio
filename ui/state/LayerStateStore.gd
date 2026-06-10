## Runtime store for persistent UI-related layer state across rebuilds.
## Keeps user-driven state (visibility, overrides, ordering hints) separate
## from structural layer data (GridLayerCollection, SpriteDefinition).

class_name LayerStateStore
extends RefCounted


# -------------------------
# Variables
# -------------------------

## Runtime state per layer_id.
## Maps layer_id -> LayerState (Dictionary).
var _layer_states: Dictionary = {}
var _default_visible: bool = true


# -------------------------
# Public API
# -------------------------

## Returns whether a layer is visible.
#func is_visible(layer_id: String) -> bool:
	#return false


## Sets visibility state for a layer.
#func set_visible(layer_id: String, visible: bool) -> void:
	#pass


## Returns full stored state for a layer.
#func get_state(layer_id: String) -> Dictionary:
	#return {}


## Overwrites full state for a layer.
#func set_state(layer_id: String, state: Dictionary) -> void:
	#pass


## Removes stored state for a layer.
#func remove_state(layer_id: String) -> void:
	#pass


## Clears all stored layer state.
#func clear() -> void:
	#pass


# -------------------------
# Private API
# -------------------------

## Ensures a state entry exists for a layer.
#func _ensure_state(layer_id: String) -> Dictionary:
	#return {}


## Creates a default state entry.
#func _create_default_state() -> Dictionary:
	#return {}
