class_name VariantScaleControl
extends MarginContainer

signal variant_scaled(variant_scale: float)

@onready var variant_preview_scale_label: Label = %VariantPreviewScaleLabel
@onready var variant_preview_scale_slider: HSlider = %VariantPreviewScaleSlider
@onready var variant_list: HFlowContainer = %VariantList

func _ready() -> void:
	pass

func _on_variant_preview_scale_slider_value_changed(value: float) -> void:
	variant_preview_scale_label.text = str(type_convert(value, TYPE_INT)) + " %"
	variant_scaled.emit(value)
