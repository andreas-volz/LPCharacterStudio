class_name LPCSATFLayerCollectionTraceMap
extends RefCounted

## LPC -> SATF
## key: SheetReference, value: Array[GridLayerData]
var sheet_reference_to_grid_layer_data_array: Dictionary = {}

## LPC -> TraceMap -> SATF
## key: SheetReference, value: Array[LPCSATFPaletteTraceMap]
var sheet_reference_to_palette_trace_map_array: Dictionary = {}
