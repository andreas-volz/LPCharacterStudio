class_name LPCSATFPaletteTraceMap
extends RefCounted

# LPC -> SATF
# key: LPCPaletteSelection, value: PaletteBinding
var lpc_palette_selection_to_palette_binding: Dictionary = {}

# SATF -> LPC
# key: PaletteBinding, value: LPCPaletteSelection
var palette_binding_to_lpc_palette_selection: Dictionary = {}
